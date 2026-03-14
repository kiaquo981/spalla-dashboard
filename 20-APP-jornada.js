'use strict';

function jornadaStore() {
  return {
    // --- State ---
    view: 'macro',        // 'macro' | 'journey'
    activePhase: 0,
    activeSection: 0,
    activeSupportPage: null,
    showMapOverlay: false,

    // --- Phases ---
    phases: [
      { id: 'onboarding', name: 'ONBOARDING', subtitle: 'Boas-vindas e acessos', month: 'Start', color: '#35301D', icon: '👋' },
      { id: 'concepcao', name: 'CONCEPÇÃO', subtitle: 'Decisões estratégicas', month: 'Mês 1', color: '#656A41', icon: '💡' },
      { id: 'validacao', name: 'VALIDAÇÃO', subtitle: 'Execução e primeiras vendas', month: 'Mês 2-3', color: '#7A8050', icon: '🚀' },
      { id: 'otimizacao', name: 'OTIMIZAÇÃO', subtitle: 'Ajustes com dados reais', month: 'Mês 4-7', color: '#8B9060', icon: '📊' },
      { id: 'escala', name: 'ESCALA', subtitle: 'Crescimento sustentável', month: 'Mês 8-12', color: '#C9A227', icon: '⭐' },
    ],

    // --- Phase sections ---
    phaseSections: {
      onboarding: [
        {
          id: 'acessos', title: 'Acessos', subtitle: 'Você recebe os acessos',
          type: 'cards',
          badge: 'Fase 0 • Onboarding',
          intro: 'Bem-vindo à Mentoria',
          introSub: 'Você está entrando. Aqui você recebe todos os acessos necessários.',
          cards: [
            { icon: '📄', title: 'Assinar Contrato', desc: 'Formalização da sua entrada na mentoria', color: '#35301D' },
            { icon: '👥', title: 'Acesso aos Grupos', desc: 'Será seu grupo de apoio durante toda a jornada', color: '#656A41' },
            { icon: '👤', title: 'Cadastro no Sistema', desc: 'Vamos te cadastrar para acompanhar do início ao fim', color: '#7A8050' },
          ]
        },
        {
          id: 'call-onboarding', title: 'Call de Onboarding', subtitle: 'Seu primeiro contato com o Time CASE para começar com clareza',
          type: 'list',
          badge: 'SEU PRIMEIRO ENCONTRO',
          intro: 'Call de Onboarding',
          cardTitle: 'Apresentação Completa',
          cardSub: 'Com o Time CASE',
          cardText: 'Nesta call, você vai conhecer a estrutura completa da mentoria, entender cada etapa do processo e como vamos te acompanhar ao longo dos 12 meses.',
          items: [
            { icon: '👥', text: 'Você conhece o Time CASE e entende quem vai te apoiar' },
            { icon: '🗺️', text: 'Explicamos passo a passo como funciona a jornada' },
            { icon: '📋', text: 'Levantamos informações para personalizar sua experiência' },
            { icon: '📅', text: 'Já deixamos agendada sua primeira call de estratégia' },
          ],
          highlight: 'Essa call é para você começar com clareza total, sem dúvidas sobre o caminho.',
          voiceParticipants: [
            { name: 'Time CASE', role: 'Equipe', speaking: true },
            { name: 'Você', role: 'Mentorado(a)', speaking: false },
          ]
        },
        {
          id: 'resumo', title: 'Resumo', subtitle: 'Resumo da Etapa de Onboarding',
          type: 'checklist',
          items: [
            { icon: '🔑', text: 'Recebimento dos acessos à plataforma e grupos' },
            { icon: '🎥', text: 'Participação na call de onboarding' },
            { icon: '📅', text: 'Agendamento da call de estratégia' },
            { icon: '📄', text: 'Recebimento do manual do mentorado com todas as informações sobre a entrega e os links necessários' },
            { icon: '📄', text: 'Assinatura do contrato (obrigatória para agendar a call de estratégia)' },
            { icon: '🔍', text: 'Realização da pesquisa de concorrentes' },
          ],
          footerMessage: 'Você está pronto para iniciar a concepção da sua estratégia e plano de ação junto com o Consultor e o time.'
        },
        {
          id: 'marco', title: 'Marco', subtitle: 'Clareza da Jornada',
          type: 'milestone',
          milestone: 'Clareza da Jornada',
          text: 'Você sabe exatamente o caminho que vai percorrer e está pronto para começar.',
          milestoneColor: '#35301D',
          button: 'Ir para Concepção'
        }
      ],
      concepcao: [
        {
          id: 'intro', title: 'Início', subtitle: 'Concepção de Estratégia',
          type: 'intro',
          badge: 'Etapa 1 • Mês 1',
          text: 'Nessa fase vamos desenhar seu plano de ação e entregar seu dossiê.'
        },
        {
          id: 'call-estrategica', title: 'Call de Estratégia', subtitle: 'É o momento que o Consultor vai discutir com você',
          type: 'list',
          badge: 'PRIMEIRO ENCONTRO',
          intro: 'É o momento que vamos juntos discutir com você, entender melhor o seu contexto, entender qual o seu nicho, definir os pilares do seu negócio.',
          items: [
            { icon: '🎯', text: 'Discutir sobre qual melhor produto' },
            { icon: '📦', text: 'Qual melhor formato de entrega' },
            { icon: '🔄', text: 'Qual melhor funil para validar essa oferta' },
            { icon: '🎤', text: 'Qual posicionamento e narrativa' },
          ],
          voiceParticipants: [
            { name: 'Consultor CASE', role: 'Estrategista', speaking: true },
            { name: 'Você', role: 'Mentorado(a)', speaking: false },
          ]
        },
        {
          id: 'apos-call', title: 'Dossiê', subtitle: 'Dossiê Estratégico com seu plano de ação personalizado',
          type: 'cards',
          badge: 'APÓS A CALL',
          intro: 'Após essa call, nosso time vai estruturar seu dossiê com as seguintes entregas:',
          cards: [
            { icon: '🎯', title: 'Oferta Desenhada', desc: 'Promessa, TESE, Formato e jornada, Ticket e sugestão de copy', color: '#656A41' },
            { icon: '📦', title: 'Arquitetura Macro de Produto', desc: 'Estrutura do produto, Jornada do cliente', color: '#7A8050' },
            { icon: '🗺️', title: 'Funil de Vendas Detalhado', desc: 'Etapas do funil, Pontos de conversão', color: '#8B9060' },
            { icon: '🎥', title: 'Aulas sobre Vendas', desc: 'Técnicas de venda, Processo comercial', color: '#656A41' },
            { icon: '💬', title: 'Scripts de Abordagens e Vendas', desc: 'Abordagens, Scripts de vendas', color: '#7A8050' },
          ],
          prazo: '1 a 2 semanas'
        },
        {
          id: 'apresentacao-dossie', title: 'Apresentação', subtitle: 'Você recebe seu dossiê estratégico personalizado',
          type: 'list',
          badge: 'SEGUNDO ENCONTRO',
          intro: 'Após o time trabalhar nos pilares estratégicos, você recebe seu Dossiê Estratégico 100% personalizado. E marcamos uma segunda call para apresentar cada detalhe.',
          items: [
            { icon: '📊', text: 'Apresentação completa do seu dossiê estratégico' },
            { icon: '📋', text: 'Explicação de cada pilar definido para você' },
            { icon: '❓', text: 'Espaço para tirar todas as suas dúvidas' },
            { icon: '🚀', text: 'Alinhamento dos próximos passos da validação' },
          ],
          highlight: 'Você não precisa anotar nada: O dossiê fica disponível para você consultar sempre que precisar.'
        },
        {
          id: 'marco', title: 'Marco', subtitle: 'Estratégia Definida',
          type: 'milestone',
          milestone: 'Estratégia definida e detalhada em um plano de ação prático',
          text: 'Após essa etapa, você vai ter clareza sobre o que vender (produto e oferta), para quem vender (posicionamento e público) e qual plano para vender (qual funil e qual técnica de venda).',
          footerMessage: 'Com essa direção, vamos partir para a execução.',
          milestoneColor: '#656A41'
        }
      ],
      validacao: [
        {
          id: 'intro', title: 'Início', subtitle: 'Validação',
          type: 'intro',
          badge: 'Etapa 2 • Mês 2-3',
          text: 'Com seu dossiê em mãos e plano de ação...',
          objective: 'Seu objetivo é fazer as primeiras vendas e os primeiros cases'
        },
        {
          id: 'objetivo', title: 'O que executar', subtitle: 'Para validar sua oferta',
          type: 'cards',
          badge: 'O QUE VOCÊ VAI EXECUTAR',
          intro: 'Para fazer as primeiras vendas, você vai executar:',
          cards: [
            { icon: '🎯', title: 'EXECUTAR O FUNIL', desc: 'Passo a passo no dossiê', color: '#7A8050', highlight: true },
            { icon: '👥', title: 'LAPIDAR SEU PERFIL', desc: 'Seguindo o direcionamento do dossiê', color: '#7A8050' },
            { icon: '🎥', title: 'INICIAR A LINHA EDITORIAL', desc: 'Usar os agentes para isso', color: '#7A8050' },
            { icon: '📖', title: 'ESTUDAR TÉCNICA DE VENDA', desc: 'Trilhas e scripts prontos', color: '#656A41' },
            { icon: '🛒', title: 'FAZER AS PRIMEIRAS VENDAS', desc: 'Aplicar o processo aprendido', color: '#656A41', highlight: true },
          ]
        },
        {
          id: 'apoio', title: 'Apoio', subtitle: 'O que você recebe para te apoiar durante a execução',
          type: 'support_list',
          supportColor: '#7A8050',
          items: [
            { icon: '👥', text: 'Grupo Individual — Com Consultor e time de líderes' },
            { icon: '🎥', text: 'Conselho Semanal — Em grupo de até 15 pessoas com Consultor' },
            { icon: '🤖', text: 'Ferramentas de IA — Roteiros, copys, scripts de vendas e abordagens' },
            { icon: '🎓', text: 'Trilhas Gravadas — Plataforma e aplicativo próprio' },
            { icon: '🔧', text: 'Oficinas de Implementação — Encontros práticos mensais' },
            { icon: '💬', text: 'Feedback do Time — Acompanhamento no dia a dia' },
            { icon: '⚡', text: 'Calls com o Time — Para dúvidas de execução' },
            { icon: '❤️', text: 'Comunidade — Troca com outros mentorados' },
          ]
        },
        {
          id: 'habilidades', title: 'Habilidades', subtitle: 'Foco desta fase',
          type: 'cards',
          cards: [
            { icon: '💰', title: 'Habilidade de Vendas', desc: 'Você terá acesso ao nosso processo comercial e às técnicas de vendas, com tudo detalhado para que não fique inseguro nem perdido ao realizar suas primeiras vendas.', color: '#656A41', highlight: true },
            { icon: '📱', title: 'Habilidade de Conteúdo', desc: 'Nessa fase, você ainda não vai dominar, mas já vai começar a pensar em conteúdo e aprender nosso processo de produção. Além disso, terá todas as ferramentas e feedbacks necessários para ajudá-lo na curva de aprendizado.', color: '#7A8050' },
          ]
        },
        {
          id: 'marco', title: 'Marco', subtitle: 'Primeiras Vendas',
          type: 'milestone',
          milestone: 'Primeiras Vendas',
          milestoneSubtitle: 'Sua jornada até aqui',
          button: 'Avançar para Otimização'
        }
      ],
      otimizacao: [
        {
          id: 'intro', title: 'Início', subtitle: 'Otimização',
          type: 'intro',
          badge: 'Etapa 3 • Mês 4-7',
          text: 'Agora é hora de ganhar musculatura para gerar demanda e vender com consistência'
        },
        {
          id: 'objetivos', title: 'Objetivos', subtitle: 'Vendas com Consistência',
          type: 'cards',
          objective: 'Vendas com Consistência',
          objectiveSub: 'Sair do "vendeu uma vez" para um processo que funciona todo mês',
          cards: [
            { icon: '🔄', title: 'Otimizar funil existente', desc: 'Melhorar conversão', step: 1 },
            { icon: '🎥', title: 'Masterizar conteúdo', desc: 'Conteúdo que converte', step: 2 },
            { icon: '🔧', title: 'Otimizar entrega', desc: 'Experiência refinada', step: 3 },
            { icon: '💬', title: 'Dominar vendas', desc: 'Processo comercial afiado', step: 4, highlight: true },
          ]
        },
        {
          id: 'analise', title: 'Call de Análise', subtitle: 'Call de Análise com Estrategista',
          type: 'list',
          badgeHighlight: 'AQUI É UM MOMENTO DE UMA NOVA CALL DE ESTRATÉGIA',
          badge: 'ANÁLISE CONJUNTA',
          intro: 'Essa call pode ser com o Consultor ou algum dos estrategistas, vai depender do tipo de funil e caso em particular',
          cards: [
            { icon: '📊', title: 'O que funcionou', desc: 'Estratégias que geraram resultado' },
            { icon: '🎯', title: 'Onde estão os gargalos', desc: 'Pontos de fricção a melhorar' },
            { icon: '📈', title: 'O que escalar', desc: 'Ações para mais investimento' },
          ],
          voiceParticipants: [
            { name: 'Estrategista CASE', role: 'Estrategista', speaking: true },
            { name: 'Você', role: 'Mentorado', speaking: false },
          ]
        },
        {
          id: 'apoio', title: 'Apoio', subtitle: 'O que você recebe para te apoiar durante a execução',
          type: 'support_list',
          supportColor: '#8B9060',
          items: [
            { icon: '👥', text: 'Grupo Individual — Com Consultor e time de líderes' },
            { icon: '🎥', text: 'Conselho Semanal — Em grupo de até 15 pessoas com Consultor' },
            { icon: '🤖', text: 'Ferramentas de IA — Roteiros, copys, scripts de vendas e abordagens' },
            { icon: '🎓', text: 'Trilhas Gravadas — Plataforma e aplicativo próprio' },
            { icon: '🔧', text: 'Oficinas de Implementação — Encontros práticos mensais' },
            { icon: '💬', text: 'Feedback do Time — Acompanhamento no dia a dia' },
            { icon: '⚡', text: 'Calls com o Time — Para dúvidas de execução' },
            { icon: '❤️', text: 'Comunidade — Troca com outros mentorados' },
          ]
        },
        {
          id: 'habilidades', title: 'Habilidades', subtitle: 'Foco desta fase',
          type: 'cards',
          cards: [
            { icon: '💰', title: 'Domínio do Processo de Vendas', desc: 'Ao final desta fase, você terá domínio completo do processo comercial e estará apto a delegar a venda, caso deseje.', color: '#656A41', highlight: true },
            { icon: '📱', title: 'Conteúdo e Geração de Leads', desc: 'Você se tornará excelente na produção de conteúdo e aprenderá a gerar leads de forma consistente, seja por meio de conteúdos orgânicos ou de anúncios bem estruturados.', color: '#8B9060' },
          ]
        },
        {
          id: 'marco', title: 'Marco', subtitle: 'Vendas com Consistência',
          type: 'milestone',
          milestone: 'Vendas com Consistência',
          text: 'Você está vendendo com consistência. Pronto para escalar.',
          milestoneColor: '#8B9060',
          button: 'Avançar para Escala'
        }
      ],
      escala: [
        {
          id: 'intro', title: 'Início', subtitle: 'ESCALA',
          type: 'intro',
          badge: 'Etapa 4 • Mês 8-12',
          text: 'Crescimento com previsibilidade.'
        },
        {
          id: 'objetivos', title: 'Objetivos', subtitle: 'O que você vai conquistar',
          type: 'cards',
          badge: 'OBJETIVOS DESSA FASE',
          intro: 'Você validou, otimizou. Agora escala com estrutura.',
          cards: [
            { icon: '📚', title: 'Manter os funis funcionando', desc: 'Consistência nas vendas' },
            { icon: '💰', title: 'Aumentar investimento em tráfego', desc: 'Escalar mídia paga', highlight: true },
            { icon: '👤', title: 'Estruturar time', desc: 'Contratar e delegar', highlight: true },
            { icon: '📚', title: 'Fazer mais funis', desc: 'Novos canais de venda' },
            { icon: '📄', title: 'Colocar mais produtos', desc: 'Expandir oferta' },
            { icon: '📈', title: 'Maestria em conteúdo', desc: 'Conteúdo de alta conversão', highlight: true },
          ]
        },
        {
          id: 'call-estrategia', title: 'Plano de Escala', subtitle: 'Call Estratégica para Plano de Escala',
          type: 'list',
          intro: 'Quando você tiver neste momento, vai ter uma call com o Consultor para definir sua execução nesta fase',
          cards: [
            { icon: '👤', title: 'Quem contratar', desc: 'Definir estrutura de time' },
            { icon: '📈', title: 'Plano de metas', desc: 'Objetivos e KPIs claros' },
            { icon: '📅', title: 'Iniciativas do ano', desc: 'Projetos prioritários' },
          ],
          voiceParticipants: [
            { name: 'Consultor CASE', role: 'Estrategista', speaking: true },
            { name: 'Você', role: 'Mentorado(a)', speaking: false },
          ]
        },
        {
          id: 'apoio', title: 'Apoio', subtitle: 'O que você recebe para te apoiar durante a execução',
          type: 'support_list',
          supportColor: '#C9A227',
          items: [
            { icon: '👥', text: 'Grupo Individual — Com Consultor e time de líderes' },
            { icon: '🎥', text: 'Conselho Semanal — Em grupo de até 15 pessoas com Consultor' },
            { icon: '🤖', text: 'Ferramentas de IA — Roteiros, copys, scripts de vendas e abordagens' },
            { icon: '🎓', text: 'Trilhas Gravadas — Plataforma e aplicativo próprio' },
            { icon: '🔧', text: 'Oficinas de Implementação — Encontros práticos mensais' },
            { icon: '💬', text: 'Feedback do Time — Acompanhamento no dia a dia' },
            { icon: '⚡', text: 'Calls com o Time — Para dúvidas de execução' },
            { icon: '❤️', text: 'Comunidade — Troca com outros mentorados' },
          ]
        },
        {
          id: 'marco', title: 'Marco', subtitle: 'Negócio Estruturado',
          type: 'milestone',
          milestone: 'Negócio Estruturado',
          text: 'Vendas consistentes, alta margem de lucro, receita previsível e processos claros.',
          badgeFinal: 'Jornada Completa!',
          journeyComplete: true
        }
      ]
    },

    // --- Support pages ---
    supportPages: [
      {
        id: 'estrategista', icon: '👥', label: 'Estrategista',
        title: 'Sua Estrategista',
        content: {
          name: 'QUEILA TRIZOTTI',
          role: 'Estrategista-Chefe da CASE',
          photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Queilatrizotti.jpg',
          whatSheDoes: [
            'Define sua oferta junto com você',
            'Estrutura seu produto',
            'Escolhe seu funil de vendas',
            'Cria seu documento estratégico',
            'Lidera os encontros semanais',
            'Direciona sua jornada de ponta a ponta',
          ],
          whenSheJoins: [
            { moment: 'Logo no início', action: 'Sessão estratégica completa' },
            { moment: 'Toda semana', action: 'Encontros ao vivo' },
            { moment: 'Após validação', action: 'Entrega do segundo documento estratégico' },
            { moment: 'Durante toda jornada', action: 'Direcionamento e alinhamento' },
          ],
          whatChanges: [
            'Você não precisa descobrir sozinho o que vende',
            'Você tem alguém experiente definindo sua estratégia',
            'Suas dúvidas estratégicas são respondidas por quem entende',
            'Você tem direção, não fica perdido',
          ],
          quote: 'Eu vou junto com você definir cada decisão estratégica. Você não vai chutar — vai decidir com base.',
          quoteAuthor: 'Queila Trizotti',
        }
      },
      {
        id: 'equipe', icon: '💬', label: 'Equipe',
        title: 'Equipe CASE',
        content: {
          estrategistas: [
            {
              name: 'Queila Trizotti', role: 'Estrategista',
              photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Queilatrizotti.jpg',
              highlight: 'R$ 55M+ gerados no digital',
              credentials: '7 anos comandando operações de alto ticket • Criadora do método CASE • Expert em narrativas, posicionamento e arquitetura de ofertas premium',
              function: 'Conduz as decisões estratégicas mais profundas do seu negócio na Call de Download e nos conselhos semanais',
            },
            {
              name: 'Hugo Nicchio', role: 'Estrategista',
              photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Hugo%20Nicchio.jpg',
              highlight: 'R$ 300M+ gerados no digital',
              credentials: 'Lidera equipe de +80 pessoas • ROI consistente de 10x a 40x • Fundador da Vita Science, Mentoria CASE e Digital Business School',
              function: 'Co-conduz os conselhos semanais e garante suporte estratégico contínuo em todas as fases',
            },
            {
              name: 'Kaique', role: 'Especialista em Funis',
              photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Kaique.jpg',
              highlight: 'Expert em IA e Performance',
              credentials: 'Lançamentos de 7 dígitos executados • Experiência em tráfego pago e otimização de funis • Especialista em IA aplicada a performance e conversão',
              function: 'Realiza calls de destrave em funil, conversão e tráfego quando você travar',
            },
            {
              name: 'Mariza Ribeiro', role: 'Especialista em Copy',
              photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Mariza%20Ribeiro.jpg',
              highlight: '+5 anos no time',
              credentials: 'Responsável por múltiplos lançamentos de 7 dígitos • Expert em copy orientada a prova social, clareza e vendas',
              function: 'Transforma toda estratégia da Call de Download em dossiês executáveis e planos de copy prontos para rodar',
            },
            {
              name: 'Victor Rubens', role: 'Especialista em Campanhas',
              photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Victor%20Rubens.jpg',
              highlight: '+R$ 30M em campanhas',
              credentials: '+5 anos criando campanhas • Expert em vídeos, anúncios e criações de campanhas de alta conversão',
              function: 'Dá feedbacks pontuais sobre campanhas e direção de vídeos',
            },
          ],
          lideres: [
            {
              name: 'Heitor', role: 'Líder Consultivo',
              photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Heitor.jpg',
              highlight: 'Seu parceiro de execução',
              credentials: 'Trabalha diretamente com Hugo • Participou de lançamentos de 7 dígitos • Expert em desenvolvimento de produtos digitais e arquitetura de ofertas',
              function: 'Está com você no WhatsApp para dúvidas, feedbacks diretos e calls de destrave. Cobra a execução, acompanha seu progresso e garante que você execute rápido',
            },
            {
              name: 'Lara', role: 'Líder Consultiva',
              photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Lara%20Santos.jpg',
              highlight: 'Sua parceira de execução',
              credentials: '+4 anos no time • Treinada diretamente com a Estrategista • Especialista em CS, operação de atendimento e jornada do cliente',
              function: 'Está com você no WhatsApp para dúvidas, feedbacks diretos e calls de destrave. Cobra a execução, acompanha seu progresso e garante que você execute rápido',
            },
          ]
        }
      },
      {
        id: 'agentes', icon: '🤖', label: 'Agentes IA',
        title: 'Agentes de Inteligência Artificial',
        content: {
          agents: [
            {
              name: 'AGENTE DE EXTRAÇÃO EDITORIAL',
              whatIs: 'Uma inteligência artificial que captura quem você é — sua essência, sua voz, seu jeito de falar.',
              howItWorks: [
                'Você alimenta com seu documento estratégico',
                'Você responde perguntas sobre você, sua história, seu estilo',
                'O agente absorve tudo e cria seu \'DNA editorial\'',
                'Tudo que você cria depois sai alinhado com você',
              ],
              whenToUse: [
                'Logo no início da execução',
                'Antes de criar qualquer conteúdo',
                'Quando sentir que o conteúdo está genérico',
              ],
              whatItHelps: [
                'Você não cria conteúdo sem personalidade',
                'Tudo que sai é você, não uma versão genérica',
                'Sua comunicação fica coerente',
              ],
            },
            {
              name: 'AGENTE DE CONTEÚDO',
              whatIs: 'Uma inteligência artificial que gera ideias de conteúdo alinhadas com sua oferta.',
              howItWorks: [
                'Você fala sobre o que quer comunicar',
                'Você define o objetivo (atrair, engajar, vender)',
                'O agente gera ideias específicas para você',
                'Você escolhe as que fazem sentido',
              ],
              whenToUse: [
                'Toda semana, para planejar conteúdo',
                'Quando não sabe o que postar',
                'Quando quer ideias para uma campanha',
              ],
              whatItHelps: [
                'Você não fica olhando pra tela sem saber o que fazer',
                'Suas ideias são alinhadas com seu objetivo',
                'Você tem um banco de ideias sempre disponível',
              ],
            },
            {
              name: 'AGENTE DE ROTEIROS',
              whatIs: 'Uma inteligência artificial que transforma suas ideias em roteiros prontos.',
              howItWorks: [
                'Você escolhe uma ideia (do Agente de Conteúdo ou sua)',
                'Você define o formato (vídeo, carrossel, stories, post)',
                'O agente cria o roteiro completo',
                'Você ajusta se quiser e produz',
              ],
              whenToUse: [
                'Depois de escolher a ideia',
                'Antes de sentar pra produzir',
                'Quando não sabe como estruturar',
              ],
              whatItHelps: [
                'Você não fica horas pensando como começar',
                'Seu conteúdo tem estrutura que funciona',
                'Você produz mais rápido',
              ],
            },
            {
              name: 'AGENTE DE FUNIL DE VENDAS',
              whatIs: 'Uma inteligência artificial específica para o seu funil de vendas.',
              howItWorks: [
                'O agente conhece o funil que foi escolhido pra você',
                'Ele te guia em cada etapa da execução',
                'Ele sugere abordagens, mensagens, ações',
                'Ele te ajuda a converter',
              ],
              whenToUse: [
                'Durante toda a execução do funil',
                'Quando não sabe qual próximo passo',
                'Quando quer otimizar alguma etapa',
              ],
              whatItHelps: [
                'Você tem um guia específico pro seu caminho',
                'Você não precisa decorar o manual',
                'Você tem suporte na hora de vender',
              ],
            },
            {
              name: 'AGENTE REVISOR DE ARQUITETURA',
              whatIs: 'Uma inteligência artificial que te ajuda a estruturar seu produto.',
              howItWorks: [
                'Você conversa sobre o que quer ensinar',
                'O agente faz perguntas para entender a jornada do seu aluno',
                'Juntos, vocês definem módulos, aulas, materiais',
                'Você sai com a arquitetura completa',
              ],
              whenToUse: [
                'Após receber o documento estratégico',
                'Quando for estruturar seu produto',
                'Quando quiser reorganizar algo',
              ],
              whatItHelps: [
                'Você não cria produto desorganizado',
                'Seu aluno tem uma jornada que faz sentido',
                'Você pensa em tudo que precisa ter',
              ],
            },
            {
              name: 'AGENTE DE ROTEIRO DE AULAS',
              whatIs: 'Uma inteligência artificial que roteiriza suas aulas.',
              howItWorks: [
                'Você define o tema da aula',
                'O agente estrutura o roteiro completo',
                'Introdução, desenvolvimento, conclusão, exercícios',
                'Você ajusta e grava',
              ],
              whenToUse: [
                'Depois de definir os módulos',
                'Quando for gravar cada aula',
                'Quando quiser melhorar uma aula existente',
              ],
              whatItHelps: [
                'Suas aulas tem estrutura didática',
                'Você não fica perdido na frente da câmera',
                'Você grava mais rápido',
              ],
            },
            {
              name: 'AGENTE DE LAPIDAÇÃO DE PERFIL',
              whatIs: 'Uma inteligência artificial que analisa e direciona ajustes no seu perfil.',
              howItWorks: [
                'O agente analisa seu perfil atual',
                'Ele identifica o que está alinhado e o que não está',
                'Ele gera sugestões de bio, destaques, posts fixados',
                'Ele cria roteiros do que produzir',
              ],
              whenToUse: [
                'Logo no início da jornada',
                'Quando quiser reposicionar seu perfil',
                'Quando sentir que o perfil não comunica direito',
              ],
              whatItHelps: [
                'Você sabe exatamente o que ajustar',
                'Você tem roteiros prontos, só produzir',
                'Seu perfil comunica quem você é e o que faz',
              ],
            },
            {
              name: 'SEU AGENTE PERSONALIZADO',
              whatIs: 'Uma inteligência artificial criada especificamente para você, com seu contexto, sua voz, seu estilo.',
              howItWorks: [
                'Na sessão hands-on, nós criamos juntos',
                'Alimentamos com tudo sobre você',
                'Configuramos para seu jeito de trabalhar',
                'Ele vira seu assistente pessoal',
              ],
              whenToUse: [
                'Para tudo',
                'É seu parceiro de trabalho',
                'Disponível sempre que precisar',
              ],
              whatItHelps: [
                'Você tem um agente que te conhece',
                'Não precisa explicar tudo de novo toda vez',
                'É como ter um assistente que sabe sua história',
              ],
            },
          ]
        }
      },
      {
        id: 'manuais', icon: '📄', label: 'Manuais',
        title: 'Manuais e Documentos',
        content: {
          docs: [
            {
              title: 'MANUAL DO SEU FUNIL',
              whatIs: 'O passo a passo completo do funil que foi escolhido pra você.',
              whatInside: ['Visão geral do funil', 'Cada etapa explicada', 'O que fazer em cada momento', 'Scripts e modelos de mensagem', 'Checklist de execução', 'Métricas para acompanhar'],
              whenToUse: 'Durante toda a execução. É seu guia de referência. Volte sempre que tiver dúvida.',
            },
            {
              title: 'DOCUMENTO ESTRATÉGICO - FASE 1',
              whatIs: 'Sua estratégia completa documentada.',
              whatInside: ['Sua oferta posicionada', 'Sua narrativa e storytelling', 'Arquitetura do produto (Ponto A ao Ponto B)', 'Funil escolhido e por quê', 'Guia de lapidação de perfil', 'Plano de ação inicial'],
              whenToUse: 'É sua bíblia estratégica. Base para todas as decisões. Referência para os agentes.',
            },
            {
              title: 'DOCUMENTO ESTRATÉGICO - FASE 2',
              whatIs: 'Seu redirecionamento após validação.',
              whatInside: ['Análise do que funcionou', 'Plano de conteúdo otimizado', 'Ajustes no funil', 'Configuração refinada dos agentes', 'Próximos passos'],
              whenToUse: 'Após validar a oferta. Para otimizar o que funciona. Base para escala.',
            },
            {
              title: 'CHECKLIST DE EXECUÇÃO',
              whatIs: 'Lista prática do que fazer em cada momento.',
              whatInside: ['Tarefas da concepção', 'Tarefas da validação', 'Tarefas da otimização', 'Tarefas da escala', 'Marcadores de progresso'],
              whenToUse: 'Todo dia, para saber o que fazer. É seu mapa de execução. Marque conforme avança.',
            },
          ]
        }
      },
      {
        id: 'encontros', icon: '🎥', label: 'Encontros',
        title: 'Encontros Semanais',
        content: {
          frequency: 'Toda terça-feira',
          format: 'Ao vivo, online',
          with: 'Queila, estrategista-chefe',
          duration: 'Aproximadamente 1 hora',
          recording: 'Disponível em 24h',
          whatHappens: [
            'Queila traz um tema relevante',
            'Você pode trazer dúvidas',
            'Análise de casos reais',
            'Direcionamento prático',
            'Espaço para perguntas',
          ],
          topics: [
            'Posicionamento e oferta',
            'Conteúdo que converte',
            'Técnicas de vendas',
            'Utilização dos agentes',
            'Análise de perfis',
            'Otimização de funil',
            'Mindset e bloqueios',
          ],
          whyImportant: [
            'Você não fica sozinho na jornada',
            'Suas dúvidas são respondidas ao vivo',
            'Você aprende com casos de outros mentorados',
            'Você tem direção toda semana',
          ],
          details: {
            duracao: '~1 hora',
            formato: 'Ao vivo',
            gravacao: 'Em 24h',
            material: 'Quando relevante',
          }
        }
      },
      {
        id: 'plataforma', icon: '🎓', label: 'Plataforma',
        title: 'Áreas da Plataforma',
        content: {
          url: 'plataforma.casementoria.com',
          areas: [
            {
              id: 'aulas', title: 'ÁREA DE AULAS',
              items: ['Aulas de fundamentos (oferta, produto, funil, mindset)', 'Aulas do seu funil específico', 'Aulas de conteúdo', 'Aulas de copy', 'Aulas de comercial', 'Aulas de utilização dos agentes'],
            },
            {
              id: 'materiais', title: 'ÁREA DE MATERIAIS',
              items: ['Templates', 'Modelos', 'Scripts', 'Checklists'],
            },
            {
              id: 'gravacoes', title: 'ÁREA DE GRAVAÇÕES',
              items: ['Todos os encontros gravados', 'Sessões especiais', 'Workshops'],
            },
            {
              id: 'agentes', title: 'ÁREA DE AGENTES',
              items: ['Acesso aos agentes de IA', 'Tutoriais de uso', 'Social Case Hub'],
            },
          ],
          sidebar: ['Dashboard', 'Aulas', 'Materiais', 'Agentes', 'Gravações'],
          courses: [
            { name: 'Fundamentos', lessons: 12 },
            { name: 'Seu Funil', lessons: 12 },
            { name: 'Comercial', lessons: 12 },
          ],
          howToUse: [
            'Acesse quando precisar aprender algo',
            'Volte para revisar conceitos',
            'Use como referência',
            'Acompanhe seu progresso',
          ],
          note: 'Conteúdo organizado por etapa da jornada. Você sabe o que assistir em cada momento. Não precisa assistir tudo — só o que faz sentido pro seu momento.',
        }
      },
      {
        id: 'comunidade', icon: '❤️', label: 'Comunidade',
        title: 'Comunidade CASE',
        content: {
          where: [
            { icon: '💬', title: 'Grupo WhatsApp', desc: 'Com a equipe e mentorados' },
            { icon: '👥', title: 'Encontros semanais', desc: 'Ao vivo toda terça' },
            { icon: '✨', title: 'Eventos especiais', desc: 'Workshops e sessões extras' },
          ],
          whatYouGet: [
            'Troca com pessoas no mesmo momento',
            'Ver que outras pessoas passam pelo mesmo',
            'Aprender com erros e acertos dos outros',
            'Networking real',
            'Motivação de ver outros avançando',
          ],
          howItWorks: [
            'Dúvidas respondidas pela equipe',
            'Troca entre mentorados',
            'Celebração de conquistas',
            'Compartilhamento de aprendizados',
          ],
          whatItIsNot: [
            'Não é um grupo genérico de networking',
            'Não é espaço para vender',
            'Não é foco em quantidade de pessoas',
          ],
          philosophy: 'É uma comunidade focada em execução e resultados.',
          whyItMatters: [
            'A jornada de empreender é solitária',
            'Ter pessoas junto muda tudo',
            'Você não está sozinho nos desafios',
            'Você celebra junto as conquistas',
          ],
        }
      }
    ],

    // --- Computed ---
    get currentPhase() { return this.phases[this.activePhase]; },
    get currentSections() { return this.phaseSections[this.currentPhase.id] || []; },
    get currentSection() { return this.currentSections[this.activeSection] || null; },
    get totalSections() { return this.currentSections.length; },
    get progressPct() { return this.totalSections > 0 ? ((this.activeSection + 1) / this.totalSections) * 100 : 0; },

    // --- Methods ---
    enterJourney(index) {
      this.activePhase = index;
      this.activeSection = 0;
      this.view = 'journey';
    },
    backToMacro() {
      this.view = 'macro';
    },
    goToPhase(index) {
      this.activePhase = Math.max(0, Math.min(index, this.phases.length - 1));
      this.activeSection = 0;
    },
    nextPhase() {
      if (this.activePhase < this.phases.length - 1) {
        this.activePhase++;
        this.activeSection = 0;
      }
    },
    prevPhase() {
      if (this.activePhase > 0) {
        this.activePhase--;
        this.activeSection = 0;
      }
    },
    nextSection() {
      if (this.activeSection < this.totalSections - 1) {
        this.activeSection++;
      } else if (this.activePhase < this.phases.length - 1) {
        this.nextPhase();
      }
    },
    prevSection() {
      if (this.activeSection > 0) {
        this.activeSection--;
      } else if (this.activePhase > 0) {
        this.activePhase--;
        this.activeSection = this.currentSections.length - 1;
      }
    },
    openSupportPage(id) { this.activeSupportPage = id; },
    closeSupportPage() { this.activeSupportPage = null; },
    getSupportPage(id) { return this.supportPages.find(function(p) { return p.id === id; }); },
  };
}
