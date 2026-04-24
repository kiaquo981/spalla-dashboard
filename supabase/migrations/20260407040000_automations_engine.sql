-- ============================================================
-- AUTOMATIONS ENGINE — trigger/condition/action rules
-- Phase 5: ClickUp Internalization
-- Date: 2026-04-07
-- ============================================================

CREATE TABLE IF NOT EXISTS god_automations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,

  -- Trigger: what event starts this automation
  trigger_type TEXT NOT NULL CHECK (trigger_type IN (
    'status_changed', 'assignee_changed', 'priority_changed',
    'task_created', 'due_date_arrived', 'custom_field_changed'
  )),
  trigger_config JSONB DEFAULT '{}', -- e.g. { "from": "pendente", "to": "em_andamento" }

  -- Condition: optional filter
  condition_config JSONB DEFAULT '{}', -- e.g. { "space_id": "space_gestao", "priority": "urgente" }

  -- Action: what to do
  action_type TEXT NOT NULL CHECK (action_type IN (
    'change_status', 'change_assignee', 'change_priority',
    'add_tag', 'remove_tag', 'send_notification',
    'create_task', 'move_to_list', 'set_custom_field'
  )),
  action_config JSONB DEFAULT '{}', -- e.g. { "status": "concluida" } or { "assignee": "kaique" }

  -- Metadata
  space_id VARCHAR(50) REFERENCES god_spaces(id),
  created_by TEXT,
  execution_count INTEGER DEFAULT 0,
  last_executed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_automations_trigger ON god_automations(trigger_type) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_automations_space ON god_automations(space_id);

ALTER TABLE god_automations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "automations_all" ON god_automations;
CREATE POLICY "automations_all" ON god_automations FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- Execution log
CREATE TABLE IF NOT EXISTS god_automation_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  automation_id UUID NOT NULL REFERENCES god_automations(id) ON DELETE CASCADE,
  task_id UUID REFERENCES god_tasks(id) ON DELETE SET NULL,
  trigger_data JSONB,
  action_result JSONB,
  success BOOLEAN DEFAULT true,
  error_message TEXT,
  executed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_automation_log_auto ON god_automation_log(automation_id);
CREATE INDEX IF NOT EXISTS idx_automation_log_date ON god_automation_log(executed_at DESC);

ALTER TABLE god_automation_log ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "automation_log_all" ON god_automation_log;
CREATE POLICY "automation_log_all" ON god_automation_log FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

NOTIFY pgrst, 'reload schema';
