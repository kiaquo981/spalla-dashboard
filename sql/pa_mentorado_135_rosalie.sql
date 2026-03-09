-- ===== MENTORADO: ROSALIE MATUK (id=135) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (135, 'PLANO DE AÇÃO v2 | ROSALIE MATUK', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- ==========================================================
  -- FASE 1: Revisão do Dossiê Estratégico
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 1, 'Ler a seção de Contexto Analisado e validar dados da expert (Rosalie, cirurgiã plástica, Vitória/ES)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 2, 'Revisar o Storytelling completo: 9 marcos desde a faculdade até a mentoria, validar tom e autenticidade', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Revisar seção de Público-Alvo: cirurgiões plásticos com clínica ativa faturando R$70k–R$150k/mês', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Revisar Tese do Produto e Oferta: Mentoria de Gestão Comercial de Ponta a Ponta, 3 pilares, ticket R$15k', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Revisar Conteúdo Programático e Arquitetura de Produto: 3 pilares + 4 bônus + jornada de 6 meses', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 6, 'Revisar Concorrentes, Lacunas de Mercado e Posicionamento estratégico da Rosalie frente aos grupos de WhatsApp', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ==========================================================
  -- FASE 2: Definição e Validação do Posicionamento
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Definição e Validação do Posicionamento', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Definir o nome oficial da mentoria (atualmente sem nome — "NOME A DEFINIR" no dossiê)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Listar 5 opções de nome que comuniquem processo comercial para médico', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Validar opções com equipe CASE e escolher nome definitivo', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Registrar nome escolhido em todos os materiais de vendas', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 2, 'Confirmar posicionamento: "Gestão Comercial de Ponta a Ponta para médicos com clínica ativa" — NÃO "gestão genérica"', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Confirmar com Rosalie disponibilidade semanal para dedicação à mentoria (item pendente no dossiê)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Levantar dados pendentes do dossiê: faturamento mensal, número de procedimentos/mês, ticket médio e taxa de conversão da clínica', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Confirmar quantidade de unidades da Mad Consulta (3 ou 4 shoppings — divergência no dossiê) para uso correto no storytelling', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ==========================================================
  -- FASE 3: Construção do Storytelling e Comunicação de Autoridade
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Construção do Storytelling e Comunicação de Autoridade', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Gravar vídeo de apresentação do storytelling base (9 marcos) para uso em página de vendas e Instagram', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Preparar roteiro com os 9 marcos do dossiê (faculdade → tombo R$400k → clínica própria → IA)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Gravar versão curta (90s) para Reels/Instagram e versão longa (5-7min) para página de vendas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Revisar com equipe CASE e ajustar tom — médica falando para médico, não coach', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 2, 'Criar post/conteúdo sobre o marco do tombo de R$400.000 na Mad Consulta: "cada erro virou um checklist"', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Criar conteúdo sobre o marco da validação do contador: "nenhum médico mandava documentos organizados como você"', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Criar conteúdo sobre o marco do Leonardo e o fechamento na consulta: "brinco que meu marido é meu primeiro cliente a quebrar objeções"', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Mapear as 11 crenças-mãe do dossiê e criar calendário de conteúdo baseado nelas (1 crença por semana de conteúdo)', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 6, 'Atualizar bio do Instagram (@dra.rosalietorrelio) para comunicar mentoria — reposicionamento gradual conforme dossiê', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ==========================================================
  -- FASE 4: Estratégia de Aquisição e Funil de Validação Offline
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Estratégia de Aquisição e Funil de Validação Offline', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Mapear os grupos de WhatsApp de cirurgiões plásticos (Marcelo Ono, Daniel Botelho, Heloisa Manfrim, Cintia Rios, Argoplasma) e listar os 1.000+ contatos disponíveis', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Listar todos os grupos ativos com número de membros e nível de engajamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Identificar os 30-50 contatos mais estratégicos para abordagem direta de pré-venda', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Estruturar funil de Aula Zoom para validação offline — benchmark: 18 participantes, 8 compradores (44% conversão) no caso de referência do dossiê', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Criar convite para aula Zoom de 60-90min sobre gestão comercial para médicos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Definir tema da aula que valide a dor central: "Por que sua clínica perde pacientes da porta para dentro"', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Disparar convite nos grupos de WhatsApp e para os contatos diretos', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 4, 'Realizar aula Zoom e fazer transição para oferta da mentoria', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Ativar contador como canal de indicação — empacotar proposta de playbook de POPs para apresentar aos clientes médicos do contador', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Mapear convites para aulas sobre feridas complexas e queimaduras como oportunidade de apresentar mentoria ao final', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Construir lista de interessados qualificada com no mínimo 50 contatos antes do lançamento oficial', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ==========================================================
  -- FASE 5: Produção dos Materiais de Vendas
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Produção dos Materiais de Vendas', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Criar página de vendas da mentoria com o copy da jornada longa aprovado no dossiê', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Adaptar o copy da jornada do dossiê para formato de página de vendas (seções: para quem é, 3 pilares, bônus, investimento)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Incluir âncora de preço: R$16.000 (soma dos módulos separados) vs. R$15.000 (mentoria completa)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Revisar com Rosalie e aprovar antes de publicar', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Produzir formulário de diagnóstico individual para pré-onboarding dos mentorados', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Listar os 6 pontos do diagnóstico do dossiê (canais de leads, qualificação, consulta, follow-up, pós-operatório, equipe)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar formulário no Google Forms ou equivalente e testar fluxo de preenchimento', 'pendente', 'equipe_spalla', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Criar apresentação de vendas (deck) para a aula Zoom de validação — estrutura: dor → autoridade → método → oferta', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Criar documento de ancoragem de preço com comparativo (consultoria comercial + treinamento de equipe + consultoria de experiência = R$16k separados)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Definir e criar proposta de turma fundadora: preço de fundador R$12.000 à vista / R$15.000 parcelado, turma de 5-8 médicos', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ==========================================================
  -- FASE 6: Estruturação do Conteúdo Programático — Pilar 1 (Funil e Visão Estratégica)
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Estruturação do Conteúdo — Pilar 1: Funil e Visão Estratégica', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Produzir aula sobre os 3 funis essenciais da clínica médica: entrada, fechamento pós-consulta e reativação de base', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Roteirizar aula com exemplos reais da clínica da Rosalie (3.000 leads na etapa perdida, CRM Ramper)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar template de Mapa de Funil Comercial para Clínica Médica (entregável do Pilar 1)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Criar Dashboard de Métricas Essenciais em planilha (taxa de agendamento, conversão, no-show, fechamento)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 2, 'Produzir aula sobre implementação do CRM Ramper: configuração de funis, etapas e rotina de atualização diária', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Criar guia de benchmarks de conversão por etapa para clínicas médicas (baseado nos dados reais da clínica da Rosalie)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Criar modelo de funis pré-configurados para CRM da clínica médica (entregável para o mentorado implementar)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Fechar parceria com empresa de CRM para onboarding e suporte dedicado aos mentorados', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ==========================================================
  -- FASE 7: Estruturação do Conteúdo Programático — Pilar 2 (Estrutura e Equipe Comercial)
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Estruturação do Conteúdo — Pilar 2: Estrutura e Equipe Comercial', 'passo_executivo', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Produzir aula sobre perfil de contratação do Comercial 1 (SDR): o que buscar, o que evitar, como avaliar na entrevista', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Criar Job Description do Comercial 1 (modelo pronto para adaptar — entregável do Pilar 2)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar checklist de onboarding documentado (o que o novo membro precisa saber no dia 1, 7 e 30)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Produzir scripts completos para todas as etapas do funil: primeiro contato, qualificação, agendamento, objeções e follow-up', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Script de triagem e pré-atendimento (WhatsApp e ligação) — por etapa do funil', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Script de qualificação (identificar se o lead tem fit para consulta paga antecipadamente)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Scripts de agendamento com confirmação e redução de no-show', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Produzir e documentar o Programa de Premiação Jurídico para time comercial (Bônus 3) — adaptar documento feito com advogado', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Criar modelo de rotina de acompanhamento semanal do time comercial (checklist de gestão sem microgerenciar)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Criar modelo de metas de conversão por etapa do funil com critérios objetivos de elegibilidade ao programa de premiação', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ==========================================================
  -- FASE 8: Estruturação do Conteúdo Programático — Pilar 3 (Consulta que Converte + Fechamento)
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Estruturação do Conteúdo — Pilar 3: Consulta que Converte e Fechamento', 'passo_executivo', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Produzir aula sobre o roteiro completo de consulta: conexão → queixa → diagnóstico → plano de tratamento → apresentação do valor → negociação', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Criar template de roteiro de consulta em etapas (adaptável por tipo de procedimento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar script de apresentação de preço e negociação pelo médico na consulta', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Criar modelo de plano de tratamento físico que ancora valor e profissionalismo (documento físico entregue na consulta)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 4, 'Criar modelo de handoff médico → Comercial 2 para fechamento burocrático (contrato, entrada, pagamento)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Produzir aula sobre a cadência de 5 follows pós-consulta: depoimento, foto, áudio, conversa, escassez', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Criar cadência de follow-up (5 passos) com scripts, timing e canal definido para cada mensagem', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar scripts das 10 objeções mais comuns: tempo, dinheiro, "não estou pronta", "vou pensar", medo do procedimento, entre outras', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Configurar 2 follows automatizados no CRM + templates para os 5 follows humanizados', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Criar régua de resgate de leads antigos para ativar os 3.000 leads na etapa "perdida" do CRM Ramper', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Criar modelo de contrato de entrada e processo de recebimento de sinal para padronizar fechamentos', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ==========================================================
  -- FASE 9: Produção dos Bônus — Experiência Premium e Blindagem da Entrega
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Produção dos Bônus: Experiência Premium e Blindagem da Entrega', 'passo_executivo', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Produzir Bônus 1 — Experiência Premium: roteiro de acompanhamento pré-consulta e checklist de percepção de experiência', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Criar roteiro de acompanhamento pré-consulta (dia do agendamento → 48h antes → dia anterior → dia da consulta)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar scripts de confirmação e redução de no-show por canal (WhatsApp, ligação)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Criar checklist de percepção de experiência: espaço físico, imagem pessoal do médico, atendimento da recepção', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Produzir Bônus 2 — Blindagem da Entrega: protocolo de pós-operatório semana a semana do dia da alta aos 90 dias', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Documentar protocolo completo de pós-operatório da clínica (hiperbárica, suplementação, laser, placa, e-book de 10 páginas, vídeos, música personalizada)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar sequência de contato com o paciente no primeiro mês pós-cirurgia com scripts por canal', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Criar checklist de segurança clínica e jurídica para proteção do médico (documentação, consentimentos, orientações escritas)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 4, 'Criar processo de indicação orgânica ativa — quando e como acionar o paciente para pedir indicação', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Produzir Bônus 4 — Sessão de Diagnóstico Individual 1:1: criar estrutura de análise de 60 minutos com Rosalie para cada mentorado', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Criar e-book de orientações pós-operatórias (base para os mentorados adaptarem ao próprio procedimento)', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ==========================================================
  -- FASE 10: Reposicionamento do Instagram e Presença Digital
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Reposicionamento do Instagram e Presença Digital', 'fase', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Definir estratégia de reposicionamento gradual do Instagram @dra.rosalietorrelio para comunicar mentoria (sem abandonar identidade de cirurgiã)', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Atualizar bio para incluir posição de mentora de gestão comercial para médicos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar destaque no Instagram dedicado à mentoria e ao método', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Planejar mix de conteúdo: 60% clínica/cirurgia + 40% gestão e mentalidade médica', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 2, 'Criar calendário de conteúdo semanal baseado nas 11 crenças-mãe do dossiê (1 crença por semana)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Produzir Reel sobre a frase "Você pensa que precisa de mais marketing. O problema está na porta para dentro" — conteúdo de maior impacto do dossiê', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Produzir Reel sobre o marco do Leonardo: "Brinco que meu marido é meu primeiro cliente a quebrar objeções" — prova de autoridade + storytelling', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Definir estratégia de collabs com blogueiras e influenciadoras do ES para ampliar alcance — já usado na clínica', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 6, 'Planejar retomada gradual de tráfego pago (superar trauma relatado no dossiê): começar com boost de melhores orgânicos, não com campanhas frias', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  -- ==========================================================
  -- FASE 11: Pesquisa e Análise de Concorrentes
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Pesquisa e Análise de Concorrentes', 'fase', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Realizar pesquisa real dos 5 concorrentes mapeados no dossiê (todos atualmente com dados inferidos — urgente preencher)', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Pesquisar Marcelo Ono (@marcelo_ono, 176k seguidores): verificar se tem curso, mentoria ou apenas grupo de WhatsApp', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Pesquisar Daniel Botelho (@danielbotelhoplastica, 321k seguidores): mapear esteira completa além do grupo de WhatsApp', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Pesquisar Cintia Rios (@dracintiarios, 153k seguidores): verificar profundidade do curso e se tem acompanhamento individualizado', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 4, 'Pesquisar Heloisa Manfrim (@plasticaetal, 215k seguidores): verificar se tem produto estruturado além do grupo', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 5, 'Pesquisar Marcia, Barbara e Marcio (Diretores de Negócios): mapear ticket, funil e diferencial da imersão presencial', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 2, 'Solicitar a Rosalie que envie perfis/links dos concorrentes para pesquisa real (item urgente apontado no dossiê)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Atualizar seção de concorrentes do dossiê com dados reais (substituir os dados inferidos/lacunados)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Documentar lacunas de mercado confirmadas após pesquisa real para reforçar o diferencial da Rosalie no posicionamento', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  -- ==========================================================
  -- FASE 12: Estrutura Operacional da Mentoria
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Estrutura Operacional da Mentoria', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Definir calendário completo dos 12 encontros quinzenais de 90 minutos para a primeira turma de 6 meses', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Bloquear datas na agenda da Rosalie para os 12 encontros e aulas ao vivo (turma fundadora)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Definir dia e horário fixo quinzenal (considerar agenda médica e disponibilidade dos mentorados)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Criar cronograma das 3 etapas: Fundação (Pilares 1-2) → Consulta e Fechamento (Pilar 3) → Consolidação (Bônus 2)', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Criar contrato de mentoria para assinatura dos mentorados na entrada', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Rascunhar cláusulas principais: prazo 6 meses, valor, condições de pagamento, entregáveis e responsabilidades', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Revisar contrato com advogado e aprovar versão final', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Configurar grupo exclusivo no WhatsApp para suporte entre encontros — criar regras de uso e boas-vindas', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Criar biblioteca de templates e materiais (scripts, roteiros, checklists do dossiê) e organizar no repositório compartilhado', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Definir plataforma de entrega das aulas gravadas para turmas futuras (a partir da turma 2)', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ==========================================================
  -- FASE 13: Integração com IA — Diferencial Tecnológico da Mentoria
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Integração com IA — Diferencial Tecnológico da Mentoria', 'passo_executivo', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Concluir a integração do agente de IA com o Feegow (em desenvolvimento — desafios técnicos ativos apontados no dossiê)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Mapear os pontos de travamento técnico da integração Feegow e priorizar resolução', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Definir data-alvo para conclusão da integração (NÃO prometer como feature entregue até estar funcionando — alerta do dossiê)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Documentar o agente de IA para SDR como case real para usar na mentoria (diferencial que nenhum concorrente tem)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Usar o agente de IA da clínica da Rosalie como case demonstrativo nas aulas do Pilar 1 (CRM + IA para SDR e agendamento)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Gravar demonstração do agente de IA em funcionamento na clínica (SDR, qualificação, agendamento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar módulo opcional de IA para mentorados avançados (implementação após CRM funcionando)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Estruturar script de IA para resgatar os 3.000 leads na etapa "perdida" do CRM Ramper como case de resultado para usar em vendas', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Definir o que ensinar sobre IA na mentoria: princípio "IA num processo vira escala, IA num caos vira mais caos" — crença 7 do dossiê', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ==========================================================
  -- FASE 14: Lançamento da Primeira Turma
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Lançamento da Primeira Turma', 'passo_executivo', 14, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Executar pré-venda offline via grupos de WhatsApp de cirurgiões plásticos — validar oferta antes de qualquer tráfego', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Criar mensagem de pré-venda para os grupos de WhatsApp: convite pessoal, sem escala, sem tráfego pago', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Realizar aula Zoom de validação (meta: 15-20 participantes, referência: 18 no caso do dossiê)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Fazer transição da aula para oferta da primeira turma com preço de fundador (R$12k à vista / R$15k parcelado)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 4, 'Fechar primeira turma com 5-8 mentorados qualificados', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Fazer onboarding completo da primeira turma: contrato, diagnóstico individual, plano de ação personalizado e acesso aos materiais', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Enviar contrato para cada mentorado e confirmar assinatura', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Enviar formulário de diagnóstico e analisar individualmente cada caso', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Realizar call individual de 60 minutos (Bônus 4) com cada mentorado e entregar plano de ação personalizado', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Coletar depoimentos e resultados da primeira turma ao longo dos 6 meses para usar em escala na turma 2', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Planejar lançamento da turma 2 após validação do método com a primeira turma — incluir funil de autoridade via Instagram e tráfego', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

END $$;
