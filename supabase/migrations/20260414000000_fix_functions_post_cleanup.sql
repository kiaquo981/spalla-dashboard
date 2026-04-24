-- Fix: fn_god_mentorado_deep + fn_god_alerts pós-cleanup 2026-04-14
-- Problema: funções referenciam colunas dropadas nas fases 1-3 da limpeza do schema
--   - marco_atual, score_engajamento, score_implementacao (dropadas Fase 2)
--   - faturamento_atual, meta_faturamento, faturamento_mentoria (migradas pra case_archives Fase 3)
--   - engagement_score, implementation_score em vw_god_overview (removidas)

-- ============================================================
-- fn_god_mentorado_deep — recreada sem colunas removidas
-- ============================================================
DROP FUNCTION IF EXISTS fn_god_mentorado_deep(integer) CASCADE;
DROP FUNCTION IF EXISTS fn_god_mentorado_deep(bigint) CASCADE;
CREATE OR REPLACE FUNCTION fn_god_mentorado_deep(p_id bigint)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result jsonb;
BEGIN
  SELECT jsonb_build_object(
    -- PERFIL
    'profile', (
      SELECT jsonb_build_object(
        'id', m.id,
        'nome', m.nome,
        'instagram', m.instagram,
        'cidade', m.cidade,
        'estado', m.estado,
        'email', m.email,
        'telefone', m.telefone,
        'cohort', m.cohort,
        'nicho', m.nicho,
        'data_inicio', m.data_inicio,
        'perfil_negocio', m.perfil_negocio,
        'frequencia_call', m.frequencia_call,
        'proxima_call', m.proxima_call_agendada
      )
      FROM mentorados m WHERE m.id = p_id
    ),

    -- FASE + MARCOS (marco_atual/score_* removidos — retorna null para compat)
    'phase', (
      SELECT jsonb_build_object(
        'fase_jornada', m.fase_jornada,
        'sub_etapa', m.sub_etapa,
        'marco_atual', NULL,
        'risco_churn', m.risco_churn,
        'engagement_score', NULL,
        'implementation_score', NULL,
        'health', CASE
          WHEN m.risco_churn = 'critico' THEN 'critico'
          WHEN m.risco_churn = 'alto' THEN 'atrasado'
          ELSE 'on_track'
        END,
        'marcos_atingidos', COALESCE(
          (SELECT jsonb_agg(jsonb_build_object(
            'marco', mm.marco, 'fase', mm.fase,
            'data', mm.data_atingido, 'evidencia', mm.evidencia
          ) ORDER BY mm.created_at)
          FROM marcos_mentorado mm WHERE mm.mentorado_id = p_id),
          '[]'::jsonb
        )
      )
      FROM mentorados m WHERE m.id = p_id
    ),

    -- FINANCEIRO — agora lê de case_archives.mentorados_financeiro
    'financial', (
      SELECT jsonb_build_object(
        'faturamento_atual', COALESCE(mf.faturamento_atual, 0),
        'meta_faturamento', COALESCE(mf.meta_faturamento, 0),
        'pct_meta_atingida', CASE
          WHEN mf.meta_faturamento > 0 AND mf.faturamento_atual > 0
          THEN ROUND((mf.faturamento_atual / mf.meta_faturamento) * 100, 1)
          ELSE 0
        END,
        'faturamento_mentoria', COALESCE(mf.faturamento_mentoria, 0),
        'qtd_vendas_total', COALESCE(m.qtd_vendas_total, 0),
        'ticket_produto', m.ticket_produto,
        'ja_vendeu', m.ja_vendeu,
        'tem_produto', m.tem_produto,
        'status_financeiro', mf.status_financeiro,
        'contrato_assinado', mf.contrato_assinado,
        'valor_contrato', mf.valor_contrato,
        'parcelas_pagas', mf.parcelas_pagas,
        'parcelas_total', mf.parcelas_total
      )
      FROM mentorados m
      LEFT JOIN case_archives.mentorados_financeiro mf ON mf.mentorado_id = m.id
      WHERE m.id = p_id
    ),

    -- CONTEXTO IA (via view simplificada)
    'context_ia', (
      SELECT row_to_json(ctx)::jsonb
      FROM vw_god_contexto_ia ctx
      WHERE ctx.mentorado_id = p_id
    ),

    -- ULTIMAS 5 CALLS (via view enxuta)
    'last_calls', COALESCE(
      (SELECT jsonb_agg(row_to_json(c)::jsonb ORDER BY c.data_call DESC)
       FROM (
         SELECT * FROM vw_god_calls gc
         WHERE gc.mentorado_id = p_id
         ORDER BY gc.data_call DESC NULLS LAST
         LIMIT 5
       ) c),
      '[]'::jsonb
    ),

    -- ULTIMAS 5 MSGS WHATSAPP
    'last_messages', COALESCE(
      (SELECT jsonb_agg(jsonb_build_object(
        'conteudo', LEFT(i.conteudo, 300),
        'sender', i.sender_name,
        'tipo', i.message_type,
        'requer_resposta', i.requer_resposta,
        'respondido', i.respondido,
        'created_at', i.created_at
       ) ORDER BY i.created_at DESC)
       FROM (
         SELECT *
         FROM interacoes_mentoria ix
         WHERE ix.mentorado_id = p_id
         ORDER BY ix.created_at DESC
         LIMIT 5
       ) i),
      '[]'::jsonb
    ),

    -- TAREFAS PENDENTES
    'pending_tasks', COALESCE(
      (SELECT jsonb_agg(jsonb_build_object(
        'tarefa', t.tarefa,
        'responsavel', t.responsavel,
        'prioridade', t.prioridade,
        'prazo', t.prazo,
        'fonte', t.fonte,
        'data_criacao', t.data_criacao
       ) ORDER BY t.data_criacao DESC)
       FROM vw_god_tarefas t
       WHERE t.mentorado_id = p_id
         AND LOWER(t.status) IN ('pendente', 'em_andamento')
       ),
      '[]'::jsonb
    ),

    -- TRAVAS ATIVAS
    'blockers', COALESCE(
      (SELECT jsonb_agg(jsonb_build_object(
        'tipo', tb.tipo,
        'area', tb.area,
        'descricao', tb.descricao,
        'frequencia', tb.frequencia,
        'primeira_mencao', tb.primeira_mencao,
        'ultima_mencao', tb.ultima_mencao
       ))
       FROM travas_bloqueios tb
       WHERE tb.mentorado_id = p_id AND tb.resolvido = false),
      '[]'::jsonb
    ),

    -- ULTIMOS 10 DIRECIONAMENTOS
    'directions', COALESCE(
      (SELECT jsonb_agg(row_to_json(d)::jsonb ORDER BY d.data DESC)
       FROM (
         SELECT * FROM vw_god_direcionamentos gd
         WHERE gd.mentorado_id = p_id
         ORDER BY gd.data DESC
         LIMIT 10
       ) d),
      '[]'::jsonb
    )
  ) INTO result;

  RETURN result;
END;
$$;

GRANT EXECUTE ON FUNCTION fn_god_mentorado_deep(bigint) TO authenticated, anon;

-- ============================================================
-- fn_god_alerts — remove refs a engagement_score/implementation_score
-- que não existem mais em vw_god_overview
-- ============================================================
DROP FUNCTION IF EXISTS fn_god_alerts CASCADE;
CREATE OR REPLACE FUNCTION fn_god_alerts()
RETURNS TABLE (
  alerta_tipo text,
  severidade text,
  mentorado_id integer,
  mentorado_nome text,
  descricao text,
  valor_referencia text,
  data_referencia timestamptz
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
  RETURN QUERY
  SELECT
    q.a_tipo,
    q.a_sev,
    q.a_mid,
    q.a_nome,
    q.a_desc,
    q.a_val,
    q.a_data
  FROM (

    -- 1. Msgs sem resposta >12h
    SELECT
      'sem_resposta'::text AS a_tipo,
      CASE
        WHEN gp.horas_pendente > 48 THEN 'critico'
        WHEN gp.horas_pendente > 24 THEN 'alto'
        ELSE 'medio'
      END::text AS a_sev,
      gp.mentorado_id::integer AS a_mid,
      gp.mentorado_nome::text AS a_nome,
      ('Mensagem pendente ha ' || ROUND(gp.horas_pendente) || 'h')::text AS a_desc,
      gp.horas_pendente::text AS a_val,
      gp.created_at AS a_data
    FROM vw_god_pendencias gp
    WHERE gp.horas_pendente > 12

    UNION ALL

    -- 2. Sem call >21 dias ou nunca fez call
    SELECT
      'sem_call'::text,
      CASE
        WHEN go2.dias_desde_call > 30 THEN 'critico'
        WHEN go2.dias_desde_call > 21 THEN 'alto'
        WHEN go2.ultima_call_data IS NULL THEN 'alto'
        ELSE 'medio'
      END::text,
      go2.id::integer,
      go2.nome::text,
      CASE
        WHEN go2.ultima_call_data IS NULL THEN 'Nunca fez call individual'
        ELSE 'Sem call ha ' || go2.dias_desde_call || ' dias'
      END::text,
      COALESCE(go2.dias_desde_call::text, 'N/A'),
      go2.ultima_call_data
    FROM vw_god_overview go2
    WHERE go2.dias_desde_call > 21
       OR go2.ultima_call_data IS NULL

    UNION ALL

    -- 3. Tarefas atrasadas (>2)
    SELECT
      'tarefas_atrasadas'::text,
      CASE
        WHEN go3.tarefas_atrasadas > 5 THEN 'critico'
        WHEN go3.tarefas_atrasadas > 3 THEN 'alto'
        ELSE 'medio'
      END::text,
      go3.id::integer,
      go3.nome::text,
      (go3.tarefas_atrasadas || ' tarefas atrasadas')::text,
      go3.tarefas_atrasadas::text,
      NULL::timestamptz
    FROM vw_god_overview go3
    WHERE go3.tarefas_atrasadas > 2

    UNION ALL

    -- 4. Risco critico/alto (score_* removidos — alert sem breakdown de score)
    SELECT
      'risco_churn'::text,
      go4.risco_churn::text,
      go4.id::integer,
      go4.nome::text,
      ('Risco ' || go4.risco_churn)::text,
      go4.risco_churn::text,
      NULL::timestamptz
    FROM vw_god_overview go4
    WHERE go4.risco_churn IN ('critico', 'alto')

    UNION ALL

    -- 5. Sem WhatsApp >7 dias
    SELECT
      'sem_whatsapp'::text,
      CASE
        WHEN go5.whatsapp_7d = 0 AND go5.whatsapp_30d = 0 THEN 'alto'
        WHEN go5.whatsapp_7d = 0 THEN 'medio'
        ELSE 'baixo'
      END::text,
      go5.id::integer,
      go5.nome::text,
      ('Sem atividade WhatsApp ha >7 dias')::text,
      go5.whatsapp_7d::text,
      NULL::timestamptz
    FROM vw_god_overview go5
    WHERE go5.whatsapp_7d = 0
      AND go5.whatsapp_total > 0

  ) q
  ORDER BY
    CASE q.a_sev
      WHEN 'critico' THEN 1
      WHEN 'alto' THEN 2
      WHEN 'medio' THEN 3
      ELSE 4
    END,
    q.a_data ASC NULLS LAST;
END;
$$;

GRANT EXECUTE ON FUNCTION fn_god_alerts() TO authenticated, anon;

-- Verificação
SELECT proname, pronargs FROM pg_proc WHERE proname IN ('fn_god_mentorado_deep', 'fn_god_alerts');
