-- ================================================================
-- Migration: garantir CASCADE e DELETE RLS em ds_producoes
-- Data: 2026-03-24
-- ================================================================

-- Adicionar CASCADE nos FKs que faltam
-- ds_eventos
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'ds_eventos_producao_id_fkey' AND table_name = 'ds_eventos') THEN
    ALTER TABLE ds_eventos DROP CONSTRAINT ds_eventos_producao_id_fkey;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'ds_eventos_producao_id_fkey' AND table_name = 'ds_eventos') THEN
    ALTER TABLE ds_eventos ADD CONSTRAINT ds_eventos_producao_id_fkey
      FOREIGN KEY (producao_id) REFERENCES ds_producoes(id) ON DELETE CASCADE;
  END IF;
END $$;

-- ds_ajustes
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'ds_ajustes_producao_id_fkey' AND table_name = 'ds_ajustes') THEN
    ALTER TABLE ds_ajustes DROP CONSTRAINT ds_ajustes_producao_id_fkey;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'ds_ajustes_producao_id_fkey' AND table_name = 'ds_ajustes') THEN
    ALTER TABLE ds_ajustes ADD CONSTRAINT ds_ajustes_producao_id_fkey
      FOREIGN KEY (producao_id) REFERENCES ds_producoes(id) ON DELETE CASCADE;
  END IF;
END $$;

-- ds_documentos (should already have CASCADE but ensure)
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'ds_documentos_producao_id_fkey' AND table_name = 'ds_documentos') THEN
    ALTER TABLE ds_documentos DROP CONSTRAINT ds_documentos_producao_id_fkey;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'ds_documentos_producao_id_fkey' AND table_name = 'ds_documentos') THEN
    ALTER TABLE ds_documentos ADD CONSTRAINT ds_documentos_producao_id_fkey
      FOREIGN KEY (producao_id) REFERENCES ds_producoes(id) ON DELETE CASCADE;
  END IF;
END $$;

-- RLS: allow delete on ds_producoes (authenticated/service_role only)
DROP POLICY IF EXISTS "ds_producoes_delete" ON ds_producoes;
CREATE POLICY "ds_producoes_delete" ON ds_producoes FOR DELETE USING (auth.role() IN ('authenticated', 'service_role'));
