-- =====================================================
-- DS-17: Aging alerts for stale documents
-- =====================================================

CREATE OR REPLACE FUNCTION ds_aging_alerts()
RETURNS TABLE (
  id UUID,
  tipo TEXT,
  estagio_atual TEXT,
  responsavel_atual TEXT,
  mentorado_nome TEXT,
  dias_parado INT
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    d.id,
    d.tipo,
    d.estagio_atual,
    d.responsavel_atual,
    m.nome AS mentorado_nome,
    EXTRACT(DAY FROM now() - d.estagio_desde)::INT AS dias_parado
  FROM ds_documentos d
  JOIN ds_producoes p ON p.id = d.producao_id
  JOIN "case".mentorados m ON m.id = d.mentorado_id
  WHERE d.estagio_atual NOT IN ('finalizado', 'enviado', 'pendente')
    AND EXTRACT(DAY FROM now() - d.estagio_desde) > 3
  ORDER BY dias_parado DESC;
$$;
