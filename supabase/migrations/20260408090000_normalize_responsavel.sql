-- ============================================================
-- Normalize responsavel/acompanhante to lowercase
-- Fix: "Kaique" vs "kaique", "Mariza" vs "mariza" causing
-- duplicate groups in filters and Meu Trabalho view.
--
-- Also: set emails on spalla_members for auth linking.
-- ============================================================

BEGIN;

-- 1. Normalize god_tasks.responsavel to lowercase
UPDATE god_tasks SET responsavel = lower(responsavel)
  WHERE responsavel IS NOT NULL AND responsavel <> lower(responsavel);

-- 2. Normalize god_tasks.acompanhante to lowercase
UPDATE god_tasks SET acompanhante = lower(acompanhante)
  WHERE acompanhante IS NOT NULL AND acompanhante <> lower(acompanhante);

-- 3. Normalize created_by
UPDATE god_tasks SET created_by = lower(created_by)
  WHERE created_by IS NOT NULL AND created_by <> lower(created_by);

-- 4. Set emails on spalla_members
UPDATE spalla_members SET email = 'kaique.azevedoo@outlook.com' WHERE id = 'kaique';
UPDATE spalla_members SET email = 'felipeggv@gmail.com'         WHERE id = 'gobbi';
UPDATE spalla_members SET email = 'heitor@casescale.com'        WHERE id = 'heitor';
UPDATE spalla_members SET email = 'hugo@casescale.com'          WHERE id = 'hugo';
UPDATE spalla_members SET email = 'lara@casescale.com'          WHERE id = 'lara';
UPDATE spalla_members SET email = 'mariza@casescale.com'        WHERE id = 'mariza';
UPDATE spalla_members SET email = 'queila@casescale.com'        WHERE id = 'queila';

-- 5. Consolidar "Sistema"/"sistema"/"equipe"/"" → "sistema"
UPDATE god_tasks SET responsavel = 'sistema'
  WHERE lower(responsavel) IN ('sistema', 'equipe', '');

COMMIT;
