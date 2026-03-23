-- Migration: classify unassigned tasks into correct lists
-- Applies the same logic as the ClickUp import classifier in 11-APP-app.js
-- Affects: space_gestao tasks with NULL list_id + NULL space tasks

-- Step 1: Fix NULL space tasks → space_gestao / list_operacional
UPDATE public.god_tasks
SET
  space_id = 'space_gestao',
  list_id  = 'list_operacional'
WHERE space_id IS NULL;

-- Step 2: Classify space_gestao tasks with NULL list_id
UPDATE public.god_tasks
SET list_id = CASE

  -- AULAS → Conteúdo & Marketing
  WHEN titulo ILIKE 'AULA%'
    THEN 'list_conteudo'

  -- ENTREGÁVEL: Módulo → Conteúdo & Marketing (course modules)
  WHEN titulo ILIKE 'ENTREGÁVEL: Módulo%'
    THEN 'list_conteudo'

  -- PLANO: gravação → Conteúdo
  WHEN titulo ILIKE 'PLANO: C3%Cronograma de Gravação%'
    THEN 'list_conteudo'

  -- Reorganizar Entrega de Roteiros → Conteúdo
  WHEN titulo ILIKE 'Reorganizar Entrega de Roteiros%'
    THEN 'list_conteudo'

  -- MANUAL: Funil → Vendas & Comercial
  WHEN titulo ILIKE 'MANUAL: Funil%'
    THEN 'list_vendas'

  -- FUNIL: → Vendas & Comercial
  WHEN titulo ILIKE 'FUNIL:%'
    THEN 'list_vendas'

  -- ENTREGÁVEL: Kit Comercial / Kit Vendas / Roteiros de Execução → Vendas
  WHEN titulo ILIKE 'ENTREGÁVEL: Kit Comercial%'
      OR titulo ILIKE 'ENTREGÁVEL: Kit Vendas%'
      OR titulo ILIKE 'ENTREGÁVEL: Roteiros de Execução%'
    THEN 'list_vendas'

  -- ENTREGÁVEL: Kit Oferta → Playbooks & Materiais
  WHEN titulo ILIKE 'ENTREGÁVEL: Kit Oferta%'
    THEN 'list_playbooks'

  -- Versionamento / Mapa / Organização de funis → Vendas
  WHEN titulo ILIKE 'Versionamento de Revisões de Funil%'
      OR titulo ILIKE 'Mapa de Funis%'
      OR titulo ILIKE 'Organização de Materiais dos Funis%'
    THEN 'list_vendas'

  -- Criar mapa visual de funis, kits de mensagem, kits de tráfego → Vendas
  WHEN titulo ILIKE 'Criar mapa visual interativo de todos os funis%'
      OR titulo ILIKE 'Criar kit de tráfego pago%'
      OR titulo ILIKE 'Criar kit de mensagens%'
      OR titulo ILIKE 'Criar checklist de funil de evento%'
      OR titulo ILIKE 'Criar roteiro de funil de aula%'
      OR titulo ILIKE 'Criar Manual do Evento Presencial%'
      OR titulo ILIKE 'Criar critérios de tema de aula%'
      OR titulo ILIKE 'Criar Manual de Vendas%'
      OR titulo ILIKE 'Criar templates de abordagem%'
      OR titulo ILIKE 'Criar JDs%'
      OR titulo ILIKE 'Criar dashboard de funil comercial%'
      OR titulo ILIKE 'Criar manual de scripts de abordagem%'
      OR titulo ILIKE 'Criar manual de rotinas da equipe comercial%'
      OR titulo ILIKE 'Criar manual de conversão por canal%'
      OR titulo ILIKE 'Gerar 5+ variações por segmento%'
      OR titulo ILIKE 'Incluir roteiro de agendamento de call%'
      OR titulo ILIKE 'Criar framework de consulta padrão%'
      OR titulo ILIKE 'Criar prompt de análise de consulta%'
      OR titulo ILIKE 'Criar manual de conexão por personalidade%'
    THEN 'list_vendas'

  -- Playbooks / templates / manuais standalone → Playbooks & Materiais
  WHEN titulo ILIKE 'Manual completo%'
      OR titulo ILIKE 'Playbook Enxuto%'
      OR titulo ILIKE 'Criar template de ICP%'
      OR titulo ILIKE 'Criar prompt de precificação%'
      OR titulo ILIKE 'Criar prompt de naming%'
      OR titulo ILIKE 'Criar template de cardápio de pacotes%'
      OR titulo ILIKE 'Criar checklist de análise de página de vendas%'
      OR titulo ILIKE 'Criar calendário editorial%'
      OR titulo ILIKE 'Criar templates ManyChat%'
      OR titulo ILIKE 'Criar manual de campanhas internas%'
      OR titulo ILIKE 'Criar termo de autorização%'
      OR titulo ILIKE 'Criar 8 roteiros de execução%'
    THEN 'list_playbooks'

  -- Deck investidores / Scraper benchmarking → Direcionamentos Queila
  WHEN titulo ILIKE 'Preparar deck all-in%'
      OR titulo ILIKE 'Scraper de Melhores Clínicas%'
    THEN 'list_direcionamentos'

  -- PROCESSO: / SOP → Operacional
  WHEN titulo ILIKE 'PROCESSO:%'
      OR titulo ILIKE 'SOP%'
      OR titulo ILIKE 'Processo:%'
    THEN 'list_operacional'

  -- SPALLA: (system/product) → Operacional
  WHEN titulo ILIKE 'SPALLA:%'
    THEN 'list_operacional'

  -- Tudo mais → Operacional (fallback seguro)
  ELSE 'list_operacional'

END
WHERE space_id = 'space_gestao'
  AND list_id IS NULL;
