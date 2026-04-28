-- Tabela de log/dedup do cron Calendar -> ClickUp.
-- Cada evento do Google Calendar processado pelo cron grava 1 linha aqui pra
-- evitar reprocessamento na proxima execucao. Tambem serve de auditoria.

CREATE TABLE IF NOT EXISTS public.cron_calendar_sync_log (
  gcal_event_id     TEXT PRIMARY KEY,
  gcal_summary      TEXT,
  gcal_organizer    TEXT,
  mentee_name       TEXT,
  matched_list_id   TEXT,
  tipo              TEXT,
  clickup_task_id   TEXT,
  clickup_task_url  TEXT,
  status            TEXT NOT NULL,
    -- 'synced' | 'skipped_no_match' | 'skipped_tipo' | 'skipped_no_list' | 'error'
  status_reason     TEXT,
  source            TEXT NOT NULL DEFAULT 'cron_calendar',
    -- 'cron_calendar' | 'manual_replay'
  synced_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_cron_calendar_sync_log_synced_at
  ON public.cron_calendar_sync_log(synced_at DESC);

CREATE INDEX IF NOT EXISTS idx_cron_calendar_sync_log_status
  ON public.cron_calendar_sync_log(status);

COMMENT ON TABLE public.cron_calendar_sync_log IS
  'Dedup + audit do cron 2x/dia que sincroniza calls agendadas no Google Calendar manual para o ClickUp.';
