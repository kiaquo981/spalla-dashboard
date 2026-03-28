---
title: "EPIC: WhatsApp Full Integration — Spalla Dashboard"
status: in_progress
created: 2026-03-28
owner: kaique
priority: urgente
---

# EPIC: WhatsApp Full Integration

> Integração bidirecional completa com Evolution API.
> De "ver mensagens read-only" para "sistema de comunicação completo".

## Stories

### STORY 1: Real-time Messages (substituir polling por Supabase Realtime) ✅
- [x] Deprecar startWhatsAppPolling (mantido como fallback)
- [x] Implementar Supabase Realtime subscription em wa_messages
- [x] Subscribe filtrado por group_jid do chat selecionado
- [x] On INSERT: append mensagem ao array (com dedup)
- [x] On UPDATE: atualizar status da mensagem
- [x] Cleanup subscription ao trocar de chat ou sair da view
- [x] Fallback pra Evolution API quando wa_messages vazio
- **Arquivos:** 11-APP-app.js

### STORY 2: Message Status Tracking (enviado/entregue/lido) ✅
- [x] Migration: ADD COLUMN status TEXT em wa_messages (64-SQL-wa-message-status.sql)
- [x] Migration: ADD COLUMN status_updated_at TIMESTAMPTZ
- [x] Migration: Enable Realtime publication + RLS policies
- [x] Backend: POST /api/webhooks/evolution (webhook receiver)
- [x] Verificar apikey header no webhook (EVOLUTION_WEBHOOK_SECRET)
- [x] Parse messages.update events → UPDATE wa_messages.status
- [ ] Configurar Evolution API pra enviar webhook de status (ops task)
- [x] Frontend: indicadores visuais (✓ cinza, ✓✓ cinza, ✓✓ azul, ✗ vermelho)
- **Arquivos:** 14-APP-server.py, 11-APP-app.js, 10-APP-index.html, 13-APP-styles.css, migration SQL

### STORY 3: Reply-to (responder mensagem específica) ✅
- [x] Backend: POST /api/wa/reply com quoted_message_id
- [x] Chamar Evolution API com parametro quoted
- [x] INSERT em wa_messages com reply_to_id
- [x] Frontend: botao "responder" em cada mensagem
- [x] Preview da mensagem citada acima do input
- [x] Enviar com reply_to_id no payload
- [x] Scroll-to ao clicar em reply preview
- **Arquivos:** 14-APP-server.py, 11-APP-app.js, 10-APP-index.html, 13-APP-styles.css

### STORY 4: Send with Audit Trail (endpoints autenticados) ✅
- [x] Backend: POST /api/wa/send-text (JWT required)
- [x] Backend: POST /api/wa/send-media (JWT required)
- [x] INSERT em wa_messages com is_from_team=true, status=pending
- [x] Log de auditoria: quem enviou, quando, pra quem
- [x] Rate limiting: 30 msgs/min por usuario (WA_RATE_LIMIT_PER_MINUTE)
- [x] Frontend: wired to new endpoints (sendWhatsAppMessage + waSendMedia)
- [x] Optimistic insert com fallback on error
- **Arquivos:** 14-APP-server.py, 11-APP-app.js

### STORY 5: Inline Media Rendering (imagens, audio, video, docs)
- [ ] Imagens: thumbnail com lightbox no click
- [ ] Audio: player HTML5 com controles
- [ ] Video: player HTML5 com thumbnail
- [ ] Documentos: icone + nome + download link
- [ ] Presigned URLs via GET /api/media/stream (já existe)
- [ ] Fallback quando media não disponível
- **Arquivos:** 10-APP-index.html, 11-APP-app.js, 13-APP-styles.css

### STORY 6: Audio Recording (gravar e enviar audio)
- [ ] Botao microfone no input de chat
- [ ] MediaRecorder API → opus/ogg
- [ ] Preview do audio antes de enviar
- [ ] Enviar via waSendMedia() type=audio
- [ ] Indicador visual de gravando
- **Arquivos:** 11-APP-app.js, 10-APP-index.html

### STORY 7: Image Paste + File Upload
- [ ] Listener de paste event no input
- [ ] Extrair imagem do clipboard
- [ ] Drag & drop de arquivos no chat
- [ ] Preview antes de enviar
- [ ] Enviar via waSendMedia()
- **Arquivos:** 11-APP-app.js, 10-APP-index.html

### STORY 8: Group Chat Management
- [ ] Migration: CREATE TABLE wa_groups
- [ ] Backend: GET /api/wa/groups (listar)
- [ ] Backend: POST /api/wa/groups/sync (sync metadata)
- [ ] Backend: POST /api/wa/groups/create (criar grupo)
- [ ] Frontend: lista de grupos com member count, last activity
- [ ] Frontend: criar grupo (selecionar mentorado + equipe)
- [ ] Frontend: vincular grupo ao mentorado
- [ ] Frontend: configurações do grupo (renomear, add/remove participantes)
- **Arquivos:** 14-APP-server.py, 11-APP-app.js, 10-APP-index.html, migration SQL

### STORY 9: Typing Indicators
- [ ] Enviar "composing" via Evolution API ao digitar
- [ ] Receber typing status via Realtime subscription
- [ ] Mostrar "digitando..." com animação de bolhas
- [ ] Debounce de 3s no envio de composing
- **Arquivos:** 11-APP-app.js, 10-APP-index.html

### STORY 10: Read Receipts (outbound)
- [ ] IntersectionObserver nas mensagens do chat
- [ ] Quando msg fica visível: chamar Evolution readMessages
- [ ] Marcar como lida no Supabase
- [ ] Atualizar contadores de unread
- **Arquivos:** 11-APP-app.js

### STORY 11: Message Search
- [ ] Full-text search via wa_messages.content_text
- [ ] Semantic search via embeddings existentes
- [ ] Search bar no chat WhatsApp
- [ ] Highlight de resultados
- [ ] Navegar pra mensagem encontrada
- **Arquivos:** 11-APP-app.js, 10-APP-index.html

### STORY 12: Deprecate Chatwoot + Unified Inbox
- [ ] Migration: migrar dados chatwoot_messages → wa_messages
- [ ] Remover webhook handler de Chatwoot
- [ ] Remover tabela chatwoot_messages (após migração confirmada)
- [ ] Garantir que inbox view (vw_wa_mentee_inbox) é única fonte
- [ ] Atualizar Command Center pra usar dados unificados
- **Arquivos:** 14-APP-server.py, 11-APP-app.js, migration SQL

## Dependências entre Stories

```
Story 1 (Realtime) ──────┐
Story 2 (Status) ────────┤──→ Story 9 (Typing)
Story 3 (Reply-to) ──────┤──→ Story 10 (Read Receipts)
Story 4 (Send w/ Audit) ─┘──→ Story 11 (Search)
                               Story 12 (Deprecate Chatwoot)
Story 5 (Media Render) ──┐
Story 6 (Audio Record) ──┤──→ independentes
Story 7 (Paste/Upload) ──┘

Story 8 (Groups) ──→ independente (pode rodar em paralelo)
```

## Definition of Done
- [ ] Enviar e receber mensagens em tempo real
- [ ] Ver status de entrega (enviado/entregue/lido)
- [ ] Responder mensagens específicas (quote)
- [ ] Ver e enviar imagens, audio, video, documentos
- [ ] Gravar e enviar audio
- [ ] Gerenciar grupos WhatsApp
- [ ] Buscar mensagens (texto + semântico)
- [ ] Zero dependência do Chatwoot
- [ ] Rate limiting e audit trail
- [ ] Tudo funcionando em produção
