-- ================================================================
-- Onboarding CS — Schema
-- Tables: ob_template_etapas, ob_template_tarefas, ob_trilhas, ob_etapas, ob_tarefas
-- Function: ob_criar_trilha()
-- View: vw_ob_pipeline
-- ================================================================

-- 1) Template de etapas (editável pelo CS)
CREATE TABLE ob_template_etapas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome TEXT NOT NULL,
  tipo TEXT NOT NULL DEFAULT 'sequencial',  -- 'sequencial' | 'paralelo'
  ordem INT NOT NULL,
  cor TEXT DEFAULT '#6b7280',
  icone TEXT DEFAULT '📋',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2) Tarefas do template
CREATE TABLE ob_template_tarefas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  etapa_id UUID REFERENCES ob_template_etapas(id) ON DELETE CASCADE,
  descricao TEXT NOT NULL,
  responsavel_padrao TEXT,        -- 'Lara', 'Heitor', 'CS', 'Financeiro', etc.
  prazo_dias INT DEFAULT 0,       -- D+N (offset from onboarding start)
  ordem INT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3) Trilhas (1 por mentorado)
CREATE TABLE ob_trilhas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  mentorado_id BIGINT REFERENCES "case".mentorados(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'em_andamento',  -- em_andamento | concluido | pausado
  data_inicio DATE DEFAULT CURRENT_DATE,
  responsavel TEXT,                     -- CS principal (Lara ou Heitor)
  notas TEXT,
  created_by TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(mentorado_id)
);

-- 4) Etapas instanciadas por trilha
CREATE TABLE ob_etapas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  trilha_id UUID REFERENCES ob_trilhas(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  tipo TEXT NOT NULL DEFAULT 'sequencial',
  ordem INT NOT NULL,
  cor TEXT,
  icone TEXT,
  status TEXT DEFAULT 'pendente',  -- pendente | em_andamento | concluido
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5) Tarefas instanciadas por etapa
CREATE TABLE ob_tarefas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  etapa_id UUID REFERENCES ob_etapas(id) ON DELETE CASCADE,
  trilha_id UUID REFERENCES ob_trilhas(id) ON DELETE CASCADE,
  mentorado_id BIGINT,
  descricao TEXT NOT NULL,
  responsavel TEXT,
  prazo_dias INT DEFAULT 0,
  data_prevista DATE,              -- calculada: trilha.data_inicio + prazo_dias
  data_concluida TIMESTAMPTZ,
  status TEXT DEFAULT 'pendente',  -- pendente | concluido
  ordem INT NOT NULL,
  notas TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ================================================================
-- Function: ob_criar_trilha()
-- Cria uma trilha para um mentorado, copiando o template atual
-- ================================================================
CREATE OR REPLACE FUNCTION ob_criar_trilha(
  p_mentorado_id BIGINT,
  p_responsavel TEXT DEFAULT NULL,
  p_data_inicio DATE DEFAULT CURRENT_DATE
) RETURNS UUID AS $$
DECLARE
  v_trilha_id UUID;
  v_etapa_id UUID;
  rec_etapa RECORD;
  rec_tarefa RECORD;
BEGIN
  INSERT INTO ob_trilhas (mentorado_id, responsavel, data_inicio)
  VALUES (p_mentorado_id, p_responsavel, p_data_inicio)
  RETURNING id INTO v_trilha_id;

  FOR rec_etapa IN SELECT * FROM ob_template_etapas ORDER BY ordem LOOP
    INSERT INTO ob_etapas (trilha_id, nome, tipo, ordem, cor, icone)
    VALUES (v_trilha_id, rec_etapa.nome, rec_etapa.tipo, rec_etapa.ordem, rec_etapa.cor, rec_etapa.icone)
    RETURNING id INTO v_etapa_id;

    FOR rec_tarefa IN SELECT * FROM ob_template_tarefas WHERE etapa_id = rec_etapa.id ORDER BY ordem LOOP
      INSERT INTO ob_tarefas (etapa_id, trilha_id, mentorado_id, descricao, responsavel, prazo_dias, data_prevista, ordem)
      VALUES (v_etapa_id, v_trilha_id, p_mentorado_id, rec_tarefa.descricao,
              COALESCE(p_responsavel, rec_tarefa.responsavel_padrao),
              rec_tarefa.prazo_dias,
              p_data_inicio + rec_tarefa.prazo_dias,
              rec_tarefa.ordem);
    END LOOP;
  END LOOP;

  RETURN v_trilha_id;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- View: vw_ob_pipeline
-- ================================================================
CREATE OR REPLACE VIEW vw_ob_pipeline AS
SELECT
  t.id AS trilha_id,
  t.mentorado_id,
  m.nome AS mentorado_nome,
  t.status,
  t.responsavel,
  t.data_inicio,
  t.notas,
  t.created_at,
  COUNT(ta.id) AS total_tarefas,
  COUNT(ta.id) FILTER (WHERE ta.status = 'concluido') AS tarefas_concluidas,
  ROUND(COUNT(ta.id) FILTER (WHERE ta.status = 'concluido')::NUMERIC / NULLIF(COUNT(ta.id), 0) * 100) AS progresso_pct,
  COUNT(ta.id) FILTER (WHERE ta.status = 'pendente' AND ta.data_prevista < CURRENT_DATE) AS tarefas_atrasadas,
  MIN(ta.data_prevista) FILTER (WHERE ta.status = 'pendente') AS proxima_tarefa_data
FROM ob_trilhas t
JOIN "case".mentorados m ON m.id = t.mentorado_id
LEFT JOIN ob_tarefas ta ON ta.trilha_id = t.id
GROUP BY t.id, m.nome;
