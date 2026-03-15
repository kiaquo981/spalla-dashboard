-- ============================================
-- Fix: god_reminders.user_id UUID → TEXT
-- O sistema usa Railway auth com user_id INTEGER (1, 2, 3...)
-- Remove FK para auth.users (Supabase Auth) e RLS policy
-- ============================================

-- 1. Drop RLS policy que depende da coluna user_id
DROP POLICY IF EXISTS user_own_reminders ON god_reminders;

-- 2. Desabilitar RLS (sistema usa filtro na query, nao Supabase Auth)
ALTER TABLE god_reminders DISABLE ROW LEVEL SECURITY;

-- 3. Drop FK para auth.users (incompativel com Railway auth)
ALTER TABLE god_reminders DROP CONSTRAINT IF EXISTS god_reminders_user_id_fkey;

-- 4. Alterar tipo da coluna
ALTER TABLE god_reminders
  ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT;

-- 5. Recriar indice
DROP INDEX IF EXISTS idx_god_reminders_user;
CREATE INDEX idx_god_reminders_user ON god_reminders (user_id);

-- 6. Garantir permissoes para anon key
GRANT SELECT, INSERT, UPDATE, DELETE ON god_reminders TO anon;
