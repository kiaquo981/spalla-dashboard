-- ================================================================
-- Migration: RLS policies para bucket dossie-briefings
-- Data: 2026-03-24
-- Contexto:
--   Bucket criado via dashboard. Precisa de policies para
--   permitir upload/download via anon key.
-- ================================================================

-- Allow uploads
DO $$ BEGIN
  CREATE POLICY "dossie_briefings_insert"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'dossie-briefings');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Allow reads
DO $$ BEGIN
  CREATE POLICY "dossie_briefings_select"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'dossie-briefings');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Allow deletes
DO $$ BEGIN
  CREATE POLICY "dossie_briefings_delete"
    ON storage.objects FOR DELETE
    USING (bucket_id = 'dossie-briefings');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Allow updates (for overwrite)
DO $$ BEGIN
  CREATE POLICY "dossie_briefings_update"
    ON storage.objects FOR UPDATE
    USING (bucket_id = 'dossie-briefings');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
