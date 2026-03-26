-- Fix spalla_members RLS: allow anon/authenticated to read members
-- Currently blocks anon key, so frontend dropdown shows empty

ALTER TABLE spalla_members ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "anon_read_members" ON spalla_members FOR SELECT TO anon USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "auth_read_members" ON spalla_members FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
