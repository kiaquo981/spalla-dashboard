-- ================================================================
-- UPDATE mentorados — Dados extraídos do grupo comercial WhatsApp
-- Fonte: Marcos (Closer) reporta vendas no grupo "CASE Mentory - Comercial"
-- Consultado Supabase em 2026-03-12 para NÃO sobrescrever dados existentes
-- ================================================================

-- 152 | Daniela Morais — já tem email, telefone, instagram. Falta: contrato
UPDATE mentorados SET
  contrato_assinado = true
WHERE id = 152;

-- 151 | Danyella Truiz — já tem email, telefone, instagram. Falta: contrato, cidade/estado
UPDATE mentorados SET
  contrato_assinado = true,
  cidade = 'Umuarama',
  estado = 'PR'
WHERE id = 151;

-- 165 | Débora Cadore — já tem email, telefone, instagram. Falta: contrato, cidade/estado, nicho
UPDATE mentorados SET
  contrato_assinado = true,
  cidade = 'Florianópolis',
  estado = 'SC'
WHERE id = 165;

-- 168 | Dentine - Lediane e Rafael — falta: instagram, email, nicho, cidade/estado, contrato
UPDATE mentorados SET
  instagram = 'dentineodonto',
  email = 'ledianesantana@yahoo.com.br',
  nicho = 'Odontologia',
  contrato_assinado = true
WHERE id = 168;

-- 167 | Josiane Barcelos — falta: instagram, email, telefone (PENDENTE), cidade/estado, nicho, contrato
UPDATE mentorados SET
  instagram = 'drajosianebarcelos',
  email = 'barcelos_josiane@hotmail.com',
  telefone = '5522998692587',
  cidade = 'Nova Friburgo',
  estado = 'RJ',
  contrato_assinado = true
WHERE id = 167;

-- 166 | Juliene Frighetto — já tem email, telefone, instagram. Falta: contrato, cidade
UPDATE mentorados SET
  contrato_assinado = true
WHERE id = 166;

-- 139 | Michelle Novelli Yoshiy — já tem tudo. Falta: contrato
UPDATE mentorados SET
  contrato_assinado = true
WHERE id = 139;

-- 172 | Vânia de Paula — já tem email, telefone, instagram. Falta: contrato, cidade/estado
UPDATE mentorados SET
  contrato_assinado = true,
  cidade = 'Goiânia',
  estado = 'GO'
WHERE id = 172;

-- ================================================================
-- VERIFICAÇÃO
-- ================================================================
SELECT id, nome, instagram, email, telefone, contrato_assinado, cidade, estado
FROM mentorados
WHERE id IN (152, 151, 165, 168, 167, 166, 139, 172)
ORDER BY nome;
