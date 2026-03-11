-- ================================================================
-- Onboarding CS — Batch: criar trilhas para mentorados existentes
-- Responsável e status conforme planilha de controle
-- ================================================================

-- Helper: cria trilha, marca status e responsável
CREATE OR REPLACE FUNCTION _ob_batch_criar(
  p_nome_match TEXT,
  p_responsavel TEXT,
  p_status TEXT  -- 'concluido' | 'em_andamento' | 'pausado'
) RETURNS VOID AS $$
DECLARE
  v_mentorado RECORD;
  v_trilha_id UUID;
BEGIN
  SELECT id, nome INTO v_mentorado
    FROM "case".mentorados
    WHERE nome ILIKE '%' || p_nome_match || '%'
    AND NOT EXISTS (SELECT 1 FROM ob_trilhas t WHERE t.mentorado_id = "case".mentorados.id)
    LIMIT 1;

  IF v_mentorado.id IS NULL THEN
    RAISE NOTICE 'SKIP: mentorado não encontrado ou já tem trilha: %', p_nome_match;
    RETURN;
  END IF;

  v_trilha_id := ob_criar_trilha(v_mentorado.id, p_responsavel, CURRENT_DATE);

  UPDATE ob_trilhas SET status = p_status, updated_at = now() WHERE id = v_trilha_id;

  IF p_status = 'concluido' THEN
    UPDATE ob_tarefas SET status = 'concluido', data_concluida = now(), updated_at = now() WHERE trilha_id = v_trilha_id;
    UPDATE ob_etapas SET status = 'concluido' WHERE trilha_id = v_trilha_id;
  END IF;

  RAISE NOTICE 'OK: % → % (resp: %)', v_mentorado.nome, p_status, p_responsavel;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- FINALIZADOS (concluído) — sem responsável específico = Heitor
-- ================================================================
DO $$ BEGIN
  PERFORM _ob_batch_criar('Dani Ferreira',           'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Thielly Prado',            'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Karine Canabrava',         'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Amanda Ribeiro',           'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Lauanne Santos',           'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Letícia Ambrosano',        'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Caroline Bittencourt',     'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Raqui Piolli',             'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Luciana',                  'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Marina Mendes',            'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Hevellin',                 'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Maria Spindola',           'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Deyse Porto',              'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Silvane Castro',           'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Gustavo Guerra',           'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Camille Pinheiro',         'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Carolina Sampaio',         'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Mônica Felici',            'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Rafael Castro',            'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Tatiana Clementino',       'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Letícia Oliveira',         'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Renata Aleixo',            'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Miriam Alves',             'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Paula',                    'Heitor', 'concluido');  -- Paula e Anna
  PERFORM _ob_batch_criar('Juliana Altavilla',        'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Karina Cabelino',          'Heitor', 'concluido');
  PERFORM _ob_batch_criar('Erica Macedo',             'Heitor', 'concluido');
END $$;

-- FINALIZADOS — Responsável: Lara
DO $$ BEGIN
  PERFORM _ob_batch_criar('Livia Lyra',               'Lara', 'concluido');
  PERFORM _ob_batch_criar('Yara Fernandes',           'Lara', 'concluido');
  PERFORM _ob_batch_criar('Michelle Novelli',         'Lara', 'concluido');
  PERFORM _ob_batch_criar('Tayslara',                 'Lara', 'concluido');
  PERFORM _ob_batch_criar('Jordanna Diniz',           'Lara', 'concluido');
END $$;

-- CANCELADO — Pablo Santos (criar como concluído mas com nota)
DO $$ BEGIN
  PERFORM _ob_batch_criar('Pablo Santos',             'Heitor', 'concluido');
END $$;

-- ================================================================
-- EM REVISÃO / AJUSTANDO (em_andamento)
-- ================================================================
DO $$ BEGIN
  PERFORM _ob_batch_criar('Betina Franciosi',         'Heitor', 'em_andamento');
  PERFORM _ob_batch_criar('Thiago Wilson',            'Heitor', 'em_andamento');
  PERFORM _ob_batch_criar('Rosalie Matuk',            'Heitor', 'em_andamento');
END $$;

-- ================================================================
-- NÃO INICIADO (em_andamento — onboarding em curso)
-- ================================================================
DO $$ BEGIN
  PERFORM _ob_batch_criar('Daniela Morais',           'Heitor', 'em_andamento');
  PERFORM _ob_batch_criar('Danyella Truiz',           'Lara',   'em_andamento');
  PERFORM _ob_batch_criar('Juliene Frighett',         'Lara',   'em_andamento');
  PERFORM _ob_batch_criar('Lediane Lopes',            'Lara',   'em_andamento');
END $$;

-- ================================================================
-- PAUSADO
-- ================================================================
DO $$ BEGIN
  PERFORM _ob_batch_criar('Letícia Wenderoscky',      NULL,    'pausado');
END $$;

-- Cleanup: remover helper temporário
DROP FUNCTION IF EXISTS _ob_batch_criar(TEXT, TEXT, TEXT);
