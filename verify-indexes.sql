-- Verification Queries for Database Optimization Migration
-- Run these queries to verify all 9 indexes were created successfully

-- ============================================================================
-- 1. List all new indexes created by this migration
-- ============================================================================
SELECT
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;

-- ============================================================================
-- 2. Check index sizes (should be small, < 10MB each)
-- ============================================================================
SELECT
  schemaname,
  tablename,
  indexname,
  pg_size_pretty(pg_relation_size(indexrelid)) as index_size,
  CASE WHEN pg_relation_size(indexrelid) > 10485760 THEN 'WARN: Large index' ELSE 'OK' END as status
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
  AND indexname LIKE 'idx_%'
ORDER BY pg_relation_size(indexrelid) DESC;

-- ============================================================================
-- 3. Verify all 9 expected indexes exist
-- ============================================================================
WITH expected_indexes AS (
  SELECT 'idx_mentorados_active_cohort' as idx_name
  UNION ALL SELECT 'idx_interacoes_mentorado_created'
  UNION ALL SELECT 'idx_analises_call_mentorado_data'
  UNION ALL SELECT 'idx_calls_mentoria_mentorado_data'
  UNION ALL SELECT 'idx_god_tasks_status_deadline'
  UNION ALL SELECT 'idx_god_tasks_mentee_status'
  UNION ALL SELECT 'idx_metricas_mentorado'
  UNION ALL SELECT 'idx_analises_call_vendas_gin'
  UNION ALL SELECT 'idx_god_tasks_tags_gin'
),
created_indexes AS (
  SELECT DISTINCT indexname
  FROM pg_indexes
  WHERE schemaname = 'public'
)
SELECT
  e.idx_name,
  CASE WHEN c.indexname IS NOT NULL THEN 'CREATED' ELSE 'MISSING' END as status
FROM expected_indexes e
LEFT JOIN created_indexes c ON e.idx_name = c.indexname
ORDER BY e.idx_name;

-- ============================================================================
-- 4. Check if indexes are being used (sequential_scans = 0 for optimized)
-- ============================================================================
SELECT
  schemaname,
  tablename,
  indexrelname as indexname,
  idx_scan as index_scans,
  idx_tup_read as tuples_read,
  idx_tup_fetch as tuples_fetched,
  CASE WHEN idx_scan = 0 THEN 'Not used yet (new)' ELSE 'Being used' END as usage_status
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
  AND indexrelname LIKE 'idx_%'
ORDER BY idx_scan DESC, tablename, indexrelname;

-- ============================================================================
-- 5. Sample query performance analysis (if tables have data)
-- ============================================================================
-- Check for sequential scans on tables with new indexes
SELECT
  schemaname,
  tablename,
  seq_scan,
  seq_tup_read,
  idx_scan,
  ROUND(100 * idx_scan / NULLIF(seq_scan + idx_scan, 0), 2) as pct_index_scans
FROM pg_stat_user_tables
WHERE schemaname = 'public'
  AND tablename IN ('mentorados', 'interacoes_mentoria', 'analises_call', 'calls_mentoria', 'god_tasks', 'metricas_mentorado')
ORDER BY tablename;
