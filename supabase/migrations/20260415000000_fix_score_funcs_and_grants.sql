-- Fix: funções atualizar_score_* + buscar_mentorado + GRANT case_archives
-- Contexto: cleanup 2026-04-14 dropou score_engajamento, score_implementacao,
--           faturamento_atual de case.mentorados (movido pra case_archives)

-- ============================================================
-- GRANTS: dar acesso ao schema case_archives para roles PostgREST
-- (necessário para fn_god_mentorado_deep via SECURITY INVOKER)
-- ============================================================
GRANT USAGE ON SCHEMA case_archives TO authenticated, anon, service_role;
GRANT SELECT ON case_archives.mentorados_financeiro TO authenticated, anon, service_role;

-- ============================================================
-- atualizar_score_engajamento — remove UPDATE em coluna dropada
-- Mantém lógica de cálculo, retorna score sem persistir
-- ============================================================
CREATE OR REPLACE FUNCTION public.atualizar_score_engajamento(p_mentorado_id bigint)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_score INTEGER;
BEGIN
  SELECT
    LEAST(100, GREATEST(0,
      50
      + CASE WHEN MAX(i.timestamp) >= NOW() - INTERVAL '7 days' THEN 30 ELSE 0 END
      + LEAST(20, COUNT(i.id) FILTER (
          WHERE i.prioridade IN ('alta', 'urgente')
          AND i.timestamp >= NOW() - INTERVAL '7 days'
        ) * 10)
      - CASE WHEN MAX(i.timestamp) < NOW() - INTERVAL '14 days' THEN 30 ELSE 0 END
      - CASE WHEN MAX(i.timestamp) < NOW() - INTERVAL '21 days' THEN 20 ELSE 0 END
    ))
  INTO v_score
  FROM interacoes_mentoria i
  WHERE i.mentorado_id = p_mentorado_id;

  -- score_engajamento foi removido do schema em 2026-04-14
  -- não persiste mais; apenas retorna valor calculado
  RETURN COALESCE(v_score, 50);
END;
$$;

GRANT EXECUTE ON FUNCTION public.atualizar_score_engajamento(bigint) TO authenticated, anon;

-- ============================================================
-- atualizar_score_implementacao — remove UPDATE em coluna dropada
-- ============================================================
CREATE OR REPLACE FUNCTION public.atualizar_score_implementacao(p_mentorado_id bigint)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_score INTEGER;
BEGIN
  SELECT
    LEAST(100, GREATEST(0,
      50
      + ROUND(
          COUNT(t.id) FILTER (WHERE t.status = 'concluida')::NUMERIC /
          NULLIF(COUNT(t.id), 0) * 40
        )
      + LEAST(10, COUNT(ma.id) FILTER (WHERE ma.implementado = TRUE) * 5)
      - LEAST(30,
          COUNT(t.id) FILTER (
            WHERE t.prazo < NOW()
            AND t.status NOT IN ('concluida', 'cancelada')
          ) * 10
        )
    ))
  INTO v_score
  FROM mentorados m
  LEFT JOIN tarefas_acordadas t ON m.id = t.mentorado_id
  LEFT JOIN materiais_entregues ma ON m.id = ma.mentorado_id
  WHERE m.id = p_mentorado_id
  GROUP BY m.id;

  -- score_implementacao foi removido do schema em 2026-04-14
  -- não persiste mais; apenas retorna valor calculado
  RETURN COALESCE(v_score, 50);
END;
$$;

GRANT EXECUTE ON FUNCTION public.atualizar_score_implementacao(bigint) TO authenticated, anon;

-- ============================================================
-- buscar_mentorado — remove faturamento_atual e score_engajamento
-- (ambos dropados). Faturamento agora vem de case_archives.
-- ============================================================
DROP FUNCTION IF EXISTS public.buscar_mentorado(text) CASCADE;
CREATE OR REPLACE FUNCTION public.buscar_mentorado(nome_busca text)
RETURNS TABLE(
  id            bigint,
  nome          character varying,
  telefone      character varying,
  estagio       character varying,
  faturamento_atual  numeric,
  score_engajamento  integer
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    m.id,
    m.nome,
    m.telefone,
    m.estagio,
    COALESCE(mf.faturamento_atual, 0)::numeric,
    NULL::integer  -- score_engajamento removido em 2026-04-14
  FROM "case".mentorados m
  LEFT JOIN case_archives.mentorados_financeiro mf ON mf.mentorado_id = m.id
  WHERE m.nome ILIKE '%' || nome_busca || '%'
  ORDER BY m.nome
  LIMIT 10;
END;
$$;

GRANT EXECUTE ON FUNCTION public.buscar_mentorado(text) TO authenticated, anon;

-- Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- Verificação
SELECT proname, pg_get_function_identity_arguments(oid) AS args
FROM pg_proc
WHERE proname IN (
  'atualizar_score_engajamento',
  'atualizar_score_implementacao',
  'buscar_mentorado'
);
