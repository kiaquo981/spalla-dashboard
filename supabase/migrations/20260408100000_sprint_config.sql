-- ============================================================
-- Sprint Configuration + Enhanced CRUD
-- Adds sprint_duration_days to god_spaces (configurable per space)
-- Adds GET/POST/PATCH endpoints for sprints
-- ============================================================

-- 1. Sprint duration config per space (default 7 days)
ALTER TABLE god_spaces ADD COLUMN IF NOT EXISTS sprint_duration_days INT DEFAULT 7;
ALTER TABLE god_spaces ADD COLUMN IF NOT EXISTS sprint_auto_create BOOLEAN DEFAULT true;

COMMENT ON COLUMN god_spaces.sprint_duration_days IS
  'Duração padrão do sprint em dias (7=semanal, 14=quinzenal, 30=mensal). Configurável por space.';
COMMENT ON COLUMN god_spaces.sprint_auto_create IS
  'Se true, fn_sprint_rollover cria sprints automaticamente ao expirar o atual.';

-- 2. Update fn_sprint_rollover to use configurable duration
CREATE OR REPLACE FUNCTION fn_sprint_rollover()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_today DATE := CURRENT_DATE;
  v_space RECORD;
  v_active TEXT;
  v_new_id TEXT;
  v_new_name TEXT;
  v_start DATE;
  v_end DATE;
  v_closed INT := 0;
  v_created INT := 0;
  v_moved INT := 0;
BEGIN
  -- Process each space with auto_create=true
  FOR v_space IN
    SELECT id, nome, sprint_duration_days
      FROM god_spaces
     WHERE sprint_auto_create = true
  LOOP
    -- Close expired sprints in this space
    UPDATE god_lists
       SET sprint_status = 'encerrado', updated_at = now()
     WHERE tipo = 'sprint'
       AND space_id = v_space.id
       AND sprint_fim < v_today
       AND sprint_status NOT IN ('encerrado','arquivado');
    v_closed := v_closed + (SELECT count(*) FROM god_lists
                             WHERE tipo='sprint' AND space_id=v_space.id
                               AND sprint_status='encerrado'
                               AND updated_at > now() - interval '5 seconds');

    -- Check if active sprint exists covering today
    SELECT id INTO v_active
      FROM god_lists
     WHERE tipo = 'sprint'
       AND space_id = v_space.id
       AND sprint_inicio <= v_today
       AND sprint_fim >= v_today
       AND sprint_status = 'ativo'
     LIMIT 1;

    IF v_active IS NULL THEN
      -- Calculate start based on duration
      v_start := v_today;
      v_end := v_today + (COALESCE(v_space.sprint_duration_days, 7) - 1);

      v_new_id := 'sprint_' || v_space.id || '_' || to_char(v_start, 'YYYYMMDD');
      v_new_name := format('Sprint %s (%s - %s)',
        to_char(v_start, 'IW'),
        to_char(v_start, 'DD/MM'),
        to_char(v_end, 'DD/MM'));

      INSERT INTO god_lists (id, nome, tipo, space_id, sprint_inicio, sprint_fim, sprint_status, created_at, updated_at)
      VALUES (v_new_id, v_new_name, 'sprint', v_space.id, v_start, v_end, 'ativo', now(), now())
      ON CONFLICT (id) DO UPDATE SET sprint_status = 'ativo', updated_at = now();

      v_active := v_new_id;
      v_created := v_created + 1;
    END IF;

    -- Move orphan tasks from closed sprints to active
    UPDATE god_tasks t
       SET sprint_id = v_active, updated_at = now()
      FROM god_lists l
     WHERE t.sprint_id = l.id
       AND l.tipo = 'sprint'
       AND l.space_id = v_space.id
       AND l.sprint_status = 'encerrado'
       AND t.status NOT IN ('concluida','cancelada','arquivada')
       AND t.sprint_id <> v_active;
    GET DIAGNOSTICS v_moved = ROW_COUNT;
  END LOOP;

  -- Also handle the legacy sprint_20260406 format
  UPDATE god_lists SET sprint_status = 'encerrado', updated_at = now()
   WHERE tipo = 'sprint' AND sprint_fim < v_today
     AND sprint_status NOT IN ('encerrado','arquivado')
     AND id LIKE 'sprint_%';

  PERFORM fn_sprint_snapshot(id) FROM god_lists WHERE tipo='sprint' AND sprint_status='ativo';

  RETURN jsonb_build_object(
    'today', v_today,
    'closed', v_closed,
    'created', v_created,
    'moved', v_moved
  );
END;
$$;

-- 3. View: sprints with task counts (enhanced)
CREATE OR REPLACE VIEW vw_sprint_dashboard AS
SELECT
  l.id AS sprint_id,
  l.nome AS sprint_name,
  l.sprint_inicio,
  l.sprint_fim,
  l.sprint_status,
  l.space_id,
  s.nome AS space_name,
  s.sprint_duration_days,
  COUNT(t.id) AS total_tasks,
  COUNT(t.id) FILTER (WHERE t.status = 'concluida') AS done_tasks,
  COUNT(t.id) FILTER (WHERE t.status IN ('pendente','em_andamento')) AS active_tasks,
  COUNT(t.id) FILTER (WHERE t.status IN ('bloqueada','pausada')) AS blocked_tasks,
  COALESCE(SUM(t.points), 0) AS total_points,
  COALESCE(SUM(t.points) FILTER (WHERE t.status = 'concluida'), 0) AS done_points,
  CASE WHEN COUNT(t.id) > 0
    THEN ROUND(COUNT(t.id) FILTER (WHERE t.status = 'concluida')::NUMERIC / COUNT(t.id) * 100)
    ELSE 0
  END AS progress_pct,
  -- Days remaining
  GREATEST(0, (l.sprint_fim - CURRENT_DATE)) AS days_remaining
FROM god_lists l
LEFT JOIN god_spaces s ON s.id = l.space_id
LEFT JOIN god_tasks t ON t.sprint_id = l.id
WHERE l.tipo = 'sprint'
GROUP BY l.id, l.nome, l.sprint_inicio, l.sprint_fim, l.sprint_status, l.space_id, s.nome, s.sprint_duration_days;

GRANT SELECT ON vw_sprint_dashboard TO authenticated, anon, service_role;
