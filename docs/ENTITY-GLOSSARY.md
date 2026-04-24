---
title: "Operon/Spalla — Entity Glossary (Catálogo de Entidades)"
type: reference
status: canonical
audience: [dev, architect, ai-agents]
created: 2026-04-07
companion: UBIQUITOUS-LANGUAGE.md
---

# Entity Glossary — Operon/Spalla

> Catálogo formal de **TODAS** as entidades do sistema, classificadas por tipo DDD e bounded context. Toda entidade nova precisa ser adicionada aqui.

## Convenções

- **Aggregate Root** = entidade principal de um aggregate, única porta de entrada pra mutações
- **Sub-Entity** = entidade que vive dentro de um aggregate root (pertence)
- **Value Object** = imutável, sem identidade própria
- **Reference Entity** = aggregate root referenciado por outro (foreign key cross-aggregate)
- **Read Model** = projeção (view) pra queries, não tem write side próprio

---

## Bounded Context 1: **Mentorship Core**

### Mentorado [Aggregate Root]
- **Tabela**: `"case".mentorados` (upstream)
- **Identidade**: `id` BIGINT
- **Sub-entities**: marcos_mentorado, mentorado_context (legacy), mentorado_notes
- **State machine**: `fase_jornada` (FSM da jornada do mentorado)
- **Estados**: `onboarding | concepcao | validacao | otimizacao | escala | concluido` (+ encerrado via `ativo=false`)
- **Eventos emitidos**: MentoradoCriado, MentoradoFaseJornadaAtualizada, MentoradoStatusFinanceiroAtualizado, MentoradoSilenciado, MentoradoDesativado, MentoradoMarcoAtingido
- **Invariantes principais**:
  - Não pode mudar de fase pulando estados (FSM enforce)
  - `ativo=false` requer `motivo_inativacao`
- **Quem manipula**: backend `/api/mentees/*`, `/api/welcome-flow/register`

### Marco do Mentorado [Sub-Entity]
- **Tabela**: `marcos_mentorado`
- **Identidade**: `id` UUID
- **Aggregate**: Mentorado
- **State machine**: implícito (existe ou não, via `data_atingido`)
- **Eventos**: MarcoAtingido
- **Invariantes**: M0 a M6 valores válidos

### Contexto (Knowledge Item) [Sub-Entity — legado]
- **Tabela**: `mentorado_context`
- **Identidade**: `id` UUID
- **Aggregate**: Mentorado
- **Status**: legado — será projetado a partir de `descarregos` na Fase 3
- **Quem manipula**: hoje, frontend descarrego diretamente. Após Fase 3, projetor de eventos.

### Mentorado Note [Sub-Entity]
- **Tabela**: `mentee_notes`
- **Identidade**: `id` UUID
- **Aggregate**: Mentorado
- **Tipos**: `livre | checkpoint_mensal | feedback_aula | registro_ligacao`
- **Sem state machine** — pure log

### Plano de Ação [Aggregate Root]
- **Tabela**: `pa_planos`
- **Identidade**: `id` UUID
- **Sub-entities**: pa_fases, pa_acoes (statechart hierárquico)
- **State machine**: `status_geral`
- **Estados**: `nao_iniciado | em_andamento | concluido | pausado`
- **Eventos**: PlanoCriado, PlanoIniciado, PlanoFaseAdicionada, PlanoAcaoAdicionada, PlanoConcluido
- **Invariantes**: 
  - PlanoConcluido só se TODAS as fases concluido
  - Cada fase concluido só se TODAS suas ações em (concluido | nao_aplicavel)
- **Bidirectional sync**: pa_acoes ↔ god_tasks via trigger (legado, será evento na Fase 2)

### Fase de Plano de Ação [Sub-Entity]
- **Tabela**: `pa_fases`
- **Aggregate**: Plano de Ação
- **State machine**: `status` (`nao_iniciado | em_andamento | concluido | pausado`)
- **Tipos**: `revisao_dossie | fase | passo_executivo`

### Ação de Plano de Ação [Sub-Entity]
- **Tabela**: `pa_acoes`
- **Aggregate**: Plano de Ação
- **State machine**: `status` (`pendente | em_andamento | concluido | bloqueado | nao_aplicavel`)
- **Pode ter**: link a `god_tasks` (cross-aggregate reference)

### Onboarding Trilha [Aggregate Root]
- **Tabela**: `ob_trilhas`
- **Identidade**: `id` UUID
- **Sub-entities**: ob_etapas, ob_tarefas
- **State machine**: `status` (`em_andamento | concluido | pausado`)
- **Criação**: instanciada via função `ob_criar_trilha(mentorado_id, ...)` que copia template
- **Templates**: ob_template_etapas + ob_template_tarefas (imutáveis)

### Onboarding Etapa [Sub-Entity]
- **Tabela**: `ob_etapas`
- **State machine**: `status` (`pendente | em_andamento | concluido`)
- **Tipos**: `sequencial | paralelo`

### Onboarding Tarefa [Sub-Entity]
- **Tabela**: `ob_tarefas`
- **State machine**: `status` (`pendente | concluido`)
- **Calculado**: `data_prevista = trilha.data_inicio + prazo_dias`

---

## Bounded Context 2: **Task Management**

### Tarefa [Aggregate Root]
- **Tabela**: `god_tasks`
- **Identidade**: `id` UUID
- **Sub-entities**: god_task_subtasks, god_task_checklist, god_task_comments, god_task_handoffs, god_task_tag_relations, god_task_field_values
- **State machine**: `status`
- **Estados (alvo Fase 2)**: `pendente | em_andamento | em_revisao | bloqueada | pausada | concluida | cancelada | arquivada`
- **Estados atuais (DB CHECK)**: `pendente | em_andamento | concluida | cancelada` (gap a corrigir)
- **Eventos**: TaskCreated, TaskStarted, TaskCompleted, TaskCancelled, TaskBlocked, TaskUnblocked, TaskPaused, TaskResumed, TaskAssigned, TaskTitleChanged, TaskPriorityChanged, TaskAutoCreatedFromCall, TaskAutoCreatedFromDescarrego
- **Invariantes**:
  - `complete` só se subtasks_done && checklist_done
  - `block` exige `bloqueio_motivo`
  - `concluida` é terminal exceto reopen (admin)
- **Triggers ativos**: 
  - `trg_god_tasks_updated` (auto updated_at)
  - `trg_sync_task_to_pa` (sync → pa_acoes)
  - `trg_call_to_tasks` (criação automática a partir de analises_call)

### Subtask [Sub-Entity]
- **Tabela**: `god_task_subtasks`
- **Identidade**: `id` UUID
- **Aggregate**: Tarefa
- **State**: `done` BOOLEAN (binário)

### Checklist Item [Sub-Entity]
- **Tabela**: `god_task_checklist`
- **State**: `done` BOOLEAN

### Task Comment [Sub-Entity]
- **Tabela**: `god_task_comments`
- **Sem state** (immutable log)

### Task Handoff [Sub-Entity]
- **Tabela**: `god_task_handoffs`
- **Sem state** (immutable log)
- **Significado**: registro de quando responsabilidade passou de uma pessoa pra outra

### Task Tag [Value Object compartilhado]
- **Tabelas**: `god_task_tags` (definição) + `god_task_tag_relations` (junction)
- **Atributos**: name, color, scope (`global | space:X | list:X`)

### Custom Field Definition [Aggregate Root menor]
- **Tabela**: `god_task_field_defs`
- **Identidade**: `id` UUID
- **Sem state** (definição estática)
- **Tipos**: text, number, date, select, multi_select, checkbox, url, rating, progress, user

### Custom Field Value [Sub-Entity de Tarefa]
- **Tabela**: `god_task_field_values`
- **Aggregate**: Tarefa (cascade delete)

### Sprint [Aggregate Root menor]
- **Tabela**: `god_lists` WHERE `tipo='sprint'`
- **Identidade**: `id` UUID
- **State machine**: implícito via datas (`sprint_inicio`, `sprint_fim`) e `sprint_status` (planejado | ativo | encerrado)
- **Sub-entities**: tasks vinculadas via `god_tasks.sprint_id`

### Space [Aggregate Root menor]
- **Tabela**: `god_spaces`
- **Identidade**: `id` UUID
- **Sub-entities**: lists
- **Sem state machine** (`ativo` BOOLEAN binário)

### List [Sub-Entity de Space]
- **Tabela**: `god_lists`
- **Aggregate**: Space
- **Tipos**: `geral | sprint | dossie_pipeline | etc`

### Reminder [Aggregate Root menor]
- **Tabela**: `god_reminders`
- **State machine**: `status` (`ativo | concluido | cancelado`)
- **Recorrência**: `recorrencia` (`nenhuma | diario | semanal | mensal`)

### Automation Rule [Aggregate Root]
- **Tabela**: `god_automations`
- **Identidade**: `id` UUID
- **State**: `is_active` BOOLEAN
- **Estrutura**: trigger_type + trigger_config + condition_config + action_type + action_config
- **Sub-entities**: god_automation_log (audit)
- **Tipos de trigger**: `status_changed | due_date_arrived | priority_changed | assigned`
- **Tipos de action**: `change_status | change_assignee | change_priority | send_notification`

### Automation Log [Sub-Entity]
- **Tabela**: `god_automation_log`
- **Aggregate**: Automation Rule
- **Sem state** (immutable execution log)

### Feedback Inbox [Aggregate Root menor]
- **Tabela**: `god_feedback`
- **State machine**: `status` (`novo | em_analise | convertido | descartado`)
- **Pode converter pra**: god_tasks via `converted_task_id`

---

## Bounded Context 3: **Dossie Production**

### Dossiê (Produção) [Aggregate Root]
- **Tabela**: `ds_producoes`
- **Identidade**: `id` UUID
- **Sub-entities**: ds_documentos, ds_ajustes, ds_eventos (audit), ds_transcricoes
- **State machine**: `status`
- **Estados**: `nao_iniciado | call_estrategia | producao | revisao | aprovado | enviado | apresentado | ajustes | finalizado | pausado | cancelado`
- **Eventos**: DossieCriado, DossieIniciado, DossieRevisaoIniciada, DossieAprovado, DossieEnviado, DossieApresentado, DossieAjusteCriado, DossieFinalizado
- **Invariantes**:
  - 1 produção por mentorado (UNIQUE constraint)
  - Status `finalizado` é terminal exceto criação de novos ajustes (loop)

### Dossiê Documento [Sub-Entity]
- **Tabela**: `ds_documentos`
- **Aggregate**: Dossiê
- **Identidade**: `id` UUID
- **State machine**: `estagio_atual` (a FSM mais sofisticada do Spalla)
- **Estados Scale**: `pendente | producao_ia | revisao_mariza | revisao_kaique | revisao_gobbi | enviado | feedback_mentorado | ajustes | aprovado | finalizado`
- **Estados Clinic**: `pendente | producao_ia | revisao_mariza | revisao_paralela | revisao_queila | enviado | feedback_mentorado | ajustes | aprovado | finalizado`
- **Tipos**: `oferta | funil | conteudo`
- **Trilha**: determina quais estágios usar (vive em código Python por enquanto)
- **Eventos**: DocumentoCriado, DocumentoEstagioAtualizado, DocumentoHandoffRealizado
- **Aging tracker**: `estagio_desde` (timestamp do último estágio change)

### Dossiê Ajuste [Sub-Entity]
- **Tabela**: `ds_ajustes`
- **State machine**: `status` (`pendente | em_andamento | concluido`)

### Dossiê Evento [Sub-Entity / Audit]
- **Tabela**: `ds_eventos`
- **Significado**: **mini event store local do dossiê**, quase pronto pra ser projetado pro `entity_events` global na Fase 1
- **Sem state** (immutable)
- **Tipos**: `estagio_change | handoff | ajuste_criado | ajuste_concluido | nota | feedback`

### Dossiê Transcrição [Sub-Entity]
- **Tabela**: `ds_transcricoes`
- **Sem state**

### Dossiê QA Score [Aggregate Root menor]
- **Tabela**: `dossie_qa_scores`
- **Sem state machine** (snapshot de avaliação RAGAS)

### Dossiê Generation Job [Aggregate Root menor]
- **Tabela**: `dossie_generation_jobs`
- **State machine**: `status` (`queued | processing | completed | failed`)
- **Significado**: job de geração de dossiê via Goose Agent (assíncrono)

---

## Bounded Context 4: **Communication**

### Call (de Mentoria) [Aggregate Root]
- **Tabela**: `calls_mentoria`
- **Identidade**: `id` UUID
- **State machine**: `status_call` (`agendada | realizada | cancelada | no_show`) — hoje fraco, gap
- **Sub-entities**: analises_call, call_insights (audit estruturado)
- **Eventos**: CallAgendada, CallRealizada, CallCancelada, CallTranscrita, CallAnalisada
- **Externa**: integra Zoom + Google Calendar

### Análise de Call [Sub-Entity / Aggregate menor]
- **Tabela**: `analises_call`
- **Sem state machine**, mas tem `processado_em`
- **Trigger ativo**: `trg_call_to_tasks` (cria god_tasks automaticamente)
- **Output AI**: tipo_call, sentimento, proximos_passos[], decisoes[], gargalos[], etc

### Call Insight [Aggregate Root menor]
- **Tabela**: `call_insights`
- **Identidade**: `id` UUID
- **Tipos**: `decision | blocker | action | feedback | milestone | risk | insight`
- **State machine**: `status` (aplicável só a `tipo='action'`): `pendente | em_andamento | concluido | cancelado`
- **Cross-aggregate**: pode linkar a `god_tasks` ou `pa_acoes`

### Mensagem WhatsApp [Aggregate menor]
- **Tabela**: `wa_messages`
- **Identidade**: `id` UUID + `message_id` (Evolution API key)
- **State machine**: `_status` (`pending | sent | delivered | read | failed`)
- **Sub-relations**: vinculada a `wa_topic` e `mentorado_id`

### WhatsApp Topic [Aggregate Root]
- **Tabela**: `wa_topics`
- **Identidade**: `id` UUID
- **State machine**: `status` (`open | active | pending_action | resolved | archived | converted_task`)
- **Sub-entity**: wa_topic_events (mini event store local)
- **AI**: embedding pgvector pra semantic dedup, ai_keywords, ai_participants
- **Eventos**: TopicCreated, TopicStatusChanged, TopicTitleEdited, TopicTaskLinked, TopicMessageAdded, TopicAiReclassified, TopicManuallyMerged, TopicArchived

### WA Topic Event [Sub-Entity / Audit]
- **Tabela**: `wa_topic_events`
- **Aggregate**: WA Topic
- **Sem state** (immutable log)

### WA Message Queue [Aggregate Root menor — sistema]
- **Tabela**: `wa_message_queue`
- **State machine**: `status` (`pending | processing | done | error | skipped | dead_letter`)
- **Significado**: **outbox + dead letter queue + saga recovery em 1 tabela**. Modelo a seguir.
- **Recovery function**: `recover_stuck_queue(stuck_minutes, max_retries)` — reset de stuck + DLQ

### WA Group [Aggregate menor]
- **Tabela**: `wa_groups`
- **Identidade**: `group_jid` (WhatsApp ID)
- **Pode linkar a**: mentorado

### WA Session [Aggregate menor — sistema]
- **Tabela**: `wa_sessions`
- **Significado**: tracking de instâncias Evolution API ativas

---

## Bounded Context 5: **Knowledge Capture**

### Descarrego [Aggregate Root — A SER CRIADO NA FASE 3]
- **Tabela**: `descarregos` (nova)
- **Identidade**: `id` UUID
- **State machine**: `status`
- **Estados**: `capturado | transcricao_pendente | transcrito | classificacao_pendente | classificado | aguardando_humano | executando_acao_automatica | executando_acao_manual | finalizado | rejeitado | erro`
- **Eventos**: DescarregoCaptured, DescarregoTranscribed, DescarregoClassified, DescarregoActionTaken, DescarregoFinalized, DescarregoRejected, DescarregoError, DescarregoEscalated
- **Saga**: `DescarregoProcessor` (capturar → transcrever → classificar → ação)
- **Cross-aggregate**: pode criar Tarefa, atualizar Mentorado

### Contexto (Knowledge Item) — legacy
- Ver Bounded Context 1 (será refatorado pra ser projeção de Descarrego)

### Storage File [Aggregate Root menor]
- **Tabela**: `sp_arquivos`
- **State machine**: `status_processamento` (`pendente | processando | processado | erro`)
- **Sub-entities**: sp_chunks (vector embeddings)

### Storage Chunk [Sub-Entity]
- **Tabela**: `sp_chunks`
- **Aggregate**: Storage File
- **Significado**: pedaço de texto vetorizado pra semantic search

### Documento da Biblioteca [Aggregate menor]
- **Tabela**: `sp_documentos`
- **Sem state machine** (snapshot estático)

---

## Bounded Context 6: **Financial**

### Financial Snapshot [Aggregate menor]
- **Tabela**: `god_financial_snapshots`
- **Identidade**: `snapshot_date` DATE (PK)
- **Sem state machine** (snapshot semanal via cron)
- **Função**: `fn_financial_snapshot()` agrega `mentorados.status_financeiro`

### Financial Log [Audit]
- **Tabela**: `god_financial_logs`
- **Sem state** (immutable audit)
- **Tipos de action**: `status_change | note | contract_update`

---

## Bounded Context 7: **Analytics & Read Models** (CQRS Read Side)

Tabelas/views que **não são entidades** mas projeções:

| View | Projeta de | Propósito |
|------|-----------|-----------|
| `vw_god_overview` | mentorados + calls + tasks + dossies | Dashboard principal |
| `vw_god_timeline` | calls + marcos + analises | Timeline cronológica |
| `vw_god_cohort` | mentorados | Segmentação N1/N2 |
| `vw_god_contexto_ia` | extracoes_agente | Latest AI extractions |
| `vw_god_calls` | calls + analises | Inventário de calls |
| `vw_god_tarefas` | god_tasks + pa_acoes + ob_tarefas | Task board unificado |
| `vw_god_pendencias` | tudo pendente | Bottleneck detection |
| `vw_god_tasks_full` | god_tasks + sub_entities | Task detail nested JSON |
| `vw_pa_pipeline` | pa_planos + pa_fases + pa_acoes | PA progress |
| `vw_ds_pipeline` | ds_producoes + ds_documentos | Dossie progress |
| `vw_ds_metrics` | ds_eventos | Métricas de dossiê |
| `vw_ds_production_queue` | ds_producoes (active) | Work queue |
| `vw_ob_pipeline` | ob_trilhas + ob_tarefas | Onboarding progress |
| `vw_call_insights_summary` | call_insights | Summary por mentorado |
| `vw_wa_topic_board` | wa_topics + wa_messages | Kanban WhatsApp |
| `vw_wa_queue_status` | wa_message_queue | Queue health |
| `vw_god_financeiro` | god_financial_snapshots | Financial dashboard |
| `vw_pipeline_health` | tudo | Overall health |
| `vw_activity_feed` | calls + tasks + topics + dossies | Unified feed |
| `vw_entity_timeline` | entity_events (Fase 1) | Journey log |
| `vw_correlation_timeline` | entity_events (Fase 1) | Saga tracking |

---

## Resumo Quantitativo

| Categoria | Quantidade |
|-----------|-----------|
| Aggregate Roots | ~25 |
| Sub-Entities | ~20 |
| Value Objects | ~5 |
| Read Models (Views) | ~21 |
| Bounded Contexts | 7 |
| Tables totais (auditadas) | ~46 |
| State machines explícitas (CHECK) | 12+ |
| State machines em código (Python) | 1 (`DS_VALID_TRANSITIONS`) |
| Triggers ativos | 12+ |
| Bridge functions | 4 |

---

## Quem Manipula Cada Aggregate (resumo)

| Aggregate | Backend endpoints | Frontend | Triggers |
|-----------|-------------------|----------|----------|
| Mentorado | `/api/mentees/*` | dashboard, ficha | - |
| Tarefa | `/api/tasks/*`, `/api/clickup/*` | tasks page, drawer | trg_call_to_tasks, trg_sync_task_to_pa |
| Dossiê | `/api/ds/update-stage` | dossies page, ficha tab | ds_updated triggers |
| Plano de Ação | (direto via Supabase) | pa page, ficha tab | trg_sync_pa_to_task |
| Call | `/api/schedule-call`, `/api/calls/*` | agenda, ficha tab | trg_call_to_tasks |
| WA Message | webhook | wa page | - |
| WA Topic | (n8n + AI) | wa topics page | trg_wa_topics_updated_at |
| WA Queue | webhook + cron | wa management | recover_stuck_queue() |
| Descarrego | `/api/descarrego/*` (Fase 3) | descarrego page, ficha tab | (Fase 3) |

---

**Versão**: v1.0 (2026-04-07)
