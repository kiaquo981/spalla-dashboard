-- ============================================================
-- Spalla Dashboard — Tags System Seed
-- Story: T-01-02 | 2026-03-11
-- Run AFTER 28-SQL-tags-schema.sql
-- ============================================================

INSERT INTO god_task_tags (name, color, scope, is_system)
VALUES
  -- Operacionais / Urgência
  ('Urgente',           '#ef4444', 'global', true),
  ('Bloqueado',         '#dc2626', 'global', true),
  ('Aguardando',        '#94a3b8', 'global', true),
  ('Follow-up',         '#f97316', 'global', true),

  -- Contexto de trabalho
  ('Cliente',           '#6366f1', 'global', true),
  ('Revisão',           '#f59e0b', 'global', true),
  ('Conteúdo',          '#8b5cf6', 'global', true),
  ('Financeiro',        '#10b981', 'global', true),
  ('Jurídico',          '#0ea5e9', 'global', true),
  ('Onboarding',        '#06b6d4', 'global', true)

ON CONFLICT (name) DO NOTHING;
