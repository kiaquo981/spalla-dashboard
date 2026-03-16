# Spalla Dashboard V2 — Especificacao de Views ("God View")

**Data:** 2026-02-17 (atualizado)
**SQL:** `god_views_v2.sql` (1206 lines, 8 indexes, 9 views, 2 functions) + `03_god_tasks_schema.sql` (tarefas bidirecionais)
**Supabase:** knusqfbvhsqworzyhvip (CASE Principal)
**Frontend:** v28 — 37 mentorados ativos, integracao bidirecional

---

## Mapeamento View -> Componente Frontend

| View/Function | Componente Frontend | Descricao |
|---|---|---|
| `vw_god_overview` | Pagina principal (lista de cards) | ~45 colunas por mentorado, ordenado por fase |
| `fn_god_mentorado_deep(id)` | Pagina de detalhe do mentorado | JSON completo com profile, phase, financial, context_ia, calls, interactions, tasks, blockers, wins, directions, milestones |
| `vw_god_tarefas` | Secao "Plano de Acao" + pagina global de tarefas | Consolida 6 fontes de tarefas numa vista unica |
| `vw_god_timeline` | Feed de atividade no detalhe | UNION ALL de calls, WhatsApp, milestones, direcionamentos, planos, conselhos |
| `vw_god_cohort` | Dashboard principal (KPIs + heatmap por fase) | Agregacoes por fase + metricas globais |
| `vw_god_calls` | Timeline de Calls | Merge calls_mentoria + analises_call |
| `vw_god_contexto_ia` | Card "Contexto Inteligente" | Ultimo output de cada agente IA |
| `vw_god_pendencias` | Alertas + lista de pendencias | Msgs pendentes de resposta com prioridade calculada |
| `vw_god_direcionamentos` | Secao "Direcionamentos Estrategicos" | 3 fontes consolidadas |
| `vw_god_vendas` | Secao de vendas | Pipeline financeiro + vendas de calls |
| `fn_god_alerts()` | Painel de alertas (topo do dashboard) | Todos os alertas ativos ordenados por severidade |

---

## 1. `vw_god_overview` — Lista de Mentorados

**Uso Supabase:** `supabase.from('vw_god_overview').select('*')`

### Colunas por Grupo

#### Perfil
| Coluna | Tipo | Descricao |
|---|---|---|
| id | integer | ID do mentorado |
| nome | text | Nome completo |
| instagram | text | @ do Instagram |
| cidade | text | Cidade |
| estado | text | UF |
| cohort | text | N1, N2, tese |
| data_inicio | timestamptz | Data de entrada no programa |
| tempo_programa_semanas | integer | Semanas desde o inicio |

#### Fase
| Coluna | Tipo | Descricao |
|---|---|---|
| fase_jornada | text | onboarding/concepcao/validacao/otimizacao/escala |
| sub_etapa | text | Sub-etapa dentro da fase |
| marco_atual | text | Ultimo marco (M0-M5) |
| marcos_atingidos | text[] | Array de marcos ja atingidos |
| fase_health | text | on_track/atrasado/critico |

#### Risco
| Coluna | Tipo | Descricao |
|---|---|---|
| risco_churn | text | baixo/medio/alto/critico |
| sinais_risco | jsonb | Array de travas identificadas |
| engagement_score | integer | 0-100, score de engajamento |
| implementation_score | integer | 0-100, score de implementacao |

#### Financeiro
| Coluna | Tipo | Descricao |
|---|---|---|
| faturamento_atual | decimal | Faturamento atual |
| meta_faturamento | decimal | Meta definida |
| qtd_vendas_total | integer | Total de vendas |
| faturamento_mentoria | numeric | Faturamento gerado na mentoria |
| ticket_produto | decimal | Ticket do produto |

#### Produto
| Coluna | Tipo | Descricao |
|---|---|---|
| tem_produto | boolean | Tem produto definido? |
| produto_nome | text | Nicho do mentorado |
| produto_detectado | text | Produto detectado nas calls |
| ja_vendeu | boolean | Ja realizou vendas? |

#### Entregas
| Coluna | Tipo | Descricao |
|---|---|---|
| dossie_entregue | boolean | Dossie estrategico entregue? |
| call_estrategia_realizada | boolean | Call de estrategia feita? |
| call_onboarding_realizada | boolean | Call de onboarding feita? |

#### WhatsApp
| Coluna | Tipo | Descricao |
|---|---|---|
| whatsapp_total | integer | Total de mensagens |
| whatsapp_7d | integer | Mensagens ultimos 7 dias |
| whatsapp_30d | integer | Mensagens ultimos 30 dias |
| horas_sem_resposta_equipe | numeric | Horas da msg mais antiga sem resposta |
| msgs_pendentes_resposta | integer | Qty de msgs aguardando resposta |

#### Calls
| Coluna | Tipo | Descricao |
|---|---|---|
| total_calls | integer | Total de calls no Orquestrador |
| ultima_call_data | timestamptz | Data da ultima call |
| dias_desde_call | integer | Dias desde a ultima call |
| ultimo_tipo_call | text | Tipo da ultima call |

#### IA
| Coluna | Tipo | Descricao |
|---|---|---|
| total_extracoes | integer | Total de extracoes IA |
| total_docs_plano | integer | Total de planos de acao gerados |
| ultimo_foco_principal | text | Foco do ultimo plano |

#### Tarefas
| Coluna | Tipo | Descricao |
|---|---|---|
| tarefas_pendentes | integer | Tarefas pendentes (acordadas + equipe) |
| tarefas_atrasadas | integer | Tarefas com prazo vencido |

#### Grupo
| Coluna | Tipo | Descricao |
|---|---|---|
| participacoes_conselho | integer | Participacoes em conselhos/QAs |
| total_analises | integer | Total de analises de call |

---

## 2. `fn_god_mentorado_deep(id)` — Detalhe Completo

**Uso Supabase:** `supabase.rpc('fn_god_mentorado_deep', { p_id: 13 })`

### Estrutura do JSON retornado

```json
{
  "profile": {
    "id": 13,
    "nome": "Livia Lyra",
    "instagram": "@livialyra",
    "cidade": "...",
    "estado": "...",
    "email": "...",
    "telefone": "...",
    "cohort": "N1",
    "nicho": "...",
    "data_inicio": "...",
    "perfil_negocio": "...",
    "frequencia_call": "mensal",
    "proxima_call": null
  },
  "phase": {
    "fase_jornada": "escala",
    "sub_etapa": "...",
    "marco_atual": "M5",
    "risco_churn": "baixo",
    "engagement_score": 85,
    "implementation_score": 90,
    "marcos_atingidos": [...],
    "health": "on_track",
    "historico_fases": [...]
  },
  "financial": {
    "faturamento_atual": 180000,
    "meta_faturamento": 200000,
    "faturamento_mentoria": 50000,
    "qtd_vendas_total": 15,
    "ticket_produto": 6000,
    "ja_vendeu": true,
    "tem_produto": true,
    "produtos_ofertados": [...]
  },
  "context_ia": {
    "cenario_atual": "...",
    "gargalos": [...],
    "ativos": [...],
    "estrategias_atuais": {...},
    "prazos_proximos": {...},
    "ultimo_plano_titulo": "...",
    "ultimo_foco": "...",
    "completude_plano": 85
  },
  "last_calls": [
    {
      "data_call": "2026-02-14",
      "tipo": "acompanhamento",
      "resumo": "...",
      "decisoes_tomadas": [...]
    }
  ],
  "last_interactions": [
    {
      "conteudo": "...",
      "sender": "Livia",
      "tipo": "text",
      "created_at": "..."
    }
  ],
  "pending_tasks": [...],
  "blockers": [...],
  "wins": [...],
  "directions": [...],
  "milestones": [...]
}
```

---

## 3. `vw_god_tarefas` — Tarefas Unificadas

**Uso Supabase:** `supabase.from('vw_god_tarefas').select('*').eq('mentorado_id', 13)`

| Coluna | Tipo | Descricao |
|---|---|---|
| mentorado_id | integer | ID do mentorado |
| mentorado_nome | text | Nome |
| tarefa | text | Descricao da tarefa |
| responsavel | text | mentorado/equipe/queila/nome |
| prioridade | text | alta/media/baixa/critico/urgente/normal |
| prazo | date | Data limite |
| status | text | pendente/em_andamento/concluida/bloqueada/cancelada |
| fonte | text | tarefas_acordadas/tarefas_equipe/extracao_mentorado/extracao_mentora/analise_call/plano_acao |
| data_criacao | timestamptz | Quando foi criada |
| call_id_origem | bigint | ID da call de origem (quando aplicavel) |

**6 fontes consolidadas:**
1. `tarefas_acordadas` — Tarefas manuais
2. `tarefas_equipe` — Tarefas delegadas a equipe
3. `tarefas_extraidas` (MENTORADO) — Extraidas por IA das calls
4. `tarefas_extraidas` (MENTORA) — Tarefas da Queila extraidas por IA
5. `analises_call.proximos_passos` — Proximos passos de cada call
6. `documentos_plano_acao.secao_proximos_passos` — Proximos passos dos planos

---

## 3b. `god_tasks` + `vw_god_tasks_full` — Sistema de Tarefas Bidirecional (NOVO)

**Uso Supabase (LEITURA):** `supabase.from('vw_god_tasks_full').select('*').order('created_at', { ascending: false }).limit(200)`
**Uso Supabase (ESCRITA):** `supabase.from('god_tasks').upsert(taskData, { onConflict: 'id' })`

### Diferenca entre vw_god_tarefas e god_tasks

| | `vw_god_tarefas` | `god_tasks` + `vw_god_tasks_full` |
|---|---|---|
| Direcao | READ-ONLY (view SQL) | READ + WRITE (tabela + view) |
| Fonte | 6 fontes consolidadas | Migrada das 4 fontes + criacao manual |
| Features | Plana (colunas simples) | Subtasks, checklist, comments, handoffs |
| Organizacao | Por mentorado | Spaces > Lists (ClickUp-style) |

### Tabelas

**`god_tasks`** — Tabela principal
| Coluna | Tipo | Descricao |
|---|---|---|
| id | uuid (PK) | UUID gerado no frontend |
| titulo | text | Titulo da tarefa |
| descricao | text | Descricao detalhada |
| status | text | pendente/em_andamento/concluida/cancelada |
| prioridade | text | urgente/alta/media/baixa |
| responsavel | text | mentorado/Queila/Heitor/Lara/Hugo |
| mentorado_id | bigint (FK) | Referencia mentorados.id |
| mentorado_nome | text | Nome (desnormalizado) |
| data_inicio | date | Inicio |
| data_fim | date | Prazo |
| space_id | text | space_mentorados/space_equipe/space_queila |
| list_id | text | list_onboarding/list_acompanhamento/etc |
| parent_task_id | uuid (FK self) | Sub-tarefa hierarquica |
| tags | text[] | Array de tags |
| fonte | text | manual/tarefas_acordadas/proximos_passos/plano_acao/equipe |
| doc_link | text | Link para doc relacionado |

**Tabelas auxiliares:** `god_task_subtasks`, `god_task_checklist`, `god_task_comments`, `god_task_handoffs`

**`vw_god_tasks_full`** — View agregada (READ-ONLY)
Retorna todas colunas de god_tasks + 4 colunas JSON:
- `subtasks` — jsonb[] de {texto, done, sort_order}
- `checklist` — jsonb[] de {texto, done, sort_order}
- `comments` — jsonb[] de {id, author, texto, created_at}
- `handoffs` — jsonb[] de {id, from_person, to_person, note, created_at}

### Organizacao ClickUp-style (3 Spaces)

```
space_mentorados (Mentorados)
├── list_onboarding
├── list_acompanhamento
├── list_estrategia
└── list_fechamento

space_equipe (Equipe CASE)
├── list_rotina
├── list_conteudo
└── list_vendas

space_queila (Direcionamentos Queila)
├── list_direcionamentos
└── list_retorativas
```

---

## 4. `vw_god_timeline` — Feed de Atividade

**Uso Supabase:** `supabase.from('vw_god_timeline').select('*').eq('mentorado_id', 13).order('data', { ascending: false }).limit(50)`

| Coluna | Tipo | Descricao |
|---|---|---|
| mentorado_id | integer | ID do mentorado |
| evento_tipo | text | call/whatsapp/milestone/direcionamento/plano_acao/conselho |
| data | timestamptz | Data do evento |
| titulo | text | Titulo resumido do evento |
| descricao | text | Descricao truncada (200 chars) |
| metadata_json | jsonb | Dados extras (call_id, tipo, duracao, etc.) |

---

## 5. `vw_god_cohort` — KPIs por Fase

**Uso Supabase:** `supabase.from('vw_god_cohort').select('*')`

| Coluna | Tipo | Descricao |
|---|---|---|
| fase | text | onboarding/concepcao/validacao/otimizacao/escala |
| total_mentorados | integer | Mentorados nesta fase |
| criticos | integer | Risco critico |
| altos | integer | Risco alto |
| medios | integer | Risco medio |
| baixos | integer | Risco baixo |
| avg_engagement | numeric | Media engajamento da fase |
| avg_implementation | numeric | Media implementacao da fase |
| total_active | integer | Total ativo (global) |
| total_calls_30d | integer | Calls ultimos 30 dias (global) |
| pending_tasks_global | integer | Tarefas pendentes (global) |
| pending_responses_global | integer | Msgs pendentes (global) |

---

## 6. `fn_god_alerts()` — Alertas Ativos

**Uso Supabase:** `supabase.rpc('fn_god_alerts')`

| Coluna | Tipo | Descricao |
|---|---|---|
| alerta_tipo | text | sem_resposta/sem_call/tarefas_atrasadas/risco_churn/sem_whatsapp |
| severidade | text | critico/alto/medio/baixo |
| mentorado_id | integer | ID do mentorado |
| mentorado_nome | text | Nome |
| descricao | text | Descricao legivel do alerta |
| valor_referencia | text | Valor numerico de referencia |
| data_referencia | timestamptz | Data de referencia |

**5 tipos de alertas:**
1. **sem_resposta** — Msgs pendentes >12h
2. **sem_call** — Sem call >21 dias
3. **tarefas_atrasadas** — >2 tarefas vencidas
4. **risco_churn** — Risco critico ou alto
5. **sem_whatsapp** — Sem atividade >7 dias

---

## Notas Tecnicas

### Type Casting
O SQL usa `::text` para JOINs entre tabelas com tipos diferentes de `mentorado_id`:
- `interacoes_mentoria.mentorado_id` = VARCHAR(255)
- `extracoes_agente.mentorado_id` = UUID (sem FK)
- `documentos_plano_acao.mentorado_id` = UUID (sem FK)

Se os tipos ja foram unificados no DB, remova os `::text` casts para melhor performance.

### Coluna `respondida` vs `respondido`
O SQL usa `respondida` (nome do CREATE TABLE original). Se o DB usa `respondido`, faca find-and-replace.

### Performance
- 8 indexes criados com prefixo `idx_god_*`
- Views usam LATERAL subqueries para evitar GROUP BY massivos
- `vw_god_overview` usa CTEs para isolar agregacoes
- `fn_god_mentorado_deep` e STABLE (cacheable pelo Supabase)

### Ordem de Execucao
1. Indexes (Step 1)
2. Views auxiliares: contexto_ia, pendencias, calls, direcionamentos, vendas
3. Views principais: tarefas, overview, timeline, cohort
4. Functions: fn_god_mentorado_deep, fn_god_alerts

---

## Nota: Variavel do Cliente Supabase

No frontend (app.js), o client Supabase e chamado `sb` (nao `supabase`) para evitar conflito com a variavel global do CDN:

```javascript
// app.js
let sb = null; // client Supabase
sb = window.supabase.createClient(CONFIG.SUPABASE_URL, CONFIG.SUPABASE_ANON_KEY);

// Leitura
const { data } = await sb.from('vw_god_overview').select('*');
// Escrita
await sb.from('god_tasks').upsert(taskData, { onConflict: 'id' });
```

**Fallback:** Se Supabase nao carregar, o frontend usa dados estaticos de `data.js` + localStorage.

---

## Validacao Pos-Deploy

```sql
SELECT COUNT(*) FROM vw_god_overview WHERE nome IS NOT NULL;  -- 37
SELECT COUNT(*) FROM vw_god_tarefas;                          -- > 100
SELECT COUNT(*) FROM vw_god_calls;                            -- > 200
SELECT COUNT(*) FROM vw_god_tasks_full;                       -- > 800
SELECT * FROM vw_god_cohort;                                  -- 5 rows
SELECT fn_god_mentorado_deep(13);                             -- Livia Lyra
SELECT * FROM fn_god_alerts() LIMIT 20;                       -- alerts
```
