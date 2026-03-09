-- ===== MENTORADO: THIAGO KAILER (id=148) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (148, 'PLANO DE AÇÃO v2 | THIAGO KAILER', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- ========================================
  -- FASE 1: Revisão do Dossiê Estratégico
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 1, 'Reler o contexto analisado e validar as 3 frentes estratégicas (Fase 1: Ígnea Agro, Fase 2: marca pessoal, Fase 3: Axioma)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 2, 'Revisar e internalizar os 6 marcos de autoridade na sequência narrativa definida no dossiê', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 3, 'Revisar análise de concorrentes (Rogério Augusto, Produtor Sem Dívida, Deyse Amaral, João Domingos, Sérgio Henrique Agro, Douglas Duek) e mapear lacunas de mercado', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Revisar os storytellings de Produtor Rural e Mercado Geral e identificar qual tom usar em cada canal', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 5, 'Revisar os públicos-alvo mapeados (Produtor Rural, Mercado Geral, Profissional) e confirmar prioridade da Fase 1', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 6, 'Revisar a tese, a oferta e o pitch de vendas da Ígnea Agro e validar com mentor', 'pendente', 'mentorado', 6, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 7, 'Revisar o conteúdo programático dos 4 movimentos e o processo operacional completo', 'pendente', 'mentorado', 7, 'dossie_auto');

  -- ========================================
  -- FASE 2: Empacotamento da Consultoria Ígnea Agro
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Empacotamento da Consultoria Ígnea Agro', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Definir nome oficial da consultoria (campo "[DEFINIR NOME]" ainda em aberto no dossiê)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Gerar lista de opções de nome para o produto de mapeamento estratégico', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Validar nome com mentor e alinhar com identidade da marca Ígnea Agro', 'pendente', 'mentor', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Registrar nome escolhido e atualizar todos os materiais do dossiê', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Finalizar e documentar a proposta comercial com faixas de investimento por tamanho de dívida (R$30K / R$50K / R$90K)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar tabela de preços formalizada com as 3 faixas de dívida (R$3M-R$10M, R$10M-R$20M, acima de R$20M)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Documentar mecanismo de abate: consultoria abatida dos honorários advocatícios ao contratar TK Advogados', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Criar script de qualificação para filtrar leads por tamanho de dívida e perfil de produtor', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 3, 'Criar e formatar os 3 bônus da consultoria (Guia do Banco, Glossário de Dívidas Agro, Checklist do Advogado)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Redigir e formatar Bônus 1 — Guia: Como Ler o que o Banco Pensa do Seu Caso (valor percebido R$5.000)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Redigir e formatar Bônus 2 — Glossário do Mercado de Dívidas Agro (valor percebido R$3.000)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Redigir e formatar Bônus 3 — Checklist: O que Avaliar Antes de Assinar com Advogado (valor percebido R$2.000)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 4, 'Criar templates operacionais: Formulário de Diagnóstico, Mapa Estratégico, Matriz de Riscos e Estratégia Recomendada', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar Formulário de Diagnóstico estruturado (contratos, volumes, credores, processos em andamento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Criar template base do Mapa Estratégico de Endividamento (PDF personalizado por caso)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Criar template da Matriz de Riscos por Cenário (planilha + PDF com melhor/pior caso)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 4, 'Criar template da Estratégia Recomendada Documentada (plano de ação com timing e prioridades)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 5, 'Redigir e assinar contrato de consultoria padrão para a Ígnea Agro (digital ou presencial)', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 6, 'Definir fluxo interno de análise com o time do escritório para o Movimento 2 (quem faz o quê nos bastidores)', 'pendente', 'mentorado', 6, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 7, 'Definir calendário de disponibilidade com slots para os encontros das consultorias', 'pendente', 'mentorado', 7, 'dossie_auto');

  -- ========================================
  -- FASE 3: Infraestrutura Digital e Canais de Captação
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Infraestrutura Digital e Canais de Captação', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Configurar canal de WhatsApp da Ígnea Agro com mensagem de boas-vindas padrão e script de primeiro contato', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar mensagem de boas-vindas automática para leads que chegam pelo WhatsApp da Ígnea Agro', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Escrever script de qualificação (nome, volume aproximado da dívida, com quem está endividado)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Definir fluxo: lead qualificado → proposta comercial → contrato → pagamento → formulário', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Criar link de pagamento e processo de onboarding do produtor após confirmação de pagamento', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Configurar ferramenta de pagamento digital (Hotmart, Stripe, PagSeguro ou similar)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Automatizar envio do formulário de diagnóstico + Bônus 2 (Glossário) após confirmação do pagamento', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Criar registro interno por caso (planilha com: volume da dívida, credores, estratégia, status de conversão para TK Advogados)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 3, 'Criar página de vendas da Ígnea Agro baseada no pitch de vendas do dossiê (estrutura em 7 blocos: abertura, ponto A, inimigo, autoridade, oferta, investimento, CTA)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Verificar e atualizar bio do Instagram @ignea.agro para comunicar claramente a oferta de consultoria estratégica', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 5, 'Criar e organizar destaques do Instagram @ignea.agro (quem somos, como funciona, resultado, contato)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ========================================
  -- FASE 4: Posicionamento da Marca Pessoal @thiago_kailer
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Posicionamento da Marca Pessoal @thiago_kailer', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Reformular bio e apresentação do perfil @thiago_kailer para comunicar o posicionamento de "estrategista neutro dos dois lados do mercado"', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Escrever nova bio do @thiago_kailer alinhada à narrativa central: "15 anos operando de dentro dos dois lados de um mercado opaco"', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Garantir separação clara de narrativas: @thiago_kailer (estrategista neutro), @ignea.agro (produtor), Axioma (investidor/fundo)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Criar foto de perfil e identidade visual que reforce posicionamento de consultor sênior e autoridade de mercado', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Produzir os primeiros conteúdos de feed/reels baseados nos 6 marcos de autoridade narrativa do dossiê', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Produzir conteúdo sobre Marco 1: Origem na advocacia bancária (HSBC, Banco do Brasil, Itaú/Unibanco)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Produzir conteúdo sobre Marco 3: BTG compra carteira Bamerindus (2016-2017) — "eu estava lá quando esse mercado nasceu"', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Produzir conteúdo sobre Marco 5: A mudança de lado — núcleo da narrativa emocional', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 4, 'Produzir conteúdo sobre Marco 6: Fundação da Ígnea Agro — "a mudança de lado virou empresa e estrutura"', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 5, 'Produzir conteúdo sobre Marco 7: Negociação de exclusividade com BTG/Enforce via Axioma', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 3, 'Criar calendário de conteúdo mensal para @thiago_kailer usando o banco de frases do dossiê (tom analítico, insider, neutro)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Definir frequência e tipos de conteúdo: análises do mercado de distressed, bastidores do mercado de dívida agro, leitura bilateral', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Adaptar banco de frases do dossiê em pautas de conteúdo para feed, reels e stories', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Definir regras do que NÃO postar no @thiago_kailer (não direcionar só para produtor, não direcionar só para investidor)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 4, 'Trabalhar com produtor de conteúdo ou editor para superar a limitação de criatividade reconhecida por Thiago ("tenho falta de habilidades de ser criativo")', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 5, 'Estudar e mapear estratégias de comunicação dos perfis de referência do dossiê (Guilber Hidaka, Rony Meisler, Renato Opice Blum)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ========================================
  -- FASE 5: Ativação da Rede de Originadores
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Ativação da Rede de Originadores e Captação Offline', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Mapear e listar os originadores ativos nos estados prioritários (MT, RS, PR, TO, PI) e estruturar modelo de parceria/comissão', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Listar todos os originadores ativos por estado com nome, contato e volume de oportunidades', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Definir percentual de comissão e modelo de repasse para originadores que tragam casos qualificados', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Criar material de apresentação da consultoria para enviar aos originadores (versão condensada do pitch)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 4, 'Fazer contato ativo com os 10 principais originadores para apresentar o produto formalizado da Ígnea Agro', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Contatar advogados parceiros que já consultam Thiago informalmente e apresentar o produto formalizado', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Listar advogados de outros estados que já buscaram orientação estratégica informal de Thiago', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Enviar mensagem personalizada para cada advogado parceiro apresentando a consultoria da Ígnea Agro', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Criar estrutura de indicação para advogados parceiros (modelo de comissão ou parceria estratégica)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 3, 'Contatar ex-clientes e contatos da rede de 15 anos de atuação que possam trazer leads qualificados', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Criar roteiro de abordagem para eventos do setor agro — Thiago já está presente em eventos, sistematizar a captação nesses encontros', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ========================================
  -- FASE 6: Aquisição dos Primeiros Clientes da Consultoria
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Aquisição dos Primeiros Clientes da Consultoria Ígnea Agro', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Identificar e listar os produtores que já procuraram Thiago informalmente e que se encaixam no perfil ICP (dívida acima de R$3M)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Mapear casos de consultoria informal já realizados gratuitamente (estimado R$300K/ano não cobrado)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Qualificar cada caso: volume da dívida, urgência, perfil do produtor, credores envolvidos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Selecionar 3-5 casos prioritários para abordagem comercial com o produto formalizado', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Realizar abordagem comercial com os primeiros leads utilizando o pitch de vendas do dossiê', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Enviar proposta comercial para os leads selecionados com faixas de investimento baseadas no tamanho da dívida', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Conduzir conversa de qualificação e fechamento seguindo o roteiro do pitch (abertura, ponto A, diferencial, oferta, investimento)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Fechar e onboar o primeiro cliente pagante da consultoria Ígnea Agro', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 3, 'Executar o primeiro ciclo completo da consultoria (4 movimentos: diagnóstico, análise, mapa, acompanhamento) e documentar aprendizados', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Executar Movimento 1 — Diagnóstico: conduzir encontro de até 2h com o primeiro cliente', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Executar Movimento 2 — Análise: Thiago e time analisam contratos em 5-7 dias úteis com apoio da Axioma', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Executar Movimento 3 — Mapa: apresentar Mapa Estratégico completo + Matriz de Riscos + Estratégia Recomendada', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 4, 'Executar Movimento 4 — Acompanhamento: 3 calls mensais + WhatsApp + call emergencial', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 5, 'Coletar feedback do primeiro cliente e ajustar processos operacionais para os próximos casos', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ========================================
  -- FASE 7: Gestão do Conflito de Interesses e Separação de Marcas
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Gestão do Conflito de Interesses e Separação de Marcas', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Documentar e formalizar a separação operacional entre TK Advogados (credores) e Ígnea Agro (produtores)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar regra clara: TK Advogados não aparece em conteúdo da Ígnea Agro e vice-versa', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Validar com mentor a estrutura jurídica de separação das entidades para cumprimento do estatuto da OAB', 'pendente', 'mentor', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Revisar nota de enquadramento da oferta: "Thiago Kailer atua como Consultor Estratégico — não como advogado. A representação jurídica é feita separadamente pelo TK Advogados"', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 2, 'Definir narrativa de comunicação para cada canal: @thiago_kailer (neutro), @ignea.agro (produtor), Axioma (mercado profissional)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 3, 'Criar protocolo interno para casos onde o cliente da consultoria Ígnea Agro deseja contratar o TK Advogados — aplicar mecanismo de abate de honorários', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- ========================================
  -- FASE 8: Desenvolvimento do Storytelling em Conteúdo
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Desenvolvimento do Storytelling em Conteúdo Digital', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Adaptar os storytellings completos do dossiê (Produtor Rural e Mercado Geral) em formatos de conteúdo para Instagram', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar versão curta (reel 60-90s) do storytelling central: "Mudei de lado — agora uso o que aprendi contra o produtor para defender o produtor"', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Criar carrossel de feed com a sequência dos 6 marcos de autoridade narrativa', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Produzir conteúdo sobre as crenças-chave do dossiê: "Endividamento não é falha moral", "O produtor precisa de estratégia antes de advogado", "Fundo de investimento não é seu aliado — é um negócio"', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Usar as "Falas Reais do Thiago" do dossiê como base para conteúdos autênticos e de alta autoridade', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Produzir conteúdo baseado em: "Eu advogava para banco. Era eu que executava o produtor."', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Produzir conteúdo baseado em: "Para dever pouco, a vinte milhões" — contextualizando as faixas de endividamento', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Produzir conteúdo baseado em: "Eu comecei a ser consultado por próprios advogados" — autoridade reconhecida por pares', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 4, 'Produzir conteúdo baseado em: "No offline, eu sou muito forte em termos de rede de contato" — validação da presença no mercado', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 3, 'Criar série de conteúdos educativos sobre o mercado de distressed assets para construir autoridade no @thiago_kailer (mercado geral)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Produzir conteúdos sobre os erros mais comuns do produtor endividado usando as "Crenças Erradas do Público" do dossiê', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 5, 'Definir estratégia para lidar com restrições da OAB em captação — posicionar conteúdo como educacional, não como captação direta', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ========================================
  -- FASE 9: Escalabilidade Operacional e Gestão do Tempo
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Escalabilidade Operacional e Gestão do Tempo', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Definir capacidade máxima de atendimento simultâneo da consultoria (limitação de horas identificada: "minha escala é pequena porque tenho que atender um por um")', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Calcular horas disponíveis por mês para a consultoria considerando advocacia ativa no TK Advogados', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Definir número máximo de casos simultâneos viável sem comprometer qualidade da entrega', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Estruturar fluxo de delegação para o time do escritório absorver parte da análise contratual (Movimento 2)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Integrar a Axioma (IA para mineração de ativos estressados) no processo de análise contratual do Movimento 2', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Mapear quais partes da análise contratual podem ser automatizadas pela Axioma (leitura de CPR, hipotecas, cessões de crédito)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Criar protocolo de uso da Axioma dentro do fluxo da consultoria Ígnea Agro', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Testar a Axioma em um caso real e documentar ganho de velocidade versus análise manual', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 3, 'Trabalhar o problema de foco identificado: "Eu tenho questão de foco. Isso me trava" — criar ritual de revisão semanal de prioridades', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Criar sistema de CRM simplificado para gerenciar pipeline de leads, clientes ativos e histórico de casos', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ========================================
  -- FASE 10: Construção de Autoridade no Mercado de Distressed Assets
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Construção de Autoridade no Mercado de Distressed Assets', 'fase', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Criar conteúdo de posicionamento como "estrategista neutro" do mercado de distressed assets para o @thiago_kailer (Fase 2 do dossiê)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Publicar análises sobre o mercado de NPL (non-performing loans) no Brasil — usando a visão de insider de 15 anos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Publicar conteúdo sobre como fundos de distressed analisam carteiras (linguagem segura: análise de risco, viabilidade, timing)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Publicar sobre a estruturação do mercado de distressed rural no Brasil — posicionamento como testemunha histórica do mercado', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Participar e gerar conteúdo sobre eventos do setor agro e de distressed assets para ampliar presença digital com base na presença offline já ativa', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar conteúdo antes, durante e depois dos eventos (bastidores, análises, insights)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Registrar interações com fundos, bancos e cooperativas durante os eventos (sem revelar confidencialidade dos casos)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 3, 'Escrever e publicar artigo sobre o mercado de dívida rural no Brasil — credenciais acadêmicas (pós-graduação Insper 2015-2016) como plataforma de autoridade', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Identificar oportunidades de participação em podcasts e eventos como especialista em distressed rural — para construção de autoridade além do Instagram', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ========================================
  -- FASE 11: Desenvolvimento e Negociação da Axioma (Fase 3)
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Desenvolvimento e Negociação da Axioma (Fase 3 — Mercado Profissional)', 'fase', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Acompanhar e apoiar a negociação de exclusividade da Axioma com BTG/Enforce — maior player do mercado de distressed no Brasil', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Reunir com o sócio técnico/engenheiro da Axioma para alinhamento do status da negociação com BTG/Enforce', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Mapear os termos mínimos aceitáveis para o contrato de licenciamento com BTG/Enforce', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Definir prazo máximo para fechar a negociação antes de partir para alternativas de licenciamento com outros fundos', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Planejar oferta de produto da Axioma para fundos e investidores qualificados (Público A da Fase 3)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Definir precificação da análise da Axioma (~R$300 por análise automatizada mencionado na call)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Criar proposta comercial para gestores de FIDCs, family offices e fundos de crédito interessados na tecnologia', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Mapear lista de fundos potenciais além do BTG/Enforce para licenciamento da Axioma', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 3, 'Planejar programa de originadores para a Axioma (Público B da Fase 3) — modelo de comissão para quem traz deal flow de ativos estressados', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'ATENÇÃO: Não ativar ações de mercado da Axioma antes de consolidar Fases 1 e 2 — seguir orientação do dossiê', 'pendente', 'mentor', 4, 'dossie_auto');

  -- ========================================
  -- FASE 12: Mentalidade, Foco e Gestão de Paralisia
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Mentalidade, Foco e Superação da Paralisia por Complexidade', 'fase', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Trabalhar o padrão de paralisia identificado: "Quando eu chego nesse tipo de complexidade, eu nunca consegui avançar" — criar sistema de execução em pequenos passos', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar lista de "próximas ações físicas" por frente de trabalho — nunca mais de 3 por semana', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Agendar revisão semanal de prioridades com o mentor para calibrar foco', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Praticar "validar antes de completar" — testar hipóteses com ações mínimas antes de construir a estrutura completa', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Trabalhar o comportamento de olhar para concorrentes e travar — substituir por análise rápida de lacunas e execução imediata', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar ritual de análise de concorrente: máximo 30 minutos/mês, foco apenas em lacunas de oportunidade', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Internalizar diferenciação única: "nenhum concorrente tem a trajetória dos dois lados" — usar como âncora contra paralisia por comparação', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 3, 'Resolver o problema de precificação: Thiago reconheceu que "não sabia precificar a consultoria" — usar as faixas definidas no dossiê como âncora e testar com primeiros clientes', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Praticar autenticidade no conteúdo: "eu queria ser mais eu" — criar exercício de gravação informal semanal para desenvolver voz própria no digital', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ========================================
  -- FASE 13: Monitoramento, Métricas e Revisão de Resultados
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Monitoramento, Métricas e Revisão de Resultados', 'passo_executivo', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Definir métricas de sucesso para a Fase 1 (Ígnea Agro) — número de consultorias fechadas, receita, taxa de conversão para TK Advogados', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Definir meta de receita mensal mínima da Ígnea Agro (baseline: R$300K/ano identificado como não capturado)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Criar painel simples de acompanhamento: leads recebidos, qualificados, propostas enviadas, fechamentos, conversões para TK Advogados', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Acompanhar taxa de conversão da consultoria para representação jurídica (LTV do modelo boutique)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 2, 'Revisar mensalmente o PA com o mentor e ajustar prioridades conforme avanço das frentes (Fase 1, Fase 2 e Fase 3)', 'pendente', 'mentor', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 3, 'Documentar casos atendidos e resultados obtidos para criar banco de provas sociais — base para futuros conteúdos de autoridade', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Avaliar em 90 dias o progresso da Fase 1 para definir timing de início da Fase 2 (marca pessoal como estrategista neutro no @thiago_kailer)', 'pendente', 'mentor', 4, 'dossie_auto');

END $$;
