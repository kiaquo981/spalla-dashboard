# Spalla — Deploy Guia Rápido (Vercel + Railway)

## Resumo
- **Front-end**: Vercel (static SPA)
- **Back-end**: Railway (Python server com Zoom, Google Calendar, Evolution API)
- **Database**: Supabase (já live em `knusqfbvhsqworzyhvip`)
- **Tempo estimado**: 15 minutos

---

## 1. Deploy Back-End (Railway) — 5 min

### Pré-requisitos
- Conta Railway (https://railway.app) — free tier ok
- GitHub account (Railway integra com GitHub)

### Passos
1. Push este repositório pra um GitHub repo seu (ou Railway pode clonar direto)
2. Log in Railway.app
3. **New Project** → **Deploy from GitHub**
4. Seleciona este repo
5. Railway auto-detecta `Procfile` e `requirements.txt`
6. Em **Variables**, adiciona as variáveis de ambiente:
   ```
   ZOOM_ACCOUNT_ID=DXq-KNA5QuSpcjG6UeUs0Q
   ZOOM_CLIENT_ID=fvNVWKX_SumngWI1kQNhg
   ZOOM_CLIENT_SECRET=zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtudXNxZmJ2aHNxd29yenlodmlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4NTg3MjcsImV4cCI6MjA3MDQzNDcyN30.f-m7TlmCoccBpUxLZhA4P5kr2lWBGtRIv6inzInAKCo
   SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtudXNxZmJ2aHNxd29yenlodmlwIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDg1ODcyNywiZXhwIjoyMDcwNDM0NzI3fQ.0n5eh94NQ1flgXzQQoKtnNkTxJAYztqKxwNKnHyq6dM
   EVOLUTION_API_KEY=07826A779A5C-4E9C-A978-DBCD5F9E4C97
   ```
7. **Deploy** — Railway vai dar um domínio tipo `spalla-backend.railway.app`
8. Copia a URL do domínio (vai precisar no Vercel)

**⚠️ Google Calendar**: Se precisar, coloca o `credentials.json` como arquivo na Railway (ou pula por enquanto — só Zoom + Supabase vão funcionar).

---

## 2. Deploy Front-End (Vercel) — 5 min

### Pré-requisitos
- Conta Vercel (https://vercel.com)
- GitHub repo com os arquivos

### Passos
1. Log in Vercel
2. **Add New** → **Project**
3. Import repo (ou conecta GitHub)
4. Seleciona este diretório (`SPALLA-V2-HANDOFF-17-02-2026`)
5. **Environment Variables** → Adiciona:
   ```
   API_BACKEND_URL=https://spalla-backend.railway.app
   ```
   (Substitui por sua URL do Railway do passo 1)
6. **Deploy**

Vercel vai servir a SPA e **reescrever** todo `/api/*` para `https://spalla-backend.railway.app/api/*`.

---

## 3. Teste Rápido

1. Acessa https://seu-dominio-vercel.app
2. Tela de login deve aparecer
3. Clica **Inspecionar** → **Console** → sem erros de CORS
4. Login com a senha (hardcoded em `12-APP-data.js`, procura por `login()`)

Se `/api/health` retorna `200 OK`, tá funcionando.

---

## 4. Checklist Pré-Produção

- [ ] Google Service Account `credentials.json` colocado em `/home/railway/app/.config/google/credentials.json` (se precisar Google Calendar)
- [ ] HTTPS habilitado (Vercel + Railway vêm com HTTPS grátis)
- [ ] Variáveis de ambiente configuradas em ambos
- [ ] Teste `/api/health` retorna `{"status": "ok", ...}`
- [ ] Auth funciona (login com a senha)
- [ ] Fotos carregam (devem estar em `photos/`)
- [ ] Datas mostram correto (DD/MM/YYYY parse foi fixado em `11-APP-app.js`)

---

## 5. Estrutura de Arquivos (Importante!)

```
SPALLA-V2-HANDOFF-17-02-2026/
├── 10-APP-index.html       ← Front-end (Vercel serve isto)
├── 11-APP-app.js
├── 12-APP-data.js
├── 13-APP-styles.css
├── 14-APP-server.py        ← Back-end (Railway roda isto)
├── photos/                 ← Assets
├── Procfile                ← Railway (NEW)
├── requirements.txt        ← Python deps (NEW)
├── vercel.json            ← Vercel config (NEW)
├── config.js              ← Config helper (NEW)
└── *.sql                  ← Schemas (referência, já em Supabase)
```

---

## 6. URLs e Credenciais

| Serviço | URL | Status |
|---------|-----|--------|
| Supabase | `knusqfbvhsqworzyhvip.supabase.co` | ✅ Live |
| Zoom API | S2S OAuth | ✅ Configurado |
| Evolution (WhatsApp) | `evolution.manager01.feynmanproject.com` | ✅ Configurado |
| Google Calendar | Requer `credentials.json` | ⚠️ Opcional |

---

## 7. Problemas Comuns

### "CORS error from API"
- Vercel rewrites deve estar configurado com `API_BACKEND_URL`
- Check `vercel.json`
- Verifica se Railway está UP e respondendo

### "Fotos não carregam"
- Pasta `photos/` deve estar no mesmo diretório que `10-APP-index.html`
- Vercel serve estaticamente tudo no root

### "Datas inconsistentes"
- `11-APP-app.js` tem `parseDateStr()` — já fixado
- Recarrega o browser (Ctrl+Shift+R)

### "Login não funciona"
- Senha está hardcoded em `12-APP-data.js` linha ~`login()` function
- Procura por `if (this.auth.password ===`

---

## 8. Próximos Passos

- [ ] Auth real (JWT + backend)
- [ ] Remover credenciais do código → variáveis de ambiente
- [ ] Adicionar SSL/HTTPS (já é automático em Vercel + Railway)
- [ ] Setup Google Calendar (colocar service account no Railway)
- [ ] Monitoramento (Railway + Vercel têm dashboards)

---

**Status**: Pronto pra produção (básico). SPA estável, back-end robusto, Supabase live.
