-- Migration: F2.4 Tarefas Recorrentes — STORY-3.2
-- Adds recurrence columns to god_tasks

ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS recorrencia TEXT DEFAULT 'nenhuma'
  CHECK (recorrencia IN ('nenhuma', 'diario', 'semanal', 'mensal', 'quinzenal'));

ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS dia_recorrencia INT;
  -- For semanal: 0=sunday, 1=monday ... 6=saturday
  -- For mensal: 1-31 (day of month)
  -- For quinzenal: 0-6 (day of week, repeats every 14 days)

ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS recorrencia_ativa BOOLEAN DEFAULT true;

ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS recorrencia_origem_id UUID REFERENCES god_tasks(id) ON DELETE SET NULL;
  -- References the original task that spawned this instance

-- Index for fast lookup of recurring tasks
CREATE INDEX IF NOT EXISTS idx_god_tasks_recorrencia ON god_tasks(recorrencia) WHERE recorrencia != 'nenhuma';
