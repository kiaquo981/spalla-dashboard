// Supabase Authentication — Direct Frontend Integration
// No backend needed — works 100% in Vercel

const SUPABASE_URL = 'https://knusqfbvhsqworzyhvip.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtudXNxZmJ2aHNxd29yenlodmlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4NTg3MjcsImV4cCI6MjA3MDQzNDcyN30.f-m7TlmCoccBpUxLZhA4P5kr2lWBGtRIv6inzInAKCo';

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
