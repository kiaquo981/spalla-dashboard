-- ============================================================
-- TASK-01: Tipos de tarefa estruturados
-- Adiciona campo `tipo` em god_tasks para classificação
-- Date: 2026-03-30
-- ============================================================

-- 1. Add tipo column with CHECK constraint
ALTER TABLE god_tasks
ADD COLUMN IF NOT EXISTS tipo TEXT DEFAULT 'geral'
CHECK (tipo IN ('geral', 'dossie', 'ajuste_dossie', 'follow_up', 'rotina', 'bug_report'));

-- 2. Index for filtering by tipo
CREATE INDEX IF NOT EXISTS idx_god_tasks_tipo ON god_tasks(tipo);

-- 3. Migrate existing tasks: infer tipo from tags where possible
UPDATE god_tasks SET tipo = 'dossie'
WHERE tipo = 'geral'
  AND (tags @> ARRAY['dossie'] OR tags @> ARRAY['dossiê'] OR tags @> ARRAY['producao']);

UPDATE god_tasks SET tipo = 'ajuste_dossie'
WHERE tipo = 'geral'
  AND (tags @> ARRAY['ajuste'] OR tags @> ARRAY['ajuste-dossie'] OR tags @> ARRAY['revisao']);

UPDATE god_tasks SET tipo = 'follow_up'
WHERE tipo = 'geral'
  AND (tags @> ARRAY['follow-up'] OR tags @> ARRAY['followup'] OR tags @> ARRAY['cobrar']);

UPDATE god_tasks SET tipo = 'rotina'
WHERE tipo = 'geral'
  AND (tags @> ARRAY['rotina'] OR tags @> ARRAY['recorrente'] OR tags @> ARRAY['semanal']);
