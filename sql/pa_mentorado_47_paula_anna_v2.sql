-- ===== MENTORADO: PAULA E ANNA - KAVA ARQUITETURA (id=47) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (47, 'PLANO DE AÇÃO v2 | PAULA E ANNA - KAVA ARQUITETURA', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- FASE 1: Revisão do Dossiê Estratégico
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 1, 'Ler o dossiê completo e anotar dúvidas e pontos de atenção', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 2, 'Revisar seção de Storytelling (origem da Kava, saída da terceira sócia, boom na pandemia, expansão para SP, validação do Cronograma Reverso Financeiro)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 3, 'Revisar seção de Público-Alvo (arquitetos B2B com faturamento R$20k-50k com dores de obra, e clientes B2C alto padrão empresários/executivos)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Revisar seção de Oferta (Mentoria Ordem & Obra® / Cronograma Reverso, 5 pilares, R$15k à vista ou 5x R$4k, bônus 1 e 4)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 5, 'Revisar Arquitetura do Produto (5 pilares: Fundamentos, Venda e Posicionamento, Construção do Cronograma, Gestão e Intercorrências, Entrega e Autoridade)', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 6, 'Revisar Estratégia do Funil (13 etapas: nome/promessa/data, grupo WhatsApp, lapidação de perfil, lista de contatos, convites, comunicação no grupo, roteiro, setup, abordagem pós-aula, onboarding)', 'pendente', 'mentorado', 6, 'dossie_auto');


  -- FASE 2: Posicionamento e Identidade de Marca
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Posicionamento e Identidade de Marca', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 1, 'Consolidar tese de posicionamento: "Arquitetura com método, gestão e responsabilidade — obra previsível do início ao fim"', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Escrever a tese central da Kava em uma frase definitiva (base para toda comunicação)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Validar o diferencial do Cronograma Reverso como mecanismo central de valor e assinatura autoral', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Definir a frase-manifesto do escritório ("projetos bonitos sem dor de cabeça" ou variação alinhada)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 2, 'Escolher e aplicar uma das 3 versões de bio sugeridas no dossiê para o perfil @kava_arq', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 3, 'Definir nome de exibição do perfil entre as opções sugeridas (Kava Arquitetura | Gestão de Obras / Projetos & Acompanhamento / Arquitetura sem Dor de Cabeça)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Confirmar nome e promessa da aula de captação: "Entre o Projeto e a Obra: como fechar escopo, defender prazo e evitar trabalhar mais sem ganhar mais"', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 5, 'Definir data e horário definitivos da aula de captação (sugerido 09 de março às 18h30)', 'pendente', 'mentorado', 5, 'dossie_auto');


  -- FASE 3: Lapidação do Perfil Instagram
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Lapidação do Perfil Instagram @kava_arq', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 1, 'Realizar auditoria completa do feed com checklist do dossiê (regra dos 5 segundos: parece alto padrão? consistente? atende poucos e melhores?)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Identificar e arquivar posts com projeto "classe média" (acabamento simples, objetos baratos, ambiente que não expande)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Arquivar post/destaque da Creche EB (gera ruído de posicionamento com alto padrão)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Arquivar posts com visual poluído, mistura de estilos ou imagem descuidada das sócias (sem maquiagem/roupa fora do posicionamento)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 4, 'Identificar posts que precisam de upgrade (projeto bom, foto ruim) para planejar regravação', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 2, 'Ajustar foto de perfil (aumentar contraste, crop mais fechado no rosto, postura firme — ambiente de obra ou escritório, não sofá)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Planejar sessão fotográfica com Anna e Paula em pé, postura firme, alfaiataria leve, ambiente de obra ou escritório', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Configurar iPhone para qualidade máxima e garantir luz adequada (softbox ou ring light) na sessão', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 3, 'Reestruturar destaques do perfil conforme nova arquitetura do dossiê (7 destaques: História, Projetos/Clientes, Serviços, Mentoria, Prova/Alunos, Bastidores, Lifestyle)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Trocar capas dos destaques de círculos neutros para imagens reais dos projetos (fotos de obras e interiores premium)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 5, 'Definir estilo visual único do feed (paleta, mood, tipo de projeto) e criar guia de padrão de produção futuro', 'pendente', 'mentorado', 5, 'dossie_auto');


  -- FASE 4: Preparação e Execução do Funil (Etapas 1-4)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Preparação do Funil de Captação (Etapas 1 a 4)', 'passo_executivo', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 1, 'Etapa 1 — Definir nome, promessa e data da aula de captação', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Confirmar nome final da aula: "Entre o Projeto e a Obra: como fechar escopo, defender prazo e evitar trabalhar mais sem ganhar mais"', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Confirmar data/horário da aula e criar link do Zoom com capacidade compatível com o tráfego esperado', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Criar formulário de inscrição no Google Forms com perguntas: nome, e-mail, WhatsApp, conforme modelo do dossiê', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 4, 'Configurar página de "obrigado" com redirecionamento para grupo de WhatsApp após inscrição', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 2, 'Etapa 2 — Criar grupo de WhatsApp exclusivo para a aula', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Criar grupo com nome oficial: "Entre o Projeto e a Obra | Kava Arquitetura"', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Configurar grupo como canal de comunicação oficial (apenas admins postam, mensagens somente leitura para membros)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Gerar link de convite do grupo para inserir na página de "obrigado" do formulário', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 3, 'Etapa 3 — Executar lapidação do perfil Instagram conforme plano da Fase 3', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Etapa 4 — Organizar lista de contatos em planilha Google Sheets (nome, profissão, cidade, como conhece, grau de proximidade, observação)', 'pendente', 'mentorado', 4, 'dossie_auto');


  -- FASE 5: Captação e Aquecimento (Etapas 5-7)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Captação e Aquecimento da Audiência (Etapas 5 a 7)', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 1, 'Etapa 5 — Convite personalizado para a base de contatos profissionais (Prioridade 1: contatos próximos → Prioridade 2: conhecidos → Prioridade 3: mais frios)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Abordar Prioridade 1 com mensagem íntima (opção "amiga" do dossiê): ancorando revisão de obras antigas e mudança no jeito de iniciar obra', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Abordar Prioridade 2 com mensagem de contexto (12 anos de obra, método, estruturação antes da execução)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Abordar Prioridade 3 com mensagem completa (identidade + origem do contato + mecanismo + convite para grupo)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 4, 'Garantir que a origem do contato exista ANTES de enviar qualquer mensagem (regra de ouro do dossiê)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 2, 'Etapa 6 — Convite para a base do Instagram (Reels ou Carrossel + sequência de Stories em 3 rodadas)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Criar Reels de convite (30-60s) seguindo a estrutura do dossiê: gancho → regancho → contexto → mecanismo → transformação → origem → convite → CTA', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Publicar Stories Rodada 1 (interrupção de padrão): "tem uma parte da obra que quase ninguém presta atenção..."', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Publicar Stories Rodada 2 (storytelling + mecanismo): origem do cronograma reverso, erros no início, virada de chave', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 4, 'Publicar Stories Rodada 3 (convite final): encontro online fechado, limitado, "me manda mensagem que te coloco no grupo"', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 5, 'Nunca usar "aula gratuita" — sempre "encontro online", "encontro privado" ou "encontro entre colegas"', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 3, 'Etapa 7 — Comunicação estratégica no grupo de WhatsApp (9 mensagens: boas-vindas, faltam 5 dias, 3 dias, amanhã, hoje manhã, 1h antes, ao vivo, 15min após, pós-encontro)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Preparar e agendar Mensagem 1 (boas-vindas): apresentação do grupo, data/horário, link virá mais perto', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Enviar Mensagem 2 (faltam 5 dias) em áudio: ponto central não é cronograma em si — é como a obra começa', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Enviar Mensagem 3 (faltam 3 dias) com foto do cronograma impresso: estrutura objetiva do encontro', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 4, 'Enviar Mensagens 4-9 nos momentos corretos: véspera, manhã do dia, 1h antes, ao vivo, 15min após início, pós-encontro com link de aplicação', 'pendente', 'mentorado', 4, 'dossie_auto');


  -- FASE 6: Preparação e Execução da Aula (Etapas 8-9)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Preparação e Execução da Aula de Captação (Etapas 8 a 9)', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 1, 'Etapa 8 — Preparar roteiro completo da aula conforme estrutura do dossiê (Início: autoridade → Meio: consciência + desejo → Transição: oferta)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Preparar bloco INÍCIO: boas-vindas, apresentação da trajetória Kava (pandemia, SP, cronograma), promessa do evento, jornada da aula, orientações', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Preparar bloco MEIO: problema (bom projeto, obra desorganizada), crenças limitantes ("obra é imprevisível mesmo"), jeito errado, consequências, solução conceitual, prova, desejo, visualização de vida futura', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Preparar bloco TRANSIÇÃO: apresentação da Mentoria Ordem & Obra®, diferenciais, urgência (vagas limitadas), CTA de aplicação', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 4, 'Preparar exemplos reais de obras antes/depois do cronograma reverso para o bloco de prova (decisões evitadas, conflitos reduzidos)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 2, 'Etapa 9 — Setup técnico completo da transmissão da aula e formulário de aplicação da mentoria', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Criar e testar link do Zoom (nome: "Cronograma Reverso na Prática: como sair do caos da obra e assumir controle — Aula Kava Arquitetura")', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Conferir plano da conta Zoom (participantes simultâneos) e subir para Webinar se necessário', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Criar formulário de aplicação da mentoria com 11 perguntas do dossiê (perfil, tipo de obra, dificuldades, expectativas para 2026, modelo de investimento)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 4, 'Configurar planilha automática de respostas do formulário e alinhar time sobre critérios de prioridade (à vista antes de parcelado)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 5, 'Testar transmissão com pelo menos 1 pessoa externa (áudio, vídeo, gravação automática, permissão de entrada)', 'pendente', 'mentorado', 5, 'dossie_auto');


  -- FASE 7: Abordagem Pós-Aula (Quem Fez Aplicação)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Abordagem Pós-Aula para Quem Fez Aplicação (Etapa 10)', 'passo_executivo', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 1, 'Organizar lista de aplicações priorizando quem marcou à vista, depois parcelado, lendo aplicação inteira antes de qualquer contato', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Ler cada aplicação: tipo de obra, dor central, momento profissional, faturamento estimado', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Separar lista em: Prioridade 1 (à vista) e Prioridade 2 (parcelado)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 2, 'Enviar mensagem de abertura no WhatsApp: perfil aprovado, precisa finalizar inscrição e confirmar detalhes, pergunta se consegue falar agora', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Se respondeu: fazer ligação imediata e conduzir para fechamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Se não respondeu em 6-8h: Follow-up 1 com texto de urgência leve', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Se não respondeu: ligação direta → se não atender → Mensagem 3 pós-ligação sem atender → ligação no horário combinado → Mensagem 4 de liberação de vaga', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 3, 'Executar script de ligação de fechamento: abertura tranquila → confirmação de contexto → dor central → autoridade da Kava → recapitulação → oferta → investimento (R$20.000 ou R$15.000 à vista) → fechamento', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Usar escuta ativa nas perguntas de dor: "onde a obra mais te desgasta hoje?" e "onde você ainda improvisa?"', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Apresentar investimento sem pedir permissão e fazer pausa/silêncio após citar o valor', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'NUNCA: marcar outra call, aceitar "pensar e voltar", dar desconto, convencer indeciso crônico', 'pendente', 'mentorado', 3, 'dossie_auto');


  -- FASE 8: Abordagem Pós-Aula (Quem Não Fez Aplicação)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Abordagem Pós-Aula para Quem Não Fez Aplicação (Etapa 11)', 'passo_executivo', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 1, 'Organizar lista de quem assistiu à aula mas não preencheu aplicação, priorizando quem atuou em obra e demonstrou engajamento ao vivo', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Nunca disparar mensagens sem organizar a lista e entender perfil de cada um', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Priorizar: arquitetos atuando em obra > escritórios pequenos/médios > quem demonstrou engajamento (mensagem, reação)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 2, 'Executar sequência de 6 follow-ups conforme dossiê (D+0 abordagem → D+1 texto + áudio → ligação → D+2 ligação combinada → D+2 texto urgência → D+3 isolar objeção → D+4 caso real → D+5 última chance)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'D+0: Enviar Versão 1 ou 2 da abordagem inicial (mencionando algo específico da atuação quando possível)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'D+1: Follow-up 1 (texto) + Follow-up 2 (áudio 1min: arquitetos talentosos sem gestão vivem apagando incêndio)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'D+3: Follow-up 4 em áudio isolando objeção: tempo, dinheiro ou falta de interesse — respeitar qualquer resposta', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 4, 'D+5: Follow-up 6 — áudio de encerramento com escassez real e tom de autoridade madura', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 3, 'Conduzir ligações de qualificação: entender fit → se tiver fit conduzir para fechamento → se não tiver fit encerrar com respeito', 'pendente', 'mentorado', 3, 'dossie_auto');


  -- FASE 9: Onboarding e Confirmação da Turma (Etapa 12)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Onboarding e Confirmação da Turma (Etapa 12)', 'passo_executivo', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 1, 'Gravar e enviar vídeo de boas-vindas para cada mentorado aprovado na turma', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Criar vídeo de boas-vindas personalizado: confirmar entrada, reforçar decisão, apresentar o que vem a seguir', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Enviar vídeo junto com acesso à plataforma de aulas e instruções de primeiro acesso', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 2, 'Criar e adicionar mentorados no grupo de WhatsApp exclusivo da turma', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 3, 'Confirmar e comunicar datas de todos os encontros ao vivo (individuais e em grupo/quinzenal)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Enviar recomendações de estudo prévio e materiais de apoio de boas-vindas (checklists, modelos iniciais)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 5, 'Agendar 3 encontros individuais por mentorado conforme compromisso da oferta', 'pendente', 'mentorado', 5, 'dossie_auto');


  -- FASE 10: Estruturação do Produto Educacional (5 Pilares)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Estruturação do Produto Educacional — 5 Pilares da Mentoria', 'fase', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 1, 'Pilar 1 — Gravar aulas de Fundamentos do Cronograma Reverso (o que é, o que não é, diferença projeto/obra/gestão, onde entra no fluxo, por que improviso gera atraso)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Criar mapa visual de distinção entre projeto, obra e gestão', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Desenvolver checklist de leitura inicial da obra para o aluno usar como ferramenta de apoio', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 2, 'Pilar 2 — Gravar aulas de Venda e Posicionamento do Acompanhamento de Obra (como apresentar, justificar valor, filtrar clientes, assumir autoridade comercial)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Criar roteiro de apresentação do acompanhamento de obra para uso em reunião comercial', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Desenvolver critérios de seleção de clientes e obras (quem é o cliente certo vs. cliente errado)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Criar estrutura de argumentação para justificar valor do acompanhamento com base no Cronograma Reverso', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 3, 'Pilar 3 — Gravar aulas de Construção do Cronograma Reverso (leitura estratégica da obra, mapeamento de etapas, fluxo de trabalho, alinhamento de expectativas)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Criar modelo base do Cronograma Reverso para os alunos usarem como ponto de partida', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Desenvolver guia de mapeamento completo de etapas da obra', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Criar roteiro de alinhamento de expectativas com o cliente a partir do cronograma', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 4, 'Pilar 4 — Gravar aulas de Gestão, Atualização e Intercorrências (rotina de atualização, pontos críticos, tomada de decisão, comunicação com cliente e fornecedores)', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Criar rotina recorrente de atualização do cronograma reverso (frequência, responsável, formato)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Desenvolver checklist de pontos críticos da obra (identificação de riscos antes de virarem problemas)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Criar roteiro de comunicação assertiva com cliente e fornecedores usando o cronograma como referência', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 5, 'Pilar 5 — Gravar aulas de Entrega, Experiência e Autoridade (fechamento da obra, captação de depoimentos, construção de autoridade, obra como ativo)', 'pendente', 'mentorado', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Criar processo estruturado de fechamento de obra (checklist de entrega, documentação final)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Desenvolver roteiro de solicitação de depoimentos pós-obra (questionário + roteiro de vídeo-depoimento)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Criar estrutura de uso da obra como ativo de autoridade e posicionamento profissional (template de caso de sucesso para portfólio)', 'pendente', 'mentorado', 3, 'dossie_auto');


  -- FASE 11: Produção dos Bônus (Kit Templates e Guia Instagram)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Produção dos Bônus da Mentoria (Bônus 1 e Bônus 4)', 'fase', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 1, 'Bônus 1 — Criar Kit Completo de Templates Visuais para Cliente (apresentação editável do cronograma, relatórios de andamento, timeline visual, checklist de entrega por etapa)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Criar apresentação editável do cronograma reverso para enviar ao cliente (formato Canva ou Slides)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Criar modelo de relatório de andamento de obra (atualização periódica para o cliente)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Criar timeline visual simplificada para reuniões com cliente (fácil leitura, sem jargão técnico)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 4, 'Criar checklist de entrega de cada etapa da obra', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 2, 'Bônus 4 — Criar Guia de Comunicação para Instagram/LinkedIn (30 ideias de posts sobre gestão de obra, templates de carrossel, roteiro de stories de bastidores)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Listar 30 ideias de conteúdo sobre gestão de obra e Cronograma Reverso para o mentorado usar no perfil', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Criar templates de carrossel editáveis no Canva para posts sobre gestão de obra', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Criar roteiro modelo de stories mostrando bastidores de obra organizada (sem glamour, com processo)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 3, 'Definir plataforma de hospedagem dos conteúdos e materiais da mentoria (Hotmart, Teachable, Notion ou similar)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Subir e organizar todos os materiais gravados e bônus na plataforma escolhida antes do início da turma', 'pendente', 'mentorado', 4, 'dossie_auto');


  -- FASE 12: Produção de Conteúdo Estratégico (Etapa 13)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Produção de Conteúdo Estratégico para o Perfil (Etapa 13)', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 1, 'Criar conteúdo "O Erro que Faz Obras Atrasarem": fase crucial entre projeto e obra que arquitetos pulam → apresentar Cronograma Reverso como solução', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Definir formato (Reels ou Carrossel) e gravar com Anna ou Paula falando diretamente para câmera', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Usar gancho: "Por que nossos projetos sempre ficam prontos antes da data prevista e não dão problema?"', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 2, 'Criar conteúdo "Por Que Clientes Ficam Sem Dinheiro no Meio da Obra": fluxo de caixa da obra, previsibilidade com cronograma reverso + planilha financeira, cliente sabe quando gastar', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Mostrar como o cronograma reverso + planilha financeira dá previsibilidade de caixa ao cliente (aplicações, resgates, picos de gasto)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Usar gancho: "A verdadeira razão das brigas entre arquiteto e cliente (e como evitar)"', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 3, 'Criar conteúdo "Posicionamento: Beleza + Eficiência": diferencial Kava = estética + organização + processo, marca como identidade/cultura do escritório', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Criar conteúdo "O Que É o Cronograma Reverso": planejar de trás para frente a partir da data de entrega, cliente define quando quer se mudar e você diz o que é plausível', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 5, 'Criar conteúdo "Como Tiramos o Cliente da Obra": papel da arquiteta no acompanhamento, cliente só "passeia", apresentação de opções A ou B, cliente entrega nas mãos', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 6, 'Criar conteúdo "A Diferença Entre Fazer Projeto e Acompanhar Obra": breakdown do faturamento (1/3 projeto, 1/3 acompanhamento, RT em tudo), obra sem estresse com método', 'pendente', 'mentorado', 6, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 7, 'Gravar depoimentos de clientes sobre a experiência com o cronograma reverso: segurança, saber o que acontece sem estar fisicamente na obra, tranquilidade', 'pendente', 'mentorado', 7, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 8, 'Produzir os 5 posts fixados do perfil usando o Agente de Conteúdo: História, Prova de Mentoria, Prova de Cliente, O Que É a Mentoria, Quais Serviços', 'pendente', 'mentorado', 8, 'dossie_auto');


  -- FASE 13: Escalabilidade e Próximo Funil (Tráfego Pago)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Escalabilidade e Próximo Funil (Tráfego Pago)', 'fase', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 47, 1, 'Após validar a oferta com a primeira turma, solicitar à equipe Case o próximo funil com tráfego pago', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 47, 1, 'Documentar resultados da primeira turma: taxa de conversão da aula, número de mentorados, faturamento, principais objeções', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 2, 'Consolidar depoimentos e provas sociais da primeira turma para usar no próximo funil', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 47, 3, 'Identificar ajustes necessários na oferta, roteiro da aula e abordagem pós-aula para a próxima turma', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 2, 'Estruturar autoridade educacional B2B no perfil @kava_arq (destaque MENTORIA, destaque PROVA/ALUNOS, posts fixados de mentoria)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 3, 'Avaliar criação de perfil separado de mentoria ou manter perfil híbrido conforme recomendação do dossiê (manter híbrido por enquanto — lapidar, não criar novo perfil)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Planejar estratégia de produção de mídia em lote: reservar 2 dias para gravação em bloco (troca de roupa, aproveita maquiagem/cabelo, resolve múltiplos conteúdos)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 5, 'Consolidar autoridade B2C no feed com portfólio curado: projetos residenciais alto padrão (Apt, Cob, Casa, Triplex RJ e SP), priorizando metragem, tipo de cliente e cidade', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 6, 'Estruturar sistema de acompanhamento de clientes B2C com apresentação de opções A ou B, alinhamento semanal e cronograma como referência de prazo e financeiro', 'pendente', 'mentorado', 6, 'dossie_auto');

END $$;
