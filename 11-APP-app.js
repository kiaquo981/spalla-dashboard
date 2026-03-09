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
const TEAM_MEMBERS = [
  { name: 'Kaique', email: 'kaique.azevedoo@outlook.com' },
  { name: 'Heitor', email: 'heitorms15@gmail.com' },
  { name: 'Hugo', email: 'hugo.nicchio@gmail.com' },
  { name: 'Queila', email: 'queilatrizotti@gmail.com' },
  { name: 'Mariza', email: 'mariza.rg22@gmail.com' },
  { name: 'Lara', email: 'santoslarafreitas@gmail.com' },
];

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
    console.log('[Spalla] Supabase initialized successfully');
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
function spalla() {
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

    // --- UI State ---
    ui: {
      page: localStorage.getItem('spalla_page') || CONFIG.DEFAULT_PAGE,
      sidebarOpen: true,
      mobileMenuOpen: false,
      search: '',
      filters: { fase: '', risco: '', cohort: '', status: '', financeiro: '' },
      sort: 'nome',
      sortDir: 'asc',
      loading: true,
      sheetsSyncing: false,
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
      // Plano de Ação
      paFilter: 'all',          // all | nao_iniciado | em_andamento | pausado | concluido
      paView: 'painel',         // painel | pipeline | list
      paModal: false,           // create plan modal
      paExpandedFases: {},      // { faseId: true } for accordion
      paLoading: false,         // loading state for PA detail
      paSearchQuery: '',        // busca por nome do mentorado
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
      scheduledCalls: [],
      pendencias: [],
      paPlanos: [],       // vw_pa_pipeline data
      paMenteePa: null,   // full PA for current mentee detail
      paAllFases: [],     // lightweight fases for sentinel calcs
      paAllAcoes: [],     // lightweight acoes for sentinel calcs
    },

    // --- Media Cache ---
    waMediaUrls: {},  // messageId → presigned URL

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
      recorrencia: 'nenhuma',
      dia_recorrencia: null,
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
      // WhatsApp pending messages
      const msgsPendentes = this.data.mentees.reduce((s, m) => s + (m.msgs_pendentes_resposta || 0), 0);
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
          email: member.email,
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
      return this.data.mentees.filter(m => m.fase_jornada === fase);
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
        list.sort((a, b) => {
          const prio = { urgente: 0, alta: 1, normal: 2, baixa: 3 };
          return (prio[a.prioridade] || 2) - (prio[b.prioridade] || 2);
        });
        result[s] = list.slice(0, 50); // Limit to 50 per column for performance
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
      return { pendente: '⏳', em_andamento: '🔄', concluida: '✅' }[status] || '📋';
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
      console.log('[Spalla] init() starting');
      try {
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
              console.log('[Spalla] Auth: session validated for', this.auth.currentUser.email);
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
                console.log('[Spalla] Auth: session refreshed for', this.auth.currentUser.email);
              } else {
                // Refresh failed — clear session
                this._clearAuthStorage();
                console.log('[Spalla] Auth: session expired, cleared');
              }
            } else {
              this._clearAuthStorage();
              console.log('[Spalla] Auth: invalid session, cleared');
            }
          } catch (e) {
            // Network error — trust local session as fallback
            this.auth.authenticated = true;
            this.auth.currentUser = JSON.parse(userStr);
            this.auth.accessToken = accessToken;
            this.auth.refreshToken = refreshToken;
            this.ui.taskAssignee = '__mine__';
            console.warn('[Spalla] Auth: offline, using cached session');
          }
        } else {
          console.log('[Spalla] Auth: no saved session');
        }

        // Initialize Supabase (if still needed for other features)
        sb = await initSupabase();
        console.log('[Spalla] Supabase initialized:', !!sb);

        await this.loadTasks();
        console.log('[Spalla] Tasks loaded:', this.data.tasks.length);

        if (this.auth.authenticated) {
          await this.loadReminders(); // Load from Supabase
          await this.loadDashboard();
          console.log('[Spalla] Dashboard loaded, mentees:', this.data.mentees.length);
          // Pre-fetch WhatsApp profile pics in background
          this._loadWaProfilePics();
          // Fetch schedule-related data from backend API
          this.fetchUpcomingCalls();
          this.fetchMenteesWithEmail();
          this.checkIntegrations();
          // Fetch Instagram profiles from Apify (background, non-blocking)
          this.updateInstagramProfiles();
        }
      } catch (e) {
        console.error('[Spalla] INIT ERROR:', e);
        // Ensure UI is visible even if init fails
        this.ui.loading = false;
        if (!this.data.mentees.length) this.loadDemoData();
      }
      console.log('[Spalla] init() complete');
    },

    async _loadWaProfilePics() {
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/evolution/chat/findChats/${EVOLUTION_CONFIG.INSTANCE}`, {
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
        console.log(`[Spalla] Loaded ${Object.keys(pics).length} WhatsApp profile pics`);
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
        console.log('[Spalla] Login successful:', data.user.email);
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
        console.log('[Spalla] Registration successful:', data.user.email);
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

        // Clear tokens and cached data from localStorage
        this._clearAuthStorage();
        localStorage.removeItem(CONFIG.TASKS_STORAGE_KEY);

        console.log('[Spalla] Logout successful - session cleared');

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
        const client = await initSupabase();
        if (!client) {
          this.auth.error = 'Erro de conexão. Tente novamente.';
          return;
        }
        const { error } = await client.auth.resetPasswordForEmail(this.auth.email, {
          redirectTo: window.location.origin
        });
        if (error) {
          this.auth.error = error.message || 'Erro ao enviar email de recuperação';
          return;
        }
        this.auth.success = 'Email de recuperação enviado! Verifique sua caixa de entrada (e spam).';
        console.log('[Spalla] Password reset email sent to:', this.auth.email);
      } catch (e) {
        this.auth.error = 'Erro ao enviar email: ' + e.message;
        console.error('[Spalla] Reset password error:', e);
      }
    },

    startDataRefresh() {
      if (this._refreshInterval) clearInterval(this._refreshInterval);
      this._refreshInterval = setInterval(() => {
        console.log('[Spalla] Auto-refresh: loading dashboard data');
        this.loadDashboard();
      }, this._refreshIntervalMs);
      console.log('[Spalla] Data auto-refresh started (every', this._refreshIntervalMs + 'ms)');
    },

    stopDataRefresh() {
      if (this._refreshInterval) {
        clearInterval(this._refreshInterval);
        this._refreshInterval = null;
        console.log('[Spalla] Data auto-refresh stopped');
      }
    },

    startWhatsAppPolling() {
      if (this._whatsappPollInterval) clearInterval(this._whatsappPollInterval);
      if (!this.ui.whatsappSelectedChat) return;
      this._whatsappPollInterval = setInterval(async () => {
        console.log('[Spalla] WhatsApp poll: checking for new messages');
        try {
          const res = await fetch(`${CONFIG.API_BASE}/api/evolution/chat/findMessages/${EVOLUTION_CONFIG.INSTANCE}`, {
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
            // Update messages if there are new ones
            if (newMsgs.length !== this.data.whatsappMessages.length) {
              this.data.whatsappMessages = newMsgs;
              // Eagerly load media URLs for all messages
              this.eagerlyLoadWaMediaUrls(this.data.whatsappMessages);
              // Auto-scroll to latest
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
      console.log('[Spalla] WhatsApp polling started (every', this._whatsappPollIntervalMs + 'ms)');
    },

    stopWhatsAppPolling() {
      if (this._whatsappPollInterval) {
        clearInterval(this._whatsappPollInterval);
        this._whatsappPollInterval = null;
        console.log('[Spalla] WhatsApp polling stopped');
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
          this.showToast(`Erro no sync: ${data.error}`, 'error');
        } else {
          this.showToast(`Sheets sync: ${data.updated} atualizacoes em ${data.elapsed_seconds}s`, 'success');
          // Reload dashboard to show updated data
          await this.loadDashboard();
        }
      } catch (e) {
        this.showToast(`Erro no sync: ${e.message}`, 'error');
      } finally {
        this.ui.sheetsSyncing = false;
      }
    },

    async loadDashboard() {
      this.ui.loading = true;
      sb = await initSupabase();
      if (sb) {
        try {
          const [mentees, cohort, calls, pendencias, paPipeline] = await Promise.all([
            sb.from('vw_god_overview').select('*'),
            sb.from('vw_god_cohort').select('*'),
            // Query directly from calls_mentoria table to get latest data
            sb.from('calls_mentoria')
              .select('*,mentorados(id,nome)')
              .order('data_call', { ascending: false })
              .limit(500),
            sb.from('vw_god_pendencias').select('*').order('created_at', { ascending: true }),
            sb.from('vw_pa_pipeline').select('*'),
          ]);
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

          if (mentees.data?.length) {
            this.data.mentees = mentees.data;
          } else {
            console.warn('[Spalla] Supabase mentees empty, using demo');
            this.loadDemoData();
          }
          if (cohort.data?.length) this.data.cohort = cohort.data;
          if (pendencias.data) this.data.pendencias = pendencias.data;
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
              created_at: c.created_at,
            }));
            console.log('[Spalla] Calls loaded from Supabase:', this._supabaseCalls.length);
            // Log first 5 calls for debugging
            console.log('[Spalla] Sample calls:', this._supabaseCalls.slice(0, 5).map(c => ({ nome: c.mentorado_nome, data: c.data_call })));
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
            const detail = typeof detailRes.data === 'string' ? JSON.parse(detailRes.data) : detailRes.data;
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
            const res = await fetch(`${CONFIG.API_BASE}/api/evolution/chat/findChats/${EVOLUTION_CONFIG.INSTANCE}`, {
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
        const res = await fetch(`${CONFIG.API_BASE}/api/evolution/chat/findMessages/${EVOLUTION_CONFIG.INSTANCE}`, {
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

    navigate(page) {
      // Stop WhatsApp polling when leaving WhatsApp page
      if (this.ui.page === 'whatsapp' && page !== 'whatsapp') {
        this.stopWhatsAppPolling();
      }
      this.ui.page = page;
      this.ui.mobileMenuOpen = false;
      localStorage.setItem('spalla_page', page);
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
      const user = this.auth.currentUser?.user_metadata?.full_name || this.auth.currentUser?.email || '';
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
      if (next === 'concluido') acao.data_conclusao = new Date().toISOString().split('T')[0];
      const { error } = await sb.from('pa_acoes').update({
        status: next,
        data_conclusao: next === 'concluido' ? new Date().toISOString().split('T')[0] : null,
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
        await sb.from('pa_fases').update({ status: newStatus }).eq('id', faseId);
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
        await sb.from('pa_planos').update({ status_geral: newStatus }).eq('id', plano.id);
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
      const map = { revisao_dossie: '📋', fase: '🧭', passo_executivo: '⚡' };
      return map[tipo] || '📌';
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
      const today = new Date().toISOString().split('T')[0];
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
      const today = new Date().toISOString().split('T')[0];
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
      const today = new Date().toISOString().split('T')[0];
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
      return acao.data_prevista < new Date().toISOString().split('T')[0];
    },

    // Detail summary stats from paMenteePa (loaded detail)
    paDetailStats() {
      const pa = this.data.paMenteePa;
      if (!pa || !pa.fases) return { total: 0, concluidas: 0, bloqueadas: 0, vencidas: 0, subTotal: 0, subConcluidas: 0 };
      const acoes = pa.fases.flatMap(f => f.acoes || []);
      const subs = acoes.flatMap(a => a.sub_acoes || []);
      const today = new Date().toISOString().split('T')[0];
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
          // Load only god_tasks (board tasks) — tarefas_equipe are shown as pending WA messages
          const { data, error } = await sb.from('vw_god_tasks_full').select('*').order('created_at', { ascending: false }).limit(200);
          if (!error && data) {
            this.data.tasks = data.map(t => ({
              ...t, prazo: t.data_fim, _source: 'god_tasks',
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
        };
        this.ui.taskEditId = task.id;
      } else {
        this.taskForm = { titulo: '', descricao: '', responsavel: '', acompanhante: '', mentorado_nome: '', prioridade: 'normal', prazo: '', data_inicio: '', data_fim: '', doc_link: '', subtasks: [], checklist: [], comments: [], attachments: [], tags: [], parent_task_id: null, space_id: 'space_jornada', list_id: '', recorrencia: 'nenhuma', dia_recorrencia: null, newSubtask: '', newCheckItem: '', newComment: '', newTag: '' };
        this.ui.taskEditId = null;
      }
      this.ui.taskModal = true;
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
      if (formData.data_fim) formData.prazo = formData.data_fim;

      if (this.ui.taskEditId) {
        const idx = this.data.tasks.findIndex(t => t.id === this.ui.taskEditId);
        if (idx !== -1) {
          const backup = { ...this.data.tasks[idx] };
          const updated = { ...backup, ...formData, updated_at: new Date().toISOString() };
          this.data.tasks[idx] = updated;
          this._cacheTasksLocal();
          const r = await this._sbUpsertTask(updated);
          if (!r.ok) { this.data.tasks[idx] = backup; this._cacheTasksLocal(); this.toast('Erro ao salvar tarefa', 'error'); return; }
          await this._sbSyncSubtasks(updated.id, updated.subtasks);
          await this._sbSyncChecklist(updated.id, updated.checklist);
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
        const r = await this._sbUpsertTask(newTask, true);
        if (!r.ok) { this.toast('Erro ao criar tarefa', 'error'); return; }
        this.data.tasks.push(newTask);
        if (newTask.subtasks?.length) await this._sbSyncSubtasks(newId, newTask.subtasks);
        if (newTask.checklist?.length) await this._sbSyncChecklist(newId, newTask.checklist);
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
        const authorName = this.auth.currentUser?.user_metadata?.full_name
          || this.auth.currentUser?.email
          || 'Equipe';
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
        if (sb) { const { error } = await sb.from('god_tasks').update({ tags: t.tags }).eq('id', taskId); if (error) this.toast('Erro ao salvar tag', 'error'); }
      }
    },

    async removeTag(taskId, tag) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t && t.tags) {
        t.tags = t.tags.filter(tg => tg !== tag);
        this._cacheTasksLocal();
        if (sb) { const { error } = await sb.from('god_tasks').update({ tags: t.tags }).eq('id', taskId); if (error) this.toast('Erro ao remover tag', 'error'); }
      }
    },

    async setParentTask(taskId, parentId) {
      const t = this.data.tasks.find(x => x.id === taskId);
      if (t) {
        t.parent_task_id = parentId || null;
        this._cacheTasksLocal();
        if (sb) { const { error } = await sb.from('god_tasks').update({ parent_task_id: parentId || null }).eq('id', taskId); if (error) this.toast('Erro ao vincular tarefa', 'error'); }
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
          console.log('[Spalla] Reminders loaded:', this.data.reminders.length);
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
        const reminder = {
          id: crypto.randomUUID ? crypto.randomUUID() : 'rem_' + Date.now(),
          titulo: this.reminderForm.texto,
          data_lembrete: this.reminderForm.data || null,
          prioridade: this.reminderForm.prioridade,
          mentorado_nome: this.reminderForm.mentorado_nome,
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

    // ===================== WHATSAPP (Evolution API) =====================

    async fetchWhatsAppChats() {
      this.ui.whatsappLoading = true;
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/evolution/chat/findChats/${EVOLUTION_CONFIG.INSTANCE}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({}),
        });
        if (res.ok) {
          const chats = await res.json();
          // Show all chats sorted by most recent
          this.data.whatsappChats = (chats || [])
            .filter(c => c.id)
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
      this.ui.whatsappSelectedChat = chat;
      this.ui.whatsappLoading = true;
      this.stopWhatsAppPolling(); // Stop previous polling
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/evolution/chat/findMessages/${EVOLUTION_CONFIG.INSTANCE}`, {
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

    async sendWhatsAppMessage() {
      if (!this.ui.whatsappMessage.trim() || !this.ui.whatsappSelectedChat) return;
      const msg = this.ui.whatsappMessage.trim();
      this.ui.whatsappMessage = '';
      try {
        const res = await fetch(`${CONFIG.API_BASE}/api/evolution/message/sendText/${EVOLUTION_CONFIG.INSTANCE}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ number: this.ui.whatsappSelectedChat.remoteJid || this.ui.whatsappSelectedChat.id, text: msg }),
        });
        if (res.ok) {
          this.data.whatsappMessages.push({
            key: { fromMe: true },
            message: { conversation: msg },
            messageTimestamp: Math.floor(Date.now() / 1000),
            pushName: 'Equipe CASE',
          });
          this.toast('Mensagem enviada', 'success');
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
          console.log(`[Spalla] Eagerly loaded mediaUrl: ${msgId}`);
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
        console.log(`[Spalla] Using Evolution mediaUrl: ${msgId}`);
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
      const instanceId = EVOLUTION_CONFIG?.INSTANCE_UUID || EVOLUTION_CONFIG?.INSTANCE || 'default';
      const chatId = this.ui.whatsappSelectedChat?.remoteJid || this.ui.whatsappSelectedChat?.id || 'unknown';

      // Build filename
      const timestamp = msg.messageTimestamp ? Math.floor(msg.messageTimestamp * 1000) : Date.now();
      const extension = mediaType === 'audioMessage' ? 'oga' : mediaType === 'imageMessage' ? 'jpg' : 'mp4';
      const filename = `${timestamp}_${msgId}.${extension}`;

      // Build S3 key
      const s3Key = `evolution-api/${instanceId}/${chatId}/${mediaType}/${filename}`;
      const streamUrl = `${CONFIG.API_BASE}/api/media/stream?key=${encodeURIComponent(s3Key)}`;

      console.log(`[Spalla] Stream fallback: ${s3Key}`);

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

      // First: try embedded data URLs (PHOTO_DATA_URLS)
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

      // Fallback: try to generate from handle/name
      if (typeof PHOTO_DATA_URLS !== 'undefined' && PHOTO_DATA_URLS[clean]) {
        return PHOTO_DATA_URLS[clean];
      }
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

    get allCallsGlobal() {
      // If real Supabase calls loaded, use them
      if (this._supabaseCalls?.length) {
        return this._supabaseCalls.map(c => ({
          mentorado: c.mentorado_nome, mentorado_id: c.mentorado_id, data: (c.data_call || '').substring(0, 10),
          tipo: c.tipo_call || 'acompanhamento', duracao: c.duracao_minutos || 0,
          horario: c.horario_call || null, status_call: c.status_call || null,
          topic: c.zoom_topic || '', resumo: c.resumo || null,
          gravacao: c.link_gravacao || null, transcricao: c.link_transcricao || null,
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
          console.log('[Schedule] Supabase not available, using demo data');
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
        console.log('[Schedule] Could not fetch upcoming calls:', e);
      }
    },

    async fetchMenteesWithEmail() {
      // Mentees already loaded from demo data in init()
      // If connecting to backend API in future, uncomment below:
      // try {
      //   const resp = await fetch(CONFIG.API_BASE + '/api/mentees');
      //   const mentees = await resp.json();
      //   if (Array.isArray(mentees)) {
      //     this._menteesWithEmail = mentees;
      //   }
      // } catch (e) {
      //   console.log('[Mentees] Could not fetch:', e);
      // }
    },

    async checkIntegrations() {
      // Health checks disabled — using Supabase directly
      // If connecting to backend API in future, uncomment below:
      // try {
      //   const resp = await fetch(CONFIG.API_BASE + '/api/health');
      //   const health = await resp.json();
      //   this._integrations = health;
      // } catch (e) {
      //   console.log('[Health] Could not check:', e);
      // }
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
          console.log('[Instagram] No mentees with Instagram handles');
          return;
        }

        console.log(`[Instagram] Updating ${handles.length} profiles from Apify...`);

        // Call the Apify integration function from data.js
        if (typeof fetchInstagramProfilesFromApify === 'function') {
          const profiles = await fetchInstagramProfilesFromApify(handles);

          // Merge results into INSTAGRAM_PROFILES (updates follower counts)
          Object.assign(INSTAGRAM_PROFILES, profiles);

          // Count successful updates
          const updated = Object.keys(profiles).length;
          console.log(`[Instagram] ✓ Updated ${updated} profiles`);

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
      // Handle YYYY-MM-DD (force local timezone, not UTC)
      if (/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) {
        return new Date(dateStr + 'T00:00:00');
      }
      const d = new Date(dateStr);
      return isNaN(d.getTime()) ? null : d;
    },

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
  };
}

// ===== DEMO DATA moved to data.js =====
