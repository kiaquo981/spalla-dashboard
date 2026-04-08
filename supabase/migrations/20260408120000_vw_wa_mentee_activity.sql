-- ============================================================
-- View: vw_wa_mentee_activity
-- Unifica interacoes_mentoria + whatsapp_messages + wa_topics
-- numa timeline única por mentorado para alimentar
-- WA Intelligence Stories 1-6
--
-- Tabelas reais no banco:
--   interacoes_mentoria (50k+ rows, classificação IA n8n)
--   whatsapp_messages (legacy, mensagens brutas Evolution API)
--   wa_topics (clusters de conversas IA)
--   wa_topic_events (audit trail de tópicos)
-- ============================================================

-- ------------------------------------------------------------
-- 1. View principal: atividade unificada por mentorado
-- Fonte primária: interacoes_mentoria (já tem classificação rica)
-- Fonte secundária: wa_topic_events (mudanças de status)
--
-- NOTA: whatsapp_messages NÃO entra como fonte separada porque
-- interacoes_mentoria já é derivada dela (1:1 via message_id).
-- Incluir ambas duplicaria cada mensagem na timeline.
-- ------------------------------------------------------------
DROP VIEW IF EXISTS vw_wa_mentee_activity CASCADE;
CREATE OR REPLACE VIEW vw_wa_mentee_activity AS

-- Fonte 1: interacoes_mentoria (classificação IA do n8n)
SELECT
  'interacao'::text AS source,
  i.id::text AS id,
  i.mentorado_id,
  m.nome AS mentorado_nome,
  i.conteudo AS content,
  i.tipo_interacao AS activity_type,
  i.categoria AS category,
  i.sentimento AS sentiment,
  i.prioridade AS priority,
  i.score_engajamento AS engagement_score,
  i.eh_equipe AS is_team,
  i.autor_identificado AS team_member,
  i.requer_resposta AS needs_response,
  COALESCE(i.respondido, false) AS was_responded,
  i.urgencia_resposta AS response_urgency,
  i.tags,
  i.acoes_sugeridas AS suggested_actions,
  i.indicadores::jsonb AS indicators,
  i.valores_extraidos::jsonb AS extracted_values,
  i.topic_id,
  wt.title AS topic_title,
  COALESCE(i.topic_status, wt.status) AS topic_status,
  wtt.name AS topic_type_name,
  wtt.color AS topic_type_color,
  i.sender_name,
  i.message_type AS content_type,
  COALESCE(i.timestamp, i.created_at) AS activity_at
FROM interacoes_mentoria i
JOIN mentorados m ON m.id = i.mentorado_id
LEFT JOIN wa_topics wt ON wt.id = i.topic_id
LEFT JOIN wa_topic_types wtt ON wtt.id = wt.type_id
WHERE m.ativo = true
  AND m.cohort IS DISTINCT FROM 'tese'

UNION ALL

-- Fonte 2: wa_topic_events (mudanças de status dos tópicos)
SELECT
  'topic_event'::text AS source,
  wte.id::text AS id,
  wt.mentorado_id,
  m.nome AS mentorado_nome,
  COALESCE(
    wte.payload->>'summary',
    'Tópico: ' || wt.title || ' → ' || COALESCE(wte.payload->>'new_status', wte.event_type)
  ) AS content,
  wte.event_type AS activity_type,
  'topico'::text AS category,
  NULL::text AS sentiment,
  NULL::text AS priority,
  NULL::integer AS engagement_score,
  (wte.created_by IS NOT NULL AND wte.created_by != 'ai') AS is_team,
  wte.created_by AS team_member,
  false AS needs_response,
  false AS was_responded,
  NULL::text AS response_urgency,
  wt.ai_keywords AS tags,
  NULL::text[] AS suggested_actions,
  wte.payload AS indicators,
  NULL::jsonb AS extracted_values,
  wt.id AS topic_id,
  wt.title AS topic_title,
  wt.status AS topic_status,
  wtt.name AS topic_type_name,
  wtt.color AS topic_type_color,
  wte.created_by AS sender_name,
  'event'::text AS content_type,
  wte.created_at AS activity_at
FROM wa_topic_events wte
JOIN wa_topics wt ON wt.id = wte.topic_id
JOIN mentorados m ON m.id = wt.mentorado_id
LEFT JOIN wa_topic_types wtt ON wtt.id = wt.type_id
WHERE m.ativo = true
  AND m.cohort IS DISTINCT FROM 'tese'
  AND wt.mentorado_id IS NOT NULL;


-- ------------------------------------------------------------
-- 2. View resumida: stats por mentorado (última semana)
-- Para cards de Command Center e health checks
-- ------------------------------------------------------------
DROP VIEW IF EXISTS vw_wa_mentee_weekly_stats CASCADE;
CREATE OR REPLACE VIEW vw_wa_mentee_weekly_stats AS
SELECT
  m.id AS mentorado_id,
  m.nome AS mentorado_nome,

  -- Contadores da semana
  COUNT(*) FILTER (
    WHERE i.created_at >= NOW() - INTERVAL '7 days'
  ) AS interacoes_semana,

  -- Mensagens brutas da semana (whatsapp_messages)
  (
    SELECT COUNT(*)
    FROM whatsapp_messages wm
    JOIN mentorados mx ON mx.grupo_whatsapp_id = wm.group_id
    WHERE mx.id = m.id
      AND wm.timestamp >= NOW() - INTERVAL '7 days'
  ) AS mensagens_semana,

  -- Pendências abertas
  COUNT(*) FILTER (
    WHERE i.requer_resposta = true
      AND COALESCE(i.respondido, false) = false
  ) AS pendencias_abertas,

  -- Dúvidas sem resposta
  COUNT(*) FILTER (
    WHERE i.tipo_interacao = 'duvida'
      AND i.requer_resposta = true
      AND COALESCE(i.respondido, false) = false
  ) AS duvidas_sem_resposta,

  -- Mensagens negativas na semana
  COUNT(*) FILTER (
    WHERE i.sentimento = 'negativo'
      AND i.created_at >= NOW() - INTERVAL '7 days'
  ) AS msgs_negativas_semana,

  -- Celebrações na semana
  COUNT(*) FILTER (
    WHERE i.tipo_interacao = 'celebracao'
      AND i.created_at >= NOW() - INTERVAL '7 days'
  ) AS celebracoes_semana,

  -- Última atividade do mentorado
  MAX(i.created_at) FILTER (
    WHERE i.eh_equipe = false
  ) AS ultima_msg_mentorado,

  -- Última atividade da equipe
  MAX(i.created_at) FILTER (
    WHERE i.eh_equipe = true
  ) AS ultima_msg_equipe,

  -- Tempo médio pendências abertas (horas)
  ROUND(AVG(
    EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600
  ) FILTER (
    WHERE i.requer_resposta = true
      AND COALESCE(i.respondido, false) = false
  ), 1) AS avg_horas_sem_resposta,

  -- Score de engajamento médio da semana
  ROUND(AVG(i.score_engajamento) FILTER (
    WHERE i.score_engajamento IS NOT NULL
      AND i.created_at >= NOW() - INTERVAL '7 days'
  ), 1) AS avg_engajamento_semana,

  -- Tópicos ativos
  (
    SELECT COUNT(*)
    FROM wa_topics wt
    WHERE wt.mentorado_id = m.id
      AND wt.status IN ('open', 'active', 'pending_action')
  ) AS topicos_ativos

FROM mentorados m
LEFT JOIN interacoes_mentoria i ON i.mentorado_id = m.id
WHERE m.ativo = true
  AND m.cohort IS DISTINCT FROM 'tese'
GROUP BY m.id, m.nome;


-- ------------------------------------------------------------
-- 3. Grants
-- ------------------------------------------------------------
GRANT SELECT ON vw_wa_mentee_activity TO authenticated, anon;
GRANT SELECT ON vw_wa_mentee_weekly_stats TO authenticated, anon;
