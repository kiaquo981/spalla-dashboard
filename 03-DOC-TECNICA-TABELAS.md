# Documentacao Completa — Spalla V2 (God Views)

> **Projeto Supabase:** `knusqfbvhsqworzyhvip` (CASE Principal)
> **Schema:** `public`
> **Data:** 17/02/2026
> **Arquivo SQL:** `god_views_v2.sql`

---

## Resumo Executivo

O banco do programa CASE tem **12 tabelas principais** com dados de **37 mentorados ativos** (29 N1 + 8 N2). Alem deles, existem ~20 mentorados "tese" (pesquisa academica) e 19 inativos (duplicatas merged + 3 desativados: Karine Canabrava e Leticia Oliveira por reembolso, Flavia Nantes por finalizacao) que **nao aparecem** no dashboard.

Para o frontend da Spalla consumir esses dados, criamos **9 views SQL + 2 functions** que consolidam tudo. O frontend so precisa fazer `SELECT * FROM nome_da_view` — toda a logica de JOIN, calculo e filtragem ja esta pronta.

### Numeros atuais

| Recurso | Quantidade |
|---------|-----------|
| Mentorados ativos no dashboard | 37 |
| Mensagens WhatsApp | 23.840 |
| Calls gravadas | 226 |
| Analises de call (IA) | ~260 |
| Extracoes de agentes IA | 505 |
| Planos de acao gerados | 93 |
| Direcionamentos da Queila | 1.362 |
| Marcos atingidos | ~104 |
| Tarefas (todas as fontes) | 804+ (god_tasks bidirecional) |
| Alertas ativos agora | 474 |

---

## 1. Tabelas-Fonte (de onde vem os dados)

### 1.1 `mentorados` — Cadastro central

**O que e:** Tabela principal com todos os dados de perfil, fase, financeiro e scores de cada mentorado.

**Alimentada por:** Cadastro manual + automacao via workflows N8N.

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `id` | bigint (PK) | ID unico do mentorado (serial) |
| `nome` | varchar | Nome completo |
| `telefone` | varchar | Telefone com DDD |
| `whatsapp_id` | varchar | ID do WhatsApp (numero@c.us) |
| `grupo_whatsapp_id` | varchar | ID do grupo WhatsApp individual (pode ser NULL) |
| `email` | text | Email do mentorado |
| `instagram` | text | @ do Instagram |
| `cidade` | text | Cidade |
| `estado` | text | UF |
| `nicho` | text | Nicho de atuacao (estetica, odonto, etc.) |
| `data_inicio` | date | Data de entrada no programa |
| `cohort` | text | Turma: `N1`, `N2` ou `tese` |
| `ativo` | boolean | Se esta ativo no programa |
| `fase_jornada` | text | Fase atual: `onboarding`, `concepcao`, `validacao`, `otimizacao`, `escala` |
| `sub_etapa` | text | Sub-etapa dentro da fase |
| `marco_atual` | text | Ultimo marco atingido (M0-M5) |
| `risco_churn` | text | Risco de saida: `baixo`, `medio`, `alto`, `critico` |
| `score_engajamento` | integer | Score 0-100 de engajamento |
| `score_implementacao` | integer | Score 0-100 de implementacao |
| `faturamento_atual` | numeric | Faturamento mensal atual (R$) |
| `meta_faturamento` | numeric | Meta de faturamento (R$) |
| `faturamento_mentoria` | numeric | Faturamento gerado durante a mentoria |
| `ticket_produto` | numeric | Preco do produto/servico principal |
| `tem_produto` | boolean | Se ja tem produto estruturado |
| `ja_vendeu` | boolean | Se ja realizou vendas |
| `qtd_vendas_total` | integer | Total de vendas realizadas |
| `perfil_negocio` | text | Tipo de negocio |
| `frequencia_call` | text | Frequencia de calls: `semanal`, `quinzenal`, `mensal` |
| `proxima_call_agendada` | timestamptz | Data/hora da proxima call |
| `dossie_entregue` | boolean | Se o dossie estrategico foi entregue |
| `call_estrategia_realizada` | boolean | Se a call de estrategia aconteceu |
| `call_onboarding_realizada` | boolean | Se o onboarding aconteceu |
| `principais_travas` | jsonb | Array de travas/bloqueios atuais |
| `produtos_ofertados` | jsonb | Array de produtos |
| `historico_fases` | jsonb | Historico de mudancas de fase |

**Filtro nas views:** `WHERE ativo = true AND cohort IS DISTINCT FROM 'tese'` — retorna os 37 ativos reais.

---

### 1.2 `calls_mentoria` — Calls gravadas

**O que e:** Cada call individual entre Queila e um mentorado.

**Alimentada por:** Zoom API scraper automatico (a cada 30 min) + registro manual.

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `id` | bigint (PK) | ID da call |
| `mentorado_id` | bigint (FK) | Referencia mentorados.id |
| `data_call` | timestamptz | Data/hora da call |
| `duracao_minutos` | integer | Duracao em minutos |
| `tipo` | text | Tipo texto livre (legado) |
| `tipo_call` | text | Tipo com check constraint: `estrategia`, `follow_up`, `onboarding`, `conselho`, `qa`, `aula`, `imersao` |
| `status` | text | Status: `processando`, `completa`, `erro` |
| `zoom_meeting_id` | text | ID da reuniao no Zoom |
| `zoom_topic` | text | Titulo da reuniao no Zoom |
| `link_gravacao` | text | URL da gravacao |
| `link_transcricao` | text | URL da transcricao |
| `transcript_completo` | text | Texto completo da transcricao |
| `principais_topicos` | jsonb | Array de topicos discutidos |
| `decisoes_tomadas` | jsonb | Array de decisoes |
| `tarefas_geradas` | integer | Quantas tarefas foram geradas |
| `observacoes_equipe` | text | Notas da equipe |

**Total:** 226 calls | **Dados atuais:** jan/2025 a fev/2026

---

### 1.3 `analises_call` — Analise de IA por call

**O que e:** Para cada call, a IA gera uma analise estruturada com resumo, gargalos, feedbacks, etc.

**Alimentada por:** Workflow N8N automatico apos processamento da transcricao.

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `id` | uuid (PK) | ID da analise |
| `mentorado_id` | integer (FK) | Referencia mentorados.id |
| `data_call` | date | Data da call analisada |
| `tipo_call` | text | Tipo da call |
| `resumo` | text | Resumo em texto da call |
| `fase_identificada` | text | Fase detectada pela IA |
| `sentimento` | text | Sentimento geral: `positivo`, `neutro`, `negativo` |
| `gargalos` | text[] | Array de gargalos identificados |
| `proximos_passos` | text[] | Array de proximos passos |
| `feedbacks_consultora` | text[] | Feedbacks especificos da Queila |
| `citacoes_relevantes` | text[] | Frases importantes do mentorado |
| `marcos_detectados` | text[] | Marcos identificados na call |
| `vendas_mencionadas` | jsonb | Dados de vendas mencionadas |
| `produto_mencionado` | text | Produto mencionado |
| `ticket_mencionado` | numeric | Ticket mencionado |

**Total:** ~260 analises

---

### 1.4 `interacoes_mentoria` — Mensagens WhatsApp

**O que e:** Cada mensagem de cada grupo WhatsApp individual.

**Alimentada por:** WhatsApp scraper continuo (Evolution API) + imports manuais de ZIPs.

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `id` | bigint (PK) | ID da mensagem |
| `mentorado_id` | bigint (FK) | Referencia mentorados.id |
| `message_id` | varchar | ID unico da mensagem (hash para dedup) |
| `conteudo` | text | Texto da mensagem |
| `sender_name` | text | Nome de quem enviou |
| `message_type` | text | Tipo: `texto`, `audio`, `imagem`, `video`, `documento` |
| `categoria` | varchar | Categoria: `duvida`, `feedback`, `tarefa`, `financeiro`, etc. |
| `requer_resposta` | boolean | Se precisa de resposta da equipe |
| `respondido` | boolean | Se ja foi respondido |
| `eh_equipe` | boolean | Se foi enviado por alguem da equipe |
| `urgencia_resposta` | varchar | Urgencia: `baixa`, `normal`, `alta`, `critica` |
| `group_id` | varchar | ID do grupo WhatsApp |
| `timestamp` | timestamptz | Data/hora original da mensagem |
| `created_at` | timestamptz | Data/hora do registro no banco |

**Total:** 23.840 mensagens | **Cobertura:** 90% dos mentorados

---

### 1.5 `extracoes_agente` — Saidas dos agentes de IA

**O que e:** Cada vez que um agente IA processa uma call, gera uma extracao com dados estruturados.

**Alimentada por:** 5 agentes IA automaticos: DIAGNOSTICO, ESTRATEGIAS, TAREFAS_MENTORADO, TAREFAS_MENTORA, PRAZOS.

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `id` | uuid (PK) | ID da extracao |
| `call_id` | bigint | Call que gerou a extracao |
| `mentorado_id` | bigint | Mentorado associado |
| `agente_tipo` | text | Tipo do agente: `DIAGNOSTICO`, `ESTRATEGIAS`, `TAREFAS_MENTORADO`, `TAREFAS_MENTORA`, `PRAZOS` |
| `output_json` | jsonb | Dados estruturados extraidos |
| `output_text` | text | Versao texto do output |
| `modelo_usado` | text | Modelo de IA usado |
| `tokens_input` / `tokens_output` | integer | Consumo de tokens |

**Total:** 505 extracoes

---

### 1.6 `documentos_plano_acao` — Planos de acao

**O que e:** Documento consolidado gerado apos processamento de uma call.

**Alimentada por:** Workflow N8N que consolida as extracoes em um plano coerente.

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `id` | uuid (PK) | ID do plano |
| `mentorado_id` | bigint | Mentorado |
| `titulo` | text | Titulo do plano |
| `foco_principal` | text | Foco principal do momento |
| `completude_score` | integer | % de completude (0-100) |
| `status` | text | `RASCUNHO`, `FINALIZADO`, etc. |
| `secao_diagnostico` | jsonb | Diagnostico |
| `secao_objetivos` | jsonb | Objetivos |
| `secao_estrategias` | jsonb | Estrategias |
| `secao_proximos_passos` | jsonb | Proximos passos (array de objetos) |
| `documento_json` | jsonb | Documento completo |
| `documento_markdown` | text | Versao markdown |
| `google_doc_url` | text | Link do Google Doc gerado |

**Total:** 93 planos

---

### 1.7 `direcionamentos` — Orientacoes da Queila

**O que e:** Cada direcionamento especifico que a Queila deu para um mentorado.

**Alimentada por:** Extracao automatica das calls + registro manual.

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `id` | bigint (PK) | ID |
| `mentorado_id` | bigint (FK) | Mentorado |
| `titulo` | varchar | Titulo do direcionamento |
| `descricao` | text | Descricao detalhada |
| `tipo` | varchar | Tipo do direcionamento |
| `prioridade` | varchar | `normal`, `alta`, `urgente` |
| `status` | varchar | `aberto`, `em_andamento`, `concluido` |
| `prazo` | date | Prazo para execucao |

**Total:** 1.362 direcionamentos

---

### 1.8 `tarefas_acordadas` — Tarefas manuais

**O que e:** Tarefas combinadas explicitamente durante as calls.

**Alimentada por:** Registro manual pela equipe.

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `mentorado_id` | bigint (FK) | Mentorado |
| `tarefa` | text | Descricao da tarefa |
| `responsavel` | text | Quem deve fazer |
| `prioridade` | text | `baixa`, `media`, `alta` |
| `prazo` | timestamptz | Prazo |
| `status` | text | `pendente`, `em_andamento`, `concluida` |

**Total:** 9 tarefas

---

### 1.9 `tarefas_equipe` — Tarefas da equipe

**O que e:** Tarefas delegadas para membros da equipe (Lara, Jennifer, etc.).

**Alimentada por:** Workflow automatico + registro manual.

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `mentorado_id` | bigint | Mentorado relacionado |
| `mentorado_nome` | varchar | Nome do mentorado |
| `tarefa` | text | Descricao |
| `responsavel_nome` | varchar | Nome do responsavel |
| `prioridade` | varchar | `normal`, `alta`, `urgente` |
| `prazo` | date | Prazo |
| `status` | varchar | `pendente`, `em_andamento`, `concluida` |

**Total:** 264 tarefas

---

### 1.10 `marcos_mentorado` — Milestones

**O que e:** Marcos de progresso atingidos por cada mentorado (M0 a M5).

**Alimentada por:** Deteccao automatica pela IA + registro manual.

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `mentorado_id` | integer (FK) | Mentorado |
| `marco` | text | Nome do marco (ex: `M1 - Produto definido`) |
| `fase` | text | Fase do marco |
| `data_atingido` | date | Quando foi atingido |
| `evidencia` | text | Evidencia/contexto |
| `fonte` | text | De onde veio (call, manual, etc.) |
| `confianca` | numeric | Confianca da deteccao (0-1) |

**Total:** ~104 marcos

---

### 1.11 `travas_bloqueios` — Bloqueios

**O que e:** Problemas recorrentes que travam o progresso do mentorado.

**Alimentada por:** Deteccao automatica pela IA.

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `mentorado_id` | bigint (FK) | Mentorado |
| `tipo` | varchar | Tipo: `entrega`, `comercial`, `conteudo`, `emocional` |
| `area` | varchar | Area afetada |
| `descricao` | text | Descricao do bloqueio |
| `frequencia` | integer | Quantas vezes mencionado |
| `primeira_mencao` / `ultima_mencao` | timestamptz | Periodo |
| `resolvido` | boolean | Se ja foi resolvido |

---

### 1.12 `metricas_mentorado` — Dados de vendas

**O que e:** Registros de vendas e metricas financeiras.

**Alimentada por:** Registro manual + extracao das calls.

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `mentorado_id` | bigint | Mentorado |
| `valor_vendas` | numeric | Valor da venda |
| `data` | date | Data |
| `extraido_de` | text | Fonte do dado |

---

### 1.13 `god_tasks` — Tarefas bidirecionais (NOVO)

**O que e:** Sistema de tarefas ClickUp-style com CRUD completo. O frontend LE e ESCREVE nesta tabela.

**Alimentada por:** Migracao das 4 fontes existentes + criacao manual no dashboard.

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `id` | uuid (PK) | ID unico (UUID gerado no frontend) |
| `titulo` | text | Titulo da tarefa |
| `descricao` | text | Descricao detalhada |
| `status` | text | `pendente`, `em_andamento`, `concluida`, `cancelada` |
| `prioridade` | text | `urgente`, `alta`, `media`, `baixa` |
| `responsavel` | text | Nome do responsavel (mentorado, Queila, equipe) |
| `mentorado_id` | bigint (FK) | Referencia mentorados.id |
| `mentorado_nome` | text | Nome do mentorado (desnormalizado) |
| `data_inicio` | date | Data de inicio |
| `data_fim` | date | Data limite/prazo |
| `space_id` | text | Space ClickUp-style: space_mentorados, space_equipe, space_queila |
| `list_id` | text | List dentro do Space |
| `parent_task_id` | uuid (FK self) | Para sub-tarefas hierarquicas |
| `tags` | text[] | Array de tags |
| `fonte` | text | Origem: manual, tarefas_acordadas, proximos_passos, plano_acao, equipe |
| `doc_link` | text | Link para documento relacionado |
| `created_at` | timestamptz | Data de criacao |
| `updated_at` | timestamptz | Data de ultima atualizacao |
| `created_by` | text | Quem criou |

---

### 1.14 `god_task_subtasks` — Sub-tarefas

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `id` | bigserial (PK) | ID unico |
| `task_id` | uuid (FK) | Referencia god_tasks.id |
| `texto` | text | Texto da sub-tarefa |
| `done` | boolean | Se esta concluida |
| `sort_order` | integer | Ordem de exibicao |

---

### 1.15 `god_task_checklist` — Checklist

Mesma estrutura que subtasks (id, task_id, texto, done, sort_order).

---

### 1.16 `god_task_comments` — Comentarios

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `id` | bigserial (PK) | ID unico |
| `task_id` | uuid (FK) | Referencia god_tasks.id |
| `author` | text | Nome do autor |
| `texto` | text | Texto do comentario |
| `created_at` | timestamptz | Data/hora |

---

### 1.17 `god_task_handoffs` — Handoffs

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `id` | bigserial (PK) | ID unico |
| `task_id` | uuid (FK) | Referencia god_tasks.id |
| `from_person` | text | De quem |
| `to_person` | text | Para quem |
| `note` | text | Nota do handoff |
| `created_at` | timestamptz | Data/hora |

---

## 2. Views SQL — O que cada uma faz

### 2.1 `vw_god_overview` — Vista master enxuta (pagina principal)

**Consumida por:** Pagina de listagem de mentorados (cards).

**Retorna:** 1 linha por mentorado com 24 colunas — so o que importa num card.

**Fontes:** mentorados + interacoes_mentoria + calls_mentoria + tarefas_acordadas + tarefas_equipe

**Colunas:**

| Grupo | Colunas | Descricao |
|-------|---------|-----------|
| Identidade | `id`, `nome`, `instagram`, `cohort` | Quem e |
| Progresso | `fase_jornada`, `sub_etapa`, `marco_atual` | Onde esta no programa |
| Saude | `risco_churn`, `engagement_score`, `implementation_score` | Precisa de atencao? |
| Financeiro | `faturamento_atual`, `meta_faturamento`, `pct_meta_atingida`, `qtd_vendas_total`, `ja_vendeu` | Vendas e faturamento |
| WhatsApp | `whatsapp_7d`, `whatsapp_30d`, `whatsapp_total`, `msgs_pendentes_resposta`, `horas_sem_resposta_equipe` | Atividade e pendencias |
| Calls | `ultima_call_data`, `dias_desde_call` | Quando foi a ultima call |
| Tarefas | `tarefas_pendentes`, `tarefas_atrasadas` | Status de tarefas |

**Uso no frontend:**
```js
const { data } = await supabase.from('vw_god_overview').select('*')
// Retorna 37 mentorados com todos os dados
```

---

### 2.2 `vw_god_tarefas` — Todas as tarefas unificadas

**Consumida por:** Pagina global de tarefas + secao "Plano de Acao" no detalhe.

**Retorna:** Todas as tarefas de 4 fontes diferentes num formato unico.

**Fontes:**
1. `tarefas_acordadas` — Tarefas combinadas nas calls (9)
2. `tarefas_equipe` — Tarefas delegadas para equipe (264)
3. `analises_call.proximos_passos` — Proximos passos extraidos pela IA
4. `documentos_plano_acao.secao_proximos_passos` — Passos dos planos de acao

**Colunas:**

| Coluna | Descricao |
|--------|-----------|
| `mentorado_id` | ID do mentorado |
| `mentorado_nome` | Nome |
| `tarefa` | Descricao da tarefa |
| `responsavel` | Quem deve executar |
| `prioridade` | baixa/media/alta |
| `prazo` | Data limite |
| `status` | pendente/em_andamento/concluida |
| `fonte` | De onde veio: `tarefas_acordadas`, `tarefas_equipe`, `analise_call`, `plano_acao` |
| `data_criacao` | Quando foi criada |

**Total:** 803 tarefas unificadas

---

### 2.3 `vw_god_calls` — Historico de calls com analise IA

**Consumida por:** Timeline de calls no detalhe do mentorado.

**Retorna:** Cada call com dados da gravacao + analise IA correspondente.

**Fontes:** calls_mentoria LEFT JOIN analises_call

**Colunas:** `call_id`, `data_call`, `tipo_call`, `duracao_minutos`, `link_gravacao`, `link_transcricao`, `zoom_topic`, `resumo` (IA), `principais_topicos`, `decisoes_tomadas`, `proximos_passos` (IA), `gargalos` (IA), `feedbacks_consultora` (IA)

**Total:** 211 calls

---

### 2.4 `vw_god_contexto_ia` — Ultimo contexto IA por mentorado

**Consumida por:** Card "Contexto Inteligente" no detalhe.

**Retorna:** O output mais recente de cada agente IA para cada mentorado.

**Fontes:** extracoes_agente (DISTINCT ON mentorado + agente) + documentos_plano_acao

**Colunas:** `cenario_atual`, `gargalos`, `ativos`, `tarefas_mentorado_pendentes`, `tarefas_queila_pendentes`, `estrategias_atuais`, `prazos_proximos`, `ultimo_plano_titulo`, `ultimo_foco`, `completude_plano`, `ultimo_plano_em`

---

### 2.5 `vw_god_pendencias` — Mensagens sem resposta

**Consumida por:** Secao "Alertas" + lista global de pendencias.

**Retorna:** Mensagens do WhatsApp que precisam de resposta da equipe.

**Fontes:** interacoes_mentoria WHERE requer_resposta=true AND respondido=false

**Colunas:** `mentorado_id`, `conteudo_truncado`, `horas_pendente`, `prioridade_calculada` (critico >48h, alto >24h, medio >12h, baixo <12h)

**Total:** 413 pendencias

---

### 2.6 `vw_god_direcionamentos` — Tudo que a Queila orientou

**Consumida por:** Secao "Direcionamentos Estrategicos" no detalhe.

**Retorna:** Todos os direcionamentos de 3 fontes.

**Fontes:**
1. `direcionamentos` — Tabela direta (1.362 rows)
2. `analises_call.feedbacks_consultora` — Feedbacks extraidos das calls
3. `extracoes_agente` tipo TAREFAS_MENTORA — Tarefas da Queila extraidas pela IA

**Total:** 1.673 direcionamentos unificados

---

### 2.7 `vw_god_vendas` — Pipeline de vendas

**Consumida por:** Secao de vendas no detalhe.

**Retorna:** 1 linha por mentorado com dados financeiros consolidados.

**Fontes:** mentorados + metricas_mentorado

**Colunas:** `faturamento_atual`, `meta_faturamento`, `pct_meta_atingida`, `qtd_vendas_total`, `ja_vendeu`, `faturamento_mentoria`, `ticket_produto`, `total_vendas_metricas`, `ultima_venda_data`

---

### 2.8 `vw_god_timeline` — Feed de atividade

**Consumida por:** Feed cronologico no detalhe do mentorado.

**Retorna:** Eventos relevantes de um mentorado em ordem cronologica. Sem WhatsApp (a mentora ja ve no celular).

**Fontes:** calls + marcos + direcionamentos + planos de acao + sessoes de grupo

**Colunas:** `mentorado_id`, `evento_tipo` (call/marco/direcionamento/plano_acao/grupo), `data`, `titulo`, `descricao`, `metadata_json`

**Total:** ~1.957 eventos

---

### 2.9 `vw_god_cohort` — KPIs por fase

**Consumida por:** Dashboard principal (KPIs globais + heatmap).

**Retorna:** 1 linha por fase com metricas agregadas.

| Coluna | Descricao |
|--------|-----------|
| `fase` | onboarding/concepcao/validacao/otimizacao/escala |
| `total_mentorados` | Quantos na fase |
| `criticos` / `altos` / `medios` / `baixos` | Distribuicao de risco |
| `avg_engagement` | Media de engajamento da fase |
| `avg_implementation` | Media de implementacao |

---

### 2.10 `vw_god_tasks_full` — Tarefas com agregacoes (NOVO)

**O que retorna:** Todas as tarefas de `god_tasks` com subtasks, checklist, comments e handoffs agregados como arrays JSON.

**Colunas:** Todas de `god_tasks` + 4 colunas agregadas:
| Coluna Extra | Tipo | Descricao |
|-------------|------|-----------|
| `subtasks` | jsonb[] | Array de {texto, done, sort_order} |
| `checklist` | jsonb[] | Array de {texto, done, sort_order} |
| `comments` | jsonb[] | Array de {id, author, texto, created_at} |
| `handoffs` | jsonb[] | Array de {id, from_person, to_person, note, created_at} |

**Frontend usa:** `sb.from('vw_god_tasks_full').select('*').order('created_at', { ascending: false }).limit(200)`

---

## 3. Functions SQL

### 3.1 `fn_god_mentorado_deep(p_id bigint)` — Raio-X completo

**Chamada por:** Pagina de detalhe de um mentorado.

**Retorna:** JSON com 9 secoes:

```json
{
  "profile": { "id", "nome", "instagram", "cidade", "cohort", "data_inicio", ... },
  "phase": { "fase_jornada", "marcos_atingidos", "risco_churn", "health", ... },
  "financial": { "faturamento_atual", "meta_faturamento", "pct_meta_atingida", "ja_vendeu", ... },
  "context_ia": { "cenario_atual", "gargalos", "estrategias", "prazos", ... },
  "last_calls": [ /* ultimas 5 calls com analise IA */ ],
  "last_messages": [ /* ultimas 5 mensagens WhatsApp (contexto rapido) */ ],
  "pending_tasks": [ /* tarefas pendentes/em andamento */ ],
  "blockers": [ /* travas ativas nao resolvidas */ ],
  "directions": [ /* ultimos 10 direcionamentos da Queila */ ]
}
```

**Uso no frontend:**
```js
const { data } = await supabase.rpc('fn_god_mentorado_deep', { p_id: 13 })
// Retorna JSON completo da Livia Lyra
```

---

### 3.2 `fn_god_alerts()` — Central de alertas

**Chamada por:** Pagina de alertas + badge no header.

**Retorna:** Tabela de alertas priorizados (critico > alto > medio).

**5 tipos de alerta:**

| Tipo | Condicao | Severidade |
|------|----------|------------|
| `sem_resposta` | Mensagem pendente >12h | medio (12-24h), alto (24-48h), critico (>48h) |
| `sem_call` | Sem call >21 dias ou nunca fez call | alto (21-30d ou nunca), critico (>30d) |
| `tarefas_atrasadas` | >2 tarefas atrasadas | medio (2-3), alto (3-5), critico (>5) |
| `risco_churn` | Risco alto ou critico | valor do risco |
| `sem_whatsapp` | 0 msgs nos ultimos 7 dias | medio (se tinha 30d), alto (se nem 30d) |

**Uso:**
```js
const { data } = await supabase.rpc('fn_god_alerts')
// Retorna array: [{ alerta_tipo, severidade, mentorado_id, mentorado_nome, descricao, ... }]
```

---

## 4. Filtros e Regras

### Filtro principal de mentorados

Todas as views filtram:
```sql
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'
```

Isso garante que:
- Os 20 mentorados "tese" (pesquisa academica) **nunca aparecem**
- Os 5 inativos (pediram reembolso/sairam) **nunca aparecem**
- Restam os **37 mentorados reais** (29 N1 + 8 N2)

### Tipos de mentorado_id

As tabelas usam tipos diferentes para `mentorado_id`:
- `mentorados.id` = bigint (serial)
- `calls_mentoria.mentorado_id` = bigint
- `analises_call.mentorado_id` = integer
- `interacoes_mentoria.mentorado_id` = bigint
- `extracoes_agente.mentorado_id` = bigint
- `marcos_mentorado.mentorado_id` = integer

As views ja tratam os casts necessarios — o frontend nao precisa se preocupar.

### Notas sobre colunas

- `interacoes_mentoria.respondido` — booleano que indica se a mensagem foi respondida
- `calls_mentoria` tem duas colunas de tipo: `tipo` (texto livre, legado) e `tipo_call` (com check constraint). As views usam `COALESCE(tipo_call, tipo)` para priorizar o mais recente

---

## 5. Indexes criados para performance

```sql
idx_god_interacoes_pending   -- Partial index: requer_resposta=true AND respondido=false
idx_god_extracoes_latest     -- mentorado_id + agente_tipo + created_at DESC
idx_god_docs_latest          -- mentorado_id + created_at DESC
idx_god_calls_latest         -- mentorado_id + data_call DESC
idx_god_analises_latest      -- mentorado_id + data_call DESC
idx_god_direcionamentos_mentorado -- mentorado_id + created_at DESC
idx_god_marcos_mentorado     -- mentorado_id + created_at DESC
```

---

## 6. Grants (permissoes)

Todas as views e functions tem `GRANT SELECT` para os roles `authenticated` e `anon` do Supabase. Isso permite acesso via Supabase Client SDK.

---

## 7. Como a Spalla consome

### Listagem principal
```js
// Pagina de cards com todos os mentorados
const { data: mentorados } = await supabase
  .from('vw_god_overview')
  .select('*')
  .order('fase_jornada')
```

### Detalhe de um mentorado
```js
// Raio-X completo
const { data: detail } = await supabase
  .rpc('fn_god_mentorado_deep', { p_id: mentoradoId })

// Timeline
const { data: timeline } = await supabase
  .from('vw_god_timeline')
  .select('*')
  .eq('mentorado_id', mentoradoId)
  .order('data', { ascending: false })
  .limit(50)
```

### Alertas globais
```js
const { data: alerts } = await supabase.rpc('fn_god_alerts')
```

### KPIs do programa
```js
const { data: kpis } = await supabase.from('vw_god_cohort').select('*')
```

### Tarefas globais
```js
const { data: tasks } = await supabase
  .from('vw_god_tarefas')
  .select('*')
  .eq('status', 'pendente')
  .order('data_criacao', { ascending: false })
```

### Operacoes de ESCRITA (god_tasks)

O frontend agora tambem ESCREVE no Supabase:

```javascript
// Criar/atualizar tarefa
await sb.from('god_tasks').upsert(taskData, { onConflict: 'id' });

// Sync subtasks
await sb.from('god_task_subtasks').delete().eq('task_id', id);
await sb.from('god_task_subtasks').insert(subtasks);

// Adicionar comentario
await sb.from('god_task_comments').insert({ task_id, author, texto });
```

**Fallback:** Se Supabase falhar, dados sao salvos em localStorage e sincronizados na proxima sessao.

---

## 8. Diagrama de dependencias

```
Frontend Spalla
    |
    v
+-- vw_god_overview -------> mentorados + interacoes + calls + tarefas (24 colunas enxutas)
+-- vw_god_tarefas --------> tarefas_acordadas + tarefas_equipe + analises_call + docs
+-- vw_god_calls ----------> calls_mentoria + analises_call (sem metadata tecnica)
+-- vw_god_contexto_ia ----> extracoes_agente + documentos_plano_acao
+-- vw_god_pendencias -----> interacoes_mentoria (filtro: pendentes)
+-- vw_god_direcionamentos > direcionamentos + analises_call + extracoes
+-- vw_god_vendas ---------> mentorados + metricas_mentorado
+-- vw_god_timeline -------> calls + marcos + direcionamentos + docs + sessoes grupo (sem WhatsApp)
+-- vw_god_cohort ---------> mentorados (distribuicao por fase)
+-- fn_god_mentorado_deep -> vw_god_calls + vw_god_contexto_ia + vw_god_direcionamentos + vw_god_tarefas + interacoes + marcos + travas
+-- fn_god_alerts ---------> vw_god_pendencias + vw_god_overview
```

---

