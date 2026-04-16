-- Add consultor_responsavel + grupo_whatsapp_id to vw_god_pendencias
DROP VIEW IF EXISTS vw_god_pendencias CASCADE;
CREATE OR REPLACE VIEW vw_god_pendencias AS
SELECT
  m.id AS mentorado_id,
  m.nome AS mentorado_nome,
  m.consultor_responsavel,
  m.grupo_whatsapp_id,
  i.id AS interacao_id,
  LEFT(i.conteudo, 200) AS conteudo_truncado,
  i.message_type AS tipo_interacao,
  i.urgencia_resposta,
  i.created_at,
  ROUND(EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600, 1) AS horas_pendente,
  CASE
    WHEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 > 48 THEN 'critico'
    WHEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 > 24 THEN 'alto'
    WHEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 > 12 THEN 'medio'
    ELSE 'baixo'
  END AS prioridade_calculada
FROM interacoes_mentoria i
JOIN mentorados m ON i.mentorado_id = m.id
WHERE i.requer_resposta = true
  AND i.respondido = false
  AND i.eh_equipe = false
  AND m.ativo = true
  AND m.cohort IS DISTINCT FROM 'tese'
ORDER BY i.created_at ASC;
