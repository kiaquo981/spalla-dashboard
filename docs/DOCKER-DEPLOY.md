# 🐳 Spalla Server — Deploy Docker

## 📋 Pré-requisitos
- Docker instalado em Manager01
- Docker Compose instalado
- Acesso SSH a Manager01 (178.156.251.146)

---

## 🚀 Passo 1: Build & Push para Docker Hub

### No seu computador local:

```bash
cd /Users/kaiquerodrigues/code/spalla-dashboard

# 1. Login no Docker Hub
docker login

# 2. Build da imagem
docker build -t seu-usuario/spalla-server:latest .

# 3. Push para Docker Hub
docker push seu-usuario/spalla-server:latest
```

**Ou use um Registry privado:**
```bash
docker tag spalla-server:latest manager01.juridicomarinho.com.br:5000/spalla-server:latest
docker push manager01.juridicomarinho.com.br:5000/spalla-server:latest
```

---

## 🚀 Passo 2: Deploy em Manager01

### SSH para Manager01:
```bash
ssh root@178.156.251.146
```

### Crie a pasta do projeto:
```bash
mkdir -p /apps/spalla-server
cd /apps/spalla-server
```

### Copie o docker-compose.yml e .env:
```bash
# Opção 1: Copiar via SCP (do seu computador local)
scp /Users/kaiquerodrigues/code/spalla-dashboard/docker-compose.yml root@178.156.251.146:/apps/spalla-server/
scp /Users/kaiquerodrigues/code/spalla-dashboard/.env.production root@178.156.251.146:/apps/spalla-server/.env
```

### Ou crie manualmente no Manager01:
```bash
cat > /apps/spalla-server/docker-compose.yml << 'EOF'
version: '3.8'
services:
  spalla-server:
    image: seu-usuario/spalla-server:latest  # Mude para sua imagem
    container_name: spalla-server
    ports:
      - "9999:9999"
    environment:
      PORT: 9999
      ZOOM_ACCOUNT_ID: DXq-KNA5QuSpcjG6UeUs0Q
      ZOOM_CLIENT_ID: fvNVWKX_SumngWI1kQNhg
      ZOOM_CLIENT_SECRET: zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g
      SUPABASE_ANON_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtudXNxZmJ2aHNxd29yenlodmlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4NTg3MjcsImV4cCI6MjA3MDQzNDcyN30.f-m7TlmCoccBpUxLZhA4P5kr2lWBGtRIv6inzInAKCo
      SUPABASE_SERVICE_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtudXNxZmJ2aHNxd29yenlodmlwIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDg1ODcyNywiZXhwIjoyMDcwNDM0NzI3fQ.0n5eh94NQ1flgXzQQoKtnNkTxJAYztqKxwNKnHyq6dM
      EVOLUTION_API_KEY: 07826A779A5C-4E9C-A978-DBCD5F9E4C97
    restart: unless-stopped
    networks:
      - spalla-network

networks:
  spalla-network:
    driver: bridge
EOF
```

### Inicie o container:
```bash
cd /apps/spalla-server
docker compose up -d

# Verifique se está rodando
docker compose logs -f spalla-server
```

### Teste o servidor:
```bash
# Do Manager01
curl http://localhost:9999/api/health

# Resultado esperado:
# {"status": "ok", "zoom_configured": true, "supabase_configured": true, ...}
```

---

## 🔗 Passo 3: Configurar Reverse Proxy (Caddy)

Se você já tem Caddy rodando, adicione a configuração:

```bash
# Edite /etc/caddy/Caddyfile
nano /etc/caddy/Caddyfile
```

Adicione:
```caddy
spalla-api.juridicomarinho.com.br {
    reverse_proxy localhost:9999
}
```

Reload Caddy:
```bash
caddy reload --config /etc/caddy/Caddyfile
```

---

## 🌐 Passo 4: Atualizar Frontend (Vercel)

### Opção A: Variável de ambiente no Vercel
1. Vá para projeto no Vercel Dashboard
2. Settings → Environment Variables
3. Adicione:
   ```
   NEXT_PUBLIC_SPALLA_API_BASE=https://spalla-api.juridicomarinho.com.br
   ```
4. Redeploy

### Opção B: Atualizar arquivo `11-APP-app.js` (local)

Abra `11-APP-app.js` e mude:
```javascript
// Antigo:
const API_BASE = '';  // ou null

// Novo:
const API_BASE = 'https://spalla-api.juridicomarinho.com.br';
```

Depois atualize todas as requisições:
```javascript
// Antigo:
fetch('/api/evolution/chat/findChats/produ02')

// Novo:
fetch(`${API_BASE}/api/evolution/chat/findChats/produ02`)
```

---

## ✅ Verificação Final

### 1. Health Check
```bash
curl https://spalla-api.juridicomarinho.com.br/api/health
```

### 2. Evolution API
```bash
curl -X POST https://spalla-api.juridicomarinho.com.br/api/evolution/chat/findChats/produ02 \
  -H "Content-Type: application/json" \
  -d '{"apikey":"07826A779A5C-4E9C-A978-DBCD5F9E4C97"}'
```

### 3. No navegador (Vercel)
- Abra https://spalla-dashboard.vercel.app
- Abra DevTools (F12) → Console
- Procure por `[Spalla]` logs
- Verifique se Evolution API está respondendo (sem 405 errors)

---

## 🔧 Comandos Úteis

```bash
# Ver logs
docker compose logs -f spalla-server

# Reiniciar
docker compose restart spalla-server

# Parar
docker compose down

# Atualizar para nova imagem
docker compose pull
docker compose up -d

# Acessar container
docker exec -it spalla-server bash
```

---

## 📝 Notas

- **Port 9999:** Padrão do servidor. Mude em docker-compose.yml se necessário
- **Healthcheck:** Dockerfile tem healthcheck automático
- **Restart Policy:** `unless-stopped` = reinicia se cair
- **Supabase 503:** Quando voltar, calls e dados vão carregar automaticamente
- **CORS:** Server envia `Access-Control-Allow-Origin: *`

---

**Status:** ✅ Pronto para deploy. Execute os passos acima em sequência.
