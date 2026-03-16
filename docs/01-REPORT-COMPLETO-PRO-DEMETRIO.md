# Spalla V2 — Guia Completo para Producao

**De:** Kaique
**Para:** Demetrio
**Data:** 17/02/2026
**Assunto:** Tudo que voce precisa saber pra subir o backend + frontend do Spalla em producao

**Status:** Frontend funcional (prototipo local) + SQL deployado no Supabase. Pronto pra voce pegar e fazer o build de producao.

---

## TL;DR — O Que E o Spalla

O Spalla e um **CRM de mentoria** para o programa CASE da Queila. Mostra 37 mentorados ativos com:

- Cards com 24+ dados (fase, risco, vendas, WhatsApp, calls)
- Detalhe completo de cada mentorado (contexto IA, calls, tarefas, direcionamentos)
- Sistema de tarefas ClickUp-style (Kanban, List, Gantt)
- Agendamento de calls (Zoom + Google Calendar automatico)
- Chat WhatsApp integrado (Evolution API)
- Dossies estrategicos com pipeline de status
- Alertas automaticos (quem nao respondeu, quem nao fez call, etc.)

**Tudo alimentado por um Supabase com 12+ tabelas, 9 views SQL e 2 functions.**

---

## Arquitetura Geral

```
┌─────────────────────────────────────────────────────────────┐
│                     USUARIO (Navegador)                     │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                FRONTEND (Alpine.js)                    │  │
│  │  index.html + app.js (77KB) + data.js (146KB)         │  │
│  │  styles.css (130KB) + /photos/ (50+ JPEGs)            │  │
│  │                                                        │  │
│  │  8 Paginas:                                            │  │
│  │  Dashboard | Detalhe | Kanban | Tarefas | Agenda      │  │
│  │  WhatsApp | Dossies | Google Docs | Lembretes         │  │
│  └──────┬────────────────────────┬───────────────────────┘  │
│         │                        │                           │
│         │ Supabase JS SDK        │ fetch('/api/...')         │
│         │ (direto)               │ (via servidor)            │
│         ▼                        ▼                           │
│  ┌─────────────┐       ┌────────────────────┐               │
│  │  Supabase   │       │  server.py         │               │
│  │  (banco)    │       │  (Python HTTP)     │               │
│  │  port 443   │       │  port 8888         │               │
│  └─────────────┘       └──────┬─────────────┘               │
│                               │                              │
│              ┌────────────────┼────────────────┐             │
│              ▼                ▼                ▼              │
│        ┌──────────┐   ┌──────────┐   ┌──────────────┐       │
│        │ Zoom API │   │ Google   │   │ Evolution    │       │
│        │ (OAuth)  │   │ Calendar │   │ API (WA)     │       │
│        └──────────┘   └──────────┘   └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

**Dois caminhos de dados:**

1. **Frontend → Supabase (direto):** Leitura de views/functions + escrita em god_tasks (SDK JS do Supabase no browser)
2. **Frontend → server.py → APIs externas:** Agendamento de calls (Zoom + Calendar), proxy WhatsApp (Evolution API)

---

## 1. BANCO DE DADOS — Supabase

### Credenciais

| Item | Valor |
|------|-------|
| **Projeto** | `knusqfbvhsqworzyhvip` |
| **URL** | `https://knusqfbvhsqworzyhvip.supabase.co` |
| **Schema** | `public` |
| **Anon Key** | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtudXNxZmJ2aHNxd29yenlodmlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4NTg3MjcsImV4cCI6MjA3MDQzNDcyN30.f-m7TlmCoccBpUxLZhA4P5kr2lWBGtRIv6inzInAKCo` |
| **Service Key** | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtudXNxZmJ2aHNxd29yenlodmlwIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDg1ODcyNywiZXhwIjoyMDcwNDM0NzI3fQ.0n5eh94NQ1flgXzQQoKtnNkTxJAYztqKxwNKnHyq6dM` |
| **Password DB** | `BekIUq66EhVJ84QB` |

**Anon Key** = read-only, vai no frontend (browser). **Service Key** = full access, vai no backend (server.py).

---

### 1.1 Tabelas-Fonte (12 tabelas principais)

| # | Tabela | Registros | O Que Guarda | Quem Alimenta |
|---|--------|-----------|--------------|---------------|
| 1 | `mentorados` | 62 (37 ativos) | Perfil, fase, risco, scores, financeiro, produto | Cadastro manual + N8N |
| 2 | `calls_mentoria` | 226 | Calls gravadas (data, tipo, duracao, zoom, transcript) | Zoom scraper automatico + manual |
| 3 | `analises_call` | ~260 | Analise IA de cada call (resumo, gargalos, feedbacks) | Workflow N8N automatico |
| 4 | `interacoes_mentoria` | 23.840 | Mensagens WhatsApp dos grupos individuais | Evolution API scraper + imports |
| 5 | `extracoes_agente` | 505 | Output dos 5 agentes IA (diagnostico, estrategias, tarefas, prazos) | 5 agentes IA automaticos |
| 6 | `documentos_plano_acao` | 93 | Planos de acao gerados por call | Workflow N8N |
| 7 | `direcionamentos` | 1.362 | Orientacoes da Queila pra cada mentorado | Extracao automatica + manual |
| 8 | `tarefas_acordadas` | 9 | Tarefas combinadas nas calls | Registro manual |
| 9 | `tarefas_equipe` | 264 | Tarefas delegadas (Lara, Jennifer, etc.) | Workflow + manual |
| 10 | `marcos_mentorado` | ~104 | Milestones M0 a M5 | IA + manual |
| 11 | `travas_bloqueios` | variavel | Problemas que travam o mentorado | Deteccao automatica IA |
| 12 | `metricas_mentorado` | variavel | Vendas e metricas financeiras | Manual + calls |

**Tabelas de tarefas bidirecionais (frontend le E escreve):**

| # | Tabela | O que faz |
|---|--------|-----------|
| 13 | `god_tasks` | Tabela principal de tarefas (~800 rows) |
| 14 | `god_task_subtasks` | Sub-tarefas |
| 15 | `god_task_checklist` | Checklist |
| 16 | `god_task_comments` | Comentarios com author |
| 17 | `god_task_handoffs` | Handoffs entre pessoas |

---

### 1.2 Views SQL (9 views — READ-ONLY)

**Todas as views ja filtram automaticamente:** `WHERE ativo = true AND cohort IS DISTINCT FROM 'tese'`
O frontend nao precisa se preocupar — so vem os 37 mentorados reais.

| # | View | Rows | O Que Entrega | Frontend Usa Em |
|---|------|------|---------------|-----------------|
| 1 | `vw_god_overview` | 37 | 1 linha por mentorado com 24 dados (fase, risco, vendas, WA, calls, tarefas) | Pagina principal (cards) |
| 2 | `vw_god_tarefas` | 804+ | Todas as tarefas de 4 fontes unificadas | Pagina global de tarefas (read-only) |
| 3 | `vw_god_tasks_full` | ~800 | god_tasks + subtasks + checklist + comments + handoffs (JSON) | Pagina de tarefas bidirecional |
| 4 | `vw_god_calls` | 211 | Calls com analise IA (resumo, decisoes, gargalos, feedbacks) | Timeline de calls no detalhe |
| 5 | `vw_god_contexto_ia` | 37 | Ultimo output de cada agente IA por mentorado | Card "Contexto Inteligente" |
| 6 | `vw_god_pendencias` | 413 | Msgs WhatsApp sem resposta com prioridade calculada | Alertas |
| 7 | `vw_god_direcionamentos` | 1.673 | Direcionamentos da Queila de 3 fontes | Secao de direcionamentos |
| 8 | `vw_god_vendas` | 37 | Pipeline financeiro (faturamento, meta, % atingida) | Secao de vendas |
| 9 | `vw_god_timeline` | ~2K | Feed cronologico (calls, marcos, planos, direcionamentos) | Timeline no detalhe |
| 10 | `vw_god_cohort` | 5 | KPIs por fase (qtd, risco, medias) | Dashboard principal |

---

### 1.3 Functions SQL (2 functions — RPC)

| Function | Input | Output | Frontend Usa Em |
|----------|-------|--------|-----------------|
| `fn_god_mentorado_deep(p_id)` | bigint (ID do mentorado) | JSON com 9 secoes: profile, phase, financial, context_ia, last_calls, last_messages, pending_tasks, blockers, directions | Pagina de detalhe |
| `fn_god_alerts()` | nenhum | Array de alertas (5 tipos, ordenados por severidade) | Painel de alertas |

---

### 1.4 Como o Frontend Consome o Banco

**LEITURA (views + functions):**

```javascript
// Client Supabase (variavel "sb" no app.js, nao "supabase")
let sb = window.supabase.createClient(CONFIG.SUPABASE_URL, CONFIG.SUPABASE_ANON_KEY);

// Lista principal de mentorados (37 rows com 24 colunas)
const { data: mentees } = await sb.from('vw_god_overview').select('*');

// Detalhe completo de 1 mentorado (JSON com 9 secoes)
const { data: detail } = await sb.rpc('fn_god_mentorado_deep', { p_id: 13 });

// Alertas ativos (474 alertas)
const { data: alerts } = await sb.rpc('fn_god_alerts');

// KPIs por fase (5 rows)
const { data: kpis } = await sb.from('vw_god_cohort').select('*');

// Calls de um mentorado
const { data: calls } = await sb.from('vw_god_calls').select('*').eq('mentorado_id', 13).order('data_call', { ascending: false });

// Tarefas completas (com subtasks, comments etc)
const { data: tasks } = await sb.from('vw_god_tasks_full').select('*').order('created_at', { ascending: false }).limit(200);
```

**ESCRITA (tabela god_tasks + auxiliares):**

```javascript
// Criar/atualizar tarefa
await sb.from('god_tasks').upsert(taskData, { onConflict: 'id' });

// Sync subtasks (delete + insert)
await sb.from('god_task_subtasks').delete().eq('task_id', id);
await sb.from('god_task_subtasks').insert(subtasks);

// Adicionar comentario
await sb.from('god_task_comments').insert({ task_id, author, texto });

// Adicionar handoff
await sb.from('god_task_handoffs').insert({ task_id, from_person, to_person, note });
```

**FALLBACK:** Se Supabase nao carregar, o frontend usa dados estaticos de `data.js` + localStorage.

---

## 2. BACKEND — server.py

O server.py e um HTTP server Python simples que serve os arquivos estaticos E proxeia APIs externas.

### Credenciais

| Servico | Credencial | Valor |
|---------|-----------|-------|
| **Zoom** | Account ID | `DXq-KNA5QuSpcjG6UeUs0Q` |
| **Zoom** | Client ID | `fvNVWKX_SumngWI1kQNhg` |
| **Zoom** | Client Secret | `zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g` |
| **Google** | Service Account | `~/.config/google/credentials.json` |
| **Google** | Calendar ID | `primary` (ou configurar via env) |
| **Evolution** | Base URL | `https://evolution.manager01.feynmanproject.com` |
| **Evolution** | API Key | `07826A779A5C-4E9C-A978-DBCD5F9E4C97` |
| **Evolution** | Instancia | `produ02` |

### Endpoints

| Metodo | Endpoint | O que faz | Dependencias |
|--------|----------|-----------|-------------|
| `POST` | `/api/schedule-call` | **Orquestra tudo:** cria Zoom → cria evento Calendar → salva no Supabase | Zoom + Google + Supabase |
| `POST` | `/api/zoom/create-meeting` | So cria reuniao Zoom | Zoom |
| `POST` | `/api/calendar/create-event` | So cria evento no Calendar | Google |
| `GET` | `/api/mentees` | Lista mentorados com email (pra agendamento) | Supabase |
| `GET` | `/api/calendar/events` | Lista eventos futuros do calendario | Google |
| `GET` | `/api/calls/upcoming` | Calls agendadas no banco | Supabase |
| `GET` | `/api/health` | Status das integracoes | — |
| `GET/POST` | `/api/evolution/*` | Proxy transparente pra Evolution API (WhatsApp) | Evolution |

### Como Rodar

```bash
# Local
cd dashboard/
python server.py         # porta 8888
python server.py 3000    # porta customizada

# Acessar
open http://localhost:8888
# Senha: spalla2026
```

### Dependencias Python (pra Google Calendar)

```bash
pip install google-auth google-auth-httplib2 google-api-python-client
```

Se nao instalar, o Zoom + WhatsApp + Supabase continuam funcionando, so Google Calendar nao.

---

## 3. FRONTEND — Alpine.js SPA

### Arquivos

| Arquivo | Tamanho | O que faz |
|---------|---------|-----------|
| `index.html` | 129KB | Estrutura HTML completa (todas as paginas inline) |
| `app.js` | 77KB | Logica Alpine.js (auth, data loading, interacoes) |
| `data.js` | 146KB | Dados estaticos (Instagram, Dossies, calls fallback) |
| `styles.css` | 130KB | Estilos completos |
| `server.py` | 19KB | Backend Python |
| `/photos/` | 50+ JPGs | Fotos de perfil dos mentorados |

### Paginas (sidebar)

| Pagina | O que mostra | Fonte de dados |
|--------|-------------|----------------|
| **Dashboard** | Grid de cards de mentorados com filtros (fase/risco/cohort) | `vw_god_overview` + `fn_god_alerts` |
| **Detalhe** | Perfil completo com tabs (Resumo, Contexto IA, Tarefas, Calls, Docs, WhatsApp) | `fn_god_mentorado_deep` + `vw_god_calls` |
| **Kanban** | Board visual por fase_jornada | `vw_god_overview` |
| **Tarefas** | Board/List/Gantt ClickUp-style (3 spaces, drag-drop) | `vw_god_tasks_full` + `god_tasks` (escrita) |
| **Agenda** | Calendario com criacao de calls (Zoom+Calendar) | Google Calendar API via server.py |
| **WhatsApp** | Chat integrado com mentorados | Evolution API via server.py |
| **Dossies** | Pipeline de status dos dossies estrategicos | Dados estaticos em data.js |
| **Google Docs** | Links diretos pra pastas compartilhadas | Dados estaticos em data.js |
| **Lembretes** | Notificacoes e lembretes manuais | localStorage |

### Autenticacao

Simples, por senha:
- Senha: `spalla2026`
- Storage: `localStorage.setItem('spalla_auth', 'true')`
- Sem sessao/JWT — se limpar localStorage, precisa logar de novo.

### Fotos de Perfil

O frontend busca fotos em 2 caminhos:
1. **Arquivo local:** `/photos/{instagram_sem_arroba}.jpg` (ex: `photos/livialyra.jpg`)
2. **WhatsApp:** via Evolution API (profilePicUrl)
3. **Fallback:** Iniciais do nome com cor gradiente

A pasta `/photos/` tem ~50 JPGs nomeados pelo handle do Instagram.

### Dados Estaticos (data.js)

O `data.js` contem dados que NAO vem do Supabase:

| Dado | O que tem | Linhas aprox |
|------|-----------|-------------|
| `INSTAGRAM_PROFILES` | 40+ perfis Instagram (seguidores, bio, engagement) | 1-500 |
| `DOSSIER_PIPELINE` | 63 mentorados com status do dossie (enviado/revisao/producao/nao_iniciado) | 497-559 |
| `DOSSIER_LINKS` | Links Google Docs dos dossies | 560-620 |
| `GOOGLE_DRIVE` | Links de pastas compartilhadas | 620-660 |
| `SUPABASE_CALLS` | 100+ calls com dados enriquecidos (fallback) | 1130+ |
| `DEMO_MENTEES` | Dados de demonstracao caso Supabase falhe | fim do arquivo |

---

## 4. FLUXOS DE DADOS

### 4.1 Carregamento do Dashboard

```
1. Usuario abre localhost:8888
2. Digita senha "spalla2026"
3. app.js inicializa Supabase client (SDK JS)
4. Carrega em paralelo:
   ├── vw_god_overview → cards dos 37 mentorados
   ├── vw_god_cohort → KPIs por fase
   ├── fn_god_alerts → alertas ativos
   └── vw_god_calls → cache de calls (pra enrichment)
5. Enriquece cada mentorado com:
   ├── dias_desde_call (calculo temporal)
   ├── Foto do Instagram ou WhatsApp
   └── Status do dossie (de data.js)
6. Se Supabase falhou → usa DEMO_MENTEES de data.js
```

### 4.2 Detalhe de Mentorado

```
1. Usuario clica num card
2. Chama fn_god_mentorado_deep(id) → JSON com 9 secoes
3. Chama vw_god_calls filtrado por mentorado_id → historico de calls
4. Normaliza arrays do context_ia (gargalos, estrategias)
5. Carrega mensagens WhatsApp em background (Evolution API)
6. Exibe tabs: Resumo | Contexto IA | Tarefas | Calls | Docs | WhatsApp
```

### 4.3 Agendamento de Call

```
1. Usuario preenche formulario (mentorado, data, hora, tipo)
2. Frontend faz POST /api/schedule-call
3. server.py orquestra:
   ├── Zoom API → cria reuniao → join_url
   ├── Google Calendar → cria evento com link Zoom + attendees
   └── Supabase → insere na calls_mentoria
4. Retorna resultado das 3 operacoes
```

### 4.4 Tarefas (CRUD Bidirecional)

```
LEITURA:
  sb.from('vw_god_tasks_full').select('*') → tarefas com subtasks/comments

ESCRITA:
  sb.from('god_tasks').upsert(task)           → cria/atualiza
  sb.from('god_task_subtasks').insert(...)     → sub-tarefas
  sb.from('god_task_comments').insert(...)     → comentarios
  sb.from('god_task_handoffs').insert(...)     → handoffs

FALLBACK:
  localStorage ('spalla_tasks') → sincroniza quando Supabase voltar
```

---

## 5. O QUE JA TA PRONTO

### Banco (Supabase)
- 12 tabelas populadas com dados reais
- 9 views SQL + 2 functions deployadas e validadas
- 7 indexes de performance criados
- Grants configurados (authenticated + anon)
- god_tasks com 800+ tarefas migradas
- SQL idempotente (`god_views_v2.sql`) — pode re-rodar sem quebrar

### Frontend (prototipo)
- 8 paginas funcionais com Alpine.js
- Integracao Supabase (leitura + escrita)
- Sistema de tarefas bidirecional (Kanban, List, Gantt)
- Filtros (fase, risco, cohort, status, financeiro)
- Busca global
- Fotos de perfil (Instagram + WhatsApp + fallback)
- WhatsApp chat integrado (Evolution API)
- Dossies com pipeline de status
- Lembretes (localStorage)
- Auth por senha

### Backend (server.py)
- Zoom meeting creation (Server-to-Server OAuth)
- Google Calendar event creation
- Supabase proxy (pra calls agendadas)
- Evolution API proxy (WhatsApp)
- Health check endpoint

---

## 6. O QUE FALTA PRA PRODUCAO

### Infraestrutura
- [ ] Subir server.py num servidor (Railway, Render, VPS, etc.)
- [ ] Configurar env vars (Zoom, Google SA, Supabase keys)
- [ ] HTTPS/SSL no dominio
- [ ] CI/CD (opcional, pode ser deploy manual)

### Backend (se reescrever)
- [ ] Migrar server.py pra framework adequado (FastAPI, Express, Next.js API routes)
- [ ] Autenticacao real (JWT, session, etc.) — hoje e so senha hardcoded
- [ ] Rate limiting nos endpoints
- [ ] Logs estruturados
- [ ] Error handling mais robusto

### Frontend (se reescrever)
- [ ] Migrar pra framework (Next.js, Nuxt, SvelteKit)
- [ ] Build/bundle otimizado (hoje sao arquivos brutos)
- [ ] Autenticacao com Supabase Auth (nao senha hardcoded)
- [ ] PWA / offline support (opcional)
- [ ] Responsive mobile

### Banco
- [ ] Nenhuma mudanca necessaria — ja ta deployado e funcionando
- [ ] Se quiser: materializar views pesadas (vw_god_timeline, vw_god_direcionamentos) pra performance

---

## 7. RESUMO DAS TABELAS E VIEWS — MAPA RAPIDO

```
TABELAS (dados brutos):
  mentorados ──────────────── 37 ativos (62 total, 20 tese + 5 inativos filtrados)
  calls_mentoria ───────────── 226 calls
  analises_call ────────────── ~260 analises IA
  interacoes_mentoria ──────── 23.840 msgs WhatsApp
  extracoes_agente ─────────── 505 outputs IA (5 agentes)
  documentos_plano_acao ────── 93 planos
  direcionamentos ──────────── 1.362 orientacoes Queila
  tarefas_acordadas ────────── 9 tarefas manuais
  tarefas_equipe ──────────── 264 tarefas delegadas
  marcos_mentorado ─────────── ~104 milestones
  travas_bloqueios ─────────── bloqueios recorrentes
  metricas_mentorado ──────── vendas/metricas
  god_tasks ────────────────── ~800 tarefas (CRUD bidirecional)
  god_task_subtasks ────────── sub-tarefas
  god_task_checklist ───────── checklists
  god_task_comments ─────────── comentarios
  god_task_handoffs ─────────── handoffs

VIEWS (dados consolidados, read-only):
  vw_god_overview ──────────── 37 rows, 24 colunas (cards)
  vw_god_tarefas ──────────── 804+ rows, 4 fontes unificadas
  vw_god_tasks_full ────────── ~800 rows, god_tasks + JSON aggregates
  vw_god_calls ────────────── 211 calls com analise IA
  vw_god_contexto_ia ──────── 37 rows, ultimo output IA
  vw_god_pendencias ────────── 413 msgs pendentes
  vw_god_direcionamentos ──── 1.673 direcionamentos
  vw_god_vendas ───────────── 37 rows, pipeline financeiro
  vw_god_timeline ─────────── ~2K eventos cronologicos
  vw_god_cohort ───────────── 5 rows, KPIs por fase

FUNCTIONS (RPC):
  fn_god_mentorado_deep(id) ── JSON completo com 9 secoes
  fn_god_alerts() ─────────── array de alertas priorizados
```

---

## 8. ARQUIVOS SQL — O Que Executar no Supabase

**Ja esta deployado**, mas se precisar recriar:

| Arquivo | O que faz | Ordem |
|---------|-----------|-------|
| `01_schema.sql` | Schema inicial (tabelas) | 1o |
| `02_update_mentorados.sql` | Updates de dados dos mentorados | 2o |
| `03_god_tasks_schema.sql` | Tabelas de tarefas bidirecionais | 3o |
| `god_views_v2.sql` | 9 views + 2 functions + 7 indexes + grants | 4o (por ultimo) |
| `FIX-IMEDIATO-16-02-2026.sql` | Correcoes pontuais (fases, desativacoes) | se necessario |

**Ordem importa:** as views referenciam as tabelas, entao criar tabelas primeiro.

O `god_views_v2.sql` e **idempotente** — tem `DROP VIEW IF EXISTS` e `DROP FUNCTION IF EXISTS` no inicio. Pode re-rodar sem medo.

---

## 9. APIs EXTERNAS — Resumo

### Zoom (Server-to-Server OAuth)

- **Tipo:** OAuth Server-to-Server (nao precisa login do usuario)
- **Token:** gerado automaticamente, cached por 1h
- **Uso:** criar reunioes com gravacao automatica na nuvem
- **Config:** env vars `ZOOM_ACCOUNT_ID`, `ZOOM_CLIENT_ID`, `ZOOM_CLIENT_SECRET`

### Google Calendar (Service Account)

- **Tipo:** Service Account com arquivo de credenciais JSON
- **Arquivo:** `~/.config/google/credentials.json`
- **Uso:** criar eventos, listar eventos futuros
- **Timezone:** America/Sao_Paulo
- **Lembretes:** 30min popup + 60min email

### Evolution API (WhatsApp)

- **Base URL:** `https://evolution.manager01.feynmanproject.com`
- **Instancia:** `produ02`
- **API Key:** `07826A779A5C-4E9C-A978-DBCD5F9E4C97`
- **Uso:** buscar chats (`/chat/findChats`), buscar mensagens, fotos de perfil
- **Proxy:** o server.py repassa tudo que vier em `/api/evolution/*` direto pra Evolution API

---

## 10. VALIDACAO — Pra Conferir Se Tudo Ta Funcionando

### No Supabase (SQL Editor)

```sql
SELECT COUNT(*) FROM vw_god_overview WHERE nome IS NOT NULL;  -- deve dar 37
SELECT COUNT(*) FROM vw_god_tarefas;                          -- deve dar > 100
SELECT COUNT(*) FROM vw_god_calls;                            -- deve dar > 200
SELECT COUNT(*) FROM vw_god_tasks_full;                       -- deve dar > 800
SELECT * FROM vw_god_cohort;                                  -- 5 rows (fases)
SELECT fn_god_mentorado_deep(13);                             -- JSON da Livia Lyra
SELECT * FROM fn_god_alerts() LIMIT 20;                       -- alertas
```

### No Browser

1. Abrir `http://localhost:8888`
2. Digitar `spalla2026`
3. Dashboard deve carregar 37 cards
4. Clicar num card deve abrir detalhe com tabs
5. Tarefas deve mostrar board Kanban
6. Agenda deve permitir agendar call

### No Terminal

```bash
curl http://localhost:8888/api/health
# {"status": "ok", "zoom_configured": true, "gcal_configured": true, "supabase_configured": true}
```

---

## Documentacao Complementar

| Arquivo | O que tem |
|---------|----------|
| `DOCUMENTACAO-SPALLA-V2.md` | Doc tecnica: todas as 17 tabelas com colunas, tipos, exemplos |
| `MERMAID-God-Views-V2.md` | Flowchart visual do sistema completo (cole no mermaid.live) |
| `SPALLA-V2-SPEC.md` | Especificacao das views com mapeamento view → componente |
| `god_views_v2.sql` | SQL completo das views + functions (pode re-rodar) |
| `03_god_tasks_schema.sql` | Schema do sistema de tarefas bidirecional |
