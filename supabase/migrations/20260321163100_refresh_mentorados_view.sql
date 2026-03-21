-- =====================================================
-- S8 patch — Refresh public.mentorados view
-- Adds snoozed_until to the view after column was added
-- to "case".mentorados in 20260321163000
-- =====================================================

-- Rebuild view so PostgreSQL re-expands SELECT * and picks up new column
CREATE OR REPLACE VIEW public.mentorados AS
    SELECT * FROM "case".mentorados;
