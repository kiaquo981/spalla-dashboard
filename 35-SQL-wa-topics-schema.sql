-- ============================================================
-- Spalla Dashboard — WhatsApp Topic Intelligence Schema
-- Story: WA-01-01 | 2026-03-11
-- ============================================================

-- ------------------------------------------------------------
-- 0. pgvector extension (run once per database)
-- ------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS vector;

-- ------------------------------------------------------------
-- 1. Topic Types (taxonomy)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wa_topic_types (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT NOT NULL UNIQUE,
  slug         TEXT NOT NULL UNIQUE,
  color        TEXT NOT NULL DEFAULT '#94a3b8',
  icon         TEXT NOT NULL DEFAULT 'message-circle',
  description  TEXT,
  creates_task BOOLEAN NOT NULL DEFAULT false,
  sort_order   INT NOT NULL DEFAULT 0,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE wa_topic_types IS 'Taxonomy of WhatsApp topic types for AI classification';

-- ------------------------------------------------------------
-- 2. Message Queue (staging / processing)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wa_message_queue (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_jid    TEXT NOT NULL,
  message_id   TEXT NOT NULL UNIQUE,
  payload      JSONB NOT NULL,
  status       TEXT NOT NULL DEFAULT 'pending',
  error_msg    TEXT,
  retry_count  INT NOT NULL DEFAULT 0,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  processed_at TIMESTAMPTZ,

  CONSTRAINT wa_message_queue_status_check
    CHECK (status IN ('pending','processing','done','error','skipped'))
);

COMMENT ON TABLE wa_message_queue IS 'Staging queue for incoming WhatsApp messages before AI processing';
COMMENT ON COLUMN wa_message_queue.group_jid IS 'WhatsApp group JID: 120363XXXXX@g.us';
COMMENT ON COLUMN wa_message_queue.message_id IS 'Evolution API message key.id (dedup)';
COMMENT ON COLUMN wa_message_queue.payload IS 'Raw Evolution API webhook payload';

CREATE INDEX IF NOT EXISTS idx_wa_queue_status ON wa_message_queue (status, created_at);
CREATE INDEX IF NOT EXISTS idx_wa_queue_group  ON wa_message_queue (group_jid, created_at);

-- ------------------------------------------------------------
-- 3. Topics (threads / clusters)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wa_topics (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_jid        TEXT NOT NULL,
  mentorado_id     BIGINT REFERENCES "case".mentorados(id) ON DELETE SET NULL,
  type_id          UUID REFERENCES wa_topic_types(id) ON DELETE SET NULL,
  title            TEXT NOT NULL,
  summary          TEXT,
  status           TEXT NOT NULL DEFAULT 'open',
  task_id          UUID REFERENCES god_tasks(id) ON DELETE SET NULL,
  confidence       NUMERIC(3,2),
  message_count    INT NOT NULL DEFAULT 0,
  first_message_at TIMESTAMPTZ,
  last_message_at  TIMESTAMPTZ,
  resolved_at      TIMESTAMPTZ,
  resolved_by      TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- RAG vector: 1536 dims for text-embedding-3-small
  embedding        vector(1536),

  -- AI metadata
  ai_keywords      TEXT[],
  ai_participants  TEXT[],
  ai_context_hash  TEXT,

  CONSTRAINT wa_topics_status_check
    CHECK (status IN ('open','active','pending_action','resolved','archived','converted_task'))
);

COMMENT ON TABLE wa_topics IS 'WhatsApp conversation topic clusters — AI-classified threads';
COMMENT ON COLUMN wa_topics.confidence IS 'AI classification confidence 0.00–1.00';
COMMENT ON COLUMN wa_topics.embedding IS '1536-dim vector for RAG semantic search';
COMMENT ON COLUMN wa_topics.ai_context_hash IS 'Hash of last N messages used for last classification';

CREATE INDEX IF NOT EXISTS idx_wa_topics_group     ON wa_topics (group_jid, status);
CREATE INDEX IF NOT EXISTS idx_wa_topics_mentorado ON wa_topics (mentorado_id, status);
CREATE INDEX IF NOT EXISTS idx_wa_topics_status    ON wa_topics (status, last_message_at DESC);
-- Note: ivfflat index requires data; create after first batch of embeddings
-- CREATE INDEX idx_wa_topics_embedding ON wa_topics USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- ------------------------------------------------------------
-- 4. Messages (processed, with topic assignment)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wa_messages (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id        TEXT NOT NULL UNIQUE,
  group_jid         TEXT NOT NULL,
  mentorado_id      BIGINT REFERENCES "case".mentorados(id) ON DELETE SET NULL,
  topic_id          UUID REFERENCES wa_topics(id) ON DELETE SET NULL,
  topic_confidence  NUMERIC(3,2),
  sender_jid        TEXT,
  sender_name       TEXT,
  is_from_team      BOOLEAN NOT NULL DEFAULT false,
  content_type      TEXT NOT NULL DEFAULT 'text',
  content_text      TEXT,
  media_url         TEXT,
  media_mime        TEXT,
  reply_to_id       TEXT,
  timestamp         TIMESTAMPTZ NOT NULL,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Vector for semantic search
  embedding         vector(1536),

  CONSTRAINT wa_messages_content_type_check
    CHECK (content_type IN (
      'text','audio','image','video','document',
      'sticker','reaction','location','other'
    ))
);

COMMENT ON TABLE wa_messages IS 'Processed WhatsApp messages with topic assignment and embeddings';
COMMENT ON COLUMN wa_messages.message_id IS 'Evolution API message key.id (dedup)';
COMMENT ON COLUMN wa_messages.is_from_team IS 'True if sender is a CASE team member';
COMMENT ON COLUMN wa_messages.embedding IS '1536-dim vector for RAG semantic search';

CREATE INDEX IF NOT EXISTS idx_wa_messages_topic     ON wa_messages (topic_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_wa_messages_group     ON wa_messages (group_jid, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_wa_messages_mentorado ON wa_messages (mentorado_id, timestamp DESC);
-- CREATE INDEX idx_wa_messages_embedding ON wa_messages USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- ------------------------------------------------------------
-- 5. Topic Events (audit trail)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wa_topic_events (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  topic_id    UUID NOT NULL REFERENCES wa_topics(id) ON DELETE CASCADE,
  event_type  TEXT NOT NULL,
  payload     JSONB,
  created_by  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT wa_topic_events_type_check
    CHECK (event_type IN (
      'created','status_changed','title_edited','task_linked',
      'message_added','ai_reclassified','manually_merged','archived'
    ))
);

COMMENT ON TABLE wa_topic_events IS 'Audit trail for topic lifecycle events';
COMMENT ON COLUMN wa_topic_events.created_by IS 'ai | user email | system';

CREATE INDEX IF NOT EXISTS idx_wa_topic_events_topic ON wa_topic_events (topic_id, created_at);

-- ------------------------------------------------------------
-- 6. updated_at trigger for wa_topics
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION wa_topics_set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_wa_topics_updated_at ON wa_topics;
CREATE TRIGGER trg_wa_topics_updated_at
  BEFORE UPDATE ON wa_topics
  FOR EACH ROW EXECUTE FUNCTION wa_topics_set_updated_at();

-- ------------------------------------------------------------
-- 7. Board View
-- ------------------------------------------------------------
DROP VIEW IF EXISTS vw_wa_topic_board;
CREATE VIEW vw_wa_topic_board AS
SELECT
  t.*,
  m.nome                           AS mentorado_nome,
  tt.name                          AS type_name,
  tt.slug                          AS type_slug,
  tt.color                         AS type_color,
  tt.icon                          AS type_icon,

  -- Last message preview (text only)
  (
    SELECT content_text
    FROM wa_messages
    WHERE topic_id = t.id
    ORDER BY timestamp DESC
    LIMIT 1
  ) AS last_message_preview,

  -- Messages awaiting team response
  (
    SELECT COUNT(*)
    FROM wa_messages
    WHERE topic_id = t.id
      AND is_from_team = false
      AND timestamp > COALESCE(
        (SELECT MAX(timestamp) FROM wa_messages
         WHERE topic_id = t.id AND is_from_team = true),
        '1970-01-01'::timestamptz
      )
  ) AS msgs_awaiting_response,

  -- Linked task info
  gt.titulo  AS task_titulo,
  gt.status  AS task_status

FROM wa_topics t
LEFT JOIN "case".mentorados m  ON m.id  = t.mentorado_id
LEFT JOIN wa_topic_types tt ON tt.id = t.type_id
LEFT JOIN god_tasks     gt ON gt.id = t.task_id;

-- ------------------------------------------------------------
-- 8. RLS Policies
-- ------------------------------------------------------------
ALTER TABLE wa_topic_types   ENABLE ROW LEVEL SECURITY;
ALTER TABLE wa_message_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE wa_topics        ENABLE ROW LEVEL SECURITY;
ALTER TABLE wa_messages      ENABLE ROW LEVEL SECURITY;
ALTER TABLE wa_topic_events  ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to allow idempotent re-run
DROP POLICY IF EXISTS "wa_topic_types_select"    ON wa_topic_types;
DROP POLICY IF EXISTS "wa_topic_types_manage"    ON wa_topic_types;
DROP POLICY IF EXISTS "wa_queue_select"          ON wa_message_queue;
DROP POLICY IF EXISTS "wa_queue_insert"          ON wa_message_queue;
DROP POLICY IF EXISTS "wa_queue_update"          ON wa_message_queue;
DROP POLICY IF EXISTS "wa_topics_select"         ON wa_topics;
DROP POLICY IF EXISTS "wa_topics_insert"         ON wa_topics;
DROP POLICY IF EXISTS "wa_topics_update"         ON wa_topics;
DROP POLICY IF EXISTS "wa_topics_delete"         ON wa_topics;
DROP POLICY IF EXISTS "wa_messages_select"       ON wa_messages;
DROP POLICY IF EXISTS "wa_messages_insert"       ON wa_messages;
DROP POLICY IF EXISTS "wa_messages_update"       ON wa_messages;
DROP POLICY IF EXISTS "wa_topic_events_select"   ON wa_topic_events;
DROP POLICY IF EXISTS "wa_topic_events_insert"   ON wa_topic_events;

-- Topic types: read-only for all authenticated
CREATE POLICY "wa_topic_types_select"
  ON wa_topic_types FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "wa_topic_types_manage"
  ON wa_topic_types FOR ALL
  TO service_role USING (true) WITH CHECK (true);

-- Message queue: service_role manages, authenticated reads own
CREATE POLICY "wa_queue_select"
  ON wa_message_queue FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "wa_queue_insert"
  ON wa_message_queue FOR INSERT
  TO authenticated WITH CHECK (true);

CREATE POLICY "wa_queue_update"
  ON wa_message_queue FOR UPDATE
  TO authenticated USING (true);

-- Topics: full access for authenticated
CREATE POLICY "wa_topics_select"
  ON wa_topics FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "wa_topics_insert"
  ON wa_topics FOR INSERT
  TO authenticated WITH CHECK (true);

CREATE POLICY "wa_topics_update"
  ON wa_topics FOR UPDATE
  TO authenticated USING (true);

CREATE POLICY "wa_topics_delete"
  ON wa_topics FOR DELETE
  TO authenticated USING (true);

-- Messages: full access for authenticated
CREATE POLICY "wa_messages_select"
  ON wa_messages FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "wa_messages_insert"
  ON wa_messages FOR INSERT
  TO authenticated WITH CHECK (true);

CREATE POLICY "wa_messages_update"
  ON wa_messages FOR UPDATE
  TO authenticated USING (true);

-- Topic events: read + insert for authenticated
CREATE POLICY "wa_topic_events_select"
  ON wa_topic_events FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "wa_topic_events_insert"
  ON wa_topic_events FOR INSERT
  TO authenticated WITH CHECK (true);

-- ------------------------------------------------------------
-- 9. Seed: Topic Types
-- ------------------------------------------------------------
INSERT INTO wa_topic_types (name, slug, color, icon, creates_task, sort_order) VALUES
  ('Revisão de Entrega',  'revisao',    '#6366f1', 'check-circle',  true,  10),
  ('Demanda Operacional', 'demanda',    '#ef4444', 'alert-circle',  true,  20),
  ('Plano de Ação',       'plano',      '#f97316', 'list',          true,  30),
  ('Dúvida / Orientação', 'duvida',     '#3b82f6', 'help-circle',   false, 40),
  ('Planejamento Call',   'call',       '#8b5cf6', 'phone',         false, 50),
  ('Celebração',          'celebracao', '#10b981', 'star',          false, 60),
  ('Dossiê Estratégico',  'dossie',     '#f59e0b', 'book',          true,  70),
  ('Pós-Call',            'pos_call',   '#06b6d4', 'message-square',true,  80),
  ('Feedback',            'feedback',   '#ec4899', 'thumbs-up',     false, 90),
  ('Sem Categoria',       'geral',      '#94a3b8', 'message-circle',false, 99)
ON CONFLICT (slug) DO NOTHING;

-- ------------------------------------------------------------
-- 10. Helper function: semantic search on topics
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION search_wa_topics(
  query_embedding vector(1536),
  p_group_jid     TEXT DEFAULT NULL,
  p_status        TEXT DEFAULT NULL,
  match_count     INT  DEFAULT 10
)
RETURNS TABLE (
  id          UUID,
  title       TEXT,
  summary     TEXT,
  status      TEXT,
  type_name   TEXT,
  type_color  TEXT,
  similarity  FLOAT
)
LANGUAGE sql STABLE AS $$
  SELECT
    t.id,
    t.title,
    t.summary,
    t.status,
    tt.name  AS type_name,
    tt.color AS type_color,
    1 - (t.embedding <=> query_embedding) AS similarity
  FROM wa_topics t
  LEFT JOIN wa_topic_types tt ON tt.id = t.type_id
  WHERE
    t.embedding IS NOT NULL
    AND (p_group_jid IS NULL OR t.group_jid = p_group_jid)
    AND (p_status    IS NULL OR t.status    = p_status)
  ORDER BY t.embedding <=> query_embedding
  LIMIT match_count;
$$;

GRANT EXECUTE ON FUNCTION search_wa_topics(vector, TEXT, TEXT, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION search_wa_topics(vector, TEXT, TEXT, INT) TO anon;
