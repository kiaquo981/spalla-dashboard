-- =============================================================================
-- RECOVERY: Recreate views dropped by CASCADE on public.mentorados
-- =============================================================================

SET search_path = public, "case";

-- 1. vw_god_contexto_ia
CREATE OR REPLACE VIEW vw_god_contexto_ia AS
WITH latest_extracoes AS (
  SELECT DISTINCT ON (mentorado_id, agente_tipo)
    mentorado_id, agente_tipo, output_json, output_text, created_at
  FROM extracoes_agente
  WHERE agente_tipo IN ('DIAGNOSTICO','ESTRATEGIAS','TAREFAS_MENTORADO','TAREFAS_MENTORA','PRAZOS')
  ORDER BY mentorado_id, agente_tipo, created_at DESC
),
latest_doc AS (
  SELECT DISTINCT ON (mentorado_id)
    mentorado_id, titulo AS ultimo_plano_titulo, foco_principal AS ultimo_foco,
    completude_score AS completude_plano, created_at AS ultimo_plano_em
  FROM documentos_plano_acao WHERE status != 'RASCUNHO'
  ORDER BY mentorado_id, created_at DESC
)
SELECT
  m.id AS mentorado_id, m.nome AS mentorado_nome,
  diag.output_json->>'cenario_atual' AS cenario_atual,
  diag.output_json->'gargalos' AS gargalos,
  diag.output_json->'ativos' AS ativos,
  tm.output_json AS tarefas_mentorado_pendentes,
  tq.output_json AS tarefas_queila_pendentes,
  est.output_json AS estrategias_atuais,
  pz.output_json AS prazos_proximos,
  ld.ultimo_plano_titulo, ld.ultimo_foco, ld.completude_plano, ld.ultimo_plano_em
FROM mentorados m
LEFT JOIN latest_extracoes diag ON diag.mentorado_id = m.id AND diag.agente_tipo = 'DIAGNOSTICO'
LEFT JOIN latest_extracoes tm ON tm.mentorado_id = m.id AND tm.agente_tipo = 'TAREFAS_MENTORADO'
LEFT JOIN latest_extracoes tq ON tq.mentorado_id = m.id AND tq.agente_tipo = 'TAREFAS_MENTORA'
LEFT JOIN latest_extracoes est ON est.mentorado_id = m.id AND est.agente_tipo = 'ESTRATEGIAS'
LEFT JOIN latest_extracoes pz ON pz.mentorado_id = m.id AND pz.agente_tipo = 'PRAZOS'
LEFT JOIN latest_doc ld ON ld.mentorado_id = m.id
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese';

GRANT SELECT ON vw_god_contexto_ia TO authenticated, anon;

-- 2. vw_god_pendencias
CREATE OR REPLACE VIEW vw_god_pendencias AS
SELECT
  m.id AS mentorado_id, m.nome AS mentorado_nome,
  i.id AS interacao_id,
  LEFT(i.conteudo, 200) AS conteudo_truncado,
  i.sender_name,
  COALESCE(i.message_type, i.tipo_interacao) AS tipo_interacao,
  i.urgencia_resposta, i.created_at,
  ROUND(EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600, 1) AS horas_pendente,
  CASE
    WHEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 > 48 THEN 'critico'
    WHEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 > 24 THEN 'alto'
    WHEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 > 12 THEN 'medio'
    ELSE 'baixo'
  END AS prioridade_calculada,
  EXISTS (
    SELECT 1 FROM interacoes_mentoria resp
    WHERE resp.mentorado_id = i.mentorado_id AND resp.eh_equipe = true
      AND resp.created_at > i.created_at AND resp.created_at < i.created_at + INTERVAL '72 hours'
  ) AS has_team_response
FROM interacoes_mentoria i
JOIN mentorados m ON i.mentorado_id = m.id
WHERE i.requer_resposta = true
  AND COALESCE(i.respondido, false) = false
  AND COALESCE(i.eh_equipe, false) = false
  AND m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'
ORDER BY i.created_at ASC;

GRANT SELECT ON vw_god_pendencias TO authenticated, anon;

-- 3. vw_god_cohort
CREATE OR REPLACE VIEW vw_god_cohort AS
SELECT
  m.fase_jornada AS fase,
  COUNT(*) AS total_mentorados,
  COUNT(*) FILTER (WHERE m.risco_churn = 'critico') AS criticos,
  COUNT(*) FILTER (WHERE m.risco_churn = 'alto') AS altos,
  COUNT(*) FILTER (WHERE m.risco_churn = 'medio') AS medios,
  COUNT(*) FILTER (WHERE m.risco_churn = 'baixo') AS baixos,
  ROUND(AVG(m.score_engajamento), 1) AS avg_engagement,
  ROUND(AVG(m.score_implementacao), 1) AS avg_implementation
FROM mentorados m
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'
GROUP BY m.fase_jornada
ORDER BY CASE m.fase_jornada
  WHEN 'escala' THEN 1 WHEN 'otimizacao' THEN 2 WHEN 'validacao' THEN 3
  WHEN 'concepcao' THEN 4 WHEN 'onboarding' THEN 5 ELSE 6
END;

GRANT SELECT ON vw_god_cohort TO authenticated, anon;

-- 4. vw_god_overview (latest version with trilha + consultor_responsavel)
CREATE OR REPLACE VIEW vw_god_overview AS
WITH
wa_stats AS (
  SELECT i.mentorado_id,
    COUNT(*) FILTER (WHERE i.created_at >= NOW() - INTERVAL '7 days') AS whatsapp_7d,
    COUNT(*) FILTER (WHERE i.created_at >= NOW() - INTERVAL '30 days') AS whatsapp_30d,
    COUNT(*) AS whatsapp_total,
    COUNT(*) FILTER (WHERE i.requer_resposta = true AND i.respondido = false) AS msgs_pendentes_resposta,
    MAX(CASE WHEN i.requer_resposta = true AND i.respondido = false AND i.eh_equipe = false
      THEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 ELSE 0 END) AS horas_sem_resposta_equipe
  FROM interacoes_mentoria i WHERE i.mentorado_id IS NOT NULL GROUP BY i.mentorado_id
),
call_stats AS (
  SELECT cm.mentorado_id, MAX(COALESCE(cm.data_call, cm.created_at)) AS ultima_call_data
  FROM calls_mentoria cm GROUP BY cm.mentorado_id
),
tarefa_stats AS (
  SELECT mentorado_id,
    COUNT(*) FILTER (WHERE LOWER(status) = 'pendente') AS tarefas_pendentes_total,
    COUNT(*) FILTER (WHERE LOWER(status) = 'pendente' AND prazo IS NOT NULL AND prazo < NOW()) AS tarefas_atrasadas
  FROM (
    SELECT mentorado_id::integer, status, prazo FROM tarefas_acordadas
    UNION ALL
    SELECT mentorado_id::integer, status::text, prazo::timestamptz FROM tarefas_equipe WHERE mentorado_id IS NOT NULL
  ) all_tasks GROUP BY mentorado_id
)
SELECT
  m.id, m.nome, m.instagram, m.cohort, m.trilha,
  m.fase_jornada, m.sub_etapa, m.marco_atual, m.risco_churn,
  m.score_engajamento AS engagement_score, m.score_implementacao AS implementation_score,
  m.faturamento_atual, m.meta_faturamento,
  CASE WHEN m.meta_faturamento > 0 AND m.faturamento_atual > 0
    THEN ROUND((m.faturamento_atual / m.meta_faturamento) * 100, 1) ELSE 0 END AS pct_meta_atingida,
  m.qtd_vendas_total, m.ja_vendeu,
  COALESCE(wa.whatsapp_7d, 0)::integer AS whatsapp_7d,
  COALESCE(wa.whatsapp_30d, 0)::integer AS whatsapp_30d,
  COALESCE(wa.whatsapp_total, 0)::integer AS whatsapp_total,
  COALESCE(wa.msgs_pendentes_resposta, 0)::integer AS msgs_pendentes_resposta,
  ROUND(COALESCE(wa.horas_sem_resposta_equipe, 0)::numeric, 1) AS horas_sem_resposta_equipe,
  cs.ultima_call_data,
  CASE WHEN cs.ultima_call_data IS NOT NULL
    THEN EXTRACT(DAY FROM (NOW() - cs.ultima_call_data))::integer ELSE NULL END AS dias_desde_call,
  COALESCE(ts.tarefas_pendentes_total, 0)::integer AS tarefas_pendentes,
  COALESCE(ts.tarefas_atrasadas, 0)::integer AS tarefas_atrasadas,
  COALESCE(m.contrato_assinado, true) AS contrato_assinado,
  COALESCE(m.status_financeiro, 'em_dia') AS status_financeiro,
  m.dia_pagamento, m.grupo_whatsapp_id, m.consultor_responsavel, m.created_at AS data_entrada
FROM "case".mentorados m
LEFT JOIN wa_stats wa ON wa.mentorado_id = m.id
LEFT JOIN call_stats cs ON cs.mentorado_id = m.id
LEFT JOIN tarefa_stats ts ON ts.mentorado_id = m.id
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'
ORDER BY CASE m.fase_jornada
  WHEN 'escala' THEN 1 WHEN 'otimizacao' THEN 2 WHEN 'validacao' THEN 3
  WHEN 'concepcao' THEN 4 WHEN 'onboarding' THEN 5 ELSE 6
END, m.nome;

GRANT SELECT ON vw_god_overview TO authenticated, anon;

-- Force reload
NOTIFY pgrst, 'reload schema';
