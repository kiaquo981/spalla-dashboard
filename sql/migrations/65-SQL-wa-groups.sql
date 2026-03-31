-- ============================================================
-- Spalla Dashboard — WhatsApp Group Management
-- Story: WA-EPIC Story 8 | 2026-03-28
-- ============================================================

-- ------------------------------------------------------------
-- 1. wa_groups table — tracks WhatsApp groups linked to mentorados
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wa_groups (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_jid       TEXT NOT NULL UNIQUE,
  mentorado_id    BIGINT,  -- references case.mentorados(id) but no FK (mentorados is a view in public schema)
  name            TEXT NOT NULL,
  description     TEXT,
  participant_count INT NOT NULL DEFAULT 0,
  participants    JSONB DEFAULT '[]'::jsonb,
  photo_url       TEXT,
  instance_name   TEXT,
  is_active       BOOLEAN NOT NULL DEFAULT true,
  last_activity   TIMESTAMPTZ,
  synced_at       TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE wa_groups IS 'WhatsApp groups tracked by the dashboard, linked to mentorados';
COMMENT ON COLUMN wa_groups.group_jid IS 'WhatsApp group JID: 120363XXXXX@g.us';
COMMENT ON COLUMN wa_groups.participants IS 'JSON array of { jid, name, isAdmin } from Evolution API';

-- Indexes
CREATE INDEX IF NOT EXISTS idx_wa_groups_mentorado ON wa_groups (mentorado_id);
CREATE INDEX IF NOT EXISTS idx_wa_groups_jid ON wa_groups (group_jid);

-- RLS
ALTER TABLE wa_groups ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'wa_groups' AND policyname = 'wa_groups_anon_select') THEN
    CREATE POLICY wa_groups_anon_select ON wa_groups FOR SELECT USING (true);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'wa_groups' AND policyname = 'wa_groups_anon_all') THEN
    CREATE POLICY wa_groups_anon_all ON wa_groups FOR ALL USING (true);
  END IF;
END $$;

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE wa_groups;
