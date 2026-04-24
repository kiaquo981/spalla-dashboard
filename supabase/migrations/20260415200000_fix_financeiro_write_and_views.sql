-- Fix: escrita financeira + aliases de views + data_primeiro_pagamento
-- Contexto: cleanup 2026-04-14 moveu campos financeiros para case_archives.mentorados_financeiro
-- O frontend ainda tentava escrever direto em mentorados + ler views/tabelas com nomes antigos

-- ============================================================
-- 1. Adicionar data_primeiro_pagamento em case_archives.mentorados_financeiro
-- ============================================================
ALTER TABLE case_archives.mentorados_financeiro
  ADD COLUMN IF NOT EXISTS data_primeiro_pagamento date;

-- ============================================================
-- 2. fn_update_mentorado_financeiro — função SECURITY DEFINER
-- Permite que authenticated/anon atualizem campos financeiros
-- sem precisar de GRANT UPDATE direto em case_archives
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_update_mentorado_financeiro(
  p_mentorado_id  bigint,
  p_field         text,
  p_value         text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, case_archives
AS $$
DECLARE
  ALLOWED_FIELDS text[] := ARRAY[
    'valor_contrato', 'parcelas_total', 'parcelas_pagas', 'dia_pagamento',
    'status_financeiro', 'contrato_assinado', 'data_contrato_assinado',
    'condicao_acordada', 'faturamento_mentoria', 'faturamento_inicial',
    'faturamento_atual', 'meta_faturamento', 'data_primeiro_pagamento'
  ];
BEGIN
  IF p_field != ALL(ALLOWED_FIELDS) THEN
    RETURN jsonb_build_object('error', 'Campo não permitido: ' || p_field);
  END IF;

  -- Garantir que o registro existe (upsert)
  INSERT INTO case_archives.mentorados_financeiro (mentorado_id)
  VALUES (p_mentorado_id)
  ON CONFLICT (mentorado_id) DO NOTHING;

  -- Atualizar o campo dinamicamente via %L (PostgreSQL faz implicit cast text → tipo da coluna)
  EXECUTE format(
    'UPDATE case_archives.mentorados_financeiro SET %I = %L WHERE mentorado_id = %s',
    p_field, p_value, p_mentorado_id
  );

  RETURN jsonb_build_object('success', true, 'field', p_field);
END;
$$;

GRANT EXECUTE ON FUNCTION public.fn_update_mentorado_financeiro(bigint, text, text)
  TO authenticated, anon;

-- ============================================================
-- 3. View alias: vw_fin_snapshots → god_financial_snapshots
-- ============================================================
CREATE OR REPLACE VIEW public.vw_fin_snapshots AS
  SELECT * FROM public.god_financial_snapshots;

GRANT SELECT ON public.vw_fin_snapshots TO authenticated, anon;

-- ============================================================
-- 4. View alias: fin_pagamento_logs → god_financial_logs
-- ============================================================
CREATE OR REPLACE VIEW public.fin_pagamento_logs AS
  SELECT
    id,
    mentorado_id,
    old_status,
    new_status,
    action_type,
    observacao,
    changed_by,
    changed_by_user_id,
    created_at
  FROM public.god_financial_logs;

GRANT SELECT ON public.fin_pagamento_logs TO authenticated, anon;

-- ============================================================
-- 5. Atualizar fn_god_mentorado_deep para incluir data_primeiro_pagamento
-- ============================================================
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

    -- FASE + MARCOS
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

    -- FINANCEIRO — via case_archives.mentorados_financeiro
    'financial', (
      SELECT jsonb_build_object(
        'faturamento_atual',        COALESCE(mf.faturamento_atual, 0),
        'meta_faturamento',         COALESCE(mf.meta_faturamento, 0),
        'pct_meta_atingida', CASE
          WHEN mf.meta_faturamento > 0 AND mf.faturamento_atual > 0
          THEN ROUND((mf.faturamento_atual / mf.meta_faturamento) * 100, 1)
          ELSE 0
        END,
        'faturamento_mentoria',     COALESCE(mf.faturamento_mentoria, 0),
        'faturamento_inicial',      COALESCE(mf.faturamento_inicial, 0),
        'qtd_vendas_total',         COALESCE(m.qtd_vendas_total, 0),
        'ticket_produto',           m.ticket_produto,
        'ja_vendeu',                m.ja_vendeu,
        'tem_produto',              m.tem_produto,
        'status_financeiro',        mf.status_financeiro,
        'contrato_assinado',        mf.contrato_assinado,
        'valor_contrato',           mf.valor_contrato,
        'parcelas_pagas',           mf.parcelas_pagas,
        'parcelas_total',           mf.parcelas_total,
        'dia_pagamento',            mf.dia_pagamento,
        'condicao_acordada',        mf.condicao_acordada,
        'data_contrato_assinado',   mf.data_contrato_assinado,
        'data_primeiro_pagamento',  mf.data_primeiro_pagamento
      )
      FROM mentorados m
      LEFT JOIN case_archives.mentorados_financeiro mf ON mf.mentorado_id = m.id
      WHERE m.id = p_id
    ),

    -- CONTEXTO IA
    'context_ia', (
      SELECT row_to_json(ctx)::jsonb
      FROM vw_god_contexto_ia ctx
      WHERE ctx.mentorado_id = p_id
    ),

    -- ULTIMAS 5 CALLS
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

-- Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- Verificação final
SELECT
  (SELECT COUNT(*) FROM pg_proc WHERE proname = 'fn_update_mentorado_financeiro') AS fn_update_ok,
  (SELECT COUNT(*) FROM pg_views WHERE viewname = 'vw_fin_snapshots' AND schemaname = 'public') AS snap_view_ok,
  (SELECT COUNT(*) FROM pg_views WHERE viewname = 'fin_pagamento_logs' AND schemaname = 'public') AS logs_view_ok,
  (SELECT COUNT(*) FROM information_schema.columns
   WHERE table_schema = 'case_archives' AND table_name = 'mentorados_financeiro'
   AND column_name = 'data_primeiro_pagamento') AS new_col_ok;
