-- ============================================================
-- TASK-09: Log de notificações de tarefa
-- Date: 2026-03-30
-- ============================================================

CREATE TABLE IF NOT EXISTS god_task_notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  task_id UUID REFERENCES god_tasks(id) ON DELETE CASCADE,
  destinatario TEXT NOT NULL,
  canal TEXT DEFAULT 'whatsapp' CHECK (canal IN ('whatsapp', 'whatsapp_mentorado', 'email', 'push')),
  enviado_em TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_god_task_notifications_task ON god_task_notifications(task_id);

ALTER TABLE god_task_notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "god_task_notifications: acesso autenticados" ON god_task_notifications FOR ALL TO authenticated USING (true) WITH CHECK (true);
