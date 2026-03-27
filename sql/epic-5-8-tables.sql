-- EPIC 5: Cron job execution logs (OpenFang)
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
CREATE POLICY "Authenticated read cron_logs" ON cron_logs FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service write cron_logs" ON cron_logs FOR INSERT TO service_role WITH CHECK (true);

-- EPIC 6: Dossiê generation job queue (Goose Agent)
CREATE TABLE IF NOT EXISTS dossie_generation_jobs (
    id BIGSERIAL PRIMARY KEY,
    mentorado_id BIGINT REFERENCES mentorados(id) ON DELETE CASCADE,
    dossie_type TEXT NOT NULL CHECK (dossie_type IN ('oferta', 'posicionamento', 'funil')),
    status TEXT NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'processing', 'evaluating', 'completed', 'failed')),
    requested_by TEXT,
    progress JSONB DEFAULT '{}',  -- {current_step: "extracting", percent: 45}
    result JSONB,                 -- {dossie_id: 123, qa_score: {...}, chars: 15000}
    error TEXT,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_gen_jobs_mentorado ON dossie_generation_jobs(mentorado_id);
CREATE INDEX IF NOT EXISTS idx_gen_jobs_status ON dossie_generation_jobs(status);

ALTER TABLE dossie_generation_jobs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated read gen_jobs" ON dossie_generation_jobs FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service write gen_jobs" ON dossie_generation_jobs FOR ALL TO service_role USING (true) WITH CHECK (true);
