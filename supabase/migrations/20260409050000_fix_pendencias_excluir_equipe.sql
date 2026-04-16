-- Fix: vw_god_pendencias incluía mensagens da equipe como pendências
-- Mensagens com eh_equipe=true SÃO a resposta, não devem gerar pendência

-- 1. Limpar falsos positivos: marcar mensagens da equipe como respondidas
UPDATE interacoes_mentoria
SET respondido = true
WHERE eh_equipe = true
  AND requer_resposta = true
  AND respondido = false;

-- 2. Quando equipe responde num grupo, marcar pendências anteriores do mentorado como respondidas
-- (se equipe mandou msg no grupo depois da msg pendente do mentorado, considera respondido)
UPDATE interacoes_mentoria AS pend
SET respondido = true
WHERE pend.requer_resposta = true
  AND pend.respondido = false
  AND pend.eh_equipe = false
  AND EXISTS (
    SELECT 1 FROM interacoes_mentoria resp
    WHERE resp.mentorado_id = pend.mentorado_id
      AND resp.eh_equipe = true
      AND resp.created_at > pend.created_at
  );

-- 3. Recriar view excluindo mensagens da equipe
DROP VIEW IF EXISTS vw_god_pendencias CASCADE;
CREATE OR REPLACE VIEW vw_god_pendencias AS
SELECT
  m.id AS mentorado_id,
  m.nome AS mentorado_nome,
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
  AND i.eh_equipe = false       -- NUNCA mostrar msgs da equipe como pendência
  AND m.ativo = true
  AND m.cohort IS DISTINCT FROM 'tese'
ORDER BY i.created_at ASC;
