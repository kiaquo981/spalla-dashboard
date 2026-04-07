-- ============================================================
-- LF-FASE3: Descarrego como entidade
-- Stories: LF-3.1 + LF-3.2
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- TABELA: descarregos
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS descarregos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Identidade
  mentorado_id BIGINT,
  consultor_id TEXT,

  -- Input bruto
  tipo_bruto TEXT NOT NULL CHECK (tipo_bruto IN (
    'texto','audio','video','imagem','arquivo','link','gravacao'
  )),
  conteudo_bruto TEXT,
  arquivo_url TEXT,
  arquivo_size_bytes BIGINT,
  arquivo_mime_type TEXT,
  duracao_ms INT,

  -- Transcrição
  transcricao TEXT,
  transcrito_em TIMESTAMPTZ,
  transcrito_por TEXT,
  transcricao_confidence NUMERIC(3,2),

  -- Classificação
  classificacao_principal TEXT CHECK (classificacao_principal IN (
    'task','contexto','feedback','reembolso','bloqueio','duvida','celebracao','outro'
  )),
  classificacao_sub TEXT,
  classificacao_confidence NUMERIC(3,2),
  classificacao_payload JSONB DEFAULT '{}'::jsonb,
  classificado_em TIMESTAMPTZ,
  classificado_por TEXT,

  -- Ação tomada
  acao_tomada TEXT CHECK (acao_tomada IN (
    'task_criada','salvo_como_contexto','escalado_kaique','rejeitado_humano','sem_acao'
  )),
  task_id UUID,
  context_id UUID,
  acao_tomada_em TIMESTAMPTZ,
  acao_tomada_por TEXT,

  -- FSM (alinhado com DescarregoStateMachine)
  status TEXT NOT NULL DEFAULT 'capturado' CHECK (status IN (
    'capturado','transcricao_pendente','transcrito',
    'classificacao_pendente','classificado',
    'aguardando_humano','executando_acao_automatica','executando_acao_manual',
    'finalizado','rejeitado','erro'
  )),

  -- Metadados
  fonte TEXT,
  correlation_id UUID,
  retry_count INT DEFAULT 0,
  last_error TEXT,

  -- Audit
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_descarregos_mentorado
  ON descarregos(mentorado_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_descarregos_status
  ON descarregos(status)
  WHERE status NOT IN ('finalizado','rejeitado');
CREATE INDEX IF NOT EXISTS idx_descarregos_correlation
  ON descarregos(correlation_id)
  WHERE correlation_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_descarregos_classificacao
  ON descarregos(classificacao_principal, classificado_em);

-- updated_at auto-trigger (cria função genérica se não existe)
CREATE OR REPLACE FUNCTION fn_lf_touch_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_descarregos_touch ON descarregos;
CREATE TRIGGER trg_descarregos_touch
  BEFORE UPDATE ON descarregos
  FOR EACH ROW EXECUTE FUNCTION fn_lf_touch_updated_at();

-- entity_events trigger (Fase 1)
DROP TRIGGER IF EXISTS trg_lf_events_descarregos ON descarregos;
CREATE TRIGGER trg_lf_events_descarregos
  AFTER INSERT OR UPDATE OR DELETE ON descarregos
  FOR EACH ROW EXECUTE FUNCTION emit_entity_event('Descarrego');

-- RLS
ALTER TABLE descarregos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "descarregos_select" ON descarregos FOR SELECT TO authenticated USING (true);
CREATE POLICY "descarregos_insert" ON descarregos FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "descarregos_update" ON descarregos FOR UPDATE TO authenticated USING (true);

GRANT SELECT, INSERT, UPDATE ON descarregos TO authenticated;
GRANT SELECT ON descarregos TO anon;
GRANT ALL ON descarregos TO service_role;

-- ------------------------------------------------------------
-- LF-3.2: migração de mentorado_context → descarregos
-- ------------------------------------------------------------
DO $$
DECLARE
  migrated_count INT := 0;
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name='mentorado_context' AND table_schema='public'
  ) THEN
    INSERT INTO descarregos (
      mentorado_id, consultor_id, tipo_bruto,
      conteudo_bruto, arquivo_url, arquivo_mime_type, transcricao,
      classificacao_principal, classificacao_confidence,
      acao_tomada, status, fonte, created_at, updated_at
    )
    SELECT
      mc.mentorado_id,
      mc.criado_por,
      CASE
        WHEN mc.tipo IN ('audio','video','imagem','arquivo','link','gravacao','texto') THEN mc.tipo
        ELSE 'texto'
      END,
      COALESCE(mc.conteudo, mc.titulo),
      mc.arquivo_url,
      mc.arquivo_tipo,
      COALESCE(mc.transcricao, mc.conteudo),
      'contexto',
      0.0,
      'salvo_como_contexto',
      'finalizado',
      'migration_legacy',
      COALESCE(mc.created_at, now()),
      COALESCE(mc.updated_at, mc.created_at, now())
    FROM mentorado_context mc
    WHERE NOT EXISTS (
      -- Idempotente: não duplicar se já rodou
      SELECT 1 FROM descarregos d
      WHERE d.fonte = 'migration_legacy'
        AND d.mentorado_id = mc.mentorado_id
        AND d.conteudo_bruto = mc.conteudo
    );
    GET DIAGNOSTICS migrated_count = ROW_COUNT;
    RAISE NOTICE 'Migrated % rows from mentorado_context to descarregos', migrated_count;
  ELSE
    RAISE NOTICE 'mentorado_context does not exist, skipping migration';
  END IF;
END $$;

COMMIT;
