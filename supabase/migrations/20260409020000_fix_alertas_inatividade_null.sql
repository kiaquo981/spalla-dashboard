-- Fix: fn_gerar_alertas_inatividade ignorava mentorados sem interações (MAX retorna NULL)
-- CodeRabbit issue: COALESCE fallback para m.created_at + CHECK constraints

-- Add CHECK constraints (não pode fazer FK pois mentorados é VIEW)
ALTER TABLE alertas_mentorado
  ADD CONSTRAINT chk_alertas_tipo CHECK (tipo IN ('inatividade', 'insatisfacao', 'bloqueio', 'trava', 'promessa_nao_cumprida', 'sem_call', 'urgencia', 'custom')),
  ADD CONSTRAINT chk_alertas_severidade CHECK (severidade IN ('critico', 'alto', 'medio', 'baixo')),
  ADD CONSTRAINT chk_alertas_fonte CHECK (fonte IN ('sistema', 'equipe', 'n8n'));

-- Recriar função com COALESCE fix
CREATE OR REPLACE FUNCTION fn_gerar_alertas_inatividade()
RETURNS INTEGER AS $$
DECLARE
  cnt INTEGER := 0;
BEGIN
  INSERT INTO alertas_mentorado (mentorado_id, tipo, severidade, titulo, descricao, fonte)
  SELECT
    m.id,
    'inatividade',
    CASE
      WHEN COALESCE(MAX(i.created_at), m.created_at) < NOW() - INTERVAL '14 days' THEN 'critico'
      WHEN COALESCE(MAX(i.created_at), m.created_at) < NOW() - INTERVAL '7 days' THEN 'alto'
      ELSE 'medio'
    END,
    'Mentorado inativo há ' || EXTRACT(DAY FROM (NOW() - COALESCE(MAX(i.created_at), m.created_at)))::INT || ' dias',
    'Última interação: ' || COALESCE(TO_CHAR(MAX(i.created_at), 'DD/MM/YYYY HH24:MI'), 'nenhuma registrada'),
    'sistema'
  FROM mentorados m
  LEFT JOIN interacoes_mentoria i ON i.mentorado_id = m.id
  WHERE m.status = 'ativo'
  GROUP BY m.id, m.created_at
  HAVING COALESCE(MAX(i.created_at), m.created_at) < NOW() - INTERVAL '7 days'
    AND NOT EXISTS (
      SELECT 1 FROM alertas_mentorado a
      WHERE a.mentorado_id = m.id
        AND a.tipo = 'inatividade'
        AND a.resolvido = FALSE
        AND a.created_at > NOW() - INTERVAL '3 days'
    );

  GET DIAGNOSTICS cnt = ROW_COUNT;
  RETURN cnt;
END;
$$ LANGUAGE plpgsql;
