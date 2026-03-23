-- =====================================================
-- sp_documentos — Biblioteca de documentos do Spalla
-- Armazena dossiês, roteiros e materiais por mentorado
-- =====================================================

CREATE TABLE IF NOT EXISTS sp_documentos (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mentee_id      BIGINT REFERENCES "case".mentorados(id) ON DELETE CASCADE,
  tipo           TEXT NOT NULL CHECK (tipo IN ('dossie', 'roteiro', 'material')),
  titulo         TEXT NOT NULL,
  subtitulo      TEXT,
  conteudo_md    TEXT NOT NULL DEFAULT '',
  secoes         JSONB NOT NULL DEFAULT '[]',
  -- cada item: { "id": "sec-uuid", "ancora": "slug", "titulo": "...", "nivel": 2, "ordem": 0 }
  versao         TEXT NOT NULL DEFAULT 'v1',
  tags           TEXT[] NOT NULL DEFAULT '{}',
  deep_link_slug TEXT UNIQUE,
  criado_em      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  atualizado_em  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices de performance
CREATE INDEX IF NOT EXISTS sp_documentos_mentee_idx ON sp_documentos(mentee_id);
CREATE INDEX IF NOT EXISTS sp_documentos_tipo_idx   ON sp_documentos(tipo);
CREATE INDEX IF NOT EXISTS sp_documentos_slug_idx   ON sp_documentos(deep_link_slug)
  WHERE deep_link_slug IS NOT NULL;

-- Auto-atualiza atualizado_em
CREATE OR REPLACE FUNCTION sp_documentos_set_updated()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.atualizado_em = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS sp_documentos_updated_trigger ON sp_documentos;
CREATE TRIGGER sp_documentos_updated_trigger
  BEFORE UPDATE ON sp_documentos
  FOR EACH ROW EXECUTE FUNCTION sp_documentos_set_updated();

-- View pública sem conteúdo completo (para listagem)
CREATE OR REPLACE VIEW vw_sp_documentos_lista AS
SELECT
  d.id,
  d.mentee_id,
  m.nome AS mentee_nome,
  d.tipo,
  d.titulo,
  d.subtitulo,
  d.versao,
  d.tags,
  d.deep_link_slug,
  jsonb_array_length(d.secoes) AS total_secoes,
  length(d.conteudo_md) AS tamanho_chars,
  d.criado_em,
  d.atualizado_em
FROM sp_documentos d
LEFT JOIN "case".mentorados m ON m.id = d.mentee_id
ORDER BY m.nome, d.tipo, d.criado_em;

COMMENT ON TABLE sp_documentos IS 'Biblioteca de documentos Spalla: dossiês, roteiros e materiais por mentorado';
COMMENT ON COLUMN sp_documentos.secoes IS 'Índice de seções gerado automaticamente pelo seed script a partir dos H2/H3 do markdown';
COMMENT ON COLUMN sp_documentos.deep_link_slug IS 'Slug único para deep linking externo (ex: funnelcase → spalla). Ex: danyella-truiz-funil-vendas';
