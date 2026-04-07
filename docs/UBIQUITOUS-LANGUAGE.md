---
title: "Operon/Spalla — Ubiquitous Language (Glossário Canônico)"
type: reference
status: canonical
audience: [dev, product, business, ai-agents]
created: 2026-04-07
authority: "Este documento é a fonte única da verdade para vocabulário do domínio. Qualquer divergência entre código e este glossário é bug."
---

# Ubiquitous Language — Operon/Spalla

> **Regra de ouro:** todo termo aqui listado é o nome canônico. Backend, frontend, banco, prompts de IA, conversas com Mariza/Queila, documentação — tudo usa o mesmo vocabulário. Se você precisa de tradução, é porque o vocabulário foi violado.

## Convenções

- **Idioma canônico**: português brasileiro (PT-BR)
- **Snake_case** em código (`mentorado_id`), **camelCase** só em interfaces externas (ex: ClickUp API)
- **PascalCase** pra entidades (`Mentorado`, `Tarefa`, `Descarrego`)
- Quando há equivalente em inglês relevante (ex: pra integração externa), está listado como `(en: ...)`

---

## A. Entidades de Negócio (Aggregate Roots)

### Mentorado
**Definição**: pessoa que contratou serviço de mentoria do Case Company. Tem nome, email, telefone, contrato, fase de jornada, consultor responsável, e histórico completo de interações com o time.
**Tabela**: `"case".mentorados` (upstream — schema vive fora do Spalla)
**Identidade**: `id` BIGINT
**Sub-entidades**: marcos, contextos, notas
**Bounded context**: Mentorship Core
**(en: mentee — usado SOMENTE em integrações externas)**

### Tarefa
**Definição**: unidade de trabalho atribuível a um membro do time, com título, descrição, responsável, datas, status e prioridade. Pode pertencer a um mentorado (work pra ele) ou ser interna (gestão, operacional).
**Tabela**: `god_tasks`
**Identidade**: `id` UUID
**Sub-entidades**: subtasks, checklist, comentários, tags, custom field values
**Bounded context**: Task Management
**Aliases proibidos**: ~~todo, item, atividade~~

### Dossiê
**Definição**: documento estratégico produzido pelo time pra um mentorado. Contém análise de oferta, posicionamento, funil. Passa por estágios de produção e revisão antes de ser entregue. Pode ter trilha Scale ou Clinic (regras diferentes).
**Tabelas**: `ds_producoes` (aggregate root) + `ds_documentos` (sub-entity por tipo) + `ds_ajustes` + `ds_eventos`
**Identidade do aggregate**: `id` UUID em `ds_producoes`
**Bounded context**: Dossie Production
**(en: dossier — usado em comunicação interna em inglês apenas)**

### Call (de Mentoria)
**Definição**: reunião agendada entre consultor do Case e mentorado. Tipos: onboarding, estratégia, acompanhamento, oferta, conselho, qa, destrave, conteúdo. Tem gravação, transcrição, análise de sentimento, próximos passos extraídos.
**Tabela**: `calls_mentoria`
**Identidade**: `id` UUID
**Bounded context**: Communication
**Termo proibido**: ~~"meeting" interno~~ (usar só em integrações Zoom/Calendar)

### Plano de Ação
**Definição**: roadmap de fases e ações pra um mentorado executar entre uma call e outra. Pode ser gerado de dossiê, de call, ou criado manualmente. Cada ação tem responsável (mentorado ou time), prazo, status.
**Tabelas**: `pa_planos` (root) + `pa_fases` + `pa_acoes`
**Aliases**: PA, plano
**Bounded context**: Mentorship Core
**(en: action plan)**

### Onboarding
**Definição**: trilha estruturada que todo novo mentorado passa nos primeiros 30 dias. Tem etapas (sequenciais ou paralelas) com tarefas (atribuídas a CS, financeiro, mentorado) e prazos calculados (D+N a partir da data de início).
**Tabelas**: `ob_template_*` (template imutável) + `ob_trilhas` + `ob_etapas` + `ob_tarefas`
**Bounded context**: Mentorship Core (sub-process)

### Descarrego
**Definição**: input bruto que o consultor joga no sistema sobre um mentorado — pode ser texto, áudio, vídeo, imagem, arquivo, link. **Não é sinônimo de contexto.** Descarrego é o ato/objeto de capturar; contexto é o que o sistema deriva e guarda depois de processar.
**Tabela**: `descarregos` (a ser criada na Fase 3)
**Lifecycle**: capturado → transcrito → classificado → ação tomada → finalizado
**Bounded context**: Knowledge Capture
**Aliases proibidos**: ~~brain dump, dump, intake, observação~~

### Contexto (Knowledge)
**Definição**: informação derivada e estruturada sobre um mentorado, geralmente fruto de processamento de descarregos. Vive na ficha do mentorado como memória organizada.
**Tabela**: `mentorado_context` (legacy — será reformulado em Fase 3 como projeção de descarregos)
**Bounded context**: Knowledge Capture
**Aliases proibidos**: ~~note, anotação genérica~~

### Sprint
**Definição**: bucket temporal de 1-2 semanas de tarefas, com início/fim definidos, KPIs, burndown. Implementado como `god_lists` com `tipo='sprint'`.
**Tabela**: `god_lists` WHERE `tipo='sprint'`
**Identidade**: `id` UUID
**Bounded context**: Task Management

### Espaço (Space)
**Definição**: agrupamento de mais alto nível de listas/tarefas. Ex: "Jornada do Mentorado", "Gestão Interna", "IA & Automação", "Sistema & Dev".
**Tabela**: `god_spaces`
**(en: space)**

### Lista (List)
**Definição**: agrupamento de tarefas dentro de um espaço. Pode ser tipo `geral`, `sprint`, etc.
**Tabela**: `god_lists`
**(en: list)**

### Mensagem WhatsApp
**Definição**: mensagem individual em um grupo WhatsApp de mentoria, capturada pela Evolution API.
**Tabela**: `wa_messages`
**Bounded context**: Communication

### Tópico WhatsApp
**Definição**: cluster semântico de mensagens relacionadas a um assunto, classificado por IA. Tem tipo (revisão, demanda, dúvida, etc), título extraído, status próprio.
**Tabela**: `wa_topics`
**Bounded context**: Communication
**(en: thread, conversation)**

### Marco (Milestone)
**Definição**: ponto de progresso atingido pelo mentorado em sua jornada. M0 a M6.
**Tabela**: `marcos_mentorado`
**Catálogo de marcos**:
- **M0** — Clareza de Jornada
- **M1** — Estratégia Definida
- **M2** — Primeira Venda
- **M3** — Primeiros Cases
- **M4** — Vendas Consistentes
- **M5** — Negócio Estruturado
- **M6** — Escala Sustentável (proposto)

### Reembolso
**Definição**: solicitação de cancelamento + devolução de pagamento por parte do mentorado. **Crítico** — sempre escala pro Kaique.
**Tabela**: ainda não tem entidade própria — vive como classificação de descarrego e como `motivo_inativacao` em mentorados

### Bloqueio (Mentorado bloqueado)
**Definição**: estado em que o mentorado está parado/travado em alguma etapa do processo, sem avançar. Diferente de uma task bloqueada.
**Detecção**: por descarrego com classificação `bloqueio`, ou por health score baixo

### Health Score (Saúde do Mentorado)
**Definição**: score composto de 0 a 100 que reflete a saúde geral do mentorado (engajamento WhatsApp, frequência de calls, execução de plano de ação, sentimento). Atualizado dinamicamente por evento.
**Implementação atual**: estática via `risco_churn` (baixo/medio/alto/critico). Será dinâmica em Fase 5.

### Risco de Churn
**Definição**: probabilidade de o mentorado cancelar contrato. Categorias: `baixo | medio | alto | critico`.
**Coluna**: `mentorados.risco_churn`

---

## B. Conceitos de Estado

### Status (de Tarefa)
**Definição**: estado comportamental atual de uma tarefa.
**Valores canônicos**:
- `pendente` — criada, não começou
- `em_andamento` — alguém tá trabalhando
- `em_revisao` — esperando aprovação
- `bloqueada` — não pode prosseguir, tem motivo
- `pausada` — voluntariamente pausada
- `concluida` — terminou com sucesso
- `cancelada` — não vai ser feita
- `arquivada` — finalizada e arquivada (cold storage)

**Nota**: hoje o CHECK do banco só aceita `pendente|em_andamento|concluida|cancelada`. Os outros 4 valores são referenciados no frontend mas geram constraint violation. **Será corrigido na Fase 2.**

### Estágio (de Documento de Dossiê)
**Definição**: posição do documento na pipeline de produção. Trilha Scale e Clinic têm estágios diferentes.
**Valores canônicos comuns**:
- `pendente`
- `producao_ia`
- `revisao_mariza`
- `revisao_kaique`
- `enviado`
- `feedback_mentorado`
- `ajustes`
- `aprovado`
- `finalizado`

**Específicos da trilha Scale**: `revisao_gobbi`
**Específicos da trilha Clinic**: `revisao_paralela`, `revisao_queila`

### Fase Jornada (do Mentorado)
**Definição**: posição do mentorado no funil completo de mentoria, do início ao fim do contrato.
**Valores canônicos** (alinhado com `mentorados.fase_jornada` CHECK):
- `onboarding` — primeiros 30 dias, setup inicial
- `concepcao` — definindo estratégia, primeiro dossiê em produção
- `validacao` — testando hipóteses, dossiê entregue, primeiras ações
- `otimizacao` — ajustando o que funciona, refinando
- `escala` — multiplicando o que dá resultado
- `concluido` — terminou ciclo de mentoria

**Estados terminais adicionais (não no CHECK, mas via `ativo=false`)**:
- `encerrado` (motivo: cancelamento, reembolso, conclusão antecipada)

**TAXONOMIA CONFLITANTE — VAI SER REMOVIDA NA FASE 2**:
- ~~`execucao`~~ → mapear pra `validacao` ou `otimizacao`
- ~~`resultado`~~ → mapear pra `escala`
- ~~`renovacao`~~ → não é fase, é evento (volta pro `onboarding` ou `concepcao` em ciclo novo)

### Trilha
**Definição**: variante de processo de produção de dossiê. Determina quais estágios o documento passa.
**Valores canônicos**:
- `scale` — trilha completa, com revisão Gobbi
- `clinic` — trilha enxuta, com revisão paralela + Queila

### Status Financeiro
**Definição**: situação de pagamento do mentorado.
**Valores canônicos**:
- `em_dia` — pagamentos em dia
- `atrasado` — pagamento(s) em atraso
- `quitado` — contrato pago integralmente
- `sem_contrato` — ainda não assinou contrato

### Tipo de Tarefa
**Definição**: categoria de propósito da tarefa.
**Valores canônicos**:
- `geral` — uso geral
- `dossie` — relacionada a produção de dossiê
- `ajuste_dossie` — correção pós-revisão
- `follow_up` — acompanhamento de mentorado
- `rotina` — tarefa recorrente
- `bug_report` — feedback de bug do sistema
- `acao` — item de ação extraído de descarrego/comentário

### Tipo de Call
**Definição**: propósito da call agendada.
**Valores canônicos**:
- `onboarding`
- `estrategia`
- `acompanhamento`
- `oferta`
- `conselho`
- `qa` (q&a, dúvidas)
- `destrave` (mentorado travado)
- `conteudo` (gravação)

**TAXONOMIA CONFLITANTE — corrigir em Fase 2**:
Frontend `scheduleForm` usa: `acompanhamento|diagnostico|planejamento|fechamento`. Mapear:
- `diagnostico` → `estrategia`
- `planejamento` → `estrategia`
- `fechamento` → `oferta`

### Sentimento (de Call ou Mensagem)
**Definição**: classificação emocional da interação.
**Valores canônicos**:
- `positivo`
- `neutro`
- `negativo`
- `frustrado`
- `empolgado`

### Prioridade
**Definição**: urgência relativa de uma tarefa.
**Valores canônicos**:
- `baixa`
- `normal`
- `alta`
- `urgente`

---

## C. Conceitos de Pessoas

### Consultor
**Definição**: membro do time Case que atende mentorados (ex: Lara, Heitor). Pode ser CS, comercial, dev.
**Tabelas**: `auth_users` + tabela de membros
**(en: consultant)**

### Responsável (de Tarefa)
**Definição**: pessoa que executa a tarefa. Pode ser membro do time ou o próprio mentorado.
**Coluna**: `god_tasks.responsavel`
**(en: assignee — em integrações ClickUp)**

### Acompanhante (de Tarefa)
**Definição**: pessoa secundária na task. Watcher de plantão.
**Coluna**: `god_tasks.acompanhante`

### Watcher
**Definição**: pessoa que escolheu acompanhar uma task pra ser notificada de mudanças, sem ser responsável.
**Coluna**: `god_tasks.watchers` JSONB (array de nomes)

### Accountable (RACI)
**Definição**: pessoa que responde pelo sucesso/falha de uma atividade. **Sempre uma só por atividade.**
**Aplicação**: ainda não implementado em código (vai pra Fase 5+). Definido em metadata das FSMs.

### Time / Equipe
**Definição**: conjunto de membros do Case que executam o trabalho. Hoje: Kaique, Mariza, Queila, Gobbi, Lara, Heitor.
**Termo proibido**: ~~"staff"~~

---

## D. Conceitos de IA

### Confidence (Confiança)
**Definição**: score de 0.0 a 1.0 que indica quão confiante a IA está numa classificação ou extração.
**Coluna típica**: `*_confidence NUMERIC(3,2)`
**Threshold canônico**: ≥0.8 = automação permitida; <0.8 = HITL (humano aprova)

### HITL (Human-in-the-Loop)
**Definição**: ponto de aprovação humana num workflow automatizado por IA.
**Aplicação Operon**: classificação de descarrego com confidence baixa entra em estado `aguardando_humano`.

### Classificação (de Descarrego)
**Definição**: rótulo atribuído pela IA ao descarrego. Tem `principal` (categoria) e `sub` (subcategoria).
**Valores canônicos do `principal`**: `task | contexto | feedback | reembolso | bloqueio | duvida | celebracao | outro`

### Transcrição
**Definição**: texto extraído de áudio/vídeo via Whisper ou Groq.
**Coluna**: `descarregos.transcricao` ou `mentorado_context.transcricao`

### Extração (AI extraction)
**Definição**: ato da IA pegar texto bruto e gerar dados estruturados (ex: extrair título, prazo, responsável de uma frase).

### Pattern (Fabric)
**Definição**: prompt template do sistema Fabric pra processamento específico. Ex: `case_extract_oferta`, `case_analyze_call`.

---

## E. Conceitos de Processo

### Lifecycle
**Definição**: ciclo de vida completo de uma entidade, do nascimento à morte. Modelado como state machine.

### State Machine (FSM)
**Definição**: definição formal dos estados possíveis de uma entidade e quais transições entre estados são permitidas.

### Transição (Transition)
**Definição**: mudança de uma entidade de um estado pra outro. Tem evento gatilho, opcional guard (condição), opcional entry/exit actions.

### Guard
**Definição**: condição booleana que precisa ser verdadeira pra uma transição acontecer. Ex: "task só pode ir pra concluida se todas subtasks done".

### Saga
**Definição**: sequência ordenada de passos que envolvem múltiplas entidades, com tracking centralizado e compensação em caso de falha.
**Exemplo**: saga de descarrego = capturar → transcrever → classificar → ação.

### Compensation (Saga)
**Definição**: ação que desfaz o efeito de um passo anterior quando a saga falha.

### Event (Domain Event)
**Definição**: fato que aconteceu no sistema, registrado de forma imutável. Sempre nomeado no passado (`TaskCreated`, `DescarregoClassified`).

### Command
**Definição**: intenção de mudar estado. Pode ser rejeitada (validação, permissão, FSM inválida). Nomeado no imperativo (`CreateTask`, `ClassifyDescarrego`).

### Query
**Definição**: leitura de estado. Não muda nada. Pode ser cacheada.

### Event Store
**Definição**: tabela append-only que guarda todos os eventos do sistema. No Spalla: `entity_events` (a ser criada na Fase 1).

### Journey Log
**Definição**: visualização cronológica dos eventos de uma entidade, do nascimento até agora.

### Correlation ID
**Definição**: UUID que amarra múltiplos eventos de uma mesma saga ou contexto operacional. Ex: todos os eventos do processamento de um descarrego compartilham o mesmo correlation_id.

### Causation ID
**Definição**: ID do evento que causou o evento atual. Permite reconstruir cadeias de causa-efeito.

### Idempotência
**Definição**: propriedade de uma operação que pode ser executada N vezes com o mesmo efeito de executar 1 vez.

### Outbox Pattern
**Definição**: padrão de garantir consistência entre BD e broker de mensagens. Evento é gravado numa tabela outbox na mesma transação do BD; worker poll publica depois.

### CQRS (Command Query Responsibility Segregation)
**Definição**: padrão de separar modelo de escrita (commands) do modelo de leitura (queries). No Spalla: tabelas base = write model, views `vw_*` = read models.

### Aggregate
**Definição**: cluster de entidades + value objects tratados como unidade de consistência. Tem um aggregate root que é a única porta de entrada.

### Aggregate Root
**Definição**: entidade principal de um aggregate. Toda mutação passa por ela. Garante invariantes.

### Bounded Context
**Definição**: subdomínio do sistema com vocabulário e modelo próprios. Operon tem 7: Mentorship Core, Task Management, Dossie Production, Communication, Knowledge Capture, Financial, Analytics.

---

## F. Conceitos de Métricas

### Lead Time
**Definição**: tempo total do nascimento da entidade até o término. Inclui esperas.

### Cycle Time
**Definição**: tempo de trabalho efetivo (sem esperas) na entidade.

### Waiting Time
**Definição**: tempo que a entidade ficou parada num estado sem progresso.

### SLO (Service Level Objective)
**Definição**: meta de qualidade. Ex: "90% dos dossiês entregues em ≤21 dias".

### Burndown
**Definição**: gráfico que mostra a quantidade de pontos restantes em um sprint ao longo do tempo.

### Velocity
**Definição**: quantidade média de pontos concluídos por sprint nas últimas N sprints.

---

## G. Conceitos Específicos do Operon

### Operon
**Definição**: nome da plataforma/produto. Inclui o Spalla Dashboard + integrações + agentes IA.

### Spalla Dashboard
**Definição**: aplicação web (Alpine.js + Python backend + Supabase) que é a UI principal do Operon.

### Case Company
**Definição**: empresa do Kaique que opera o Operon. Atende mentorados via mentoria estruturada.

### Case Scale / Case Clinic
**Definição**: dois produtos/trilhas distintos de mentoria. Scale = jornada completa de longo prazo. Clinic = formato enxuto.

### Pipeline (de Dossiê)
**Definição**: sequência de estágios pelo qual um documento de dossiê passa, da produção à entrega.

### Bridge (Function)
**Definição**: função SQL no Supabase que conecta entidades de subsistemas diferentes. Ex: `bridge_create_task`, `bridge_auto_check_task`.

### Command Center
**Definição**: tela do dashboard que mostra visão executiva do dia (sprint atual, pendências críticas, mentorados sem call recente).

### Carteira
**Definição**: conjunto de mentorados sob responsabilidade de um consultor específico.

---

## H. Termos Proibidos (não usar)

| Proibido | Use no lugar |
|----------|--------------|
| customer | mentorado |
| client | mentorado |
| user (referindo-se a mentorado) | mentorado |
| project | (depende — sprint, lista, ou tarefa) |
| ticket | tarefa |
| issue | feedback (se vier de feedback inbox) ou tarefa (se for trabalho) |
| meeting | call (se for de mentoria) ou reunião (se for interna) |
| document | dossiê (se for entregável) ou doc (se for arquivo genérico) |
| brief | dossiê (se for o documento) ou briefing (se for input pro dossiê) |
| dump / brain dump | descarrego |
| note (tarefa) | tarefa |
| status (de mentorado) | fase_jornada |
| stage (de dossiê) | estagio |

---

## Versioning

Este documento é versionado. Mudanças significativas (adicionar/renomear/remover termos) requerem:
1. PR no repo
2. Revisão por Kaique
3. Atualização de qualquer código que referencie o termo afetado
4. Update do `TAXONOMY-RECONCILIATION.md` se for resolver conflito

**Versão atual**: v1.0 (2026-04-07 — primeira publicação)
