-- ============================================================
-- Spalla Dashboard — Backfill: eh_equipe NULL → determinístico
-- 2026-03-16
-- ============================================================
-- Quando o GPT falha na classificação, eh_equipe fica NULL.
-- Isso impede o trigger auto_mark_responded de funcionar.
-- Solução: preencher retroativamente usando telefone do sender.
-- ============================================================

-- Equipe CASE — telefones conhecidos
-- Heitor:  5527999473185
-- Kaique:  5511964682447
-- Lara:    5524992514909
-- Queila:  5527988918032
-- Thiago:  5511967755879

-- 1. Marcar como equipe se sender_phone é da equipe
UPDATE interacoes_mentoria
SET eh_equipe = true
WHERE eh_equipe IS NULL
  AND sender_phone IN (
    '5527999473185',
    '5511964682447',
    '5524992514909',
    '5527988918032',
    '5511967755879'
  );

-- 2. Marcar como NÃO equipe se sender_phone existe mas não é da equipe
UPDATE interacoes_mentoria
SET eh_equipe = false
WHERE eh_equipe IS NULL
  AND sender_phone IS NOT NULL
  AND sender_phone NOT IN (
    '5527999473185',
    '5511964682447',
    '5524992514909',
    '5527988918032',
    '5511967755879'
  );

-- 3. Report do backfill
SELECT
  'backfill_eh_equipe' AS operation,
  COUNT(*) FILTER (WHERE eh_equipe IS NULL) AS still_null,
  COUNT(*) FILTER (WHERE eh_equipe = true) AS is_equipe,
  COUNT(*) FILTER (WHERE eh_equipe = false) AS not_equipe,
  COUNT(*) AS total
FROM interacoes_mentoria;

-- 4. Re-executar cleanup de pendências fantasma após backfill
-- (agora que eh_equipe está preenchido, podemos encontrar mais fantasmas)
SELECT * FROM fix_phantom_pendencias();
