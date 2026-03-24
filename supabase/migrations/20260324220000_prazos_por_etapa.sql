-- ================================================================
-- Migration: prazos_etapas JSONB em ds_documentos
-- Data: 2026-03-24
-- Contexto:
--   Prazo individual por etapa por dossiê.
--   Ex: {"producao_ia":"2026-04-01","revisao_mariza":"2026-04-05",...}
--   Permite Queila saber quando cada dossiê chega pra ela revisar.
-- ================================================================

ALTER TABLE ds_documentos
  ADD COLUMN IF NOT EXISTS prazos_etapas JSONB DEFAULT '{}'::jsonb;

COMMENT ON COLUMN ds_documentos.prazos_etapas IS
  'Prazo por etapa do pipeline. Chaves = IDs de DS_ESTAGIOS, valores = datas ISO (YYYY-MM-DD). Ex: {"revisao_queila":"2026-04-10"}';
