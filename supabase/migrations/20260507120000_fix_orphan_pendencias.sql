-- ─────────────────────────────────────────────────────────────
-- Fix: pendências órfãs em estado inconsistente
-- Cenário: status_pendencia='atendida' mas respondido=false.
--
-- Causa: o cleanup_phantom_replied_unbounded (Python, classifier) +
-- fix_phantom_pendencias (SQL, migration 78/79) marcam status='atendida'
-- quando detectam mentee respondendo após >72h, mas só atualizam
-- respondido=true em alguns caminhos (não em todos).
--
-- Sintoma: mensagens ficam invisíveis no dashboard:
--   - vw_god_pendencias filtra implicitamente por status != 'atendida'
--   - "Aguardando Resposta" filtra por eh_equipe=false (essas órfãs são team→mentee)
--   - raw filter por respondido=false ainda as retorna — frontend não usa
--
-- Auditoria 2026-05-07: 7 itens órfãos.
--
-- Decisão: normalizar — quando status='atendida', marcar respondido=true
-- também. Reflete a realidade (foram resolvidas) e remove inconsistência
-- pra queries futuras só dependerem de respondido.
-- ─────────────────────────────────────────────────────────────

-- One-shot: limpa o backlog atual.
WITH atualizadas AS (
  UPDATE interacoes_mentoria
     SET respondido = true,
         respondido_em = COALESCE(respondido_em, topic_resolved_at, NOW()),
         updated_at = NOW()
   WHERE respondido = false
     AND status_pendencia = 'atendida'
  RETURNING id, mentorado_id, sender_name, timestamp
)
SELECT
  'orphan_pendencias_normalized' AS evento,
  COUNT(*) AS total_corrigidas,
  MIN(timestamp) AS pendencia_mais_antiga,
  MAX(timestamp) AS pendencia_mais_nova
FROM atualizadas;

-- Trigger preventivo: garante que futuras transições pra status='atendida'
-- sempre alinhem respondido=true. Idempotente: se já tá true, no-op.
CREATE OR REPLACE FUNCTION sync_respondido_with_status_pendencia()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.status_pendencia = 'atendida' AND COALESCE(NEW.respondido, false) = false THEN
    NEW.respondido := true;
    NEW.respondido_em := COALESCE(NEW.respondido_em, NEW.topic_resolved_at, NOW());
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_respondido_status ON interacoes_mentoria;
CREATE TRIGGER trg_sync_respondido_status
  BEFORE UPDATE OF status_pendencia ON interacoes_mentoria
  FOR EACH ROW
  WHEN (NEW.status_pendencia = 'atendida' AND COALESCE(NEW.respondido, false) = false)
  EXECUTE FUNCTION sync_respondido_with_status_pendencia();

COMMENT ON TRIGGER trg_sync_respondido_status ON interacoes_mentoria IS
  'Mantém respondido=true sempre que status_pendencia=atendida (regra de consistência pós-PR #626).';
