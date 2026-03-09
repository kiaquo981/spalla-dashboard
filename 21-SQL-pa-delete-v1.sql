-- ============================================================
-- 21-SQL-pa-delete-v1.sql
-- Deletar todos os planos v1 (que NÃO são dossie_auto_v3)
-- CASCADE vai deletar pa_fases e pa_acoes associadas
-- ============================================================

-- Preview: quantos planos serão deletados
-- SELECT id, mentorado_id, titulo, created_by FROM pa_planos WHERE created_by IS DISTINCT FROM 'dossie_auto_v3';

DELETE FROM pa_planos WHERE created_by IS DISTINCT FROM 'dossie_auto_v3';
