-- Fix: vw_wa_mentee_weekly_stats contava msgs da equipe como pendência
-- Mesma correção que vw_god_pendencias e vw_god_overview

-- Recriar view com filtro eh_equipe = false
DROP VIEW IF EXISTS vw_wa_mentee_weekly_stats CASCADE;
CREATE OR REPLACE VIEW vw_wa_mentee_weekly_stats AS
SELECT
  m.id AS mentorado_id,
  m.nome AS mentorado_nome,
  COUNT(*) FILTER (WHERE i.created_at >= NOW() - INTERVAL '7 days') AS interacoes_semana,
  (SELECT COUNT(*) FROM whatsapp_messages wm
   JOIN mentorados mx ON mx.grupo_whatsapp_id = wm.group_id
   WHERE mx.id = m.id AND wm.timestamp >= NOW() - INTERVAL '7 days'
  ) AS mensagens_semana,
  -- Fix: exclui equipe
  COUNT(*) FILTER (
    WHERE i.requer_resposta = true AND COALESCE(i.respondido, false) = false AND i.eh_equipe = false
  ) AS pendencias_abertas,
  COUNT(*) FILTER (
    WHERE i.tipo_interacao = 'duvida' AND i.requer_resposta = true AND COALESCE(i.respondido, false) = false AND i.eh_equipe = false
  ) AS duvidas_sem_resposta,
  COUNT(*) FILTER (WHERE i.created_at >= NOW() - INTERVAL '7 days' AND i.sentimento = 'positivo') AS celebracoes_semana,
  COUNT(*) FILTER (WHERE i.created_at >= NOW() - INTERVAL '7 days' AND i.sentimento = 'negativo') AS msgs_negativas_semana,
  ROUND(AVG(i.score_engajamento) FILTER (WHERE i.created_at >= NOW() - INTERVAL '7 days'), 1) AS avg_engajamento_semana,
  ROUND(AVG(EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600) FILTER (
    WHERE i.requer_resposta = true AND COALESCE(i.respondido, false) = false AND i.eh_equipe = false
  ), 1) AS avg_horas_sem_resposta,
  MAX(i.created_at) FILTER (WHERE i.eh_equipe = false) AS ultima_msg_mentorado,
  MAX(i.created_at) FILTER (WHERE i.eh_equipe = true) AS ultima_msg_equipe,
  COUNT(DISTINCT i.topic_id) FILTER (WHERE i.created_at >= NOW() - INTERVAL '7 days') AS topicos_ativos
FROM mentorados m
LEFT JOIN interacoes_mentoria i ON i.mentorado_id = m.id
WHERE m.ativo = true
GROUP BY m.id, m.nome;

-- Also: disable sprint_auto_create on non-sistema spaces (prevent duplicate sprints)
UPDATE god_spaces SET sprint_auto_create = false WHERE id != 'space_sistema';
