---
title: WA Inbox UI — Spec
worktree: wt-wa-inbox-ui
branch: feature/case/wa-inbox-ui
sprint: S9-B
status: ready
created: 2026-03-21
---

# Spec — WA Inbox UI: Chat 1:1 + SLA + Canned + Collision

## 1. Objetivo

Camada visual do WA Management v2. **Somente frontend** — `index.html` + `app.js`.
Depende do PR #76 (wt-wa-dm-core) estar merged + `git rebase develop`.

---

## 2. Padrões Confirmados no Código Existente

### Padrão de acesso a dados
- **Supabase direto** (`sb.from(...)`) para queries read e inserts simples
- **`fetch(CONFIG.API_BASE + '/api/...')`** para endpoints backend
- **S9-B usa exclusivamente Supabase direto** — mensagens, canned responses, presence via backend API

### Padrão Alpine.js
- Métodos inline no objeto principal `app()` — sem componentes separados
- Estado em `this.data.*` (dados) e `this.ui.*` (estado de UI)
- Toast via `this.toast(msg, type)` — `'success'|'error'|'warning'`
- Supabase client em `sb` (global)

### Método de referência: `openWaTopic(topic)`
```javascript
// app.js linha ~5197
const { data, error } = await sb.from('wa_messages')
  .select('id,sender_name,is_from_team,content_type,content_text,timestamp')
  .eq('topic_id', topic.id)
  .order('timestamp', { ascending: true })
  .limit(100);
```
→ `waInboxView` seguirá o mesmo padrão mas com `.eq('mentorado_id', X)`.

### Método de referência: `convertTopicToTask()` (app.js ~5232)
→ Mostra que `god_tasks` pode ser criado via Supabase direto. **Relevante para S9-C**, não S9-B.

### `_waHealthLabel(m)` — CONFLITO IDENTIFICADO
Método atual calcula health baseado em `calcHealthScore()`. A VIEW `vw_wa_mentee_inbox` agora retorna `health_status` diretamente. **Decisão:** S9-B NÃO substitui `_waHealthLabel()` — mantém compatibilidade. Os SLA badges usam `m.horas_sem_resposta_equipe` da VIEW no inbox, e o carteira atual mantém o `_waHealthLabel()` existente.

---

## 3. Data Sources Confirmados (pós-migration dm-core)

| Dado | Source | Query |
|------|--------|-------|
| Inbox list | `vw_wa_mentee_inbox` | `sb.from('vw_wa_mentee_inbox').select('*')` |
| Messages do mentee | `wa_messages` | `.eq('mentorado_id', X).order('timestamp', asc)` |
| Canned responses | `wa_canned_responses` | `.select('shortcode,name,content,category')` |
| Presence | backend API | `POST/DELETE/GET /api/wa/presence` (S9-A) |

---

## 4. Componentes a Implementar

### 4.1 SLA Countdown Badges — Carteira cards

**Localização:** Novos helpers em `app.js` + CSS em `index.html`

**Helpers (novos métodos no objeto `app()`):**
```javascript
_waSlaTimerClass(horas) {
  if (horas == null) return 'sla-none';
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
```

**CSS (`index.html` — seção de estilos WA existente):**
```css
/* SLA Badges */
.sla-badge { display:inline-flex; align-items:center; gap:4px; padding:2px 8px; border-radius:12px; font-size:11px; font-weight:600; }
.sla-green  { background:#dcfce7; color:#166534; }
.sla-yellow { background:#fef9c3; color:#854d0e; }
.sla-red    { background:#fee2e2; color:#991b1b; animation: sla-pulse 2s ease-in-out infinite; }
.sla-none   { background:#f1f5f9; color:#64748b; }
@keyframes sla-pulse { 0%,100% { opacity:1; } 50% { opacity:.6; } }
```

**Uso no card HTML** (adicionar ao card de mentorado na Carteira):
```html
<span
  x-bind:class="'sla-badge ' + _waSlaTimerClass(m.horas_sem_resposta_equipe)"
  x-text="_waSlaTimerText(m.horas_sem_resposta_equipe)"
></span>
```

**Nota:** `m.horas_sem_resposta_equipe` só existe em `vw_wa_mentee_inbox`. A Carteira atual carrega `mentees` via `GET /api/mentees`. Para ter esse campo, o inbox view usa dados da view. O badge só aparece na aba "Inbox" (S9-B), não na aba "Carteira" que usa o endpoint existente.

---

### 4.2 waInboxView — Chat 1:1 virtual

**Estado no `this.ui`:**
```javascript
waInbox: {
  open: false,
  mentoradoId: null,
  mentoradoNome: '',
  messages: [],
  loading: false,
  cursor: null,        // timestamp do oldest msg carregada (para load more)
  hasMore: true,
  presenceInterval: null,
  presencePollInterval: null,
  others: [],          // outros usuários vendo agora
},
```

**Métodos:**
```javascript
async openWaInbox(menteeId, menteeNome) { ... }
async closeWaInbox() { ... }
async loadInboxMessages(menteeId, before = null) { ... }  // cursor-based
async loadMoreMessages() { ... }
_waInboxGroupByTopic(messages) { ... }  // agrupa badges de tópico
```

**Query base:**
```javascript
// Carrega 50 mensagens mais recentes
const { data } = await sb.from('wa_messages')
  .select('id,sender_name,is_from_team,content_type,content_text,timestamp,topic_id')
  .eq('mentorado_id', menteeId)
  .order('timestamp', { ascending: false })  // mais recentes primeiro
  .limit(50);
// Reverter para exibir mais antigo no topo
this.ui.waInbox.messages = (data || []).reverse();
this.ui.waInbox.cursor = data?.length ? data[data.length - 1].timestamp : null;
this.ui.waInbox.hasMore = (data?.length || 0) === 50;
```

**Load more (scroll up):**
```javascript
const { data } = await sb.from('wa_messages')
  .select('id,sender_name,is_from_team,content_type,content_text,timestamp,topic_id')
  .eq('mentorado_id', menteeId)
  .lt('timestamp', this.ui.waInbox.cursor)
  .order('timestamp', { ascending: false })
  .limit(50);
// Prepend ao array existente
this.ui.waInbox.messages = [...(data || []).reverse(), ...this.ui.waInbox.messages];
```

**Renderização de mensagem (HTML Alpine):**
```html
<div x-bind:class="msg.is_from_team ? 'wa-msg-team' : 'wa-msg-mentee'">
  <span class="wa-msg-sender" x-text="msg.sender_name"></span>
  <div class="wa-msg-bubble" x-text="msg.content_text"></div>
  <span class="wa-msg-time" x-text="_waUltimoContato({horas_sem_resposta_equipe: ...})"></span>
  <!-- Botão criar tarefa (S9-C integra modal aqui) -->
  <button class="wa-extract-btn" @click="ui.waTaskExtract = { open: true, msg }">⊕</button>
</div>
```

**Render do chat:** `is_from_team = true` → alinhado à direita (balão azul), `false` → esquerda (balão cinza). Padrão WhatsApp Web.

---

### 4.3 waCannedResponses — Quick replies

**Estado:**
```javascript
waCanned: {
  all: [],      // cache completo carregado no mount
  filtered: [],
  show: false,
  query: '',
},
```

**Carregamento (uma vez, no mount da página WA):**
```javascript
async loadCannedResponses() {
  const { data } = await sb.from('wa_canned_responses')
    .select('shortcode,name,content,category')
    .order('shortcode');
  this.ui.waCanned.all = data || [];
},
```

**Trigger no input de mensagem:** detecta `/` como primeiro char → filtra:
```javascript
onWaInputKeydown(e) {
  const val = e.target.value;
  if (val.startsWith('/')) {
    const q = val.slice(1).toLowerCase();
    this.ui.waCanned.filtered = this.ui.waCanned.all.filter(r =>
      r.shortcode.includes(q) || r.name.toLowerCase().includes(q)
    );
    this.ui.waCanned.show = this.ui.waCanned.filtered.length > 0;
  } else {
    this.ui.waCanned.show = false;
  }
},

selectCannedResponse(r) {
  // Injeta conteúdo no input de mensagem (via this.ui.waMessageInput)
  this.ui.waMessageInput = r.content;
  this.ui.waCanned.show = false;
},
```

**HTML — dropdown canned responses:**
```html
<div x-show="ui.waCanned.show" class="canned-dropdown">
  <template x-for="r in ui.waCanned.filtered" :key="r.shortcode">
    <div class="canned-item" @click="selectCannedResponse(r)">
      <span class="canned-shortcode" x-text="r.shortcode"></span>
      <span class="canned-name" x-text="r.name"></span>
    </div>
  </template>
</div>
```

---

### 4.4 Presence (Collision detection)

**Usando endpoints do S9-A:** `POST /api/wa/presence`, `DELETE /api/wa/presence`, `GET /api/wa/presence/{id}`

```javascript
async sendWaPresence(mentoradoId) {
  await fetch(`${CONFIG.API_BASE}/api/wa/presence`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.token}` },
    body: JSON.stringify({
      mentorado_id: mentoradoId,
      user_email: this.auth?.currentUser?.email || '',
      user_name: this.auth?.currentUser?.name || '',
    }),
  });
},

async clearWaPresence(mentoradoId) {
  const email = this.auth?.currentUser?.email || '';
  await fetch(`${CONFIG.API_BASE}/api/wa/presence?mentorado_id=${mentoradoId}&user_email=${encodeURIComponent(email)}`, {
    method: 'DELETE',
    headers: { 'Authorization': `Bearer ${this.auth.token}` },
  });
},

async pollWaPresence(mentoradoId) {
  try {
    const resp = await fetch(`${CONFIG.API_BASE}/api/wa/presence/${mentoradoId}`, {
      headers: { 'Authorization': `Bearer ${this.auth.token}` },
    });
    const others = await resp.json();
    const myEmail = this.auth?.currentUser?.email || '';
    this.ui.waInbox.others = (others || []).filter(u => u.user_email !== myEmail);
  } catch (e) { /* silencioso */ }
},
```

**Ciclo de vida:**
```javascript
async openWaInbox(menteeId, menteeNome) {
  this.ui.waInbox = { open: true, mentoradoId: menteeId, ... };
  await this.loadInboxMessages(menteeId);
  await this.loadCannedResponses();
  await this.sendWaPresence(menteeId);
  // Heartbeat 30s
  this.ui.waInbox.presenceInterval = setInterval(() => this.sendWaPresence(menteeId), 30000);
  // Poll presence 15s
  this.ui.waInbox.presencePollInterval = setInterval(() => this.pollWaPresence(menteeId), 15000);
},

async closeWaInbox() {
  const { mentoradoId, presenceInterval, presencePollInterval } = this.ui.waInbox;
  clearInterval(presenceInterval);
  clearInterval(presencePollInterval);
  if (mentoradoId) await this.clearWaPresence(mentoradoId);
  this.ui.waInbox = { open: false, mentoradoId: null, ... };
},
```

**Collision badge no header do chat:**
```html
<div x-show="ui.waInbox.others.length > 0" class="collision-badge">
  <template x-for="u in ui.waInbox.others" :key="u.user_email">
    <span x-text="u.user_name + ' também está aqui'"></span>
  </template>
</div>
```

---

## 5. Arquivos a Modificar

| Arquivo | Ação | Onde |
|---------|------|------|
| `app/frontend/11-APP-app.js` | ADD — 5 helpers + 6 métodos + estado waInbox | Seção `WA MANAGEMENT` ~linha 5260+ |
| `app/frontend/10-APP-index.html` | ADD — CSS badges + HTML chat view + canned dropdown | Seção WA styles + HTML do módulo WA |

**Não tocar:** `supabase/`, `app/backend/`

---

## 6. Nota: `window.beforeunload` para presence cleanup

```javascript
// Adicionar no init() ou mount da página
window.addEventListener('beforeunload', () => {
  const { mentoradoId } = this.ui.waInbox;
  if (mentoradoId) {
    // sendBeacon é best-effort (não bloqueia unload)
    const email = this.auth?.currentUser?.email || '';
    navigator.sendBeacon(
      `${CONFIG.API_BASE}/api/wa/presence?mentorado_id=${mentoradoId}&user_email=${encodeURIComponent(email)}`,
    );
  }
});
```
