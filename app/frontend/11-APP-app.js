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
      toasts: [],
      // Tasks
      taskFilter: 'all', // all | pendente | em_andamento | concluida | atrasada
      taskAssignee: '',
      taskModal: false,
      taskEditId: null,
      taskView: 'board', // 'list' | 'board'
      taskDetailDrawer: null, // task ID for detail drawer
      taskGanttRange: 'month', // 'week' | 'month' | 'quarter'
      taskSpaceFilter: 'all', // space_id filter
      taskListFilter: 'all', // list_id filter
      taskGroupBy: 'status', // 'status' | 'assignee' | 'priority' | 'list'
      taskTagFilter: [],       // tag ids for filtering
      taskTagsDropdown: false, // tags dropdown open in modal
      taskTagsFilterOpen: false, // tags filter dropdown in toolbar
      // Dossiers (legacy)
      dossierFilter: 'all',
      // Dossiê Production System
      dsFilter: 'all',
      dsView: 'painel',        // painel | pipeline | lista
      dsSearchQuery: '',
      dsExpandedDocs: {},       // { producaoId: true }
      dsLoading: false,
      dsModal: false,
      dsDetailProducaoId: null, // for detail view
      dsConfirm: null,          // { title, msg, onConfirm }
      dsSortField: 'mentorado_nome',
      dsSortAsc: true,
      mediaModal: null,          // { url, originalUrl, label } para iframe preview
      dsAjusteError: false,
      // WhatsApp
      whatsappSelectedChat: null,
      whatsappMessage: '',
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
      waFaseDropdownId: null,           // id of mentee with open fase dropdown
      // WA Management — Notas Estruturadas
      notesDrawer: { open: false, menteeId: null, menteeNome: '', tipo: 'livre' },
      notesSaving: false,
      notesForm: { conteudo: '', tags: '' },
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
    },

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
      pendencias: [],
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
      // Tags & Custom Fields
      taskTags: [],             // god_task_tags — all available tags
      fieldDefs: [],            // applicable god_task_field_defs for current modal
      finDetailLogs: [],        // financial logs for mentee detail tab
      menteeNotes: [],          // notes for current notes drawer
      waSelectedMentees: [],    // IDs selected in bulk mode
      digestData: null,         // loaded digest for current mentee
    },

    // --- Financeiro (CFO Payments View) ---
    financeiro: null,
    finFilter: '',
    finNoteModal: { open: false, menteeId: null, menteeNome: '', text: '' },

    // --- Perfil Comportamental ---
    perfilForm: { json_raw: '', notas_texto: '', fonte: 'ai_claude', fonte_detalhes: '' },
    _perfilCharts: {},

    // --- Media Cache ---
    waMediaUrls: {},  // messageId → presigned URL

    // Task organization: 2 Spaces — Jornada (mentee-owned) + Gestão (team-owned)
    spaces: [
      { id: 'space_jornada', name: 'Jornada Mentorados', icon: '◎', color: '#6366f1',
        lists: [
          { id: 'list_onboarding', name: 'Onboarding', icon: '▸' },
          { id: 'list_concepcao', name: 'Concepção', icon: '◇' },
          { id: 'list_validacao', name: 'Validação', icon: '●' },
          { id: 'list_otimizacao', name: 'Otimização', icon: '◆' },
          { id: 'list_escala', name: 'Escala', icon: '▲' },
        ]
      },
      { id: 'space_gestao', name: 'Gestão CASE', icon: '◈', color: '#f59e0b',
        lists: [
          { id: 'list_direcionamentos', name: 'Direcionamentos Queila', icon: '★' },
          { id: 'list_operacional', name: 'Operacional', icon: '✦' },
          { id: 'list_conteudo', name: 'Conteúdo & Marketing', icon: '◉' },
          { id: 'list_vendas', name: 'Vendas & Comercial', icon: '◆' },
          { id: 'list_playbooks', name: 'Playbooks & Materiais', icon: '■' },
          { id: 'list_dossies', name: 'Dossiês', icon: '◇' },
        ]
      },
    ],

    // --- Task Form ---
    taskForm: {
      titulo: '',
      descricao: '',
      responsavel: '',
      mentorado_nome: '',
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
      space_id: 'space_jornada',
      list_id: '',
      newSubtask: '',
      newCheckItem: '',
      newComment: '',
      newTag: '',
      recorrencia: 'nenhuma',
      dia_recorrencia: null,
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
    scheduleForm: { mentorado: '', mentorado_id: '', tipo: 'acompanhamento', data: '', horario: '10:00', duracao: 60, email: '', notas: '' },

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
      // WhatsApp pending messages — read from pendencias list (single source of truth, always in sync)
      const msgsPendentes = this.data.pendencias.length;
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
    get pendenciasList() {
      const prioOrder = { critico: 0, alto: 1, medio: 2, baixo: 3 };
      return [...this.data.pendencias].sort((a, b) => {
        return (prioOrder[a.prioridade_calculada] ?? 3) - (prioOrder[b.prioridade_calculada] ?? 3);
      });
    },

    pendenciasMinimized: false,
    pendenciasExpanded: false,

    get pendenciasVisible() {
      return this.pendenciasExpanded ? this.pendenciasList : this.pendenciasList.slice(0, 15);
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
      // Remove from local list
      this.data.pendencias = this.data.pendencias.filter(p => p.interacao_id !== interacaoId);
      // Update mentee counts
      const pending = this.data.pendencias;
      this.data.mentees = this.data.mentees.map(m => {
        const count = pending.filter(p => p.mentorado_id === m.id).length;
        return { ...m, msgs_pendentes_resposta: count };
      });
      this.toast('Mensagem marcada como respondida', 'success');
    },

    async markAllAsResponded() {
      if (!confirm('Marcar TODAS as ' + this.data.pendencias.length + ' mensagens como respondidas?')) return;
      const sb2 = await initSupabase();
      if (!sb2) return;
      const ids = this.data.pendencias.map(p => p.interacao_id);
      const { error } = await sb2.from('interacoes_mentoria').update({ respondido: true }).in('id', ids);
      if (error) {
        this.toast('Erro ao marcar mensagens', 'error');
        console.error('[Spalla] markAllAsResponded error:', error);
        return;
      }
      this.data.pendencias = [];
      this.data.mentees = this.data.mentees.map(m => ({ ...m, msgs_pendentes_resposta: 0 }));
      this.toast('Todas as mensagens marcadas como respondidas', 'success');
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
      return email.includes('cfo') || name.includes('cfo') || email.includes('financeiro') || name.includes('kaique');
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

    async changeFinStatus(menteeId, newStatus, observacao) {
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/financeiro/status`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.token}` },
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
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.auth.token}` },
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

    todayStr() { return new Date().toISOString().split('T')[0]; },

    _filterTasks(tasks) {
      let list = tasks;
      if (this.ui.taskAssignee) {
        const assignee = this.ui.taskAssignee === '__mine__'
          ? (this.auth.currentUser?.full_name || '').toLowerCase()
          : this.ui.taskAssignee.toLowerCase();
        if (assignee) list = list.filter(t => t.responsavel?.toLowerCase().includes(assignee));
      }
      if (this.ui.taskSpaceFilter !== 'all') {
        list = list.filter(t => t.space_id === this.ui.taskSpaceFilter);
      }
      if (this.ui.taskListFilter !== 'all') {
        list = list.filter(t => t.list_id === this.ui.taskListFilter);
      }
      if (this.ui.taskTagFilter.length) {
        list = list.filter(t => {
          const taskTagIds = (t.tags || []).map(tg => tg.id).filter(Boolean);
          return this.ui.taskTagFilter.some(tagId => taskTagIds.includes(tagId));
        });
      }
      return list;
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
      return TEAM_MEMBERS.map(member => {
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
        t.recorrencia && t.recorrencia !== 'nenhuma' && t.status === 'concluida'
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
      return { diario: 'Diaria', semanal: 'Semanal', quinzenal: 'Quinzenal', mensal: 'Mensal' }[r] || '';
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
      } catch (err) {
        // Rollback
        mentee.fase_jornada = oldFase;
        this.toast(`Erro ao mover ${mentee.nome}: ${err.message}`, 'error');
      }
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
      if (this.ui.search && this.ui.page === 'tasks') {
        const q = this.ui.search.toLowerCase();
        list = list.filter(t => t.titulo?.toLowerCase().includes(q) || t.mentorado_nome?.toLowerCase().includes(q));
      }
      list.sort((a, b) => {
        const prio = { urgente: 0, alta: 1, normal: 2, baixa: 3 };
        return (prio[a.prioridade] || 2) - (prio[b.prioridade] || 2);
      });
      return list.slice(0, 100);
    },

    // Tasks: grouped by status (ClickUp style board)
    get tasksByStatus() {
      const statuses = ['pendente', 'em_andamento', 'concluida'];
      const result = {};
      for (const s of statuses) {
        let list = this._filterTasks([...this.data.tasks].filter(t => t.status === s));
        list.sort((a, b) => {
          const prio = { urgente: 0, alta: 1, normal: 2, baixa: 3 };
          return (prio[a.prioridade] || 2) - (prio[b.prioridade] || 2);
        });
        result[s] = list.slice(0, 50);
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
      const teamNames = TEAM_MEMBERS.map(m => m.name.toLowerCase());
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

    // Dossiers: filtered
    get filteredDossiers() {
      if (this.ui.dossierFilter === 'all') return DOSSIER_PIPELINE;
      const statusMap = {
        enviado: ['enviado'],
        em_revisao: ['em_revisao', 'ajustar', 'ajustando', 'aprovado_enviar', 'revisao_kaique', 'revisao_mariza', 'revisao_queila'],
        producao_ia: ['producao_ia'],
        nao_iniciado: ['nao_iniciado', 'onboarding', 'pausado'],
      };
      const statuses = statusMap[this.ui.dossierFilter] || [this.ui.dossierFilter];
      return DOSSIER_PIPELINE.filter(d => statuses.includes(d.status));
    },

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
        // Deep-link: resolve URL pathname to page
        const pathname = window.location.pathname.replace(/^\//, '').replace(/\/$/, '');
        if (pathname && this._routeMap[pathname]) {
          this.ui.page = this._routeMap[pathname];
          localStorage.setItem('spalla_page', this._routeMap[pathname]);
        }
        // Handle browser back/forward
        window.addEventListener('popstate', (e) => {
          const p = window.location.pathname.replace(/^\//, '').replace(/\/$/, '');
          if (p && this._routeMap[p]) {
            this.ui.page = this._routeMap[p];
          } else if (!p || p === '') {
            this.ui.page = 'dashboard';
          }
        });

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
              this.ui.taskAssignee = '__mine__';
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
                this.ui.taskAssignee = '__mine__';
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
                this.ui.taskAssignee = '__mine__';
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

        if (this.auth.authenticated) {
          await this.loadReminders(); // Load from Supabase
          await this.loadDashboard();
          // Pre-fetch WhatsApp profile pics in background
          this._loadWaProfilePics();
          // Fetch schedule-related data from backend API
          this.fetchUpcomingCalls();
          // Fetch Instagram profiles from Apify (background, non-blocking)
          this.updateInstagramProfiles();
          // Load WhatsApp per-user session + start health check
          this.loadWaSession();
          this.waStartHealthCheck();
          // Lazy-load Arquivos data if page is already on arquivos (deep-link or localStorage restore)
          if (this.ui.page === 'arquivos') {
            this.loadArquivos();
          }
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
        this.ui.taskAssignee = '__mine__';

        await this.loadReminders();
        await this.loadDashboard();
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
        this.loadDashboard();
      }, this._refreshIntervalMs);
    },

    stopDataRefresh() {
      if (this._refreshInterval) {
        clearInterval(this._refreshInterval);
        this._refreshInterval = null;
      }
    },

    startWhatsAppPolling() {
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
            this.toast('WhatsApp API indisponível', 'warning');
            return;
          }
          if (res.ok) {
            const data = await res.json();
            const msgs = data.messages?.records || data.messages || data || [];
            const newMsgs = (Array.isArray(msgs) ? msgs : []).reverse();
            // Compare last message ID to detect changes (length alone is unreliable)
            const lastLocal = this.data.whatsappMessages[this.data.whatsappMessages.length - 1];
            const lastRemote = newMsgs[newMsgs.length - 1];
            const localId = lastLocal?.key?.id || '';
            const remoteId = lastRemote?.key?.id || '';
            if (newMsgs.length !== this.data.whatsappMessages.length || localId !== remoteId) {
              this.data.whatsappMessages = newMsgs;
              this.eagerlyLoadWaMediaUrls(this.data.whatsappMessages);
              this.$nextTick(() => {
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

    async loadDashboard() {
      this.ui.loading = true;
      sb = await initSupabase();
      if (sb) {
        try {
          const [mentees, cohort, pendencias, paPipeline] = await Promise.all([
            sb.from('vw_god_overview').select('*'),
            sb.from('vw_god_cohort').select('*'),
            sb.from('vw_god_pendencias').select('*').order('created_at', { ascending: true }),
            sb.from('vw_pa_pipeline').select('*'),
          ]);
          // Load calls in background (non-blocking)
          const calls = await sb.from('calls_mentoria')
            .select('id,mentorado_id,data_call,duracao_minutos,tipo,tipo_call,link_gravacao,link_transcricao,zoom_topic,status_call,"senha_Call",link_plano_acao,principais_topicos,decisoes_tomadas,created_at,mentorados(id,nome)')
            .order('data_call', { ascending: false })
            .limit(500);
          // Check individual query errors
          if (mentees.error) console.error('[Spalla] Mentees query error:', mentees.error.message);
          if (cohort.error) console.error('[Spalla] Cohort query error:', cohort.error.message);
          if (calls.error) console.error('[Spalla] Calls query error:', calls.error.message);
          if (pendencias.error) console.error('[Spalla] Pendencias query error:', pendencias.error.message);
          if (paPipeline.error) console.error('[Spalla] PA Pipeline query error:', paPipeline.error?.message);
          if (paPipeline.data) this.data.paPlanos = paPipeline.data;
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
            // Reconcile msgs_pendentes_resposta per mentee to match the actual pendencias list.
            // vw_god_overview and vw_god_pendencias use different logic → counts never match.
            // Single source of truth: always derive from pendencias.data.
            const pendsByMentee = {};
            pendencias.data.forEach(p => {
              if (p.mentorado_id) pendsByMentee[p.mentorado_id] = (pendsByMentee[p.mentorado_id] || 0) + 1;
            });
            this.data.mentees = this.data.mentees.map(m => ({
              ...m,
              msgs_pendentes_resposta: pendsByMentee[m.id] || 0,
            }));
          }
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
              transcript_completo: c.transcript_completo || null,
              observacoes_equipe: c.observacoes_equipe || null,
              created_at: c.created_at,
            }));
            // Log first 5 calls for debugging
          }
          // Recalculate dias_desde_call with real call data
          if (this._supabaseCalls?.length) this._enrichMenteesWithCalls();
          this.supabaseConnected = true;
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
      // Auto-refresh disabled — only WhatsApp polling active
      // if (this.supabaseConnected) this.startDataRefresh();
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
      if (!_waInst) { if (this.data.detail) this.data.detail._waLoaded = true; return; }
      const nome = this.data.detail?.profile?.nome;
      if (!nome) { if (this.data.detail) this.data.detail._waLoaded = true; return; }
      // Enrich detail with overview WA metrics
      const overviewMentee = this.data.mentees.find(m => m.id === this.ui.selectedMenteeId);
      if (this.data.detail && overviewMentee) {
        this.data.detail._waMetrics = {
          whatsapp_7d: overviewMentee.whatsapp_7d,
          whatsapp_30d: overviewMentee.whatsapp_30d,
          whatsapp_total: overviewMentee.whatsapp_total,
        };
      }
      try {
        // Strategy 1: Use grupo_whatsapp_id from mentorados table (reliable)
        const grupoId = overviewMentee?.grupo_whatsapp_id;
        let remoteJid = null;
        let chatObj = null;

        if (grupoId) {
          remoteJid = grupoId;
          chatObj = { remoteJid: grupoId, id: grupoId, name: nome, _fromGrupoId: true };
        } else {
          // Strategy 2: Fallback to name matching in Evolution chats
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

        // Fetch last 10 messages using remoteJid
        const res = await fetch(`${CONFIG.API_BASE}/api/evolution/chat/findMessages/${_waInst}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ where: { key: { remoteJid } }, limit: 10 }),
        });
        if (!res.ok) { if (this.data.detail) this.data.detail._waLoaded = true; return; }
        const data = await res.json();
        const msgs = data.messages?.records || data.messages || data || [];
        const interactions = (Array.isArray(msgs) ? msgs : []).reverse().map(msg => ({
          sender: msg.key?.fromMe ? 'Equipe CASE' : (msg.pushName || nome),
          conteudo: this.getWaMessageText(msg),
          created_at: msg.messageTimestamp ? new Date(msg.messageTimestamp * 1000).toISOString() : null,
        })).filter(i => i.conteudo);

        if (this.data.detail) {
          if (interactions.length) {
            this.data.detail.last_interactions = interactions;
            this.data.detail._waChat = chatObj;
          }
          this.data.detail._waLoaded = true;
        }
      } catch (e) {
        console.warn('[Spalla] Could not load detail WA messages:', e.message);
        if (this.data.detail) this.data.detail._waLoaded = true;
      }
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

    // ===================== NAVIGATION =====================

    // Deep-link route map (pathname → page name)
    _routeMap: {
      'welcome-flow': 'welcome_flow',
      'dashboard': 'dashboard',
      'kanban': 'kanban',
      'tasks': 'tasks',
      'agenda': 'agenda',
      'equipe': 'equipe',
      'whatsapp': 'whatsapp',
      'wa-topics': 'wa_topics',
      'wa-management': 'wa_management',
      'reminders': 'reminders',
      'dossies': 'dossies',
      'planos-acao': 'planos_acao',
      'onboarding': 'onboarding',
      'docs': 'docs',
      'arquivos': 'arquivos',
      'settings': 'settings',
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
      this.navigate('arquivos');
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
          const { data, error } = await sb.from('vw_god_tasks_full').select('*').order('created_at', { ascending: false }).limit(200);
          if (!error && data) {
            this.data.tasks = data.map(t => ({
              ...t, prazo: t.data_fim, _source: 'god_tasks',
              subtasks: (t.subtasks || []).map(s => ({ text: s.texto || s.text, done: s.done })),
              checklist: (t.checklist || []).map(c => ({ text: c.texto || c.text, done: c.done })),
              comments: (t.comments || []).map(c => ({ id: c.id, author: c.author, text: c.texto || c.text, timestamp: c.created_at || c.timestamp })),
              handoffs: (t.handoffs || []).map(h => ({ from: h.from_person || h.from, to: h.to_person || h.to, note: h.note, date: h.created_at || h.date })),
              tags: (t.tags_full && t.tags_full.length) ? t.tags_full : (t.tags || []).map(tg => typeof tg === 'string' ? { id: null, name: tg, color: '#94a3b8' } : tg),
              custom_fields: t.custom_fields_json || [],
              attachments: [],
            }));
            this._autoCategorize();
            this._cacheTasksLocal();
            return;
          }
        } catch (e) { console.warn('[Spalla] Tasks fetch error, falling back:', e.message); }
      }
      // Fallback: localStorage
      try {
        const raw = localStorage.getItem(CONFIG.TASKS_STORAGE_KEY);
        if (raw) { const parsed = JSON.parse(raw); if (parsed.length > 0) { this.data.tasks = parsed; this._autoCategorize(); return; } }
      } catch (e) {}
      this.data.tasks = DEMO_TASKS;
      this._cacheTasksLocal();
    },

    _autoCategorize() {
      const phaseList = (fase) => {
        if (fase === 'onboarding') return 'list_onboarding';
        if (fase === 'concepcao') return 'list_concepcao';
        if (fase === 'validacao') return 'list_validacao';
        if (fase === 'otimizacao') return 'list_otimizacao';
        if (fase === 'escala') return 'list_escala';
        return 'list_concepcao';
      };
      this.data.tasks.forEach(t => {
        // Migrate old space IDs to new ones
        if (t.space_id === 'space_mentorados' || t.space_id === 'space_equipe' || t.space_id === 'space_queila') {
          t.space_id = null; t.list_id = null;
        }
        if (!t.space_id) {
          const titulo = (t.titulo || '').toLowerCase();
          const fonte = t.fonte || '';
          const resp = t.responsavel || '';
          const mentee = this.data.mentees.find(m => m.nome === t.mentorado_nome);
          const fase = mentee?.fase_jornada || '';

          // Mentee-owned tasks → Jornada, list by phase
          if (resp === 'mentorado' || fonte === 'tarefas_acordadas' || fonte === 'analise_call') {
            t.space_id = 'space_jornada';
            t.list_id = phaseList(fase);
            if (!t.acompanhante) t.acompanhante = 'Kaique';
          }
          // Queila directions → Gestão
          else if (resp === 'Queila' || fonte === 'direcionamento') {
            t.space_id = 'space_gestao';
            t.list_id = titulo.includes('playbook') || titulo.includes('material') ? 'list_playbooks' : 'list_direcionamentos';
          }
          // Dossiê tasks → Gestão / Dossiês
          else if (titulo.includes('dossie') || titulo.includes('dossiê') || fonte === 'dossie') {
            t.space_id = 'space_gestao';
            t.list_id = 'list_dossies';
          }
          // Content/Marketing → Gestão
          else if (titulo.includes('conteudo') || titulo.includes('conteúdo') || titulo.includes('video') || titulo.includes('post') || titulo.includes('campanha') || titulo.includes('trafego') || titulo.includes('tráfego')) {
            t.space_id = 'space_gestao';
            t.list_id = 'list_conteudo';
          }
          // Sales → Gestão
          else if (titulo.includes('venda') || titulo.includes('funil') || titulo.includes('oferta') || titulo.includes('comercial')) {
            t.space_id = 'space_gestao';
            t.list_id = 'list_vendas';
          }
          // Has mentee associated → Jornada, by phase
          else if (t.mentorado_nome) {
            t.space_id = 'space_jornada';
            t.list_id = phaseList(fase);
            if (!t.acompanhante && resp && resp !== 'mentorado') t.acompanhante = resp;
          }
          // Everything else → Gestão / Operacional
          else {
            t.space_id = 'space_gestao';
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
      const VALID_COLS = ['id','titulo','descricao','status','prioridade','responsavel','acompanhante','mentorado_id','mentorado_nome','data_inicio','data_fim','space_id','list_id','parent_task_id','tags','fonte','doc_link','created_at','updated_at','created_by','recorrencia','dia_recorrencia','recorrencia_ativa','recorrencia_origem_id'];
      const row = {};
      for (const k of VALID_COLS) { if (task[k] !== undefined) row[k] = task[k]; }
      if (row.mentorado_id) row.mentorado_id = parseInt(row.mentorado_id) || null;
      if (isNew && this.auth.currentUser) row.created_by = this.auth.currentUser.id;
      try {
        const { error } = await sb.from('god_tasks').upsert(row, { onConflict: 'id' });
        if (error) { console.warn('[Spalla] Task upsert error:', error.message); return { ok: false, error }; }
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
          const { error: insErr } = await sb.from('god_task_subtasks').insert(subtasks.map((s, i) => ({ task_id: taskId, texto: s.text, done: s.done, sort_order: i })));
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
          const { error: insErr } = await sb.from('god_task_checklist').insert(checklist.map((c, i) => ({ task_id: taskId, texto: c.text, done: c.done, sort_order: i })));
          if (insErr) { console.warn('[Spalla] Checklist insert error:', insErr.message); return { ok: false }; }
        }
        return { ok: true };
      } catch (e) { console.warn('[Spalla] Checklist sync error:', e.message); return { ok: false }; }
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
          responsavel: task.responsavel || '',
          acompanhante: task.acompanhante || '',
          mentorado_nome: task.mentorado_nome || '',
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
          parent_task_id: task.parent_task_id || null,
          space_id: task.space_id || 'space_jornada',
          list_id: task.list_id || '',
          recorrencia: task.recorrencia || 'nenhuma',
          dia_recorrencia: task.dia_recorrencia || null,
          newSubtask: '',
          newCheckItem: '',
          newComment: '',
          newTag: '',
          fieldValues: {},
        };
        this.ui.taskEditId = task.id;
        this.loadFieldDefs(task.space_id, task.list_id, task.id);
      } else {
        this.taskForm = { titulo: '', descricao: '', responsavel: '', acompanhante: '', mentorado_nome: '', prioridade: 'normal', prazo: '', data_inicio: '', data_fim: '', doc_link: '', subtasks: [], checklist: [], comments: [], attachments: [], tags: [], parent_task_id: null, space_id: 'space_jornada', list_id: '', recorrencia: 'nenhuma', dia_recorrencia: null, newSubtask: '', newCheckItem: '', newComment: '', newTag: '', fieldValues: {} };
        this.ui.taskEditId = null;
        this.loadFieldDefs('space_jornada', null, null);
      }
      this.ui.taskModal = true;
      this.ui.taskTagsDropdown = false;
    },

    closeTaskModal() {
      this.ui.taskModal = false;
      this.ui.taskEditId = null;
    },

    async saveTask() {
      if (!this.taskForm.titulo.trim()) return;
      const formData = { ...this.taskForm };
      delete formData.newSubtask;
      delete formData.newCheckItem;
      delete formData.newComment;
      delete formData.newTag;
      delete formData.fieldValues;
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
      }
      this._cacheTasksLocal();
      this.closeTaskModal();
      this.toast('Tarefa salva', 'success');
    },

    async updateTaskStatus(taskId, newStatus) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (!t) return;
      const oldStatus = t.status;
      t.status = newStatus;
      t.updated_at = new Date().toISOString();
      this._cacheTasksLocal();
      if (sb) {
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

    addSubtask() {
      if (this.taskForm.newSubtask.trim()) {
        this.taskForm.subtasks.push({ text: this.taskForm.newSubtask.trim(), done: false });
        this.taskForm.newSubtask = '';
      }
    },

    removeSubtask(idx) {
      this.taskForm.subtasks.splice(idx, 1);
    },

    addCheckItem() {
      if (this.taskForm.newCheckItem.trim()) {
        this.taskForm.checklist.push({ text: this.taskForm.newCheckItem.trim(), done: false });
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

    taskChecklistProgress(task) {
      if (!task.checklist || !task.checklist.length) return null;
      const done = task.checklist.filter(c => c.done).length;
      return { done, total: task.checklist.length, pct: Math.round((done / task.checklist.length) * 100) };
    },

    // Task detail drawer
    openTaskDetail(taskId) {
      this.ui.taskDetailDrawer = taskId;
    },

    closeTaskDetail() {
      this.ui.taskDetailDrawer = null;
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

    async deleteComment(taskId, commentId) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t && t.comments) {
        t.comments = t.comments.filter(c => c.id !== commentId);
        this._cacheTasksLocal();
        this._sbDeleteComment(commentId);
      }
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
    get ganttTasks() {
      let tasks = this._filterTasks([...this.data.tasks].filter(t => t.status !== 'concluida'));
      return tasks.filter(t => t.data_inicio || t.data_fim || t.prazo).sort((a, b) => {
        const da = a.data_inicio || a.prazo || a.created_at || '';
        const db = b.data_inicio || b.prazo || b.created_at || '';
        return da.localeCompare(db);
      }).slice(0, 50);
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
    },

    _isPrelinkedUser() {
      const name = (this.auth.currentUser?.full_name || '').toLowerCase().trim();
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
          if (createRes.status === 403 || createRes.status === 409 || errBody.error?.includes('already') || errBody.message?.includes('already')) {
            console.log('[WA Session] Instance exists, reconnecting...');
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
      this.stopWhatsAppPolling(); // Stop previous polling
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/evolution/chat/findMessages/${instance}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ where: { key: { remoteJid: chat.remoteJid || chat.id } }, limit: 50 }),
        });
        if (res.ok) {
          const data = await res.json();
          // Evolution API v2 can return { messages: { records: [...] } } or just an array
          const msgs = data.messages?.records || data.messages || data || [];
          this.data.whatsappMessages = (Array.isArray(msgs) ? msgs : []).reverse();
          // Eagerly load media URLs for all messages
          this.eagerlyLoadWaMediaUrls(this.data.whatsappMessages);
        } else {
          throw new Error(`HTTP ${res.status}`);
        }
      } catch (e) {
        console.error('[Spalla] WA messages fetch error:', e);
        this.data.whatsappMessages = DEMO_WA_MESSAGES;
      }
      this.ui.whatsappLoading = false;
      this.$nextTick(() => {
        const el = document.getElementById('wa-messages-end');
        if (el) el.scrollIntoView({ behavior: 'smooth' });
      });
      // Start polling for new messages
      this.startWhatsAppPolling();
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
      this.ui.whatsappMessage = '';
      if (!isPersonal) {
        this.toast('Enviando pelo numero central (conecte seu WhatsApp em Configuracoes)', 'warning');
      }
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/evolution/message/sendText/${instance}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ number: this.ui.whatsappSelectedChat.remoteJid || this.ui.whatsappSelectedChat.id, text: msg }),
        });
        if (res.ok) {
          this.data.whatsappMessages.push({
            key: { fromMe: true },
            message: { conversation: msg },
            messageTimestamp: Math.floor(Date.now() / 1000),
            pushName: isPersonal ? (this.auth.currentUser?.full_name || 'Voce') : 'Equipe CASE',
          });
          this.$nextTick(() => {
            const el = document.getElementById('wa-messages-end');
            if (el) el.scrollIntoView({ behavior: 'smooth' });
          });
        } else {
          throw new Error(`HTTP ${res.status}`);
        }
      } catch (e) {
        console.error('[Spalla] WA send error:', e);
        this.toast('Erro ao enviar: ' + e.message, 'error');
        this.ui.whatsappMessage = msg; // restore on error
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
      // Convert to base64
      const base64 = await new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result.split(',')[1]);
        reader.onerror = reject;
        reader.readAsDataURL(file);
      });
      this.ui.waSendingMedia = true;
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/evolution/message/sendMedia/${instance}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            number: this.ui.whatsappSelectedChat.remoteJid || this.ui.whatsappSelectedChat.id,
            mediatype,
            media: base64,
            fileName: file.name,
            caption: '',
          }),
        });
        if (res.ok) {
          // Optimistic message in thread
          const msgObj = { key: { fromMe: true }, messageTimestamp: Math.floor(Date.now() / 1000), pushName: 'Voce' };
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
          throw new Error(`HTTP ${res.status}`);
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
      // Document messages with video MIME types
      if (m.documentMessage?.mimetype?.includes('video')) return 'video';
      if (m.documentMessage?.mimetype?.includes('audio')) return 'audio';
      if (m.documentMessage?.mimetype?.includes('image')) return 'image';
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

        // Check if Evolution API provided mediaUrl
        if (msg.message?.mediaUrl) {
          this.waMediaUrls[msgId] = msg.message.mediaUrl;
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
      if (this.ui.waPortfolioFaseFilter) {
        list = list.filter(m => m.fase_jornada === this.ui.waPortfolioFaseFilter);
      }
      if (this.ui.waPortfolioHealthFilter) {
        list = list.filter(m => this._waHealthLabel(m) === this.ui.waPortfolioHealthFilter);
      }
      if (this.ui.waPortfolioView === 'inbox') {
        list.sort((a, b) => this._waPriorityScore(b) - this._waPriorityScore(a));
      } else {
        list.sort((a, b) => (a.nome || '').localeCompare(b.nome || ''));
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

    _waHealthLabel(m) {
      const score = this.calcHealthScore(m).total;
      if (score >= 70) return 'verde';
      if (score >= 40) return 'amarelo';
      return 'vermelho';
    },

    _waPriorityScore(m) {
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
      const h = m.horas_sem_resposta_equipe;
      if (h == null) return '—';
      if (h < 1) return 'Agora';
      if (h < 24) return `${Math.floor(h)}h atrás`;
      const d = Math.floor(h / 24);
      if (d === 1) return 'Ontem';
      return `${d}d atrás`;
    },

    async patchMentee(menteeId, updates) {
      try {
        const resp = await fetch(`${CONFIG.API_BASE}/api/mentees/${menteeId}`, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.auth.token}`,
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
      this.toast(`Fase atualizada para ${this._waFaseLabel(novaFase)}`, 'success');
    },

    async snoozeMentee(menteeId, dias) {
      const dt = new Date();
      dt.setDate(dt.getDate() + dias);
      await this.patchMentee(menteeId, { snoozed_until: dt.toISOString() });
      this.toast(`Mentorado snoozeado por ${dias} dias`, 'success');
    },

    // ===================== NOTAS ESTRUTURADAS =====================

    openNotesDrawer(menteeId, menteeNome) {
      this.ui.notesDrawer = { open: true, menteeId, menteeNome: menteeNome || '', tipo: 'livre' };
      this.ui.notesForm = { conteudo: '', tags: '' };
      this.loadMenteeNotes(menteeId);
    },

    closeNotesDrawer() {
      this.ui.notesDrawer = { open: false, menteeId: null, menteeNome: '', tipo: 'livre' };
      this.ui.notesForm = { conteudo: '', tags: '' };
      this.data.menteeNotes = [];
    },

    async loadMenteeNotes(menteeId) {
      if (!menteeId) return;
      try {
        const { data, error } = await sb
          .from('mentee_notes')
          .select('id,tipo,conteudo,tags,created_at,author_name')
          .eq('mentee_id', menteeId)
          .order('created_at', { ascending: false })
          .limit(20);
        if (error) throw error;
        this.data.menteeNotes = data || [];
      } catch (e) {
        console.error('loadMenteeNotes error:', e);
        this.data.menteeNotes = [];
      }
    },

    async postMenteeNote(menteeId, tipo, conteudo, tags) {
      if (!conteudo?.trim()) {
        this.toast('Escreva algo antes de salvar.', 'warning');
        return false;
      }
      this.ui.notesSaving = true;
      try {
        const tagsArr = tags ? tags.split(',').map(t => t.trim()).filter(Boolean) : [];
        const { error } = await sb.from('mentee_notes').insert({
          mentee_id: menteeId,
          tipo,
          conteudo: conteudo.trim(),
          tags: tagsArr,
        });
        if (error) throw error;
        this.toast('Nota salva!', 'success');
        this.ui.notesForm = { conteudo: '', tags: '' };
        this.ui.notesDrawer.tipo = 'livre';
        await this.loadMenteeNotes(menteeId);
        return true;
      } catch (e) {
        console.error('postMenteeNote error:', e);
        this.toast('Erro ao salvar nota.', 'error');
        return false;
      } finally {
        this.ui.notesSaving = false;
      }
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
            'Authorization': `Bearer ${this.auth.token}`,
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
        const { data, error } = await sb.from('wa_messages')
          .select('id,sender_name,is_from_team,content_type,content_text,timestamp')
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
          prioridade: 'media',
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
      'dradanyellatruiz': 'danyellatruiz.jpg',
      'danyella truiz': 'danyellatruiz.jpg',
      'dr.rafaelcastro': 'drrafaelcastro.jpg',
      'doctraction': 'drrafaelcastro.jpg',
      'rafael castro': 'drrafaelcastro.jpg',
    },

    igPhoto(handleOrName) {
      if (!handleOrName) return null;
      void this.photoTick;

      const isHandle = !handleOrName.includes(' ');
      const clean = handleOrName.replace('@','').toLowerCase();

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
      return ALL_MENTEE_NAMES || this.data.mentees.map(m => m.nome).sort();
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
    openMedia(url, label) {
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
      // Zoom download link → convert to share link (opens player instead of downloading)
      if (/zoom\.us\/rec\/download/i.test(url)) {
        const shareUrl = url.replace('/rec/download/', '/rec/share/');
        window.open(shareUrl, '_blank', 'noopener');
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

      const days = [];
      // Previous month days
      const prevLastDay = new Date(year, month, 0).getDate();
      for (let i = startDay - 1; i >= 0; i--) {
        const d = prevLastDay - i;
        const m2 = month === 0 ? 11 : month - 1;
        const y2 = month === 0 ? year - 1 : year;
        const ds = `${y2}-${String(m2+1).padStart(2,'0')}-${String(d).padStart(2,'0')}`;
        days.push({ key: ds, num: d, currentMonth: false, isToday: ds === todayStr, dateStr: ds, calls: callMap[ds] || 0 });
      }
      // Current month days
      for (let d = 1; d <= lastDay.getDate(); d++) {
        const ds = `${year}-${String(month+1).padStart(2,'0')}-${String(d).padStart(2,'0')}`;
        days.push({ key: ds, num: d, currentMonth: true, isToday: ds === todayStr, dateStr: ds, calls: callMap[ds] || 0 });
      }
      // Next month days to fill grid (6 rows)
      const remaining = 42 - days.length;
      for (let d = 1; d <= remaining; d++) {
        const m2 = month === 11 ? 0 : month + 1;
        const y2 = month === 11 ? year + 1 : year;
        const ds = `${y2}-${String(m2+1).padStart(2,'0')}-${String(d).padStart(2,'0')}`;
        days.push({ key: ds, num: d, currentMonth: false, isToday: ds === todayStr, dateStr: ds, calls: callMap[ds] || 0 });
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
        try {
          const zoomRes = await fetch(`${CONFIG.API_BASE}/api/zoom/create-meeting`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              topic: titulo,
              start_time: `${f.data}T${f.horario}:00`,
              duration: parseInt(f.duracao) || 60,
              description: f.notas || '',
              invitees: f.email ? [f.email] : [],
            }),
          });
          const zoomData = await zoomRes.json();
          if (zoomData.join_url) zoomUrl = zoomData.join_url;
        } catch (e) {
          console.warn('[Schedule] Zoom creation warning:', e.message);
        }

        try {
          const startDt = new Date(`${f.data}T${f.horario}:00`);
          const endDt = new Date(startDt.getTime() + (parseInt(f.duracao) || 60) * 60000);
          const calRes = await fetch(`${CONFIG.API_BASE}/api/calendar/create-event`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              summary: titulo,
              start_iso: startDt.toISOString(),
              end_iso: endDt.toISOString(),
              description: f.notas || '',
              attendees: f.email ? [f.email] : [],
              location: zoomUrl || '',
            }),
          });
          const calData = await calRes.json();
          if (calData.html_link) calendarUrl = calData.html_link;
        } catch (e) {
          console.warn('[Schedule] Calendar creation warning:', e.message);
        }

        // Then: Insert into Supabase with links
        if (!sb) {
          this.toast('Supabase não conectado', 'error');
          return;
        }
        const { data: callData, error } = await sb
          .from('calls_mentoria')
          .insert({
            mentorado_id: menteeId,
            data_call: `${f.data}T${f.horario}:00`,
            duracao_minutos: parseInt(f.duracao) || 60,
            tipo: f.tipo || 'acompanhamento',
            status_call: 'agendada',
            participantes: JSON.stringify([f.email || '']),
            observacoes_equipe: f.notas || '',
            link_gravacao: zoomUrl || null,
            zoom_topic: titulo,
          })
          .select();

        if (error) throw error;

        this.toast('Call agendada: Zoom ' + (zoomUrl ? '✓' : '○') + ' Calendar ' + (calendarUrl ? '✓' : '○'), 'success');

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
        this.scheduleForm = { mentorado: '', mentorado_id: '', tipo: 'acompanhamento', data: '', horario: '10:00', duracao: 60, email: '', notas: '' };

        // Refresh upcoming calls
        this.fetchUpcomingCalls();

      } catch (err) {
        console.error('[Schedule]', err);
        this.toast('Erro ao agendar: ' + err.message, 'error');
      } finally {
        this.ui.scheduling = false;
      }
    },

    // ===================== SCHEDULE API HELPERS =====================

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
          };
        });
      } catch (e) {
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

    dossierStats() {
      const total = DOSSIER_PIPELINE.length;
      const enviados = DOSSIER_PIPELINE.filter(d => d.status === 'enviado').length;
      const emRevisao = DOSSIER_PIPELINE.filter(d => ['em_revisao', 'ajustar', 'ajustando', 'aprovado_enviar', 'revisao_kaique', 'revisao_mariza', 'revisao_queila'].includes(d.status)).length;
      const producaoIa = DOSSIER_PIPELINE.filter(d => d.status === 'producao_ia').length;
      const naoIniciado = DOSSIER_PIPELINE.filter(d => ['nao_iniciado', 'onboarding', 'pausado'].includes(d.status)).length;
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

    dsProgressPercent(estagio) {
      const num = this.dsEstagioNum(estagio);
      return Math.round((num / DS_ESTAGIOS.length) * 100);
    },

    // --- DS Data Loading ---
    async loadDsData() {
      if (!sb) return;
      this.ui.dsLoading = true;
      try {
        const [prodRes, docsRes] = await Promise.all([
          sb.from('vw_ds_pipeline').select('*').order('mentorado_nome'),
          sb.from('ds_documentos').select('id, producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, estagio_desde, link_doc, ordem').order('ordem'),
        ]);
        if (prodRes.data) this.data.dsProducoes = prodRes.data;
        if (docsRes.data) this.data.dsAllDocs = docsRes.data;
      } catch (e) {
        console.error('[DS] loadDsData error:', e);
      } finally {
        this.ui.dsLoading = false;
      }
    },

    async loadDsMenteeDetail(producaoId) {
      if (!sb) return;
      this.ui.dsLoading = true;
      try {
        const [prodRes, docsRes, eventsRes, ajustesRes] = await Promise.all([
          sb.from('ds_producoes').select('*').eq('id', producaoId).single(),
          sb.from('ds_documentos').select('*').eq('producao_id', producaoId).order('ordem'),
          sb.from('ds_eventos').select('*').eq('producao_id', producaoId).order('created_at', { ascending: false }).limit(50),
          sb.from('ds_ajustes').select('*').eq('producao_id', producaoId).order('created_at', { ascending: false }),
        ]);
        if (prodRes.data) this.data.dsMenteeDetail = prodRes.data;
        if (docsRes.data) this.data.dsAllDocs = docsRes.data;
        if (eventsRes.data) this.data.dsEventos = eventsRes.data;
        if (ajustesRes.data) this.data.dsAjustes = ajustesRes.data;
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
      if (this.ui.dsFilter !== 'all') {
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
      // Search filter
      if (this.ui.dsSearchQuery) {
        const q = this.ui.dsSearchQuery.toLowerCase();
        list = list.filter(p => (p.mentorado_nome || '').toLowerCase().includes(q) || (p.responsavel_atual || '').toLowerCase().includes(q));
      }
      return list;
    },

    dsPipelineColumns() {
      const cols = {};
      DS_ESTAGIOS.forEach(e => { cols[e.id] = []; });
      this.filteredDsProducoes.forEach(p => {
        // Use estagio_min_num to determine which column
        const minNum = p.estagio_min_num || 1;
        const estagio = DS_ESTAGIOS[Math.min(minNum - 1, DS_ESTAGIOS.length - 1)];
        if (estagio && cols[estagio.id]) cols[estagio.id].push(p);
      });
      return cols;
    },

    // --- DS CRUD + Handoff ---
    async advanceDocStage(docId, notas) {
      if (!sb) return;
      const doc = this.data.dsAllDocs.find(d => d.id === docId);
      if (!doc) return;
      const curIdx = DS_ESTAGIOS.findIndex(e => e.id === doc.estagio_atual);
      if (curIdx < 0 || curIdx >= DS_ESTAGIOS.length - 1) return;

      // Dependency check: enviado requires all 3 docs approved
      const nextEstagio = DS_ESTAGIOS[curIdx + 1];
      if (nextEstagio.id === 'enviado') {
        const siblings = this.data.dsAllDocs.filter(d => d.producao_id === doc.producao_id && d.id !== docId);
        const allApproved = siblings.every(s => this.dsEstagioNum(s.estagio_atual) >= this.dsEstagioNum('aprovado'));
        if (!allApproved) {
          this.toast('Todos os 3 documentos precisam estar aprovados antes de enviar', 'warning');
          return;
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

      let newStatus;
      if (stages.every(s => s >= 10)) newStatus = 'finalizado';
      else if (stages.every(s => s >= 7)) newStatus = 'enviado';
      else if (stages.every(s => s >= 6)) newStatus = 'aprovado';
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
      const curIdx = DS_ESTAGIOS.findIndex(e => e.id === doc.estagio_atual);
      if (curIdx < 0 || curIdx >= DS_ESTAGIOS.length - 1) return false;
      const next = DS_ESTAGIOS[curIdx + 1];
      if (next.id === 'enviado') {
        const siblings = this.data.dsAllDocs.filter(d => d.producao_id === doc.producao_id && d.id !== doc.id);
        return siblings.every(s => this.dsEstagioNum(s.estagio_atual) >= this.dsEstagioNum('aprovado'));
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
    },

    dsFormatDate(d) {
      if (!d) return '-';
      const dt = new Date(d);
      return dt.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' });
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

    async updateDocLink(docId, link) {
      if (!sb) return;
      const { error } = await sb.from('ds_documentos').update({ link_doc: link }).eq('id', docId);
      if (error) this.toast('Erro ao salvar link: ' + error.message, 'error');
      else this.toast('Link salvo', 'success');
    },

    // ===================== ONBOARDING CS =====================

    // --- OB Constants ---
    OB_STATUS: [
      { id: 'em_andamento', label: 'Em Andamento', color: '#3b82f6', icon: '◌' },
      { id: 'concluido', label: 'Concluído', color: '#10b981', icon: '●' },
      { id: 'pausado', label: 'Pausado', color: '#6b7280', icon: '◎' },
    ],

    obStatusLabel(s) {
      const m = { em_andamento: 'Em Andamento', concluido: 'Concluído', pausado: 'Pausado' };
      return m[s] || s;
    },
    obStatusColor(s) {
      const m = { em_andamento: '#3b82f6', concluido: '#10b981', pausado: '#6b7280' };
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
      const { error } = await sb.from('ob_trilhas').update({ status, updated_at: new Date().toISOString() }).eq('id', trilhaId);
      if (error) { this.toast('Erro: ' + error.message, 'error'); return; }
      // Log event
      const statusLabels = { em_andamento: 'Em Andamento', concluido: 'Concluído', pausado: 'Pausado' };
      await this._logObEvento(trilhaId, null, null, 'trilha_status', oldStatus, status, 'Status: ' + (statusLabels[oldStatus] || oldStatus || '-') + ' → ' + (statusLabels[status] || status));
      await this.loadObData();
      if (this.ui.obDetailTrilhaId === trilhaId) await this.loadObDetail(trilhaId);
      this.toast('Status atualizado', 'success');
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
      const statuses = ['em_andamento', 'concluido', 'pausado'];
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

    avatarInitials(nome) {
      if (!nome) return '?';
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
