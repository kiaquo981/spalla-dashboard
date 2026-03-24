-- ================================================================
-- Migration: split data_call_apresentacao em oferta vs pos+funil
-- Data: 2026-03-24
-- Contexto:
--   Existem 2 calls de apresentação:
--   1) Oferta (após 3 semanas da call Queila)
--   2) Posicionamento + Funil (1 semana após aprovação da oferta)
--   Mantém coluna antiga para backwards compat, copia valor para _oferta.
-- ================================================================

-- Novas colunas
ALTER TABLE ds_producoes
  ADD COLUMN IF NOT EXISTS data_call_apresentacao_oferta DATE DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS data_call_apresentacao_pos_funil DATE DEFAULT NULL;

COMMENT ON COLUMN ds_producoes.data_call_apresentacao_oferta IS
  'Data da call de apresentação do dossiê de oferta ao mentorado.';
COMMENT ON COLUMN ds_producoes.data_call_apresentacao_pos_funil IS
  'Data da call de apresentação dos dossiês de posicionamento e funil ao mentorado.';

-- Migrar dados existentes: valor antigo vai pra _oferta
UPDATE ds_producoes
  SET data_call_apresentacao_oferta = data_call_apresentacao
  WHERE data_call_apresentacao IS NOT NULL
    AND data_call_apresentacao_oferta IS NULL;

-- Rebuild view com nova ordem de estágios e novas colunas
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
  p.data_call_apresentacao_oferta,
  p.data_call_apresentacao_pos_funil,
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

  -- Most behind doc (new order: enviado=6, feedback=7, ajustes=8, aprovado=9, finalizado=10)
  MIN(CASE d.estagio_atual
    WHEN 'pendente' THEN 1 WHEN 'producao_ia' THEN 2
    WHEN 'revisao_mariza' THEN 3 WHEN 'revisao_kaique' THEN 4
    WHEN 'revisao_queila' THEN 5 WHEN 'enviado' THEN 6
    WHEN 'feedback_mentorado' THEN 7 WHEN 'ajustes' THEN 8
    WHEN 'aprovado' THEN 9 WHEN 'finalizado' THEN 10
  END) AS estagio_min_num,

  -- Aging (oldest doc in current stage)
  MAX(EXTRACT(DAY FROM now() - d.estagio_desde))::INT AS dias_no_estagio,

  -- Pending adjustments
  (SELECT COUNT(*) FROM ds_ajustes a WHERE a.producao_id = p.id AND a.status != 'concluido') AS ajustes_pendentes

FROM ds_producoes p
JOIN "case".mentorados m ON m.id = p.mentorado_id
LEFT JOIN ds_documentos d ON d.producao_id = p.id
GROUP BY p.id, m.nome, m.id;
