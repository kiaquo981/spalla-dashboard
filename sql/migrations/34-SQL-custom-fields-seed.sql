-- ============================================================
-- Spalla Dashboard — Custom Fields Seed
-- Story: T-02-02 | 2026-03-11
-- Run AFTER 30-SQL-custom-fields-schema.sql
-- ============================================================

-- ============================================================
-- GLOBAL FIELDS — Appear on all tasks regardless of space
-- ============================================================
INSERT INTO god_task_field_defs (name, field_type, scope, options, config, sort_order, is_system)
VALUES

  -- Tipo de Ação (select)
  (
    'Tipo de Ação',
    'select',
    'global',
    '[
      {"id": "call",      "label": "Call",      "color": "#6366f1"},
      {"id": "tarefa",    "label": "Tarefa",    "color": "#3b82f6"},
      {"id": "revisao",   "label": "Revisão",   "color": "#f59e0b"},
      {"id": "entrega",   "label": "Entrega",   "color": "#10b981"},
      {"id": "pesquisa",  "label": "Pesquisa",  "color": "#8b5cf6"}
    ]'::jsonb,
    '{"placeholder": "Selecione o tipo"}'::jsonb,
    10,
    true
  ),

  -- Complexidade (rating 1–5)
  (
    'Complexidade',
    'rating',
    'global',
    NULL,
    '{"max": 5}'::jsonb,
    20,
    true
  ),

  -- Esforço Estimado (number em horas)
  (
    'Esforço Estimado',
    'number',
    'global',
    NULL,
    '{"unit": "horas", "min": 0, "max": 999, "placeholder": "0"}'::jsonb,
    30,
    true
  ),

  -- Canal (select)
  (
    'Canal',
    'select',
    'global',
    '[
      {"id": "whatsapp",   "label": "WhatsApp",   "color": "#25d366"},
      {"id": "email",      "label": "E-mail",     "color": "#6366f1"},
      {"id": "presencial", "label": "Presencial", "color": "#f59e0b"},
      {"id": "online",     "label": "Online",     "color": "#3b82f6"},
      {"id": "documento",  "label": "Documento",  "color": "#94a3b8"}
    ]'::jsonb,
    '{"placeholder": "Selecione o canal"}'::jsonb,
    40,
    true
  )

ON CONFLICT DO NOTHING;


-- ============================================================
-- SPACE: Jornada Mentorados
-- ============================================================
INSERT INTO god_task_field_defs (name, field_type, scope, options, config, sort_order, is_system)
VALUES

  -- Fase do Mentorado (select)
  (
    'Fase Mentorado',
    'select',
    'space:space_jornada',
    '[
      {"id": "diagnostico", "label": "Diagnóstico", "color": "#8b5cf6"},
      {"id": "estrategia",  "label": "Estratégia",  "color": "#3b82f6"},
      {"id": "execucao",    "label": "Execução",    "color": "#f97316"},
      {"id": "consolidacao","label": "Consolidação","color": "#10b981"}
    ]'::jsonb,
    '{"placeholder": "Fase atual"}'::jsonb,
    10,
    true
  ),

  -- ROI Esperado (select)
  (
    'ROI Esperado',
    'select',
    'space:space_jornada',
    '[
      {"id": "alto",  "label": "Alto",  "color": "#10b981"},
      {"id": "medio", "label": "Médio", "color": "#f59e0b"},
      {"id": "baixo", "label": "Baixo", "color": "#94a3b8"}
    ]'::jsonb,
    '{}'::jsonb,
    20,
    true
  ),

  -- Validado pelo Mentorado (checkbox)
  (
    'Validado pelo Mentorado',
    'checkbox',
    'space:space_jornada',
    NULL,
    '{}'::jsonb,
    30,
    true
  ),

  -- Link de Evidência (url)
  (
    'Link de Evidência',
    'url',
    'space:space_jornada',
    NULL,
    '{"placeholder": "https://"}'::jsonb,
    40,
    true
  )

ON CONFLICT DO NOTHING;


-- ============================================================
-- SPACE: Gestão CASE
-- ============================================================
INSERT INTO god_task_field_defs (name, field_type, scope, options, config, sort_order, is_system)
VALUES

  -- Departamento (select)
  (
    'Departamento',
    'select',
    'space:space_gestao',
    '[
      {"id": "marketing",  "label": "Marketing",   "color": "#8b5cf6"},
      {"id": "vendas",     "label": "Vendas",      "color": "#10b981"},
      {"id": "operacoes",  "label": "Operações",   "color": "#f59e0b"},
      {"id": "produto",    "label": "Produto",     "color": "#6366f1"},
      {"id": "conteudo",   "label": "Conteúdo",    "color": "#f97316"},
      {"id": "financeiro", "label": "Financeiro",  "color": "#0ea5e9"},
      {"id": "juridico",   "label": "Jurídico",    "color": "#dc2626"}
    ]'::jsonb,
    '{"placeholder": "Departamento responsável"}'::jsonb,
    10,
    true
  ),

  -- Aprovação Queila (checkbox)
  (
    'Aprovação Queila',
    'checkbox',
    'space:space_gestao',
    NULL,
    '{}'::jsonb,
    20,
    true
  ),

  -- Prazo Interno (date extra além do data_fim)
  (
    'Prazo de Entrega Interno',
    'date',
    'space:space_gestao',
    NULL,
    '{"placeholder": "Data de entrega interna"}'::jsonb,
    30,
    true
  )

ON CONFLICT DO NOTHING;
