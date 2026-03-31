# WhatsApp Integration Plan — Spalla Dashboard

## O que já funciona
- Enviar texto via Evolution API (proxy backend)
- Enviar media (imagem, audio, video, doc) via base64
- Listar chats e mensagens
- Polling cada 5s pra novas mensagens
- Sessoes por usuario (wa_sessions)
- Pipeline N8N de ingestao (webhook -> classificacao -> Supabase)
- Inbox view com metricas (vw_wa_mentee_inbox)
- Storage S3 (case-evolution-media)

## O que falta

| Funcionalidade | Status |
|---|---|
| Enviar texto | DONE |
| Enviar media | DONE |
| Ver imagens/audio/docs inline | PARCIAL |
| Reply to (responder msg especifica) | NAO |
| Status de entrega (enviado/entregue/lido) | NAO |
| Real-time push (sem polling) | NAO |
| Gerenciamento de grupos | NAO |
| Webhook direto Evolution -> Dashboard | NAO |
| Inbox unificado (Chatwoot + Evolution) | NAO |

## Fases

### FASE 1: MVP (1-2 semanas)
1. Migration: coluna `status` em wa_messages
2. Backend: webhook receiver pra status updates da Evolution
3. Backend: endpoints autenticados de send com audit trail
4. Backend: endpoint de reply-to
5. Frontend: Supabase Realtime no lugar de polling 5s
6. Frontend: UI de reply-to (preview da msg citada)
7. Frontend: indicadores de status (check cinza/azul)

### FASE 2: Media (1 semana)
1. Render inline: imagens (lightbox), audio (player), video, docs
2. Gravacao de audio (MediaRecorder API)
3. Paste de imagem do clipboard

### FASE 3: Grupos (1-2 semanas)
1. Migration: tabela wa_groups
2. Backend: CRUD de grupos via Evolution API
3. Frontend: painel de gerenciamento de grupos
4. Link grupo -> mentorado

### FASE 4: Avancado (2 semanas)
1. Deprecar Chatwoot (migrar dados)
2. Typing indicators
3. Read receipts (marcar como lido ao visualizar)
4. Busca full-text + semantica

## Arquitetura

```
Evolution API (producao002 + user instances)
  |                    |
  | webhook            | REST API
  v                    ^
N8N (wa-ingest)    Spalla Backend (proxy + custom endpoints)
  |                    |
  v                    v
         Supabase (wa_messages, wa_topics, wa_groups)
              ^
              | Supabase Realtime
              |
         Spalla Frontend (Alpine.js)
```

## Backend: Railway (web-production-2cde5.up.railway.app)
## Frontend: Vercel (spalla-dashboard.vercel.app)

## Env vars existentes
- EVOLUTION_BASE, EVOLUTION_API_KEY
- S3_ACCESS_KEY, S3_SECRET_KEY, S3_BUCKET, S3_ENDPOINT
- SUPABASE_URL, SUPABASE_SERVICE_KEY

## Novos env vars
- EVOLUTION_WEBHOOK_SECRET
- WA_RATE_LIMIT_PER_MINUTE (default: 30)
