-- ============================================================
-- Sprint Management — points, time estimates, sprint stats
-- Phase 2: ClickUp Internalization
-- Date: 2026-04-07
-- ============================================================

-- 1. Add sprint-related columns to god_tasks
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS points INTEGER;
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS time_estimate INTEGER; -- minutes
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS sprint_id VARCHAR(50) REFERENCES god_lists(id);

CREATE INDEX IF NOT EXISTS idx_god_tasks_sprint ON god_tasks(sprint_id);
CREATE INDEX IF NOT EXISTS idx_god_tasks_points ON god_tasks(points) WHERE points IS NOT NULL;

-- 2. Sprint stats view — aggregated per sprint
CREATE OR REPLACE VIEW vw_sprint_stats AS
SELECT
  l.id AS sprint_id,
  l.nome AS sprint_name,
  l.sprint_inicio,
  l.sprint_fim,
  l.sprint_status,
  l.space_id,
  COUNT(t.id) AS total_tasks,
  COUNT(t.id) FILTER (WHERE t.status = 'concluida') AS done_tasks,
  COUNT(t.id) FILTER (WHERE t.status = 'pendente') AS pending_tasks,
  COUNT(t.id) FILTER (WHERE t.status = 'em_andamento') AS in_progress_tasks,
  COALESCE(SUM(t.points), 0) AS total_points,
  COALESCE(SUM(t.points) FILTER (WHERE t.status = 'concluida'), 0) AS done_points,
  COALESCE(SUM(t.points) FILTER (WHERE t.status != 'concluida'), 0) AS remaining_points,
  COALESCE(SUM(t.time_estimate), 0) AS total_estimate_min,
  COALESCE(SUM(t.time_estimate) FILTER (WHERE t.status = 'concluida'), 0) AS done_estimate_min
FROM god_lists l
LEFT JOIN god_tasks t ON t.sprint_id = l.id
WHERE l.tipo = 'sprint'
GROUP BY l.id, l.nome, l.sprint_inicio, l.sprint_fim, l.sprint_status, l.space_id;

-- 3. Sprint daily snapshot for burndown chart
-- Stores a daily snapshot of remaining points/tasks per sprint
CREATE TABLE IF NOT EXISTS god_sprint_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sprint_id VARCHAR(50) NOT NULL REFERENCES god_lists(id) ON DELETE CASCADE,
  snapshot_date DATE NOT NULL,
  remaining_points INTEGER NOT NULL DEFAULT 0,
  remaining_tasks INTEGER NOT NULL DEFAULT 0,
  total_points INTEGER NOT NULL DEFAULT 0,
  total_tasks INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(sprint_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS idx_sprint_snapshots_sprint ON god_sprint_snapshots(sprint_id);
CREATE INDEX IF NOT EXISTS idx_sprint_snapshots_date ON god_sprint_snapshots(snapshot_date);

ALTER TABLE god_sprint_snapshots ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "sprint_snapshots_all" ON god_sprint_snapshots;
CREATE POLICY "sprint_snapshots_all" ON god_sprint_snapshots FOR ALL USING (true) WITH CHECK (true);

-- 4. Function to take a daily snapshot (called from backend cron or manually)
CREATE OR REPLACE FUNCTION fn_sprint_snapshot(p_sprint_id VARCHAR)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
  v_remaining_points INTEGER;
  v_remaining_tasks INTEGER;
  v_total_points INTEGER;
  v_total_tasks INTEGER;
BEGIN
  SELECT
    COALESCE(SUM(points) FILTER (WHERE status != 'concluida'), 0),
    COUNT(*) FILTER (WHERE status != 'concluida'),
    COALESCE(SUM(points), 0),
    COUNT(*)
  INTO v_remaining_points, v_remaining_tasks, v_total_points, v_total_tasks
  FROM god_tasks
  WHERE sprint_id = p_sprint_id;

  INSERT INTO god_sprint_snapshots (sprint_id, snapshot_date, remaining_points, remaining_tasks, total_points, total_tasks)
  VALUES (p_sprint_id, CURRENT_DATE, v_remaining_points, v_remaining_tasks, v_total_points, v_total_tasks)
  ON CONFLICT (sprint_id, snapshot_date) DO UPDATE SET
    remaining_points = EXCLUDED.remaining_points,
    remaining_tasks = EXCLUDED.remaining_tasks,
    total_points = EXCLUDED.total_points,
    total_tasks = EXCLUDED.total_tasks;
END;
$$;

GRANT EXECUTE ON FUNCTION fn_sprint_snapshot(VARCHAR) TO authenticated;
GRANT EXECUTE ON FUNCTION fn_sprint_snapshot(VARCHAR) TO anon;

NOTIFY pgrst, 'reload schema';
