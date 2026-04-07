-- ============================================================
-- Sprint Rollover Automation
-- Resolve: sprints encerrados não rolam automaticamente,
-- tarefas órfãs ficam no sprint passado, novo sprint não nasce.
--
-- Estratégia (recorte semanal):
--   1. Sprints cujo sprint_fim < CURRENT_DATE → status='encerrado'
--   2. Se NÃO existe sprint cobrindo CURRENT_DATE → criar novo
--      (segunda a domingo da semana atual)
--   3. Mover tarefas não-concluídas do sprint encerrado pro novo
--   4. Marcar o novo como 'ativo'
-- ============================================================

CREATE OR REPLACE FUNCTION fn_sprint_rollover()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_today DATE := CURRENT_DATE;
  v_week_start DATE;
  v_week_end   DATE;
  v_active_sprint RECORD;
  v_new_sprint_id TEXT;
  v_new_sprint_name TEXT;
  v_closed_count INT := 0;
  v_moved_count INT := 0;
  v_created_new BOOLEAN := false;
  v_existing_active TEXT;
BEGIN
  -- Semana ISO: segunda como início
  v_week_start := v_today - ((EXTRACT(ISODOW FROM v_today)::INT - 1));
  v_week_end   := v_week_start + 6;

  -- ----------------------------------------------------------
  -- 1. Encerrar sprints expirados
  -- ----------------------------------------------------------
  UPDATE god_lists
     SET sprint_status = 'encerrado',
         updated_at = now()
   WHERE tipo = 'sprint'
     AND sprint_fim IS NOT NULL
     AND sprint_fim < v_today
     AND sprint_status NOT IN ('encerrado','arquivado');
  GET DIAGNOSTICS v_closed_count = ROW_COUNT;

  -- ----------------------------------------------------------
  -- 2. Verifica se já existe sprint cobrindo a semana atual
  -- ----------------------------------------------------------
  SELECT id INTO v_existing_active
    FROM god_lists
   WHERE tipo = 'sprint'
     AND sprint_inicio <= v_today
     AND sprint_fim    >= v_today
   ORDER BY sprint_inicio DESC
   LIMIT 1;

  IF v_existing_active IS NULL THEN
    -- Criar sprint da semana atual
    v_new_sprint_id := 'sprint_' || to_char(v_week_start, 'YYYYMMDD');
    v_new_sprint_name := format(
      'Sprint %s (%s - %s)',
      to_char(v_week_start, 'IW'),
      to_char(v_week_start, 'DD/MM'),
      to_char(v_week_end,   'DD/MM')
    );

    INSERT INTO god_lists (
      id, nome, tipo, space_id,
      sprint_inicio, sprint_fim, sprint_status,
      created_at, updated_at
    )
    VALUES (
      v_new_sprint_id,
      v_new_sprint_name,
      'sprint',
      'space_sistema',
      v_week_start,
      v_week_end,
      'ativo',
      now(),
      now()
    )
    ON CONFLICT (id) DO UPDATE SET
      sprint_status = 'ativo',
      updated_at = now()
    RETURNING id INTO v_new_sprint_id;

    v_created_new := true;
  ELSE
    v_new_sprint_id := v_existing_active;
    -- Garante que ele está marcado como ativo
    UPDATE god_lists
       SET sprint_status = 'ativo', updated_at = now()
     WHERE id = v_new_sprint_id
       AND sprint_status <> 'ativo';
  END IF;

  -- ----------------------------------------------------------
  -- 3. Mover tarefas órfãs (não-concluídas em sprints encerrados) → sprint atual
  -- ----------------------------------------------------------
  UPDATE god_tasks t
     SET sprint_id = v_new_sprint_id,
         updated_at = now()
    FROM god_lists l
   WHERE t.sprint_id = l.id
     AND l.tipo = 'sprint'
     AND l.sprint_fim < v_today
     AND t.status NOT IN ('concluida','cancelada','arquivada')
     AND t.sprint_id <> v_new_sprint_id;
  GET DIAGNOSTICS v_moved_count = ROW_COUNT;

  -- ----------------------------------------------------------
  -- 4. Snapshot final
  -- ----------------------------------------------------------
  PERFORM fn_sprint_snapshot(v_new_sprint_id);

  RETURN jsonb_build_object(
    'today', v_today,
    'week_start', v_week_start,
    'week_end', v_week_end,
    'closed_count', v_closed_count,
    'created_new_sprint', v_created_new,
    'active_sprint_id', v_new_sprint_id,
    'tasks_moved', v_moved_count
  );
END;
$$;

COMMENT ON FUNCTION fn_sprint_rollover() IS
  'Automação semanal de sprints. Encerra sprints expirados, cria sprint da semana atual se não existir, move tarefas órfãs, marca o atual como ativo. Idempotente — pode rodar quantas vezes quiser.';

GRANT EXECUTE ON FUNCTION fn_sprint_rollover() TO authenticated, service_role;

-- ============================================================
-- Disparo imediato pra desbloquear o estado atual
-- ============================================================
DO $$
DECLARE
  result jsonb;
BEGIN
  result := fn_sprint_rollover();
  RAISE NOTICE 'Sprint rollover result: %', result;
END $$;
