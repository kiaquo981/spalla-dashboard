-- =============================================================================
-- MIGRATION: Add constraints to card_comments (polymorphic FK validation)
-- =============================================================================

-- Ensure exactly one FK is set (polymorphic comments)
ALTER TABLE card_comments
  ADD CONSTRAINT card_comments_exactly_one_fk
  CHECK (num_nonnulls(producao_id, documento_id, mentorado_id) = 1);

-- Add FK on mentorado_id (was missing — producao_id and documento_id had FKs)
ALTER TABLE card_comments
  ADD CONSTRAINT card_comments_mentorado_id_fkey
  FOREIGN KEY (mentorado_id) REFERENCES mentorados(id) ON DELETE CASCADE;
