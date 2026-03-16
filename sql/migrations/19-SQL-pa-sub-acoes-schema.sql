-- ================================================================
-- PA Sub-Ações Schema — New hierarchy level
-- pa_planos → pa_fases → pa_acoes → pa_sub_acoes
-- Run in Supabase SQL Editor BEFORE inserting v2 data
-- ================================================================

-- 1. pa_sub_acoes (granular tasks within each action)
CREATE TABLE IF NOT EXISTS pa_sub_acoes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  acao_id UUID NOT NULL REFERENCES pa_acoes(id) ON DELETE CASCADE,
  fase_id UUID NOT NULL REFERENCES pa_fases(id) ON DELETE CASCADE,
  plano_id UUID NOT NULL REFERENCES pa_planos(id) ON DELETE CASCADE,
  mentorado_id BIGINT NOT NULL REFERENCES "case".mentorados(id),
  numero INT,
  titulo TEXT NOT NULL,
  status TEXT DEFAULT 'pendente'
    CHECK (status IN ('pendente','em_andamento','concluido','bloqueado','nao_aplicavel')),
  data_prevista DATE,
  data_conclusao DATE,
  responsavel TEXT DEFAULT 'mentorado',
  notas TEXT,
  ordem INT DEFAULT 0,
  origem TEXT DEFAULT 'manual',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_pa_sub_acoes_acao ON pa_sub_acoes(acao_id);
CREATE INDEX IF NOT EXISTS idx_pa_sub_acoes_fase ON pa_sub_acoes(fase_id);
CREATE INDEX IF NOT EXISTS idx_pa_sub_acoes_plano ON pa_sub_acoes(plano_id);
CREATE INDEX IF NOT EXISTS idx_pa_sub_acoes_mentorado ON pa_sub_acoes(mentorado_id);

-- RLS
ALTER TABLE pa_sub_acoes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "pa_sub_acoes_all" ON pa_sub_acoes FOR ALL USING (true) WITH CHECK (true);

-- Updated_at trigger
CREATE TRIGGER trg_pa_sub_acoes_updated_at BEFORE UPDATE ON pa_sub_acoes
FOR EACH ROW EXECUTE FUNCTION update_pa_updated_at();

-- ================================================================
-- Update vw_pa_pipeline to include sub_acoes counts
-- ================================================================
DROP VIEW IF EXISTS vw_pa_pipeline;
CREATE OR REPLACE VIEW vw_pa_pipeline AS
SELECT
  p.id AS plano_id,
  p.mentorado_id,
  m.nome AS mentorado_nome,
  p.titulo,
  p.formato,
  p.google_doc_url,
  p.status_geral,
  p.notas,
  p.created_at,
  p.updated_at,
  COALESCE(f_agg.total_fases, 0) AS total_fases,
  COALESCE(a_agg.total_acoes, 0) AS total_acoes,
  COALESCE(a_agg.acoes_concluidas, 0) AS acoes_concluidas,
  COALESCE(a_agg.acoes_bloqueadas, 0) AS acoes_bloqueadas,
  COALESCE(a_agg.acoes_vencidas, 0) AS acoes_vencidas,
  COALESCE(s_agg.total_sub_acoes, 0) AS total_sub_acoes,
  COALESCE(s_agg.sub_acoes_concluidas, 0) AS sub_acoes_concluidas,
  CASE WHEN COALESCE(a_agg.total_acoes, 0) > 0
    THEN ROUND((COALESCE(a_agg.acoes_concluidas, 0)::numeric / a_agg.total_acoes) * 100)
    ELSE 0
  END AS pct_concluido,
  f_agg.fase_atual,
  EXTRACT(DAY FROM now() - GREATEST(
    p.updated_at,
    COALESCE(a_agg.last_acao_update, p.updated_at)
  ))::int AS dias_sem_update
FROM pa_planos p
JOIN "case".mentorados m ON m.id = p.mentorado_id
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) AS total_fases,
    (SELECT f2.titulo FROM pa_fases f2
     WHERE f2.plano_id = p.id AND f2.status IN ('nao_iniciado','em_andamento')
     ORDER BY f2.ordem LIMIT 1) AS fase_atual
  FROM pa_fases f WHERE f.plano_id = p.id
) f_agg ON true
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) AS total_acoes,
    COUNT(*) FILTER (WHERE a.status = 'concluido') AS acoes_concluidas,
    COUNT(*) FILTER (WHERE a.status = 'bloqueado') AS acoes_bloqueadas,
    COUNT(*) FILTER (WHERE a.data_prevista < CURRENT_DATE AND a.status NOT IN ('concluido','nao_aplicavel')) AS acoes_vencidas,
    MAX(a.updated_at) AS last_acao_update
  FROM pa_acoes a WHERE a.plano_id = p.id
) a_agg ON true
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) AS total_sub_acoes,
    COUNT(*) FILTER (WHERE s.status = 'concluido') AS sub_acoes_concluidas
  FROM pa_sub_acoes s WHERE s.plano_id = p.id
) s_agg ON true;
