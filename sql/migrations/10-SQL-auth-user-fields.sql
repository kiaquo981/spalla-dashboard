-- ================================================================
-- Spalla V2 — SQL Migration for Multi-User Auth & Activity Tracking
-- ================================================================

-- Add user_id to god_reminders (for private reminders per user)
ALTER TABLE god_reminders
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- Add created_by to god_tasks (for tracking task creation)
ALTER TABLE god_tasks
  ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- Enable RLS on god_reminders (if not already enabled)
ALTER TABLE god_reminders ENABLE ROW LEVEL SECURITY;

-- Drop old policies if they exist
DROP POLICY IF EXISTS "reminders_open" ON god_reminders;
DROP POLICY IF EXISTS "user_own_reminders" ON god_reminders;

-- Create RLS policy: users can only see their own reminders, or legacy reminders (user_id IS NULL)
CREATE POLICY "user_own_reminders" ON god_reminders
  FOR ALL USING (auth.uid() = user_id OR user_id IS NULL);

-- god_tasks remains open (RLS not applied) — all users see all tasks
-- Comments and handoffs use author/autor fields for tracking (no RLS needed)
