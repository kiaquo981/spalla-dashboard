#!/bin/bash
# 🐳 SPALLA SERVER — DOCKER SWARM DEPLOYMENT
# Deploy para Manager01 (178.156.157.169) no Docker Swarm da Hetzner

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          SPALLA SERVER — Docker Swarm Deploy                   ║"
echo "║                    Manager01 (Hetzner)                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Configuration
MANAGER_IP="178.156.157.169"
MANAGER_USER="root"
MANAGER_PASSWORD="3jM9EmKvfHmv"
MANAGER_PORT="22"
DEPLOY_PATH="/apps/spalla-server"
REGISTRY="seu-usuario/spalla-server"  # Mude para seu Docker Hub username
IMAGE_TAG="latest"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Build Docker Image
echo -e "${BLUE}[1/5]${NC} Building Docker image..."
docker build -t ${REGISTRY}:${IMAGE_TAG} .
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Image built successfully${NC}"
else
    echo -e "${RED}✗ Failed to build image${NC}"
    exit 1
fi
echo ""

# Step 2: Push to Docker Hub
echo -e "${BLUE}[2/5]${NC} Pushing image to Docker Hub..."
echo "Make sure you're logged in: docker login"
docker push ${REGISTRY}:${IMAGE_TAG}
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Image pushed successfully${NC}"
else
    echo -e "${RED}✗ Failed to push image${NC}"
    exit 1
fi
echo ""

# Step 3: Prepare deploy on Manager01
echo -e "${BLUE}[3/5]${NC} Connecting to Manager01 and preparing deployment..."

# Cria SSH command script (evita timeout)
cat > /tmp/deploy-commands.sh << 'DEPLOYEOF'
#!/bin/bash
set -e

DEPLOY_PATH="/apps/spalla-server"
REGISTRY="seu-usuario/spalla-server"
IMAGE_TAG="latest"

# Create deploy directory
mkdir -p $DEPLOY_PATH
cd $DEPLOY_PATH

# Create .env file
cat > .env << 'ENVEOF'
SUPABASE_URL=https://db.vcbyogkfmdlhxjgydtrd.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZjYnlvZ2tmbWRsaHhqZ3lkdHJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwOTQwMjksImV4cCI6MjA3OTY3MDAyOX0.BjxFuSAu0weFQHxq7M4yEN_0IApLf9zXqZXeSjwXTDw
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZjYnlvZ2tmbWRsaHhqZ3lkdHJkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5NDAyOSwiZXhwIjoyMDc5NjcwMDI5fQ.wgkaiJiRS7xvCI35hIjYrrYyDsKk-6nG6dLim8CGI6c
ZOOM_ACCOUNT_ID=DXq-KNA5QuSpcjG6UeUs0Q
ZOOM_CLIENT_ID=fvNVWKX_SumngWI1kQNhg
ZOOM_CLIENT_SECRET=zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g
EVOLUTION_API_KEY=07826A779A5C-4E9C-A978-DBCD5F9E4C97
ENVEOF

# Create docker-compose.yml for Swarm
cat > docker-compose.yml << 'COMPOSEEOF'
version: '3.8'

services:
  spalla-server:
    image: seu-usuario/spalla-server:latest
    ports:
      - "9999:9999"
    environment:
      PORT: 9999
      SUPABASE_URL: ${SUPABASE_URL}
      SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY}
      SUPABASE_SERVICE_KEY: ${SUPABASE_SERVICE_KEY}
      ZOOM_ACCOUNT_ID: ${ZOOM_ACCOUNT_ID}
      ZOOM_CLIENT_ID: ${ZOOM_CLIENT_ID}
      ZOOM_CLIENT_SECRET: ${ZOOM_CLIENT_SECRET}
      EVOLUTION_API_KEY: ${EVOLUTION_API_KEY}
    restart: unless-stopped
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == worker
COMPOSEEOF

echo "✓ Deploy files created"
echo "Path: $DEPLOY_PATH"
ls -la $DEPLOY_PATH

DEPLOYEOF

# Execute deploy commands on Manager01
sshpass -p "$MANAGER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$MANAGER_IP 'bash -s' < /tmp/deploy-commands.sh

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Deploy files prepared on Manager01${NC}"
else
    echo -e "${RED}✗ Failed to prepare deploy files${NC}"
    exit 1
fi
echo ""

# Step 4: Deploy Stack to Swarm
echo -e "${BLUE}[4/5]${NC} Deploying to Docker Swarm..."

sshpass -p "$MANAGER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$MANAGER_IP << SSHEOF
cd /apps/spalla-server
docker pull seu-usuario/spalla-server:latest
docker compose down || true
docker compose up -d
sleep 5
docker compose logs -n 50 spalla-server
SSHEOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Stack deployed successfully${NC}"
else
    echo -e "${RED}✗ Failed to deploy stack${NC}"
    exit 1
fi
echo ""

# Step 5: Health Check
echo -e "${BLUE}[5/5]${NC} Verifying deployment..."

HEALTH_CHECK=$(sshpass -p "$MANAGER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$MANAGER_IP "curl -s http://localhost:9999/api/health | jq '.status'" 2>/dev/null || echo "error")

if [ "$HEALTH_CHECK" == '"ok"' ]; then
    echo -e "${GREEN}✓ Health check passed!${NC}"
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                  DEPLOYMENT SUCCESSFUL! 🎉                     ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║ Server: http://178.156.157.169:9999                           ║"
    echo "║ Health: http://178.156.157.169:9999/api/health                ║"
    echo "║ Evolution API: http://178.156.157.169:9999/api/evolution/*    ║"
    echo "║                                                                ║"
    echo "║ Next Steps:                                                    ║"
    echo "║ 1. Setup Caddy reverse proxy (optional)                        ║"
    echo "║ 2. Update frontend .env with API base URL                     ║"
    echo "║ 3. Test WhatsApp integration                                  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
else
    echo -e "${RED}✗ Health check failed${NC}"
    echo "Check logs on Manager01: ssh root@178.156.157.169"
    echo "Then: cd /apps/spalla-server && docker compose logs -f"
    exit 1
fi

# Cleanup
rm -f /tmp/deploy-commands.sh
