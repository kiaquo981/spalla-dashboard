-- =====================================================
-- DS-20: Seed transcrições existentes
-- Source: BU-CASE/knowledge/team/*/transcricoes/
-- =====================================================

DO $$
DECLARE v_mid BIGINT;
BEGIN
  -- Thiago Kailer (2 transcrições — 203KB + 99KB)
  SELECT id INTO v_mid FROM "case".mentorados WHERE nome ILIKE '%Thiago Kailer%' LIMIT 1;
  IF v_mid IS NOT NULL THEN
    INSERT INTO ds_transcricoes (mentorado_id, arquivo, tipo, tamanho_kb, status)
    VALUES
      (v_mid, 'call-estrategia-2026-02-09.txt', 'estrategia', 203, 'processada'),
      (v_mid, 'onboarding-thiago-kailer.txt', 'onboarding', 99, 'processada')
    ON CONFLICT (mentorado_id, arquivo) DO NOTHING;
  END IF;

  -- Directories exist but empty (ready for future transcriptions):
  -- daniela-morais, danyella-truiz, debora-cadore, rosalie-torrelio,
  -- michelle-novelli, jordanna-diniz

  RAISE NOTICE 'Transcription seed complete';
END $$;
