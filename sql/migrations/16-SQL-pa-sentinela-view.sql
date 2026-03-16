-- Sentinela PA: Enhanced vw_pa_pipeline with blocked/overdue/origin counts
-- Run this in Supabase SQL Editor to upgrade the view
-- DROP is needed because column names changed (CREATE OR REPLACE can't rename columns)

DROP VIEW IF EXISTS vw_pa_pipeline;

CREATE VIEW vw_pa_pipeline AS
SELECT
  p.id AS plano_id,
  p.mentorado_id,
  m.nome AS mentorado_nome,
  p.titulo,
  p.formato,
  p.google_doc_url,
  p.status_geral,
  p.notas,
  p.created_at,
  p.updated_at,
  COALESCE(f_agg.total_fases, 0) AS total_fases,
  COALESCE(a_agg.total_acoes, 0) AS total_acoes,
  COALESCE(a_agg.acoes_concluidas, 0) AS acoes_concluidas,
  CASE WHEN COALESCE(a_agg.total_acoes, 0) > 0
    THEN ROUND((COALESCE(a_agg.acoes_concluidas, 0)::numeric / a_agg.total_acoes) * 100)
    ELSE 0
  END AS pct_concluido,
  f_agg.fase_atual,
  EXTRACT(DAY FROM now() - GREATEST(
    p.updated_at,
    COALESCE(a_agg.last_acao_update, p.updated_at)
  ))::int AS dias_sem_update,
  -- New sentinel fields
  COALESCE(a_agg.acoes_bloqueadas, 0) AS acoes_bloqueadas,
  COALESCE(a_agg.acoes_vencidas, 0) AS acoes_vencidas,
  COALESCE(a_agg.acoes_dossie, 0) AS acoes_dossie,
  COALESCE(a_agg.acoes_call, 0) AS acoes_call,
  COALESCE(a_agg.acoes_manual, 0) AS acoes_manual
FROM pa_planos p
JOIN "case".mentorados m ON m.id = p.mentorado_id
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) AS total_fases,
    (SELECT f2.titulo FROM pa_fases f2
     WHERE f2.plano_id = p.id AND f2.status IN ('nao_iniciado','em_andamento')
     ORDER BY f2.ordem LIMIT 1) AS fase_atual
  FROM pa_fases f WHERE f.plano_id = p.id
) f_agg ON true
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) AS total_acoes,
    COUNT(*) FILTER (WHERE a.status = 'concluido') AS acoes_concluidas,
    COUNT(*) FILTER (WHERE a.status = 'bloqueado') AS acoes_bloqueadas,
    COUNT(*) FILTER (WHERE a.data_prevista < CURRENT_DATE AND a.status NOT IN ('concluido','nao_aplicavel')) AS acoes_vencidas,
    COUNT(*) FILTER (WHERE a.origem = 'dossie_auto') AS acoes_dossie,
    COUNT(*) FILTER (WHERE a.origem = 'call_plano') AS acoes_call,
    COUNT(*) FILTER (WHERE COALESCE(a.origem, 'manual') = 'manual') AS acoes_manual,
    MAX(a.updated_at) AS last_acao_update
  FROM pa_acoes a WHERE a.plano_id = p.id
) a_agg ON true;
