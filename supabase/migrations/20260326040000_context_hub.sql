-- Context Hub: áudio, texto e anexos vinculados ao mentorado durante onboarding
-- Persiste até o último dossiê ser entregue, depois pode ser arquivado

CREATE TABLE IF NOT EXISTS mentorado_context (
    id BIGSERIAL PRIMARY KEY,
    mentorado_id BIGINT NOT NULL,
    tipo TEXT NOT NULL CHECK (tipo IN ('audio', 'texto', 'arquivo')),
    titulo TEXT,                          -- nome descritivo (ex: "Áudio call onboarding")
    conteudo TEXT,                        -- texto livre ou transcrição do áudio
    arquivo_url TEXT,                     -- URL do arquivo no storage (áudio, PDF, imagem)
    arquivo_nome TEXT,                    -- nome original do arquivo
    arquivo_tipo TEXT,                    -- MIME type (audio/mp3, application/pdf, etc)
    arquivo_tamanho INTEGER,             -- tamanho em bytes
    fase TEXT DEFAULT 'onboarding',      -- onboarding, dossie_oferta, dossie_posicionamento, dossie_funil
    criado_por TEXT,                      -- email de quem criou
    ativo BOOLEAN DEFAULT true,          -- false = arquivado (após entrega do último dossiê)
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ctx_mentorado ON mentorado_context(mentorado_id);
CREATE INDEX IF NOT EXISTS idx_ctx_tipo ON mentorado_context(tipo);
CREATE INDEX IF NOT EXISTS idx_ctx_ativo ON mentorado_context(ativo);

ALTER TABLE mentorado_context ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "anon_read_context" ON mentorado_context FOR SELECT TO anon USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "anon_insert_context" ON mentorado_context FOR INSERT TO anon WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "anon_update_context" ON mentorado_context FOR UPDATE TO anon USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "anon_delete_context" ON mentorado_context FOR DELETE TO anon USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "auth_all_context" ON mentorado_context FOR ALL TO authenticated USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "service_all_context" ON mentorado_context FOR ALL TO service_role USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
