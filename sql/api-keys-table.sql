-- ===== API Keys Table =====
-- Stores hashed API keys for external integrations (n8n, webhooks, etc.)
-- The raw key is shown once on creation and never stored.

CREATE TABLE IF NOT EXISTS api_keys (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    key_hash TEXT NOT NULL UNIQUE,        -- SHA-256 hash of the raw key
    key_prefix TEXT NOT NULL,             -- First 14 chars + "..." for display
    label TEXT NOT NULL,                  -- Human-readable label (e.g., "n8n-production")
    role TEXT NOT NULL DEFAULT 'integration',  -- integration | readonly
    active BOOLEAN NOT NULL DEFAULT true,
    created_by TEXT,                      -- Email of admin who created
    created_at TIMESTAMPTZ DEFAULT now(),
    last_used_at TIMESTAMPTZ,
    CONSTRAINT api_keys_role_check CHECK (role IN ('integration', 'readonly'))
);

-- Index for fast lookup by hash (used on every API request)
CREATE INDEX IF NOT EXISTS idx_api_keys_hash_active ON api_keys (key_hash) WHERE active = true;

-- RLS: Only service_role can manage keys (backend uses service key)
ALTER TABLE api_keys ENABLE ROW LEVEL SECURITY;

CREATE POLICY "service_role_full_access" ON api_keys
    FOR ALL USING (auth.role() = 'service_role');

COMMENT ON TABLE api_keys IS 'API keys for external integrations. Keys are stored as SHA-256 hashes.';
COMMENT ON COLUMN api_keys.key_hash IS 'SHA-256 hash of the raw API key';
COMMENT ON COLUMN api_keys.key_prefix IS 'First 14 characters of the key for identification (sk_spalla_xxxx...)';
COMMENT ON COLUMN api_keys.role IS 'integration = full access, readonly = GET-only';
