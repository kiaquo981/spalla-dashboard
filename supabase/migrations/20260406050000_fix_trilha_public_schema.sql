-- =============================================================================
-- HOTFIX: Expose trilha in public.mentorados view
-- public.mentorados is a VIEW that was created with SELECT * before trilha existed
-- DROP and recreate to pick up new columns
-- =============================================================================

-- Drop and recreate to pick up trilha column
DROP VIEW IF EXISTS public.mentorados CASCADE;
CREATE VIEW public.mentorados AS SELECT * FROM "case".mentorados;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.mentorados TO authenticated;
GRANT SELECT ON public.mentorados TO anon;

-- Force schema cache reload
NOTIFY pgrst, 'reload schema';
