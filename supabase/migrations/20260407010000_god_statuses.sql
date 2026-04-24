-- ============================================================
-- GOD_STATUSES — Per-space customizable statuses
-- Phase 0: ClickUp Internalization
-- Date: 2026-04-07
-- ============================================================

-- 1. Status definitions per space
CREATE TABLE IF NOT EXISTS god_statuses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  space_id VARCHAR(50) NOT NULL REFERENCES god_spaces(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  color TEXT NOT NULL DEFAULT '#808080',
  status_group TEXT NOT NULL DEFAULT 'active'
    CHECK (status_group IN ('active', 'done', 'closed')),
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(space_id, name)
);

CREATE INDEX IF NOT EXISTS idx_god_statuses_space ON god_statuses(space_id);
CREATE INDEX IF NOT EXISTS idx_god_statuses_group ON god_statuses(status_group);

-- 2. RLS
ALTER TABLE god_statuses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "god_statuses_select" ON god_statuses;
CREATE POLICY "god_statuses_select" ON god_statuses FOR SELECT USING (true);

DROP POLICY IF EXISTS "god_statuses_all_auth" ON god_statuses;
CREATE POLICY "god_statuses_all_auth" ON god_statuses FOR ALL
  TO authenticated USING (true) WITH CHECK (true);

-- Also allow anon (internal dashboard)
DROP POLICY IF EXISTS "god_statuses_all_anon" ON god_statuses;
CREATE POLICY "god_statuses_all_anon" ON god_statuses FOR ALL
  TO anon USING (true) WITH CHECK (true);

-- 3. Seed default statuses for each existing space
-- Maps from old TEXT statuses: pendente, em_andamento, concluida, cancelada
INSERT INTO god_statuses (space_id, name, color, status_group, sort_order, is_default) VALUES
  -- Jornada do Mentorado
  ('space_jornada', 'Pendente',      '#94a3b8', 'active', 0, true),
  ('space_jornada', 'Em Andamento',  '#f59e0b', 'active', 1, false),
  ('space_jornada', 'Concluida',     '#22c55e', 'done',   2, false),
  ('space_jornada', 'Cancelada',     '#6b7280', 'closed', 3, false),
  -- Gestao Interna
  ('space_gestao', 'Pendente',       '#94a3b8', 'active', 0, true),
  ('space_gestao', 'Em Andamento',   '#f59e0b', 'active', 1, false),
  ('space_gestao', 'Concluida',      '#22c55e', 'done',   2, false),
  ('space_gestao', 'Cancelada',      '#6b7280', 'closed', 3, false),
  -- IA & Automacao
  ('space_ia', 'Pendente',           '#94a3b8', 'active', 0, true),
  ('space_ia', 'Em Andamento',       '#f59e0b', 'active', 1, false),
  ('space_ia', 'Concluida',          '#22c55e', 'done',   2, false),
  ('space_ia', 'Cancelada',          '#6b7280', 'closed', 3, false),
  -- Sistema & Dev
  ('space_sistema', 'Pendente',      '#94a3b8', 'active', 0, true),
  ('space_sistema', 'Em Andamento',  '#f59e0b', 'active', 1, false),
  ('space_sistema', 'Em Revisao',    '#8b5cf6', 'active', 2, false),
  ('space_sistema', 'Concluida',     '#22c55e', 'done',   3, false),
  ('space_sistema', 'Cancelada',     '#6b7280', 'closed', 4, false)
ON CONFLICT (space_id, name) DO NOTHING;

-- 4. Add status_id column to god_tasks (keep old status TEXT for now)
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS status_id UUID REFERENCES god_statuses(id);

CREATE INDEX IF NOT EXISTS idx_god_tasks_status_id ON god_tasks(status_id);

-- 5. Migrate existing text statuses to status_id
-- Match by name pattern: pendente → Pendente, em_andamento → Em Andamento, etc.
UPDATE god_tasks t
SET status_id = s.id
FROM god_statuses s
WHERE t.status_id IS NULL
  AND t.space_id IS NOT NULL
  AND s.space_id = t.space_id
  AND (
    (t.status = 'pendente'     AND s.name = 'Pendente')
    OR (t.status = 'em_andamento' AND s.name = 'Em Andamento')
    OR (t.status = 'concluida'    AND s.name = 'Concluida')
    OR (t.status = 'cancelada'    AND s.name = 'Cancelada')
  );

-- Tasks without space_id: assign to space_gestao defaults
UPDATE god_tasks t
SET status_id = s.id
FROM god_statuses s
WHERE t.status_id IS NULL
  AND s.space_id = 'space_gestao'
  AND (
    (t.status = 'pendente'     AND s.name = 'Pendente')
    OR (t.status = 'em_andamento' AND s.name = 'Em Andamento')
    OR (t.status = 'concluida'    AND s.name = 'Concluida')
    OR (t.status = 'cancelada'    AND s.name = 'Cancelada')
  );

-- 6. Update vw_god_tasks_full to include status details
-- NOTE: We DON'T drop the view here to avoid CASCADE issues.
-- The view will be updated in the frontend to join god_statuses.

-- 7. Notify PostgREST to reload schema
NOTIFY pgrst, 'reload schema';
