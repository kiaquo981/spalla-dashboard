-- ============================================================
-- Migration 53: Financial Tables for CFO Payments View
-- Story: STORY-5.0 — CFO Payments View
-- Date: 2026-03-16
-- ============================================================

-- =============
-- TABLE 1: god_financial_snapshots
-- Weekly snapshots of payment status distribution
-- Call fn_financial_snapshot() weekly via pg_cron or edge function
-- =============

CREATE TABLE IF NOT EXISTS god_financial_snapshots (
  snapshot_date DATE NOT NULL PRIMARY KEY,
  em_dia_count INTEGER DEFAULT 0,
  atrasado_count INTEGER DEFAULT 0,
  quitado_count INTEGER DEFAULT 0,
  sem_contrato_count INTEGER DEFAULT 0,
  total_mentorados INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

GRANT SELECT ON god_financial_snapshots TO authenticated;

-- =============
-- TABLE 2: god_financial_logs
-- Audit trail for all financial actions
-- =============

CREATE TABLE IF NOT EXISTS god_financial_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  mentorado_id BIGINT NOT NULL REFERENCES "case".mentorados(id),
  old_status TEXT,
  new_status TEXT,
  action_type TEXT NOT NULL CHECK (action_type IN ('status_change', 'note', 'contract_update')),
  observacao TEXT,
  changed_by TEXT NOT NULL,
  changed_by_user_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_financial_logs_mentorado ON god_financial_logs(mentorado_id);
CREATE INDEX idx_financial_logs_created ON god_financial_logs(created_at DESC);

GRANT SELECT, INSERT ON god_financial_logs TO authenticated;

-- =============
-- FUNCTION: fn_financial_snapshot()
-- Populates god_financial_snapshots with current counts
-- Schedule: weekly via pg_cron or Supabase edge function
-- Usage: SELECT fn_financial_snapshot();
-- =============

CREATE OR REPLACE FUNCTION fn_financial_snapshot()
RETURNS void AS $$
BEGIN
  INSERT INTO god_financial_snapshots (
    snapshot_date,
    em_dia_count,
    atrasado_count,
    quitado_count,
    sem_contrato_count,
    total_mentorados
  )
  SELECT
    CURRENT_DATE,
    COUNT(*) FILTER (WHERE COALESCE(status_financeiro, 'em_dia') IN ('em_dia', 'pago')),
    COUNT(*) FILTER (WHERE status_financeiro = 'atrasado'),
    COUNT(*) FILTER (WHERE status_financeiro = 'quitado'),
    COUNT(*) FILTER (WHERE contrato_assinado = false),
    COUNT(*)
  FROM "case".mentorados
  WHERE ativo = true AND cohort IS DISTINCT FROM 'tese'
  ON CONFLICT (snapshot_date) DO UPDATE SET
    em_dia_count = EXCLUDED.em_dia_count,
    atrasado_count = EXCLUDED.atrasado_count,
    quitado_count = EXCLUDED.quitado_count,
    sem_contrato_count = EXCLUDED.sem_contrato_count,
    total_mentorados = EXCLUDED.total_mentorados,
    created_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Seed: populate today's snapshot
SELECT fn_financial_snapshot();
