-- ============================================================
-- Operon Dashboard — Call Intelligence (call_insights)
-- 2026-03-12
-- ============================================================
-- OBJETIVO:
-- Tabela call_insights para armazenar insights estruturados
-- extraídos de calls por GPT: decisões, bloqueios, ações,
-- feedbacks, marcos. Alimentada via N8N após análise GPT.
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. Tabela call_insights
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS call_insights (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  call_id         UUID NOT NULL REFERENCES calls_mentoria(id) ON DELETE CASCADE,
  mentorado_id    BIGINT REFERENCES "case".mentorados(id) ON DELETE SET NULL,

  -- Tipo do insight
  tipo            TEXT NOT NULL CHECK (tipo IN (
    'decision',   -- Decisão tomada na call
    'blocker',    -- Bloqueio identificado
    'action',     -- Ação acordada (pode virar god_task)
    'feedback',   -- Feedback do mentorado
    'milestone',  -- Marco/conquista
    'risk',       -- Risco identificado
    'insight'     -- Insight geral
  )),

  -- Conteúdo
  titulo          TEXT NOT NULL,
  descricao       TEXT,
  impacto         TEXT CHECK (impacto IN ('alto', 'medio', 'baixo')),

  -- Status (para action items)
  status          TEXT DEFAULT 'pendente' CHECK (status IN (
    'pendente', 'em_andamento', 'concluido', 'cancelado'
  )),

  -- Links
  god_task_id     UUID REFERENCES god_tasks(id) ON DELETE SET NULL,
  pa_acao_id      UUID REFERENCES pa_acoes(id) ON DELETE SET NULL,

  -- Metadata
  confianca       NUMERIC(3,2) CHECK (confianca BETWEEN 0 AND 1),  -- 0-1, GPT confidence
  auto_created    BOOLEAN DEFAULT true,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- ─────────────────────────────────────────────────────────────
-- 2. Índices
-- ─────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_call_insights_call
  ON call_insights (call_id);

CREATE INDEX IF NOT EXISTS idx_call_insights_mentorado
  ON call_insights (mentorado_id)
  WHERE mentorado_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_call_insights_tipo
  ON call_insights (tipo, status);

CREATE INDEX IF NOT EXISTS idx_call_insights_pending
  ON call_insights (mentorado_id, status)
  WHERE tipo = 'action' AND status = 'pendente';

-- ─────────────────────────────────────────────────────────────
-- 3. RLS
-- ─────────────────────────────────────────────────────────────
ALTER TABLE call_insights ENABLE ROW LEVEL SECURITY;

CREATE POLICY "select_call_insights" ON call_insights
  FOR SELECT USING (true);

CREATE POLICY "insert_call_insights" ON call_insights
  FOR INSERT WITH CHECK (true);

CREATE POLICY "update_call_insights" ON call_insights
  FOR UPDATE USING (true);

-- ─────────────────────────────────────────────────────────────
-- 4. View: insights by mentorado (para detail page widget)
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_call_insights_summary AS
SELECT
  ci.mentorado_id,
  m.nome            AS mentorado_nome,
  COUNT(*)          AS total,
  COUNT(*) FILTER (WHERE ci.tipo = 'action' AND ci.status = 'pendente') AS acoes_pendentes,
  COUNT(*) FILTER (WHERE ci.tipo = 'blocker' AND ci.status = 'pendente') AS bloqueios_ativos,
  COUNT(*) FILTER (WHERE ci.tipo = 'decision') AS decisoes,
  COUNT(*) FILTER (WHERE ci.tipo = 'milestone') AS marcos,
  MAX(ci.created_at) AS ultimo_insight
FROM call_insights ci
JOIN "case".mentorados m ON m.id = ci.mentorado_id
GROUP BY ci.mentorado_id, m.nome;

GRANT SELECT ON call_insights TO anon, authenticated, service_role;
GRANT INSERT, UPDATE ON call_insights TO authenticated, service_role;
GRANT SELECT ON vw_call_insights_summary TO anon, authenticated, service_role;

COMMENT ON TABLE call_insights IS 'Insights estruturados extraídos de calls por GPT via N8N. Tipos: decision, blocker, action, feedback, milestone, risk, insight.';
