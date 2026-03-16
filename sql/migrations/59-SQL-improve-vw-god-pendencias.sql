-- ============================================================
-- Spalla Dashboard — Improve: vw_god_pendencias com NULL protection
-- 2026-03-16
-- ============================================================
-- A view atual usa respondido = false, mas não trata respondido IS NULL.
-- Mensagens com respondido=NULL aparecem como pendência eterna.
-- Adiciona has_team_response e sender_name para contexto.
-- ============================================================

CREATE OR REPLACE VIEW vw_god_pendencias AS
SELECT
  m.id AS mentorado_id,
  m.nome AS mentorado_nome,
  i.id AS interacao_id,
  LEFT(i.conteudo, 200) AS conteudo_truncado,
  i.sender_name,
  COALESCE(i.message_type, i.tipo_interacao) AS tipo_interacao,
  i.urgencia_resposta,
  i.created_at,
  ROUND(EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600, 1) AS horas_pendente,
  CASE
    WHEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 > 48 THEN 'critico'
    WHEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 > 24 THEN 'alto'
    WHEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 > 12 THEN 'medio'
    ELSE 'baixo'
  END AS prioridade_calculada,
  EXISTS (
    SELECT 1 FROM interacoes_mentoria resp
    WHERE resp.mentorado_id = i.mentorado_id
      AND resp.eh_equipe = true
      AND resp.created_at > i.created_at
      AND resp.created_at < i.created_at + INTERVAL '72 hours'
  ) AS has_team_response
FROM interacoes_mentoria i
JOIN mentorados m ON i.mentorado_id = m.id
WHERE i.requer_resposta = true
  AND COALESCE(i.respondido, false) = false
  AND COALESCE(i.eh_equipe, false) = false
  AND m.ativo = true
  AND m.cohort IS DISTINCT FROM 'tese'
ORDER BY i.created_at ASC;

GRANT SELECT ON vw_god_pendencias TO authenticated, anon;
