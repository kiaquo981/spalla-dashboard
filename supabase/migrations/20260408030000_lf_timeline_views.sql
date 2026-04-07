-- ============================================================
-- LF-FASE1: Timeline views
-- Stories: LF-1.4 (vw_entity_timeline) + LF-1.5 (vw_correlation_timeline)
-- ============================================================

-- ------------------------------------------------------------
-- vw_entity_timeline
-- Jornada de UMA entidade específica (filtra por aggregate_type + aggregate_id)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_entity_timeline AS
SELECT
  e.id,
  e.event_id,
  e.aggregate_type,
  e.aggregate_id,
  e.event_type,
  e.event_version,
  e.payload,
  e.metadata,
  e.metadata->>'actor'  AS actor,
  e.metadata->>'source' AS source,
  e.occurred_at,
  e.recorded_at,
  e.correlation_id,
  e.causation_id,
  -- delta humano (segundos desde o evento anterior do mesmo aggregate)
  EXTRACT(EPOCH FROM (
    e.occurred_at - LAG(e.occurred_at) OVER (
      PARTITION BY e.aggregate_type, e.aggregate_id
      ORDER BY e.occurred_at
    )
  ))::INT AS seconds_since_prev
FROM entity_events e
ORDER BY e.aggregate_type, e.aggregate_id, e.occurred_at;

COMMENT ON VIEW vw_entity_timeline IS
  'Per-entity event timeline. Filter: WHERE aggregate_type = X AND aggregate_id = Y.';

-- ------------------------------------------------------------
-- vw_correlation_timeline
-- Saga / processo: agrupa todos os eventos do mesmo correlation_id
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_correlation_timeline AS
SELECT
  e.correlation_id,
  e.id,
  e.event_id,
  e.aggregate_type,
  e.aggregate_id,
  e.event_type,
  e.payload,
  e.metadata->>'actor'  AS actor,
  e.metadata->>'source' AS source,
  e.causation_id,
  e.occurred_at,
  -- ordem dentro da saga
  ROW_NUMBER() OVER (
    PARTITION BY e.correlation_id ORDER BY e.occurred_at, e.id
  ) AS step_number,
  -- duração total da saga (do primeiro ao último evento)
  EXTRACT(EPOCH FROM (
    MAX(e.occurred_at) OVER (PARTITION BY e.correlation_id)
    - MIN(e.occurred_at) OVER (PARTITION BY e.correlation_id)
  ))::INT AS saga_total_seconds,
  COUNT(*) OVER (PARTITION BY e.correlation_id) AS saga_event_count
FROM entity_events e
WHERE e.correlation_id IS NOT NULL
ORDER BY e.correlation_id, e.occurred_at, e.id;

COMMENT ON VIEW vw_correlation_timeline IS
  'Saga / cross-entity flow. Groups events by correlation_id with step numbers and total duration.';

GRANT SELECT ON vw_entity_timeline       TO authenticated, anon, service_role;
GRANT SELECT ON vw_correlation_timeline  TO authenticated, anon, service_role;
