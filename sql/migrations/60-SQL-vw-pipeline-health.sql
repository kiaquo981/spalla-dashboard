-- ============================================================
-- Spalla Dashboard — View: Pipeline Health
-- 2026-03-16
-- ============================================================
-- Consolida health do pipeline em uma única query.
-- Usada pelo dashboard para mostrar status do pipeline.
-- ============================================================

CREATE OR REPLACE VIEW vw_pipeline_health AS
SELECT
  (SELECT COUNT(*) FROM interacoes_mentoria
   WHERE created_at > NOW() - INTERVAL '24 hours') AS msgs_24h,

  (SELECT COUNT(*) FROM interacoes_mentoria
   WHERE created_at > NOW() - INTERVAL '1 hour') AS msgs_1h,

  (SELECT COUNT(*) FROM wa_dead_letter_queue
   WHERE status = 'pending') AS dlq_pending,

  (SELECT COUNT(*) FROM interacoes_mentoria
   WHERE eh_equipe IS NULL
     AND created_at > NOW() - INTERVAL '7 days') AS null_eh_equipe_7d,

  (SELECT COUNT(*) FROM interacoes_mentoria
   WHERE requer_resposta IS NULL
     AND created_at > NOW() - INTERVAL '7 days') AS null_requer_resposta_7d,

  (SELECT COUNT(*) FROM vw_god_pendencias) AS pendencias_total,

  (SELECT COUNT(*) FROM vw_god_pendencias
   WHERE horas_pendente > 24) AS pendencias_criticas,

  (SELECT MAX(created_at) FROM interacoes_mentoria) AS ultima_msg_recebida,

  (SELECT ROUND(EXTRACT(EPOCH FROM (NOW() - MAX(created_at))) / 60)
   FROM interacoes_mentoria) AS minutos_sem_msg;

GRANT SELECT ON vw_pipeline_health TO authenticated, anon;
