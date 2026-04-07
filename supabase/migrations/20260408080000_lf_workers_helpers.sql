-- ============================================================
-- LF-MVP Story 1: Workers Helpers
--
-- 1. fn_rrule_next_occurrence(rrule, base) — calcula próxima execução
--    a partir de um RRULE simplificado (FREQ=HOURLY|DAILY|WEEKLY|MONTHLY,
--    INTERVAL=N). RFC 5545 subset suficiente pra 95% dos casos.
--
-- 2. fn_materialize_recurring_due() — varre templates due,
--    cria instâncias filhas, avança proxima_execucao. Idempotente.
--
-- 3. task_trigger_rules garantia: ultimo_evento_id como cursor
--    (já existe da migração anterior — só validamos via NOT EXISTS).
-- ============================================================

CREATE OR REPLACE FUNCTION fn_rrule_next_occurrence(p_rrule TEXT, p_base TIMESTAMPTZ)
RETURNS TIMESTAMPTZ
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  v_freq TEXT;
  v_interval INT := 1;
  v_match TEXT[];
BEGIN
  IF p_rrule IS NULL OR p_rrule = '' THEN
    RETURN NULL;
  END IF;

  -- FREQ
  v_match := regexp_matches(p_rrule, 'FREQ=([A-Z]+)', 'i');
  IF array_length(v_match, 1) IS NULL THEN
    RETURN NULL;
  END IF;
  v_freq := upper(v_match[1]);

  -- INTERVAL (default 1)
  v_match := regexp_matches(p_rrule, 'INTERVAL=(\d+)', 'i');
  IF array_length(v_match, 1) >= 1 THEN
    v_interval := v_match[1]::INT;
  END IF;

  RETURN CASE v_freq
    WHEN 'HOURLY'  THEN p_base + (v_interval || ' hours')::interval
    WHEN 'DAILY'   THEN p_base + (v_interval || ' days')::interval
    WHEN 'WEEKLY'  THEN p_base + (v_interval || ' weeks')::interval
    WHEN 'MONTHLY' THEN p_base + (v_interval || ' months')::interval
    WHEN 'YEARLY'  THEN p_base + (v_interval || ' years')::interval
    ELSE NULL
  END;
END;
$$;

COMMENT ON FUNCTION fn_rrule_next_occurrence(TEXT, TIMESTAMPTZ) IS
  'Calcula próxima execução a partir de RRULE simplificado (FREQ + INTERVAL). Subset do RFC 5545.';


-- ============================================================
-- fn_materialize_recurring_due
-- ============================================================
CREATE OR REPLACE FUNCTION fn_materialize_recurring_due()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_template RECORD;
  v_new_id UUID;
  v_count INT := 0;
  v_next TIMESTAMPTZ;
BEGIN
  FOR v_template IN
    SELECT *
      FROM god_tasks
     WHERE especie = 'recorrente_template'
       AND status NOT IN ('arquivada','cancelada','pausada')
       AND proxima_execucao IS NOT NULL
       AND proxima_execucao <= now()
       AND rrule IS NOT NULL
     LIMIT 100
  LOOP
    -- Cria a instância
    INSERT INTO god_tasks (
      titulo, descricao, status, prioridade,
      responsavel, acompanhante, mentorado_id, mentorado_nome,
      space_id, list_id, sprint_id, tipo, tags,
      data_inicio, data_fim,
      especie, parent_recurring_id, fonte
    )
    VALUES (
      v_template.titulo,
      v_template.descricao,
      'pendente',
      v_template.prioridade,
      v_template.responsavel,
      v_template.acompanhante,
      v_template.mentorado_id,
      v_template.mentorado_nome,
      v_template.space_id,
      v_template.list_id,
      v_template.sprint_id,
      v_template.tipo,
      v_template.tags,
      v_template.proxima_execucao,
      NULL,
      'recorrente_instancia',
      v_template.id,
      'recurring_scheduler'
    )
    RETURNING id INTO v_new_id;

    -- Avança proxima_execucao
    v_next := fn_rrule_next_occurrence(v_template.rrule, v_template.proxima_execucao);
    UPDATE god_tasks
       SET proxima_execucao = v_next,
           updated_at = now()
     WHERE id = v_template.id;

    v_count := v_count + 1;
  END LOOP;

  RETURN jsonb_build_object(
    'materialized', v_count,
    'ran_at', now()
  );
END;
$$;

COMMENT ON FUNCTION fn_materialize_recurring_due() IS
  'Worker SQL: varre templates recorrentes due, cria instâncias filhas, avança proxima_execucao via RRULE.';

GRANT EXECUTE ON FUNCTION fn_materialize_recurring_due() TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION fn_rrule_next_occurrence(TEXT, TIMESTAMPTZ) TO authenticated, service_role;


-- ============================================================
-- fn_apply_trigger_rules
-- Lê entity_events > cursor, aplica regras ativas, materializa tasks
-- ============================================================
CREATE OR REPLACE FUNCTION fn_apply_trigger_rules()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_rule RECORD;
  v_event RECORD;
  v_template JSONB;
  v_total_created INT := 0;
  v_max_event_id BIGINT;
BEGIN
  FOR v_rule IN
    SELECT *
      FROM task_trigger_rules
     WHERE ativa = true
  LOOP
    v_max_event_id := COALESCE(v_rule.ultimo_evento_id, 0);

    FOR v_event IN
      SELECT id, event_id, aggregate_type, aggregate_id, event_type, payload, correlation_id
        FROM entity_events
       WHERE id > COALESCE(v_rule.ultimo_evento_id, 0)
         AND aggregate_type = v_rule.when_aggregate_type
         AND event_type = v_rule.when_event_type
         AND payload @> COALESCE(v_rule.when_payload_filter, '{}'::jsonb)
       ORDER BY id ASC
       LIMIT 200
    LOOP
      v_template := v_rule.then_template;

      -- Materializa task com campos do template
      INSERT INTO god_tasks (
        titulo, descricao, status, prioridade,
        responsavel, mentorado_id, especie,
        trigger_rule_id, fonte
      )
      VALUES (
        COALESCE(v_template->>'titulo', 'Task disparada por ' || v_rule.nome),
        COALESCE(v_template->>'descricao', NULL),
        'pendente',
        COALESCE(v_template->>'prioridade', 'normal'),
        v_template->>'responsavel',
        NULLIF(v_template->>'mentorado_id', '')::BIGINT,
        'triggered_instancia',
        v_rule.id,
        'trigger_listener'
      );

      v_total_created := v_total_created + 1;
      v_max_event_id := v_event.id;
    END LOOP;

    -- Avança cursor
    UPDATE task_trigger_rules
       SET ultimo_evento_id = v_max_event_id,
           ultimo_disparo_em = CASE WHEN v_max_event_id > COALESCE(ultimo_evento_id, 0)
                                    THEN now() ELSE ultimo_disparo_em END,
           total_disparos = total_disparos + (v_max_event_id - COALESCE(ultimo_evento_id, 0))
     WHERE id = v_rule.id
       AND v_max_event_id > COALESCE(ultimo_evento_id, 0);
  END LOOP;

  RETURN jsonb_build_object(
    'tasks_created', v_total_created,
    'ran_at', now()
  );
END;
$$;

COMMENT ON FUNCTION fn_apply_trigger_rules() IS
  'Worker SQL: lê entity_events > cursor por regra ativa em task_trigger_rules, materializa tasks correspondentes.';

GRANT EXECUTE ON FUNCTION fn_apply_trigger_rules() TO authenticated, service_role;
