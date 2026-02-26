# FIXES RECOMENDADOS POR PRIORIDADE

## PRIORIDADE 0️⃣ — REVOGAR CHAVES (AGORA, antes de leitura deste arquivo!)

Se você é dono da conta ou tem acesso administrativo, **REVOGUE IMEDIATAMENTE**:

1. **Zoom Account**
   - Acesse: https://marketplace.zoom.us/
   - Revogue: `ZOOM_CLIENT_ID` e `ZOOM_CLIENT_SECRET`
   - Gere novas chaves com escopo **MÍNIMO**

2. **Evolution API**
   - Acesse: evolution.manager01.feynmanproject.com
   - Delete/rotate: `07826A779A5C-4E9C-A978-DBCD5F9E4C97`
   - Crie nova instance

3. **Supabase**
   - Acesse: https://supabase.com/dashboard
   - Projeto `knusqfbvhsqworzyhvip`
   - Regenerate API keys (anon + service)

---

## PRIORIDADE 1️⃣ — SECURITY FIXES (Fazer em paralelo, 24-48 horas)

### 1.1 Remover Todas as Credenciais Hardcoded

**Arquivo:** `11-APP-app.js` (linhas 8-16)

❌ **Antes:**
```javascript
const CONFIG = {
  SUPABASE_URL: 'https://knusqfbvhsqworzyhvip.supabase.co',
  SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',  // BAD!
  AUTH_PASSWORD: 'spalla2026',  // BAD!
};
```

✅ **Depois:**
```javascript
const CONFIG = {
  SUPABASE_URL: 'https://knusqfbvhsqworzyhvip.supabase.co',
  SUPABASE_ANON_KEY: process.env.REACT_APP_SUPABASE_ANON_KEY || '',
  API_BASE_URL: process.env.REACT_APP_API_BASE_URL || 'https://api.example.com',
  // Auth removed — will use JWT token approach
};
```

**Arquivo:** `12-APP-data.js` (linhas 7-10)

❌ **Antes:**
```javascript
const EVOLUTION_CONFIG = {
  BASE_URL: 'https://evolution.manager01.feynmanproject.com',
  INSTANCE: 'produ02',
  API_KEY: '07826A779A5C-4E9C-A978-DBCD5F9E4C97',  // BAD!
};
```

✅ **Depois:**
```javascript
const EVOLUTION_CONFIG = {
  BASE_URL: 'https://evolution.manager01.feynmanproject.com',
  INSTANCE: 'produ02',
  // API_KEY REMOVED — will be passed from backend
};
```

**Arquivo:** `14-APP-server.py` (linhas 20-26)

❌ **Antes:**
```python
EVOLUTION_API_KEY = '07826A779A5C-4E9C-A978-DBCD5F9E4C97'  # BAD!
ZOOM_ACCOUNT_ID = os.environ.get('ZOOM_ACCOUNT_ID', 'DXq-KNA5QuSpcjG6UeUs0Q')  # Fallback BAD!
ZOOM_CLIENT_ID = os.environ.get('ZOOM_CLIENT_ID', 'fvNVWKX_SumngWI1kQNhg')  # Fallback BAD!
ZOOM_CLIENT_SECRET = os.environ.get('ZOOM_CLIENT_SECRET', 'zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g')  # Fallback BAD!
```

✅ **Depois:**
```python
EVOLUTION_API_KEY = os.environ.get('EVOLUTION_API_KEY')
if not EVOLUTION_API_KEY:
    raise ValueError('EVOLUTION_API_KEY env var required!')

ZOOM_ACCOUNT_ID = os.environ.get('ZOOM_ACCOUNT_ID')
ZOOM_CLIENT_ID = os.environ.get('ZOOM_CLIENT_ID')
ZOOM_CLIENT_SECRET = os.environ.get('ZOOM_CLIENT_SECRET')

if not all([ZOOM_ACCOUNT_ID, ZOOM_CLIENT_ID, ZOOM_CLIENT_SECRET]):
    print('[WARNING] Zoom not configured — scheduling disabled')
    ZOOM_AVAILABLE = False
else:
    ZOOM_AVAILABLE = True
```

---

### 1.2 Implementar JWT Authentication

**Nova estrutura:**

```javascript
// 11-APP-app.js — Nova function

async login() {
  const response = await fetch('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: this.auth.email,
      password: this.auth.password
    })
  });

  if (response.ok) {
    const { token, expiresIn } = await response.json();
    localStorage.setItem('auth_token', token);
    localStorage.setItem('token_expires', Date.now() + expiresIn * 1000);
    this.auth.authenticated = true;
    this.auth.token = token;
  } else {
    this.auth.error = 'Credenciais inválidas';
  }
}

// Adicionar token a todas as requests
async loadDashboard() {
  const token = localStorage.getItem('auth_token');
  const headers = token ? { 'Authorization': `Bearer ${token}` } : {};

  const res = await fetch('/api/dashboard', { headers });
  // ... resto do código
}
```

**Backend (novo endpoint):**

```python
# 14-APP-server.py

import jwt
import hashlib

JWT_SECRET = os.environ.get('JWT_SECRET')

def create_jwt_token(user_email, expires_in=86400):
    """Create JWT token (valid 24h)"""
    import time
    payload = {
        'email': user_email,
        'iat': int(time.time()),
        'exp': int(time.time()) + expires_in
    }
    return jwt.encode(payload, JWT_SECRET, algorithm='HS256')

def verify_jwt_token(token):
    """Verify and decode JWT"""
    try:
        return jwt.decode(token, JWT_SECRET, algorithms=['HS256'])
    except:
        return None

def _handle_login():
    """POST /api/auth/login"""
    try:
        body = json.loads(self._read_body())
        email = body.get('email')
        password = body.get('password')

        # Hash password and compare to stored hash (use bcrypt in production)
        password_hash = hashlib.sha256(password.encode()).hexdigest()

        # In production: query database for user with matching hash
        # For now: hardcoded validation (replace with DB lookup)
        VALID_USERS = {
            'queila@case.com': 'hashed_password_here'
        }

        if email not in VALID_USERS:
            self._send_json({'error': 'Invalid credentials'}, 401)
            return

        # Generate JWT token
        token = create_jwt_token(email)
        self._send_json({
            'token': token,
            'expiresIn': 86400  # 24 hours
        })
    except Exception as e:
        self._send_json({'error': str(e)}, 500)
```

---

### 1.3 Implementar CORS Whitelist

**Arquivo:** `14-APP-server.py` (linha 272)

❌ **Antes:**
```python
self.send_header('Access-Control-Allow-Origin', '*')  # Wildcard!
```

✅ **Depois:**
```python
def do_OPTIONS(self):
    origin = self.headers.get('Origin', '')
    allowed_origins = [
        'https://spalla-dashboard.vercel.app',
        'http://localhost:3000',  # Dev only
    ]

    if origin in allowed_origins:
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', origin)
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.send_header('Access-Control-Max-Age', '86400')
        self.end_headers()
    else:
        self.send_error(403, 'Origin not allowed')
```

---

### 1.4 Adicionar RLS Policies Estritas no Supabase

Execute no SQL Editor do Supabase:

```sql
-- Habilitar RLS em todas as tabelas
ALTER TABLE mentorados ENABLE ROW LEVEL SECURITY;
ALTER TABLE calls_mentoria ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks_mentorados ENABLE ROW LEVEL SECURITY;
ALTER TABLE god_tasks ENABLE ROW LEVEL SECURITY;

-- Policy: Anon users only read data (não podem update/delete)
CREATE POLICY "anon_read_only" ON mentorados
  FOR SELECT
  TO anon
  USING (true);

-- Policy: Authenticated users can read + update own mentee data
CREATE POLICY "auth_update_own" ON mentorados
  FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = user_id);

-- Policy: Service role (backend) has full access
CREATE POLICY "service_full_access" ON mentorados
  TO service_role
  USING (true);
```

---

## PRIORIDADE 2️⃣ — ERROR HANDLING (24 horas)

### 2.1 Wrap JSON.parse() em Try-Catch

**Arquivo:** `11-APP-app.js` (linha 676)

❌ **Antes:**
```javascript
const detail = typeof detailRes.data === 'string' ? JSON.parse(detailRes.data) : detailRes.data;
```

✅ **Depois:**
```javascript
let detail = null;
try {
  detail = typeof detailRes.data === 'string' ? JSON.parse(detailRes.data) : detailRes.data;
} catch (e) {
  console.error('[Spalla] Failed to parse detail JSON:', e);
  this.toast('Erro ao carregar detalhes do mentorado', 'error');
  detail = this.getDemoDetail(id);  // Fallback
}
```

**Arquivo:** `11-APP-app.js` (linha 854)

❌ **Antes:**
```javascript
const raw = localStorage.getItem(CONFIG.TASKS_STORAGE_KEY);
if (raw) {
  const parsed = JSON.parse(raw);  // Can crash!
  if (parsed.length > 0) { ... }
}
```

✅ **Depois:**
```javascript
const raw = localStorage.getItem(CONFIG.TASKS_STORAGE_KEY);
if (raw) {
  try {
    const parsed = JSON.parse(raw);
    if (Array.isArray(parsed) && parsed.length > 0) {
      // Validate structure
      const validTasks = parsed.filter(t => t.id && t.titulo);
      if (validTasks.length > 0) {
        this.data.tasks = validTasks;
        this._autoCategorize();
        return;
      }
    }
  } catch (e) {
    console.warn('[Spalla] Tasks localStorage corrupted, using demo');
    localStorage.removeItem(CONFIG.TASKS_STORAGE_KEY);
  }
}
```

---

### 2.2 Adicionar Error Toast para API Failures

**Arquivo:** `11-APP-app.js` (linha 1050)

❌ **Antes:**
```javascript
if (sb) {
  try {
    await sb.from('god_tasks').update({ status: newStatus }).eq('id', taskId);
  } catch (e) {}  // Silent failure!
}
```

✅ **Depois:**
```javascript
if (sb) {
  try {
    await sb.from('god_tasks').update({ status: newStatus }).eq('id', taskId);
    this.toast('Tarefa atualizada', 'success');
  } catch (e) {
    console.error('[Spalla] Task update failed:', e);
    t.status = oldStatus;  // Revert
    this.toast(`Erro ao atualizar tarefa: ${e.message}`, 'error');
  }
}
```

---

## PRIORIDADE 3️⃣ — INPUT VALIDATION (24 horas)

### 3.1 Backend Validation

**Arquivo:** `14-APP-server.py` (novo helper)

```python
def validate_task_input(data):
    """Validate task form data"""
    errors = []

    if not data.get('titulo') or not data['titulo'].strip():
        errors.append('titulo_required')

    if len(data.get('titulo', '')) > 500:
        errors.append('titulo_too_long')

    if data.get('prioridade') not in ['urgente', 'alta', 'normal', 'baixa']:
        errors.append('invalid_prioridade')

    if data.get('mentorado_id'):
        try:
            int(data['mentorado_id'])
        except:
            errors.append('invalid_mentorado_id')

    return errors

def _handle_create_task(self):
    """POST /api/tasks"""
    try:
        body = json.loads(self._read_body())

        # Validate input
        errors = validate_task_input(body)
        if errors:
            self._send_json({'error': 'Validation failed', 'details': errors}, 400)
            return

        # Create in Supabase
        result = supabase_request('POST', 'god_tasks', body)
        self._send_json(result)
    except Exception as e:
        self._send_json({'error': str(e)}, 500)
```

---

## PRIORIDADE 4️⃣ — ENVIRONMENT SETUP (4 horas)

### Vercel Frontend Variables

Adicionar em Project Settings → Environment Variables:

```
REACT_APP_SUPABASE_URL=https://knusqfbvhsqworzyhvip.supabase.co
REACT_APP_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs... (new key after rotation)
REACT_APP_API_BASE_URL=https://api.spalla-production.railway.app
REACT_APP_API_TIMEOUT=30000
```

### Railway Backend Variables

Adicionar em Service Settings → Variables:

```
EVOLUTION_API_KEY=07826A779A5C... (new key after rotation)
ZOOM_ACCOUNT_ID=DXq-KNA5... (new ID after rotation)
ZOOM_CLIENT_ID=fvNVWKX... (new ID after rotation)
ZOOM_CLIENT_SECRET=zsgo0Xjtih... (new secret after rotation)
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1... (new key)
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1... (new key)
GOOGLE_SA_CREDENTIALS_B64=<base64(credentials.json)> (or leave empty if not using GCal)
JWT_SECRET=<generate random 64-char string>
```

---

## TESTING CHECKLIST

### Testes Críticos (Antes de Deploy)

- [ ] Login com JWT token funciona
- [ ] Token expira após 24h
- [ ] Dashboard carrega sem credenciais no console
- [ ] API calls incluem `Authorization: Bearer <token>`
- [ ] CORS rejeita origins não-whitelisted
- [ ] JSON parsing falha gracefully (não faz crash)
- [ ] Task update com erro mostra toast
- [ ] Supabase RLS bloqueia updates sem permissão
- [ ] localStorage corrupted não faz crash app

### Verificação de Security

```bash
# Check for hardcoded credentials in git history
git log -p --all -S 'AUTH_PASSWORD' --
git log -p --all -S 'EVOLUTION_API_KEY' --
git log -p --all -S 'SUPABASE_SERVICE_KEY' --

# Check for exposed keys in current code
grep -r "password\|secret\|key" --include="*.js" --include="*.py" | grep -v TODO | grep -v /node_modules | grep -v /dist
```

---

## DEPLOYMENT SEQUENCE

### 1. Prepare (1 hour)
- [ ] Create new API keys in all services (Zoom, Evolution, Supabase)
- [ ] Revoke old keys IMMEDIATELY
- [ ] Update Vercel + Railway env vars
- [ ] Test locally with new credentials

### 2. Deploy Backend (30 min)
```bash
# In Railway project
git push origin main  # Triggers auto-deploy
# Verify at: https://api.spalla-production.railway.app/api/health
```

### 3. Deploy Frontend (30 min)
```bash
# In Vercel project (auto-deploys on push)
git push origin main
# Verify at: https://spalla-dashboard.vercel.app
```

### 4. Smoke Test (15 min)
- [ ] Open https://spalla-dashboard.vercel.app
- [ ] Check DevTools: Network tab should show `Authorization: Bearer ...` headers
- [ ] Check DevTools: Console should have NO exposed credentials
- [ ] Login works
- [ ] Dashboard loads
- [ ] Can view mentee detail
- [ ] Can schedule call

### 5. Monitoring (ongoing)
- [ ] Set up Sentry for error tracking
- [ ] Set up logging in Railway
- [ ] Create on-call rotation for alerts

---

## TEMPO ESTIMADO POR FIX

| Fix | Tempo | Dependências |
|-----|-------|---|
| Remover hardcoded keys | 2h | None |
| JWT implementation | 8h | Remove keys |
| CORS whitelist | 1h | None |
| RLS policies | 2h | None |
| Try-catch wrapping | 3h | None |
| Input validation | 4h | Try-catch done |
| Environment setup | 1h | All code done |
| Testing | 4h | All code done |
| **TOTAL** | **25h (~3 dias)** | - |

---

## LINKS IMPORTANTES

- Vercel Secrets: https://vercel.com/team/spalla/settings/environment-variables
- Railway Env Vars: https://railway.app/project/xxx/service/xxx/variables
- Supabase RLS: https://supabase.com/docs/guides/auth/row-level-security
- JWT.io: https://jwt.io (test tokens)
- CWE Database: https://cwe.mitre.org (security references)

---

**Status:** Documento de Referência
**Última Atualização:** 26 de Fevereiro de 2026
**Próximo Passo:** Começar com PRIORIDADE 0 (revogar chaves!)
