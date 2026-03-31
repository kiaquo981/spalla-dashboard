-- ============================================================
-- Comentários dentro do card (dossiê e mentorado)
-- "Nada de grupo, nada, esquece, só ali dentro" — Gobbi
-- Date: 2026-03-30
-- ============================================================

-- 1. Comments table (polymorphic: dossiê OR mentorado)
CREATE TABLE IF NOT EXISTS card_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  -- Polymorphic: exactly one of these should be set
  producao_id UUID REFERENCES ds_producoes(id) ON DELETE CASCADE,
  documento_id UUID REFERENCES ds_documentos(id) ON DELETE CASCADE,
  mentorado_id BIGINT,

  author TEXT NOT NULL DEFAULT 'Equipe',
  content TEXT NOT NULL,
  content_type TEXT DEFAULT 'text' CHECK (content_type IN ('text', 'audio', 'image', 'video', 'file')),
  media_url TEXT,          -- S3 key or URL for media attachments
  media_mime TEXT,
  media_name TEXT,

  parent_id UUID REFERENCES card_comments(id) ON DELETE CASCADE, -- threaded replies
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_card_comments_producao ON card_comments(producao_id) WHERE producao_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_card_comments_documento ON card_comments(documento_id) WHERE documento_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_card_comments_mentorado ON card_comments(mentorado_id) WHERE mentorado_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_card_comments_created ON card_comments(created_at DESC);

-- RLS
ALTER TABLE card_comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "card_comments: acesso autenticados" ON card_comments FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_card_comments_updated_at()
RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_card_comments_updated_at ON card_comments;
CREATE TRIGGER trg_card_comments_updated_at BEFORE UPDATE ON card_comments FOR EACH ROW EXECUTE FUNCTION update_card_comments_updated_at();
