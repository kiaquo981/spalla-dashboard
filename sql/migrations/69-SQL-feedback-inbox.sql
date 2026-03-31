-- ============================================================
-- TASK-10: Feedback / Bug Report Inbox
-- Separado do board de tarefas
-- Date: 2026-03-30
-- ============================================================

CREATE TABLE IF NOT EXISTS god_feedback (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  titulo TEXT NOT NULL,
  descricao TEXT,
  categoria TEXT DEFAULT 'bug' CHECK (categoria IN ('bug', 'sugestao', 'feature', 'outro')),
  prioridade TEXT DEFAULT 'normal' CHECK (prioridade IN ('baixa', 'normal', 'alta', 'urgente')),
  status TEXT DEFAULT 'novo' CHECK (status IN ('novo', 'em_analise', 'convertido', 'descartado')),
  media_urls TEXT[] DEFAULT '{}',
  created_by TEXT DEFAULT 'equipe',
  converted_task_id UUID REFERENCES god_tasks(id) ON DELETE SET NULL,
  descarte_motivo TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Index for filtering
CREATE INDEX IF NOT EXISTS idx_god_feedback_status ON god_feedback(status);
CREATE INDEX IF NOT EXISTS idx_god_feedback_categoria ON god_feedback(categoria);

-- RLS
ALTER TABLE god_feedback ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "god_feedback: leitura autenticados" ON god_feedback;
CREATE POLICY "god_feedback: leitura autenticados" ON god_feedback FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "god_feedback: escrita autenticados" ON god_feedback;
CREATE POLICY "god_feedback: escrita autenticados" ON god_feedback FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_god_feedback_updated_at()
RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_god_feedback_updated_at ON god_feedback;
CREATE TRIGGER trg_god_feedback_updated_at BEFORE UPDATE ON god_feedback FOR EACH ROW EXECUTE FUNCTION update_god_feedback_updated_at();
