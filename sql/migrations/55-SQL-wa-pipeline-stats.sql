-- ============================================================
-- Spalla Dashboard — Pipeline Stats (contadores diários)
-- 2026-03-16
-- ============================================================

CREATE TABLE IF NOT EXISTS wa_pipeline_stats (
  id                      BIGSERIAL PRIMARY KEY,
  stat_date               DATE NOT NULL DEFAULT CURRENT_DATE,
  msgs_received           INT DEFAULT 0,
  msgs_classified         INT DEFAULT 0,
  msgs_saved              INT DEFAULT 0,
  msgs_failed             INT DEFAULT 0,
  classification_fallbacks INT DEFAULT 0,
  dlq_entries             INT DEFAULT 0,
  UNIQUE(stat_date)
);

-- Helper: incrementar stat do dia atual
CREATE OR REPLACE FUNCTION increment_pipeline_stat(p_field TEXT, p_increment INT DEFAULT 1)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO wa_pipeline_stats (stat_date)
  VALUES (CURRENT_DATE)
  ON CONFLICT (stat_date) DO NOTHING;

  EXECUTE format(
    'UPDATE wa_pipeline_stats SET %I = %I + $1 WHERE stat_date = CURRENT_DATE',
    p_field, p_field
  ) USING p_increment;
END;
$$;

GRANT ALL ON wa_pipeline_stats TO authenticated, anon;
GRANT USAGE, SELECT ON SEQUENCE wa_pipeline_stats_id_seq TO authenticated, anon;
GRANT EXECUTE ON FUNCTION increment_pipeline_stat(TEXT, INT) TO authenticated, anon;
