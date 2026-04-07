-- ============================================================
-- LF-FASE1: emit_entity_event() trigger function
-- Story: LF-1.2
--
-- Função genérica para capturar eventos de qualquer tabela.
-- Uso: CREATE TRIGGER trg_x AFTER INSERT OR UPDATE OR DELETE
--      ON x FOR EACH ROW EXECUTE FUNCTION emit_entity_event('AggregateType');
--
-- NUNCA bloqueia a operação pai. Erros viram RAISE WARNING.
-- ============================================================

CREATE OR REPLACE FUNCTION emit_entity_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_aggregate_type TEXT;
  v_aggregate_id   TEXT;
  v_event_type     TEXT;
  v_payload        JSONB;
  v_metadata       JSONB;
  v_old_jsonb      JSONB;
  v_new_jsonb      JSONB;
  v_actor          TEXT;
  v_old_status     TEXT;
  v_new_status     TEXT;
  v_old_fase       TEXT;
  v_new_fase       TEXT;
BEGIN
  -- Aggregate type vem do argumento do trigger
  v_aggregate_type := COALESCE(TG_ARGV[0], TG_TABLE_NAME);

  -- Tenta capturar actor do GUC (se app setou via SET LOCAL)
  BEGIN
    v_actor := current_setting('app.actor', true);
  EXCEPTION WHEN OTHERS THEN
    v_actor := NULL;
  END;
  IF v_actor IS NULL OR v_actor = '' THEN
    v_actor := current_user;
  END IF;

  -- Serializar OLD e NEW (quando existem)
  IF TG_OP = 'DELETE' THEN
    v_old_jsonb := to_jsonb(OLD);
    v_new_jsonb := NULL;
    v_aggregate_id := COALESCE((v_old_jsonb->>'id'), (v_old_jsonb->>'uuid'));
    v_event_type := v_aggregate_type || 'Deleted';
    v_payload := jsonb_build_object('old', v_old_jsonb);
  ELSIF TG_OP = 'INSERT' THEN
    v_new_jsonb := to_jsonb(NEW);
    v_old_jsonb := NULL;
    v_aggregate_id := COALESCE((v_new_jsonb->>'id'), (v_new_jsonb->>'uuid'));
    v_event_type := v_aggregate_type || 'Created';
    v_payload := jsonb_build_object('new', v_new_jsonb);
  ELSE -- UPDATE
    v_old_jsonb := to_jsonb(OLD);
    v_new_jsonb := to_jsonb(NEW);
    v_aggregate_id := COALESCE((v_new_jsonb->>'id'), (v_new_jsonb->>'uuid'));
    v_event_type := v_aggregate_type || 'Updated';
    v_payload := jsonb_build_object('old', v_old_jsonb, 'new', v_new_jsonb);
  END IF;

  v_metadata := jsonb_build_object(
    'source', 'trigger',
    'table', TG_TABLE_NAME,
    'schema', TG_TABLE_SCHEMA,
    'op', TG_OP,
    'actor', v_actor
  );

  -- Evento principal
  INSERT INTO entity_events (
    aggregate_type, aggregate_id, event_type, payload, metadata
  ) VALUES (
    v_aggregate_type,
    COALESCE(v_aggregate_id, 'unknown'),
    v_event_type,
    v_payload,
    v_metadata
  );

  -- Eventos derivados: status change
  IF TG_OP = 'UPDATE' THEN
    v_old_status := v_old_jsonb->>'status';
    v_new_status := v_new_jsonb->>'status';
    IF v_old_status IS DISTINCT FROM v_new_status
       AND v_new_status IS NOT NULL THEN
      INSERT INTO entity_events (
        aggregate_type, aggregate_id, event_type, payload, metadata
      ) VALUES (
        v_aggregate_type,
        COALESCE(v_aggregate_id, 'unknown'),
        v_aggregate_type || 'StatusChanged',
        jsonb_build_object('old_status', v_old_status, 'new_status', v_new_status),
        v_metadata
      );
    END IF;

    -- Fase change (mentorados)
    v_old_fase := v_old_jsonb->>'fase_jornada';
    v_new_fase := v_new_jsonb->>'fase_jornada';
    IF v_old_fase IS DISTINCT FROM v_new_fase
       AND v_new_fase IS NOT NULL THEN
      INSERT INTO entity_events (
        aggregate_type, aggregate_id, event_type, payload, metadata
      ) VALUES (
        v_aggregate_type,
        COALESCE(v_aggregate_id, 'unknown'),
        v_aggregate_type || 'FaseChanged',
        jsonb_build_object('old_fase', v_old_fase, 'new_fase', v_new_fase),
        v_metadata
      );
    END IF;
  END IF;

  -- Retorno padrão de trigger AFTER (ignorado, mas obrigatório)
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;

EXCEPTION WHEN OTHERS THEN
  -- NUNCA bloquear a operação pai
  RAISE WARNING 'emit_entity_event failed for % on %.%: %',
    TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME, SQLERRM;
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$;

COMMENT ON FUNCTION emit_entity_event() IS
  'Generic trigger function. Captures INSERT/UPDATE/DELETE on any table into entity_events. Pass aggregate type as TG_ARGV[0]. Never blocks parent op (errors → WARNING).';

GRANT EXECUTE ON FUNCTION emit_entity_event() TO authenticated, service_role;
