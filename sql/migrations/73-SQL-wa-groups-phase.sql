-- ============================================================
-- Grupos WA em pastas/fase
-- Date: 2026-03-30
-- ============================================================

ALTER TABLE wa_groups
ADD COLUMN IF NOT EXISTS fase TEXT DEFAULT 'geral' CHECK (fase IN ('geral', 'onboarding', 'acompanhamento', 'producao', 'entrega', 'pos_entrega', 'interno')),
ADD COLUMN IF NOT EXISTS folder TEXT DEFAULT NULL;

COMMENT ON COLUMN wa_groups.fase IS 'Fase do mentorado: organiza grupos em pastas visuais no frontend';
COMMENT ON COLUMN wa_groups.folder IS 'Pasta customizada (se não usar fase automática)';

CREATE INDEX IF NOT EXISTS idx_wa_groups_fase ON wa_groups(fase);
