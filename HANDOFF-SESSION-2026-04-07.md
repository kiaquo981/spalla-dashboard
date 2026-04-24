---
title: "Handoff — Monster Session 2026-04-07"
type: handoff
status: active
created: 2026-04-07
session_prs: 456-499
total_prs: 44
branch: develop → main (synced)
---

# Handoff — Monster Session 07/04/2026

## O que foi entregue (44 PRs mergeados)

### EPIC LF — Lifecycle Foundation (Fases 0-3)
**Status: COMPLETO em prod**

| Fase | PRs | O que |
|---|---|---|
| Fase 0 | #456 | UBIQUITOUS-LANGUAGE.md (50+ termos), ENTITY-GLOSSARY.md (~46 entidades), TAXONOMY-RECONCILIATION.md (5 conflitos) |
| Fase 1 | #456 | `entity_events` table + `emit_entity_event()` PL/pgSQL + 15 triggers + `vw_entity_timeline` + `vw_correlation_timeline` |
| Fase 2 | #456 | 5 FSMs Python: Task(8 estados), Mentorado(8), DossieProducao(6), DossieDocumento(Scale+Clinic), Descarrego(11). 33 testes. |
| Fase 2.5 | #456 | Tarefa como aggregate central: especie, depends_on[], rrule, task_trigger_rules, vw_meu_trabalho |
| Fase 3 backend | #456 | Tabela descarregos + saga processor + GPT-4o-mini classifier + 5 endpoints + HITL |
| Fase 3 frontend | #457 | Pipeline descarregos na aba Contexto |

### EPIC CU-01 — ClickUp Views
**Status: COMPLETO**

| Story | PR |
|---|---|
| CU-01.1 List view ungrouped fix | #467 |
| CU-01.3 Board polish | (visual tweaks em PRs de fix) |

### EPIC CU-02 — ClickUp Deep (5/6 done)
**Status: 5/6 — Gantt SVG deferred**

| Story | PR | Status |
|---|---|---|
| CU-02.1 Task Detail Drawer | #492 | ✅ 8 status + acompanhante + tipo + especie |
| CU-02.2 List View inline | Já existia | ✅ Inline edit em todas colunas |
| CU-02.3 Custom Fields UI | #494 | ✅ Inline edit by type (text/number/date/checkbox/select) |
| CU-02.4 View System | Já existia | ✅ 7 views + saved views + tabs |
| CU-02.5 Sidebar v2 | Já existia | ✅ Spaces/Lists/Sprints CRUD |
| CU-02.6 Gantt dependências | #497 | ⚠️ Indicadores visuais sim, SVG lines NÃO |

### MVP-LF (6 stories)
**Status: COMPLETO**

| Story | PR |
|---|---|
| Workers (recurring + trigger) | #460 |
| Modo EU (Meu Trabalho) | #461 + #469 + #472 + #474 + #482 + #484 + #486 + #488 + #490 |
| Descarrego create modal | #462 |
| Task espécies UI | #463 |
| Task transition API | #464 |
| Smoke test script | #465 |

### Infra & Fixes
| O que | PR |
|---|---|
| Sprint rollover automático | #458 |
| CI fix (openapi exclude + SQL DROP) | #459 |
| Normalize responsavel lowercase | #470 |
| Cache busting (v=135 → v=214) | #480 + vários |
| Realtime 4 canais | #496 |
| ClickUp auto-sync bidirecional | #498 |
| Sprint config (duração por space) | #476 |

---

## O que ficou pendente (próximas sessões)

### P0 — Executar imediatamente

#### 1. Gantt SVG Lines (CU-02.6 completo)
**O que é:** Desenhar setas SVG reais conectando barras do Gantt entre tasks que têm `depends_on`.
**Onde:** `app/frontend/10-APP-index.html` linha ~4808 (seção gantt-view) + `11-APP-app.js` (novo getter `ganttDependencyLines`)
**Como:**
- Pra cada task no `ganttTasks` que tem `depends_on[]`, encontrar as tasks dependentes no array
- Calcular posição Y (índice * row height) de ambas as tasks
- Calcular posição X (fim da barra da task dependente → início da barra da task dependente)
- Renderizar `<line>` ou `<path>` SVG com arrow marker
- Precisa de DOM position calculation — usar `getBoundingClientRect` ou calcular por índice
**AC:**
- [ ] Setas visíveis entre tasks com depends_on
- [ ] Arrow head no final da seta (marker-end)
- [ ] Cor diferente por tipo (blocking = vermelho, normal = roxo)
- [ ] Não quebra performance com 80 tasks

#### 2. CU-02.6 Drag-to-resize no Gantt
**O que é:** Arrastar bordas da barra pra mudar data_inicio/data_fim.
**Onde:** `.gantt-bar` no HTML (adicionar drag handles) + JS handlers
**Como:**
- Adicionar divs de 6px nas bordas esquerda/direita da barra
- mousedown → captura posição inicial + data correspondente
- mousemove → calcula nova data baseado em pixels/dia
- mouseup → PATCH god_tasks com nova data_inicio ou data_fim
**AC:**
- [ ] Drag na borda esquerda muda data_inicio
- [ ] Drag na borda direita muda data_fim
- [ ] Visual feedback durante drag (barra se expande/contrai)
- [ ] Persist no Supabase

---

### P1 — Desdobrar em stories

#### 3. Descarrego Classifier — Orquestrador Completo
**O que já existe:**
- `domain/services/descarrego_classifier.py` — GPT-4o-mini classifica em 7 tipos
- `_descarrego_processor_run()` em `14-APP-server.py` — saga capturado→transcrito→classificado→ação
- Endpoints: `/api/descarrego/capture`, `/process`, `/approve`, `/reject`
- Frontend: modal de captura + pipeline UI na aba Contexto

**O que falta:**
- **Refinamento do classifier**: testar com inputs reais do Kaique, ajustar prompt, calibrar confidence thresholds
- **Mais tipos de ação**: hoje só cria task ou salva contexto. Falta: criar lembrete, escalar pra Kaique (WhatsApp), criar plano de ação item, vincular a dossiê
- **Contexto enriquecido**: passar últimas 5 interações do mentorado pro classifier pra melhorar acurácia
- **Batch processing**: endpoint pra processar múltiplos descarregos de uma vez (ex: importar 10 áudios de WhatsApp)
- **Feedback loop**: quando humano corrige classificação, salvar pra fine-tuning futuro
- **Métricas**: dashboard de accuracy, confidence distribution, ações tomadas por tipo

**Onde começa:** `app/backend/domain/services/descarrego_classifier.py` (prompt), `_descarrego_execute_action()` em server.py (ações)

#### 4. Descarrego Process Endpoint — Full Pipeline
**O que já existe:** endpoint assíncrono funcional (202 Accepted + thread daemon)
**O que falta:**
- **Whisper transcrição**: OPENAI_API_KEY precisa estar no Railway env. Função `openai_whisper()` existe mas não foi testada end-to-end com áudio real
- **Retry com backoff**: hoje retry_count incrementa mas não há lógica de re-tentativa automática
- **Progress tracking**: frontend faz polling mas poderia usar Realtime (canal descarregos já existe)
- **Cancellation**: não tem como cancelar um processo em andamento
- **Timeout**: saga pode ficar travada se Whisper/GPT demorar. Adicionar timeout de 120s

**Teste ouro (script pronto):** `scripts/lf_smoke_test.py` — rodar com `RAILWAY_URL` + `AUTH_TOKEN` + `SUPABASE_ANON_KEY`

#### 5. Frontend: Contexto Tab Completa
**O que já existe:**
- Seção Pipeline de Descarregos (aba Contexto da ficha do mentorado)
- Modal de captura (texto + áudio com MediaRecorder)
- Botões Processar/Aprovar/Rejeitar (HITL)
- Realtime subscribe em descarregos

**O que falta:**
- **Filtros na aba Contexto**: por tipo (texto/áudio), por classificação, por status
- **Expandir conteúdo**: click no card expande pra ver transcrição completa
- **Edição de classificação**: quando humano rejeita, poder reclassificar manualmente
- **Vinculação com task**: quando descarrego cria task, link clicável pra abrir a task
- **Vinculação com dossiê**: se classificação = dossiê, link pra produção correspondente
- **Upload de arquivo**: além de texto/áudio, suportar PDF, imagem, vídeo
- **Batch import de WhatsApp**: importar áudios diretamente do feed WA do mentorado

#### 6. Process Button + Classification UI (#61)
**O que é:** Botão de processar mais prominent + UI de classificação detalhada
**O que falta:**
- **Classificação visual**: card com primary_type como badge grande, subtype, confidence meter, summary
- **Ação sugerida**: "IA sugere: criar task pra Kaique com prazo quinta" com botão confirmar
- **Override**: dropdown pra mudar classificação antes de confirmar
- **Histórico**: timeline de ações tomadas no descarrego (capturado → transcrito → classificado → aprovado → task criada)

---

### P2 — Dragons pendentes

#### Dragons do plano original (docs/stories/EPIC-CU-01)
Os 51 dragons originais foram implementados em sessões anteriores. Verificar se há dragons residuais:

```
Implementados: 1-51 (sessão 2026-04-07 madrugada)
Pendentes de QA visual: 15 lows do CodeRabbit
```

#### Dragons potenciais novos
- **Dragon 52**: Undo/Redo pra edições inline (Cmd+Z)
- **Dragon 53**: Bulk edit no Meu Trabalho (selecionar múltiplas → batch update status/responsável)
- **Dragon 54**: Notificação in-app quando task é atribuída a mim (badge + toast)
- **Dragon 55**: Keyboard shortcuts no Gantt (←→ navegar, Enter abrir, Space toggle)

---

### P3 — FSMs que precisam de exercício real

#### TaskStateMachine
**Arquivo:** `app/backend/domain/state_machines/task.py`
**Status:** Implementada com 8 estados, 12 eventos, 3 guards (template, depends_on, quest children)
**Endpoint:** `POST /api/tasks/{id}/transition` (#464)
**O que falta:**
- Frontend consumir o endpoint (hoje ainda faz PATCH direto no status)
- Migrar todos os `updateTaskStatus()` do frontend pra usar `/transition` ao invés de PATCH direto
- Isso garante que guards rodam (ex: não pode completar quest com filhos abertos)

#### MentoradoStateMachine
**Arquivo:** `app/backend/domain/state_machines/mentorado.py`
**Status:** Implementada (8 estados: lead→escala→concluido)
**O que falta:**
- Endpoint `POST /api/mentees/{id}/transition` (não existe ainda)
- Frontend: dropdown de fase_jornada no ficha do mentorado usar o endpoint
- Trigger rules: "quando mentorado muda pra concepcao, criar task de primeiro dossiê"

#### DossieProducaoStateMachine + DossieDocumentoStateMachine
**Arquivo:** `app/backend/domain/state_machines/dossie.py`
**Status:** Implementadas (Scale 7 estados, Clinic 10 estados com 4 pilares)
**O que falta:**
- Endpoints de transição pra dossiês
- Frontend: integrar com a aba Dossiês
- Workflow automático: quando todos documentos de uma produção chegam em 'aprovado', produção transiciona pra 'aprovado' automaticamente

#### DescarregoStateMachine
**Arquivo:** `app/backend/domain/state_machines/descarrego.py`
**Status:** Implementada (11 estados com guards de tipo + confidence)
**Integração:** Já usada no endpoint `/process` e `/approve`/`/reject`
**O que falta:**
- Frontend mostrar o estado da FSM explicitamente (step indicator visual)
- Guard de retry: máximo 3 retries antes de requer intervenção humana

---

## Arquitetura atual (pós-sessão)

```
Frontend (Vercel — main)
  10-APP-index.html  (~12.3K linhas)
  11-APP-app.js      (~11K linhas)
  13-APP-styles.css  (~8K linhas)
  Cache bust: v=214 (JS) + v=210 (CSS)

Backend (Railway — main)
  14-APP-server.py   (~6.7K linhas)
  domain/
    state_machines/
      base.py          — StateMachine base class
      task.py          — 8 estados, 12 eventos, 3 guards
      mentorado.py     — 8 estados (lead→concluido)
      dossie.py        — ProducaoFSM + DocumentoFSM (Scale/Clinic)
      descarrego.py    — 11 estados, guards de tipo + confidence
      test_fsm.py      — 33 testes passing
    services/
      descarrego_classifier.py — GPT-4o-mini

  Daemon threads (6):
    1. _sheets_sync_loop         — Google Sheets sync
    2. _automations_cron         — Automations engine (5min)
    3. _recurring_tasks_cron     — Legacy recurring (1h)
    4. _sprint_rollover_cron     — Sprint rollover (6h + boot)
    5. _lf_recurring_scheduler   — RRULE materializer (5min)
    6. _lf_trigger_listener      — entity_events → task rules (30s)
    7. _clickup_auto_sync        — ClickUp push (10min)

Database (Supabase — knusqfbvhsqworzyhvip)
  Migrations aplicadas: 20260408000000 → 20260408100000 (11 novas)
  entity_events: append-only event store com 15 triggers
  descarregos: FSM pipeline table
  task_trigger_rules: regras declarativas
  vw_meu_trabalho: tela do operador
  vw_sprint_dashboard: stats do sprint
  vw_entity_timeline + vw_correlation_timeline: journey log
  fn_sprint_rollover(): automação semanal
  fn_materialize_recurring_due(): scheduler SQL
  fn_apply_trigger_rules(): listener SQL
  fn_rrule_next_occurrence(): RRULE parser SQL

Realtime: 4 canais Supabase
  god_tasks, descarregos, mentorados, god_task_comments
```

## Bugs conhecidos

1. **Meu Trabalho**: funciona mas UX pode melhorar (status badges sem background colorido no ClickUp real têm pill com fundo)
2. **List view colunas**: custom fields adicionados via modal nativo (Data inicial, Status como toggle) não são custom fields reais — são campos nativos tratados como toggle de visibilidade. Pode confundir.
3. **Sprint sidebar**: sprints antigos (Sprint 1/2/3) mostram "0" tasks porque as tasks foram movidas pro sprint ativo. Considerar esconder sprints com 0 tasks ou marcar como arquivados.

## Env vars necessárias no Railway

| Var | Status | Pra quê |
|---|---|---|
| OPENAI_API_KEY | ⚠️ Verificar | Whisper transcrição + GPT-4o-mini classifier |
| CLICKUP_API_TOKEN | ✅ | Bidirecional sync |
| SUPABASE_URL | ✅ | Tudo |
| SUPABASE_ANON_KEY | ✅ | Tudo |
| EVOLUTION_API_KEY | ✅ | WhatsApp |

## Ordem sugerida de execução

1. **Gantt SVG lines** (CU-02.6 completo) — visual, rápido
2. **Gantt drag-to-resize** — UX
3. **FSM endpoints** (mentorado + dossiê) — backend
4. **Frontend migrar pra /transition** — frontend
5. **Descarrego classifier refinamento** — IA
6. **Contexto tab filtros + expand** — frontend
7. **Trigger rules pré-configuradas** (mentorado fase → task automática)
8. **Batch descarrego import** — backend + frontend
