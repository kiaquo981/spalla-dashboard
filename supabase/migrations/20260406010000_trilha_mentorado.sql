-- =============================================================================
-- MIGRATION: Add trilha (SCALE | CLINIC) to mentorados
-- =============================================================================
-- SCALE: 3 dossiês separados (Oferta, Funil, Posicionamento) — padrão atual
-- CLINIC: 1 dossiê unificado (Oferta, Marketing, Comercial, Consulta)
-- =============================================================================

SET search_path = "case", public;

-- 1. Add trilha column to mentorados (split into steps for safety)
ALTER TABLE "case".mentorados ADD COLUMN IF NOT EXISTS trilha TEXT DEFAULT 'scale';
UPDATE "case".mentorados SET trilha = 'scale' WHERE trilha IS NULL;
ALTER TABLE "case".mentorados ALTER COLUMN trilha SET NOT NULL;
DO $$ BEGIN
  ALTER TABLE "case".mentorados ADD CONSTRAINT mentorados_trilha_check CHECK (trilha IN ('scale', 'clinic'));
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 2. Index for filtering
CREATE INDEX IF NOT EXISTS idx_mentorados_trilha ON "case".mentorados(trilha);

-- 4. Update vw_ds_pipeline to include trilha and clinic doc type
DROP VIEW IF EXISTS vw_ds_pipeline;
CREATE VIEW vw_ds_pipeline AS
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
    WHEN 'revisao_queila' THEN 5 WHEN 'enviado' THEN 6
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

GRANT SELECT ON vw_ds_pipeline TO authenticated, anon;

-- 5. Update vw_god_overview to expose trilha
-- We need to add m.trilha to the SELECT. Simplest: recreate with the extra column.
-- The full view definition lives in migration 62. We just ALTER it here.
CREATE OR REPLACE VIEW vw_god_overview AS
WITH
wa_stats AS (
  SELECT
    i.mentorado_id,
    COUNT(*) FILTER (WHERE i.created_at >= NOW() - INTERVAL '7 days') AS whatsapp_7d,
    COUNT(*) FILTER (WHERE i.created_at >= NOW() - INTERVAL '30 days') AS whatsapp_30d,
    COUNT(*) AS whatsapp_total,
    COUNT(*) FILTER (
      WHERE i.requer_resposta = true AND i.respondido = false
    ) AS msgs_pendentes_resposta,
    MAX(
      CASE
        WHEN i.requer_resposta = true AND i.respondido = false AND i.eh_equipe = false
        THEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600
        ELSE 0
      END
    ) AS horas_sem_resposta_equipe
  FROM interacoes_mentoria i
  WHERE i.mentorado_id IS NOT NULL
  GROUP BY i.mentorado_id
),
call_stats AS (
  SELECT
    cm.mentorado_id,
    MAX(COALESCE(cm.data_call, cm.created_at)) AS ultima_call_data
  FROM calls_mentoria cm
  GROUP BY cm.mentorado_id
),
tarefa_stats AS (
  SELECT
    mentorado_id,
    COUNT(*) FILTER (WHERE LOWER(status) = 'pendente') AS tarefas_pendentes_total,
    COUNT(*) FILTER (
      WHERE LOWER(status) = 'pendente'
        AND prazo IS NOT NULL AND prazo < NOW()
    ) AS tarefas_atrasadas
  FROM (
    SELECT mentorado_id::integer AS mentorado_id, status, prazo
    FROM tarefas_acordadas
    UNION ALL
    SELECT mentorado_id::integer, status::text, prazo::timestamptz
    FROM tarefas_equipe
    WHERE mentorado_id IS NOT NULL
  ) all_tasks
  GROUP BY mentorado_id
)
SELECT
  m.id,
  m.nome,
  m.instagram,
  m.cohort,
  m.trilha,
  m.fase_jornada,
  m.sub_etapa,
  m.marco_atual,
  m.risco_churn,
  m.score_engajamento AS engagement_score,
  m.score_implementacao AS implementation_score,
  m.faturamento_atual,
  m.meta_faturamento,
  CASE
    WHEN m.meta_faturamento > 0 AND m.faturamento_atual > 0
    THEN ROUND((m.faturamento_atual / m.meta_faturamento) * 100, 1)
    ELSE 0
  END AS pct_meta_atingida,
  m.qtd_vendas_total,
  m.ja_vendeu,
  COALESCE(wa.whatsapp_7d, 0)::integer AS whatsapp_7d,
  COALESCE(wa.whatsapp_30d, 0)::integer AS whatsapp_30d,
  COALESCE(wa.whatsapp_total, 0)::integer AS whatsapp_total,
  COALESCE(wa.msgs_pendentes_resposta, 0)::integer AS msgs_pendentes_resposta,
  ROUND(COALESCE(wa.horas_sem_resposta_equipe, 0)::numeric, 1) AS horas_sem_resposta_equipe,
  cs.ultima_call_data,
  CASE
    WHEN cs.ultima_call_data IS NOT NULL
    THEN EXTRACT(DAY FROM (NOW() - cs.ultima_call_data))::integer
    ELSE NULL
  END AS dias_desde_call,
  COALESCE(ts.tarefas_pendentes_total, 0)::integer AS tarefas_pendentes,
  COALESCE(ts.tarefas_atrasadas, 0)::integer AS tarefas_atrasadas,
  COALESCE(m.contrato_assinado, true) AS contrato_assinado,
  COALESCE(m.status_financeiro, 'em_dia') AS status_financeiro,
  m.dia_pagamento,
  m.grupo_whatsapp_id,
  m.consultor_responsavel
FROM "case".mentorados m
LEFT JOIN wa_stats wa ON wa.mentorado_id = m.id
LEFT JOIN call_stats cs ON cs.mentorado_id = m.id
LEFT JOIN tarefa_stats ts ON ts.mentorado_id = m.id
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'
ORDER BY
  CASE m.fase_jornada
    WHEN 'escala' THEN 1
    WHEN 'otimizacao' THEN 2
    WHEN 'validacao' THEN 3
    WHEN 'concepcao' THEN 4
    WHEN 'onboarding' THEN 5
    ELSE 6
  END,
  m.nome;

GRANT SELECT ON vw_god_overview TO authenticated, anon;

-- 6. Add parallel review flags to ds_documentos (CLINIC only)
ALTER TABLE ds_documentos ADD COLUMN IF NOT EXISTS rev_paralela_gobbi BOOLEAN DEFAULT FALSE;
ALTER TABLE ds_documentos ADD COLUMN IF NOT EXISTS rev_paralela_kaique BOOLEAN DEFAULT FALSE;

-- 7. Patch fn_god_mentorado_deep to include trilha in profile
-- We replace the function, adding 'trilha' to the profile jsonb_build_object.
-- Full function body from migration 08, with trilha added.
CREATE OR REPLACE FUNCTION fn_god_mentorado_deep(p_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = "case", public
AS $$
DECLARE
  result JSONB;
  m RECORD;
BEGIN
  SELECT * INTO m FROM mentorados WHERE id = p_id;
  IF NOT FOUND THEN RETURN '{}'::JSONB; END IF;

  SELECT jsonb_build_object(
    'profile', (
      SELECT jsonb_build_object(
        'id', m.id,
        'nome', m.nome,
        'instagram', m.instagram,
        'cidade', m.cidade,
        'estado', m.estado,
        'email', m.email,
        'telefone', m.telefone,
        'cohort', m.cohort,
        'trilha', m.trilha,
        'nicho', m.nicho,
        'data_inicio', m.data_inicio,
        'perfil_negocio', m.perfil_negocio,
        'frequencia_call', m.frequencia_call,
        'proxima_call', m.proxima_call_agendada,
        'consultor_responsavel', m.consultor_responsavel
      )
    ),
    'phase', (
      SELECT jsonb_build_object(
        'fase_jornada', m.fase_jornada,
        'sub_etapa', m.sub_etapa,
        'marco_atual', m.marco_atual,
        'risco_churn', m.risco_churn,
        'engagement_score', m.score_engajamento,
        'implementation_score', m.score_implementacao,
        'marcos_atingidos', (
          SELECT COALESCE(jsonb_agg(jsonb_build_object(
            'marco', mm.marco,
            'data_atingido', mm.data_atingido,
            'evidencia', mm.evidencia
          ) ORDER BY mm.data_atingido DESC), '[]'::jsonb)
          FROM marcos_mentorado mm WHERE mm.mentorado_id = p_id
        )
      )
    ),
    'financial', (
      SELECT jsonb_build_object(
        'faturamento_atual', m.faturamento_atual,
        'meta_faturamento', m.meta_faturamento,
        'qtd_vendas_total', m.qtd_vendas_total,
        'ja_vendeu', m.ja_vendeu,
        'contrato_assinado', m.contrato_assinado,
        'status_financeiro', m.status_financeiro,
        'dia_pagamento', m.dia_pagamento
      )
    ),
    'context_ia', (
      SELECT COALESCE(
        (SELECT jsonb_build_object(
          'gargalos', v.gargalos,
          'estrategias_atuais', v.estrategias_atuais,
          'proximos_passos', v.proximos_passos,
          'sentimento_geral', v.sentimento_geral,
          'resumo_consolidado', v.resumo_consolidado
        ) FROM vw_god_contexto_ia v WHERE v.mentorado_id = p_id LIMIT 1),
        '{}'::jsonb
      )
    ),
    'last_calls', (
      SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'data_call', c.data_call,
        'tipo_call', c.tipo_call,
        'resumo', c.resumo,
        'decisoes_tomadas', c.decisoes_tomadas,
        'gargalos', c.gargalos,
        'proximos_passos', c.proximos_passos,
        'sentimento', c.sentimento
      ) ORDER BY c.data_call DESC), '[]'::jsonb)
      FROM (SELECT * FROM analises_call WHERE mentorado_id = p_id ORDER BY data_call DESC LIMIT 5) c
    ),
    'last_messages', (
      SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'periodo_inicio', aw.periodo_inicio,
        'periodo_fim', aw.periodo_fim,
        'total_mensagens', aw.total_mensagens,
        'topicos_principais', aw.topicos_principais,
        'sentimento_geral', aw.sentimento_geral,
        'resumo', aw.resumo
      ) ORDER BY aw.periodo_fim DESC), '[]'::jsonb)
      FROM (SELECT * FROM analises_whatsapp WHERE mentorado_id = p_id ORDER BY periodo_fim DESC LIMIT 5) aw
    )
  ) INTO result;

  RETURN result;
END;
$$;
