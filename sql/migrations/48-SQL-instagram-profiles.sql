-- ============================================================
-- Operon Dashboard — Instagram Profile Columns
-- 2026-03-12
-- ============================================================
-- OBJETIVO:
-- Adicionar colunas de perfil Instagram em mentorados para
-- substituir hardcoded igPhoto() com dados reais da tabela
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. Colunas Instagram em mentorados (schema "case")
-- ─────────────────────────────────────────────────────────────
ALTER TABLE "case".mentorados
  ADD COLUMN IF NOT EXISTS instagram_username    TEXT,
  ADD COLUMN IF NOT EXISTS instagram_photo_url   TEXT,
  ADD COLUMN IF NOT EXISTS instagram_followers   INTEGER,
  ADD COLUMN IF NOT EXISTS instagram_following   INTEGER,
  ADD COLUMN IF NOT EXISTS instagram_posts       INTEGER,
  ADD COLUMN IF NOT EXISTS instagram_bio         TEXT,
  ADD COLUMN IF NOT EXISTS instagram_full_name   TEXT,
  ADD COLUMN IF NOT EXISTS instagram_last_sync   TIMESTAMPTZ;

-- ─────────────────────────────────────────────────────────────
-- 2. Índice para lookup por username
-- ─────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_mentorados_ig_username
  ON "case".mentorados (instagram_username)
  WHERE instagram_username IS NOT NULL;

-- ─────────────────────────────────────────────────────────────
-- 3. View helper — mentorados com dados IG
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_mentorados_ig AS
SELECT
  id,
  nome,
  instagram_username,
  instagram_photo_url,
  instagram_followers,
  instagram_following,
  instagram_posts,
  instagram_bio,
  instagram_full_name,
  instagram_last_sync,
  -- Computed: dias desde último sync
  CASE
    WHEN instagram_last_sync IS NULL THEN NULL
    ELSE EXTRACT(EPOCH FROM (now() - instagram_last_sync)) / 86400
  END AS dias_desde_sync
FROM "case".mentorados
WHERE instagram_username IS NOT NULL;

GRANT SELECT ON vw_mentorados_ig TO anon, authenticated, service_role;

COMMENT ON VIEW vw_mentorados_ig IS 'Mentorados com dados de perfil Instagram. Atualizado via N8N workflow.';
