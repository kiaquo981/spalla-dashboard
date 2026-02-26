# Evolution API Setup — WhatsApp Chat Manager Integration

## 📱 Architecture Overview

```
Spalla Frontend (Vercel)
        ↓ (CORS safe)
Railway Backend (Python 14-APP-server.py)
        ↓ (HTTP proxy)
Evolution API (produ02)
        ↓
WhatsApp Baileys
```

## ✅ Current Status

- **Evolution API Instance:** `produ02` (active)
- **API Key:** `07826A779A5C-4E9C-A978-DBCD5F9E4C97` (configured in `.env`)
- **Base URL:** `https://evolution.manager01.feynmanproject.com`
- **Data:** 774 chats, 1668 contacts, 40766 messages

## 🔗 API Endpoints

All calls go through the backend proxy at `/api/wa`:

### 1. Get Chats (List Conversations)
```
POST /api/wa
{
  "action": "findChats"
}

Returns:
[
  {
    "id": "cmlku1br266ibqw4j9iumz6ci",
    "remoteJid": "120363425383855738@g.us",
    "pushName": "Chat Name",
    "profilePicUrl": "https://...",
    "updatedAt": "2026-02-26T21:28:03.000Z",
    "unreadCount": 0
  }
]
```

### 2. Get Messages (Fetch Conversation History)
```
POST /api/wa
{
  "action": "findMessages",
  "remoteJid": "120363425383855738@g.us",
  "limit": 50
}

Returns:
[
  {
    "id": "cmm3z5xgm9x7bqw4jh7kbxvt1",
    "key": {
      "id": "3EB0DEF313D4B153E3ED4D",
      "fromMe": false,
      "remoteJid": "120363425383855738@g.us",
      "participant": "159059886006368@lid"
    },
    "message": {
      "conversation": "Hello!"
    },
    "messageTimestamp": 1772141283
  }
]
```

### 3. Send Message
```
POST /api/wa
{
  "action": "sendText",
  "number": "5511999999999",
  "text": "Hello, this is a test message!"
}

Returns:
{
  "status": "ok",
  "message_id": "...",
  ...
}
```

## 🧪 Testing

### Local Testing
```bash
# 1. Start the server
python3 14-APP-server.py 8000

# 2. Test endpoint
curl -X POST http://localhost:8000/api/wa \
  -H "Content-Type: application/json" \
  -d '{"action": "findChats"}'
```

### Frontend Testing (Browser Console)
```javascript
// Get all chats
evolutionDirect.getChats().then(chats => {
  console.log('Chats:', chats);
});

// Get messages from a chat
evolutionDirect.getMessages('120363425383855738@g.us', 50).then(msgs => {
  console.log('Messages:', msgs);
});

// Send a message (to test contact)
evolutionDirect.sendMessage('5511999999999', 'Test message').then(result => {
  console.log('Sent:', result);
});
```

## 📋 Features Implemented

✅ **Load Chats** — Real-time from Evolution API
✅ **Load Messages** — With pagination (limit 50)
✅ **Send Messages** — Text-based (plain text, no media yet)
✅ **Persistent Storage** — Auto-sync to Supabase `interacoes_mentoria`
✅ **Error Handling** — Detailed logging for debugging
✅ **CORS Proxy** — Backend handles CORS issues

## 🚀 Next Steps (For Full Chat Manager)

1. **Media Support** — Upload/download photos, videos, audios
2. **Message Status** — Delivery, read receipts
3. **Typing Indicators** — Show when contact is typing
4. **Media Gallery** — Display images/videos inline
5. **Message Search** — Full-text search in conversations
6. **Notifications** — Real-time updates (WebSocket)

## 🔧 Environment Variables (Railway)

Required in Railway deployment:

```
EVOLUTION_API_KEY=07826A779A5C-4E9C-A978-DBCD5F9E4C97
SUPABASE_ANON_KEY=<your key>
SUPABASE_SERVICE_KEY=<your key>
JWT_SECRET=<random string>
```

## 📞 Support

If `/api/wa` returns errors:

1. Check if `EVOLUTION_API_KEY` is set: `echo $EVOLUTION_API_KEY`
2. Verify Evolution API is up: `curl https://evolution.manager01.feynmanproject.com/instance/fetchInstances`
3. Check Railway logs for error details
4. Test locally first: `python3 14-APP-server.py 8000`

## 🐛 Known Issues

None currently. Evolution API is fully integrated and operational.

---
*Updated: 2026-02-26*
