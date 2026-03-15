# Spalla Dashboard Server — Deploy Instructions

## Local Testing (Already Running)
- **Port:** 9876
- **Status:** ✅ Running and tested
- **Command:** `python3 14-APP-server.py 9876`

## Production Deploy to Manager01

### Option 1: Manual SSH Deploy
```bash
# 1. Copy server to Manager01
scp -r /Users/kaiquerodrigues/code/spalla-dashboard/14-APP-server.py root@178.156.251.146:/app/spalla/

# 2. SSH into Manager01 and start the server
ssh root@178.156.251.146
cd /app/spalla
python3 14-APP-server.py 9999 &  # Run on port 9999

# 3. Verify it's running
curl http://localhost:9999/api/health
```

### Option 2: Docker Deploy (Recommended)
```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY 14-APP-server.py .

ENV PORT=9999
EXPOSE 9999

CMD ["python3", "14-APP-server.py", "9999"]
```

## Frontend Configuration

### Update Vercel Environment Variable
Add to Vercel project settings:
```
NEXT_PUBLIC_SPALLA_API_BASE=https://manager01.juridicomarinho.com.br:9999
```

Or hardcode in `11-APP-app.js`:
```javascript
const API_BASE = 'https://manager01.juridicomarinho.com.br:9999';
// Instead of: fetch('/api/evolution/...')
// Use: fetch(`${API_BASE}/api/evolution/...`)
```

## Reverse Proxy Setup (Caddy on Manager01)
```caddy
spalla-api.juridicomarinho.com.br {
    reverse_proxy localhost:9999
}
```

## API Health Check
```bash
curl https://manager01.juridicomarinho.com.br:9999/api/health
# Response: {"status": "ok", "zoom_configured": true, ...}
```

---
**Server is ready for production deploy. Choose your option above.**
