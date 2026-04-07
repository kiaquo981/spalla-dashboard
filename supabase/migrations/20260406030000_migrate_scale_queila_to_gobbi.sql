-- =============================================================================
-- HOTFIX: Migrate Scale documents from revisao_queila to revisao_gobbi
-- Scale uses Rev. Gobbi, Clinic uses Rev. Queila
-- =============================================================================

-- Update all Scale mentorado documents from revisao_queila → revisao_gobbi
UPDATE ds_documentos d
SET estagio_atual = 'revisao_gobbi',
    responsavel_atual = 'Gobbi'
FROM "case".mentorados m
WHERE d.mentorado_id = m.id
  AND m.trilha = 'scale'
  AND d.estagio_atual = 'revisao_queila';
