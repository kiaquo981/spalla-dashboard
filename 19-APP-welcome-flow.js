'use strict';

function welcomeFlowStore() {
  return {
    step: 0,
    totalSteps: 6,
    loading: false,
    error: null,
    credentials: null,

    // Form data
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

    // Validation state
    touched: {},

    // Validation helpers
    isValidEmail(email) { return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email); },
    isValidPhone(phone) { return phone.replace(/\D/g, '').length >= 10; },
    isValidName(name) { return name.trim().length >= 3; },

    // Sanitize
    sanitize(str) {
      return str.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
                .replace(/<[^>]*>/g, '').trim();
    },

    // Format phone as Brazilian pattern
    formatPhone(value) {
      var digits = value.replace(/\D/g, '');
      if (digits.length > 11) digits = digits.slice(0, 11);
      if (digits.length <= 2) return digits;
      if (digits.length <= 7) return '(' + digits.slice(0, 2) + ') ' + digits.slice(2);
      if (digits.length <= 10) return '(' + digits.slice(0, 2) + ') ' + digits.slice(2, 6) + '-' + digits.slice(6);
      return '(' + digits.slice(0, 2) + ') ' + digits.slice(2, 7) + '-' + digits.slice(7);
    },

    // Step validation
    canAdvance() {
      if (this.step === 1) {
        return this.isValidName(this.data.nome) &&
               this.isValidEmail(this.data.email) &&
               this.isValidPhone(this.data.whatsapp);
      }
      if (this.step === 3) {
        return this.data.tom_de_voz && this.data.usa_emojis;
      }
      return true;
    },

    nextStep() { if (this.canAdvance()) this.step++; },
    prevStep() { this.step = Math.max(0, this.step - 1); },

    // Members
    addMembro() {
      if (this.data.membros_extras.length < 10) {
        this.data.membros_extras.push({
          id: Date.now().toString(),
          nome_completo: '', whatsapp: '', email: '', funcao: ''
        });
      }
    },
    removeMembro(id) {
      this.data.membros_extras = this.data.membros_extras.filter(function(m) { return m.id !== id; });
    },

    // Submit
    async submitWizard() {
      this.loading = true;
      this.error = null;
      this.step = 5;

      try {
        var nome = this.sanitize(this.data.nome);
        var whatsappDigits = this.data.whatsapp.replace(/\D/g, '');
        // Ensure country code 55 prefix
        var whatsappId = whatsappDigits.startsWith('55') ? whatsappDigits : '55' + whatsappDigits;
        var nameParts = nome.trim().split(/\s+/);
        var primeiroNome = nameParts[0] || nome;
        var ultimoNome = nameParts.length > 1 ? nameParts[nameParts.length - 1] : primeiroNome;
        // Default password: first name lowercase + last name lowercase + '123'
        var senhaDefault = (primeiroNome + ultimoNome).toLowerCase().replace(/[^a-z0-9]/g, '') + '123';

        // Team members for WhatsApp group
        var participantes = [
          whatsappId + '@s.whatsapp.net',  // mentorado
          whatsappId + '@s.whatsapp.net',  // mentorado (duplicate as in template)
          '5524992514909@s.whatsapp.net',  // Queila
          '5511934667188@s.whatsapp.net',  // Kaique
          '5527999473185@s.whatsapp.net',  // Hugo
          '5527992640273@s.whatsapp.net',  // Team
          '5527988918032@s.whatsapp.net',  // Team
        ];

        // Add extra members if any
        if (this.data.incluir_membros_extras && this.data.membros_extras.length) {
          this.data.membros_extras.forEach(function(m) {
            var mDigits = m.whatsapp.replace(/\D/g, '');
            var mId = mDigits.startsWith('55') ? mDigits : '55' + mDigits;
            participantes.push(mId + '@s.whatsapp.net');
          });
        }

        var payload = {
          nome: nome,
          email: this.sanitize(this.data.email),
          whatsapp: whatsappDigits,
          whatsappId: whatsappId,
          instagram: this.data.instagram || null,
          linkedin: this.data.linkedin || null,
          outra_rede: this.data.outra_rede || null,
          tom_de_voz: this.data.tom_de_voz,
          como_chama_audiencia: this.sanitize(this.data.como_chama_audiencia),
          usa_emojis: this.data.usa_emojis,
          expressoes: this.data.expressoes ? this.data.expressoes.split(',').map(function(e) { return e.trim(); }) : [],
          tipos_conteudo: this.data.tipos_conteudo,
          incluir_membros_extras: this.data.incluir_membros_extras,
          membros_extras: this.data.incluir_membros_extras
            ? this.data.membros_extras.map(function(m) {
                return {
                  nome_completo: m.nome_completo.replace(/<[^>]*>/g, '').trim(),
                  whatsapp: m.whatsapp.replace(/\D/g, ''),
                  email: m.email.replace(/<[^>]*>/g, '').trim(),
                  funcao: m.funcao.replace(/<[^>]*>/g, '').trim(),
                };
              })
            : [],
          primeiroNome: primeiroNome,
          ultimoNome: ultimoNome,
          senhaDefault: senhaDefault,
          participantes: participantes,
          nomeGrupo: 'CASE | ' + primeiroNome,
        };

        // 1. Send to webhook
        var webhookUrl = (typeof CONFIG !== 'undefined' && CONFIG.WEBHOOK_NOVO_MENTORADO)
          || 'https://webhook.manager01.feynmanproject.com/webhook/novo_mentorado';

        var controller = new AbortController();
        var timeoutId = setTimeout(function() { controller.abort(); }, 10000);

        var webhookRes = await fetch(webhookUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
          signal: controller.signal,
        });
        clearTimeout(timeoutId);

        if (!webhookRes.ok) throw new Error('Webhook error: ' + webhookRes.status);

        // 2. Create mentorado auth
        var apiBase = (typeof CONFIG !== 'undefined' && CONFIG.API_BASE) || '';
        var authRes = await fetch(apiBase + '/api/welcome-flow/register', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ nome: payload.nome, email: payload.email, whatsapp: payload.whatsapp }),
        });

        if (authRes.ok) {
          var authData = await authRes.json();
          this.credentials = authData.credentials || null;
        }

        this.step = 6;
      } catch (err) {
        console.error('[WelcomeFlow] Error:', err);
        this.error = err.message || 'Erro ao processar. Tente novamente.';
      } finally {
        this.loading = false;
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
      this.loading = false;
      this.touched = {};
      this.data = {
        nome: '', email: '', whatsapp: '', instagram: '', linkedin: '',
        outra_rede: '', tom_de_voz: '', como_chama_audiencia: '',
        usa_emojis: '', expressoes: '', tipos_conteudo: [],
        incluir_membros_extras: false, membros_extras: [],
      };
    },
  };
}
