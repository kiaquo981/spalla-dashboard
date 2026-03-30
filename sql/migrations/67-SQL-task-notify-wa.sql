-- ============================================================
-- TASK-03: Notificação WhatsApp ao criar tarefa
-- Adiciona campo whatsapp_jid em spalla_members
-- Date: 2026-03-30
-- ============================================================

-- 1. Add WhatsApp JID field to spalla_members
ALTER TABLE spalla_members
ADD COLUMN IF NOT EXISTS whatsapp_jid VARCHAR(50) NULL;

COMMENT ON COLUMN spalla_members.whatsapp_jid IS
  'JID do WhatsApp (formato: 5511999999999@s.whatsapp.net). Usado para notificações automáticas de tarefas.';

-- 2. Populate known JIDs (update with real numbers)
-- UPDATE spalla_members SET whatsapp_jid = '55XXXXXXXXXXX@s.whatsapp.net' WHERE id = 'kaique';
-- UPDATE spalla_members SET whatsapp_jid = '55XXXXXXXXXXX@s.whatsapp.net' WHERE id = 'heitor';
-- etc.
