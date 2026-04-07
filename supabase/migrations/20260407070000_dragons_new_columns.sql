-- Dragons 18/20/23: Add recurrence_rule, time_spent, watchers columns to god_tasks
-- Safe: uses IF NOT EXISTS pattern via DO blocks

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'god_tasks' AND column_name = 'recurrence_rule') THEN
    ALTER TABLE god_tasks ADD COLUMN recurrence_rule TEXT DEFAULT NULL;
    COMMENT ON COLUMN god_tasks.recurrence_rule IS 'Recurring schedule: daily, weekly, monthly, or NULL';
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'god_tasks' AND column_name = 'time_spent') THEN
    ALTER TABLE god_tasks ADD COLUMN time_spent NUMERIC DEFAULT 0;
    COMMENT ON COLUMN god_tasks.time_spent IS 'Total hours tracked on this task';
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'god_tasks' AND column_name = 'watchers') THEN
    ALTER TABLE god_tasks ADD COLUMN watchers JSONB DEFAULT '[]'::jsonb;
    COMMENT ON COLUMN god_tasks.watchers IS 'Array of user names watching this task';
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'god_tasks' AND column_name = 'cover_image_url') THEN
    ALTER TABLE god_tasks ADD COLUMN cover_image_url TEXT DEFAULT NULL;
    COMMENT ON COLUMN god_tasks.cover_image_url IS 'Optional cover image URL for board cards';
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'god_tasks' AND column_name = 'archived_at') THEN
    ALTER TABLE god_tasks ADD COLUMN archived_at TIMESTAMPTZ DEFAULT NULL;
    COMMENT ON COLUMN god_tasks.archived_at IS 'When task was archived (NULL = not archived)';
  END IF;
END $$;
