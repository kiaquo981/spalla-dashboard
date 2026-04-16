---
title: "Handoff — Session 2026-04-08"
type: handoff
status: active
created: 2026-04-08
session_prs: 501-507
total_prs: 7
branch: develop (all merged)
previous_session: HANDOFF-SESSION-2026-04-07.md
---

# Handoff — Session 08/04/2026

## O que foi entregue (7 PRs mergeados)

| PR | Branch | O que |
|---|---|---|
| #501 | `feature/case/gantt-svg-lines` | SVG bezier arrows entre tasks com `depends_on` (viewBox 0-1000, red blocking / purple resolved) |
| #502 | `feature/case/gantt-drag-resize` | Drag handles nas bordas da barra do Gantt (left=data_inicio, right=data_fim, touch support) |
| #503 | `feature/case/fsm-endpoints` | 3 endpoints transition: mentorado, dossiê produção, dossiê documento |
| #504 | `feature/case/frontend-transition-api` | Frontend `updateTaskStatus()` migrado pra `/api/tasks/{id}/transition` com 21 event mappings |
| #505 | `feature/case/descarrego-refinamento` | Classifier 11 tipos + contexto enriquecido + aba Contexto v2 (filtros, expand, reclassificação) |
| #506 | `feature/case/trigger-rules-preconfig` | 7 trigger rules pré-configuradas (mentorado lifecycle + dossiê aprovado) |
| #507 | `feature/case/batch-descarrego` | Batch import endpoint (até 20 items) + frontend UI com auto-process |

**Cache version**: v=223 (JS)

---

## O que ficou pendente — Pipeline de execução

### Bloco 1: WA Intelligence Layer (8 stories)
**Bloqueador**: 2 patches n8n precisam ser aplicados manualmente
- `docs/n8n-patches/PATCH-fallback-requer-resposta.json` (10 regras)
- `docs/n8n-patches/PATCH-classificar-enriquecer-completo.json` (ehDescartavel, team no-pendencia)
- View `vw_wa_mentee_activity` precisa ser criada (unifica wa_messages + interacoes_mentoria + wa_topics)

**Stories (ordem):**
1. Story 7 — Map `interacoes_mentoria` vs `whatsapp_messages`
2. Story 2 — Painel pendências no Command Center
3. Story 1 — Resumo semanal por mentorado
4. Story 4 — Perguntas sem resposta da equipe
5. Story 3 — Timeline de atividades unificada
6. Story 5 — Notas/percepções (47k existentes)
7. Story 6 — Alertas no Command Center
8. Story 8 — Audit n8n workflow v34

**EPIC**: `docs/EPIC-WA-INTELLIGENCE-LAYER.md`

### Bloco 2: CodeRabbit QA (15 lows pendentes)
- 15 issues low-priority do CodeRabbit da sessão de Dragons (#448)
- Ref: `HANDOFF-SESSION-2026-04-07.md` → seção "Dragons potenciais novos"

### Bloco 3: Dragons 52-55
- **Dragon 52**: Undo/Redo pra edições inline (Cmd+Z)
- **Dragon 53**: Bulk edit no Meu Trabalho (multi-select → batch update)
- **Dragon 54**: Notificação in-app (badge + toast quando task atribuída)
- **Dragon 55**: Keyboard shortcuts no Gantt (←→, Enter, Space)

### Bloco 4: Stories pendentes (spec pronta)
- **STORY-3.1**: Dashboard equipe (workload por membro)
- **STORY-3.2**: Tarefas recorrentes (rrule melhorado)
- **STORY-3.3**: Health Score mentorado (0-100, 6 dimensões)
- **STORY-5.1**: Upload inteligente (11 tipos arquivo)
- **STORY-5.2**: Pastas virtuais por mentorado

### Bloco 5: ClickUp Internalization restante
- **Fase 4**: ClickUp sync bidirecional full (webhook receiver existe, falta full import paginated)
- **Fase 5**: Automations engine UI + Dashboard widgets (cron existe, UI básica existe)
- Ref: `.claude/plans/kind-nibbling-cat.md` e `docs/research-clickup-internalization.md`

### Bloco 6: EPICs não começados
- **EPIC-TAREFAS-FOLLOWUP**: 10 stories (follow-up automático, notificação WA, tipos tarefa)
- **PRD V2 Epics**: Financeiro, Documentos/Wiki, Calls/Agenda

### Bloco 7: Infra / Env vars
- `YOUTUBE_API_KEY` no Railway (auto-upload calls)
- `GOOGLE_DRIVE_FOLDER_ID` no Railway (sync automático)
- Maestro n8n workflows (6 workflows pra importar manualmente)

---

## Endpoints novos desta sessão

| Método | Path | O que |
|--------|------|-------|
| POST | `/api/mentees/{id}/transition` | FSM mentorado (8 estados, 12 eventos) |
| POST | `/api/dossies/producoes/{id}/transition` | FSM dossiê produção (6 estados) |
| POST | `/api/dossies/documentos/{id}/transition` | FSM dossiê documento (Scale 7 / Clinic 10 estados) |
| POST | `/api/descarrego/{id}/reclassify` | Reclassificação manual com audit trail |
| POST | `/api/descarrego/batch-capture` | Batch import (até 20 items, auto_process) |

## Classifier v2 — tipos suportados

| Tipo | Ação automática |
|------|----------------|
| task | Cria god_task com prazo/responsável |
| lembrete | Cria god_task prioridade alta com prazo |
| escalacao | Cria god_task urgente pro Kaique |
| contexto | Salva em mentorado_context |
| dossie | Salva em mentorado_context (fase=dossie) |
| feedback | Salva em mentorado_context (fase=feedback) |
| plano_acao | Salva em mentorado_context (fase=plano_acao) |
| reembolso | Sem ação automática (aguarda humano) |
| bloqueio | Sem ação automática (aguarda humano) |
| duvida | Sem ação automática |
| celebracao | Sem ação automática |

## Trigger rules ativas (migration 20260408110000)

| Evento | Task criada | Responsável | Prazo |
|--------|------------|-------------|-------|
| contract_signed → onboarding | Kickoff call | Mariza | 2d |
| kickoff_done → concepcao | Iniciar dossiê | Queila | 5d |
| strategy_validated → validacao | Acompanhar validação | Kaique | 14d |
| ready_to_scale → escala | Atualizar dossiês | Queila | 7d |
| cycle_complete → concluido | Encerramento formal | Mariza | 5d |
| cancel → encerrado | Análise de churn | Kaique | 3d |
| Dossiê approve → aprovado | Agendar entrega | Mariza | 3d |

**Nota**: Migration precisa ser aplicada via `supabase db push` (RLS bloqueia insert via anon key).

---

## Gotchas desta sessão

- **Rebase conflicts**: PRs paralelos de develop conflitam no cache version (`v=XXX`) e no bloco de `ui` state — sempre pegar a versão mais alta e manter TODOS os states
- **Next.js validation hook**: dispara em TODOS os edits de `.html` e `.py` — irrelevante (projeto é vanilla HTML/Alpine.js + Flask). Ignorar sempre.
- **RLS em task_trigger_rules**: anon key não consegue INSERT. Precisa service_role key ou aplicar via migration.
- **supabase db push --include-all**: migrations orphan (`20260319120000`) causam conflito. Usar `migration repair --status applied` antes.

---

## Ordem sugerida de execução (próxima sessão)

1. **Aplicar migration trigger rules** (`supabase db push` ou SQL direto com service_role)
2. **WA Intelligence Story 7** (map interacoes vs whatsapp_messages)
3. **WA Intelligence Story 2** (painel pendências)
4. **15 CodeRabbit lows** (QA visual batch)
5. **Dragons 52-55** (undo/redo, bulk edit, notificações, shortcuts)
6. **STORY-3.3 Health Score** (independente, alto impacto)
7. **ClickUp Fase 4-5** (sync full + automations UI)
