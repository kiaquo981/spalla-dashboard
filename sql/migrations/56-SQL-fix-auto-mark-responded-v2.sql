-- ============================================================
-- Spalla Dashboard — Fix: auto_mark_responded com janela 72h
-- 2026-03-16
-- ============================================================
-- PROBLEMA: O trigger original (migration 41) marca TODAS as
-- pendências anteriores do mentorado como respondidas, sem limite
-- temporal. Se equipe responde hoje, pendência de 30 dias atrás
-- também é marcada como respondida (incorreto).
--
-- CORREÇÃO: Adicionar janela de 72h — só marca pendências das
-- últimas 72 horas como respondidas.
-- Também trata respondido IS NULL (antes só checava = false).
-- ============================================================

-- 1. Function corrigida
CREATE OR REPLACE FUNCTION auto_mark_responded()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NEW.eh_equipe = true AND NEW.mentorado_id IS NOT NULL THEN
    UPDATE interacoes_mentoria
    SET respondido = true
    WHERE mentorado_id = NEW.mentorado_id
      AND requer_resposta = true
      AND (respondido = false OR respondido IS NULL)
      AND created_at > NEW.created_at - INTERVAL '72 hours'
      AND created_at < NEW.created_at;
  END IF;
  RETURN NEW;
END;
$$;

-- 2. Recriar trigger (idempotente)
DROP TRIGGER IF EXISTS trg_auto_mark_responded ON interacoes_mentoria;
CREATE TRIGGER trg_auto_mark_responded
  AFTER INSERT ON interacoes_mentoria
  FOR EACH ROW
  WHEN (NEW.eh_equipe = true AND NEW.mentorado_id IS NOT NULL)
  EXECUTE FUNCTION auto_mark_responded();

-- 3. Índices (idempotentes)
CREATE INDEX IF NOT EXISTS idx_interacoes_pending_response
  ON interacoes_mentoria (mentorado_id, created_at)
  WHERE requer_resposta = true AND (respondido = false OR respondido IS NULL);

CREATE INDEX IF NOT EXISTS idx_interacoes_team_messages
  ON interacoes_mentoria (mentorado_id, created_at DESC)
  WHERE eh_equipe = true;
