-- ================================================================
-- Migration: briefing e arquivos de dossiê
-- Data: 2026-03-24
-- Contexto:
--   Permite criar dossiês com briefing rico (texto + arquivos).
--   Arquivos (PDF, DOC, imagem, áudio) vão pro Supabase Storage.
-- ================================================================

-- Briefing text na produção
ALTER TABLE ds_producoes
  ADD COLUMN IF NOT EXISTS briefing TEXT DEFAULT NULL;

COMMENT ON COLUMN ds_producoes.briefing IS
  'Briefing em texto sobre a produção dos dossiês deste mentorado.';

-- Tabela de arquivos do briefing
CREATE TABLE IF NOT EXISTS ds_briefing_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  producao_id UUID NOT NULL REFERENCES ds_producoes(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  tipo TEXT NOT NULL, -- mime type
  tamanho BIGINT DEFAULT 0,
  storage_path TEXT NOT NULL, -- path no bucket
  uploaded_by TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ds_briefing_files_producao ON ds_briefing_files(producao_id);

COMMENT ON TABLE ds_briefing_files IS
  'Arquivos anexados ao briefing de produção de dossiê (PDFs, DOCs, imagens, áudios).';

-- Storage bucket (precisa ser criado via dashboard ou API, mas registramos aqui)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('dossie-briefings', 'dossie-briefings', false) ON CONFLICT DO NOTHING;

-- RLS
ALTER TABLE ds_briefing_files ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "ds_briefing_files_select" ON ds_briefing_files FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "ds_briefing_files_insert" ON ds_briefing_files FOR INSERT WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "ds_briefing_files_delete" ON ds_briefing_files FOR DELETE USING (true);
