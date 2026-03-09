-- ===== MENTORADO: THIELLY PRADO (id=30) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (30, 'PLANO DE AÇÃO v2 | THIELLY PRADO', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- ============================================================
  -- FASE 1: Revisão do Dossiê Estratégico
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Ler e validar o diagnóstico completo do dossiê com a mentora Queila Trizotti', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Confirmar público-alvo validado: donas de negócios de beleza com 5–15 colaboradores e faturamento entre R$50k–R$200k/mês', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Validar posicionamento estratégico: mentora de liderança, cultura e excelência para empresárias da beleza', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Confirmar produto principal: Mentoria Aura Business (6 meses, R$25k ancoragem / R$20k parcelado / R$15k à vista)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Revisar os 4 pilares do Método Aura Business: Posicionamento Premium, Liderança que Cria Cultura, Experiência 360°, Estratégias de Crescimento', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 2: Estruturação do Posicionamento Digital
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Estruturação do Posicionamento Digital', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Criar novo Instagram estratégico separado do perfil banido (100% dedicado a tráfego e captação de leads)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Escolher nome do novo perfil (opções: @thiellyprado.academy, @thielly.aurabusiness, @thielly.beautyleader)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Configurar foto de perfil: close sofisticado, roupa neutra (preto/bege/branco), fundo claro, expressão de líder confiante', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Escrever bio seguindo estrutura: quem é + o que faz + prova social + CTA filtrado (lista de espera mentoria)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Configurar os 6 destaques essenciais do Instagram (Começar Aqui, Minha História, Liderança & Time, Campanhas & Estratégia, Experiência & Marca, Depoimentos)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Criar destaque "Começar Aqui": mini apresentação, valores e visão', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar destaque "Minha História": trajetória do hospital ao Aura, dor e transformação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Criar destaque "Liderança & Time": rituais de cultura, feedbacks, reuniões com balões', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Criar destaque "Experiência & Marca": atmosfera Aura, detalhes premium, estética sensorial', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 3, 'Criar e fixar os 3 posts estratégicos do perfil (storytelling premium, crenças sobre negócios, apresentação aspiracional da mentoria)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Post fixado 1: storytelling emocional + estratégico (prisão no negócio anterior → renascimento no Aura → liderança e cultura)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Post fixado 2: carrossel provocativo sobre crenças — "Negócio não cresce por mágica. Cresce por estratégia + liderança + cultura."', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Post fixado 3: apresentação aspiracional da mentoria (para quem é, para quem não é, o que transforma)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 4, 'Definir mensagem central da marca pessoal: "Você não cresce por sorte. Você cresce por estratégia + liderança + cultura."', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Usar o perfil banido apenas para collabs e construção de autoridade, nunca para tráfego pago', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 3: Produção da Primeira Leva de Conteúdo
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Produção da Primeira Leva de Conteúdo', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Produzir 15–20 vídeos curtos iniciais (45–60 segundos, estilo conversa espontânea, tom natural e premium)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Vídeo: "O que ninguém te conta sobre liderar um time na beleza"', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Vídeo: "Como eu penso cultura dentro do Aura"', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Vídeo: "A diferença entre equipe e movimento"', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Vídeo: "Por que experiência é mais importante que técnica"', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 5, 'Vídeo: "Erros que quase me fizeram desistir do empreendedorismo"', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 6, 'Vídeo: "A história dos balões e o conceito por trás"', 'pendente', 'mentorado', 6, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 7, 'Vídeo: "O que realmente faz um negócio de beleza crescer"', 'pendente', 'mentorado', 7, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 8, 'Vídeo: "Você sabe a diferença entre gestor e líder?"', 'pendente', 'mentorado', 8, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 9, 'Vídeo: "700 mil de faturamento por mês — os 4 pilares que sustentam isso"', 'pendente', 'mentorado', 9, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Registrar bastidores do aniversário de 3 anos do Aura para usar como primeira leva de conteúdo estratégico', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Filmar time se preparando, balões, estética e atmosfera do evento', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Registrar momentos emocionais da equipe (ritual dos balões com sonhos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Capturar bastidores da criação da experiência (café da manhã, decoração, celebração)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 3, 'Estabelecer ritmo de postagem: 3 a 4 vídeos por semana + 1 carrossel profundo + stories diários com bastidores', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Planejar collabs entre novo IG, perfil principal e Instagram do Aura para amplificar alcance', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Seguir calendário editorial semanal: domingo (desejo/oportunidade), segunda (confiança expert), terça (alcance/descoberta), quarta (infovendas), quinta (desejo), sexta (confiança), sábado (identificação)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 4: Pilar 1 — Posicionamento Premium
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Pilar 1 — Posicionamento Premium', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Mapeamento do cliente ideal de alto padrão', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Listar os 20 últimos clientes e classificar por ticket médio, frequência, indicações e nível de exigência', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Identificar os 5 clientes ideais (pagam bem, voltam sempre, indicam) e criar persona premium com foto e descrição completa', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Criar critérios de aceite para novos clientes e script de recusa educada para perfis fora do padrão', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Auditoria de imagem e identidade visual do negócio', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Fotografar estabelecimento em todos os ângulos e analisar o que comunica valor vs. o que precisa melhorar', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Avaliar apresentação pessoal e uniforme da equipe (alinhamento com padrão premium desejado)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Listar e priorizar 3 melhorias visuais para executar imediatamente (uniforme, iluminação, decoração)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 3, 'Definir o serviço âncora que representa o DNA da marca Aura', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Identificar serviço com maior margem, maior procura e que melhor representa o DNA da marca', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Reformular entrega do serviço âncora: agregar avaliação personalizada, brinde, pós-venda diferenciado', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Criar nome especial e narrativa premium para o serviço assinatura', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 4, 'Reestruturação de precificação consciente e alinhada ao posicionamento premium', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Calcular custo real de cada serviço (produto + tempo + equipe + estrutura)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Pesquisar 3 concorrentes do mesmo padrão desejado (não os mais baratos) como referência', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Definir novos preços baseados em custo + valor percebido + posicionamento desejado, e criar pacotes estratégicos (combos de valor, sem desconto)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 5, 'Criar estratégia de comunicação digital: definir 3 pilares de conteúdo e banco com 20–30 fotos/vídeos para 1 mês', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 5: Pilar 2 — Liderança que Cria Cultura
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Pilar 2 — Liderança que Cria Cultura', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Definir os valores e DNA da marca em documento formal', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Escrever a história da marca: por que criou o Aura, qual era o sonho, o que move até hoje', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Listar 5 valores inegociáveis e 3 comportamentos esperados que os representam na prática', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Apresentar documento de história + valores + comportamentos para toda a equipe em reunião especial', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Reestruturar processo de contratação com foco em fit cultural', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Criar roteiro de entrevista com perguntas de fit cultural (ex: "O que é excelência para você?", "Como você lida com feedback?")', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Definir 3 "sinais vermelhos" que indicam que a pessoa não é certa (ex: falta de pontualidade, resistência a seguir padrões)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Criar checklist de avaliação dos primeiros 30 dias com acompanhamento próximo', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 3, 'Criar rituais e rotinas de cultura fixos', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Definir reunião semanal de alinhamento (15–30 minutos toda segunda de manhã)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar ritual de boas-vindas para novos colaboradores (apresentação à equipe + kit de boas-vindas)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Estabelecer café da manhã mensal (última quarta) onde Thielly abre os números e celebra conquistas coletivas', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Documentar todos os rituais em calendário mensal fixo e compartilhar com a equipe', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 4, 'Estruturar onboarding e treinamento contínuo para novos colaboradores', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Montar roteiro de integração de 7 dias: Dia 1 história da marca + tour; Dias 2–3 shadowing; Dias 4–7 prática supervisionada', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar manual de padrões de atendimento e comportamento (slides ou PDF simples)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Gravar vídeos curtos (3–5 min) ensinando os principais processos do Aura', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Definir "padrinho/madrinha" para cada novo colaborador nos primeiros 30 dias', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 5, 'Implementar sistema de feedback semanal e protocolo de gestão de conflitos', 'pendente', 'mentorado', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Criar hábito de feedbacks semanais rápidos (2–3 minutos por pessoa) com script: reconhecer o bom + apontar melhoria + oferecer apoio', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Estabelecer conversas individuais mensais de 15–20 minutos com cada colaborador', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Criar protocolo de conflitos: conversa individual primeiro, depois mediação se necessário', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 6, 'Definir funções, processos e responsabilidades de cada colaborador com organograma simples', 'pendente', 'mentorado', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Criar organograma simples do negócio e descrição de cargo resumida para cada função (1 página)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Mapear processos do dia a dia (abertura, atendimento, fechamento, limpeza) e delegar responsáveis', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 7, 'Implementar cultura de metas coletivas mensais com acompanhamento semanal e celebração de resultados', 'pendente', 'mentorado', 7, 'dossie_auto');

  -- ============================================================
  -- FASE 6: Pilar 3 — Experiência 360°
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Pilar 3 — Experiência 360°', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Mapear a jornada atual da cliente do agendamento ao pós-atendimento', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Percorrer o caminho da cliente: desde agendar no WhatsApp até sair do salão, anotando cada ponto de contato', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Identificar 5 pontos críticos que precisam melhorar (ex: demora na resposta, recepção fria, ambiente bagunçado)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Pedir feedback sincero de 3 clientes fiéis sobre a experiência atual', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Criar ambiência sensorial completa no espaço (olfato, som, iluminação, temperatura, ordem visual)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Escolher aroma exclusivo do espaço (difusor/vela — baunilha, lavanda ou flor de laranjeira como assinatura Aura)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Montar playlist exclusiva no Spotify que transmita a energia do Aura (relaxante, sofisticada, leve)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Ajustar iluminação para tons quentes ou luz natural (evitar luz branca forte), garantir temperatura confortável', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 3, 'Criar rituais de encantamento que geram conexão emocional e tornam o atendimento memorável', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Implementar cappuccino personalizado com nome da cliente como assinatura do Aura', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar ritual de boas-vindas: cumprimentar pelo nome, oferecer bebida personalizada, gesto de acolhimento', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Incluir elemento surpresa durante atendimento (massagem nas mãos, frase inspiradora no espelho, momento de relaxamento)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Documentar todos os rituais para treinamento padronizado da equipe', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 4, 'Padronizar o atendimento em todos os pontos de contato com scripts definidos', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Criar script de atendimento no WhatsApp com a voz da marca (agendamentos, confirmações, dúvidas)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Padronizar recepção: o que falar quando a cliente chega, como cumprimentar, onde levá-la', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Definir ritual de despedida e treinamento de role-play com a equipe para simulações', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 5, 'Implementar estratégia de pós-atendimento que fideliza e converte clientes em promotoras', 'pendente', 'mentorado', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Enviar mensagem personalizada 2–4h após atendimento agradecendo e perguntando como a cliente está se sentindo', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar sistema de follow-up: mensagem de aniversário + lembrete de retorno 15–30 dias depois', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Solicitar indicação de forma natural ao final do atendimento com script definido', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 6, 'Transformar 2–3 cantinhos do salão em pontos instagramáveis para gerar mídia espontânea das clientes', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 7: Pilar 4 — Estratégias de Crescimento
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Pilar 4 — Estratégias de Crescimento', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Ativar as 20 clientes mais fiéis como canal de indicação (campanha estilo "Ação da Pipoca")', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Criar ação de indicação com benefício exclusivo (upgrade gratuito, brinde especial ou experiência VIP)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Comunicar a ação de forma personalizada (mensagem individualizada para cada cliente VIP)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Acompanhar e registrar indicações geradas e conversões em agendamentos', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Mapear e ativar parcerias estratégicas locais com marcas que atendem o mesmo público', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Listar 10 marcas ou profissionais locais com valores alinhados (cafés, lojas de roupa, clínicas, personal trainers)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Selecionar 3 parceiros para contato e propor ação conjunta (evento, sorteio, troca de brindes, co-branding)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 3, 'Criar calendário de campanhas internas mensais para os próximos 6 meses', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Mapear 6 datas estratégicas: Dia das Mulheres, Dia das Mães, Dia dos Namorados, Outubro Rosa, Black Friday (com Aura Day), Natal', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Para cada campanha: definir tema, oferta especial (valor agregado, não desconto), decoração temática e comunicação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Replicar modelo do Aura Day (aniversário do salão): pacotes estratégicos + experiência premium + evento com equipe', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 4, 'Criar pacotes estratégicos de alto valor com nomes atrativos (Aura Day, Dia do Autocuidado, Glow Total)', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Analisar serviços mais procurados juntos e montar 3 combos estratégicos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Precificar pacotes com valor agregado (não desconto): incluir mimo especial ou upgrade', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Criar arte visual premium para cada pacote e divulgá-los como experiências exclusivas', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 5, 'Otimizar agenda e reativar clientes inativas (60+ dias sem visita)', 'pendente', 'mentorado', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Levantar lista de clientes inativas e criar campanha de reativação com mensagem personalizada e incentivo para voltar', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar sistema de lembretes automáticos de retorno (30 dias após último atendimento)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 6, 'Introdução ao tráfego pago estratégico no Instagram/Facebook com foco local', 'pendente', 'mentorado', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Definir objetivo claro do primeiro anúncio (agendamentos, seguidores locais ou brand awareness)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar 1 anúncio simples com orçamento de R$10–20/dia e raio de 5–10km do salão usando conteúdo orgânico de melhor desempenho', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Monitorar resultados por 7 dias: mensagens recebidas, agendamentos, custo por lead', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- ============================================================
  -- FASE 8: Estruturação do Produto Mentoria Aura Business
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Estruturação do Produto Mentoria Aura Business', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Finalizar arquitetura completa do produto Mentoria Aura Business (6 meses, híbrida)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Definir cronograma dos encontros quinzenais online (revisão de resultados, ajustes de rota, planejamento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Planejar Imersão Presencial no Aura (1 dia intensivo de 8h ou 2 dias imersivos de 4–5h cada)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Estruturar grupo exclusivo no WhatsApp com dinâmica de suporte diário', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Criar Kit Completo de Ferramentas de Gestão para entrega às alunas', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Montar templates prontos de gestão de equipe (organograma, descrição de cargos, checklist de onboarding)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar planilhas de controle e indicadores (faturamento, ticket médio, metas, origem de clientes)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Compilar biblioteca de bastidores do Aura e manuais de liderança e processos internos', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Documentar rituais de cultura do Aura aplicáveis a outros negócios (reuniões, balões, café da manhã, celebrações)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 3, 'Criar formulário de diagnóstico individual para aplicar no início de cada mentoria (Mapa Estratégico Aura)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Definir estrutura de entregáveis da mentoria: diagnóstico + encontros quinzenais + suporte diário + imersão presencial + trilhas + ferramentas', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Precificar e documentar as condições de pagamento: R$25k ancoragem / R$20k parcelado / R$15k à vista', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 9: Preparação e Execução do Evento de Lançamento
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Preparação e Execução do Evento de Lançamento', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Definir conceito, nome e data do evento presencial de lançamento (Aura Business Day / Boss Beauty / Master Aura)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Escolher data entre 20 e 31 de janeiro (energia de planejamento do início de ano)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Confirmar local: espaço clean, elegante e minimalista para 20–30 participantes', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Definir meta de vendas para o evento: 5–15 fechamentos', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Montar lista de 80–150 potenciais participantes qualificados (empresárias com equipe e dor de liderança)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Levantar base de clientes VIP do Aura, donas de studio/spa/clínica e profissionais com equipe', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar formulário de qualificação com perguntas: estágio do negócio, tamanho da equipe, maior desafio, objetivo', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 3, 'Estruturar conteúdo e pitch do evento (marcar call de preparação com Queila)', 'pendente', 'mentor', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Bloco 1: História + autoridade + conexão emocional (dores do público + trajetória da Thielly + resultados reais)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Bloco 2: Jornada do cliente + problemas invisíveis + perguntas de interação para gerar consciência de problema', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Bloco 3: Vendas com naturalidade — quebrar crenças, mostrar provas de resultado, instalar nova mentalidade', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Pitch: apresentar oferta, ancoragem de preço (R$50k → R$25k especial), condições e chamada para ação', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 4, 'Divulgação do evento: lista pessoal + Instagram + prospecção ativa com convites individualizados', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Enviar convites via ligação direta, áudio personalizado e mensagem no WhatsApp para lista qualificada', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Publicar no Instagram usando bastidores do aniversário do Aura como gancho de autoridade', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Fazer collabs com perfil do Aura e perfil pessoal para amplificar alcance do evento', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 5, 'Organizar logística do evento: coffee premium, material impresso, time de apoio (recepção + registro + fechamento de vendas)', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 6, 'Executar follow-up com interessados que não fecharam no evento (até 24–48h após) com mensagem personalizada', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 10: Gestão do Instagram Banido e Transição de Perfil
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Gestão do Instagram Banido e Transição de Perfil', 'fase', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Aceitar que o perfil banido não será usado para tráfego pago (situação quase impossível de reverter sem processo)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Usar perfil banido exclusivamente para collabs com o novo perfil estratégico e construção de autoridade passiva', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Comunicar a transição para seguidores do perfil atual de forma natural, direcionando para o novo perfil', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Garantir que o novo perfil estratégico esteja 100% configurado antes de iniciar tráfego pago', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Monitorar crescimento do novo perfil semanalmente e ajustar estratégia de conteúdo conforme resultados', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 11: Desenvolvimento do Storytelling e Narrativa Pessoal
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Desenvolvimento do Storytelling e Narrativa Pessoal', 'fase', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Sistematizar o storytelling pessoal para uso em conteúdo, eventos e pitches de venda', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Documentar a história do hospital: filha com câncer, venda de perfumes, sobrancelhas para enfermeiras — origem do dom de levantar mulheres', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Descrever a transição: saída da sociedade anterior (12–14h/dia, exaustão, sem paz) para criação do Aura em 20 dias', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Construir narrativa de resultados: 3 anos → 60+ colaboradores → R$700k/mês → parceria com Natália Beauty', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Criar versões do storytelling para diferentes contextos: reels curtos (60s), carrosséis, eventos presenciais e pitches', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Treinar a habilidade de ensinar o que faz intuitivamente (transformar "competência inconsciente" em método ensinável)', 'pendente', 'mentor', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Gravar vídeos respondendo: "Por que você faz isso?" para cada prática do Aura (extrair o método intuitivo)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Escrever os critérios de cada decisão estratégica (contratação, campanhas, precificação) de forma didática', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 3, 'Criar banco de conteúdo de roteiros prontos baseados nos ganchos validados (Alcance, Consciência de Problema, Confiança, Desejo, Identificação)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Gravar o vídeo "Profissionais da beleza não são difíceis. Difícil é liderar sem postura." como conteúdo viral de autoridade', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ============================================================
  -- FASE 12: Parceria Estratégica com Natália Beauty
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Parceria Estratégica com Natália Beauty e Network Nacional', 'fase', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Alavancar a parceria com Natália Beauty como prova social de autoridade nacional no posicionamento digital', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Criar conteúdo sobre a trajetória: de cliente da Natália Beauty a sócia no projeto de transplante de sobrancelhas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Usar o lançamento em São Paulo do projeto de transplante como marco de prova de credibilidade', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Mapear conexões com médicas, esteticistas e empresárias do network da Natália Beauty como potenciais alunas da mentoria', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Identificar oportunidades de collab de conteúdo com parceiros e figuras de autoridade do setor de beleza nacional', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 13: Pós-Validação e Escalabilidade
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Pós-Validação e Escalabilidade da Mentoria', 'fase', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Revisar feedbacks das primeiras alunas e aprimorar a entrega da mentoria', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Criar formulário de satisfação intermediário (mês 3) e final (mês 6) para cada aluna', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Documentar casos de transformação reais para usar como prova social em futuras vendas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Gravar depoimentos em vídeo de alunas satisfeitas (antes/depois de resultados práticos)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Aprofundar os pilares da mentoria com base no feedback das alunas e ajustar conteúdo programático', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Revisar e atualizar os 4 pilares (Posicionamento, Liderança, Experiência, Crescimento) com exemplos reais das alunas', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar módulo adicional baseado nas dores mais recorrentes identificadas durante a mentoria', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 3, 'Construir funil de conteúdo contínuo para captação de novas turmas (calendário 2025–2026)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Avaliar criação de produtos complementares: Experiência Presencial no Aura (imersão), formatos de grupo menor, e-book de metodologia', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Planejar expansão para alcance nacional: parceiros estratégicos, eventos em outras cidades, collab com influenciadoras do setor', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 14: Acompanhamento de KPIs e Ajustes Estratégicos
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Acompanhamento de KPIs e Ajustes Estratégicos', 'passo_executivo', 14, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Criar dashboard de indicadores de crescimento do Aura e da mentoria', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Monitorar mensalmente: faturamento do Aura, ticket médio, novos clientes, clientes inativos recuperados', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Monitorar crescimento do Instagram: seguidores, alcance, engajamento, DMs de potenciais alunas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Rastrear funil de vendas da mentoria: leads qualificados → evento → vendas → taxa de conversão', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 2, 'Realizar revisão estratégica mensal com a mentora Queila para ajustar rotas e prioridades', 'pendente', 'mentor', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Documentar aprendizados, erros e acertos de cada campanha e ação executada para construção do método pessoal', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Celebrar marcos atingidos com a equipe do Aura (reforçar cultura de reconhecimento e pertencimento)', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;
