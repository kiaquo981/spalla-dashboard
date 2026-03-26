-- Chatwoot Messages Log — tracks all WhatsApp/email messages synced from Chatwoot
-- This is a LOG table (append-only), not a conversation manager.
-- Chatwoot is the source of truth for conversations; this table enables
-- Spalla to show message activity per mentorado without calling Chatwoot API.

CREATE TABLE IF NOT EXISTS chatwoot_messages (
    id BIGSERIAL PRIMARY KEY,
    mentorado_id BIGINT REFERENCES mentorados(id) ON DELETE SET NULL,
    direction TEXT NOT NULL CHECK (direction IN ('inbound', 'outbound')),
    content_preview TEXT,  -- first 200 chars, not full message
    chatwoot_conversation_id BIGINT,
    chatwoot_message_id BIGINT,
    sender_name TEXT,
    channel TEXT DEFAULT 'whatsapp',  -- whatsapp, email, web
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Index for fast lookups per mentorado
CREATE INDEX IF NOT EXISTS idx_cw_messages_mentorado ON chatwoot_messages(mentorado_id);
CREATE INDEX IF NOT EXISTS idx_cw_messages_created ON chatwoot_messages(created_at DESC);

-- RLS: authenticated users can read all, system can write
ALTER TABLE chatwoot_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated read chatwoot_messages"
    ON chatwoot_messages FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Service write chatwoot_messages"
    ON chatwoot_messages FOR INSERT
    TO service_role
    WITH CHECK (true);

-- Add last_contact column to mentorados if not exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'mentorados' AND column_name = 'last_contact'
    ) THEN
        ALTER TABLE mentorados ADD COLUMN last_contact TIMESTAMPTZ;
    END IF;
END $$;
