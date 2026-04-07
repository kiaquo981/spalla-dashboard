---
title: "EPIC LF-FASE2: FSMs explícitas em Python (domain/state_machines)"
type: epic
status: pending
priority: P0
parent_epic: EPIC-LF-MASTER.md
depends_on: EPIC-LF-FASE1-event-store.md
created: 2026-04-07
duration: 2-3 weeks
breaking_change: parcial (migrations de CHECK constraints)
---

# EPIC LF-FASE2: State Machines explícitas em Python

## Visão

Criar o módulo `app/backend/domain/` com **classes Python que enforçam transições válidas de estado** pra cada entidade-chave. CHECK constraints no banco continuam (defesa em profundidade), mas a validação real acontece em código antes do INSERT/UPDATE.

## Por que importa

1. **Hoje qualquer código pode setar `god_tasks.status='concluida'` mesmo com subtasks abertas.** A FSM impede isso.
2. **CHECK constraints só validam VALORES**, não TRANSIÇÕES. Você pode pular `pendente → concluida` direto sem passar por `em_andamento`.
3. **Integration tests viram triviais**: você testa a FSM isolada sem precisar de banco.
4. **Ponto único de emissão de eventos**: toda transição passa pela FSM, que dispara `EntityEventStore.emit()`. Garante captura 100%.

## Stories

### Story LF-2.1 — Reconciliação de CHECK Constraints (depende de TAXONOMY-RECONCILIATION.md)

**Como:** sistema
**Eu quero:** CHECK constraints alinhados com o vocabulário canônico decidido na Fase 0
**Pra que:** o frontend não consiga gerar valores que o banco rejeita

**Mudanças:**

1. `god_tasks.status` — adicionar `em_revisao`, `bloqueada`, `pausada`, `arquivada`
   ```sql
   ALTER TABLE god_tasks DROP CONSTRAINT god_tasks_status_check;
   ALTER TABLE god_tasks ADD CONSTRAINT god_tasks_status_check
     CHECK (status IN ('pendente','em_andamento','em_revisao','bloqueada','pausada','concluida','cancelada','arquivada'));
   ```

2. `mentorados.fase_jornada` — alinhar com canônico (manter o que está)
   - DB já tem `onboarding|concepcao|validacao|otimizacao|escala|concluido` ✓
   - Atualizar backend `/api/mentees/{id}` PATCH pra rejeitar valores fora dessa lista (substitui as 5 strings legadas)

3. `god_tasks.tipo` — formalizar enum
   - Hoje é TEXT livre
   - Adicionar CHECK: `tipo IN ('geral','dossie','ajuste_dossie','follow_up','rotina','bug_report','acao')`

**AC:**
- [ ] Migration aplicada
- [ ] Backend `/api/mentees/{id}` PATCH validando apenas valores canônicos
- [ ] Frontend continuando a funcionar (smoke test)

---

### Story LF-2.2 — Módulo `domain/` Base + EntityEventStore

**Como:** dev
**Eu quero:** estrutura de módulos limpa pro código de domínio
**Pra que:** separar lógica de negócio de infra HTTP

**Estrutura:**
```
app/backend/domain/
├── __init__.py
├── state_machines/
│   ├── __init__.py
│   └── base.py          (StateMachine, Transition, exceptions)
├── events/
│   ├── __init__.py
│   ├── store.py         (EntityEventStore, emit())
│   └── types.py         (EventType constants, payload schemas)
└── tests/
    ├── __init__.py
    └── test_base_state_machine.py
```

**`base.py`** (esqueleto na ARCHITECTURE-V2-spalla-applied.md):
- `StateMachine` classe abstrata
- `Transition` dataclass
- `InvalidTransitionError`, `GuardFailedError`
- Método `can_transition(event)`
- Método `transition(event, actor, correlation_id, payload)`
- Auto-emite evento via `EntityEventStore.emit()`

**`store.py`**:
- `EntityEventStore.emit(aggregate_type, aggregate_id, event_type, payload, metadata)`
- Conexão com Supabase via service role
- Suporta correlation_id e causation_id passados por kwarg

**AC:**
- [ ] Estrutura de módulos criada
- [ ] `StateMachine` base testado com FSM mock
- [ ] `EntityEventStore` testado com inserção real em entity_events (sandbox)

---

### Story LF-2.3 — TaskStateMachine

**FSM**:
```
pendente
  ├─[start]→ em_andamento
  ├─[cancel]→ cancelada
  └─[archive]→ arquivada (legacy)

em_andamento
  ├─[request_review]→ em_revisao
  ├─[complete]→ concluida (guard: subtasks_done && checklist_done)
  ├─[block]→ bloqueada (guard: bloqueio_motivo provided)
  ├─[pause]→ pausada
  └─[cancel]→ cancelada

em_revisao
  ├─[approve]→ concluida
  ├─[changes_requested]→ em_andamento
  └─[cancel]→ cancelada

bloqueada
  ├─[unblock]→ em_andamento
  └─[cancel]→ cancelada

pausada
  ├─[resume]→ em_andamento
  └─[cancel]→ cancelada

concluida (terminal exceto reopen)
  ├─[reopen]→ em_andamento (admin only)
  └─[archive]→ arquivada

cancelada (terminal)
  └─[archive]→ arquivada

arquivada (terminal)
```

**Guards:**
- `complete` exige todas as subtasks done E todos os checklists done
- `block` exige `bloqueio_motivo` não-vazio
- `reopen` exige permissão admin (TODO Fase 6 — por agora só requer authenticated)

**Entry actions:**
- `em_andamento` (entry): seta `started_at = now()` se for null
- `concluida` (entry): seta `completed_at = now()`
- `bloqueada` (entry): registra evento adicional `TaskBlocked` com motivo
- `arquivada` (entry): seta `archived_at = now()`

**Eventos emitidos:**
- `TaskCreated` (não pela FSM, pela criação)
- `TaskStarted`, `TaskCompleted`, `TaskBlocked`, `TaskUnblocked`, `TaskPaused`, `TaskResumed`, `TaskCancelled`, `TaskReopened`, `TaskArchived`, `TaskReviewRequested`, `TaskApproved`, `TaskChangesRequested`

**AC:**
- [ ] `TaskStateMachine` em `domain/state_machines/task.py`
- [ ] Test suite com 100% das transições válidas testadas
- [ ] Test suite com 5+ transições inválidas testadas (esperando exception)
- [ ] Guards testados (subtasks aberta → não pode complete)
- [ ] Entry actions testadas (started_at setado)

---

### Story LF-2.4 — MentoradoStateMachine

**FSM** (alinhado com taxonomia DB):
```
[lead → onboarding via contratoAssinado] (lead é estado virtual, fora do CHECK)

onboarding
  ├─[avancar_concepcao]→ concepcao (guard: primeira_call_feita && primeiro_dossie_entregue)
  └─[encerrar]→ encerrado (offboard)

concepcao
  ├─[avancar_validacao]→ validacao (guard: dossie_aprovado)
  └─[encerrar]→ encerrado

validacao
  ├─[avancar_otimizacao]→ otimizacao (guard: primeiras_vendas)
  └─[encerrar]→ encerrado

otimizacao
  ├─[avancar_escala]→ escala
  └─[encerrar]→ encerrado

escala
  ├─[concluir]→ concluido
  └─[encerrar]→ encerrado

concluido (terminal)
encerrado (terminal — soft delete via ativo=false)
```

**Nota:** o backend hoje aceita `onboarding|execucao|resultado|renovacao|encerrado` como valores no PATCH. **Isso é bug**. Esta story corrige.

**AC:**
- [ ] `MentoradoStateMachine` criado
- [ ] Guards verificam pré-requisitos via query (call feita, dossie entregue, etc)
- [ ] Backend `/api/mentees/{id}` refatorado pra usar a FSM
- [ ] Test suite

---

### Story LF-2.5 — DossieProducaoStateMachine

**FSM** (matches CHECK existente):
```
nao_iniciado
  └─[iniciar]→ call_estrategia

call_estrategia
  └─[iniciar_producao]→ producao

producao
  └─[enviar_revisao]→ revisao

revisao
  ├─[aprovar]→ aprovado
  └─[devolver_producao]→ producao

aprovado
  └─[enviar]→ enviado

enviado
  └─[apresentar]→ apresentado

apresentado
  ├─[criar_ajustes]→ ajustes (loop)
  └─[finalizar]→ finalizado

ajustes
  └─[concluir_ajustes]→ apresentado

finalizado (terminal)

* qualquer estado → pausado / cancelado (escapes)
```

**AC:**
- [ ] `DossieProducaoStateMachine` criado
- [ ] Test suite cobrindo loop ajustes ↔ apresentado
- [ ] Refatora `_handle_ds_update_stage` no backend pra usar a FSM

---

### Story LF-2.6 — DossieDocumentoStateMachine (Scale + Clinic)

**FSM Scale**:
```
pendente → producao_ia → revisao_mariza → revisao_kaique → revisao_gobbi → enviado → feedback_mentorado → ajustes → aprovado → finalizado
```

**FSM Clinic**:
```
pendente → producao_ia → revisao_mariza → revisao_paralela → revisao_queila → enviado → feedback_mentorado → ajustes → aprovado → finalizado
```

**Decisão:** modelar como **classe parametrizada por trilha**. Constructor recebe `trilha='scale'|'clinic'` e monta as transições.

**AC:**
- [ ] `DossieDocumentoStateMachine(trilha)` criado
- [ ] Trilhas Scale e Clinic geram transições corretas
- [ ] Test suite cobrindo ambas trilhas
- [ ] Refatora `_handle_ds_update_stage` pra usar (substituindo `DS_VALID_TRANSITIONS` dict)

---

### Story LF-2.7 — DescarregoStateMachine (proativa pra Fase 3)

A FSM do Descarrego é criada agora (no domain/) mas a tabela só nasce na Fase 3. Por que adiantar? Porque queremos saber a forma antes de fazer migration.

**FSM**:
```
capturado
  ├─[start_transcription]→ transcricao_pendente (guard: tipo_bruto in audio/video/gravacao)
  └─[skip_transcription]→ classificacao_pendente (texto direto)

transcricao_pendente
  ├─[transcribed]→ transcrito
  └─[transcription_failed]→ erro

transcrito
  └─[start_classification]→ classificacao_pendente

classificacao_pendente
  ├─[classified]→ classificado
  └─[classification_failed]→ erro

classificado
  ├─[high_confidence]→ executando_acao_automatica (guard: confidence >= 0.8 && not_critical_type)
  └─[needs_human_review]→ aguardando_humano

executando_acao_automatica
  └─[action_taken]→ finalizado

aguardando_humano
  ├─[human_approved]→ executando_acao_manual
  └─[human_rejected]→ rejeitado (terminal)

executando_acao_manual
  └─[action_taken]→ finalizado

erro
  └─[human_intervened]→ qualquer estado anterior (admin retry)

finalizado (terminal)
rejeitado (terminal)
```

**AC:**
- [ ] `DescarregoStateMachine` criado em `domain/state_machines/descarrego.py`
- [ ] Test suite completo
- [ ] (Implementação real conecta com tabela na Fase 3)

---

### Story LF-2.8 — Integração com Endpoints (substituição gradual)

**Endpoints a refatorar:**
- `/api/tasks/create` (POST) — cria task via aggregate, dispara `TaskCreated`
- `/api/tasks/{id}/transition` (POST, NOVO) — wrapper genérico que recebe `event` e chama FSM
- `/api/mentees/{id}` (PATCH) — usa MentoradoStateMachine pra mudança de fase
- `/api/ds/update-stage` (POST) — usa DossieDocumentoStateMachine

**AC:**
- [ ] 4 endpoints refatorados
- [ ] Tentativa de transição inválida retorna 409 Conflict com mensagem clara
- [ ] Backend continua aceitando endpoints legacy por enquanto (graceful migration)

---

### Story LF-2.9 — Test Suite Completo (CI gate)

**AC:**
- [ ] `app/backend/domain/tests/` com pytest
- [ ] ≥80% coverage no módulo `domain/`
- [ ] Test pra cada FSM: matriz completa de transições (válidas + inválidas)
- [ ] Test de event emission: cada transição emite o evento certo em entity_events
- [ ] Roda em CI antes de merge

---

## DoD do Epic LF-FASE2

- [ ] Story LF-2.1 (CHECK reconciliation) ✓
- [ ] Story LF-2.2 (módulo domain + base) ✓
- [ ] Story LF-2.3 (TaskStateMachine) ✓
- [ ] Story LF-2.4 (MentoradoStateMachine) ✓
- [ ] Story LF-2.5 (DossieProducaoStateMachine) ✓
- [ ] Story LF-2.6 (DossieDocumentoStateMachine Scale + Clinic) ✓
- [ ] Story LF-2.7 (DescarregoStateMachine) ✓
- [ ] Story LF-2.8 (4 endpoints refatorados) ✓
- [ ] Story LF-2.9 (test suite completo) ✓
- [ ] PR mergeado em develop
- [ ] Backend deployado no Railway
- [ ] Smoke test: tentar transição inválida via API → 409 Conflict
