---
title: "EPIC LF (Master): Lifecycle Foundation — State Machines, Event Store & Sagas"
type: epic
status: in_progress
priority: P0
owner: kaique
created: 2026-04-07
related_docs:
  - docs/ARCHITECTURE-state-machines-lifecycle-journey.md
  - docs/ARCHITECTURE-V2-spalla-applied.md
sub_epics:
  - EPIC-LF-FASE0-vocabulary.md
  - EPIC-LF-FASE1-event-store.md
  - EPIC-LF-FASE2-state-machines.md
  - EPIC-LF-FASE3-descarrego-saga.md
---

# EPIC LF (Master): Lifecycle Foundation

## Visão

Estabelecer a fundação arquitetural do Operon/Spalla pra todo processo com IA: **state machines explícitas, event store unificado, sagas formais e entidades com lifecycle visível**. Isso destrava o orquestrador de descarrego, process mining, health score dinâmico, e todo workflow automatizado futuro.

## Por que agora

1. **Bloqueador estratégico**: o orquestrador de descarrego (input do Kaique → IA → task auto-criada) é arquiteturalmente inviável sem isso. Sem Descarrego como entidade com FSM, qualquer orquestração com IA fica frágil e invisível.
2. **Débito técnico crescente**: 3 taxonomias diferentes pra "fase do mentorado", `em_revisao`/`bloqueada`/`pausada`/`arquivada` no frontend mas não no CHECK do banco, dual-write entre `pa_acoes` ↔ `god_tasks`. Cada semana que passa é mais cara de consertar.
3. **G-3M-1 (Pipeline dossies end-to-end sem Kaique)**: precisa de saga observável pra garantir SLO de entrega.
4. **M1 (Infra para operadores escalarem)**: operadores não conseguem trabalhar autonomamente sem journey log unificado.

## Filosofia da execução

**Zero breaking change até o fim da Fase 2.** Tudo é aditivo: adiciona tabelas, adiciona triggers, adiciona módulos Python sem alterar comportamento existente. Só na Fase 3 começamos a substituir caminhos antigos por novos, ainda com fallback.

**Captura ANTES de enforce.** Primeiro logamos eventos passivamente (Fase 1). Depois, com dados reais em mãos, refinamos as FSMs (Fase 2). Só então construímos a saga sobre fundação validada (Fase 3).

## Sub-Epics

| Fase | Epic | Duração | Output principal |
|------|------|---------|------------------|
| **0** | [LF-FASE0: Vocabulary](EPIC-LF-FASE0-vocabulary.md) | 1 sem | `UBIQUITOUS-LANGUAGE.md` + `ENTITY-GLOSSARY.md` + `TAXONOMY-RECONCILIATION.md` |
| **1** | [LF-FASE1: Event Store](EPIC-LF-FASE1-event-store.md) | 1 sem | Migration `entity_events` + triggers + view, capturando passivamente |
| **2** | [LF-FASE2: State Machines](EPIC-LF-FASE2-state-machines.md) | 2-3 sem | `app/backend/domain/state_machines/` em Python + migrations de CHECK constraints |
| **3** | [LF-FASE3: Descarrego Saga](EPIC-LF-FASE3-descarrego-saga.md) | 2-3 sem | Tabela `descarregos` + `DescarregoStateMachine` + `DescarregoProcessor` saga + endpoint |

## Critério de Sucesso (DoD do Epic Master)

- [ ] Vocabulário canônico publicado e validado com Kaique + Mariza + Queila
- [ ] Tabela `entity_events` capturando 100% dos INSERT/UPDATE/DELETE de tabelas-chave (god_tasks, ds_*, pa_*)
- [ ] FSMs explícitas em código pra: Task, Mentorado, DossieProducao, DossieDocumento, Descarrego
- [ ] Tentativa de transição inválida via API retorna 409 Conflict com mensagem explicativa
- [ ] Tabela `descarregos` substituindo `mentorado_context` para novos inputs
- [ ] Saga `DescarregoProcessor` executando: capturar → transcrever → classificar → ação
- [ ] Endpoint `POST /api/descarrego/process` funcional com HITL (confidence threshold)
- [ ] Dado real: ≥1k eventos capturados em `entity_events` na primeira semana de produção
- [ ] Journey query funcional: "mostra timeline completa da entidade X" via view `vw_entity_timeline`

## Métricas de Sucesso (long-tail, mensuráveis)

| Métrica | Target em 30d | Target em 90d |
|---------|---------------|---------------|
| Cobertura de captura (% ações com evento) | 60% | 95% |
| Correlation coverage (% eventos com correlation_id) | 30% | 70% |
| Transições inválidas bloqueadas (#) | >0 | >100 |
| Taxa de erro de saga descarrego | <20% | <5% |
| HITL approval rate (sugestões IA) | >70% | >85% |
| Tempo pra responder "o que aconteceu com X" | <10min | <2min |

## Riscos & Mitigações

| Risco | Severidade | Mitigação |
|-------|------------|-----------|
| Breaking changes em produção | Alta | Fases 1-2 são puramente aditivas. Fase 3 com fallback dual-write durante migração. |
| Performance degradação por triggers | Média | Triggers em `entity_events` usam `EXCEPTION WHEN OTHERS` pra nunca bloquear transação. |
| Mariza/Queila resistência ao novo vocabulário | Média | Fase 0 inclui workshop de validação, não imposição. |
| Saga descarrego com classificação ruim | Média | HITL em todo confidence < 0.8, métricas de approval rate. |
| Drift entre FSM Python e CHECK constraint SQL | Baixa | Test suite que valida ambos batem. CI checa. |

## Branch & Release Strategy

- Branch: `feature/case/lifecycle-foundation`
- Sub-branches por Fase: `feature/case/lf-fase0`, `lf-fase1`, etc
- Cada Fase = 1 PR pra develop, mergeado em ordem
- Vercel deploys auto cada fase
- Railway redeploy quando Fase 2+ tem mudança em backend Python

## Time / RACI

| Atividade | R | A | C | I |
|-----------|---|---|---|---|
| Fase 0 (vocab) | Claude (research) | Kaique | Mariza, Queila | time |
| Fase 1 (event store) | Claude | Kaique | - | time |
| Fase 2 (FSMs) | Claude | Kaique | Mariza | time |
| Fase 3 (saga) | Claude | Kaique | Mariza, Queila | time |
| Code review | Claude (CodeRabbit) | Kaique | - | - |
| Deploy decision | Kaique | Kaique | - | - |
