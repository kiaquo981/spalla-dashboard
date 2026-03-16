-- =====================================================
-- DOSSIÊ PRODUCTION SYSTEM — Seed from static data
-- Maps DOSSIER_PIPELINE (12-APP-data.js) → ds_* tables
-- Run AFTER 22-SQL-ds-schema.sql
-- =====================================================

DO $$
DECLARE
  v_mid BIGINT;
  v_pid UUID;
  v_did UUID;
  v_status TEXT;
  v_estagio TEXT;
  v_responsavel TEXT;
BEGIN

  -- ===== HELPER: Parse DD/MM/YYYY to DATE =====
  -- We'll use inline CASE for each entry

  -- =========================================================
  -- GROUP 1: Strategic dossiers (single doc, all enviado)
  -- These mentorados already went through the old flow.
  -- We create a producao with status=finalizado and 1 doc type='oferta' at finalizado
  -- =========================================================

  -- Dani Ferreira
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Dani Ferreira%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dani Ferreira | Dossiê Estratégico', 'finalizado', null, '2025-11-07', '2025-11-07', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração: dossiê estratégico enviado');
  END IF;

  -- Thielly Prado
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Thielly%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Thielly Prado | Dossiê Estratégico', 'finalizado', '2026-01-27', '2026-01-27', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração: dossiê estratégico enviado');
  END IF;

  -- Karine Canabrava
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Karine Canabrava%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Karine Canabrava | Dossiê Estratégico', 'finalizado', '2025-11-17', '2025-11-17', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração: dossiê estratégico enviado');
  END IF;

  -- Amanda Ribeiro
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Amanda Ribeiro%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Amanda Ribeiro | Dossiê Estratégico', 'finalizado', '2025-11-12', '2025-11-12', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Lauanne Santos
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Lauanne%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Lauanne Santos | Dossiê Estratégico', 'finalizado', '2025-12-16', '2025-12-16', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Letícia Ambrosano
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Ambrosano%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Letícia Ambrosano | Dossiê Estratégico', 'finalizado', '2025-11-17', '2025-11-17', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Caroline Bittencourt
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Caroline Bittencourt%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Caroline Bittencourt | Dossiê Estratégico', 'finalizado', '2025-12-03', '2025-12-03', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Raquilaine Pioli
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Raquilaine%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Raquilaine Pioli | Dossiê Estratégico', 'finalizado', '2025-11-27', '2025-11-27', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Luciana Saraiva
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Luciana Saraiva%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Luciana Saraiva | Dossiê Estratégico', 'finalizado', '2025-12-09', '2025-12-09', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Marina Mendes
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Marina Mendes%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Marina Mendes | Dossiê Estratégico', 'finalizado', '2025-11-27', '2025-11-27', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Hevellin Félix
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Hevellin%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Hevellin Felix | Dossiê Estratégico', 'finalizado', '2025-12-04', '2025-12-04', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Maria Spindola
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Maria Spindola%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Maria Spindola | Dossiê Estratégico', 'finalizado', '2025-12-10', '2025-12-10', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Deyse Porto
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Deyse%' OR nome ILIKE '%Deisy%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Deisy Porto | Dossiê Estratégico', 'finalizado', '2025-12-04', '2025-12-04', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Silvane Castro
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Silvane%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Silvane Castro | Dossiê Estratégico', 'finalizado', '2025-12-16', '2025-12-16', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Gustavo Guerra
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Gustavo Guerra%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Gustavo Guerra | Dossiê Estratégico', 'finalizado', '2025-12-18', '2025-12-18', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Camille Bragança
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Camille%Bragan%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Camille Bragança | Dossiê Estratégico', 'finalizado', '2025-12-23', '2025-12-23', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Carolina Sampaio
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Carolina Sampaio%' OR nome ILIKE '%Carol Sampaio%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dossiê Estratégico | Carol Sampaio', 'finalizado', '2026-01-06', '2026-01-06', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Mônica Felici
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%M_nica Felici%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Mônica Felici | Dossiê Estratégico', 'finalizado', '2026-01-07', '2026-01-07', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Rafael Castro
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Rafael Castro%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Rafael Castro | Dossiê Estratégico', 'finalizado', '2025-12-20', '2025-12-20', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Tatiana Clementino
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Tatiana Clementino%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Tatiana Clementino | Dossiê Estratégico', 'finalizado', '2026-01-02', '2026-01-02', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Letícia Oliveira
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Let_cia Oliveira%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Letícia Oliveira | Dossiê Estratégico', 'finalizado', '2026-01-07', '2026-01-07', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Renata Aleixo
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Renata Aleixo%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Renata Aleixo & Rodrigo Moura | Dossiê Estratégico', 'finalizado', '2026-01-06', '2026-01-06', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Miriam Alves
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Miriam Alves%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Miriam Alves Ferreira Velho | Dossiê Estratégico', 'finalizado', '2026-01-06', '2026-01-06', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Paula Groisman e Anna Plachta
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Anna Plachta%' OR nome ILIKE '%Paula Groisman%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Anna Plachta e Paula Groisman | Dossiê Estratégico', 'finalizado', '2026-01-05', '2026-01-05', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Juliana Altavilla
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Juliana Altavilla%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Juliana Altavilla | Dossiê Estratégico', 'finalizado', '2026-01-07', '2026-01-07', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Pablo Santos (cancelado)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Pablo Santos%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'cancelado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Pablo Santos | Dossiê Estratégico', 'finalizado', '2026-01-27', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'cancelado', 'seed', 'Migração: cancelado');
  END IF;

  -- =========================================================
  -- GROUP 2: Individual dossiers with 3 docs (new format)
  -- =========================================================

  -- Livia Lyra (enviado, single estrategico doc)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Livia Lyra%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_producao_ia, data_revisao_queila, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Livia Lyra | Dossiê Estratégico', 'finalizado', '2026-01-06', '2026-02-14', '2026-02-14', '2026-02-14', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- Yara Gomes (aprovado_enviar → all 3 docs reviewed)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Yara Gomes%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'aprovado', 'Lara', 'seed') RETURNING id INTO v_pid;
    -- Oferta
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, data_revisao_mariza, data_revisao_kaique, data_revisao_queila, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dossiê Oferta e Produto - Yara Gomes', 'aprovado', null, '2026-02-05', '2026-02-06', '2026-02-13', '2026-02-13', '2026-02-13', 1);
    -- Funil
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, data_revisao_mariza, data_revisao_kaique, data_revisao_queila, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'funil', 'Dossiê Funil de Vendas - Yara Gomes', 'aprovado', null, '2026-02-05', '2026-02-06', '2026-02-13', '2026-02-13', '2026-02-13', 2);
    -- Conteudo
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, data_revisao_mariza, data_revisao_kaique, data_revisao_queila, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'conteudo', 'Dossiê Posicionamento e Conteúdo - Yara Gomes', 'aprovado', null, '2026-02-05', '2026-02-06', '2026-02-13', '2026-02-13', '2026-02-13', 3);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'aprovado', 'seed', 'Migração: 3 docs aprovados');
  END IF;

  -- Michelle Novelli (enviado, 3 docs)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Michelle Novelli%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'enviado', 'Lara', 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_producao_ia, data_revisao_kaique, data_revisao_queila, data_envio, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dossiê Oferta e Produto - Michelle Novelli Yoshiy', 'enviado', '2026-02-06', '2026-02-13', '2026-02-14', '2026-02-14', '2026-02-14', 1);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_producao_ia, data_revisao_kaique, data_revisao_queila, data_envio, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'funil', 'Dossiê Funil de Vendas - Michelle Novelli Yoshiy', 'enviado', '2026-02-10', '2026-02-13', '2026-02-14', '2026-02-14', '2026-02-14', 2);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_producao_ia, data_revisao_kaique, data_revisao_queila, data_envio, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'conteudo', 'Dossiê Posicionamento e Conteúdo - Michelle Novelli Yoshiy', 'enviado', '2026-02-10', '2026-02-13', '2026-02-14', '2026-02-14', '2026-02-14', 3);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'enviado', 'seed', 'Migração: 3 docs enviados');
  END IF;

  -- Tayslara Belarmino (enviado, 3 docs)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Tayslara%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'enviado', 'Lara', 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_producao_ia, data_revisao_kaique, data_revisao_queila, data_envio, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dossiê Oferta e Produto - Dra. Tayslara Belarmino', 'enviado', '2026-02-07', '2026-02-13', '2026-02-14', '2026-02-14', '2026-02-14', 1);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_producao_ia, data_revisao_kaique, data_revisao_queila, data_envio, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'funil', 'Dossiê Funil de Vendas - Dra. Tayslara Belarmino', 'enviado', '2026-02-11', '2026-02-13', '2026-02-14', '2026-02-14', '2026-02-14', 2);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_producao_ia, data_revisao_kaique, data_revisao_queila, data_envio, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'conteudo', 'Dossiê Posicionamento e Conteúdo - Dra. Tayslara Belarmino', 'enviado', '2026-02-11', '2026-02-13', '2026-02-14', '2026-02-14', '2026-02-14', 3);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'enviado', 'seed', 'Migração: 3 docs enviados');
  END IF;

  -- Karina Cabelino (enviado, 3 docs com data_envio)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Karina Cabelino%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'enviado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_producao_ia, data_revisao_mariza, data_revisao_kaique, data_revisao_queila, data_envio, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dossiê Oferta e Produto - Karina Cabelino', 'enviado', '2026-02-12', '2026-02-13', '2026-02-13', '2026-02-14', '2026-02-14', '2026-02-14', 1);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_producao_ia, data_revisao_mariza, data_revisao_kaique, data_revisao_queila, data_envio, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'funil', 'Dossiê Funil de Vendas - Karina Cabelino', 'enviado', '2026-02-12', '2026-02-13', '2026-02-14', '2026-02-16', '2026-02-18', '2026-02-18', 2);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_producao_ia, data_revisao_mariza, data_revisao_kaique, data_revisao_queila, data_envio, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'conteudo', 'Dossiê Posicionamento e Conteúdo - Karina Cabelino', 'enviado', '2026-02-12', '2026-02-14', '2026-02-14', '2026-02-16', '2026-02-18', '2026-02-18', 3);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'enviado', 'seed', 'Migração: 3 docs enviados');
  END IF;

  -- Érica Macedo (enviado, single estrategico)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%_rica Macedo%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'finalizado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_producao_ia, data_finalizado, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dossiê Estratégico - Érica Macedo', 'finalizado', '2026-02-24', '2026-02-24', '2026-02-24', 1);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'finalizado', 'seed', 'Migração');
  END IF;

  -- =========================================================
  -- GROUP 3: In review (3 docs each)
  -- =========================================================

  -- Betina Franciosi (revisao_kaique)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Betina%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'revisao', 'Kaique', 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, data_revisao_mariza, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dossiê Oferta e Produto - Dra. Betina Franciosi', 'revisao_kaique', 'Kaique', '2026-02-23', '2026-03-02', '2026-03-02', 1);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, data_revisao_mariza, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'funil', 'Dossiê Funil de Vendas - Dra. Betina Franciosi', 'revisao_kaique', 'Kaique', '2026-02-24', '2026-03-03', '2026-03-03', 2);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, data_revisao_mariza, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'conteudo', 'Dossiê de Posicionamento e Conteúdo - Betina Franciosi', 'revisao_kaique', 'Kaique', '2026-02-24', '2026-03-04', '2026-03-04', 3);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'revisao_kaique', 'seed', 'Migração: em revisão Kaique');
  END IF;

  -- Jordanna Diniz (aprovado_enviar → mixed stages)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Jordanna%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'revisao', 'Lara', 'seed') RETURNING id INTO v_pid;
    -- Oferta: all reviews done
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, data_producao_ia, data_revisao_kaique, data_revisao_queila, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dossiê Oferta e Produto - Jordanna Diniz', 'aprovado', '2026-02-20', '2026-02-20', '2026-02-23', '2026-02-23', 1);
    -- Funil: only kaique review
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, data_revisao_kaique, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'funil', 'Dossiê Funil de Vendas - Jordanna Diniz', 'revisao_queila', 'Queila', '2026-02-21', '2026-02-20', '2026-02-20', 2);
    -- Conteudo: only kaique review
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, data_revisao_kaique, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'conteudo', 'Dossiê Posicionamento e Conteúdo - Jordanna Diniz', 'revisao_queila', 'Queila', '2026-02-21', '2026-02-20', '2026-02-20', 3);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'revisao', 'seed', 'Migração: mix de estágios');
  END IF;

  -- Thiago Kailer (revisao_queila)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Thiago Kailer%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'revisao', 'Queila', 'seed') RETURNING id INTO v_pid;
    -- Oferta: up to kaique
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, data_revisao_mariza, data_revisao_kaique, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dossiê Oferta e Produto - Thiago Kailer', 'revisao_queila', 'Queila', '2026-02-13', '2026-02-18', '2026-02-25', '2026-02-25', 1);
    -- Funil: only AI
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'funil', 'Dossiê Funil de Vendas - Thiago Kailer', 'revisao_mariza', 'Mariza', '2026-02-20', '2026-02-20', 2);
    -- Conteudo: only AI
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'conteudo', 'Dossiê de Posicionamento - Thiago Kailer', 'revisao_mariza', 'Mariza', '2026-02-20', '2026-02-20', 3);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'revisao', 'seed', 'Migração: mix de estágios');
  END IF;

  -- Rosalie Torrelio (revisao_mariza — was sent back)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Rosalie%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'revisao', 'Mariza', 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, data_revisao_kaique, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dossiê Oferta e Produto - Rosalie Torrelio', 'revisao_mariza', 'Mariza', '2026-02-23', '2026-03-02', '2026-03-02', 1);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, data_revisao_kaique, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'funil', 'Dossiê Funil de Vendas - Rosalie Torrelio', 'revisao_mariza', 'Mariza', '2026-02-23', '2026-03-02', '2026-03-02', 2);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, data_revisao_kaique, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'conteudo', 'Dossiê Posicionamento e Conteúdo - Rosalie Torrelio', 'revisao_mariza', 'Mariza', '2026-02-22', '2026-03-02', '2026-03-02', 3);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'revisao_mariza', 'seed', 'Migração: retornou para Mariza após revisão Kaique');
  END IF;

  -- =========================================================
  -- GROUP 4: Produção / Não iniciado
  -- =========================================================

  -- Daniela Morais (onboarding — no docs yet)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Daniela Morais%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'nao_iniciado', 'Heitor', 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dossiê Oferta e Produto - Daniela Morais', 'pendente', null, now(), 1);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'funil', 'Dossiê Funil de Vendas - Daniela Morais', 'pendente', null, now(), 2);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'conteudo', 'Dossiê Posicionamento e Conteúdo - Daniela Morais', 'pendente', null, now(), 3);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'nao_iniciado', 'seed', 'Migração: onboarding');
  END IF;

  -- Danyella Truiz (producao_ia, 3 docs with AI dates)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Danyella Truiz%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, data_call_onboarding, created_by)
    VALUES (v_mid, 'producao', 'Lara', '2026-02-23', 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dossiê Oferta e Produto - Danyella Truiz', 'revisao_mariza', 'Mariza', '2026-03-04', '2026-03-04', 1);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'funil', 'Dossiê Funil de Vendas - Danyella Truiz', 'revisao_mariza', 'Mariza', '2026-03-04', '2026-03-04', 2);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, data_producao_ia, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'conteudo', 'Dossiê Posicionamento e Conteúdo - Danyella Truiz', 'revisao_mariza', 'Mariza', '2026-03-04', '2026-03-04', 3);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'producao', 'seed', 'Migração: produção IA completa, aguardando revisão');
  END IF;

  -- Juliene Frighetoo (pendente_contrato, call 10/03)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Juliene%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, data_call_estrategia, contrato_assinado, created_by)
    VALUES (v_mid, 'call_estrategia', 'Lara', '2026-03-10', 'pendente', 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dossiê Oferta e Produto - Juliene Frighetto', 'pendente', now(), 1);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'funil', 'Dossiê Funil de Vendas - Juliene Frighetto', 'pendente', now(), 2);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'conteudo', 'Dossiê Posicionamento e Conteúdo - Juliene Frighetto', 'pendente', now(), 3);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'call_estrategia', 'seed', 'Migração: pendente contrato');
  END IF;

  -- Lediane Lopes (call_estrategia)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Lediane%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'call_estrategia', 'Lara', 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dossiê Oferta e Produto - Lediane Lopes', 'pendente', now(), 1);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'funil', 'Dossiê Funil de Vendas - Lediane Lopes', 'pendente', now(), 2);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'conteudo', 'Dossiê Posicionamento e Conteúdo - Lediane Lopes', 'pendente', now(), 3);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'call_estrategia', 'seed', 'Migração: aguardando call estratégia');
  END IF;

  -- Letícia Wenderoscky (pausado)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Wenderoscky%' OR nome ILIKE '%Wenderosck%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_producoes (mentorado_id, status, responsavel_atual, created_by)
    VALUES (v_mid, 'pausado', null, 'seed') RETURNING id INTO v_pid;
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'oferta', 'Dossiê Oferta e Produto - Letícia Wenderoscky', 'pendente', now(), 1);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'funil', 'Dossiê Funil de Vendas - Letícia Wenderoscky', 'pendente', now(), 2);
    INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, estagio_desde, ordem)
    VALUES (v_pid, v_mid, 'conteudo', 'Dossiê Posicionamento e Conteúdo - Letícia Wenderoscky', 'pendente', now(), 3);
    INSERT INTO ds_eventos (producao_id, mentorado_id, tipo_evento, para_valor, responsavel, descricao)
    VALUES (v_pid, v_mid, 'estagio_change', 'pausado', 'seed', 'Migração: pausado');
  END IF;

  RAISE NOTICE 'Seed migration complete!';

END $$;
