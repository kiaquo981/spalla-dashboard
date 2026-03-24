-- ================================================================
-- Migration: garantir CASCADE e DELETE RLS em ds_producoes
-- Data: 2026-03-24
-- ================================================================

-- Adicionar CASCADE nos FKs que faltam
-- ds_eventos
DO $$ BEGIN
  ALTER TABLE ds_eventos DROP CONSTRAINT IF EXISTS ds_eventos_producao_id_fkey;
  ALTER TABLE ds_eventos ADD CONSTRAINT ds_eventos_producao_id_fkey
    FOREIGN KEY (producao_id) REFERENCES ds_producoes(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ds_ajustes
DO $$ BEGIN
  ALTER TABLE ds_ajustes DROP CONSTRAINT IF EXISTS ds_ajustes_producao_id_fkey;
  ALTER TABLE ds_ajustes ADD CONSTRAINT ds_ajustes_producao_id_fkey
    FOREIGN KEY (producao_id) REFERENCES ds_producoes(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ds_documentos (should already have CASCADE but ensure)
DO $$ BEGIN
  ALTER TABLE ds_documentos DROP CONSTRAINT IF EXISTS ds_documentos_producao_id_fkey;
  ALTER TABLE ds_documentos ADD CONSTRAINT ds_documentos_producao_id_fkey
    FOREIGN KEY (producao_id) REFERENCES ds_producoes(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- RLS: allow delete on ds_producoes
DO $$ BEGIN
  CREATE POLICY "ds_producoes_delete" ON ds_producoes FOR DELETE USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
