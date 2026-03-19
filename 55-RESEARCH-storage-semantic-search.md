---
title: "Research: File Storage + Semantic Search — Benchmark de Mercado"
type: research
status: complete
date: 2026-03-18
author: Atlas (Analyst Agent)
---

# File Storage + Semantic Search — Como o Mercado Faz

Pesquisa em 3 frentes: frameworks OSS/RAG, plataformas CRM/SaaS, e patterns Supabase+pgvector.

---

## 1. COMO OS CRMs ASSOCIAM ARQUIVOS A ENTIDADES

### Ranking de capacidade de busca

| # | Plataforma | Busca semântica | Busca em conteúdo | Transcrição nativa | Modelo de associação |
|---|-----------|----------------|-------------------|--------------------|---------------------|
| 1 | **Notion** | Vector search + AI Q&A | Full-text + semantic | Nao | Block tree (file = block) |
| 2 | **ClickUp** | AI Brain indexes tudo | Cross-tool search | SyncUps (calls) | Task attachment |
| 3 | **Close.com** | Nao | Full-text em transcricoes | AssemblyAI nativo ($0.02/min) | Activity-based (file -> activity -> lead) |
| 4 | **HubSpot** | Nao | Nao (so metadata) | Nao | Engagement-mediated (file -> note -> entity) |
| 5 | **Attio** | Nao | Fuzzy record search | Call Intelligence nativo | Record-native storage |
| 6 | **Pipedrive** | Nao | Nao | Nao | **Direct FK** (file.deal_id, file.person_id) |
| 7 | **Monday.com** | Nao | Nao | Nao | Column-based (file column on item) |

### Padroes de associacao arquivo-entidade

| Padrao | Quem usa | Como funciona | Pro | Contra |
|--------|----------|---------------|-----|--------|
| **Direct FK** | Pipedrive | `file.deal_id`, `file.person_id` direto | Simples, query rapida | Sem contexto de "por que" |
| **Polimorphic** | **Spalla (nosso)** | `entidade_tipo` + `entidade_id` | Flexivel, 1 tabela | Cast de IDs |
| **Engagement-mediated** | HubSpot | file -> note -> entity (3 steps) | Audit trail rico | Query cara, 3 joins |
| **Activity-based** | Close.com | file vive em activity (call, email) | Natural pra vendas | Acoplado ao modelo de activity |
| **Block tree** | Notion | file = block, parent-child tree | Flexivel, reuso | Modelo complexo |
| **Task attachment** | ClickUp | file -> task direto | Simples 1:1 | Limitado ao contexto de task |

**Conclusao**: Nosso modelo polimorphico (`entidade_tipo` + `entidade_id`) e o mais flexivel. O Pipedrive e o mais simples mas precisaria de N FKs. O modelo do HubSpot e over-engineered para nosso caso.

---

## 2. COMO OS FRAMEWORKS OSS EXTRAEM CONTEUDO

### Comparativo de pipelines de extracao

| Framework | Formatos nativos | Chunking | Busca | Audio/Video | Licenca |
|-----------|-----------------|----------|-------|-------------|---------|
| **Unstructured.io** | 30+ (melhor) | Basic + by_title (respects sections) | N/A (ETL only) | NAO | Apache 2.0 |
| **LlamaIndex** | 10+ extensivel | 10+ parsers (Semantic, Hierarchical, Window) | Vector + BM25 hybrid | NAO (external) | MIT |
| **LangChain** | 200+ loaders | 8+ splitters (Recursive, Token, Markdown) | EnsembleRetriever (BM25+vector) | AssemblyAI loader | MIT |
| **Onyx (Danswer)** | Via 40+ connectors | Multi-pass multi-context | Vespa hybrid + time-decay + reranking | NAO | MIT (CE) |
| **AnythingLLM** | 20+ | TextSplitter (~1000 chars) | Vector similarity only | **SIM (FFmpeg + Whisper)** | MIT |

### O que cada um usa para extrair por tipo de arquivo

| Tipo | Unstructured.io | LlamaIndex | LangChain | AnythingLLM |
|------|----------------|------------|-----------|-------------|
| PDF | PDFMiner + OCR (Tesseract/Paddle) | pypdf | PyPDFLoader / PDFPlumber | pdf-parse |
| DOCX | python-docx | python-docx | Docx2txtLoader | officeparser |
| XLSX | openpyxl | openpyxl | CSVLoader (after convert) | officeparser |
| Images | pytesseract + unstructured-inference | N/A | N/A | tesseract.js (OCR) |
| Audio | N/A | N/A | AssemblyAI API | **FFmpeg + Whisper** |
| Video | N/A | N/A | YouTube transcript | **FFmpeg + Whisper** |
| HTML | BeautifulSoup | BeautifulSoup | WebBaseLoader | Puppeteer |
| Markdown | Custom parser | MarkdownNodeParser | MarkdownTextSplitter | stdlib |

### Estrategias de chunking — o que funciona

| Estrategia | Quando usar | Tamanho tipico |
|-----------|-------------|----------------|
| **Recursive character** (LangChain default) | Texto generico | 1000 chars, 200 overlap |
| **By title/heading** (Unstructured) | Documentos estruturados (dossies, PDFs) | Respeita secoes, max 500 chars |
| **Semantic splitter** (LlamaIndex) | Quando qualidade > velocidade | Adaptativo por similaridade |
| **Sentence window** (LlamaIndex) | Quando precisa de contexto expandido | 1 sentence + 3 vizinhas |
| **Multi-pass** (Onyx/Danswer) | Enterprise search | Multiplos embeddings por doc |

**Conclusao para Spalla**: Nosso chunking atual (800 tokens, 200 overlap) esta ok para docs genericos. Para dossies (markdown estruturado), deveriamos usar **by_title/heading** que respeita a estrutura de secoes. Para transcricoes de call, **sentence-based** e melhor.

---

## 3. COMO NOTION FAZ BUSCA SEMANTICA (GOLD STANDARD)

Notion tem a melhor arquitetura de busca que encontramos:

### Pipeline Notion

```
Content change
  -> Kafka event
  -> Consumer chunks page into "spans"
  -> Each span embedded with metadata (authors, permissions)
  -> Vectors stored in turbopuffer (object-storage vector DB)
  -> Query: embed query -> cosine similarity -> permission filter -> rank
```

### Diferenciais chave
1. **Separation of concerns**: Conteudo (blocks) separado de index (vector DB)
2. **Permission-aware embeddings**: Metadata de permissao em cada span, sem re-embed quando permissao muda
3. **Dual pipeline**: Offline batch (Spark) + Online real-time (Kafka, sub-minuto)
4. **Hash-based dedup**: xxHash do texto + hash do metadata. So re-embed se texto mudar
5. **Resultado**: p50 latency 50-70ms, 90% reducao de custo

### O que podemos copiar
- Separar metadata de busca do metadata de storage (ja fazemos com sp_chunks.entidade_tipo denormalizado)
- Hash do conteudo para evitar re-embedding desnecessario
- Permission metadata no chunk (nosso caso nao precisa — dashboard interno)

---

## 4. COMO CLOSE.COM FAZ TRANSCRICAO BUSCAVEL (MELHOR PARA NOSSO CASO)

Close.com e o mais relevante porque:
- Transcricao nativa de calls com **speaker labels** e **timestamps**
- Transcricoes sao **full-text searchable** via API de filtering
- Estrutura: `recording_transcript.utterances[].{speaker, speaker_side, start, end, text}`

### Modelo de dados de transcricao

```json
{
  "recording_transcript": {
    "utterances": [
      {
        "speaker": "Rosalie",
        "speaker_side": "contact",
        "start": 12.5,
        "end": 18.3,
        "text": "O problema era gestao nao transparente..."
      },
      {
        "speaker": "Queila",
        "speaker_side": "close-user",
        "start": 18.5,
        "end": 25.1,
        "text": "E como voce resolveu isso na pratica?"
      }
    ]
  }
}
```

### O que podemos copiar
- Guardar **speaker labels + timestamps** nas transcricoes de call
- Quando buscar por "depoimento da Rosalie sobre gestao", ranquear chunks que tem speaker=Rosalie + conteudo semanticamente similar
- Usar `conteudo_estruturado` (JSONB) em `sp_conteudo_extraido` para guardar essa estrutura

---

## 5. ALTERNATIVAS DE EMBEDDING (RESOLVER QUOTA OPENAI)

| Provider | Modelo | Preco/1M tokens | Free tier | Dims | Multilingue | Recomendacao |
|----------|--------|-----------------|-----------|------|-------------|-------------|
| **Voyage AI** | voyage-4-lite | $0.02 | **200M tokens gratis** | 1024 | Sim | **MELHOR opcao** |
| **Google** | Gemini Embedding 001 | **GRATIS** | Ilimitado via Gemini API | 3072 | Sim | Runner-up |
| **Mistral** | mistral-embed | $0.01 | - | 1024 | Sim | Mais barato pago |
| **OpenAI** | text-embedding-3-small | $0.02 | - | 1536 | Sim | Atual (com quota) |
| **Cohere** | embed-v3 multilingual | $0.10 | - | 1024 | 100+ langs | Caro |
| **Self-hosted** | nomic-embed-text-v2 | ~$0.001 | Railway template | 768 | ~100 langs | Zero vendor lock |

### Recomendacao

**Imediato**: Trocar para **Voyage AI voyage-4-lite**
- 200M tokens gratis = suficiente para indexar TUDO que o Spalla tem
- $0.02/1M apos free tier (mesmo preco do OpenAI)
- 1024 dims (menor que 1536 = index HNSW menor e mais rapido)
- API compativel (mesma logica, so trocar endpoint)

**Alternativa zero-cost**: Google Gemini Embedding 001
- Literalmente gratis
- 3072 dims (maior, mas compressivel)

**Mudanca necessaria no schema**: Se trocar de 1536 para 1024 dims, precisa recriar a coluna `embedding` e o index HNSW.

---

## 6. SUPABASE + PGVECTOR — PATTERNS DE PRODUCAO

### Schema recomendado (baseado em supabase-community/chatgpt-your-files)

```sql
-- Documents (metadata + owner)
documents (id, name, owner_id, storage_path, ...)

-- Sections/chunks (content + embedding)
document_sections (id, document_id, content, embedding vector(1024))
```

Com RLS: users so veem sections de documents que possuem.

### Pipeline automatico (Supabase nativo)

```
INSERT em sp_arquivos
  -> Trigger PG dispara
  -> pgmq enfileira job
  -> pg_cron processa fila a cada 10s
  -> Edge Function gera embedding
  -> UPDATE sp_chunks com vetor
```

Isso eliminaria a necessidade do Railway processar embeddings.

### HNSW vs IVFFlat (para <10K docs)

| Metrica | Sequential Scan | IVFFlat | HNSW |
|---------|----------------|---------|------|
| Latencia (1M vetores) | ~890ms | ~12ms | **~8ms** |
| Recall@10 | 1.0 (exato) | 0.92 | **0.98** |
| Precisa treino? | Nao | Sim | **Nao** |

**Para <10K docs**: HNSW e correto (ja implementamos). Ate sequential scan seria ok.

### Realtime para status de processamento

```sql
-- Habilitar realtime na tabela
ALTER PUBLICATION supabase_realtime ADD TABLE sp_arquivos;
```

Frontend (Alpine.js):
```javascript
supabase.channel('file-status')
  .on('postgres_changes', {
    event: 'UPDATE',
    schema: 'public',
    table: 'sp_arquivos',
    filter: `id=eq.${arquivoId}`
  }, (payload) => {
    this.fileStatus = payload.new.status_processamento
  })
  .subscribe()
```

---

## 7. RECOMENDACOES PARA O SPALLA

### O que ja esta BOM no nosso design

| Aspecto | Status | Referencia |
|---------|--------|-----------|
| Modelo polimorphico (entidade_tipo + entidade_id) | OK | Mais flexivel que Pipedrive/HubSpot |
| Supabase Storage + pgvector | OK | Pattern validado pela comunidade |
| Busca hibrida (semantic 70% + keyword 30%) | OK | Mesmo approach de Onyx/Danswer |
| HNSW index | OK | Correto para <10K docs |
| Soft delete | OK | Mesmo padrao do Pipedrive |
| Pipeline de extracao por mime type | OK | Similar ao AnythingLLM |

### O que PRECISAMOS MELHORAR

| # | Melhoria | Inspirado em | Impacto | Esforco |
|---|---------|-------------|---------|---------|
| 1 | **Trocar embedding provider** (Voyage AI ou Gemini) | Research | Desbloqueia busca semantica | Baixo (trocar endpoint) |
| 2 | **Chunking by heading** para .md e .docx | Unstructured.io | Chunks mais semanticos para dossies | Medio |
| 3 | **Speaker labels + timestamps** em transcricoes | Close.com | Buscar "o que a Rosalie disse sobre X" | Medio |
| 4 | **Realtime status** no frontend | Supabase Realtime | UX de processamento ao vivo | Baixo |
| 5 | **Hash de conteudo** para evitar re-embedding | Notion | Economia de API calls | Baixo |
| 6 | **Reranking** nos resultados de busca | Onyx/Danswer, LlamaIndex | Resultados mais precisos | Medio |
| 7 | **Workspace isolation** (se multi-equipe) | AnythingLLM | Separar mentorados por equipe | Alto (futuro) |

### Prioridade de implementacao

```
AGORA (resolve o blocker):
  1. Trocar para Voyage AI (200M tokens gratis, API similar)
  2. Ajustar schema: vector(1536) -> vector(1024)

PROXIMO SPRINT:
  3. Chunking by heading para dossies markdown
  4. Realtime status via Supabase subscription
  5. Hash de conteudo (evitar re-embed)

FUTURO:
  6. Speaker labels em transcricoes de call
  7. Reranking (Cohere ou cross-encoder local)
  8. UI de busca global no dashboard
```

---

## 8. FONTES

### Frameworks OSS
- [Unstructured-IO/unstructured](https://github.com/Unstructured-IO/unstructured)
- [LlamaIndex Ingestion Pipeline](https://developers.llamaindex.ai/)
- [LangChain Document Loaders](https://docs.langchain.com/)
- [Onyx (Danswer)](https://github.com/onyx-dot-app/onyx)
- [AnythingLLM](https://github.com/Mintplex-Labs/anything-llm)

### Plataformas CRM/SaaS
- [HubSpot Files API v3](https://developers.hubspot.com/docs/api-reference/files-files-v3/guide)
- [Notion Vector Search at Scale](https://www.notion.com/blog/two-years-of-vector-search-at-notion)
- [Notion File Upload API](https://developers.notion.com/docs/uploading-small-files)
- [ClickUp Brain AI Search](https://clickup.com/features/ai)
- [Close.com Call API + Transcripts](https://developer.close.com/resources/activities/call/)
- [Pipedrive Files API](https://developers.pipedrive.com/docs/api/v1/Files)
- [Monday.com Files API](https://developer.monday.com/api-reference/reference/files-1)
- [Attio API Docs](https://docs.attio.com/)

### Supabase + pgvector
- [Supabase Semantic Search](https://supabase.com/docs/guides/ai/semantic-search)
- [Supabase Automatic Embeddings](https://supabase.com/docs/guides/ai/automatic-embeddings)
- [Supabase Vector Buckets](https://supabase.com/blog/vector-buckets)
- [supabase-community/chatgpt-your-files](https://github.com/supabase-community/chatgpt-your-files)
- [Voyage AI Pricing](https://docs.voyageai.com/docs/pricing)
- [pgvector HNSW vs IVFFlat](https://aws.amazon.com/blogs/database/optimize-generative-ai-applications-with-pgvector-indexing/)
