# Story 4.0 — WhatsApp Per-User Connection

## Overview
Cada usuario do Spalla conecta seu proprio WhatsApp via QR Code para enviar mensagens direto do sistema. O webhook central (producao002) continua coletando todas as mensagens — esta feature adiciona apenas a **conexao individual** e o **envio roteado**.

---

## Epic 1: Foundation & Schema (Sprint 1)

### Story 1.1 — Schema `wa_sessions`
**Como** administrador do sistema,
**quero** uma tabela que armazene sessoes WhatsApp por usuario,
**para que** cada membro da equipe tenha sua propria conexao isolada.

**Acceptance Criteria:**
- [x] Tabela `wa_sessions` criada com campos: `id`, `user_id`, `instance_name`, `status`, `phone_number`, `qr_code_base64`, `connected_at`, `last_health_check`, `created_at`, `updated_at`
- [x] `status` com CHECK: `disconnected`, `qr_pending`, `connecting`, `connected`, `banned`
- [x] Unique index: 1 sessao ativa por user
- [x] RLS: user ve apenas sua propria sessao
- [x] Trigger `updated_at` automatico

**File List:**
- `50-SQL-wa-sessions.sql`

---

### Story 1.2 — Settings UI: Secao WhatsApp
**Como** usuario do Spalla,
**quero** ver uma secao "WhatsApp" nas configuracoes,
**para que** eu saiba o estado da minha conexao e possa iniciar o pareamento.

**Acceptance Criteria:**
- [x] Nova secao "WhatsApp" na pagina de Settings
- [x] Estado `disconnected`: botao "Conectar meu WhatsApp"
- [x] Estado `connected`: exibe numero conectado + botao "Desconectar"
- [x] Estado `qr_pending`: exibe QR Code + instrucao
- [x] Icone de status (verde=conectado, cinza=desconectado, amarelo=pendente)

**File List:**
- `10-APP-index.html` (Settings section)
- `13-APP-styles.css` (WhatsApp settings styles)

---

### Story 1.3 — Funcao `loadWaSession()`
**Como** sistema,
**quero** carregar a sessao WhatsApp do usuario logado ao iniciar o app,
**para que** o estado da conexao esteja sempre atualizado na UI.

**Acceptance Criteria:**
- [x] `loadWaSession()` consulta `wa_sessions` filtrado por `auth.uid()`
- [x] Popula `this.waSession` (null se nao existe)
- [x] Chamado no `init()` apos login
- [x] Se `status === 'connected'`, valida com Evolution API (`connectionState`)

**File List:**
- `11-APP-app.js` (loadWaSession, init)

---

## Epic 2: Instance Creation & QR Pairing (Sprint 2)

### Story 2.1 — Criar instancia Evolution per-user
**Como** usuario do Spalla,
**quero** que ao clicar "Conectar meu WhatsApp" uma instancia seja criada para mim,
**para que** eu tenha minha propria conexao independente.

**Acceptance Criteria:**
- [x] `waCreateInstance()` chama `POST /instance/create` com `instanceName: spalla_{user_id_short}`
- [x] Parametros: `integration: WHATSAPP-BAILEYS`, `qrcode: true`
- [x] Salva `instance_name` em `wa_sessions` com `status: qr_pending`
- [x] Tratamento de erro: instancia ja existe -> tenta reconectar
- [x] Tratamento de erro: API offline -> toast de erro

**File List:**
- `11-APP-app.js` (waCreateInstance)

---

### Story 2.2 — Exibir QR Code e polling de status
**Como** usuario do Spalla,
**quero** ver o QR Code na tela e que o sistema detecte automaticamente quando eu escanear,
**para que** eu nao precise clicar nada apos escanear o codigo.

**Acceptance Criteria:**
- [x] `waFetchQrCode()` chama `GET /instance/connect/{instance}` -> retorna base64
- [x] Exibe QR em modal/card nas Settings
- [x] Polling a cada 3s: `GET /instance/connectionState/{instance}`
- [x] Quando `state === 'open'`: atualiza `wa_sessions.status = 'connected'`, salva `phone_number`
- [x] QR expira em 45s -> exibe botao "Gerar novo QR"
- [x] Toast de sucesso: "WhatsApp conectado!"

**File List:**
- `11-APP-app.js` (waFetchQrCode, waPollingStatus)
- `10-APP-index.html` (QR modal)
- `13-APP-styles.css` (QR modal styles)

---

### Story 2.3 — Persistencia de sessao
**Como** usuario do Spalla,
**quero** que minha conexao WhatsApp persista entre reloads e sessoes,
**para que** eu nao precise escanear o QR toda vez que abrir o sistema.

**Acceptance Criteria:**
- [x] No `init()`: se `wa_sessions.status === 'connected'`, verifica com Evolution API
- [x] Se Evolution confirma `open`: mantem connected, exibe numero
- [x] Se Evolution retorna `close`: tenta `PUT /instance/restart/{instance}`
- [x] Se restart falha: atualiza status para `disconnected`, pede novo QR
- [x] Indicador visual no sidebar/topbar: dot verde quando conectado

**File List:**
- `11-APP-app.js` (init, waCheckHealth)

---

### Story 2.4 — Desconectar WhatsApp
**Como** usuario do Spalla,
**quero** poder desconectar meu WhatsApp das configuracoes,
**para que** eu possa trocar de numero ou revogar acesso.

**Acceptance Criteria:**
- [x] Botao "Desconectar" com confirmacao
- [x] `waDisconnect()` chama `DELETE /instance/logout/{instance}`
- [x] Atualiza `wa_sessions.status = 'disconnected'`, limpa `phone_number`
- [x] UI volta para estado "Conectar meu WhatsApp"

**File List:**
- `11-APP-app.js` (waDisconnect)
- `10-APP-index.html` (disconnect button)

---

## Epic 3: Envio Roteado & Health (Sprint 3)

### Story 3.1 — Roteamento dinamico de envio
**Como** usuario do Spalla,
**quero** que minhas mensagens sejam enviadas pelo meu WhatsApp conectado,
**para que** o mentorado receba a mensagem do meu numero pessoal.

**Acceptance Criteria:**
- [ ] `sendWhatsAppMessage()` usa `wa_sessions.instance_name` do user logado
- [ ] Fallback para `producao002` se user nao tem instancia conectada
- [ ] Toast de aviso se enviando pelo numero central (fallback)
- [ ] Mensagem enviada aparece no thread otimisticamente

**File List:**
- `11-APP-app.js` (sendWhatsAppMessage refactor)

---

### Story 3.2 — Envio de midia (arquivos, imagens, audio)
**Como** usuario do Spalla,
**quero** enviar fotos, documentos e audios pelo chat do Spalla,
**para que** eu nao precise alternar entre Spalla e WhatsApp.

**Acceptance Criteria:**
- [ ] Botao de anexo no chat
- [ ] Upload de imagem: `POST /message/sendMedia/{instance}` com `mediatype: image`
- [ ] Upload de documento: `POST /message/sendMedia/{instance}` com `mediatype: document`
- [ ] Preview do arquivo antes de enviar
- [ ] Progress indicator durante upload
- [ ] Limite de tamanho: 16MB (limite do WhatsApp)

**File List:**
- `11-APP-app.js` (waSendMedia)
- `10-APP-index.html` (attachment UI)
- `13-APP-styles.css` (attachment styles)

---

### Story 3.3 — Health check & auto-reconnect
**Como** sistema,
**quero** verificar periodicamente se a conexao WhatsApp do usuario esta ativa,
**para que** desconexoes sejam detectadas e tratadas automaticamente.

**Acceptance Criteria:**
- [ ] Polling a cada 60s: `GET /instance/connectionState/{instance}`
- [ ] Se `close`: tenta `PUT /instance/restart/{instance}` (1x)
- [ ] Se restart falha: banner "WhatsApp desconectado — Reconectar"
- [ ] Atualiza `wa_sessions.last_health_check` a cada check
- [ ] Nao roda health check se user nao tem sessao

**File List:**
- `11-APP-app.js` (waHealthCheck interval)

---

### Story 3.4 — Indicador de conexao global
**Como** usuario do Spalla,
**quero** ver em qualquer pagina se meu WhatsApp esta conectado,
**para que** eu saiba se posso enviar mensagens antes de ir ao chat.

**Acceptance Criteria:**
- [ ] Dot no sidebar (item WhatsApp): verde=conectado, cinza=desconectado
- [ ] Tooltip com numero conectado e tempo de conexao
- [ ] No chat: se desconectado, campo de envio desabilitado com mensagem "Conecte seu WhatsApp em Configuracoes"

**File List:**
- `10-APP-index.html` (sidebar dot, chat disabled state)
- `13-APP-styles.css` (connection indicator styles)

---

## Resumo

| Sprint | Epic | Stories | Esforco |
|--------|------|---------|---------|
| **1** | Foundation & Schema | 1.1, 1.2, 1.3 | Leve |
| **2** | Instance & QR Pairing | 2.1, 2.2, 2.3, 2.4 | Medio |
| **3** | Envio Roteado & Health | 3.1, 3.2, 3.3, 3.4 | Medio |

**Total: 3 Epics, 11 Stories**

---

## Notas Tecnicas

- **producao002** continua como coletor central (webhook → Supabase → classificacao)
- Instancias per-user sao APENAS para envio e conexao visual
- Evolution API v2 persiste sessoes em PostgreSQL (Baileys) — reconexao automatica no restart do server
- Fallback: se user nao tem instancia, envio vai pelo producao002 com aviso
