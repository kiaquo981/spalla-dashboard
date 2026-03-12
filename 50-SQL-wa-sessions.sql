-- ============================================
-- Story 1.1: wa_sessions — WhatsApp per-user sessions
-- Sprint 1 of WhatsApp Per-User Connection (Story 4.0)
-- ============================================

-- Table: stores one active WhatsApp session per user
CREATE TABLE IF NOT EXISTS wa_sessions (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  instance_name TEXT NOT NULL UNIQUE,
  status        TEXT NOT NULL DEFAULT 'disconnected'
                  CHECK (status IN ('disconnected', 'qr_pending', 'connecting', 'connected', 'banned')),
  phone_number  TEXT,                  -- e.g. '5531999999999'
  qr_code_base64 TEXT,                 -- temporary QR for pairing (cleared after connect)
  connected_at  TIMESTAMPTZ,
  last_health_check TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- Only one active session per user (disconnected sessions don't count)
CREATE UNIQUE INDEX idx_wa_sessions_active_user
  ON wa_sessions (user_id)
  WHERE status NOT IN ('disconnected', 'banned');

-- Index for quick lookup by instance name (Evolution API callbacks)
CREATE INDEX idx_wa_sessions_instance ON wa_sessions (instance_name);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION wa_sessions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_wa_sessions_updated_at
  BEFORE UPDATE ON wa_sessions
  FOR EACH ROW
  EXECUTE FUNCTION wa_sessions_updated_at();

-- ============================================
-- RLS: each user sees only their own session
-- ============================================
ALTER TABLE wa_sessions ENABLE ROW LEVEL SECURITY;

-- Users can read their own sessions
CREATE POLICY wa_sessions_select ON wa_sessions
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own session
CREATE POLICY wa_sessions_insert ON wa_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own session
CREATE POLICY wa_sessions_update ON wa_sessions
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete (disconnect) their own session
CREATE POLICY wa_sessions_delete ON wa_sessions
  FOR DELETE USING (auth.uid() = user_id);

-- Service role bypass (for backend/webhook updates)
-- Note: service_role key bypasses RLS by default in Supabase
