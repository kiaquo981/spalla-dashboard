-- ============================================================
-- Operon Dashboard — Unified Activity Feed View
-- 2026-03-12
-- ============================================================
-- OBJETIVO:
-- Criar vw_activity_feed unificando calls + tasks + PA + OB + DS + WA topics
-- Substitui vw_god_timeline no frontend
-- ============================================================

CREATE OR REPLACE VIEW vw_activity_feed AS

-- 1. Calls
SELECT
  'call'::TEXT                        AS tipo,
  c.id::TEXT                          AS item_id,
  c.mentorado_id,
  m.nome                              AS mentorado_nome,
  c.data_call                         AS ts,
  c.tipo_call                         AS subtipo,
  c.resumo_executivo                  AS conteudo,
  c.sentimento_geral                  AS sentimento,
  NULL::TEXT                          AS status,
  NULL::TEXT                          AS responsavel,
  c.pa_plano_id::TEXT                 AS ref_pa,
  c.ds_producao_id::TEXT              AS ref_ds,
  c.ob_trilha_id::TEXT                AS ref_ob
FROM calls_mentoria c
JOIN "case".mentorados m ON m.id = c.mentorado_id

UNION ALL

-- 2. God Tasks (relevantes — pendentes e recentes)
SELECT
  'task'::TEXT,
  t.id::TEXT,
  t.mentorado_id,
  t.mentorado_nome,
  COALESCE(t.updated_at, t.created_at),
  t.list_id,
  t.titulo,
  NULL,
  t.status,
  t.responsavel,
  t.pa_acao_id::TEXT,
  NULL,
  t.ob_tarefa_id::TEXT
FROM god_tasks t
WHERE t.status IN ('pendente', 'em_andamento')
   OR t.updated_at >= now() - interval '30 days'

UNION ALL

-- 3. PA Ações (recentes)
SELECT
  'pa_acao'::TEXT,
  a.id::TEXT,
  p.mentorado_id,
  m.nome,
  COALESCE(a.updated_at, a.created_at),
  a.tipo_acao,
  a.descricao,
  NULL,
  a.status,
  a.responsavel,
  a.id::TEXT,
  NULL,
  NULL
FROM pa_acoes a
JOIN pa_fases f ON f.id = a.fase_id
JOIN pa_planos p ON p.id = f.plano_id
JOIN "case".mentorados m ON m.id = p.mentorado_id
WHERE a.updated_at >= now() - interval '30 days'
   OR a.status IN ('pendente', 'em_andamento', 'bloqueado')

UNION ALL

-- 4. WA Topics (recentes)
SELECT
  'wa_topic'::TEXT,
  w.id::TEXT,
  w.mentorado_id,
  m.nome,
  w.created_at,
  w.tipo,
  w.conteudo,
  w.sentimento,
  w.status,
  NULL,
  NULL,
  NULL,
  NULL
FROM wa_topics w
JOIN "case".mentorados m ON m.id = w.mentorado_id
WHERE w.created_at >= now() - interval '30 days'

UNION ALL

-- 5. DS Documentos (mudanças de estágio recentes)
SELECT
  'ds_doc'::TEXT,
  d.id::TEXT,
  d.mentorado_id,
  m.nome,
  COALESCE(d.updated_at, d.created_at),
  d.tipo_documento,
  'Estágio: ' || d.estagio,
  NULL,
  d.estagio,
  d.responsavel,
  NULL,
  d.id::TEXT,
  NULL
FROM ds_documentos d
JOIN "case".mentorados m ON m.id = d.mentorado_id
WHERE d.updated_at >= now() - interval '30 days'

ORDER BY ts DESC;

COMMENT ON VIEW vw_activity_feed IS 'Unified activity feed: calls, tasks, PA, WA topics, DS docs. Replaces vw_god_timeline.';

GRANT SELECT ON vw_activity_feed TO anon, authenticated, service_role;
