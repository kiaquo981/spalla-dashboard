-- ================================================================
-- Migration: prazo_entrega em ds_documentos + rebuild vw_ds_pipeline
-- Data: 2026-03-24
-- Contexto:
--   Prazo de entrega individual por dossiê (oferta, funil, conteúdo)
--   além do prazo global que já existe em ds_producoes.
-- ================================================================

ALTER TABLE ds_documentos
  ADD COLUMN IF NOT EXISTS prazo_entrega DATE DEFAULT NULL;

COMMENT ON COLUMN ds_documentos.prazo_entrega IS
  'Data limite para entrega deste dossiê específico. NULL = sem prazo individual.';

-- Rebuild view para expor os prazos por doc
DROP VIEW IF EXISTS vw_ds_pipeline;
CREATE VIEW vw_ds_pipeline AS
SELECT
  p.id AS producao_id,
  p.mentorado_id,
  m.nome AS mentorado_nome,
  p.status,
  p.responsavel_atual,
  p.data_call_estrategia,
  p.data_call_apresentacao,
  p.data_call_onboarding,
  p.contrato_assinado,
  p.prazo_entrega,
  p.notas,
  p.created_at,
  p.updated_at,

  -- Per-doc stages
  MAX(CASE WHEN d.tipo = 'oferta' THEN d.estagio_atual END) AS oferta_estagio,
  MAX(CASE WHEN d.tipo = 'funil' THEN d.estagio_atual END) AS funil_estagio,
  MAX(CASE WHEN d.tipo = 'conteudo' THEN d.estagio_atual END) AS conteudo_estagio,

  -- Per-doc responsaveis
  MAX(CASE WHEN d.tipo = 'oferta' THEN d.responsavel_atual END) AS oferta_responsavel,
  MAX(CASE WHEN d.tipo = 'funil' THEN d.responsavel_atual END) AS funil_responsavel,
  MAX(CASE WHEN d.tipo = 'conteudo' THEN d.responsavel_atual END) AS conteudo_responsavel,

  -- Per-doc prazos
  MAX(CASE WHEN d.tipo = 'oferta' THEN d.prazo_entrega END) AS oferta_prazo,
  MAX(CASE WHEN d.tipo = 'funil' THEN d.prazo_entrega END) AS funil_prazo,
  MAX(CASE WHEN d.tipo = 'conteudo' THEN d.prazo_entrega END) AS conteudo_prazo,

  -- Counts
  COUNT(d.id) FILTER (WHERE d.estagio_atual = 'finalizado') AS docs_finalizados,
  COUNT(d.id) AS total_docs,

  -- Most behind doc (for bottleneck)
  MIN(CASE d.estagio_atual
    WHEN 'pendente' THEN 1 WHEN 'producao_ia' THEN 2
    WHEN 'revisao_mariza' THEN 3 WHEN 'revisao_kaique' THEN 4
    WHEN 'revisao_queila' THEN 5 WHEN 'aprovado' THEN 6
    WHEN 'enviado' THEN 7 WHEN 'feedback_mentorado' THEN 8
    WHEN 'ajustes' THEN 9 WHEN 'finalizado' THEN 10
  END) AS estagio_min_num,

  -- Aging (oldest doc in current stage)
  MAX(EXTRACT(DAY FROM now() - d.estagio_desde))::INT AS dias_no_estagio,

  -- Pending adjustments
  (SELECT COUNT(*) FROM ds_ajustes a WHERE a.producao_id = p.id AND a.status != 'concluido') AS ajustes_pendentes

FROM ds_producoes p
JOIN "case".mentorados m ON m.id = p.mentorado_id
LEFT JOIN ds_documentos d ON d.producao_id = p.id
GROUP BY p.id, m.nome, m.id;
