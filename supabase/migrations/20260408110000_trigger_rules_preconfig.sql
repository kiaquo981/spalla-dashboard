-- ============================================================
-- Trigger Rules pré-configuradas
-- Mentorado muda de fase → tasks automáticas
-- ============================================================

-- Regra 1: Mentorado entra em onboarding → criar task de kickoff
INSERT INTO task_trigger_rules (nome, descricao, when_aggregate_type, when_event_type, when_payload_filter, then_template, origem, criado_por)
VALUES (
  'Onboarding: kickoff call',
  'Quando mentorado assina contrato e entra em onboarding, criar task de agendar kickoff call',
  'Mentorado',
  'MentoradoContract_signed',
  '{"to": "onboarding"}'::jsonb,
  '{
    "titulo": "Agendar kickoff call com mentorado",
    "descricao": "Mentorado acabou de assinar. Agendar a call de kickoff dentro de 48h.\n\n- Confirmar data/hora\n- Preparar pauta\n- Enviar link da call",
    "responsavel": "mariza",
    "prioridade": "alta",
    "especie": "one_time",
    "prazo_dias": 2
  }'::jsonb,
  'sistema',
  'migration'
)
ON CONFLICT DO NOTHING;

-- Regra 2: Mentorado entra em concepcao → criar task de primeiro dossiê
INSERT INTO task_trigger_rules (nome, descricao, when_aggregate_type, when_event_type, when_payload_filter, then_template, origem, criado_por)
VALUES (
  'Concepção: iniciar dossiê estratégico',
  'Quando mentorado completa kickoff e entra em concepcao, criar task de iniciar o primeiro dossiê',
  'Mentorado',
  'MentoradoKickoff_done',
  '{"to": "concepcao"}'::jsonb,
  '{
    "titulo": "Iniciar dossiê estratégico do mentorado",
    "descricao": "Mentorado completou onboarding. Iniciar a produção do dossiê de oferta.\n\n- Revisar briefing e calls de diagnóstico\n- Criar produção no pipeline\n- Definir escopo (Scale ou Clinic)",
    "responsavel": "queila",
    "prioridade": "alta",
    "especie": "one_time",
    "prazo_dias": 5
  }'::jsonb,
  'sistema',
  'migration'
)
ON CONFLICT DO NOTHING;

-- Regra 3: Mentorado entra em validacao → criar task de acompanhamento
INSERT INTO task_trigger_rules (nome, descricao, when_aggregate_type, when_event_type, when_payload_filter, then_template, origem, criado_por)
VALUES (
  'Validação: acompanhar hipóteses',
  'Quando mentorado entra em validacao, criar task de acompanhamento de testes de hipótese',
  'Mentorado',
  'MentoradoStrategy_validated',
  '{"to": "validacao"}'::jsonb,
  '{
    "titulo": "Acompanhar validação de hipóteses do mentorado",
    "descricao": "Mentorado entrou em fase de validação. Acompanhar:\n\n- Resultados dos testes de oferta\n- Métricas de funil\n- Feedback do mercado",
    "responsavel": "kaique",
    "prioridade": "normal",
    "especie": "one_time",
    "prazo_dias": 14
  }'::jsonb,
  'sistema',
  'migration'
)
ON CONFLICT DO NOTHING;

-- Regra 4: Mentorado entra em escala → criar task de dossiê de escala
INSERT INTO task_trigger_rules (nome, descricao, when_aggregate_type, when_event_type, when_payload_filter, then_template, origem, criado_por)
VALUES (
  'Escala: dossiê de escalada',
  'Quando mentorado está pronto pra escalar, criar task de dossiê atualizado',
  'Mentorado',
  'MentoradoReady_to_scale',
  '{"to": "escala"}'::jsonb,
  '{
    "titulo": "Atualizar dossiês para fase de escala",
    "descricao": "Mentorado pronto pra escalar. Atualizar dossiês:\n\n- Revisar oferta (ajustar preço/posicionamento pra escala)\n- Atualizar funil (novos canais, automações)\n- Documentar aprendizados da validação",
    "responsavel": "queila",
    "prioridade": "alta",
    "especie": "one_time",
    "prazo_dias": 7
  }'::jsonb,
  'sistema',
  'migration'
)
ON CONFLICT DO NOTHING;

-- Regra 5: Mentorado concluído → criar task de encerramento
INSERT INTO task_trigger_rules (nome, descricao, when_aggregate_type, when_event_type, when_payload_filter, then_template, origem, criado_por)
VALUES (
  'Conclusão: encerramento formal',
  'Quando ciclo do mentorado conclui, criar task de encerramento',
  'Mentorado',
  'MentoradoCycle_complete',
  '{"to": "concluido"}'::jsonb,
  '{
    "titulo": "Encerramento formal do ciclo de mentoria",
    "descricao": "Ciclo completo. Executar checklist de encerramento:\n\n- Dossiê final consolidado\n- NPS/feedback do mentorado\n- Proposta de renovação (se aplicável)\n- Arquivar documentos",
    "responsavel": "mariza",
    "prioridade": "normal",
    "especie": "one_time",
    "prazo_dias": 5
  }'::jsonb,
  'sistema',
  'migration'
)
ON CONFLICT DO NOTHING;

-- Regra 6: Mentorado cancelado → criar task de churn analysis
INSERT INTO task_trigger_rules (nome, descricao, when_aggregate_type, when_event_type, when_payload_filter, then_template, origem, criado_por)
VALUES (
  'Cancelamento: análise de churn',
  'Quando mentorado cancela em qualquer fase, criar task de análise',
  'Mentorado',
  'MentoradoCancel',
  '{"to": "encerrado"}'::jsonb,
  '{
    "titulo": "Análise de churn — mentorado cancelou",
    "descricao": "Mentorado cancelou. Analisar:\n\n- Motivo do cancelamento\n- Fase em que cancelou\n- Ações que poderiam ter evitado\n- Atualizar FAQ de objeções se necessário",
    "responsavel": "kaique",
    "prioridade": "alta",
    "especie": "one_time",
    "prazo_dias": 3
  }'::jsonb,
  'sistema',
  'migration'
)
ON CONFLICT DO NOTHING;

-- Regra 7: Dossiê produção aprovado → criar task de entrega
INSERT INTO task_trigger_rules (nome, descricao, when_aggregate_type, when_event_type, when_payload_filter, then_template, origem, criado_por)
VALUES (
  'Dossiê aprovado: agendar entrega',
  'Quando produção de dossiê é aprovada, criar task de agendar call de entrega',
  'DossieProducao',
  'DossieProducaoApprove',
  '{"to": "aprovado"}'::jsonb,
  '{
    "titulo": "Agendar call de entrega do dossiê",
    "descricao": "Dossiê aprovado. Agendar call de apresentação:\n\n- Confirmar data com mentorado\n- Preparar apresentação\n- Garantir que .docx está formatado\n- Enviar material 24h antes",
    "responsavel": "mariza",
    "prioridade": "alta",
    "especie": "one_time",
    "prazo_dias": 3
  }'::jsonb,
  'sistema',
  'migration'
)
ON CONFLICT DO NOTHING;
