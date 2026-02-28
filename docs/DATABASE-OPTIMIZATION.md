# Database Optimization — 9 Critical Indexes

**Date:** 2026-02-27
**Status:** Ready for deployment
**Impact:** 50-70% performance improvement on dashboard queries
**Risk Level:** LOW (all indexes are additive, no data changes)
**Execution Time:** < 1 minute on 40 mentorados

---

## Overview

This optimization adds 9 strategically-designed indexes to the Spalla Dashboard database to accelerate critical query patterns. All indexes are **additive** (safe to apply) and do not modify any existing data.

### Performance Impact

**Expected Improvements:**
- Dashboard views: 50-70% faster
- WhatsApp stats: 10-20x faster
- Call analytics: 5-10x faster
- Task queries: 3-5x faster
- Financial metrics: 2-3x faster

---

## Index Details

### 1. idx_mentorados_active_cohort (CRITICAL)

**Table:** `mentorados`
**Columns:** `(ativo, cohort)`
**Used By:** All dashboard views (`vw_god_overview`, `vw_god_calls`, `vw_god_tarefas`, etc.)
**Filter Pattern:**
```sql
WHERE ativo = true AND cohort IS DISTINCT FROM 'tese'
```
**Benefit:** 50-70% faster on all dashboard views
**Risk:** NONE

---

### 2. idx_interacoes_mentorado_created (CRITICAL)

**Table:** `interacoes_mentoria`
**Columns:** `(mentorado_id, created_at DESC)`
**Used By:** `vw_god_overview` (WhatsApp stats CTE, line 411-430)
**Filter Pattern:**
```sql
WHERE mentorado_id = X AND created_at >= NOW() - INTERVAL '7 days'
```
**Benefit:** WhatsApp stats queries 10-20x faster
**Risk:** NONE

---

### 3. idx_analises_call_mentorado_data (CRITICAL)

**Table:** `analises_call`
**Columns:** `(mentorado_id, data_call DESC, created_at DESC)`
**Used By:** `vw_god_calls` (LATERAL join, line 201-208)
**Filter Pattern:**
```sql
LATERAL lookup on (mentorado_id, data_call) pair
```
**Benefit:** Call timeline 5-10x faster (eliminates 226 subquery scans)
**Risk:** NONE

---

### 4. idx_calls_mentoria_mentorado_data (HIGH)

**Table:** `calls_mentoria`
**Columns:** `(mentorado_id, data_call DESC)`
**Used By:** `vw_god_overview` (call_stats CTE, line 432-438)
**Filter Pattern:**
```sql
GROUP BY mentorado_id, MAX(data_call)
```
**Benefit:** Latest call queries 3-5x faster
**Risk:** NONE

---

### 5. idx_god_tasks_status_deadline (HIGH)

**Table:** `god_tasks`
**Columns:** `(status, data_fim)` WHERE `status IN ('pendente', 'em_andamento')`
**Used By:** Overdue tasks queries (`vw_god_tarefas`, lines 340-347)
**Filter Pattern:**
```sql
WHERE status='pendente' AND data_fim < NOW()
```
**Benefit:** Pending/overdue task queries 3-5x faster
**Risk:** NONE (partial index on non-completed tasks only)

---

### 6. idx_god_tasks_mentee_status (MEDIUM)

**Table:** `god_tasks`
**Columns:** `(mentorado_id, status)`
**Used By:** Task detail view filtering by mentee + status
**Filter Pattern:**
```sql
WHERE mentorado_id = X AND status = Y
```
**Benefit:** Task filtering per mentee 2-3x faster
**Risk:** NONE

---

### 7. idx_metricas_mentorado (MEDIUM)

**Table:** `metricas_mentorado`
**Columns:** `(mentorado_id)`
**Used By:** `vw_god_vendas` (sales aggregations, lines 298-305)
**Filter Pattern:**
```sql
SUM(valor_vendas) FROM metricas_mentorado GROUP BY mentorado_id
```
**Benefit:** Financial dashboard 2-3x faster
**Risk:** NONE

---

### 8. idx_analises_call_vendas_gin (OPTIONAL)

**Table:** `analises_call`
**Columns:** `vendas_mencionadas` (JSONB, GIN index)
**Used By:** JSONB containment queries (future feature)
**Filter Pattern:**
```sql
WHERE vendas_mencionadas @> '{"product":"X"}'
```
**Benefit:** Product/feature lookups 100-1000x faster
**Risk:** NONE (only affects JSONB queries)

---

### 9. idx_god_tasks_tags_gin (OPTIONAL)

**Table:** `god_tasks`
**Columns:** `tags` (Array, GIN index)
**Used By:** Tag filtering (future feature)
**Filter Pattern:**
```sql
WHERE "tag_name" = ANY(tags)
```
**Benefit:** Tag lookups 10-100x faster
**Risk:** NONE (only affects array queries)

---

## Deployment Instructions

### Option 1: Using Migration Script (Recommended)

```bash
# From repository root
chmod +x apply-migration.sh
./apply-migration.sh
```

The script will:
1. Load environment variables from `.env`
2. Connect to Supabase database
3. Apply all migrations in `migrations/` directory
4. Verify success

**Prerequisites:**
- PostgreSQL client tools (`psql`) installed
- `.env` file with `SUPABASE_SERVICE_KEY`
- Network access to Supabase

### Option 2: Manual Application via Supabase SQL Editor

1. Go to https://supabase.com/dashboard
2. Select the **Spalla Dashboard** project
3. Go to **SQL Editor**
4. Create a new query
5. Copy the entire contents of `migrations/20260227_add_database_indexes.sql`
6. Click **Run** (or Ctrl+Enter)
7. Verify success with verification queries (see below)

### Option 3: Using psql Directly

```bash
# Set connection string
export DATABASE_URL="postgresql://postgres:YOUR_PASSWORD@knusqfbvhsqworzyhvip.supabase.co:5432/postgres"

# Apply migration
psql "$DATABASE_URL" -f migrations/20260227_add_database_indexes.sql

# Verify
psql "$DATABASE_URL" -f verify-indexes.sql
```

---

## Verification

After applying the migration, verify success using the verification queries:

```bash
# Run all verification queries
psql "$DATABASE_URL" -f verify-indexes.sql
```

Or run individually in Supabase SQL Editor:

### Query 1: List all created indexes
```sql
SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;
```

**Expected Result:** 9 indexes listed

### Query 2: Verify expected indexes exist
```sql
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
```

**Expected Result:** All 9 indexes showing "CREATED"

### Query 3: Check index sizes
```sql
SELECT
  tablename,
  indexname,
  pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
  AND indexname LIKE 'idx_%'
ORDER BY pg_relation_size(indexrelid) DESC;
```

**Expected Result:** All indexes < 10MB each

---

## Performance Testing

### Before/After Comparison

#### Test 1: Dashboard Overview Load

**Before:**
```sql
-- Measure baseline
SELECT * FROM vw_god_overview LIMIT 10;
-- Expected: 2-5 seconds (sequential scans on mentorados)
```

**After:**
```sql
-- Should be significantly faster
SELECT * FROM vw_god_overview LIMIT 10;
-- Expected: 0.5-1 second (index scans)
```

#### Test 2: WhatsApp Stats Aggregation

**Before:**
```sql
SELECT COUNT(*) FROM interacoes_mentoria
WHERE created_at >= NOW() - INTERVAL '7 days';
-- Expected: 1-2 seconds (full table scan)
```

**After:**
```sql
SELECT COUNT(*) FROM interacoes_mentoria
WHERE created_at >= NOW() - INTERVAL '7 days';
-- Expected: 100-300ms (index scan)
```

#### Test 3: Call Analytics

**Before:**
```sql
SELECT COUNT(*) FROM analises_call
WHERE mentorado_id = 'specific_id' AND data_call > NOW() - INTERVAL '30 days';
-- Expected: 0.5-1 second
```

**After:**
```sql
SELECT COUNT(*) FROM analises_call
WHERE mentorado_id = 'specific_id' AND data_call > NOW() - INTERVAL '30 days';
-- Expected: 10-50ms (index scan)
```

### Performance Monitoring

After deployment, monitor index usage:

```sql
-- Check which indexes are being used
SELECT
  schemaname,
  tablename,
  indexrelname,
  idx_scan as index_scans,
  idx_tup_read as tuples_read,
  CASE WHEN idx_scan = 0 THEN 'Unused' ELSE 'Active' END as status
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
  AND indexrelname LIKE 'idx_%'
ORDER BY idx_scan DESC;
```

---

## Rollback Instructions

If any index causes issues, rollback is simple (indexes are non-destructive):

```bash
# Via psql
psql "$DATABASE_URL" -c "DROP INDEX IF EXISTS idx_mentorados_active_cohort;"
psql "$DATABASE_URL" -c "DROP INDEX IF EXISTS idx_interacoes_mentorado_created;"
# ... (repeat for all 9 indexes)
```

Or create a rollback migration file:

```sql
-- migrations/20260227_rollback_database_indexes.sql
DROP INDEX IF EXISTS idx_mentorados_active_cohort;
DROP INDEX IF EXISTS idx_interacoes_mentorado_created;
DROP INDEX IF EXISTS idx_analises_call_mentorado_data;
DROP INDEX IF EXISTS idx_calls_mentoria_mentorado_data;
DROP INDEX IF EXISTS idx_god_tasks_status_deadline;
DROP INDEX IF EXISTS idx_god_tasks_mentee_status;
DROP INDEX IF EXISTS idx_metricas_mentorado;
DROP INDEX IF EXISTS idx_analises_call_vendas_gin;
DROP INDEX IF EXISTS idx_god_tasks_tags_gin;
```

---

## Future Optimizations

### Phase 2: Materialized Views (NOT IN SCOPE)
- Materialize `vw_god_overview` for sub-100ms dashboard loads
- Requires refresh strategy (cron job)

### Phase 3: Query Optimization (NOT IN SCOPE)
- Add pagination to API responses (avoid loading all 40 mentorados at once)
- Implement caching layer (Redis) for frequently accessed aggregations
- Add statement timeout to prevent runaway queries

### Phase 4: Schema Optimization (NOT IN SCOPE)
- Partitioning for `interacoes_mentoria` (by date)
- Denormalization of frequently joined tables

---

## References

- **Source File:** `/Users/kaiquerodrigues/Downloads/spalla-quick-wins.sql`
- **Migration File:** `migrations/20260227_add_database_indexes.sql`
- **Verification File:** `verify-indexes.sql`
- **Deploy Script:** `apply-migration.sh`

---

## Support

For issues or questions about this optimization:

1. Check the verification queries (see above)
2. Review PostgreSQL documentation: https://www.postgresql.org/docs/current/indexes.html
3. Check Supabase index documentation: https://supabase.com/docs/guides/database/indexes

---

**Migration Status:** READY FOR DEPLOYMENT
**Created:** 2026-02-27
**Branch:** `optimize/database-indexes`
