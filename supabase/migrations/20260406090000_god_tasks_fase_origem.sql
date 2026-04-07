-- Add fase_origem to god_tasks for phase-based task generation
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS fase_origem TEXT;
CREATE INDEX IF NOT EXISTS idx_god_tasks_fase_origem ON god_tasks(fase_origem);
NOTIFY pgrst, 'reload schema';
