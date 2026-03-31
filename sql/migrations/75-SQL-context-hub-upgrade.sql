-- =============================================================================
-- MIGRATION 75: Context Hub upgrade — transcricao, link_url, tipo gravacao
-- =============================================================================

-- Add transcricao column (Whisper output)
ALTER TABLE mentorado_context ADD COLUMN IF NOT EXISTS transcricao TEXT;

-- Add link_url column (for link tipo)
ALTER TABLE mentorado_context ADD COLUMN IF NOT EXISTS link_url TEXT;

-- Update tipo CHECK constraint to include link and gravacao
ALTER TABLE mentorado_context DROP CONSTRAINT IF EXISTS mentorado_context_tipo_check;
ALTER TABLE mentorado_context ADD CONSTRAINT mentorado_context_tipo_check
  CHECK (tipo IN ('audio', 'texto', 'arquivo', 'link', 'gravacao'));

GRANT SELECT, INSERT, UPDATE ON mentorado_context TO authenticated, anon;
