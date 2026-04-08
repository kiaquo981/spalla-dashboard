-- Fix: SLA mostra "0m" e "Último contato: Agora" pra todos
-- Root cause: horas_sem_resposta_equipe usa ELSE 0 (sempre 0 se não tem pendência)
-- msgs_pendentes_resposta não filtrava eh_equipe

-- Recriar a CTE wa_stats na vw_god_overview com campos corretos
-- Adicionando: ultimo_contato_mentorado (última msg do mentorado, não da equipe)
-- Corrigindo: msgs_pendentes_resposta exclui eh_equipe
-- Corrigindo: horas_sem_resposta usa ELSE NULL em vez de ELSE 0

DROP VIEW IF EXISTS vw_god_overview CASCADE;

CREATE OR REPLACE VIEW vw_god_overview AS
WITH
wa_stats AS (
  SELECT
    i.mentorado_id,
    COUNT(*) FILTER (WHERE i.created_at >= NOW() - INTERVAL '7 days') AS whatsapp_7d,
    COUNT(*) FILTER (WHERE i.created_at >= NOW() - INTERVAL '30 days') AS whatsapp_30d,
    COUNT(*) AS whatsapp_total,
    -- Fix: exclui equipe da contagem de pendências
    COUNT(*) FILTER (
      WHERE i.requer_resposta = true AND i.respondido = false AND i.eh_equipe = false
    ) AS msgs_pendentes_resposta,
    -- Fix: NULL quando não tem pendência (não 0)
    MAX(
      CASE
        WHEN i.requer_resposta = true AND i.respondido = false AND i.eh_equipe = false
        THEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600
        ELSE NULL
      END
    ) AS horas_sem_resposta_equipe,
    -- Novo: última interação de qualquer lado
    MAX(i.created_at) AS ultima_interacao,
    -- Novo: última msg do mentorado (não equipe)
    MAX(i.created_at) FILTER (WHERE i.eh_equipe = false) AS ultimo_contato_mentorado,
    -- Novo: última msg da equipe
    MAX(i.created_at) FILTER (WHERE i.eh_equipe = true) AS ultimo_contato_equipe
  FROM interacoes_mentoria i
  WHERE i.mentorado_id IS NOT NULL
  GROUP BY i.mentorado_id
),
call_stats AS (
  SELECT
    cm.mentorado_id,
    MAX(COALESCE(cm.data_call, cm.created_at)) AS ultima_call_data
  FROM calls_mentoria cm
  GROUP BY cm.mentorado_id
),
tarefa_stats AS (
  SELECT mentorado_id,
    COUNT(*) FILTER (WHERE LOWER(status) = 'pendente') AS tarefas_pendentes_total,
    COUNT(*) FILTER (WHERE LOWER(status) = 'pendente' AND prazo IS NOT NULL AND prazo < NOW()) AS tarefas_atrasadas
  FROM (
    SELECT mentorado_id::integer, status, prazo FROM tarefas_acordadas
    UNION ALL
    SELECT mentorado_id::integer, status::text, prazo::timestamptz FROM tarefas_equipe WHERE mentorado_id IS NOT NULL
  ) all_tasks GROUP BY mentorado_id
)
SELECT
  m.id, m.nome, m.instagram, m.cohort, m.trilha,
  m.fase_jornada, m.sub_etapa, m.marco_atual, m.risco_churn,
  m.score_engajamento AS engagement_score, m.score_implementacao AS implementation_score,
  m.faturamento_atual, m.meta_faturamento,
  CASE
    WHEN m.meta_faturamento IS NOT NULL AND m.meta_faturamento > 0
    THEN ROUND((COALESCE(m.faturamento_atual, 0) / m.meta_faturamento * 100)::numeric, 1)
    ELSE 0
  END AS pct_meta_atingida,
  m.qtd_vendas_total,
  m.contrato_assinado, m.status_financeiro, m.valor_contrato,
  m.consultor_responsavel,
  m.data_inicio AS data_entrada,
  -- WA stats
  COALESCE(wa.whatsapp_7d, 0) AS whatsapp_7d,
  COALESCE(wa.whatsapp_30d, 0) AS whatsapp_30d,
  COALESCE(wa.whatsapp_total, 0) AS whatsapp_total,
  COALESCE(wa.msgs_pendentes_resposta, 0) AS msgs_pendentes_resposta,
  wa.horas_sem_resposta_equipe,
  wa.ultima_interacao,
  wa.ultimo_contato_mentorado,
  wa.ultimo_contato_equipe,
  -- Calls
  cs.ultima_call_data,
  CASE
    WHEN cs.ultima_call_data IS NOT NULL
    THEN EXTRACT(DAY FROM (NOW() - cs.ultima_call_data))::integer
    ELSE NULL
  END AS dias_desde_call,
  -- Tarefas
  COALESCE(ts.tarefas_pendentes_total, 0) AS tarefas_pendentes,
  COALESCE(ts.tarefas_atrasadas, 0) AS tarefas_atrasadas
FROM mentorados m
LEFT JOIN wa_stats wa ON wa.mentorado_id = m.id
LEFT JOIN call_stats cs ON cs.mentorado_id = m.id
LEFT JOIN tarefa_stats ts ON ts.mentorado_id = m.id
WHERE m.ativo = true
  AND m.cohort IS DISTINCT FROM 'tese';
