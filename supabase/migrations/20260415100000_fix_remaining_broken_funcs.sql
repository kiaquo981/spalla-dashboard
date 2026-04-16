-- Fix: buscar_contexto_rag, calcular_estagio_mentorado, get_stats_mentorado
-- Contexto: cleanup 2026-04-14 dropou faturamento_atual/meta_faturamento de mentorados;
--           esses campos foram movidos para case_archives.mentorados_financeiro

-- ============================================================
-- buscar_contexto_rag — substitui faturamento_atual/meta_faturamento
-- por LEFT JOIN case_archives.mentorados_financeiro
-- ============================================================
CREATE OR REPLACE FUNCTION public.buscar_contexto_rag(
  p_mentorado_id bigint,
  p_query_embedding vector DEFAULT NULL::vector,
  p_dias_mensagens integer DEFAULT 30
)
RETURNS json
LANGUAGE plpgsql
AS $$
DECLARE
  v_resultado JSON;
BEGIN
  SELECT json_build_object(
    'mentorado', (
      SELECT row_to_json(m.*)
      FROM (
        SELECT men.id, men.nome, men.telefone, men.estagio, men.nicho,
               men.produto_servico,
               COALESCE(mf.faturamento_atual, 0)  AS faturamento_atual,
               COALESCE(mf.meta_faturamento, 0)   AS meta_faturamento,
               men.perfil_negocio, men.principais_travas, men.frequencia_call
        FROM mentorados men
        LEFT JOIN case_archives.mentorados_financeiro mf ON mf.mentorado_id = men.id
        WHERE men.id = p_mentorado_id
      ) m
    ),
    'ultimas_calls', (
      SELECT COALESCE(json_agg(c.*), '[]'::json)
      FROM (
        SELECT call_id, data_call, tipo, duracao_minutos,
               principais_topicos, plano_acao, proximos_passos,
               transcript_resumido
        FROM buscar_resumo_calls(p_mentorado_id, 3)
      ) c
    ),
    'chunks_relevantes', (
      CASE WHEN p_query_embedding IS NOT NULL THEN
        (SELECT COALESCE(json_agg(s.*), '[]'::json)
         FROM (
           SELECT call_id, data_call, chunk_content, chunk_summary, similarity
           FROM buscar_calls_semantico(p_mentorado_id, p_query_embedding, 0.65, 5)
         ) s)
      ELSE '[]'::json
      END
    ),
    'mensagens_recentes', (
      SELECT COALESCE(json_agg(msg.*), '[]'::json)
      FROM (
        SELECT sender_name, timestamp, conteudo, eh_equipe,
               tipo_interacao, categoria
        FROM interacoes_mentoria
        WHERE mentorado_id = p_mentorado_id
          AND timestamp >= NOW() - (p_dias_mensagens || ' days')::INTERVAL
        ORDER BY timestamp DESC
        LIMIT 30
      ) msg
    ),
    'eventos_abertos', (
      SELECT COALESCE(json_agg(e.*), '[]'::json)
      FROM (
        SELECT tipo, titulo, descricao, status, prioridade,
               dias_sem_update, prazo_estimado
        FROM eventos_mentorados
        WHERE mentorado_id = p_mentorado_id
          AND status IN ('aberto', 'em_progresso', 'pendente')
        ORDER BY prioridade DESC, dias_sem_update DESC
        LIMIT 10
      ) e
    )
  ) INTO v_resultado;

  RETURN v_resultado;
END;
$$;

GRANT EXECUTE ON FUNCTION public.buscar_contexto_rag(bigint, vector, integer)
  TO authenticated, anon;

-- ============================================================
-- calcular_estagio_mentorado — substitui faturamento_atual
-- por subquery em case_archives.mentorados_financeiro
-- ============================================================
CREATE OR REPLACE FUNCTION public.calcular_estagio_mentorado(p_mentorado_id bigint)
RETURNS character varying
LANGUAGE plpgsql
AS $$
DECLARE
  v_dias_mentoria            INTEGER;
  v_faturamento              DECIMAL;
  v_direcionamentos_concluidos INTEGER;
  v_autonomia_score          DECIMAL;
BEGIN
  SELECT
    DATE_PART('day', NOW() - data_inicio),
    COALESCE(
      (SELECT faturamento_atual
       FROM case_archives.mentorados_financeiro
       WHERE mentorado_id = p_mentorado_id),
      0
    ),
    (SELECT COUNT(*) FROM direcionamentos
     WHERE mentorado_id = p_mentorado_id AND status = 'concluido')
  INTO v_dias_mentoria, v_faturamento, v_direcionamentos_concluidos
  FROM mentorados
  WHERE id = p_mentorado_id;

  v_autonomia_score :=
    (LEAST(v_dias_mentoria / 90.0, 1.0) * 30)
    + (LEAST(v_faturamento / 10000.0, 1.0) * 40)
    + (LEAST(v_direcionamentos_concluidos / 20.0, 1.0) * 30);

  RETURN CASE
    WHEN v_autonomia_score < 25 THEN 'iniciante'
    WHEN v_autonomia_score < 50 THEN 'em_desenvolvimento'
    WHEN v_autonomia_score < 75 THEN 'avancado'
    ELSE 'autonomo'
  END;
END;
$$;

GRANT EXECUTE ON FUNCTION public.calcular_estagio_mentorado(bigint)
  TO authenticated, anon;

-- ============================================================
-- get_stats_mentorado — substitui m.faturamento_atual/meta_faturamento
-- por LEFT JOIN case_archives.mentorados_financeiro
-- ============================================================
DROP FUNCTION IF EXISTS public.get_stats_mentorado(text) CASCADE;
CREATE OR REPLACE FUNCTION public.get_stats_mentorado(nome_busca text)
RETURNS TABLE(
  mentorado_nome        text,
  total_calls           bigint,
  ultima_call           timestamp with time zone,
  total_direcionamentos bigint,
  direcionamentos_abertos bigint,
  faturamento_atual     numeric,
  meta_faturamento      numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    m.nome::text,
    COUNT(DISTINCT c.id),
    MAX(c.data_inicio),
    COUNT(DISTINCT d.id),
    COUNT(DISTINCT CASE WHEN d.status IN ('aberto', 'em_andamento') THEN d.id END),
    COALESCE(mf.faturamento_atual, 0),
    COALESCE(mf.meta_faturamento, 0)
  FROM mentorados m
  LEFT JOIN case_archives.mentorados_financeiro mf ON mf.mentorado_id = m.id
  LEFT JOIN calls_mentoria c ON m.id = c.mentorado_id
  LEFT JOIN direcionamentos d ON m.id = d.mentorado_id
  WHERE m.nome ILIKE '%' || nome_busca || '%'
  GROUP BY m.id, m.nome, mf.faturamento_atual, mf.meta_faturamento
  LIMIT 1;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_stats_mentorado(text) TO authenticated, anon;

-- Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- Verificação
SELECT proname, pg_get_function_identity_arguments(oid) AS args
FROM pg_proc
WHERE proname IN ('buscar_contexto_rag', 'calcular_estagio_mentorado', 'get_stats_mentorado');
