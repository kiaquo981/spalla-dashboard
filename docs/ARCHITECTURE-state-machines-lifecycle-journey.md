---
title: "Operon/Spalla — State Machines, Entity Lifecycle & Journey Log"
type: architecture
status: research
audience: [architect, dev, product]
created: 2026-04-07
author: Kaique (research) + Claude Opus (synthesis)
related:
  - docs/DOSSIE-PIPELINE.md
  - app/backend/14-APP-server.py
  - supabase/migrations/
---

# State Machines, Entity Lifecycle & Journey Log
## Como orquestrar processos com IA no Operon/Spalla

> **Propósito deste documento.** Estabelecer a fundação conceitual e arquitetural pra que toda entidade do sistema (mentorado, dossiê, task, call, mensagem, contexto, plano de ação) tenha: **(1)** um ciclo de vida explícito com estados válidos e transições guardadas, **(2)** um log de jornada imutável que responde "quando isso mudou, por que, quem fez, e o que aconteceu depois", **(3)** regras claras de onde ela nasce, onde mora, quem executa cada etapa, e quando ela morre. Sem isso, qualquer orquestração com IA vira caos não-determinístico.

---

## Parte I — Fundamentos Conceituais

### 1. Entidades, Value Objects e Aggregates (DDD)

**Entidade** é um objeto que tem **identidade única** (ID) e **ciclo de vida** próprio. Ela muda ao longo do tempo mas continua sendo a mesma coisa. No Operon: `Mentorado`, `Tarefa`, `Dossie`, `Call`, `MensagemWhatsApp` são todas entidades.

**Value Object** é imutável e não tem identidade. É definido pelos seus atributos. Se dois value objects têm os mesmos atributos, são iguais. No Operon: `Endereco`, `Periodo`, `ValorMonetario`, `Prioridade` são value objects.

**Aggregate** é um cluster de entidades e value objects tratados como unidade de consistência. Tem um **Aggregate Root** — a única entidade acessível de fora. Modificações internas sempre passam pelo root. Isso garante **invariantes** (regras que nunca podem ser violadas).

> "Aggregates encapsulate business rules, domain logic, and data integrity for a specific concept within the domain." — [Lucidchart DDD Event Storming Guide](https://www.lucidchart.com/blog/ddd-event-storming)

**Exemplo Operon:**
- `Mentorado` é um aggregate root. Ele contém: `Contexto[]`, `FasesJornada[]`, `StatusFinanceiro`, `Consultor`.
- `Tarefa` é outro aggregate root separado que **referencia** Mentorado por ID mas NÃO é parte do aggregate de Mentorado.
- `Dossie` é aggregate root separado com sub-entidades `Oferta`, `Posicionamento`, `Funil`, cada uma com seu sub-lifecycle.

**Por que separar?** Performance (carregar o aggregate inteiro toda vez é custoso) e consistência (transações locais dentro do aggregate, eventual consistency entre aggregates via eventos).

Refs: [Aggregates & Entities in DDD — Paul Rayner](http://thepaulrayner.com/blog/aggregates-and-entities-in-domain-driven-design/), [Understanding Domain Entities — Khalil Stemmler](https://khalilstemmler.com/articles/typescript-domain-driven-design/entities/)

---

### 2. Ubiquitous Language

Todo termo técnico do código tem que bater 1:1 com o vocabulário do negócio. **Não existe tradução**. Se a Mariza chama de "dossiê" o documento que o time produz, o código chama de `Dossie`, a tabela chama de `dossies`, o endpoint chama de `/api/dossies`. Nunca "document" ou "brief".

No Operon: `mentorado` (não "client"), `call de mentoria` (não "meeting"), `descarrego` (não "dump" ou "brain-dump"), `dossiê` (não "report"), `trilha scale/clinic` (não "track"), `fase do funil` (não "stage").

**Anti-pattern:** backend usa `customer`, frontend usa `mentee`, UI mostra `aluno`. Resultado: confusão, bugs, reuniões explicando o que cada termo significa.

Ref: [Domain-Driven Design — Wikipedia](https://en.wikipedia.org/wiki/Domain-driven_design)

---

### 3. Finite State Machines (FSM)

Uma máquina de estados finitos tem:
- **Estados**: conjunto finito de condições possíveis (`pendente`, `em_andamento`, `concluida`)
- **Transições**: regras que permitem passar de um estado pra outro
- **Eventos**: triggers que disparam transições
- **Guards**: condições booleanas que precisam ser verdadeiras pra a transição acontecer
- **Actions**: efeitos colaterais executados durante/após a transição (entry, exit, during)

**Exemplo:** Uma `Tarefa` no Operon:

```
pendente --[start]--> em_andamento --[complete]--> concluida
                          |
                          +--[block]--> bloqueada
                          +--[cancel]--> cancelada
```

**Guard**: `[complete]` só é permitida se todas as subtasks estão concluídas.
**Entry action**: ao entrar em `em_andamento`, setar `started_at = now()`.
**Exit action**: ao sair de `em_andamento` pra `concluida`, setar `completed_at = now()` e disparar evento `TaskCompleted`.

> "We must prevent illegal transitions. To protect the integrity of the physical shipping process, we enforce a strict state machine." — [Use State Machines! — Richard Clayton](https://rclayton.silvrback.com/use-state-machines)

**Por que FSM é crítica?** Porque sem ela, qualquer código pode setar `status = 'concluida'` mesmo que a task ainda tá bloqueada. A FSM **força** a validação. Invariantes viram parte da estrutura.

Ref: [State Machine in a DDD Context — Patric Steiner](https://patricsteiner.github.io/state-machine-in-a-ddd-context/)

---

### 4. Statecharts (David Harel, 1987) — FSM com Superpoderes

FSMs simples sofrem **state explosion**: se você tem 5 estados principais e cada um tem 3 sub-estados, você precisa de 15 estados flat na FSM. Se adicionar uma dimensão paralela (ex: `timer_rodando`), vira 30. Impossível manter.

**Statecharts** resolvem isso com 3 extensões:

1. **Hierarchy (nested states):** Um estado pode conter sub-estados. Ex: `em_andamento` contém `{pausado, ativo, aguardando_input}`. Transições do estado pai aplicam a todos os filhos.

2. **Concurrency (parallel regions):** Duas FSMs rodando em paralelo dentro do mesmo objeto. Ex: uma task pode estar `em_andamento` (região 1) E `watched_by_user` (região 2) simultaneamente. Cada região tem seu estado ativo independente.

3. **History states:** Ao voltar pra um estado composto, lembrar qual sub-estado estava ativo. Ex: pausar uma task e voltar pro mesmo sub-estado onde parou.

Harel introduziu isso no paper clássico [*Statecharts: A Visual Formalism for Complex Systems* (1987)](https://www.state-machine.com/doc/Harel87.pdf). Biblioteca moderna de referência: [XState (Stately.ai)](https://stately.ai/docs/xstate) implementa SCXML-compliant statecharts pra JavaScript/TypeScript.

> "Statecharts are compact and expressive—small diagrams can express complex behavior—as well as compositional and modular." — [Statecharts.dev](https://statecharts.dev/)

**Exemplo Operon:** O estado de um `Dossie` é naturalmente hierárquico:

```
Dossie
├─ coletando_inputs (parallel)
│  ├─ audios_pendentes
│  ├─ audios_transcritos
│  └─ analise_chamadas
├─ em_producao
│  ├─ oferta
│  │  ├─ rascunho
│  │  ├─ em_revisao
│  │  └─ aprovada
│  ├─ posicionamento (mesma estrutura)
│  └─ funil (mesma estrutura)
├─ em_revisao_final
│  ├─ revisao_kaique
│  ├─ revisao_mariza
│  └─ revisao_queila
├─ entregue
└─ arquivado
```

Cada sub-estado tem suas próprias transições. A revisão paralela (kaique + mariza + queila) é uma **parallel region** — os 3 rolam simultâneos e só convergem pra `entregue` quando todos aprovam.

---

### 5. Petri Nets — Concorrência com Tokens

Petri nets são uma alternativa matematicamente rigorosa pra modelar workflows concorrentes. A notação tem 3 elementos:

- **Places** (círculos): estados ou condições
- **Transitions** (retângulos): eventos que podem ocorrer
- **Tokens** (bolinhas): marcam quais places estão ativos

Uma transição "dispara" quando todos os places de entrada têm pelo menos 1 token. Quando dispara, consome os tokens de entrada e cria tokens nos places de saída.

**Por que importa?** Petri nets modelam naturalmente:
- **And-split**: uma transição produz tokens em múltiplos places (paralelização)
- **And-join**: uma transição consome tokens de múltiplos places (sincronização/rendezvous)
- **Or-split/join**: decisões condicionais

É a base teórica de workflow engines como Camunda, Activiti, e do próprio BPMN.

**Exemplo Operon:** Pipeline de produção de dossiê:
```
[audio_uploaded] → (transcreve) → [transcrito] → (extract patterns)
                                                        ↓
  [oferta_draft]  ←  (split)  ← [analise_concluida] (and-split)
       ↓
  (revisao)  →  [revisao_ok]  ↘
                                (and-join) → [dossie_pronto]
  [posicionamento_ok] ↗
       ↑
  [funil_ok] ↗
```

Refs: [Petri Net — Wikipedia](https://en.wikipedia.org/wiki/Petri_net), [Petri-Nets as a conceptual standard for workflows](http://www.project-open.com/en/workflow-petri-nets)

---

### 6. Event Sourcing — Capturando a Jornada, Não Só o Destino

**Princípio fundamental:** ao invés de guardar só o **estado atual** de cada entidade, você guarda a **sequência de eventos** que levou ela a esse estado. O estado atual é sempre derivado replayando os eventos.

> "With event sourcing, we capture the journey rather than the just destination." — [Martin Fowler, Event Sourcing](https://martinfowler.com/eaaDev/EventSourcing.html)

**Estrutura típica:**

```
event_store:
  id | aggregate_id | aggregate_type | event_type     | payload           | occurred_at | actor
  1  | task-123     | Tarefa         | TaskCreated    | {titulo, prioridade} | 10:00 | kaique
  2  | task-123     | Tarefa         | TaskAssigned   | {responsavel: "mariza"} | 10:05 | kaique
  3  | task-123     | Tarefa         | TaskStarted    | {}                | 10:30 | mariza
  4  | task-123     | Tarefa         | TaskBlocked    | {motivo: "aguardando cliente"} | 14:00 | mariza
  5  | task-123     | Tarefa         | TaskUnblocked  | {}                | 16:00 | mariza
  6  | task-123     | Tarefa         | TaskCompleted  | {}                | 17:00 | mariza
```

Pra saber o estado atual da task-123, você replaya os 6 eventos em ordem. Cada evento aplica uma mutação na projeção. Estado atual = resultado do fold.

**Benefícios:**
1. **Audit trail completo e gratuito.** Não precisa de tabela `audit_log` paralela. O event store É o audit log.
2. **Temporal queries.** "Qual era o status da task-123 às 15:00?" Trivial: replaya eventos até 15:00.
3. **Debugging.** Dá pra reproduzir qualquer bug replayando eventos de produção em ambiente de teste.
4. **Correções históricas.** Eventos são imutáveis, mas dá pra emitir eventos compensatórios (`TaskCorrected`) que revertem efeitos.
5. **Múltiplas projeções.** O mesmo event stream pode alimentar N read models (tabela de tasks, view de burndown, dashboard de velocity).

**Snapshots:** pra entidades com centenas de eventos, replayar tudo é caro. Solução: periodicamente salvar um snapshot do estado em um ponto específico, e só replayar eventos a partir dali.

Refs: [Event Sourcing Pattern — Microsoft Learn](https://learn.microsoft.com/en-us/azure/architecture/patterns/event-sourcing), [Audit log with event sourcing — Arkency](https://blog.arkency.com/audit-log-with-event-sourcing/), [Event Sourcing vs CDC — Debezium Blog](https://debezium.io/blog/2020/02/10/event-sourcing-vs-cdc/)

---

### 7. CQRS — Separando Escrita de Leitura

**Command Query Responsibility Segregation** é o pattern de separar os modelos de dados:
- **Write model (Command side):** validação de invariantes, lógica de negócio, aggregate roots, event store
- **Read model (Query side):** projeções otimizadas pra queries específicas (dashboard, tabelas, charts)

> "The core concept of CQRS is that you can use a different model to update information than the model you use to read information." — [Martin Fowler, CQRS](https://martinfowler.com/bliki/CQRS.html)

**Por que?** Porque queries e commands têm necessidades opostas:
- Commands precisam de consistência forte, transações, validação complexa
- Queries precisam de velocidade, joins pré-calculados, índices específicos

**CQRS + Event Sourcing** é uma combinação natural: os commands produzem eventos, os eventos alimentam múltiplas projeções (read models) que servem queries diferentes.

**Trade-off:** eventual consistency. Uma query feita 50ms depois de um command pode não ver o efeito ainda. Pra casos críticos (ex: cadastrar task e imediatamente ver na lista), você pode forçar sincronização ou usar optimistic UI update.

No Operon atual, `vw_god_tasks_full` é essencialmente um read model CQRS (join de `god_tasks` + `god_task_subtasks` + `god_task_comments` + `god_task_tags`). A migração pra event sourcing seria: eventos disparados por triggers no Postgres alimentam a view, mantendo o write model simples.

Refs: [CQRS Pattern — Microsoft Learn](https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs), [A Beginner's Guide to CQRS — kurrent.io](https://www.kurrent.io/cqrs-pattern)

---

### 8. Domain Events vs Integration Events

**Domain Event:** fato que aconteceu dentro de um bounded context. Exemplo: `TaskCompleted` é relevante pro contexto de gestão de tarefas. Handlers dentro do mesmo contexto reagem a isso (atualizar burndown, notificar watchers, etc).

**Integration Event:** fato publicado pra outros bounded contexts consumirem. Exemplo: `DossieEntregue` é relevante pro contexto de Financeiro (faturar), Cliente (notificar via WhatsApp), Pipeline (mover mentorado pra próxima fase).

Domain events geralmente são publicados **dentro da mesma transação** do aggregate. Integration events são publicados **fora da transação**, via outbox pattern, pra garantir que evento só sai se a transação comitou.

> "Domain Events are handled within the same transaction, while Integration Events are handled outside the transaction and often become messages sent to an Events Bus to other Bounded Contexts." — [AWS Cloud Operations — Domain Consistency](https://aws.amazon.com/blogs/mt/achieve-domain-consistency-in-event-driven-architectures/)

---

### 9. Outbox Pattern — Consistência entre BD e Broker

**O problema:** você precisa atualizar o BD E publicar um evento num broker (RabbitMQ, Kafka, n8n webhook). Se o BD comita mas o publish falha → evento perdido. Se publica primeiro mas BD falha → evento fantasma. Two-phase commit não escala.

**A solução:** em vez de publicar direto no broker, você **insere o evento numa tabela `outbox` na mesma transação** do BD. Depois, um worker assíncrono lê `outbox`, publica no broker, marca como enviado. Se falhar, retry.

```sql
BEGIN;
  UPDATE god_tasks SET status = 'concluida' WHERE id = 'task-123';
  INSERT INTO outbox (aggregate_id, event_type, payload)
    VALUES ('task-123', 'TaskCompleted', '{"by":"mariza"}');
COMMIT;
-- Depois, worker polls outbox e publica
```

**Garantias:**
- Se BD falha → nada foi gravado, nada é publicado. ✓
- Se publish falha → worker retenta até sucesso. ✓
- No máximo uma vez publicado por evento (idempotência via `message_id`).

Refs: [Transactional Outbox — AWS Prescriptive Guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/transactional-outbox.html), [The Outbox Pattern — dev.to](https://dev.to/igornosatov_15/the-outbox-pattern-a-love-letter-to-eventual-consistency-3ch3)

---

### 10. Saga Pattern — Transações Distribuídas

Uma **saga** é uma sequência de transações locais onde cada uma atualiza seu aggregate e publica um evento que dispara a próxima. Se qualquer passo falha, a saga executa **transações compensatórias** que desfazem os passos anteriores.

Duas implementações:

**Choreography (descentralizada):** cada serviço escuta eventos e decide o que fazer. Ninguém "comanda". Funciona bem pra sagas simples, mas fica difícil entender o fluxo quando tem 10+ serviços escutando.

**Orchestration (centralizada):** um orchestrador comanda explicitamente cada passo. "Faça X no serviço A. Se deu certo, faça Y no serviço B. Se Y falhou, desfaça X." Mais fácil de raciocinar, monitorar, debugar.

> "BPMN can be used to describe a saga. Flow engines based on BPMN can directly execute compensation out of the box." — [BPMN and Microservices Orchestration — Camunda](https://camunda.com/blog/2018/08/bpmn-microservices-orchestration-part-2-graphical-models/)

**Exemplo Operon — Saga de Produção de Dossiê:**
1. `Mentorado` envia áudio → `AudioRecebido`
2. Saga aciona serviço de transcrição → `AudioTranscrito`
3. Saga aciona extractor de patterns → `PatternsExtraidos`
4. Saga cria 3 tasks paralelas (oferta/posicionamento/funil) → `TasksCriadas`
5. Cada task é trabalhada pelo responsável → `TaskConcluida` (3x)
6. Saga espera todas → aciona revisão paralela → `DossieRevisado`
7. Saga entrega → `DossieEntregue`

Se qualquer passo falha (ex: transcrição dá erro), saga dispara compensações: remove tasks criadas, notifica Kaique, volta status pra `erro_na_transcricao`.

Refs: [Microservices Pattern: Saga — microservices.io](https://microservices.io/patterns/data/saga.html), [Saga: How to implement complex business transactions — Bernd Rücker](https://blog.bernd-ruecker.com/saga-how-to-implement-complex-business-transactions-without-two-phase-commit-e00aa41a1b1b)

---

### 11. BPMN — A Notação Padrão

**Business Process Model and Notation** é o standard ISO 19510 pra descrever processos de negócio visualmente. Tem símbolos pra:
- **Activities** (retângulos): o que precisa ser feito
- **Gateways** (losangos): decisões, paralelizações, sincronizações
- **Events** (círculos): início, fim, intermediários (timer, mensagem, erro)
- **Pools & Lanes**: quem é responsável por cada atividade
- **Sequence flows**: ordem de execução
- **Message flows**: comunicação entre pools

Engines como [Camunda](https://camunda.com/), [Activiti](https://www.activiti.org/), [Flowable](https://www.flowable.com/), [Zeebe](https://zeebe.io/) executam BPMN diretamente.

**Por que importa pro Operon?** BPMN é a linguagem que o não-dev (Kaique, Mariza, Queila) consegue ler e entender. Se você desenha o processo de produção de dossiê em BPMN, todo mundo vê o mesmo processo. O código executa exatamente o que tá no diagrama.

Ref: [Wikipedia — BPMN](https://en.wikipedia.org/wiki/Business_Process_Model_and_Notation)

---

### 12. Durable Execution (Temporal.io, Restate)

**Problema:** workflows reais duram horas, dias, meses (ex: "esperar 48h depois de mandar a oferta e só depois fazer follow-up"). Um processo tradicional não sobrevive a crashes, reinicializações, deploys.

**Solução:** durable execution engines como [Temporal.io](https://temporal.io/) persistem o estado completo do workflow automaticamente. Se o servidor crasha, o workflow **continua exatamente de onde parou** em outro processo, com todas as variáveis locais e o ponto exato na linha de código.

Conceitos-chave:
- **Workflow**: código que coordena atividades. Durable.
- **Activity**: unidade de trabalho (chamada API, DB write). Pode falhar e ser retentada.
- **Signal**: input assíncrono enviado a um workflow em execução. Ex: "aprove o dossiê agora".
- **Timer**: pausa o workflow por X tempo (durable — sobrevive a crashes).
- **Event History**: log imutável de tudo que aconteceu no workflow.
- **Continue-As-New**: pra workflows infinitos, limpa o histórico e recomeça com o mesmo ID e estado.

> "Because the full running state of a Workflow is durable and fault tolerant by default, your business logic can be recovered, replayed, or paused at any point." — [Temporal Platform Documentation](https://docs.temporal.io/workflow-execution)

**Aplicação Operon:** o orquestrador de descarrego que transcreve + classifica + cria tasks é um workflow que pode durar 30-60s. Se der erro no meio, Temporal retenta automaticamente. Follow-ups agendados pra daqui a 7 dias ficam "pausados" num timer durable.

Ref: [Temporal: Beyond State Machines — temporal.io blog](https://temporal.io/blog/temporal-replaces-state-machines-for-distributed-applications)

---

### 13. Choreography vs Orchestration — Quando Escolher

| Dimensão | Choreography | Orchestration |
|----------|--------------|---------------|
| Controle | Distribuído | Centralizado |
| Acoplamento | Baixo | Médio |
| Visibilidade | Difícil | Fácil |
| Debugging | Difícil (trace distribuído) | Fácil (1 lugar) |
| Complexidade do fluxo | Simples | Arbitrária |
| Mudança de fluxo | Rearranja serviços | Muda o orchestrator |

**Regra prática:**
- ≤3 passos, fluxo linear → choreography (cada serviço escuta o evento do anterior)
- 4-10 passos, lógica de negócio complexa → orchestration (workflow engine)
- >10 passos ou branching pesado → BPMN engine com visualização

**Operon recomendação:** orchestration pra pipelines de dossiê (complexo, crítico, precisa observabilidade). Choreography pra notificações simples (task criada → manda WhatsApp).

---

### 14. Event Storming — Descobrindo o Modelo

**Event Storming** é um workshop criado por Alberto Brandolini (2012) pra descobrir o modelo de domínio RAPIDAMENTE com todos os stakeholders numa parede só.

**Como funciona:**
1. Reúne devs + negócio numa sala com uma parede gigante
2. Pegue post-its **laranjas** e escreve todos os **domain events** que acontecem no sistema (nome no passado: "PedidoRecebido", "DossieEntregue")
3. Ordena no tempo
4. Adiciona post-its **azuis** pros **commands** que causam os eventos ("ReceberPedido", "EntregarDossie")
5. Adiciona **amarelos** pros **aggregates** (entidades que contêm as regras)
6. Identifica **hotspots** (conflitos, dúvidas) em vermelho
7. Agrupa aggregates em **bounded contexts** (verde)

Resultado: um mapa visível do domínio inteiro, que serve de blueprint pra arquitetura, pra event store, pras FSMs.

**Vou propor um Event Storming do Operon** na Parte III.

Refs: [Event Storming — Wikipedia](https://en.wikipedia.org/wiki/Event_storming), [Event Storming 101 — Lucidchart](https://www.lucidchart.com/blog/ddd-event-storming)

---

### 15. RACI Matrix — Quem Faz o Quê

Pra cada **atividade** no processo, definir 4 papéis:

| Letra | Significado | Regra |
|-------|-------------|-------|
| **R** | Responsible — quem executa | 1 ou mais pessoas |
| **A** | Accountable — quem responde pelo resultado | **Exatamente 1 pessoa** |
| **C** | Consulted — quem dá input antes | 0 ou mais |
| **I** | Informed — quem é notificado depois | 0 ou mais |

**Regra sagrada:** só pode ter **um** Accountable por atividade. Senão, ninguém é.

**Aplicação Operon:** cada state machine de uma entidade tem um RACI associado a cada transição.

| Atividade | R (quem faz) | A (responsável final) | C (consultado) | I (informado) |
|-----------|--------------|----------------------|----------------|---------------|
| Transcrever áudio de descarrego | IA (Whisper) | Kaique | - | Consultor |
| Classificar descarrego | IA (GPT-4o) | Kaique | - | Consultor |
| Criar task a partir de descarrego | Consultor | Kaique | - | Responsável designado |
| Produzir dossiê (oferta) | Queila/Mariza | Mariza | Kaique | Mentorado |
| Revisão final de dossiê | Kaique | Kaique | Mariza, Queila | Mentorado |

Isso vai direto no código como metadata da state machine. O orquestrador de IA sabe quem notificar em cada transição.

Ref: [RACI Chart — Atlassian Work Management](https://www.atlassian.com/work-management/project-management/raci-chart)

---

### 16. Process Mining — Descobrindo o Processo Real

Você tem um processo **desenhado** (o que você acha que acontece) e o processo **real** (o que realmente acontece). Eles divergem sempre. Process mining descobre o real a partir de event logs.

Algoritmos (Alpha Algorithm, Inductive Miner, Heuristics Miner) analisam o event store e geram:
- **Process discovery**: desenho automático do processo real
- **Conformance checking**: diferenças entre desenho e real
- **Performance analysis**: gargalos, tempo médio em cada estado, retrabalho

> "Process mining works with event logs, a sequential format ideal for representing customer journeys." — [Fluxicon — Process Mining for Customer Journeys](https://fluxicon.com/blog/2022/04/process-mining-for-customer-journeys/)

**Aplicação Operon:** depois de 3-6 meses com event sourcing rodando, dá pra descobrir:
- Quantos dias em média um dossiê leva da criação à entrega?
- Em qual fase ele trava mais?
- Quais mentorados seguem o fluxo feliz e quais fogem do padrão?
- Onde rolam loops (retrabalho)?

Tools: [Celonis](https://www.celonis.com/), [Disco (Fluxicon)](https://fluxicon.com/), [PM4Py (open source)](https://pm4py.fit.fraunhofer.de/).

Ref: [A Process Mining Based Model for Customer Journey Mapping](https://ceur-ws.org/Vol-1848/CAiSE2017_Forum_Paper7.pdf)

---

### 17. Customer Health Score & Lifecycle Stages

Dentro de uma entidade de longa duração como `Mentorado`, existem **fases do ciclo de vida** distintas, cada uma com métricas de saúde próprias:

- **Onboarding** (0-30 dias): signup → primeira call → primeiro dossiê entregue
- **Execução** (30-180 dias): dossiês produzidos, ações executadas, conversão
- **Otimização** (180d+): melhorias iterativas, novos produtos
- **Manutenção** (estável): acompanhamento leve

Cada fase tem um **health score** composto: engajamento no WhatsApp, tempo de resposta, execução de plano de ação, satisfação em calls, status financeiro.

> "You can't use the same Health Scores for all lifecycle stages because a customer's behavior changes as they mature." — [Vitally — Lifecycle Health Scores](https://www.vitally.io/post/why-you-should-build-customer-health-scores-by-lifecycle-stage)

**Aplicação Operon:** o `Mentorado` já tem `fase` no schema (onboarding/execucao/otimizacao/manutencao). Falta associar um health score dinâmico calculado por evento (não por cron), e transições automáticas entre fases quando critérios são atingidos.

Refs: [Gainsight — Customer Health Scores](https://www.gainsight.com/blog/customer-health-scores/), [Planhat — Health Scores Guide](https://www.planhat.com/customer-success/health)

---

### 18. Human-in-the-Loop (HITL) em Orquestração de Agentes IA

Quando você mistura IA com humanos num workflow, precisa decidir pontos de controle:

| Confidence | Decisão |
|------------|---------|
| Alta (>0.9) | IA executa automaticamente |
| Média (0.6-0.9) | IA sugere, humano aprova |
| Baixa (<0.6) | Humano decide do zero |

> "Identify which points require human input, whether that input is optional or mandatory, and whether the human response is an approval that advances the workflow or feedback that loops back to the agent for refinement." — [HatchWorks — Orchestrating AI Agents](https://hatchworks.com/blog/ai-agents/orchestrating-ai-agents/)

**Aplicação Operon:**
- Transcrição de áudio: 100% automático (baixo risco)
- Classificação de descarrego: automático se confidence ≥ 0.8, senão mostra pro Kaique decidir
- Criação de task a partir de descarrego: **sempre** passa por humano (ação visível, com impacto)
- Envio de mensagem WhatsApp automatizada: passa por humano antes de enviar
- Mudança de fase do mentorado: automático se métricas batem critério, senão sugestão

Refs: [LangGraph — Agent Orchestration](https://www.langchain.com/langgraph), [Azure AI Agent Orchestration Patterns](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns)

---

## Parte II — Mapeamento ao Operon/Spalla

### Entidades do Operon (Aggregate Roots)

| Entidade | Tabela atual | É aggregate root? | Sub-entidades | Status machine? |
|----------|--------------|-------------------|---------------|-----------------|
| **Mentorado** | `mentorados` | Sim | `mentorado_context`, `fase_mentorado_history` | Parcial (`fase`) |
| **Tarefa** | `god_tasks` | Sim | `god_task_subtasks`, `god_task_checklist`, `god_task_comments`, `god_task_tags` | Sim (status) |
| **Dossiê** | `dossies` | Sim | `dossie_secoes` (oferta/pos/funil) | Parcial |
| **Call** | `calls_mentoria` | Sim | - | Não |
| **MensagemWhatsApp** | `wa_interactions` | Sim | - | Não |
| **Contexto (Descarrego)** | `mentorado_context` | ❌ parte de Mentorado | - | Implícito |
| **Sprint** | `god_sprints` | Sim | - | Sim (status) |
| **PlanoDeAcao** | `planos_acao` | Sim | `plano_acao_itens` | Parcial |
| **Automation** | `god_automations` | Sim | `god_automation_log` | Sim (ativo/inativo) |
| **Feedback** | - (ainda) | Deveria ser | - | - |
| **Reembolso** | - (ainda) | Deveria ser | - | - |

**Gap principal:** nem todas têm state machine explícita. Hoje é via campo `status` livre, sem enforcement de transições válidas. Precisa refatorar.

---

### Bounded Contexts do Operon

Mapeamento preliminar (a validar em Event Storming):

1. **Mentorship Core** — mentorado, fase, health score, consultor
2. **Task Management** — tarefas, sprints, automations, burndown
3. **Dossie Production** — dossiês, revisões, pipeline de produção
4. **Communication** — WhatsApp, Calls, notificações
5. **Knowledge Capture** — descarrego, contexto, documentos
6. **Financial** — contratos, pagamentos, reembolsos
7. **Analytics** — dashboard, health scores, process mining

Cada bounded context tem seu próprio modelo. Integração via eventos.

---

### Lifecycle Map das Entidades Principais

#### Mentorado

```
lead
  ↓ [assinou_contrato]
onboarding (0-30 dias)
  ├─ [primeira_call_feita]
  ├─ [primeiro_dossie_solicitado]
  └─ [primeiro_dossie_entregue]
  ↓ [criterio_onboarding_completo]
execucao (30-180 dias)
  ├─ [dossies_produzidos]
  ├─ [plano_acao_executando]
  └─ [calls_recorrentes]
  ↓ [criterio_otimizacao] OU [resultados_obtidos]
otimizacao
  ↓ [periodo_encerramento]
manutencao
  ↓ [contrato_renovado] OU [contrato_encerrado]
  → execucao                → encerrado
```

**Eventos que disparam transições:**
- `ContratoAssinado` → lead → onboarding
- `PrimeiroDossieEntregue` + `PrimeiraCallFeita` → onboarding → execucao
- `HealthScore < 30 por 14 dias` → qualquer fase → alerta_risco
- `ReembolsoSolicitado` → qualquer fase → em_negociacao_reembolso
- `ContratoEncerrado` → qualquer fase → encerrado

#### Tarefa

```
pendente
  ├─[start]→ em_andamento
  ├─[cancel]→ cancelada
  └─[archive]→ arquivada
em_andamento
  ├─[complete]→ concluida (guard: subtasks_done && checklist_done)
  ├─[block]→ bloqueada (entry: exige motivo)
  ├─[pause]→ pausada (entry: exige retomar_em)
  └─[cancel]→ cancelada
bloqueada
  ├─[unblock]→ em_andamento
  └─[cancel]→ cancelada
pausada
  ├─[resume]→ em_andamento
  └─[timer_arrived]→ em_andamento (automático via cron)
concluida (estado final, exceto reopen)
  └─[reopen]→ em_andamento (admin only)
```

#### Dossiê

```
solicitado
  ↓ [inputs_coletados] (and-join de áudios, calls, docs)
em_producao (parallel region)
  ├─ oferta { rascunho → em_revisao → aprovada }
  ├─ posicionamento { rascunho → em_revisao → aprovada }
  └─ funil { rascunho → em_revisao → aprovada }
  ↓ [todas_secoes_aprovadas] (and-join)
em_revisao_final (parallel region)
  ├─ revisao_kaique { pendente → aprovado | revisao_pedida }
  ├─ revisao_mariza { pendente → aprovado | revisao_pedida }
  └─ revisao_queila { pendente → aprovado | revisao_pedida }
  ↓ [todas_revisoes_ok]
entregue
  ↓ [arquivamento_periodico]
arquivado
```

Note: cada sub-estado de revisão pode retornar pra `em_producao` via `revisao_pedida`, criando loop de retrabalho que será visível no process mining.

#### Contexto (Descarrego)

```
capturado (raw — áudio/texto/arquivo)
  ↓ [transcricao_necessaria]
transcricao_pendente
  ↓ [transcrito_pelo_whisper]
transcrito
  ↓ [classificacao_pendente]
classificando (IA em progresso)
  ├─ [classificado_como_task] → criar_task_pendente
  ├─ [classificado_como_contexto] → contextualizado (apenas salva)
  ├─ [classificado_como_feedback] → feedback_registrado
  ├─ [classificado_como_reembolso] → alerta_reembolso
  └─ [classificado_como_bloqueio] → alerta_bloqueio
criar_task_pendente
  ├─ [humano_aprovou] → task_criada
  └─ [humano_rejeitou] → contextualizado
feedback_registrado, alerta_reembolso, alerta_bloqueio
  ↓ [acao_tomada]
finalizado
```

---

### Journey Log: a Tabela Única

Proposta: uma tabela central `entity_events` que guarda TODOS os eventos de TODAS as entidades:

```sql
CREATE TABLE entity_events (
  id BIGSERIAL PRIMARY KEY,
  event_id UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  aggregate_type TEXT NOT NULL,  -- 'Mentorado', 'Tarefa', 'Dossie', etc
  aggregate_id TEXT NOT NULL,    -- id da entidade (UUID ou int como text)
  event_type TEXT NOT NULL,      -- 'TaskCreated', 'DossieEntregue', etc
  event_version INT NOT NULL DEFAULT 1,
  payload JSONB NOT NULL,        -- dados específicos do evento
  metadata JSONB NOT NULL,       -- actor, ip, user_agent, correlation_id, causation_id
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  -- Índices
  UNIQUE (aggregate_type, aggregate_id, event_id)
);

CREATE INDEX idx_ee_aggregate ON entity_events (aggregate_type, aggregate_id, occurred_at);
CREATE INDEX idx_ee_event_type ON entity_events (event_type, occurred_at);
CREATE INDEX idx_ee_correlation ON entity_events ((metadata->>'correlation_id'));
CREATE INDEX idx_ee_actor ON entity_events ((metadata->>'actor'));
```

**Por que single table?** Simplicidade. Process mining roda sobre uma tabela só. Audit trail centralizado. Correlation IDs conectam eventos de sagas cross-entity.

**Exemplos de eventos:**
```json
{
  "event_type": "TaskCreatedFromDescarrego",
  "aggregate_type": "Tarefa",
  "aggregate_id": "task-789",
  "payload": {
    "titulo": "Reembolso para Maria Silva",
    "responsavel": "kaique",
    "prazo": "2026-04-10",
    "prioridade": "urgente"
  },
  "metadata": {
    "actor": "ia-classifier",
    "correlation_id": "descarrego-456",
    "causation_id": "event-123",
    "confidence": 0.94,
    "source_descarrego_id": "456"
  }
}
```

O `correlation_id` amarra todos os eventos da mesma saga (descarrego → classificação → task criada → task assigned → task completed). O `causation_id` é o evento que causou este.

---

### Integração com o Orquestrador de Descarrego (IA)

Fluxo proposto (HITL configurável):

```
1. Usuário grava áudio na aba Contexto do mentorado
   → EVENT: DescarregoCaptured {mentorado_id, tipo: 'audio', blob_url}
   → ENTITY: cria Descarrego (state: capturado)

2. Webhook aciona worker de transcrição
   → EVENT: TranscricaoIniciada
   → ENTITY: Descarrego (state: transcricao_pendente)
   → ACTION: POST /api/context/transcribe

3. Whisper retorna texto
   → EVENT: Transcrito {texto, duration_ms, model: 'whisper-1'}
   → ENTITY: Descarrego (state: transcrito)

4. Auto-dispara classificador
   → EVENT: ClassificacaoIniciada
   → ENTITY: Descarrego (state: classificando)
   → ACTION: POST /api/descarrego/classify (GPT-4o)

5. IA retorna JSON estruturado:
   {
     "primary_type": "task" | "context" | "feedback" | "refund" | "block",
     "confidence": 0.0-1.0,
     "subtype": "dossie" | "analise" | ...,
     "task": { titulo, responsavel, prazo, prioridade, descricao } | null,
     "context": { categoria, tags, urgente } | null,
     "feedback": { sentimento, pontos_positivos, pontos_negativos } | null,
     "alertas": [...]
   }
   → EVENT: Classificado {primary_type, confidence, full_classification}
   → ENTITY: Descarrego (state: classificado_como_X)

6. Se primary_type == 'task':
   a) Se confidence >= 0.8 AND RACI permite auto-create:
      → EVENT: TaskCreatedFromDescarrego
      → cria Tarefa automaticamente
      → notifica responsavel via WhatsApp
   b) Se confidence < 0.8 OR ação crítica:
      → EVENT: TaskSuggestionPending
      → mostra card pro humano aprovar
      → humano clica 'Criar' → EVENT: TaskApprovedByHuman → cria
      → humano clica 'Rejeitar' → EVENT: TaskRejectedByHuman → vira só contexto

7. Se primary_type == 'feedback':
   → EVENT: FeedbackCaptured
   → atualiza health score do mentorado
   → se negativo E urgente → cria alerta pro Kaique

8. Se primary_type == 'refund':
   → EVENT: RefundRequested
   → cria task urgente pro financeiro
   → notifica Kaique imediatamente

9. Se primary_type == 'block':
   → EVENT: MenteeBlocked {motivo, severidade}
   → cria task pra consultor desbloquear
   → atualiza health score
```

Todas as transições são eventos no `entity_events`. O `correlation_id` amarra tudo ao descarrego original. Process mining revela padrões: quanto tempo leva do descarrego à ação? Qual tipo de descarrego gera mais tasks? Onde travamos?

---

### Read Models (CQRS projections)

A partir do event store, projetamos:

1. **`vw_mentorado_timeline`** — cronologia completa de um mentorado (todas entidades filhas)
2. **`vw_task_lifecycle`** — métricas de fluxo: lead time, cycle time, waiting time por estado
3. **`vw_dossie_funnel`** — quantos dossiês em cada sub-estado
4. **`vw_descarrego_insights`** — classificações mais comuns, confidence médio, ações tomadas
5. **`vw_health_score`** — score por mentorado atualizado a cada evento relevante
6. **`vw_raci_workload`** — quantas atividades cada membro do time tem como R/A por dia
7. **`vw_process_mining_raw`** — formato padronizado pra ferramentas externas (Disco, PM4Py)

---

## Parte III — Arquitetura Proposta

### Camadas

```
┌─────────────────────────────────────────────┐
│  UI (Alpine.js + HTML)                      │
│  - Mostra read models via Supabase           │
│  - Dispara commands via REST                 │
└─────────────────────────────────────────────┘
                     ↓ commands
┌─────────────────────────────────────────────┐
│  Command Layer (Python backend)             │
│  - Validação, autenticação, autorização      │
│  - Carrega aggregate do event store          │
│  - Valida state machine (FSM transitions)    │
│  - Executa lógica, dispara domain events     │
│  - Persiste eventos + outbox em 1 transação  │
└─────────────────────────────────────────────┘
                     ↓ events
┌─────────────────────────────────────────────┐
│  Event Store (Supabase Postgres)            │
│  - entity_events (append-only)               │
│  - outbox (pra integration events)           │
└─────────────────────────────────────────────┘
                     ↓ triggers
┌─────────────────────────────────────────────┐
│  Projectors (Postgres triggers + workers)   │
│  - Atualizam read models síncronos (mesma tx)│
│  - Publicam integration events via outbox    │
└─────────────────────────────────────────────┘
                     ↓ pub
┌─────────────────────────────────────────────┐
│  Integration Bus (n8n / webhooks / Supabase │
│  Realtime)                                    │
│  - Notifica outros bounded contexts           │
│  - Aciona agentes IA                          │
│  - Envia WhatsApp                             │
└─────────────────────────────────────────────┘
                     ↓ signals
┌─────────────────────────────────────────────┐
│  Workflow/Saga Layer                        │
│  - Orquestrador de Descarrego                 │
│  - Pipeline de Dossiê                         │
│  - Follow-ups automáticos                     │
└─────────────────────────────────────────────┘
```

### Incrementos Recomendados (Iterativo)

**Fase 0 — Estabelecer vocabulário (1 semana)**
- Documento com ubiquitous language de todas entidades
- Review com Kaique + time

**Fase 1 — Event Store básico (1-2 semanas)**
- Criar tabela `entity_events` com schema acima
- Adicionar triggers nos `god_tasks`, `mentorados`, `dossies` que gravam eventos em `entity_events` a cada INSERT/UPDATE/DELETE
- Sem mudar código existente ainda — só capturar o que já acontece
- Começar a acumular histórico real pra process mining

**Fase 2 — State Machines explícitas (2-3 semanas)**
- Implementar FSM em Python pra cada entidade principal
- `god_tasks.status` passa a ser validado por FSM antes de qualquer UPDATE
- Migrations pra adicionar colunas `status_entered_at`, `status_entered_by`
- Eventos emitidos explicitamente em cada transição

**Fase 3 — Orquestrador de Descarrego (2 semanas)**
- Endpoint `/api/descarrego/classify` com GPT-4o
- Endpoint `/api/descarrego/process` que roda a saga completa
- UI: botão "Processar com IA" em cada item de descarrego
- HITL: cards de sugestão com aprovar/rejeitar
- Tab Contexto na ficha do mentorado (reusa o descarrego)

**Fase 4 — Journey viewer (1-2 semanas)**
- UI: timeline visual de um mentorado mostrando todos eventos
- UI: lifecycle viewer de uma task mostrando transições
- UI: dashboard de process mining básico (tempo médio por estado)

**Fase 5 — Sagas de Dossiê (2-3 semanas)**
- Durable execution pro pipeline de dossiê
- Cada passo emite evento, saga reage
- Compensações automatizadas em caso de falha

**Fase 6 — Process Mining & Health Score (ongoing)**
- Integração com Disco ou PM4Py
- Health score calculado por evento
- Transições automáticas de fase do mentorado

---

### Princípios Arquiteturais (inegociáveis)

1. **Eventos são imutáveis.** Nunca UPDATE ou DELETE em `entity_events`. Só INSERT.
2. **Estado atual deriva de eventos.** Read models são projeções. A verdade tá no event store.
3. **Toda transição de estado passa pela FSM.** Não existe `UPDATE status = 'concluida'` solto.
4. **Cada evento tem correlation_id + causation_id.** Rastreabilidade completa.
5. **Outbox pattern pra integração externa.** Nunca fazer dual-write sem transação.
6. **HITL configurável por confidence + RACI.** Ações críticas sempre têm humano.
7. **Ubiquitous language no código.** Código fala português quando o negócio fala português.
8. **Um accountable por atividade.** RACI explícito.

---

## Parte IV — Terminologia Completa (Glossário)

| Termo | Definição | Aplicação Operon |
|-------|-----------|------------------|
| **Entidade** | Objeto com identidade única e lifecycle | Mentorado, Tarefa, Dossie, Call |
| **Value Object** | Imutável, sem identidade | Prioridade, Periodo, Endereco |
| **Aggregate** | Cluster de entidades com consistency boundary | Mentorado + seus contextos |
| **Aggregate Root** | Única entrada pro aggregate | `Mentorado` controla `Contexto` |
| **Bounded Context** | Subdomínio do sistema com modelo próprio | "Task Management" vs "Dossie Production" |
| **Ubiquitous Language** | Vocabulário compartilhado time+código | "mentorado", "descarrego", "dossie" |
| **Invariant** | Regra que nunca pode ser violada | "task concluida só se subtasks done" |
| **FSM (Finite State Machine)** | Estados finitos + transições + guards | Status de Tarefa |
| **Statechart** | FSM hierárquica + paralela + history | Status de Dossie |
| **State Explosion** | Combinações exponenciais em FSM flat | Problema que statecharts resolvem |
| **Guard** | Condição boolean pra transição | `pode_concluir = subtasks_done` |
| **Entry Action** | Ação executada ao entrar num estado | `set started_at = now()` |
| **Exit Action** | Ação executada ao sair de um estado | `log time_spent` |
| **Petri Net** | Modelagem matemática de concorrência | Pipeline de dossiê paralelo |
| **Token** | Marca de estado ativo em Petri net | Sinaliza etapa concluída |
| **And-split / Or-split** | Tipos de gateway em workflow | Paralelização vs decisão |
| **Event Sourcing** | Histórico imutável como source of truth | `entity_events` table |
| **Event Store** | Persistência append-only de eventos | Tabela Postgres + índices |
| **Snapshot** | Estado congelado pra reconstrução rápida | Evitar replay de 1000+ eventos |
| **CQRS** | Write model e read model separados | `god_tasks` (write) + `vw_*` (read) |
| **Command** | Intenção de mudar estado | `CreateTask`, `CompleteTask` |
| **Query** | Leitura sem side effects | `GetTasksByAssignee` |
| **Domain Event** | Fato do domínio (passado) | `TaskCompleted`, `DossieEntregue` |
| **Integration Event** | Evento cross-bounded-context | `MentoradoUpgradedToOtimizacao` |
| **Outbox Pattern** | Consistência entre BD e broker | Garante publish atômico |
| **Eventual Consistency** | Read models convergem com delay | Aceita 100-500ms de atraso |
| **Saga** | Transação distribuída long-running | Pipeline de dossiê |
| **Compensating Transaction** | Desfaz passo anterior em falha | Cancelar task se dossie falhou |
| **Choreography** | Sagas distribuídas (cada um escuta) | Notificações simples |
| **Orchestration** | Saga com comando central | Pipeline de dossie |
| **BPMN** | Notação visual padrão pra processos | Desenhar pipeline legível |
| **Workflow Engine** | Executor de workflows (Camunda, etc) | Camunda, Temporal, n8n |
| **Durable Execution** | Workflow que sobrevive a crashes | Temporal.io |
| **Activity** | Unidade de trabalho em workflow | "Transcrever áudio" |
| **Signal** | Input assíncrono pra workflow rodando | "Aprove este dossiê agora" |
| **Timer** | Pausa durável em workflow | "Espere 48h" |
| **Continue-As-New** | Refresh de workflow infinito | Mentorado com 1000+ eventos |
| **Event Storming** | Workshop pra descobrir modelo | Sessão com Kaique + time |
| **Process Mining** | Descoberta automática de processo real | Descobrir gargalos reais |
| **Conformance Checking** | Diff entre processo desenhado e real | Auditoria de qualidade |
| **Lead Time** | Tempo total do início ao fim | "Dossie levou 14 dias" |
| **Cycle Time** | Tempo de trabalho efetivo (sem espera) | "Só 3 dias de trabalho real" |
| **Waiting Time** | Tempo parado em cada estado | "7 dias parado em revisao_mariza" |
| **WIP Limit** | Trabalho máximo em progresso | "Máx 3 dossiês em revisao_final" |
| **SLO** | Service Level Objective | "90% dos dossiês < 21 dias" |
| **RACI** | Responsible/Accountable/Consulted/Informed | Quem faz o quê em cada transição |
| **Health Score** | Métrica composta de saúde | Score do mentorado 0-100 |
| **Lifecycle Stage** | Fase do ciclo de vida | Onboarding/Execução/Otimização |
| **HITL** | Human-in-the-Loop | Aprovação humana em IA |
| **Confidence Threshold** | Limite pra automação vs humano | >0.8 automático, senão pede aprovação |
| **Agent Orchestration** | Coordenação de múltiplos agentes IA | LangGraph, Microsoft Agent Framework |
| **Task Routing** | Assign automático ao especialista | "Task financeira → kaique" |
| **Idempotência** | Mesma operação dá mesmo resultado | Retries seguros |
| **Correlation ID** | Amarra eventos da mesma saga | Descarrego → Task → Done |
| **Causation ID** | Evento que causou o evento atual | Rastreabilidade causal |
| **Projector** | Função que atualiza read model | Trigger Postgres ou worker |
| **Snapshot Interval** | Frequência de snapshots | A cada 50 eventos |
| **Event Version** | Versão do schema do evento | Migração de schema de eventos |
| **Upcasting** | Converter evento antigo pra schema novo | Compatibilidade backward |
| **Replay** | Re-executar eventos pra reconstruir estado | Debug + rebuild |
| **Temporal Query** | Estado em um ponto no tempo | "Qual era o status ontem?" |
| **At-Least-Once Delivery** | Garantia de entrega mínima | Pode duplicar, precisa idempotência |
| **Exactly-Once Semantic** | Delivery + dedupe | Mais complexo, outbox + message_id |

---

## Parte V — Próximos Passos Concretos

1. **Workshop de Event Storming (2h)** — Kaique + Mariza + Queila + dev. Mapear eventos, commands, aggregates numa parede digital (Miro/FigJam).
2. **Documento de Ubiquitous Language** — glossário oficial dos termos do Operon.
3. **Migration `entity_events`** — criar tabela e triggers de captura nos `god_tasks`, `mentorados`, `dossies`.
4. **FSM Python por entidade** — classe `TaskStateMachine`, `DossieStateMachine`, etc.
5. **Orquestrador de Descarrego (MVP)** — endpoint `/api/descarrego/process` com Whisper + GPT-4o classifier.
6. **Tab Contexto na ficha do mentorado** — já existe parcialmente, finalizar.
7. **UI: Journey Viewer** — timeline visual de uma entidade mostrando eventos.

---

## Referências Principais

### State Machines & Statecharts
- [Harel, D. (1987). *Statecharts: A Visual Formalism for Complex Systems*](https://www.state-machine.com/doc/Harel87.pdf) — paper fundacional
- [statecharts.dev — The Welcome Guide](https://statecharts.dev/)
- [XState (Stately.ai)](https://stately.ai/docs/xstate) — implementação de referência em JS/TS
- [Use State Machines! — Richard Clayton](https://rclayton.silvrback.com/use-state-machines)
- [State Machine in a DDD Context — Patric Steiner](https://patricsteiner.github.io/state-machine-in-a-ddd-context/)

### Domain-Driven Design
- [Domain-Driven Design — Wikipedia](https://en.wikipedia.org/wiki/Domain-driven_design)
- [Aggregates & Entities in DDD — Paul Rayner](http://thepaulrayner.com/blog/aggregates-and-entities-in-domain-driven-design/)
- [Understanding Domain Entities — Khalil Stemmler](https://khalilstemmler.com/articles/typescript-domain-driven-design/entities/)
- [SAP Curated Resources for DDD](https://github.com/SAP/curated-resources-for-domain-driven-design)
- [DDD Modelling: Aggregates vs Entities — Dan Does Code](https://www.dandoescode.com/blog/ddd-modelling-aggregates-vs-entities)

### Event Sourcing & CQRS
- [Event Sourcing — Martin Fowler](https://martinfowler.com/eaaDev/EventSourcing.html)
- [Event Sourcing Pattern — Microsoft Azure](https://learn.microsoft.com/en-us/azure/architecture/patterns/event-sourcing)
- [Why Event Sourcing? — Eventuate.io](https://eventuate.io/whyeventsourcing.html)
- [Audit log with event sourcing — Arkency](https://blog.arkency.com/audit-log-with-event-sourcing/)
- [CQRS — Martin Fowler](https://martinfowler.com/bliki/CQRS.html)
- [CQRS Pattern — Microsoft Azure](https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs)

### Workflow & Orchestration
- [Microservices Saga Pattern — microservices.io](https://microservices.io/patterns/data/saga.html)
- [BPMN and Microservices Orchestration — Camunda](https://camunda.com/blog/2018/08/bpmn-microservices-orchestration-part-2-graphical-models/)
- [Saga: How to implement complex business transactions — Bernd Rücker](https://blog.bernd-ruecker.com/saga-how-to-implement-complex-business-transactions-without-two-phase-commit-e00aa41a1b1b)
- [Petri Net — Wikipedia](https://en.wikipedia.org/wiki/Petri_net)
- [Petri-Nets as conceptual standard for modelling workflows](http://www.project-open.com/en/workflow-petri-nets)

### Durable Execution
- [Temporal.io — Durable Execution](https://temporal.io/)
- [Temporal Platform Documentation](https://docs.temporal.io/workflow-execution)
- [Managing very long-running Workflows — Temporal](https://temporal.io/blog/very-long-running-workflows)
- [Temporal: Beyond State Machines](https://temporal.io/blog/temporal-replaces-state-machines-for-distributed-applications)

### Domain Events & Outbox
- [Transactional Outbox — AWS Prescriptive Guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/transactional-outbox.html)
- [The Outbox Pattern — dev.to](https://dev.to/igornosatov_15/the-outbox-pattern-a-love-letter-to-eventual-consistency-3ch3)
- [Domain events — .NET Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/domain-events-design-implementation)
- [How To Use Domain Events — Milan Jovanović](https://www.milanjovanovic.tech/blog/how-to-use-domain-events-to-build-loosely-coupled-systems)

### Event Storming
- [Event Storming — Wikipedia](https://en.wikipedia.org/wiki/Event_storming)
- [Event Storming 101 — Lucidchart](https://www.lucidchart.com/blog/ddd-event-storming)
- [How to use Event Storming — Philippe Bourgau](https://philippe.bourgau.net/how-to-use-event-storming-to-introduce-domain-driven-design/)
- [Event Storming — Context Mapper](https://contextmapper.org/docs/event-storming/)

### Process Mining & Journey Mapping
- [Process Mining For Customer Journeys — Fluxicon](https://fluxicon.com/blog/2022/04/process-mining-for-customer-journeys/)
- [A Process Mining Based Model for Customer Journey Mapping](https://ceur-ws.org/Vol-1848/CAiSE2017_Forum_Paper7.pdf)
- [Analyzing Customer Journey with Process Mining — IEEE](https://ieeexplore.ieee.org/document/8458017/)
- [Customer journeys and process mining — ITM Conferences](https://www.itm-conferences.org/articles/itmconf/pdf/2024/05/itmconf_iess2024_05002.pdf)

### Customer Health & Lifecycle
- [Customer Health Score — Gainsight](https://www.gainsight.com/blog/customer-health-scores/)
- [Complete Guide to Health Scores — Velaris](https://www.velaris.io/articles/cs-health-scores)
- [Planhat — Health Scores Guide](https://www.planhat.com/customer-success/health)
- [Health Score by Lifecycle Stage — Vitally](https://www.vitally.io/post/why-you-should-build-customer-health-scores-by-lifecycle-stage)

### RACI & Process Ownership
- [RACI Matrix Guide — project-management.com](https://project-management.com/understanding-responsibility-assignment-matrix-raci-matrix/)
- [RACI Chart — Atlassian Work Management](https://www.atlassian.com/work-management/project-management/raci-chart)
- [Responsibility Assignment Matrix — Wikipedia](https://en.wikipedia.org/wiki/Responsibility_assignment_matrix)

### AI Agent Orchestration
- [AI Agent Orchestration Patterns — Microsoft Learn](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns)
- [Microsoft Agent Framework Overview](https://learn.microsoft.com/en-us/agent-framework/overview/)
- [Top 7 AI Agent Orchestration Frameworks — KDnuggets](https://www.kdnuggets.com/top-7-ai-agent-orchestration-frameworks)
- [LangGraph — Agent Orchestration](https://www.langchain.com/langgraph)
- [What is AI Agent Orchestration? — IBM](https://www.ibm.com/think/topics/ai-agent-orchestration)
- [Orchestrating AI Agents in Production — HatchWorks](https://hatchworks.com/blog/ai-agents/orchestrating-ai-agents/)
- [Agentic AI Explained: Workflows vs Agents — Orkes](https://orkes.io/blog/agentic-ai-explained-agents-vs-workflows/)

---

**Documento vivo.** Atualizar conforme implementação avança e Event Storming revela novos insights.
