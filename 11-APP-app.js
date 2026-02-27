/* ================================================================
   SPALLA V2 — Application Logic (Full Feature Set)
   Stack: Alpine.js + Supabase JS v2 + Evolution API
   Pages: Dashboard, Detail, Kanban, Dossies, Tasks, WhatsApp, Docs, Lembretes
   ================================================================ */

// ===== CONFIG =====
const CONFIG = {
  SUPABASE_URL: 'https://knusqfbvhsqworzyhvip.supabase.co',
  SUPABASE_ANON_KEY: window.__SUPABASE_ANON_KEY__ || '',  // Injected from backend
  API_BASE_URL: window.__API_BASE_URL__ || 'https://api.spalla-dashboard.vercel.app',
  AUTH_STORAGE_KEY: 'spalla_auth',
  TASKS_STORAGE_KEY: 'spalla_tasks',
  REMINDERS_STORAGE_KEY: 'spalla_reminders',
  DEFAULT_PAGE: 'dashboard',
  ITEMS_PER_PAGE: 50,
};

// ===== SUPABASE CLIENT =====
let sb = null;

function initSupabase() {
  if (!CONFIG.SUPABASE_ANON_KEY) {
    console.warn('[Spalla] Supabase anon key not configured — using demo data');
    return null;
  }
  if (!window.supabase || !window.supabase.createClient) {
    console.warn('[Spalla] Supabase JS not loaded yet — using demo data');
    return null;
  }
  try {
    return window.supabase.createClient(CONFIG.SUPABASE_URL, CONFIG.SUPABASE_ANON_KEY);
  } catch (e) {
    console.error('[Spalla] Failed to init Supabase:', e);
    return null;
  }
}

// ===== TEMPORAL AWARENESS =====
const SYSTEM_TODAY = new Date();
function parseDateStr(dateStr) {
  if (!dateStr) return null;
  if (/^\d{2}\/\d{2}\/\d{4}$/.test(dateStr)) {
    const [d, m, y] = dateStr.split('/');
    return new Date(parseInt(y), parseInt(m) - 1, parseInt(d));
  }
  const date = new Date(dateStr);
  return isNaN(date.getTime()) ? null : date;
}
function daysBetween(dateStr) {
  const d = parseDateStr(dateStr);
  if (!d) return null;
  return Math.floor((SYSTEM_TODAY - d) / (1000 * 60 * 60 * 24));
}

// ===== ALPINE APP =====
function spalla() {
  return {
    // --- Auth (JWT) ---
    auth: {
      authenticated: false,
      email: '',
      password: '',
      token: null,
      tokenExpires: null,
      error: '',
      loading: false
    },
    supabaseConnected: false,
    _supabaseCalls: [],

    // --- Broken photo tracking ---
    brokenPhotos: {},
    waPhotos: {},
    photoTick: 0,
    _enrichingInProgress: false,  // HIGH-07: Race condition prevention

    // --- LOW-06: Performance tracking ---
    perf: {
      dashboardLoadTime: 0,
      tasksLoadTime: 0,
      callsLoadTime: 0,
    },
    _perfMarkers: {},

    // --- UI State ---
    ui: {
      page: CONFIG.DEFAULT_PAGE,
      sidebarOpen: true,
      mobileMenuOpen: false,
      search: '',
      filters: { fase: '', risco: '', cohort: '', status: '', financeiro: '' },
      sort: 'nome',
      sortDir: 'asc',
      loading: true,
      detailLoading: false,
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
      // Dossiers
      dossierFilter: 'all', // all | enviado | em_revisao | producao_ia | nao_iniciado
      // WhatsApp
      whatsappSelectedChat: null,
      whatsappMessage: '',
      whatsappLoading: false,
      // Reminders
      reminderModal: false,
      reminderFilter: 'ativo', // ativo | concluido | all
      // Docs
      docSearch: '',
      // Agenda Calendar
      selectedCalDate: null,
      calendarMonth: new Date().getMonth(),
      calendarYear: new Date().getFullYear(),
      expandedCall: null,
      scheduleModal: false,
      scheduling: false,
      // Media Viewer
      mediaViewerOpen: false,
      mediaViewerData: null,
      mediaViewerZoom: 1,
      mediaViewerPanX: 0,
      mediaViewerPanY: 0,
      mediaViewerIsDragging: false,
      mediaViewerDragStart: { x: 0, y: 0 },
    },

    // --- Profile Form ---
    profileForm: {
      displayName: '',
      newPassword: '',
      confirmPassword: '',
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
      scheduledCalls: [],
    },

    // Task organization: 2 Spaces — Jornada (mentee-owned) + Gestão (team-owned)
    spaces: [
      { id: 'space_jornada', name: 'Jornada Mentorados', icon: '🎯', color: '#6366f1',
        lists: [
          { id: 'list_onboarding', name: 'Onboarding', icon: '🚀' },
          { id: 'list_concepcao', name: 'Concepção', icon: '💡' },
          { id: 'list_validacao', name: 'Validação', icon: '✅' },
          { id: 'list_otimizacao', name: 'Otimização', icon: '⚡' },
          { id: 'list_escala', name: 'Escala', icon: '📈' },
        ]
      },
      { id: 'space_gestao', name: 'Gestão CASE', icon: '⚙️', color: '#f59e0b',
        lists: [
          { id: 'list_direcionamentos', name: 'Direcionamentos Queila', icon: '👑' },
          { id: 'list_operacional', name: 'Operacional', icon: '🔧' },
          { id: 'list_conteudo', name: 'Conteúdo & Marketing', icon: '📱' },
          { id: 'list_vendas', name: 'Vendas & Comercial', icon: '💰' },
          { id: 'list_playbooks', name: 'Playbooks & Materiais', icon: '📚' },
          { id: 'list_dossies', name: 'Dossiês', icon: '📋' },
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
      }
      if (this.ui.filters.financeiro === 'sem_contrato') {
        list = list.filter(m => !m.contrato_assinado);
      } else if (this.ui.filters.financeiro === 'atrasado') {
        list = list.filter(m => m.status_financeiro === 'atrasado');
      } else if (this.ui.filters.financeiro === 'em_dia') {
        list = list.filter(m => m.status_financeiro === 'em_dia');
      } else if (this.ui.filters.financeiro === 'quitado') {
        list = list.filter(m => m.status_financeiro === 'quitado');
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
      const semContrato = this.data.mentees.filter(m => !m.contrato_assinado).length;
      const pgtoAtrasado = this.data.mentees.filter(m => m.status_financeiro === 'atrasado').length;
      const totalCalls = this.data.cohort.reduce((sum, c) => sum + (c.total_calls_30d || 0), 0);
      return {
        totalMentorados,
        emDia: totalMentorados - criticos - altos,
        comPendencia: cohort[0]?.pending_responses_global || 0,
        riscoCritico: criticos + altos,
        calls30d: totalCalls,
        tarefasPendentes: cohort[0]?.pending_tasks_global || 0,
        semContrato,
        pgtoAtrasado,
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

    // Kanban: group mentees by phase
    menteesByPhase(fase) {
      return this.data.mentees.filter(m => m.fase_jornada === fase);
    },

    // Tasks: filtered
    get filteredTasks() {
      let list = [...this.data.tasks];
      if (this.ui.taskFilter !== 'all') {
        if (this.ui.taskFilter === 'atrasada') {
          list = list.filter(t => t.status === 'pendente' && (t.data_fim || t.prazo) && parseDateStr(t.data_fim || t.prazo) < SYSTEM_TODAY);
        } else {
          list = list.filter(t => t.status === this.ui.taskFilter);
        }
      }
      if (this.ui.taskAssignee) {
        list = list.filter(t => t.responsavel?.toLowerCase().includes(this.ui.taskAssignee.toLowerCase()));
      }
      if (this.ui.taskSpaceFilter !== 'all') {
        list = list.filter(t => t.space_id === this.ui.taskSpaceFilter);
      }
      if (this.ui.taskListFilter !== 'all') {
        list = list.filter(t => t.list_id === this.ui.taskListFilter);
      }
      if (this.ui.search && this.ui.page === 'tasks') {
        const q = this.ui.search.toLowerCase();
        list = list.filter(t => t.titulo?.toLowerCase().includes(q) || t.mentorado_nome?.toLowerCase().includes(q));
      }
      list.sort((a, b) => {
        const prio = { urgente: 0, alta: 1, normal: 2, baixa: 3 };
        return (prio[a.prioridade] || 2) - (prio[b.prioridade] || 2);
      });
      return list.slice(0, 100); // Limit for performance
    },

    // Tasks: grouped by status (ClickUp style board)
    get tasksByStatus() {
      const statuses = ['pendente', 'em_andamento', 'concluida'];
      const result = {};
      for (const s of statuses) {
        let list = [...this.data.tasks].filter(t => t.status === s);
        if (this.ui.taskAssignee) {
          list = list.filter(t => t.responsavel?.toLowerCase().includes(this.ui.taskAssignee.toLowerCase()));
        }
        if (this.ui.taskSpaceFilter !== 'all') {
          list = list.filter(t => t.space_id === this.ui.taskSpaceFilter);
        }
        if (this.ui.taskListFilter !== 'all') {
          list = list.filter(t => t.list_id === this.ui.taskListFilter);
        }
        list.sort((a, b) => {
          const prio = { urgente: 0, alta: 1, normal: 2, baixa: 3 };
          return (prio[a.prioridade] || 2) - (prio[b.prioridade] || 2);
        });
        result[s] = list.slice(0, 50); // Limit to 50 per column for performance
      }
      return result;
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
      const teamMembers = ['kaique', 'mariza', 'equipe', 'heitor', 'lara', 'hugo'];
      return this.data.tasks.filter(t => {
        const isForMentee = t.mentorado_nome?.toLowerCase() === nome;
        const isTeam = teamMembers.some(tm => t.responsavel?.toLowerCase()?.includes(tm));
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
      return { pendente: '⏳', em_andamento: '🔄', concluida: '✅' }[status] || '📋';
    },

    async moveTask(taskId, newStatus) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t) {
        t.status = newStatus;
        t.updated_at = new Date().toISOString();
        this._cacheTasksLocal();
        if (sb) sb.from('god_tasks').update({ status: newStatus }).eq('id', taskId).then(() => {});
        this.toast(`Tarefa movida para ${this.taskStatusLabel(newStatus)}`, 'success');
      }
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
        atrasada: tasks.filter(t => t.status === 'pendente' && (t.data_fim || t.prazo) && parseDateStr(t.data_fim || t.prazo) < SYSTEM_TODAY).length,
      };
    },

    // Dossiers: filtered
    get filteredDossiers() {
      if (this.ui.dossierFilter === 'all') return DOSSIER_PIPELINE;
      const statusMap = {
        enviado: ['enviado'],
        em_revisao: ['em_revisao', 'ajustar', 'aprovado_enviar', 'revisao_kaique'],
        producao_ia: ['producao_ia'],
        nao_iniciado: ['nao_iniciado'],
      };
      const statuses = statusMap[this.ui.dossierFilter] || [this.ui.dossierFilter];
      return DOSSIER_PIPELINE.filter(d => statuses.includes(d.status));
    },

    // Reminders: filtered
    get filteredReminders() {
      let list = [...this.data.reminders];
      if (this.ui.reminderFilter === 'ativo') list = list.filter(r => !r.concluido);
      else if (this.ui.reminderFilter === 'concluido') list = list.filter(r => r.concluido);
      list.sort((a, b) => {
        if (a.data && b.data) return parseDateStr(a.data) - parseDateStr(b.data);
        if (a.data) return -1;
        return 1;
      });
      return list;
    },

    // ===================== JWT AUTHENTICATION =====================

    async login() {
      // Authenticate with email/password using Supabase directly
      if (!this.auth.email || !this.auth.password) {
        this.auth.error = 'Email e senha são obrigatórios';
        return;
      }

      this.auth.loading = true;
      this.auth.error = '';

      try {
        // Call Supabase Auth directly (no backend needed)
        const result = await supabaseAuth.login(this.auth.email, this.auth.password);

        if (!result.success) {
          this.auth.error = result.error || 'Falha na autenticação';
          this.auth.loading = false;
          return;
        }

        // Save token
        this.auth.token = result.token;
        this.auth.refreshToken = result.refreshToken;
        this.auth.tokenExpires = Date.now() + result.expiresIn * 1000;
        this.auth.authenticated = true;
        this.auth.password = '';  // Clear password from memory
        this.auth.error = '';

        // Persist auth state
        localStorage.setItem(CONFIG.AUTH_STORAGE_KEY, JSON.stringify({
          token: this.auth.token,
          refreshToken: this.auth.refreshToken,
          email: this.auth.email,
          expiresAt: this.auth.tokenExpires
        }));

        this.toast('Autenticação bem-sucedida!', 'success');
        this.auth.loading = false;
      } catch (e) {
        console.error('[Spalla] Login error:', e);
        this.auth.error = 'Erro na autenticação';
        this.auth.loading = false;
      }
    },

    logout() {
      // Clear JWT token and reset auth state
      this.auth.authenticated = false;
      this.auth.token = null;
      this.auth.email = '';
      this.auth.password = '';
      this.auth.tokenExpires = null;
      localStorage.removeItem(CONFIG.AUTH_STORAGE_KEY);
      this.toast('Desconectado', 'info');
    },

    getAuthToken() {
      // Get current JWT token (check expiration first)
      if (!this.auth.token) return null;

      // Check if token expired
      if (this.auth.tokenExpires && this.auth.tokenExpires < Date.now()) {
        this.logout();
        return null;
      }

      return this.auth.token;
    },

    getAuthHeaders() {
      // Get headers with JWT token for API requests
      const token = this.getAuthToken();
      const headers = { 'Content-Type': 'application/json' };
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }
      return headers;
    },

    getUserDisplayName() {
      // Return display name based on logged-in user
      if (!this.auth.authenticated || !this.auth.email) {
        return 'Usuário';
      }
      // Extract name from email (part before @)
      const name = this.auth.email.split('@')[0];
      // Capitalize first letter
      return name.charAt(0).toUpperCase() + name.slice(1);
    },

    getUserRole() {
      // Return user role based on email
      if (!this.auth.authenticated || !this.auth.email) {
        return 'Visitante';
      }
      // Map emails to roles
      const emailRoles = {
        'hugo.nicchio@gmail.com': 'Mentor',
        'queila@case.com': 'Mentora CASE',
      };
      return emailRoles[this.auth.email] || 'Usuário';
    },

    navigate(page) {
      // Navigate to different pages
      this.ui.page = page;
      if (page === 'perfil') {
        this.profileForm.displayName = localStorage.getItem('spalla_displayName') || this.getUserDisplayName();
      }
      console.log(`[Spalla] Navigated to ${page}`);
    },

    saveProfile() {
      // Validate password
      if (this.profileForm.newPassword) {
        if (this.profileForm.newPassword.length < 8) {
          this.toast('Senha deve ter no mínimo 8 caracteres', 'error');
          return;
        }
        if (this.profileForm.newPassword !== this.profileForm.confirmPassword) {
          this.toast('Senhas não conferem', 'error');
          return;
        }
      }

      // Save display name to localStorage
      if (this.profileForm.displayName) {
        localStorage.setItem('spalla_displayName', this.profileForm.displayName);
      }

      // TODO: Send password change to backend API
      if (this.profileForm.newPassword) {
        console.log('[Spalla] Password change request would be sent to API');
        // const response = await fetch(`${CONFIG.API_BASE_URL}/api/auth/change-password`, {
        //   method: 'POST',
        //   headers: this.getAuthHeaders(),
        //   body: JSON.stringify({ newPassword: this.profileForm.newPassword })
        // });
      }

      this.toast('Perfil salvo com sucesso!', 'success');
      this.profileForm.newPassword = '';
      this.profileForm.confirmPassword = '';
    },

    deleteAccount() {
      // TODO: Implement account deletion with backend
      console.log('[Spalla] Account deletion request would be sent to API');
      this.toast('Funcionalidade em desenvolvimento', 'info');
    },

    async parseJsonResponse(response, operation = 'API call') {
      // Parse JSON response with Content-Type validation (HIGH-03)
      try {
        const contentType = response.headers.get('content-type');
        if (!contentType || !contentType.includes('application/json')) {
          console.error(`[Spalla] Invalid Content-Type for ${operation}:`, contentType);
          throw new Error(`Expected JSON, got ${contentType || 'no content-type'}`);
        }
        return await response.json();
      } catch (e) {
        console.error(`[Spalla] Failed to parse JSON from ${operation}:`, e);
        return null;
      }
    },

    // LOW-06: Performance tracking utilities
    perfMark(name) {
      // Mark start of a performance-measured operation
      this._perfMarkers[name] = performance.now();
    },

    perfMeasure(name) {
      // Measure elapsed time and log
      if (!this._perfMarkers[name]) return 0;
      const elapsed = performance.now() - this._perfMarkers[name];
      this.perf[name + 'Time'] = elapsed;
      console.log(`[Perf] ${name}: ${elapsed.toFixed(2)}ms`);
      delete this._perfMarkers[name];
      return elapsed;
    },

    // ===================== LIFECYCLE =====================

    async init() {
      console.log('[Spalla] init() starting');
      try {
        // Restore JWT token from localStorage
        const stored = localStorage.getItem(CONFIG.AUTH_STORAGE_KEY);
        if (stored) {
          try {
            const auth = JSON.parse(stored);
            this.auth.token = auth.token;
            this.auth.email = auth.email;
            this.auth.tokenExpires = auth.expiresAt;
            // Check if token not expired
            if (auth.expiresAt > Date.now()) {
              this.auth.authenticated = true;
            } else {
              this.logout();
            }
          } catch (e) {
            console.warn('[Spalla] Failed to restore auth:', e);
          }
        }
        console.log('[Spalla] Auth:', this.auth.authenticated);
        await this.loadTasks();
        console.log('[Spalla] Tasks loaded:', this.data.tasks.length);
        this.loadLocalReminders();
        if (this.auth.authenticated) {
          await this.loadDashboard();
          console.log('[Spalla] Dashboard loaded, mentees:', this.data.mentees.length);
          // Pre-fetch WhatsApp profile pics in background
          this._loadWaProfilePics();
          // Fetch schedule-related data from backend API
          this.fetchUpcomingCalls();
          this.fetchMenteesWithEmail();
          this.checkIntegrations();
        }
      } catch (e) {
        console.error('[Spalla] INIT ERROR:', e);
        // Ensure UI is visible even if init fails
        this.ui.loading = false;
        if (!this.data.mentees.length) this.loadDemoData();
      }
      // Attach global keyboard listener for media viewer
      window.addEventListener('keydown', (e) => this.mediaViewerKeyDown(e));
      console.log('[Spalla] init() complete');
    },

    async _loadWaProfilePics() {
      try {
        // Call via Vercel backend proxy
        const res = await fetch(CONFIG.API_BASE_URL + '/api/wa', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'findChats' }),
        });
        console.log('[WA] findChats response:', { status: res.status, ok: res.ok, contentType: res.headers.get('content-type') });
        if (!res.ok) {
          const errorBody = await res.text();
          console.warn('[WA] findChats failed:', { status: res.status, error: errorBody.substring(0, 200) });
          this.toast('Erro ao carregar fotos do WhatsApp', 'error');  // HIGH-06: Error boundary
          return;
        }
        const chats = await res.json();
        if (!Array.isArray(chats)) {
          console.warn('[WA] findChats returned non-array:', typeof chats);
          return;
        }
        const pics = {};
        // Build searchable text from each chat (name + pushName + subject)
        const chatEntries = chats.filter(c => c.profilePicUrl).map(c => ({
          text: [c.name, c.pushName, c.subject].filter(Boolean).join(' ').toLowerCase(),
          pic: c.profilePicUrl,
        }));
        // TODO: Add Supabase realtime subscriptions here for live updates
        for (const m of (this.data.mentees || [])) {
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
        console.log(`[Spalla] Loaded ${Object.keys(pics).length} WhatsApp profile pics`);
      } catch (e) {
        console.warn('[Spalla] Could not load WA profile pics:', e.message);
      }
    },

    // ===================== AUTH =====================

    // HIGH-01: Constant-time string comparison to prevent timing attacks
    _timingSafeCompare(a, b) {
      if (typeof a !== 'string' || typeof b !== 'string') return false;
      if (a.length !== b.length) {
        // Still iterate to waste time (constant-time behavior)
        for (let i = 0; i < 100000; i++) {}
        return false;
      }
      let result = 0;
      for (let i = 0; i < a.length; i++) {
        result |= a.charCodeAt(i) ^ b.charCodeAt(i);
      }
      return result === 0;
    },

    // REMOVED: Old single-password login. Now using async login() with email/password + JWT (line 477)

    logout() {
      this.auth.authenticated = false;
      localStorage.removeItem(CONFIG.AUTH_STORAGE_KEY);
    },

    // ===================== DATA LOADING =====================

    async loadDashboard() {
      // LOW-06: Performance tracking
      this.perfMark('dashboardLoad');
      this.ui.loading = true;
      sb = initSupabase();
      if (sb) {
        try {
          const [mentees, cohort, alerts, calls] = await Promise.all([
            sb.from('vw_god_overview').select('*'),
            sb.from('vw_god_cohort').select('*'),
            sb.rpc('fn_god_alerts'),
            sb.from('vw_god_calls').select('*').order('data_call', { ascending: false }).limit(500),
          ]);
          if (mentees.data?.length) {
            this.data.mentees = mentees.data;
            // MED-03: Removed sensitive debug logs (emails, full mentee data)
          } else {
            console.warn('[Spalla] Supabase mentees empty, using demo');
            this.loadDemoData();
          }
          if (cohort.data?.length) this.data.cohort = cohort.data;
          if (alerts.data?.length) this.data.alerts = alerts.data;
          if (calls.data?.length) {
            this._supabaseCalls = calls.data;
            console.log('[Spalla] Calls loaded from Supabase:', calls.data.length);
          }
          // Recalculate dias_desde_call with real call data
          if (this._supabaseCalls?.length) this._enrichMenteesWithCalls();
          // Enrich with Instagram handles, Zoom passwords, and emails
          if (sb && this.data.mentees?.length) {
            await this._enrichMenteesWithSocialAndZoom();
            await this._enrichMenteesWithEmails();
          }
          // MED-02: Setup realtime subscriptions for live updates
          if (sb) this._setupRealtimeSubscriptions();
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
      this.perfMeasure('dashboardLoad');  // LOW-06: Log performance
      this.ui.loading = false;
    },

    _enrichMenteesWithCalls() {
      // HIGH-07: Prevent race condition (concurrent enrichment calls)
      if (this._enrichingInProgress) return;
      this._enrichingInProgress = true;

      try {
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
      } finally {
        this._enrichingInProgress = false;
      }
    },

    async _enrichMenteesWithSocialAndZoom() {
      // Fetch Instagram handles + Zoom passwords from mentorados table (direct lookup by nome)
      try {
        const { data: menteeData } = await sb.from('mentorados').select('nome, instagram, zoom_password, link_gravacao_senha');
        if (!menteeData?.length) {
          console.log('[Spalla] Mentorados table empty or not accessible');
          return;
        }

        const menteeMap = {};
        for (const m of menteeData) {
          const key = (m.nome || '').toLowerCase().trim();
          if (key) {
            menteeMap[key] = {
              instagram: m.instagram || null,
              zoom_password: m.zoom_password || null,
              link_gravacao_senha: m.link_gravacao_senha || null,
            };
          }
        }

        // Enrich this.data.mentees with these fields
        this.data.mentees = this.data.mentees.map(m => {
          const key = (m.nome || '').toLowerCase().trim();
          const enrichment = menteeMap[key] || {};
          return {
            ...m,
            instagram: enrichment.instagram || m.instagram || null,
            zoom_password: enrichment.zoom_password || null,
            link_gravacao_senha: enrichment.link_gravacao_senha || null,
          };
        });

        console.debug('[Spalla] Enriched mentees with Instagram + Zoom data');
      } catch (e) {
        console.warn('[Spalla] Could not fetch Instagram/Zoom data:', e);
      }
    },

    async _enrichMenteesWithEmails() {
      // Fetch emails from Supabase mentorados table
      try {
        const { data: menteeData } = await sb.from('mentorados').select('nome, email');
        if (!menteeData?.length) {
          console.log('[Spalla] Could not fetch emails from mentorados table');
          return;
        }

        const emailMap = {};
        for (const m of menteeData) {
          const key = (m.nome || '').toLowerCase().trim();
          if (key && m.email) {
            emailMap[key] = m.email;
          }
        }

        // Enrich this.data.mentees with email field
        this.data.mentees = this.data.mentees.map(m => {
          const key = (m.nome || '').toLowerCase().trim();
          return {
            ...m,
            email: emailMap[key] || m.email || null,
          };
        });

        console.debug('[Spalla] Enriched mentees with email data');
      } catch (e) {
        console.warn('[Spalla] Could not fetch email data:', e);
      }
    },

    _setupRealtimeSubscriptions() {
      // MED-02: Setup Supabase Realtime subscriptions for live updates
      try {
        // Subscribe to changes in mentorados (mentees)
        const menteeChannel = sb.channel('mentorados_changes')
          .on('postgres_changes', { event: '*', schema: 'public', table: 'mentorados' }, payload => {
            console.debug('[Spalla] Mentee changed (realtime):', payload);
            // Reload dashboard to refresh mentee data
            this.loadDashboard();
          })
          .subscribe();

        // Subscribe to changes in calls
        const callsChannel = sb.channel('calls_changes')
          .on('postgres_changes', { event: '*', schema: 'public', table: 'calls_mentoria' }, payload => {
            console.debug('[Spalla] Call changed (realtime):', payload);
            // Reload call data
            if (payload.eventType === 'INSERT' || payload.eventType === 'UPDATE') {
              this._supabaseCalls = this._supabaseCalls || [];
              if (!this._supabaseCalls.find(c => c.id === payload.new?.id)) {
                this._supabaseCalls.push(payload.new);
              }
              this._enrichMenteesWithCalls();
            }
          })
          .subscribe();

        // Subscribe to changes in tasks
        const tasksChannel = sb.channel('tasks_changes')
          .on('postgres_changes', { event: '*', schema: 'public', table: 'god_tasks' }, payload => {
            console.debug('[Spalla] Task changed (realtime):', payload);
            this.loadTasks(); // Reload tasks when changes occur
          })
          .subscribe();

        console.log('[Spalla] Realtime subscriptions setup complete');
      } catch (e) {
        console.warn('[Spalla] Could not setup realtime subscriptions:', e);
      }
    },

    async loadMenteeDetail(id) {
      this.ui.detailLoading = true;
      this.ui.selectedMenteeId = id;
      this.ui.page = 'detail';
      this.ui.activeDetailTab = 'resumo';
      window.scrollTo({ top: 0, behavior: 'smooth' });
      if (sb) {
        try {
          // Load deep detail + real calls in parallel
          const [detailRes, callsRes] = await Promise.all([
            sb.rpc('fn_god_mentorado_deep', { p_id: id }),
            sb.from('vw_god_calls').select('*').eq('mentorado_id', id).order('data_call', { ascending: false }),
          ]);
          if (detailRes.data) {
            let detail = null;
            try {
              detail = typeof detailRes.data === 'string' ? JSON.parse(detailRes.data) : detailRes.data;
            } catch (e) {
              console.error('[Spalla] Failed to parse detail JSON:', e);
              this.toast('Erro ao carregar detalhes do mentorado', 'error');
              return;
            }
            // Enrich with real calls from vw_god_calls
            if (callsRes.data?.length) {
              detail.last_calls = callsRes.data.map(c => ({
                data_call: c.data_call, tipo: c.tipo_call || 'acompanhamento',
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
      const nome = this.data.detail?.profile?.nome;
      if (!nome) return;
      try {
        // Find matching WA chat
        const firstName = nome.split(' ')[0].toLowerCase();
        let chats = this.data.whatsappChats;
        // If chats not loaded yet, fetch them
        if (!chats || chats.length === 0) {
          const res = await fetch(CONFIG.API_BASE_URL + '/api/wa', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: 'findChats' }),
          });
          if (res.ok) {
            try {
              chats = await res.json();
            } catch (e) {
              console.warn('[Spalla] Failed to parse chats JSON:', e.message);
              return;
            }
          }
        }
        const chat = (chats || []).find(c => {
          const pushName = (c.pushName || c.name || '').toLowerCase();
          return pushName.includes(firstName);
        });
        if (!chat) {
          console.log('[Spalla] No matching chat found for:', firstName);
          return;
        }

        // Fetch last 10 messages
        const res = await fetch(CONFIG.API_BASE_URL + '/api/wa', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'findMessages', remoteJid: chat.remoteJid || chat.id, limit: 10 }),
        });
        if (!res.ok) {
          const errorBody = await res.text();
          console.warn('[Spalla] findMessages failed:', { status: res.status, error: errorBody.substring(0, 200) });
          return;
        }
        let data;
        try {
          data = await res.json();
        } catch (e) {
          console.warn('[Spalla] Failed to parse messages JSON:', e.message);
          return;
        }
        const msgs = data.messages?.records || data.messages || data || [];
        const interactions = (Array.isArray(msgs) ? msgs : []).reverse().map(msg => ({
          sender: msg.key?.fromMe ? 'Equipe CASE' : (msg.pushName || nome),
          conteudo: this.getWaMessageText(msg),
          created_at: msg.messageTimestamp ? new Date(msg.messageTimestamp * 1000).toISOString() : null,
        })).filter(i => i.conteudo);

        if (this.data.detail && interactions.length) {
          this.data.detail.last_interactions = interactions;
          this.data.detail._waChat = chat;
        }
      } catch (e) {
        console.warn('[Spalla] Could not load detail WA messages:', e.message);
      }
    },

    openDetailWhatsApp() {
      const chat = this.data.detail?._waChat;
      if (chat) {
        this.navigate('whatsapp');
        this.fetchWhatsAppChats().then(() => this.selectWhatsAppChat(chat));
      } else {
        this.navigate('whatsapp');
        this.fetchWhatsAppChats();
      }
    },

    // ===================== NAVIGATION =====================

    navigate(page) {
      this.ui.page = page;
      this.ui.mobileMenuOpen = false;
      window.scrollTo({ top: 0, behavior: 'smooth' });
    },

    goBack() {
      this.ui.page = 'dashboard';
      this.data.detail = null;
      this.ui.selectedMenteeId = null;
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
      this.ui.filters = { fase: '', risco: '', cohort: '', status: '', financeiro: '' };
      this.ui.search = '';
    },

    filterByPhase(fase) {
      this.ui.filters.fase = this.ui.filters.fase === fase ? '' : fase;
    },

    // ===================== TASK MANAGEMENT =====================

    async loadTasks() {
      if (sb) {
        try {
          const { data, error } = await sb.from('vw_god_tasks_full').select('*').order('created_at', { ascending: false }).limit(200);
          if (!error && data?.length) {
            this.data.tasks = data.map(t => ({
              ...t, prazo: t.data_fim,
              subtasks: (t.subtasks || []).map(s => ({ text: s.texto || s.text, done: s.done })),
              checklist: (t.checklist || []).map(c => ({ text: c.texto || c.text, done: c.done })),
              comments: (t.comments || []).map(c => ({ id: c.id, author: c.author, text: c.texto || c.text, timestamp: c.created_at || c.timestamp })),
              handoffs: (t.handoffs || []).map(h => ({ from: h.from_person || h.from, to: h.to_person || h.to, note: h.note, date: h.created_at || h.date })),
              tags: t.tags || [], attachments: [],
            }));
            this._autoCategorize();
            this._cacheTasksLocal();
            console.log('[Spalla] Tasks loaded from Supabase:', data.length);
            return;
          }
        } catch (e) { console.warn('[Spalla] Tasks fetch error, falling back:', e.message); }
      }
      // Fallback: localStorage
      try {
        const raw = localStorage.getItem(CONFIG.TASKS_STORAGE_KEY);
        if (raw) {
          const parsed = JSON.parse(raw);
          if (Array.isArray(parsed) && parsed.length > 0) {
            const validTasks = parsed.filter(t => t.id && t.titulo);
            if (validTasks.length > 0) {
              this.data.tasks = validTasks;
              this._autoCategorize();
              return;
            }
          }
        }
      } catch (e) {
        console.warn('[Spalla] Failed to load tasks from localStorage:', e.message);
      }
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

    async _sbDeleteTask(taskId) {
      if (!sb) return;
      try { await sb.from('god_tasks').delete().eq('id', taskId); } catch (e) { console.warn('[Spalla] Task delete error:', e.message); }
    },

    async _sbSyncSubtasks(taskId, subtasks) {
      if (!sb) return;
      try {
        await sb.from('god_task_subtasks').delete().eq('task_id', taskId);
        if (subtasks?.length) {
          await sb.from('god_task_subtasks').insert(subtasks.map((s, i) => ({ task_id: taskId, texto: s.text, done: s.done, sort_order: i })));
        }
      } catch (e) { console.warn('[Spalla] Subtask sync error:', e.message); }
    },

    async _sbSyncChecklist(taskId, checklist) {
      if (!sb) return;
      try {
        await sb.from('god_task_checklist').delete().eq('task_id', taskId);
        if (checklist?.length) {
          await sb.from('god_task_checklist').insert(checklist.map((c, i) => ({ task_id: taskId, texto: c.text, done: c.done, sort_order: i })));
        }
      } catch (e) { console.warn('[Spalla] Checklist sync error:', e.message); }
    },

    async _sbAddComment(taskId, author, text) {
      if (!sb) return;
      try { await sb.from('god_task_comments').insert({ task_id: taskId, author, texto: text }); } catch (e) { console.warn('[Spalla] Comment error:', e.message); }
    },

    async _sbDeleteComment(commentId) {
      if (!sb) return;
      try { await sb.from('god_task_comments').delete().eq('id', commentId); } catch (e) { console.warn('[Spalla] Delete comment error:', e.message); }
    },

    async _sbAddHandoff(taskId, from, to, note) {
      if (!sb) return;
      try { await sb.from('god_task_handoffs').insert({ task_id: taskId, from_person: from, to_person: to, note }); } catch (e) { console.warn('[Spalla] Handoff error:', e.message); }
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
          newSubtask: '',
          newCheckItem: '',
          newComment: '',
          newTag: '',
        };
        this.ui.taskEditId = task.id;
      } else {
        this.taskForm = { titulo: '', descricao: '', responsavel: '', acompanhante: '', mentorado_nome: '', prioridade: 'normal', prazo: '', data_inicio: '', data_fim: '', doc_link: '', subtasks: [], checklist: [], comments: [], attachments: [], tags: [], parent_task_id: null, space_id: 'space_jornada', list_id: '', newSubtask: '', newCheckItem: '', newComment: '', newTag: '' };
        this.ui.taskEditId = null;
      }
      this.ui.taskModal = true;
    },

    closeTaskModal() {
      this.ui.taskModal = false;
      this.ui.taskEditId = null;
    },

    async saveTask() {
      if (!this.taskForm.titulo.trim()) {
        this.toast('Título é obrigatório', 'error');  // MED-06
        return;
      }
      const formData = { ...this.taskForm };
      delete formData.newSubtask;
      delete formData.newCheckItem;
      delete formData.newComment;
      delete formData.newTag;
      if (formData.data_fim) formData.prazo = formData.data_fim;

      if (this.ui.taskEditId) {
        const idx = this.data.tasks.findIndex(t => t.id === this.ui.taskEditId);
        if (idx !== -1) {
          const updated = { ...this.data.tasks[idx], ...formData, updated_at: new Date().toISOString() };
          this.data.tasks[idx] = updated;
          this._sbUpsertTask(updated);
          this._sbSyncSubtasks(updated.id, updated.subtasks);
          this._sbSyncChecklist(updated.id, updated.checklist);
        }
      } else {
        const newId = crypto.randomUUID ? crypto.randomUUID() : 'task_' + Date.now();
        const newTask = {
          id: newId, ...formData,
          status: 'pendente', fonte: 'manual',
          comments: [], attachments: [], handoffs: [],
          tags: formData.tags || [],
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        };
        this.data.tasks.push(newTask);
        this._sbUpsertTask(newTask);
        if (newTask.subtasks?.length) this._sbSyncSubtasks(newId, newTask.subtasks);
        if (newTask.checklist?.length) this._sbSyncChecklist(newId, newTask.checklist);
      }
      this._cacheTasksLocal();
      this.closeTaskModal();
      this.toast('Tarefa salva', 'success');
    },

    async updateTaskStatus(taskId, newStatus) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t) {
        t.status = newStatus;
        t.updated_at = new Date().toISOString();
        this._cacheTasksLocal();
        if (sb) {
          try {
            await sb.from('god_tasks').update({ status: newStatus, updated_at: t.updated_at }).eq('id', taskId);
            this.toast(`Tarefa atualizada para ${newStatus}`, 'success');  // MED-07
          } catch (e) {
            console.warn('[Spalla] Failed to update task:', e);
            this.toast('Erro ao sincronizar tarefa', 'error');  // MED-07: Error boundary
          }
        }
      }
    },

    async deleteTask(taskId) {
      this.data.tasks = this.data.tasks.filter(t => t.id !== taskId);
      this._cacheTasksLocal();
      this._sbDeleteTask(taskId);
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
        t.comments.push({ id: commentId, author: 'Queila Trizotti', text: commentText, timestamp: new Date().toISOString() });
        this.taskForm.newComment = '';
        this._cacheTasksLocal();
        this._sbAddComment(taskId, 'Queila Trizotti', commentText);
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
    addTag(taskId) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t && this.taskForm.newTag?.trim()) {
        if (!t.tags) t.tags = [];
        if (!t.tags.includes(this.taskForm.newTag.trim())) {
          t.tags.push(this.taskForm.newTag.trim());
        }
        this.taskForm.newTag = '';
        this._cacheTasksLocal();
        if (sb) sb.from('god_tasks').update({ tags: t.tags }).eq('id', taskId).then(() => {});
      }
    },

    removeTag(taskId, tag) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t && t.tags) {
        t.tags = t.tags.filter(tg => tg !== tag);
        this._cacheTasksLocal();
        if (sb) sb.from('god_tasks').update({ tags: t.tags }).eq('id', taskId).then(() => {});
      }
    },

    setParentTask(taskId, parentId) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t) {
        t.parent_task_id = parentId || null;
        this._cacheTasksLocal();
        if (sb) sb.from('god_tasks').update({ parent_task_id: parentId || null }).eq('id', taskId).then(() => {});
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
      if (t) {
        if (!t.handoffs) t.handoffs = [];
        t.handoffs.push({ from, to, note, date: new Date().toISOString() });
        t.responsavel = to;
        t.updated_at = new Date().toISOString();
        this._cacheTasksLocal();
        this._sbAddHandoff(taskId, from, to, note);
        if (sb) sb.from('god_tasks').update({ responsavel: to }).eq('id', taskId).then(() => {});
        this.toast(`Tarefa passada de ${from} para ${to}`, 'success');
      }
    },

    // Gantt helpers
    get ganttTasks() {
      let tasks = [...this.data.tasks].filter(t => t.status !== 'concluida');
      if (this.ui.taskSpaceFilter !== 'all') {
        tasks = tasks.filter(t => t.space_id === this.ui.taskSpaceFilter);
      }
      if (this.ui.taskListFilter !== 'all') {
        tasks = tasks.filter(t => t.list_id === this.ui.taskListFilter);
      }
      if (this.ui.taskAssignee) {
        tasks = tasks.filter(t => t.responsavel?.toLowerCase().includes(this.ui.taskAssignee.toLowerCase()));
      }
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

    loadLocalReminders() {
      try {
        const raw = localStorage.getItem(CONFIG.REMINDERS_STORAGE_KEY);
        if (raw) {
          const parsed = JSON.parse(raw);
          if (Array.isArray(parsed)) {
            // MED-09: Validate structure of each reminder
            const validated = parsed.filter(rem => {
              if (!rem || typeof rem !== 'object') return false;
              if (typeof rem.texto !== 'string' || !rem.texto.trim()) return false;
              if (typeof rem.data !== 'string') return false;
              if (!['low', 'normal', 'high'].includes(rem.prioridade)) rem.prioridade = 'normal';
              if (typeof rem.mentorado_nome !== 'string') rem.mentorado_nome = '';
              return true;
            });
            this.data.reminders = validated;
          } else {
            throw new Error('Invalid reminders format');
          }
        }
      } catch (e) {
        console.warn('[Spalla] Failed to load reminders:', e.message);
        this.data.reminders = [];
      }
    },

    saveLocalReminders() {
      localStorage.setItem(CONFIG.REMINDERS_STORAGE_KEY, JSON.stringify(this.data.reminders));
    },

    openReminderModal() {
      this.reminderForm = { texto: '', data: '', prioridade: 'normal', mentorado_nome: '' };
      this.ui.reminderModal = true;
    },

    closeReminderModal() {
      this.ui.reminderModal = false;
    },

    saveReminder() {
      if (!this.reminderForm.texto.trim()) return;
      this.data.reminders.push({
        id: 'rem_' + Date.now(),
        ...this.reminderForm,
        concluido: false,
        created_at: new Date().toISOString(),
      });
      this.saveLocalReminders();
      this.closeReminderModal();
      this.toast('Lembrete criado', 'success');
    },

    toggleReminder(id) {
      const r = this.data.reminders.find(x => x.id === id);
      if (r) {
        r.concluido = !r.concluido;
        this.saveLocalReminders();
      }
    },

    deleteReminder(id) {
      this.data.reminders = this.data.reminders.filter(r => r.id !== id);
      this.saveLocalReminders();
      this.toast('Lembrete removido', 'info');
    },

    // ===================== WHATSAPP (Evolution API) =====================

    async fetchWhatsAppChats() {
      this.ui.whatsappLoading = true;
      try {
        // Fetch chats directly from Evolution API
        const chats = await evolutionDirect.getChats();

        if (chats && chats.length > 0) {
          // Sort by most recent
          this.data.whatsappChats = chats.sort((a, b) => {
            const ta = new Date(a.updatedAt || 0).getTime();
            const tb = new Date(b.updatedAt || 0).getTime();
            return tb - ta;
          });
          this.toast(`${this.data.whatsappChats.length} conversas carregadas`, 'success');
        } else {
          throw new Error('No chats returned');
        }
      } catch (e) {
        console.log('[Spalla] Evolution API unavailable. Using demo data.', e.message);
        // Load demo chats as fallback
        this.data.whatsappChats = DEMO_WA_CHATS;
      }
      this.ui.whatsappLoading = false;
    },

    async selectWhatsAppChat(chat) {
      console.log('[WA] selectWhatsAppChat called with:', { name: chat?.name || chat?.pushName, id: chat?.id });

      if (!chat || !chat.id) {
        console.warn('[WA] Invalid chat object');
        return;
      }

      this.ui.whatsappSelectedChat = chat;
      this.ui.whatsappLoading = true;

      // CLEAR messages IMMEDIATELY
      this.data.whatsappMessages = [];
      console.log('[WA] Cleared messages, now fetching...');

      try {
        const remoteJid = chat.remoteJid || chat.id;
        console.log('[WA] Chat object:', chat);
        console.log('[WA] remoteJid:', remoteJid);

        // Fetch messages directly from Evolution API
        const messages = await evolutionDirect.getMessages(remoteJid);

        if (Array.isArray(messages) && messages.length > 0) {
          this.data.whatsappMessages = messages;
          console.log('[WA] Got', messages.length, 'messages');
        } else {
          console.log('[WA] No messages found');
          this.data.whatsappMessages = [];
        }
      } catch (e) {
        console.error('[WA] Error:', e.message);
      }

      this.ui.whatsappLoading = false;
      this.$nextTick(() => {
        const el = document.getElementById('wa-messages-end');
        if (el) el.scrollIntoView({ behavior: 'smooth' });
      });
    },

    async sendWhatsAppMessage() {
      if (!this.ui.whatsappMessage.trim() || !this.ui.whatsappSelectedChat) return;
      const msg = this.ui.whatsappMessage.trim();
      this.ui.whatsappMessage = '';
      try {
        const remoteJid = this.ui.whatsappSelectedChat.remoteJid || this.ui.whatsappSelectedChat.id;

        // Send via Evolution API directly
        const result = await evolutionDirect.sendMessage(remoteJid, msg);

        if (result) {
          this.data.whatsappMessages.push({
            id: result.key?.id || Date.now(),
            fromMe: true,
            sender: 'me',
            body: msg,
            timestamp: new Date().toISOString(),
            type: 'text',
          });
          this.toast('Mensagem enviada', 'success');
          this.$nextTick(() => {
            const el = document.getElementById('wa-messages-end');
            if (el) el.scrollIntoView({ behavior: 'smooth' });
          });
        } else {
          throw new Error('Falha ao enviar');
        }
      } catch (e) {
        console.error('[Spalla] WA send error:', e);
        this.toast('Erro ao enviar: ' + e.message, 'error');
      }
    },

    getWaMessageText(msg) {
      if (!msg || !msg.message) return '(mensagem vazia)';  // MED-11: Fallback
      const m = msg.message;
      if (m.conversation) return m.conversation;
      if (m.extendedTextMessage?.text) return m.extendedTextMessage.text;
      if (m.imageMessage) return m.imageMessage.caption || '[Imagem]';
      if (m.videoMessage) return m.videoMessage.caption || '[Vídeo]';
      if (m.audioMessage) return '[Áudio]';
      if (m.documentMessage) return m.documentMessage.title || m.documentMessage.fileName || '[Documento]';
      if (m.stickerMessage) return '[Sticker]';
      if (m.contactMessage) return m.contactMessage.displayName || '[Contato]';
      if (m.locationMessage) return '[Localização]';
      if (m.reactionMessage) return m.reactionMessage.text || '[Reação]';
      return '(tipo desconhecido)';  // MED-11: Better fallback message
    },

    getWaMessageTime(msg) {
      if (!msg?.messageTimestamp) return '';
      const d = new Date(msg.messageTimestamp * 1000);
      return d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
    },

    getWaChatName(chat) {
      return chat?.name || chat?.subject || chat?.pushName || chat?.id?.split('@')[0] || 'Chat';
    },

    // ===================== MEDIA VIEWER =====================

    openMediaViewer(msg) {
      if (!msg || !msg.message) return;
      this.ui.mediaViewerOpen = true;
      this.ui.mediaViewerData = msg;
      console.log('[MediaViewer] Opened:', msg.message?.imageMessage ? 'image' : msg.message?.videoMessage ? 'video' : msg.message?.audioMessage ? 'audio' : 'unknown');
    },

    closeMediaViewer() {
      this.ui.mediaViewerOpen = false;
      this.ui.mediaViewerData = null;
      this.ui.mediaViewerZoom = 1;
      this.ui.mediaViewerPanX = 0;
      this.ui.mediaViewerPanY = 0;
      console.log('[MediaViewer] Closed');
    },

    // Zoom controls
    mediaViewerZoomIn() {
      this.ui.mediaViewerZoom = Math.min(5, this.ui.mediaViewerZoom + 0.2);
    },

    mediaViewerZoomOut() {
      this.ui.mediaViewerZoom = Math.max(1, this.ui.mediaViewerZoom - 0.2);
    },

    mediaViewerResetZoom() {
      this.ui.mediaViewerZoom = 1;
      this.ui.mediaViewerPanX = 0;
      this.ui.mediaViewerPanY = 0;
    },

    // Drag controls
    mediaViewerStartDrag(e) {
      if (this.ui.mediaViewerZoom <= 1) return;
      this.ui.mediaViewerIsDragging = true;
      this.ui.mediaViewerDragStart = { x: e.clientX, y: e.clientY };
    },

    mediaViewerMoveDrag(e) {
      if (!this.ui.mediaViewerIsDragging) return;
      const dx = e.clientX - this.ui.mediaViewerDragStart.x;
      const dy = e.clientY - this.ui.mediaViewerDragStart.y;
      this.ui.mediaViewerPanX += dx;
      this.ui.mediaViewerPanY += dy;
      this.ui.mediaViewerDragStart = { x: e.clientX, y: e.clientY };
    },

    mediaViewerEndDrag() {
      this.ui.mediaViewerIsDragging = false;
    },

    // Wheel zoom
    mediaViewerWheel(e) {
      e.preventDefault();
      const delta = e.deltaY > 0 ? -0.1 : 0.1;
      this.ui.mediaViewerZoom = Math.max(1, Math.min(5, this.ui.mediaViewerZoom + delta));
    },

    // Get transform for zoomed image
    mediaViewerGetTransform() {
      const scale = this.ui.mediaViewerZoom;
      const x = this.ui.mediaViewerPanX;
      const y = this.ui.mediaViewerPanY;
      return `scale(${scale}) translate(${x}px, ${y}px)`;
    },

    // Get proxied media URL for audio/video (handles CORS)
    getProxiedMediaUrl(evolutionUrl) {
      if (!evolutionUrl) return null;
      try {
        const backendUrl = CONFIG.API_BASE_URL;
        return `${backendUrl}/api/wa/media-proxy?url=${encodeURIComponent(evolutionUrl)}`;
      } catch (error) {
        console.error('[App] Error proxying media URL:', error);
        return evolutionUrl;
      }
    },

    // Download media file
    downloadMedia() {
      if (!this.ui.mediaViewerData?.message) return;

      const msg = this.ui.mediaViewerData.message;
      let url, filename = 'media';

      if (msg.imageMessage?.url) {
        url = msg.imageMessage.url;
        filename = `image_${Date.now()}.jpg`;
      } else if (msg.videoMessage?.url) {
        url = msg.videoMessage.url;
        filename = `video_${Date.now()}.mp4`;
      } else if (msg.audioMessage?.url) {
        url = msg.audioMessage.url;
        filename = `audio_${Date.now()}.mp3`;
      } else {
        return;
      }

      // Use proxied URL for download
      const link = document.createElement('a');
      link.href = this.getProxiedMediaUrl(url);
      link.download = filename;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      console.log('[MediaViewer] Downloaded:', filename);
    },

    // Handle keyboard shortcuts in media viewer
    mediaViewerKeyDown(e) {
      if (!this.ui.mediaViewerOpen) return;

      switch (e.key) {
        case 'Escape':
          this.closeMediaViewer();
          break;
        case '+':
        case '=':
          this.mediaViewerZoomIn();
          break;
        case '-':
        case '_':
          this.mediaViewerZoomOut();
          break;
        case 'r':
        case 'R':
          this.mediaViewerResetZoom();
          break;
        case 'd':
        case 'D':
          if (e.ctrlKey || e.metaKey) {
            e.preventDefault();
            this.downloadMedia();
          }
          break;
      }
    },

    // ===================== INSTAGRAM HELPERS =====================

    validateInstagramHandle(handle) {
      // Validate Instagram handle format (MED-04)
      if (!handle) return false;
      // Instagram handles: 1-30 chars, alphanumeric + . _ -, no consecutive dots/dashes
      const regex = /^[a-z0-9._-]{1,30}$/i;
      return regex.test(handle.replace('@', ''));
    },

    igPhoto(handleOrName) {
      if (!handleOrName) return null;
      void this.photoTick; // Force Alpine reactivity on photoTick change

      const isHandle = !handleOrName.includes(' ');
      const handle = isHandle ? handleOrName.replace('@', '') : null;

      // Strategy 1: Try exact lookup in INSTAGRAM_PROFILES
      if (handle && INSTAGRAM_PROFILES && INSTAGRAM_PROFILES[handle]) {
        const foto = INSTAGRAM_PROFILES[handle].foto;
        console.debug('[igPhoto] Found in INSTAGRAM_PROFILES (exact)', {
          input: handleOrName,
          handle,
          foto
        });
        return foto;
      }

      // Strategy 2: Try lowercase lookup (Instagram handles are case-insensitive)
      if (handle) {
        const handleLower = handle.toLowerCase();
        if (INSTAGRAM_PROFILES && INSTAGRAM_PROFILES[handleLower]) {
          const foto = INSTAGRAM_PROFILES[handleLower].foto;
          console.debug('[igPhoto] Found in INSTAGRAM_PROFILES (lowercase)', {
            input: handleOrName,
            handleLower,
            foto
          });
          return foto;
        }
      }

      // Strategy 3: If full name provided, search INSTAGRAM_PROFILES by nome field
      if (!handle && INSTAGRAM_PROFILES) {
        const nameLower = handleOrName.toLowerCase();
        for (const [key, profile] of Object.entries(INSTAGRAM_PROFILES)) {
          if (profile.nome && profile.nome.toLowerCase().includes(nameLower)) {
            console.debug('[igPhoto] Found in INSTAGRAM_PROFILES (by name)', {
              input: handleOrName,
              key,
              profileName: profile.nome,
              foto: profile.foto
            });
            return profile.foto;
          }
        }
      }

      // Fallback: Generate path dynamically for files not in database
      const clean = (handle || handleOrName).replace('@', '').toLowerCase();
      const fileKey = isHandle ? clean : clean.replace(/\s+/g, '_');
      const photoPath = `photos/${fileKey}.jpg`;
      console.debug('[igPhoto] Generated fallback path', {
        input: handleOrName,
        isHandle,
        fileKey,
        photoPath,
        note: 'Not found in INSTAGRAM_PROFILES, using generated path'
      });
      return photoPath;
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

    get allCallsGlobal() {
      // If real Supabase calls loaded, use them
      if (this._supabaseCalls?.length) {
        // Calculate date 30 days ago
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        const thirtyDaysAgoStr = thirtyDaysAgo.toISOString().split('T')[0];

        return this._supabaseCalls
          .filter(c => {
            // Show calls from last 30 days and future calls
            const callDate = (c.data_call || '').split('T')[0];
            return callDate >= thirtyDaysAgoStr;
          })
          .map(c => ({
            mentorado: c.mentorado_nome, data: c.data_call,
            tipo: c.tipo_call || 'acompanhamento', duracao: c.duracao_minutos || 0,
            topic: c.zoom_topic || '', resumo: c.resumo || null,
            gravacao: c.link_gravacao || null, transcricao: c.link_transcricao || null,
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
          const dias = Math.floor((hoje - this._parseDate(m.ultima_call_data).getTime()) / 86400000);
          return dias > 30;
        })
        .map(m => ({
          ...m,
          dias: m.ultima_call_data ? Math.floor((hoje - this._parseDate(m.ultima_call_data).getTime()) / 86400000) : null,
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

    onMentoradoSelect() {
      const nome = this.scheduleForm.mentorado;
      if (!nome) return;  // MED-03: Removed debug logs
      const m = this.data.mentees.find(x => x.nome === nome);
      if (m) {
        this.scheduleForm.mentorado_id = m.id || '';
        this.scheduleForm.email = m.email || '';
      } else {
        console.warn('[Spalla] Mentorado not found');  // Keep warning (non-sensitive)
      }
    },

    getScheduleBlock(nome) {
      // Validações desabilitadas — dados inconsistentes no DB
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
        const resp = await fetch(window.API_BASE_URL + '/api/schedule-call', {
          method: 'POST',
          headers: this.getAuthHeaders(),
          body: JSON.stringify({
            mentorado: f.mentorado,
            mentorado_id: f.mentorado_id || '',
            email: f.email || '',
            tipo: f.tipo || 'acompanhamento',
            data: f.data,
            horario: f.horario || '10:00',
            duracao: f.duracao || 60,
            notas: f.notas || '',
            use_zoom: true,
          })
        });

        const result = await resp.json();
        console.log('[Schedule] ===== FULL RESPONSE =====');
        console.log('[Schedule] Success:', result.success);
        console.log('[Schedule] Message:', result.message);
        console.log('[Schedule] Zoom ID:', result.zoom?.id);
        console.log('[Schedule] Zoom URL:', result.zoom?.join_url);
        console.log('[Schedule] Zoom Error:', result.zoomError);
        console.log('[Schedule] ===== CALENDAR DETAILS =====');
        console.log('[Schedule] Calendar ID:', result.calendar?.id);
        console.log('[Schedule] Calendar Link:', result.calendar?.link);
        console.log('[Schedule] Calendar Error:', result.calendarError);
        console.log('[Schedule] ===== FULL RESPONSE OBJECT =====', result);

        if (result.zoom?.id && result.calendar?.id) {
          this.toast('✅ Zoom + Calendar criados!', 'success');
        } else if (result.zoom?.id) {
          this.toast('✅ Zoom criado (Calendar pendente)', 'warning');
        } else if (result.calendar?.id) {
          this.toast('✅ Calendar criado (Zoom pendente)', 'warning');
        } else {
          this.toast('✅ Call registrada (Zoom/Calendar pendentes)', 'warning');
        }

        // Store locally for immediate UI update
        if (!this.data.scheduledCalls) this.data.scheduledCalls = [];
        this.data.scheduledCalls.push({
          mentorado: f.mentorado,
          data: f.data,
          horario: f.horario,
          tipo: f.tipo,
          zoom_url: result.zoom?.join_url || '',
          calendar_link: result.calendar?.link || '',
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
        const resp = await fetch(window.API_BASE_URL + '/api/calls/upcoming', { headers: this.getAuthHeaders() });
        const calls = await resp.json();
        if (Array.isArray(calls)) {
          this.data.scheduledCalls = calls.map(c => ({
            mentorado: c.zoom_topic?.replace(/^Call \w+ — /, '') || '',
            data: c.data_call?.split('T')[0] || '',
            horario: c.data_call?.split('T')[1]?.substring(0, 5) || '',
            tipo: c.tipo || c.tipo_call || '',
            zoom_url: c.link_gravacao || '',
            status: c.status || 'agendada',
          }));
        }
      } catch (e) {
        console.log('[Schedule] Could not fetch upcoming calls:', e);
      }
    },

    async fetchMenteesWithEmail() {
      try {
        const resp = await fetch(window.API_BASE_URL + '/api/mentees');
        const mentees = await resp.json();
        if (Array.isArray(mentees)) {
          this._menteesWithEmail = mentees;
        }
      } catch (e) {
        console.log('[Mentees] Could not fetch:', e);
      }
    },

    async checkIntegrations() {
      try {
        const resp = await fetch(window.API_BASE_URL + '/api/health');
        const health = await resp.json();
        this._integrations = health;
        console.log('[Spalla] Integrations:', health);
      } catch (e) {
        console.log('[Health] Could not check:', e);
      }
    },

    // ===================== DOSSIER HELPERS =====================

    dossierStatusConfig(status) {
      return DOSSIER_STATUS_CONFIG[status] || DOSSIER_STATUS_CONFIG.nao_iniciado;
    },

    dossierStats() {
      const total = DOSSIER_PIPELINE.length;
      const enviados = DOSSIER_PIPELINE.filter(d => d.status === 'enviado').length;
      const emRevisao = DOSSIER_PIPELINE.filter(d => ['em_revisao', 'ajustar', 'aprovado_enviar', 'revisao_kaique'].includes(d.status)).length;
      const producaoIa = DOSSIER_PIPELINE.filter(d => d.status === 'producao_ia').length;
      const naoIniciado = DOSSIER_PIPELINE.filter(d => d.status === 'nao_iniciado').length;
      return { total, enviados, emRevisao, producaoIa, naoIniciado };
    },

    dossierSearchUrl(title) {
      if (!title) return null;
      const direct = getDossierDirectLink(title);
      if (direct) return direct;
      return `https://drive.google.com/drive/search?q=${encodeURIComponent(title)}`;
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

    _parseDate(dateStr) {
      if (!dateStr) return null;
      // Handle DD/MM/YYYY format
      if (/^\d{2}\/\d{2}\/\d{4}$/.test(dateStr)) {
        const [dd, mm, yy] = dateStr.split('/');
        return new Date(`${yy}-${mm}-${dd}T00:00:00`);
      }
      const d = new Date(dateStr);
      return isNaN(d.getTime()) ? null : d;
    },

    systemDateLabel() {
      return SYSTEM_TODAY.toLocaleDateString('pt-BR', { weekday: 'long', day: '2-digit', month: 'long', year: 'numeric' });
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

    timeAgo(dateStr) {
      if (!dateStr) return '-';
      const d = this._parseDate(dateStr);
      if (!d) return '-';
      const days = Math.floor((SYSTEM_TODAY - d) / (1000 * 60 * 60 * 24));
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
      return Math.floor((SYSTEM_TODAY - d) / (1000 * 60 * 60 * 24));
    },

    today() {
      return SYSTEM_TODAY.toLocaleDateString('pt-BR', { weekday: 'long', day: '2-digit', month: 'long', year: 'numeric' });
    },

    isOverdue(dateStr) {
      if (!dateStr) return false;
      const d = this._parseDate(dateStr);
      return d ? d < SYSTEM_TODAY : false;
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
  };
}

// ===== DEMO DATA moved to data.js =====

// ===== INITIALIZATION LOG =====
console.log('[Spalla] app.js loaded successfully');
console.log('[Spalla] spalla() function defined:', typeof spalla === 'function');
console.log('[Spalla] DOSSIER_PIPELINE available:', typeof DOSSIER_PIPELINE !== 'undefined');
console.log('[Spalla] DOSSIER_STATUS_CONFIG available:', typeof DOSSIER_STATUS_CONFIG !== 'undefined');

// Auto-init Alpine if it's already loaded
if (typeof window.Alpine !== 'undefined' && window.Alpine.start) {
  console.log('[Spalla] Alpine already loaded, scheduling init...');
  document.addEventListener('DOMContentLoaded', () => {
    setTimeout(() => {
      console.log('[Spalla] Calling Alpine.start()...');
      window.Alpine.start();
    }, 100);
  });
}
