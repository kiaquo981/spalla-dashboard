-- ================================================================
-- Migration: Offboard fields — motivo_inativacao + data_inativacao
-- Data: 2026-03-24
-- Contexto:
--   Adiciona campos para registrar o motivo pelo qual um mentorado
--   foi desativado (ativo = false). Permite auditoria futura e
--   relatórios de churn/conclusão.
-- ================================================================

ALTER TABLE "case".mentorados
  ADD COLUMN IF NOT EXISTS motivo_inativacao TEXT
    CHECK (motivo_inativacao IN ('reembolso', 'conclusao', 'cancelamento', 'outro'))
    DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS data_inativacao DATE DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS obs_inativacao TEXT DEFAULT NULL;

COMMENT ON COLUMN "case".mentorados.motivo_inativacao IS
  'Motivo pelo qual o mentorado foi desativado (ativo = false).
   reembolso = pediu reembolso e saiu | conclusao = concluiu o programa |
   cancelamento = cancelou antes de terminar | outro = motivo livre em obs_inativacao';

COMMENT ON COLUMN "case".mentorados.data_inativacao IS
  'Data em que o mentorado foi desativado. NULL se ainda ativo.';

COMMENT ON COLUMN "case".mentorados.obs_inativacao IS
  'Observação livre sobre o desligamento. Usada quando motivo = outro.';

CREATE INDEX IF NOT EXISTS idx_mentorados_motivo_inativacao
  ON "case".mentorados (motivo_inativacao)
  WHERE ativo = false;
