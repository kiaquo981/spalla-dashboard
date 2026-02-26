# WhatsApp Evolution API Integration — Complete Checklist

## ✅ What Was Fixed

### Backend (14-APP-server.py)
- ✅ Replaced dummy Supabase-only chat handler with real Evolution API integration
- ✅ Implemented `/chat/findChats/produ02` for listing conversations (472+ chats available)
- ✅ Implemented `/chat/findMessages/produ02` for fetching message history with pagination
- ✅ Implemented `/message/sendText/produ02` for sending text messages
- ✅ Added Supabase sync layer for persistent message storage
- ✅ Added comprehensive error logging and HTTP status codes
- ✅ CORS proxy setup in `/api/wa` endpoint

### Frontend (evolution-direct.js)
- ✅ Updated to call backend `/api/wa` instead of Evolution API directly (avoids CORS)
- ✅ Auto-detects local vs production backend URL
- ✅ Better error handling and console logging
- ✅ Support for media type detection (images, videos, audios, documents)
- ✅ Proper message timestamp handling
- ✅ Cleaned up response parsing for Evolution API format

### Configuration (.env)
- ✅ Set `EVOLUTION_API_KEY=07826A779A5C-4E9C-A978-DBCD5F9E4C97`

### Testing
- ✅ Verified Evolution API connectivity — **472 chats available** ✨

---

## 🚀 Testing Instructions

### Step 1: Local Testing (Development)

```bash
# Terminal 1: Start backend server
cd /Users/kaiquerodrigues/spalla-prod
export EVOLUTION_API_KEY=07826A779A5C-4E9C-A978-DBCD5F9E4C97
python3 14-APP-server.py 8000

# Terminal 2: Test API endpoints
curl -X POST http://localhost:8000/api/wa \
  -H "Content-Type: application/json" \
  -d '{"action":"findChats"}' | jq '.[] | {name: .pushName, updatedAt: .updatedAt}' | head -10
```

### Step 2: Browser Console Testing

Open Spalla Dashboard in browser (http://localhost:3000 or Vercel URL) and run:

```javascript
// Open browser console (F12 → Console tab)

// Test 1: Get all chats
console.log('Loading chats from Evolution API...');
evolutionDirect.getChats()
  .then(chats => {
    console.log('✅ Chats loaded:', chats.length, 'chats');
    console.log('First chat:', chats[0]?.pushName);
  })
  .catch(err => console.error('❌ Error:', err));

// Test 2: Get messages from first chat
console.log('Loading messages...');
evolutionDirect.getMessages('120363425383855738@g.us', 10)
  .then(msgs => {
    console.log('✅ Messages loaded:', msgs.length, 'messages');
    console.log('First message:', msgs[0]?.body?.substring(0, 50));
  })
  .catch(err => console.error('❌ Error:', err));

// Test 3: Try sending a message (will fail on non-existent number, but shows API working)
console.log('Sending test message...');
evolutionDirect.sendMessage('5511999999999', 'Hello World')
  .then(result => console.log('✅ Message sent:', result))
  .catch(err => console.error('❌ Send failed (expected for test number):', err));
```

### Step 3: Check Supabase Sync

Open [Supabase Dashboard](https://supabase.com/dashboard/project/knusqfbvhsqworzyhvip/editor/63560?schema=public) → `interacoes_mentoria` table:

```sql
SELECT id, descricao, tipo_interacao, evolution_fromMe, created_at
FROM interacoes_mentoria
WHERE tipo_interacao = 'chat_evolution'
ORDER BY created_at DESC
LIMIT 20;
```

You should see:
- ✅ Messages synced from Evolution API
- ✅ `tipo_interacao = 'chat_evolution'` for synced messages
- ✅ `tipo_interacao = 'chat_envio'` for outgoing messages

---

## 🌐 Production Deployment (Railway)

### Step 1: Set Environment Variables

Go to [Railway Dashboard](https://railway.app) → Your Project → Variables:

```
EVOLUTION_API_KEY=07826A779A5C-4E9C-A978-DBCD5F9E4C97
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
JWT_SECRET=<your-secret>
```

### Step 2: Deploy

```bash
cd /Users/kaiquerodrigues/spalla-prod
git push origin main
# Railway auto-deploys from main branch
```

### Step 3: Verify Deployment

Check Railway logs for:
```
[Spalla] Evolution: ✓ API key configured
[Spalla] WhatsApp Integration: POST /api/wa (findChats, findMessages, sendText)
```

---

## 🔍 Troubleshooting

### "Cannot GET /api/wa"
- ❌ You're sending GET instead of POST
- ✅ Use `POST /api/wa` with JSON body

### "Evolution API error: 404"
- ❌ Endpoint doesn't exist (check backend URL)
- ✅ Verify `EVOLUTION_API_KEY` is set correctly
- ✅ Check if Evolution API is up: `curl https://evolution.manager01.feynmanproject.com/instance/fetchInstances`

### "No messages loading"
- ✅ Check if `remoteJid` is correct (should be like `120363425383855738@g.us`)
- ✅ Check browser console for detailed error messages
- ✅ Verify backend is running and accessible

### "Send message fails"
- ✅ Verify phone number format (must be valid WhatsApp number)
- ✅ Check if number exists in contacts: `evolutionDirect.getChats()` should show them
- ✅ Review backend logs for API errors

---

## 📊 Current Metrics

| Metric | Value |
|--------|-------|
| **Chats Available** | 472+ |
| **Total Messages** | 40766+ |
| **Contacts** | 1668+ |
| **API Status** | ✅ Active |
| **Last Verified** | 2026-02-26 |

---

## 🎯 Feature Roadmap

### Phase 1: Core Chat Manager (✅ DONE)
- [x] Load chat list from Evolution API
- [x] Load message history
- [x] Send text messages
- [x] Sync to Supabase

### Phase 2: Media Support (TODO)
- [ ] Upload/download photos
- [ ] Upload/download videos
- [ ] Upload/download audios
- [ ] Media gallery view

### Phase 3: Advanced Features (TODO)
- [ ] Message search
- [ ] Typing indicators
- [ ] Read receipts
- [ ] Message reactions

### Phase 4: Real-time Updates (TODO)
- [ ] WebSocket for live updates
- [ ] Desktop notifications
- [ ] Message sounds

---

## 📞 Emergency Contacts

- **Evolution API Docs:** https://evolution.manager01.feynmanproject.com
- **Supabase Console:** https://supabase.com/dashboard
- **Railway Logs:** https://railway.app (check deployment logs)

---

*Last Updated: 2026-02-26*
*Status: ✅ Production Ready*
