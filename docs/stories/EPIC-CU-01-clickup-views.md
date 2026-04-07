---
title: "EPIC CU-01: ClickUp-Quality Task Views"
type: epic
status: in_progress
priority: P0
created: 2026-04-07
owner: kaique
---

# EPIC CU-01: ClickUp-Quality Task Views

## Objetivo
Elevar as 3 task views (Board, List, Calendar) do Spalla ao nivel visual e funcional do ClickUp, sem quebrar o que ja funciona.

## Contexto
Sessao 2026-04-07 tentou reescrever tudo de uma vez (9 PRs). Resultado: layout quebrado em producao. Agora vamos com calma — 1 story por vez, QA antes de merge.

## Stories

### CU-01.1 — Fix: List view ungrouped mode broken
**Status:** todo
**Prioridade:** P0-URGENTE (producao quebrada)
**AC:**
- [ ] `tasksTree` retorna `_currentGroup` e `_isGroupLast` em TODOS os items (nao so quando agrupado)
- [ ] List view renderiza corretamente sem agrupamento ativo
- [ ] List view renderiza corretamente COM agrupamento (status, priority, assignee)
- [ ] "+ Adicionar Tarefa" aparece no final de cada grupo
- [ ] Testar visualmente antes de merge

### CU-01.2 — Cleanup: Remover CSS morto (236 linhas)
**Status:** todo
**Prioridade:** P1
**AC:**
- [ ] Remover regras CSS orfas em 13-APP-styles.css (task-board*, task-card*, task-list__row*)
- [ ] Verificar que nenhuma class removida e referenciada no HTML
- [ ] Board, List e Calendar continuam funcionando apos cleanup
- [ ] Mobile responsive nao quebra

### CU-01.3 — Polish: Board view card refinement
**Status:** todo
**Prioridade:** P2
**AC:**
- [ ] Cards com hover shadow suave
- [ ] Priority badge no topo do card
- [ ] Tags como badges coloridos solidos (nao translucidos)
- [ ] Avatar + data relativa no footer
- [ ] Subtask progress inline
- [ ] Testar drag-and-drop entre colunas
- [ ] Comparar visualmente com screenshot ClickUp

### CU-01.4 — Polish: List view column alignment
**Status:** todo
**Prioridade:** P2
**AC:**
- [ ] Colunas alinhadas horizontalmente (Nome, Responsavel, Data, Prioridade)
- [ ] Status dot antes do titulo
- [ ] Tags inline como badges solidos
- [ ] Data relativa em vermelho quando atrasada
- [ ] Avatar circular pro responsavel
- [ ] Comparar visualmente com screenshot ClickUp

### CU-01.5 — Polish: Calendar view refinement
**Status:** todo
**Prioridade:** P3
**AC:**
- [ ] Hoje destacado em amarelo
- [ ] Tasks com borda colorida por prioridade
- [ ] Drag-to-reschedule funcional
- [ ] Month nav funcional
- [ ] Tasks truncadas a 30 chars no cell

### CU-01.6 — Feature: Sprint detail panel QA
**Status:** todo
**Prioridade:** P2
**AC:**
- [ ] KPIs renderizam com dados reais
- [ ] Burndown bars proporcionais
- [ ] Ativar/Encerrar/Carry-over funcionais
- [ ] Migrations rodadas no Supabase

## Ordem de execucao
1. CU-01.1 (fix urgente)
2. CU-01.2 (cleanup antes de polish)
3. CU-01.3 + CU-01.4 (polish visual — podem ser paralelas)
4. CU-01.5 + CU-01.6 (refinamento)

## Regras
- 1 PR por story
- QA visual antes de merge (screenshot ou browser check)
- Nao misturar fix + feature no mesmo PR
