---
title: "Operon/Spalla — Architecture V2: Teoria Aplicada ao Sistema Real"
type: architecture
status: research+audit
audience: [architect, dev, product, CEO]
created: 2026-04-07
parent_doc: ARCHITECTURE-state-machines-lifecycle-journey.md
---

# Architecture V2 — Teoria Aplicada ao Spalla Real

> **Propósito.** O documento V1 estabeleceu a teoria (state machines, entity lifecycle, journey logs, DDD, CQRS, sagas, etc). Este V2 faz a tradução DIRETA: pega o Spalla que existe HOJE — cada tabela, endpoint, state machine implícita, trigger, view — e mostra exatamente onde a teoria encaixa, onde tá certo, onde tá inconsistente, e qual evolução faz sentido **sem refazer tudo do zero**.

> Filosofia: o Spalla já tem 90% da infraestrutura certa. Não precisa reconstruir. Precisa **tornar explícito** o que está implícito, **consolidar** o que está fragmentado, e **conectar** o que está isolado.

---

## Sumário Executivo (pra quem só tem 5 minutos)

**O que o Spalla tem hoje de certo:**
- 46 tabelas de entidades organizadas em 7 subsistemas (mentorship, tasks, PA, DS, OB, WA, financial)
- ~20 CQRS views (`vw_god_*`, `vw_pa_*`, `vw_ds_*`, etc) — read models já separados do write model
- 12+ state machines implícitas via CHECK constraints em colunas `status`/`estagio`/`fase`
- 8 triggers automáticos de state transition (call→task, pa↔task bidirectional sync, updated_at, etc)
- 4 bridge functions que atravessam entidades (`bridge_create_task`, `bridge_auto_check_task`, `ob_criar_trilha`, `fn_financial_snapshot`)
- Dead letter queue pattern no WA (`wa_message_queue.status`)
- Vector embeddings (pgvector) pra semantic search de WA topics
- Fuzzy match via trigram pra auto-completar tasks
- 78+ endpoints REST no backend, com idempotência em webhooks
- 3 background threads (sheets sync 6h, automations 5min, recurring 1h)

**O que o Spalla tem de inconsistente:**
1. **Vocabulário fragmentado**: `fase_jornada` tem valores diferentes em lugares diferentes (`mentorados`: onboarding/concepcao/validacao/otimizacao/escala/concluido; `god_tasks.list_id`: list_onboarding/list_concepcao/...; endpoint `/api/mentees`: onboarding/execucao/resultado/renovacao/encerrado). São 3 taxonomias diferentes pra mesma coisa.
2. **Journey log disperso**: `ds_eventos` guarda transições de dossiê, `god_automation_log` guarda execuções de automation, `wa_topic_events` guarda eventos de WA topics, `god_financial_logs` guarda mudanças financeiras, mas **não existe tabela única** de journey log. Cada subsistema tem o seu, em formato diferente.
3. **State machines sem enforcement no código**: CHECK constraints no banco impedem valores inválidos, mas **não impedem transições inválidas**. Você pode pular de `pendente` direto pra `concluida` sem passar por `em_andamento`. A lógica de transição válida só existe em `DS_VALID_TRANSITIONS` (dossiê) e na `_handle_ds_update_stage`. Todo o resto confia no cliente.
4. **Mentorados é tabela upstream**: o schema de `mentorados` vive em `"case".mentorados` (upstream), e o Spalla só referencia. Isso é OK, mas significa que mudanças de lifecycle precisam ser coordenadas com o schema do case.
5. **Sprint ≠ entidade separada**: sprint é só uma `god_lists` com `tipo='sprint'`. Isso é elegante, mas significa que burndown, velocity, retrospective vivem em lugar estranho.
6. **Descarrego ≠ entidade própria**: hoje descarrego vira `mentorado_context` direto, sem classificação intermediária, sem state machine, sem audit. É texto bruto salvo.
7. **Tasks tem 3 sources**: god_tasks (write model), vw_god_tasks_full (read model), localStorage (cache). Drift acontece.
8. **Trilha Scale vs Clinic**: duas jornadas de dossiê com regras diferentes — mas a distinção vive implícita em strings, sem FSMs diferentes.

**O que o Spalla ainda não tem:**
- Tabela central `entity_events` (journey log unificado)
- FSMs explícitas em Python com validação de transição
- Saga orchestrator (cada subsistema tem sua mini-saga em triggers + threads)
- Correlation/causation IDs (impossível rastrear "este evento causou aquele")
- Process mining setup
- Health score dinâmico (hoje é `risco_churn` calculado manualmente)
- HITL configurável por confidence
- Orquestrador de descarrego (está por vir)

**Caminho incremental de evolução (meu diagnóstico):**
Fase 0→1: vocabulário unificado + tabela `entity_events` capturando via triggers o que já acontece (1 semana, zero breaking change). Fase 2: FSMs explícitas por entidade, substituindo CHECK constraints soltas (2 semanas). Fase 3: orquestrador de descarrego como primeira saga real (2 semanas). Fase 4: journey viewer na UI (1 semana). Depois: process mining e health score dinâmico.

---

## Parte I — Aprofundamento Teórico (camadas que o V1 não tocou)

### 1. Identity vs Entity vs Instance

Um ponto sutil que costuma confundir: **identidade** ≠ **entidade** ≠ **instância**. 

- **Identidade** é o conceito abstrato de "essa coisa é ela mesma ao longo do tempo". Implementada como um ID (UUID, bigint, slug).
- **Entidade** é a classe/tabela que define a forma desse "ser" (colunas, invariantes, comportamentos).
- **Instância** é um registro específico com valores concretos.

No Spalla: `mentorados` é a **entidade**, `mentorados.id = 42` é uma **instância**, e o fato de que "a Maria Silva que eu tava falando ontem é a mesma que tá em um call agora" é a **identidade**. Quando você muda `nome` de "Maria" pra "Maria Silva Souza" o ID continua 42 — a identidade é preservada mesmo com mudança de atributo.

**Por que importa no Operon?** Porque o descarrego pode mencionar "a Maria" sem ID. O sistema precisa **resolver a identidade** (identity resolution) antes de processar. Isso é uma operação explícita: lookup por nome, fuzzy match, confirmação humana se ambíguo. A teoria chama isso de **entity resolution** ou **record linkage** em data engineering.

O Spalla já faz isso parcialmente via `bridge_auto_check_task` com `pg_trgm` (similarity > 0.3). A lição: identity resolution é um **componente de primeira classe**, não algo feito ad-hoc em cada endpoint.

### 2. Structural vs Behavioral State

Tem uma diferença crítica que o V1 não explicitou: estado **estrutural** é quem você é (nome, email, fase); estado **comportamental** é onde você tá no processo (status da task, estágio do dossiê).

Harel disse: "A state machine describes the **behavioral** state of an object, not its structural state."

**Aplicação Spalla:**
- `mentorados.nome` = estrutural (muda raro, por correção)
- `mentorados.fase_jornada` = comportamental (muda no ciclo de vida)
- `god_tasks.titulo` = estrutural
- `god_tasks.status` = comportamental
- `ds_documentos.tipo` (oferta/funil/conteudo) = estrutural
- `ds_documentos.estagio_atual` = comportamental

Essa distinção importa porque:
1. State machines só governam transições **comportamentais**
2. Audit trail precisa distinguir: "mudou de nome" (erro de cadastro) é diferente de "avançou de fase" (evento de negócio)
3. Backup/restore tem que preservar estado estrutural, mas pode re-derivar comportamental via event replay

### 3. Commands, Events, Queries — e a assimetria temporal

Um conceito sutil do CQRS+Event Sourcing:

| Conceito | Tempo | Forma | Falha permitida? |
|----------|-------|-------|-----------------|
| **Command** | Futuro (intenção) | Imperativo: `CreateTask`, `CompleteTask` | SIM — pode ser rejeitado |
| **Event** | Passado (fato) | Passado: `TaskCreated`, `TaskCompleted` | NÃO — aconteceu, é imutável |
| **Query** | Presente (leitura) | Interrogativo: `GetTasksByAssignee` | SIM — erro técnico apenas |

**Assimetria:** commands podem falhar por regra de negócio (invariante violada, permissão negada, state machine inválida). Events **nunca falham** — já aconteceram. Queries falham só por erro técnico (banco fora, timeout).

**Aplicação Spalla:** hoje a gente mistura os três. `POST /api/tasks/create` é um command (pode ser rejeitado), `POST /api/clickup/webhook` **deveria ser event-driven** (ClickUp já decidiu, Spalla só registra), mas está implementado como command (pode "rejeitar" o webhook). Separar esses no código traz clareza.

### 4. Temporal Coupling — o pecado capital

**Temporal coupling** é quando a ordem de operações importa mas não é explícita no código. Exemplo ruim:

```python
task.set_status('em_andamento')  # tem que ser antes
task.set_started_at(now())        # senão dá erro
```

Isso quebra quando alguém chama `set_started_at` primeiro. Uma FSM resolve:

```python
task.transition('start')  # state machine: entry_action = {status='em_andamento', started_at=now()}
```

Uma única operação atômica, a FSM garante a ordem.

**Aplicação Spalla:** o backend tem vários lugares com temporal coupling. Exemplo na função `_recurring_tasks_cron`: tem que limpar `recurrence_rule` ANTES de criar a nova task, senão retry duplica. Isso foi resolvido no PR #449, mas o racional é temporal coupling — tornamos a ordem explícita via `clear-then-create` pattern.

### 5. Anti-corruption Layer (ACL)

Quando você integra com sistema externo (ClickUp, Evolution, Whisper, Gemini), você tem duas opções:

**Opção ruim:** deixar o vocabulário externo vazar pro seu domínio. Exemplo: `god_tasks.status` passa a aceitar `'to do'`, `'in progress'`, `'done'` porque é o que o ClickUp usa.

**Opção certa (Anti-corruption layer):** criar uma camada de tradução que isola. `ClickUpAdapter` recebe ClickUp-speak e produz Spalla-speak. `god_tasks.status` só aceita `pendente/em_andamento/concluida/cancelada`.

**Aplicação Spalla:** o backend JÁ FAZ isso parcialmente via `normalize_status()` no `_handle_clickup_import_all`. Mas não é consistente — alguns pontos vazam vocabulário externo. A recomendação: um módulo `adapters/` com um adapter por integração externa, todas as chamadas passando por lá.

Ref: Eric Evans (DDD book) define ACL como um dos "context mapping patterns" entre bounded contexts.

### 6. Consistency Boundaries

Quando você escreve num aggregate, a escrita é **transacionalmente consistente** dentro do aggregate. Entre aggregates, é **eventualmente consistente** (via eventos).

**Regra prática:** se você tem que modificar duas coisas na mesma transação pra manter um invariante, elas estão no mesmo aggregate. Se você pode aceitar 500ms de atraso, elas estão em aggregates diferentes.

**Aplicação Spalla:**
- `god_tasks` + `god_task_subtasks` + `god_task_checklist` + `god_task_comments` = **mesmo aggregate** (Task). Invariante: não pode ter subtask órfã, contador de subtasks done precisa estar sincronizado. Transação única.
- `god_tasks` + `mentorados` = **aggregates diferentes**. Invariante "task pertence a mentorado ativo" é fraco — pode aceitar delay. Via foreign key + eventual consistency.
- `pa_acoes` ↔ `god_tasks` (sync bidirecional via trigger) = isso é **dual aggregate** conectado por integration event síncrono. Funciona, mas é uma solução intermediária entre strong e eventual consistency.

### 7. Projection Lag e Reader-Side Caches

Em CQRS/Event Sourcing, a projeção (read model) é atualizada ASSINCRONAMENTE depois que o command comita. Entre o write e a atualização do read model tem um **lag** (projection lag). Normalmente <100ms, mas pode ser mais.

**Consequência:** "write-then-read" pode retornar valor velho. Exemplo: cria uma task, imediatamente busca lista de tasks, a nova ainda não apareceu.

**Soluções:**
1. **Optimistic UI update** (o que o Spalla frontend já faz): atualiza o estado local imediatamente, sincroniza em background, rollback se falhar.
2. **Read-your-writes consistency**: ao ler, se for o mesmo usuário que escreveu, redireciona pro write model.
3. **Session stickiness**: todas as operações de um usuário vão pro mesmo replica, eliminando lag pra ele.
4. **Projection versioning**: retorna versão do read model junto com dados, cliente espera versão >= esperada.

O Spalla usa opção 1 (optimistic), que é simples e funciona bem pra single-user scenarios. Pra múltiplos usuários editando simultaneamente (que acontece no /tasks quando Kaique + Mariza estão online), seria bom adicionar Supabase Realtime (que já existe) pra invalidar cache quando evento chega de outro usuário.

### 8. Event Schema Evolution

Eventos são imutáveis, mas o schema deles evolui com o tempo. Estratégias:

**Versioning**: cada evento tem `version`. Consumers sabem lidar com múltiplas versões. Problema: dificulta replay de eventos antigos com código novo.

**Upcasting**: ao ler eventos antigos, uma função `upcast` converte pra versão atual. Todos os consumers só veem versão N. Mais limpo, mas adiciona camada.

**Weak schema**: evento tem um `payload: JSONB` com campos opcionais. Flexível, mas perde validação.

**Aplicação Spalla:** o schema da tabela `entity_events` que vamos criar vai ter `event_version INT` pra suportar upcasting futuro. Começamos com v1, evoluímos com cuidado.

### 9. Idempotência, At-Least-Once vs Exactly-Once

Sistemas distribuídos têm um teorema inconveniente: não existe **exactly-once delivery**. Você consegue:

- **At-most-once**: envia uma vez, se falhar, perde. (Ruim pra transações críticas.)
- **At-least-once**: envia, retenta até confirmação. Pode duplicar. (Exige idempotência do consumer.)
- **Effectively-once**: at-least-once + idempotência no consumer = indistinguível de exactly-once.

**Idempotência** = mesma operação executada N vezes tem o mesmo efeito que executar 1 vez.

**Aplicação Spalla:**
- `POST /api/clickup/webhook` — ClickUp retenta se Spalla retorna 5xx. O handler **deve** ser idempotente. Hoje ele é: checa se status mudou antes de atualizar. ✓
- `POST /api/tasks/create` — se o cliente chama duas vezes por retry, duas tasks são criadas. **NÃO É IDEMPOTENTE.** Solução: cliente gera `client_reference_id`, servidor dedupeia por esse ID numa janela de 24h. Isso ainda não está implementado.
- `_automations_cron` — foi tornado idempotente no PR #449 via `affected_this_run` set + skip-if-same-status.
- `_recurring_tasks_cron` — idempotente via clear-then-create.

**Padrão recomendado**: toda ação que modifica estado via API deveria aceitar um `idempotency_key` opcional no header. Servidor mantém tabela `idempotency_keys` com TTL de 24h.

### 10. Log Compaction vs Event Retention

**Problema**: se você grava TUDO como evento forever, a tabela cresce pra infinito. 5GB/ano pra uma empresa ativa é realista.

**Solução 1 — Retention**: eventos mais antigos que X são deletados. Perde histórico pra auditoria.

**Solução 2 — Snapshots**: a cada N eventos, salva o estado completo. Consumers replay a partir do snapshot mais recente, não do início. Tabela cresce mas queries são rápidas.

**Solução 3 — Log compaction**: pra cada chave (ex: task-123), mantém apenas o evento mais recente de cada tipo. Assim você ainda sabe "qual é o último TaskStatusChanged" sem replay. Kafka faz isso natively.

**Aplicação Spalla:** começaremos com snapshots periódicos (a cada 50 eventos por entidade). Pra análise histórica pesada, considerar exportar eventos antigos pra cold storage (S3 + Athena).

### 11. Pure Events vs Event-Carried State Transfer

Tem dois estilos de event payload:

**Pure event (thin)**: só o que mudou.
```json
{ "event": "TaskStatusChanged", "task_id": "123", "from": "pendente", "to": "em_andamento" }
```

**Event-carried state transfer (fat)**: o estado completo depois da mudança.
```json
{ "event": "TaskStatusChanged", "task": { "id": "123", "titulo": "...", "status": "em_andamento", "responsavel": "kaique", "prazo": "..." } }
```

Thin é menor e não duplica dados. Fat permite consumers processarem sem precisar consultar o write model.

**Regra prática**: use thin internamente (dentro do mesmo bounded context), fat pra integration events (pra outros contextos/serviços).

**Aplicação Spalla:** quando WhatsApp notifier precisa enviar "task X foi concluída pro mentorado Y", o event carried state inclui titulo, mentorado_nome, responsavel_nome. Evita N queries adicionais.

### 12. Time-Travel Debugging via Event Replay

**Feature poderosa que event sourcing destrava:** você pode reproduzir qualquer bug em ambiente de dev simplesmente replayando os eventos de produção até o ponto do bug.

**Aplicação Spalla:** se Maria reclama "eu fiz X ontem e deu errado", com event sourcing eu consigo:
1. Pegar todos os eventos da saga da Maria desde 24h atrás
2. Replayar em ambiente de staging com o código atual
3. Ver exatamente onde quebrou
4. Corrigir, replayar de novo pra validar

Sem event sourcing, eu dependo de logs (que podem não ter o contexto exato), screenshots, e conversar com Maria pra reconstruir.

### 13. Aggregates Grande vs Pequeno — o dilema

Aggregates pequenos (um registro, ~5 invariantes) são fáceis de entender mas criam complexidade entre aggregates.

Aggregates grandes (uma árvore inteira) simplificam invariantes mas viram performance killer (carrega dados demais).

**Heurística de Vaughn Vernon (autor do *Implementing Domain-Driven Design*):**
1. Favor aggregates pequenos
2. Só coloca junto o que **muda junto** (sincronização atômica)
3. Use eventual consistency entre aggregates sempre que possível
4. Aggregate ≠ entidade do banco; pode ser subset

**Aplicação Spalla:** hoje `god_tasks` + `god_task_subtasks` + `god_task_checklist` + `god_task_comments` são 4 tabelas. Ao carregar uma task pro drawer, a view `vw_god_tasks_full` faz join e retorna nested JSON. Isso é **agregação no read side**, eficiente. No write side, cada tabela tem endpoints próprios. Isso é **aggregate pequeno no write + aggregate grande no read** — um padrão CQRS clássico bem aplicado.

### 14. Command Bus + Handler Pattern

Uma organização mais madura do código é:
1. Requests HTTP → criam **Command objects** (estruturas POJO tipadas)
2. **Command Bus** roteia pro **Handler** correto
3. Handler carrega aggregate, valida, executa, persiste eventos
4. Eventos disparam **Projectors** que atualizam read models

Vantagem: testabilidade (você testa o handler isoladamente, sem HTTP), auditoria (todo command passa pelo bus, loga), retries e idempotência centralizados.

**Aplicação Spalla:** hoje o backend tem 78+ handlers misturados em `14-APP-server.py` (um arquivo de ~6000 linhas). Uma refatoração pra command bus ajudaria, mas não é prioritário — funciona.

### 15. Saga Compensation vs Retry

Quando uma saga falha no passo N, você tem duas escolhas:

**Retry**: retenta o passo N até sucesso. Funciona se o erro é transitório (timeout, 500 passageiro). Ruim se o erro é permanente (regra de negócio violada).

**Compensation**: desfaz os passos 1 a N-1 com "transações compensatórias" que revertem os efeitos. Funciona pra erros permanentes.

**Regra:** retry primeiro (com exponential backoff), compensation depois de K retries falhados.

**Aplicação Spalla:** o `_recurring_tasks_cron` já faz isso: tenta criar a próxima task, se falhar, restaura `recurrence_rule` na original (compensation). Futuro orquestrador de descarrego precisa da mesma estrutura: se classificação falhar, devolve o descarrego pra estado "transcrito" pra retry.

### 16. Workflow Versioning

Workflows em durable execution precisam lidar com o problema: "o workflow tá rodando há 3 meses, eu deployei código novo, o que acontece?"

**Opções:**
- **Grandfathering**: workflows antigos continuam com código antigo até terminarem. Código novo só vale pra novos.
- **Migration**: workflows antigos são migrados pra novo schema via upcast.
- **Continue-As-New**: workflow antigo é encerrado, novo é iniciado com o estado atual.

**Aplicação Spalla:** irrelevante por enquanto (não temos workflows de meses), mas importante pra quando o orquestrador de descarrego virar workflow durable.

### 17. Process Mining: Discovery vs Conformance vs Enhancement

Process mining tem 3 usos:

1. **Discovery**: descobrir o processo real a partir do event log. Você não desenha nada, o algoritmo descobre.
2. **Conformance**: comparar o processo real com o processo desenhado. "Eu achei que era X, mas é Y."
3. **Enhancement**: analisar performance do processo (cycle time, gargalos, loops, retrabalho).

Ferramentas: [PM4Py](https://pm4py.fit.fraunhofer.de/) (Python, grátis), [Disco (Fluxicon)](https://fluxicon.com/disco/) (ferramenta paga, excelente), [Celonis](https://www.celonis.com/) (enterprise).

**Aplicação Spalla:** depois de 3 meses com `entity_events` acumulando, rodar PM4Py sobre os eventos de dossiê vai revelar coisas como: "o cycle time médio de um dossiê é 18 dias, mas 40% deles ficam travados em `revisao_mariza` por mais de 5 dias". Isso é insight acionável impossível de ver olhando tabelas.

### 18. Service Level Objectives (SLO) por State Machine

Toda FSM crítica deveria ter SLOs definidos por estado:

- **Waiting time SLO**: tempo máximo que uma entidade pode ficar em X estado. Ex: "uma task em `pendente` por mais de 7 dias dispara alerta."
- **Cycle time SLO**: tempo total do nascimento até a morte. Ex: "um dossiê deve ser entregue em até 21 dias."
- **Lead time SLO**: tempo do pedido à entrega (inclui tempo de espera). Sempre >= cycle time.

**Aplicação Spalla:** os SLOs ainda são implícitos (no `ds_pipeline.dias_no_estagio` como indicador). Tornar explícitos via tabela `entity_slos` com targets por estado permite alertas automáticos.

### 19. The Outbox-Polling Trade-off

O outbox pattern precisa de um **poller** que lê a tabela `outbox` e publica no broker. Existem duas estratégias:

**Polling**: worker faz `SELECT * FROM outbox WHERE published_at IS NULL` a cada X segundos. Simples, mas tem latência (X segundos) e carga constante.

**CDC (Change Data Capture)**: escuta logs do Postgres (via Debezium, wal2json) e publica em tempo real. Mais complexo, mas latência ~0.

**Aplicação Spalla:** começaríamos com polling (a cada 5s). Se precisar de latência mais baixa, migrar pra CDC via Supabase Realtime (que já expõe CDC de graça).

### 20. The "Unit of Work" Pattern

Em sistemas com múltiplos repositórios, precisa de um Unit of Work que garante que todas as escritas em uma transação comitam juntas ou não comitam nenhuma. Ao mesmo tempo, coleta eventos disparados durante a transação pra publicar depois do commit.

**Aplicação Spalla:** o Python backend hoje não tem Unit of Work formalizado. Cada handler faz suas próprias queries Supabase. Uma migração pra um framework como SQLAlchemy + Unit of Work daria essa garantia. Não é prioritário.

---

## Parte II — Auditoria do Spalla Atual, Entidade por Entidade

Nesta parte, cada entidade existente é analisada sob o framework teórico: o que é aggregate root, qual a FSM implícita, quais invariantes existem, quais eventos são emitidos (se algum), quem controla o lifecycle.

### 2.1 Mentorado — o aggregate raíz do sistema

**Tabela**: `"case".mentorados` (upstream — definida fora do Spalla)
**Identidade**: `id` (BIGINT)
**Tipo**: **Aggregate Root** do bounded context "Mentorship Core"

**Estado comportamental**:
- `fase_jornada` TEXT: `onboarding | concepcao | validacao | otimizacao | escala | concluido` (CHECK)
- `sub_etapa` TEXT (livre — gap)
- `marco_atual` TEXT: M0..M6 (livre — gap)
- `risco_churn` TEXT: `baixo | medio | alto | critico` (CHECK)
- `ativo` BOOLEAN (soft delete)
- `status_financeiro` TEXT: `em_dia | atrasado | quitado`
- `contrato_assinado` BOOLEAN
- `snoozed_until` TIMESTAMPTZ (CS pode silenciar)

**Estado estrutural**:
- `nome`, `email`, `telefone`, `cohort` (N1/N2/tese), `historico_fases` JSONB

**Sub-entidades (no mesmo aggregate ou não):**
- `marcos_mentorado` — sub-entidade (mesma cohesão, pode ser do mesmo aggregate)
- `mentorado_context` (descarrego) — sub-entidade
- `mentorado_notes` — sub-entidade
- `pa_planos` — aggregate **separado** (pode ser modificado sem travar mentorado)
- `ds_producoes` — aggregate **separado**
- `ob_trilhas` — aggregate **separado**
- `god_tasks` onde mentorado_id = X — **reference** cross-aggregate
- `calls_mentoria` — **reference** cross-aggregate
- `wa_messages`, `wa_topics` — **reference** cross-aggregate

**FSM implícita do `fase_jornada`**:
Hoje: **não há enforcement de transição**. CHECK constraint só valida que o valor está na lista. Você pode pular de `onboarding` pra `escala` direto.

Desenhando a FSM explícita:
```
lead (pre-state, implícito)
  ↓ [contratoAssinado]
onboarding
  ↓ [primeiraCallFeita] + [primeiroDossieEntregue]
concepcao
  ↓ [dossieAprovado] + [planoAcaoIniciado]
validacao
  ↓ [primeirasVendasRealizadas]
otimizacao
  ↓ [metaAlcancada] OU [periodoCumprido]
escala
  ↓ [periodoEncerramento]
concluido (terminal)

+ transições paralelas:
  qualquer_fase → encerrado (via offboard: ativo=false, motivo_inativacao)
```

**Eventos implícitos que o sistema emite hoje** (mas não registra em journey log):
- `MentoradoCriado` (via `/api/welcome-flow/register`)
- `FaseJornadaAtualizada` (via `/api/mentees/{id}` PATCH)
- `MentoradoSilenciado` (via snoozed_until)
- `MentoradoDesativado` (via `/api/mentees/{id}/offboard`)
- `StatusFinanceiroAtualizado` (loga em `god_financial_logs` — bom!)
- `PrimeiraCallRealizada` (implícito via `call_estrategia_realizada=true`)
- `PrimeiroDossieEntregue` (implícito via `dossie_entregue=true`)

**Journey log atual**: disperso em `god_financial_logs` (só financial) e `historico_fases` JSONB (só fase). Sem schema unificado.

**RACI por transição (proposta)**:
| Transição | Responsible | Accountable | Consulted | Informed |
|-----------|-------------|-------------|-----------|----------|
| lead → onboarding | consultor | Kaique | - | Mariza (dossiê) |
| onboarding → concepcao | consultor | Mariza | Kaique | mentorado |
| concepcao → validacao | Mariza | Kaique | - | mentorado |
| validacao → otimizacao | consultor | consultor | Kaique | - |
| qualquer → encerrado | Kaique | Kaique | consultor | - |

**Gap analysis**:
- ❌ Não há tabela de audit pra mudanças de fase (além do `historico_fases` JSONB que é fragil)
- ❌ Não há FSM em código que rejeita transição inválida
- ❌ `/api/mentees/{id}` PATCH (linha do backend) valida só o valor ser da lista, não se a transição é legal
- ❌ Taxonomia inconsistente: `/api/mentees` PATCH aceita `['onboarding','execucao','resultado','renovacao','encerrado']` — **isso é DIFERENTE** do CHECK constraint do `mentorados.fase_jornada` (`['onboarding','concepcao','validacao','otimizacao','escala','concluido']`). **Bug latente.**
- ✓ `risco_churn` tem valores bem definidos
- ✓ Soft delete via `ativo` está certo
- ✓ `historico_fases` como log estruturado é uma boa intenção

**Ação recomendada (ordem)**:
1. **Reconciliar taxonomia**: decidir UMA fase jornada canônica. Minha recomendação: manter `onboarding/concepcao/validacao/otimizacao/escala/concluido` (é o que está no CHECK) e atualizar o backend pra aceitar só esses valores.
2. **Criar `entity_events` e começar a logar mudanças de `fase_jornada` via trigger** — zero breaking change, só captura.
3. **Criar classe Python `MentoradoStateMachine`** que valida transições. Endpoint PATCH passa a usar.
4. Implementar RACI em metadata da FSM.

### 2.2 Tarefa (god_tasks) — o aggregate mais maduro

**Tabela**: `god_tasks`
**Identidade**: `id` (UUID)
**Tipo**: **Aggregate Root** do bounded context "Task Management"

**Sub-entidades (mesmo aggregate)**:
- `god_task_subtasks` (CASCADE delete)
- `god_task_checklist` (CASCADE)
- `god_task_comments` (CASCADE)
- `god_task_handoffs` (CASCADE)
- `god_task_tag_relations` (CASCADE)
- `god_task_field_values` (CASCADE, custom fields)

**Tudo isso junto = Task aggregate.** Já está certo.

**Aggregates separados referenciados**:
- `mentorado_id` → Mentorado
- `pa_acao_id` → PA Action (bidirecional sync via trigger — DUAL-WRITE pattern, problemático em escala)
- `parent_task_id` → Self-referencing pra hierarquia

**FSM atual**:
```
pendente --[manual]--> em_andamento --[manual]--> concluida
                                     ↓
                                     cancelada
                                     (voltar pra pendente não é proibido — gap)
```

CHECK: `status IN ('pendente','em_andamento','concluida','cancelada')`

**Estados que deveriam existir mas não existem**:
- `bloqueada` — "tá bloqueada esperando input" (existe campo `bloqueio_motivo` mas não é estado)
- `em_revisao` — já referenciado no frontend (`em_revisao` aparece em `filteredTasks`) mas não tá no CHECK. **Bug: o código pode setar um valor que o banco rejeita.**
- `pausada` — distinto de bloqueada (você pausou ativamente)
- `arquivada` — agora tem coluna `archived_at` (via migration 20260407070000) mas não é um estado da FSM

**Invariantes explícitos**:
- `prioridade IN ('baixa','normal','alta','urgente')` ✓
- `parent_task_id != id` (implícito, precisaria de CHECK)

**Invariantes implícitos (não enforced)**:
- ❌ Não pode marcar `concluida` se tem subtask not done
- ❌ Não pode marcar `concluida` se tem checklist not done
- ❌ Não pode reopen task `concluida` sem permissão
- ❌ Task em `bloqueada` precisa de `bloqueio_motivo`

**Triggers ativos**:
- `trg_god_tasks_updated`: BEFORE UPDATE → auto `updated_at` ✓
- `trg_sync_task_to_pa`: ON UPDATE status → sincroniza pa_acoes.status se `pa_acao_id` setado
- `trg_sync_pa_to_task`: inverso
- `trg_call_to_tasks`: AFTER INSERT on `analises_call` → cria god_tasks automaticamente com `auto_created=true`

**O trigger `trg_call_to_tasks` é um exemplo de choreography**: a entidade `analises_call` "emite um evento" (o INSERT) e o trigger reage criando god_tasks. Elegante. Mas tem problema: não há idempotência, e a dedupe usada é via texto (se rodar de novo, duplica).

**Eventos implícitos hoje**:
- `TaskCreated` (INSERT)
- `TaskUpdated` (UPDATE — genérico demais)
- `TaskStatusChanged` (UPDATE status)
- `TaskAssigned` (UPDATE responsavel)
- `TaskDeleted` (DELETE)
- `TaskAutoCreatedFromCall` (trg_call_to_tasks)
- `TaskSyncedToPA` (trg_sync_task_to_pa)

**Gap analysis**:
- ⚠️ `em_revisao` no frontend mas não no CHECK do banco = bug
- ❌ Estados ausentes: bloqueada, pausada, arquivada
- ❌ Invariantes de guard não enforced (pode concluir com subtask aberta)
- ❌ Sync bidirecional PA ↔ Task via trigger = **dual-write anti-pattern**. Se trigger falhar por algum motivo, os dois lados divergem sem notificação.
- ✓ Aggregate está bem modelado com sub-entidades
- ✓ `auto_created` + `confianca_ia` é uma boa prática pra marcar proveniência

**Ação recomendada**:
1. **Adicionar `em_revisao`, `bloqueada`, `pausada`, `arquivada` ao CHECK constraint** — migration imediata.
2. **Criar `TaskStateMachine` em Python** com validação de guards.
3. **Substituir triggers de sync bidirecional por integration events**: quando task muda, emite `TaskStatusChanged`, projector atualiza pa_acoes. Unidirecional.
4. **Emitir eventos em `entity_events`** via trigger até termos o command bus formal.

### 2.3 Contexto/Descarrego — a entidade que está por nascer

**Tabela atual**: `mentorado_context` (embutida dentro do aggregate Mentorado)
**Problema**: não é tratada como entidade própria. Sem state machine. Sem lifecycle visível. Sem classificação.

**Como deveria ser (proposta)**:

**Entidade nova**: `Descarrego` (bounded context: "Knowledge Capture")

**Campos sugeridos**:
```
id UUID
mentorado_id BIGINT (ref)
tipo_bruto TEXT: 'texto' | 'audio' | 'imagem' | 'video' | 'arquivo' | 'link'
conteudo_bruto TEXT (texto direto, ou caption de arquivo)
arquivo_url TEXT
duracao_ms INT (pra audio/video)

-- Transcrição
transcricao TEXT
transcrito_em TIMESTAMPTZ
transcrito_por TEXT ('whisper-1' | 'groq-whisper-large-v3' | 'human')

-- Classificação IA
classificacao_principal TEXT: 'task' | 'contexto' | 'feedback' | 'reembolso' | 'bloqueio' | 'duvida' | 'celebracao'
classificacao_sub TEXT: 'dossie' | 'analise' | 'feedback_positivo' | 'feedback_negativo' | ...
confidence NUMERIC(3,2)
classificado_em TIMESTAMPTZ
classificado_por TEXT ('gpt-4o' | 'gemini-2.5' | 'human')

-- Ação tomada
acao_tomada TEXT: 'task_criada' | 'salvo_como_contexto' | 'escalado_kaique' | 'rejeitado'
task_id UUID (se virou task)
context_id UUID (se virou contexto estruturado)
acao_tomada_em TIMESTAMPTZ
acao_tomada_por TEXT (user name ou 'ai')

-- State machine
status TEXT: 'capturado' | 'transcrito' | 'classificado' | 'revisado_humano' | 'finalizado' | 'erro'
```

**FSM**:
```
capturado (raw input)
  ↓ [se tem audio/video] transcrição necessária
transcricao_pendente
  ↓ [Whisper retorna]
transcrito
  ↓ [auto-dispara GPT-4o]
classificacao_pendente
  ↓ [GPT-4o retorna]
classificado
  ├─[confidence >= 0.8 && tipo_permite_auto]→ executando_acao_automatica
  └─[confidence < 0.8 || tipo_requer_humano]→ aguardando_humano
executando_acao_automatica
  ↓ [ação executada]
finalizado
aguardando_humano
  ├─[humano aprova]→ executando_acao_manual → finalizado
  └─[humano rejeita]→ rejeitado (estado terminal)
erro (qualquer transição pode ir pra cá)
  └─[humano investiga]→ volta pra estado anterior
```

**Eventos emitidos**:
- `DescarregoCaptured`
- `DescarregoTranscribed` (causation_id: DescarregoCaptured)
- `DescarregoClassified` (causation_id: DescarregoTranscribed)
- `DescarregoConvertedToTask` (se ação = criar task) → dispara `TaskCreated` no aggregate Task
- `DescarregoSavedAsContext`
- `DescarregoEscalated`
- `DescarregoRejected`

**Saga**:
```
POST /api/descarrego/process
  → 1. INSERT into descarregos (status=capturado)
  → 2. if tipo=audio: dispara worker de transcrição
         if tipo=texto: pula pra step 3
  → 3. Whisper → transcricao
  → 4. UPDATE descarregos set transcricao, status=transcrito
  → 5. GPT-4o com prompt de classificação
  → 6. UPDATE descarregos set classificacao, status=classificado
  → 7. Decisão:
     if confidence >= 0.8 AND primary_type in [auto_allowed]:
       → executa ação (criar task com dados extraídos, salvar contexto, etc)
       → UPDATE status=finalizado
     else:
       → UPDATE status=aguardando_humano
       → frontend mostra card de sugestão
       → humano clica aprovar → continua
```

**Por que precisamos disso**: hoje quando Kaique joga um áudio no `/descarrego`, ele é transcrito e salvo como texto em `mentorado_context`. Ponto. Nenhuma classificação, nenhuma ação, nada. É um "diário" sem inteligência. A teoria diz: **tornar o descarrego uma entidade com lifecycle próprio destrava o orquestrador de IA**.

### 2.4 Dossiê (ds_producoes + ds_documentos) — o mais complexo

**Aggregate Root**: `ds_producoes` (1 por mentorado)
**Sub-entidades**:
- `ds_documentos` (3 por produção: oferta, funil, conteudo) — cada um com sub-lifecycle próprio
- `ds_ajustes` (ajustes pós-call)
- `ds_eventos` (audit trail — **isso já é um mini event store!**)
- `ds_transcricoes`

**FSM de `ds_producoes.status`** (CHECK constraint):
```
nao_iniciado → call_estrategia → producao → revisao → aprovado → enviado → apresentado → (loop ajustes ↔ apresentado)* → finalizado
       └─→ pausado (hatch)
       └─→ cancelado (hatch)
```

**FSM de `ds_documentos.estagio_atual`** (CHECK):
```
pendente → producao_ia → revisao_mariza → revisao_kaique → revisao_queila → aprovado → enviado → feedback_mentorado → ajustes → finalizado
```

**Diferença entre Scale e Clinic**: no frontend ficou visível que Clinic inclui `revisao_paralela` e `revisao_queila` separadas, enquanto Scale passa por `revisao_gobbi`. Essa distinção **vive no código frontend como constante**, mas não há FSM diferente por trilha no backend. A validação `DS_VALID_TRANSITIONS` está dentro de `_handle_ds_update_stage` no Python.

**`ds_eventos` é praticamente um event store** já! Campos:
- `tipo_evento` TEXT: `estagio_change | handoff | ajuste_criado | ajuste_concluido | nota | feedback`
- `de_valor` TEXT (from_state)
- `para_valor` TEXT (to_state)
- `responsavel` TEXT (actor)
- `proximo_responsavel` TEXT (next accountable)
- `descricao` TEXT (payload free-form)
- `created_at` TIMESTAMPTZ (occurred_at)

**Falta pra ser event store completo**:
- `event_id UUID` (pra idempotência)
- `correlation_id UUID` (pra amarrar com outras entities)
- `causation_id UUID` (pra rastrear qual evento causou qual)
- `payload JSONB` (estruturado, não free-form em `descricao`)
- `event_version INT` (pra evolução de schema)

**Gap analysis do Dossiê**:
- ✓ Event store local (`ds_eventos`) é a melhor implementação de qualquer subsistema do Spalla
- ✓ `estagio_desde` (aging tracker) já existe — base pro SLO por estado
- ✓ `DS_VALID_TRANSITIONS` no backend já enforça FSM
- ⚠️ Mas `ds_eventos` é isolado — nenhuma outra entidade sabe quando um dossiê mudou de estado. Falta pub de integration event.
- ❌ Trilha Scale vs Clinic vive em código Python, não na estrutura do dado. Se tiver uma trilha nova amanhã, tem que fazer deploy.
- ❌ Não há correlation ID amarrando "este dossiê surgiu deste descarrego, que veio daquele áudio, que foi gravado naquela call"

**Ação recomendada**:
1. **Usar `ds_eventos` como template pro `entity_events` global** — o schema é quase igual
2. **Promover `ds_eventos` a projetor pra `entity_events`** — via trigger, todo insert em ds_eventos também vai pra entity_events
3. **Modelar trilhas como data**: tabela `dossie_trilhas` com FSM JSON configurável por trilha. Adicionar nova trilha = INSERT + reload.
4. **Emitir integration events** quando dossiê muda de estado pra outros bounded contexts reagirem (ex: "dossie finalizado" → sprint atualiza, WhatsApp notifica)

### 2.5 WhatsApp Queue — a obra-prima oculta

**Tabela**: `wa_message_queue`
**Estado**: `pending | processing | done | error | skipped | dead_letter`

Isso é um **exemplo perfeito de FSM aplicada** que o Spalla já tem. Olhando o código:

1. n8n recebe webhook do Evolution API
2. INSERT em `wa_message_queue` com status=`pending`, `message_id` UNIQUE (idempotência!)
3. Worker pega, muda pra `processing`
4. Se der sucesso → `done`
5. Se der erro → `error` com `retry_count++`
6. Função `recover_stuck_queue(stuck_minutes, max_retries)` roda a cada 5min:
   - Messages em `processing` por mais de 5min → volta pra `pending` (crash recovery!)
   - Messages em `error` com retry_count >= 3 → vai pra `dead_letter`

Isso é literalmente o **Outbox Pattern + Dead Letter Queue + Saga Recovery** combinados. Em 1 tabela. Sem framework.

**A lição importante**: o Spalla já sabe fazer FSMs bem feitas quando precisa. Só não aplicou em toda entidade.

### 2.6 Plano de Ação (pa_planos, pa_fases, pa_acoes)

**Aggregate Root**: `pa_planos` (1 por mentorado)
**Sub-entidades**: `pa_fases`, `pa_acoes`, `pa_sub_acoes`

**FSM de `pa_planos.status_geral`**:
```
nao_iniciado → em_andamento → concluido
                     ↓
                     pausado
```

**FSM de `pa_fases.status`**:
```
nao_iniciado → em_andamento → concluido
                     ↓
                     pausado
```

**FSM de `pa_acoes.status`**:
```
pendente → em_andamento → concluido
                ↓
                bloqueado
                ↓
                nao_aplicavel
```

Três FSMs aninhadas! Isso é um statechart hierárquico natural:

```
PlanoDeAcao
├─ nao_iniciado
├─ em_andamento (estado composto — tem sub-FSM)
│  └─ for each Fase (parallel region):
│     ├─ nao_iniciado
│     ├─ em_andamento (estado composto)
│     │  └─ for each Acao (parallel region):
│     │     ├─ pendente
│     │     ├─ em_andamento
│     │     ├─ concluido
│     │     ├─ bloqueado
│     │     └─ nao_aplicavel
│     ├─ concluido
│     └─ pausado
├─ concluido
└─ pausado
```

**Isso É um Harel statechart.** Mas tá implementado como 3 tabelas flat, sem FSM explícita.

**Regras de transição implícitas que deveriam ser explícitas**:
- `PlanoDeAcao.concluido` só é válido se todas `pa_fases.concluido`
- `pa_fases.concluido` só é válido se todas `pa_acoes in (concluido, nao_aplicavel)`
- Nenhuma `pa_acao` pode estar `em_andamento` se sua fase está `pausado`

**Gap analysis**:
- ❌ Nenhuma dessas regras está enforced — você pode marcar PA como `concluido` com ações ainda `pendente`
- ✓ Bidirecional sync com `god_tasks` via trigger é interessante
- ❌ Mas falta `dias_sem_update` (aging) — ahh, tem sim, em `vw_pa_pipeline` — OK.
- ✓ `origem` em pa_planos marca proveniência (dossie_auto, call_plano, manual)

### 2.7 Onboarding (ob_trilhas, ob_etapas, ob_tarefas) — o saga mais bem feito

**Template**: `ob_template_etapas` + `ob_template_tarefas` (imutáveis)
**Instância**: `ob_trilhas` + `ob_etapas` + `ob_tarefas` (cópia do template, per-mentorado)

**Função `ob_criar_trilha(mentorado_id, ...)`**: literalmente uma saga que:
1. Cria trilha
2. Copia todas etapas do template → instancia
3. Copia todas tarefas do template → instancia com `data_prevista = trilha.data_inicio + prazo_dias`
4. Retorna trilha_id

**Isso é a implementação mais próxima de "durable execution" no Spalla atual.** Um workflow declarativo (template) instanciado pra cada novo mentorado, com pontos de checkpoint, deadlines calculados, e state machine por etapa.

**Único problema**: não tem versionamento. Se você muda o template e cria uma nova trilha com o template novo, trilhas antigas continuam com o template antigo (o que é correto), mas se você precisar mudar as antigas também, não tem ferramenta automatizada.

### 2.8 Call + Analises + Insights — o fluxo de extração

**Fluxo atual**:
```
calls_mentoria.INSERT
  → (manual via agendamento ou log retrospectivo)
  → analises_call.INSERT (AI extrai: sentimento, proximos_passos[], decisoes[], gargalos[])
    → trigger trg_call_to_tasks:
       → FOREACH proximo_passo[] + decisao[]:
          → god_tasks.INSERT(auto_created=true, confianca_ia=X)
  → (paralelo) call_insights.INSERT (AI extrai: actions, blockers, milestones tipados)
    → call_insights.tipo='action' pode linkar a god_task via FK
```

Isso é uma **saga de extração**. Cada passo emite um resultado que dispara o próximo. Implementada via triggers + AI externa.

**Fragilidade**: a saga é invisível. Se algum passo falhar (ex: AI retorna malformado), não há retry automático. Não há "status da saga" visível em lugar nenhum.

**Proposta**: adicionar tabela `call_processing_jobs` com status da saga (recebido → transcrito → analisado → insights_extraidos → finalizado). Cada passo atualiza. Se falhar em X, retomar de X.

### 2.9 Automations — a FSM que já virou tabela

`god_automations` tem:
- `trigger_type` (status_changed, due_date_arrived, etc)
- `trigger_config` JSONB (scope: space_id, list_id, responsavel)
- `condition_config` JSONB
- `action_type` (change_status, change_assignee)
- `action_config` JSONB
- `is_active` BOOLEAN

E `god_automation_log`:
- Registra cada execução com trigger_data + result

Isso é **literalmente** uma saga orchestrator embutida. Cada automation é um workflow de 1 step. A teoria diz: ótimo, mas escala pra N steps? Não. Pra workflows multi-step, precisaria estender.

### 2.10 Interações WhatsApp (wa_topics + wa_messages + wa_topic_events)

O sistema de WA topics é o **mais sofisticado do Spalla**:
- `wa_topics` tem FSM (`open | active | pending_action | resolved | archived | converted_task`)
- `wa_topic_events` é um event store local
- `embedding` pgvector pra semantic dedup
- `ai_context_hash` pra invalidar classificação quando mensagens novas chegam

**Isso já aplica 80% da teoria.** Só falta conectar com o `entity_events` global e usar correlation_id pra amarrar com mentorado + tasks geradas.

---

## Parte III — Gap Analysis: Teoria vs Realidade

Aqui é onde a rubber meets the road. Vou listar as lacunas concretas por conceito teórico.

### Gap 1: Ubiquitous Language Fragmentada

**Teoria**: vocabulário único, mesmo termo em todos os lugares.

**Realidade Spalla**:
- Fase de mentorado: **3 taxonomias diferentes**
  - DB: `onboarding | concepcao | validacao | otimizacao | escala | concluido`
  - Backend `/api/mentees` PATCH: `onboarding | execucao | resultado | renovacao | encerrado`
  - Frontend filtros: mistura os dois

- Status de task: **2 taxonomias**
  - DB: `pendente | em_andamento | concluida | cancelada`
  - Código frontend: `pendente | em_andamento | em_revisao | concluida | cancelada | atrasada`
  - `em_revisao` e `atrasada` não existem no CHECK — bug latente

- "Trilha": Scale vs Clinic vive em string no backend, não em tabela

**Ação**: criar `docs/UBIQUITOUS-LANGUAGE.md` com glossário canônico. Qualquer discrepância com esse glossário = bug.

### Gap 2: Journey Log Fragmentado

**Teoria**: uma tabela central `entity_events` com correlation_id.

**Realidade Spalla**: 6 tabelas de audit separadas:
- `ds_eventos` (dossiê)
- `god_automation_log` (automations)
- `wa_topic_events` (WA topics)
- `god_financial_logs` (mudanças financeiras)
- `historico_fases` JSONB em mentorados (mudanças de fase)
- `call_insights` (parcialmente audit)

Nenhuma amarra com correlation_id. Impossível responder "qual foi a cadeia de eventos que levou este dossiê a ser finalizado?".

**Ação**: criar `entity_events` e, via triggers, projetar todos os eventos das tabelas acima pra lá também. Mantém compatibilidade, adiciona visão unificada.

### Gap 3: Guards e Invariantes sem Enforcement

**Teoria**: guards impedem transições inválidas.

**Realidade Spalla**:
- `DS_VALID_TRANSITIONS` no backend Python enforça transições válidas ✓ (único lugar)
- Resto: zero enforcement. CHECK constraints só validam que o valor é da lista, não a transição.

**Ação**: classe Python `StateMachine` base + subclasses por entidade. Todo endpoint que muda estado passa por validação de transição.

### Gap 4: Dual-Write sem Outbox

**Teoria**: escrita em BD + publicação de evento na mesma transação via outbox.

**Realidade Spalla**:
- `trg_sync_task_to_pa` + `trg_sync_pa_to_task` = dual-write anti-pattern. Se um falha, divergem.
- Sends WA via backend sem gravar outbox.
- Webhook externo sem gravar outbox.

**Ação**: quando criar `entity_events`, adicionar campo `published_at TIMESTAMPTZ` (null = pendente). Worker poll e publica, marca `published_at`. Ou usar Supabase Realtime pra CDC direto.

### Gap 5: Identity Resolution Ad-Hoc

**Teoria**: entity resolution é componente de primeira classe.

**Realidade Spalla**: `bridge_auto_check_task` faz fuzzy match via pg_trgm, mas ad-hoc. Não há módulo reutilizável `resolveMentorado(nome: str, ambiguity_handler)`.

**Ação**: módulo `adapters/identity_resolver.py` com funções `resolveMentorado`, `resolveTarefa`, etc, reutilizáveis.

### Gap 6: Saga Observabilidade Zero

**Teoria**: toda saga tem um status visível.

**Realidade Spalla**: a saga de extração (call → analise → tasks auto criadas) é invisível. Se a AI falhar, ninguém sabe até alguém reclamar.

**Ação**: criar tabela `saga_executions` com (id, saga_type, status, started_at, completed_at, steps_completed, failed_step, retry_count). Cada saga escreve lá.

### Gap 7: Descarrego não é entidade

**Teoria**: se uma coisa tem lifecycle, deve ser entidade com FSM.

**Realidade**: descarrego é texto bruto em `mentorado_context`. Sem lifecycle, sem classificação, sem audit.

**Ação**: criar tabela `descarregos` com FSM completa. Migrar dados existentes.

### Gap 8: Read Models (CQRS) excelentes, Write Models soltos

**Teoria**: write model é o guardião das invariantes, read model é otimizado pra queries.

**Realidade Spalla**: as views (`vw_*`) são excelentes read models. Mas o write model é ad-hoc — cada endpoint escreve direto em tabelas, sem encapsulamento.

**Ação**: criar camada `domain/` em Python com classes `Mentorado`, `Tarefa`, `Dossie` que encapsulam os invariantes. Endpoints carregam aggregates, mutam, persistem. Gradual — começar com Task (mais usada).

### Gap 9: Health Score Estático

**Teoria**: health score é composto dinâmico atualizado por evento.

**Realidade Spalla**: `risco_churn` é texto que alguém seta. Não é calculado de eventos.

**Ação**: função `calc_health_score(mentorado_id)` que olha eventos recentes (calls, mensagens, tasks, dossie progress) e retorna score 0-100. Trigger em eventos relevantes recalcula.

### Gap 10: Process Mining não-existente

**Teoria**: event log permite descobrir processo real.

**Realidade Spalla**: eventos dispersos, sem formato padrão. Impossível exportar pra PM4Py.

**Ação**: depois que `entity_events` existir, criar view `vw_process_mining_raw` no formato esperado por ferramentas de process mining (case_id, activity, timestamp, resource).

---

## Parte IV — Plano de Evolução Incremental

Filosofia: **zero breaking change até a Fase 3**. Só adição. Depois vamos substituir código antigo gradualmente.

### Fase 0 — Vocabulário (1 semana, zero código)

**Deliverables**:
1. `docs/UBIQUITOUS-LANGUAGE.md` — glossário canônico
2. `docs/ENTITY-GLOSSARY.md` — lista de entidades com definição formal
3. Revisão com Kaique + Mariza + Queila

**Critério de sucesso**: qualquer dev novo consegue ler e entender o vocabulário sem precisar perguntar.

### Fase 1 — Event Store passivo (1 semana)

**Deliverables**:
1. Migration: cria tabela `entity_events`
2. Triggers em tabelas-chave (god_tasks, mentorados, dossies, pa_*, ds_*, wa_topics) que capturam eventos em `entity_events` via AFTER INSERT/UPDATE/DELETE
3. Triggers NÃO bloqueiam operação — se entity_events falhar por algum motivo, log de erro mas continua
4. View `vw_entity_timeline(entity_type, entity_id)` pra visualizar histórico
5. Dashboard admin: contagem de eventos por tipo por dia

**Zero breaking change**. Só passa a capturar o que já acontece.

**Critério de sucesso**: após 7 dias, ter ≥10k eventos capturados e conseguir responder "mostra timeline completa da tarefa X".

### Fase 2 — FSMs explícitas (2-3 semanas)

**Deliverables**:
1. Módulo `domain/state_machines.py` com classe base `StateMachine` e subclasses:
   - `TaskStateMachine`
   - `MentoradoStateMachine`
   - `DossieProducaoStateMachine`
   - `DossieDocumentoStateMachine`
   - `DescarregoStateMachine` (nova!)
2. Migração: adiciona estados ausentes aos CHECK constraints (`em_revisao`, `bloqueada`, `pausada`, `arquivada` em god_tasks)
3. Endpoints críticos refatorados pra usar FSM: `/api/tasks/*`, `/api/mentees/*`, `/api/ds/update-stage`
4. Testes: pra cada FSM, test suite que verifica transições válidas e inválidas

**Critério de sucesso**: tentar fazer transição inválida via API retorna 409 Conflict com mensagem explicando.

### Fase 3 — Descarrego como entidade + Orquestrador (2-3 semanas)

**Deliverables**:
1. Migration: tabela `descarregos` com FSM completa
2. Migration: migra `mentorado_context` existentes pra `descarregos` (com status='finalizado', classificacao='contexto_legado')
3. Endpoint `POST /api/descarrego/process` implementando a saga completa
4. UI: aba "Contexto" na ficha do mentorado usando `descarregos` como fonte
5. UI: card de sugestão HITL quando confidence < 0.8
6. Classificador GPT-4o com prompt bem definido, retornando JSON estruturado
7. Integration test: gravar áudio → ver task criada automaticamente

**Critério de sucesso**: Kaique grava "preciso fazer dossiê da Maria pra quinta" e em <60s aparece uma task pendente com título extraído, responsavel=kaique, prazo=quinta.

### Fase 4 — Journey Viewer + Basics de Process Mining (1-2 semanas)

**Deliverables**:
1. UI `/journey/:entity_type/:entity_id` mostrando timeline visual
2. View `vw_process_mining_raw` no formato padrão
3. Script Python que exporta CSV pra PM4Py
4. Notebook Jupyter inicial explorando lead time de dossiês

**Critério de sucesso**: conseguir responder "qual o tempo médio que um dossiê fica em cada estado?" com dados reais de 1 mês.

### Fase 5 — Health Score Dinâmico + SLOs (2 semanas)

**Deliverables**:
1. Tabela `entity_slos` com targets por estado por entidade
2. View `vw_slo_violations` pra ver quem tá estourando
3. Função `calc_mentorado_health_score(id)` baseada em eventos
4. Atualização automática de `risco_churn` via trigger em eventos relevantes
5. Alertas no frontend quando SLO violado

**Critério de sucesso**: "mentorado Maria caiu de 82 pra 45 de health score" e sistema explica por que (3 calls canceladas seguidas, 5 mensagens sem resposta há 3 dias).

### Fase 6 — Refatoração gradual pro Write Model formal (ongoing, 1-2 meses)

**Deliverables**:
1. Módulo `domain/aggregates.py` com classes de aggregate
2. Migração gradual dos endpoints pra usar aggregates
3. Integration tests
4. Eventualmente: command bus formal

Não é prioritário. Fazer quando time tiver tempo sobrando.

---

## Parte V — Arquitetura de Referência (código-first)

### Módulo Python proposto: `app/backend/domain/`

```
domain/
├── __init__.py
├── state_machines/
│   ├── __init__.py
│   ├── base.py                    # StateMachine base class
│   ├── task.py                    # TaskStateMachine
│   ├── mentorado.py               # MentoradoStateMachine
│   ├── dossie_producao.py         # DossieProducaoStateMachine
│   ├── dossie_documento.py        # DossieDocumentoStateMachine
│   └── descarrego.py              # DescarregoStateMachine
├── events/
│   ├── __init__.py
│   ├── store.py                   # EntityEventStore (wrapper pra entity_events)
│   ├── types.py                   # Event dataclasses
│   └── publishers.py              # Publish integration events
├── aggregates/                    # Futuro
│   ├── task.py
│   └── mentorado.py
└── sagas/
    ├── __init__.py
    ├── descarrego_processor.py    # Saga do orquestrador de descarrego
    └── dossie_pipeline.py         # Saga do pipeline de dossie
```

### Exemplo: `domain/state_machines/base.py`

```python
from dataclasses import dataclass
from typing import Callable, Dict, List, Optional, Any

@dataclass
class Transition:
    from_state: str
    to_state: str
    event: str
    guard: Optional[Callable[[Any], bool]] = None  # returns True if allowed
    entry_action: Optional[Callable[[Any], None]] = None
    exit_action: Optional[Callable[[Any], None]] = None

class StateMachine:
    states: List[str] = []
    initial_state: str = None
    terminal_states: List[str] = []
    transitions: List[Transition] = []
    
    def __init__(self, entity):
        self.entity = entity
    
    def current_state(self) -> str:
        return getattr(self.entity, self._state_field)
    
    @property
    def _state_field(self) -> str:
        raise NotImplementedError
    
    def can_transition(self, event: str) -> bool:
        current = self.current_state()
        matching = [t for t in self.transitions if t.from_state == current and t.event == event]
        if not matching:
            return False
        transition = matching[0]
        if transition.guard and not transition.guard(self.entity):
            return False
        return True
    
    def transition(self, event: str, actor: str, correlation_id: str = None, payload: dict = None):
        current = self.current_state()
        matching = [t for t in self.transitions if t.from_state == current and t.event == event]
        if not matching:
            raise InvalidTransitionError(
                f"Cannot {event} from {current}. Valid events: {self._valid_events(current)}"
            )
        transition = matching[0]
        if transition.guard and not transition.guard(self.entity):
            raise GuardFailedError(f"Guard failed for {event} on {current}")
        
        # Exit action
        if transition.exit_action:
            transition.exit_action(self.entity)
        
        # State change
        old_state = current
        setattr(self.entity, self._state_field, transition.to_state)
        
        # Entry action
        if transition.entry_action:
            transition.entry_action(self.entity)
        
        # Emit event to entity_events
        EntityEventStore.emit(
            aggregate_type=type(self.entity).__name__,
            aggregate_id=str(self.entity.id),
            event_type=f"{type(self.entity).__name__}{event.capitalize()}",
            payload={
                "from_state": old_state,
                "to_state": transition.to_state,
                **(payload or {})
            },
            metadata={
                "actor": actor,
                "correlation_id": correlation_id,
            }
        )
    
    def _valid_events(self, state: str) -> List[str]:
        return [t.event for t in self.transitions if t.from_state == state]


class InvalidTransitionError(Exception): pass
class GuardFailedError(Exception): pass
```

### Exemplo: `domain/state_machines/task.py`

```python
from .base import StateMachine, Transition

class TaskStateMachine(StateMachine):
    states = ['pendente', 'em_andamento', 'em_revisao', 'bloqueada', 'pausada', 'concluida', 'cancelada', 'arquivada']
    initial_state = 'pendente'
    terminal_states = ['cancelada', 'arquivada']
    
    _state_field = 'status'
    
    @staticmethod
    def _all_subtasks_done(task) -> bool:
        return all(s['done'] for s in task.subtasks)
    
    @staticmethod
    def _set_started_at(task):
        from datetime import datetime, timezone
        task.started_at = datetime.now(timezone.utc)
    
    @staticmethod
    def _set_completed_at(task):
        from datetime import datetime, timezone
        task.completed_at = datetime.now(timezone.utc)
    
    transitions = [
        # Fluxo principal
        Transition('pendente', 'em_andamento', 'start', entry_action=_set_started_at.__func__),
        Transition('em_andamento', 'em_revisao', 'request_review'),
        Transition('em_revisao', 'em_andamento', 'changes_requested'),
        Transition('em_revisao', 'concluida', 'approve', entry_action=_set_completed_at.__func__),
        Transition('em_andamento', 'concluida', 'complete',
                   guard=_all_subtasks_done.__func__,
                   entry_action=_set_completed_at.__func__),
        
        # Pausas e bloqueios
        Transition('em_andamento', 'bloqueada', 'block'),
        Transition('bloqueada', 'em_andamento', 'unblock'),
        Transition('em_andamento', 'pausada', 'pause'),
        Transition('pausada', 'em_andamento', 'resume'),
        
        # Cancelamento e arquivamento
        Transition('pendente', 'cancelada', 'cancel'),
        Transition('em_andamento', 'cancelada', 'cancel'),
        Transition('bloqueada', 'cancelada', 'cancel'),
        Transition('pausada', 'cancelada', 'cancel'),
        Transition('concluida', 'arquivada', 'archive'),
        Transition('cancelada', 'arquivada', 'archive'),
        
        # Reabertura (com permissão especial)
        Transition('concluida', 'em_andamento', 'reopen'),
    ]
```

### Exemplo: migration de `entity_events`

```sql
-- Migration: 20260408000000_entity_events.sql
CREATE TABLE entity_events (
  id BIGSERIAL PRIMARY KEY,
  event_id UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  aggregate_type TEXT NOT NULL,
  aggregate_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  event_version INT NOT NULL DEFAULT 1,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  published_at TIMESTAMPTZ,
  
  -- Correlation for sagas
  correlation_id UUID,
  causation_id UUID
);

CREATE INDEX idx_ee_aggregate ON entity_events (aggregate_type, aggregate_id, occurred_at);
CREATE INDEX idx_ee_event_type ON entity_events (event_type, occurred_at);
CREATE INDEX idx_ee_correlation ON entity_events (correlation_id) WHERE correlation_id IS NOT NULL;
CREATE INDEX idx_ee_unpublished ON entity_events (recorded_at) WHERE published_at IS NULL;

-- Trigger function to emit event from any table
CREATE OR REPLACE FUNCTION emit_entity_event()
RETURNS TRIGGER AS $$
DECLARE
  v_aggregate_type TEXT := TG_ARGV[0];
  v_event_type TEXT;
  v_old_data JSONB;
  v_new_data JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_event_type := v_aggregate_type || 'Created';
    v_new_data := to_jsonb(NEW);
  ELSIF TG_OP = 'UPDATE' THEN
    v_event_type := v_aggregate_type || 'Updated';
    v_old_data := to_jsonb(OLD);
    v_new_data := to_jsonb(NEW);
  ELSIF TG_OP = 'DELETE' THEN
    v_event_type := v_aggregate_type || 'Deleted';
    v_old_data := to_jsonb(OLD);
  END IF;
  
  INSERT INTO entity_events (aggregate_type, aggregate_id, event_type, payload, metadata)
  VALUES (
    v_aggregate_type,
    COALESCE((v_new_data->>'id'), (v_old_data->>'id')),
    v_event_type,
    jsonb_build_object('old', v_old_data, 'new', v_new_data),
    jsonb_build_object('source', 'trigger', 'table', TG_TABLE_NAME)
  );
  
  RETURN COALESCE(NEW, OLD);
EXCEPTION WHEN OTHERS THEN
  -- Never block the operation. Log error and continue.
  RAISE WARNING 'entity_events capture failed: %', SQLERRM;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Apply to key tables
CREATE TRIGGER trg_god_tasks_events
AFTER INSERT OR UPDATE OR DELETE ON god_tasks
FOR EACH ROW EXECUTE FUNCTION emit_entity_event('Task');

CREATE TRIGGER trg_ds_producoes_events
AFTER INSERT OR UPDATE OR DELETE ON ds_producoes
FOR EACH ROW EXECUTE FUNCTION emit_entity_event('DossieProducao');

CREATE TRIGGER trg_ds_documentos_events
AFTER INSERT OR UPDATE OR DELETE ON ds_documentos
FOR EACH ROW EXECUTE FUNCTION emit_entity_event('DossieDocumento');

CREATE TRIGGER trg_pa_acoes_events
AFTER INSERT OR UPDATE OR DELETE ON pa_acoes
FOR EACH ROW EXECUTE FUNCTION emit_entity_event('PaAcao');

-- For mentorados, since it's upstream, trigger on Spalla-owned tables that touch it
-- (we can't modify the case.mentorados table directly)

-- View: entity timeline
CREATE VIEW vw_entity_timeline AS
SELECT
  aggregate_type,
  aggregate_id,
  event_type,
  payload,
  metadata,
  occurred_at,
  correlation_id,
  causation_id
FROM entity_events
ORDER BY occurred_at DESC;
```

### Exemplo: saga do descarrego em Python

```python
# domain/sagas/descarrego_processor.py
from uuid import uuid4
from ..state_machines.descarrego import DescarregoStateMachine
from ..events.store import EntityEventStore

class DescarregoProcessor:
    """
    Saga orchestrator pra processar descarrego end-to-end.
    """
    
    def __init__(self, descarrego_id: str, actor: str):
        self.descarrego_id = descarrego_id
        self.actor = actor
        self.correlation_id = str(uuid4())
        self.descarrego = self._load()
        self.sm = DescarregoStateMachine(self.descarrego)
    
    def run(self):
        try:
            # Step 1: Transcribe if audio
            if self.descarrego.tipo_bruto in ('audio', 'video', 'gravacao'):
                self._transcribe()
            
            # Step 2: Classify via GPT-4o
            self._classify()
            
            # Step 3: Take action based on classification
            if self.descarrego.confidence >= 0.8:
                self._execute_auto_action()
            else:
                self._queue_for_human_review()
            
        except Exception as e:
            # Compensation: mark as error, keep for retry
            self.sm.transition('error', actor='system', correlation_id=self.correlation_id,
                             payload={'error': str(e)})
            raise
    
    def _transcribe(self):
        self.sm.transition('start_transcription', actor=self.actor, correlation_id=self.correlation_id)
        audio_bytes = self._fetch_audio()
        transcricao = openai_whisper(audio_bytes, 'descarrego.webm', 'audio/webm')
        self.descarrego.transcricao = transcricao
        self.descarrego.transcrito_em = now()
        self.sm.transition('transcribed', actor='whisper', correlation_id=self.correlation_id)
    
    def _classify(self):
        self.sm.transition('start_classification', actor=self.actor, correlation_id=self.correlation_id)
        text = self.descarrego.transcricao or self.descarrego.conteudo_bruto
        result = gpt4o_classify_descarrego(text, context=self._mentorado_context())
        self.descarrego.classificacao_principal = result['primary_type']
        self.descarrego.classificacao_sub = result.get('subtype')
        self.descarrego.confidence = result['confidence']
        self.descarrego.classificado_em = now()
        self.sm.transition('classified', actor='gpt-4o', correlation_id=self.correlation_id,
                          payload={'classification': result})
    
    def _execute_auto_action(self):
        primary = self.descarrego.classificacao_principal
        if primary == 'task':
            # Create task aggregate with extracted fields
            from ..aggregates.task import TaskAggregate
            task = TaskAggregate.create(
                titulo=self.descarrego.task_extracted_titulo,
                responsavel=self.descarrego.task_extracted_responsavel,
                prazo=self.descarrego.task_extracted_prazo,
                mentorado_id=self.descarrego.mentorado_id,
                fonte='descarrego_ai',
                correlation_id=self.correlation_id,  # amarra com descarrego!
            )
            self.descarrego.acao_tomada = 'task_criada'
            self.descarrego.task_id = task.id
        elif primary == 'contexto':
            # Save as context item
            ctx = save_context_item(self.descarrego)
            self.descarrego.acao_tomada = 'salvo_como_contexto'
            self.descarrego.context_id = ctx.id
        elif primary == 'reembolso':
            # Critical: escalate to Kaique
            create_urgent_alert(kaique_id, 'Reembolso detectado', self.descarrego)
            self.descarrego.acao_tomada = 'escalado_kaique'
        
        self.sm.transition('action_taken', actor='system', correlation_id=self.correlation_id)
        self.sm.transition('finalize', actor='system', correlation_id=self.correlation_id)
    
    def _queue_for_human_review(self):
        self.sm.transition('await_human_review', actor='system', correlation_id=self.correlation_id)
        # Frontend will show card via polling or realtime
```

Com isso, quando você grava um áudio e a saga roda, o event store fica assim:

```
event_id              | event_type              | correlation_id | causation_id
---------------------- | ----------------------- | -------------- | ------------
e1                    | DescarregoCaptured      | c1             | null
e2                    | DescarregoStartTranscribing | c1          | e1
e3                    | DescarregoTranscribed   | c1             | e2
e4                    | DescarregoStartClassifying | c1           | e3
e5                    | DescarregoClassified    | c1             | e4
e6                    | DescarregoActionTaken   | c1             | e5
e7                    | TaskCreated             | c1             | e6   ← linked!
e8                    | DescarregoFinalized     | c1             | e6
```

Replay desse correlation_id inteiro me dá a cadeia completa. **Isso é o ouro.**

---

## Parte VI — Métricas para Medir Sucesso

Pra saber se o investimento nessa arquitetura valeu a pena:

1. **Cobertura de captura**: % de ações do sistema que geram evento em `entity_events`. Target: 95% em 3 meses.

2. **Correlation coverage**: % de eventos que têm `correlation_id` não-nulo (= participam de alguma saga). Target: 70% em 3 meses.

3. **Transições inválidas bloqueadas**: # de tentativas de transição inválida que a FSM rejeitou. Se for 0, a FSM não tá sendo exercitada (ou o código nunca tenta nada inválido — improvável).

4. **Cycle time de dossiê**: medido via process mining. Target: redução de 20% em 6 meses.

5. **Tasks criadas via IA com confidence >= 0.8**: proxy pra qualidade do classificador. Target: 80% das classificações acima de 0.8.

6. **HITL approval rate**: % de sugestões da IA que humano aprova (vs rejeita). Target: 85% ou mais.

7. **Saga failure rate**: % de execuções de saga que terminam em `erro`. Target: < 5%.

8. **Time-to-journey-view**: quanto tempo um dev leva pra responder "o que aconteceu com X entre A e B"? Target: < 2 minutos com o journey viewer.

---

## Conclusão

O Spalla **já é um sistema event-driven implícito**, só não sabe. Tem FSMs (nos CHECK constraints), event stores locais (`ds_eventos`, `wa_topic_events`, `god_automation_log`), triggers que fazem choreography, dead letter queue, vector semantic search, bridge functions cross-entity, read models CQRS bem feitos.

**O que falta é tornar tudo isso coerente e unificado**, não reescrever. A arquitetura V2 aqui proposta é uma evolução, não revolução.

A ordem correta é:

1. **Vocabulário unificado** (não-código, 1 semana)
2. **Event store passivo capturando tudo** (zero breaking, 1 semana)
3. **FSMs explícitas pra entidades críticas** (2-3 semanas)
4. **Descarrego como primeira saga formal** (destrava IA orquestradora, 2-3 semanas)
5. **Journey viewer + process mining** (insights, 1-2 semanas)
6. **Health score dinâmico + SLOs** (operação proativa, 2 semanas)

Total: ~10-14 semanas pra ter a arquitetura madura, com o sistema continuando a funcionar o tempo inteiro.

---

## Anexos

### A. Taxonomias conflitantes que precisam ser resolvidas

1. **Fase jornada de mentorado**:
   - DB CHECK: `onboarding | concepcao | validacao | otimizacao | escala | concluido`
   - Backend `/api/mentees/{id}` PATCH aceita: `onboarding | execucao | resultado | renovacao | encerrado`
   - **Resolução recomendada**: manter o do DB como canônico, atualizar backend.

2. **Status de task**:
   - DB CHECK: `pendente | em_andamento | concluida | cancelada`
   - Frontend referencia: `em_revisao`, `atrasada`, `bloqueada`, `pausada`, `arquivada`
   - **Resolução recomendada**: expandir CHECK pra incluir todos, migrar dados.

3. **Tipo de call**:
   - `calls_mentoria.tipo_call`: onboarding, estrategia, acompanhamento, oferta, conselho, qa, destrave, conteudo
   - `scheduleForm.tipo` frontend: acompanhamento, diagnostico, planejamento, fechamento
   - **Resolução recomendada**: definir enum canônico, atualizar ambos.

### B. Arquivos do Spalla citados neste documento

- `supabase/migrations/05-SQL-schema-inicial.sql` — schemas base
- `supabase/migrations/07-SQL-god-tasks-schema.sql` — aggregate Task
- `supabase/migrations/08-SQL-god-views-v2.sql` — CQRS read models
- `supabase/migrations/15-SQL-pa-schema.sql` — Plano de Ação
- `supabase/migrations/22-SQL-ds-schema.sql` — Dossiê (melhor FSM do sistema)
- `supabase/migrations/24-SQL-ob-schema.sql` — Onboarding (melhor saga do sistema)
- `supabase/migrations/35-SQL-wa-topics-schema.sql` — WhatsApp topics + pgvector
- `supabase/migrations/42-SQL-task-bridge.sql` — triggers choreography call→task
- `supabase/migrations/49-SQL-call-intelligence.sql` — call_insights
- `app/backend/14-APP-server.py` — monolith com 78+ endpoints
- `app/frontend/10-APP-index.html` — UI
- `app/frontend/11-APP-app.js` — Alpine.js state management

### C. Links de referência (expande o V1)

Do documento V1:
- [Harel 1987 — Statecharts](https://www.state-machine.com/doc/Harel87.pdf)
- [Martin Fowler — Event Sourcing](https://martinfowler.com/eaaDev/EventSourcing.html)
- [Eric Evans — DDD book](https://www.domainlanguage.com/ddd/)

Adicional pra V2:
- [Vaughn Vernon — Effective Aggregate Design (3 papers)](https://www.dddcommunity.org/library/vernon_2011/) — o guia definitivo pra decidir tamanho de aggregate
- [Greg Young — CQRS Documents](https://cqrs.files.wordpress.com/2010/11/cqrs_documents.pdf) — fundador do pattern
- [Udi Dahan — Don't Delete. Just Don't.](https://udidahan.com/2009/09/01/dont-delete-just-dont/) — por que soft delete é pior que event sourcing
- [Pat Helland — Immutability Changes Everything](https://dl.acm.org/doi/10.14778/2732288.2732291) — paper sobre o impacto de dados imutáveis
- [Martin Kleppmann — Designing Data-Intensive Applications (book)](https://dataintensive.net/) — referência master pra tudo isso

---

**Documento vivo.** Atualizar conforme cada fase é implementada e descobrimos novas coisas no código.
