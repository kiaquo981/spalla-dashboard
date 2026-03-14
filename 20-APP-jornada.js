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
      { id: 'onboarding', name: 'ONBOARDING', subtitle: 'Boas-vindas e acessos', month: 'Start', color: '#35301D', icon: '\u{1F44B}' },
      { id: 'concepcao', name: 'CONCEPÇÃO', subtitle: 'Decisões estratégicas', month: 'Mês 1', color: '#656A41', icon: '\u{1F4A1}' },
      { id: 'validacao', name: 'VALIDAÇÃO', subtitle: 'Execução e primeiras vendas', month: 'Mês 2-3', color: '#7A8050', icon: '\u{1F680}' },
      { id: 'otimizacao', name: 'OTIMIZAÇÃO', subtitle: 'Ajustes com dados reais', month: 'Mês 4-7', color: '#8B9060', icon: '\u{1F4CA}' },
      { id: 'escala', name: 'ESCALA', subtitle: 'Crescimento sustentável', month: 'Mês 8-12', color: '#C9A227', icon: '\u{2B50}' },
    ],

    // --- Phase sections ---
    phaseSections: {
      onboarding: [
        {
          id: 'acessos', title: 'Acessos', subtitle: 'Bem-vindo ao CASE',
          type: 'cards',
          intro: 'Seus primeiros passos na mentoria. Aqui você recebe todos os acessos necessários para começar.',
          cards: [
            { icon: '\u{1F4DD}', title: 'Contrato Digital', desc: 'Assinatura do contrato de mentoria com todos os termos e condições.' },
            { icon: '\u{1F4AC}', title: 'Grupos WhatsApp', desc: 'Acesso ao grupo exclusivo de mentorados e canal de suporte direto.' },
            { icon: '\u{1F464}', title: 'Cadastro na Plataforma', desc: 'Criação do perfil no dashboard com dados pessoais e do negócio.' },
          ]
        },
        {
          id: 'call_onboarding', title: 'Call de Onboarding', subtitle: 'Primeira reunião com a equipe',
          type: 'list',
          intro: 'Reunião de boas-vindas com a equipe CASE para alinhar expectativas e planejar os próximos passos.',
          items: [
            { icon: '\u{1F4C5}', text: 'Agendamento da call dentro de 48h após o contrato' },
            { icon: '\u{1F465}', text: 'Apresentação da equipe e dos canais de suporte' },
            { icon: '\u{1F3AF}', text: 'Levantamento inicial de objetivos e situação atual' },
            { icon: '\u{1F4CB}', text: 'Definição do cronograma personalizado' },
          ]
        },
        {
          id: 'resumo_ob', title: 'Resumo do Onboarding', subtitle: 'O que você recebe',
          type: 'checklist',
          items: [
            'Acesso ao grupo exclusivo de WhatsApp',
            'Login na plataforma Spalla',
            'Cronograma personalizado da jornada',
            'Contato direto do estrategista designado',
            'Guia de primeiros passos (PDF)',
            'Agenda dos encontros semanais',
          ]
        },
        {
          id: 'marco_ob', title: 'Marco', subtitle: 'Clareza da Jornada',
          type: 'milestone',
          text: 'Ao final do onboarding, você terá clareza total sobre sua jornada na mentoria, com acessos configurados, equipe apresentada e cronograma definido.',
          milestone: 'Clareza da Jornada'
        }
      ],
      concepcao: [
        {
          id: 'intro_conc', title: 'Concepção de Estratégia', subtitle: 'Etapa 1 \u2022 Mês 1',
          type: 'intro',
          badge: 'Etapa 1 \u2022 Mês 1',
          text: 'Nesta fase, vamos construir toda a base estratégica do seu negócio. É aqui que definimos posicionamento, oferta, funil de vendas e scripts de conversão.'
        },
        {
          id: 'call_estrategia', title: 'Call de Estratégia', subtitle: 'Reunião com o estrategista',
          type: 'list',
          intro: 'Reunião profunda com seu estrategista para definir a direção do negócio.',
          items: [
            { icon: '\u{1F3AF}', text: 'Definição do posicionamento e nicho específico' },
            { icon: '\u{1F4B0}', text: 'Modelagem da oferta (ticket, formato, duração)' },
            { icon: '\u{1F50D}', text: 'Análise de concorrência e diferenciação' },
            { icon: '\u{1F4DD}', text: 'Briefing completo para produção dos dossiês' },
          ]
        },
        {
          id: 'dossie', title: 'Dossiê Estratégico', subtitle: '5 entregáveis completos',
          type: 'cards',
          intro: 'O dossiê é o documento-mestre da sua mentoria. Produzido pela equipe CASE com base na call de estratégia.',
          cards: [
            { icon: '\u{1F4E6}', title: 'Oferta', desc: 'Arquitetura completa da oferta com pricing, pilares e diferenciais.' },
            { icon: '\u{1F3D7}\uFE0F', title: 'Arquitetura', desc: 'Estrutura do programa: módulos, entregas, cronograma interno.' },
            { icon: '\u{1F3AF}', title: 'Funil de Vendas', desc: 'Funis completos com templates de mensagem e scripts.' },
            { icon: '\u{1F3AC}', title: 'Aulas/Conteúdo', desc: 'Estratégia de conteúdo com pilares, calendários e roteiros.' },
            { icon: '\u{1F4AC}', title: 'Scripts', desc: 'Scripts de vendas, qualificação e tratamento de objeções.' },
          ]
        },
        {
          id: 'apresentacao_dossie', title: 'Apresentação do Dossiê', subtitle: 'Segunda call com estrategista',
          type: 'list',
          intro: 'Reunião de apresentação e validação do dossiê produzido.',
          items: [
            { icon: '\u{1F4CA}', text: 'Apresentação detalhada de cada seção do dossiê' },
            { icon: '\u{2705}', text: 'Validação e ajustes com o mentorado' },
            { icon: '\u{1F4DD}', text: 'Definição do plano de ação imediato' },
            { icon: '\u{1F4C5}', text: 'Agendamento das próximas entregas' },
          ]
        },
        {
          id: 'marco_conc', title: 'Marco', subtitle: 'Estratégia Definida',
          type: 'milestone',
          text: 'Com o dossiê validado, você tem toda a estratégia documentada e pronta para execução. Posicionamento, oferta, funil e scripts — tudo definido.',
          milestone: 'Estratégia Definida'
        }
      ],
      validacao: [
        {
          id: 'intro_val', title: 'Validação e Primeiras Vendas', subtitle: 'Etapa 2 \u2022 Mês 2-3',
          type: 'intro',
          badge: 'Etapa 2 \u2022 Mês 2-3',
          text: 'Hora de colocar a estratégia em prática. Nesta fase você executa o funil, faz as primeiras abordagens e fecha as primeiras vendas.'
        },
        {
          id: 'executar', title: 'O que Executar', subtitle: 'Ações práticas',
          type: 'cards',
          intro: 'As 5 frentes de execução simultânea nesta fase.',
          cards: [
            { icon: '\u{1F4E9}', title: 'Abordagens', desc: 'Envio de mensagens de prospecção usando os scripts do dossiê.' },
            { icon: '\u{1F4F1}', title: 'Conteúdo', desc: 'Início da produção de conteúdo seguindo o calendário.' },
            { icon: '\u{1F4DE}', title: 'Calls de Venda', desc: 'Agendamento e condução de calls de qualificação e venda.' },
            { icon: '\u{1F4CA}', title: 'Métricas', desc: 'Registro diário de mensagens, respostas, calls e vendas.' },
            { icon: '\u{1F504}', title: 'Iteração', desc: 'Ajustes rápidos baseados nos primeiros resultados.' },
          ]
        },
        {
          id: 'apoio_val', title: 'Apoio Disponível', subtitle: 'Suporte contínuo',
          type: 'support_list',
          items: [
            'Revisão semanal de métricas com estrategista',
            'Feedback em tempo real via WhatsApp',
            'Correção de rota em calls quinzenais',
            'Templates de follow-up atualizados',
            'Treinamento de vendas ao vivo',
            'Análise de conversas gravadas',
            'Suporte técnico para ferramentas',
            'Grupo de mentorados para troca',
          ]
        },
        {
          id: 'habilidades_val', title: 'Habilidades a Desenvolver', subtitle: 'Foco desta fase',
          type: 'cards',
          cards: [
            { icon: '\u{1F4B5}', title: 'Vendas', desc: 'Dominar scripts, conduzir calls com confiança e tratar objeções.' },
            { icon: '\u{1F4F2}', title: 'Conteúdo', desc: 'Produzir conteúdo estratégico que gera autoridade e atrai leads.' },
          ]
        },
        {
          id: 'marco_val', title: 'Marco', subtitle: 'Primeiras Vendas',
          type: 'milestone',
          text: 'O objetivo desta fase é fechar as primeiras vendas reais. Cada venda valida a estratégia e traz dados para otimização.',
          milestone: 'Primeiras Vendas'
        }
      ],
      otimizacao: [
        {
          id: 'intro_oti', title: 'Otimização com Dados Reais', subtitle: 'Etapa 3 \u2022 Mês 4-7',
          type: 'intro',
          badge: 'Etapa 3 \u2022 Mês 4-7',
          text: 'Com as primeiras vendas realizadas, agora é hora de otimizar. Analisamos dados reais para aumentar conversão, ajustar oferta e criar consistência.'
        },
        {
          id: 'objetivos_oti', title: 'Objetivos', subtitle: '4 focos de otimização',
          type: 'cards',
          cards: [
            { icon: '\u{1F4C8}', title: 'Taxa de Conversão', desc: 'Aumentar conversão de leads em clientes com ajustes finos nos scripts.' },
            { icon: '\u{1F4B0}', title: 'Ticket Médio', desc: 'Validar e ajustar precificação baseado no feedback do mercado.' },
            { icon: '\u{1F504}', title: 'Funil de Vendas', desc: 'Otimizar cada etapa do funil com base nos dados coletados.' },
            { icon: '\u{1F4F1}', title: 'Conteúdo', desc: 'Ajustar estratégia de conteúdo com base no engajamento real.' },
          ]
        },
        {
          id: 'call_analise', title: 'Call de Análise', subtitle: 'Reunião com estrategista',
          type: 'list',
          intro: 'Reunião aprofundada para analisar métricas e definir otimizações.',
          items: [
            { icon: '\u{1F4CA}', text: 'Análise completa de métricas: mensagens, calls, vendas' },
            { icon: '\u{1F50D}', text: 'Identificação de gargalos no funil' },
            { icon: '\u{1F527}', text: 'Definição de ajustes específicos' },
            { icon: '\u{1F4CB}', text: 'Plano de ação para o próximo mês' },
          ]
        },
        {
          id: 'apoio_oti', title: 'Apoio Disponível', subtitle: 'Suporte contínuo',
          type: 'support_list',
          items: [
            'Dashboards de performance atualizados',
            'Análise de gravações de calls de venda',
            'Otimização de scripts baseada em dados',
            'Estratégia de conteúdo ajustada',
            'Coaching individual quando necessário',
            'Benchmarking com outros mentorados',
            'Suporte em automações e ferramentas',
            'Grupo mastermind mensal',
          ]
        },
        {
          id: 'habilidades_oti', title: 'Habilidades a Desenvolver', subtitle: 'Foco desta fase',
          type: 'cards',
          cards: [
            { icon: '\u{1F4CA}', title: 'Análise de Dados', desc: 'Interpretar métricas e tomar decisões baseadas em dados reais.' },
            { icon: '\u{1F504}', title: 'Iteração Rápida', desc: 'Testar, medir e ajustar rapidamente cada elemento do funil.' },
          ]
        },
        {
          id: 'marco_oti', title: 'Marco', subtitle: 'Vendas com Consistência',
          type: 'milestone',
          text: 'O objetivo é atingir consistência nas vendas — não depender de picos, mas ter um fluxo previsível e sustentável.',
          milestone: 'Vendas com Consistência'
        }
      ],
      escala: [
        {
          id: 'intro_esc', title: 'Escala Sustentável', subtitle: 'Etapa 4 \u2022 Mês 8-12',
          type: 'intro',
          badge: 'Etapa 4 \u2022 Mês 8-12',
          text: 'A fase final transforma seu negócio em uma operação escalável. Automações, equipe, processos e novos canais de aquisição.'
        },
        {
          id: 'objetivos_esc', title: 'Objetivos de Escala', subtitle: '6 frentes',
          type: 'cards',
          cards: [
            { icon: '\u{2699}\uFE0F', title: 'Automações', desc: 'Automatizar processos repetitivos: follow-up, agendamento, onboarding.' },
            { icon: '\u{1F465}', title: 'Equipe', desc: 'Contratar e treinar SDR ou assistente para prospecção.' },
            { icon: '\u{1F4CB}', title: 'Processos', desc: 'Documentar POPs (Procedimentos Operacionais Padrão) do negócio.' },
            { icon: '\u{1F4E2}', title: 'Novos Canais', desc: 'Expandir para tráfego pago, parcerias e indicações.' },
            { icon: '\u{1F3AC}', title: 'Eventos', desc: 'Planejar webinars ou eventos presenciais para lançamento.' },
            { icon: '\u{1F4B8}', title: 'Recorrência', desc: 'Criar modelo de recorrência ou continuidade pós-mentoria.' },
          ]
        },
        {
          id: 'plano_escala', title: 'Plano de Escala', subtitle: 'Reunião com consultor',
          type: 'list',
          intro: 'Call dedicada para montar o plano de escala personalizado.',
          items: [
            { icon: '\u{1F4CB}', text: 'Definição de metas de faturamento para os próximos 6 meses' },
            { icon: '\u{1F465}', text: 'Plano de contratação e delegação' },
            { icon: '\u{2699}\uFE0F', text: 'Mapeamento de automações prioritárias' },
            { icon: '\u{1F4E2}', text: 'Estratégia de aquisição escalável' },
          ]
        },
        {
          id: 'apoio_esc', title: 'Apoio Disponível', subtitle: 'Suporte contínuo',
          type: 'support_list',
          items: [
            'Consultoria em automações e ferramentas',
            'Templates de POPs e processos',
            'Estratégia de tráfego pago',
            'Planejamento de eventos',
            'Suporte na contratação de equipe',
            'Revisão do modelo de negócio',
            'Networking com outros mentorados avançados',
            'Plano de transição pós-mentoria',
          ]
        },
        {
          id: 'marco_esc', title: 'Marco', subtitle: 'Negócio Estruturado',
          type: 'milestone',
          text: 'Ao final desta fase, você terá um negócio estruturado com processos, equipe e canais de aquisição funcionando. Sua mentoria está completa — mas a jornada continua.',
          milestone: 'Negócio Estruturado',
          journeyComplete: true
        }
      ]
    },

    // --- Support pages ---
    supportPages: [
      {
        id: 'estrategista', icon: '\u{1F9E0}', label: 'Estrategista',
        title: 'Sua Estrategista',
        content: {
          name: 'Queila Trizotti',
          role: 'Estrategista-Chefe',
          photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Queilatrizotti.jpg',
          bio: 'Especialista em posicionamento e monetização de mentorias. Mais de R$ 55M+ gerados no digital. Responsável por estruturar ofertas, funis e estratégias de conversão para mentorados CASE.',
          responsibilities: [
            'Definir posicionamento e estratégia de mercado',
            'Produzir os dossiês estratégicos',
            'Conduzir calls de estratégia e análise',
            'Orientar decisões de pricing e oferta',
            'Acompanhar evolução e corrigir rota',
          ]
        }
      },
      {
        id: 'equipe', icon: '\u{1F465}', label: 'Equipe',
        title: 'Equipe CASE',
        content: {
          estrategistas: [
            { name: 'Queila Trizotti', role: 'Estrategista-Chefe', photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Queilatrizotti.jpg', highlight: 'R$ 55M+ gerados no digital' },
            { name: 'Hugo Nicchio', role: 'Estrategista', photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Hugo%20Nicchio.jpg', highlight: 'R$ 300M+ gerados no digital' },
            { name: 'Kaique', role: 'Especialista em Funis', photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Kaique.jpg', highlight: 'Expert em IA e Performance' },
            { name: 'Mariza Ribeiro', role: 'Especialista em Copy', photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Mariza%20Ribeiro.jpg', highlight: '+5 anos no time' },
            { name: 'Victor Rubens', role: 'Especialista em Campanhas', photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Victor%20Rubens.jpg', highlight: '+R$ 30M em campanhas' },
          ],
          lideres: [
            { name: 'Heitor', role: 'Líder Consultivo', photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Heitor.jpg', highlight: 'Seu parceiro de execução' },
            { name: 'Lara', role: 'Líder Consultiva', photo: 'https://sttacbrmtyxiwprovhrf.supabase.co/storage/v1/object/public/user-avatars/Lara%20Santos.jpg', highlight: 'Sua parceira de execução' },
          ]
        }
      },
      {
        id: 'agentes', icon: '\u{1F916}', label: 'Agentes IA',
        title: 'Agentes de Inteligência Artificial',
        content: {
          agents: [
            { name: 'Agente de Extração Editorial', desc: 'Captura seu DNA editorial a partir de conteúdos e conversas.' },
            { name: 'Agente de Conteúdo', desc: 'Gera ideias de conteúdo alinhadas com sua oferta e posicionamento.' },
            { name: 'Agente de Roteiros', desc: 'Transforma ideias em roteiros prontos para stories e reels.' },
            { name: 'Agente de Funil de Vendas', desc: 'Guia na execução do funil de vendas com scripts e templates.' },
            { name: 'Agente Revisor de Arquitetura', desc: 'Estrutura seu produto e valida a arquitetura da oferta.' },
            { name: 'Agente de Roteiro de Aulas', desc: 'Roteiriza suas aulas com estrutura pedagógica e engajamento.' },
            { name: 'Agente de Lapidação de Perfil', desc: 'Analisa e direciona ajustes no seu perfil do Instagram.' },
            { name: 'Seu Agente Personalizado', desc: 'Criado especificamente para você, com base no seu dossiê e contexto.' },
          ]
        }
      },
      {
        id: 'manuais', icon: '\u{1F4D6}', label: 'Manuais',
        title: 'Manuais e Documentos',
        content: {
          docs: [
            { title: 'Guia de Primeiros Passos', desc: 'Tudo que você precisa saber para começar com o pé direito.' },
            { title: 'Manual de Vendas', desc: 'Scripts, técnicas e processos de venda validados.' },
            { title: 'Guia de Conteúdo', desc: 'Como produzir conteúdo estratégico para atrair leads.' },
            { title: 'Playbook de Automações', desc: 'Configuração de ferramentas e automações do funil.' },
          ]
        }
      },
      {
        id: 'encontros', icon: '\u{1F4C5}', label: 'Encontros',
        title: 'Encontros Semanais',
        content: {
          description: 'Toda semana temos encontros ao vivo para acompanhamento, troca e aprendizado.',
          meetings: [
            { day: 'Terça-feira', time: '10h', title: 'Encontro de Estratégia', desc: 'Análise de casos, otimização de funis e correção de rota.' },
            { day: 'Quinta-feira', time: '14h', title: 'Encontro de Conteúdo', desc: 'Planejamento de conteúdo, revisão de roteiros e tendências.' },
          ]
        }
      },
      {
        id: 'plataforma', icon: '\u{1F4BB}', label: 'Plataforma',
        title: 'Áreas da Plataforma',
        content: {
          areas: [
            { name: 'Dashboard', desc: 'Visão geral do seu progresso, métricas e próximos passos.' },
            { name: 'Dossiês', desc: 'Acesso aos documentos estratégicos produzidos para você.' },
            { name: 'Planos de Ação', desc: 'Tarefas e entregas organizadas por fase da mentoria.' },
            { name: 'WhatsApp', desc: 'Gestão de conversas e histórico de atendimento.' },
            { name: 'Agenda', desc: 'Calendário de calls, encontros e entregas.' },
            { name: 'Equipe', desc: 'Informações da equipe e contatos diretos.' },
          ]
        }
      },
      {
        id: 'comunidade', icon: '\u{1F91D}', label: 'Comunidade',
        title: 'Comunidade CASE',
        content: {
          description: 'A comunidade CASE conecta mentorados em diferentes fases da jornada para troca de experiências e networking.',
          features: [
            'Grupo exclusivo no WhatsApp',
            'Encontros mensais de networking',
            'Compartilhamento de resultados e aprendizados',
            'Parcerias entre mentorados',
            'Acesso a cases de sucesso detalhados',
            'Convites para eventos presenciais',
          ]
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
