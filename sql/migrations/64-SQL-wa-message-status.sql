-- ============================================================
-- Spalla Dashboard — WhatsApp Message Status Tracking
-- Story: WA-EPIC Story 2 | 2026-03-28
-- ============================================================

-- ------------------------------------------------------------
-- 1. Add status columns to wa_messages
-- ------------------------------------------------------------
ALTER TABLE wa_messages
  ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'sent',
  ADD COLUMN IF NOT EXISTS status_updated_at TIMESTAMPTZ;

-- Constraint: valid status values
-- sent → delivered → read | failed
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'wa_messages_status_check'
  ) THEN
    ALTER TABLE wa_messages
      ADD CONSTRAINT wa_messages_status_check
      CHECK (status IN ('pending', 'sent', 'delivered', 'read', 'failed'));
  END IF;
END $$;

-- Index for status queries (unread count, etc.)
CREATE INDEX IF NOT EXISTS idx_wa_messages_status
  ON wa_messages (group_jid, status, timestamp DESC);

-- ------------------------------------------------------------
-- 2. Enable Realtime on wa_messages
-- ------------------------------------------------------------
-- Supabase Realtime requires the table to be in the publication
ALTER PUBLICATION supabase_realtime ADD TABLE wa_messages;

-- ------------------------------------------------------------
-- 3. RLS policy for anon read (frontend uses anon key)
-- ------------------------------------------------------------
-- Check if RLS is enabled; if not, enable it
ALTER TABLE wa_messages ENABLE ROW LEVEL SECURITY;

-- Allow anon to SELECT (read messages in frontend)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'wa_messages' AND policyname = 'wa_messages_anon_select'
  ) THEN
    CREATE POLICY wa_messages_anon_select ON wa_messages
      FOR SELECT USING (true);
  END IF;
END $$;

-- Allow anon to INSERT (frontend sends messages via Supabase)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'wa_messages' AND policyname = 'wa_messages_anon_insert'
  ) THEN
    CREATE POLICY wa_messages_anon_insert ON wa_messages
      FOR INSERT WITH CHECK (is_from_team = true);
  END IF;
END $$;

-- Allow service_role full access (backend webhook updates status)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'wa_messages' AND policyname = 'wa_messages_service_all'
  ) THEN
    CREATE POLICY wa_messages_service_all ON wa_messages
      FOR ALL USING (auth.role() = 'service_role');
  END IF;
END $$;

-- ------------------------------------------------------------
-- 4. Backfill: mark existing messages as 'sent' (already default)
-- ------------------------------------------------------------
UPDATE wa_messages SET status = 'sent' WHERE status IS NULL;
