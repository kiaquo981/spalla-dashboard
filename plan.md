---
title: WA DM Core — Plan
worktree: wt-wa-dm-core
branch: feature/case/wa-dm-core
sprint: S9-A
status: ready
created: 2026-03-21
---

# Plan — WA DM v2: Core Data Model

## Sequência

```
Step 1: Migration SQL completa
Step 2: Endpoints backend (4 handlers)
Step 3: Registrar rotas no do_GET / do_POST / do_DELETE
Step 4: Smoke test local
Step 5: Commit + PR
```

---

## Step 1 — Migration SQL

**Arquivo:** `supabase/migrations/20260321180000_wa_dm_v2.sql`

### 1.1 Header e search_path
```sql
-- S9-A — WA DM v2: Core Data Model
-- Sprint 9 | Feature: DM 1:1 inbox + SLA + canned + presence + segments
SET search_path = "case", public;
```

### 1.2 CREATE VIEW vw_wa_mentee_inbox
- Header comment com schema das colunas
- SELECT com LATERAL JOINs conforme spec.md §5.1
- WHERE m.ativo = true
- `CREATE OR REPLACE VIEW` para idempotência

### 1.3 CREATE TABLE wa_sla_states
- IF NOT EXISTS
- Indexes: `idx_wa_sla_states_mentorado_id` ON `(mentorado_id, created_at DESC)`
- RLS: enable + SELECT/INSERT policy

### 1.4 CREATE TABLE wa_canned_responses
- IF NOT EXISTS
- Index: `idx_wa_canned_shortcode` ON `(shortcode)`
- RLS: enable + SELECT/INSERT/UPDATE/DELETE policy (tudo true por ora)
- **SEED:** INSERT 8 templates com ON CONFLICT DO NOTHING

### 1.5 CREATE TABLE wa_presence
- IF NOT EXISTS
- UNIQUE constraint `(mentorado_id, user_email)`
- Index: `idx_wa_presence_last_seen` ON `(last_seen)`
- RLS: enable + SELECT policy (true) + INSERT/UPDATE policy (true) + DELETE policy para owner (`user_email = auth.email()`)

### 1.6 CREATE TABLE wa_saved_segments
- IF NOT EXISTS
- Index: `idx_wa_saved_segments_owner` ON `(owner_email)`
- RLS: enable + SELECT policy (true + is_shared OR owner_email = auth.email()) + INSERT/DELETE por owner

### 1.7 ALTER TABLE god_tasks
```sql
ALTER TABLE god_tasks
  ADD COLUMN IF NOT EXISTS source_topic_id   UUID REFERENCES wa_topics(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS source_message_id UUID REFERENCES wa_messages(id) ON DELETE SET NULL;
```
- Indexes: `idx_god_tasks_source_topic` ON `(source_topic_id)`, `idx_god_tasks_source_message` ON `(source_message_id)`

### 1.8 PostgREST + GRANTs
```sql
-- Expose via public schema (PostgREST)
GRANT SELECT ON vw_wa_mentee_inbox TO anon, authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON wa_sla_states TO anon, authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON wa_canned_responses TO anon, authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON wa_presence TO anon, authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON wa_saved_segments TO anon, authenticated, service_role;
```

---

## Step 2 — Backend Handlers

**Arquivo:** `app/backend/14-APP-server.py`

Adicionar 4 métodos privados na classe handler (padrão `_handle_*`):

### 2.1 `_handle_wa_inbox(self)`
```python
def _handle_wa_inbox(self):
    parsed = urllib.parse.urlparse(self.path)
    params = urllib.parse.parse_qs(parsed.query)

    query = 'vw_wa_mentee_inbox?select=*'

    health = params.get('health_status', [None])[0]
    if health:
        query += f'&health_status=eq.{health}'

    fase = params.get('fase_jornada', [None])[0]
    if fase:
        query += f'&fase_jornada=eq.{fase}'

    search = params.get('search', [None])[0]
    if search:
        query += f'&nome=ilike.*{urllib.parse.quote(search)}*'

    sort = params.get('sort', ['sla_desc'])[0]
    sort_map = {
        'sla_desc': 'horas_sem_resposta_equipe.desc.nullslast',
        'unread_desc': 'unread_count.desc.nullslast',
        'last_message_desc': 'last_message_at.desc.nullslast',
    }
    order = sort_map.get(sort, 'horas_sem_resposta_equipe.desc.nullslast')
    query += f'&order={order}'

    result = supabase_request('GET', query)
    self._send_json(result or [])
```

### 2.2 `_handle_wa_presence_post(self)`
```python
def _handle_wa_presence_post(self):
    try:
        body = json.loads(self._read_body())
    except Exception:
        self._send_json({'error': 'Invalid JSON'}, 400)
        return

    mentorado_id = body.get('mentorado_id')
    user_email = body.get('user_email')
    user_name = body.get('user_name', '')

    if not mentorado_id or not user_email:
        self._send_json({'error': 'mentorado_id and user_email required'}, 400)
        return

    # UPSERT via PostgREST prefer=resolution=merge-duplicates
    result = supabase_request(
        'POST',
        'wa_presence',
        {'mentorado_id': mentorado_id, 'user_email': user_email,
         'user_name': user_name, 'last_seen': 'now()'},
    )
    self._send_json({'ok': True})
```

### 2.3 `_handle_wa_presence_delete(self)`
```python
def _handle_wa_presence_delete(self):
    parsed = urllib.parse.urlparse(self.path)
    params = urllib.parse.parse_qs(parsed.query)

    mentorado_id = params.get('mentorado_id', [None])[0]
    user_email = params.get('user_email', [None])[0]

    if not mentorado_id or not user_email:
        self._send_json({'error': 'mentorado_id and user_email required'}, 400)
        return

    supabase_request(
        'DELETE',
        f'wa_presence?mentorado_id=eq.{mentorado_id}&user_email=eq.{urllib.parse.quote(user_email)}'
    )
    self._send_json({'ok': True})
```

### 2.4 `_handle_wa_presence_get(self, mentorado_id)`
```python
def _handle_wa_presence_get(self, mentorado_id):
    result = supabase_request(
        'GET',
        f'wa_presence?mentorado_id=eq.{mentorado_id}'
        f'&last_seen=gte.{urllib.parse.quote("now() - interval 60 seconds")}'
        f'&select=user_email,user_name,last_seen'
    )
    self._send_json(result or [])
```

> **Nota:** PostgREST não aceita `now() - interval` diretamente como parâmetro de filtro. Usar timestamp calculado em Python: `(datetime.utcnow() - timedelta(seconds=60)).isoformat() + 'Z'`.

---

## Step 3 — Registrar Rotas

Adicionar no `do_GET`:
```python
elif self.path.startswith('/api/wa/inbox'):
    self._handle_wa_inbox()
elif re.match(r'^/api/wa/presence/(\d+)$', self.path):
    _m = re.match(r'^/api/wa/presence/(\d+)$', self.path)
    self._handle_wa_presence_get(_m.group(1))
```

Adicionar no `do_POST`:
```python
elif self.path == '/api/wa/presence':
    self._handle_wa_presence_post()
```

Adicionar no `do_DELETE`:
```python
elif self.path.startswith('/api/wa/presence'):
    self._handle_wa_presence_delete()
```

---

## Step 4 — Smoke Test

1. Aplicar migration: `supabase db push` (ou exec SQL direto no Supabase studio)
2. Verificar VIEW retorna rows: `GET /api/wa/inbox` → array não vazio
3. Verificar presence upsert: `POST /api/wa/presence` com body válido → `{"ok": true}`
4. Verificar presence get: `GET /api/wa/presence/{id}` → array
5. Verificar presence delete: `DELETE /api/wa/presence?mentorado_id=X&user_email=Y` → `{"ok": true}`

---

## Step 5 — Commit + PR

```bash
git add supabase/migrations/20260321180000_wa_dm_v2.sql
git add app/backend/14-APP-server.py
git commit -m "feat(wa): S9-A — vw_wa_mentee_inbox + 4 tables + presence endpoints"
# PR → develop
```

---

## Arquivos Tocados

| Arquivo | Tipo | Ação |
|---------|------|------|
| `supabase/migrations/20260321180000_wa_dm_v2.sql` | SQL | CRIAR |
| `app/backend/14-APP-server.py` | Python | EDITAR (+~80 linhas) |

**Total:** 2 arquivos, ~250 linhas novas.
