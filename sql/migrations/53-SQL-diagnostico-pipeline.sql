-- ============================================================
-- Spalla Dashboard — Diagnóstico do Pipeline WhatsApp
-- 2026-03-16
-- ============================================================
-- INSTRUÇÕES: Executar estas queries UMA A UMA no Supabase SQL Editor
-- para diagnosticar o estado atual do pipeline de mensagens.
-- Estas são queries de LEITURA APENAS (SELECT) — não alteram dados.
-- ============================================================

-- ============================================================
-- A.1: Trigger auto_mark_responded existe?
-- ESPERADO: 1 row se migration 41 foi aplicada
-- ============================================================
SELECT tgname, tgrelid::regclass, tgenabled
FROM pg_trigger
WHERE tgname = 'trg_auto_mark_responded';

SELECT proname FROM pg_proc WHERE proname = 'auto_mark_responded';

-- ============================================================
-- A.2: Tabela wa_sessions existe?
-- ESPERADO: ~10 columns se migration 50/51 foi aplicada
-- ============================================================
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'wa_sessions'
ORDER BY ordinal_position;

SELECT schemaname, tablename, policyname, cmd
FROM pg_policies WHERE tablename = 'wa_sessions';

-- ============================================================
-- A.3: Contagem de mensagens (divergência = msgs perdidas)
-- ============================================================
SELECT
  (SELECT COUNT(*) FROM interacoes_mentoria) AS total_interacoes,
  (SELECT COUNT(*) FROM interacoes_mentoria WHERE created_at > NOW() - INTERVAL '7 days') AS interacoes_7d,
  (SELECT COUNT(*) FROM interacoes_mentoria WHERE created_at > NOW() - INTERVAL '24 hours') AS interacoes_24h;

-- ============================================================
-- A.4: Pendências fantasma (respondido=false mas TEM resposta posterior)
-- ============================================================
SELECT COUNT(*) AS pendencias_fantasma
FROM interacoes_mentoria i
WHERE i.requer_resposta = true
  AND (i.respondido = false OR i.respondido IS NULL)
  AND EXISTS (
    SELECT 1 FROM interacoes_mentoria resp
    WHERE resp.mentorado_id = i.mentorado_id
      AND resp.eh_equipe = true
      AND resp.created_at > i.created_at
      AND resp.created_at < i.created_at + INTERVAL '72 hours'
  );

SELECT COUNT(*) AS pendencias_atuais FROM vw_god_pendencias;

-- ============================================================
-- A.5: Campos NULL críticos (IA falhou na classificação)
-- ============================================================
SELECT
  COUNT(*) AS total_msgs,
  COUNT(*) FILTER (WHERE eh_equipe IS NULL) AS null_eh_equipe,
  COUNT(*) FILTER (WHERE requer_resposta IS NULL) AS null_requer_resposta,
  COUNT(*) FILTER (WHERE classificacao IS NULL AND classification IS NULL AND categoria IS NULL) AS null_classificacao,
  COUNT(*) FILTER (WHERE respondido IS NULL) AS null_respondido,
  ROUND(100.0 * COUNT(*) FILTER (WHERE eh_equipe IS NULL) / NULLIF(COUNT(*), 0), 1) AS pct_null_eh_equipe,
  ROUND(100.0 * COUNT(*) FILTER (WHERE requer_resposta IS NULL) / NULLIF(COUNT(*), 0), 1) AS pct_null_requer_resposta
FROM interacoes_mentoria;

-- Breakdown por semana
SELECT
  DATE_TRUNC('week', created_at) AS semana,
  COUNT(*) AS total,
  COUNT(*) FILTER (WHERE eh_equipe IS NULL) AS null_eh_equipe,
  COUNT(*) FILTER (WHERE requer_resposta IS NULL) AS null_requer_resposta
FROM interacoes_mentoria
WHERE created_at > NOW() - INTERVAL '8 weeks'
GROUP BY 1 ORDER BY 1 DESC;
