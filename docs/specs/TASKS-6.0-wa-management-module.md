---
title: "TASKS-6.0 — WhatsApp Management Module"
type: task-checklist
status: pending
plan: PLAN-6.0-wa-management-module.md
date: 2026-03-20
---

# TASKS-6.0 — WhatsApp Management Module

> Checklist executável por story. Cada story = uma branch = um PR para `develop`.
> Marque `[x]` ao concluir cada item. Não avance de story sem fechar todos os itens da anterior.

---

## FASE 1 — Backend Foundation

---

### S6.1 — Migration: `mentee_notes` + `snoozed_until`
**Branch:** `feature/s6.1-migration-mentee-notes`

- [ ] Criar arquivo `app/backend/migrations/006_mentee_notes_and_snooze.sql`
- [ ] Escrever `ALTER TABLE mentorados ADD COLUMN IF NOT EXISTS snoozed_until TIMESTAMPTZ DEFAULT NULL`
- [ ] Escrever `CREATE INDEX idx_mentorados_snoozed ON mentorados(snoozed_until) WHERE snoozed_until IS NOT NULL`
- [ ] Escrever `CREATE TABLE mentee_notes (...)` com todos os campos da spec seção 7
- [ ] Escrever `CREATE INDEX idx_mentee_notes_mentorado ON mentee_notes(mentorado_id, created_at DESC)`
- [ ] Escrever `CREATE INDEX idx_mentee_notes_type ON mentee_notes(type)`
- [ ] Escrever as 2 políticas RLS (SELECT + INSERT)
- [ ] Rodar migration no Supabase (Studio SQL editor ou `supabase db push`)
- [ ] Verificar no Studio: tabela `mentee_notes` existe com todas as colunas
- [ ] Verificar no Studio: coluna `snoozed_until` aparece em `mentorados`
- [ ] Verificar no Studio: 3 índices criados
- [ ] Verificar no Studio: RLS enabled na `mentee_notes`
- [ ] Commit: `chore(db): add mentee_notes table and snoozed_until column #S6.1`
- [ ] Abrir PR → develop, aguardar CI

---

### S6.2 — Backend: `GET /api/mentees/portfolio`
**Branch:** `feature/s6.2-portfolio-endpoint`
**Depende de:** S6.1 merged

- [ ] Abrir `app/backend/14-APP-server.py`
- [ ] Localizar onde fica o handler de `GET /api/mentees` (buscar por `/api/mentees`)
- [ ] Verificar os nomes reais das colunas nas tabelas: `mentorados`, `wa_topics`, `wa_message_queue`, `god_tasks` (inspecionar via Studio ou lendo migrations existentes)
- [ ] Adicionar elif para `/api/mentees/portfolio` ANTES do handler genérico de `/api/mentees`
- [ ] Implementar leitura do `current_user_uid` do JWT no handler
- [ ] Implementar query SQL com JOINs (conforme PLAN seção S6.2, ajustando nomes de colunas reais)
- [ ] Implementar lógica de scope: `?scope=me` filtra por `assignee_uid = current_user`; `?scope=all` retorna todos **— validar role do usuário antes: verificar `current_user.is_admin` ou `has_role("manager")`; retornar 403 se scope=all e usuário não autorizado**
- [ ] Calcular `dias_sem_interacao` como `(now() - last_message_at).days` no Python
- [ ] Retornar JSON com campo `mentees: [...]` conforme schema da spec seção 6.1
- [ ] Testar com curl (scope=me): `curl -H "Authorization: Bearer $TOKEN" http://localhost:9999/api/mentees/portfolio`
- [ ] Verificar que response inclui todos os campos: `id, nome, foto_url, fase, group_jid, snoozed_until, last_message_at, last_message_preview, unread_count, open_topics_count, negative_sentiment_count, pending_consultant_tasks, next_call, dias_sem_interacao`
- [ ] Testar com scope=all, verificar diferença no número de resultados
- [ ] Verificar que GET /api/mentees existente continua funcionando (regressão)
- [ ] Commit: `feat(api): add GET /api/mentees/portfolio with scoped view #S6.2`
- [ ] Abrir PR → develop, aguardar CI

---

### S6.3 — Backend: `GET` + `POST /api/mentees/{id}/notes`
**Branch:** `feature/s6.3-notes-endpoints`
**Depende de:** S6.1 merged

- [ ] Abrir `app/backend/14-APP-server.py`
- [ ] Localizar onde ficam os handlers de `/api/mentees/{id}` (se existir)
- [ ] Adicionar handler para `GET /api/mentees/{id}/notes`
  - [ ] Extrair `mentee_id` do path
  - [ ] **Validar autorização: verificar que o usuário logado (uid/role do JWT) é assignee do mentorado ou possui role autorizado — retornar 403 se não autorizado**
  - [ ] Query: `SELECT * FROM mentee_notes WHERE mentorado_id = $1 ORDER BY created_at DESC LIMIT 20`
  - [ ] Retornar `{ notes: [...] }`
- [ ] Adicionar handler para `POST /api/mentees/{id}/notes`
  - [ ] Parse body JSON
  - [ ] **Validar autorização antes do INSERT: verificar que o usuário logado é assignee do mentorado ou possui role autorizado — retornar 403 se não autorizado**
  - [ ] Validar `type` contra enum: `['checkpoint_mensal', 'feedback_aula', 'registro_ligacao', 'nota_livre']`
  - [ ] Retornar 400 se type inválido
  - [ ] Extrair `uid` e `name` do usuário logado (JWT)
  - [ ] INSERT em `mentee_notes`
  - [ ] Retornar a nota criada com status 201
- [ ] Testar GET: `curl -H "Authorization: Bearer $TOKEN" http://localhost:9999/api/mentees/1/notes`
- [ ] Testar POST com type válido: deve retornar 201
- [ ] Testar POST com type inválido: deve retornar 400
- [ ] Verificar que outros endpoints existentes não foram afetados
- [ ] Commit: `feat(api): add GET+POST /api/mentees/{id}/notes #S6.3`
- [ ] Abrir PR → develop, aguardar CI

---

### S6.4 — Backend: `PATCH /api/mentees/{id}`
**Branch:** `feature/s6.4-patch-mentee`
**Depende de:** S6.1 merged

- [ ] Abrir `app/backend/14-APP-server.py`
- [ ] Verificar se já existe `do_PATCH` ou handling de método PATCH (buscar por `'PATCH'` no arquivo)
- [ ] Se não existir: adicionar `do_PATCH` seguindo o padrão do `do_GET` e `do_POST`
- [ ] Adicionar handler para `PATCH /api/mentees/{id}`
  - [ ] Extrair `mentee_id` do path
  - [ ] Parse body JSON
  - [ ] Definir `ALLOWED_FIELDS = {'fase_mentoria', 'snoozed_until'}`
  - [ ] Rejeitar com 400 se body contém chave fora de ALLOWED_FIELDS
  - [ ] Se `fase_mentoria`: validar contra enum `['onboarding', 'execucao', 'resultado', 'renovacao', 'alumni']`
  - [ ] Se `snoozed_until`: aceitar ISO datetime string ou null
  - [ ] **Validar tenant/owner: incluir `AND tenant_id = $N` no WHERE clause do UPDATE (`UPDATE mentorados SET ... WHERE id = $1 AND tenant_id = $2`); retornar 403 se tenant não corresponder ou estiver ausente**
  - [ ] Executar UPDATE em `mentorados` para os campos recebidos
  - [ ] Retornar o registro atualizado
- [ ] Testar PATCH fase: `curl -X PATCH -d '{"fase_mentoria":"resultado"}' .../api/mentees/1`
- [ ] Testar PATCH snooze: `curl -X PATCH -d '{"snoozed_until":"2026-03-27T00:00:00Z"}' .../api/mentees/1`
- [ ] Testar PATCH campo inválido: deve retornar 400
- [ ] Testar PATCH fase inválida: deve retornar 400
- [ ] Commit: `feat(api): add PATCH /api/mentees/{id} for fase and snooze #S6.4`
- [ ] Abrir PR → develop, aguardar CI

---

### S6.5 — Backend: `PATCH /api/mentees/bulk`
**Branch:** `feature/s6.5-bulk-endpoint`
**Depende de:** S6.4 merged

- [ ] Abrir `app/backend/14-APP-server.py`
- [ ] Adicionar handler `PATCH /api/mentees/bulk` — DEVE ficar ANTES do handler de `PATCH /api/mentees/{id}` no roteamento
- [ ] Parse body JSON
- [ ] Validar `ids`: obrigatório, array não-vazio, máximo 50 elementos, todos inteiros
- [ ] Validar que exatamente um campo de update foi enviado (`fase_mentoria` OU `snoozed_until`)
- [ ] Retornar 400 com mensagem clara se validações falharem
- [ ] **Validar tenant/owner: obter `tenant_id` do JWT/request; retornar 403 se ausente ou não autorizado**
- [ ] Executar `UPDATE mentorados SET <campo> = $1 WHERE id = ANY($2::bigint[]) AND tenant_id = $3` — uma única query com tenant scoping
- [ ] Retornar `{ updated: <count>, ids: [...] }`
- [ ] Testar bulk fase: `curl -X PATCH -d '{"ids":[1,2,3],"fase_mentoria":"execucao"}' .../api/mentees/bulk`
- [ ] Testar bulk snooze: `curl -X PATCH -d '{"ids":[1,2],"snoozed_until":"2026-03-27T00:00:00Z"}' .../api/mentees/bulk`
- [ ] Testar com ids=[]: deve retornar 400
- [ ] Testar com 51 ids: deve retornar 400
- [ ] Testar que `/api/mentees/bulk` não é capturado pelo handler `/{id}` (verificar ordem no código)
- [ ] Commit: `feat(api): add PATCH /api/mentees/bulk with 50-item limit #S6.5`
- [ ] Abrir PR → develop, aguardar CI

---

## FASE 2 — Carteira Grid

---

### S6.6 — Frontend: Página Carteira — Grid View
**Branch:** `feature/s6.6-carteira-grid`
**Depende de:** S6.2 merged

#### `11-APP-app.js`

- [ ] Adicionar constantes no topo do arquivo (ou seção de constantes):
  ```javascript
  const KANBAN_FASE_COLS = [...]
  const KANBAN_SAUDE_COLS = [...]
  ```
- [ ] Adicionar em `this.data`: `carteira: []`, `undoBuffer: null`
- [ ] Adicionar em `this.ui`: `carteiraView: 'grid'`, `kanbanEixo: 'fase'`, `kanbanDragging: null`, `kanbanDraggingOver: null`, `bulkSelected: new Set()`, `snoozeOverlay: false`, `focusedMenteeIdx: -1`
- [ ] Adicionar em `this.ui.carteiraFilter`: `{ fase: '', health: '', consultor: 'me', has_pending: false, search: '', logic: 'AND' }`
- [ ] Adicionar em `this.ui`: `toast: { open: false, message: '', actionLabel: '', action: null }`
- [ ] Implementar `async loadCarteira()` — GET /api/mentees/portfolio com scope correto
- [ ] Implementar `getHealthStatus(mentee)` — retorna 'green'|'yellow'|'red'
- [ ] Implementar `getHealthLabel(mentee)` — retorna 'Engajado'|'Atenção'|'Risco'
- [ ] Implementar `getTimeSinceLabel(mentee)` — retorna string ou null
- [ ] Implementar `get carteiraFiltrada()` (computed getter):
  - [ ] Filtra snoozed: `!m.snoozed_until || new Date(m.snoozed_until) < new Date()`
  - [ ] Filtra por `ui.carteiraFilter.fase` se preenchido
  - [ ] Filtra por `ui.carteiraFilter.health` se preenchido
  - [ ] Filtra por `ui.carteiraFilter.search` (nome.toLowerCase().includes)
  - [ ] Respeita lógica AND/OR entre filtros ativos
- [ ] Implementar `get carteiraSnooze()` — retorna mentorados com snoozed_until válido
- [ ] Implementar `showToast(message, actionLabel, action)` — abre toast, fecha em 30s
- [ ] Adicionar case `'carteira'` no router do Alpine (onde as pages são inicializadas): chama `loadCarteira()`
- [ ] Adicionar `carteira` ao array de nav items (entre `whatsapp` e `wa_topics`)

#### `10-APP-index.html`

- [ ] Adicionar item nav para `carteira` (seguindo padrão dos outros nav items)
- [ ] Adicionar `<!-- ===== PAGE: CARTEIRA ===== -->` no local correto entre as pages
- [ ] Implementar header da carteira:
  - [ ] View toggles: `[Grid] [Inbox] [Kanban]` — cada um seta `ui.carteiraView`
  - [ ] Filter bar: Fase (select), Saúde (select), Busca (input debounce), toggle AND/OR
  - [ ] Snooze counter: `x-show="carteiraSnooze.length > 0"` com contador e botão para overlay
- [ ] Implementar Grid view (`x-show="ui.carteiraView === 'grid'"`)
  - [ ] `<template x-for="m in carteiraFiltrada" :key="m.id">`
  - [ ] Card com: checkbox, foto+health dot, nome, fase badge, time-signal, last message preview, unread count, próxima call
  - [ ] Hover menu: [Abrir Chat] [Nova Nota] [Ver Digest] [Snooze]
- [ ] Implementar Snooze overlay (`x-show="ui.snoozeOverlay"`) — lista de snoozed com [Acordar] por item
- [ ] Implementar Toast component (global, antes de `</body>`)
- [ ] Implementar Inbox view placeholder (`x-show="ui.carteiraView === 'inbox'"`) — "Em breve (S6.7)"
- [ ] Implementar Kanban view placeholder (`x-show="ui.carteiraView === 'kanban'"`) — "Em breve (S6.8)"

#### Validação manual

- [ ] Navegar para Carteira: cards aparecem com dados reais
- [ ] Health badge verde/amarelo/vermelho aparece corretamente
- [ ] Time-signal aparece somente quando `dias_sem_interacao > 3`
- [ ] Filtro por fase: selecionar "onboarding" mostra apenas onboarding
- [ ] Busca por nome filtra em tempo real
- [ ] Toggle AND → OR muda comportamento quando 2+ filtros ativos
- [ ] Mentorado snoozed (forçar via Studio: `UPDATE mentorados SET snoozed_until = now() + interval '1 day' WHERE id = X`) desaparece da grid
- [ ] Contador de snoozed aparece, click abre overlay, [Acordar] recoloca o card
- [ ] Nenhuma feature existente quebrada (whatsapp page, wa_topics, kanban existente, dashboard)

- [ ] Commit: `feat(ui): add carteira page with grid view, health signals, scoped filter #S6.6`
- [ ] Abrir PR → develop, aguardar CI

---

## FASE 3 — Scale Layer

---

### S6.7 — Frontend: Priority Inbox + compound filter + keyboard shortcuts
**Branch:** `feature/s6.7-inbox-keyboard`
**Depende de:** S6.6 merged

#### `11-APP-app.js`

- [ ] Implementar `getPriorityScore(mentee)`:
  - [ ] `score += dias_sem_interacao * 3`
  - [ ] `score += fase em ['onboarding','renovacao'] ? 20 : 0`
  - [ ] `score += pending_consultant_tasks * 25`
  - [ ] `score += unread_count * 1.5`
  - [ ] `score += negative_sentiment_count * 10`
  - [ ] Retornar `Math.round(score)`
- [ ] Implementar `get carteiraOrdenada()` — se inbox view, sort desc por score; senão, retorna `carteiraFiltrada` ordenada por nome
- [ ] Implementar `initKeyboardShortcuts()` com guards:
  - [ ] Guard 1: `this.ui.page !== 'carteira'` → return
  - [ ] Guard 2: `document.activeElement` é INPUT, TEXTAREA ou SELECT → return
  - [ ] Guard 3: `this.ui.notaModal.open` → return
  - [ ] `j` / `ArrowDown` → incrementar `ui.focusedMenteeIdx` (máximo: length - 1)
  - [ ] `k` / `ArrowUp` → decrementar `ui.focusedMenteeIdx` (mínimo: 0)
  - [ ] `e` → `navigate('whatsapp', { group: focusedMentee.group_jid })`
  - [ ] `n` → `openNotaModal(focusedMentee.id, 'nota_livre')`
  - [ ] `s` → `openSnoozeMenu(focusedMentee.id)` (picker inline: 1d/3d/7d)
  - [ ] `x` → `toggleBulkSelect(focusedMentee.id)`
- [ ] Chamar `initKeyboardShortcuts()` no case `'carteira'` do router (já foi adicionado? confirmar)
- [ ] Implementar `openSnoozeMenu(menteeId)` — abre micro-dropdown inline no card focado

#### `10-APP-index.html`

- [ ] Substituir placeholder do Inbox view pelo HTML real:
  - [ ] `<template x-for="m in carteiraOrdenada" :key="m.id">`
  - [ ] Row com: checkbox, avatar, nome, fase, time-signal, score badge, hover actions (E/N/S)
  - [ ] Classe `focused` quando `ui.focusedMenteeIdx === $index`
  - [ ] Estado vazio: "Nenhum mentorado com prioridade agora" quando todos score < 5
- [ ] Adicionar hint de atalhos no header do inbox: `J/K · E · N · S · X`

#### Validação manual

- [ ] Inbox view reordena: mentorado sem resposta há 10 dias fica no topo
- [ ] Score badge mostra número diferente por mentorado
- [ ] Apertar `j` navega para o próximo; `k` para o anterior (indicador visual no card)
- [ ] Apertar `e` com card focado abre o chat correto
- [ ] Apertar `s` abre snooze menu do card focado
- [ ] Atalhos NÃO disparam dentro de input de busca (digitar "j" na busca não navega)
- [ ] Compound filter: Fase = onboarding AND Saúde = vermelho → só mostra onboarding+vermelho
- [ ] Toggle para OR: onboarding OR vermelho → mostra todos os onboarding + todos os vermelhos

- [ ] Commit: `feat(ui): add priority inbox, compound filter, and keyboard shortcuts #S6.7`
- [ ] Abrir PR → develop, aguardar CI

---

### S6.9 — Frontend: Bulk toolbar + Snooze
**Branch:** `feature/s6.9-bulk-snooze`
**Depende de:** S6.7 merged (e S6.5 merged para bulk backend)

#### `11-APP-app.js`

- [ ] Implementar `toggleBulkSelect(id)` — add/remove do Set + `new Set()` para trigger Alpine
- [ ] Implementar `toggleSelectAll()` — se todos selecionados, limpa; senão seleciona todos de `carteiraFiltrada`
- [ ] Implementar `clearBulkSelect()` — `ui.bulkSelected = new Set()`
- [ ] Implementar helper `snoozeDate(days)` — retorna ISO string de `now + days dias`
- [ ] Implementar `async executeBulkAction(field, value)`:
  - [ ] Salvar undo buffer: `{ ids, field, previous: [{id, value}...], expiresAt: Date.now() + 30000 }`
  - [ ] Atualizar `data.carteira` localmente (otimista)
  - [ ] Limpar `ui.bulkSelected`
  - [ ] Chamar `PATCH /api/mentees/bulk`
  - [ ] Chamar `showToast('X mentorados atualizados', 'Desfazer', () => this.undoBulkAction())`
- [ ] Implementar `undoBulkAction()`:
  - [ ] Guard: `!undoBuffer || Date.now() > undoBuffer.expiresAt` → return
  - [ ] Reverter `data.carteira` localmente
  - [ ] Para cada `{id, value}` no `previous`, chamar `PATCH /api/mentees/{id}` com o valor anterior
  - [ ] Limpar `undoBuffer`
- [ ] Implementar `async snoozeOne(id, days)`:
  - [ ] Calcular `snoozed_until`
  - [ ] Atualizar `data.carteira` localmente (otimista)
  - [ ] Chamar `PATCH /api/mentees/{id}` com `snoozed_until`
  - [ ] Chamar `showToast('Sonecado por Xd', 'Acordar', () => this.unsnooze(id))`
- [ ] Implementar `async unsnooze(id)`:
  - [ ] Atualizar `data.carteira` localmente: `snoozed_until = null`
  - [ ] Chamar `PATCH /api/mentees/{id}` com `snoozed_until: null`
- [ ] Implementar `async snoozeMany(days)` — bulk snooze via `executeBulkAction('snoozed_until', snoozeDate(days))`

#### `10-APP-index.html`

- [ ] Implementar Bulk toolbar (dentro do header da Carteira):
  - [ ] `x-show="ui.bulkSelected.size > 0"`
  - [ ] Contador: "X selecionados"
  - [ ] Dropdown "Mover Fase →" com 5 opções de fase
  - [ ] Dropdown "Snooze →" com 1d / 3d / 7d
  - [ ] Botão "Limpar seleção"
  - [ ] Checkbox "Selecionar todos" no header (liga/desliga todos os filtrados)
- [ ] Adicionar checkbox em cada card da Grid view (já adicionado no S6.6? se não, adicionar agora)
- [ ] Adicionar checkbox em cada row do Inbox view (já adicionado no S6.7? confirmar)

#### Validação manual

- [ ] Selecionar 3 cards → toolbar aparece com "3 selecionados"
- [ ] Bulk Mover Fase → Execução: os 3 cards atualizam na UI e no banco (conferir no Studio)
- [ ] Toast "3 mentorados atualizados" com [Desfazer] aparece
- [ ] Clicar [Desfazer] dentro de 30s: cards voltam para fase anterior
- [ ] Aguardar 30s sem clicar [Desfazer]: desfazer não funciona mais (toast some)
- [ ] Bulk Snooze 1d: cards somem da grid, contador "3 snoozed" aparece
- [ ] Snooze individual via hover menu: card some, toast com [Acordar]
- [ ] Clicar [Acordar]: card reaparece
- [ ] Forçar `snoozed_until = now() - 1 hour` via Studio: ao navegar para Carteira, mentorado aparece normalmente
- [ ] "Selecionar todos" com filtro ativo: seleciona apenas os filtrados, não todos os mentorados

- [ ] Commit: `feat(ui): add bulk operations, snooze, and undo toast #S6.9`
- [ ] Abrir PR → develop, aguardar CI

---

## FASE 4 — Full Board

---

### S6.8 — Frontend: Kanban View com bulk drag
**Branch:** `feature/s6.8-kanban`
**Depende de:** S6.9 merged (para bulk select já existir)

#### `11-APP-app.js`

- [ ] Implementar `getKanbanColumns()` — retorna `KANBAN_FASE_COLS` ou `KANBAN_SAUDE_COLS`
- [ ] Implementar `getMenteesForColumn(colKey)` — filtra `carteiraFiltrada` pela coluna
- [ ] Implementar `onDragStart(e, id)`:
  - [ ] Setar `ui.kanbanDragging = id`
  - [ ] Se `ui.bulkSelected.has(id)`: drag todos do Set; senão, drag só o id
  - [ ] `e.dataTransfer.setData('text/plain', JSON.stringify(ids))`
- [ ] Implementar `onDrop(e, colKey)`:
  - [ ] `e.preventDefault()`
  - [ ] Parse ids do dataTransfer
  - [ ] Se `col.readonly` → return (eixo saúde)
  - [ ] Se ids.length === 1 → `updateMenteeFase(ids[0], colKey)`
  - [ ] Se ids.length > 1 → `updateMenteeFaseBulk(ids, colKey)` + showToast
  - [ ] Limpar `ui.kanbanDragging` e `ui.kanbanDraggingOver`
  - [ ] Limpar `ui.bulkSelected` após bulk drag
- [ ] Implementar `async updateMenteeFase(id, fase)`:
  - [ ] Atualizar `data.carteira` localmente
  - [ ] `PATCH /api/mentees/{id}` com `fase_mentoria`
  - [ ] showToast `"<nome> movido para <fase> ✓"`
- [ ] Implementar `async updateMenteeFaseBulk(ids, fase)`:
  - [ ] Atualizar `data.carteira` localmente
  - [ ] `PATCH /api/mentees/bulk` com `{ ids, fase_mentoria: fase }`
  - [ ] showToast `"X mentorados movidos para <fase> ✓"`

#### `10-APP-index.html`

- [ ] Substituir placeholder do Kanban view pelo HTML real
- [ ] Eixo selector: botões [Por Fase] [Por Saúde] — alteram `ui.kanbanEixo`
- [ ] `<template x-for="col in getKanbanColumns()">` para as colunas
- [ ] Cada coluna: `@dragover.prevent`, `@dragleave`, `@drop`
- [ ] Highlight de coluna durante drag: `:class="{ 'drop-target': ui.kanbanDraggingOver === col.key }"`
- [ ] Header da coluna: label + color bar + count
- [ ] `<template x-for="m in getMenteesForColumn(col.key)">` para os cards
- [ ] Card kanban: `draggable`, `@dragstart`, checkbox, avatar, nome, health dot, hover actions
- [ ] Empty state por coluna: "Nenhum mentorado aqui"
- [ ] Eixo Saúde: cards SEM `draggable` (ou `draggable="false"`) — não permitem drag

#### Validação manual

- [ ] Kanban renderiza 5 colunas de fase com counts corretos
- [ ] Arrastar card de Onboarding → Execução: card move, banco atualiza (conferir Studio)
- [ ] Toast "Ana Lima movida para Execução ✓" aparece
- [ ] Drag no eixo Saúde: NÃO deve mover (cards não draggable)
- [ ] Selecionar 2 cards (checkbox) → arrastar um deles: ambos se movem para a coluna destino
- [ ] Highlight visual na coluna destino durante o drag
- [ ] Filtro de fase ativo no header: kanban só mostra mentorados filtrados
- [ ] Coluna vazia: placeholder "Nenhum mentorado aqui" aparece

- [ ] Commit: `feat(ui): add kanban view with drag-and-drop and bulk drag #S6.8`
- [ ] Abrir PR → develop, aguardar CI

---

### S6.10 — Frontend: Modal Notas
**Branch:** `feature/s6.10-modal-notas`
**Depende de:** S6.3 merged (endpoints de notas)

#### `11-APP-app.js`

- [ ] Adicionar em `this.ui.notaModal`: `{ open: false, menteeId: null, type: 'nota_livre', data: {} }`
- [ ] Implementar `openNotaModal(menteeId, type)` — seta state e abre modal
- [ ] Implementar `closeNotaModal()` — fecha e limpa state
- [ ] Implementar `async createMenteeNote()`:
  - [ ] POST `/api/mentees/${menteeId}/notes` com `{ type, data, tags }`
  - [ ] Fechar modal
  - [ ] Se timeline do mentorado estiver aberta: recarregar notas
  - [ ] showToast `"Nota salva ✓"`

#### `10-APP-index.html`

- [ ] Adicionar modal global (antes de `</body>`, fora de qualquer page)
- [ ] `x-show="ui.notaModal.open"` com overlay + `x-transition`
- [ ] Tabs de tipo: [Checkpoint Mensal] [Feedback de Aula] [Registro de Ligação] [Nota Livre]
- [ ] Campos para `checkpoint_mensal`:
  - [ ] Progresso (1-5, radio ou select)
  - [ ] Bloqueios (textarea)
  - [ ] Próximos passos (textarea)
  - [ ] Humor do mentorado (select: animado/neutro/frustrado/desengajado)
  - [ ] Observações (textarea)
- [ ] Campos para `feedback_aula`:
  - [ ] Título da aula (input text)
  - [ ] Participou? (checkbox)
  - [ ] Entregou tarefa? (select: sim/não/parcialmente)
  - [ ] Observações (textarea)
- [ ] Campos para `registro_ligacao`:
  - [ ] Duração em minutos (number input)
  - [ ] Tópicos (textarea)
  - [ ] Decisões (textarea)
  - [ ] Follow-ups (textarea)
- [ ] Campos para `nota_livre`:
  - [ ] Texto (textarea, suporte markdown)
  - [ ] Tags (input com chips)
- [ ] Botões: [Cancelar] e [Salvar Nota]
- [ ] Verificar que [Nova Nota] nos cards da Carteira abre o modal corretamente

#### Validação manual

- [ ] Clicar [Nova Nota] em qualquer card abre modal
- [ ] Cada tab mostra os campos corretos
- [ ] Salvar Checkpoint Mensal: nota aparece no banco (conferir Studio em `mentee_notes`)
- [ ] Toast "Nota salva ✓" aparece
- [ ] Fechar com [Cancelar]: não salva
- [ ] Testar os 4 tipos de nota

- [ ] Commit: `feat(ui): add structured notes modal with 4 templates #S6.10`
- [ ] Abrir PR → develop, aguardar CI

---

### S6.11 — Frontend: Timeline de Notas no Detail
**Branch:** `feature/s6.11-notes-timeline`
**Depende de:** S6.10 merged

#### `11-APP-app.js`

- [ ] Adicionar em `this.data`: `menteeNotes: {}`
- [ ] Implementar `async loadMenteeNotes(menteeId)`:
  - [ ] GET `/api/mentees/${menteeId}/notes`
  - [ ] Salvar em `data.menteeNotes[menteeId]`
- [ ] Decidir onde abrir o detail: slide-over lateral ou seção dentro do card expandido
  - [ ] Se slide-over: adicionar `ui.detailMenteeId: null` e `openDetail(id)` / `closeDetail()`

#### `10-APP-index.html`

- [ ] Implementar o detail panel (slide-over ou expandido)
- [ ] Timeline de notas:
  - [ ] `<template x-for="note in data.menteeNotes[ui.detailMenteeId]">`
  - [ ] Ícone por tipo (📋 checkpoint | 🎓 aula | 📞 ligação | 📝 livre)
  - [ ] Data formatada
  - [ ] Preview do conteúdo (expansível)
  - [ ] Tags (se nota livre)
- [ ] Estado vazio: "Nenhuma nota registrada ainda"
- [ ] Botão [+ Nova Nota] dentro do detail que abre o modal

#### Validação manual

- [ ] Abrir detail de mentorado: timeline carrega
- [ ] Salvar nova nota: aparece no topo da timeline
- [ ] Ícones corretos por tipo
- [ ] Estado vazio aparece para mentorado sem notas

- [ ] Commit: `feat(ui): add mentee notes timeline in detail panel #S6.11`
- [ ] Abrir PR → develop, aguardar CI

---

### S6.12 — Frontend: Digest Panel
**Branch:** `feature/s6.12-digest`
**Depende de:** S6.6 merged (wa_topics já carregados em `data.waTopics`)

#### `11-APP-app.js`

- [ ] Verificar que `data.waTopics` é populado pelo `loadWaTopics()` existente (confirmar no app.js)
- [ ] Implementar helper `subDays(date, n)` — retorna `date - n dias`
- [ ] Implementar `computeDigest(menteeId)`:
  - [ ] Buscar mentee em `data.carteira` pelo id
  - [ ] Filtrar `data.waTopics` por `group_jid === mentee.group_jid` E `last_message_at > 7 dias atrás`
  - [ ] Retornar: `{ topics, actionItems, sentiment, needsAttention }`
  - [ ] `actionItems`: topics com `has_action_item === true` (ou campo equivalente na tabela)
  - [ ] `sentiment`: contar positivos/negativos/neutros, retornar o mais frequente
  - [ ] `needsAttention`: topics com `sentiment === 'negative'` e `status === 'open'`
- [ ] Implementar `openDigest(menteeId)`:
  - [ ] Setar `data.digestOpen = menteeId`
  - [ ] Chamar `loadWaTopics()` se `data.waTopics` estiver vazio

#### `10-APP-index.html`

- [ ] Implementar slide-over do digest (`x-show="data.digestOpen !== null"`)
- [ ] Header: "Digest — <nome do mentorado>" + botão [×] fechar
- [ ] Seção "Tópicos da semana":
  - [ ] Lista dos últimos 5 tópicos (label, keywords, data)
  - [ ] Estado vazio: "Nenhuma atividade classificada esta semana"
- [ ] Seção "Action items pendentes":
  - [ ] Lista com status (aberto/fechado)
  - [ ] Estado vazio: "Nenhum action item pendente"
- [ ] Seção "Sentimento geral":
  - [ ] Badge: 🟢 Positivo / 🟡 Neutro / 🔴 Negativo
- [ ] Seção "Precisa atenção":
  - [ ] Topics negativos abertos com destaque
  - [ ] Estado vazio: "Nenhuma mensagem requer atenção"

#### Validação manual

- [ ] Clicar [Ver Digest] em card com wa_topics: painel abre com dados reais
- [ ] Clicar [Ver Digest] em mentorado sem wa_topics: todas as seções mostram estado vazio
- [ ] Fechar o painel: `data.digestOpen = null`
- [ ] Tópicos aparecem com data correta (últimos 7 dias)

- [ ] Commit: `feat(ui): add AI group digest slide-over panel #S6.12`
- [ ] Abrir PR → develop, aguardar CI

---

## Regressão Final (pós todas as stories)

- [ ] Navegar por TODAS as páginas existentes sem erro no console:
  - [ ] dashboard
  - [ ] kanban (existente)
  - [ ] tasks
  - [ ] agenda
  - [ ] whatsapp (chat raw)
  - [ ] wa_topics (board)
  - [ ] reminders
  - [ ] dossies
  - [ ] planos_acao
  - [ ] onboarding
  - [ ] docs
  - [ ] arquivos
  - [ ] financeiro
  - [ ] settings
- [ ] QR pairing no whatsapp page ainda funciona
- [ ] wa_topics board: filtros e KPIs funcionam
- [ ] Kanban existente: drag-and-drop continua funcionando
- [ ] Carteira: todas as 6 features funcionam end-to-end
- [ ] Zero erros no console do browser em qualquer page
- [ ] Verificar no banco (Studio): `mentee_notes` tem dados, `snoozed_until` atualiza corretamente

---

## Sumário de PRs por Sprint

| Sprint | Stories | PRs | Bloqueante para próximo sprint |
|--------|---------|-----|-------------------------------|
| Sprint 1 | S6.1, S6.2, S6.4, S6.5 | 4 | S6.2 e S6.5 mergeados |
| Sprint 2 | S6.3, S6.6 | 2 | S6.3 e S6.6 mergeados |
| Sprint 3 | S6.7, S6.9 | 2 | S6.7 e S6.9 mergeados |
| Sprint 4 | S6.8, S6.10, S6.11, S6.12 | 4 | — |
