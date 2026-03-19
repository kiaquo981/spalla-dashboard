-- =====================================================
-- SPALLA STORAGE v2 — Schema Upgrades
-- Date: 2026-03-18
-- Changes:
--   1. vector(1536) → vector(1024) for Voyage AI
--   2. pinned flag on sp_arquivos
--   3. content_hash for dedup (Notion pattern)
--   4. multi-pass indexing support (chunk_tipo)
--   5. Realtime subscription on sp_arquivos
-- =====================================================

-- 1. Add pinned + content_hash to sp_arquivos
ALTER TABLE sp_arquivos
  ADD COLUMN IF NOT EXISTS pinned BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS content_hash TEXT;

CREATE INDEX IF NOT EXISTS idx_sp_arquivos_pinned
  ON sp_arquivos(pinned) WHERE pinned = true AND deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_sp_arquivos_hash
  ON sp_arquivos(content_hash) WHERE deleted_at IS NULL;

COMMENT ON COLUMN sp_arquivos.pinned IS 'Pinned files always appear in search results (dossies master, contratos)';
COMMENT ON COLUMN sp_arquivos.content_hash IS 'SHA-256 hash of extracted text — skip re-embedding if unchanged';

-- 2. Drop old HNSW index + change vector dimension from 1536 to 1024
DROP INDEX IF EXISTS idx_sp_chunks_embedding;

ALTER TABLE sp_chunks
  ALTER COLUMN embedding TYPE vector(1024)
  USING NULL;

-- Add chunk_tipo for multi-pass indexing
ALTER TABLE sp_chunks
  ADD COLUMN IF NOT EXISTS chunk_tipo TEXT DEFAULT 'standard'
    CHECK (chunk_tipo IN ('standard', 'context', 'heading'));

COMMENT ON COLUMN sp_chunks.chunk_tipo IS 'standard=normal chunk, context=broad context (2x size), heading=section-level chunk';

-- Recreate HNSW index with 1024 dims
CREATE INDEX idx_sp_chunks_embedding
  ON sp_chunks USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

-- 3. Update search functions for vector(1024)

-- Semantic search
CREATE OR REPLACE FUNCTION fn_busca_semantica(
  p_query_embedding vector(1024),
  p_limit INT DEFAULT 10,
  p_entidade_tipo TEXT DEFAULT NULL,
  p_categoria TEXT DEFAULT NULL,
  p_mentorado_id BIGINT DEFAULT NULL,
  p_threshold FLOAT DEFAULT 0.3
)
RETURNS TABLE (
  chunk_id UUID,
  arquivo_id UUID,
  arquivo_nome TEXT,
  storage_path TEXT,
  mime_type TEXT,
  categoria TEXT,
  entidade_tipo TEXT,
  entidade_id TEXT,
  mentorado_id BIGINT,
  mentorado_nome TEXT,
  chunk_texto TEXT,
  chunk_index INT,
  similaridade FLOAT,
  arquivo_created_at TIMESTAMPTZ
)
LANGUAGE sql STABLE
AS $$
  -- First: pinned files always included
  (
    SELECT
      c.id, c.arquivo_id, c.arquivo_nome, a.storage_path, a.mime_type,
      c.categoria, c.entidade_tipo, c.entidade_id, c.mentorado_id, c.mentorado_nome,
      c.texto, c.chunk_index,
      CASE WHEN c.embedding IS NOT NULL
        THEN 1 - (c.embedding <=> p_query_embedding)
        ELSE 0.99
      END AS similaridade,
      a.created_at
    FROM sp_chunks c
    JOIN sp_arquivos a ON a.id = c.arquivo_id AND a.deleted_at IS NULL AND a.pinned = true
    WHERE
      (p_entidade_tipo IS NULL OR c.entidade_tipo = p_entidade_tipo)
      AND (p_categoria IS NULL OR c.categoria = p_categoria)
      AND (p_mentorado_id IS NULL OR c.mentorado_id = p_mentorado_id)
    LIMIT 3
  )
  UNION ALL
  -- Then: semantic results
  (
    SELECT
      c.id, c.arquivo_id, c.arquivo_nome, a.storage_path, a.mime_type,
      c.categoria, c.entidade_tipo, c.entidade_id, c.mentorado_id, c.mentorado_nome,
      c.texto, c.chunk_index,
      1 - (c.embedding <=> p_query_embedding) AS similaridade,
      a.created_at
    FROM sp_chunks c
    JOIN sp_arquivos a ON a.id = c.arquivo_id AND a.deleted_at IS NULL AND (a.pinned IS NOT true)
    WHERE
      c.embedding IS NOT NULL
      AND 1 - (c.embedding <=> p_query_embedding) >= p_threshold
      AND (p_entidade_tipo IS NULL OR c.entidade_tipo = p_entidade_tipo)
      AND (p_categoria IS NULL OR c.categoria = p_categoria)
      AND (p_mentorado_id IS NULL OR c.mentorado_id = p_mentorado_id)
    ORDER BY c.embedding <=> p_query_embedding
    LIMIT p_limit
  );
$$;

-- Hybrid search
CREATE OR REPLACE FUNCTION fn_busca_hibrida(
  p_query_embedding vector(1024),
  p_query_text TEXT,
  p_limit INT DEFAULT 10,
  p_entidade_tipo TEXT DEFAULT NULL,
  p_categoria TEXT DEFAULT NULL,
  p_mentorado_id BIGINT DEFAULT NULL,
  p_semantic_weight FLOAT DEFAULT 0.7,
  p_threshold FLOAT DEFAULT 0.25
)
RETURNS TABLE (
  chunk_id UUID,
  arquivo_id UUID,
  arquivo_nome TEXT,
  storage_path TEXT,
  mime_type TEXT,
  categoria TEXT,
  entidade_tipo TEXT,
  entidade_id TEXT,
  mentorado_id BIGINT,
  mentorado_nome TEXT,
  chunk_texto TEXT,
  score_final FLOAT,
  score_semantico FLOAT,
  score_keyword FLOAT
)
LANGUAGE sql STABLE
AS $$
  WITH pinned AS (
    SELECT c.id, 1.0::float AS sem_score, 0.0::float AS kw_score, 1.0::float AS final_score
    FROM sp_chunks c
    JOIN sp_arquivos a ON a.id = c.arquivo_id AND a.deleted_at IS NULL AND a.pinned = true
    WHERE
      (p_entidade_tipo IS NULL OR c.entidade_tipo = p_entidade_tipo)
      AND (p_categoria IS NULL OR c.categoria = p_categoria)
      AND (p_mentorado_id IS NULL OR c.mentorado_id = p_mentorado_id)
    LIMIT 3
  ),
  semantic AS (
    SELECT c.id, 1 - (c.embedding <=> p_query_embedding) AS score
    FROM sp_chunks c
    JOIN sp_arquivos a ON a.id = c.arquivo_id AND a.deleted_at IS NULL
    WHERE c.embedding IS NOT NULL
      AND 1 - (c.embedding <=> p_query_embedding) >= p_threshold
      AND (p_entidade_tipo IS NULL OR c.entidade_tipo = p_entidade_tipo)
      AND (p_categoria IS NULL OR c.categoria = p_categoria)
      AND (p_mentorado_id IS NULL OR c.mentorado_id = p_mentorado_id)
      AND c.id NOT IN (SELECT id FROM pinned)
  ),
  keyword AS (
    SELECT c.id, ts_rank(c.texto_tsv, websearch_to_tsquery('portuguese', p_query_text)) AS score
    FROM sp_chunks c
    JOIN sp_arquivos a ON a.id = c.arquivo_id AND a.deleted_at IS NULL
    WHERE c.texto_tsv @@ websearch_to_tsquery('portuguese', p_query_text)
      AND (p_entidade_tipo IS NULL OR c.entidade_tipo = p_entidade_tipo)
      AND (p_categoria IS NULL OR c.categoria = p_categoria)
      AND (p_mentorado_id IS NULL OR c.mentorado_id = p_mentorado_id)
      AND c.id NOT IN (SELECT id FROM pinned)
  ),
  combined AS (
    SELECT id, sem_score, kw_score, final_score FROM pinned
    UNION ALL
    SELECT
      COALESCE(s.id, k.id),
      COALESCE(s.score, 0),
      COALESCE(k.score, 0),
      (COALESCE(s.score, 0) * p_semantic_weight) + (COALESCE(k.score, 0) * (1 - p_semantic_weight))
    FROM semantic s FULL OUTER JOIN keyword k ON s.id = k.id
  )
  SELECT
    cb.id, c.arquivo_id, c.arquivo_nome, a.storage_path, a.mime_type,
    c.categoria, c.entidade_tipo, c.entidade_id, c.mentorado_id, c.mentorado_nome,
    c.texto, cb.final_score, cb.sem_score, cb.kw_score
  FROM combined cb
  JOIN sp_chunks c ON c.id = cb.id
  JOIN sp_arquivos a ON a.id = c.arquivo_id
  ORDER BY cb.final_score DESC
  LIMIT p_limit;
$$;

-- 4. Enable Realtime on sp_arquivos for live processing status
ALTER PUBLICATION supabase_realtime ADD TABLE sp_arquivos;
