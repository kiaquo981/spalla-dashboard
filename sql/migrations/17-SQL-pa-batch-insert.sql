-- ============================================================================
-- BATCH INSERT: Planos de Ação extraídos dos Dossiês Estratégicos
-- Gerado em: 2026-03-08
-- Fonte: Dossiês Estratégicos dos mentorados
-- ============================================================================

-- ===== MENTORADO: Mônica Felici (id=43) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (43, 'PLANO DE AÇÃO | MÔNICA FELICI', 'fases', 'nao_iniciado', 'migração v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 43, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 43, 1, 'Revisar Público-alvo', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 43, 2, 'Revisar Oferta', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 43, 3, 'Revisar Arquitetura do produto', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 43, 4, 'Revisar Estratégia do funil', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 1: Preparação
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 43, 'Fase 1: Preparação', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 43, 1, 'Definir nome, promessa e data da aula', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 43, 2, 'Criar grupo de WhatsApp', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 43, 3, 'Criar formulário de inscrição', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 43, 4, 'Lapidação do perfil', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 2: Captação
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 43, 'Fase 2: Captação', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 43, 1, 'Gravar anúncios', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 43, 2, 'Iniciar captação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 43, 3, 'Comunicação no grupo', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- Fase 3: Aula
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 43, 'Fase 3: Aula', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 43, 1, 'Preparar roteiro da aula', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 43, 2, 'Setup da aplicação da mentoria', 'pendente', 'mentorado', 2, 'dossie_auto');

  -- Fase 4: Vendas
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 43, 'Fase 4: Vendas', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 43, 1, 'Abordagem pós-aula para quem fez aplicação', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 43, 2, 'Abordagem pós-aula para quem não fez aplicação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 43, 3, 'Onboarding e confirmação da turma', 'pendente', 'mentorado', 3, 'dossie_auto');

END $$;


-- ===== MENTORADO: Dani Ferreira (id=1) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (1, 'PLANO DE AÇÃO | DANI FERREIRA', 'fases', 'nao_iniciado', 'migração v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico
  -- (Dani não tem seção explícita de revisão, mas tem pilares de produto a revisar)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 1, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 1, 1, 'Revisar Contexto e Posicionamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 2, 'Revisar Público-alvo', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 3, 'Revisar Oferta e Arquitetura do Produto', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 4, 'Revisar Storytelling', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 5, 'Revisar Proposta de Valor', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 1: Diagnóstico e Estratégia
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 1, 'Pilar 1: Diagnóstico e Estratégia', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 1, 1, 'Levantar números reais dos últimos 3 meses', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 2, 'Analisar gargalo: aquisição, venda, precificação ou entrega', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 3, 'Fazer Diagnóstico 360 e preencher Plano de Ação 90 dias', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 4, 'Traçar metas simples e possíveis', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 2: Ofertas e Precificação
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 1, 'Pilar 2: Ofertas e Precificação', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 1, 1, 'Montar 3 planos com diferentes níveis de investimento', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 2, 'Escrever descrição de cada plano', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 3, 'Adicionar bônus estratégicos', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 4, 'Revisar preços com base no custo, margem e tempo', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 5, 'Criar Tabela Master com visual limpo', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 3: Vendas e Conversão
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 1, 'Pilar 3: Vendas e Conversão', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 1, 1, 'Aplicar roteiro de consulta validado', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 2, 'Treinar scripts de WhatsApp e follow-up', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 3, 'Praticar contorno de objeções', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 4, 'Implementar apresentação de orçamento de alto valor', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 4: Marketing e Aquisição
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 1, 'Pilar 4: Marketing e Aquisição', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 1, 1, 'Definir posicionamento e narrativa profissional', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 2, 'Criar conteúdo estratégico', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 3, 'Implementar Playbook de Social Selling', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- Fase 5: Mentalidade e Liderança Comercial
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 1, 'Pilar 5: Mentalidade e Liderança Comercial', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 1, 1, 'Desenvolver mentalidade de alto desempenho comercial', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 1, 2, 'Trabalhar postura firme e clareza de valor', 'pendente', 'mentorado', 2, 'dossie_auto');

END $$;


-- ===== MENTORADO: Karine Canabrava (id=34) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (34, 'PLANO DE AÇÃO | KARINE CANABRAVA', 'fases', 'nao_iniciado', 'migração v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 34, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 34, 1, 'Revisar Contexto e Posicionamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 2, 'Revisar Público-alvo', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 3, 'Revisar Proposta de Valor', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 4, 'Revisar Storytelling', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 5, 'Revisar Lapidação do Perfil', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Pilar 1: Financeiro (Organização)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 34, 'Pilar 1: Financeiro (Organização)', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 34, 1, 'Mapear todas as contas bancárias e categorias de despesas', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 2, 'Implantar software de conciliação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 3, 'Criar plano de contas junto ao consultor', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 4, 'Alimentar dados e revisar semanalmente', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 5, 'Validar a primeira DRE e identificar gargalos de custo', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Pilar 2: Visão Estratégica (Start)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 34, 'Pilar 2: Visão Estratégica (Start)', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 34, 1, 'Revisar dados financeiros e comerciais da fase anterior', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 2, 'Preencher o Business Model Canvas com o consultor', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 3, 'Realizar benchmarking e comparar diferenciais', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 4, 'Executar análise SWOT', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 5, 'Criar plano de ação 5W2H com prioridades de crescimento', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Pilar 3: Comercial
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 34, 'Pilar 3: Comercial', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 34, 1, 'Criar planilha com metas mensais e semanais', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 2, 'Analisar histórico de vendas para definir ticket médio', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 3, 'Montar quadro de gestão à vista', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 4, 'Implementar rotina semanal de análise dos indicadores', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 5, 'Treinar time de vendas nas metas e acompanhamento diário', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Pilar 4: Processos e Pessoas
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 34, 'Pilar 4: Processos e Pessoas', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 34, 1, 'Fazer diagnóstico dos setores e rotinas existentes', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 2, 'Mapear o fluxo de cada processo', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 3, 'Produzir os POPs com apoio do consultor', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 4, 'Validar e treinar os responsáveis', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 5, 'Implementar e acompanhar rotinas semanalmente', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Pilar 5: Consolidação e Liberdade
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 34, 'Pilar 5: Consolidação e Liberdade', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 34, 1, 'Manter rotina de fechamento financeiro mensal', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 2, 'Analisar indicadores com o consultor', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 3, 'Discutir resultados nas reuniões de conselho', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 34, 4, 'Implementar ajustes estratégicos conforme metas', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;


-- ===== MENTORADO: Marina Mendes (id=41) =====
-- Marina's dossier has no explicit Plano de Ação section with phases/tables.
-- Creating plan based on the 4 Pilares do Método from the Oferta section.
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (41, 'PLANO DE AÇÃO | MARINA MENDES', 'fases', 'nao_iniciado', 'migração v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 41, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 41, 1, 'Revisar Contexto e Posicionamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 41, 2, 'Revisar Público-alvo', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 41, 3, 'Revisar Storytelling', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 41, 4, 'Revisar Oferta e Arquitetura do Produto', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Pilar 1: Percepção de Valor
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 41, 'Pilar 1: Percepção de Valor', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 41, 1, 'Estruturar assinatura estética e identidade visual', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 41, 2, 'Definir posicionamento premium no digital', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 41, 3, 'Criar narrativa de autoridade', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- Pilar 2: Captação de Paciente
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 41, 'Pilar 2: Captação de Paciente', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 41, 1, 'Implementar captação orgânica com criativos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 41, 2, 'Criar conteúdo estratégico para atração', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 41, 3, 'Organizar estética do perfil e narrativa de autoridade', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- Pilar 3: Oferta e Recorrência
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 41, 'Pilar 3: Oferta e Recorrência', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 41, 1, 'Criar pacotes premium e plano anual', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 41, 2, 'Estruturar recorrência e fidelização', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 41, 3, 'Definir precificação por protocolo completo', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- Pilar 4: Jornada do Paciente
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 41, 'Pilar 4: Jornada do Paciente', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 41, 1, 'Estruturar consulta que converte', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 41, 2, 'Implementar processo pré-consulta ao pós-venda', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 41, 3, 'Criar sistema de follow-up e reativação', 'pendente', 'mentorado', 3, 'dossie_auto');

END $$;


-- ===== MENTORADO: Rafael Castro (id=8) =====
-- Rafael has 3 Fases: Lapidação, Produção de Conteúdo, Distribuição e Conversão
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (8, 'PLANO DE AÇÃO | RAFAEL CASTRO', 'fases', 'nao_iniciado', 'migração v2')
  RETURNING id INTO _plano_id;

  -- Fase 1: Lapidação e Preparação do Perfil
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 8, 'Fase 1: Lapidação e Preparação do Perfil', 'fase', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 8, 1, 'Ajustar Bio e Nome', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 8, 2, 'Criar destaques (História, Prova, Produto, Bastidores, Lifestyle)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 8, 3, 'Criar posts fixados', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- Fase 2: Produção de Conteúdo
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 8, 'Fase 2: Produção de Conteúdo', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 8, 1, 'Organização inicial: selecionar 5-7 ideias por semana', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 8, 2, 'Desenvolvimento das ideias no Agente de Conteúdo', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 8, 3, 'Preparação para gravação e design', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 8, 4, 'Gravação e produção em lote', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 8, 5, 'Edição, revisão e programação', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 3: Distribuição e Conversão
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 8, 'Fase 3: Distribuição e Conversão', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 8, 1, 'Configurar turbinar publicação no Instagram', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 8, 2, 'Configurar distribuição no Gerenciador de Anúncios Meta', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 8, 3, 'Testar primeiros conteúdos e definir base de referência', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 8, 4, 'Otimizar baseado em métricas do perfil', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;


-- ===== MENTORADO: Tayslara Belarmino (id=138) =====
-- 3 dossiês: Oferta e Produto, Posicionamento e Conteúdo, Funil de Vendas
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (138, 'PLANO DE AÇÃO | TAYSLARA BELARMINO', 'fases', 'nao_iniciado', 'migração v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico (Oferta e Produto)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 138, 'Revisão do Dossiê - Oferta e Produto', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 138, 1, 'Revisar Storytelling', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 2, 'Revisar Público-alvo', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 3, 'Revisar Tese do produto', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 4, 'Revisar Conteúdo programático', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 5, 'Revisar Oferta e Arquitetura', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 6, 'Revisar Copy da jornada', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- Plano Executivo: Passos 1-12
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 138, 'Plano Executivo - Preparação e Vendas', 'passo_executivo', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 138, 1, 'Entender a estratégia do momento', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 2, 'Definir cronograma com data combinada', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 3, 'Preparar mínimo necessário: contrato, onboarding, PDF, formulário, scripts', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 4, 'Montar base de prospecção (lista/grupos)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 5, 'Executar funil de vendas: prospecção, abordagem, qualificação, call', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 6, 'Aplicar critérios de qualificação', 'pendente', 'mentorado', 6, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 7, 'Onboarding após pagamento', 'pendente', 'mentorado', 7, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 8, 'Conduzir call de Diagnóstico', 'pendente', 'mentorado', 8, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 9, 'Entregar vitória rápida e 1o material', 'pendente', 'mentorado', 9, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 10, 'Construir Plano de Ação do mentorado', 'pendente', 'mentorado', 10, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 11, 'Acompanhamento: reuniões quinzenais e suporte WhatsApp', 'pendente', 'mentorado', 11, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 12, 'Produção incremental de materiais conforme demanda', 'pendente', 'mentorado', 12, 'dossie_auto');

  -- Plano do Produto: O Básico Para Começar
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 138, 'Produto - O Básico Para Começar', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 138, 1, 'Definir o nome da mentoria', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 2, 'Preparar modelo de contrato', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 3, 'Montar fluxo de onboarding mínimo', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 4, 'Criar formulário de diagnóstico', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 5, 'Definir perguntas do diagnóstico por pilar', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 6, 'Definir formato do plano individual', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- Funil de Vendas: Etapas 0-5
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 138, 'Funil de Vendas - Etapas de Execução', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 138, 1, 'Etapa 0: Definir produto (formato, preço, conteúdo)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 2, 'Etapa 1: Preparação (perfil, formulário, scripts)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 3, 'Etapa 2: Abordagem de Lista (grupos WhatsApp)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 4, 'Etapa 3: Autoridade (conteúdo Instagram em paralelo)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 5, 'Etapa 5: Social Seller (prospecção ativa DM)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Posicionamento e Conteúdo: Funil de Autoridade
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 138, 'Posicionamento - Funil de Autoridade', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 138, 1, 'Criação do novo perfil de mentora', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 2, 'Lapidação de perfil @dratayslarabelarmino', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 3, 'Produção de conteúdo', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 138, 4, 'Distribuição de conteúdo', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;


-- ===== MENTORADO: Yara Gomes (id=137) =====
-- 3 dossiês: Oferta e Produto, Funil de Vendas, Posicionamento e Conteúdo
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (137, 'PLANO DE AÇÃO | YARA GOMES', 'fases', 'nao_iniciado', 'migração v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê - Oferta e Produto
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 137, 'Revisão do Dossiê - Oferta e Produto', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 137, 1, 'Revisar Storytelling', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 2, 'Revisar Público-alvo', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 3, 'Revisar Tese do Produto', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 4, 'Revisar Conteúdo programático', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 5, 'Revisar Oferta e Arquitetura', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 6, 'Revisar Copy da Jornada', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- Produto: O Básico Para Começar
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 137, 'Produto - O Básico Para Começar', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 137, 1, 'Definir o nome da mentoria', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 2, 'Preparar modelo de contrato', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 3, 'Montar fluxo de onboarding mínimo', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 4, 'Criar formulário de diagnóstico', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 5, 'Definir perguntas do diagnóstico por pilar', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 6, 'Definir formato do plano individual', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- Funil de Vendas: Etapas 0-4
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 137, 'Funil de Vendas - Etapas de Execução', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 137, 1, 'Etapa 0: Definir produto (formato, preço, conteúdo)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 2, 'Etapa 1: Preparação (perfil, formulário, planilha, scripts)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 3, 'Etapa 2: Abordagem de Lista (primeiras vendas)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 4, 'Etapa 3: Autoridade (conteúdo Instagram em paralelo)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 5, 'Etapa 4: Social Seller (prospecção ativa DM)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Posicionamento: Revisão do Dossiê
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 137, 'Revisão do Dossiê - Posicionamento e Conteúdo', 'revisao_dossie', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 137, 1, 'Revisar Lapidação de perfil', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 2, 'Revisar Ideias de posts', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 3, 'Revisar Ideias de Stories', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 4, 'Revisar Distribuição de conteúdo', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Posicionamento: Fases de Execução
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 137, 'Posicionamento - Fases de Execução', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 137, 1, 'Fase 1: Abordagem e vendas (ver Dossiê Funil)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 2, 'Fase 2: Lapidação de perfil @dra.yaragomes', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 3, 'Fase 2: Criar e lapidar perfil novo de mentoria', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 137, 4, 'Fase 3: Funil autoridade + social seller', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;


-- ===== MENTORADO: Letícia Oliveira (id=45) =====
-- Arquivo não encontrado nos Downloads. Criando plano básico com revisão do dossiê.
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (45, 'PLANO DE AÇÃO | LETÍCIA OLIVEIRA', 'fases', 'nao_iniciado', 'migração v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 45, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 45, 1, 'Revisar Contexto e Posicionamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 45, 2, 'Revisar Público-alvo', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 45, 3, 'Revisar Oferta e Arquitetura', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 45, 4, 'Revisar Storytelling', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;
