/* ================================================================
   SPALLA V2 — Application Logic (Full Feature Set)
   Stack: Alpine.js + Supabase JS v2 + Evolution API
   Pages: Dashboard, Detail, Kanban, Dossies, Tasks, WhatsApp, Docs, Lembretes
   ================================================================ */

// ===== CONFIG =====
const CONFIG = {
  API_BASE: 'https://web-production-2cde5.up.railway.app',  // Production server (Railway HTTPS proxy)
  SUPABASE_URL: 'https://knusqfbvhsqworzyhvip.supabase.co',
  SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtudXNxZmJ2aHNxd29yenlodmlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4NTg3MjcsImV4cCI6MjA3MDQzNDcyN30.f-m7TlmCoccBpUxLZhA4P5kr2lWBGtRIv6inzInAKCo',
  AUTH_STORAGE_KEY: 'spalla_auth',
  TASKS_STORAGE_KEY: 'spalla_tasks',
  REMINDERS_STORAGE_KEY: 'spalla_reminders',
  DEFAULT_PAGE: 'dashboard',
  ITEMS_PER_PAGE: 50,
};

// ===== TEAM MEMBERS =====
// Note: Full member data (emails) stored in Supabase. Only identifiers kept here.
const TEAM_MEMBERS = [
  { name: 'Kaique', id: 'kaique' },
  { name: 'Heitor', id: 'heitor' },
  { name: 'Hugo', id: 'hugo' },
  { name: 'Queila', id: 'queila' },
  { name: 'Mariza', id: 'mariza' },
  { name: 'Lara', id: 'lara' },
  { name: 'Gobbi', id: 'gobbi' },
];

// ===== EVOLUTION API GUARD =====
const EVOLUTION_INSTANCE = typeof EVOLUTION_CONFIG !== 'undefined' ? EVOLUTION_CONFIG.INSTANCE : null;

// ===== SUPABASE CLIENT =====
let sb = null;

async function initSupabase() {
  if (!CONFIG.SUPABASE_ANON_KEY) {
    console.warn('[Spalla] Supabase anon key not configured — using demo data');
    return null;
  }

  // Reuse existing instance if already initialized
  if (sb) return sb;

  // Wait for Supabase JS to load (with timeout)
  let attempts = 0;
  while ((!window.supabase || !window.supabase.createClient) && attempts < 50) {
    await new Promise(resolve => setTimeout(resolve, 100)); // Wait 100ms
    attempts++;
  }

  if (!window.supabase || !window.supabase.createClient) {
    console.error('[Spalla] Supabase JS failed to load after 5 seconds');
    return null;
  }

  try {
    const client = window.supabase.createClient(CONFIG.SUPABASE_URL, CONFIG.SUPABASE_ANON_KEY);
    return client;
  } catch (e) {
    console.error('[Spalla] Failed to init Supabase:', e);
    return null;
  }
}

// ===== TEMPORAL AWARENESS =====
function SYSTEM_TODAY() { return new Date(); }
function parseDateStr(dateStr) {
  if (!dateStr) return null;
  if (/^\d{2}\/\d{2}\/\d{4}$/.test(dateStr)) {
    const [d, m, y] = dateStr.split('/');
    return new Date(parseInt(y), parseInt(m) - 1, parseInt(d));
  }
  // YYYY-MM-DD: force local timezone (avoid UTC shift showing previous day)
  if (/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) {
    return new Date(dateStr + 'T00:00:00');
  }
  const date = new Date(dateStr);
  return isNaN(date.getTime()) ? null : date;
}
function daysBetween(dateStr) {
  const d = parseDateStr(dateStr);
  if (!d) return null;
  return Math.floor((SYSTEM_TODAY() - d) / (1000 * 60 * 60 * 24));
}

// ===== ALPINE APP =====
function operon() {
  return {
    // === PHASE TASK TEMPLATES (Wave 2 F2.1) ===
    PHASE_TASK_TEMPLATES: {
      'onboarding': [
        { titulo: 'Enviar kit de boas-vindas', descricao: 'Kit com acesso à plataforma, cronograma e materiais iniciais', prioridade: 'alta' },
        { titulo: 'Agendar call de onboarding', descricao: 'Call de 60min para alinhamento de expectativas e plano de ação', prioridade: 'alta' },
        { titulo: 'Criar grupo WhatsApp', descricao: 'Grupo com mentorado + consultor responsável', prioridade: 'alta' },
        { titulo: 'Verificar assinatura do contrato', descricao: 'Confirmar recebimento e assinatura do contrato na plataforma', prioridade: 'alta' },
      ],
      'concepcao': [
        { titulo: 'Definir nicho e público-alvo', descricao: 'Workshop para definição precisa do nicho e ICP', prioridade: 'alta' },
        { titulo: 'Validar oferta principal', descricao: 'Revisão e validação da oferta com framework CASE', prioridade: 'alta' },
        { titulo: 'Criar estrutura do funil', descricao: 'Mapear etapas do funil de vendas', prioridade: 'normal' },
        { titulo: 'Definir posicionamento', descricao: 'Definir diferencial e mensagem de posicionamento', prioridade: 'normal' },
      ],
      'validacao': [
        { titulo: 'Acompanhar primeira venda', descricao: 'Suporte e monitoramento até fechar primeira venda', prioridade: 'alta' },
        { titulo: 'Review do funil de vendas', descricao: 'Análise de métricas e ajustes necessários', prioridade: 'alta' },
        { titulo: 'Ajustar oferta conforme feedback', descricao: 'Iterar oferta com base em objeções reais', prioridade: 'normal' },
        { titulo: 'Call de estratégia — próxima fase', descricao: 'Call para planejar transição para Otimização', prioridade: 'normal' },
      ],
      'otimizacao': [
        { titulo: 'Escalar tráfego pago', descricao: 'Aumentar investimento em tráfego com base nos dados', prioridade: 'alta' },
        { titulo: 'Otimizar taxa de conversão', descricao: 'A/B test de copy, landing page e oferta', prioridade: 'alta' },
        { titulo: 'Automatizar processos repetitivos', descricao: 'Mapear e automatizar top 3 gargalos operacionais', prioridade: 'normal' },
      ],
      'escala': [
        { titulo: 'Definir estrutura da equipe', descricao: 'Mapear cargos e responsabilidades necessárias para escalar', prioridade: 'alta' },
        { titulo: 'Implementar processos e SOPs', descricao: 'Documentar processos críticos para onboarding de equipe', prioridade: 'alta' },
        { titulo: 'Escalar operação', descricao: 'Executar plano de escala com time definido', prioridade: 'normal' },
      ],
    },

    // --- Auth ---
    auth: {
      authenticated: false,
      mode: 'login', // 'login' | 'register' | 'reset'
      email: '',
      password: '',
      confirmPassword: '',
      fullName: '',
      error: '',
      success: '',
      currentUser: null,
      accessToken: null,
      refreshToken: null,
    },
    supabaseConnected: false,
    _supabaseCalls: [],

    // --- WA Quick Reply Templates (Wave 2 F2.3) ---
    WA_QUICK_REPLY_TEMPLATES: [
      { id: 'saudacao', label: '\u{1F44B} Saudação', template: 'Oi {nome}! Tudo bem? Passei para checar como você está indo. Tem alguma dúvida ou precisa de algo?' },
      { id: 'lembrete-call', label: '\u{1F4C5} Lembrete de Call', template: 'Oi {nome}! Lembrete: sua call está agendada para amanhã. Confirma sua presença?' },
      { id: 'parabens-venda', label: '\u{1F389} Parabéns pela Venda', template: 'Parabéns pela primeira venda, {nome}! Esse é um marco enorme. Estamos muito felizes com seu progresso!' },
      { id: 'reengajamento', label: '\u{26A1} Reengajamento', template: 'Oi {nome}, notei que faz alguns dias sem atividade. Tudo certo? Posso ajudar com algum bloqueio?' },
      { id: 'checkin-semanal', label: '\u{1F4CA} Check-in Semanal', template: 'Oi {nome}! Check-in semanal: como foi sua semana? Conseguiu executar o plano de ação?' },
      { id: 'mudanca-fase', label: '\u{1F680} Mudança de Fase', template: 'Oi {nome}! Você avançou para a fase {fase}. Preparei as próximas tarefas para você. Bora?' },
      { id: 'tarefa-pendente', label: '\u{2705} Tarefa Pendente', template: 'Oi {nome}, você tem tarefas pendentes desta semana. Posso ajudar a desbloqueá-las?' },
      { id: 'resultado-financeiro', label: '\u{1F4B0} Resultado Financeiro', template: 'Oi {nome}! Vi que você teve um resultado incrível. Vamos conversar sobre como escalar isso?' },
    ],

    // --- Broken photo tracking ---
    brokenPhotos: {},
    waPhotos: {},
    photoTick: 0,

    // --- Auto Refresh ---
    _refreshInterval: null,
    _refreshIntervalMs: 60000, // 60 seconds
    _whatsappPollInterval: null,
    _whatsappPollIntervalMs: 5000, // 5 seconds

    // --- Debounce timers ---
    _searchTimer: null,
    _obDebounceTimer: null,
    _dsDebounceTimer: null,
    _paDebounceTimer: null,

    // --- Detail cache ---
    _detailCache: {},

    // --- UI State ---
    darkMode: localStorage.getItem('spalla_dark') === 'true',
    toggleDarkMode() {
      this.darkMode = !this.darkMode;
      localStorage.setItem('spalla_dark', this.darkMode);
      document.documentElement.setAttribute('data-theme', this.darkMode ? 'dark' : 'light');
    },
    ui: {
      page: localStorage.getItem('spalla_page') || CONFIG.DEFAULT_PAGE,
      sidebarOpen: true,
      mobileMenuOpen: false,
      search: '',
      filters: { fase: '', risco: '', cohort: '', status: '', financeiro: '', carteira: '' },
      sort: 'nome',
      sortDir: 'asc',
      loading: true,
      sheetsSyncing: false,
      detailLoading: false,
      finDetailLoading: false,  // loading state for financial detail logs
      selectedMenteeId: null,
      activeDetailTab: 'resumo',
      detailTaskFilter: 'pendentes',
      toasts: [],
      // Tasks
      taskFilter: 'all', // all | pendente | em_andamento | concluida | atrasada
      taskTipoFilter: '', // '' = todos; 'dossie', 'follow_up', etc.
      taskAssignee: '', // '' = todos; '__mine__' = minhas tarefas
      taskModal: false,
      taskEditId: null,
      taskView: 'board', // 'list' | 'board'
      taskDetailDrawer: null, // task ID for detail drawer
      drawerNewSubtask: '', // inline subtask add in drawer
      mentionDropdown: false,  // @mention dropdown visível
      mentionQuery: '',        // texto digitado após @
      mentionStart: -1,        // posição do @ no textarea
      taskGanttRange: 'month', // 'week' | 'month' | 'quarter'
      _ganttDrag: null,
      ganttFocusedTaskId: null,  // Dragon 55: keyboard-navigated task
      descarregoFilter: 'todos',
      descarregoExpanded: {},
      batchDescarregoOpen: false,
      batchDescarregoText: '',
      batchDescarregoSubmitting: false,
      calYear: new Date().getFullYear(),
      calMonth: new Date().getMonth(),
      bulkSelected: {}, // { taskId: true }
      bulkMode: false,
      collapsedGroups: {},
      fieldsModalOpen: false,
      fieldsModalTab: 'add', // 'create' | 'add'
      newFieldName: '',
      newFieldType: 'text',
      visibleFieldIds: {}, // { fieldId: true } — which custom fields show as columns
      nativeFieldsVisible: { nome: true, sprints: true, responsavel: true, data_inicio: true, data_fim: true, prioridade: true, points: true, status: true, comentarios: true }, // native column toggles
      collapsedSpaces: {}, // { spaceId: true }
      subtaskExpanded: null, // index of expanded subtask in drawer
      automationsOpen: false,
      autoForm: { name: '', trigger_type: 'status_changed', trigger_config: {}, condition_config: {}, action_type: 'change_status', action_config: {} },
      dashboardOpen: false,
      notificationsOpen: false,
      taskSpaceFilter: 'all', // space_id filter
      taskListFilter: 'all', // list_id filter
      taskSprintFilter: 'all', // sprint_id filter
      ccWeekOffset: 0,       // Command Center week nav: 0=current, -1=prev, +1=next
      ccBoardFilter: 'priority', // 'all' | 'priority' (hide escala/validacao) | 'onboarding' | 'concepcao' | 'validacao' | 'escala'
      ccBoardExpanded: {},   // mentorado id → boolean
      ccDailyExpanded: false,
      ccActivityExpanded: false,
      spaceExpanded: null,   // which space has sub-lists visible
      docsTab: 'arquivos',   // 'arquivos' | 'biblioteca' | 'google_docs'
      taskGroupBy: 'status', // 'status' | 'assignee' | 'priority' | 'list'
      // EPIC 2: Fabric AI
      fabricModal: false, fabricPattern: 'case_extract_oferta', fabricInput: '', fabricResult: '', fabricError: '', fabricLoading: false,
      // EPIC 6: Dossiê generation
      dossieGenType: 'oferta',
      // Context Hub
      ctxTipo: 'texto', ctxTitulo: '', ctxConteudo: '', ctxArquivo: null, ctxFase: 'onboarding', ctxSaving: false,
      ctxLinkUrl: '',
      ctxFilter: { tipo: 'all', fase: 'all' },
      ctxExpanded: {},
      ctxEditing: {},   // { [ctxId]: { titulo, conteudo, fase } }
      ctxTranscribing: {},
      ctxRecording: false,
      ctxMediaRecorder: null,
      ctxRecordingChunks: [],
      ctxRecordingSeconds: 0,
      ctxRecordingTimer: null,
      ativoSearch: '',
      ativoResults: [],
      // Save-to-context modal state
      ctxSaveModal: false,
      ctxSaveData: null, // { menteeId, menteeName, msg, tipo, chatJid, mediaUrl, msgText, msgId }
      ctxSaveDesc: '',
      ctxSavePasta: '',
      ctxSaveSaving: false,
      taskTagFilter: [],       // tag ids for filtering
      taskDateFilter: 'all', // all | today | next7 | next30 | overdue | no_date
      taskTagsDropdown: false, // tags dropdown open in modal
      taskTagsFilterOpen: false, // tags filter dropdown in toolbar
      syncingSubtasks: false,    // ClickUp subtask sync in progress
      taskExpandedIds: {},       // { [taskId]: true } for tree expand/collapse
      taskActivity: [],          // activity events for current task detail
      reactionPicker: null,      // comment id with open emoji picker
      listColumnsOpen: false,    // column config dropdown
      listColumns: {
        responsavel:  { label: 'Responsável',   visible: true },
        acompanhante: { label: 'Acompanhante',  visible: true },
        mentorado:    { label: 'Mentorado',      visible: true },
        datas:        { label: 'Datas',          visible: true },
        prioridade:   { label: 'Prioridade',     visible: true },
        status:       { label: 'Status',         visible: false },
        tags:         { label: 'Tags',           visible: false },
        fonte:        { label: 'Fonte',          visible: false },
        space:        { label: 'Space / Lista',  visible: false },
        comentarios:  { label: 'Comentários',    visible: false },
        criado_em:    { label: 'Criado em',      visible: false },
        atualizado:   { label: 'Atualizado',     visible: false },
      },
      // Dossiers (legacy)
      dossierFilter: 'all',
      // Dossiê Production System
      dsFilter: 'all',
      dsCarteira: 'all',
      dsTipoDoc: 'all',        // all | oferta | conteudo | funil
      dsView: 'painel',        // painel | pipeline | lista
      dsSearchQuery: '',
      dsExpandedDocs: {},       // { producaoId: true }
      dsLoading: false,
      dsModal: false,
      dsCreateModal: false,
      dsCreateForm: { mentorado_id: '', responsavel: '', briefing: '', docs: ['oferta', 'funil', 'conteudo'] },
      dsCreateUploading: false,
      dsCreateFiles: [],
      dsRecording: false,
      dsMediaRecorder: null,
      dsDetailProducaoId: null, // for detail view
      dsConfirm: null,          // { title, msg, onConfirm }
      dsSortField: 'mentorado_nome',
      dsSortAsc: true,
      mediaModal: null,          // { url, originalUrl, label } para iframe preview
      dsAjusteError: false,
      // WhatsApp
      whatsappSelectedChat: null,
      whatsappMessage: '',
      waReplyTo: null,
      waLightboxUrl: null,
      waRecording: false,
      waRecorder: null,
      waSearchQuery: '',
      waSearchResults: [],
      waSearchOpen: false,
      // Onda 4: navegação entre matches + FAB nova msg + lightbox enriquecido
      waSearchActiveIdx: 0,
      waNewMsgFabVisible: false,
      waNewMsgFabCount: 0,
      waLightboxList: [],
      waLightboxIdx: 0,
      // Onda 6: mini-card mentorado contextual (painel collapsible)
      waMenteeCardOpen: false,
      // Onda 7: performance + atalhos + animação envio
      waMaxVisibleMessages: 200,
      waShortcutsOpen: false,
      waJustSentId: null,
      waTypingIndicator: false,
      waGroupsPanel: false,
      waGroupsSyncing: false,
      waGroupCreateModal: false,
      waGroupForm: { subject: '', mentorado_id: '', participants: '' },
      detailWaMessage: '',
      waFollowupEnabled: false,
      waFollowupDays: 2,
      bulkFollowupModal: false,
      feedbackFormOpen: false,
      batchTaskModal: false,
      feedbackCatFilter: '',
      feedbackStatusFilter: '',
      driveSyncing: false,
      waFaseFilter: '',
      whatsappLoading: false,
      // WhatsApp Per-User Session
      waSessionLoading: false,
      waQrPolling: false,
      waSendingMedia: false,
      waMobileSidebarHidden: false,
      // WA Topics Board
      waTopicsView: 'board',
      waTopicsSearch: '',
      waTopicsStatusFilter: '',
      waTopicsTypeFilter: '',
      waTopicDetail: null,
      waTopicMessages: [],
      waTopicsLoading: false,
      // WA Management — Carteira
      waPortfolioLoading: false,
      waPortfolioView: 'carteira',      // 'carteira' | 'inbox'
      waPortfolioFaseFilter: '',        // '' | 'onboarding' | 'execucao' | 'resultado' | 'renovacao'
      waPortfolioHealthFilter: '',      // '' | 'verde' | 'amarelo' | 'vermelho'
      waFilterLogic: 'AND',             // 'AND' | 'OR' — compound filter logic
      waFocusedIdx: -1,                 // keyboard navigation: index in waPortfolioMentees()
      waFaseDropdownId: null,           // id of mentee with open fase dropdown
      // WA Management — Notas Estruturadas
      notesDrawer: { open: false, menteeId: null, menteeNome: '', tipo: 'livre' },
      offboardModal: { open: false, menteeId: null, menteeNome: '', motivo: '', obs: '', loading: false },
      notesDrawerTab: 'notes',   // I-5: 'notes' | 'files'
      notesSaving: false,
      notesForm: {
        conteudo: '', tags: '',
        progresso: 0, bloqueios: '', proximos_passos: '',
        participou: false, entregou_tarefa: false, observacoes: '',
        duracao: '', topicos: '', decisoes: '', followups: ''
      },
      // Groups / Pastas
      groupsPanel: false,
      groupsModal: { open: false, editing: null },
      groupsForm: { nome: '', cor: '#6366f1', icon: '\u{1F4C1}' },
      activeGroupFilter: null,
      assignModal: { open: false, menteeId: null, menteeNome: '' },
      // I-2: triage scores lazy-load state
      triageLoaded: false,
      // I-4: Copilot Contextual
      copilotOpen: false,
      copilotMenteeId: null,
      copilotMenteeNome: '',
      copilotInput: '',
      copilotLoading: false,
      copilotHistory: [],  // [{role, content}]
      // WA Management — Bulk Selection
      waBulkMode: false,             // bulk select mode on/off
      waBulkFase: '',                // fase to apply in bulk
      waBulkApplying: false,         // loading state for bulk apply
      // WA Management — AI Group Digest
      digestModal: { open: false, menteeId: null, menteeNome: '' },
      digestLoading: false,
      // Reminders
      reminderModal: false,
      reminderFilter: 'ativo', // ativo | concluido | all
      // Plano de Ação
      paFilter: 'all',          // all | nao_iniciado | em_andamento | pausado | concluido
      paView: 'painel',         // painel | pipeline | list
      paModal: false,           // create plan modal
      paExpandedFases: {},      // { faseId: true } for accordion
      paLoading: false,         // loading state for PA detail
      paSearchQuery: '',        // busca por nome do mentorado
      // Perfil Comportamental
      perfilLoading: false,
      perfilModal: false,
      perfilInputMode: 'json',  // json | form
      perfilGerando: false,     // estado de loading da geração IA
      // Onboarding CS
      obView: 'painel',         // painel | pipeline | lista
      obFilter: 'all',          // all | em_andamento | concluido | atrasado
      obSearchQuery: '',
      obExpandedTrilha: null,
      obLoading: false,
      obTemplateMode: false,     // toggle editor de template
      obExpandedEtapas: {},      // { etapaId: true } for accordion in detail
      obDetailTrilhaId: null,
      obNewTrilhaModal: false,
      obNewTrilhaResp: '',
      obNewTrilhaMentorado: '',
      // Docs
      docSearch: '',
      // Agenda Calendar
      selectedCalDate: null,
      calendarMonth: new Date().getMonth(),
      calendarYear: new Date().getFullYear(),
      expandedCall: null,
      scheduleModal: false,
      scheduling: false,
      processCallsModal: false,
      processCallsExpanded: false,
      // WA DM v2 — Inbox (S9-B)
      waInbox: {
        open: false,
        mentoradoId: null,
        mentoradoNome: '',
        messages: [],
        loading: false,
        cursor: null,               // timestamp da msg mais antiga carregada
        hasMore: true,
        presenceInterval: null,
        presencePollInterval: null,
        others: [],                 // outros usuários vendo agora (collision)
      },
      waCanned: {
        filtered: [],
        show: false,
      },
      waMessageInput: '',
      waQuickRepliesOpen: false,
      // S9-C: Task Extraction + Triage + Saved Segments
      waTaskExtract: { open: false, msg: null, titulo: '', prioridade: 'normal', data_fim: '', saving: false },
      waTriageLoading: false,
      waTriageAssigning: null,
      waSavedSegmentActive: null,
      waSaveSegmentModal: { open: false, name: '' },
      alertsDismissed: [],
      timelineFilter: '',
      teamView: 'cards', // 'cards' | 'ranking'
      gcalConflict: null,
      checkingConflict: false,    },

    // --- Descarrego page state ---
    descarrego: { menteeId: null, menteeName: '', search: '', dragging: false },

    // --- Meu Trabalho (root-level for Alpine reactivity) ---
    meuTrabalho: [],
    meuTrabalhoLoading: false,
    meuTrabalhoFilter: 'pendentes',  // default: só pendentes/em_andamento
    meuTrabalhoGroupBy: '',
    meuTrabalhoHideDone: true,

    // --- Sprints (root-level) ---
    sprintDashboard: [],
    sprintActive: null,
    sprintTasks: [],
    sprintLoading: false,
    sprintGroupBy: 'status',

    // --- Data ---
    data: {
      mentees: [],
      cohort: [],
      alerts: [],
      detail: null,
      tasks: [],
      reminders: [],
      whatsappChats: [],
      whatsappMessages: [],
      waSession: null,  // { id, instance_name, status, phone_number, connected_at, ... }
      waTopics: [],
      waTopicTypes: [],
      scheduledCalls: [],
      gcalEvents: [],
      pendencias: [],
      aguardandoResposta: [],  // raw interacoes_mentoria mentee→equipe não respondidas (sem filtro do classifier)
      paPlanos: [],       // vw_pa_pipeline data
      paMenteePa: null,   // full PA for current mentee detail
      paAllFases: [],     // lightweight fases for sentinel calcs
      paAllAcoes: [],     // lightweight acoes for sentinel calcs
      // Onboarding CS
      obTrilhas: [],             // vw_ob_pipeline
      obTrilhaDetail: null,      // trilha + etapas + tarefas (detail view)
      obTemplateEtapas: [],      // template etapas + tarefas (for editor)
      obEventos: [],             // timeline / audit trail for detail view
      // Perfil Comportamental
      perfilComportamental: null,
      // Dossiê Production System
      dsProducoes: [],          // vw_ds_pipeline
      dsAllDocs: [],            // ds_documentos (lightweight)
      dsMenteeDetail: null,     // full detail for one mentee
      dsEventos: [],            // audit trail for detail view
      dsAjustes: [],            // ajustes for detail view
      dsBriefingFiles: [],      // briefing files for detail view
      // Tags & Custom Fields
      taskTags: [],             // god_task_tags — all available tags
      fieldDefs: [],            // applicable god_task_field_defs for current modal
      automations: [],          // god_automations rules
      savedViews: [],           // god_saved_views
      templates: [],            // god_task_templates
      finDetailLogs: [],        // financial logs for mentee detail tab
      menteeNotes: [],          // notes for current notes drawer
      waSelectedMentees: [],    // IDs selected in bulk mode
      digestData: null,         // loaded digest for current mentee
// I-2: server-side triage scores, keyed by mentee id
      triageScores: {},        // I-2: keyed by mentee id
      menteeLabels: {},        // I-1: keyed by mentee id → [{slug,name,color,count}]
      waLabelsSummary: [],     // I-1: global label counts
      // I-5: files for current notes drawer mentee
      menteeFiles: { docs: [], media: [], loading: false },
      groups: [],               // mentee_groups with member_ids
      waGroups: [],             // wa_groups from Supabase (Story 8)
      waWeeklyStats: [],        // vw_wa_mentee_weekly_stats (WA Intelligence)
      waAlertas: [],            // vw_alertas_command_center (Story 6)
      agentMetrics: [],         // vw_agent_metrics (ORCH-07)
      _menteeWaActivity: [],    // vw_wa_mentee_activity for selected mentorado
      // WA DM v2 (S9-B)
      waCannedAll: [],          // cache de canned responses
      // S9-C
      waTriageTopics: [],
      waTriageCount: 0,
      waSavedSegments: [],
      timeline: [],
      menteeMessages: [],  // EPIC 1: Chatwoot messages for current mentorado
      menteeContext: [],   // Context Hub: áudios, notas, arquivos para dossiê
      menteeDescarregos: [], // LF-FASE3: pipeline de descarregos (nova entidade)
      // meuTrabalho: moved to root level for Alpine reactivity
      teamPerformance: [],
      feedbackList: [],           // TASK-10: god_feedback entries
      // Command Center static data
      projects: [
        {
          id: 'spalla', icon: '⚡', cor: '#7c3aed',
          nome: 'Spalla Dashboard',
          desc: 'Portal operacional da mentoria — gestão de mentorados, sprints, tasks e integrações ClickUp',
          fase: 'Sprint 1 · Command Center ao vivo',
          team: ['Kaique', 'Heitor'],
          responsavel: 'Kaique', progresso: 72,
          url: 'https://spalla-dashboard.vercel.app', status: 'em_andamento',
        },
        {
          id: 'hub-case', icon: '🤖', cor: '#0ea5e9',
          nome: 'Hub CASE AI',
          desc: 'Central de agentes de IA para uso interno da equipe e acesso dos mentorados',
          fase: 'Configurando onboarding e acesso por mentorado',
          team: ['Kaique'],
          responsavel: 'Kaique', progresso: 35,
          url: 'https://hub.caseai.com.br/', status: 'em_andamento',
        },
        {
          id: 'social-case', icon: '📱', cor: '#10b981',
          nome: 'Social CASE',
          desc: 'Calendário editorial + métricas das redes sociais — Queila e mentorados',
          fase: 'Beta — definindo fluxo de acesso por mentorado',
          team: ['Queila', 'Kaique'],
          responsavel: 'Queila', progresso: 20,
          url: 'http://social.caseai.com.br/', status: 'em_andamento',
        },
        {
          id: 'grupos-wa', icon: '💬', cor: '#f59e0b',
          nome: 'Acomp. WhatsApp',
          desc: 'Suporte consultivo diário — grupos e DMs com mentorados ativos',
          fase: 'Operacional · atendimento contínuo',
          team: ['Kaique', 'Heitor', 'Mariza'],
          responsavel: 'Kaique', progresso: 60,
          url: null, status: 'em_andamento',
        },
        {
          id: 'mentorados', icon: '📄', cor: '#ec4899',
          nome: 'Dossiês e Entregas',
          desc: 'Produção de dossiês de oferta, posicionamento e funil para mentorados ativos',
          fase: 'Produção · 3 mentorados com dossiê em andamento',
          team: ['Mariza', 'Kaique'],
          responsavel: 'Mariza', progresso: 15,
          url: null, status: 'em_andamento',
        },
      ],
      // Sprints carregados de god_lists (tipo='sprint') via loadGodLists()
      // Fallback hardcoded aqui caso Supabase falhe
      sprints: [
        { id: '901113377455', nome: 'Sprint 1', inicio: '2026-03-16', fim: '2026-03-22', status: 'encerrado', total: 7, concluidas: 2, highlights: [] },
        { id: '901113377456', nome: 'Sprint 2', inicio: '2026-03-23', fim: '2026-03-29', status: 'encerrado', total: 225, concluidas: 2, highlights: [] },
        { id: '901113377457', nome: 'Sprint 3', inicio: '2026-03-30', fim: '2026-04-05', status: 'encerrado', total: 230, concluidas: 0, highlights: [] },
        { id: 'sprint_4', nome: 'Sprint 4', inicio: '2026-04-06', fim: '2026-04-12', status: 'ativo', total: 0, concluidas: 0, highlights: [] },
        { id: 'sprint_5', nome: 'Sprint 5', inicio: '2026-04-13', fim: '2026-04-19', status: 'planejado', total: 0, concluidas: 0, highlights: [] },
      ],
      // Membros carregados de spalla_members via loadSpallaMembers()
      members: [],
      // Listas/sprints carregados de god_lists via loadGodLists()
      lists: [],
      ferramentas: [
        { nome: 'Hub CASE AI', desc: 'Central de agentes de IA — uso interno e mentorados', url: 'https://hub.caseai.com.br/', tags: ['ao vivo', 'ia'], status: 'live', falta: null, color: '#7c3aed' },
        { nome: 'Social CASE', desc: 'Calendário editorial + métricas das redes dos mentorados', url: 'http://social.caseai.com.br/', tags: ['beta'], status: 'beta', falta: 'Configurar acesso para mentorados', color: '#0ea5e9' },
        { nome: 'Funnel CASE', desc: 'Visualização e design dos funis da mentoria', url: 'https://funnelcase.vercel.app/', tags: ['beta'], status: 'beta', falta: 'Liberação para alunos', color: '#10b981' },
        { nome: 'PageOS', desc: 'Criação de páginas de captura e vendas', url: 'https://page-os-eta.vercel.app/', tags: ['beta'], status: 'beta', falta: 'Liberação para alunos', color: '#f59e0b' },
        { nome: 'Carousel AI', desc: 'Produção de carrosséis com IA', url: 'https://carousel-ai-production.up.railway.app/', tags: ['beta'], status: 'beta', falta: 'Liberação para alunos', color: '#ec4899' },
      ],
      ccData: null, // live data from ClickUp (populated by loadCommandCenterData)
    },

    // --- F2.5 — In-app notifications ---
    notifications: [],
    notificationsOpen: false,
    notificationsUnread: 0,

    // --- Financeiro (CFO Payments View) ---
    financeiro: null,
    finFilter: '',
    finNoteModal: { open: false, menteeId: null, menteeNome: '', text: '' },

    // --- Perfil Comportamental ---
    perfilForm: { json_raw: '', notas_texto: '', fonte: 'ai_claude', fonte_detalhes: '' },
    _perfilCharts: {},

    // --- Media Cache ---
    waMediaUrls: {},  // messageId → presigned URL

    // Task organization — loaded dynamically from god_spaces + god_lists + god_statuses
    spaces: [],
    allStatuses: [], // god_statuses rows

    // --- Task Type Icons ---
    TASK_TIPO_MAP: {
      geral:         { icon: '📋', label: 'Geral' },
      dossie:        { icon: '📑', label: 'Dossiê' },
      ajuste_dossie: { icon: '🔧', label: 'Ajuste dossiê' },
      follow_up:     { icon: '🔄', label: 'Follow-up' },
      rotina:        { icon: '📅', label: 'Rotina' },
      bug_report:    { icon: '🐛', label: 'Bug report' },
    },

    // --- Task Form ---
    taskForm: {
      titulo: '',
      descricao: '',
      responsavel: '',
      mentorado_nome: '',
      tipo: 'geral',
      notificarMentorado: false,
      // LF Story 4: espécie + campos relacionados
      especie: 'one_time',
      rrule: '',
      rrule_freq: 'DAILY',
      rrule_interval: 1,
      proxima_execucao: '',
      trigger_aggregate: '',
      trigger_event: '',
      trigger_filter: '',
      prioridade: 'normal',
      prazo: '', // this becomes data_fim
      data_inicio: '',
      data_fim: '',
      doc_link: '',
      subtasks: [],
      checklist: [],
      comments: [],
      attachments: [],
      tags: [],
      parent_task_id: null,
      acompanhante: '',
      space_id: 'space_atendimento',
      list_id: '',
      newSubtask: '',
      newCheckItem: '',
      newComment: '',
      newTag: '',
      recorrencia: 'nenhuma',
      dia_recorrencia: null,
      recorrencia_ativa: true,
      bloqueio_motivo: '',
      bloqueio_responsavel: '',
      context_ativo_ids: [],
      fieldValues: {},         // { fieldId: <value> } for custom fields
    },

    // --- Reminder Form ---
    reminderForm: {
      texto: '',
      data: '',
      prioridade: 'normal',
      mentorado_nome: '',
    },

    // --- Schedule Form ---
    scheduleForm: { mentorado: '', mentorado_id: '', tipo: 'acompanhamento', data: '', horario: '10:00', duracao: 60, email: '', convidados_extras: '', notas: '' },

    // --- Arquivos (Storage + Semantic Search) ---
    arquivos: {
      list: [],
      loading: false,            // Fix 3 — file list loading state
      searchResults: [],
      searchQuery: '',
      searchMode: 'hybrid',
      searchLoading: false,
      uploadLoading: false,
      storageOverview: [],
      queue: [],
      filterCategoria: '',
      filterEntidade: '',
      filterMentoradoId: '',
      filterDateFrom: '',
      filterDateTo: '',
      voyageConfigured: false,
      // 5.2 — Folder view
      viewMode: 'folders',       // 'folders' | 'folder_detail' | 'all'
      folders: [],               // from vw_arquivos_por_mentorado
      currentFolder: null,       // { mentorado_id, mentorado_nome } or null='geral' or { pasta_id, ... } for custom
      folderFiles: [],           // files for current folder
      folderFilesLoading: false,
      // 5.6 — Custom folders
      customFolders: [],         // from vw_pastas_overview
      showNewFolderForm: false,
      creatingFolder: false,
      newFolderForm: { nome: '', descricao: '', cor: '#6b7280', mentoradoId: null, mentoradoSearch: '', showMentoradoDropdown: false },
      editingFolder: null,       // folder object being edited, or null
      showEditFolderForm: false,
      moveFileTarget: null,      // file being moved, or null
      showMoveModal: false,
      folderColors: [
        { name: 'Cinza', hex: '#6b7280' },
        { name: 'Vermelho', hex: '#ef4444' },
        { name: 'Laranja', hex: '#f97316' },
        { name: 'Amarelo', hex: '#eab308' },
        { name: 'Verde', hex: '#22c55e' },
        { name: 'Azul', hex: '#3b82f6' },
        { name: 'Roxo', hex: '#8b5cf6' },
        { name: 'Rosa', hex: '#ec4899' },
      ],
      // 5.4 — Realtime
      processingCount: 0,
      uploadForm: {
        mentoradoId: null,
        mentoradoNome: '',
        mentoradoSearch: '',
        entidadeTipo: 'geral',
        descricao: '',
        pastaId: null,
        files: [],
        showModal: false,
        showMentoradoDropdown: false,
      },
      // Fix 9 — Pagination
      page: 1,
      pageSize: 50,
      // Fix 16 — Bulk select
      selectedIds: [],
    },
    // 5.4 — Realtime channel ref
    _arquivosChannel: null,
    // 5.5 — Detail mentorado arquivos
    _detailArquivos: [],
    _detailArquivosLoading: false,
    _detailArquivosSearch: '',

    // --- API Integration State ---
    _menteesWithEmail: [],
    _integrations: {},

    // --- Biblioteca ---
    bib: {
      docs: [],
      filtered: [],
      search: '',
      menteeFilter: '',
      tipoFilter: '',
      activeDoc: null,
      docLoading: false,
      loading: false,
      activeSec: null,
      renderedHtml: '',
      editMode: false,
      expandedMentees: {},
    },
    _pendingBibliotecaSlug: null,

    // --- Tool Status ---
    toolsStatus: [
      { id: 'hubcase',    name: 'HubCase',     url: 'https://hub.caseai.com.br',                      status: 'checking' },
      { id: 'socialcase', name: 'Social Case',  url: 'https://social.caseai.com.br',                   status: 'checking' },
      { id: 'funnelcase', name: 'FunnelCase',   url: 'https://funnelcase.vercel.app',                  status: 'checking' },
      { id: 'pageos',     name: 'PageOS',       url: 'https://page-os-eta.vercel.app',                 status: 'checking' },
      { id: 'carrossel',  name: 'Carrossel AI', url: 'https://carousel-ai-production.up.railway.app',  status: 'checking' },
    ],
    _toolsChecking: false,
    _toolsCheckedAt: null,

    // ===================== COMPUTED =====================

    get filteredMentees() {
      let list = [...this.data.mentees];
      if (this.ui.search) {
        const q = this.ui.search.toLowerCase();
        list = list.filter(m =>
          m.nome?.toLowerCase().includes(q) ||
          m.produto_nome?.toLowerCase().includes(q) ||
          m.instagram?.toLowerCase().includes(q)
        );
      }
      if (this.ui.filters.fase) list = list.filter(m => m.fase_jornada === this.ui.filters.fase);
      if (this.ui.filters.risco) list = list.filter(m => m.risco_churn === this.ui.filters.risco);
      if (this.ui.filters.cohort) list = list.filter(m => m.cohort === this.ui.filters.cohort);
      if (this.ui.filters.status === 'com_pendencia') {
        list = list.filter(m => (m.tarefas_atrasadas || 0) > 0 || (m.msgs_pendentes_resposta || 0) > 0);
      } else if (this.ui.filters.status === 'em_dia') {
        list = list.filter(m => (m.tarefas_atrasadas || 0) === 0 && (m.risco_churn === 'baixo' || m.risco_churn === 'medio'));
      } else if (this.ui.filters.status === 'sem_call') {
        list = list.filter(m => (m.dias_desde_call || 999) > 21);
      } else if (this.ui.filters.status === 'aguardando_resposta') {
        list = list.filter(m => (m.msgs_aguardando_resposta || 0) > 0);
      } else if (this.ui.filters.status === 'precisa_reforco') {
        list = list.filter(m => (m.msgs_para_reforcar || 0) > 0);
      } else if (this.ui.filters.status === 'risco_critico') {
        list = list.filter(m => m.risco_churn === 'critico' || m.risco_churn === 'alto');
      }
      if (this.ui.filters.financeiro === 'sem_contrato') {
        list = list.filter(m => m.contrato_assinado === false);
      } else if (this.ui.filters.financeiro === 'atrasado') {
        list = list.filter(m => m.status_financeiro === 'atrasado');
      } else if (this.ui.filters.financeiro === 'em_dia') {
        list = list.filter(m => m.status_financeiro === 'em_dia');
      } else if (this.ui.filters.financeiro === 'quitado') {
        list = list.filter(m => m.status_financeiro === 'quitado');
      }
      if (this.ui.filters.carteira) {
        list = list.filter(m => m.consultor_responsavel === this.ui.filters.carteira);
      }
      list.sort((a, b) => {
        let va = a[this.ui.sort], vb = b[this.ui.sort];
        if (typeof va === 'string') va = va?.toLowerCase() || '';
        if (typeof vb === 'string') vb = vb?.toLowerCase() || '';
        if (va == null) va = this.ui.sortDir === 'asc' ? 'zzz' : '';
        if (vb == null) vb = this.ui.sortDir === 'asc' ? 'zzz' : '';
        if (va < vb) return this.ui.sortDir === 'asc' ? -1 : 1;
        if (va > vb) return this.ui.sortDir === 'asc' ? 1 : -1;
        return 0;
      });
      return list;
    },

    get kpis() {
      const cohort = this.data.cohort;
      if (!cohort.length) return {};
      const totalMentorados = cohort.reduce((s, c) => s + (c.total_mentorados || 0), 0);
      const criticos = cohort.reduce((s, c) => s + (c.criticos || 0), 0);
      const altos = cohort.reduce((s, c) => s + (c.altos || 0), 0);
      const semContrato = this.data.mentees.filter(m => m.contrato_assinado === false).length;
      const pgtoAtrasado = this.data.mentees.filter(m => m.status_financeiro === 'atrasado').length;
      // Calculate calls in last 30 days from real call data
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      const calls30d = (this._supabaseCalls || []).filter(c => {
        if (!c.data_call) return false;
        return new Date(c.data_call + 'T12:00:00') >= thirtyDaysAgo;
      }).length;
      // Calculate pending tasks from board (god_tasks)
      const tarefasPendentes = this.data.tasks.filter(t => t.status === 'pendente' || t.status === 'em_andamento').length;
      // WhatsApp pending: card "Reforços pendentes" conta SÓ team→mentee (alinhado com a seção "Reforço & Compromissos").
      // Aguardando resposta (mentee→equipe) é contado separado e renderizado na própria seção.
      const msgsPendentes = (this.data.pendencias || []).filter(p => p.direcao === 'team_to_mentee').length;
      const msgsAguardando = (this.data.aguardandoResposta || []).length;
      const mentoradosCriticos = this.data.mentees.filter(m => (m.horas_sem_resposta_equipe || 0) > 24).length;
      return {
        totalMentorados,
        emDia: totalMentorados - criticos - altos,
        comPendencia: cohort[0]?.pending_responses_global || 0,
        riscoCritico: criticos + altos,
        calls30d,
        tarefasPendentes,
        semContrato,
        pgtoAtrasado,
        msgsPendentes,
        msgsAguardando,
        mentoradosCriticos,
        paEmExecucao: this.data.paPlanos.filter(p => p.status_geral === 'em_andamento').length,
        paParados: this.data.paPlanos.filter(p => p.status_geral === 'em_andamento' && (p.dias_sem_update || 0) > 14).length,
        paConcluidos: this.data.paPlanos.filter(p => p.status_geral === 'concluido').length,
      };
    },

    get phaseDistribution() {
      const order = ['onboarding', 'concepcao', 'validacao', 'otimizacao', 'escala'];
      return order.map(fase => {
        const c = this.data.cohort.find(x => x.fase === fase);
        return { fase, label: this.phaseLabel(fase), total: c?.total_mentorados || 0, criticos: c?.criticos || 0, altos: c?.altos || 0 };
      }).filter(p => p.total > 0);
    },

    get totalMenteesInPhases() {
      return this.phaseDistribution.reduce((s, p) => s + p.total, 0);
    },

    // Pendencias: sorted by priority
    // Card "Reforço & Compromissos" é EXCLUSIVAMENTE team→mentee.
    // Itens mentee→team da view vivem na seção "Aguardando Resposta" (fonte raw separada).
    // Sem este filtro, mensagens de mentee aparecem duplicadas em ambas as seções.
    get pendenciasList() {
      const prioOrder = { critico: 0, alto: 1, medio: 2, baixo: 3 };
      let list = (this.data.pendencias || []).filter(p => p.direcao === 'team_to_mentee');
      // Filtrar por consultor se filtro ativo
      const consultor = this.ui.filters?.carteira;
      if (consultor) {
        // Cruzar mentorado_id da pendência com consultor_responsavel do mentorado
        const menteeIds = new Set(
          (this.data.mentees || [])
            .filter(m => m.consultor_responsavel === consultor)
            .map(m => m.id)
        );
        list = list.filter(p => menteeIds.has(p.mentorado_id));
      }
      // Filtro de status: card de pendências é REFORÇO/COMPROMISSOS (vem da view com classifier)
      // "Aguardando resposta" tem card próprio (raw) — quando esse filtro está ativo, esse card oculta todos os itens
      const statusFilter = this.ui.filters?.status;
      if (statusFilter === 'aguardando_resposta') {
        return [];
      }
      // Sem filtro ou "precisa_reforco": mostra todos os itens da view
      return list.sort((a, b) => {
        return (prioOrder[a.prioridade_calculada] ?? 3) - (prioOrder[b.prioridade_calculada] ?? 3);
      });
    },

    pendenciasMinimized: false,
    pendenciasExpanded: false,

    get pendenciasVisible() {
      return this.pendenciasExpanded ? this.pendenciasList : this.pendenciasList.slice(0, 15);
    },

    // Aguardando Resposta — fonte raw (interacoes_mentoria), sem filtro do classifier
    aguardandoMinimized: false,
    aguardandoExpanded: false,

    get aguardandoRespostaList() {
      const prioOrder = { critico: 0, alto: 1, medio: 2, baixo: 3 };
      let list = [...(this.data.aguardandoResposta || [])];
      const consultor = this.ui.filters?.carteira;
      if (consultor) {
        const menteeIds = new Set(
          (this.data.mentees || [])
            .filter(m => m.consultor_responsavel === consultor)
            .map(m => m.id)
        );
        list = list.filter(p => menteeIds.has(p.mentorado_id));
      }
      // Espelha filtro de status do select
      const statusFilter = this.ui.filters?.status;
      if (statusFilter === 'precisa_reforco') {
        // Esse card é só pra aguardando — se filtro é reforço, esconde tudo
        return [];
      }
      return list.sort((a, b) => {
        return (prioOrder[a.prioridade_calculada] ?? 3) - (prioOrder[b.prioridade_calculada] ?? 3);
      });
    },

    get aguardandoRespostaVisible() {
      return this.aguardandoExpanded ? this.aguardandoRespostaList : this.aguardandoRespostaList.slice(0, 15);
    },

    formatHorasPendente(horas) {
      if (horas == null) return '-';
      if (horas < 1) return '<1h';
      if (horas < 24) return Math.round(horas) + 'h';
      return Math.round(horas / 24) + 'd ' + Math.round(horas % 24) + 'h';
    },

    urgenciaClass(prioridade) {
      const map = { critico: 'wa-urgencia--critico', alto: 'wa-urgencia--alto', medio: 'wa-urgencia--medio', baixo: 'wa-urgencia--baixo' };
      return map[prioridade] || 'wa-urgencia--baixo';
    },

    urgenciaLabel(prioridade) {
      const map = { critico: 'Crítico', alto: 'Alto', medio: 'Médio', baixo: 'Baixo' };
      return map[prioridade] || prioridade;
    },

    fonteLabel(fonte) {
      const map = {
        call_feedback: 'Call',
        extracao_ia: 'IA',
        direcionamento: 'Direcionamento',
        manual: 'Manual',
        tarefas_acordadas: 'Acordado',
        whatsapp: 'WhatsApp',
      };
      return map[fonte] || (fonte || '').replace(/_/g, ' ');
    },

    async markAsResponded(interacaoId) {
      const sb2 = await initSupabase();
      if (!sb2) return;
      const { error } = await sb2.from('interacoes_mentoria').update({ respondido: true }).eq('id', interacaoId);
      if (error) {
        this.toast('Erro ao marcar como respondido', 'error');
        console.error('[Spalla] markAsResponded error:', error);
        return;
      }
      // Remove de ambas fontes locais
      this.data.pendencias = this.data.pendencias.filter(p => p.interacao_id !== interacaoId);
      this.data.aguardandoResposta = (this.data.aguardandoResposta || []).filter(p => p.interacao_id !== interacaoId);
      this._reconcileMenteeCounters();
      this.toast('Mensagem marcada como respondida', 'success');
    },

    async markAllAsResponded() {
      const total = this.data.pendencias.length + (this.data.aguardandoResposta || []).length;
      if (!confirm('Marcar TODAS as ' + total + ' mensagens como respondidas?')) return;
      const sb2 = await initSupabase();
      if (!sb2) return;
      const ids = [
        ...this.data.pendencias.map(p => p.interacao_id),
        ...(this.data.aguardandoResposta || []).map(p => p.interacao_id),
      ];
      const { error } = await sb2.from('interacoes_mentoria').update({ respondido: true }).in('id', ids);
      if (error) {
        this.toast('Erro ao marcar mensagens', 'error');
        console.error('[Spalla] markAllAsResponded error:', error);
        return;
      }
      this.data.pendencias = [];
      this.data.aguardandoResposta = [];
      this.data.mentees = this.data.mentees.map(m => ({ ...m, msgs_pendentes_resposta: 0, msgs_aguardando_resposta: 0, msgs_para_reforcar: 0 }));
      this.toast('Todas as mensagens marcadas como respondidas', 'success');
    },

    // Helper: recalcula contadores derivados em todos os mentees a partir das 2 fontes
    _reconcileMenteeCounters() {
      const buckets = {};
      (this.data.pendencias || []).forEach(p => {
        if (!p.mentorado_id) return;
        const b = buckets[p.mentorado_id] || (buckets[p.mentorado_id] = { reforco: 0, aguardando: 0 });
        if (p.direcao === 'team_to_mentee') b.reforco += 1;
      });
      (this.data.aguardandoResposta || []).forEach(p => {
        if (!p.mentorado_id) return;
        const b = buckets[p.mentorado_id] || (buckets[p.mentorado_id] = { reforco: 0, aguardando: 0 });
        b.aguardando += 1;
      });
      this.data.mentees = this.data.mentees.map(m => {
        const b = buckets[m.id] || { reforco: 0, aguardando: 0 };
        return { ...m, msgs_pendentes_resposta: b.reforco + b.aguardando, msgs_aguardando_resposta: b.aguardando, msgs_para_reforcar: b.reforco };
      });
    },

    waBadgeClass(m) {
      const h = m.horas_sem_resposta_equipe || 0;
      if (h > 24) return 'mc-card__wa-badge--danger';
      if (h > 12) return 'mc-card__wa-badge--warning';
      return 'mc-card__wa-badge--success';
    },

    // ===================== HEALTH SCORE =====================

    calcHealthScore(m) {
      // Dim 1: Engagement WA (25%)
      let scoreWa = 0;
      const wa7d = m.whatsapp_7d || 0;
      if (wa7d >= 10) scoreWa = 100;
      else if (wa7d >= 5) scoreWa = 80;
      else if (wa7d >= 2) scoreWa = 50;
      else if (wa7d >= 1) scoreWa = 30;
      const hsr = m.horas_sem_resposta_equipe || 0;
      if (hsr > 48) scoreWa -= 40;
      else if (hsr > 24) scoreWa -= 20;
      else if (hsr > 12) scoreWa -= 10;
      scoreWa = Math.max(0, Math.min(100, scoreWa));

      // Dim 2: Frequencia Calls (20%)
      const dc = m.dias_desde_call ?? 999;
      let scoreCalls = dc <= 14 ? 100 : dc <= 21 ? 80 : dc <= 30 ? 50 : dc <= 45 ? 25 : 0;

      // Dim 3: Progresso Tarefas (20%)
      const scoreTarefas = Math.max(0, 100 - (m.tarefas_pendentes || 0) * 5 - (m.tarefas_atrasadas || 0) * 15);

      // Dim 4: Evolucao Vendas (15%)
      let scoreVendas = 20;
      const meta = m.meta_faturamento || 0;
      const fat = m.faturamento_atual || 0;
      if (meta > 0) {
        const pct = fat / meta;
        scoreVendas = pct >= 1 ? 100 : pct >= 0.5 ? 70 : pct >= 0.2 ? 40 : 10;
      } else if (m.ja_vendeu) {
        scoreVendas = 60;
      }

      // Dim 5: Implementacao (10%)
      const scoreImpl = Math.min(100, Math.max(0, Math.round(
        (m.engagement_score || 50) * 0.5 + (m.implementation_score || 50) * 0.5
      )));

      // Dim 6: Financeiro (10%)
      let scoreFin = 50;
      if (m.contrato_assinado && ['em_dia', 'quitado', 'pago'].includes(m.status_financeiro)) scoreFin = 100;
      else if (m.contrato_assinado && m.status_financeiro === 'atrasado') scoreFin = 40;
      else if (m.contrato_assinado === false) scoreFin = 20;

      const total = Math.round(
        scoreWa * 0.25 + scoreCalls * 0.20 + scoreTarefas * 0.20 +
        scoreVendas * 0.15 + scoreImpl * 0.10 + scoreFin * 0.10
      );

      return {
        total,
        breakdown: {
          'WhatsApp': { score: Math.round(scoreWa * 0.25), max: 25 },
          'Calls': { score: Math.round(scoreCalls * 0.20), max: 20 },
          'Tarefas': { score: Math.round(scoreTarefas * 0.20), max: 20 },
          'Vendas': { score: Math.round(scoreVendas * 0.15), max: 15 },
          'Implementação': { score: Math.round(scoreImpl * 0.10), max: 10 },
          'Financeiro': { score: Math.round(scoreFin * 0.10), max: 10 },
        },
        color: total >= 80 ? 'success' : total >= 50 ? 'warning' : 'danger',
      };
    },

    // ===================== SHARED HELPERS =====================

    get currentUserName() {
      return this.auth.currentUser?.full_name || this.auth.currentUser?.email || 'Sistema';
    },

    get myCarteira() {
      const name = (this.auth.currentUser?.full_name || '').toLowerCase();
      if (name.includes('lara')) return 'Lara';
      if (name.includes('heitor')) return 'Heitor';
      return null;
    },

    // ===================== FINANCEIRO (CFO Payments View) =====================
    get isCfoUser() {
      const email = (this.auth.currentUser?.email || '').toLowerCase();
      const name = (this.auth.currentUser?.full_name || '').toLowerCase();
      return email.includes('cfo') || name.includes('cfo') || email.includes('financeiro') || name.includes('kaique') || name.includes('gobbi');
    },

    get filteredFinanceiro() {
      if (!this.financeiro?.mentorados) return [];
      let list = this.financeiro.mentorados;
      if (this.finFilter) {
        list = list.filter(m => m.status_financeiro === this.finFilter);
      }
      return list;
    },

    finStatusLabel(status) {
      const map = { em_dia: 'Em Dia', atrasado: 'Inadimplente', quitado: 'Quitado', sem_contrato: 'Sem Contrato' };
      return map[status] || status || '—';
    },

    finStatusColor(status) {
      const map = { em_dia: '#22c55e', atrasado: '#ef4444', quitado: '#3b82f6', sem_contrato: '#f59e0b' };
      return map[status] || '#9ca3af';
    },

    finTimeAgo(dateStr) {
      if (!dateStr) return '—';
      const diff = Date.now() - new Date(dateStr).getTime();
      const days = Math.floor(diff / 86400000);
      if (days === 0) return 'Hoje';
      if (days === 1) return 'Ontem';
      if (days < 30) return `${days}d atrás`;
      return new Date(dateStr).toLocaleDateString('pt-BR');
    },

    async loadFinanceiro() {
      try {
        const sb = await initSupabase();
        const [{ data: mentorados }, { data: snapshots }, { data: logs }] = await Promise.all([
          sb.from('vw_god_financeiro').select('*'),
          sb.from('vw_fin_snapshots').select('*').order('created_at', { ascending: false }).limit(90),
          sb.from('fin_pagamento_logs').select('*').order('created_at', { ascending: false }).limit(200),
        ]);
        const kpis = {
          em_dia: mentorados.filter(m => ['em_dia', 'pago'].includes(m.status_financeiro)).length,
          atrasado: mentorados.filter(m => m.status_financeiro === 'atrasado').length,
          quitado: mentorados.filter(m => m.status_financeiro === 'quitado').length,
          sem_contrato: mentorados.filter(m => !m.contrato_assinado).length,
        };
        this.financeiro = { mentorados, snapshots, logs, kpis };
      } catch (e) {
        console.error('[Spalla] loadFinanceiro error:', e);
      }
    },

    async updateMenteeFinField(field, value) {
      const menteeId = this.ui.selectedMenteeId;
      if (!sb || !menteeId) return;
      // Campos financeiros vivem em case_archives.mentorados_financeiro — usa RPC
      const { data: res, error } = await sb.rpc('fn_update_mentorado_financeiro', {
        p_mentorado_id: menteeId,
        p_field: field,
        p_value: String(value),
      });
      if (error || res?.error) { this.toast('Erro: ' + (error?.message || res?.error), 'error'); return; }
      // Update local state
      if (this.data.detail?.financial) this.data.detail.financial[field] = value;
      if (this.data.detail?.profile) this.data.detail.profile[field] = value;
    },

    async changeFinStatus(menteeId, newStatus, observacao) {
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/financeiro/status`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
          body: JSON.stringify({ mentorado_id: menteeId, status: newStatus, observacao }),
        });
        if (res.ok) {
          this.toast('Status financeiro atualizado', 'success');
          await this.loadFinanceiro();
          await this.loadFinDetailLogs();
        } else {
          this.toast('Erro ao atualizar status financeiro', 'error');
          await this.loadFinanceiro();
        }
      } catch (e) {
        console.error('[Spalla] changeFinStatus error:', e);
        this.toast('Erro ao atualizar status financeiro', 'error');
      }
    },

    async addFinNote() {
      if (!this.finNoteModal.menteeId || !this.finNoteModal.text.trim()) return;
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/financeiro/nota`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
          body: JSON.stringify({ mentorado_id: this.finNoteModal.menteeId, observacao: this.finNoteModal.text.trim() }),
        });
        if (res.ok) {
          this.finNoteModal = { open: false, menteeId: null, menteeNome: '', text: '' };
          this.toast('Observacao adicionada', 'success');
          await this.loadFinDetailLogs();
        } else {
          this.toast('Erro ao salvar observacao', 'error');
        }
      } catch (e) {
        console.error('[Spalla] addFinNote error:', e);
      }
    },

    async loadFinDetailLogs() {
      if (!this.ui.selectedMenteeId) return;
      this.ui.finDetailLoading = true;
      try {
        const sb = await initSupabase();
        const { data } = await sb.from('fin_pagamento_logs')
          .select('*')
          .eq('mentorado_id', this.ui.selectedMenteeId)
          .order('created_at', { ascending: false });
        this.data.finDetailLogs = data || [];
      } catch (e) {
        console.error('[Spalla] loadFinDetailLogs error:', e);
      } finally {
        this.ui.finDetailLoading = false;
      }
    },

    async loadMenteeFinDetail(id) {
      await this.loadMenteeDetail(id);
      this.ui.activeDetailTab = 'financeiro';
      await this.loadFinDetailLogs();
    },

    get myCarteira() {
      const name = (this.auth.currentUser?.full_name || '').toLowerCase();
      if (name.includes('lara')) return 'Lara';
      if (name.includes('heitor')) return 'Heitor';
      return null;
    },

    todayStr() { return new Date().toISOString().split('T')[0]; },

    // Sort: date ASC (no-date at bottom), then priority as tiebreak
    _taskSortFn(a, b) {
      const prio = { urgente: 0, alta: 1, normal: 2, baixa: 3 };
      const da = parseDateStr(a.data_fim || a.prazo);
      const db = parseDateStr(b.data_fim || b.prazo);
      if (da && db) {
        const diff = da - db;
        if (diff !== 0) return diff;
        return (prio[a.prioridade] ?? 2) - (prio[b.prioridade] ?? 2);
      }
      if (da && !db) return -1;
      if (!da && db) return 1;
      return (prio[a.prioridade] ?? 2) - (prio[b.prioridade] ?? 2);
    },

    // Distinct mentorado names from tasks (for filter dropdown)
    taskMentoradoOptions() {
      const names = new Set();
      for (const t of this.data.tasks) {
        if (t.mentorado_nome && t.mentorado_nome.trim()) names.add(t.mentorado_nome.trim());
      }
      return [...names].sort();
    },

    _filterTasks(tasks) {
      let list = tasks;
      if (this.ui.taskAssignee) {
        if (this.ui.taskAssignee === '__mine__') {
          const me = (this.auth.currentUser?.full_name || '').toLowerCase();
          if (me) list = list.filter(t => t.responsavel?.toLowerCase().includes(me));
        } else if (this.ui.taskAssignee.startsWith('mentee:')) {
          // Filter by specific mentorado name
          const menteeName = this.ui.taskAssignee.slice(7); // remove "mentee:" prefix
          list = list.filter(t => t.mentorado_nome === menteeName);
        } else {
          // Filter by team member (responsavel)
          const assignee = this.ui.taskAssignee.toLowerCase();
          list = list.filter(t => t.responsavel?.toLowerCase().includes(assignee));
        }
      }
      if (this.ui.taskSpaceFilter !== 'all') {
        list = list.filter(t => t.space_id === this.ui.taskSpaceFilter);
      }
      if (this.ui.taskListFilter !== 'all') {
        list = list.filter(t => t.list_id === this.ui.taskListFilter);
      }
      if (this.ui.taskSprintFilter !== 'all') {
        list = list.filter(t => t.sprint_id === this.ui.taskSprintFilter);
      }
      if (this.ui.taskTagFilter.length) {
        list = list.filter(t => {
          const taskTagIds = (t.tags || []).map(tg => tg.id).filter(Boolean);
          return this.ui.taskTagFilter.some(tagId => taskTagIds.includes(tagId));
        });
      }
      // Date range filter (ClickUp-style)
      const df = this.ui.taskDateFilter;
      if (df && df !== 'all') {
        const todayStart = new Date(); todayStart.setHours(0, 0, 0, 0);
        const todayEnd   = new Date(); todayEnd.setHours(23, 59, 59, 999);
        if (df === 'no_date') {
          list = list.filter(t => !t.data_fim && !t.prazo);
        } else if (df === 'overdue') {
          list = list.filter(t => {
            const due = parseDateStr(t.data_fim || t.prazo);
            return due && due < todayStart && t.status !== 'concluida';
          });
        } else {
          const days = df === 'today' ? 0 : df === 'next7' ? 7 : 30;
          const rangeEnd = new Date(todayStart); rangeEnd.setDate(rangeEnd.getDate() + days); rangeEnd.setHours(23, 59, 59, 999);
          list = list.filter(t => {
            const due = parseDateStr(t.data_fim || t.prazo);
            return due && due >= todayStart && due <= rangeEnd;
          });
        }
      }
      // Tipo filter
      if (this.ui.taskTipoFilter) {
        list = list.filter(t => (t.tipo || 'geral') === this.ui.taskTipoFilter);
      }
      return list;
    },

    taskTipoIcon(tipo) {
      return (this.TASK_TIPO_MAP[tipo] || this.TASK_TIPO_MAP.geral).icon;
    },

    taskTipoLabel(tipo) {
      return (this.TASK_TIPO_MAP[tipo] || this.TASK_TIPO_MAP.geral).label;
    },

    _debounce(timerKey, fn, delay = 500) {
      clearTimeout(this[timerKey]);
      this[timerKey] = setTimeout(() => fn(), delay);
    },

    _debouncedLoadObData() { this._debounce('_obDebounceTimer', () => this.loadObData()); },
    _debouncedLoadDsData() { this._debounce('_dsDebounceTimer', () => this.loadDsData()); },
    _debouncedLoadPaPipeline() { this._debounce('_paDebounceTimer', () => this.loadPaPipeline()); },

    // ===================== TEAM DASHBOARD =====================

    get teamStats() {
      const members = this.data.members?.length
        ? this.data.members.map(m => ({ name: m.nome_curto || m.nome_completo, id: m.id }))
        : TEAM_MEMBERS;
      return members.map(member => {
        const mName = member.name.toLowerCase();
        const myTasks = this.data.tasks.filter(t => t.responsavel?.toLowerCase().includes(mName));
        const pendentes = myTasks.filter(t => t.status === 'pendente').length;
        const emAndamento = myTasks.filter(t => t.status === 'em_andamento').length;
        const atrasadas = myTasks.filter(t =>
          t.status === 'pendente' && t.data_fim && parseDateStr(t.data_fim) < SYSTEM_TODAY()
        ).length;
        const week = new Date(); week.setDate(week.getDate() - 7);
        const concluidas7d = myTasks.filter(t => {
          if (t.status !== 'concluida' || !t.updated_at) return false;
          return new Date(t.updated_at) >= week;
        }).length;
        const mentorados = [...new Set(myTasks.map(t => t.mentorado_nome).filter(Boolean))].length;
        const carga = Math.min(Math.round((pendentes + emAndamento) / 20 * 100), 100);
        return {
          name: member.name,
          id: member.id,
          pendentes, emAndamento, atrasadas, concluidas7d, mentorados, carga,
          cargaStatus: carga >= 85 ? 'danger' : carga >= 60 ? 'warning' : 'success',
        };
      });
    },

    // ===================== RECURRING TASKS =====================

    async _checkRecurringTasks() {
      const recurring = this.data.tasks.filter(t =>
        t.recorrencia && t.recorrencia !== 'nenhuma' &&
        t.recorrencia_ativa !== false &&
        t.status === 'concluida'
      );
      for (const task of recurring) {
        const nextDate = this._calcNextOccurrence(task);
        if (!nextDate) continue;
        const originId = task.recorrencia_origem_id || task.id;
        const exists = this.data.tasks.find(t =>
          (t.recorrencia_origem_id === originId || t.id === originId) &&
          t.status === 'pendente' && t.id !== task.id
        );
        if (exists) continue;
        const newId = crypto.randomUUID ? crypto.randomUUID() : 'task_' + Date.now();
        const newTask = {
          id: newId,
          titulo: task.titulo,
          descricao: task.descricao,
          responsavel: task.responsavel,
          mentorado_nome: task.mentorado_nome,
          mentorado_id: task.mentorado_id,
          prioridade: task.prioridade,
          space_id: task.space_id,
          list_id: task.list_id,
          tags: task.tags || [],
          recorrencia: task.recorrencia,
          dia_recorrencia: task.dia_recorrencia,
          recorrencia_origem_id: originId,
          data_inicio: nextDate,
          data_fim: nextDate,
          status: 'pendente',
          fonte: 'recorrencia',
          comments: [], attachments: [], handoffs: [], subtasks: [], checklist: [],
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        };
        this.data.tasks.push(newTask);
        this._sbUpsertTask(newTask, true);
        this._cacheTasksLocal();
      }
    },

    _calcNextOccurrence(task) {
      const completed = task.updated_at ? new Date(task.updated_at) : new Date();
      switch (task.recorrencia) {
        case 'diario': {
          const n = new Date(completed);
          n.setDate(n.getDate() + 1);
          while (n.getDay() === 0 || n.getDay() === 6) n.setDate(n.getDate() + 1);
          return n.toISOString().split('T')[0];
        }
        case 'semanal': {
          const day = task.dia_recorrencia ?? completed.getDay();
          const n = new Date(completed);
          n.setDate(n.getDate() + ((7 + day - n.getDay()) % 7 || 7));
          return n.toISOString().split('T')[0];
        }
        case 'quinzenal': {
          const day = task.dia_recorrencia ?? completed.getDay();
          const n = new Date(completed);
          n.setDate(n.getDate() + 7 + ((7 + day - n.getDay()) % 7 || 7));
          return n.toISOString().split('T')[0];
        }
        case 'mensal': {
          const dayOfMonth = task.dia_recorrencia ?? completed.getDate();
          const n = new Date(completed);
          n.setMonth(n.getMonth() + 1);
          const lastDay = new Date(n.getFullYear(), n.getMonth() + 1, 0).getDate();
          n.setDate(Math.min(dayOfMonth, lastDay));
          return n.toISOString().split('T')[0];
        }
        default: return null;
      }
    },

    recorrenciaLabel(r) {
      return { diario: 'Diária', semanal: 'Semanal', quinzenal: 'Quinzenal', mensal: 'Mensal' }[r] || '';
    },

    async toggleRecorrencia(taskId) {
      const task = this.data.tasks.find(t => t.id === taskId);
      if (!task) return;
      const newVal = !(task.recorrencia_ativa ?? true);
      task.recorrencia_ativa = newVal;
      await this.updateTaskField(taskId, 'recorrencia_ativa', newVal);
      this.toast(newVal ? 'Recorrência reativada' : 'Recorrência pausada', 'info');
    },

    // Kanban: group mentees by phase
    menteesByPhase(fase) {
      const base = this.ui.filters.carteira
        ? this.data.mentees.filter(m => m.consultor_responsavel === this.ui.filters.carteira)
        : this.data.mentees;
      return base.filter(m => m.fase_jornada === fase);
    },

    // Kanban drag-and-drop: move mentorado between phases
    dragMentee(e, menteeId, fromFase) {
      e.dataTransfer.setData('text/plain', JSON.stringify({ menteeId, fromFase }));
      e.dataTransfer.effectAllowed = 'move';
      e.target.classList.add('kanban-card--dragging');
    },

    async dropMenteeToPhase(e, targetFase) {
      const raw = e.dataTransfer.getData('text/plain');
      if (!raw) return;
      let payload;
      try { payload = JSON.parse(raw); } catch { return; }
      const { menteeId, fromFase } = payload;
      if (fromFase === targetFase) return;

      const mentee = this.data.mentees.find(m => m.id === menteeId);
      if (!mentee) return;

      // Optimistic update
      const oldFase = mentee.fase_jornada;
      mentee.fase_jornada = targetFase;

      try {
        const client = sb || await initSupabase();
        if (!client) throw new Error('Supabase não disponível');
        sb = client;
        const { error } = await client.from('mentorados')
          .update({ fase_jornada: targetFase })
          .eq('id', menteeId);

        if (error) throw error;

        this.toast(`${mentee.nome}: ${this.phaseLabel(oldFase)} → ${this.phaseLabel(targetFase)}`, 'success');

        // Wave 2 F2.1: Generate phase tasks on phase change
        const templates = this.PHASE_TASK_TEMPLATES[targetFase?.toLowerCase()];
        if (templates?.length) {
          const confirmGenerate = window.confirm(`Gerar ${templates.length} tarefas padrão para a fase ${this.formatPhaseLabel(targetFase)}?`);
          if (confirmGenerate) {
            try {
              const generated = await this.generatePhaseTasks(menteeId, targetFase);
              if (generated > 0) {
                this.toast(`${generated} tarefas geradas para fase ${this.formatPhaseLabel(targetFase)}`, 'success');
                await this.loadTasks();
              }
            } catch (taskErr) {
              console.warn('[Spalla] generatePhaseTasks (kanban):', taskErr.message);
              this.toast('Erro ao gerar tarefas da fase', 'error');
            }
          }
        }
      } catch (err) {
        // Rollback
        mentee.fase_jornada = oldFase;
        this.toast(`Erro ao mover ${mentee.nome}: ${err.message}`, 'error');
      }
    },

    // Wave 2 F2.1: Generate tasks from phase templates
    formatPhaseLabel(fase) {
      return {
        onboarding: 'Onboarding', concepcao: 'Concepção', validacao: 'Validação',
        otimizacao: 'Otimização', escala: 'Escala',
        execucao: 'Execução', resultado: 'Resultado', renovacao: 'Renovação', encerrado: 'Encerrado',
      }[fase] || fase || '-';
    },

    async generatePhaseTasks(menteeId, newPhase) {
      const templates = this.PHASE_TASK_TEMPLATES[newPhase?.toLowerCase()];
      if (!templates?.length || !menteeId || !sb) return 0;
      // Preflight: skip titles already present for this mentee+phase to avoid duplicates
      const { data: existing, error: fetchErr } = await sb
        .from('god_tasks')
        .select('titulo')
        .eq('mentorado_id', menteeId)
        .eq('fase_origem', newPhase);
      if (fetchErr) throw fetchErr;
      const existingTitles = new Set((existing || []).map(t => t.titulo));
      const newTasks = templates
        .filter(t => !existingTitles.has(t.titulo))
        .map(t => ({
          mentorado_id: menteeId,
          titulo: t.titulo,
          descricao: t.descricao,
          prioridade: t.prioridade,
          status: 'pendente',
          fase_origem: newPhase,
        }));
      if (!newTasks.length) return 0;
      const { error } = await sb.from('god_tasks').insert(newTasks);
      if (error) throw error;
      return newTasks.length;
    },

    // Tasks: filtered
    get filteredTasks() {
      let list = [...this.data.tasks];
      if (this.ui.taskFilter !== 'all') {
        if (this.ui.taskFilter === 'atrasada') {
          list = list.filter(t => t.status === 'pendente' && (t.data_fim || t.prazo) && parseDateStr(t.data_fim || t.prazo) < SYSTEM_TODAY());
        } else {
          list = list.filter(t => t.status === this.ui.taskFilter);
        }
      }
      list = this._filterTasks(list);
      // Quick filter (Dragon 39)
      if (this.quickFilter) {
        const me = (this.auth?.currentUser?.user_metadata?.full_name || this.auth?.currentUser?.full_name || this.auth?.currentUser?.email || '').toLowerCase().split(' ')[0];
        const now = new Date();
        const weekEnd = new Date(now); weekEnd.setDate(now.getDate() + 7);
        if (this.quickFilter === 'mine') list = list.filter(t => t.responsavel && me && t.responsavel.toLowerCase().includes(me));
        else if (this.quickFilter === 'overdue') list = list.filter(t => t.data_fim && new Date(t.data_fim) < now && t.status !== 'concluida');
        else if (this.quickFilter === 'unassigned') list = list.filter(t => !t.responsavel);
        else if (this.quickFilter === 'thisWeek') list = list.filter(t => t.data_fim && new Date(t.data_fim) >= now && new Date(t.data_fim) <= weekEnd);
        else if (this.quickFilter === 'favorites') list = list.filter(t => this.favorites.includes(t.id));
        else if (this.quickFilter === 'recurring') list = list.filter(t => t.recorrencia && t.recorrencia !== 'nenhuma');
      }
      if (this.ui.search && this.ui.page === 'tasks') {
        const q = this.ui.search.toLowerCase();
        list = list.filter(t => t.titulo?.toLowerCase().includes(q) || t.mentorado_nome?.toLowerCase().includes(q) || t.responsavel?.toLowerCase().includes(q));
      }
      list.sort(this._taskSortFn.bind(this));
      return list.slice(0, 500);
    },

    // Tasks: tree view — flat array with _depth metadata for list view
    get tasksTree() {
      const filtered = this.filteredTasks;
      const allTasks = this.data.tasks;
      const result = [];

      // Index child tasks by parent_task_id
      const childTasksByParent = {};
      for (const t of allTasks) {
        if (t.parent_task_id) {
          if (!childTasksByParent[t.parent_task_id]) childTasksByParent[t.parent_task_id] = [];
          childTasksByParent[t.parent_task_id].push(t);
        }
      }

      for (const task of filtered) {
        // Skip tasks that are children (they show under their parent)
        if (task.parent_task_id) continue;

        const subtaskCount = (task.subtasks || []).length;
        const childTasks = childTasksByParent[task.id] || [];
        const checklistCount = (task.checklist || []).length;
        const totalChildren = subtaskCount + childTasks.length + checklistCount;

        result.push({ ...task, _depth: 0, _childCount: totalChildren, _currentGroup: 'all', _isGroupLast: false });

        if (this.ui.taskExpandedIds[task.id] && totalChildren > 0) {
          // 1) Child tasks (real god_tasks with parent_task_id)
          for (const child of childTasks) {
            const grandchildren = (child.subtasks || []).length + (childTasksByParent[child.id] || []).length;
            result.push({ ...child, _depth: 1, _childCount: grandchildren, _isChildTask: true, _parentId: task.id, _currentGroup: 'all', _isGroupLast: false });
          }
          // 2) Inline subtasks
          (task.subtasks || []).forEach((sub, idx) => {
            result.push({
              id: sub.id || ('sub_' + task.id + '_' + idx),
              titulo: sub.text || '',
              status: sub.status || (sub.done ? 'concluida' : 'pendente'),
              prioridade: sub.prioridade || 'normal',
              responsavel: sub.responsavel || '',
              acompanhante: null, mentorado_nome: null,
              data_inicio: sub.data_inicio || null,
              data_fim: sub.data_fim || null, prazo: sub.data_fim || null,
              tags: [], is_blocked: false, recorrencia: 'nenhuma',
              _depth: 1, _childCount: 0, _isSubtask: true, _parentId: task.id, _subIdx: idx, _currentGroup: 'all', _isGroupLast: false,
            });
          });
          // 3) Checklist items
          (task.checklist || []).forEach((ci, idx) => {
            result.push({
              id: 'check_' + task.id + '_' + idx,
              titulo: '☐ ' + (ci.text || ''),
              status: ci.done ? 'concluida' : 'pendente',
              prioridade: 'normal',
              responsavel: ci.assignee || '',
              acompanhante: null, mentorado_nome: null,
              data_inicio: null, data_fim: ci.due_date || null, prazo: ci.due_date || null,
              tags: [], is_blocked: false, recorrencia: 'nenhuma',
              _depth: 1, _childCount: 0, _isChecklist: true, _parentId: task.id, _checkIdx: idx, _currentGroup: 'all', _isGroupLast: false,
            });
          });
        }
      }

      // Insert group headers based on groupBy
      const groupBy = this.ui.taskGroupBy;
      if (groupBy) {
        const grouped = {};
        const groupOrder = [];
        for (const item of result) {
          if (item._depth > 0) continue; // Group only top-level
          let key;
          if (groupBy === 'assignee') key = item.responsavel || 'Sem responsavel';
          else if (groupBy === 'priority') key = item.prioridade || 'normal';
          else if (groupBy === 'list') key = this.getListName(item.list_id) || 'Sem lista';
          else if (groupBy === 'mentorado') key = item.mentorado_nome || 'Sem mentorado';
          else if (groupBy === 'date') {
            const due = item.data_fim || item.prazo;
            if (!due) { key = 'sem_data'; }
            else {
              const d = new Date(due + 'T00:00:00');
              const today = new Date(); today.setHours(0,0,0,0);
              const diff = Math.round((d - today) / 86400000);
              if (diff < 0) key = 'em_atraso';
              else if (diff === 0) key = 'hoje';
              else if (diff === 1) key = 'amanha';
              else if (diff <= 7) key = d.toLocaleDateString('pt-BR', { weekday: 'long' }).replace(/^\w/, c => c.toUpperCase());
              else key = 'futuro';
            }
          }
          else key = item.status || 'pendente';
          if (!grouped[key]) { grouped[key] = []; groupOrder.push(key); }
          grouped[key].push(item);
        }
        // Build with headers
        const childItems = result.filter(r => r._depth > 0);
        const finalResult = [];
        // For status, use a fixed order
        const keys = groupBy === 'status' ? ['pendente', 'em_andamento', 'concluida'].filter(k => grouped[k]) :
                     groupBy === 'priority' ? ['urgente', 'alta', 'normal', 'baixa'].filter(k => grouped[k]) :
                     groupBy === 'date' ? ['em_atraso', 'hoje', 'amanha'].concat(groupOrder.filter(k => !['em_atraso','hoje','amanha','futuro','sem_data'].includes(k))).concat(['futuro', 'sem_data']).filter(k => grouped[k]) :
                     groupOrder;
        // Add any keys not in the fixed order
        for (const k of groupOrder) { if (!keys.includes(k)) keys.push(k); }
        for (const key of keys) {
          const items = grouped[key] || [];
          if (!items.length) continue;
          const dateLabels = { em_atraso: 'Em atraso', hoje: 'Hoje', amanha: 'Amanha', futuro: 'Futuro', sem_data: 'Sem data' };
          const label = groupBy === 'status' ? this.statusLabel(key) :
                        groupBy === 'priority' ? this.priorityLabel(key) :
                        groupBy === 'date' ? (dateLabels[key] || key) :
                        key ? key.charAt(0).toUpperCase() + key.slice(1) : 'Sem responsavel';
          finalResult.push({ id: 'group_' + key, _isGroupHeader: true, _groupLabel: label, _groupKey: key, _groupBy: groupBy, _groupCount: items.length, _depth: 0 });
          for (let idx = 0; idx < items.length; idx++) {
            const item = items[idx];
            item._currentGroup = key;
            item._isGroupLast = (idx === items.length - 1);
            finalResult.push(item);
            for (const child of childItems) {
              if (child._parentId === item.id) { child._currentGroup = key; finalResult.push(child); }
            }
          }
        }
        return finalResult;
      }

      // Mark last top-level item for "+ Adicionar Tarefa" button
      const topLevel = result.filter(t => t._depth === 0);
      if (topLevel.length) topLevel[topLevel.length - 1]._isGroupLast = true;

      return result;
    },

    // Group label helpers for task list headers
    statusLabel(s) { return { pendente: 'A Fazer', em_andamento: 'Em Progresso', concluida: 'Concluído' }[s] || s; },
    priorityLabel(p) { return { urgente: 'Urgente', alta: 'Alta', normal: 'Normal', baixa: 'Baixa' }[p] || p; },
    groupHeaderColor(groupBy, key) {
      if (groupBy === 'status') return { pendente: '#64748b', em_andamento: '#2563eb', concluida: '#16a34a' }[key] || '#64748b';
      if (groupBy === 'priority') return { urgente: '#dc2626', alta: '#ea580c', normal: '#64748b', baixa: '#94a3b8' }[key] || '#64748b';
      if (groupBy === 'date') return { em_atraso: '#dc2626', hoje: '#d97706', amanha: '#2563eb', futuro: '#64748b', sem_data: '#94a3b8' }[key] || '#8b6f47';
      return '#8b6f47';
    },

    // Tasks: grouped by status (ClickUp style board)
    // Board columns — respects groupBy selection
    get boardColumns() {
      const groupBy = this.ui.taskGroupBy;
      if (groupBy === 'priority') return [
        { key: 'urgente', label: 'Urgente', color: '#dc2626' },
        { key: 'alta', label: 'Alta', color: '#ea580c' },
        { key: 'normal', label: 'Normal', color: '#64748b' },
        { key: 'baixa', label: 'Baixa', color: '#94a3b8' },
      ];
      if (groupBy === 'assignee') {
        const names = new Set();
        this.data.tasks.forEach(t => { if (t.responsavel) names.add(t.responsavel); });
        const cols = [...names].sort().map(n => ({ key: n, label: n.charAt(0).toUpperCase() + n.slice(1), color: '#8b6f47' }));
        cols.push({ key: '', label: 'Sem responsavel', color: '#94a3b8' });
        return cols;
      }
      if (groupBy === 'list') {
        const lists = new Set();
        this.data.tasks.forEach(t => { lists.add(t.list_id || ''); });
        return [...lists].map(id => ({ key: id, label: this.getListName(id) || id || 'Sem lista', color: '#8b6f47' }));
      }
      // Default: status — use god_statuses if available, else fallback
      const spaceFilter = this.ui.taskSpaceFilter;
      const spaceStatuses = (this.allStatuses || [])
        .filter(s => spaceFilter === 'all' || s.space_id === spaceFilter)
        .filter(s => s.status_group !== 'closed');
      if (spaceStatuses.length) {
        // Dedupe by name (when "all" spaces, same name appears per space)
        const seen = new Set();
        return spaceStatuses.filter(s => {
          if (seen.has(s.name)) return false;
          seen.add(s.name);
          return true;
        }).map(s => ({
          key: s.name.toLowerCase().replace(/\s+/g, '_').normalize('NFD').replace(/[\u0300-\u036f]/g, ''),
          statusId: s.id,
          label: s.name,
          color: s.color || '',
          statusGroup: s.status_group,
        }));
      }
      return [
        { key: 'pendente', label: 'A Fazer', color: '#94a3b8' },
        { key: 'em_andamento', label: 'Em Progresso', color: '#f59e0b' },
        { key: 'concluida', label: 'Concluido', color: '#22c55e' },
      ];
    },

    get tasksByStatus() {
      const groupBy = this.ui.taskGroupBy;
      const columns = this.boardColumns;
      const result = {};
      const q = (this.ui.search || '').toLowerCase();
      for (const col of columns) {
        let list = [...this.data.tasks];
        // Filter by the group key
        if (groupBy === 'priority') list = list.filter(t => (t.prioridade || 'normal') === col.key);
        else if (groupBy === 'assignee') list = list.filter(t => (t.responsavel || '') === col.key);
        else if (groupBy === 'list') list = list.filter(t => (t.list_id || '') === col.key);
        else list = list.filter(t => t.status === col.key);
        list = this._filterTasks(list);
        if (q) list = list.filter(t => t.titulo?.toLowerCase().includes(q) || t.mentorado_nome?.toLowerCase().includes(q) || t.responsavel?.toLowerCase().includes(q));
        list.sort(this._taskSortFn.bind(this));
        result[col.key] = list.slice(0, 200);
      }
      return result;
    },

    // Task KPIs for current user
    get myTaskKpis() {
      const myName = (this.auth.currentUser?.full_name || '').toLowerCase();
      if (!myName) return { pendentes: 0, emAndamento: 0, total: this.data.tasks.length };
      const myTasks = this.data.tasks.filter(t => t.responsavel?.toLowerCase().includes(myName));
      return {
        pendentes: myTasks.filter(t => t.status === 'pendente').length,
        emAndamento: myTasks.filter(t => t.status === 'em_andamento').length,
        total: this.data.tasks.length,
      };
    },

    // Check if task belongs to current user
    isMyTask(t) {
      const myName = (this.auth.currentUser?.full_name || '').toLowerCase();
      return myName && t.responsavel?.toLowerCase().includes(myName);
    },

    // Detail view: tasks for this specific mentee
    get detailTasksDela() {
      const nome = this.data.detail?.profile?.nome?.toLowerCase();
      if (!nome) return [];
      const firstName = nome.split(' ')[0];
      return this.data.tasks.filter(t => {
        const isForMentee = t.mentorado_nome?.toLowerCase() === nome;
        const resp = (t.responsavel || '').toLowerCase();
        const isPersonal = !resp || resp === 'mentorado' || resp === firstName || resp === nome;
        return isForMentee && isPersonal && t.status !== 'concluida';
      });
    },

    get detailTasksEquipe() {
      const nome = this.data.detail?.profile?.nome?.toLowerCase();
      if (!nome) return [];
      const members = this.data.members?.length ? this.data.members : TEAM_MEMBERS.map(m => ({ nome_curto: m.name }));
      const teamNames = members.map(m => (m.nome_curto || m.name || '').toLowerCase());
      return this.data.tasks.filter(t => {
        const isForMentee = t.mentorado_nome?.toLowerCase() === nome;
        const isTeam = teamNames.some(tm => t.responsavel?.toLowerCase()?.includes(tm));
        return isForMentee && isTeam && t.status !== 'concluida';
      });
    },

    get detailTasksQueila() {
      const nome = this.data.detail?.profile?.nome?.toLowerCase();
      if (!nome) return [];
      return this.data.tasks.filter(t => {
        const isForMentee = t.mentorado_nome?.toLowerCase() === nome;
        const isQueila = t.responsavel?.toLowerCase()?.includes('queila');
        return isForMentee && isQueila && t.status !== 'concluida';
      });
    },

    get detailAllTasks() {
      const nome = this.data.detail?.profile?.nome?.toLowerCase();
      if (!nome) return [];
      return this.data.tasks.filter(t => t.mentorado_nome?.toLowerCase() === nome);
    },

    taskStatusLabel(status) {
      return { pendente: 'A Fazer', em_andamento: 'Em Progresso', concluida: 'Concluído' }[status] || status;
    },

    taskStatusIcon(status) {
      return ''; // visual indicator via CSS dot (.task-status-dot)
    },

    async moveTask(taskId, newStatus) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (!t) return;
      const oldStatus = t.status;
      t.status = newStatus;
      t.updated_at = new Date().toISOString();
      this._cacheTasksLocal();
      if (sb) {
        const { error } = await sb.from('god_tasks').update({ status: newStatus, updated_at: t.updated_at }).eq('id', taskId);
        if (error) { t.status = oldStatus; this._cacheTasksLocal(); this.toast('Erro ao mover tarefa', 'error'); return; }
      }
      this.toast(`Tarefa movida para ${this.taskStatusLabel(newStatus)}`, 'success');
      if (newStatus === 'concluida') this._checkRecurringTasks();
    },

    // Drag and drop
    dragTask: null,
    dragOverColumn: null,

    onDragStart(event, taskId) {
      this.dragTask = taskId;
      event.dataTransfer.effectAllowed = 'move';
      event.target.style.opacity = '0.5';
    },

    onDragEnd(event) {
      event.target.style.opacity = '1';
      this.dragTask = null;
      this.dragOverColumn = null;
    },

    onDragOver(event, status) {
      event.preventDefault();
      event.dataTransfer.dropEffect = 'move';
      this.dragOverColumn = status;
    },

    onDragLeave(event, status) {
      if (this.dragOverColumn === status) this.dragOverColumn = null;
    },

    onDrop(event, status) {
      event.preventDefault();
      if (this.dragTask) {
        this.moveTask(this.dragTask, status);
      }
      this.dragTask = null;
      this.dragOverColumn = null;
    },

    get taskBoardStats() {
      const tasks = this.data.tasks;
      return {
        total: tasks.length,
        pendente: tasks.filter(t => t.status === 'pendente').length,
        em_andamento: tasks.filter(t => t.status === 'em_andamento').length,
        concluida: tasks.filter(t => t.status === 'concluida').length,
        atrasada: tasks.filter(t => t.status === 'pendente' && (t.data_fim || t.prazo) && parseDateStr(t.data_fim || t.prazo) < SYSTEM_TODAY()).length,
      };
    },

    // Dossiers: DEPRECATED — data now from ds_producoes/ds_documentos via Supabase
    get filteredDossiers() { return []; },

    // Reminders: filtered
    get filteredReminders() {
      let list = [...this.data.reminders];
      if (this.ui.reminderFilter === 'ativo') list = list.filter(r => r.status !== 'concluido');
      else if (this.ui.reminderFilter === 'concluido') list = list.filter(r => r.status === 'concluido');
      list.sort((a, b) => {
        if (a.data_lembrete && b.data_lembrete) return parseDateStr(a.data_lembrete) - parseDateStr(b.data_lembrete);
        if (a.data_lembrete) return -1;
        return 1;
      });
      return list;
    },

    get supabase() {
      return sb;
    },

    // ===================== LIFECYCLE =====================

    async init() {
      try {
        // Apply stored dark mode
        if (this.darkMode) document.documentElement.setAttribute('data-theme', 'dark');
        // Onda 7: registra atalhos de teclado globais
        window.addEventListener('keydown', (ev) => this.handleWaShortcuts(ev));
        // Deep-link: resolve URL pathname to page
        const pathname = window.location.pathname.replace(/^\//, '').replace(/\/$/, '');
        // Deep-link: /mentorado/:id — store for after auth
        const menteeDeepLink = pathname.match(/^mentorado\/(.+)$/);
        const taskDeepLink = new URLSearchParams(window.location.search).get('task');
        if (taskDeepLink) {
          this._pendingTaskId = taskDeepLink;
          this.ui.page = 'tasks';
        } else if (menteeDeepLink) {
          this._pendingMenteeId = menteeDeepLink[1];
        } else if (pathname && this._routeMap[pathname]) {
          this.ui.page = this._routeMap[pathname];
          localStorage.setItem('spalla_page', this._routeMap[pathname]);
        }
        // Handle browser back/forward
        window.addEventListener('popstate', (e) => {
          const p = window.location.pathname.replace(/^\//, '').replace(/\/$/, '');
          // Deep-link: /mentorado/:id
          const menteeMatch = p.match(/^mentorado\/(.+)$/);
          if (menteeMatch) {
            this.loadMenteeDetail(menteeMatch[1]);
            return;
          }
          if (p && this._routeMap[p]) {
            this.ui.page = this._routeMap[p];
          } else if (!p || p === '') {
            this.ui.page = 'dashboard';
          }
        });

        // Deep link: ?dl=biblioteca/{slug} — opens doc directly after auth
        const dlParam = new URLSearchParams(window.location.search).get('dl');
        if (dlParam?.startsWith('biblioteca/')) {
          this.ui.page = 'documentos';
          this.ui.docsTab = 'biblioteca';
          this._pendingBibliotecaSlug = dlParam.replace('biblioteca/', '');
        }

        // Check tool statuses in background (non-blocking)
        this.checkToolsStatus();

        // Restore JWT session from localStorage + validate with server
        const accessToken = localStorage.getItem('spalla_access_token');
        const refreshToken = localStorage.getItem('spalla_refresh_token');
        const userStr = localStorage.getItem('spalla_user');

        if (accessToken && userStr) {
          try {
            // Validate token with backend
            const resp = await fetch(`${CONFIG.API_BASE}/api/auth/me`, {
              headers: { 'Authorization': `Bearer ${accessToken}` }
            });
            if (resp.ok) {
              const userData = await resp.json();
              this.auth.authenticated = true;
              this.auth.currentUser = userData.user || JSON.parse(userStr);
              this.auth.accessToken = accessToken;
              this.auth.refreshToken = refreshToken;
            } else if (resp.status === 401 && refreshToken) {
              // Try refresh
              const refreshResp = await fetch(`${CONFIG.API_BASE}/api/auth/refresh`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ refresh_token: refreshToken })
              });
              if (refreshResp.ok) {
                const data = await refreshResp.json();
                this.auth.authenticated = true;
                this.auth.currentUser = data.user || JSON.parse(userStr);
                this.auth.accessToken = data.access_token;
                this.auth.refreshToken = data.refresh_token;
                localStorage.setItem('spalla_access_token', data.access_token);
                localStorage.setItem('spalla_refresh_token', data.refresh_token);
                if (data.user) localStorage.setItem('spalla_user', JSON.stringify(data.user));
              } else {
                // Refresh failed — clear session
                this._clearAuthStorage();
              }
            } else {
              this._clearAuthStorage();
            }
          } catch (e) {
            // Network error — validate token expiry locally before trusting cache
            try {
              const payload = JSON.parse(atob(accessToken.split('.')[1]));
              const now = Math.floor(Date.now() / 1000);
              if (payload.exp && payload.exp > now) {
                this.auth.authenticated = true;
                this.auth.currentUser = JSON.parse(userStr);
                this.auth.accessToken = accessToken;
                this.auth.refreshToken = refreshToken;
                console.warn('[Spalla] Auth: offline, using cached session (token not expired)');
              } else {
                console.warn('[Spalla] Auth: offline, cached token expired');
                this._clearAuthStorage();
              }
            } catch (parseErr) {
              this._clearAuthStorage();
            }
          }
        }

        // Initialize Supabase (if still needed for other features)
        sb = await initSupabase();

        await this.loadTasks();
        this.loadTaskTags(); // non-blocking
        this.loadSpallaMembers(); // non-blocking: popula data.members
        this.loadGodLists();     // non-blocking: popula data.lists + data.sprints
        this.loadFieldDefs();    // non-blocking: popula data.fieldDefs for custom columns
        this.loadAutomations();  // non-blocking: popula data.automations
        this.loadSavedViews();   // non-blocking: popula data.savedViews
        this.loadTemplates();    // non-blocking: popula data.templates
        this._subscribeRealtime(); // Supabase Realtime for live task updates
        this._initKeyboardShortcuts(); // N=new, /=search, Esc=close, Alt+1-4=views
        this.$watch('ui.taskView', () => setTimeout(() => this._initSortable(), 200));
        setTimeout(() => this._initSortable(), 500); // Initial sortable setup

        if (this.auth.authenticated) {
          // Auto-refresh token before it expires (every 45 min)
          this._startTokenAutoRefresh();
          await this.loadReminders(); // Load from Supabase
          await this.loadDashboard();
          this.loadCommandCenterData(); // non-blocking: populate CC from ClickUp
          // Pre-fetch WhatsApp profile pics in background
          this._loadWaProfilePics();
          // Fetch schedule-related data from backend API
          this.fetchUpcomingCalls();
          this.fetchGcalEvents();
          // Fetch Instagram profiles from Apify (background, non-blocking)
          this.updateInstagramProfiles();
          // Load WhatsApp per-user session + start health check
          this.loadWaSession();
          this.waStartHealthCheck();
          // Lazy-load data if page is already restored from localStorage
          if (this.ui.page === 'arquivos') this.loadArquivos();
          if (this.ui.page === 'meu_trabalho') this.loadMeuTrabalho();
        }
      } catch (e) {
        console.error('[Spalla] INIT ERROR:', e);
        // Ensure UI is visible even if init fails
        this.ui.loading = false;
        if (!this.data.mentees.length) this.loadDemoData();
      }
    },

    async _loadWaProfilePics() {
      const { instance } = this._waActiveInstance();
      if (!instance) return;
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/evolution/chat/findChats/${instance}`, {
          method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}',
        });
        if (!res.ok) return;
        const chats = await res.json();
        const pics = {};
        // Build searchable text from each chat (name + pushName + subject)
        const chatEntries = chats.filter(c => c.profilePicUrl).map(c => ({
          text: [c.name, c.pushName, c.subject].filter(Boolean).join(' ').toLowerCase(),
          pic: c.profilePicUrl,
        }));
        for (const m of this.data.mentees) {
          if (!m.nome || pics[m.nome]) continue;
          const nameLower = m.nome.toLowerCase();
          const firstName = nameLower.split(' ')[0];
          const lastName = nameLower.split(' ').pop();
          // Try exact full name match first, then first+last, then first name only
          const match = chatEntries.find(c => c.text.includes(nameLower))
            || (lastName !== firstName && chatEntries.find(c => c.text.includes(firstName) && c.text.includes(lastName)))
            || chatEntries.find(c => c.text.includes(firstName) && (c.text.includes('case') || c.text.includes('mentory') || c.text.includes('consultoria')));
          if (match) pics[m.nome] = match.pic;
        }
        this.waPhotos = pics;
        this.photoTick++;
      } catch (e) {
        console.warn('[Spalla] Could not load WA profile pics:', e.message);
      }
    },

    // ===================== AUTH =====================

    async login() {
      this.auth.error = '';
      if (!this.auth.email || !this.auth.password) {
        this.auth.error = 'Email e senha são obrigatórios';
        return;
      }
      try {
        const response = await fetch(`${CONFIG.API_BASE}/api/auth/login`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            email: this.auth.email,
            password: this.auth.password,
          })
        });
        const data = await response.json();

        if (!response.ok) {
          this.auth.error = data.error || 'Email ou senha incorretos';
          this.auth.password = '';
          return;
        }

        // Store tokens
        this.auth.authenticated = true;
        this.auth.currentUser = data.user;
        this.auth.accessToken = data.access_token;
        this.auth.refreshToken = data.refresh_token;
        localStorage.setItem('spalla_access_token', data.access_token);
        localStorage.setItem('spalla_refresh_token', data.refresh_token);
        localStorage.setItem('spalla_user', JSON.stringify(data.user));

        this.auth.email = '';
        this.auth.password = '';

        await this.loadReminders();
        await this.loadDashboard();
        this.loadCommandCenterData(); // non-blocking
        this.loadWaSession();
        this.waStartHealthCheck();

        // Restore deep-link route AFTER all loads complete
        const pendingRoute = window.location.pathname.replace(/^\//, '').replace(/\/$/, '');
        console.log('[Spalla] Login done. pathname:', JSON.stringify(pendingRoute), 'routeMap hit:', this._routeMap[pendingRoute], 'current ui.page:', this.ui.page);
        if (pendingRoute && this._routeMap[pendingRoute]) {
          const target = this._routeMap[pendingRoute];
          this.ui.page = target;
          localStorage.setItem('spalla_page', target);
          console.log('[Spalla] Deep-link restored to:', target);
        }
        // Deep-link: /mentorado/:id
        if (this._pendingMenteeId) {
          setTimeout(() => this.loadMenteeDetail(this._pendingMenteeId), 300);
          this._pendingMenteeId = null;
        }
        // Deep-link task: /tasks?task=UUID
        if (this._pendingTaskId) {
          this.ui.page = 'tasks';
          const tid = this._pendingTaskId;
          this._pendingTaskId = null;
          // Wait for tasks to load before opening drawer
          const waitForTasks = () => {
            if (this.data.tasks.length) { this.openTaskDetail(tid); }
            else { setTimeout(waitForTasks, 200); }
          };
          setTimeout(waitForTasks, 300);
        }
      } catch (e) {
        this.auth.error = 'Erro ao fazer login: ' + e.message;
        console.error('[Spalla] Login error:', e);
      }
    },

    async register() {
      this.auth.error = '';
      if (!this.auth.email || !this.auth.password || !this.auth.fullName) {
        this.auth.error = 'Nome, email e senha são obrigatórios';
        return;
      }
      if (this.auth.password !== this.auth.confirmPassword) {
        this.auth.error = 'As senhas não coincidem';
        return;
      }
      if (this.auth.password.length < 6) {
        this.auth.error = 'A senha deve ter pelo menos 6 caracteres';
        return;
      }
      try {
        const response = await fetch(`${CONFIG.API_BASE}/api/auth/register`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            email: this.auth.email,
            password: this.auth.password,
            fullName: this.auth.fullName,
          })
        });
        const data = await response.json();

        if (!response.ok) {
          this.auth.error = data.error || 'Erro ao criar conta';
          return;
        }

        // Store tokens
        this.auth.authenticated = true;
        this.auth.currentUser = data.user;
        this.auth.accessToken = data.access_token;
        this.auth.refreshToken = data.refresh_token;
        localStorage.setItem('spalla_access_token', data.access_token);
        localStorage.setItem('spalla_refresh_token', data.refresh_token);
        localStorage.setItem('spalla_user', JSON.stringify(data.user));

        this.auth.email = '';
        this.auth.password = '';
        this.auth.confirmPassword = '';
        this.auth.fullName = '';

        await this.loadReminders();
        await this.loadDashboard();
        this.loadWaSession();
        this.waStartHealthCheck();
      } catch (e) {
        this.auth.error = 'Erro ao criar conta: ' + e.message;
        console.error('[Spalla] Register error:', e);
      }
    },

    _startTokenAutoRefresh() {
      // Refresh token every 45 minutes to prevent session expiry
      if (this._tokenRefreshTimer) clearInterval(this._tokenRefreshTimer);
      this._tokenRefreshTimer = setInterval(async () => {
        const refreshToken = localStorage.getItem('spalla_refresh_token');
        if (!refreshToken || !this.auth.authenticated) return;
        try {
          const resp = await fetch(`${CONFIG.API_BASE}/api/auth/refresh`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ refresh_token: refreshToken })
          });
          if (resp.ok) {
            const data = await resp.json();
            this.auth.accessToken = data.access_token;
            this.auth.refreshToken = data.refresh_token;
            localStorage.setItem('spalla_access_token', data.access_token);
            localStorage.setItem('spalla_refresh_token', data.refresh_token);
            if (data.user) localStorage.setItem('spalla_user', JSON.stringify(data.user));
            console.log('[Spalla] Token auto-refreshed');
          }
        } catch (e) {
          console.warn('[Spalla] Token auto-refresh failed (offline?):', e.message);
        }
      }, 45 * 60 * 1000); // 45 min
      // Refresh on tab visibility change (user returns after idle)
      document.addEventListener('visibilitychange', async () => {
        if (document.visibilityState !== 'visible' || !this.auth.authenticated) return;
        const token = localStorage.getItem('spalla_access_token');
        if (!token) return;
        try {
          const payload = JSON.parse(atob(token.split('.')[1]));
          const minutesLeft = (payload.exp - Math.floor(Date.now() / 1000)) / 60;
          // If token expired or expiring within 60min, refresh immediately
          if (minutesLeft < 60) {
            const refreshToken = localStorage.getItem('spalla_refresh_token');
            if (!refreshToken) { this.logout(); return; }
            const resp = await fetch(`${CONFIG.API_BASE}/api/auth/refresh`, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ refresh_token: refreshToken })
            });
            if (resp.ok) {
              const data = await resp.json();
              this.auth.accessToken = data.access_token;
              this.auth.refreshToken = data.refresh_token;
              localStorage.setItem('spalla_access_token', data.access_token);
              localStorage.setItem('spalla_refresh_token', data.refresh_token);
              console.log('[Spalla] Token refreshed on tab return (' + Math.round(minutesLeft) + 'min left)');
            } else if (resp.status === 401) {
              console.warn('[Spalla] Refresh token expired, logging out');
              this.logout();
            }
          }
        } catch (e) { console.warn('[Spalla] visibilitychange refresh error:', e.message); }
      }, { once: false });
    },

    _clearAuthStorage() {
      localStorage.removeItem('spalla_access_token');
      localStorage.removeItem('spalla_refresh_token');
      localStorage.removeItem('spalla_user');
    },

    async logout() {
      try {
        // Clear all auth state
        this.auth.authenticated = false;
        this.auth.currentUser = null;
        this.auth.accessToken = null;
        this.auth.refreshToken = null;
        this.auth.email = '';
        this.auth.password = '';
        this.auth.confirmPassword = '';
        this.auth.fullName = '';
        this.auth.mode = 'login';
        this.auth.error = '';

        // Stop data refresh
        this.stopDataRefresh();

        // Stop WhatsApp polling and health checks
        this.waStopHealthCheck();
        this.waStopStatusPolling();
        this.stopWhatsAppPolling();

        // Clear tokens and cached data from localStorage
        this._clearAuthStorage();
        localStorage.removeItem(CONFIG.TASKS_STORAGE_KEY);


        // Reload page to reset all state
        setTimeout(() => window.location.reload(), 500);
      } catch (e) {
        console.error('[Spalla] Logout error:', e);
      }
    },

    toggleAuthMode() {
      this.auth.mode = this.auth.mode === 'login' ? 'register' : 'login';
      this.auth.error = '';
      this.auth.success = '';
      this.auth.email = '';
      this.auth.password = '';
      this.auth.confirmPassword = '';
      this.auth.fullName = '';
    },

    async resetPassword() {
      this.auth.error = '';
      this.auth.success = '';
      if (!this.auth.email) {
        this.auth.error = 'Digite seu email para recuperar a senha';
        return;
      }
      try {
        const resp = await fetch(`${CONFIG.API_BASE}/api/auth/reset-password`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email: this.auth.email.trim().toLowerCase() })
        });
        const data = await resp.json();
        if (!resp.ok) {
          this.auth.error = data.error || 'Erro ao solicitar recuperacao';
          return;
        }
        this.auth.success = data.message || 'Se o email existir, as instrucoes de recuperacao serao enviadas.';
      } catch (e) {
        this.auth.error = 'Erro de conexao. Tente novamente.';
        console.error('[Spalla] Reset password error:', e);
      }
    },

    startDataRefresh() {
      if (this._refreshInterval) clearInterval(this._refreshInterval);
      this._refreshInterval = setInterval(() => {
        // Refresh silencioso — não pisca skeleton. Mantém estado/scroll/filtros do usuário.
        this.loadDashboard({ silent: true });
      }, this._refreshIntervalMs);
    },

    stopDataRefresh() {
      if (this._refreshInterval) {
        clearInterval(this._refreshInterval);
        this._refreshInterval = null;
      }
    },

    // ===== Supabase Realtime subscription for wa_messages =====
    _subscribeWaRealtime(groupJid) {
      this._unsubscribeWaRealtime(); // cleanup previous
      if (!this.supabase || !groupJid) return;
      this._waRealtimeChannel = this.supabase
        .channel(`wa-chat-${groupJid.replace(/[^a-zA-Z0-9]/g, '_')}`)
        .on('postgres_changes', {
          event: 'INSERT',
          schema: 'public',
          table: 'whatsapp_messages',
          filter: `group_id=eq.${groupJid}`,
        }, (payload) => {
          try {
            const newMsg = this._waDbToEvolutionFormat(payload.new);
            // Avoid duplicates (optimistic insert from send)
            if (!this.data.whatsappMessages.find(m => m.key?.id === newMsg.key?.id)) {
              // Only auto-scroll if user is already near the bottom
              const feed = document.querySelector('.wa-chat__messages');
              const wasAtBottom = feed ? (feed.scrollHeight - feed.scrollTop - feed.clientHeight < 150) : true;
              this.data.whatsappMessages.push(newMsg);
              if (wasAtBottom) {
                this.$nextTick(() => {
                  const el = document.getElementById('wa-messages-end');
                  if (el) el.scrollIntoView({ behavior: 'smooth' });
                });
              } else if (!newMsg.key?.fromMe) {
                // Onda 4: user scrollado pra cima + msg de outro = mostra FAB
                this.ui.waNewMsgFabVisible = true;
                this.ui.waNewMsgFabCount = (this.ui.waNewMsgFabCount || 0) + 1;
              }
            }
            // TASK-05: Check if this message resolves a pending follow-up
            if (!payload.new.is_from_team) {
              this._checkFollowupResponse(groupJid, payload.new);
            }
          } catch (e) {
            console.error('[Spalla] Realtime INSERT handler error:', e);
          }
        })
        .on('postgres_changes', {
          event: 'UPDATE',
          schema: 'public',
          table: 'whatsapp_messages',
          filter: `group_id=eq.${groupJid}`,
        }, (payload) => {
          // Update status of existing message
          const updated = payload.new;
          const idx = this.data.whatsappMessages.findIndex(m => m.key?.id === updated.message_id);
          if (idx >= 0) {
            this.data.whatsappMessages[idx]._status = updated.status;
            this.data.whatsappMessages[idx]._statusUpdatedAt = updated.status_updated_at;
          }
        })
        .subscribe();
    },

    _unsubscribeWaRealtime() {
      if (this._waRealtimeChannel) {
        this.supabase.removeChannel(this._waRealtimeChannel);
        this._waRealtimeChannel = null;
      }
    },

    // Convert wa_messages DB row to Evolution API format (compatible with existing HTML template)
    // Convert whatsapp_messages row to Evolution API format (HTML compatible)
    _waDbToEvolutionFormat(row) {
      // whatsapp_messages schema: type, content, media_url, media_mime_type, quoted_message_id, group_id
      // Normalize DB type: 'audioMessage' → 'audio', 'imageMessage' → 'image', etc
      const rawType = (row.type || 'text').replace('Message', '').toLowerCase();
      const contentType = rawType === 'chat' ? 'text' : rawType === 'conversation' ? 'text' : rawType === 'extendedtext' ? 'text' : rawType;
      const msgObj = {};
      if (contentType === 'text' || !contentType) {
        msgObj.conversation = row.content || '';
      } else if (contentType === 'image') {
        msgObj.imageMessage = { caption: row.caption || '', url: row.media_url, mediaUrl: row.media_url };
      } else if (contentType === 'audio' || contentType === 'ptt') {
        msgObj.audioMessage = { url: row.media_url, mimetype: row.media_mime_type || 'audio/ogg', mediaUrl: row.media_url };
      } else if (contentType === 'video') {
        msgObj.videoMessage = { caption: row.caption || '', url: row.media_url, mediaUrl: row.media_url };
      } else if (contentType === 'document') {
        msgObj.documentMessage = { fileName: row.file_name || row.content || 'Documento', url: row.media_url, mimetype: row.media_mime_type, mediaUrl: row.media_url };
      } else if (contentType === 'sticker') {
        msgObj.conversation = '[Sticker]';
      } else {
        msgObj.conversation = row.content || `[${rawType}]`;
      }
      // Also set mediaUrl at message level for eagerlyLoadWaMediaUrls
      if (row.media_url) msgObj.mediaUrl = row.media_url;
      // Detect forwarded messages (sender starts with ~)
      const senderRaw = row.sender_name || 'Desconhecido';
      const isForwarded = senderRaw.startsWith('~');
      const senderClean = isForwarded ? senderRaw.substring(1).trim() : senderRaw;
      return {
        key: { id: row.message_id || row.id || ('db-' + Date.now()), fromMe: !!row.is_from_team, remoteJid: row.group_id || row.chat_id },
        message: msgObj,
        messageTimestamp: row.timestamp ? Math.floor(new Date(row.timestamp).getTime() / 1000) : Math.floor(Date.now() / 1000),
        pushName: senderClean,
        _dbId: row.id,
        _replyToId: row.quoted_message_id,
        _contentType: contentType,
        _mediaUrl: row.media_url,
        _isForwarded: isForwarded,
      };
    },

    // Legacy polling — kept as fallback but deprecated
    startWhatsAppPolling() {
      // DEPRECATED: Replaced by Supabase Realtime (_subscribeWaRealtime)
      // Only used as fallback when wa_messages table is empty for this chat
      if (this._whatsappPollInterval) clearInterval(this._whatsappPollInterval);
      const { instance } = this._waActiveInstance();
      if (!this.ui.whatsappSelectedChat || !instance) return;
      this._whatsappPollInterval = setInterval(async () => {
        try {
          const res = await fetch(`${CONFIG.API_BASE}/api/evolution/chat/findMessages/${instance}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ where: { key: { remoteJid: this.ui.whatsappSelectedChat.remoteJid || this.ui.whatsappSelectedChat.id } }, limit: 50 }),
          });
          if (res.status === 405 || res.status === 404) {
            console.warn('[Spalla] WhatsApp API not available (', res.status, '— stopping polling)');
            this.stopWhatsAppPolling();
            return;
          }
          if (res.ok) {
            const data = await res.json();
            const msgs = data.messages?.records || data.messages || data || [];
            const newMsgs = (Array.isArray(msgs) ? msgs : []).reverse();
            const lastLocal = this.data.whatsappMessages[this.data.whatsappMessages.length - 1];
            const lastRemote = newMsgs[newMsgs.length - 1];
            const localId = lastLocal?.key?.id || '';
            const remoteId = lastRemote?.key?.id || '';
            if (newMsgs.length !== this.data.whatsappMessages.length || localId !== remoteId) {
              const feed = document.querySelector('.wa-chat__messages');
              const wasAtBottom = feed ? (feed.scrollHeight - feed.scrollTop - feed.clientHeight < 150) : true;
              this.data.whatsappMessages = newMsgs;
              this.eagerlyLoadWaMediaUrls(this.data.whatsappMessages);
              if (wasAtBottom) this.$nextTick(() => {
                const el = document.getElementById('wa-messages-end');
                if (el) el.scrollIntoView({ behavior: 'smooth' });
              });
            }
          }
        } catch (e) {
          console.warn('[Spalla] WhatsApp poll error (non-blocking):', e.message);
        }
      }, this._whatsappPollIntervalMs);
    },

    stopWhatsAppPolling() {
      if (this._whatsappPollInterval) {
        clearInterval(this._whatsappPollInterval);
        this._whatsappPollInterval = null;
      }
      this._unsubscribeWaRealtime();
      this.cleanupWaReadReceipts();
    },

    // ===================== BIBLIOTECA =====================

    async loadBiblioteca() {
      if (this.bib.loading && this.bib.docs.length > 0) return;
      this.bib.loading = true;
      try {
        const resp = await fetch(`${CONFIG.API_BASE}/api/biblioteca`, {
          headers: { 'Authorization': `Bearer ${this.auth.accessToken}` }
        });
        if (!resp.ok) throw new Error(`biblioteca list failed: ${resp.status}`);
        this.bib.docs = await resp.json();
        this.bibFilter();
        // Resolve deep-link slug set during init()
        if (this._pendingBibliotecaSlug) {
          const doc = this.bib.docs.find(d => d.deep_link_slug === this._pendingBibliotecaSlug);
          if (doc) this.bibOpenDoc(doc.id);
          this._pendingBibliotecaSlug = null;
        }
      } catch (e) {
        console.error('[Biblioteca] load failed', e);
      } finally {
        this.bib.loading = false;
      }
    },

    bibFilter() {
      let list = [...this.bib.docs];
      if (this.bib.menteeFilter) list = list.filter(d => String(d.mentee_id) === String(this.bib.menteeFilter));
      if (this.bib.tipoFilter)   list = list.filter(d => d.tipo === this.bib.tipoFilter);
      if (this.bib.search) {
        const q = this.bib.search.toLowerCase();
        list = list.filter(d =>
          d.titulo?.toLowerCase().includes(q) ||
          d.subtitulo?.toLowerCase().includes(q) ||
          (d.tags || []).some(t => t.toLowerCase().includes(q))
        );
      }
      this.bib.filtered = list;
    },

    async bibOpenDoc(id) {
      if (this.bib.activeDoc?.id === id && this.bib.renderedHtml) return;
      this.bib.docLoading = true;
      this.bib.renderedHtml = '';
      this.bib.activeSec = null;
      try {
        const resp = await fetch(`${CONFIG.API_BASE}/api/biblioteca/${id}`, {
          headers: { 'Authorization': `Bearer ${this.auth.accessToken}` }
        });
        if (!resp.ok) throw new Error(`doc fetch failed: ${resp.status}`);
        const doc = await resp.json();
        this.bib.activeDoc = doc;
        this.bib.renderedHtml = (typeof marked !== 'undefined')
          ? (typeof DOMPurify !== 'undefined' ? DOMPurify.sanitize(marked.parse(doc.conteudo_md || '')) : marked.parse(doc.conteudo_md || ''))
          : '<pre>' + (doc.conteudo_md || '').replace(/</g, '&lt;') + '</pre>';
        this.$nextTick(() => {
          const body = document.querySelector('.bib__reader-body');
          if (body) body.scrollTop = 0;
          // Inject anchor IDs into rendered headings for TOC scrolling
          body?.querySelectorAll('h2,h3').forEach((el, i) => {
            const sec = doc.secoes?.[i];
            if (sec?.ancora && !el.id) el.id = sec.ancora;
          });
        });
      } catch (e) {
        console.error('[Biblioteca] doc load failed', e);
      } finally {
        this.bib.docLoading = false;
      }
    },

    get bibGroupedDocs() {
      const docs = this.bib.filtered || [];
      const groups = {};
      for (const doc of docs) {
        const mentee = doc.mentee_nome || 'Geral';
        if (!groups[mentee]) groups[mentee] = { mentee, docs: [] };
        groups[mentee].docs.push(doc);
      }
      // Sort groups alphabetically, "Geral" last
      return Object.values(groups).sort((a, b) =>
        a.mentee === 'Geral' ? 1 : b.mentee === 'Geral' ? -1 : a.mentee.localeCompare(b.mentee)
      );
    },

    async navigateToDossieDoc(mentoradoId, tipo) {
      // Navigate from Dossiês → Documentos/Biblioteca, opening the matching doc by type
      // tipo from ds_documentos: oferta, funil, conteudo
      // Map to sp_documentos titulo keywords
      const tipoKeywords = {
        oferta: 'oferta',
        funil: 'funil',
        conteudo: 'posicionamento',
      };
      const keyword = tipoKeywords[tipo] || tipo;

      // 1. Switch to Documentos page, Biblioteca tab
      this.navigate('documentos');
      this.ui.docsTab = 'biblioteca';

      // 2. Load biblioteca if needed
      if (!this.bib.docs.length) {
        await this.loadBiblioteca();
      }

      // 3. Find matching doc by mentorado_id + tipo
      const mid = typeof mentoradoId === 'string' ? parseInt(mentoradoId) : mentoradoId;

      // First try exact match by mentorado + tipo keyword in titulo or slug
      let doc = this.bib.docs.find(d =>
        (d.mentee_id === mid || d.mentee_id === String(mid)) &&
        ((d.titulo || '').toLowerCase().includes(keyword) || (d.deep_link_slug || '').includes(keyword))
      );

      // Fallback: any doc of this mentorado
      if (!doc) {
        doc = this.bib.docs.find(d => d.mentee_id === mid || d.mentee_id === String(mid));
      }

      if (doc) {
        this.$nextTick(() => this.bibOpenDoc(doc.id));
      } else {
        // Last resort: fetch from API
        try {
          const resp = await fetch(`${CONFIG.API_BASE}/api/biblioteca?mentee_id=${mentoradoId}`);
          if (resp.ok) {
            const docs = await resp.json();
            const match = docs.find(d => (d.titulo || '').toLowerCase().includes(keyword)) || docs[0];
            if (match) {
              this.$nextTick(() => this.bibOpenDoc(match.id));
              return;
            }
          }
        } catch (e) { console.warn('[Dossie→Bib] fetch error:', e); }
        this.toast('Documento não encontrado na Biblioteca', 'info');
      }
    },

    async bibSaveDoc() {
      const doc = this.bib.activeDoc;
      if (!doc || !doc.id) return;
      try {
        const { error } = await this.sb.from('sp_documentos')
          .update({ conteudo_md: doc.conteudo_md })
          .eq('id', doc.id);
        if (error) throw error;
        // Re-render preview
        this.bib.renderedHtml = (typeof marked !== 'undefined')
          ? (typeof DOMPurify !== 'undefined' ? DOMPurify.sanitize(marked.parse(doc.conteudo_md || '')) : marked.parse(doc.conteudo_md || ''))
          : (doc.conteudo_md || '').replace(/</g, '&lt;').replace(/>/g, '&gt;');
        this.bib.editMode = false;
        // Unmount editor
        const editorEl = this.$refs.bibEditor;
        if (editorEl && window.OperonEditor?.isActive(editorEl)) {
          window.OperonEditor.unmount(editorEl);
        }
        console.log('[Biblioteca] doc saved');
      } catch (e) {
        console.error('[Biblioteca] save failed', e);
        alert('Erro ao salvar: ' + (e.message || e));
      }
    },

    bibScrollTo(ancora) {
      this.bib.activeSec = ancora;
      this.$nextTick(() => {
        const body = document.querySelector('.bib__reader-body');
        const el = body?.querySelector(`#${CSS.escape(ancora)}`);
        if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
      });
    },

    hasBibDoc(mentoradoId, tipo) {
      if (!this.bib.docs.length) return false;
      const mid = typeof mentoradoId === 'string' ? parseInt(mentoradoId) : mentoradoId;
      const tipoKeywords = { oferta: 'oferta', funil: 'funil', conteudo: 'posicionamento' };
      const keyword = tipoKeywords[tipo] || tipo;
      return this.bib.docs.some(d =>
        (d.mentee_id === mid || d.mentee_id === String(mid)) &&
        ((d.titulo || '').toLowerCase().includes(keyword) || (d.deep_link_slug || '').includes(keyword))
      );
    },

    bibMenteeOptions() {
      const seen = new Set();
      return this.bib.docs
        .filter(d => {
          if (!d.mentee_id || seen.has(d.mentee_id)) return false;
          seen.add(d.mentee_id);
          return true;
        })
        .map(d => ({ id: d.mentee_id, nome: d.mentee_nome || `Mentorado ${d.mentee_id}` }));
    },

    bibCopyDeepLink(slug) {
      if (!slug) return;
      const url = `${window.location.origin}${window.location.pathname}?dl=biblioteca/${slug}`;
      navigator.clipboard?.writeText(url).catch(() => {});
    },

    bibTipoLabel(tipo) {
      return { dossie: 'Dossiê', roteiro: 'Roteiro', material: 'Material' }[tipo] || tipo;
    },

    // ===================== TOOL STATUS =====================

    async checkToolsStatus() {
      if (this._toolsChecking) return;
      this._toolsChecking = true;
      this.toolsStatus.forEach(t => { t.status = 'checking'; });
      await Promise.all(this.toolsStatus.map(async (tool) => {
        try {
          const ctrl = new AbortController();
          const tid = setTimeout(() => ctrl.abort(), 6000);
          await fetch(tool.url, { method: 'HEAD', mode: 'no-cors', signal: ctrl.signal });
          clearTimeout(tid);
          tool.status = 'online';
        } catch (_) {
          tool.status = 'offline';
        }
      }));
      const now = new Date();
      this._toolsCheckedAt = now.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
      this._toolsChecking = false;
    },

    // ===================== DATA LOADING =====================

    async syncSheets() {
      if (this.ui.sheetsSyncing) return;
      this.ui.sheetsSyncing = true;
      try {
        const resp = await fetch(`${CONFIG.API_BASE}/api/sheets/sync`, { method: 'POST' });
        const data = await resp.json();
        if (data.error) {
          this.toast(`Erro no sync: ${data.error}`, 'error');
        } else {
          this.toast(`Sheets sync: ${data.updated} atualizacoes em ${data.elapsed_seconds}s`, 'success');
          // Reload dashboard to show updated data
          await this.loadDashboard();
        }
      } catch (e) {
        this.toast(`Erro no sync: ${e.message}`, 'error');
      } finally {
        this.ui.sheetsSyncing = false;
      }
    },

    async loadDashboard({ silent = false } = {}) {
      // Auto-refresh em background NÃO seta loading=true pra não piscar a tela.
      // Só o load inicial e o botão "Atualizar" mostram skeleton.
      if (!silent) this.ui.loading = true;
      sb = await initSupabase();
      if (sb) {
        try {
          const [mentees, cohort, pendencias, aguardandoRaw, paPipeline, waWeekly, waAlertas] = await Promise.all([
            sb.from('vw_god_overview').select('*'),
            sb.from('vw_god_cohort').select('*'),
            sb.from('vw_god_pendencias').select('*').order('created_at', { ascending: true }),
            // Aguardando Resposta — confia na coluna requer_resposta do banco
            // (classifier upstream é a fonte de verdade). Sem filtros de mentorado pra
            // não excluir quem tem cohort=NULL (PR #604).
            sb.from('interacoes_mentoria')
              .select('id, mentorado_id, conteudo, sender_name, message_type, created_at, mentorados(id, nome, consultor_responsavel, ativo, cohort, grupo_whatsapp_id)')
              .eq('eh_equipe', false)
              .eq('requer_resposta', true)
              .eq('respondido', false)
              .order('created_at', { ascending: false }),
            sb.from('vw_pa_pipeline').select('*'),
            sb.from('vw_wa_mentee_weekly_stats').select('*'),
            sb.from('vw_alertas_command_center').select('*'),
          ]);
          // Load calls in background (non-blocking)
          const calls = await sb.from('calls_mentoria')
            .select('id,mentorado_id,data_call,duracao_minutos,tipo,tipo_call,link_gravacao,link_transcricao,link_youtube,zoom_topic,status_call,"senha_Call",link_plano_acao,principais_topicos,decisoes_tomadas,created_at,mentorados(id,nome)')
            .order('data_call', { ascending: false })
            .limit(500);
          // Check individual query errors
          if (mentees.error) console.error('[Spalla] Mentees query error:', mentees.error.message);
          if (cohort.error) console.error('[Spalla] Cohort query error:', cohort.error.message);
          if (calls.error) console.error('[Spalla] Calls query error:', calls.error.message);
          if (pendencias.error) console.error('[Spalla] Pendencias query error:', pendencias.error.message);
          if (paPipeline.error) console.error('[Spalla] PA Pipeline query error:', paPipeline.error?.message);
          if (paPipeline.data) this.data.paPlanos = paPipeline.data;
          if (waWeekly.error) console.error('[Spalla] WA Weekly Stats query error:', waWeekly.error?.message);
          if (waWeekly.data) this.data.waWeeklyStats = waWeekly.data;
          if (waAlertas.error) console.error('[Spalla] WA Alertas query error:', waAlertas.error?.message);
          if (waAlertas.data) this.data.waAlertas = waAlertas.data;
          // Load lightweight fases + acoes for sentinel calculations
          const [paFasesRes, paAcoesRes] = await Promise.all([
            sb.from('pa_fases').select('id, plano_id, titulo, tipo, status, ordem, origem'),
            sb.from('pa_acoes').select('id, fase_id, plano_id, status, origem, data_prevista, responsavel, updated_at'),
          ]);
          if (paFasesRes.data) this.data.paAllFases = paFasesRes.data;
          if (paAcoesRes.data) this.data.paAllAcoes = paAcoesRes.data;
          // Load DS pipeline data
          this.loadDsData();
          // Load OB onboarding data
          this.loadObData();
          // Load mentee groups/pastas (non-blocking)
          this.loadGroups();

          if (mentees.data?.length) {
            this.data.mentees = mentees.data;
            // Load emails for schedule form auto-fill via backend API
            // (vw_god_overview doesn't expose email; direct table access blocked by RLS)
            try {
              const emailResp = await fetch(`${CONFIG.API_BASE}/api/mentees`);
              if (emailResp.ok) {
                const emailData = await emailResp.json();
                if (Array.isArray(emailData)) this._menteesWithEmail = emailData;
              }
            } catch (e) {
              console.warn('[Spalla] Failed to load mentee emails:', e);
            }
          } else {
            console.warn('[Spalla] Supabase mentees empty, using demo');
            this.loadDemoData();
          }
          if (cohort.data?.length) this.data.cohort = cohort.data;
          if (pendencias.data) {
            this.data.pendencias = pendencias.data;
          }
          // Aguardando Resposta — bate 1:1 com a tabela: linhas onde requer_resposta=true,
          // respondido=false, eh_equipe=false. Confia na coluna requer_resposta do banco.
          if (aguardandoRaw.error) console.error('[Spalla] Aguardando raw query error:', aguardandoRaw.error.message);
          this.data.aguardandoResposta = (aguardandoRaw.data || []).map(r => {
            const m = r.mentorados || {};
            const nowMs = Date.now();
            const created = new Date(r.created_at).getTime();
            const horas = Math.round((nowMs - created) / 36e5 * 10) / 10;
            return {
              interacao_id: r.id,
              mentorado_id: r.mentorado_id,
              mentorado_nome: m.nome || '?',
              consultor_responsavel: m.consultor_responsavel,
              chat_id: m.grupo_whatsapp_id,
              grupo_whatsapp_id: m.grupo_whatsapp_id,
              conteudo_truncado: (r.conteudo || '').slice(0, 200),
              tipo_interacao: r.message_type,
              autor_identificado: r.sender_name,
              created_at: r.created_at,
              horas_pendente: horas,
              prioridade_calculada: horas > 48 ? 'critico' : horas > 24 ? 'alto' : horas > 12 ? 'medio' : 'baixo',
              eh_equipe: false,
              direcao: 'mentee_to_team',
            };
          });
          // Reconcile counters per mentee — ambas as fontes feedback contagem do filtro
          const pendsByMentee = {};
          (pendencias.data || []).forEach(p => {
            if (!p.mentorado_id) return;
            const b = pendsByMentee[p.mentorado_id] || (pendsByMentee[p.mentorado_id] = { reforco: 0, aguardando: 0 });
            if (p.direcao === 'team_to_mentee') b.reforco += 1;
          });
          this.data.aguardandoResposta.forEach(a => {
            const b = pendsByMentee[a.mentorado_id] || (pendsByMentee[a.mentorado_id] = { reforco: 0, aguardando: 0 });
            b.aguardando += 1;
          });
          this.data.mentees = this.data.mentees.map(m => {
            const b = pendsByMentee[m.id] || { reforco: 0, aguardando: 0 };
            return {
              ...m,
              msgs_pendentes_resposta: b.reforco + b.aguardando,
              msgs_aguardando_resposta: b.aguardando,
              msgs_para_reforcar: b.reforco,
            };
          });
          if (calls.data?.length) {
            // Normalize calls data (from calls_mentoria table directly)
            this._supabaseCalls = calls.data.map(c => ({
              mentorado_id: c.mentorado_id,
              mentorado_nome: c.mentorados?.nome || 'Unknown',
              call_id: c.id,
              data_call: c.data_call,
              tipo_call: c.tipo_call || c.tipo,
              duracao_minutos: c.duracao_minutos,
              link_gravacao: c.link_gravacao,
              link_transcricao: c.link_transcricao,
              zoom_topic: c.zoom_topic,
              senha_call: c.senha_Call || c.senha_call || null,
              status_call: c.status_call || (c.link_gravacao ? 'realizada' : null),
              horario_call: c.data_call && c.data_call.includes('T') ? c.data_call.substring(11, 16) : null,
              link_plano_acao: c.link_plano_acao || null,
              link_youtube: c.link_youtube || null,
              transcript_completo: c.transcript_completo || null,
              observacoes_equipe: c.observacoes_equipe || null,
              created_at: c.created_at,
            }));
            // Log first 5 calls for debugging
          }
          // Recalculate dias_desde_call with real call data
          if (this._supabaseCalls?.length) this._enrichMenteesWithCalls();
          this.supabaseConnected = true;
          this.loadAlerts().catch(e => console.warn('[Spalla] Alerts:', e));
          this.loadTeamPerformance().catch(e => console.warn('[Spalla] TeamPerf:', e));
          this._maybeUpdateKpiSnapshot();
          this.toast('Dados carregados do Supabase', 'success');
        } catch (e) {
          console.error('[Spalla] Fetch error:', e);
          this.loadDemoData();
          this.toast('Usando dados de demonstracao', 'info');
        }
      } else {
        this.loadDemoData();
      }
      this.ui.loading = false;
      // F2.5 — rebuild notifications after dashboard data loads
      this._buildNotifications();
      // Auto-refresh: religado com modo silent pra resolver dado-fantasma (Lauanne respondida ainda aparece).
      // Intervalo via _refreshIntervalMs (60s default).
      if (this.supabaseConnected && !this._refreshInterval) this.startDataRefresh();
    },

    // === ALERTS BAR (Wave 1 F1.1) ===
    async loadAlerts() {
      if (!sb) return;
      const { data, error } = await sb.rpc('fn_god_alerts');
      if (error) { console.warn('[Spalla] loadAlerts:', error.message); return; }
      this.data.alerts = data || [];
    },

// === IN-APP NOTIFICATIONS (Wave 2 F2.5) ===
    _buildNotifications() {
      const notifs = [];
      const now = new Date();

      // Alert: mentees without contact > 3 days
      (this.data.mentees || []).forEach(m => {
        const lastContact = m.ultimo_contato ? new Date(m.ultimo_contato) : null;
        if (!lastContact) return;
        const days = Math.floor((now - lastContact) / 86400000);
        if (days >= 3) {
          notifs.push({
            id: `health-${m.id}`,
            type: 'health',
            icon: '⚠️',
            title: `${m.nome} sem contato há ${days}d`,
            body: m.fase_jornada ? `Fase: ${m.fase_jornada}` : 'Mentorado em risco',
            menteeId: m.id,
            createdAt: new Date(now - days * 86400000).toISOString(),
            read: false,
            color: days >= 7 ? '#ef4444' : '#f59e0b',
          });
        }
      });

      // Alert: overdue tasks (data_fim < today, status != concluida)
      (this.data.tasks || []).forEach(t => {
        if (!t.data_fim || t.status === 'concluida' || t.status === 'cancelada') return;
        const due = new Date(t.data_fim);
        if (due < now) {
          const days = Math.floor((now - due) / 86400000);
          notifs.push({
            id: `task-${t.id}`,
            type: 'task',
            icon: '📋',
            title: `Tarefa vencida: ${(t.titulo || '').slice(0, 40)}`,
            body: `Venceu há ${days}d${t.mentorado_nome ? ` — ${t.mentorado_nome}` : ''}`,
            menteeId: t.mentorado_id,
            createdAt: t.data_fim,
            read: false,
            color: '#f59e0b',
          });
        }
      });

      // Sort: by date desc
      notifs.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

      // Preserve read state from existing notifications
      const readIds = new Set((this.notifications || []).filter(n => n.read).map(n => n.id));
      notifs.forEach(n => { if (readIds.has(n.id)) n.read = true; });

      this.notifications = notifs.slice(0, 20); // cap at 20
      this.notificationsUnread = this.notifications.filter(n => !n.read).length;
    },

    markNotificationRead(id) {
      const n = this.notifications.find(n => n.id === id);
      if (n) { n.read = true; this.notificationsUnread = this.notifications.filter(n => !n.read).length; }
    },

    markAllNotificationsRead() {
      this.notifications.forEach(n => n.read = true);
      this.notificationsUnread = 0;
    },

    toggleNotifications() {
      this.notificationsOpen = !this.notificationsOpen;
      if (this.notificationsOpen) this._buildNotifications();
    },
    // === TEAM PERFORMANCE (Wave 2 F2.2) ===
    async loadTeamPerformance() {
      if (!sb) return;
      const { data: tasks, error: tErr } = await sb
        .from('god_tasks')
        .select('responsavel, status, updated_at, created_at')
        .not('responsavel', 'is', null);
      const { data: mentees, error: mErr } = await sb
        .from('mentorados')
        .select('consultor_responsavel, id');
      const { data: calls, error: cErr } = await sb
        .from('calls_mentoria')
        .select('responsavel_call, data_call, status_call')
        .gte('data_call', new Date(Date.now() - 30*24*60*60*1000).toISOString());
      if (tErr || mErr) { console.warn('[Spalla] loadTeamPerformance:', tErr?.message || mErr?.message); return; }
      // Agregar por responsavel
      const byMember = {};
      for (const t of (tasks || [])) {
        const name = t.responsavel || 'Sem responsavel';
        if (!byMember[name]) byMember[name] = { name, tasksDone: 0, tasksPending: 0, mentorados: 0, calls30d: 0 };
        if (t.status === 'concluida' || t.status === 'done') byMember[name].tasksDone++;
        else byMember[name].tasksPending++;
      }
      for (const m of (mentees || [])) {
        const name = m.consultor_responsavel || 'Sem responsavel';
        if (!byMember[name]) byMember[name] = { name, tasksDone: 0, tasksPending: 0, mentorados: 0, calls30d: 0 };
        byMember[name].mentorados++;
      }
      for (const c of (calls || [])) {
        const name = c.responsavel_call || '';
        if (!name) continue;
        if (!byMember[name]) byMember[name] = { name, tasksDone: 0, tasksPending: 0, mentorados: 0, calls30d: 0 };
        if (c.status_call === 'realizada') byMember[name].calls30d++;
      }
      this.data.teamPerformance = Object.values(byMember)
        .filter(m => m.name && m.name !== 'Sem responsavel')
        .sort((a, b) => b.tasksDone - a.tasksDone);
    },

    _alertKey(alert) {
      return `${alert.mentorado_id || ''}-${alert.alerta_tipo || ''}`;
    },

    dismissAlert(alert) {
      const key = this._alertKey(alert);
      if (!(this.ui.alertsDismissed || []).includes(key)) {
        this.ui.alertsDismissed = [...(this.ui.alertsDismissed || []), key];
      }
    },

    get visibleAlerts() {
      const dismissed = this.ui.alertsDismissed || [];
      return (this.data.alerts || []).filter(a => !dismissed.includes(this._alertKey(a)));
    },

    get criticalAlertCount() {
      return (this.visibleAlerts || []).filter(a => a.severidade === 'critico').length;
    },

    get alertsAltoCount() {
      return (this.visibleAlerts || []).filter(a => a.severidade === 'alto').length;
    },

    get alertsMedioCount() {
      return (this.visibleAlerts || []).filter(a => a.severidade === 'medio').length;
    },

    get alertsCriticos() {
      return (this.visibleAlerts || []).filter(a => a.severidade === 'critico');
    },

    get alertsAlto() {
      return (this.visibleAlerts || []).filter(a => a.severidade === 'alto');
    },

    get alertsMedio() {
      return (this.visibleAlerts || []).filter(a => a.severidade === 'medio');
    },

    // === KPI TRENDS (Wave 1 F1.4) ===
    _maybeUpdateKpiSnapshot() {
      try {
        const stored = JSON.parse(localStorage.getItem('spalla_kpi_snapshot') || 'null');
        const now = Date.now();
        if (!stored || !Number.isFinite(stored.ts) || (now - stored.ts) > 7 * 24 * 60 * 60 * 1000) {
          localStorage.setItem('spalla_kpi_snapshot', JSON.stringify({
            ts: now,
            kpis: { ...this.kpis },
          }));
        }
      } catch (e) { /* noop */ }
    },

    kpiTrend(key) {
      try {
        const stored = JSON.parse(localStorage.getItem('spalla_kpi_snapshot') || 'null');
        if (!stored?.kpis) return '';
        const prev = stored.kpis[key];
        const curr = this.kpis[key];
        if (prev == null || curr == null) return '';
        if (curr > prev) return '▲';
        if (curr < prev) return '▼';
        return '';
      } catch (e) { return ''; }
    },

    kpiTrendClass(key) {
      const t = this.kpiTrend(key);
      if (t === '▲') return 'trend--up';
      if (t === '▼') return 'trend--down';
      return '';
    },

    // === EXPORT CSV (Wave 1 F1.3) ===
    exportDashboardCsv() {
      let url;
      try {
        const rows = [['Nome','Fase','Risco','Engagement (%)','Dias sem Call','Msgs Pendentes','Financeiro','Contrato','Consultor','Cohort']];
        for (const m of this.filteredMentees) {
          rows.push([
            m.nome || '',
            m.fase_jornada || '',
            m.risco_churn || '',
            m.engagement_score ?? '',
            m.dias_desde_call ?? '',
            m.msgs_pendentes_resposta ?? 0,
            m.status_financeiro || '',
            m.contrato_assinado ? 'Sim' : 'Não',
            m.consultor_responsavel || '',
            m.cohort || '',
          ]);
        }
        const csv = rows.map(r => r.map(v => `"${(v ?? '').toString().replace(/"/g, '""')}"`).join(',')).join('\n');
        const blob = new Blob(['\uFEFF' + csv], { type: 'text/csv;charset=utf-8;' });
        url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `spalla-mentorados-${new Date().toISOString().slice(0, 10)}.csv`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        this.toast(`${this.filteredMentees.length} mentorados exportados`, 'success');
      } catch (e) {
        console.warn('[Spalla] exportDashboardCsv:', e);
        this.toast('Erro ao exportar CSV', 'error');
      } finally {
        if (url) URL.revokeObjectURL(url);
      }
    },

    exportDetailCsv() {
      let url;
      try {
        const p = this.data.detail?.profile || {};
        const ph = this.data.detail?.phase || {};
        const fin = this.data.detail?.financial || {};
        const calls = this.data.detail?.last_calls || [];
        const profile = [
          ['Campo', 'Valor'],
          ['Nome', p.nome || ''],
          ['Instagram', p.instagram || ''],
          ['Fase', ph.fase_jornada || ''],
          ['Risco', ph.risco_churn || ''],
          ['Marco', ph.marco_atual || ''],
          ['Engagement', (ph.engagement_score || 0) + '%'],
          ['Implementacao', (ph.implementation_score || 0) + '%'],
          ['Cohort', p.cohort || ''],
          ['Consultor', p.consultor_responsavel || ''],
          ['Total Vendido', fin.faturamento_atual || 0],
          ['Qtd Vendas', fin.qtd_vendas_total || 0],
          ['Status Financeiro', fin.status_financeiro || ''],
          ['Contrato', p.contrato_assinado ? 'Sim' : 'Não'],
          ['Dias desde Call', ph.dias_desde_call ?? ''],
          ['Msgs Pendentes', ph.msgs_pendentes_resposta ?? 0],
        ];
        const callsRows = [
          [],
          ['--- CALLS ---'],
          ['Data', 'Tipo', 'Duração (min)', 'Status'],
          ...calls.map(c => [
            c.data_call ? new Date(c.data_call).toLocaleDateString('pt-BR') : '',
            c.tipo_call || '',
            c.duracao || c.duracao_minutos || '',
            c.status_call || '',
          ]),
        ];
        const allRows = [...profile, ...callsRows];
        const csv = allRows.map(r => r.map(v => `"${(v ?? '').toString().replace(/"/g, '""')}"`).join(',')).join('\n');
        const blob = new Blob(['\uFEFF' + csv], { type: 'text/csv;charset=utf-8;' });
        url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        const nome = (p.nome || 'mentorado').toLowerCase().replace(/\s+/g, '-');
        a.download = `spalla-${nome}-${new Date().toISOString().slice(0, 10)}.csv`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        this.toast('Perfil exportado', 'success');
      } catch (e) {
        console.warn('[Spalla] exportDetailCsv:', e);
        this.toast('Erro ao exportar perfil', 'error');
      } finally {
        if (url) URL.revokeObjectURL(url);
      }
    },

    _enrichMenteesWithCalls() {
      if (!this.data.mentees?.length) return;
      // Recalculate dias_desde_call using real Supabase calls
      const callsByMentee = {};
      for (const c of (this._supabaseCalls || [])) {
        const name = (c.mentorado_nome || '').toLowerCase().trim();
        if (!name || !c.data_call) continue;
        if (!callsByMentee[name]) callsByMentee[name] = [];
        callsByMentee[name].push(c.data_call);
      }
      this.data.mentees = this.data.mentees.map(m => {
        // Normalize Instagram handle (remove extra @)
        if (m.instagram?.startsWith('@')) {
          m.instagram = m.instagram.replace(/^@+/, '');
        }

        // Fix known data issues
        if (m.nome?.toLowerCase().includes('danyella') && m.faturamento_atual === 150000) {
          m.faturamento_atual = 0; // Danyella just entered, no sales yet
          m.contrato_assinado = false;
        }

        const mName = m.nome?.toLowerCase()?.trim();
        const callDates = callsByMentee[mName] || [];
        // Also check static SUPABASE_CALLS as fallback
        const staticDates = (SUPABASE_CALLS || [])
          .filter(c => c.data && c.mentorado?.toLowerCase()?.trim() === mName)
          .map(c => c.data);
        const allDates = [...callDates, ...staticDates].sort();
        const mostRecent = allDates.pop();
        const dynamicDays = daysBetween(mostRecent);
        const origDays = daysBetween(m.ultima_call_data);
        const bestDays = (dynamicDays !== null && origDays !== null) ? Math.min(dynamicDays, origDays) : (dynamicDays ?? origDays);
        return { ...m, dias_desde_call: bestDays ?? m.dias_desde_call };
      });
    },

    openDetail(id) {
      this.loadMenteeDetail(id);
      history.pushState({ page: 'detail', menteeId: id }, '', '/mentorado/' + id);
    },

    async loadMenteeDetail(id) {
      this.destroyPerfilCharts();
      this.data.perfilComportamental = null;
      this.ui.detailLoading = true;
      this.ui.selectedMenteeId = id;
      this.ui.page = 'detail';
      this.ui.activeDetailTab = 'resumo';
      window.scrollTo({ top: 0, behavior: 'smooth' });
      // Check cache (5 min TTL)
      const cached = this._detailCache[id];
      if (cached && Date.now() - cached.ts < 300000) {
        this.data.detail = cached.data;
        this.ui.detailLoading = false;
        this._loadDetailWaMessages();
        return;
      }
      if (sb) {
        try {
          // Load deep detail + real calls in parallel
          const [detailRes, callsRes] = await Promise.all([
            sb.rpc('fn_god_mentorado_deep', { p_id: id }),
            sb.from('calls_mentoria').select('*,mentorados(id,nome)').eq('mentorado_id', id).order('data_call', { ascending: false }),
          ]);
          if (detailRes.data) {
            const detail = typeof detailRes.data === 'string' ? JSON.parse(detailRes.data) : detailRes.data;
            // Enrich with real calls from vw_god_calls
            if (callsRes.data?.length) {
              detail.last_calls = callsRes.data.map(c => ({
                call_id: c.id,
                data_call: c.data_call, tipo: c.tipo_call || c.tipo || 'acompanhamento',
                duracao: c.duracao_minutos || 0,
                resumo: c.resumo || c.zoom_topic || 'Call de acompanhamento',
                gravacao: c.link_gravacao || null,
                transcricao: c.link_transcricao || null,
                senha_call: c['senha_Call'] || c.senha_call || null,
                link_youtube: c.link_youtube || null,
                plano_acao: c.link_plano_acao || null,
                decisoes_tomadas: c.decisoes_tomadas || [],
                feedbacks_queila: c.feedbacks_consultora || c.proximos_passos || [],
              }));
            }
            // Normalize context_ia: Supabase returns objects, template expects strings
            if (detail.context_ia) {
              const ctx = detail.context_ia;
              // gargalos: [{descricao, citacao_direta}] → ['descricao']
              if (Array.isArray(ctx.gargalos) && ctx.gargalos.length && typeof ctx.gargalos[0] === 'object') {
                ctx.gargalos = ctx.gargalos.map(g => g.descricao || g.texto || JSON.stringify(g));
              }
              // estrategias_atuais: {parcerias, formatos_produto, ...} → summary string
              if (ctx.estrategias_atuais && typeof ctx.estrategias_atuais === 'object') {
                const parts = [];
                if (ctx.estrategias_atuais.formatos_produto) parts.push(...ctx.estrategias_atuais.formatos_produto.map(f => f.descricao || f.tipo));
                if (ctx.estrategias_atuais.estrategias_marketing) parts.push(...ctx.estrategias_atuais.estrategias_marketing.map(e => e.nome || e.objetivo));
                ctx.estrategias_atuais = parts.length ? parts.join(' · ') : '';
              }
            }
            this.data.detail = detail;
            this._detailCache[id] = { data: detail, ts: Date.now() };
          }
        } catch (e) {
          console.error('[Spalla] Detail fetch error:', e);
          this.data.detail = this.getDemoDetail(id);
        }
      } else {
        this.data.detail = this.getDemoDetail(id);
      }
      this.ui.detailLoading = false;
      // Load WA messages for this mentee in background
      this._loadDetailWaMessages();
    },

    async _loadDetailWaMessages() {
      const { instance: _waInst } = this._waActiveInstance();
      const nome = this.data.detail?.profile?.nome;
      const menteeId = this.ui.selectedMenteeId;
      if (!nome) { if (this.data.detail) this.data.detail._waLoaded = true; return; }

      // Enrich detail with overview WA metrics
      const overviewMentee = this.data.mentees.find(m => m.id === menteeId);
      if (this.data.detail && overviewMentee) {
        this.data.detail._waMetrics = {
          whatsapp_7d: overviewMentee.whatsapp_7d,
          whatsapp_30d: overviewMentee.whatsapp_30d,
          whatsapp_total: overviewMentee.whatsapp_total,
        };
      }

      try {
        // Strategy 0: Check wa_groups for linked group (most reliable — Story 8)
        let remoteJid = null;
        let chatObj = null;
        let usedSupabase = false;

        const { data: linkedGroups } = await sb.from('wa_groups')
          .select('group_jid,name')
          .eq('mentorado_id', menteeId)
          .eq('is_active', true)
          .limit(1);

        if (linkedGroups?.length) {
          remoteJid = linkedGroups[0].group_jid;
          chatObj = { remoteJid, id: remoteJid, name: linkedGroups[0].name || nome };
        }

        // Strategy 1: Use grupo_whatsapp_id from mentorados table
        if (!remoteJid) {
          const grupoId = overviewMentee?.grupo_whatsapp_id;
          if (grupoId) {
            remoteJid = grupoId;
            chatObj = { remoteJid: grupoId, id: grupoId, name: nome };
          }
        }

        // Strategy 2: Fallback to name matching in Evolution chats
        if (!remoteJid && _waInst) {
          const firstName = nome.split(' ')[0].toLowerCase();
          let chats = this.data.whatsappChats;
          if (!chats.length) {
            const res = await fetch(`${CONFIG.API_BASE}/api/evolution/chat/findChats/${_waInst}`, {
              method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}',
            });
            if (res.ok) chats = await res.json();
          }
          const chat = (chats || []).find(c => {
            const pushName = (c.pushName || c.name || '').toLowerCase();
            return pushName.includes(firstName);
          });
          if (chat) {
            remoteJid = chat.remoteJid || chat.id;
            chatObj = chat;
          }
        }

        if (!remoteJid) { if (this.data.detail) this.data.detail._waLoaded = true; return; }

        // Try loading from Supabase wa_messages first (real data, with status)
        const { data: dbMsgs } = await sb.from('whatsapp_messages')
          .select('id,message_id,sender_name,type,content,media_url,media_mime_type,quoted_message_id,timestamp,is_group,group_id')
          .eq('group_id', remoteJid)
          .order('timestamp', { ascending: false })
          .limit(100);

        let interactions = [];
        // Build team member name set for matching
        const teamNames = new Set();
        (this.data.members || []).forEach(m => {
          if (m.nome_curto) teamNames.add(m.nome_curto.toLowerCase());
          if (m.nome_completo) teamNames.add(m.nome_completo.toLowerCase());
        });

        if (dbMsgs?.length) {
          usedSupabase = true;
          interactions = dbMsgs.reverse().map(msg => {
            // Detect team: sender name matches a team member
            const senderLower = (msg.sender_name || '').toLowerCase();
            const isTeam = teamNames.has(senderLower) ||
              [...teamNames].some(tn => senderLower.includes(tn) || tn.includes(senderLower));
            // Normalize content_type: Supabase stores WA types like 'conversation', 'extendedTextMessage'
            // Template expects: text, audio, image, video, document
            const MEDIA_TYPES = new Set(['audio', 'image', 'video', 'document', 'sticker']);
            const rawType = (msg.type || '').toLowerCase();
            const normalizedType = MEDIA_TYPES.has(rawType) ? rawType : 'text';
            return {
              sender: isTeam ? (msg.sender_name || 'Equipe CASE') : (msg.sender_name || nome),
              conteudo: msg.content || (normalizedType !== 'text' ? `[${rawType}]` : ''),
              created_at: msg.timestamp,
              message_id: msg.message_id,
              is_from_team: isTeam,
              content_type: normalizedType,
              media_url: msg.media_url,
            };
          });
        }

        // Fallback: Evolution API direct
        if (!interactions.length && _waInst) {
          const res = await fetch(`${CONFIG.API_BASE}/api/evolution/chat/findMessages/${_waInst}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ where: { key: { remoteJid } }, limit: 30 }),
          });
          if (res.ok) {
            const data = await res.json();
            const msgs = data.messages?.records || data.messages || data || [];
            interactions = (Array.isArray(msgs) ? msgs : []).reverse().map(msg => {
              const pushName = msg.pushName || '';
              const pushLower = pushName.toLowerCase();
              const isTeam = msg.key?.fromMe || teamNames.has(pushLower) ||
                [...teamNames].some(tn => pushLower.includes(tn) || tn.includes(pushLower));
              return {
                sender: isTeam ? (pushName || 'Equipe CASE') : (pushName || nome),
                conteudo: this.getWaMessageText(msg),
                created_at: msg.messageTimestamp ? new Date(msg.messageTimestamp * 1000).toISOString() : null,
                is_from_team: isTeam,
              };
            }).filter(i => i.conteudo);
          }
        }

        if (this.data.detail) {
          this.data.detail.last_interactions = interactions;
          this.data.detail._waChat = chatObj;
          this.data.detail._waGroupJid = remoteJid;
          this.data.detail._waFromSupabase = usedSupabase;
          this.data.detail._waLoaded = true;

          // Calculate response time and unread count
          if (interactions.length) {
            // Find last team message and last mentee message
            let lastTeamIdx = -1, lastMenteeIdx = -1;
            for (let i = interactions.length - 1; i >= 0; i--) {
              if ((interactions[i].is_from_team || interactions[i].sender === 'Equipe CASE') && lastTeamIdx === -1) lastTeamIdx = i;
              if (!interactions[i].is_from_team && interactions[i].sender !== 'Equipe CASE' && lastMenteeIdx === -1) lastMenteeIdx = i;
              if (lastTeamIdx >= 0 && lastMenteeIdx >= 0) break;
            }
            // Unread = messages from mentee after last team response
            let unread = 0;
            if (lastTeamIdx >= 0) {
              for (let i = lastTeamIdx + 1; i < interactions.length; i++) {
                if (!interactions[i].is_from_team && interactions[i].sender !== 'Equipe CASE') unread++;
              }
            } else {
              // Team never responded — all mentee msgs are "unread"
              unread = interactions.filter(m => !m.is_from_team && m.sender !== 'Equipe CASE').length;
            }
            this.data.detail._waUnreadCount = unread;

            // Response time: if last message is from mentee, how long ago?
            if (lastMenteeIdx >= 0 && (lastTeamIdx < 0 || lastMenteeIdx > lastTeamIdx)) {
              const lastMenteeTime = new Date(interactions[lastMenteeIdx].created_at);
              const hours = Math.round((Date.now() - lastMenteeTime.getTime()) / (1000 * 60 * 60));
              let label = '';
              if (hours < 1) label = 'Respondido agora';
              else if (hours < 24) label = `Sem resposta ha ${hours}h`;
              else { const days = Math.round(hours / 24); label = `Sem resposta ha ${days} dia${days > 1 ? 's' : ''}`; }
              this.data.detail._waResponseInfo = { hours, label };
            } else {
              this.data.detail._waResponseInfo = null;
            }
          }
        }
      } catch (e) {
        console.warn('[Spalla] Could not load detail WA messages:', e.message);
        if (this.data.detail) this.data.detail._waLoaded = true;
      }
    },

    // Send message from mentee detail WhatsApp tab
    async sendDetailWaMessage() {
      const text = this.ui.detailWaMessage?.trim();
      if (!text) return;
      const jid = this.data.detail?._waGroupJid;
      if (!jid) { this.toast('Nenhum grupo vinculado a este mentorado', 'warning'); return; }
      const { instance } = this._waActiveInstance();
      if (!instance) { this.toast('WhatsApp nao conectado', 'warning'); return; }

      this.ui.detailWaMessage = '';
      // Optimistic insert
      if (this.data.detail?.last_interactions) {
        this.data.detail.last_interactions.push({
          sender: 'Equipe CASE',
          conteudo: text,
          created_at: new Date().toISOString(),
          status: 'pending',
          is_from_team: true,
        });
      }
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/wa/send-text`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
          body: JSON.stringify({ number: jid, text, instance, group_jid: jid }),
        });
        if (!res.ok) { const err = await res.json().catch(() => ({})); throw new Error(err.error || `HTTP ${res.status}`); }
        // TASK-04: Create follow-up task if enabled
        if (this.ui.waFollowupEnabled && sb) {
          await this._createFollowupTask(text, jid);
          this.ui.waFollowupEnabled = false;
        }
        this.toast('Mensagem enviada', 'success');
      } catch (e) {
        this.toast('Erro ao enviar: ' + e.message, 'error');
      }
    },

    async _createFollowupTask(msgText, groupJid) {
      const mentoradoNome = this.data.detail?.nome || '';
      const days = this.ui.waFollowupDays || 2;
      const dueDate = new Date();
      dueDate.setDate(dueDate.getDate() + days);
      const dueDateStr = dueDate.toISOString().split('T')[0];
      const responsavel = this.currentUserName || '';
      const preview = msgText.length > 100 ? msgText.substring(0, 100) + '...' : msgText;

      const taskData = {
        titulo: `Follow-up — ${mentoradoNome}`,
        descricao: `Mensagem enviada: "${preview}" em ${new Date().toLocaleDateString('pt-BR')}\nChecar se mentorado respondeu.`,
        tipo: 'follow_up',
        prioridade: 'normal',
        responsavel,
        mentorado_nome: mentoradoNome,
        mentorado_id: this.data.detail?.id || null,
        tags: ['follow-up'],
        data_fim: dueDateStr,
        status: 'pendente',
        fonte: 'auto_followup',
        follow_up_group_jid: groupJid || null,
      };

      const { data: created, error } = await sb.from('god_tasks').insert(taskData).select().single();
      if (error) { console.warn('[follow-up] Error creating task:', error); return; }
      this.data.tasks.push(created);
      this._cacheTasksLocal();
      this.toast(`Follow-up criado: checar em ${days} dias`, 'info');
    },

    // --- Google Drive Sync ---
    driveFiles: { files: [], folder_url: '', created_folder: false },

    async syncDriveFiles() {
      if (!this.data.detail?.id || !this.data.detail?.nome) return;
      this.ui.driveSyncing = true;
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/drive/sync`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
          body: JSON.stringify({
            mentorado_id: this.data.detail.id,
            mentorado_nome: this.data.detail.nome,
            produto: 'mentory',
          }),
        });
        const data = await res.json();
        if (res.ok) {
          this.driveFiles = data;
        } else {
          this.toast('Erro Drive: ' + (data.error || ''), 'error');
        }
      } catch (e) { this.toast('Erro de conexão com Drive', 'error'); }
      this.ui.driveSyncing = false;
    },

    // --- Resumo Semanal ---
    weeklySummary: { text: '', loading: false, stats: null },

    async loadWeeklySummary(mentoradoId) {
      if (!mentoradoId) return;
      this.weeklySummary.loading = true;
      this.weeklySummary.text = '';
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/mentee/weekly-summary`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
          body: JSON.stringify({ mentorado_id: mentoradoId }),
        });
        const data = await res.json();
        if (res.ok) {
          this.weeklySummary.text = data.summary || '';
          this.weeklySummary.stats = data.stats || null;
        } else {
          this.weeklySummary.text = 'Erro: ' + (data.error || 'Falha ao gerar resumo');
        }
      } catch (e) {
        this.weeklySummary.text = 'Erro de conexão';
      }
      this.weeklySummary.loading = false;
    },

    // --- Contexto Onboarding ---
    obContext: { trilha: null, etapas: [], loading: false },

    async loadObContext(mentoradoId) {
      if (!sb || !mentoradoId) return;
      this.obContext.loading = true;
      try {
        const { data: trilhas } = await sb.from('ob_trilhas')
          .select('*')
          .eq('mentorado_id', mentoradoId)
          .limit(1);
        this.obContext.trilha = trilhas?.[0] || null;

        if (this.obContext.trilha) {
          const { data: etapas } = await sb.from('ob_etapas')
            .select('*, ob_tarefas(*)')
            .eq('trilha_id', this.obContext.trilha.id)
            .order('ordem');
          this.obContext.etapas = etapas || [];
        }
      } catch (e) { console.warn('[ob-context]', e); }
      this.obContext.loading = false;
    },

    // --- Alertas Etapa Atrasada (Onboarding) ---
    ccAlertasEtapaAtrasada() {
      const trilhas = this.data.obTrilhas || [];
      const now = new Date();
      const alertas = [];
      for (const t of trilhas) {
        if (t.status === 'concluido') continue;
        const atrasadas = (t.tarefas_atrasadas || 0);
        if (atrasadas > 0) {
          alertas.push({
            mentorado_id: t.mentorado_id,
            mentorado_nome: t.mentorado_nome || 'Mentorado',
            etapa: t.etapa_atual || 'Onboarding',
            atrasadas,
            progresso: t.progresso_pct || 0,
          });
        }
      }
      return alertas.sort((a, b) => b.atrasadas - a.atrasadas);
    },

    // === CC V2: Board do Consultor ("Tony Stark") ===
    // Uses vw_god_overview which already has: consultor_responsavel, dias_desde_call, ultima_call_data, tarefas_pendentes, tarefas_atrasadas
    ccConsultantBoard() {
      const mentees = this.data.mentees || [];
      const fullName = (this.auth.currentUser?.full_name || this.auth.currentUser?.user_metadata?.full_name || '').toLowerCase().trim();
      const me = fullName.split(' ')[0] || (this.auth.currentUser?.email || '').toLowerCase().split('@')[0] || 'kaique';
      const dsProds = this.data.dsProducoes || [];
      const dsDocs = this.data.dsAllDocs || [];
      const now = new Date();

      // Filter by consultant's portfolio (admin sees all)
      const isAdmin = ['kaique', 'gobbi', 'queila'].some(n => fullName.includes(n));
      const myMentees = isAdmin ? mentees : mentees.filter(m =>
        (m.consultor_responsavel || '').toLowerCase() === me.toLowerCase()
      );

      const board = [];
      for (const m of myMentees) {
        // Use data from vw_god_overview directly
        // If no call ever, fallback to days since entry (not 999)
        let diasSemCall = m.dias_desde_call;
        if (diasSemCall == null && m.data_entrada) {
          diasSemCall = Math.floor((now - new Date(m.data_entrada)) / 86400000);
        }
        if (diasSemCall == null) diasSemCall = 999;
        const ultimaCallDate = m.ultima_call_data ? new Date(m.ultima_call_data).toLocaleDateString('pt-BR') : 'Nunca';

        // Dossiê from ds_producoes (if loaded)
        const prod = dsProds.find(p => p.mentorado_id === m.id);
        const docs = dsDocs.filter(d => d.producao_id === prod?.producao_id);
        const dossieEtapa = docs.length ? docs.map(d => (DS_ESTAGIOS.find(e => e.id === d.estagio_atual) || {}).label || d.estagio_atual).join(', ') : null;
        const dossiePrazo = prod?.prazo_entrega || prod?.prazo_interno || null;
        const dossieAtrasado = dossiePrazo && new Date(dossiePrazo) < now && prod?.status !== 'finalizado';

        // Urgency score
        let urgency = 0;
        if (m.tarefas_atrasadas) urgency += m.tarefas_atrasadas * 10;
        if (dossieAtrasado) urgency += 15;
        if (diasSemCall >= 30) urgency += 10;
        else if (diasSemCall >= 14) urgency += 5;
        if (m.tarefas_pendentes) urgency += m.tarefas_pendentes;

        board.push({
          id: m.id,
          nome: m.nome,
          instagram: m.instagram,
          dataEntrada: m.data_entrada || m.created_at || null,
          consultor: m.consultor_responsavel || '',
          fase: m.fase_jornada || 'ativo',
          tarefasPendentes: m.tarefas_pendentes || 0,
          tarefasAtrasadas: m.tarefas_atrasadas || 0,
          diasSemCall,
          ultimaCall: ultimaCallDate,
          dossieEtapa,
          dossieAtrasado,
          statusFinanceiro: m.status_financeiro || 'em_dia',
          contratoAssinado: m.contrato_assinado !== false,
          urgency,
        });
      }

      return board.sort((a, b) => b.urgency - a.urgency);
    },

    ccBoardFiltered() {
      const board = this.ccConsultantBoard();
      const f = this.ui.ccBoardFilter || 'priority';
      if (f === 'all') return board;
      if (f === 'priority') return board.filter(m => ['onboarding', 'concepcao'].includes(m.fase));
      return board.filter(m => m.fase === f);
    },

    ccBoardGrouped() {
      const board = this.ccBoardFiltered();
      const PHASE_ORDER = ['onboarding', 'concepcao', 'validacao', 'otimizacao', 'escala'];
      const PHASE_LABELS = { onboarding: 'Onboarding', concepcao: 'Concepção', validacao: 'Validação', otimizacao: 'Otimização', escala: 'Escala' };
      const groups = {};
      // Dedupe by id — previne duplicação se data.mentees tiver entries duplicadas
      const seen = new Set();
      for (const m of board) {
        if (seen.has(m.id)) continue;
        seen.add(m.id);
        // Só agrupa se a fase é válida. Fases inválidas (ativo, execucao, etc.) são ignoradas
        // pra não poluir os grupos onboarding/concepcao.
        if (!m.fase || !PHASE_ORDER.includes(m.fase)) continue;
        if (!groups[m.fase]) groups[m.fase] = [];
        groups[m.fase].push(m);
      }
      return PHASE_ORDER.filter(p => groups[p]).map(p => ({ phase: p, label: PHASE_LABELS[p], items: groups[p] }));
    },

    ccBoardToggle(id) {
      this.ui.ccBoardExpanded = { ...this.ui.ccBoardExpanded, [id]: !this.ui.ccBoardExpanded[id] };
    },

    // Dossiê status for a mentee (used in expanded card)
    ccBoardDossie(mentoradoId) {
      const prod = (this.data.dsProducoes || []).find(p => p.mentorado_id === mentoradoId);
      if (!prod) return null;
      const docs = (this.data.dsAllDocs || []).filter(d => d.producao_id === prod.producao_id);
      const cfg = DS_STATUS_PRODUCAO.find(s => s.id === prod.status) || DS_STATUS_PRODUCAO[0];
      return {
        statusId: prod.status,
        statusLabel: cfg.label,
        statusColor: cfg.color,
        docs: docs.map(d => {
          const tipo = DS_DOC_TIPOS.find(t => t.id === d.tipo) || { label: d.tipo, color: '#6b7280' };
          const estagio = DS_ESTAGIOS.find(e => e.id === d.estagio_atual) || DS_ESTAGIOS[0];
          return { tipo: tipo.label, tipoColor: tipo.color, estagio: estagio.label, estagioColor: estagio.color };
        }),
      };
    },

    // Bifurcated tasks: team delivers vs mentee executes
    ccBoardTasks(mentoradoId) {
      const mentee = (this.data.mentees || []).find(x => x.id === mentoradoId);
      if (!mentee) return { equipe: [], mentorado: [], total: 0 };
      const firstName = (mentee.nome || '').split(' ')[0].toLowerCase();
      const active = (this.data.tasks || []).filter(t =>
        t.mentorado_id === mentoradoId &&
        !['concluida', 'arquivada', 'cancelada'].includes(t.status)
      );
      const equipe = [];
      const mentorado = [];
      for (const t of active) {
        const resp = (t.responsavel || '').toLowerCase();
        if (firstName.length > 2 && resp.includes(firstName)) {
          mentorado.push(t);
        } else {
          equipe.push(t);
        }
      }
      return { equipe: equipe.slice(0, 4), mentorado: mentorado.slice(0, 4), total: active.length };
    },

    // Onboarding trilha for a mentee
    ccBoardOb(mentoradoId) {
      return (this.data.obTrilhas || []).find(t => t.mentorado_id === mentoradoId && t.status !== 'concluido') || null;
    },

    // --- Grupos WA por fase ---
    get waGroupsByFase() {
      const groups = this.data.waGroups || [];
      const fases = {};
      const faseOrder = ['interno', 'onboarding', 'acompanhamento', 'producao', 'entrega', 'pos_entrega', 'geral'];
      const faseLabels = {
        interno: 'Interno', onboarding: 'Onboarding', acompanhamento: 'Acompanhamento',
        producao: 'Produção', entrega: 'Entrega', pos_entrega: 'Pós-entrega', geral: 'Geral',
      };
      for (const g of groups) {
        const fase = g.fase || 'geral';
        if (!fases[fase]) fases[fase] = { label: faseLabels[fase] || fase, groups: [] };
        fases[fase].groups.push(g);
      }
      return faseOrder.filter(f => fases[f]).map(f => fases[f]);
    },

    async updateWaGroupFase(groupId, fase) {
      if (!sb) return;
      await sb.from('wa_groups').update({ fase }).eq('id', groupId);
      const g = this.data.waGroups.find(gr => gr.id === groupId);
      if (g) g.fase = fase;
      this.toast('Grupo atualizado', 'success');
    },

    // --- WA Intelligence Layer ---
    waIntel: { classifications: [], percepcoes: [], pendencias: [], loading: false },

    async loadWaIntelligence(mentoradoId) {
      if (!sb || !mentoradoId) return;
      this.waIntel.loading = true;
      try {
        // Classifications summary (last 30 days)
        const thirtyDaysAgo = new Date(Date.now() - 30 * 86400000).toISOString();
        const { data: interactions } = await sb.from('interacoes_mentoria')
          .select('categoria,tipo_interacao,sentimento,score_engajamento,requer_resposta,respondido,conteudo,sender_name,created_at,urgencia_resposta,intencao_primaria')
          .eq('mentorado_id', mentoradoId)
          .gte('created_at', thirtyDaysAgo)
          .order('created_at', { ascending: false })
          .limit(100);

        // Aggregate classifications
        const catCounts = {};
        const sentCounts = {};
        let pendCount = 0;
        for (const i of (interactions || [])) {
          catCounts[i.categoria || 'OUTROS'] = (catCounts[i.categoria || 'OUTROS'] || 0) + 1;
          sentCounts[i.sentimento || 'neutro'] = (sentCounts[i.sentimento || 'neutro'] || 0) + 1;
          if (i.requer_resposta && !i.respondido) pendCount++;
        }
        this.waIntel.classifications = {
          total: (interactions || []).length,
          categorias: Object.entries(catCounts).sort((a, b) => b[1] - a[1]),
          sentimentos: Object.entries(sentCounts).sort((a, b) => b[1] - a[1]),
          pendencias: pendCount,
          avgEngajamento: interactions?.length ? Math.round(interactions.reduce((s, i) => s + (i.score_engajamento || 0), 0) / interactions.length) : 0,
        };

        // Pendências (requer_resposta = true, respondido = false)
        this.waIntel.pendencias = (interactions || []).filter(i => i.requer_resposta && !i.respondido);

        // Percepções (all time, last 20)
        const { data: percs } = await sb.from('percepcoes_mentorado')
          .select('*')
          .eq('mentorado_id', mentoradoId)
          .order('created_at', { ascending: false })
          .limit(20);
        this.waIntel.percepcoes = percs || [];
      } catch (e) {
        console.warn('[wa-intel] Error:', e);
      }
      this.waIntel.loading = false;
    },

    // --- Card Comments (dossiê + mentorado) ---
    cardComments: [],
    cardCommentInput: '',
    cardCommentsLoading: false,

    async loadCardComments(opts = {}) {
      if (!sb) return;
      this.cardCommentsLoading = true;
      let query = sb.from('card_comments').select('*').order('created_at', { ascending: true });
      if (opts.producao_id) query = query.eq('producao_id', opts.producao_id);
      else if (opts.documento_id) query = query.eq('documento_id', opts.documento_id);
      else if (opts.mentorado_id) query = query.eq('mentorado_id', opts.mentorado_id);
      else { this.cardCommentsLoading = false; return; }
      const { data, error } = await query.limit(200);
      this.cardComments = error ? [] : (data || []);
      this.cardCommentsLoading = false;
    },

    async addCardComment(opts = {}) {
      if (!sb || !this.cardCommentInput.trim()) return;
      const row = {
        content: this.cardCommentInput.trim(),
        content_type: 'text',
        author: this.currentUserName || 'Equipe',
      };
      if (opts.producao_id) row.producao_id = opts.producao_id;
      if (opts.documento_id) row.documento_id = opts.documento_id;
      if (opts.mentorado_id) row.mentorado_id = opts.mentorado_id;

      const { data: created, error } = await sb.from('card_comments').insert(row).select().single();
      if (error) { this.toast('Erro ao salvar comentário: ' + error.message, 'error'); return; }
      this.cardComments.push(created);

      // @mention detection → create task + notify
      const mentions = this.cardCommentInput.match(/@(\w+)/g);
      if (mentions?.length) {
        for (const mention of mentions) {
          const name = mention.slice(1); // remove @
          const member = (this.data.members || []).find(m =>
            m.nome_curto?.toLowerCase() === name.toLowerCase()
          ) || TEAM_MEMBERS.find(m => m.name.toLowerCase() === name.toLowerCase());
          if (member) {
            const mentoradoNome = this.data.detail?.nome || '';
            const taskData = {
              titulo: `@${member.nome_curto || member.name}: ${this.cardCommentInput.substring(0, 60)}`,
              descricao: `Menção em comentário por ${row.author}:\n"${this.cardCommentInput}"\n\nMentorado: ${mentoradoNome}`,
              tipo: 'geral',
              prioridade: 'normal',
              responsavel: member.nome_curto || member.name,
              mentorado_nome: mentoradoNome,
              mentorado_id: opts.mentorado_id || null,
              status: 'pendente',
              fonte: 'mention',
                };
            const { data: task } = await sb.from('god_tasks').insert(taskData).select().single();
            if (task) {
              this.data.tasks.push(task);
              this._notifyTaskViaWa(task).catch(() => {});
              this.toast(`Tarefa criada para @${member.nome_curto || member.name}`, 'info');
            }
          }
        }
      }
      this.cardCommentInput = '';
    },

    async deleteCardComment(commentId) {
      if (!sb || !confirm('Excluir comentário?')) return;
      await sb.from('card_comments').delete().eq('id', commentId);
      this.cardComments = this.cardComments.filter(c => c.id !== commentId);
    },

    // --- Batch Task from Audio (TASK-07) ---
    batchTask: {
      recording: false,
      recorder: null,
      transcribing: false,
      transcript: '',
      extractedTasks: [],
      saving: false,
    },

    async batchTaskStartRecording() {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        const recorder = new MediaRecorder(stream, { mimeType: 'audio/webm;codecs=opus' });
        const chunks = [];
        recorder.ondataavailable = (e) => { if (e.data.size > 0) chunks.push(e.data); };
        recorder.onstop = () => {
          stream.getTracks().forEach(t => t.stop());
          const blob = new Blob(chunks, { type: 'audio/webm' });
          this.batchTaskProcessAudio(blob);
        };
        recorder.start();
        this.batchTask.recorder = recorder;
        this.batchTask.recording = true;
        this.batchTask.transcript = '';
        this.batchTask.extractedTasks = [];
      } catch (e) {
        this.toast('Erro ao acessar microfone: ' + e.message, 'error');
      }
    },

    batchTaskStopRecording() {
      if (this.batchTask.recorder && this.batchTask.recording) {
        this.batchTask.recorder.stop();
        this.batchTask.recording = false;
      }
    },

    async batchTaskProcessAudio(blob) {
      this.batchTask.transcribing = true;
      try {
        const formData = new FormData();
        formData.append('audio', blob, 'batch-tasks.webm');
        const res = await fetch(`${CONFIG.API_BASE}/api/tasks/from-audio`, {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${this.auth.accessToken}` },
          body: formData,
        });
        const data = await res.json();
        if (!res.ok) { this.toast('Erro: ' + (data.error || 'Falha na transcrição'), 'error'); return; }
        this.batchTask.transcript = data.transcript || '';
        this.batchTask.extractedTasks = (data.tasks || []).map((t, i) => ({
          ...t,
          _idx: i,
          _selected: true,
          titulo: t.titulo || '',
          descricao: t.descricao || '',
          responsavel: t.responsavel || '',
          mentorado: t.mentorado || '',
          prioridade: t.prioridade || 'normal',
          tipo: t.tipo || 'geral',
          prazo_dias: t.prazo_dias || null,
          subtasks: (t.subtasks || []).map(s => typeof s === 'string' ? { text: s, done: false } : s),
        }));
        if (!this.batchTask.extractedTasks.length) {
          this.toast('Nenhuma tarefa identificada no áudio', 'warning');
        }
      } catch (e) {
        this.toast('Erro ao processar áudio: ' + e.message, 'error');
      } finally {
        this.batchTask.transcribing = false;
      }
    },

    async batchTaskConfirmAll() {
      if (!sb) return;
      const selected = this.batchTask.extractedTasks.filter(t => t._selected);
      if (!selected.length) return;
      this.batchTask.saving = true;
      let created = 0;
      for (const t of selected) {
        const dueDate = t.prazo_dias ? new Date(Date.now() + t.prazo_dias * 86400000).toISOString().split('T')[0] : null;
        const row = {
          titulo: t.titulo,
          tipo: t.tipo,
          prioridade: t.prioridade,
          responsavel: t.responsavel || '',
          mentorado_nome: t.mentorado || '',
          data_fim: dueDate,
          status: 'pendente',
          fonte: 'audio_batch',
          descricao: t.descricao ? `${t.descricao}\n\n[Criada por áudio em ${new Date().toLocaleDateString('pt-BR')}]` : `Criada por áudio em ${new Date().toLocaleDateString('pt-BR')}`,
        };
        const { data: newTask, error } = await sb.from('god_tasks').insert(row).select().single();
        if (!error && newTask) {
          this.data.tasks.push(newTask);
          // Create subtasks if any
          if (t.subtasks?.length && newTask.id) {
            const subRows = t.subtasks.map((s, idx) => ({
              task_id: newTask.id,
              texto: s.text || s,
              done: false,
              sort_order: idx,
            }));
            await sb.from('god_task_subtasks').insert(subRows);
          }
          created++;
        }
      }
      this._cacheTasksLocal();
      this.batchTask.saving = false;
      this.batchTask.extractedTasks = [];
      this.batchTask.transcript = '';
      this.ui.batchTaskModal = false;
      this.toast(`${created} tarefas criadas a partir do áudio`, 'success');
    },

    // --- Feedback Form ---
    feedbackForm: {
      titulo: '',
      descricao: '',
      categoria: 'bug',
      prioridade: 'normal',
    },

    get filteredFeedback() {
      let list = [...this.data.feedbackList];
      if (this.ui.feedbackCatFilter) list = list.filter(f => f.categoria === this.ui.feedbackCatFilter);
      if (this.ui.feedbackStatusFilter) list = list.filter(f => f.status === this.ui.feedbackStatusFilter);
      list.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
      return list;
    },

    async loadFeedback() {
      if (!sb) return;
      const { data, error } = await sb.from('god_feedback').select('*').order('created_at', { ascending: false }).limit(200);
      if (!error && data) this.data.feedbackList = data;
    },

    async submitFeedback() {
      if (!sb || !this.feedbackForm.titulo.trim()) return;
      const row = {
        titulo: this.feedbackForm.titulo.trim(),
        descricao: this.feedbackForm.descricao.trim() || null,
        categoria: this.feedbackForm.categoria,
        prioridade: this.feedbackForm.prioridade,
        created_by: this.currentUserName || 'equipe',
      };
      const { data: created, error } = await sb.from('god_feedback').insert(row).select().single();
      if (error) { this.toast('Erro ao enviar feedback: ' + error.message, 'error'); return; }
      this.data.feedbackList.unshift(created);
      this.feedbackForm = { titulo: '', descricao: '', categoria: 'bug', prioridade: 'normal' };
      this.ui.feedbackFormOpen = false;
      this.toast('Feedback enviado', 'success');
    },

    async updateFeedbackStatus(fbId, newStatus) {
      if (!sb) return;
      const { error } = await sb.from('god_feedback').update({ status: newStatus }).eq('id', fbId);
      if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      const fb = this.data.feedbackList.find(f => f.id === fbId);
      if (fb) fb.status = newStatus;
      this.toast('Status atualizado', 'success');
    },

    async convertFeedbackToTask(fb) {
      if (!sb) return;
      const taskData = {
        titulo: fb.titulo,
        descricao: `[Convertido de feedback]\n${fb.descricao || ''}\n\nCategoria: ${fb.categoria}\nPrioridade sentida: ${fb.prioridade}\nReportado por: ${fb.created_by}`,
        tipo: 'bug_report',
        prioridade: fb.prioridade,
        responsavel: 'kaique',
        space_id: 'space_sistema',
        status: 'pendente',
        fonte: 'feedback',
        tags: [fb.categoria],
      };
      const { data: created, error } = await sb.from('god_tasks').insert(taskData).select().single();
      if (error) { this.toast('Erro ao criar tarefa: ' + error.message, 'error'); return; }
      // Update feedback status
      await sb.from('god_feedback').update({ status: 'convertido', converted_task_id: created.id }).eq('id', fb.id);
      fb.status = 'convertido';
      fb.converted_task_id = created.id;
      this.data.tasks.push(created);
      this._cacheTasksLocal();
      this.toast('Tarefa criada a partir do feedback', 'success');
    },

    async discardFeedback(fbId, motivo) {
      if (!sb) return;
      const { error } = await sb.from('god_feedback').update({ status: 'descartado', descarte_motivo: motivo || null }).eq('id', fbId);
      if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      const fb = this.data.feedbackList.find(f => f.id === fbId);
      if (fb) { fb.status = 'descartado'; fb.descarte_motivo = motivo; }
      this.toast('Feedback descartado', 'info');
    },

    // --- Bulk Follow-up State ---
    bulkFollowup: {
      template: 'Oi {nome}! Passando pra checar como estão as coisas. Precisa de algo?',
      days: 2,
      mentees: [],
      sending: false,
      sent: 0,
    },

    async openBulkFollowup() {
      if (!sb) return;
      this.bulkFollowup.mentees = [];
      this.bulkFollowup.sending = false;
      this.bulkFollowup.sent = 0;

      // Load mentorados with their WA groups and last response info
      const mentorados = this.data.mentorados || [];
      const waGroups = await sb.from('wa_groups').select('group_jid,mentorado_id').then(r => r.data || []);
      const groupMap = {};
      for (const g of waGroups) { if (g.mentorado_id) groupMap[g.mentorado_id] = g.group_jid; }

      const menteeList = [];
      for (const m of mentorados) {
        const jid = groupMap[m.id];
        if (!jid) continue; // skip mentorados without WA group

        // Get last team message and last mentorado message
        const { data: lastTeam } = await sb.from('whatsapp_messages')
          .select('created_at')
          .eq('group_id', jid).eq('is_from_team', true)
          .order('created_at', { ascending: false }).limit(1);

        const { data: lastMentee } = await sb.from('whatsapp_messages')
          .select('created_at,content')
          .eq('group_id', jid).eq('is_from_team', false)
          .order('created_at', { ascending: false }).limit(1);

        const lastTeamDate = lastTeam?.[0]?.created_at ? new Date(lastTeam[0].created_at) : null;
        const lastMenteeDate = lastMentee?.[0]?.created_at ? new Date(lastMentee[0].created_at) : null;

        // Calculate days since last response from mentee (or since team's last msg)
        let daysSinceResponse = null;
        if (lastTeamDate && (!lastMenteeDate || lastMenteeDate < lastTeamDate)) {
          daysSinceResponse = Math.floor((Date.now() - lastTeamDate) / (1000 * 60 * 60 * 24));
        }

        menteeList.push({
          id: m.id,
          nome: m.nome,
          jid,
          daysSinceResponse,
          lastMsg: lastMentee?.[0]?.content?.substring(0, 60) || '',
          selected: daysSinceResponse !== null && daysSinceResponse >= 3,
        });
      }

      // Sort: most days without response first
      menteeList.sort((a, b) => (b.daysSinceResponse || 0) - (a.daysSinceResponse || 0));
      this.bulkFollowup.mentees = menteeList;
      this.ui.bulkFollowupModal = true;
    },

    async executeBulkFollowup() {
      const selected = this.bulkFollowup.mentees.filter(m => m.selected);
      if (!selected.length || !this.bulkFollowup.template.trim()) return;

      this.bulkFollowup.sending = true;
      this.bulkFollowup.sent = 0;
      const { instance } = this._waActiveInstance();
      if (!instance) { this.toast('WhatsApp não conectado', 'warning'); this.bulkFollowup.sending = false; return; }

      let success = 0;
      for (const m of selected) {
        const text = this.bulkFollowup.template.replace(/\{nome\}/gi, m.nome.split(' ')[0]);
        try {
          await fetch(`${CONFIG.API_BASE}/api/wa/send-text`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
            body: JSON.stringify({ number: m.jid, text, instance, group_jid: m.jid }),
          });
          // Create follow-up task
          if (sb) {
            const dueDate = new Date();
            dueDate.setDate(dueDate.getDate() + this.bulkFollowup.days);
            await sb.from('god_tasks').insert({
              titulo: `Follow-up — ${m.nome}`,
              descricao: `Follow-up em bloco enviado em ${new Date().toLocaleDateString('pt-BR')}`,
              tipo: 'follow_up',
              prioridade: 'normal',
              responsavel: this.currentUserName || '',
              mentorado_nome: m.nome,
              mentorado_id: m.id,
              tags: ['follow-up'],
              data_fim: dueDate.toISOString().split('T')[0],
              status: 'pendente',
              fonte: 'auto_followup_bulk',
                  follow_up_group_jid: m.jid,
            });
          }
          success++;
        } catch (e) {
          console.warn(`[bulk-followup] Failed for ${m.nome}:`, e);
        }
        this.bulkFollowup.sent = success;
        // Small delay to respect rate limits
        await new Promise(r => setTimeout(r, 500));
      }

      this.bulkFollowup.sending = false;
      // Reload tasks
      await this.loadTasks?.();
      this.toast(`${success} follow-ups enviados, ${success} tarefas criadas`, 'success');
      this.ui.bulkFollowupModal = false;
    },

    // TASK-05: Check if incoming message resolves pending follow-up tasks
    async _checkFollowupResponse(groupJid, msg) {
      if (!sb || !groupJid) return;
      // Find pending follow-up tasks for this group
      const pendingFollowups = this.data.tasks.filter(t =>
        t.tipo === 'follow_up' &&
        t.status === 'pendente' &&
        t.follow_up_group_jid === groupJid &&
        !t.follow_up_responded_at
      );
      if (!pendingFollowups.length) return;

      const now = new Date().toISOString();
      const preview = (msg.content || '').substring(0, 80);
      for (const task of pendingFollowups) {
        // Mark as responded (but don't close — consultant decides)
        task.follow_up_responded_at = now;
        await sb.from('god_tasks').update({ follow_up_responded_at: now }).eq('id', task.id);
        // Add auto-comment
        await sb.from('god_task_comments').insert({
          task_id: task.id,
          author: 'Sistema',
          texto: `Mentorado respondeu em ${new Date().toLocaleDateString('pt-BR')}: "${preview}..."`,
        });
      }
      if (pendingFollowups.length) {
        this.toast(`${pendingFollowups.length} follow-up(s) sinalizados como respondidos`, 'info');
      }
    },

    // Date label for day separators in chat — accepts ISO string, Unix seconds, Date, or null
    waDateLabel(input) {
      if (input === null || input === undefined || input === '') return '';
      let d;
      if (input instanceof Date) {
        d = input;
      } else if (typeof input === 'number') {
        // Unix timestamp in seconds (Evolution API convention)
        d = new Date(input * 1000);
      } else {
        d = new Date(input);
      }
      if (isNaN(d.getTime())) return '';
      const today = new Date();
      const yesterday = new Date(today); yesterday.setDate(today.getDate() - 1);
      const sameDay = (a, b) => a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
      if (sameDay(d, today)) return 'Hoje';
      if (sameDay(d, yesterday)) return 'Ontem';
      const startToday = new Date(today.getFullYear(), today.getMonth(), today.getDate());
      const startD = new Date(d.getFullYear(), d.getMonth(), d.getDate());
      const diffDays = Math.round((startToday - startD) / 86400000);
      if (diffDays > 1 && diffDays < 7) {
        return d.toLocaleDateString('pt-BR', { weekday: 'long' }).replace(/^./, c => c.toUpperCase());
      }
      if (d.getFullYear() === today.getFullYear()) {
        return d.toLocaleDateString('pt-BR', { day: '2-digit', month: 'long' });
      }
      return d.toLocaleDateString('pt-BR', { day: '2-digit', month: 'long', year: 'numeric' });
    },

    shouldShowWaDateSeparator(msg, prevMsg) {
      const a = msg?.messageTimestamp ?? msg?.created_at;
      if (!a) return false;
      const b = prevMsg?.messageTimestamp ?? prevMsg?.created_at;
      if (!b) return true;
      return this.waDateLabel(a) !== this.waDateLabel(b);
    },

    // Onda 1: grouping — true se primeira bolha de um grupo (sender mudou, gap > 60s, ou novo dia)
    isWaFirstOfGroup(msg, prevMsg) {
      if (!prevMsg) return true;
      if (!!msg?.key?.fromMe !== !!prevMsg?.key?.fromMe) return true;
      if ((msg?.pushName || '') !== (prevMsg?.pushName || '')) return true;
      const a = Number(msg?.messageTimestamp || 0) * 1000;
      const b = Number(prevMsg?.messageTimestamp || 0) * 1000;
      if (a && b && Math.abs(a - b) > 60000) return true;
      return this.shouldShowWaDateSeparator(msg, prevMsg);
    },

    isDetailWaFirstOfGroup(msg, prevMsg) {
      if (!prevMsg) return true;
      const aTeam = !!(msg?.is_from_team || msg?.sender === 'Equipe CASE');
      const bTeam = !!(prevMsg?.is_from_team || prevMsg?.sender === 'Equipe CASE');
      if (aTeam !== bTeam) return true;
      if ((msg?.sender || '') !== (prevMsg?.sender || '')) return true;
      const a = new Date(msg?.created_at || 0).getTime();
      const b = new Date(prevMsg?.created_at || 0).getTime();
      if (a && b && Math.abs(a - b) > 60000) return true;
      return this.shouldShowWaDateSeparator(msg, prevMsg);
    },

    // Onda 5: gerador determinístico de waveform
    waAudioBars(msgId) {
      const id = String(msgId || 'wa');
      const bars = [];
      let h = 0;
      for (let i = 0; i < id.length; i++) h = ((h << 5) - h + id.charCodeAt(i)) | 0;
      for (let i = 0; i < 28; i++) {
        h = (h * 9301 + 49297) % 233280;
        const v = Math.abs(h % 100) / 100;
        const env = Math.sin((i / 28) * Math.PI);
        const height = 6 + v * 22 * (0.4 + env * 0.6);
        bars.push(Math.round(height));
      }
      return bars;
    },

    // Onda 5: player custom factory (rollback via body[data-wa-audio="legacy"])
    waAudioPlayer(url, msgId) {
      const parent = this;
      return {
        url, msgId,
        playing: false, progress: 0, duration: 0, currentTime: 0,
        speed: 1, speeds: [1, 1.5, 2], bars: [], audio: null,
        init() {
          this.bars = parent.waAudioBars(msgId);
          this.audio = new Audio(this.url);
          this.audio.preload = 'metadata';
          this.audio.addEventListener('loadedmetadata', () => { this.duration = this.audio.duration || 0; });
          this.audio.addEventListener('timeupdate', () => {
            this.currentTime = this.audio.currentTime || 0;
            this.progress = this.duration ? this.currentTime / this.duration : 0;
          });
          this.audio.addEventListener('ended', () => { this.playing = false; this.progress = 0; this.currentTime = 0; });
          this.audio.addEventListener('error', () => { this.playing = false; });
        },
        toggle() {
          if (!this.audio) return;
          if (this.playing) { this.audio.pause(); this.playing = false; }
          else { this.audio.play().then(() => this.playing = true).catch(() => this.playing = false); }
        },
        cycleSpeed() {
          const idx = this.speeds.indexOf(this.speed);
          this.speed = this.speeds[(idx + 1) % this.speeds.length];
          if (this.audio) this.audio.playbackRate = this.speed;
        },
        seekTo(barIdx) {
          if (!this.audio || !this.duration) return;
          this.audio.currentTime = this.duration * (barIdx / 28);
        },
        fmtTime(s) {
          if (!s || isNaN(s)) return '0:00';
          const m = Math.floor(s / 60);
          const sec = Math.floor(s % 60);
          return `${m}:${sec.toString().padStart(2, '0')}`;
        },
      };
    },

    // Onda 2: sidebar richness helpers
    getWaChatPreview(chat) {
      const lm = chat?.lastMessage;
      if (!lm?.message) return '';
      const m = lm.message;
      let txt = m.conversation || m.extendedTextMessage?.text || '';
      if (!txt) {
        if (m.imageMessage) txt = '📷 Imagem';
        else if (m.videoMessage) txt = '🎥 Vídeo';
        else if (m.audioMessage) txt = '🎤 Áudio';
        else if (m.documentMessage) txt = '📎 Documento';
        else if (m.stickerMessage) txt = 'Sticker';
        else txt = '';
      }
      const prefix = lm.key?.fromMe ? 'Você: ' : '';
      const out = (prefix + txt).replace(/\s+/g, ' ').trim();
      return out.length > 50 ? out.slice(0, 50) + '…' : out;
    },

    getWaChatTimestampLabel(chat) {
      const ts = chat?.lastMessage?.messageTimestamp || chat?.updatedAt;
      if (!ts) return '';
      const d = typeof ts === 'number' ? new Date(ts * 1000) : new Date(ts);
      if (isNaN(d.getTime())) return '';
      const now = new Date();
      const sameDay = d.getFullYear() === now.getFullYear() && d.getMonth() === now.getMonth() && d.getDate() === now.getDate();
      if (sameDay) return d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
      const diffDays = Math.round((now - d) / 86400000);
      if (diffDays === 1) return 'Ontem';
      if (diffDays < 7) return d.toLocaleDateString('pt-BR', { weekday: 'short' }).replace('.', '');
      return d.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' });
    },

    getWaChatUnread(chat) {
      const n = Number(chat?.unreadCount || chat?.unread || 0);
      return n > 0 ? n : 0;
    },

    getWaChatPendingHours(chat) {
      const lm = chat?.lastMessage;
      if (!lm || lm.key?.fromMe) return 0;
      const ts = Number(lm.messageTimestamp || 0);
      if (!ts) return 0;
      return Math.floor((Date.now() / 1000 - ts) / 3600);
    },

    getWaChatLinkedMentee(chat) {
      const jid = chat?.remoteJid || chat?.id;
      if (!jid) return null;
      const g = (this.data.waGroups || []).find(g => g.group_jid === jid);
      if (!g?.mentorado_id) return null;
      const m = (this.data.mentees || []).find(m => m.id === g.mentorado_id);
      return m ? { id: m.id, name: m.full_name || m.nome || 'Mentorado' } : null;
    },

    getWaChatPhone(chat) {
      const jid = chat?.remoteJid || chat?.id || '';
      if (jid.endsWith('@g.us')) return '';
      const num = jid.replace('@s.whatsapp.net', '').replace('@lid', '').replace(/\D/g, '');
      if (num.length >= 12) return `+${num.slice(0,2)} ${num.slice(2,4)} ${num.slice(4,9)}-${num.slice(9)}`;
      if (num.length >= 10) return `+${num}`;
      return '';
    },

    // Clean sender name — replace raw JID numbers with readable format
    waCleanSenderName(name) {
      if (!name) return 'Desconhecido';
      // If it's a pure number (JID), format as phone
      if (/^\d{10,15}$/.test(name)) {
        // Format: 5511999887766 → (55) 11 99988-7766
        if (name.length >= 12) return `+${name.slice(0,2)} ${name.slice(2,4)} ${name.slice(4,9)}-${name.slice(9)}`;
        return name;
      }
      // Remove @s.whatsapp.net or @lid suffix
      return name.replace(/@s\.whatsapp\.net$/, '').replace(/@lid$/, '');
    },

    // Resolve media URL for detail tab — S3 key → stream proxy, full URL → passthrough
    waDetailMediaUrl(url) {
      if (!url) return '';
      if (url.startsWith('http')) return url;
      // S3 key → stream proxy
      return `${CONFIG.API_BASE}/api/media/stream?key=${encodeURIComponent(url)}`;
    },

    openDetailWhatsApp() {
      const chat = this.data.detail?._waChat;
      if (chat) {
        this.navigate('whatsapp');
        this.fetchWhatsAppChats().then(() => {
          // Try to find the full chat object (with name/photo) from loaded chats
          const jid = chat.remoteJid || chat.id;
          const fullChat = this.data.whatsappChats.find(c => (c.remoteJid || c.id) === jid);
          this.selectWhatsAppChat(fullChat || chat);
        });
      } else {
        this.navigate('whatsapp');
        this.fetchWhatsAppChats();
      }
    },

    // Open WhatsApp and auto-select the mentee's group chat (Carteira quick action)
    async openMenteeChat(m) {
      if (!m) return;
      const jid = m.grupo_whatsapp_id;
      this.navigate('whatsapp');
      if (this.waSessionStatus() === 'connected') {
        await this.fetchWhatsAppChats();
      }
      if (jid) {
        const fullChat = this.data.whatsappChats.find(c => (c.remoteJid || c.id) === jid);
        await this.selectWhatsAppChat(fullChat || { remoteJid: jid, id: jid, name: m.nome || '' });
      } else {
        await this.selectWhatsAppChat(null);
      }
    },

    // Open WhatsApp from a wa_topic — uses group_jid to jump directly to the chat
    async openTopicChat(topic) {
      if (!topic) return;
      const jid = topic.group_jid;
      const name = topic.mentorado_nome || topic.title || '';
      this.navigate('whatsapp');
      if (this.waSessionStatus() === 'connected') {
        await this.fetchWhatsAppChats();
      }
      if (jid) {
        const fullChat = this.data.whatsappChats.find(c => (c.remoteJid || c.id) === jid);
        await this.selectWhatsAppChat(fullChat || { remoteJid: jid, id: jid, name });
      } else {
        await this.selectWhatsAppChat(null);
      }
    },

    // ===================== COMMAND CENTER COMPUTED =====================

    // WA Intelligence: mentorados com pendências ordenados por urgência
    ccWaPendencias() {
      return (this.data.waWeeklyStats || [])
        .filter(s => s.pendencias_abertas > 0)
        .sort((a, b) => (b.avg_horas_sem_resposta || 0) - (a.avg_horas_sem_resposta || 0));
    },

    // WA Intelligence: resumo geral da semana
    ccWaResumoSemana() {
      const stats = this.data.waWeeklyStats || [];
      return {
        totalInteracoes: stats.reduce((s, m) => s + (m.interacoes_semana || 0), 0),
        totalPendencias: stats.reduce((s, m) => s + (m.pendencias_abertas || 0), 0),
        totalDuvidasAbertas: stats.reduce((s, m) => s + (m.duvidas_sem_resposta || 0), 0),
        mentoradosAtivos: stats.filter(m => m.interacoes_semana > 0).length,
        mentoradosInativos: stats.filter(m => m.interacoes_semana === 0).length,
        celebracoes: stats.reduce((s, m) => s + (m.celebracoes_semana || 0), 0),
        negativos: stats.reduce((s, m) => s + (m.msgs_negativas_semana || 0), 0),
      };
    },

    // WA Intelligence: alertas abertos agrupados por severidade (Story 6)
    ccWaAlertas() {
      return this.data.waAlertas || [];
    },
    ccWaAlertasCriticos() {
      return (this.data.waAlertas || []).filter(a => a.severidade === 'critico' || a.severidade === 'alto');
    },

    // --- Percepcoes CRUD (Story 5) ---
    _percepcaoForm: { conteudo: '', tipo: 'observacao' },

    async addPercepcao(mentoradoId) {
      if (!sb || !mentoradoId || !this._percepcaoForm.conteudo.trim()) return;
      const { error } = await sb.from('percepcoes_mentorado').insert({
        mentorado_id: mentoradoId,
        conteudo: this._percepcaoForm.conteudo.trim(),
        tipo: this._percepcaoForm.tipo || 'observacao',
        autor: this.currentUserName || 'Equipe',
        fonte: 'dashboard',
      });
      if (error) return this.toast('Erro ao salvar percepção: ' + error.message, 'error');
      this._percepcaoForm = { conteudo: '', tipo: 'observacao' };
      await this.loadWaIntelligence(mentoradoId);
      this.toast('Percepção registrada', 'success');
    },

    async deletePercepcao(percId, mentoradoId) {
      if (!sb || !percId) return;
      const { error } = await sb.from('percepcoes_mentorado').delete().eq('id', percId);
      if (error) return this.toast('Erro ao remover: ' + error.message, 'error');
      await this.loadWaIntelligence(mentoradoId);
      this.toast('Percepção removida', 'info');
    },

    // --- Alertas CRUD (Story 6) ---
    _alertaForm: { titulo: '', tipo: 'custom', severidade: 'medio', descricao: '' },

    async addAlerta(mentoradoId) {
      if (!sb || !mentoradoId || !this._alertaForm.titulo.trim()) return;
      const { error } = await sb.from('alertas_mentorado').insert({
        mentorado_id: mentoradoId,
        titulo: this._alertaForm.titulo.trim(),
        tipo: this._alertaForm.tipo || 'custom',
        severidade: this._alertaForm.severidade || 'medio',
        descricao: this._alertaForm.descricao.trim() || null,
        fonte: 'equipe',
      });
      if (error) return this.toast('Erro ao criar alerta: ' + error.message, 'error');
      this._alertaForm = { titulo: '', tipo: 'custom', severidade: 'medio', descricao: '' };
      await this._reloadAlertas();
      this.toast('Alerta criado', 'success');
    },

    async resolveAlerta(alertaId) {
      if (!sb || !alertaId) return;
      const { error } = await sb.from('alertas_mentorado').update({
        resolvido: true,
        resolvido_por: this.currentUserName || 'Equipe',
        resolvido_at: new Date().toISOString(),
      }).eq('id', alertaId);
      if (error) return this.toast('Erro ao resolver: ' + error.message, 'error');
      await this._reloadAlertas();
      this.toast('Alerta resolvido', 'success');
    },

    async _reloadAlertas() {
      if (!sb) return;
      const { data } = await sb.from('vw_alertas_command_center').select('*');
      if (data) this.data.waAlertas = data;
    },

    // WA Intel: stats do mentorado selecionado na ficha
    menteeWaStats() {
      const mid = this.data.detail?.profile?.id;
      if (!mid) return null;
      return (this.data.waWeeklyStats || []).find(s => s.mentorado_id === mid) || null;
    },

    // Story 3.1: Workload por membro da equipe
    ccWorkloadEquipe() {
      const tasks = this.data.tasks || [];
      const members = this.data.members || [];
      const byMember = {};
      for (const t of tasks) {
        const resp = (t.responsavel || '').toLowerCase().trim();
        if (!resp || resp === 'sistema') continue;
        if (!byMember[resp]) byMember[resp] = { pendente: 0, em_andamento: 0, concluida: 0, total: 0, atrasadas: 0 };
        const s = t.status || 'pendente';
        if (s === 'concluida' || s === 'cancelada') byMember[resp].concluida++;
        else if (s === 'em_andamento') byMember[resp].em_andamento++;
        else byMember[resp].pendente++;
        byMember[resp].total++;
        if (s !== 'concluida' && s !== 'cancelada' && t.data_fim) {
          const due = new Date(t.data_fim);
          if (due < new Date()) byMember[resp].atrasadas++;
        }
      }
      return members
        .filter(m => m.ativo !== false)
        .map(m => {
          const key = (m.nome_curto || m.id || '').toLowerCase();
          const stats = byMember[key] || { pendente: 0, em_andamento: 0, concluida: 0, total: 0, atrasadas: 0 };
          return { ...stats, id: m.id, nome: m.nome_curto || m.nome_completo, cor: m.cor || '#6366f1', cargo: m.cargo || '' };
        })
        .filter(m => m.total > 0)
        .sort((a, b) => (b.em_andamento + b.pendente) - (a.em_andamento + a.pendente));
    },

    ccSelectedSprint() {
      const sprints = (this.data.sprints || []).slice().sort((a, b) => (a.inicio || '').localeCompare(b.inicio || ''));
      if (!sprints.length) return null;
      const today = new Date().toISOString().slice(0, 10);
      let activeIdx = sprints.findIndex(s => s.inicio <= today && today <= s.fim);
      if (activeIdx < 0) activeIdx = sprints.findIndex(s => s.status === 'ativo');
      if (activeIdx < 0) activeIdx = 0;
      const idx = Math.max(0, Math.min(sprints.length - 1, activeIdx + (this.ui.ccWeekOffset || 0)));
      return sprints[idx];
    },

    ccWeekNavLabel() {
      if (this.ui.ccWeekOffset === 0) return 'Esta semana';
      const sel = this.ccSelectedSprint();
      return sel ? sel.nome : (this.ui.ccWeekOffset < 0 ? 'Semana anterior' : 'Próxima semana');
    },

    ccWeekNavCanPrev() {
      const sprints = (this.data.sprints || []).slice().sort((a, b) => (a.inicio || '').localeCompare(b.inicio || ''));
      if (sprints.length <= 1) return false;
      const today = new Date().toISOString().slice(0, 10);
      let activeIdx = sprints.findIndex(s => s.inicio <= today && today <= s.fim);
      if (activeIdx < 0) activeIdx = sprints.findIndex(s => s.status === 'ativo');
      if (activeIdx < 0) activeIdx = 0;
      return activeIdx + (this.ui.ccWeekOffset || 0) > 0;
    },

    ccWeekNavCanNext() {
      const sprints = (this.data.sprints || []).slice().sort((a, b) => (a.inicio || '').localeCompare(b.inicio || ''));
      if (sprints.length <= 1) return false;
      const today = new Date().toISOString().slice(0, 10);
      let activeIdx = sprints.findIndex(s => s.inicio <= today && today <= s.fim);
      if (activeIdx < 0) activeIdx = sprints.findIndex(s => s.status === 'ativo');
      if (activeIdx < 0) activeIdx = 0;
      return activeIdx + (this.ui.ccWeekOffset || 0) < sprints.length - 1;
    },

    ccTasksByStatus() {
      // Use live ClickUp data only for current week (offset=0)
      if (this.data.ccData?.by_status && (this.ui.ccWeekOffset || 0) === 0) {
        const s = this.data.ccData.by_status;
        return {
          backlog:    s.backlog    || [],
          inProgress: s.em_andamento || [],
          review:     s.em_revisao  || [],
          done:       s.concluida   || [],
        };
      }
      const tasks = this.data.tasks || [];
      const sel = this.ccSelectedSprint();
      // Filter to tasks belonging to the selected sprint
      const sprintTasks = sel ? tasks.filter(t => t.sprint_id === sel.id) : tasks;
      return {
        backlog:    sprintTasks.filter(t => t.status === 'pendente'),
        inProgress: sprintTasks.filter(t => t.status === 'em_andamento'),
        review:     sprintTasks.filter(t => t.status === 'revisao' || t.status === 'em_revisao'),
        done:       sprintTasks.filter(t => t.status === 'concluida' || t.status === 'concluído'),
      };
    },

    ccTasksByMember() {
      // Prefer live ClickUp data
      const raw = this.data.ccData?.by_member;
      if (raw) {
        // Resolve ClickUp usernames (ex: 'kaique.rodrigues') para nomes de exibição
        // usando spalla_members.clickup_username ou nome_curto
        const members = this.data.members || [];
        if (!members.length) return raw;
        const resolved = {};
        for (const [username, count] of Object.entries(raw)) {
          const member = members.find(m =>
            m.clickup_username === username ||
            m.id === username ||
            m.nome_curto?.toLowerCase() === username.toLowerCase()
          );
          const displayName = member ? member.nome_curto : username;
          resolved[displayName] = (resolved[displayName] || 0) + count;
        }
        return resolved;
      }
      // Fallback: tarefas locais
      const tasks = this.data.tasks || [];
      const map = {};
      tasks.forEach(t => {
        const name = (t.responsavel || 'Sem responsável').split(' ')[0];
        map[name] = (map[name] || 0) + 1;
      });
      return map;
    },

    // Workload por membro: avatar + tasks ativas para o Team card
    ccMemberWorkload() {
      const members = this.data.members || [];
      const memberColors = ['#7c3aed','#0ea5e9','#10b981','#f59e0b','#ec4899','#6366f1'];
      const resolveDisplayName = (username) => {
        if (!username) return '';
        const m = members.find(m =>
          m.clickup_username === username ||
          m.nome_curto?.toLowerCase() === username.toLowerCase()
        );
        return m ? m.nome_curto : username.split('.')[0];
      };
      const allCcTasks = [
        ...(this.data.ccData?.by_status?.em_andamento || []),
        ...(this.data.ccData?.by_status?.em_revisao || []),
        ...(this.data.ccData?.by_status?.backlog || []),
        ...(this.data.ccData?.by_status?.concluida || []),
      ];
      const workload = {};
      for (const task of allCcTasks) {
        const assignees = task.responsavel ? task.responsavel.split(', ').filter(Boolean) : [];
        for (const username of assignees) {
          const name = resolveDisplayName(username);
          if (!name) continue;
          if (!workload[name]) workload[name] = { name, inProgress: [], review: [], done: 0, total: 0 };
          workload[name].total++;
          if (task.status === 'em_andamento') workload[name].inProgress.push({ titulo: task.titulo, url: task.url });
          else if (task.status === 'em_revisao') workload[name].review.push({ titulo: task.titulo, url: task.url });
          else if (task.status === 'concluida') workload[name].done++;
        }
      }
      // Fallback: se não tem dados do ClickUp, usa data.tasks
      if (!allCcTasks.length) {
        const tasks = this.data.tasks || [];
        for (const t of tasks) {
          const name = (t.responsavel || '').split(' ')[0];
          if (!name) continue;
          if (!workload[name]) workload[name] = { name, inProgress: [], review: [], done: 0, total: 0 };
          workload[name].total++;
          if (t.status === 'em_andamento') workload[name].inProgress.push({ titulo: t.titulo, url: null });
          else if (t.status === 'em_revisao') workload[name].review.push({ titulo: t.titulo, url: null });
          else if (t.status === 'concluida') workload[name].done++;
        }
      }
      return Object.values(workload)
        .filter(m => m.total > 0)
        .sort((a, b) => b.inProgress.length - a.inProgress.length || b.total - a.total)
        .map((m, i) => ({ ...m, color: memberColors[i % memberColors.length], initial: m.name.charAt(0).toUpperCase() }));
    },

    ccSprintProgress() {
      if (this.data.ccData?.sprint && (this.ui.ccWeekOffset || 0) === 0) {
        const total = this.data.ccData.total || 0;
        const done  = this.data.ccData.concluidas || 0;
        if (!total) return 0;
        return Math.round((done / total) * 100);
      }
      const sprint = this.ccSelectedSprint();
      if (!sprint || !sprint.total) return 0;
      return Math.round(((sprint.concluidas || 0) / sprint.total) * 100);
    },

    ccNewMentees() {
      // Only mentorados created in the last 14 days
      const cutoff = new Date();
      cutoff.setDate(cutoff.getDate() - 14);
      return (this.data.mentees || []).filter(m => {
        if (!m.created_at) return false;
        return new Date(m.created_at) >= cutoff;
      }).sort((a, b) => new Date(b.created_at) - new Date(a.created_at)).slice(0, 8);
    },

    ccRecentActivity() {
      const actionLabel = (status) => {
        if (!status) return 'atualizou';
        const s = status.toLowerCase();
        if (s === 'concluida' || s === 'concluído' || s === 'done') return 'concluiu';
        if (s === 'em_andamento' || s === 'in_progress' || s === 'em andamento') return 'iniciou';
        if (s === 'revisao' || s === 'em_revisao' || s === 'review') return 'enviou pra revisão';
        if (s === 'bloqueado') return 'bloqueou';
        return 'atualizou';
      };
      // Prefer live ClickUp data
      if (this.data.ccData?.activity?.length) {
        return this.data.ccData.activity.slice(0, 12).map(a => {
          const task = (this.data.tasks || []).find(t => t.operon_id === a.operon_id);
          return {
            text: a.text,
            who: a.who,
            time: a.time,
            url: a.url,
            operon_id: a.operon_id || null,
            action: task ? actionLabel(task.status) : 'atualizou',
          };
        });
      }
      const tasks = [...(this.data.tasks || [])];
      return tasks
        .filter(t => t.updated_at || t.created_at)
        .sort((a, b) => new Date(b.updated_at || b.created_at) - new Date(a.updated_at || a.created_at))
        .slice(0, 8)
        .map(t => ({
          id: t.id,
          text: t.titulo || t.nome || 'Tarefa',
          who: (t.responsavel || '?').split(' ')[0],
          time: t.updated_at || t.created_at,
          status: t.status,
          action: actionLabel(t.status),
        }));
    },

    ccBlockers() {
      // Prefer live ClickUp data with explicit blockers array
      if (this.data.ccData?.blockers?.length) return this.data.ccData.blockers;
      // Fallback: urgent/blocked tasks not yet done from live or static data
      const inProgress = [
        ...(this.data.ccData?.by_status?.em_andamento || []),
        ...(this.data.ccData?.by_status?.em_revisao || []),
        ...(this.data.ccData?.by_status?.backlog || []),
      ];
      const source = inProgress.length ? inProgress : (this.data.tasks || []);
      return source
        .filter(t => {
          const s = (t.status || '').toLowerCase();
          const p = (t.prioridade || '').toLowerCase();
          return s === 'bloqueado' || p === 'urgente';
        })
        .slice(0, 6)
        .map(t => {
          const rawDesc = t.desc || t.descricao || t.contexto || '';
          const cleanDesc = rawDesc.replace(/[*_`#>]/g, '').trim();
          const firstLine = cleanDesc.split('\n').find(l => l.trim()) || '';
          const s = firstLine.trim();
          const shortDesc = s.length > 60 ? s.slice(0, 60) + '…' : s;
          return { text: t.titulo || t.nome || 'Tarefa', desc: shortDesc, who: (t.responsavel || t.assignee || '?').split(' ')[0], prioridade: t.prioridade || 'alta', url: t.url || null };
        });
    },

    ccDailyMap() {
      const memberColors = ['#7c3aed','#0ea5e9','#10b981','#f59e0b','#ec4899','#6366f1','#ef4444','#8b5cf6'];
      const today = new Date(); today.setHours(0,0,0,0);
      const yesterday = new Date(today); yesterday.setDate(yesterday.getDate() - 1);
      const todayStr = today.toISOString().slice(0,10);
      const yesterdayStr = yesterday.toISOString().slice(0,10);

      // HOJE: usa ccMemberWorkload que já tem dados corretos do ClickUp (em_andamento + em_revisao)
      const workload = this.ccMemberWorkload();
      const members = {};
      workload.forEach(m => {
        members[m.name.toLowerCase()] = {
          name: m.name, initial: m.initial, color: m.color,
          hoje: [...m.inProgress, ...(m.review || [])],
          ontem: [], bloqueios: [],
        };
      });

      // ONTEM + BLOQUEIOS: enriquece com god_tasks (data.tasks)
      const tasks = this.data.tasks || [];
      tasks.forEach(t => {
        const fullName = (t.responsavel || '').trim();
        const firstName = fullName.split(' ')[0];
        if (!firstName) return;
        const key = firstName.toLowerCase();
        if (!members[key]) {
          const idx = Object.keys(members).length;
          const displayName = firstName.charAt(0).toUpperCase() + firstName.slice(1).toLowerCase();
          members[key] = { name: displayName, initial: displayName.charAt(0).toUpperCase(), color: memberColors[idx % memberColors.length], hoje: [], ontem: [], bloqueios: [] };
        }
        const st = (t.status || '').toLowerCase().trim();
        const isDone = ['concluido','done','concluída','concluida','concluído','feito','closed'].includes(st);
        const isBlocked = t.is_blocked || st === 'bloqueado' || (t.bloqueio_motivo && t.bloqueio_motivo.trim());
        const updatedStr = (t.updated_at || '').slice(0, 10);
        const dueStr = (t.data_fim || t.prazo || '').slice(0, 10);

        if (isBlocked) {
          if (!members[key].bloqueios.find(b => (b.titulo || b.nome) === (t.titulo || t.nome)))
            members[key].bloqueios.push(t);
        } else if (isDone && (updatedStr === todayStr || updatedStr === yesterdayStr)) {
          members[key].ontem.push(t);
        } else if (dueStr === yesterdayStr && !isDone) {
          members[key].ontem.push(t);
        }
      });

      // BLOQUEIOS: também verifica ccData.by_status.bloqueado (ClickUp)
      const ccBlocked = this.data.ccData?.by_status?.bloqueado || [];
      const membersList = this.data.members || [];
      ccBlocked.forEach(t => {
        const assignees = (t.responsavel || '').split(', ').filter(Boolean);
        assignees.forEach(username => {
          const found = membersList.find(m => m.clickup_username === username || m.nome_curto?.toLowerCase() === username.toLowerCase());
          const displayName = found ? found.nome_curto : username.split('.')[0];
          if (!displayName) return;
          const key = displayName.toLowerCase();
          if (!members[key]) {
            const idx = Object.keys(members).length;
            members[key] = { name: displayName, initial: displayName.charAt(0).toUpperCase(), color: memberColors[idx % memberColors.length], hoje: [], ontem: [], bloqueios: [] };
          }
          if (!members[key].bloqueios.find(b => (b.titulo || b.nome) === t.titulo))
            members[key].bloqueios.push(t);
        });
      });

      return Object.values(members)
        .filter(m => m.hoje.length + m.ontem.length + m.bloqueios.length > 0)
        .sort((a, b) => (b.hoje.length + b.bloqueios.length) - (a.hoje.length + a.bloqueios.length));
    },

    // === CC V2: Dossiês Gargalados ===
    ccDossiesGargalados() {
      const docs = this.data.dsAllDocs || [];
      const prods = this.data.dsProducoes || [];
      const now = new Date();
      const gargalados = [];
      for (const doc of docs) {
        if (doc.estagio_atual === 'finalizado' || doc.estagio_atual === 'pendente') continue;
        const updatedAt = doc.updated_at ? new Date(doc.updated_at) : null;
        const diasParado = updatedAt ? Math.floor((now - updatedAt) / (1000 * 60 * 60 * 24)) : null;
        if (diasParado !== null && diasParado >= 3) {
          const prod = prods.find(p => p.producao_id === doc.producao_id);
          gargalados.push({
            ...doc,
            mentorado_nome: prod?.mentorado_nome || doc.mentorado_nome || '?',
            diasParado,
            estagio_label: (this.dsEstagioConfig?.(doc.estagio_atual) || {}).label || doc.estagio_atual,
          });
        }
      }
      return gargalados.sort((a, b) => b.diasParado - a.diasParado).slice(0, 10);
    },

    // === CC V2: Mentorados sem call há X dias ===
    ccMentoradosSemCall() {
      const mentees = this.data.mentees || [];
      const now = new Date();
      const result = [];
      for (const m of mentees) {
        if (m.status === 'offboarded' || m.status === 'cancelado') continue;
        let diasSemCall = m.dias_desde_call;
        if (diasSemCall == null && m.data_entrada) {
          diasSemCall = Math.floor((now - new Date(m.data_entrada)) / 86400000);
        }
        if (diasSemCall == null) diasSemCall = 999;
        if (diasSemCall >= 14) {
          const lastCallDate = m.ultima_call_data ? new Date(m.ultima_call_data).toLocaleDateString('pt-BR') : 'Nunca';
          result.push({ id: m.id, nome: m.nome, diasSemCall, lastCall: lastCallDate });
        }
      }
      return result.sort((a, b) => b.diasSemCall - a.diasSemCall).slice(0, 15);
    },

    // === CC V2: Download da Semana (sexta — consolidado semanal) ===
    ccDownloadSemana() {
      const now = new Date();
      const weekStart = new Date(now); weekStart.setDate(now.getDate() - now.getDay() + 1); weekStart.setHours(0, 0, 0, 0); // segunda
      const weekEnd = new Date(weekStart); weekEnd.setDate(weekStart.getDate() + 6); weekEnd.setHours(23, 59, 59, 999); // domingo
      const tasks = this.data.tasks || [];
      const mentees = this.data.mentees || [];

      // Tarefas concluídas esta semana
      const concluidas = tasks.filter(t => {
        const updated = new Date(t.updated_at);
        return t.status === 'concluida' && updated >= weekStart && updated <= weekEnd;
      });

      // Tarefas criadas esta semana
      const criadas = tasks.filter(t => {
        const created = new Date(t.created_at);
        return created >= weekStart && created <= weekEnd;
      });

      // Pendentes ainda abertas
      const pendentes = tasks.filter(t => t.status === 'pendente' || t.status === 'em_andamento');

      // Atrasadas
      const atrasadas = tasks.filter(t => {
        const due = t.data_fim || t.prazo;
        return due && new Date(due) < now && t.status !== 'concluida';
      });

      // Mentorados ativos
      const ativos = mentees.filter(m => m.status !== 'offboarded' && m.status !== 'cancelado');

      // Dossiês entregues esta semana
      const entregues = (this.data.dsAllDocs || []).filter(d => {
        if (d.estagio_atual !== 'finalizado') return false;
        const updated = new Date(d.updated_at);
        return updated >= weekStart && updated <= weekEnd;
      });

      return {
        periodo: `${weekStart.toLocaleDateString('pt-BR')} — ${weekEnd.toLocaleDateString('pt-BR')}`,
        tarefasConcluidas: concluidas.length,
        tarefasCriadas: criadas.length,
        tarefasPendentes: pendentes.length,
        tarefasAtrasadas: atrasadas.length,
        mentoradosAtivos: ativos.length,
        dossiesEntregues: entregues.length,
        dossiesGargalados: this.ccDossiesGargalados().length,
        topConcluidas: concluidas.slice(0, 5),
        topPendentes: pendentes.filter(t => t.prioridade === 'alta' || t.prioridade === 'urgente').slice(0, 5),
        topAtrasadas: atrasadas.slice(0, 5),
      };
    },

    // === CC V2: Planejamento da Semana (segunda — o que priorizar) ===
    ccPlanejamentoSemana() {
      const now = new Date();
      const tasks = this.data.tasks || [];

      // Próximos 7 dias
      const in7days = new Date(now); in7days.setDate(in7days.getDate() + 7);

      // Tarefas com prazo nos próximos 7 dias
      const comPrazo = tasks.filter(t => {
        const due = t.data_fim || t.prazo;
        if (!due || t.status === 'concluida') return false;
        const d = new Date(due);
        return d >= now && d <= in7days;
      }).sort((a, b) => new Date(a.data_fim || a.prazo) - new Date(b.data_fim || b.prazo));

      // Atrasadas (prioridade máxima)
      const atrasadas = tasks.filter(t => {
        const due = t.data_fim || t.prazo;
        return due && new Date(due) < now && t.status !== 'concluida';
      }).sort((a, b) => new Date(a.data_fim || a.prazo) - new Date(b.data_fim || b.prazo));

      // Follow-ups pendentes
      const followups = tasks.filter(t => t.tipo === 'follow_up' && t.status === 'pendente');

      // Dossiês com prazo crítico
      const dossiesCriticos = this.dsNewsCriticos?.() || [];

      // Sem call há muito tempo
      const semCall = this.ccMentoradosSemCall();

      return {
        atrasadas: atrasadas.slice(0, 10),
        comPrazo: comPrazo.slice(0, 10),
        followups: followups.slice(0, 10),
        dossiesCriticos: dossiesCriticos.slice(0, 5),
        semCall: semCall.slice(0, 5),
        totalAcoes: atrasadas.length + comPrazo.length + followups.length,
      };
    },

    async loadAgentMetrics() {
      if (!CONFIG.API_BASE) return;
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/agent-metrics`, {
          headers: { 'Authorization': `Bearer ${this.auth.accessToken}` },
        });
        if (!res.ok) return;
        const d = await res.json();
        this.data.agentMetrics = d.agents || [];
      } catch (e) { /* silent */ }
    },

    async loadCommandCenterData() {
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/clickup/command-center`);
        if (!res.ok) return;
        const d = await res.json();
        this.data.ccData = d;
        // Enrich data.tasks with ClickUp subtasks for tree view
        if (d.by_status) {
          const allCcTasks = [
            ...(d.by_status.backlog || []),
            ...(d.by_status.em_andamento || []),
            ...(d.by_status.em_revisao || []),
            ...(d.by_status.concluida || []),
          ];
          const ccByOperon = {};
          for (const ct of allCcTasks) {
            if (ct.id) ccByOperon[ct.id] = ct;
          }
          this.data.tasks = this.data.tasks.map(t => {
            if (t.operon_id && ccByOperon[t.operon_id]?.subtasks?.length) {
              const ccSubs = ccByOperon[t.operon_id].subtasks;
              return {
                ...t,
                subtasks: ccSubs.map(s => ({
                  id: s.id || null,
                  text: s.titulo || '',
                  done: s.status === 'concluida',
                  sort_order: 0,
                  status: s.status || 'pendente',
                  responsavel: s.responsavel || '',
                  prioridade: 'normal',
                  clickup_id: s.clickup_id || s.id || null,
                })),
              };
            }
            return t;
          });
        }
        // Sync active sprint totals into data.sprints for the header/timeline card
        if (d.sprint) {
          const patch = { total: d.total, concluidas: d.concluidas, status: 'ativo' };
          const idx = this.data.sprints.findIndex(s =>
            s.id === d.sprint.id || s.id === d.sprint.list_id || s.nome === d.sprint.nome
          );
          if (idx >= 0) {
            this.data.sprints[idx] = { ...this.data.sprints[idx], ...patch };
          } else {
            this.data.sprints.push({ ...d.sprint, ...patch, highlights: [] });
          }
          // Mark others as encerrado ou planejado (não ativo)
          const activeId = d.sprint.id || d.sprint.list_id;
          this.data.sprints = this.data.sprints.map(s =>
            (s.id === activeId || s.nome === d.sprint.nome) ? s : { ...s, status: s.status === 'encerrado' ? 'encerrado' : 'planejado' }
          );
        }
      } catch (e) {
        console.warn('[CC] ClickUp load failed:', e.message);
      }
    },

    // Carrega membros da equipe de spalla_members (substitui TEAM_MEMBERS hardcoded)
    async loadSpallaMembers() {
      if (!sb) return;
      try {
        const { data, error } = await sb.from('spalla_members').select('*').eq('ativo', true).order('id');
        if (!error && data?.length) {
          this.data.members = data;
        }
      } catch (e) {
        console.warn('[Spalla] loadSpallaMembers failed:', e.message);
      }
    },

    // Carrega listas e sprints de god_lists (substitui arrays hardcoded)
    async loadSpacesAndStatuses() {
      if (!sb) return;
      try {
        const [spacesRes, listsRes, statusesRes] = await Promise.all([
          sb.from('god_spaces').select('*').eq('ativo', true).order('ordem'),
          sb.from('god_lists').select('*').eq('ativo', true).order('ordem'),
          sb.from('god_statuses').select('*').order('sort_order'),
        ]);
        const spacesData = spacesRes.data || [];
        const listsData = listsRes.data || [];
        const statusesData = statusesRes.data || [];

        this.allStatuses = statusesData;
        this.data.lists = listsData;

        // Build sprints
        const sprints = listsData
          .filter(l => l.tipo === 'sprint')
          .map(l => ({
            id: l.id, nome: l.nome, inicio: l.sprint_inicio, fim: l.sprint_fim,
            status: l.sprint_status, total: l.sprint_total || 0,
            concluidas: l.sprint_concluidas || 0, highlights: [],
          }));
        if (sprints.length) this.data.sprints = sprints;

        // Build spaces with nested lists
        this.spaces = spacesData.map(sp => {
          const spLists = listsData
            .filter(l => l.space_id === sp.id && l.tipo !== 'sprint')
            .map(l => ({ id: l.id, name: l.nome, icon: l.tipo === 'backlog' ? '📋' : '▸' }));
          // Add sprints to their parent space
          const spSprints = listsData
            .filter(l => l.space_id === sp.id && l.tipo === 'sprint')
            .map(l => ({
              id: l.id, name: l.nome, isSprint: true, status: l.sprint_status,
              icon: l.sprint_status === 'ativo' ? '⚡' : (l.sprint_status === 'encerrado' ? '✓' : '○'),
            }));
          return {
            id: sp.id, name: sp.nome, icon: sp.icone || '◇', color: sp.cor || '#6366f1',
            lists: [...spLists, ...spSprints],
          };
        });
      } catch (e) {
        console.warn('[Spalla] loadSpacesAndStatuses failed:', e.message);
      }
      // Fallback: if no spaces loaded (migration not run yet), use defaults
      if (!this.spaces.length) {
        this.spaces = [
          { id: 'space_jornada', name: 'Jornada do Mentorado', icon: '🗺️', color: '#10b981', lists: [] },
          { id: 'space_gestao', name: 'Gestao Interna', icon: '⚙️', color: '#6366f1', lists: [] },
          { id: 'space_ia', name: 'IA & Automacao', icon: '🤖', color: '#f59e0b', lists: [] },
          { id: 'space_sistema', name: 'Sistema & Dev', icon: '💻', color: '#0ea5e9', lists: [] },
        ];
      }
    },

    // Legacy alias — kept for any callers
    // Sidebar CRUD
    async sidebarAddSpace() {
      const name = prompt('Nome do novo espaco');
      if (!name?.trim()) return;
      const slug = 'space_' + name.toLowerCase().replace(/[^a-z0-9]/g, '_').replace(/_+/g, '_');
      try {
        const { error } = await sb.from('god_spaces').insert({ id: slug, nome: name, cor: '#6366f1', icone: '◇', ordem: this.spaces.length + 1 });
        if (error) throw error;
        await this.loadSpacesAndStatuses();
        this.toast('Espaco criado: ' + name, 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },
    async sidebarAddList(spaceId) {
      const name = prompt('Nome da nova lista');
      if (!name?.trim()) return;
      const slug = 'list_' + name.toLowerCase().replace(/[^a-z0-9]/g, '_').replace(/_+/g, '_');
      try {
        const { error } = await sb.from('god_lists').insert({ id: slug, nome: name, space_id: spaceId, tipo: 'list', ordem: 99 });
        if (error) throw error;
        await this.loadSpacesAndStatuses();
        this.toast('Lista criada: ' + name, 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },

    async loadGodLists() {
      return this.loadSpacesAndStatuses();
    },

    navigateWithFilter(page, filter) {
      const statusMap = { backlog: 'pendente', inProgress: 'em_andamento', review: 'em_revisao', done: 'concluida' };
      this.navigate(page);
      if (filter) {
        setTimeout(() => {
          if (statusMap[filter]) {
            this.ui.taskFilter = statusMap[filter];
          } else if (['pendente','em_andamento','em_revisao','concluida','atrasada'].includes(filter)) {
            this.ui.taskFilter = filter;
          } else {
            // Nome de responsável — filtrar por assignee, limpar filtro de status
            this.ui.taskAssignee = filter;
            this.ui.taskFilter = 'all';
            this.ui.search = '';
          }
        }, 30);
      }
    },

    navigateToTask(taskId) {
      this.navigate('tasks');
      setTimeout(() => {
        this.ui.taskAssignee = '';
        this.ui.taskFilter = 'all';
        this.ui.search = '';
        this.ui.taskDetailDrawer = taskId;
      }, 30);
    },

    // Navega para atividade recente — tenta abrir drawer local, senão abre URL externa
    navigateToActivityTask(item) {
      if (item.id) {
        // Item local com Supabase UUID — abre drawer direto
        this.navigateToTask(item.id);
        return;
      }
      if (item.operon_id) {
        // Item do ClickUp — busca tarefa local pelo operon_id
        const match = (this.data.tasks || []).find(t => t.operon_id === item.operon_id);
        if (match) {
          this.navigateToTask(match.id);
          return;
        }
      }
      if (item.text) {
        // Fallback: busca por título
        const match = (this.data.tasks || []).find(t =>
          (t.titulo || t.nome || '').toLowerCase() === item.text.toLowerCase()
        );
        if (match) {
          this.navigateToTask(match.id);
          return;
        }
      }
      // Fallback final: abre URL externa (ClickUp)
      if (item.url) {
        window.open(item.url, '_blank');
      } else {
        this.navigate('tasks');
      }
    },

    // ===================== NAVIGATION =====================

    // Deep-link route map (pathname → page name)
    _routeMap: {
      'welcome-flow': 'welcome_flow',
      'command-center': 'command_center',
      'dashboard': 'dashboard',
      'kanban': 'kanban',
      'tasks': 'tasks',
      'meu-trabalho': 'meu_trabalho',
      'sprints': 'sprints',
      'agenda': 'agenda',
      'equipe': 'equipe',
      'whatsapp': 'whatsapp',
      'wa-topics': 'wa_topics',
      'wa-management': 'wa_management',
      'reminders': 'reminders',
      'feedback': 'feedback',
      'dossies': 'dossies',
      'planos-acao': 'planos_acao',
      'onboarding': 'onboarding',
      'docs': 'docs',
      'documentos': 'documentos',
      'arquivos': 'arquivos',
      'settings': 'settings',
      'descarrego': 'descarrego',
      'jornada': 'kanban',
    },

    _pageToRoute(page) {
      for (const [route, p] of Object.entries(this._routeMap)) {
        if (p === page) return route;
      }
      return page.replace(/_/g, '-');
    },

    // ===================== ARQUIVOS (Storage + Search) =====================
    // TODO (Fix 18): Folder nesting — too complex for this PR, requires schema changes
    // TODO (Fix 20): Saved searches — requires backend persistence or localStorage with more UI

    async loadArquivos() {
      this.arquivos.loading = true; // Fix 3
      try {
        if (!this.supabase) {
          console.error('[Arquivos] Supabase client not ready');
          sb = await initSupabase();
        }
        const { data, error } = await this.supabase.from('sp_arquivos')
          .select('*')
          .is('deleted_at', null)
          .order('created_at', { ascending: false });
        if (error) console.error('[Arquivos] Load error:', error);
        this.arquivos.list = data || [];
        // Count processing files
        this.arquivos.processingCount = this.arquivos.list.filter(a =>
          ['pendente', 'extraindo', 'chunking', 'embedding'].includes(a.status_processamento)
        ).length;
      } catch(e) {
        console.error('[Arquivos] loadArquivos failed:', e);
      }
      this.arquivos.loading = false; // Fix 3
      // Load storage status
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/storage/status`);
        const status = await res.json();
        this.arquivos.storageOverview = status.overview || [];
        this.arquivos.queue = status.queue || [];
        this.arquivos.voyageConfigured = status.voyage_configured;
      } catch(e) { console.error('[Arquivos] Storage status error:', e); }
      // 5.2 — Load folder data
      await this._loadArquivosFolders();
      // 5.6 — Load custom folders
      await this.loadCustomFolders();
      // 5.4 — Subscribe to realtime
      this._subscribeArquivosRealtime();
    },

    // ===== 5.2 — FOLDER VIEW =====

    async _loadArquivosFolders() {
      try {
        const { data, error } = await this.supabase
          .from('vw_arquivos_por_mentorado')
          .select('*')
          .order('total_arquivos', { ascending: false });
        if (error) console.error('[Arquivos] Folders error:', error);
        // Filter out TESE mentorados — only show CASE (cohort N1, N2, or null)
        const teseIds = new Set(
          (this.data.mentees || [])
            .filter(m => m.cohort === 'tese')
            .map(m => m.id)
        );
        this.arquivos.folders = (data || [])
          .filter(f => f.mentorado_nome && !teseIds.has(f.mentorado_id));
        console.log('[Arquivos] Loaded', this.arquivos.folders.length, 'CASE mentorado folders (excluded', teseIds.size, 'tese)');
      } catch(e) {
        console.error('[Arquivos] _loadArquivosFolders failed:', e);
      }
    },

    // ===== 5.6 — CUSTOM FOLDERS =====

    async loadCustomFolders() {
      try {
        const { data, error } = await this.supabase
          .from('vw_pastas_overview')
          .select('*')
          .order('sort_order', { ascending: true })
          .order('nome', { ascending: true });
        if (error) console.error('[Arquivos] Custom folders error:', error);
        this.arquivos.customFolders = data || [];
        console.log('[Arquivos] Loaded', this.arquivos.customFolders.length, 'custom folders');
      } catch(e) {
        console.error('[Arquivos] loadCustomFolders failed:', e);
      }
    },

    openNewFolderForm() {
      this.arquivos.showNewFolderForm = true;
      this.arquivos.newFolderForm = { nome: '', descricao: '', cor: '#6b7280', mentoradoId: null, mentoradoSearch: '', showMentoradoDropdown: false };
    },

    closeNewFolderForm() {
      this.arquivos.showNewFolderForm = false;
    },

    get newFolderFilteredMentees() {
      const q = (this.arquivos.newFolderForm.mentoradoSearch || '').toLowerCase().trim();
      if (!q) return (this.data.mentees || []).slice(0, 15);
      return (this.data.mentees || []).filter(m =>
        m.nome?.toLowerCase().includes(q) || m.instagram?.toLowerCase().includes(q)
      ).slice(0, 15);
    },

    selectNewFolderMentorado(mentee) {
      this.arquivos.newFolderForm.mentoradoId = mentee.id;
      this.arquivos.newFolderForm.mentoradoSearch = mentee.nome;
      this.arquivos.newFolderForm.showMentoradoDropdown = false;
    },

    clearNewFolderMentorado() {
      this.arquivos.newFolderForm.mentoradoId = null;
      this.arquivos.newFolderForm.mentoradoSearch = '';
      this.arquivos.newFolderForm.showMentoradoDropdown = false;
    },

    async createFolder() {
      const f = this.arquivos.newFolderForm;
      if (!f.nome.trim()) { this.toast('Nome da pasta e obrigatorio.', 'warning'); return; }
      // Prevent duplicate names
      const nameNorm = f.nome.trim().toLowerCase();
      const exists = this.arquivos.customFolders.some(cf => cf.nome?.toLowerCase() === nameNorm);
      if (exists) { this.toast('Ja existe uma pasta com esse nome.', 'warning'); return; }
      // Prevent double-click
      if (this.arquivos.creatingFolder) return;
      this.arquivos.creatingFolder = true;
      try {
        const insertData = {
          nome: f.nome.trim(),
          cor: f.cor,
        };
        if (f.descricao.trim()) insertData.descricao = f.descricao.trim();
        if (f.mentoradoId) insertData.mentorado_id = f.mentoradoId;
        const { error } = await this.supabase.from('sp_pastas').insert(insertData);
        if (error) throw error;
        this.closeNewFolderForm();
        await this.loadCustomFolders();
        this.toast('Pasta "' + f.nome.trim() + '" criada', 'success');
      } catch(e) {
        console.error('[Arquivos] createFolder failed:', e);
        this.toast('Erro ao criar pasta: ' + (e.message || e), 'error');
      } finally {
        this.arquivos.creatingFolder = false;
      }
    },

    async deleteFolder(folderId) {
      if (!confirm('Excluir esta pasta? Os arquivos dentro dela ficarao sem pasta.')) return;
      try {
        // Unassign files first
        await this.supabase.from('sp_arquivos').update({ pasta_id: null }).eq('pasta_id', folderId);
        const { error } = await this.supabase.from('sp_pastas').delete().eq('id', folderId);
        if (error) throw error;
        // If viewing this folder, go back
        if (this.arquivos.currentFolder?.pasta_id === folderId) {
          this.closeFolderView();
        }
        await this.loadCustomFolders();
        this.toast('Pasta excluida', 'info');
      } catch(e) {
        console.error('[Arquivos] deleteFolder failed:', e);
        this.toast('Erro ao excluir pasta: ' + (e.message || e), 'error');
      }
    },

    openEditFolderForm(folder) {
      this.arquivos.editingFolder = { ...folder };
      this.arquivos.showEditFolderForm = true;
    },

    closeEditFolderForm() {
      this.arquivos.showEditFolderForm = false;
      this.arquivos.editingFolder = null;
    },

    async editFolder() {
      const f = this.arquivos.editingFolder;
      if (!f || !f.nome?.trim()) return;
      try {
        const { error } = await this.supabase.from('sp_pastas')
          .update({ nome: f.nome.trim(), descricao: f.descricao || null, cor: f.cor })
          .eq('id', f.id);
        if (error) throw error;
        this.closeEditFolderForm();
        await this.loadCustomFolders();
        // Update current folder header if viewing it
        if (this.arquivos.currentFolder?.pasta_id === f.id) {
          this.arquivos.currentFolder.nome = f.nome.trim();
          this.arquivos.currentFolder.cor = f.cor;
        }
        this.toast('Pasta atualizada', 'success');
      } catch(e) {
        console.error('[Arquivos] editFolder failed:', e);
        this.toast('Erro ao editar pasta: ' + (e.message || e), 'error');
      }
    },

    openCustomFolder(folder) {
      this.arquivos.viewMode = 'folder_detail';
      this.arquivos.currentFolder = {
        pasta_id: folder.id,
        nome: folder.nome,
        cor: folder.cor,
        icone: folder.icone,
        descricao: folder.descricao,
        mentorado_id: folder.mentorado_id,
        mentorado_nome: folder.mentorado_nome,
      };
      this.arquivos.folderFilesLoading = true;
      this._loadCustomFolderFiles(folder.id);
    },

    async _loadCustomFolderFiles(pastaId) {
      try {
        const { data, error } = await this.supabase.from('sp_arquivos')
          .select('*')
          .eq('pasta_id', pastaId)
          .is('deleted_at', null)
          .order('categoria', { ascending: true })
          .order('created_at', { ascending: false });
        if (error) console.error('[Arquivos] Custom folder files error:', error);
        this.arquivos.folderFiles = data || [];
      } catch(e) {
        console.error('[Arquivos] _loadCustomFolderFiles failed:', e);
      }
      this.arquivos.folderFilesLoading = false;
    },

    // Move file to folder
    openMoveModal(arquivo) {
      this.arquivos.moveFileTarget = arquivo;
      this.arquivos.showMoveModal = true;
    },

    closeMoveModal() {
      this.arquivos.moveFileTarget = null;
      this.arquivos.showMoveModal = false;
    },

    async moveFileToFolder(pastaId) {
      const arquivo = this.arquivos.moveFileTarget;
      if (!arquivo) return;
      try {
        const { error } = await this.supabase.from('sp_arquivos')
          .update({ pasta_id: pastaId || null })
          .eq('id', arquivo.id);
        if (error) throw error;
        // Update local state
        const item = this.arquivos.list.find(a => a.id === arquivo.id);
        if (item) item.pasta_id = pastaId || null;
        const folderItem = this.arquivos.folderFiles.find(a => a.id === arquivo.id);
        if (folderItem) folderItem.pasta_id = pastaId || null;
        this.closeMoveModal();
        await this.loadCustomFolders(); // refresh counts
        this.toast('Arquivo movido', 'success');
      } catch(e) {
        console.error('[Arquivos] moveFileToFolder failed:', e);
        this.toast('Erro ao mover arquivo: ' + (e.message || e), 'error');
      }
    },

    _folderNameById(pastaId) {
      if (!pastaId) return null;
      const f = this.arquivos.customFolders.find(f => f.id === pastaId);
      return f ? f.nome : null;
    },

    get arquivosGeralCount() {
      return this.arquivos.list.filter(a => !a.entidade_id || a.entidade_tipo === 'geral').length;
    },

    get arquivosGeralSize() {
      return this.arquivos.list
        .filter(a => !a.entidade_id || a.entidade_tipo === 'geral')
        .reduce((sum, a) => sum + (a.tamanho_bytes || 0), 0);
    },

    async openFolder(folder) {
      // If it's a custom folder (has pasta_id), use custom folder flow
      if (folder && folder.pasta_id) {
        return this.openCustomFolder(folder);
      }
      this.arquivos.viewMode = 'folder_detail';
      this.arquivos.currentFolder = folder; // { mentorado_id, mentorado_nome } or null for geral
      this.arquivos.folderFilesLoading = true;
      try {
        let query = this.supabase.from('sp_arquivos')
          .select('*')
          .is('deleted_at', null)
          .order('categoria', { ascending: true })
          .order('created_at', { ascending: false });

        if (folder && folder.mentorado_id) {
          query = query.eq('entidade_id', folder.mentorado_id);
        } else {
          // Geral — no entidade_id
          query = query.or('entidade_id.is.null,entidade_tipo.eq.geral');
        }
        const { data, error } = await query;
        if (error) console.error('[Arquivos] Folder files error:', error);
        this.arquivos.folderFiles = data || [];
      } catch(e) {
        console.error('[Arquivos] openFolder failed:', e);
      }
      this.arquivos.folderFilesLoading = false;
    },

    closeFolderView() {
      this.arquivos.viewMode = 'folders';
      this.arquivos.currentFolder = null;
      this.arquivos.folderFiles = [];
      this.arquivos.searchResults = [];
      this.arquivos.searchQuery = '';
      this.arquivos.page = 1;
      this.arquivos.selectedIds = [];
    },

    get folderFilesByCategoria() {
      const groups = {};
      const order = ['documento', 'audio', 'video', 'imagem', 'planilha', 'outro'];
      for (const f of this.arquivos.folderFiles) {
        const cat = f.categoria || 'outro';
        if (!groups[cat]) groups[cat] = [];
        groups[cat].push(f);
      }
      return order.filter(c => groups[c]).map(c => ({ categoria: c, files: groups[c] }));
    },

    _categoriaLabel(cat) {
      const map = { documento: 'Documentos', audio: 'Audios', video: 'Videos', imagem: 'Imagens', planilha: 'Planilhas', outro: 'Outros' };
      return map[cat] || cat;
    },

    openUploadForFolder() {
      this.openUploadModal();
      if (this.arquivos.currentFolder && this.arquivos.currentFolder.pasta_id) {
        // Custom folder — set pastaId
        this.arquivos.uploadForm.pastaId = this.arquivos.currentFolder.pasta_id;
      }
      if (this.arquivos.currentFolder && this.arquivos.currentFolder.mentorado_id) {
        const m = (this.data.mentees || []).find(m => m.id === this.arquivos.currentFolder.mentorado_id);
        if (m) this.selectUploadMentorado(m);
      }
    },

    // --- Upload Form Helpers ---

    openUploadModal() {
      this.arquivos.uploadForm = {
        mentoradoId: null,
        mentoradoNome: '',
        mentoradoSearch: '',
        entidadeTipo: 'geral',
        descricao: '',
        pastaId: null,
        files: [],
        showModal: true,
        showMentoradoDropdown: false,
      };
    },

    closeUploadModal() {
      this.arquivos.uploadForm.showModal = false;
    },

    get uploadFilteredMentees() {
      const q = (this.arquivos.uploadForm.mentoradoSearch || '').toLowerCase().trim();
      if (!q) return (this.data.mentees || []).slice(0, 15);
      return (this.data.mentees || []).filter(m =>
        m.nome?.toLowerCase().includes(q) || m.instagram?.toLowerCase().includes(q)
      ).slice(0, 15);
    },

    selectUploadMentorado(mentee) {
      this.arquivos.uploadForm.mentoradoId = mentee.id;
      this.arquivos.uploadForm.mentoradoNome = mentee.nome;
      this.arquivos.uploadForm.mentoradoSearch = mentee.nome;
      this.arquivos.uploadForm.entidadeTipo = 'mentorado';
      this.arquivos.uploadForm.showMentoradoDropdown = false;
    },

    clearUploadMentorado() {
      this.arquivos.uploadForm.mentoradoId = null;
      this.arquivos.uploadForm.mentoradoNome = '';
      this.arquivos.uploadForm.mentoradoSearch = '';
      this.arquivos.uploadForm.entidadeTipo = 'geral';
      this.arquivos.uploadForm.showMentoradoDropdown = false;
    },

    addUploadFiles(fileList) {
      for (const file of fileList) {
        // Avoid duplicates by name+size
        const exists = this.arquivos.uploadForm.files.some(f => f.name === file.name && f.size === file.size);
        if (!exists) {
          this.arquivos.uploadForm.files.push({
            file,
            name: file.name,
            size: file.size,
            type: file.type,
            status: 'waiting',
            progress: 0,
            error: null,
          });
        }
      }
    },

    removeUploadFile(index) {
      this.arquivos.uploadForm.files.splice(index, 1);
    },

    handleUploadDrop(event) {
      event.preventDefault();
      const files = event.dataTransfer?.files;
      if (files?.length) this.addUploadFiles(files);
    },

    handleUploadFileInput(event) {
      const files = event.target.files;
      if (files?.length) this.addUploadFiles(files);
      event.target.value = '';
    },

    _uploadFileIcon(type) {
      if (type.startsWith('image/')) return '🖼️';
      if (type.startsWith('audio/')) return '🎵';
      if (type.startsWith('video/')) return '🎬';
      if (type.includes('spreadsheet') || type.includes('csv') || type.includes('excel')) return '📊';
      if (type.includes('pdf')) return '📕';
      return '📄';
    },

    async uploadArquivos() {
      const form = this.arquivos.uploadForm;
      if (!form.files.length) return;

      this.arquivos.uploadLoading = true;
      const entidadeTipo = form.mentoradoId ? form.entidadeTipo : 'geral';
      const entidadeId = form.mentoradoId || null;

      for (const entry of form.files) {
        if (entry.status === 'done') continue;
        entry.status = 'uploading';
        entry.progress = 10;

        try {
          const ext = entry.name.split('.').pop().toLowerCase();
          const nomeStorage = crypto.randomUUID() + '.' + ext;
          const pathPrefix = entidadeId ? `${entidadeTipo}/${entidadeId}` : entidadeTipo;
          const path = `${pathPrefix}/${nomeStorage}`;

          // 1. Upload to Supabase Storage
          const { error: uploadError } = await this.supabase.storage
            .from('spalla-arquivos')
            .upload(path, entry.file);
          if (uploadError) throw uploadError;
          entry.progress = 50;

          // 2. Insert metadata
          entry.status = 'processing';
          const categoria = this._detectCategoria(entry.type, ext);
          const insertData = {
            nome_original: entry.name,
            nome_storage: nomeStorage,
            storage_path: path,
            mime_type: entry.type,
            tamanho_bytes: entry.size,
            extensao: ext,
            entidade_tipo: entidadeTipo,
            entidade_id: entidadeId,
            categoria,
          };
          if (form.descricao.trim()) insertData.descricao = form.descricao.trim();
          if (form.pastaId) insertData.pasta_id = form.pastaId;

          const { data: inserted, error: insertError } = await this.supabase
            .from('sp_arquivos')
            .insert(insertData)
            .select()
            .single();
          if (insertError) throw insertError;
          entry.progress = 75;

          // 3. Trigger processing
          await fetch(`${CONFIG.API_BASE}/api/storage/process`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ arquivo_id: inserted.id }),
          });

          entry.status = 'done';
          entry.progress = 100;
          console.log('[Arquivos] Uploaded:', inserted.nome_original, inserted.id);
        } catch(e) {
          console.error('[Arquivos] Upload failed:', e);
          entry.status = 'error';
          entry.error = e.message || String(e);
        }
      }

      this.arquivos.uploadLoading = false;

      // If all done, close modal and reload
      const doneCount = form.files.filter(f => f.status === 'done').length;
      const errorCount = form.files.filter(f => f.status === 'error').length;
      if (doneCount > 0 && errorCount === 0) {
        this.toast(doneCount + ' arquivo(s) enviado(s) com sucesso', 'success');
        this.closeUploadModal();
        await this.loadArquivos();
      } else if (doneCount > 0 && errorCount > 0) {
        this.toast(doneCount + ' enviado(s), ' + errorCount + ' com erro', 'warning');
        await this.loadArquivos();
      } else if (errorCount > 0 && doneCount === 0) {
        this.toast('Erro no upload de todos os arquivos', 'error');
      }
    },

    // Legacy handler for backward compat (not used in new UI)
    async uploadArquivo(event) {
      const files = event.target.files;
      if (!files || !files.length) return;
      this.openUploadModal();
      this.addUploadFiles(files);
    },

    async searchArquivos() {
      const q = this.arquivos.searchQuery.trim();
      if (!q) { this.arquivos.searchResults = []; return; }
      this.arquivos.searchLoading = true;
      this._saveSearchHistory(q); // Fix 17
      try {
        // 5.3 — Build filters including mentorado, date range, and folder context
        const filters = {
          categoria: this.arquivos.filterCategoria || null,
          entidade_tipo: this.arquivos.filterEntidade || null,
        };
        // Mentorado filter: from dropdown OR from current folder
        const mentoradoFilter = this.arquivos.filterMentoradoId ||
          (this.arquivos.viewMode === 'folder_detail' && this.arquivos.currentFolder?.mentorado_id) || null;
        if (mentoradoFilter) filters.mentorado_id = mentoradoFilter;
        if (this.arquivos.filterDateFrom) filters.date_from = this.arquivos.filterDateFrom;
        if (this.arquivos.filterDateTo) filters.date_to = this.arquivos.filterDateTo;

        const res = await fetch(`${CONFIG.API_BASE}/api/storage/search`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            query: q,
            mode: this.arquivos.searchMode,
            limit: 20,
            filters,
          }),
        });
        const data = await res.json();
        // Fix 4 — Deduplicate by arquivo_id, keep highest score
        const rawResults = data.results || [];
        const grouped = {};
        for (const r of rawResults) {
          if (!grouped[r.arquivo_id] || (r.score_final || 0) > (grouped[r.arquivo_id].score_final || 0)) {
            grouped[r.arquivo_id] = r;
          }
        }
        this.arquivos.searchResults = Object.values(grouped).sort((a, b) => (b.score_final || 0) - (a.score_final || 0));
        if (data.error) this.toast(data.error, 'warning');
      } catch(e) {
        console.error('Search failed:', e);
        this.toast('Erro na busca: ' + e.message, 'error');
      }
      this.arquivos.searchLoading = false;
    },

    async deleteArquivo(id) {
      if (!confirm('Excluir este arquivo?')) return;
      await this.supabase.from('sp_arquivos')
        .update({ deleted_at: new Date().toISOString() })
        .eq('id', id);
      this.arquivos.list = this.arquivos.list.filter(a => a.id !== id);
      this.arquivos.folderFiles = this.arquivos.folderFiles.filter(a => a.id !== id);
      this.arquivos.selectedIds = this.arquivos.selectedIds.filter(sid => sid !== id);
      this.toast('Arquivo excluido', 'info');
    },

    async togglePinArquivo(id, currentPinned) {
      await this.supabase.from('sp_arquivos')
        .update({ pinned: !currentPinned })
        .eq('id', id);
      const item = this.arquivos.list.find(a => a.id === id);
      if (item) item.pinned = !currentPinned;
    },

    async getArquivoUrl(storagePath) {
      const { data } = await this.supabase.storage
        .from('spalla-arquivos')
        .createSignedUrl(storagePath, 3600);
      if (data?.signedUrl) window.open(data.signedUrl, '_blank');
    },

    // ===== DOCUMENT VIEWER =====
    viewer: {
      open: false,
      loading: false,
      arquivo: null,
      content: '',
      contentHtml: '',
      signedUrl: '',
      mode: 'text', // 'text' | 'pdf' | 'image' | 'audio' | 'video' | 'raw'
    },

    async openViewer(arquivo) {
      this.viewer.open = true;
      this.viewer.loading = true;
      this.viewer.arquivo = arquivo;
      this.viewer.content = '';
      this.viewer.contentHtml = '';
      this.viewer.signedUrl = '';

      const cat = arquivo.categoria;
      const ext = (arquivo.extensao || '').toLowerCase();
      const mime = arquivo.mime_type || '';

      // Get signed URL for binary files
      const { data: urlData } = await this.supabase.storage
        .from('spalla-arquivos')
        .createSignedUrl(arquivo.storage_path, 3600);
      this.viewer.signedUrl = urlData?.signedUrl || '';

      if (cat === 'imagem') {
        this.viewer.mode = 'image';
        this.viewer.loading = false;
      } else if (cat === 'audio') {
        this.viewer.mode = 'audio';
        // Load transcription if available
        try {
          const { data: c } = await this.supabase.from('sp_conteudo_extraido')
            .select('conteudo_texto').eq('arquivo_id', arquivo.id).order('created_at', { ascending: false }).limit(1).single();
          if (c?.conteudo_texto) this.viewer.content = c.conteudo_texto;
        } catch(e) {}
        this.viewer.loading = false;
      } else if (cat === 'video') {
        this.viewer.mode = 'video';
        try {
          const { data: c } = await this.supabase.from('sp_conteudo_extraido')
            .select('conteudo_texto').eq('arquivo_id', arquivo.id).order('created_at', { ascending: false }).limit(1).single();
          if (c?.conteudo_texto) this.viewer.content = c.conteudo_texto;
        } catch(e) {}
        this.viewer.loading = false;
      } else if (ext === 'pdf' || mime === 'application/pdf') {
        this.viewer.mode = 'pdf';
        this.viewer.loading = false;
      } else if (['md', 'txt', 'csv', 'docx', 'xlsx'].includes(ext) || mime.startsWith('text/')) {
        // For text-based: load extracted content from sp_conteudo_extraido
        this.viewer.mode = 'text';
        try {
          const { data: conteudo } = await this.supabase
            .from('sp_conteudo_extraido')
            .select('conteudo_texto, metodo_extracao, word_count')
            .eq('arquivo_id', arquivo.id)
            .order('created_at', { ascending: false })
            .limit(1)
            .single();

          if (conteudo?.conteudo_texto) {
            this.viewer.content = conteudo.conteudo_texto;
            // Render markdown if .md
            if (ext === 'md' || mime === 'text/markdown') {
              this.viewer.contentHtml = this._renderMarkdown(conteudo.conteudo_texto);
            }
          } else {
            // Fallback: download raw file
            const { data: blob } = await this.supabase.storage
              .from('spalla-arquivos')
              .download(arquivo.storage_path);
            if (blob) this.viewer.content = await blob.text();
          }
        } catch(e) {
          console.error('[Viewer] Load error:', e);
          // Fallback: download raw
          try {
            const { data: blob } = await this.supabase.storage
              .from('spalla-arquivos')
              .download(arquivo.storage_path);
            if (blob) this.viewer.content = await blob.text();
          } catch(e2) { this.viewer.content = 'Erro ao carregar conteúdo.'; }
        }
        this.viewer.loading = false;
      } else {
        // Unknown type — offer download
        this.viewer.mode = 'raw';
        this.viewer.loading = false;
      }
    },

    closeViewer() {
      this.viewer.open = false;
      this.viewer.arquivo = null;
      this.viewer.content = '';
      this.viewer.contentHtml = '';
      this.viewer.signedUrl = '';
    },

    _renderMarkdown(text) {
      // Lightweight markdown to HTML (no external deps)
      let html = text
        // Escape HTML
        .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
        // Headers
        .replace(/^######\s+(.+)$/gm, '<h6>$1</h6>')
        .replace(/^#####\s+(.+)$/gm, '<h5>$1</h5>')
        .replace(/^####\s+(.+)$/gm, '<h4>$1</h4>')
        .replace(/^###\s+(.+)$/gm, '<h3>$1</h3>')
        .replace(/^##\s+(.+)$/gm, '<h2>$1</h2>')
        .replace(/^#\s+(.+)$/gm, '<h1>$1</h1>')
        // Bold + italic
        .replace(/\*\*\*(.+?)\*\*\*/g, '<strong><em>$1</em></strong>')
        .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
        .replace(/\*(.+?)\*/g, '<em>$1</em>')
        // Lists
        .replace(/^-\s+(.+)$/gm, '<li>$1</li>')
        .replace(/^(\d+)\.\s+(.+)$/gm, '<li>$2</li>')
        // Horizontal rule
        .replace(/^---+$/gm, '<hr>')
        // Line breaks
        .replace(/\n\n/g, '</p><p>')
        .replace(/\n/g, '<br>');
      // Wrap in paragraphs
      html = '<p>' + html + '</p>';
      // Clean up list items into proper lists
      html = html.replace(/(<li>.*?<\/li>)/gs, '<ul>$1</ul>');
      html = html.replace(/<\/ul>\s*<ul>/g, '');
      return html;
    },

    _detectCategoria(mimeType, ext) {
      if (mimeType.startsWith('image/')) return 'imagem';
      if (mimeType.startsWith('audio/')) return 'audio';
      if (mimeType.startsWith('video/')) return 'video';
      if (['xlsx', 'xls', 'csv'].includes(ext)) return 'planilha';
      if (['pdf', 'docx', 'doc', 'md', 'txt'].includes(ext)) return 'documento';
      return 'outro';
    },

    _formatBytes(bytes) {
      if (!bytes) return '0 B';
      const k = 1024;
      const sizes = ['B', 'KB', 'MB', 'GB'];
      const i = Math.floor(Math.log(bytes) / Math.log(k));
      return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
    },

    _statusIcon(status) {
      const map = { pendente: '⏳', extraindo: '📄', chunking: '✂️', embedding: '🧠', concluido: '✅', erro: '❌', ignorado: '⏭️' };
      return map[status] || '❓';
    },

    // Fix 15 — Status text label
    _statusLabel(status) {
      const map = {
        pendente: 'Pendente',
        extraindo: 'Extraindo...',
        chunking: 'Processando...',
        embedding: 'Indexando...',
        concluido: 'Indexado',
        erro: 'Erro',
        ignorado: 'Ignorado'
      };
      return map[status] || status;
    },

    // Fix 9 — Paginated files
    get paginatedFiles() {
      const start = (this.arquivos.page - 1) * this.arquivos.pageSize;
      return this.arquivos.list.slice(start, start + this.arquivos.pageSize);
    },

    get totalPages() {
      return Math.max(1, Math.ceil(this.arquivos.list.length / this.arquivos.pageSize));
    },

    nextPage() {
      if (this.arquivos.page < this.totalPages) this.arquivos.page++;
    },

    prevPage() {
      if (this.arquivos.page > 1) this.arquivos.page--;
    },

    // Fix 16 — Bulk select
    toggleSelectFile(id) {
      const idx = this.arquivos.selectedIds.indexOf(id);
      if (idx >= 0) this.arquivos.selectedIds.splice(idx, 1);
      else this.arquivos.selectedIds.push(id);
    },

    selectAllFiles() {
      const visible = this.paginatedFiles;
      const allSelected = visible.every(f => this.arquivos.selectedIds.includes(f.id));
      if (allSelected) {
        this.arquivos.selectedIds = [];
      } else {
        this.arquivos.selectedIds = visible.map(f => f.id);
      }
    },

    clearSelection() {
      this.arquivos.selectedIds = [];
    },

    async bulkDeleteFiles() {
      const ids = this.arquivos.selectedIds;
      if (!ids.length) return;
      if (!confirm('Excluir ' + ids.length + ' arquivo(s) selecionado(s)?')) return;
      const now = new Date().toISOString();
      for (const id of ids) {
        await this.supabase.from('sp_arquivos').update({ deleted_at: now }).eq('id', id);
      }
      this.arquivos.list = this.arquivos.list.filter(a => !ids.includes(a.id));
      this.arquivos.folderFiles = this.arquivos.folderFiles.filter(a => !ids.includes(a.id));
      this.toast(ids.length + ' arquivo(s) excluido(s)', 'info');
      this.arquivos.selectedIds = [];
    },

    async bulkMoveFiles(pastaId) {
      const ids = this.arquivos.selectedIds;
      if (!ids.length) return;
      for (const id of ids) {
        await this.supabase.from('sp_arquivos').update({ pasta_id: pastaId || null }).eq('id', id);
        const item = this.arquivos.list.find(a => a.id === id);
        if (item) item.pasta_id = pastaId || null;
      }
      await this.loadCustomFolders();
      this.toast(ids.length + ' arquivo(s) movido(s)', 'success');
      this.arquivos.selectedIds = [];
    },

    // Fix 17 — Search history
    get searchHistory() {
      try {
        return JSON.parse(localStorage.getItem('spalla_search_history') || '[]');
      } catch { return []; }
    },

    _saveSearchHistory(query) {
      if (!query) return;
      let history = this.searchHistory.filter(h => h !== query);
      history.unshift(query);
      if (history.length > 5) history = history.slice(0, 5);
      localStorage.setItem('spalla_search_history', JSON.stringify(history));
    },

    clearSearchHistory() {
      localStorage.removeItem('spalla_search_history');
    },

    // Fix 19 — Storage quota
    get storageUsedMb() {
      return (this.arquivos.storageOverview || []).reduce((sum, o) => sum + (parseFloat(o.total_mb) || 0), 0);
    },

    get storageQuotaMb() { return 500; }, // bucket limit

    get storagePercent() {
      return Math.min(100, Math.round((this.storageUsedMb / this.storageQuotaMb) * 100));
    },

    _categoriaIcon(cat) {
      const map = { documento: '📄', imagem: '🖼️', audio: '🎵', video: '🎬', planilha: '📊', outro: '📎' };
      return map[cat] || '📎';
    },

    // ===== 5.4 — REALTIME SUBSCRIPTION =====

    _subscribeArquivosRealtime() {
      if (this._arquivosChannel) return; // already subscribed
      if (!this.supabase) return;
      this._arquivosChannel = this.supabase
        .channel('arquivos-realtime')
        .on('postgres_changes', {
          event: 'UPDATE',
          schema: 'public',
          table: 'sp_arquivos'
        }, (payload) => {
          const updated = payload.new;
          // Update in main list
          const idx = this.arquivos.list.findIndex(a => a.id === updated.id);
          if (idx >= 0) {
            const oldStatus = this.arquivos.list[idx].status_processamento;
            this.arquivos.list[idx] = { ...this.arquivos.list[idx], ...updated };
            // Toast when processing completes
            if (oldStatus !== 'concluido' && updated.status_processamento === 'concluido') {
              this.toast(`Arquivo processado: ${updated.nome_original}`, 'success');
            }
            if (oldStatus !== 'erro' && updated.status_processamento === 'erro') {
              this.toast(`Erro no processamento: ${updated.nome_original}`, 'error');
            }
          }
          // Update in folder files
          const fidx = this.arquivos.folderFiles.findIndex(a => a.id === updated.id);
          if (fidx >= 0) {
            this.arquivos.folderFiles[fidx] = { ...this.arquivos.folderFiles[fidx], ...updated };
          }
          // Update in detail arquivos
          const didx = this._detailArquivos.findIndex(a => a.id === updated.id);
          if (didx >= 0) {
            this._detailArquivos[didx] = { ...this._detailArquivos[didx], ...updated };
          }
          // Recount processing
          this.arquivos.processingCount = this.arquivos.list.filter(a =>
            ['pendente', 'extraindo', 'chunking', 'embedding'].includes(a.status_processamento)
          ).length;
        })
        .on('postgres_changes', {
          event: 'INSERT',
          schema: 'public',
          table: 'sp_arquivos'
        }, (payload) => {
          // Add new file to list if not already present
          if (!this.arquivos.list.find(a => a.id === payload.new.id)) {
            this.arquivos.list.unshift(payload.new);
          }
          this.arquivos.processingCount = this.arquivos.list.filter(a =>
            ['pendente', 'extraindo', 'chunking', 'embedding'].includes(a.status_processamento)
          ).length;
        })
        .subscribe();
    },

    _unsubscribeArquivosRealtime() {
      if (this._arquivosChannel) {
        this.supabase.removeChannel(this._arquivosChannel);
        this._arquivosChannel = null;
      }
    },

    async reprocessArquivo(id) {
      try {
        await fetch(`${CONFIG.API_BASE}/api/storage/process`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ arquivo_id: id }),
        });
        // Update local status
        const item = this.arquivos.list.find(a => a.id === id);
        if (item) item.status_processamento = 'pendente';
        this.toast('Reprocessamento iniciado', 'info');
      } catch(e) {
        this.toast('Erro ao reprocessar: ' + e.message, 'error');
      }
    },

    _isProcessing(status) {
      return ['pendente', 'extraindo', 'chunking', 'embedding'].includes(status);
    },

    // ===== 5.5 — DETAIL MENTORADO ARQUIVOS =====

    async loadDetailArquivos(mentoradoId) {
      const mid = mentoradoId || this.ui.selectedMenteeId;
      if (!mid || !this.supabase) return;
      this._detailArquivosLoading = true;
      try {
        const { data, error } = await this.supabase.from('sp_arquivos')
          .select('*')
          .eq('entidade_id', mid)
          .is('deleted_at', null)
          .order('created_at', { ascending: false });
        if (error) console.error('[Arquivos] Detail load error:', error);
        this._detailArquivos = data || [];
      } catch(e) {
        console.error('[Arquivos] loadDetailArquivos failed:', e);
      }
      this._detailArquivosLoading = false;
    },

    get filteredDetailArquivos() {
      if (!this._detailArquivosSearch) return this._detailArquivos;
      const q = this._detailArquivosSearch.toLowerCase();
      return this._detailArquivos.filter(a =>
        a.nome_original?.toLowerCase().includes(q) ||
        a.categoria?.toLowerCase().includes(q) ||
        a.descricao?.toLowerCase().includes(q)
      );
    },

    openUploadForDetail() {
      this.openUploadModal();
      const mid = this.ui.selectedMenteeId;
      if (mid) {
        const m = (this.data.mentees || []).find(m => m.id === mid);
        if (m) this.selectUploadMentorado(m);
      }
    },

    goToMentoradoFolder(mentoradoId, mentoradoNome) {
      this.navigate('documentos');
      this.ui.docsTab = 'arquivos';
      this.loadArquivos().then(() => {
        this.openFolder({ mentorado_id: mentoradoId, mentorado_nome: mentoradoNome });
      });
    },

    navigate(page) {
      // Stop WhatsApp polling when leaving WhatsApp page
      if (this.ui.page === 'whatsapp' && page !== 'whatsapp') {
        this.stopWhatsAppPolling();
      }
      // 5.4 — Unsubscribe from realtime when leaving arquivos
      if (this.ui.page === 'arquivos' && page !== 'arquivos') {
        this._unsubscribeArquivosRealtime();
      }
      this.ui.page = page;
      this.ui.mobileMenuOpen = false;
      if (page === 'financeiro') this.loadFinanceiro();
      if (page === 'command_center') {
        if (!this.data.dsProducoes.length) this.loadDsData();
        // Force reload mentees to sync fase_jornada after updates
        if (sb) {
          sb.from('vw_god_overview').select('*').then(({ data }) => {
            if (data?.length) this.data.mentees = data;
          });
        }
        // ORCH-07: Load agent metrics
        this.loadAgentMetrics();
      }
      if (page === 'carteira') this.initWaKeyboardShortcuts();
      if (page === 'descarrego') { this.ui.ctxFilter.tipo = 'all'; this.ui.ctxFilter.fase = 'all'; }
      if (page === 'meu_trabalho') this.loadMeuTrabalho();
      localStorage.setItem('spalla_page', page);
      // Update URL without reload
      const route = this._pageToRoute(page);
      if (route && window.location.pathname !== '/' + route) {
        history.pushState({ page }, '', '/' + route);
      }
      window.scrollTo({ top: 0, behavior: 'smooth' });
    },

    goBack() {
      this.ui.page = 'dashboard';
      localStorage.setItem('spalla_page', 'dashboard');
      this.data.detail = null;
      this.ui.selectedMenteeId = null;
      history.pushState({ page: 'dashboard' }, '', '/dashboard');
    },

    // ===================== PLANO DE AÇÃO (PA) =====================

    // PA Form state
    paForm: { titulo: 'Plano de Ação', google_doc_url: '', formato: 'fases' },
    paFaseForm: { titulo: '', tipo: 'fase' },
    paAcaoForm: { titulo: '', data_prevista: '', responsavel: 'mentorado' },
    paSubAcaoForm: {},  // keyed by acao_id: { titulo: '' }

    // Load full PA for a mentee (called when opening PA tab)
    async loadMenteePa(mentoradoId) {
      if (!sb) return;
      const mid = mentoradoId || this.ui.selectedMenteeId;
      if (!mid) return;
      this.ui.paLoading = true;
      try {
        const { data: planos } = await sb.from('pa_planos')
          .select('*')
          .eq('mentorado_id', mid)
          .limit(1)
          .single();
        if (!planos) { this.data.paMenteePa = null; this.ui.paLoading = false; return; }
        const [fasesRes, acoesRes, subAcoesRes] = await Promise.all([
          sb.from('pa_fases').select('*').eq('plano_id', planos.id).order('ordem'),
          sb.from('pa_acoes').select('*').eq('plano_id', planos.id).order('ordem'),
          sb.from('pa_sub_acoes').select('*').eq('plano_id', planos.id).order('ordem'),
        ]);
        const fases = (fasesRes.data || []).map(f => ({
          ...f,
          acoes: (acoesRes.data || []).filter(a => a.fase_id === f.id).map(a => ({
            ...a,
            sub_acoes: (subAcoesRes.data || []).filter(s => s.acao_id === a.id),
          })),
        }));
        this.data.paMenteePa = { ...planos, fases };
        // Auto-expand first em_andamento or nao_iniciado phase
        if (fases.length && !Object.values(this.ui.paExpandedFases).some(v => v)) {
          const first = fases.find(f => f.status === 'em_andamento') || fases.find(f => f.status === 'nao_iniciado') || fases[0];
          if (first) this.ui.paExpandedFases[first.id] = true;
        }
      } catch (e) {
        console.error('[Spalla] loadMenteePa error:', e);
        this.data.paMenteePa = null;
      }
      this.ui.paLoading = false;
    },

    // Get PA summary for a mentee (from pipeline data)
    getPaForMentee(id) {
      return this.data.paPlanos.find(p => p.mentorado_id === id) || null;
    },

    // Create a new PA plan
    async createPlano() {
      if (!sb) return;
      const mid = this.ui.selectedMenteeId;
      if (!mid) return;
      const user = this.currentUserName;
      const { data, error } = await sb.from('pa_planos').insert({
        mentorado_id: mid,
        titulo: this.paForm.titulo || 'Plano de Ação',
        formato: this.paForm.formato,
        google_doc_url: this.paForm.google_doc_url || null,
        created_by: user,
      }).select().single();
      if (error) { this.toast('Erro ao criar plano: ' + error.message, 'error'); return; }
      this.ui.paModal = false;
      this.paForm = { titulo: 'Plano de Ação', google_doc_url: '', formato: 'fases' };
      await this.loadMenteePa(mid);
      // Refresh pipeline
      const { data: pipe } = await sb.from('vw_pa_pipeline').select('*');
      if (pipe) this.data.paPlanos = pipe;
      this.toast('Plano criado com sucesso', 'success');
    },

    // Add a phase to the current plan
    async addFase() {
      if (!sb || !this.data.paMenteePa) return;
      const plano = this.data.paMenteePa;
      const ordem = (plano.fases?.length || 0) + 1;
      const { error } = await sb.from('pa_fases').insert({
        plano_id: plano.id,
        mentorado_id: plano.mentorado_id,
        titulo: this.paFaseForm.titulo || 'Nova Fase',
        tipo: this.paFaseForm.tipo,
        ordem,
      });
      if (error) { this.toast('Erro ao adicionar fase', 'error'); return; }
      this.paFaseForm = { titulo: '', tipo: 'fase' };
      await this.loadMenteePa();
      this.toast('Fase adicionada', 'success');
    },

    // Add an action to a phase
    async addAcao(faseId) {
      if (!sb || !this.data.paMenteePa) return;
      const plano = this.data.paMenteePa;
      const fase = plano.fases?.find(f => f.id === faseId);
      const ordem = (fase?.acoes?.length || 0) + 1;
      const { error } = await sb.from('pa_acoes').insert({
        fase_id: faseId,
        plano_id: plano.id,
        mentorado_id: plano.mentorado_id,
        numero: ordem,
        titulo: this.paAcaoForm.titulo || 'Nova Ação',
        data_prevista: this.paAcaoForm.data_prevista || null,
        responsavel: this.paAcaoForm.responsavel || 'mentorado',
        ordem,
      });
      if (error) { this.toast('Erro ao adicionar ação', 'error'); return; }
      this.paAcaoForm = { titulo: '', data_prevista: '', responsavel: 'mentorado' };
      await this.loadMenteePa();
    },

    // Toggle action status (click-cycle)
    async toggleAcaoStatus(acao) {
      if (!sb) return;
      const cycle = ['pendente', 'em_andamento', 'concluido'];
      const idx = cycle.indexOf(acao.status);
      const next = cycle[(idx + 1) % cycle.length];
      // Optimistic update
      acao.status = next;
      if (next === 'concluido') acao.data_conclusao = this.todayStr();
      const { error } = await sb.from('pa_acoes').update({
        status: next,
        data_conclusao: next === 'concluido' ? this.todayStr() : null,
      }).eq('id', acao.id);
      if (error) { this.toast('Erro ao atualizar status', 'error'); await this.loadMenteePa(); return; }
      // Auto-update phase status
      await this._updateFaseStatus(acao.fase_id);
      // Auto-update plan status
      await this._updatePlanoStatus();
      // Refresh pipeline
      const { data: pipe } = await sb.from('vw_pa_pipeline').select('*');
      if (pipe) this.data.paPlanos = pipe;
    },

    // Save inline-edited action fields
    async saveAcao(acao) {
      if (!sb) return;
      const { error } = await sb.from('pa_acoes').update({
        titulo: acao.titulo,
        data_prevista: acao.data_prevista || null,
        responsavel: acao.responsavel,
        notas: acao.notas || null,
      }).eq('id', acao.id);
      if (error) this.toast('Erro ao salvar ação', 'error');
    },

    // Delete a phase
    async deleteFase(faseId) {
      if (!sb || !confirm('Excluir esta fase e todas as ações?')) return;
      const { error } = await sb.from('pa_fases').delete().eq('id', faseId);
      if (error) { this.toast('Erro ao excluir fase', 'error'); return; }
      await this.loadMenteePa();
      this.toast('Fase excluída', 'success');
    },

    // Delete an action
    async deleteAcao(acaoId) {
      if (!sb || !confirm('Excluir esta ação?')) return;
      const { error } = await sb.from('pa_acoes').delete().eq('id', acaoId);
      if (error) { this.toast('Erro ao excluir ação', 'error'); return; }
      await this.loadMenteePa();
    },

    // Toggle sub-action status: pendente → em_andamento → concluido → pendente
    async toggleSubAcaoStatus(subacao) {
      if (!sb) return;
      const cycle = { pendente: 'em_andamento', em_andamento: 'concluido', concluido: 'pendente' };
      const newStatus = cycle[subacao.status] || 'pendente';
      const { error } = await sb.from('pa_sub_acoes').update({ status: newStatus }).eq('id', subacao.id);
      if (error) { this.toast('Erro ao atualizar sub-ação', 'error'); return; }
      await this.loadMenteePa();
    },

    // Save sub-action inline edits (titulo, responsavel)
    async saveSubAcao(subacao) {
      if (!sb) return;
      const { error } = await sb.from('pa_sub_acoes').update({
        titulo: subacao.titulo,
        responsavel: subacao.responsavel,
      }).eq('id', subacao.id);
      if (error) { this.toast('Erro ao salvar sub-ação', 'error'); return; }
    },

    // Delete a sub-action
    async deleteSubAcao(subacaoId) {
      if (!sb || !confirm('Excluir esta sub-ação?')) return;
      const { error } = await sb.from('pa_sub_acoes').delete().eq('id', subacaoId);
      if (error) { this.toast('Erro ao excluir sub-ação', 'error'); return; }
      await this.loadMenteePa();
    },

    // Get per-action sub-acao form state
    getSubAcaoForm(acaoId) {
      if (!this.paSubAcaoForm[acaoId]) this.paSubAcaoForm[acaoId] = { titulo: '' };
      return this.paSubAcaoForm[acaoId];
    },

    // Add a new sub-action to an action
    async addSubAcao(acaoId, faseId) {
      if (!sb || !this.data.paMenteePa) return;
      const plano = this.data.paMenteePa;
      const fase = plano.fases?.find(f => f.id === faseId);
      const acao = fase?.acoes?.find(a => a.id === acaoId);
      const ordem = (acao?.sub_acoes?.length || 0) + 1;
      const form = this.getSubAcaoForm(acaoId);
      const { error } = await sb.from('pa_sub_acoes').insert({
        plano_id: plano.id,
        fase_id: faseId,
        acao_id: acaoId,
        titulo: form.titulo || 'Nova sub-ação',
        ordem,
        status: 'pendente',
        origem: 'manual',
      });
      if (error) { this.toast('Erro ao adicionar sub-ação', 'error'); return; }
      this.paSubAcaoForm[acaoId] = { titulo: '' };
      await this.loadMenteePa();
    },

    // Auto-update phase status based on actions
    async _updateFaseStatus(faseId) {
      if (!sb || !this.data.paMenteePa) return;
      const fase = this.data.paMenteePa.fases?.find(f => f.id === faseId);
      if (!fase || !fase.acoes?.length) return;
      const all = fase.acoes.length;
      const done = fase.acoes.filter(a => a.status === 'concluido' || a.status === 'nao_aplicavel').length;
      const inProgress = fase.acoes.some(a => a.status === 'em_andamento');
      let newStatus = 'nao_iniciado';
      if (done === all) newStatus = 'concluido';
      else if (done > 0 || inProgress) newStatus = 'em_andamento';
      if (fase.status !== newStatus) {
        fase.status = newStatus;
        try { await sb.from('pa_fases').update({ status: newStatus }).eq('id', faseId); }
        catch (e) { console.error('Erro ao atualizar fase:', e); }
      }
    },

    // Auto-update plan status based on phases
    async _updatePlanoStatus() {
      if (!sb || !this.data.paMenteePa) return;
      const plano = this.data.paMenteePa;
      const fases = plano.fases || [];
      if (!fases.length) return;
      const allDone = fases.every(f => f.status === 'concluido');
      const anyActive = fases.some(f => f.status === 'em_andamento' || f.status === 'concluido');
      let newStatus = 'nao_iniciado';
      if (allDone) newStatus = 'concluido';
      else if (anyActive) newStatus = 'em_andamento';
      if (plano.status_geral !== newStatus) {
        plano.status_geral = newStatus;
        try { await sb.from('pa_planos').update({ status_geral: newStatus }).eq('id', plano.id); }
        catch (e) { console.error('Erro ao atualizar plano:', e); }
      }
    },

    // PA Pipeline helpers
    get filteredPaPlanos() {
      let list = [...this.data.paPlanos];
      if (this.ui.paFilter && this.ui.paFilter !== 'all') {
        list = list.filter(p => p.status_geral === this.ui.paFilter);
      }
      if (this.ui.paSearchQuery) {
        const q = this.ui.paSearchQuery.toLowerCase();
        list = list.filter(p => (p.mentorado_nome || '').toLowerCase().includes(q));
      }
      return list;
    },

    paPipelineColumns() {
      const statuses = ['nao_iniciado', 'em_andamento', 'pausado', 'concluido'];
      const list = this.ui.paSearchQuery ? this.filteredPaPlanos : this.data.paPlanos;
      return statuses.map(s => ({
        status: s,
        label: this.paStatusLabel(s),
        items: list.filter(p => p.status_geral === s),
      }));
    },

    paStatusLabel(s) {
      const map = { nao_iniciado: 'Aguardando Início', em_andamento: 'Em Execução', pausado: 'Pausado', concluido: 'Concluído' };
      return map[s] || s;
    },

    paStatusColor(s) {
      const map = { nao_iniciado: '#6b7280', em_andamento: '#3b82f6', pausado: '#f59e0b', concluido: '#10b981' };
      return map[s] || '#6b7280';
    },

    paAcaoStatusIcon(s) {
      const map = {
        pendente: '○',
        em_andamento: '◉',
        concluido: '✓',
        bloqueado: '⊘',
        nao_aplicavel: '—',
      };
      return map[s] || '○';
    },

    paAcaoStatusLabel(s) {
      const map = { pendente: 'Pendente', em_andamento: 'Em Progresso', concluido: 'Concluída', bloqueado: 'Bloqueada', nao_aplicavel: 'N/A' };
      return map[s] || s;
    },

    paTipoLabel(tipo) {
      const map = { revisao_dossie: 'Diagnóstico', fase: 'Estratégia', passo_executivo: 'Execução' };
      return map[tipo] || tipo;
    },

    paTipoColor(tipo) {
      const map = { revisao_dossie: '#8b5cf6', fase: '#0ea5e9', passo_executivo: '#f97316' };
      return map[tipo] || '#6b7280';
    },

    paTipoBgColor(tipo) {
      const map = { revisao_dossie: '#8b5cf620', fase: '#0ea5e920', passo_executivo: '#f9731620' };
      return map[tipo] || '#6b728020';
    },

    paTipoIcon(tipo) {
      const svgs = {
        revisao_dossie: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1" ry="1"/></svg>',
        fase: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"/></svg>',
        passo_executivo: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>',
      };
      return svgs[tipo] || '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg>';
    },

    paOrigemLabel(origem) {
      const map = { dossie_auto: 'Dossiê', call_plano: 'Call', manual: 'Manual' };
      return map[origem] || origem || 'Manual';
    },

    paOrigemColor(origem) {
      const map = { dossie_auto: 'pa-origem--dossie', call_plano: 'pa-origem--call', manual: 'pa-origem--manual' };
      return map[origem] || 'pa-origem--manual';
    },

    // Sentinel data for a plan (breakdown by tipo, origem, blocked, overdue)
    paSentinelData(planoId) {
      const fases = this.data.paAllFases.filter(f => f.plano_id === planoId);
      const acoes = this.data.paAllAcoes.filter(a => a.plano_id === planoId);
      const today = this.todayStr();
      const byTipo = {};
      for (const f of fases) {
        const tipo = f.tipo || 'fase';
        if (!byTipo[tipo]) byTipo[tipo] = { total: 0, done: 0 };
        const fAcoes = acoes.filter(a => a.fase_id === f.id);
        byTipo[tipo].total += fAcoes.length;
        byTipo[tipo].done += fAcoes.filter(a => a.status === 'concluido' || a.status === 'nao_aplicavel').length;
      }
      const byOrigem = { dossie_auto: 0, call_plano: 0, manual: 0 };
      for (const a of acoes) {
        const o = a.origem || 'manual';
        byOrigem[o] = (byOrigem[o] || 0) + 1;
      }
      const blocked = acoes.filter(a => a.status === 'bloqueado').length;
      const overdue = acoes.filter(a => a.data_prevista && a.data_prevista < today && a.status !== 'concluido' && a.status !== 'nao_aplicavel').length;
      return { byTipo, byOrigem, blocked, overdue, totalAcoes: acoes.length };
    },

    // Page-level KPIs for the Sentinela PA page
    paPageKpis() {
      const plans = this.data.paPlanos;
      const total = plans.length;
      const emExecucao = plans.filter(p => p.status_geral === 'em_andamento').length;
      const parados = plans.filter(p => p.status_geral === 'em_andamento' && (p.dias_sem_update || 0) > 14).length;
      const allAcoes = this.data.paAllAcoes;
      const today = this.todayStr();
      const bloqueadas = allAcoes.filter(a => a.status === 'bloqueado').length;
      const totalAcoes = allAcoes.length;
      const concluidas = allAcoes.filter(a => a.status === 'concluido' || a.status === 'nao_aplicavel').length;
      const taxaConclusao = totalAcoes > 0 ? Math.round((concluidas / totalAcoes) * 100) : 0;
      const diasSemUpdate = plans.filter(p => p.dias_sem_update != null);
      const mediaDias = diasSemUpdate.length > 0 ? Math.round(diasSemUpdate.reduce((s, p) => s + (p.dias_sem_update || 0), 0) / diasSemUpdate.length) : 0;
      return { total, emExecucao, parados, bloqueadas, taxaConclusao, mediaDias };
    },

    paBlockedCount(planoId) {
      return this.data.paAllAcoes.filter(a => a.plano_id === planoId && a.status === 'bloqueado').length;
    },

    paOverdueCount(planoId) {
      const today = this.todayStr();
      return this.data.paAllAcoes.filter(a => a.plano_id === planoId && a.data_prevista && a.data_prevista < today && a.status !== 'concluido' && a.status !== 'nao_aplicavel').length;
    },

    paLastUpdate(planoId) {
      const acoes = this.data.paAllAcoes.filter(a => a.plano_id === planoId && a.updated_at);
      if (!acoes.length) return null;
      const latest = acoes.reduce((max, a) => a.updated_at > max ? a.updated_at : max, acoes[0].updated_at);
      const diff = Math.floor((Date.now() - new Date(latest).getTime()) / 86400000);
      if (diff === 0) return 'hoje';
      if (diff === 1) return 'ontem';
      return 'há ' + diff + ' dias';
    },

    // Tipo progress percentage for a plan
    paTipoProgress(planoId, tipo) {
      const sd = this.paSentinelData(planoId);
      const t = sd.byTipo[tipo];
      if (!t || t.total === 0) return 0;
      return Math.round((t.done / t.total) * 100);
    },

    paFaseProgress(fase) {
      if (!fase.acoes?.length) return 0;
      const done = fase.acoes.filter(a => a.status === 'concluido' || a.status === 'nao_aplicavel').length;
      return Math.round((done / fase.acoes.length) * 100);
    },

    togglePaFase(faseId) {
      this.ui.paExpandedFases[faseId] = !this.ui.paExpandedFases[faseId];
    },

    isPaFaseExpanded(faseId) {
      return !!this.ui.paExpandedFases[faseId];
    },
    expandAllPaFases() {
      const pa = this.data.paMenteePa;
      if (!pa?.fases) return;
      pa.fases.forEach(f => { this.ui.paExpandedFases[f.id] = true; });
    },
    collapseAllPaFases() {
      this.ui.paExpandedFases = {};
    },

    // Check if acao is overdue
    paAcaoOverdue(acao) {
      if (!acao.data_prevista) return false;
      if (acao.status === 'concluido' || acao.status === 'nao_aplicavel') return false;
      return acao.data_prevista < this.todayStr();
    },

    // Detail summary stats from paMenteePa (loaded detail)
    paDetailStats() {
      const pa = this.data.paMenteePa;
      if (!pa || !pa.fases) return { total: 0, concluidas: 0, bloqueadas: 0, vencidas: 0, subTotal: 0, subConcluidas: 0 };
      const acoes = pa.fases.flatMap(f => f.acoes || []);
      const subs = acoes.flatMap(a => a.sub_acoes || []);
      const today = this.todayStr();
      return {
        total: acoes.length,
        concluidas: acoes.filter(a => a.status === 'concluido').length,
        bloqueadas: acoes.filter(a => a.status === 'bloqueado').length,
        vencidas: acoes.filter(a => a.data_prevista && a.data_prevista < today && a.status !== 'concluido' && a.status !== 'nao_aplicavel').length,
        subTotal: subs.length,
        subConcluidas: subs.filter(s => s.status === 'concluido').length,
      };
    },

    // Detail: progress by tipo from paMenteePa
    paDetailTipoProgress(tipo) {
      const pa = this.data.paMenteePa;
      if (!pa || !pa.fases) return { pct: 0, done: 0, total: 0 };
      const fases = pa.fases.filter(f => (f.tipo || 'fase') === tipo);
      const acoes = fases.flatMap(f => f.acoes || []);
      const done = acoes.filter(a => a.status === 'concluido' || a.status === 'nao_aplicavel').length;
      return { pct: acoes.length > 0 ? Math.round((done / acoes.length) * 100) : 0, done, total: acoes.length };
    },

    // Detail: origin composition from paMenteePa
    paDetailOrigem() {
      const pa = this.data.paMenteePa;
      if (!pa || !pa.fases) return { dossie_auto: 0, call_plano: 0, manual: 0 };
      const acoes = pa.fases.flatMap(f => f.acoes || []);
      const r = { dossie_auto: 0, call_plano: 0, manual: 0 };
      for (const a of acoes) { r[a.origem || 'manual'] = (r[a.origem || 'manual'] || 0) + 1; }
      return r;
    },

    // ===================== SORTING / FILTERS =====================

    toggleSort(field) {
      if (this.ui.sort === field) {
        this.ui.sortDir = this.ui.sortDir === 'asc' ? 'desc' : 'asc';
      } else {
        this.ui.sort = field;
        this.ui.sortDir = 'asc';
      }
    },

    clearFilters() {
      this.ui.filters = { fase: '', risco: '', cohort: '', status: '', financeiro: '', carteira: '' };
      this.ui.search = '';
    },

    filterByPhase(fase) {
      this.ui.filters.fase = this.ui.filters.fase === fase ? '' : fase;
    },

    // ===================== TASK MANAGEMENT =====================

    async loadTasks() {
      if (sb) {
        try {
          // Load only god_tasks (board tasks) — tarefas_equipe are shown as pending WA messages
          const { data, error } = await sb.from('vw_god_tasks_full').select('*').order('created_at', { ascending: false }).limit(1000);
          if (!error && data) {
            this.data.tasks = data.map(t => ({
              ...t, prazo: t.data_fim, _source: 'god_tasks',
              // Subtasks: full model with status/dates/responsavel/prioridade
              subtasks: (t.subtasks_json || t.subtasks || []).map(s => ({
                id: s.id || null,
                text: s.texto || s.text || '',
                done: s.done || false,
                sort_order: s.sort_order ?? 0,
                status: s.status || (s.done ? 'concluida' : 'pendente'),
                responsavel: s.responsavel || '',
                data_inicio: s.data_inicio || '',
                data_fim: s.data_fim || '',
                prioridade: s.prioridade || 'normal',
                clickup_id: s.clickup_id || null,
              })),
              checklist: (t.checklist_json || t.checklist || []).map(c => ({
                id: c.id || null,
                text: c.texto || c.text || '',
                done: c.done || false,
                sort_order: c.sort_order ?? 0,
                due_date: c.due_date || '',
                assignee: c.assignee || '',
              })),
              comments: (t.comments_json || t.comments || []).map(c => ({ id: c.id, author: c.author, text: c.texto || c.text, timestamp: c.created_at || c.timestamp })),
              handoffs: (t.handoffs_json || t.handoffs || []).map(h => ({ from: h.from_person || h.from, to: h.to_person || h.to, note: h.note, date: h.created_at || h.date })),
              tags: (t.tags_full && t.tags_full.length) ? t.tags_full : (t.tags || []).map(tg => typeof tg === 'string' ? { id: null, name: tg, color: '#94a3b8' } : tg),
              custom_fields: t.custom_fields_json || [],
              dependencies: t.dependencies_json || [],
              dependents: t.dependents_json || [],
              subtasks_total: t.subtasks_total || 0,
              subtasks_done: t.subtasks_done || 0,
              checklist_total: t.checklist_total || 0,
              checklist_done: t.checklist_done || 0,
              is_blocked: t.is_blocked || false,
              attachments: [],
            }));
            // Clear stale localStorage cache — Supabase is source of truth
            try { localStorage.removeItem(CONFIG.TASKS_STORAGE_KEY); } catch (e) {}
            // Merge sprint_id from god_tasks (not in view)
            try {
              const { data: sprintData } = await sb.from('god_tasks').select('id, sprint_id').not('sprint_id', 'is', null);
              if (sprintData) {
                const sprintMap = Object.fromEntries(sprintData.map(s => [s.id, s.sprint_id]));
                this.data.tasks.forEach(t => { t.sprint_id = sprintMap[t.id] || ''; });
              }
            } catch (e) {}
            this._autoCategorize();
            this._cacheTasksLocal();
this._buildNotifications(); // F2.5 — refresh notification bell after tasks load
            this._checkRecurringTasks();
            return;
          }
        } catch (e) { console.warn('[Spalla] Tasks fetch error, falling back:', e.message); }
      }
      // Fallback: localStorage (only if Supabase completely unavailable)
      if (!sb) {
        try {
          const raw = localStorage.getItem(CONFIG.TASKS_STORAGE_KEY);
          if (raw) { const parsed = JSON.parse(raw); if (parsed.length > 0) { this.data.tasks = parsed; this._autoCategorize(); this._checkRecurringTasks(); return; } }
        } catch (e) {}
        this.data.tasks = DEMO_TASKS;
      }
    },

    _autoCategorize() {
      const validSpaces = ['space_entregas', 'space_atendimento', 'space_mentorado', 'space_produto', 'space_tecnologia'];
      this.data.tasks.forEach(t => {
        // Skip tasks already in valid spaces
        if (validSpaces.includes(t.space_id)) return;
        // Migrate old space IDs
        if (t.space_id) {
          t.space_id = null; t.list_id = null;
        }
        // Migrate dossiês from atendimento to entregas
        if (t.space_id === 'space_atendimento' && t.list_id === 'list_dossies') {
          t.space_id = 'space_entregas';
        }
        if (!t.space_id) {
          const titulo = (t.titulo || '').toLowerCase();
          const fonte = t.fonte || '';
          const resp = t.responsavel || '';

          // Dossiê tasks → Entregas / Dossiês
          if (titulo.includes('dossie') || titulo.includes('dossiê') || titulo.startsWith('[ds]') || fonte === 'dossie') {
            t.space_id = 'space_entregas';
            t.list_id = 'list_dossies';
          }
          // Mentorado-owned tasks → Mentorado / Tarefas
          else if (resp === 'mentorado' || resp === 'Mentorado' || titulo.includes('checklist de ações')) {
            t.space_id = 'space_mentorado';
            t.list_id = 'list_tarefas_mentorado';
          }
          // Pós-call actions → Atendimento / Pós-call
          else if (fonte === 'tarefas_acordadas' || fonte === 'analise_call' || titulo.includes('pós-call') || titulo.includes('pos-call')) {
            t.space_id = 'space_atendimento';
            t.list_id = 'list_poscall';
          }
          // Análises & revisões do mentorado → Atendimento / Análises
          else if (titulo.includes('revisão') || titulo.includes('revisao') || titulo.includes('análise') || titulo.includes('analise') || titulo.includes('lapidação') || titulo.includes('lapidacao') || titulo.includes('linha editorial') || titulo.includes('evento presencial')) {
            t.space_id = 'space_atendimento';
            t.list_id = 'list_analises';
          }
          // Aulas & gravações → Produto / Aulas
          else if (titulo.includes('aula') || titulo.includes('gravação') || titulo.includes('gravacao') || titulo.includes('roteiro') || titulo.includes('gravar') || titulo.includes('área de membros')) {
            t.space_id = 'space_produto';
            t.list_id = 'list_aulas';
          }
          // Manuais, kits, processos → Produto / Manuais & Kits
          else if (titulo.includes('manual') || titulo.includes('kit') || titulo.includes('playbook') || titulo.includes('processo') || titulo.includes('classificação') || titulo.includes('c1/c2/c3') || titulo.includes('template') || titulo.includes('protocolo')) {
            t.space_id = 'space_produto';
            t.list_id = 'list_manuais';
          }
          // Planejamento de produto → Produto / Planejamento
          else if (titulo.includes('oferta') || titulo.includes('funil') || titulo.includes('produto') || titulo.includes('formato') || titulo.includes('precificação') || titulo.includes('precificacao') || fonte === 'direcionamento') {
            t.space_id = 'space_produto';
            t.list_id = 'list_planejamento';
          }
          // Spalla / sistema → Tecnologia / Maestro
          else if (titulo.includes('spalla') || titulo.includes('maestro') || titulo.includes('dashboard') || titulo.includes('painel') || titulo.includes('wireframe')) {
            t.space_id = 'space_tecnologia';
            t.list_id = 'list_maestro';
          }
          // Agentes & automações → Tecnologia
          else if (titulo.includes('agente') || titulo.includes('n8n') || titulo.includes('workflow') || titulo.includes('automação') || titulo.includes('automacao') || titulo.includes('manychat') || titulo.includes('webhook')) {
            t.space_id = 'space_tecnologia';
            t.list_id = 'list_agentes';
          }
          // Has mentorado associated → Atendimento / Operacional
          else if (t.mentorado_nome) {
            t.space_id = 'space_atendimento';
            t.list_id = 'list_operacional';
          }
          // Everything else → Atendimento / Operacional
          else {
            t.space_id = 'space_atendimento';
            t.list_id = 'list_operacional';
          }
        }
      });
    },

    _cacheTasksLocal() {
      try { localStorage.setItem(CONFIG.TASKS_STORAGE_KEY, JSON.stringify(this.data.tasks)); } catch (e) {}
    },

    async _sbUpsertTask(task, isNew = false) {
      if (!sb) return { ok: false };
      const VALID_COLS = ['id','titulo','descricao','status','prioridade','responsavel','acompanhante','mentorado_id','mentorado_nome','data_inicio','data_fim','space_id','list_id','parent_task_id','tags','fonte','doc_link','created_at','updated_at','created_by','recorrencia','dia_recorrencia','recorrencia_ativa','recorrencia_origem_id','bloqueio_motivo','bloqueio_responsavel','tipo','context_ativo_ids'];
      const DATE_COLS = ['data_inicio', 'data_fim'];
      const row = {};
      for (const k of VALID_COLS) { if (task[k] !== undefined) row[k] = task[k]; }
      // Empty string is invalid for DATE columns — convert to null
      for (const k of DATE_COLS) { if (row[k] === '') row[k] = null; }
      if (row.mentorado_id) row.mentorado_id = parseInt(row.mentorado_id) || null;
      if (isNew && this.auth.currentUser) row.created_by = this.auth.currentUser.id;
      try {
        const { error } = await sb.from('god_tasks').upsert(row, { onConflict: 'id' });
        if (error) {
          // Graceful degradation: if bloqueio columns not in DB yet, retry without them
          if (error.code === '42703' && error.message && error.message.includes('bloqueio_')) {
            const fallback = { ...row };
            delete fallback.bloqueio_motivo;
            delete fallback.bloqueio_responsavel;
            const { error: err2 } = await sb.from('god_tasks').upsert(fallback, { onConflict: 'id' });
            if (err2) { console.warn('[Spalla] Task upsert error:', err2.message); return { ok: false, error: err2 }; }
            console.warn('[Spalla] bloqueio colunas ausentes — aplique a migration 20260324120000_add_bloqueio_motivo.sql');
            return { ok: true };
          }
          console.warn('[Spalla] Task upsert error:', error.message); return { ok: false, error };
        }
        return { ok: true };
      } catch (e) { console.warn('[Spalla] Task upsert error:', e.message); return { ok: false }; }
    },

    async _sbDeleteTask(taskId) {
      if (!sb) return { ok: false };
      try {
        const { error } = await sb.from('god_tasks').delete().eq('id', taskId);
        if (error) { console.warn('[Spalla] Task delete error:', error.message); return { ok: false }; }
        return { ok: true };
      } catch (e) { console.warn('[Spalla] Task delete error:', e.message); return { ok: false }; }
    },

    async _sbSyncSubtasks(taskId, subtasks) {
      if (!sb) return { ok: false };
      try {
        const { error: delErr } = await sb.from('god_task_subtasks').delete().eq('task_id', taskId);
        if (delErr) { console.warn('[Spalla] Subtask delete error:', delErr.message); return { ok: false }; }
        if (subtasks?.length) {
          const rows = subtasks.map((s, i) => ({
            task_id:    taskId,
            texto:      s.text || s.texto || '',
            done:       s.done || false,
            sort_order: i,
            status:     s.status || (s.done ? 'concluida' : 'pendente'),
            responsavel: s.responsavel || null,
            data_inicio: s.data_inicio || null,
            data_fim:    s.data_fim || null,
            prioridade:  s.prioridade || 'normal',
            clickup_id:  s.clickup_id || null,
            updated_at:  new Date().toISOString(),
          }));
          const { error: insErr } = await sb.from('god_task_subtasks').insert(rows);
          if (insErr) { console.warn('[Spalla] Subtask insert error:', insErr.message); return { ok: false }; }
        }
        return { ok: true };
      } catch (e) { console.warn('[Spalla] Subtask sync error:', e.message); return { ok: false }; }
    },

    async _sbSyncChecklist(taskId, checklist) {
      if (!sb) return { ok: false };
      try {
        const { error: delErr } = await sb.from('god_task_checklist').delete().eq('task_id', taskId);
        if (delErr) { console.warn('[Spalla] Checklist delete error:', delErr.message); return { ok: false }; }
        if (checklist?.length) {
          const rows = checklist.map((c, i) => ({
            task_id:    taskId,
            texto:      c.text || c.texto || '',
            done:       c.done || false,
            sort_order: i,
            due_date:   c.due_date || null,
            assignee:   c.assignee || null,
            updated_at: new Date().toISOString(),
          }));
          const { error: insErr } = await sb.from('god_task_checklist').insert(rows);
          if (insErr) { console.warn('[Spalla] Checklist insert error:', insErr.message); return { ok: false }; }
        }
        return { ok: true };
      } catch (e) { console.warn('[Spalla] Checklist sync error:', e.message); return { ok: false }; }
    },

    // ── Dependencies ──────────────────────────────────────────────────────────
    async addDependency(taskId, dependsOnId, tipo = 'finish_to_start') {
      if (!sb || taskId === dependsOnId) return;
      const t = this.data.tasks.find(x => x.id === taskId);
      if (!t) return;
      const already = (t.dependencies || []).some(d => d.depends_on === dependsOnId);
      if (already) { this.toast('Dependência já existe', 'info'); return; }
      const blocker = this.data.tasks.find(x => x.id === dependsOnId);
      const row = { task_id: taskId, depends_on: dependsOnId, tipo, created_by: this.currentUserName };
      const { data: inserted, error } = await sb.from('god_task_dependencies').insert(row).select().single();
      if (error) { this.toast('Erro ao criar dependência: ' + error.message, 'error'); return; }
      if (!t.dependencies) t.dependencies = [];
      t.dependencies.push({
        dep_id: inserted.id, depends_on: dependsOnId, tipo,
        blocker_titulo: blocker?.titulo || dependsOnId,
        blocker_status: blocker?.status || 'backlog',
        blocker_data_fim: blocker?.data_fim || null,
      });
      // Update is_blocked flag
      t.is_blocked = t.dependencies.some(d => d.blocker_status !== 'concluida');
      this._cacheTasksLocal();
      this.toast('Dependência criada', 'success');
    },

    async removeDependency(taskId, depId) {
      if (!sb) return;
      const t = this.data.tasks.find(x => x.id === taskId);
      if (!t) return;
      const { error } = await sb.from('god_task_dependencies').delete().eq('id', depId);
      if (error) { this.toast('Erro ao remover dependência: ' + error.message, 'error'); return; }
      t.dependencies = (t.dependencies || []).filter(d => d.dep_id !== depId);
      t.is_blocked = t.dependencies.some(d => d.blocker_status !== 'concluida');
      this._cacheTasksLocal();
      this.toast('Dependência removida', 'info');
    },

    // Validate subtask dates against parent task range (returns array of warning strings)
    _validateSubtaskDates(parentTask, subtask) {
      const warnings = [];
      if (!parentTask) return warnings;
      const parentStart = parentTask.data_inicio ? new Date(parentTask.data_inicio) : null;
      const parentEnd   = parentTask.data_fim    ? new Date(parentTask.data_fim)    : null;
      const subStart    = subtask.data_inicio    ? new Date(subtask.data_inicio)    : null;
      const subEnd      = subtask.data_fim       ? new Date(subtask.data_fim)       : null;
      if (parentStart && subStart && subStart < parentStart)
        warnings.push(`Início da subtarefa (${subtask.data_inicio}) anterior ao início da tarefa mãe (${parentTask.data_inicio})`);
      if (parentEnd && subEnd && subEnd > parentEnd)
        warnings.push(`Prazo da subtarefa (${subtask.data_fim}) ultrapassa o prazo da tarefa mãe (${parentTask.data_fim})`);
      return warnings;
    },

    // Progress helper for task cards and detail — always returns {done,total,pct}
    subtaskProgress(task) {
      const total = task.subtasks_total ?? (task.subtasks || []).length;
      const done  = task.subtasks_done  ?? (task.subtasks || []).filter(s => s.done).length;
      return { done, total, pct: total ? Math.round((done / total) * 100) : 0 };
    },

    async _sbAddComment(taskId, author, text) {
      if (!sb) return { ok: false };
      try {
        const { error } = await sb.from('god_task_comments').insert({ task_id: taskId, author, texto: text });
        if (error) { console.warn('[Spalla] Comment error:', error.message); return { ok: false }; }
        return { ok: true };
      } catch (e) { console.warn('[Spalla] Comment error:', e.message); return { ok: false }; }
    },

    async _sbDeleteComment(commentId) {
      if (!sb) return { ok: false };
      try {
        const { error } = await sb.from('god_task_comments').delete().eq('id', commentId);
        if (error) { console.warn('[Spalla] Delete comment error:', error.message); return { ok: false }; }
        return { ok: true };
      } catch (e) { console.warn('[Spalla] Delete comment error:', e.message); return { ok: false }; }
    },

    async _sbAddHandoff(taskId, from, to, note) {
      if (!sb) return { ok: false };
      try {
        const { error } = await sb.from('god_task_handoffs').insert({ task_id: taskId, from_person: from, to_person: to, note });
        if (error) { console.warn('[Spalla] Handoff error:', error.message); return { ok: false }; }
        return { ok: true };
      } catch (e) { console.warn('[Spalla] Handoff error:', e.message); return { ok: false }; }
    },

    openTaskModal(task = null) {
      if (task) {
        this.taskForm = {
          titulo: task.titulo,
          descricao: task.descricao || '',
          responsavel: (TEAM_MEMBERS.find(m => m.name.toLowerCase() === (task.responsavel||'').toLowerCase())?.name) || task.responsavel || '',
          acompanhante: (TEAM_MEMBERS.find(m => m.name.toLowerCase() === (task.acompanhante||'').toLowerCase())?.name) || task.acompanhante || '',
          mentorado_nome: task.mentorado_nome || '',
          tipo: task.tipo || 'geral',
          prioridade: task.prioridade || 'normal',
          prazo: task.data_fim || task.prazo || '',
          data_inicio: task.data_inicio || '',
          data_fim: task.data_fim || task.prazo || '',
          doc_link: task.doc_link || '',
          subtasks: task.subtasks ? [...task.subtasks] : [],
          checklist: task.checklist ? [...task.checklist] : [],
          comments: task.comments ? [...task.comments] : [],
          attachments: task.attachments ? [...task.attachments] : [],
          tags: task.tags ? [...task.tags] : [],
          dependencies: task.dependencies ? [...task.dependencies] : [],
          parent_task_id: task.parent_task_id || null,
          space_id: task.space_id || 'space_atendimento',
          list_id: task.list_id || '',
          recorrencia: task.recorrencia || 'nenhuma',
          dia_recorrencia: task.dia_recorrencia || null,
          recorrencia_ativa: task.recorrencia_ativa !== false,
          newSubtask: '',
          newCheckItem: '',
          newComment: '',
          newTag: '',
          newDependsOn: '',
          newDependsOnType: 'finish_to_start',
          bloqueio_motivo: task.bloqueio_motivo || '',
          bloqueio_responsavel: task.bloqueio_responsavel || '',
          context_ativo_ids: task.context_ativo_ids || [],
          fieldValues: {},
        };
        this.ui.taskEditId = task.id;
        this.loadFieldDefs(task.space_id, task.list_id, task.id);
        // Load mentee context for ativo autocomplete
        if (task.mentorado_id) this.loadMenteeContext(task.mentorado_id);
      } else {
        // Preserve mentorado_nome if it was pre-set (e.g. from mentee detail view)
        const presetMentorado = this.taskForm?.mentorado_nome || '';
        const presetTipo = this.taskForm?.tipo || 'geral';
        this.taskForm = { titulo: '', descricao: '', responsavel: '', acompanhante: '', mentorado_nome: presetMentorado, tipo: presetTipo, prioridade: 'normal', prazo: '', data_inicio: '', data_fim: '', doc_link: '', subtasks: [], checklist: [], comments: [], attachments: [], tags: [], dependencies: [], parent_task_id: null, space_id: 'space_atendimento', list_id: '', recorrencia: 'nenhuma', dia_recorrencia: null, recorrencia_ativa: true, bloqueio_motivo: '', bloqueio_responsavel: '', context_ativo_ids: [], newSubtask: '', newCheckItem: '', newComment: '', newTag: '', newDependsOn: '', newDependsOnType: 'finish_to_start', fieldValues: {} };
        this.ui.taskEditId = null;
        this.loadFieldDefs('space_atendimento', null, null);
      }
      this.ui.taskModal = true;
      this.ui.taskTagsDropdown = false;
    },

    closeTaskModal() {
      this.ui.taskModal = false;
      this.ui.taskEditId = null;
      this.taskForm.mentorado_nome = '';
    },

    async saveTask() {
      if (!this.taskForm.titulo.trim()) return;
      const formData = { ...this.taskForm };
      delete formData.newSubtask;
      delete formData.newCheckItem;
      delete formData.newComment;
      delete formData.newTag;
      delete formData.newDependsOn;
      delete formData.newDependsOnType;
      delete formData.fieldValues;
      // LF Story 4: limpa campos de UI helper antes de persistir
      delete formData.rrule_freq;
      delete formData.rrule_interval;
      // Triggered: extrai pra criar regra separada após salvar a task
      const triggerSpec = (formData.especie === 'triggered_template' && formData.trigger_aggregate && formData.trigger_event)
        ? { aggregate: formData.trigger_aggregate, event: formData.trigger_event, filter: formData.trigger_filter }
        : null;
      delete formData.trigger_aggregate;
      delete formData.trigger_event;
      delete formData.trigger_filter;
      // Recorrente: garante rrule construído
      if (formData.especie !== 'recorrente_template') {
        formData.rrule = null;
        formData.proxima_execucao = null;
      }
      const pendingDependencies = this.taskForm.dependencies || [];
      if (formData.data_fim) formData.prazo = formData.data_fim;
      // Normalize tags to TEXT[] for backward compat column
      const tagsObjects = formData.tags || [];
      formData.tags = tagsObjects.map(t => t.name || t);

      if (this.ui.taskEditId) {
        const idx = this.data.tasks.findIndex(t => t.id === this.ui.taskEditId);
        if (idx !== -1) {
          const backup = { ...this.data.tasks[idx] };
          const updated = { ...backup, ...formData, tags: tagsObjects, updated_at: new Date().toISOString() };
          this.data.tasks[idx] = updated;
          this._cacheTasksLocal();
          const r = await this._sbUpsertTask({ ...updated, tags: formData.tags });
          if (!r.ok) { this.data.tasks[idx] = backup; this._cacheTasksLocal(); this.toast('Erro ao salvar tarefa', 'error'); return; }
          await this._sbSyncSubtasks(updated.id, updated.subtasks);
          await this._sbSyncChecklist(updated.id, updated.checklist);
          await this._sbSyncTagRelations(updated.id, tagsObjects);
          await this.saveFieldValues(updated.id);
          // Sync new dependencies added via modal
          for (const dep of pendingDependencies.filter(d => d._new)) {
            await this.addDependency(updated.id, dep.depends_on, dep.tipo);
          }
        }
      } else {
        const newId = crypto.randomUUID ? crypto.randomUUID() : 'task_' + Date.now();
        const newTask = {
          id: newId, ...formData,
          status: 'pendente', fonte: 'manual',
          comments: [], attachments: [], handoffs: [],
          tags: tagsObjects,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        };
        const r = await this._sbUpsertTask({ ...newTask, tags: formData.tags }, true);
        if (!r.ok) { this.toast('Erro ao criar tarefa', 'error'); return; }
        this.data.tasks.push(newTask);
        if (newTask.subtasks?.length) await this._sbSyncSubtasks(newId, newTask.subtasks);
        if (newTask.checklist?.length) await this._sbSyncChecklist(newId, newTask.checklist);
        if (tagsObjects.length) await this._sbSyncTagRelations(newId, tagsObjects);
        await this.saveFieldValues(newId);
        // TASK-03/09: Notify responsavel via WhatsApp (only on creation, not edit)
        if (newTask.responsavel) {
          newTask._notifyMentorado = this.taskForm.notificarMentorado || false;
          this._notifyTaskViaWa(newTask).catch(e => console.warn('[task-notify]', e));
        }
        // LF Story 4: cria regra de trigger se especie=triggered_template
        if (triggerSpec) {
          await this._createTriggerRule(newId, triggerSpec);
        }
      }
      this._cacheTasksLocal();
      this.closeTaskModal();
      this.toast('Tarefa salva', 'success');
    },

    async _notifyTaskViaWa(task) {
      if (!task.responsavel || !sb) return;
      const baseUrl = window.location.origin;
      const link = `${baseUrl}/tasks?detail=${task.id}`;
      const prazo = task.data_fim || task.prazo || '';
      const criador = this.currentUserName || '';

      // Lookup responsavel's whatsapp_jid from spalla_members (via Supabase, no backend needed)
      try {
        const { data: members } = await sb.from('spalla_members')
          .select('nome_curto,whatsapp_jid')
          .eq('ativo', true);

        const member = (members || []).find(m => m.nome_curto?.toLowerCase() === task.responsavel.toLowerCase());
        if (!member?.whatsapp_jid) {
          console.warn('[task-notify] No whatsapp_jid for', task.responsavel);
          return;
        }

        // Build message
        const tipoInfo = this.TASK_TIPO_MAP[task.tipo] || this.TASK_TIPO_MAP.geral;
        const now = new Date();
        const dataHora = now.toLocaleDateString('pt-BR') + ' às ' + now.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
        const lines = [`📋 *Nova tarefa:* ${task.titulo}`];
        if (task.descricao) lines.push(`📝 ${task.descricao.substring(0, 150)}${task.descricao.length > 150 ? '...' : ''}`);
        lines.push(`${tipoInfo.icon} Tipo: ${tipoInfo.label}`);
        if (criador) lines.push(`👤 Criada por: ${criador}`);
        if (task.mentorado_nome) lines.push(`🧑 Mentorado: ${task.mentorado_nome}`);
        if (prazo) lines.push(`📅 Prazo: ${new Date(prazo + 'T12:00:00').toLocaleDateString('pt-BR')}`);
        lines.push(`🕐 Cadastrada em: ${dataHora}`);
        if (link) lines.push(`🔗 ${link}`);
        const text = lines.join('\n');

        // Send via backend proxy (same endpoint as WA chat — already works)
        const { instance } = this._waActiveInstance();
        if (!instance) return;
        const number = member.whatsapp_jid.split('@')[0];
        await fetch(`${CONFIG.API_BASE}/api/wa/send-text`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
          body: JSON.stringify({ number, text, instance }),
        });
      } catch (e) { console.warn('[task-notify]', e); }

      // TASK-09: Notify mentorado if opted in and tipo is dossie/ajuste
      if (task._notifyMentorado && task.mentorado_nome) {
        const tipo = task.tipo || 'geral';
        if (['dossie', 'ajuste_dossie'].includes(tipo)) {
          this._notifyMentoradoViaWa(task).catch(e => console.warn('[task-notify-mentee]', e));
        }
      }
    },

    async _notifyMentoradoViaWa(task) {
      if (!sb || !task.mentorado_nome) return;
      const mentoradoId = task.mentorado_id;
      if (!mentoradoId) return;
      const { data: groups } = await sb.from('wa_groups').select('group_jid').eq('mentorado_id', mentoradoId).limit(1);
      if (!groups?.length) return;
      const jid = groups[0].group_jid;

      const text = `Olá! Uma nova ação foi registrada para você:\n\n📋 *${task.titulo}*\n${task.data_fim ? '📅 Prazo: ' + new Date(task.data_fim + 'T12:00:00').toLocaleDateString('pt-BR') : ''}\n\nSe tiver dúvidas, é só mandar aqui!`;

      const { instance } = this._waActiveInstance();
      if (!instance) return;
      await fetch(`${CONFIG.API_BASE}/api/wa/send-text`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
        body: JSON.stringify({ number: jid, text, instance, group_jid: jid }),
      });
    },

    // Dragon 52: Undo/Redo stack
    _undoStack: [],
    _redoStack: [],
    _pushUndo(taskId, field, oldValue, newValue) {
      this._undoStack.push({ taskId, field, oldValue, newValue, ts: Date.now() });
      if (this._undoStack.length > 50) this._undoStack.shift();
      this._redoStack = [];
    },
    async undo() {
      const entry = this._undoStack.pop();
      if (!entry) return this.toast('Nada para desfazer', 'info');
      this._redoStack.push(entry);
      await this._applyFieldChange(entry.taskId, entry.field, entry.oldValue, true);
      this.toast('Desfeito: ' + entry.field, 'info');
    },
    async redo() {
      const entry = this._redoStack.pop();
      if (!entry) return this.toast('Nada para refazer', 'info');
      this._undoStack.push(entry);
      await this._applyFieldChange(entry.taskId, entry.field, entry.newValue, true);
      this.toast('Refeito: ' + entry.field, 'info');
    },
    async _applyFieldChange(taskId, field, value, skipUndo) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (!t) return;
      const dbValue = (value === '' && ['sprint_id', 'list_id'].includes(field)) ? null : value;
      t[field] = value;
      t.updated_at = new Date().toISOString();
      this._cacheTasksLocal();
      if (sb) {
        const { error } = await sb.from('god_tasks').update({ [field]: dbValue, updated_at: t.updated_at }).eq('id', taskId);
        if (error) this.toast('Erro ao atualizar ' + field, 'error');
      }
    },

    async updateTaskField(taskId, field, value) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (!t) return;
      // Normalize responsavel to lowercase (prevent duplicates like "Kaique" vs "kaique")
      if (field === 'responsavel' && value) value = value.toLowerCase().trim();
      // Normalize empty strings to null for DB (sprint_id, list_id)
      const dbValue = (value === '' && ['sprint_id', 'list_id'].includes(field)) ? null : value;
      const old = t[field];
      t[field] = value;
      t.updated_at = new Date().toISOString();
      this._cacheTasksLocal();
      this._pushUndo(taskId, field, old, value);
      if (sb) {
        const { error } = await sb.from('god_tasks').update({ [field]: dbValue, updated_at: t.updated_at }).eq('id', taskId);
        if (error) { t[field] = old; this._cacheTasksLocal(); this.toast('Erro ao atualizar ' + field, 'error'); }
      }
    },

    async updateTaskStatus(taskId, newStatus) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (!t) return;
      const oldStatus = t.status;

      // Map (currentStatus, targetStatus) → FSM event
      const eventMap = {
        'pendente→em_andamento': 'start',
        'pendente→bloqueada': 'block',
        'pendente→cancelada': 'cancel',
        'pendente→concluida': 'complete',
        'em_andamento→concluida': 'complete',
        'em_andamento→em_revisao': 'request_review',
        'em_andamento→bloqueada': 'block',
        'em_andamento→pausada': 'pause',
        'em_andamento→cancelada': 'cancel',
        'em_revisao→concluida': 'approve',
        'em_revisao→em_andamento': 'changes_requested',
        'em_revisao→cancelada': 'cancel',
        'bloqueada→em_andamento': 'unblock',
        'bloqueada→cancelada': 'cancel',
        'pausada→em_andamento': 'resume',
        'pausada→cancelada': 'cancel',
        'concluida→arquivada': 'archive',
        'concluida→em_andamento': 'reopen',
        'concluida→pendente': 'reopen',
        'cancelada→arquivada': 'archive',
        'cancelada→pendente': 'reopen',
      };
      let event = eventMap[`${oldStatus}→${newStatus}`];
      // Gates use 'approve' instead of 'complete' from pendente
      if (t.especie === 'gate' && oldStatus === 'pendente' && newStatus === 'concluida') event = 'approve';

      // Optimistic update
      t.status = newStatus;
      t.updated_at = new Date().toISOString();
      this._cacheTasksLocal();

      if (event && CONFIG.API_BASE) {
        // Use FSM transition endpoint (validates guards)
        try {
          const res = await fetch(`${CONFIG.API_BASE}/api/tasks/${taskId}/transition`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
            body: JSON.stringify({ event }),
          });
          if (!res.ok) {
            const err = await res.json().catch(() => ({}));
            t.status = oldStatus; this._cacheTasksLocal();
            this.toast(err.error || 'Transição não permitida', 'error');
            return;
          }
          // ORCH-04: Dependency Reactor feedback
          const resData = await res.json().catch(() => ({}));
          if (resData.reactor && resData.reactor.length > 0) {
            for (const r of resData.reactor) {
              const localT = this.data.tasks.find(x => x.id === r.task_id);
              if (localT && r.action !== 'ready_for_human') {
                localT.status = 'em_andamento';
                localT.updated_at = new Date().toISOString();
              }
              const label = r.action === 'agent_auto_started' ? 'Agente iniciado' : r.action === 'auto_unblocked' ? 'Desbloqueada' : 'Pronta';
              this.toast(`${label}: ${r.titulo}`, 'success');
            }
            this._cacheTasksLocal();
          }
        } catch (e) {
          // Fallback to direct update if transition API unreachable
          if (sb) {
            const { error } = await sb.from('god_tasks').update({ status: newStatus, updated_at: t.updated_at }).eq('id', taskId);
            if (error) { t.status = oldStatus; this._cacheTasksLocal(); this.toast('Erro ao atualizar status', 'error'); return; }
          }
        }
      } else if (sb) {
        // No matching event (same status, or unmapped) — direct update
        const { error } = await sb.from('god_tasks').update({ status: newStatus, updated_at: t.updated_at }).eq('id', taskId);
        if (error) { t.status = oldStatus; this._cacheTasksLocal(); this.toast('Erro ao atualizar status', 'error'); return; }
      }
      if (newStatus === 'concluida') this._checkRecurringTasks();
    },

    async deleteTask(taskId) {
      const backup = this.data.tasks.find(t => t.id === taskId);
      this.data.tasks = this.data.tasks.filter(t => t.id !== taskId);
      this._cacheTasksLocal();
      const r = await this._sbDeleteTask(taskId);
      if (!r.ok && backup) { this.data.tasks.push(backup); this._cacheTasksLocal(); this.toast('Erro ao remover tarefa', 'error'); return; }
      this.toast('Tarefa removida', 'info');
    },

    async syncClickUpSubtasks() {
      this.ui.syncingSubtasks = true;
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/clickup/sync-subtasks`, { method: 'POST' });
        const json = await res.json();
        if (!res.ok) {
          this.toast(json.error || 'Erro ao sincronizar subtasks', 'error');
          return;
        }
        const msg = json.tasks_matched === 0
          ? 'Nenhuma tarefa com operon_id encontrada'
          : `${json.synced} subtask(s) sincronizada(s) em ${json.tasks_matched} tarefa(s)`;
        this.toast(msg, json.synced > 0 ? 'success' : 'info');
        if (json.synced > 0) await this.loadTasks();
      } catch (e) {
        this.toast('Erro de conexão ao sincronizar subtasks', 'error');
      } finally {
        this.ui.syncingSubtasks = false;
      }
    },

    async clickupImportAll() {
      if (!confirm('Importar todas as tarefas do ClickUp? Tarefas existentes serao atualizadas.')) return;
      this.ui.syncingSubtasks = true;
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/clickup/import-all`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}' });
        const json = await res.json();
        if (!res.ok) { this.toast(json.error || 'Erro ao importar', 'error'); return; }
        this.toast(`Importadas: ${json.imported}, Atualizadas: ${json.updated}`, 'success');
        await this.loadTasks();
      } catch (e) { this.toast('Erro de conexao', 'error'); }
      finally { this.ui.syncingSubtasks = false; }
    },

    // Sync status per task: 'synced' | 'pending' | 'unlinked'
    taskSyncStatus(task) {
      if (!task) return 'unlinked';
      if (!task.operon_id) return 'unlinked';
      if (!task.clickup_synced_at) return 'pending';
      const synced = new Date(task.clickup_synced_at);
      const updated = new Date(task.updated_at || task.created_at);
      return updated > synced ? 'pending' : 'synced';
    },

    taskSyncLabel(task) {
      const s = this.taskSyncStatus(task);
      return s === 'synced' ? 'Sincronizado' : s === 'pending' ? 'Pendente' : 'Não vinculado';
    },

    taskSyncColor(task) {
      const s = this.taskSyncStatus(task);
      return s === 'synced' ? '#10b981' : s === 'pending' ? '#f59e0b' : 'var(--neutral-300)';
    },

    async clickupPushTask(taskId) {
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/clickup/push/${taskId}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}' });
        const json = await res.json();
        if (!res.ok) { this.toast(json.error || 'Erro ao enviar', 'error'); return; }
        if (json.clickup_url) {
          const idx = this.data.tasks.findIndex(t => t.id === taskId);
          if (idx >= 0) {
            this.data.tasks[idx] = { ...this.data.tasks[idx], operon_id: json.clickup_id, clickup_url: json.clickup_url };
          }
        }
        this.toast(`Task ${json.action === 'created' ? 'criada' : 'atualizada'} no ClickUp`, 'success');
      } catch (e) { this.toast('Erro ao enviar pro ClickUp', 'error'); }
    },

    addSubtask() {
      if (this.taskForm.newSubtask.trim()) {
        this.taskForm.subtasks.push({
          text: this.taskForm.newSubtask.trim(),
          done: false,
          status: 'pendente',
          responsavel: '',
          data_inicio: '',
          data_fim: '',
          prioridade: 'normal',
          clickup_id: null,
        });
        this.taskForm.newSubtask = '';
      }
    },

    removeSubtask(idx) {
      this.taskForm.subtasks.splice(idx, 1);
    },

    addCheckItem() {
      if (this.taskForm.newCheckItem.trim()) {
        this.taskForm.checklist.push({ text: this.taskForm.newCheckItem.trim(), done: false, due_date: '', assignee: '' });
        this.taskForm.newCheckItem = '';
      }
    },

    removeCheckItem(idx) {
      this.taskForm.checklist.splice(idx, 1);
    },

    toggleCheckItem(taskId, idx) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t && t.checklist && t.checklist[idx]) {
        t.checklist[idx].done = !t.checklist[idx].done;
        this._cacheTasksLocal();
        this._sbSyncChecklist(taskId, t.checklist);
      }
    },

    toggleSubtask(taskId, idx) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t && t.subtasks && t.subtasks[idx]) {
        t.subtasks[idx].done = !t.subtasks[idx].done;
        this._cacheTasksLocal();
        this._sbSyncSubtasks(taskId, t.subtasks);
      }
    },

    async drawerAddSubtask(taskId) {
      const text = (this.ui.drawerNewSubtask || '').trim();
      if (!text) return;
      const t = this.data.tasks.find(x => x.id === taskId);
      if (!t) return;
      const newSub = { text, done: false, status: 'pendente', responsavel: '', data_inicio: '', data_fim: '', prioridade: 'normal', clickup_id: null };
      if (!t.subtasks) t.subtasks = [];
      t.subtasks.push(newSub);
      t.subtasks_total = t.subtasks.length;
      this.ui.drawerNewSubtask = '';
      this._cacheTasksLocal();
      await this._sbSyncSubtasks(taskId, t.subtasks);
    },

    taskChecklistProgress(task) {
      if (!task.checklist || !task.checklist.length) return null;
      const done = task.checklist.filter(c => c.done).length;
      return { done, total: task.checklist.length, pct: Math.round((done / task.checklist.length) * 100) };
    },

    // Task detail drawer
    openTaskDetail(taskId) {
      // Navigate to tasks page if not already there
      if (this.ui.page !== 'tasks') {
        this.navigate('tasks');
      }
      this.ui.taskDetailDrawer = taskId;
      this.ui.taskActivity = [];
      this._loadTaskActivity(taskId);
      // Update URL for shareable link
      if (taskId && window.history.replaceState) {
        window.history.replaceState(null, '', `/tasks?task=${taskId}`);
      }
    },

    // Copy shareable task link
    copyTaskLink(taskId) {
      const url = `${window.location.origin}/tasks?task=${taskId}`;
      navigator.clipboard.writeText(url).then(() => this.toast('Link copiado!', 'success'));
    },

    formatActivity(evt) {
      if (evt.action === 'created') return `criou esta tarefa`;
      if (evt.action === 'field_change') {
        const labels = { status: 'status', responsavel: 'responsável', prioridade: 'prioridade' };
        const fieldLabel = labels[evt.field] || evt.field;
        if (evt.old_value && evt.new_value) return `alterou ${fieldLabel} de "${evt.old_value}" para "${evt.new_value}"`;
        if (evt.new_value) return `definiu ${fieldLabel} como "${evt.new_value}"`;
        return `alterou ${fieldLabel}`;
      }
      return evt.action;
    },

    async _loadTaskActivity(taskId) {
      if (!sb || !taskId) return;
      try {
        const { data, error } = await sb.from('god_task_activity')
          .select('*')
          .eq('task_id', taskId)
          .order('created_at', { ascending: false })
          .limit(50);
        if (!error && data) this.ui.taskActivity = data;
      } catch (e) { console.warn('[Activity] load error:', e); }
    },

    closeTaskDetail() {
      this.ui.taskDetailDrawer = null;
      // Reset URL (remove ?task= param) — only on tasks page
      if (window.history.replaceState && this.ui.page === 'tasks') {
        window.history.replaceState(null, '', '/tasks');
      }
    },

    get activeTaskDetail() {
      if (!this.ui.taskDetailDrawer) return null;
      return this.data.tasks.find(t => t.id === this.ui.taskDetailDrawer);
    },

    // Comments
    async addComment(taskId) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t && this.taskForm.newComment?.trim()) {
        if (!t.comments) t.comments = [];
        const commentText = this.taskForm.newComment.trim();
        const commentId = crypto.randomUUID ? crypto.randomUUID() : 'comment_' + Date.now();
        // Get author name from current user
        const authorName = this.currentUserName;
        t.comments.push({ id: commentId, author: authorName, text: commentText, timestamp: new Date().toISOString() });
        this.taskForm.newComment = '';
        this._cacheTasksLocal();
        this._sbAddComment(taskId, authorName, commentText);
      }
    },

    toggleReaction(taskId, commentId, emoji) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (!t || !t.comments) return;
      const cm = t.comments.find(c => c.id === commentId);
      if (!cm) return;
      if (!cm.reactions) cm.reactions = {};
      if (cm.reactions[emoji]) {
        cm.reactions[emoji]--;
        if (cm.reactions[emoji] <= 0) delete cm.reactions[emoji];
      } else {
        cm.reactions[emoji] = (cm.reactions[emoji] || 0) + 1;
      }
      this._cacheTasksLocal();
      // Persist reactions to Supabase
      if (sb) {
        sb.from('god_task_comments').update({ reactions: cm.reactions }).eq('id', commentId).then(({ error }) => {
          if (error) console.warn('[Reactions] save error:', error);
        });
      }
    },

    async deleteComment(taskId, commentId) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t && t.comments) {
        t.comments = t.comments.filter(c => c.id !== commentId);
        this._cacheTasksLocal();
        this._sbDeleteComment(commentId);
      }
    },

    // ===================== MENTIONS =====================

    // Detecta @ enquanto digita no textarea de comentário
    handleMentionInput(e) { return this.onCommentKeyup(e); },
    onCommentKeyup(e) {
      const ta = e.target;
      const text = ta.value;
      const pos = ta.selectionStart;
      const slice = text.slice(0, pos);
      const atIdx = slice.lastIndexOf('@');
      if (atIdx >= 0 && !slice.slice(atIdx + 1).includes(' ') && !slice.slice(atIdx + 1).includes('\n')) {
        this.ui.mentionQuery = slice.slice(atIdx + 1);
        this.ui.mentionStart = atIdx;
        this.ui.mentionDropdown = true;
      } else {
        this.ui.mentionDropdown = false;
        this.ui.mentionStart = -1;
      }
    },

    onCommentKeydown(e) {
      if (this.ui.mentionDropdown && e.key === 'Escape') {
        this.ui.mentionDropdown = false;
      }
    },

    mentionMembers() {
      const q = (this.ui.mentionQuery || '').toLowerCase();
      const members = this.data.members?.length
        ? this.data.members
        : TEAM_MEMBERS.map(m => ({ id: m.id, nome_curto: m.name, cor: '#6366f1' }));
      if (!q) return members;
      return members.filter(m =>
        (m.nome_curto || '').toLowerCase().includes(q) ||
        (m.nome_completo || '').toLowerCase().includes(q)
      );
    },

    insertMention(name, targetEl) {
      const ta = targetEl || this.$refs.commentTextarea;
      if (!ta) return;
      const text = this.taskForm.newComment || '';
      const before = text.slice(0, this.ui.mentionStart);
      const cursorPos = ta.selectionStart;
      const after = text.slice(cursorPos);
      this.taskForm.newComment = before + '@' + name + ' ' + after;
      this.ui.mentionDropdown = false;
      this.ui.mentionQuery = '';
      this.$nextTick(() => {
        ta.focus();
        const cursor = (before + '@' + name + ' ').length;
        ta.setSelectionRange(cursor, cursor);
      });
    },

    // Renderiza texto de comentário com @menções estilizadas
    renderCommentText(text) {
      if (!text) return '';
      // Render markdown if marked is available, otherwise fallback
      let html = '';
      if (typeof marked !== 'undefined') {
        try {
          html = marked.parse(text);
          if (typeof DOMPurify !== 'undefined') html = DOMPurify.sanitize(html);
        } catch (e) { html = text.replace(/\n/g, '<br>'); }
      } else {
        html = text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/\n/g, '<br>');
      }
      // Highlight @mentions in rendered output
      return html.replace(/@(\w+)/g, '<span class="comment-mention">@$1</span>');
    },

    // Tags
    async addTag(taskId) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t && this.taskForm.newTag?.trim()) {
        if (!t.tags) t.tags = [];
        const tag = this.taskForm.newTag.trim();
        if (!t.tags.includes(tag)) t.tags.push(tag);
        this.taskForm.newTag = '';
        this._cacheTasksLocal();
        try {
          if (sb) { const { error } = await sb.from('god_tasks').update({ tags: t.tags }).eq('id', taskId); if (error) this.toast('Erro ao salvar tag', 'error'); }
        } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
      }
    },

    async removeTag(taskId, tag) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t && t.tags) {
        t.tags = t.tags.filter(tg => tg !== tag);
        this._cacheTasksLocal();
        try {
          if (sb) { const { error } = await sb.from('god_tasks').update({ tags: t.tags }).eq('id', taskId); if (error) this.toast('Erro ao remover tag', 'error'); }
        } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
      }
    },

    // --- Tags Relational Model ---
    async loadTaskTags() {
      if (!sb) return;
      try {
        const { data, error } = await sb.from('god_task_tags').select('*').order('name');
        if (!error && data) this.data.taskTags = data;
      } catch (e) { console.warn('[Spalla] loadTaskTags error:', e.message); }
    },

    async createTag(name, color = '#94a3b8') {
      if (!name?.trim() || !sb) return null;
      try {
        const { data, error } = await sb.from('god_task_tags')
          .insert({ name: name.trim(), color, scope: 'global', is_system: false })
          .select().single();
        if (!error && data) { this.data.taskTags.push(data); return data; }
        if (error) this.toast('Tag já existe ou erro: ' + error.message, 'error');
      } catch (e) { this.toast('Erro ao criar tag', 'error'); }
      return null;
    },

    async deleteTag(tagId) {
      const tag = this.data.taskTags.find(t => t.id === tagId);
      if (!tag || tag.is_system) return;
      this.data.taskTags = this.data.taskTags.filter(t => t.id !== tagId);
      if (sb) {
        const { error } = await sb.from('god_task_tags').delete().eq('id', tagId);
        if (error) { this.loadTaskTags(); this.toast('Erro ao remover tag', 'error'); }
      }
    },

    toggleFormTag(tagId) {
      if (!this.taskForm.tags) this.taskForm.tags = [];
      const tagDef = this.data.taskTags.find(t => t.id === tagId);
      if (!tagDef) return;
      const idx = this.taskForm.tags.findIndex(t => (t.id || t) === tagId);
      if (idx !== -1) {
        this.taskForm.tags.splice(idx, 1);
      } else {
        this.taskForm.tags.push({ id: tagDef.id, name: tagDef.name, color: tagDef.color });
      }
    },

    async _sbSyncTagRelations(taskId, tags) {
      if (!sb) return;
      await sb.from('god_task_tag_relations').delete().eq('task_id', taskId);
      const validTags = (tags || []).filter(t => t.id);
      if (validTags.length) {
        await sb.from('god_task_tag_relations').insert(
          validTags.map(t => ({ task_id: taskId, tag_id: t.id }))
        );
      }
    },

    // --- Custom Fields ---
    // Custom Fields — column helpers
    visibleCustomFields() {
      return (this.data.fieldDefs || []).filter(f => this.ui.visibleFieldIds[f.field_id || f.id]);
    },
    getTaskFieldValue(task, fieldId) {
      const cf = task.custom_fields_json || task.custom_fields || [];
      if (Array.isArray(cf)) {
        const found = cf.find(f => f.field_id === fieldId);
        return found?.value?.v ?? '';
      }
      return '';
    },
    toggleFieldVisibility(fieldId) {
      this.ui.visibleFieldIds = { ...this.ui.visibleFieldIds, [fieldId]: !this.ui.visibleFieldIds[fieldId] };
    },
    async createCustomField() {
      const name = this.ui.newFieldName?.trim();
      if (!name) return;
      const spaceId = this.ui.taskSpaceFilter !== 'all' ? this.ui.taskSpaceFilter : 'global';
      const scope = spaceId === 'global' ? 'global' : 'space:' + spaceId;
      try {
        const { data, error } = await sb.from('god_task_field_defs').insert({
          name,
          field_type: this.ui.newFieldType || 'text',
          scope,
          sort_order: (this.data.fieldDefs?.length || 0) + 1,
        }).select().single();
        if (error) throw error;
        this.ui.newFieldName = '';
        this.ui.visibleFieldIds = { ...this.ui.visibleFieldIds, [data.id]: true };
        await this.loadFieldDefs(this.ui.taskSpaceFilter !== 'all' ? this.ui.taskSpaceFilter : null);
        this.toast('Campo criado: ' + name, 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },

    async loadFieldDefs(spaceId = null, listId = null, taskId = null) {
      if (!sb) return;
      const p_task_id = taskId || '00000000-0000-0000-0000-000000000000';
      try {
        const { data, error } = await sb.rpc('get_task_fields', {
          p_task_id,
          p_space_id: spaceId || null,
          p_list_id: listId || null,
        });
        if (!error && data) {
          this.data.fieldDefs = data;
          if (taskId) {
            const vals = {};
            data.forEach(f => { if (f.value && f.value.v !== undefined) vals[f.field_id] = f.value.v; });
            this.taskForm.fieldValues = { ...this.taskForm.fieldValues, ...vals };
          }
        }
      } catch (e) { console.warn('[Spalla] loadFieldDefs error:', e.message); }
    },

    async saveFieldValues(taskId) {
      if (!sb || !taskId) return;
      const fieldValues = this.taskForm.fieldValues || {};
      const upserts = Object.entries(fieldValues)
        .filter(([, val]) => val !== null && val !== undefined && val !== '')
        .map(([fieldId, val]) => ({ task_id: taskId, field_id: fieldId, value: { v: val } }));
      if (!upserts.length) return;
      const { error } = await sb.from('god_task_field_values').upsert(upserts, { onConflict: 'task_id,field_id' });
      if (error) console.warn('[Spalla] saveFieldValues error:', error.message);
    },

    async saveInlineFieldValue(taskId, fieldId, value) {
      if (!sb || !taskId || !fieldId) return;
      try {
        await sb.from('god_task_field_values').upsert(
          { task_id: taskId, field_id: fieldId, value: { v: value } },
          { onConflict: 'task_id,field_id' }
        );
      } catch (e) {
        console.warn('[Spalla] saveInlineFieldValue:', e);
      }
    },

    async setParentTask(taskId, parentId) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t) {
        t.parent_task_id = parentId || null;
        this._cacheTasksLocal();
        try {
          if (sb) { const { error } = await sb.from('god_tasks').update({ parent_task_id: parentId || null }).eq('id', taskId); if (error) this.toast('Erro ao vincular tarefa', 'error'); }
        } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
      }
    },

    getChildTasks(taskId) {
      return this.data.tasks.filter(t => t.parent_task_id === taskId);
    },

    toggleTaskExpand(taskId) {
      this.ui.taskExpandedIds = { ...this.ui.taskExpandedIds, [taskId]: !this.ui.taskExpandedIds[taskId] };
    },

    getParentTask(taskId) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t?.parent_task_id) return this.data.tasks.find(x => x.id === t.parent_task_id);
      return null;
    },

    // Handoffs (passagem de bastão)
    async addHandoff(taskId, from, to, note) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (!t) return;
      if (!t.handoffs) t.handoffs = [];
      t.handoffs.push({ from, to, note, date: new Date().toISOString() });
      t.responsavel = to;
      t.updated_at = new Date().toISOString();
      this._cacheTasksLocal();
      const r = await this._sbAddHandoff(taskId, from, to, note);
      if (sb) { const { error } = await sb.from('god_tasks').update({ responsavel: to }).eq('id', taskId); if (error) this.toast('Erro ao atualizar responsável', 'error'); }
      if (r.ok) this.toast(`Tarefa passada de ${from} para ${to}`, 'success');
      else this.toast('Erro ao registrar handoff', 'error');
    },

    // Gantt helpers
    // ── Bulk Actions ──
    get bulkCount() { return Object.values(this.ui.bulkSelected).filter(Boolean).length; },
    _isRealTaskId(id) {
      // Reject synthetic IDs from tasksTree (subtask/checklist rows have prefixes)
      if (!id || typeof id !== 'string') return false;
      if (id.startsWith('sub_') || id.startsWith('check_')) return false;
      return true;
    },
    _lastBulkIdx: -1,
    bulkToggle(taskId, event) {
      if (!this._isRealTaskId(taskId)) return;
      // Only consider real (non-synthetic) tasks for range selection
      const tree = this.tasksTree.filter(t => !t._isGroupHeader && this._isRealTaskId(t.id));
      const idx = tree.findIndex(t => t.id === taskId);
      // Shift+Click range selection
      if (event?.shiftKey && this._lastBulkIdx >= 0 && idx >= 0) {
        const from = Math.min(this._lastBulkIdx, idx);
        const to = Math.max(this._lastBulkIdx, idx);
        const sel = { ...this.ui.bulkSelected };
        for (let i = from; i <= to; i++) {
          if (tree[i]) sel[tree[i].id] = true;
        }
        this.ui.bulkSelected = sel;
      } else {
        this.ui.bulkSelected = { ...this.ui.bulkSelected, [taskId]: !this.ui.bulkSelected[taskId] };
      }
      if (idx >= 0) this._lastBulkIdx = idx;
    },
    bulkSelectAll() {
      const sel = {};
      this.data.tasks.forEach(t => { sel[t.id] = true; });
      this.ui.bulkSelected = sel;
    },
    bulkClear() { this.ui.bulkSelected = {}; this.ui.bulkMode = false; },
    async bulkUpdateField(field, value) {
      const ids = Object.entries(this.ui.bulkSelected).filter(([,v]) => v).map(([id]) => id).filter(id => this._isRealTaskId(id));
      if (!ids.length) return;
      if (!confirm(`Atualizar ${ids.length} tarefa(s)?`)) return;
      try {
        const { error } = await sb.from('god_tasks').update({ [field]: value }).in('id', ids);
        if (error) throw error;
        this.data.tasks = this.data.tasks.map(t => ids.includes(t.id) ? { ...t, [field]: value } : t);
        this.toast(`${ids.length} tarefa(s) atualizada(s)`, 'success');
        this.bulkClear();
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },
    async bulkDelete() {
      const ids = Object.entries(this.ui.bulkSelected).filter(([,v]) => v).map(([id]) => id).filter(id => this._isRealTaskId(id));
      if (!ids.length) return;
      if (!confirm(`Excluir ${ids.length} tarefa(s) permanentemente?`)) return;
      try {
        const { error } = await sb.from('god_tasks').delete().in('id', ids);
        if (error) throw error;
        this.data.tasks = this.data.tasks.filter(t => !ids.includes(t.id));
        this.toast(`${ids.length} tarefa(s) excluida(s)`, 'success');
        this.bulkClear();
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },

    // ── Command Palette (Dragon 25) ──
    cmdPalette: false,
    cmdQuery: '',
    cmdSelectedIdx: 0,
    get cmdResults() {
      const q = (this.cmdQuery || '').toLowerCase().trim();
      if (!q) return this._cmdDefaultActions();
      const results = [];
      // Search tasks
      this.data.tasks.filter(t => t.titulo?.toLowerCase().includes(q)).slice(0, 8).forEach(t => {
        results.push({ type: 'task', icon: '📋', label: t.titulo, sublabel: t.responsavel || '', action: () => { this.openTaskDetail(t.id); this.cmdPalette = false; } });
      });
      // Search pages — use real ui.page keys (matching navigate())
      const pages = [
        { key: 'dashboard', label: 'Dashboard', icon: '📊' },
        { key: 'tasks', label: 'Tarefas', icon: '✅' },
        { key: 'kanban', label: 'Mentorados', icon: '👥' },
        { key: 'agenda', label: 'Agenda', icon: '📞' },
        { key: 'documentos', label: 'Documentos', icon: '📁' },
        { key: 'whatsapp', label: 'WhatsApp', icon: '💬' },
        { key: 'equipe', label: 'Equipe', icon: '👤' },
      ];
      pages.filter(p => p.label.toLowerCase().includes(q)).forEach(p => {
        results.push({ type: 'nav', icon: p.icon, label: 'Ir para ' + p.label, sublabel: '', action: () => { this.navigate(p.key); this.cmdPalette = false; } });
      });
      // Search members — filter tasks by responsavel via search input
      (this.data.members || []).filter(m => (m.nome_curto || m.name || '').toLowerCase().includes(q)).slice(0, 4).forEach(m => {
        const memberName = m.nome_curto || m.name;
        results.push({ type: 'member', icon: '👤', label: memberName, sublabel: 'Filtrar tarefas', action: () => { this.ui.search = memberName; this.navigate('tasks'); this.cmdPalette = false; } });
      });
      // Actions
      if ('nova tarefa'.includes(q) || 'criar'.includes(q) || 'new task'.includes(q)) {
        results.push({ type: 'action', icon: '➕', label: 'Criar nova tarefa', sublabel: 'N', action: () => { this.openTaskModal(); this.cmdPalette = false; } });
      }
      if ('dark'.includes(q) || 'escuro'.includes(q) || 'claro'.includes(q) || 'tema'.includes(q)) {
        results.push({ type: 'action', icon: '🌙', label: this.darkMode ? 'Modo claro' : 'Modo escuro', sublabel: '', action: () => { this.toggleDarkMode(); this.cmdPalette = false; } });
      }
      return results;
    },
    _cmdDefaultActions() {
      return [
        { type: 'action', icon: '➕', label: 'Criar nova tarefa', sublabel: 'N', action: () => { this.openTaskModal(); this.cmdPalette = false; } },
        { type: 'nav', icon: '✅', label: 'Ir para Tarefas', sublabel: '', action: () => { this.navigate('tasks'); this.cmdPalette = false; } },
        { type: 'nav', icon: '👥', label: 'Ir para Mentorados', sublabel: '', action: () => { this.navigate('kanban'); this.cmdPalette = false; } },
        { type: 'nav', icon: '📞', label: 'Ir para Agenda', sublabel: '', action: () => { this.navigate('agenda'); this.cmdPalette = false; } },
        { type: 'action', icon: '🌙', label: this.darkMode ? 'Modo claro' : 'Modo escuro', sublabel: '', action: () => { this.toggleDarkMode(); this.cmdPalette = false; } },
        { type: 'action', icon: '🔍', label: 'Buscar tarefa...', sublabel: '/', action: () => { this.navigate('tasks'); this.cmdPalette = false; setTimeout(() => document.querySelector('.tasks-main input[type="text"]')?.focus(), 200); } },
      ];
    },
    cmdExec(idx) {
      const item = this.cmdResults[idx || this.cmdSelectedIdx];
      if (item?.action) item.action();
    },
    cmdKeyDown(e) {
      if (e.key === 'ArrowDown') { e.preventDefault(); this.cmdSelectedIdx = Math.min(this.cmdSelectedIdx + 1, this.cmdResults.length - 1); }
      else if (e.key === 'ArrowUp') { e.preventDefault(); this.cmdSelectedIdx = Math.max(this.cmdSelectedIdx - 1, 0); }
      else if (e.key === 'Enter') { e.preventDefault(); this.cmdExec(); }
      else if (e.key === 'Escape') { this.cmdPalette = false; }
    },

    // ── Quick Filters (Dragon 39) ──
    quickFilter: null, // 'mine' | 'overdue' | 'unassigned' | 'thisWeek' | 'favorites'
    setQuickFilter(filter) {
      this.quickFilter = this.quickFilter === filter ? null : filter;
    },
    get quickFilterCounts() {
      const tasks = this.data.tasks;
      const me = (this.auth?.currentUser?.user_metadata?.full_name || this.auth?.currentUser?.full_name || this.auth?.currentUser?.email || '').toLowerCase().split(' ')[0];
      const now = new Date();
      const weekEnd = new Date(now); weekEnd.setDate(now.getDate() + 7);
      return {
        mine: tasks.filter(t => t.responsavel && me && t.responsavel.toLowerCase().includes(me)).length,
        overdue: tasks.filter(t => t.data_fim && new Date(t.data_fim) < now && t.status !== 'concluida').length,
        unassigned: tasks.filter(t => !t.responsavel).length,
        thisWeek: tasks.filter(t => t.data_fim && new Date(t.data_fim) >= now && new Date(t.data_fim) <= weekEnd).length,
        favorites: this.favorites.length,
        recurring: tasks.filter(t => t.recorrencia && t.recorrencia !== 'nenhuma').length,
      };
    },

    // ── Task Age (Dragon 43) ──
    taskAge(createdAt) {
      if (!createdAt) return null;
      const days = Math.floor((Date.now() - new Date(createdAt).getTime()) / 86400000);
      if (days <= 3) return { label: 'Novo', cls: 'cu-age--fresh' };
      if (days <= 7) return { label: days + 'd', cls: 'cu-age--week' };
      if (days <= 30) return { label: days + 'd', cls: 'cu-age--stale' };
      return { label: Math.floor(days / 30) + 'mo', cls: 'cu-age--ancient' };
    },

    // ── Focus/Zen Mode (Dragon 45) ──
    focusMode: false,
    toggleFocusMode() {
      this.focusMode = !this.focusMode;
      document.documentElement.classList.toggle('cu-focus-mode', this.focusMode);
    },

    // ── Context Menu (Dragon 48) ──
    contextMenu: { show: false, x: 0, y: 0, taskId: null },
    showContextMenu(e, taskId) {
      e.preventDefault();
      this.contextMenu = { show: true, x: e.clientX, y: e.clientY, taskId };
    },
    hideContextMenu() { this.contextMenu.show = false; },
    contextAction(action) {
      const id = this.contextMenu.taskId;
      this.hideContextMenu();
      if (!id) return;
      switch(action) {
        case 'open': this.openTaskDetail(id); break;
        case 'duplicate': this.duplicateTask(id); break;
        case 'favorite': this.toggleFavorite(id); break;
        case 'complete': this.updateTaskStatus(id, 'concluida'); break;
        case 'delete': if (confirm('Excluir?')) this.deleteTask(id); break;
        case 'timer': this.startTimeTracker(id); break;
        case 'copy': navigator.clipboard.writeText(window.location.origin + '/tasks?task=' + id); this.toast('Link copiado', 'success'); break;
      }
    },

    // ── Batch Move (Dragon 42) ──
    async bulkMoveToList(listId) {
      const ids = Object.entries(this.ui.bulkSelected).filter(([,v]) => v).map(([id]) => id);
      if (!ids.length || !sb) return;
      try {
        const { error } = await sb.from('god_tasks').update({ list_id: listId }).in('id', ids);
        if (error) throw error;
        this.data.tasks = this.data.tasks.map(t => ids.includes(t.id) ? { ...t, list_id: listId } : t);
        this.toast(`${ids.length} tarefa(s) movida(s)`, 'success');
        this.bulkClear();
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },

    // ── Task Archive (Dragon 35) ──
    async archiveTask(taskId) {
      if (!sb) return;
      try {
        await sb.from('god_tasks').update({ status: 'arquivada' }).eq('id', taskId);
        const task = this.data.tasks.find(t => t.id === taskId);
        if (task) task.status = 'arquivada';
        this.toast('Tarefa arquivada', 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },
    async restoreTask(taskId) {
      if (!sb) return;
      try {
        await sb.from('god_tasks').update({ status: 'pendente' }).eq('id', taskId);
        const task = this.data.tasks.find(t => t.id === taskId);
        if (task) task.status = 'pendente';
        this.toast('Tarefa restaurada', 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },

    // ── Action Items from Comments (Dragon 51) ──
    async createActionFromComment(taskId, commentText, assignee) {
      if (!sb || !commentText) return;
      try {
        const parent = this.data.tasks.find(t => t.id === taskId);
        const { data, error } = await sb.from('god_tasks').insert({
          titulo: commentText.slice(0, 200),
          responsavel: assignee || null,
          parent_task_id: taskId,
          status: 'pendente',
          prioridade: 'normal',
          tipo: 'acao',
          space_id: parent?.space_id,
          list_id: parent?.list_id,
          fonte: 'comment_action'
        }).select().single();
        if (error) throw error;
        this.data.tasks.push(data);
        this.toast('Item de acao criado', 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },

    // ── My Work View (Dragon 36) ──
    get myWorkData() {
      let meFirst = (this.auth?.currentUser?.full_name || this.auth?.currentUser?.user_metadata?.full_name || '').toLowerCase().split(' ')[0];
      if (!meFirst) meFirst = (this.auth?.currentUser?.email || '').toLowerCase().split(/[@.]/)[0];
      if (!meFirst) meFirst = 'kaique';
      const myTasks = this.data.tasks.filter(t => {
        const r = (t.responsavel || '').toLowerCase();
        return r === meFirst || r.includes(meFirst);
      });
      const now = new Date();
      const todayStr = now.toISOString().slice(0, 10);
      const weekEnd = new Date(now); weekEnd.setDate(now.getDate() + 7);
      return {
        overdue: myTasks.filter(t => t.data_fim && new Date(t.data_fim) < now && t.status !== 'concluida'),
        today: myTasks.filter(t => t.data_fim && t.data_fim.slice(0, 10) === todayStr && t.status !== 'concluida'),
        upcoming: myTasks.filter(t => t.data_fim && new Date(t.data_fim) > now && new Date(t.data_fim) <= weekEnd && t.status !== 'concluida'),
        done: myTasks.filter(t => t.status === 'concluida').slice(0, 10),
      };
    },

    // ── Activity Timeline (Dragon 22) ──
    activityTimeline: [],
    activityTimelineOpen: false,
    async loadActivityTimeline() {
      if (!sb) return;
      try {
        const { data, error } = await sb.from('god_task_activity')
          .select('*')
          .order('created_at', { ascending: false })
          .limit(100);
        if (!error && data) this.activityTimeline = data;
      } catch (e) { console.warn('[Activity]', e.message); }
    },
    get activityByDay() {
      const groups = {};
      for (const a of this.activityTimeline) {
        const day = (a.created_at || '').slice(0, 10);
        if (!groups[day]) groups[day] = [];
        groups[day].push(a);
      }
      return Object.entries(groups).map(([day, items]) => ({ day, items }));
    },

    // ── Task Watchers (Dragon 23) ──
    async toggleWatcher(taskId) {
      const me = this.auth?.currentUser?.user_metadata?.full_name || this.auth?.currentUser?.email || 'user';
      const task = this.data.tasks.find(t => t.id === taskId);
      if (!task) return;
      const watchers = task.watchers || [];
      const idx = watchers.indexOf(me);
      if (idx >= 0) watchers.splice(idx, 1);
      else watchers.push(me);
      task.watchers = [...watchers];
      if (sb) {
        try {
          await sb.from('god_tasks').update({ watchers }).eq('id', taskId);
        } catch (e) { console.warn('[Watch]', e.message); }
      }
    },
    isWatching(taskId) {
      const me = this.auth?.currentUser?.user_metadata?.full_name || '';
      const task = this.data.tasks.find(t => t.id === taskId);
      return (task?.watchers || []).includes(me);
    },

    // ── Global Search (Dragon 32) ──
    globalSearchOpen: false,
    globalSearchQuery: '',
    get globalSearchResults() {
      const q = (this.globalSearchQuery || '').toLowerCase().trim();
      if (!q || q.length < 2) return { tasks: [], mentorados: [], calls: [] };
      return {
        tasks: this.data.tasks.filter(t => t.titulo?.toLowerCase().includes(q)).slice(0, 10),
        mentorados: (this.data.mentees || []).filter(m => (m.nome || '').toLowerCase().includes(q)).slice(0, 5),
        calls: (this._supabaseCalls || []).filter(c => (c.titulo || c.assunto || '').toLowerCase().includes(q)).slice(0, 5),
      };
    },

    // ── Sprint Velocity (Dragon 37) ──
    get sprintVelocityData() {
      const sprints = (this.data.sprints || []).filter(s => s.status === 'encerrado' || s.status === 'ativo');
      return sprints.map(s => {
        const tasks = this.data.tasks.filter(t => t.sprint_id === s.id);
        const done = tasks.filter(t => t.status === 'concluida');
        return {
          name: s.nome || 'Sprint',
          committed: tasks.reduce((sum, t) => sum + (t.points || 1), 0),
          completed: done.reduce((sum, t) => sum + (t.points || 1), 0),
          taskCount: tasks.length,
          doneCount: done.length,
        };
      });
    },

    // ── Priority Matrix / Eisenhower (Dragon 38) ──
    get priorityMatrix() {
      const tasks = this.data.tasks.filter(t => t.status !== 'concluida' && t.status !== 'cancelada');
      const now = new Date();
      const soonCutoff = new Date(now.getTime() + 3 * 86400000);
      // Urgente = prazo em 3 dias OU prioridade 'urgente'
      const isUrgent = t => t.prioridade === 'urgente' || (t.data_fim && new Date(t.data_fim) <= soonCutoff);
      // Importante = prioridade alta/urgente OU tem mentorado vinculado
      const isImportant = t => t.prioridade === 'urgente' || t.prioridade === 'alta' || !!t.mentorado_id;
      return {
        urgentImportant: tasks.filter(t => isUrgent(t) && isImportant(t)),
        notUrgentImportant: tasks.filter(t => !isUrgent(t) && isImportant(t)),
        urgentNotImportant: tasks.filter(t => isUrgent(t) && !isImportant(t)),
        notUrgentNotImportant: tasks.filter(t => !isUrgent(t) && !isImportant(t)),
      };
    },

    // ── Subtask Progress (Dragon 40 — enhanced) ──
    subtaskProgressBar(task) {
      const p = this.subtaskProgress(task);
      if (!p.total) return null;
      const pct = Math.round(p.done / p.total * 100);
      return { done: p.done, total: p.total, pct, color: pct === 100 ? '#22c55e' : pct > 50 ? '#3b82f6' : '#d97706' };
    },

    // ── Task Estimation vs Actual (Dragon 46) ──
    estimationAccuracy(task) {
      if (!task.time_estimate || !task.time_spent) return null;
      const ratio = task.time_spent / task.time_estimate;
      return {
        estimated: task.time_estimate,
        actual: task.time_spent,
        ratio,
        label: ratio <= 1 ? 'Dentro' : ratio <= 1.5 ? 'Acima' : 'Muito acima',
        color: ratio <= 1 ? '#22c55e' : ratio <= 1.5 ? '#d97706' : '#dc2626',
      };
    },

    // ── Keyboard Navigation in List (Dragon 30) ──
    _listFocusIdx: -1,
    listKeyNav(e) {
      const rows = this.tasksTree.filter(t => !t._isGroupHeader);
      if (!rows.length) return;
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        this._listFocusIdx = Math.min(this._listFocusIdx + 1, rows.length - 1);
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        this._listFocusIdx = Math.max(this._listFocusIdx - 1, 0);
      } else if (e.key === 'Enter' && this._listFocusIdx >= 0) {
        e.preventDefault();
        const t = rows[this._listFocusIdx];
        if (t) this.openTaskDetail(t._parentId || t.id);
      } else if (e.key === ' ' && this._listFocusIdx >= 0) {
        e.preventDefault();
        const t = rows[this._listFocusIdx];
        if (t) this.bulkToggle(t.id, e);
      }
      // Scroll focused row into view
      this.$nextTick(() => {
        const focused = document.querySelector(`.cu-list__row[data-focus-idx="${this._listFocusIdx}"]`);
        focused?.scrollIntoView({ block: 'nearest' });
      });
    },

    // ── Time Tracking (Dragon 20) ──
    timeTracker: { taskId: null, startTime: null, elapsed: 0, interval: null },
    startTimeTracker(taskId) {
      this.stopTimeTracker();
      this.timeTracker.taskId = taskId;
      this.timeTracker.startTime = Date.now();
      this.timeTracker.elapsed = 0;
      this.timeTracker.interval = setInterval(() => {
        this.timeTracker.elapsed = Math.floor((Date.now() - this.timeTracker.startTime) / 1000);
      }, 1000);
    },
    stopTimeTracker() {
      if (this.timeTracker.interval) clearInterval(this.timeTracker.interval);
      const elapsed = this.timeTracker.elapsed;
      const taskId = this.timeTracker.taskId;
      this.timeTracker = { taskId: null, startTime: null, elapsed: 0, interval: null };
      return { taskId, elapsed };
    },
    async saveTimeEntry(taskId, seconds) {
      if (!sb || !taskId || !seconds) return;
      const hours = Math.round(seconds / 36) / 100; // 2 decimal places
      try {
        const task = this.data.tasks.find(t => t.id === taskId);
        const current = task?.time_spent || 0;
        await sb.from('god_tasks').update({ time_spent: current + hours }).eq('id', taskId);
        if (task) task.time_spent = current + hours;
        this.toast(`${this.formatDuration(seconds)} registrado`, 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },
    formatDuration(seconds) {
      const h = Math.floor(seconds / 3600);
      const m = Math.floor((seconds % 3600) / 60);
      const s = seconds % 60;
      if (h > 0) return `${h}h ${m}m`;
      if (m > 0) return `${m}m ${s}s`;
      return `${s}s`;
    },

    // ── Task Breadcrumb (Dragon 29) ──
    taskBreadcrumb(taskId) {
      const task = this.data.tasks.find(t => t.id === taskId);
      if (!task) return [];
      const parts = [];
      // spaces lives at root (this.spaces), each space contains its own .lists array
      const spaces = this.spaces || [];
      let space = null, list = null;
      for (const sp of spaces) {
        const li = (sp.lists || []).find(l => l.id === task.list_id);
        if (li) { space = sp; list = li; break; }
      }
      if (!space && task.space_id) space = spaces.find(s => s.id === task.space_id);
      if (space) parts.push({ label: space.name || space.nome, type: 'space' });
      if (list) parts.push({ label: list.name || list.nome, type: 'list' });
      parts.push({ label: task.titulo, type: 'task' });
      return parts;
    },

    // ── Duplicate Task (Dragon 28) ──
    async duplicateTask(taskId) {
      const orig = this.data.tasks.find(t => t.id === taskId);
      if (!orig || !sb) return;
      // Whitelist only persisted DB columns (avoid view-derived fields like subtasks/comments/_source)
      const VALID_COLS = ['titulo','descricao','status','prioridade','responsavel','acompanhante','mentorado_id','mentorado_nome','data_inicio','data_fim','space_id','list_id','parent_task_id','tags','fonte','doc_link','recorrencia','dia_recorrencia','recorrencia_ativa','tipo','points','time_estimate','sprint_id','recurrence_rule'];
      const copy = {};
      for (const k of VALID_COLS) { if (orig[k] !== undefined && orig[k] !== null) copy[k] = orig[k]; }
      copy.titulo = (orig.titulo || 'Tarefa') + ' (copia)';
      copy.status = 'pendente';
      try {
        const { data, error } = await sb.from('god_tasks').insert(copy).select().single();
        if (error) throw error;
        this.data.tasks.push(data);
        this.toast('Tarefa duplicada', 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },

    // ── Favorites / Pinned (Dragon 24) ──
    favorites: JSON.parse(localStorage.getItem('spalla_favorites') || '[]'),
    toggleFavorite(taskId) {
      const idx = this.favorites.indexOf(taskId);
      if (idx >= 0) this.favorites.splice(idx, 1);
      else this.favorites.push(taskId);
      localStorage.setItem('spalla_favorites', JSON.stringify(this.favorites));
    },
    isFavorite(taskId) { return this.favorites.includes(taskId); },
    get favoriteTasks() { return this.data.tasks.filter(t => this.favorites.includes(t.id)); },

    // ── Sprint Management ──
    get activeSprintId() {
      return this.ui.taskSprintFilter !== 'all' ? this.ui.taskSprintFilter : null;
    },
    get activeSprintData() {
      const id = this.activeSprintId;
      if (!id) return null;
      return (this.data.sprints || []).find(s => s.id === id) || null;
    },
    get sprintTasks() {
      const id = this.activeSprintId;
      if (!id) return [];
      return this.data.tasks.filter(t => t.sprint_id === id);
    },
    get sprintStats() {
      const tasks = this.sprintTasks;
      const total = tasks.length;
      const done = tasks.filter(t => t.status === 'concluida').length;
      const points = tasks.reduce((s, t) => s + (t.points || 0), 0);
      const donePoints = tasks.filter(t => t.status === 'concluida').reduce((s, t) => s + (t.points || 0), 0);
      return { total, done, pending: total - done, points, donePoints, remainingPoints: points - donePoints, pct: total ? Math.round(done / total * 100) : 0 };
    },
    sprintBurndownData() {
      // Returns { labels: [dates], ideal: [points], actual: [points] }
      const sp = this.activeSprintData;
      if (!sp?.inicio || !sp?.fim) return null;
      const start = new Date(sp.inicio);
      const end = new Date(sp.fim);
      const totalDays = Math.ceil((end - start) / 86400000) + 1;
      const totalPoints = this.sprintStats.points || this.sprintStats.total;
      const labels = [];
      const ideal = [];
      for (let i = 0; i < totalDays; i++) {
        const d = new Date(start); d.setDate(d.getDate() + i);
        labels.push(d.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' }));
        ideal.push(Math.round(totalPoints * (1 - i / (totalDays - 1))));
      }
      // Actual: remaining per day from snapshots (or estimate from current data)
      const remaining = this.sprintStats.remainingPoints || (this.sprintStats.total - this.sprintStats.done);
      const today = new Date();
      const daysPassed = Math.min(totalDays, Math.ceil((today - start) / 86400000) + 1);
      const actual = [];
      for (let i = 0; i < daysPassed; i++) {
        // Linear interpolation from totalPoints to remaining (simplified — real data comes from snapshots)
        actual.push(Math.round(totalPoints - (totalPoints - remaining) * (i / (daysPassed - 1 || 1))));
      }
      return { labels, ideal, actual };
    },
    async sprintCreate() {
      const name = prompt('Nome do sprint (ex: Sprint 4)');
      if (!name) return;
      const inicio = prompt('Data inicio (YYYY-MM-DD)');
      if (!inicio) return;
      const fim = prompt('Data fim (YYYY-MM-DD)');
      if (!fim) return;
      const spaceId = this.ui.taskSpaceFilter !== 'all' ? this.ui.taskSpaceFilter : 'space_sistema';
      try {
        const { data, error } = await sb.from('god_lists').insert({
          id: 'sprint_' + Date.now(),
          nome: name,
          space_id: spaceId,
          tipo: 'sprint',
          sprint_inicio: inicio,
          sprint_fim: fim,
          sprint_status: 'planejado',
          ordem: (this.data.sprints?.length || 0) + 1,
        }).select().single();
        if (error) throw error;
        this.toast('Sprint criado', 'success');
        await this.loadSpacesAndStatuses();
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },
    async sprintClose(sprintId) {
      if (!confirm('Encerrar este sprint? Tarefas incompletas podem ser movidas pro proximo.')) return;
      try {
        const { error } = await sb.from('god_lists').update({ sprint_status: 'encerrado' }).eq('id', sprintId);
        if (error) throw error;
        // Take final snapshot
        await sb.rpc('fn_sprint_snapshot', { p_sprint_id: sprintId });
        this.toast('Sprint encerrado', 'success');
        await this.loadSpacesAndStatuses();
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },
    async sprintActivate(sprintId) {
      try {
        const { error } = await sb.from('god_lists').update({ sprint_status: 'ativo' }).eq('id', sprintId);
        if (error) throw error;
        this.toast('Sprint ativado', 'success');
        await this.loadSpacesAndStatuses();
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },
    async sprintCarryOver(fromSprintId, toSprintId) {
      const incomplete = this.data.tasks.filter(t => t.sprint_id === fromSprintId && t.status !== 'concluida');
      if (!incomplete.length) { this.toast('Nenhuma tarefa incompleta', 'info'); return; }
      if (!confirm(`Mover ${incomplete.length} tarefa(s) incompleta(s) pro sprint selecionado?`)) return;
      const ids = incomplete.map(t => t.id);
      try {
        const { error } = await sb.from('god_tasks').update({ sprint_id: toSprintId }).in('id', ids);
        if (error) throw error;
        this.data.tasks = this.data.tasks.map(t => ids.includes(t.id) ? { ...t, sprint_id: toSprintId } : t);
        this.toast(`${ids.length} tarefa(s) movida(s)`, 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },
    async assignToSprint(taskId, sprintId) {
      await this.updateTaskField(taskId, 'sprint_id', sprintId || null);
    },
    async updateTaskPoints(taskId, points) {
      const val = parseInt(points) || null;
      await this.updateTaskField(taskId, 'points', val);
    },

    // ── Dragon 4: Activity Feed (track all changes) ──
    async logActivity(taskId, action, field = null, oldValue = null, newValue = null) {
      if (!sb || !taskId) return;
      try {
        await sb.from('god_task_activity').insert({
          task_id: taskId,
          action,
          field_name: field,
          old_value: oldValue !== null ? JSON.stringify(oldValue) : null,
          new_value: newValue !== null ? JSON.stringify(newValue) : null,
          user_id: this.auth.currentUser?.email || 'system',
        });
      } catch (e) { /* silent */ }
    },

    // ── Dragon 5: Export CSV ──
    exportTasksCSV() {
      const tasks = this.data.tasks;
      const headers = ['titulo','status','prioridade','responsavel','mentorado_nome','data_inicio','data_fim','space_id','list_id','tipo','fonte','created_at'];
      const rows = tasks.map(t => headers.map(h => {
        const v = t[h] ?? '';
        return '"' + String(v).replace(/"/g, '""') + '"';
      }).join(','));
      const csv = headers.join(',') + '\n' + rows.join('\n');
      const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url; a.download = 'tarefas_' + new Date().toISOString().slice(0,10) + '.csv';
      a.click(); URL.revokeObjectURL(url);
      this.toast('CSV exportado: ' + tasks.length + ' tarefas', 'success');
    },

    async importTasksCSV(file) {
      if (!file || !sb) return;
      const text = await file.text();
      const lines = text.split('\n').filter(l => l.trim());
      if (lines.length < 2) { this.toast('CSV vazio', 'warn'); return; }
      const headers = lines[0].split(',').map(h => h.replace(/"/g, '').trim());
      let imported = 0;
      for (let i = 1; i < lines.length; i++) {
        const vals = lines[i].match(/("([^"]|"")*"|[^,]*)/g) || [];
        const row = {};
        headers.forEach((h, j) => { row[h] = (vals[j] || '').replace(/^"|"$/g, '').replace(/""/g, '"').trim(); });
        if (!row.titulo) continue;
        try {
          await sb.from('god_tasks').insert({
            titulo: row.titulo,
            status: row.status || 'pendente',
            prioridade: row.prioridade || 'normal',
            responsavel: row.responsavel || null,
            mentorado_nome: row.mentorado_nome || null,
            data_inicio: row.data_inicio || null,
            data_fim: row.data_fim || null,
            space_id: row.space_id || null,
            list_id: row.list_id || null,
            tipo: row.tipo || 'geral',
            fonte: 'csv_import',
          });
          imported++;
        } catch (e) { /* skip bad rows */ }
      }
      await this.loadTasks();
      this.toast(`Importadas: ${imported} de ${lines.length - 1} linhas`, 'success');
    },

    // ── Dragon 6: Form View (public intake) ──
    get formViewFields() {
      return [
        { key: 'titulo', label: 'Titulo da tarefa', type: 'text', required: true },
        { key: 'descricao', label: 'Descricao', type: 'textarea', required: false },
        { key: 'prioridade', label: 'Prioridade', type: 'select', options: ['normal','alta','urgente','baixa'], required: false },
        { key: 'responsavel', label: 'Responsavel', type: 'select', options: (this.data.members || []).map(m => m.nome_curto || m.name), required: false },
        { key: 'data_fim', label: 'Data de vencimento', type: 'date', required: false },
        { key: 'mentorado_nome', label: 'Mentorado', type: 'text', required: false },
      ];
    },

    async submitFormView(formData) {
      if (!formData?.titulo?.trim() || !sb) { this.toast('Titulo obrigatorio', 'warn'); return; }
      try {
        const { error } = await sb.from('god_tasks').insert({
          ...formData,
          status: 'pendente',
          fonte: 'form',
          space_id: this.ui.taskSpaceFilter !== 'all' ? this.ui.taskSpaceFilter : null,
          created_by: 'form_submission',
        });
        if (error) throw error;
        await this.loadTasks();
        this.toast('Tarefa criada via formulario', 'success');
        return true;
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); return false; }
    },

    // ── Dragon 7: Workload View ──
    get workloadData() {
      const members = this.data.members || [];
      const tasks = this.data.tasks.filter(t => t.status !== 'concluida');
      return members.map(m => {
        const name = m.nome_curto || m.name;
        const nameLower = (name || '').toLowerCase();
        const idLower = (m.id || '').toLowerCase();
        const myTasks = tasks.filter(t => {
          const r = (t.responsavel || '').toLowerCase();
          return r === nameLower || r === idLower || r.includes(nameLower);
        });
        const points = myTasks.reduce((s, t) => s + (t.points || 0), 0);
        const estimate = myTasks.reduce((s, t) => s + (t.time_estimate || 0), 0);
        const overdue = myTasks.filter(t => (t.data_fim || t.prazo) && new Date(t.data_fim || t.prazo) < new Date()).length;
        const byPrio = { urgente: 0, alta: 0, normal: 0, baixa: 0 };
        myTasks.forEach(t => { byPrio[t.prioridade || 'normal']++; });
        return { name, color: m.cor || '#6366f1', count: myTasks.length, points, estimate, overdue, byPrio };
      }).sort((a, b) => b.count - a.count);
    },

    // ── Task Templates ──
    async loadTemplates() {
      if (!sb) return;
      try {
        const { data } = await sb.from('god_task_templates').select('*').order('usage_count', { ascending: false });
        if (data) this.data.templates = data;
      } catch (e) { console.warn('[Spalla] loadTemplates:', e.message); }
    },

    async createFromTemplate(templateId) {
      const tmpl = (this.data.templates || []).find(t => t.id === templateId);
      if (!tmpl) return;
      const td = tmpl.template_data || {};
      const titulo = (td.titulo_prefix || '') + prompt('Nome da tarefa:');
      if (!titulo?.trim()) return;
      const task = {
        titulo,
        descricao: td.descricao || '',
        prioridade: td.prioridade || 'normal',
        tipo: td.tipo || 'geral',
        space_id: td.space_id || this.ui.taskSpaceFilter !== 'all' ? this.ui.taskSpaceFilter : null,
        list_id: td.list_id || this.ui.taskListFilter !== 'all' ? this.ui.taskListFilter : null,
        status: 'pendente',
        created_by: this.auth.currentUser?.email || 'dashboard',
      };
      try {
        const { data, error } = await sb.from('god_tasks').insert(task).select().single();
        if (error) throw error;
        // Add subtasks from template
        if (td.subtasks?.length && data?.id) {
          const subs = td.subtasks.map((s, i) => ({ task_id: data.id, texto: s.text || s, done: false, sort_order: i }));
          await sb.from('god_task_subtasks').insert(subs);
        }
        // Increment usage count
        await sb.from('god_task_templates').update({ usage_count: (tmpl.usage_count || 0) + 1 }).eq('id', templateId);
        await this.loadTasks();
        this.toast('Tarefa criada do template: ' + tmpl.name, 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },

    // ── Quick Add (inline task creation in list view) ──
    async quickAddTask(titulo) {
      if (!titulo?.trim() || !sb) return;
      const task = {
        titulo: titulo.trim(),
        status: 'pendente',
        prioridade: 'normal',
        space_id: this.ui.taskSpaceFilter !== 'all' ? this.ui.taskSpaceFilter : null,
        list_id: this.ui.taskListFilter !== 'all' ? this.ui.taskListFilter : null,
        sprint_id: this.ui.taskSprintFilter !== 'all' ? this.ui.taskSprintFilter : null,
        created_by: this.auth.currentUser?.email || 'dashboard',
      };
      try {
        const { data, error } = await sb.from('god_tasks').insert(task).select().single();
        if (error) throw error;
        this.data.tasks.unshift({ ...data, subtasks: [], checklist: [], comments: [], tags: [] });
        this.toast('Tarefa criada', 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },

    // ── Saved Views ──
    async loadSavedViews() {
      if (!sb) return;
      try {
        const { data } = await sb.from('god_saved_views').select('*').order('is_pinned', { ascending: false }).order('name');
        if (data) this.data.savedViews = data;
      } catch (e) { console.warn('[Spalla] loadSavedViews:', e.message); }
    },

    async saveCurrentView(name) {
      if (!name?.trim() || !sb) return;
      const config = {
        groupBy: this.ui.taskGroupBy,
        spaceFilter: this.ui.taskSpaceFilter,
        listFilter: this.ui.taskListFilter,
        sprintFilter: this.ui.taskSprintFilter,
        visibleFieldIds: this.ui.visibleFieldIds,
      };
      try {
        const { error } = await sb.from('god_saved_views').insert({
          name, view_type: this.ui.taskView, config,
          space_id: this.ui.taskSpaceFilter !== 'all' ? this.ui.taskSpaceFilter : null,
        });
        if (error) throw error;
        await this.loadSavedViews();
        this.toast('View salva: ' + name, 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },

    applySavedView(view) {
      this.ui.taskView = view.view_type || 'list';
      const c = view.config || {};
      if (c.groupBy) this.ui.taskGroupBy = c.groupBy;
      if (c.spaceFilter) this.ui.taskSpaceFilter = c.spaceFilter;
      if (c.listFilter) this.ui.taskListFilter = c.listFilter;
      if (c.sprintFilter) this.ui.taskSprintFilter = c.sprintFilter;
      if (c.visibleFieldIds) this.ui.visibleFieldIds = c.visibleFieldIds;
    },

    async deleteSavedView(id) {
      if (!confirm('Excluir esta view?')) return;
      await sb.from('god_saved_views').delete().eq('id', id);
      this.data.savedViews = (this.data.savedViews || []).filter(v => v.id !== id);
    },

    // ── Realtime Subscriptions ──
    _subscribeRealtime() {
      if (!sb) return;
      try {
        // Tasks realtime
        sb.channel('god_tasks_changes')
          .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'god_tasks' }, (payload) => {
            const existing = this.data.tasks.find(t => t.id === payload.new.id);
            if (!existing) {
              this.data.tasks.unshift(payload.new);
              this.toast('Nova tarefa: ' + (payload.new.titulo || '').substring(0, 40), 'info');
            }
            // Refresh Meu Trabalho se estiver na página
            if (this.ui.page === 'meu_trabalho') this.loadMeuTrabalho();
          })
          .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'god_tasks' }, (payload) => {
            const idx = this.data.tasks.findIndex(t => t.id === payload.new.id);
            if (idx >= 0) {
              const existing = this.data.tasks[idx];
              this.data.tasks[idx] = { ...existing, ...payload.new };
            }
            if (this.ui.page === 'meu_trabalho') this.loadMeuTrabalho();
          })
          .on('postgres_changes', { event: 'DELETE', schema: 'public', table: 'god_tasks' }, (payload) => {
            this.data.tasks = this.data.tasks.filter(t => t.id !== payload.old.id);
            if (this.ui.page === 'meu_trabalho') this.loadMeuTrabalho();
          })
          .subscribe((status) => {
            if (status === 'SUBSCRIBED') console.log('[Spalla] Realtime: subscribed to god_tasks');
          });

        // Descarregos realtime (substitui polling)
        sb.channel('descarregos_changes')
          .on('postgres_changes', { event: '*', schema: 'public', table: 'descarregos' }, (payload) => {
            const menteeId = this.data.detail?.profile?.id;
            const row = payload.new || payload.old;
            if (menteeId && row?.mentorado_id == menteeId) {
              this.loadMenteeDescarregos(menteeId);
            }
          })
          .subscribe((status) => {
            if (status === 'SUBSCRIBED') console.log('[Spalla] Realtime: subscribed to descarregos');
          });

        // Mentorados realtime
        sb.channel('mentorados_changes')
          .on('postgres_changes', { event: 'UPDATE', schema: 'case', table: 'mentorados' }, (payload) => {
            const idx = (this.data.mentees || []).findIndex(m => m.id === payload.new.id);
            if (idx >= 0) {
              this.data.mentees[idx] = { ...this.data.mentees[idx], ...payload.new };
            }
            // Refresh detail if open
            if (this.data.detail?.profile?.id === payload.new.id) {
              this.data.detail.profile = { ...this.data.detail.profile, ...payload.new };
            }
          })
          .subscribe((status) => {
            if (status === 'SUBSCRIBED') console.log('[Spalla] Realtime: subscribed to mentorados');
          });

        // Comments realtime
        sb.channel('comments_changes')
          .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'god_task_comments' }, (payload) => {
            const taskId = payload.new?.task_id;
            const task = this.data.tasks.find(t => t.id === taskId);
            if (task) {
              if (!task.comments) task.comments = [];
              const exists = task.comments.find(c => c.id === payload.new.id);
              if (!exists) task.comments.push(payload.new);
            }
          })
          .subscribe((status) => {
            if (status === 'SUBSCRIBED') console.log('[Spalla] Realtime: subscribed to comments');
          });

        // Dragon 54: Entity events subscription (notifications)
        sb.channel('entity_events_changes')
          .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'entity_events' }, (payload) => {
            const evt = payload.new;
            if (!evt) return;
            const me = (this.auth.currentUser?.full_name || '').toLowerCase().split(' ')[0];
            const assignee = (evt.payload?.responsavel || evt.payload?.assignee || '').toLowerCase();
            const titulo = evt.payload?.titulo || evt.aggregate_type || '';
            const eventType = evt.event_type || '';

            // Push to notifications array for the bell dropdown
            const shouldNotify =
              (assignee && assignee.includes(me)) ||
              eventType.includes('Transition') ||
              eventType.includes('transition');

            if (shouldNotify) {
              const notif = {
                id: evt.id || ('evt_' + Date.now()),
                type: eventType.includes('assigned') || eventType.includes('created') ? 'task_assigned' : 'transition',
                text: titulo.substring(0, 80) || eventType,
                detail: eventType,
                read: false,
                createdAt: evt.created_at || new Date().toISOString(),
              };
              this.notifications.unshift(notif);
              if (this.notifications.length > 20) this.notifications.pop();
              this.notificationsUnread = this.notifications.filter(n => !n.read).length;

              // Toast only for tasks assigned to me
              if (assignee && assignee.includes(me)) {
                this.toast('Nova tarefa: ' + titulo.substring(0, 50), 'info');
              }
            }
          })
          .subscribe((status) => {
            if (status === 'SUBSCRIBED') console.log('[Spalla] Realtime: subscribed to entity_events');
          });

      } catch (e) {
        console.warn('[Spalla] Realtime subscription failed:', e.message);
      }
    },

    // ── Inline Title Edit (list view) ──
    inlineEditTitle(taskId, newTitle) {
      const title = newTitle?.trim();
      if (!title) return;
      const task = this.data.tasks.find(t => t.id === taskId);
      if (task && title !== task.titulo) {
        task.titulo = title;
        task.updated_at = new Date().toISOString();
        if (sb) sb.from('god_tasks').update({ titulo: title }).eq('id', taskId);
      }
    },

    // ── Keyboard Shortcuts ──
    _initKeyboardShortcuts() {
      // Global Cmd+K / Ctrl+K — Command Palette (works on ALL pages)
      document.addEventListener('keydown', (e) => {
        if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
          e.preventDefault();
          this.cmdPalette = !this.cmdPalette;
          this.cmdQuery = '';
          this.cmdSelectedIdx = 0;
          if (this.cmdPalette) this.$nextTick(() => document.getElementById('cmd-palette-input')?.focus());
        }
        // Dragon 52: Cmd+Z undo, Cmd+Shift+Z redo (global, tasks page)
        if ((e.metaKey || e.ctrlKey) && e.key === 'z' && !e.target.isContentEditable && e.target.tagName !== 'INPUT' && e.target.tagName !== 'TEXTAREA') {
          if (this.ui.page === 'tasks' || this.ui.page === 'meu_trabalho') {
            e.preventDefault();
            if (e.shiftKey) this.redo();
            else this.undo();
          }
        }
      });
      document.addEventListener('keydown', (e) => {
        // Don't trigger in input/textarea/contenteditable (except cmd palette)
        if (e.target.id === 'cmd-palette-input') return;
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA' || e.target.isContentEditable) return;
        if (this.ui.page !== 'tasks') return;

        if (e.key === 'n' && !e.ctrlKey && !e.metaKey) {
          e.preventDefault();
          this.openTaskModal();
        } else if (e.key === '/' && !e.ctrlKey && !e.metaKey) {
          e.preventDefault();
          document.querySelector('.tasks-main input[type="text"][placeholder*="Buscar"]')?.focus();
        } else if (e.key === 'Escape') {
          if (this.ui.taskDetailDrawer) this.closeTaskDetail();
          else if (this.ui.fieldsModalOpen) this.ui.fieldsModalOpen = false;
          else if (this.ui.automationsOpen) this.ui.automationsOpen = false;
          else if (this.ui.dashboardOpen) this.ui.dashboardOpen = false;
        } else if (e.key === '1' && e.altKey) {
          this.ui.taskView = 'list';
        } else if (e.key === '2' && e.altKey) {
          this.ui.taskView = 'calendar';
        } else if (e.key === '3' && e.altKey) {
          this.ui.taskView = 'board';
        } else if (e.key === '4' && e.altKey) {
          this.ui.taskView = 'gantt';
        }

        // Dragon 55: Gantt keyboard shortcuts
        if (this.ui.taskView === 'gantt') {
          const tasks = this.ganttTasks;
          if (!tasks.length) return;
          const curIdx = tasks.findIndex(t => t.id === this.ui.ganttFocusedTaskId);

          if (e.key === 'ArrowDown' || e.key === 'j') {
            e.preventDefault();
            const nextIdx = curIdx < tasks.length - 1 ? curIdx + 1 : 0;
            this.ui.ganttFocusedTaskId = tasks[nextIdx].id;
            document.querySelector(`[data-gantt-task="${tasks[nextIdx].id}"]`)?.scrollIntoView({ block: 'nearest' });
          } else if (e.key === 'ArrowUp' || e.key === 'k') {
            e.preventDefault();
            const prevIdx = curIdx > 0 ? curIdx - 1 : tasks.length - 1;
            this.ui.ganttFocusedTaskId = tasks[prevIdx].id;
            document.querySelector(`[data-gantt-task="${tasks[prevIdx].id}"]`)?.scrollIntoView({ block: 'nearest' });
          } else if (e.key === 'Enter' && this.ui.ganttFocusedTaskId) {
            e.preventDefault();
            this.openTaskDetail(this.ui.ganttFocusedTaskId);
          } else if (e.key === 'ArrowRight' && this.ui.ganttFocusedTaskId) {
            e.preventDefault();
            const t = tasks.find(x => x.id === this.ui.ganttFocusedTaskId);
            if (t?.data_fim) {
              const d = new Date(t.data_fim + 'T12:00:00');
              d.setDate(d.getDate() + 1);
              this.updateTaskField(t.id, 'data_fim', d.toISOString().slice(0, 10));
            }
          } else if (e.key === 'ArrowLeft' && this.ui.ganttFocusedTaskId) {
            e.preventDefault();
            const t = tasks.find(x => x.id === this.ui.ganttFocusedTaskId);
            if (t?.data_fim) {
              const d = new Date(t.data_fim + 'T12:00:00');
              d.setDate(d.getDate() - 1);
              this.updateTaskField(t.id, 'data_fim', d.toISOString().slice(0, 10));
            }
          } else if (e.key === ' ' && this.ui.ganttFocusedTaskId) {
            e.preventDefault();
            const t = tasks.find(x => x.id === this.ui.ganttFocusedTaskId);
            if (t) {
              const next = t.status === 'pendente' ? 'em_andamento' : t.status === 'em_andamento' ? 'concluida' : 'pendente';
              this.updateTaskStatus(t.id, next);
            }
          }
        }
      });
    },

    // ── SortableJS — Drag & Drop Reorder (Dragon 8) ──
    _sortableInstances: [],
    _initSortable() {
      // Destroy previous instances
      this._sortableInstances.forEach(s => s.destroy());
      this._sortableInstances = [];
      if (typeof Sortable === 'undefined') return;

      const self = this;

      // Board columns: drag cards between status columns
      this.$nextTick(() => {
        document.querySelectorAll('.cu-board__cards').forEach(el => {
          const inst = Sortable.create(el, {
            group: 'board-tasks',
            animation: 180,
            ghostClass: 'cu-sortable-ghost',
            chosenClass: 'cu-sortable-chosen',
            dragClass: 'cu-sortable-drag',
            handle: '.cu-card',
            onEnd(evt) {
              const taskId = evt.item?.getAttribute('data-task-id');
              const toCol = evt.to?.closest('.cu-board__col');
              const colLabel = toCol?.querySelector('.cu-board__col-label')?.textContent?.trim();
              if (taskId && colLabel) {
                // Find status key from label
                const col = self.boardColumns.find(c => c.label === colLabel);
                if (col) self.moveTask(taskId, col.key);
              }
            }
          });
          self._sortableInstances.push(inst);
        });

        // List view rows: reorder tasks within groups
        document.querySelectorAll('.cu-list__body').forEach(el => {
          const inst = Sortable.create(el, {
            animation: 180,
            ghostClass: 'cu-sortable-ghost',
            chosenClass: 'cu-sortable-chosen',
            handle: '.cu-list__row',
            onEnd(evt) {
              // Reorder in local data array
              const items = Array.from(evt.from.children);
              const taskIds = items.map(row => row.getAttribute('data-task-id')).filter(Boolean);
              if (taskIds.length > 0) {
                // Update sort_order in local state
                taskIds.forEach((id, idx) => {
                  const task = self.data.tasks.find(t => t.id === id);
                  if (task) task.sort_order = idx;
                });
              }
            }
          });
          self._sortableInstances.push(inst);
        });
      });
    },

    // ── Automations Engine ──
    async loadAutomations() {
      if (!sb) return;
      try {
        const { data, error } = await sb.from('god_automations').select('*').order('created_at', { ascending: false });
        if (!error && data) this.data.automations = data;
      } catch (e) { console.warn('[Spalla] loadAutomations:', e.message); }
    },

    async saveAutomation(auto) {
      if (!sb) return;
      try {
        if (auto.id) {
          const { error } = await sb.from('god_automations').update(auto).eq('id', auto.id);
          if (error) throw error;
        } else {
          const { data, error } = await sb.from('god_automations').insert(auto).select().single();
          if (error) throw error;
          auto.id = data.id;
        }
        await this.loadAutomations();
        this.toast('Automacao salva', 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },

    async toggleAutomation(id) {
      const auto = (this.data.automations || []).find(a => a.id === id);
      if (!auto) return;
      auto.is_active = !auto.is_active;
      await sb.from('god_automations').update({ is_active: auto.is_active }).eq('id', id);
    },

    async deleteAutomation(id) {
      if (!confirm('Excluir esta automacao?')) return;
      await sb.from('god_automations').delete().eq('id', id);
      this.data.automations = (this.data.automations || []).filter(a => a.id !== id);
      this.toast('Automacao excluida', 'success');
    },

    // Evaluate automations on task change
    async evaluateAutomations(taskId, triggerType, triggerData = {}) {
      const rules = (this.data.automations || []).filter(a => a.is_active && a.trigger_type === triggerType);
      const task = this.data.tasks.find(t => t.id === taskId);
      if (!task || !rules.length) return;

      for (const rule of rules) {
        // Check condition
        const cond = rule.condition_config || {};
        if (cond.space_id && task.space_id !== cond.space_id) continue;
        if (cond.priority && task.prioridade !== cond.priority) continue;
        if (cond.list_id && task.list_id !== cond.list_id) continue;

        // Check trigger specifics
        const trig = rule.trigger_config || {};
        if (triggerType === 'status_changed' && trig.to && triggerData.newValue !== trig.to) continue;
        if (triggerType === 'status_changed' && trig.from && triggerData.oldValue !== trig.from) continue;

        // Execute action
        const act = rule.action_config || {};
        try {
          if (rule.action_type === 'change_status') await this.updateTaskStatus(taskId, act.status);
          else if (rule.action_type === 'change_assignee') await this.updateTaskField(taskId, 'responsavel', act.assignee);
          else if (rule.action_type === 'change_priority') await this.updateTaskField(taskId, 'prioridade', act.priority);
          else if (rule.action_type === 'send_notification') this.toast('Auto: ' + (act.message || rule.name), 'info');

          // Log execution
          await sb.from('god_automation_log').insert({
            automation_id: rule.id, task_id: taskId,
            trigger_data: triggerData, action_result: act, success: true,
          });
          await sb.from('god_automations').update({
            execution_count: (rule.execution_count || 0) + 1,
            last_executed_at: new Date().toISOString(),
          }).eq('id', rule.id);
        } catch (e) {
          await sb.from('god_automation_log').insert({
            automation_id: rule.id, task_id: taskId,
            trigger_data: triggerData, success: false, error_message: e.message,
          });
        }
      }
    },

    // ── Dashboard Stats ──
    get dashboardStats() {
      const tasks = this.data.tasks;
      const now = new Date();
      const weekAgo = new Date(now - 7 * 86400000);
      const recentDone = tasks.filter(t => t.status === 'concluida' && t.updated_at && new Date(t.updated_at) > weekAgo).length;
      const byAssignee = {};
      tasks.filter(t => t.status !== 'concluida').forEach(t => {
        const key = t.responsavel || 'Sem responsavel';
        byAssignee[key] = (byAssignee[key] || 0) + 1;
      });
      const byPriority = { urgente: 0, alta: 0, normal: 0, baixa: 0 };
      tasks.filter(t => t.status !== 'concluida').forEach(t => { byPriority[t.prioridade || 'normal']++; });
      const overdue = tasks.filter(t => t.status === 'pendente' && (t.data_fim || t.prazo) && new Date(t.data_fim || t.prazo) < now).length;

      return {
        total: tasks.length,
        pending: tasks.filter(t => t.status === 'pendente').length,
        inProgress: tasks.filter(t => t.status === 'em_andamento').length,
        done: tasks.filter(t => t.status === 'concluida').length,
        overdue,
        recentDone,
        byAssignee: Object.entries(byAssignee).sort((a, b) => b[1] - a[1]),
        byPriority,
      };
    },

    // ── Dashboard Charts Data ──
    _dashCharts: {},

    dashStatusData() {
      const t = this.data.tasks;
      return {
        labels: ['Pendentes', 'Em progresso', 'Concluídas', 'Atrasadas'],
        data: [
          t.filter(x => x.status === 'pendente').length,
          t.filter(x => x.status === 'em_andamento').length,
          t.filter(x => x.status === 'concluida').length,
          t.filter(x => x.status !== 'concluida' && (x.data_fim || x.prazo) && new Date(x.data_fim || x.prazo) < new Date()).length,
        ],
        colors: ['#94a3b8', '#3b82f6', '#22c55e', '#ef4444'],
      };
    },

    dashVelocityData() {
      const sprints = (this.data.sprints || []).slice().sort((a, b) => (a.inicio || '').localeCompare(b.inicio || ''));
      if (!sprints.length) return null;
      const tasks = this.data.tasks;
      return {
        labels: sprints.map(s => s.nome || 'Sprint'),
        committed: sprints.map(s => tasks.filter(t => t.sprint_id === s.id).length),
        completed: sprints.map(s => tasks.filter(t => t.sprint_id === s.id && t.status === 'concluida').length),
      };
    },

    dashBurndownData() {
      const sprint = this.ccSelectedSprint?.() || this.ccSelectedSprint;
      if (!sprint || !sprint.inicio || !sprint.fim) return null;
      const tasks = this.data.tasks.filter(t => t.sprint_id === sprint.id);
      const total = tasks.length;
      if (!total) return null;
      const start = new Date(sprint.inicio);
      const end = new Date(sprint.fim);
      const days = Math.ceil((end - start) / 86400000) + 1;
      const labels = [];
      const ideal = [];
      const actual = [];
      for (let i = 0; i < days; i++) {
        const d = new Date(start);
        d.setDate(d.getDate() + i);
        labels.push(d.toLocaleDateString('pt-BR', { day: 'numeric', month: 'short' }));
        ideal.push(Math.round(total * (1 - i / (days - 1))));
        const doneByDay = tasks.filter(t => t.status === 'concluida' && t.updated_at && new Date(t.updated_at) <= d).length;
        actual.push(d <= new Date() ? total - doneByDay : null);
      }
      return { labels, ideal, actual, total };
    },

    renderDashCharts() {
      if (typeof Chart === 'undefined') return;
      this.$nextTick(() => {
        // Status doughnut
        const statusEl = document.getElementById('dashChartStatus');
        if (statusEl) {
          if (this._dashCharts.status) this._dashCharts.status.destroy();
          const sd = this.dashStatusData();
          this._dashCharts.status = new Chart(statusEl.getContext('2d'), {
            type: 'doughnut',
            data: { labels: sd.labels, datasets: [{ data: sd.data, backgroundColor: sd.colors, borderWidth: 0 }] },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: { font: { size: 11 }, padding: 10 } } }, cutout: '65%' },
          });
        }
        // Velocity bar
        const vd = this.dashVelocityData();
        const velEl = document.getElementById('dashChartVelocity');
        if (velEl && vd) {
          if (this._dashCharts.velocity) this._dashCharts.velocity.destroy();
          this._dashCharts.velocity = new Chart(velEl.getContext('2d'), {
            type: 'bar',
            data: {
              labels: vd.labels,
              datasets: [
                { label: 'Comprometidas', data: vd.committed, backgroundColor: '#c7d2fe', borderRadius: 4 },
                { label: 'Concluídas', data: vd.completed, backgroundColor: '#6366f1', borderRadius: 4 },
              ],
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: { font: { size: 11 } } } }, scales: { y: { beginAtZero: true, ticks: { font: { size: 10 } } }, x: { ticks: { font: { size: 10 } } } } },
          });
        }
        // Burndown line
        const bd = this.dashBurndownData();
        const burnEl = document.getElementById('dashChartBurndown');
        if (burnEl && bd) {
          if (this._dashCharts.burndown) this._dashCharts.burndown.destroy();
          this._dashCharts.burndown = new Chart(burnEl.getContext('2d'), {
            type: 'line',
            data: {
              labels: bd.labels,
              datasets: [
                { label: 'Ideal', data: bd.ideal, borderColor: '#d1d5db', borderDash: [5, 3], borderWidth: 2, pointRadius: 0, fill: false },
                { label: 'Real', data: bd.actual, borderColor: '#6366f1', borderWidth: 2, pointRadius: 3, pointBackgroundColor: '#6366f1', fill: false, spanGaps: true },
              ],
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: { font: { size: 11 } } } }, scales: { y: { beginAtZero: true, title: { display: true, text: 'Tasks restantes', font: { size: 10 } }, ticks: { font: { size: 10 } } }, x: { ticks: { font: { size: 10 } } } } },
          });
        }
      });
    },

    // ── Calendar View helpers ──
    calMonthLabel() {
      const d = new Date(this.ui.calYear, this.ui.calMonth, 1);
      return d.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' }).replace(/^\w/, c => c.toUpperCase());
    },
    calNavMonth(delta) {
      let m = this.ui.calMonth + delta;
      let y = this.ui.calYear;
      if (m < 0) { m = 11; y--; } else if (m > 11) { m = 0; y++; }
      this.ui.calMonth = m;
      this.ui.calYear = y;
    },
    calCells() {
      const y = this.ui.calYear, m = this.ui.calMonth;
      const first = new Date(y, m, 1);
      const startDay = first.getDay(); // 0=Sun
      const daysInMonth = new Date(y, m + 1, 0).getDate();
      const today = new Date(); today.setHours(0,0,0,0);
      const cells = [];
      // Previous month padding
      const prevDays = new Date(y, m, 0).getDate();
      for (let i = startDay - 1; i >= 0; i--) {
        const d = prevDays - i;
        const dt = `${y}-${String(m).padStart(2,'0')}-${String(d).padStart(2,'0')}`;
        cells.push({ key: 'p' + d, day: d, date: new Date(y, m - 1, d).toISOString().slice(0,10), inMonth: false, isToday: false });
      }
      // Current month
      for (let d = 1; d <= daysInMonth; d++) {
        const dt = new Date(y, m, d);
        const iso = dt.toISOString().slice(0, 10);
        cells.push({ key: 'c' + d, day: d, date: iso, inMonth: true, isToday: dt.getTime() === today.getTime() });
      }
      // Next month padding (fill to 42 cells = 6 rows)
      const remaining = 42 - cells.length;
      for (let d = 1; d <= remaining; d++) {
        cells.push({ key: 'n' + d, day: d, date: new Date(y, m + 1, d).toISOString().slice(0,10), inMonth: false, isToday: false });
      }
      return cells;
    },
    calAllTasksForDate(dateStr) {
      return this.data.tasks.filter(t => {
        const due = t.data_fim || t.prazo;
        if (!due) return false;
        return due.slice(0, 10) === dateStr;
      });
    },
    calTasksForDate(dateStr) {
      return this.calAllTasksForDate(dateStr).slice(0, 5);
    },
    async calDropTask(event, dateStr) {
      const taskId = event.dataTransfer?.getData('text/plain');
      if (!taskId) return;
      await this.updateTaskField(taskId, 'data_fim', dateStr);
    },

    get ganttTasks() {
      let tasks = this._filterTasks([...this.data.tasks].filter(t =>
        t.status !== 'arquivada' && t.status !== 'cancelada'
      ));
      return tasks.filter(t => t.data_inicio || t.data_fim || t.prazo).sort((a, b) => {
        const da = a.data_inicio || a.prazo || a.created_at || '';
        const db = b.data_inicio || b.prazo || b.created_at || '';
        return da.localeCompare(db);
      }).slice(0, 80);
    },

    ganttBarStyle(task) {
      const range = this.ui.taskGanttRange;
      const now = new Date();
      let rangeStart, totalDays;
      if (range === 'week') {
        rangeStart = new Date(now);
        rangeStart.setDate(now.getDate() - now.getDay());
        totalDays = 7;
      } else if (range === 'quarter') {
        rangeStart = new Date(now.getFullYear(), Math.floor(now.getMonth() / 3) * 3, 1);
        totalDays = 90;
      } else {
        rangeStart = new Date(now.getFullYear(), now.getMonth(), 1);
        totalDays = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate();
      }
      const start = task.data_inicio ? parseDateStr(task.data_inicio) : (task.created_at ? parseDateStr(task.created_at) : now);
      const end = task.data_fim || task.prazo ? parseDateStr(task.data_fim || task.prazo) : new Date(start.getTime() + 7 * 86400000);
      const startOffset = Math.max(0, (start - rangeStart) / 86400000);
      const duration = Math.max(1, (end - start) / 86400000);
      const left = (startOffset / totalDays) * 100;
      const width = Math.min((duration / totalDays) * 100, 100 - left);
      const prioColors = { urgente: '#ef4444', alta: '#f59e0b', normal: '#6366f1', baixa: '#94a3b8' };
      return `left:${Math.max(0, left)}%;width:${Math.max(2, width)}%;background:${prioColors[task.prioridade] || '#6366f1'}`;
    },

    ganttDayHeaders() {
      const range = this.ui.taskGanttRange;
      const now = new Date();
      let start, count;
      if (range === 'week') {
        start = new Date(now); start.setDate(now.getDate() - now.getDay()); count = 7;
      } else if (range === 'quarter') {
        start = new Date(now.getFullYear(), Math.floor(now.getMonth() / 3) * 3, 1); count = 90;
      } else {
        start = new Date(now.getFullYear(), now.getMonth(), 1);
        count = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate();
      }
      const headers = [];
      for (let i = 0; i < count; i++) {
        const d = new Date(start);
        d.setDate(start.getDate() + i);
        headers.push({ date: d, label: d.getDate(), isToday: d.toDateString() === now.toDateString(), isWeekend: d.getDay() === 0 || d.getDay() === 6 });
      }
      return headers;
    },

    // ORCH-01: Dependency lines for Gantt SVG overlay
    get ganttDependencyLines() {
      const tasks = this.ganttTasks;
      if (!tasks.length) return [];
      const range = this.ui.taskGanttRange;
      const now = new Date();
      let rangeStart, totalDays;
      if (range === 'week') {
        rangeStart = new Date(now); rangeStart.setDate(now.getDate() - now.getDay()); totalDays = 7;
      } else if (range === 'quarter') {
        rangeStart = new Date(now.getFullYear(), Math.floor(now.getMonth() / 3) * 3, 1); totalDays = 90;
      } else {
        rangeStart = new Date(now.getFullYear(), now.getMonth(), 1);
        totalDays = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate();
      }
      const lines = [];
      for (let i = 0; i < tasks.length; i++) {
        const t = tasks[i];
        const deps = t.depends_on || [];
        for (const depId of deps) {
          const j = tasks.findIndex(x => x.id === depId);
          if (j < 0) continue;
          const blocker = tasks[j];
          const blockerEnd = parseDateStr(blocker.data_fim || blocker.prazo || blocker.created_at || new Date().toISOString());
          const depStart = parseDateStr(t.data_inicio || t.created_at || new Date().toISOString());
          const fromXPct = Math.min(100, Math.max(0, ((blockerEnd - rangeStart) / (totalDays * 86400000)) * 100));
          const toXPct = Math.min(100, Math.max(0, ((depStart - rangeStart) / (totalDays * 86400000)) * 100));
          const fromY = j * 40 + 20;
          const toY = i * 40 + 20;
          const resolved = ['concluida', 'cancelada', 'arquivada'].includes(blocker.status);
          lines.push({ fromXPct, fromY, toXPct, toY, isBlocking: !resolved });
        }
      }
      return lines;
    },

    // Gantt drag-to-resize: start
    ganttDragStart(event, task, side) {
      const timelineEl = event.target.closest('.gantt-row__timeline');
      if (!timelineEl) return;
      const origStart = task.data_inicio || '';
      const origEnd = task.data_fim || task.prazo || '';
      this.ui._ganttDrag = { taskId: task.id, side, startX: event.clientX, origStart, origEnd };

      const barEl = event.target.closest('.gantt-bar');
      if (barEl) barEl.classList.add('gantt-bar--dragging');

      const range = this.ui.taskGanttRange;
      const now = new Date();
      let rangeStart, totalDays;
      if (range === 'week') {
        rangeStart = new Date(now); rangeStart.setDate(now.getDate() - now.getDay()); totalDays = 7;
      } else if (range === 'quarter') {
        rangeStart = new Date(now.getFullYear(), Math.floor(now.getMonth() / 3) * 3, 1); totalDays = 90;
      } else {
        rangeStart = new Date(now.getFullYear(), now.getMonth(), 1);
        totalDays = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate();
      }
      const pxPerDay = timelineEl.offsetWidth / totalDays;

      const onMove = (e) => {
        const clientX = e.touches ? e.touches[0].clientX : e.clientX;
        const drag = this.ui._ganttDrag;
        if (!drag) return;
        const deltaPx = clientX - drag.startX;
        const deltaDays = Math.round(deltaPx / pxPerDay);
        if (deltaDays === 0) return;
        const t = this.data.tasks.find(x => x.id === drag.taskId);
        if (!t) return;

        if (drag.side === 'left' && drag.origStart) {
          const d = parseDateStr(drag.origStart);
          if (d) { d.setDate(d.getDate() + deltaDays); t.data_inicio = d.toISOString().slice(0, 10); }
        } else if (drag.side === 'right') {
          const dateStr = drag.origEnd || drag.origStart;
          if (dateStr) {
            const d = parseDateStr(dateStr);
            if (d) { d.setDate(d.getDate() + deltaDays); t.data_fim = d.toISOString().slice(0, 10); }
          }
        }
      };

      const onEnd = async (e) => {
        document.removeEventListener('mousemove', onMove);
        document.removeEventListener('mouseup', onEnd);
        document.removeEventListener('touchmove', onMove);
        document.removeEventListener('touchend', onEnd);
        if (barEl) barEl.classList.remove('gantt-bar--dragging');

        const drag = this.ui._ganttDrag;
        this.ui._ganttDrag = null;
        if (!drag) return;
        const t = this.data.tasks.find(x => x.id === drag.taskId);
        if (!t) return;

        // Persist changes
        if (drag.side === 'left' && t.data_inicio !== drag.origStart) {
          await this.updateTaskField(drag.taskId, 'data_inicio', t.data_inicio);
        } else if (drag.side === 'right' && t.data_fim !== drag.origEnd) {
          await this.updateTaskField(drag.taskId, 'data_fim', t.data_fim);
        }
      };

      document.addEventListener('mousemove', onMove);
      document.addEventListener('mouseup', onEnd);
      document.addEventListener('touchmove', onMove, { passive: false });
      document.addEventListener('touchend', onEnd);
    },

    // Grouped tasks for list view
    get tasksGrouped() {
      const groupBy = this.ui.taskGroupBy;
      const tasks = this.filteredTasks;
      const groups = {};
      for (const t of tasks) {
        let key;
        if (groupBy === 'assignee') key = t.responsavel || 'Sem responsável';
        else if (groupBy === 'priority') key = t.prioridade || 'normal';
        else if (groupBy === 'list') {
          const list = this.spaces.flatMap(s => s.lists).find(l => l.id === t.list_id);
          key = list ? list.name : 'Sem lista';
        }
        else key = t.status || 'pendente';
        if (!groups[key]) groups[key] = [];
        groups[key].push(t);
      }
      return groups;
    },

    // Space/List helpers
    getSpaceName(spaceId) {
      return this.spaces.find(s => s.id === spaceId)?.name || '';
    },

    getListName(listId) {
      for (const s of this.spaces) {
        const l = s.lists.find(ll => ll.id === listId);
        if (l) return l.name;
      }
      return '';
    },

    getAllLists() {
      return this.spaces.flatMap(s => s.lists.map(l => ({ ...l, spaceName: s.name, spaceId: s.id })));
    },

    // ===================== REMINDERS =====================

    async loadReminders() {
      if (!this.auth.currentUser) {
        this.data.reminders = [];
        return;
      }
      try {
        const { data, error } = await this.supabase
          .from('god_reminders')
          .select('*')
          .eq('user_id', this.auth.currentUser.id)
          .order('data_lembrete', { ascending: true });
        if (error) {
          console.error('[Spalla] Error loading reminders:', error);
          this.data.reminders = [];
        } else {
          this.data.reminders = data || [];
        }
      } catch (e) {
        console.error('[Spalla] Exception loading reminders:', e);
        this.data.reminders = [];
      }
    },

    async _saveReminder(reminder) {
      if (!this.auth.currentUser) return;
      try {
        const payload = {
          ...reminder,
          user_id: this.auth.currentUser.id,
        };
        const { error } = await this.supabase
          .from('god_reminders')
          .upsert(payload, { onConflict: 'id' });
        if (error) console.error('[Spalla] Error saving reminder:', error);
        else await this.loadReminders();
      } catch (e) {
        console.error('[Spalla] Exception saving reminder:', e);
      }
    },

    openReminderModal() {
      this.reminderForm = { texto: '', data: '', prioridade: 'normal', mentorado_nome: '' };
      this.ui.reminderModal = true;
    },

    closeReminderModal() {
      this.ui.reminderModal = false;
    },

    async saveReminder() {
      if (!this.reminderForm.texto.trim()) return;
      if (!this.auth.currentUser) {
        this.auth.error = 'Você deve estar logado para criar lembretes';
        return;
      }
      try {
        // Resolve mentorado_id from nome if available
        let mentoradoId = null;
        if (this.reminderForm.mentorado_nome) {
          const match = this.data.mentees.find(m => m.nome === this.reminderForm.mentorado_nome);
          if (match) mentoradoId = match.id;
        }
        const reminder = {
          id: crypto.randomUUID ? crypto.randomUUID() : 'rem_' + Date.now(),
          titulo: this.reminderForm.texto,
          data_lembrete: this.reminderForm.data || null,
          prioridade: this.reminderForm.prioridade,
          mentorado_nome: this.reminderForm.mentorado_nome,
          mentorado_id: mentoradoId,
          status: 'ativo',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
          user_id: this.auth.currentUser.id,
        };
        const { error } = await this.supabase
          .from('god_reminders')
          .insert(reminder);
        if (error) {
          console.error('[Spalla] Error creating reminder:', error);
          this.toast('Erro ao criar lembrete: ' + error.message, 'error');
        } else {
          await this.loadReminders();
          this.closeReminderModal();
          this.toast('Lembrete criado', 'success');
        }
      } catch (e) {
        console.error('[Spalla] Exception creating reminder:', e);
        this.toast('Erro ao criar lembrete', 'error');
      }
    },

    async toggleReminder(id) {
      const r = this.data.reminders.find(x => x.id === id);
      if (r) {
        try {
          const newStatus = r.status === 'concluido' ? 'ativo' : 'concluido';
          const { error } = await this.supabase
            .from('god_reminders')
            .update({ status: newStatus, updated_at: new Date().toISOString() })
            .eq('id', id);
          if (error) console.error('[Spalla] Error updating reminder:', error);
          else await this.loadReminders();
        } catch (e) {
          console.error('[Spalla] Exception toggling reminder:', e);
        }
      }
    },

    async deleteReminder(id) {
      try {
        const { error } = await this.supabase
          .from('god_reminders')
          .delete()
          .eq('id', id);
        if (error) {
          console.error('[Spalla] Error deleting reminder:', error);
          this.toast('Erro ao remover lembrete', 'error');
        } else {
          await this.loadReminders();
          this.toast('Lembrete removido', 'info');
        }
      } catch (e) {
        console.error('[Spalla] Exception deleting reminder:', e);
        this.toast('Erro ao remover lembrete', 'error');
      }
    },

    // ===================== WHATSAPP PER-USER SESSION =====================

    // Pre-linked Evolution instances per user (skip QR, always connected)
    _waPrelinkedInstances: {
      mariza: { instance_name: 'producao002', phone_number: '5511941936764' },
      kaique: { instance_name: 'producao002', phone_number: '5511941936764' },
      'kaique rodrigues': { instance_name: 'producao002', phone_number: '5511941936764' },
      'kaique.azevedoo': { instance_name: 'producao002', phone_number: '5511941936764' },
    },

    _isPrelinkedUser() {
      // Try full_name first, then email prefix — same fallback chain as other auth lookups
      let name = (this.auth.currentUser?.full_name || this.auth.currentUser?.user_metadata?.full_name || '').toLowerCase().trim();
      if (!name) {
        name = (this.auth.currentUser?.email || '').toLowerCase().split('@')[0];
      }
      return this._waPrelinkedInstances[name] || null;
    },

    async loadWaSession() {
      if (!sb || !this.auth.currentUser) return;
      const userId = String(this.auth.currentUser.id);
      if (!userId) return;

      // Check if user has a pre-linked instance (no QR needed)
      const prelinked = this._isPrelinkedUser();
      if (prelinked) {
        this.data.waSession = {
          id: 'prelinked',
          user_id: userId,
          instance_name: prelinked.instance_name,
          status: 'connected',
          phone_number: prelinked.phone_number,
          connected_at: new Date().toISOString(),
        };
        this.waVerifyConnection(prelinked.instance_name);
        return;
      }

      try {
        const { data, error } = await sb.from('wa_sessions')
          .select('*')
          .eq('user_id', userId)
          .neq('status', 'disconnected')
          .order('created_at', { ascending: false })
          .limit(1)
          .maybeSingle();
        if (error) { console.warn('[WA Session] Load error:', error.message); return; }
        this.data.waSession = data || null;
        if (data?.status === 'connected') {
          this.waVerifyConnection(data.instance_name);
        } else if (data?.status === 'qr_pending') {
          this.waFetchQrCode(data.instance_name);
          this.waStartStatusPolling(data.instance_name);
        }
      } catch (e) {
        console.error('[WA Session] Exception:', e);
      }
    },

    // All Evolution API calls go through Railway proxy (CONFIG.API_BASE/api/evolution/...)
    // The proxy handles CORS and adds the apikey header automatically.

    async waVerifyConnection(instanceName) {
      if (!instanceName) return;
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/evolution/instance/connectionState/${instanceName}`);
        if (res.ok) {
          const body = await res.json();
          const state = body.instance?.state || body.state;
          if (state === 'open') {
            if (sb && this.data.waSession?.id) {
              await sb.from('wa_sessions')
                .update({ status: 'connected', last_health_check: new Date().toISOString() })
                .eq('id', this.data.waSession.id);
            }
            if (this.data.waSession) this.data.waSession.status = 'connected';
            // Load chats after verifying connection
            this.fetchWhatsAppChats();
          } else {
            console.warn('[WA Session] Connection state:', state, '— attempting restart');
            await this.waAttemptRestart(instanceName);
          }
        }
      } catch (e) {
        console.warn('[WA Session] Health check failed:', e.message);
      }
    },

    async waAttemptRestart(instanceName) {
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/evolution/instance/restart/${instanceName}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' }
        });
        if (res.ok) {
          console.log('[WA Session] Restart successful');
        } else {
          if (sb && this.data.waSession?.id) {
            await sb.from('wa_sessions')
              .update({ status: 'disconnected', qr_code_base64: null })
              .eq('id', this.data.waSession.id);
            this.data.waSession.status = 'disconnected';
          }
        }
      } catch (e) {
        console.warn('[WA Session] Restart failed:', e.message);
      }
    },

    async waStartConnection() {
      // Pre-linked users are already connected, no need to scan QR
      if (this._isPrelinkedUser()) {
        this.toast('Seu WhatsApp já está vinculado automaticamente', 'info');
        return;
      }
      if (!sb || !this.auth.currentUser) {
        this.toast('Erro: servico indisponivel', 'error');
        return;
      }
      this.ui.waSessionLoading = true;
      try {
        const userId = String(this.auth.currentUser.id);
        if (!userId) throw new Error('Usuario invalido');
        const instanceName = `spalla_u${userId}`;

        // Create instance via Railway proxy
        const createRes = await fetch(`${CONFIG.API_BASE}/api/evolution/instance/create`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            instanceName,
            integration: 'WHATSAPP-BAILEYS',
            qrcode: true,
            rejectCall: false,
          })
        });

        if (!createRes.ok) {
          const errBody = await createRes.json().catch(() => ({}));
          if ([401, 403, 409].includes(createRes.status) || errBody.error?.includes('already') || errBody.message?.includes('already')) {
            console.log('[WA Session] Instance may exist or creation restricted, trying reconnect...');
          } else {
            throw new Error(errBody.message || errBody.error || `HTTP ${createRes.status}`);
          }
        }

        // Upsert session in Supabase
        const existing = this.data.waSession;
        if (existing) {
          await sb.from('wa_sessions')
            .update({ status: 'qr_pending', instance_name: instanceName, qr_code_base64: null })
            .eq('id', existing.id);
          existing.status = 'qr_pending';
          existing.instance_name = instanceName;
        } else {
          // Try to find existing record first (may exist from previous session)
          const { data: found } = await sb.from('wa_sessions')
            .select('*')
            .eq('instance_name', instanceName)
            .maybeSingle();
          if (found) {
            await sb.from('wa_sessions')
              .update({ status: 'qr_pending', user_id: userId, qr_code_base64: null })
              .eq('id', found.id);
            found.status = 'qr_pending';
            this.data.waSession = found;
          } else {
            const { data: newSession, error } = await sb.from('wa_sessions')
              .insert({ user_id: userId, instance_name: instanceName, status: 'qr_pending' })
              .select('*')
              .single();
            if (error) throw error;
            this.data.waSession = newSession;
          }
        }

        // Fetch QR code
        await this.waFetchQrCode(instanceName);
        // Start polling for connection status
        this.waStartStatusPolling(instanceName);

      } catch (e) {
        console.error('[WA Session] Start connection error:', e);
        this.toast('Erro ao conectar WhatsApp: ' + e.message, 'error');
      }
      this.ui.waSessionLoading = false;
    },

    async waFetchQrCode(instanceName) {
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/evolution/instance/connect/${instanceName}`);
        if (res.ok) {
          const body = await res.json();
          const qr = body.base64 || body.qrcode?.base64 || null;
          if (qr && this.data.waSession) {
            this.data.waSession.qr_code_base64 = qr;
            if (sb) {
              await sb.from('wa_sessions')
                .update({ qr_code_base64: qr })
                .eq('id', this.data.waSession.id);
            }
          }
        }
      } catch (e) {
        console.warn('[WA Session] QR fetch error:', e.message);
      }
    },

    waStartStatusPolling(instanceName) {
      if (this._waStatusInterval) clearInterval(this._waStatusInterval);
      this.ui.waQrPolling = true;
      let attempts = 0;
      const maxAttempts = 60; // 5s * 60 = 5 min timeout

      this._waStatusInterval = setInterval(async () => {
        attempts++;
        if (attempts > maxAttempts) {
          this.waStopStatusPolling();
          this.toast('Tempo esgotado. Clique "Novo QR" para tentar novamente.', 'warning');
          return;
        }
        try {
          // Check connection state first
          const res = await fetch(`${CONFIG.API_BASE}/api/evolution/instance/connectionState/${instanceName}`);
          if (res.ok) {
            const body = await res.json();
            const state = body.instance?.state || body.state;
            if (state === 'open') {
              this.waStopStatusPolling();
              if (this.data.waSession) {
                this.data.waSession.status = 'connected';
                this.data.waSession.connected_at = new Date().toISOString();
                this.data.waSession.qr_code_base64 = null;
                if (sb) {
                  await sb.from('wa_sessions')
                    .update({
                      status: 'connected',
                      connected_at: new Date().toISOString(),
                      qr_code_base64: null,
                      last_health_check: new Date().toISOString()
                    })
                    .eq('id', this.data.waSession.id);
                }
              }
              this.toast('WhatsApp conectado!', 'success');
              this.fetchWhatsAppChats();
              return;
            }
          }
          // QR not scanned yet — refresh QR every poll cycle
          // Evolution QR expires in ~20s, calling connect/ returns a fresh one
          await this.waFetchQrCode(instanceName);
        } catch (e) {
          console.warn('[WA Session] Polling error:', e.message);
        }
      }, 5000);
    },

    waStopStatusPolling() {
      if (this._waStatusInterval) {
        clearInterval(this._waStatusInterval);
        this._waStatusInterval = null;
      }
      this.ui.waQrPolling = false;
    },

    async waDisconnect() {
      if (!this.data.waSession) return;
      // Pre-linked users cannot disconnect (shared instance)
      if (this._isPrelinkedUser()) {
        this.toast('Esta instância é vinculada permanentemente à sua conta', 'warning');
        return;
      }
      const session = this.data.waSession;
      try {
        const logoutRes = await fetch(`${CONFIG.API_BASE}/api/evolution/instance/logout/${session.instance_name}`, {
          method: 'DELETE',
          headers: { 'Content-Type': 'application/json' }
        });
        if (!logoutRes.ok && logoutRes.status !== 400) {
          console.warn('[WA Session] Logout API status:', logoutRes.status);
          this.toast('Aviso: logout da instancia pode ter falhado', 'warning');
        }
      } catch (e) {
        console.warn('[WA Session] Logout API error:', e.message);
        this.toast('Aviso: nao foi possivel desconectar a instancia', 'warning');
      }
      if (sb && session.id) {
        await sb.from('wa_sessions')
          .update({ status: 'disconnected', phone_number: null, qr_code_base64: null })
          .eq('id', session.id);
      }
      this.data.waSession = null;
      this.data.whatsappChats = [];
      this.data.whatsappMessages = [];
      this.ui.whatsappSelectedChat = null;
      this.waStopStatusPolling();
      this.toast('WhatsApp desconectado', 'info');
    },

    waSessionStatus() {
      return this.data.waSession?.status || 'disconnected';
    },

    waSessionPhone() {
      return this.data.waSession?.phone_number || null;
    },

    // ===================== WHATSAPP (Evolution API) =====================

    async fetchWhatsAppChats() {
      const { instance } = this._waActiveInstance();
      if (!instance) { this.toast('WhatsApp nao configurado', 'info'); return; }
      this.ui.whatsappLoading = true;
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/evolution/chat/findChats/${instance}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({}),
        });
        if (res.ok) {
          const chats = await res.json();
          // Show all chats sorted by most recent
          // Use remoteJid as primary identifier (id can be null in Evolution v2)
          this.data.whatsappChats = (chats || [])
            .filter(c => c && (c.remoteJid || c.id))
            .filter(c => c.remoteJid !== 'status@broadcast') // Exclude status updates
            .map(c => {
              // Normalize: ensure id is set, derive display name
              if (!c.id) c.id = c.remoteJid;
              if (!c.name && !c.pushName) {
                // Try to get alt number from lastMessage
                const alt = c.lastMessage?.key?.remoteJidAlt;
                if (alt) {
                  c.pushName = alt.replace('@s.whatsapp.net', '');
                } else if (c.remoteJid) {
                  c.pushName = c.remoteJid.replace('@s.whatsapp.net', '').replace('@lid', '').replace('@g.us', ' (grupo)');
                }
              }
              return c;
            })
            .sort((a, b) => {
              const ta = new Date(a.updatedAt || 0).getTime();
              const tb = new Date(b.updatedAt || 0).getTime();
              return tb - ta;
            })
            .slice(0, 100);
          this.toast(`${this.data.whatsappChats.length} conversas carregadas`, 'success');
        } else {
          throw new Error(`HTTP ${res.status}`);
        }
      } catch (e) {
        console.error('[Spalla] WhatsApp fetch error:', e);
        this.toast('Erro ao carregar WhatsApp: ' + e.message, 'error');
        // Load demo chats
        this.data.whatsappChats = DEMO_WA_CHATS;
      }
      this.ui.whatsappLoading = false;
    },

    async selectWhatsAppChat(chat) {
      const { instance } = this._waActiveInstance();
      if (!instance) return;
      this.ui.whatsappSelectedChat = chat;
      this.ui.whatsappLoading = true;
      this.stopWhatsAppPolling(); // cleanup previous subscriptions + polling

      const groupJid = chat.remoteJid || chat.id;
      this._loadingGroupJid = groupJid;

      // Strategy: try Supabase wa_messages first, fallback to Evolution API
      let usedRealtime = false;
      try {
        const { data: rawMsgs, error } = await sb.from('whatsapp_messages')
          .select('id,message_id,group_id,sender_name,type,content,media_url,media_mime_type,quoted_message_id,timestamp,is_from_team')
          .eq('group_id', groupJid)
          .order('timestamp', { ascending: false })
          .limit(100);
        // Reverse to chronological order (oldest first for display)
        const dbMsgs = rawMsgs ? rawMsgs.reverse() : [];

        if (this._loadingGroupJid !== groupJid) return; // stale request — user switched chats

        if (!error && dbMsgs && dbMsgs.length > 0) {
          // Use Supabase data — convert to Evolution format for HTML compatibility
          this.data.whatsappMessages = dbMsgs.map(row => this._waDbToEvolutionFormat(row));
          // Subscribe to Realtime for live updates
          this._subscribeWaRealtime(groupJid);
          usedRealtime = true;
          console.log(`[Spalla] WA chat loaded from Supabase: ${dbMsgs.length} msgs (Realtime active)`);
        } else {
          throw new Error('No messages in Supabase — fallback to Evolution API');
        }
      } catch (sbErr) {
        // Fallback: load from Evolution API directly (legacy path)
        console.warn('[Spalla] Supabase WA fallback:', sbErr.message);
        try {
          const res = await fetch(`${CONFIG.API_BASE}/api/evolution/chat/findMessages/${instance}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ where: { key: { remoteJid: groupJid } }, limit: 50 }),
          });
          if (res.ok) {
            const data = await res.json();
            const msgs = data.messages?.records || data.messages || data || [];
            this.data.whatsappMessages = (Array.isArray(msgs) ? msgs : []).reverse();
            this.eagerlyLoadWaMediaUrls(this.data.whatsappMessages);
          } else {
            throw new Error(`HTTP ${res.status}`);
          }
        } catch (evoErr) {
          console.error('[Spalla] WA messages fetch error:', evoErr);
          this.data.whatsappMessages = DEMO_WA_MESSAGES;
        }
        // Legacy polling as fallback when not using Realtime
        this.startWhatsAppPolling();
      }

      this.ui.whatsappLoading = false;
      this.$nextTick(() => {
        const el = document.getElementById('wa-messages-end');
        if (el) el.scrollIntoView({ behavior: 'smooth' });
        // Setup read receipts observer for visible messages
        this.setupWaReadReceipts();
        // Eagerly load media URLs for Supabase messages
        this.eagerlyLoadWaMediaUrls(this.data.whatsappMessages);
      });
    },

    // Story 3.1: Dynamic send routing — uses user's instance if connected, fallback to producao002
    _waActiveInstance() {
      // Pre-linked users always use their assigned instance
      const prelinked = this._isPrelinkedUser();
      if (prelinked) {
        return { instance: prelinked.instance_name, isPersonal: true };
      }
      const session = this.data.waSession;
      if (session?.status === 'connected' && session?.instance_name) {
        return { instance: session.instance_name, isPersonal: true };
      }
      return { instance: EVOLUTION_INSTANCE, isPersonal: false };
    },

    async sendWhatsAppMessage() {
      if (!this.ui.whatsappMessage.trim() || !this.ui.whatsappSelectedChat) return;
      const { instance, isPersonal } = this._waActiveInstance();
      if (!instance) { this.toast('WhatsApp nao configurado', 'info'); return; }
      const msg = this.ui.whatsappMessage.trim();
      const replyTo = this.ui.waReplyTo;
      const replyToId = replyTo?.key?.id || null;
      this.ui.whatsappMessage = '';
      this.clearWaReply();
      if (!isPersonal) {
        this.toast('Enviando pelo numero central (conecte seu WhatsApp em Configuracoes)', 'warning');
      }

      const number = this.ui.whatsappSelectedChat.remoteJid || this.ui.whatsappSelectedChat.id;
      const groupJid = number;

      // Optimistic insert (will be deduplicated by Realtime if using Supabase)
      const optimisticMsg = {
        key: { id: 'pending-' + Date.now(), fromMe: true, remoteJid: groupJid },
        message: { conversation: msg },
        messageTimestamp: Math.floor(Date.now() / 1000),
        pushName: isPersonal ? (this.auth.currentUser?.full_name || 'Voce') : 'Equipe CASE',
        _status: 'pending',
        _replyToId: replyToId,
      };
      this.data.whatsappMessages.push(optimisticMsg);
      // Onda 7: marca msg recém-enviada pra animação send-pop (300ms)
      this.ui.waJustSentId = optimisticMsg.key.id;
      setTimeout(() => { if (this.ui.waJustSentId === optimisticMsg.key.id) this.ui.waJustSentId = null; }, 600);
      this.$nextTick(() => {
        const el = document.getElementById('wa-messages-end');
        if (el) el.scrollIntoView({ behavior: 'smooth' });
      });

      try {
        // Use new authenticated endpoint (with reply support)
        const endpoint = replyToId ? '/api/wa/reply' : '/api/wa/send-text';
        const payload = { number, text: msg, instance, group_jid: groupJid };
        if (replyToId) payload.quoted_message_id = replyToId;

        const res = await fetch(`${CONFIG.API_BASE}${endpoint}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.auth.accessToken}`,
          },
          body: JSON.stringify(payload),
        });

        if (res.ok) {
          const result = await res.json();
          // Update optimistic message with real ID
          const optIdx = this.data.whatsappMessages.indexOf(optimisticMsg);
          if (optIdx >= 0 && result.message_id) {
            this.data.whatsappMessages[optIdx].key.id = result.message_id;
            this.data.whatsappMessages[optIdx]._status = 'sent';
          }
        } else {
          const err = await res.json().catch(() => ({}));
          throw new Error(err.error || `HTTP ${res.status}`);
        }
      } catch (e) {
        console.error('[Spalla] WA send error:', e);
        this.toast('Erro ao enviar: ' + e.message, 'error');
        // Mark optimistic message as failed
        const optIdx = this.data.whatsappMessages.indexOf(optimisticMsg);
        if (optIdx >= 0) {
          this.data.whatsappMessages[optIdx]._status = 'failed';
        }
        this.ui.whatsappMessage = msg; // restore text on error
      }
    },

    // Story 3.2: Send media (image, document, audio)
    async waSendMedia(file) {
      if (!file || !this.ui.whatsappSelectedChat) return;
      const { instance } = this._waActiveInstance();
      if (!instance) { this.toast('WhatsApp nao configurado', 'info'); return; }
      const maxBytes = 16 * 1024 * 1024; // 16MB WhatsApp limit
      if (file.size > maxBytes) {
        this.toast('Arquivo muito grande (maximo 16MB)', 'error');
        return;
      }
      // Determine media type
      let mediatype = 'document';
      if (file.type.startsWith('image/')) mediatype = 'image';
      else if (file.type.startsWith('video/')) mediatype = 'video';
      else if (file.type.startsWith('audio/')) mediatype = 'audio';
      // Convert to base64 data URL
      const base64 = await new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result);
        reader.onerror = reject;
        reader.readAsDataURL(file);
      });

      const number = this.ui.whatsappSelectedChat.remoteJid || this.ui.whatsappSelectedChat.id;
      const groupJid = number;

      this.ui.waSendingMedia = true;
      try {
        // Use new authenticated endpoint
        const res = await fetch(`${CONFIG.API_BASE}/api/wa/send-media`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.auth.accessToken}`,
          },
          body: JSON.stringify({
            number,
            instance,
            group_jid: groupJid,
            media_url: base64,
            media_type: mediatype,
            media_name: file.name,
            media_mime: file.type,
            caption: '',
          }),
        });
        if (res.ok) {
          const result = await res.json();
          // Optimistic message in thread
          const msgObj = {
            key: { id: result.message_id || ('pending-' + Date.now()), fromMe: true, remoteJid: groupJid },
            messageTimestamp: Math.floor(Date.now() / 1000),
            pushName: this.auth.currentUser?.full_name || 'Voce',
            _status: 'sent',
          };
          if (mediatype === 'image') msgObj.message = { imageMessage: { caption: file.name } };
          else if (mediatype === 'audio') msgObj.message = { audioMessage: {} };
          else if (mediatype === 'video') msgObj.message = { videoMessage: { caption: file.name } };
          else msgObj.message = { documentMessage: { fileName: file.name } };
          this.data.whatsappMessages.push(msgObj);
          this.toast(`${mediatype === 'image' ? 'Imagem' : mediatype === 'audio' ? 'Audio' : mediatype === 'video' ? 'Video' : 'Documento'} enviado`, 'success');
          this.$nextTick(() => {
            const el = document.getElementById('wa-messages-end');
            if (el) el.scrollIntoView({ behavior: 'smooth' });
          });
        } else {
          const err = await res.json().catch(() => ({}));
          throw new Error(err.error || `HTTP ${res.status}`);
        }
      } catch (e) {
        console.error('[Spalla] WA media send error:', e);
        this.toast('Erro ao enviar arquivo: ' + e.message, 'error');
      }
      this.ui.waSendingMedia = false;
    },

    waHandleFileAttach(e) {
      const file = e.target?.files?.[0];
      if (file) this.waSendMedia(file);
      if (e.target) e.target.value = ''; // reset input
    },

    // Story 3.3: Health check — 60s periodic polling
    waStartHealthCheck() {
      if (this._waHealthInterval) clearInterval(this._waHealthInterval);
      this._waHealthInterval = setInterval(async () => {
        const session = this.data.waSession;
        if (!session || session.status !== 'connected') return;
        await this.waVerifyConnection(session.instance_name);
      }, 60000);
    },

    waStopHealthCheck() {
      if (this._waHealthInterval) {
        clearInterval(this._waHealthInterval);
        this._waHealthInterval = null;
      }
    },

    getWaMessageText(msg) {
      if (!msg || !msg.message) return '';
      const m = msg.message;
      if (m.conversation) return m.conversation;
      if (m.extendedTextMessage?.text) return m.extendedTextMessage.text;
      if (m.imageMessage) return m.imageMessage.caption || '[Imagem]';
      if (m.videoMessage) return m.videoMessage.caption || '[Video]';
      if (m.audioMessage) return '[Audio]';
      if (m.documentMessage) return m.documentMessage.title || m.documentMessage.fileName || '[Documento]';
      if (m.stickerMessage) return '[Sticker]';
      if (m.contactMessage) return m.contactMessage.displayName || '[Contato]';
      if (m.locationMessage) return '[Localizacao]';
      if (m.reactionMessage) return m.reactionMessage.text || '[Reacao]';
      return '[midia]';
    },

    getWaMessageType(msg) {
      if (!msg?.message) return 'text';
      const m = msg.message;
      if (m.audioMessage) return 'audio';
      if (m.imageMessage) return 'image';
      if (m.videoMessage) return 'video';
      if (m.documentMessage) {
        if (m.documentMessage.mimetype?.includes('video')) return 'video';
        if (m.documentMessage.mimetype?.includes('audio')) return 'audio';
        if (m.documentMessage.mimetype?.includes('image')) return 'image';
        return 'document';
      }
      return 'text';
    },

    // Eagerly load media URLs for all messages after they're fetched
    eagerlyLoadWaMediaUrls(messages) {
      if (!Array.isArray(messages)) return;
      if (!this.waMediaUrls) this.waMediaUrls = {};

      let updated = false;
      for (const msg of messages) {
        if (!msg?.key?.id) continue;
        const msgId = msg.key.id;

        // Skip if already cached
        if (this.waMediaUrls[msgId]) continue;

        // Check if Evolution API provided mediaUrl directly
        if (msg.message?.mediaUrl) {
          this.waMediaUrls[msgId] = msg.message.mediaUrl;
          updated = true;
        }
        // Check if Supabase row has _mediaUrl (S3 key or full URL)
        else if (msg._mediaUrl) {
          const url = msg._mediaUrl;
          if (url.includes('mmg.whatsapp.net')) {
            // Temporary WhatsApp URL — construct S3 fallback key
            // S3 path: evolution-api/{INSTANCE_UUID}/{chatId}/{messageType}/{timestamp}_{msgId}.{ext}
            const instanceUuid = (typeof EVOLUTION_CONFIG !== 'undefined' ? EVOLUTION_CONFIG?.INSTANCE_UUID : null) || 'default';
            const chatId = msg.key?.remoteJid || this.ui.whatsappSelectedChat?.remoteJid || 'unknown';
            const mediaType = msg._contentType === 'image' ? 'imageMessage' : msg._contentType === 'video' ? 'videoMessage' : msg._contentType === 'document' ? 'documentMessage' : 'audioMessage';
            const ts = msg.messageTimestamp ? Math.floor(msg.messageTimestamp * 1000) : Date.now();
            const ext = mediaType === 'audioMessage' ? 'oga' : mediaType === 'imageMessage' ? 'jpg' : mediaType === 'videoMessage' ? 'mp4' : 'bin';
            const s3Key = `evolution-api/${instanceUuid}/${chatId}/${mediaType}/${ts}_${msgId}.${ext}`;
            // Try S3 first (more reliable), fallback to WA URL
            this.waMediaUrls[msgId] = `${CONFIG.API_BASE}/api/media/stream?key=${encodeURIComponent(s3Key)}&fallback=${encodeURIComponent(url)}`;
          } else if (url.startsWith('http')) {
            this.waMediaUrls[msgId] = url;
          } else {
            // S3 key — use stream proxy
            this.waMediaUrls[msgId] = `${CONFIG.API_BASE}/api/media/stream?key=${encodeURIComponent(url)}`;
          }
          updated = true;
        }
      }

      // Trigger reactivity once for all updates
      if (updated) {
        this.waMediaUrls = { ...this.waMediaUrls };
      }
    },

    loadWaMedia(msg) {
      if (!msg?.key?.id) return '';
      const msgId = msg.key.id;

      // Return cached URL if available
      if (this.waMediaUrls && this.waMediaUrls[msgId]) {
        return this.waMediaUrls[msgId];
      }

      // Check if Evolution API already provided a presigned mediaUrl (best case!)
      if (msg.message?.mediaUrl) {
        if (!this.waMediaUrls) this.waMediaUrls = {};
        this.waMediaUrls[msgId] = msg.message.mediaUrl;
        this.waMediaUrls = { ...this.waMediaUrls };
        return msg.message.mediaUrl;
      }

      // Fallback: construct stream URL via our backend proxy
      // Determine message type
      let mediaType = null;
      if (msg.message?.audioMessage) mediaType = 'audioMessage';
      else if (msg.message?.imageMessage) mediaType = 'imageMessage';
      else if (msg.message?.videoMessage) mediaType = 'videoMessage';
      else if (msg.message?.documentMessage) mediaType = 'documentMessage';

      if (!mediaType) return '';

      // Get Evolution instance UUID and chat ID
      const instanceId = (typeof EVOLUTION_CONFIG !== 'undefined' ? EVOLUTION_CONFIG?.INSTANCE_UUID : null) || this._waActiveInstance().instance || 'default';
      const chatId = this.ui.whatsappSelectedChat?.remoteJid || this.ui.whatsappSelectedChat?.id || 'unknown';

      // Build filename
      const timestamp = msg.messageTimestamp ? Math.floor(msg.messageTimestamp * 1000) : Date.now();
      const extension = mediaType === 'audioMessage' ? 'oga' : mediaType === 'imageMessage' ? 'jpg' : 'mp4';
      const filename = `${timestamp}_${msgId}.${extension}`;

      // Build S3 key
      const s3Key = `evolution-api/${instanceId}/${chatId}/${mediaType}/${filename}`;
      const streamUrl = `${CONFIG.API_BASE}/api/media/stream?key=${encodeURIComponent(s3Key)}`;


      // Set URL immediately
      if (!this.waMediaUrls) this.waMediaUrls = {};
      this.waMediaUrls[msgId] = streamUrl;
      this.waMediaUrls = { ...this.waMediaUrls };

      return ''; // Return empty URL initially (will be filled when fetch completes)
    },

    getWaMessageTime(msg) {
      if (!msg?.messageTimestamp) return '';
      const d = new Date(msg.messageTimestamp * 1000);
      return d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
    },

    getWaChatName(chat) {
      return chat?.name || chat?.subject || chat?.pushName || chat?.id?.split('@')[0] || 'Chat';
    },

    // Onda 7: virtual scrolling pragmático — slice das últimas N msgs
    // Alpine sem virtual scrolling real é caro de implementar; cap em 200 cobre 99% dos casos
    visibleWaMessages() {
      const all = this.data.whatsappMessages || [];
      const max = this.ui.waMaxVisibleMessages || 200;
      if (all.length <= max) return all;
      return all.slice(-max);
    },
    waLoadMoreMessages() {
      this.ui.waMaxVisibleMessages = (this.ui.waMaxVisibleMessages || 200) + 200;
    },

    // Onda 7: atalhos de teclado globais — só ativos quando /whatsapp está aberto
    handleWaShortcuts(ev) {
      if (this.ui.page !== 'whatsapp') return;
      const tag = (ev.target?.tagName || '').toLowerCase();
      const isInput = tag === 'input' || tag === 'textarea' || ev.target?.isContentEditable;
      // ESC sempre ativo
      if (ev.key === 'Escape') {
        if (this.ui.waShortcutsOpen) { this.ui.waShortcutsOpen = false; ev.preventDefault(); return; }
        if (this.ui.waLightboxUrl) { this.ui.waLightboxUrl = null; ev.preventDefault(); return; }
        if (this.ui.waMenteeCardOpen) { this.ui.waMenteeCardOpen = false; ev.preventDefault(); return; }
        return;
      }
      // Outros só fora de input
      if (isInput) return;
      const k = ev.key.toLowerCase();
      if (k === '?') { this.ui.waShortcutsOpen = !this.ui.waShortcutsOpen; ev.preventDefault(); return; }
      if (k === '/') {
        if (this.ui.whatsappSelectedChat) {
          this.ui.waSearchOpen = true;
          this.$nextTick(() => this.$refs.waSearchInput?.focus());
          ev.preventDefault();
        }
        return;
      }
      if (k === 'j' || k === 'k') {
        const chats = this.data.whatsappChats || [];
        if (!chats.length) return;
        const curIdx = this.ui.whatsappSelectedChat ? chats.findIndex(c => c.id === this.ui.whatsappSelectedChat.id) : -1;
        const nextIdx = k === 'j'
          ? (curIdx >= chats.length - 1 ? 0 : curIdx + 1)
          : (curIdx <= 0 ? chats.length - 1 : curIdx - 1);
        if (chats[nextIdx]) this.selectWhatsAppChat(chats[nextIdx]);
        ev.preventDefault();
      }
    },

    // Convert URLs in text to clickable links (safe — escapes HTML first)
    linkifyText(text) {
      if (!text) return '';
      // Escape HTML to prevent XSS
      const escaped = text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
      // Convert URLs to <a> tags
      return escaped.replace(/(https?:\/\/[^\s<"']+)/g, '<a href="$1" target="_blank" rel="noopener" style="color:#3b82f6;text-decoration:underline;word-break:break-all">$1</a>');
    },

    // Onda 6: lookup do mentee linkado por wa_groups (defensivo — funciona mesmo sem Onda 2 mergeada)
    waChatLinkedMenteeId(chat) {
      const jid = chat?.remoteJid || chat?.id;
      if (!jid) return null;
      const g = (this.data.waGroups || []).find(g => g.group_jid === jid);
      return g?.mentorado_id || null;
    },

    // Onda 6: extrai a primeira URL de um texto pra renderizar preview card (favicon + domínio + URL)
    extractFirstUrl(text) {
      if (!text) return null;
      const m = text.match(/https?:\/\/[^\s<"']+/);
      if (!m) return null;
      try {
        const u = new URL(m[0]);
        return {
          url: m[0],
          domain: u.hostname.replace(/^www\./, ''),
          favicon: `https://www.google.com/s2/favicons?domain=${u.hostname}&sz=64`,
          path: u.pathname && u.pathname !== '/' ? u.pathname.slice(0, 60) : '',
        };
      } catch (e) {
        return null;
      }
    },

    // Onda 6: abre/fecha mini-card do mentorado vinculado (painel direito do chat)
    toggleWaMenteeCard() {
      this.ui.waMenteeCardOpen = !this.ui.waMenteeCardOpen;
    },

    // Resolve dados completos do mentee vinculado pra mini-card
    getWaSelectedChatMenteeFull() {
      const chat = this.ui.whatsappSelectedChat;
      const id = chat ? this.waChatLinkedMenteeId(chat) : null;
      if (!id) return null;
      return (this.data.mentees || []).find(m => m.id === id) || null;
    },

    // ===== Reply-to helpers =====
    setWaReply(msg) {
      this.ui.waReplyTo = msg;
      // Focus the input
      this.$nextTick(() => {
        const input = document.querySelector('.wa-chat__input input[type="text"]');
        if (input) input.focus();
      });
    },

    clearWaReply() {
      this.ui.waReplyTo = null;
    },

    getReplyPreviewText(messageId) {
      if (!messageId) return '';
      const msg = this.data.whatsappMessages.find(m => m.key?.id === messageId);
      if (!msg) return '[mensagem]';
      const text = this.getWaMessageText(msg);
      return text.length > 60 ? text.substring(0, 60) + '...' : text;
    },

    // Onda 3: reply preview enriquecido — sender + tipo de mídia + thumb URL
    getReplyPreviewMeta(messageId) {
      if (!messageId) return { sender: '', type: 'text', thumbUrl: '', icon: '' };
      const msg = this.data.whatsappMessages.find(m => m.key?.id === messageId);
      if (!msg) return { sender: '', type: 'text', thumbUrl: '', icon: '' };
      const sender = msg.key?.fromMe ? 'Você' : (msg.pushName || 'Mensagem');
      const m = msg.message || {};
      let type = 'text', icon = '';
      if (m.imageMessage) { type = 'image'; icon = '📷'; }
      else if (m.videoMessage) { type = 'video'; icon = '🎥'; }
      else if (m.audioMessage) { type = 'audio'; icon = '🎤'; }
      else if (m.documentMessage) { type = 'document'; icon = '📎'; }
      else if (m.stickerMessage) { type = 'sticker'; icon = '🌟'; }
      const thumbUrl = (this.waMediaUrls && this.waMediaUrls[msg.key?.id]) || '';
      return { sender, type, thumbUrl, icon };
    },

    // Onda 3: cor única por sender — hash do JID/pushName em 8 cores curadas
    // Aplicado no .wa-bubble__sender pra ajudar rastreio em grupos com 4+ pessoas
    waSenderColor(name) {
      if (!name) return '#4a5e3a';
      const palette = ['#1f7a8c','#5a3e8a','#8a4f1f','#1f6b3a','#8a1f4f','#3e6b1f','#6b1f1f','#1f3e6b'];
      let hash = 0;
      for (let i = 0; i < name.length; i++) hash = ((hash << 5) - hash + name.charCodeAt(i)) | 0;
      return palette[Math.abs(hash) % palette.length];
    },

    // Onda 3: avatar mini só na primeira bolha do grupo (em chats que NÃO são "me")
    // Para chats de grupo, usa profilePicUrl do sender se disponível, senão iniciais
    waSenderAvatarUrl(msg) {
      // Por enquanto, sem fallback de profilePicUrl por participante (Evolution não expõe)
      return '';
    },

    waSenderInitials(name) {
      if (!name) return '?';
      return this.avatarInitials(name);
    },

    scrollToWaMessage(messageId) {
      if (!messageId) return;
      const el = document.getElementById('wa-msg-' + messageId);
      if (el) {
        el.scrollIntoView({ behavior: 'smooth', block: 'center' });
        el.style.background = 'rgba(107, 154, 70, 0.15)';
        setTimeout(() => { el.style.background = ''; }, 2000);
      }
    },

    // Onda 4: navegação entre matches do search com ↑/↓ e ESC pra fechar
    waSearchNext() {
      const total = this.ui.waSearchResults?.length || 0;
      if (!total) return;
      this.ui.waSearchActiveIdx = (this.ui.waSearchActiveIdx + 1) % total;
      const r = this.ui.waSearchResults[this.ui.waSearchActiveIdx];
      if (r?.message_id) this.scrollToWaMessage(r.message_id);
    },
    waSearchPrev() {
      const total = this.ui.waSearchResults?.length || 0;
      if (!total) return;
      this.ui.waSearchActiveIdx = (this.ui.waSearchActiveIdx - 1 + total) % total;
      const r = this.ui.waSearchResults[this.ui.waSearchActiveIdx];
      if (r?.message_id) this.scrollToWaMessage(r.message_id);
    },

    // Onda 4: FAB "↓ Nova mensagem" — observa scroll do feed; quando user
    // está scrollado pra cima e chega msg, mostra pílula
    waOnFeedScroll(ev) {
      const el = ev?.target;
      if (!el) return;
      const distFromBottom = el.scrollHeight - el.scrollTop - el.clientHeight;
      if (distFromBottom < 80) {
        this.ui.waNewMsgFabVisible = false;
        this.ui.waNewMsgFabCount = 0;
      }
    },
    waJumpToBottom() {
      const el = document.getElementById('wa-messages-end');
      if (el) el.scrollIntoView({ behavior: 'smooth', block: 'end' });
      this.ui.waNewMsgFabVisible = false;
      this.ui.waNewMsgFabCount = 0;
    },

    // Onda 4: lightbox sofisticado — coleta todas as imgs do chat e navega ←/→
    openWaLightbox(currentUrl) {
      const list = [];
      (this.data.whatsappMessages || []).forEach(m => {
        const id = m.key?.id;
        const url = id ? this.waMediaUrls?.[id] : null;
        if (url && this.getWaMessageType?.(m) === 'image') list.push(url);
      });
      const idx = Math.max(0, list.indexOf(currentUrl));
      this.ui.waLightboxList = list.length ? list : [currentUrl];
      this.ui.waLightboxIdx = idx;
      this.ui.waLightboxUrl = list.length ? list[idx] : currentUrl;
    },
    waLightboxNext() {
      const list = this.ui.waLightboxList || [];
      if (list.length < 2) return;
      this.ui.waLightboxIdx = (this.ui.waLightboxIdx + 1) % list.length;
      this.ui.waLightboxUrl = list[this.ui.waLightboxIdx];
    },
    waLightboxPrev() {
      const list = this.ui.waLightboxList || [];
      if (list.length < 2) return;
      this.ui.waLightboxIdx = (this.ui.waLightboxIdx - 1 + list.length) % list.length;
      this.ui.waLightboxUrl = list[this.ui.waLightboxIdx];
    },
    waLightboxDownload() {
      const url = this.ui.waLightboxUrl;
      if (!url) return;
      const a = document.createElement('a');
      a.href = url;
      a.download = 'imagem-' + Date.now() + '.jpg';
      a.target = '_blank';
      document.body.appendChild(a);
      a.click();
      a.remove();
    },

    // ===== Audio Recording (Story 6) =====
    async waStartRecording() {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        const recorder = new MediaRecorder(stream, { mimeType: 'audio/webm;codecs=opus' });
        const chunks = [];
        recorder.ondataavailable = (e) => { if (e.data.size > 0) chunks.push(e.data); };
        recorder.onstop = async () => {
          stream.getTracks().forEach(t => t.stop());
          const blob = new Blob(chunks, { type: 'audio/ogg' });
          if (blob.size < 1000) { this.toast('Audio muito curto', 'warning'); return; }
          const file = new File([blob], `audio_${Date.now()}.ogg`, { type: 'audio/ogg' });
          this.waSendMedia(file);
        };
        recorder.start();
        this.ui.waRecording = true;
        this.ui.waRecorder = recorder;
        this.toast('Gravando audio...', 'info');
      } catch (e) {
        console.error('[Spalla] Mic access denied:', e);
        this.toast('Acesso ao microfone negado', 'error');
      }
    },

    waStopRecording() {
      if (this.ui.waRecorder && this.ui.waRecorder.state === 'recording') {
        this.ui.waRecorder.stop();
      }
      this.ui.waRecording = false;
      this.ui.waRecorder = null;
    },

    // ===== Paste + Drag & Drop (Story 7) =====
    waHandlePaste(e) {
      const items = e.clipboardData?.items;
      if (!items) return;
      for (const item of items) {
        if (item.type.startsWith('image/')) {
          e.preventDefault();
          const file = item.getAsFile();
          if (file) {
            this.toast('Imagem colada — enviando...', 'info');
            this.waSendMedia(file);
          }
          return;
        }
      }
    },

    waHandleDrop(e) {
      const files = e.dataTransfer?.files;
      if (!files || files.length === 0) return;
      const file = files[0];
      if (file.size > 16 * 1024 * 1024) {
        this.toast('Arquivo muito grande (maximo 16MB)', 'error');
        return;
      }
      this.toast(`Arquivo "${file.name}" — enviando...`, 'info');
      this.waSendMedia(file);
    },

    // ===== Typing Indicator (Story 9) =====
    _waTypingTimeout: null,
    waHandleTyping() {
      if (this._waTypingTimeout) return; // Already sent recently
      const { instance } = this._waActiveInstance();
      const chat = this.ui.whatsappSelectedChat;
      if (!instance || !chat) return;
      // Send composing presence via Evolution API
      fetch(`${CONFIG.API_BASE}/api/evolution/chat/presence/${instance}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ number: chat.remoteJid || chat.id, presence: 'composing' }),
      }).catch(() => {}); // fire and forget
      this._waTypingTimeout = setTimeout(() => { this._waTypingTimeout = null; }, 3000); // debounce 3s
    },

    // ===== Message Search (Story 11) =====
    async waSearchMessages() {
      const q = this.ui.waSearchQuery?.trim();
      if (!q || q.length < 3) { this.ui.waSearchResults = []; return; }
      const chat = this.ui.whatsappSelectedChat;
      if (!chat) return;
      const groupJid = chat.remoteJid || chat.id;
      try {
        const { data, error } = await sb.from('whatsapp_messages')
          .select('id,message_id,sender_name,content,timestamp')
          .eq('group_id', groupJid)
          .ilike('content', `%${q}%`)
          .order('timestamp', { ascending: false })
          .limit(20);
        if (error) throw error;
        this.ui.waSearchResults = data || [];
        this.ui.waSearchActiveIdx = 0;
        // Onda 4: pula direto pro primeiro match
        if (this.ui.waSearchResults.length && this.ui.waSearchResults[0].message_id) {
          this.scrollToWaMessage(this.ui.waSearchResults[0].message_id);
        }
      } catch (e) {
        console.error('[Spalla] WA search error:', e);
        this.ui.waSearchResults = [];
        this.ui.waSearchActiveIdx = 0;
      }
    },

    // ===== Read Receipts (Story 10) =====
    _waReadObserver: null,
    _waReadSent: new Set(),
    setupWaReadReceipts() {
      if (this._waReadObserver) this._waReadObserver.disconnect();
      const container = document.querySelector('.wa-chat__messages');
      if (!container) return;
      this._waReadObserver = new IntersectionObserver((entries) => {
        const { instance } = this._waActiveInstance();
        if (!instance) return;
        for (const entry of entries) {
          if (!entry.isIntersecting) continue;
          const msgId = entry.target.id?.replace('wa-msg-', '');
          if (!msgId || msgId.startsWith('pending-') || this._waReadSent.has(msgId)) continue;
          // Find the message — only mark incoming (not fromMe) as read
          const msg = this.data.whatsappMessages.find(m => m.key?.id === msgId);
          if (!msg || msg.key?.fromMe) continue;
          this._waReadSent.add(msgId);
          // Send read receipt via Evolution API
          const chat = this.ui.whatsappSelectedChat;
          fetch(`${CONFIG.API_BASE}/api/evolution/chat/markMessageAsRead/${instance}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ readMessages: [{ id: msgId, remoteJid: chat?.remoteJid || chat?.id }] }),
          }).catch(() => {});
        }
      }, { root: container, threshold: 0.5 });
      // Observe all message bubbles
      container.querySelectorAll('.wa-bubble').forEach(el => this._waReadObserver.observe(el));
    },

    cleanupWaReadReceipts() {
      if (this._waReadObserver) {
        this._waReadObserver.disconnect();
        this._waReadObserver = null;
      }
      this._waReadSent.clear();
    },

    // ===== WA Group Management (Story 8) =====
    async loadWaGroups() {
      try {
        const { data, error } = await sb.from('wa_groups')
          .select('*')
          .eq('is_active', true)
          .order('last_activity', { ascending: false, nullsFirst: false });
        if (error) throw error;
        this.data.waGroups = data || [];
      } catch (e) {
        console.error('[Spalla] loadWaGroups error:', e);
        this.data.waGroups = [];
      }
    },

    async waGroupsSync() {
      const { instance } = this._waActiveInstance();
      if (!instance) { this.toast('WhatsApp nao conectado', 'warning'); return; }
      this.ui.waGroupsSyncing = true;
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/wa/groups/sync`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
          body: JSON.stringify({ instance }),
        });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const result = await res.json();
        this.toast(`${result.synced} grupos sincronizados`, 'success');
        await this.loadWaGroups();
      } catch (e) {
        console.error('[Spalla] WA groups sync error:', e);
        this.toast('Erro ao sincronizar grupos: ' + e.message, 'error');
      } finally {
        this.ui.waGroupsSyncing = false;
      }
    },

    async waGroupCreate() {
      const { instance } = this._waActiveInstance();
      if (!instance) { this.toast('WhatsApp nao conectado', 'warning'); return; }
      const { subject, mentorado_id, participants } = this.ui.waGroupForm;
      if (!subject.trim()) { this.toast('Nome do grupo obrigatorio', 'warning'); return; }
      const phones = participants.split('\n').map(p => p.trim()).filter(p => p.length >= 10);
      if (phones.length === 0) { this.toast('Adicione pelo menos 1 telefone', 'warning'); return; }
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/wa/groups/create`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
          body: JSON.stringify({ instance, subject: subject.trim(), participants: phones, mentorado_id: mentorado_id || null }),
        });
        if (!res.ok) { const err = await res.json().catch(() => ({})); throw new Error(err.error || `HTTP ${res.status}`); }
        this.toast(`Grupo "${subject}" criado!`, 'success');
        this.ui.waGroupCreateModal = false;
        this.ui.waGroupForm = { subject: '', mentorado_id: '', participants: '' };
        await this.loadWaGroups();
      } catch (e) {
        console.error('[Spalla] WA group create error:', e);
        this.toast('Erro ao criar grupo: ' + e.message, 'error');
      }
    },

    async waGroupLink(groupId, mentoradoId) {
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/wa/groups/${groupId}/link`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
          body: JSON.stringify({ mentorado_id: mentoradoId ? parseInt(mentoradoId) : null }),
        });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        // Update local
        const g = this.data.waGroups.find(g => g.id === groupId);
        if (g) g.mentorado_id = mentoradoId ? parseInt(mentoradoId) : null;
        this.toast(mentoradoId ? 'Grupo vinculado ao mentorado' : 'Vinculo removido', 'success');
      } catch (e) {
        console.error('[Spalla] WA group link error:', e);
        this.toast('Erro ao vincular: ' + e.message, 'error');
      }
    },

    // ===================== WA TOPICS BOARD =====================

    async loadWaTopics() {
      this.ui.waTopicsLoading = true;
      try {
        const [topicsRes, typesRes] = await Promise.all([
          sb.from('vw_wa_topic_board')
            .select('*')
            .order('last_message_at', { ascending: false })
            .limit(500),
          sb.from('wa_topic_types')
            .select('*')
            .order('sort_order'),
        ]);
        if (topicsRes.error) throw topicsRes.error;
        if (typesRes.error) throw typesRes.error;
        this.data.waTopics = topicsRes.data || [];
        this.data.waTopicTypes = typesRes.data || [];
      } catch (e) {
        console.error('[Spalla] loadWaTopics error:', e);
        this.toast('Erro ao carregar tópicos: ' + e.message, 'error');
      }
      this.ui.waTopicsLoading = false;
    },

    waTopicsFiltered(status) {
      return this.data.waTopics.filter(t => {
        if (t.status !== status) return false;
        if (this.ui.waTopicsTypeFilter && t.type_slug !== this.ui.waTopicsTypeFilter) return false;
        if (this.ui.waTopicsSearch) {
          const q = this.ui.waTopicsSearch.toLowerCase();
          if (!(t.title?.toLowerCase().includes(q) || t.mentorado_nome?.toLowerCase().includes(q))) return false;
        }
        return true;
      });
    },

    waTopicsFilteredAll() {
      return this.data.waTopics.filter(t => {
        if (this.ui.waTopicsStatusFilter && t.status !== this.ui.waTopicsStatusFilter) return false;
        if (this.ui.waTopicsTypeFilter && t.type_slug !== this.ui.waTopicsTypeFilter) return false;
        if (this.ui.waTopicsSearch) {
          const q = this.ui.waTopicsSearch.toLowerCase();
          if (!(t.title?.toLowerCase().includes(q) || t.mentorado_nome?.toLowerCase().includes(q))) return false;
        }
        return true;
      });
    },

    // ===================== WA MANAGEMENT — CARTEIRA =====================

    waPortfolioMentees() {
      let list = [...this.data.mentees];
      // Filter by active group/pasta
      if (this.ui.activeGroupFilter) {
        const group = this.data.groups.find(g => g.id === this.ui.activeGroupFilter);
        if (group) list = list.filter(m => group.member_ids?.includes(m.id));
      }
      const hasFase   = !!this.ui.waPortfolioFaseFilter;
      const hasHealth = !!this.ui.waPortfolioHealthFilter;
      const bothActive = hasFase && hasHealth;
      if (bothActive && this.ui.waFilterLogic === 'OR') {
        // OR: mentee matches if it satisfies ANY of the active filters
        list = list.filter(m =>
          m.fase_jornada === this.ui.waPortfolioFaseFilter ||
          this._waHealthLabel(m) === this.ui.waPortfolioHealthFilter
        );
      } else {
        // AND (default): apply each active filter sequentially
        if (hasFase) {
          list = list.filter(m => m.fase_jornada === this.ui.waPortfolioFaseFilter);
        }
        if (hasHealth) {
          list = list.filter(m => this._waHealthLabel(m) === this.ui.waPortfolioHealthFilter);
        }
      }
      if (this.ui.waPortfolioView === 'inbox') {
        // I-2: lazy-load triage scores on first inbox access
        if (!this.ui.triageLoaded) this.loadMenteesTriage();
        list.sort((a, b) => this._waPriorityScore(b) - this._waPriorityScore(a));
      } else {
        list.sort((a, b) => (a.nome || '').localeCompare(b.nome || ''));
        // I-1: labels loaded on-demand when card is visible, not in bulk
        // (removed bulk forEach that caused ERR_INSUFFICIENT_RESOURCES)
      }
      return list;
    },

    waPortfolioKpis() {
      const all = this.data.mentees;
      return {
        total: all.length,
        verde: all.filter(m => this._waHealthLabel(m) === 'verde').length,
        amarelo: all.filter(m => this._waHealthLabel(m) === 'amarelo').length,
        vermelho: all.filter(m => this._waHealthLabel(m) === 'vermelho').length,
      };
    },

    // ===================== WA GROUP BOARD — Kanban por wa_status =====================

    waGroupBoard() {
      const mentees = this.data.mentees;
      const topics  = this.data.waTopics || [];
      const hasActive = (m) => topics.some(t =>
        t.mentorado_id === m.id && t.status !== 'resolved' && t.status !== 'converted_task' && t.status !== 'archived'
      );
      return {
        // Only show "Aguardando" for mentees who actually have an open topic
        aguardando:   mentees.filter(m => (!m.wa_status || m.wa_status === 'aguardando') && hasActive(m)),
        em_andamento: mentees.filter(m => m.wa_status === 'em_andamento'),
        bloqueado:    mentees.filter(m => m.wa_status === 'bloqueado'),
        resolvido:    mentees.filter(m => m.wa_status === 'resolvido'),
      };
    },

    menteeActiveTopics(menteeId) {
      return (this.data.waTopics || []).filter(
        t => t.mentorado_id === menteeId && t.status !== 'resolved' && t.status !== 'converted_task' && t.status !== 'archived'
      );
    },

    async setGroupStatus(menteeId, status) {
      await this.patchMentee(menteeId, { wa_status: status });
      const m = this.data.mentees.find(x => x.id === menteeId);
      if (m) m.wa_status = status;
    },

    _waHealthLabel(m) {
      const score = this.calcHealthScore(m).total;
      if (score >= 70) return 'verde';
      if (score >= 40) return 'amarelo';
      return 'vermelho';
    },

    // Wave 3.2 — Churn Risk (0-100). Pure client-side from existing fields.
    calcChurnRisk(m) {
      let risk = 0;
      // Signal 1: Days without call (strongest predictor)
      const dc = m.dias_desde_call ?? 999;
      if (dc > 60) risk += 35;
      else if (dc > 45) risk += 25;
      else if (dc > 30) risk += 15;
      else if (dc > 21) risk += 5;
      // Signal 2: WA engagement (radio silence = churn signal)
      const wa7d = m.whatsapp_7d || 0;
      if (wa7d === 0) risk += 25;
      else if (wa7d <= 2) risk += 15;
      else if (wa7d <= 5) risk += 5;
      // Signal 3: Overdue tasks accumulating
      const late = m.tarefas_atrasadas || 0;
      if (late >= 5) risk += 20;
      else if (late >= 3) risk += 12;
      else if (late >= 1) risk += 5;
      // Signal 4: Financial stress
      if (m.status_financeiro === 'atrasado') risk += 15;
      if (m.contrato_assinado === false) risk += 8;
      // Signal 5: Critical phases with low engagement (onboarding/renovacao are highest-risk moments)
      if (['onboarding', 'renovacao'].includes(m.fase_jornada) && dc > 21) risk += 10;
      return Math.min(100, risk);
    },

    _waPriorityScore(m) {
      // I-2: use server triage score when available
      const server = this.data.triageScores?.[m.id];
      if (server?.score != null) return server.score;
      // fallback: client-side calculation
      let score = 0;
      const h = m.horas_sem_resposta_equipe || 0;
      if (h > 72) score += 40;
      else if (h > 48) score += 25;
      else if (h > 24) score += 10;
      if (m.fase_jornada === 'onboarding' || m.fase_jornada === 'renovacao') score += 20;
      score += Math.min(20, (m.pendencias_count || 0) * 5);
      score += Math.min(10, (m.msgs_pendentes_resposta || 0));
      if (m.risco_churn === 'alto') score += 15;
      else if (m.risco_churn === 'medio') score += 5;
      return score;
    },

    // ===================== I-2: Server Triage Score =====================

    waTriageBadge(score) {
      if (score >= 60) return { color: '#b91c1c', bg: '#fee2e2', text: 'Crítico' };
      if (score >= 30) return { color: '#92400e', bg: '#fef3c7', text: 'Atenção' };
      return { color: '#065f46', bg: '#d1fae5', text: 'OK' };
    },

    async loadMenteesTriage() {
      if (this.ui.triageLoaded) return;
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/mentees/triage`, {
          headers: { 'Authorization': `Bearer ${this.authToken}` },
        });
        if (!res.ok) return;
        const rows = await res.json();
        const map = {};
        for (const r of (rows || [])) {
          if (r.id) map[r.id] = r;
        }
        this.data.triageScores = map;
        this.ui.triageLoaded = true;
      } catch (e) {
        console.warn('[Spalla] loadMenteesTriage error:', e);
      }
    },

    // ===================== I-5: Mentee Files =====================

    async loadMenteeFiles(menteeId) {
      if (!menteeId) return;
      this.data.menteeFiles = { docs: [], media: [], loading: true };
      try {
        const [docsRes, mediaRes] = await Promise.all([
          fetch(`/api/storage/files?entidade_tipo=mentorado&entidade_id=${menteeId}`, {
            headers: { 'Authorization': `Bearer ${this.authToken}` },
          }),
          fetch(`/api/wa/media?mentee_id=${menteeId}`, {
            headers: { 'Authorization': `Bearer ${this.authToken}` },
          }),
        ]);
        const docs = docsRes.ok ? await docsRes.json() : [];
        const mediaJson = mediaRes.ok ? await mediaRes.json() : { media: [] };
        this.data.menteeFiles = {
          docs: Array.isArray(docs) ? docs : [],
          media: mediaJson?.media || [],
          loading: false,
        };
      } catch (e) {
        console.warn('[Spalla] loadMenteeFiles error:', e);
        this.data.menteeFiles = { docs: [], media: [], loading: false };
      }
    },

    _fileTypeIcon(mime, msgType) {
      if (msgType === 'audioMessage') return '🎵';
      if (msgType === 'videoMessage') return '🎬';
      if (msgType === 'imageMessage') return '🖼️';
      if (!mime) return '📄';
      if (mime.includes('pdf')) return '📋';
      if (mime.includes('spreadsheet') || mime.includes('excel')) return '📊';
      if (mime.includes('word') || mime.includes('document')) return '📝';
      if (mime.includes('zip') || mime.includes('rar')) return '🗜️';
      return '📄';
    },

    _fileMediaLabel(msgType) {
      const labels = {
        audioMessage: 'Áudio',
        videoMessage: 'Vídeo',
        documentMessage: 'Documento',
        imageMessage: 'Imagem',
      };
      return labels[msgType] || msgType || 'Arquivo';
    },

    // ===================== WA LABEL SUMMARY (I-1) =====================

    waMsgLabelBadge(slug) {
      // Color map fallback if not fetched yet
      const colors = {
        revisao:   { bg: '#e0e7ff', color: '#4338ca' },
        demanda:   { bg: '#fee2e2', color: '#b91c1c' },
        plano:     { bg: '#ffedd5', color: '#c2410c' },
        duvida:    { bg: '#dbeafe', color: '#1d4ed8' },
        call:      { bg: '#ede9fe', color: '#6d28d9' },
      };
      return colors[slug] || { bg: '#f3f4f6', color: '#374151' };
    },

    async loadMenteeLabels(menteeId) {
      if (!menteeId || this.data.menteeLabels?.[menteeId]) return;
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/wa/labels/summary?mentee_id=${menteeId}&days=30`, {
          headers: { 'Authorization': `Bearer ${this.authToken}` },
        });
        if (res.ok) {
          const labels = await res.json();
          if (Array.isArray(labels)) {
            this.data.menteeLabels = { ...this.data.menteeLabels, [menteeId]: labels.slice(0, 3) };
          }
        }
      } catch (e) {
        console.warn('[Spalla] loadMenteeLabels error:', e);
      }
    },

    // ===================== COPILOT CONTEXTUAL (I-4) =====================

    openCopilot(menteeId, menteeNome) {
      this.ui.copilotOpen = true;
      this.ui.copilotMenteeId = menteeId || null;
      this.ui.copilotMenteeNome = menteeNome || '';
      this.ui.copilotInput = '';
      this.ui.copilotHistory = [];
    },

    closeCopilot() {
      this.ui.copilotOpen = false;
      this.ui.copilotMenteeId = null;
      this.ui.copilotMenteeNome = '';
      this.ui.copilotInput = '';
      this.ui.copilotHistory = [];
    },

    async sendCopilotMessage() {
      const msg = (this.ui.copilotInput || '').trim();
      if (!msg || this.ui.copilotLoading) return;

      this.ui.copilotHistory.push({ role: 'user', content: msg });
      this.ui.copilotInput = '';
      this.ui.copilotLoading = true;

      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/copilot`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.authToken}`,
          },
          body: JSON.stringify({
            mentee_id: this.ui.copilotMenteeId,
            message: msg,
            history: this.ui.copilotHistory.slice(-6),
          }),
        });
        const data = await res.json();
        const reply = data.reply || data.error || 'Erro ao obter resposta.';
        this.ui.copilotHistory.push({ role: 'assistant', content: reply });
      } catch (e) {
        this.ui.copilotHistory.push({ role: 'assistant', content: 'Erro de conexão.' });
      } finally {
        this.ui.copilotLoading = false;
        this.$nextTick(() => {
          const el = document.getElementById('copilot-messages');
          if (el) el.scrollTop = el.scrollHeight;
        });
      }
    },

    _waFaseLabel(fase) {
      const labels = {
        onboarding: 'Onboarding',
        execucao: 'Execução',
        resultado: 'Resultado',
        renovacao: 'Renovação',
        encerrado: 'Encerrado',
      };
      return labels[fase] || fase || '—';
    },

    _waFaseBadgeStyle(fase) {
      const styles = {
        onboarding: 'background:#dbeafe;color:#1e40af',
        execucao: 'background:#d1fae5;color:#065f46',
        resultado: 'background:#ede9fe;color:#5b21b6',
        renovacao: 'background:#fef3c7;color:#92400e',
        encerrado: 'background:#f1f5f9;color:#64748b',
      };
      return styles[fase] || 'background:#f1f5f9;color:#64748b';
    },

    _waUltimoContato(m) {
      // Usa ultimo_contato_mentorado (última msg do mentorado) ou ultima_interacao (qualquer)
      const ts = m.ultimo_contato_mentorado || m.ultima_interacao;
      if (!ts) return '—';
      const diffH = (Date.now() - new Date(ts).getTime()) / 3600000;
      if (diffH < 1) return 'Agora';
      if (diffH < 24) return `${Math.floor(diffH)}h atrás`;
      const d = Math.floor(diffH / 24);
      if (d === 1) return 'Ontem';
      return `${d}d atrás`;
    },

    // ===================== WA DM v2 — S9-B =====================

    // --- SLA Timer helpers ---

    _waSlaTimerClass(horas) {
      if (horas == null || horas < 0) return 'sla-none';
      if (horas > 72) return 'sla-red';
      if (horas > 48) return 'sla-yellow';
      return 'sla-green';
    },

    _waSlaTimerText(horas) {
      if (horas == null || horas < 0) return '—';
      if (horas < 1) return `${Math.round(horas * 60)}m`;
      if (horas < 24) return `${Math.round(horas)}h`;
      const d = Math.floor(horas / 24);
      const h = Math.round(horas % 24);
      return h > 0 ? `${d}d ${h}h` : `${d}d`;
    },

    // Formata timestamp ISO para exibição no chat ("14:32", "ontem", "seg 18 mar")
    _waInboxMsgTime(ts) {
      if (!ts) return '';
      const d = new Date(ts);
      const now = new Date();
      const diffH = (now - d) / 3600000;
      if (diffH < 24 && d.getDate() === now.getDate()) {
        return d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
      }
      if (diffH < 48) return 'ontem';
      return d.toLocaleDateString('pt-BR', { weekday: 'short', day: 'numeric', month: 'short' });
    },

    // Returns true when topic badge should be shown (topic changes between consecutive msgs)
    _waInboxShouldShowTopic(messages, index) {
      if (index === 0) return !!messages[index].topic_id;
      return messages[index].topic_id &&
             messages[index].topic_id !== messages[index - 1].topic_id;
    },

    // --- Inbox View ---

    async openWaInbox(menteeId, menteeNome) {
      // Clean up any previous inbox session before overwriting
      if (this.ui.waInbox?.presenceInterval) clearInterval(this.ui.waInbox.presenceInterval);
      if (this.ui.waInbox?.presencePollInterval) clearInterval(this.ui.waInbox.presencePollInterval);
      if (this.ui.waInbox?.mentoradoId && this.ui.waInbox.mentoradoId !== menteeId) {
        await this.clearWaPresence(this.ui.waInbox.mentoradoId);
      }
      this.ui.waInbox = {
        open: true, mentoradoId: menteeId, mentoradoNome: menteeNome || '',
        messages: [], loading: true, cursor: null, hasMore: true,
        presenceInterval: null, presencePollInterval: null, others: [],
      };
      this.ui.waMessageInput = '';
      this.ui.waCanned.show = false;
      await this.loadInboxMessages(menteeId);
      await this.loadCannedResponses();
      await this.sendWaPresence(menteeId);
      this.ui.waInbox.presenceInterval = setInterval(
        () => this.sendWaPresence(menteeId), 30000
      );
      this.ui.waInbox.presencePollInterval = setInterval(
        () => this.pollWaPresence(menteeId), 15000
      );
    },

    async closeWaInbox() {
      const { mentoradoId, presenceInterval, presencePollInterval } = this.ui.waInbox;
      clearInterval(presenceInterval);
      clearInterval(presencePollInterval);
      if (mentoradoId) await this.clearWaPresence(mentoradoId);
      this.ui.waInbox = {
        open: false, mentoradoId: null, mentoradoNome: '',
        messages: [], loading: false, cursor: null, hasMore: true,
        presenceInterval: null, presencePollInterval: null, others: [],
      };
      this.ui.waCanned.show = false;
      this.ui.waMessageInput = '';
    },

    async loadInboxMessages(menteeId) {
      this.ui.waInbox.loading = true;
      try {
        // Use interacoes_mentoria (has mentorado_id + enriched data)
        const { data, error } = await sb.from('interacoes_mentoria')
          .select('id,sender_name,eh_equipe,tipo_interacao,conteudo,timestamp,topic_id')
          .eq('mentorado_id', menteeId)
          .order('timestamp', { ascending: false })
          .order('id', { ascending: false })
          .limit(50);
        if (error) throw error;
        if (this.ui.waInbox.mentoradoId !== menteeId) return; // stale guard
        const msgs = (data || []).reverse();
        this.ui.waInbox.messages = msgs;
        // composite cursor: { timestamp, id } — stable even when timestamps tie
        this.ui.waInbox.cursor   = msgs.length ? { timestamp: msgs[0].timestamp, id: msgs[0].id } : null;
        this.ui.waInbox.hasMore  = (data?.length || 0) === 50;
      } catch (e) {
        console.error('[Spalla] loadInboxMessages error:', e);
        this.ui.waInbox.messages = [];
      } finally {
        this.ui.waInbox.loading = false;
      }
    },

    async loadMoreInboxMessages() {
      const { mentoradoId, cursor, loading, hasMore } = this.ui.waInbox;
      if (!mentoradoId || !cursor || loading || !hasMore) return;
      this.ui.waInbox.loading = true;
      try {
        const { data, error } = await sb.from('interacoes_mentoria')
          .select('id,sender_name,eh_equipe,tipo_interacao,conteudo,timestamp,topic_id')
          .eq('mentorado_id', mentoradoId)
          .or(`timestamp.lt.${cursor.timestamp},and(timestamp.eq.${cursor.timestamp},id.lt.${cursor.id})`)
          .order('timestamp', { ascending: false })
          .order('id', { ascending: false })
          .limit(50);
        if (error) throw error;
        if (this.ui.waInbox.mentoradoId !== mentoradoId) return; // stale guard
        const older = (data || []).reverse();
        this.ui.waInbox.messages = [...older, ...this.ui.waInbox.messages];
        this.ui.waInbox.cursor   = older.length ? { timestamp: older[0].timestamp, id: older[0].id } : cursor;
        this.ui.waInbox.hasMore  = (data?.length || 0) === 50;
      } catch (e) {
        console.error('[Spalla] loadMoreInboxMessages error:', e);
      } finally {
        this.ui.waInbox.loading = false;
      }
    },

    // --- Presence ---

    async sendWaPresence(mentoradoId) {
      if (!mentoradoId) return;
      try {
        await fetch(`${CONFIG.API_BASE}/api/wa/presence`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.auth.accessToken}`,
          },
          body: JSON.stringify({
            mentorado_id: mentoradoId,
            user_email: this.auth?.currentUser?.email || '',
            user_name:  this.auth?.currentUser?.name  || this.auth?.currentUser?.email || '',
          }),
        });
      } catch (e) { /* best-effort */ }
    },

    async clearWaPresence(mentoradoId) {
      if (!mentoradoId) return;
      const email = encodeURIComponent(this.auth?.currentUser?.email || '');
      try {
        await fetch(
          `${CONFIG.API_BASE}/api/wa/presence?mentorado_id=${mentoradoId}&user_email=${email}`,
          { method: 'DELETE', headers: { 'Authorization': `Bearer ${this.auth.accessToken}` } }
        );
      } catch (e) { /* best-effort */ }
    },

    async pollWaPresence(mentoradoId) {
      if (!mentoradoId) return;
      try {
        const resp = await fetch(
          `${CONFIG.API_BASE}/api/wa/presence/${mentoradoId}`,
          { headers: { 'Authorization': `Bearer ${this.auth.accessToken}` } }
        );
        if (!resp.ok) return;
        const all = await resp.json();
        const myEmail = this.auth?.currentUser?.email || '';
        this.ui.waInbox.others = (Array.isArray(all) ? all : [])
          .filter(u => u.user_email !== myEmail);
      } catch (e) { /* silencioso */ }
    },

    // --- Canned Responses ---

    async loadCannedResponses() {
      if (this.data.waCannedAll?.length > 0) return; // já em cache
      try {
        const { data } = await sb.from('wa_canned_responses')
          .select('shortcode,name,content,category')
          .order('shortcode');
        this.data.waCannedAll = data || [];
      } catch (e) {
        this.data.waCannedAll = [];
      }
    },

    onWaInputKeyup(value) {
      if (value && value.startsWith('/')) {
        const q = value.slice(1).toLowerCase();
        this.ui.waCanned.filtered = (this.data.waCannedAll || []).filter(r =>
          r.shortcode.slice(1).includes(q) || r.name.toLowerCase().includes(q)
        );
        this.ui.waCanned.show = this.ui.waCanned.filtered.length > 0;
      } else {
        this.ui.waCanned.show = false;
      }
    },

    selectCannedResponse(r) {
      this.ui.waMessageInput = r.content;
      this.ui.waCanned.show  = false;
    },

    // --- Quick Reply Templates (Wave 2 F2.3) ---
    applyQuickReply(tpl) {
      const nome = this.ui.waInbox?.mentoradoNome || '';
      const menteeId = this.ui.waInbox?.mentoradoId;
      const mentee = menteeId ? this.data.mentees.find(m => m.id === menteeId) : null;
      const fase = mentee?.fase_jornada || '';
      const text = tpl.template
        .replace(/\{nome\}/g, nome)
        .replace(/\{fase\}/g, fase);
      this.ui.waMessageInput = text;
      this.ui.waQuickRepliesOpen = false;
    },

    // ===================== END WA DM v2 — S9-B =====================

    // === WA TASK EXTRACTION (S9-C) ===

    openWaTaskExtract(msg) {
      const titulo = (msg?.content_text || '').slice(0, 80);
      this.ui.waTaskExtract = { open: true, msg, titulo, prioridade: 'normal', data_fim: '', saving: false };
    },

    closeWaTaskExtract() {
      this.ui.waTaskExtract = { open: false, msg: null, titulo: '', prioridade: 'normal', data_fim: '', saving: false };
    },

    async submitWaTaskExtract() {
      const { msg, titulo, prioridade, data_fim } = this.ui.waTaskExtract;
      if (!titulo.trim()) { this.toast('Título obrigatório', 'warning'); return; }
      this.ui.waTaskExtract.saving = true;
      try {
        const mentoradoId = this.ui.waInbox?.mentoradoId || null;
        const mentee      = (this.data.mentees || []).find(m => m.id === mentoradoId);
        const payload = {
          titulo:            titulo.trim(),
          status:            'pendente',
          prioridade,
          mentorado_id:      mentoradoId,
          mentorado_nome:    mentee?.nome || null,
          source_message_id: msg?.id           || null,
          source_topic_id:   msg?.topic_id     || null,
          data_fim:          data_fim          || null,
          created_by:        this.auth?.currentUser?.email || null,
        };
        const { error } = await sb.from('god_tasks').insert(payload);
        if (error) throw error;
        this.toast('Tarefa criada!', 'success');
        this.closeWaTaskExtract();
      } catch (e) {
        console.error('[Spalla] submitWaTaskExtract error:', e);
        this.toast('Erro ao criar tarefa: ' + e.message, 'error');
      } finally {
        this.ui.waTaskExtract.saving = false;
      }
    },

    // === WA TRIAGE (S9-C) ===

    async loadWaTriage() {
      this.ui.waTriageLoading = true;
      try {
        const { data, error } = await sb
          .from('wa_topics')
          .select('id,group_jid,title,summary,last_message_at,message_count,status')
          .is('mentorado_id', null)
          .neq('status', 'archived')
          .order('last_message_at', { ascending: false });
        if (error) throw error;
        this.data.waTriageTopics = data || [];
        this.data.waTriageCount  = (data || []).length;
      } catch (e) {
        console.error('[Spalla] loadWaTriage error:', e);
        this.data.waTriageTopics = [];
        this.data.waTriageCount  = 0;
      } finally {
        this.ui.waTriageLoading = false;
      }
    },

    async assignWaTriageTopic(topicId, groupJid, mentoradoId) {
      if (!mentoradoId) return;
      this.ui.waTriageAssigning = topicId;
      try {
        const { error } = await sb.from('wa_topics')
          .update({ mentorado_id: parseInt(mentoradoId, 10) })
          .eq('id', topicId);
        if (error) throw error;
        await this.patchMentee(parseInt(mentoradoId, 10), { grupo_whatsapp_id: groupJid });
        this.toast('Tópico vinculado!', 'success');
        this.data.waTriageTopics = this.data.waTriageTopics.filter(t => t.id !== topicId);
        this.data.waTriageCount  = this.data.waTriageTopics.length;
      } catch (e) {
        console.error('[Spalla] assignWaTriageTopic error:', e);
        this.toast('Erro ao vincular: ' + e.message, 'error');
      } finally {
        this.ui.waTriageAssigning = null;
      }
    },

    // === WA SAVED SEGMENTS (S9-C) ===

    async loadWaSavedSegments() {
      const email = this.auth?.currentUser?.email || '';
      try {
        const { data } = await sb.from('wa_saved_segments')
          .select('id,name,filters,is_shared,owner_email')
          .or(`is_shared.eq.true,owner_email.eq.${email}`)
          .order('created_at', { ascending: false });
        this.data.waSavedSegments = data || [];
      } catch (e) {
        this.data.waSavedSegments = [];
      }
    },

    applyWaSegment(segment) {
      this.ui.waSavedSegmentActive      = segment.id;
      const f = segment.filters || {};
      this.ui.waPortfolioFaseFilter     = f.fase_jornada  || '';
      this.ui.waPortfolioHealthFilter   = f.health_status || '';
    },

    clearWaSegment() {
      this.ui.waSavedSegmentActive    = null;
      this.ui.waPortfolioFaseFilter   = '';
      this.ui.waPortfolioHealthFilter = '';
    },

    async saveCurrentWaSegment() {
      const name = (this.ui.waSaveSegmentModal.name || '').trim();
      if (!name) { this.toast('Nome obrigatório', 'warning'); return; }
      const filters = {};
      if (this.ui.waPortfolioFaseFilter)   filters.fase_jornada  = this.ui.waPortfolioFaseFilter;
      if (this.ui.waPortfolioHealthFilter) filters.health_status = this.ui.waPortfolioHealthFilter;
      const { error } = await sb.from('wa_saved_segments').insert({
        name, filters, is_shared: false,
        owner_email: this.auth?.currentUser?.email || '',
      });
      if (error) { this.toast('Erro ao salvar filtro', 'error'); return; }
      this.toast('Filtro salvo!', 'success');
      this.ui.waSaveSegmentModal = { open: false, name: '' };
      await this.loadWaSavedSegments();
    },

    async deleteWaSegment(id) {
      const { error } = await sb.from('wa_saved_segments').delete().eq('id', id);
      if (error) { this.toast('Erro ao remover', 'error'); return; }
      this.data.waSavedSegments = this.data.waSavedSegments.filter(s => s.id !== id);
      if (this.ui.waSavedSegmentActive === id) this.clearWaSegment();
    },

    // === TIMELINE UNIFICADA (Wave 1 F1.2) ===
    async loadTimeline(menteeId) {
      if (!sb || !menteeId) return;
      this._timelineReqId = (this._timelineReqId || 0) + 1;
      const reqId = this._timelineReqId;
      this.data.timeline = [];
      try {
        const { data, error } = await sb
          .from('vw_god_timeline')
          .select('*')
          .eq('mentorado_id', menteeId)
          .order('data', { ascending: false })
          .limit(50);
        if (reqId !== this._timelineReqId) return; // stale response
        if (error) { console.warn('[Spalla] loadTimeline:', error.message); return; }
        this.data.timeline = data || [];
      } catch (e) {
        if (reqId === this._timelineReqId) console.warn('[Spalla] loadTimeline exception:', e);
      }
    },

    // ===== LF Modo EU: tela default do operador =====
    async loadMeuTrabalho() {
      this.meuTrabalhoLoading = true;
      try {
        // Resolve nome com múltiplos fallbacks
        let me = (this.auth.currentUser?.full_name || this.auth.currentUser?.user_metadata?.full_name || '').toLowerCase().split(' ')[0];
        if (!me) me = (this.auth.currentUser?.email || '').toLowerCase().split(/[@.]/)[0];
        if (!me) me = 'kaique';
        const member = TEAM_MEMBERS.find(m => m.id === me || m.name.toLowerCase() === me);
        const searchName = member ? member.id : me;

        // Usa data.tasks (já carregado) em vez de query separada ao vw_meu_trabalho
        // Isso elimina a intermitência (race condition, query falhando, etc.)
        const allTasks = this.data.tasks || [];
        this.meuTrabalho = allTasks.filter(t => {
          if (t.status === 'arquivada' || t.status === 'cancelada') return false;
          const r = (t.responsavel || '').toLowerCase();
          const a = (t.acompanhante || '').toLowerCase();
          return r.includes(searchName) || a.includes(searchName);
        });
        console.log('[MeuTrabalho] filtered', this.meuTrabalho.length, 'tasks from', allTasks.length, 'for:', searchName);
      } catch (e) {
        console.warn('[Spalla] loadMeuTrabalho:', e);
        this.meuTrabalho = [];
      } finally {
        this.meuTrabalhoLoading = false;
      }
    },

    // Dragon 53: Bulk edit helpers for Meu Trabalho
    bulkToggle(taskId) {
      if (this.ui.bulkSelected[taskId]) delete this.ui.bulkSelected[taskId];
      else this.ui.bulkSelected[taskId] = true;
    },
    bulkSelectAll() {
      const tasks = this.meuTrabalhoFiltered || [];
      tasks.forEach(t => { this.ui.bulkSelected[t.id] = true; });
    },
    bulkClearAll() {
      this.ui.bulkSelected = {};
    },
    get bulkCount() {
      return Object.keys(this.ui.bulkSelected).length;
    },
    async bulkUpdateField(field, value) {
      const ids = Object.keys(this.ui.bulkSelected);
      if (!ids.length) return this.toast('Nenhuma tarefa selecionada', 'info');
      for (const id of ids) {
        await this.updateTaskField(id, field, value);
      }
      this.toast(`${ids.length} tarefa(s) atualizada(s)`, 'success');
      this.ui.bulkSelected = {};
      this.ui.bulkMode = false;
      this.loadMeuTrabalho();
    },
    async bulkUpdateStatus(newStatus) {
      const ids = Object.keys(this.ui.bulkSelected);
      if (!ids.length) return this.toast('Nenhuma tarefa selecionada', 'info');
      for (const id of ids) {
        await this.updateTaskStatus(id, newStatus);
      }
      this.toast(`${ids.length} tarefa(s) → ${newStatus}`, 'success');
      this.ui.bulkSelected = {};
      this.ui.bulkMode = false;
      this.loadMeuTrabalho();
    },

    get meuTrabalhoQuickFilters() {
      const all = this.meuTrabalho || [];
      const now = new Date(); now.setHours(0,0,0,0);
      const weekEnd = new Date(now); weekEnd.setDate(weekEnd.getDate() + (7 - weekEnd.getDay()));
      const pendentes = all.filter(t => t.status !== 'concluida' && t.status !== 'cancelada' && t.status !== 'arquivada');
      const atrasadas = all.filter(t => t.atrasada);
      const semana = all.filter(t => {
        if (!t.data_fim) return false;
        const d = new Date(t.data_fim + 'T00:00:00');
        return d >= now && d <= weekEnd;
      });
      const bloqueadas = all.filter(t => t.status === 'bloqueada' || t.bloqueada_por_dependencia);
      return [
        { key: 'all', label: 'Todas', count: all.length },
        { key: 'pendentes', label: 'Ativas', count: pendentes.length },
        { key: 'atrasadas', label: 'Atrasadas', count: atrasadas.length },
        { key: 'semana', label: 'Esta semana', count: semana.length },
        { key: 'bloqueadas', label: 'Bloqueadas', count: bloqueadas.length },
      ];
    },

    get meuTrabalhoFiltered() {
      let items = this.meuTrabalho || [];
      const f = this.meuTrabalhoFilter;
      const now = new Date(); now.setHours(0,0,0,0);
      const weekEnd = new Date(now); weekEnd.setDate(weekEnd.getDate() + (7 - weekEnd.getDay()));
      if (f === 'pendentes') items = items.filter(t => t.status !== 'concluida' && t.status !== 'cancelada' && t.status !== 'arquivada');
      else if (f === 'atrasadas') items = items.filter(t => t.atrasada);
      else if (f === 'semana') items = items.filter(t => { if (!t.data_fim) return false; const d = new Date(t.data_fim+'T00:00:00'); return d >= now && d <= weekEnd; });
      else if (f === 'bloqueadas') items = items.filter(t => t.status === 'bloqueada' || t.bloqueada_por_dependencia);
      if (this.meuTrabalhoHideDone) items = items.filter(t => t.status !== 'concluida');
      // Sort: urgente > alta > normal > baixa, then atrasadas first
      const prioOrder = { urgente: 0, alta: 1, normal: 2, baixa: 3 };
      items.sort((a, b) => {
        if (a.atrasada && !b.atrasada) return -1;
        if (!a.atrasada && b.atrasada) return 1;
        return (prioOrder[a.prioridade] || 2) - (prioOrder[b.prioridade] || 2);
      });
      return items;
    },

    get meuTrabalhoGrouped() {
      const items = this.meuTrabalhoFiltered;
      const by = this.meuTrabalhoGroupBy;
      if (!by) return [{ key: 'all', label: '', tasks: items }];
      const map = {};
      const order = [];
      const labels = {
        pendente: 'Pendente', em_andamento: 'Em andamento', em_revisao: 'Em revisao',
        bloqueada: 'Bloqueada', pausada: 'Pausada', concluida: 'Concluida',
        urgente: 'Urgente', alta: 'Alta', normal: 'Normal', baixa: 'Baixa',
      };
      for (const t of items) {
        let key;
        if (by === 'status') key = t.status || 'pendente';
        else if (by === 'mentorado') key = t.mentorado_nome || 'Interno / Sem mentorado';
        else if (by === 'prioridade') key = t.prioridade || 'normal';
        else key = t.status || 'pendente';
        if (!map[key]) { map[key] = []; order.push(key); }
        map[key].push(t);
      }
      // Fixed order for status/priority
      let keys = order;
      if (by === 'status') keys = ['pendente','em_andamento','em_revisao','bloqueada','pausada','concluida'].filter(k => map[k]);
      else if (by === 'prioridade') keys = ['urgente','alta','normal','baixa'].filter(k => map[k]);
      for (const k of order) { if (!keys.includes(k)) keys.push(k); }
      return keys.map(k => ({ key: k, label: labels[k] || k, tasks: map[k] || [] }));
    },

    // ===== SPRINT DASHBOARD =====
    async loadSprintDashboard() {
      this.sprintLoading = true;
      try {
        if (!sb) sb = await initSupabase();
        const { data, error } = await sb
          .from('vw_sprint_dashboard')
          .select('*')
          .order('sprint_inicio', { ascending: false })
          .limit(20);
        if (error) throw error;
        this.sprintDashboard = data || [];
        const active = (data || []).find(s => s.sprint_status === 'ativo');
        if (active) this.selectSprint(active.sprint_id);
      } catch (e) {
        console.warn('[Spalla] loadSprintDashboard:', e);
      } finally {
        this.sprintLoading = false;
      }
    },

    async selectSprint(sprintId) {
      this.sprintActive = this.sprintDashboard.find(s => s.sprint_id === sprintId) || null;
      try {
        if (!sb) sb = await initSupabase();
        const { data, error } = await sb
          .from('god_tasks')
          .select('*')
          .eq('sprint_id', sprintId)
          .order('prioridade', { ascending: true })
          .order('data_fim', { ascending: true, nullsFirst: false })
          .limit(500);
        if (error) throw error;
        this.sprintTasks = data || [];
      } catch (e) {
        console.warn('[Spalla] selectSprint:', e);
        this.sprintTasks = [];
      }
    },

    get sprintTasksGrouped() {
      const tasks = this.sprintTasks || [];
      const by = this.sprintGroupBy;
      const groups = {};
      const order = [];
      for (const t of tasks) {
        let key;
        if (by === 'status') key = t.status || 'pendente';
        else if (by === 'responsavel') key = t.responsavel || 'sem responsavel';
        else if (by === 'prioridade') key = t.prioridade || 'normal';
        else if (by === 'mentorado') key = t.mentorado_nome || 'Interno';
        else key = t.status || 'pendente';
        if (!groups[key]) { groups[key] = []; order.push(key); }
        groups[key].push(t);
      }
      return order.map(key => ({ key, tasks: groups[key] }));
    },

    async addTaskToSprint(taskId) {
      if (!this.sprintActive || !sb) return;
      try {
        await sb.from('god_tasks').update({ sprint_id: this.sprintActive.sprint_id }).eq('id', taskId);
        this.selectSprint(this.sprintActive.sprint_id);
        this.toast?.('Task adicionada ao sprint');
      } catch (e) {
        this.toast?.('Erro: ' + e.message, 'error');
      }
    },

    async removeTaskFromSprint(taskId) {
      if (!sb) return;
      try {
        await sb.from('god_tasks').update({ sprint_id: null }).eq('id', taskId);
        this.sprintTasks = this.sprintTasks.filter(t => t.id !== taskId);
        this.toast?.('Task removida do sprint');
      } catch (e) {
        this.toast?.('Erro: ' + e.message, 'error');
      }
    },

    // ===== LF-FASE3: Criar descarrego direto pelo frontend =====
    openDescarregoCreate() {
      this.ui.descarregoModal = {
        open: true, tipo: 'texto', texto: '',
        audioBlob: null, audioUrl: null,
        recording: false, recordingSeconds: 0, submitting: false,
        _mediaRecorder: null, _stream: null, _interval: null,
      };
    },

    closeDescarregoCreate() {
      const m = this.ui.descarregoModal;
      if (m?._stream) m._stream.getTracks().forEach(t => t.stop());
      if (m?._interval) clearInterval(m._interval);
      if (m?.audioUrl) URL.revokeObjectURL(m.audioUrl);
      this.ui.descarregoModal = { open: false };
    },

    async startDescarregoRecording() {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        const recorder = new MediaRecorder(stream);
        const chunks = [];
        recorder.ondataavailable = e => chunks.push(e.data);
        recorder.onstop = () => {
          const blob = new Blob(chunks, { type: 'audio/webm' });
          this.ui.descarregoModal.audioBlob = blob;
          this.ui.descarregoModal.audioUrl = URL.createObjectURL(blob);
        };
        recorder.start();
        this.ui.descarregoModal._mediaRecorder = recorder;
        this.ui.descarregoModal._stream = stream;
        this.ui.descarregoModal.recording = true;
        this.ui.descarregoModal.recordingSeconds = 0;
        this.ui.descarregoModal._interval = setInterval(() => {
          this.ui.descarregoModal.recordingSeconds += 1;
        }, 1000);
      } catch (e) {
        this.toast?.('Erro ao acessar microfone: ' + e.message, 'error');
      }
    },

    stopDescarregoRecording() {
      const m = this.ui.descarregoModal;
      if (m?._mediaRecorder?.state === 'recording') m._mediaRecorder.stop();
      if (m?._stream) m._stream.getTracks().forEach(t => t.stop());
      if (m?._interval) clearInterval(m._interval);
      m.recording = false;
      m._mediaRecorder = null;
      m._stream = null;
      m._interval = null;
    },

    resetDescarregoAudio() {
      const m = this.ui.descarregoModal;
      if (m?.audioUrl) URL.revokeObjectURL(m.audioUrl);
      m.audioBlob = null;
      m.audioUrl = null;
      m.recordingSeconds = 0;
    },

    async submitDescarregoCreate() {
      const m = this.ui.descarregoModal;
      const menteeId = this.data.detail?.profile?.id;
      if (!menteeId) { this.toast?.('Sem mentorado selecionado', 'error'); return; }
      m.submitting = true;
      try {
        let arquivoUrl = null, arquivoMime = null, arquivoSize = null;
        if (m.tipo === 'audio' && m.audioBlob) {
          if (!this.supabase) sb = await initSupabase();
          const path = `descarregos/${menteeId}/${Date.now()}.webm`;
          const { error: upErr } = await this.supabase.storage.from('uploads').upload(path, m.audioBlob, { contentType: 'audio/webm' });
          if (upErr) throw upErr;
          const { data: urlData } = this.supabase.storage.from('uploads').getPublicUrl(path);
          arquivoUrl = urlData.publicUrl;
          arquivoMime = 'audio/webm';
          arquivoSize = m.audioBlob.size;
        }

        const body = {
          mentorado_id: menteeId,
          tipo_bruto: m.tipo === 'audio' ? 'audio' : 'texto',
          conteudo_bruto: m.tipo === 'texto' ? m.texto : null,
          arquivo_url: arquivoUrl,
          arquivo_mime_type: arquivoMime,
          arquivo_size_bytes: arquivoSize,
          fonte: 'web_drawer',
        };

        const r = await fetch(`${CONFIG.API_BASE}/api/descarrego/capture`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.token || ''}` },
          body: JSON.stringify(body),
        });
        if (!r.ok) throw new Error(`HTTP ${r.status}: ${await r.text()}`);
        const created = await r.json();
        const descarregoId = created.descarrego_id;

        await fetch(`${CONFIG.API_BASE}/api/descarrego/${descarregoId}/process`, {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${this.auth.token || ''}` },
        });

        this.toast?.('Descarrego capturado — processando');
        this.closeDescarregoCreate();
        await this.loadMenteeDescarregos(menteeId);
        this._pollDescarrego(descarregoId);
      } catch (e) {
        console.error('[descarrego_create]', e);
        this.toast?.('Falha: ' + e.message, 'error');
      } finally {
        if (this.ui.descarregoModal) this.ui.descarregoModal.submitting = false;
      }
    },

    // ===== LF Story 4: helpers de espécie =====
    rebuildRrule() {
      const f = this.taskForm.rrule_freq || 'DAILY';
      const i = this.taskForm.rrule_interval || 1;
      this.taskForm.rrule = `FREQ=${f};INTERVAL=${i}`;
    },

    async _createTriggerRule(taskId, spec) {
      try {
        if (!this.supabase) sb = await initSupabase();
        let filter = {};
        if (spec.filter) {
          try { filter = JSON.parse(spec.filter); } catch { filter = {}; }
        }
        await this.supabase.from('task_trigger_rules').insert({
          nome: this.taskForm.titulo || 'Regra de trigger',
          when_aggregate_type: spec.aggregate,
          when_event_type: spec.event,
          when_payload_filter: filter,
          then_template: {
            titulo: this.taskForm.titulo,
            descricao: this.taskForm.descricao,
            responsavel: this.taskForm.responsavel,
            prioridade: this.taskForm.prioridade,
          },
          ativa: true,
          origem: 'manual',
        });
      } catch (e) {
        console.warn('[trigger_rule]', e);
        this.toast?.('Task criada mas regra de trigger falhou: ' + e.message, 'warning');
      }
    },

    // Batch descarrego import
    async submitBatchDescarrego() {
      const menteeId = this.data.detail?.profile?.id;
      if (!menteeId) return this.toast?.('Sem mentorado selecionado', 'error');
      const rawText = (this.ui.batchDescarregoText || '').trim();
      if (!rawText) return this.toast?.('Cole os textos para importar', 'error');

      // Split by double newline or "---" separator
      const items = rawText.split(/\n{2,}|^---$/m)
        .map(t => t.trim())
        .filter(t => t.length > 5);

      if (!items.length) return this.toast?.('Nenhum item válido encontrado', 'error');
      if (items.length > 20) return this.toast?.('Máximo 20 itens por batch', 'error');

      this.ui.batchDescarregoSubmitting = true;
      try {
        const r = await fetch(`${CONFIG.API_BASE}/api/descarrego/batch-capture`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.token || ''}` },
          body: JSON.stringify({
            mentorado_id: menteeId,
            auto_process: true,
            items: items.map(text => ({ tipo_bruto: 'texto', conteudo_bruto: text, fonte: 'batch_import' })),
          }),
        });
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        const result = await r.json();
        this.toast?.(`${result.created} descarregos importados e processando`, 'success');
        this.ui.batchDescarregoText = '';
        this.ui.batchDescarregoOpen = false;
        this.loadMenteeDescarregos(menteeId);
      } catch (e) {
        this.toast?.('Falha no batch import: ' + e.message, 'error');
      } finally {
        this.ui.batchDescarregoSubmitting = false;
      }
    },

    // ===== LF-FASE3: Descarregos pipeline =====
    async loadMenteeDescarregos(menteeId) {
      if (!menteeId) return;
      this.data.menteeDescarregos = [];
      try {
        const r = await fetch(`${CONFIG.API_BASE}/api/mentees/${menteeId}/descarregos`, {
          headers: { 'Authorization': `Bearer ${this.auth.token || ''}` },
        });
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        const body = await r.json();
        this.data.menteeDescarregos = body.descarregos || [];
      } catch (e) { console.warn('[Spalla] loadMenteeDescarregos:', e); }
    },

    async processDescarrego(descarregoId) {
      try {
        const r = await fetch(`${CONFIG.API_BASE}/api/descarrego/${descarregoId}/process`, {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${this.auth.token || ''}` },
        });
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        this.toast?.('Processamento iniciado');
        // Poll até status mudar
        this._pollDescarrego(descarregoId);
      } catch (e) {
        this.toast?.('Falha ao processar: ' + e.message, 'error');
      }
    },

    async approveDescarrego(descarregoId) {
      try {
        const r = await fetch(`${CONFIG.API_BASE}/api/descarrego/${descarregoId}/approve`, {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${this.auth.token || ''}` },
        });
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        this.toast?.('Aprovado — executando ação');
        this._pollDescarrego(descarregoId);
      } catch (e) {
        this.toast?.('Falha ao aprovar: ' + e.message, 'error');
      }
    },

    async rejectDescarrego(descarregoId) {
      if (!confirm('Rejeitar este descarrego?')) return;
      try {
        const r = await fetch(`${CONFIG.API_BASE}/api/descarrego/${descarregoId}/reject`, {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${this.auth.token || ''}` },
        });
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        this.toast?.('Rejeitado');
        const menteeId = this.data.detail?.profile?.id;
        if (menteeId) this.loadMenteeDescarregos(menteeId);
      } catch (e) {
        this.toast?.('Falha ao rejeitar: ' + e.message, 'error');
      }
    },

    _pollDescarrego(descarregoId, tries = 0) {
      if (tries > 30) return; // max ~90s
      setTimeout(async () => {
        const menteeId = this.data.detail?.profile?.id;
        if (!menteeId) return;
        await this.loadMenteeDescarregos(menteeId);
        const d = (this.data.menteeDescarregos || []).find(x => x.id === descarregoId);
        const terminal = ['finalizado', 'rejeitado', 'erro', 'aguardando_humano'];
        if (d && !terminal.includes(d.status)) {
          this._pollDescarrego(descarregoId, tries + 1);
        }
      }, 3000);
    },

    // Descarrego filter + reclassification
    get filteredDescarregos() {
      const list = this.data.menteeDescarregos || [];
      const f = this.ui.descarregoFilter || 'todos';
      if (f === 'todos') return list;
      if (f === 'pendentes') return list.filter(d => ['capturado', 'aguardando_humano', 'erro'].includes(d.status));
      if (f === 'processados') return list.filter(d => ['finalizado', 'rejeitado'].includes(d.status));
      return list.filter(d => d.classificacao_principal === f);
    },

    async reclassifyDescarrego(descarregoId, newType) {
      try {
        const r = await fetch(`${CONFIG.API_BASE}/api/descarrego/${descarregoId}/reclassify`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.token || ''}` },
          body: JSON.stringify({ new_type: newType }),
        });
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        this.toast?.('Reclassificado para ' + newType);
        const menteeId = this.data.detail?.profile?.id;
        if (menteeId) this.loadMenteeDescarregos(menteeId);
      } catch (e) {
        this.toast?.('Falha ao reclassificar: ' + e.message, 'error');
      }
    },

    // ===== CONTEXT HUB: áudio, texto, anexos para dossiê =====
    async loadMenteeWaIntel(menteeId) {
      if (!menteeId) return;
      this.data._menteeWaActivity = [];
      try {
        const { data, error } = await sb.from('vw_wa_mentee_activity')
          .select('*')
          .eq('mentorado_id', menteeId)
          .order('activity_at', { ascending: false })
          .limit(100);
        if (error) console.warn('[Spalla] loadMenteeWaIntel:', error.message);
        if (data) this.data._menteeWaActivity = data;
      } catch (e) { console.warn('[Spalla] loadMenteeWaIntel:', e); }
    },

    async loadMenteeContext(menteeId) {
      if (!menteeId) return;
      this.data.menteeContext = [];
      try {
        const { data, error } = await sb.from('mentorado_context')
          .select('*')
          .eq('mentorado_id', menteeId)
          .eq('ativo', true)
          .order('created_at', { ascending: false });
        if (data) this.data.menteeContext = data;
      } catch (e) { console.warn('[Spalla] loadMenteeContext:', e); }
    },

    async saveContext() {
      const menteeId = this.data.detail?.profile?.id || this.descarrego?.menteeId;
      if (!menteeId) return;
      this.ui.ctxSaving = true;
      try {
        const record = {
          mentorado_id: menteeId,
          tipo: this.ui.ctxTipo || 'texto',
          titulo: this.ui.ctxTitulo || '',
          conteudo: this.ui.ctxConteudo || '',
          fase: this.ui.ctxFase || 'onboarding',
          criado_por: this.auth.currentUser?.email || '',
        };

        // Link tipo: store URL in link_url
        if (this.ui.ctxTipo === 'link' && this.ui.ctxLinkUrl) {
          record.link_url = this.ui.ctxLinkUrl;
          if (!record.conteudo) record.conteudo = this.ui.ctxLinkUrl;
        }

        // Upload file if present (arquivo, audio or gravacao)
        if (this.ui.ctxArquivo) {
          const file = this.ui.ctxArquivo;
          const MAX_SIZE = 100 * 1024 * 1024; // 100 MB
          if (file.size > MAX_SIZE) throw new Error('Arquivo muito grande (máx 100 MB)');
          const path = `context/${menteeId}/${Date.now()}_${file.name}`;
          const { error: uploadError } = await sb.storage.from('uploads').upload(path, file);
          if (uploadError) throw uploadError;
          const { data: urlData } = sb.storage.from('uploads').getPublicUrl(path);
          if (!urlData?.publicUrl) throw new Error('Falha ao obter URL do arquivo');
          record.arquivo_url = urlData.publicUrl;
          record.arquivo_nome = file.name;
          record.arquivo_tipo = file.type;
          record.arquivo_tamanho = file.size;
        }

        const { data: inserted, error } = await sb.from('mentorado_context').insert(record).select('id').single();
        if (error) throw error;

        // Reset form
        this.ui.ctxTitulo = '';
        this.ui.ctxConteudo = '';
        this.ui.ctxArquivo = null;
        this.ui.ctxLinkUrl = '';
        this.toast('Contexto adicionado', 'success');
        await this.loadMenteeContext(menteeId);

        // Auto-transcribe — passa arquivo_url diretamente (não busca no array para evitar race)
        if (inserted?.id && ['audio', 'gravacao'].includes(record.tipo) && record.arquivo_url) {
          this._autoTranscribeWithUrl(inserted.id, record.arquivo_url);
        }
      } catch (e) {
        console.error('[Spalla] saveContext:', e);
        this.toast('Erro ao salvar: ' + e.message, 'error');
      }
      this.ui.ctxSaving = false;
    },

    async deleteContext(ctxId) {
      if (!confirm('Excluir este contexto permanentemente?')) return;
      try {
        await sb.from('mentorado_context').delete().eq('id', ctxId);
        this.data.menteeContext = this.data.menteeContext.filter(c => c.id !== ctxId);
        this.toast('Contexto excluido', 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },

    async archiveContext(ctxId) {
      try {
        await sb.from('mentorado_context').update({ ativo: false }).eq('id', ctxId);
        this.data.menteeContext = this.data.menteeContext.filter(c => c.id !== ctxId);
        this.toast('Contexto arquivado', 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },

    async archiveAllContext() {
      const items = this.filteredMenteeContext;
      if (!items.length) return;
      if (!confirm(`Arquivar ${items.length} contexto(s)? Eles nao serao excluidos, apenas ocultados.`)) return;
      try {
        const ids = items.map(c => c.id);
        await sb.from('mentorado_context').update({ ativo: false }).in('id', ids);
        this.data.menteeContext = this.data.menteeContext.filter(c => !ids.includes(c.id));
        this.toast(`${ids.length} contexto(s) arquivado(s)`, 'success');
      } catch (e) { this.toast('Erro: ' + e.message, 'error'); }
    },

    async archiveContextOnDossieDelivery(menteeId) {
      // Called when last dossiê is delivered — archives all context
      try {
        await sb.from('mentorado_context')
          .update({ ativo: false })
          .eq('mentorado_id', menteeId);
      } catch (e) { console.warn('[Spalla] archiveContext:', e); }
    },

    // Context Hub — inline edit
    ctxStartEdit(ctx) {
      this.ui.ctxEditing = { ...this.ui.ctxEditing, [ctx.id]: { titulo: ctx.titulo || '', conteudo: ctx.conteudo || '', fase: ctx.fase || 'geral' } };
    },
    ctxCancelEdit(ctxId) {
      const e = { ...this.ui.ctxEditing };
      delete e[ctxId];
      this.ui.ctxEditing = e;
    },
    async ctxSaveEdit(ctxId) {
      const edit = this.ui.ctxEditing[ctxId];
      if (!edit) return;
      try {
        const { error } = await sb.from('mentorado_context')
          .update({ titulo: edit.titulo, conteudo: edit.conteudo, fase: edit.fase })
          .eq('id', ctxId);
        if (error) throw error;
        const idx = this.data.menteeContext.findIndex(c => c.id === ctxId);
        if (idx >= 0) {
          this.data.menteeContext[idx] = { ...this.data.menteeContext[idx], titulo: edit.titulo, conteudo: edit.conteudo, fase: edit.fase };
        }
        this.ctxCancelEdit(ctxId);
        this.toast('Contexto atualizado', 'success');
      } catch (e) {
        this.toast('Erro ao salvar: ' + e.message, 'error');
      }
    },

    // Context Hub — toggle expand
    ctxToggle(ctxId) {
      this.ui.ctxExpanded = { ...this.ui.ctxExpanded, [ctxId]: !this.ui.ctxExpanded[ctxId] };
    },

    // Context Hub — filtered list (used in x-for)
    get filteredMenteeContext() {
      let items = this.data.menteeContext || [];
      const f = this.ui.ctxFilter;
      if (f.tipo !== 'all') items = items.filter(c => c.tipo === f.tipo);
      if (f.fase !== 'all') items = items.filter(c => c.fase === f.fase);
      return items;
    },

    // Context Hub — audio recording via MediaRecorder
    async startRecording() {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        this.ui.ctxRecordingChunks = [];
        this.ui.ctxRecordingSeconds = 0;
        const mr = new MediaRecorder(stream);
        this.ui.ctxMediaRecorder = mr;
        mr.ondataavailable = (e) => { if (e.data.size > 0) this.ui.ctxRecordingChunks.push(e.data); };
        mr.onstop = () => this._onRecordingStop(stream);
        mr.start(200);
        this.ui.ctxRecording = true;
        this.ui.ctxRecordingTimer = setInterval(() => { this.ui.ctxRecordingSeconds++; }, 1000);
      } catch (e) {
        this.toast('Microfone não disponível: ' + e.message, 'error');
      }
    },

    stopRecording() {
      if (this.ui.ctxMediaRecorder && this.ui.ctxRecording) {
        clearInterval(this.ui.ctxRecordingTimer);
        this.ui.ctxMediaRecorder.stop();
        this.ui.ctxRecording = false;
      }
    },

    async _onRecordingStop(stream) {
      stream.getTracks().forEach(t => t.stop());
      const blob = new Blob(this.ui.ctxRecordingChunks, { type: 'audio/webm' });
      const ts = new Date().toLocaleString('pt-BR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' }).replace(',', '');
      const file = new File([blob], `gravacao_${Date.now()}.webm`, { type: 'audio/webm' });
      this.ui.ctxArquivo = file;
      this.ui.ctxTipo = 'gravacao';
      if (!this.ui.ctxTitulo) this.ui.ctxTitulo = `Gravacao ${ts}`;
      // Auto-save after recording stops (triggered by "Parar e salvar" button)
      this.toast('Salvando gravacao...', 'info');
      await this.saveContext();
    },

    // Context Hub — transcribe an existing audio context card
    async transcribeContext(ctxId) {
      const ctx = (this.data.menteeContext || []).find(c => c.id === ctxId);
      if (!ctx?.arquivo_url) { this.toast('Sem arquivo de áudio para transcrever', 'warn'); return; }
      this.ui.ctxTranscribing = { ...this.ui.ctxTranscribing, [ctxId]: true };
      try {
        const resp = await fetch(`${CONFIG.API_BASE}/api/context/transcribe`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken || localStorage.getItem('spalla_access_token') || ''}` },
          body: JSON.stringify({ arquivo_url: ctx.arquivo_url }),
        });
        const result = await resp.json();
        if (result.error) throw new Error(result.error);
        await sb.from('mentorado_context').update({ transcricao: result.transcricao }).eq('id', ctxId);
        const idx = (this.data.menteeContext || []).findIndex(c => c.id === ctxId);
        if (idx >= 0) this.data.menteeContext[idx] = { ...this.data.menteeContext[idx], transcricao: result.transcricao };
        this.toast('Transcrição concluída!', 'success');
      } catch (e) {
        this.toast('Erro na transcrição: ' + e.message, 'error');
      }
      const t = { ...this.ui.ctxTranscribing };
      delete t[ctxId];
      this.ui.ctxTranscribing = t;
    },

    // Context Hub — auto-transcribe after saving (usa URL direto, sem depender do array carregado)
    async _autoTranscribeWithUrl(ctxId, arquivoUrl) {
      this.ui.ctxTranscribing = { ...this.ui.ctxTranscribing, [ctxId]: true };
      try {
        const resp = await fetch(`${CONFIG.API_BASE}/api/context/transcribe`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken || localStorage.getItem('spalla_access_token') || ''}` },
          body: JSON.stringify({ arquivo_url: arquivoUrl }),
        });
        const result = await resp.json();
        if (result.error) throw new Error(result.error);
        await sb.from('mentorado_context').update({ transcricao: result.transcricao }).eq('id', ctxId);
        const idx = (this.data.menteeContext || []).findIndex(c => c.id === ctxId);
        if (idx >= 0) this.data.menteeContext[idx] = { ...this.data.menteeContext[idx], transcricao: result.transcricao };
        this.toast('Transcrição concluída!', 'success');
      } catch (e) {
        this.toast('Transcrição automática falhou: ' + e.message, 'warn');
      }
      const t = { ...this.ui.ctxTranscribing }; delete t[ctxId]; this.ui.ctxTranscribing = t;
    },

    // Context Hub — auto-transcribe para itens já salvos (busca no array)
    async _autoTranscribeIfNeeded(ctxId) {
      const ctx = (this.data.menteeContext || []).find(c => c.id === ctxId);
      if (!ctx || !['audio', 'gravacao'].includes(ctx.tipo) || !ctx.arquivo_url || ctx.transcricao) return;
      await this._autoTranscribeWithUrl(ctxId, ctx.arquivo_url);
    },

    // ===== DESCARREGO PAGE helpers =====

    get descarregoMenteeList() {
      const q = (this.descarrego.search || '').toLowerCase().trim();
      const list = this.data.mentees || [];
      if (!q) return list;
      return list.filter(m => (m.nome || '').toLowerCase().includes(q) || (m.instagram || '').toLowerCase().includes(q));
    },

    async selectDescarregoMentee(m) {
      this.descarrego.menteeId = m.id;
      this.descarrego.menteeName = m.nome;
      this.ui.ctxTipo = 'texto';
      this.ui.ctxTitulo = '';
      this.ui.ctxConteudo = '';
      this.ui.ctxLinkUrl = '';
      this.ui.ctxArquivo = null;
      this.ui.ctxFase = 'onboarding';
      await this.loadMenteeContext(m.id);
    },

    handleDescarregoDrop(event) {
      this.descarrego.dragging = false;
      const file = event.dataTransfer?.files?.[0];
      if (file) this.ui.ctxArquivo = file;
    },

    _ctxTipoStyle(tipo) {
      const map = {
        texto:    'background:#e8f4f0;color:#1a6b5a',
        audio:    'background:#fef3e2;color:#9a6400',
        gravacao: 'background:#fce8e8;color:#c0392b',
        link:     'background:#e8eeff;color:#2a4fba',
        arquivo:  'background:#f0ece8;color:#5a4a3a',
        imagem:   'background:#f4e8f4;color:#7a2a8a',
        video:    'background:#e8f0f4;color:#1a5a8a',
        documento:'background:#f0ece8;color:#5a4a3a',
      };
      return map[tipo] || 'background:var(--op-bg-1);color:var(--op-text-muted)';
    },

    _ctxTipoLabel(tipo) {
      const map = { texto:'TEXTO', audio:'ÁUDIO', gravacao:'GRAV.', link:'LINK', arquivo:'ARQ.', imagem:'IMG', video:'VÍDEO', documento:'DOC' };
      return map[tipo] || (tipo || '').toUpperCase();
    },

    _formatRecSeconds(s) {
      const m = Math.floor(s / 60);
      const sec = s % 60;
      return String(m).padStart(2,'0') + ':' + String(sec).padStart(2,'0');
    },

    // ===== S2: Save WA message as Context (ativo) =====

    // Resolve mentorado from chat context (reused by both save functions)
    _resolveWaMentee(chatJid, chatName) {
      let menteeId = null, menteeName = '';
      // Strategy 1: wa_groups linked
      const group = (this.data.waGroups || []).find(g => g.group_jid === chatJid);
      if (group?.mentorado_id) {
        menteeId = group.mentorado_id;
        menteeName = this.data.mentees.find(m => m.id == menteeId)?.nome || '';
      }
      // Strategy 2: fuzzy match chat name
      if (!menteeId && chatName) {
        const cn = chatName.toLowerCase();
        for (const m of this.data.mentees) {
          const nome = m.nome.toLowerCase();
          const first = nome.split(' ')[0];
          if (cn.includes(nome) || (first.length > 3 && cn.includes(first) && (cn.includes('case') || cn.includes('mentory') || cn.includes('clinic')))) {
            menteeId = m.id; menteeName = m.nome; break;
          }
        }
      }
      // Strategy 3: grupo_whatsapp_id
      if (!menteeId) {
        const m = this.data.mentees.find(m => m.grupo_whatsapp_id === chatJid);
        if (m) { menteeId = m.id; menteeName = m.nome; }
      }
      return { menteeId, menteeName };
    },

    // Open save-to-context modal (WA main page)
    saveWaMsgAsContext(msg) {
      const chat = this.ui.whatsappSelectedChat;
      const chatJid = chat?.remoteJid || chat?.id;
      const { menteeId, menteeName } = this._resolveWaMentee(chatJid, this.getWaChatName(chat));
      if (!menteeId) { this.toast('Mentorado nao detectado pra este grupo', 'error'); return; }
      const msgType = this.getWaMessageType(msg);
      const tipoMap = { text: 'texto', audio: 'audio', image: 'imagem', video: 'video', document: 'documento' };
      this.ui.ctxSaveData = {
        menteeId, menteeName,
        tipo: tipoMap[msgType] || 'texto',
        msgText: this.getWaMessageText(msg),
        mediaUrl: this.waMediaUrls?.[msg.key?.id] || null,
        msgId: msg.key?.id || null,
        chatJid,
        sender: msg.pushName || '',
        source: 'wa_main',
      };
      this.ui.ctxSaveDesc = this.getWaMessageText(msg)?.substring(0, 200) || '';
      this.ui.ctxSavePasta = '';
      this.ui.ctxSaveModal = true;
    },

    // Open save-to-context modal (WA detail tab in ficha)
    saveDetailWaMsgAsContext(msg) {
      const menteeId = this.data.detail?.profile?.id;
      const menteeName = this.data.detail?.profile?.nome || '';
      if (!menteeId) { this.toast('Mentorado nao identificado', 'error'); return; }
      const tipoMap = { text: 'texto', audio: 'audio', image: 'imagem', video: 'video', document: 'documento' };
      this.ui.ctxSaveData = {
        menteeId, menteeName,
        tipo: tipoMap[msg.content_type] || 'texto',
        msgText: msg.conteudo || '',
        mediaUrl: msg.media_url ? this.waDetailMediaUrl(msg.media_url) : null,
        msgId: msg.message_id || null,
        chatJid: this.data.detail?._waGroupJid || null,
        sender: msg.sender || '',
        source: 'wa_detail',
      };
      this.ui.ctxSaveDesc = (msg.conteudo || '')?.substring(0, 200);
      this.ui.ctxSavePasta = '';
      this.ui.ctxSaveModal = true;
    },

    // Open save-to-context from WA inbox messages
    openCtxSaveFromWaInbox(msg) {
      const menteeId = msg.mentorado_id || this.ui.selectedMenteeId;
      const menteeName = msg.mentorado_nome || this.data.mentees.find(m => m.id === menteeId)?.nome || '';
      if (!menteeId) { this.toast('Mentorado não identificado para esta mensagem', 'error'); return; }
      this.ui.ctxSaveData = {
        menteeId, menteeName,
        tipo: 'texto',
        msgText: msg.content_text || msg.conteudo || '',
        mediaUrl: null,
        msgId: msg.id || null,
        chatJid: msg.group_jid || null,
        sender: msg.sender_name || '',
        source: 'wa_inbox',
      };
      this.ui.ctxSaveDesc = (msg.content_text || msg.conteudo || '').substring(0, 200);
      this.ui.ctxSavePasta = '';
      this.ui.ctxSaveModal = true;
    },

    // Confirm save from modal
    async confirmSaveContext() {
      const d = this.ui.ctxSaveData;
      if (!d) return;
      this.ui.ctxSaveSaving = true;

      const record = {
        mentorado_id: d.menteeId,
        tipo: d.tipo,
        titulo: this.ui.ctxSaveDesc?.substring(0, 100) || `WA: ${d.sender} — ${new Date().toLocaleDateString('pt-BR', {day:'2-digit',month:'2-digit'})}`,
        conteudo: this.ui.ctxSaveDesc || d.msgText || '',
        fase: this.ui.ctxSavePasta || 'geral',
        origem: 'whatsapp_ui',
        wa_message_id: d.msgId,
        wa_group_jid: d.chatJid,
        criado_por: this.auth.currentUser?.email || '',
      };

      // Upload media if exists
      if (d.mediaUrl && d.tipo !== 'texto') {
        try {
          const resp = await fetch(d.mediaUrl);
          const blob = await resp.blob();
          const ext = d.tipo === 'imagem' ? 'jpg' : d.tipo === 'audio' ? 'ogg' : d.tipo === 'video' ? 'mp4' : 'bin';
          const fileName = `wa_${d.msgId || Date.now()}.${ext}`;
          const path = `context/${d.menteeId}/${Date.now()}_${fileName}`;
          const { error: uploadErr } = await sb.storage.from('uploads').upload(path, blob);
          if (!uploadErr) {
            const { data: urlData } = sb.storage.from('uploads').getPublicUrl(path);
            record.arquivo_url = urlData?.publicUrl;
            record.arquivo_nome = fileName;
            record.arquivo_tipo = blob.type;
            record.arquivo_tamanho = blob.size;
          }
        } catch (e) { console.warn('[S2] Media upload failed:', e.message); }
      }

      try {
        const { data: inserted, error } = await sb.from('mentorado_context').insert(record).select('id,ativo_codigo').single();
        if (error) throw error;
        this.toast(`${inserted?.ativo_codigo || 'ATIVO'} salvo na ficha de ${d.menteeName}`, 'success');
        // Auto-transcribe audio
        if (inserted?.id && ['audio'].includes(d.tipo) && record.arquivo_url) {
          this._autoTranscribeWithUrl(inserted.id, record.arquivo_url);
        }
        // Navigate to mentorado detail → Contexto tab and reload
        if (this.ui.page !== 'detail' || this.ui.selectedMenteeId !== d.menteeId) {
          this.ui.selectedMenteeId = d.menteeId;
          this.navigate('detail');
          await this.loadMenteeDetail(d.menteeId);
        }
        this.ui.activeDetailTab = 'contexto';
        await this.loadMenteeContext(d.menteeId);
      } catch (e) {
        this.toast('Erro: ' + e.message, 'error');
      }
      this.ui.ctxSaveSaving = false;
      this.ui.ctxSaveModal = false;
      this.ui.ctxSaveData = null;
    },

    // ===== EPIC 1: Load Chatwoot messages for mentorado =====
    async loadMenteeMessages(menteeId) {
      if (!menteeId) return;
      this.data.menteeMessages = [];
      try {
        const resp = await fetch(`${CONFIG.API_BASE}/api/mentees/${menteeId}/messages`, {
          headers: { 'Authorization': 'Bearer ' + (localStorage.getItem('spalla_access_token') || '') },
        });
        if (resp.ok) this.data.menteeMessages = await resp.json();
      } catch (e) { console.warn('[Spalla] loadMenteeMessages:', e); }
    },

    // ===== EPIC 2: Run Fabric pattern =====
    async runFabricPattern() {
      if (!this.ui.fabricInput || !this.ui.fabricPattern) return;
      this.ui.fabricLoading = true;
      this.ui.fabricResult = '';
      this.ui.fabricError = '';
      try {
        const resp = await fetch(`${CONFIG.API_BASE}/api/fabric/run`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + (localStorage.getItem('spalla_access_token') || ''),
          },
          body: JSON.stringify({
            pattern: this.ui.fabricPattern,
            input: this.ui.fabricInput,
          }),
        });
        const data = await resp.json();
        if (resp.ok && data.output) {
          this.ui.fabricResult = data.output;
        } else {
          this.ui.fabricError = data.error || 'Erro ao processar';
        }
      } catch (e) {
        this.ui.fabricError = 'Erro de conexao: ' + e.message;
      }
      this.ui.fabricLoading = false;
    },

    // ===== EPIC 6: Generate dossiê via Goose =====
    async generateDossie(menteeId, tipo = 'oferta') {
      if (!menteeId) return;
      try {
        const resp = await fetch(`${CONFIG.API_BASE}/api/dossie/generate`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + (localStorage.getItem('spalla_access_token') || ''),
          },
          body: JSON.stringify({ mentorado_id: menteeId, type: tipo }),
        });
        const data = await resp.json();
        if (resp.ok) {
          alert(`Dossie ${tipo} enfileirado para ${data.mentorado_nome}. Job #${data.job_id}`);
        } else {
          alert('Erro: ' + (data.error || 'Falha ao gerar'));
        }
      } catch (e) {
        alert('Erro de conexao: ' + e.message);
      }
    },

    async patchMentee(menteeId, updates) {
      try {
        const resp = await fetch(`${CONFIG.API_BASE}/api/mentees/${menteeId}`, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.auth.accessToken}`,
          },
          body: JSON.stringify(updates),
        });
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
        const result = await resp.json();
        const idx = this.data.mentees.findIndex(m => m.id === menteeId);
        if (idx !== -1) this.data.mentees[idx] = { ...this.data.mentees[idx], ...updates };
        return result;
      } catch (e) {
        this.toast('Erro ao atualizar mentorado: ' + e.message, 'error');
        throw e;
      }
    },

    async changeFaseMentee(menteeId, novaFase) {
      await this.patchMentee(menteeId, { fase_jornada: novaFase });
      this.ui.waFaseDropdownId = null;
      this.toast(`Fase atualizada para ${this.formatPhaseLabel(novaFase)}`, 'success');
      // Wave 2 F2.1: Generate phase tasks on phase change
      const templates = this.PHASE_TASK_TEMPLATES[novaFase?.toLowerCase()];
      if (templates?.length) {
        const confirmGenerate = window.confirm(`Gerar ${templates.length} tarefas padrão para a fase ${this.formatPhaseLabel(novaFase)}?`);
        if (confirmGenerate) {
          try {
            const generated = await this.generatePhaseTasks(menteeId, novaFase);
            if (generated > 0) {
              this.toast(`${generated} tarefas geradas para fase ${this.formatPhaseLabel(novaFase)}`, 'success');
              await this.loadTasks();
            }
          } catch (taskErr) {
            console.warn('[Spalla] generatePhaseTasks (wa):', taskErr.message);
            this.toast('Erro ao gerar tarefas da fase', 'error');
          }
        }
      }
    },

    async snoozeMentee(menteeId, dias) {
      // snoozed_until foi removido da tabela — snooze desabilitado temporariamente
      this.toast('Snooze temporariamente indisponível', 'info');
    },

    openOffboardModal(menteeId, menteeNome) {
      this.ui.offboardModal = { open: true, menteeId, menteeNome, motivo: '', obs: '', loading: false };
    },

    closeOffboardModal() {
      this.ui.offboardModal = { open: false, menteeId: null, menteeNome: '', motivo: '', obs: '', loading: false };
    },

    async confirmOffboard() {
      const m = this.ui.offboardModal;
      if (!m.motivo) { this.toast('Selecione o motivo do desligamento', 'warning'); return; }
      m.loading = true;
      try {
        const resp = await fetch(`${CONFIG.API_BASE}/api/mentees/${m.menteeId}/offboard`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.auth.accessToken}`,
          },
          body: JSON.stringify({ motivo: m.motivo, obs: m.obs }),
        });
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
        // Remove from local list immediately (ativo = false → filtered out by view)
        this.data.mentees = this.data.mentees.filter(x => x.id !== m.menteeId);
        // If detail view is open for this mentee, close it
        if (this.data.detail?.profile?.id === m.menteeId) {
          this.data.detail = null;
          this.ui.showDetail = false;
        }
        this.toast(`${m.menteeNome} desativado com sucesso`, 'success');
        this.closeOffboardModal();
      } catch (e) {
        this.toast('Erro ao desligar mentorado: ' + e.message, 'error');
      } finally {
        m.loading = false;
      }
    },

    // ===================== NOTAS ESTRUTURADAS =====================

    openNotesDrawer(menteeId, menteeNome) {
      this.ui.notesDrawer = { open: true, menteeId, menteeNome: menteeNome || '', tipo: 'livre' };
      this.ui.notesForm = {
        conteudo: '', tags: '',
        progresso: 0, bloqueios: '', proximos_passos: '',
        participou: false, entregou_tarefa: false, observacoes: '',
        duracao: '', topicos: '', decisoes: '', followups: ''
      };
      this.ui.notesDrawerTab = 'notes';
      this.data.menteeFiles = { docs: [], media: [], loading: false };
      this.loadMenteeNotes(menteeId);
    },

    closeNotesDrawer() {
      this.ui.notesDrawer = { open: false, menteeId: null, menteeNome: '', tipo: 'livre' };
      this.ui.notesForm = {
        conteudo: '', tags: '',
        progresso: 0, bloqueios: '', proximos_passos: '',
        participou: false, entregou_tarefa: false, observacoes: '',
        duracao: '', topicos: '', decisoes: '', followups: ''
      };
      this.ui.notesDrawerTab = 'notes';
      this.data.menteeNotes = [];
      this.data.menteeFiles = { docs: [], media: [], loading: false };
    },

    async loadMenteeNotes(menteeId) {
      if (!menteeId) return;
      try {
        const res = await fetch(`/api/mentees/${menteeId}/notes`, {
          headers: { 'Authorization': `Bearer ${this._getToken()}` }
        });
        if (!res.ok) throw new Error(await res.text());
        const notes = await res.json();
        this.data.menteeNotes = (notes || []).map(n => ({
          ...n,
          _conteudo: (() => { try { return typeof n.conteudo === 'string' ? JSON.parse(n.conteudo) : n.conteudo; } catch { return { texto: n.conteudo }; } })()
        }));
      } catch (e) {
        console.error('loadMenteeNotes error:', e);
        this.data.menteeNotes = [];
      }
    },

    async postMenteeNote(menteeId, tipo) {
      const f = this.ui.notesForm;
      let conteudo;
      if (tipo === 'checkpoint_mensal') {
        if (!f.progresso || !f.proximos_passos?.trim()) {
          this.toast('Preencha progresso e proximos passos.', 'warning'); return false;
        }
        conteudo = { progresso: f.progresso, bloqueios: f.bloqueios.trim(), proximos_passos: f.proximos_passos.trim() };
      } else if (tipo === 'feedback_aula') {
        if (!f.observacoes?.trim()) {
          this.toast('Preencha as observacoes.', 'warning'); return false;
        }
        conteudo = { participou: f.participou, entregou_tarefa: f.entregou_tarefa, observacoes: f.observacoes.trim() };
      } else if (tipo === 'registro_ligacao') {
        if (!f.topicos?.trim()) {
          this.toast('Preencha os topicos discutidos.', 'warning'); return false;
        }
        conteudo = { duracao: f.duracao.trim(), topicos: f.topicos.trim(), decisoes: f.decisoes.trim(), followups: f.followups.trim() };
      } else {
        if (!f.conteudo?.trim()) { this.toast('Escreva algo antes de salvar.', 'warning'); return false; }
        conteudo = { texto: f.conteudo.trim() };
      }
      this.ui.notesSaving = true;
      try {
        const tagsArr = f.tags ? f.tags.split(',').map(t => t.trim()).filter(Boolean) : [];
        const res = await fetch(`/api/mentees/${menteeId}/notes`, {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${this._getToken()}`, 'Content-Type': 'application/json' },
          body: JSON.stringify({ tipo, conteudo: JSON.stringify(conteudo), tags: tagsArr })
        });
        if (!res.ok) throw new Error(await res.text());
        this.toast('Nota salva!', 'success');
        this.ui.notesForm = {
          conteudo: '', tags: '',
          progresso: 0, bloqueios: '', proximos_passos: '',
          participou: false, entregou_tarefa: false, observacoes: '',
          duracao: '', topicos: '', decisoes: '', followups: ''
        };
        await this.loadMenteeNotes(menteeId);
        return true;
      } catch (e) {
        console.error('postMenteeNote error:', e);
        this.toast('Erro ao salvar nota.', 'error');
        return false;
      } finally { this.ui.notesSaving = false; }
    },

    _notesTipoLabel(tipo) {
      const map = {
        'checkpoint_mensal': 'Checkpoint Mensal',
        'feedback_aula': 'Feedback de Aula',
        'registro_ligacao': 'Registro de Ligação',
        'livre': 'Nota Livre',
      };
      return map[tipo] || tipo;
    },

    _notesTipoPlaceholder(tipo) {
      const map = {
        'checkpoint_mensal': 'Progresso (1-5), bloqueios encontrados, próximos passos acordados...',
        'feedback_aula': 'Participou? Entregou tarefa? Observações sobre o engajamento...',
        'registro_ligacao': 'Duração, tópicos discutidos, decisões tomadas, follow-ups prometidos...',
        'livre': 'Escreva sua nota...',
      };
      return map[tipo] || 'Escreva sua nota...';
    },

    _getToken() {
      return localStorage.getItem('spalla_access_token') || localStorage.getItem('sb-access-token') || '';
    },

    // ===================== MENTEE GROUPS / PASTAS =====================

    async loadGroups() {
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/mentee-groups`, { headers: { 'Authorization': `Bearer ${this._getToken()}` } });
        if (!res.ok) return;
        this.data.groups = await res.json() || [];
      } catch (e) { console.error('loadGroups error:', e); }
    },

    async createGroup() {
      const f = this.ui.groupsForm;
      if (!f.nome.trim()) { this.toast('Nome obrigatorio', 'warning'); return; }
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/mentee-groups`, {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${this._getToken()}`, 'Content-Type': 'application/json' },
          body: JSON.stringify({ nome: f.nome.trim(), cor: f.cor, icon: f.icon })
        });
        if (!res.ok) throw new Error();
        await this.loadGroups();
        this.ui.groupsModal = { open: false, editing: null };
        this.ui.groupsForm = { nome: '', cor: '#6366f1', icon: '\u{1F4C1}' };
        this.toast('Pasta criada!', 'success');
      } catch (e) { this.toast('Erro ao criar pasta', 'error'); }
    },

    async deleteGroup(groupId) {
      try {
        const res = await fetch(`/api/mentee-groups/${groupId}`, {
          method: 'DELETE',
          headers: { 'Authorization': `Bearer ${this._getToken()}` }
        });
        if (!res.ok) throw new Error();
        if (this.ui.activeGroupFilter === groupId) this.ui.activeGroupFilter = null;
        await this.loadGroups();
        this.toast('Pasta removida', 'success');
      } catch (e) { this.toast('Erro ao remover pasta', 'error'); }
    },

    async toggleGroupMember(groupId, menteeId) {
      const group = this.data.groups.find(g => g.id === groupId);
      if (!group) return;
      const isMember = group.member_ids?.includes(menteeId);
      try {
        if (isMember) {
          await fetch(`/api/mentee-groups/${groupId}/members/${menteeId}`, {
            method: 'DELETE', headers: { 'Authorization': `Bearer ${this._getToken()}` }
          });
        } else {
          await fetch(`/api/mentee-groups/${groupId}/members`, {
            method: 'POST',
            headers: { 'Authorization': `Bearer ${this._getToken()}`, 'Content-Type': 'application/json' },
            body: JSON.stringify({ mentee_id: menteeId })
          });
        }
        await this.loadGroups();
      } catch (e) { this.toast('Erro ao atualizar pasta', 'error'); }
    },

    openAssignModal(menteeId, menteeNome) {
      this.ui.assignModal = { open: true, menteeId, menteeNome: menteeNome || '' };
      if (!this.data.groups.length) this.loadGroups();
    },

    // ===================== WA MANAGEMENT — KEYBOARD SHORTCUTS (S6.7) =====================

    initWaKeyboardShortcuts() {
      if (this._waKbdListener) return; // prevent double registration
      this._waKbdListener = (e) => {
        // Guard 1: only on carteira page
        if (this.ui.page !== 'carteira') return;
        // Guard 2: ignore when typing in inputs
        const tag = document.activeElement?.tagName;
        if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT') return;
        // Guard 3: ignore when modals are open
        if (this.ui.notesDrawer?.open || this.ui.digestModal?.open || this.ui.taskModal) return;

        const mentees = this.waPortfolioMentees ? this.waPortfolioMentees() : (this.data.mentees || []);
        const len = mentees.length;
        if (!len) return;

        switch (e.key) {
          case 'j':
          case 'ArrowDown':
            e.preventDefault();
            this.ui.waFocusedIdx = Math.min((this.ui.waFocusedIdx ?? -1) + 1, len - 1);
            break;
          case 'k':
          case 'ArrowUp':
            e.preventDefault();
            this.ui.waFocusedIdx = Math.max((this.ui.waFocusedIdx ?? 0) - 1, 0);
            break;
          case 'e': {
            const m = mentees[this.ui.waFocusedIdx ?? 0];
            if (m) this.navigate('whatsapp');
            break;
          }
          case 'n': {
            const m = mentees[this.ui.waFocusedIdx ?? 0];
            if (m && this.openNotesDrawer) this.openNotesDrawer(m.id, m.nome);
            break;
          }
          case 's': {
            const m = mentees[this.ui.waFocusedIdx ?? 0];
            if (m && this.snoozeMentee) this.snoozeMentee(m.id, 1);
            break;
          }
          case 'x': {
            const m = mentees[this.ui.waFocusedIdx ?? 0];
            if (m) {
              const idx = this.data.waSelectedMentees.indexOf(m.id);
              if (idx === -1) {
                this.data.waSelectedMentees.push(m.id);
              } else {
                this.data.waSelectedMentees.splice(idx, 1);
              }
            }
            break;
          }
          case 'Escape':
            this.ui.waFocusedIdx = -1;
            break;
        }
      };
      document.addEventListener('keydown', this._waKbdListener);
    },

    // ===================== WA MANAGEMENT — BULK SELECTION =====================

    toggleBulkSelect(menteeId) {
      const idx = this.data.waSelectedMentees.indexOf(menteeId);
      if (idx === -1) {
        this.data.waSelectedMentees.push(menteeId);
      } else {
        this.data.waSelectedMentees.splice(idx, 1);
      }
    },

    isBulkSelected(menteeId) {
      return this.data.waSelectedMentees.includes(menteeId);
    },

    clearBulkSelection() {
      this.data.waSelectedMentees = [];
      this.ui.waBulkFase = '';
      this.ui.waBulkMode = false;
    },

    selectAllBulk() {
      const visible = this.waPortfolioMentees ? this.waPortfolioMentees() : (this.data.mentees || []);
      this.data.waSelectedMentees = visible.map(m => m.id);
    },

    async bulkUpdateFase(fase) {
      if (!fase || this.data.waSelectedMentees.length === 0) return;
      const ids = [...this.data.waSelectedMentees];
      this.ui.waBulkApplying = true;
      try {
        const resp = await fetch(`${CONFIG.API_BASE}/api/mentees/bulk`, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.auth.accessToken}`,
          },
          body: JSON.stringify({ ids, updates: { fase_jornada: fase } }),
        });
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
        ids.forEach(id => {
          const m = (this.data.mentees || []).find(x => x.id === id);
          if (m) m.fase_jornada = fase;
        });
        this.toast(`${ids.length} mentorado(s) movido(s) para ${this._waFaseLabel(fase)}`, 'success');
        this.clearBulkSelection();
      } catch (e) {
        console.error('bulkUpdateFase error:', e);
        this.toast('Erro ao aplicar bulk update.', 'error');
      } finally {
        this.ui.waBulkApplying = false;
      }
    },


    // ===================== WA MANAGEMENT — AI GROUP DIGEST =====================

    openDigestModal(menteeId, menteeNome) {
      this.ui.digestModal = { open: true, menteeId, menteeNome: menteeNome || '' };
      this.data.digestData = null;
      this.loadMenteeDigest(menteeId);
    },

    closeDigestModal() {
      this.ui.digestModal = { open: false, menteeId: null, menteeNome: '' };
      this.data.digestData = null;
    },

    async loadMenteeDigest(menteeId) {
      if (!menteeId) return;
      this.ui.digestLoading = true;
      try {
        const cutoff = new Date();
        cutoff.setDate(cutoff.getDate() - 7);
        const { data: topicos, error } = await sb
          .from('vw_wa_topic_board')
          .select('id,title,summary,status,type_name,type_slug,type_color,type_icon,confidence,last_message_at,msgs_awaiting_response,task_titulo,task_status')
          .eq('mentorado_id', menteeId)
          .gte('last_message_at', cutoff.toISOString())
          .order('last_message_at', { ascending: false });
        if (error) throw error;
        const list = topicos || [];
        this.data.digestData = {
          topicos: list,
          sentimento: this._digestSentimentoGeral(list),
          precisaAtencao: list.filter(t => t.status === 'pending_action' || (t.msgs_awaiting_response || 0) > 0),
          actionItems: list.filter(t => t.task_titulo && t.task_status && t.task_status !== 'concluido'),
          total: list.length,
        };
      } catch (e) {
        console.error('[Spalla] loadMenteeDigest error:', e);
        this.data.digestData = { topicos: [], sentimento: 'neutro', precisaAtencao: [], actionItems: [], total: 0 };
      } finally {
        this.ui.digestLoading = false;
      }
    },

    _digestSentimentoGeral(topicos) {
      if (!topicos || topicos.length === 0) return 'neutro';
      const negativos = ['problema', 'bloqueio', 'risco', 'conflito', 'atencao', 'urgente'];
      const positivos = ['progresso', 'conquista', 'resultado', 'aprovacao', 'entrega', 'sucesso'];
      let score = 0;
      topicos.forEach(t => {
        const slug = (t.type_slug || '').toLowerCase();
        if (negativos.some(n => slug.includes(n))) score -= 1;
        else if (positivos.some(p => slug.includes(p))) score += 1;
        if ((t.msgs_awaiting_response || 0) > 2) score -= 1;
        if (t.status === 'pending_action') score -= 1;
      });
      if (score < 0) return 'atencao';
      if (score > 0) return 'positivo';
      return 'neutro';
    },

    async openWaTopic(topic) {
      this.ui.waTopicDetail = topic;
      this.ui.waTopicMessages = [];
      try {
        const { data, error } = await sb.from('interacoes_mentoria')
          .select('id,sender_name,eh_equipe,tipo_interacao,conteudo,timestamp')
          .eq('topic_id', topic.id)
          .order('timestamp', { ascending: true })
          .limit(100);
        if (error) throw error;
        this.ui.waTopicMessages = data || [];
      } catch (e) {
        console.error('[Spalla] loadTopicMessages error:', e);
      }
    },

    async updateTopicStatus(topicId, status) {
      try {
        const { error } = await sb.from('wa_topics')
          .update({ status, updated_at: new Date().toISOString(), ...(status === 'resolved' ? { resolved_at: new Date().toISOString() } : {}) })
          .eq('id', topicId);
        if (error) throw error;
        // Update local state
        const idx = this.data.waTopics.findIndex(t => t.id === topicId);
        if (idx !== -1) this.data.waTopics[idx] = { ...this.data.waTopics[idx], status };
        if (this.ui.waTopicDetail?.id === topicId) this.ui.waTopicDetail = { ...this.ui.waTopicDetail, status };
        // Log event
        await sb.from('wa_topic_events').insert({ topic_id: topicId, event_type: 'status_changed', payload: { status }, created_by: this.auth?.currentUser?.email || 'user' });
        this.toast('Status atualizado', 'success');
      } catch (e) {
        console.error('[Spalla] updateTopicStatus error:', e);
        this.toast('Erro ao atualizar status', 'error');
      }
    },

    async convertTopicToTask(topic) {
      try {
        const taskData = {
          titulo: topic.title,
          descricao: topic.summary || `Convertido do tópico WA: ${topic.title}`,
          status: 'pendente',
          prioridade: 'normal',
          acompanhante: topic.mentorado_nome || null,
          created_by: this.auth?.currentUser?.email || null,
        };
        const { data: task, error } = await sb.from('god_tasks').insert(taskData).select().single();
        if (error) throw error;
        // Link topic → task
        await sb.from('wa_topics').update({ task_id: task.id, status: 'converted_task' }).eq('id', topic.id);
        await sb.from('wa_topic_events').insert({ topic_id: topic.id, event_type: 'task_linked', payload: { task_id: task.id }, created_by: this.auth?.currentUser?.email || 'user' });
        // Refresh local state
        const idx = this.data.waTopics.findIndex(t => t.id === topic.id);
        if (idx !== -1) this.data.waTopics[idx] = { ...this.data.waTopics[idx], status: 'converted_task', task_id: task.id, task_titulo: task.titulo };
        if (this.ui.waTopicDetail?.id === topic.id) this.ui.waTopicDetail = { ...this.ui.waTopicDetail, status: 'converted_task', task_titulo: task.titulo };
        this.toast('Tarefa criada com sucesso!', 'success');
      } catch (e) {
        console.error('[Spalla] convertTopicToTask error:', e);
        this.toast('Erro ao converter em tarefa: ' + e.message, 'error');
      }
    },

    waTopicStatusLabel(status) {
      const labels = { open: 'Aberto', active: 'Ativo', pending_action: 'Pendente', resolved: 'Resolvido', archived: 'Arquivado', converted_task: 'Tarefa' };
      return labels[status] || status;
    },

    waTopicStatusClass(status) {
      const cls = { open: 'badge--info', active: 'badge--warning', pending_action: 'badge--danger', resolved: 'badge--success', archived: '', converted_task: 'badge--brand' };
      return cls[status] || '';
    },

    // ===================== INSTAGRAM HELPERS =====================

    // Photo library: Instagram handle OR nome → local photo filename
    // Keys can be: Instagram handle (lowercase), nome parts (lowercase), or any identifier
    _photoLibrary: {
      'drajulianaaltavilla': 'drajulianaaltavilla.jpg',
      'juliana altavilla': 'drajulianaaltavilla.jpg',
      'dra.ericamacedo': 'dra.ericamacedo.jpg',
      'erica macedo': 'dra.ericamacedo.jpg',
      'dramonicafelici': 'dramonicafelici.jpg',
      'monica felici': 'dramonicafelici.jpg',
      'daniela morais': 'danielamoraiscota.jpg',
      'danielamoraiscota': 'danielamoraiscota.jpg',
      'dra.deboracadore': 'dradeboracadore.jpg',
      'dradeboracadore': 'dradeboracadore.jpg',
      'debora cadore': 'dradeboracadore.jpg',
      'dra.julienefrighetto': 'drajulienefrighetto.jpg',
      'drajulienefrighetto': 'drajulienefrighetto.jpg',
      'juliene frighetto': 'drajulienefrighetto.jpg',
      'juliene cristina': 'drajulienefrighetto.jpg',
      'julienne frighetto': 'drajulienefrighetto.jpg',
      'danyellatruiz': 'danyellatruiz.jpg',
      'dradanyellatruiz': 'dradanyellatruiz.jpg',
      'danyella truiz': 'dradanyellatruiz.jpg',
      'dr.rafaelcastro': 'dr.rafaelcastro.jpg',
      'doctraction': 'dr.rafaelcastro.jpg',
      'rafael castro': 'dr.rafaelcastro.jpg',
      'dra.deboracadore': 'dra.deboracadore.jpg',
      'debora cadore': 'dra.deboracadore.jpg',
      'dentineodonto': 'dentineodonto.jpg',
      'dentine': 'dentineodonto.jpg',
      'lediane': 'dentineodonto.jpg',
      'elinarocha': 'elinarocha.jpg',
      'elina rocha': 'elinarocha.jpg',
      'dra.jessicacrespi': 'dra.jessicacrespi.jpg',
      'jessica crespi': 'dra.jessicacrespi.jpg',
      'drajosianebarcelos': 'drajosianebarcelos.jpg',
      'josiane barcelos': 'drajosianebarcelos.jpg',
      'lucienetamaki': 'lucienetamaki.jpg',
      'luciene tamaki': 'lucienetamaki.jpg',
      'odontokerr': 'odontokerr.jpg',
      'sidney kerr': 'odontokerr.jpg',
      'dravaniadepaula': 'dravaniadepaula.jpg',
      'vania de paula': 'dravaniadepaula.jpg',
      'flavia.nantes': 'flavia.nantes.jpg',
      'flavia nantes': 'flavia.nantes.jpg',
      'flaviannyartiaga': 'flaviannyartiaga.jpg',
      'flavianny artiaga': 'flaviannyartiaga.jpg',
      'karinebarroscanabrava': 'karinebarroscanabrava.jpg',
      'karine canabrava': 'karinebarroscanabrava.jpg',
      'leticiaoliveira.cpm': 'leticiaoliveira.cpm.jpg',
      'leticia oliveira': 'leticiaoliveira.cpm.jpg',
      'dramarinamendess': 'dramarinamendess.jpg',
      'marina mendes': 'dramarinamendess.jpg',
      'profpablosantos': 'profpablosantos.jpg',
      'pablo santos': 'profpablosantos.jpg',
      'queilatrizotti': 'queilatrizotti.jpg',
      'queila trizotti': 'queilatrizotti.jpg',
      'dr.leandrovelasco': 'dr.leandrovelasco.jpg',
      'leandro velasco': 'dr.leandrovelasco.jpg',
      'juliana.takasu': 'juliana.takasu.jpg',
      'juliana takasu': 'juliana.takasu.jpg',
      // Mentorados cujo IG no DB não bate com o nome do arquivo local
      'jessicacrespi.pro': 'dra.jessicacrespi.jpg',
      'jessicacrespipro': 'dra.jessicacrespi.jpg',
      'mentoriamedicine': 'dratayslarabelarmino.jpg',
      'dratayslarabelarmino': 'dratayslarabelarmino.jpg',
      'tayslara belarmino': 'dratayslarabelarmino.jpg',
      'metodoaurabusiness': 'thiellyprado.jpg',
      'thiellyprado': 'thiellyprado.jpg',
      'thielly prado': 'thiellyprado.jpg',
      'instituto.yaragomes': 'dra.yaragomes.jpg',
      'institutoyaragomes': 'dra.yaragomes.jpg',
      'dra.yaragomes': 'dra.yaragomes.jpg',
      'yara gomes': 'dra.yaragomes.jpg',
      'neonato_edu': 'neonato_edu.jpg',
      'neonatoedu': 'neonato_edu.jpg',
      'neonato - ana paula e jordana': 'neonato_edu.jpg',
      'ana paula e jordana': 'neonato_edu.jpg',
      'kava_arq': 'kava_arq.jpg',
      'kavaarq': 'kava_arq.jpg',
      'paula groisman e anna plachta': 'kava_arq.jpg',
      'paula groisman': 'kava_arq.jpg',
      'anna plachta': 'kava_arq.jpg',
    },

    igPhoto(handleOrName) {
      if (!handleOrName) return null;
      void this.photoTick;

      const isHandle = !handleOrName.includes(' ');
      const clean = handleOrName.replace('@','').trim().toLowerCase();

      // First: try embedded data URLs (PHOTO_DATA_URLS — base64, never expire)
      if (typeof PHOTO_DATA_URLS !== 'undefined' && PHOTO_DATA_URLS[clean]) {
        return PHOTO_DATA_URLS[clean];
      }

      // Second: try photo library mapping
      if (this._photoLibrary[clean]) {
        const filename = this._photoLibrary[clean];
        const fileKey = filename.replace('.jpg', '');
        if (typeof PHOTO_DATA_URLS !== 'undefined' && PHOTO_DATA_URLS[fileKey]) {
          return PHOTO_DATA_URLS[fileKey];
        }
        return `photos/${filename}`;
      }

      // Third: try INSTAGRAM_PROFILES foto field
      if (typeof INSTAGRAM_PROFILES !== 'undefined') {
        const profile = INSTAGRAM_PROFILES[clean];
        if (profile?.foto) return profile.foto;
      }

      // Fourth: try local photos directory
      const fileKey = isHandle ? clean : clean.replace(/\s+/g, '_');
      return `photos/${fileKey}.jpg`;
    },

    // Returns style object for mc-card__avatar-photo.
    // Returns empty object (not setting background-image) when no photo URL exists,
    // preventing url(null) being set and the browser flickering on re-evaluation.
    igPhotoStyle(handleOrName) {
      const url = this.igPhoto(handleOrName);
      return url ? { 'background-image': `url(${url})` } : {};
    },

    callMenteePhoto(call) {
      if (!call) return null;
      // Match by ID first (reliable), then name fallback
      const m = (call.mentorado_id && this.data.mentees.find(x => String(x.id) === String(call.mentorado_id)))
             || this.data.mentees.find(x => x.nome === call.mentorado)
             || this.data.mentees.find(x => x.nome?.toLowerCase().trim() === call.mentorado?.toLowerCase().trim());
      return this.igPhoto(m?.instagram || call.mentorado);
    },

    igFollowers(handle) {
      return getFollowers(handle);
    },

    igProfile(handle) {
      return getInstagramProfile(handle);
    },

    handlePhotoError(src) {
      // no-op: hiding handled by @error in template
    },

    hasValidPhoto(handle) {
      return !!this.igPhoto(handle);
    },

    // ===================== MENTEE LIST (for dropdowns) =====================

    get menteeNames() {
      if (this.data.mentees && this.data.mentees.length > 0) {
        return this.data.mentees.map(m => m.nome).sort();
      }
      return ALL_MENTEE_NAMES || [];
    },

    // ===================== AGENDA (calls globais) =====================

    /**
     * Detecta se um link de "transcrição" é na verdade um download de vídeo do Zoom.
     * Zoom armazena: share/ = player web, download/ = download direto .mp4
     * Muitas calls têm link_transcricao preenchido com download/ por engano.
     */
    isRealTranscricao(url) {
      if (!url) return false;
      // Zoom download links are NOT transcriptions — they download the .mp4
      if (/zoom\.us\/rec\/download/i.test(url)) return false;
      return true;
    },

    /**
     * Abre mídia (gravação ou transcrição):
     * - Google Drive files → modal com iframe /preview (evita download)
     * - Zoom share links → abre em nova aba (player do Zoom)
     * - YouTube → abre em nova aba
     * - Google Docs → abre em nova aba
     * - Zoom download → converte para share link (player em vez de download)
     */
    openMedia(url, label, password) {
      if (!url) return;
      // Google Drive file → modal preview
      const driveMatch = url.match(/drive\.google\.com\/file\/d\/([^/]+)/);
      if (driveMatch) {
        this.ui.mediaModal = {
          url: `https://drive.google.com/file/d/${driveMatch[1]}/preview`,
          originalUrl: url,
          label: label || 'Arquivo',
        };
        return;
      }
      // Zoom recording → append password if available
      if (/zoom\.us\/rec\//i.test(url)) {
        let finalUrl = url;
        // Convert download → share link
        if (/\/rec\/download\//i.test(finalUrl)) {
          finalUrl = finalUrl.replace('/rec/download/', '/rec/share/');
        }
        // Append password parameter if available (filter out "undefined" string)
        const cleanPwd = password && password !== 'undefined' && password !== 'null' ? password : null;
        if (cleanPwd && !finalUrl.includes('pwd=')) {
          const separator = finalUrl.includes('?') ? '&' : '?';
          finalUrl += `${separator}pwd=${encodeURIComponent(cleanPwd)}`;
        }
        window.open(finalUrl, '_blank');
        return;
      }
      // Everything else → open in new tab
      window.open(url, '_blank', 'noopener');
    },

    /**
     * Abre transcrição: prioriza transcript_completo (texto) sobre link URL.
     * Se texto já disponível → mostra modal. Senão busca do Supabase por call_id.
     */
    async openTranscricao(urlOrText, transcriptText, callId) {
      // 1. Texto já disponível (detail view carrega completo)
      if (transcriptText) {
        this.ui.mediaModal = { text: transcriptText, label: 'Transcrição' };
        return;
      }
      // 2. Tem call_id → buscar transcript_completo sob demanda
      if (callId && sb) {
        this.ui.mediaModal = { text: 'Carregando transcrição...', label: 'Transcrição' };
        try {
          const { data, error } = await sb
            .from('calls_mentoria')
            .select('transcript_completo')
            .eq('id', callId)
            .single();
          if (data?.transcript_completo) {
            this.ui.mediaModal = { text: data.transcript_completo, label: 'Transcrição' };
            return;
          }
        } catch (e) {
          console.error('[Spalla] Error fetching transcript:', e);
        }
        // Se não tem transcript, fecha modal e tenta URL
        this.ui.mediaModal = null;
      }
      // 3. Fallback: URL (Google Docs etc)
      if (urlOrText) {
        this.openMedia(urlOrText, 'Transcrição');
      } else {
        this.toast('Transcrição não disponível para esta call', 'error');
      }
    },

    closeMedia() { this.ui.mediaModal = null; },

    get allCallsGlobal() {
      // If real Supabase calls loaded, use them
      if (this._supabaseCalls?.length) {
        return this._supabaseCalls.map(c => ({
          call_id: c.call_id, mentorado: c.mentorado_nome, mentorado_id: c.mentorado_id, data: (c.data_call || '').substring(0, 10),
          tipo: c.tipo_call || 'acompanhamento', duracao: c.duracao_minutos || 0,
          horario: c.horario_call || null, status_call: c.status_call || null,
          topic: c.zoom_topic || '', resumo: c.resumo || null,
          gravacao: c.link_gravacao || null,
          transcricao: c.link_transcricao || null,
          senha_call: c.senha_call || null, plano_acao: c.link_plano_acao || null,
          link_youtube: c.link_youtube || null,
          decisoes: c.decisoes_tomadas || [], gargalos: c.gargalos || [],
          proximos_passos: c.proximos_passos || [], sentimento: null,
        }));
      }
      // Fallback: static SUPABASE_CALLS with MENTEE_CONTEXTS enrichment
      return (SUPABASE_CALLS || []).map(c => {
        const ctx = getMenteeContext(c.mentorado);
        if (ctx?.calls) {
          const match = ctx.calls.find(cc => cc.data === c.data);
          if (match) return { ...c, gravacao: match.gravacao || null, transcricao: match.transcricao || null };
        }
        return c;
      });
    },

    get retorativasUrgentes() {
      // Mentees sem call há mais de 30 dias ou sem call nenhuma
      const hoje = Date.now();
      return this.data.mentees
        .filter(m => {
          if (!m.ultima_call_data) return true;
          const dias = Math.floor((hoje - parseDateStr(m.ultima_call_data).getTime()) / 86400000);
          return dias > 30;
        })
        .map(m => ({
          ...m,
          dias: m.ultima_call_data ? Math.floor((hoje - parseDateStr(m.ultima_call_data).getTime()) / 86400000) : null,
        }))
        .sort((a, b) => (b.dias || 999) - (a.dias || 999));
    },

    // ===================== CALENDAR METHODS =====================

    calendarTitle() {
      const months = ['Janeiro','Fevereiro','Marco','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'];
      return months[this.ui.calendarMonth] + ' ' + this.ui.calendarYear;
    },

    calendarPrev() {
      if (this.ui.calendarMonth === 0) { this.ui.calendarMonth = 11; this.ui.calendarYear--; }
      else this.ui.calendarMonth--;
    },

    calendarNext() {
      if (this.ui.calendarMonth === 11) { this.ui.calendarMonth = 0; this.ui.calendarYear++; }
      else this.ui.calendarMonth++;
    },

    calendarToday() {
      const now = new Date();
      this.ui.calendarMonth = now.getMonth();
      this.ui.calendarYear = now.getFullYear();
      this.ui.selectedCalDate = null;
    },

    calendarDays() {
      const year = this.ui.calendarYear;
      const month = this.ui.calendarMonth;
      const firstDay = new Date(year, month, 1);
      const lastDay = new Date(year, month + 1, 0);
      let startDay = firstDay.getDay() - 1; // Monday = 0
      if (startDay < 0) startDay = 6;

      const today = new Date();
      const todayStr = today.toISOString().split('T')[0];

      // Build call count map
      const callMap = {};
      (this.allCallsGlobal || []).forEach(c => {
        if (c.data) { callMap[c.data] = (callMap[c.data] || 0) + 1; }
      });
      // Build gcal event count map
      const gcalMap = {};
      (this.data.gcalEvents || []).forEach(e => {
        const d = (e.start || '').substring(0, 10);
        if (d) { gcalMap[d] = (gcalMap[d] || 0) + 1; }
      });

      const days = [];
      // Previous month days
      const prevLastDay = new Date(year, month, 0).getDate();
      for (let i = startDay - 1; i >= 0; i--) {
        const d = prevLastDay - i;
        const m2 = month === 0 ? 11 : month - 1;
        const y2 = month === 0 ? year - 1 : year;
        const ds = `${y2}-${String(m2+1).padStart(2,'0')}-${String(d).padStart(2,'0')}`;
        days.push({ key: ds, num: d, currentMonth: false, isToday: ds === todayStr, dateStr: ds, calls: callMap[ds] || 0, gcalEvents: gcalMap[ds] || 0 });
      }
      // Current month days
      for (let d = 1; d <= lastDay.getDate(); d++) {
        const ds = `${year}-${String(month+1).padStart(2,'0')}-${String(d).padStart(2,'0')}`;
        days.push({ key: ds, num: d, currentMonth: true, isToday: ds === todayStr, dateStr: ds, calls: callMap[ds] || 0, gcalEvents: gcalMap[ds] || 0 });
      }
      // Next month days to fill grid (6 rows)
      const remaining = 42 - days.length;
      for (let d = 1; d <= remaining; d++) {
        const m2 = month === 11 ? 0 : month + 1;
        const y2 = month === 11 ? year + 1 : year;
        const ds = `${y2}-${String(m2+1).padStart(2,'0')}-${String(d).padStart(2,'0')}`;
        days.push({ key: ds, num: d, currentMonth: false, isToday: ds === todayStr, dateStr: ds, calls: callMap[ds] || 0, gcalEvents: gcalMap[ds] || 0 });
      }
      return days;
    },

    calendarFilteredCalls() {
      const calls = [...(this.allCallsGlobal || [])].sort((a, b) => (b.data || '').localeCompare(a.data || ''));
      if (this.ui.selectedCalDate) {
        return calls.filter(c => c.data === this.ui.selectedCalDate);
      }
      return calls;
    },

    getScheduleBlock(nome) {
      if (!nome) return null;
      const m = this.data.mentees.find(x => x.nome === nome);
      if (!m) return null;
      if (m.contrato_assinado === false) return { title: 'CONTRATO NAO ASSINADO', msg: 'Nao e permitido agendar calls sem contrato assinado. Resolva a situacao contratual primeiro.' };
      if (m.status_financeiro === 'atrasado') return { title: 'PAGAMENTO ATRASADO', msg: 'Mentorado com parcelas em atraso. Regularize antes de agendar nova call.' };
      return null;
    },

    async scheduleCall() {
      const f = this.scheduleForm;
      if (!f.mentorado || !f.data) {
        this.toast('Selecione mentorado e data', 'error');
        return;
      }
      const block = this.getScheduleBlock(f.mentorado);
      if (block) {
        this.toast(block.title + ': ' + block.msg, 'error');
        return;
      }

      // Check for Google Calendar conflicts before proceeding
      this.ui.gcalConflict = null;
      if (f.data && f.horario && this.data.gcalEvents?.length) {
        const slotStart = new Date(`${f.data}T${f.horario}:00`).getTime();
        const margin = 30 * 60000; // ±30 minutes
        const conflict = this.data.gcalEvents.find(e => {
          const eStart = new Date(e.start).getTime();
          return Math.abs(eStart - slotStart) < margin;
        });
        if (conflict && !this.ui._conflictConfirmed) {
          this.ui.gcalConflict = { summary: conflict.summary, start: conflict.start };
          return; // User must confirm or change time
        }
      }

      this.ui.scheduling = true;

      try {
        // Get mentorado ID from mentees data
        let menteeId = f.mentorado_id;
        if (!menteeId) {
          const found = this.data.mentees?.find(m => m.nome === f.mentorado);
          menteeId = found?.id || null;
        }

        // Construct datetime from data + horario
        // f.data comes from HTML input type="date" in format YYYY-MM-DD
        // Zoom/Calendar expect ISO format. Create date as local, then convert properly
        const d = new Date(`${f.data}T${f.horario}:00`);
        const dataCall = d.toISOString();

        // Build title consistent with user naming: "[Case] Nome - Tipo - Data"
        const dataFormatada = new Date(f.data + 'T12:00:00').toLocaleDateString('pt-BR');
        const titulo = `[Case] ${f.mentorado} - ${f.tipo} - ${dataFormatada}`;

        // First: Create Zoom meeting + Google Calendar event on backend
        let zoomUrl = null;
        let calendarUrl = null;
        let gcalEventId = null;
        try {
          // Parse convidados extras: comma/space/newline separated emails
          const extras = (f.convidados_extras || '')
            .split(/[\s,;]+/)
            .map(e => e.trim().toLowerCase())
            .filter(e => e && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e));
          const zoomInvitees = [];
          if (f.email) zoomInvitees.push(f.email);
          for (const e of extras) if (!zoomInvitees.includes(e)) zoomInvitees.push(e);

          const zoomRes = await fetch(`${CONFIG.API_BASE}/api/zoom/create-meeting`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
            body: JSON.stringify({
              topic: titulo,
              start_time: `${f.data}T${f.horario}:00`,
              duration: parseInt(f.duracao) || 60,
              description: f.notas || '',
              invitees: zoomInvitees,
            }),
          });
          const zoomData = await zoomRes.json();
          if (!zoomRes.ok) {
            console.error('[Schedule] Zoom create failed', zoomRes.status, zoomData);
            this.toast?.(`Zoom: ${zoomData.error || zoomRes.status}`, 'warning');
          }
          if (zoomData.join_url) zoomUrl = zoomData.join_url;
        } catch (e) {
          console.warn('[Schedule] Zoom creation warning:', e.message);
          this.toast?.(`Zoom falhou: ${e.message}`, 'warning');
        }

        try {
          // Use local datetime string (not UTC) to avoid timezone offset
          const startLocal = `${f.data}T${f.horario}:00`;
          const durMinutes = parseInt(f.duracao) || 60;
          const endDt = new Date(new Date(`${startLocal}`).getTime() + durMinutes * 60000);
          const endLocal = `${endDt.getFullYear()}-${String(endDt.getMonth()+1).padStart(2,'0')}-${String(endDt.getDate()).padStart(2,'0')}T${String(endDt.getHours()).padStart(2,'0')}:${String(endDt.getMinutes()).padStart(2,'0')}:00`;

          // Build attendees: mentorado + convidados extras (do NOT auto-add logged-in user;
          // the organizing account is adm@allindigitalmarketing.com.br via DWD impersonation,
          // so logged-in user is not part of the meeting unless they add themselves to convidados_extras)
          const attendees = [];
          if (f.email) attendees.push(f.email);
          for (const e of extras) if (!attendees.includes(e)) attendees.push(e);

          const calRes = await fetch(`${CONFIG.API_BASE}/api/calendar/create-event`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
            body: JSON.stringify({
              summary: titulo,
              start_iso: startLocal,
              end_iso: endLocal,
              description: `${f.notas || ''}\n\nTipo: ${f.tipo}\nMentorado: ${f.mentorado}\nZoom: ${zoomUrl || 'N/A'}`,
              attendees,
              location: zoomUrl || '',
            }),
          });
          const calData = await calRes.json();
          if (!calRes.ok) {
            console.error('[Schedule] Calendar create failed', calRes.status, calData);
            this.toast?.(`Calendar: ${calData.error || calRes.status}`, 'warning');
          }
          if (calData.html_link) calendarUrl = calData.html_link;
          if (calData.event_id) gcalEventId = calData.event_id;
        } catch (e) {
          console.warn('[Schedule] Calendar creation warning:', e.message);
          this.toast?.(`Calendar falhou: ${e.message}`, 'warning');
        }

        // Then: Insert into Supabase with links
        if (!sb) {
          this.toast('Supabase não conectado', 'error');
          return;
        }
        const insertObj = {
          mentorado_id: menteeId,
          // Inclui offset BRT (-03:00) explicitamente — sem isso o Postgres TIMESTAMPTZ
          // assume UTC, e o horario aparece -3h no Spalla. Calendar/Zoom acertam porque
          // o backend ja envia timeZone:America/Sao_Paulo no payload.
          data_call: `${f.data}T${f.horario}:00-03:00`,
          duracao_minutos: parseInt(f.duracao) || 60,
          tipo: f.tipo || 'acompanhamento',
          status_call: 'agendada',
          participantes: JSON.stringify([f.email || '']),
          observacoes_equipe: f.notas || '',
          link_gravacao: zoomUrl || null,
          zoom_topic: titulo,
        };
        if (gcalEventId) insertObj.google_calendar_event_id = gcalEventId;
        const { data: callData, error } = await sb
          .from('calls_mentoria')
          .insert(insertObj)
          .select();

        if (error) throw error;

        this.toast('Call agendada: Zoom ' + (zoomUrl ? '✓' : '○') + ' Calendar ' + (calendarUrl ? '✓' : '○'), 'success');

        // ClickUp sync (whitelist filtered backend-side: onboarding/estrategia/apresentacao/oferta)
        try {
          const cuRes = await fetch(`${CONFIG.API_BASE}/api/clickup/create-milestone`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
            body: JSON.stringify({
              mentee_name: f.mentorado,
              tipo: f.tipo,
              data_call_iso: `${f.data}T${f.horario}:00-03:00`,
              duracao_min: parseInt(f.duracao) || 60,
              zoom_url: zoomUrl || '',
              gcal_event_id: gcalEventId || '',
            }),
          });
          const cuData = await cuRes.json();
          if (cuData.task_id) {
            this.toast(`✓ Task no ClickUp: ${cuData.list_name}`, 'success');
          } else if (cuData.skipped) {
            console.log('[ClickUp] skipped:', cuData.reason);
          } else if (cuData.error === 'no_list_for_mentee') {
            this.toast(`⚠ Sem lista ClickUp pra ${f.mentorado} — crie em Mentorados`, 'warning');
          } else if (cuData.error) {
            this.toast(`ClickUp falhou: ${cuData.reason || cuData.error}`, 'warning');
          }
        } catch (e) {
          console.warn('[ClickUp] sync warning:', e.message);
        }

        // Store locally for immediate UI update
        if (!this.data.scheduledCalls) this.data.scheduledCalls = [];
        this.data.scheduledCalls.push({
          id: callData[0]?.id,
          mentorado: f.mentorado,
          mentorado_id: menteeId,
          data: f.data,
          horario: f.horario,
          tipo: f.tipo,
          titulo: titulo,
        });

        this.ui.scheduleModal = false;
        this.ui.gcalConflict = null;
        this.ui._conflictConfirmed = false;
        this.scheduleForm = { mentorado: '', mentorado_id: '', tipo: 'acompanhamento', data: '', horario: '10:00', duracao: 60, email: '', convidados_extras: '', notas: '' };

        // Send WhatsApp invite to mentorado
        if (menteeId && sb) {
          try {
            const { data: groups } = await sb.from('wa_groups').select('group_jid').eq('mentorado_id', menteeId).limit(1);
            if (groups?.length) {
              const jid = groups[0].group_jid;
              const dataFormatada = new Date(`${f.data}T12:00:00`).toLocaleDateString('pt-BR', { weekday: 'long', day: 'numeric', month: 'long' });
              const text = `📞 *Call agendada!*\n\n📅 ${dataFormatada} às ${f.horario}\n⏱ ${f.duracao} minutos\n🎯 Tipo: ${f.tipo}\n${zoomUrl ? '🔗 Link: ' + zoomUrl : ''}\n\nTe espero lá!`;
              const { instance } = this._waActiveInstance();
              if (instance) {
                await fetch(`${CONFIG.API_BASE}/api/wa/send-text`, {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
                  body: JSON.stringify({ number: jid, text, instance, group_jid: jid }),
                });
              }
            }
          } catch (e) { console.warn('[Schedule] WA invite failed:', e); }
        }

        // Refresh upcoming calls + gcal events
        this.fetchUpcomingCalls();
        this.fetchGcalEvents();

      } catch (err) {
        console.error('[Schedule]', err);
        this.toast('Erro ao agendar: ' + err.message, 'error');
      } finally {
        this.ui.scheduling = false;
      }
    },

    // ===================== SCHEDULE API HELPERS =====================

    async deleteCall(callId) {
      if (!callId || !sb) return;
      if (!confirm('Tem certeza que deseja excluir esta call? Essa ação não pode ser desfeita.')) return;
      try {
        const { error } = await sb.from('calls_mentoria').delete().eq('id', callId);
        if (error) throw error;
        // Remove from local arrays
        this._supabaseCalls = (this._supabaseCalls || []).filter(c => c.call_id !== callId);
        this.data.upcomingCalls = (this.data.upcomingCalls || []).filter(c => c.id !== callId);
        // Remove from detail calls if open
        if (this.data.detail?.last_calls) {
          this.data.detail.last_calls = this.data.detail.last_calls.filter(c => c.call_id !== callId);
        }
        this.ui.expandedCall = null;
        this.toast('Call excluída', 'success');
      } catch (e) {
        this.toast('Erro ao excluir: ' + e.message, 'error');
      }
    },

    async fetchUpcomingCalls() {
      try {
        if (!sb) {
          return;
        }

        // Fetch calls with status 'agendada'
        const { data: agendadas, error: err1 } = await sb
          .from('calls_mentoria')
          .select('*')
          .eq('status_call', 'agendada')
          .order('data_call', { ascending: true });

        // Also fetch future calls (data_call >= today) that may not have status set
        const today = new Date().toISOString().substring(0, 10);
        const { data: futuras, error: err2 } = await sb
          .from('calls_mentoria')
          .select('*')
          .gte('data_call', today)
          .order('data_call', { ascending: true });

        if (err1) console.warn('[Schedule] agendadas query error:', err1);
        if (err2) console.warn('[Schedule] futuras query error:', err2);

        // Merge and deduplicate by id, only keep future calls
        const now = new Date();
        const allCalls = [...(agendadas || []), ...(futuras || [])];
        const seen = new Set();
        const calls = allCalls.filter(c => {
          if (seen.has(c.id)) return false;
          seen.add(c.id);
          // Only include calls that haven't happened yet
          if (c.status_call === 'realizada') return false;
          const raw = String(c.data_call);
          const dt = raw.includes('T') ? new Date(c.data_call) : new Date(raw + 'T23:59:59');
          return dt >= now;
        });

        this.data.scheduledCalls = calls.map(c => {
          const raw = String(c.data_call);
          const dataCall = raw.includes('T') ? new Date(c.data_call) : new Date(raw + 'T12:00:00');
          const mentee = this.data.mentees?.find(m => m.id === c.mentorado_id);

          return {
            id: c.id,
            mentorado: mentee?.nome || '',
            mentorado_id: c.mentorado_id,
            data: dataCall.toLocaleDateString('pt-BR'),
            horario: raw.includes('T') ? dataCall.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' }) : '',
            tipo: c.tipo || 'acompanhamento',
            duracao: c.duracao_minutos || 60,
            status: c.status_call || 'agendada',
            zoom_url: c.link_gravacao || null,
            google_calendar_event_id: c.google_calendar_event_id || null,
          };
        });
      } catch (e) {
      }
    },


    async cancelScheduledCall(sc) {
      if (!confirm(`Cancelar call com ${sc.mentorado}?`)) return;
      try {
        if (!sb) return;
        // Update status in Supabase
        const { error } = await sb
          .from('calls_mentoria')
          .update({ status_call: 'cancelada' })
          .eq('id', sc.id);
        if (error) throw error;

        // Delete from Google Calendar if event_id exists
        if (sc.google_calendar_event_id) {
          try {
            await fetch(`${CONFIG.API_BASE}/api/calendar/event/${sc.google_calendar_event_id}`, { method: 'DELETE' });
          } catch (e) {
            console.warn('[Schedule] GCal delete warning:', e.message);
          }
        }

        this.toast('Call cancelada', 'success');
        this.fetchUpcomingCalls();
        this.fetchGcalEvents();
      } catch (e) {
        console.error('[Schedule] Cancel error:', e);
        this.toast('Erro ao cancelar: ' + e.message, 'error');
      }
    },

    async fetchGcalEvents() {
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/calendar/events`);
        const result = await res.json();
        this.data.gcalEvents = (result.events || []).map(e => ({
          id: e.id,
          summary: e.summary || '',
          start: e.start?.dateTime || e.start?.date || '',
          end: e.end?.dateTime || e.end?.date || '',
          htmlLink: e.htmlLink || '',
        }));
      } catch (e) {
        console.warn('[GCal] fetchGcalEvents error:', e.message);
        this.data.gcalEvents = [];
      }
    },

    async updateInstagramProfiles() {
      /**
       * Fetch real Instagram profile data from Apify for all mentees
       * Runs in background, updates follower counts automatically
       */
      try {
        if (!this.data.mentees?.length) return;

        // Collect all Instagram handles from mentees
        const handles = this.data.mentees
          .filter(m => m.instagram)
          .map(m => m.instagram);

        if (!handles.length) {
          return;
        }


        // Call the Apify integration function from data.js
        if (typeof fetchInstagramProfilesFromApify === 'function') {
          const profiles = await fetchInstagramProfilesFromApify(handles);

          // Merge results into INSTAGRAM_PROFILES (updates follower counts)
          Object.assign(INSTAGRAM_PROFILES, profiles);

          // Count successful updates
          const updated = Object.keys(profiles).length;

          // Trigger photo tick update to refresh any displayed follower counts
          this.photoTick++;
        }
      } catch (e) {
        console.warn('[Instagram] Could not update profiles:', e.message);
      }
    },

    // ===================== DOSSIER HELPERS =====================

    dossierStatusConfig(status) {
      return DOSSIER_STATUS_CONFIG[status] || DOSSIER_STATUS_CONFIG.nao_iniciado;
    },

    // DEPRECATED: stats now computed from dsProducoes (Supabase data)
    dossierStats() {
      const prods = this.data.dsProducoes;
      const total = prods.length;
      const enviados = prods.filter(p => p.status === 'enviado' || p.status === 'finalizado').length;
      const emRevisao = prods.filter(p => p.status === 'revisao').length;
      const producaoIa = prods.filter(p => p.status === 'producao').length;
      const naoIniciado = prods.filter(p => ['nao_iniciado', 'call_estrategia', 'pausado'].includes(p.status)).length;
      return { total, enviados, emRevisao, producaoIa, naoIniciado };
    },

    dossierSearchUrl(title) {
      if (!title) return null;
      const direct = getDossierDirectLink(title);
      if (direct) return direct;
      return `https://drive.google.com/drive/search?q=${encodeURIComponent(title)}`;
    },

    // ===================== DOSSIÊ PRODUCTION SYSTEM =====================

    // --- DS Config helpers ---
    dsEstagioConfig(estagio) {
      return DS_ESTAGIOS.find(e => e.id === estagio) || DS_ESTAGIOS[0];
    },

    dsDocTipoConfig(tipo) {
      return DS_DOC_TIPOS.find(t => t.id === tipo) || DS_DOC_TIPOS[0];
    },

    dsStatusConfig(status) {
      return DS_STATUS_PRODUCAO.find(s => s.id === status) || DS_STATUS_PRODUCAO[0];
    },

    dsAllStatuses() {
      return DS_STATUS_PRODUCAO;
    },

    dsEstagioNum(estagio) {
      const idx = DS_ESTAGIOS.findIndex(e => e.id === estagio);
      return idx >= 0 ? idx + 1 : 0;
    },

    dsAgingClass(dias) {
      if (dias == null) return '';
      if (dias <= 2) return 'ds-aging--green';
      if (dias <= 5) return 'ds-aging--yellow';
      if (dias <= 10) return 'ds-aging--orange';
      return 'ds-aging--red';
    },

    dsProgressPercent(estagio, trilha) {
      const stages = trilha ? this.dsEstagiosForTrilha(trilha) : DS_ESTAGIOS;
      const idx = stages.findIndex(e => e.id === estagio);
      const num = idx >= 0 ? idx + 1 : 0;
      return Math.round((num / stages.length) * 100);
    },

    // --- DS Data Loading ---
    async loadDsData() {
      if (!sb) return;
      this.ui.dsLoading = true;
      try {
        const [prodRes, docsRes] = await Promise.all([
          sb.from('vw_ds_pipeline').select('*').order('mentorado_nome'),
          sb.from('ds_documentos').select('id, producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, estagio_desde, link_doc, ordem, prazo_entrega, prazos_etapas, rev_paralela_gobbi, rev_paralela_kaique').order('ordem'),
        ]);
        if (prodRes.data) this.data.dsProducoes = prodRes.data;
        if (docsRes.data) this.data.dsAllDocs = docsRes.data;
        // Pre-load Biblioteca so hasBibDoc() works on first render
        if (!this.bib.docs.length) this.loadBiblioteca();
        // Auto-sync status for all non-paused/cancelled productions
        this._autoSyncDsStatuses();
      } catch (e) {
        console.error('[DS] loadDsData error:', e);
      } finally {
        this.ui.dsLoading = false;
      }
    },

    async _autoSyncDsStatuses() {
      if (!sb) return;
      const skipStatuses = ['pausado', 'cancelado'];
      for (const prod of this.data.dsProducoes) {
        if (skipStatuses.includes(prod.status)) continue;
        const docs = this.data.dsAllDocs.filter(d => d.producao_id === prod.producao_id);
        if (!docs.length) continue;
        const stages = docs.map(d => this.dsEstagioNum(d.estagio_atual));
        const minStage = Math.min(...stages);
        let expected;
        if (stages.every(s => s >= 10)) expected = 'finalizado';
        else if (stages.every(s => s >= 9)) expected = 'aprovado';
        else if (stages.every(s => s >= 6)) expected = 'enviado';
        else if (minStage >= 3) expected = 'revisao';
        else if (minStage >= 2) expected = 'producao';
        else expected = 'nao_iniciado';
        if (expected !== prod.status) {
          const mostBehind = docs.reduce((a, b) => this.dsEstagioNum(a.estagio_atual) <= this.dsEstagioNum(b.estagio_atual) ? a : b);
          await sb.from('ds_producoes').update({ status: expected, responsavel_atual: mostBehind.responsavel_atual }).eq('id', prod.producao_id);
          prod.status = expected;
          prod.responsavel_atual = mostBehind.responsavel_atual;
        }
      }
    },

    async loadDsMenteeDetail(producaoId) {
      if (!sb) return;
      this.ui.dsLoading = true;
      try {
        const [prodRes, docsRes, eventsRes, ajustesRes, filesRes] = await Promise.all([
          sb.from('ds_producoes').select('*').eq('id', producaoId).single(),
          sb.from('ds_documentos').select('*').eq('producao_id', producaoId).order('ordem'),
          sb.from('ds_eventos').select('*').eq('producao_id', producaoId).order('created_at', { ascending: false }).limit(50),
          sb.from('ds_ajustes').select('*').eq('producao_id', producaoId).order('created_at', { ascending: false }),
          sb.from('ds_briefing_files').select('*').eq('producao_id', producaoId).order('created_at'),
        ]);
        if (prodRes.data) this.data.dsMenteeDetail = prodRes.data;
        if (docsRes.data) this.data.dsAllDocs = docsRes.data;
        if (eventsRes.data) this.data.dsEventos = eventsRes.data;
        if (ajustesRes.data) this.data.dsAjustes = ajustesRes.data;
        this.data.dsBriefingFiles = filesRes?.data || [];
      } catch (e) {
        console.error('[DS] loadDsMenteeDetail error:', e);
      } finally {
        this.ui.dsLoading = false;
      }
    },

    getDsForMentee(mentoradoId) {
      return this.data.dsProducoes.find(p => p.mentorado_id === mentoradoId) || null;
    },

    getDsDocs(producaoId) {
      return this.data.dsAllDocs.filter(d => d.producao_id === producaoId);
    },

    // --- DS KPIs ---
    // --- DS News (Command Center card) ---
    dsNewsEntregues() {
      const now = new Date(); now.setHours(0,0,0,0);
      const weekAgo = new Date(now.getTime() - 7 * 86400000);
      return this.data.dsAllDocs.filter(d => {
        if (d.estagio_atual !== 'finalizado') return false;
        const dt = d.updated_at ? new Date(d.updated_at) : null;
        return dt && dt >= weekAgo;
      }).map(d => {
        const prod = this.data.dsProducoes.find(p => p.producao_id === d.producao_id);
        return { ...d, mentorado_nome: prod?.mentorado_nome || '?', responsavel: d.responsavel_atual || prod?.responsavel_atual || '-' };
      });
    },
    dsNewsEmProducao() {
      return this.data.dsAllDocs.filter(d => {
        if (d.estagio_atual === 'finalizado' || d.estagio_atual === 'pendente') return false;
        const prod = this.data.dsProducoes.find(p => p.producao_id === d.producao_id);
        return prod && !['pausado', 'cancelado', 'finalizado'].includes(prod.status);
      }).map(d => {
        const prod = this.data.dsProducoes.find(p => p.producao_id === d.producao_id);
        const aging = d.estagio_desde ? Math.floor((Date.now() - new Date(d.estagio_desde).getTime()) / 86400000) : 0;
        return { ...d, mentorado_nome: prod?.mentorado_nome || '?', aging };
      }).sort((a, b) => b.aging - a.aging);
    },
    dsNewsCriticos() {
      const today = new Date(); today.setHours(0,0,0,0);
      return this.data.dsAllDocs.filter(d => {
        if (d.estagio_atual === 'finalizado') return false;
        const prod = this.data.dsProducoes.find(p => p.producao_id === d.producao_id);
        if (!prod || ['pausado', 'cancelado'].includes(prod.status)) return false;
        if (d.prazo_entrega) { const dt = new Date(d.prazo_entrega + 'T00:00:00'); if ((dt - today) / 86400000 <= 3) return true; }
        if (d.prazos_etapas && d.prazos_etapas[d.estagio_atual]) { const dt = new Date(d.prazos_etapas[d.estagio_atual] + 'T00:00:00'); if ((dt - today) / 86400000 <= 3) return true; }
        if (prod.prazo_entrega) { const dt = new Date(prod.prazo_entrega + 'T00:00:00'); if ((dt - today) / 86400000 <= 3) return true; }
        return false;
      }).map(d => {
        const prod = this.data.dsProducoes.find(p => p.producao_id === d.producao_id);
        const prazo = d.prazo_entrega || d.prazos_etapas?.[d.estagio_atual] || prod?.prazo_entrega;
        const diff = prazo ? Math.round((new Date(prazo + 'T00:00:00') - today) / 86400000) : null;
        return { ...d, mentorado_nome: prod?.mentorado_nome || '?', prazo, diff, producao_id: d.producao_id };
      }).sort((a, b) => (a.diff ?? 99) - (b.diff ?? 99));
    },
    dsNewsProximasApresentacoes() {
      const today = new Date(); today.setHours(0,0,0,0);
      const results = [];
      this.data.dsProducoes.forEach(p => {
        if (['pausado', 'cancelado', 'finalizado'].includes(p.status)) return;
        if (p.data_call_apresentacao_oferta) {
          const dt = new Date(p.data_call_apresentacao_oferta + 'T00:00:00');
          if (dt >= new Date(today.getTime() - 86400000)) results.push({ mentorado_nome: p.mentorado_nome, tipo: '◆ Apres. Oferta', data: p.data_call_apresentacao_oferta, diff: Math.round((dt - today) / 86400000), producao_id: p.producao_id });
        }
        if (p.data_call_apresentacao_pos_funil) {
          const dt = new Date(p.data_call_apresentacao_pos_funil + 'T00:00:00');
          if (dt >= new Date(today.getTime() - 86400000)) results.push({ mentorado_nome: p.mentorado_nome, tipo: '▽◈ Apres. Pos+Funil', data: p.data_call_apresentacao_pos_funil, diff: Math.round((dt - today) / 86400000), producao_id: p.producao_id });
        }
        const docs = this.data.dsAllDocs.filter(d => d.producao_id === p.producao_id && d.prazo_entrega && d.estagio_atual !== 'finalizado');
        docs.forEach(d => {
          const dt = new Date(d.prazo_entrega + 'T00:00:00');
          if (dt >= new Date(today.getTime() - 86400000)) {
            const icon = d.tipo === 'oferta' ? '◆' : d.tipo === 'funil' ? '▽' : '◈';
            results.push({ mentorado_nome: p.mentorado_nome, tipo: icon + ' Entrega ' + (this.dsDocTipoConfig(d.tipo)?.label || d.tipo), data: d.prazo_entrega, diff: Math.round((dt - today) / 86400000), producao_id: p.producao_id });
          }
        });
      });
      return results.sort((a, b) => a.diff - b.diff);
    },

    dsPageKpis() {
      const prods = this.data.dsProducoes;
      const total = prods.length;
      const producaoIa = prods.filter(p => p.status === 'producao').length;
      const emRevisao = prods.filter(p => p.status === 'revisao').length;
      const aprovados = prods.filter(p => p.status === 'aprovado').length;
      const enviados = prods.filter(p => p.status === 'enviado' || p.status === 'apresentado').length;
      const finalizados = prods.filter(p => p.status === 'finalizado').length;
      const agingArr = prods.filter(p => p.dias_no_estagio != null && !['finalizado', 'cancelado', 'pausado'].includes(p.status)).map(p => p.dias_no_estagio);
      const agingMedio = agingArr.length ? Math.round(agingArr.reduce((a, b) => a + b, 0) / agingArr.length) : 0;
      return { total, producaoIa, emRevisao, aprovados, enviados, finalizados, agingMedio };
    },

    // --- DS Filters ---
    get filteredDsProducoes() {
      let list = this.data.dsProducoes;
      // Status filter
      if (this.ui.dsFilter === 'all') {
        // Hide paused/cancelled by default
        list = list.filter(p => !['pausado', 'cancelado'].includes(p.status));
      } else {
        const statusMap = {
          nao_iniciado: ['nao_iniciado', 'call_estrategia'],
          producao: ['producao'],
          revisao: ['revisao'],
          aprovado: ['aprovado'],
          enviado: ['enviado', 'apresentado'],
          finalizado: ['finalizado'],
          pausado: ['pausado', 'cancelado'],
        };
        const statuses = statusMap[this.ui.dsFilter] || [this.ui.dsFilter];
        list = list.filter(p => statuses.includes(p.status));
      }
      // Carteira filter
      if (this.ui.dsCarteira && this.ui.dsCarteira !== 'all') {
        list = list.filter(p => (p.carteira || '').toLowerCase() === this.ui.dsCarteira.toLowerCase());
      }
      // Tipo doc filter (filter by which doc types have non-finalized stages)
      if (this.ui.dsTipoDoc && this.ui.dsTipoDoc !== 'all') {
        const tipo = this.ui.dsTipoDoc;
        list = list.filter(p => {
          const docs = this.data.dsAllDocs.filter(d => d.producao_id === p.producao_id && d.tipo === tipo);
          return docs.length > 0;
        });
      }
      // Search filter
      if (this.ui.dsSearchQuery) {
        const q = this.ui.dsSearchQuery.toLowerCase();
        list = list.filter(p => (p.mentorado_nome || '').toLowerCase().includes(q) || (p.responsavel_atual || '').toLowerCase().includes(q));
      }
      // Sort: active first (producao, revisao, aprovado, enviado), then nao_iniciado, then finalizado last
      const statusOrder = { producao: 0, revisao: 1, aprovado: 2, enviado: 3, apresentado: 4, call_estrategia: 5, nao_iniciado: 6, finalizado: 9 };
      list = [...list].sort((a, b) => (statusOrder[a.status] ?? 7) - (statusOrder[b.status] ?? 7));
      return list;
    },

    dsPipelineColumns() {
      const cols = {};
      DS_ESTAGIOS.forEach(e => { cols[e.id] = []; });
      this.filteredDsProducoes.forEach(p => {
        // Determine column by the most-behind doc's actual stage
        const docs = this.data.dsAllDocs.filter(d => d.producao_id === p.producao_id);
        if (!docs.length) { cols['pendente'].push(p); return; }
        const trilha = p.trilha || 'scale';
        const stages = this.dsEstagiosForTrilha(trilha);
        let minIdx = stages.length - 1;
        docs.forEach(d => {
          const idx = stages.findIndex(s => s.id === d.estagio_atual);
          if (idx >= 0 && idx < minIdx) minIdx = idx;
        });
        const estagio = stages[minIdx];
        if (estagio && cols[estagio.id]) cols[estagio.id].push(p);
        else cols['pendente'].push(p);
      });
      return cols;
    },

    // --- DS CRUD + Handoff ---
    _docTrilha(doc) {
      const prod = this.data.dsProducoes.find(p => p.producao_id === doc.producao_id);
      return prod?.trilha || 'scale';
    },

    async advanceDocStage(docId, notas) {
      if (!sb) return;
      const doc = this.data.dsAllDocs.find(d => d.id === docId);
      if (!doc) return;
      const trilha = this._docTrilha(doc);
      const stages = this.dsEstagiosForTrilha(trilha);
      const curIdx = stages.findIndex(e => e.id === doc.estagio_atual);
      if (curIdx < 0 || curIdx >= stages.length - 1) return;

      // Dependency check: enviado requires all docs approved (admin can override)
      const nextEstagio = stages[curIdx + 1];
      if (nextEstagio.id === 'enviado') {
        const siblings = this.data.dsAllDocs.filter(d => d.producao_id === doc.producao_id && d.id !== docId);
        const allApproved = siblings.every(s => this.dsEstagioNum(s.estagio_atual) >= this.dsEstagioNum('aprovado'));
        if (!allApproved) {
          if (!confirm('Os outros documentos do dossiê (oferta/funil/conteúdo) ainda não passaram por todas as revisões. Enviar este documento mesmo assim?')) return;
        }
      }

      const user = this.currentUserName;
      const proximoResp = nextEstagio.responsavel || user;
      const now = new Date().toISOString();

      // Build update object
      const update = {
        estagio_atual: nextEstagio.id,
        responsavel_atual: nextEstagio.responsavel || null,
        estagio_desde: now,
      };
      // Set timestamp for the stage
      const tsField = 'data_' + nextEstagio.id.replace('revisao_', 'revisao_');
      const tsMap = {
        producao_ia: 'data_producao_ia',
        revisao_mariza: 'data_revisao_mariza',
        revisao_kaique: 'data_revisao_kaique',
        revisao_queila: 'data_revisao_queila',
        revisao_gobbi: 'data_revisao_queila',
        revisao_paralela: 'data_revisao_queila',
        enviado: 'data_envio',
        feedback_mentorado: 'data_feedback_mentorado',
        finalizado: 'data_finalizado',
      };
      if (tsMap[nextEstagio.id]) update[tsMap[nextEstagio.id]] = now;

      const { error } = await sb.from('ds_documentos').update(update).eq('id', docId);
      if (error) { this.toast('Erro ao avançar estágio: ' + error.message, 'error'); return; }

      // Log event
      await this._logDsEvento(doc.producao_id, docId, 'estagio_change', doc.estagio_atual, nextEstagio.id, user, notas || `Avançou para ${nextEstagio.label}`);

      // Auto-update producao status
      await this._updateDsProducaoStatus(doc.producao_id);

      // Refresh
      await this.loadDsMenteeDetail(doc.producao_id);
      await this.loadDsData();
      this.toast(`Avançou para ${nextEstagio.label}`, 'success');
    },

    async regressDocStage(docId, motivo) {
      if (!sb) return;
      const doc = this.data.dsAllDocs.find(d => d.id === docId);
      if (!doc) return;
      const curIdx = DS_ESTAGIOS.findIndex(e => e.id === doc.estagio_atual);
      if (curIdx <= 0) return;

      const prevEstagio = DS_ESTAGIOS[curIdx - 1];
      const user = this.currentUserName;

      const { error } = await sb.from('ds_documentos').update({
        estagio_atual: prevEstagio.id,
        responsavel_atual: prevEstagio.responsavel || null,
        estagio_desde: new Date().toISOString(),
      }).eq('id', docId);

      if (error) { this.toast('Erro ao voltar estágio: ' + error.message, 'error'); return; }

      await this._logDsEvento(doc.producao_id, docId, 'estagio_change', doc.estagio_atual, prevEstagio.id, user, motivo || `Retornou para ${prevEstagio.label}`);
      await this._updateDsProducaoStatus(doc.producao_id);
      await this.loadDsMenteeDetail(doc.producao_id);
      await this.loadDsData();
      this.toast(`Retornou para ${prevEstagio.label}`, 'info');
    },

    dsPromptRegress(docId) {
      const doc = this.data.dsAllDocs.find(d => d.id === docId);
      if (!doc) return;
      const curStage = this.dsEstagioConfig(doc.estagio_atual);
      const motivo = prompt(`Motivo para retornar de "${curStage.label}":`);
      if (motivo === null) return; // cancelled
      if (!motivo.trim()) { this.toast('Informe o motivo para voltar o estagio', 'warning'); return; }
      this.regressDocStage(docId, motivo.trim());
    },

    async createAdjustmentTask(doc) {
      if (!doc || !sb) return;
      const prod = this.data.dsProducoes.find(p => p.producao_id === doc.producao_id);
      const mentoradoNome = prod?.mentorado_nome || doc.mentorado_nome || '';
      const tipoLabel = { oferta: 'Oferta', posicionamento: 'Posicionamento', funil: 'Funil' }[doc.tipo] || doc.tipo || '';
      const estagio = this.dsEstagioConfig(doc.estagio_atual);
      const user = this.currentUserName;

      // Pre-fill task form and open modal for user to complete
      this.taskForm.titulo = `Ajuste dossiê — ${mentoradoNome}${tipoLabel ? ' (' + tipoLabel + ')' : ''}`;
      this.taskForm.descricao = `Dossiê: ${tipoLabel} | Etapa: ${estagio?.label || doc.estagio_atual} | Solicitado por: ${user}\n\nO que precisa ajustar:\n`;
      this.taskForm.tipo = 'ajuste_dossie';
      this.taskForm.prioridade = 'alta';
      this.taskForm.mentorado_nome = mentoradoNome;
      this.taskForm.doc_link = doc.link_doc || '';
      this.taskForm.space_id = 'space_entregas';
      this.taskForm.list_id = 'list_dossies';
      this.taskForm.tags = ['ajuste-dossie'];
      this.ui.taskEditId = null;
      this.ui.taskModal = true;
    },

    async updateDsStatus(producaoId, newStatus) {
      if (!sb || !newStatus) return;
      const oldStatus = this.data.dsMenteeDetail?.status;
      const { error } = await sb.from('ds_producoes').update({ status: newStatus }).eq('id', producaoId);
      if (error) { this.toast('Erro ao atualizar status: ' + error.message, 'error'); return; }
      const user = this.currentUserName;
      await this._logDsEvento(producaoId, null, 'status_change', oldStatus, newStatus, user, `Status: ${oldStatus} → ${newStatus}`);
      await this.loadDsData();
      if (this.data.dsMenteeDetail) this.data.dsMenteeDetail.status = newStatus;
      this.toast('Status atualizado', 'success');
    },

    async saveDsNotas(producaoId, notas) {
      if (!sb) return;
      const { error } = await sb.from('ds_producoes').update({ notas }).eq('id', producaoId);
      if (error) this.toast('Erro ao salvar notas: ' + error.message, 'error');
      else this.toast('Notas salvas', 'success');
    },

    async updateContrato(producaoId, valor) {
      if (!sb) return;
      const { error } = await sb.from('ds_producoes').update({ contrato_assinado: valor }).eq('id', producaoId);
      if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      const user = this.currentUserName;
      await this._logDsEvento(producaoId, null, 'nota', null, valor, user, `Contrato: ${valor}`);
      await this.loadDsData();
      this.toast('Contrato atualizado', 'success');
    },

    async setCallDate(producaoId, campo, data) {
      if (!sb) return;
      const update = {};
      update[campo] = data || null;
      const { error } = await sb.from('ds_producoes').update(update).eq('id', producaoId);
      if (error) this.toast('Erro: ' + error.message, 'error');
      else {
        const user = this.currentUserName;
        await this._logDsEvento(producaoId, null, 'nota', null, data, user, `${campo} definido: ${data}`);
        await this.loadDsData();
        this.toast('Data atualizada', 'success');
      }
    },

    getStagePrazo(doc, stageId) {
      if (!doc || !doc.prazos_etapas) return '';
      return doc.prazos_etapas[stageId] || '';
    },

    async setStagePrazo(docId, producaoId, stageId, data) {
      if (!sb) return;
      const doc = this.data.dsAllDocs.find(d => d.id === docId);
      if (!doc) return;
      const prazos = { ...(doc.prazos_etapas || {}) };
      if (data) prazos[stageId] = data;
      else delete prazos[stageId];
      const { error } = await sb.from('ds_documentos').update({ prazos_etapas: prazos }).eq('id', docId);
      if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      doc.prazos_etapas = prazos;
      const user = this.currentUserName;
      const stageLabel = DS_ESTAGIOS.find(s => s.id === stageId)?.label || stageId;
      await this._logDsEvento(producaoId, docId, 'nota', null, data, user, `Prazo ${stageLabel}: ${data || 'removido'}`);
      this.toast(`Prazo ${stageLabel} atualizado`, 'success');
    },

    async setDocPrazo(docId, producaoId, data) {
      if (!sb) return;
      const { error } = await sb.from('ds_documentos').update({ prazo_entrega: data || null }).eq('id', docId);
      if (error) this.toast('Erro: ' + error.message, 'error');
      else {
        const user = this.currentUserName;
        await this._logDsEvento(producaoId, docId, 'nota', null, data, user, `prazo_entrega doc definido: ${data}`);
        await this.loadDsData();
        if (this.data.dsMenteeDetail) await this.loadDsMenteeDetail(producaoId);
        this.toast('Prazo do dossiê atualizado', 'success');
      }
    },

    async createAjuste(producaoId, docId, descricao, responsavel, deadline) {
      if (!sb || !descricao) return;
      const mentoradoId = this.data.dsMenteeDetail?.mentorado_id;
      const { error } = await sb.from('ds_ajustes').insert({
        producao_id: producaoId,
        documento_id: docId || null,
        mentorado_id: mentoradoId,
        descricao,
        responsavel: responsavel || null,
        deadline: deadline || null,
      });
      if (error) { this.toast('Erro ao criar ajuste: ' + error.message, 'error'); return; }
      const user = this.currentUserName;
      await this._logDsEvento(producaoId, docId, 'ajuste_criado', null, descricao, user, `Ajuste: ${descricao}`);
      await this.loadDsMenteeDetail(producaoId);
      this.toast('Ajuste criado', 'success');
    },

    async toggleAjusteStatus(ajusteId) {
      if (!sb) return;
      const aj = this.data.dsAjustes.find(a => a.id === ajusteId);
      if (!aj) return;
      const nextStatus = aj.status === 'pendente' ? 'em_andamento' : aj.status === 'em_andamento' ? 'concluido' : 'pendente';
      const { error } = await sb.from('ds_ajustes').update({ status: nextStatus }).eq('id', ajusteId);
      if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      if (nextStatus === 'concluido') {
        const user = this.currentUserName;
        await this._logDsEvento(aj.producao_id, aj.documento_id, 'ajuste_concluido', aj.status, 'concluido', user, aj.descricao);
      }
      await this.loadDsMenteeDetail(aj.producao_id);
    },

    async _updateDsProducaoStatus(producaoId) {
      if (!sb) return;
      const docs = this.data.dsAllDocs.filter(d => d.producao_id === producaoId);
      if (!docs.length) return;

      const stages = docs.map(d => this.dsEstagioNum(d.estagio_atual));
      const minStage = Math.min(...stages);
      const maxStage = Math.max(...stages);

      // Ordem: 1=pendente 2=producao_ia 3=rev_mariza 4=rev_kaique 5=rev_queila 6=enviado 7=feedback 8=ajustes 9=aprovado 10=finalizado
      let newStatus;
      if (stages.every(s => s >= 10)) newStatus = 'finalizado';
      else if (stages.every(s => s >= 9)) newStatus = 'aprovado';
      else if (stages.every(s => s >= 6)) newStatus = 'enviado';
      else if (minStage >= 3) newStatus = 'revisao';
      else if (minStage >= 2) newStatus = 'producao';
      else newStatus = 'nao_iniciado';

      // Determine current responsavel
      const mostBehindDoc = docs.reduce((a, b) => this.dsEstagioNum(a.estagio_atual) <= this.dsEstagioNum(b.estagio_atual) ? a : b);
      const responsavel = mostBehindDoc.responsavel_atual;

      try { await sb.from('ds_producoes').update({ status: newStatus, responsavel_atual: responsavel }).eq('id', producaoId); }
      catch (e) { console.error('Erro ao atualizar producao:', e); }
    },

    async _logDsEvento(producaoId, docId, tipo, de, para, responsavel, descricao) {
      if (!sb) return;
      const mentoradoId = this.data.dsMenteeDetail?.mentorado_id || null;
      try {
        await sb.from('ds_eventos').insert({
          producao_id: producaoId,
          documento_id: docId || null,
          mentorado_id: mentoradoId,
          tipo_evento: tipo,
          de_valor: de || null,
          para_valor: para || null,
          responsavel,
          descricao,
        });
      } catch (e) { console.error('Erro ao logar evento DS:', e); }
    },

    // --- OB Event Logging (Timeline) ---
    async _logObEvento(trilhaId, etapaId, tarefaId, tipo, de, para, descricao) {
      if (!sb) return;
      try {
        const user = this.currentUserName;
        await sb.from('ob_eventos').insert({
          trilha_id: trilhaId,
          etapa_id: etapaId || null,
          tarefa_id: tarefaId || null,
          tipo_evento: tipo,
          de_valor: de || null,
          para_valor: para || null,
          responsavel: user,
          descricao,
        });
      } catch (e) { console.warn('[OB] _logObEvento failed:', e); }
    },

    dsCanAdvance(doc) {
      if (!doc) return false;
      const trilha = this._docTrilha(doc);
      const stages = this.dsEstagiosForTrilha(trilha);
      const curIdx = stages.findIndex(e => e.id === doc.estagio_atual);
      if (curIdx < 0 || curIdx >= stages.length - 1) return false;
      // Parallel review: block advance until both reviewers approved
      if (doc.estagio_atual === 'revisao_paralela') {
        return doc.rev_paralela_gobbi && doc.rev_paralela_kaique;
      }
      return true;
    },

    async openDsDetail(producaoId) {
      this.ui.dsDetailProducaoId = producaoId;
      await this.loadDsMenteeDetail(producaoId);
    },

    closeDsDetail() {
      this.ui.dsDetailProducaoId = null;
      this.data.dsMenteeDetail = null;
      this.data.dsEventos = [];
      this.data.dsAjustes = [];
      this.data.dsBriefingFiles = [];
    },

    dsBriefingFileUrl(path) {
      if (!sb || !path) return '#';
      const { data } = sb.storage.from('dossie-briefings').getPublicUrl(path);
      return data?.publicUrl || '#';
    },

    async dsDeleteProducao(producaoId) {
      if (!sb || !producaoId) return;
      const prod = this.data.dsProducoes.find(p => p.producao_id === producaoId);
      const nome = prod?.mentorado_nome || 'esta produção';
      if (!confirm(`Excluir a produção de dossiê de "${nome}"?\n\nIsso remove todos os documentos, ajustes, eventos e arquivos associados. Esta ação não pode ser desfeita.`)) return;
      try {
        // Delete storage files
        const files = this.data.dsBriefingFiles || [];
        if (files.length) {
          const paths = files.map(f => f.storage_path);
          const { error: storageErr } = await sb.storage.from('dossie-briefings').remove(paths);
          if (storageErr) console.warn('[DS] storage remove error (continuing):', storageErr);
        }
        // Delete producao (CASCADE removes docs, ajustes, eventos, briefing_files)
        const { error } = await sb.from('ds_producoes').delete().eq('id', producaoId);
        if (error) throw error;
        this.closeDsDetail();
        await this.loadDsData();
        this.toast(`Produção de "${nome}" excluída`, 'success');
      } catch (e) {
        console.error('[DS] deleteProducao error:', e);
        this.toast('Erro ao excluir: ' + (e.message || e), 'error');
      }
    },

    // --- DS Create Production ---
    async openDsCreateModal() {
      this.ui.dsCreateModal = true;
      this.ui.dsCreateForm = { mentorado_id: '', responsavel: '', briefing: '', docs: ['oferta', 'funil', 'conteudo'] };
      this.ui.dsCreateFiles = [];
      // Load mentorados list if not cached
      if (!this._dsMentoradosList) {
        const { data } = await sb.from('mentorados').select('id, nome').eq('status', 'ativo').not('consultor_responsavel', 'is', null).order('nome');
        this._dsMentoradosList = data || [];
      }
    },

    get dsMentoradosList() { return this._dsMentoradosList || []; },

    async dsCreateProducao() {
      if (!sb) return;
      const f = this.ui.dsCreateForm;
      if (!f.mentorado_id) { this.toast('Selecione um mentorado', 'warning'); return; }
      if (!f.docs.length) { this.toast('Selecione pelo menos um dossiê', 'warning'); return; }

      this.ui.dsCreateUploading = true;
      try {
        // 1. Create producao
        const { data: prod, error: prodErr } = await sb.from('ds_producoes').insert({
          mentorado_id: parseInt(f.mentorado_id),
          status: 'nao_iniciado',
          responsavel_atual: f.responsavel || null,
          briefing: f.briefing || null,
        }).select().single();
        if (prodErr) throw prodErr;

        // 2. Create documents (respects trilha)
        const tituloMap = {
          oferta: 'Dossiê de Oferta', funil: 'Dossiê de Funil',
          conteudo: 'Dossiê de Posicionamento', clinic: 'Dossiê Clínica',
        };
        const docs = f.docs.map((tipo, i) => ({
          producao_id: prod.id,
          mentorado_id: parseInt(f.mentorado_id),
          tipo,
          titulo: tituloMap[tipo] || 'Dossiê',
          estagio_atual: 'pendente',
          responsavel_atual: f.responsavel || null,
          ordem: i + 1,
        }));
        const { error: docsErr } = await sb.from('ds_documentos').insert(docs);
        if (docsErr) throw docsErr;

        // 3. Upload files
        for (const file of this.ui.dsCreateFiles) {
          const path = `${prod.id}/${Date.now()}_${file.name}`;
          const { error: uploadErr } = await sb.storage.from('dossie-briefings').upload(path, file);
          if (!uploadErr) {
            await sb.from('ds_briefing_files').insert({
              producao_id: prod.id,
              nome: file.name,
              tipo: file.type,
              tamanho: file.size,
              storage_path: path,
              uploaded_by: this.currentUserName,
            });
          }
        }

        // 4. Log event
        await this._logDsEvento(prod.id, null, 'nota', null, 'producao_criada', this.currentUserName, 'Produção criada com briefing');

        this.ui.dsCreateModal = false;
        await this.loadDsData();
        this.toast('Produção criada com sucesso!', 'success');
      } catch (e) {
        console.error('[DS] createProducao error:', e);
        this.toast('Erro ao criar: ' + (e.message || e), 'error');
      } finally {
        this.ui.dsCreateUploading = false;
      }
    },

    dsToggleDocType(tipo) {
      const idx = this.ui.dsCreateForm.docs.indexOf(tipo);
      if (idx >= 0) this.ui.dsCreateForm.docs.splice(idx, 1);
      else this.ui.dsCreateForm.docs.push(tipo);
    },

    dsHandleFileInput(event) {
      const files = Array.from(event.target.files || []);
      this.ui.dsCreateFiles.push(...files);
      event.target.value = '';
    },

    dsRemoveFile(idx) {
      this.ui.dsCreateFiles.splice(idx, 1);
    },

    async dsStartRecording() {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        const recorder = new MediaRecorder(stream);
        const chunks = [];
        recorder.ondataavailable = e => chunks.push(e.data);
        recorder.onstop = () => {
          const blob = new Blob(chunks, { type: 'audio/webm' });
          const file = new File([blob], `audio_${Date.now()}.webm`, { type: 'audio/webm' });
          this.ui.dsCreateFiles.push(file);
          stream.getTracks().forEach(t => t.stop());
          this.ui.dsRecording = false;
          this.toast('Audio gravado', 'success');
        };
        recorder.start();
        this.ui.dsMediaRecorder = recorder;
        this.ui.dsRecording = true;
      } catch (e) {
        this.toast('Erro ao acessar microfone: ' + e.message, 'error');
      }
    },

    dsStopRecording() {
      if (this.ui.dsMediaRecorder && this.ui.dsMediaRecorder.state === 'recording') {
        this.ui.dsMediaRecorder.stop();
      }
    },

    dsFormatDate(d) {
      if (!d) return '-';
      const parts = String(d).slice(0, 10).split('-');
      return parts[2] + '/' + parts[1];
    },

    dsPrazoClass(prazo) {
      if (!prazo) return '';
      const today = new Date(); today.setHours(0,0,0,0);
      const dt = new Date(prazo + 'T00:00:00');
      const diff = Math.round((dt - today) / 86400000);
      if (diff < 0) return 'ds-deadline--overdue';
      if (diff <= 7) return 'ds-deadline--soon';
      return '';
    },

    dsFormatDateTime(d) {
      if (!d) return '-';
      const dt = new Date(d);
      return dt.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' }) + ' ' + dt.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
    },

    // --- DS Ajuste Form ---
    dsAjusteForm: { descricao: '', responsavel: '', deadline: '', docId: '', etapa: '' },

    dsResetAjusteForm() {
      this.dsAjusteForm = { descricao: '', responsavel: '', deadline: '', docId: '', etapa: '' };
    },

    // --- DS Table Sorting ---
    dsSortBy(field) {
      if (this.ui.dsSortField === field) {
        this.ui.dsSortAsc = !this.ui.dsSortAsc;
      } else {
        this.ui.dsSortField = field;
        this.ui.dsSortAsc = true;
      }
    },

    dsSortedList() {
      const list = [...this.filteredDsProducoes];
      const f = this.ui.dsSortField;
      const asc = this.ui.dsSortAsc;
      list.sort((a, b) => {
        let va = a[f], vb = b[f];
        if (va == null) va = '';
        if (vb == null) vb = '';
        if (typeof va === 'string') va = va.toLowerCase();
        if (typeof vb === 'string') vb = vb.toLowerCase();
        if (va < vb) return asc ? -1 : 1;
        if (va > vb) return asc ? 1 : -1;
        return 0;
      });
      return list;
    },

    async dsSubmitAjuste(producaoId) {
      if (!this.dsAjusteForm.descricao) {
        this.ui.dsAjusteError = true;
        this.toast('Preencha a descricao do ajuste', 'warning');
        return;
      }
      // Build rich description with context
      let desc = this.dsAjusteForm.descricao;
      const docId = this.dsAjusteForm.docId || null;
      const etapa = this.dsAjusteForm.etapa;
      if (etapa) {
        const cfg = this.dsEstagioConfig(etapa);
        desc = `[${cfg.label}] ${desc}`;
      }
      await this.createAjuste(producaoId, docId, desc, this.dsAjusteForm.responsavel, this.dsAjusteForm.deadline);
      this.dsResetAjusteForm();
    },

    // --- DS Pipeline Drag & Drop ---
    dsDragProducaoId: null,
    dsDragOverStage: null,

    dsDragStart(event, producaoId) {
      this.dsDragProducaoId = producaoId;
      event.dataTransfer.effectAllowed = 'move';
      const card = event.target.closest('.ds-pipeline__card');
      if (card) card.classList.add('ds-pipeline__card--dragging');
    },

    dsDragEnd(event) {
      const card = event.target.closest('.ds-pipeline__card');
      if (card) card.classList.remove('ds-pipeline__card--dragging');
      this.dsDragProducaoId = null;
      this.dsDragOverStage = null;
    },

    dsDragOver(event, stageId) {
      event.preventDefault();
      event.dataTransfer.dropEffect = 'move';
      this.dsDragOverStage = stageId;
    },

    dsDragLeave(event, stageId) {
      if (this.dsDragOverStage === stageId) this.dsDragOverStage = null;
    },

    async dsDrop(event, targetStageId) {
      event.preventDefault();
      this.dsDragOverStage = null;
      if (!this.dsDragProducaoId) return;

      const producaoId = this.dsDragProducaoId;
      this.dsDragProducaoId = null;

      // Get mentee info for confirm
      const prod = this.data.dsProducoes.find(p => p.producao_id === producaoId);
      const targetStage = DS_ESTAGIOS.find(e => e.id === targetStageId);
      if (!prod || !targetStage) return;

      const docs = this.data.dsAllDocs.filter(d => d.producao_id === producaoId);
      if (!docs.length) return;

      // Check if already at target
      const targetNum = this.dsEstagioNum(targetStageId);
      const allSame = docs.every(d => this.dsEstagioNum(d.estagio_atual) === targetNum);
      if (allSame) return;

      // Show confirm dialog
      this.ui.dsConfirm = {
        title: `Mover ${prod.mentorado_nome}?`,
        msg: `Todos os 3 documentos serao movidos para "${targetStage.label}". Esta acao sera registrada no historico.`,
        onConfirm: async () => {
          const user = this.currentUserName;
          for (const doc of docs) {
            const curNum = this.dsEstagioNum(doc.estagio_atual);
            if (curNum === targetNum) continue;
            const now = new Date().toISOString();
            const update = {
              estagio_atual: targetStage.id,
              responsavel_atual: targetStage.responsavel || null,
              estagio_desde: now,
            };
            const tsMap = {
              producao_ia: 'data_producao_ia', revisao_mariza: 'data_revisao_mariza',
              revisao_kaique: 'data_revisao_kaique', revisao_queila: 'data_revisao_queila',
              revisao_gobbi: 'data_revisao_queila', revisao_paralela: 'data_revisao_queila',
              enviado: 'data_envio', feedback_mentorado: 'data_feedback_mentorado',
              finalizado: 'data_finalizado',
            };
            if (tsMap[targetStage.id]) update[tsMap[targetStage.id]] = now;
            await sb.from('ds_documentos').update(update).eq('id', doc.id);
            await this._logDsEvento(producaoId, doc.id, 'estagio_change', doc.estagio_atual, targetStage.id, user, `Pipeline: ${doc.tipo} → ${targetStage.label}`);
          }
          await this._updateDsProducaoStatus(producaoId);
          await this.loadDsData();
          this.toast(`Movido para ${targetStage.label}`, 'success');
        },
      };
    },

    isValidGoogleDocsUrl(url) {
      try { new URL(url); } catch { return false; }
      return url.startsWith('https://') && (url.includes('docs.google.com') || url.includes('drive.google.com'));
    },

    async updateDocLink(docId, link) {
      if (!sb) return;
      const { error } = await sb.from('ds_documentos').update({ link_doc: link }).eq('id', docId);
      if (error) this.toast('Erro ao salvar link: ' + error.message, 'error');
      else this.toast('Link salvo', 'success');
    },

    async updateMentoradoTrilha(mentoradoId, trilha) {
      if (!mentoradoId) return;
      try {
        const resp = await fetch(`${CONFIG.API_BASE}/api/mentees/${mentoradoId}`, {
          method: 'PATCH',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.accessToken}` },
          body: JSON.stringify({ trilha }),
        });
        if (!resp.ok) { const e = await resp.json(); throw new Error(e.error || resp.statusText); }
      } catch (e) {
        this.toast('Erro ao atualizar trilha: ' + e.message, 'error');
        return;
      }
      // Update local detail
      if (this.data.detail?.profile) this.data.detail.profile.trilha = trilha;
      // Update mentorados list
      const m = this.data.mentees.find(x => x.id === mentoradoId);
      if (m) m.trilha = trilha;
      // Update pipeline view
      const prod = this.data.dsProducoes.find(x => x.mentorado_id === mentoradoId);
      if (prod) prod.trilha = trilha;
      this.toast('Trilha atualizada para ' + trilha.toUpperCase(), 'success');
    },

    dsDocTiposForTrilha(trilha) {
      const t = DS_TRILHAS.find(x => x.id === trilha);
      return t ? DS_DOC_TIPOS.filter(d => t.docs.includes(d.id)) : DS_DOC_TIPOS.slice(0, 3);
    },

    dsEstagiosForTrilha(trilha) {
      const ids = trilha === 'clinic' ? DS_ESTAGIOS_CLINIC : DS_ESTAGIOS_SCALE;
      return DS_ESTAGIOS.filter(s => ids.includes(s.id));
    },

    async dsToggleParalelaReview(docId, reviewer) {
      if (!sb) return;
      const field = reviewer === 'gobbi' ? 'rev_paralela_gobbi' : 'rev_paralela_kaique';
      const doc = this.data.dsAllDocs.find(d => d.id === docId);
      if (!doc) return;
      const newVal = !doc[field];
      const { error } = await sb.from('ds_documentos').update({ [field]: newVal }).eq('id', docId);
      if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      doc[field] = newVal;
      // Auto-advance if both done
      if (doc.rev_paralela_gobbi && doc.rev_paralela_kaique && doc.estagio_atual === 'revisao_paralela') {
        await this.advanceDocStage(docId);
      }
      this.toast(reviewer.charAt(0).toUpperCase() + reviewer.slice(1) + (newVal ? ' aprovou' : ' desfez aprovação'), newVal ? 'success' : 'info');
    },

    // ===================== ONBOARDING CS =====================

    // --- OB Constants ---
    OB_STATUS: [
      { id: 'em_andamento', label: 'Em Andamento', color: '#3b82f6', icon: '◌' },
      { id: 'concluido', label: 'Concluído', color: '#10b981', icon: '●' },
      { id: 'pausado', label: 'Pausado', color: '#6b7280', icon: '◎' },
    ],

    obStatusLabel(s) {
      const m = { a_fazer: 'A Fazer', em_andamento: 'Em Andamento', concluido: 'Concluído', pausado: 'Pausado' };
      return m[s] || s;
    },
    obStatusColor(s) {
      const m = { a_fazer: '#d97706', em_andamento: '#3b82f6', concluido: '#10b981', pausado: '#6b7280' };
      return m[s] || '#6b7280';
    },

    // --- OB Data Loading ---
    async loadObData() {
      if (!sb) return;
      try {
        const { data, error } = await sb.from('vw_ob_pipeline').select('*');
        if (error) { console.error('[OB] loadObData error:', error.message); return; }
        this.data.obTrilhas = data || [];
      } catch (e) {
        console.error('[OB] loadObData error:', e);
      }
    },

    async loadObDetail(trilhaId) {
      if (!sb || !trilhaId) return;
      this.ui.obLoading = true;
      this.ui.obDetailTrilhaId = trilhaId;
      try {
        const [trilhaRes, etapasRes, tarefasRes] = await Promise.all([
          sb.from('ob_trilhas').select('*').eq('id', trilhaId).single(),
          sb.from('ob_etapas').select('*').eq('trilha_id', trilhaId).order('ordem'),
          sb.from('ob_tarefas').select('*').eq('trilha_id', trilhaId).order('ordem'),
        ]);
        if (trilhaRes.error) { console.error('[OB] trilha error:', trilhaRes.error); return; }
        const etapas = (etapasRes.data || []).map(e => ({
          ...e,
          tarefas: (tarefasRes.data || []).filter(t => t.etapa_id === e.id),
        }));
        this.data.obTrilhaDetail = { ...trilhaRes.data, etapas };
        // Load eventos separately (table may not exist yet)
        try {
          const eventosRes = await sb.from('ob_eventos').select('*').eq('trilha_id', trilhaId).order('created_at', { ascending: false }).limit(100);
          this.data.obEventos = eventosRes.data || [];
        } catch (_) { this.data.obEventos = []; }
        // Auto-expand first non-completed etapa
        if (etapas.length && !Object.values(this.ui.obExpandedEtapas).some(v => v)) {
          const first = etapas.find(e => e.status !== 'concluido') || etapas[0];
          if (first) this.ui.obExpandedEtapas[first.id] = true;
        }
      } catch (e) {
        console.error('[OB] loadObDetail error:', e);
      } finally {
        this.ui.obLoading = false;
      }
    },

    async loadObTemplate() {
      if (!sb) return;
      try {
        const [etapasRes, tarefasRes] = await Promise.all([
          sb.from('ob_template_etapas').select('*').order('ordem'),
          sb.from('ob_template_tarefas').select('*').order('ordem'),
        ]);
        this.data.obTemplateEtapas = (etapasRes.data || []).map(e => ({
          ...e,
          tarefas: (tarefasRes.data || []).filter(t => t.etapa_id === e.id),
        }));
      } catch (e) {
        console.error('[OB] loadObTemplate error:', e);
      }
    },

    // --- OB Trail CRUD ---
    async criarTrilha(mentoradoId, responsavel) {
      if (!sb || !mentoradoId) return;
      try {
        const { data, error } = await sb.rpc('ob_criar_trilha', {
          p_mentorado_id: mentoradoId,
          p_responsavel: responsavel || null,
        });
        if (error) { this.toast('Erro ao criar trilha: ' + error.message, 'error'); return; }
        this.toast('Trilha de onboarding criada!', 'success');
        await this.loadObData();
        this.ui.obNewTrilhaModal = false;
        return data;
      } catch (e) {
        this.toast('Erro: ' + e.message, 'error');
      }
    },

    async toggleObTarefa(tarefaId, novoStatus) {
      if (!sb || !tarefaId) return;
      // Capture tarefa info before update for logging
      const detail = this.data.obTrilhaDetail;
      let tarefaInfo = null;
      if (detail) {
        for (const et of (detail.etapas || [])) {
          const t = (et.tarefas || []).find(t => t.id === tarefaId);
          if (t) { tarefaInfo = { ...t, etapa_id: et.id, trilha_id: detail.id }; break; }
        }
      }
      const now = novoStatus === 'concluido' ? new Date().toISOString() : null;
      const { error } = await sb.from('ob_tarefas').update({
        status: novoStatus,
        data_concluida: now,
        updated_at: new Date().toISOString(),
      }).eq('id', tarefaId);
      if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      // Log event
      if (tarefaInfo) {
        const tipo = novoStatus === 'concluido' ? 'tarefa_concluida' : 'tarefa_reaberta';
        const desc = (novoStatus === 'concluido' ? 'Concluiu' : 'Reabriu') + ': ' + (tarefaInfo.descricao || '');
        await this._logObEvento(tarefaInfo.trilha_id, tarefaInfo.etapa_id, tarefaId, tipo, tarefaInfo.status, novoStatus, desc);
      }
      // Refresh detail
      if (this.ui.obDetailTrilhaId) {
        await this.loadObDetail(this.ui.obDetailTrilhaId);
        // Recalc etapa statuses
        for (const etapa of (this.data.obTrilhaDetail?.etapas || [])) {
          await this._recalcObEtapaStatus(etapa.id);
        }
        await this.loadObDetail(this.ui.obDetailTrilhaId);
      }
      await this.loadObData();
    },

    async _recalcObEtapaStatus(etapaId) {
      if (!sb) return;
      const detail = this.data.obTrilhaDetail;
      if (!detail) return;
      const etapa = detail.etapas.find(e => e.id === etapaId);
      if (!etapa || !etapa.tarefas?.length) return;
      const allDone = etapa.tarefas.every(t => t.status === 'concluido');
      const anyDone = etapa.tarefas.some(t => t.status === 'concluido');
      const newStatus = allDone ? 'concluido' : anyDone ? 'em_andamento' : 'pendente';
      if (newStatus !== etapa.status) {
        try {
          await sb.from('ob_etapas').update({ status: newStatus }).eq('id', etapaId);
          const tipo = newStatus === 'concluido' ? 'etapa_concluida' : 'etapa_iniciada';
          const desc = (newStatus === 'concluido' ? 'Etapa concluída' : 'Etapa iniciada') + ': ' + (etapa.nome || '');
          await this._logObEvento(detail.id, etapaId, null, tipo, etapa.status, newStatus, desc);
        } catch (e) { console.error('Erro ao recalcular etapa:', e); }
      }
    },

    async updateObTarefaResponsavel(tarefaId, resp) {
      if (!sb) return;
      // Capture old value for logging
      const detail = this.data.obTrilhaDetail;
      let oldResp = null, tarefaDesc = '', etapaId = null;
      if (detail) {
        for (const et of (detail.etapas || [])) {
          const t = (et.tarefas || []).find(t => t.id === tarefaId);
          if (t) { oldResp = t.responsavel; tarefaDesc = t.descricao; etapaId = et.id; break; }
        }
      }
      const { error } = await sb.from('ob_tarefas').update({ responsavel: resp }).eq('id', tarefaId);
      if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      // Log event
      if (detail) {
        await this._logObEvento(detail.id, etapaId, tarefaId, 'responsavel_alterado', oldResp, resp, 'Responsável alterado em: ' + tarefaDesc);
      }
      if (this.ui.obDetailTrilhaId) await this.loadObDetail(this.ui.obDetailTrilhaId);
    },

    async updateObTrilhaStatus(trilhaId, status) {
      if (!sb) return;
      const oldStatus = this.data.obTrilhaDetail?.status || null;
      const now = new Date().toISOString();
      const { error } = await sb.from('ob_trilhas').update({ status, updated_at: now }).eq('id', trilhaId);
      if (error) { this.toast('Erro: ' + error.message, 'error'); return; }

      // When marking as concluido, auto-complete all tarefas and etapas
      if (status === 'concluido') {
        await sb.from('ob_tarefas').update({ status: 'concluido', data_concluida: now, updated_at: now }).eq('trilha_id', trilhaId).neq('status', 'concluido');
        await sb.from('ob_etapas').update({ status: 'concluido', updated_at: now }).eq('trilha_id', trilhaId).neq('status', 'concluido');
      }

      // Log event
      const statusLabels = { a_fazer: 'A Fazer', em_andamento: 'Em Andamento', concluido: 'Concluído', pausado: 'Pausado' };
      await this._logObEvento(trilhaId, null, null, 'trilha_status', oldStatus, status, 'Status: ' + (statusLabels[oldStatus] || oldStatus || '-') + ' → ' + (statusLabels[status] || status));
      await this.loadObData();
      if (this.ui.obDetailTrilhaId === trilhaId) await this.loadObDetail(trilhaId);
      this.toast(status === 'concluido' ? 'Trilha concluída — todas as tarefas finalizadas' : 'Status atualizado', 'success');
    },

    async deleteObTrilha(trilhaId) {
      if (!sb || !confirm('Tem certeza que deseja excluir esta trilha?')) return;
      const { error } = await sb.from('ob_trilhas').delete().eq('id', trilhaId);
      if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      this.data.obTrilhaDetail = null;
      this.ui.obDetailTrilhaId = null;
      this.ui.obExpandedTrilha = null;
      await this.loadObData();
      this.toast('Trilha excluída', 'success');
    },

    // --- OB Template Editor CRUD ---
    async saveTemplateEtapa(etapa) {
      if (!sb) return;
      if (etapa.id) {
        const { error } = await sb.from('ob_template_etapas').update({
          nome: etapa.nome, tipo: etapa.tipo, ordem: etapa.ordem, cor: etapa.cor, icone: etapa.icone, updated_at: new Date().toISOString(),
        }).eq('id', etapa.id);
        if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      } else {
        const maxOrdem = this.data.obTemplateEtapas.reduce((max, e) => Math.max(max, e.ordem), 0);
        const { error } = await sb.from('ob_template_etapas').insert({
          nome: etapa.nome || 'Nova Etapa', tipo: etapa.tipo || 'sequencial', ordem: maxOrdem + 1, cor: etapa.cor || '#6b7280', icone: etapa.icone || '◆',
        });
        if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      }
      await this.loadObTemplate();
      this.toast('Etapa salva', 'success');
    },

    async deleteTemplateEtapa(etapaId) {
      if (!sb || !confirm('Excluir etapa e todas as tarefas?')) return;
      const { error } = await sb.from('ob_template_etapas').delete().eq('id', etapaId);
      if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      await this.loadObTemplate();
      this.toast('Etapa excluída', 'success');
    },

    async saveTemplateTarefa(tarefa) {
      if (!sb) return;
      if (tarefa.id) {
        const { error } = await sb.from('ob_template_tarefas').update({
          descricao: tarefa.descricao, responsavel_padrao: tarefa.responsavel_padrao,
          prazo_dias: tarefa.prazo_dias, ordem: tarefa.ordem, updated_at: new Date().toISOString(),
        }).eq('id', tarefa.id);
        if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      } else {
        const etapaTarefas = this.data.obTemplateEtapas.find(e => e.id === tarefa.etapa_id)?.tarefas || [];
        const maxOrdem = etapaTarefas.reduce((max, t) => Math.max(max, t.ordem), 0);
        const { error } = await sb.from('ob_template_tarefas').insert({
          etapa_id: tarefa.etapa_id, descricao: tarefa.descricao || 'Nova tarefa',
          responsavel_padrao: tarefa.responsavel_padrao || 'CS', prazo_dias: tarefa.prazo_dias || 0, ordem: maxOrdem + 1,
        });
        if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      }
      await this.loadObTemplate();
      this.toast('Tarefa salva', 'success');
    },

    async deleteTemplateTarefa(tarefaId) {
      if (!sb || !confirm('Excluir tarefa do template?')) return;
      const { error } = await sb.from('ob_template_tarefas').delete().eq('id', tarefaId);
      if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      await this.loadObTemplate();
      this.toast('Tarefa excluída', 'success');
    },

    // --- OB KPIs ---
    obPageKpis() {
      const trilhas = this.data.obTrilhas;
      const total = trilhas.length;
      const emAndamento = trilhas.filter(t => t.status === 'em_andamento').length;
      const concluidas = trilhas.filter(t => t.status === 'concluido').length;
      const atrasadas = trilhas.filter(t => (t.tarefas_atrasadas || 0) > 0).length;
      const totalTarefas = trilhas.reduce((s, t) => s + (t.total_tarefas || 0), 0);
      const tarefasConcluidas = trilhas.reduce((s, t) => s + (t.tarefas_concluidas || 0), 0);
      const progressoMedio = totalTarefas > 0 ? Math.round((tarefasConcluidas / totalTarefas) * 100) : 0;
      // Duração média das trilhas concluídas
      const concluidasList = trilhas.filter(t => t.status === 'concluido' && t.data_inicio);
      let duracaoMedia = 0;
      if (concluidasList.length) {
        const totalDias = concluidasList.reduce((s, t) => {
          const start = new Date(t.data_inicio + 'T00:00:00');
          const end = t.updated_at ? new Date(t.updated_at) : new Date();
          return s + Math.max(0, Math.floor((end - start) / 86400000));
        }, 0);
        duracaoMedia = Math.round(totalDias / concluidasList.length);
      }
      return { total, emAndamento, concluidas, atrasadas, progressoMedio, duracaoMedia };
    },

    // --- OB Filters ---
    get filteredObTrilhas() {
      let list = [...this.data.obTrilhas];
      if (this.ui.obFilter && this.ui.obFilter !== 'all') {
        if (this.ui.obFilter === 'atrasado') {
          list = list.filter(t => (t.tarefas_atrasadas || 0) > 0);
        } else {
          list = list.filter(t => t.status === this.ui.obFilter);
        }
      }
      if (this.ui.obSearchQuery) {
        const q = this.ui.obSearchQuery.toLowerCase();
        list = list.filter(t => (t.mentorado_nome || '').toLowerCase().includes(q) || (t.responsavel || '').toLowerCase().includes(q));
      }
      return list;
    },

    obPipelineColumns() {
      const statuses = ['a_fazer', 'em_andamento', 'concluido', 'pausado'];
      const list = this.ui.obSearchQuery ? this.filteredObTrilhas : this.data.obTrilhas;
      return statuses.map(s => ({
        status: s,
        label: this.obStatusLabel(s),
        color: this.obStatusColor(s),
        items: list.filter(t => t.status === s),
      }));
    },

    // --- OB Helpers ---
    obProgressColor(pct) {
      if (pct >= 80) return '#10b981';
      if (pct >= 50) return '#f59e0b';
      return '#ef4444';
    },

    obDiasAtraso(dataPrevista) {
      if (!dataPrevista) return 0;
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const prev = new Date(dataPrevista + 'T00:00:00');
      const diff = Math.floor((today - prev) / 86400000);
      return diff > 0 ? diff : 0;
    },

    obTarefaDuracao(tarefa) {
      if (!tarefa?.created_at) return 0;
      const start = new Date(tarefa.created_at);
      const end = tarefa.data_concluida ? new Date(tarefa.data_concluida) : new Date();
      return Math.max(0, Math.floor((end - start) / 86400000));
    },

    obEtapaDuracao(etapa) {
      if (!etapa?.tarefas?.length) return 0;
      const dates = etapa.tarefas.map(t => t.created_at ? new Date(t.created_at).getTime() : null).filter(Boolean);
      if (!dates.length) return 0;
      const start = Math.min(...dates);
      const concluidas = etapa.tarefas.filter(t => t.data_concluida).map(t => new Date(t.data_concluida).getTime());
      const end = etapa.status === 'concluido' && concluidas.length ? Math.max(...concluidas) : Date.now();
      return Math.max(0, Math.floor((end - start) / 86400000));
    },

    obTrilhaDuracao(trilha) {
      if (!trilha?.data_inicio) return 0;
      const start = new Date(trilha.data_inicio + 'T00:00:00');
      const end = trilha.status === 'concluido' && trilha.updated_at ? new Date(trilha.updated_at) : new Date();
      return Math.max(0, Math.floor((end - start) / 86400000));
    },

    obFormatDateTime(d) {
      if (!d) return '-';
      const dt = new Date(d);
      return dt.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' }) + ' ' + dt.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
    },

    obEtapaProgress(etapa) {
      if (!etapa?.tarefas?.length) return 0;
      const done = etapa.tarefas.filter(t => t.status === 'concluido').length;
      return Math.round((done / etapa.tarefas.length) * 100);
    },

    obEtapaStatusIcon(status) {
      const m = { pendente: '○', em_andamento: '◌', concluido: '●' };
      return m[status] || '○';
    },

    toggleObEtapa(etapaId) {
      this.ui.obExpandedEtapas[etapaId] = !this.ui.obExpandedEtapas[etapaId];
    },
    isObEtapaExpanded(etapaId) {
      return !!this.ui.obExpandedEtapas[etapaId];
    },
    expandAllObEtapas() {
      const detail = this.data.obTrilhaDetail;
      if (!detail?.etapas) return;
      detail.etapas.forEach(e => { this.ui.obExpandedEtapas[e.id] = true; });
    },
    collapseAllObEtapas() {
      this.ui.obExpandedEtapas = {};
    },

    obCloseDetail() {
      this.data.obTrilhaDetail = null;
      this.data.obEventos = [];
      this.ui.obDetailTrilhaId = null;
      this.ui.obExpandedEtapas = {};
    },

    // Get etapa-level summary for pipeline cards
    obTrilhaEtapaSummary(trilhaId) {
      // We use obTrilhaDetail only when detail is open, so for card view we use the pipeline data
      return null; // Cards show aggregate data from vw_ob_pipeline
    },

    // --- OB Template helpers ---
    async openObTemplateEditor() {
      this.ui.obTemplateMode = true;
      await this.loadObTemplate();
    },
    closeObTemplateEditor() {
      this.ui.obTemplateMode = false;
    },

    // ===================== TOASTS =====================

    toast(msg, type = 'info') {
      const id = Date.now();
      this.ui.toasts.push({ id, msg, type });
      setTimeout(() => { this.ui.toasts = this.ui.toasts.filter(t => t.id !== id); }, 4000);
    },

    // ===================== HELPERS =====================

    riskClass(risk) {
      return { critico: 'danger', alto: 'warning', medio: 'info', baixo: 'success' }[risk] || 'neutral';
    },

    riskLabel(risk) {
      return { critico: 'Critico', alto: 'Alto', medio: 'Medio', baixo: 'Baixo' }[risk] || risk || '-';
    },

    phaseLabel(fase) {
      return { onboarding: 'Onboarding', concepcao: 'Concepcao', validacao: 'Validacao', otimizacao: 'Otimizacao', escala: 'Escala' }[fase] || fase || '-';
    },

    phaseClass(fase) { return `phase--${fase}`; },

    prioClass(p) {
      return { urgente: 'danger', alta: 'warning', normal: 'info', baixa: 'neutral' }[p] || 'neutral';
    },

    prioLabel(p) {
      return { urgente: 'Urgente', alta: 'Alta', normal: 'Normal', baixa: 'Baixa' }[p] || p || 'Normal';
    },

    // ORCH-02: Agent member detection
    isAgentMember(name) {
      if (!name) return false;
      const member = (this.data.members || []).find(m =>
        m.id === name || (m.nome_curto || '').toLowerCase() === (name || '').toLowerCase()
      );
      return member?.tipo === 'agent' || (name || '').startsWith('agent_');
    },

    avatarInitials(nome) {
      if (!nome) return '?';
      if (this.isAgentMember(nome)) return '🤖';
      const parts = nome.split(' ').filter(p => p.length > 0);
      if (parts.length >= 2) return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
      return parts[0]?.substring(0, 2).toUpperCase() || '?';
    },

    avatarGradient(name) {
      if (!name) return 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
      let hash = 0;
      for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash);
      const gradients = [
        'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
        'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
        'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
        'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
        'linear-gradient(135deg, #a18cd1 0%, #fbc2eb 100%)',
        'linear-gradient(135deg, #fccb90 0%, #d57eeb 100%)',
        'linear-gradient(135deg, #e0c3fc 0%, #8ec5fc 100%)',
        'linear-gradient(135deg, #f5576c 0%, #ff6f61 100%)',
        'linear-gradient(135deg, #89f7fe 0%, #66a6ff 100%)',
        'linear-gradient(135deg, #fddb92 0%, #d1fdff 100%)',
        'linear-gradient(135deg, #96fbc4 0%, #f9f586 100%)',
      ];
      return gradients[Math.abs(hash) % gradients.length];
    },

    formatCurrency(val) {
      if (val == null || val === 0) return '-';
      if (val >= 1000) return `R$ ${(val / 1000).toFixed(0)}K`;
      return `R$ ${val.toLocaleString('pt-BR')}`;
    },

    _parseDate(dateStr) { return parseDateStr(dateStr); },

    systemDateLabel() {
      return SYSTEM_TODAY().toLocaleDateString('pt-BR', { weekday: 'long', day: '2-digit', month: 'long', year: 'numeric' });
    },

    formatDate(dateStr) {
      if (!dateStr) return '-';
      const d = this._parseDate(dateStr);
      if (!d) return dateStr; // fallback: show raw string
      return d.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' });
    },

    formatDateFull(dateStr) {
      if (!dateStr) return '-';
      const d = this._parseDate(dateStr);
      if (!d) return dateStr; // fallback: show raw string
      return d.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' });
    },

    relativeTime(dateStr) { return this.timeAgo(dateStr); },

    relativeDueDate(dateStr) {
      if (!dateStr) return '';
      const d = this._parseDate(dateStr);
      if (!d) return dateStr;
      const today = new Date(); today.setHours(0,0,0,0);
      const target = new Date(d); target.setHours(0,0,0,0);
      const diff = Math.round((target - today) / 86400000);
      if (diff === 0) return 'Hoje';
      if (diff === 1) return 'Amanha';
      if (diff === -1) return 'Ontem';
      if (diff < -1) return Math.abs(diff) + ' dias atras';
      if (diff <= 7) return target.toLocaleDateString('pt-BR', { weekday: 'short' });
      return d.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' });
    },

    timeAgo(dateStr) {
      if (!dateStr) return '-';
      const d = this._parseDate(dateStr);
      if (!d) return '-';
      const days = Math.floor((SYSTEM_TODAY() - d) / (1000 * 60 * 60 * 24));
      if (days === 0) return 'Hoje';
      if (days === 1) return 'Ontem';
      if (days < 7) return `${days}d atras`;
      if (days < 30) return `${Math.floor(days / 7)}sem atras`;
      return `${Math.floor(days / 30)}m atras`;
    },

    daysAgo(dateStr) {
      if (!dateStr) return 999;
      const d = this._parseDate(dateStr);
      if (!d) return 999;
      return Math.floor((SYSTEM_TODAY() - d) / (1000 * 60 * 60 * 24));
    },

    today() {
      return SYSTEM_TODAY().toLocaleDateString('pt-BR', { weekday: 'long', day: '2-digit', month: 'long', year: 'numeric' });
    },

    isOverdue(dateStr) {
      if (!dateStr) return false;
      const d = this._parseDate(dateStr);
      return d ? d < SYSTEM_TODAY() : false;
    },

    sparklineSvg(values, color = '#10b981', w = 60, h = 20) {
      if (!values || values.length < 2) return '';
      const max = Math.max(...values);
      const min = Math.min(...values);
      const range = max - min || 1;
      const step = w / (values.length - 1);
      const points = values.map((v, i) => `${(i * step).toFixed(1)},${(h - ((v - min) / range) * h * 0.8 - h * 0.1).toFixed(1)}`);
      const areaPoints = [...points, `${w},${h}`, `0,${h}`];
      return `<svg class="sparkline" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}"><polygon class="sparkline__area" points="${areaPoints.join(' ')}" fill="${color}"/><polyline class="sparkline__line" points="${points.join(' ')}" stroke="${color}"/></svg>`;
    },

    progressRingSvg(pct, size = 40, stroke = 4, color = '#10b981') {
      const r = (size - stroke) / 2;
      const c = 2 * Math.PI * r;
      const offset = c - (pct / 100) * c;
      return `<svg class="progress-ring" width="${size}" height="${size}"><circle cx="${size/2}" cy="${size/2}" r="${r}" fill="none" stroke="#e2e8f0" stroke-width="${stroke}"/><circle cx="${size/2}" cy="${size/2}" r="${r}" fill="none" stroke="${color}" stroke-width="${stroke}" stroke-dasharray="${c}" stroke-dashoffset="${offset}" stroke-linecap="round"/></svg>`;
    },

    statBoxClass(value, warnThreshold, dangerThreshold, inverse = false) {
      if (value == null) return '';
      if (inverse) {
        if (value >= dangerThreshold) return 'stat-box--danger';
        if (value >= warnThreshold) return 'stat-box--warning';
        return '';
      }
      if (value <= dangerThreshold) return 'stat-box--danger';
      if (value <= warnThreshold) return 'stat-box--warning';
      return '';
    },

    // ===================== DEMO DATA =====================

    loadDemoData() {
      // Recalculate dias_desde_call dynamically based on today
      this.data.mentees = DEMO_MENTEES.map(m => {
        const dynamicDays = daysBetween(m.ultima_call_data);
        // Also check SUPABASE_CALLS for more recent calls
        const mName = m.nome?.toLowerCase();
        const recentSbCall = (SUPABASE_CALLS || [])
          .filter(c => c.data && c.mentorado?.toLowerCase() === mName)
          .map(c => c.data)
          .sort()
          .pop(); // most recent date
        const sbDays = daysBetween(recentSbCall);
        const bestDays = (dynamicDays !== null && sbDays !== null) ? Math.min(dynamicDays, sbDays) : (sbDays ?? dynamicDays);
        return { ...m, dias_desde_call: bestDays ?? m.dias_desde_call };
      });
      this.data.cohort = DEMO_COHORT;
      this.data.alerts = DEMO_ALERTS;
    },

    getDemoDetail(id) {
      const m = this.data.mentees.find(x => x.id === id);
      if (!m) return null;
      const ctx = getMenteeContext(m.nome) || {};

      // Helper to parse DD/MM/YYYY or YYYY-MM-DD into a Date
      const parseD = (s) => {
        if (!s) return new Date(0);
        if (/^\d{2}\/\d{2}\/\d{4}$/.test(s)) {
          const [dd, mm, yy] = s.split('/');
          return new Date(`${yy}-${mm}-${dd}T00:00:00`);
        }
        return new Date(s);
      };

      // Calls from MENTEE_CONTEXTS (have gravacao/transcricao)
      const ctxCalls = (ctx.calls || []).map(c => ({
        data_call: c.data, tipo: c.tipo || 'acompanhamento', duracao: c.duracao || 45,
        resumo: c.resumo || c.obs || 'Call de acompanhamento',
        gravacao: c.gravacao || null,
        transcricao: c.transcricao || null,
        decisoes_tomadas: c.decisoes_tomadas || c.decisoes || [],
        feedbacks_queila: c.feedbacks_queila || [],
      }));

      // Calls from SUPABASE_CALLS for this mentee
      const mName = m.nome?.toLowerCase()?.trim();
      const ctxName = Object.keys(MENTEE_CONTEXTS || {}).find(k => k.toLowerCase() === mName)?.toLowerCase();
      const sbCalls = (SUPABASE_CALLS || [])
        .filter(c => {
          if (!c.mentorado || !c.data) return false;
          const cName = c.mentorado.toLowerCase().trim();
          // Exact match on DEMO_MENTEES name or MENTEE_CONTEXTS key
          if (cName === mName) return true;
          if (ctxName && cName === ctxName) return true;
          // Fuzzy: both first+last name tokens must appear
          const mTokens = mName?.split(/\s+/).filter(t => t.length > 2) || [];
          const cTokens = cName.split(/\s+/).filter(t => t.length > 2);
          if (mTokens.length >= 2 && cTokens.length >= 2) {
            return mTokens[0] === cTokens[0] && (mTokens.some(t => cTokens.includes(t)) && cTokens.some(t => mTokens.includes(t)));
          }
          return false;
        })
        .map(c => ({
          data_call: c.data, tipo: c.tipo || 'acompanhamento', duracao: c.duracao || 45,
          resumo: c.resumo || c.topic || 'Call de acompanhamento',
          gravacao: null, transcricao: null,
          decisoes_tomadas: c.decisoes || [], feedbacks_queila: c.proximos_passos || [],
          gargalos: c.gargalos || [], sentimento: c.sentimento || null,
        }));

      // Merge: ctx calls first (have links), then sb calls that don't overlap
      const allCalls = [...ctxCalls];
      for (const sc of sbCalls) {
        // Normalize date for comparison
        const scDate = parseD(sc.data_call).toISOString().slice(0, 10);
        const overlap = allCalls.some(ac => parseD(ac.data_call).toISOString().slice(0, 10) === scDate);
        if (!overlap) allCalls.push(sc);
      }
      // Sort by date descending
      allCalls.sort((a, b) => parseD(b.data_call) - parseD(a.data_call));

      // Mentee tasks from local storage
      const menteeTasks = this.data.tasks
        .filter(t => t.mentorado_nome?.toLowerCase() === m.nome?.toLowerCase() && t.status !== 'concluida')
        .map(t => ({ tarefa: t.titulo, prioridade: t.prioridade, fonte: t.fonte || 'manual' }));

      return {
        profile: { id: m.id, nome: m.nome, instagram: m.instagram, cidade: '', estado: '', email: '', telefone: '', cohort: m.cohort, nicho: m.produto_nome, data_inicio: '', perfil_negocio: ctx.perfil_tipo || '', frequencia_call: 'quinzenal' },
        phase: { fase_jornada: m.fase_jornada, sub_etapa: '', marco_atual: m.marco_atual, risco_churn: m.risco_churn, engagement_score: m.engagement_score || 50, implementation_score: m.implementation_score || 30, marcos_atingidos: [], health: m.risco_churn === 'baixo' ? 'on_track' : 'at_risk' },
        financial: { faturamento_atual: m.faturamento_atual || 0, meta_faturamento: m.meta_faturamento || 0, faturamento_mentoria: 0, qtd_vendas_total: m.qtd_vendas_total || 0, ticket_produto: 0, ja_vendeu: m.ja_vendeu || false, tem_produto: m.tem_produto || false },
        context_ia: {
          cenario_atual: ctx.cenario || 'Sem contexto registrado.',
          gargalos: ctx.gargalos || [],
          estrategias_atuais: ctx.estrategias || '',
          ultimo_plano_titulo: '',
          ultimo_foco: ctx.funil || '',
          completude_plano: 0,
        },
        last_calls: allCalls,
        last_interactions: [],
        pending_tasks: menteeTasks,
        directions: ctx.direcionamento ? [{ texto: ctx.direcionamento, fonte: 'planilha', data: '2026-02-15' }] : [],
      };
    },

    // ===== PERFIL COMPORTAMENTAL =====

    async loadPerfilComportamental(mentoradoId) {
      if (!sb) return;
      const mid = mentoradoId || this.data.detail?.profile?.id;
      if (!mid) return;
      this.ui.perfilLoading = true;
      try {
        const { data, error } = await sb.from('perfil_comportamental')
          .select('*').eq('mentorado_id', mid).maybeSingle();
        if (error) throw error;
        this.data.perfilComportamental = data;
        if (data) {
          this.$nextTick(() => this.renderPerfilCharts());
        }
      } catch (e) {
        console.error('Error loading perfil:', e);
        this.toast('Erro ao carregar perfil', 'error');
      } finally {
        this.ui.perfilLoading = false;
      }
    },

    openPerfilEdit() {
      const p = this.data.perfilComportamental;
      if (p) {
        const combined = {};
        if (p.dimensoes && Object.keys(p.dimensoes).length) combined.dimensoes = p.dimensoes;
        if (p.comunicacao && Object.keys(p.comunicacao).length) combined.comunicacao = p.comunicacao;
        this.perfilForm.json_raw = Object.keys(combined).length ? JSON.stringify(combined, null, 2) : '';
        this.perfilForm.notas_texto = p.notas_texto || '';
        this.perfilForm.fonte = p.fonte || 'ai_claude';
        this.perfilForm.fonte_detalhes = p.fonte_detalhes || '';
      } else {
        this.perfilForm = { json_raw: '', notas_texto: '', fonte: 'ai_claude', fonte_detalhes: '' };
      }
      this.ui.perfilInputMode = 'json';
      this.ui.perfilModal = true;
    },

    async savePerfilComportamental() {
      if (!sb) return;
      const mid = this.data.detail?.profile?.id;
      if (!mid) return;

      let dimensoes = {};
      let comunicacao = {};

      // Parse JSON input
      const raw = this.perfilForm.json_raw.trim();
      if (raw) {
        try {
          const parsed = JSON.parse(raw);
          dimensoes = parsed.dimensoes || {};
          comunicacao = parsed.comunicacao || {};
        } catch (e) {
          this.toast('JSON invalido. Verifique o formato.', 'error');
          return;
        }
      }

      const payload = {
        mentorado_id: mid,
        dimensoes,
        comunicacao,
        notas_texto: this.perfilForm.notas_texto || null,
        fonte: this.perfilForm.fonte || 'manual',
        fonte_detalhes: this.perfilForm.fonte_detalhes || null,
        created_by: this.currentUserName || null,
      };

      try {
        const { error } = await sb.from('perfil_comportamental')
          .upsert(payload, { onConflict: 'mentorado_id' });
        if (error) throw error;
        this.ui.perfilModal = false;
        this.toast('Perfil salvo com sucesso', 'success');
        await this.loadPerfilComportamental(mid);
      } catch (e) {
        console.error('Error saving perfil:', e);
        this.toast('Erro ao salvar perfil: ' + e.message, 'error');
      }
    },

    async gerarPerfilComIA() {
      if (!sb) return;
      const mid = this.data.detail?.profile?.id;
      if (!mid) { this.toast('Selecione um mentorado primeiro', 'error'); return; }

      this.ui.perfilGerando = true;
      this.toast('Analisando transcrições com IA... isso pode levar até 30s', 'info');

      try {
        const fnUrl = CONFIG.SUPABASE_URL + '/functions/v1/gerar-perfil';
        const resp = await fetch(fnUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + CONFIG.SUPABASE_ANON_KEY,
            'apikey': CONFIG.SUPABASE_ANON_KEY,
          },
          body: JSON.stringify({ mentorado_id: mid }),
        });

        const data = await resp.json();
        if (!resp.ok || data.error) throw new Error(data.error || 'Erro na Edge Function');

        // Salva localmente caso o upsert da Edge Function tenha falhado
        if (data.perfil) {
          const { error: saveErr } = await sb.from('perfil_comportamental')
            .upsert({
              mentorado_id: mid,
              dimensoes: data.perfil.dimensoes || {},
              comunicacao: data.perfil.comunicacao || {},
              notas_texto: 'Gerado via IA a partir de ' + data.calls_analisadas + ' calls.',
              fonte: 'ai_claude',
              fonte_detalhes: 'claude-3-haiku | ' + data.calls_analisadas + ' calls | ' + new Date().toISOString(),
              created_by: this.currentUserName || 'ai_auto',
            }, { onConflict: 'mentorado_id' });
          if (saveErr) console.warn('Upsert local falhou:', saveErr);
        }

        this.toast('Perfil gerado com sucesso (' + data.calls_analisadas + ' calls analisadas)', 'success');
        await this.loadPerfilComportamental(mid);
      } catch (e) {
        console.error('Erro ao gerar perfil:', e);
        this.toast('Erro ao gerar perfil: ' + (e.message || 'erro desconhecido'), 'error');
      } finally {
        this.ui.perfilGerando = false;
      }
    },

    destroyPerfilCharts() {
      Object.values(this._perfilCharts).forEach(c => { try { c.destroy(); } catch(e) {} });
      this._perfilCharts = {};
    },

    renderPerfilCharts() {
      this.destroyPerfilCharts();
      const p = this.data.perfilComportamental;
      if (!p) return;
      const dim = p.dimensoes || {};

      // Big Five radar
      if (dim.big_five) {
        const ctx = document.getElementById('chart-bigfive');
        if (ctx) {
          const bf = dim.big_five;
          this._perfilCharts.bigfive = new Chart(ctx, {
            type: 'radar',
            data: {
              labels: ['Abert.', 'Consc.', 'Extrov.', 'Amabil.', 'Neurot.'],
              datasets: [{
                label: 'Score',
                data: [bf.abertura||0, bf.conscienciosidade||0, bf.extroversao||0, bf.amabilidade||0, bf.neuroticismo||0],
                backgroundColor: 'rgba(245,158,11,0.2)',
                borderColor: 'rgb(245,158,11)',
                borderWidth: 2,
                pointBackgroundColor: 'rgb(245,158,11)',
              }]
            },
            options: this._radarOpts(100),
          });
        }
      }

      // DISC radar
      if (dim.disc) {
        const ctx = document.getElementById('chart-disc');
        if (ctx) {
          const d = dim.disc;
          this._perfilCharts.disc = new Chart(ctx, {
            type: 'radar',
            data: {
              labels: ['Domin.', 'Influen.', 'Estabil.', 'Conform.'],
              datasets: [{
                label: 'Score',
                data: [d.dominancia||0, d.influencia||0, d.estabilidade||0, d.conformidade||d.consciencia||0],
                backgroundColor: 'rgba(99,102,241,0.2)',
                borderColor: 'rgb(99,102,241)',
                borderWidth: 2,
                pointBackgroundColor: 'rgb(99,102,241)',
              }]
            },
            options: this._radarOpts(100),
          });
        }
      }

      // Quatro Zonas radar
      if (dim.quatro_zonas) {
        const ctx = document.getElementById('chart-zonas');
        if (ctx) {
          const z = dim.quatro_zonas;
          const getVal = (v) => typeof v === 'object' ? (v?.score||0) : (v||0);
          this._perfilCharts.zonas = new Chart(ctx, {
            type: 'radar',
            data: {
              labels: ['Incomp.', 'Compet.', 'Excelenc.', 'Genialid.'],
              datasets: [{
                label: 'Score',
                data: [getVal(z.incompetencia), getVal(z.competencia), getVal(z.excelencia), getVal(z.genialidade)],
                backgroundColor: 'rgba(16,185,129,0.2)',
                borderColor: 'rgb(16,185,129)',
                borderWidth: 2,
                pointBackgroundColor: 'rgb(16,185,129)',
              }]
            },
            options: this._radarOpts(100),
          });
        }
      }

      // Modos Esquematicos horizontal bar
      if (dim.modos_esquematicos) {
        const ctx = document.getElementById('chart-modos');
        if (ctx) {
          const modos = dim.modos_esquematicos;
          const labelMap = {
            crianca_vulneravel: 'Cr. Vulneravel',
            crianca_zangada: 'Cr. Zangada',
            protetor_desligado: 'Prot. Desligado',
            capitulador: 'Capitulador',
            adulto_saudavel: 'Ad. Saudavel',
          };
          const keys = Object.keys(modos);
          const labels = keys.map(k => labelMap[k] || k);
          const values = keys.map(k => modos[k]);
          const colors = values.map(v => v >= 70 ? 'rgba(239,68,68,0.7)' : v >= 40 ? 'rgba(245,158,11,0.7)' : 'rgba(34,197,94,0.7)');
          this._perfilCharts.modos = new Chart(ctx, {
            type: 'bar',
            data: {
              labels,
              datasets: [{ label: 'Score', data: values, backgroundColor: colors, borderWidth: 0 }]
            },
            options: {
              indexAxis: 'y',
              responsive: true,
              maintainAspectRatio: false,
              plugins: { legend: { display: false } },
              scales: {
                x: { min: 0, max: 100, ticks: { font: { size: 9 } }, grid: { color: 'rgba(0,0,0,0.05)' } },
                y: { ticks: { font: { size: 9 } } }
              }
            },
          });
        }
      }
    },

    _radarOpts(max) {
      return {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          legend: { display: false },
          tooltip: {
            callbacks: {
              label: function(ctx) { return ctx.raw + '/100'; }
            }
          }
        },
        scales: {
          r: {
            min: 0, max,
            ticks: { stepSize: 25, display: false },
            grid: { color: 'rgba(0,0,0,0.06)' },
            pointLabels: { font: { size: 9 } },
          }
        }
      };
    },
  };
}

// ===== DEMO DATA moved to data.js =====
