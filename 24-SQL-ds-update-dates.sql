-- =====================================================
-- DOSSIÊ PRODUCTION — Update with real dates from spreadsheet
-- Run AFTER 23-SQL-ds-seed-from-static.sql
-- =====================================================

-- Helper: Update producao + doc dates by mentorado name
-- For strategic dossiers (single doc = oferta), update producao dates + doc IA date

DO $$
DECLARE
  v_mid BIGINT;
  v_pid UUID;
BEGIN

  -- ===== FINALIZADOS (Strategic dossiers) =====

  -- Dani Ferreira: call 13/08/2025, IA 07/11/2025, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Dani Ferreira%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-08-13', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2025-11-07' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Thielly Prado: call 10/10/2025, IA 27/01/2026, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Thielly%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-10-10', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-01-27' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Karine Canabrava: call 24/10/2025, IA 17/11/2025
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Karine Canabrava%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-10-24' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2025-11-17' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Amanda Ribeiro: call 23/10/2025, IA 12/11/2025, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Amanda Ribeiro%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-10-23', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2025-11-12' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Lauanne Santos: call 24/10/2025, IA 16/12/2025, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Lauanne%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-10-24', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2025-12-16' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Letícia Ambrosano: call 30/10/2025, IA 17/11/2025, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Ambrosano%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-10-30', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2025-11-17' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Caroline Bittencourt: call 07/11/2025, IA 03/12/2025, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Caroline Bittencourt%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-11-07', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2025-12-03' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Raquilaine Pioli: call 11/08/2025, IA 27/11/2025, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Raquilaine%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-08-11', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2025-11-27' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Luciana Saraiva: IA 09/12/2025, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Luciana Saraiva%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2025-12-09' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Marina Mendes: IA 27/11/2025, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Marina Mendes%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2025-11-27' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Hevellin Félix: call 20/11/2025, IA 04/12/2025
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Hevellin%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-11-20' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2025-12-04' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Maria Spindola: call 07/11/2025, IA 10/12/2025
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Maria Spindola%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-11-07' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2025-12-10' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Deyse Porto: call 16/10/2025, IA 04/12/2025
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Deyse%' OR nome ILIKE '%Deisy%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-10-16' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2025-12-04' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Silvane Castro: call 02/10/2025, IA 16/12/2025
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Silvane%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-10-02' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2025-12-16' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Gustavo Guerra: call 28/11/2025, IA 18/12/2025
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Gustavo Guerra%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-11-28' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2025-12-18' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Camille Bragança: call 28/11/2025, IA 23/12/2025
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Camille%Bragan%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-11-28' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2025-12-23' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Carolina Sampaio: call 20/11/2025, IA 06/01/2026
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Carolina Sampaio%' OR nome ILIKE '%Carol Sampaio%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-11-20' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-01-06' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Mônica Felici: call 24/11/2025, IA 07/01/2026
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%M_nica Felici%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-11-24' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-01-07' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Rafael Castro: IA 20/12/2025
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Rafael Castro%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_documentos SET data_producao_ia = '2025-12-20' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Tatiana Clementino: call 08/11/2025, IA 02/01/2026
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Tatiana Clementino%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-11-08' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-01-02' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Letícia Oliveira: call 26/11/2025, IA 07/01/2026
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Let_cia Oliveira%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-11-26' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-01-07' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Renata Aleixo: call 21/11/2025, IA 06/01/2026
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Renata Aleixo%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-11-21' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-01-06' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Miriam Alves: call 12/12/2025, IA 06/01/2026, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Miriam Alves%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-12-12', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-01-06' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Paula e Anna: call 26/11/2025, IA 05/01/2026, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Anna Plachta%' OR nome ILIKE '%Paula Groisman%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-11-26', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-01-05' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Juliana Altavilla: IA 07/01/2026, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Juliana Altavilla%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-01-07' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Pablo Santos: call 18/09/2025, IA 27/01/2026, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Pablo Santos%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2025-09-18', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-01-27' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- ===== INDIVIDUAIS COM 3 DOCS =====

  -- Livia Lyra: IA 07/01/2026, queila 14/02/2026, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Livia Lyra%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-01-07', data_revisao_queila = '2026-02-14' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- Yara Gomes: call 29/01/2026, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Yara Gomes%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2026-01-29', contrato_assinado = 'sim' WHERE id = v_pid;
    -- Oferta
    UPDATE ds_documentos SET data_producao_ia = '2026-02-05', data_revisao_mariza = '2026-02-06', data_revisao_kaique = '2026-02-13', data_revisao_queila = '2026-02-13'
    WHERE producao_id = v_pid AND tipo = 'oferta';
    -- Funil
    UPDATE ds_documentos SET data_producao_ia = '2026-02-05', data_revisao_mariza = '2026-02-06', data_revisao_kaique = '2026-02-13', data_revisao_queila = '2026-02-13'
    WHERE producao_id = v_pid AND tipo = 'funil';
    -- Conteudo
    UPDATE ds_documentos SET data_producao_ia = '2026-02-05', data_revisao_mariza = '2026-02-06', data_revisao_kaique = '2026-02-13', data_revisao_queila = '2026-02-13'
    WHERE producao_id = v_pid AND tipo = 'conteudo';
  END IF;

  -- Michelle Novelli: call 26/01/2026, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Michelle Novelli%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2026-01-26', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-02-05', data_revisao_mariza = '2026-02-06', data_revisao_kaique = '2026-02-13', data_revisao_queila = '2026-02-14', data_envio = '2026-02-14'
    WHERE producao_id = v_pid AND tipo = 'oferta';
    UPDATE ds_documentos SET data_producao_ia = '2026-02-08', data_revisao_mariza = '2026-02-10', data_revisao_kaique = '2026-02-13', data_revisao_queila = '2026-02-14', data_envio = '2026-02-14'
    WHERE producao_id = v_pid AND tipo = 'funil';
    UPDATE ds_documentos SET data_producao_ia = '2026-02-08', data_revisao_mariza = '2026-02-10', data_revisao_kaique = '2026-02-13', data_revisao_queila = '2026-02-14', data_envio = '2026-02-14'
    WHERE producao_id = v_pid AND tipo = 'conteudo';
  END IF;

  -- Tayslara Belarmino: call 28/01/2026, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Tayslara%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2026-01-28', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-02-06', data_revisao_mariza = '2026-02-07', data_revisao_kaique = '2026-02-13', data_revisao_queila = '2026-02-14', data_envio = '2026-02-14'
    WHERE producao_id = v_pid AND tipo = 'oferta';
    UPDATE ds_documentos SET data_producao_ia = '2026-02-10', data_revisao_mariza = '2026-02-11', data_revisao_kaique = '2026-02-13', data_revisao_queila = '2026-02-14', data_envio = '2026-02-14'
    WHERE producao_id = v_pid AND tipo = 'funil';
    UPDATE ds_documentos SET data_producao_ia = '2026-02-10', data_revisao_mariza = '2026-02-11', data_revisao_kaique = '2026-02-13', data_revisao_queila = '2026-02-14', data_envio = '2026-02-14'
    WHERE producao_id = v_pid AND tipo = 'conteudo';
  END IF;

  -- Karina Cabelino: call 04/02/2026, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Karina Cabelino%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2026-02-04', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-02-12', data_revisao_mariza = '2026-02-13', data_revisao_kaique = '2026-02-13', data_revisao_queila = '2026-02-14', data_envio = '2026-02-14'
    WHERE producao_id = v_pid AND tipo = 'oferta';
    UPDATE ds_documentos SET data_producao_ia = '2026-02-12', data_revisao_mariza = '2026-02-13', data_revisao_kaique = '2026-02-13', data_revisao_queila = '2026-02-16', data_envio = '2026-02-18'
    WHERE producao_id = v_pid AND tipo = 'funil';
    UPDATE ds_documentos SET data_producao_ia = '2026-02-12', data_revisao_mariza = '2026-02-14', data_revisao_kaique = '2026-02-14', data_revisao_queila = '2026-02-16', data_envio = '2026-02-18'
    WHERE producao_id = v_pid AND tipo = 'conteudo';
  END IF;

  -- Érica Macedo: IA 24/02/2026, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%_rica Macedo%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-02-24' WHERE producao_id = v_pid AND tipo = 'oferta';
  END IF;

  -- ===== EM REVISÃO =====

  -- Betina Franciosi: call 13/02/2026, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Betina%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2026-02-13', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-02-23', data_revisao_mariza = '2026-03-02'
    WHERE producao_id = v_pid AND tipo = 'oferta';
    UPDATE ds_documentos SET data_producao_ia = '2026-02-24', data_revisao_mariza = '2026-03-03'
    WHERE producao_id = v_pid AND tipo = 'funil';
    UPDATE ds_documentos SET data_producao_ia = '2026-02-24', data_revisao_mariza = '2026-03-04'
    WHERE producao_id = v_pid AND tipo = 'conteudo';
  END IF;

  -- Thiago Kailer: call 09/02/2026, contrato sim
  -- Mariza revisou 06/03, Kaique 25/02
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Thiago Kailer%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2026-02-09', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-02-13', data_revisao_mariza = '2026-03-06', data_revisao_kaique = '2026-02-25'
    WHERE producao_id = v_pid AND tipo = 'oferta';
    UPDATE ds_documentos SET data_producao_ia = '2026-02-20', data_revisao_mariza = '2026-03-06', data_revisao_kaique = '2026-02-25'
    WHERE producao_id = v_pid AND tipo = 'funil';
    UPDATE ds_documentos SET data_producao_ia = '2026-02-20', data_revisao_mariza = '2026-03-06', data_revisao_kaique = '2026-02-25'
    WHERE producao_id = v_pid AND tipo = 'conteudo';
  END IF;

  -- Rosalie Torrelio: call 03/02/2026, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Rosalie%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2026-02-03', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-02-23', data_revisao_kaique = '2026-03-02'
    WHERE producao_id = v_pid AND tipo = 'oferta';
    UPDATE ds_documentos SET data_producao_ia = '2026-02-23', data_revisao_kaique = '2026-03-02'
    WHERE producao_id = v_pid AND tipo = 'funil';
    UPDATE ds_documentos SET data_producao_ia = '2026-02-22', data_revisao_kaique = '2026-03-02'
    WHERE producao_id = v_pid AND tipo = 'conteudo';
  END IF;

  -- Jordanna Diniz: call 10/02/2026, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Jordanna%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_estrategia = '2026-02-10', contrato_assinado = 'sim' WHERE id = v_pid;
    UPDATE ds_documentos SET data_producao_ia = '2026-02-18', data_revisao_mariza = '2026-02-28', data_revisao_kaique = '2026-02-20', data_revisao_queila = '2026-02-23'
    WHERE producao_id = v_pid AND tipo = 'oferta';
    UPDATE ds_documentos SET data_producao_ia = '2026-02-19', data_revisao_mariza = '2026-02-28', data_revisao_kaique = '2026-02-20'
    WHERE producao_id = v_pid AND tipo = 'funil';
    UPDATE ds_documentos SET data_producao_ia = '2026-02-19', data_revisao_mariza = '2026-02-28', data_revisao_kaique = '2026-02-20'
    WHERE producao_id = v_pid AND tipo = 'conteudo';
  END IF;

  -- ===== NÃO INICIADO / PRODUÇÃO =====

  -- Daniela Morais: contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Daniela Morais%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    UPDATE ds_producoes SET contrato_assinado = 'sim' WHERE mentorado_id = v_mid;
  END IF;

  -- Danyella Truiz: onboarding 23/02, contrato sim
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Danyella Truiz%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    SELECT id INTO v_pid FROM ds_producoes WHERE mentorado_id = v_mid;
    UPDATE ds_producoes SET data_call_onboarding = '2026-02-23', contrato_assinado = 'sim' WHERE id = v_pid;
    -- IA dates already set in seed
  END IF;

  -- Juliene Frighetto: call 10/03/2026
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Juliene%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    UPDATE ds_producoes SET data_call_estrategia = '2026-03-10' WHERE mentorado_id = v_mid;
  END IF;

  -- Jordanna already handled above

  -- Letícia Wenderoscky: contrato não
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Wenderoscky%' OR nome ILIKE '%Wenderosck%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    UPDATE ds_producoes SET contrato_assinado = 'nao' WHERE mentorado_id = v_mid;
  END IF;

  RAISE NOTICE 'Date update complete!';

END $$;
