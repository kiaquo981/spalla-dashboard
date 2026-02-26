// Spalla Authentication Functions
// Integração com Supabase Auth (Email + Google)

const AuthConfig = {
  API_BASE: window.API_BASE_URL || 'http://localhost:8888',
  STORAGE_KEY: 'spalla_auth_session',
  GOOGLE_CLIENT_ID: 'YOUR_GOOGLE_CLIENT_ID_HERE', // Replace with actual
  GOOGLE_REDIRECT_URI: window.location.origin + '/auth/google/callback',
};

// ===== AUTH LOGIN/SIGNUP METHODS =====

async function authLogin() {
  try {
    if (!this.auth.email || !this.auth.password) {
      this.auth.error = 'Email e senha obrigatórios';
      return;
    }

    this.auth.loading = true;
    this.auth.error = '';

    const response = await fetch(`${AuthConfig.API_BASE}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: this.auth.email.toLowerCase(),
        password: this.auth.password
      })
    });

    const data = await response.json();

    if (!response.ok) {
      this.auth.error = data.error || 'Falha na autenticação';
      this.auth.loading = false;
      return;
    }

    // Success: Save session
    this.auth.token = data.token;
    this.auth.refreshToken = data.refreshToken;
    this.auth.user = data.user;
    this.auth.authenticated = true;
    this.auth.password = '';

    // Save to localStorage
    localStorage.setItem(AuthConfig.STORAGE_KEY, JSON.stringify({
      token: this.auth.token,
      refreshToken: this.auth.refreshToken,
      user: this.auth.user,
      expiresAt: Date.now() + (data.expiresIn * 1000)
    }));

    this.auth.loading = false;
    this.loadDashboard();
    this.toast('Login bem-sucedido!', 'success');
  } catch (e) {
    console.error('[Auth] Login error:', e);
    this.auth.error = 'Erro ao conectar. Tente novamente.';
    this.auth.loading = false;
  }
}

async function authSignup() {
  try {
    if (!this.authSignup.email || !this.authSignup.password || !this.authSignup.fullName) {
      this.auth.error = 'Todos os campos são obrigatórios';
      return;
    }

    if (this.authSignup.password.length < 8) {
      this.auth.error = 'Senha deve ter no mínimo 8 caracteres';
      return;
    }

    if (this.authSignup.password !== this.authSignup.confirmPassword) {
      this.auth.error = 'Senhas não conferem';
      return;
    }

    this.auth.loading = true;
    this.auth.error = '';

    const response = await fetch(`${AuthConfig.API_BASE}/api/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: this.authSignup.email.toLowerCase(),
        password: this.authSignup.password,
        full_name: this.authSignup.fullName
      })
    });

    const data = await response.json();

    if (!response.ok) {
      this.auth.error = data.error || 'Erro ao criar conta';
      this.auth.loading = false;
      return;
    }

    // Success
    this.auth.success = 'Conta criada! Verifique seu email e faça login.';
    this.authSignup = { email: '', password: '', confirmPassword: '', fullName: '' };
    
    setTimeout(() => {
      this.authMode = 'login';
      this.auth.success = '';
    }, 2000);

    this.auth.loading = false;
  } catch (e) {
    console.error('[Auth] Signup error:', e);
    this.auth.error = 'Erro ao criar conta. Tente novamente.';
    this.auth.loading = false;
  }
}

function authLoginGoogle() {
  // Initiate Google OAuth flow
  const params = new URLSearchParams({
    client_id: AuthConfig.GOOGLE_CLIENT_ID,
    redirect_uri: AuthConfig.GOOGLE_REDIRECT_URI,
    response_type: 'code',
    scope: 'openid email profile',
    access_type: 'offline',
    prompt: 'consent'
  });

  window.location.href = `https://accounts.google.com/o/oauth2/v2/auth?${params}`;
}

async function authRefreshToken() {
  try {
    if (!this.auth.refreshToken) return false;

    const response = await fetch(`${AuthConfig.API_BASE}/api/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken: this.auth.refreshToken })
    });

    if (!response.ok) return false;

    const data = await response.json();
    this.auth.token = data.token;
    
    // Update localStorage
    const session = JSON.parse(localStorage.getItem(AuthConfig.STORAGE_KEY) || '{}');
    session.token = data.token;
    localStorage.setItem(AuthConfig.STORAGE_KEY, JSON.stringify(session));

    return true;
  } catch (e) {
    console.error('[Auth] Token refresh failed:', e);
    return false;
  }
}

function authLogout() {
  this.auth.authenticated = false;
  this.auth.token = null;
  this.auth.refreshToken = null;
  this.auth.user = null;
  this.auth.email = '';
  this.auth.password = '';
  localStorage.removeItem(AuthConfig.STORAGE_KEY);
  this.authMode = 'login';
  this.toast('Desconectado', 'info');
}

function authRestoreSession() {
  const stored = localStorage.getItem(AuthConfig.STORAGE_KEY);
  if (!stored) return false;

  try {
    const session = JSON.parse(stored);
    
    // Check if token is expired
    if (session.expiresAt && Date.now() > session.expiresAt) {
      console.log('[Auth] Token expired, trying refresh...');
      this.authRefreshToken();
      return false;
    }

    this.auth.token = session.token;
    this.auth.refreshToken = session.refreshToken;
    this.auth.user = session.user;
    this.auth.authenticated = true;
    return true;
  } catch (e) {
    console.error('[Auth] Failed to restore session:', e);
    return false;
  }
}

function getAuthHeaders() {
  const headers = { 'Content-Type': 'application/json' };
  if (this.auth.token) {
    headers['Authorization'] = `Bearer ${this.auth.token}`;
  }
  return headers;
}
