-- ============================================================
-- Migration: Mentee Groups — pasta/turma customizada
-- ============================================================

CREATE TABLE IF NOT EXISTS "case".mentee_groups (
  id          SERIAL PRIMARY KEY,
  nome        TEXT NOT NULL,
  cor         TEXT NOT NULL DEFAULT '#6366f1',
  icon        TEXT NOT NULL DEFAULT '📁',
  created_by  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "case".mentee_group_members (
  group_id   INTEGER NOT NULL REFERENCES "case".mentee_groups(id) ON DELETE CASCADE,
  mentee_id  BIGINT  NOT NULL REFERENCES "case".mentorados(id)    ON DELETE CASCADE,
  added_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (group_id, mentee_id)
);

-- Index for fast group lookup by mentee
CREATE INDEX IF NOT EXISTS idx_group_members_mentee
  ON "case".mentee_group_members (mentee_id);

-- RLS
ALTER TABLE "case".mentee_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE "case".mentee_group_members ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'case' AND tablename = 'mentee_groups' AND policyname = 'mentee_groups_all'
    ) THEN
        CREATE POLICY "mentee_groups_all"
            ON "case".mentee_groups FOR ALL USING (true) WITH CHECK (true);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'case' AND tablename = 'mentee_group_members' AND policyname = 'mentee_group_members_all'
    ) THEN
        CREATE POLICY "mentee_group_members_all"
            ON "case".mentee_group_members FOR ALL USING (true) WITH CHECK (true);
    END IF;
END $$;

-- Expose via public schema for PostgREST
CREATE OR REPLACE VIEW public.mentee_groups AS
    SELECT * FROM "case".mentee_groups;

CREATE OR REPLACE VIEW public.mentee_group_members AS
    SELECT * FROM "case".mentee_group_members;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.mentee_groups TO anon, authenticated, service_role;
GRANT SELECT, INSERT, DELETE ON public.mentee_group_members TO anon, authenticated, service_role;

COMMENT ON TABLE "case".mentee_groups IS 'Custom folders/groups to organize mentees (e.g. Turma Julho, VIPs)';
COMMENT ON TABLE "case".mentee_group_members IS 'M2M between mentee_groups and mentorados';
