-- ============================================================
-- Full-text search + Saved Views
-- ============================================================

-- 1. Trigram extension for fuzzy search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 2. GIN index on titulo for fast search
CREATE INDEX IF NOT EXISTS idx_god_tasks_titulo_trgm ON god_tasks USING GIN (titulo gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_god_tasks_descricao_trgm ON god_tasks USING GIN (descricao gin_trgm_ops);

-- 3. Saved Views table
CREATE TABLE IF NOT EXISTS god_saved_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  view_type TEXT NOT NULL DEFAULT 'list' CHECK (view_type IN ('list', 'board', 'calendar', 'gantt')),
  space_id VARCHAR(50) REFERENCES god_spaces(id),
  config JSONB NOT NULL DEFAULT '{}',
  -- config contains: { groupBy, filters, visibleColumns, sortBy, sortDir }
  is_default BOOLEAN DEFAULT false,
  is_pinned BOOLEAN DEFAULT false,
  created_by TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_saved_views_space ON god_saved_views(space_id);

ALTER TABLE god_saved_views ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "saved_views_all" ON god_saved_views;
CREATE POLICY "saved_views_all" ON god_saved_views FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

NOTIFY pgrst, 'reload schema';
