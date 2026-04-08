-- ============================================================
-- Fix: Spaces/Lists/Sprints invisíveis (RLS bloqueava anon key)
-- + Sprint 4/5 + carry-over + grant anon em funções RPC
-- ============================================================

-- 1. RLS: permitir anon access (padrão do Spalla — frontend usa anon key)
DROP POLICY IF EXISTS "god_spaces_anon_all" ON public.god_spaces;
CREATE POLICY "god_spaces_anon_all" ON public.god_spaces FOR ALL TO anon USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "god_lists_anon_all" ON public.god_lists;
CREATE POLICY "god_lists_anon_all" ON public.god_lists FOR ALL TO anon USING (true) WITH CHECK (true);

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'god_statuses') THEN
    EXECUTE 'DROP POLICY IF EXISTS "god_statuses_anon_all" ON public.god_statuses';
    EXECUTE 'CREATE POLICY "god_statuses_anon_all" ON public.god_statuses FOR ALL TO anon USING (true) WITH CHECK (true)';
  END IF;
END $$;

-- 2. Grant anon execute em funções RPC (backend usa anon key no supabase_request)
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_sprint_rollover') THEN
    EXECUTE 'GRANT EXECUTE ON FUNCTION fn_sprint_rollover() TO anon';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_materialize_recurring_due') THEN
    EXECUTE 'GRANT EXECUTE ON FUNCTION fn_materialize_recurring_due() TO anon';
  END IF;
END $$;

-- 3. Encerrar Sprints 2 e 3 (já passaram)
UPDATE public.god_lists SET sprint_status = 'encerrado'
WHERE tipo = 'sprint' AND sprint_status != 'encerrado'
  AND sprint_fim IS NOT NULL AND sprint_fim < '2026-04-06';

-- 4. Criar Sprint 4 (ativo) e Sprint 5 (planejado)
INSERT INTO public.god_lists (id, nome, space_id, tipo, sprint_inicio, sprint_fim, sprint_status, ordem)
VALUES
  ('sprint_4', 'Sprint 4 (4/6 - 4/12)', 'space_sistema', 'sprint', '2026-04-06', '2026-04-12', 'ativo', 4),
  ('sprint_5', 'Sprint 5 (4/13 - 4/19)', 'space_sistema', 'sprint', '2026-04-13', '2026-04-19', 'planejado', 5)
ON CONFLICT (id) DO NOTHING;

-- 5. Carry-over: tasks pendentes/em_andamento de sprints encerrados → Sprint 4
UPDATE public.god_tasks
SET sprint_id = 'sprint_4', updated_at = NOW()
WHERE sprint_id IN ('901113377456', '901113377457')
  AND status NOT IN ('concluida', 'cancelada', 'arquivada');

-- 6. Alocar tasks órfãs (sem sprint) no Sprint 4
UPDATE public.god_tasks
SET sprint_id = 'sprint_4', updated_at = NOW()
WHERE (sprint_id IS NULL OR sprint_id = '')
  AND status NOT IN ('concluida', 'cancelada', 'arquivada')
  AND created_at > '2026-03-16';

-- 7. Restaurar tasks nos spaces (tasks que perderam space_id)
-- Regra: se task tem list_id que pertence a um space, herdar o space
UPDATE public.god_tasks t
SET space_id = l.space_id
FROM public.god_lists l
WHERE t.list_id = l.id
  AND (t.space_id IS NULL OR t.space_id = '');

-- Se não tem list_id nem space_id, classificar por tipo
UPDATE public.god_tasks
SET space_id = 'space_gestao'
WHERE (space_id IS NULL OR space_id = '')
  AND tipo IN ('dossie', 'ajuste_dossie', 'follow_up', 'geral', 'rotina');

UPDATE public.god_tasks
SET space_id = 'space_sistema'
WHERE (space_id IS NULL OR space_id = '')
  AND tipo IN ('bug_report');

UPDATE public.god_tasks
SET space_id = 'space_jornada'
WHERE (space_id IS NULL OR space_id = '')
  AND mentorado_id IS NOT NULL
  AND (space_id IS NULL OR space_id = '');

-- Fallback: qualquer task sem space vai pra gestão
UPDATE public.god_tasks
SET space_id = 'space_gestao'
WHERE (space_id IS NULL OR space_id = '');
