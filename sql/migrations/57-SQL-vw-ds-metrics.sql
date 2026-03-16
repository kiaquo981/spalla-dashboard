-- =====================================================
-- DS-18: View de métricas de produção
-- =====================================================

CREATE OR REPLACE VIEW vw_ds_metrics AS
WITH producao_stats AS (
  SELECT status, COUNT(*) as count
  FROM ds_producoes
  GROUP BY status
),
estagio_stats AS (
  SELECT estagio_atual, COUNT(*) as count
  FROM ds_documentos
  GROUP BY estagio_atual
),
avg_time AS (
  SELECT
    estagio_atual,
    (AVG(EXTRACT(EPOCH FROM now() - estagio_desde)) / 86400)::INT AS avg_dias
  FROM ds_documentos
  WHERE estagio_atual NOT IN ('pendente', 'finalizado')
  GROUP BY estagio_atual
),
bottleneck AS (
  SELECT COUNT(*) AS docs_parados
  FROM ds_documentos
  WHERE estagio_atual NOT IN ('finalizado', 'enviado', 'pendente')
    AND EXTRACT(EPOCH FROM now() - estagio_desde) / 86400 > 3
),
throughput AS (
  SELECT COUNT(*) AS enviados_30d
  FROM ds_documentos
  WHERE estagio_atual = 'enviado'
    AND data_envio >= now() - INTERVAL '30 days'
)
SELECT
  (SELECT json_agg(json_build_object('status', status, 'count', count)) FROM producao_stats) AS producao_por_status,
  (SELECT json_agg(json_build_object('estagio', estagio_atual, 'count', count)) FROM estagio_stats) AS docs_por_estagio,
  (SELECT json_agg(json_build_object('estagio', estagio_atual, 'avg_dias', avg_dias)) FROM avg_time) AS tempo_medio_por_estagio,
  (SELECT docs_parados FROM bottleneck) AS docs_bottleneck,
  (SELECT enviados_30d FROM throughput) AS throughput_30d;

-- Rollback: DROP VIEW IF EXISTS vw_ds_metrics;
