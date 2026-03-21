---
title: "SPEC-6.0 — WhatsApp Management Module"
type: feature-spec
status: draft-v2
author: spec-feature skill
date: 2026-03-20
bu: BU-CASE
project: spalla-dashboard
size: XL
epic: 6
---

# SPEC-6.0 — WhatsApp Management Module

## 1. Problema

O Spalla já possui uma interface tipo WhatsApp Web (`whatsapp` page) e um board de tópicos AI (`wa_topics`). Mas ambos são **reativos** — o consultor abre para ver o que aconteceu, não tem visão de quem precisa de atenção **agora**, e não consegue **agir** a partir do que vê.

Com 20-40 mentorados por equipe, consultores perdem tempo para:
- Descobrir quem está sem interação há dias (risco de churn)
- Lembrar onde pararam com cada mentorado
- Achar action items prometidos mas não cumpridos
- Entender o estado emocional de cada grupo
- Mover mentorados entre fases manualmente (hoje é campo na tabela, sem UI de gestão)

Nenhuma ferramenta no mercado resolve isso para o modelo de mentoria consultiva. O Spalla é o único.

---

## 2. Solução Proposta

Um **Management Hub** centralizado na página `carteira` com 3 modos de view e ações inline — não só visualizar, mas **gerir** diretamente do board.

```
┌──────────────────────────────────────────────────────────────────┐
│  CARTEIRA — Management Hub                                       │
│                                                                  │
│  [Grid] [Inbox] [Kanban]        ☑ 3 selecionados [Bulk ▾]       │
│  Filtros (AND/OR): Fase / Saúde / Consultor / Pendências / 🔍   │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Grid:   cards em grade com health badges                       │
│          ↳ bulk select via checkbox, time-based signal badges   │
│  Inbox:  lista ordenada por priority score                      │
│          ↳ snooze (reaparece em X dias), compound filters       │
│  Kanban: colunas drag-and-drop (fase OU saúde)                  │
│          ↳ drag individual ou bulk (múltiplos selecionados)     │
│                                                                  │
│  Ações inline (em qualquer view):                               │
│    [Abrir Chat] [Nova Nota] [Ver Digest] [Mover Fase] [Snooze]  │
│                                                                  │
│  Atalhos: J/K navegar · E abrir chat · N nota · S snooze        │
└──────────────────────────────────────────────────────────────────┘
```

### F1 — Carteira do Consultor (Grid View)
View de portfólio de todos os mentorados com indicadores de saúde. Modo padrão.

### F2 — Priority Inbox (List View)
Vista que reordena por score de prioridade. Quem agir primeiro, no topo.

### F3 — Notas Estruturadas por Mentorado
Sistema de anotações com templates tipados. Acessível de qualquer view.

### F4 — AI Group Digest
Resumo semanal por mentorado, gerado a partir dos `wa_topics` existentes.

### F5 — Kanban de Gestão (Kanban View)
Board drag-and-drop com colunas configuráveis. **Permite mover mentorados entre fases** — arrasta o card, atualiza o banco. Ações inline sem sair do board.

### F6 — Bulk Operations + Snooze
Seleção múltipla de mentorados (checkbox) com ações em lote e snooze temporário. Torna o módulo funcional em escala — 20-40 mentorados gerenciados sem fricção de modal por modal.

---

## 3. Fora de Escopo

- ❌ Substituir ou modificar a `whatsapp` page existente (chat raw continua intacto)
- ❌ Substituir ou modificar a `wa_topics` page existente
- ❌ Notificações push / email
- ❌ App mobile nativo
- ❌ Envio em massa / broadcast para grupos WA
- ❌ Novo pipeline de classificação AI (usa N8N existente)
- ❌ Integração com WhatsApp oficial API (usa Evolution API existente)
- ❌ Dashboard executivo multi-consultor (Wave 2 futura)
- ❌ Automação de follow-ups / regras de automação (Wave 2 futura)
- ❌ Kanban com swimlanes / múltiplos eixos simultâneos (só um eixo por vez: fase OU saúde)
- ❌ SLA configurável por consultor (threshold fixo no frontend: 3/7 dias)
- ❌ Histórico de ações de bulk (audit log) — Wave 2

---

## 4. Dependências

### Tabelas existentes (já prontas, não modificar)
| Tabela | Dados usados |
|--------|-------------|
| `mentorados` | id, nome, foto, fase_mentoria, group_jid |
| `wa_topics` | mentorado_id, group_jid, last_message_at, status, ai_keywords, sentiment (via type_id), confidence |
| `wa_message_queue` | group_jid, status (pending/done), created_at |
| `god_tasks` | mentorado_id, status, assignee, titulo, prazo |
| `wa_sessions` | user_id, status, instance_name |

### Endpoints existentes (já prontos, não duplicar)
| Endpoint | Uso |
|----------|-----|
| `GET /api/mentees` | Lista mentorados (base) |
| `GET /api/evolution/chat/findMessages/{instance}` | Mensagens por grupo |
| `GET /api/calls/upcoming` | Próximas calls agendadas |
| Proxy `/api/evolution/*` | Qualquer chamada à Evolution API |

### Nova tabela necessária
`mentee_notes` — ver seção 7.

---

## 5. Acceptance Criteria

### F1 — Carteira do Consultor
- [ ] Página `carteira` acessível via nav (novo item entre `whatsapp` e `wa_topics`)
- [ ] Exibe todos os mentorados em grid de cards
- [ ] Cada card mostra: foto, nome, fase, health badge (verde/amarelo/vermelho), dias sem interação, preview da última mensagem, count de msgs não lidas, próxima call
- [ ] Health badge calculado no frontend: verde ≤ 3 dias, amarelo 4-7 dias, vermelho > 7 dias
- [ ] Time-based signal badge no card: "Sem resposta há 5 dias" — baseado em `dias_sem_interacao`
- [ ] Quick actions no card (hover menu): [Abrir Chat] [Nova Nota] [Ver Digest] [Snooze]
- [ ] **View scoped por padrão:** consultor logado vê APENAS seus mentorados. Filtro "Todos" disponível para gestores (campo `assignee` em `mentorados`)
- [ ] Checkbox de seleção em cada card (aparece no hover ou sempre visível no modo bulk)
- [ ] Filtros compostos header: Fase / Saúde / Consultor — com lógica AND (padrão) ou OR (toggle)
- [ ] Busca por nome de mentorado (debounce 300ms, filtra em memória sobre `data.carteira`)
- [ ] Mentorados snoozed ficam ocultos da view principal; link "X snoozed" para ver/desfazer
- [ ] Estado vazio quando filtros retornam zero: "Nenhum mentorado com esses critérios"

### F2 — Priority Inbox
- [ ] Toggle [Inbox] na Carteira ativa list view ordenada por priority score
- [ ] Score = soma ponderada: dias_sem_interação (×3) + fase_crítica (onboarding/renovação +20) + pendência_consultor (+25) + msgs_não_lidas (×1.5) + sentimento_negativo (+10)
- [ ] Badge numérico de score em cada row (ex: "Score 47")
- [ ] Compound filter bar: Fase AND/OR Saúde AND/OR `has_pending` AND/OR `snoozed=false` — toggle AND/OR por grupo de filtros
- [ ] "Sem prioridades" state quando todos estão saudáveis (score < 5)
- [ ] Mentorados snoozed não aparecem no inbox — com link "3 snoozed · ver"
- [ ] Atalhos de teclado na Inbox view:
  - `J` / `K` — navegar item anterior/próximo (foco visual no card)
  - `E` — abrir chat do mentorado focado
  - `N` — abrir modal de nota do mentorado focado
  - `S` — snooze do mentorado focado (abre picker de duração: 1d / 3d / 7d)
  - `X` — selecionar/deselecionar mentorado focado para bulk
- [ ] "Sem resposta há X dias" aparece em vermelho se > threshold (7d para crítico)

### F3 — Notas Estruturadas
- [ ] Botão "Nova Nota" no card da Carteira e na página de detail do mentorado
- [ ] Modal com 4 templates: Checkpoint Mensal, Feedback de Aula, Registro de Ligação, Nota Livre
- [ ] Cada template tem campos específicos (ver seção 7)
- [ ] Nota salva em `mentee_notes` com `mentorado_id`, `type`, `data` (JSONB), `created_by`
- [ ] Timeline de notas visível no detail do mentorado (ordenada por data desc)
- [ ] Tags livres na Nota Livre com autocomplete

### F4 — AI Group Digest
- [ ] Botão "Ver Digest" no card da Carteira abre painel lateral
- [ ] Digest gerado a partir dos `wa_topics` dos últimos 7 dias do mentorado
- [ ] Exibe: tópicos discutidos, action items com status, sentimento geral, alerta de msgs sem resposta do consultor
- [ ] Se não há `wa_topics` recentes → estado "Nenhuma atividade esta semana"
- [ ] Digest re-calculado ao abrir (client-side aggregation dos wa_topics, sem endpoint novo)

### F5 — Kanban de Gestão
- [ ] Toggle [Kanban] na Carteira ativa board view
- [ ] Selector de eixo: **Por Fase** | **Por Saúde**
- [ ] **Por Fase** — colunas: `Onboarding` | `Execução` | `Resultado` | `Renovação` | `Alumni/Saída`
- [ ] **Por Saúde** — colunas: `Crítico (>7d)` | `Atenção (4-7d)` | `Engajado (≤3d)` | `Inativo`
- [ ] Cards são os mesmos da Carteira (foto, nome, health badge, dias, unread count)
- [ ] **Drag-and-drop individual:** arrastar card entre colunas
  - No eixo Fase: salva `fase_mentoria` via `PATCH /api/mentees/{id}`
  - No eixo Saúde: read-only (saúde é calculada, não editável)
- [ ] **Drag-and-drop bulk:** se ≥1 card selecionado (checkbox), arrastar qualquer um move todos os selecionados para a coluna destino → `PATCH /api/mentees/bulk`
- [ ] Preview pré-drop: "Mover 3 mentorados → Execução?" (tooltip acima do card)
- [ ] Feedback visual durante drag (card semi-transparente, coluna de destino highlighted com border)
- [ ] Confirmação toast após mover: "Ana Lima movida para Resultado ✓" / "3 mentorados movidos para Execução ✓"
- [ ] Ações inline no card (hover menu): [Abrir Chat] [Nova Nota] [Ver Digest] [Snooze]
- [ ] Count de cards por coluna no header (inclui mentorados snoozed com indicador separado)
- [ ] Coluna vazia mostra placeholder "Nenhum mentorado aqui"
- [ ] Implementado sem lib externa — drag-and-drop nativo HTML5 (dragstart, dragover, dragleave, drop)

### F6 — Bulk Operations + Snooze
- [ ] Checkbox em cada card em todas as views (Grid, Inbox, Kanban)
- [ ] "Selecionar todos" checkbox no header (aplica ao resultado filtrado atual, não ao total)
- [ ] Bulk action toolbar aparece quando ≥1 selecionado:
  - `Mover Fase →` (dropdown: onboarding / execução / resultado / renovação / alumni)
  - `Snooze por →` (dropdown: 1 dia / 3 dias / 7 dias / data customizada)
  - `Marcar como respondido` (zera `unread_count` local — não modifica wa_message_queue)
  - `Limpar seleção`
- [ ] Bulk Fase → chama `PATCH /api/mentees/bulk` com `{ ids: [], fase_mentoria: '...' }`
- [ ] Bulk Snooze → chama `PATCH /api/mentees/bulk` com `{ ids: [], snoozed_until: '<ISO>' }`
- [ ] **Preview antes de executar bulk:** "Mover 5 mentorados para Execução. Confirmar?" inline no toolbar (não modal)
- [ ] Após bulk executar: toast "5 mentorados atualizados" + `Desfazer` link (30s window — revert local + PATCH reverso)
- [ ] **Snooze individual:** ação disponível no hover menu de qualquer card
  - Abre micro-dropdown: "1 dia" / "3 dias" / "7 dias"
  - Salva `snoozed_until` via `PATCH /api/mentees/{id}`
  - Card some da view imediatamente (remoção local otimista)
- [ ] **Snooze automático:** mentorado snoozed reaparece automaticamente quando `snoozed_until` < now (checado no `loadCarteira`)
- [ ] Contador "X snoozed" clicável no header → mostra list overlay com [Acordar Agora] por cada um
- [ ] Desfazer funciona somente enquanto toast visível (30s); após isso, o dado no banco é permanente

---

## 6. Novos Endpoints Backend

### 6.1 `GET /api/mentees/portfolio`

Agrega dados de todos os mentorados do usuário logado em uma única chamada.

**Response:**
```json
{
  "mentees": [
    {
      "id": 42,
      "nome": "Ana Lima",
      "foto_url": "https://...",
      "fase": "execucao",
      "group_jid": "120363xxx@g.us",
      "last_message_at": "2026-03-18T10:30:00Z",
      "last_message_preview": "Consegui aplicar o protocolo...",
      "unread_count": 3,
      "open_topics_count": 2,
      "negative_sentiment_count": 0,
      "pending_consultant_tasks": 1,
      "next_call": { "datetime": "2026-03-21T15:00:00Z", "zoom_link": "..." },
      "health_score": "yellow",
      "dias_sem_interacao": 5
    }
  ]
}
```

**Query logic (backend):**
1. Busca todos os mentorados
2. Para cada mentorado:
   - `last_message_at` = MAX(last_message_at) dos `wa_topics` com esse group_jid
   - `unread_count` = COUNT de mensagens em `wa_message_queue` com status `pending` nos últimos 7 dias para esse group_jid
   - `open_topics_count` = COUNT de `wa_topics` com `status = 'open'`
   - `negative_sentiment_count` = COUNT de `wa_topics` abertos onde type_id tem sentiment negativo
   - `pending_consultant_tasks` = COUNT de `god_tasks` com assignee = usuário logado e status != 'concluida'
   - `next_call` = próxima call do `upcoming_calls` para esse mentorado
3. Retorna array ordenado por nome (frontend reordena por prioridade)

### 6.2 `GET /api/mentees/{id}/notes`

Lista notas de um mentorado, ordenadas por `created_at desc`.

**Response:**
```json
{
  "notes": [
    {
      "id": "uuid",
      "type": "checkpoint_mensal",
      "data": { "progresso": 4, "bloqueios": "...", "proximos_passos": "..." },
      "tags": [],
      "created_by": "Kaique",
      "created_at": "2026-03-15T09:00:00Z"
    }
  ]
}
```

### 6.3 `POST /api/mentees/{id}/notes`

Cria nota estruturada para um mentorado.

**Body:**
```json
{
  "type": "checkpoint_mensal | feedback_aula | registro_ligacao | nota_livre",
  "data": { ... },
  "tags": ["string"]
}
```

### 6.4 `PATCH /api/mentees/{id}`

Atualiza campo editável de um mentorado. Usado pelo Kanban drag-and-drop para mover de fase.

**Body:**
```json
{
  "fase_mentoria": "onboarding | execucao | resultado | renovacao | alumni"
}
```

**Regras:**
- Apenas campos permitidos: `fase_mentoria` (por ora)
- Valida que o valor está no enum antes de salvar
- Retorna o mentorado atualizado

**Response:**
```json
{
  "id": 42,
  "nome": "Ana Lima",
  "fase_mentoria": "resultado",
  "updated_at": "2026-03-20T14:35:00Z"
}
```

### 6.5 `PATCH /api/mentees/bulk`

Aplica a mesma mudança a um conjunto de mentorados. Usado por bulk operations e bulk drag-and-drop no Kanban.

**Body:**
```json
{
  "ids": [42, 17, 88],
  "fase_mentoria": "execucao"
}
```
ou
```json
{
  "ids": [42, 17],
  "snoozed_until": "2026-03-27T00:00:00Z"
}
```

**Regras:**
- `ids` é obrigatório, array não-vazio, máximo 50 IDs por request
- Apenas um campo de update por request (ou `fase_mentoria` ou `snoozed_until`)
- Campos permitidos: `fase_mentoria`, `snoozed_until`
- `snoozed_until = null` acorda o mentorado (desfaz snooze)
- Executa como UPDATE ... WHERE id = ANY(ids) — única query SQL

**Response:**
```json
{
  "updated": 3,
  "ids": [42, 17, 88]
}
```

---

## 7. Nova Tabela: `mentee_notes`

### Alteração em `mentorados` (migration additive)

```sql
-- Adiciona suporte a snooze na tabela existente
ALTER TABLE mentorados
  ADD COLUMN IF NOT EXISTS snoozed_until TIMESTAMPTZ DEFAULT NULL;

CREATE INDEX idx_mentorados_snoozed ON mentorados(snoozed_until)
  WHERE snoozed_until IS NOT NULL;
```

### Nova tabela `mentee_notes`

```sql
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

-- RLS: usuários autenticados veem todas as notas (equipe compartilhada)
ALTER TABLE mentee_notes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "authenticated can read notes" ON mentee_notes
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "authenticated can insert notes" ON mentee_notes
  FOR INSERT WITH CHECK (auth.uid() = created_by_uid);
```

### Templates (estrutura de `data` por tipo)

**checkpoint_mensal:**
```json
{
  "progresso": 1-5,
  "bloqueios": "texto livre",
  "proximos_passos": "texto livre",
  "humor_mentorado": "animado | neutro | frustrado | desengajado",
  "observacoes": "texto livre"
}
```

**feedback_aula:**
```json
{
  "aula_titulo": "string",
  "participou": true/false,
  "entregou_tarefa": true/false | "parcialmente",
  "observacoes": "texto livre"
}
```

**registro_ligacao:**
```json
{
  "duracao_min": 45,
  "topicos": "texto livre",
  "decisoes": "texto livre",
  "follow_ups": "texto livre"
}
```

**nota_livre:**
```json
{
  "texto": "markdown livre"
}
```

---

## 8. Componentes Frontend (Alpine.js)

### Novos métodos em `operon()` (`11-APP-app.js`)

```javascript
// F1 — Carteira
async loadCarteira()              // GET /api/mentees/portfolio → this.data.carteira
getHealthStatus(mentee)           // → 'green' | 'yellow' | 'red'
getHealthLabel(mentee)            // → 'Engajado' | 'Atenção' | 'Risco'
getTimeSinceLabel(mentee)         // → 'Sem resposta há 5 dias' | null (se ≤ 3d)
get carteiraFiltrada()            // computed: aplica filtros compostos AND/OR + exclui snoozed
get carteiraSnooze()              // computed: apenas mentorados com snoozed_until > now

// F2 — Priority Score
getPriorityScore(mentee)          // calcula score ponderado
get carteiraOrdenada()            // computed: sorted by priority (if inbox mode) or nome

// F3 — Notas
async loadMenteeNotes(menteeId)   // GET /api/mentees/{id}/notes
async createMenteeNote(data)      // POST /api/mentees/{id}/notes
openNotaModal(menteeId, type)     // abre modal com template certo
closeNotaModal()

// F4 — Digest
openDigest(menteeId)              // abre painel de digest
computeDigest(menteeId)           // agrega wa_topics locais já carregados

// F5 — Kanban
getKanbanColumns()                // retorna colunas baseado em ui.kanbanEixo
getMenteesForColumn(columnKey)    // filtra carteiraFiltrada por coluna
onDragStart(event, menteeId)      // HTML5 drag start — inclui bulk se selecionados
onDragOver(event)                 // allow drop + preview tooltip
onDragLeave(event)                // remove highlight
onDrop(event, columnKey)          // individual ou bulk drop → updateMenteeFase
async updateMenteeFase(id, fase)  // PATCH /api/mentees/{id}
async updateMenteeFaseBulk(ids, fase) // PATCH /api/mentees/bulk

// F6 — Bulk + Snooze
toggleBulkSelect(menteeId)        // adiciona/remove de ui.bulkSelected (Set)
toggleSelectAll()                 // seleciona todos da carteiraFiltrada atual
clearBulkSelect()                 // limpa Set
async executeBulkAction(action, value) // chama PATCH /api/mentees/bulk + undo buffer
async snoozeOne(menteeId, days)   // PATCH /api/mentees/{id} snoozed_until + remove local
async snoozeMany(days)            // bulk snooze dos selecionados
async unsnooze(menteeId)          // PATCH snoozed_until = null + reinsere em carteira
undoBulkAction()                  // reverte a última bulk action (30s window)
initKeyboardShortcuts()           // registra keydown handlers para J/K/E/N/S/X
```

### Novos state em `this.data`
```javascript
this.data.carteira = []           // portfolio data (todos, incl. snoozed)
this.data.menteeNotes = {}        // { [menteeId]: [notes] }
this.data.digestOpen = null       // menteeId do digest aberto
this.data.undoBuffer = null       // { ids, field, previousValues, expiresAt }
```

### Novos state em `this.ui`
```javascript
this.ui.carteiraView = 'grid'     // 'grid' | 'inbox' | 'kanban'
this.ui.kanbanEixo = 'fase'       // 'fase' | 'saude'
this.ui.kanbanDragging = null     // menteeId(s) sendo arrastado(s)
this.ui.carteiraFilter = {
  fase: '',
  health: '',
  consultor: 'me',               // 'me' | 'all' — scoped por padrão
  has_pending: false,
  search: '',
  logic: 'AND'                   // 'AND' | 'OR' para combinar filtros
}
this.ui.notaModal = {
  open: false,
  menteeId: null,
  type: 'nota_livre',
  data: {}
}
this.ui.bulkSelected = new Set() // Set de menteeIds selecionados
this.ui.snoozeOverlay = false    // mostra lista de snoozed
this.ui.focusedMenteeIdx = -1   // índice do card focado (keyboard nav)
```

### Colunas do Kanban

**Eixo Fase:**
```javascript
const KANBAN_FASE_COLS = [
  { key: 'onboarding',  label: 'Onboarding',  color: '#6366f1' },
  { key: 'execucao',    label: 'Execução',     color: '#3b82f6' },
  { key: 'resultado',   label: 'Resultado',    color: '#22c55e' },
  { key: 'renovacao',   label: 'Renovação',    color: '#f97316' },
  { key: 'alumni',      label: 'Alumni/Saída', color: '#94a3b8' },
]
```

**Eixo Saúde (read-only — não permite drag):**
```javascript
const KANBAN_SAUDE_COLS = [
  { key: 'red',    label: 'Crítico',  color: '#ef4444', readonly: true },
  { key: 'yellow', label: 'Atenção',  color: '#f59e0b', readonly: true },
  { key: 'green',  label: 'Engajado', color: '#22c55e', readonly: true },
]
```

### Nova página HTML: `carteira`
```html
<!-- ===== PAGE: CARTEIRA ===== -->
<div class="page-content" x-show="ui.page === 'carteira'" x-transition>
  <!-- Header com filtros + toggle prioridade -->
  <!-- Grid de cards -->
  <!-- Painel lateral de digest (slide-over) -->
</div>
```

### Modal de Nota
```html
<!-- Modal global (reutilizável de qualquer página) -->
<div class="modal-overlay" x-show="ui.notaModal.open">
  <!-- Switch por tipo de nota -->
  <!-- Campos dinâmicos baseados no tipo -->
</div>
```

---

## 9. Sequência de Implementação

| # | Story | Feature | Escopo | Tamanho | Depende de |
|---|-------|---------|--------|---------|------------|
| S6.1 | Migration: `mentee_notes` + `snoozed_until` em `mentorados` | F3/F6 | SQL apenas | S | — |
| S6.2 | Backend: `GET /api/mentees/portfolio` com scoped view | F1/F2 | Python server | M | mentorados + wa_topics |
| S6.3 | Backend: Notes endpoints (GET + POST) | F3 | Python server | M | S6.1 |
| S6.4 | Backend: `PATCH /api/mentees/{id}` (fase + snoozed_until) | F5/F6 | Python server | S | S6.1 |
| S6.5 | Backend: `PATCH /api/mentees/bulk` | F6 | Python server | S | S6.4 |
| S6.6 | Frontend: Página Carteira — Grid View (F1) com scoped, compound filter, time signals | F1 | HTML + JS | L | S6.2 |
| S6.7 | Frontend: Priority Inbox + compound filter + keyboard shortcuts (F2) | F2 | JS + HTML | M | S6.6 |
| S6.8 | Frontend: Kanban View com bulk drag (F5) | F5 | HTML + JS | L | S6.5 + S6.6 |
| S6.9 | Frontend: Bulk toolbar + Snooze (F6) | F6 | HTML + JS | M | S6.5 + S6.6 |
| S6.10 | Frontend: Modal Notas (F3) | F3 | HTML + JS | M | S6.3 |
| S6.11 | Frontend: Timeline de notas no Detail | F3 | HTML + JS | S | S6.10 |
| S6.12 | Frontend: Digest panel (F4) | F4 | HTML + JS | M | S6.6 |

**Ordem recomendada:**
```
S6.1 ──────────────────────────────────────────┐
S6.2 ───────────────────────┐                  │
S6.4 ─────────────┐         │                  │
       ↓           ↓         ↓                  ↓
     S6.5        S6.6 ──── S6.7              S6.3
       │           │          │                 │
       ↓           ↓          ↓                 ↓
   S6.8 + S6.9  S6.12     (keyboard)        S6.10 → S6.11
```

**Sprints sugeridos:**
- Sprint 1: S6.1 + S6.2 + S6.4 + S6.5 (fundação backend completa)
- Sprint 2: S6.3 + S6.6 (carteira grid funcional com filtros e scoped view)
- Sprint 3: S6.7 + S6.9 (inbox + bulk + snooze — core de gestão em escala)
- Sprint 4: S6.8 + S6.10 + S6.11 + S6.12 (kanban + notas + digest)

---

## 10. Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| `GET /api/mentees/portfolio` lento se muitos mentorados (N+1 queries) | Alta | Médio | Usar SQL com JOINs e subqueries, não N queries no Python |
| `wa_topics` sem `mentorado_id` consistente (group_jid não mapeado) | Média | Alto | JOIN via group_jid; doc de mapeamento obrigatório no onboarding |
| Digest vazio se N8N classifier não rodou | Alta | Baixo | State explícito "Nenhuma atividade classificada esta semana" |
| `mentee_notes` crescendo ilimitado (sem paginação) | Baixa | Baixo | Endpoint retorna ordenado desc; `?limit=20&offset=0` desde o início |
| Bulk de 50 mentorados causa lock na tabela `mentorados` | Baixa | Médio | UPDATE ... WHERE id = ANY() é atomic; limite de 50 ids previne abusos |
| Snooze não atualiza entre abas abertas (stale state) | Média | Baixo | Ao navegar de volta à carteira, `loadCarteira()` re-fetch filtra snoozed |
| Compound filter AND/OR confuso para usuário leigo | Média | Baixo | Default AND (mais restritivo); tooltip explicando "Mostrar TODOS os critérios" vs "QUALQUER critério" |
| Keyboard shortcuts conflitando com inputs/modais | Alta | Médio | Guards: shortcuts só ativos quando `ui.page === 'carteira'` e nenhum modal/input focado |

---

## 11. Decisões Técnicas Registradas

1. **Digest é client-side, não endpoint** — Os `wa_topics` já são carregados no `loadWaTopics()`. O digest agrega esses dados no frontend sem nova chamada à API. Simplifica o backend.

2. **Portfolio endpoint, não stream** — Todos os dados chegam em uma chamada (`/api/mentees/portfolio`), não em múltiplas. O custo de uma query SQL com JOINs é menor que N chamadas paralelas.

3. **Health score é frontend-only** — Calculado no Alpine.js com base em `dias_sem_interacao`. Sem ML, sem complexidade. Regra simples: ≤3 verde, 4-7 amarelo, >7 vermelho.

4. **Notas são equipe compartilhada** — RLS permite todos autenticados lerem todas as notas. Não é privado por consultor. Modelo colaborativo (equipe CASE trabalha junto nos mentorados).

5. **Carteira é nova página, não substituição** — Nav ganha novo item `carteira`. O `dashboard` original (KPIs, cards) e o `whatsapp` (chat raw) continuam intactos.

6. **Kanban drag-and-drop nativo, sem lib** — HTML5 Drag and Drop API (`dragstart`, `dragover`, `dragleave`, `drop`). Suficiente para esse caso de uso. Não adicionar sortable.js, vue-draggable ou similar — mantém zero dependências no frontend.

7. **Eixo Saúde no Kanban é read-only** — Saúde é calculada (dias sem interação), não um campo editável. Drag entre colunas de saúde não faz sentido. O board de saúde serve para visualização por cluster, não para gestão de estado.

8. **`carteiraView` unifica os 3 modos na mesma página** — Grid, Inbox e Kanban são views da mesma página `carteira`, com os mesmos dados (`data.carteira`). A fonte de dados é carregada uma vez em `loadCarteira()`, os modos apenas reorganizam a apresentação.

9. **Scoped view por padrão, não global** — `ui.carteiraFilter.consultor = 'me'` no init. O consultor logado vê apenas seus mentorados. Gestores podem mudar para 'all'. Isso previne sobrecarga cognitiva em equipes grandes — pattern validado pelo Intercom (team scoping), Front (my inbox) e Gainsight (CSM portfolio).

10. **Snooze em `mentorados`, não tabela separada** — `snoozed_until TIMESTAMPTZ` direto na tabela existente. Uma coluna nullable é infinitamente mais simples que uma join table para um feature de presença/ausência binária. Custo: zero impacto em queries existentes (NULL é o estado padrão).

11. **Bulk via `PATCH /api/mentees/bulk` com limit de 50** — Uma query SQL `UPDATE ... WHERE id = ANY($1::bigint[])` é safe e performática até centenas de registros. Limite de 50 previne abusos sem overhead de pagination. Pattern idêntico ao Zendesk (100-ticket bulk limit) e Linear (50-item batch).

12. **Undo via buffer local, não banco** — O undo de 30s é client-side: salva `{ids, field, previousValues}` em `data.undoBuffer`, aplica PATCH reverso se clicado. Não requer tabela de audit/history. Simples, previsível, suficiente para o caso de uso. Após 30s, o buffer é limpo sem side-effects.

13. **Compound filter AND/OR em memória** — O `GET /api/mentees/portfolio` retorna todos os dados necessários para filtrar. O frontend filtra em `carteiraFiltrada` (computed). Não requer query params no backend. Simplifica o backend e permite filtros instantâneos sem round-trips.

14. **Keyboard shortcuts guard: `ui.page === 'carteira' && !anyInputFocused()`** — Atalhos só ativam quando o usuário está na Carteira e sem modal/input ativo. Evita conflitos com formulários de nota, busca e outros campos. `anyInputFocused()` checa `document.activeElement.tagName`.

15. **Drag bulk: todos os selecionados seguem o card arrastado** — Se `ui.bulkSelected.size > 0`, qualquer drag de um card selecionado arrasta todos os selecionados para a mesma coluna destino. Se o card arrastado NÃO está nos selecionados, drag funciona individualmente (comportamento individual preservado).
