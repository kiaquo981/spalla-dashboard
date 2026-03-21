-- =====================================================
-- S8 — WA Management Module: DB Schema
-- Sprint 8 | Feature: Carteira + Notas + Snooze + Bulk
-- =====================================================

SET search_path = "case", public;

-- 1. Add snoozed_until to mentorados
-- (allows consultant to snooze a mentee from priority inbox)
ALTER TABLE "case".mentorados
    ADD COLUMN IF NOT EXISTS snoozed_until TIMESTAMPTZ;

-- 2. Create mentee_notes table
--    Fields match frontend 11-APP-app.js exactly:
--      - mentee_id BIGINT (references mentorados.id — integer PK)
--      - tipo: 'livre' | 'checkpoint_mensal' | 'feedback_aula' | 'registro_ligacao'
--      - conteudo TEXT (plain text)
--      - tags TEXT[]
--      - author_name TEXT (display name stored at insert time)
--      - created_at TIMESTAMPTZ
CREATE TABLE IF NOT EXISTS "case".mentee_notes (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    mentee_id   BIGINT      NOT NULL REFERENCES "case".mentorados(id) ON DELETE CASCADE,
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
    ON "case".mentee_notes (mentee_id, created_at DESC);

-- RLS
ALTER TABLE "case".mentee_notes ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'case' AND tablename = 'mentee_notes' AND policyname = 'mentee_notes_select'
    ) THEN
        CREATE POLICY "mentee_notes_select"
            ON "case".mentee_notes FOR SELECT USING (true);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'case' AND tablename = 'mentee_notes' AND policyname = 'mentee_notes_insert'
    ) THEN
        CREATE POLICY "mentee_notes_insert"
            ON "case".mentee_notes FOR INSERT WITH CHECK (true);
    END IF;
END $$;

-- Expose via public schema for PostgREST (anon/service role access)
CREATE OR REPLACE VIEW public.mentee_notes AS
    SELECT * FROM "case".mentee_notes;

GRANT SELECT, INSERT ON public.mentee_notes TO anon, authenticated, service_role;
