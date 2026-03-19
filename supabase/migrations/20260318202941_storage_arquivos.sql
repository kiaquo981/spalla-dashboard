-- =====================================================
-- SPALLA FILE STORAGE + SEMANTIC SEARCH
-- Run this in Supabase SQL Editor
-- Date: 2026-03-18
-- =====================================================
--
-- ARCHITECTURE (3 layers):
--
--   Layer 1: STORAGE
--     Supabase Storage bucket "spalla-arquivos" = binary files
--     sp_arquivos = metadata + entity references
--
--   Layer 2: CONTENT EXTRACTION (background pipeline)
--     Upload triggers processing job
--     PDF/DOCX/MD/TXT → text extraction
--     XLSX/CSV → structured text with headers
--     MP3/OGG/WAV → Whisper speech-to-text
--     MP4/MOV → extract audio → Whisper
--     PNG/JPEG/WEBP → OCR + GPT-4o vision description
--     Result → sp_conteudo_extraido
--
--   Layer 3: SEMANTIC SEARCH (pgvector)
--     Extracted text → chunked (800 tokens, 200 overlap)
--     Each chunk → text-embedding-3-small (1536 dims)
--     Search = embed query → cosine similarity → ranked results
--     Filters: mentorado, entidade_tipo, categoria, date range
--
--   Hetzner S3 stays ONLY for WhatsApp/Evolution media
--
-- =====================================================

-- Ensure pgvector (already enabled from wa_topics, but safe to repeat)
CREATE EXTENSION IF NOT EXISTS vector;

-- =====================================================
-- 1. sp_arquivos — file metadata (polymorphic attachment)
-- =====================================================
CREATE TABLE IF NOT EXISTS sp_arquivos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

  -- File metadata
  nome_original TEXT NOT NULL,
  nome_storage TEXT NOT NULL,               -- uuid-based sanitized name
  storage_path TEXT NOT NULL,               -- full bucket path: {entidade_tipo}/{entidade_id}/{nome_storage}
  mime_type TEXT NOT NULL,
  tamanho_bytes BIGINT NOT NULL,
  extensao TEXT,                            -- pdf, docx, png, mp4, ogg, etc

  -- Polymorphic attachment
  entidade_tipo TEXT NOT NULL CHECK (entidade_tipo IN (
    'mentorado',
    'task',
    'dossie_doc',
    'dossie_producao',
    'plano_acao',
    'call',
    'geral'
  )),
  entidade_id TEXT,                         -- UUID or BIGINT as text

  -- Categorization
  categoria TEXT DEFAULT 'documento' CHECK (categoria IN (
    'documento',     -- PDF, DOCX, MD, TXT
    'imagem',        -- JPG, PNG, WEBP
    'audio',         -- MP3, WAV, OGG
    'planilha',      -- XLSX, CSV
    'video',         -- MP4, MOV
    'outro'
  )),
  descricao TEXT,

  -- Processing status (for semantic search pipeline)
  status_processamento TEXT DEFAULT 'pendente' CHECK (status_processamento IN (
    'pendente',       -- waiting in queue
    'extraindo',      -- content extraction in progress
    'chunking',       -- splitting into chunks
    'embedding',      -- generating vectors
    'concluido',      -- ready for semantic search
    'erro',           -- processing failed
    'ignorado'        -- file type not supported for extraction
  )),
  erro_processamento TEXT,                  -- error message if failed
  processado_em TIMESTAMPTZ,               -- when processing completed

  -- Audit
  uploaded_by TEXT DEFAULT 'dashboard',
  created_at TIMESTAMPTZ DEFAULT now(),
  deleted_at TIMESTAMPTZ                    -- soft delete
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_sp_arquivos_entidade
  ON sp_arquivos(entidade_tipo, entidade_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_sp_arquivos_categoria
  ON sp_arquivos(categoria) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_sp_arquivos_created
  ON sp_arquivos(created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_sp_arquivos_status_proc
  ON sp_arquivos(status_processamento) WHERE deleted_at IS NULL;

-- RLS (permissive — internal dashboard, password-protected)
ALTER TABLE sp_arquivos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sp_arquivos_all" ON sp_arquivos FOR ALL USING (true) WITH CHECK (true);


-- =====================================================
-- 2. sp_conteudo_extraido — extracted text per file
-- =====================================================
-- One row per file. Stores the FULL extracted text before chunking.
-- Useful for: full-text display, re-chunking, debugging extraction.
CREATE TABLE IF NOT EXISTS sp_conteudo_extraido (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  arquivo_id UUID NOT NULL REFERENCES sp_arquivos(id) ON DELETE CASCADE,

  -- Extracted content
  conteudo_texto TEXT,                      -- full extracted text
  conteudo_estruturado JSONB,              -- structured data (xlsx headers+rows, image labels, etc)
  metadados_extracao JSONB,                -- extraction metadata: {pages, duration_sec, word_count, language, model_used}

  -- Source info
  metodo_extracao TEXT NOT NULL CHECK (metodo_extracao IN (
    'text_direct',      -- MD, TXT, CSV → direct read
    'pdf_extract',      -- PDF → pdfplumber/pymupdf
    'docx_extract',     -- DOCX → python-docx
    'xlsx_extract',     -- XLSX → openpyxl
    'whisper_stt',      -- audio → OpenAI Whisper
    'whisper_video',    -- video → extract audio → Whisper
    'ocr_vision',       -- image → GPT-4o vision + description
    'manual'            -- manually provided text
  )),

  word_count INT,
  duracao_segundos INT,                    -- for audio/video files
  idioma TEXT DEFAULT 'pt-BR',

  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_sp_conteudo_arquivo ON sp_conteudo_extraido(arquivo_id);

ALTER TABLE sp_conteudo_extraido ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sp_conteudo_all" ON sp_conteudo_extraido FOR ALL USING (true) WITH CHECK (true);


-- =====================================================
-- 3. sp_chunks — semantic chunks with vectors
-- =====================================================
-- Each file's extracted text is split into overlapping chunks.
-- Each chunk gets a 1536-dim embedding for cosine similarity search.
CREATE TABLE IF NOT EXISTS sp_chunks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  arquivo_id UUID NOT NULL REFERENCES sp_arquivos(id) ON DELETE CASCADE,
  conteudo_id UUID NOT NULL REFERENCES sp_conteudo_extraido(id) ON DELETE CASCADE,

  -- Chunk content
  texto TEXT NOT NULL,                     -- chunk text (typically 800 tokens)
  chunk_index INT NOT NULL,                -- position in document (0-based)
  token_count INT,                         -- approximate token count

  -- Vector embedding
  embedding vector(1536),                  -- text-embedding-3-small

  -- Context (denormalized for search performance)
  arquivo_nome TEXT,                       -- sp_arquivos.nome_original
  entidade_tipo TEXT,                      -- sp_arquivos.entidade_tipo
  entidade_id TEXT,                        -- sp_arquivos.entidade_id
  categoria TEXT,                          -- sp_arquivos.categoria
  mentorado_id BIGINT,                     -- resolved mentorado (for filtering)
  mentorado_nome TEXT,                     -- resolved name (for display)

  created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_sp_chunks_arquivo ON sp_chunks(arquivo_id);
CREATE INDEX IF NOT EXISTS idx_sp_chunks_mentorado ON sp_chunks(mentorado_id);
CREATE INDEX IF NOT EXISTS idx_sp_chunks_entidade ON sp_chunks(entidade_tipo, entidade_id);

-- HNSW vector index (better than ivfflat — no training needed, works from row 0)
CREATE INDEX IF NOT EXISTS idx_sp_chunks_embedding
  ON sp_chunks USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

ALTER TABLE sp_chunks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sp_chunks_all" ON sp_chunks FOR ALL USING (true) WITH CHECK (true);


-- =====================================================
-- 4. SEMANTIC SEARCH FUNCTION
-- =====================================================
-- Usage: SELECT * FROM fn_busca_semantica('depoimento do mentorado João sobre vendas', 10);
-- With filters: SELECT * FROM fn_busca_semantica('vídeo da Rosalie sobre posicionamento', 10, 'mentorado', NULL, NULL, NULL);

CREATE OR REPLACE FUNCTION fn_busca_semantica(
  p_query_embedding vector(1536),          -- pre-computed embedding of search query
  p_limit INT DEFAULT 10,
  p_entidade_tipo TEXT DEFAULT NULL,        -- filter by entity type
  p_categoria TEXT DEFAULT NULL,            -- filter by file category
  p_mentorado_id BIGINT DEFAULT NULL,       -- filter by mentorado
  p_threshold FLOAT DEFAULT 0.3            -- minimum similarity (0-1, lower = more results)
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
  SELECT
    c.id AS chunk_id,
    c.arquivo_id,
    c.arquivo_nome,
    a.storage_path,
    a.mime_type,
    c.categoria,
    c.entidade_tipo,
    c.entidade_id,
    c.mentorado_id,
    c.mentorado_nome,
    c.texto AS chunk_texto,
    c.chunk_index,
    1 - (c.embedding <=> p_query_embedding) AS similaridade,
    a.created_at AS arquivo_created_at
  FROM sp_chunks c
  JOIN sp_arquivos a ON a.id = c.arquivo_id AND a.deleted_at IS NULL
  WHERE
    c.embedding IS NOT NULL
    AND 1 - (c.embedding <=> p_query_embedding) >= p_threshold
    AND (p_entidade_tipo IS NULL OR c.entidade_tipo = p_entidade_tipo)
    AND (p_categoria IS NULL OR c.categoria = p_categoria)
    AND (p_mentorado_id IS NULL OR c.mentorado_id = p_mentorado_id)
  ORDER BY c.embedding <=> p_query_embedding
  LIMIT p_limit;
$$;

-- =====================================================
-- 5. FULL-TEXT SEARCH FALLBACK (keyword search)
-- =====================================================
-- For when semantic search isn't enough or user wants exact matches

ALTER TABLE sp_chunks ADD COLUMN IF NOT EXISTS texto_tsv tsvector
  GENERATED ALWAYS AS (to_tsvector('portuguese', texto)) STORED;

CREATE INDEX IF NOT EXISTS idx_sp_chunks_fts ON sp_chunks USING gin(texto_tsv);

CREATE OR REPLACE FUNCTION fn_busca_keyword(
  p_query TEXT,
  p_limit INT DEFAULT 20,
  p_entidade_tipo TEXT DEFAULT NULL,
  p_categoria TEXT DEFAULT NULL,
  p_mentorado_id BIGINT DEFAULT NULL
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
  rank FLOAT
)
LANGUAGE sql STABLE
AS $$
  SELECT
    c.id AS chunk_id,
    c.arquivo_id,
    c.arquivo_nome,
    a.storage_path,
    a.mime_type,
    c.categoria,
    c.entidade_tipo,
    c.entidade_id,
    c.mentorado_id,
    c.mentorado_nome,
    c.texto AS chunk_texto,
    ts_rank(c.texto_tsv, websearch_to_tsquery('portuguese', p_query)) AS rank
  FROM sp_chunks c
  JOIN sp_arquivos a ON a.id = c.arquivo_id AND a.deleted_at IS NULL
  WHERE
    c.texto_tsv @@ websearch_to_tsquery('portuguese', p_query)
    AND (p_entidade_tipo IS NULL OR c.entidade_tipo = p_entidade_tipo)
    AND (p_categoria IS NULL OR c.categoria = p_categoria)
    AND (p_mentorado_id IS NULL OR c.mentorado_id = p_mentorado_id)
  ORDER BY rank DESC
  LIMIT p_limit;
$$;

-- =====================================================
-- 6. HYBRID SEARCH (semantic + keyword combined)
-- =====================================================
-- Reciprocal Rank Fusion: combines both rankings for best results

CREATE OR REPLACE FUNCTION fn_busca_hibrida(
  p_query_embedding vector(1536),
  p_query_text TEXT,
  p_limit INT DEFAULT 10,
  p_entidade_tipo TEXT DEFAULT NULL,
  p_categoria TEXT DEFAULT NULL,
  p_mentorado_id BIGINT DEFAULT NULL,
  p_semantic_weight FLOAT DEFAULT 0.7,     -- 70% semantic, 30% keyword
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
  WITH semantic AS (
    SELECT
      c.id,
      1 - (c.embedding <=> p_query_embedding) AS score
    FROM sp_chunks c
    JOIN sp_arquivos a ON a.id = c.arquivo_id AND a.deleted_at IS NULL
    WHERE
      c.embedding IS NOT NULL
      AND 1 - (c.embedding <=> p_query_embedding) >= p_threshold
      AND (p_entidade_tipo IS NULL OR c.entidade_tipo = p_entidade_tipo)
      AND (p_categoria IS NULL OR c.categoria = p_categoria)
      AND (p_mentorado_id IS NULL OR c.mentorado_id = p_mentorado_id)
  ),
  keyword AS (
    SELECT
      c.id,
      ts_rank(c.texto_tsv, websearch_to_tsquery('portuguese', p_query_text)) AS score
    FROM sp_chunks c
    JOIN sp_arquivos a ON a.id = c.arquivo_id AND a.deleted_at IS NULL
    WHERE
      c.texto_tsv @@ websearch_to_tsquery('portuguese', p_query_text)
      AND (p_entidade_tipo IS NULL OR c.entidade_tipo = p_entidade_tipo)
      AND (p_categoria IS NULL OR c.categoria = p_categoria)
      AND (p_mentorado_id IS NULL OR c.mentorado_id = p_mentorado_id)
  ),
  combined AS (
    SELECT
      COALESCE(s.id, k.id) AS chunk_id,
      COALESCE(s.score, 0) AS sem_score,
      COALESCE(k.score, 0) AS kw_score,
      (COALESCE(s.score, 0) * p_semantic_weight) +
      (COALESCE(k.score, 0) * (1 - p_semantic_weight)) AS final_score
    FROM semantic s
    FULL OUTER JOIN keyword k ON s.id = k.id
  )
  SELECT
    cb.chunk_id,
    c.arquivo_id,
    c.arquivo_nome,
    a.storage_path,
    a.mime_type,
    c.categoria,
    c.entidade_tipo,
    c.entidade_id,
    c.mentorado_id,
    c.mentorado_nome,
    c.texto AS chunk_texto,
    cb.final_score AS score_final,
    cb.sem_score AS score_semantico,
    cb.kw_score AS score_keyword
  FROM combined cb
  JOIN sp_chunks c ON c.id = cb.chunk_id
  JOIN sp_arquivos a ON a.id = c.arquivo_id
  ORDER BY cb.final_score DESC
  LIMIT p_limit;
$$;


-- =====================================================
-- 7. UTILITY VIEWS
-- =====================================================

-- Storage usage overview
CREATE OR REPLACE VIEW vw_storage_overview AS
SELECT
  entidade_tipo,
  COUNT(*) FILTER (WHERE deleted_at IS NULL) AS total_arquivos,
  COALESCE(SUM(tamanho_bytes) FILTER (WHERE deleted_at IS NULL), 0) AS total_bytes,
  ROUND(COALESCE(SUM(tamanho_bytes) FILTER (WHERE deleted_at IS NULL), 0) / 1048576.0, 2) AS total_mb,
  COUNT(*) FILTER (WHERE status_processamento = 'concluido' AND deleted_at IS NULL) AS indexados,
  COUNT(*) FILTER (WHERE status_processamento = 'pendente' AND deleted_at IS NULL) AS pendentes,
  COUNT(*) FILTER (WHERE status_processamento = 'erro' AND deleted_at IS NULL) AS com_erro,
  COUNT(DISTINCT entidade_id) FILTER (WHERE deleted_at IS NULL) AS entidades_com_arquivos
FROM sp_arquivos
GROUP BY entidade_tipo
ORDER BY total_bytes DESC;

-- Processing queue (files waiting to be indexed)
CREATE OR REPLACE VIEW vw_processamento_fila AS
SELECT
  a.id,
  a.nome_original,
  a.mime_type,
  a.extensao,
  a.categoria,
  a.tamanho_bytes,
  a.entidade_tipo,
  a.entidade_id,
  a.status_processamento,
  a.erro_processamento,
  a.created_at,
  EXTRACT(EPOCH FROM (now() - a.created_at)) / 60 AS minutos_na_fila
FROM sp_arquivos a
WHERE a.status_processamento IN ('pendente', 'erro')
  AND a.deleted_at IS NULL
ORDER BY a.created_at ASC;

-- Per-mentorado file inventory
CREATE OR REPLACE VIEW vw_arquivos_por_mentorado AS
SELECT
  m.id AS mentorado_id,
  m.nome AS mentorado_nome,
  COUNT(a.id) FILTER (WHERE a.deleted_at IS NULL) AS total_arquivos,
  COUNT(a.id) FILTER (WHERE a.categoria = 'documento' AND a.deleted_at IS NULL) AS documentos,
  COUNT(a.id) FILTER (WHERE a.categoria = 'audio' AND a.deleted_at IS NULL) AS audios,
  COUNT(a.id) FILTER (WHERE a.categoria = 'video' AND a.deleted_at IS NULL) AS videos,
  COUNT(a.id) FILTER (WHERE a.categoria = 'imagem' AND a.deleted_at IS NULL) AS imagens,
  COUNT(a.id) FILTER (WHERE a.status_processamento = 'concluido' AND a.deleted_at IS NULL) AS indexados,
  ROUND(COALESCE(SUM(a.tamanho_bytes) FILTER (WHERE a.deleted_at IS NULL), 0) / 1048576.0, 2) AS total_mb
FROM mentorados m
LEFT JOIN sp_arquivos a ON a.entidade_tipo = 'mentorado' AND a.entidade_id = m.id::TEXT
GROUP BY m.id, m.nome
ORDER BY total_arquivos DESC;


-- =====================================================
-- 8. HELPER FUNCTIONS
-- =====================================================

-- Get files for any entity
CREATE OR REPLACE FUNCTION fn_get_arquivos(p_entidade_tipo TEXT, p_entidade_id TEXT)
RETURNS SETOF sp_arquivos
LANGUAGE sql STABLE
AS $$
  SELECT * FROM sp_arquivos
  WHERE entidade_tipo = p_entidade_tipo
    AND entidade_id = p_entidade_id
    AND deleted_at IS NULL
  ORDER BY created_at DESC;
$$;

-- Count files per entity
CREATE OR REPLACE FUNCTION fn_count_arquivos(p_entidade_tipo TEXT, p_entidade_id TEXT)
RETURNS BIGINT
LANGUAGE sql STABLE
AS $$
  SELECT COUNT(*) FROM sp_arquivos
  WHERE entidade_tipo = p_entidade_tipo
    AND entidade_id = p_entidade_id
    AND deleted_at IS NULL;
$$;

-- Soft-delete a file (doesn't remove from storage — use cleanup job for that)
CREATE OR REPLACE FUNCTION fn_soft_delete_arquivo(p_arquivo_id UUID)
RETURNS VOID
LANGUAGE sql
AS $$
  UPDATE sp_arquivos SET deleted_at = now() WHERE id = p_arquivo_id;
$$;


-- =====================================================
-- 9. SUPABASE STORAGE BUCKET
-- =====================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'spalla-arquivos',
  'spalla-arquivos',
  false,
  524288000,  -- 500MB max (video files can be large)
  ARRAY[
    -- Documents
    'application/pdf',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-excel',
    'text/csv',
    'text/plain',
    'text/markdown',
    -- Images
    'image/jpeg',
    'image/png',
    'image/webp',
    -- Audio
    'audio/mpeg',
    'audio/wav',
    'audio/ogg',
    'audio/mp4',
    'audio/x-m4a',
    -- Video
    'video/mp4',
    'video/quicktime',
    'video/webm'
  ]
)
ON CONFLICT (id) DO NOTHING;

-- Storage RLS (permissive for dashboard)
CREATE POLICY "spalla_arquivos_insert" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'spalla-arquivos');
CREATE POLICY "spalla_arquivos_select" ON storage.objects FOR SELECT
  USING (bucket_id = 'spalla-arquivos');
CREATE POLICY "spalla_arquivos_update" ON storage.objects FOR UPDATE
  USING (bucket_id = 'spalla-arquivos');
CREATE POLICY "spalla_arquivos_delete" ON storage.objects FOR DELETE
  USING (bucket_id = 'spalla-arquivos');
