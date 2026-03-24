-- ================================================================
-- Migration: ClickUp Model — Estrutura organizacional nativa
-- Data: 2026-03-23
-- Autor: Spalla Dev
--
-- Contexto:
--   O Spalla precisa modelar o ClickUp de forma nativa para que:
--   1. Tarefas internas e importadas do ClickUp compartilhem os mesmos IDs
--   2. Membros da equipe tenham mapeamento ClickUp ↔ Spalla
--   3. Spaces e Lists sejam entidades reais (não strings hardcoded no JS)
--   4. Sprints vivam no banco — não em arrays estáticos no front-end
--
-- Tabelas criadas:
--   - spalla_members    → equipe (ClickUp user_id + username + nome)
--   - god_spaces        → spaces (Jornada, Gestão, IA, Sistema)
--   - god_lists         → lists e sprints dentro de cada space
--
-- Colunas adicionadas em god_tasks:
--   - clickup_id        → ID do ClickUp para cross-reference (ex: '9hx3abc2')
--   - clickup_url       → URL direta da tarefa no ClickUp
--   - clickup_synced_at → Timestamp do último sync com ClickUp
-- ================================================================

-- ================================================================
-- 1. SPALLA_MEMBERS — equipe com mapeamento ClickUp
-- ================================================================

CREATE TABLE IF NOT EXISTS public.spalla_members (
  id              VARCHAR(50)  PRIMARY KEY,           -- slug interno: 'kaique', 'mariza'
  nome_completo   VARCHAR(200) NOT NULL,
  nome_curto      VARCHAR(50)  NOT NULL,
  email           VARCHAR(200) NULL,
  clickup_user_id VARCHAR(50)  NULL,                  -- ID numérico do usuário no ClickUp
  clickup_username VARCHAR(100) NULL,                 -- username no ClickUp (ex: 'kaique.rodrigues')
  cargo           VARCHAR(100) NULL,
  cor             VARCHAR(20)  NOT NULL DEFAULT '#6366f1',
  ativo           BOOLEAN      NOT NULL DEFAULT true,
  created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.spalla_members IS
  'Membros da equipe Spalla com mapeamento para usuários ClickUp.
   Resolve o problema de matching entre username ClickUp e nome completo.';

COMMENT ON COLUMN public.spalla_members.clickup_user_id IS
  'ID numérico do usuário no ClickUp (campo "id" do objeto assignee).
   Usado para filtrar tarefas do ClickUp por responsável sem ambiguidade.';

COMMENT ON COLUMN public.spalla_members.clickup_username IS
  'Username no ClickUp — pode ser first name, email prefix, ou slug customizado.
   Preenchido automaticamente no primeiro sync com a API do ClickUp.';

-- ================================================================
-- 2. GOD_SPACES — spaces (equivalente ao Space do ClickUp)
-- ================================================================

CREATE TABLE IF NOT EXISTS public.god_spaces (
  id              VARCHAR(50)  PRIMARY KEY,           -- slug interno: 'space_jornada'
  nome            VARCHAR(200) NOT NULL,
  clickup_space_id VARCHAR(50) NULL,                  -- ID do Space no ClickUp: '90114112693'
  cor             VARCHAR(20)  NOT NULL DEFAULT '#6366f1',
  icone           VARCHAR(50)  NULL,                  -- emoji ou nome de ícone
  ordem           SMALLINT     NOT NULL DEFAULT 0,
  ativo           BOOLEAN      NOT NULL DEFAULT true,
  created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.god_spaces IS
  'Spaces do Spalla — espelha o conceito de Space do ClickUp.
   clickup_space_id permite sync bidirecional.';

-- ================================================================
-- 3. GOD_LISTS — listas e sprints dentro de cada space
-- ================================================================

CREATE TABLE IF NOT EXISTS public.god_lists (
  id               VARCHAR(50)  PRIMARY KEY,          -- slug ou ID ClickUp: 'list_onboarding', '901113377455'
  nome             VARCHAR(200) NOT NULL,
  space_id         VARCHAR(50)  NOT NULL REFERENCES public.god_spaces(id) ON DELETE RESTRICT,
  clickup_list_id  VARCHAR(50)  NULL,                 -- ID da List no ClickUp
  tipo             VARCHAR(20)  NOT NULL DEFAULT 'list'
                   CHECK (tipo IN ('list','sprint','backlog','folder')),
  -- Campos específicos de Sprint
  sprint_inicio    DATE         NULL,
  sprint_fim       DATE         NULL,
  sprint_status    VARCHAR(20)  NOT NULL DEFAULT 'planejado'
                   CHECK (sprint_status IN ('ativo','planejado','encerrado','arquivado')),
  sprint_total     INT          NULL DEFAULT 0,       -- total de tarefas (cache, não normativo)
  sprint_concluidas INT         NULL DEFAULT 0,       -- concluídas (cache, não normativo)
  -- Metadados
  ordem            SMALLINT     NOT NULL DEFAULT 0,
  ativo            BOOLEAN      NOT NULL DEFAULT true,
  created_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.god_lists IS
  'Listas e Sprints do Spalla — equivalente a List do ClickUp.
   Tipo "sprint" ativa os campos sprint_inicio/fim/status.
   Substitui o array data.sprints hardcoded no frontend.';

COMMENT ON COLUMN public.god_lists.sprint_total IS
  'Cache de contagem — atualizado pelo backend a cada sync.
   NÃO é fonte de verdade. Use COUNT(god_tasks) para valores exatos.';

-- ================================================================
-- 4. GOD_TASKS — adiciona colunas para cross-reference com ClickUp
-- ================================================================

ALTER TABLE public.god_tasks
  ADD COLUMN IF NOT EXISTS operon_id         VARCHAR(50)  NULL,
  ADD COLUMN IF NOT EXISTS clickup_url       VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS clickup_synced_at TIMESTAMPTZ  NULL;

COMMENT ON COLUMN public.god_tasks.operon_id IS
  'ID interno Operon — espelha o ID da tarefa correspondente no ClickUp (ex: "9hx3abc2").
   UNIQUE NULL — uma tarefa Spalla pode não ter par no ClickUp (tarefa criada internamente).
   Quando presente, permite sync bidirecional e abertura do drawer a partir
   de itens de atividade que chegam da API do ClickUp.';

COMMENT ON COLUMN public.god_tasks.clickup_url IS
  'URL direta para a tarefa no ClickUp.
   Armazenada para casos em que o ClickUp não está acessível via API
   mas o usuário quer navegar manualmente.';

COMMENT ON COLUMN public.god_tasks.clickup_synced_at IS
  'Timestamp do último sync com o ClickUp.
   NULL = tarefa criada internamente, nunca sincronizada.
   Usado para detectar divergências (tarefa atualizada no ClickUp após o último sync).';

-- Índice para lookup por operon_id (crítico para performance do sync)
CREATE UNIQUE INDEX IF NOT EXISTS idx_god_tasks_operon_id
  ON public.god_tasks (operon_id)
  WHERE operon_id IS NOT NULL;

-- ================================================================
-- 5. SEED DATA — dados estáticos que viviam hardcoded no front-end
-- ================================================================

-- 5a. SPALLA_MEMBERS — equipe (IDs ClickUp a preencher no primeiro sync)
INSERT INTO public.spalla_members (id, nome_completo, nome_curto, cargo, cor)
VALUES
  ('kaique', 'Kaique Rodrigues', 'Kaique', 'Head de Produto',   '#6366f1'),
  ('heitor', 'Heitor Santos',    'Heitor', 'Desenvolvedor',     '#0ea5e9'),
  ('hugo',   'Hugo',             'Hugo',   'Desenvolvedor',     '#10b981'),
  ('queila', 'Queila Martins',   'Queila', 'Head de Estratégia','#f59e0b'),
  ('mariza', 'Mariza',           'Mariza', 'Operações',         '#ec4899'),
  ('lara',   'Lara',             'Lara',   'Sucesso do Cliente', '#8b5cf6')
ON CONFLICT (id) DO NOTHING;

-- 5b. GOD_SPACES — espaces do Spalla
INSERT INTO public.god_spaces (id, nome, clickup_space_id, cor, icone, ordem)
VALUES
  ('space_jornada', 'Jornada do Mentorado', '90114112693', '#10b981', '🗺️', 1),
  ('space_gestao',  'Gestão Interna',       NULL,          '#6366f1', '⚙️', 2),
  ('space_ia',      'IA & Automação',       NULL,          '#f59e0b', '🤖', 3),
  ('space_sistema', 'Sistema & Dev',        NULL,          '#0ea5e9', '💻', 4)
ON CONFLICT (id) DO NOTHING;

-- 5c. GOD_LISTS — listas por space + sprints (reais, do ClickUp)
INSERT INTO public.god_lists (id, nome, space_id, clickup_list_id, tipo, sprint_inicio, sprint_fim, sprint_status, sprint_total, sprint_concluidas, ordem)
VALUES
  -- Jornada — fases da mentoria
  ('list_onboarding',  'Onboarding',           'space_jornada', NULL,             'list', NULL, NULL, 'planejado', 0, 0, 1),
  ('list_concepcao',   'Concepção',            'space_jornada', NULL,             'list', NULL, NULL, 'planejado', 0, 0, 2),
  ('list_validacao',   'Validação',            'space_jornada', NULL,             'list', NULL, NULL, 'planejado', 0, 0, 3),
  ('list_otimizacao',  'Otimização',           'space_jornada', NULL,             'list', NULL, NULL, 'planejado', 0, 0, 4),
  ('list_escala',      'Escala',               'space_jornada', NULL,             'list', NULL, NULL, 'planejado', 0, 0, 5),

  -- Gestão — áreas de trabalho interno
  ('list_dossies',        'Dossiês',           'space_gestao',  NULL,             'list', NULL, NULL, 'planejado', 0, 0, 1),
  ('list_conteudo',       'Conteúdo',          'space_gestao',  NULL,             'list', NULL, NULL, 'planejado', 0, 0, 2),
  ('list_direcionamentos','Direcionamentos',   'space_gestao',  NULL,             'list', NULL, NULL, 'planejado', 0, 0, 3),
  ('list_playbooks',      'Playbooks',         'space_gestao',  NULL,             'list', NULL, NULL, 'planejado', 0, 0, 4),
  ('list_vendas',         'Vendas & Funil',    'space_gestao',  NULL,             'list', NULL, NULL, 'planejado', 0, 0, 5),

  -- IA & Automação
  ('list_agentes',     'Agentes',              'space_ia',      NULL,             'list', NULL, NULL, 'planejado', 0, 0, 1),
  ('list_workflows',   'Workflows N8N',        'space_ia',      NULL,             'list', NULL, NULL, 'planejado', 0, 0, 2),

  -- Sistema — sprints reais do ClickUp
  ('901113377455', 'Sprint 1 (3/16 - 3/22)', 'space_sistema', '901113377455', 'sprint', '2026-03-16', '2026-03-22', 'encerrado', 7,   2, 1),
  ('901113377456', 'Sprint 2 (3/23 - 3/29)', 'space_sistema', '901113377456', 'sprint', '2026-03-23', '2026-03-29', 'ativo',     225, 2, 2),
  ('901113377457', 'Sprint 3 (3/30 - 4/5)',  'space_sistema', '901113377457', 'sprint', '2026-03-30', '2026-04-05', 'planejado', 230, 0, 3)
ON CONFLICT (id) DO NOTHING;

-- ================================================================
-- 6. ROW LEVEL SECURITY
-- ================================================================

ALTER TABLE public.spalla_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.god_spaces     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.god_lists      ENABLE ROW LEVEL SECURITY;

-- Leitura pública (autenticados) — estrutura organizacional não é sensível
DROP POLICY IF EXISTS "spalla_members: leitura autenticados" ON public.spalla_members;
CREATE POLICY "spalla_members: leitura autenticados"
  ON public.spalla_members FOR SELECT
  USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "god_spaces: leitura autenticados" ON public.god_spaces;
CREATE POLICY "god_spaces: leitura autenticados"
  ON public.god_spaces FOR SELECT
  USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "god_lists: leitura autenticados" ON public.god_lists;
CREATE POLICY "god_lists: leitura autenticados"
  ON public.god_lists FOR SELECT
  USING (auth.role() = 'authenticated');

-- Escrita: apenas service_role (backend) ou usuário autenticado
-- god_lists: permite update de sprint_total/sprint_concluidas pelo front (cache)
DROP POLICY IF EXISTS "god_lists: escrita autenticados" ON public.god_lists;
CREATE POLICY "god_lists: escrita autenticados"
  ON public.god_lists FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- ================================================================
-- 7. ÍNDICES de performance
-- ================================================================

CREATE INDEX IF NOT EXISTS idx_god_lists_space_id      ON public.god_lists (space_id);
CREATE INDEX IF NOT EXISTS idx_god_lists_tipo          ON public.god_lists (tipo);
CREATE INDEX IF NOT EXISTS idx_god_lists_sprint_status ON public.god_lists (sprint_status) WHERE tipo = 'sprint';
CREATE INDEX IF NOT EXISTS idx_spalla_members_clickup  ON public.spalla_members (clickup_user_id) WHERE clickup_user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_spalla_members_username ON public.spalla_members (clickup_username) WHERE clickup_username IS NOT NULL;

-- ================================================================
-- 8. TRIGGER: updated_at automático
-- ================================================================

-- Reusa a função se já existe no projeto
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_spalla_members_updated_at ON public.spalla_members;
CREATE TRIGGER trg_spalla_members_updated_at
  BEFORE UPDATE ON public.spalla_members
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_god_lists_updated_at ON public.god_lists;
CREATE TRIGGER trg_god_lists_updated_at
  BEFORE UPDATE ON public.god_lists
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
