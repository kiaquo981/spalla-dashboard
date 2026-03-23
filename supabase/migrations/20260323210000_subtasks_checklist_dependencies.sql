-- =============================================================================
-- Migration: Subtasks full attributes + Dependencies + Date constraints
-- =============================================================================
-- 1. Enhance god_task_subtasks with task-like fields (status, datas, responsavel)
-- 2. Enhance god_task_checklist with due_date + assignee
-- 3. Create god_task_dependencies (Gantt-style A→B)
-- 4. Rebuild vw_god_tasks_full with enhanced subtasks + dependencies + progress
-- 5. Date-constraint validation helper function
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Enhance god_task_subtasks
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.god_task_subtasks
  ADD COLUMN IF NOT EXISTS status        text NOT NULL DEFAULT 'pendente',
  ADD COLUMN IF NOT EXISTS responsavel   text,
  ADD COLUMN IF NOT EXISTS data_inicio   date,
  ADD COLUMN IF NOT EXISTS data_fim      date,
  ADD COLUMN IF NOT EXISTS prioridade    text NOT NULL DEFAULT 'normal',
  ADD COLUMN IF NOT EXISTS clickup_id    text,
  ADD COLUMN IF NOT EXISTS updated_at    timestamptz DEFAULT now();

ALTER TABLE public.god_task_subtasks
  DROP CONSTRAINT IF EXISTS chk_subtask_status;
ALTER TABLE public.god_task_subtasks
  ADD CONSTRAINT chk_subtask_status
    CHECK (status IN ('pendente','em_andamento','em_revisao','concluida','bloqueada'));

ALTER TABLE public.god_task_subtasks
  DROP CONSTRAINT IF EXISTS chk_subtask_dates;
ALTER TABLE public.god_task_subtasks
  ADD CONSTRAINT chk_subtask_dates
    CHECK (data_inicio IS NULL OR data_fim IS NULL OR data_inicio <= data_fim);

CREATE INDEX IF NOT EXISTS idx_subtasks_clickup_id
  ON public.god_task_subtasks(clickup_id) WHERE clickup_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_subtasks_task_id
  ON public.god_task_subtasks(task_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Enhance god_task_checklist
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.god_task_checklist
  ADD COLUMN IF NOT EXISTS due_date    date,
  ADD COLUMN IF NOT EXISTS assignee    text,
  ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Create god_task_dependencies
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.god_task_dependencies (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id     uuid NOT NULL REFERENCES public.god_tasks(id) ON DELETE CASCADE,
  depends_on  uuid NOT NULL REFERENCES public.god_tasks(id) ON DELETE CASCADE,
  tipo        text NOT NULL DEFAULT 'finish_to_start',
  created_at  timestamptz DEFAULT now(),
  created_by  text,
  CONSTRAINT no_self_dep   CHECK (task_id != depends_on),
  CONSTRAINT valid_dep_type CHECK (tipo IN (
    'finish_to_start','start_to_start','finish_to_finish','start_to_finish'
  )),
  UNIQUE(task_id, depends_on)
);

CREATE INDEX IF NOT EXISTS idx_dep_task_id  ON public.god_task_dependencies(task_id);
CREATE INDEX IF NOT EXISTS idx_dep_dep_on   ON public.god_task_dependencies(depends_on);

ALTER TABLE public.god_task_dependencies ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "anon_all_dependencies" ON public.god_task_dependencies;
CREATE POLICY "anon_all_dependencies" ON public.god_task_dependencies
  FOR ALL USING (true) WITH CHECK (true);

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Date-constraint validation function
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.fn_check_subtask_dates(
  p_task_id     uuid,
  p_data_inicio date,
  p_data_fim    date
)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  parent_inicio date;
  parent_fim    date;
  warnings      text[] := '{}';
BEGIN
  SELECT t.data_inicio, t.data_fim
    INTO parent_inicio, parent_fim
    FROM public.god_tasks t
   WHERE t.id = p_task_id;

  IF parent_inicio IS NOT NULL AND p_data_inicio IS NOT NULL
     AND p_data_inicio < parent_inicio THEN
    warnings := array_append(warnings,
      'Início (' || p_data_inicio || ') anterior ao início da tarefa mãe (' || parent_inicio || ')');
  END IF;

  IF parent_fim IS NOT NULL AND p_data_fim IS NOT NULL
     AND p_data_fim > parent_fim THEN
    warnings := array_append(warnings,
      'Prazo (' || p_data_fim || ') ultrapassa o prazo da tarefa mãe (' || parent_fim || ')');
  END IF;

  RETURN jsonb_build_object(
    'ok',       array_length(warnings, 1) IS NULL,
    'warnings', to_jsonb(warnings)
  );
END;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. Rebuild vw_god_tasks_full
--    Must DROP first — CREATE OR REPLACE can't change column order when t.* expands
-- ─────────────────────────────────────────────────────────────────────────────
DROP VIEW IF EXISTS public.vw_god_tasks_full;
CREATE VIEW public.vw_god_tasks_full AS
SELECT
  t.*,

  -- Tags with full metadata
  COALESCE(
    (SELECT jsonb_agg(jsonb_build_object('id', tg.id, 'name', tg.name, 'color', tg.color))
       FROM public.god_task_tag_relations r
       JOIN public.god_task_tags           tg ON tg.id = r.tag_id
      WHERE r.task_id = t.id),
    '[]'::jsonb
  ) AS tags_full,

  -- Custom fields
  COALESCE(
    (SELECT jsonb_agg(jsonb_build_object(
        'field_id',   fv.field_id,
        'field_name', fd.name,
        'field_type', fd.field_type,
        'value',      fv.value
      ))
       FROM public.god_task_field_values fv
       JOIN public.god_task_field_defs   fd ON fd.id = fv.field_id
      WHERE fv.task_id = t.id),
    '[]'::jsonb
  ) AS custom_fields_json,

  -- Subtasks (enhanced)
  COALESCE(
    (SELECT jsonb_agg(jsonb_build_object(
        'id',          s.id,
        'texto',       s.texto,
        'done',        s.done,
        'sort_order',  s.sort_order,
        'status',      s.status,
        'responsavel', s.responsavel,
        'data_inicio', s.data_inicio,
        'data_fim',    s.data_fim,
        'prioridade',  s.prioridade,
        'clickup_id',  s.clickup_id,
        'created_at',  s.created_at,
        'updated_at',  s.updated_at
      ) ORDER BY s.sort_order, s.created_at)
       FROM public.god_task_subtasks s
      WHERE s.task_id = t.id),
    '[]'::jsonb
  ) AS subtasks_json,

  -- Checklist (enhanced)
  COALESCE(
    (SELECT jsonb_agg(jsonb_build_object(
        'id',         c.id,
        'texto',      c.texto,
        'done',       c.done,
        'sort_order', c.sort_order,
        'due_date',   c.due_date,
        'assignee',   c.assignee,
        'created_at', c.created_at
      ) ORDER BY c.sort_order, c.created_at)
       FROM public.god_task_checklist c
      WHERE c.task_id = t.id),
    '[]'::jsonb
  ) AS checklist_json,

  -- Comments
  COALESCE(
    (SELECT jsonb_agg(jsonb_build_object(
        'id',         cm.id,
        'author',     cm.author,
        'texto',      cm.texto,
        'created_at', cm.created_at
      ) ORDER BY cm.created_at)
       FROM public.god_task_comments cm
      WHERE cm.task_id = t.id),
    '[]'::jsonb
  ) AS comments_json,

  -- Handoffs
  COALESCE(
    (SELECT jsonb_agg(jsonb_build_object(
        'id',          h.id,
        'from_person', h.from_person,
        'to_person',   h.to_person,
        'note',        h.note,
        'created_at',  h.created_at
      ) ORDER BY h.created_at)
       FROM public.god_task_handoffs h
      WHERE h.task_id = t.id),
    '[]'::jsonb
  ) AS handoffs_json,

  -- Dependencies: blockers (tasks this task waits for)
  COALESCE(
    (SELECT jsonb_agg(jsonb_build_object(
        'dep_id',           dep.id,
        'depends_on',       dep.depends_on,
        'tipo',             dep.tipo,
        'blocker_titulo',   bt.titulo,
        'blocker_status',   bt.status,
        'blocker_data_fim', bt.data_fim
      ) ORDER BY dep.created_at)
       FROM public.god_task_dependencies dep
       JOIN public.god_tasks             bt ON bt.id = dep.depends_on
      WHERE dep.task_id = t.id),
    '[]'::jsonb
  ) AS dependencies_json,

  -- Dependents: tasks waiting for this task
  COALESCE(
    (SELECT jsonb_agg(jsonb_build_object(
        'dep_id',             d2.id,
        'task_id',            d2.task_id,
        'tipo',               d2.tipo,
        'dependent_titulo',   dt.titulo,
        'dependent_status',   dt.status,
        'dependent_data_fim', dt.data_fim
      ) ORDER BY d2.created_at)
       FROM public.god_task_dependencies d2
       JOIN public.god_tasks             dt ON dt.id = d2.task_id
      WHERE d2.depends_on = t.id),
    '[]'::jsonb
  ) AS dependents_json,

  -- Progress counters for subtask/checklist progress bars
  (SELECT COUNT(*)::int FROM public.god_task_subtasks  s WHERE s.task_id = t.id)           AS subtasks_total,
  (SELECT COUNT(*)::int FROM public.god_task_subtasks  s WHERE s.task_id = t.id AND s.done) AS subtasks_done,
  (SELECT COUNT(*)::int FROM public.god_task_checklist c WHERE c.task_id = t.id)            AS checklist_total,
  (SELECT COUNT(*)::int FROM public.god_task_checklist c WHERE c.task_id = t.id AND c.done) AS checklist_done,

  -- Blocked flag: true if any dependency blocker is not concluida
  EXISTS(
    SELECT 1
      FROM public.god_task_dependencies dep
      JOIN public.god_tasks             bt ON bt.id = dep.depends_on
     WHERE dep.task_id = t.id AND bt.status != 'concluida'
  ) AS is_blocked

FROM public.god_tasks t;
