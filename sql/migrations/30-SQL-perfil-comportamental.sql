-- ============================================================
-- 30-SQL-perfil-comportamental.sql
-- Perfil Comportamental por Mentorado (Big Five, DISC, etc.)
-- ============================================================

CREATE TABLE perfil_comportamental (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  mentorado_id BIGINT NOT NULL,
  dimensoes JSONB DEFAULT '{}',
  comunicacao JSONB DEFAULT '{}',
  notas_texto TEXT,
  fonte TEXT DEFAULT 'manual',
  fonte_detalhes TEXT,
  created_by TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE UNIQUE INDEX idx_perfil_mentorado_unique ON perfil_comportamental(mentorado_id);

ALTER TABLE perfil_comportamental ENABLE ROW LEVEL SECURITY;

CREATE POLICY "perfil_comportamental_access" ON perfil_comportamental
  FOR ALL USING (auth.role() IN ('authenticated', 'anon'));

-- Trigger updated_at reusa fn_update_timestamp() existente
CREATE TRIGGER trg_perfil_updated BEFORE UPDATE ON perfil_comportamental
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
