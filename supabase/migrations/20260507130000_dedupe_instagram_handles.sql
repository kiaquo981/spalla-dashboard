-- ─────────────────────────────────────────────────────────────
-- Fix: handles Instagram duplicados em "case".mentorados
--
-- Auditoria 2026-05-07 detectou 2 pares onde 2 mentees apontam pro
-- mesmo @ no IG. Em ambos, um dos lados tem cohort='tese' (rascunho/
-- entrada antiga) e o outro é o mentee real ativo:
--
--   @dradanielleferreiraa
--     id=1   Danielle Ferreira         cohort=N1     ← canônico
--     id=69  Danielle Junges           cohort=tese   ← rascunho
--
--   @dramichellenovelli
--     id=65  Michelle Fonte            cohort=tese   ← rascunho
--     id=139 Michelle Novelli Yoshiy   cohort=null   ← canônico
--
-- O CRON Apify semanal grava 1 row em mentorados_seguidores_history
-- por cada mentorado_id, então o mesmo perfil IG era contado 2x —
-- inflando custo Apify e poluindo a view de delta.
--
-- Decisão (menos destrutiva): zerar instagram nas entradas cohort='tese'.
-- Preserva o cadastro pra história. Quem decidir desativar essas entradas
-- depois, faz num PR de cleanup específico (envolve julgamento de produto).
-- ─────────────────────────────────────────────────────────────

-- Snapshot pré-fix (logging via SELECT — visível no log da migration)
SELECT
  'pre_fix_dup_audit' AS evento,
  jsonb_agg(jsonb_build_object(
    'id', id,
    'nome', nome,
    'instagram', instagram,
    'cohort', cohort,
    'ativo', ativo
  )) AS duplicados
FROM "case".mentorados
WHERE LOWER(REGEXP_REPLACE(instagram, '^@', '')) IN (
  'dradanielleferreiraa',
  'dramichellenovelli'
)
ORDER BY 1;

-- Limpa instagram apenas das entradas cohort='tese' identificadas
UPDATE "case".mentorados
   SET instagram = NULL,
       updated_at = NOW()
 WHERE id IN (69, 65)
   AND cohort = 'tese'
   AND LOWER(REGEXP_REPLACE(instagram, '^@', '')) IN (
     'dradanielleferreiraa',
     'dramichellenovelli'
   );

-- Index único parcial preventivo: bloqueia novos duplicados em mentees
-- ativos não-tese. Não trava entradas tese (rascunho), não trava NULL.
CREATE UNIQUE INDEX IF NOT EXISTS uniq_mentorados_instagram_active
  ON "case".mentorados (LOWER(REGEXP_REPLACE(instagram, '^@', '')))
  WHERE ativo = true
    AND instagram IS NOT NULL
    AND TRIM(instagram) != ''
    AND cohort IS DISTINCT FROM 'tese';

COMMENT ON INDEX "case".uniq_mentorados_instagram_active IS
  'Previne handles Instagram duplicados em mentees ativos não-tese. Permite duplicação em rascunhos (cohort=tese).';

-- Verificação pós-fix: deveria retornar 0 grupos
SELECT
  'post_fix_dup_count' AS evento,
  COUNT(*) AS grupos_duplicados_remanescentes
FROM (
  SELECT LOWER(REGEXP_REPLACE(instagram, '^@', '')) AS handle
  FROM "case".mentorados
  WHERE ativo = true
    AND instagram IS NOT NULL
    AND cohort IS DISTINCT FROM 'tese'
  GROUP BY 1
  HAVING COUNT(*) > 1
) g;
