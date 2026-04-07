---
title: "EPIC LF-FASE1: Event Store passivo (entity_events)"
type: epic
status: pending
priority: P0
parent_epic: EPIC-LF-MASTER.md
depends_on: EPIC-LF-FASE0-vocabulary.md
created: 2026-04-07
duration: 1 week
breaking_change: false
---

# EPIC LF-FASE1: Event Store passivo (entity_events)

## Visão

Criar a tabela central `entity_events` que vai receber **TODOS** os eventos de TODAS as entidades-chave do Spalla. Esta fase é **puramente aditiva** — captura passivamente o que já acontece via triggers Postgres, sem alterar nenhum código existente. Ao final, temos visibilidade unificada da jornada de qualquer entidade.

## Por que importa

1. **Sem journey log unificado, não dá pra fazer process mining** (descobrir cycle time, gargalos, retrabalho)
2. **Sem correlation_id, sagas são invisíveis** (impossível rastrear "este descarrego virou esta task que virou este dossiê")
3. **Sem audit centralizado, debugging vira arqueologia** (tem que olhar 6 tabelas diferentes pra entender o que aconteceu)
4. **É a fundação da Fase 2 (FSMs)** — toda transição de estado vai gerar evento via FSM, mas a infra de storage tem que existir antes

## Filosofia

**Captura primeiro, enforce depois.** Esta fase não tem opinião sobre o que é estado válido. Ela só registra o que aconteceu. A Fase 2 vai usar esses eventos pra refinar as FSMs com base em dados reais.

**Nunca bloquear operação.** Trigger function tem `EXCEPTION WHEN OTHERS` — se inserir em entity_events falhar por qualquer motivo, log de warning mas a operação principal continua.

## Stories

### Story LF-1.1 — Migration: tabela entity_events

**Como:** event store
**Eu quero:** ser uma tabela append-only com schema rico
**Pra que:** receber eventos de todos os subsistemas em formato unificado

**Schema proposto:**
```sql
CREATE TABLE entity_events (
  id BIGSERIAL PRIMARY KEY,
  event_id UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  -- What
  aggregate_type TEXT NOT NULL,    -- 'Task', 'Mentorado', 'Dossie', etc
  aggregate_id TEXT NOT NULL,      -- entity ID as text (UUID or bigint)
  event_type TEXT NOT NULL,        -- 'TaskCreated', 'TaskStatusChanged', etc
  event_version INT NOT NULL DEFAULT 1,
  -- Data
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  -- When
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  -- Saga tracking
  correlation_id UUID,
  causation_id UUID,
  -- Outbox
  published_at TIMESTAMPTZ
);
```

**Índices críticos:**
- (aggregate_type, aggregate_id, occurred_at) — timeline de uma entidade
- (event_type, occurred_at) — eventos de um tipo
- (correlation_id) WHERE NOT NULL — saga tracking
- (recorded_at) WHERE published_at IS NULL — outbox poller

**AC:**
- [ ] Migration cria tabela com schema acima
- [ ] Todos índices criados
- [ ] RLS: SELECT pra authenticated, INSERT pra service_role + authenticated
- [ ] CHECK constraint: aggregate_type IN (lista whitelist)
- [ ] Comentários SQL explicando cada coluna

---

### Story LF-1.2 — Trigger Function: emit_entity_event

**Como:** sistema
**Eu quero:** uma função genérica que captura mudança de qualquer tabela como evento
**Pra que:** evitar duplicar lógica de captura por tabela

**Comportamento:**
- Recebe `aggregate_type` como argumento do trigger
- Detecta TG_OP (INSERT/UPDATE/DELETE)
- Constrói event_type derivado (`{Type}Created`, `{Type}Updated`, `{Type}Deleted`)
- Detecta mudança de status (se houver coluna 'status') e emite evento adicional `{Type}StatusChanged`
- Detecta mudança de fase (se houver coluna 'fase' ou 'fase_jornada') e emite `{Type}FaseChanged`
- Payload inclui old + new (em JSONB)
- Metadata inclui: source='trigger', table=TG_TABLE_NAME
- **Nunca bloqueia**: EXCEPTION WHEN OTHERS captura erros e só faz RAISE WARNING

**AC:**
- [ ] Função criada
- [ ] Detecta tipo de operação corretamente
- [ ] Emite eventos derivados (StatusChanged, FaseChanged)
- [ ] Erro em entity_events NÃO impede operação principal
- [ ] Testes manuais via INSERT/UPDATE/DELETE em tabela mock

---

### Story LF-1.3 — Triggers nas Tabelas-Chave

**Como:** sistema
**Eu quero:** triggers ativos em god_tasks, ds_producoes, ds_documentos, pa_planos, pa_acoes, wa_topics, mentorado_context
**Pra que:** capturar passivamente todos os eventos do dia-a-dia

**Tabelas alvo (Fase 1):**
1. `god_tasks` → aggregate_type='Task'
2. `ds_producoes` → 'DossieProducao'
3. `ds_documentos` → 'DossieDocumento'
4. `ds_ajustes` → 'DossieAjuste'
5. `pa_planos` → 'PlanoAcao'
6. `pa_fases` → 'PlanoAcaoFase'
7. `pa_acoes` → 'PlanoAcaoItem'
8. `wa_topics` → 'WhatsAppTopic'
9. `mentorado_context` → 'Contexto' (legado, será substituído por Descarrego na Fase 3)
10. `god_reminders` → 'Reminder'
11. `god_feedback` → 'FeedbackInbox'
12. `ob_trilhas` → 'OnboardingTrilha'

**Não cobertas em Fase 1** (cobertas em Fase 2 ou via projetor):
- `mentorados` (upstream schema, não temos write access direto)
- `wa_messages` (volume muito alto, vamos avaliar custo)
- `wa_message_queue` (já tem state machine própria, pode ficar fora por agora)

**AC:**
- [ ] 12 triggers AFTER INSERT OR UPDATE OR DELETE criados
- [ ] Cada trigger usa `emit_entity_event(aggregate_type)`
- [ ] Teste manual: criar god_task → ver evento aparecer em entity_events
- [ ] Teste de erro: forçar erro em entity_events → operação original sucesso

---

### Story LF-1.4 — View: vw_entity_timeline

**Como:** dev/admin
**Eu quero:** uma view que mostra timeline cronológica de qualquer entidade
**Pra que:** debug + audit + journey viewer futuro

**Schema:**
```sql
CREATE VIEW vw_entity_timeline AS
SELECT
  ee.event_id,
  ee.aggregate_type,
  ee.aggregate_id,
  ee.event_type,
  ee.payload->'old'->>'status' AS old_status,
  ee.payload->'new'->>'status' AS new_status,
  ee.payload->'old'->>'fase_jornada' AS old_fase,
  ee.payload->'new'->>'fase_jornada' AS new_fase,
  ee.metadata->>'source' AS source,
  ee.metadata->>'table' AS source_table,
  ee.metadata->>'actor' AS actor,
  ee.correlation_id,
  ee.causation_id,
  ee.occurred_at
FROM entity_events ee
ORDER BY ee.occurred_at DESC;
```

**AC:**
- [ ] View criada
- [ ] Query `SELECT * FROM vw_entity_timeline WHERE aggregate_type='Task' AND aggregate_id='X'` retorna timeline completa
- [ ] Performance OK até 100k eventos (índice apropriado)

---

### Story LF-1.5 — View: vw_correlation_timeline (sagas)

**Como:** debugger
**Eu quero:** view que mostra todos os eventos de uma saga (mesmo correlation_id)
**Pra que:** rastrear cadeias inteiras

**Schema:**
```sql
CREATE VIEW vw_correlation_timeline AS
SELECT
  correlation_id,
  array_agg(json_build_object(
    'event_id', event_id,
    'aggregate_type', aggregate_type,
    'aggregate_id', aggregate_id,
    'event_type', event_type,
    'occurred_at', occurred_at,
    'causation_id', causation_id
  ) ORDER BY occurred_at) AS events,
  count(*) AS event_count,
  min(occurred_at) AS started_at,
  max(occurred_at) AS last_event_at
FROM entity_events
WHERE correlation_id IS NOT NULL
GROUP BY correlation_id;
```

**AC:**
- [ ] View criada
- [ ] Útil quando Fase 3 começa a popular correlation_id

---

### Story LF-1.6 — Migration: índices e RLS

**AC:**
- [ ] Todos índices da Story 1.1 aplicados
- [ ] RLS policies configuradas pra service_role e authenticated
- [ ] Test: anon não consegue SELECT (segurança)

---

### Story LF-1.7 — Smoke Test em Produção

**Como:** dev
**Eu quero:** validar que após deploy em produção os eventos começam a fluir
**Pra que:** confiança antes de avançar pra Fase 2

**Procedimento:**
1. Deploy migration
2. Criar uma god_task pelo frontend
3. Verificar `SELECT * FROM entity_events WHERE aggregate_type='Task' ORDER BY id DESC LIMIT 5`
4. Mudar status da task
5. Verificar evento `TaskStatusChanged` em entity_events
6. Após 1h, contar eventos por tipo: `SELECT event_type, count(*) FROM entity_events GROUP BY 1`

**AC:**
- [ ] Eventos aparecem no entity_events em produção
- [ ] Pelo menos 50 eventos no primeiro dia
- [ ] Zero erro 500 em endpoints existentes (validar via Railway logs)

---

## DoD do Epic LF-FASE1

- [ ] Story LF-1.1 (migration entity_events) ✓
- [ ] Story LF-1.2 (trigger function) ✓
- [ ] Story LF-1.3 (triggers em 12 tabelas) ✓
- [ ] Story LF-1.4 (vw_entity_timeline) ✓
- [ ] Story LF-1.5 (vw_correlation_timeline) ✓
- [ ] Story LF-1.6 (RLS + índices) ✓
- [ ] Story LF-1.7 (smoke test) ✓
- [ ] Migration aplicada em produção
- [ ] ≥1k eventos capturados em 7 dias
- [ ] Zero degradação de performance perceptível
- [ ] PR mergeado em develop
