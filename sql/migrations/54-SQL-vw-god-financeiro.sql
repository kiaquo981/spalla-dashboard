-- ============================================================
-- Migration 54: View vw_god_financeiro
-- Story: STORY-5.0 — CFO Payments View
-- Date: 2026-03-16
-- ============================================================

DROP VIEW IF EXISTS vw_god_financeiro CASCADE;

CREATE OR REPLACE VIEW vw_god_financeiro AS
SELECT
  m.id,
  m.nome,
  m.instagram,
  m.fase_jornada,
  m.cohort,
  COALESCE(m.status_financeiro, 'em_dia') AS status_financeiro,
  COALESCE(m.contrato_assinado, true) AS contrato_assinado,
  m.dia_pagamento,
  COALESCE(m.faturamento_atual, 0) AS faturamento_atual,
  COALESCE(m.meta_faturamento, 0) AS meta_faturamento,

  -- Calculated: mentee needs action?
  CASE
    WHEN m.status_financeiro = 'atrasado' THEN true
    WHEN m.contrato_assinado = false THEN true
    ELSE false
  END AS acao_pendente,

  -- Last financial log
  fl.ultimo_log_data,
  fl.ultimo_log_obs,
  fl.ultimo_log_by

FROM "case".mentorados m

LEFT JOIN LATERAL (
  SELECT
    created_at AS ultimo_log_data,
    observacao AS ultimo_log_obs,
    changed_by AS ultimo_log_by
  FROM god_financial_logs
  WHERE mentorado_id = m.id
  ORDER BY created_at DESC
  LIMIT 1
) fl ON true

WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'
ORDER BY
  CASE
    WHEN m.status_financeiro = 'atrasado' THEN 1
    WHEN m.contrato_assinado = false THEN 2
    WHEN m.status_financeiro = 'em_dia' THEN 3
    WHEN m.status_financeiro = 'quitado' THEN 4
    ELSE 5
  END,
  m.nome;

GRANT SELECT ON vw_god_financeiro TO authenticated;
