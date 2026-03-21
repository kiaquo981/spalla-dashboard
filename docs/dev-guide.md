# Spalla Dashboard — Dev Guide

> Leitura obrigatória antes do primeiro commit. Tempo estimado: 20 min.

---

## Contents

- [Stack](#stack)
- [Repository Structure](#repository-structure)
- [Local Setup](#local-setup)
- [Branch Flow](#branch-flow)
- [Commit Convention](#commit-convention)
- [Opening a PR](#opening-a-pr)
- [Backend Architecture](#backend-architecture)
- [Frontend Architecture](#frontend-architecture)
- [Supabase](#supabase)
- [Testing](#testing)
- [Debugging](#debugging)
- [Critical Rules](#critical-rules)
- [FAQ](#faq)

---

## Stack

| Layer | Technology |
|-------|-----------|
| Frontend | HTML + Alpine.js (SPA, zero build step) |
| Backend | Python 3.9 — `http.server` (no framework) |
| Database | Supabase (Postgres + PostgREST + pgvector) |
| Deploy backend | Railway (auto-deploy on `main` merge) |
| Deploy frontend | Vercel (auto-deploy on `main` merge) |
| WhatsApp | Evolution API (self-hosted) |
| Media storage | Hetzner Object Storage (S3-compatible) |
| Embeddings | Voyage AI `voyage-3-lite` (primary) / OpenAI `text-embedding-3-small` (fallback) |

**No build step, no bundler, no TypeScript compilation.** The frontend is served as-is. The backend is a single Python file — no framework to install, no migrations to run. Both can be running locally in under 2 minutes.

---

## Repository Structure

```
spalla-dashboard/
├── app/
│   ├── backend/
│   │   ├── 14-APP-server.py          # Entire backend — one file, ~2000 lines
│   │   ├── requirements.txt          # All Python deps (local dev)
│   │   └── requirements-railway.txt  # Railway-specific (removes binary deps)
│   └── frontend/
│       ├── 10-APP-index.html         # SPA shell + all HTML templates (~800 lines)
│       └── 11-APP-app.js             # Alpine.js app logic (~7000 lines)
├── docs/
│   ├── api-reference.md              # Full API documentation
│   └── dev-guide.md                  # This file
└── deploy/                           # Docker/Railway config
```

### Why numbered prefixes?

The `10-`, `11-`, `14-` prefixes are ordering conventions — they signal load/execution order and help in directory listings. Do not rename them; URLs and references are hardcoded to these filenames.

---

## Local Setup

### Prerequisites

- Python 3.9+
- A Supabase project (at minimum `SUPABASE_URL` + `SUPABASE_SERVICE_KEY` + `JWT_SECRET`)
- git

### 1. Clone and branch

```bash
git clone git@github.com:case-company/spalla-dashboard.git
cd spalla-dashboard

# Always branch from develop — NEVER from main
git checkout develop
git pull origin develop
git checkout -b feature/case/nome-da-feature
```

### 2. Backend

```bash
cd app/backend

# Create virtualenv
python3 -m venv .venv
source .venv/bin/activate       # macOS/Linux
# .venv\Scripts\activate        # Windows

# Install dependencies
pip install -r requirements.txt

# Create .env with the minimum required variables
cat > .env << 'EOF'
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_SERVICE_KEY=eyJ...
JWT_SECRET=any-long-random-string-here-at-least-32-chars
PORT=9999
EOF

# Start the server
python 14-APP-server.py
# → Listening on http://localhost:9999
```

**Minimum variables to run (others degrade gracefully):**

| Variable | Minimum? | Without it |
|----------|----------|------------|
| `SUPABASE_URL` | ✅ | Server fails to start |
| `SUPABASE_SERVICE_KEY` | ✅ | All DB queries fail |
| `JWT_SECRET` | ✅ | Auth endpoints fail |
| `PORT` | — | Defaults to `9999` |
| Everything else | — | That feature is disabled; `/api/health` reports `false` |

### 3. Frontend

The frontend is plain HTML — serve it with any static server:

```bash
# Option 1: Python (no deps)
cd app/frontend
python3 -m http.server 3000
# → http://localhost:3000

# Option 2: Node serve
npx serve app/frontend -p 3000

# Option 3: VS Code Live Server extension — click "Go Live"
```

**Point the frontend at your local backend:**

In `11-APP-app.js`, find `CONFIG.API_BASE` near the top and temporarily change it to `http://localhost:9999` for local testing.

> ⚠️ **NEVER commit this change.** `CONFIG.API_BASE` must point to the Railway URL in production. Add it to your pre-commit mental checklist: `git diff -- app/frontend/11-APP-app.js | grep API_BASE`.

### 4. Verify everything is working

```bash
# Backend health check
curl http://localhost:9999/api/health | python3 -m json.tool

# Expected: {"status":"ok","supabase_configured":true,...}
```

Open `http://localhost:3000`, log in with any credentials that exist in `auth_users`, and confirm the dashboard loads data.

---

## Branch Flow

```
main        ← Production (Railway + Vercel auto-deploy)
  ↑
develop     ← Integration branch (PR target for all features)
  ↑
feature/case/<slug>   ← Your feature
fix/case/<slug>       ← Your bug fix
hotfix/case/<slug>    ← Emergency production fix (targets main directly)
```

### Rules

| Rule | Detail |
|------|--------|
| PRs always target `develop` | Exception: hotfixes target `main` directly |
| `main` only receives PRs from `develop` | Or from `hotfix/case/<slug>` |
| Never push directly to `main` or `develop` | PRs only — both branches are protected |
| Branch names follow `type/case/<slug>` | `type` = `feature` \| `fix` \| `hotfix` \| `chore` |

### Keeping your branch up to date

```bash
# Rebase on develop before opening a PR
git fetch origin
git rebase origin/develop

# If conflicts:
git status                    # see what's conflicting
# resolve conflicts in editor
git add <resolved-files>
git rebase --continue
```

---

## Commit Convention

Format: `tipo(escopo): descrição curta` — max 72 characters.

```bash
feat(case): adiciona filtro por consultor no kanban
fix(auth): remove coluna role inexistente da query
fix(pendencias): reconcilia msgs_pendentes_resposta na carga inicial
refactor(storage): extrai helper _chunk_multipass para reutilização
docs(api): atualiza referência de endpoints com exemplos curl
chore(deps): atualiza requirements.txt com voyage-ai==0.3.2
perf(search): adiciona índice HNSW em sp_arquivos_chunks.embedding
security(jwt): aumenta mínimo de JWT_SECRET para 32 chars
```

**Valid types:**

| Type | When to use |
|------|-------------|
| `feat` | New feature or behavior visible to the user |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code restructuring, no behavior change |
| `style` | Formatting, whitespace — no logic change |
| `test` | Adding or updating tests |
| `chore` | Tooling, deps, CI config |
| `perf` | Performance improvement |
| `ci` | CI/CD pipeline changes |
| `security` | Security fix or hardening |

---

## Opening a PR

```bash
# 1. Make sure your branch is rebased on develop
git fetch origin
git rebase origin/develop

# 2. Push
git push origin feature/case/nome-da-feature

# 3. Create PR via GitHub CLI
gh pr create \
  --base develop \
  --title "feat(case): descrição da feature" \
  --body "## O que muda
- item 1
- item 2

## Como testar
- [ ] Passo 1
- [ ] Passo 2

## Checklist
- [ ] \`git status\` limpo (sem .env, .key, credenciais)
- [ ] Testei backend localmente
- [ ] Testei frontend localmente
- [ ] CONFIG.API_BASE não aponta para localhost
- [ ] Commits seguem a convenção"
```

### PR checklist (mandatory)

- [ ] No `.env`, `.key`, credential files staged
- [ ] No `CONFIG.API_BASE = 'http://localhost'` committed
- [ ] Tested backend locally (python server starts, endpoints respond correctly)
- [ ] Tested frontend locally (browser loads, key flows work)
- [ ] Changes are scoped to the feature — no unrelated edits
- [ ] New backend endpoints are documented in `docs/api-reference.md`
- [ ] Commits follow the convention (no "fix stuff", "wip", etc.)

---

## Backend Architecture

### Key design decision

The backend is a single Python file using the stdlib `http.server.BaseHTTPRequestHandler`. **No Flask, no FastAPI, no framework.** This was intentional: zero framework dependency, direct Railway deploy with a single `python` command, and trivially auditable.

The tradeoff is manual routing and no middleware. Every endpoint is a method.

### Request dispatch

```python
# In do_POST, do_GET, do_PUT, do_DELETE:
if self.path == '/api/auth/login':
    self._handle_login()
elif self.path == '/api/schedule-call':
    self._handle_schedule_call()
elif self.path.startswith('/api/evolution/'):
    self._proxy_evolution()
```

The `elif` chain is the router. Ordering matters for `startswith` patterns — put them after exact matches.

### Adding a new endpoint

**Step 1 — Register the route:**

```python
# In do_POST (or do_GET/do_PUT/do_DELETE):
elif self.path == '/api/meu-endpoint':
    self._handle_meu_endpoint()
```

**Step 2 — Implement the handler:**

```python
def _handle_meu_endpoint(self):
    try:
        body = json.loads(self._read_body())
        campo = body.get('campo')
        if not campo:
            self._send_json({'error': 'campo is required'}, 400)
            return

        result = supabase_request('POST', 'minha_tabela', {'campo': campo})
        self._send_json({'success': True, 'data': result})

    except Exception as e:
        log_error('MeuEndpoint', str(e), e)
        self._send_json({'error': str(e)}, 500)
```

**Step 3 — Document it** in `docs/api-reference.md`.

### Supabase helper

All Supabase access goes through `supabase_request(method, path, body)`, which wraps the REST API using the service key:

```python
# Read with filters
result = supabase_request('GET', 'vw_god_overview?select=id,nome,fase_jornada')
result = supabase_request('GET', 'mentorados?id=eq.7&select=*')

# Insert (returns inserted row)
result = supabase_request('POST', 'calls_mentoria', {
    'mentorado_id': 7,
    'data_call': '2026-04-10T13:00:00+00:00',
    'tipo_call': 'acompanhamento'
})

# Update
result = supabase_request('PATCH', 'calls_mentoria?id=eq.88', {
    'status_call': 'realizada'
})

# Delete
result = supabase_request('DELETE', 'calls_mentoria?id=eq.88')
```

PostgREST query syntax: field filters use `field=operator.value` (e.g., `id=eq.7`, `status=in.(pendente,erro)`, `data_call=gte.2026-01-01`).

### Auth middleware

To protect an endpoint with JWT auth:

```python
def _handle_protected_endpoint(self):
    user = self._require_auth()
    if not user:
        return  # _require_auth already sent 401

    # user['id'], user['email'], user['role'] are available here
    result = supabase_request('GET', f"dados?user_id=eq.{user['id']}")
    self._send_json(result)
```

`_require_auth()` reads the `Authorization: Bearer <token>` header, validates the HMAC signature and expiry, and returns the decoded payload or sends `401` and returns `None`.

### Background threads

Long operations (file processing, sheet sync) run in daemon threads so the HTTP response returns immediately:

```python
import threading

def _handle_storage_process(self):
    body = json.loads(self._read_body())
    arquivo_id = body.get('arquivo_id')
    if not arquivo_id:
        self._send_json({'error': 'arquivo_id is required'}, 400)
        return

    # Start background thread, respond immediately
    t = threading.Thread(target=self._process_file_async, args=(arquivo_id,), daemon=True)
    t.start()
    self._send_json({'status': 'processing', 'arquivo_id': arquivo_id})
```

---

## Frontend Architecture

### Single Page Application

The frontend is one HTML file (`10-APP-index.html`) and one JS file (`11-APP-app.js`). Alpine.js manages reactivity. There is no router library — page navigation is controlled by a string variable (`ui.page`).

### Alpine store structure

```javascript
Alpine.data('app', () => ({
  // UI state
  ui: {
    page: 'dashboard',      // current page name
    loading: false,
    filters: {
      fase: '',
      risco: '',
      cohort: '',
      status: '',
      financeiro: '',
      carteira: '',         // consultant filter (Lara / Heitor)
    },
    search: '',
    mobileMenuOpen: false,
  },

  // Data
  data: {
    mentees: [],            // from vw_god_overview (+ reconciled msgs_pendentes_resposta)
    cohort: [],             // from vw_god_cohort
    pendencias: [],         // from vw_god_pendencias (unanswered interactions)
    calls: [],              // from calls_mentoria
    tasks: [],              // from god_tasks
    paPlanos: [],           // from vw_pa_pipeline
    financeiro: [],         // from vw_god_financeiro (lazy-loaded on CFO page)
  },

  // Computed getters (Alpine)
  get kpis() { ... },
  get filteredMentees() { ... },
  get phaseDistribution() { ... },
  // ...

  // Methods
  navigate(page) { ... },
  loadDashboard() { ... },
  loadFinanceiro() { ... },
  // ...
}))
```

### Navigation

**Always use `navigate()`** to change pages. It handles side effects: lazy-loading page-specific data, saving scroll position, and logging.

```javascript
this.navigate('financeiro');    // loads vw_god_financeiro on first visit
this.navigate('arquivos');      // loads sp_arquivos
this.navigate('dashboard');     // already loaded — instant
```

### Adding a new page

1. **Sidebar nav** — add a nav item in `10-APP-index.html`:
   ```html
   <a class="sidebar__item" @click="navigate('minha-pagina')"
      :class="{'sidebar__item--active': ui.page === 'minha-pagina'}">
     Minha Página
   </a>
   ```

2. **Page block** — add an `x-show` section in the HTML:
   ```html
   <!-- PAGE: MINHA-PAGINA -->
   <div x-show="ui.page === 'minha-pagina'" x-cloak>
     <h1>Minha Página</h1>
     <div x-show="ui.loading">Carregando...</div>
     <!-- content here -->
   </div>
   ```

3. **Navigate hook** — wire the data load in `navigate()` in `11-APP-app.js`:
   ```javascript
   if (page === 'minha-pagina') this.loadMinhaPagina();
   ```

4. **Load method** — implement `loadMinhaPagina()`:
   ```javascript
   async loadMinhaPagina() {
     if (this.data.minhaPagina?.length) return; // already loaded
     this.ui.loading = true;
     try {
       const { data, error } = await sb.from('vw_minha_view').select('*');
       if (error) throw error;
       this.data.minhaPagina = data || [];
     } catch (e) {
       console.error('[Spalla] loadMinhaPagina:', e);
     } finally {
       this.ui.loading = false;
     }
   },
   ```

### Computed list pattern

Filters and search are always applied in `filteredMentees` (or a page-specific equivalent). Don't filter inline in templates — computed getters keep logic testable and centralized:

```javascript
get filteredMentees() {
  let list = this.data.mentees;
  if (this.ui.search) {
    const q = this.ui.search.toLowerCase();
    list = list.filter(m => m.nome?.toLowerCase().includes(q));
  }
  if (this.ui.filters.fase) list = list.filter(m => m.fase_jornada === this.ui.filters.fase);
  if (this.ui.filters.status === 'com_pendencia') {
    list = list.filter(m => (m.msgs_pendentes_resposta || 0) > 0 || (m.tarefas_atrasadas || 0) > 0);
  }
  return list;
},
```

### Pending messages — data contract

`msgs_pendentes_resposta` on each mentee object is **always derived from `data.pendencias`**, never read directly from `vw_god_overview`. This reconciliation happens after every load in `loadDashboard()`. Do not read `m.msgs_pendentes_resposta` from the Supabase view directly — the counts will be stale.

---

## Supabase

### Schema changes

Schema changes (new tables, columns, indexes) are made via Supabase SQL Editor. There is no migration file system — changes go directly to the managed Postgres instance.

**Before making a schema change:**

1. Notify the team (especially for destructive changes: `DROP COLUMN`, `RENAME`, `DROP TABLE`)
2. Make changes during low-traffic hours (outside 9-18h BRT)
3. Test the query in SQL Editor on a `LIMIT 10` first
4. If adding a column that existing code depends on, add it with a default so existing rows are valid immediately

**Destructive change checklist:**
- [ ] Team notified
- [ ] Frontend reads from a view — check if view needs updating
- [ ] Backend queries updated if they reference the column/table by name
- [ ] RLS policies still valid after the change

### Adding a new Supabase view

```sql
-- 1. Create the view
CREATE OR REPLACE VIEW vw_minha_view AS
SELECT
  m.id,
  m.nome,
  -- ... your logic ...
FROM mentorados m
LEFT JOIN outra_tabela o ON o.mentorado_id = m.id;

-- 2. Enable RLS (required for JS client access)
ALTER VIEW vw_minha_view OWNER TO postgres;

-- 3. Grant read access to anon role
GRANT SELECT ON vw_minha_view TO anon;

-- 4. (If using RLS policies on underlying tables, ensure anon can read through)
CREATE POLICY "read_all" ON vw_minha_view FOR SELECT USING (true);
```

### pgvector index (storage)

The `sp_arquivos_chunks` table uses a pgvector `HNSW` index for fast approximate nearest-neighbor search. If you add a new embedding model with different dimensions, you must rebuild the index:

```sql
-- Drop old index
DROP INDEX IF EXISTS sp_arquivos_chunks_embedding_idx;

-- Create new index for 512-dim vectors (Voyage)
CREATE INDEX sp_arquivos_chunks_embedding_idx
ON sp_arquivos_chunks
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);
```

---

## Testing

There is no automated test suite. Testing is currently manual — all QA happens locally before PR, and Railway provides the final integration test on the production URL.

### Backend testing approach

**Health check first — always:**

```bash
curl -s http://localhost:9999/api/health | python3 -m json.tool
```

**Auth flow:**

```bash
# Login
TOKEN=$(curl -s -X POST http://localhost:9999/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"your@email.com","password":"yourpassword"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

# Validate token
curl -s http://localhost:9999/api/auth/me -H "Authorization: Bearer $TOKEN"
```

**Test a new endpoint:**

```bash
# Test your endpoint locally before writing any frontend code
curl -s -X POST http://localhost:9999/api/meu-endpoint \
  -H "Content-Type: application/json" \
  -d '{"campo":"valor"}' | python3 -m json.tool
```

**Test error paths explicitly:**

```bash
# Missing required field
curl -s -X POST http://localhost:9999/api/meu-endpoint \
  -H "Content-Type: application/json" \
  -d '{}' | python3 -m json.tool
# Expected: {"error": "campo is required"} with status 400

# Bad auth
curl -s http://localhost:9999/api/auth/me \
  -H "Authorization: Bearer invalid-token"
# Expected: {"error": "Invalid or expired token"} with status 401
```

### Frontend testing approach

1. Open `http://localhost:3000` in the browser
2. Open DevTools (F12) → Console tab — watch for `[Spalla]` prefixed errors
3. Navigate to each page you modified
4. Test filter interactions, click handlers, and modal flows
5. Check the Network tab for failed API calls (red entries)

**Alpine.js debugging:**

```javascript
// In browser console — inspect Alpine component state
document.querySelector('[x-data]').__x.$data.ui
document.querySelector('[x-data]').__x.$data.data.mentees.length
document.querySelector('[x-data]').__x.$data.kpis
```

### Supabase query testing

Test queries directly in Supabase SQL Editor before wiring them to the backend or frontend. This isolates DB issues from application logic:

```sql
-- Test your view returns expected data
SELECT * FROM vw_god_overview LIMIT 5;

-- Test a filter
SELECT * FROM vw_god_pendencias
WHERE mentorado_id = 7
ORDER BY created_at DESC;
```

---

## Debugging

### Railway backend logs

1. Go to [railway.app](https://railway.app) → your project → backend service
2. Click **Logs** tab
3. The backend uses `log_error('Context', message, exception)` for structured error output

Filter for errors:
```
# In the Railway log search
ERROR
# or look for the context name
MeuEndpoint
```

### Common backend issues

**`ModuleNotFoundError`** — a new dependency was added to `requirements.txt` but Railway hasn't re-deployed. Push a commit to trigger a fresh deploy.

**`Supabase request failed: 400`** — your PostgREST query syntax is wrong. Test the exact query in Supabase SQL Editor or via the REST API directly:

```bash
curl "https://seu-projeto.supabase.co/rest/v1/minha_tabela?campo=eq.valor&select=*" \
  -H "apikey: $SUPABASE_SERVICE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_KEY"
```

**`JWT decode error`** — `JWT_SECRET` on Railway doesn't match the one used to issue tokens. Tokens issued locally won't work against production and vice versa. Always log in fresh after changing `JWT_SECRET`.

**Evolution proxy returns 404** — check that `EVOLUTION_INSTANCE` matches the actual instance name in your Evolution API dashboard. Instance names are case-sensitive.

### Common frontend issues

**Page loads but shows no data** — open Console. Look for `[Spalla]` error lines. Common cause: Supabase anon key misconfigured, or the view doesn't have `GRANT SELECT TO anon`.

**Filter toggle doesn't update the list** — Alpine.js computed getters are pure functions. If the getter reads from `this.data.mentees` and the array reference didn't change, Alpine won't re-render. Ensure you're replacing the array (not mutating it in place):
```javascript
// ✅ Correct — new array reference triggers re-render
this.data.mentees = this.data.mentees.map(m => ({ ...m, field: newValue }));

// ❌ Wrong — in-place mutation, Alpine may not detect the change
this.data.mentees.forEach(m => { m.field = newValue; });
```

**`CONFIG.API_BASE` pointing to localhost after deploy** — run `git diff origin/main -- app/frontend/11-APP-app.js | grep API_BASE` before merging.

### Supabase

**View returns empty on frontend but has rows in SQL Editor** — the anon role likely lacks SELECT permission. Run:

```sql
GRANT SELECT ON vw_minha_view TO anon;
```

**Realtime not firing** — go to Supabase dashboard → Database → Replication, and verify the source table has Realtime enabled.

**pgvector search returns wrong results** — check `embedding_dims` in `/api/storage/status`. If the stored vectors are 1536-dim (OpenAI) and you query with 512-dim (Voyage), the cosine similarity will be meaningless.

---

## Critical Rules

### Never

- Push directly to `main` or `develop`
- Commit `.env`, `.key`, credential files, or API keys
- Change `CONFIG.API_BASE` to `localhost` and commit it
- Add Python dependencies without updating `requirements.txt`
- Create a new backend route without documenting it in `docs/api-reference.md`
- Mutate Alpine arrays in-place (use `map`, `filter`, spread)
- Drop or rename a column without notifying the team first

### Always

- Branch from `develop` (not `main`)
- Test the full flow locally (backend + frontend) before opening a PR
- Target `develop` in your PR (not `main`)
- Describe what changed and how to test in the PR body
- Rebase on `develop` before push to avoid messy merge commits
- Run `git status` and confirm no unintended files are staged before committing

---

## FAQ

**How do I deploy?**

You don't — Railway and Vercel deploy automatically when a PR is merged to `main`. To test a branch in a staging-like environment, push to `develop` first and verify there.

**How do I view backend logs?**

Railway Dashboard → your project → backend service → Logs tab. For local dev, logs stream to your terminal.

**How do I reset a user's password?**

The password reset endpoint (`POST /api/auth/reset-password`) logs the request but doesn't send email yet. To reset manually:

```sql
-- In Supabase SQL Editor
-- Option 1: Set a known bcrypt hash (generate at bcrypt.online)
UPDATE auth_users
SET password_hash = '$2b$12$...'
WHERE email = 'user@example.com';

-- Option 2: Delete and re-register via /api/auth/register
```

**Can I modify the database schema?**

Yes, via Supabase SQL Editor. For `CREATE TABLE`, `CREATE VIEW`, and `ADD COLUMN`: go ahead, but notify the team on Slack. For `DROP`, `RENAME`, or `ALTER COLUMN`: get explicit approval first and do it in off-hours.

**How do I add a new integration (e.g., a third-party API)?**

1. Add the credentials as Railway environment variables (Railway dashboard → Variables)
2. Initialize the client in `14-APP-server.py` at startup (near the top where other clients are initialized)
3. Check `INTEGRATION_CONFIGURED = bool(os.getenv('INTEGRATION_API_KEY'))` for graceful degradation
4. Add the config status to `/api/health`
5. Implement handlers following the existing pattern

**The Supabase JS client is returning 403 on a new view**

The anon role doesn't have SELECT permission. Run in SQL Editor:
```sql
GRANT SELECT ON vw_sua_view TO anon;
```
If the underlying tables have RLS, also ensure the anon role satisfies the policies.

**Why is `http.server` used instead of Flask/FastAPI?**

Deliberate simplicity: zero framework deps, no version conflicts, trivial Railway deploy. The backend is not performance-critical — it handles at most a few concurrent staff users. If throughput ever becomes a concern, migrating to FastAPI is a ~4-hour effort since the handler structure is already clean.

**How does the pending messages count stay in sync?**

`vw_god_overview` (mentee list) and `vw_god_pendencias` (unanswered interactions) are computed independently in Postgres. Their counts will differ if the view logic diverges. To keep them in sync without changing the DB views, the frontend reconciles `msgs_pendentes_resposta` per mentee immediately after loading `pendencias.data`:

```javascript
// After loading vw_god_pendencias:
const pendsByMentee = {};
pendencias.data.forEach(p => {
  if (p.mentorado_id) pendsByMentee[p.mentorado_id] = (pendsByMentee[p.mentorado_id] || 0) + 1;
});
this.data.mentees = this.data.mentees.map(m => ({
  ...m,
  msgs_pendentes_resposta: pendsByMentee[m.id] || 0,
}));
```

`data.pendencias.length` is then the single source of truth for the dashboard KPI count.
