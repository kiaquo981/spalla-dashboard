# Spalla Dashboard — API Reference

> Base URL (production): `https://spalla-backend.up.railway.app`
> Base URL (local dev): `http://localhost:9999`
> All responses: `Content-Type: application/json`
> Authentication: `Authorization: Bearer <access_token>` (where required)

---

## Authentication

Spalla uses a custom JWT system backed by the `auth_users` Supabase table.

### Token lifecycle

| Token | TTL | Usage |
|-------|-----|-------|
| `access_token` | 60 min | Every authenticated request |
| `refresh_token` | 7 days | Exchange for new `access_token` |

### Roles

| Role | Access |
|------|--------|
| `equipe` | Default staff — full dashboard |
| `admin` | Admin — same as equipe (reserved for future) |
| `mentorado` | Mentee-facing view (future) |

---

## Endpoints

### Auth

#### `POST /api/auth/register`

Create a new user account.

**Auth required:** No

**Request body**

```json
{
  "email": "heitor@case.com.br",
  "password": "minimo6chars",
  "fullName": "Heitor Lima",
  "role": "equipe"
}
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `email` | string | ✅ | Lowercased before storage |
| `password` | string | ✅ | Min 6 characters |
| `fullName` | string | — | Also accepted as `full_name` |
| `role` | string | — | `equipe` \| `admin` \| `mentorado`. Default: `equipe` |

**Response `201 Created`**

```json
{
  "success": true,
  "user": {
    "id": 42,
    "email": "heitor@case.com.br",
    "full_name": "Heitor Lima",
    "role": "equipe"
  },
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "expires_in": 3600
}
```

**Errors**

| Status | `error` | Cause |
|--------|---------|-------|
| 400 | `Email and password required` | Missing fields |
| 400 | `Password must be at least 6 characters` | Too short |
| 409 | `Email already exists` | Duplicate email |
| 500 | `Registration failed` | DB error |

---

#### `POST /api/auth/login`

Authenticate and receive JWT tokens.

**Auth required:** No

**Request body**

```json
{
  "email": "heitor@case.com.br",
  "password": "minimo6chars"
}
```

**Response `200 OK`**

```json
{
  "success": true,
  "user": {
    "id": 42,
    "email": "heitor@case.com.br",
    "full_name": "Heitor Lima",
    "role": "equipe"
  },
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "expires_in": 3600
}
```

> **Note:** Legacy SHA-256 password hashes are auto-migrated to bcrypt on first successful login.

**Errors**

| Status | `error` | Cause |
|--------|---------|-------|
| 400 | `Email and password required` | Missing fields |
| 401 | `Invalid email or password` | Wrong credentials or user not found |
| 500 | `Login failed` | DB error |

---

#### `POST /api/auth/refresh`

Exchange a refresh token for a new access/refresh token pair.

**Auth required:** No

**Request body**

```json
{
  "refresh_token": "eyJ..."
}
```

**Response `200 OK`**

```json
{
  "success": true,
  "user": { "id": 42, "email": "heitor@case.com.br", "full_name": "Heitor Lima" },
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "expires_in": 3600
}
```

**Errors**

| Status | `error` | Cause |
|--------|---------|-------|
| 400 | `Refresh token required` | Missing field |
| 401 | `Invalid or expired refresh token` | Bad/expired token |

---

#### `POST /api/auth/reset-password`

Request a password reset. Always returns success (prevents email enumeration).

**Auth required:** No

> ⚠️ Email is not actually sent yet — no email service configured. Logs the request server-side.

**Request body**

```json
{ "email": "heitor@case.com.br" }
```

**Response `200 OK`**

```json
{
  "success": true,
  "message": "Se o email existir no sistema, as instrucoes de recuperacao serao enviadas."
}
```

---

#### `GET /api/auth/me`

Validate the current access token and return the logged-in user.

**Auth required:** ✅ `Authorization: Bearer <access_token>`

**Response `200 OK`**

```json
{
  "user": {
    "id": 42,
    "email": "heitor@case.com.br",
    "full_name": "Heitor Lima"
  }
}
```

**Errors**

| Status | `error` | Cause |
|--------|---------|-------|
| 401 | `Missing or invalid token` | No/bad Authorization header |
| 401 | `Invalid or expired token` | Token expired or is a refresh token |

---

### Mentorados

#### `GET /api/mentees`

Returns all mentorados with their email addresses. Used internally to populate the schedule-call form (email not exposed in RLS-protected views).

**Auth required:** No (backend-to-backend, no sensitive data)

**Response `200 OK`**

```json
[
  {
    "id": 7,
    "nome": "João Silva",
    "email": "joao@silva.com"
  }
]
```

> The frontend reads the full mentee list from `vw_god_overview` directly via Supabase client. This endpoint only supplements the email field.

---

### Scheduling

#### `POST /api/schedule-call`

Full scheduling orchestration: creates a Zoom meeting → Google Calendar event → inserts a record in `calls_mentoria`.

**Auth required:** No (called from authenticated frontend session)

**Request body**

```json
{
  "mentorado": "João Silva",
  "mentorado_id": 7,
  "email": "joao@silva.com",
  "tipo": "acompanhamento",
  "data": "2026-04-10",
  "horario": "10:00",
  "duracao": 60,
  "notas": "Revisar metas do mês"
}
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `mentorado` | string | ✅ | Display name |
| `data` | string | ✅ | `YYYY-MM-DD` |
| `mentorado_id` | number | — | If provided, inserts into `calls_mentoria` |
| `email` | string | — | Invited to Zoom + Calendar |
| `tipo` | string | — | `acompanhamento` \| `diagnostico` \| `planejamento` \| `onboarding` \| `estrategia`. Default: `acompanhamento` |
| `horario` | string | — | `HH:MM`. Default: `10:00` |
| `duracao` | number | — | Minutes. Default: `60` |
| `notas` | string | — | Added to calendar description |

**`tipo` → `tipo_call` mapping**

| `tipo` | `tipo_call` (stored) |
|--------|---------------------|
| `acompanhamento`, `conselho`, `qa` | `acompanhamento` |
| `onboarding` | `diagnostico` |
| `estrategia` | `planejamento` |
| anything else | `acompanhamento` |

**Response `200 OK`**

```json
{
  "mentorado": "João Silva",
  "data": "2026-04-10",
  "horario": "10:00",
  "tipo": "acompanhamento",
  "zoom": {
    "meeting_id": "123456789",
    "join_url": "https://zoom.us/j/123456789",
    "password": "abc123"
  },
  "calendar": {
    "event_id": "gcal_event_id",
    "html_link": "https://calendar.google.com/..."
  },
  "supabase": {
    "inserted": true,
    "id": 88
  }
}
```

> Partial success is normal — if Zoom is not configured, `zoom` will contain an error but Calendar and Supabase inserts still proceed.

**Errors**

| Status | `error` | Cause |
|--------|---------|-------|
| 400 | `mentorado and data are required` | Missing required fields |

---

#### `POST /api/zoom/create-meeting`

Create a standalone Zoom meeting without the full scheduling flow.

**Auth required:** No

**Request body**

```json
{
  "topic": "Call Diagnóstico — João Silva",
  "start_time": "2026-04-10T10:00:00",
  "duration": 60,
  "invitees": ["joao@silva.com"]
}
```

**Response `200 OK`**

```json
{
  "meeting_id": "123456789",
  "join_url": "https://zoom.us/j/123456789",
  "password": "abc123",
  "start_url": "https://zoom.us/s/123456789?zak=..."
}
```

---

#### `POST /api/calendar/create-event`

Create a standalone Google Calendar event.

**Auth required:** No

**Request body**

```json
{
  "summary": "Call Diagnóstico — João Silva",
  "start": "2026-04-10T10:00:00",
  "end": "2026-04-10T11:00:00",
  "description": "Zoom: https://zoom.us/j/123",
  "attendees": ["joao@silva.com"],
  "location": "https://zoom.us/j/123"
}
```

**Response `200 OK`**

```json
{
  "event_id": "gcal_event_id",
  "html_link": "https://calendar.google.com/..."
}
```

---

#### `GET /api/calendar/events`

List upcoming Google Calendar events (next 50, from now).

**Auth required:** No

**Response `200 OK`**

```json
[
  {
    "id": "gcal_event_id",
    "summary": "Call — João Silva",
    "start": "2026-04-10T10:00:00-03:00",
    "end": "2026-04-10T11:00:00-03:00",
    "location": "https://zoom.us/j/123",
    "attendees": ["joao@silva.com"]
  }
]
```

---

#### `GET /api/calls/upcoming`

Return all calls from `calls_mentoria`, ordered by date descending (latest first). Limit 500.

**Auth required:** No

**Response `200 OK`**

```json
[
  {
    "id": 88,
    "mentorado_id": 7,
    "data_call": "2026-04-10T10:00:00+00:00",
    "tipo": "acompanhamento",
    "tipo_call": "acompanhamento",
    "duracao_minutos": 60,
    "zoom_meeting_id": "123456789",
    "zoom_topic": "Call Acompanhamento — João Silva",
    "status": "processando",
    "link_gravacao": "https://zoom.us/j/...",
    "observacoes_equipe": "Revisar metas do mês"
  }
]
```

---

### Google Sheets Sync

The backend syncs `pagamentos_sheet` and `contratos_sheet` Google Sheets into Supabase tables on a background loop (every 30 min by default).

#### `GET /api/sheets/status`

**Auth required:** No

**Response `200 OK`**

```json
{
  "sheets_configured": true,
  "last_sync": "2026-03-20T18:30:00",
  "last_result": { "updated": 14, "errors": 0 },
  "payments_sheet": "1abc...spreadsheet_id",
  "contracts_sheet": "1def...spreadsheet_id"
}
```

---

#### `POST /api/sheets/sync`

Trigger an immediate manual sync.

**Auth required:** No

**Request body:** Empty

**Response `200 OK`**

```json
{
  "updated": 14,
  "created": 2,
  "errors": 0,
  "duration_ms": 4201
}
```

---

### Media (Hetzner S3)

WhatsApp media files (audio, video, images) are stored in a Hetzner S3-compatible bucket. The backend provides two endpoints to access them.

#### `GET /api/media/presign?key=<s3_key>`

Generate a time-limited presigned URL for direct S3 access.

**Auth required:** No

**Query parameters**

| Param | Required | Example |
|-------|----------|---------|
| `key` | ✅ | `evolution-api/{uuid}/{chatId}/audioMessage/abc.ogg` |

**Response `200 OK`**

```json
{
  "url": "https://s3.hetzner.com/bucket/...?X-Amz-Signature=...",
  "bucket": "spalla-media",
  "endpoint": "fsn1.your-objectstorage.com"
}
```

**Errors**

| Status | `error` | Cause |
|--------|---------|-------|
| 400 | `key parameter required` | Missing `key` param |
| 500 | — | S3 presign failure |

---

#### `GET /api/media/stream?key=<s3_key>`

Stream the S3 file through the backend (avoids CORS issues on the frontend).

**Auth required:** No

**Query parameters:** Same as `/api/media/presign`

**Response `200 OK`**
Raw binary stream with correct `Content-Type` and `Cache-Control: public, max-age=3600`.

**Errors**

| Status | Cause |
|--------|-------|
| 404 | File not found at S3 key |
| 403 | Presign failed — bad credentials or wrong key |

---

### Storage & Semantic Search

The storage system processes uploaded files (PDF, DOCX, XLSX, CSV, images, audio/video) through a pipeline: extract text → chunk → embed → store in `sp_arquivos_chunks` with pgvector.

#### `POST /api/storage/process`

Trigger the processing pipeline for a file that's already uploaded to S3 and registered in `sp_arquivos`.

**Auth required:** No

**Request body**

```json
{ "arquivo_id": "uuid-of-arquivo" }
```

**Processing pipeline (async, runs in background thread)**

1. Download file from Supabase Storage / S3
2. Extract text (PDF via PyMuPDF, DOCX, XLSX, CSV, images via Gemini/OpenAI Vision, audio via Whisper)
3. Chunk text (heading-aware or token-based, ~500 tokens, 50-token overlap)
4. Embed chunks (Voyage AI `voyage-3-lite` or OpenAI `text-embedding-3-small`)
5. Store chunks in `sp_arquivos_chunks` with `embedding` (pgvector)
6. Update `sp_arquivos.status_processamento` = `concluido`

**Response `200 OK`** (returns immediately, processing is async)

```json
{ "status": "processing", "arquivo_id": "uuid-of-arquivo" }
```

**Errors**

| Status | `error` | Cause |
|--------|---------|-------|
| 400 | `arquivo_id is required` | Missing field |

---

#### `POST /api/storage/search`

Search across all processed file chunks using semantic, keyword, or hybrid search.

**Auth required:** No

**Request body**

```json
{
  "query": "protocolo de atendimento para clientes inativos",
  "mode": "hybrid",
  "limit": 10,
  "filters": {
    "entidade_tipo": "mentorado",
    "entidade_id": 7
  }
}
```

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| `query` | string | — | Required. The search text |
| `mode` | string | `hybrid` | `semantic` \| `keyword` \| `hybrid` |
| `limit` | number | `10` | Max 50 |
| `filters.entidade_tipo` | string | — | `mentorado` \| `equipe` \| `global` |
| `filters.entidade_id` | number | — | Filter by specific entity ID |

**Response `200 OK`**

```json
{
  "results": [
    {
      "chunk_id": "uuid",
      "arquivo_id": "uuid",
      "arquivo_nome": "protocolo-2026.pdf",
      "mentorado_nome": "João Silva",
      "texto": "...chunk text...",
      "score": 0.87,
      "score_type": "cosine",
      "page_num": 3
    }
  ],
  "total": 4,
  "query": "protocolo de atendimento para clientes inativos",
  "mode": "hybrid",
  "query_time_ms": 320
}
```

---

#### `GET /api/storage/files?entidade_tipo=<type>&entidade_id=<id>`

List all processed files for a given entity.

**Auth required:** No

**Query parameters**

| Param | Required | Example |
|-------|----------|---------|
| `entidade_tipo` | — | `mentorado` |
| `entidade_id` | — | `7` |

**Response `200 OK`**

```json
[
  {
    "id": "uuid",
    "nome_original": "relatorio-abril.pdf",
    "tipo_mime": "application/pdf",
    "tamanho_bytes": 204800,
    "status_processamento": "concluido",
    "total_chunks": 12,
    "entidade_tipo": "mentorado",
    "entidade_id": 7,
    "storage_path": "arquivos/mentorado/7/relatorio-abril.pdf",
    "created_at": "2026-03-20T14:00:00Z"
  }
]
```

---

#### `GET /api/storage/status`

Storage system overview: files, sizes, processing queue.

**Auth required:** No

**Response `200 OK`**

```json
{
  "overview": [
    {
      "entidade_tipo": "mentorado",
      "total_arquivos": 34,
      "total_chunks": 412,
      "tamanho_total_mb": 128.4,
      "pendentes": 2,
      "com_erro": 0
    }
  ],
  "queue": [
    {
      "arquivo_id": "uuid",
      "nome_original": "novo-arquivo.pdf",
      "status_processamento": "pendente",
      "created_at": "2026-03-20T15:00:00Z"
    }
  ],
  "embedding_provider": "voyage",
  "embedding_dims": 512,
  "voyage_configured": true,
  "openai_configured": true,
  "gemini_configured": true,
  "vision_provider": "gemini"
}
```

---

#### `POST /api/storage/reprocess`

Reprocess files stuck in `pendente` or `erro` status.

**Auth required:** No

**Request body**

```json
{ "status": "pendente" }
```

| `status` | Effect |
|----------|--------|
| `pendente` (default) | Reprocess all pending files |
| `erro` | Reprocess all failed files |
| `all` | Reprocess both `pendente` and `erro` |

**Response `200 OK`**

```json
{ "queued": 3, "status_filter": "pendente" }
```

---

#### `POST /api/storage/test`

Debug endpoint — runs a test embedding to verify the pipeline is configured correctly.

**Auth required:** No

**Response `200 OK`**

```json
{
  "status": "ok",
  "provider": "voyage",
  "dims": 512,
  "first_values": [0.012, -0.034, 0.091, 0.002, -0.055],
  "voyage_key_set": true,
  "openai_key_set": true
}
```

---

### Welcome Flow

#### `POST /api/welcome-flow/register`

Register a new mentorado from the onboarding wizard. **Public endpoint** — no auth required. Auto-generates a temporary password from the mentee's first name + last 4 digits of their WhatsApp number.

**Auth required:** No (public, called from onboarding page)

**Request body**

```json
{
  "nome": "João Silva",
  "email": "joao@silva.com",
  "whatsapp": "11999990000"
}
```

| Field | Required | Notes |
|-------|----------|-------|
| `nome` | ✅ | Full name |
| `email` | ✅ | Used as login identifier |
| `whatsapp` | — | Used to derive temp password: `{first_name}{last4digits}` |

**Response `201 Created`**

```json
{
  "success": true,
  "user_id": 42,
  "credentials": {
    "email": "joao@silva.com",
    "temp_password": "joao0000"
  }
}
```

**Response `200 OK`** (if user already exists)

```json
{
  "success": true,
  "already_exists": true,
  "user_id": 42,
  "message": "User already exists with this email"
}
```

---

### Evolution API Proxy

All requests to `/api/evolution/*` are proxied transparently to the Evolution WhatsApp instance. This avoids CORS issues and keeps the Evolution API key server-side.

**Methods supported:** `GET`, `POST`, `PUT`, `DELETE`

**Proxied path:** `/api/evolution{path}` → `{EVOLUTION_BASE}{path}`

**Auth:** The backend injects `apikey: {EVOLUTION_API_KEY}` automatically.

**Example requests**

```bash
# List messages for a chat
GET /api/evolution/chat/findMessages/case-spalla?where[key][remoteJid]=5511999990000@s.whatsapp.net

# Send text message
POST /api/evolution/message/sendText/case-spalla
{ "number": "5511999990000", "text": "Olá!" }

# Fetch contacts
GET /api/evolution/chat/findContacts/case-spalla
```

> See [Evolution API docs](https://doc.evolution-api.com) for the full endpoint reference. The `case-spalla` part is the instance name configured via `EVOLUTION_INSTANCE` env var.

---

#### `GET /api/evolution/instance-uuid`

Returns the Evolution instance name and S3 bucket info (for media path resolution).

**Response `200 OK`**

```json
{
  "instance": "case-spalla",
  "note": "UUID discovery not yet automated. Please check S3 bucket manually.",
  "s3_bucket": "spalla-media",
  "s3_endpoint": "fsn1.your-objectstorage.com"
}
```

---

### System

#### `GET /api/health`

Server health check — returns configuration status for all integrations.

**Auth required:** No

**Response `200 OK`**

```json
{
  "status": "ok",
  "zoom_configured": true,
  "gcal_configured": true,
  "supabase_configured": true,
  "sheets_configured": true,
  "openai_configured": true,
  "storage_search": true
}
```

---

## Data Sources (Supabase Views)

The frontend reads most data directly from Supabase via the JS client. These are the primary views:

| View | Data | Used by |
|------|------|---------|
| `vw_god_overview` | Full mentee list with all KPI fields | Dashboard, Mentees page |
| `vw_god_cohort` | Cohort distribution by phase + risk | Dashboard stats |
| `vw_god_pendencias` | Unanswered interactions (`respondido = false`) | Pendências widget, msgs count |
| `vw_pa_pipeline` | Plano de Ação execution pipeline | PA board |
| `vw_god_financeiro` | Financial status per mentee | CFO Financeiro page |
| `vw_fin_snapshots` | Monthly financial snapshots | CFO KPIs |
| `calls_mentoria` | All scheduled/recorded calls | Calls tab |
| `sp_arquivos` | Uploaded file registry | Arquivos page |
| `vw_storage_overview` | Storage stats by entity type | Storage status |
| `vw_processamento_fila` | Files pending/errored processing | Storage queue |
| `interacoes_mentoria` | Raw WhatsApp/interaction log | Pendências, interaction history |

---

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `SUPABASE_URL` | ✅ | Supabase project URL |
| `SUPABASE_SERVICE_KEY` | ✅ | Service role key (full access) |
| `SUPABASE_ANON_KEY` | — | Anon key (fallback) |
| `JWT_SECRET` | ✅ | HMAC secret for JWT signing. Generate: `openssl rand -hex 32` |
| `ZOOM_ACCOUNT_ID` | — | Zoom Server-to-Server OAuth |
| `ZOOM_CLIENT_ID` | — | Zoom OAuth client ID |
| `ZOOM_CLIENT_SECRET` | — | Zoom OAuth client secret |
| `GOOGLE_SA_JSON` | — | Google Service Account JSON (base64 or raw) |
| `PAYMENTS_SHEET_ID` | — | Google Sheets ID for payments |
| `CONTRACTS_SHEET_ID` | — | Google Sheets ID for contracts |
| `EVOLUTION_API_KEY` | — | Evolution WhatsApp API key |
| `EVOLUTION_BASE` | — | Evolution instance base URL |
| `EVOLUTION_INSTANCE` | — | Instance name (e.g. `case-spalla`) |
| `S3_ENDPOINT` | — | Hetzner S3 endpoint (e.g. `fsn1.your-objectstorage.com`) |
| `S3_BUCKET` | — | S3 bucket name |
| `AWS_ACCESS_KEY_ID` | — | S3 access key |
| `AWS_SECRET_ACCESS_KEY` | — | S3 secret key |
| `OPENAI_API_KEY` | — | OpenAI (Whisper + Vision + embeddings fallback) |
| `VOYAGE_API_KEY` | — | Voyage AI (primary embedding provider) |
| `GEMINI_API_KEY` | — | Gemini (Vision fallback for images) |
| `PORT` | — | Backend port. Default: `9999` |

---

## Error Format

All error responses follow this shape:

```json
{ "error": "Human-readable error message" }
```

---

## Rate Limits & Notes

- No rate limiting is implemented at the backend level — rely on Railway's request limits and Supabase's connection pooler
- The Evolution proxy has a 30-second timeout per request
- Storage processing (`/api/storage/process`, `/api/storage/reprocess`) runs in background threads — the response returns immediately
- Reprocessing staggers 5 files per second to avoid overwhelming OpenAI/Voyage rate limits
