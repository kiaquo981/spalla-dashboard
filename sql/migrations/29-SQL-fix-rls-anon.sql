-- ================================================================
-- 29-SQL-fix-rls-anon.sql
-- Fix: Allow anon role in RLS policies
-- The app uses Supabase client with anon key (no Supabase Auth signIn),
-- so auth.role() = 'anon'. The policies from 28-SQL required 'authenticated'
-- which blocked all direct table queries.
-- Run this in Supabase SQL Editor.
-- ================================================================

-- ================================================================
-- 1. Fix policies on tables from 28-SQL (1A) — allow anon + authenticated
-- ================================================================

-- god_tasks
DROP POLICY IF EXISTS "god_tasks_authenticated" ON god_tasks;
CREATE POLICY "god_tasks_access" ON god_tasks
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- god_task_subtasks
DROP POLICY IF EXISTS "god_task_subtasks_authenticated" ON god_task_subtasks;
CREATE POLICY "god_task_subtasks_access" ON god_task_subtasks
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- god_task_checklist
DROP POLICY IF EXISTS "god_task_checklist_authenticated" ON god_task_checklist;
CREATE POLICY "god_task_checklist_access" ON god_task_checklist
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- god_task_comments
DROP POLICY IF EXISTS "god_task_comments_authenticated" ON god_task_comments;
CREATE POLICY "god_task_comments_access" ON god_task_comments
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- god_task_handoffs
DROP POLICY IF EXISTS "god_task_handoffs_authenticated" ON god_task_handoffs;
CREATE POLICY "god_task_handoffs_access" ON god_task_handoffs
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- marcos_mentorado
DROP POLICY IF EXISTS "marcos_mentorado_authenticated" ON marcos_mentorado;
CREATE POLICY "marcos_mentorado_access" ON marcos_mentorado
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- analises_call
DROP POLICY IF EXISTS "analises_call_authenticated" ON analises_call;
CREATE POLICY "analises_call_access" ON analises_call
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- fontes_raw
DROP POLICY IF EXISTS "fontes_raw_authenticated" ON fontes_raw;
CREATE POLICY "fontes_raw_access" ON fontes_raw
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- analises_whatsapp
DROP POLICY IF EXISTS "analises_whatsapp_authenticated" ON analises_whatsapp;
CREATE POLICY "analises_whatsapp_access" ON analises_whatsapp
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- pa_planos
DROP POLICY IF EXISTS "pa_planos_authenticated" ON pa_planos;
CREATE POLICY "pa_planos_access" ON pa_planos
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- pa_fases
DROP POLICY IF EXISTS "pa_fases_authenticated" ON pa_fases;
CREATE POLICY "pa_fases_access" ON pa_fases
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- pa_acoes
DROP POLICY IF EXISTS "pa_acoes_authenticated" ON pa_acoes;
CREATE POLICY "pa_acoes_access" ON pa_acoes
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- pa_sub_acoes
DROP POLICY IF EXISTS "pa_sub_acoes_authenticated" ON pa_sub_acoes;
CREATE POLICY "pa_sub_acoes_access" ON pa_sub_acoes
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- ds_producoes
DROP POLICY IF EXISTS "ds_producoes_authenticated" ON ds_producoes;
CREATE POLICY "ds_producoes_access" ON ds_producoes
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- ds_documentos
DROP POLICY IF EXISTS "ds_documentos_authenticated" ON ds_documentos;
CREATE POLICY "ds_documentos_access" ON ds_documentos
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- ds_eventos
DROP POLICY IF EXISTS "ds_eventos_authenticated" ON ds_eventos;
CREATE POLICY "ds_eventos_access" ON ds_eventos
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- ds_ajustes
DROP POLICY IF EXISTS "ds_ajustes_authenticated" ON ds_ajustes;
CREATE POLICY "ds_ajustes_access" ON ds_ajustes
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));


-- ================================================================
-- 2. Fix policies on ob_* tables from 28-SQL (1B) — allow anon + authenticated
-- ================================================================

DROP POLICY IF EXISTS "ob_template_etapas_authenticated" ON ob_template_etapas;
CREATE POLICY "ob_template_etapas_access" ON ob_template_etapas
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

DROP POLICY IF EXISTS "ob_template_tarefas_authenticated" ON ob_template_tarefas;
CREATE POLICY "ob_template_tarefas_access" ON ob_template_tarefas
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

DROP POLICY IF EXISTS "ob_trilhas_authenticated" ON ob_trilhas;
CREATE POLICY "ob_trilhas_access" ON ob_trilhas
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

DROP POLICY IF EXISTS "ob_etapas_authenticated" ON ob_etapas;
CREATE POLICY "ob_etapas_access" ON ob_etapas
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

DROP POLICY IF EXISTS "ob_tarefas_authenticated" ON ob_tarefas;
CREATE POLICY "ob_tarefas_access" ON ob_tarefas
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

DROP POLICY IF EXISTS "ob_eventos_authenticated" ON ob_eventos;
CREATE POLICY "ob_eventos_access" ON ob_eventos
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));
