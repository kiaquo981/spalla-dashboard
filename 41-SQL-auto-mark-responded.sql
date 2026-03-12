-- ============================================================
-- Spalla Dashboard — Auto-Mark Messages as Responded
-- 2026-03-11
-- ============================================================
-- PROBLEMA: O v34 classifica mensagens e marca requer_resposta=true,
-- mas quando a equipe responde no WhatsApp (eh_equipe=true),
-- ninguém atualiza respondido=true nas mensagens anteriores.
-- Resultado: pendências fantasma que já foram respondidas.
--
-- SOLUÇÃO: Trigger que, ao inserir mensagem da equipe,
-- auto-marca todas as pendências anteriores do mesmo mentorado.
-- ============================================================

-- 1. Função do trigger
CREATE OR REPLACE FUNCTION auto_mark_responded()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Quando equipe envia mensagem, marca pendências anteriores como respondidas
  IF NEW.eh_equipe = true AND NEW.mentorado_id IS NOT NULL THEN
    UPDATE interacoes_mentoria
    SET respondido = true
    WHERE mentorado_id = NEW.mentorado_id
      AND requer_resposta = true
      AND respondido = false
      AND created_at < NEW.created_at;
  END IF;

  RETURN NEW;
END;
$$;

-- 2. Trigger (AFTER INSERT para não atrasar o INSERT do v34)
DROP TRIGGER IF EXISTS trg_auto_mark_responded ON interacoes_mentoria;
CREATE TRIGGER trg_auto_mark_responded
  AFTER INSERT ON interacoes_mentoria
  FOR EACH ROW
  WHEN (NEW.eh_equipe = true AND NEW.mentorado_id IS NOT NULL)
  EXECUTE FUNCTION auto_mark_responded();

-- 3. Cleanup retroativo: marcar como respondidas mensagens que já
--    têm resposta da equipe posterior (limpa as 53+ pendências fantasma)
WITH team_responses AS (
  SELECT DISTINCT ON (mentorado_id)
    mentorado_id,
    created_at AS responded_at
  FROM interacoes_mentoria
  WHERE eh_equipe = true
    AND mentorado_id IS NOT NULL
  ORDER BY mentorado_id, created_at DESC
)
UPDATE interacoes_mentoria i
SET respondido = true
FROM team_responses tr
WHERE i.mentorado_id = tr.mentorado_id
  AND i.requer_resposta = true
  AND i.respondido = false
  AND i.created_at < tr.responded_at;

-- 4. Índice para acelerar a busca do trigger
CREATE INDEX IF NOT EXISTS idx_interacoes_pending_response
  ON interacoes_mentoria (mentorado_id, created_at)
  WHERE requer_resposta = true AND respondido = false;

-- 5. Índice para acelerar busca de mensagens da equipe
CREATE INDEX IF NOT EXISTS idx_interacoes_team_messages
  ON interacoes_mentoria (mentorado_id, created_at DESC)
  WHERE eh_equipe = true;
