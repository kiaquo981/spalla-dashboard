-- ============================================================
-- LF-FASE1: Event Store passivo (entity_events)
-- Story: LF-1.1 (table) + LF-1.6 (indexes + RLS)
--
-- Adiciona a tabela central de eventos do Spalla. Append-only.
-- Captura passivamente eventos de todas as entidades-chave.
--
-- Zero breaking change: nenhuma alteração em tabelas existentes.
-- ============================================================

-- Garantir extensions necessárias
CREATE EXTENSION IF NOT EXISTS "pgcrypto"; -- pra gen_random_uuid

-- ============================================================
-- TABELA: entity_events
-- ============================================================
CREATE TABLE IF NOT EXISTS entity_events (
  -- Identificação
  id BIGSERIAL PRIMARY KEY,
  event_id UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

  -- O que aconteceu
  aggregate_type TEXT NOT NULL,
  aggregate_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  event_version INT NOT NULL DEFAULT 1,

  -- Dados
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

  -- Quando
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Outbox pattern
  published_at TIMESTAMPTZ,

  -- Saga tracking
  correlation_id UUID,
  causation_id UUID,

  -- Validação aggregate_type whitelist (semi-aberto - permite expansão controlada)
  CONSTRAINT entity_events_aggregate_type_check CHECK (
    aggregate_type IN (
      'Task',
      'TaskSubtask',
      'TaskComment',
      'Mentorado',
      'MentoradoNote',
      'MentoradoMarco',
      'DossieProducao',
      'DossieDocumento',
      'DossieAjuste',
      'DossieEvento',
      'PlanoAcao',
      'PlanoAcaoFase',
      'PlanoAcaoItem',
      'OnboardingTrilha',
      'OnboardingEtapa',
      'OnboardingTarefa',
      'Call',
      'CallAnalise',
      'CallInsight',
      'WhatsAppMessage',
      'WhatsAppTopic',
      'WhatsAppQueue',
      'Descarrego',
      'Contexto',
      'Reminder',
      'FeedbackInbox',
      'Sprint',
      'Space',
      'List',
      'Automation',
      'StorageFile',
      'FinancialLog',
      'System'
    )
  )
);

-- Comentários explicativos
COMMENT ON TABLE entity_events IS
  'Central event store for Operon/Spalla. Append-only. Captures all entity lifecycle events for journey log, audit, process mining, and saga tracking.';
COMMENT ON COLUMN entity_events.event_id IS
  'Unique event UUID (idempotency key). Different from auto-increment id.';
COMMENT ON COLUMN entity_events.aggregate_type IS
  'PascalCase type name of the aggregate (Task, Mentorado, Dossie, etc).';
COMMENT ON COLUMN entity_events.aggregate_id IS
  'String representation of the entity primary key (UUID or BIGINT as text).';
COMMENT ON COLUMN entity_events.event_type IS
  'Event name in past tense (TaskCreated, TaskStatusChanged, etc).';
COMMENT ON COLUMN entity_events.event_version IS
  'Schema version of the payload. Allows event schema evolution via upcasting.';
COMMENT ON COLUMN entity_events.payload IS
  'Event-specific data. For status changes: {old: {...}, new: {...}}.';
COMMENT ON COLUMN entity_events.metadata IS
  'Context: {actor, source, table, ip, user_agent, ...}.';
COMMENT ON COLUMN entity_events.occurred_at IS
  'When the event happened in domain time (vs recorded_at = system time).';
COMMENT ON COLUMN entity_events.recorded_at IS
  'When the event was inserted into entity_events.';
COMMENT ON COLUMN entity_events.published_at IS
  'NULL = not yet published to integration bus. Filled by outbox poller.';
COMMENT ON COLUMN entity_events.correlation_id IS
  'Groups events from the same saga or operational context.';
COMMENT ON COLUMN entity_events.causation_id IS
  'event_id of the event that caused this one. Enables causal chain tracing.';

-- ============================================================
-- ÍNDICES (críticos pra performance)
-- ============================================================

-- Timeline de uma entidade específica (query mais comum)
CREATE INDEX IF NOT EXISTS idx_entity_events_aggregate
  ON entity_events (aggregate_type, aggregate_id, occurred_at DESC);

-- Eventos por tipo (analytics, process mining)
CREATE INDEX IF NOT EXISTS idx_entity_events_type
  ON entity_events (event_type, occurred_at DESC);

-- Saga tracking (eventos correlacionados)
CREATE INDEX IF NOT EXISTS idx_entity_events_correlation
  ON entity_events (correlation_id, occurred_at)
  WHERE correlation_id IS NOT NULL;

-- Outbox pollers (eventos não publicados)
CREATE INDEX IF NOT EXISTS idx_entity_events_unpublished
  ON entity_events (recorded_at)
  WHERE published_at IS NULL;

-- Causation chain (debugging)
CREATE INDEX IF NOT EXISTS idx_entity_events_causation
  ON entity_events (causation_id)
  WHERE causation_id IS NOT NULL;

-- Recent events (admin dashboard)
CREATE INDEX IF NOT EXISTS idx_entity_events_recent
  ON entity_events (occurred_at DESC);

-- ============================================================
-- RLS POLICIES
-- ============================================================
ALTER TABLE entity_events ENABLE ROW LEVEL SECURITY;

-- SELECT: authenticated pode ler tudo (audit transparente pro time)
CREATE POLICY "entity_events_select_authenticated"
  ON entity_events FOR SELECT
  TO authenticated
  USING (true);

-- INSERT: authenticated + service_role podem inserir (triggers + app code)
CREATE POLICY "entity_events_insert_authenticated"
  ON entity_events FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- UPDATE: SOMENTE service_role pode (pra outbox publishers updaterem published_at)
CREATE POLICY "entity_events_update_service"
  ON entity_events FOR UPDATE
  TO service_role
  USING (true);

-- DELETE: NINGUÉM pode deletar (event store é imutável)
-- Sem policy de DELETE = ninguém deleta

-- ============================================================
-- GRANT explícito
-- ============================================================
GRANT SELECT ON entity_events TO authenticated;
GRANT INSERT ON entity_events TO authenticated;
GRANT SELECT ON entity_events TO anon;  -- read-only pro frontend
GRANT ALL ON entity_events TO service_role;
GRANT USAGE, SELECT ON SEQUENCE entity_events_id_seq TO authenticated, service_role;
