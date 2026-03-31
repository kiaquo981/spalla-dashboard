-- =============================================================================
-- MIGRATION 77: Create uploads bucket + expand context categories
-- =============================================================================

-- 1. Create 'uploads' storage bucket (if not exists)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'uploads',
  'uploads',
  true,
  104857600,  -- 100 MB
  NULL        -- allow all mime types
)
ON CONFLICT (id) DO NOTHING;

-- 2. Storage policies: authenticated can upload/read, service_role full access
DROP POLICY IF EXISTS "auth_upload" ON storage.objects;
CREATE POLICY "auth_upload" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'uploads');

DROP POLICY IF EXISTS "auth_read_uploads" ON storage.objects;
CREATE POLICY "auth_read_uploads" ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'uploads');

DROP POLICY IF EXISTS "public_read_uploads" ON storage.objects;
CREATE POLICY "public_read_uploads" ON storage.objects
  FOR SELECT TO anon
  USING (bucket_id = 'uploads');

DROP POLICY IF EXISTS "service_all_uploads" ON storage.objects;
CREATE POLICY "service_all_uploads" ON storage.objects
  FOR ALL TO service_role
  USING (bucket_id = 'uploads')
  WITH CHECK (bucket_id = 'uploads');

-- 3. Add check constraint for valid fase values (informational, not blocking)
-- The frontend now supports these categories:
-- Jornada: onboarding, travas, momentos, acoes
-- Dossies: dossie_oferta, dossie_posicionamento, dossie_funil
-- Operacional: funil_novo, campanha, conteudo, financeiro, geral
COMMENT ON COLUMN mentorado_context.fase IS 'Categories: onboarding, travas, momentos, acoes, dossie_oferta, dossie_posicionamento, dossie_funil, funil_novo, campanha, conteudo, financeiro, geral';
