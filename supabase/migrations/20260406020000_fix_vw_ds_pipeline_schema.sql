-- =============================================================================
-- HOTFIX: Recreate vw_ds_pipeline in public schema
-- The migration 20260406010000 created it in "case" schema due to SET search_path
-- =============================================================================

-- Drop the misplaced view in case schema
DROP VIEW IF EXISTS "case".vw_ds_pipeline;

-- Recreate in public schema (where the frontend expects it)
DROP VIEW IF EXISTS public.vw_ds_pipeline;
CREATE VIEW public.vw_ds_pipeline AS
SELECT
  p.id AS producao_id,
  p.mentorado_id,
  m.nome AS mentorado_nome,
  m.trilha,
  m.consultor_responsavel AS carteira,
  p.status,
  p.responsavel_atual,
  p.data_call_estrategia,
  p.data_call_apresentacao,
  p.data_call_onboarding,
  p.contrato_assinado,
  p.notas,
  p.created_at,
  p.updated_at,

  -- Per-doc stages (SCALE)
  MAX(CASE WHEN d.tipo = 'oferta' THEN d.estagio_atual END) AS oferta_estagio,
  MAX(CASE WHEN d.tipo = 'funil' THEN d.estagio_atual END) AS funil_estagio,
  MAX(CASE WHEN d.tipo = 'conteudo' THEN d.estagio_atual END) AS conteudo_estagio,

  -- CLINIC unified doc
  MAX(CASE WHEN d.tipo = 'clinic' THEN d.estagio_atual END) AS clinic_estagio,

  -- Per-doc responsaveis
  MAX(CASE WHEN d.tipo = 'oferta' THEN d.responsavel_atual END) AS oferta_responsavel,
  MAX(CASE WHEN d.tipo = 'funil' THEN d.responsavel_atual END) AS funil_responsavel,
  MAX(CASE WHEN d.tipo = 'conteudo' THEN d.responsavel_atual END) AS conteudo_responsavel,
  MAX(CASE WHEN d.tipo = 'clinic' THEN d.responsavel_atual END) AS clinic_responsavel,

  -- Per-doc prazos
  MAX(CASE WHEN d.tipo = 'oferta' THEN d.prazo_entrega END) AS oferta_prazo,
  MAX(CASE WHEN d.tipo = 'funil' THEN d.prazo_entrega END) AS funil_prazo,
  MAX(CASE WHEN d.tipo = 'conteudo' THEN d.prazo_entrega END) AS conteudo_prazo,
  MAX(CASE WHEN d.tipo = 'clinic' THEN d.prazo_entrega END) AS clinic_prazo,

  -- Counts
  COUNT(d.id) FILTER (WHERE d.estagio_atual = 'finalizado') AS docs_finalizados,
  COUNT(d.id) AS total_docs,

  -- Most behind doc (for bottleneck)
  MIN(CASE d.estagio_atual
    WHEN 'pendente' THEN 1 WHEN 'producao_ia' THEN 2
    WHEN 'revisao_mariza' THEN 3 WHEN 'revisao_kaique' THEN 4
    WHEN 'revisao_queila' THEN 5 WHEN 'revisao_gobbi' THEN 5
    WHEN 'revisao_paralela' THEN 5 WHEN 'enviado' THEN 6
    WHEN 'feedback_mentorado' THEN 7
    WHEN 'ajustes' THEN 8 WHEN 'aprovado' THEN 9
    WHEN 'finalizado' THEN 10
  END) AS estagio_min_num,

  -- Aging (oldest doc in current stage)
  MAX(EXTRACT(DAY FROM now() - d.estagio_desde))::INT AS dias_no_estagio,

  -- Pending adjustments
  (SELECT COUNT(*) FROM ds_ajustes a WHERE a.producao_id = p.id AND a.status != 'concluido') AS ajustes_pendentes,

  -- Prazo entrega (from producao)
  p.prazo_entrega

FROM ds_producoes p
JOIN "case".mentorados m ON m.id = p.mentorado_id
LEFT JOIN ds_documentos d ON d.producao_id = p.id
GROUP BY p.id, m.nome, m.id, m.trilha, m.consultor_responsavel;

GRANT SELECT ON public.vw_ds_pipeline TO authenticated, anon;
