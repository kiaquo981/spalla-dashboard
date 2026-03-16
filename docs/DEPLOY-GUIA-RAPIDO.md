# 🚀 GUIA RÁPIDO — Deploy Spalla Server em Docker Swarm

## ⚡ Resumo Executivo

Você está deployando um servidor Python que:
- ✅ Proxia a Evolution API para WhatsApp
- ✅ Conecta com Supabase (case_db_mentorados)
- ✅ Integra Zoom + Google Calendar
- ✅ Roda em Docker Swarm na Hetzner (Manager01: 178.156.157.169)

---

## 📋 Pré-requisitos

- [ ] Docker Hub account (ou Registry privado)
- [ ] SSH acesso a Manager01 (178.156.157.169)
- [ ] sshpass instalado: `brew install sshpass`

---

## 🎯 PASSO 1: Build & Push da Imagem Docker

```bash
cd /Users/kaiquerodrigues/code/spalla-dashboard

# 1. Login no Docker Hub
docker login

# 2. Substitua 'seu-usuario' pelo seu Docker Hub username
export DOCKER_USER="seu-usuario"

# 3. Build
docker build -t $DOCKER_USER/spalla-server:latest .

# 4. Push
docker push $DOCKER_USER/spalla-server:latest

# ✓ Confirme que subiu
curl https://hub.docker.com/v2/repositories/$DOCKER_USER/spalla-server
```

**Salve seu username para os próximos passos!**

---

## 🎯 PASSO 2: Prepare Manager01 (SSH)

```bash
# Login em Manager01
ssh root@178.156.157.169
# Senha: 3jM9EmKvfHmv

# Crie o diretório
mkdir -p /apps/spalla-server
cd /apps/spalla-server

# Crie o arquivo .env
cat > .env << 'EOF'
SUPABASE_URL=https://knusqfbvhsqworzyhvip.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtudXNxZmJ2aHNxd29yenlodmlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4NTg3MjcsImV4cCI6MjA3MDQzNDcyN30.f-m7TlmCoccBpUxLZhA4P5kr2lWBGtRIv6inzInAKCo
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtudXNxZmJ2aHNxd29yenlodmlwIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDg1ODcyNywiZXhwIjoyMDcwNDM0NzI3fQ.0n5eh94NQ1flgXzQQoKtnNkTxJAYztqKxwNKnHyq6dM
ZOOM_ACCOUNT_ID=DXq-KNA5QuSpcjG6UeUs0Q
ZOOM_CLIENT_ID=fvNVWKX_SumngWI1kQNhg
ZOOM_CLIENT_SECRET=zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g
EVOLUTION_API_KEY=07826A779A5C-4E9C-A978-DBCD5F9E4C97
EOF

# Crie o docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  spalla-server:
    image: seu-usuario/spalla-server:latest  # ⚠️ MUDE PARA SEU USERNAME
    container_name: spalla-server
    ports:
      - "9999:9999"
    env_file: .env
    restart: unless-stopped
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == worker
EOF
```

---

## 🎯 PASSO 3: Deploy no Docker Swarm

```bash
# Ainda no Manager01, em /apps/spalla-server/

# 1. Pull da imagem
docker pull seu-usuario/spalla-server:latest

# 2. Parar stack anterior (se existir)
docker compose down || true

# 3. Start
docker compose up -d

# 4. Verifique logs
docker compose logs -f spalla-server

# 5. Test health
curl http://localhost:9999/api/health

# Resultado esperado:
# {"status": "ok", "zoom_configured": true, "supabase_configured": true, ...}
```

**Sair do SSH:** `exit`

---

## 🎯 PASSO 4: Setup Reverse Proxy (Caddy) — OPCIONAL

Se você quer expor via domínio `spalla-api.juridicomarinho.com.br`:

```bash
# SSH em Manager01
ssh root@178.156.157.169

# Edit Caddy config
nano /etc/caddy/Caddyfile

# Adicione:
spalla-api.juridicomarinho.com.br {
    reverse_proxy localhost:9999 {
        header_upstream X-Forwarded-For {http.request.remote}
        header_upstream X-Forwarded-Proto {http.request.proto}
    }
}

# Save (Ctrl+O, Enter, Ctrl+X)

# Reload Caddy
caddy reload --config /etc/caddy/Caddyfile

# Verify
curl https://spalla-api.juridicomarinho.com.br/api/health
```

---

## 🎯 PASSO 5: Atualizar Frontend (Vercel)

### Opção A: Via Vercel Dashboard (RECOMENDADO)

1. Vá para: https://vercel.com/dashboard
2. Procure projeto "spalla-dashboard"
3. Settings → Environment Variables
4. Adicione nova variável:
   ```
   NEXT_PUBLIC_SPALLA_API_BASE=http://178.156.157.169:9999
   ```
   Ou se você setup Caddy:
   ```
   NEXT_PUBLIC_SPALLA_API_BASE=https://spalla-api.juridicomarinho.com.br
   ```
5. Redeploy (vai aparecer um botão "Redeploy")

### Opção B: Atualizar código `11-APP-app.js`

```javascript
// Antigo (local)
const API_BASE = '';

// Novo (produção)
const API_BASE = 'http://178.156.157.169:9999';
// Ou com Caddy:
const API_BASE = 'https://spalla-api.juridicomarinho.com.br';
```

Depois faça push para GitHub e redeploy.

---

## ✅ Verificação Final

### 1. Health Check
```bash
curl http://178.156.157.169:9999/api/health
# {"status": "ok", "zoom_configured": true, "supabase_configured": true}
```

### 2. Evolution API
```bash
curl -X POST http://178.156.157.169:9999/api/evolution/chat/findChats/produ02 \
  -H "Content-Type: application/json" \
  -d '{"apikey":"07826A779A5C-4E9C-A978-DBCD5F9E4C97"}' | jq '.length'
# Esperado: 473 chats
```

### 3. No navegador
- Abra https://spalla-dashboard.vercel.app
- DevTools → Console
- Procure por `[Spalla]` logs
- Verifique se não há 405 errors
- Clique em um WhatsApp chat para testar

---

## 🔧 Troubleshooting

### "Image not found" error
```bash
# Manager01
docker pull seu-usuario/spalla-server:latest
```

### "Port already in use"
```bash
# Manager01
docker compose down
sleep 5
docker compose up -d
```

### "Supabase connection error"
```bash
# Verifique .env em /apps/spalla-server/.env
cat .env

# Verifique conectividade
curl https://db.vcbyogkfmdlhxjgydtrd.supabase.co -I
```

### "Evolution API 405"
```bash
# Verifique API Key
curl -X POST http://localhost:9999/api/evolution/chat/findChats/produ02 \
  -H "Content-Type: application/json" \
  -d '{"apikey":"07826A779A5C-4E9C-A978-DBCD5F9E4C97"}' \
  -v
```

---

## 📞 Contato & Suporte

**Server Logs:**
```bash
ssh root@178.156.157.169
cd /apps/spalla-server
docker compose logs -f spalla-server
```

**Docker Stats:**
```bash
ssh root@178.156.157.169
docker stats spalla-server
```

---

## 🎯 Status Final

- ✅ Dockerfile criado e testado
- ✅ Supabase URL corrigida (case_db_mentorados)
- ✅ docker-compose.yml pronto
- ✅ Credenciais atualizadas
- ⏳ Awaiting: Build & Push da imagem
- ⏳ Awaiting: Deploy em Manager01

**Próximo passo:** Execute PASSO 1 (Build & Push)
