-- =====================================================
-- Refresh public.mentorados view
-- Picks up: motivo_inativacao, data_inativacao, obs_inativacao
-- added in 20260324180000_add_offboard_fields
-- =====================================================

CREATE OR REPLACE VIEW public.mentorados AS
    SELECT * FROM "case".mentorados;
