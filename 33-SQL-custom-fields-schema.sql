-- ============================================================
-- Spalla Dashboard — Custom Fields Engine Schema
-- Story: T-02-01 | 2026-03-11
-- ============================================================

-- ------------------------------------------------------------
-- 1. Field definitions
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS god_task_field_defs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,

  -- Field types:
  -- text | number | date | select | multi_select
  -- checkbox | url | user | progress | rating
  field_type  TEXT NOT NULL,

  -- Scope:
  -- 'global'
  -- 'space:space_jornada' | 'space:space_gestao'
  -- 'list:list_onboarding' | 'list:list_operacional' etc.
  scope       TEXT NOT NULL DEFAULT 'global',

  -- For select / multi_select: array of option objects
  -- [{ "id": "uuid", "label": "Nome", "color": "#hex" }]
  options     JSONB,

  -- Extra config by type:
  -- number: { "unit": "horas", "min": 0, "max": 999 }
  -- rating: { "max": 5 }
  -- date:   { "format": "DD/MM/YYYY" }
  -- general: { "hidden": false, "placeholder": "..." }
  config      JSONB DEFAULT '{}'::jsonb,

  sort_order  INT NOT NULL DEFAULT 0,
  is_system   BOOLEAN NOT NULL DEFAULT false,
  created_by  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT god_task_field_defs_type_check
    CHECK (field_type IN (
      'text', 'number', 'date', 'select', 'multi_select',
      'checkbox', 'url', 'user', 'progress', 'rating'
    ))
);

COMMENT ON TABLE god_task_field_defs IS 'Custom field definitions scoped to global, space or list';
COMMENT ON COLUMN god_task_field_defs.field_type IS 'text|number|date|select|multi_select|checkbox|url|user|progress|rating';
COMMENT ON COLUMN god_task_field_defs.scope IS 'global | space:{id} | list:{id}';
COMMENT ON COLUMN god_task_field_defs.options IS 'Array of { id, label, color } for select/multi_select fields';
COMMENT ON COLUMN god_task_field_defs.config IS 'Type-specific configuration: unit, min, max, hidden, placeholder etc.';

-- ------------------------------------------------------------
-- 2. Field values per task
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS god_task_field_values (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id    UUID NOT NULL REFERENCES god_tasks(id) ON DELETE CASCADE,
  field_id   UUID NOT NULL REFERENCES god_task_field_defs(id) ON DELETE CASCADE,

  -- Flexible value store by type:
  -- text:         { "v": "string" }
  -- number:       { "v": 42 }
  -- date:         { "v": "2026-03-15" }
  -- select:       { "v": "option_id" }
  -- multi_select: { "v": ["option_id_1", "option_id_2"] }
  -- checkbox:     { "v": true }
  -- url:          { "v": "https://..." }
  -- user:         { "v": "kaique" }
  -- progress:     { "v": 75 }
  -- rating:       { "v": 4 }
  value      JSONB NOT NULL DEFAULT '{}'::jsonb,

  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT god_task_field_values_unique UNIQUE (task_id, field_id)
);

COMMENT ON TABLE god_task_field_values IS 'Custom field values per task — value stored as JSONB { v: <value> }';

-- ------------------------------------------------------------
-- 3. Indexes
-- ------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_god_task_field_defs_scope
  ON god_task_field_defs (scope);

CREATE INDEX IF NOT EXISTS idx_god_task_field_defs_sort
  ON god_task_field_defs (sort_order);

CREATE INDEX IF NOT EXISTS idx_god_task_field_values_task
  ON god_task_field_values (task_id);

CREATE INDEX IF NOT EXISTS idx_god_task_field_values_field
  ON god_task_field_values (field_id);

-- ------------------------------------------------------------
-- 4. RLS Policies
-- ------------------------------------------------------------
ALTER TABLE god_task_field_defs ENABLE ROW LEVEL SECURITY;
ALTER TABLE god_task_field_values ENABLE ROW LEVEL SECURITY;

-- Field defs: all authenticated can read
CREATE POLICY "god_task_field_defs_select"
  ON god_task_field_defs FOR SELECT
  TO authenticated
  USING (true);

-- Field defs: authenticated can insert (create new fields)
CREATE POLICY "god_task_field_defs_insert"
  ON god_task_field_defs FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Field defs: only non-system can be updated
CREATE POLICY "god_task_field_defs_update"
  ON god_task_field_defs FOR UPDATE
  TO authenticated
  USING (is_system = false)
  WITH CHECK (is_system = false);

-- Field defs: only non-system can be deleted
CREATE POLICY "god_task_field_defs_delete"
  ON god_task_field_defs FOR DELETE
  TO authenticated
  USING (is_system = false);

-- Field values: full access for authenticated
CREATE POLICY "god_task_field_values_select"
  ON god_task_field_values FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "god_task_field_values_insert"
  ON god_task_field_values FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "god_task_field_values_update"
  ON god_task_field_values FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "god_task_field_values_delete"
  ON god_task_field_values FOR DELETE
  TO authenticated
  USING (true);

-- ------------------------------------------------------------
-- 5. Function: get applicable fields for a task context
--    Returns field defs + current value for given task
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_task_fields(
  p_task_id  UUID,
  p_space_id TEXT DEFAULT NULL,
  p_list_id  TEXT DEFAULT NULL
)
RETURNS TABLE (
  field_id    UUID,
  field_name  TEXT,
  field_type  TEXT,
  scope       TEXT,
  options     JSONB,
  config      JSONB,
  sort_order  INT,
  is_system   BOOLEAN,
  value       JSONB
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    fd.id          AS field_id,
    fd.name        AS field_name,
    fd.field_type,
    fd.scope,
    fd.options,
    fd.config,
    fd.sort_order,
    fd.is_system,
    COALESCE(fv.value, '{}'::jsonb) AS value
  FROM god_task_field_defs fd
  LEFT JOIN god_task_field_values fv
    ON fv.field_id = fd.id
   AND fv.task_id = p_task_id
  WHERE
    -- Global fields always included
    fd.scope = 'global'
    -- Space-scoped fields if space_id matches
    OR (p_space_id IS NOT NULL AND fd.scope = 'space:' || p_space_id)
    -- List-scoped fields if list_id matches
    OR (p_list_id IS NOT NULL  AND fd.scope = 'list:'  || p_list_id)
    -- Exclude hidden fields
    AND COALESCE((fd.config->>'hidden')::boolean, false) = false
  ORDER BY
    -- Space fields first, then list, then global
    CASE
      WHEN p_list_id  IS NOT NULL AND fd.scope = 'list:'  || p_list_id  THEN 1
      WHEN p_space_id IS NOT NULL AND fd.scope = 'space:' || p_space_id THEN 2
      ELSE 3
    END,
    fd.sort_order;
$$;

-- ------------------------------------------------------------
-- 5b. Grant execute permissions on the function
-- ------------------------------------------------------------
GRANT EXECUTE ON FUNCTION get_task_fields(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_task_fields(UUID, TEXT, TEXT) TO anon;

-- ------------------------------------------------------------
-- 6. Update vw_god_tasks_full to include custom field values
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

  -- Custom field values
  COALESCE(
    (
      SELECT jsonb_agg(
        jsonb_build_object(
          'field_id',   fv.field_id,
          'field_name', fd.name,
          'field_type', fd.field_type,
          'value',      fv.value
        ) ORDER BY fd.sort_order
      )
      FROM god_task_field_values fv
      JOIN god_task_field_defs fd ON fd.id = fv.field_id
      WHERE fv.task_id = t.id
    ),
    '[]'::jsonb
  ) AS custom_fields_json,

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
