-- =============================================================================
-- SPALLA FIXES — Calls Recentes + Instagram + Contexto IA
-- =============================================================================
-- Executar no Supabase SQL Editor:
-- https://app.supabase.com/project/knusqfbvhsqworzyhvip/sql/editor
--
-- Objetivo:
-- 1. Filtrar calls para últimos 60 dias (remover calls antigas)
-- 2. Verificar dados de Instagram em mentorados
-- 3. Verificar dados de Contexto IA em extracoes_agente
--
-- Data: 2026-02-27
-- =============================================================================

-- ============================================================================
-- PASSO 1: FIX VIEW vw_god_calls — Filtrar por data
-- ============================================================================
DROP VIEW IF EXISTS vw_god_calls CASCADE;

CREATE OR REPLACE VIEW vw_god_calls AS
SELECT
  m.id AS mentorado_id,
  m.nome AS mentorado_nome,
  cm.id AS call_id,
  cm.data_call,
  COALESCE(cm.tipo_call, cm.tipo) AS tipo_call,
  cm.duracao_minutos,
  cm.link_gravacao,
  cm.link_transcricao,
  cm.zoom_topic,
  -- Analise IA
  ac.resumo,
  cm.principais_topicos,
  cm.decisoes_tomadas,
  ac.proximos_passos,
  ac.gargalos,
  ac.feedbacks_consultora,
  cm.created_at
FROM calls_mentoria cm
JOIN mentorados m ON cm.mentorado_id = m.id
LEFT JOIN LATERAL (
  SELECT *
  FROM analises_call a
  WHERE a.mentorado_id = m.id
    AND a.data_call = cm.data_call::date
  ORDER BY a.created_at DESC
  LIMIT 1
) ac ON true
WHERE m.ativo = true
  AND m.cohort IS DISTINCT FROM 'tese'
  AND cm.data_call >= NOW() - INTERVAL '60 days'
ORDER BY cm.data_call DESC NULLS LAST;

-- ============================================================================
-- PASSO 2: Verificar dados de Instagram
-- ============================================================================
-- Execute esta query para ver quem tem Instagram preenchido:
SELECT id, nome, instagram FROM mentorados
WHERE ativo = true AND instagram IS NOT NULL AND instagram != ''
ORDER BY nome;

-- Se aparecer vazio, você precisa preencher manualmente em:
-- https://app.supabase.com/project/knusqfbvhsqworzyhvip/editor/tableEdit/mentorados

-- ============================================================================
-- PASSO 3: Verificar Contexto IA
-- ============================================================================
-- Execute esta query para ver quem tem contexto IA preenchido:
SELECT
  mentorado_id,
  mentorado_nome,
  cenario_atual,
  COUNT(*) as campos_preenchidos
FROM vw_god_contexto_ia
WHERE cenario_atual IS NOT NULL AND cenario_atual != ''
GROUP BY mentorado_id, mentorado_nome, cenario_atual
ORDER BY mentorado_nome;

-- Se aparecer vazio, precisa rodas os agentes IA em Supabase
-- Via tabela: extracoes_agente com agente_tipo = 'DIAGNOSTICO'

-- ============================================================================
-- PASSO 4: Verificar Transcrições de Calls
-- ============================================================================
-- Execute esta query para ver calls com transcrições:
SELECT id, data_call, mentorado_id, zoom_topic, link_transcricao
FROM calls_mentoria
WHERE link_transcricao IS NOT NULL AND link_transcricao != ''
ORDER BY data_call DESC
LIMIT 10;

-- Se aparecer vazio, precisa preencher manualmente ou integrar com Zoom API

-- ============================================================================
-- PASSO 5: Recompile fn_god_mentorado_deep (já vai usar a nova view)
-- ============================================================================
-- A função fn_god_mentorado_deep usa vw_god_calls internamente
-- Como alteramos a view, ela vai passar a retornar calls recentes automaticamente
-- Nenhuma ação necessária — já funciona!

-- Teste:
SELECT fn_god_mentorado_deep(1); -- Retorna JSON com últimas 5 calls (agora filtra 60 dias)
