-- Migration 53: Add google_calendar_event_id to calls_mentoria
-- Enables cancellation of Google Calendar events when calls are cancelled

ALTER TABLE calls_mentoria
ADD COLUMN IF NOT EXISTS google_calendar_event_id TEXT;

COMMENT ON COLUMN calls_mentoria.google_calendar_event_id IS
  'ID do evento no Google Calendar para cancelamento futuro';

CREATE INDEX IF NOT EXISTS idx_calls_mentoria_gcal_event_id
  ON calls_mentoria (google_calendar_event_id)
  WHERE google_calendar_event_id IS NOT NULL;
