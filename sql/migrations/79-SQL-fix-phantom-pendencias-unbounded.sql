-- ============================================================
-- Spalla Dashboard — fix_phantom_pendencias SEM janela 72h
-- 2026-05-05
-- ============================================================
-- PROBLEMA: A migration 78 criou fix_phantom_pendencias() com
-- janela INTERVAL '72 hours' entre a pendência team→mentee e a
-- resposta da mentee. Quando a mentee responde >72h depois (8d, 9d
-- etc), a pendência fica órfã pra sempre.
--
-- Sintoma 2026-05-05: card "Reforço & Compromissos" mostrando
-- Tatiana Clementino (9d), Camille Bragança (8d), Juliene Frighetto
-- (8d), Letícia Ambrosano (8d), Monica Felici (8d) — todas com
-- resposta da mentee no grupo, mas fora da janela de 72h.
--
-- CORREÇÃO: nova função fix_phantom_pendencias_unbounded() que
-- resolve qualquer pendência team→mentee onde a mentee respondeu
-- em qualquer momento posterior, sem limite. Pode ser chamada
-- sob demanda (não é trigger automático — perigoso retroativo).
--
-- O classifier Python (rodando a cada 30min no Mac via launchd)
-- chama esta função no início de cada run pra cleanup contínuo.
-- ============================================================

CREATE OR REPLACE FUNCTION fix_phantom_pendencias_unbounded()
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
      AND i.eh_equipe = true
      AND EXISTS (
        SELECT 1 FROM interacoes_mentoria resp
        WHERE resp.chat_id = i.chat_id
          AND resp.eh_equipe = false
          AND resp.created_at > i.created_at
        -- SEM janela de 72h: aceita qualquer resposta posterior da mentee
      )
  )
  UPDATE interacoes_mentoria
  SET respondido = true,
      status_pendencia = 'atendida',
      motivo_classificador = COALESCE(motivo_classificador, '') || ' [unbounded_cleanup]',
      classificado_em = NOW(),
      classificador_modelo = 'backfill_unbounded',
      classificador_confidence = 1.0
  WHERE id IN (SELECT id FROM phantoms);

  GET DIAGNOSTICS v_count = ROW_COUNT;

  RETURN QUERY SELECT v_count, jsonb_build_object(
    'timestamp', NOW(),
    'fixed', v_count,
    'description', 'Pendências team→mentee resolvidas (sem janela 72h)'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION fix_phantom_pendencias_unbounded() TO authenticated, anon, service_role;

COMMENT ON FUNCTION fix_phantom_pendencias_unbounded() IS
  'Resolve pendências team→mentee onde a mentee respondeu em QUALQUER momento posterior (sem janela 72h). Chamada pelo classifier Python a cada 30min. Migration 79.';
