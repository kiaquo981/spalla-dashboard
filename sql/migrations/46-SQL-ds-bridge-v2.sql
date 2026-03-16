-- ============================================================
-- Operon Dashboard — Dossier ↔ God Tasks Bridge (v2 — fixed column names)
-- 2026-03-16
-- ============================================================
-- FIXES from v1:
--   estagio → estagio_atual
--   tipo_documento → tipo
--   responsavel → responsavel_atual
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. FKs em ds_documentos e ds_ajustes
-- ─────────────────────────────────────────────────────────────
ALTER TABLE ds_documentos
  ADD COLUMN IF NOT EXISTS god_task_id UUID REFERENCES god_tasks(id) ON DELETE SET NULL;

ALTER TABLE ds_ajustes
  ADD COLUMN IF NOT EXISTS god_task_id UUID REFERENCES god_tasks(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_ds_documentos_task
  ON ds_documentos (god_task_id) WHERE god_task_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_ds_ajustes_task
  ON ds_ajustes (god_task_id) WHERE god_task_id IS NOT NULL;

-- ─────────────────────────────────────────────────────────────
-- 2. TRIGGER: mudança de estágio → cria god_task para responsável
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION bridge_ds_stage_to_task()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, "case"
AS $$
DECLARE
  v_task_id UUID;
  v_mentorado_nome TEXT;
BEGIN
  -- Só criar task quando entra em revisão (não no estado final)
  IF NEW.estagio_atual IN ('producao_ia', 'revisao_mariza', 'revisao_kaique', 'revisao_queila') AND
     (OLD.estagio_atual IS NULL OR OLD.estagio_atual IS DISTINCT FROM NEW.estagio_atual) THEN

    SELECT nome INTO v_mentorado_nome
    FROM "case".mentorados WHERE id = NEW.mentorado_id;

    -- Fechar task anterior do mesmo documento se existir
    IF OLD.god_task_id IS NOT NULL THEN
      UPDATE god_tasks
      SET status = 'concluida', updated_at = now()
      WHERE id = OLD.god_task_id AND status != 'concluida';
    END IF;

    INSERT INTO god_tasks (
      titulo, descricao, status, prioridade, responsavel,
      mentorado_id, mentorado_nome,
      space_id, list_id, fonte,
      auto_created
    ) VALUES (
      '[DS] ' || NEW.tipo || ' — ' || COALESCE(v_mentorado_nome, 'Mentorado'),
      'Estágio: ' || NEW.estagio_atual || ' → ação necessária',
      'pendente',
      CASE
        WHEN NEW.estagio_atual LIKE 'revisao_%' THEN 'alta'
        ELSE 'normal'
      END,
      NEW.responsavel_atual,
      NEW.mentorado_id,
      v_mentorado_nome,
      'space_gestao',
      'list_dossies',
      'dossie',
      true
    )
    RETURNING id INTO v_task_id;

    -- Link task ao documento
    NEW.god_task_id := v_task_id;

  END IF;

  -- Fechar task quando documento for concluído/enviado/finalizado
  IF NEW.estagio_atual IN ('enviado', 'finalizado') AND OLD.god_task_id IS NOT NULL THEN
    UPDATE god_tasks
    SET status = 'concluida', updated_at = now()
    WHERE id = OLD.god_task_id AND status != 'concluida';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_ds_stage_to_task ON ds_documentos;
CREATE TRIGGER trg_ds_stage_to_task
  BEFORE UPDATE OF estagio_atual ON ds_documentos
  FOR EACH ROW
  EXECUTE FUNCTION bridge_ds_stage_to_task();
