// Supabase Authentication — Direct Frontend Integration
// No backend needed — works 100% in Vercel

// Load from environment variables (set in .env or Vercel deployment)
const SUPABASE_URL = process.env.REACT_APP_SUPABASE_URL || process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.REACT_APP_SUPABASE_ANON_KEY || process.env.SUPABASE_ANON_KEY;

if (!SUPABASE_URL) {
  throw new Error('SUPABASE_URL environment variable is required');
}
if (!SUPABASE_ANON_KEY) {
  throw new Error('SUPABASE_ANON_KEY environment variable is required');
}

// Supabase Auth Client
class SupabaseAuthClient {
  constructor(url, key) {
    this.url = url;
    this.key = key;
  }

  async login(email, password) {
    try {
      const response = await fetch(`${this.url}/auth/v1/token?grant_type=password`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'apikey': this.key,
        },
        body: JSON.stringify({
          email: email.toLowerCase(),
          password: password,
        }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error_description || 'Login failed');
      }

      const data = await response.json();
      return {
        success: true,
        token: data.access_token,
        refreshToken: data.refresh_token,
        user: data.user,
        expiresIn: data.expires_in,
      };
    } catch (error) {
      console.error('[Supabase Auth] Login error:', error);
      return {
        success: false,
        error: error.message || 'Authentication failed',
      };
    }
  }

  async signup(email, password, fullName) {
    try {
      const response = await fetch(`${this.url}/auth/v1/signup`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'apikey': this.key,
        },
        body: JSON.stringify({
          email: email.toLowerCase(),
          password: password,
          user_metadata: {
            full_name: fullName,
          },
        }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || 'Signup failed');
      }

      const data = await response.json();
      return {
        success: true,
        user: data.user,
      };
    } catch (error) {
      console.error('[Supabase Auth] Signup error:', error);
      return {
        success: false,
        error: error.message || 'Signup failed',
      };
    }
  }

  async refreshToken(refreshToken) {
    try {
      const response = await fetch(`${this.url}/auth/v1/token?grant_type=refresh_token`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'apikey': this.key,
        },
        body: JSON.stringify({
          refresh_token: refreshToken,
        }),
      });

      if (!response.ok) {
        throw new Error('Token refresh failed');
      }

      const data = await response.json();
      return {
        success: true,
        token: data.access_token,
        expiresIn: data.expires_in,
      };
    } catch (error) {
      console.error('[Supabase Auth] Token refresh error:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }
}

// Initialize client
const supabaseAuth = new SupabaseAuthClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Export for use in app
if (typeof module !== 'undefined' && module.exports) {
  module.exports = supabaseAuth;
}
