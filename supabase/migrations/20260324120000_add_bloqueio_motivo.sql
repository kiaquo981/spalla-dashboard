-- ─────────────────────────────────────────────────────────────────────────────
-- Add bloqueio_motivo to god_tasks + update vw_god_tasks_full
-- ─────────────────────────────────────────────────────────────────────────────

-- 1. Add columns
ALTER TABLE public.god_tasks
  ADD COLUMN IF NOT EXISTS bloqueio_motivo      TEXT,
  ADD COLUMN IF NOT EXISTS bloqueio_responsavel TEXT;   -- quem pode desbloquear

-- 2. Rebuild view (must DROP first — t.* expands)
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

  -- Progress counters
  (SELECT COUNT(*)::int FROM public.god_task_subtasks  s WHERE s.task_id = t.id)            AS subtasks_total,
  (SELECT COUNT(*)::int FROM public.god_task_subtasks  s WHERE s.task_id = t.id AND s.done) AS subtasks_done,
  (SELECT COUNT(*)::int FROM public.god_task_checklist c WHERE c.task_id = t.id)            AS checklist_total,
  (SELECT COUNT(*)::int FROM public.god_task_checklist c WHERE c.task_id = t.id AND c.done) AS checklist_done,

  -- Blocked flag: true if has pending dependency OR bloqueio_motivo set
  (
    (t.bloqueio_motivo IS NOT NULL AND t.bloqueio_motivo != '')
    OR EXISTS(
      SELECT 1
        FROM public.god_task_dependencies dep
        JOIN public.god_tasks             bt ON bt.id = dep.depends_on
       WHERE dep.task_id = t.id AND bt.status != 'concluida'
    )
  ) AS is_blocked

FROM public.god_tasks t;
