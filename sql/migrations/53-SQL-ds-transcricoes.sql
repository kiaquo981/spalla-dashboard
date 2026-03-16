-- =====================================================
-- DS-11: Tabela de tracking de transcrições
-- =====================================================

CREATE TABLE IF NOT EXISTS ds_transcricoes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  mentorado_id BIGINT REFERENCES "case".mentorados(id) ON DELETE CASCADE,
  arquivo TEXT NOT NULL,
  tipo TEXT DEFAULT 'call', -- 'call' | 'onboarding' | 'estrategia' | 'outro'
  duracao_estimada TEXT,
  tamanho_kb INT,
  status TEXT DEFAULT 'disponivel', -- 'disponivel' | 'em_uso' | 'processada'
  created_at TIMESTAMPTZ DEFAULT now(),

  UNIQUE(mentorado_id, arquivo)
);

CREATE INDEX IF NOT EXISTS idx_ds_transcricoes_mentorado ON ds_transcricoes(mentorado_id);
CREATE INDEX IF NOT EXISTS idx_ds_transcricoes_status ON ds_transcricoes(status);

ALTER TABLE ds_transcricoes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ds_transcricoes_all" ON ds_transcricoes FOR ALL USING (true) WITH CHECK (true);
