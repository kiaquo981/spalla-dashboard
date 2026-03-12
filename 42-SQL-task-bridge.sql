-- ============================================================
-- Spalla Dashboard — Task Bridge Layer
-- 2026-03-12
-- ============================================================
-- OBJETIVO: Unificar tudo em god_tasks.
-- v34 hoje escreve em tarefas_acordadas → muda pra god_tasks.
-- Calls geram próximos_passos como texto → viram god_tasks.
-- PA ações linkam bidirecionalmente com god_tasks.
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. NOVAS COLUNAS EM god_tasks (links de origem)
-- ─────────────────────────────────────────────────────────────
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS pa_acao_id       UUID REFERENCES pa_acoes(id) ON DELETE SET NULL;
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS interacao_origem_id UUID;  -- FK lógica para interacoes_mentoria (schema case)
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS call_origem_id   UUID;    -- FK lógica para analises_call (schema case)
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS auto_created     BOOLEAN DEFAULT false;
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS confianca_ia     NUMERIC(3,2);  -- 0.00-1.00 confiança da extração

CREATE INDEX IF NOT EXISTS idx_god_tasks_pa_acao ON god_tasks (pa_acao_id) WHERE pa_acao_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_god_tasks_interacao ON god_tasks (interacao_origem_id) WHERE interacao_origem_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_god_tasks_call ON god_tasks (call_origem_id) WHERE call_origem_id IS NOT NULL;

-- ─────────────────────────────────────────────────────────────
-- 2. FUNCTION: bridge_create_task (chamada pelo v34)
-- Substitui INSERT direto em tarefas_acordadas.
-- v34 chama: POST /rest/v1/rpc/bridge_create_task
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
  -- Buscar nome e fase do mentorado para auto-categorização
  SELECT nome, fase_jornada INTO v_mentorado_nome, v_fase
  FROM "case".mentorados WHERE id = p_mentorado_id;

  -- Auto-categorizar space/list baseado na fase (mesma lógica do app.js)
  IF p_responsavel IS NOT NULL AND lower(p_responsavel) NOT IN ('mentorado', v_mentorado_nome) THEN
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

  -- Se veio de PA, criar link bidirecional
  IF p_pa_acao_id IS NOT NULL THEN
    UPDATE pa_acoes SET notas = COALESCE(notas, '') || ' | task_id:' || v_task_id::text
    WHERE id = p_pa_acao_id;
  END IF;

  RETURN v_task_id;
END;
$$;

GRANT EXECUTE ON FUNCTION bridge_create_task(BIGINT,TEXT,TEXT,TEXT,TEXT,DATE,TEXT,UUID,UUID,UUID,NUMERIC,TEXT[]) TO service_role;

-- ─────────────────────────────────────────────────────────────
-- 3. FUNCTION: bridge_auto_check_task (chamada pelo v34 após
--    "Detectar Ação Concluída")
-- Match fuzzy: mentorado + keywords da ação → task mais próxima
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION bridge_auto_check_task(
  p_mentorado_id    BIGINT,
  p_acao_concluida  TEXT,      -- descrição da ação (do GPT)
  p_evidencia       TEXT DEFAULT NULL,
  p_interacao_id    UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_task RECORD;
  v_pa   RECORD;
  v_matched_tasks UUID[] := '{}';
  v_matched_pa    UUID[] := '{}';
  v_keywords TEXT[];
  v_search_terms TEXT;
BEGIN
  -- Gerar termos de busca a partir da ação concluída
  v_search_terms := lower(unaccent(p_acao_concluida));

  -- 1. Buscar god_tasks abertas do mentorado com match textual
  FOR v_task IN
    SELECT id, titulo, descricao
    FROM god_tasks
    WHERE mentorado_id = p_mentorado_id
      AND status IN ('pendente', 'em_andamento')
      AND (
        lower(unaccent(titulo)) % v_search_terms  -- trigram similarity
        OR v_search_terms ILIKE '%' || lower(unaccent(LEFT(titulo, 40))) || '%'
        OR lower(unaccent(titulo)) ILIKE '%' || LEFT(v_search_terms, 40) || '%'
      )
    ORDER BY similarity(lower(unaccent(titulo)), v_search_terms) DESC
    LIMIT 3
  LOOP
    -- Auto-check se similaridade > 0.3
    IF similarity(lower(unaccent(v_task.titulo)), v_search_terms) > 0.3 THEN
      UPDATE god_tasks
      SET status = 'concluida',
          updated_at = now()
      WHERE id = v_task.id;

      -- Adicionar comment automático
      INSERT INTO god_task_comments (task_id, author, texto)
      VALUES (v_task.id, 'ia-v34',
        'Auto-check via WhatsApp: "' || LEFT(p_acao_concluida, 200) || '"'
        || CASE WHEN p_evidencia IS NOT NULL THEN E'\nEvidência: "' || LEFT(p_evidencia, 200) || '"' ELSE '' END
      );

      v_matched_tasks := array_append(v_matched_tasks, v_task.id);
    END IF;
  END LOOP;

  -- 2. Buscar pa_acoes abertas do mentorado com match textual
  FOR v_pa IN
    SELECT id, titulo
    FROM pa_acoes
    WHERE mentorado_id = p_mentorado_id
      AND status IN ('pendente', 'em_andamento')
      AND (
        lower(unaccent(titulo)) % v_search_terms
        OR v_search_terms ILIKE '%' || lower(unaccent(LEFT(titulo, 40))) || '%'
        OR lower(unaccent(titulo)) ILIKE '%' || LEFT(v_search_terms, 40) || '%'
      )
    ORDER BY similarity(lower(unaccent(titulo)), v_search_terms) DESC
    LIMIT 3
  LOOP
    IF similarity(lower(unaccent(v_pa.titulo)), v_search_terms) > 0.3 THEN
      UPDATE pa_acoes
      SET status = 'concluido',
          data_conclusao = CURRENT_DATE,
          updated_at = now()
      WHERE id = v_pa.id;

      v_matched_pa := array_append(v_matched_pa, v_pa.id);
    END IF;
  END LOOP;

  RETURN jsonb_build_object(
    'matched_tasks', to_jsonb(v_matched_tasks),
    'matched_pa',    to_jsonb(v_matched_pa),
    'search_terms',  v_search_terms,
    'total_checked',  array_length(v_matched_tasks, 1) + array_length(v_matched_pa, 1)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION bridge_auto_check_task(BIGINT,TEXT,TEXT,UUID) TO service_role;

-- ─────────────────────────────────────────────────────────────
-- 4. TRIGGER: Calls → god_tasks automáticas
-- Quando analises_call é inserida com proximos_passos,
-- cria god_tasks para cada próximo passo.
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION bridge_call_to_tasks()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_passo TEXT;
  v_mentorado_nome TEXT;
  v_fase TEXT;
BEGIN
  -- Só processar se tem próximos passos
  IF NEW.proximos_passos IS NULL OR array_length(NEW.proximos_passos, 1) IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT nome, fase_jornada INTO v_mentorado_nome, v_fase
  FROM "case".mentorados WHERE id = NEW.mentorado_id;

  FOREACH v_passo IN ARRAY NEW.proximos_passos
  LOOP
    -- Pular passos vazios ou muito curtos
    IF length(trim(v_passo)) < 5 THEN
      CONTINUE;
    END IF;

    -- Verificar se já existe task similar (dedup)
    IF NOT EXISTS (
      SELECT 1 FROM god_tasks
      WHERE mentorado_id = NEW.mentorado_id
        AND call_origem_id = NEW.id
        AND similarity(lower(unaccent(titulo)), lower(unaccent(v_passo))) > 0.5
    ) THEN
      INSERT INTO god_tasks (
        titulo, descricao, status, prioridade, responsavel,
        mentorado_id, mentorado_nome, data_fim,
        space_id, list_id, fonte,
        call_origem_id, auto_created, confianca_ia
      ) VALUES (
        LEFT(trim(v_passo), 200),
        'Extraído da call ' || COALESCE(NEW.tipo_call, '') || ' de ' || COALESCE(NEW.data_call::text, ''),
        'pendente', 'normal', v_mentorado_nome,
        NEW.mentorado_id, v_mentorado_nome,
        (NEW.data_call + interval '7 days')::date,  -- prazo default: 7 dias após call
        'space_jornada',
        CASE v_fase
          WHEN 'onboarding' THEN 'list_onboarding'
          WHEN 'concepcao'  THEN 'list_concepcao'
          WHEN 'validacao'  THEN 'list_validacao'
          WHEN 'otimizacao' THEN 'list_otimizacao'
          WHEN 'escala'     THEN 'list_escala'
          ELSE 'list_geral'
        END,
        'analise_call',
        NEW.id, true, NEW.confianca_fase
      );
    END IF;
  END LOOP;

  -- Também criar tasks das decisões tomadas
  IF NEW.decisoes_tomadas IS NOT NULL AND array_length(NEW.decisoes_tomadas, 1) > 0 THEN
    FOREACH v_passo IN ARRAY NEW.decisoes_tomadas
    LOOP
      IF length(trim(v_passo)) < 5 THEN
        CONTINUE;
      END IF;

      IF NOT EXISTS (
        SELECT 1 FROM god_tasks
        WHERE mentorado_id = NEW.mentorado_id
          AND call_origem_id = NEW.id
          AND similarity(lower(unaccent(titulo)), lower(unaccent(v_passo))) > 0.5
      ) THEN
        INSERT INTO god_tasks (
          titulo, descricao, status, prioridade,
          mentorado_id, mentorado_nome,
          space_id, list_id, fonte,
          call_origem_id, auto_created, tags
        ) VALUES (
          LEFT(trim(v_passo), 200),
          'Decisão da call ' || COALESCE(NEW.tipo_call, '') || ' de ' || COALESCE(NEW.data_call::text, ''),
          'pendente', 'alta',
          NEW.mentorado_id, v_mentorado_nome,
          'space_gestao', 'list_operacional', 'decisao_call',
          NEW.id, true, ARRAY['decisao-call']
        );
      END IF;
    END LOOP;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_call_to_tasks ON public.analises_call;
CREATE TRIGGER trg_call_to_tasks
  AFTER INSERT ON public.analises_call
  FOR EACH ROW
  EXECUTE FUNCTION bridge_call_to_tasks();

-- ─────────────────────────────────────────────────────────────
-- 5. SYNC BIDIRECIONAL: PA ↔ god_tasks
-- Quando pa_acoes muda status → atualiza god_task linkada
-- Quando god_tasks muda status → atualiza pa_acao linkada
-- ─────────────────────────────────────────────────────────────

-- PA → Tasks
CREATE OR REPLACE FUNCTION sync_pa_to_task()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    UPDATE god_tasks
    SET status = CASE NEW.status
          WHEN 'concluido'  THEN 'concluida'
          WHEN 'em_andamento' THEN 'em_andamento'
          WHEN 'bloqueado'  THEN 'pendente'
          ELSE 'pendente'
        END,
        updated_at = now()
    WHERE pa_acao_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_pa_to_task ON pa_acoes;
CREATE TRIGGER trg_sync_pa_to_task
  AFTER UPDATE OF status ON pa_acoes
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION sync_pa_to_task();

-- Tasks → PA
CREATE OR REPLACE FUNCTION sync_task_to_pa()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
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
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_task_to_pa ON god_tasks;
CREATE TRIGGER trg_sync_task_to_pa
  AFTER UPDATE OF status ON god_tasks
  FOR EACH ROW
  WHEN (NEW.pa_acao_id IS NOT NULL AND OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION sync_task_to_pa();

-- ─────────────────────────────────────────────────────────────
-- 6. EXTENSÃO pg_trgm (necessária para match fuzzy)
-- ─────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Índices trigram para match fuzzy
CREATE INDEX IF NOT EXISTS idx_god_tasks_titulo_trgm
  ON god_tasks USING gin (lower(unaccent(titulo)) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_pa_acoes_titulo_trgm
  ON pa_acoes USING gin (lower(unaccent(titulo)) gin_trgm_ops);

-- ─────────────────────────────────────────────────────────────
-- 7. MIGRAR tarefas_acordadas existentes → god_tasks
-- ─────────────────────────────────────────────────────────────
INSERT INTO god_tasks (
  titulo, descricao, status, prioridade, responsavel,
  mentorado_id, mentorado_nome, data_fim,
  fonte, auto_created, created_at
)
SELECT
  ta.tarefa,
  ta.observacoes,
  COALESCE(ta.status, 'pendente'),
  COALESCE(ta.prioridade, 'normal'),
  ta.responsavel,
  ta.mentorado_id,
  m.nome,
  ta.prazo::date,
  'tarefas_acordadas',
  true,
  COALESCE(ta.created_at, now())
FROM tarefas_acordadas ta
LEFT JOIN "case".mentorados m ON m.id = ta.mentorado_id
WHERE NOT EXISTS (
  SELECT 1 FROM god_tasks g
  WHERE g.mentorado_id = ta.mentorado_id
    AND g.fonte = 'tarefas_acordadas'
    AND similarity(lower(g.titulo), lower(ta.tarefa)) > 0.8
);

-- Também migrar tarefas_equipe
INSERT INTO god_tasks (
  titulo, descricao, status, prioridade, responsavel,
  mentorado_id, mentorado_nome,
  data_fim, space_id, list_id, fonte, auto_created, created_at
)
SELECT
  te.tarefa,
  NULL,
  COALESCE(te.status, 'pendente'),
  COALESCE(te.prioridade, 'normal'),
  te.responsavel_nome,
  te.mentorado_id,
  te.mentorado_nome,
  te.prazo,
  'space_gestao', 'list_operacional',
  'tarefas_equipe',
  true,
  COALESCE(te.created_at, now())
FROM tarefas_equipe te
WHERE NOT EXISTS (
  SELECT 1 FROM god_tasks g
  WHERE g.mentorado_id = te.mentorado_id
    AND g.fonte = 'tarefas_equipe'
    AND similarity(lower(g.titulo), lower(te.tarefa)) > 0.8
);
