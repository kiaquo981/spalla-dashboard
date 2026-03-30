-- ============================================================
-- Datas internas vs externas no dossiê
-- prazo_entrega = data EXTERNA (comunicada ao mentorado, 3 semanas pós-call)
-- prazo_interno = data INTERNA (prazo real da equipe, 2 semanas)
-- Date: 2026-03-30
-- ============================================================

-- 1. Add prazo_interno to ds_producoes
ALTER TABLE ds_producoes
ADD COLUMN IF NOT EXISTS prazo_interno DATE DEFAULT NULL;

COMMENT ON COLUMN ds_producoes.prazo_interno IS
  'Prazo INTERNO da equipe (geralmente 1 semana antes do prazo_entrega). Não visível pro mentorado.';

-- 2. Add prazo_interno to ds_documentos (per-doc deadline)
ALTER TABLE ds_documentos
ADD COLUMN IF NOT EXISTS prazo_interno DATE DEFAULT NULL;

COMMENT ON COLUMN ds_documentos.prazo_interno IS
  'Prazo INTERNO por documento. Se null, herda do ds_producoes.prazo_interno.';

-- 3. Add prazos por etapa (prazo interno de cada stage)
ALTER TABLE ds_documentos
ADD COLUMN IF NOT EXISTS prazo_producao_ia DATE DEFAULT NULL,
ADD COLUMN IF NOT EXISTS prazo_revisao_mariza DATE DEFAULT NULL,
ADD COLUMN IF NOT EXISTS prazo_revisao_kaique DATE DEFAULT NULL,
ADD COLUMN IF NOT EXISTS prazo_revisao_queila DATE DEFAULT NULL;
