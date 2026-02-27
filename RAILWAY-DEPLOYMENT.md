# Railway Deployment Guide — Spalla Dashboard

## Overview

Spalla Dashboard runs on Railway with:
- **Backend:** Python 3.11 (HTTP server + API routes)
- **Frontend:** Static SPA (Alpine.js)
- **Port:** 8000 (configurable via PORT env var)

## Prerequisites

1. **Railway CLI** installed: `npm install -g @railway/cli`
2. **GitHub account** with repo access
3. **Environment variables** configured in Railway dashboard

## Step 1: Connect Repository

```bash
railway init
```

Select:
- GitHub repository: `kiaquo981/spalla-dashboard`
- Project name: `spalla-dashboard`

## Step 2: Configure Environment Variables

In Railway dashboard → Project → Variables, add:

### Required (CRITICAL)
- `SUPABASE_URL` → https://your-project.supabase.co
- `SUPABASE_ANON_KEY` → Your Supabase anonymous key
- `SUPABASE_SERVICE_KEY` → Your Supabase service key
- `JWT_SECRET` → Strong random string (min 32 chars)

### Optional (for Zoom integration)
- `ZOOM_ACCOUNT_ID` → Your Zoom account ID
- `ZOOM_CLIENT_ID` → Your Zoom OAuth client ID
- `ZOOM_CLIENT_SECRET` → Your Zoom OAuth client secret

### Optional (for WhatsApp/Evolution)
- `EVOLUTION_API_KEY` → Your Evolution API key

### Optional (for Google Calendar)
- `GOOGLE_CALENDAR_ID` → Calendar ID (default: primary)
- `GOOGLE_SA_CREDENTIALS_B64` → Base64-encoded service account JSON

## Step 3: Deploy

### Option A: Automatic Deployment (GitHub)
Push to main branch:
```bash
git push origin main
```

Railway automatically deploys on push.

### Option B: Manual Deployment
```bash
railway deploy
```

## Step 4: Verify Deployment

Check health endpoint:
```bash
curl https://<your-railway-url>/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2026-02-27T..."
}
```

## Step 5: View Logs

```bash
railway logs
```

## Troubleshooting

### Issue: Port already in use
**Solution:** Railway automatically assigns PORT. Check:
```bash
railway status
```

### Issue: Missing environment variables
**Solution:** Verify in Railway dashboard:
- Project → Variables → Check all required vars are set
- Redeploy after adding variables

### Issue: Python dependencies fail
**Solution:** Check requirements.txt includes all dependencies:
```bash
pip install -r requirements.txt
```

### Issue: Frontend not loading
**Solution:** Verify SPA routing in vercel.json is correct

## Health Checks

The backend includes automatic health checks:

**Endpoint:** `GET /health`

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2026-02-27T20:30:00Z",
  "checks": {
    "supabase": "✓",
    "jwt_configured": "✓",
    "evolution_instance": "✓"
  }
}
```

## Production Best Practices

1. **Never hardcode secrets** → Always use environment variables
2. **Monitor logs** → Check `railway logs` regularly
3. **Set up alerts** → Railway dashboard → Alerts
4. **Regular backups** → Export Supabase data weekly
5. **Rate limiting** → Enabled on all API endpoints

## Rolling Deploys

Railway supports zero-downtime deployments:
1. New container starts
2. Health checks pass
3. Old container shuts down
4. No downtime

## Database Connection

Supabase connection is managed via environment variables:
- URL: `SUPABASE_URL`
- Key: `SUPABASE_ANON_KEY`

Connections are pooled automatically.

## Support

- Railway Docs: https://docs.railway.app
- Spalla Issues: https://github.com/kiaquo981/spalla-dashboard/issues
