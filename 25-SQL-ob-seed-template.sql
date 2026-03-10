-- ================================================================
-- Onboarding CS — Seed Template (Playbook)
-- 6 etapas, ~36 tarefas
-- ================================================================

-- ===== ETAPA A: Registro e Estrutura (D0) =====
INSERT INTO ob_template_etapas (id, nome, tipo, ordem, cor, icone) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'A: Registro e Estrutura', 'sequencial', 1, '#6366f1', '🏗️');

INSERT INTO ob_template_tarefas (etapa_id, descricao, responsavel_padrao, prazo_dias, ordem) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'Adicionar contato na aba Resumo Acompanhamento', 'CS', 0, 1),
  ('a0000000-0000-0000-0000-000000000001', 'Criar aba modelo do mentorado (dados base)', 'CS', 0, 2),
  ('a0000000-0000-0000-0000-000000000001', 'Criar grupo de WhatsApp do mentorado (Queila e Heitor como adm)', 'CS', 0, 3),
  ('a0000000-0000-0000-0000-000000000001', 'Criar pasta no Drive do mentorado e compartilhar com acesso de edição', 'CS', 0, 4),
  ('a0000000-0000-0000-0000-000000000001', 'Criar aba do mentorado na planilha de controle', 'CS', 0, 5),
  ('a0000000-0000-0000-0000-000000000001', 'Enviar acesso à plataforma de conteúdo com vídeo explicativo', 'CS', 0, 6),
  ('a0000000-0000-0000-0000-000000000001', 'Enviar mensagem para baixar o aplicativo', 'CS', 0, 7),
  ('a0000000-0000-0000-0000-000000000001', 'Criar acesso na plataforma (seguir vídeo de orientação)', 'CS', 0, 8),
  ('a0000000-0000-0000-0000-000000000001', 'Enviar acesso à plataforma do Hub de agentes', 'CS', 0, 9),
  ('a0000000-0000-0000-0000-000000000001', 'Criar/organizar acessos (Notion/Drive/Zoom/Área de membros)', 'CS', 0, 10),
  ('a0000000-0000-0000-0000-000000000001', 'Pegar endereço no privado (envio das flores)', 'CS', 0, 11),
  ('a0000000-0000-0000-0000-000000000001', 'Verificar se reunião de onboarding foi agendada', 'CS', 0, 12),
  ('a0000000-0000-0000-0000-000000000001', 'Enviar mensagem de apresentação e boas-vindas no grupo (Heitor)', 'Heitor', 0, 13),
  ('a0000000-0000-0000-0000-000000000001', 'Chamar no privado para dados financeiros/contrato (Heitor)', 'Heitor', 0, 14);

-- ===== ETAPA B: Agendamento e Preparação (D0-D2) =====
INSERT INTO ob_template_etapas (id, nome, tipo, ordem, cor, icone) VALUES
  ('b0000000-0000-0000-0000-000000000002', 'B: Agendamento e Preparação', 'sequencial', 2, '#0ea5e9', '📅');

INSERT INTO ob_template_tarefas (etapa_id, descricao, responsavel_padrao, prazo_dias, ordem) VALUES
  ('b0000000-0000-0000-0000-000000000002', 'Agendar reunião de onboarding com Heitor (Zoom + convite)', 'CS', 0, 1),
  ('b0000000-0000-0000-0000-000000000002', 'Garantir que mentorado entendeu objetivo do call (enviar msg 24h antes)', 'CS', 1, 2),
  ('b0000000-0000-0000-0000-000000000002', 'Conferir agenda da Queila para agendar call de estratégia', 'CS', 1, 3),
  ('b0000000-0000-0000-0000-000000000002', 'Enviar convite para reunião de estratégia com Queila', 'CS', 2, 4);

-- ===== ETAPA C: Execução do Call de Onboarding (D1-D5) =====
INSERT INTO ob_template_etapas (id, nome, tipo, ordem, cor, icone) VALUES
  ('c0000000-0000-0000-0000-000000000003', 'C: Execução do Call', 'sequencial', 3, '#f97316', '📞');

INSERT INTO ob_template_tarefas (etapa_id, descricao, responsavel_padrao, prazo_dias, ordem) VALUES
  ('c0000000-0000-0000-0000-000000000003', 'Conduzir reunião de onboarding (roteiro padrão)', 'Heitor', 2, 1),
  ('c0000000-0000-0000-0000-000000000003', 'Definir próximos passos imediatos (tarefas e prazos)', 'Heitor', 2, 2),
  ('c0000000-0000-0000-0000-000000000003', 'Sair do call com contrato assinado (se possível)', 'Heitor', 2, 3);

-- ===== ETAPA D: Pós-Onboarding (D2-D7) =====
INSERT INTO ob_template_etapas (id, nome, tipo, ordem, cor, icone) VALUES
  ('d0000000-0000-0000-0000-000000000004', 'D: Pós-Onboarding', 'sequencial', 4, '#10b981', '✅');

INSERT INTO ob_template_tarefas (etapa_id, descricao, responsavel_padrao, prazo_dias, ordem) VALUES
  ('d0000000-0000-0000-0000-000000000004', 'Enviar resumo da reunião no grupo de onboarding (doc + áudio)', 'Heitor', 2, 1),
  ('d0000000-0000-0000-0000-000000000004', 'Atualizar planilha do mentorado com status "onboarding concluído"', 'CS', 3, 2),
  ('d0000000-0000-0000-0000-000000000004', 'Confirmar agenda do call com Queila e enviar convite final', 'CS', 3, 3),
  ('d0000000-0000-0000-0000-000000000004', 'Atualizar link com gravação e documentos (transcrição, YouTube)', 'CS', 4, 4),
  ('d0000000-0000-0000-0000-000000000004', 'Validar se mentorado enviou lista de concorrentes', 'CS', 5, 5),
  ('d0000000-0000-0000-0000-000000000004', 'Enviar resumo + percepções no grupo de onboarding', 'Heitor', 5, 6),
  ('d0000000-0000-0000-0000-000000000004', 'Conferir se há pendências de contrato/financeiro antes de avançar', 'Heitor', 7, 7);

-- ===== CHECKLIST FINANCEIRO (paralelo) =====
INSERT INTO ob_template_etapas (id, nome, tipo, ordem, cor, icone) VALUES
  ('e0000000-0000-0000-0000-000000000005', 'Checklist Financeiro', 'paralelo', 5, '#f59e0b', '💰');

INSERT INTO ob_template_tarefas (etapa_id, descricao, responsavel_padrao, prazo_dias, ordem) VALUES
  ('e0000000-0000-0000-0000-000000000005', 'Pegar valor/condição/datas e enviar msg no grupo Financeiro', 'Heitor', 0, 1),
  ('e0000000-0000-0000-0000-000000000005', 'Atualizar aba de acompanhamento de pagamentos', 'Heitor', 1, 2),
  ('e0000000-0000-0000-0000-000000000005', 'Adicionar cobranças futuras na agenda (All In)', 'Heitor', 1, 3);

-- ===== CHECKLIST CONTRATO (paralelo) =====
INSERT INTO ob_template_etapas (id, nome, tipo, ordem, cor, icone) VALUES
  ('f0000000-0000-0000-0000-000000000006', 'Checklist Contrato', 'paralelo', 6, '#8b5cf6', '📝');

INSERT INTO ob_template_tarefas (etapa_id, descricao, responsavel_padrao, prazo_dias, ordem) VALUES
  ('f0000000-0000-0000-0000-000000000006', 'Solicitar dados do representante legal no privado', 'Heitor', 0, 1),
  ('f0000000-0000-0000-0000-000000000006', 'Enviar contrato pela ferramenta D4Sign', 'Heitor', 1, 2),
  ('f0000000-0000-0000-0000-000000000006', 'Fazer follow-up da assinatura', 'Heitor', 3, 3),
  ('f0000000-0000-0000-0000-000000000006', 'Confirmar assinatura do contrato', 'Heitor', 5, 4),
  ('f0000000-0000-0000-0000-000000000006', 'Arquivar contrato assinado na pasta Drive do mentorado', 'CS', 5, 5);
