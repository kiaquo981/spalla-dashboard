-- EPIC 1-8: Integration tables for Chatwoot, RAGAS, OpenFang, Goose
-- Note: mentorados is a VIEW, not a table — cannot use REFERENCES

-- EPIC 1: Chatwoot message log
CREATE TABLE IF NOT EXISTS chatwoot_messages (
    id BIGSERIAL PRIMARY KEY,
    mentorado_id BIGINT,
    direction TEXT NOT NULL CHECK (direction IN ('inbound', 'outbound')),
    content_preview TEXT,
    chatwoot_conversation_id BIGINT,
    chatwoot_message_id BIGINT,
    sender_name TEXT,
    channel TEXT DEFAULT 'whatsapp',
    created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_cw_messages_mentorado ON chatwoot_messages(mentorado_id);
CREATE INDEX IF NOT EXISTS idx_cw_messages_created ON chatwoot_messages(created_at DESC);
ALTER TABLE chatwoot_messages ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  CREATE POLICY "read_chatwoot_messages" ON chatwoot_messages FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "write_chatwoot_messages" ON chatwoot_messages FOR INSERT TO service_role WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- EPIC 3: RAGAS quality scores
CREATE TABLE IF NOT EXISTS dossie_qa_scores (
    id BIGSERIAL PRIMARY KEY,
    mentorado_id BIGINT,
    scores JSONB NOT NULL,
    verdict TEXT NOT NULL CHECK (verdict IN ('approved', 'needs_review', 'failed', 'error')),
    dossie_chars INTEGER DEFAULT 0,
    source_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_qa_scores_mentorado ON dossie_qa_scores(mentorado_id);
CREATE INDEX IF NOT EXISTS idx_qa_scores_verdict ON dossie_qa_scores(verdict);
ALTER TABLE dossie_qa_scores ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  CREATE POLICY "read_qa_scores" ON dossie_qa_scores FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "write_qa_scores" ON dossie_qa_scores FOR INSERT TO service_role WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- EPIC 5: Cron job logs
CREATE TABLE IF NOT EXISTS cron_logs (
    id BIGSERIAL PRIMARY KEY,
    job_name TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('success', 'failed', 'skipped')),
    message TEXT,
    result_count INTEGER DEFAULT 0,
    executed_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_cron_logs_job ON cron_logs(job_name);
CREATE INDEX IF NOT EXISTS idx_cron_logs_at ON cron_logs(executed_at DESC);
ALTER TABLE cron_logs ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  CREATE POLICY "read_cron_logs" ON cron_logs FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "write_cron_logs" ON cron_logs FOR INSERT TO service_role WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- EPIC 6: Dossiê generation job queue
CREATE TABLE IF NOT EXISTS dossie_generation_jobs (
    id BIGSERIAL PRIMARY KEY,
    mentorado_id BIGINT,
    dossie_type TEXT NOT NULL CHECK (dossie_type IN ('oferta', 'posicionamento', 'funil')),
    status TEXT NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'processing', 'evaluating', 'completed', 'failed')),
    requested_by TEXT,
    progress JSONB DEFAULT '{}',
    result JSONB,
    error TEXT,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_gen_jobs_mentorado ON dossie_generation_jobs(mentorado_id);
CREATE INDEX IF NOT EXISTS idx_gen_jobs_status ON dossie_generation_jobs(status);
ALTER TABLE dossie_generation_jobs ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  CREATE POLICY "read_gen_jobs" ON dossie_generation_jobs FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "all_gen_jobs" ON dossie_generation_jobs FOR ALL TO service_role USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Add last_contact to base table (if mentorados is a view over another table)
-- This needs to be added to the actual base table. Skipping if it fails.
DO $$ BEGIN
  ALTER TABLE god_mentorados ADD COLUMN IF NOT EXISTS last_contact TIMESTAMPTZ;
EXCEPTION WHEN undefined_table THEN
  -- Try alternate table names
  BEGIN
    ALTER TABLE mentorado ADD COLUMN IF NOT EXISTS last_contact TIMESTAMPTZ;
  EXCEPTION WHEN undefined_table THEN NULL;
  END;
END $$;
