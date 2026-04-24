-- ============================================================
-- Migration: alertas_mentorado + vw_alertas_command_center
-- Story 6: Alertas e Urgências no Command Center
-- ============================================================

-- Tabela de alertas operacionais (equipe + sistema)
CREATE TABLE IF NOT EXISTS alertas_mentorado (
  id BIGSERIAL PRIMARY KEY,
  mentorado_id BIGINT NOT NULL,
  tipo TEXT NOT NULL DEFAULT 'inatividade',
    -- tipos: inatividade, insatisfacao, bloqueio, trava, promessa_nao_cumprida, sem_call, urgencia, custom
  severidade TEXT NOT NULL DEFAULT 'medio',
    -- severidades: critico, alto, medio, baixo
  titulo TEXT NOT NULL,
  descricao TEXT,
  fonte TEXT DEFAULT 'sistema',
    -- fontes: sistema (auto-gerado), equipe (manual), n8n (workflow)
  resolvido BOOLEAN NOT NULL DEFAULT FALSE,
  resolvido_por TEXT,
  resolvido_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index para queries frequentes
CREATE INDEX IF NOT EXISTS idx_alertas_mentorado_abertos
  ON alertas_mentorado (mentorado_id, resolvido, severidade)
  WHERE resolvido = FALSE;

CREATE INDEX IF NOT EXISTS idx_alertas_mentorado_created
  ON alertas_mentorado (created_at DESC);

-- RLS
ALTER TABLE alertas_mentorado ENABLE ROW LEVEL SECURITY;
CREATE POLICY "alertas_mentorado_anon_all" ON alertas_mentorado
  FOR ALL TO anon USING (true) WITH CHECK (true);

-- View agregada para Command Center
CREATE OR REPLACE VIEW vw_alertas_command_center AS
SELECT
  a.id,
  a.mentorado_id,
  m.nome AS mentorado_nome,
  a.tipo,
  a.severidade,
  a.titulo,
  a.descricao,
  a.fonte,
  a.created_at,
  -- Tempo desde criação (em horas)
  ROUND(EXTRACT(EPOCH FROM (NOW() - a.created_at)) / 3600, 1) AS horas_aberto
FROM alertas_mentorado a
JOIN mentorados m ON m.id = a.mentorado_id
WHERE a.resolvido = FALSE
ORDER BY
  CASE a.severidade
    WHEN 'critico' THEN 1
    WHEN 'alto' THEN 2
    WHEN 'medio' THEN 3
    WHEN 'baixo' THEN 4
  END,
  a.created_at ASC;

-- Auto-gerar alertas de inatividade (mentorados sem interação há 7+ dias)
-- Isso pode ser chamado periodicamente via cron/n8n
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
      WHEN MAX(i.created_at) < NOW() - INTERVAL '14 days' THEN 'critico'
      WHEN MAX(i.created_at) < NOW() - INTERVAL '7 days' THEN 'alto'
      ELSE 'medio'
    END,
    'Mentorado inativo há ' || EXTRACT(DAY FROM (NOW() - MAX(i.created_at)))::INT || ' dias',
    'Última interação: ' || TO_CHAR(MAX(i.created_at), 'DD/MM/YYYY HH24:MI'),
    'sistema'
  FROM mentorados m
  LEFT JOIN interacoes_mentoria i ON i.mentorado_id = m.id
  WHERE m.status = 'ativo'
  GROUP BY m.id
  HAVING MAX(i.created_at) < NOW() - INTERVAL '7 days'
    -- Não duplicar alerta se já existe um aberto do mesmo tipo
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
