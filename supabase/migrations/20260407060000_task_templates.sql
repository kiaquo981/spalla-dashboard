-- Task Templates
CREATE TABLE IF NOT EXISTS god_task_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  template_data JSONB NOT NULL DEFAULT '{}',
  -- template_data: { titulo_prefix, descricao, prioridade, tipo, tags, subtasks[], checklist[], space_id, list_id }
  space_id VARCHAR(50) REFERENCES god_spaces(id),
  is_global BOOLEAN DEFAULT false,
  usage_count INTEGER DEFAULT 0,
  created_by TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE god_task_templates ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "templates_all" ON god_task_templates;
CREATE POLICY "templates_all" ON god_task_templates FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- Seed common templates
INSERT INTO god_task_templates (name, description, is_global, template_data) VALUES
  ('Dossie', 'Template para dossiê de mentorado', true, '{"titulo_prefix": "Dossiê: ", "tipo": "dossie", "prioridade": "alta", "subtasks": [{"text":"Briefing com mentorado"},{"text":"Rascunho v1"},{"text":"Revisão consultor"},{"text":"Revisão Queila"},{"text":"Entrega final"}]}'),
  ('Follow-up', 'Follow-up pos-call', true, '{"titulo_prefix": "Follow-up: ", "tipo": "follow_up", "prioridade": "normal"}'),
  ('Bug Report', 'Reporte de bug no sistema', true, '{"titulo_prefix": "[BUG] ", "tipo": "bug_report", "prioridade": "urgente"}'),
  ('Processo', 'Processo operacional', true, '{"titulo_prefix": "PROCESSO: ", "tipo": "geral", "prioridade": "alta"}'),
  ('Rotina Semanal', 'Tarefa rotineira semanal', true, '{"titulo_prefix": "", "tipo": "rotina", "prioridade": "normal", "recorrencia": "semanal"}')
ON CONFLICT DO NOTHING;

NOTIFY pgrst, 'reload schema';
