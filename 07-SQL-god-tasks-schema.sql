-- ============================================================
-- GOD TASKS SCHEMA — Supabase Tables for ClickUp-style Task Management
-- Dashboard: Spalla v26+
-- Date: 2026-02-17
-- ============================================================

-- 1. Main Tasks Table
CREATE TABLE IF NOT EXISTS god_tasks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  titulo TEXT NOT NULL,
  descricao TEXT,
  status TEXT DEFAULT 'pendente' CHECK (status IN ('pendente', 'em_andamento', 'concluida', 'cancelada')),
  prioridade TEXT DEFAULT 'normal' CHECK (prioridade IN ('baixa', 'normal', 'alta', 'urgente')),
  responsavel TEXT,
  acompanhante TEXT,
  mentorado_id BIGINT REFERENCES mentorados(id) ON DELETE SET NULL,
  mentorado_nome TEXT,
  data_inicio DATE,
  data_fim DATE,
  space_id TEXT,
  list_id TEXT,
  parent_task_id UUID REFERENCES god_tasks(id) ON DELETE SET NULL,
  tags TEXT[] DEFAULT '{}',
  fonte TEXT DEFAULT 'manual',
  doc_link TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by TEXT DEFAULT 'dashboard'
);

-- 2. Subtasks
CREATE TABLE IF NOT EXISTS god_task_subtasks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  task_id UUID NOT NULL REFERENCES god_tasks(id) ON DELETE CASCADE,
  texto TEXT NOT NULL,
  done BOOLEAN DEFAULT false,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Checklist Items
CREATE TABLE IF NOT EXISTS god_task_checklist (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  task_id UUID NOT NULL REFERENCES god_tasks(id) ON DELETE CASCADE,
  texto TEXT NOT NULL,
  done BOOLEAN DEFAULT false,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Comments
CREATE TABLE IF NOT EXISTS god_task_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  task_id UUID NOT NULL REFERENCES god_tasks(id) ON DELETE CASCADE,
  author TEXT NOT NULL DEFAULT 'Equipe',
  texto TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Handoffs (Passagem de Bastao)
CREATE TABLE IF NOT EXISTS god_task_handoffs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  task_id UUID NOT NULL REFERENCES god_tasks(id) ON DELETE CASCADE,
  from_person TEXT NOT NULL,
  to_person TEXT NOT NULL,
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 6. Reminders
CREATE TABLE IF NOT EXISTS god_reminders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  titulo TEXT NOT NULL,
  descricao TEXT,
  tipo TEXT DEFAULT 'geral',
  mentorado_nome TEXT,
  data_lembrete TIMESTAMPTZ,
  recorrencia TEXT DEFAULT 'nenhuma' CHECK (recorrencia IN ('nenhuma', 'diario', 'semanal', 'mensal')),
  status TEXT DEFAULT 'ativo' CHECK (status IN ('ativo', 'concluido', 'cancelado')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE god_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE god_task_subtasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE god_task_checklist ENABLE ROW LEVEL SECURITY;
ALTER TABLE god_task_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE god_task_handoffs ENABLE ROW LEVEL SECURITY;
ALTER TABLE god_reminders ENABLE ROW LEVEL SECURITY;

-- Allow all for anon (internal dashboard, password-protected)
CREATE POLICY "god_tasks_all" ON god_tasks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "god_task_subtasks_all" ON god_task_subtasks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "god_task_checklist_all" ON god_task_checklist FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "god_task_comments_all" ON god_task_comments FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "god_task_handoffs_all" ON god_task_handoffs FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "god_reminders_all" ON god_reminders FOR ALL USING (true) WITH CHECK (true);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_god_tasks_status ON god_tasks(status);
CREATE INDEX IF NOT EXISTS idx_god_tasks_mentorado ON god_tasks(mentorado_id);
CREATE INDEX IF NOT EXISTS idx_god_tasks_mentorado_nome ON god_tasks(mentorado_nome);
CREATE INDEX IF NOT EXISTS idx_god_tasks_parent ON god_tasks(parent_task_id);
CREATE INDEX IF NOT EXISTS idx_god_tasks_space ON god_tasks(space_id);
CREATE INDEX IF NOT EXISTS idx_god_tasks_list ON god_tasks(list_id);
CREATE INDEX IF NOT EXISTS idx_god_tasks_responsavel ON god_tasks(responsavel);
CREATE INDEX IF NOT EXISTS idx_god_task_subtasks_task ON god_task_subtasks(task_id);
CREATE INDEX IF NOT EXISTS idx_god_task_checklist_task ON god_task_checklist(task_id);
CREATE INDEX IF NOT EXISTS idx_god_task_comments_task ON god_task_comments(task_id);
CREATE INDEX IF NOT EXISTS idx_god_task_handoffs_task ON god_task_handoffs(task_id);
CREATE INDEX IF NOT EXISTS idx_god_reminders_status ON god_reminders(status);

-- ============================================================
-- TRIGGER: auto-update updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_god_tasks_updated
  BEFORE UPDATE ON god_tasks
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_god_reminders_updated
  BEFORE UPDATE ON god_reminders
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

-- ============================================================
-- VIEW: god_tasks with nested subtasks/comments/handoffs
-- ============================================================
CREATE OR REPLACE VIEW vw_god_tasks_full AS
SELECT
  t.*,
  COALESCE(
    (SELECT json_agg(json_build_object('id', s.id, 'text', s.texto, 'done', s.done) ORDER BY s.sort_order)
     FROM god_task_subtasks s WHERE s.task_id = t.id), '[]'::json
  ) AS subtasks,
  COALESCE(
    (SELECT json_agg(json_build_object('id', cl.id, 'text', cl.texto, 'done', cl.done) ORDER BY cl.sort_order)
     FROM god_task_checklist cl WHERE cl.task_id = t.id), '[]'::json
  ) AS checklist,
  COALESCE(
    (SELECT json_agg(json_build_object('id', c.id, 'author', c.author, 'text', c.texto, 'timestamp', c.created_at) ORDER BY c.created_at DESC)
     FROM god_task_comments c WHERE c.task_id = t.id), '[]'::json
  ) AS comments,
  COALESCE(
    (SELECT json_agg(json_build_object('id', h.id, 'from', h.from_person, 'to', h.to_person, 'note', h.note, 'date', h.created_at) ORDER BY h.created_at DESC)
     FROM god_task_handoffs h WHERE h.task_id = t.id), '[]'::json
  ) AS handoffs
FROM god_tasks t;
