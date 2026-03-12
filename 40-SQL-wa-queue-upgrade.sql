-- ============================================================
-- Spalla Dashboard — WA Queue Upgrade: Dead Letter + Recovery
-- 2026-03-11
-- ============================================================

-- 1. Expandir constraint de status para incluir dead_letter
ALTER TABLE wa_message_queue DROP CONSTRAINT IF EXISTS wa_message_queue_status_check;
ALTER TABLE wa_message_queue ADD CONSTRAINT wa_message_queue_status_check
  CHECK (status IN ('pending','processing','done','error','skipped','dead_letter'));

-- 2. Adicionar coluna de dead letter tracking
ALTER TABLE wa_message_queue ADD COLUMN IF NOT EXISTS dead_letter_at TIMESTAMPTZ;

-- 3. Índice para recovery (busca stuck items)
CREATE INDEX IF NOT EXISTS idx_wa_queue_recovery
  ON wa_message_queue (status, created_at)
  WHERE status IN ('processing','error');

-- 4. Função de recovery automático
-- Chamada pelo N8N Recovery workflow a cada 5 min
-- POST /rest/v1/rpc/recover_stuck_queue
CREATE OR REPLACE FUNCTION recover_stuck_queue(
  p_stuck_minutes INT DEFAULT 5,
  p_max_retries   INT DEFAULT 3
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_reset INT;
  v_dead  INT;
  v_dead_ids UUID[];
BEGIN
  -- ETAPA 1: Reset itens travados em 'processing' há mais de X minutos
  -- (n8n crashou ou timeout — item nunca foi marcado como done/error)
  WITH reset AS (
    UPDATE wa_message_queue
    SET
      status      = 'pending',
      retry_count = retry_count + 1,
      error_msg   = COALESCE(error_msg, '') || ' | recovery_reset:' || now()::text
    WHERE status = 'processing'
      AND created_at < now() - (p_stuck_minutes || ' minutes')::interval
    RETURNING id
  )
  SELECT COUNT(*) INTO v_reset FROM reset;

  -- ETAPA 2: Mover itens com erro excessivo para dead_letter
  WITH dead AS (
    UPDATE wa_message_queue
    SET
      status         = 'dead_letter',
      dead_letter_at = now(),
      error_msg      = COALESCE(error_msg, '') || ' | dead_letter:' || now()::text
    WHERE status = 'error'
      AND retry_count >= p_max_retries
    RETURNING id
  )
  SELECT COUNT(*), ARRAY_AGG(id) INTO v_dead, v_dead_ids FROM dead;

  RETURN jsonb_build_object(
    'reset_to_pending',      v_reset,
    'moved_to_dead_letter',  v_dead,
    'dead_letter_ids',       COALESCE(to_jsonb(v_dead_ids), '[]'::jsonb),
    'ran_at',                now()
  );
END;
$$;

GRANT EXECUTE ON FUNCTION recover_stuck_queue(INT, INT) TO service_role;
GRANT EXECUTE ON FUNCTION recover_stuck_queue(INT, INT) TO authenticated;

-- 5. View para monitoramento da fila no Spalla
DROP VIEW IF EXISTS vw_wa_queue_status;
CREATE VIEW vw_wa_queue_status AS
SELECT
  status,
  COUNT(*)                                    AS total,
  MIN(created_at)                             AS oldest,
  MAX(created_at)                             AS newest,
  AVG(retry_count)::NUMERIC(3,1)              AS avg_retries,
  COUNT(*) FILTER (WHERE retry_count > 0)     AS with_retries
FROM wa_message_queue
GROUP BY status
ORDER BY
  CASE status
    WHEN 'processing'  THEN 1
    WHEN 'error'       THEN 2
    WHEN 'pending'     THEN 3
    WHEN 'dead_letter' THEN 4
    WHEN 'done'        THEN 5
    ELSE 6
  END;
