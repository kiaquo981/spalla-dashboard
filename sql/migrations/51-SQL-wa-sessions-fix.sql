-- ============================================
-- Fix: wa_sessions schema corrigido
-- O sistema usa auth proprio (Railway) com user_id INTEGER
-- nao Supabase Auth. Remove FK UUID e RLS baseado em auth.uid()
-- ============================================

-- Drop tabela anterior (criada com schema errado)
DROP TABLE IF EXISTS wa_sessions CASCADE;

-- Recriar com user_id INTEGER (compativel com sistema Railway)
CREATE TABLE wa_sessions (
  id            SERIAL PRIMARY KEY,
  user_id       INTEGER NOT NULL,
  instance_name TEXT NOT NULL UNIQUE,
  status        TEXT NOT NULL DEFAULT 'disconnected'
                  CHECK (status IN ('disconnected', 'qr_pending', 'connecting', 'connected', 'banned')),
  phone_number  TEXT,
  qr_code_base64 TEXT,
  connected_at  TIMESTAMPTZ,
  last_health_check TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- 1 sessao ativa por usuario
CREATE UNIQUE INDEX idx_wa_sessions_active_user
  ON wa_sessions (user_id)
  WHERE status NOT IN ('disconnected', 'banned');

-- Lookup por instance_name (para callbacks/webhooks)
CREATE INDEX idx_wa_sessions_instance ON wa_sessions (instance_name);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION wa_sessions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_wa_sessions_updated_at
  BEFORE UPDATE ON wa_sessions
  FOR EACH ROW
  EXECUTE FUNCTION wa_sessions_updated_at();

-- RLS: desabilitado (sistema usa anon key com filtro na query, nao Supabase Auth)
-- A seguranca e feita pelo filtro user_id na query do frontend
ALTER TABLE wa_sessions DISABLE ROW LEVEL SECURITY;

-- Permissoes para anon key (leitura e escrita filtradas por user_id na query)
GRANT SELECT, INSERT, UPDATE, DELETE ON wa_sessions TO anon;
GRANT USAGE, SELECT ON SEQUENCE wa_sessions_id_seq TO anon;
