-- =============================================================
-- PLANO DE ACAO COMPLETO - Paula e Anna (KAVA Arquitetura)
-- mentorado_id = 47
-- Gerado automaticamente a partir do Dossie Estrategico
-- =============================================================

DO $
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN

-- =============================================================
-- PLANO
-- =============================================================
INSERT INTO pa_planos (mentorado_id, titulo, descricao, status, origem)
VALUES (
  47,
  'Plano de Acao - Paula e Anna (KAVA Arquitetura)',
  'Lancamento da Mentoria Cronograma Reverso / Ordem e Obra. Metodo de gestao de obra para arquitetos. Posicionamento premium, funil de 13 etapas, aula ao vivo com transicao para oferta de mentoria R$20k.',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _plano_id;

-- =============================================================
-- FASE 0 - REVISAO DO DOSSIE ESTRATEGICO
-- =============================================================
INSERT INTO pa_fases (plano_id, numero, titulo, descricao, tipo, status, origem)
VALUES (
  _plano_id, 0,
  'Revisao do Dossie Estrategico',
  'Leitura e validacao de todas as secoes do dossie antes de iniciar a execucao. Garantir alinhamento entre posicionamento, storytelling, oferta, produto e funil.',
  'revisao_dossie',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _fase_id;

  -- Acao 0.1
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 1, 'Revisar secao de Contexto e Posicionamento',
    'Ler e validar o contexto das experts (KAVA Arquitetura, 12+ anos RJ, 4 anos SP, cronograma reverso, ticket ~R$100/m2). Confirmar reposicionamento de "projeto + estetica" para "gestao de obra com metodo".',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 0.2
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 2, 'Revisar secao de Storytelling',
    'Validar narrativa de origem da KAVA (de Tres Arquitetura a KAVA), crescimento na pandemia, expansao para SP e criacao do Cronograma Reverso Financeiro. Confirmar tom e autenticidade.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 0.3
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 3, 'Revisar secao de Publico-Alvo (Mentoria + Clientes)',
    'Validar perfil do publico da mentoria (arquitetos com clientes ativos, R$20k-50k/mes, transicao de tecnico para gestor) e perfil dos clientes finais (executivos, empresarios, alto padrao).',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 0.4
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 4, 'Revisar secao de Oferta e Arquitetura do Produto',
    'Validar os 5 pilares da mentoria: Fundamentos do Cronograma Reverso, Venda e Posicionamento do Acompanhamento, Construcao do Cronograma Reverso, Gestao/Atualizacao/Intercorrencias, Entrega/Experiencia/Autoridade.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 0.5
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 5, 'Revisar secao de Estrategia do Funil (13 Etapas)',
    'Ler e compreender as 13 etapas do funil de vendas: da preparacao (etapas 1-4), captacao (5-7), aula (8-9) e vendas (10-13). Marcar duvidas para alinhar com mentor.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 0.6
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 6, 'Revisar secao de Lapidacao do Perfil (Instagram)',
    'Validar sugestoes de foto, bio, destaques (7 sugeridos: Historia, Projetos/Clientes, Servicos, Mentoria, Prova/Alunos, Bastidores, Lifestyle), posts fixados e auditoria do feed.',
    'mentorado', 'pendente', 'dossie_auto');

-- =============================================================
-- FASE 1 - DEFINIR NOME, PROMESSA E DATA
-- =============================================================
INSERT INTO pa_fases (plano_id, numero, titulo, descricao, tipo, status, origem)
VALUES (
  _plano_id, 1,
  'Definir Nome, Promessa e Data da Aula',
  'Etapa 1 do funil. Definir o nome oficial do encontro, a promessa central e a data/horario. Garantir alinhamento entre nome e posicionamento premium.',
  'fase',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _fase_id;

  -- Acao 1.1
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 1, 'Definir nome oficial do encontro',
    'Escolher entre opcoes sugeridas: "Entre o Projeto e a Obra: como o Cronograma Reverso organiza prazo, cliente e faturamento" ou variacao. Nome deve refletir metodo, nao "aula gratuita".',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 1.2
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 2, 'Definir promessa central do evento',
    'A promessa deve comunicar: por que obras desorganizam mesmo com bons projetos, onde nasce o caos (antes da execucao) e como o Cronograma Reverso muda prazo, negociacao e faturamento.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 1.3
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 3, 'Definir data e horario do encontro',
    'Escolher data e horario considerando disponibilidade e melhor janela para o publico-alvo (arquitetos). Considerar dias uteis, horario noturno ou final de tarde.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 1.4
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 4, 'Validar nome e promessa com mentor Spalla',
    'Enviar nome, promessa e data para validacao. Confirmar alinhamento com posicionamento premium e estrategia do funil.',
    'mentor', 'pendente', 'dossie_auto');

-- =============================================================
-- FASE 2 - CRIAR GRUPO DE WHATSAPP
-- =============================================================
INSERT INTO pa_fases (plano_id, numero, titulo, descricao, tipo, status, origem)
VALUES (
  _plano_id, 2,
  'Criar e Configurar Grupo de WhatsApp',
  'Etapa 2 do funil. Criar grupo fechado para comunicacao pre-aula. Nao e grupo de conversa nem de vendas - e canal oficial de preparacao.',
  'fase',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _fase_id;

  -- Acao 2.1
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 1, 'Criar grupo no WhatsApp com nome do evento',
    'Criar grupo fechado com o nome do encontro. Configurar para que apenas admins possam enviar mensagens. Adicionar foto de capa profissional.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 2.2
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 2, 'Preparar mensagem de boas-vindas do grupo',
    'Redigir mensagem conforme modelo do dossie: apresentacao do grupo, data/horario, o que sera compartilhado (link, lembretes, contextos previos). Tom profissional e objetivo.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 2.3
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 3, 'Preparar sequencia de 9 mensagens de aquecimento',
    'Escrever/adaptar as 9 mensagens do dossie: boas-vindas, faltam 5 dias (audio), faltam 3 dias, e amanha, e hoje (link), falta 1h (audio), ao vivo, ainda da tempo, pos-encontro.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 2.4
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 4, 'Definir cronograma de envio das mensagens',
    'Mapear datas exatas de envio de cada mensagem baseado na data do evento. Criar alarmes/lembretes para nao esquecer.',
    'mentorado', 'pendente', 'dossie_auto');

-- =============================================================
-- FASE 3 - LAPIDACAO DO PERFIL (INSTAGRAM)
-- =============================================================
INSERT INTO pa_fases (plano_id, numero, titulo, descricao, tipo, status, origem)
VALUES (
  _plano_id, 3,
  'Lapidacao do Perfil do Instagram',
  'Etapa 3 do funil. Otimizar perfil do Instagram para posicionamento premium: foto, bio, destaques, posts fixados e auditoria do feed.',
  'fase',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _fase_id;

  -- Acao 3.1
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 1, 'Atualizar foto de perfil',
    'Foto profissional, com boa iluminacao, mostrando rosto claramente. Transmitir autoridade e acessibilidade. Evitar fotos de obra ou logotipo.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 3.2
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 2, 'Reescrever bio do Instagram',
    'Bio deve comunicar: quem sao (arquitetas que projetam, acompanham e executam), metodo (Cronograma Reverso), resultado (obra com previsibilidade). Usar sugestoes do dossie.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 3.3
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 3, 'Reorganizar destaques do perfil',
    'Implementar 7 destaques sugeridos: Historia, Projetos/Clientes, Servicos, Mentoria, Prova/Alunos, Bastidores, Lifestyle. Cada destaque deve ter capa visual coerente.',
    'mentorado', 'pendente', 'dossie_auto')
  RETURNING id INTO _acao_id;

    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 1, 'Criar destaque Historia', 'Contar origem da KAVA, trajetoria, valores. Usar storytelling do dossie.', 'mentorado', 'pendente', 'dossie_auto');
    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 2, 'Criar destaque Projetos/Clientes', 'Mostrar projetos reais, antes e depois, depoimentos visuais.', 'mentorado', 'pendente', 'dossie_auto');
    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 3, 'Criar destaque Servicos', 'Listar servicos oferecidos: projeto, acompanhamento, cronograma reverso.', 'mentorado', 'pendente', 'dossie_auto');
    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 4, 'Criar destaque Mentoria', 'Apresentar a mentoria Cronograma Reverso, para quem e, o que entrega.', 'mentorado', 'pendente', 'dossie_auto');
    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 5, 'Criar destaque Prova/Alunos', 'Depoimentos e resultados de mentorados (quando houver). Prova social.', 'mentorado', 'pendente', 'dossie_auto');
    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 6, 'Criar destaque Bastidores', 'Rotina do escritorio, visitas a obra, reunioes com clientes.', 'mentorado', 'pendente', 'dossie_auto');
    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 7, 'Criar destaque Lifestyle', 'Vida pessoal com equilibrio profissional. Humanizar a marca.', 'mentorado', 'pendente', 'dossie_auto');

  -- Acao 3.4
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 4, 'Selecionar e fixar 5 posts estrategicos',
    'Escolher 5 posts que comuniquem: autoridade em obra, metodo cronograma reverso, resultado com clientes, bastidores profissionais e posicionamento premium. Seguir checklist do dossie.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 3.5
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 5, 'Fazer auditoria do feed',
    'Revisar ultimos 9-12 posts. Verificar se comunicam posicionamento correto. Arquivar posts que contradizem o reposicionamento (ex: apenas estetica sem metodo).',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 3.6
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 6, 'Validar perfil otimizado com mentor',
    'Enviar print do perfil atualizado para feedback do mentor. Ajustar conforme orientacoes antes de iniciar captacao.',
    'mentor', 'pendente', 'dossie_auto');

-- =============================================================
-- FASE 4 - ORGANIZAR LISTA DE CONTATOS
-- =============================================================
INSERT INTO pa_fases (plano_id, numero, titulo, descricao, tipo, status, origem)
VALUES (
  _plano_id, 4,
  'Organizar Lista de Contatos',
  'Etapa 4 do funil. Mapear e classificar todos os contatos potenciais em planilha com prioridades (1-proximo, 2-medio, 3-frio). A origem do contato precisa existir ANTES da mensagem.',
  'fase',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _fase_id;

  -- Acao 4.1
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 1, 'Criar planilha de contatos com campos obrigatorios',
    'Montar planilha com colunas: Nome, Telefone, Instagram, Origem do contato, Prioridade (1/2/3), Status de convite, Observacoes. Formato Google Sheets ou similar.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 4.2
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 2, 'Listar contatos proximos (Prioridade 1)',
    'Arquitetos e designers da rede pessoal com quem ja tem relacionamento direto. Colegas de profissao, ex-colegas de faculdade, parceiros de obra.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 4.3
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 3, 'Listar contatos medios (Prioridade 2)',
    'Profissionais que conhecem de vista ou ja tiveram contato pontual. Seguidores que interagem frequentemente. Indicacoes de amigos em comum.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 4.4
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 4, 'Listar contatos frios (Prioridade 3)',
    'Profissionais identificados no Instagram que atuam em obra. Contatos de eventos, feiras ou grupos profissionais. Requer abordagem com apresentacao.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 4.5
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 5, 'Classificar e validar lista com no minimo 50 contatos',
    'Revisar lista completa, validar prioridades e garantir que cada contato tem uma origem real (regra de ouro: se nao existe origem clara, nao chamar ainda).',
    'mentorado', 'pendente', 'dossie_auto');

-- =============================================================
-- FASE 5 - CONVITE PARA BASE DE CONTATOS
-- =============================================================
INSERT INTO pa_fases (plano_id, numero, titulo, descricao, tipo, status, origem)
VALUES (
  _plano_id, 5,
  'Convite para Base de Contatos',
  'Etapa 5 do funil. Enviar convites personalizados via WhatsApp para a lista organizada. Scripts diferentes por nivel de proximidade. Tom natural, sem pitch.',
  'fase',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _fase_id;

  -- Acao 5.1
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 1, 'Adaptar scripts de convite por prioridade',
    'Personalizar os 3 modelos de mensagem do dossie: Opcao 1 (contato proximo/intimo), Opcao 2 (WhatsApp raiz, simples), Opcao 3 (menos amiga, mais colega). Para contatos frios, usar modelo B com apresentacao.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 5.2
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 2, 'Enviar convites para Prioridade 1 (proximos)',
    'Iniciar pelos contatos mais proximos. Enviar mensagem personalizada, aguardar resposta, adicionar ao grupo quem aceitar. Registrar status na planilha.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 5.3
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 3, 'Enviar convites para Prioridade 2 (medios)',
    'Seguir para contatos medios apos completar prioridade 1. Usar tom adequado ao nivel de proximidade. Registrar na planilha.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 5.4
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 4, 'Enviar convites para Prioridade 3 (frios)',
    'Abordar contatos frios com script de apresentacao: "Oi [Nome], aqui e a Anna/Paula da Kava Arquitetura (RJ/SP). Te chamei porque [ORIGEM REAL]..." Apenas se existir origem clara.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 5.5
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 5, 'Acompanhar respostas e adicionar aceites ao grupo',
    'Monitorar respostas diariamente. Adicionar ao grupo quem aceitar. Atualizar status na planilha (enviado/aceito/recusou/sem resposta).',
    'mentorado', 'pendente', 'dossie_auto');

-- =============================================================
-- FASE 6 - CONVITE PARA BASE DO INSTAGRAM
-- =============================================================
INSERT INTO pa_fases (plano_id, numero, titulo, descricao, tipo, status, origem)
VALUES (
  _plano_id, 6,
  'Convite para Base do Instagram',
  'Etapa 6-7 do funil. Criar conteudo organico no Instagram (Reels/Carrossel + Stories) para atrair arquitetos para o grupo. Posts no feed + sequencia de stories com narrativa estrategica.',
  'fase',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _fase_id;

  -- Acao 6.1
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 1, 'Criar post no feed (Reels ou Carrossel)',
    'Video ou carrossel contando a historia do cronograma reverso de forma natural. Reels 30-60s, Ana ou Paula falando direto para camera. Seguir estrutura de 8 blocos do dossie: gancho, regancho, contexto, mecanismo, transformacao, origem da ideia, convite, CTA.',
    'mentorado', 'pendente', 'dossie_auto')
  RETURNING id INTO _acao_id;

    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 1, 'Escrever roteiro do Reels/Carrossel', 'Adaptar copy sugerida no dossie com 8 blocos: gancho, regancho, contexto, mecanismo, transformacao, origem, convite, CTA. Tom natural, como se falasse com amigo.', 'mentorado', 'pendente', 'dossie_auto');
    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 2, 'Gravar e editar o conteudo', 'Gravar video direto para camera ou montar carrossel. Edicao limpa, sem excesso. Pode impulsionar para alcançar mais arquitetos da regiao.', 'mentorado', 'pendente', 'dossie_auto');
    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 3, 'Publicar e monitorar engajamento', 'Publicar no melhor horario. Responder comentarios e DMs. Direcionar interessados para o grupo.', 'mentorado', 'pendente', 'dossie_auto');

  -- Acao 6.2
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 2, 'Criar sequencia de Stories (2-3 rodadas)',
    'Produzir 3 sequencias de stories conforme dossie: Stories 1 (Preparacao/Interrupcao de padrao - 6 stories), Stories 2 (Storytelling/Mecanismo/Transformacao - 6 stories), Stories 3 (Convite Final - 7 stories com CTA).',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 6.3
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 3, 'Responder DMs e direcionar para o grupo',
    'Monitorar mensagens recebidas via Instagram. Responder com tom pessoal e profissional. Enviar link do grupo para interessados qualificados.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 6.4
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 4, 'Utilizar Agente de Conteudo para copys adicionais',
    'Solicitar orientacao no grupo da mentoria sobre como usar o Agente de Conteudo para estruturar narrativas alinhadas ao posicionamento premium. Adaptar respostas ao tom da KAVA.',
    'mentorado', 'pendente', 'dossie_auto');

-- =============================================================
-- FASE 7 - COMUNICACAO NO GRUPO (AQUECIMENTO)
-- =============================================================
INSERT INTO pa_fases (plano_id, numero, titulo, descricao, tipo, status, origem)
VALUES (
  _plano_id, 7,
  'Comunicacao no Grupo (Aquecimento Pre-Aula)',
  'Etapa 7 do funil. Executar sequencia de 9 mensagens no grupo de WhatsApp para preparar mentalmente, aumentar presenca ao vivo e criar autoridade antes do convite para mentoria.',
  'fase',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _fase_id;

  -- Acao 7.1
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 1, 'Enviar Mensagem 1 - Boas-vindas (logo apos entrada)',
    'Texto de boas-vindas com foto do escritorio/cronograma/as duas juntas. Apresentar objetivo do grupo, data/horario, o que sera compartilhado. Assinatura: Ana e Paula.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 7.2
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 2, 'Enviar Mensagem 2 - Faltam 5 dias (audio)',
    'Audio de 30-60s. Revisando material, ponto central e como a obra comeca. Estruturar de tras pra frente mudou tudo em prazo, controle e previsibilidade.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 7.3
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 3, 'Enviar Mensagem 3 - Faltam 3 dias',
    'Texto com foto (cronograma impresso ou na tela). Estrutura da aula: onde obra perde controle, sequencia correta de execucao, cronograma como referencia, por onde comecar.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 7.4
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 4, 'Enviar Mensagem 4 - E amanha',
    'Texto com data/horario. Pedir para separar bloco, caderno, exemplo de obra. Encontro nao ficara gravado. Troca ao vivo.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 7.5
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 5, 'Enviar Mensagem 5 - E hoje (manha, com link)',
    'Texto com link do Zoom, ID e senha. Sala abre 10 min antes. Gerar urgencia positiva.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 7.6
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 6, 'Enviar Mensagens 6-8 - Falta 1h / Ao Vivo / Ainda da tempo',
    'Mensagem 6: audio falta 1h com reenvio do link. Mensagem 7: texto curto "ESTAMOS AO VIVO". Mensagem 8: 15 min apos inicio, lembrete para quem nao entrou.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 7.7
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 7, 'Enviar Mensagem 9 - Pos-encontro',
    'Texto + foto da call com todos. Agradecer participacao. Apresentar mentoria como continuidade natural. Link para formulario de aplicacao. "Nao e para todo mundo, turma pequena".',
    'mentorado', 'pendente', 'dossie_auto');

-- =============================================================
-- FASE 8 - PREPARAR ROTEIRO DA AULA
-- =============================================================
INSERT INTO pa_fases (plano_id, numero, titulo, descricao, tipo, status, origem)
VALUES (
  _plano_id, 8,
  'Preparar Roteiro da Aula',
  'Etapa 8 do funil. Montar roteiro estrategico da aula com 3 blocos (Inicio, Meio, Fim) + Transicao para Oferta. Objetivo: consciencia, quebra de crencas, desejo e decisao consciente.',
  'fase',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _fase_id;

  -- Acao 8.1
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 1, 'Preparar bloco INICIO da aula',
    'Boas-vindas e apresentacao (quem sao, vivencia real), promessa do evento (o que vao entender), jornada da aula (cenario atual vs desejado), orientacoes (dividida em blocos, transparencia sobre convite final).',
    'mentorado', 'pendente', 'dossie_auto')
  RETURNING id INTO _acao_id;

    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 1, 'Montar script de apresentacao pessoal', 'Quem sao Anna e Paula, KAVA Arquitetura, projetam/acompanham/executam. Vivencia acumulada, nao curriculo. Frase-chave do dossie.', 'mentorado', 'pendente', 'dossie_auto');
    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 2, 'Definir promessa clara do evento', 'O que o arquiteto vai entender: por que obra desorganiza, onde nasce o caos, como o Cronograma Reverso muda prazo/negociacao/faturamento.', 'mentorado', 'pendente', 'dossie_auto');
    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 3, 'Estruturar jornada da aula (antes vs depois)', 'Do cenario atual (obra confusa, cliente pressionando) para o desejado (metodo claro, controle, obra como sistema).', 'mentorado', 'pendente', 'dossie_auto');

  -- Acao 8.2
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 2, 'Preparar bloco MEIO da aula',
    'Apresentacao do problema (obras caoticas com bons projetos), crencas limitantes (obra e imprevisivel, gestao nao e meu papel), o jeito errado (improvisar, acompanhar quando da), consequencias, solucao conceitual (Cronograma Reverso como tese), prova (exemplos reais), construcao de desejo, visualizacao futura.',
    'mentorado', 'pendente', 'dossie_auto')
  RETURNING id INTO _acao_id;

    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 1, 'Listar crencas limitantes a quebrar', '"Obra e imprevisivel mesmo", "E assim pra todo arquiteto", "Com mais experiencia melhora", "Gestao nao e meu papel". Preparar contra-argumentos.', 'mentorado', 'pendente', 'dossie_auto');
    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 2, 'Separar exemplos reais de obras (prova)', 'Selecionar 2-3 casos reais de antes e depois da implementacao do cronograma reverso. Decisoes evitadas, conflitos reduzidos.', 'mentorado', 'pendente', 'dossie_auto');
    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 3, 'Montar bloco de visualizacao futura', 'Cliente perguntando prazo e voce aponta criterio. Mudanca solicitada e impacto claro. Obra sem desespero. Arquiteto como condutor, nao bombeiro.', 'mentorado', 'pendente', 'dossie_auto');

  -- Acao 8.3
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 3, 'Preparar bloco TRANSICAO PARA OFERTA',
    'Apresentacao da mentoria (aula abre consciencia, obra exige acompanhamento), diferenciais (acompanhamento real, aplicacao em obras reais, nao e curso), urgencia (vagas limitadas, criterio de entrada), CTA (aplicacao e filtro, nao compromisso).',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 8.4
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 4, 'Preparar bloco FIM da aula',
    'Resumo final (problema claro, metodo existe, caminho existe). Encerramento maduro: responsabilidade profissional, escolha consciente, convite sem pressao. Tom final: "Obra nao precisa ser caos. Mas tambem nao muda sozinha."',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 8.5
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 5, 'Ensaiar e validar roteiro com mentor',
    'Fazer ensaio da aula completa. Cronometrar cada bloco. Enviar gravacao ou resumo para mentor validar estrutura e tom antes do evento.',
    'mentor', 'pendente', 'dossie_auto');

-- =============================================================
-- FASE 9 - SETUP DA APLICACAO DA MENTORIA
-- =============================================================
INSERT INTO pa_fases (plano_id, numero, titulo, descricao, tipo, status, origem)
VALUES (
  _plano_id, 9,
  'Setup da Aplicacao da Mentoria',
  'Etapa 9 do funil. Configurar infraestrutura tecnica (Zoom), criar formulario de aplicacao (pre-qualificacao, nao inscricao), preparar planilha de dados e alinhar equipe.',
  'fase',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _fase_id;

  -- Acao 9.1
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 1, 'Configurar Zoom para a aula',
    'Criar link, configurar sala (capacidade, audio, video, gravacao automatica, permissao de entrada). Testar com pelo menos 1 pessoa externa. Verificar plano da conta.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 9.2
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 2, 'Criar formulario de aplicacao da mentoria',
    'Formulario de pre-qualificacao (nao inscricao). 11 perguntas essenciais conforme dossie: nome, email, WhatsApp, cidade, atuacao, tipo de obra, acompanhamento, dificuldade, desgaste, meta 2026, modelo de investimento.',
    'mentorado', 'pendente', 'dossie_auto')
  RETURNING id INTO _acao_id;

    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 1, 'Montar formulario com 11 perguntas', 'Seguir modelo exato do dossie. Incluir texto de introducao e pagina de obrigado conforme templates fornecidos.', 'mentorado', 'pendente', 'dossie_auto');
    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 2, 'Configurar pagina de obrigado', 'Mensagem: "Aplicacao enviada com sucesso. Nossa equipe ira analisar e entraremos em contato por WhatsApp." Conforme modelo do dossie.', 'mentorado', 'pendente', 'dossie_auto');
    INSERT INTO pa_sub_acoes (acao_id, numero, titulo, descricao, responsavel, status, origem)
    VALUES (_acao_id, 3, 'Testar formulario completo', 'Preencher como teste, verificar recebimento de dados, pagina de obrigado e integracao com planilha.', 'mentorado', 'pendente', 'dossie_auto');

  -- Acao 9.3
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 3, 'Preparar planilha de aplicacoes recebidas',
    'Configurar planilha automatica para receber dados do formulario. Colunas para classificacao de prioridade (a vista vs parcelado) e status de abordagem.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 9.4
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 4, 'Alinhar equipe sobre abordagem pos-aula',
    'Definir criterios de prioridade, leitura do formulario, abordagem sem pressao. Garantir que toda comunicacao segue posicionamento premium.',
    'mentorado', 'pendente', 'dossie_auto');

-- =============================================================
-- FASE 10 - ABORDAGEM POS-AULA (QUEM FEZ APLICACAO)
-- =============================================================
INSERT INTO pa_fases (plano_id, numero, titulo, descricao, tipo, status, origem)
VALUES (
  _plano_id, 10,
  'Abordagem Pos-Aula - Quem Fez Aplicacao',
  'Etapa 10 do funil. Converter arquitetos que preencheram aplicacao em mentorados. Sequencia: mensagem de abertura, follow-ups, ligacoes, fechamento direto. Investimento R$20.000.',
  'fase',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _fase_id;

  -- Acao 10.1
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 1, 'Organizar lista por prioridade de contato',
    'Separar aplicacoes: 1o quem marcou a vista, 2o quem marcou parcelado. Regra de ouro: nunca ligar sem ler a aplicacao inteira, entender tipo de obra, dor central e momento profissional.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 10.2
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 2, 'Enviar mensagem de abertura (WhatsApp)',
    'Mensagem personalizada: "Oi [Nome]! Aqui e a [Ana/Paula] da Kava. A gente analisou sua aplicacao e seu perfil foi aprovado para a mentoria! Voce consegue falar agora?" Se respondeu: ligar. Se nao: follow-up.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 10.3
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 3, 'Executar sequencia de follow-up e ligacoes',
    'Follow-up 1 (6-8h depois), Ligacao direta, Pos ligacao sem atender, Ligacao no horario combinado (dia seguinte), Segunda ligacao do dia, Mensagem 4 (liberacao de vaga final). Seguir scripts do dossie.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 10.4
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 4, 'Executar ligacao de fechamento (script completo)',
    'Seguir script de 10 passos: abertura (autoridade tranquila), confirmacao de contexto (espelhamento), dor central (2-3 perguntas), autoridade Kava, recapitulacao estrategica, apresentacao objetiva da mentoria, checagem de desejo, investimento (R$20.000), fechamento direto, inversao de polaridade.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 10.5
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 5, 'Registrar resultado de cada abordagem',
    'Atualizar planilha com status final de cada lead: fechou, recusou, sem resposta, adiou. Manter historico de todas as interacoes.',
    'mentorado', 'pendente', 'dossie_auto');

-- =============================================================
-- FASE 11 - ABORDAGEM POS-AULA (QUEM NAO FEZ APLICACAO)
-- =============================================================
INSERT INTO pa_fases (plano_id, numero, titulo, descricao, tipo, status, origem)
VALUES (
  _plano_id, 11,
  'Abordagem Pos-Aula - Quem NAO Fez Aplicacao',
  'Etapa 11 do funil. Reativar arquitetos que assistiram a aula mas nao aplicaram. Nao e fechamento direto, e ativacao de intencao. Sequencia de follow-ups D+1 a D+5.',
  'fase',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _fase_id;

  -- Acao 11.1
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 1, 'Organizar lista de quem assistiu e nao aplicou',
    'Cruzar lista de presenca na aula com formularios recebidos. Priorizar: arquitetos atuando em obra, escritorios pequenos/medios, quem demonstrou engajamento (mensagem, reacao, presenca ao vivo).',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 11.2
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 2, 'Enviar abordagem inicial (WhatsApp)',
    'Mensagem personalizada: participou da aula, pela atuacao voce tem perfil para a mentoria, poucas vagas para implementacao do cronograma reverso. Faz sentido conversar? Nunca disparar sem organizar lista.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 11.3
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 3, 'Executar sequencia de follow-ups (D+1 a D+5)',
    'Follow-up 1 (D+1 texto), Follow-up 2 (D+1 audio 1min), Ligacao direta, Follow-up 3 (D+2 pos ligacao texto), Ligacao combinada (D+2), Follow-up 4 (D+3 audio 50s isolar objecao), Follow-up 5 (D+4 caso real + conexao), Follow-up 6 (D+5 audio escassez real + ultima chance).',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 11.4
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 4, 'Conduzir ligacao de qualificacao/fechamento',
    'Para quem respondeu com interesse: qualificar perfil e conduzir para fechamento usando script da etapa 10. Tom maduro, autoridade pratica, respeito ao timing.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 11.5
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 5, 'Registrar resultados e encerrar ciclo',
    'Atualizar planilha com status final. Nao pressionar, nao vender por texto, nao falar preco por mensagem, nao insistir apos encerramento.',
    'mentorado', 'pendente', 'dossie_auto');

-- =============================================================
-- FASE 12 - ONBOARDING E CONFIRMACAO DA TURMA (PASSO EXECUTIVO)
-- =============================================================
INSERT INTO pa_fases (plano_id, numero, titulo, descricao, tipo, status, origem)
VALUES (
  _plano_id, 12,
  'Onboarding e Confirmacao da Turma',
  'Etapa 12 do funil. Integrar novos mentorados com video de boas-vindas, acesso a plataforma, grupo de WhatsApp, datas dos encontros ao vivo e recomendacoes iniciais.',
  'passo_executivo',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _fase_id;

  -- Acao 12.1
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 1, 'Gravar video de boas-vindas para novos mentorados',
    'Video pessoal de Anna e Paula recebendo o mentorado, explicando proximos passos, reforçando compromisso e exclusividade da turma.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 12.2
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 2, 'Configurar acesso a plataforma de aulas',
    'Criar contas e enviar credenciais. Garantir que todos os modulos dos 5 pilares estao disponiveis conforme arquitetura do produto.',
    'equipe_spalla', 'pendente', 'dossie_auto');

  -- Acao 12.3
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 3, 'Criar grupo de WhatsApp da turma',
    'Grupo exclusivo para mentorados da turma. Diferente do grupo de captacao. Adicionar todos os confirmados.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 12.4
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 4, 'Enviar cronograma de encontros ao vivo e recomendacoes',
    'Compartilhar datas dos encontros ao vivo, recomendacoes para estudo inicial e expectativas para a primeira semana de mentoria.',
    'mentorado', 'pendente', 'dossie_auto');

-- =============================================================
-- FASE 13 - PRODUCAO DE CONTEUDO CONTINUA (PASSO EXECUTIVO)
-- =============================================================
INSERT INTO pa_fases (plano_id, numero, titulo, descricao, tipo, status, origem)
VALUES (
  _plano_id, 13,
  'Producao de Conteudo Continua',
  'Etapa 13 do funil. Manter producao de conteudo estrategico no Instagram apos lancamento. Reforcar posicionamento premium, cronograma reverso como metodo e autoridade em gestao de obra.',
  'passo_executivo',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _fase_id;

  -- Acao 13.1
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 1, 'Produzir conteudo: O erro que faz obras atrasarem',
    'Gancho: "Por que nossos projetos ficam prontos antes da data prevista e nao dao problema?" Mostrar fase crucial entre projeto e obra que maioria pula. Cronograma reverso como solucao.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 13.2
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 2, 'Produzir conteudo: Por que clientes ficam sem dinheiro na obra',
    'Gancho: "A verdadeira razao das brigas entre arquiteto e cliente (e como evitar)". Cronograma reverso + planilha financeira = previsibilidade para o cliente.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 13.3
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 3, 'Produzir conteudo: Depoimentos de clientes',
    'Gravar videos de clientes falando sobre experiencia com cronograma: seguranca, organizacao, saber o que acontece sem estar na obra. Prova social no feed.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 13.4
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 4, 'Produzir conteudo: Posicionamento beleza + eficiencia',
    'Gancho: "Nao entregamos so projetos bonitos, mas tambem sem dor de cabeca". Marca = beleza + organizacao + processo. Atrai cliente que valoriza os dois.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 13.5
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 5, 'Produzir conteudo: O que e o Cronograma Reverso',
    'Gancho: "Por que fazemos o cronograma de tras para frente?" Comecar pela data de entrega e voltar. Cliente define quando quer se mudar, voce diz o que e plausivel. Fica entre projeto executivo e obra.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 13.6
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 6, 'Produzir conteudo: Diferenca entre fazer projeto e acompanhar obra',
    'Gancho: "Por que arquitetos que fazem obra ganham 30% a mais (e nao tem estresse)?" Breakdown faturamento: 1/3 projeto, 1/3 acompanhamento, maior parte RT.',
    'mentorado', 'pendente', 'dossie_auto');

-- =============================================================
-- FASE 14 - AJUSTES ESTRATEGICOS E PROXIMA RODADA (PASSO EXECUTIVO)
-- =============================================================
INSERT INTO pa_fases (plano_id, numero, titulo, descricao, tipo, status, origem)
VALUES (
  _plano_id, 14,
  'Ajustes Estrategicos e Proxima Rodada',
  'Avaliar resultados do lancamento, consolidar aprendizados, ajustar estrategia e preparar proxima rodada de vendas. Analise de metricas e otimizacao do funil.',
  'passo_executivo',
  'nao_iniciado',
  'dossie_auto'
)
RETURNING id INTO _fase_id;

  -- Acao 14.1
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 1, 'Analisar metricas do lancamento',
    'Consolidar numeros: total de contatos abordados, taxa de aceite no grupo, presenca na aula, formularios recebidos, ligacoes realizadas, fechamentos, ticket medio, faturamento total.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 14.2
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 2, 'Identificar gargalos e pontos de melhoria',
    'Onde houve maior perda no funil? Qual etapa teve menor conversao? A comunicacao no grupo foi efetiva? O roteiro da aula gerou desejo suficiente?',
    'mentor', 'pendente', 'dossie_auto');

  -- Acao 14.3
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 3, 'Documentar aprendizados e boas praticas',
    'Registrar o que funcionou e o que precisa ajustar. Scripts que convertem melhor, horarios ideais, objecoes mais comuns, perfil que mais fecha.',
    'mentorado', 'pendente', 'dossie_auto');

  -- Acao 14.4
  INSERT INTO pa_acoes (fase_id, numero, titulo, descricao, responsavel, status, origem)
  VALUES (_fase_id, 4, 'Planejar proxima rodada de lancamento',
    'Com base nos aprendizados, definir data da proxima turma, ajustar scripts, otimizar funil e expandir base de contatos para proxima rodada.',
    'mentor', 'pendente', 'dossie_auto');

END $;
