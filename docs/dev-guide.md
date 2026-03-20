# Spalla Dashboard — Dev Guide

> Para devs que vão contribuir com o projeto. Leitura obrigatória antes do primeiro commit.

---

## Stack

| Layer | Tecnologia |
|-------|-----------|
| Frontend | HTML + Alpine.js (SPA, zero build step) |
| Backend | Python 3.9 — `http.server` (sem framework) |
| Database | Supabase (Postgres + PostgREST + pgvector) |
| Deploy backend | Railway (auto-deploy do branch `main`) |
| Deploy frontend | Vercel (auto-deploy do branch `main`) |
| WhatsApp | Evolution API (self-hosted) |
| Armazenamento de mídia | Hetzner Object Storage (S3-compatible) |

---

## Estrutura do repositório

```
spalla-dashboard/
├── app/
│   ├── backend/
│   │   ├── 14-APP-server.py          # Backend completo (único arquivo Python)
│   │   ├── requirements.txt
│   │   └── requirements-railway.txt  # Railway-specific (sem bcrypt binário)
│   └── frontend/
│       ├── 10-APP-index.html         # SPA completa (Vercel serve direto)
│       └── 11-APP-app.js             # Lógica Alpine.js (~6800 linhas)
├── docs/
│   ├── api-reference.md              # Este guia de API
│   └── dev-guide.md                  # Este arquivo
└── deploy/                           # Docker/deploy configs
```

---

## Setup local (macOS/Linux)

### 1. Clone e branch

```bash
git clone git@github.com:case-company/spalla-dashboard.git
cd spalla-dashboard

# Sempre cria branch a partir de develop, NUNCA de main
git checkout develop
git pull origin develop
git checkout -b feature/case/nome-da-feature
```

### 2. Backend

```bash
cd app/backend

# Cria virtualenv
python3 -m venv .venv
source .venv/bin/activate

# Instala dependências
pip install -r requirements.txt

# Cria o .env com as variáveis necessárias
cp .env.example .env   # (se existir) ou cria manualmente — ver tabela abaixo

# Sobe o servidor
python 14-APP-server.py
# → http://localhost:9999
```

**Variáveis mínimas para rodar localmente:**

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_SERVICE_KEY=eyJ...
JWT_SECRET=qualquer-string-longa-aqui
PORT=9999
```

> Sem as variáveis de Zoom/GCal/Evolution, essas features simplesmente não funcionam — o resto opera normalmente.

### 3. Frontend

O frontend é HTML puro — basta abrir no browser ou usar qualquer servidor estático:

```bash
# Opção 1: Python (zero deps)
cd app/frontend
python3 -m http.server 3000
# → http://localhost:3000

# Opção 2: npx serve
npx serve app/frontend -p 3000

# Opção 3: VS Code Live Server extension
```

**Apontar o frontend para o backend local:**

No `11-APP-app.js`, procure `CONFIG.API_BASE` e altere temporariamente para `http://localhost:9999` se necessário. Mas normalmente o frontend em produção já está configurado para apontar para Railway.

> **Nunca commite** uma mudança de `CONFIG.API_BASE` apontando para `localhost`.

---

## Fluxo de branches

```
main        ← Production (Railway + Vercel auto-deploy)
  ↑
develop     ← Integração (PR alvo padrão)
  ↑
feature/case/<slug>   ← Sua feature
fix/case/<slug>       ← Seu bugfix
```

**Regras:**
- PRs sempre para `develop` — **nunca diretamente para `main`**
- `main` só recebe PRs de `develop` (ou hotfixes críticos via `hotfix/case/<slug>`)
- Nomes de branch seguem o padrão: `feature/case/<slug>` ou `fix/case/<slug>`

---

## Convenção de commits

Formato: `tipo(escopo): descrição curta` — máx. 72 chars

```bash
feat(case): adiciona filtro por consultor no kanban
fix(auth): remove coluna role inexistente da query
refactor(storage): extrai helper _chunk_multipass
docs(api): atualiza referência de endpoints
chore(deps): atualiza requirements.txt
```

**Tipos válidos:** `feat`, `fix`, `docs`, `refactor`, `style`, `test`, `chore`, `perf`, `ci`, `security`

---

## Criando uma PR

```bash
# 1. Garante que o branch está atualizado com develop
git fetch origin
git rebase origin/develop

# 2. Push
git push origin feature/case/nome-da-feature

# 3. Cria PR via CLI
gh pr create \
  --base develop \
  --title "feat(case): descrição" \
  --body "## O que muda\n- item\n\n## Como testar\n- [ ] passo"
```

**Checklist antes de abrir PR:**
- [ ] `git status` limpo (sem arquivos de `.env`, `.key`, credenciais)
- [ ] Testei localmente (backend + frontend)
- [ ] Não modifiquei arquivos fora do escopo da feature
- [ ] Commits seguem a convenção

---

## Regras críticas

### ❌ NUNCA faça

- Push direto para `main` ou `develop`
- Commit de `.env`, `.key`, credentials
- Modificar `CONFIG.API_BASE` para localhost e commitar
- Adicionar dependências sem atualizar `requirements.txt`
- Criar rotas no backend sem documentar em `docs/api-reference.md`

### ✅ SEMPRE faça

- Cria branch a partir de `develop`
- Testa localmente antes de abrir PR
- PR vai para `develop`
- Descreve o que mudou e como testar no corpo da PR

---

## Arquitetura do backend

O backend é um único arquivo Python usando `http.server.BaseHTTPRequestHandler`. Não usa Flask, FastAPI ou qualquer framework — é HTTP puro.

**Roteamento manual:** o `do_GET`, `do_POST`, `do_PUT`, `do_DELETE` fazem o dispatch por `self.path`.

**Para adicionar um novo endpoint:**

```python
# 1. Em do_POST (ou do_GET):
elif self.path == '/api/meu-endpoint':
    self._handle_meu_endpoint()

# 2. Implemente o handler:
def _handle_meu_endpoint(self):
    try:
        body = json.loads(self._read_body())
        # lógica...
        self._send_json({'success': True})
    except Exception as e:
        log_error('MeuEndpoint', str(e), e)
        self._send_json({'error': str(e)}, 500)
```

**Supabase no backend:** use sempre `supabase_request(method, path, body)`:

```python
# GET
result = supabase_request('GET', 'minha_tabela?campo=eq.valor&select=id,nome')

# POST (insert)
result = supabase_request('POST', 'minha_tabela', {'campo': 'valor'})

# PATCH (update)
result = supabase_request('PATCH', 'minha_tabela?id=eq.42', {'campo': 'novo_valor'})
```

---

## Arquitetura do frontend

**Single Page Application** baseada em Alpine.js. Toda a lógica está em `11-APP-app.js` e o HTML em `10-APP-index.html`.

**Estrutura do Alpine store:**

```
Alpine.data('app', () => ({
  ui: {
    page: 'dashboard',        // página atual
    filters: {},              // filtros da lista de mentorados
    search: '',               // busca
    ...
  },
  data: {
    mentees: [],              // vw_god_overview
    pendencias: [],           // vw_god_pendencias
    cohort: [],               // vw_god_cohort
    calls: [],                // calls_mentoria
    ...
  },
  // computed getters, métodos...
}))
```

**Navegação entre páginas:**

```javascript
// Sempre use navigate() para mudar de página — ele cuida de side effects
this.navigate('financeiro');
```

**Para adicionar uma nova página:**

1. Adicionar nav item no sidebar (`10-APP-index.html`)
2. Adicionar bloco `PAGE: NOME` no HTML com `x-show="ui.page === 'nome'"`
3. Adicionar `if (page === 'nome') this.loadNome()` em `navigate()` no JS
4. Implementar `loadNome()` no JS

---

## Supabase — dicas

O frontend acessa Supabase diretamente via JS client (`@supabase/supabase-js`) para leituras de views.
O backend acessa via REST API com a service key para operações privilegiadas.

**Adicionar uma nova view:**

1. Criar a view no Supabase SQL Editor
2. Adicionar RLS policy: `CREATE POLICY "read_all" ON vw_minha_view FOR SELECT USING (true);`
3. No frontend: `sb.from('vw_minha_view').select('*')`

---

## Dúvidas frequentes

**"Como faço deploy?"**
Não precisa fazer nada — o Railway e Vercel fazem auto-deploy quando um PR é mergeado em `main`. Para testar em develop, abra um PR para develop primeiro.

**"Como vejo os logs do backend?"**
Railway Dashboard → seu serviço → Logs. Em desenvolvimento local, saem no terminal.

**"Como faço para resetar a senha de um usuário?"**
Ainda não há email service. Use o Supabase dashboard para atualizar `password_hash` diretamente, ou implemente o endpoint `/api/auth/reset-password` com email service.

**"Posso modificar o schema do banco?"**
Sim, via Supabase SQL Editor. Para mudanças críticas (drop column, rename), avise o time antes e faça na janela de menor uso.
