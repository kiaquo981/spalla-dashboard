-- Fix RLS on god_task_field_defs — dashboard uses anon role
-- Error: "new row violates row-level security policy for table god_task_field_defs"

DROP POLICY IF EXISTS "god_task_field_defs_insert" ON god_task_field_defs;
CREATE POLICY "god_task_field_defs_insert"
  ON god_task_field_defs FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

DROP POLICY IF EXISTS "god_task_field_defs_select" ON god_task_field_defs;
CREATE POLICY "god_task_field_defs_select"
  ON god_task_field_defs FOR SELECT
  TO anon, authenticated
  USING (true);

DROP POLICY IF EXISTS "god_task_field_defs_update" ON god_task_field_defs;
CREATE POLICY "god_task_field_defs_update"
  ON god_task_field_defs FOR UPDATE
  TO anon, authenticated
  USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "god_task_field_defs_delete" ON god_task_field_defs;
CREATE POLICY "god_task_field_defs_delete"
  ON god_task_field_defs FOR DELETE
  TO anon, authenticated
  USING (is_system = false);

-- Also fix god_task_field_values
DROP POLICY IF EXISTS "god_task_field_values_select" ON god_task_field_values;
CREATE POLICY "god_task_field_values_select"
  ON god_task_field_values FOR SELECT
  TO anon, authenticated
  USING (true);

DROP POLICY IF EXISTS "god_task_field_values_insert" ON god_task_field_values;
CREATE POLICY "god_task_field_values_insert"
  ON god_task_field_values FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

DROP POLICY IF EXISTS "god_task_field_values_update" ON god_task_field_values;
CREATE POLICY "god_task_field_values_update"
  ON god_task_field_values FOR UPDATE
  TO anon, authenticated
  USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "god_task_field_values_delete" ON god_task_field_values;
CREATE POLICY "god_task_field_values_delete"
  ON god_task_field_values FOR DELETE
  TO anon, authenticated
  USING (true);

NOTIFY pgrst, 'reload schema';
