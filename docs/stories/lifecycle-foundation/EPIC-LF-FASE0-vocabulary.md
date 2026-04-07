---
title: "EPIC LF-FASE0: Ubiquitous Language + Entity Glossary"
type: epic
status: in_progress
priority: P0
parent_epic: EPIC-LF-MASTER.md
created: 2026-04-07
duration: 1 week
breaking_change: false
---

# EPIC LF-FASE0: Ubiquitous Language + Entity Glossary

## Visão

Estabelecer **vocabulário canônico único** pro Operon/Spalla. Hoje temos 3 taxonomias diferentes pra "fase do mentorado", status de task que existe no frontend mas não no banco, "trilha" Scale vs Clinic vivendo em strings espalhadas. Isso é débito técnico crescente. A Fase 0 resolve no nível conceitual e documental, sem código de produção.

## Por que importa

Sem vocabulário unificado, **todas** as fases seguintes ficam frágeis. Como vou criar `TaskStateMachine` se não sei quais são todos os estados válidos? Como vou logar evento `MentoradoFaseAtualizada` se temos 3 valores possíveis pra "fase"?

Vocabulário fragmentado = bugs latentes em produção (constraint violation), confusão de quem entra novo no time, decisões impossíveis de tomar sem perguntar.

## Stories

### Story LF-0.1 — Glossário Canônico (Ubiquitous Language)

**Como:** arquiteto do sistema
**Eu quero:** um documento único com TODOS os termos do domínio Operon/Spalla
**Pra que:** qualquer dev ou stakeholder consiga ler e entender sem perguntar

**Escopo:**
- `docs/UBIQUITOUS-LANGUAGE.md` — glossário com cada termo do domínio
- Cada termo: definição em 1-2 linhas + exemplo + tabelas/colunas onde aparece
- Termos a cobrir: Mentorado, Tarefa, Dossiê, Call, Sprint, Plano de Ação, Onboarding, Descarrego, Contexto, Trilha (Scale/Clinic), Marco, Fase, Fase Jornada, Status (de cada entidade), Estágio, Risco Churn, Health Score, Consultor, Responsável, Acompanhante, Sentimento, Confidence, etc

**AC (Acceptance Criteria):**
- [ ] Documento com ≥40 termos
- [ ] Cada termo tem: definição, exemplo de uso, referência a tabela/campo do banco
- [ ] Inclui termos em PT (canônico) com equivalentes em EN quando relevante (pra integração externa)
- [ ] Validação visual com Kaique

**DoD:**
- [ ] Arquivo criado
- [ ] Linkado no README do projeto
- [ ] Mencionado no CLAUDE.md

---

### Story LF-0.2 — Entity Glossary (Catálogo de Entidades)

**Como:** arquiteto do sistema
**Eu quero:** catálogo formal de TODAS as entidades do Spalla com seu papel no DDD
**Pra que:** o time saiba o que é aggregate root, o que é sub-entidade, qual o bounded context

**Escopo:**
- `docs/ENTITY-GLOSSARY.md` — uma seção por entidade
- Cada entidade: tabela, identidade, tipo (aggregate root / sub-entity / value object), bounded context, sub-entidades, FSM (se tem), eventos emitidos (se algum)

**Entidades a catalogar:**
1. Mentorado (aggregate root)
2. Tarefa (god_tasks)
3. Subtask, Checklist, Comment, Tag (sub-entities da Tarefa)
4. Dossiê Produção (ds_producoes)
5. Dossiê Documento (ds_documentos, sub-entity)
6. Dossiê Ajuste (ds_ajustes)
7. Plano de Ação (pa_planos)
8. Fase de PA (pa_fases, sub-entity)
9. Ação de PA (pa_acoes, sub-entity)
10. Onboarding Trilha (ob_trilhas)
11. Onboarding Etapa (ob_etapas)
12. Onboarding Tarefa (ob_tarefas)
13. Call (calls_mentoria)
14. Análise de Call (analises_call)
15. Call Insight (call_insights)
16. WhatsApp Message (wa_messages)
17. WhatsApp Topic (wa_topics)
18. WhatsApp Topic Event (wa_topic_events)
19. WhatsApp Message Queue (wa_message_queue)
20. Descarrego (NOVO — a ser criado na Fase 3)
21. Contexto (legacy — mentorado_context)
22. Sprint (god_lists tipo='sprint')
23. Space (god_spaces)
24. List (god_lists)
25. Custom Field Definition + Value
26. Automation (god_automations)
27. Reminder (god_reminders)
28. Feedback Inbox (god_feedback)
29. Financial Snapshot (god_financial_snapshots)
30. Financial Log (god_financial_logs)

**AC:**
- [ ] Todas 30 entidades catalogadas
- [ ] Distinção clara: aggregate root vs sub-entity vs value object
- [ ] Bounded context atribuído a cada
- [ ] FSM listada quando existe (mesmo que implícita via CHECK)

**DoD:**
- [ ] Arquivo criado
- [ ] Cross-referenced com `UBIQUITOUS-LANGUAGE.md`

---

### Story LF-0.3 — Taxonomy Reconciliation (Conflitos Resolvidos)

**Como:** arquiteto do sistema
**Eu quero:** documento que mapeia TODOS os conflitos de taxonomia atuais e a resolução proposta
**Pra que:** Fase 2 (FSMs) tenha base sólida pra escolher os valores canônicos sem ambiguidade

**Conflitos identificados na auditoria do V2:**

1. **Fase Jornada Mentorado** — 3 valores diferentes
   - DB CHECK: `onboarding | concepcao | validacao | otimizacao | escala | concluido`
   - Backend `/api/mentees/{id}` PATCH: `onboarding | execucao | resultado | renovacao | encerrado`
   - Frontend mistura

2. **Status de Tarefa** — bug latente
   - DB CHECK: `pendente | em_andamento | concluida | cancelada`
   - Frontend referencia: `em_revisao | atrasada | bloqueada | pausada | arquivada` (não existem no CHECK!)

3. **Tipo de Call** — duas listas
   - DB: onboarding/estrategia/acompanhamento/oferta/conselho/qa/destrave/conteudo
   - Frontend scheduleForm: acompanhamento/diagnostico/planejamento/fechamento

4. **Trilha** (Scale/Clinic)
   - Existe como string em código Python (`DS_VALID_TRANSITIONS`), não em tabela

5. **Status financeiro**
   - mentorados: em_dia | atrasado | quitado
   - Outros lugares: pago, cancelado, etc

**Escopo:**
- `docs/TAXONOMY-RECONCILIATION.md` — uma seção por conflito
- Cada conflito: lista valores atuais, escolhe canônico, lista pontos a atualizar (DB CHECK, código Python, código JS)
- Plano de migração (qual ordem mexer pra não quebrar)

**AC:**
- [ ] Todos 5 conflitos mapeados
- [ ] Decisão de valor canônico documentada com justificativa
- [ ] Plano de migração com ordem de execução

**DoD:**
- [ ] Arquivo criado
- [ ] Decisões assinadas por Kaique (validação humana)
- [ ] Marcado como input pra Story LF-2.1

---

## Não-Escopo (Out of Scope)

- ❌ Mudanças no banco de dados (zero migrations nesta fase)
- ❌ Mudanças no código Python ou JS
- ❌ Implementação de FSMs (vai pra Fase 2)
- ❌ Workshop presencial de Event Storming (faz na Fase 2 se necessário)

## DoD do Epic LF-FASE0

- [ ] Story LF-0.1 (UBIQUITOUS-LANGUAGE.md) ✓
- [ ] Story LF-0.2 (ENTITY-GLOSSARY.md) ✓
- [ ] Story LF-0.3 (TAXONOMY-RECONCILIATION.md) ✓
- [ ] Sem código de produção alterado
- [ ] PR mergeado em develop
- [ ] Kaique validou os 3 documentos
