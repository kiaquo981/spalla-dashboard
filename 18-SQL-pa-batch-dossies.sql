-- ============================================================================
-- BATCH INSERT: Planos de Ação extraídos de 29 Dossiês Estratégicos (PDFs)
-- Gerado em: 2026-03-08
-- Fonte: /Users/kaiquerodrigues/Downloads/Dossies_Spalla/*.pdf
--
-- NOTA: Este arquivo contém PAs para 29 mentorados.
-- Os 7 mentorados já cobertos pelo 17-SQL-pa-batch-insert.sql foram excluídos:
--   Dani(1), Rafael(8), Karine(34), Marina(41), Mônica(43),
--   Letícia Oliveira(45), Tayslara(138), Yara(137)
--
-- ⚠️  ATENÇÃO: Alguns mentorados JÁ possuem PAs no banco (created_by='migração v1').
--     Se quiser SUBSTITUIR, rode primeiro:
--     DELETE FROM pa_acoes WHERE plano_id IN (SELECT id FROM pa_planos WHERE mentorado_id = XX);
--     DELETE FROM pa_fases WHERE plano_id IN (SELECT id FROM pa_planos WHERE mentorado_id = XX);
--     DELETE FROM pa_planos WHERE mentorado_id = XX;
--
-- ⚠️  Danyella Truiz usa id=999 (placeholder) — substituir pelo ID correto.
-- ============================================================================


-- ===== MENTORADO: Amanda Ribeiro (id=32) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (32, 'PLANO DE AÇÃO | AMANDA RIBEIRO', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 32, 1, 'Revisar o Storytelling e validar narrativa de autoridade', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 2, 'Revisar o Público-alvo e alinhar perfil ideal de mentorada', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 3, 'Revisar a Tese do produto e proposta de valor', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 4, 'Revisar a Arquitetura do produto (módulos e entregáveis)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 5, 'Revisar a Oferta e estrutura de precificação', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 6, 'Revisar o Pitch de vendas e argumentação comercial', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Identidade e Posicionamento Digital', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 32, 1, 'Definir nome e identidade visual da mentoria', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 2, 'Atualizar bio do Instagram com novo posicionamento', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 3, 'Organizar destaques do perfil com narrativa estratégica', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 4, 'Atualizar posts fixados com conteúdo de autoridade', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Estruturação da Oferta e Produto', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 32, 1, 'Finalizar arquitetura da mentoria em grupo (6 meses)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 2, 'Gravar aulas dos 3 pilares (Conversão, Atração, Gestão)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 3, 'Preparar bônus (Roteiro de Consulta, Follow-up, Framework de Crenças)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 4, 'Configurar área de membros ou pasta de entrega', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 5, 'Criar grupo exclusivo no WhatsApp para mentoradas', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Estratégia de Conteúdo e Aquecimento', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 32, 1, 'Definir linha editorial estratégica para Instagram', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 2, 'Criar conteúdo de bastidores da clínica Casa Amara', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 3, 'Produzir conteúdo de prova social (depoimentos e resultados)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 4, 'Criar sequência de aquecimento pré-lançamento da mentoria', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Captação e Vendas', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 32, 1, 'Ativar base de pacientes e ex-alunos com campanha segmentada', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 2, 'Realizar calls de vendas com interessadas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 3, 'Executar follow-up e fechamento de vendas', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 4, 'Formalizar contratos e fazer onboarding das alunas', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Entrega da Mentoria (Pós-Venda)', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 32, 1, 'Enviar boas-vindas e liberar acesso aos materiais', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 2, 'Realizar call de diagnóstico individual com cada mentorada', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 3, 'Conduzir encontros quinzenais ao vivo (2h cada)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 4, 'Acompanhar e responder no grupo WhatsApp diariamente', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 32, 5, 'Coletar depoimentos dos mentorados mensalmente', 'pendente', 'mentorado', 5, 'dossie_auto');
END $$;


-- ===== MENTORADO: Betina Franciosi (id=145) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (145, 'PLANO DE AÇÃO | BETINA FRANCIOSI', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 145, 1, 'Revisar o público-alvo B2B (médicos estabelecidos)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 2, 'Revisar o posicionamento anti-genérico da mentoria', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 3, 'Revisar a oferta e definir limite entre core e bônus', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 4, 'Revisar a estratégia de funil B2B (separada do perfil B2C)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 5, 'Revisar a arquitetura do produto (Atração + Conversão + Gestão + Tech)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Criação de Marca e Identidade da Mentoria', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 145, 1, 'Definir nome e identidade visual da mentoria', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 2, 'Criar perfil B2B no Instagram dedicado à mentoria', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 3, 'Estruturar bio, destaques e identidade do novo perfil', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 4, 'Definir precificação final e estrutura de pagamento', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Estruturação do Produto e Método', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 145, 1, 'Documentar o método de venda testado na própria clínica', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 2, 'Estruturar módulo de CRM + IA + bot de qualificação como bônus', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 3, 'Criar template do dashboard financeiro para alunos', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 4, 'Definir cronograma de entrega (imersão + acompanhamento)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 5, 'Planejar gestão do tempo da dupla durante entrega', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Construção de Prova Social B2B', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 145, 1, 'Documentar resultados próprios (lista de espera, conversão 44-50%)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 2, 'Criar conteúdo mostrando bastidores do NEGÓCIO (não só cirurgia)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 3, 'Mapear e ativar rede de colegas médicos para indicações', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 4, 'Produzir cases com números reais para funil de autoridade', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Captação e Primeiro Lançamento', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 145, 1, 'Construir funil de captação B2B (landing page + formulário)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 2, 'Ativar rede de contatos médicos com convite direto', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 3, 'Realizar calls de vendas consultivas com interessados', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 4, 'Fechar primeiros alunos e formalizar contratos', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Entrega e Imersão Presencial', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 145, 1, 'Preparar espaço da clínica em SP para imersão presencial', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 2, 'Realizar onboarding dos alunos com acesso a materiais e CRM', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 3, 'Conduzir imersão presencial com a primeira turma', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 145, 4, 'Coletar depoimentos e resultados da primeira turma', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;


-- ===== MENTORADO: Camille Pinheiro Bragança (id=49) =====
DO $$
DECLARE _plano_id UUID; _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by) VALUES (49, 'PLANO DE AÇÃO | CAMILLE BRAGANÇA', 'fases', 'nao_iniciado', 'dossie_auto_v2') RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem) VALUES (_plano_id, 49, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto') RETURNING id INTO _fase_id;
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 49, 1, 'Revisar o Plano para Clínica (oferta/ancoragem/venda/funil)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 49, 2, 'Revisar o Público-alvo (pacientes de alto padrão)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 49, 3, 'Revisar a Oferta e estrutura de precificação', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 49, 4, 'Revisar a Arquitetura do produto (VIP presencial)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 49, 5, 'Revisar a Estratégia do funil de vendas', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem) VALUES (_plano_id, 49, 'Implementar Funil de Vendas', 'fase', 2, 'nao_iniciado', 'dossie_auto') RETURNING id INTO _fase_id;
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 49, 1, 'Definir datas do presencial VIP', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 49, 2, 'Abordar as 2 interessadas que já demonstraram interesse', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 49, 3, 'Assistir aula de vendas da plataforma', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 49, 4, 'Realizar call de vendas com interessados', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 49, 5, 'Fazer fechamento de vendas e formalizar contrato', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 49, 6, 'Fazer onboarding dos alunos', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem) VALUES (_plano_id, 49, 'Estruturação dos Ativos Comerciais', 'fase', 3, 'nao_iniciado', 'dossie_auto') RETURNING id INTO _fase_id;
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 49, 1, 'Ajustar oferta da clínica (ancoragem e ticket)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 49, 2, 'Ajustar venda na consulta (script e abordagem)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 49, 3, 'Ajustar funil comercial da clínica', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem) VALUES (_plano_id, 49, 'Lapidação do Perfil do Instagram', 'fase', 4, 'nao_iniciado', 'dossie_auto') RETURNING id INTO _fase_id;
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 49, 1, 'Atualizar bio com posicionamento de referência em lábios naturais', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 49, 2, 'Organizar destaques com narrativa estratégica', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 49, 3, 'Iniciar produção de conteúdo seguindo guia de ideias', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem) VALUES (_plano_id, 49, 'Validação do VIP e Geração de Cases', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto') RETURNING id INTO _fase_id;
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 49, 1, 'Formatar conhecimento tácito em método replicável', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 49, 2, 'Executar primeiro VIP presencial com alunos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 49, 3, 'Documentar resultados e coletar depoimentos', 'pendente', 'mentorado', 3, 'dossie_auto');
END $$;


-- ===== MENTORADO: Carolina Sampaio (id=42) =====
DO $$
DECLARE _plano_id UUID; _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by) VALUES (42, 'PLANO DE AÇÃO | CAROLINA SAMPAIO', 'fases', 'nao_iniciado', 'dossie_auto_v2') RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem) VALUES (_plano_id, 42, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto') RETURNING id INTO _fase_id;
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 42, 1, 'Revisar público-alvo (oftalmologistas em fase madura)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 42, 2, 'Revisar posicionamento como formadora técnica premium', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 42, 3, 'Revisar oferta do Treinamento VIP (Hand-On + Observer)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 42, 4, 'Revisar estratégia do funil de captação de alunos', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem) VALUES (_plano_id, 42, 'Sistematização do Método', 'fase', 2, 'nao_iniciado', 'dossie_auto') RETURNING id INTO _fase_id;
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 42, 1, 'Criar nome para o método (diagnóstico, marcação, CO2)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 42, 2, 'Sistematizar critérios técnicos em processo replicável', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 42, 3, 'Definir as 4 técnicas cirúrgicas ensinadas no VIP', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 42, 4, 'Estruturar fluxo didático: Diagnóstico > Observatório > Prática', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem) VALUES (_plano_id, 42, 'Posicionamento Digital e Conteúdo', 'fase', 3, 'nao_iniciado', 'dossie_auto') RETURNING id INTO _fase_id;
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 42, 1, 'Atualizar perfil do Instagram com posicionamento de formadora', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 42, 2, 'Criar conteúdo de autoridade técnica (bastidores cirúrgicos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 42, 3, 'Produzir conteúdo diferenciando técnica premium vs genérica', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem) VALUES (_plano_id, 42, 'Estruturação da Oferta Comercial', 'fase', 4, 'nao_iniciado', 'dossie_auto') RETURNING id INTO _fase_id;
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 42, 1, 'Definir formato final do VIP (presencial, turma de 2)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 42, 2, 'Definir precificação (Hand-On vs Observer) com ancoragem', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 42, 3, 'Estruturar script de vendas para calls', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem) VALUES (_plano_id, 42, 'Captação e Vendas', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto') RETURNING id INTO _fase_id;
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 42, 1, 'Ativar demanda latente de colegas interessados', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 42, 2, 'Realizar calls e fechar primeiros alunos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 42, 3, 'Executar primeiro VIP presencial', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 42, 4, 'Coletar depoimentos para próximas turmas', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;


-- ===== MENTORADO: Caroline Bittencourt (id=40) =====
DO $$
DECLARE _plano_id UUID; _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by) VALUES (40, 'PLANO DE AÇÃO | CAROLINE BITTENCOURT', 'fases', 'nao_iniciado', 'dossie_auto_v2') RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem) VALUES (_plano_id, 40, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto') RETURNING id INTO _fase_id;
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 40, 1, 'Revisar público-alvo (profissionais saúde R$50-150k)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 40, 2, 'Revisar posicionamento como Mentora-Executora', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 40, 3, 'Revisar oferta (Sistema de Escala Sustentável)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 40, 4, 'Revisar arquitetura dos 4 pilares', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem) VALUES (_plano_id, 40, 'Estabilização do Marketing da Zentha Clinic', 'fase', 2, 'nao_iniciado', 'dossie_auto') RETURNING id INTO _fase_id;
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 40, 1, 'Definir posicionamento de tráfego (brega vs high-ticket)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 40, 2, 'Estabilizar faturamento acima de R$300k/mês', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 40, 3, 'Comunicar Sistema de 4 Pilares no Instagram', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem) VALUES (_plano_id, 40, 'Estruturação do Produto de Mentoria', 'fase', 3, 'nao_iniciado', 'dossie_auto') RETURNING id INTO _fase_id;
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 40, 1, 'Documentar Sistema de Escala Sustentável em formato ensinável', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 40, 2, 'Definir formato (grupo + imersão presencial na Zentha)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 40, 3, 'Definir precificação com ancoragem (R$25k target)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 40, 4, 'Criar materiais de suporte (checklists, templates)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem) VALUES (_plano_id, 40, 'Lapidação do Perfil e Conteúdo', 'fase', 4, 'nao_iniciado', 'dossie_auto') RETURNING id INTO _fase_id;
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 40, 1, 'Atualizar bio com posicionamento de mentora de gestão', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 40, 2, 'Criar conteúdo de bastidores da Zentha Clinic', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 40, 3, 'Produzir storytelling de superação (garagem → clínica 300m²)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem) VALUES (_plano_id, 40, 'Captação e Vendas', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto') RETURNING id INTO _fase_id;
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 40, 1, 'Ativar lista de ~400 profissionais dos Melhores Amigos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 40, 2, 'Realizar calls de vendas consultivas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 40, 3, 'Formalizar contratos e fazer onboarding', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 40, 4, 'Conduzir imersão presencial na Zentha Clinic', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;
-- ===== MENTORADO: Jordanna Diniz (id=144) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (144, 'PLANO DE AÇÃO | JORDANNA DINIZ', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico (explícita no dossiê)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 1, 'Revisar Storytelling', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 2, 'Revisar Público-alvo', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 3, 'Revisar Tese do Produto', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 4, 'Revisar Arquitetura do Produto', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 5, 'Revisar Oferta', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 1: Estruturação da Mentoria
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Fase 1: Estruturação da Mentoria', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 1, 'Definir nome oficial da mentoria de 6 meses', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 2, 'Estruturar módulos e cronograma (técnica + carreira + posicionamento)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 3, 'Definir entregáveis por módulo (aulas, hands-on, materiais)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 4, 'Preparar contrato e proposta comercial', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 2: Montagem de Equipe e Infraestrutura
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Fase 2: Equipe e Infraestrutura', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 1, 'Contratar suporte administrativo (secretária/assistente)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 2, 'Contratar gestor de tráfego e CRM', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 3, 'Criar landing page da mentoria', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 4, 'Configurar funil digital (captação → aplicação → venda)', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 3: Posicionamento Digital
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Fase 3: Posicionamento Digital', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 1, 'Lapidação do perfil Instagram (bio, destaques, foto)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 2, 'Criar conteúdo de storytelling (8 marcos da jornada)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 3, 'Gravar conteúdos de autoridade (robótica pélvica + endometriose)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 4, 'Ativar base de ex-alunos da pós-graduação como prova social', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 4: Captação e Primeira Turma
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Fase 4: Captação e Primeira Turma', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 1, 'Iniciar captação via funil digital + rede de contatos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 2, 'Realizar calls de venda consultiva (aplicação → entrevista)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 3, 'Fechar primeira turma e enviar onboarding', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 4, 'Iniciar entrega da mentoria de 6 meses', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;


-- ===== MENTORADO: Juliana Altavilla (id=9) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (9, 'PLANO DE AÇÃO | JULIANA ALTAVILLA', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 9, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 9, 1, 'Revisar Storytelling e Posicionamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 2, 'Revisar Público-alvo', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 3, 'Revisar Oferta da Mentoria Cirúrgica', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 4, 'Revisar Arquitetura do Produto', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 1: Lapidação de Perfil
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 9, 'Fase 1: Lapidação de Perfil', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 9, 1, 'Atualizar foto de perfil (crop rosto, fundo neutro)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 2, 'Ajustar nome do perfil: Dra. Juliana Altavilla | Rinoplastia Natural BH', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 3, 'Solicitar verificação do perfil (selo azul)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 4, 'Atualizar bio com versão sugerida no dossiê', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 5, 'Configurar link da bio com 3 botões (WhatsApp, Agenda, Mentoria)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 2: Destaques e Posts Fixados
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 9, 'Fase 2: Destaques e Posts Fixados', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 9, 1, 'Criar 7 destaques ordenados (Historia, Pacientes, Procedimentos, Bastidores, Lifestyle, Mentoria, Prova)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 2, 'Fixar post Historia (carrossel jornada pessoal)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 3, 'Fixar post Marco Autoridade/Prova Mentoria (reels)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 4, 'Fixar post Prova Cliente (reels antes/depois)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 5, 'Fixar post O Que É a Mentoria (carrossel explicativo)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 3: Estratégia de Conteúdo
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 9, 'Fase 3: Estratégia de Conteúdo', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 9, 1, 'Gravar conteúdos de autoridade (rinoplastia natural, 20 anos de experiência)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 2, 'Criar série de antes/depois com storytelling dos pacientes', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 3, 'Produzir conteúdo de bastidores (cirurgias, consultório)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 4, 'Criar conteúdo sobre a mentoria cirúrgica para médicos', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 4: Funil e Captação para Mentoria
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 9, 'Fase 4: Funil e Captação para Mentoria', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 9, 1, 'Estruturar funil de captação para mentoria cirúrgica', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 2, 'Criar formulário de aplicação para mentorados', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 3, 'Iniciar divulgação da mentoria nos canais digitais', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 9, 4, 'Realizar calls de venda e fechar primeira turma', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;


-- ===== MENTORADO: Karina Cabelino (id=136) =====
-- (PA explícito no dossiê — Revisão toda "Revisado", FASE 1 e FASE 2 definidas)
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (136, 'PLANO DE AÇÃO | KARINA CABELINO', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico (todas marcadas como Revisado)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'concluido', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 136, 1, 'Revisar Storytelling', 'concluido', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 136, 2, 'Revisar Público-alvo', 'concluido', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 136, 3, 'Revisar Tese do Produto', 'concluido', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 136, 4, 'Revisar Conteúdo Programático', 'concluido', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 136, 5, 'Revisar Oferta e Arquitetura', 'concluido', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 136, 6, 'Revisar Copy da Jornada', 'concluido', 'mentorado', 6, 'dossie_auto');

  -- Fase 1: Mínimo Viável (explícito no dossiê)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Fase 1: Mínimo Viável', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 136, 1, 'Definir nome da mentoria presencial VIP', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 136, 2, 'Preparar contrato e proposta comercial (R$20K)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 136, 3, 'Criar formulário de inscrição/aplicação', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 136, 4, 'Definir fluxo "O que fazer quando fechar" (onboarding → entrega)', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 2: Funil Caçador + Posicionamento
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Fase 2: Funil Caçador + Posicionamento', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 136, 1, 'Estruturar funil caçador (abordagem ativa)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 136, 2, 'Lapidação de perfil Instagram (Técnica Pontilhada)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 136, 3, 'Criar conteúdo de posicionamento e autoridade HOF', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 136, 4, 'Aguardar 4 alunas confirmadas para liberar Fase 3', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 3: Preparação da Turma (explícito no dossiê)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Fase 3: Preparação da Turma', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 136, 5, 'Preparar todos os materiais (PDFs, scripts, bônus)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 136, 6, 'Confirmar logística presencial (local, equipamentos, agenda 2 dias)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 136, 7, 'Enviar onboarding completo (7 dias antes da turma)', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- Fase 4: Realização e Pós-Turma
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Fase 4: Realização e Pós-Turma', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 136, 8, 'Realizar turma presencial VIP (2 dias)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 136, 9, 'Call de acompanhamento 30 dias após a turma', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 136, 10, 'Coletar depoimentos e resultados para prova social', 'pendente', 'mentorado', 3, 'dossie_auto');

END $$;


-- ===== MENTORADO: Lauanne Santos (id=33) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (33, 'PLANO DE AÇÃO | LAUANNE SANTOS', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 33, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 33, 1, 'Revisar Storytelling e Posicionamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 2, 'Revisar Público-alvo (profissionais saúde/estética R$30-100K/mês)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 3, 'Revisar Tese do Produto (The One Regional)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 4, 'Revisar Oferta e Arquitetura (R$37.870, 12 meses, 6 pilares)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 5, 'Revisar Jornada do Aluno (8 etapas)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 1: Estruturação do Produto The One Regional
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 33, 'Fase 1: Estruturação do Produto', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 33, 1, 'Definir nome oficial do programa (The One Regional ou variação)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 2, 'Estruturar os 6 pilares do método (Educação, Consultoria, Networking, Marketing, Cartão Benefícios, Entrega local)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 3, 'Definir entregas de cada pilar com cronograma 12 meses', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 4, 'Formalizar parceria com Ricardo (modelo, split, responsabilidades)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 5, 'Preparar contrato e proposta comercial (R$37.870)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 2: Jornada do Aluno e Experiências
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 33, 'Fase 2: Jornada do Aluno e Experiências', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 33, 1, 'Estruturar evento de entrada (Convite/Evento regional)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 2, 'Definir processo de Reunião Embaixadora + Diagnóstico', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 3, 'Planejar THE ONE Experience (2 dias presenciais)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 4, 'Estruturar encontros regionais + encontros extras Lauanne', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 5, 'Planejar Imersão SP como marco final da jornada', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 3: Posicionamento e Captação
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 33, 'Fase 3: Posicionamento e Captação', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 33, 1, 'Lapidação de perfil Instagram (4 pilares de posicionamento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 2, 'Criar conteúdo dos 4 pilares (Gestão, Vendas, Comunidade, Experiência real)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 3, 'Definir estratégia de captação regional (embaixadoras + eventos)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 4, 'Criar funil de venda (evento → reunião → diagnóstico → fechamento)', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 4: Lançamento da Primeira Turma
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 33, 'Fase 4: Lançamento da Primeira Turma', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 33, 1, 'Realizar primeiro evento regional de captação', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 2, 'Executar processo de vendas (reuniões + diagnósticos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 3, 'Fechar primeira turma e iniciar onboarding', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 33, 4, 'Realizar THE ONE Experience com primeira turma', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;


-- ===== MENTORADO: Letícia Ambrosano (id=37) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (37, 'PLANO DE AÇÃO | LETÍCIA AMBROSANO', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  -- Fase: Revisão do Dossiê Estratégico
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 37, 1, 'Revisar Storytelling (7 anos ICB, 2600+ pacientes)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 2, 'Revisar Público-alvo (dermatologistas e cirurgiões capilares)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 3, 'Revisar Tese do Produto (Método de Naturalidade Cirúrgica)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 4, 'Revisar Oferta (R$50K, 3 meses + 6 meses acompanhamento)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 5, 'Revisar 5 Pilares do Método (Seleção, Programação, Contraste, Visagismo, Hands-On)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 1: Estruturação da Formação/Certificação
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Fase 1: Estruturação da Formação', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 37, 1, 'Definir nome oficial da formação (Certificação em Naturalidade Cirúrgica)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 2, 'Estruturar Trilha Teórica Online (Tricologia, Cirúrgico, Contábil, Vigilância Sanitária)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 3, 'Estruturar módulo presencial (5 dias: 2 cirurgias hands-on + 3 dias consultório)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 4, 'Definir processo de certificação e critérios de aprovação', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 5, 'Preparar contrato e proposta comercial (R$50K à vista / parcelado)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 2: Produção de Materiais e Infraestrutura
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Fase 2: Materiais e Infraestrutura', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 37, 1, 'Gravar aulas da Trilha Teórica Online (4 módulos)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 2, 'Criar materiais de apoio (PDFs, protocolos, checklists cirúrgicos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 3, 'Configurar plataforma online para entrega das aulas', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 4, 'Preparar logística presencial (Campinas: cirurgias, consultório, agenda)', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 3: Posicionamento e Captação
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Fase 3: Posicionamento e Captação', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 37, 1, 'Lapidação de perfil Instagram (autoridade em transplante capilar)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 2, 'Criar conteúdo dos 5 Pilares do Método de Naturalidade Cirúrgica', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 3, 'Ativar base de 32 médicos treinados como prova social', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 4, 'Criar landing page da formação', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 5, 'Estruturar funil de captação (conteúdo → aplicação → entrevista → venda)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 4: Primeira Turma
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Fase 4: Primeira Turma', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 37, 1, 'Iniciar captação e processo de seleção de alunos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 2, 'Realizar calls de venda consultiva (90% conversão como referência)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 3, 'Fechar primeira turma e enviar onboarding + trilha teórica', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 37, 4, 'Executar módulo presencial (5 dias em Campinas) + acompanhamento 6 meses', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;


-- =============================================
-- SILVANE CASTRO (id=2)
-- =============================================
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (2, 'PLANO DE AÇÃO | SILVANE CASTRO', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  -- FASE 1: Revisão do Dossiê
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 1, 'Revisar seção de Contexto e validar posicionamento como Estrategista de Crescimento para Clínicas Médicas de Elite', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 2, 'Revisar análise de concorrentes (Flávio Augusto, Ícaro de Carvalho, Marcus Marques) e identificar gaps de diferenciação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 3, 'Revisar storytelling aprovado e validar narrativa da jornada Seven (17 anos de consultoria)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 4, 'Revisar estrutura da oferta Legacy (5 pilares) e validar ticket de R$120k-R$197k', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 5, 'Revisar arquitetura de produto e funil de entrada (Sprint Estratégico como porta de entrada)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- FASE 2: Reposicionamento e Narrativa
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Reposicionamento Estratégico e Nova Narrativa no Instagram', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 1, 'Atualizar bio do Instagram com novo posicionamento: Estrategista de Crescimento para Clínicas Médicas de Elite', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 2, 'Reorganizar destaques do Instagram com categorias: Cases, Método Seven, Legacy, Bastidores, Resultados', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 3, 'Gravar 5 conteúdos com a nova narrativa: médica que virou estrategista e já escalou +200 clínicas', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 4, 'Criar linha editorial semanal: 2x autoridade (cases/método), 2x conexão (bastidores/storytelling), 1x provocação (tese)', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- FASE 3: Organização de Cases e Provas Sociais
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Organização de Cases e Provas Sociais de Clínicas', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 1, 'Selecionar 5 cases de clínicas com resultados mensuráveis (faturamento antes/depois, % crescimento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 2, 'Documentar cada case no formato: cenário inicial, diagnóstico, intervenção Seven, resultado em números', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 3, 'Gravar depoimentos em vídeo com donos das clínicas atendidas (mínimo 3 vídeos)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 4, 'Criar carrossel de case para Instagram com dados reais de crescimento de clínicas', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- FASE 4: Estruturação do Funil e Oferta Legacy
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Estruturação do Funil de Entrada e Oferta Legacy', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 1, 'Estruturar página de aplicação para o Sprint Estratégico (produto de entrada, diagnóstico de 2 dias)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 2, 'Definir critérios de qualificação para Legacy: faturamento mínimo R$350k/mês, clínica com equipe, disposição para implantar gestão', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 3, 'Criar script de call de vendas para Legacy com ancoragem nos 5 pilares e ROI projetado', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 4, 'Montar apresentação comercial do Legacy com cases, metodologia Seven e estrutura dos 6 meses', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- FASE 5: Ativação da Primeira Turma Legacy
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Ativação e Lançamento da Primeira Turma Legacy', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 1, 'Fazer lista de 20 médicos donos de clínicas que já conhecem a Seven para convite direto à primeira turma', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 2, 'Realizar 10 calls de apresentação do Legacy usando o novo script e apresentação comercial', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 3, 'Fechar mínimo de 5 médicos para primeira turma Legacy com início em até 30 dias', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 4, 'Criar campanha de lançamento no Instagram: sequência de 7 dias com storytelling, cases e abertura de vagas', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;

-- =============================================
-- TATIANA CLEMENTINO (id=38)
-- =============================================
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (38, 'PLANO DE AÇÃO | TATIANA CLEMENTINO', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  -- FASE 1: Revisão do Dossiê
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Revisar seção de Contexto e validar transição de "Especialista em Lábios" para "Especialista em Full Face"', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Revisar análise de concorrentes e validar diferenciais do Protocolo Década (5 camadas de rejuvenescimento)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Revisar storytellings por público (dentistas vs médicos) e validar narrativas de autoridade', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Revisar estrutura da oferta Full Face e validar conteúdo programático do curso', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Revisar pitch de vendas e validar argumentação para ticket premium', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- FASE 2: Reconstrução de Autoridade Digital
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Reconstrução de Autoridade e Presença Digital', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Atualizar bio do Instagram com posicionamento Full Face: Doutorado na Alemanha + Protocolo Década + 25 anos de carreira', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Gravar série de 5 Reels mostrando as 5 camadas do Protocolo Década com linguagem técnica acessível', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Criar conteúdo sobre a técnica avançada de lábios da Noruega como diferencial exclusivo no Brasil', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Publicar 3 posts de autoridade: bastidores do doutorado em Munique, prática clínica real, antes/depois com contexto técnico', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Reorganizar destaques do perfil: Protocolo Década, Full Face, Casos Clínicos, Formação Internacional, Depoimentos', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- FASE 3: Estruturação da Oferta Premium Full Face
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Estruturação da Oferta Premium Full Face', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Finalizar conteúdo programático do curso Full Face com módulos baseados nas 5 camadas do Protocolo Década', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Definir formato de entrega: hands-on presencial com pacientes reais + acompanhamento pós-curso', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Estruturar módulo exclusivo da técnica avançada de lábios trazida da Noruega', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Definir ticket e condições comerciais diferenciando público dentista e médico', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- FASE 4: Construção de Provas e Casos Clínicos
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Documentação de Casos Clínicos e Provas de Resultado', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Selecionar 10 casos clínicos com antes/depois documentados do Protocolo Década completo', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Gravar depoimentos de alunos anteriores que aplicaram técnicas aprendidas nos cursos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Criar material visual profissional dos casos: fotos padronizadas com iluminação clínica e descrição técnica', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- FASE 5: Lançamento e Captação da Primeira Turma
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Lançamento e Captação da Primeira Turma Full Face', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Criar página de inscrição/aplicação para o programa Full Face com pré-requisitos claros', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Montar sequência de lançamento: 3 lives técnicas no Instagram mostrando as 5 camadas + abertura de vagas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Ativar lista de contatos profissionais (dentistas e médicos) para convite direto à primeira turma', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Realizar calls de vendas usando o pitch validado no dossiê para fechar mínimo de 8 alunos', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;

-- =============================================
-- THIAGO WILSON DA LUZ KAILER (id=148)
-- =============================================
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (148, 'PLANO DE AÇÃO | THIAGO WILSON DA LUZ KAILER', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  -- FASE 1: Revisão do Dossiê
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 1, 'Revisar seção de Contexto e validar foco na Fase 1: consultoria para produtor rural endividado via Ígnea Agro', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 2, 'Revisar análise de concorrentes e validar diferencial de ter atuado dos dois lados (bancos e produtores)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 3, 'Revisar storytelling e validar narrativa: do advogado dos bancos ao defensor do produtor rural', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Revisar estrutura da oferta de consultoria e mapeamento de dívidas rurais (R$20M-R$100M+)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 5, 'Revisar roadmap das 3 fases definidas pela Queila (produtor rural → conteúdo distress → Axioma/IA)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- FASE 2: Posicionamento Digital e Presença no @ignea.agro
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Posicionamento Digital e Ativação do @ignea.agro', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 1, 'Definir bio do @ignea.agro com posicionamento claro: advogado que já atuou para bancos e agora defende produtores rurais endividados', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 2, 'Gravar 5 conteúdos educativos sobre armadilhas contratuais que bancos usam contra produtores rurais', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 3, 'Criar série de conteúdo "Visão 360°": como funciona a cobrança do lado do banco vs. a defesa do produtor', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Publicar 3 posts com cases reais (anonimizados) de produtores que renegociaram dívidas milionárias', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 5, 'Criar destaques: Quem Sou, Como Funciona, Cases, Dívida Rural, Perguntas Frequentes', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- FASE 3: Empacotamento da Oferta de Consultoria
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Empacotamento da Consultoria para Produtor Rural Endividado', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 1, 'Estruturar produto de entrada: Mapa da Dívida Rural (diagnóstico completo da situação do produtor com raio-X de contratos)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 2, 'Definir escopo e entregáveis da consultoria completa: análise contratual, estratégia de renegociação, acompanhamento jurídico', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 3, 'Criar apresentação comercial da Ígnea Agro com diferencial "visão dos dois lados" e resultados de renegociações', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Definir modelo de precificação respeitando restrições da OAB (consultoria, não captação de clientes)', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- FASE 4: Rede de Indicação e Captação Estratégica
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Ativação de Rede de Indicação e Primeiros Clientes', 'passo_executivo', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 1, 'Mapear 15 contatos estratégicos no agronegócio (contadores rurais, agrônomos, cooperativas) para programa de indicação', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 2, 'Criar material de apresentação para parceiros indicadores explicando o Mapa da Dívida Rural', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 3, 'Realizar 5 reuniões com produtores rurais endividados para validar oferta e ajustar comunicação', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Fechar primeiros 3 contratos de consultoria via Ígnea Agro para gerar cases e validar modelo', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;

-- =============================================
-- THIELLY PRADO (id=30)
-- =============================================
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (30, 'PLANO DE AÇÃO | THIELLY PRADO', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  -- FASE 1: Revisão do Dossiê
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Revisar seção de Contexto e validar posicionamento da Mentoria Aura Business para empresárias da beleza', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Revisar análise de concorrentes e validar diferencial: salão real com 60+ colaboradores e R$700k/mês', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Revisar storytelling e validar narrativa da jornada de cabeleireira a empresária do Aura', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Revisar os 4 pilares do Método Aura Business (Posicionamento Premium, Liderança, Experiência 360°, Crescimento)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Revisar estrutura de ticket (R$25k ancoragem / R$20k parcelado / R$15k à vista) e formato de 6 meses', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- FASE 2: Reconstrução da Presença Digital (Instagram Novo)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Reconstrução da Presença Digital após Banimento do Instagram', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Configurar novo perfil do Instagram com bio posicionada: fundadora do Aura, 60+ colaboradores, R$700k/mês, mentora de empresárias da beleza', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Criar destaques estratégicos: Método Aura, Bastidores do Salão, Resultados, Mentoria, Minha História', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Gravar 10 Reels de autoridade mostrando bastidores reais do Aura: equipe, gestão, cultura, processos', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Criar linha editorial semanal: 2x bastidores do Aura, 2x dicas de gestão para donas de salão, 1x storytelling pessoal', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Implementar estratégia de reels virais: rotina do salão, desafios de liderar 60 pessoas, transformações de gestão', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- FASE 3: Sistematização do Método Aura Business
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Sistematização do Método e Materiais da Mentoria Aura Business', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Documentar os 4 pilares do Método Aura Business em formato de manual com frameworks visuais', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Criar kit de ferramentas para mentoradas: checklist de diagnóstico, planilha de gestão, script de cultura', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Estruturar cronograma da Imersão Presencial no Aura: agenda de 2 dias com vivência real no salão', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Definir calendário dos encontros quinzenais online com temas específicos por pilar ao longo dos 6 meses', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- FASE 4: Captação e Tráfego Pago
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Estruturação de Captação e Tráfego Pago para Mentoria', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Criar página de aplicação para Mentoria Aura Business com depoimentos e números do salão Aura', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Gravar 3 criativos de anúncio: bastidores do Aura com 60 colaboradores, depoimento pessoal, resultado de mentorada', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Configurar campanha de tráfego pago com segmentação: donas de salão, faturamento R$50k+, interesse em gestão', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Criar funil de WhatsApp: aplicação → qualificação → call de vendas com script baseado nos 4 pilares', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- FASE 5: Lançamento da Primeira Turma
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Lançamento e Fechamento da Primeira Turma Aura Business', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Fazer lista de 15 donas de salão que já admiram o Aura para convite direto à primeira turma', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Realizar evento online gratuito "Bastidores do Aura" como isca para captação de mentoradas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Executar 10 calls de vendas com script dos 4 pilares e ancoragem no ticket de R$25k', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Fechar mínimo de 6 mentoradas para primeira turma com início da Imersão Presencial no Aura em até 45 dias', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;

-- ===== MENTORADO: DEYSE PORTO (id=31) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (31, 'PLANO DE AÇÃO | DEYSE PORTO', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 31, 1, 'Revisar seção de Storytelling e validar narrativa de formadora de especialistas em psiquiatria infantojuvenil', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 2, 'Revisar seção de Público-Alvo e confirmar ICP: psiquiatras e médicos que atuam ou desejam atuar em infância e adolescência', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 3, 'Revisar Tese do Produto e validar os 4 pilares da mentoria (excelência clínica, identidade, gestão de consultório, autoridade)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 4, 'Revisar Arquitetura do Produto e confirmar formato de 12 meses com encontros quinzenais e trilhas gravadas', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 5, 'Revisar seção de Oferta e validar ticket de R$20.000 a R$25.000 para Mentoria Clínica Avançada', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Consolidação do Posicionamento Digital', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 31, 1, 'Criar linhas editoriais fixas no Instagram que reforcem a tese de formadora de especialistas em PIA', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 2, 'Construir narrativa forte conectando trajetória institucional (ex-presidente Associação Catarinense de Psiquiatria) com missão educacional', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 3, 'Reposicionar comunicação do produto de "curso de casos clínicos" para "Formação ProPia — referência em PIA no Brasil"', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 4, 'Produzir conteúdo estratégico com prova social intencional (depoimentos de alunos, cases de supervisão)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 5, 'Definir e repetir tese central: "Ser referência em PIA exige raciocínio clínico refinado + identidade clara + consultório estruturado"', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Estruturação da Mentoria Anual High-Ticket', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 31, 1, 'Organizar esqueleto das trilhas gravadas para os 4 pilares (excelência clínica, identidade, gestão, autoridade)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 2, 'Definir formato de escala: encontros em grupo + acompanhamento individual em momentos-chave', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 3, 'Criar ferramentas: Mapa de Identidade Clínica, Painel de Gestão Médica, Plano de Expansão de Rede', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 4, 'Estruturar roteiro padrão de avaliação infantojuvenil como ferramenta central do Pilar 1', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 5, 'Desenvolver Scripts de Comunicação Médica (agendamento, cancelamento, pós-consulta) como bônus', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Construção do Funil de Vendas Consultivo', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 31, 1, 'Mapear os ~20 médicos da base quente altamente potenciais para a nova mentoria', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 2, 'Ativar base de ~50 alunos da formação atual com abordagem de upgrade para mentoria anual', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 3, 'Acionar rede de contatos institucional (psiquiatras, pediatras, psicólogos) como canal de indicação', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 4, 'Implementar funil de abordagem 1x1 com ligação de qualificação + call de venda estruturada', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Treinamento de Vendas e Superação de Barreiras', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 31, 1, 'Treinar script de call de venda adaptado ao tom Deyse (acolhedora, técnica, objetiva)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 2, 'Trabalhar mentalidade de ticket alto (R$20-25k): internalizar que o valor entregue justifica o investimento', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 3, 'Superar receio de vendas 1:1 — praticar com primeiros leads qualificados', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 4, 'Consumir conteúdo da plataforma de aulas Spalla sobre vendas consultivas', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Abertura da Próxima Turma da Mentoria', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 31, 1, 'Realizar ligações de qualificação com médicos da base quente usando script treinado', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 2, 'Conduzir calls de venda estruturadas para fechar mentorados na faixa de R$20-25k', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 3, 'Iniciar tráfego pago estratégico para ampliar volume de leads qualificados', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 31, 4, 'Atualizar status de cada ação no grupo de WhatsApp da Spalla conforme execução', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;


-- ===== MENTORADO: ÉRICA MACEDO (id=7) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (7, 'PLANO DE AÇÃO | ÉRICA MACEDO', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 7, 1, 'Revisar público-alvo definido (dentistas/médicos em transição de aplicador para estrategista facial)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 2, 'Validar oferta Full Regenera (R$8k à vista / 3x R$4k) e confirmar formato de 2 dias presenciais + 3 meses online', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 3, 'Revisar arquitetura do produto: 4 pilares (Preenchimento Estrutural, Fios/Bioestimuladores, Toxina Inteligente, Análise Facial)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 4, 'Revisar estratégia de funil: ativação por base/ex-alunos (~200 contatos) antes de tráfego pago', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 5, 'Alinhar posicionamento: narrativa de rejuvenescimento facial (não "harmonização"), mulher internacional/elegante/segura', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 6, 'Revisar lapidação inicial do perfil do Instagram conforme recomendação do dossiê', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Estruturação dos Ativos Comerciais', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 7, 1, 'Definir data e local do evento presencial (Rio de Janeiro - Barra da Tijuca)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 2, 'Criar formulário de aplicação para filtrar alunos qualificados', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 3, 'Criar PDF de apresentação comercial da Full Regenera com ancoragem de valor (R$65k vs R$8k)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 4, 'Estruturar conteúdo programático detalhado dos 4 pilares com técnicas específicas', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 5, 'Preparar materiais de apoio: checklist de análise facial, guia de combinação de técnicas por perfil 40+', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Lapidação do Perfil do Instagram', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 7, 1, 'Atualizar bio com posicionamento premium: rejuvenescimento facial, internacional, cirurgiã', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 2, 'Colocar link do formulário de aplicação na bio', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 3, 'Organizar destaques com estética minimalista e premium (antes/depois com compliance europeu)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 4, 'Atualizar posts fixados com conteúdo de autoridade técnica e raciocínio clínico', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 5, 'Planejar produção de conteúdo durante viagem ao Brasil (bastidores, casos, storytelling)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Implementar Funil de Vendas via Base', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 7, 1, 'Criar lista de contatos qualificados (~200 dentistas/ex-alunos no WhatsApp)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 2, 'Criar scripts de abordagem personalizada para prospecção ativa', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 3, 'Testar abordagem com 5 pessoas da base e coletar feedback', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 4, 'Ajustar abordagem conforme feedback e enviar para restante da lista', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 5, 'Criar roteiro de ligação e roteiro de call de vendas', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Execução Comercial e Fechamento', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 7, 1, 'Realizar ligações de qualificação e agendar calls de venda', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 2, 'Realizar calls de vendas com apresentação da Full Regenera', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 3, 'Fazer fechamento de vendas e formalizar com contrato', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 4, 'Realizar follow-up com contatos que não fecharam na primeira abordagem', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 7, 5, 'Fazer onboarding dos alunos matriculados na turma de validação', 'pendente', 'mentorado', 5, 'dossie_auto');
END $$;


-- ===== MENTORADO: GUSTAVO GUERRA (id=48) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (48, 'PLANO DE AÇÃO | GUSTAVO GUERRA', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 48, 1, 'Revisar público-alvo definido (oftalmologistas e cirurgiões plásticos que operam blefaroplastia)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 2, 'Validar duas faixas de oferta: 15k (observership 2 dias) e 30k (VIP 3 dias com prática cirúrgica)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 3, 'Revisar posicionamento: Mentor de Carreira e Tecnologia em Blefaroplastia Estruturada a Laser', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 4, 'Revisar arquitetura do produto: Fundamentos Laser CO2, Simulação Prática, Observership, Prática Assistida', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 5, 'Alinhar tom de comunicação: científico, responsável e alinhado às Sociedades Médicas', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Estruturação da Mentoria e Materiais', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 48, 1, 'Estruturar conteúdo da aula teórica presencial: física do laser, parâmetros, fototipos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 2, 'Preparar quadro de parâmetros e checklist de segurança por fototipo', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 3, 'Organizar protocolo de simulação prática (hands on com tomate, pele de frango)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 4, 'Definir logística do observership: centro cirúrgico, pacientes, cronograma dos 2-3 dias', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 5, 'Preparar gravação profissional da cirurgia completa (bônus para alunos)', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 6, 'Estruturar formato dos 3 meses de acompanhamento pós-mentoria', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Posicionamento Digital e Autoridade', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 48, 1, 'Atualizar perfil do Instagram com posicionamento de referência em Blefaroplastia a Laser e Speaker DEKA', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 2, 'Criar conteúdo de autoridade: parametrização do laser, diferença bisturi vs laser, resultados clínicos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 3, 'Destacar credenciais internacionais: membro de sociedades brasileira, americana, europeia e italiana', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 4, 'Produzir conteúdo sobre o diferencial da Parametrização Científica', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Captação e Qualificação de Leads', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 48, 1, 'Mapear os 30-50 colegas que já demonstraram interesse direto em mentoria/treinamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 2, 'Criar formulário de aplicação qualificando: especialidade, acesso a laser CO2, experiência cirúrgica', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 3, 'Ativar rede de contatos em congressos, sociedades médicas e grupos de especialistas', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 4, 'Explorar parceria com DEKA Brasil para indicação de médicos que adquiriram laser CO2', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 5, 'Criar apresentação comercial com ancoragem de valor (R$49k/R$117k vs R$15k/R$30k)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Execução de Vendas e Primeira Turma', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 48, 1, 'Realizar abordagem direta com médicos qualificados (prospecção ativa via WhatsApp e ligação)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 2, 'Conduzir calls de vendas com foco em ROI (2-3 cirurgias pagam o investimento)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 3, 'Fechar primeira turma (até 5 médicos oferta 15k ou até 2 médicos oferta 30k VIP)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 4, 'Formalizar contratos e fazer onboarding dos alunos com orientações pré-presencial', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Entrega e Escala do Modelo', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 48, 1, 'Executar imersão presencial da primeira turma (teoria + hands on + observership cirúrgico)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 2, 'Coletar depoimentos e documentar resultados dos primeiros alunos para prova social', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 3, 'Iniciar acompanhamento de 3 meses pós-mentoria (discussão de casos e correção de parâmetros)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 48, 4, 'Definir cronograma de turmas recorrentes alinhado com agenda cirúrgica e plano de transição para Itália', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;


-- ===== MENTORADO: HEVELLIN FÉLIX (id=36) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (36, 'PLANO DE AÇÃO | HEVELLIN FÉLIX', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 36, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 36, 1, 'Revisar posicionamento atual e validar tese da "Definição HD Tripla" como marca proprietária', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 2, 'Analisar concorrentes (Valéria Ribeiro, Júlio Lira, Face Hoff) e mapear gaps de diferenciação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 3, 'Validar público-alvo principal (dentistas 3-10 anos em harmonização facial)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 4, 'Revisar pilares do posicionamento: obsessão pelo detalhe, segurança médica, didática e repertório cirúrgico', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 5, 'Alinhar visão de futuro 12 meses: meta de R$ 2,5-3 milhões (educacional + clínica)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 36, 'Estruturação da Metodologia e Produto Educacional', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 36, 1, 'Formalizar e documentar a metodologia "Definição HD Tripla" (Técnica dos 3 Pontos + Efeito Zero + Marcação HD)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 2, 'Estruturar os 4 pilares do Programa Lipo HD: técnica HD, segurança/sedação, prática guiada, negócio/posicionamento', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 3, 'Definir formato da mentoria em grupo premium (R$ 20k) com limite de 5 alunos por turma', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 4, 'Criar protocolo de suporte pós-curso com prazo definido (3 meses)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 5, 'Gravar conteúdo online de preparação pré-presencial (farmacologia, anatomia, segurança)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 36, 'Construção de Marca e Autoridade Digital', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 36, 1, 'Refinar imagem e presença digital para alinhar com autoridade real', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 2, 'Criar biblioteca de 50+ cases antes/depois com autorização para uso pelos alunos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 3, 'Desenvolver storytelling de marca: da professora de português do Acre à Princesa da Papada', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 4, 'Estruturar conteúdo de posicionamento como referência nacional em lipo de papada HD', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 36, 'Funil de Vendas e Captação', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 36, 1, 'Montar estratégia de social seller com posts, Reels e stories que convertem', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 2, 'Treinar equipe SDR/Closer com scripts e narrativas de venda da mentoria', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 3, 'Implementar funil de captação com escassez real (turmas de máx. 5 alunos)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 4, 'Criar método de venda sem desconto com ancoragem de valor (R$ 72k valor real vs R$ 20k investimento)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 5, 'Ativar demanda reprimida da agenda clínica como fonte de leads para mentoria', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 36, 'Execução do Planejamento 2026', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 36, 1, 'Executar imersão presencial de janeiro e turma START/Impulse de março (1o trimestre)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 2, 'Lançar turma START + Impulse do 2o trimestre (junho) com formato 4 Hands e Microvasos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 3, 'Finalizar ajustes da formação online para escalar com clareza de método', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 4, 'Implementar opção Impulse 100% online para ampliar alcance geográfico', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 5, 'Romper crença de merecimento e ajustar padrão financeiro para cobrar como referência nacional', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 36, 'Escala e Previsibilidade de Faturamento', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 36, 1, 'Atingir previsibilidade de múltiplos 6 dígitos mensais combinando clínica + educacional', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 2, 'Consolidar tráfego rodando com narrativas corretas e social seller ativo', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 3, 'Equilibrar rotina entre Medicina + Consultório + Mentoria sem sobrecarregar agenda', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 36, 4, 'Preparar base para instituto próprio e linha de conteúdo premium da marca Definição HD Tripla', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;


-- ===== MENTORADO: LIVIA LYRA (id=13) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (13, 'PLANO DE AÇÃO | LIVIA LYRA', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 13, 1, 'Revisar posicionamento da PhleboAcademy como Escola de Desenvolvimento Técnico em Flebologia', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 2, 'Validar público-alvo: médicos flebologistas/cirurgiões vasculares comprometidos, éticos e travados pela insegurança', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 3, 'Analisar as 3 crenças-mãe do público (perfeição técnica, validação externa, sacerdócio/medo de crescer)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 4, 'Revisar arquitetura de produtos: PhleboAcademy (escola) + IMPULSE 2026 (programa anual)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 5, 'Confirmar tese central: segurança vem de processo e progressão, não de perfeição', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Lapidação do Perfil e Marca Pessoal', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 13, 1, 'Atualizar foto de perfil: corte mais fechado no rosto, fundo clínico, expressão de confiança', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 2, 'Alterar nome do perfil para "Dra Lívia Lyra | Cirurgiã Vascular" (posicionamento nacional)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 3, 'Reescrever bio do Instagram: incluir dor explícita e CTA orientado à ação', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 4, 'Reorganizar Linktree: priorizar agendamento, prova social, site clínico e PhleboAcademy', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 5, 'Reestruturar destaques do Instagram de 12 para 6 (História, Antes/Depois, Tratamentos, PhleboAcademy, Bastidores, Lifestyle)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Estruturação do Produto IMPULSE 2026', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 13, 1, 'Implementar formulário inteligente de diagnóstico para enquadramento de fase dos alunos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 2, 'Estruturar os 4 pilares do IMPULSE: diagnóstico estratégico, mapa de alavancas, implementação assistida, consolidação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 3, 'Montar sistema de execução no Notion com score de priorização e checklists', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 4, 'Definir estrutura das 4 estações: Clareza/Fundação, Implementação-Chave, Consolidação, Previsibilidade', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 5, 'Organizar grupos de fase para encontros mensais com ênfase ajustada à maturidade do aluno', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Comunicação e Narrativa Estratégica', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 13, 1, 'Criar destaque "História" com narrativa emocional: quem é a Dra. Lívia, por que flebologia', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 2, 'Desenvolver conteúdo abordando as 9 travas operacionais do público (medo de errar, síndrome do aprendiz eterno)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 3, 'Aplicar os 3 antídotos nas narrativas: processo acima da perfeição, coerência gera autoridade, crescer com direção preserva valores', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 4, 'Criar página de depoimentos de pacientes e antes/depois para reduzir objeções', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 5, 'Estruturar comunicação dupla: pacientes (tratamento de varizes) e médicos (formação PhleboAcademy)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Lançamento e Vendas do IMPULSE', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 13, 1, 'Definir precificação final: IMPULSE Online R$ 36k ou pacote Online + Sprint Presencial R$ 48k', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 2, 'Criar funil de captação de médicos flebologistas via conteúdo educativo e eventos presenciais', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 3, 'Estruturar Sprint Presencial IMPULSE como produto premium opcional de aceleração', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 4, 'Montar argumentação de ancoragem: investimento ultrapassaria R$ 60k se contratado separadamente', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Consolidação da Operação e Escalabilidade', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 13, 1, 'Ativar suporte do time PhleboAcademy para execução técnico-operacional com escopo claro', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 2, 'Implementar indicadores simples de acompanhamento para medir evolução dos alunos por estação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 3, 'Consolidar clínica + educação: equilibrar atendimento em BH com liderança nacional da PhleboAcademy', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 13, 4, 'Preparar caminho de ascensão ASCEND para alunos que concluem o ciclo IMPULSE', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;


-- ===== MENTORADO: MICHELLE NOVELLI YOSHIY (id=139) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (139, 'PLANO DE AÇÃO | MICHELLE NOVELLI YOSHIY', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 139, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 139, 1, 'Revisar guia de Storytelling e validar narrativa autoral (ultrassom + subincisão)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 2, 'Revisar guia de Público-alvo e confirmar perfil do médico ideal para a imersão', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 3, 'Revisar guia de Tese do Produto e alinhar diferencial competitivo (celulite isolada + ultrassom)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 4, 'Revisar guia de Conteúdo Programático e estruturar módulos da imersão presencial', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 5, 'Revisar guia de Oferta e Arquitetura e definir ticket, formato e escada de produtos', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 6, 'Revisar guia de Copy da Jornada e aprovar comunicação do funil de vendas', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 139, 'Posicionamento e Marca Autoral', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 139, 1, 'Definir nome oficial da mentoria/imersão usando Agente de Naming', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 2, 'Criar narrativa de desvinculação gradual da Gold Incision (marca própria em paralelo)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 3, 'Consolidar posicionamento como especialista em celulite com técnica guiada por ultrassom', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 4, 'Assumir publicamente o papel de capacitadora (não apenas cirurgiã) no Instagram', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 5, 'Testar narrativas-chave: "Por que minha técnica é diferente" e "Por que aprender comigo é mais seguro"', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 139, 'Estruturação do Produto Educacional', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 139, 1, 'Transformar conhecimento tácito em método ensinável com módulos claros (subincisão + ultrassom + manejo de complicações)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 2, 'Definir formato final da imersão presencial (turmas micro de 4 alunos, 2 dias, prática supervisionada)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 3, 'Selecionar e confirmar pacientes modelo para a prática hands-on do presencial', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 4, 'Preparar materiais de apoio: checklists, guias técnicos e protocolos para os alunos', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 5, 'Gravar aula introdutória (ultrassom básico) e subir como link privado na plataforma', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 139, 'Funil de Captação e Vendas', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 139, 1, 'Mapear e organizar leads orgânicos dos 6 grupos de WhatsApp (2.900+ médicos)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 2, 'Estudar roteiro de call de vendas + fechamento + follow-up (abordagem 1a1)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 3, 'Iniciar abordagem pelos leads quentes (médicos que já pediram para aprender via DM)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 4, 'Rodar abordagem em lote na base de contatos com texto + áudio no estilo natural', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 5, 'Usar Instagram como máquina de leads educacionais (conteúdo de mecanismo e raciocínio clínico)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 139, 'Preparação Operacional do Presencial', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 139, 1, 'Preparar PDF "de dúvida" (pós-call) e PDF "do comprado" (manual do participante)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 2, 'Finalizar contrato e definir procedimento de assinatura digital', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 3, 'Desenhar fluxo de onboarding completo (boas-vindas, checklist, confirmações, suporte)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 4, 'Treinar secretária para executar o roteiro de onboarding', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 139, 'Logística e Execução do Evento Presencial', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 139, 1, 'Definir logística exata do dia (sequência, tempos, pausas, fluxo de prática na clínica)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 2, 'Organizar welcome coffee e estrutura de recepção dos alunos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 3, 'Confirmar informações de hotel e deslocamento para envio aos participantes', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 139, 4, 'Estruturar jornada pós-presencial: 3 encontros online / 3 meses (revisão de casos + dúvidas)', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;


-- ===== MENTORADO: MIRIAM ALVES (id=50) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (50, 'PLANO DE AÇÃO | MIRIAM ALVES', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 50, 1, 'Revisar guia de Público-alvo e validar perfil do oftalmologista ideal (R1-R3 / recém-formados)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 2, 'Revisar guia de Oferta e confirmar formato da mentoria (Fellow virtual + imersão presencial)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 3, 'Revisar guia de Arquitetura do Produto e alinhar trilha (planejamento > exames > cirurgias > casos)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 4, 'Revisar guia de Estratégia do Funil e definir modelo de captação de oftalmologistas', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 5, 'Revisar guia de Lapidação de Perfil e validar posicionamento digital como capacitadora', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Posicionamento e Autoridade Digital', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 50, 1, 'Atualizar bio do Instagram com credenciais de autoridade (Harvard, +2.400 cirurgias, +11 anos)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 2, 'Criar post fixado contando trajetória e marcos de autoridade (residência, pós-doc Harvard)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 3, 'Transicionar comunicação de "médica que opera" para "referência que capacita oftalmologistas"', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 4, 'Definir tese norteadora: "Ensino o que a residência não ensina: raciocínio clínico e planejamento refracional"', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 5, 'Produzir conteúdos com profundidade técnica (refração apurada, indicação cirúrgica, leitura de exames)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Estruturação do Produto (Mentoria em Cirurgia Refrativa)', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 50, 1, 'Mapear temas que domina e quer ensinar (refração, planejamento, leitura de exames, indicação cirúrgica)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 2, 'Separar conteúdo em categorias: base teórica, casos reais e cirurgias gravadas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 3, 'Estruturar trilha progressiva (planejamento > exames > cirurgias gravadas > discussão de casos)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 4, 'Definir formato final: módulos online + possível imersão presencial em São Paulo', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 5, 'Definir precificação e modelo de negócio (ticket alto, turmas pequenas, liberação progressiva)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Validação Estratégica e Captação', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 50, 1, 'Retomar contato com oftalmologistas interessados que já procuraram aprender', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 2, 'Preparar e realizar calls de vendas com interessados (roteiro + qualificação)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 3, 'Abordar restante da base de contatos com abordagem personalizada', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 4, 'Diferenciar-se pela ética e critério (não banalizar indicação cirúrgica)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Organização de Conteúdo e Gravações', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 50, 1, 'Organizar acervo de cirurgias gravadas para uso como material didático', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 2, 'Gravar módulos teóricos sobre refração apurada e planejamento refracional', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 3, 'Montar banco de casos reais comentados (decisão clínica + resultado)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 4, 'Configurar plataforma de aulas e definir fluxo de onboarding dos alunos', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Lapidação de Perfil e Plano de Conteúdo', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 50, 1, 'Executar lapidação completa do perfil do Instagram (bio, destaques, feed estratégico)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 2, 'Criar plano de conteúdo focado nos 4 pilares: segurança, planejamento, casos reais e autoridade Harvard', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 3, 'Solicitar à equipe CASE a segunda etapa da lapidação de perfil e plano de conteúdo', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 50, 4, 'Definir estratégia de conteúdo duplo: captação de pacientes (refrativa) + captação de alunos (mentoria)', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;


-- ===== MENTORADO: SILVANE CASTRO (id=2) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (2, 'PLANO DE AÇÃO | SILVANE CASTRO', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  -- Fase 1: Revisão do Dossiê
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 1, 'Revisar contexto analisado e validar posicionamento como Estrategista de Crescimento para Clínicas Médicas de Elite', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 2, 'Revisar análise de concorrentes e identificar gaps de diferenciação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 3, 'Revisar público-alvo definido (médicos empresários R$350k-1M+/mês) e validar critérios de escolha', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 4, 'Revisar storytelling e aprovar narrativa base para comunicação', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 5, 'Revisar tese de posicionamento e pilares estratégicos definidos no dossiê', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 2: Reposicionamento e Comunicação
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Reposicionamento e Nova Comunicação', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 1, 'Ajustar posicionamento no Instagram de consultora genérica para estrategista de crescimento de elite', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 2, 'Definir linha editorial clara com pilares: estratégia de crescimento, decisão por números, modelo de negócio, liderança e legado', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 3, 'Gravar primeiros conteúdos com nova narrativa visceral e contraintuitiva (sair do educativo genérico)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 4, 'Organizar e documentar cases de sucesso (especialmente masculinos) como principal ativo de autoridade', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 5, 'Integrar os 3 perfis do Instagram (pessoal, Seven, School) em estratégia unificada', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- Fase 3: Estruturação da Oferta Legacy
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Estruturação da Oferta Legacy', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 1, 'Consolidar oferta Legacy como programa de aceleração de crescimento (ticket R$120-150k anual)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 2, 'Pensar em nomes para o programa Legacy e definir identidade da oferta', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 3, 'Estruturar primeira turma do Legacy (data, logística, número de vagas 8-15 clientes/ano)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 4, 'Definir modelo de receita: Legacy como carro-chefe + Signature escalando com time operacional', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 4: Funil de Vendas e Tráfego
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Funil de Vendas e Tráfego Estratégico', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 1, 'Implementar traqueamento correto de tráfego (quente/frio, UTMs, análise diária de CAC real)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 2, 'Criar anúncios baseados em dores profundas e cases reais (sair de números brutos genéricos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 3, 'Melhorar página de conversão com foco em estratégia e transformação (não em entregáveis)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 4, 'Iniciar aquecimento de base para reduzir dependência de público quente (80% das vendas)', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- Fase 5: Autoridade e Escala
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Amplificação de Autoridade e Escala Operacional', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 1, 'Planejar turnê presencial em 3 capitais (SP, RJ, BH) como reaquecimento de base e autoridade', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 2, 'Criar conteúdo semanal sobre tendências do mercado de saúde estética para posicionamento', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 3, 'Fazer call com time para plano de conteúdo e definir critérios claros para copy, edição e tráfego', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 4, 'Estruturar banco de ideias e processos de produção de conteúdo sem dependência da Silvane', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 5, 'Avaliar podcast/entrevistas como formato principal de autoridade visível', 'pendente', 'mentorado', 5, 'dossie_auto');

END $$;

-- ===== MENTORADO: TATIANA CLEMENTINO (id=38) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (38, 'PLANO DE AÇÃO | TATIANA CLEMENTINO', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Revisar contexto analisado e validar transição de Especialista em Lábios para Especialista em Full Face', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Revisar análise de concorrentes (Andressa Ballarin, Laís Silveira, Daniela Claudino, Gabriela Piovesan)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Revisar público-alvo definido (dentistas e médicos da estética facial, R$15k-60k/mês)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Revisar storytelling base e validar narrativa de superação e reconstrução de autoridade', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Revisar posicionamento e diferencial Masterização vs. Modinha como proposta de valor', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Reconstrução de Posicionamento Digital', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Atualizar imagem digital do Instagram para refletir nível real de expertise e autoridade técnica', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Criar narrativa clara sobre história, pioneirismo e diferenciais (Doutorado Alemanha, Noruega, Protocolo Década)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Produzir conteúdo demonstrando critério, processo e raciocínio clínico (não apenas resultado final)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Incluir progressivamente mais casos de full face feminino e aumentar proporção de casos masculinos', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Organizar produção de conteúdo no recesso com sugestões do dossiê (destaques e linhas editoriais)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Estruturação do Produto Premium Full Face', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Estruturar Programa de Aperfeiçoamento Full Face com técnica avançada de lábios da Noruega', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Definir formato VIP (2 pessoas, ticket R$35k) com controle e segurança', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Traduzir competência inconsciente em método ensinável com 5 camadas do Protocolo Década', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Pesquisar formato observe-se/limitação de mão com ~10 profissionais do mercado', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Definir mecanismo único comunicável que diferencia do mercado saturado de cursos básicos', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Captação de Alunos e Funil de Vendas', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Retomar aquisição de novos pacientes e tráfego pago para consultório', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Criar modelo de criativo/anúncio para captação de paciente modelo', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Manter Protocolo Década como plano com número limitado de alunos para atrair público emergente', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Usar conteúdo/posicionamento do protocolo para aumentar ticket da clínica', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Lançamento e Escala do Produto Digital', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Receber prompt/modelo para montagem de aulas do programa', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Gravar conteúdos com nova narrativa e posicionamento durante período de recesso', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Explorar contatos e parcerias internacionais (Dubai e Tônia Beauty Miami)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Participar dos encontros da mentoria e aplicar direcionamentos estratégicos', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Atingir meta de R$150-200 mil/mês somando consultório + produto digital', 'pendente', 'mentorado', 5, 'dossie_auto');

END $$;

-- ===== MENTORADO: THIAGO WILSON DA LUZ KAILER (id=148) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (148, 'PLANO DE AÇÃO | THIAGO WILSON DA LUZ KAILER', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 1, 'Revisar contexto analisado e validar foco na Fase 1: consultoria para produtor rural endividado via Ígnea Agro', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 2, 'Revisar análise de concorrentes diretos (Rogério Augusto, Produtor Sem Dívida, Deyse Amaral, João Domingos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 3, 'Revisar storytellings por público (Produtor Rural, Mercado Geral, Investidor, Advogado)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Revisar posicionamento desejado como autoridade madura no mercado de distress/agro/dívida', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 5, 'Revisar público-alvo por segmento (produtor rural, mercado geral, profissional) e validar priorização', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Empacotamento da Consultoria Estratégica Ígnea Agro', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 1, 'Formalizar e precificar a consultoria de mapeamento estratégico para produtor rural endividado (R$20M-100M+)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 2, 'Criar versão 360 da consultoria com análise aprofundada de contratos/processos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 3, 'Estruturar consultoria como entry point que converte em cliente jurídico de longo prazo', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Definir modelo de crédito do valor da consultoria nos honorários futuros de advocacia', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 5, 'Monetizar os R$300K+ que já entrega gratuitamente em análise e mapeamento estratégico', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Posicionamento Digital e Produção de Conteúdo', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 1, 'Reposicionar Instagram @ignea.agro para comunicar valor real da consultoria estratégica', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 2, 'Usar narrativa central: mudei de lado - agora uso o que aprendi contra o produtor para defender o produtor', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 3, 'Criar conteúdo respeitando restrições da OAB (gerar captação sem publicidade direta)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Escancarar a história do outro lado no marketing (diferencial de ter sido advogado dos bancos)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 5, 'Separar disciplina de narrativa entre TK Advogados (credores) e Ígnea Agro (produtores) para gerenciar conflito', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Ativação de Network e Funil Offline', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 1, 'Ativar rede de originadores em MT, RS, PR, TO, PI para captação de produtores endividados', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 2, 'Estruturar pipeline de clientes potenciais a partir de ex-clientes e contatos de 15 anos de atuação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 3, 'Organizar presença em eventos do agronegócio para posicionamento como referência em distressed assets', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Usar advogados que já consultam informalmente como canal de indicação estruturado', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Execução da Fase 1 e Preparação das Próximas Frentes', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 1, 'Validar primeiras consultorias pagas com produtores do pipeline existente', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 2, 'Documentar casos e resultados para construção de prova social e autoridade digital', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 3, 'Preparar Fase 2: conteúdo/posicionamento para mercado de distress/ativos estressados (marca pessoal)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Preparar Fase 3: oferta Axioma de análise com IA para mercado profissional (fundos/BTG) + originadores', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 5, 'Acompanhar negociação de exclusividade da Axioma com BTG/Enforce e definir impacto na estratégia geral', 'pendente', 'mentorado', 5, 'dossie_auto');

END $$;


-- ===== MENTORADO: THIELLY PRADO (id=30) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (30, 'PLANO DE AÇÃO | THIELLY PRADO', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Ler o dossiê completo da Mentoria Aura Business e anotar dúvidas', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Revisar os 4 pilares (Posicionamento Premium, Liderança, Experiência 360°, Crescimento) e identificar prioridades', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Validar o perfil de cliente ideal descrito no dossiê com a realidade atual do Salão Aura', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Mapear faturamento atual (R$700k/mês) e definir meta de crescimento para os próximos 6 meses', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Posicionamento Premium e Identidade de Marca', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Mapear o perfil do cliente ideal premium (dor, desejo, ticket médio, frequência)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Realizar auditoria visual completa do salão (fachada, ambiente interno, materiais)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Definir o serviço-âncora premium do Salão Aura com precificação estratégica', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Criar sistema de filtragem de clientes (atrair premium, desestimular low-ticket)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Redesenhar a comunicação digital do salão com posicionamento premium consistente', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Liderança e Cultura Organizacional', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Definir valores e DNA cultural do Salão Aura com a equipe de 60+ colaboradores', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Estruturar processo de contratação alinhado aos valores culturais definidos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Implementar rituais de cultura (reuniões semanais, reconhecimentos, alinhamentos)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Criar programa de onboarding para novos colaboradores com imersão na cultura', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Estabelecer sistema de feedback contínuo e metas individuais por função', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Experiência 360° do Cliente', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Redesenhar a jornada completa do cliente (do agendamento ao pós-serviço)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Criar ambiência sensorial no salão (aromas, música, iluminação, texturas)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Implementar rituais de encantamento em cada ponto de contato com o cliente', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Padronizar o atendimento com script e protocolo para toda a equipe', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Criar sistema de pós-venda com reativação e fidelização de clientes premium', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 6, 'Criar ambiente instagramável para gerar mídia espontânea dos clientes', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Estratégias de Crescimento e Presença Digital', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Reconstruir perfil do Instagram (conta banida) com estratégia de conteúdo premium', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Criar campanhas temáticas mensais para ativação de clientes via mídia social', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Estruturar parcerias estratégicas locais para atração de público premium', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Desenvolver pacotes de alto valor com upsell e cross-sell entre serviços', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Implementar sistema de agendamento online e reativação automática de clientes inativos', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Estruturação da Mentoria Digital Aura Business', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Sistematizar o Método Aura em módulos ensinável para donas de salão (R$50-200k/mês)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Definir formato híbrido da mentoria (6 meses, encontros quinzenais + suporte)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Criar página de vendas e materiais de ancoragem (R$25k) para a mentoria', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Iniciar tráfego pago segmentado para donas de salão consolidados', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;

-- ===== MENTORADO: LUCIANA SARAIVA (id=10) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (10, 'PLANO DE AÇÃO | LUCIANA SARAIVA', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 10, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 10, 1, 'Revisar análise de perfil do Instagram e identificar gaps de posicionamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 2, 'Validar o público-alvo definido (dentistas com consultório que querem crescer premium)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 3, 'Mapear faturamento atual (+R$500k/mês) e definir meta de crescimento com a mentoria', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 4, 'Revisar a Tese do produto e proposta de valor do Método Elleve (5 pilares)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 5, 'Revisar o Pitch de vendas e argumentação comercial', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 10, 'Otimização de Perfil e Posicionamento Digital', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 10, 1, 'Atualizar foto de perfil profissional com enquadramento e iluminação estratégicos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 2, 'Reescrever nome e bio do Instagram com posicionamento claro para dentistas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 3, 'Substituir link do WhatsApp por landing page estratégica com formulário de aplicação', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 4, 'Criar os 8 destaques estratégicos do funil (Método, Resultados, Bastidores, FAQ, etc.)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 5, 'Fixar 3 posts estratégicos no topo do feed (História, Método Elleve, Provas Sociais)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 10, 'Estratégia de Conteúdo e Autoridade', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 10, 1, 'Reduzir conteúdo estético e aumentar conteúdo estratégico/vendas no feed', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 2, 'Implementar os 4 pilares de conteúdo: Autoridade Técnica, Storytelling, Prova Social, Oferta', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 3, 'Criar calendário editorial semanal com linhas editoriais definidas no dossiê', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 4, 'Produzir conteúdos de storytelling usando os 25 anos de experiência e a clínica de 1.500m²', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 5, 'Publicar provas sociais e resultados de mentoradas de forma consistente (2x/semana)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 10, 'Funil de Vendas e Captação de Leads', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 10, 1, 'Criar landing page do Método Elleve com copy estratégica e formulário de aplicação', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 2, 'Estruturar funil de entrada: conteúdo > destaque > link na bio > landing page > call', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 3, 'Implementar as 8 ideias de anúncios definidas no dossiê para tráfego pago', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 4, 'Criar sequência de nutrição para leads que aplicaram mas não agendaram call', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 10, 'Estruturação da Oferta High Ticket', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 10, 1, 'Estruturar a oferta do Método Elleve com ancoragem de valor e entregáveis claros', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 2, 'Criar script de call de vendas high ticket focado em vendas consultivas para dentistas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 3, 'Definir precificação premium com opções de parcelamento e pagamento à vista', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 4, 'Desenvolver materiais de apoio para a call de vendas (apresentação, cases, depoimentos)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 10, 'Escala e Experiência do Paciente Premium', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 10, 1, 'Sistematizar o módulo de experiência do paciente premium dentro do Método Elleve', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 2, 'Criar programa de acompanhamento pós-mentoria para retenção e indicações', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 3, 'Estruturar versão em grupo do Método Elleve para escalar após validação individual', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 10, 4, 'Iniciar tráfego pago segmentado para dentistas com os criativos validados organicamente', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;

-- ===== MENTORADO: MARIA SPINDOLA (id=39) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (39, 'PLANO DE AÇÃO | MARIA SPINDOLA', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 39, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 39, 1, 'Revisar o Método ACE (Alignment, Credibility, Execution) + Inteligência Cultural', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 2, 'Validar o público-alvo (mulheres gerentes/coordenadoras em multinacionais, 28-45 anos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 3, 'Revisar a precificação (R$18k parcelado / R$14k à vista) e ajustar se necessário', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 4, 'Revisar a Arquitetura do produto (4 pilares: Alignment, Credibility, Execution + Códigos Invisíveis)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 39, 'Construção de Autoridade Digital', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 39, 1, 'Otimizar perfil do Instagram com posicionamento claro de mentora de carreira corporativa', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 2, 'Otimizar LinkedIn corporativo como prova de autoridade (doutorado aos 24, gerente global)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 3, 'Publicar conteúdo 5-7x por semana no Instagram com tese: excelência técnica não basta', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 4, 'Criar conteúdos de storytelling usando os 14 anos de carreira em multinacionais', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 5, 'Superar bloqueio de mentalidade sobre cobrar pelo conhecimento e se posicionar como mentora', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 39, 'Estruturação do Método ACE e Produto', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 39, 1, 'Estruturar Pilar 1 (Alignment): exercícios de autodescoberta, dia perfeito, valores vs. demandas', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 2, 'Estruturar Pilar 2 (Credibility): Matriz de Valor Raro, leitura de stakeholders, autoapresentação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 3, 'Estruturar Pilar 3 (Execution): mapeamento do jogo corporativo, plano de visibilidade, estratégia de saída/permanência', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 4, 'Estruturar Pilar 4 (Inteligência Cultural): códigos culturais, habilidades sociais corporativas, etiqueta cross-cultural', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 5, 'Criar ferramentas de apoio: Template Dia Perfeito, Matriz Valor x Raridade, Mapa do Poder, Guia IC', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 39, 'Funil de Autoridade e Captação', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 39, 1, 'Criar formulário de aplicação (Typeform/Google Forms) com filtros de qualificação', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 2, 'Colocar link do formulário na bio do Instagram e nos stories 2x/semana', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 3, 'Montar lista de prospecção ativa: ex-colegas, seguidoras com perfil executivo, contatos de networking', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 4, 'Criar 3 scripts de abordagem (Direta, Antecipação, Calorosa) e testar com 5 pessoas', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 5, 'Estruturar ligação de qualificação de 5 minutos com script de perguntas de dor e meta', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 39, 'Validação e Primeiras Vendas', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 39, 1, 'Estruturar script da call de diagnóstico e venda (30-45 min) com ancoragem de R$50k', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 2, 'Realizar as primeiras 5 calls de diagnóstico usando o script do dossiê', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 3, 'Usar a palestra para grupo de 20 mulheres como evento de validação e conversão em lote', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 4, 'Coletar depoimentos e cases das mentoradas de validação (6 mulheres, 2 pagantes)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 39, 'Escala e Oferta em Grupo', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 39, 1, 'Após validar metodologia individual, estruturar oferta em grupo (6 meses, R$8k parcelado)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 2, 'Gravar trilhas de conteúdo a partir das calls individuais, organizadas por pilar ACE', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 3, 'Criar grupo de suporte (WhatsApp/Telegram) ancorado nas aulas e planos de ação', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 39, 4, 'Configurar os bônus digitais: Compass AI e Maria Advisor para as mentoradas', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;


-- ===== MENTORADO: PABLO SANTOS (id=6) =====
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
  (_fase_id, _plano_id, 6, 1, 'Revisar storytelling e validar narrativa de autoridade técnica sem postura de guru', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 2, 'Revisar público-alvo (dentistas 3-5 anos que não dominam prótese sobre implante)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 3, 'Revisar oferta da mentoria em prótese sobre implante e implantodontia digital avançada', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 4, 'Revisar arquitetura do produto (4 pilares, jornada e entregáveis)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 5, 'Revisar estratégia do funil (base quente de ~200 ex-alunos presenciais)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 6, 'Posicionamento e Comunicação de Autoridade', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 6, 1, 'Romper padrão de escassez e assumir posição de referência grande com números reais (~R$1M/mês, 200+ implantes/mês)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 2, 'Lapidar perfil do Instagram para comunicar autoridade técnica com naturalidade', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 3, 'Criar conteúdos que mostrem resultados mensuráveis e liderança de equipe (cultura de time)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 4, 'Trabalhar trava de comunicação de grandeza — aprender a mostrar números sem autopostura humilde', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 6, 'Estruturação da Oferta e Produto', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 6, 1, 'Definir nome, promessa e data da aula/evento de captação para a mentoria', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 2, 'Simplificar entrega da mentoria em jornada clara com entregáveis definidos (lives, encontros, suporte)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 3, 'Definir critérios de entrada e processo de qualificação (seleção a dedo, 20-25 vagas)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 4, 'Estruturar cadência da mentoria: duração, módulos práticos e formato presencial + acompanhamento', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 6, 'Captação e Aquecimento da Base Quente', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 6, 1, 'Organizar lista de contatos dos ~200 ex-alunos presenciais (prioridade máxima)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 2, 'Criar grupo de WhatsApp e enviar convite personalizado para a base de contatos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 3, 'Executar convite para a base do Instagram (~170 alunos do curso online)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 4, 'Manter comunicação ativa no grupo com conteúdo de valor e aquecimento por 7 dias', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 5, 'Preparar roteiro da aula/evento de conversão com foco em prova de resultado e polaridade', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 6, 'Vendas e Fechamento', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 6, 1, 'Realizar aula/evento ao vivo com aplicação prática e call-to-action para mentoria', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 2, 'Executar abordagem pós-aula para quem fez aplicação (qualificação → call → decisão)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 3, 'Executar abordagem pós-aula para quem não fez aplicação com follow-up estruturado', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 4, 'Realizar onboarding e confirmação da turma com os mentorados selecionados', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 6, 'Produção de Conteúdo e Escala', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 6, 1, 'Iniciar produção de conteúdo estratégico para Instagram (lives cirúrgicas comentadas, análise de casos)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 2, 'Reduzir dependência do operacional clínico e liberar tempo para estratégia da mentoria', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 6, 3, 'Solicitar à equipe Case o próximo funil de tráfego pago após validar oferta com base quente', 'pendente', 'mentorado', 3, 'dossie_auto');
END $$;

-- ===== MENTORADO: PAULA E ANNA (id=47) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (47, 'PLANO DE AÇÃO | PAULA E ANNA', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 1, 'Revisar storytelling da Kava (origem, pandemia, expansão SP, cronograma reverso financeiro)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 2, 'Revisar público-alvo mentoria (arquitetos em transição de técnico para gestor, R$20-50k/mês)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 3, 'Revisar público-alvo clientes (empresários alto padrão que valorizam previsibilidade)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Revisar oferta da Mentoria Cronograma Reverso / Ordem e Obra (5 pilares, R$15-20k)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 5, 'Revisar posicionamento: de arquitetas estéticas para especialistas em gestão de obra com método', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Reposicionamento Digital e Narrativa', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 1, 'Atualizar bio e destaques do Instagram para comunicar método, gestão e cronograma reverso', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 2, 'Construir narrativa clara e consistente sobre quem são, como trabalham e por que são diferentes', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 3, 'Explicitar o cronograma reverso como mecanismo central de valor em toda a comunicação', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Limpar ruídos do perfil que comunicam atendimento generalista e afastam alto padrão', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 5, 'Criar conteúdos que mostrem bastidores de obra organizada, processo e previsibilidade', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Estruturação Comercial e Qualificação de Clientes', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 1, 'Estruturar processo de qualificação prévia de leads para filtrar clientes desalinhados antes da call', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 2, 'Criar script de apresentação comercial do acompanhamento de obra como solução', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 3, 'Definir precificação clara do acompanhamento ancorada em valor (redução de risco, previsibilidade)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Reduzir dependência do contato direto das sócias no processo comercial', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Validação do Produto Educacional (Mentoria)', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 1, 'Finalizar estrutura da Mentoria Ordem e Obra com os 5 pilares e jornada do mentorado', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 2, 'Gravar aulas estruturais de base técnica (cronograma reverso, venda de acompanhamento, gestão)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 3, 'Definir bônus da oferta (Kit Templates Visuais + Guia de Comunicação para Instagram/LinkedIn)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Preparar materiais de apoio (checklists, modelos, orientações práticas para mentorados)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Captação e Lançamento da Mentoria', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 1, 'Organizar lista de contatos de arquitetos da rede (indicações, boca a boca, colegas)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 2, 'Criar grupo de WhatsApp e executar convite para base de contatos qualificados', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 3, 'Preparar e executar aula/evento de conversão mostrando método do cronograma reverso na prática', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Executar abordagem pós-evento e fechamento das primeiras vagas da mentoria', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 5, 'Realizar onboarding estratégico individual dos mentorados selecionados', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 47, 'Aumento de Ticket e Escala do Escritório', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 47, 1, 'Aumentar ticket médio do escritório acima de R$100/m² ancorando no acompanhamento como diferencial', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 2, 'Reduzir volume de clientes desalinhados e priorizar projetos de alto padrão com gestão completa', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 3, 'Consolidar cronograma reverso como assinatura autoral do escritório Kava em toda comunicação', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 47, 4, 'Solicitar à equipe Case o próximo funil de tráfego pago após validação da mentoria', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;

-- ===== MENTORADO: RAQUI PIOLLI (id=5) =====
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
  (_fase_id, _plano_id, 5, 1, 'Revisar storytelling (trajetória Vitória → SP, crise de vendas, virada com estratégia comercial)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 2, 'Revisar público-alvo (médicos/dentistas migrando de estético paliativo para cirúrgico facial)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 3, 'Revisar oferta Formação Cirúrgica One Face Lift (6 meses, 4 pilares, R$40-60k)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 4, 'Revisar posicionamento como cirurgiã-mentora premium em face (blefaro, lift, papada, fronto)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 5, 'Revisar oferta complementar de Frontoplastia (produto mais enxuto, ~R$20k)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Posicionamento e Conteúdo Estratégico', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 5, 1, 'Construir narrativa estruturada como formadora cirúrgica premium (não apenas cirurgiã)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 2, 'Criar conteúdos de raciocínio cirúrgico no Instagram (indicação, seleção de casos, por que operar)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 3, 'Atualizar banco de provas sociais (antes/depois, depoimentos, bastidores cirúrgicos com didática)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 4, 'Manter constância em conteúdo educativo de posicionamento para profissionais e pacientes', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 5, 'Implantar processo de banco de conteúdos organizado (Notion/pastas/referências)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Funil do Consultório e Técnica de Vendas', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 5, 1, 'Ajustar campanhas com gestor de tráfego para atrair leads qualificados (blefaro, face, local, poder de investimento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 2, 'Treinar e supervisionar equipe de agendamento para melhorar qualificação e taxa de comparecimento', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 3, 'Masterizar técnica de venda em consulta (estrutura, perguntas, ancoragem, decisão imediata, sinal)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 4, 'Desenvolver habilidade de fechamento online/à distância (propostas, valor, link de entrada)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 5, 'Criar rotina de acompanhamento de métricas com gestor de tráfego para ajustar campanhas rapidamente', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Estruturação das Ofertas Premium de Mentoria', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 5, 1, 'Validar e lançar Formação One Face Lift (6 meses: observação + prática + observatório final + acompanhamento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 2, 'Definir ticket e modelo comercial da oferta premium (âncora R$60k, turma de até 4 alunos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 3, 'Estruturar oferta complementar de Frontoplastia (3 meses, observatório + prática + acompanhamento, ~R$20k)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 4, 'Gravar acervo de cirurgias do observatório para usar como bônus exclusivo das turmas', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Reorganização de Agenda e Foco Estratégico', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 5, 1, 'Planejar saída gradual da faculdade para liberar tempo e energia para o negócio principal', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 2, 'Redirecionar tempo liberado para produção de conteúdo, gestão de marketing e cuidado das turmas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 3, 'Eliminar frentes que não constroem o negócio principal (viagens improdutivas, atividades dispersas)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 4, 'Implantar rotina semanal de planejamento de conteúdo com banco de cases e bastidores', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Lançamento e Captação para Mentoria Cirúrgica', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 5, 1, 'Organizar lista de contatos qualificados (alunos faculdade, colegas cirurgiões, profissionais que já alugam sala)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 2, 'Criar campanha de captação posicionando método exclusivo (observar → praticar → revisar)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 3, 'Executar processo de vendas com calls individuais para candidatos qualificados', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 4, 'Realizar onboarding da primeira turma com alinhamento de nível técnico e objetivos cirúrgicos', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 5, 5, 'Usar centro cirúrgico próprio como ativo de autoridade e diferencial na captação B2B', 'pendente', 'mentorado', 5, 'dossie_auto');
END $$;

-- ===== MENTORADO: RENATA ALEIXO (id=44) =====
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
  (_fase_id, _plano_id, 44, 1, 'Revisar storytelling base e validar narrativa da dupla Renata + Rodrigo', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 2, 'Revisar público-alvo da mentoria (nutricionistas clínicas 3-10 anos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Revisar oferta completa: pilares, bônus, ancoragem e precificação (R$27K)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Revisar arquitetura do produto e jornada do aluno (steps, encontros, suporte)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 5, 'Revisar estratégia do funil e etapas de captação/aquecimento/vendas', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Posicionamento e Storytelling', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 1, 'Consolidar posicionamento como referência em Nutrição de Precisão e Negócios', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 2, 'Definir nome final da mentoria (Jornadas Clínicas de Alto Valor ou outra opção)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Adaptar storytelling base para conteúdos de feed, reels, bio e apresentações', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Criar argumentos de autoridade com dados proprietários (média 17 alimentos inflamatórios, taxa 85%)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 5, 'Posicionar diferencial do Sistema PDM de Negócios (técnica + vendas + dados preditivos)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Estruturação da Oferta e Produto', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 1, 'Estruturar Pilar 1 (Consultas + Exames Isolados) com aulas gravadas e materiais', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 2, 'Estruturar Pilar 2 (Protocolo PDM - Desinflamação e Microbiota) com fluxo de 90 dias', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Estruturar Pilar 3 (Jornada 5 Estrelas - Gestão de Saúde Nutricional e LTV)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Preparar bônus: scripts de venda, PITCH de consultório, painel de controle e planilhas', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 5, 'Montar sistema de evolução por steps com trilhas liberadas conforme avanço do aluno', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 6, 'Criar formato de encontros ao vivo quinzenais (estratégia + plantão técnico)', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Preparação do Funil de Lançamento', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 1, 'Definir nome, promessa e data da aula de captação', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 2, 'Criar grupo de WhatsApp e formulário de inscrição para a aula', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Estruturar lista de contatos e base do Instagram para convite', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Montar estrutura técnica para disparo de mensagens de captação', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 5, 'Executar lapidação de perfil no Instagram com posicionamento de mentora', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Captação, Aquecimento e Aula', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 1, 'Enviar convite para base de contatos e comunicação nos grupos de WhatsApp', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 2, 'Executar remarketing e aquecimento com conteúdo de autoridade', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Preparar roteiro da aula ao vivo com storytelling e demonstração do Método PDM', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Configurar setup da aplicação da mentoria (plataforma, onboarding, comunidade)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Vendas e Fechamento', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 1, 'Executar abordagem pós-aula para quem fez aplicação (follow-up personalizado)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 2, 'Executar abordagem pós-aula para quem não fez aplicação (reengajamento)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Realizar onboarding e confirmação da turma com alinhamento de expectativa', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Produzir conteúdo contínuo de autoridade para sustentação do posicionamento', 'pendente', 'mentorado', 4, 'dossie_auto');
END $$;

-- ===== MENTORADO: ROSALIE MATUK FUENTES TORRELIO (id=135) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (135, 'PLANO DE AÇÃO | ROSALIE MATUK FUENTES TORRELIO', 'fases', 'nao_iniciado', 'dossie_auto_v2')
  RETURNING id INTO _plano_id;

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 1, 'Revisar storytelling base e validar narrativa da trajetória (tombo R$400K, reconstrução)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 2, 'Revisar público-alvo (cirurgiões plásticos e médicos R$70k-R$150k/mês)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Revisar tese do produto: Gestão Comercial de Ponta a Ponta para clínicas médicas', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Revisar conteúdo programático e arquitetura dos 3 pilares + bônus', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Revisar oferta, precificação (R$15K) e copy da jornada', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 6, 'Revisar análise de concorrência e lacunas de mercado identificadas', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Posicionamento e Marca Pessoal', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 1, 'Consolidar posicionamento como médica referência em processo comercial e experiência premium', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 2, 'Reposicionar perfis do Instagram (pessoal e clínica) para comunicar mentoria, não só procedimentos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Adaptar storytelling para conteúdos de feed, reels e apresentações (vulnerabilidade + processo)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Imprimir as 11 crenças-mãe nos conteúdos de autoridade e comunicação', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Diferenciar-se dos concorrentes com POPs e IA como ativos reais', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Estruturação do Produto e Oferta', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 1, 'Estruturar Pilar 1: Funil Visível (mapeamento de leads, métricas, CRM)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 2, 'Estruturar Pilar 2: Consulta que Converte (escuta ativa, gestão de expectativa, fechamento pelo médico)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Estruturar Pilar 3: Pós-consulta e Experiência Premium (follow-up, CRM, fidelização, indicação)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Preparar bônus: POPs documentados, protocolo de experiência premium, blindagem de entrega', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Levantar números da clínica (faturamento, procedimentos/mês, ticket médio, taxa de conversão) para ancoragem', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Validação Offline e Lista de Interessados', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 1, 'Mapear rede de relacionamento ativa (grupos de WhatsApp com 1.000+ médicos)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 2, 'Ativar canais offline: Hospital Infantil, Hospital Universitário Federal, rede do Leonardo', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Explorar canal do contador como parceiro de distribuição (playbook de POPs)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Construir lista de interessados via pré-venda offline antes de escalar via Instagram', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Funil de Aula Zoom e Captação', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 1, 'Preparar roteiro da aula Zoom com storytelling de vulnerabilidade e demonstração do sistema de conversão', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 2, 'Definir data e enviar convites para rede de médicos via grupos de WhatsApp', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Criar formulário de inscrição e grupo de WhatsApp para participantes da aula', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Executar comunicação de aquecimento e remarketing pré-aula nos grupos', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Vendas, Fechamento e Onboarding', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 1, 'Executar abordagem pós-aula com follow-up estruturado', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 2, 'Quebrar objeções principais: tempo, complexidade, desconforto com preço na consulta', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Confirmar disponibilidade de agenda para dedicação à mentoria e definir formato de encontros', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Realizar onboarding da primeira turma com alinhamento de expectativa e regras da comunidade', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Iniciar produção de conteúdo contínuo para reposicionamento gradual como mentora no Instagram', 'pendente', 'mentorado', 5, 'dossie_auto');
END $$;
