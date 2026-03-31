-- =============================================================================
-- MIGRATION 69: Add sprint_id to god_tasks (sprint as temporal view, not location)
-- =============================================================================
-- Sprint is a 7-day window. Tasks live in their space/list permanently.
-- sprint_id is a separate dimension — "what's planned for this week?"
-- =============================================================================

-- Add sprint_id column (nullable — most tasks won't be in a sprint)
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS sprint_id text;

-- Grant access
GRANT SELECT, INSERT, UPDATE ON god_tasks TO authenticated, anon;
