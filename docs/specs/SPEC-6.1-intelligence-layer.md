---
title: "SPEC-6.1 — Intelligence Layer (5 Features)"
type: feature-spec
status: approved
author: atlas-analyst
date: 2026-03-21
bu: BU-CASE
project: spalla-dashboard
size: L
epic: 6
parent-spec: SPEC-6.0-wa-management-module.md
---

# SPEC-6.1 — Intelligence Layer

## Contexto

O benchmark de 11 ferramentas identificou 5 features de "camada de inteligência" que nenhuma das features F1-F10 (SPEC-6.0) endereçou. Essas features transformam o Spalla de um dashboard reativo em um sistema consultivo proativo.

**Stack existente relevante:**
- Frontend: Alpine.js + HTML (Operon Design System)
- Backend: Python HTTP server (`14-APP-server.py`)
- DB: Supabase PostgreSQL
- WA: Evolution API proxy via `/api/evolution/{path}`
- Tabelas já existentes: `mentorados`, `wa_message_queue`, `wa_topics`, `wa_topic_types`, `sp_arquivos`
- Endpoints já existentes: `GET /api/mentees`, `GET /api/storage/files`, `POST /api/copilot`

---

## Features

### I-1 — AI Auto-labeling de Mensagens (Trengo-inspired)

**Problema:** Os tópicos (`wa_topics`) já têm tipo e confiança, mas as **mensagens individuais** chegam sem classificação. O consultor não sabe, sem ler tudo, se uma mensagem é uma dúvida, um action item, uma reclamação, ou uma entrega. A UI não mostra isso.

**Solução:** Cada mensagem na `wa_message_queue` recebe label automático por IA (n8n já processa as mensagens — basta adicionar o label). UI exibe badges de label nos tópicos do digest e na carteira.

**Categorias de label:**
| Slug | Label PT | Cor |
|------|----------|-----|
| `action_item` | Action Item | amber |
| `question` | Dúvida | blue |
| `emotional` | Emocional | purple |
| `delivery` | Entrega | green |
| `complaint` | Reclamação | red |
| `update` | Update | gray |
| `gratitude` | Agradecimento | teal |

#### Escopo Exato

- Adicionar coluna `msg_label` (varchar) e `msg_label_confidence` (float) na `wa_message_queue`
- Novo endpoint `GET /api/wa/labels/summary?mentee_id={id}` — retorna contagem de labels por mentorado nos últimos 30 dias
- UI: badges de label no digest drawer por tópico
- UI: no carteira card, badge de label dominante (ex: "3 action items pendentes")
- **NÃO está no escopo:** re-classificar mensagens históricas retroativamente (só novas mensagens)

#### Novos Endpoints

```
GET /api/wa/labels/summary?mentee_id={id}&days=30
→ { action_item: 3, question: 1, emotional: 0, delivery: 2, complaint: 0, update: 5 }
```

#### Nova Tabela/Migration

```sql
-- Adicionar colunas em wa_message_queue (migration)
ALTER TABLE wa_message_queue
  ADD COLUMN IF NOT EXISTS msg_label VARCHAR(32),
  ADD COLUMN IF NOT EXISTS msg_label_confidence FLOAT DEFAULT NULL;

-- Índice para queries por label + group
CREATE INDEX IF NOT EXISTS idx_wa_msg_label ON wa_message_queue(group_jid, msg_label)
  WHERE msg_label IS NOT NULL;
```

**Nota técnica:** n8n já processa as mensagens. Adicionar step de classification no workflow existente que faz POST na Evolution API. O label vai junto com o tópico já criado.

#### Componentes Alpine.js

1. `waMsgLabelBadge(label)` → retorna `{ text, color }` dado um slug de label
2. `waLabelSummary(menteeId)` → async, chama `/api/wa/labels/summary`, popula `data.labelSummaries[menteeId]`
3. No digest drawer: `<template x-for="topic in data.digestTopicos">` adicionar badges dos labels dos msgs daquele tópico
4. No carteira card: badge condicional "N action items" se `labelSummary.action_item > 0`

#### Sequência de Implementação

1. Migration: adicionar colunas em `wa_message_queue`
2. Backend: endpoint `GET /api/wa/labels/summary`
3. Frontend: função `waMsgLabelBadge()` + helper `waLabelSummary()`
4. Frontend: badges no carteira card
5. Frontend: badges no digest drawer
6. n8n: adicionar step de label no workflow de ingestion *(fora do scope do dev — @n8n-team)*

---

### I-2 — Triage Score (Crisp-inspired)

**Problema:** O inbox atual ordena por dias de inatividade + msgs não lidas. Simples demais. Um mentorado em onboarding sem resposta há 2 dias é mais crítico que um mentorado veterano sem resposta há 5 dias — mas o inbox atual mostraria o veterano primeiro.

**Solução:** Score composto `triage_score` que considera 5 dimensões com pesos. Novo endpoint retorna mentorados já ordenados. A view "Inbox" do wa_management usa esse endpoint em vez do sort local.

**Fórmula do triage score (0-100):**
```
score = (dias_sem_interacao × 2.0)           # peso máximo
      + (fase_critica ? 20 : 0)              # onboarding OU renovacao
      + (pendencias_consultor × 5)           # action_items não respondidos
      + (msgs_nao_lidas × 1.5)               # volume
      + (sentimento_negativo ? 15 : 0)       # topic com complaint recente
```

Onde `fase_critica` = `fase_jornada IN ('onboarding', 'renovacao')`.

#### Escopo Exato

- Novo endpoint `GET /api/mentees/triage` que computa e retorna lista ordenada por score
- View "Inbox" do `wa_management` consome esse endpoint (atualmente usa ordenação local em `waComputePriorityScore()`)
- Score visível como badge no carteira card e no inbox row
- **NÃO está no escopo:** ML, modelos externos, treinamento. Tudo é lógica determinística no backend.

#### Novo Endpoint

```
GET /api/mentees/triage
→ Array de mentorados com campo adicional:
  {
    ...mentee_fields,
    triage_score: 87,
    triage_breakdown: {
      dias_sem_interacao: 4,
      fase_critica: true,
      pendencias_consultor: 2,
      msgs_nao_lidas: 12,
      sentimento_negativo: false
    }
  }
```

Calculado via query Supabase (JOIN `mentorados` + `wa_topics` + `wa_message_queue`).

#### Sem novas tabelas

Toda a informação já existe. O endpoint faz agregação na query.

#### Componentes Alpine.js

1. `loadMenteesTriage()` → substitui `loadMentees()` no contexto do wa_management (não globalmente)
2. `waTriageBadge(score)` → retorna cor + label (`{ color, text }`) baseado em faixas: 0-30=verde, 31-60=amarelo, 61+=vermelho
3. No inbox view: substituir ordenação atual por resultado do `/api/mentees/triage`
4. No carteira card: badge do score ao lado do health indicator
5. Breakdown tooltip: `x-data="{ open: false }"` com `@mouseenter`/`@mouseleave`

#### Sequência de Implementação

1. Backend: `_handle_mentees_triage()` com query agregada
2. Backend: registrar `GET /api/mentees/triage` no do_GET
3. Frontend: `loadMenteesTriage()` + `waTriageBadge()`
4. Frontend: inbox view consume o novo endpoint
5. Frontend: badge no carteira card com tooltip breakdown

---

### I-3 — Group Hub por Mentorado (Periskope-inspired)

**Problema:** O Spalla trata o grupo WhatsApp do mentorado como um canal de chat. Periskope trata o grupo como uma **entidade com saúde própria**: atividade, participantes, mensagens sinalizadas, timeline de decisões. O consultor precisa entender o grupo como um todo, não só ler mensagens.

**Solução:** Painel "Group Hub" acessível via botão no carteira card. Drawer lateral que mostra:
- Health do grupo (baseado em `wa_topics` do `group_jid`)
- Timeline de tópicos/decisões do grupo (últimos 30 dias)
- Mensagens sinalizadas por IA (action items, complaints, deliveries)
- Atividade recente (msgs por dia — sparkline simples)

#### Escopo Exato

- Novo endpoint `GET /api/wa/group-hub?mentee_id={id}` — agrega dados do grupo
- Novo drawer "Group Hub" no HTML (similar ao Notes Drawer existente)
- Botão de acesso no carteira card (ícone de grupo)
- **NÃO está no escopo:** WebSocket real-time, acesso direto à Evolution API para listar participantes do grupo, métricas de participantes individuais

#### Novo Endpoint

```
GET /api/wa/group-hub?mentee_id={id}
→ {
    group_jid: "...",
    total_topicos: 12,
    topicos_abertos: 3,
    topicos_pendentes: 2,
    msgs_semana: 47,
    msgs_por_dia: [4, 7, 3, 8, 12, 9, 4],    // últimos 7 dias
    topicos_recentes: [                         // últimos 10, ordenados por last_message_at
      { id, title, status, type_name, type_color, last_message_at, msgs_awaiting_response }
    ],
    mensagens_sinalizadas: [                    // msgs com label action_item ou complaint
      { id, body, msg_label, created_at, from_me }
    ]
  }
```

Query: JOIN `mentorados` + `wa_topics` (group_jid) + `wa_message_queue` (group_jid).

#### Sem novas tabelas

Toda informação já existe em `wa_topics`, `wa_message_queue`, `mentorados`.

#### Componentes Alpine.js

1. Estado: `ui.groupHub = { open: false, menteeId: null, data: null, loading: false }`
2. `openGroupHub(menteeId)` → seta `ui.groupHub.open = true`, chama endpoint, popula dados
3. `closeGroupHub()` → limpa estado
4. Drawer HTML: `x-show="ui.groupHub.open"` — posição fixa, similar ao Notes Drawer
5. Dentro do drawer:
   - 4 KPI pills: tópicos abertos, pendentes, msgs semana, sinalizadas
   - Sparkline de atividade (7 barras via divs com altura relativa — sem biblioteca)
   - Lista de tópicos recentes com status badges
   - Lista de mensagens sinalizadas com label badge
6. Botão no carteira card: ícone de users/grupo com `@click="openGroupHub(m.id)"`

#### Sequência de Implementação

1. Backend: `_handle_wa_group_hub()` com query agregada (JOIN wa_topics + wa_message_queue)
2. Backend: registrar `GET /api/wa/group-hub` no do_GET
3. Frontend: estado `ui.groupHub`, funções `openGroupHub/closeGroupHub`
4. Frontend: drawer HTML completo
5. Frontend: botão de acesso no carteira card

---

### I-4 — Copilot com Histórico do Mentorado (Crisp + Intercom-inspired)

**Problema:** O Copilot atual (`ui.waCopilotOpen`) usa como contexto o estado geral do portfólio (`_waCopilotContext()`). Quando o consultor pergunta "O que a Ana falou essa semana?", o copilot não tem o histórico específico da Ana — só sabe que ela existe no portfólio.

**Solução:** Quando o Copilot é aberto **a partir do contexto de um mentorado específico** (botão no carteira card ou no Group Hub), o endpoint `/api/copilot` recebe `mentee_id` e enriquece o contexto com:
- Últimos 10 tópicos do grupo da Ana
- Últimas 5 notas estruturadas da Ana
- Mensagens sinalizadas (action items não resolvidos)
- Fase da mentoria + dias sem interação

O copilot genérico (sem mentee_id) permanece como está.

#### Escopo Exato

- Modificar `POST /api/copilot` para aceitar campo `mentee_id` opcional
- Backend: se `mentee_id` presente, buscar histórico específico e incluir no system prompt
- Frontend: `openCopilot(menteeId = null)` — aceita `menteeId` opcional
- Botão contextual no carteira card: "Perguntar sobre [Nome]"
- Header do copilot mostra para qual mentorado está contextualizando
- **NÃO está no escopo:** memória persistente entre sessões, fine-tuning, histórico de perguntas salvo no DB

#### Modificação de Endpoint Existente

```
POST /api/copilot
Body: { message, context: 'portfolio' | 'mentee', mentee_id?: string }

Comportamento:
- context='portfolio' (default): comportamento atual, sem mudança
- context='mentee', mentee_id=X: busca histórico do mentorado X no DB,
  adiciona ao system prompt antes de chamar GPT-4o-mini
```

**System prompt adicional (quando mentee_id presente):**
```
Você está auxiliando um consultor a gerir o mentorado: {nome}.
Fase: {fase}. Último contato: {N} dias atrás.

Tópicos recentes do grupo:
{lista de wa_topics com title + status}

Últimas notas:
{lista de mentee_notes com tipo + resumo}

Action items pendentes:
{wa_topics com status=pending_action}

Responda baseado APENAS nessas informações. Se não souber, diga que não tem dados.
```

#### Sem novas tabelas

A busca do histórico é feita via Supabase queries nas tabelas existentes.

#### Componentes Alpine.js

1. `openCopilot(menteeId = null)` — modificar função existente: se menteeId, popula `ui.waCopilotContext = { menteeId, menteeName }`
2. `askCopilot()` — modificar para incluir `mentee_id` no body se `ui.waCopilotContext.menteeId` existir
3. Header do copilot: `x-show="ui.waCopilotContext.menteeId"` com texto "Contexto: [Nome]" + botão X para limpar contexto
4. Botão no carteira card: "Copilot sobre [Nome]" com ícone diferenciado (sparkles colorido)
5. Estado: `ui.waCopilotContext = { menteeId: null, menteeName: null }`

#### Sequência de Implementação

1. Backend: modificar `_handle_copilot()` — aceitar `mentee_id`, buscar histórico, enriquecer prompt
2. Frontend: modificar `openCopilot()` para aceitar `menteeId`
3. Frontend: modificar `askCopilot()` para passar `mentee_id`
4. Frontend: header contextual no painel do copilot
5. Frontend: botão contextual no carteira card

---

### I-5 — File View por Mentorado (Respond.io-inspired)

**Problema:** O consultor não consegue achar um documento enviado pelo mentorado sem rolar horas de conversa. Não existe galeria de arquivos por mentorado.

**Solução:** Aba "Arquivos" no Notes Drawer (que já existe por mentorado). Mostra 2 categorias:
1. **Documentos do Spalla** — arquivos em `sp_arquivos` onde `entidade_tipo='mentorado'` e `entidade_id={id}` (endpoint já existe: `GET /api/storage/files`)
2. **Mídia do WhatsApp** — arquivos enviados no grupo via Evolution API (imagens, PDFs, áudios)

#### Escopo Exato

- Adicionar aba "Arquivos" no Notes Drawer (ao lado das abas existentes de notas/digest)
- Consumir `GET /api/storage/files?entidade_tipo=mentorado&entidade_id={id}` (JÁ EXISTE — zero backend)
- Novo endpoint `GET /api/wa/media?mentee_id={id}&limit=20` — lista mídia WA recente do grupo
- UI: grid de thumbnails para imagens, lista para docs/áudio
- Click em item: abre media modal existente (`openMedia()`)
- **NÃO está no escopo:** upload de arquivos nessa view, arquivos de outros contextos que não sejam o mentorado específico, paginação (só últimos 20 itens WA)

#### Novo Endpoint

```
GET /api/wa/media?mentee_id={id}&limit=20
→ [
    {
      id,
      filename,
      mime_type,
      url,           // presigned S3 URL via generate_presigned_url()
      created_at,
      message_type,  // 'imageMessage' | 'documentMessage' | 'audioMessage' | 'videoMessage'
      from_me        // bool
    }
  ]
```

Query: busca `group_jid` do mentorado → filtra `wa_message_queue` por `group_jid` e `message_type NOT IN ('conversation', 'extendedTextMessage')` → gera presigned URLs via S3.

#### Sem novas tabelas

Dados já existem em `wa_message_queue` (campo `s3_key` ou similar) e `sp_arquivos`.

#### Componentes Alpine.js

1. Estado no drawer de notas: `ui.notesDrawer.tab = 'notes' | 'files'` — adicionar ao estado existente
2. `loadMenteeFiles(menteeId)` → chama ambos endpoints em paralelo, popula `data.menteeFiles[menteeId] = { docs: [], media: [] }`
3. No Notes Drawer: adicionar tab switcher "Notas | Arquivos"
4. FileView HTML:
   - Seção "Documentos" — lista com ícone por tipo (pdf, xlsx, docx), nome, data, botão "Abrir"
   - Seção "Mídia WA" — grid 3 colunas para imagens (thumbnail), lista para áudios/docs
   - Estado vazio: "Nenhum arquivo compartilhado ainda"
5. Ao abrir o drawer: `loadMenteeFiles(menteeId)` dispara junto com `loadMenteeNotes()`

#### Sequência de Implementação

1. Backend: `_handle_wa_media()` — busca `group_jid` do mentee, filtra `wa_message_queue` por mídia, gera presigned URLs
2. Backend: registrar `GET /api/wa/media` no do_GET
3. Frontend: estado `ui.notesDrawer.tab`, função `loadMenteeFiles()`
4. Frontend: tab switcher no drawer header
5. Frontend: FileView HTML com seções docs + mídia

---

## Sequência de Implementação Geral

Ordem recomendada considerando dependências e valor entregue por fase:

```
FASE 1 (1-2 dias) — Backend-heavy, sem UX risk
  → I-2 Triage Score endpoint (puro cálculo, zero risco)
  → I-5 File View endpoint WA media (backend simples, endpoint similar ao presign existente)

FASE 2 (1-2 dias) — Frontend dos dois backends prontos
  → I-2 Triage Score UI (badge no card + inbox reordenado)
  → I-5 File View UI (aba no drawer existente)

FASE 3 (1-2 dias) — Features com mais estado de UI
  → I-4 Copilot Contextual (modificação do copilot existente — baixo risco)
  → I-1 Label Summary endpoint + badges no card/digest

FASE 4 (2-3 dias) — Feature mais complexa de UI
  → I-3 Group Hub (novo drawer + endpoint agregado)
  → I-1 n8n step de labeling (coordenar com n8n-team)
```

**Dependências entre features:**
- I-3 (Group Hub) depende de I-1 (labels) para mostrar mensagens sinalizadas → implementar I-1 backend antes de finalizar I-3 UI
- I-4 (Copilot contextual) funciona independente das demais
- I-2 e I-5 são completamente independentes

---

## Fora do Escopo (Hard Boundaries)

| Item | Motivo |
|------|--------|
| Re-classificação retroativa de mensagens | Volume + custo de API |
| Participantes individuais do grupo WA | Evolution API não expõe facilmente via proxy atual |
| Memória persistente do Copilot entre sessões | Requer tabela de histórico + privacidade |
| Upload de arquivos na FileView | Escopo separado (storage module) |
| WebSocket/real-time no Group Hub | Stack atual é polling, não WebSocket |
| ML / fine-tuning para labels | n8n já usa GPT para classificação |
| Paginação na FileView WA | Últimos 20 suficiente para MVP |
| Label de mensagens históricas (antes de I-1) | Só novas msgs recebem label |

---

## Resumo de Artefatos Novos

### Endpoints Novos (4)
| Método | Path | Feature |
|--------|------|---------|
| GET | `/api/wa/labels/summary?mentee_id={id}` | I-1 |
| GET | `/api/mentees/triage` | I-2 |
| GET | `/api/wa/group-hub?mentee_id={id}` | I-3 |
| GET | `/api/wa/media?mentee_id={id}` | I-5 |

### Endpoints Modificados (1)
| Método | Path | Mudança |
|--------|------|---------|
| POST | `/api/copilot` | Aceita `mentee_id` opcional para contexto enriquecido |

### Migrations (1)
| Tabela | Mudança |
|--------|---------|
| `wa_message_queue` | ADD COLUMN `msg_label` VARCHAR(32), `msg_label_confidence` FLOAT |

### Componentes Alpine.js Novos
| Função | Feature |
|--------|---------|
| `waMsgLabelBadge(label)` | I-1 |
| `waLabelSummary(menteeId)` | I-1 |
| `loadMenteesTriage()` | I-2 |
| `waTriageBadge(score)` | I-2 |
| `openGroupHub(menteeId)` + `closeGroupHub()` | I-3 |
| Drawer "Group Hub" (HTML) | I-3 |
| `openCopilot(menteeId?)` — modificação | I-4 |
| `askCopilot()` — modificação | I-4 |
| `loadMenteeFiles(menteeId)` | I-5 |
| Tab "Arquivos" no Notes Drawer (HTML) | I-5 |
