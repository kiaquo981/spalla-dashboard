-- ORCH-07: Agent Metrics View
-- Aggregates task stats per agent member for dashboard

CREATE OR REPLACE VIEW vw_agent_metrics AS
SELECT
  m.id AS agent_id,
  m.nome_curto AS agent_name,
  m.cor,
  m.max_concurrent_tasks,
  m.execution_endpoint,
  COUNT(*) FILTER (WHERE t.status = 'em_andamento') AS tasks_em_andamento,
  COUNT(*) FILTER (WHERE t.status = 'pendente') AS tasks_pendentes,
  COUNT(*) FILTER (WHERE t.status = 'concluida' AND t.updated_at > NOW() - INTERVAL '7 days') AS concluidas_7d,
  COUNT(*) FILTER (WHERE t.status = 'concluida' AND t.updated_at > NOW() - INTERVAL '30 days') AS concluidas_30d,
  COUNT(*) FILTER (WHERE t.status = 'concluida') AS concluidas_total,
  ROUND(AVG(EXTRACT(EPOCH FROM (t.updated_at - t.created_at)) / 3600)
    FILTER (WHERE t.status = 'concluida'), 1) AS avg_horas_conclusao,
  COUNT(*) FILTER (WHERE t.status IN ('bloqueada','cancelada')) AS falhas_total,
  COUNT(*) AS tasks_total
FROM spalla_members m
LEFT JOIN god_tasks t ON t.responsavel = m.id OR LOWER(t.responsavel) = LOWER(m.nome_curto)
WHERE m.tipo = 'agent'
GROUP BY m.id, m.nome_curto, m.cor, m.max_concurrent_tasks, m.execution_endpoint;

-- RLS: allow anon read
GRANT SELECT ON vw_agent_metrics TO anon, authenticated;
