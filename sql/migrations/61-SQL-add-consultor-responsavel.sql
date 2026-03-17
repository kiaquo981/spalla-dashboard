-- =============================================================================
-- MIGRATION 61: Add consultor_responsavel to mentorados
-- =============================================================================
-- Purpose: Enable "Minha Carteira" filter in Spalla Dashboard
-- Consultores: Lara, Heitor (1:1 relationship with mentorados)
-- =============================================================================

-- Step 1: Add column
ALTER TABLE mentorados ADD COLUMN IF NOT EXISTS consultor_responsavel TEXT;

-- Step 2: Create index for filter performance
CREATE INDEX IF NOT EXISTS idx_mentorados_consultor
  ON mentorados(consultor_responsavel)
  WHERE consultor_responsavel IS NOT NULL;

-- Step 3: Seed data — Lara's portfolio (20 mentorados)
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Luciana Saraiva%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Livia Lyra%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Mannu Carvalho%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Juliana Altavilla%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Erica Macedo%' OR nome ILIKE '%Érica Macedo%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Deisy Porto%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Thielly Prado%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Lauanne Santos%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Amanda Ribeiro%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Letícia Ambrosano%' OR nome ILIKE '%Leticia Ambrosano%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Maria Spindola%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Caroline Bittencourt%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Tatiana Clementino%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Tayslara Belarmino%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Yara Fernandes%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Michelle Novelli%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Jordanna%Osaki%' OR nome ILIKE '%Jordanna%Diniz%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Danyella Truiz%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Juliene%Frighetto%';
UPDATE mentorados SET consultor_responsavel = 'Lara' WHERE nome ILIKE '%Lediane%Santana%' OR nome ILIKE '%Lediane%Dentine%';

-- Step 4: Seed data — Heitor's portfolio (19 mentorados)
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Danielle Ferreira%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Raqui Piolli%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Silvane Castro%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Hevellin%' OR nome ILIKE '%Hevellin Félix%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Carolina Sampaio%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Renata Aleixo%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Mônica Felici%' OR nome ILIKE '%Monica Felici%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Paula Monteiro%' OR nome ILIKE '%Kava%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Gustavo Guerra%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Camille%Bragança%' OR nome ILIKE '%Camille%Bragan%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Miriam Alves%' OR nome ILIKE '%Miriam%Velho%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Rosalie Matuk%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Karina Cabelino%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Thiago%Kailer%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Betina Franciosi%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Daniela Morais%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Débora%Goldmeier%' OR nome ILIKE '%Debora%Goldmeier%' OR nome ILIKE '%Débora%Cadore%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Vânia de Paula%' OR nome ILIKE '%Vania de Paula%';
UPDATE mentorados SET consultor_responsavel = 'Heitor' WHERE nome ILIKE '%Paulo%Rodrigues%';

-- Step 5: Verification
-- After running, verify counts:
-- SELECT consultor_responsavel, COUNT(*) FROM mentorados WHERE ativo = true AND cohort IS DISTINCT FROM 'tese' GROUP BY consultor_responsavel;
-- Expected: Lara ~20, Heitor ~18-19, NULL = any unmatched

-- Step 6: Add column comment
COMMENT ON COLUMN mentorados.consultor_responsavel IS 'Consultor responsável pela carteira deste mentorado (Lara ou Heitor). Usado no filtro "Minha Carteira" do Spalla Dashboard.';
