-- ============================================================
-- Migration: WA Group Board — status column for kanban view
-- Table: case.mentorados
-- ============================================================
-- Adds wa_status field to track response management stage per
-- WA group. Used by the board view (Aguardando / Em andamento /
-- Bloqueado / Resolvido). Defaults to 'aguardando' so existing
-- rows land in the first column automatically.
-- ============================================================

ALTER TABLE "case".mentorados
  ADD COLUMN IF NOT EXISTS wa_status TEXT NOT NULL DEFAULT 'aguardando'
  CHECK (wa_status IN ('aguardando', 'em_andamento', 'bloqueado', 'resolvido'));

-- Index for fast board column queries
CREATE INDEX IF NOT EXISTS idx_mentorados_wa_status
  ON "case".mentorados (wa_status);

COMMENT ON COLUMN "case".mentorados.wa_status IS
  'WA group response management stage: aguardando | em_andamento | bloqueado | resolvido';
