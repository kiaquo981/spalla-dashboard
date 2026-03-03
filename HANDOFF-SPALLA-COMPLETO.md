# 🎯 SPALLA Dashboard — Handoff Completo

**Data:** 03 de Março de 2026
**Status:** Production-Ready (v2 funcional)
**Responsável Original:** Kaique Rodrigues (@kaiquerodrigues)

---

## 📋 Sumário Executivo

**Spalla** é um dashboard de gestão de mentorados CASE, desenvolvido em vanilla HTML/CSS/JS com Alpine.js no frontend e Python Flask no backend. Integra:
- ✅ Supabase (dados em tempo real)
- ✅ WhatsApp (Evolution API)
- ✅ Instagram (Apify scraper)
- ✅ Zoom + Google Calendar (agendamento de calls)
- ✅ Google Drive (documentos e dossiers)
- ✅ Hetzner S3 (armazenamento de mídias)

**Deploy:** Vercel (frontend) + Railway (backend)
**Repo:** https://github.com/kiaquo981/spalla-dashboard

---

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                    VERCEL (Frontend)                        │
│  10-APP-index.html | 11-APP-app.js | 12-APP-data.js        │
│  13-APP-styles.css | 13-APP-photos.js | config.local.js    │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTPS
┌──────────────────────────┴──────────────────────────────────┐
│                  RAILWAY (Backend Python)                   │
│           14-APP-server.py (Flask + Supabase)              │
│  - Zoom meeting creation                                   │
│  - Google Calendar events                                  │
│  - S3 presigned URLs                                       │
└──────────────────────────┬──────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
    ┌───▼────┐        ┌────▼───┐        ┌───▼────┐
    │Supabase│        │Zoom    │        │Google  │
    │        │        │API     │        │Calendar│
    └────────┘        └────────┘        └────────┘
        │
    ┌───▼────────────────────────────┐
    │Evolution API (WhatsApp)        │
    │Apify (Instagram Scraper)       │
    │Hetzner S3 (Media Storage)      │
    └────────────────────────────────┘
```

---

## 🔧 Stack Técnico

| Camada | Tecnologia | Versão | Notas |
|--------|-----------|--------|-------|
| Frontend | Alpine.js | 3.14.8 | Reatividade sem build |
| Frontend | Supabase JS | v2 | Client async |
| CSS | Vanilla CSS | - | Estilos em 13-APP-styles.css |
| Backend | Python Flask | 3.11 | Railway runtime |
| Database | Supabase PostgreSQL | - | Real-time subscriptions |
| Auth | Token simples | - | PASSWORD: `spalla2026` |
| Deploy | Vercel | - | Auto-deploy on push |
| Deploy | Railway | - | Auto-deploy on push |

---

## 📁 Estrutura de Arquivos

```
spalla-dashboard/
├── 10-APP-index.html          # UI HTML (1700+ linhas)
├── 11-APP-app.js              # Lógica Alpine.js (2000+ linhas)
├── 12-APP-data.js             # Dados estáticos
├── 13-APP-styles.css          # Estilos (126KB)
├── 13-APP-photos.js           # Base64 photos (335KB)
├── 14-APP-server.py           # Backend Flask (Railway)
├── config.local.js            # Apify API key (NÃO commitar)
├── .env                        # Environment variables (NÃO commitar)
├── styles.css → 13-APP-styles.css  # Symlink
├── .gitignore                 # Inclui config.local.js
└── HANDOFF-SPALLA-COMPLETO.md # Este arquivo
```

---

## 🚀 Como Fazer Deploy

### 1. Vercel (Frontend)

**Deployment Automático:** Qualquer push para `main` dispara auto-deploy
```bash
git push origin main
```

**URL:** https://spalla-dashboard-gilt.vercel.app

### 2. Railway (Backend)

**Deployment Automático:** Qualquer push para `main` dispara auto-deploy
```bash
git push origin main
```

**URL:** https://web-production-2cde5.up.railway.app

---

## 🔐 Variáveis de Ambiente

> **⚠️ IMPORTANTE:** Todas as chaves são mantidas em `.env.production` (não commitado) e nas configurações do Vercel/Railway. NÃO adicione credenciais em arquivos versionados.

### Vercel Settings → Environment Variables
- `API_BASE_URL` — Base URL do backend (Railway)
- `APIFY_API_KEY` — Chave da API Apify
- `SUPABASE_URL` — URL do Supabase
- `SUPABASE_ANON_KEY` — Chave pública do Supabase

### Railway Variables
- Todas as chaves acima
- `ZOOM_*` — Credenciais do Zoom
- `EVOLUTION_API_*` — Credenciais Evolution/WhatsApp
- `S3_*` — Credenciais Hetzner S3
- `POSTGRESQL_*` — Conexão com banco

**Para obter credenciais:** Contact Kaique Rodrigues

---

## 📊 Banco de Dados (Supabase)

### Tabelas Principais

#### `mentorados`
Armazena perfil, engagement, financeiro de cada mentorado

#### `god_tasks`
Tarefas atribuídas aos mentorados ou equipe

#### `calls_mentoria`
Histórico e agendamento de calls com links do Zoom/Calendar

#### `dossier_pipeline`
Status dos dossiês em cada estágio (enviado, revisão, etc)

---

## 🔗 APIs e Integrações

### Evolution API (WhatsApp)
- Fetch mensagens em tempo real
- Mídias salvam em S3
- Baseado em webhooks

### Apify (Instagram)
- Scraping de follower counts
- Rate-limited (10 calls/min)
- Cacheado em memória

### Zoom API
- Criar meetings
- Endpoint: `/api/zoom/create-meeting`

### Google Calendar API
- Criar eventos
- Endpoint: `/api/calendar/create-event`

### Hetzner S3
- Armazenar mídias WhatsApp
- Presigned URLs para download seguro

---

## ✅ Funcionalidades Implementadas

- [x] Dashboard com KPIs e filtros
- [x] Detail page com 8 abas
- [x] Tarefas com modal, subtasks, checklist
- [x] WhatsApp real-time com mídias
- [x] Agendamento de calls (Zoom + Calendar)
- [x] Pipeline visual de dossiers
- [x] Instagram integration (Apify)
- [x] Profile photos (base64)
- [x] Responsive design

### Parcialmente Implementadas
- [ ] Lembretes (Reminders)
- [ ] Relatórios PDF

---

## 🐛 Bugs Corrigidos Recentemente

1. **Task Modal Invisível** → Movido para fora de page containers
2. **Handoffs Crashes** → Adicionado safe navigation
3. **Apify Key Config** → Criado `config.local.js`
4. **Dossier Status Display** → Adicionado ao config

---

## 🔍 Como Debugar

```javascript
// Browser console
console.log(sb)                    // Supabase client
console.log(spalla_app.data.mentees) // Dados carregados
console.log(APIFY_CONFIG)          // Apify setup

// Testar API
fetch('https://web-production-2cde5.up.railway.app/health')
  .then(r => r.json())
  .then(d => console.log(d))
```

---

## 📝 Quick Start para Desenvolvedores

```bash
# 1. Clone
git clone https://github.com/kiaquo981/spalla-dashboard.git
cd spalla-dashboard

# 2. Local development
python3 -m http.server 8000

# 3. Faça mudanças
# 4. Commit + push
git add .
git commit -m "Feature: description"
git push origin main

# 5. Vercel + Railway deployam automaticamente (~30s)
```

---

## 🎯 Próximos Passos

1. Migrar para OAuth2
2. Adicionar testes automatizados
3. Implementar relatórios PDF
4. Completar Lembretes
5. Documentação de API pública

---

## ✋ Handoff Pronto

Este documento cobre:
- ✅ Arquitetura
- ✅ Deploy (Vercel + Railway)
- ✅ Variáveis de ambiente
- ✅ Banco de dados
- ✅ APIs externas
- ✅ Debug guide
- ✅ Quick start

**Próximo dev pode:**
1. Clonar repo
2. Entender estrutura
3. Fazer alterações
4. Push = auto-deploy
5. Debugar com esta guia

**Bom trabalho! 🚀**
