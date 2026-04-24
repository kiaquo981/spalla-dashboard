-- Add instance_api_key to wa_sessions so backend can proxy per-instance
ALTER TABLE wa_sessions ADD COLUMN IF NOT EXISTS instance_api_key TEXT;

-- Set known keys
UPDATE wa_sessions SET instance_api_key = '5D6552BD-2580-46EB-A819-26663DD030E0' WHERE instance_name = 'spalla_u5';

NOTIFY pgrst, 'reload schema';
