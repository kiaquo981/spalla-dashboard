-- ============================================================================
-- BATCH INSERT v3: Planos de Ação extraídos dos Dossiês Estratégicos
-- Gerado em: 2026-03-08
-- Fonte: Dossiês Estratégicos (Livia, Luciana, Maria, Michelle, Miriam)
-- ============================================================================

-- ===== MENTORADO: Livia Lyra (id=13) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (13, 'PLANO DE AÇÃO | LIVIA LYRA', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 13, 1, 'Revisar Storytelling (jornada flebologia + PhleboAcademy)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 2, 'Revisar Público-alvo (médicos cirurgiões vasculares)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 3, 'Revisar Tese do Produto (escola de flebologia)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 4, 'Revisar Arquitetura do Produto IMPULSE (4 pilares, 4 estações)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 5, 'Revisar Oferta IMPULSE 2026 (R$36K-48K, 12 meses)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 1: Lapidação de Perfil e Posicionamento
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Fase 1: Lapidação de Perfil e Posicionamento', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 13, 1, 'Atualizar foto de perfil (crop rosto, fundo neutro)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 2, 'Ajustar nome do perfil: Dra Livia Lyra | Cirurgia Vascular', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 3, 'Atualizar bio com as 3 versões sugeridas no dossiê', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 4, 'Configurar link da bio (WhatsApp, Agenda, PhleboAcademy)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 5, 'Criar 6 destaques ordenados (Historia, Antes e Depois, Tratamentos, Phlebo Academy, Bastidores, Lifestyle)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 2: Estruturação do IMPULSE 2026
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Fase 2: Estruturação do IMPULSE 2026', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 13, 1, 'Estruturar os 4 pilares (Diagnóstico Estratégico, Mapa de Alavancas, Implementação Assistida, Consolidação)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 2, 'Definir entregas por estação (Primavera, Verão, Outono, Inverno)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 3, 'Preparar sprint presencial e dinâmica de planejamento trimestral', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 4, 'Configurar entrega via Notion + Time PhleboAcademy', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 5, 'Preparar contrato e proposta comercial (R$36K-48K)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 3: Posicionamento Digital e Conteúdo
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Fase 3: Posicionamento Digital e Conteúdo', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 13, 1, 'Gravar conteúdo de storytelling (jornada flebologia, PhleboAcademy, IMPULSE)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 2, 'Criar conteúdo de autoridade (casos clínicos, resultados antes/depois)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 3, 'Produzir conteúdo sobre o método IMPULSE para médicos vasculares', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 4, 'Criar conteúdo de bastidores (PhleboAcademy, consultório, congressos)', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 4: Captação e Primeira Turma IMPULSE
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Fase 4: Captação e Primeira Turma IMPULSE', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 13, 1, 'Estruturar funil de captação (conteúdo → aplicação → call → venda)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 2, 'Ativar rede de contatos e congressos de cirurgia vascular', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 3, 'Realizar calls de venda consultiva para o IMPULSE', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 4, 'Fechar primeira turma e iniciar sprint presencial de onboarding', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;


-- ===== MENTORADO: Luciana Saraiva (id=10) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (10, 'PLANO DE AÇÃO | LUCIANA SARAIVA', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 10, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 10, 1, 'Revisar Storytelling e Posicionamento (Método Elleve)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 2, 'Revisar Público-alvo (dentistas que querem odontologia premium)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 3, 'Revisar Tese do Produto (Papel Mentor para dentistas)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 4, 'Revisar Arquitetura do Produto (5 pilares Elleve)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 5, 'Revisar Oferta e Workshop Elleve como produto de entrada', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 1: Lapidação de Perfil e Posicionamento
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 10, 'Fase 1: Lapidação de Perfil e Posicionamento', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 10, 1, 'Atualizar foto de perfil (crop rosto, fundo neutro)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 2, 'Ajustar nome do perfil conforme sugestão do dossiê', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 3, 'Atualizar bio com versão sugerida (Método Elleve + clínica 1500m²)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 4, 'Configurar link da bio com botões estratégicos', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 5, 'Criar destaques ordenados conforme dossiê (Historia, Clínica, Alunos, Workshop, Bastidores, Lifestyle)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 2: Estratégia de Conteúdo e Anúncios
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 10, 'Fase 2: Estratégia de Conteúdo e Anúncios', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 10, 1, 'Implementar calendário editorial por dia da semana (Papel Mentor)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 2, 'Gravar conteúdos das 5 linhas editoriais (Desejo, Confiança, Alcance, Infovendas, Identificação)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 3, 'Criar os 8 anúncios detalhados do dossiê para tráfego pago', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 4, 'Produzir conteúdo de storytelling (clínica 1500m², faturamento 500K/mês)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 5, 'Criar conteúdo de autoridade sobre odontologia premium e gestão de clínica', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 3: Estruturação do Workshop Elleve
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 10, 'Fase 3: Estruturação do Workshop Elleve', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 10, 1, 'Definir formato e conteúdo programático do Workshop Elleve', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 2, 'Estruturar a mentoria principal (5 pilares Elleve, cronograma, entregas)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 3, 'Preparar contrato e proposta comercial da mentoria', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 4, 'Criar landing page do Workshop Elleve', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 4: Funil e Captação
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 10, 'Fase 4: Funil e Captação', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 10, 1, 'Ativar tráfego pago com os 8 anúncios do dossiê', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 2, 'Estruturar funil Workshop → Mentoria (captação → inscrição → upsell)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 3, 'Realizar Workshop Elleve como evento de captação', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 4, 'Converter participantes do Workshop em mentorados e fechar primeira turma', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;


-- ===== MENTORADO: Maria Spindola (id=39) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (39, 'PLANO DE AÇÃO | MARIA SPINDOLA', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 39, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 39, 1, 'Revisar Storytelling (14 anos multinacionais agro → mentora de carreira)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 2, 'Revisar Público-alvo (executivos expatriados e profissionais agro)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 3, 'Revisar Tese do Produto (Método ACE + Inteligência Cultural)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 4, 'Revisar Arquitetura do Produto (4 pilares: Alignment, Credibility, Execution, IC)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 5, 'Revisar Oferta Individual (R$18K, 6 meses) e Grupo (R$6-8K)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 1: Estruturação do Método ACE
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 39, 'Fase 1: Estruturação do Método ACE', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 39, 1, 'Estruturar Pilar 1 Alignment (Fit Cultural, Perfil de Liderança, Plano de Voo)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 2, 'Estruturar Pilar 2 Credibility (Marca Pessoal, LinkedIn, Comunicação Executiva)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 3, 'Estruturar Pilar 3 Execution (Gestão de Stakeholders, Resultados, Negociação)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 4, 'Estruturar Pilar 4 Inteligência Cultural e Social', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 5, 'Preparar contrato e proposta comercial (Individual R$18K / Grupo R$6-8K)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 2: Posicionamento Digital e Conteúdo
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 39, 'Fase 2: Posicionamento Digital e Conteúdo', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 39, 1, 'Lapidação de perfil Instagram (bio, destaques, foto, link da bio)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 2, 'Gravar conteúdo de storytelling (jornada multinacionais, expatriação, transição)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 3, 'Criar conteúdo de autoridade sobre carreira internacional e inteligência cultural', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 4, 'Produzir conteúdo sobre o Método ACE para executivos', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 3: Funil de Captação e Prospecção Ativa
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 39, 'Fase 3: Funil de Captação e Prospecção Ativa', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 39, 1, 'Criar formulário de qualificação para mentorados', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 2, 'Montar lista de prospecção ativa (executivos agro, expatriados, RH)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 3, 'Implementar os 3 scripts de abordagem do dossiê (LinkedIn/WhatsApp/Email)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 4, 'Estruturar ligação de qualificação (5 min) + Call de diagnóstico e venda', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 5, 'Preparar evento de validação (Jan/2026) como ponto de captação', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 4: Vendas e Primeira Turma
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 39, 'Fase 4: Vendas e Primeira Turma', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 39, 1, 'Iniciar prospecção ativa com scripts e lista de contatos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 2, 'Realizar calls de diagnóstico e venda consultiva', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 3, 'Fechar primeiros mentorados individuais (R$18K)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 4, 'Iniciar entrega da mentoria Método ACE (6 meses)', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;


-- ===== MENTORADO: Michelle Novelli Yoshiy (id=132) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (132, 'PLANO DE AÇÃO | MICHELLE NOVELLI YOSHIY', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 132, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 132, 1, 'Revisar Storytelling (7 marcos: radiologista → pioneira ultrassom dermatológico)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 2, 'Revisar Público-alvo (médicos estetas, nutrólogos, dermatologistas)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 3, 'Revisar Tese do Produto (subincisão guiada por ultrassom para retrações)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 4, 'Revisar 10 Crenças para imprimir no conteúdo', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 5, 'Revisar Oferta da Imersão Presencial (2 dias, 4 médicos, R$15-25K)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 1: Desvinculação do Gold Incision e Marca Própria
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 132, 'Fase 1: Marca Própria e Posicionamento', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 132, 1, 'Definir nome da marca própria (desvinculação do Gold Incision)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 2, 'Lapidação de perfil Instagram (bio, destaques, foto, posicionamento ultrassom)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 3, 'Criar destaques com foco em autoridade (Casos Clínicos, Ultrassom, Celulite, Imersão, Bastidores)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 4, 'Gravar conteúdo dos 7 marcos do storytelling (da radiologia ao ultrassom dermatológico)', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 2: Estratégia de Conteúdo e Autoridade
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 132, 'Fase 2: Estratégia de Conteúdo e Autoridade', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 132, 1, 'Criar conteúdo das 10 crenças do dossiê (ultrassom obrigatório, celulite tem solução, etc.)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 2, 'Produzir conteúdo técnico sobre subincisão guiada por ultrassom', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 3, 'Gravar casos clínicos com resultados (antes/depois com ultrassom)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 4, 'Criar conteúdo sobre as 6 dores do público-alvo (insegurança técnica, falta diferenciação, resultados ruins celulite)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 5, 'Produzir conteúdo educativo sobre a tese (por que ultrassom muda tudo no corporal)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 3: Estruturação da Imersão Presencial
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 132, 'Fase 3: Estruturação da Imersão Presencial', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 132, 1, 'Estruturar conteúdo programático da imersão (2 dias, teoria + hands-on)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 2, 'Definir logística presencial (local, equipamentos ultrassom, modelos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 3, 'Preparar materiais didáticos (protocolos subincisão, atlas ultrassonográfico)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 4, 'Preparar contrato e proposta comercial (R$15-25K por aluno, máx 4)', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 4: Captação e Primeira Turma da Imersão
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 132, 'Fase 4: Captação e Primeira Turma da Imersão', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 132, 1, 'Estruturar funil de captação (conteúdo → aplicação → call → venda)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 2, 'Ativar rede de contatos médicos e congressos de estética', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 3, 'Realizar calls de venda consultiva para a imersão', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 132, 4, 'Fechar 4 médicos e realizar primeira imersão presencial', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;


-- ===== MENTORADO: Miriam Alves (id=50) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (50, 'PLANO DE AÇÃO | MIRIAM ALVES', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 50, 1, 'Revisar Storytelling (de Curitiba a Harvard, oftalmologia + cirurgia refrativa)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 2, 'Revisar Público-alvo (oftalmologistas recém-formados e em transição)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 3, 'Revisar Tese do Produto (Capacitação em Cirurgia Refrativa a Laser)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 4, 'Revisar Arquitetura do Produto (4 pilares refrativa)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 5, 'Revisar Oferta (6 meses, 4 pilares, capacitação completa)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 1: Estruturação da Capacitação em Cirurgia Refrativa
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Fase 1: Estruturação da Capacitação', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 50, 1, 'Estruturar Pilar 1: Planejamento Refracional (módulos e entregas)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 2, 'Estruturar Pilar 2: Leitura de Exames Pré-operatórios', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 3, 'Estruturar Pilar 3: Cirurgia Refrativa na Prática (gravações de cirurgias)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 4, 'Estruturar Pilar 4: Discussão de Casos Clínicos', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 5, 'Preparar contrato e proposta comercial (6 meses)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 2: Posicionamento Digital e Conteúdo
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Fase 2: Posicionamento Digital e Conteúdo', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 50, 1, 'Lapidação de perfil Instagram (bio, destaques, foto, posicionamento refrativa)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 2, 'Gravar conteúdo de storytelling (de Curitiba a Harvard, 3 filhos, 2400+ cirurgias)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 3, 'Criar conteúdo de autoridade sobre cirurgia refrativa (pós-doc Harvard, técnicas)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 4, 'Produzir conteúdo sobre as dores do público (insegurança técnica, dependência hospital, falta autonomia)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 5, 'Criar conteúdo educativo sobre a capacitação para oftalmologistas', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 3: Independência do Hospital e Modelo de Negócio
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Fase 3: Modelo de Negócio e Independência', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 50, 1, 'Estruturar plano de redução da dependência do hospital (70% receita atual)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 2, 'Definir modelo de precificação da capacitação (considerando ticket premium)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 3, 'Criar funil de captação (conteúdo IG → aplicação → call → venda)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 4, 'Estruturar landing page da capacitação em cirurgia refrativa', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 4: Captação e Primeira Turma
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Fase 4: Captação e Primeira Turma', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 50, 1, 'Iniciar captação via Instagram e rede de contatos oftalmológicos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 2, 'Ativar congressos e sociedades de oftalmologia como canal de captação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 3, 'Realizar calls de venda consultiva para oftalmologistas', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 4, 'Fechar primeira turma e iniciar capacitação de 6 meses', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;
