---
title: Spalla Storage + Semantic Search — Architecture
type: architecture
status: draft
date: 2026-03-18
---

# Spalla Storage + Semantic Search

## Overview

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────────┐
│   Frontend   │────▶│  Supabase Storage │     │  Railway Backend     │
│  (Alpine.js) │     │  bucket: spalla-  │     │  (14-APP-server.py)  │
│              │     │  arquivos         │     │                      │
│  Upload UI   │     └──────────────────┘     │  /api/process-file   │
│  Search UI   │                               │  /api/search         │
└──────┬───────┘     ┌──────────────────┐     └──────────┬───────────┘
       │             │  Supabase DB      │                │
       └────────────▶│                   │◀───────────────┘
                     │  sp_arquivos      │
                     │  sp_conteudo      │   ┌─────────────────┐
                     │  sp_chunks        │   │  OpenAI API      │
                     │  (pgvector)       │   │  - Whisper STT   │
                     └──────────────────┘   │  - Embeddings    │
                                             │  - GPT-4o Vision │
                                             └─────────────────┘
```

## Upload Flow

```
1. User picks file(s) in dashboard
2. Frontend:
   a. supabase.storage.from('spalla-arquivos').upload(path, file)
   b. INSERT into sp_arquivos (metadata + status='pendente')
   c. POST /api/process-file { arquivo_id }
3. Backend processes async:
   a. Download file from Supabase Storage
   b. Extract content based on mime_type
   c. INSERT into sp_conteudo_extraido
   d. Chunk text (800 tokens, 200 overlap)
   e. Generate embeddings via OpenAI
   f. INSERT into sp_chunks (with vectors)
   g. UPDATE sp_arquivos status='concluido'
```

## Content Extraction by File Type

| Type | Extensions | Method | Tool | Cost |
|------|-----------|--------|------|------|
| **Text** | .md, .txt | Direct read | — | Free |
| **PDF** | .pdf | Text extraction | `pdfplumber` | Free |
| **DOCX** | .docx | XML extraction | `python-docx` | Free |
| **XLSX** | .xlsx | Sheet→text with headers | `openpyxl` | Free |
| **CSV** | .csv | Parse with headers | stdlib `csv` | Free |
| **Audio** | .mp3, .wav, .ogg, .m4a | Speech-to-text | OpenAI Whisper API | ~$0.006/min |
| **Video** | .mp4, .mov, .webm | Extract audio → STT | `ffmpeg` + Whisper | ~$0.006/min |
| **Image** | .png, .jpg, .webp | OCR + description | GPT-4o vision | ~$0.01/image |

### Cost Estimates (for 37 mentorados)

| Scenario | Files | Est. Cost |
|----------|-------|-----------|
| All dossiês (PDF/DOCX) | ~111 (3 per mentorado) | ~$0.05 (embedding only) |
| Call recordings (audio) | ~226 calls × 30min avg | ~$40 Whisper + $2 embedding |
| Videos (MP4) | ~50 videos × 10min | ~$3 Whisper + $0.50 embedding |
| Images (screenshots etc) | ~200 | ~$2 GPT-4o vision |
| **Total initial indexing** | **~587 files** | **~$48** |
| **Per month (incremental)** | ~50 new files | **~$5-10** |

## Chunking Strategy

```python
CHUNK_SIZE = 800      # tokens per chunk
CHUNK_OVERLAP = 200   # token overlap between chunks
MIN_CHUNK_SIZE = 50   # skip chunks smaller than this

# For audio/video transcriptions:
# Chunk by natural pauses/sentences, not fixed token windows
# Preserve speaker labels when available
```

## Search Architecture

### 3 Search Modes

1. **Semantic** (`fn_busca_semantica`):
   Query → embed → cosine similarity
   Best for: "depoimento da Rosalie sobre posicionamento"

2. **Keyword** (`fn_busca_keyword`):
   Query → Portuguese full-text search (tsvector)
   Best for: exact names, dates, specific terms

3. **Hybrid** (`fn_busca_hibrida`):
   Combines both with Reciprocal Rank Fusion (70% semantic + 30% keyword)
   Best for: general search — DEFAULT mode

### Search API

```
POST /api/search
{
  "query": "depoimento do mentorado João sobre vendas",
  "mode": "hybrid",        // "semantic" | "keyword" | "hybrid"
  "filters": {
    "mentorado_id": 42,    // optional
    "entidade_tipo": null,  // optional: "mentorado", "task", "call", etc
    "categoria": null,      // optional: "audio", "video", "documento", etc
    "date_from": null,      // optional
    "date_to": null         // optional
  },
  "limit": 10
}

Response:
{
  "results": [
    {
      "arquivo_id": "uuid",
      "arquivo_nome": "Call-Estrategia-Joao-2026-02-15.mp3",
      "categoria": "audio",
      "mentorado_nome": "João Silva",
      "chunk_texto": "...então eu comecei a vender no primeiro mês...",
      "similaridade": 0.89,
      "storage_url": "signed-url-for-download",
      "timestamp_in_file": "12:34"   // for audio/video, position of this chunk
    }
  ],
  "total": 3,
  "query_time_ms": 45
}
```

## Backend Dependencies (add to requirements.txt)

```
# Content extraction
pdfplumber>=0.10
python-docx>=1.0
openpyxl>=3.1

# Audio/Video
openai>=1.0           # Whisper API + Embeddings + Vision

# Text processing
tiktoken>=0.5         # Token counting for chunking

# Already have: supabase (via SUPABASE_URL + service key)
```

### Why NOT install ffmpeg?

For video files, instead of extracting audio locally with ffmpeg:
- Upload video to Supabase Storage
- Use OpenAI's Whisper API which accepts video files directly (mp4, mov, webm)
- OR use a lightweight Python lib (`moviepy`) only if Whisper rejects the format
- This avoids adding ffmpeg to the Railway Docker image

## Environment Variables (add to Railway)

```
OPENAI_API_KEY=sk-...           # For Whisper, Embeddings, Vision
EMBEDDING_MODEL=text-embedding-3-small
WHISPER_MODEL=whisper-1
VISION_MODEL=gpt-4o
```

## Processing Queue Strategy

**Simple approach** (no BullMQ/Redis needed):

1. Frontend POSTs to `/api/process-file` after upload
2. Backend spawns a thread to process (already using threading in server.py)
3. Updates `sp_arquivos.status_processamento` at each step
4. Frontend polls `sp_arquivos` status via Supabase realtime or interval

**If scale becomes an issue later:**
- Move to Supabase Edge Functions (Deno)
- Or add a simple Redis queue on Railway

## Frontend Integration Points

### 1. Upload Component (any entity detail page)
```javascript
// In Alpine.js component
async uploadFile(file, entidadeTipo, entidadeId) {
  const ext = file.name.split('.').pop();
  const nomeStorage = `${crypto.randomUUID()}.${ext}`;
  const path = `${entidadeTipo}/${entidadeId}/${nomeStorage}`;

  // 1. Upload binary to Supabase Storage
  const { data, error } = await supabase.storage
    .from('spalla-arquivos')
    .upload(path, file);

  // 2. Insert metadata
  await supabase.from('sp_arquivos').insert({
    nome_original: file.name,
    nome_storage: nomeStorage,
    storage_path: path,
    mime_type: file.type,
    tamanho_bytes: file.size,
    extensao: ext,
    entidade_tipo: entidadeTipo,
    entidade_id: entidadeId,
    categoria: this.detectCategoria(file.type)
  });

  // 3. Trigger processing
  await fetch(`${API_BASE}/api/process-file`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ arquivo_id: data.id })
  });
}
```

### 2. Search Bar (global)
```javascript
async searchFiles(query) {
  const res = await fetch(`${API_BASE}/api/search`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      query,
      mode: 'hybrid',
      filters: this.searchFilters,
      limit: 10
    })
  });
  return res.json();
}
```

### 3. File List (in entity detail views)
```javascript
// Load files for a specific entity
async loadArquivos(entidadeTipo, entidadeId) {
  const { data } = await supabase
    .rpc('fn_get_arquivos', {
      p_entidade_tipo: entidadeTipo,
      p_entidade_id: entidadeId
    });
  return data;
}
```

## Implementation Order

1. **SQL schema** → Run `53-SQL-storage-arquivos.sql` in Supabase
2. **Backend extraction endpoints** → Add to `14-APP-server.py`
3. **Frontend upload component** → Add to `11-APP-app.js`
4. **Frontend search UI** → Global search bar
5. **Batch indexing** → Script to process existing dossiês/calls
6. **Polish** → Progress indicators, error handling, retry
