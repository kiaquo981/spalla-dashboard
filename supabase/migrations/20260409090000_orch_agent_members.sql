-- ORCH-02: Agent Members in spalla_members
-- Adds tipo (human/agent/bot), max_concurrent_tasks, execution_endpoint
-- Seeds 3 AI agent members

ALTER TABLE spalla_members
  ADD COLUMN IF NOT EXISTS tipo TEXT NOT NULL DEFAULT 'human'
    CHECK (tipo IN ('human', 'agent', 'bot'));

ALTER TABLE spalla_members
  ADD COLUMN IF NOT EXISTS max_concurrent_tasks INT DEFAULT NULL;

ALTER TABLE spalla_members
  ADD COLUMN IF NOT EXISTS execution_endpoint TEXT DEFAULT NULL;

-- Seed agent members
INSERT INTO spalla_members (id, nome_completo, nome_curto, cargo, cor, tipo, max_concurrent_tasks, execution_endpoint, ativo)
VALUES
  ('agent_maestro',    'Maestro',    'Maestro',    'Orquestrador WA',  '#f59e0b', 'agent', 5, 'n8n_webhook:maestro',    true),
  ('agent_descarrego', 'Descarrego', 'Descarrego', 'Classificador IA', '#10b981', 'agent', 3, 'descarrego_pipeline',    true),
  ('agent_review',     'Review',     'Review',     'Revisor Dossiê',   '#8b5cf6', 'agent', 2, 'claude_api:review',      true)
ON CONFLICT (id) DO NOTHING;
