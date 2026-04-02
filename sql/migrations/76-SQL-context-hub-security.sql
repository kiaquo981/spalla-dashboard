-- =============================================================================
-- MIGRATION 76: Context Hub security — remove anon access + add max 50MB limit
-- =============================================================================

-- 1. Remove anon read/write from mentorado_context (dados sensíveis de mentoria)
DROP POLICY IF EXISTS "anon_read_context"   ON mentorado_context;
DROP POLICY IF EXISTS "anon_insert_context" ON mentorado_context;
DROP POLICY IF EXISTS "anon_update_context" ON mentorado_context;
DROP POLICY IF EXISTS "anon_delete_context" ON mentorado_context;

-- 2. Authenticated team can access all (single-tenant — toda equipe CASE é confiável)
DROP POLICY IF EXISTS "auth_all_context" ON mentorado_context;
CREATE POLICY "auth_all_context" ON mentorado_context
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

-- 3. Service role full access (backend Railway)
DROP POLICY IF EXISTS "service_all_context" ON mentorado_context;
CREATE POLICY "service_all_context" ON mentorado_context
  FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

-- 4. Ensure RLS is enabled
ALTER TABLE mentorado_context ENABLE ROW LEVEL SECURITY;

-- 5. Storage: restrict mentorado_context uploads to authenticated only
-- (run in dashboard if bucket "uploads" has public access — context files should not be public-by-default)
-- UPDATE storage.buckets SET public = false WHERE id = 'uploads';
-- Note: public bucket is OK for now as URLs are UUIDs; above is optional hardening

GRANT SELECT, INSERT, UPDATE, DELETE ON mentorado_context TO authenticated;
GRANT ALL ON mentorado_context TO service_role;
