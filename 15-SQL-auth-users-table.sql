-- =============================================================================
-- SPALLA DASHBOARD — Tabela auth_users (persistente no Supabase)
-- Substitui o SQLite local que era apagado a cada deploy no Railway
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.auth_users (
  id BIGSERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Permitir acesso via service_role (usado pelo server.py)
ALTER TABLE public.auth_users ENABLE ROW LEVEL SECURITY;

-- Policy: service_role tem acesso total
CREATE POLICY "Service role full access" ON public.auth_users
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Verificacao:
-- SELECT id, email, full_name, created_at FROM public.auth_users;
