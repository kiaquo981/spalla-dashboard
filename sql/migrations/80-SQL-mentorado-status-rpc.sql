-- ============================================================
-- Spalla Dashboard — RPC pra atualizar status operacional do mentorado
-- 2026-05-05
-- ============================================================
-- PROBLEMA: PATCH /api/mentees/{id} via REST PATCH em
-- public.mentorados retorna sucesso mas a coluna contrato_assinado
-- (e status_financeiro, dia_pagamento) não atualiza. PostgREST
-- schema cache desatualizado — as colunas existem (a view
-- vw_god_overview usa) mas o cache não as conhece, então PATCH
-- ignora silenciosamente.
--
-- SOLUÇÃO: função RPC plpgsql que:
-- 1. Garante colunas existem (ADD COLUMN IF NOT EXISTS)
-- 2. UPDATE direto via plpgsql (bypassa schema cache do REST)
-- 3. NOTIFY pra reload do cache
-- ============================================================

-- 1. Garante colunas (idempotente)
ALTER TABLE public.mentorados
  ADD COLUMN IF NOT EXISTS contrato_assinado boolean DEFAULT true,
  ADD COLUMN IF NOT EXISTS status_financeiro text DEFAULT 'em_dia',
  ADD COLUMN IF NOT EXISTS dia_pagamento integer;

-- 2. RPC pra atualizar status operacional (chamada pelo backend)
CREATE OR REPLACE FUNCTION public.set_mentorado_status(
  p_id integer,
  p_contrato_assinado boolean DEFAULT NULL,
  p_status_financeiro text DEFAULT NULL,
  p_dia_pagamento integer DEFAULT NULL
)
RETURNS TABLE(id integer, nome text, contrato_assinado boolean, status_financeiro text, dia_pagamento integer)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Validações
  IF p_status_financeiro IS NOT NULL
     AND p_status_financeiro NOT IN ('em_dia', 'atrasado', 'quitado', 'sem_contrato', 'pago') THEN
    RAISE EXCEPTION 'status_financeiro inválido: %', p_status_financeiro;
  END IF;
  IF p_dia_pagamento IS NOT NULL AND (p_dia_pagamento < 1 OR p_dia_pagamento > 31) THEN
    RAISE EXCEPTION 'dia_pagamento deve estar entre 1 e 31';
  END IF;

  UPDATE public.mentorados m
  SET
    contrato_assinado = COALESCE(p_contrato_assinado, m.contrato_assinado),
    status_financeiro = COALESCE(p_status_financeiro, m.status_financeiro),
    dia_pagamento     = CASE
                          WHEN p_dia_pagamento IS NULL AND p_dia_pagamento::text IS NULL THEN m.dia_pagamento
                          ELSE p_dia_pagamento
                        END,
    updated_at = NOW()
  WHERE m.id = p_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Mentorado não encontrado: id=%', p_id;
  END IF;

  RETURN QUERY
  SELECT m.id, m.nome, m.contrato_assinado, m.status_financeiro, m.dia_pagamento
  FROM public.mentorados m
  WHERE m.id = p_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.set_mentorado_status(integer, boolean, text, integer)
  TO authenticated, anon, service_role;

COMMENT ON FUNCTION public.set_mentorado_status IS
  'Atualiza status operacional do mentorado (contrato/financeiro/dia_pgto). Bypassa o schema cache desatualizado do PostgREST. Migration 80.';

-- 3. Força reload do schema cache do PostgREST
NOTIFY pgrst, 'reload schema';
