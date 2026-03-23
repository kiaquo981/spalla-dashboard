-- ================================================================
-- Fix: tasks de produto/processo atribuídas a heitor → gobbi
-- Heitor = consultor/CS apenas. Produto, processos, manuais = Gobbi.
-- ================================================================

UPDATE public.god_tasks
SET responsavel = 'gobbi'
WHERE operon_id IN (
  '868hwdejy',  -- PROCESSO: Novo Workflow de Trabalho com IA (produto/equipe)
  '868hwfgh6'   -- MANUAL: Funil de Levantada de Mão (manual de produto)
)
AND responsavel = 'heitor';
