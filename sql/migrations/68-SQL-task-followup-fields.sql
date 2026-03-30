-- ============================================================
-- TASK-05: Follow-up status vinculado
-- Adiciona campos follow-up em god_tasks
-- Date: 2026-03-30
-- ============================================================

-- 1. Follow-up tracking fields
ALTER TABLE god_tasks
ADD COLUMN IF NOT EXISTS follow_up_group_jid TEXT NULL,
ADD COLUMN IF NOT EXISTS follow_up_responded_at TIMESTAMPTZ NULL;

-- 2. Index for finding pending follow-ups by group
CREATE INDEX IF NOT EXISTS idx_god_tasks_followup_jid
  ON god_tasks(follow_up_group_jid)
  WHERE follow_up_group_jid IS NOT NULL AND status = 'pendente' AND tipo = 'follow_up';
