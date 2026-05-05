-- ============================================================
-- Spalla Dashboard — Auto-Mark Responded: trigger gêmeo (mentee)
-- 2026-04-30
-- ============================================================
-- PROBLEMA: O trigger atual (migration 56) só dispara quando o time
-- envia mensagem nova, então só resolve pendência se o time continua
-- a conversa. Quando a mentorada responde mas o time não retorna em
-- 72h, a pendência fica órfã (status_pendencia=aberta para sempre).
--
-- Sintoma observado em 2026-04-30: card "Reforço & Compromissos"
-- mostrando Karina Cabelino (118h crítico), Renata Aleixo (117h),
-- Carolina (73h), Maria (64h), Jessica (24h) com 1+ mensagens da
-- mentorada após a pendência — todas respondidas mas marcadas como
-- abertas.
--
-- CORREÇÃO: trigger gêmeo que dispara em INSERT de msg da mentorada
-- (eh_equipe=false) e marca pendências team→mentee anteriores
-- (até 72h atrás) como respondido=true. Atualiza também a função
-- fix_phantom_pendencias() para considerar respostas da mentee.
-- ============================================================

-- 1. Function que reage a msg da mentorada
CREATE OR REPLACE FUNCTION auto_mark_responded_by_mentee()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NEW.eh_equipe = false AND NEW.mentorado_id IS NOT NULL THEN
    UPDATE interacoes_mentoria
    SET respondido = true
    WHERE mentorado_id = NEW.mentorado_id
      AND eh_equipe = true
      AND requer_resposta = true
      AND (respondido = false OR respondido IS NULL)
      AND created_at > NEW.created_at - INTERVAL '72 hours'
      AND created_at < NEW.created_at;
  END IF;
  RETURN NEW;
END;
$$;

-- 2. Trigger gêmeo
DROP TRIGGER IF EXISTS trg_auto_mark_responded_by_mentee ON interacoes_mentoria;
CREATE TRIGGER trg_auto_mark_responded_by_mentee
  AFTER INSERT ON interacoes_mentoria
  FOR EACH ROW
  WHEN (NEW.eh_equipe = false AND NEW.mentorado_id IS NOT NULL)
  EXECUTE FUNCTION auto_mark_responded_by_mentee();

-- 3. fix_phantom_pendencias() expandida — considera resposta da
--    mentorada OU do time como sinal de "pendência atendida"
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
          AND resp.created_at > i.created_at
          AND resp.created_at < i.created_at + INTERVAL '72 hours'
          AND (
            -- resposta do time (caso original)
            (i.eh_equipe = false AND resp.eh_equipe = true)
            OR
            -- resposta da mentorada para pendência team→mentee (novo)
            (i.eh_equipe = true AND resp.eh_equipe = false)
          )
      )
  )
  UPDATE interacoes_mentoria
  SET respondido = true
  WHERE id IN (SELECT id FROM phantoms);

  GET DIAGNOSTICS v_count = ROW_COUNT;

  RETURN QUERY SELECT v_count, jsonb_build_object(
    'timestamp', NOW(),
    'fixed', v_count,
    'description', 'Pendências fantasma corrigidas (team+mentee)'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION fix_phantom_pendencias() TO authenticated, anon;

-- 4. Cleanup retroativo: pega TODAS as pendências team→mentee onde
--    a mentorada respondeu depois (sem janela 72h, retroativo único)
WITH mentee_responses AS (
  SELECT DISTINCT ON (mentorado_id, team_msg_id)
    i.id AS team_msg_id,
    i.mentorado_id,
    i.created_at AS team_at,
    resp.created_at AS responded_at
  FROM interacoes_mentoria i
  JOIN interacoes_mentoria resp
    ON resp.mentorado_id = i.mentorado_id
   AND resp.eh_equipe = false
   AND resp.created_at > i.created_at
  WHERE i.eh_equipe = true
    AND i.requer_resposta = true
    AND (i.respondido = false OR i.respondido IS NULL)
  ORDER BY i.mentorado_id, i.id, resp.created_at ASC
)
UPDATE interacoes_mentoria i
SET respondido = true
FROM mentee_responses mr
WHERE i.id = mr.team_msg_id;

-- 5. Comentário e tracking
COMMENT ON FUNCTION auto_mark_responded_by_mentee() IS
  'Trigger gêmeo do auto_mark_responded: dispara em msg da mentorada e marca pendências team→mentee anteriores como respondidas (janela 72h).';
