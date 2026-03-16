-- ============================================================================
-- BATCH INSERT: Planos de Ação — 5 Dossiês restantes
-- Gerado em: 2026-03-08
-- Fonte: /Users/kaiquerodrigues/Downloads/Dossies_Spalla/
--
-- Mentorados: Pablo Santos (6), Paula e Anna (47), Raqui Piolli (5),
--             Renata Aleixo (44), Rosalie Matuk (135)
-- ============================================================================


-- ===== MENTORADO: Pablo Santos (id=6) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (6, 'PLANO DE AÇÃO | PABLO SANTOS', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 6, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 6, 1, 'Revisar o Storytelling e validar narrativa de autoridade em implantodontia', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 2, 'Revisar o Público-alvo e alinhar perfil ideal (dentistas que querem dominar prótese sobre implante)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 3, 'Revisar a Tese do produto e proposta de valor da mentoria prática', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 4, 'Revisar a Arquitetura do produto (4 pilares: Prótese, Digital, Prática Presencial, Avançada)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 5, 'Revisar a Oferta e estrutura de precificação da mentoria', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 6, 'Revisar a Estratégia do funil de captação e conversão', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 6, 'Posicionamento e Perfil Digital', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 6, 1, 'Atualizar bio do Instagram com posicionamento de mentor em implantodontia avançada', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 2, 'Criar destaques estratégicos: Casos Clínicos, Método, Depoimentos, Mentoria', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 3, 'Produzir conteúdo de bastidores da clínica mostrando casos complexos de implante', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 4, 'Criar linha editorial separando conteúdo B2C (pacientes) e B2B (dentistas)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 6, 'Estruturação da Mentoria Prática em Implantodontia', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 6, 1, 'Finalizar arquitetura da mentoria com os 4 pilares definidos no dossiê', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 2, 'Estruturar módulo presencial com hands-on em prótese sobre implante', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 3, 'Definir cronograma de entrega e formato dos encontros (presencial + online)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 4, 'Preparar materiais de apoio: protocolos clínicos, checklists e casos referência', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 5, 'Configurar área de membros ou pasta de entrega para mentorados', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 6, 'Captação via Base Quente de Ex-Alunos', 'passo_executivo', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 6, 1, 'Segmentar base de ~200 ex-alunos presenciais e ~170 online (Hotmart) por perfil', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 2, 'Criar campanha de aquecimento direcionada para ex-alunos via WhatsApp', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 3, 'Realizar aula ao vivo de demonstração para base quente', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 4, 'Abrir inscrições com oferta exclusiva para ex-alunos', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 6, 'Vendas e Onboarding', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 6, 1, 'Realizar calls de vendas individuais com interessados', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 2, 'Executar follow-up estruturado e fechamento de vendas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 3, 'Formalizar contratos e processar pagamentos', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 4, 'Fazer onboarding dos mentorados com acesso aos materiais e grupo exclusivo', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;


-- ===== MENTORADO: Paula e Anna / KAVA Arquitetura (id=47) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (47, 'PLANO DE AÇÃO | PAULA E ANNA (KAVA)', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 1, 'Revisar o Storytelling e validar narrativa de autoridade em gestão de obra', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 2, 'Revisar o Público-alvo e alinhar perfil ideal (arquitetos R$20-50k)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 3, 'Revisar a Tese do produto e o método Cronograma Reverso', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Revisar a Arquitetura do produto educacional', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 5, 'Revisar a Oferta e estrutura de precificação', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 6, 'Revisar a Copy da jornada e argumentação comercial', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Reposicionamento Digital com Método Cronograma Reverso', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 1, 'Atualizar bio do Instagram com posicionamento de mentoras em gestão de obra', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 2, 'Criar destaques estratégicos: Método, Cronograma Reverso, Resultados, Mentoria', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 3, 'Produzir conteúdo mostrando bastidores de obras gerenciadas com o método', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Criar série de conteúdo educativo sobre gestão de obra para arquitetos', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Estruturação do Produto Educacional', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 1, 'Estruturar mentoria em grupo com base no método Cronograma Reverso', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 2, 'Definir módulos: planejamento de obra, cronograma, gestão de equipe, entrega', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 3, 'Criar templates e ferramentas práticas para os mentorados (planilhas, checklists)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Definir formato de entrega: encontros ao vivo + suporte assíncrono', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 5, 'Criar área de membros ou pasta de entrega organizada', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Qualificação Comercial e Funil de Vendas', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 1, 'Definir funil de captação para arquitetos (Instagram + indicações)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 2, 'Criar página de vendas ou documento de apresentação da mentoria', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 3, 'Preparar pitch de vendas com argumentação baseada em resultados reais', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Criar sequência de aquecimento pré-lançamento para rede de contatos', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Lançamento e Vendas', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 1, 'Ativar rede de arquitetos conhecidos com campanha segmentada', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 2, 'Realizar aula ao vivo gratuita sobre gestão de obra com método', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 3, 'Conduzir calls de vendas individuais com interessados', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Executar follow-up e fechamento de vendas', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 5, 'Formalizar contratos e fazer onboarding dos mentorados', 'pendente', 'mentorado', 5, 'dossie_auto');
END $$;


-- ===== MENTORADO: Raqui Piolli (id=5) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (5, 'PLANO DE AÇÃO | RAQUI PIOLLI', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 5, 1, 'Revisar o Storytelling e validar narrativa de autoridade em cirurgia facial', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 2, 'Revisar o Público-alvo e alinhar perfil ideal (cirurgiões que querem dominar face lift)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 3, 'Revisar a Tese do produto e proposta de valor da Formação One Face Lift', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 4, 'Revisar a Arquitetura do produto (4 pilares: Observação, Prática, Observatório, Acompanhamento)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 5, 'Revisar a Oferta premium R$40k e estrutura de precificação', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Posicionamento como Formadora em Cirurgia Facial', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 5, 1, 'Atualizar bio do Instagram com posicionamento de formadora em One Face Lift', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 2, 'Criar destaques estratégicos: Técnica, Casos, Formação, Depoimentos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 3, 'Produzir conteúdo de bastidores do centro cirúrgico próprio com casos reais', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 4, 'Criar conteúdo educativo diferenciando blefaroplastia, papada e frontoplastia', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 5, 'Documentar resultados cirúrgicos com antes/depois e narrativa técnica', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Estruturação da Formação One Face Lift', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 5, 1, 'Finalizar arquitetura da formação de 6 meses com máximo 4 alunos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 2, 'Estruturar Pilar 1: Observação Estruturada (cirurgias ao vivo)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 3, 'Estruturar Pilar 2: Prática Supervisionada (hands-on com supervisão)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 4, 'Estruturar Pilar 3: Observatório Final e Pilar 4: Acompanhamento Pós-Cirurgia', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 5, 'Preparar protocolos cirúrgicos documentados e checklists para cada etapa', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Marketing e Funil Profissionalizado', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 5, 1, 'Definir funil de captação para cirurgiões (congressos + Instagram + indicações)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 2, 'Criar página de vendas ou material de apresentação da formação premium', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 3, 'Preparar pitch de vendas enfatizando exclusividade (apenas 4 vagas)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 4, 'Criar sequência de aquecimento para base de contatos médicos', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Captação e Vendas Premium', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 5, 1, 'Ativar rede de contatos médicos e cirurgiões com campanha segmentada', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 2, 'Realizar calls de vendas individuais com cirurgiões interessados', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 3, 'Executar follow-up e fechamento de vendas (R$40k/aluno)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 4, 'Formalizar contratos e fazer onboarding dos 4 alunos selecionados', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;


-- ===== MENTORADO: Renata Aleixo (id=44) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (44, 'PLANO DE AÇÃO | RENATA ALEIXO', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 1, 'Revisar o Storytelling e validar narrativa de autoridade em nutrição de precisão', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 2, 'Revisar o Público-alvo e alinhar perfil ideal (nutricionistas clínicas 3-10 anos, R$4-12k)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Revisar a Tese do produto e o Protocolo PDM (Desinflamação e Microbiota)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Revisar o Conteúdo programático da mentoria Nutrição 4P', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 5, 'Revisar a Oferta e Arquitetura do produto', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 6, 'Revisar a Copy da jornada e argumentação comercial', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Posicionamento Digital em Nutrição de Precisão', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 1, 'Atualizar bio do Instagram com posicionamento de mentora em Nutrição de Precisão', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 2, 'Criar destaques estratégicos: Protocolo PDM, Resultados, Método, Mentoria', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Produzir conteúdo mostrando resultados clínicos (85% conversão, faturamento dobrado)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Criar conteúdo educativo sobre Desinflamação, Microbiota e Dados Preditivos', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 5, 'Posicionar parceria Renata + Rodrigo Moura como diferencial (nutri + farmacêutico)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Estruturação da Mentoria PDM e Nutrição 4P', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 1, 'Finalizar arquitetura da mentoria com Sistema PDM de Negócios', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 2, 'Estruturar módulo de Dados Preditivos para nutricionistas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Estruturar módulo de Tratamento com Microbiota (Protocolo PDM)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Estruturar módulo de Engenharia de Vendas para consultório (R$3.500/tratamento)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 5, 'Criar templates e ferramentas práticas: protocolos clínicos, scripts de venda', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Conteúdo e Construção de Autoridade', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 1, 'Criar linha editorial estratégica para Instagram focada em B2B (nutricionistas)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 2, 'Produzir conteúdo de prova social com cases de nutricionistas que aplicaram o método', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Documentar cases com números reais (ticket médio, conversão, faturamento)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Criar sequência de aquecimento pré-lançamento para base de contatos', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Captação e Vendas', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 1, 'Ativar base de nutricionistas conhecidas e ex-alunas com campanha segmentada', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 2, 'Realizar aula ao vivo demonstrando o Protocolo PDM na prática', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Conduzir calls de vendas individuais com nutricionistas interessadas', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Executar follow-up e fechamento de vendas', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 5, 'Formalizar contratos e fazer onboarding das mentoradas', 'pendente', 'mentorado', 5, 'dossie_auto');
END $$;


-- ===== MENTORADO: Rosalie Matuk Fuentes Torrelio (id=135) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (135, 'PLANO DE AÇÃO | ROSALIE MATUK', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 1, 'Revisar o Storytelling e validar narrativa de autoridade em gestão comercial médica', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 2, 'Revisar o Público-alvo e alinhar perfil ideal (médicos com clínica ativa)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Revisar a Tese do produto e proposta de valor da mentoria de gestão comercial', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Revisar a Arquitetura do produto (POPs, CRM, IA para SDR, funil de conversão)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Revisar a Oferta e estrutura de precificação da mentoria online de 6 meses', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Posicionamento como Mentora de Gestão Comercial Médica', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 1, 'Atualizar bio do Instagram com posicionamento de mentora em gestão comercial para médicos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 2, 'Criar destaques estratégicos: Sistema Comercial, CRM, IA, Resultados, Mentoria', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Produzir conteúdo mostrando bastidores do sistema comercial da própria clínica', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Criar conteúdo educativo sobre POPs, CRM Ramper e Agente IA para SDR', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Documentar sistema de conversão: IA qualifica → SDR agenda → consulta paga → fechamento', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Estruturação da Mentoria Online de Gestão Comercial', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 1, 'Finalizar arquitetura da mentoria online de 6 meses para médicos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 2, 'Estruturar módulo de implantação de POPs comerciais na clínica', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Estruturar módulo de CRM e automação com Ramper', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Estruturar módulo de Agente IA para qualificação e SDR automatizado', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Criar templates de POPs, scripts de SDR e configuração de CRM para alunos', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Ativação da Rede de Relacionamento', 'passo_executivo', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 1, 'Mapear e segmentar os 1.000+ médicos dos grupos de WhatsApp', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 2, 'Criar campanha de aquecimento direcionada para médicos com clínica ativa', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Produzir conteúdo de prova social com resultados da própria clínica', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Realizar aula ao vivo gratuita sobre gestão comercial para médicos via WhatsApp', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Validação e Vendas via WhatsApp', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 1, 'Abrir inscrições com oferta direcionada para médicos dos grupos de WhatsApp', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 2, 'Conduzir calls de vendas individuais com médicos interessados', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Executar follow-up estruturado com 5 pontos de contato (como no sistema próprio)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Formalizar contratos e fazer onboarding dos mentorados', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;
