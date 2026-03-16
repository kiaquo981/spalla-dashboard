-- ============================================================
-- Spalla Dashboard — Fix: Cleanup de Pendências Fantasma
-- 2026-03-16
-- ============================================================
-- Function que pode rodar manualmente ou via cron para limpar
-- pendências que já foram respondidas mas não foram marcadas.
-- ============================================================

CREATE OR REPLACE FUNCTION fix_phantom_pendencias()
RETURNS TABLE(fixed_count INT, details JSONB)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_count INT;
BEGIN
  WITH phantoms AS (
    SELECT i.id
    FROM interacoes_mentoria i
    WHERE i.requer_resposta = true
      AND (i.respondido = false OR i.respondido IS NULL)
      AND EXISTS (
        SELECT 1 FROM interacoes_mentoria resp
        WHERE resp.mentorado_id = i.mentorado_id
          AND resp.eh_equipe = true
          AND resp.created_at > i.created_at
          AND resp.created_at < i.created_at + INTERVAL '72 hours'
      )
  )
  UPDATE interacoes_mentoria
  SET respondido = true
  WHERE id IN (SELECT id FROM phantoms);

  GET DIAGNOSTICS v_count = ROW_COUNT;

  RETURN QUERY SELECT v_count, jsonb_build_object(
    'timestamp', NOW(),
    'fixed', v_count,
    'description', 'Pendências fantasma corrigidas'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION fix_phantom_pendencias() TO authenticated, anon;

-- Executar cleanup imediato
SELECT * FROM fix_phantom_pendencias();
