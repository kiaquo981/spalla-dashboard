-- =====================================================
-- S9-A — WA DM v2: Core Data Model
-- Sprint 9 | Feature: DM 1:1 inbox + SLA + canned + presence + segments
-- Worktree: wt-wa-dm-core | Branch: feature/case/wa-dm-core
-- Created: 2026-03-21
-- =====================================================
-- Depends on:
--   - "case".mentorados (has grupo_whatsapp_id, snoozed_until, foto_url, fase_jornada)
--   - wa_messages (has mentorado_id, is_from_team, sender_name, content_text, timestamp)
--   - wa_topics   (has mentorado_id, status)
--   - god_tasks   (has mentorado_id, status)
-- =====================================================

BEGIN;

SET search_path = "case", public;

-- =====================================================
-- 1. VIEW: vw_wa_mentee_inbox
--    Virtual 1:1 inbox per mentee, aggregated from group messages
--    One row per active mentorado — abstrai o grupo WA como DM 1:1
-- =====================================================

CREATE OR REPLACE VIEW public.vw_wa_mentee_inbox AS
SELECT
  m.id                                            AS mentorado_id,
  m.nome                                          AS nome,
  m.foto_url                                      AS foto_url,
  m.fase_jornada                                  AS fase_jornada,
  m.grupo_whatsapp_id                             AS group_jid,
  m.snoozed_until,

  -- Last message in the group (any sender)
  last_msg.content_text                           AS last_message,
  last_msg.timestamp                              AS last_message_at,
  last_msg.sender_name                            AS last_message_sender,
  last_msg.is_from_team                           AS last_message_is_team,

  -- Unread: inbound msgs after last team response (mentorado waiting on team)
  COALESCE(unread.cnt, 0)                         AS unread_count,

  -- SLA: hours since last inbound that still has no team reply after it
  --      pending_inbound = NULL when team already replied → verde/no alert
  ROUND(
    EXTRACT(EPOCH FROM (now() - pending_inbound.ts)) / 3600.0,
    1
  )                                               AS horas_sem_resposta_equipe,

  -- Health status: snoozed > vermelho > amarelo > verde
  CASE
    WHEN m.snoozed_until IS NOT NULL AND m.snoozed_until > now() THEN 'snoozed'
    WHEN pending_inbound.ts IS NOT NULL
         AND EXTRACT(EPOCH FROM (now() - pending_inbound.ts)) / 3600 > 72 THEN 'vermelho'
    WHEN pending_inbound.ts IS NOT NULL
         AND EXTRACT(EPOCH FROM (now() - pending_inbound.ts)) / 3600 > 48 THEN 'amarelo'
    ELSE 'verde'
  END                                             AS health_status,

  -- Open topics (pending team action)
  COALESCE(open_topics.cnt, 0)                    AS open_topics_count,

  -- Active god_tasks for this mentee
  COALESCE(active_tasks.cnt, 0)                   AS active_tasks_count

FROM "case".mentorados m

-- Last message from the group (any sender)
LEFT JOIN LATERAL (
  SELECT content_text, timestamp, sender_name, is_from_team
  FROM public.wa_messages
  WHERE mentorado_id = m.id
  ORDER BY timestamp DESC
  LIMIT 1
) last_msg ON true

-- Unread count: inbound messages since last team reply
LEFT JOIN LATERAL (
  SELECT COUNT(*)::INT AS cnt
  FROM public.wa_messages
  WHERE mentorado_id = m.id
    AND is_from_team = false
    AND timestamp > COALESCE(
      (SELECT MAX(timestamp)
       FROM public.wa_messages
       WHERE mentorado_id = m.id AND is_from_team = true),
      '1970-01-01'::timestamptz
    )
) unread ON true

-- Pending inbound: last inbound that has NO team reply after it
--   NULL when team already responded → SLA timer stops → health = verde
LEFT JOIN LATERAL (
  SELECT timestamp AS ts
  FROM public.wa_messages
  WHERE mentorado_id = m.id
    AND is_from_team = false
    AND timestamp > COALESCE(
      (SELECT MAX(timestamp)
       FROM public.wa_messages
       WHERE mentorado_id = m.id AND is_from_team = true),
      '1970-01-01'::timestamptz
    )
  ORDER BY timestamp DESC
  LIMIT 1
) pending_inbound ON true

-- Open topics (excluding resolved/archived)
LEFT JOIN LATERAL (
  SELECT COUNT(*)::INT AS cnt
  FROM public.wa_topics
  WHERE mentorado_id = m.id
    AND status IN ('open', 'active', 'pending_action')
) open_topics ON true

-- Active tasks for this mentee
LEFT JOIN LATERAL (
  SELECT COUNT(*)::INT AS cnt
  FROM public.god_tasks
  WHERE mentorado_id = m.id
    AND status IN ('pendente', 'em_andamento')
) active_tasks ON true

WHERE m.ativo = true;

COMMENT ON VIEW public.vw_wa_mentee_inbox IS
  'S9 — Virtual 1:1 inbox per mentee. Aggregates WA group messages as DM-style inbox with SLA tracking.';

GRANT SELECT ON public.vw_wa_mentee_inbox TO anon, authenticated, service_role;


-- =====================================================
-- 2. TABLE: wa_sla_states
--    Histórico de SLA por mentorado (Chatwoot/Trengo pattern)
--    Permite analytics: % tempo em vermelho, quem resolveu mais SLAs
-- =====================================================

CREATE TABLE IF NOT EXISTS public.wa_sla_states (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  mentorado_id    BIGINT      NOT NULL REFERENCES "case".mentorados(id) ON DELETE CASCADE,
  yellow_at       TIMESTAMPTZ,            -- quando entrou em amarelo (48h sem resposta)
  red_at          TIMESTAMPTZ,            -- quando entrou em vermelho (72h sem resposta)
  resolved_at     TIMESTAMPTZ,            -- quando saiu do estado (equipe respondeu)
  resolved_by     TEXT,                   -- email do consultor que resolveu
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.wa_sla_states IS
  'S9 — SLA state history per mentee. Tracks when mentees enter/exit yellow/red states.';

CREATE INDEX IF NOT EXISTS idx_wa_sla_states_mentorado
  ON public.wa_sla_states (mentorado_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_wa_sla_states_open
  ON public.wa_sla_states (mentorado_id)
  WHERE resolved_at IS NULL;

ALTER TABLE public.wa_sla_states ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public'
      AND tablename = 'wa_sla_states' AND policyname = 'wa_sla_states_select'
  ) THEN
    CREATE POLICY "wa_sla_states_select"
      ON public.wa_sla_states FOR SELECT USING (true);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public'
      AND tablename = 'wa_sla_states' AND policyname = 'wa_sla_states_insert'
  ) THEN
    CREATE POLICY "wa_sla_states_insert"
      ON public.wa_sla_states FOR INSERT WITH CHECK (true);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public'
      AND tablename = 'wa_sla_states' AND policyname = 'wa_sla_states_update'
  ) THEN
    CREATE POLICY "wa_sla_states_update"
      ON public.wa_sla_states FOR UPDATE USING (true);
  END IF;
END $$;

GRANT SELECT, INSERT, UPDATE ON public.wa_sla_states TO anon, authenticated, service_role;


-- =====================================================
-- 3. TABLE: wa_canned_responses
--    Respostas rápidas com shortcode (Chatwoot pattern)
--    Trigger: usuário digita '/' no input → dropdown com shortcodes
-- =====================================================

CREATE TABLE IF NOT EXISTS public.wa_canned_responses (
  id          UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  shortcode   TEXT    NOT NULL UNIQUE,    -- ex: '/bom_dia', '/acompanhamento'
  name        TEXT    NOT NULL,           -- ex: 'Bom dia padrão'
  content     TEXT    NOT NULL,           -- texto completo da resposta
  category    TEXT    NOT NULL DEFAULT 'geral'
                      CHECK (category IN ('onboarding', 'follow_up', 'cobranca', 'geral')),
  created_by  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.wa_canned_responses IS
  'S9 — Quick-reply templates with shortcodes. Triggered by "/" in message input (Chatwoot pattern).';

CREATE INDEX IF NOT EXISTS idx_wa_canned_shortcode
  ON public.wa_canned_responses (shortcode);

CREATE INDEX IF NOT EXISTS idx_wa_canned_category
  ON public.wa_canned_responses (category);

ALTER TABLE public.wa_canned_responses ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public'
      AND tablename = 'wa_canned_responses' AND policyname = 'wa_canned_responses_all'
  ) THEN
    CREATE POLICY "wa_canned_responses_all"
      ON public.wa_canned_responses FOR ALL USING (true) WITH CHECK (true);
  END IF;
END $$;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.wa_canned_responses TO anon, authenticated, service_role;

-- Seed: ~8 templates padrão CASE
INSERT INTO public.wa_canned_responses (shortcode, name, content, category) VALUES
  ('/bom_dia',        'Bom dia padrão',         'Bom dia! Tudo bem? Passando para dar um oi e saber como estão as coisas por aí. Precisa de algo?', 'geral'),
  ('/acompanhamento', 'Check semanal',           'Olá! Passando para fazer um check semanal. Como estão os avanços? Tem alguma dificuldade que posso te ajudar a resolver?', 'follow_up'),
  ('/call',           'Agendamento de call',     'Oi! Que tal agendarmos uma call para falar sobre seu progresso? Me manda os melhores horários para você essa semana.', 'geral'),
  ('/material',       'Envio de material',       'Acabei de te enviar o material que conversamos. Qualquer dúvida sobre o conteúdo, é só chamar!', 'onboarding'),
  ('/prazo',          'Lembrete de prazo',       'Oi! Lembrando que o prazo para [AÇÃO] é [DATA]. Se precisar de apoio para concluir, me fala!', 'follow_up'),
  ('/resultado',      'Solicitação de resultado','Oi! Lembro que você mencionou [OBJETIVO]. Como estão os números? Me atualiza para podermos celebrar juntos!', 'follow_up'),
  ('/renovacao',      'Proposta de renovação',   'Olá! Sua jornada está chegando na reta final e adoraríamos continuar te apoiando. Que tal conversarmos sobre a renovação? Tenho condições especiais para quem já faz parte da família.', 'cobranca'),
  ('/parabens',       'Parabéns resultado',      'PARABÉNS! Isso é incrível! Você merece muito esse resultado. Continue assim — isso é só o começo!', 'geral')
ON CONFLICT (shortcode) DO NOTHING;


-- =====================================================
-- 4. TABLE: wa_presence
--    Collision detection — quem está vendo qual mentorado (Trengo/Front pattern)
--    Previne respostas duplicadas em equipes multi-consultor
-- =====================================================

CREATE TABLE IF NOT EXISTS public.wa_presence (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  mentorado_id    BIGINT      NOT NULL REFERENCES "case".mentorados(id) ON DELETE CASCADE,
  user_email      TEXT        NOT NULL,
  user_name       TEXT,
  last_seen       TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT wa_presence_unique UNIQUE (mentorado_id, user_email)
);

COMMENT ON TABLE public.wa_presence IS
  'S9 — Real-time presence tracking. Heartbeat-based collision detection (30s interval, 60s TTL).';

CREATE INDEX IF NOT EXISTS idx_wa_presence_mentee
  ON public.wa_presence (mentorado_id, last_seen DESC);

CREATE INDEX IF NOT EXISTS idx_wa_presence_last_seen
  ON public.wa_presence (last_seen);

ALTER TABLE public.wa_presence ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public'
      AND tablename = 'wa_presence' AND policyname = 'wa_presence_all'
  ) THEN
    CREATE POLICY "wa_presence_all"
      ON public.wa_presence FOR ALL USING (true) WITH CHECK (true);
  END IF;
END $$;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.wa_presence TO anon, authenticated, service_role;


-- =====================================================
-- 5. TABLE: wa_saved_segments
--    Filter presets salvos na Carteira (Respond.io pattern)
--    Permite criar filtros como "Onboarding em risco", "Renovação esse mês"
-- =====================================================

CREATE TABLE IF NOT EXISTS public.wa_saved_segments (
  id          UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT    NOT NULL,
  filters     JSONB   NOT NULL DEFAULT '{}',
  -- ex: {"fase_jornada": "onboarding", "health_status": "vermelho"}
  is_shared   BOOLEAN NOT NULL DEFAULT false,
  owner_email TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.wa_saved_segments IS
  'S9 — Saved filter presets for the Carteira view (Respond.io pattern).';

CREATE INDEX IF NOT EXISTS idx_wa_saved_segments_owner
  ON public.wa_saved_segments (owner_email);

CREATE INDEX IF NOT EXISTS idx_wa_saved_segments_shared
  ON public.wa_saved_segments (is_shared)
  WHERE is_shared = true;

ALTER TABLE public.wa_saved_segments ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public'
      AND tablename = 'wa_saved_segments' AND policyname = 'wa_saved_segments_all'
  ) THEN
    CREATE POLICY "wa_saved_segments_all"
      ON public.wa_saved_segments FOR ALL USING (true) WITH CHECK (true);
  END IF;
END $$;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.wa_saved_segments TO anon, authenticated, service_role;


-- =====================================================
-- 6. ALTER: god_tasks — backlinks WA (Front/Linear pattern)
--    Permite task extraction: de qual mensagem surgiu essa task?
-- =====================================================

ALTER TABLE public.god_tasks
  ADD COLUMN IF NOT EXISTS source_topic_id   UUID
    REFERENCES public.wa_topics(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS source_message_id UUID
    REFERENCES public.wa_messages(id) ON DELETE SET NULL;

COMMENT ON COLUMN public.god_tasks.source_topic_id IS
  'S9 — WA topic that originated this task (task extraction feature).';
COMMENT ON COLUMN public.god_tasks.source_message_id IS
  'S9 — WA message that originated this task (task extraction feature).';

CREATE INDEX IF NOT EXISTS idx_god_tasks_source_topic
  ON public.god_tasks (source_topic_id)
  WHERE source_topic_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_god_tasks_source_message
  ON public.god_tasks (source_message_id)
  WHERE source_message_id IS NOT NULL;

COMMIT;
