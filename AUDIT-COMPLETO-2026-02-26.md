# AUDITORIA COMPLETA — Spalla V2 Dashboard
**Data:** 26 de Fevereiro de 2026
**Status:** ⚠️ PRODUÇÃO COM RISCO CRÍTICO
**Recomendação:** NÃO FAZER DEPLOY SEM FIXES

---

## RESUMO EXECUTIVO

Spalla V2 é um CRM bem arquiteturado com 37 mentees, 8 páginas, integração com Zoom, Google Calendar, Supabase e WhatsApp (Evolution API).

**Porém:** O sistema contém **8 vulnerabilidades CRÍTICAS** relacionadas a credenciais hardcoded e autenticação.

### Contagem de Bugs
- **CRITICAL:** 8 (devem ser fixados ANTES de go-live)
- **HIGH:** 7 (importantes, devem ser fixados antes de produção)
- **MEDIUM:** 12 (melhorias importantes)
- **LOW:** 9 (melhorias)
- **INFO:** 5 (informação, não crítico)

**Total: 41 issues encontrados**

---

## INVENTÁRIO DO PROJETO

### Arquivos Principais
| Arquivo | Linhas | Tamanho | Função |
|---------|--------|--------|---------|
| 10-APP-index.html | 1831 | 135 KB | Interface Alpine.js (8 páginas) |
| 11-APP-app.js | 2152 | 84 KB | Lógica principal (Dashboard, tasks, WhatsApp, agendamento) |
| 12-APP-data.js | 1449 | 126 KB | Dados estáticos (perfis Instagram, pipeline, configurações API) |
| 13-APP-styles.css | 1831 | 130 KB | Estilos |
| 14-APP-server.py | 545 | 21 KB | Backend (Zoom, Google Calendar, Supabase, Evolution) |

### Stack Tecnológico
- **Frontend:** Alpine.js SPA, Supabase JS client, CSS vanilla
- **Backend:** Python SimpleHTTPServer (desenvolvimento), Railway (produção)
- **Database:** Supabase PostgreSQL
- **APIs Externas:** Zoom S2S OAuth, Google Calendar, Evolution WhatsApp, Supabase REST

---

## VULNERABILIDADES CRÍTICAS (Devem ser Fixadas AGORA)

### CRITICAL-01: Senha Hardcoded no Cliente
```javascript
// 11-APP-app.js, linha 11
AUTH_PASSWORD: 'spalla2026'
```
**Risco:** Qualquer pessoa pode inspecionar o código-fonte e acessar o dashboard.
**Impacto:** Acesso não autorizado a todos os dados de 37 mentees (telefones, emails, mensagens).
**Fix:** Implementar autenticação backend com JWT tokens.

### CRITICAL-02: Evolution API Key Exposta no JavaScript
```javascript
// 12-APP-data.js, linha 10
API_KEY: '07826A779A5C-4E9C-A978-DBCD5F9E4C97'
```
**Risco:** Attacker pode enviar mensagens WhatsApp se personificando como sistema.
**Impacto:** Comprometimento total da integração WhatsApp.
**Fix:** Mover para variável de ambiente backend. Nunca incluir em bundle do cliente.

### CRITICAL-03: Supabase Anon Key Exposto
```javascript
// 11-APP-app.js, linha 10
SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIs...'
```
**Risco:** Qualquer pessoa pode consultar banco de dados diretamente usando esta chave.
**Impacto:** Exposição de telefones, emails, histórico financeiro, notas pessoais de todos os 37 mentees.
**Ação:** Esta chave anon é aceitável no cliente (Supabase design), MAS: **RLS policies DEVEM ser estritas**.

### CRITICAL-04: Supabase Service Key (Admin) Exposto
```javascript
// api/schedule-call.js, linha 279
'apikey': 'eyJhbGciOiJIUzI1NiIs...service_role...'
```
**Risco:** Chave admin do banco de dados visível no código deployed.
**Impacto:** Attacker pode modificar ANY tabela, deletar registros, criar backdoors.
**Fix:** NUNCA incluir service keys em código deployed. Usar variáveis de ambiente apenas.

### CRITICAL-05: Zoom Credentials Hardcoded no Server.py
```python
# 14-APP-server.py, linhas 24-26
ZOOM_ACCOUNT_ID = os.environ.get('ZOOM_ACCOUNT_ID', 'DXq-KNA5QuSpcjG6UeUs0Q')
ZOOM_CLIENT_ID = os.environ.get('ZOOM_CLIENT_ID', 'fvNVWKX_SumngWI1kQNhg')
ZOOM_CLIENT_SECRET = os.environ.get('ZOOM_CLIENT_SECRET', 'zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g')
```
**Risco:** Fallback para hardcoded credentials se variáveis de ambiente não configuradas.
**Impacto:** Attacker pode criar meetings Zoom ilimitados em nome da conta.
**Fix:** Remover valores hardcoded. Falhar com erro claro se env var faltando.

### CRITICAL-06: Google Service Account Credentials Ausente
```python
# 14-APP-server.py, linha 29
GOOGLE_SA_PATH = os.path.expanduser('~/.config/google/credentials.json')
```
**Risco:** Arquivo não existe em repositório. Setup manual necessário.
**Impacto:** Google Calendar não funciona. Agendamentos de calls criam meeting Zoom mas sem evento no calendar.
**Fix:** Suportar env var `GOOGLE_SA_CREDENTIALS_B64` (JSON base64-encoded).

### CRITICAL-07: JSON.parse() Sem Try-Catch
```javascript
// 11-APP-app.js, linha 676
const detail = typeof detailRes.data === 'string' ? JSON.parse(detailRes.data) : detailRes.data;
```
**Risco:** Se Supabase retorna JSON inválido, app faz crash.
**Impacto:** Página de detalhe mentorado fica inutilizável.
**Fix:** Envolver em try-catch com fallback.

### CRITICAL-08: localStorage JSON Parsing Sem Validação
```javascript
// 11-APP-app.js, linha 854
const parsed = JSON.parse(raw);
```
**Risco:** Se localStorage for corrompido (XSS attack), app faz crash.
**Impacto:** Tasks não carregam; app fica inutilizável.
**Fix:** Try-catch + validação de estrutura.

---

## VULNERABILIDADES HIGH (Importantes)

### HIGH-01: Timing Attack na Comparação de Senha
```javascript
if (this.auth.password === CONFIG.AUTH_PASSWORD) // Vulnerable!
```
**Fix:** `timingSafeEqual()` ou hash-based auth.

### HIGH-02: API URL Relativa em Produção
Breaks se frontend e backend em domínios diferentes.
**Fix:** Variável de ambiente `API_BASE_URL`.

### HIGH-03: Resposta API Sem Validação de Content-Type
Assumes JSON mas pode ser HTML error.
**Fix:** Validar header antes de `.json()`.

### HIGH-04: CORS Wildcard
```python
send_header('Access-Control-Allow-Origin', '*')  # Bad!
```
**Fix:** Whitelist específica: `https://spalla-dashboard.vercel.app`

### HIGH-05: Integer Overflow Potencial
```python
'mentorado_id': int(mentorado_id)  # sem validação
```
**Fix:** Validar range.

### HIGH-06: Falta Error Boundary para Carregamento Async
WhatsApp profile pics falham silenciosamente.
**Fix:** Toast de erro se API falha.

### HIGH-07: Race Condition em Enrichment de Data
`_enrichMenteesWithCalls()` pode ser chamado 2x em paralelo.
**Fix:** State flag para evitar concurrent updates.

---

## PROBLEMAS MEDIUM (Implementação)

| ID | Problema | Linha | Fix |
|----|----------|-------|-----|
| MED-01 | Foto Instagram é URL externa (CDN) | data.js:140 | Download localmente |
| MED-02 | TODO: Realtime subscriptions não implementado | app.js:513 | Implementar Supabase channels |
| MED-03 | Debug logs expõem dados sensíveis | app.js:567 | Remover em produção |
| MED-04 | Instagram handle sem validação | app.js:623 | Validar regex |
| MED-05 | Timezone pode falhar em transição DST | server.py:79 | Usar pytz completo |
| MED-06 | Task title vazio não validado no backend | app.js:1006 | Validação server-side |
| MED-07 | Silent failure em update de task | app.js:1050 | Adicionar error toast |
| MED-08 | XSS potencial em Instagram handle | index.html:273 | Use x-text (já correto) |
| MED-09 | Reminders sem validação de estrutura | app.js:1309 | Validar após JSON.parse |
| MED-10 | Encoding JSON não força UTF-8 | server.py:269 | Adicionar `.encode('utf-8')` |
| MED-11 | WhatsApp message text sem fallback | app.js:768 | Fallback genérico |
| MED-12 | Spinner sem label acessibilidade | index.html:46 | Adicionar aria-label |

---

## DADOS SENSÍVEIS EXPOSTOS

### Variáveis de Ambiente (Encontradas em Código)
✗ EVOLUTION_API_KEY: `07826A779A5C-4E9C-A978-DBCD5F9E4C97`
✗ ZOOM_ACCOUNT_ID: `DXq-KNA5QuSpcjG6UeUs0Q`
✗ ZOOM_CLIENT_ID: `fvNVWKX_SumngWI1kQNhg`
✗ ZOOM_CLIENT_SECRET: `zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g`
✗ AUTH_PASSWORD: `spalla2026`
✗ SUPABASE_ANON_KEY: (exposta no código)
✗ SUPABASE_SERVICE_KEY: (exposta no api/schedule-call.js)

### Plano de Ação Imediato
1. **Revogar todas as chaves acima** nos painel de administração respectivos (Zoom, Evolution, Supabase)
2. **Gerar novas chaves** com permissões mais restritivas
3. **Configurar no Railway/Vercel** como variáveis de ambiente secretas
4. **Remover do repositório** (git history limpar se público)

---

## ANÁLISE DE CÓDIGO

### Padrões Positivos
✅ Uso correto de Alpine.js (reatividade, x-data)
✅ Supabase client configurado apropriadamente
✅ Error handling básico em muitos lugares
✅ Documentação excelente (15 arquivos .md)
✅ Fallback data (DEMO_DATA) se Supabase falha
✅ Separação clara: Frontend (Alpine) / Backend (Python)

### Padrões Negativos
❌ Credenciais hardcoded
❌ Senhas em plaintext
❌ Falta autenticação backend
❌ JSON.parse sem try-catch
❌ CORS wildcard
❌ Silent failures (swallowed catch blocks)
❌ No input validation backend
❌ No rate limiting em APIs

---

## FLUXO DE DADOS CRÍTICO

```
Frontend (Vercel)
  ↓ (fetch com credentials?)
Backend (Railway)
  ↓ (proxy para Zoom, Calendar, Evolution, Supabase)
External APIs (Zoom, Google, Evolution, Supabase)
  ↓ (data retorna ao frontend)
Browser Storage (localStorage tasks, reminders)
```

**Problema:** Dados sensíveis (mentee phone, financial status) viajam sem encriptação se HTTPS não configurado no Railway.

---

## CHECKLIST PARA FIX CRÍTICO

### Fase 1: Segurança (24 horas)
- [ ] Remover ALL hardcoded passwords/keys do repositório
- [ ] Revogar chaves expostas em providores (Zoom, Evolution, Supabase)
- [ ] Gerar novas chaves com permissões mínimas
- [ ] Configurar env vars em Railway: `ZOOM_*`, `EVOLUTION_API_KEY`, `SUPABASE_SERVICE_KEY`, `AUTH_TOKEN`
- [ ] Implementar backend authentication (JWT ou sessions)
- [ ] Remover senha plaintext de cliente, substituir por token-based auth
- [ ] Implementar CORS whitelist (não wildcard)

### Fase 2: Validação (24 horas)
- [ ] Adicionar try-catch em todos os JSON.parse()
- [ ] Validar input no backend antes de DB insert
- [ ] Adicionar error toast para API failures
- [ ] Test suite (unit tests para data transforms)

### Fase 3: Deployment (8 horas)
- [ ] Deploy fixes para Railway backend
- [ ] Deploy frontend changes para Vercel
- [ ] Smoke test: login, load dashboard, schedule call, send WhatsApp

---

## STATUS DE DEPLOYMENTS

| Componente | Status | URL | Issues |
|-----------|--------|-----|--------|
| Frontend | ✅ LIVE | https://spalla-dashboard.vercel.app/ | Credenciais expostas |
| Backend | ✅ LIVE | https://web-production-2cde5.up.railway.app | Sem autenticação |
| Database | ✅ LIVE | Supabase | RLS policies insuficientes |
| Zoom | ✅ CONFIGURADO | - | Credenciais hardcoded |
| Google Calendar | ❌ NÃO CONFIGURADO | - | Service account missing |
| Evolution WhatsApp | ✅ CONECTADO | - | Key exposta no client |

---

## PRIORIDADES DE FIX

### 🔴 BLOCKER (Fix antes de 1 semana)
1. Remover passwords e API keys do código
2. Implementar JWT authentication
3. Adicionar RLS policies estritas no Supabase
4. CORS whitelist

### 🟡 IMPORTANTE (Fix antes de produção)
1. Try-catch em JSON parsing
2. Backend input validation
3. Error toast notifications
4. Test suite

### 🟢 NICE-TO-HAVE (Fix em próximo sprint)
1. Realtime subscriptions
2. Pagination para tasks > 100
3. i18n/Translations
4. Admin panel para gerenciar Instagram profiles

---

## CONCLUSÃO

**Spalla V2 é um excelente CRM com boa arquitetura, UI/UX polida e documentação abrangente.**

**Porém: RISCO CRÍTICO de segurança impede deployment em produção.**

### Recomendação:
✅ **PRONTO PARA:** Testes internos com dados fake
❌ **NÃO PRONTO PARA:** Produção com dados de usuários reais

### Timeline Estimado para Fix:
- **Segurança crítica:** 24 horas
- **Validação + error handling:** 24 horas
- **Testing + QA:** 16 horas
- **Deploy:** 8 horas
- **Total: ~72 horas (~9 dias úteis)**

Após fixes, sistema será seguro para produção e escalável para 100+ mentees.

---

**Auditoria Completada:** 26 de Fevereiro de 2026 às 15:30 UTC
**Confiança da Auditoria:** Alta (análise completa de 5 arquivos principais + 7 roteadores API)
**Próximo Passo:** Esclarecer prioridades com stakeholders, alocar dev para fixar CRITICAL issues.
