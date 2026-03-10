-- =====================================================
-- DOSSIÊ PRODUCTION CONTROL SYSTEM — Schema
-- Run this in Supabase SQL Editor
-- =====================================================

-- 1. ds_producoes — 1 per mentorado (production control)
CREATE TABLE IF NOT EXISTS ds_producoes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  mentorado_id BIGINT REFERENCES "case".mentorados(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'nao_iniciado',
    -- nao_iniciado | call_estrategia | producao | revisao | aprovado | enviado | apresentado | ajustes | finalizado | pausado | cancelado
  responsavel_atual TEXT,

  -- Marcos globais
  data_call_estrategia DATE,
  data_call_apresentacao DATE,
  data_call_onboarding DATE,
  contrato_assinado TEXT DEFAULT 'pendente', -- sim | nao | pendente

  -- Controle
  notas TEXT,
  created_by TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  UNIQUE(mentorado_id)
);

-- 2. ds_documentos — 3 per production (oferta, funil, conteudo)
CREATE TABLE IF NOT EXISTS ds_documentos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  producao_id UUID REFERENCES ds_producoes(id) ON DELETE CASCADE,
  mentorado_id BIGINT REFERENCES "case".mentorados(id) ON DELETE CASCADE,

  tipo TEXT NOT NULL, -- 'oferta' | 'funil' | 'conteudo'
  titulo TEXT,
  link_doc TEXT,      -- Google Doc URL

  estagio_atual TEXT DEFAULT 'pendente',
    -- pendente | producao_ia | revisao_mariza | revisao_kaique | revisao_queila | aprovado | enviado | feedback_mentorado | ajustes | finalizado
  responsavel_atual TEXT,

  -- Timestamps por etapa (denormalizados para query rápida)
  data_producao_ia TIMESTAMPTZ,
  data_revisao_mariza TIMESTAMPTZ,
  data_revisao_kaique TIMESTAMPTZ,
  data_revisao_queila TIMESTAMPTZ,
  data_envio TIMESTAMPTZ,
  data_feedback_mentorado TIMESTAMPTZ,
  data_finalizado TIMESTAMPTZ,

  -- Aging
  estagio_desde TIMESTAMPTZ DEFAULT now(),

  ordem INT DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. ds_eventos — audit trail
CREATE TABLE IF NOT EXISTS ds_eventos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  producao_id UUID REFERENCES ds_producoes(id) ON DELETE CASCADE,
  documento_id UUID REFERENCES ds_documentos(id) ON DELETE SET NULL,
  mentorado_id BIGINT,

  tipo_evento TEXT NOT NULL,
    -- estagio_change | handoff | ajuste_criado | ajuste_concluido | nota | feedback
  de_valor TEXT,
  para_valor TEXT,
  responsavel TEXT,
  proximo_responsavel TEXT,
  descricao TEXT,

  created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. ds_ajustes — post-call adjustments
CREATE TABLE IF NOT EXISTS ds_ajustes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  producao_id UUID REFERENCES ds_producoes(id) ON DELETE CASCADE,
  documento_id UUID REFERENCES ds_documentos(id) ON DELETE SET NULL,
  mentorado_id BIGINT,

  descricao TEXT NOT NULL,
  responsavel TEXT,
  deadline DATE,
  status TEXT DEFAULT 'pendente', -- pendente | em_andamento | concluido
  notas TEXT,

  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Indexes
CREATE INDEX IF NOT EXISTS idx_ds_documentos_producao ON ds_documentos(producao_id);
CREATE INDEX IF NOT EXISTS idx_ds_documentos_mentorado ON ds_documentos(mentorado_id);
CREATE INDEX IF NOT EXISTS idx_ds_eventos_producao ON ds_eventos(producao_id);
CREATE INDEX IF NOT EXISTS idx_ds_eventos_documento ON ds_eventos(documento_id);
CREATE INDEX IF NOT EXISTS idx_ds_ajustes_producao ON ds_ajustes(producao_id);

-- 6. View: vw_ds_pipeline
CREATE OR REPLACE VIEW vw_ds_pipeline AS
SELECT
  p.id AS producao_id,
  p.mentorado_id,
  m.nome AS mentorado_nome,
  p.status,
  p.responsavel_atual,
  p.data_call_estrategia,
  p.data_call_apresentacao,
  p.data_call_onboarding,
  p.contrato_assinado,
  p.notas,
  p.created_at,
  p.updated_at,

  -- Per-doc stages
  MAX(CASE WHEN d.tipo = 'oferta' THEN d.estagio_atual END) AS oferta_estagio,
  MAX(CASE WHEN d.tipo = 'funil' THEN d.estagio_atual END) AS funil_estagio,
  MAX(CASE WHEN d.tipo = 'conteudo' THEN d.estagio_atual END) AS conteudo_estagio,

  -- Per-doc responsaveis
  MAX(CASE WHEN d.tipo = 'oferta' THEN d.responsavel_atual END) AS oferta_responsavel,
  MAX(CASE WHEN d.tipo = 'funil' THEN d.responsavel_atual END) AS funil_responsavel,
  MAX(CASE WHEN d.tipo = 'conteudo' THEN d.responsavel_atual END) AS conteudo_responsavel,

  -- Counts
  COUNT(d.id) FILTER (WHERE d.estagio_atual = 'finalizado') AS docs_finalizados,
  COUNT(d.id) AS total_docs,

  -- Most behind doc (for bottleneck)
  MIN(CASE d.estagio_atual
    WHEN 'pendente' THEN 1 WHEN 'producao_ia' THEN 2
    WHEN 'revisao_mariza' THEN 3 WHEN 'revisao_kaique' THEN 4
    WHEN 'revisao_queila' THEN 5 WHEN 'aprovado' THEN 6
    WHEN 'enviado' THEN 7 WHEN 'feedback_mentorado' THEN 8
    WHEN 'ajustes' THEN 9 WHEN 'finalizado' THEN 10
  END) AS estagio_min_num,

  -- Aging (oldest doc in current stage)
  MAX(EXTRACT(DAY FROM now() - d.estagio_desde))::INT AS dias_no_estagio,

  -- Pending adjustments
  (SELECT COUNT(*) FROM ds_ajustes a WHERE a.producao_id = p.id AND a.status != 'concluido') AS ajustes_pendentes

FROM ds_producoes p
JOIN "case".mentorados m ON m.id = p.mentorado_id
LEFT JOIN ds_documentos d ON d.producao_id = p.id
GROUP BY p.id, m.nome, m.id;

-- 7. RLS Policies (permissive for team use)
ALTER TABLE ds_producoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE ds_documentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE ds_eventos ENABLE ROW LEVEL SECURITY;
ALTER TABLE ds_ajustes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ds_producoes_all" ON ds_producoes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "ds_documentos_all" ON ds_documentos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "ds_eventos_all" ON ds_eventos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "ds_ajustes_all" ON ds_ajustes FOR ALL USING (true) WITH CHECK (true);

-- 8. Updated_at trigger
CREATE OR REPLACE FUNCTION ds_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ds_producoes_updated BEFORE UPDATE ON ds_producoes
  FOR EACH ROW EXECUTE FUNCTION ds_update_timestamp();
CREATE TRIGGER ds_documentos_updated BEFORE UPDATE ON ds_documentos
  FOR EACH ROW EXECUTE FUNCTION ds_update_timestamp();
CREATE TRIGGER ds_ajustes_updated BEFORE UPDATE ON ds_ajustes
  FOR EACH ROW EXECUTE FUNCTION ds_update_timestamp();
