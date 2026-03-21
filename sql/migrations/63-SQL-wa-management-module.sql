-- =====================================================
-- S8 — WA Management Module: DB Schema
-- Sprint 8 | Feature: Carteira + Notas + Snooze + Bulk
-- =====================================================

-- 1. Add snoozed_until to mentorados
-- (allows consultant to snooze a mentee from priority inbox)
ALTER TABLE mentorados
    ADD COLUMN IF NOT EXISTS snoozed_until TIMESTAMPTZ;

-- 2. Create mentee_notes table
--    Fields match frontend 11-APP-app.js exactly:
--      - mentee_id BIGINT (references mentorados.id — integer PK)
--      - tipo: 'livre' | 'checkpoint_mensal' | 'feedback_aula' | 'registro_ligacao'
--      - conteudo TEXT (plain text)
--      - tags TEXT[]
--      - author_name TEXT (display name stored at insert time)
--      - created_at TIMESTAMPTZ
CREATE TABLE IF NOT EXISTS mentee_notes (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    mentee_id   BIGINT      NOT NULL REFERENCES mentorados(id) ON DELETE CASCADE,
    tipo        TEXT        NOT NULL CHECK (tipo IN (
                    'livre',
                    'checkpoint_mensal',
                    'feedback_aula',
                    'registro_ligacao'
                )),
    conteudo    TEXT        NOT NULL,
    tags        TEXT[]      NOT NULL DEFAULT '{}',
    author_name TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index: queries by mentee ordered by date
CREATE INDEX IF NOT EXISTS idx_mentee_notes_mentee_id_created
    ON mentee_notes (mentee_id, created_at DESC);

-- RLS
ALTER TABLE mentee_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "mentee_notes_select"
    ON mentee_notes FOR SELECT
    USING (true);

CREATE POLICY IF NOT EXISTS "mentee_notes_insert"
    ON mentee_notes FOR INSERT
    WITH CHECK (true);
