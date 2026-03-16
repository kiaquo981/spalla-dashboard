-- ================================================================
-- PA (Plano de Ação) Schema — 3 Tables + 1 View
-- Run in Supabase SQL Editor
-- ================================================================

-- 1. pa_planos (1 per mentee)
CREATE TABLE IF NOT EXISTS pa_planos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  mentorado_id BIGINT NOT NULL REFERENCES "case".mentorados(id) ON DELETE CASCADE,
  titulo TEXT NOT NULL DEFAULT 'Plano de Ação',
  formato TEXT DEFAULT 'fases' CHECK (formato IN ('fases','passos')),
  google_doc_url TEXT,
  status_geral TEXT DEFAULT 'nao_iniciado'
    CHECK (status_geral IN ('nao_iniciado','em_andamento','pausado','concluido')),
  notas TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by TEXT
);

CREATE INDEX IF NOT EXISTS idx_pa_planos_mentorado ON pa_planos(mentorado_id);

-- 2. pa_fases (sections within a plan)
CREATE TABLE IF NOT EXISTS pa_fases (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  plano_id UUID NOT NULL REFERENCES pa_planos(id) ON DELETE CASCADE,
  mentorado_id BIGINT NOT NULL REFERENCES "case".mentorados(id),
  titulo TEXT NOT NULL,
  tipo TEXT DEFAULT 'fase' CHECK (tipo IN ('revisao_dossie','fase','passo_executivo')),
  ordem INT DEFAULT 0,
  status TEXT DEFAULT 'nao_iniciado'
    CHECK (status IN ('nao_iniciado','em_andamento','concluido','pausado')),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pa_fases_plano ON pa_fases(plano_id);
CREATE INDEX IF NOT EXISTS idx_pa_fases_mentorado ON pa_fases(mentorado_id);

-- 3. pa_acoes (action items within each phase)
CREATE TABLE IF NOT EXISTS pa_acoes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
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
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pa_acoes_fase ON pa_acoes(fase_id);
CREATE INDEX IF NOT EXISTS idx_pa_acoes_plano ON pa_acoes(plano_id);
CREATE INDEX IF NOT EXISTS idx_pa_acoes_mentorado ON pa_acoes(mentorado_id);

-- 4. View: vw_pa_pipeline (aggregated for dashboard)
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
    MAX(a.updated_at) AS last_acao_update
  FROM pa_acoes a WHERE a.plano_id = p.id
) a_agg ON true;

-- RLS policies
ALTER TABLE pa_planos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pa_fases ENABLE ROW LEVEL SECURITY;
ALTER TABLE pa_acoes ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to read/write (team tool)
CREATE POLICY "pa_planos_all" ON pa_planos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "pa_fases_all" ON pa_fases FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "pa_acoes_all" ON pa_acoes FOR ALL USING (true) WITH CHECK (true);

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_pa_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pa_planos_updated_at BEFORE UPDATE ON pa_planos
FOR EACH ROW EXECUTE FUNCTION update_pa_updated_at();

CREATE TRIGGER trg_pa_acoes_updated_at BEFORE UPDATE ON pa_acoes
FOR EACH ROW EXECUTE FUNCTION update_pa_updated_at();
