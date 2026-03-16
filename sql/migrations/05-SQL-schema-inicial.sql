-- =============================================================================
-- CASE Mentoria — Sistema de Controle de Mentorados
-- Schema Migration v1.0 — 09/02/2026
-- =============================================================================
-- Run this on Supabase SQL Editor in order
-- =============================================================================

-- 1. ALTER TABLE public.mentorados — Novas colunas de rastreamento
-- =============================================================================

ALTER TABLE public.mentorados
  ADD COLUMN IF NOT EXISTS fase_jornada text DEFAULT 'onboarding',
  ADD COLUMN IF NOT EXISTS sub_etapa text,
  ADD COLUMN IF NOT EXISTS marco_atual text,
  ADD COLUMN IF NOT EXISTS risco_churn text DEFAULT 'medio',
  ADD COLUMN IF NOT EXISTS cohort text,
  ADD COLUMN IF NOT EXISTS tem_produto boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS ja_vendeu boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS qtd_vendas_total integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS faturamento_mentoria numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS dossie_entregue boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS call_estrategia_realizada boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS call_onboarding_realizada boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS dias_sem_interacao integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS ultimo_processamento timestamptz,
  ADD COLUMN IF NOT EXISTS resumo_status text,
  ADD COLUMN IF NOT EXISTS historico_fases jsonb DEFAULT '[]'::jsonb;

-- Constraints (added separately because ADD COLUMN IF NOT EXISTS + CHECK don't combine well)
-- Only add if column was just created; skip if already constrained

DO $$
BEGIN
  -- fase_jornada check
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.check_constraints
    WHERE constraint_name = 'mentorados_fase_jornada_check'
  ) THEN
    ALTER TABLE public.mentorados
      ADD CONSTRAINT mentorados_fase_jornada_check
      CHECK (fase_jornada IN ('onboarding','concepcao','validacao','otimizacao','escala','concluido'));
  END IF;

  -- risco_churn check
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.check_constraints
    WHERE constraint_name = 'mentorados_risco_churn_check'
  ) THEN
    ALTER TABLE public.mentorados
      ADD CONSTRAINT mentorados_risco_churn_check
      CHECK (risco_churn IN ('baixo','medio','alto','critico'));
  END IF;

  -- cohort check
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.check_constraints
    WHERE constraint_name = 'mentorados_cohort_check'
  ) THEN
    ALTER TABLE public.mentorados
      ADD CONSTRAINT mentorados_cohort_check
      CHECK (cohort IN ('N1','N2','tese', NULL));
  END IF;
END $$;

-- Index on fase_jornada for dashboard queries
CREATE INDEX IF NOT EXISTS idx_mentorados_fase ON public.mentorados(fase_jornada);
CREATE INDEX IF NOT EXISTS idx_mentorados_cohort ON public.mentorados(cohort);
CREATE INDEX IF NOT EXISTS idx_mentorados_risco ON public.mentorados(risco_churn);

-- 2. CREATE TABLE public.marcos_mentorado
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.marcos_mentorado (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  mentorado_id integer NOT NULL REFERENCES public.mentorados(id) ON DELETE CASCADE,
  marco text NOT NULL,
  fase text NOT NULL,
  data_atingido date,
  evidencia text,
  fonte text,
  arquivo_origem text,
  confianca numeric DEFAULT 0.5 CHECK (confianca >= 0 AND confianca <= 1),
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_marcos_mentorado_id ON public.marcos_mentorado(mentorado_id);
CREATE INDEX IF NOT EXISTS idx_marcos_marco ON public.marcos_mentorado(marco);

COMMENT ON TABLE public.marcos_mentorado IS 'Marcos (milestones) atingidos por cada mentorado na jornada CASE';
COMMENT ON COLUMN public.marcos_mentorado.marco IS 'M0=Clareza Jornada, M1=Estratégia Definida, M2=Primeira Venda, M3=Primeiros Cases, M4=Vendas Consistentes, M5=Negócio Estruturado';
COMMENT ON COLUMN public.marcos_mentorado.confianca IS 'Score de confiança da extração IA (0.0 a 1.0)';

-- 3. CREATE TABLE public.analises_call
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.analises_call (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  mentorado_id integer REFERENCES public.mentorados(id) ON DELETE CASCADE,
  arquivo text NOT NULL,
  tipo_call text NOT NULL,
  data_call date,
  fase_identificada text,
  confianca_fase numeric DEFAULT 0.5,
  sub_etapas_concluidas text[] DEFAULT '{}',
  marcos_detectados text[] DEFAULT '{}',
  produto_mencionado text,
  ticket_mencionado numeric,
  vendas_mencionadas jsonb DEFAULT '{}'::jsonb,
  gargalos text[] DEFAULT '{}',
  sentimento text,
  proximos_passos text[] DEFAULT '{}',
  resumo text,
  decisoes_tomadas text[] DEFAULT '{}',
  feedbacks_consultora text[] DEFAULT '{}',
  citacoes_relevantes text[] DEFAULT '{}',
  raw_json jsonb,
  processado_em timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_analises_mentorado_id ON public.analises_call(mentorado_id);
CREATE INDEX IF NOT EXISTS idx_analises_arquivo ON public.analises_call(arquivo);
CREATE INDEX IF NOT EXISTS idx_analises_tipo ON public.analises_call(tipo_call);
CREATE INDEX IF NOT EXISTS idx_analises_data ON public.analises_call(data_call);

COMMENT ON TABLE public.analises_call IS 'Análises extraídas por IA de cada transcrição de call';
COMMENT ON COLUMN public.analises_call.tipo_call IS 'onboarding, estrategia, acompanhamento, oferta, conselho, qa, destrave, conteudo';
COMMENT ON COLUMN public.analises_call.sentimento IS 'positivo, neutro, negativo, frustrado, empolgado';

-- 4. CREATE TABLE public.fontes_raw
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.fontes_raw (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo text NOT NULL,
  subtipo text,
  nome_arquivo text NOT NULL,
  caminho_completo text,
  formato text DEFAULT 'webvtt',
  mentorado_nome text,
  mentorado_id integer REFERENCES public.mentorados(id) ON DELETE SET NULL,
  mentorados_detectados text[] DEFAULT '{}',
  data_fonte date,
  tamanho_bytes integer,
  word_count integer,
  tem_speaker_labels boolean DEFAULT false,
  processado boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_fontes_arquivo ON public.fontes_raw(nome_arquivo);
CREATE INDEX IF NOT EXISTS idx_fontes_mentorado ON public.fontes_raw(mentorado_id);
CREATE INDEX IF NOT EXISTS idx_fontes_processado ON public.fontes_raw(processado);

COMMENT ON TABLE public.fontes_raw IS 'Registro de cada arquivo-fonte processado (transcrições e exports WhatsApp)';

-- 5. CREATE TABLE public.analises_whatsapp
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.analises_whatsapp (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  mentorado_id integer NOT NULL REFERENCES public.mentorados(id) ON DELETE CASCADE,
  arquivo text NOT NULL,
  periodo_inicio date,
  periodo_fim date,
  total_mensagens integer DEFAULT 0,
  msgs_mentorado integer DEFAULT 0,
  msgs_time_case integer DEFAULT 0,
  dias_ativos integer DEFAULT 0,
  maior_gap_dias integer DEFAULT 0,
  topicos_principais text[] DEFAULT '{}',
  avancos_reportados text[] DEFAULT '{}',
  problemas_mencionados text[] DEFAULT '{}',
  vendas_mencionadas jsonb DEFAULT '{}'::jsonb,
  sentimento_geral text,
  nivel_engajamento text,
  resumo text,
  raw_json jsonb,
  processado_em timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_analises_wa_mentorado ON public.analises_whatsapp(mentorado_id);

COMMENT ON TABLE public.analises_whatsapp IS 'Análises extraídas por IA de cada export WhatsApp de grupo individual';

-- 6. UPDATE cohort N1/N2 based on group membership
-- =============================================================================

-- N1 Members
UPDATE public.mentorados SET cohort = 'N1' WHERE id IN (
  7,   -- Dra Erica Macedo
  5,   -- Raquilaine Pioli
  32,  -- Amanda Ribeiro
  47,  -- Paula/Anna (Kava)
  49,  -- Camille Bragança
  40,  -- Caroline Bittencourt
  1,   -- Danielle Ferreira
  48,  -- Gustavo Guerra
  36,  -- Hevellin Felix
  37,  -- Letícia Ambrosano
  45,  -- Letícia Oliveira
  39,  -- Maria Spindola
  41,  -- Marina Mendes
  50,  -- Miriam Alves Ferreira
  43,  -- Mônica Felici
  44,  -- Renata Aleixo
  38,  -- Tatiana Clementino
  30   -- Thielly Prado
);

-- N2 Members
UPDATE public.mentorados SET cohort = 'N2' WHERE id IN (
  9,   -- Juliana Altavilla
  2,   -- Silvane Castro
  34,  -- Karine Canabrava
  6,   -- Pablo Santos
  31,  -- Deisy Porto
  11,  -- Flávia Nantes
  33,  -- Lauanne Santos
  10,  -- Luciana Saraiva
  8    -- Rafael Castro
);

-- Tese members
UPDATE public.mentorados SET cohort = 'tese' WHERE id BETWEEN 56 AND 75;

-- Newer mentorados (Jan-Feb 2026) — cohort TBD
-- IDs: 132 (Michelle), 133 (Tayslara), 134 (Yara), 135 (Rosalie), 136 (Karina), 137 (Yara Gomes)
-- 42 (Carol Sampaio) — also newer

-- =============================================================================
-- Enable RLS policies (optional — adjust based on your frontend needs)
-- =============================================================================

ALTER TABLE public.marcos_mentorado ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analises_call ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fontes_raw ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analises_whatsapp ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read all (adjust as needed)
CREATE POLICY "Allow read access" ON public.marcos_mentorado FOR SELECT USING (true);
CREATE POLICY "Allow read access" ON public.analises_call FOR SELECT USING (true);
CREATE POLICY "Allow read access" ON public.fontes_raw FOR SELECT USING (true);
CREATE POLICY "Allow read access" ON public.analises_whatsapp FOR SELECT USING (true);

-- Allow service role full access
CREATE POLICY "Allow service role full access" ON public.marcos_mentorado FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow service role full access" ON public.analises_call FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow service role full access" ON public.fontes_raw FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow service role full access" ON public.analises_whatsapp FOR ALL USING (true) WITH CHECK (true);

-- =============================================================================
-- Done! Schema ready.
-- =============================================================================
