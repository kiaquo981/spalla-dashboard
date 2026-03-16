-- ============================================================
-- Spalla Dashboard — Dead Letter Queue para Pipeline WhatsApp
-- 2026-03-16
-- ============================================================
-- Mensagens que falham no pipeline (GPT timeout, Supabase error)
-- são salvas aqui em vez de desaparecer silenciosamente.
-- ============================================================

CREATE TABLE IF NOT EXISTS wa_dead_letter_queue (
  id             BIGSERIAL PRIMARY KEY,
  message_id     TEXT,
  raw_payload    JSONB NOT NULL,
  error_message  TEXT,
  error_node     TEXT,
  pipeline_stage TEXT,
  retry_count    INT DEFAULT 0,
  status         TEXT DEFAULT 'pending'
                   CHECK (status IN ('pending', 'retried', 'resolved', 'abandoned')),
  created_at     TIMESTAMPTZ DEFAULT NOW(),
  resolved_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_dlq_status
  ON wa_dead_letter_queue(status) WHERE status = 'pending';

CREATE INDEX IF NOT EXISTS idx_dlq_created
  ON wa_dead_letter_queue(created_at DESC);

GRANT ALL ON wa_dead_letter_queue TO authenticated;
GRANT ALL ON wa_dead_letter_queue TO anon;
GRANT USAGE, SELECT ON SEQUENCE wa_dead_letter_queue_id_seq TO authenticated, anon;
