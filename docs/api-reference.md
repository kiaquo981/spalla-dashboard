# Spalla Dashboard — API Reference

> **Base URL (production):** `https://spalla-backend.up.railway.app`
> **Base URL (local dev):** `http://localhost:9999`
> **Protocol:** HTTPS only in production
> **Content-Type:** `application/json` for all requests and responses

---

## Contents

- [Authentication](#authentication)
- [Quick Start](#quick-start)
- [Core Concepts](#core-concepts)
- [Endpoints](#endpoints)
  - [Auth](#auth)
  - [Mentorados](#mentorados)
  - [Scheduling](#scheduling)
  - [Google Sheets Sync](#google-sheets-sync)
  - [Media (Hetzner S3)](#media-hetzner-s3)
  - [Storage & Semantic Search](#storage--semantic-search)
  - [Welcome Flow](#welcome-flow)
  - [Evolution API Proxy](#evolution-api-proxy)
  - [System](#system)
- [Supabase Direct Access](#supabase-direct-access)
- [Realtime Subscriptions](#realtime-subscriptions)
- [Data Sources](#data-sources)
- [Environment Variables](#environment-variables)
- [Error Reference](#error-reference)
- [Limits & Timeouts](#limits--timeouts)

---

## Authentication

Spalla uses a custom JWT system backed by the `auth_users` Supabase table. There is no OAuth or external identity provider — authentication is handled entirely by the backend.

### Token lifecycle

| Token | TTL | Purpose |
|-------|-----|---------|
| `access_token` | 60 minutes | Sent on every authenticated request |
| `refresh_token` | 7 days | Exchange for a new token pair without re-login |

Both tokens are HMAC-SHA256 signed JWTs. The secret is set via the `JWT_SECRET` environment variable.

### Roles

| Role | Description |
|------|-------------|
| `equipe` | Default staff role — full dashboard access |
| `admin` | Reserved for future admin-specific features; currently same access as `equipe` |
| `mentorado` | Mentee-facing role — reserved for future mentee portal |

### Sending the token

Include the access token in the `Authorization` header on every authenticated request:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Token refresh strategy

When a `401 Invalid or expired token` response is received, use the stored `refresh_token` to obtain a new pair via `POST /api/auth/refresh`. On success, replace both tokens in local storage and retry the original request.

---

## Quick Start

Three steps to make your first authenticated request.

### Step 1 — Login

```bash
curl -s -X POST https://spalla-backend.up.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"heitor@case.com.br","password":"minimo6chars"}' | jq .
```

Response:

```json
{
  "success": true,
  "user": { "id": 42, "email": "heitor@case.com.br", "full_name": "Heitor Lima" },
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "expires_in": 3600
}
```

### Step 2 — Store the token

```bash
TOKEN="eyJ..."    # access_token from login response
REFRESH="eyJ..."  # refresh_token from login response
```

### Step 3 — Make an authenticated request

```bash
curl -s https://spalla-backend.up.railway.app/api/auth/me \
  -H "Authorization: Bearer $TOKEN" | jq .
```

Response:

```json
{
  "user": { "id": 42, "email": "heitor@case.com.br", "full_name": "Heitor Lima" }
}
```

---

## Core Concepts

### Data architecture

Spalla has two distinct data access patterns:

**1. Backend API (HTTP)** — used for operations that require privileged access or orchestration across multiple services (auth, scheduling, file processing, WhatsApp proxy). The backend holds the Supabase service key and Evolution API key — these never reach the browser.

**2. Supabase Direct (JS client)** — used by the frontend for all read-heavy dashboard data. The frontend connects directly to Supabase using the anon key and reads from RLS-protected views. No backend roundtrip is needed for listing mentees, cohort stats, or financial data.

```
Browser
  ├── Supabase JS client  ──→  Supabase (views, realtime subscriptions)
  └── fetch()            ──→  Backend API  ──→  Supabase (service key ops)
                                             ──→  Zoom, GCal, Evolution, S3
```

### Supabase views

The dashboard aggregates data through PostgreSQL views. All views are prefixed with `vw_`. The frontend always reads from views, never from raw tables directly (except `calls_mentoria`, `sp_arquivos`, and `interacoes_mentoria`).

### Pending messages (msgs_pendentes_resposta)

Each mentee's `msgs_pendentes_resposta` count is derived exclusively from `vw_god_pendencias` (rows where `interacoes_mentoria.respondido = false`). The dashboard reconciles this after every data load so the KPI widget and per-mentee counts are always in sync.

---

## Endpoints

---

### Auth

---

#### `POST /api/auth/register`

Create a new user account. Not exposed in the public UI — used for onboarding team members directly.

**Auth required:** No

**Request body**

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `email` | string | ✅ | Lowercased before storage. Must be unique. |
| `password` | string | ✅ | Minimum 6 characters |
| `fullName` | string | — | Also accepted as `full_name` |
| `role` | string | — | `equipe` \| `admin` \| `mentorado`. Defaults to `equipe` |

```bash
curl -s -X POST https://spalla-backend.up.railway.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "heitor@case.com.br",
    "password": "minimo6chars",
    "fullName": "Heitor Lima",
    "role": "equipe"
  }' | jq .
```

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
| 400 | `Email and password required` | One or both fields missing |
| 400 | `Password must be at least 6 characters` | Password too short |
| 409 | `Email already exists` | Email already registered |
| 500 | `Registration failed` | Database write error |

---

#### `POST /api/auth/login`

Authenticate with email and password. Returns a JWT token pair.

**Auth required:** No

> **Note:** Legacy SHA-256 password hashes are transparently migrated to bcrypt on the first successful login. No action required from the caller.

| Field | Type | Required |
|-------|------|----------|
| `email` | string | ✅ |
| `password` | string | ✅ |

```bash
curl -s -X POST https://spalla-backend.up.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"heitor@case.com.br","password":"minimo6chars"}' | jq .
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

**Errors**

| Status | `error` | Cause |
|--------|---------|-------|
| 400 | `Email and password required` | Missing fields |
| 401 | `Invalid email or password` | Wrong credentials or user does not exist |
| 500 | `Login failed` | Database read error |

---

#### `POST /api/auth/refresh`

Exchange a `refresh_token` for a new access/refresh token pair. Call this when `access_token` expires (after 60 min) without requiring the user to re-enter their password.

**Auth required:** No

| Field | Type | Required |
|-------|------|----------|
| `refresh_token` | string | ✅ |

```bash
curl -s -X POST https://spalla-backend.up.railway.app/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d "{\"refresh_token\":\"$REFRESH\"}" | jq .
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
| 400 | `Refresh token required` | Field missing |
| 401 | `Invalid or expired refresh token` | Token tampered, malformed, or older than 7 days |

---

#### `POST /api/auth/reset-password`

Request a password reset. Always returns `200` regardless of whether the email exists — this prevents user enumeration.

> ⚠️ **Email delivery not yet implemented.** No email is actually sent. The request is logged server-side. Implement this endpoint by wiring it to a transactional email provider (Resend, SendGrid, Postmark) and generating a time-limited reset token.

**Auth required:** No

| Field | Type | Required |
|-------|------|----------|
| `email` | string | ✅ |

```bash
curl -s -X POST https://spalla-backend.up.railway.app/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{"email":"heitor@case.com.br"}' | jq .
```

**Response `200 OK`** (always, regardless of email existence)

```json
{
  "success": true,
  "message": "Se o email existir no sistema, as instrucoes de recuperacao serao enviadas."
}
```

---

#### `GET /api/auth/me`

Validate the current access token and return the logged-in user profile. Use this on app startup to verify a stored token is still valid.

**Auth required:** ✅

```bash
curl -s https://spalla-backend.up.railway.app/api/auth/me \
  -H "Authorization: Bearer $TOKEN" | jq .
```

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
| 401 | `Missing or invalid token` | No `Authorization` header, or header malformed |
| 401 | `Invalid or expired token` | Token signature invalid, expired, or is a refresh token |

---

### Mentorados

---

#### `GET /api/mentees`

Returns all mentorados with their email addresses. This supplements the RLS-protected Supabase views, which do not expose email for privacy reasons. Used internally by the schedule-call form to populate the email invite field.

**Auth required:** No

> The full mentee dataset (phases, risks, KPIs, financial status) is read by the frontend directly from `vw_god_overview` via the Supabase JS client. This endpoint only fills the email gap.

```bash
curl -s https://spalla-backend.up.railway.app/api/mentees | jq .
```

**Response `200 OK`**

```json
[
  {
    "id": 7,
    "nome": "João Silva",
    "email": "joao@silva.com"
  },
  {
    "id": 12,
    "nome": "Maria Oliveira",
    "email": "maria@oliveira.com"
  }
]
```

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | integer | No | Mentee ID — matches `id` in `vw_god_overview` |
| `nome` | string | No | Full name |
| `email` | string | Yes | Login email (may be null for legacy records) |

---

### Scheduling

The scheduling system orchestrates three external services in a single call: Zoom (video meeting), Google Calendar (event with invites), and Supabase (persistent record in `calls_mentoria`). Each sub-operation is independent — a failure in one does not abort the others.

---

#### `POST /api/schedule-call`

Full scheduling orchestration: create Zoom meeting → create Google Calendar event → insert `calls_mentoria` record. Partial success is normal when some integrations are not configured.

**Auth required:** No

| Field | Type | Required | Format / Constraints |
|-------|------|----------|----------------------|
| `mentorado` | string | ✅ | Display name used in Zoom topic and Calendar event title |
| `data` | string | ✅ | `YYYY-MM-DD` |
| `mentorado_id` | integer | — | If provided, a record is inserted in `calls_mentoria` |
| `email` | string | — | Invited to both Zoom meeting and Google Calendar event |
| `tipo` | string | — | `acompanhamento` \| `diagnostico` \| `planejamento` \| `onboarding` \| `estrategia`. Default: `acompanhamento` |
| `horario` | string | — | `HH:MM` (24h, Brasília). Default: `10:00` |
| `duracao` | integer | — | Duration in minutes. Default: `60` |
| `notas` | string | — | Appended to the Calendar event description and stored in `observacoes_equipe` |

**`tipo` → `tipo_call` mapping** (what gets stored in `calls_mentoria.tipo_call`)

| Input `tipo` | Stored `tipo_call` |
|---|---|
| `acompanhamento`, `conselho`, `qa` | `acompanhamento` |
| `onboarding`, `diagnostico` | `diagnostico` |
| `estrategia`, `planejamento` | `planejamento` |
| anything else | `acompanhamento` |

```bash
curl -s -X POST https://spalla-backend.up.railway.app/api/schedule-call \
  -H "Content-Type: application/json" \
  -d '{
    "mentorado": "João Silva",
    "mentorado_id": 7,
    "email": "joao@silva.com",
    "tipo": "acompanhamento",
    "data": "2026-04-10",
    "horario": "10:00",
    "duracao": 60,
    "notas": "Revisar metas do mês"
  }' | jq .
```

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
    "event_id": "gcal_event_id_string",
    "html_link": "https://calendar.google.com/calendar/event?eid=..."
  },
  "supabase": {
    "inserted": true,
    "id": 88
  }
}
```

When an integration is not configured, its key contains an `error` string instead:

```json
{
  "zoom": { "error": "Zoom not configured" },
  "calendar": { "event_id": "abc", "html_link": "https://..." },
  "supabase": { "inserted": true, "id": 88 }
}
```

**Errors**

| Status | `error` | Cause |
|--------|---------|-------|
| 400 | `mentorado and data are required` | Missing `mentorado` or `data` fields |

---

#### `POST /api/zoom/create-meeting`

Create a standalone Zoom meeting without triggering Calendar or Supabase inserts. Useful for ad-hoc meetings not associated with a specific mentee record.

**Auth required:** No

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `topic` | string | — | Meeting title shown in Zoom. Default: `Mentoria` |
| `start_time` | string | — | ISO 8601 datetime: `YYYY-MM-DDTHH:MM:SS`. Defaults to current time |
| `duration` | integer | — | Duration in minutes. Default: `60` |
| `invitees` | array[string] | — | Email addresses to invite |

```bash
curl -s -X POST https://spalla-backend.up.railway.app/api/zoom/create-meeting \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "Call Diagnóstico — João Silva",
    "start_time": "2026-04-10T10:00:00",
    "duration": 60,
    "invitees": ["joao@silva.com"]
  }' | jq .
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

| Field | Type | Description |
|-------|------|-------------|
| `meeting_id` | string | Zoom meeting ID — store in `calls_mentoria.zoom_meeting_id` |
| `join_url` | string | Participant URL |
| `password` | string | Meeting password |
| `start_url` | string | Host URL with ZAK token — expires after ~2h |

---

#### `POST /api/calendar/create-event`

Create a standalone Google Calendar event on the configured service account calendar.

**Auth required:** No

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `summary` | string | — | Event title |
| `start` | string | — | ISO 8601: `YYYY-MM-DDTHH:MM:SS` |
| `end` | string | — | ISO 8601: `YYYY-MM-DDTHH:MM:SS` |
| `description` | string | — | Event body (HTML supported) |
| `attendees` | array[string] | — | Email addresses — receive Google Calendar invite |
| `location` | string | — | Physical address or meeting URL |

```bash
curl -s -X POST https://spalla-backend.up.railway.app/api/calendar/create-event \
  -H "Content-Type: application/json" \
  -d '{
    "summary": "Call Diagnóstico — João Silva",
    "start": "2026-04-10T10:00:00",
    "end": "2026-04-10T11:00:00",
    "description": "Zoom: https://zoom.us/j/123",
    "attendees": ["joao@silva.com"],
    "location": "https://zoom.us/j/123"
  }' | jq .
```

**Response `200 OK`**

```json
{
  "event_id": "gcal_event_id_string",
  "html_link": "https://calendar.google.com/calendar/event?eid=..."
}
```

---

#### `GET /api/calendar/events`

List the next 50 upcoming Google Calendar events, ordered chronologically from now.

**Auth required:** No

```bash
curl -s https://spalla-backend.up.railway.app/api/calendar/events | jq .
```

**Response `200 OK`**

```json
[
  {
    "id": "gcal_event_id",
    "summary": "Call Acompanhamento — João Silva",
    "start": "2026-04-10T10:00:00-03:00",
    "end": "2026-04-10T11:00:00-03:00",
    "location": "https://zoom.us/j/123456789",
    "attendees": ["joao@silva.com", "heitor@case.com.br"]
  }
]
```

---

#### `GET /api/calls/upcoming`

Return all records from `calls_mentoria`, ordered by `data_call` descending (most recent first). Hard limit of 500 rows.

**Auth required:** No

```bash
curl -s https://spalla-backend.up.railway.app/api/calls/upcoming | jq .
```

**Response `200 OK`**

```json
[
  {
    "id": 88,
    "mentorado_id": 7,
    "data_call": "2026-04-10T13:00:00+00:00",
    "tipo": "acompanhamento",
    "tipo_call": "acompanhamento",
    "duracao_minutos": 60,
    "zoom_meeting_id": "123456789",
    "zoom_topic": "Call Acompanhamento — João Silva",
    "status": "processando",
    "link_gravacao": null,
    "observacoes_equipe": "Revisar metas do mês",
    "status_call": null
  }
]
```

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | integer | No | Primary key |
| `mentorado_id` | integer | Yes | FK to `mentorados.id` |
| `data_call` | string (ISO 8601) | No | Call datetime with timezone |
| `tipo_call` | string | No | Normalized type: `acompanhamento` \| `diagnostico` \| `planejamento` |
| `duracao_minutos` | integer | Yes | |
| `zoom_meeting_id` | string | Yes | |
| `status_call` | string | Yes | `realizada` \| `cancelada` \| `processando` |
| `link_gravacao` | string | Yes | Zoom recording URL |
| `link_transcricao` | string | Yes | Transcript URL |

---

### Google Sheets Sync

The backend maintains a background loop that syncs two Google Sheets into Supabase tables. The loop interval defaults to 30 minutes and runs automatically on server start.

- `PAYMENTS_SHEET_ID` → syncs financial data into the payments table used by `vw_god_financeiro`
- `CONTRACTS_SHEET_ID` → syncs contract records

---

#### `GET /api/sheets/status`

Returns the current sync state without triggering a sync.

**Auth required:** No

```bash
curl -s https://spalla-backend.up.railway.app/api/sheets/status | jq .
```

**Response `200 OK`**

```json
{
  "sheets_configured": true,
  "last_sync": "2026-03-20T18:30:00",
  "last_result": {
    "updated": 14,
    "created": 2,
    "errors": 0
  },
  "payments_sheet": "1abc...spreadsheet_id",
  "contracts_sheet": "1def...spreadsheet_id"
}
```

When `sheets_configured` is `false`, `last_sync`, `last_result`, and sheet IDs will be `null`.

---

#### `POST /api/sheets/sync`

Trigger an immediate manual sync, bypassing the 30-minute interval. Blocks until the sync completes.

**Auth required:** No

**Request body:** Empty (`{}` or no body)

```bash
curl -s -X POST https://spalla-backend.up.railway.app/api/sheets/sync | jq .
```

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

WhatsApp media files (audio messages, images, video, documents) are stored in a Hetzner Object Storage bucket (S3-compatible API). The backend exposes two endpoints to access them securely without exposing S3 credentials to the browser.

Choose between the two endpoints based on use case:
- **`/presign`** — gives the browser a temporary signed URL it can use directly (best for large files, streaming audio/video)
- **`/stream`** — backend fetches and proxies the file to the browser (use when the browser would hit CORS issues with the presigned URL)

---

#### `GET /api/media/presign`

Generate a time-limited presigned URL for direct S3 access. The URL is valid for approximately 1 hour.

**Auth required:** No

**Query parameters**

| Param | Type | Required | Example |
|-------|------|----------|---------|
| `key` | string | ✅ | `evolution-api/{uuid}/{chatId}/audioMessage/abc.ogg` |

```bash
curl -s "https://spalla-backend.up.railway.app/api/media/presign?key=evolution-api/uuid/5511999990000%40s.whatsapp.net/audioMessage/abc.ogg" | jq .
```

**Response `200 OK`**

```json
{
  "url": "https://fsn1.your-objectstorage.com/spalla-media/evolution-api/...?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=...",
  "bucket": "spalla-media",
  "endpoint": "fsn1.your-objectstorage.com"
}
```

**Errors**

| Status | `error` | Cause |
|--------|---------|-------|
| 400 | `key parameter required` | `key` query param missing |
| 500 | — | S3 credentials not configured or key path malformed |

---

#### `GET /api/media/stream`

Fetch the S3 object and stream it through the backend. Preserves the correct `Content-Type` and adds `Cache-Control: public, max-age=3600`.

**Auth required:** No

**Query parameters:** Same as `/api/media/presign`

```bash
# Play audio directly in terminal (requires mpv or ffplay)
curl -s "https://spalla-backend.up.railway.app/api/media/stream?key=evolution-api/.../abc.ogg" -o audio.ogg
```

**Response `200 OK`** — Raw binary with appropriate `Content-Type` header.

**Errors**

| Status | Cause |
|--------|-------|
| 400 | `key` query param missing |
| 403 | Presign failed — bad credentials or malformed key |
| 404 | Object not found at the specified S3 key |

---

### Storage & Semantic Search

The storage system processes uploaded files through a pipeline: download → extract text → chunk → embed → store in `sp_arquivos_chunks` with pgvector. Processing is always asynchronous — the API returns immediately and processing runs in a background thread.

**Supported file types**

| Type | Extraction method |
|------|-----------------|
| PDF | PyMuPDF (text layer) |
| DOCX | python-docx |
| XLSX, CSV | openpyxl / csv |
| Images (PNG, JPG, WEBP) | Gemini Vision or OpenAI Vision |
| Audio/Video (MP3, MP4, OGG, etc.) | OpenAI Whisper |

**Embedding providers** (in priority order)

| Provider | Model | Dimensions | Configured via |
|----------|-------|-----------|----------------|
| Voyage AI | `voyage-3-lite` | 512 | `VOYAGE_API_KEY` |
| OpenAI | `text-embedding-3-small` | 1536 | `OPENAI_API_KEY` |

---

#### `POST /api/storage/process`

Trigger the processing pipeline for a file already registered in `sp_arquivos`. The file must already be uploaded to Supabase Storage or S3.

**Auth required:** No

| Field | Type | Required |
|-------|------|----------|
| `arquivo_id` | string (UUID) | ✅ |

```bash
curl -s -X POST https://spalla-backend.up.railway.app/api/storage/process \
  -H "Content-Type: application/json" \
  -d '{"arquivo_id":"550e8400-e29b-41d4-a716-446655440000"}' | jq .
```

**Response `200 OK`** (immediate — processing continues in background)

```json
{ "status": "processing", "arquivo_id": "550e8400-e29b-41d4-a716-446655440000" }
```

Poll `GET /api/storage/files` or `GET /api/storage/status` to check when processing completes. The `sp_arquivos.status_processamento` field transitions: `pendente` → `processando` → `concluido` | `erro`.

**Errors**

| Status | `error` | Cause |
|--------|---------|-------|
| 400 | `arquivo_id is required` | Field missing or empty |

---

#### `POST /api/storage/search`

Semantic, keyword, or hybrid search across all processed file chunks. Uses pgvector cosine similarity for semantic mode.

**Auth required:** No

| Field | Type | Required | Default | Constraints |
|-------|------|----------|---------|-------------|
| `query` | string | ✅ | — | Natural language query |
| `mode` | string | — | `hybrid` | `semantic` \| `keyword` \| `hybrid` |
| `limit` | integer | — | `10` | Max `50` |
| `filters.entidade_tipo` | string | — | — | `mentorado` \| `equipe` \| `global` |
| `filters.entidade_id` | integer | — | — | Filter to a specific entity |

```bash
curl -s -X POST https://spalla-backend.up.railway.app/api/storage/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "protocolo de atendimento para clientes inativos",
    "mode": "hybrid",
    "limit": 5,
    "filters": { "entidade_tipo": "mentorado", "entidade_id": 7 }
  }' | jq .
```

**Response `200 OK`**

```json
{
  "results": [
    {
      "chunk_id": "uuid",
      "arquivo_id": "uuid",
      "arquivo_nome": "protocolo-2026.pdf",
      "mentorado_nome": "João Silva",
      "texto": "...extracted chunk text (up to ~500 tokens)...",
      "score": 0.87,
      "score_type": "cosine",
      "page_num": 3
    }
  ],
  "total": 1,
  "query": "protocolo de atendimento para clientes inativos",
  "mode": "hybrid",
  "query_time_ms": 320
}
```

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `score` | float | No | 0–1. Higher is more similar. `cosine` for semantic, `rank` for keyword |
| `score_type` | string | No | `cosine` \| `rank` \| `combined` |
| `page_num` | integer | Yes | Page number within the source document (PDF only) |

---

#### `GET /api/storage/files`

List all files registered in `sp_arquivos` for a given entity.

**Auth required:** No

**Query parameters**

| Param | Type | Required | Example |
|-------|------|----------|---------|
| `entidade_tipo` | string | — | `mentorado` \| `equipe` \| `global` |
| `entidade_id` | integer | — | `7` |

Both params are optional — omit both to list all files.

```bash
# All files for mentee 7
curl -s "https://spalla-backend.up.railway.app/api/storage/files?entidade_tipo=mentorado&entidade_id=7" | jq .

# All files in the system
curl -s "https://spalla-backend.up.railway.app/api/storage/files" | jq .
```

**Response `200 OK`**

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
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

| `status_processamento` | Meaning |
|------------------------|---------|
| `pendente` | Registered, not yet processed |
| `processando` | Pipeline running in background |
| `concluido` | Fully processed, chunks available for search |
| `erro` | Processing failed — check server logs for details |

---

#### `GET /api/storage/status`

System-wide storage overview: file counts, sizes, processing queue, and provider configuration.

**Auth required:** No

```bash
curl -s https://spalla-backend.up.railway.app/api/storage/status | jq .
```

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
    },
    {
      "entidade_tipo": "global",
      "total_arquivos": 5,
      "total_chunks": 87,
      "tamanho_total_mb": 14.2,
      "pendentes": 0,
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

Re-queue files stuck in `pendente` or `erro` status. Processes 5 files per second to avoid overwhelming Voyage AI / OpenAI rate limits.

**Auth required:** No

| Field | Type | Required | Values |
|-------|------|----------|--------|
| `status` | string | — | `pendente` (default) \| `erro` \| `all` |

```bash
# Reprocess all failed files
curl -s -X POST https://spalla-backend.up.railway.app/api/storage/reprocess \
  -H "Content-Type: application/json" \
  -d '{"status":"erro"}' | jq .

# Reprocess everything (pendente + erro)
curl -s -X POST https://spalla-backend.up.railway.app/api/storage/reprocess \
  -H "Content-Type: application/json" \
  -d '{"status":"all"}' | jq .
```

**Response `200 OK`** (immediate — reprocessing runs in background)

```json
{ "queued": 3, "status_filter": "erro" }
```

---

#### `POST /api/storage/test`

Sanity check — runs a test embedding with a fixed string to verify the embedding pipeline is configured and responding. Does not write to the database.

**Auth required:** No

```bash
curl -s -X POST https://spalla-backend.up.railway.app/api/storage/test | jq .
```

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

---

#### `POST /api/welcome-flow/register`

Register a new mentorado from the onboarding wizard. Public endpoint — no auth required. Creates a user account and a mentee record in Supabase. A temporary password is auto-generated from the mentee's first name and last 4 digits of their WhatsApp number (e.g., `joao0000`).

**Auth required:** No (public-facing onboarding page)

> This endpoint is idempotent on email — if the email already exists, it returns `already_exists: true` with the existing `user_id` instead of an error.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `nome` | string | ✅ | Full name. First word used to derive the temp password |
| `email` | string | ✅ | Used as login identifier |
| `whatsapp` | string | — | Used to derive temp password: `{first_name_lowercase}{last4digits}`. Example: `"11999990000"` → `joao0000` |

```bash
curl -s -X POST https://spalla-backend.up.railway.app/api/welcome-flow/register \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Silva",
    "email": "joao@silva.com",
    "whatsapp": "11999990000"
  }' | jq .
```

**Response `201 Created`** (new user)

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

**Response `200 OK`** (user already exists)

```json
{
  "success": true,
  "already_exists": true,
  "user_id": 42,
  "message": "User already exists with this email"
}
```

**Errors**

| Status | `error` | Cause |
|--------|---------|-------|
| 400 | `nome and email are required` | Missing required fields |
| 500 | `Registration failed` | DB write error |

---

### Evolution API Proxy

All requests to `/api/evolution/*` are proxied transparently to the Evolution WhatsApp instance. This approach:

1. Keeps the Evolution API key server-side — never exposed to the browser
2. Avoids CORS preflight failures (the browser only talks to the backend)
3. Allows the Evolution instance URL to change without frontend deploys

**Methods supported:** `GET`, `POST`, `PUT`, `DELETE`

**Path mapping:** `/api/evolution{path}` → `{EVOLUTION_BASE}{path}`

**Injected header:** `apikey: {EVOLUTION_API_KEY}` (added server-side, not from the browser)

**Timeout:** 30 seconds per request

```bash
# List messages for a WhatsApp chat
curl -s "https://spalla-backend.up.railway.app/api/evolution/chat/findMessages/case-spalla?where[key][remoteJid]=5511999990000@s.whatsapp.net" | jq .

# Send a text message
curl -s -X POST "https://spalla-backend.up.railway.app/api/evolution/message/sendText/case-spalla" \
  -H "Content-Type: application/json" \
  -d '{"number":"5511999990000","text":"Olá!"}' | jq .

# Fetch all contacts
curl -s "https://spalla-backend.up.railway.app/api/evolution/chat/findContacts/case-spalla" | jq .

# Check connection status
curl -s "https://spalla-backend.up.railway.app/api/evolution/instance/connectionState/case-spalla" | jq .
```

> `case-spalla` is the Evolution instance name, configured via the `EVOLUTION_INSTANCE` env var. See [Evolution API documentation](https://doc.evolution-api.com) for the full endpoint catalog.

---

#### `GET /api/evolution/instance-uuid`

Returns the configured Evolution instance name and S3 bucket coordinates for resolving media file paths. Used by the frontend to build correct S3 keys for WhatsApp media.

**Auth required:** No

```bash
curl -s https://spalla-backend.up.railway.app/api/evolution/instance-uuid | jq .
```

**Response `200 OK`**

```json
{
  "instance": "case-spalla",
  "note": "UUID discovery not yet automated. Check S3 bucket path manually to find the Evolution UUID prefix.",
  "s3_bucket": "spalla-media",
  "s3_endpoint": "fsn1.your-objectstorage.com"
}
```

---

### System

---

#### `GET /api/health`

Returns the operational status of all integrations. Use this to verify which features are active without checking environment variables directly.

**Auth required:** No

```bash
curl -s https://spalla-backend.up.railway.app/api/health | jq .
```

**Response `200 OK`**

```json
{
  "status": "ok",
  "zoom_configured": true,
  "gcal_configured": true,
  "supabase_configured": true,
  "sheets_configured": false,
  "openai_configured": true,
  "storage_search": true,
  "evolution_configured": true,
  "s3_configured": true
}
```

All boolean fields are `true` only when the corresponding credentials are present and the client initialized without error at startup.

---

## Supabase Direct Access

The frontend reads most data directly from Supabase using the JS client. No backend roundtrip is needed for these operations.

### Client initialization

```javascript
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const sb = createClient(
  'https://your-project.supabase.co',
  'your-anon-key'
)
```

### Common query patterns

```javascript
// Full mentee list with all KPI fields
const { data } = await sb.from('vw_god_overview').select('*')

// Unanswered interactions (pending messages)
const { data } = await sb.from('vw_god_pendencias').select('*')

// Cohort distribution
const { data } = await sb.from('vw_god_cohort').select('*')

// Financial view (CFO page)
const { data } = await sb.from('vw_god_financeiro').select('*')

// Calls log (last 500, most recent first)
const { data } = await sb
  .from('calls_mentoria')
  .select('*, mentorados(nome)')
  .order('data_call', { ascending: false })
  .limit(500)

// Files for a specific mentee
const { data } = await sb
  .from('sp_arquivos')
  .select('*')
  .eq('entidade_tipo', 'mentorado')
  .eq('entidade_id', 7)
```

### Adding a new view

1. Create the view in Supabase SQL Editor
2. Grant read access via RLS:
   ```sql
   CREATE POLICY "read_all" ON vw_minha_view
   FOR SELECT USING (true);
   ```
3. Query from the frontend: `sb.from('vw_minha_view').select('*')`

---

## Realtime Subscriptions

The frontend can subscribe to live changes using Supabase Realtime. Useful for:
- Automatically refreshing the pendências widget when N8N marks interactions as `respondido = false`
- Live updates to `calls_mentoria` when a new call is scheduled from another browser session

```javascript
// Subscribe to new unanswered interactions
const channel = sb
  .channel('pendencias-live')
  .on(
    'postgres_changes',
    {
      event: 'INSERT',
      schema: 'public',
      table: 'interacoes_mentoria',
      filter: 'respondido=eq.false'
    },
    (payload) => {
      console.log('New pending message:', payload.new)
      // Re-fetch pendencias and reconcile with mentees
      this.loadDashboard()
    }
  )
  .subscribe()

// Unsubscribe when leaving the page
channel.unsubscribe()
```

For Realtime to work, the table must have Realtime enabled in Supabase dashboard: Database → Replication → Tables.

---

## Data Sources

| Source | Type | Data | Used by |
|--------|------|------|---------|
| `vw_god_overview` | View | Full mentee list with phase, risk, financial, and KPI fields | Dashboard, Mentees page |
| `vw_god_cohort` | View | Cohort distribution by phase + risk + pending_responses | Dashboard stats |
| `vw_god_pendencias` | View | Unanswered interactions (`interacoes_mentoria.respondido = false`) | Pendências widget, `msgs_pendentes_resposta` reconciliation |
| `vw_pa_pipeline` | View | Plano de Ação execution board (tasks, statuses, progress) | PA board |
| `vw_god_financeiro` | View | Financial status per mentee (contract, payments, status) | CFO Financeiro page |
| `vw_fin_snapshots` | View | Monthly financial snapshots | CFO KPI cards |
| `calls_mentoria` | Table | All scheduled and recorded calls | Calls tab |
| `sp_arquivos` | Table | Uploaded file registry with processing status | Arquivos page |
| `interacoes_mentoria` | Table | Raw WhatsApp interaction log | Pendências detail, history |
| `vw_storage_overview` | View | Storage stats grouped by entity type | Storage status widget |
| `vw_processamento_fila` | View | Files stuck in `pendente` or `erro` | Storage queue |

---

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `SUPABASE_URL` | ✅ | Supabase project URL (`https://xxx.supabase.co`) |
| `SUPABASE_SERVICE_KEY` | ✅ | Service role key — full DB access, never expose to browser |
| `SUPABASE_ANON_KEY` | — | Anon key — used as fallback in some queries |
| `JWT_SECRET` | ✅ | HMAC-SHA256 signing secret. Generate: `openssl rand -hex 32` |
| `PORT` | — | Backend port. Default: `9999` |
| `ZOOM_ACCOUNT_ID` | — | Zoom Server-to-Server OAuth account ID |
| `ZOOM_CLIENT_ID` | — | Zoom OAuth client ID |
| `ZOOM_CLIENT_SECRET` | — | Zoom OAuth client secret |
| `GOOGLE_SA_JSON` | — | Google Service Account JSON — base64-encoded or raw string |
| `PAYMENTS_SHEET_ID` | — | Google Sheets spreadsheet ID for payments sync |
| `CONTRACTS_SHEET_ID` | — | Google Sheets spreadsheet ID for contracts sync |
| `EVOLUTION_API_KEY` | — | Evolution WhatsApp API key |
| `EVOLUTION_BASE` | — | Evolution instance base URL (e.g. `https://evolution.yourhost.com`) |
| `EVOLUTION_INSTANCE` | — | Instance name (e.g. `case-spalla`) |
| `S3_ENDPOINT` | — | Hetzner S3 endpoint (e.g. `fsn1.your-objectstorage.com`) |
| `S3_BUCKET` | — | S3 bucket name (e.g. `spalla-media`) |
| `AWS_ACCESS_KEY_ID` | — | S3 access key |
| `AWS_SECRET_ACCESS_KEY` | — | S3 secret key |
| `OPENAI_API_KEY` | — | OpenAI — Whisper transcription, Vision (fallback), embeddings (fallback) |
| `VOYAGE_API_KEY` | — | Voyage AI — primary embedding provider (`voyage-3-lite`) |
| `GEMINI_API_KEY` | — | Gemini — Vision for image processing (preferred over OpenAI Vision) |

Variables marked `—` for Required are optional. When absent, the corresponding feature degrades gracefully: `/api/health` returns `false` for that integration, and related endpoints return a descriptive error.

---

## Error Reference

All error responses use this envelope:

```json
{ "error": "Human-readable description of what went wrong" }
```

### Common HTTP status codes

| Status | When used |
|--------|-----------|
| 200 | Success |
| 201 | Resource created successfully |
| 400 | Client error — malformed request, missing required field, invalid value |
| 401 | Authentication failure — missing token, bad token, expired token |
| 403 | Authorization failure — valid token but insufficient permissions |
| 404 | Resource not found |
| 405 | HTTP method not allowed for this path |
| 409 | Conflict — resource already exists (e.g., duplicate email on register) |
| 500 | Server-side error — check Railway logs for stack trace |

### Common error strings

| `error` value | Status | Endpoint |
|---------------|--------|----------|
| `Email and password required` | 400 | `/api/auth/login`, `/api/auth/register` |
| `Password must be at least 6 characters` | 400 | `/api/auth/register` |
| `Email already exists` | 409 | `/api/auth/register` |
| `Invalid email or password` | 401 | `/api/auth/login` |
| `Missing or invalid token` | 401 | Any authenticated endpoint |
| `Invalid or expired token` | 401 | Any authenticated endpoint |
| `Invalid or expired refresh token` | 401 | `/api/auth/refresh` |
| `Refresh token required` | 400 | `/api/auth/refresh` |
| `mentorado and data are required` | 400 | `/api/schedule-call` |
| `key parameter required` | 400 | `/api/media/presign`, `/api/media/stream` |
| `arquivo_id is required` | 400 | `/api/storage/process` |

---

## Limits & Timeouts

| Endpoint / Feature | Limit |
|---|---|
| `/api/calls/upcoming` | 500 rows max (hard coded, no pagination) |
| `/api/calendar/events` | 50 events (Google Calendar API default) |
| `/api/storage/search` | 50 results max (`limit` param) |
| Evolution proxy timeout | 30 seconds per request |
| Supabase direct queries | Default 1,000 rows (PostgREST); increase with `.limit(N)` |
| Storage reprocessing rate | 5 files/second (avoids OpenAI/Voyage rate limits) |
| `access_token` TTL | 60 minutes |
| `refresh_token` TTL | 7 days |

**No rate limiting is implemented at the backend level.** Railway's HTTP timeout (default 60s) and Supabase's connection pooler are the effective limits under load. If rate limiting becomes necessary, implement it at the Railway gateway or add a Redis-backed middleware layer.
