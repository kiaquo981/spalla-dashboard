-- ============================================================
-- FIX IMEDIATO — Correcoes de dados CASE
-- Data: 2026-02-16
-- EXECUTAR NO SQL EDITOR DO SUPABASE
-- ============================================================

-- ============================================================
-- 1. CORRIGIR grupo_whatsapp_id ERRADOS (4 mentorados)
-- Os IDs atuais foram criados pelo import manual de ZIPs
-- Os IDs corretos vem da Evolution API (WhatsApp real)
-- ============================================================

-- Michelle Novelli (id=132)
-- DB atual: 12036302e259a88b66@g.us (FALSO)
-- Evolution: 120363423109346723@g.us ([Case] Michelle Novelli)
UPDATE mentorados
SET grupo_whatsapp_id = '120363423109346723@g.us'
WHERE id = 132;

-- Tayslara Belarmino (id=133)
-- DB atual: 1203635299ed680d76@g.us (FALSO)
-- Evolution: 120363423263106612@g.us ([Case] Tayslara Belarmino)
UPDATE mentorados
SET grupo_whatsapp_id = '120363423263106612@g.us'
WHERE id = 133;

-- Rosalie Torrelio (id=135)
-- DB atual: 56ae5122543cfe6a9eef2c67dca20008 (FALSO - formato nem e WhatsApp)
-- Evolution: 120363405618429117@g.us ([Case] Rosalie Torrelio)
UPDATE mentorados
SET grupo_whatsapp_id = '120363405618429117@g.us'
WHERE id = 135;

-- Karina Cabelino (id=136)
-- DB atual: 120363e039bc8e58ef@g.us (FALSO)
-- Evolution: 120363422678267967@g.us ([Case] Dra. Karina Cabelino)
UPDATE mentorados
SET grupo_whatsapp_id = '120363422678267967@g.us'
WHERE id = 136;

-- ============================================================
-- 2. VINCULAR grupos que existem na Evolution mas nao no DB
-- ============================================================

-- Betina Franciosi (id=145) — grupo existe na Evolution
UPDATE mentorados
SET grupo_whatsapp_id = '120363423537756907@g.us'
WHERE id = 145;

-- Daniela Morais (id=146) — grupo existe na Evolution
UPDATE mentorados
SET grupo_whatsapp_id = '120363407759892012@g.us'
WHERE id = 146;

-- ============================================================
-- 3. INATIVAR Marina Mendes (pediu reembolso)
-- ============================================================

UPDATE mentorados
SET ativo = false
WHERE id = 41;

-- ============================================================
-- VERIFICACAO
-- ============================================================

SELECT id, nome, grupo_whatsapp_id, ativo
FROM mentorados
WHERE id IN (132, 133, 135, 136, 145, 146, 41)
ORDER BY id;
