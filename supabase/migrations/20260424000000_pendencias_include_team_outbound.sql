-- Fix: vw_god_pendencias estava excluindo TUDO com eh_equipe=true
-- Problema: o filtro do #530 (commit 2d24455) joga fora mensagens da equipe
--   que esperam resposta do mentorado (Hugo perguntando, Heitor pedindo
--   confirmação, Lara pedindo material, etc.) — 45 pendências reais sumiam.
--
-- Comprovação 2026-04-23:
--   universo total requer_resposta=true AND respondido=false → 45
--   filtro atual eh_equipe=false                              →  0  (sumia tudo)
--
-- Decisão: mostrar TUDO que requer resposta. UI passa a distinguir via
-- coluna eh_equipe + autor_identificado se quem escreveu foi equipe ou
-- mentorado, e usa isso pra renderizar badge contextual.

DROP VIEW IF EXISTS vw_god_pendencias CASCADE;

CREATE OR REPLACE VIEW vw_god_pendencias AS
SELECT
  m.id                                                             AS mentorado_id,
  m.nome                                                           AS mentorado_nome,
  m.consultor_responsavel,
  m.grupo_whatsapp_id,
  i.id                                                             AS interacao_id,
  LEFT(i.conteudo, 200)                                            AS conteudo_truncado,
  i.message_type                                                   AS tipo_interacao,
  i.urgencia_resposta,
  i.created_at,
  ROUND(EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600, 1)      AS horas_pendente,
  CASE
    WHEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 > 48 THEN 'critico'
    WHEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 > 24 THEN 'alto'
    WHEN EXTRACT(EPOCH FROM (NOW() - i.created_at)) / 3600 > 12 THEN 'medio'
    ELSE 'baixo'
  END                                                              AS prioridade_calculada,
  -- Novos campos: UI usa pra mostrar badge "Equipe → Mentorado" vs "Mentorado → Equipe"
  COALESCE(i.eh_equipe, false)                                     AS eh_equipe,
  i.autor_identificado,
  CASE
    WHEN COALESCE(i.eh_equipe, false) THEN 'team_to_mentee'
    ELSE 'mentee_to_team'
  END                                                              AS direcao
FROM interacoes_mentoria i
JOIN mentorados m ON i.mentorado_id = m.id
WHERE i.requer_resposta = true
  AND i.respondido      = false
  AND m.ativo           = true
  AND m.cohort IS DISTINCT FROM 'tese'
ORDER BY i.created_at ASC;

GRANT SELECT ON vw_god_pendencias TO authenticated, anon;

-- Recria fn_god_alerts (foi dropada com CASCADE)
-- Definição idêntica ao migration 20260414000000, sem mudança de lógica
CREATE OR REPLACE FUNCTION fn_god_alerts()
RETURNS TABLE (
  alerta_tipo       text,
  severidade        text,
  mentorado_id      integer,
  mentorado_nome    text,
  descricao         text,
  valor_referencia  text,
  data_referencia   timestamptz
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
  RETURN QUERY
  SELECT q.a_tipo, q.a_sev, q.a_mid, q.a_nome, q.a_desc, q.a_val, q.a_data
  FROM (
    -- 1. Msgs sem resposta >12h (agora pega equipe→mentorado também)
    SELECT
      'sem_resposta'::text AS a_tipo,
      CASE
        WHEN gp.horas_pendente > 48 THEN 'critico'
        WHEN gp.horas_pendente > 24 THEN 'alto'
        ELSE 'medio'
      END::text                                                    AS a_sev,
      gp.mentorado_id::integer                                     AS a_mid,
      gp.mentorado_nome::text                                      AS a_nome,
      ('Mensagem pendente ha ' || ROUND(gp.horas_pendente) || 'h')::text AS a_desc,
      gp.horas_pendente::text                                      AS a_val,
      gp.created_at                                                AS a_data
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
      ('Possui ' || go3.tarefas_atrasadas || ' tarefa(s) atrasada(s)')::text,
      go3.tarefas_atrasadas::text,
      NOW()
    FROM vw_god_overview go3
    WHERE go3.tarefas_atrasadas > 2
  ) q
  ORDER BY
    CASE q.a_sev WHEN 'critico' THEN 1 WHEN 'alto' THEN 2 ELSE 3 END,
    q.a_data DESC NULLS LAST;
END;
$$;

GRANT EXECUTE ON FUNCTION fn_god_alerts() TO authenticated, anon;
