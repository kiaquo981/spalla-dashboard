-- =============================================================================
-- MIGRATION 67: Fix call_stats to use COALESCE(data_call, created_at)
-- =============================================================================
-- Problem: Many calls_mentoria rows have data_call=NULL (inserted by Zoom
--          webhook without date). The view ignores these, showing "Sem call"
--          for mentees who actually had calls.
-- Fix: Use created_at as fallback when data_call is NULL.
-- =============================================================================

CREATE OR REPLACE VIEW vw_god_overview AS
WITH
-- WhatsApp stats
wa_stats AS (
  SELECT
    i.mentorado_id,
    COUNT(*) FILTER (WHERE i.created_at >= NOW() - INTERVAL '7 days') AS whatsapp_7d,
    COUNT(*) FILTER (WHERE i.created_at >= NOW() - INTERVAL '30 days') AS whatsapp_30d,
    COUNT(*) AS whatsapp_total,
    COUNT(*) FILTER (
      WHERE i.requer_resposta = true AND i.respondido = false
    ) AS msgs_pendentes_resposta,
    MAX(
      CASE
        WHEN i.requer_resposta = true AND i.respondido = false AND i.eh_equipe = false
        THEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600
        ELSE 0
      END
    ) AS horas_sem_resposta_equipe
  FROM interacoes_mentoria i
  WHERE i.mentorado_id IS NOT NULL
  GROUP BY i.mentorado_id
),
-- Call stats (ultima call — usa data_call, fallback pra created_at)
call_stats AS (
  SELECT
    cm.mentorado_id,
    MAX(COALESCE(cm.data_call, cm.created_at)) AS ultima_call_data
  FROM calls_mentoria cm
  GROUP BY cm.mentorado_id
),
-- Tarefas stats
tarefa_stats AS (
  SELECT
    mentorado_id,
    COUNT(*) FILTER (WHERE LOWER(status) = 'pendente') AS tarefas_pendentes_total,
    COUNT(*) FILTER (
      WHERE LOWER(status) = 'pendente'
        AND prazo IS NOT NULL AND prazo < NOW()
    ) AS tarefas_atrasadas
  FROM (
    SELECT mentorado_id::integer AS mentorado_id, status, prazo
    FROM tarefas_acordadas
    UNION ALL
    SELECT mentorado_id::integer, status::text, prazo::timestamptz
    FROM tarefas_equipe
    WHERE mentorado_id IS NOT NULL
  ) all_tasks
  GROUP BY mentorado_id
)
SELECT
  m.id,
  m.nome,
  m.instagram,
  m.cohort,
  m.fase_jornada,
  m.sub_etapa,
  m.marco_atual,
  m.risco_churn,
  m.score_engajamento AS engagement_score,
  m.score_implementacao AS implementation_score,
  m.faturamento_atual,
  m.meta_faturamento,
  CASE
    WHEN m.meta_faturamento > 0 AND m.faturamento_atual > 0
    THEN ROUND((m.faturamento_atual / m.meta_faturamento) * 100, 1)
    ELSE 0
  END AS pct_meta_atingida,
  m.qtd_vendas_total,
  m.ja_vendeu,
  COALESCE(wa.whatsapp_7d, 0)::integer AS whatsapp_7d,
  COALESCE(wa.whatsapp_30d, 0)::integer AS whatsapp_30d,
  COALESCE(wa.whatsapp_total, 0)::integer AS whatsapp_total,
  COALESCE(wa.msgs_pendentes_resposta, 0)::integer AS msgs_pendentes_resposta,
  ROUND(COALESCE(wa.horas_sem_resposta_equipe, 0)::numeric, 1) AS horas_sem_resposta_equipe,
  cs.ultima_call_data,
  CASE
    WHEN cs.ultima_call_data IS NOT NULL
    THEN EXTRACT(DAY FROM (NOW() - cs.ultima_call_data))::integer
    ELSE NULL
  END AS dias_desde_call,
  COALESCE(ts.tarefas_pendentes_total, 0)::integer AS tarefas_pendentes,
  COALESCE(ts.tarefas_atrasadas, 0)::integer AS tarefas_atrasadas,
  COALESCE(m.contrato_assinado, true) AS contrato_assinado,
  COALESCE(m.status_financeiro, 'em_dia') AS status_financeiro,
  m.dia_pagamento,
  m.grupo_whatsapp_id,
  m.consultor_responsavel
FROM mentorados m
LEFT JOIN wa_stats wa ON wa.mentorado_id = m.id
LEFT JOIN call_stats cs ON cs.mentorado_id = m.id
LEFT JOIN tarefa_stats ts ON ts.mentorado_id = m.id
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'
ORDER BY
  CASE m.fase_jornada
    WHEN 'escala' THEN 1
    WHEN 'otimizacao' THEN 2
    WHEN 'validacao' THEN 3
    WHEN 'concepcao' THEN 4
    WHEN 'onboarding' THEN 5
    ELSE 6
  END,
  m.nome;

GRANT SELECT ON vw_god_overview TO authenticated, anon;
