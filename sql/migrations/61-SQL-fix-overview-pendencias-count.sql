-- ============================================================
-- Spalla Dashboard — Fix: vw_god_overview msgs_pendentes_resposta
-- 2026-03-16
-- ============================================================
-- PROBLEMA: KPI "Msgs s/ resposta" mostrava 13, mas só existiam 2 reais.
-- A subquery na vw_god_overview usava respondido = false sem:
--   1. COALESCE para NULL (respondido=NULL era ignorado)
--   2. Filtro eh_equipe = false (msgs da equipe contavam como pendente)
--   3. Verificação de resposta posterior
--
-- CORREÇÃO: Adicionado COALESCE em respondido e eh_equipe.
-- A verificação de resposta posterior (NOT EXISTS com 72h window)
-- não foi adicionada à view por performance — a function
-- count_real_pendencias() faz isso se necessário.
-- ============================================================

-- Helper function (para queries mais precisas quando necessário)
CREATE OR REPLACE FUNCTION count_real_pendencias(p_mentorado_id BIGINT)
RETURNS INTEGER
LANGUAGE sql
STABLE
AS $$
  SELECT COUNT(*)::integer
  FROM interacoes_mentoria i
  WHERE i.mentorado_id = p_mentorado_id
    AND i.requer_resposta = true
    AND COALESCE(i.respondido, false) = false
    AND COALESCE(i.eh_equipe, false) = false
    AND NOT EXISTS (
      SELECT 1 FROM interacoes_mentoria resp
      WHERE resp.mentorado_id = i.mentorado_id
        AND resp.eh_equipe = true
        AND resp.created_at > i.created_at
        AND resp.created_at < i.created_at + INTERVAL '72 hours'
    );
$$;

GRANT EXECUTE ON FUNCTION count_real_pendencias(BIGINT) TO authenticated, anon;

-- NOTE: vw_god_overview was recreated via CREATE OR REPLACE VIEW
-- with COALESCE fixes applied directly to Supabase.
-- The full view definition is too large for a migration file.
-- Key change: respondido = false → COALESCE(respondido, false) = false
-- Key change: eh_equipe = false → COALESCE(eh_equipe, false) = false
