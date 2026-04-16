-- ORCH-03: Gate Tasks (Checkpoint Pattern)
-- Adds 'gate' to especie CHECK constraint
-- Adds gate_config JSONB for approvers/criteria

-- 1. Expand especie CHECK to include 'gate'
ALTER TABLE god_tasks DROP CONSTRAINT IF EXISTS god_tasks_especie_check;
ALTER TABLE god_tasks ADD CONSTRAINT god_tasks_especie_check
  CHECK (especie IN (
    'one_time',
    'quest',
    'recorrente_template',
    'recorrente_instancia',
    'triggered_template',
    'triggered_instancia',
    'gate'
  ));

-- 2. Gate config (approvers, min_approvals, criteria)
ALTER TABLE god_tasks
  ADD COLUMN IF NOT EXISTS gate_config JSONB DEFAULT NULL;

COMMENT ON COLUMN god_tasks.gate_config IS
  'Config do gate: {"approvers": ["kaique"], "min_approvals": 1, "criteria": "Dossiê revisado"}';
