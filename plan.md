---
title: WA Inbox UI — Plan
worktree: wt-wa-inbox-ui
branch: feature/case/wa-inbox-ui
sprint: S9-B
status: ready
created: 2026-03-21
---

# Plan — WA Inbox UI: Chat 1:1 + SLA + Canned + Collision

## Pré-requisito
```bash
# Após PR #76 (wt-wa-dm-core) mergiado em develop:
cd /path/to/wt-wa-inbox-ui
git rebase develop
# Verificar:
# - vw_wa_mentee_inbox existe
# - wa_canned_responses existe com 8 rows seed
# - wa_presence existe
# - GET /api/wa/inbox responde
```

## Sequência

```
Step 1: Estado inicial + data shapes
Step 2: SLA helpers + CSS
Step 3: waInboxView — estado + métodos de carregamento
Step 4: waInboxView — presence + heartbeat
Step 5: waCannedResponses — estado + métodos
Step 6: HTML — chat view + canned dropdown
Step 7: Commit + PR
```

---

## Step 1 — Estado inicial

**Arquivo:** `app/frontend/11-APP-app.js`

Localizar `data: {}` e `ui: {}` no objeto `app()`. Adicionar:

```javascript
// data: {}
waCannedAll: [],       // cache de canned responses

// ui: {}
waInbox: {
  open:                  false,
  mentoradoId:           null,
  mentoradoNome:         '',
  messages:              [],
  loading:               false,
  cursor:                null,        // timestamp da mensagem mais antiga carregada
  hasMore:               true,
  presenceInterval:      null,
  presencePollInterval:  null,
  others:                [],          // outros usuários presentes
},
waCanned: {
  filtered:  [],
  show:      false,
  query:     '',
},
waMessageInput: '',    // bind do input de texto do chat
```

---

## Step 2 — SLA helpers + CSS

### 2.1 Helpers em `app/frontend/11-APP-app.js`

Localizar a seção `// ===================== WA MANAGEMENT — CARTEIRA =====================` (~linha 4888).
Adicionar APÓS os métodos existentes `_waUltimoContato`, `_waFaseBadgeStyle`:

```javascript
// === SLA TIMER (S9-B) ===

_waSlaTimerClass(horas) {
  if (horas == null || horas < 0) return 'sla-none';
  if (horas > 72) return 'sla-red';
  if (horas > 48) return 'sla-yellow';
  return 'sla-green';
},

_waSlaTimerText(horas) {
  if (horas == null || horas < 0) return '—';
  if (horas < 1) return `${Math.round(horas * 60)}m`;
  if (horas < 24) return `${Math.round(horas)}h`;
  const d = Math.floor(horas / 24);
  const h = Math.round(horas % 24);
  return h > 0 ? `${d}d ${h}h` : `${d}d`;
},

// Formata timestamp ISO para exibição no chat (ex: "14:32", "ontem", "seg")
_waInboxMsgTime(ts) {
  if (!ts) return '';
  const d = new Date(ts);
  const now = new Date();
  const diffH = (now - d) / 3600000;
  if (diffH < 24 && d.getDate() === now.getDate()) {
    return d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
  }
  if (diffH < 48) return 'ontem';
  return d.toLocaleDateString('pt-BR', { weekday: 'short', day: 'numeric', month: 'short' });
},
```

### 2.2 CSS em `app/frontend/10-APP-index.html`

Localizar seção de estilos do módulo WA. Adicionar:

```css
/* === S9-B: SLA Badges === */
.sla-badge  { display:inline-flex; align-items:center; gap:3px; padding:2px 8px; border-radius:10px; font-size:11px; font-weight:600; line-height:1.4; }
.sla-green  { background:#dcfce7; color:#166534; }
.sla-yellow { background:#fef9c3; color:#854d0e; }
.sla-red    { background:#fee2e2; color:#991b1b; animation:sla-pulse 2s ease-in-out infinite; }
.sla-none   { background:#f1f5f9; color:#94a3b8; }
@keyframes sla-pulse { 0%,100%{opacity:1} 50%{opacity:.55} }

/* === S9-B: WA Inbox Chat View === */
.wa-inbox-container { display:flex; flex-direction:column; height:100%; }
.wa-inbox-header    { display:flex; align-items:center; justify-content:space-between; padding:12px 16px; border-bottom:1px solid #e2e8f0; }
.wa-inbox-messages  { flex:1; overflow-y:auto; padding:16px; display:flex; flex-direction:column; gap:8px; }
.wa-msg-wrapper     { display:flex; flex-direction:column; max-width:75%; }
.wa-msg-team        { align-self:flex-end; align-items:flex-end; }
.wa-msg-mentee      { align-self:flex-start; align-items:flex-start; }
.wa-msg-bubble      { padding:8px 12px; border-radius:12px; font-size:13px; line-height:1.5; position:relative; }
.wa-msg-team   .wa-msg-bubble  { background:#3b82f6; color:#fff; border-bottom-right-radius:4px; }
.wa-msg-mentee .wa-msg-bubble  { background:#f1f5f9; color:#1e293b; border-bottom-left-radius:4px; }
.wa-msg-sender  { font-size:11px; color:#64748b; font-weight:500; margin-bottom:2px; }
.wa-msg-time    { font-size:10px; color:#94a3b8; margin-top:2px; }
.wa-topic-badge { font-size:10px; background:#ede9fe; color:#6d28d9; padding:1px 7px; border-radius:8px; align-self:center; margin:8px 0 2px; }
.wa-extract-btn { opacity:0; font-size:16px; background:none; border:none; cursor:pointer; color:#3b82f6; padding:2px 4px; transition:opacity .15s; position:absolute; right:-28px; top:4px; }
.wa-msg-bubble:hover .wa-extract-btn { opacity:1; }
.wa-load-more-btn   { align-self:center; font-size:12px; color:#3b82f6; background:none; border:none; cursor:pointer; padding:8px; }

/* Collision badge */
.collision-badge { background:#fef9c3; color:#92400e; border-radius:8px; padding:4px 10px; font-size:12px; }

/* === S9-B: Canned Responses === */
.canned-dropdown  { position:absolute; bottom:100%; left:0; right:0; background:#fff; border:1px solid #e2e8f0; border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,.08); max-height:220px; overflow-y:auto; z-index:100; }
.canned-item      { display:flex; align-items:center; gap:8px; padding:8px 12px; cursor:pointer; border-bottom:1px solid #f8fafc; }
.canned-item:hover { background:#f8fafc; }
.canned-shortcode { font-size:12px; font-weight:700; color:#3b82f6; font-family:monospace; min-width:100px; }
.canned-name      { font-size:12px; color:#475569; }
.wa-inbox-input-wrap { position:relative; padding:12px 16px; border-top:1px solid #e2e8f0; }
.wa-inbox-input-wrap input { width:100%; padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:13px; outline:none; }
.wa-inbox-input-wrap input:focus { border-color:#3b82f6; }
```

---

## Step 3 — waInboxView: carregamento de mensagens

### Métodos em `app/frontend/11-APP-app.js`

Adicionar bloco `// === WA INBOX VIEW (S9-B) ===` após os helpers SLA:

```javascript
// === WA INBOX VIEW (S9-B) ===

async openWaInbox(menteeId, menteeNome) {
  this.ui.waInbox = {
    open: true, mentoradoId: menteeId, mentoradoNome: menteeNome || '',
    messages: [], loading: true, cursor: null, hasMore: true,
    presenceInterval: null, presencePollInterval: null, others: [],
  };
  this.ui.waMessageInput = '';
  await this.loadInboxMessages(menteeId);
  await this.loadCannedResponses();
  // Presence (Step 4)
  await this.sendWaPresence(menteeId);
  this.ui.waInbox.presenceInterval = setInterval(() => this.sendWaPresence(menteeId), 30000);
  this.ui.waInbox.presencePollInterval = setInterval(() => this.pollWaPresence(menteeId), 15000);
},

async closeWaInbox() {
  const { mentoradoId, presenceInterval, presencePollInterval } = this.ui.waInbox;
  clearInterval(presenceInterval);
  clearInterval(presencePollInterval);
  if (mentoradoId) await this.clearWaPresence(mentoradoId);
  this.ui.waInbox = {
    open: false, mentoradoId: null, mentoradoNome: '',
    messages: [], loading: false, cursor: null, hasMore: true,
    presenceInterval: null, presencePollInterval: null, others: [],
  };
  this.ui.waCanned.show = false;
  this.ui.waMessageInput = '';
},

async loadInboxMessages(menteeId) {
  this.ui.waInbox.loading = true;
  try {
    const { data, error } = await sb.from('wa_messages')
      .select('id,sender_name,is_from_team,content_type,content_text,timestamp,topic_id')
      .eq('mentorado_id', menteeId)
      .order('timestamp', { ascending: false })
      .limit(50);
    if (error) throw error;
    const msgs = (data || []).reverse();
    this.ui.waInbox.messages = msgs;
    this.ui.waInbox.cursor   = msgs.length ? msgs[0].timestamp : null;
    this.ui.waInbox.hasMore  = (data?.length || 0) === 50;
  } catch (e) {
    console.error('[Spalla] loadInboxMessages error:', e);
    this.ui.waInbox.messages = [];
  } finally {
    this.ui.waInbox.loading = false;
  }
},

async loadMoreInboxMessages() {
  const { mentoradoId, cursor, loading } = this.ui.waInbox;
  if (!mentoradoId || !cursor || loading) return;
  this.ui.waInbox.loading = true;
  try {
    const { data, error } = await sb.from('wa_messages')
      .select('id,sender_name,is_from_team,content_type,content_text,timestamp,topic_id')
      .eq('mentorado_id', mentoradoId)
      .lt('timestamp', cursor)
      .order('timestamp', { ascending: false })
      .limit(50);
    if (error) throw error;
    const older = (data || []).reverse();
    this.ui.waInbox.messages = [...older, ...this.ui.waInbox.messages];
    this.ui.waInbox.cursor   = older.length ? older[0].timestamp : cursor;
    this.ui.waInbox.hasMore  = (data?.length || 0) === 50;
  } catch (e) {
    console.error('[Spalla] loadMoreInboxMessages error:', e);
  } finally {
    this.ui.waInbox.loading = false;
  }
},

// Retorna topic_id da mensagem anterior para renderizar badge de tópico
_waInboxShouldShowTopic(messages, index) {
  if (index === 0) return !!messages[index].topic_id;
  return messages[index].topic_id && messages[index].topic_id !== messages[index - 1].topic_id;
},
```

---

## Step 4 — Presence (heartbeat + poll)

Adicionar continuando o bloco S9-B:

```javascript
async sendWaPresence(mentoradoId) {
  if (!mentoradoId) return;
  try {
    await fetch(`${CONFIG.API_BASE}/api/wa/presence`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.auth.token}`,
      },
      body: JSON.stringify({
        mentorado_id: mentoradoId,
        user_email:   this.auth?.currentUser?.email || '',
        user_name:    this.auth?.currentUser?.name  || this.auth?.currentUser?.email || '',
      }),
    });
  } catch (e) { /* best-effort — silencioso */ }
},

async clearWaPresence(mentoradoId) {
  if (!mentoradoId) return;
  const email = encodeURIComponent(this.auth?.currentUser?.email || '');
  try {
    await fetch(`${CONFIG.API_BASE}/api/wa/presence?mentorado_id=${mentoradoId}&user_email=${email}`, {
      method: 'DELETE',
      headers: { 'Authorization': `Bearer ${this.auth.token}` },
    });
  } catch (e) { /* best-effort */ }
},

async pollWaPresence(mentoradoId) {
  if (!mentoradoId) return;
  try {
    const resp = await fetch(`${CONFIG.API_BASE}/api/wa/presence/${mentoradoId}`, {
      headers: { 'Authorization': `Bearer ${this.auth.token}` },
    });
    if (!resp.ok) return;
    const all = await resp.json();
    const myEmail = this.auth?.currentUser?.email || '';
    this.ui.waInbox.others = (Array.isArray(all) ? all : []).filter(u => u.user_email !== myEmail);
  } catch (e) { /* silencioso */ }
},
```

**Adicionar no `init()` ou mount da página WA — cleanup ao fechar janela:**
```javascript
// Adicionar no init() da app Alpine
window.addEventListener('beforeunload', () => {
  const { mentoradoId } = this.ui?.waInbox || {};
  if (mentoradoId && this.auth?.currentUser?.email) {
    const email = encodeURIComponent(this.auth.currentUser.email);
    navigator.sendBeacon(`${CONFIG.API_BASE}/api/wa/presence?mentorado_id=${mentoradoId}&user_email=${email}`);
  }
});
```

---

## Step 5 — waCannedResponses

Adicionar continuando o bloco S9-B:

```javascript
async loadCannedResponses() {
  if (this.data.waCannedAll?.length > 0) return; // já carregado
  try {
    const { data } = await sb.from('wa_canned_responses')
      .select('shortcode,name,content,category')
      .order('shortcode');
    this.data.waCannedAll = data || [];
  } catch (e) {
    this.data.waCannedAll = [];
  }
},

onWaInputKeyup(value) {
  if (value.startsWith('/')) {
    const q = value.slice(1).toLowerCase();
    this.ui.waCanned.filtered = (this.data.waCannedAll || []).filter(r =>
      r.shortcode.slice(1).includes(q) || r.name.toLowerCase().includes(q)
    );
    this.ui.waCanned.show = this.ui.waCanned.filtered.length > 0;
  } else {
    this.ui.waCanned.show = false;
  }
},

selectCannedResponse(r) {
  this.ui.waMessageInput = r.content;
  this.ui.waCanned.show  = false;
},
```

---

## Step 6 — HTML

**Arquivo:** `app/frontend/10-APP-index.html`

Localizar o módulo WA no HTML. Adicionar:

### 6.1 Botão inbox no card de mentorado da Carteira

Localizar o card HTML de cada mentorado na Carteira. Adicionar badge SLA + botão de inbox:

```html
<!-- SLA badge (adicionar ao card de mentorado) -->
<span
  x-bind:class="'sla-badge ' + _waSlaTimerClass(m.horas_sem_resposta_equipe)"
  x-text="_waSlaTimerText(m.horas_sem_resposta_equipe)"
></span>

<!-- Botão abrir inbox 1:1 -->
<button class="btn-icon" title="Abrir conversa" @click="openWaInbox(m.mentorado_id, m.nome)">
  💬
</button>
```

> **Nota:** `m.horas_sem_resposta_equipe` existe em `vw_wa_mentee_inbox`. O SLA badge só funciona se a carteira usa dados dessa view. Verificar se `this.data.mentees` é populado de `vw_wa_mentee_inbox` ou de `/api/mentees`. Se for `/api/mentees`, o badge mostrará `—` até que a carteira migre para a view — comportamento aceitável em S9-B.

### 6.2 Chat inbox (drawer ou modal lateral)

```html
<!-- WA Inbox Drawer (S9-B) -->
<div
  x-show="ui.waInbox.open"
  class="wa-inbox-container"
  style="position:fixed;top:0;right:0;width:420px;height:100vh;background:#fff;box-shadow:-4px 0 24px rgba(0,0,0,.12);z-index:200;display:flex;flex-direction:column"
  @keydown.escape.window="closeWaInbox()"
>
  <!-- Header -->
  <div class="wa-inbox-header">
    <div>
      <strong x-text="ui.waInbox.mentoradoNome"></strong>
      <!-- Collision badge -->
      <template x-for="u in ui.waInbox.others" :key="u.user_email">
        <span class="collision-badge" x-text="u.user_name + ' também está aqui'"></span>
      </template>
    </div>
    <button @click="closeWaInbox()">✕</button>
  </div>

  <!-- Messages -->
  <div class="wa-inbox-messages" id="waInboxMessages">
    <!-- Load more -->
    <button
      x-show="ui.waInbox.hasMore && !ui.waInbox.loading"
      class="wa-load-more-btn"
      @click="loadMoreInboxMessages()"
    >↑ Carregar mais</button>

    <div x-show="ui.waInbox.loading && ui.waInbox.messages.length === 0"
         style="text-align:center;color:#64748b;padding:24px">Carregando...</div>

    <template x-for="(msg, idx) in ui.waInbox.messages" :key="msg.id">
      <div>
        <!-- Topic badge (quando muda de tópico) -->
        <div x-show="_waInboxShouldShowTopic(ui.waInbox.messages, idx)"
             class="wa-topic-badge">tópico</div>

        <!-- Message bubble -->
        <div class="wa-msg-wrapper" x-bind:class="msg.is_from_team ? 'wa-msg-team' : 'wa-msg-mentee'">
          <span class="wa-msg-sender"
                x-show="!msg.is_from_team"
                x-text="msg.sender_name || 'Mentorado'"></span>
          <div style="position:relative">
            <div class="wa-msg-bubble" x-text="msg.content_text || '[mídia]'"></div>
            <!-- Botão criar tarefa (S9-C usa este trigger) -->
            <button class="wa-extract-btn"
                    title="Criar tarefa"
                    @click="openWaTaskExtract(msg)">⊕</button>
          </div>
          <span class="wa-msg-time" x-text="_waInboxMsgTime(msg.timestamp)"></span>
        </div>
      </div>
    </template>
  </div>

  <!-- Input área -->
  <div class="wa-inbox-input-wrap">
    <!-- Canned responses dropdown -->
    <div x-show="ui.waCanned.show" class="canned-dropdown">
      <template x-for="r in ui.waCanned.filtered" :key="r.shortcode">
        <div class="canned-item" @click="selectCannedResponse(r)">
          <span class="canned-shortcode" x-text="r.shortcode"></span>
          <span class="canned-name" x-text="r.name"></span>
        </div>
      </template>
    </div>
    <input
      type="text"
      x-model="ui.waMessageInput"
      @keyup="onWaInputKeyup(ui.waMessageInput)"
      @keydown.escape="ui.waCanned.show = false"
      placeholder="Digite / para respostas rápidas..."
    />
  </div>
</div>
```

---

## Step 7 — Commit + PR

```bash
git add app/frontend/10-APP-index.html app/frontend/11-APP-app.js spec.md plan.md
git commit -m "feat(wa): S9-B — waInboxView + SLA badges + canned responses + presence"
git push -u origin feature/case/wa-inbox-ui
gh pr create --base develop
```
