-- ============================================================
-- Operon Dashboard — Reminders Cross-Links
-- 2026-03-12
-- ============================================================
-- OBJETIVO:
-- 1. Adicionar FKs lógicas em god_reminders para mentorado, task, call, PA
-- 2. Backfill mentorado_id via match de nome no título
-- 3. Índices parciais para queries rápidas
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. NOVAS COLUNAS
-- ─────────────────────────────────────────────────────────────
ALTER TABLE god_reminders
  ADD COLUMN IF NOT EXISTS mentorado_id  BIGINT,
  ADD COLUMN IF NOT EXISTS task_id       UUID,
  ADD COLUMN IF NOT EXISTS call_id       UUID,
  ADD COLUMN IF NOT EXISTS pa_acao_id    UUID;

-- ─────────────────────────────────────────────────────────────
-- 2. ÍNDICES PARCIAIS
-- ─────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_reminders_mentorado
  ON god_reminders (mentorado_id) WHERE mentorado_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_reminders_task
  ON god_reminders (task_id) WHERE task_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_reminders_call
  ON god_reminders (call_id) WHERE call_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_reminders_pa_acao
  ON god_reminders (pa_acao_id) WHERE pa_acao_id IS NOT NULL;

-- ─────────────────────────────────────────────────────────────
-- 3. BACKFILL: mentorado_id via match de nome no título
--    Lógica: se o título do lembrete contém o nome do mentorado,
--    associar automaticamente.
-- ─────────────────────────────────────────────────────────────
UPDATE god_reminders r
SET mentorado_id = m.id
FROM "case".mentorados m
WHERE r.mentorado_id IS NULL
  AND r.titulo ILIKE '%' || m.nome || '%'
  AND length(m.nome) >= 3;  -- evitar matches falsos com nomes curtos
