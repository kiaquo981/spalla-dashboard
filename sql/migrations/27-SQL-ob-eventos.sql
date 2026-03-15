-- ============================================================
-- ob_eventos — Timeline / Audit trail for Onboarding CS
-- Mirrors ds_eventos pattern for the Dossiê system
-- ============================================================

CREATE TABLE IF NOT EXISTS ob_eventos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  trilha_id UUID REFERENCES ob_trilhas(id) ON DELETE CASCADE,
  etapa_id UUID REFERENCES ob_etapas(id) ON DELETE SET NULL,
  tarefa_id UUID REFERENCES ob_tarefas(id) ON DELETE SET NULL,
  tipo_evento TEXT NOT NULL,
    -- tarefa_concluida | tarefa_reaberta | etapa_iniciada | etapa_concluida
    -- trilha_status | responsavel_alterado
  de_valor TEXT,
  para_valor TEXT,
  responsavel TEXT,
  descricao TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ob_eventos_trilha ON ob_eventos(trilha_id);
