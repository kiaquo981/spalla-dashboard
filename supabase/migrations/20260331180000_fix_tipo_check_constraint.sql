-- =============================================================================
-- MIGRATION: Fix CHECK constraint on mentorado_context.tipo
-- The original migration (20260326040000) constrained tipo to ('audio','texto','arquivo')
-- but migration 80 introduced new types without updating the CHECK.
-- =============================================================================

-- Drop the old CHECK constraint
ALTER TABLE mentorado_context
  DROP CONSTRAINT IF EXISTS mentorado_context_tipo_check;

-- Add expanded CHECK with all valid types
ALTER TABLE mentorado_context
  ADD CONSTRAINT mentorado_context_tipo_check
  CHECK (tipo IN ('audio', 'texto', 'arquivo', 'gravacao', 'link', 'imagem', 'video', 'documento'));

-- Add UNIQUE constraint on ativo_codigo per mentorado (prevents duplicates)
CREATE UNIQUE INDEX IF NOT EXISTS idx_ctx_ativo_codigo_unique
  ON mentorado_context (mentorado_id, ativo_codigo)
  WHERE ativo_codigo IS NOT NULL;
