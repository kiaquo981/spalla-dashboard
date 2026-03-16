-- =============================================================================
-- SPALLA DASHBOARD — ADD FINANCIAL/CONTRACT COLUMNS TO MENTORADOS
-- =============================================================================
-- These columns are populated by Google Sheets sync (14-APP-server.py)
-- Sources:
--   Payments: Sheet 1YY6t5ZxRPTLyCHC-EVkyem10caEJw4TuBy3AR14r0ao
--   Contracts: Sheet 1-Yi5G-bUJanRtmfugFgmVz_DRSV-HOEaP-sSAJqUIxY
-- =============================================================================

-- Add columns (idempotent with IF NOT EXISTS via DO block)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'case' AND table_name = 'mentorados' AND column_name = 'contrato_assinado'
  ) THEN
    ALTER TABLE "case".mentorados ADD COLUMN contrato_assinado boolean DEFAULT true;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'case' AND table_name = 'mentorados' AND column_name = 'status_financeiro'
  ) THEN
    ALTER TABLE "case".mentorados ADD COLUMN status_financeiro text DEFAULT 'em_dia';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'case' AND table_name = 'mentorados' AND column_name = 'dia_pagamento'
  ) THEN
    ALTER TABLE "case".mentorados ADD COLUMN dia_pagamento integer;
  END IF;
END $$;

-- NOTE: CHECK constraint skipped — validation done in backend (server.py).

-- =============================================================================
-- VALIDATION
-- =============================================================================
-- SELECT contrato_assinado, status_financeiro, dia_pagamento
-- FROM "case".mentorados WHERE ativo = true LIMIT 5;
-- =============================================================================
