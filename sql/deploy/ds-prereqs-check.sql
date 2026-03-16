-- =====================================================
-- DOSSIÊ PRODUCTION SYSTEM — Pre-requisites Check
-- Execute via: supabase db execute --project-ref knusqfbvhsqworzyhvip
-- =====================================================

-- Q1: Confirmar tabela mentorados existe e tem dados
SELECT COUNT(*) as mentorados_count FROM "case".mentorados;

-- Q2: Listar colunas de god_tasks (verificar auto_created, fonte, space_id, list_id)
SELECT column_name FROM information_schema.columns
WHERE table_name = 'god_tasks' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Q3: Confirmar ds_producoes NAO existe
SELECT EXISTS (
  SELECT FROM information_schema.tables
  WHERE table_name = 'ds_producoes' AND table_schema = 'public'
) as ds_producoes_exists;

-- Q4: Confirmar ds_documentos NAO existe
SELECT EXISTS (
  SELECT FROM information_schema.tables
  WHERE table_name = 'ds_documentos' AND table_schema = 'public'
) as ds_documentos_exists;

-- Q5: Sample de nomes para validar ILIKE do seed
SELECT nome FROM "case".mentorados ORDER BY nome LIMIT 10;

-- Q6: Confirmar UUID generation funciona
SELECT EXISTS (
  SELECT FROM pg_extension WHERE extname = 'uuid-ossp'
) OR EXISTS (
  SELECT FROM pg_proc WHERE proname = 'gen_random_uuid'
) as uuid_available;
