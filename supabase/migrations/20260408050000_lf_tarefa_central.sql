-- ============================================================
-- LF-FASE2.5: Tarefa como aggregate root central
-- Story: LF-2.10 (model refinement)
--
-- Adições aditivas em god_tasks:
--   - especie (one_time | quest | recorrente_template | recorrente_instancia
--              | triggered_template | triggered_instancia)
--   - depends_on UUID[]   (sequência: aguardando outras tasks)
--   - rrule TEXT          (RFC 5545 — só pra recorrente_template)
--   - parent_recurring_id UUID  (instância → template)
--   - trigger_rule_id UUID      (instância → regra)
--
-- Tabela nova:
--   - task_trigger_rules (regras declarativas que escutam entity_events)
--
-- View nova:
--   - vw_meu_trabalho (modo EU agregado, tela default do operador)
--
-- Zero breaking change: tudo nullable, defaults seguros.
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. god_tasks: colunas aditivas
-- ------------------------------------------------------------
ALTER TABLE god_tasks
  ADD COLUMN IF NOT EXISTS especie TEXT DEFAULT 'one_time',
  ADD COLUMN IF NOT EXISTS depends_on UUID[] DEFAULT ARRAY[]::UUID[],
  ADD COLUMN IF NOT EXISTS rrule TEXT,
  ADD COLUMN IF NOT EXISTS parent_recurring_id UUID,
  ADD COLUMN IF NOT EXISTS trigger_rule_id UUID,
  ADD COLUMN IF NOT EXISTS proxima_execucao TIMESTAMPTZ;

ALTER TABLE god_tasks DROP CONSTRAINT IF EXISTS god_tasks_especie_check;
ALTER TABLE god_tasks ADD CONSTRAINT god_tasks_especie_check
  CHECK (especie IN (
    'one_time',
    'quest',
    'recorrente_template',
    'recorrente_instancia',
    'triggered_template',
    'triggered_instancia'
  ));

COMMENT ON COLUMN god_tasks.especie IS
  'Discrimina o sabor da tarefa. Driver dos guards da TaskStateMachine.';
COMMENT ON COLUMN god_tasks.depends_on IS
  'Lista de god_tasks.id que precisam estar concluídas antes desta poder iniciar (sequência).';
COMMENT ON COLUMN god_tasks.rrule IS
  'RFC 5545 recurrence rule. Só faz sentido em especie=recorrente_template.';
COMMENT ON COLUMN god_tasks.parent_recurring_id IS
  'Aponta para o template (especie=recorrente_template) que gerou esta instância.';
COMMENT ON COLUMN god_tasks.trigger_rule_id IS
  'Aponta para a task_trigger_rules que disparou esta instância.';
COMMENT ON COLUMN god_tasks.proxima_execucao IS
  'Próximo horário em que o scheduler deve materializar uma instância (templates recorrentes).';

-- Indexes pra queries de scheduler/listener
CREATE INDEX IF NOT EXISTS idx_god_tasks_recurring_due
  ON god_tasks (proxima_execucao)
  WHERE especie = 'recorrente_template' AND status NOT IN ('arquivada','cancelada');

CREATE INDEX IF NOT EXISTS idx_god_tasks_especie
  ON god_tasks (especie, status);

CREATE INDEX IF NOT EXISTS idx_god_tasks_responsavel_status
  ON god_tasks (responsavel, status)
  WHERE status NOT IN ('concluida','arquivada','cancelada');

CREATE INDEX IF NOT EXISTS idx_god_tasks_depends_on
  ON god_tasks USING GIN (depends_on);

-- ------------------------------------------------------------
-- 2. task_trigger_rules: regras declarativas
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS task_trigger_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL,
  descricao TEXT,

  -- WHEN
  when_aggregate_type TEXT NOT NULL,
  when_event_type     TEXT NOT NULL,
  when_payload_filter JSONB DEFAULT '{}'::jsonb,

  -- THEN — template da task que será criada
  then_template JSONB NOT NULL,

  -- Controle
  ativa BOOLEAN NOT NULL DEFAULT true,
  origem TEXT NOT NULL DEFAULT 'manual' CHECK (origem IN ('manual','ia_sugerida','sistema')),
  criado_por TEXT,

  -- Ledger
  ultimo_disparo_em TIMESTAMPTZ,
  total_disparos INT NOT NULL DEFAULT 0,
  ultimo_evento_id BIGINT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE task_trigger_rules IS
  'Regras declarativas que escutam entity_events e materializam tarefas. Substrato pra automação process-mining-driven.';
COMMENT ON COLUMN task_trigger_rules.then_template IS
  'JSONB com os campos da task a criar: titulo, descricao, especie, responsavel, etc. Suporta interpolação ${event.payload.x}.';
COMMENT ON COLUMN task_trigger_rules.ultimo_evento_id IS
  'Cursor do listener — último entity_events.id processado por essa regra. Garante idempotência.';

CREATE INDEX IF NOT EXISTS idx_task_trigger_rules_match
  ON task_trigger_rules (when_aggregate_type, when_event_type)
  WHERE ativa = true;

ALTER TABLE task_trigger_rules ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ttr_select" ON task_trigger_rules FOR SELECT TO authenticated USING (true);
CREATE POLICY "ttr_insert" ON task_trigger_rules FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "ttr_update" ON task_trigger_rules FOR UPDATE TO authenticated USING (true);

GRANT SELECT, INSERT, UPDATE ON task_trigger_rules TO authenticated;
GRANT ALL ON task_trigger_rules TO service_role;

-- Trigger pra entity_events (Fase 1)
DROP TRIGGER IF EXISTS trg_lf_events_task_trigger_rules ON task_trigger_rules;
CREATE TRIGGER trg_lf_events_task_trigger_rules
  AFTER INSERT OR UPDATE OR DELETE ON task_trigger_rules
  FOR EACH ROW EXECUTE FUNCTION emit_entity_event('TaskTriggerRule');

-- ------------------------------------------------------------
-- 3. vw_meu_trabalho: tela default do operador (modo EU)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_meu_trabalho AS
SELECT
  t.id,
  t.titulo,
  t.descricao,
  t.status,
  t.prioridade,
  t.especie,
  t.responsavel,
  t.acompanhante,
  t.mentorado_id,
  t.mentorado_nome,
  t.sprint_id,
  t.space_id,
  t.list_id,
  t.parent_task_id,
  t.depends_on,
  t.tags,
  t.tipo,
  t.data_inicio,
  t.data_fim,
  t.created_at,
  t.updated_at,
  -- "modo EU": é minha como dona OU como acompanhante?
  CASE
    WHEN t.responsavel IS NOT NULL THEN t.responsavel
    ELSE t.acompanhante
  END AS papel_principal,
  -- Bloqueada por dependência ainda aberta?
  EXISTS (
    SELECT 1 FROM god_tasks dep
    WHERE dep.id = ANY(t.depends_on)
      AND dep.status NOT IN ('concluida','cancelada','arquivada')
  ) AS bloqueada_por_dependencia,
  -- Atrasada (data_fim no passado e ainda aberta)?
  (t.data_fim IS NOT NULL
    AND t.data_fim < now()
    AND t.status NOT IN ('concluida','cancelada','arquivada')) AS atrasada
FROM god_tasks t
WHERE t.especie NOT IN ('recorrente_template','triggered_template')  -- só execuções reais
  AND t.status NOT IN ('arquivada','cancelada')
ORDER BY
  CASE t.prioridade
    WHEN 'urgente' THEN 1
    WHEN 'alta'    THEN 2
    WHEN 'normal'  THEN 3
    WHEN 'baixa'   THEN 4
    ELSE 5
  END,
  t.data_fim NULLS LAST,
  t.created_at;

COMMENT ON VIEW vw_meu_trabalho IS
  'Tela default do operador. Filtra com WHERE responsavel = X OR acompanhante = X pra modo EU.';

GRANT SELECT ON vw_meu_trabalho TO authenticated, anon, service_role;

COMMIT;
