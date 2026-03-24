// Welcome Flow — Alpine store for mentee onboarding wizard
function welcomeFlowStore() {
  return {
    step: 0,
    error: null,
    credentials: null,
    touched: {},

    data: {
      nome: '',
      email: '',
      whatsapp: '',
      instagram: '',
      linkedin: '',
      outra_rede: '',
      tom_de_voz: '',
      como_chama_audiencia: '',
      usa_emojis: '',
      expressoes: '',
      tipos_conteudo: [],
      incluir_membros_extras: false,
      membros_extras: [],
    },

    isValidName(v) { return v && v.trim().length >= 3; },
    isValidEmail(v) { return v && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v); },
    isValidPhone(v) { return v && v.replace(/\D/g, '').length >= 10; },

    formatPhone(v) {
      const d = v.replace(/\D/g, '').slice(0, 11);
      if (d.length <= 2) return d;
      if (d.length <= 7) return '(' + d.slice(0,2) + ') ' + d.slice(2);
      if (d.length <= 10) return '(' + d.slice(0,2) + ') ' + d.slice(2,6) + '-' + d.slice(6);
      return '(' + d.slice(0,2) + ') ' + d.slice(2,7) + '-' + d.slice(7);
    },

    canAdvance() {
      if (this.step === 1) {
        return this.isValidName(this.data.nome) && this.isValidEmail(this.data.email) && this.isValidPhone(this.data.whatsapp);
      }
      if (this.step === 3) {
        return !!this.data.tom_de_voz && !!this.data.usa_emojis;
      }
      return true;
    },

    nextStep() {
      if (!this.canAdvance()) return;
      this.step++;
    },

    prevStep() {
      if (this.step > 0) this.step--;
    },

    addMembro() {
      this.data.membros_extras.push({
        id: Date.now(),
        nome_completo: '',
        whatsapp: '',
        email: '',
        funcao: '',
      });
    },

    removeMembro(id) {
      this.data.membros_extras = this.data.membros_extras.filter(m => m.id !== id);
    },

    async submitWizard() {
      this.step = 5;
      this.error = null;
      try {
        const payload = { ...this.data };
        if (payload.expressoes) {
          payload.expressoes = payload.expressoes.split(',').map(s => s.trim()).filter(Boolean);
        }
        const res = await fetch('/api/welcome-flow', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        });
        const json = await res.json();
        if (!res.ok) throw new Error(json.error || 'Erro ao processar cadastro');
        this.credentials = json.credentials || null;
        this.step = 6;
      } catch (e) {
        this.error = e.message || 'Erro inesperado. Tente novamente.';
      }
    },

    retrySubmit() {
      this.error = null;
      this.submitWizard();
    },

    resetWizard() {
      this.step = 0;
      this.error = null;
      this.credentials = null;
      this.touched = {};
      this.data = {
        nome: '', email: '', whatsapp: '', instagram: '', linkedin: '', outra_rede: '',
        tom_de_voz: '', como_chama_audiencia: '', usa_emojis: '', expressoes: '',
        tipos_conteudo: [], incluir_membros_extras: false, membros_extras: [],
      };
    },
  };
}
