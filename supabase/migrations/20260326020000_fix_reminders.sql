-- Fix god_reminders: add missing columns that frontend expects
ALTER TABLE god_reminders ADD COLUMN IF NOT EXISTS prioridade TEXT DEFAULT 'normal';
ALTER TABLE god_reminders ADD COLUMN IF NOT EXISTS mentorado_nome TEXT;
ALTER TABLE god_reminders ADD COLUMN IF NOT EXISTS mentorado_id BIGINT;
ALTER TABLE god_reminders ADD COLUMN IF NOT EXISTS data_lembrete TIMESTAMPTZ;
