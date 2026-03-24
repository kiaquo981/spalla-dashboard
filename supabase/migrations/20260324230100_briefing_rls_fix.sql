-- Complete briefing setup (table + RLS) — fix for failed 20260324230000
ALTER TABLE ds_producoes ADD COLUMN IF NOT EXISTS briefing TEXT DEFAULT NULL;

CREATE TABLE IF NOT EXISTS ds_briefing_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  producao_id UUID NOT NULL REFERENCES ds_producoes(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  tipo TEXT NOT NULL,
  tamanho BIGINT DEFAULT 0,
  storage_path TEXT NOT NULL,
  uploaded_by TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ds_briefing_files_producao ON ds_briefing_files(producao_id);

ALTER TABLE ds_briefing_files ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "ds_briefing_files_select" ON ds_briefing_files FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
  CREATE POLICY "ds_briefing_files_insert" ON ds_briefing_files FOR INSERT WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
  CREATE POLICY "ds_briefing_files_delete" ON ds_briefing_files FOR DELETE USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
