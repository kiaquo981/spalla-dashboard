---
title: WA Task Triage — Plan
worktree: wt-wa-task-triage
branch: feature/case/wa-task-triage
sprint: S9-C
status: ready
created: 2026-03-21
---

# Plan — WA Task Extraction + Triage + Saved Segments

## Pré-requisito
```bash
# Após PR #76 (wt-wa-dm-core) mergiado em develop:
cd /path/to/wt-wa-task-triage
git rebase develop
```

## Sequência

```
Step 1: Estado inicial
Step 2: Task Extraction modal (app.js + HTML)
Step 3: Triage inbox (app.js + HTML + sidebar badge)
Step 4: Saved Segments (app.js + HTML)
Step 5: CSS para novos componentes
Step 6: Commit + PR
```

> **Nota de merge:** Se S9-B ainda não mergiou, o botão `⊕` no chat pode não existir ainda.
> S9-C pode mergiar ANTES de S9-B — o modal fica pronto esperando o trigger do S9-B.

---

## Step 1 — Estado inicial

**Arquivo:** `app/frontend/11-APP-app.js`

Localizar o bloco de estado `ui: {}` e `data: {}` no `app()`. Adicionar:

```javascript
// data: {}
waTriageTopics: [],
waTriageCount: 0,
waSavedSegments: [],

// ui: {}
waTaskExtract: {
  open: false,
  msg: null,
  titulo: '',
  prioridade: 'normal',
  data_fim: '',
  saving: false,
},
waTriageLoading: false,
waTriageAssigning: null,
waSavedSegmentActive: null,
waSaveSegmentModal: { open: false, name: '' },
```

> Se S9-B já mergiou, parte desse estado já existe — usar `ADD COLUMN IF NOT EXISTS` mental: só adicionar o que falta.

---

## Step 2 — Task Extraction

### 2.1 Métodos em `app/frontend/11-APP-app.js`

Adicionar bloco `// === WA TASK EXTRACTION (S9-C) ===` após os helpers SLA (ou após os métodos S9-B se já mergiados):

```javascript
// === WA TASK EXTRACTION (S9-C) ===

openWaTaskExtract(msg) {
  const titulo = (msg?.content_text || '').slice(0, 80);
  this.ui.waTaskExtract = {
    open: true,
    msg,
    titulo,
    prioridade: 'normal',
    data_fim: '',
    saving: false,
  };
},

closeWaTaskExtract() {
  this.ui.waTaskExtract = { open: false, msg: null, titulo: '', prioridade: 'normal', data_fim: '', saving: false };
},

async submitWaTaskExtract() {
  const { msg, titulo, prioridade, data_fim } = this.ui.waTaskExtract;
  if (!titulo.trim()) {
    this.toast('Título obrigatório', 'warning');
    return;
  }
  this.ui.waTaskExtract.saving = true;
  try {
    const mentoradoId = this.ui.waInbox?.mentoradoId || null;
    const mentee      = (this.data.mentees || []).find(m => m.id === mentoradoId);
    const payload = {
      titulo:            titulo.trim(),
      status:            'pendente',
      prioridade,
      mentorado_id:      mentoradoId,
      mentorado_nome:    mentee?.nome || null,
      source_message_id: msg?.id           || null,
      source_topic_id:   msg?.topic_id     || null,
      data_fim:          data_fim          || null,
      created_by:        this.auth?.currentUser?.email || null,
    };
    const { error } = await sb.from('god_tasks').insert(payload);
    if (error) throw error;
    this.toast('Tarefa criada!', 'success');
    this.closeWaTaskExtract();
  } catch (e) {
    console.error('[Spalla] submitWaTaskExtract error:', e);
    this.toast('Erro ao criar tarefa: ' + e.message, 'error');
  } finally {
    this.ui.waTaskExtract.saving = false;
  }
},
```

### 2.2 HTML modal em `app/frontend/10-APP-index.html`

Adicionar antes do fechamento do `</body>` (ou junto com outros modais):

```html
<!-- Modal: WA Task Extraction (S9-C) -->
<div
  x-show="ui.waTaskExtract.open"
  class="modal-overlay"
  @click.self="closeWaTaskExtract()"
  @keydown.escape.window="closeWaTaskExtract()"
>
  <div class="modal-card" style="max-width:480px">
    <div class="modal-header">
      <h3>Criar Tarefa da Conversa</h3>
      <button @click="closeWaTaskExtract()">✕</button>
    </div>
    <div class="modal-body" style="display:flex;flex-direction:column;gap:12px">
      <!-- Mensagem origem -->
      <div class="extract-source" x-show="ui.waTaskExtract.msg?.content_text">
        <span style="font-size:11px;color:#64748b;font-weight:500">MENSAGEM ORIGEM</span>
        <p style="font-size:13px;color:#374151;margin:4px 0 0;padding:8px;background:#f8fafc;border-radius:6px;border-left:3px solid #3b82f6"
           x-text="(ui.waTaskExtract.msg?.content_text || '').slice(0, 140)"></p>
      </div>
      <!-- Título -->
      <div>
        <label style="font-size:12px;font-weight:500;color:#374151">Título</label>
        <input
          type="text"
          x-model="ui.waTaskExtract.titulo"
          placeholder="Descreva a tarefa..."
          maxlength="200"
          class="form-input"
          style="width:100%;margin-top:4px"
          autofocus
        />
      </div>
      <!-- Prioridade + Data -->
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
        <div>
          <label style="font-size:12px;font-weight:500;color:#374151">Prioridade</label>
          <select x-model="ui.waTaskExtract.prioridade" class="form-input" style="width:100%;margin-top:4px">
            <option value="baixa">Baixa</option>
            <option value="normal">Normal</option>
            <option value="alta">Alta</option>
            <option value="urgente">Urgente</option>
          </select>
        </div>
        <div>
          <label style="font-size:12px;font-weight:500;color:#374151">Data limite</label>
          <input type="date" x-model="ui.waTaskExtract.data_fim" class="form-input" style="width:100%;margin-top:4px" />
        </div>
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn-secondary" @click="closeWaTaskExtract()">Cancelar</button>
      <button
        class="btn-primary"
        @click="submitWaTaskExtract()"
        :disabled="ui.waTaskExtract.saving || !ui.waTaskExtract.titulo.trim()"
      >
        <span x-text="ui.waTaskExtract.saving ? 'Salvando...' : 'Criar Tarefa'"></span>
      </button>
    </div>
  </div>
</div>
```

---

## Step 3 — Triage Inbox

### 3.1 Métodos em `app/frontend/11-APP-app.js`

Adicionar bloco `// === WA TRIAGE (S9-C) ===`:

```javascript
// === WA TRIAGE (S9-C) ===

async loadWaTriage() {
  this.ui.waTriageLoading = true;
  try {
    const { data, error } = await sb
      .from('wa_topics')
      .select('id,group_jid,title,summary,last_message_at,message_count,status')
      .is('mentorado_id', null)
      .neq('status', 'archived')
      .order('last_message_at', { ascending: false });
    if (error) throw error;
    this.data.waTriageTopics = data || [];
    this.data.waTriageCount  = (data || []).length;
  } catch (e) {
    console.error('[Spalla] loadWaTriage error:', e);
    this.data.waTriageTopics = [];
    this.data.waTriageCount  = 0;
  } finally {
    this.ui.waTriageLoading = false;
  }
},

async assignWaTriageTopic(topicId, groupJid, mentoradoId) {
  if (!mentoradoId) return;
  this.ui.waTriageAssigning = topicId;
  try {
    const { error } = await sb.from('wa_topics')
      .update({ mentorado_id: parseInt(mentoradoId, 10) })
      .eq('id', topicId);
    if (error) throw error;
    // Atualiza grupo_whatsapp_id do mentorado
    await this.patchMentee(parseInt(mentoradoId, 10), { grupo_whatsapp_id: groupJid });
    this.toast('Tópico vinculado!', 'success');
    this.data.waTriageTopics = this.data.waTriageTopics.filter(t => t.id !== topicId);
    this.data.waTriageCount  = this.data.waTriageTopics.length;
  } catch (e) {
    console.error('[Spalla] assignWaTriageTopic error:', e);
    this.toast('Erro ao vincular: ' + e.message, 'error');
  } finally {
    this.ui.waTriageAssigning = null;
  }
},
```

### 3.2 HTML — seção triage no módulo WA

Localizar onde as tabs/views do módulo WA são renderizadas. Adicionar tab "Triage" e seu conteúdo:

```html
<!-- Tab button triage -->
<button @click="ui.waView = 'triage'; loadWaTriage()"
        x-bind:class="ui.waView === 'triage' ? 'tab-active' : ''">
  Triage
  <span x-show="data.waTriageCount > 0"
        class="triage-count-badge"
        x-text="data.waTriageCount"></span>
</button>

<!-- Triage content -->
<div x-show="ui.waView === 'triage'">
  <div x-show="ui.waTriageLoading" style="padding:24px;text-align:center;color:#64748b">
    Carregando...
  </div>
  <div x-show="!ui.waTriageLoading && data.waTriageTopics.length === 0"
       style="padding:24px;text-align:center;color:#64748b">
    Nenhum tópico pendente de vinculação.
  </div>
  <template x-for="t in data.waTriageTopics" :key="t.id">
    <div class="triage-item">
      <div class="triage-info">
        <span class="triage-jid" x-text="t.group_jid"></span>
        <span class="triage-title" x-text="t.title || 'Sem título'"></span>
        <span class="triage-meta">
          <span x-text="(t.message_count || 0) + ' mensagens'"></span>
          <span x-show="t.last_message_at" x-text="' · ' + _waInboxMsgTime(t.last_message_at)"></span>
        </span>
        <p x-show="t.summary" class="triage-summary" x-text="(t.summary || '').slice(0, 120)"></p>
      </div>
      <div class="triage-action">
        <select
          @change="assignWaTriageTopic(t.id, t.group_jid, $event.target.value)"
          :disabled="ui.waTriageAssigning === t.id"
          class="form-input"
          style="width:200px"
        >
          <option value="">Vincular a mentorado...</option>
          <template x-for="m in data.mentees" :key="m.id">
            <option :value="m.id" x-text="m.nome"></option>
          </template>
        </select>
        <span x-show="ui.waTriageAssigning === t.id" style="font-size:12px;color:#64748b">Vinculando...</span>
      </div>
    </div>
  </template>
</div>
```

---

## Step 4 — Saved Segments

### 4.1 Métodos em `app/frontend/11-APP-app.js`

Adicionar bloco `// === WA SAVED SEGMENTS (S9-C) ===`:

```javascript
// === WA SAVED SEGMENTS (S9-C) ===

async loadWaSavedSegments() {
  const email = this.auth?.currentUser?.email || '';
  try {
    const { data } = await sb.from('wa_saved_segments')
      .select('id,name,filters,is_shared,owner_email')
      .or(`is_shared.eq.true,owner_email.eq.${email}`)
      .order('created_at', { ascending: false });
    this.data.waSavedSegments = data || [];
  } catch (e) {
    this.data.waSavedSegments = [];
  }
},

applyWaSegment(segment) {
  this.ui.waSavedSegmentActive = segment.id;
  const f = segment.filters || {};
  this.ui.waPortfolioFaseFilter   = f.fase_jornada  || '';
  this.ui.waPortfolioHealthFilter = f.health_status || '';
},

clearWaSegment() {
  this.ui.waSavedSegmentActive    = null;
  this.ui.waPortfolioFaseFilter   = '';
  this.ui.waPortfolioHealthFilter = '';
},

async saveCurrentWaSegment() {
  const name = (this.ui.waSaveSegmentModal.name || '').trim();
  if (!name) { this.toast('Nome obrigatório', 'warning'); return; }
  const filters = {};
  if (this.ui.waPortfolioFaseFilter)   filters.fase_jornada  = this.ui.waPortfolioFaseFilter;
  if (this.ui.waPortfolioHealthFilter) filters.health_status = this.ui.waPortfolioHealthFilter;
  const { error } = await sb.from('wa_saved_segments').insert({
    name,
    filters,
    is_shared:   false,
    owner_email: this.auth?.currentUser?.email || '',
  });
  if (error) { this.toast('Erro ao salvar filtro', 'error'); return; }
  this.toast('Filtro salvo!', 'success');
  this.ui.waSaveSegmentModal = { open: false, name: '' };
  await this.loadWaSavedSegments();
},

async deleteWaSegment(id) {
  const { error } = await sb.from('wa_saved_segments').delete().eq('id', id);
  if (error) { this.toast('Erro ao remover', 'error'); return; }
  this.data.waSavedSegments = this.data.waSavedSegments.filter(s => s.id !== id);
  if (this.ui.waSavedSegmentActive === id) this.clearWaSegment();
},
```

### 4.2 HTML — chips acima dos filtros da Carteira

Localizar a seção de filtros da `waPortfolioMentees` no HTML. Adicionar antes dos filtros:

```html
<!-- Saved Segments chips (S9-C) -->
<div class="segments-row"
     x-show="data.waSavedSegments.length > 0 || ui.waPortfolioFaseFilter || ui.waPortfolioHealthFilter"
     x-init="loadWaSavedSegments()">
  <template x-for="s in data.waSavedSegments" :key="s.id">
    <div class="segment-chip"
         :class="ui.waSavedSegmentActive === s.id ? 'chip-active' : ''"
         @click="applyWaSegment(s)">
      <span x-text="s.name"></span>
      <button
        x-show="s.owner_email === auth?.currentUser?.email"
        @click.stop="deleteWaSegment(s.id)"
        class="chip-delete"
        title="Remover filtro">✕</button>
    </div>
  </template>

  <button
    x-show="(ui.waPortfolioFaseFilter || ui.waPortfolioHealthFilter) && !ui.waSavedSegmentActive"
    class="segment-save-btn"
    @click="ui.waSaveSegmentModal = { open: true, name: '' }">
    + Salvar filtro
  </button>

  <button x-show="ui.waSavedSegmentActive" class="segment-clear-btn" @click="clearWaSegment()">
    × Limpar
  </button>
</div>

<!-- Modal: salvar segment -->
<div x-show="ui.waSaveSegmentModal.open" class="modal-overlay"
     @click.self="ui.waSaveSegmentModal.open = false"
     @keydown.escape.window="ui.waSaveSegmentModal.open = false">
  <div class="modal-card" style="max-width:360px">
    <div class="modal-header">
      <h3>Salvar filtro atual</h3>
      <button @click="ui.waSaveSegmentModal.open = false">✕</button>
    </div>
    <div class="modal-body">
      <input
        type="text"
        x-model="ui.waSaveSegmentModal.name"
        placeholder="Ex: Onboarding em risco"
        class="form-input"
        style="width:100%"
        @keydown.enter="saveCurrentWaSegment()"
        autofocus
      />
    </div>
    <div class="modal-footer">
      <button class="btn-secondary" @click="ui.waSaveSegmentModal.open = false">Cancelar</button>
      <button class="btn-primary" @click="saveCurrentWaSegment()">Salvar</button>
    </div>
  </div>
</div>
```

---

## Step 5 — CSS

Adicionar ao bloco de estilos WA em `index.html`:

```css
/* === S9-C: Task Extraction + Triage + Segments === */

/* Triage */
.triage-item { display:flex; justify-content:space-between; align-items:flex-start; gap:16px; padding:12px 16px; border-bottom:1px solid #f1f5f9; }
.triage-info { flex:1; min-width:0; }
.triage-jid  { font-size:11px; color:#94a3b8; font-family:monospace; display:block; margin-bottom:2px; }
.triage-title { font-size:13px; font-weight:600; color:#1e293b; display:block; }
.triage-meta  { font-size:11px; color:#64748b; display:block; margin-top:2px; }
.triage-summary { font-size:12px; color:#475569; margin:4px 0 0; }
.triage-count-badge { background:#ef4444; color:#fff; border-radius:10px; font-size:10px; font-weight:700; padding:1px 6px; margin-left:4px; }

/* Saved Segments */
.segments-row { display:flex; flex-wrap:wrap; gap:8px; align-items:center; margin-bottom:12px; }
.segment-chip { display:inline-flex; align-items:center; gap:4px; padding:4px 10px; border-radius:16px; background:#f1f5f9; color:#475569; font-size:12px; font-weight:500; cursor:pointer; border:1px solid #e2e8f0; transition:all .15s; }
.segment-chip:hover { background:#e2e8f0; }
.segment-chip.chip-active { background:#dbeafe; color:#1d4ed8; border-color:#93c5fd; }
.chip-delete { background:none; border:none; color:inherit; cursor:pointer; padding:0 2px; opacity:.6; }
.chip-delete:hover { opacity:1; }
.segment-save-btn { font-size:12px; color:#3b82f6; background:none; border:1px dashed #93c5fd; padding:4px 10px; border-radius:16px; cursor:pointer; }
.segment-clear-btn { font-size:12px; color:#64748b; background:none; border:none; cursor:pointer; }

/* Extract source box */
.extract-source { padding:8px 12px; background:#f8fafc; border-radius:6px; border-left:3px solid #3b82f6; }
```

---

## Step 6 — Commit + PR

```bash
git add app/frontend/10-APP-index.html app/frontend/11-APP-app.js spec.md plan.md
git commit -m "feat(wa): S9-C — task extraction + triage inbox + saved segments"
git push -u origin feature/case/wa-task-triage
gh pr create --base develop
```

> **Merge order:** S9-B mergeia antes de S9-C para garantir que o botão `⊕` existe no chat.
> S9-C pode ser desenvolvido em paralelo — o modal fica pronto esperando o trigger.
