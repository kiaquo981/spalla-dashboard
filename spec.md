---
title: WA DM Core — Spec
worktree: wt-wa-dm-core
branch: feature/case/wa-dm-core
sprint: S9-A
status: ready
created: 2026-03-21
---

# Spec — WA DM v2: Core Data Model

## 1. Objetivo

Criar a fundação de dados do módulo WA Management v2:
- VIEW `vw_wa_mentee_inbox` — abstrai grupos WhatsApp como DM 1:1 por mentorado
- 4 novas tabelas auxiliares: `wa_sla_states`, `wa_canned_responses`, `wa_presence`, `wa_saved_segments`
- ALTER `god_tasks` com 2 colunas de backlink WA
- 4 endpoints backend base (inbox + presence)

**Zero frontend. Zero UI. Só SQL + Python endpoints.**

---

## 2. Schema Existente Confirmado

### Tabelas em uso pela VIEW

**`wa_messages`** (public schema):
```
id               UUID PK
message_id       TEXT UNIQUE        -- Evolution API dedup key
group_jid        TEXT NOT NULL
mentorado_id     BIGINT → "case".mentorados(id)  -- populado pelo N8N ✅
topic_id         UUID → wa_topics(id)
sender_jid       TEXT
sender_name      TEXT
is_from_team     BOOLEAN NOT NULL DEFAULT false
content_type     TEXT               -- 'text'|'audio'|'image'|...
content_text     TEXT
timestamp        TIMESTAMPTZ NOT NULL
created_at       TIMESTAMPTZ
```

**`wa_topics`** (public schema):
```
id               UUID PK
group_jid        TEXT NOT NULL
mentorado_id     BIGINT → "case".mentorados(id)  -- populado pelo N8N ✅
status           TEXT               -- 'open'|'active'|'pending_action'|'resolved'|'archived'|'converted_task'
last_message_at  TIMESTAMPTZ
```

**`"case".mentorados`** (case schema):
```
id               BIGINT PK
nome             TEXT
foto_url         TEXT
fase_jornada     TEXT
grupo_whatsapp_id TEXT             -- JID do grupo: 120363XXX@g.us ✅
snoozed_until    TIMESTAMPTZ       -- adicionado em S8 ✅
ativo            BOOLEAN
```

**`god_tasks`** (public schema):
```
id               UUID PK
titulo           TEXT NOT NULL
status           TEXT               -- 'pendente'|'em_andamento'|'concluida'|'cancelada'
mentorado_id     BIGINT → mentorados(id)
-- source_topic_id   → AINDA NÃO EXISTE (S9 entrega)
-- source_message_id → AINDA NÃO EXISTE (S9 entrega)
```

### O que NÃO existe ainda (S9 entrega)
- `vw_wa_mentee_inbox` — VIEW principal
- `wa_sla_states` — histórico SLA
- `wa_canned_responses` — respostas rápidas
- `wa_presence` — collision detection
- `wa_saved_segments` — filtros salvos
- `god_tasks.source_topic_id`
- `god_tasks.source_message_id`

---

## 3. Cross-Schema: Observação Crítica

A VIEW precisa fazer JOIN de tabelas em 2 schemas:
- `"case".mentorados` — schema `case`
- `wa_messages`, `wa_topics`, `god_tasks` — schema `public`

**Solução:** migration com `SET search_path = "case", public;` + prefixo explícito em `"case".mentorados`.
A VIEW em si fica em `public` para ser acessada pelo PostgREST.

Verificação: na `07-SQL-god-tasks-schema.sql`, `god_tasks` usa `mentorados(id)` sem prefixo — isso funciona porque no contexto de execução o search_path incluía `"case"`. O Supabase trata ambos via PostgREST pelo schema `public` por padrão.

---

## 4. Padrão Backend Confirmado

Raw Python `BaseHTTPRequestHandler` em `app/backend/14-APP-server.py`:

```python
# Estrutura padrão de handler
def do_GET(self):
    if self.path == '/api/wa/inbox':
        self._handle_wa_inbox()
    elif self.path.startswith('/api/wa/presence/'):
        self._handle_wa_presence_get()
    # ...

def _handle_wa_inbox(self):
    params = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
    result = supabase_request('GET', 'vw_wa_mentee_inbox?select=*')
    self._send_json(result)
```

Supabase access: `supabase_request(method, path, body=None)` — wrapper já implementado na linha ~700.

---

## 5. Migration: `20260321180000_wa_dm_v2.sql`

### 5.1 vw_wa_mentee_inbox

VIEW em `public` com LATERAL JOINs em `wa_messages` por `mentorado_id`.

**Campos retornados:**
- `mentorado_id`, `nome`, `foto_url`, `fase_jornada`, `group_jid`, `snoozed_until`
- `last_message`, `last_message_at`, `last_message_sender`, `last_message_is_team`
- `unread_count` — msgs inbound depois da última resposta da equipe
- `horas_sem_resposta_equipe` — SLA timer (ROUND para 1 decimal)
- `health_status` — `'snoozed'|'vermelho'|'amarelo'|'verde'`
  - snoozed: `snoozed_until > now()`
  - vermelho: > 72h sem resposta equipe
  - amarelo: > 48h
  - verde: resto
- `open_topics_count` — topics com status IN ('open','active','pending_action')
- `active_tasks_count` — god_tasks com status IN ('pendente','em_andamento')

**Filtro:** `WHERE m.ativo = true`

**Performance concern:** LATERAL JOINs em wa_messages ok até ~500 mentorados.
Acima disso → materializar. Por ora: view simples.

### 5.2 wa_sla_states

```sql
CREATE TABLE wa_sla_states (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mentorado_id    BIGINT NOT NULL REFERENCES "case".mentorados(id) ON DELETE CASCADE,
  yellow_at       TIMESTAMPTZ,
  red_at          TIMESTAMPTZ,
  resolved_at     TIMESTAMPTZ,
  resolved_by     TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 5.3 wa_canned_responses

```sql
CREATE TABLE wa_canned_responses (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shortcode   TEXT NOT NULL UNIQUE,  -- '/bom_dia', '/acompanhamento'
  name        TEXT NOT NULL,
  content     TEXT NOT NULL,
  category    TEXT DEFAULT 'geral',  -- 'onboarding'|'follow_up'|'cobranca'|'geral'
  created_by  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**Seed (~8 templates):**
| shortcode | name | category |
|-----------|------|---------|
| /bom_dia | Bom dia padrão | geral |
| /acompanhamento | Check semanal | follow_up |
| /call | Agendamento de call | geral |
| /material | Envio de material | onboarding |
| /prazo | Lembrete de prazo | follow_up |
| /resultado | Solicitação de resultado | follow_up |
| /renovacao | Proposta de renovação | cobranca |
| /parabens | Parabéns resultado | geral |

### 5.4 wa_presence

```sql
CREATE TABLE wa_presence (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mentorado_id    BIGINT NOT NULL REFERENCES "case".mentorados(id) ON DELETE CASCADE,
  user_email      TEXT NOT NULL,
  user_name       TEXT,
  last_seen       TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT wa_presence_unique UNIQUE (mentorado_id, user_email)
);
```

### 5.5 wa_saved_segments

```sql
CREATE TABLE wa_saved_segments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  filters     JSONB NOT NULL DEFAULT '{}',
  is_shared   BOOLEAN DEFAULT false,
  owner_email TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 5.6 ALTER god_tasks

```sql
ALTER TABLE god_tasks
  ADD COLUMN IF NOT EXISTS source_topic_id   UUID REFERENCES wa_topics(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS source_message_id UUID REFERENCES wa_messages(id) ON DELETE SET NULL;
```

### 5.7 PostgREST exposure + RLS

Todas as novas tabelas/views:
- `CREATE OR REPLACE VIEW public.X AS SELECT * FROM X;` (para as que estão no schema case, se houver)
- `GRANT SELECT, INSERT, UPDATE, DELETE ON public.X TO anon, authenticated, service_role;`
- RLS: SELECT = true; INSERT = true; UPDATE e DELETE apenas em wa_presence (by user_email)

---

## 6. Endpoints Backend

### GET /api/wa/inbox

Query `vw_wa_mentee_inbox` com filtros opcionais:
- `health_status`: `verde|amarelo|vermelho|snoozed`
- `fase_jornada`: `onboarding|execucao|resultado|renovacao`
- `search`: busca por nome (ilike)
- `sort`: `sla_desc|unread_desc|last_message_desc` (default: `sla_desc`)

Retorna array de objetos da VIEW.

### POST /api/wa/presence

Body: `{ mentorado_id, user_email, user_name }`
→ UPSERT `wa_presence` por `(mentorado_id, user_email)`
→ Atualiza `last_seen = now()`

### DELETE /api/wa/presence

Params: `mentorado_id`, `user_email`
→ DELETE WHERE `mentorado_id = X AND user_email = Y`

### GET /api/wa/presence/{mentorado_id}

→ SELECT WHERE `mentorado_id = X AND last_seen > now() - interval '60 seconds'`
→ Retorna array com `[{user_email, user_name, last_seen}]`

---

## 7. Arquivos a Modificar

| Arquivo | Ação |
|---------|------|
| `supabase/migrations/20260321180000_wa_dm_v2.sql` | CRIAR — migration completa |
| `app/backend/14-APP-server.py` | EDITAR — adicionar 4 endpoints WA |

**Não tocar:**
- `app/frontend/` — zero frontend neste worktree
- Qualquer migration existente

---

## 8. Riscos e Mitigações

| Risco | Mitigação |
|-------|-----------|
| `wa_messages.mentorado_id` pode ser NULL (grupos não mapeados) | LEFT JOIN — rows sem mensagem aparecem com NULLs, não são excluídas |
| Cross-schema JOIN (case + public) | `SET search_path` explícito na migration; prefixos no SQL |
| `god_tasks` sem schema prefix no CREATE original | ALTER usa path direto `god_tasks` — funciona em search_path padrão Supabase |
| Presença stale após crash | `last_seen > now() - interval '60s'` na query — aceito por design |
