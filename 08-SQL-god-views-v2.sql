-- =============================================================================
-- SPALLA DASHBOARD V2 — "GOD VIEW" SQL VIEWS & FUNCTIONS
-- =============================================================================
-- Projeto Supabase: knusqfbvhsqworzyhvip (CASE Principal)
-- Schema: public
-- Data: 2026-02-16
--
-- OBJETIVO: Consolidar dados do programa CASE em views limpas para a Spalla.
-- Foco em informacoes ACIONAVEIS — sem ruido, sem dados que ninguem olha.
--
-- DADOS (16/02/2026):
--   40 mentorados ativos (30 N1 + 10 N2), filtrados de 62 total
--   226 calls | ~260 analises | 505 extracoes IA | 93 planos
--   23.840 msgs WhatsApp | ~104 marcos | 1.362 direcionamentos
--   273 tarefas (9 acordadas + 264 equipe)
--
-- FILTRO PRINCIPAL:
--   WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'
--
-- ARQUITETURA:
--   9 views (5 auxiliares + 4 principais) + 2 functions
--   Overview enxuto: 24 colunas (sem ruido)
--   Timeline: sem WhatsApp (ela ja ve no celular)
--   Deep function: 9 secoes (sem duplicacao)
-- =============================================================================


-- =============================================================================
-- STEP 0: DROP VIEWS/FUNCTIONS ANTIGAS (ordem reversa de dependencia)
-- =============================================================================
DROP FUNCTION IF EXISTS fn_god_alerts() CASCADE;
DROP FUNCTION IF EXISTS fn_god_mentorado_deep(bigint) CASCADE;
DROP VIEW IF EXISTS vw_god_cohort CASCADE;
DROP VIEW IF EXISTS vw_god_timeline CASCADE;
DROP VIEW IF EXISTS vw_god_overview CASCADE;
DROP VIEW IF EXISTS vw_god_tarefas CASCADE;
DROP VIEW IF EXISTS vw_god_vendas CASCADE;
DROP VIEW IF EXISTS vw_god_direcionamentos CASCADE;
DROP VIEW IF EXISTS vw_god_calls CASCADE;
DROP VIEW IF EXISTS vw_god_pendencias CASCADE;
DROP VIEW IF EXISTS vw_god_contexto_ia CASCADE;


-- =============================================================================
-- STEP 1: INDEXES (performance)
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_god_interacoes_pending
  ON interacoes_mentoria(mentorado_id, requer_resposta, respondido)
  WHERE requer_resposta = true AND respondido = false;

CREATE INDEX IF NOT EXISTS idx_god_extracoes_latest
  ON extracoes_agente(mentorado_id, agente_tipo, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_god_docs_latest
  ON documentos_plano_acao(mentorado_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_god_calls_latest
  ON calls_mentoria(mentorado_id, data_call DESC);

CREATE INDEX IF NOT EXISTS idx_god_analises_latest
  ON analises_call(mentorado_id, data_call DESC);

CREATE INDEX IF NOT EXISTS idx_god_direcionamentos_mentorado
  ON direcionamentos(mentorado_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_god_marcos_mentorado
  ON marcos_mentorado(mentorado_id, created_at DESC);


-- =============================================================================
-- STEP 2: VIEWS AUXILIARES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 2.1  vw_god_contexto_ia
-- Ultimo output de cada agente IA por mentorado
-- Fonte: extracoes_agente + documentos_plano_acao
-- NOTA: timestamps de processamento removidos (ninguem precisa saber quando a IA rodou)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_god_contexto_ia AS
WITH latest_extracoes AS (
  SELECT DISTINCT ON (mentorado_id, agente_tipo)
    mentorado_id,
    agente_tipo,
    output_json,
    output_text,
    created_at
  FROM extracoes_agente
  WHERE agente_tipo IN (
    'DIAGNOSTICO', 'ESTRATEGIAS', 'TAREFAS_MENTORADO',
    'TAREFAS_MENTORA', 'PRAZOS'
  )
  ORDER BY mentorado_id, agente_tipo, created_at DESC
),
latest_doc AS (
  SELECT DISTINCT ON (mentorado_id)
    mentorado_id,
    titulo AS ultimo_plano_titulo,
    foco_principal AS ultimo_foco,
    completude_score AS completude_plano,
    created_at AS ultimo_plano_em
  FROM documentos_plano_acao
  WHERE status != 'RASCUNHO'
  ORDER BY mentorado_id, created_at DESC
)
SELECT
  m.id AS mentorado_id,
  m.nome AS mentorado_nome,
  -- Diagnostico
  diag.output_json->>'cenario_atual' AS cenario_atual,
  diag.output_json->'gargalos' AS gargalos,
  diag.output_json->'ativos' AS ativos,
  -- Tarefas pendentes
  tm.output_json AS tarefas_mentorado_pendentes,
  tq.output_json AS tarefas_queila_pendentes,
  -- Estrategias e prazos
  est.output_json AS estrategias_atuais,
  pz.output_json AS prazos_proximos,
  -- Plano de acao
  ld.ultimo_plano_titulo,
  ld.ultimo_foco,
  ld.completude_plano,
  ld.ultimo_plano_em
FROM mentorados m
LEFT JOIN latest_extracoes diag
  ON diag.mentorado_id = m.id AND diag.agente_tipo = 'DIAGNOSTICO'
LEFT JOIN latest_extracoes tm
  ON tm.mentorado_id = m.id AND tm.agente_tipo = 'TAREFAS_MENTORADO'
LEFT JOIN latest_extracoes tq
  ON tq.mentorado_id = m.id AND tq.agente_tipo = 'TAREFAS_MENTORA'
LEFT JOIN latest_extracoes est
  ON est.mentorado_id = m.id AND est.agente_tipo = 'ESTRATEGIAS'
LEFT JOIN latest_extracoes pz
  ON pz.mentorado_id = m.id AND pz.agente_tipo = 'PRAZOS'
LEFT JOIN latest_doc ld
  ON ld.mentorado_id = m.id
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese';


-- -----------------------------------------------------------------------------
-- 2.2  vw_god_pendencias
-- Mensagens WhatsApp pendentes de resposta (acionavel)
-- Fonte: interacoes_mentoria
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_god_pendencias AS
SELECT
  m.id AS mentorado_id,
  m.nome AS mentorado_nome,
  i.id AS interacao_id,
  LEFT(i.conteudo, 200) AS conteudo_truncado,
  i.message_type AS tipo_interacao,
  i.urgencia_resposta,
  i.created_at,
  ROUND(EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600, 1) AS horas_pendente,
  CASE
    WHEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 > 48 THEN 'critico'
    WHEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 > 24 THEN 'alto'
    WHEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 > 12 THEN 'medio'
    ELSE 'baixo'
  END AS prioridade_calculada
FROM interacoes_mentoria i
JOIN mentorados m ON i.mentorado_id = m.id
WHERE i.requer_resposta = true
  AND i.respondido = false
  AND m.ativo = true
  AND m.cohort IS DISTINCT FROM 'tese'
ORDER BY i.created_at ASC;


-- -----------------------------------------------------------------------------
-- 2.3  vw_god_calls
-- Historico de calls com analise IA (sem metadata tecnica)
-- Fonte: calls_mentoria + analises_call
-- CORTADO: zoom_meeting_id, call_status, sentimento, fase_identificada,
--   citacoes_relevantes, vendas_mencionadas, produto_mencionado,
--   ticket_mencionado, marcos_detectados, has_transcript, tarefas_geradas,
--   observacoes_equipe
-- -----------------------------------------------------------------------------
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
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'
ORDER BY cm.data_call DESC NULLS LAST;


-- -----------------------------------------------------------------------------
-- 2.4  vw_god_direcionamentos
-- Direcionamentos da Queila de 3 fontes
-- Fontes: direcionamentos + analises_call.feedbacks + extracoes TAREFAS_MENTORA
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_god_direcionamentos AS

-- Fonte 1: tabela direcionamentos
SELECT
  d.mentorado_id::integer AS mentorado_id,
  m.nome AS mentorado_nome,
  COALESCE(d.titulo, LEFT(d.descricao, 80)) AS texto,
  d.descricao AS texto_completo,
  d.created_at AS data,
  'direcionamento' AS fonte,
  d.status::text AS status,
  d.prioridade::text AS prioridade
FROM direcionamentos d
JOIN mentorados m ON d.mentorado_id = m.id
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'

UNION ALL

-- Fonte 2: feedbacks da consultora nas analises_call
SELECT
  ac.mentorado_id,
  m.nome AS mentorado_nome,
  fb AS texto,
  fb AS texto_completo,
  COALESCE(ac.data_call::timestamptz, ac.created_at) AS data,
  'call_feedback' AS fonte,
  'registrado' AS status,
  'media' AS prioridade
FROM analises_call ac
JOIN mentorados m ON ac.mentorado_id = m.id,
LATERAL unnest(ac.feedbacks_consultora) AS fb
WHERE ac.feedbacks_consultora IS NOT NULL
  AND array_length(ac.feedbacks_consultora, 1) > 0
  AND m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'

UNION ALL

-- Fonte 3: extracoes TAREFAS_MENTORA (IA)
SELECT
  m.id AS mentorado_id,
  m.nome AS mentorado_nome,
  LEFT(e.output_text, 200) AS texto,
  e.output_text AS texto_completo,
  e.created_at AS data,
  'extracao_ia' AS fonte,
  'extraido' AS status,
  'media' AS prioridade
FROM extracoes_agente e
JOIN mentorados m ON e.mentorado_id = m.id
WHERE e.agente_tipo = 'TAREFAS_MENTORA'
  AND e.output_text IS NOT NULL
  AND m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'

ORDER BY data DESC;


-- -----------------------------------------------------------------------------
-- 2.5  vw_god_vendas
-- Dados financeiros consolidados (sem detalhes de call)
-- Fontes: mentorados + metricas_mentorado
-- CORTADO: vendas_mencionadas/produto/ticket de analises_call (ruido)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_god_vendas AS
SELECT
  m.id AS mentorado_id,
  m.nome AS mentorado_nome,
  m.faturamento_atual,
  m.meta_faturamento,
  CASE
    WHEN m.meta_faturamento > 0 AND m.faturamento_atual > 0
    THEN ROUND((m.faturamento_atual / m.meta_faturamento) * 100, 1)
    ELSE 0
  END AS pct_meta_atingida,
  m.qtd_vendas_total,
  m.ja_vendeu,
  m.faturamento_mentoria,
  m.ticket_produto,
  vm.total_vendas_metricas,
  vm.ultima_venda_data
FROM mentorados m
LEFT JOIN (
  SELECT
    met.mentorado_id,
    SUM(met.valor_vendas) AS total_vendas_metricas,
    MAX(met.data) AS ultima_venda_data
  FROM metricas_mentorado met
  GROUP BY met.mentorado_id
) vm ON vm.mentorado_id = m.id
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese';


-- =============================================================================
-- STEP 3: VIEWS PRINCIPAIS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 3.1  vw_god_tarefas
-- Tarefas unificadas de 4 fontes
-- Fontes: tarefas_acordadas + tarefas_equipe + analises_call.proximos_passos
--         + documentos_plano_acao.secao_proximos_passos
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_god_tarefas AS

-- Fonte 1: tarefas_acordadas (manuais)
SELECT
  ta.mentorado_id::integer AS mentorado_id,
  m.nome AS mentorado_nome,
  ta.tarefa,
  ta.responsavel,
  ta.prioridade,
  ta.prazo::date AS prazo,
  ta.status,
  'tarefas_acordadas' AS fonte,
  ta.created_at AS data_criacao
FROM tarefas_acordadas ta
JOIN mentorados m ON ta.mentorado_id = m.id

UNION ALL

-- Fonte 2: tarefas_equipe
SELECT
  te.mentorado_id::integer AS mentorado_id,
  COALESCE(m.nome, te.mentorado_nome) AS mentorado_nome,
  te.tarefa,
  te.responsavel_nome AS responsavel,
  te.prioridade::text AS prioridade,
  te.prazo AS prazo,
  te.status::text AS status,
  'tarefas_equipe' AS fonte,
  te.created_at AS data_criacao
FROM tarefas_equipe te
LEFT JOIN mentorados m ON te.mentorado_id = m.id

UNION ALL

-- Fonte 3: proximos_passos de analises_call
SELECT
  ac.mentorado_id,
  m.nome AS mentorado_nome,
  pp AS tarefa,
  'mentorado' AS responsavel,
  'media' AS prioridade,
  NULL::date AS prazo,
  'pendente' AS status,
  'analise_call' AS fonte,
  ac.created_at AS data_criacao
FROM analises_call ac
JOIN mentorados m ON ac.mentorado_id = m.id,
LATERAL unnest(ac.proximos_passos) AS pp
WHERE ac.proximos_passos IS NOT NULL
  AND array_length(ac.proximos_passos, 1) > 0

UNION ALL

-- Fonte 4: secao_proximos_passos de documentos_plano_acao
SELECT
  m.id AS mentorado_id,
  m.nome AS mentorado_nome,
  item.value->>'descricao' AS tarefa,
  COALESCE(item.value->>'responsavel', 'mentorado') AS responsavel,
  COALESCE(item.value->>'prioridade', 'media') AS prioridade,
  (item.value->>'prazo')::date AS prazo,
  COALESCE(item.value->>'status', 'pendente') AS status,
  'plano_acao' AS fonte,
  d.created_at AS data_criacao
FROM documentos_plano_acao d
JOIN mentorados m ON d.mentorado_id = m.id
CROSS JOIN LATERAL jsonb_array_elements(
  CASE
    WHEN jsonb_typeof(d.secao_proximos_passos) = 'array' THEN d.secao_proximos_passos
    ELSE '[]'::jsonb
  END
) AS item(value)
WHERE d.secao_proximos_passos IS NOT NULL;


-- -----------------------------------------------------------------------------
-- 3.2  vw_god_overview
-- Vista Master ENXUTA — 24 colunas (era 45+)
-- So o que importa pra um card na lista de mentorados
-- Consumida por: pagina principal + fn_god_alerts
--
-- CORTADO: cidade, estado, data_inicio, tempo_programa_semanas,
--   marcos_atingidos (array), fase_health (redundante com risco_churn),
--   sinais_risco, faturamento_mentoria, ticket_produto, tem_produto,
--   produto_nome, produto_detectado, dossie_entregue,
--   call_estrategia_realizada, call_onboarding_realizada, ultimo_tipo_call,
--   total_extracoes, total_docs_plano, ultimo_foco_principal,
--   total_analises, participacoes_conselho
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_god_overview AS
WITH
-- WhatsApp stats
wa_stats AS (
  SELECT
    i.mentorado_id,
    COUNT(*) FILTER (WHERE i.created_at >= NOW() - INTERVAL '7 days') AS whatsapp_7d,
    COUNT(*) FILTER (WHERE i.created_at >= NOW() - INTERVAL '30 days') AS whatsapp_30d,
    COUNT(*) AS whatsapp_total,
    COUNT(*) FILTER (
      WHERE i.requer_resposta = true AND i.respondido = false
    ) AS msgs_pendentes_resposta,
    MAX(
      CASE
        WHEN i.requer_resposta = true AND i.respondido = false AND i.eh_equipe = false
        THEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600
        ELSE 0
      END
    ) AS horas_sem_resposta_equipe
  FROM interacoes_mentoria i
  WHERE i.mentorado_id IS NOT NULL
  GROUP BY i.mentorado_id
),
-- Call stats (so ultima call)
call_stats AS (
  SELECT
    cm.mentorado_id,
    MAX(cm.data_call) AS ultima_call_data
  FROM calls_mentoria cm
  GROUP BY cm.mentorado_id
),
-- Tarefas stats
tarefa_stats AS (
  SELECT
    mentorado_id,
    COUNT(*) FILTER (WHERE LOWER(status) = 'pendente') AS tarefas_pendentes_total,
    COUNT(*) FILTER (
      WHERE LOWER(status) = 'pendente'
        AND prazo IS NOT NULL AND prazo < NOW()
    ) AS tarefas_atrasadas
  FROM (
    SELECT mentorado_id::integer AS mentorado_id, status, prazo
    FROM tarefas_acordadas
    UNION ALL
    SELECT mentorado_id::integer, status::text, prazo::timestamptz
    FROM tarefas_equipe
    WHERE mentorado_id IS NOT NULL
  ) all_tasks
  GROUP BY mentorado_id
)
SELECT
  -- IDENTIDADE
  m.id,
  m.nome,
  m.instagram,
  m.email,
  m.cohort,

  -- PROGRESSO
  m.fase_jornada,
  m.sub_etapa,
  m.marco_atual,

  -- SAUDE
  m.risco_churn,
  m.score_engajamento AS engagement_score,
  m.score_implementacao AS implementation_score,

  -- FINANCEIRO
  m.faturamento_atual,
  m.meta_faturamento,
  CASE
    WHEN m.meta_faturamento > 0 AND m.faturamento_atual > 0
    THEN ROUND((m.faturamento_atual / m.meta_faturamento) * 100, 1)
    ELSE 0
  END AS pct_meta_atingida,
  m.qtd_vendas_total,
  m.ja_vendeu,

  -- WHATSAPP
  COALESCE(wa.whatsapp_7d, 0)::integer AS whatsapp_7d,
  COALESCE(wa.whatsapp_30d, 0)::integer AS whatsapp_30d,
  COALESCE(wa.whatsapp_total, 0)::integer AS whatsapp_total,
  COALESCE(wa.msgs_pendentes_resposta, 0)::integer AS msgs_pendentes_resposta,
  ROUND(COALESCE(wa.horas_sem_resposta_equipe, 0)::numeric, 1) AS horas_sem_resposta_equipe,

  -- CALLS
  cs.ultima_call_data,
  CASE
    WHEN cs.ultima_call_data IS NOT NULL
    THEN EXTRACT(DAY FROM (NOW() - cs.ultima_call_data))::integer
    ELSE NULL
  END AS dias_desde_call,

  -- TAREFAS
  COALESCE(ts.tarefas_pendentes_total, 0)::integer AS tarefas_pendentes,
  COALESCE(ts.tarefas_atrasadas, 0)::integer AS tarefas_atrasadas,
  
  -- CONTRATO & FINANCEIRO
  m.contrato_assinado,
  CASE 
    WHEN m.status_financeiro = 'atrasado' THEN 'atrasado'
    WHEN m.status_financeiro = 'em_dia' THEN 'em_dia'
    WHEN m.status_financeiro = 'quitado' THEN 'quitado'
    ELSE 'sem_contrato'
  END AS status_financeiro,
  p.nome AS produto_nome

FROM mentorados m
LEFT JOIN wa_stats wa ON wa.mentorado_id = m.id
LEFT JOIN call_stats cs ON cs.mentorado_id = m.id
LEFT JOIN tarefa_stats ts ON ts.mentorado_id = m.id
LEFT JOIN produtos p ON m.produto_id = p.id
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'
ORDER BY
  CASE m.fase_jornada
    WHEN 'escala' THEN 1
    WHEN 'otimizacao' THEN 2
    WHEN 'validacao' THEN 3
    WHEN 'concepcao' THEN 4
    WHEN 'onboarding' THEN 5
    ELSE 6
  END,
  m.nome;


-- -----------------------------------------------------------------------------
-- 3.3  vw_god_timeline
-- Timeline de eventos por mentorado
-- SEM WHATSAPP (ela ja ve no celular — era 50% do volume)
-- Fontes: calls + marcos + direcionamentos + planos + sessoes de grupo
-- Todos com filtro de mentorado ativo (corrigido)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_god_timeline AS

-- Calls individuais
SELECT
  cm.mentorado_id::integer AS mentorado_id,
  'call' AS evento_tipo,
  cm.data_call AS data,
  COALESCE(cm.tipo_call, cm.tipo, 'call') || ': ' || COALESCE(
    (SELECT ac.resumo FROM analises_call ac
     WHERE ac.mentorado_id = cm.mentorado_id AND ac.data_call = cm.data_call::date
     ORDER BY ac.created_at DESC LIMIT 1),
    COALESCE(cm.zoom_topic, 'Call registrada')
  ) AS titulo,
  NULL::text AS descricao,
  jsonb_build_object(
    'call_id', cm.id,
    'tipo', COALESCE(cm.tipo_call, cm.tipo),
    'duracao', cm.duracao_minutos
  ) AS metadata_json
FROM calls_mentoria cm
JOIN mentorados m ON cm.mentorado_id = m.id
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'

UNION ALL

-- Marcos atingidos
SELECT
  mm.mentorado_id,
  'marco' AS evento_tipo,
  COALESCE(mm.data_atingido::timestamptz, mm.created_at) AS data,
  'Marco: ' || mm.marco || ' (' || mm.fase || ')' AS titulo,
  mm.evidencia AS descricao,
  jsonb_build_object('fonte', mm.fonte, 'confianca', mm.confianca) AS metadata_json
FROM marcos_mentorado mm
JOIN mentorados m ON mm.mentorado_id = m.id
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'

UNION ALL

-- Direcionamentos
SELECT
  d.mentorado_id::integer AS mentorado_id,
  'direcionamento' AS evento_tipo,
  d.created_at AS data,
  'Direcionamento: ' || LEFT(COALESCE(d.titulo::text, d.descricao, ''), 80) AS titulo,
  LEFT(d.descricao, 200) AS descricao,
  jsonb_build_object('status', d.status, 'prioridade', d.prioridade) AS metadata_json
FROM direcionamentos d
JOIN mentorados m ON d.mentorado_id = m.id
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'

UNION ALL

-- Planos de acao gerados
SELECT
  dp.mentorado_id::integer AS mentorado_id,
  'plano_acao' AS evento_tipo,
  dp.created_at AS data,
  'Plano: ' || dp.titulo AS titulo,
  'Foco: ' || COALESCE(dp.foco_principal, 'N/A') AS descricao,
  jsonb_build_object('status', dp.status, 'completude', dp.completude_score) AS metadata_json
FROM documentos_plano_acao dp
JOIN mentorados m ON dp.mentorado_id = m.id
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'

UNION ALL

-- Sessoes de grupo (conselhos, QAs, aulas)
SELECT
  ac.mentorado_id,
  'grupo' AS evento_tipo,
  COALESCE(ac.data_call::timestamptz, ac.created_at) AS data,
  ac.tipo_call || ': ' || COALESCE(LEFT(ac.resumo, 80), 'Sessao de grupo') AS titulo,
  LEFT(ac.resumo, 200) AS descricao,
  jsonb_build_object('tipo', ac.tipo_call) AS metadata_json
FROM analises_call ac
JOIN mentorados m ON ac.mentorado_id = m.id
WHERE ac.tipo_call IN ('conselho', 'qa', 'aula', 'imersao')
  AND m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'

ORDER BY data DESC NULLS LAST;


-- -----------------------------------------------------------------------------
-- 3.4  vw_god_cohort
-- Distribuicao por fase do programa (sem stats globais repetidos em cada row)
-- CORTADO: total_active, total_calls_30d, pending_tasks_global,
--   pending_responses_global (eram o mesmo valor em cada linha)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_god_cohort AS
SELECT
  m.fase_jornada AS fase,
  COUNT(*) AS total_mentorados,
  COUNT(*) FILTER (WHERE m.risco_churn = 'critico') AS criticos,
  COUNT(*) FILTER (WHERE m.risco_churn = 'alto') AS altos,
  COUNT(*) FILTER (WHERE m.risco_churn = 'medio') AS medios,
  COUNT(*) FILTER (WHERE m.risco_churn = 'baixo') AS baixos,
  ROUND(AVG(m.score_engajamento), 1) AS avg_engagement,
  ROUND(AVG(m.score_implementacao), 1) AS avg_implementation
FROM mentorados m
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'
GROUP BY m.fase_jornada
ORDER BY
  CASE m.fase_jornada
    WHEN 'escala' THEN 1
    WHEN 'otimizacao' THEN 2
    WHEN 'validacao' THEN 3
    WHEN 'concepcao' THEN 4
    WHEN 'onboarding' THEN 5
    ELSE 6
  END;


-- =============================================================================
-- STEP 4: FUNCTIONS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 4.1  fn_god_mentorado_deep(p_id bigint)
-- JSON completo para pagina de detalhe — 9 secoes (era 11)
-- REMOVIDO: 'wins' (duplicava 'phase.marcos_atingidos') e 'milestones' (idem)
-- REDUZIDO: last_messages de 15 para 5 (contexto rapido, nao historico)
-- ADICIONADO: pct_meta_atingida no financial
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_god_mentorado_deep(p_id bigint)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result jsonb;
BEGIN
  SELECT jsonb_build_object(
    -- PERFIL
    'profile', (
      SELECT jsonb_build_object(
        'id', m.id,
        'nome', m.nome,
        'instagram', m.instagram,
        'cidade', m.cidade,
        'estado', m.estado,
        'email', m.email,
        'telefone', m.telefone,
        'cohort', m.cohort,
        'nicho', m.nicho,
        'data_inicio', m.data_inicio,
        'perfil_negocio', m.perfil_negocio,
        'frequencia_call', m.frequencia_call,
        'proxima_call', m.proxima_call_agendada
      )
      FROM mentorados m WHERE m.id = p_id
    ),

    -- FASE + MARCOS
    'phase', (
      SELECT jsonb_build_object(
        'fase_jornada', m.fase_jornada,
        'sub_etapa', m.sub_etapa,
        'marco_atual', m.marco_atual,
        'risco_churn', m.risco_churn,
        'engagement_score', m.score_engajamento,
        'implementation_score', m.score_implementacao,
        'health', CASE
          WHEN m.risco_churn = 'critico' THEN 'critico'
          WHEN m.risco_churn = 'alto' THEN 'atrasado'
          ELSE 'on_track'
        END,
        'marcos_atingidos', COALESCE(
          (SELECT jsonb_agg(jsonb_build_object(
            'marco', mm.marco, 'fase', mm.fase,
            'data', mm.data_atingido, 'evidencia', mm.evidencia
          ) ORDER BY mm.created_at)
          FROM marcos_mentorado mm WHERE mm.mentorado_id = p_id),
          '[]'::jsonb
        )
      )
      FROM mentorados m WHERE m.id = p_id
    ),

    -- FINANCEIRO
    'financial', (
      SELECT jsonb_build_object(
        'faturamento_atual', m.faturamento_atual,
        'meta_faturamento', m.meta_faturamento,
        'pct_meta_atingida', CASE
          WHEN m.meta_faturamento > 0 AND m.faturamento_atual > 0
          THEN ROUND((m.faturamento_atual / m.meta_faturamento) * 100, 1)
          ELSE 0
        END,
        'faturamento_mentoria', m.faturamento_mentoria,
        'qtd_vendas_total', m.qtd_vendas_total,
        'ticket_produto', m.ticket_produto,
        'ja_vendeu', m.ja_vendeu,
        'tem_produto', m.tem_produto
      )
      FROM mentorados m WHERE m.id = p_id
    ),

    -- CONTEXTO IA (via view simplificada)
    'context_ia', (
      SELECT row_to_json(ctx)::jsonb
      FROM vw_god_contexto_ia ctx
      WHERE ctx.mentorado_id = p_id
    ),

    -- ULTIMAS 5 CALLS (via view enxuta)
    'last_calls', COALESCE(
      (SELECT jsonb_agg(row_to_json(c)::jsonb ORDER BY c.data_call DESC)
       FROM (
         SELECT * FROM vw_god_calls gc
         WHERE gc.mentorado_id = p_id
         ORDER BY gc.data_call DESC NULLS LAST
         LIMIT 5
       ) c),
      '[]'::jsonb
    ),

    -- ULTIMAS 5 MSGS WHATSAPP (contexto rapido pre-call)
    'last_messages', COALESCE(
      (SELECT jsonb_agg(jsonb_build_object(
        'conteudo', LEFT(i.conteudo, 300),
        'sender', i.sender_name,
        'tipo', i.message_type,
        'requer_resposta', i.requer_resposta,
        'respondido', i.respondido,
        'created_at', i.created_at
       ) ORDER BY i.created_at DESC)
       FROM (
         SELECT *
         FROM interacoes_mentoria ix
         WHERE ix.mentorado_id = p_id
         ORDER BY ix.created_at DESC
         LIMIT 5
       ) i),
      '[]'::jsonb
    ),

    -- TAREFAS PENDENTES
    'pending_tasks', COALESCE(
      (SELECT jsonb_agg(jsonb_build_object(
        'tarefa', t.tarefa,
        'responsavel', t.responsavel,
        'prioridade', t.prioridade,
        'prazo', t.prazo,
        'fonte', t.fonte,
        'data_criacao', t.data_criacao
       ) ORDER BY t.data_criacao DESC)
       FROM vw_god_tarefas t
       WHERE t.mentorado_id = p_id
         AND LOWER(t.status) IN ('pendente', 'em_andamento')
       ),
      '[]'::jsonb
    ),

    -- TRAVAS ATIVAS
    'blockers', COALESCE(
      (SELECT jsonb_agg(jsonb_build_object(
        'tipo', tb.tipo,
        'area', tb.area,
        'descricao', tb.descricao,
        'frequencia', tb.frequencia,
        'primeira_mencao', tb.primeira_mencao,
        'ultima_mencao', tb.ultima_mencao
       ))
       FROM travas_bloqueios tb
       WHERE tb.mentorado_id = p_id AND tb.resolvido = false),
      '[]'::jsonb
    ),

    -- ULTIMOS 10 DIRECIONAMENTOS
    'directions', COALESCE(
      (SELECT jsonb_agg(row_to_json(d)::jsonb ORDER BY d.data DESC)
       FROM (
         SELECT * FROM vw_god_direcionamentos gd
         WHERE gd.mentorado_id = p_id
         ORDER BY gd.data DESC
         LIMIT 10
       ) d),
      '[]'::jsonb
    )
  ) INTO result;

  RETURN result;
END;
$$;


-- -----------------------------------------------------------------------------
-- 4.2  fn_god_alerts()
-- Alertas ativos priorizados por severidade
-- SIMPLIFICADO: sem_call agora detecta "nunca fez call" sem precisar total_analises
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_god_alerts()
RETURNS TABLE (
  alerta_tipo text,
  severidade text,
  mentorado_id integer,
  mentorado_nome text,
  descricao text,
  valor_referencia text,
  data_referencia timestamptz
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
  RETURN QUERY
  SELECT
    q.a_tipo,
    q.a_sev,
    q.a_mid,
    q.a_nome,
    q.a_desc,
    q.a_val,
    q.a_data
  FROM (

    -- 1. Msgs sem resposta >12h
    SELECT
      'sem_resposta'::text AS a_tipo,
      CASE
        WHEN gp.horas_pendente > 48 THEN 'critico'
        WHEN gp.horas_pendente > 24 THEN 'alto'
        ELSE 'medio'
      END::text AS a_sev,
      gp.mentorado_id::integer AS a_mid,
      gp.mentorado_nome::text AS a_nome,
      ('Mensagem pendente ha ' || ROUND(gp.horas_pendente) || 'h')::text AS a_desc,
      gp.horas_pendente::text AS a_val,
      gp.created_at AS a_data
    FROM vw_god_pendencias gp
    WHERE gp.horas_pendente > 12

    UNION ALL

    -- 2. Sem call >21 dias ou nunca fez call
    SELECT
      'sem_call'::text,
      CASE
        WHEN go2.dias_desde_call > 30 THEN 'critico'
        WHEN go2.dias_desde_call > 21 THEN 'alto'
        WHEN go2.ultima_call_data IS NULL THEN 'alto'
        ELSE 'medio'
      END::text,
      go2.id::integer,
      go2.nome::text,
      CASE
        WHEN go2.ultima_call_data IS NULL THEN 'Nunca fez call individual'
        ELSE 'Sem call ha ' || go2.dias_desde_call || ' dias'
      END::text,
      COALESCE(go2.dias_desde_call::text, 'N/A'),
      go2.ultima_call_data
    FROM vw_god_overview go2
    WHERE go2.dias_desde_call > 21
       OR go2.ultima_call_data IS NULL

    UNION ALL

    -- 3. Tarefas atrasadas (>2)
    SELECT
      'tarefas_atrasadas'::text,
      CASE
        WHEN go3.tarefas_atrasadas > 5 THEN 'critico'
        WHEN go3.tarefas_atrasadas > 3 THEN 'alto'
        ELSE 'medio'
      END::text,
      go3.id::integer,
      go3.nome::text,
      (go3.tarefas_atrasadas || ' tarefas atrasadas')::text,
      go3.tarefas_atrasadas::text,
      NULL::timestamptz
    FROM vw_god_overview go3
    WHERE go3.tarefas_atrasadas > 2

    UNION ALL

    -- 4. Risco critico/alto
    SELECT
      'risco_churn'::text,
      go4.risco_churn::text,
      go4.id::integer,
      go4.nome::text,
      ('Risco ' || go4.risco_churn ||
        CASE
          WHEN go4.engagement_score IS NOT NULL AND go4.engagement_score < 30
            THEN ' | Engajamento: ' || go4.engagement_score
          WHEN go4.implementation_score IS NOT NULL AND go4.implementation_score < 30
            THEN ' | Implementacao: ' || go4.implementation_score
          ELSE ''
        END)::text,
      go4.risco_churn::text,
      NULL::timestamptz
    FROM vw_god_overview go4
    WHERE go4.risco_churn IN ('critico', 'alto')

    UNION ALL

    -- 5. Sem WhatsApp >7 dias
    SELECT
      'sem_whatsapp'::text,
      CASE
        WHEN go5.whatsapp_7d = 0 AND go5.whatsapp_30d = 0 THEN 'alto'
        WHEN go5.whatsapp_7d = 0 THEN 'medio'
        ELSE 'baixo'
      END::text,
      go5.id::integer,
      go5.nome::text,
      ('Sem atividade WhatsApp ha >7 dias')::text,
      go5.whatsapp_7d::text,
      NULL::timestamptz
    FROM vw_god_overview go5
    WHERE go5.whatsapp_7d = 0
      AND go5.whatsapp_total > 0

  ) q
  ORDER BY
    CASE q.a_sev
      WHEN 'critico' THEN 1
      WHEN 'alto' THEN 2
      WHEN 'medio' THEN 3
      ELSE 4
    END,
    q.a_data ASC NULLS LAST;
END;
$$;


-- =============================================================================
-- STEP 5: GRANTS (Supabase roles)
-- =============================================================================
GRANT SELECT ON vw_god_overview TO authenticated, anon;
GRANT SELECT ON vw_god_tarefas TO authenticated, anon;
GRANT SELECT ON vw_god_calls TO authenticated, anon;
GRANT SELECT ON vw_god_contexto_ia TO authenticated, anon;
GRANT SELECT ON vw_god_pendencias TO authenticated, anon;
GRANT SELECT ON vw_god_direcionamentos TO authenticated, anon;
GRANT SELECT ON vw_god_vendas TO authenticated, anon;
GRANT SELECT ON vw_god_timeline TO authenticated, anon;
GRANT SELECT ON vw_god_cohort TO authenticated, anon;
GRANT EXECUTE ON FUNCTION fn_god_mentorado_deep(bigint) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION fn_god_alerts() TO authenticated, anon;


-- =============================================================================
-- STEP 6: VALIDACAO
-- =============================================================================
-- SELECT COUNT(*) FROM vw_god_overview;              -- 40
-- SELECT COUNT(*) FROM vw_god_tarefas;               -- ~803
-- SELECT COUNT(*) FROM vw_god_calls;                 -- ~211
-- SELECT COUNT(*) FROM vw_god_pendencias;            -- check
-- SELECT COUNT(*) FROM vw_god_timeline;              -- ~2000 (sem WhatsApp)
-- SELECT * FROM vw_god_cohort;                       -- 5 fases
-- SELECT fn_god_mentorado_deep(13);                  -- JSON 9 secoes
-- SELECT * FROM fn_god_alerts() LIMIT 20;            -- alertas
-- =============================================================================
-- FIM — god_views_v2.sql (enxuto)
-- =============================================================================

-- FUTURE: Add separate column for zoom_join_url when schema allows
-- ALTER TABLE calls_mentoria ADD COLUMN zoom_join_url TEXT;
-- This will separate join URLs from recording URLs (currently both use link_gravacao)
