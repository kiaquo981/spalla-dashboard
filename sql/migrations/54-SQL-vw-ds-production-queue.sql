-- =====================================================
-- DS-12: View fila de produção
-- Mentorados com transcrição disponível mas sem produção completa
-- =====================================================

CREATE OR REPLACE VIEW vw_ds_production_queue AS
SELECT
  m.id,
  m.nome,
  COUNT(t.id) AS transcricoes_disponiveis,
  MAX(t.created_at) AS ultima_transcricao,
  p.id AS producao_id,
  p.status AS producao_status
FROM "case".mentorados m
JOIN ds_transcricoes t ON t.mentorado_id = m.id AND t.status = 'disponivel'
LEFT JOIN ds_producoes p ON p.mentorado_id = m.id
WHERE p.id IS NULL OR p.status = 'nao_iniciado'
GROUP BY m.id, m.nome, p.id, p.status
ORDER BY ultima_transcricao DESC;
