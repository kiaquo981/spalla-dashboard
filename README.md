# Spalla Dashboard

Dashboard de gestão de mentorados da CASE.

## Arquitetura

```
Vercel (Frontend)          Hetzner manager01 (Backend)       Supabase (DB)
app/frontend/        →     app/backend/                 →    PostgreSQL
HTML + Alpine.js           Python Flask API :9999            RLS policies
                           Docker container                  Edge Functions
```

## Estrutura do Repo

```
spalla-dashboard/
├── app/
│   ├── frontend/       ← HTML, JS, CSS (servido pela Vercel)
│   └── backend/        ← Python API (roda no Hetzner via Docker)
├── sql/
│   └── migrations/     ← SQL files (já executados no Supabase)
├── integrations/
│   ├── n8n/            ← N8N workflow JSONs
│   └── supabase/       ← Edge Functions
├── deploy/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── vercel.json
│   └── Procfile
├── docs/               ← Documentação técnica
├── .github/
│   └── workflows/      ← CI pipeline
├── .env.example        ← Variáveis de ambiente (copiar pra .env)
└── README.md
```

## Setup Local

```bash
# 1. Clone
gh repo clone case-company/spalla-dashboard
cd spalla-dashboard

# 2. Copiar env vars
cp .env.example .env
# Preencher com valores reais

# 3. Backend (Python)
cd app/backend
pip install -r requirements-railway.txt
python 14-APP-server.py 9999

# 4. Frontend
# Abrir app/frontend/10-APP-index.html no browser
# Ou usar live-server: npx live-server app/frontend
```

## Workflow

```
1. git checkout develop && git pull
2. git checkout -b feature/minha-feature
3. (fazer mudanças)
4. git commit -m "feat(dashboard): descrição"
5. git push origin feature/minha-feature
6. gh pr create --base develop
7. CI testa → CodeRabbit revisa → merge
```

## Links

- [PRs](https://github.com/case-company/spalla-dashboard/pulls)
- [CI](https://github.com/case-company/spalla-dashboard/actions)
