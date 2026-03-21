---
title: WA Task Triage — Spec
worktree: wt-wa-task-triage
branch: feature/case/wa-task-triage
sprint: S9-C
status: ready
created: 2026-03-21
---

# Spec — WA Task Extraction + Triage + Saved Segments

## 1. Objetivo

Features de produtividade do WA v2. Pode rodar em paralelo com S9-B após PR #76 mergiado.
Escopo: frontend (`app.js` + `index.html`) + backend (`14-APP-server.py`) para saved-segments.

---

## 2. Descobertas do Código Existente

### `convertTopicToTask()` — padrão para task creation (app.js ~5232)

```javascript
// EXISTENTE: usa sb.from('god_tasks').insert() DIRETAMENTE
const taskData = {
  titulo: topic.title,
  status: 'pendente',
  prioridade: 'media',
  created_by: this.auth?.currentUser?.email || null,
};
const { data: task, error } = await sb.from('god_tasks').insert(taskData).select().single();
```

**Decisão S9-C:** Task extraction NÃO usa backend endpoint — usa `sb.from('god_tasks').insert()` diretamente (consistente com `convertTopicToTask`), adicionando `source_message_id` + `source_topic_id` (colunas criadas em S9-A).

### Padrão de modal existente
Modais usam `this.ui.digestModal = { open: true/false, ... }` — estado no objeto `ui`.
`x-show="ui.digestModal.open"` no HTML.

### `wa_topics` direto via Supabase
`updateTopicStatus()` e `openWaTopic()` usam `sb.from('wa_topics')` diretamente.
`waTriageInbox` seguirá o mesmo padrão.

### Saved segments — decisão de arquitetura
**Original:** backend endpoints `GET/POST/DELETE /api/wa/saved-segments`.
**Decisão S9-C:** usar Supabase direto (`sb.from('wa_saved_segments')`) — RLS permissivo, consistente com todos os outros inserts no frontend. Evita 3 novos handlers no backend sem razão técnica.

---

## 3. Features

### 3.1 Task Extraction — Modal (Front/Linear pattern)

**Trigger:** botão `⊕` ao hover numa mensagem no `waInboxView` (implementado em S9-B como `@click="ui.waTaskExtract = { open: true, msg }"`).

**Estado:**
```javascript
// this.ui
waTaskExtract: {
  open: false,
  msg: null,        // objeto wa_message completo
  titulo: '',       // pré-preenchido com msg.content_text (truncado)
  prioridade: 'normal',
  data_fim: '',
  saving: false,
},
```

**Métodos:**

```javascript
openWaTaskExtract(msg) {
  const titulo = (msg.content_text || '').slice(0, 80);
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
    const mentee = (this.data.mentees || []).find(m => m.id === mentoradoId);
    const { data: task, error } = await sb.from('god_tasks').insert({
      titulo: titulo.trim(),
      status: 'pendente',
      prioridade,
      mentorado_id:    mentoradoId,
      mentorado_nome:  mentee?.nome || null,
      source_message_id: msg.id,
      source_topic_id:   msg.topic_id || null,
      data_fim:        data_fim || null,
      created_by:      this.auth?.currentUser?.email || null,
    }).select().single();
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

**HTML — modal de task extraction:**
```html
<!-- Modal Task Extraction -->
<div x-show="ui.waTaskExtract.open" class="modal-overlay" @click.self="closeWaTaskExtract()">
  <div class="modal-card">
    <div class="modal-header">
      <h3>Criar Tarefa</h3>
      <button @click="closeWaTaskExtract()">✕</button>
    </div>
    <div class="modal-body">
      <!-- Mensagem de origem -->
      <div class="extract-source" x-show="ui.waTaskExtract.msg">
        <span class="extract-label">Mensagem origem:</span>
        <span class="extract-msg" x-text="(ui.waTaskExtract.msg?.content_text || '').slice(0, 120)"></span>
      </div>
      <!-- Título -->
      <label>Título</label>
      <input type="text" x-model="ui.waTaskExtract.titulo" placeholder="Descrição da tarefa..." maxlength="200" />
      <!-- Prioridade -->
      <label>Prioridade</label>
      <select x-model="ui.waTaskExtract.prioridade">
        <option value="baixa">Baixa</option>
        <option value="normal">Normal</option>
        <option value="alta">Alta</option>
        <option value="urgente">Urgente</option>
      </select>
      <!-- Data fim -->
      <label>Data limite (opcional)</label>
      <input type="date" x-model="ui.waTaskExtract.data_fim" />
    </div>
    <div class="modal-footer">
      <button @click="closeWaTaskExtract()">Cancelar</button>
      <button class="btn-primary" @click="submitWaTaskExtract()" x-bind:disabled="ui.waTaskExtract.saving">
        <span x-text="ui.waTaskExtract.saving ? 'Salvando...' : 'Criar Tarefa'"></span>
      </button>
    </div>
  </div>
</div>
```

---

### 3.2 waTriageInbox — Tópicos sem mentorado (Linear pattern)

**O que é:** `wa_topics WHERE mentorado_id IS NULL AND status != 'archived'` — grupos cujo N8N não conseguiu mapear grupo → mentorado.

**Estado:**
```javascript
// this.data
waTriageTopics: [],
waTriageCount: 0,
// this.ui
waTriageLoading: false,
waTriageAssigning: null,  // topic_id em processo de assignment
```

**Métodos:**
```javascript
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
    this.data.waTriageCount = (data || []).length;
  } catch (e) {
    console.error('[Spalla] loadWaTriage error:', e);
    this.data.waTriageTopics = [];
    this.data.waTriageCount = 0;
  } finally {
    this.ui.waTriageLoading = false;
  }
},

async assignWaTriageTopic(topicId, groupJid, mentoradoId) {
  if (!mentoradoId) return;
  this.ui.waTriageAssigning = topicId;
  try {
    // 1. Vincular tópico ao mentorado
    const { error: e1 } = await sb.from('wa_topics')
      .update({ mentorado_id: mentoradoId })
      .eq('id', topicId);
    if (e1) throw e1;

    // 2. Atualizar grupo_whatsapp_id no mentorado
    await this.patchMentee(mentoradoId, { grupo_whatsapp_id: groupJid });

    this.toast('Tópico vinculado!', 'success');
    // Remover da lista local
    this.data.waTriageTopics = this.data.waTriageTopics.filter(t => t.id !== topicId);
    this.data.waTriageCount = this.data.waTriageTopics.length;
  } catch (e) {
    console.error('[Spalla] assignWaTriageTopic error:', e);
    this.toast('Erro ao vincular: ' + e.message, 'error');
  } finally {
    this.ui.waTriageAssigning = null;
  }
},
```

**Badge na sidebar WA** (indicador de itens a triagem):
```html
<!-- Badge no botão/tab da triage -->
<span
  x-show="data.waTriageCount > 0"
  class="triage-badge"
  x-text="'Triage (' + data.waTriageCount + ')'"
></span>
```

**HTML — lista de triage:**
```html
<div x-show="ui.waView === 'triage'">
  <div x-show="ui.waTriageLoading">Carregando...</div>
  <div x-show="!ui.waTriageLoading && data.waTriageTopics.length === 0">
    Nenhum tópico pendente de vinculação.
  </div>
  <template x-for="t in data.waTriageTopics" :key="t.id">
    <div class="triage-item">
      <div class="triage-info">
        <span class="triage-jid" x-text="t.group_jid"></span>
        <span class="triage-title" x-text="t.title"></span>
        <span class="triage-summary" x-text="t.summary"></span>
        <span class="triage-msgs" x-text="t.message_count + ' msgs'"></span>
      </div>
      <div class="triage-action">
        <!-- Dropdown de mentorados para vincular -->
        <select @change="assignWaTriageTopic(t.id, t.group_jid, $event.target.value)">
          <option value="">Vincular a mentorado...</option>
          <template x-for="m in data.mentees" :key="m.id">
            <option :value="m.id" x-text="m.nome"></option>
          </template>
        </select>
      </div>
    </div>
  </template>
</div>
```

---

### 3.3 waSavedSegments — Filter presets (Respond.io pattern)

**Estado:**
```javascript
// this.data
waSavedSegments: [],
// this.ui
waSavedSegmentActive: null,    // id do segment ativo
waSaveSegmentModal: { open: false, name: '' },
```

**Métodos:**
```javascript
async loadWaSavedSegments() {
  const email = this.auth?.currentUser?.email || '';
  const { data } = await sb.from('wa_saved_segments')
    .select('id,name,filters,is_shared,owner_email')
    .or(`is_shared.eq.true,owner_email.eq.${email}`)
    .order('created_at', { ascending: false });
  this.data.waSavedSegments = data || [];
},

applyWaSegment(segment) {
  this.ui.waSavedSegmentActive = segment.id;
  const f = segment.filters || {};
  // Aplica nos filtros existentes da Carteira
  if (f.fase_jornada)   this.ui.waPortfolioFaseFilter   = f.fase_jornada;
  if (f.health_status)  this.ui.waPortfolioHealthFilter = f.health_status;
  // Limpa filtros não incluídos no segment
  if (!f.fase_jornada)  this.ui.waPortfolioFaseFilter   = '';
  if (!f.health_status) this.ui.waPortfolioHealthFilter = '';
},

clearWaSegment() {
  this.ui.waSavedSegmentActive = null;
  this.ui.waPortfolioFaseFilter   = '';
  this.ui.waPortfolioHealthFilter = '';
},

async saveCurrentWaSegment() {
  const name = this.ui.waSaveSegmentModal.name.trim();
  if (!name) { this.toast('Nome obrigatório', 'warning'); return; }
  const filters = {};
  if (this.ui.waPortfolioFaseFilter)   filters.fase_jornada  = this.ui.waPortfolioFaseFilter;
  if (this.ui.waPortfolioHealthFilter) filters.health_status = this.ui.waPortfolioHealthFilter;
  const { error } = await sb.from('wa_saved_segments').insert({
    name,
    filters,
    is_shared: false,
    owner_email: this.auth?.currentUser?.email || '',
  });
  if (error) { this.toast('Erro ao salvar', 'error'); return; }
  this.toast('Filtro salvo!', 'success');
  this.ui.waSaveSegmentModal = { open: false, name: '' };
  await this.loadWaSavedSegments();
},

async deleteWaSegment(id) {
  await sb.from('wa_saved_segments').delete().eq('id', id);
  this.data.waSavedSegments = this.data.waSavedSegments.filter(s => s.id !== id);
  if (this.ui.waSavedSegmentActive === id) this.clearWaSegment();
},
```

**HTML — chips de segments acima dos filtros:**
```html
<!-- Saved Segments row -->
<div class="segments-row" x-show="data.waSavedSegments.length > 0 || ui.waPortfolioFaseFilter || ui.waPortfolioHealthFilter">
  <template x-for="s in data.waSavedSegments" :key="s.id">
    <div
      class="segment-chip"
      x-bind:class="ui.waSavedSegmentActive === s.id ? 'chip-active' : ''"
      @click="applyWaSegment(s)"
    >
      <span x-text="s.name"></span>
      <button
        x-show="s.owner_email === auth?.currentUser?.email"
        @click.stop="deleteWaSegment(s.id)"
        class="chip-delete"
      >✕</button>
    </div>
  </template>

  <!-- Botão salvar filtro atual (só aparece se há algum filtro ativo) -->
  <button
    x-show="ui.waPortfolioFaseFilter || ui.waPortfolioHealthFilter"
    class="segment-save-btn"
    @click="ui.waSaveSegmentModal = { open: true, name: '' }"
  >+ Salvar filtro</button>

  <!-- Limpar segment ativo -->
  <button x-show="ui.waSavedSegmentActive" class="segment-clear-btn" @click="clearWaSegment()">
    Limpar
  </button>
</div>

<!-- Modal: salvar segment -->
<div x-show="ui.waSaveSegmentModal.open" class="modal-overlay" @click.self="ui.waSaveSegmentModal.open = false">
  <div class="modal-card" style="max-width:360px">
    <div class="modal-header"><h3>Salvar filtro atual</h3></div>
    <div class="modal-body">
      <input type="text" x-model="ui.waSaveSegmentModal.name" placeholder="Ex: Onboarding em risco" @keydown.enter="saveCurrentWaSegment()" />
    </div>
    <div class="modal-footer">
      <button @click="ui.waSaveSegmentModal.open = false">Cancelar</button>
      <button class="btn-primary" @click="saveCurrentWaSegment()">Salvar</button>
    </div>
  </div>
</div>
```

---

## 4. Arquivos a Modificar

| Arquivo | Ação | Tamanho estimado |
|---------|------|-----------------|
| `app/frontend/11-APP-app.js` | ADD — 8 métodos + estado | +~120 linhas |
| `app/frontend/10-APP-index.html` | ADD — modal extraction + triage HTML + segments HTML + CSS | +~100 linhas |

**Não tocar:** `supabase/`, `app/backend/`

---

## 5. Integração com S9-B (coordenação de branches)

O botão `⊕` (task extraction trigger) é renderizado no template do `waInboxView` — feature de S9-B.
Quando S9-B mergear, S9-C já tem o handler `submitWaTaskExtract()` pronto.

**Contrato de interface S9-B → S9-C:**
- S9-B adiciona no template de mensagem: `@click="openWaTaskExtract(msg)"`
- S9-C implementa `openWaTaskExtract()`, `submitWaTaskExtract()`, e o modal HTML

Se as branches rodam em paralelo antes do merge, S9-C mergeia depois de S9-B para garantir que o botão existe.

---

## 6. Pré-condições (verificar antes de codar)

- [ ] `god_tasks.source_topic_id` e `source_message_id` existem (PR #76 mergiado)
- [ ] `wa_saved_segments` existe com RLS permissivo
- [ ] `wa_topics WHERE mentorado_id IS NULL` retorna rows (pode estar vazio — ok)
- [ ] `this.patchMentee()` existe em app.js (existe — linha ~4969 ✅)
