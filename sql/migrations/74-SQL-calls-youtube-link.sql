-- ============================================================
-- Zoom → YouTube: campo link_youtube em calls_mentoria
-- Date: 2026-03-30
-- ============================================================

ALTER TABLE calls_mentoria
ADD COLUMN IF NOT EXISTS link_youtube TEXT DEFAULT NULL;

COMMENT ON COLUMN calls_mentoria.link_youtube IS 'URL do YouTube após upload automático via n8n (Zoom Recording → YouTube workflow)';
