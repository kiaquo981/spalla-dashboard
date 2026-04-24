-- ============================================================
-- LF-FASE2: Taxonomy Reconciliation
-- Story: LF-2.1
--
-- Alinha CHECK constraints com o vocabulário canônico definido
-- em docs/UBIQUITOUS-LANGUAGE.md e docs/TAXONOMY-RECONCILIATION.md.
--
-- Mudanças aditivas (não remove valores válidos existentes).
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. god_tasks.status — expandir de 4 para 8 estados
-- ------------------------------------------------------------
ALTER TABLE god_tasks DROP CONSTRAINT IF EXISTS god_tasks_status_check;
ALTER TABLE god_tasks ADD CONSTRAINT god_tasks_status_check
  CHECK (status IN (
    'pendente','em_andamento','em_revisao','bloqueada',
    'pausada','concluida','cancelada','arquivada'
  ));

-- ------------------------------------------------------------
-- 2. god_tasks.tipo — formalizar (nullable, mas se setado válido)
-- ------------------------------------------------------------
ALTER TABLE god_tasks DROP CONSTRAINT IF EXISTS god_tasks_tipo_check;
ALTER TABLE god_tasks ADD CONSTRAINT god_tasks_tipo_check
  CHECK (tipo IS NULL OR tipo IN (
    'geral','dossie','ajuste_dossie','follow_up','rotina','bug_report','acao'
  ));

-- ------------------------------------------------------------
-- 3. calls_mentoria.tipo_call — normalizar legados + adicionar CHECK
-- ------------------------------------------------------------
-- Drop pre-existing constraints first (could be from older migrations)
ALTER TABLE calls_mentoria DROP CONSTRAINT IF EXISTS calls_mentoria_tipo_call_check;
ALTER TABLE calls_mentoria DROP CONSTRAINT IF EXISTS calls_mentoria_tipo_check;

-- Bypass user triggers durante normalização (existe trigger legado bugado)
SET session_replication_role = replica;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_name='calls_mentoria' AND column_name='tipo_call') THEN
    UPDATE calls_mentoria SET tipo_call='estrategia'
      WHERE tipo_call IN ('diagnostico','planejamento');
    UPDATE calls_mentoria SET tipo_call='oferta'
      WHERE tipo_call='fechamento';
  END IF;
END $$;
SET session_replication_role = DEFAULT;

ALTER TABLE calls_mentoria ADD CONSTRAINT calls_mentoria_tipo_check
  CHECK (tipo_call IS NULL OR tipo_call IN (
    'onboarding','estrategia','acompanhamento','oferta',
    'conselho','qa','destrave','conteudo','plano_acao'
  ));

-- ------------------------------------------------------------
-- 4. mentorados.trilha — nova coluna (Scale vs Clinic)
-- ------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='case' AND table_name='mentorados' AND column_name='trilha'
  ) THEN
    ALTER TABLE "case".mentorados ADD COLUMN trilha TEXT DEFAULT 'scale'
      CHECK (trilha IN ('scale','clinic'));
  END IF;
END $$;

-- ------------------------------------------------------------
-- 5. ds_producoes.trilha — denormalizada
-- ------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='ds_producoes' AND column_name='trilha'
  ) THEN
    ALTER TABLE ds_producoes ADD COLUMN trilha TEXT DEFAULT 'scale'
      CHECK (trilha IN ('scale','clinic'));
  END IF;
END $$;

-- ------------------------------------------------------------
-- 6. mentorados.status_financeiro — adicionar CHECK
-- ------------------------------------------------------------
ALTER TABLE "case".mentorados DROP CONSTRAINT IF EXISTS mentorados_status_financeiro_check;
ALTER TABLE "case".mentorados ADD CONSTRAINT mentorados_status_financeiro_check
  CHECK (status_financeiro IS NULL OR status_financeiro IN (
    'sem_contrato','pendente','em_dia','atrasado','quitado','cancelado'
  ));

COMMIT;
