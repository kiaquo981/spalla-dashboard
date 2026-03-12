-- ============================================================
-- Operon Dashboard — Onboarding ↔ God Tasks Bridge
-- 2026-03-12
-- ============================================================
-- OBJETIVO:
-- 1. Linkar ob_tarefas com god_tasks via FK
-- 2. Trigger: nova ob_tarefa → cria god_task automaticamente
-- 3. Sync bidirecional de status
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. FK: god_tasks.ob_tarefa_id
-- ─────────────────────────────────────────────────────────────
ALTER TABLE god_tasks
  ADD COLUMN IF NOT EXISTS ob_tarefa_id UUID;

CREATE INDEX IF NOT EXISTS idx_god_tasks_ob_tarefa
  ON god_tasks (ob_tarefa_id) WHERE ob_tarefa_id IS NOT NULL;

-- ─────────────────────────────────────────────────────────────
-- 2. TRIGGER: INSERT em ob_tarefas → cria god_task
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION bridge_ob_to_god_task()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_task_id UUID;
  v_mentorado_nome TEXT;
  v_mentorado_id BIGINT;
BEGIN
  -- Buscar mentorado via trilha
  SELECT t.mentorado_id INTO v_mentorado_id
  FROM ob_trilhas t
  WHERE t.id = NEW.trilha_id;

  SELECT nome INTO v_mentorado_nome
  FROM "case".mentorados
  WHERE id = v_mentorado_id;

  INSERT INTO god_tasks (
    titulo, descricao, status, prioridade, responsavel,
    mentorado_id, mentorado_nome, data_fim,
    space_id, list_id, fonte,
    ob_tarefa_id, auto_created
  ) VALUES (
    '[OB] ' || NEW.titulo,
    NEW.descricao,
    CASE NEW.status
      WHEN 'concluida' THEN 'concluida'
      WHEN 'em_andamento' THEN 'em_andamento'
      ELSE 'pendente'
    END,
    'normal',
    NEW.responsavel,
    v_mentorado_id,
    v_mentorado_nome,
    NEW.data_prevista,
    'space_jornada',
    'list_onboarding',
    'onboarding',
    NEW.id,
    true
  )
  RETURNING id INTO v_task_id;

  RETURN NEW;
END;
$$;

-- Criar trigger apenas se não existir
DROP TRIGGER IF EXISTS trg_ob_to_god_task ON ob_tarefas;
CREATE TRIGGER trg_ob_to_god_task
  AFTER INSERT ON ob_tarefas
  FOR EACH ROW
  EXECUTE FUNCTION bridge_ob_to_god_task();

-- ─────────────────────────────────────────────────────────────
-- 3. SYNC BIDIRECIONAL: ob_tarefas ↔ god_tasks
-- ─────────────────────────────────────────────────────────────

-- OB → God Tasks (status change)
CREATE OR REPLACE FUNCTION sync_ob_to_god()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    UPDATE god_tasks
    SET status = CASE NEW.status
          WHEN 'concluida'    THEN 'concluida'
          WHEN 'em_andamento' THEN 'em_andamento'
          ELSE 'pendente'
        END,
        updated_at = now()
    WHERE ob_tarefa_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_ob_to_god ON ob_tarefas;
CREATE TRIGGER trg_sync_ob_to_god
  AFTER UPDATE OF status ON ob_tarefas
  FOR EACH ROW
  EXECUTE FUNCTION sync_ob_to_god();

-- God Tasks → OB (status change)
CREATE OR REPLACE FUNCTION sync_god_to_ob()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NEW.ob_tarefa_id IS NOT NULL AND OLD.status IS DISTINCT FROM NEW.status THEN
    UPDATE ob_tarefas
    SET status = CASE NEW.status
          WHEN 'concluida'    THEN 'concluida'
          WHEN 'em_andamento' THEN 'em_andamento'
          WHEN 'cancelada'    THEN 'cancelada'
          ELSE 'pendente'
        END,
        data_conclusao = CASE WHEN NEW.status = 'concluida' THEN CURRENT_DATE ELSE data_conclusao END,
        updated_at = now()
    WHERE id = NEW.ob_tarefa_id;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_god_to_ob ON god_tasks;
CREATE TRIGGER trg_sync_god_to_ob
  AFTER UPDATE OF status ON god_tasks
  FOR EACH ROW
  WHEN (NEW.ob_tarefa_id IS NOT NULL)
  EXECUTE FUNCTION sync_god_to_ob();

-- ─────────────────────────────────────────────────────────────
-- 4. BACKFILL: criar god_tasks para ob_tarefas existentes
-- ─────────────────────────────────────────────────────────────
INSERT INTO god_tasks (
  titulo, descricao, status, prioridade, responsavel,
  mentorado_id, mentorado_nome, data_fim,
  space_id, list_id, fonte,
  ob_tarefa_id, auto_created
)
SELECT
  '[OB] ' || ot.titulo,
  ot.descricao,
  CASE ot.status
    WHEN 'concluida' THEN 'concluida'
    WHEN 'em_andamento' THEN 'em_andamento'
    ELSE 'pendente'
  END,
  'normal',
  ot.responsavel,
  t.mentorado_id,
  m.nome,
  ot.data_prevista,
  'space_jornada',
  'list_onboarding',
  'onboarding',
  ot.id,
  true
FROM ob_tarefas ot
JOIN ob_etapas e ON e.id = ot.etapa_id
JOIN ob_trilhas t ON t.id = e.trilha_id
LEFT JOIN "case".mentorados m ON m.id = t.mentorado_id
WHERE NOT EXISTS (
  SELECT 1 FROM god_tasks gt WHERE gt.ob_tarefa_id = ot.id
);
