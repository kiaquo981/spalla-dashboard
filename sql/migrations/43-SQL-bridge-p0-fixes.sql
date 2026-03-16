-- ============================================================
-- Operon Dashboard — P0 Bridge Fixes
-- 2026-03-12
-- ============================================================
-- OBJETIVO:
-- 1. Substituir hack notas→task_id por FK real em pa_acoes
-- 2. Enriquecer calls_mentoria com links para PA/DS/OB + campos IA
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. FK REAL: pa_acoes.god_task_id (substitui hack de notas)
-- ─────────────────────────────────────────────────────────────
ALTER TABLE pa_acoes
  ADD COLUMN IF NOT EXISTS god_task_id UUID REFERENCES god_tasks(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_pa_acoes_god_task
  ON pa_acoes (god_task_id) WHERE god_task_id IS NOT NULL;

-- ─────────────────────────────────────────────────────────────
-- 2. BACKFILL: extrair task_id do hack em notas
--    Formato: '... | task_id:<uuid>'
-- ─────────────────────────────────────────────────────────────
UPDATE pa_acoes
SET god_task_id = (
  regexp_match(notas, 'task_id:([0-9a-f\-]{36})')
)[1]::uuid
WHERE notas LIKE '%task_id:%'
  AND god_task_id IS NULL;

-- ─────────────────────────────────────────────────────────────
-- 3. Atualizar bridge_create_task para usar FK real
--    (em vez de concatenar em notas)
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION bridge_create_task(
  p_mentorado_id      BIGINT,
  p_titulo             TEXT,
  p_descricao          TEXT DEFAULT NULL,
  p_responsavel        TEXT DEFAULT NULL,
  p_prioridade         TEXT DEFAULT 'normal',
  p_data_fim           DATE DEFAULT NULL,
  p_fonte              TEXT DEFAULT 'whatsapp',
  p_interacao_id       UUID DEFAULT NULL,
  p_call_id            UUID DEFAULT NULL,
  p_pa_acao_id         UUID DEFAULT NULL,
  p_confianca          NUMERIC DEFAULT NULL,
  p_tags               TEXT[] DEFAULT '{}'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_task_id UUID;
  v_mentorado_nome TEXT;
  v_fase TEXT;
  v_space TEXT;
  v_list TEXT;
BEGIN
  SELECT nome, fase_jornada INTO v_mentorado_nome, v_fase
  FROM "case".mentorados WHERE id = p_mentorado_id;

  IF p_responsavel IS NOT NULL AND lower(p_responsavel) NOT IN ('mentorado', lower(COALESCE(v_mentorado_nome, ''))) THEN
    v_space := 'space_gestao';
    v_list  := 'list_operacional';
  ELSE
    v_space := 'space_jornada';
    v_list  := CASE v_fase
      WHEN 'onboarding'  THEN 'list_onboarding'
      WHEN 'concepcao'   THEN 'list_concepcao'
      WHEN 'validacao'   THEN 'list_validacao'
      WHEN 'otimizacao'  THEN 'list_otimizacao'
      WHEN 'escala'      THEN 'list_escala'
      ELSE 'list_geral'
    END;
  END IF;

  INSERT INTO god_tasks (
    titulo, descricao, status, prioridade, responsavel,
    mentorado_id, mentorado_nome, data_fim,
    space_id, list_id, fonte,
    interacao_origem_id, call_origem_id, pa_acao_id,
    auto_created, confianca_ia, tags
  ) VALUES (
    p_titulo, p_descricao, 'pendente', p_prioridade, p_responsavel,
    p_mentorado_id, v_mentorado_nome, p_data_fim,
    v_space, v_list, p_fonte,
    p_interacao_id, p_call_id, p_pa_acao_id,
    true, p_confianca, p_tags
  )
  RETURNING id INTO v_task_id;

  -- Usar FK real em vez do hack de notas
  IF p_pa_acao_id IS NOT NULL THEN
    UPDATE pa_acoes SET god_task_id = v_task_id
    WHERE id = p_pa_acao_id AND god_task_id IS NULL;
  END IF;

  RETURN v_task_id;
END;
$$;

GRANT EXECUTE ON FUNCTION bridge_create_task(BIGINT,TEXT,TEXT,TEXT,TEXT,DATE,TEXT,UUID,UUID,UUID,NUMERIC,TEXT[]) TO service_role;

-- ─────────────────────────────────────────────────────────────
-- 4. Atualizar sync bidirecional para usar god_task_id
-- ─────────────────────────────────────────────────────────────

-- PA → Tasks (agora via FK bidirecional)
CREATE OR REPLACE FUNCTION sync_pa_to_task()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    -- Sync via god_tasks.pa_acao_id (original)
    UPDATE god_tasks
    SET status = CASE NEW.status
          WHEN 'concluido'    THEN 'concluida'
          WHEN 'em_andamento' THEN 'em_andamento'
          WHEN 'bloqueado'    THEN 'pendente'
          ELSE 'pendente'
        END,
        updated_at = now()
    WHERE pa_acao_id = NEW.id;

    -- Sync via pa_acoes.god_task_id (novo FK)
    IF NEW.god_task_id IS NOT NULL THEN
      UPDATE god_tasks
      SET status = CASE NEW.status
            WHEN 'concluido'    THEN 'concluida'
            WHEN 'em_andamento' THEN 'em_andamento'
            WHEN 'bloqueado'    THEN 'pendente'
            ELSE 'pendente'
          END,
          updated_at = now()
      WHERE id = NEW.god_task_id
        AND status IS DISTINCT FROM CASE NEW.status
            WHEN 'concluido'    THEN 'concluida'
            WHEN 'em_andamento' THEN 'em_andamento'
            WHEN 'bloqueado'    THEN 'pendente'
            ELSE 'pendente'
          END;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

-- Tasks → PA (agora também atualiza via god_task_id)
CREATE OR REPLACE FUNCTION sync_task_to_pa()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Sync via pa_acao_id (original)
  IF NEW.pa_acao_id IS NOT NULL AND OLD.status IS DISTINCT FROM NEW.status THEN
    UPDATE pa_acoes
    SET status = CASE NEW.status
          WHEN 'concluida'    THEN 'concluido'
          WHEN 'em_andamento' THEN 'em_andamento'
          WHEN 'cancelada'    THEN 'nao_aplicavel'
          ELSE 'pendente'
        END,
        data_conclusao = CASE WHEN NEW.status = 'concluida' THEN CURRENT_DATE ELSE data_conclusao END,
        updated_at = now()
    WHERE id = NEW.pa_acao_id;
  END IF;

  -- Sync via god_task_id (novo FK reverso)
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    UPDATE pa_acoes
    SET status = CASE NEW.status
          WHEN 'concluida'    THEN 'concluido'
          WHEN 'em_andamento' THEN 'em_andamento'
          WHEN 'cancelada'    THEN 'nao_aplicavel'
          ELSE 'pendente'
        END,
        data_conclusao = CASE WHEN NEW.status = 'concluida' THEN CURRENT_DATE ELSE data_conclusao END,
        updated_at = now()
    WHERE god_task_id = NEW.id
      AND id IS DISTINCT FROM NEW.pa_acao_id;  -- evitar double-update
  END IF;

  RETURN NEW;
END;
$$;

-- ─────────────────────────────────────────────────────────────
-- 5. ENRIQUECER calls_mentoria com links cross-system + IA
-- ─────────────────────────────────────────────────────────────
ALTER TABLE calls_mentoria
  ADD COLUMN IF NOT EXISTS pa_plano_id       UUID REFERENCES pa_planos(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS ds_producao_id    UUID,  -- FK lógica para ds_producoes
  ADD COLUMN IF NOT EXISTS ob_trilha_id      UUID,  -- FK lógica para ob_trilhas
  ADD COLUMN IF NOT EXISTS sentimento_geral  TEXT CHECK (sentimento_geral IN ('positivo', 'neutro', 'negativo', 'misto')),
  ADD COLUMN IF NOT EXISTS decisoes_json     JSONB DEFAULT '[]',
  ADD COLUMN IF NOT EXISTS bloqueios_json    JSONB DEFAULT '[]';

COMMENT ON COLUMN calls_mentoria.decisoes_json IS 'Array de {texto, responsavel, prazo, status}';
COMMENT ON COLUMN calls_mentoria.bloqueios_json IS 'Array de {texto, severidade, resolvido}';

-- Índices parciais para queries de dashboard
CREATE INDEX IF NOT EXISTS idx_calls_pa_plano
  ON calls_mentoria (pa_plano_id) WHERE pa_plano_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_calls_sentimento
  ON calls_mentoria (sentimento_geral) WHERE sentimento_geral IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_calls_ds_producao
  ON calls_mentoria (ds_producao_id) WHERE ds_producao_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_calls_ob_trilha
  ON calls_mentoria (ob_trilha_id) WHERE ob_trilha_id IS NOT NULL;
