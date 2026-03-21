---
title: "PLAN-6.0 — WhatsApp Management Module"
type: implementation-plan
status: draft
spec: SPEC-6.0-wa-management-module.md
date: 2026-03-20
bu: BU-CASE
project: spalla-dashboard
epic: 6
---

# PLAN-6.0 — WhatsApp Management Module

## Visão Geral

4 fases, 12 stories, ~4 sprints. Cada fase entrega valor incremental e testável.

```
Fase 1 → Backend Foundation (SQL + 3 endpoints)
Fase 2 → Carteira Grid (core UI funcional)
Fase 3 → Scale Layer (inbox + bulk + snooze)
Fase 4 → Full Board (kanban + notas + digest)
```

**Princípio de execução:** Nenhuma fase começa sem a anterior estar com CI verde. Cada story é uma branch isolada. Merge via PR para `develop`.

---

## Fase 1 — Backend Foundation

**Goal:** Toda a camada de dados e APIs prontas antes do primeiro pixel de frontend. Frontend da Fase 2 não espera por nada.

**Exit criteria:**
- [ ] Migration rodada em staging, schema verificado
- [ ] `GET /api/mentees/portfolio` retorna dados reais com JOINs corretos
- [ ] `PATCH /api/mentees/{id}` atualiza `fase_mentoria` e `snoozed_until`
- [ ] `PATCH /api/mentees/bulk` atualiza N ids em única query
- [ ] `GET` + `POST /api/mentees/{id}/notes` funcionando com todos os 4 tipos
- [ ] Zero rotas quebradas nas existentes (regressão manual)

### S6.1 — Migration: `mentee_notes` + `snoozed_until`

**Branch:** `feature/s6.1-migration-mentee-notes`

**Arquivo a criar:**
- `app/backend/migrations/006_mentee_notes_and_snooze.sql`

**Conteúdo:**
```sql
-- 1. Adiciona coluna snooze na tabela existente (additive, nullable)
ALTER TABLE mentorados
  ADD COLUMN IF NOT EXISTS snoozed_until TIMESTAMPTZ DEFAULT NULL;

CREATE INDEX idx_mentorados_snoozed ON mentorados(snoozed_until)
  WHERE snoozed_until IS NOT NULL;

-- 2. Nova tabela de notas estruturadas
CREATE TABLE mentee_notes (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mentorado_id    BIGINT NOT NULL REFERENCES mentorados(id) ON DELETE CASCADE,
  created_by_uid  UUID NOT NULL REFERENCES auth.users(id),
  created_by_name TEXT NOT NULL,
  type            TEXT NOT NULL CHECK (type IN (
                    'checkpoint_mensal',
                    'feedback_aula',
                    'registro_ligacao',
                    'nota_livre'
                  )),
  data            JSONB NOT NULL DEFAULT '{}',
  tags            TEXT[] DEFAULT '{}',
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_mentee_notes_mentorado ON mentee_notes(mentorado_id, created_at DESC);
CREATE INDEX idx_mentee_notes_type ON mentee_notes(type);

-- RLS
ALTER TABLE mentee_notes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "authenticated can read notes" ON mentee_notes
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "authenticated can insert notes" ON mentee_notes
  FOR INSERT WITH CHECK (auth.uid() = created_by_uid);
```

**Steps:**
1. Criar o arquivo SQL com o conteúdo acima
2. Aplicar via Supabase CLI: `supabase db push` (ou SQL editor no dashboard)
3. Verificar schema no Supabase Studio: tabela `mentee_notes` existe, coluna `snoozed_until` em `mentorados`
4. Confirmar índices criados

**Arquivos modificados:** `app/backend/migrations/` (novo arquivo)
**Arquivos NÃO tocar:** qualquer arquivo fora de `migrations/`

---

### S6.2 — Backend: `GET /api/mentees/portfolio`

**Branch:** `feature/s6.2-portfolio-endpoint`

**Arquivo a modificar:** `app/backend/14-APP-server.py`

**Localização no arquivo:** Adicionar novo handler após a rota `GET /api/mentees` existente (buscar por `do_GET` e a seção de mentees).

**Steps:**
1. Localizar o handler de `GET /api/mentees` no server.py
2. Adicionar novo elif para `/api/mentees/portfolio` ANTES do handler genérico de mentees
3. Implementar query SQL com JOINs (ver abaixo)
4. Testar com curl: `curl -H "Authorization: Bearer <token>" http://localhost:9999/api/mentees/portfolio`
5. Verificar que resposta inclui todos os campos do schema da spec (seção 6.1)

**Query SQL a implementar:**
```sql
SELECT
  m.id,
  m.nome,
  m.foto_url,
  m.fase_mentoria,
  m.group_jid,
  m.snoozed_until,
  m.assignee_uid,                            -- para scoped view
  MAX(wt.last_message_at) AS last_message_at,
  (
    SELECT content FROM wa_message_queue
    WHERE group_jid = m.group_jid
    ORDER BY created_at DESC LIMIT 1
  ) AS last_message_preview,
  COUNT(DISTINCT wmq.id) FILTER (
    WHERE wmq.status = 'pending'
    AND wmq.created_at > now() - INTERVAL '7 days'
  ) AS unread_count,
  COUNT(DISTINCT wt.id) FILTER (WHERE wt.status = 'open') AS open_topics_count,
  COUNT(DISTINCT wt.id) FILTER (
    WHERE wt.status = 'open' AND wt.sentiment = 'negative'
  ) AS negative_sentiment_count,
  COUNT(DISTINCT gt.id) FILTER (
    WHERE gt.assignee_uid = :current_user_uid
    AND gt.status != 'concluida'
  ) AS pending_consultant_tasks
FROM mentorados m
LEFT JOIN wa_topics wt ON wt.group_jid = m.group_jid
LEFT JOIN wa_message_queue wmq ON wmq.group_jid = m.group_jid
LEFT JOIN god_tasks gt ON gt.mentorado_id = m.id
WHERE m.active = true   -- ajustar se coluna não existir
GROUP BY m.id
ORDER BY m.nome ASC
```

> ⚠️ Verificar nomes de colunas reais nas tabelas antes de implementar. O schema acima é baseado no mapeamento da spec — pode haver divergência de nomes de coluna.

**Regra de scoped view:** O endpoint aceita query param `?scope=me` (default) ou `?scope=all`. Com `scope=me`, filtra `WHERE m.assignee_uid = :current_user_uid` (ou equivalente na tabela). O frontend envia `scope` baseado em `ui.carteiraFilter.consultor`.

**Arquivos modificados:** `app/backend/14-APP-server.py` (adição de rota)
**Arquivos NÃO tocar:** frontend, migrations, outros endpoints

---

### S6.3 — Backend: `GET` + `POST /api/mentees/{id}/notes`

**Branch:** `feature/s6.3-notes-endpoints`

**Arquivo a modificar:** `app/backend/14-APP-server.py`

**Steps:**
1. Adicionar handler para `GET /api/mentees/{id}/notes`
   - Extrai `mentee_id` do path
   - Query: `SELECT * FROM mentee_notes WHERE mentorado_id = $1 ORDER BY created_at DESC LIMIT 20`
   - Retorna `{ notes: [...] }`
2. Adicionar handler para `POST /api/mentees/{id}/notes`
   - Parse body JSON
   - Valida campo `type` contra enum (checkpoint_mensal | feedback_aula | registro_ligacao | nota_livre)
   - Extrai `created_by_name` do JWT claims ou body
   - INSERT em `mentee_notes`
   - Retorna a nota criada
3. Testar ambos os endpoints com curl

**Arquivos modificados:** `app/backend/14-APP-server.py`
**Depende de:** S6.1 (tabela `mentee_notes` deve existir)

---

### S6.4 — Backend: `PATCH /api/mentees/{id}`

**Branch:** `feature/s6.4-patch-mentee`

**Arquivo a modificar:** `app/backend/14-APP-server.py`

**Steps:**
1. Verificar se já existe handler `PATCH` no server.py (buscar por `do_PATCH` ou `'PATCH'`)
2. Adicionar handler para `PATCH /api/mentees/{id}`
3. Campos permitidos: `fase_mentoria` (enum validado), `snoozed_until` (ISO datetime ou null)
4. Rejeitar qualquer campo fora da allowlist com 400
5. UPDATE na tabela `mentorados`, retorna o registro atualizado

**Arquivos modificados:** `app/backend/14-APP-server.py`
**Depende de:** S6.1 (coluna `snoozed_until` deve existir)

---

### S6.5 — Backend: `PATCH /api/mentees/bulk`

**Branch:** `feature/s6.5-bulk-endpoint`

**Arquivo a modificar:** `app/backend/14-APP-server.py`

> ⚠️ Esta rota DEVE ser registrada ANTES do handler de `PATCH /api/mentees/{id}` para evitar que `/bulk` seja capturado como `{id}`.

**Steps:**
1. Adicionar handler para `PATCH /api/mentees/bulk`
2. Parse body: `{ ids: [int], fase_mentoria?: str, snoozed_until?: str|null }`
3. Validar: `ids` não-vazio, max 50 elementos, exatamente um campo de update
4. Executar: `UPDATE mentorados SET <campo> = $1 WHERE id = ANY($2::bigint[])`
5. Retornar `{ updated: int, ids: [int] }`

**Arquivos modificados:** `app/backend/14-APP-server.py`
**Depende de:** S6.4 (rota PATCH já estruturada)

---

## Fase 2 — Carteira Grid (Core UI)

**Goal:** Página `carteira` funcional como view principal. Consultor logado consegue ver seus mentorados, filtrar, buscar, e ver os health signals.

**Exit criteria:**
- [ ] Nav item `carteira` aparece e navega para a página correta
- [ ] Grid renderiza cards com todos os campos (foto, nome, fase, health badge, dias, preview, unread, próxima call)
- [ ] Time-based signal badge aparece no card quando `dias_sem_interacao > 3`
- [ ] Scoped view funciona: consultor vê apenas seus mentorados por padrão
- [ ] Filtros de fase + health funcionam (AND/OR toggle)
- [ ] Busca por nome filtra em tempo real (debounce)
- [ ] Quick actions no hover: [Abrir Chat] [Nova Nota] [Ver Digest] [Snooze]
- [ ] Nenhuma feature existente quebrada (whatsapp page, wa_topics page, kanban existente)

### S6.6 — Frontend: Página Carteira — Grid View

**Branch:** `feature/s6.6-carteira-grid`

**Arquivos a modificar:**
- `app/frontend/10-APP-index.html` — adicionar nav item + HTML da página carteira
- `app/frontend/11-APP-app.js` — adicionar page handler + métodos Alpine.js

**Steps no `11-APP-app.js`:**

1. **Nav item:** Encontrar o array/objeto de nav items, inserir `carteira` entre `whatsapp` e `wa_topics`

2. **Page init:** Adicionar case para `carteira` no router:
   ```javascript
   case 'carteira':
     await this.loadCarteira()
     this.initKeyboardShortcuts()
     break
   ```

3. **`loadCarteira()`:**
   ```javascript
   async loadCarteira() {
     const scope = this.ui.carteiraFilter.consultor === 'me' ? 'me' : 'all'
     const res = await this.apiGet(`/api/mentees/portfolio?scope=${scope}`)
     this.data.carteira = res.mentees || []
   }
   ```

4. **`getHealthStatus(mentee)`:**
   ```javascript
   getHealthStatus(mentee) {
     const d = mentee.dias_sem_interacao
     if (d <= 3) return 'green'
     if (d <= 7) return 'yellow'
     return 'red'
   }
   ```

5. **`getTimeSinceLabel(mentee)`:**
   ```javascript
   getTimeSinceLabel(mentee) {
     if (mentee.dias_sem_interacao <= 3) return null
     return `Sem resposta há ${mentee.dias_sem_interacao} dias`
   }
   ```

6. **`carteiraFiltrada` (computed getter):**
   - Filtra `snoozed_until > now()` (ocultar snoozed)
   - Aplica filtros de fase, health, consultor
   - Aplica busca por nome (toLowerCase includes)
   - Respeita `ui.carteiraFilter.logic` (AND/OR)
   - Retorna array filtrado

7. **`carteiraSnooze` (computed getter):**
   - Retorna mentorados com `snoozed_until` válido (> now)

8. **Novo state em `this.data`:** `carteira`, `undoBuffer`

9. **Novo state em `this.ui`:** `carteiraView`, `carteiraFilter`, `bulkSelected`, `snoozeOverlay`, `focusedMenteeIdx`

**Steps no `10-APP-index.html`:**

1. Adicionar nav item:
   ```html
   <li x-show="ui.nav.includes('carteira')">
     <a @click="navigate('carteira')" :class="{'active': ui.page === 'carteira'}">
       <span class="icon">👥</span> Carteira
     </a>
   </li>
   ```

2. Adicionar `<!-- ===== PAGE: CARTEIRA ===== -->` seguindo o padrão das outras páginas

3. Estrutura HTML da página carteira:
   ```
   <div class="page-content" x-show="ui.page === 'carteira'">
     <!-- Header: título + view toggles + filtros + bulk toolbar -->
     <!-- [Grid] [Inbox] [Kanban] | AND/OR | Fase ▾ | Saúde ▾ | Consultor ▾ | 🔍 -->
     <!-- Bulk toolbar (x-show="ui.bulkSelected.size > 0") -->

     <!-- Snooze counter -->
     <!-- "X snoozed · ver" -->

     <!-- Grid view (x-show="ui.carteiraView === 'grid'") -->
     <!-- template do card -->

     <!-- Inbox view (Fase 3) — placeholder -->
     <!-- Kanban view (Fase 4) — placeholder -->
   </div>
   ```

4. **Card HTML** (componente reutilizável inline):
   ```html
   <div class="mentee-card"
        :class="{ 'selected': ui.bulkSelected.has(m.id), 'health-red': getHealthStatus(m) === 'red' }"
        x-data="{ hovered: false }"
        @mouseenter="hovered = true" @mouseleave="hovered = false">

     <!-- Checkbox -->
     <input type="checkbox" :checked="ui.bulkSelected.has(m.id)"
            @change="toggleBulkSelect(m.id)">

     <!-- Foto + health badge -->
     <div class="avatar-wrapper">
       <img :src="m.foto_url" :alt="m.nome">
       <span class="health-dot" :class="'dot-' + getHealthStatus(m)"></span>
     </div>

     <!-- Info -->
     <div class="card-info">
       <h3 x-text="m.nome"></h3>
       <span class="fase-badge" x-text="m.fase"></span>
       <p class="last-msg" x-text="m.last_message_preview"></p>
       <span class="time-signal" x-show="getTimeSinceLabel(m)"
             x-text="getTimeSinceLabel(m)"></span>
     </div>

     <!-- Counters -->
     <div class="card-counters">
       <span x-show="m.unread_count > 0" x-text="m.unread_count + ' não lidas'"></span>
       <span x-show="m.next_call" x-text="'Call: ' + formatDate(m.next_call?.datetime)"></span>
     </div>

     <!-- Hover actions -->
     <div class="card-actions" x-show="hovered">
       <button @click="navigate('whatsapp', { group: m.group_jid })">Chat</button>
       <button @click="openNotaModal(m.id, 'nota_livre')">Nota</button>
       <button @click="openDigest(m.id)">Digest</button>
       <button @click="snoozeOne(m.id, 1)">Snooze</button>
     </div>
   </div>
   ```

**Arquivos modificados:**
- `app/frontend/10-APP-index.html`
- `app/frontend/11-APP-app.js`

**Depende de:** S6.2 (endpoint portfolio)

---

## Fase 3 — Scale Layer

**Goal:** Módulo funcional em escala. Inbox com ordenação por risco, bulk operations, snooze. Consul­tor consegue processar 20+ mentorados sem fricção.

**Exit criteria:**
- [ ] Inbox view reordena cards por priority score corretamente
- [ ] Toggle AND/OR no filter funciona (scope dos filtros muda)
- [ ] Compound filter combina ≥2 filtros simultaneamente
- [ ] Atalhos J/K navegam entre cards no inbox; E/N/S ativam ações
- [ ] Bulk select: checkbox seleciona, "Selecionar todos" seleciona filtrados
- [ ] Bulk toolbar aparece quando ≥1 selecionado
- [ ] Bulk Mover Fase executa PATCH /api/mentees/bulk e atualiza UI local
- [ ] Bulk Snooze remove cards da view, conta no "X snoozed"
- [ ] Snooze individual funciona no hover menu
- [ ] Undo toast aparece 30s, clicando reverte a ação
- [ ] Snoozed re-aparece quando `snoozed_until` < now (no próximo loadCarteira)

### S6.7 — Frontend: Priority Inbox + compound filter + keyboard shortcuts

**Branch:** `feature/s6.7-inbox-keyboard`

**Arquivos a modificar:**
- `app/frontend/11-APP-app.js` — novos métodos e state
- `app/frontend/10-APP-index.html` — HTML do inbox view e filter bar

**Steps no `11-APP-app.js`:**

1. **`getPriorityScore(mentee)`:**
   ```javascript
   getPriorityScore(mentee) {
     let score = 0
     score += (mentee.dias_sem_interacao || 0) * 3
     if (['onboarding', 'renovacao'].includes(mentee.fase)) score += 20
     score += (mentee.pending_consultant_tasks || 0) * 25
     score += (mentee.unread_count || 0) * 1.5
     score += (mentee.negative_sentiment_count || 0) * 10
     return Math.round(score)
   }
   ```

2. **`carteiraOrdenada` (computed getter):**
   ```javascript
   get carteiraOrdenada() {
     if (this.ui.carteiraView !== 'inbox') return this.carteiraFiltrada
     return [...this.carteiraFiltrada].sort(
       (a, b) => this.getPriorityScore(b) - this.getPriorityScore(a)
     )
   }
   ```

3. **`initKeyboardShortcuts()`:**
   ```javascript
   initKeyboardShortcuts() {
     document.addEventListener('keydown', (e) => {
       if (this.ui.page !== 'carteira') return
       if (document.activeElement.tagName === 'INPUT' ||
           document.activeElement.tagName === 'TEXTAREA') return
       if (this.ui.notaModal.open) return

       const mentees = this.carteiraOrdenada
       const idx = this.ui.focusedMenteeIdx
       const focused = mentees[idx]

       switch(e.key) {
         case 'j': case 'ArrowDown':
           e.preventDefault()
           this.ui.focusedMenteeIdx = Math.min(idx + 1, mentees.length - 1)
           break
         case 'k': case 'ArrowUp':
           e.preventDefault()
           this.ui.focusedMenteeIdx = Math.max(idx - 1, 0)
           break
         case 'e':
           if (focused) this.navigate('whatsapp', { group: focused.group_jid })
           break
         case 'n':
           if (focused) this.openNotaModal(focused.id, 'nota_livre')
           break
         case 's':
           if (focused) this.openSnoozeMenu(focused.id)
           break
         case 'x':
           if (focused) this.toggleBulkSelect(focused.id)
           break
       }
     })
   }
   ```

4. **Compound filter logic em `carteiraFiltrada`:**
   - Cada filtro ativo gera um predicate
   - `logic === 'AND'`: mentee deve passar em TODOS os predicates
   - `logic === 'OR'`: mentee deve passar em PELO MENOS UM

**Steps no `10-APP-index.html`:**

1. Adicionar filter bar completa com toggle AND/OR:
   ```html
   <div class="filter-bar">
     <span>Filtros:</span>
     <button @click="ui.carteiraFilter.logic = ui.carteiraFilter.logic === 'AND' ? 'OR' : 'AND'"
             class="logic-toggle"
             x-text="ui.carteiraFilter.logic">
     </button>
     <select x-model="ui.carteiraFilter.fase">
       <option value="">Todas as fases</option>
       <option>onboarding</option>
       <!-- ... -->
     </select>
     <select x-model="ui.carteiraFilter.health">
       <option value="">Toda saúde</option>
       <option value="red">Crítico</option>
       <option value="yellow">Atenção</option>
       <option value="green">Engajado</option>
     </select>
     <input type="search" x-model.debounce.300ms="ui.carteiraFilter.search"
            placeholder="Buscar mentorado...">
   </div>
   ```

2. Adicionar Inbox view HTML (list rows):
   ```html
   <!-- Inbox view -->
   <div x-show="ui.carteiraView === 'inbox'" class="inbox-list">
     <template x-for="m in carteiraOrdenada" :key="m.id">
       <div class="inbox-row"
            :class="{ 'focused': ui.focusedMenteeIdx === carteiraOrdenada.indexOf(m) }">
         <input type="checkbox" :checked="ui.bulkSelected.has(m.id)"
                @change="toggleBulkSelect(m.id)">
         <img :src="m.foto_url" :alt="m.nome" class="avatar-sm">
         <div class="row-info">
           <span x-text="m.nome" class="nome"></span>
           <span class="time-signal" x-show="getTimeSinceLabel(m)"
                 x-text="getTimeSinceLabel(m)"></span>
         </div>
         <span class="score-badge" x-text="'Score ' + getPriorityScore(m)"></span>
         <div class="row-actions">
           <button @click="navigate('whatsapp', {group: m.group_jid})">E</button>
           <button @click="openNotaModal(m.id, 'nota_livre')">N</button>
           <button @click="openSnoozeMenu(m.id)">S</button>
         </div>
       </div>
     </template>
   </div>
   ```

---

### S6.9 — Frontend: Bulk toolbar + Snooze

**Branch:** `feature/s6.9-bulk-snooze`

**Arquivos a modificar:**
- `app/frontend/11-APP-app.js` — bulk methods, snooze methods, undo
- `app/frontend/10-APP-index.html` — bulk toolbar HTML, snooze dropdown, snooze overlay

**Steps no `11-APP-app.js`:**

1. **`toggleBulkSelect(menteeId)`:**
   ```javascript
   toggleBulkSelect(id) {
     if (this.ui.bulkSelected.has(id)) this.ui.bulkSelected.delete(id)
     else this.ui.bulkSelected.add(id)
     this.ui.bulkSelected = new Set(this.ui.bulkSelected) // trigger Alpine reactivity
   }
   ```

2. **`toggleSelectAll()`:**
   ```javascript
   toggleSelectAll() {
     if (this.ui.bulkSelected.size === this.carteiraFiltrada.length) {
       this.ui.bulkSelected = new Set()
     } else {
       this.ui.bulkSelected = new Set(this.carteiraFiltrada.map(m => m.id))
     }
   }
   ```

3. **`executeBulkAction(field, value)`:**
   ```javascript
   async executeBulkAction(field, value) {
     const ids = [...this.ui.bulkSelected]
     // salvar undo buffer
     const previous = ids.map(id => ({
       id,
       value: this.data.carteira.find(m => m.id === id)?.[field]
     }))
     this.data.undoBuffer = { ids, field, previous, expiresAt: Date.now() + 30000 }

     // atualização otimista local
     this.data.carteira = this.data.carteira.map(m =>
       ids.includes(m.id) ? { ...m, [field]: value } : m
     )
     this.ui.bulkSelected = new Set()

     // persistir
     await this.apiPatch('/api/mentees/bulk', { ids, [field]: value })
     this.showToast(`${ids.length} mentorados atualizados`, 'Desfazer', () => this.undoBulkAction())
   }
   ```

4. **`undoBulkAction()`:**
   ```javascript
   async undoBulkAction() {
     if (!this.data.undoBuffer || Date.now() > this.data.undoBuffer.expiresAt) return
     const { ids, field, previous } = this.data.undoBuffer
     // reverter local
     this.data.carteira = this.data.carteira.map(m => {
       const prev = previous.find(p => p.id === m.id)
       return prev ? { ...m, [field]: prev.value } : m
     })
     // reverter banco: cada id com seu valor anterior
     for (const { id, value } of previous) {
       await this.apiPatch(`/api/mentees/${id}`, { [field]: value })
     }
     this.data.undoBuffer = null
   }
   ```

5. **`snoozeOne(menteeId, days)`:**
   ```javascript
   async snoozeOne(id, days) {
     const until = new Date()
     until.setDate(until.getDate() + days)
     const isoUntil = until.toISOString()
     // remoção otimista
     this.data.carteira = this.data.carteira.map(m =>
       m.id === id ? { ...m, snoozed_until: isoUntil } : m
     )
     await this.apiPatch(`/api/mentees/${id}`, { snoozed_until: isoUntil })
     this.showToast(`Mentorado sonecado por ${days}d`, 'Acordar', () => this.unsnooze(id))
   }
   ```

6. **`unsnooze(menteeId)`:**
   ```javascript
   async unsnooze(id) {
     this.data.carteira = this.data.carteira.map(m =>
       m.id === id ? { ...m, snoozed_until: null } : m
     )
     await this.apiPatch(`/api/mentees/${id}`, { snoozed_until: null })
   }
   ```

**Steps no `10-APP-index.html`:**

1. **Bulk toolbar** (dentro do header da Carteira, `x-show="ui.bulkSelected.size > 0"`):
   ```html
   <div class="bulk-toolbar">
     <span x-text="ui.bulkSelected.size + ' selecionados'"></span>
     <div class="bulk-action">
       <span>Mover Fase →</span>
       <div class="dropdown">
         <button @click="executeBulkAction('fase_mentoria', 'onboarding')">Onboarding</button>
         <button @click="executeBulkAction('fase_mentoria', 'execucao')">Execução</button>
         <button @click="executeBulkAction('fase_mentoria', 'resultado')">Resultado</button>
         <button @click="executeBulkAction('fase_mentoria', 'renovacao')">Renovação</button>
         <button @click="executeBulkAction('fase_mentoria', 'alumni')">Alumni</button>
       </div>
     </div>
     <div class="bulk-action">
       <span>Snooze →</span>
       <div class="dropdown">
         <button @click="executeBulkAction('snoozed_until', snoozeDate(1))">1 dia</button>
         <button @click="executeBulkAction('snoozed_until', snoozeDate(3))">3 dias</button>
         <button @click="executeBulkAction('snoozed_until', snoozeDate(7))">7 dias</button>
       </div>
     </div>
     <button @click="clearBulkSelect()">Limpar seleção</button>
   </div>
   ```

2. **Snooze counter + overlay:**
   ```html
   <div class="snooze-counter" x-show="carteiraSnooze.length > 0">
     <button @click="ui.snoozeOverlay = true">
       <span x-text="carteiraSnooze.length + ' snoozed'"></span>
     </button>
   </div>

   <div class="snooze-overlay" x-show="ui.snoozeOverlay" @click.outside="ui.snoozeOverlay = false">
     <template x-for="m in carteiraSnooze" :key="m.id">
       <div class="snooze-row">
         <span x-text="m.nome"></span>
         <span x-text="'Volta em ' + formatDate(m.snoozed_until)"></span>
         <button @click="unsnooze(m.id)">Acordar</button>
       </div>
     </template>
   </div>
   ```

3. **Toast component** (se não existir, adicionar um genérico):
   ```html
   <div class="toast" x-show="ui.toast.open" x-transition>
     <span x-text="ui.toast.message"></span>
     <button x-show="ui.toast.actionLabel"
             x-text="ui.toast.actionLabel"
             @click="ui.toast.action?.()">
     </button>
   </div>
   ```

---

## Fase 4 — Full Board

**Goal:** Kanban funcional com drag-and-drop e bulk drag. Notas estruturadas completas. Digest por mentorado. Módulo 100% completo.

**Exit criteria:**
- [ ] Kanban renderiza colunas de fase com todos os cards
- [ ] Drag-and-drop individual funciona e persiste no banco
- [ ] Bulk drag (múltiplos selecionados) move todos para a coluna destino
- [ ] Preview tooltip aparece durante drag
- [ ] Modal de notas abre com 4 templates, salva e confirma
- [ ] Timeline de notas no detail do mentorado
- [ ] Digest panel abre com resumo dos wa_topics dos últimos 7 dias

### S6.8 — Frontend: Kanban View com bulk drag

**Branch:** `feature/s6.8-kanban`

**Arquivos a modificar:**
- `app/frontend/11-APP-app.js` — kanban methods + drag handlers
- `app/frontend/10-APP-index.html` — Kanban HTML

**Steps no `11-APP-app.js`:**

1. **`getKanbanColumns()`:**
   ```javascript
   getKanbanColumns() {
     if (this.ui.kanbanEixo === 'fase') return KANBAN_FASE_COLS
     return KANBAN_SAUDE_COLS
   }
   ```

2. **`getMenteesForColumn(colKey)`:**
   ```javascript
   getMenteesForColumn(colKey) {
     if (this.ui.kanbanEixo === 'fase') {
       return this.carteiraFiltrada.filter(m => m.fase_mentoria === colKey)
     }
     return this.carteiraFiltrada.filter(m => this.getHealthStatus(m) === colKey)
   }
   ```

3. **`onDragStart(event, menteeId)`:**
   ```javascript
   onDragStart(e, id) {
     this.ui.kanbanDragging = id
     // se id está no bulk selection, arrastar todos; senão, só esse
     const ids = this.ui.bulkSelected.has(id) ? [...this.ui.bulkSelected] : [id]
     e.dataTransfer.setData('text/plain', JSON.stringify(ids))
   }
   ```

4. **`onDrop(event, colKey)`:**
   ```javascript
   async onDrop(e, colKey) {
     e.preventDefault()
     const ids = JSON.parse(e.dataTransfer.getData('text/plain'))
     const col = this.getKanbanColumns().find(c => c.key === colKey)
     if (col?.readonly) return  // eixo saúde é read-only

     if (ids.length === 1) {
       await this.updateMenteeFase(ids[0], colKey)
     } else {
       await this.updateMenteeFaseBulk(ids, colKey)
     }
     this.ui.kanbanDragging = null
     this.ui.bulkSelected = new Set()
   }
   ```

5. Constantes no topo do app.js (ou em seção de constantes):
   ```javascript
   const KANBAN_FASE_COLS = [
     { key: 'onboarding', label: 'Onboarding',  color: '#6366f1', readonly: false },
     { key: 'execucao',   label: 'Execução',     color: '#3b82f6', readonly: false },
     { key: 'resultado',  label: 'Resultado',    color: '#22c55e', readonly: false },
     { key: 'renovacao',  label: 'Renovação',    color: '#f97316', readonly: false },
     { key: 'alumni',     label: 'Alumni/Saída', color: '#94a3b8', readonly: false },
   ]
   const KANBAN_SAUDE_COLS = [
     { key: 'red',    label: 'Crítico',  color: '#ef4444', readonly: true },
     { key: 'yellow', label: 'Atenção',  color: '#f59e0b', readonly: true },
     { key: 'green',  label: 'Engajado', color: '#22c55e', readonly: true },
   ]
   ```

**Steps no `10-APP-index.html`:**

```html
<!-- Kanban view -->
<div x-show="ui.carteiraView === 'kanban'" class="kanban-board">
  <!-- Eixo selector -->
  <div class="eixo-selector">
    <button :class="{ active: ui.kanbanEixo === 'fase' }"
            @click="ui.kanbanEixo = 'fase'">Por Fase</button>
    <button :class="{ active: ui.kanbanEixo === 'saude' }"
            @click="ui.kanbanEixo = 'saude'">Por Saúde</button>
  </div>

  <!-- Colunas -->
  <div class="kanban-columns">
    <template x-for="col in getKanbanColumns()" :key="col.key">
      <div class="kanban-column"
           :class="{ 'drop-target': ui.kanbanDraggingOver === col.key }"
           @dragover.prevent="ui.kanbanDraggingOver = col.key"
           @dragleave="ui.kanbanDraggingOver = null"
           @drop="onDrop($event, col.key)">

        <!-- Column header -->
        <div class="col-header" :style="'border-top: 3px solid ' + col.color">
          <span x-text="col.label"></span>
          <span class="count" x-text="getMenteesForColumn(col.key).length"></span>
        </div>

        <!-- Cards -->
        <template x-for="m in getMenteesForColumn(col.key)" :key="m.id">
          <div class="kanban-card"
               :draggable="!col.readonly"
               @dragstart="onDragStart($event, m.id)"
               :class="{ 'selected': ui.bulkSelected.has(m.id) }">
            <input type="checkbox" :checked="ui.bulkSelected.has(m.id)"
                   @change.stop="toggleBulkSelect(m.id)">
            <img :src="m.foto_url" :alt="m.nome" class="avatar-xs">
            <span x-text="m.nome"></span>
            <span class="health-dot" :class="'dot-' + getHealthStatus(m)"></span>
            <!-- hover actions omitidas por brevidade, igual ao grid card -->
          </div>
        </template>

        <!-- Empty state -->
        <div class="col-empty" x-show="getMenteesForColumn(col.key).length === 0">
          Nenhum mentorado aqui
        </div>
      </div>
    </template>
  </div>
</div>
```

---

### S6.10 — Frontend: Modal Notas

**Branch:** `feature/s6.10-modal-notas`

**Arquivos a modificar:**
- `app/frontend/11-APP-app.js` — nota methods
- `app/frontend/10-APP-index.html` — modal HTML

**Steps:**

1. **`openNotaModal(menteeId, type)`** e **`closeNotaModal()`** — state manipulation simples

2. **`createMenteeNote()`:**
   ```javascript
   async createMenteeNote() {
     const { menteeId, type, data } = this.ui.notaModal
     await this.apiPost(`/api/mentees/${menteeId}/notes`, { type, data, tags: [] })
     this.closeNotaModal()
     // Se timeline estiver aberta, reload notes
     if (this.data.currentMenteeId === menteeId) await this.loadMenteeNotes(menteeId)
     this.showToast('Nota salva ✓')
   }
   ```

3. **Modal HTML** (global, fora dos pages, antes de `</body>`):
   - `x-show="ui.notaModal.open"` com `x-transition`
   - Selector de tipo (4 tabs)
   - Campos dinâmicos por tipo (`x-show="ui.notaModal.type === 'checkpoint_mensal'"` etc.)
   - Botões Cancelar / Salvar Nota

---

### S6.11 — Frontend: Timeline de Notas no Detail

**Branch:** `feature/s6.11-notes-timeline`

**Arquivos a modificar:**
- `app/frontend/11-APP-app.js` — `loadMenteeNotes()`
- `app/frontend/10-APP-index.html` — seção de timeline no detail panel (slide-over ou page separada)

**Steps:**
1. `loadMenteeNotes(id)` → GET → `data.menteeNotes[id] = res.notes`
2. Template de timeline com ícone por tipo de nota, data formatada, conteúdo expandível

---

### S6.12 — Frontend: Digest Panel

**Branch:** `feature/s6.12-digest`

**Arquivos a modificar:**
- `app/frontend/11-APP-app.js` — `computeDigest(menteeId)`
- `app/frontend/10-APP-index.html` — slide-over panel

**Steps:**

1. **`computeDigest(menteeId)`:**
   ```javascript
   computeDigest(id) {
     const mentee = this.data.carteira.find(m => m.id === id)
     const topics = (this.data.waTopics || []).filter(
       t => t.group_jid === mentee?.group_jid &&
            new Date(t.last_message_at) > subDays(new Date(), 7)
     )
     return {
       topics: topics.slice(0, 5),
       actionItems: topics.filter(t => t.has_action_item),
       sentiment: this.aggregateSentiment(topics),
       needsAttention: topics.filter(t => t.sentiment === 'negative' && t.status === 'open')
     }
   }
   ```

2. **Digest slide-over HTML:**
   ```html
   <div class="slide-over" x-show="data.digestOpen !== null" @click.outside="data.digestOpen = null">
     <h2>Digest — <span x-text="getMenteeById(data.digestOpen)?.nome"></span></h2>
     <!-- Tópicos, Action Items, Sentimento, Precisa Atenção -->
   </div>
   ```

---

## Arquivos por Story (resumo)

| Story | Arquivo modificado | Tipo |
|-------|--------------------|------|
| S6.1 | `app/backend/migrations/006_*.sql` | criação |
| S6.2 | `app/backend/14-APP-server.py` | modificação |
| S6.3 | `app/backend/14-APP-server.py` | modificação |
| S6.4 | `app/backend/14-APP-server.py` | modificação |
| S6.5 | `app/backend/14-APP-server.py` | modificação |
| S6.6 | `app/frontend/10-APP-index.html`, `app/frontend/11-APP-app.js` | modificação |
| S6.7 | `app/frontend/10-APP-index.html`, `app/frontend/11-APP-app.js` | modificação |
| S6.8 | `app/frontend/10-APP-index.html`, `app/frontend/11-APP-app.js` | modificação |
| S6.9 | `app/frontend/10-APP-index.html`, `app/frontend/11-APP-app.js` | modificação |
| S6.10 | `app/frontend/10-APP-index.html`, `app/frontend/11-APP-app.js` | modificação |
| S6.11 | `app/frontend/10-APP-index.html`, `app/frontend/11-APP-app.js` | modificação |
| S6.12 | `app/frontend/10-APP-index.html`, `app/frontend/11-APP-app.js` | modificação |

**Arquivos que NUNCA devem ser tocados neste epic:**
- Nenhum arquivo da `whatsapp` page (linhas 2201-2354 do index.html)
- Nenhum arquivo da `wa_topics` page
- N8N workflows
- `.env`, secrets, credenciais

---

## Estratégia de Teste

### Por story (manual, pré-PR)

**Backend (S6.1–S6.5):**
```bash
# S6.1 — verificar schema
supabase db diff  # ou inspecionar via Studio

# S6.2 — portfolio endpoint
curl -s -H "Authorization: Bearer $TOKEN" \
  http://localhost:9999/api/mentees/portfolio | jq '.mentees[0] | keys'

# S6.4 — patch individual
curl -s -X PATCH -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fase_mentoria":"resultado"}' \
  http://localhost:9999/api/mentees/1 | jq '.fase_mentoria'

# S6.5 — bulk patch
curl -s -X PATCH -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"ids":[1,2],"fase_mentoria":"execucao"}' \
  http://localhost:9999/api/mentees/bulk | jq '.updated'
```

**Frontend (S6.6+):**
- Abrir `http://localhost:9999`, navegar para Carteira
- Verificar que cards aparecem com dados reais
- Testar filtros um a um
- Testar drag no kanban com 2 mentorados
- Testar bulk select + bulk move
- Testar snooze individual + reaparecer

### Regressão obrigatória antes de cada PR
- [ ] `whatsapp` page abre e chat funciona
- [ ] `wa_topics` board carrega
- [ ] `kanban` page (existente) não quebrou
- [ ] Login flow intacto

---

## Rollback Plan

| Fase | Como reverter |
|------|---------------|
| Fase 1 (SQL) | `ALTER TABLE mentorados DROP COLUMN snoozed_until;` + `DROP TABLE mentee_notes;` |
| Fase 2-4 (Frontend) | Reverter PR no GitHub. Nenhuma mudança é destrutiva — são adições |
| Fase 2-4 (Backend) | Reverter PR. Endpoints novos não afetam endpoints existentes |

**Zero breaking changes:** Todas as mudanças são aditivas (novas rotas, novos campos, nova página). Nenhuma rota existente é modificada.
