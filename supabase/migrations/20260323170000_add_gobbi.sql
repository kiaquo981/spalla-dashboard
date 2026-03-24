-- ================================================================
-- Add Felipe Gobbi to spalla_members + fix responsavel misassignment
-- Source: XLSX Mapeamento Global — Gob tasks were assigned to heitor
-- ================================================================

-- 1. Add Gobbi to equipe
INSERT INTO public.spalla_members (id, nome_completo, nome_curto, cargo, cor)
VALUES
  ('gobbi', 'Felipe Gobbi', 'Gobbi', 'Head de Produto & CS', '#f97316')
ON CONFLICT (id) DO NOTHING;

-- 2. Fix tasks where Gobbi is primary responsible but were assigned to heitor
-- 868hy5a1w: "Responsável: Gobbi (estratégia) + Lara + Heitor (execução)"
UPDATE public.god_tasks
SET responsavel = 'gobbi'
WHERE operon_id IN (
  '868hy5a1w'  -- PROCESSO: Jornada Completa da Mentoria — Fluxo Ideal + Rotinas de Acompanhamento
);
