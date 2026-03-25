-- Remove UNIQUE constraint on mentorado_id — permite múltiplas produções por mentorado
ALTER TABLE ds_producoes DROP CONSTRAINT IF EXISTS ds_producoes_mentorado_id_key;
