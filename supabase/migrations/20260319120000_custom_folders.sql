-- =====================================================
-- CUSTOM FOLDERS — User-created folders for file organization
-- Date: 2026-03-19
-- =====================================================

-- 1. sp_pastas — custom folders
CREATE TABLE IF NOT EXISTS sp_pastas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome TEXT NOT NULL,
  descricao TEXT,
  cor TEXT DEFAULT '#6b7280',          -- hex color for folder icon
  icone TEXT DEFAULT 'folder',          -- icon name
  mentorado_id BIGINT REFERENCES "case".mentorados(id) ON DELETE SET NULL,  -- optional: folder scoped to mentorado
  parent_id UUID REFERENCES sp_pastas(id) ON DELETE CASCADE,         -- nested folders
  sort_order INT DEFAULT 0,
  created_by TEXT DEFAULT 'dashboard',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_sp_pastas_mentorado ON sp_pastas(mentorado_id);
CREATE INDEX IF NOT EXISTS idx_sp_pastas_parent ON sp_pastas(parent_id);

ALTER TABLE sp_pastas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sp_pastas_all" ON sp_pastas FOR ALL USING (auth.role() IN ('authenticated', 'service_role')) WITH CHECK (auth.role() IN ('authenticated', 'service_role'));

-- 2. Add pasta_id to sp_arquivos (file can belong to a folder)
ALTER TABLE sp_arquivos
  ADD COLUMN IF NOT EXISTS pasta_id UUID REFERENCES sp_pastas(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_sp_arquivos_pasta ON sp_arquivos(pasta_id) WHERE deleted_at IS NULL;

-- 3. Trigger for updated_at
DROP TRIGGER IF EXISTS sp_pastas_updated ON sp_pastas;
CREATE TRIGGER sp_pastas_updated BEFORE UPDATE ON sp_pastas
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

-- 4. View: folder with file counts
CREATE OR REPLACE VIEW vw_pastas_overview AS
SELECT
  p.id,
  p.nome,
  p.descricao,
  p.cor,
  p.icone,
  p.mentorado_id,
  m.nome AS mentorado_nome,
  p.parent_id,
  p.sort_order,
  p.created_at,
  COUNT(a.id) FILTER (WHERE a.deleted_at IS NULL) AS total_arquivos,
  ROUND(COALESCE(SUM(a.tamanho_bytes) FILTER (WHERE a.deleted_at IS NULL), 0) / 1048576.0, 2) AS total_mb
FROM sp_pastas p
LEFT JOIN "case".mentorados m ON m.id = p.mentorado_id
LEFT JOIN sp_arquivos a ON a.pasta_id = p.id
GROUP BY p.id, m.nome
ORDER BY p.sort_order, p.nome;
