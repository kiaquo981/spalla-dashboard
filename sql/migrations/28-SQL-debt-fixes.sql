-- ================================================================
-- 28-SQL-debt-fixes.sql
-- Technical Debt Resolution: Security, Integrity, Performance
-- Run this in Supabase SQL Editor (as superuser/service role)
-- ================================================================

-- ================================================================
-- 1A. Replace USING(true) with role-restricted policies
-- NOTE: App uses Supabase anon key (no Supabase Auth signIn), so
-- auth.role() = 'anon'. Policies must allow both 'authenticated' and 'anon'.
-- CORRECTED in 29-SQL-fix-rls-anon.sql (original used only 'authenticated').
-- ================================================================

-- god_tasks
DROP POLICY IF EXISTS "god_tasks_all" ON god_tasks;
CREATE POLICY "god_tasks_authenticated" ON god_tasks
  FOR ALL USING (auth.role() = 'authenticated');

-- god_task_subtasks
DROP POLICY IF EXISTS "god_task_subtasks_all" ON god_task_subtasks;
CREATE POLICY "god_task_subtasks_authenticated" ON god_task_subtasks
  FOR ALL USING (auth.role() = 'authenticated');

-- god_task_checklist
DROP POLICY IF EXISTS "god_task_checklist_all" ON god_task_checklist;
CREATE POLICY "god_task_checklist_authenticated" ON god_task_checklist
  FOR ALL USING (auth.role() = 'authenticated');

-- god_task_comments
DROP POLICY IF EXISTS "god_task_comments_all" ON god_task_comments;
CREATE POLICY "god_task_comments_authenticated" ON god_task_comments
  FOR ALL USING (auth.role() = 'authenticated');

-- god_task_handoffs
DROP POLICY IF EXISTS "god_task_handoffs_all" ON god_task_handoffs;
CREATE POLICY "god_task_handoffs_authenticated" ON god_task_handoffs
  FOR ALL USING (auth.role() = 'authenticated');

-- marcos_mentorado
DROP POLICY IF EXISTS "marcos_mentorado_select" ON marcos_mentorado;
DROP POLICY IF EXISTS "marcos_mentorado_all" ON marcos_mentorado;
CREATE POLICY "marcos_mentorado_authenticated" ON marcos_mentorado
  FOR ALL USING (auth.role() = 'authenticated');

-- analises_call
DROP POLICY IF EXISTS "analises_call_select" ON analises_call;
DROP POLICY IF EXISTS "analises_call_all" ON analises_call;
CREATE POLICY "analises_call_authenticated" ON analises_call
  FOR ALL USING (auth.role() = 'authenticated');

-- fontes_raw
DROP POLICY IF EXISTS "fontes_raw_select" ON fontes_raw;
DROP POLICY IF EXISTS "fontes_raw_all" ON fontes_raw;
CREATE POLICY "fontes_raw_authenticated" ON fontes_raw
  FOR ALL USING (auth.role() = 'authenticated');

-- analises_whatsapp
DROP POLICY IF EXISTS "analises_whatsapp_select" ON analises_whatsapp;
DROP POLICY IF EXISTS "analises_whatsapp_all" ON analises_whatsapp;
CREATE POLICY "analises_whatsapp_authenticated" ON analises_whatsapp
  FOR ALL USING (auth.role() = 'authenticated');

-- pa_planos
DROP POLICY IF EXISTS "pa_planos_all" ON pa_planos;
CREATE POLICY "pa_planos_authenticated" ON pa_planos
  FOR ALL USING (auth.role() = 'authenticated');

-- pa_fases
DROP POLICY IF EXISTS "pa_fases_all" ON pa_fases;
CREATE POLICY "pa_fases_authenticated" ON pa_fases
  FOR ALL USING (auth.role() = 'authenticated');

-- pa_acoes
DROP POLICY IF EXISTS "pa_acoes_all" ON pa_acoes;
CREATE POLICY "pa_acoes_authenticated" ON pa_acoes
  FOR ALL USING (auth.role() = 'authenticated');

-- pa_sub_acoes
DROP POLICY IF EXISTS "pa_sub_acoes_all" ON pa_sub_acoes;
CREATE POLICY "pa_sub_acoes_authenticated" ON pa_sub_acoes
  FOR ALL USING (auth.role() = 'authenticated');

-- ds_producoes
DROP POLICY IF EXISTS "ds_producoes_all" ON ds_producoes;
CREATE POLICY "ds_producoes_authenticated" ON ds_producoes
  FOR ALL USING (auth.role() = 'authenticated');

-- ds_documentos
DROP POLICY IF EXISTS "ds_documentos_all" ON ds_documentos;
CREATE POLICY "ds_documentos_authenticated" ON ds_documentos
  FOR ALL USING (auth.role() = 'authenticated');

-- ds_eventos
DROP POLICY IF EXISTS "ds_eventos_all" ON ds_eventos;
CREATE POLICY "ds_eventos_authenticated" ON ds_eventos
  FOR ALL USING (auth.role() = 'authenticated');

-- ds_ajustes
DROP POLICY IF EXISTS "ds_ajustes_all" ON ds_ajustes;
CREATE POLICY "ds_ajustes_authenticated" ON ds_ajustes
  FOR ALL USING (auth.role() = 'authenticated');


-- ================================================================
-- 1B. Enable RLS on ob_* tables (currently have no RLS)
-- ================================================================

ALTER TABLE ob_template_etapas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ob_template_etapas_authenticated" ON ob_template_etapas
  FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE ob_template_tarefas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ob_template_tarefas_authenticated" ON ob_template_tarefas
  FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE ob_trilhas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ob_trilhas_authenticated" ON ob_trilhas
  FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE ob_etapas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ob_etapas_authenticated" ON ob_etapas
  FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE ob_tarefas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ob_tarefas_authenticated" ON ob_tarefas
  FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE ob_eventos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ob_eventos_authenticated" ON ob_eventos
  FOR ALL USING (auth.role() = 'authenticated');


-- ================================================================
-- 1C. Missing indexes for common queries
-- ================================================================

CREATE INDEX IF NOT EXISTS idx_ob_etapas_trilha ON ob_etapas(trilha_id);
CREATE INDEX IF NOT EXISTS idx_ob_tarefas_trilha ON ob_tarefas(trilha_id);
CREATE INDEX IF NOT EXISTS idx_ob_tarefas_etapa ON ob_tarefas(etapa_id);
CREATE INDEX IF NOT EXISTS idx_ds_ajustes_doc ON ds_ajustes(documento_id);
CREATE INDEX IF NOT EXISTS idx_pa_acoes_status ON pa_acoes(status);


-- ================================================================
-- 1D. CHECK constraints on status fields
-- ================================================================

ALTER TABLE ob_tarefas ADD CONSTRAINT chk_ob_tarefas_status
  CHECK (status IN ('pendente','concluido'));

ALTER TABLE ob_etapas ADD CONSTRAINT chk_ob_etapas_status
  CHECK (status IN ('pendente','em_andamento','concluido'));

ALTER TABLE ob_trilhas ADD CONSTRAINT chk_ob_trilhas_status
  CHECK (status IN ('em_andamento','concluido','pausado'));

ALTER TABLE ds_ajustes ADD CONSTRAINT chk_ds_ajustes_status
  CHECK (status IN ('pendente','em_andamento','concluido'));

ALTER TABLE ds_producoes ADD CONSTRAINT chk_ds_contrato
  CHECK (contrato_assinado IN ('sim','nao','pendente'));


-- ================================================================
-- 1E. Foreign keys — SKIPPED
-- mentorados is a view (not a table), so FK constraints cannot reference it.
-- ob_tarefas.mentorado_id, ds_eventos.mentorado_id, ds_ajustes.mentorado_id
-- remain without FK enforcement (integrity maintained at application level).
-- ================================================================


-- ================================================================
-- 1F. updated_at triggers for ob_* tables
-- ================================================================

-- Add missing updated_at column to ob_etapas
ALTER TABLE ob_etapas ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

-- Reuse existing fn_update_timestamp() for ob_* triggers
CREATE TRIGGER trg_ob_template_etapas_updated
  BEFORE UPDATE ON ob_template_etapas
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_ob_template_tarefas_updated
  BEFORE UPDATE ON ob_template_tarefas
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_ob_trilhas_updated
  BEFORE UPDATE ON ob_trilhas
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_ob_tarefas_updated
  BEFORE UPDATE ON ob_tarefas
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_ob_etapas_updated
  BEFORE UPDATE ON ob_etapas
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();


-- ================================================================
-- 1G. Note: vw_pa_pipeline consolidation
-- The canonical definition of vw_pa_pipeline is in 19-SQL-pa-sub-acoes-schema.sql.
-- Definitions in 15-SQL and 16-SQL are superseded — add comments there manually.
-- No SQL changes needed here since CREATE OR REPLACE handles precedence.
-- ================================================================
