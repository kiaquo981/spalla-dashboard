-- Fix: god_feedback RLS bloqueava anon key (frontend usa anon)
DROP POLICY IF EXISTS "god_feedback_anon_all" ON public.god_feedback;
CREATE POLICY "god_feedback_anon_all" ON public.god_feedback
  FOR ALL TO anon USING (true) WITH CHECK (true);
