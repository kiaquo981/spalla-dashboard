-- ============================================================
-- Spalla Dashboard — Tags System Schema
-- Story: T-01-01 | 2026-03-11
-- ============================================================

-- ------------------------------------------------------------
-- 1. Tags definitions table
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS god_task_tags (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  color       TEXT NOT NULL DEFAULT '#6366f1',
  scope       TEXT NOT NULL DEFAULT 'global',
  -- 'global' | 'space:space_jornada' | 'space:space_gestao'
  -- | 'list:list_onboarding' etc.
  is_system   BOOLEAN NOT NULL DEFAULT false,
  created_by  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT god_task_tags_name_key UNIQUE (name)
);

COMMENT ON TABLE god_task_tags IS 'Tag definitions for tasks — global or scoped to space/list';
COMMENT ON COLUMN god_task_tags.scope IS 'Scope: global | space:{space_id} | list:{list_id}';
COMMENT ON COLUMN god_task_tags.is_system IS 'System tags cannot be deleted via UI';

-- ------------------------------------------------------------
-- 2. Task <-> Tag relation (replaces tags TEXT[] in god_tasks)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS god_task_tag_relations (
  task_id UUID NOT NULL REFERENCES god_tasks(id) ON DELETE CASCADE,
  tag_id  UUID NOT NULL REFERENCES god_task_tags(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  PRIMARY KEY (task_id, tag_id)
);

COMMENT ON TABLE god_task_tag_relations IS 'Many-to-many relation between tasks and tags';

-- ------------------------------------------------------------
-- 3. Indexes
-- ------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_god_task_tags_scope
  ON god_task_tags (scope);

CREATE INDEX IF NOT EXISTS idx_god_task_tag_relations_task
  ON god_task_tag_relations (task_id);

CREATE INDEX IF NOT EXISTS idx_god_task_tag_relations_tag
  ON god_task_tag_relations (tag_id);

-- ------------------------------------------------------------
-- 4. RLS Policies
-- ------------------------------------------------------------
ALTER TABLE god_task_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE god_task_tag_relations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "god_task_tags_select" ON god_task_tags;
DROP POLICY IF EXISTS "god_task_tags_insert" ON god_task_tags;
DROP POLICY IF EXISTS "god_task_tags_update" ON god_task_tags;
DROP POLICY IF EXISTS "god_task_tags_delete" ON god_task_tags;
DROP POLICY IF EXISTS "god_task_tag_relations_select" ON god_task_tag_relations;
DROP POLICY IF EXISTS "god_task_tag_relations_insert" ON god_task_tag_relations;
DROP POLICY IF EXISTS "god_task_tag_relations_delete" ON god_task_tag_relations;

-- Tags: anyone authenticated can read
CREATE POLICY "god_task_tags_select"
  ON god_task_tags FOR SELECT
  TO authenticated
  USING (true);

-- Tags: anyone authenticated can insert
CREATE POLICY "god_task_tags_insert"
  ON god_task_tags FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Tags: only non-system tags can be updated by authenticated users
CREATE POLICY "god_task_tags_update"
  ON god_task_tags FOR UPDATE
  TO authenticated
  USING (is_system = false)
  WITH CHECK (is_system = false);

-- Tags: only non-system tags can be deleted
CREATE POLICY "god_task_tags_delete"
  ON god_task_tags FOR DELETE
  TO authenticated
  USING (is_system = false);

-- Tag relations: full access for authenticated
CREATE POLICY "god_task_tag_relations_select"
  ON god_task_tag_relations FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "god_task_tag_relations_insert"
  ON god_task_tag_relations FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "god_task_tag_relations_delete"
  ON god_task_tag_relations FOR DELETE
  TO authenticated
  USING (true);

-- ------------------------------------------------------------
-- 5. Migration: copy existing TEXT[] tags to new model
--    Run ONLY if god_tasks.tags TEXT[] has data
-- ------------------------------------------------------------
DO $$
DECLARE
  r RECORD;
  tag_name TEXT;
  tag_id UUID;
BEGIN
  -- For each task that has tags in the old TEXT[] column
  FOR r IN
    SELECT id, tags
    FROM god_tasks
    WHERE tags IS NOT NULL AND array_length(tags, 1) > 0
  LOOP
    -- For each tag string in the array
    FOREACH tag_name IN ARRAY r.tags
    LOOP
      tag_name := trim(tag_name);
      CONTINUE WHEN tag_name = '';

      -- Insert tag if not exists
      INSERT INTO god_task_tags (name, color, scope, is_system)
      VALUES (tag_name, '#94a3b8', 'global', false)
      ON CONFLICT (name) DO NOTHING;

      -- Get tag id
      SELECT id INTO tag_id FROM god_task_tags WHERE name = tag_name;

      -- Create relation
      INSERT INTO god_task_tag_relations (task_id, tag_id)
      VALUES (r.id, tag_id)
      ON CONFLICT DO NOTHING;
    END LOOP;
  END LOOP;

  RAISE NOTICE 'Migration complete: old TEXT[] tags migrated to relational model';
END;
$$;

-- ------------------------------------------------------------
-- 6. Update vw_god_tasks_full to include tags with id + color
-- ------------------------------------------------------------
DROP VIEW IF EXISTS vw_god_tasks_full;
CREATE VIEW vw_god_tasks_full AS
SELECT
  t.*,

  -- Tags as JSON array with id, name, color
  COALESCE(
    (
      SELECT jsonb_agg(
        jsonb_build_object(
          'id',    tg.id,
          'name',  tg.name,
          'color', tg.color
        ) ORDER BY tg.name
      )
      FROM god_task_tag_relations tr
      JOIN god_task_tags tg ON tg.id = tr.tag_id
      WHERE tr.task_id = t.id
    ),
    '[]'::jsonb
  ) AS tags_full,

  -- Subtasks
  COALESCE(
    (
      SELECT jsonb_agg(
        jsonb_build_object(
          'id',         s.id,
          'texto',      s.texto,
          'done',       s.done,
          'sort_order', s.sort_order
        ) ORDER BY s.sort_order
      )
      FROM god_task_subtasks s
      WHERE s.task_id = t.id
    ),
    '[]'::jsonb
  ) AS subtasks_json,

  -- Checklist
  COALESCE(
    (
      SELECT jsonb_agg(
        jsonb_build_object(
          'id',         c.id,
          'texto',      c.texto,
          'done',       c.done,
          'sort_order', c.sort_order
        ) ORDER BY c.sort_order
      )
      FROM god_task_checklist c
      WHERE c.task_id = t.id
    ),
    '[]'::jsonb
  ) AS checklist_json,

  -- Comments
  COALESCE(
    (
      SELECT jsonb_agg(
        jsonb_build_object(
          'id',         cm.id,
          'author',     cm.author,
          'texto',      cm.texto,
          'created_at', cm.created_at
        ) ORDER BY cm.created_at
      )
      FROM god_task_comments cm
      WHERE cm.task_id = t.id
    ),
    '[]'::jsonb
  ) AS comments_json,

  -- Handoffs
  COALESCE(
    (
      SELECT jsonb_agg(
        jsonb_build_object(
          'id',          h.id,
          'from_person', h.from_person,
          'to_person',   h.to_person,
          'note',        h.note,
          'created_at',  h.created_at
        ) ORDER BY h.created_at
      )
      FROM god_task_handoffs h
      WHERE h.task_id = t.id
    ),
    '[]'::jsonb
  ) AS handoffs_json

FROM god_tasks t;

-- ------------------------------------------------------------
-- 7. NOTE: After confirming migration, you may drop old column:
--    ALTER TABLE god_tasks DROP COLUMN IF EXISTS tags;
--    (Do NOT run until frontend is updated to use tags_full)
-- ------------------------------------------------------------
