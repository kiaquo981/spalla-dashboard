-- ================================================================
-- PA Batch Insert v2 — Deep Action Plans from Dossiers
-- 28 mentorados with 60-80 actions each + sub-actions
-- Requires: 19-SQL-pa-sub-acoes-schema.sql run first
-- Run in Supabase SQL Editor
-- ================================================================


-- ===== MENTORADO: JORDANNA DINIZ (id=144) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (144, 'PLANO DE AÇÃO v2 | JORDANNA DINIZ', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- FASE 1: Revisão do Dossiê Estratégico
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 1, 'Ler o dossiê completo e anotar dúvidas ou ajustes sobre contexto, posicionamento e concorrentes', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 2, 'Revisar seção de Storytelling e validar os 8 marcos narrativos (residência, Crispi, quase desistiu, endometriose, meta dos 5 anos, saída do convênio, mulher no console, chegada da Júlia)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 3, 'Revisar e aprovar o ICP principal (cirurgiãs ginecológicas robóticas, 7-15 anos de formação, modelo misto convênio/particular)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 4, 'Revisar a análise de concorrentes (Dr. Marcelo Vieira, Dr. Frederico Corrêa, mentorias genéricas) e confirmar posicionamento diferenciado', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 5, 'Validar os 4 pilares da oferta (Fluxograma de Sucesso, Precificação por Complexidade, Rede de Indicadores, Posicionamento Online)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- FASE 2: Storytelling & Narrativa Autoral
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Storytelling & Narrativa Autoral', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 1, 'Gravar o storytelling base em formato vídeo (de residente homenageada a referência nacional em cirurgia robótica)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Preparar roteiro com os marcos: residência no Viet Gama, formação com Crispi, momento que quase desistiu, descoberta da endometriose robótica', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Incluir marcos de: meta dos 5 anos operando, decisão de sair do convênio, palestra opero de salto, chegada da Júlia e decisão de monetizar', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Gravar versão completa (15-20 min) com videomaker profissional na casa/consultório', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 2, 'Criar versão curta do storytelling (2-3 min) para uso em pitch de vendas e abertura de eventos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 3, 'Selecionar as 10 frases-chave para uso recorrente na comunicação', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 4, 'Definir as 18 crenças centrais do posicionamento e associar evidências pessoais a cada uma', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Mapear crenças de carreira: Resultado vem de escolha, Posicionamento é como você entra no hospital, Precificar alto é respeito próprio', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Mapear crenças de mentalidade: Se você não colocar coroa ninguém vai colocar, Ser mulher é diferencial, Generosidade sem limite vira exploração', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Criar documento final com crença + evidência + frase de impacto para cada uma das 18 crenças', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 5, 'Adaptar storytelling para formatos: bio do Instagram, apresentações em congressos, página de vendas e anúncios', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- FASE 3: Definição de Público-alvo & ICP
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Definição de Público-alvo & ICP', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 1, 'Detalhar o ICP Fase 1 — cirurgiãs ginecológicas de robótica/minimamente invasiva com 7-15 anos de formação', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Definir perfil profissional: já opera regularmente, modelo misto convênio+particular, prática técnica consolidada', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Listar critérios de elegibilidade: não é iniciante, possui consultório, já cobra honorários, deseja estruturar carreira', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Mapear as 6 dores centrais: preso ao convênio, não sabe precificar, sem rede de indicação, medo de julgamento, sem método de conversão, trabalha muito e vive pouco', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 2, 'Documentar o perfil excluído: residentes, médicos sem prática cirúrgica, clínicos puros, perfil de marketing agressivo', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 3, 'Mapear a expansão futura do ICP: Fase 2 (robótica em outras especialidades) e Fase 3 (carreira cirúrgica transversal)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 4, 'Documentar objeções comuns do ICP e preparar respostas: Não tenho tempo, É caro, Eu já sei operar, Meus colegas vão julgar, Não tenho perfil digital', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 5, 'Validar potencial pagador: faturamento médio R$60-150k/mês do cirurgião robótico sustenta investimento de R$70k na mentoria', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- FASE 4: Estruturação da Oferta
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Estruturação da Oferta', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 1, 'Definir nome oficial da mentoria alinhado ao posicionamento de carreira cirúrgica de excelência', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 2, 'Validar a promessa central: Em 6 meses, estruturar carreira cirúrgica para reduzir convênio e consolidar modelo particular previsível', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 3, 'Estruturar a jornada de 6 meses: Fase 1 (Diagnóstico individual, dias 1-14) + Fase 2 (Implementação em grupo, meses 1-6)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Definir formato da call de diagnóstico individual (40 min): raio-x do modelo atual, identificação do pilar prioritário, 3 mudanças imediatas', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Estruturar os 12 encontros quinzenais ao vivo (90 min cada): ciclo de pilares em loop', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Definir regras do grupo de WhatsApp: somente leitura para conteúdos/avisos, dúvidas nos encontros ao vivo', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 4, 'Confirmar e estruturar os 7 bônus com valores de ancoragem (total R$57.000)', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Confirmar Bônus 1: Case Challenge — discussão de caso clínico real ao vivo (3 sessões, valor R$9.000)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Confirmar Bônus 2: Conduta de Excelência — relacionamento com hospitais e indústria (valor R$12.000)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Confirmar Bônus 3: Complicações Cirúrgicas — prevenção e condução em robótica (valor R$3.000)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 4, 'Confirmar Bônus 4: Treinamento de Concierge/Equipe — scripts de atendimento e follow-up (valor R$9.000)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 5, 'Confirmar Bônus 5: Imersão de Posicionamento Científico — entrada em sociedades, patrocínio de indústria (valor R$12.000)', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 6, 'Confirmar Bônus 7: Raciocínio Clínico na Endometriose — casos reais, condução multidisciplinar (valor R$9.000)', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 5, 'Definir precificação final: R$70.000 (12x cartão) ou R$60.000 à vista, e configurar na Kiwify', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 6, 'Limitar turma a 5-10 mentoradas para garantir acompanhamento individual', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- FASE 5: Conteúdo Programático & Módulos
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Conteúdo Programático & Módulos', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 1, 'Gravar módulo do Pilar 1: O Fluxograma de Sucesso — Consulta de Alta Conversão', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Gravar aula sobre Fase 1 — Conexão: agendamento via concierge, dossiê do paciente, recepção pessoal', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Gravar aula sobre Fase 2 — Diagnóstico: escuta ativa, perguntas direcionadas, enquadramento em 3 perfis', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Gravar aula sobre Fase 3 — Apresentação: desenhar Fluxograma de Sucesso na frente da paciente', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 4, 'Gravar aula sobre Fase 4 — Fechamento: precificação por grupo de complexidade, 3 entregas pós-cirurgia', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 2, 'Gravar módulo do Pilar 2: Precificação por Complexidade e Organização de Agenda', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Gravar aula sobre os 3 grupos de precificação: baixa (R$25k), média (R$35-40k) e alta complexidade (R$50-55k)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Gravar aula sobre cálculo de hora real, regra dos 15 dias e modelo sem retorno', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Gravar aula sobre plano de transição convênio para particular (redução progressiva 6-12 meses)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 3, 'Gravar módulo do Pilar 3: Posicionamento Offline — A Rede de Indicadores', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Gravar aula sobre mapeamento de indicadores por especialidade', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Gravar aula sobre protocolo de devolutiva pós-cirúrgica e ativação de rede', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Gravar aula sobre estratégia do Endodinner e eventos de relacionamento', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 4, 'Gravar módulo do Pilar 4: Posicionamento Online — Instagram como vitrine de confirmação de autoridade', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 5, 'Subir primeiro módulo gravado na plataforma de aulas antes de abrir inscrições', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- FASE 6: Materiais & Ferramentas de Entrega
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Materiais & Ferramentas de Entrega', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 1, 'Criar os materiais do Pilar 1 — Consulta de Alta Conversão', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Criar script de consulta versão médica (4 fases com falas-guia) + versão concierge', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Criar guia de objeções de paciente com respostas prontas (5 objeções principais)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Criar roteiro de roleplay para simulação de consulta ao vivo nos encontros', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 4, 'Criar scripts de comunicação do consultório: WhatsApp (confirmação, onboarding, follow-up)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 2, 'Criar os materiais do Pilar 2 — Precificação e Agenda', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Criar planilha de precificação por complexidade cirúrgica (editável pelo mentorado)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Criar calculadora de hora trabalhada real (convênio vs particular)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Criar template de proposta para paciente e template de reembolso', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 4, 'Criar checklist de transição convênio para particular com regra dos 15 dias', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 3, 'Criar os materiais do Pilar 3 — Rede de Indicadores', 'pendente', 'equipe_spalla', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Criar template de lista de indicadores por especialidade (20-30 potenciais)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Criar template de relatório pós-cirúrgico para indicadores', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Criar roteiro de ações de captação semanal e guia do Endodinner', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 4, 'Criar checklist Vitrine de Autoridade para o Pilar 4: perfil, destaques, provas, conteúdo mínimo', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 5, 'Criar formulário de diagnóstico individual para onboarding', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- FASE 7: Pitch & Estratégia de Vendas
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Pitch & Estratégia de Vendas', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 1, 'Ensaiar o pitch de vendas completo (20-25 min) seguindo a estrutura do dossiê', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Ensaiar bloco de Abertura: onde o público está agora (convênio, agenda cheia, margem baixa)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Ensaiar bloco de Diagnóstico Real: custo de ficar parado (R$600-800k/ano perdidos em conversão)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Ensaiar apresentação dos 4 pilares com resultados concretos de cada um', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 4, 'Ensaiar bloco de Timing (Congresso em maio) e Call-to-Action final', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 2, 'Definir estratégia de venda consultiva: oferecer call de diagnóstico gratuita (40 min) como porta de entrada', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 3, 'Preparar abordagem para lista quente: ex-alunos da pós-graduação, proctores, contatos de congressos', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 4, 'Criar sequência de mensagens para WhatsApp: convite para call, follow-up pós-call, envio de documentação', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 5, 'Gravar o pitch de vendas em vídeo para usar como webinário ou apresentação em eventos', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- FASE 8: Posicionamento Digital & Conteúdo
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Posicionamento Digital & Conteúdo', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 1, 'Reestruturar o perfil do Instagram como vitrine de autoridade para mentoria', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Reescrever bio do Instagram com posicionamento de mentora de carreira cirúrgica', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Criar destaques organizados: Sobre Mim, Método, Resultados, Mentoria, Bastidores', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Produzir 3-5 posts de posicionamento como mentora usando as crenças centrais', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 2, 'Criar calendário editorial com mix: 40% autoridade técnica, 30% carreira, 20% bastidores, 10% mentoria', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 3, 'Produzir Reels com trechos do storytelling e frases de impacto para médicos', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 4, 'Implementar rotina de produção com videomaker — 1 sessão de gravação por semana', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 5, 'Criar conteúdo específico para médicos: transição convênio-particular, precificação ética, rede de indicação', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- FASE 9: Infraestrutura & Equipe
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Infraestrutura & Equipe', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 1, 'Montar infraestrutura mínima para abrir inscrições', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Criar página de inscrição simples com descrição da mentoria + formulário de aplicação', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Redigir contrato de mentoria: objetivo, prazo de 6 meses, valor, política de cancelamento', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Configurar conta na Kiwify para pagamento', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 4, 'Criar grupo de WhatsApp com link pronto para adicionar mentorados', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 2, 'Definir as 12 datas dos encontros quinzenais e bloquear no Google Calendar', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 3, 'Configurar plataforma de aulas com módulos organizados por pilar', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 4, 'Contratar 1 pessoa de suporte/CRM para gestão operacional da mentoria', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 5, 'Contratar gestor de tráfego para campanhas futuras (pós primeira turma piloto)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- FASE 10: Captação & Funil de Vendas
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Captação & Funil de Vendas', 'passo_executivo', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 1, 'Ativar funil dominante: Eventos Científicos > Networking > Instagram', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Mapear próximos 3 congressos/eventos de cirurgia robótica para presença estratégica', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Preparar abordagem de networking em eventos: apresentação como mentora, não apenas cirurgiã', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Usar o Congresso Brasileiro de Cirurgia Robótica (Brasília, maio) como evento de captação principal', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 2, 'Reativar base de ex-alunos da pós-graduação e do curso Ecosurg com convite para call de diagnóstico', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 3, 'Ativar lista de contatos de congressos e proctores com abordagem consultiva', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 4, 'Publicar série de conteúdos posicionando a mentoria: stories de bastidores, posts sobre os 4 pilares', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 5, 'Realizar 10-15 calls de diagnóstico gratuitas para preencher as 5-10 vagas da primeira turma', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- FASE 11: Onboarding da Primeira Turma
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Onboarding da Primeira Turma', 'passo_executivo', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 1, 'Executar Semana 1 do onboarding (dias 1-7) para cada mentorado', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Enviar contrato, link de pagamento e boas-vindas por WhatsApp', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Adicionar mentorado ao grupo de WhatsApp e enviar acesso à plataforma', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Enviar formulário de diagnóstico para preenchimento antes da call individual', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 2, 'Executar Semana 2 do onboarding: call de diagnóstico individual', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Realizar call individual de 40 min: mapear cirurgias, preços, conversão, rede de indicação', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Montar plano de ação individualizado: raio-x do modelo atual, pilar prioritário, 3 mudanças imediatas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Enviar plano personalizado por escrito e agendar primeiro encontro quinzenal', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 3, 'Enviar calendário dos 12 encontros e confirmar presença no primeiro', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  -- FASE 12: Entrega & Gestão da Mentoria
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 144, 'Entrega & Gestão da Mentoria', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 144, 1, 'Conduzir os 12 encontros quinzenais ao vivo com ciclo de pilares em loop', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 144, 1, 'Quinzena A: apresentar conteúdo de um pilar com casos reais e simulações', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 2, 'Quinzena B: revisar números e resultados da implementação de cada mentorado', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 144, 3, 'Incluir 3 sessões de Case Challenge ao longo dos 6 meses nos encontros', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 144, 2, 'Acompanhar métricas de evolução: taxa de conversão, ticket médio, % convênio vs particular, indicações/mês', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 3, 'Ajustar plano individual de cada mentorado conforme evolução', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 4, 'Coletar depoimentos e resultados ao longo dos 6 meses para prova social', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 5, 'Realizar encontro de encerramento com balanço dos 6 meses e plano de continuidade', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 144, 6, 'Documentar aprendizados da turma piloto e ajustar oferta para a segunda turma', 'pendente', 'mentorado', 6, 'dossie_auto');

END $$;



-- ================================================================
-- AMANDA RIBEIRO (mentorado_id = 32)
-- Mentoria Empresária Estética | Profissionais da Saúde
-- Dossiê: Harmonização Facial + Posicionamento Estratégico
-- ================================================================
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (32, 'PLANO DE AÇÃO v2 | Amanda Ribeiro', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- ============================================================
  -- FASE 1: Revisão do Dossiê Estratégico
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 32, 1, 'Ler dossiê completo e anotar dúvidas sobre posicionamento e oferta', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 2, 'Validar público-alvo definido (profissionais da saúde R$10-30k/mês em estética facial)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 3, 'Confirmar produto escolhido: Mentoria em grupo 6 meses (R$20-25k)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 4, 'Revisar proposta de valor e transformação prometida com a equipe Spalla', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 5, 'Validar os 4 pilares de posicionamento (Diferenciação Premium, Estética Visual, Conteúdo Estratégico, Experiência Humanizada)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 6, 'Alinhar cronograma de execução das fases com a equipe Spalla', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 2: Storytelling & Narrativa Autoral
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Storytelling & Narrativa Autoral', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 1, 'Refinar storytelling principal (da ortodontia ao medo da harmonização até Casa Amara)', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Mapear momentos-chave da jornada: residência, mestrado USP, primeiro preenchimento, pandemia, Green, Casa Amara', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Identificar os 3 pontos de virada emocionais para usar em conteúdo e pitch', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Redigir versão final do storytelling para uso em funis e vídeos de vendas', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 32, 2, 'Definir a tese central da mentoria: "Não é técnica, é estrutura de negócio"', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 3, 'Criar narrativa de identificação com o público (síndrome do impostor, medo de cobrar, comparação)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 4, 'Gravar vídeo de storytelling completo para uso em funil de vendas', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 5, 'Adaptar storytelling em versões curtas para stories e reels (60s e 90s)', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 3: Definição de Público-alvo & ICP
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Definição de Público-alvo & ICP', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 1, 'Detalhar perfil do ICP (dentistas, biomédicas, enfermeiras estetas com clínica própria, R$10-30k/mês)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Listar as 6 dores principais do público (mais do mesmo, não sabe se posicionar, vergonha de aparecer, sem reconhecimento, cansada de cursos genéricos, sensação de apagar fogo)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Mapear os 4 desejos principais (atrair pacientes naturalmente, diferenciar-se pela experiência, segurança na comunicação, aumentar faturamento)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Documentar as 8 objeções mais comuns e preparar respostas para cada uma', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 32, 2, 'Definir critérios de qualificação para o formulário de aplicação (faturamento, consultório próprio, plano de tratamento, equipe)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 3, 'Criar avatar detalhado da mentorada ideal com nome fictício, rotina e frustrações', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 4, 'Validar alinhamento expert-público: Amanda viveu as mesmas dores (usar como ativo de conexão)', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ============================================================
  -- FASE 4: Estruturação da Oferta
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Estruturação da Oferta — Mentoria Empresária Estética', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 1, 'Finalizar estrutura da oferta: 6 meses, grupo (máx 10), R$20-25k, encontros semanais ao vivo', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Confirmar formato: diagnóstico individual inicial + calls semanais em grupo + suporte assíncrono', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Definir modelo cíclico de entrada (alunas podem entrar a qualquer momento no ciclo)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Estruturar diagnóstico individual com análise dos 5 pilares (Posicionamento, Atração, Oferta, Atendimento, Conversão)', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 32, 2, 'Definir ticket final e política de pagamento (R$20k à vista / R$25k parcelado até 12x)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 3, 'Montar ancoragem de preço: valor total entregue R$35k+ vs. investimento real', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 4, 'Criar justificativa de ROI (investimento se paga em 2 meses, R$85-95k de lucro líquido nos 4 meses restantes)', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 5, 'Estruturar os 4 bônus exclusivos', 'pendente', 'equipe_spalla', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Criar scripts de conversão para WhatsApp e consulta', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Elaborar modelo de parcerias estratégicas para clínicas premium', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Desenvolver roteiros de treinamento de equipe (secretária e recepcionista)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 4, 'Preparar sessão de roleplay comercial com estrutura de feedback', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ============================================================
  -- FASE 5: Conteúdo Programático & Módulos (5 Pilares)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Conteúdo Programático & Módulos — Os 5 Pilares', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 1, 'Pilar 1 — Posicionamento: estruturar conteúdo programático completo', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Módulo Mentalidade: parar de se ver como profissional e se ver como marca', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Módulo Percepção de Valor: iluminação, ângulo, foto, feed, stories, bio', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Módulo Comunicação Diferenciada: parar de ser genérica, falar sobre COMO atua', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 4, 'Módulo Linha Editorial Fixa: 5 tipos de conteúdo obrigatórios (A&D, Case, Autopromoção, Dúvidas, Consulta)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 5, 'Módulo Gestão de Conteúdo: planejar 1 mês em 1 dia, gravar tudo de uma vez', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 2, 'Pilar 2 — Atração de Pacientes: estruturar conteúdo programático', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Módulo 4 Caminhos de Captação: Instagram orgânico, parcerias estratégicas, paciente modelo, reativação de base', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Módulo Funil de Curto Prazo: reativação da base existente + parcerias locais rápidas', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Módulo Funil de Longo Prazo: posicionamento consistente + tráfego pago estruturado', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 3, 'Pilar 3 — Oferta: estruturar conteúdo programático', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Módulo Mentalidade de Precificação: quebrar crença "as pessoas não podem pagar"', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Módulo Ancoragem de Preços: técnica do valor total isolado vs. plano completo com desconto', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Módulo Plano de Tratamento Completo: full face em vez de procedimento isolado', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 4, 'Módulo Estrutura de 3 Ofertas: âncora, ideal e mínimo viável', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 4, 'Pilar 4 — Atendimento & Experiência: estruturar conteúdo programático', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Módulo Pré-Consulta: atendimento no WhatsApp que já vende (scripts de boas práticas)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Módulo Consulta de Valor: 5 etapas (escuta ativa, conexão emocional, diagnóstico completo, apresentação do plano, fechamento)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Módulo Pós-Consulta: fidelização imediata (mesmo dia) + longo prazo (4 meses)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 4, 'Módulo Treinamento de Equipe: scripts para recepcionista, secretária e auxiliar', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 5, 'Pilar 5 — Conversão: estruturar conteúdo programático', 'pendente', 'mentorado', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Módulo 7 Passos da Venda: abertura, conexão, exploração, alinhamento, apresentação, objeções, fechamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Módulo Quebra de Objeções: "vou pensar", "tá caro", "não tenho dinheiro", "medo de ficar artificial"', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Módulo Fechamento Financeiro: ancoragem, desconto, parcelamento, silêncio estratégico', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- ============================================================
  -- FASE 6: Materiais & Ferramentas de Entrega
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Materiais & Ferramentas de Entrega', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 1, 'Criar plataforma com trilhas gravadas dos 5 pilares (aulas + planos de ação)', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Gravar aulas de cada pilar com exemplos práticos da Casa Amara', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Criar planos de ação passo a passo para cada pilar (7 passos cada)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Organizar trilha na plataforma com acesso vitalício', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 32, 2, 'Criar checklist de percepção de valor do perfil (feed, stories, destaques, bio)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 3, 'Elaborar planilha de calendário editorial mensal com os 5 tipos de conteúdo', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 4, 'Criar checklist de planos de tratamento (3 níveis: básico, ideal, premium)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 5, 'Desenvolver scripts de atendimento: WhatsApp inicial, confirmação, pós-consulta, follow-up 7 dias, reativação 4 meses', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 6, 'Criar planilha de controle de captação (origem do paciente, CPM, CTR, custo por lead)', 'pendente', 'equipe_spalla', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 7, 'Elaborar planilha de conversão (consultas/mês, fechamentos, % conversão, ticket médio, objeções)', 'pendente', 'equipe_spalla', 7, 'dossie_auto');

  -- ============================================================
  -- FASE 7: Pitch & Estratégia de Vendas da Mentoria
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Pitch & Estratégia de Vendas da Mentoria', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 1, 'Estruturar script da ligação de qualificação (5 minutos)', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Criar abertura com conexão rápida e curiosidade', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Definir perguntas de qualificação: status atual, técnica, faturamento, captação, ticket médio', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Criar iscas estratégicas para plantar entre as perguntas (resultados da Casa Amara)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 4, 'Elaborar bloco de descoberta da dor profunda e mapeamento de meta', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 2, 'Estruturar script da call de venda (técnica LEVE em 7 passos)', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Passo 1: Apresentação do projeto (exclusividade, escassez, retribuição)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Passo 2: Reaquecimento (recapitular dores + medir comprometimento)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Passo 3-4: Apresentação da oferta (visão de futuro, não entregáveis) + checagem de interesse', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 4, 'Passo 5: Ancoragem (R$25-30k) + justificativa + revelação do valor real', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 5, 'Passo 6-7: Fechamento financeiro (assumir a venda) + inversão de polaridade', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 32, 3, 'Criar mini-biblioteca de respostas rápidas para objeções em DM ("vergonha de aparecer", "cidade pequena", "posso pensar?")', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 4, 'Treinar Amanda na execução da call de venda com roleplay e feedback', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 5, 'Definir política de gravação e feedback das ligações de qualificação', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 8: Posicionamento Digital & Conteúdo
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Posicionamento Digital & Conteúdo (@draamanda_ribeiro)', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 1, 'Otimizar bio do Instagram (usar Versão 2 recomendada: autoridade clínica + docente)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Reescrever bio com gatilho de autoridade numérica (+X planejamentos Full Face)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Ajustar link Beacons com CTAs distintos (Agendar Avaliação + Close Friends Profissionais)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Testar foto de perfil com micro-sorriso confiante e fundo mediterrâneo Casa Amara', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 2, 'Reorganizar destaques na sequência estratégica recomendada', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Destaque 1: Quem Sou (história, credenciais e propósito)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Destaque 2: Método (explicação do processo Casa Amara)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Destaque 3: Resultados (antes/depois + mini casos narrados)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 4, 'Destaque 4: Provas (feedbacks e vídeos curtos de pacientes)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 5, 'Destaque 5: Como Agendar (passos + orientações práticas)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 32, 3, 'Fixar trio estratégico de posts: Apresentação+Autoridade (carrossel), Prova Social Comentada (reel longo), Prova Social Dinâmica (reel curto)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 4, 'Implementar linha editorial fixa semanal: Alcance e Descoberta, Confiança no Expert, Infovendas, Desejo e Oportunidade, Identificação', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 5, 'Produzir banco de 8-12 provas sociais dinâmicas (antes/depois com trilha e texto)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 6, 'Criar capas de destaques minimalistas com paleta off-white + bege pedra + preto sutil', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 9: Infraestrutura & Equipe
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Infraestrutura & Equipe de Suporte', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 32, 1, 'Criar perfil da mentoria no Instagram (separado do perfil clínico pessoal)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 2, 'Configurar grupo de Close Friends para profissionais (bastidores de vendas e objeções)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 3, 'Implementar formulário de aplicação (Google Forms) com perguntas de qualificação', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 4, 'Configurar sistema de agendamento para calls de qualificação e venda', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 5, 'Preparar equipamentos de produção de conteúdo (microfone de lapela, ring light, tripé, CapCut/InShot)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 6, 'Configurar ferramentas de gestão: Meta Business Suite, Canva, Google Drive para conteúdo mensal', 'pendente', 'mentorado', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 7, 'Definir estrutura de suporte assíncrono entre encontros (grupo WhatsApp ou similar)', 'pendente', 'equipe_spalla', 7, 'dossie_auto');

  -- ============================================================
  -- FASE 10: Captação & Funil de Vendas
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Captação & Funil de Vendas da Mentoria', 'passo_executivo', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 1, 'Implementar funil Social Seller (ativo 1:1 no Instagram)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Definir lista de prioridade: seguidores que interagem, profissionais HOF da região, quem viu highlights', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Implementar cadência de 7 dias (D1 abordagem leve, D2 puxão de dor, D3 follow, D5 prova, D7 última chamada)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Personalizar scripts prontos de DM: gatilho de conversa, puxão de dor, convite para ligação curta', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 4, 'Meta: 15-20 abordagens/dia, 40%+ resposta em DM, 50% ligações marcadas', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 2, 'Implementar funil Levantada de Mão (passivo via conteúdo + CTA)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Criar story-série "Diagnóstico em 6 min" com palavra-chave DIAGNÓSTICO', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Criar reel contrassenso: "Postar mais não fecha agenda. Estruturar melhor fecha." CTA: ESTRUTURA', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Criar carrossel passo a passo com CTA: "Comenta ROTEIRO que te mando o mapa"', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 4, 'Implementar stories enquete de qualificação invisível (plano completo vs. avulso, conversão 30% vs 70%)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 3, 'Estruturar funil de tráfego pago (Meta Ads) para autoridade de longo prazo', 'pendente', 'equipe_spalla', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Topo (40% budget): 3-5 criativos de awareness (contrassenso, story de virada, autoridade técnica)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Meio (35% budget): 3 criativos de consideração (prova comentada, aula curta 7 passos, checklist WhatsApp)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Fundo (25% budget): 3 criativos de conversão (case R$800→R$3000, bastidor consulta 5k, oferta vagas limitadas)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 4, 'Configurar retargeting always-on: abandono form 7d, visitou highlights 14d, engajou sem converter 30d', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 5, 'Definir orçamento inicial R$150-250/dia (TOF 40%, MOF 35%, BOF 25%)', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 32, 4, 'Executar cronograma de 30 dias: Sem1 Social Seller + Levantadas, Sem2 Ligar + marcar calls, Sem3 Iniciar tráfego, Sem4 Otimizar criativos', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 5, 'Definir KPIs e metas: 60-100 leads qualificados + 15-25 calls em 30 dias', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 11: Onboarding da Primeira Turma
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Onboarding da Primeira Turma (máx 10 alunas)', 'passo_executivo', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 1, 'Preparar diagnóstico individual inicial para cada aluna (análise dos 5 pilares)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Criar formulário de diagnóstico pré-onboarding (faturamento, conversão, posicionamento, equipe, oferta)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Agendar call individual de 1h30 com cada aluna para diagnóstico inicial', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Gerar plano de ação personalizado com prioridades para os primeiros 30 dias de cada aluna', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 32, 2, 'Configurar grupo de suporte assíncrono para a turma', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 3, 'Definir calendário de encontros semanais ao vivo (dia e horário fixo)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 4, 'Enviar kit de boas-vindas com acesso à plataforma, grupo e agenda dos encontros', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 5, 'Liberar trilhas gravadas e materiais de apoio na plataforma', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 12: Entrega & Gestão da Mentoria
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 32, 'Entrega & Gestão Contínua da Mentoria', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 32, 1, 'Executar ciclo semanal de encontros ao vivo (1 pilar por ciclo)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 32, 1, 'Ciclo 1: Posicionamento e comunicação da marca (primeiras semanas)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 2, 'Ciclo 2: Estruturação de ofertas e domínio da ancoragem', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 32, 3, 'Ciclo 3: Experiência do paciente, equipe e previsibilidade', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 32, 2, 'Realizar sessões de roleplay comercial com feedback individual nas calls em grupo', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 3, 'Analisar casos reais das alunas nas calls (consultas que travaram, objeções não quebradas)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 4, 'Acompanhar métricas de resultado das alunas (faturamento, conversão, ticket médio) mensalmente', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 5, 'Realizar diagnóstico individual final ao término dos 6 meses (comparar com o inicial)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 6, 'Coletar depoimentos e resultados das alunas para prova social da próxima turma', 'pendente', 'mentorado', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 32, 7, 'Avaliar abertura de novas turmas e ajustar oferta com base nos feedbacks do primeiro ciclo', 'pendente', 'equipe_spalla', 7, 'dossie_auto');

END $$;


-- ================================================================
-- CAROLINA SAMPAIO (mentorado_id = 42)
-- ================================================================
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (42, 'PLANO DE AÇÃO v2 | Carolina Sampaio', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- ============================================================
  -- FASE 1: Revisão do Dossiê Estratégico
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 42, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 42, 1, 'Revisar seção de contexto e validar posicionamento como formadora técnica premium em blefaroplastia', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 2, 'Validar perfil do público-alvo primário (oftalmologistas em fase madura) e secundários (fellows, dermato/plástica)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 3, 'Confirmar os 4 pilares técnicos do método (Superior, Inferior, Lifting Cauda, CO2 + Drug Delivery)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 4, 'Revisar análise de concorrentes e confirmar diferenciais competitivos (hands-on + CO2 + turma reduzida)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 5, 'Validar precificação final: VIP R$15k, Observership R$8k, Premium R$20k', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 2: Storytelling & Narrativa Autoral
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 42, 'Storytelling & Narrativa Autoral', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 1, 'Revisar e aprovar storytelling do dossiê (jornada convênio → premium → ensino)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Validar narrativa da transição convênio alto volume para particular premium', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Aprovar história da demanda espontânea de colegas pedindo para acompanhar cirurgias', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Confirmar tom da narrativa: técnica refinada + didática estruturada + prática real', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 42, 2, 'Gravar áudio/vídeo contando sua história pessoal para uso em conteúdo e vendas', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 3, 'Documentar a tese central: dominar técnica com método claro gera segurança, autoridade e ticket premium', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 4, 'Criar versão resumida do storytelling para uso em calls de venda (2-3 minutos)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 5, 'Enviar histórias pessoais e profissionais no grupo da mentoria para elaboração de conteúdo', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 3: Definição de Público-alvo & ICP
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 42, 'Definição de Público-alvo & ICP', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 1, 'Mapear perfil primário: oftalmologistas em fase madura que querem dominar estética premium', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Documentar dores: burnout, medo de complicações, insegurança para cobrar premium', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Documentar desejos: qualidade de vida, segurança técnica, reconhecimento, transição suave', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Definir critérios de qualificação: já opera, tem volume, quer elevar nível técnico', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 42, 2, 'Mapear perfil secundário: fellows recém-formados (porta de entrada via Observership)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 3, 'Mapear perfil terciário: dermatologistas e cirurgiões plásticos interessados em blefaro', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 4, 'Postar no grupo da Célia (185 pessoas) para validar dores e identificar potenciais alunos', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ============================================================
  -- FASE 4: Estruturação da Oferta
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 42, 'Estruturação da Oferta', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 1, 'Finalizar estrutura da oferta principal: Programa VIP de Blefaroplastia com CO2', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Confirmar formato: Imersão Presencial 2 dias + Mentoria Online 3 meses', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Validar turmas ultra reduzidas (máx. 2 alunos) para supervisão milimétrica', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Confirmar preço VIP: 10x R$1.800 ou R$15.000 à vista', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 2, 'Estruturar oferta de entrada: Observership (1 dia, R$8.000 à vista ou 10x R$1.000)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Definir entregáveis do Observership: observação + explicação ao vivo + olhar cirúrgico', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Posicionar Observership como porta de entrada para quem não está pronto para o VIP', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Criar mecanismo de upgrade: Observership → VIP com desconto', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 42, 3, 'Estruturar oferta premium: VIP Premium 3 dias (10x R$2.500 ou R$20.000 à vista)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 4, 'Montar tabela de ancoragem de valor (R$54k valor de mercado vs R$15k investimento)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 5, 'Definir cenários de ROI para apresentar na venda (1 blefaro = ROI parcial, 2 = ROI total)', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 6, 'Receber oferta formatada, revisar e fazer ajustes finais', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 5: Conteúdo Programático & Módulos
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 42, 'Conteúdo Programático & Módulos', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 1, 'Estruturar Pilar 1: Blefaroplastia Superior (indicação, marcação, técnica, sutura, pós-op)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Definir critérios de indicação e avaliação pré-operatória (excesso de pele vs ptose real)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Sistematizar marcação estratégica premium (naturalidade, assimetrias, prega fixa)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Documentar técnica completa: abertura, retirada proporcional, cauterização seletiva', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 4, 'Sistematizar técnica de sutura invisível (fios, lógica contínua, tensão, peles espessas)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 5, 'Documentar manejo pós-operatório: prevenção edema, complicações precoces, revisão 7/30 dias', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 2, 'Estruturar Pilar 2: Blefaroplastia Inferior (avaliação, incisão, descolamento, bolsas, cantopexia)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Documentar avaliação estrutural da base inferior (bolsas herniadas, ligamentos, transposição vs retirada)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Sistematizar incisão minimamente traumática (rente ao cílio, preservar orbicular, evitar retração)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Documentar descolamento seguro (fronteiras anatômicas, planos seguros, controle sangramento)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 4, 'Sistematizar retirada de pele com paciente acordado e cantopexia quando necessário', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 3, 'Estruturar Pilar 3: Lifting de Cauda de Supercílio', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Definir critérios de indicação correta (queda lateral, peso na cauda, diferença de blefaro isolada)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Documentar marcação e planejamento (simulação com paciente acordado, evitar excesso de tração)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Sistematizar técnica cirúrgica (incisão precisa, preservar nervos/vasos, fixação segura)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 4, 'Documentar integração com blefaroplastia superior e inferior', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 4, 'Estruturar Pilar 4: Aplicação Estratégica de CO2 + Drug Delivery', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Documentar diferença entre CO2 incisional e CO2 fracionado e quando usar cada um', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Sistematizar parâmetros ideais para pálpebra (ponteira, potência, áreas de risco)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Documentar protocolo de drug delivery estratégico (PDRN, fatores, antioxidantes)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 4, 'Sistematizar combinação CO2 + blefaro (momento exato, evitar fibrose, sequência ideal)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 42, 5, 'Estruturar cronograma do Dia 1: Diagnóstico 360° & Observership (manhã teórica + tarde prática)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 6, 'Estruturar cronograma do Dia 2: Cirurgia Completa hand-on guiado (superior + inferior + CO2)', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 6: Materiais & Ferramentas de Entrega
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 42, 'Materiais & Ferramentas de Entrega', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 1, 'Criar ferramentas de apoio do Pilar 1 (Superior)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Criar Mapa de Marcação Superior: Modelo Carol Sampaio', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Criar Checklist de Risco & Contraindicações Superior', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Criar Guia de Sutura Invisível: Passo a Passo', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 4, 'Criar Script de Consulta Pré-operatória Superior', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 2, 'Criar ferramentas de apoio do Pilar 2 (Inferior)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Criar Mapa de Descolamento Seguro: Inferior', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Criar Guia de Transposição vs. Retirada', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Criar Checklist Anti-Retração Inferior', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 4, 'Criar Script de Acompanhamento 7-30 dias', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 3, 'Criar ferramentas de apoio do Pilar 3 (Lifting Cauda)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Criar Mapa de Indicação do Lifting Lateral', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Criar Guia de Fixação Segura', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Criar Checklist Anti-Artefato (evitar olhar artificial)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 4, 'Criar Script de Explicação ao Paciente sobre lifting', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 4, 'Criar ferramentas de apoio do Pilar 4 (CO2 + Drug Delivery)', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Criar Mapa de Parâmetros de CO2 por Tipo de Pele', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Criar Checklist de Risco (áreas sensíveis)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Criar Guia de Drug Delivery Premium', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 4, 'Criar Script de Explicação & Indicação do CO2 para pacientes', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 42, 5, 'Criar checklist geral de critérios cirúrgicos para entrega ao aluno', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 7: Pitch & Estratégia de Vendas
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 42, 'Pitch & Estratégia de Vendas', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 1, 'Assistir a aula de venda da Spalla e internalizar estrutura de reunião', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 2, 'Estruturar roteiro da reunião de vendas (30-45 min)', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Montar bloco de conexão: quebrar gelo falando de casos comuns', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Montar bloco de diagnóstico: fazer o lead falar das dificuldades técnicas e financeiras', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Montar apresentação da solução: explicar os 4 Pilares + diferencial CO2 + hands-on', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 4, 'Montar bloco de ancoragem e ROI (2 cirurgias pagam o investimento)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 5, 'Preparar respostas para objeções: "tá caro", "vou pensar", "não tenho tempo"', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 42, 3, 'Gravar áudio apresentando a oferta e enviar para Queila dar feedback', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 4, 'Preparar material de apoio à venda: PDF/apresentação 20 slides (Autoridade → Diferencial → Estrutura → Investimento)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 5, 'Fazer as primeiras calls de venda pessoalmente (não delegar no início)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 6, 'Organizar agenda para encaixar reuniões de venda (sexta tarde, sábado manhã)', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 8: Posicionamento Digital & Conteúdo
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 42, 'Posicionamento Digital & Conteúdo', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 1, 'Atualizar foto de perfil do Instagram com elementos de autoridade cirúrgica', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Trocar para foto com expressão firme (leve sorriso fechado), enquadramento 70% rosto', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Incluir elemento de autoridade: jaleco, consultório ou instrumento sutil', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Usar fundo neutro (bege, branco ou gelo)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 42, 2, 'Reescrever bio do Instagram comunicando nicho em 0,5 segundo (Blefaroplastia + Laser CO2)', 'pendente', 'equipe_spalla', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 3, 'Reorganizar destaques do Instagram com estrutura estratégica', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Criar destaque "Sobre a Carol" (formação USP, +10 anos, princípios de naturalidade)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Criar destaque "Blefaroplastia" (técnicas superiores/inferiores, lifting, CO2)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Criar destaque "Resultados" (antes/depois premium com narrativa)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 4, 'Criar destaque "Formação Médica" (programa, técnicas, depoimentos de médicos)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 5, 'Criar destaque "FAQ Premium" (dúvidas de pacientes e médicos)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 4, 'Criar trio de posts fixados estratégicos', 'pendente', 'equipe_spalla', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Criar Post Fixado #1: Quem é a Dra. Carol (carrossel com formação, experiência, filosofia)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Criar Post Fixado #2: Blefaroplastia - O Guia Definitivo (idades, indicações, mitos, riscos)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Criar Post Fixado #3: Resultados + Prova Social (3 casos, timeline, depoimentos)', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 42, 5, 'Começar plano de conteúdo com linha editorial híbrida (pacientes + profissionais)', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 6, 'Implementar calendário editorial semanal (Dom: lifestyle, Seg: autoridade, Ter: desejo, Qua: prova social, Qui: infovendas, Sex: bastidores, Sab: identificação)', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 9: Infraestrutura & Equipe
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 42, 'Infraestrutura & Equipe', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 42, 1, 'Definir data exata da primeira Imersão Presencial (3 dias em Fortaleza)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 2, 'Bloquear agenda do centro cirúrgico (Automarks) para os dias da imersão', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 3, 'Garantir disponibilidade de pacientes para observership e hands-on nos dias da imersão', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 4, 'Contratar fotógrafo/videomaker para registro profissional da imersão (prova social para Turma 2)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 5, 'Preparar estrutura para receber 2 alunos com conforto (coffee break, materiais impressos)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 10: Captação & Funil de Vendas
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 42, 'Captação & Funil de Vendas', 'passo_executivo', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 1, 'Montar lista de prospecção com 80-100 nomes qualificados', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Mapear 4 leads quentes já identificados (colega Sobral, ex-residente, duas médicas interessadas)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Listar ex-residentes dos últimos 3 anos (~30 nomes) com bom relacionamento', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Mapear colegas oftalmologistas e dermatologistas da rede que se beneficiariam', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 4, 'Criar planilha com Nome, WhatsApp, Nível de Relacionamento, Potencial Financeiro', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 2, 'Contatar 3 pessoas que já demonstraram interesse (prospecção tiro curto)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Contatar colega de Sobral (pediu mentoria em agosto, tem 3 clínicas)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Contatar ex-residente que quer abrir clínica popular', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Contatar colega do interior que fez glaucoma e quer aprender pálpebra', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 42, 3, 'Pedir permissão à Célia e postar no grupo (185 pessoas) pedindo feedback sobre dificuldades', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 4, 'Iniciar abordagem via WhatsApp usando scripts do dossiê (ex-residentes e colegas próximos)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 5, 'Realizar ligações de qualificação com perguntas-filtro (dor técnica, dor financeira, validação)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 6, 'Agendar e executar reuniões de vendas com leads qualificados', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 11: Onboarding da Primeira Turma
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 42, 'Onboarding da Primeira Turma', 'passo_executivo', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 42, 1, 'Enviar contrato e link de pagamento aos alunos confirmados', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 2, 'Criar grupo de WhatsApp da turma para comunicação direta', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 3, 'Enviar material prévio (teoria básica) para nivelar conhecimento antes da imersão', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 4, 'Enviar informações logísticas: local, horários, o que levar, recomendações de hospedagem', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 5, 'Fazer call de boas-vindas individual com cada aluno para alinhar expectativas', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 12: Entrega & Gestão da Mentoria
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 42, 'Entrega & Gestão da Mentoria', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 1, 'Executar Dia 1 da imersão: Diagnóstico 360° & Observership', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Manhã: Abertura, nivelamento técnico e Masterclass Mapa do Olhar', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Manhã: Demonstração ao vivo (observatório) com análise completa do paciente', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Tarde: Análise em dupla (treinar o olhar) e mini-prática supervisionada', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 4, 'Final: Revisão do dia, principais acertos/ajustes e preparação para Dia 2', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 2, 'Executar Dia 2 da imersão: Cirurgia Completa hand-on guiado', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Manhã: Revisão prática Dia 1 + planejamento cirúrgico do paciente do dia', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Manhã: Observação cirúrgica (caso modelo da Carol) com explicação passo a passo', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Tarde: Primeira cirurgia completa do aluno com supervisão milimétrica da Carol', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 4, 'Final: Feedback técnico individual (pontos fortes, evolução, erros, plano técnico)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 42, 3, 'Coletar depoimentos em vídeo dos alunos ao final do último dia (no calor da emoção)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 42, 4, 'Executar mentoria online de acompanhamento (3 meses pós-imersão)', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 42, 1, 'Realizar encontros mensais/quinzenais para revisão técnica dos casos do aluno', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 2, 'Analisar fotos e vídeos dos casos do aluno (marcação, retirada, sutura, acabamento)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 3, 'Dar correções individuais e ajustes de conduta conforme perfil do paciente', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 4, 'Revisar resultados intermediários (7, 30, 60 dias) e direcionar próxima cirurgia', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 42, 5, 'Entregar plano técnico personalizado e contínuo ao final dos 3 meses', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 42, 5, 'Manter lista de "não compradores" para follow-up e próxima turma', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 42, 6, 'Usar material fotográfico/vídeo da Turma 1 como prova social para vender Turma 2', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

END $$;


-- ================================================================
-- BETINA FRANCIOSI (mentorado_id = 145)
-- ================================================================
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (145, 'PLANO DE AÇÃO v2 | Betina Franciosi', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- ============================================================
  -- FASE 1: Revisão do Dossiê Estratégico
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 1, 'Revisar seção de Storytelling e validar marcos narrativos', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 2, 'Revisar seção de Público-alvo e confirmar ICP da primeira turma', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 3, 'Revisar seção de Tese do Produto e alinhar posicionamento', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 4, 'Revisar seção de Arquitetura do Produto e validar conteúdo programático', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 5, 'Revisar seção de Oferta e confirmar preço, bônus e condições', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 6, 'Revisar seção de Pitch de Vendas e adaptar para tom pessoal', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 2: Identidade de Marca da Mentoria
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Identidade de Marca da Mentoria', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 1, 'Definir nome oficial da mentoria (substituir "[NOME A DEFINIR]")', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 145, 1, 'Brainstorm de 5-10 opções de nome com Betina e Vinícius', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 2, 'Validar disponibilidade do nome em domínio e redes sociais', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 3, 'Escolher nome final e registrar', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 2, 'Criar identidade visual separada do @drabetinafranciosi', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 145, 1, 'Definir paleta de cores e tipografia da marca B2B', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 2, 'Criar logo da mentoria', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 3, 'Criar templates visuais para stories, posts e materiais', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 3, 'Criar perfil B2B separado no Instagram para a mentoria', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 145, 1, 'Criar conta e configurar perfil com bio estratégica B2B', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 2, 'Produzir 9 posts iniciais para grid de lançamento', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 3, 'Configurar destaques: Método, Resultados, Sobre, Mentoria', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 4, 'Escrever declaração de posicionamento anti-genérico em 1 frase', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ============================================================
  -- FASE 3: Infraestrutura Pré-Lançamento
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Infraestrutura Pré-Lançamento', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 1, 'Redigir e revisar contrato de mentoria para assinatura digital', 'pendente', 'equipe_spalla', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 2, 'Configurar plataforma de pagamento (R$ 42k parcelado / R$ 30k à vista)', 'pendente', 'equipe_spalla', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 3, 'Criar grupo exclusivo de WhatsApp com link de convite', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 4, 'Criar formulário de diagnóstico pré-call com 8 perguntas-chave', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 5, 'Definir calendário dos 12 encontros quinzenais (datas, horários, links Zoom)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 6, 'Configurar plataforma de conteúdo (Academia Expert) e acessos', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 7, 'Publicar template de CRM (GoHighLevel) com pipeline, automações e tags', 'pendente', 'mentorado', 7, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 8, 'Criar planilha de acompanhamento de métricas (1 aba por mentorado)', 'pendente', 'equipe_spalla', 8, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 9, 'Redigir regras do grupo de WhatsApp para enviar no onboarding', 'pendente', 'equipe_spalla', 9, 'dossie_auto');

  -- ============================================================
  -- FASE 4: Produção de Conteúdo e Materiais da Mentoria
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Produção de Conteúdo e Materiais da Mentoria', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 1, 'Gravar aulas dos 3 pilares (Conversão, Atração, Gestão)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 145, 1, 'Gravar aulas do Pilar 1 (Conversão) antes do Encontro 1', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 2, 'Gravar aulas do Pilar 2 (Atração) antes do Encontro 5', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 3, 'Gravar aulas do Pilar 3 (Gestão) antes do Encontro 9', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 2, 'Preparar Bônus 1: Roteiro de Consulta de Alta Performance', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 145, 1, 'Documentar as 6 fases da consulta (abertura até fechamento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 2, 'Criar template adaptável por especialidade', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 3, 'Incluir scripts personalizáveis para cada fase', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 3, 'Preparar Bônus 2: Protocolo de Follow-up Pós-Consulta + Scripts', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 145, 1, 'Definir timing exato de retomada por canal (WhatsApp, ligação)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 2, 'Escrever scripts de mensagem para cada tipo de objeção pendente', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 3, 'Criar roteiro para treinar secretária no follow-up', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 4, 'Preparar Bônus 3: Framework de Desbloqueio de Crenças Limitantes', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 5, 'Preparar Bônus 4: Modelo de Estratégia de Conteúdo B2C para Clínicas', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 6, 'Preparar Bônus 5: Checklist de Transição Tecnológica', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 7, 'Preparar Bônus 6: Imersão do Vinícius (2-3h ao vivo)', 'pendente', 'mentorado', 7, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 145, 1, 'Roteirizar sessão: processos, CRM, IA comercial, dashboard', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 2, 'Preparar demonstração ao vivo do GoHighLevel configurado', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 3, 'Documentar erros comuns de implementação tecnológica', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 8, 'Preparar Bônus 7: Case Study - Estratégia da Gravidez', 'pendente', 'mentorado', 8, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 9, 'Gravar vídeo de onboarding no CRM (Vinícius)', 'pendente', 'mentorado', 9, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 10, 'Redigir Guia CFM (o que pode e não pode no Instagram médico)', 'pendente', 'equipe_spalla', 10, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 11, 'Criar guia de objeções com respostas prontas (6 objeções principais)', 'pendente', 'mentorado', 11, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 12, 'Configurar área de membros na plataforma e organizar materiais', 'pendente', 'equipe_spalla', 12, 'dossie_auto');

  -- ============================================================
  -- FASE 5: Construção do Funil B2B de Captação
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Construção do Funil B2B de Captação', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 1, 'Mapear lista de contatos B2B existentes para ativação', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 145, 1, 'Listar colegas médicos da turma de formação 2021 + residência', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 2, 'Listar contatos de imersões e eventos médicos frequentados', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 3, 'Identificar seguidores B2C que são médicos ou cônjuges de médicos', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 4, 'Mapear rede de Vinícius no universo tech/engenharia para parcerias', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 2, 'Construir prova social específica para oferta B2B', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 145, 1, 'Documentar números da própria clínica (conversão 44-50%, 500+ lista)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 2, 'Criar peças visuais com resultados verificáveis', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 3, 'Preparar depoimentos e evidências para página de vendas', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 3, 'Avaliar conexão com Rafael Medeiros para parceria ou indicação cruzada', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 4, 'Criar página de vendas com storytelling, oferta e prova social', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  -- ============================================================
  -- FASE 6: Estratégia de Conteúdo B2B no Perfil da Mentoria
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Estratégia de Conteúdo B2B no Perfil da Mentoria', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 1, 'Definir estratégia de conteúdo B2B (bastidores do NEGÓCIO, não da cirurgia)', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 2, 'Criar banco de pautas B2B para 90 dias organizadas por estágio de consciência', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 145, 1, 'Criar pautas de topo (Descobre): dores do médico que não converte', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 2, 'Criar pautas de meio (Entende/Deseja): método, bastidores, resultados', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 3, 'Criar pautas de fundo (Confia/Decide): prova social, oferta, urgência', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 3, 'Produzir e publicar primeiro conteúdo de bastidor do negócio', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 4, 'Imprimir as 18 crenças do dossiê nos conteúdos de forma estratégica', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 5, 'Usar frases de comunicação do dossiê nos copies e legendas', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 7: Precificação e Estrutura Financeira da Mentoria
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Precificação e Estrutura Financeira da Mentoria', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 1, 'Validar precificação final (R$ 42k parcelado / R$ 30k à vista)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 2, 'Definir limite de vagas da primeira turma (5 a 10 pessoas)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 3, 'Estruturar argumento de ROI para quebra de objeção de preço', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 4, 'Definir claramente o que é core vs. bônus na entrega', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 5, 'Planejar gestão do tempo da dupla (Betina + Vinícius) durante entrega', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 8: Storytelling e Narrativa de Venda
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Storytelling e Narrativa de Venda', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 1, 'Adaptar storytelling base para diferentes formatos de comunicação', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 145, 1, 'Adaptar para conteúdo de feed e reels do perfil B2B', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 2, 'Adaptar para bio e destaques do perfil da mentoria', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 3, 'Adaptar para página de vendas e anúncios', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 4, 'Adaptar para apresentações e aulas ao vivo', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 2, 'Treinar Betina no pitch de vendas completo (20-25 min)', 'pendente', 'mentor', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 3, 'Praticar transições entre seções do pitch (tom consultivo, direto)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 4, 'Preparar respostas para as 6 objeções comuns do público-alvo', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ============================================================
  -- FASE 9: Lançamento e Vendas da Primeira Turma
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Lançamento e Vendas da Primeira Turma', 'passo_executivo', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 1, 'Executar ativação da lista de contatos B2B mapeada', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 145, 1, 'Enviar mensagens personalizadas para colegas médicos da rede', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 2, 'Oferecer call de diagnóstico gratuita (30 min) para interessados', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 3, 'Fazer follow-up estruturado com leads que demonstraram interesse', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 2, 'Realizar calls de venda individuais usando o pitch estruturado', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 3, 'Acompanhar taxa de conversão de leads para matrículas', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 4, 'Fechar as primeiras 5-10 vagas da turma inaugural', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ============================================================
  -- FASE 10: Onboarding e Diagnóstico (Execução Fase 1 da Mentoria)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Onboarding e Diagnóstico dos Mentorados', 'passo_executivo', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 1, 'Executar onboarding de cada mentorado matriculado', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 145, 1, 'Enviar mensagem de boas-vindas personalizada (não automática)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 2, 'Adicionar ao grupo de WhatsApp e enviar regras', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 3, 'Enviar contrato para assinatura digital', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 4, 'Enviar formulário de diagnóstico (prazo 5 dias)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 5, 'Vinícius envia acesso ao vídeo de onboarding do CRM', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 2, 'Realizar call de diagnóstico individual com cada mentorado (40 min)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 145, 1, 'Acolhimento e revisão do formulário (0-5 min)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 2, 'Diagnóstico: aprofundar nos números reais da clínica (5-20 min)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 3, 'Identificar gargalo principal e definir pilar prioritário (20-30 min)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 145, 4, 'Definir 3 tarefas concretas para executar antes do Encontro 1 (30-40 min)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 3, 'Registrar métricas-base de cada mentorado no CRM', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 4, 'Preencher planilha de métricas (Dia 1) para cada mentorado', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  -- ============================================================
  -- FASE 11: Execução Pilar 1 - Conversão (Encontros 1 a 4)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Execução Pilar 1 - Conversão (Encontros 1 a 4)', 'passo_executivo', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 1, 'Encontro 1: Estrutura da consulta de alta performance (6 fases)', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 2, 'Encontro 2: Diagnóstico Real, Imagem do Resultado e ancoragem de valor', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 3, 'Encontro 3: Protocolo de follow-up do dia seguinte e treinamento de secretária', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 145, 4, 'Encontro 4: Leitura dos dados de conversão e decisão de quando subir ticket', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 5, 'Entregar Bônus 1 (Roteiro de Consulta) junto com onboarding', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 6, 'Entregar Bônus 2 (Protocolo Follow-up) após Encontro 2', 'pendente', 'equipe_spalla', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 7, 'Entregar Bônus 3 (Framework Crenças) no Encontro 3', 'pendente', 'equipe_spalla', 7, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 8, 'Enviar lembrete no grupo 2 dias antes de cada encontro', 'pendente', 'equipe_spalla', 8, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 9, 'Atualizar planilha de métricas no Encontro 4 (Mês 2)', 'pendente', 'equipe_spalla', 9, 'dossie_auto');

  -- ============================================================
  -- FASE 12: Execução Pilar 2 - Atração (Encontros 5 a 8)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Execução Pilar 2 - Atração (Encontros 5 a 8)', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 1, 'Encontro 5: Posicionamento de nicho e reformulação de bio', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 2, 'Encontro 6: Conteúdo de bastidor vs. educativo e banco de pautas', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 3, 'Encontro 7: Qualificação pré-consulta (formulário + script + bot IA)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 4, 'Encontro 8: Leitura de dados de atração e análise de ROI por canal', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 5, 'Entregar Bônus 4 (Estratégia de Conteúdo) entre Encontros 4 e 5', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 6, 'Entregar Bônus 5 (Checklist Transição) nos Encontros 5-6', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 7, 'Atualizar planilha de métricas no Encontro 8 (Mês 4)', 'pendente', 'equipe_spalla', 7, 'dossie_auto');

  -- ============================================================
  -- FASE 13: Execução Pilar 3 - Gestão com Tecnologia (Encontros 9 a 12)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Execução Pilar 3 - Gestão com Tecnologia (Encontros 9 a 12)', 'passo_executivo', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 1, 'Encontro 9: CRM, pipeline, automações, tags e KPIs essenciais', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 2, 'Encontro 10: Dashboard financeiro, custo por procedimento e margem', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 3, 'Encontro 11: Precificação com dado real e estratégia de aumento de ticket', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 4, 'Encontro 12: Encerramento, antes vs. depois, plano de 90 dias', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 5, 'Entregar Bônus 6 (Imersão Vinícius) nos Encontros 6-7', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 6, 'Entregar Bônus 7 (Case Study Gravidez) no Encontro 8+', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 7, 'Solicitar depoimento de cada mentorado no Encontro 12', 'pendente', 'mentorado', 7, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 8, 'Atualizar planilha de métricas final (Mês 6)', 'pendente', 'equipe_spalla', 8, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 9, 'Cada mentorado apresenta plano de 90 dias pós-mentoria', 'pendente', 'mentorado', 9, 'dossie_auto');

  -- ============================================================
  -- FASE 14: Gestão Recorrente e Acompanhamento Contínuo
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 145, 'Gestão Recorrente e Acompanhamento Contínuo', 'passo_executivo', 14, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 145, 1, 'Acompanhar e responder no grupo WhatsApp diariamente (seg-sex 8h-19h)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 2, 'Realizar 12 encontros quinzenais ao vivo (2h cada)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 3, 'Coletar depoimentos dos mentorados mensalmente (para conteúdo)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 4, 'Atualizar status de cada ação do funil em tempo real', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 5, 'Registrar motivo em caso de atraso em qualquer ação', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 145, 6, 'Analisar resultados e ajustar plano de ação conforme evolução', 'pendente', 'mentor', 6, 'dossie_auto');

END $$;


DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN

-- =============================================================
-- PLANO DE AÇÃO — Camille Pinheiro Bragança (mentorado_id = 49)
-- =============================================================
INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
VALUES (49, 'Plano de Ação Estratégico — Camille Pinheiro Bragança', 'fases', 'nao_iniciado', 'dossie_auto_v3')
RETURNING id INTO _plano_id;

-- =============================================================
-- FASE 1: Revisão do Dossiê Estratégico
-- =============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 49, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'em_andamento', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 49, 1, 'Revisar posicionamento e 4 pilares definidos', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 49, 2, 'Revisar tese central e diferencial competitivo', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 49, 3, 'Revisar storytelling e narrativa pessoal', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 49, 4, 'Revisar público-alvo da clínica e perfil de paciente ideal', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 49, 5, 'Revisar análise de concorrentes da clínica', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 49, 6, 'Revisar estratégia comercial da clínica (7 passos)', 'pendente', 'mentorado', 6, 'dossie_auto'),
(_fase_id, _plano_id, 49, 7, 'Revisar público-alvo da mentoria e perfil de aluno ideal', 'pendente', 'mentorado', 7, 'dossie_auto'),
(_fase_id, _plano_id, 49, 8, 'Revisar oferta da mentoria Método Lábios Únicos', 'pendente', 'mentorado', 8, 'dossie_auto'),
(_fase_id, _plano_id, 49, 9, 'Revisar arquitetura do produto e grade curricular', 'pendente', 'mentorado', 9, 'dossie_auto'),
(_fase_id, _plano_id, 49, 10, 'Revisar funil de vendas da mentoria', 'pendente', 'mentorado', 10, 'dossie_auto'),
(_fase_id, _plano_id, 49, 11, 'Revisar lapidação do Instagram (bio, destaques, fixados)', 'pendente', 'mentorado', 11, 'dossie_auto'),
(_fase_id, _plano_id, 49, 12, 'Revisar linha editorial e ideias de conteúdo', 'pendente', 'mentorado', 12, 'dossie_auto');

-- =============================================================
-- FASE 2: Reestruturação da Oferta da Clínica
-- =============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 49, 'Reestruturação da Oferta da Clínica', 'fase', 2, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 49, 1, 'Definir pacote carro-chefe de preenchimento labial natural', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 49, 2, 'Criar tabela de preços com âncora e upsell', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 49, 3, 'Montar apresentação visual da oferta para usar na consulta', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 49, 4, 'Definir política de pagamento e parcelamento', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 49, 5, 'Criar script de apresentação da oferta na consulta', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

-- =============================================================
-- FASE 3: Técnica de Venda na Consulta
-- =============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 49, 'Técnica de Venda na Consulta', 'fase', 3, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 49, 1, 'Estruturar roteiro da consulta de avaliação (etapas)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
(_fase_id, _plano_id, 49, 2, 'Incluir perguntas de diagnóstico para gerar desejo', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 49, 3, 'Treinar técnica de ancoragem de preço na consulta', 'pendente', 'mentor', 3, 'dossie_auto'),
(_fase_id, _plano_id, 49, 4, 'Definir gatilhos de fechamento durante a consulta', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
(_fase_id, _plano_id, 49, 5, 'Simular consultas de venda com feedback do mentor', 'pendente', 'mentor', 5, 'dossie_auto');

-- =============================================================
-- FASE 4: Funil Comercial da Clínica
-- =============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 49, 'Funil Comercial da Clínica', 'fase', 4, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 49, 1, 'Mapear jornada do paciente do Instagram até o agendamento', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
(_fase_id, _plano_id, 49, 2, 'Criar script de atendimento para secretária no WhatsApp', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 49, 3, 'Definir processo de qualificação de leads da clínica', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 49, 4, 'Implementar follow-up pós-consulta para pacientes que não fecharam', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 49, 5, 'Criar sistema de reativação de pacientes inativos', 'pendente', 'mentorado', 5, 'dossie_auto');

-- =============================================================
-- FASE 5: Treinamento do Time e Secretária
-- =============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 49, 'Treinamento do Time e Secretária', 'fase', 5, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 49, 1, 'Treinar secretária no script de atendimento e qualificação', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 49, 2, 'Definir metas de agendamento e conversão para o time', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 49, 3, 'Criar checklist de follow-up para a secretária executar', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
(_fase_id, _plano_id, 49, 4, 'Implementar reunião semanal de acompanhamento com o time', 'pendente', 'mentorado', 4, 'dossie_auto');

-- =============================================================
-- FASE 6: Posicionamento da Clínica no Instagram
-- =============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 49, 'Posicionamento da Clínica no Instagram', 'fase', 6, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 49, 1, 'Definir identidade visual do perfil da clínica', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 49, 2, 'Criar calendário de conteúdo específico para a clínica', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 49, 3, 'Publicar antes e depois com autorização dos pacientes', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 49, 4, 'Criar conteúdo educativo sobre preenchimento labial natural', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 49, 5, 'Definir frequência e horários de postagem para a clínica', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

-- =============================================================
-- FASE 7: Estruturação da Mentoria Método Lábios Únicos
-- =============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 49, 'Estruturação da Mentoria Método Lábios Únicos', 'fase', 7, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 49, 1, 'Validar grade curricular dos 4 pilares da mentoria', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 49, 2, 'Preparar material do Pilar 1: Anatomia Labial Aplicada', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 49, 3, 'Preparar material do Pilar 2: Técnicas de Preenchimento Natural', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 49, 4, 'Preparar material do Pilar 3: Planejamento e Diagnóstico', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 49, 5, 'Preparar material do Pilar 4: Posicionamento e Captação', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 49, 6, 'Definir formato do presencial VIP (2 dias hands-on)', 'pendente', 'mentorado', 6, 'dossie_auto'),
(_fase_id, _plano_id, 49, 7, 'Estruturar acompanhamento de 6 meses pós-presencial', 'pendente', 'equipe_spalla', 7, 'dossie_auto');

-- =============================================================
-- FASE 8: Funil de Vendas da Mentoria
-- =============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 49, 'Funil de Vendas da Mentoria', 'fase', 8, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 49, 1, 'Definir datas do primeiro presencial VIP', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 49, 2, 'Abordar as 2 profissionais já interessadas na mentoria', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 49, 3, 'Assistir aula de vendas do programa Spalla', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 49, 4, 'Realizar call de vendas com as interessadas', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 49, 5, 'Fazer fechamento de vendas da primeira turma', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 49, 6, 'Executar follow-up com leads que não fecharam', 'pendente', 'mentorado', 6, 'dossie_auto'),
(_fase_id, _plano_id, 49, 7, 'Formalizar venda com contrato e pagamento', 'pendente', 'mentorado', 7, 'dossie_auto'),
(_fase_id, _plano_id, 49, 8, 'Fazer onboarding dos alunos da primeira turma', 'pendente', 'mentorado', 8, 'dossie_auto');

-- =============================================================
-- FASE 9: Lapidação do Perfil do Instagram
-- =============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 49, 'Lapidação do Perfil do Instagram', 'passo_executivo', 9, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 49, 1, 'Atualizar bio com posicionamento de referência em lábios naturais', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 49, 2, 'Criar destaque Sobre Mim com storytelling pessoal', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 49, 3, 'Criar destaque Resultados com antes e depois de pacientes', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 49, 4, 'Criar destaque Método com explicação do processo', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 49, 5, 'Criar destaque Depoimentos com provas sociais', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 49, 6, 'Criar destaque Mentoria para atrair profissionais', 'pendente', 'mentorado', 6, 'dossie_auto'),
(_fase_id, _plano_id, 49, 7, 'Definir e publicar post fixado 1: carrossel de autoridade', 'pendente', 'mentorado', 7, 'dossie_auto'),
(_fase_id, _plano_id, 49, 8, 'Definir e publicar post fixado 2: carrossel de resultados', 'pendente', 'mentorado', 8, 'dossie_auto'),
(_fase_id, _plano_id, 49, 9, 'Definir e publicar post fixado 3: carrossel de conexão pessoal', 'pendente', 'mentorado', 9, 'dossie_auto'),
(_fase_id, _plano_id, 49, 10, 'Gravar e publicar reels fixado 1: bastidores de procedimento', 'pendente', 'mentorado', 10, 'dossie_auto'),
(_fase_id, _plano_id, 49, 11, 'Gravar e publicar reels fixado 2: depoimento de paciente', 'pendente', 'mentorado', 11, 'dossie_auto');

-- =============================================================
-- FASE 10: Produção de Conteúdo e Linha Editorial
-- =============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 49, 'Produção de Conteúdo e Linha Editorial', 'fase', 10, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 49, 1, 'Implementar linha editorial com 5 categorias (Descobrir, Entender, Confiar, Desejar, Se Identificar)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
(_fase_id, _plano_id, 49, 2, 'Definir calendário semanal de postagens (feed + stories + reels)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 49, 3, 'Implementar fluxo de execução de conteúdo em 8 etapas', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 49, 4, 'Produzir primeira semana de conteúdo seguindo o calendário', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 49, 5, 'Criar banco de ideias de conteúdo para viagens e eventos', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
(_fase_id, _plano_id, 49, 6, 'Criar conteúdos híbridos (clínica + mentoria no mesmo perfil)', 'pendente', 'mentorado', 6, 'dossie_auto'),
(_fase_id, _plano_id, 49, 7, 'Definir rotina de gravação semanal (batch content)', 'pendente', 'mentorado', 7, 'dossie_auto');

-- =============================================================
-- FASE 11: Meta Financeira e Acompanhamento
-- =============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 49, 'Meta Financeira e Acompanhamento', 'fase', 11, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 49, 1, 'Definir meta financeira mensal da clínica (caminho para R$100k)', 'pendente', 'mentor', 1, 'dossie_auto'),
(_fase_id, _plano_id, 49, 2, 'Calcular número de procedimentos necessários por mês', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 49, 3, 'Definir meta de faturamento da mentoria por turma', 'pendente', 'mentor', 3, 'dossie_auto'),
(_fase_id, _plano_id, 49, 4, 'Criar planilha de acompanhamento de receita (clínica + mentoria)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
(_fase_id, _plano_id, 49, 5, 'Implementar revisão quinzenal de indicadores com o mentor', 'pendente', 'mentor', 5, 'dossie_auto');

-- =============================================================
-- FASE 12: Passos Executivos Imediatos
-- =============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 49, 'Passos Executivos Imediatos', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 49, 1, 'Agendar call de revisão do dossiê com o mentor', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 49, 2, 'Atualizar bio do Instagram esta semana', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 49, 3, 'Definir data do presencial VIP até o fim da semana', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 49, 4, 'Enviar mensagem para as 2 interessadas na mentoria', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 49, 5, 'Assistir aula de vendas do programa Spalla', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 49, 6, 'Gravar 3 conteúdos da primeira semana do calendário', 'pendente', 'mentorado', 6, 'dossie_auto');

END $$;


DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN

  -- ============================================================
  -- PLANO DE AÇÃO v2 | Caroline Bittencourt (mentorado_id = 40)
  -- ============================================================
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (40, 'PLANO DE AÇÃO v2 | Caroline Bittencourt', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- ============================================================
  -- FASE 1: Revisão do Dossiê Estratégico
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 40, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 1, 'Ler o dossiê completo e anotar dúvidas sobre posicionamento e oferta', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 2, 'Validar o posicionamento Mentora-Executora com foco em profissionais de saúde (faturamento R$ 50k+)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 3, 'Revisar e aprovar a narrativa de storytelling (endividada → Zentha 300m² → R$ 5M em 3 anos)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 4, 'Agendar call com mentor para alinhar prioridades e tirar dúvidas do dossiê', 'pendente', 'mentor', 4, 'dossie_auto');

  -- ============================================================
  -- FASE 2: Estruturação da Oferta — Mentoria Sistema de Escala Sustentável
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 40, 'Estruturação da Oferta — Mentoria Sistema de Escala Sustentável', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 1, 'Definir ticket final da mentoria (faixa R$ 20-25k) e condições de pagamento', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 2, 'Estruturar a entrega: 12 encontros quinzenais + 2 hot seats + suporte via grupo', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 3, 'Montar o roteiro dos 4 pilares (Comercial, Financeiro, Marketing, Liderança) para os encontros', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 4, 'Criar página de vendas ou documento de apresentação da mentoria', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 5, 'Definir modelo híbrido (presencial na Zentha + online) e logística dos encontros', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 3: Pilar 1 — Estrutura Comercial
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 40, 'Pilar 1 — Estrutura Comercial', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 1, 'Contratar vendedora exclusiva para a mentoria (perfil consultivo, não agressivo)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 1, 'Definir perfil ideal da vendedora (experiência em high ticket, saúde/estética)', 'pendente', 'mentorado', 1, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 2, 'Publicar vaga e iniciar processo seletivo', 'pendente', 'mentorado', 2, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 3, 'Treinar vendedora com role-play semanal das 5 situações-chave', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 2, 'Criar scripts de vendas para as 5 situações de abordagem comercial', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 1, 'Script de primeiro contato (DM/WhatsApp)', 'pendente', 'equipe_spalla', 1, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 2, 'Script de qualificação de lead (perguntas para filtrar perfil ideal)', 'pendente', 'equipe_spalla', 2, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 3, 'Script de convite para evento/call de vendas', 'pendente', 'equipe_spalla', 3, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 4, 'Script de follow-up pós-evento', 'pendente', 'equipe_spalla', 4, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 5, 'Script de recuperação de leads frios', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 3, 'Implementar CRM ou planilha de controle de leads com funil de vendas', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 4, 'Definir meta comercial mensal (número de calls, propostas enviadas, conversões)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 5, 'Criar rotina semanal de prospecção ativa (lista de 10 profissionais/semana)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 4: Pilar 2 — Inteligência Financeira
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 40, 'Pilar 2 — Inteligência Financeira', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 1, 'Abrir conta PJ separada para a mentoria (separar finanças da clínica)', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 2, 'Listar todos os custos fixos e variáveis da operação de mentoria', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 3, 'Recalcular precificação da mentoria com base em custos reais e margem desejada', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 4, 'Implementar fluxo de caixa semanal (planilha ou ferramenta)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 5, 'Criar régua de cobrança automatizada para parcelas da mentoria', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 6, 'Definir pró-labore fixo e separar lucro da operação', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 5: Pilar 3 — Marketing de Autoridade
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 40, 'Pilar 3 — Marketing de Autoridade', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 1, 'Definir identidade visual high-ticket para a mentoria (paleta, tipografia, direção de arte)', 'pendente', 'equipe_spalla', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 2, 'Planejar Campanha de Base com sequência de conteúdos de aquecimento', 'pendente', 'equipe_spalla', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 3, 'Mapear 10 profissionais de saúde estratégicos para parcerias e colabs', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 4, 'Implementar momento instagramável na Zentha (espaço para fotos/stories dos mentorados)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 5, 'Criar kit de boas-vindas para mentorados (unboxing instagramável)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 6: Pilar 4 — Liderança e Gestão de Pessoas
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 40, 'Pilar 4 — Liderança e Gestão de Pessoas', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 1, 'Aplicar teste DISC na equipe da Zentha para mapear perfis comportamentais', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 2, 'Mapear performance individual da equipe (avaliação por critérios objetivos)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 3, 'Criar sistema de comissionamento por pontuação para a equipe', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 1, 'Definir critérios de pontuação (assiduidade, metas, atendimento, proatividade)', 'pendente', 'mentorado', 1, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 2, 'Criar planilha de acompanhamento mensal de pontuação', 'pendente', 'mentorado', 2, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 3, 'Comunicar o sistema para a equipe e iniciar período de teste', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 4, 'Implementar rotina de reunião semanal de 15 minutos com equipe', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 5, 'Criar processo de onboarding para novos colaboradores da clínica', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 7: Lapidação do Perfil Pessoal (Instagram Carol)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 40, 'Lapidação do Perfil Pessoal — Instagram Carol', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 1, 'Reescrever bio do Instagram pessoal (nota atual 6.1/10 — posicionar como mentora)', 'pendente', 'equipe_spalla', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 2, 'Reestruturar destaques do perfil pessoal (nota atual 5.4/10 — crítico)', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 1, 'Criar destaque "Minha História" (storytelling pessoal)', 'pendente', 'equipe_spalla', 1, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 2, 'Criar destaque "Mentoria" (método, pilares, resultados)', 'pendente', 'equipe_spalla', 2, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 3, 'Criar destaque "Resultados" (cases e provas sociais)', 'pendente', 'equipe_spalla', 3, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 4, 'Criar destaque "Zentha" (bastidores da clínica como prova de execução)', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 3, 'Substituir os 3 posts fixados do perfil pessoal (nota atual 3.9/10 — urgente)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 1, 'Post fixado 1: Carrossel de storytelling (de endividada a R$ 5M)', 'pendente', 'equipe_spalla', 1, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 2, 'Post fixado 2: Reels de autoridade sobre gestão de clínicas', 'pendente', 'equipe_spalla', 2, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 3, 'Post fixado 3: Conteúdo sobre a mentoria com CTA claro', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 4, 'Atualizar foto de perfil com direção de arte profissional (nota atual 8.2/10 — manter ou refinar)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 5, 'Limpar feed: arquivar posts que não comunicam autoridade ou posicionamento de mentora', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 8: Lapidação do Perfil da Clínica (Instagram Zentha)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 40, 'Lapidação do Perfil da Clínica — Instagram Zentha', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 1, 'Reescrever bio do perfil Zentha (nota atual 6.5/10 — destacar diferenciais)', 'pendente', 'equipe_spalla', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 2, 'Reestruturar destaques do perfil Zentha (nota atual 5/10)', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 1, 'Criar destaque "Estrutura" (tour pela clínica de 300m²)', 'pendente', 'equipe_spalla', 1, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 2, 'Criar destaque "Tratamentos" (serviços oferecidos com antes/depois)', 'pendente', 'equipe_spalla', 2, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 3, 'Criar destaque "Depoimentos" (provas sociais de pacientes)', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 3, 'Atualizar foto de perfil da Zentha com logotipo profissional', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 4, 'Revisar e otimizar os posts fixados do perfil Zentha (nota atual 7.5/10)', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  -- ============================================================
  -- FASE 9: Produção de Conteúdo — Perfil Pessoal Carol
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 40, 'Produção de Conteúdo — Perfil Pessoal Carol', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 1, 'Montar calendário editorial semanal de 7 dias para perfil pessoal', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 1, 'Dia de Alcance: Reels de conteúdo viral sobre gestão de clínicas', 'pendente', 'equipe_spalla', 1, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 2, 'Dia de Consciência: Carrossel educativo sobre os 4 pilares', 'pendente', 'equipe_spalla', 2, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 3, 'Dia de Confiança: Stories mostrando bastidores e rotina real', 'pendente', 'equipe_spalla', 3, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 4, 'Dia de Desejo: Post de prova social ou case de sucesso', 'pendente', 'equipe_spalla', 4, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 5, 'Dia de Identificação: Conteúdo pessoal e vulnerável (storytelling)', 'pendente', 'equipe_spalla', 5, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 6, 'Dia de Oportunidade: CTA direto para aplicação ou contato', 'pendente', 'equipe_spalla', 6, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 7, 'Dia de Conexão: Lives ou collabs com profissionais de saúde', 'pendente', 'equipe_spalla', 7, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 2, 'Gravar primeiro lote de 4 Reels (conteúdos de alcance e consciência)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 3, 'Agendar call com equipe de conteúdo para alinhar direção editorial', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 4, 'Criar banco de ideias de conteúdo com 30 pautas para os próximos 30 dias', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  -- ============================================================
  -- FASE 10: Produção de Conteúdo — Perfil Zentha
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 40, 'Produção de Conteúdo — Perfil Zentha', 'fase', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 1, 'Montar calendário editorial semanal para perfil Zentha', 'pendente', 'equipe_spalla', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 2, 'Produzir conteúdos de Autoridade e Prova Social (antes/depois, depoimentos)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 3, 'Criar conteúdos de Infovendas (explicando procedimentos com CTA para agendamento)', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 4, 'Produzir conteúdos de Bastidores (rotina da clínica, equipe, dia a dia)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 5, 'Criar conteúdos de Posicionamento e Diferenciais (estrutura 300m², tecnologia, equipe)', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 11: Funil de Aquecimento e Evento Presencial
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 40, 'Funil de Aquecimento e Evento Presencial de Conversão', 'fase', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 1, 'Ativar base quente: lista Invisalign (244), Melhores Amigos (400), Outros Grupos (160)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 1, 'Enviar sequência de 3 stories de aquecimento para lista Melhores Amigos', 'pendente', 'mentorado', 1, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 2, 'Enviar mensagem personalizada para lista Invisalign (profissionais de saúde)', 'pendente', 'mentorado', 2, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 3, 'Ativar grupos WhatsApp com conteúdo de valor antes do convite', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 2, 'Adicionar pessoa no WhatsApp para gestão de convites e confirmações', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 3, 'Criar copy dos convites para evento presencial na Zentha', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 4, 'Definir data, horário e logística do evento presencial na Zentha', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 5, 'Montar roteiro do evento presencial com 3 blocos (contexto, conteúdo, oferta)', 'pendente', 'equipe_spalla', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 1, 'Bloco 1: Abertura com storytelling pessoal + contexto do mercado', 'pendente', 'equipe_spalla', 1, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 2, 'Bloco 2: Conteúdo dos 4 pilares com mini-diagnóstico dos participantes', 'pendente', 'equipe_spalla', 2, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 40, 3, 'Bloco 3: Pitch da mentoria + CTA + condições especiais do evento', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 6, 'Executar campanha de pré-aquecimento 7 dias antes do evento', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 7, 'Criar checklist completo do dia do evento (espaço, materiais, equipe, recepção)', 'pendente', 'equipe_spalla', 7, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 8, 'Executar follow-up pós-evento com lista de interessados (48h)', 'pendente', 'mentorado', 8, 'dossie_auto');

  -- ============================================================
  -- FASE 12: Tráfego Pago e Prospecção Digital
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 40, 'Tráfego Pago e Prospecção Digital', 'fase', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 1, 'Configurar conta de anúncios (Meta Ads) com pixel e conversões personalizadas', 'pendente', 'equipe_spalla', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 2, 'Criar campanha de tráfego pago para captação de leads (formulário ou WhatsApp)', 'pendente', 'equipe_spalla', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 3, 'Produzir 3 criativos de anúncio (vídeo storytelling, carrossel resultados, estático oferta)', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 4, 'Definir público-alvo nos anúncios (profissionais de saúde, donos de clínica, faturamento R$ 50k+)', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 5, 'Implementar prospecção seletiva: lista de 20 perfis ideais para abordagem direta via DM', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 6, 'Definir orçamento mensal de tráfego e métricas de acompanhamento (CPL, CPA)', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 13: Cronograma de Execução e Validação Final
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 40, 'Cronograma de Execução e Validação Final', 'passo_executivo', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 1, 'Executar checklist de preparação — Semanas 1 e 2 (perfis, bio, destaques, scripts)', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 2, 'Executar checklist de preparação — Semanas 3 e 4 (conteúdo, aquecimento, convites)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 3, 'Executar fase de lançamento — Semana 1 (evento, tráfego, prospecção ativa)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 4, 'Executar fase de conversão — Semanas 2 a 4 (follow-up, calls de vendas, fechamentos)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 5, 'Fazer validação final do plano com mentor antes de iniciar execução', 'pendente', 'mentor', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 40, 6, 'Agendar reunião de revisão quinzenal para acompanhar progresso do plano', 'pendente', 'mentor', 6, 'dossie_auto');

END $$;

-- ================================================================
-- DEYSE PORTO (mentorado_id = 31)
-- ================================================================
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (31, 'PLANO DE AÇÃO v2 | Deyse Porto', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- ============================================================
  -- FASE 1: Revisão do Dossiê Estratégico
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 31, 1, 'Revisar contexto da expert: trajetória, resultados atuais e forças', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 31, 2, 'Validar público-alvo definido (psiquiatras e médicos em PIA)', 'pendente', 'mentor', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 31, 3, 'Revisar posicionamento: de professora de curso para formadora de especialistas em PIA', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 31, 4, 'Validar tese central da mentoria com Deyse', 'pendente', 'mentor', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 31, 5, 'Revisar os 4 pilares da mentoria e alinhar com a entrega real', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 31, 6, 'Mapear gaps identificados no dossiê e priorizar correções', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 2: Consolidação do Posicionamento Digital
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Consolidação do Posicionamento Digital', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 1, 'Definir narrativa única: psiquiatra → professora → mentora de médicos em PIA', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 31, 1, 'Mapear marcos da trajetória: residência, associação, consultório, formação, mentoria', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 2, 'Criar linha do tempo narrativa conectando cada marco ao propósito', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 3, 'Validar narrativa com Deyse e ajustar tom (ética, acolhimento, firmeza)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 2, 'Construir tese repetível para comunicação: raciocínio clínico + identidade + consultório', 'pendente', 'equipe_spalla', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 3, 'Reposicionar nome do produto: de "curso de casos clínicos" para "Formação ProPia"', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 4, 'Definir linhas editoriais fixas alinhadas aos 4 pilares da mentoria', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 5, 'Criar frase de posicionamento para uso recorrente em bio, posts e calls', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 3: Lapidação do Perfil do Instagram
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Lapidação do Perfil do Instagram', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 1, 'Atualizar foto de perfil: close médio, olhar direto, referência a formação no fundo', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 2, 'Reescrever bio priorizando médicos/profissionais como público principal', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 31, 1, 'Incluir promessa de transformação: "Formo médicos com raciocínio clínico seguro e consultório previsível"', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 2, 'Adicionar CTA claro direcionando para formação ou mentoria', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 3, 'Escolher entre as 3 versões sugeridas no dossiê e implementar', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 3, 'Reorganizar destaques: Sobre → Formação → Mentoria → Resultados → Consultório', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 31, 1, 'Criar destaque "Sobre / Quem Sou" com 5-8 stories novos de apresentação', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 2, 'Criar destaque "Formação Clínica" explicando o curso/ProPia', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 3, 'Criar destaque "Mentoria Clínica Avançada" com 5-8 stories novos', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 4, 'Agrupar destaques clínicos (Autismo, TOC, SONO etc.) em 3-4 guarda-chuvas', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 5, 'Arquivar ou mover para o fim destaques pessoais/pouco estratégicos', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 4, 'Revisar posts fixados: manter plaquinha Hotmart e depoimento Amanda, criar novo post explicando trilha Formação + Mentoria', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 5, 'Criar post fixado de apresentação + autoridade focado em médicos', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 4: Estruturação da Oferta da Mentoria Clínica Avançada
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Estruturação da Oferta da Mentoria Clínica Avançada', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 1, 'Finalizar arquitetura dos 4 pilares da mentoria com conteúdo programático', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 31, 1, 'Pilar 1: Detalhar módulos de Excelência Clínica e Raciocínio Diagnóstico', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 2, 'Pilar 2: Estruturar entrega de Identidade Clínica e Repertório Profissional', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 3, 'Pilar 3: Organizar conteúdo de Estrutura e Gestão de Consultório', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 4, 'Pilar 4: Definir entregáveis de Posicionamento e Autoridade Profissional', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 2, 'Definir formato final: encontros quinzenais (1 clínico + 1 carreira) + trilhas gravadas', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 3, 'Estruturar diagnóstico personalizado inicial para cada mentorado', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 4, 'Definir e validar ticket da mentoria: R$ 20.000 a R$ 25.000', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 5, 'Criar modelo de upgrade com desconto para alunos antigos do curso', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 6, 'Organizar ferramentas de implementação: planilhas, scripts e templates', 'pendente', 'equipe_spalla', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 31, 1, 'Criar Painel de Gestão Médica (controle de custos, precificação, projeções)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 2, 'Criar Plano de Expansão de Rede Profissional (parcerias com escolas, pediatras, psicólogos)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 3, 'Criar Scripts de Comunicação Médica (agendamento, cancelamento, pós-consulta)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 4, 'Criar Mapa de Identidade Clínica (posicionamento atual, público-alvo, nicho)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 5, 'Criar Guia de Posicionamento Profissional (imagem médica, comunicação, visibilidade)', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 5: Pilar 1 - Excelência Clínica e Raciocínio Diagnóstico
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Pilar 1 — Excelência Clínica e Raciocínio Diagnóstico Avançado', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 1, 'Trazer casos avançados e reais da prática em PIA para os encontros', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 2, 'Aplicar o roteiro padrão de avaliação infantojuvenil nas consultas', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 3, 'Registrar dúvidas e condutas para receber feedback clínico estruturado', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 4, 'Participar ativamente da discussão técnica dos casos e revisar condutas', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 5, 'Estudar protocolos e literatura científica aplicada à infância e adolescência', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 6, 'Implementar ajustes clínicos definidos na supervisão e no feedback individualizado', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 6: Pilar 2 - Identidade Clínica e Repertório Profissional
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Pilar 2 — Construção da Identidade Clínica e Repertório Profissional', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 1, 'Preencher o Mapa de Identidade Clínica com detalhes sobre atuação, pacientes e nicho', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 2, 'Definir público que deseja atender prioritariamente na infância e adolescência', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 3, 'Delimitar estilo de prática médica que quer sustentar no consultório e na carreira', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 4, 'Revisar posicionamento atual à luz da identidade clínica desejada', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 5, 'Desenhar plano de construção profissional coerente com o legado desejado', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 6, 'Reposicionar progressivamente a atuação rumo ao perfil clínico desejado', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 7: Pilar 3 - Estrutura e Gestão de Consultório
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Pilar 3 — Estrutura e Gestão de Consultório', 'passo_executivo', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 1, 'Mapear estrutura atual do consultório: fluxo de pacientes, agenda, retornos e processos', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 2, 'Utilizar o Painel de Gestão Médica para organizar custos, precificação e projeções', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 3, 'Revisar e ajustar precificação buscando equilíbrio entre valor e sustentabilidade', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 4, 'Desenhar jornada do paciente e da família do primeiro contato ao pós-consulta', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 5, 'Implementar scripts internos de atendimento, agendamento, cancelamento e pós-consulta', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 6, 'Aplicar o Plano de Expansão de Rede Profissional com escolas, pediatras e psicólogos', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 7, 'Monitorar estabilidade da agenda, recorrência de pacientes e indicações espontâneas', 'pendente', 'mentorado', 7, 'dossie_auto');

  -- ============================================================
  -- FASE 8: Pilar 4 - Posicionamento e Autoridade Profissional
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Pilar 4 — Posicionamento e Autoridade Profissional', 'passo_executivo', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 1, 'Revisar imagem médica e presença atual (online e offline) com Guia de Posicionamento', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 2, 'Ajustar comunicação para transmitir autoridade com ética e clareza', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 3, 'Definir frentes de visibilidade técnica: palestras, publicações, congressos, mídia médica', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 4, 'Planejar e executar ações de visibilidade técnica (eventos, conteúdos, posicionamento)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 5, 'Utilizar Preparação para Provas e Palestras para estruturar apresentações', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 6, 'Integrar posicionamento clínico, identidade e consultório em narrativa coerente', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 9: Sprint de Vendas — Preparação (Semana 1)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Sprint de Vendas — Preparação (Semana 1)', 'passo_executivo', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 1, 'Finalizar oferta revisada da Mentoria Clínica Avançada', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 2, 'Finalizar arquitetura dos pilares com entregáveis claros', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 3, 'Gerar roteiros da call de vendas adaptados ao tom da Deyse', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 4, 'Criar lista com os ~20 médicos da base quente para abordagem', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 5, 'Validar materiais e estratégia com a Queila por áudio', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 10: Sprint de Vendas — Ligações e Agendamento (Semana 2)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Sprint de Vendas — Ligações 1x1 e Agendamento (Semana 2)', 'passo_executivo', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 1, 'Enviar mensagens de abordagem (3 variações: direta, antecipação, calorosa)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 31, 1, 'Personalizar mensagem V1 (direta/curiosidade) para cada médico da lista', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 2, 'Personalizar mensagem V2 (antecipação) para médicos mais próximos', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 3, 'Personalizar mensagem V3 (calorosa/conexão) para alunos antigos', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 2, 'Fazer ligações curtas de qualificação (5 minutos) seguindo script do dossiê', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 3, 'Qualificar rapidamente com perguntas de status, técnica, faturamento e dor', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 4, 'Agendar calls de vendas apenas com quem demonstrar desejo real', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ============================================================
  -- FASE 11: Sprint de Vendas — Calls de Vendas e Fechamento (Semanas 3-4)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Sprint de Vendas — Calls de Vendas e Fechamento (Semanas 3-4)', 'passo_executivo', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 1, 'Executar calls de vendas seguindo o script completo de 7 passos do dossiê', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 31, 1, 'Passo 1: Abertura com seleção e exclusividade', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 2, 'Passo 2: Reaquecimento retomando dores e metas da qualificação', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 3, 'Passo 3: Apresentação da jornada (sem listar entregáveis)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 4, 'Passo 4-5: Checagem e apresentação do investimento (R$ 20-25k)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 5, 'Passo 6-7: Fechamento e inversão de polaridade se necessário', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 2, 'Gravar todas as calls para análise posterior de objeções e padrões', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 3, 'Coletar e catalogar objeções recorrentes (dinheiro, tempo, medo, frustração)', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 4, 'Fazer follow-up qualificado com leads que não fecharam na call', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 5, 'Fechar upgrades para alunos antigos com condição especial', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 6, 'Avaliar métricas de qualificação e ajustar comunicação para próxima fase', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 12: Estratégia de Conteúdo e Calendário Editorial
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Estratégia de Conteúdo e Calendário Editorial', 'fase', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 1, 'Implementar calendário editorial semanal com 5 linhas editoriais definidas', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 31, 1, 'Domingo/Quinta: Desejo e oportunidade (aspiracional, futuro, mentoria)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 2, 'Segunda/Sexta: Confiança no expert (autoridade, prova, bastidor)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 3, 'Terça: Alcance e descoberta (tendências, contrassenso, mercado)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 4, 'Quarta: Infovendas (frameworks, tutoriais, história do produto)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 5, 'Sábado: Identificação com expert (crença, história pessoal, mentalidade)', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 2, 'Produzir conteúdos de alcance: clínica infantil, formação médica, posicionamento ético', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 3, 'Produzir conteúdos de consciência de problema: erros comuns, falta de supervisão, história da mentoria', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 4, 'Produzir conteúdos de confiança: case comentado, bastidor da mentoria, prova social', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 5, 'Produzir conteúdos de desejo: lifestyle, tese da mentoria, quebra de objeção', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 6, 'Produzir conteúdos de identificação: posicionamento de mercado, mentalidade, história pessoal', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 13: Tráfego Pago — Turbinar e Distribuir
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Tráfego Pago — Turbinar e Distribuir no Instagram', 'passo_executivo', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 1, 'Configurar preparação técnica: Instagram profissional, Página Facebook, Gerenciador de Anúncios', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 31, 1, 'Verificar/mudar Instagram para conta profissional', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 2, 'Criar página no Facebook e conectar ao Instagram', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 3, 'Acessar Gerenciador de Anúncios e configurar forma de pagamento', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 2, 'Iniciar testes de Turbinar: escolher 2-3 posts, R$ 28/dia por 4 dias cada', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 3, 'Avaliar custo por seguidor após 2 dias e calcular média de referência', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 4, 'Escalar posts que performam abaixo da média (R$ 28-40/dia, 7-14 dias)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 5, 'Criar campanha de Distribuição no Gerenciador com público de engajadores', 'pendente', 'mentorado', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 31, 1, 'Criar público personalizado de engajadores do Instagram', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 2, 'Criar campanha com objetivo "Engajamento", R$ 15-25/dia contínuo', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 31, 3, 'Adicionar 2-3 posts existentes e publicar campanha', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 6, 'Monitorar métricas semanalmente: frequência, alcance, CPM, custo por seguidor', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 7, 'Trocar posts da distribuição a cada 3-4 dias para manter frescor', 'pendente', 'mentorado', 7, 'dossie_auto');

  -- ============================================================
  -- FASE 14: Funil Recorrente — Base de Alunos para Mentoria
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Funil Recorrente — Base de Alunos para Mentoria', 'fase', 14, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 1, 'Estruturar funil de conversão: Formação ProPia → base qualificada → Mentoria Avançada', 'pendente', 'equipe_spalla', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 2, 'Criar sistema de abordagem ativa dentro da base de alunos existentes', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 3, 'Ativar rede de contatos profissionais (associações, congressos, colegas) como fonte de leads', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 4, 'Implementar call de venda estruturada como processo recorrente (não pontual)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 5, 'Criar processo de renovação e retenção de mentorados ao longo dos 12 meses', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 6, 'Reduzir dependência de lançamentos pontuais com faturamento previsível', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 15: Escalabilidade da Mentoria sem Sobrecarga
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 31, 'Escalabilidade da Mentoria sem Sobrecarga', 'fase', 15, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 1, 'Gravar trilhas de conteúdo para que mentorados executem o plano de forma autônoma', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 2, 'Estruturar aulas gravadas por pilar para reduzir dependência de encontros ao vivo', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 3, 'Definir formato escalável: grupo + acompanhamento individual sem ficar presa em 1:1', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 4, 'Criar processos sólidos de onboarding e acompanhamento de mentorados', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 31, 5, 'Preparar comunidade psiquiátrica avançada como espaço de troca entre mentorados', 'pendente', 'mentorado', 5, 'dossie_auto');

END $$;


DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (48, 'PLANO DE ACAO v2 | Gustavo Guerra', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- =============================================
  -- FASE 1: Revisao do Dossie Estrategico
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Revisao do Dossie Estrategico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 48, 1, 'Revisar e validar publico-alvo definido (oftalmologistas e cirurgioes plasticos que operam blefaroplastia)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 48, 2, 'Revisar e validar Oferta 15k (Observership 2 dias + bonus)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 48, 3, 'Revisar e validar Oferta 30k (VIP 3 dias + pratica assistida + mentoria 3 meses)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 48, 4, 'Revisar e validar arquitetura do produto (6 pilares da mentoria)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 48, 5, 'Revisar e validar estrategia de funil (abordagem de lista + ligacao + call de venda)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 48, 6, 'Revisar sugestoes de lapidacao do perfil do Instagram', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- =============================================
  -- FASE 2: Estruturacao dos Ativos Comerciais
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Estruturacao dos Ativos Comerciais', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 1, 'Definir data e local do evento presencial (imersao)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 48, 1, 'Definir cidade-sede da imersao (Volta Redonda, SJC ou SP)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 2, 'Reservar centro cirurgico para observership e pratica assistida', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 3, 'Definir datas da primeira turma', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 2, 'Criar formulario de aplicacao para mentoria', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 48, 1, 'Montar formulario no Typeform/Google Forms com campos de qualificacao', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 2, 'Incluir perguntas: especialidade, tempo de carreira, ticket atual, tem laser CO2, insegurancas', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 3, 'Testar e publicar o formulario', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 3, 'Criar PDF de apresentacao comercial da mentoria', 'pendente', 'equipe_spalla', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 48, 1, 'Incluir autoridade resumida do Dr. Gustavo e tese central', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 2, 'Detalhar as 2 ofertas (15k e 30k) com cronograma e entregaveis', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 3, 'Incluir ancoragem de valor, CTA e link do formulario', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  -- =============================================
  -- FASE 3: Lapidacao do Perfil do Instagram
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Lapidacao do Perfil do Instagram', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 1, 'Atualizar a bio do Instagram com posicionamento de mentor em laser CO2', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 2, 'Colocar link do formulario de aplicacao na bio', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 3, 'Organizar destaques do Instagram (Mentoria, Resultados, Tecnica, Sobre Mim)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 48, 1, 'Criar destaque "Mentoria" com stories sobre a formacao', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 2, 'Criar destaque "Resultados" com antes/depois e depoimentos', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 3, 'Criar destaque "Tecnica" com bastidores de cirurgias a laser', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 4, 'Atualizar posts fixados com conteudo estrategico de autoridade', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 5, 'Agendar nova sessao de fotos com estetica medica/tecnologica (fundo cinza/azul, luz suave)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- =============================================
  -- FASE 4: Producao de Conteudo Estrategico
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Producao de Conteudo Estrategico', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 1, 'Produzir conteudo durante viagem/congressos (bastidores, DEKA, cirurgias)', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 2, 'Gravar Reels educativos sobre parametrizacao do laser (fluencia, pulso, potencia)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 3, 'Publicar carroseis comparativos: bisturi vs laser (resultados, recuperacao, ticket)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 4, 'Criar stories com prova social (depoimentos de colegas, resultados clinicos)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 5, 'Postar conteudo sobre a tese central: parametrizacao cientifica personalizada', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- =============================================
  -- FASE 5: Montagem da Lista de Contatos
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Montagem da Lista de Contatos', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 1, 'Listar os 30-50 medicos que ja pediram mentoria ou fizeram observership informal', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 2, 'Mapear medicos de grupos profissionais que o Gustavo participa', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 3, 'Identificar medicos que comentam/interagem nos conteudos do Instagram', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 4, 'Levantar indicacoes da DEKA (speaker oficial - vantagem estrategica)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 5, 'Organizar lista em planilha com nome, especialidade, contato e nivel de interesse', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- =============================================
  -- FASE 6: Criacao dos Scripts de Abordagem
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Criacao dos Scripts de Abordagem', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 1, 'Criar script de abordagem versao Direta (curiosidade tecnica)', 'pendente', 'equipe_spalla', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 2, 'Criar script de abordagem versao Autoridade', 'pendente', 'equipe_spalla', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 3, 'Criar script de abordagem versao Relacionamento', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 4, 'Testar as 3 versoes de abordagem com 5 pessoas da lista', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 5, 'Ajustar scripts com base nas respostas recebidas', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 6, 'Disparar abordagem para a lista completa apos validacao', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- =============================================
  -- FASE 7: Ligacao de Qualificacao
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Ligacao de Qualificacao', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 1, 'Criar roteiro da ligacao de qualificacao (5 min)', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 48, 1, 'Incluir abertura leve e 3-4 perguntas de dor tecnica', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 2, 'Incluir 1-2 perguntas de meta e recapitulacao', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 3, 'Incluir ponte e convite para call completa', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 2, 'Realizar ligacoes de qualificacao com leads que responderam a abordagem', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 3, 'Agendar call de diagnostico + venda com leads qualificados', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- =============================================
  -- FASE 8: Call de Diagnostico e Venda
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Call de Diagnostico e Venda', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 1, 'Criar roteiro completo da call de diagnostico + venda', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 48, 1, 'Estruturar bloco de boas-vindas e enquadramento (3-5 min)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 2, 'Estruturar exploracao de dores tecnicas e de posicionamento (10-15 min)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 3, 'Estruturar exploracao de metas e desejos (5-10 min)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 4, 'Estruturar recapitulacao estrategica e apresentacao da tese (8-10 min)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 5, 'Estruturar explicacao dos 6 pilares da mentoria (5-10 min)', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 6, 'Estruturar ancoragem de valor e apresentacao do investimento (3-5 min)', 'pendente', 'equipe_spalla', 6, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 7, 'Estruturar fechamento consultivo e tratamento de objecoes (5-10 min)', 'pendente', 'equipe_spalla', 7, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 2, 'Treinar Gustavo no roteiro da call de venda', 'pendente', 'equipe_spalla', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 3, 'Realizar as calls de diagnostico + venda com leads qualificados', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 4, 'Preparar respostas para objecoes comuns (preco, medo tecnico, duvida no laser, indecisao)', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  -- =============================================
  -- FASE 9: Fechamento e Contrato
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Fechamento e Contrato', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 1, 'Fazer fechamento de vendas com leads aprovados na call', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 2, 'Follow up de contatos que nao fecharam na primeira call', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 3, 'Formalizar a venda com contrato (termos, pagamento, datas)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 4, 'Confirmar modalidade escolhida pelo aluno (Observership 15k ou VIP 30k)', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- =============================================
  -- FASE 10: Onboarding dos Alunos
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Onboarding dos Alunos', 'fase', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 1, 'Enviar datas da imersao e pre-requisitos tecnicos ao aluno', 'pendente', 'equipe_spalla', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 2, 'Enviar recomendacoes de estudo previo ao aluno', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 3, 'Incluir aluno no grupo de WhatsApp da turma', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 4, 'Enviar video de boas-vindas personalizado', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- =============================================
  -- FASE 11: Entrega da Imersao Presencial
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Entrega da Imersao Presencial', 'passo_executivo', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 1, 'Dia 1: Ministrar aula teorica sobre fundamentos do Laser CO2 e parametrizacao', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 48, 1, 'Ensinar diferenca entre bisturi e laser como tecnologia cirurgica', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 2, 'Ensinar parametros essenciais: fluencia, densidade, pulso e potencia', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 3, 'Demonstrar como operar diferentes fototipos com seguranca', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 4, 'Realizar simulacao pratica (hands on) com materiais de treino', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 2, 'Dia 2: Conduzir observership guiado em cirurgia real', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 48, 1, 'Executar Blefaroplastia Estruturada a Laser com explicacao ao vivo', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 2, 'Explicar logica da marcacao, reforco ligamentar e raciocinio das camadas', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 3, 'Demonstrar rejuvenescimento periocular com CO2 fracionado (segunda ponteira)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 3, 'Dia 3 (VIP): Supervisionar pratica cirurgica assistida do aluno', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 48, 1, 'Aluno opera palpebra sob supervisao direta do Dr. Gustavo', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 2, 'Orientar ajuste individual de parametros em tempo real', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 48, 3, 'Corrigir erros tecnicos e dar feedback personalizado', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 4, 'Gravar cirurgia completa profissionalmente (bonus para o aluno)', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  -- =============================================
  -- FASE 12: Mentoria e Discussao de Casos (90 dias)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 48, 'Mentoria e Discussao de Casos (90 dias pos-imersao)', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 1, 'Estruturar cronograma de encontros de discussao de casos (3 meses)', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 2, 'Realizar plantoes de duvidas sobre parametrizacao e casos reais dos alunos', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 3, 'Analisar casos complexos trazidos pelos alunos e corrigir erros de parametrizacao', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 4, 'Orientar alunos no planejamento cirurgico seguro para suas proprias clinicas', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 48, 5, 'Coletar depoimentos e resultados dos alunos para prova social', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

END $$;


DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (7, 'PLANO DE AÇÃO v2 | Érica Macedo', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- ============================================================
  -- FASE 1: Revisão do Dossiê e Alinhamento Estratégico
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Revisão do Dossiê e Alinhamento Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 7, 1, 'Validar contexto da expert: nicho odontologia/estética facial, segmentos B2C (clínica Europa) e B2B (formação avançada)', 'pendente', 'mentor', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 2, 'Confirmar produto principal: Full Regenera — formação presencial avançada baseada na Tríade (preenchimento + fios + toxina) com análise facial', 'pendente', 'mentor', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 3, 'Alinhar posicionamento: rejuvenescimento facial (evitar "harmonização"), elegante, internacional, olhar clínico', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 4, 'Validar público-alvo: dentistas e médicos com base em HOF que querem evoluir para raciocínio clínico completo', 'pendente', 'mentor', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 5, 'Revisar desafios-chave: travamento operacional, falta de gestão, medo de marketing, perfeccionismo no conteúdo', 'pendente', 'mentor', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 6, 'Validar storytelling base e marcos narrativos (7 marcos definidos no dossiê)', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 2: Reenvelopagem do Instagram e Identidade Visual
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Reenvelopagem do Instagram e Identidade Visual', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 7, 1, 'Reescrever bio do Instagram com posicionamento premium: nome + especialidade + certificação + para quem + CTA', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 7, 1, 'Definir frase de bio: "Formando dentistas e médicos em rejuvenescimento 40+ | Certificação Internacional"', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 2, 'Inserir link do formulário Google Forms na bio', 'pendente', 'equipe_spalla', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 7, 2, 'Reorganizar destaques do Instagram com categorias estratégicas', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 7, 1, 'Criar destaque "Full Regenera" com informações da formação', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 2, 'Criar destaque "Resultados" com antes/depois e cases clínicos', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 3, 'Criar destaque "Sobre Érica" com trajetória e autoridade', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 4, 'Criar destaque "Depoimentos" com provas sociais de ex-alunos', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 7, 3, 'Atualizar foto de perfil com estética premium/elegante alinhada ao novo posicionamento', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 4, 'Criar 3 posts fixados estratégicos: resultado técnico (antes/depois) + depoimento/prova social + o que é o Full Regenera', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 5, 'Definir identidade visual minimalista e premium para feed (paleta de cores, fontes, estilo de imagem)', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 3: Estruturação da Oferta Full Regenera
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Estruturação da Oferta Full Regenera', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 7, 1, 'Finalizar estrutura dos 4 pilares do conteúdo programático com preenchimentos pendentes', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 7, 1, 'Pilar 1 — Preencher técnicas específicas de preenchimento estrutural que vai ensinar', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 2, 'Pilar 2 — Definir técnicas de fio (PDO, espiral, bioestimulador) e marcas/produtos', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 3, 'Pilar 3 — Listar técnicas de toxina inteligente (platisma, MMII, masseter, skin boosting)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 4, 'Pilar 4 — Adicionar ferramentas de análise facial (análise de terços, avaliação de ptose, mapeamento)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 7, 2, 'Confirmar formato final: 2 dias presenciais (Rio, Barra da Tijuca) + 3 meses acompanhamento online', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 3, 'Validar precificação: R$8.000 à vista ou 3x R$4.000 (parcelado R$12.000)', 'pendente', 'mentor', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 4, 'Definir número máximo de vagas por turma (meta: 10 vagas)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 5, 'Confirmar se haverá pré-treinamento online (módulo teórico) e qual plataforma', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 6, 'Criar documento de oferta final com entregáveis, bônus e certificação internacional', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 4: Preparação de Materiais Didáticos e Protocolos
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Preparação de Materiais Didáticos e Protocolos', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 7, 1, 'Criar protocolo documentado de preenchimento estrutural passo a passo', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 2, 'Criar protocolo de aplicação de fios e bioestimuladores passo a passo', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 3, 'Criar protocolo de toxina inteligente passo a passo', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 4, 'Criar checklist de análise facial estruturada pré-atendimento', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 5, 'Criar guia de combinação de técnicas por perfil de paciente 40+', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 6, 'Criar modelo de apresentação de plano de rejuvenescimento ao paciente', 'pendente', 'mentorado', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 7, 'Criar template de documentação de caso (portfólio + segurança clínica)', 'pendente', 'mentorado', 7, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 8, 'Criar guia de indicação: quando injetável resolve e quando cirurgia é necessária', 'pendente', 'mentorado', 8, 'dossie_auto');

  -- ============================================================
  -- FASE 5: Infraestrutura Operacional e Pagamento
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Infraestrutura Operacional e Pagamento', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 7, 1, 'Configurar forma de receber pagamento (Pix + link de parcelamento no cartão)', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 7, 1, 'Definir plataforma de pagamento (PagSeguro, Mercado Pago ou similar)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 2, 'Configurar link de pagamento com opções à vista e parcelado', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 3, 'Testar link de pagamento com transação de R$1', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 7, 2, 'Criar formulário de pré-matrícula no Google Forms', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 7, 1, 'Incluir campos: nome, WhatsApp, email, especialidade, tempo em HOF, faturamento, cursos anteriores, motivação', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 2, 'Colar link do formulário na bio do Instagram', 'pendente', 'equipe_spalla', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 7, 3, 'Criar contrato de prestação de serviço para assinatura dos alunos', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 4, 'Criar planilha de controle de leads e vendas (nome, tipo, status, venda)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 5, 'Reservar local para o evento presencial em Barra da Tijuca, RJ', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 6: Ativação da Lista (Prospecção Ativa — Base Quente)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Ativação da Lista — Prospecção Ativa na Base Quente', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 7, 1, 'Segmentar lista de ~200 contatos em 3 grupos: ex-alunos, network ativo, contatos frios', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 7, 1, 'Prioridade 1: identificar ex-alunos (turma 2018 e outros cursos anteriores)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 2, 'Prioridade 2: mapear network ativo (dentistas/médicos com contato recente)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 3, 'Prioridade 3: listar contatos frios para reativação', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 7, 2, 'Enviar mensagens de abertura personalizadas por segmento (não vender na primeira msg)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 7, 1, 'Mensagem A (ex-alunos): retomar vínculo genuíno, perguntar como estão na HOF', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 2, 'Mensagem B (network ativo): nomear a dor de técnica sem planejamento', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 3, 'Mensagem C (contatos frios): transparência + exclusividade antes do público geral', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 4, 'Mensagem D (áudio WhatsApp): gravar áudio natural para contatos com mais intimidade', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 7, 3, 'Conduzir conversas no privado: ouvir antes de falar, qualificar com perguntas estratégicas', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 4, 'Propor ligação de qualificação (15-20 min) após 3-5 trocas de mensagem', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 5, 'Agendar e conduzir calls de venda (40-50 min) com estrutura de 8 blocos', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 6, 'Meta da fase: fechar 3 a 5 vagas via ativação da lista', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 7: Ativação em Grupos e Comunidades
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Ativação em Grupos e Comunidades', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 7, 1, 'Mapear grupos de WhatsApp e Facebook por prioridade de autoridade', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 7, 1, 'Prioridade 1: grupos onde já participou ativamente ou deu aulas', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 2, 'Prioridade 2: grupos de dentistas generalistas / odontologia estética', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 3, 'Prioridade 3: grupos de harmonização orofacial (profissionais)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 7, 2, 'Publicar mensagens de valor nos grupos (texto + áudio) sem mencionar turma/preço/vaga', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 3, 'Frequência: 1 grupo a cada 2-3 dias, começar por onde tem mais autoridade', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 4, 'Quando alguém chamar no privado: seguir protocolo de qualificação da Fase 6', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 5, 'Meta da fase: fechar 2 a 3 vagas adicionais via grupos', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 8: Conteúdo Orgânico no Instagram (Posicionamento + Aquecimento)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Conteúdo Orgânico no Instagram — Posicionamento e Aquecimento', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 7, 1, 'Executar calendário de 15 dias de conteúdo (Semanas 1-3) com mix de carrosseis e reels', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 7, 1, 'Semana 1 (Dias 1-5): conteúdo de confiança + educação — despertar que planejamento facial é oportunidade', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 2, 'Semana 2 (Dias 6-10): diferenciação + confiança — mostrar que existe forma superior e quem domina', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 3, 'Semana 3 (Dias 11-15): desejo + convite claro — quer essa solução, precisa de direcionamento', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 7, 2, 'Usar crenças-chave nos conteúdos: "Técnica sem análise é risco", "Plano de tratamento > seringa"', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 3, 'Publicar stories de bastidores: rotina clínica, cirurgia, formação, Europa — reforçar autoridade', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 4, 'Incluir CTAs estratégicos em cada post (salvar, comentar, chamar no privado)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 5, 'Respeitar compliance europeu: evitar antes/depois explícitos, focar em raciocínio e processo', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 9: Tráfego Pago (Turbinar + Anúncios de Captação)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Tráfego Pago — Turbinar Posts e Anúncios de Captação', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 7, 1, 'Impulsionar posts orgânicos com melhor performance para ampliar alcance qualificado', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 2, 'Criar campanha de captação de leads com formulário de pré-matrícula', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 3, 'Definir segmentação: dentistas e médicos com interesse em HOF/estética facial', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 4, 'Monitorar métricas de leads e custo por lead — ajustar criativos semanalmente', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 5, 'Meta: gerar leads qualificados suficientes para preencher vagas restantes', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 10: Processo de Vendas e Conversão Final
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Processo de Vendas e Conversão Final', 'fase', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 7, 1, 'Executar ligações de qualificação (15-20 min) com estrutura de 5 blocos', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 7, 1, 'Bloco 1: Quebra-gelo (1-2 min) — criar conforto e antecipar estrutura', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 2, 'Bloco 2: Situação atual (5-7 min) — entender onde está na harmonização', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 3, 'Bloco 3: Resultado desejado (3-4 min) — mapear o que quer alcançar', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 4, 'Bloco 4: Gap (2-3 min) — mostrar a distância entre atual e desejado', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 5, 'Bloco 5: Propor call de venda (2-3 min) — convidar para conversa completa', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 7, 2, 'Executar calls de venda (40-50 min) com estrutura de 8 blocos', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 7, 1, 'Blocos 1-3: Quebra-gelo + diagnóstico profundo + agitação', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 2, 'Bloco 4: Apresentação por pilares — jornada de transformação, não lista de entregáveis', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 3, 'Blocos 5-6: Checagem de interesse + investimento com ancoragem (R$65k separado vs R$8k integrado)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 4, 'Blocos 7-8: Tratar objeções com perguntas + fechamento com elegância', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 7, 3, 'Executar follow-up pós-call: 24h, 72h e 7 dias com mensagens estratégicas', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 4, 'Dominar respostas para objeções-chave: "é caro", "preciso pensar", "já fiz cursos", "não tenho tempo"', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 5, 'Meta final: 10/10 vagas fechadas até data do evento', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 11: Execução do Evento Presencial Full Regenera
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Execução do Evento Presencial Full Regenera', 'fase', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 7, 1, 'Onboarding pré-treinamento: enviar contrato, boas-vindas, checklist e materiais', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 7, 1, 'Enviar contrato para assinatura de cada aluno matriculado', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 2, 'Enviar boas-vindas + instruções de acesso à plataforma', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 3, 'Enviar checklist de pré-estudo para preparo antes do presencial', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 4, 'Confirmar presença e detalhes logísticos 3 dias antes', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 7, 2, 'Dia 1: Análise Facial + Preenchimento Estrutural + Fios', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 7, 1, 'Manhã: teoria e raciocínio clínico — análise facial estruturada + demonstração ao vivo em paciente real', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 2, 'Tarde: prática supervisionada — cada aluno executa preenchimento estrutural e fios em paciente real', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 3, 'Documentação fotográfica dos casos realizados no Dia 1', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 7, 3, 'Dia 2: Toxina Inteligente + Integração da Tríade', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 7, 1, 'Manhã: prática supervisionada de toxina inteligente com raciocínio de preservação de expressão', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 2, 'Tarde: integração dos 4 pilares — casos completos, discussão, entrega de protocolos e orientações', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 3, 'Entrega de protocolos completos (impresso + digital) e certificação internacional', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 7, 4, 'Garantir pacientes reais agendados para prática supervisionada nos 2 dias', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 5, 'Coletar depoimentos dos alunos ao final do evento para prova social', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 12: Acompanhamento Pós-Treinamento (3 Meses)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 7, 'Acompanhamento Pós-Treinamento — 3 Meses de Consolidação', 'fase', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 7, 1, 'Conduzir 3 encontros online de 1h (mensal) para discussão de casos reais', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 7, 1, 'Mês 1: aluno executa na clínica, apresenta primeiros casos, recebe análise e orientação', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 2, 'Mês 2: execução com mais autonomia, ajustes de raciocínio, casos mais complexos', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 7, 3, 'Mês 3: consolidação do método, revisão final, validação de resultados, alta técnica', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 7, 2, 'Orientar alunos na construção de portfólio de resultados próprios', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 3, 'Dar alta técnica formal ao final dos 3 meses com certificação', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 4, 'Coletar depoimentos finais e cases de sucesso para marketing da próxima turma', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 7, 5, 'Avaliar resultados da turma de validação e planejar ajustes para próxima edição', 'pendente', 'mentor', 5, 'dossie_auto');

END $$;


DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN

-- PLANO
INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
VALUES (9, 'PA Completo — Juliana Altavilla (Dossie)', 'fases', 'nao_iniciado', 'dossie_auto_v3')
RETURNING id INTO _plano_id;

-- ============================================================
-- FASE 1: Lapidação de Perfil
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 9, 'Lapidação de Perfil', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 9, 1, 'Trocar foto de perfil — crop mais fechado, versão médica premium', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 9, 2, 'Alterar nome para "Dra. Juliana Altavilla | Rinoplastia Natural BH"', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 9, 3, 'Solicitar verificação do perfil (selo verificado)', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 9, 4, 'Reescrever bio com CTA, prova social e especialidade clara', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 9, 5, 'Configurar link da bio com 3 botões: agendar consulta, aplicação mentoria, resultados/depoimentos', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 9, 6, 'Converter para conta profissional (se ainda não for)', 'pendente', 'mentorado', 6, 'dossie_auto');

-- ============================================================
-- FASE 2: Reorganização de Destaques
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 9, 'Reorganização de Destaques', 'fase', 2, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 9, 1, 'Criar destaque "História" — trajetória pessoal e profissional', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 9, 2, 'Criar destaque "Pacientes" — antes e depois, depoimentos', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 9, 3, 'Criar destaque "Procedimentos" — explicações e bastidores cirúrgicos', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 9, 4, 'Criar destaque "Bastidores" — dia a dia no consultório e clínica', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 9, 5, 'Criar destaque "Lifestyle" — vida pessoal, hobbies, família', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 9, 6, 'Criar destaque "Mentoria" — conteúdo sobre mentoria para médicos', 'pendente', 'mentorado', 6, 'dossie_auto'),
(_fase_id, _plano_id, 9, 7, 'Criar destaque "Prova Mentoria" — resultados e depoimentos de mentorados', 'pendente', 'mentorado', 7, 'dossie_auto');

-- ============================================================
-- FASE 3: Posts Fixados
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 9, 'Posts Fixados', 'fase', 3, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 9, 1, 'Criar e fixar carrossel "Minha História" — trajetória e autoridade', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 9, 2, 'Criar e fixar reels "Marco de Autoridade / Mentoria"', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 9, 3, 'Criar e fixar reels "Prova de Cliente" — depoimento de paciente', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 9, 4, 'Criar e fixar carrossel "O que é a Mentoria" — explicação do programa', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 9, 5, 'Criar e fixar reels "Quais Serviços" — overview do que oferece', 'pendente', 'mentorado', 5, 'dossie_auto');

-- ============================================================
-- FASE 4: Produção de Conteúdo e Prova Social
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 9, 'Produção de Conteúdo e Prova Social', 'fase', 4, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 9, 1, 'Intensificar produção — mínimo 3 provas sociais/semana no feed', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 9, 2, 'Produzir 2-4 conteúdos de prova social por semana (antes/depois, depoimentos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 9, 3, 'Produzir 1-2 cases comentados por semana (análise de resultado)', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 9, 4, 'Produzir 1-2 bastidores por semana (consultório, cirurgia, rotina)', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 9, 5, 'Produzir 1 conteúdo lifestyle por semana (vida pessoal, família)', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 9, 6, 'Gravar antes/depois de todos os casos cirúrgicos sistematicamente', 'pendente', 'mentorado', 6, 'dossie_auto');

-- ============================================================
-- FASE 5: Ideias de Anúncios para Mentoria (Batch 1 — Prioritários)
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 9, 'Ideias de Anúncios para Mentoria — Batch 1 (Prioritários)', 'fase', 5, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 9, 1, 'Gravar anúncio Ideia 1 — "Eu sei o que é ser médico e não saber como atrair pacientes"', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 9, 2, 'Gravar anúncio Ideia 2 — "Você já pensou em quanto dinheiro está deixando na mesa?"', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 9, 3, 'Gravar anúncio Ideia 3 — "Quando comecei minha clínica, achava que bastava ser boa cirurgiã"', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 9, 4, 'Gravar anúncio Ideia 4 — "Se alguém te dissesse que dá pra lotar sua agenda sem depender de convênio"', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 9, 5, 'Gravar anúncio Ideia 5 — "Eu faturei X com rinoplastia no último ano"', 'pendente', 'mentorado', 5, 'dossie_auto');

-- Sub-ações para cada anúncio prioritário
SELECT id INTO _acao_id FROM pa_acoes WHERE fase_id = _fase_id AND numero = 1 LIMIT 1;
INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_acao_id, _fase_id, _plano_id, 9, 1, 'Escrever roteiro seguindo gancho + desenvolvimento + CTA do dossie', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 9, 2, 'Gravar vídeo vertical (reels) com visual consultório/cirúrgico', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 9, 3, 'Editar e exportar para uso em campanha Meta Ads', 'pendente', 'mentorado', 3, 'dossie_auto');

-- ============================================================
-- FASE 6: Ideias de Anúncios para Mentoria (Batch 2 — Expansão)
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 9, 'Ideias de Anúncios para Mentoria — Batch 2 (Expansão)', 'fase', 6, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 9, 1, 'Gravar anúncio Ideia 6 — Depoimento de mentorado (prova social direta)', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 9, 2, 'Gravar anúncio Ideia 7 — "O maior erro que médicos cometem no Instagram"', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 9, 3, 'Gravar anúncio Ideia 8 — "Você não precisa de mais seguidores, precisa de pacientes certos"', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 9, 4, 'Gravar anúncio Ideia 9 — "Minha agenda estava vazia há 2 anos atrás"', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 9, 5, 'Gravar anúncio Ideia 10 — "3 coisas que todo médico deveria saber sobre marketing"', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 9, 6, 'Gravar anúncio Ideia 11 — "Se você pudesse voltar no tempo e se dar 1 conselho"', 'pendente', 'mentorado', 6, 'dossie_auto'),
(_fase_id, _plano_id, 9, 7, 'Gravar anúncio Ideia 12 — "Mentoria não é curso online. É acompanhamento real"', 'pendente', 'mentorado', 7, 'dossie_auto'),
(_fase_id, _plano_id, 9, 8, 'Gravar anúncio Ideia 13 — Bastidores: mostrando resultados reais de mentorados', 'pendente', 'mentorado', 8, 'dossie_auto'),
(_fase_id, _plano_id, 9, 9, 'Gravar anúncio Ideia 14 — "Eu poderia estar só operando, mas escolhi ajudar outros médicos"', 'pendente', 'mentorado', 9, 'dossie_auto'),
(_fase_id, _plano_id, 9, 10, 'Gravar anúncios Ideias 15-19 — restantes do dossie (lifestyle, autoridade, prova)', 'pendente', 'mentorado', 10, 'dossie_auto');

-- ============================================================
-- FASE 7: Preparação Técnica — Tráfego Pago
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 9, 'Preparação Técnica — Tráfego Pago', 'passo_executivo', 7, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 9, 1, 'Verificar conta profissional Instagram ativa', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 9, 2, 'Criar/vincular página Facebook ao perfil Instagram', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 9, 3, 'Acessar e configurar Gerenciador de Anúncios Meta', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 9, 4, 'Configurar método de pagamento no Gerenciador', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 9, 5, 'Criar e instalar Pixel Meta no Typeform', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 9, 6, 'Configurar evento de conversão do Pixel (Lead/CompleteRegistration)', 'pendente', 'mentorado', 6, 'dossie_auto');

-- ============================================================
-- FASE 8: Setup Typeform — Formulário de Captação Mentoria
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 9, 'Setup Typeform — Formulário de Captação Mentoria', 'passo_executivo', 8, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 9, 1, 'Criar conta Typeform (plano Basic ou superior)', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 9, 2, 'Criar formulário com Bloco 1 — Nome completo e WhatsApp', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 9, 3, 'Adicionar Bloco 2 — Especialidade médica e cidade', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 9, 4, 'Adicionar Bloco 3 — Tempo de atuação e faturamento atual', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 9, 5, 'Adicionar Bloco 4 — Principal desafio e objetivo com a mentoria', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 9, 6, 'Adicionar Bloco 5 — Disponibilidade de investimento', 'pendente', 'mentorado', 6, 'dossie_auto'),
(_fase_id, _plano_id, 9, 7, 'Configurar tela de Obrigado com mensagem e redirecionamento', 'pendente', 'mentorado', 7, 'dossie_auto');

-- Sub-ações técnicas do Typeform
SELECT id INTO _acao_id FROM pa_acoes WHERE fase_id = _fase_id AND numero = 7 LIMIT 1;
INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_acao_id, _fase_id, _plano_id, 9, 1, 'Configurar campos ocultos UTMs no Typeform (utm_source, utm_medium, utm_campaign, utm_content)', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 9, 2, 'Integrar Typeform com Google Sheets para receber leads', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 9, 3, 'Instalar Pixel Meta no Typeform e configurar evento de conversão', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 9, 4, 'Testar formulário completo e verificar recebimento no Sheets', 'pendente', 'mentorado', 4, 'dossie_auto');

-- ============================================================
-- FASE 9: Ação Turbinar — Atrair Seguidores Novos
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 9, 'Ação Turbinar — Atrair Seguidores Novos', 'passo_executivo', 9, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 9, 1, 'Selecionar conteúdos para turbinar — foco público médico (não pacientes)', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 9, 2, 'Configurar público-alvo: médicos, interesses em cirurgia/otorrino, 28-55 anos', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 9, 3, 'Definir orçamento teste R$28/dia por turbinada', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 9, 4, 'Turbinar pelo app Instagram (botão promover)', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 9, 5, 'Monitorar métricas: alcance, novos seguidores, custo por seguidor', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 9, 6, 'Definir critério de quando turbinar — posts com bom engajamento orgânico', 'pendente', 'mentorado', 6, 'dossie_auto');

-- ============================================================
-- FASE 10: Ação Converter — Campanha Meta Ads para Leads Mentoria
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 9, 'Ação Converter — Campanha Meta Ads para Leads Mentoria', 'passo_executivo', 10, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 9, 1, 'Criar campanha no Gerenciador com objetivo "Leads"', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 9, 2, 'Configurar público: médicos Brasil, 28-55 anos, interesses cirurgia/medicina estética', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 9, 3, 'Configurar posicionamentos: Feed + Stories + Reels (Instagram e Facebook)', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 9, 4, 'Subir criativos das 5 ideias prioritárias (Fase 5) como anúncios', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 9, 5, 'Escrever copies para cada criativo seguindo modelo do dossie', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 9, 6, 'Configurar URL de destino: link Typeform com UTMs corretos', 'pendente', 'mentorado', 6, 'dossie_auto'),
(_fase_id, _plano_id, 9, 7, 'Definir orçamento diário e publicar campanha', 'pendente', 'mentorado', 7, 'dossie_auto');

-- Sub-ações de UTMs
SELECT id INTO _acao_id FROM pa_acoes WHERE fase_id = _fase_id AND numero = 6 LIMIT 1;
INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_acao_id, _fase_id, _plano_id, 9, 1, 'Montar URL com utm_source=meta, utm_medium=ads, utm_campaign=mentoria_medicos', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 9, 2, 'Adicionar utm_content com nome de cada criativo para rastreio', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 9, 3, 'Testar link completo antes de publicar — verificar UTMs no Sheets', 'pendente', 'mentorado', 3, 'dossie_auto');

-- ============================================================
-- FASE 11: Ação Distribuir — Aquecer Audiência Existente
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 9, 'Ação Distribuir — Aquecer Audiência Existente', 'passo_executivo', 11, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 9, 1, 'Criar público personalizado ENV_IG_30D (engajaram no IG nos últimos 30 dias)', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 9, 2, 'Criar campanha de engajamento direcionada ao público ENV_IG_30D', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 9, 3, 'Selecionar conteúdos de prova social e autoridade para distribuir', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 9, 4, 'Configurar orçamento para distribuição (segundo plano, menor verba)', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 9, 5, 'Monitorar engajamento e aquecer audiência antes de converter', 'pendente', 'mentorado', 5, 'dossie_auto');

-- ============================================================
-- FASE 12: Rotina Semanal e Operação Contínua
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 9, 'Rotina Semanal e Operação Contínua', 'fase', 12, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_fase_id, _plano_id, 9, 1, 'Reservar 30 min/semana para verificar números (alcance, leads, custo)', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 9, 2, 'Checar leads novos no Google Sheets e qualificar MQLs', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 9, 3, 'Revisar performance das campanhas — pausar criativos ruins, escalar bons', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 9, 4, 'Selecionar próximo conteúdo para turbinar na semana', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 9, 5, 'Planejar produção de conteúdo da semana (prova social + bastidores + lifestyle)', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 9, 6, 'Entrar em contato com leads qualificados via WhatsApp', 'pendente', 'mentorado', 6, 'dossie_auto'),
(_fase_id, _plano_id, 9, 7, 'Evitar erros comuns: não mexer em campanha antes de 5 dias, não trocar criativo sem testar', 'pendente', 'mentorado', 7, 'dossie_auto');

-- Sub-ações checklist semanal
SELECT id INTO _acao_id FROM pa_acoes WHERE fase_id = _fase_id AND numero = 1 LIMIT 1;
INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
(_acao_id, _fase_id, _plano_id, 9, 1, 'Verificar custo por lead e custo por seguidor', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 9, 2, 'Verificar taxa de conversão do Typeform (visitantes vs leads)', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 9, 3, 'Comparar performance dos criativos e identificar melhor copy', 'pendente', 'mentorado', 3, 'dossie_auto');

END $$;


DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN

-- =============================================
-- PLANO DE AÇÃO — Hevellin Félix (mentorado_id = 36)
-- Dossie: Mentoria Lipo HD — Método de Definição Cervical Cirúrgica
-- =============================================

INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
VALUES (36, 'PA Hevellin Félix — Mentoria Lipo HD: Escala e Posicionamento Nacional', 'fases', 'nao_iniciado', 'dossie_auto_v3')
RETURNING id INTO _plano_id;

-- =============================================
-- FASE 1: Revisão do Dossiê e Alinhamento Estratégico
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 36, 'Revisão do Dossiê e Alinhamento Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 36, 1, 'Revisar posicionamento atual: Princesa da Papada e diferencial técnico em Lipo HD', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 36, 2, 'Validar público-alvo: dentistas com 3-10 anos em harmonização facial, faturamento R$30-100k/mês', 'pendente', 'mentor', 2, 'dossie_auto'),
(_fase_id, _plano_id, 36, 3, 'Mapear gargalos do modelo atual: atendimento individual, suporte indefinido, escala limitada', 'pendente', 'mentor', 3, 'dossie_auto'),
(_fase_id, _plano_id, 36, 4, 'Alinhar visão de resultado: referência nacional em Lipo HD, faturamento R$2,5-3M no primeiro ano', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 36, 5, 'Revisar ativos existentes: base de 30-80 alunos, Instagram 17.6k, clínica própria, equipe estruturada', 'pendente', 'mentorado', 5, 'dossie_auto');

-- =============================================
-- FASE 2: Estruturação da Metodologia "Definição HD Tripla"
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 36, 'Estruturação da Metodologia Definição HD Tripla', 'fase', 2, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 36, 1, 'Formalizar o nome e registro da metodologia Definição HD Tripla', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 36, 2, 'Estruturar Pilar 1: Técnica de Alta Definição HD — protocolos, marcações, equipamentos', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 36, 3, 'Estruturar Pilar 2: Segurança, Biossegurança e Sedação — checklists e protocolos clínicos', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 36, 4, 'Estruturar Pilar 3: Prática Guiada em Paciente Real — formato hands-on supervisionado', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 36, 5, 'Estruturar Pilar 4: Negócio, Posicionamento e Venda — precificação, branding, captação', 'pendente', 'mentor', 5, 'dossie_auto'),
(_fase_id, _plano_id, 36, 6, 'Criar documento-mestre da metodologia com os 4 pilares consolidados', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

-- =============================================
-- FASE 3: Arquitetura do Produto — Mentoria em Grupo Lipo HD
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 36, 'Arquitetura do Produto — Mentoria em Grupo Lipo HD', 'fase', 3, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 36, 1, 'Definir formato final: imersão presencial 2 dias + 3 meses de acompanhamento em grupo', 'pendente', 'mentor', 1, 'dossie_auto'),
(_fase_id, _plano_id, 36, 2, 'Estruturar cronograma da imersão presencial (dia 1 e dia 2)', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 36, 3, 'Definir estrutura do acompanhamento pós-imersão: encontros semanais, plantão de dúvidas, grupo', 'pendente', 'mentor', 3, 'dossie_auto'),
(_fase_id, _plano_id, 36, 4, 'Criar material de apoio: apostila técnica, checklists de procedimento, vídeos de referência', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 36, 5, 'Definir precificação final: ticket R$20k, turmas de 10-15 alunos, meta 6-8 turmas/ano', 'pendente', 'mentor', 5, 'dossie_auto'),
(_fase_id, _plano_id, 36, 6, 'Criar página de aplicação/inscrição para a mentoria', 'pendente', 'equipe_spalla', 6, 'dossie_auto'),
(_fase_id, _plano_id, 36, 7, 'Desenvolver sequência de onboarding para novos mentorados', 'pendente', 'equipe_spalla', 7, 'dossie_auto');

-- =============================================
-- FASE 4: Oferta e Copywriting
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 36, 'Oferta e Copywriting', 'fase', 4, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 36, 1, 'Construir Big Idea da oferta: única mentoria com prática real em paciente + método HD exclusivo', 'pendente', 'mentor', 1, 'dossie_auto'),
(_fase_id, _plano_id, 36, 2, 'Escrever copy da página de vendas/aplicação com storytelling da Hevellin', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 36, 3, 'Criar lista de objeções e respostas para script de vendas', 'pendente', 'mentor', 3, 'dossie_auto'),
(_fase_id, _plano_id, 36, 4, 'Definir bônus e garantias: acesso vitalício ao grupo, certificado, sessão extra de dúvidas', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 36, 5, 'Criar apresentação de vendas (slides) para calls de fechamento', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
(_fase_id, _plano_id, 36, 6, 'Validar oferta com 3-5 contatos quentes da base antes do lançamento', 'pendente', 'mentorado', 6, 'dossie_auto');

-- =============================================
-- FASE 5: Funil Curto 1 — Ativação da Base de Alunos
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 36, 'Funil Curto 1 — Ativação da Base de Alunos', 'fase', 5, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 36, 1, 'Levantar lista completa de ex-alunos (30-80 contatos) com dados atualizados', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 36, 2, 'Classificar ex-alunos por potencial: quentes, mornos, frios', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 36, 3, 'Criar sequência de mensagens de abordagem personalizada para cada segmento', 'pendente', 'mentor', 3, 'dossie_auto'),
(_fase_id, _plano_id, 36, 4, 'Iniciar abordagem 1:1 com os contatos quentes (meta: 10-15 conversas na semana 1)', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 36, 5, 'Agendar calls de apresentação da mentoria com interessados', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 36, 6, 'Executar calls de fechamento seguindo script de vendas', 'pendente', 'mentorado', 6, 'dossie_auto');

-- =============================================
-- FASE 6: Funil Curto 2 — Social Seller no Instagram
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 36, 'Funil Curto 2 — Social Seller no Instagram', 'fase', 6, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 36, 1, 'Mapear perfis de dentistas que interagem nos posts e stories (últimos 30 dias)', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 36, 2, 'Criar rotina diária de prospecção ativa: 10-15 DMs por dia para perfis qualificados', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 36, 3, 'Desenvolver templates de abordagem por DM: abertura, qualificação, convite para call', 'pendente', 'mentor', 3, 'dossie_auto'),
(_fase_id, _plano_id, 36, 4, 'Criar conteúdo-isca nos stories: enquetes, caixinhas de perguntas sobre Lipo HD', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 36, 5, 'Implementar fluxo de qualificação: DM → diagnóstico rápido → call agendada', 'pendente', 'mentorado', 5, 'dossie_auto');

-- =============================================
-- FASE 7: Funil Curto 3 — Network e Indicações
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 36, 'Funil Curto 3 — Network e Indicações', 'fase', 7, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 36, 1, 'Listar contatos estratégicos: colegas dentistas, professores, fornecedores, parceiros de congressos', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 36, 2, 'Criar programa de indicação: bônus ou benefício para quem indicar alunos qualificados', 'pendente', 'mentor', 2, 'dossie_auto'),
(_fase_id, _plano_id, 36, 3, 'Abordar ex-alunos satisfeitos pedindo indicações ativas', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 36, 4, 'Participar de eventos e congressos de harmonização como estratégia de captação', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 36, 5, 'Criar mini-evento presencial ou online de demonstração para atrair leads quentes', 'pendente', 'mentorado', 5, 'dossie_auto');

-- =============================================
-- FASE 8: Funil Longo — Tráfego Pago e Conteúdo Estratégico
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 36, 'Funil Longo — Tráfego Pago e Conteúdo Estratégico', 'fase', 8, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 36, 1, 'Gravar 3-5 criativos de anúncio: antes/depois, depoimento, bastidores de procedimento', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 36, 2, 'Configurar campanhas de tráfego pago: Meta Ads focado em dentistas interessados em Lipo', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 36, 3, 'Criar landing page de captura com VSL ou carta de vendas da mentoria', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
(_fase_id, _plano_id, 36, 4, 'Implementar sequência de e-mail/WhatsApp pós-captura: 5-7 mensagens de nutrição', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
(_fase_id, _plano_id, 36, 5, 'Definir orçamento inicial de tráfego: R$3-5k/mês para validação', 'pendente', 'mentor', 5, 'dossie_auto'),
(_fase_id, _plano_id, 36, 6, 'Montar calendário de conteúdo estratégico: 3 posts/semana + stories diários', 'pendente', 'equipe_spalla', 6, 'dossie_auto'),
(_fase_id, _plano_id, 36, 7, 'Criar conteúdo de autoridade: cases de resultado, bastidores, educação técnica', 'pendente', 'mentorado', 7, 'dossie_auto');

-- =============================================
-- FASE 9: Lapidação de Perfil Instagram
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 36, 'Lapidação de Perfil Instagram', 'fase', 9, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 36, 1, 'Reescrever bio do Instagram: posicionamento como mentora de Lipo HD + CTA claro', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 36, 2, 'Reduzir destaques de 14 para 7: Método HD, Resultados, Mentoria, Depoimentos, Sobre Mim, Imersão, Contato', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 36, 3, 'Reorganizar feed com posts fixados: funil duplo (atração de pacientes + atração de alunos)', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 36, 4, 'Atualizar foto de perfil: imagem profissional com jaleco ou ambiente clínico', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 36, 5, 'Criar capas padronizadas para os destaques com identidade visual da mentoria', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
(_fase_id, _plano_id, 36, 6, 'Gravar stories de posicionamento: rotina clínica, bastidores, resultados de alunos', 'pendente', 'mentorado', 6, 'dossie_auto');

-- =============================================
-- FASE 10: Estrutura Comercial e Script de Vendas
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 36, 'Estrutura Comercial e Script de Vendas', 'fase', 10, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 36, 1, 'Estudar e adaptar script de vendas consultiva para calls de fechamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 36, 2, 'Definir processo comercial: lead → qualificação → call → proposta → follow-up → fechamento', 'pendente', 'mentor', 2, 'dossie_auto'),
(_fase_id, _plano_id, 36, 3, 'Criar CRM simplificado para acompanhar pipeline de leads e conversões', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
(_fase_id, _plano_id, 36, 4, 'Treinar rotina de follow-up: 3 toques em 7 dias para leads que não fecharam', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 36, 5, 'Definir condições de pagamento: à vista, parcelado, entrada + parcelas', 'pendente', 'mentor', 5, 'dossie_auto'),
(_fase_id, _plano_id, 36, 6, 'Simular 3 calls de vendas com mentor antes de abordar leads reais', 'pendente', 'mentorado', 6, 'dossie_auto');

-- =============================================
-- FASE 11: Sprint 90 Dias — Execução e Marcos
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 36, 'Sprint 90 Dias — Execução e Marcos', 'fase', 11, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 36, 1, 'Semana 1-2: Finalizar oferta, página de aplicação, script de vendas e lista de abordagem', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 36, 1, 'Finalizar documento da oferta completa com bônus e garantias', 'pendente', 'mentorado', 1, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 36, 2, 'Publicar página de aplicação/inscrição online', 'pendente', 'equipe_spalla', 2, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 36, 3, 'Completar lista de abordagem com mínimo 50 contatos', 'pendente', 'mentorado', 3, 'dossie_auto');


INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 36, 2, 'Semana 3-4: Ativar funis curtos — base de alunos + social seller + network', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 36, 1, 'Enviar mensagens para toda a base de ex-alunos classificados como quentes', 'pendente', 'mentorado', 1, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 36, 2, 'Iniciar rotina diária de prospecção por DM no Instagram', 'pendente', 'mentorado', 2, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 36, 3, 'Agendar mínimo 5 calls de vendas na semana', 'pendente', 'mentorado', 3, 'dossie_auto');


INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 36, 3, 'Semana 5-6: Lapidação de perfil + início de conteúdo estratégico', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 36, 1, 'Completar toda a lapidação do perfil Instagram', 'pendente', 'mentorado', 1, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 36, 2, 'Publicar primeiros 6 posts do calendário de conteúdo', 'pendente', 'mentorado', 2, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 36, 3, 'Gravar criativos para anúncios pagos', 'pendente', 'mentorado', 3, 'dossie_auto');


INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 36, 4, 'Semana 7-8: Ativar tráfego pago + escalar social selling', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 36, 5, 'Semana 9-10: Otimizar funis com base em dados de conversão', 'pendente', 'mentor', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
  (_fase_id, _plano_id, 36, 6, 'Semana 11-12: Fechar primeira turma (meta 10-15 alunos) e preparar imersão', 'pendente', 'mentorado', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 36, 1, 'Confirmar local e data da primeira imersão presencial', 'pendente', 'mentorado', 1, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 36, 2, 'Enviar kit de boas-vindas e onboarding para alunos fechados', 'pendente', 'equipe_spalla', 2, 'dossie_auto');
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 36, 3, 'Preparar materiais didáticos para os 2 dias de imersão', 'pendente', 'mentorado', 3, 'dossie_auto');


-- =============================================
-- FASE 12: Próximos Passos Imediatos
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 36, 'Próximos Passos Imediatos', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 36, 1, 'Revisar e aprovar oferta final da Mentoria Lipo HD com mentor', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 36, 2, 'Montar lista de abordagem com mínimo 50 contatos qualificados', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 36, 3, 'Preparar mensagens de abordagem personalizadas para cada segmento', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 36, 4, 'Estudar e praticar script de vendas consultiva', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 36, 5, 'Executar lapidação completa do perfil Instagram esta semana', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 36, 6, 'Gravar primeiro lote de criativos para anúncios (3-5 vídeos)', 'pendente', 'mentorado', 6, 'dossie_auto'),
(_fase_id, _plano_id, 36, 7, 'Criar página de aplicação e formulário de inscrição', 'pendente', 'equipe_spalla', 7, 'dossie_auto'),
(_fase_id, _plano_id, 36, 8, 'Agendar primeira rodada de calls de vendas com leads quentes', 'pendente', 'mentorado', 8, 'dossie_auto');

END $$;


DO $$
DECLARE _plano_id UUID; _fase_id UUID; _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (136, 'PLANO DE AÇÃO v2 | Karina Cabelino', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- =============================================
  -- FASE 1: Revisão do Dossiê Estratégico
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 1, 'Revisar Storytelling Base e validar marcos narrativos', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 2, 'Revisar Público-Alvo e confirmar perfil ideal da aluna', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 3, 'Revisar Tese do Produto e validar os 3 pilares (Olhar + Pontilhada + Planejamento)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 4, 'Revisar Conteúdo Programático e ajustar com o que será realmente ensinado', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 5, 'Revisar Oferta e Arquitetura de Produto (preço, bônus, ancoragem)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 6, 'Revisar Copy da Jornada e adaptar à sua voz', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- =============================================
  -- FASE 2: Definição do Nome e Identidade da Mentoria
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Definição do Nome e Identidade da Mentoria', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 1, 'Definir nome oficial da mentoria (usar Agente de Naming ou brainstorm)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 2, 'Validar nome com equipe Spalla', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 3, 'Batizar o método: consolidar "Efeito UAU" como nome do resultado', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 4, 'Definir tagline da mentoria para uso em comunicação', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- =============================================
  -- FASE 3: Preparação Jurídica e Contratual
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Preparação Jurídica e Contratual', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 1, 'Preparar contrato da mentoria (dados, formato, investimento R$20K, política cancelamento)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 136, 1, 'Incluir dados das partes e descrição do serviço', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 2, 'Incluir formato: 2 dias presenciais + call 30 dias + turma max 4 alunas', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 3, 'Definir política de cancelamento, confidencialidade e direito de imagem', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 4, 'Configurar assinatura digital (Clicksign ou DocuSign)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 2, 'Criar modelo de proposta comercial (1-2 páginas: resumo oferta + investimento + próximos passos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 3, 'Montar pasta de documentação jurídica (contratos, termos de consentimento, guia intercorrência)', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- =============================================
  -- FASE 4: Formulário de Aplicação e Qualificação
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Formulário de Aplicação e Qualificação', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 1, 'Criar formulário de aplicação (Google Forms ou Typeform)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 136, 1, 'Incluir campos: Nome, Instagram, cidade, WhatsApp', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 2, 'Incluir perfil: Formação, tempo de atuação, faturamento, consultório próprio', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 3, 'Incluir técnica: Já injeta? Há quanto tempo? Regiões? Maior dificuldade?', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 4, 'Incluir expectativa: Por que quer a mentoria? Resultado esperado?', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 5, 'Incluir investimento: Pronta para R$20K? Forma de pagamento? Disponibilidade 2 dias em Itaperuna?', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 2, 'Definir critérios de qualificação/desqualificação da candidata', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 3, 'Testar formulário e validar fluxo de recebimento', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- =============================================
  -- FASE 5: Fluxo de Fechamento (O que fazer quando fechar)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Fluxo de Fechamento Pós-Venda', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 1, 'Definir fluxo completo pós-fechamento', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 136, 1, 'Enviar contrato para assinatura digital', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 2, 'Confirmar pagamento (PIX, cartão ou boleto)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 3, 'Enviar mensagem de boas-vindas (WhatsApp/email)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 4, 'Coletar informações: endereço, dados NF, preferências de datas', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 5, 'Adicionar aluna em planilha de controle', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 2, 'Criar template de mensagem de boas-vindas padronizado', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 3, 'Criar planilha de controle de alunas (dados, pagamento, status)', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- =============================================
  -- FASE 6: Posicionamento Digital como Mentora
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Posicionamento Digital como Mentora', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 1, 'Atualizar bio do Instagram com posicionamento de mentora HOF', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 2, 'Criar destaques no Instagram: Método, Resultados, Mentoria, Sobre Mim', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
  (_fase_id, _plano_id, 136, 3, 'Produzir conteúdo de autoridade voltado para profissionais (não só pacientes)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 136, 1, 'Postar sobre análise facial em movimento (diferencial do Olhar)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 2, 'Postar sobre Técnica Pontilhada vs. bolus convencional', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 3, 'Postar sobre processo de venda consultiva e ticket alto', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 4, 'Usar frases do banco de ouro do dossiê nos posts', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 4, 'Criar conteúdo de prova social (R$300K/mês, cidade 120K hab, cases fullface)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 5, 'Publicar bastidores da preparação da mentoria (gera antecipação)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 6, 'Seguir padrão visual de referência aspiracional (Maria Alice Flora)', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- =============================================
  -- FASE 7: Funil Caçador — Prospecção e Vendas
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Funil Caçador — Prospecção e Vendas da Turma 1', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 1, 'Levantar lista de contatos quentes (pessoas que já pediram mentoria)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 2, 'Ativar rede do grupo Protocol (Valéria) como canal de prospecção', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 3, 'Ativar rede do grupo de cirurgia como canal de prospecção', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 4, 'Abordar contatos da rede local (referência na cidade)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 5, 'Explorar rede de pacientes médicos como indicadores', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 6, 'Fazer abordagem via WhatsApp/DM com script consultivo', 'pendente', 'mentorado', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 7, 'Agendar calls de venda com candidatas qualificadas', 'pendente', 'mentorado', 7, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 8, 'Aplicar processo de venda com ancoragem (R$35K valor real → R$20K à vista)', 'pendente', 'mentorado', 8, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 9, 'Quebrar objeções usando respostas do dossiê (preço, distância, tempo, insegurança)', 'pendente', 'mentorado', 9, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 10, 'Fechar 4 alunas para a Turma 1', 'pendente', 'mentorado', 10, 'dossie_auto');

  -- =============================================
  -- FASE 8: Preparação de Materiais Didáticos e Bônus
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Preparação de Materiais Didáticos e Bônus', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 1, 'Criar Guia de Cefalometria Simplificada para HOF (material digital)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 2, 'Criar material de Visagismo aplicado à harmonização', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 3, 'Criar Guia da Técnica Pontilhada (posições, ângulos, profundidades)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 4, 'Montar Tabela de Precificação por ml e por protocolo (Bônus 2)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 5, 'Criar Script de Venda completo — 9 etapas da conexão ao fechamento (Bônus 3)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 6, 'Montar Pack de Cases/Fotos com antes/depois organizados por tipo de face (Bônus 1)', 'pendente', 'mentorado', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 7, 'Documentar Protocolo de Regeneração: Peeling + Exossomos + 3 Homecares (Bônus 4)', 'pendente', 'mentorado', 7, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 8, 'Criar Checklist de análise facial em movimento (pontos de observação)', 'pendente', 'mentorado', 8, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 9, 'Criar modelo de ficha de avaliação facial e orçamento profissional', 'pendente', 'mentorado', 9, 'dossie_auto');

  -- =============================================
  -- FASE 9: Preparação de Materiais Físicos e Impressos
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Preparação de Materiais Físicos e Impressos', 'passo_executivo', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 1, 'Imprimir Script de Venda completo (4 cópias)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 2, 'Imprimir Planilha de Precificação (4 cópias)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 3, 'Preparar Portfolio de cases (impresso ou iPad) para uso no Dia 1', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 4, 'Imprimir Protocolo de Regeneração (4 cópias)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 5, 'Imprimir Checklist de Análise Facial (4 cópias)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 6, 'Imprimir Guia da Técnica Pontilhada (4 cópias)', 'pendente', 'mentorado', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 7, 'Comprar blocos de anotações + canetas (4 kits)', 'pendente', 'mentorado', 7, 'dossie_auto');

  -- =============================================
  -- FASE 10: Logística Presencial e Insumos
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Logística Presencial e Insumos', 'passo_executivo', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 1, 'Negociar tarifa especial em hotel/pousada para alunas', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 2, 'Mapear opções de transfer (Uber, táxi, van) e orientar sobre aeroportos (Juiz de Fora / Vitória)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 3, 'Definir alimentação: almoço incluso? Coffee break? Lista de restaurantes', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 4, 'Preparar espaço físico da clínica (cadeiras, iluminação, bancadas, ar-condicionado)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 5, 'Comprar insumos: Ácido Hialurônico (80-120ml total)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 6, 'Comprar insumos: Agulhas, cânulas, descartáveis', 'pendente', 'mentorado', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 7, 'Comprar insumos: Anestésico tópico, gelo', 'pendente', 'mentorado', 7, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 8, 'Recrutar 8-12 modelos para o Dia 2 (2-3 por aluna)', 'pendente', 'mentorado', 8, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 9, 'Fotografar modelos antecipadamente para análise prévia das alunas', 'pendente', 'mentorado', 9, 'dossie_auto');

  -- =============================================
  -- FASE 11: Onboarding das Alunas (7 dias antes)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Onboarding das Alunas — Preparação Pré-Mentoria', 'passo_executivo', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 1, 'Enviar email/WhatsApp com orientações completas (endereço, como chegar, onde ficar, programação)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 2, 'Enviar link para pasta com materiais preparatórios (PDFs)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 3, 'Enviar fotos dos modelos com orientação para análise prévia', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 4, 'Enviar material preparatório: cefalometria simplificada e visagismo', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 5, 'Criar grupo de WhatsApp da turma (4 alunas + Karina)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 6, 'Confirmar presença de todas as alunas (3 dias antes)', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- =============================================
  -- FASE 12: Realizar a Turma (Dia 1 + Dia 2)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Realizar a Turma — Dia 1 (Teoria) + Dia 2 (Prática)', 'fase', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 1, 'DIA 1 MANHÃ: Ministrar Pilar 1 — O Olhar (cefalometria, visagismo, análise em movimento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 2, 'DIA 1 TARDE: Ministrar Pilar 2 — Planejamento Estratégico (processo consultivo 9 etapas)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 3, 'DIA 1: Realizar simulação prática com fotos de modelos (planejamento + orçamento)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
  (_fase_id, _plano_id, 136, 4, 'DIA 2 INTEGRAL: Ministrar Pilar 3 — Técnica Pontilhada com modelos ao vivo', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;
  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 136, 1, 'Supervisionar diagnóstico individual de cada modelo por cada aluna', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 2, 'Acompanhar planejamento de protocolo fullface por aluna', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 3, 'Supervisionar injeção fullface com Técnica Pontilhada (2-3 modelos por aluna)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 136, 4, 'Corrigir posicionamento, pressão, distribuição e quantidade em tempo real', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 5, 'Documentar todos os procedimentos com fotos profissionais (antes/durante/depois)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 6, 'Entregar materiais e bônus às alunas ao final do Dia 2', 'pendente', 'mentorado', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 7, 'Coletar depoimentos e feedback das alunas (prova social para próximas turmas)', 'pendente', 'mentorado', 7, 'dossie_auto');

  -- =============================================
  -- FASE 13: Call de Acompanhamento 30 Dias
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Call de Acompanhamento — 30 Dias Pós-Mentoria', 'fase', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 1, 'Agendar call individual com cada aluna (30 dias após a turma)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 2, 'Analisar casos que a aluna fez na própria clínica (fotos + resultados)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 3, 'Corrigir rota e tirar dúvidas de aplicação dos 3 pilares', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 4, 'Validar evolução da taxa de conversão e ticket médio da aluna', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 5, 'Direcionar próximos passos de desenvolvimento', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 6, 'Registrar resultados para prova social e case de sucesso', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- =============================================
  -- FASE 14: Pós-Turma — Escala e Próximos Passos
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 136, 'Pós-Turma — Consolidação e Escala', 'fase', 14, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 136, 1, 'Compilar resultados da Turma 1 (depoimentos, fotos, dados de evolução das alunas)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 2, 'Publicar prova social da Turma 1 no Instagram (bastidores, depoimentos, resultados)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 3, 'Avaliar ajustes no conteúdo/logística para a Turma 2', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 4, 'Iniciar prospecção para Turma 2 usando prova social da Turma 1', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 5, 'Avaliar viabilidade de produto digital/escalável para alcance nacional', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 136, 6, 'Mapear possibilidade de estruturar tráfego pago para funil digital', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

END $$;


DO $$
DECLARE _plano_id UUID; _fase_id UUID; _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (13, 'PLANO DE ACAO v2 | Livia Lyra', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- =============================================
  -- FASE 1: REVISAO DO DOSSIE
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Revisao Geral do Dossie', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 1, 'Ler e validar o bloco de Publico-Alvo (perfil do medico comprometido e travado)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 2, 'Revisar Mapa de Crencas (3 crencas-mae + 9 travas operacionais)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 3, 'Validar descricao do produto PhleboAcademy (tese, promessa, para quem e)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 4, 'Validar descricao do IMPULSE 2026 (4 pilares, 4 estacoes, entregaveis)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 5, 'Revisar Planejamento 2026 (trimestral presencial + online)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 6, 'Anotar discordancias ou ajustes desejados no dossie', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- =============================================
  -- FASE 2: LAPIDACAO PERFIL PESSOAL @LIVIALYRA — FOTO + NOME
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Lapidacao Perfil Pessoal — Foto de Perfil e Nome', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 1, 'Fazer nova foto de perfil com corte fechado (rosto 75-80%), fundo clean, jaleco ou blazer', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 2, 'Ajustar iluminacao frontal suave e expressao de confianca serena', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 3, 'Garantir resolucao minima 640x640px', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 4, 'Alterar nome do perfil para: Dra Livia Lyra | Cirurgia Vascular', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 5, 'Subir nova foto e nome no Instagram', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- =============================================
  -- FASE 3: LAPIDACAO PERFIL PESSOAL @LIVIALYRA — BIO
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Lapidacao Perfil Pessoal — Bio do Instagram', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 1, 'Escolher versao da bio entre as 3 propostas do dossie (foco: dor do paciente + autoridade)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 2, 'Incluir linha que fale COM o paciente (nao sobre a Livia)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 3, 'Garantir CTA orientado a acao na ultima linha da bio', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 4, 'Publicar nova bio no Instagram', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- =============================================
  -- FASE 4: LAPIDACAO PERFIL PESSOAL — LINK DA BIO (LINKTREE)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Lapidacao Perfil Pessoal — Link da Bio (Linktree)', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 1, 'Reorganizar ordem dos links: Agendar consulta > Site clinico > Depoimentos > YouTube > Phlebo Academy', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 13, 1, 'Colocar "Agende sua consulta (WhatsApp)" como primeiro link', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 2, 'Mover Site Clinico para segunda posicao', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 3, 'Adicionar link de depoimentos/prova social entre YouTube e Phlebo Academy', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 4, 'Renomear link da Phlebo Academy para "Cursos para medicos (Phlebo Academy)"', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 2, 'Criar link educativo para paciente (Perguntas frequentes ou Antes e Depois)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 3, 'Manter entre 5-7 links no total para maximizar conversao', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- =============================================
  -- FASE 5: LAPIDACAO PERFIL PESSOAL — DESTAQUES
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Lapidacao Perfil Pessoal — Destaques do Instagram', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 1, 'Reduzir de 12 para 6 destaques estrategicos', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 13, 1, 'Criar destaque Historia (5-8 stories: quem e a Dra Livia, por que flebologia, evolucao)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 2, 'Criar destaque Antes e Depois (8-12 stories: depoimentos reais, prints, casos eticos)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 3, 'Criar destaque Tratamentos (8-10 stories: varizes, endolaser, laser, meia elastica)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 4, 'Criar destaque Phlebo Academy (8-10 stories: o que e, IMPULSE, para quem e)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 5, 'Criar destaque Bastidores (6-10 stories: dia a dia, eventos, preparacao)', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 6, 'Criar destaque Lifestyle (5-8 stories: rotina, saude, valores pessoais)', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 2, 'Criar capas visuais premium para os 6 destaques (fundo bege/areia, line icons, minimalista)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 3, 'Organizar sequencia: Historia > Antes e Depois > Tratamentos > Phlebo Academy > Bastidores > Lifestyle', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 4, 'Arquivar os 12 destaques antigos (nao apagar, apenas ocultar)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 5, 'Publicar nova estrutura de destaques', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- =============================================
  -- FASE 6: LAPIDACAO PERFIL PESSOAL — POSTS FIXADOS
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Lapidacao Perfil Pessoal — Posts Fixados', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 1, 'Criar Fixado 1 — Historia (Reel 30-45s): jornada profissional, valores, visao de medicina', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 2, 'Criar Fixado 2 — Historia (Carrossel 6-8 slides): por que escolhi tratar varizes desse jeito', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 3, 'Criar Fixado 3 — Prova/Autoridade (Reel): aqui nao existe milagre, existe metodo', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 4, 'Criar Fixado 4 — Produto (Carrossel 8-10 slides): como funciona o tratamento de varizes', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 5, 'Criar Fixado 5 — Produto (Reel): caso real com contexto e CTA claro', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 6, 'Ajustar hook do fixado atual de autoridade para ser mais convidativo', 'pendente', 'mentorado', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 7, 'Fixar os 5 posts na ordem estrategica e desfixar os anteriores', 'pendente', 'mentorado', 7, 'dossie_auto');

  -- =============================================
  -- FASE 7: LAPIDACAO PERFIL PESSOAL — ESTRATEGIA DE FEED
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Lapidacao Perfil Pessoal — Estrategia de Conteudo do Feed', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 1, 'Implementar narrativa estruturada no feed (Quem sou > Por que confiar > Metodo > Resultado > Proximo passo)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 2, 'Criar conteudos de lideranca (visao, padrao de cuidado, diferencial)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 3, 'Aumentar conteudo de produto didatico (passo a passo do tratamento, jornada do paciente)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 4, 'Organizar prova social em mensagem estrategica (nao so evidencia solta)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 5, 'Incluir CTA claro em todos os Reels (conduzir acao, nao so informar)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 6, 'Separar sinalizacao de conteudo para paciente vs medico/aluno', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  -- =============================================
  -- FASE 8: PRODUCAO PRIMEIROS CONTEUDOS — PERFIL PESSOAL
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Producao dos Primeiros Conteudos Estrategicos — Perfil Pessoal', 'passo_executivo', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 1, 'Produzir Reel: Variz nao e so estetica (descoberta)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 2, 'Produzir Reel: Nem toda variz precisa de tratamento (consciencia)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 3, 'Produzir Reel: Laser nao e milagre e isso e bom (autoridade)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 4, 'Produzir Reel: Como eu decido o melhor tratamento (confianca)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 5, 'Produzir Reel: Resultado real nao acontece rapido (transformacao)', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 6, 'Produzir Carrossel: Como funciona o tratamento de verdade (produto)', 'pendente', 'equipe_spalla', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 7, 'Produzir Reel: Por que eu nao prometo milagre (posicionamento)', 'pendente', 'equipe_spalla', 7, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 8, 'Produzir Reel: Voce nao e exagerada por se incomodar (identificacao)', 'pendente', 'equipe_spalla', 8, 'dossie_auto');

  -- =============================================
  -- FASE 9: LAPIDACAO PERFIL @PHLEBOACADEMY — FOTO + NOME + BIO
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Lapidacao Perfil @PhleboAcademy — Foto, Nome e Bio', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 1, 'Criar versao simplificada do logo para avatar (simbolo maior, menos linhas internas)', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 13, 1, 'Aumentar contraste do simbolo (dourado mais claro ou branco)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 2, 'Centralizar simbolo ocupando 80-85% do circulo', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 3, 'Testar versao hibrida: simbolo + subtitulo Flebologia Medica', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 4, 'Garantir resolucao 1080x1080px minimo', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 2, 'Adicionar subtitulo estrategico ao nome: Phlebo Academy | Formacao medica em flebologia pratica', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 3, 'Implementar associacao visual com a Livia (Phlebo Academy by Dra. Livia Lyra)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 4, 'Escolher e publicar nova bio entre as 4 versoes propostas no dossie', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 5, 'Garantir presenca de prova social (+700 vasculares treinados) na bio', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 6, 'Iniciar processo de solicitacao do selo de verificacao do Instagram', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- =============================================
  -- FASE 10: LAPIDACAO PERFIL @PHLEBOACADEMY — LINK + DESTAQUES + FIXADOS
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Lapidacao Perfil @PhleboAcademy — Link da Bio, Destaques e Fixados', 'fase', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 1, 'Ajustar cabecalho Linktree: Formacao medica em flebologia pratica / Por Dra. Livia Lyra', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 2, 'Otimizar copy do primeiro link: Descubra a formacao ideal para sua fase profissional', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 3, 'Ajustar copy do segundo link: Formacao Online em Flebologia — base pratica e clinica', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 4, 'Ajustar copy do terceiro link: Converse com nossa equipe educacional', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 5, 'Adicionar link futuro de prova social: Resultados e depoimentos de alunos', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 6, 'Reorganizar destaques na sequencia: Quem Somos > Alunos > Formacoes > Bastidores > Duvidas > Baixe o App', 'pendente', 'mentorado', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 13, 1, 'Refazer destaque Quem Somos (5-7 stories: por que nasceu, visao da Livia, para quem e e nao e)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 2, 'Refazer destaque Alunos (8-12 stories: depoimentos, prints, bastidores de turmas)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 3, 'Refazer destaque Formacoes (8-10 stories: quais existem, para quem, diferenca entre elas)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 4, 'Criar capas com padrao visual neutro (preto/off-white/bege, icones line finos)', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 7, 'Criar 5 fixados estrategicos para @PhleboAcademy', 'pendente', 'equipe_spalla', 7, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 13, 1, 'Fixado 1 — Historia (Carrossel 6-8 slides): Por que a Phlebo Academy existe', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 2, 'Fixado 2 — Historia (Reel 30-45s): conexao emocional + autoridade da fundadora', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 3, 'Fixado 3 — Prova/Autoridade (Reel): bastidores de eventos + comunidade real', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 4, 'Fixado 4 — Formacoes (Carrossel 8-10 slides): portfolio de produtos com clareza', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 5, 'Fixado 5 — Formacoes (Reel): conversao silenciosa, proximo passo logico', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- =============================================
  -- FASE 11: ESTRATEGIA DE FEED @PHLEBOACADEMY
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Estrategia de Conteudo do Feed @PhleboAcademy', 'fase', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 1, 'Implementar narrativa-mae no feed: Quem somos > Visao > Metodo > Transformacao > Como fazer parte', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 2, 'Criar conteudos de posicionamento repetido (frases-ancora do metodo)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 3, 'Explicar produto com clareza visual (jornada do aluno, o que muda na pratica)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 4, 'Conectar prova social a promessa explicita (nao so evidencia muda)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 5, 'Padronizar identidade visual do feed (capas com padrao claro por tipo de conteudo)', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 6, 'Sinalizar claramente para quem cada conteudo e (medico iniciante vs experiente)', 'pendente', 'equipe_spalla', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 7, 'Incluir CTA direcionais em todos os conteudos (conduzir acao, nao so informar)', 'pendente', 'equipe_spalla', 7, 'dossie_auto');

  -- =============================================
  -- FASE 12: ESTRUTURACAO DO IMPULSE 2026 — EXECUCAO
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Estruturacao e Lancamento IMPULSE 2026', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 1, 'Finalizar formulario inteligente de diagnostico para entrada no IMPULSE', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 2, 'Estruturar Score de Priorizacao e sistema de enquadramento por fase', 'pendente', 'mentor', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 3, 'Montar sistema de execucao no Notion (checklists, diagnostico, acompanhamento)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 4, 'Definir e organizar grupos de fase para encontros mensais', 'pendente', 'mentor', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 5, 'Validar estrutura das 4 estacoes do ano (Clareza > Implementacao > Consolidacao > Previsibilidade)', 'pendente', 'mentor', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 6, 'Preparar material de lancamento do IMPULSE alinhado com posicionamento do dossie', 'pendente', 'equipe_spalla', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 7, 'Estruturar precificacao e opcoes (Online R$36k / Online+Presencial R$48k)', 'pendente', 'mentor', 7, 'dossie_auto');

  -- =============================================
  -- FASE 13: PLANEJAMENTO TRIMESTRAL 2026
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 13, 'Execucao do Planejamento Trimestral 2026', 'passo_executivo', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 1, 'Executar 1o trimestre: Imersao Janeiro + START/Impulse Marco + 4 Hands (Funcional Leo + Microvasos eu)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 13, 1, 'Realizar Imersao presencial em Janeiro', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 2, 'Lancar START e Impulse em Marco', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 3, 'Executar 4 Hands (Funcional com Leo + Microvasos com Livia)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 13, 4, 'Avaliar possibilidade de One on One e Ascend no 1o trimestre', 'pendente', 'mentor', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 13, 2, 'Executar 2o trimestre: START/Impulse Junho + One on One + Ascend', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 3, 'Planejar 3o trimestre (a definir com base nos resultados)', 'pendente', 'mentor', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 4, 'Planejar 4o trimestre: evento presencial Nov/Dez (a definir em maio)', 'pendente', 'mentor', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 5, 'Terminar ajustes da formacao online para clareza do metodo e entrada de mais gente', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 6, 'Garantir que Impulse tenha opcao 100% online funcional', 'pendente', 'equipe_spalla', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 13, 7, 'Estruturar Advisor One on One como produto premium', 'pendente', 'mentor', 7, 'dossie_auto');

END $$;


DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN

-- ========================
-- PLANO DE AÇÃO — Lauanne Santos
-- ========================
INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
VALUES (33, 'PA Estratégico — Lauanne Santos | Mentora de Clínicas de Saúde', 'fases', 'nao_iniciado', 'dossie_auto_v3')
RETURNING id INTO _plano_id;

-- ========================================================
-- FASE 1: Revisão do Dossiê e Alinhamento Estratégico
-- ========================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 33, 'Revisão do Dossiê e Alinhamento Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 33, 1, 'Leitura completa do dossiê pela mentorada', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 33, 2, 'Anotar dúvidas e pontos de discordância sobre posicionamento e oferta', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 33, 3, 'Reunião de alinhamento mentor + mentorada para validar direcionamento estratégico', 'pendente', 'mentor', 3, 'dossie_auto'),
(_fase_id, _plano_id, 33, 4, 'Definir prioridades de execução: oferta, perfil ou funil primeiro', 'pendente', 'mentor', 4, 'dossie_auto'),
(_fase_id, _plano_id, 33, 5, 'Validar público-alvo principal: profissionais de saúde com clínicas faturando R$30-100k/mês', 'pendente', 'mentorado', 5, 'dossie_auto');

-- ========================================================
-- FASE 2: Posicionamento e Marca Pessoal
-- ========================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 33, 'Posicionamento e Marca Pessoal', 'fase', 2, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 33, 1, 'Adotar novo posicionamento: mentora de clínicas de saúde e estética que faturam R$30-100k', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 33, 2, 'Definir os 3 pilares de autoridade: Gestão Clínica, Marketing para Saúde, Liderança de Equipe', 'pendente', 'mentor', 2, 'dossie_auto'),
(_fase_id, _plano_id, 33, 3, 'Criar tese central: "Clínica que fatura R$500k+ não depende do dono na cadeira"', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 33, 4, 'Documentar história pessoal: de dentista solo em Ceres-GO a clínica com R$820k/mês', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 33, 5, 'Criar bio unificada para usar em redes sociais, eventos e materiais', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
(_fase_id, _plano_id, 33, 6, 'Separar identidade de marca: @doutoralauannesantos (profissional) vs @lauannesantos.theone (mentora)', 'pendente', 'mentorado', 6, 'dossie_auto');

-- ========================================================
-- FASE 3: Reestruturação da Oferta
-- ========================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 33, 'Reestruturação da Oferta', 'fase', 3, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 33, 1, 'Reestruturar oferta The One como programa regional com 6 pilares', 'pendente', 'mentor', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 33, 1, 'Pilar 1 — Educação: curadoria de cursos relevantes para o público', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 2, 'Pilar 2 — Networking: estruturar encontros presenciais regionais', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 3, 'Pilar 3 — Consultoria: definir formato de atendimento individual', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 4, 'Pilar 4 — Marketing: plano de marketing feito para o mentorado', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 5, 'Pilar 5 — Cartão Benefícios: negociar parcerias com fornecedores regionais', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 6, 'Pilar 6 — Entrega Local: usar clínica Faccia como hub de treinamento presencial', 'pendente', 'mentorado', 6, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 33, 2, 'Criar oferta standalone Mentoria Clínica Lucrativa (12 meses)', 'pendente', 'mentor', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 33, 1, 'Definir ticket: R$40k à vista ou R$50k em 7x', 'pendente', 'mentor', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 2, 'Estruturar entregáveis: mentoria individual + eventos trimestrais presenciais', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 3, 'Documentar os 3 pilares da mentoria: Captação, Conversão e Fidelização', 'pendente', 'mentor', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 4, 'Criar apresentação comercial da Mentoria Clínica Lucrativa', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 33, 3, 'Definir preço e condições de pagamento do The One regional (atual R$37.870)', 'pendente', 'mentor', 3, 'dossie_auto'),
(_fase_id, _plano_id, 33, 4, 'Criar página de vendas ou documento de apresentação de cada oferta', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
(_fase_id, _plano_id, 33, 5, 'Criar script de apresentação da oferta para calls de venda', 'pendente', 'mentor', 5, 'dossie_auto');

-- ========================================================
-- FASE 4: Arquitetura de Produto — Mentoria Clínica Lucrativa
-- ========================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 33, 'Arquitetura de Produto — Mentoria Clínica Lucrativa', 'fase', 4, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 33, 1, 'Estruturar Pilar 1 — Marketing e Captação de Pacientes', 'pendente', 'mentor', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 33, 1, 'Módulo Campanhas Internas: reativação de base, indicações, parcerias locais', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 2, 'Módulo Campanhas Externas: tráfego pago, conteúdo orgânico, eventos', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 3, 'Módulo Posicionamento Digital: Instagram, Google, presença online', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 4, 'Módulo Tráfego Pago: estrutura de campanhas, segmentação regional', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 33, 2, 'Estruturar Pilar 2 — Comercial e Conversão', 'pendente', 'mentor', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 33, 1, 'Módulo Jornada do Paciente: do primeiro contato ao fechamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 2, 'Módulo Técnica A Escada: apresentação de tratamento em fases ascendentes', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 3, 'Módulo Treinamento de Equipe: scripts de recepção e follow-up', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 4, 'Módulo Ticket Médio: estratégias para aumentar valor por paciente', 'pendente', 'mentorado', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 33, 3, 'Estruturar Pilar 3 — Fidelização e Indicação', 'pendente', 'mentor', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 33, 1, 'Módulo Campanhas de Indicação: programa Member Get Member para clínicas', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 2, 'Módulo Jornada de Encantamento: experiência do paciente pós-procedimento', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 3, 'Módulo Follow-up Estruturado: recontato em 30/60/90 dias', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 4, 'Módulo Reativação de Pacientes Inativos: campanhas de retorno', 'pendente', 'mentorado', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 33, 4, 'Criar cronograma de implementação dos 3 pilares em sprints de 4 semanas', 'pendente', 'mentor', 4, 'dossie_auto'),
(_fase_id, _plano_id, 33, 5, 'Documentar metodologia de implementação com princípios do dossiê', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

-- ========================================================
-- FASE 5: Marketing e Captação Estratégica
-- ========================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 33, 'Marketing e Captação Estratégica', 'fase', 5, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 33, 1, 'Implementar campanhas internas na clínica Faccia como modelo', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 33, 1, 'Campanha de reativação: ligar para pacientes inativos há 6+ meses', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 2, 'Campanha de indicação: benefício para quem indicar novos pacientes', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 3, 'Campanha de parcerias: acordos com academias, salões e farmácias locais', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 33, 2, 'Criar estrutura de campanhas externas: tráfego pago + conteúdo orgânico', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 33, 3, 'Montar funil de anúncio direto: Meta Ads → WhatsApp → Agendamento', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
(_fase_id, _plano_id, 33, 4, 'Implementar 4 fases de marketing do dossiê: Sprint 1 a 4 sequencialmente', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 33, 5, 'Documentar resultados de cada campanha como case para a mentoria', 'pendente', 'mentorado', 5, 'dossie_auto');

-- ========================================================
-- FASE 6: Comercial e Estrutura de Conversão
-- ========================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 33, 'Comercial e Estrutura de Conversão', 'fase', 6, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 33, 1, 'Mapear jornada completa do paciente na clínica (do WhatsApp ao pós-consulta)', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 33, 1, 'Etapa 1: Primeiro contato via WhatsApp — script de qualificação', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 2, 'Etapa 2: Recepção na clínica — protocolo de acolhimento', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 3, 'Etapa 3: Consulta — apresentação do plano de tratamento com Técnica A Escada', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 4, 'Etapa 4: Fechamento — negociação e formas de pagamento', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 5, 'Etapa 5: Pós-consulta — follow-up em 24h e agendamento de retorno', 'pendente', 'mentorado', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 33, 2, 'Criar script de venda baseado na Técnica A Escada (tratamento em fases ascendentes)', 'pendente', 'mentor', 2, 'dossie_auto'),
(_fase_id, _plano_id, 33, 3, 'Desenvolver script de recepção e atendimento telefônico/WhatsApp', 'pendente', 'mentor', 3, 'dossie_auto'),
(_fase_id, _plano_id, 33, 4, 'Implementar estratégia de aumento de ticket médio por consulta', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 33, 5, 'Criar planilha de controle de conversão: leads → agendamentos → comparecimento → fechamento', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

-- ========================================================
-- FASE 7: Treinamento de Equipe Comercial
-- ========================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 33, 'Treinamento de Equipe Comercial', 'fase', 7, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 33, 1, 'Treinar recepcionistas com scripts de agendamento e qualificação', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 33, 2, 'Realizar role-play semanal de atendimento com equipe', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 33, 3, 'Criar checklist de atendimento padrão para cada etapa da jornada', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 33, 4, 'Implementar reunião semanal de resultados: leads, agendamentos, conversão', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 33, 5, 'Gravar treinamento modelo para replicar com mentorados da Mentoria Clínica Lucrativa', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 33, 6, 'Documentar as 6 fases de implementação comercial do dossiê como material da mentoria', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

-- ========================================================
-- FASE 8: Fidelização e Estratégia de Indicação
-- ========================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 33, 'Fidelização e Estratégia de Indicação', 'fase', 8, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 33, 1, 'Criar programa de indicação Member Get Member para a clínica', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 33, 1, 'Definir benefício para quem indica: desconto, brinde ou sessão cortesia', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 2, 'Criar material de divulgação do programa de indicação', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 3, 'Treinar equipe para oferecer o programa em cada consulta', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 33, 2, 'Implementar jornada de encantamento pós-procedimento (mensagem em 24h, 7 dias, 30 dias)', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 33, 3, 'Criar campanha de reativação para pacientes inativos há 90+ dias', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 33, 4, 'Implementar sistema de follow-up estruturado: 30/60/90 dias pós-tratamento', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 33, 5, 'Criar pesquisa de satisfação pós-atendimento via WhatsApp', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
(_fase_id, _plano_id, 33, 6, 'Documentar as 6 fases de implementação de fidelização como material da mentoria', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

-- ========================================================
-- FASE 9: Funil de Evento Presencial — Bastidores 820K
-- ========================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 33, 'Funil de Evento Presencial — Bastidores 820K', 'fase', 9, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 33, 1, 'Estruturar evento presencial "Bastidores 820K" na clínica Faccia (30 pessoas)', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 33, 1, 'Definir data, local (clínica Faccia) e capacidade (30 vagas)', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 2, 'Criar roteiro do evento: conteúdo + pitch da Mentoria Clínica Lucrativa', 'pendente', 'mentor', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 3, 'Preparar kit do participante: pasta, caneta, material impresso', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 4, 'Organizar coffee break e ambientação do espaço', 'pendente', 'mentorado', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 33, 2, 'Montar funil de captação para o evento', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 33, 1, 'Criar landing page de inscrição do evento Bastidores 820K', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 2, 'Configurar anúncios Meta Ads segmentados para profissionais de saúde na região', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 3, 'Criar sequência de aquecimento: e-mail/WhatsApp pré-evento', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 4, 'Montar lista de convidados diretos via rede de contatos da Lauanne', 'pendente', 'mentorado', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 33, 3, 'Criar pitch de venda da Mentoria Clínica Lucrativa para o evento', 'pendente', 'mentor', 3, 'dossie_auto'),
(_fase_id, _plano_id, 33, 4, 'Preparar formulário de aplicação pós-evento para interessados', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
(_fase_id, _plano_id, 33, 5, 'Planejar follow-up pós-evento: call individual com cada lead quente', 'pendente', 'mentorado', 5, 'dossie_auto');

-- ========================================================
-- FASE 10: Lapidação do Perfil Instagram (@lauannesantos.theone)
-- ========================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 33, 'Lapidação do Perfil Instagram — @lauannesantos.theone', 'passo_executivo', 10, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 33, 1, 'Atualizar bio: incluir prova social (R$820k/mês) + CTA claro para evento/mentoria', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 33, 2, 'Trocar foto de perfil: manter nota 8/10, garantir fundo limpo e expressão profissional', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 33, 3, 'Criar 5 destaques estratégicos: Minha História, Resultados, Método, Depoimentos, Evento', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 33, 4, 'Redesenhar capas dos destaques com identidade visual consistente', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
(_fase_id, _plano_id, 33, 5, 'Criar 3 posts fixados: resultado transformador, método, convite para próximo passo', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 33, 6, 'Adicionar link na bio: Linktree ou página com opções (evento, aplicação, WhatsApp)', 'pendente', 'equipe_spalla', 6, 'dossie_auto'),
(_fase_id, _plano_id, 33, 7, 'Revisar feed: remover posts desalinhados com posicionamento de mentora', 'pendente', 'mentorado', 7, 'dossie_auto');

-- ========================================================
-- FASE 11: Conteúdo e Calendário Editorial
-- ========================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 33, 'Conteúdo e Calendário Editorial', 'fase', 11, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 33, 1, 'Definir linhas editoriais para o perfil de mentora', 'pendente', 'mentor', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 33, 1, 'Linha 1 — Bastidores da Clínica: rotina, equipe, processos reais', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 2, 'Linha 2 — Resultados e Cases: faturamento, transformações de mentorados', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 3, 'Linha 3 — Método e Ensino: dicas de gestão, marketing e vendas para clínicas', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 4, 'Linha 4 — Lifestyle de Mentora: vida pessoal, viagens, conquistas', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 5, 'Linha 5 — Provocações e Crenças: quebra de objeções sobre investir em mentoria', 'pendente', 'mentorado', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 33, 2, 'Criar calendário editorial semanal: 4 posts feed + 10 stories/dia + 2 reels/semana', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 33, 3, 'Produzir 10 ideias de conteúdo para o perfil de mentora conforme dossiê', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 33, 4, 'Produzir 10 ideias de conteúdo para o perfil profissional @doutoralauannesantos', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 33, 5, 'Gravar primeiro lote de 5 reels seguindo as linhas editoriais definidas', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 33, 6, 'Agendar conteúdo da primeira semana com ferramenta de agendamento', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

-- ========================================================
-- FASE 12: Anúncios e Tráfego Pago
-- ========================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 33, 'Anúncios e Tráfego Pago', 'fase', 12, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 33, 1, 'Criar 10 anúncios para o evento Bastidores 820K conforme dossiê', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 33, 1, 'Anúncio 1 — Pergunta Direta: "Sua clínica fatura menos de R$100k/mês?"', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 2, 'Anúncio 2 — Resultado Chocante: "R$820 mil por mês em Ceres-GO com 22 mil habitantes"', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 3, 'Anúncio 3 — Bastidores: "Eu vou abrir a clínica e mostrar tudo que faço"', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 4, 'Anúncio 4 — Escassez: "30 vagas para conhecer por dentro uma clínica de R$820k"', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 5, 'Anúncio 5 — Contraste: "Minha cidade tem 22 mil habitantes. Minha clínica fatura R$820k"', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 6, 'Anúncio 6 — Dor: "Você está preso na cadeira do consultório atendendo 10h/dia?"', 'pendente', 'equipe_spalla', 6, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 7, 'Anúncio 7 — Provocação: "A maioria dos dentistas acha que precisa de mais pacientes"', 'pendente', 'equipe_spalla', 7, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 8, 'Anúncio 8 — Storytelling: "Há 5 anos eu faturava R$30k e achava que era o máximo"', 'pendente', 'equipe_spalla', 8, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 9, 'Anúncio 9 — Evento: "Um dia inteiro dentro da minha clínica. Sem teoria, só prática"', 'pendente', 'equipe_spalla', 9, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 33, 10, 'Anúncio 10 — Social Proof: "X profissionais já passaram pelo meu método"', 'pendente', 'equipe_spalla', 10, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 33, 2, 'Configurar Gerenciador de Anúncios Meta: pixel, públicos, conversões', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 33, 3, 'Criar público personalizado: profissionais de saúde, raio 150km de Ceres-GO', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
(_fase_id, _plano_id, 33, 4, 'Definir orçamento inicial: R$50-100/dia para teste de criativos', 'pendente', 'mentor', 4, 'dossie_auto'),
(_fase_id, _plano_id, 33, 5, 'Gravar vídeos para os anúncios: Lauanne na clínica, bastidores, depoimentos', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 33, 6, 'Montar dashboard de acompanhamento: CPL, CPA, ROAS por anúncio', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

END $$;

DO $$
DECLARE _plano_id UUID; _fase_id UUID; _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (37, 'PLANO DE AÇÃO v2 | Letícia Ambrosano', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- =============================================
  -- FASE 0: REVISÃO DO DOSSIÊ
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Revisão do Dossiê com a Mentorada', 'revisao_dossie', 0, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 1, 'Apresentar dossiê completo para Letícia e alinhar prioridades', 'pendente', 'mentor', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 2, 'Validar público-alvo principal: médicos em transição de carreira (nota 9.0/10)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 3, 'Confirmar produto escolhido: Formação Híbrida - Método de Naturalidade Cirúrgica (R$ 50k)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 4, 'Revisar posicionamento: única médica que ensina TC com prática hands-on e naturalidade', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 5, 'Validar proposta de valor e declaração de transformação prometida', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 6, 'Alinhar ordem de execução: funil de tiro curto (lista 91 contatos) + paralelo Instagram', 'pendente', 'mentor', 6, 'dossie_auto');

  -- =============================================
  -- FASE 1: DEFINIÇÃO E PRECIFICAÇÃO DA OFERTA
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Definição e Precificação da Oferta Premium', 'fase', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 1, 'Definir precificação final da formação (R$ 40-60k) com opções à vista e parcelado', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Calcular custos fixos da imersão presencial (5 dias: centro cirúrgico, materiais, equipe)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Definir preço à vista (R$ 50k) e preço parcelado com estratégia de número quebrado', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Estruturar condição especial para primeira turma (early bird)', 'pendente', 'mentor', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 2, 'Estruturar entregáveis completos da formação', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Detalhar trilha teórica online: módulos Tricologia, Cirúrgico, Contábil e Vigilância Sanitária', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Definir formato da prática presencial: 2 dias cirurgia hands-on + 3 dias consultório real', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Estruturar acompanhamento pós-imersão: 3 meses grupo + 6 meses bônus WhatsApp', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 4, 'Listar bônus: guia equipamentos, playbook atendimento, script comercial, mentoria estruturação', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 3, 'Definir limite de vagas por turma (8-10 alunos) e cronograma da primeira turma', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 4, 'Criar documento de apresentação da oferta (PDF profissional) para envio pós-call', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 5, 'Validar diferenciais competitivos vs concorrentes (Thiago Bianco, Alan Wells, Igor Ferreira)', 'pendente', 'mentor', 5, 'dossie_auto');

  -- =============================================
  -- FASE 2: PREPARAÇÃO DA LISTA QUENTE (91 CONTATOS)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Preparação da Lista Quente - 91 Contatos', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 1, 'Mapear e listar os 32 médicos treinados na ICB com contatos atualizados', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Levantar lista completa dos 32 médicos com nome, telefone, email e especialidade', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Classificar por nível de interesse: quente, morno, frio', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Identificar quais ainda mantêm contato ativo (os que procuram para tirar dúvidas)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 2, 'Mapear contatos adicionais da rede de Campinas (até completar 91)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Listar médicos das 3 faculdades de Campinas (Unicamp + 2 particulares)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Listar contatos da Capflix e grupos de networking médico', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Incluir técnicas de enfermagem que recebem pedidos e indicam interessados', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 4, 'Incluir colegas que oferecem parcerias (ex: preceptora na Unisa)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 3, 'Segmentar lista por proximidade, especialidade e nível de interesse demonstrado', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 4, 'Organizar lista em planilha com status de abordagem (não contatado, contatado, agendado, fechado)', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  -- =============================================
  -- FASE 3: ROTEIRO DE ABORDAGEM E PITCH
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Roteiro de Abordagem e Estruturação do Pitch', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 1, 'Criar roteiro de abordagem personalizado para lista quente (WhatsApp/ligação)', 'pendente', 'mentor', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Criar mensagem de abertura para ex-alunos ICB (tom de reconexão + novidade)', 'pendente', 'mentor', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Criar mensagem para contatos novos da rede (tom de indicação + autoridade)', 'pendente', 'mentor', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Preparar perguntas de qualificação: momento de carreira, dores atuais, interesse em TC', 'pendente', 'mentor', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 2, 'Estruturar apresentação do pitch para calls de diagnóstico', 'pendente', 'mentor', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Montar estrutura da call: rapport, diagnóstico de dor, apresentação da formação, fechamento', 'pendente', 'mentor', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Incluir diferenciais claros: 2.600+ pacientes, 90% conversão, Body Hair, Naturalidade por Contraste', 'pendente', 'mentor', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Preparar respostas para as 12 objeções mais comuns do dossiê', 'pendente', 'mentor', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 4, 'Criar gatilho de urgência: primeira turma com vagas limitadas (8-10)', 'pendente', 'mentor', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 3, 'Treinar habilidade de agendamento e condução da call de venda', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 4, 'Simular 3 calls de role-play antes de iniciar abordagens reais', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- =============================================
  -- FASE 4: EXECUÇÃO DO FUNIL DE TIRO CURTO (VENDAS DIRETAS)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Execução do Funil de Tiro Curto - Vendas Diretas', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 1, 'Iniciar contato direto com os 32 médicos da ICB (Semana 1-2)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Enviar mensagens para os 10 contatos mais quentes primeiro', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Qualificar interesse e identificar dores atuais em cada conversa', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Agendar calls de diagnóstico com os interessados qualificados', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 2, 'Expandir abordagem para os demais 59 contatos da rede (Semana 2-4)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 3, 'Realizar pitch direto nas calls agendadas com foco em fechamento', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 4, 'Fazer fechamentos na própria call ou com prazo curto para decisão (48h)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 5, 'Registrar feedback de cada call para ajustar pitch e objeções', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 6, 'Meta: fechar 8-10 alunos para a primeira turma', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- =============================================
  -- FASE 5: LAPIDAÇÃO DO PERFIL INSTAGRAM
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Lapidação do Perfil Instagram (@draleticiaambrosano)', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 1, 'Atualizar bio para versão V1 - Autoridade dupla (Mentora + Cirurgiã)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Implementar bio: Dermatologista & Mentora em TC (FUE) | +3.000 resultados naturais | Criadora do Método de Naturalidade Cirúrgica', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Configurar linktree com 2 botões: Mentoria para Médicos + Pré-triagem para Pacientes', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 2, 'Testar foto de perfil com leve aumento de nitidez e contraste no fundo (nota atual 8/10)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
  (_fase_id, _plano_id, 37, 3, 'Reorganizar destaques na nova ordem estratégica (nota atual 6/10)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Criar destaque 1: Quem Sou (autoridade + conexão humana)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Criar destaque 2: Mentoria Médicos (formação, método, seleção)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Criar destaque 3: Resultados (antes/depois e cases de alunos)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 4, 'Criar destaque 4: Naturalidade (educação sobre contraste e técnica)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 5, 'Criar destaque 5: Consultas & Agenda (direcionar para ação)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 4, 'Criar e fixar os 3 posts estratégicos (nota atual 7/10)', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Post #1: Reel "Quem é a Dra. Letícia" (Autoridade + História + Método, 40s)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Post #2: Carrossel "Erros que deixam o transplante artificial" (9 slides educativos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Post #3: Carrossel "De médico inseguro a cirurgião confiante" (case de aluno)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 5, 'Padronizar CTA único em todos os stories e legendas', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- =============================================
  -- FASE 6: PRODUÇÃO DE CONTEÚDO - PAPEL PROFISSIONAL
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Produção de Conteúdo - Papel Profissional (Pacientes)', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 1, 'Implementar calendário editorial profissional (7 dias/semana)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Domingo: Lifestyle sutil e inspiração (ritual matinal, obsessão por resultado)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Segunda: Autoridade com prova social comentada (cases reais)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Terça: Infovendas (5 perguntas que salvam resultado, preço justificado)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 4, 'Quarta: Prova social estática (antes/depois natural vs artificial)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 5, 'Quinta: Bastidor do dia a dia (preparação, cirurgia 8h, verificação de folículos)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 6, 'Sexta: Prova social dinâmica (depoimentos, indicações, antes/depois)', 'pendente', 'mentorado', 6, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 7, 'Sábado: Conversa interessante (transplante dói?, médico barato, tempo de resultado)', 'pendente', 'mentorado', 7, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 2, 'Gravar primeiros 5 Reels didáticos sobre o Método de Naturalidade Cirúrgica', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 3, 'Produzir 3 carrosseis educativos sobre contraste, visagismo e programação cirúrgica', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 4, 'Coletar e organizar cases de antes/depois com autorização dos pacientes', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- =============================================
  -- FASE 7: PRODUÇÃO DE CONTEÚDO - PAPEL MENTOR
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Produção de Conteúdo - Papel Mentor (Médicos)', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 1, 'Implementar calendário editorial mentor (7 dias/semana)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Domingo/Quinta: Desejo e oportunidade (transição de carreira, ROI em 2 meses)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Segunda/Sexta: Confiança no expert (32 médicos treinados, 7 anos ICB, cases)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Terça: Alcance e descoberta (R$ 24.447 por cirurgia, aparência jovem, contraste natural)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 4, 'Quarta: Infovendas (curso online vs prática real, método vs observação)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 5, 'Sábado: Identificação com o expert (vulnerabilidade, síndrome da impostora, medo)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 2, 'Gravar 5 Reels de alcance/descoberta para atrair médicos em transição', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Reel 1: "Eu cobro R$ 24.447 por um transplante" (neuromarketing, números quebrados)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Reel 2: "Treinei 32 médicos para uma empresa. Nenhum me treinou para abrir a minha"', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Reel 3: "80% dos transplantes ficam artificiais" (técnica do contraste)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 4, 'Reel 4: "Você investiu R$ 10 mil num curso e ainda não se sente seguro"', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 5, 'Reel 5: "Fiz fertilização, tive abortos e quase não abri meu negócio" (storytelling)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 3, 'Produzir conteúdo de quebra de objeções para médicos', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Objeção idade: "Médico em transição aos 45? Essa é sua melhor janela"', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Objeção estrutura: "Não precisa de equipe gigante, precisa de método"', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Objeção medo: "Por que médicos desistem no primeiro ano (e como evitar)"', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 4, 'Objeção investimento: "ROI em 2 meses - a formação se paga em 60 dias"', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- =============================================
  -- FASE 8: ESTRATÉGIA DE STORIES
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Estratégia de Stories - Calendário Semanal', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 1, 'Implementar calendário de stories com estrutura de 5 etapas por dia', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Segunda: Educação + Autoridade (dúvida real de paciente + explicação + prova)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Terça: Bastidores de cirurgia (planejamento, etapa, rotina, equipe)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Quarta: Quebra de crença com prova (afirmação contra-intuitiva + exemplo clínico)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 4, 'Quinta: Caixinha de perguntas (dúvidas sobre transplante com respostas + prova)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 5, 'Sexta: Prova social (caso + antes/depois + planejamento + resultado)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 6, 'Sábado/Domingo: Humanização (vida pessoal, família, rotina fora do trabalho)', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 2, 'Criar 5 séries fixas de stories para construir identidade', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Série 1: Pergunta de Consulta (dúvidas reais de pacientes)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Série 2: Erro do Transplante Capilar (erros comuns do mercado)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Série 3: Bastidor da Cirurgia (processo real da operação)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 4, 'Série 4: Dúvidas de Médicos (conteúdo voltado para público mentor)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 5, 'Série 5: Caso Comentado (análise técnica de cases reais)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- =============================================
  -- FASE 9: GRAVAÇÃO DA TRILHA TEÓRICA ONLINE
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Gravação da Trilha Teórica Online - Do Zero à Mega-Sessão', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 1, 'Estruturar e gravar Módulo Tricologia (completo e estruturado)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Aula: Anatomia e embriologia do folículo piloso', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Aula: Ciclo folicular e fisiologia do crescimento do fio', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Aula: Alopecias não cicatriciais (AGA, padrão feminino, eflúvios, alopecia areata)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 4, 'Aula: Alopecias cicatriciais (LPP, AFF, FADP, foliculites diversas)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 5, 'Aula: Infecções, alterações da haste e tricopatias', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 6, 'Aula: Tricologia moderna (equipamentos, LLLT, cabine, medicações)', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 2, 'Estruturar e gravar Módulo Cirúrgico', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Aula: Anestesia local e complicações cirúrgicas', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Aula: Shave, non-shave e long-hair + marcação cirúrgica', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Aula: Seleção de bons candidatos e contraindicações', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 4, 'Aula: Tempo, materiais, fluxo e segurança cirúrgica', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 5, 'Aula: Pós-operatório que atrai indicações + estrutura para operar', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 6, 'Aula: Formação e treinamento da equipe + materiais necessários', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 3, 'Gravar Módulo Contábil (impostos específicos para procedimentos cirúrgicos)', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 4, 'Gravar Módulo Vigilância Sanitária (requisitos antes de iniciar projeto)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 5, 'Gravar e editar banco de cirurgias comentadas (olho do cirurgião)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 6, 'Hospedar conteúdo em plataforma de ensino online (definir plataforma)', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  -- =============================================
  -- FASE 10: PREPARAÇÃO DA IMERSÃO PRESENCIAL
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Preparação da Imersão Presencial - 5 Dias', 'fase', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 1, 'Preparar estrutura dos 2 dias de cirurgia hands-on', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Selecionar pacientes adequados para as cirurgias de treinamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Preparar roteiro de etapas: extração, lapidação, implante, manejo intraoperatório', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Garantir equipamentos e materiais para prática supervisionada', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 2, 'Preparar estrutura dos 3 dias de consultório real', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Agendar consultas novas para observação (seleção, planejamento, fechamento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Programar retornos de 7 dias, 3, 6, 9 e 12 meses para acompanhamento', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Preparar demonstração de dermatoscopia digital e registro fotográfico', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 3, 'Criar checklists, playbooks e protocolos para entrega aos alunos', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 4, 'Definir logística: hospedagem, alimentação e transporte para alunos de fora', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 5, 'Criar certificação em Naturalidade Cirúrgica (modelo do certificado)', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- =============================================
  -- FASE 11: PÓS-VALIDAÇÃO E ESCALA
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Pós-Validação da Primeira Turma e Escala', 'fase', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 1, 'Coletar depoimentos e cases de sucesso dos primeiros alunos formados', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 2, 'Documentar antes/depois dos alunos (evolução técnica) para prova social', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 3, 'Ajustar oferta e conteúdo com base no feedback da primeira turma', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 4, 'Estruturar funil de captação para públicos secundários (Dermatologistas, Recém-formados)', 'pendente', 'mentor', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 5, 'Trabalhar estratégia de posicionamento e rede social de longo prazo', 'pendente', 'mentor', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 6, 'Preparar terreno para tráfego pago (3-6 meses após validação orgânica)', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  -- =============================================
  -- FASE 12: STORYTELLING E POSICIONAMENTO PESSOAL
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 37, 'Storytelling e Posicionamento Pessoal da Dra. Letícia', 'fase', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 1, 'Refinar e ensaiar storytelling pessoal para uso em lives, calls e eventos', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 37, 1, 'Bloco 1: Aparência jovem como trunfo e obstáculo (38 anos, parece 30)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 2, 'Bloco 2: Formação sólida (residência dermatologia + fellow tricologia + ICB)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 3, 'Bloco 3: 7 anos como diretora/referência na ICB, treinando 32 médicos', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 4, 'Bloco 4: Vida pessoal - fertilização, abortos, marido desempregado, medo de sair', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 5, 'Bloco 5: Decisão de sair em nov/2024 - nunca fechou no vermelho, R$ 24.447 por cirurgia', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 37, 6, 'Bloco 6: Descoberta dos 4 pilares (Contraste, Visagismo, Programação, Densidade)', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 37, 2, 'Reposicionar discurso de "dermatologista que faz transplante" para "referência que ensina transplante com naturalidade"', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 3, 'Incorporar comunicação didática: método, técnica, bastidor de ensino', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 4, 'Incluir prova de alunos formados e CTA de seleção de mentoria em todo conteúdo', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 37, 5, 'Consolidar tese central: Protocolo N4 - Naturalidade em 4 Fatores (seleção, programação, contraste, visagismo, execução)', 'pendente', 'mentorado', 5, 'dossie_auto');

END $$;
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN

  -- =============================================
  -- PLANO DE ACAO - Miriam Alves (mentorado_id=50)
  -- =============================================
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (50, 'PLANO DE ACAO v2 | Miriam Alves', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- =============================================
  -- FASE 0: Revisao do Dossie Estrategico
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Revisao do Dossie Estrategico com a Mentorada', 'revisao_dossie', 0, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 1, 'Revisar contexto da expert: trajetoria, formacao (USP, Harvard), +11 anos, +2.400 cirurgias', 'pendente', 'mentor', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 2, 'Validar posicionamento: de oftalmologista clinica para referencia em ensino de cirurgia refrativa', 'pendente', 'mentor', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 3, 'Revisar publico-alvo da mentoria: oftalmologistas recem-formados R1-R3 buscando dominar refrativa', 'pendente', 'mentor', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 4, 'Revisar publico-alvo de pacientes: profissionais adultos com poder aquisitivo que valorizam seguranca', 'pendente', 'mentor', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 5, 'Alinhar desafios-chave: 70% faturamento vai para hospital, dependencia de infraestrutura, sindrome do impostor', 'pendente', 'mentor', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 6, 'Revisar metas financeiras: R$200-250 mil/mes com mentoria, reduzir dependencia do hospital', 'pendente', 'mentor', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 7, 'Confirmar tese e diferencial central com a mentorada e obter aceite do plano', 'pendente', 'mentorado', 7, 'dossie_auto')
  RETURNING id INTO _acao_id;

  -- =============================================
  -- FASE 1: Validacao Estrategica do Produto e Posicionamento
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Validacao Estrategica do Produto e Posicionamento', 'fase', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 1, 'Organizar conteudo tecnico: mapear temas que domina (refracao, planejamento, leitura de exames)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 1, 'Listar todos os temas que ja domina e quer ensinar', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 2, 'Separar mentalmente: base teorica vs caso real vs cirurgia gravada', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 3, 'Organizar conhecimento sem gravar ainda - apenas estruturar', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 2, 'Assumir publicamente o papel de capacitadora, nao apenas de cirurgia', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 1, 'Responder colegas ja interessados e observar reacoes', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 2, 'Testar narrativa: ensino o que a residencia nao ensina', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 3, 'Testar narrativa: planejamento e decisao vem antes do laser', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 3, 'Revisar dossie estrategico: publico-alvo, oferta, arquitetura, estrategia do funil, lapidacao de perfil', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 4, 'Validar os 4 pilares do produto: planejamento refracional, exames pre-op, cirurgias gravadas, discussao de casos', 'pendente', 'mentor', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 5, 'Definir formato final da oferta: Capacitacao em Cirurgia Refrativa a Laser (6 meses, 10x R$1.200)', 'pendente', 'mentor', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  -- =============================================
  -- FASE 2: Abordagem e Primeiras Vendas
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Abordagem e Primeiras Vendas', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 1, 'Retomar contato com os interessados que ja mandaram mensagem', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 1, 'Retomar contato e sugerir data/horario para conversa', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 2, 'Conduzir para a call (nao explicar tudo por texto)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 3, 'Confirmar data e horario da call com mensagem de confirmacao', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 2, 'Se preparar e realizar a call de vendas (assistir aula de vendas antes)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 1, 'Assistir a aula de vendas na plataforma Academia Expert', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 2, 'Saber explicar com clareza: para quem e, o que aprende, como funciona', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 3, 'Seguir script da call: abertura, reaquecimento, jornada, alinhamento, investimento, fechamento', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 3, 'Abordar o restante da base de contatos com mensagem padrao', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 1, 'Listar contatos: colegas, ex-alunos, medicos que ja procuraram, interessados em refrativa', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 2, 'Enviar mensagem padrao unica para todos (nao personalizar demais)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 3, 'Conduzir interessados para call, encerrar com elegancia quem nao quer agora', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 4, 'Abordar grupos grandes de oftalmologistas (~200 medicos) com mensagem padrao', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 5, 'Consolidar primeiras vendas e validar a oferta no mercado', 'pendente', 'mentorado', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  -- =============================================
  -- FASE 3: Onboarding dos Alunos
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Onboarding dos Alunos', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 1, 'Enviar contrato da capacitacao para o aluno assinar', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 2, 'Confirmar pagamento ou sinal e validar a vaga', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 3, 'Liberar acesso a plataforma de conteudo', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 4, 'Incluir aluno no grupo oficial da capacitacao (WhatsApp)', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 5, 'Comunicar data, horario e tema da primeira aula ao vivo', 'pendente', 'mentorado', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 6, 'Enviar mensagem completa de onboarding (modelo padrao)', 'pendente', 'mentorado', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

  -- =============================================
  -- FASE 4: Producao de Aulas Gravadas (Conteudo Tecnico)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Producao de Aulas Gravadas (Conteudo Tecnico)', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 1, 'Gravar aulas do Pilar 1: Planejamento Refracional com Criterio Clinico', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 1, 'Refracao subjetiva, objetiva e cicloplegiada aplicada a cirurgia refrativa', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 2, 'Identificacao do grau real do paciente', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 3, 'Principais erros de planejamento e diferenca de decisao em jovens vs acima de 40 anos', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 4, 'Criterios para tirar mais grau, tirar menos grau e contraindicar a cirurgia', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 2, 'Gravar aulas do Pilar 2: Leitura e Interpretacao dos Exames Pre-operatorios', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 1, 'Quais exames pedir no pre-operatorio da cirurgia refrativa', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 2, 'Como interpretar exames com foco cirurgico e identificar riscos/contraindicacoes', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 3, 'Correlacao entre exames e planejamento refracional', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 3, 'Criar ferramentas de apoio: metodo de refracao, criterio de planejamento, protocolo de decisao clinica', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 4, 'Criar protocolo de exames pre-operatorios e criterio de leitura de exames', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 5, 'Subir todas as aulas gravadas na plataforma de conteudo', 'pendente', 'equipe_spalla', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  -- =============================================
  -- FASE 5: Gravacao das Cirurgias Refrativas
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Gravacao das Cirurgias Refrativas', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 1, 'Definir datas possiveis de gravacao e procedimentos previstos (FemtoLasik, PRK, Femtoanel)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 2, 'Escolher e validar videomaker com experiencia em ambiente cirurgico', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 1, 'Buscar indicacoes de colegas medicos ou videomakers que ja gravaram cirurgias', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 2, 'Pedir portfolio especifico (cirurgias gravadas, nao generico)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 3, 'Confirmar experiencia com campo esteril, iluminacao hospitalar e paramentacao', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 3, 'Selecionar cirurgias para gravacao: priorizar casos bem indicados, didaticos e com boa visualizacao', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 4, 'Obter termo de consentimento dos pacientes para uso educacional das imagens', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 5, 'Realizar alinhamento tecnico com videomaker: enquadramento, foco, audio, pontos criticos', 'pendente', 'mentorado', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 6, 'Gravar cirurgias reais com explicacao passo a passo do raciocinio clinico', 'pendente', 'mentorado', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 7, 'Editar e subir cirurgias gravadas na plataforma com comentarios didaticos', 'pendente', 'equipe_spalla', 7, 'dossie_auto')
  RETURNING id INTO _acao_id;

  -- =============================================
  -- FASE 6: Estruturacao dos Encontros ao Vivo e Discussao de Casos
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Estruturacao dos Encontros ao Vivo e Discussao de Casos', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 1, 'Definir calendario de encontros ao vivo (Pilar 4: Discussao de Casos e Tomada de Decisao)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 2, 'Estruturar formato das mentorias ao vivo: discussao de casos reais, correcao de raciocinio, ajustes finos', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 3, 'Organizar grupo de WhatsApp para suporte continuo e discussao de casos entre encontros', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 4, 'Criar metodo de tomada de decisao e discussao de casos como ferramenta de apoio', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 5, 'Realizar primeiro encontro ao vivo e coletar feedback dos alunos', 'pendente', 'mentorado', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  -- =============================================
  -- FASE 7: Construcao do Storytelling e Narrativa de Autoridade
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Construcao do Storytelling e Narrativa de Autoridade', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 1, 'Revisar e internalizar o storytelling base da marca pessoal (historia completa do dossie)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 2, 'Consolidar eixo narrativo: origem, consciencia, escolha, criterio, posicionamento atual', 'pendente', 'mentor', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 3, 'Adaptar storytelling para diferentes formatos: feed, reels, bio, pagina de vendas, anuncios', 'pendente', 'equipe_spalla', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 4, 'Criar post fixado sobre Harvard, autoridade e volume de cirurgias (+2.400)', 'pendente', 'equipe_spalla', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 5, 'Definir tese forte e frase norteadora para toda comunicacao', 'pendente', 'mentor', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  -- =============================================
  -- FASE 8: Lapidacao de Perfil no Instagram
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Lapidacao de Perfil no Instagram', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 1, 'Atualizar foto de perfil: jaleco ou blazer, fundo neutro, expressao de autoridade serena', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 2, 'Atualizar bio do Instagram: ancorar autoridade tecnica (PhD, Harvard, +2.400 cirurgias, mentora)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 1, 'Escolher entre as 4 versoes de bio sugeridas no dossie', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_acao_id, _fase_id, _plano_id, 50, 2, 'Atualizar nome exibido (ex: Dra. Miriam Alves | Cirurgia Refrativa)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 3, 'Manter perfil hibrido: paciente + aluno no mesmo perfil (nao separar)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 4, 'Organizar destaques do perfil: autoridade, mentoria, pacientes, bastidores', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 5, 'Solicitar segunda etapa da lapidacao de perfil e plano de conteudo a equipe Case', 'pendente', 'equipe_spalla', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  -- =============================================
  -- FASE 9: Posicionamento Digital e Conteudo Estrategico
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Posicionamento Digital e Conteudo Estrategico', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 1, 'Aprofundar comunicacao tecnica nos videos: sair do generico e mostrar profundidade clinica', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 2, 'Criar conteudos que mostrem trajetoria e autoridade (Harvard, volume, premios academicos)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 3, 'Comunicar explicitamente como mentora/capacitadora, nao apenas como medica', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 4, 'Diferenciar-se dos concorrentes pela etica, criterio e seguranca (nao por tecnica rapida)', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 5, 'Estruturar audiencia do Instagram para venda de educacao (nao apenas autoridade clinica)', 'pendente', 'equipe_spalla', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 6, 'Desenvolver plano de conteudo recorrente com equipe Case', 'pendente', 'equipe_spalla', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

  -- =============================================
  -- FASE 10: Estruturacao do Bonus Presencial (Observe-se)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Estruturacao do Bonus Presencial (Observe-se)', 'fase', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 1, 'Definir formato do Observe-se presencial: 1 dia completo acompanhando atendimentos e cirurgias', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 2, 'Organizar logistica: local (considerar Sao Paulo para evitar conflitos), agenda, recepcao', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 3, 'Garantir que o foco seja raciocinio clinico e tomada de decisao (nao hands-on)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 4, 'Definir janela de 6 meses para alunos agendarem a data presencial', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  -- =============================================
  -- FASE 11: Otimizacao do Funil de Vendas (passo executivo)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Otimizacao do Funil de Vendas', 'passo_executivo', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 1, 'Construir pagina de vendas baseada na oferta validada (copy do dossie)', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 2, 'Configurar funil de curto prazo: contato quente > call > fechamento', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 3, 'Implementar sistema de follow-up para leads que nao responderam (lembrete em 2-3 dias)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 4, 'Padronizar mensagens de abordagem e scripts de call para consistencia', 'pendente', 'equipe_spalla', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 5, 'Analisar metricas: taxa de resposta, taxa de agendamento, taxa de conversao na call', 'pendente', 'equipe_spalla', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 6, 'Iterar oferta e funil com base nos resultados das primeiras vendas', 'pendente', 'mentor', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

  -- =============================================
  -- FASE 12: Escala e Independencia Financeira (passo executivo)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Escala e Independencia Financeira', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 1, 'Avaliar resultados da primeira turma e coletar depoimentos para prova social', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 2, 'Planejar segunda turma com ajustes baseados no feedback dos primeiros alunos', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 3, 'Desenvolver estrategia de anuncios pagos para captar novos oftalmologistas', 'pendente', 'equipe_spalla', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 4, 'Criar modulo sobre posicionamento digital para medicos (diferencial no produto)', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 5, 'Projetar meta de R$200-250 mil/mes com mentoria e reduzir dependencia do hospital progressivamente', 'pendente', 'mentor', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 6, 'Avaliar viabilidade de Fellow virtual com possivel imersao presencial em SP', 'pendente', 'mentor', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

  -- =============================================
  -- FASE 13: Consolidacao e Autonomia (passo executivo)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 50, 'Consolidacao e Autonomia', 'passo_executivo', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 1, 'Consolidar posicionamento como referencia nacional em ensino de cirurgia refrativa', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 2, 'Equilibrar agenda: reduzir carga hospitalar conforme faturamento digital cresce', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 3, 'Aumentar margem liquida significativamente vs modelo atual (70% hospital)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 4, 'Conquistar qualidade de vida: mais tempo com os filhos (Lara, Livia, Joao Pedro)', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 5, 'Transformar conhecimento que dava de graca em produto rentavel e sustentavel', 'pendente', 'mentorado', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 50, 6, 'Revisar plano de acao completo e definir proximos passos para o segundo ciclo', 'pendente', 'mentor', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

END $$;
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN

-- ============================================================
-- PLANO DE ACAO
-- ============================================================
INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
VALUES (10, 'PLANO DE ACAO v2 | Luciana Saraiva', 'fases', 'nao_iniciado', 'dossie_auto_v3')
RETURNING id INTO _plano_id;

-- ============================================================
-- FASE 0: REVISAO DO DOSSIE
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 10, 'Revisao do Dossie com a Mentorada', 'revisao_dossie', 0, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

-- Acao 1
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 1, 'Agendar call de revisao do dossie com Luciana e equipe', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 2
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 2, 'Apresentar diagnostico completo do perfil: foto, nome, bio, destaques, posts fixados e feed', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 3
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 3, 'Apresentar estrategia de funil: landing page, formulario de aplicacao e link da bio', 'pendente', 'equipe_spalla', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 4
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 4, 'Apresentar proximos passos: Fases 1 a 5 do plano estrategico', 'pendente', 'equipe_spalla', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 5
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 5, 'Alinhar expectativas e validar prioridades com Luciana', 'pendente', 'mentor', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 6
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 6, 'Definir cronograma de execucao das fases com datas-alvo', 'pendente', 'equipe_spalla', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- ============================================================
-- FASE 1: LAPIDACAO DO PERFIL — Foto, Nome e Bio
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 10, 'Lapidacao do Perfil — Foto, Nome e Bio', 'fase', 1, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

-- Acao 1
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 1, 'Produzir nova foto de perfil profissional (rosto frontal ou 3/4, fundo limpo, luz suave, expressao serena e segura)', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 1, 'Agendar sessao fotografica em estudio ou clinica com luz natural', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 2, 'Usar roupa minimalista (preto, branco ou cinza) e rosto preenchendo 70% do frame', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 3, 'Selecionar e aplicar a melhor foto no perfil @alucianasaraiva', 'pendente', 'mentorado', 3, 'dossie_auto');

-- Acao 2
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 2, 'Alterar o nome do perfil para formato estrategico (ex: Dra. Luciana Saraiva - Mentora ou Odonto Premium)', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 3
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 3, 'Reescrever a bio com estrutura de mini-funil: autoridade + nicho + prova social + CTA', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 1, 'Incluir +25 anos na odontologia, clinica premium 500k/mes e Metodo Elleve', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 2, 'Definir publico-alvo claro: dentistas que querem vender procedimentos de alto ticket', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 3, 'Adicionar CTA direto para Workshop Elleve ou aplicacao de mentoria', 'pendente', 'mentorado', 3, 'dossie_auto');

-- Acao 4
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 4, 'Substituir link da bio: trocar grupo WhatsApp por Linktree com botoes estrategicos', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 1, 'Criar botao "Quero garantir minha vaga no Workshop Elleve" apontando para landing page', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 2, 'Criar botao "Aplicar para Mentoria Premium (somos seletivos)" apontando para formulario', 'pendente', 'mentorado', 2, 'dossie_auto');

-- Acao 5
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 5, 'Criar landing page do Workshop Elleve com formulario de captura (nome, email, telefone, cidade)', 'pendente', 'equipe_spalla', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 6
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 6, 'Instalar Pixel do Meta Ads na landing page para rastreamento e remarketing', 'pendente', 'equipe_spalla', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- ============================================================
-- FASE 2: DESTAQUES ESTRATEGICOS (Funil nos Stories)
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 10, 'Destaques Estrategicos — Funil nos Stories', 'fase', 2, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

-- Acao 1
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 1, 'Criar destaque MINHA HISTORIA — conexao emocional e trajetoria de autoridade', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 1, 'Gravar sequencia de stories: sofa emprestado ate clinica 1500m2 faturando 500k/mes', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 2, 'Incluir virada de chave: gestora e empreendedora, nao apenas tecnica', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 3, 'Incluir ponte para o publico: missao de ajudar dentistas a viverem esse salto', 'pendente', 'mentorado', 3, 'dossie_auto');

-- Acao 2
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 2, 'Criar destaque A CLINICA — prova social e autoridade visual', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 3
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 3, 'Criar destaque METODO ELLEVE — educacao + diferencial + posicionamento (5 pilares)', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 4
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 4, 'Criar destaque MENTORIA — oferta premium com formato, diferenciais e filtros de selecao', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 5
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 5, 'Criar destaque WORKSHOP — captacao de leads para evento de topo de funil', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 6
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 6, 'Criar destaque CASES — prova social com antes/depois de mentorados e prints reais', 'pendente', 'mentorado', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 7
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 7, 'Criar destaque BASTIDORES — humanizacao profissional (clinica, gravacoes, eventos, alunos)', 'pendente', 'mentorado', 7, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 8
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 8, 'Criar destaque PERGUNTAS — quebra de objecoes frequentes dos dentistas', 'pendente', 'mentorado', 8, 'dossie_auto')
RETURNING id INTO _acao_id;

-- ============================================================
-- FASE 3: POSTS FIXADOS — Vitrine Oficial
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 10, 'Posts Fixados — Vitrine Oficial do Perfil', 'fase', 3, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

-- Acao 1
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 1, 'Criar e fixar Post 1 — MINHA HISTORIA (storytelling emocional + ponte para mentoria)', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 1, 'Abertura forte com dor da persona e contraste (sofa emprestado vs clinica 1500m2)', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 2, 'Incluir filtro de publico: "Se voce e dentista e trabalha demais..."', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 3, 'Conectar com o Metodo Elleve e incluir CTA suave para acompanhar', 'pendente', 'mentorado', 3, 'dossie_auto');

-- Acao 2
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 2, 'Criar e fixar Post 2 — O QUE EU FACO / METODO ELLEVE (5 pilares + para quem e)', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 1, 'Explicar os 5 pilares: Protocolos Premium, Jornada do Paciente, Posicionamento, Vendas, Gestao', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 2, 'Definir publico: dentistas que ja atendem mas nao escalam, cansados de volume', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 3, 'CTA direto: link na bio para workshop e mentorias', 'pendente', 'mentorado', 3, 'dossie_auto');

-- Acao 3
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 3, 'Criar e fixar Post 3 — PROVA SOCIAL / RESULTADOS / CASES', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 1, 'Reunir provas: faturamento 500k/mes, clinica 1500m2, vendas high ticket 80-150k', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 2, 'Incluir cases de mentorados: aumento de ticket 2x-5x, prints e depoimentos', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 3, 'CTA forte: "Quer ser meu proximo case? Link da bio"', 'pendente', 'mentorado', 3, 'dossie_auto');

-- Acao 4
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 4, 'Melhorar Reels fixado atual: adicionar filtro de publico, conexao com Metodo Elleve e CTA claro', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 5
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 5, 'Ajustar legenda do Reels fixado para conversao (nao generica)', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- ============================================================
-- FASE 4: REPOSICIONAMENTO DO FEED — De Influenciadora a Mentora
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 10, 'Reposicionamento do Feed — De Influenciadora a Mentora', 'fase', 4, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

-- Acao 1
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 1, 'Definir nova proporcao de conteudo: 40% tecnico, 30% storytelling, 20% bastidores, 10% lifestyle', 'pendente', 'mentor', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 2
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 2, 'Criar series recorrentes para fixar autoridade: Aula Rapida, Erro que te Trava, Como eu Faria, Segredos do Consultorio Premium', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 3
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 3, 'Aumentar volume de carrosseis educativos com licao pratica (ex: "Como faturar 500mil/mes", "Por que voce ainda baixa o preco")', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 4
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 4, 'Produzir mais conteudo de prova social: antes/depois de mentorados, prints de faturamento, videos de alunos', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 5
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 5, 'Tornar Reels mais diretos: gancho forte nos 3 primeiros segundos, insight imediato, ritmo rapido', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 6
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 6, 'Mover posts que enfraquecem o perfil (objetos, viagens sem contexto, fotos antigas) para o meio do feed', 'pendente', 'mentorado', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 7
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 7, 'Construir narrativa fixa no feed: historia de consultorio pequeno a 500k, Metodo Elleve, transformacao de mentorados', 'pendente', 'mentorado', 7, 'dossie_auto')
RETURNING id INTO _acao_id;

-- ============================================================
-- FASE 5: ESTRATEGIA DE CONTEUDO — Calendario Editorial
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 10, 'Estrategia de Conteudo — Calendario Editorial Semanal', 'fase', 5, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

-- Acao 1
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 1, 'Implementar calendario editorial: Domingo/Quinta=Desejo e Oportunidade, Segunda/Sexta=Confianca no Expert, Terca=Alcance, Quarta=Infovendas, Sabado=Identificacao', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 2
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 2, 'Produzir conteudo Pilar Autoridade Tecnica: erros que impedem faturar alto, experiencia vs estrutura, vender sem desconto', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 3
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 3, 'Produzir conteudo Pilar Storytelling Estrategico: construi clinica 1500m2 do zero, pacientes internacionais, mentalidade de alto valor', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 4
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 4, 'Produzir conteudo Pilar Prova Social: mini cases reais, depoimentos em video, antes/depois de faturamento', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 5
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 5, 'Produzir conteudo Pilar Oferta: Reels sobre Metodo Elleve, explicacao da mentoria, comparacao curso vs mentoria vs metodo', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 6
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 6, 'Garantir que todo conteudo tenha CTA direcionando para pagina de vendas (nao grupo WhatsApp)', 'pendente', 'mentorado', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- ============================================================
-- FASE 6: IDEIAS DE ANUNCIOS — Criativos para Meta Ads
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 10, 'Ideias de Anuncios — Criativos para Meta Ads', 'fase', 6, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

-- Acao 1
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 1, 'Gravar Anuncio 01 — "Eles so veem a clinica de 1500m2" (storytelling de origem humilde + mentoria)', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 2
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 2, 'Gravar Anuncio 02 — "Nao e a estrutura. E a tecnica." (tecnica de venda > lustre da clinica)', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 3
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 3, 'Gravar Anuncio 03 — "O dia que mostrei meu faturamento" (prova social, destravar mentalidade)', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 4
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 4, 'Gravar Anuncio 04 — "Agenda cheia, bolso vazio" (dor direta, precificacao + plano de tratamento)', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 5
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 5, 'Gravar Anuncio 05 — "O investimento que mudou como eu vendo" (mentoria de 80k como ponto de virada)', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 6
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 6, 'Gravar Anuncio 06 — "Do consultorio comum ao ultra high ticket" (posicionamento + protocolos + venda etica)', 'pendente', 'mentorado', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 7
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 7, 'Gravar Anuncios 07 e 08 — "Antes de passar orcamento caro, verifique isso" e "Dentista que ganha mais que medico"', 'pendente', 'mentorado', 7, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 8
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 8, 'Distribuir conteudos organicamente antes e depois transformar os melhores em anuncios pagos', 'pendente', 'equipe_spalla', 8, 'dossie_auto')
RETURNING id INTO _acao_id;

-- ============================================================
-- FASE 7: AJUSTAR ENTREGA DA MENTORIA — Estrutura e Planos
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 10, 'Ajustar Entrega da Mentoria — Planos de Acao por Pilar', 'fase', 7, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

-- Acao 1
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 1, 'Desenhar Plano 1 — Oferta e Precificacao (checklist padrao para todos mentorados)', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 2
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 2, 'Desenhar Plano 2 — Produtos e Protocolos premium', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 3
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 3, 'Desenhar Plano 3 — Jornada e Fluxo do Paciente', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 4
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 4, 'Desenhar Plano 4 — Venda na Consulta (postura, script, argumentos)', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 5
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 5, 'Ajustar onboarding: diagnostico rapido + definir ordem dos planos + entregar PA na primeira call', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 6
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 6, 'Atualizar formato da mentoria: duracao 6 meses, 1 encontro individual no inicio e 1 no final, encontro semanal fixo', 'pendente', 'mentorado', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 7
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 7, 'Reorganizar encontros semanais: Semana A=Treinamento de Vendas, Semana B=Sessao de Conselho/Tira-duvidas', 'pendente', 'mentorado', 7, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 8
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 8, 'Migrar atendimentos individuais para sessoes de conselho em grupo (inteligencia coletiva + escala)', 'pendente', 'mentorado', 8, 'dossie_auto')
RETURNING id INTO _acao_id;

-- ============================================================
-- FASE 8: ESTRUTURAR FUNIL DA MENTORIA
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 10, 'Estruturar Funil da Mentoria — Captacao e Qualificacao', 'fase', 8, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

-- Acao 1
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 1, 'Criar formulario de aplicacao para mentoria (dados basicos, faturamento, especialidade, principais dores)', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 2
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 2, 'Linkar formulario na bio via Linktree: botao Mentoria separado de botao Imersao/Workshop', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 3
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 3, 'Definir fluxo de abordagem: anuncio/conteudo > aplicacao > planilha/CRM > ligacao de qualificacao > call de venda', 'pendente', 'equipe_spalla', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 4
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 4, 'Criar script de mensagem inicial DM/WhatsApp para abordagem de leads qualificados', 'pendente', 'equipe_spalla', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 5
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 5, 'Criar roteiro de ligacao de qualificacao (5 min): abertura, mapping de dores, isca/carteirada, dor profunda, meta, convite para call', 'pendente', 'equipe_spalla', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 1, 'Incluir perguntas de qualificacao: oferta atual, precificacao, quem faz a venda, taxa de conversao, paciente ideal, jornada', 'pendente', 'equipe_spalla', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 10, 2, 'Usar iscas reais da Luciana: pacientes internacionais, fechamento de 20-100k, reorganizacao de agenda', 'pendente', 'equipe_spalla', 2, 'dossie_auto');

-- Acao 6
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 6, 'Criar roteiro da call de venda: abertura com exclusividade, reaquecimento, oferta sem detalhes tecnicos, checagem, preco ancorado, fechamento', 'pendente', 'mentor', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- ============================================================
-- FASE 9: CONTEUDO E POSICIONAMENTO — Producao Estrategica
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 10, 'Conteudo, Anuncios e Posicionamento — Producao Estrategica', 'fase', 9, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

-- Acao 1
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 1, 'Ajustar bio e links no perfil @alucianasaraiva como mentora de venda/precificacao para saude', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 2
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 2, 'Criar conteudos com foco em Desejo + Autoridade: historia de faturamento, pacientes internacionais, bastidores reais', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 3
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 3, 'Criar conteudos Contraintuitivos: profissional PRECISA vender, nao delegar venda high ticket, voce nao e desvalorizado - voce se desvaloriza', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 4
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 4, 'Distribuir conteudo organicamente com trafego leve antes de transformar em anuncios', 'pendente', 'equipe_spalla', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 5
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 5, 'Transformar os melhores conteudos organicos em anuncios com CTA para aplicacao da mentoria', 'pendente', 'equipe_spalla', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 6
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 6, 'Gravar trilhas de apoio para Plano 1 (Oferta e Precificacao): aula de precificacao, planilha, logica de lucro e preco', 'pendente', 'mentorado', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- ============================================================
-- FASE 10: TIME E OPERACAO
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 10, 'Time e Operacao — Organizacao da Equipe', 'fase', 10, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

-- Acao 1
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 1, 'Reposicionar Renata: foco em suporte aos mentorados + execucao e organizacao da mentoria/projeto', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 2
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 2, 'Buscar profissional (fixo ou frila) para gravar bastidores no consultorio e criar conteudos organicos', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 3
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 3, 'Luciana domina as calls de venda primeiro, seguindo o script do funil', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 4
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 4, 'Apos dominar e ter padrao de taxa de fechamento, treinar closer para assumir parte das calls', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 5
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 5, 'Implementar rotina de metas e vendas com mentorados nas calls semanais (meta, abordagens, fechamento)', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 6
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 6, 'Puxar mentorados para venda ativa e indicacao no momento em que o paciente esta feliz', 'pendente', 'mentorado', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- ============================================================
-- FASE 11: PROXIMA IMERSAO — Workshop Elleve Experience
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 10, 'Proxima Imersao — Planejamento do Workshop Elleve Experience', 'fase', 11, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

-- Acao 1
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 1, 'Definir data da proxima imersao (idealmente apos Carnaval)', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 2
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 2, 'Garantir pre-requisitos antes do evento: planos da mentoria desenhados, entrega ajustada, funil de aplicacao rodando', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 3
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 3, 'Criar pagina de vendas do Workshop Elleve com formulario de captura e storytelling de autoridade', 'pendente', 'equipe_spalla', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 4
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 4, 'Encher o evento com base atual + anuncios + audiencia aquecida pelo novo posicionamento', 'pendente', 'equipe_spalla', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 5
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 5, 'Criar sequencia de aquecimento pre-evento nos stories e feed (contagem regressiva, bastidores, depoimentos)', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- ============================================================
-- FASE 12 (passo_executivo): EXECUCAO IMEDIATA — Perfil
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 10, 'Execucao Imediata — Ajustes Rapidos no Perfil', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

-- Acao 1
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 1, 'Trocar foto de perfil para nova foto profissional (frontal, luz suave, 70% do frame)', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 2
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 2, 'Atualizar nome do perfil para "Dra. Luciana Saraiva - Mentora" ou variacao escolhida', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 3
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 3, 'Aplicar nova bio otimizada no Instagram', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 4
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 4, 'Substituir link do WhatsApp por Linktree com botoes de Workshop e Mentoria', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 5
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 5, 'Fixar os 3 posts estrategicos (Historia, Metodo, Provas) no topo do feed', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 6
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 6, 'Criar capas premium para os 8 destaques (fundo branco/bege/champagne, estetica sofisticada)', 'pendente', 'mentorado', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- ============================================================
-- FASE 13 (passo_executivo): EXECUCAO — Funil e Gravacoes
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 10, 'Execucao — Funil, Gravacoes e Lancamento', 'passo_executivo', 13, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

-- Acao 1
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 1, 'Publicar landing page do Workshop Elleve com pixel instalado', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 2
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 2, 'Publicar formulario de aplicacao para mentoria e integrar com planilha/CRM', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 3
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 3, 'Gravar e publicar sequencia do destaque MINHA HISTORIA (15 stories)', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 4
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 4, 'Gravar primeiros 2 anuncios e publicar organicamente para teste de engajamento', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 5
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 5, 'Gravar trilha de apoio do Plano 1 (aula de precificacao + planilha + logica de lucro)', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 6
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 6, 'Realizar primeira call de venda usando o script do funil e registrar aprendizados', 'pendente', 'mentorado', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- Acao 7
INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 10, 7, 'Ativar primeiros anuncios pagos no Meta Ads direcionando para landing page e formulario', 'pendente', 'equipe_spalla', 7, 'dossie_auto')
RETURNING id INTO _acao_id;

END $$;
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN

-- =============================================
-- PLANO DE ACAO - Maria Spindola (mentorado_id=39)
-- =============================================
INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
VALUES (39, 'PLANO DE ACAO v2 | Maria Spindola', 'fases', 'nao_iniciado', 'dossie_auto_v3')
RETURNING id INTO _plano_id;

-- =============================================
-- FASE 0: REVISAO DO DOSSIE
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 39, 'Revisao do Dossie com a Mentorada', 'revisao_dossie', 0, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 1, 'Revisar contexto da expert: 14 anos em multinacionais, veterinaria de formacao, transicao Brasil-EUA', 'pendente', 'mentor', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 2, 'Validar publico-alvo definido: mulheres gerentes/coordenadoras em multinacionais (Brasil e EUA)', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 3, 'Confirmar posicionamento: mentora que ensina executivas a navegar codigos nao-escritos de multinacionais', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 4, 'Revisar Metodo ACE (Alignment, Credibility, Execution) + Inteligencia Cultural - confirmar pilares', 'pendente', 'mentor', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 5, 'Alinhar desafios pessoais: baixa afinidade digital, bloqueio de mentalidade (termostato financeiro), preconceito de mercado', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 6, 'Definir prioridades e ordem de execucao das proximas fases do plano de acao', 'pendente', 'mentor', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- =============================================
-- FASE 1: CLAREZA DA OFERTA PRINCIPAL
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 39, 'Clareza e Estruturacao da Oferta Principal', 'fase', 1, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 1, 'Escrever descricao da mentoria em 1 pagina: Ponto A (plato, frustracao) vs Ponto B (plano claro, promocao)', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 1, 'Descrever a dor principal da cliente: estagnacao, aquario dourado, falta de reconhecimento', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 2, 'Descrever a transformacao: plano de carreira estrategico, leitura de codigos culturais, promocao encaminhada', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 3, 'Listar os 4 pilares em bullet points: Clareza, Valor, Estrategia, Inteligencia Cultural e Social', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 2, 'Oficializar nome do metodo: ACE powered by Cultural Intelligence', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 3, 'Definir formato final: Mentoria Individual 6 meses, 12 encontros quinzenais + suporte WhatsApp', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 4, 'Definir precificacao unica: 12x R$1.500 ou R$14.000 a vista (nao criar duas ofertas Standard/Premium)', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 5, 'Estruturar ancoragem de valor: listar entregaveis separados (diagnostico R$2k, sessoes R$12k, suporte R$4k, etc) totalizando R$52.500+', 'pendente', 'mentor', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 6, 'Incluir bonus exclusivos como IAs: Compass AI (conselheiro 24h) e Maria Advisor (agente estrategico)', 'pendente', 'equipe_spalla', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- =============================================
-- FASE 2: DEFINICAO DO PUBLICO IDEAL
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 39, 'Definicao e Aprofundamento do Publico Ideal', 'fase', 2, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 1, 'Escolher o coracao da persona: mulher em gerencia/coordenacao senior em multinacional, renda media-alta', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 2, 'Escrever em topicos: o que essa mulher sente no dia a dia (plato, frustracao, comparacao injusta)', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 1, 'Listar as 5 principais dores: estagnacao, frustracao/nao reconhecimento, comparacao injusta, investimento desperdicado, inseguranca cultural', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 2, 'Listar os 4 principais desejos: promocao (gerente para diretora), reconhecimento estrategico, clareza de plano, dominio do jogo corporativo', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 3, 'Mapear os principais erros que o publico comete hoje (investir em cursos tecnicos, trabalhar mais em vez de melhor)', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 4, 'Listar as duvidas concretas que chegam para a Maria nos cafes e conversas', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 5, 'Mapear objecoes mais comuns e preparar respostas: nao preciso de ajuda, MBA nao funcionou, investimento alto, sem tempo, falta de senioridade', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- =============================================
-- FASE 3: POSICIONAMENTO DIGITAL E PERFIL
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 39, 'Posicionamento Digital e Lapidacao do Perfil Instagram', 'fase', 3, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 1, 'Ajustar foto de perfil: recortar para rosto ocupar 60-70% da imagem, ajustar brilho/contraste', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 2, 'Atualizar bio do Instagram com novo posicionamento nichado', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 1, 'Nome: Maria Spindola | Estrategista de carreira', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 2, 'Linha 1: Global Director | 15 anos em multinacionais | +27 nacionalidades', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 3, 'Linha 2: Metodo ACE + Cultural Intelligence', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 4, 'CTA: Aplique para a mentoria (link formulario)', 'pendente', 'mentorado', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 3, 'Reorganizar destaques na ordem: Quem Sou, Mentoria, Resultados, Conteudo, Perguntas', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 4, 'Criar post fixado #1 APRESENTACAO: historia Brasil -> EUA com storytelling forte', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 5, 'Criar post fixado #2 CONTEUDO DE VALOR: 5 movimentos para sair do plato e acelerar promocao', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 6, 'Criar post fixado #3 RESULTADOS: case de mentorada com antes/depois real', 'pendente', 'mentorado', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 7, 'Atualizar capas dos destaques: fundo neutro corporativo (bege, cinza, off-white) com icones minimalistas', 'pendente', 'mentorado', 7, 'dossie_auto')
RETURNING id INTO _acao_id;

-- =============================================
-- FASE 4: STORYTELLING E BANCO DE HISTORIAS
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 39, 'Storytelling e Construcao do Banco de Historias', 'fase', 4, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 1, 'Escrever Historia 1 - Quase Perfeita: frase do marido como gatilho da tese Imperfeitas e Imparaveis', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 2, 'Escrever Historia 2 - Plato e Resposta do RH: voce precisa fazer 30 anos (tese: nao e tecnica, e estrategia)', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 3, 'Escrever Historia 3 - Visualizacao + Mudanca EUA: tecnica de escrita que atraiu vaga exata pelo Instagram', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 4, 'Escrever Historia 4 - Divorcio, filha pequena, doutorado: forca, resiliencia e independencia financeira', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 5, 'Organizar todas as historias em formato de bullets (texto corrido) para banco reutilizavel em reels, carrosseis, palestras', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 6, 'Revisar storytelling principal da pagina de vendas: jornada veterinaria -> corporativo -> EUA -> mentora', 'pendente', 'mentor', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- =============================================
-- FASE 5: ARQUITETURA DO PRODUTO (METODO ACE)
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 39, 'Arquitetura do Produto e Estruturacao do Metodo ACE', 'fase', 5, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 1, 'Estruturar Pilar 1 ALIGNMENT: autodescoberta profissional, dia perfeito, compatibilidade carreira vs vida pessoal', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 1, 'Criar Template Dia Perfeito (planilha de mapeamento)', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 2, 'Criar Checklist de Valores Pessoais vs Corporativos', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 3, 'Criar Script da Tecnica de Visualizacao e Escrita', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 2, 'Estruturar Pilar 2 CREDIBILITY: Matriz de Valor Raro, Leitura de Stakeholders, Gestao de Percepcao', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 1, 'Criar Matriz Valor x Raridade (template)', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 2, 'Criar Template Perfil de Stakeholder', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 3, 'Criar Script de Autoapresentacao (como falar de si sem soar arrogante)', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 3, 'Estruturar Pilar 3 EXECUTION: Mapa do Poder, criterios nao-oficiais de promocao, Plano de Visibilidade', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 1, 'Criar Template Mapa do Poder (organograma real vs oficial)', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 2, 'Criar Roteiro para Reuniao 1:1 Estrategica', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 3, 'Criar Checklist de Networking Interno', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 4, 'Estruturar Pilar 4 CODIGOS INVISIVEIS: Inteligencia Cultural e Social para ambientes globais', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 1, 'Criar Guia de Inteligencia Cultural (manual com codigos dos principais paises)', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 2, 'Criar Quiz Teste sua Inteligencia Cultural', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 3, 'Criar Checklist O que NAO fazer com Americanos, Asiaticos, Europeus', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 5, 'Compilar apostila completa do metodo para entrega as mentoradas (versao impressa e digital)', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 6, 'Definir jornada pratica da mentorada: diagnostico -> plano inicial -> 12 encontros quinzenais -> suporte entre sessoes', 'pendente', 'mentorado', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- =============================================
-- FASE 6: ESTRATEGIA DE CONTEUDO
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 39, 'Estrategia de Conteudo e Calendario Editorial', 'fase', 6, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 1, 'Implementar calendario editorial semanal com 5 linhas: Desejo, Confianca, Alcance, Infovendas, Desejo, Confianca, Identificacao', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 2, 'Criar pasta de ideias de conteudo em 2 linhas editoriais: aceleracao de carreira e inteligencia cultural', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 3, 'Produzir conteudo de Alcance/Descoberta: Por que voce nunca e promovida, 3 erros em multinacionais, comentario do marido', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 4, 'Produzir conteudo de Infovendas: Voce esta no plato (7 sinais), metodo CVE trabalhar duro vs crescer rapido', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 5, 'Produzir conteudo de Autoridade/Prova: Aos 24 era gerente e mae solo, Fui barrada pelo chefe 60 dias depois estava nos EUA', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 6, 'Produzir conteudo de Quebra de Objecoes: carreira internacional morando no Brasil, networking vs puxa-saco, investir em carreira', 'pendente', 'mentorado', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 7, 'Separar 2-3 temas das aulas/comunidade para transformar em reels curtinhos (tema + ponto central)', 'pendente', 'mentorado', 7, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 8, 'Publicar conteudo de 5 a 7x por semana no Instagram, sempre reforcando tese: excelencia tecnica nao basta', 'pendente', 'mentorado', 8, 'dossie_auto')
RETURNING id INTO _acao_id;

-- =============================================
-- FASE 7: FUNIL DE CAPTACAO E QUALIFICACAO
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 39, 'Funil de Captacao: Formulario de Aplicacao e Prospeccao', 'fase', 7, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 1, 'Criar formulario de aplicacao (Typeform/Google Forms) com perguntas de qualificacao', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 1, 'Incluir perguntas: dados pessoais, cargo atual, renda, momento emocional, dor principal', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 2, 'Incluir perguntas: meta de carreira, disponibilidade emocional para mudanca', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 3, 'Colocar link na bio do Instagram e nos stories 2x/semana', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 2, 'Montar lista de prospeccao ativa: ex-colegas, mulheres que interagem no Instagram, seguidoras com perfil executivo', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 3, 'Criar 3 variacoes de script de abordagem: Direta (curiosidade), Antecipacao (angulacao forte), Calorosa (intimidade profissional)', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 4, 'Testar scripts com 5 pessoas antes de disparar para toda a base', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 5, 'Ajustar abordagem com base nas respostas: nenhuma resposta = abordagem fraca, poucas = falta de escassez', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 6, 'Disparar para o resto da lista apos ajustes validados', 'pendente', 'mentorado', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- =============================================
-- FASE 8: PROCESSO DE VENDAS (CALLS)
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 39, 'Processo de Vendas: Ligacao de Qualificacao e Call de Diagnostico', 'fase', 8, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 1, 'Estruturar ligacao de qualificacao de 5 minutos: abertura, quebra-gelo, 3-5 perguntas, recapitulacao, convite para call completa', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 1, 'Perguntas-chave: status atual, sensacao de plato, reconhecimento/promocao, ambiente politico/cultural', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 2, 'Perguntas-chave: dor principal em uma frase, meta de curto prazo (6-12 meses)', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 2, 'Estruturar call de diagnostico e venda (30-45 min): boas-vindas, explorar dores, metas, recapitular, apresentar tese', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 1, 'Etapa 1-3: Boas-vindas (3-5 min), Explorar dores (10-15 min), Explorar metas (5-10 min)', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 2, 'Etapa 4-6: Recapitular (3-5 min), Apresentar tese da mentoria (5-7 min), Explicar metodo ACE (7-10 min)', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 3, 'Etapa 7-11: Jornada pratica, Ancorar valor (R$50k+), Investimento, Checar e fechar, Pos-fechamento', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 3, 'Preparar respostas para objecoes de dinheiro, tempo, medo: conectar com dor e tese (trabalhar mais nao te tirou do plato)', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 4, 'Definir estrategia de downsell: Sessao Estrategica de 2h por R$2.000 para quem tem perfil mas nao tem condicoes agora', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 5, 'Regra: nunca oferecer desconto de cara. Sequencia: plano -> valor -> preco -> so apos objecao legitima -> condicoes especiais', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- =============================================
-- FASE 9: MENTALIDADE E TERMOSTATO FINANCEIRO
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 39, 'Mentalidade, Termostato Financeiro e Desbloqueio', 'fase', 9, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 1, 'Retomar exercicio de visualizacao focado na mentoria: escrever diariamente frases de gratidao pelas mentoradas', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 1, 'Definir um numero: 5, 10, 20 mentoradas - e repetir esse numero nas visualizacoes', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_acao_id, _fase_id, _plano_id, 39, 2, 'Escrever: Hoje estou muito feliz e agradecida pelas minhas X mentoradas em aceleracao de carreira', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 2, 'Atualizar mapa dos sonhos: incluir viagens, reconhecimento, liberdade de agenda, espaco de trabalho ideal, impacto nas alunas', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 3, 'Trocar discurso interno: de ja tenho vida boa, pra que mais? para ja tenho vida boa E por isso posso ir para o proximo nivel', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 4, 'Trabalhar bloqueio de cobranca: separar valor do salario corporativo do valor da mentoria (sao mercados diferentes)', 'pendente', 'mentor', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 5, 'Criar referencias de desejo: acompanhar mentoras de alto ticket como Kate McFee para expandir termostato', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- =============================================
-- FASE 10: VALIDACAO COM EVENTO (PALESTRA JAN/26)
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 39, 'Validacao: Palestra para 20 Mulheres e Primeiros Cases', 'fase', 10, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 1, 'Preparar palestra sobre carreira para grupo de 20 mulheres brasileiras nos EUA (Jan/2026)', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 2, 'Usar palestra como evento de validacao do metodo ACE e geracao de desejo', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 3, 'Incluir pitch leve ao final da palestra para conversao em lote (5-10 mentoradas)', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 4, 'Coletar depoimentos e cases das 6 mentoradas gratuitas para usar como prova social', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 5, 'Documentar resultados das 2 clientes pagantes da comunidade Imperfeitas e Imparaveis', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- =============================================
-- FASE 11: INFRAESTRUTURA E OPERACAO
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 39, 'Infraestrutura Operacional e Plataforma', 'passo_executivo', 11, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 1, 'Manter Kajabi como plataforma principal: aulas gravadas, materiais, trilhas por pilar, estrutura por modulos', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 2, 'Contratar Zoom pago para gravacoes de alta qualidade, sem limite de 40 min, com transcricao', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 3, 'Ter numero de WhatsApp exclusivo para mentoradas (separar do pessoal)', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 4, 'Montar operacao simples para primeira turma: planilha + WhatsApp + Kajabi (CRM fica para segunda turma)', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 5, 'Preparar box de boas-vindas elegante e minimalista: caneca Imperfeitas e Imparaveis, caneta personalizada, cartao da Maria', 'pendente', 'mentorado', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 6, 'Estruturar acesso das alunas: plataforma Kajabi, replays, materiais de apoio, tarefas/exercicios, apostila compilada', 'pendente', 'mentorado', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

-- =============================================
-- FASE 12: INPUTS PARA EQUIPE E PROXIMOS PASSOS
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 39, 'Inputs para Equipe Spalla e Proximos Passos Imediatos', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 1, 'Enviar prints/descricao da comunidade Imperfeitas e Imparaveis para equipe (aulas, formato, custo, participantes)', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 2, 'Enviar resumo da experiencia anterior de mentoria: o que funcionou (reuniao presencial) e o que nao funcionou (hot seat so no final)', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 3, 'Enviar agenda de palestras/workshops previstos (grupo de 20 mulheres em janeiro) como ativo de captacao', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 4, 'Alinhar com equipe Spalla o suporte para construcao de pagina de vendas no Kajabi', 'pendente', 'equipe_spalla', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 5, 'Definir meta inicial: fechar 3-5 mentoradas individuais pagas nos proximos 60 dias', 'pendente', 'mentor', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

-- =============================================
-- FASE 13: ESCALA FUTURA (OFERTA GRUPO)
-- =============================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 39, 'Preparacao para Escala: Oferta Grupo e Automacoes', 'passo_executivo', 13, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 1, 'Planejar oferta grupo para quando houver demanda represada (nao como atalho antes de vender individual)', 'pendente', 'mentor', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 2, 'Estrutura futura do grupo: 6 meses, call quinzenal Q&A/hot seat, 1 oficina extra/mes, trilhas gravadas', 'pendente', 'mentor', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 3, 'Precificacao grupo: ancoragem R$9.000, preco parcelado R$8.000 (4x R$2.000), a vista R$6.000', 'pendente', 'mentor', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 4, 'Gravar trilhas de aulas a partir das calls individuais para alimentar produto grupo', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 5, 'Implementar CRM e automacoes somente a partir da segunda turma (foco agora e validar e entregar)', 'pendente', 'equipe_spalla', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 39, 6, 'Construir audiencia focada em expats brasileiras para publico secundario futuro (transicao internacional)', 'pendente', 'mentorado', 6, 'dossie_auto')
RETURNING id INTO _acao_id;

END $$;
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN

-- ============================================================
-- PLANO DE ACAO
-- ============================================================
INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
VALUES (139, 'PLANO DE ACAO v2 | Michelle Novelli', 'fases', 'nao_iniciado', 'dossie_auto_v3')
RETURNING id INTO _plano_id;

-- ============================================================
-- FASE 0: REVISAO DO DOSSIE ESTRATEGICO
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 139, 'Revisao do Dossie Estrategico com Michelle', 'revisao_dossie', 0, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 1, 'Revisar storytelling base e marcos da narrativa com Michelle', 'pendente', 'mentor', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 139, 1, 'Validar os 7 marcos do storytelling (Radiologista, Oportunidade, Virada, Preconceito Superado, Explosao, Constatacao, Vocacao)', 'pendente', 'mentor', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 2, 'Confirmar frases-chave para comunicacao (Eu ja sei resolver o pior, Eu enxergo atraves da pele, etc)', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 3, 'Validar crenca-mae: Estetica seria e ciencia + mao + responsabilidade', 'pendente', 'mentor', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 2, 'Revisar publico-alvo definido no dossie e ajustar se necessario', 'pendente', 'mentor', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 139, 1, 'Confirmar foco em medicos estetas que dominam facial mas nao oferecem celulite', 'pendente', 'mentor', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 2, 'Validar decisao de produto de entrada ser celulite (sem PMMA) conforme call estrategica', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 3, 'Revisar tese do produto e conteudo programatico (3 pilares)', 'pendente', 'mentor', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 4, 'Revisar concorrentes mapeados e lacunas de mercado identificadas', 'pendente', 'mentor', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 5, 'Revisar secoes pendentes do dossie: Conteudo Programatico, Oferta e Arquitetura, Copy da Jornada', 'pendente', 'mentor', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 6, 'Alinhar expectativas de desvinculacao gradual da Gold Incision', 'pendente', 'mentor', 6, 'dossie_auto');

-- ============================================================
-- FASE 1: POSICIONAMENTO E MARCA PROPRIA
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 139, 'Posicionamento e Construcao de Marca Propria', 'fase', 1, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 1, 'Definir nome autoral da mentoria/imersao (usar Agente de Naming)', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 139, 1, 'Acessar hub.caseai.com.br e usar Agente de Naming para gerar opcoes', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 2, 'Enviar melhores opcoes no grupo para validacao com equipe', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 3, 'Aprovar nome final para uso em contrato, PDFs e comunicacao', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 2, 'Definir nome autoral da tecnica de subincisao guiada por ultrassom', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 3, 'Consolidar posicionamento: especialista em tratamento de retracoes com tecnica autoral guiada por ultrassom', 'pendente', 'mentor', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 4, 'Definir estrategia de desvinculacao gradual da Gold Incision (marca paralela, nao ruptura)', 'pendente', 'mentor', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 5, 'Atualizar bio e destaques do Instagram com novo posicionamento autoral', 'pendente', 'mentorado', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 6, 'Mapear diferenciais unicos para comunicacao: radiologista + esteta + pioneira ultrassom + celulite isolada + turmas micro', 'pendente', 'mentor', 6, 'dossie_auto');

-- ============================================================
-- FASE 2: ESTRUTURACAO DO PRODUTO EDUCACIONAL
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 139, 'Estruturacao do Produto Educacional (Imersao Presencial)', 'fase', 2, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 1, 'Validar e ajustar conteudo programatico dos 3 pilares com base na pratica real da Michelle', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 139, 1, 'Pilar 1: Ajustar conteudo de Tecnica de Subincisao (anatomia, passo-a-passo, bioestimuladores, retracoes)', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 2, 'Pilar 2: Ajustar conteudo de Ultrassom Dermatologico Aplicado (mapeamento, complicacoes por imagem)', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 3, 'Pilar 3: Ajustar conteudo de Complicacoes - Prevencao e Manejo (protocolos, arvore de decisao)', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 2, 'Definir cronograma detalhado da imersao (pre-treinamento + Dia 1 + Dia 2 + pos-treinamento)', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 3, 'Produzir materiais e ferramentas do aluno (protocolos, checklists, templates, guias)', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 139, 1, 'Protocolo documentado de subincisao passo-a-passo', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 2, 'Checklist de avaliacao pre-procedimento', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 3, 'Guia de escolha de bioestimuladores absorviveis (indicacoes, doses, marcas)', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 4, 'Template de consentimento informado para celulite', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 5, 'Modelo de documentacao de caso (portfolio + seguranca juridica)', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 6, 'Protocolo de manejo de complicacoes + arvore de decisao', 'pendente', 'mentorado', 6, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 7, 'Atlas de imagens ultrassonograficas do gluteo', 'pendente', 'mentorado', 7, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 4, 'Gravar modulo teorico online (anatomia + tecnica + ultrassom basico) para pre-treinamento', 'pendente', 'mentorado', 4, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 139, 1, 'Gravar aula introdutoria de ultrassom basico para preparar alunos', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 2, 'Subir como link privado (YouTube nao listado ou plataforma Kiwify)', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 5, 'Definir e confirmar pacientes modelo para o presencial de 24-25 de Abril', 'pendente', 'mentorado', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 6, 'Definir formato e preco final da imersao (R$ 25.000 a vista / R$ 35.000 parcelado)', 'pendente', 'mentor', 6, 'dossie_auto');

-- ============================================================
-- FASE 3: OFERTA E ARQUITETURA COMERCIAL
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 139, 'Oferta e Arquitetura Comercial', 'fase', 3, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 1, 'Finalizar pagina/documento de oferta com promessa, pilares, jornada e ancoragem de preco', 'pendente', 'equipe_spalla', 1, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 2, 'Estruturar argumentos de quebra de objecoes para calls de venda', 'pendente', 'mentor', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 139, 1, 'Objecao: Ja fiz curso de celulite/gluteo - diferenciar pratica supervisionada', 'pendente', 'mentor', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 2, 'Objecao: E muito caro para 2 dias - ancoragem de ROI (1 procedimento ja paga)', 'pendente', 'mentor', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 3, 'Objecao: Nao tenho aparelho de ultrassom - ultrassom e diferencial, nao pre-requisito', 'pendente', 'mentor', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 4, 'Objecao: Nao quero trabalhar com PMMA - celulite usa bioestimulador absorvivel', 'pendente', 'mentor', 4, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 5, 'Objecao: Tem muita gente oferecendo isso - ninguem ensina celulite aprofundada com ultrassom', 'pendente', 'mentor', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 3, 'Definir escada de produtos futuros: Celulite (entrada) > Volume/PMMA > Endolaser para nodulos', 'pendente', 'mentor', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 4, 'Preparar PDF de duvida (pos-call) para reforcar clareza e remover inseguranca do lead', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 5, 'Preparar PDF do comprado / manual do participante (pos-pagamento)', 'pendente', 'equipe_spalla', 5, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 139, 1, 'Incluir info de hotel, deslocamento, o que levar, como sera o presencial', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 2, 'Incluir jornada pos-presencial: 3 encontros / 3 meses / 1 por mes', 'pendente', 'equipe_spalla', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 6, 'Preparar contrato com procedimento de assinatura definido', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

-- ============================================================
-- FASE 4: CONTEUDO E COMUNICACAO ESTRATEGICA
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 139, 'Conteudo e Comunicacao Estrategica no Instagram', 'fase', 4, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 1, 'Mudar comunicacao de apenas resultado/case para mecanismo e raciocinio clinico', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 2, 'Criar conteudos baseados nas 10 crencas do dossie para imprimir no publico', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 139, 1, 'Crenca 1: Resultado vem de tecnica certa, nao de produto caro', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 2, 'Crenca 2: Seguranca nao e opcional (valorizar diagnostico por imagem)', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 3, 'Crenca 3: Celulite e dor emocional real, nao frescura', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 4, 'Crenca 4: Marketing sem tecnica e perigoso', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 5, 'Crenca 5-10: Autonomia, estudo, padronizacao mata resultado, ensinar e responsabilidade, complicacao nao e vergonha, excelencia e detalhe invisivel', 'pendente', 'mentorado', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 3, 'Produzir conteudo mostrando diferenciais tecnicos: ultrassom pre-procedimento, visualizacao de complicacoes', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 4, 'Criar narrativa clara de por que a tecnica e diferente e por que aprender com ela e mais seguro', 'pendente', 'mentorado', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 5, 'Comecar a se posicionar em temas estrategicos (complicacoes, PMMA) com postura educativa, nao polemica', 'pendente', 'mentorado', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 6, 'Adaptar storytelling para conteudos de feed, reels, bio e destaques', 'pendente', 'mentorado', 6, 'dossie_auto');

-- ============================================================
-- FASE 5: FUNIL DE CAPTACAO E VENDAS
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 139, 'Funil de Captacao e Vendas para a Imersao', 'fase', 5, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 1, 'Mapear e organizar lista de leads organicos (medicos que ja procuraram por DM)', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 2, 'Mapear grupos de WhatsApp como ativos de captacao (2.900+ medicos unicos)', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 139, 1, 'Grupo Ultrassom Dermatologico (330 membros) - Michelle e autoridade maxima, criou o grupo', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 2, 'Grupo Biossimetric Academy (715 membros) - medicos que usam PMMA', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 3, 'Grupos Lhalapeel (415), PDRN (715), Exossomos, MKT Medico (815)', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 3, 'Estudar abordagem de vendas: roteiro de call + fechamento + follow-up', 'pendente', 'mentorado', 3, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 139, 1, 'Estudar estrutura completa do funil: abordagem 1a1 com ligacao de qualificacao', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 2, 'Comecar pela interessada quente (leads organicos), depois escalar lista', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 4, 'Definir processo claro de aplicacao, qualificacao e fechamento', 'pendente', 'mentor', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 5, 'Reforcar abordagem em grupos como compartilhamento de case tecnico genuino (nao divulgacao direta)', 'pendente', 'mentor', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 6, 'Usar Instagram como maquina de leads educacionais (conteudo estrategico > DM > call)', 'pendente', 'mentorado', 6, 'dossie_auto');

-- ============================================================
-- FASE 6: ABORDAGEM E VENDA DA PRIMEIRA TURMA
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 139, 'Abordagem e Venda da Primeira Turma (4 vagas)', 'fase', 6, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 1, 'Rodar abordagem da lista quente (leads que ja procuraram por DM)', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 2, 'Rodar abordagem em lote nos grupos de WhatsApp com follow-up e controle', 'pendente', 'mentorado', 2, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 139, 1, 'Usar texto + audio no estilo natural da Michelle', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 2, 'Manter controle de abordagens enviadas e follow-ups', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 3, 'Realizar calls de qualificacao e fechamento com interessados', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 4, 'Fechar 4 alunos para a primeira turma de validacao (24-25 de Abril)', 'pendente', 'mentorado', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 5, 'Enviar contrato e receber assinatura dos alunos fechados', 'pendente', 'mentorado', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 6, 'Atualizar status do funil em tempo real conforme cada acao for executada', 'pendente', 'mentorado', 6, 'dossie_auto');

-- ============================================================
-- FASE 7: ONBOARDING E PRE-TREINAMENTO DOS ALUNOS
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 139, 'Onboarding e Pre-Treinamento dos Alunos', 'fase', 7, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 1, 'Desenhar curso/fluxo de onboarding completo (antes de delegar)', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;

INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 139, 1, 'Mensagem de boas-vindas + proximos passos', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 2, 'Assinatura do contrato (se ainda nao concluida)', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 3, 'Liberacao/entrega do PDF do comprado', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 4, 'Link da aula introdutoria + checklist do aluno (o que levar / como se preparar)', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 5, 'Confirmacoes: presenca, horarios, local e lembretes', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 139, 6, 'Canal de suporte + info pos-presencial (3 encontros online)', 'pendente', 'mentorado', 6, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 2, 'Criar roteiro copia e cola de onboarding (mensagens + ordem + gatilhos de envio)', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 3, 'Delegar execucao do onboarding para secretaria (treinar roteiro de envios, confirmacoes e lembretes)', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 4, 'Liberar acesso a plataforma de aulas e modulos teoricos para os alunos', 'pendente', 'mentorado', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 5, 'Enviar checklist de pre-estudo e confirmar que alunos completaram antes do presencial', 'pendente', 'mentorado', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 6, 'Confirmar presenca e detalhes logisticos 3 dias antes do evento', 'pendente', 'mentorado', 6, 'dossie_auto');

-- ============================================================
-- FASE 8: PREPARACAO LOGISTICA DO PRESENCIAL
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 139, 'Preparacao Logistica do Presencial (24-25 Abril)', 'fase', 8, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 1, 'Confirmar data travada: presencial 24 e 25 de Abril', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 2, 'Definir e confirmar pacientes modelo para pratica supervisionada', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 3, 'Preparar materiais de apoio: checklists e guias impressos para o dia', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 4, 'Definir logistica exata: sequencia, tempos, pausas, fluxo de pratica', 'pendente', 'mentorado', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 5, 'Organizar welcome coffee e recepcao dos alunos na clinica', 'pendente', 'mentorado', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 6, 'Garantir tempo de sobra para organizacao (sem correria)', 'pendente', 'mentorado', 6, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 7, 'Preparar equipamento de ultrassom e insumos para os 2 dias', 'pendente', 'mentorado', 7, 'dossie_auto');

-- ============================================================
-- FASE 9: EXECUCAO DA IMERSAO PRESENCIAL
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 139, 'Execucao da Imersao Presencial (Dia 1 e Dia 2)', 'fase', 9, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 1, 'Dia 1 Manha: Revisao teorica de anatomia funcional + alinhamento do protocolo de subincisao', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 2, 'Dia 1 Manha: Demonstracao ao vivo - Michelle executa subincisao completa em paciente real', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 3, 'Dia 1 Tarde: Pratica supervisionada - cada aluno executa individualmente com correcao em tempo real', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 4, 'Dia 1 Tarde: Documentacao fotografica dos casos + checklist de execucao + anotacoes tecnicas', 'pendente', 'mentorado', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 5, 'Dia 2 Manha: Mapeamento ultrassonografico ao vivo do gluteo (produtos previos, fibroses, vasos)', 'pendente', 'mentorado', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 6, 'Dia 2 Manha: Interpretacao clinica de imagens reais + documentacao antes/depois', 'pendente', 'mentorado', 6, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 7, 'Dia 2 Tarde: Discussao de casos de complicacoes reais + protocolo de prevencao e manejo', 'pendente', 'mentorado', 7, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 8, 'Dia 2 Tarde: Pratica adicional + encerramento com entrega de protocolos documentados', 'pendente', 'mentorado', 8, 'dossie_auto');

-- ============================================================
-- FASE 10: ACOMPANHAMENTO POS-TREINAMENTO
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 139, 'Acompanhamento Pos-Treinamento (3 Meses)', 'fase', 10, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 1, 'Mes 1: Conduzir encontro online 1h - aluno apresenta primeiros casos, Michelle corrige e orienta', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 2, 'Mes 2: Encontro online 1h - analise de evolucao, ajustes de tecnica, casos mais complexos', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 3, 'Mes 3: Encontro online 1h - revisao final, validacao de resultados, alta tecnica', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 4, 'Coletar depoimentos e resultados dos alunos para prova social', 'pendente', 'mentorado', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 5, 'Documentar aprendizados da turma 1 para otimizar proximas turmas', 'pendente', 'mentorado', 5, 'dossie_auto');

-- ============================================================
-- FASE 11 (PASSO EXECUTIVO): ESCALA E PROXIMAS TURMAS
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 139, 'Escala: Proximas Turmas e Otimizacao do Funil', 'passo_executivo', 11, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 1, 'Analisar resultados da turma 1 e ajustar produto/cronograma se necessario', 'pendente', 'mentor', 1, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 2, 'Definir calendario de proximas turmas (manter turmas de 4 alunos)', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 3, 'Usar depoimentos e cases da turma 1 como prova social para vendas', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 4, 'Treinar equipe para apoiar vendas futuras do produto educacional', 'pendente', 'mentorado', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 5, 'Otimizar funil de captacao com base nos dados da primeira rodada', 'pendente', 'mentor', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 6, 'Avaliar possibilidade de ajustar preco para turmas seguintes (sair do preco fundador)', 'pendente', 'mentor', 6, 'dossie_auto');

-- ============================================================
-- FASE 12 (PASSO EXECUTIVO): ESCADA DE PRODUTOS PREMIUM
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 139, 'Escada de Produtos Premium e Expansao', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 1, 'Planejar produto 2 da escada: Volume/Preenchimento gluteo (PMMA) para alunos avanc ados', 'pendente', 'mentor', 1, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 2, 'Planejar produto 3 da escada: Endolaser para nodulos (tecnica revolucionaria exclusiva)', 'pendente', 'mentor', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 3, 'Consolidar marca propria e independencia total da Gold Incision', 'pendente', 'mentorado', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 4, 'Avaliar expansao para modelo de recorrencia (comunidade de ex-alunos, atualizacoes tecnicas)', 'pendente', 'mentor', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 5, 'Explorar convites para palestrar em eventos do nicho como estrategia de autoridade', 'pendente', 'mentorado', 5, 'dossie_auto');

-- ============================================================
-- FASE 13 (PASSO EXECUTIVO): AUTOMACAO E DELEGACAO
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 139, 'Automacao, Delegacao e Sustentabilidade Operacional', 'passo_executivo', 13, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 1, 'Sistematizar processo de vendas para que equipe possa executar abordagem e follow-up', 'pendente', 'mentorado', 1, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 2, 'Automatizar fluxo de onboarding com secretaria executando 100% do roteiro', 'pendente', 'mentorado', 2, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 3, 'Criar sistema de controle de funil com datas de entrega e status atualizados em tempo real', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 4, 'Avaliar necessidade de monitor/assistente para expandir turmas sem sobrecarregar Michelle', 'pendente', 'mentor', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 5, 'Garantir que modelo educacional nao comprometa faturamento clinico (R$ 400-500k/mes)', 'pendente', 'mentor', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 139, 6, 'Transformar conhecimento tacito em metodo ensinavel e replicavel sem perder qualidade', 'pendente', 'mentorado', 6, 'dossie_auto');

END $$;
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN

-- ============================================================
-- PLANO DE ACAO
-- ============================================================
INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
VALUES (6, 'PLANO DE ACAO v2 | Pablo Santos', 'fases', 'nao_iniciado', 'dossie_auto_v3')
RETURNING id INTO _plano_id;

-- ============================================================
-- FASE 0: REVISAO DO DOSSIE
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 6, 'Revisao do Dossie com o Mentorado', 'revisao_dossie', 0, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 1, 'Apresentar o dossie completo ao Pablo e validar contexto do expert', 'pendente', 'mentor', 1, 'dossie_auto'),
(_fase_id, _plano_id, 6, 2, 'Validar publico-alvo: dentistas 3-7 anos que nao dominam protese sobre implante', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 6, 3, 'Confirmar produto principal: Mentoria em Protese sobre Implante e Implantodontia Digital Avancada', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 6, 4, 'Alinhar desafios-chave: estafa mental, escassez travestida, vicio em operacional', 'pendente', 'mentor', 4, 'dossie_auto'),
(_fase_id, _plano_id, 6, 5, 'Validar meta operacional: 20-25 vagas por turma, sala cabe 23', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 6, 6, 'Revisar arquitetura dos 4 pilares da formacao e confirmar conteudo programatico', 'pendente', 'mentorado', 6, 'dossie_auto');

-- ============================================================
-- FASE 1: POSICIONAMENTO ESTRATEGICO E MENTALIDADE
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 6, 'Posicionamento Estrategico e Mudanca de Mentalidade', 'fase', 1, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 1, 'Romper padrao de escassez: largar apego ao concurso/plantao como simbolo de seguranca', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 6, 2, 'Transicionar de professor acessivel para referencia tecnica premium em implantodontia digital', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 6, 3, 'Definir narrativa central: lider tecnico que transforma carreiras com proximidade e resultado', 'pendente', 'mentor', 3, 'dossie_auto'),
(_fase_id, _plano_id, 6, 4, 'Superar trava de comunicacao de grandeza: comunicar numeros e provas com naturalidade', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 6, 5, 'Reduzir vicio em operacional/adrenalina: delegar tarefas nao-estrategicas da clinica', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 6, 6, 'Criar rituais de clareza mental: proteger tempo estrategico para a mentoria', 'pendente', 'mentorado', 6, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 6, 7, 'Reposicionar medo de formar concorrentes como fortalecimento de rede e autoridade', 'pendente', 'mentor', 7, 'dossie_auto');

-- ============================================================
-- FASE 2: ESTRUTURACAO DA OFERTA E PRODUTO
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 6, 'Estruturacao da Oferta e Produto da Mentoria', 'fase', 2, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 1, 'Finalizar arquitetura dos 4 pilares: Protese sobre Implante, Digital, Pratica Presencial, Implanto Avancada', 'pendente', 'mentorado', 1, 'dossie_auto')
RETURNING id INTO _acao_id;
INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 6, 1, 'Pilar 1: Definir conteudo programatico de protese sobre implante como base tecnica central', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 6, 2, 'Pilar 2: Estruturar modulo de implantodontia digital aplicada ao planejamento real', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 6, 3, 'Pilar 3: Definir formato OBSERVE-SE para imersao presencial na clinica', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 6, 4, 'Pilar 4: Criar trilha de evolucao para implantodontia avancada e zigomatico', 'pendente', 'mentorado', 4, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 2, 'Definir entregaveis com precisao: aulas gravadas, imersao presencial, discussao de casos, acompanhamento online', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 6, 3, 'Estruturar cadencia: encontros online quinzenais por 3 meses pos-imersao', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 6, 4, 'Definir criterios de entrada: dentistas 3-7 anos, inseguros em protese sobre implante', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 6, 5, 'Estruturar bonus 1: Estrategias de Captacao de Pacientes para Implantodontia (valor ref R$5.000)', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
(_fase_id, _plano_id, 6, 6, 'Estruturar bonus 2: Tecnica de Venda Clinica Avancada para Cobrar Mais Caro (valor ref R$7.000)', 'pendente', 'equipe_spalla', 6, 'dossie_auto'),
(_fase_id, _plano_id, 6, 7, 'Validar pricing: R$12.000 a vista ou 3x R$5.000 no cartao', 'pendente', 'mentorado', 7, 'dossie_auto');

-- ============================================================
-- FASE 3: SIMPLIFICACAO DA JORNADA DE ENTREGA
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 6, 'Simplificacao e Clareza na Jornada de Entrega', 'fase', 3, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 1, 'Transformar entrega em jornada clara de 5 etapas: onboarding, raciocinio clinico, observe-se, discussao, acompanhamento', 'pendente', 'mentor', 1, 'dossie_auto'),
(_fase_id, _plano_id, 6, 2, 'Criar onboarding simples: acesso plataforma + grupo fechado + orientacao de estudo', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 6, 3, 'Gravar conteudo teorico da base tecnica (protese sobre implante + digital)', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 6, 4, 'Planejar logistica da imersao presencial formato OBSERVE-SE na clinica', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 6, 5, 'Criar template de discussao estruturada de casos clinicos', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
(_fase_id, _plano_id, 6, 6, 'Montar calendário dos encontros online quinzenais (3 meses)', 'pendente', 'mentorado', 6, 'dossie_auto');

-- ============================================================
-- FASE 4: LAPIDACAO DO PERFIL DO INSTAGRAM
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 6, 'Lapidacao do Perfil do Instagram (@profpablosantos)', 'fase', 4, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 1, 'Atualizar foto de perfil: crop 60-70% rosto, expressao firme, fundo neutro/consultorio', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 6, 2, 'Otimizar campo Nome para SEO: Pablo Santos | Protese sobre Implante & Odonto Digital', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 6, 3, 'Reescrever bio com publico claro, diferencial digital e CTA de aplicacao', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES (_fase_id, _plano_id, 6, 4, 'Reestruturar destaques na ordem de conversao: Quem sou, Resultados, Formacao, Bastidores, Duvidas', 'pendente', 'equipe_spalla', 4, 'dossie_auto')
RETURNING id INTO _acao_id;
INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_acao_id, _fase_id, _plano_id, 6, 1, 'Destaque 1 Quem Sou: gravar 6-8 stories com roteiro de autoridade tecnica', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 6, 2, 'Destaque 2 Resultados: compilar depoimentos e casos antes/depois de alunos', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 6, 3, 'Destaque 3 Formacao/Mentoria: gravar 8-10 stories explicando o produto premium', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 6, 4, 'Destaque 4 Bastidores: capturar rotina real da clinica sem perder autoridade', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_acao_id, _fase_id, _plano_id, 6, 5, 'Destaque 5 Duvidas: gravar respostas para 7 objecoes mais comuns', 'pendente', 'mentorado', 5, 'dossie_auto');

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 5, 'Arquivar posts com linguagem generica de especializacao tradicional', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 6, 6, 'Definir manual de estetica visual: fundo limpo, luz frontal, roupa escura, texto branco/off-white', 'pendente', 'equipe_spalla', 6, 'dossie_auto'),
(_fase_id, _plano_id, 6, 7, 'Manter perfil unico hibrido (clinica + formacao) sem criar perfil separado', 'pendente', 'mentorado', 7, 'dossie_auto');

-- ============================================================
-- FASE 5: POSTS FIXADOS E CONTEUDO DE TOPO DE PERFIL
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 6, 'Posts Fixados e Conteudo de Topo de Perfil', 'fase', 5, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 1, 'Criar Post Fixado 1 HISTORIA: carrossel com trajetoria de clinico geral a especialista', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
(_fase_id, _plano_id, 6, 2, 'Criar Post Fixado 2 PROVA/AUTORIDADE: reels 60-90s sobre o custo de nao ser especialista', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 6, 3, 'Criar Post Fixado 3 PRODUTO: carrossel com 9 slides explicando a formacao premium', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
(_fase_id, _plano_id, 6, 4, 'Gravar Reels de Suporte 1 HISTORIA: O custo invisivel de indicar pacientes (30-45s)', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 6, 5, 'Gravar Reels de Suporte 2 PRODUTO: Por que essa formacao nao e comum (30-45s)', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 6, 6, 'Fixar reels de suporte na guia de reels do perfil', 'pendente', 'mentorado', 6, 'dossie_auto');

-- ============================================================
-- FASE 6: STORYTELLING E COMUNICACAO BASE
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 6, 'Storytelling e Comunicacao de Marca Pessoal', 'fase', 6, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 1, 'Aprovar storytelling base do dossie como fundacao de toda comunicacao', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 6, 2, 'Manter eixo narrativo: origem > consciencia > escolha > criterio > posicionamento atual', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 6, 3, 'Adaptar storytelling para formatos: feed, reels, bio, destaques, pagina de vendas, anuncios', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
(_fase_id, _plano_id, 6, 4, 'Definir tom de comunicacao: humano, maduro, sem cliche de marketing, sem promessa vazia', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
(_fase_id, _plano_id, 6, 5, 'Garantir que toda comunicacao preserve: autoridade tecnica, etica, criterio, naturalidade', 'pendente', 'mentor', 5, 'dossie_auto');

-- ============================================================
-- FASE 7: ESTRATEGIA DE CONTEUDO ORGANICO
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 6, 'Estrategia de Conteudo Organico (20 ideias mapeadas)', 'fase', 7, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 1, 'Produzir conteudos da fase DESCOBRIR: workaholic, R$700k em cidade pequena, R$3M encaminhados, pegar mais mao', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 6, 2, 'Produzir conteudos da fase ENTENDER: 7 sinais, gestao nao foi primeiro passo, perdas alem do dinheiro, digital obrigatorio', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 6, 3, 'Produzir conteudos da fase CONFIAR: 18 anos mesma especialidade, case de aluno, bastidores plantao, clinica cidade pequena', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 6, 4, 'Produzir conteudos da fase DESEJAR: dentista que escolhe, R$700k lifestyle, antes/depois 18 anos, reconhecimento', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 6, 5, 'Produzir conteudos da fase IDENTIFICAR: quase desisti, jaleco sujo, solidao workaholic, o que faria diferente', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 6, 6, 'Manter conteudos que funcionam: casos clinicos, planejamento reverso, protese provisoria, overdenture, bastidores reais', 'pendente', 'mentorado', 6, 'dossie_auto'),
(_fase_id, _plano_id, 6, 7, 'Regravar bons temas com headline forte, framing estrategico e CTA de aplicacao', 'pendente', 'equipe_spalla', 7, 'dossie_auto');

-- ============================================================
-- FASE 8: ESTRATEGIA DE ANUNCIOS (TRAFEGO PAGO)
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 6, 'Estrategia de Anuncios e Trafego Pago (20 anuncios mapeados)', 'fase', 8, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 1, 'Produzir anuncios de DOR: dinheiro que sai da clinica, custo de nao dominar, pegar mais mao, digital obrigatorio', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
(_fase_id, _plano_id, 6, 2, 'Produzir anuncios de AUTORIDADE: gestao nao mudou tudo, observe-se, 18 anos, zigomatico e ponto de chegada', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 6, 3, 'Produzir anuncios de PROVA SOCIAL: depoimentos de alunos, nao e falta de paciente, clinica R$700k cidade pequena', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
(_fase_id, _plano_id, 6, 4, 'Produzir anuncios de DIFERENCIAL: por que nao saiu do mocho, clinico vs especialista, captacao incluida', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
(_fase_id, _plano_id, 6, 5, 'Produzir anuncio de FECHAMENTO: essa nao e uma decisao impulsiva, o que vem depois da formacao', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
(_fase_id, _plano_id, 6, 6, 'Otimizar investimento atual de R$30k/mes em trafego para direcionar a formacao premium', 'pendente', 'mentorado', 6, 'dossie_auto');

-- ============================================================
-- FASE 9: FUNIL DE AQUISICAO BASE QUENTE
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 6, 'Funil de Aquisicao pela Base Quente (prioridade maxima)', 'fase', 9, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 1, 'Mapear e segmentar os ~200 ex-alunos presenciais como prioridade maxima', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 6, 2, 'Mapear os ~170 alunos do curso online Hotmart como base secundaria', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 6, 3, 'Criar abordagem de reativacao personalizada para ex-alunos (sem ser generica)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
(_fase_id, _plano_id, 6, 4, 'Estruturar qualificacao pre-call: perguntas e criterios para evitar desqualificados', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
(_fase_id, _plano_id, 6, 5, 'Definir processo de venda: qualificacao > call > decisao na call', 'pendente', 'mentor', 5, 'dossie_auto'),
(_fase_id, _plano_id, 6, 6, 'Vender com polaridade: selecao a dedo, processo seletivo, ponto de inflexao de carreira', 'pendente', 'mentorado', 6, 'dossie_auto'),
(_fase_id, _plano_id, 6, 7, 'Ativar network qualificado: rede de clinicas e contatos via alunos', 'pendente', 'mentorado', 7, 'dossie_auto');

-- ============================================================
-- FASE 10: ANCORAGEM E PAGINA DE VENDAS
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 6, 'Ancoragem de Valor e Pagina de Vendas', 'fase', 10, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 1, 'Construir ancoragem: especializacao R$40-80k + cursos hands-on R$25-40k + mentorias R$10k = R$70k+ fragmentado', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
(_fase_id, _plano_id, 6, 2, 'Criar pagina de vendas com copy da jornada: dor > tese > pilares > metodo > resultado > investimento', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 6, 3, 'Incluir provas na pagina: depoimentos de alunos, numeros da clinica, trajetoria de 17+ anos', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
(_fase_id, _plano_id, 6, 4, 'Incluir secao de objecoes: dinheiro, tempo, medo, historico de frustracao com cursos', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
(_fase_id, _plano_id, 6, 5, 'Posicionar como decisao de carreira, nao compra emocional: processo seletivo via aplicacao', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

-- ============================================================
-- FASE 11: LANCAMENTO DA PRIMEIRA TURMA (PASSO EXECUTIVO)
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 6, 'Lancamento da Primeira Turma da Mentoria', 'passo_executivo', 11, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 1, 'Iniciar reativacao da base quente: contato direto com ex-alunos presenciais', 'pendente', 'mentorado', 1, 'dossie_auto'),
(_fase_id, _plano_id, 6, 2, 'Abrir formulario de aplicacao com criterios de selecao definidos', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
(_fase_id, _plano_id, 6, 3, 'Agendar e conduzir calls de venda com candidatos qualificados', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 6, 4, 'Fechar primeira turma com meta de 20-25 vagas', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 6, 5, 'Configurar plataforma de aulas gravadas e grupo fechado', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
(_fase_id, _plano_id, 6, 6, 'Agendar data da imersao presencial OBSERVE-SE na clinica', 'pendente', 'mentorado', 6, 'dossie_auto'),
(_fase_id, _plano_id, 6, 7, 'Preparar materiais de apoio e protocolos do Pablo para entrega aos alunos', 'pendente', 'mentorado', 7, 'dossie_auto');

-- ============================================================
-- FASE 12: OPERACAO E ENTREGA DA MENTORIA (PASSO EXECUTIVO)
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 6, 'Operacao e Entrega da Primeira Turma', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 1, 'Executar onboarding: liberar acesso a plataforma e grupo fechado', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
(_fase_id, _plano_id, 6, 2, 'Conduzir fase teorica: alunos estudam base tecnica e raciocinio clinico', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 6, 3, 'Executar imersao presencial OBSERVE-SE com observacao de casos reais', 'pendente', 'mentorado', 3, 'dossie_auto'),
(_fase_id, _plano_id, 6, 4, 'Conduzir discussao estruturada de casos clinicos pos-imersao', 'pendente', 'mentorado', 4, 'dossie_auto'),
(_fase_id, _plano_id, 6, 5, 'Iniciar acompanhamento online quinzenal por 3 meses', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 6, 6, 'Coletar depoimentos e resultados dos alunos para prova social', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

-- ============================================================
-- FASE 13: ESCALA E PROXIMOS PASSOS (PASSO EXECUTIVO)
-- ============================================================
INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
VALUES (_plano_id, 6, 'Escala, Otimizacao e Proximos Passos', 'passo_executivo', 13, 'nao_iniciado', 'dossie_auto')
RETURNING id INTO _fase_id;

INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
VALUES
(_fase_id, _plano_id, 6, 1, 'Analisar resultados da primeira turma: taxa de aplicacao, satisfacao, depoimentos', 'pendente', 'mentor', 1, 'dossie_auto'),
(_fase_id, _plano_id, 6, 2, 'Ajustar oferta e entrega com base no feedback dos primeiros alunos', 'pendente', 'mentorado', 2, 'dossie_auto'),
(_fase_id, _plano_id, 6, 3, 'Escalar aquisicao: ativar trafego pago direcionado a formacao apos validacao base quente', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
(_fase_id, _plano_id, 6, 4, 'Estruturar funil frio via Instagram com conteudo organico + anuncios mapeados', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
(_fase_id, _plano_id, 6, 5, 'Avaliar reducao da dependencia do plantao/concurso conforme receita da mentoria cresce', 'pendente', 'mentorado', 5, 'dossie_auto'),
(_fase_id, _plano_id, 6, 6, 'Planejar turma 2 com base nos aprendizados e depoimentos da turma 1', 'pendente', 'mentorado', 6, 'dossie_auto');

END $$;
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN

  -- =============================================
  -- PLANO DE ACAO v2 | Raqui Piolli (mentorado_id = 5)
  -- =============================================
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (5, 'PLANO DE ACAO v2 | Raqui Piolli', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- =============================================
  -- FASE 0: Revisao do Dossie com a Mentorada
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Revisao do Dossie com a Mentorada', 'revisao_dossie', 0, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 1, 'Apresentar o dossie completo para a Raqui em call dedicada', 'pendente', 'mentor', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 2, 'Revisar contexto analisado: forcas, diferenciais, desafios e motivacoes atuais', 'pendente', 'mentor', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 3, 'Validar posicionamento proposto: cirurgia especialista em face + mentora de formacao cirurgica premium', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 4, 'Alinhar visao de futuro (12 meses): funil redondo, marketing profissionalizado, ofertas premium, reorganizacao de agenda', 'pendente', 'mentor', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 5, 'Definir prioridades e ordem de execucao das fases do plano de acao', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 6, 'Registrar ajustes e observacoes da mentorada sobre o plano', 'pendente', 'mentor', 6, 'dossie_auto');

  -- =============================================
  -- FASE 1: Posicionamento e Narrativa Estrategica
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Posicionamento e Narrativa Estrategica', 'fase', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 1, 'Consolidar tese central: migrar do paliativo para o cirurgico com observacao, pratica supervisionada e revisao tecnica', 'pendente', 'mentor', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 2, 'Construir narrativa da trajetoria: 10 anos de cirurgia, transicao Vitoria-SP, estrutura propria, demanda natural de profissionais', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 3, 'Definir pilares de posicionamento: naturalidade cirurgica, criterio clinico, metodo proprio, estrutura premium, didatica clara', 'pendente', 'mentor', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 4, 'Criar mecanismo unico comunicavel: Metodo Observatorio-Pratica-Revisao (OPR)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 5, 'Desenvolver storytelling oficial para uso em conteudo, paginas de venda e calls comerciais', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 6, 'Validar posicionamento final com a Raqui e ajustar tom de comunicacao', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- =============================================
  -- FASE 2: Lapidacao do Perfil Instagram (@dra.raqui)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Lapidacao do Perfil Instagram (@dra.raqui)', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 1, 'Otimizar bio: transformacao + autoridade + para quem e + CTA direto', 'pendente', 'equipe_spalla', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
  (_fase_id, _plano_id, 5, 2, 'Criar estrutura de destaques otimizada: Sobre, Resultados, One Face Lift, Frontoplastia, Formacoes, Alunos', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 5, 1, 'Destaque Sobre: trajetoria, credenciais, visao de naturalidade', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 2, 'Destaque Resultados: antes/depois, depoimentos, videos curtos', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 3, 'Destaque One Face Lift: o que e, para quem, diferenciais', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 4, 'Destaque Frontoplastia: explicacao, casos, duvidas', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 5, 'Destaque Formacoes: metodo, turmas, bastidores cirurgicos', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 6, 'Destaque Alunos: videos dos alunos, evolucao, prova social cirurgica', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  -- Buscar o acao_id correto para sub_acoes acima (acao 2 desta fase)
  -- Re-inserir acoes restantes
  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 3, 'Criar 3 posts fixados urgentes: apresentacao (carrossel), conteudo de valor (pacientes), prova social forte (antes/depois + CTA)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 4, 'Gravar stories para preencher cada destaque com conteudo estrategico', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 5, 'Publicar post fixado #1: carrossel de apresentacao — Quem e a cirurgia por tras do One Face Lift', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 6, 'Revisar e aprovar arquitetura completa do perfil com a Raqui', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- =============================================
  -- FASE 3: Estruturacao da Oferta One Face Lift (R$ 40k)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Estruturacao da Oferta One Face Lift (R$ 40k)', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 1, 'Validar estrutura da formacao de 6 meses: 2d observatorio + 3d pratica + 2d observatorio final + 3 meses acompanhamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 2, 'Definir ticket ancora (R$ 60k) e preco de lancamento (R$ 40k primeira turma)', 'pendente', 'mentor', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 3, 'Estruturar versao enxuta opcional (somente pratica R$ 25k) como downsell', 'pendente', 'mentor', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 4, 'Criar pagina de oferta/apresentacao com copy da jornada do aluno e 4 pilares', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 5, 'Definir bonus exclusivos: acervo de cirurgias gravadas, certificacao, analise individual de casos', 'pendente', 'mentor', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 6, 'Preparar argumentario de venda com ancoragem de valor (R$ 60k+ se contratado separado)', 'pendente', 'equipe_spalla', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 7, 'Validar oferta completa com a Raqui e simular pitch de venda', 'pendente', 'mentorado', 7, 'dossie_auto');

  -- =============================================
  -- FASE 4: Estruturacao da Oferta Frontoplastia (R$ 20k)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Estruturacao da Oferta Frontoplastia (R$ 20k)', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 1, 'Validar estrutura da formacao de 3 meses: 2d observatorio + 2d pratica + 1 mes acompanhamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 2, 'Definir ticket: R$ 20k a vista ou 10x R$ 2.200', 'pendente', 'mentor', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 3, 'Criar pagina de oferta com copy baseada nos 3 pilares: observacao, pratica supervisionada, acompanhamento', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 4, 'Definir bonus: biblioteca de cirurgias gravadas, protocolos de seguranca, scripts de qualificacao', 'pendente', 'mentor', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 5, 'Posicionar Frontoplastia como tecnica rara com alta demanda (prova: 40 interessados em live improvisada)', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 6, 'Validar oferta com a Raqui e testar com base atual de alunos da faculdade', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- =============================================
  -- FASE 5: Funil do Consultorio — Trafego e Qualificacao de Leads
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Funil do Consultorio — Trafego e Qualificacao de Leads', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 1, 'Ajustar campanhas com gestor de trafego (Rafa): foco em blefaroplastia, face, publico local SP com poder de investimento', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 5, 1, 'Revisar publicos e segmentacoes atuais das campanhas', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 2, 'Eliminar leads desqualificados: papada isolada, outros estados, perfis sem poder de investimento', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 3, 'Criar rotina semanal de revisao de metricas com o Rafa', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 2, 'Treinar e supervisionar equipe de agendamento/pre-atendimento para melhorar qualificacao e taxa de comparecimento', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 3, 'Implementar script de qualificacao de leads antes da consulta (filtro de perfil ideal)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 4, 'Criar rotina de acompanhamento de metricas: leads, agendamentos, comparecimento, fechamento', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 5, 'Definir meta mensal de consultas qualificadas e taxa de conversao alvo', 'pendente', 'mentor', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 6, 'Criar dashboard simples para acompanhar funil do consultorio semanalmente', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  -- =============================================
  -- FASE 6: Tecnica de Venda em Consulta e Online
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Tecnica de Venda em Consulta e Online', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 1, 'Masterizar tecnica de venda presencial: estrutura de perguntas, ancoragem de valor, decisao imediata, link de entrada, sinal', 'pendente', 'mentor', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
  (_fase_id, _plano_id, 5, 2, 'Desenvolver habilidade de fechamento online/a distancia (maior gap atual da Raqui)', 'pendente', 'mentor', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 5, 1, 'Treinar ancoragem de valor por video/call', 'pendente', 'mentor', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 2, 'Praticar pedido de sinal e decisao imediata a distancia', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 3, 'Criar estrutura de proposta comercial para envio pos-call', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 3, 'Criar script de venda para formacoes (One Face Lift e Frontoplastia) com objecoes mapeadas', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 4, 'Mapear e preparar respostas para objecoes mais comuns: sera que vou conseguir, e caro, preciso ver mais, tenho medo', 'pendente', 'mentor', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 5, 'Simular calls de venda com feedback do mentor', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 6, 'Implementar processo de follow-up pos-consulta para leads que nao fecharam', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- =============================================
  -- FASE 7: Rotina de Conteudo e Marketing Profissionalizado
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Rotina de Conteudo e Marketing Profissionalizado', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 1, 'Criar calendario editorial semanal com linhas editoriais definidas (lifestyle, autoridade, desejo, prova social, infovendas, identificacao)', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 5, 1, 'Domingo: lifestyle sutil e inspiracao (manha de cirurgia, detalhes da clinica)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 2, 'Segunda: autoridade e prova social comentada (fios vs cirurgia, bioestimuladores, raciocinio clinico)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 3, 'Terca: desejo e oportunidade (narrativa emocional, investimento honesto)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 4, 'Quarta: prova social estatica (antes/depois, depoimentos)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 5, 'Quinta: infovendas (conteudo educativo com CTA para formacoes)', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 6, 'Sexta: prova social dinamica (bastidores cirurgicos, resultados ao vivo)', 'pendente', 'equipe_spalla', 6, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 7, 'Sabado: identificacao com o expert (humanizacao, rotina real)', 'pendente', 'equipe_spalla', 7, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 2, 'Montar banco de conteudos e provas sociais no Notion/Drive (cases, antes/depois, depoimentos, bastidores)', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 3, 'Aumentar constancia em conteudo educativo de posicionamento para profissionais e pacientes', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 4, 'Criar conteudos mostrando raciocinio cirurgico (por que blefaro e indicada, como selecionar casos, por que fios nao resolvem)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 5, 'Produzir conteudo de bastidores de ensino (aula, discussao de casos, mentoria) para posicionar como formadora', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 6, 'Implementar processo automatizado de organizacao: pastas, referencias, calendario rodando no automatico', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  -- =============================================
  -- FASE 8: Funil de Captacao para Formacoes Cirurgicas
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Funil de Captacao para Formacoes Cirurgicas', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 1, 'Ativar base existente: alunos da faculdade (~40 profissionais) como primeiro publico qualificado', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 2, 'Ativar rede de contatos regionais (colegas medicos em SP) via mensagem direta e convites', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 3, 'Criar funil de anuncios de trafego + pagina de aplicacao para formacoes', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 4, 'Usar centro cirurgico como prova social de estrutura (locacao ja atrai medicos interessados)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 5, 'Criar sequencia de nutrição por WhatsApp/email para leads de formacao', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 6, 'Definir meta de turma: 4 alunos por turma (One Face Lift) para manter qualidade premium', 'pendente', 'mentor', 6, 'dossie_auto');

  -- =============================================
  -- FASE 9: Reorganizacao de Agenda e Foco Estrategico
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Reorganizacao de Agenda e Foco Estrategico', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 1, 'Planejar saida gradual da faculdade (retorno financeiro baixo + retrabalho com cirurgias de alunos em pacientes modelo)', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 2, 'Mapear todas as frentes atuais: consultorio, cirurgias, locacao, faculdade, mentorias, viagens', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 3, 'Classificar cada frente por retorno financeiro e alinhamento com o plano principal', 'pendente', 'mentor', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 4, 'Eliminar ou reduzir frentes que drenam energia sem retorno (prioridade: faculdade)', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 5, 'Redirecionar tempo liberado para: producao de conteudo, gestao de marketing/vendas, turmas de mentoria', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 6, 'Criar rotina semanal estruturada com blocos dedicados: clinica, conteudo, gestao, formacao', 'pendente', 'mentor', 6, 'dossie_auto');

  -- =============================================
  -- FASE 10: Arquitetura de Produto — One Face Lift
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Arquitetura de Produto — Formacao One Face Lift', 'fase', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 1, 'Estruturar Pilar 1 — Observacao Estruturada (2 dias): conteudo programatico, ferramentas, plano de acao do aluno', 'pendente', 'mentor', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_acao_id, _fase_id, _plano_id, 5, 1, 'Preparar caderno de marcacoes cirurgicas e checklists de indicacao/vetores', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 2, 'Organizar biblioteca de cirurgias gravadas para revisao dos alunos', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_acao_id, _fase_id, _plano_id, 5, 3, 'Definir caneta dermografica e modelos de estudo para treino de marcacoes', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 2, 'Estruturar Pilar 2 — Pratica Supervisionada (3 dias): sequencia cirurgica guiada, checklists de seguranca, registro de aprendizados', 'pendente', 'mentor', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 3, 'Estruturar Pilar 3 — Observatorio Final (2 dias): casos complexos, refinamento tecnico, correcao de erros percebidos', 'pendente', 'mentor', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 4, 'Estruturar Pilar 4 — Acompanhamento Pos-Cirurgia (3 meses): envio de casos, feedback, discussoes mensais, grupo WhatsApp', 'pendente', 'mentor', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 5, 'Preparar materiais de apoio: videos gravados, checklists, protocolos de refinamento, material visual de vetores/planos', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 6, 'Definir cronograma da primeira turma e abrir inscricoes', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- =============================================
  -- FASE 11: Arquitetura de Produto — Frontoplastia
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Arquitetura de Produto — Formacao em Frontoplastia', 'fase', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 1, 'Estruturar Pilar 1 — Observacao com Raciocinio Clinico (2 dias): indicacao, marcacao, vetores, profundidades, limites de seguranca', 'pendente', 'mentor', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 2, 'Estruturar Pilar 2 — Pratica Supervisionada com Correcao Direta (2 dias): 4-6 pacientes reais, correcao em tempo real', 'pendente', 'mentor', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 3, 'Estruturar Pilar 3 — Acompanhamento Pos-Cirurgia (1 mes): envio de casos, feedback direto, discussoes', 'pendente', 'mentor', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 4, 'Preparar materiais: biblioteca de videos, checklists de execucao, templates de envio de caso, fichas de acompanhamento', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 5, 'Criar grupo exclusivo WhatsApp e pasta Notion/Drive para turma', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 6, 'Definir cronograma da primeira turma de Frontoplastia e abrir inscricoes', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- =============================================
  -- FASE 12: Lancamento e Primeiras Vendas (Passo Executivo)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Lancamento e Primeiras Vendas das Formacoes', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 1, 'Ativar lista quente: enviar convite personalizado para alunos da faculdade e contatos regionais', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 2, 'Publicar conteudo de lancamento no Instagram: bastidores, tese, depoimentos, abertura de turma', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 3, 'Ativar campanhas de trafego direcionadas para pagina de aplicacao das formacoes', 'pendente', 'mentorado', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 4, 'Realizar calls de venda com leads qualificados usando script e objecoes preparadas', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 5, 'Fechar primeira turma One Face Lift (meta: 4 alunos a R$ 40k)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 6, 'Fechar primeira turma Frontoplastia (meta: 4 alunos a R$ 20k)', 'pendente', 'mentorado', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 7, 'Registrar aprendizados de venda e ajustar processo para proximas turmas', 'pendente', 'mentor', 7, 'dossie_auto');

  -- =============================================
  -- FASE 13: Consolidacao e Escala (Passo Executivo)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Consolidacao e Escala do Negocio', 'passo_executivo', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 1, 'Coletar depoimentos e provas sociais dos primeiros alunos formados', 'pendente', 'mentorado', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 2, 'Documentar evolucao dos alunos para uso em marketing (antes/durante/depois)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 3, 'Revisar metricas do funil do consultorio: leads, conversao, ticket medio, faturamento mensal', 'pendente', 'mentor', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 4, 'Ajustar campanhas, conteudo e funis com base nos dados dos primeiros 3 meses', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 5, 'Confirmar saida da faculdade e redirecionar tempo para operacao do negocio', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 6, 'Planejar turma 2 das formacoes com preco atualizado (ancora R$ 60k One Face Lift)', 'pendente', 'mentor', 6, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 7, 'Consolidar Raqui como referencia nacional em formacao cirurgica de face com funil robusto e ofertas premium', 'pendente', 'mentor', 7, 'dossie_auto');

  -- =============================================
  -- FASE 14: Rotina de Acompanhamento e Melhoria Continua (Passo Executivo)
  -- =============================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 5, 'Rotina de Acompanhamento e Melhoria Continua', 'passo_executivo', 14, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES
    (_fase_id, _plano_id, 5, 1, 'Implementar reuniao quinzenal de revisao estrategica com mentor', 'pendente', 'mentor', 1, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 2, 'Acompanhar KPIs semanais: leads, agendamentos, fechamentos, faturamento consultorio, vendas formacao', 'pendente', 'mentorado', 2, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 3, 'Revisar e atualizar conteudo editorial mensalmente com base em performance', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 4, 'Coletar feedback dos alunos apos cada turma e iterar produto', 'pendente', 'mentorado', 4, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 5, 'Manter banco de provas sociais atualizado (novos cases, depoimentos, resultados)', 'pendente', 'mentorado', 5, 'dossie_auto'),
    (_fase_id, _plano_id, 5, 6, 'Avaliar novas oportunidades: locacao de centro cirurgico como produto B2B, expansao de ofertas complementares', 'pendente', 'mentor', 6, 'dossie_auto');

END $$;

-- ===== MENTORADO: TATIANA CLEMENTINO (id=38) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (38, 'PLANO DE AÇÃO v2 | TATIANA CLEMENTINO', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- =====================================================
  -- FASE 1: Revisão do Dossiê Estratégico
  -- =====================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Ler dossiê completo e assimilar todo o contexto estratégico', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Validar produto principal: Programa Full Decade (Observing + Mentoria)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Confirmar posicionamento como Especialista em Full Face (não só lábios)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Revisar storytelling pessoal e validar narrativa de superação', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Alinhar metas: R$ 150–200k/mês somando consultório + produto digital', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- =====================================================
  -- FASE 2: Definição e Estruturação da Oferta
  -- =====================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Definição e Estruturação da Oferta Full Decade', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Finalizar formato da oferta: Observing R$15k à vista / R$20k parcelado', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Estruturar upsell Prática Assistida VIP: R$20k à vista / R$25k parcelado', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Definir turma reduzida: máximo 4 alunos por imersão', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Organizar logística dos 2 dias presenciais em Brasília', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Definir estrutura da Mentoria de Consolidação de 3 meses (6 encontros quinzenais)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 38, 6, 'Estruturar conteúdo programático dos 2 dias de Observação Clínica', 'pendente', 'mentorado', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 38, 1, 'Dia 1 manhã: Leitura tridimensional do rosto, anatomia aplicada e simulação guiada', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 2, 'Dia 1 tarde: Observação clínica ao vivo — Caso 1 com discussão pós-aplicação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 3, 'Dia 2 manhã: As 5 Dimensões (regeneração, estruturação, volumização, modulação, lapidação)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 4, 'Dia 2 tarde: Observação clínica ao vivo — Caso 2 com comparação de perfis', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 5, 'Bônus Dia 2: Técnica Avançada de Lábios — Método Noruega', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- =====================================================
  -- FASE 3: Posicionamento e Identidade Digital
  -- =====================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Posicionamento e Identidade Digital', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Atualizar bio do Instagram com uma das 6 opções sugeridas no dossiê', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Reordenar destaques no Instagram seguindo estrutura: Quem Sou → Full Decade → Lábios Noruegueses → Resultados', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Criar os 3 posts fixados: Apresentação/Autoridade, Full Decade, Antes & Depois', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Ajustar foto de perfil com aproximação do rosto (70–80%) e versão com jaleco premium', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Criar destaque "Quem Sou" com formação, doutorado Munique, Ex-Speaker Galderma e Noruega', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 6, 'Criar destaque "Full Decade" com apresentação do Protocolo Década e as 5 camadas', 'pendente', 'mentorado', 6, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 7, 'Criar destaque "Lábios Noruegueses" com Técnica Julie Horn e exemplos de resultado natural', 'pendente', 'mentorado', 7, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 8, 'Criar destaque "Resultados" organizado por categorias: full face feminino, masculino e lábios', 'pendente', 'mentorado', 8, 'dossie_auto');

  -- =====================================================
  -- FASE 4: Narrativa e Storytelling
  -- =====================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Narrativa, Storytelling e Autoridade', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Adaptar storytelling base para vídeo de apresentação pessoal (90s)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Criar carrossel "20 Anos Injetando: O Que Mudou?" com jornada desde 2008', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Gravar vídeo "Noruega: A Viagem Que Mudou Tudo" com Julie Horn e técnica de lábios', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Criar carrossel "4 Anos na Alemanha: O Que Aprendi" com doutorado em Munique', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Gravar vídeo "Zero Processos em 20 Anos" com tema ética, resultado e confiança', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 6, 'Criar série de conteúdo sobre carreira: congress Galderma, bastidores de speaker internacional', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 38, 7, 'Adaptar storytelling para formatos digitais usando prompt do ChatGPT do dossiê', 'pendente', 'mentorado', 7, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 38, 1, 'Adaptar storytelling para post de feed mantendo tom humano e maduro', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 2, 'Adaptar storytelling para roteiro de Reels (60-90s)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 3, 'Adaptar storytelling para página de vendas do Full Decade', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 4, 'Adaptar storytelling para anúncios de conversão (profissionais)', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- =====================================================
  -- FASE 5: Calendário Editorial e Produção de Conteúdo
  -- =====================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Calendário Editorial e Produção de Conteúdo', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Implementar calendário editorial híbrido: Dom Lifestyle → Seg Autoridade → Ter Desejo → Qua Prova Social → Qui Infovendas → Sex Prova Dinâmica → Sáb Identificação', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Gravar conteúdos de oportunidade de mercado: "A Cirurgia Plástica Cresceu. E Agora?"', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Criar carrossel "Aperfeiçoamento vs Nova Técnica" com comparativo profissional A vs B', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Gravar vídeo "Por Que Você Tem Medo de Cobrar Caro?" com tese de segurança técnica = vendas', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Criar carrossel "Por Que Meus Pacientes Estão Há 10 Anos Comigo?" com Protocolo Década', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 6, 'Criar carrossel educativo "As 5 Camadas: Explicação Completa" com método tridimensional', 'pendente', 'mentorado', 6, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 7, 'Gravar vídeo "Por Que Você NÃO Vê Onde Eu Preenchi?" com pontos invisíveis estratégicos', 'pendente', 'mentorado', 7, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 8, 'Criar carrossel "A Combinação Hidroxiapatita + Sculptra" com gráfico temporal de resultado', 'pendente', 'mentorado', 8, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 38, 9, 'Produzir conteúdo de prova social organizado por categorias de casos', 'pendente', 'mentorado', 9, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 38, 1, 'Criar Reels antes/depois de Full Face Feminino (5-6 casos com idade e tempo de tratamento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 2, 'Criar Reels antes/depois de Full Face Masculino (3-4 casos com diferencial masculino)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 3, 'Criar Reels antes/depois de Lábios Naturais com Técnica Norueguesa (3-4 casos)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 4, 'Criar Reels "3 Ângulos" mostrando resultado frontal, 3/4 e perfil', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 5, 'Publicar stories diários de resultados: Seg lábios, Ter full face, Qua masculino, Qui olhar, Sex pele', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- =====================================================
  -- FASE 6: Estruturação do Produto Full Decade
  -- =====================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Estruturação do Produto Full Decade — Método 5 Dimensões', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Estruturar Pilar 1 — Regeneração Profunda: combinação Hidroxiapatita + Sculptra', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Estruturar Pilar 2 — Estruturação Invisível: pontos estratégicos escondidos e lifting sem corte', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Estruturar Pilar 3 — Volumização Estratégica: acolchoado uniforme e reposicionamento', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Estruturar Pilar 4 — Modulação Neurotoxinas: lifting com toxina e miomodulação', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Estruturar Pilar 5 — Lapidação & Textura: peptídeos injetáveis e protocolo de pálpebras exclusivo', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 6, 'Criar módulo de Integração: como as 5 dimensões conversam e sequência personalizada por caso', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 38, 7, 'Criar aulas usando Prompt de Criação de Aula do dossiê (10 campos + 10 módulos estruturados)', 'pendente', 'mentorado', 7, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 38, 1, 'Preencher campos do prompt: Tema, Objetivo Clínico, Erro do Mercado, Risco, Caso-Base', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 2, 'Preencher campos do prompt: Limite Clínico, Decisão Milimétrica, Erro Crítico, Integração Facial, Ação Prática', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 3, 'Gerar aula no ChatGPT e ajustar nuances pessoais da Tati', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 4, 'Repetir processo para cada pilar das 5 dimensões', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 8, 'Criar ferramentas de apoio: Protocolo de Timing, Mapa de Zonas, Checklist de Segurança, Scripts', 'pendente', 'mentorado', 8, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 9, 'Organizar módulo de casos complexos: rostos jovens, maduros, assimetrias, masculinos, correções', 'pendente', 'mentorado', 9, 'dossie_auto');

  -- =====================================================
  -- FASE 7: Estruturação do Curso de Lábios — Método Noruega
  -- =====================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Estruturação do Curso Técnica Avançada de Lábios — Método Noruega', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Definir investimento: R$12.000 (ou 6x de R$2.500) para imersão presencial de 1 dia', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Estruturar manhã do curso: Masterclass de Compreensão Milimétrica (08h-12h30)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Estruturar tarde do curso: Prática Supervisionada Individual (14h-18h)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Preparar bônus: Cases Profissionais Prontos Para Usar com autorização de divulgação', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Organizar conteúdo técnico: anatomia labial profunda, mapeamento milimétrico, personalização total', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 6, 'Criar guia de correções avançadas: como resolver lábio mal feito, assimetrias, bico de pato', 'pendente', 'mentorado', 6, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 7, 'Configurar gravação completa com 1 ano de acesso para revisão pós-imersão', 'pendente', 'mentorado', 7, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 38, 8, 'Estruturar formato exclusivo "Mesa Redonda" para demonstração ao vivo', 'pendente', 'mentorado', 8, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 38, 1, 'Posicionar paciente modelo ao centro com alunos em círculo ao redor', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 2, 'Conduzir análise completa ANTES de tocar: discussão de raciocínio com alunos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 3, 'Explicar decisão milimétrica passo a passo durante aplicação completa', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 4, 'Abrir perguntas durante todo o processo de execução', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- =====================================================
  -- FASE 8: Captação de Pacientes Modelo
  -- =====================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Captação de Pacientes Modelo para os Cursos', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Receber e revisar modelos de anúncios de captação de pacientes do dossiê (5 modelos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Criar anúncio "Vaga Exclusiva: Paciente Modelo para Protocolo Década" com desconto de 50%', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Criar anúncio foco em "Oportunidade Única: Paciente Modelo — Harmonização Labial"', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Definir critérios de seleção: mulheres 35–55 anos, disponíveis para fotos e retornos', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Publicar anúncios no Instagram e Facebook Ads conforme referências do dossiê', 'pendente', 'mentorado', 6, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 6, 'Selecionar e confirmar 2 pacientes modelo por imersão do Full Decade', 'pendente', 'mentorado', 7, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 7, 'Documentar casos fotograficamente para compor portfólio profissional e conteúdo', 'pendente', 'mentorado', 8, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 38, 1, 'Explorar parcerias locais estratégicas para indicação de pacientes modelo', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 38, 1, 'Mapear cabeleireira de salão premium com clientela alinhada ao público da Tati', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 2, 'Propor parceria de indicação mútua com profissionais complementares', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 3, 'Verificar contatos internacionais: Dubai (estética) e Tônia Beauty Miami', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- =====================================================
  -- FASE 9: Funil de Reaquecimento e Conversão da Base
  -- =====================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Funil de Reaquecimento e Conversão da Base de Alunos', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Mapear e separar lista de leads (interessados anteriores) em planilha de controle', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Mapear e separar lista de ex-alunos em planilha separada', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Identificar grupos de Odontologia e HOF em Brasília para ativação', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Ativar lista de leads com mensagem personalizada (texto + áudio conforme script do dossiê)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Ativar lista de ex-alunos com mensagem de upsell e convite exclusivo', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 6, 'Ativar grupos de Odontologia/HOF com case clínico de rejuvenescimento estrutural', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 38, 7, 'Executar Etapa 2: Conversas no Privado com qualificação e agendamento de ligação', 'pendente', 'mentorado', 7, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 38, 1, 'Responder em até 2 horas após cada contato recebido', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 2, 'Fazer pelo menos 3 perguntas de qualificação por conversa', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 3, 'Nunca mencionar o programa espontaneamente nas mensagens iniciais', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 4, 'Propor ligação rápida de 15-20 min e enviar link de agendamento', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 5, 'Anotar perfil e status de cada lead na planilha de controle', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 38, 8, 'Executar Etapa 3: Ligação de Qualificação (15-20 min)', 'pendente', 'mentorado', 8, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 38, 1, 'Criar rapport e diagnosticar situação atual: prática, resultados, abordagem clínica', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 2, 'Entender resultado desejado e identificar gap entre onde está e onde quer chegar', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 3, 'Propor call de venda de 40-50 min e enviar link de agendamento', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 4, 'Anotar palavras exatas do lead para usar na ancoragem da call de venda', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- =====================================================
  -- FASE 10: Call de Venda e Fechamento
  -- =====================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Call de Venda, Fechamento e Upsell', 'passo_executivo', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Executar abertura da call com quebra-gelo e antecipação da estrutura da conversa', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Realizar diagnóstico profundo: dor raiz, barreira, desejo e urgência do lead', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Agitar consequência de não agir: ciclo de resultados medianos e competição por preço', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Apresentar Full Decade pelos 3 pilares: Raciocínio Clínico, Observação Real e Consolidação', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Fazer ancoragem de valor antes de revelar preço (R$40k+ em componentes separados)', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 6, 'Revelar investimento e fazer silêncio estratégico após o preço', 'pendente', 'mentorado', 6, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 7, 'Tratar objeções com perguntas (caro, preciso pensar, já fiz curso, não tenho dinheiro)', 'pendente', 'mentorado', 7, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 8, 'Apresentar upsell Prática Assistida VIP após fechar o Observing', 'pendente', 'mentorado', 8, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 38, 9, 'Executar follow-up pós-call para leads que não fecharam na hora', 'pendente', 'mentorado', 9, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 38, 1, 'Enviar mensagem D+1 referenciando o que o lead disse que fez mais sentido', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 2, 'Enviar mensagem D+3 perguntando o que falta para ter certeza', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 3, 'Enviar mensagem de confirmação e próximos passos imediatamente após pagamento confirmado', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- =====================================================
  -- FASE 11: Estratégia de Anúncios Pagos e Reaquecimento
  -- =====================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Estratégia de Anúncios Pagos e Reaquecimento de Base', 'fase', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Executar Fase 1 do funil: Reaquecimento de 3–4 semanas com conteúdo estratégico no Instagram', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Criar anúncios pagos de posicionamento: cases, Protocolo Década e nova narrativa de especialista', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Executar Fase 2: Anúncios pagos de conversão após reaquecimento da audiência', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Criar anúncio com gancho: "Por que você tem medo de cobrar R$40.000?" direcionado para profissionais', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Criar anúncio com prova: resultado Full Decade + depoimento de ex-aluno', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 38, 6, 'Pesquisar com amigas do mercado sobre formato "observe-se / limitação de mão"', 'pendente', 'mentorado', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 38, 1, 'Perguntar para ~10 profissionais sobre preferência: observe-se / prática limitada / mão na massa', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 2, 'Coletar feedback e consolidar dados para decisão de formato final do curso', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 3, 'Voltar com resultado da pesquisa para grupo da mentoria', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- =====================================================
  -- FASE 12: Expansão do Consultório e Mercado Masculino
  -- =====================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Expansão do Consultório Boutique e Mercado Masculino', 'fase', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Aumentar proporção de cases masculinos no conteúdo (diferencial: homens têm menos medo de procedimentos)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Criar carrossel "O Mercado Masculino Que Você Está Ignorando" com dados de crescimento 300%', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Documentar casos masculinos do consultório para construção de portfólio especializado', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Implementar gestão de tráfego para aquisição de novos pacientes no consultório', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Incluir progressivamente mais cases de full face feminino para transição do posicionamento', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 6, 'Manter lábios como diferencial/bônus estratégico, não como foco principal da comunicação', 'pendente', 'mentorado', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 38, 7, 'Considerar benchmark estratégico do concorrente Igor para entender objeções e dinâmica', 'pendente', 'mentorado', 7, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 38, 1, 'Avaliar participação incógnita no curso do Igor para entender dinâmica e objeções do público', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 2, 'Fazer networking estratégico no evento para ampliar rede de contatos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 3, 'Usar insights do benchmark como empoderamento e diferenciação da oferta', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- =====================================================
  -- FASE 13: Nome, Branding e Estrutura do Programa
  -- =====================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Nome, Branding e Estrutura Administrativa do Programa', 'fase', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Finalizar nome oficial do programa (Full Decade já validado, confirmar registro)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Definir data e logística da primeira turma (local em Brasília, horários, recepção)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Estruturar aquecimento de base nas semanas que antecedem a abertura de inscrições', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Criar página de vendas do Full Decade usando pitch de apresentação do dossiê', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Organizar cases masculinos e femininos para base de conteúdo do pré-lançamento', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 6, 'Configurar WhatsApp Business com notificações ativas para gestão de leads', 'pendente', 'mentorado', 6, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 7, 'Call com time da mentoria para alinhar plano de conteúdo e cronograma de lançamento', 'pendente', 'mentorado', 7, 'dossie_auto');

  -- =====================================================
  -- FASE 14: Métricas, Revisão e Escalonamento
  -- =====================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 38, 'Métricas, Revisão Mensal e Escalonamento', 'passo_executivo', 14, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 38, 1, 'Monitorar taxa de resposta das listas: meta 40–60% leads / 60–80% ex-alunos / 10–20% grupos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 2, 'Monitorar conversão de conversas para ligação: meta 40–50%', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 3, 'Monitorar conversão de ligação para call de venda: meta 50–65%', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 4, 'Monitorar conversão de call para venda fechada: meta 30–50%', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 5, 'Revisar faturamento mensal: meta R$80–100k consultório + produto digital escalando', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 6, 'Participar dos encontros semanais de mentoria (terça-feira)', 'pendente', 'mentorado', 6, 'dossie_auto'),
  (_fase_id, _plano_id, 38, 7, 'Planejar cursos satélites futuros: "Lábios Noruegueses Avançado", "Década Full Face" separado', 'pendente', 'mentorado', 7, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 38, 8, 'Avaliar expansão internacional após consolidação no Brasil', 'pendente', 'mentorado', 8, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 38, 1, 'Retomar contato com profissional de estética de Dubai para explorar possibilidades', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 2, 'Contatar Tônia Beauty em Miami para entender estrutura e possibilidades de parceria', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 38, 3, 'Avaliar viabilidade de turma internacional do Full Decade (Portugal/Europa como mercado)', 'pendente', 'mentorado', 3, 'dossie_auto');

END $$;

-- ===== MENTORADO: ROSALIE MATUK (id=135) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (135, 'PLANO DE AÇÃO v2 | ROSALIE MATUK', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- ==========================================================
  -- FASE 1: Revisão do Dossiê Estratégico
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 1, 'Ler a seção de Contexto Analisado e validar dados da expert (Rosalie, cirurgiã plástica, Vitória/ES)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 2, 'Revisar o Storytelling completo: 9 marcos desde a faculdade até a mentoria, validar tom e autenticidade', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Revisar seção de Público-Alvo: cirurgiões plásticos com clínica ativa faturando R$70k–R$150k/mês', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Revisar Tese do Produto e Oferta: Mentoria de Gestão Comercial de Ponta a Ponta, 3 pilares, ticket R$15k', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Revisar Conteúdo Programático e Arquitetura de Produto: 3 pilares + 4 bônus + jornada de 6 meses', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 6, 'Revisar Concorrentes, Lacunas de Mercado e Posicionamento estratégico da Rosalie frente aos grupos de WhatsApp', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ==========================================================
  -- FASE 2: Definição e Validação do Posicionamento
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Definição e Validação do Posicionamento', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Definir o nome oficial da mentoria (atualmente sem nome — "NOME A DEFINIR" no dossiê)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Listar 5 opções de nome que comuniquem processo comercial para médico', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Validar opções com equipe CASE e escolher nome definitivo', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Registrar nome escolhido em todos os materiais de vendas', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 2, 'Confirmar posicionamento: "Gestão Comercial de Ponta a Ponta para médicos com clínica ativa" — NÃO "gestão genérica"', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Confirmar com Rosalie disponibilidade semanal para dedicação à mentoria (item pendente no dossiê)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Levantar dados pendentes do dossiê: faturamento mensal, número de procedimentos/mês, ticket médio e taxa de conversão da clínica', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Confirmar quantidade de unidades da Mad Consulta (3 ou 4 shoppings — divergência no dossiê) para uso correto no storytelling', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ==========================================================
  -- FASE 3: Construção do Storytelling e Comunicação de Autoridade
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Construção do Storytelling e Comunicação de Autoridade', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Gravar vídeo de apresentação do storytelling base (9 marcos) para uso em página de vendas e Instagram', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Preparar roteiro com os 9 marcos do dossiê (faculdade → tombo R$400k → clínica própria → IA)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Gravar versão curta (90s) para Reels/Instagram e versão longa (5-7min) para página de vendas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Revisar com equipe CASE e ajustar tom — médica falando para médico, não coach', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 2, 'Criar post/conteúdo sobre o marco do tombo de R$400.000 na Mad Consulta: "cada erro virou um checklist"', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Criar conteúdo sobre o marco da validação do contador: "nenhum médico mandava documentos organizados como você"', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Criar conteúdo sobre o marco do Leonardo e o fechamento na consulta: "brinco que meu marido é meu primeiro cliente a quebrar objeções"', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Mapear as 11 crenças-mãe do dossiê e criar calendário de conteúdo baseado nelas (1 crença por semana de conteúdo)', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 6, 'Atualizar bio do Instagram (@dra.rosalietorrelio) para comunicar mentoria — reposicionamento gradual conforme dossiê', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ==========================================================
  -- FASE 4: Estratégia de Aquisição e Funil de Validação Offline
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Estratégia de Aquisição e Funil de Validação Offline', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Mapear os grupos de WhatsApp de cirurgiões plásticos (Marcelo Ono, Daniel Botelho, Heloisa Manfrim, Cintia Rios, Argoplasma) e listar os 1.000+ contatos disponíveis', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Listar todos os grupos ativos com número de membros e nível de engajamento', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Identificar os 30-50 contatos mais estratégicos para abordagem direta de pré-venda', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Estruturar funil de Aula Zoom para validação offline — benchmark: 18 participantes, 8 compradores (44% conversão) no caso de referência do dossiê', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Criar convite para aula Zoom de 60-90min sobre gestão comercial para médicos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Definir tema da aula que valide a dor central: "Por que sua clínica perde pacientes da porta para dentro"', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Disparar convite nos grupos de WhatsApp e para os contatos diretos', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 4, 'Realizar aula Zoom e fazer transição para oferta da mentoria', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Ativar contador como canal de indicação — empacotar proposta de playbook de POPs para apresentar aos clientes médicos do contador', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Mapear convites para aulas sobre feridas complexas e queimaduras como oportunidade de apresentar mentoria ao final', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Construir lista de interessados qualificada com no mínimo 50 contatos antes do lançamento oficial', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ==========================================================
  -- FASE 5: Produção dos Materiais de Vendas
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Produção dos Materiais de Vendas', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Criar página de vendas da mentoria com o copy da jornada longa aprovado no dossiê', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Adaptar o copy da jornada do dossiê para formato de página de vendas (seções: para quem é, 3 pilares, bônus, investimento)', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Incluir âncora de preço: R$16.000 (soma dos módulos separados) vs. R$15.000 (mentoria completa)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Revisar com Rosalie e aprovar antes de publicar', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Produzir formulário de diagnóstico individual para pré-onboarding dos mentorados', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Listar os 6 pontos do diagnóstico do dossiê (canais de leads, qualificação, consulta, follow-up, pós-operatório, equipe)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar formulário no Google Forms ou equivalente e testar fluxo de preenchimento', 'pendente', 'equipe_spalla', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Criar apresentação de vendas (deck) para a aula Zoom de validação — estrutura: dor → autoridade → método → oferta', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Criar documento de ancoragem de preço com comparativo (consultoria comercial + treinamento de equipe + consultoria de experiência = R$16k separados)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Definir e criar proposta de turma fundadora: preço de fundador R$12.000 à vista / R$15.000 parcelado, turma de 5-8 médicos', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ==========================================================
  -- FASE 6: Estruturação do Conteúdo Programático — Pilar 1 (Funil e Visão Estratégica)
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Estruturação do Conteúdo — Pilar 1: Funil e Visão Estratégica', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Produzir aula sobre os 3 funis essenciais da clínica médica: entrada, fechamento pós-consulta e reativação de base', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Roteirizar aula com exemplos reais da clínica da Rosalie (3.000 leads na etapa perdida, CRM Ramper)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar template de Mapa de Funil Comercial para Clínica Médica (entregável do Pilar 1)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Criar Dashboard de Métricas Essenciais em planilha (taxa de agendamento, conversão, no-show, fechamento)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 2, 'Produzir aula sobre implementação do CRM Ramper: configuração de funis, etapas e rotina de atualização diária', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Criar guia de benchmarks de conversão por etapa para clínicas médicas (baseado nos dados reais da clínica da Rosalie)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Criar modelo de funis pré-configurados para CRM da clínica médica (entregável para o mentorado implementar)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Fechar parceria com empresa de CRM para onboarding e suporte dedicado aos mentorados', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ==========================================================
  -- FASE 7: Estruturação do Conteúdo Programático — Pilar 2 (Estrutura e Equipe Comercial)
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Estruturação do Conteúdo — Pilar 2: Estrutura e Equipe Comercial', 'passo_executivo', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Produzir aula sobre perfil de contratação do Comercial 1 (SDR): o que buscar, o que evitar, como avaliar na entrevista', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Criar Job Description do Comercial 1 (modelo pronto para adaptar — entregável do Pilar 2)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar checklist de onboarding documentado (o que o novo membro precisa saber no dia 1, 7 e 30)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Produzir scripts completos para todas as etapas do funil: primeiro contato, qualificação, agendamento, objeções e follow-up', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Script de triagem e pré-atendimento (WhatsApp e ligação) — por etapa do funil', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Script de qualificação (identificar se o lead tem fit para consulta paga antecipadamente)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Scripts de agendamento com confirmação e redução de no-show', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Produzir e documentar o Programa de Premiação Jurídico para time comercial (Bônus 3) — adaptar documento feito com advogado', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Criar modelo de rotina de acompanhamento semanal do time comercial (checklist de gestão sem microgerenciar)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Criar modelo de metas de conversão por etapa do funil com critérios objetivos de elegibilidade ao programa de premiação', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ==========================================================
  -- FASE 8: Estruturação do Conteúdo Programático — Pilar 3 (Consulta que Converte + Fechamento)
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Estruturação do Conteúdo — Pilar 3: Consulta que Converte e Fechamento', 'passo_executivo', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Produzir aula sobre o roteiro completo de consulta: conexão → queixa → diagnóstico → plano de tratamento → apresentação do valor → negociação', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Criar template de roteiro de consulta em etapas (adaptável por tipo de procedimento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar script de apresentação de preço e negociação pelo médico na consulta', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Criar modelo de plano de tratamento físico que ancora valor e profissionalismo (documento físico entregue na consulta)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 4, 'Criar modelo de handoff médico → Comercial 2 para fechamento burocrático (contrato, entrada, pagamento)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Produzir aula sobre a cadência de 5 follows pós-consulta: depoimento, foto, áudio, conversa, escassez', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Criar cadência de follow-up (5 passos) com scripts, timing e canal definido para cada mensagem', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar scripts das 10 objeções mais comuns: tempo, dinheiro, "não estou pronta", "vou pensar", medo do procedimento, entre outras', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Configurar 2 follows automatizados no CRM + templates para os 5 follows humanizados', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Criar régua de resgate de leads antigos para ativar os 3.000 leads na etapa "perdida" do CRM Ramper', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Criar modelo de contrato de entrada e processo de recebimento de sinal para padronizar fechamentos', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ==========================================================
  -- FASE 9: Produção dos Bônus — Experiência Premium e Blindagem da Entrega
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Produção dos Bônus: Experiência Premium e Blindagem da Entrega', 'passo_executivo', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Produzir Bônus 1 — Experiência Premium: roteiro de acompanhamento pré-consulta e checklist de percepção de experiência', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Criar roteiro de acompanhamento pré-consulta (dia do agendamento → 48h antes → dia anterior → dia da consulta)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar scripts de confirmação e redução de no-show por canal (WhatsApp, ligação)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Criar checklist de percepção de experiência: espaço físico, imagem pessoal do médico, atendimento da recepção', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Produzir Bônus 2 — Blindagem da Entrega: protocolo de pós-operatório semana a semana do dia da alta aos 90 dias', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Documentar protocolo completo de pós-operatório da clínica (hiperbárica, suplementação, laser, placa, e-book de 10 páginas, vídeos, música personalizada)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar sequência de contato com o paciente no primeiro mês pós-cirurgia com scripts por canal', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Criar checklist de segurança clínica e jurídica para proteção do médico (documentação, consentimentos, orientações escritas)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 4, 'Criar processo de indicação orgânica ativa — quando e como acionar o paciente para pedir indicação', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Produzir Bônus 4 — Sessão de Diagnóstico Individual 1:1: criar estrutura de análise de 60 minutos com Rosalie para cada mentorado', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Criar e-book de orientações pós-operatórias (base para os mentorados adaptarem ao próprio procedimento)', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ==========================================================
  -- FASE 10: Reposicionamento do Instagram e Presença Digital
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Reposicionamento do Instagram e Presença Digital', 'fase', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Definir estratégia de reposicionamento gradual do Instagram @dra.rosalietorrelio para comunicar mentoria (sem abandonar identidade de cirurgiã)', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Atualizar bio para incluir posição de mentora de gestão comercial para médicos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar destaque no Instagram dedicado à mentoria e ao método', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Planejar mix de conteúdo: 60% clínica/cirurgia + 40% gestão e mentalidade médica', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 2, 'Criar calendário de conteúdo semanal baseado nas 11 crenças-mãe do dossiê (1 crença por semana)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Produzir Reel sobre a frase "Você pensa que precisa de mais marketing. O problema está na porta para dentro" — conteúdo de maior impacto do dossiê', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Produzir Reel sobre o marco do Leonardo: "Brinco que meu marido é meu primeiro cliente a quebrar objeções" — prova de autoridade + storytelling', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Definir estratégia de collabs com blogueiras e influenciadoras do ES para ampliar alcance — já usado na clínica', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 6, 'Planejar retomada gradual de tráfego pago (superar trauma relatado no dossiê): começar com boost de melhores orgânicos, não com campanhas frias', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  -- ==========================================================
  -- FASE 11: Pesquisa e Análise de Concorrentes
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Pesquisa e Análise de Concorrentes', 'fase', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Realizar pesquisa real dos 5 concorrentes mapeados no dossiê (todos atualmente com dados inferidos — urgente preencher)', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Pesquisar Marcelo Ono (@marcelo_ono, 176k seguidores): verificar se tem curso, mentoria ou apenas grupo de WhatsApp', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Pesquisar Daniel Botelho (@danielbotelhoplastica, 321k seguidores): mapear esteira completa além do grupo de WhatsApp', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Pesquisar Cintia Rios (@dracintiarios, 153k seguidores): verificar profundidade do curso e se tem acompanhamento individualizado', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 4, 'Pesquisar Heloisa Manfrim (@plasticaetal, 215k seguidores): verificar se tem produto estruturado além do grupo', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 5, 'Pesquisar Marcia, Barbara e Marcio (Diretores de Negócios): mapear ticket, funil e diferencial da imersão presencial', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 2, 'Solicitar a Rosalie que envie perfis/links dos concorrentes para pesquisa real (item urgente apontado no dossiê)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 3, 'Atualizar seção de concorrentes do dossiê com dados reais (substituir os dados inferidos/lacunados)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Documentar lacunas de mercado confirmadas após pesquisa real para reforçar o diferencial da Rosalie no posicionamento', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  -- ==========================================================
  -- FASE 12: Estrutura Operacional da Mentoria
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Estrutura Operacional da Mentoria', 'passo_executivo', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Definir calendário completo dos 12 encontros quinzenais de 90 minutos para a primeira turma de 6 meses', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Bloquear datas na agenda da Rosalie para os 12 encontros e aulas ao vivo (turma fundadora)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Definir dia e horário fixo quinzenal (considerar agenda médica e disponibilidade dos mentorados)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Criar cronograma das 3 etapas: Fundação (Pilares 1-2) → Consulta e Fechamento (Pilar 3) → Consolidação (Bônus 2)', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Criar contrato de mentoria para assinatura dos mentorados na entrada', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Rascunhar cláusulas principais: prazo 6 meses, valor, condições de pagamento, entregáveis e responsabilidades', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Revisar contrato com advogado e aprovar versão final', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Configurar grupo exclusivo no WhatsApp para suporte entre encontros — criar regras de uso e boas-vindas', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Criar biblioteca de templates e materiais (scripts, roteiros, checklists do dossiê) e organizar no repositório compartilhado', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 5, 'Definir plataforma de entrega das aulas gravadas para turmas futuras (a partir da turma 2)', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  -- ==========================================================
  -- FASE 13: Integração com IA — Diferencial Tecnológico da Mentoria
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Integração com IA — Diferencial Tecnológico da Mentoria', 'passo_executivo', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Concluir a integração do agente de IA com o Feegow (em desenvolvimento — desafios técnicos ativos apontados no dossiê)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Mapear os pontos de travamento técnico da integração Feegow e priorizar resolução', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Definir data-alvo para conclusão da integração (NÃO prometer como feature entregue até estar funcionando — alerta do dossiê)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Documentar o agente de IA para SDR como case real para usar na mentoria (diferencial que nenhum concorrente tem)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Usar o agente de IA da clínica da Rosalie como case demonstrativo nas aulas do Pilar 1 (CRM + IA para SDR e agendamento)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Gravar demonstração do agente de IA em funcionamento na clínica (SDR, qualificação, agendamento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Criar módulo opcional de IA para mentorados avançados (implementação após CRM funcionando)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Estruturar script de IA para resgatar os 3.000 leads na etapa "perdida" do CRM Ramper como case de resultado para usar em vendas', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Definir o que ensinar sobre IA na mentoria: princípio "IA num processo vira escala, IA num caos vira mais caos" — crença 7 do dossiê', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ==========================================================
  -- FASE 14: Lançamento da Primeira Turma
  -- ==========================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 135, 'Lançamento da Primeira Turma', 'passo_executivo', 14, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 1, 'Executar pré-venda offline via grupos de WhatsApp de cirurgiões plásticos — validar oferta antes de qualquer tráfego', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Criar mensagem de pré-venda para os grupos de WhatsApp: convite pessoal, sem escala, sem tráfego pago', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Realizar aula Zoom de validação (meta: 15-20 participantes, referência: 18 no caso do dossiê)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Fazer transição da aula para oferta da primeira turma com preço de fundador (R$12k à vista / R$15k parcelado)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 4, 'Fechar primeira turma com 5-8 mentorados qualificados', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 135, 2, 'Fazer onboarding completo da primeira turma: contrato, diagnóstico individual, plano de ação personalizado e acesso aos materiais', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 135, 1, 'Enviar contrato para cada mentorado e confirmar assinatura', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 2, 'Enviar formulário de diagnóstico e analisar individualmente cada caso', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 135, 3, 'Realizar call individual de 60 minutos (Bônus 4) com cada mentorado e entregar plano de ação personalizado', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 135, 3, 'Coletar depoimentos e resultados da primeira turma ao longo dos 6 meses para usar em escala na turma 2', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 135, 4, 'Planejar lançamento da turma 2 após validação do método com a primeira turma — incluir funil de autoridade via Instagram e tráfego', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

END $$;

-- ===== MENTORADO: THIELLY PRADO (id=30) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (30, 'PLANO DE AÇÃO v2 | THIELLY PRADO', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- ============================================================
  -- FASE 1: Revisão do Dossiê Estratégico
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Ler e validar o diagnóstico completo do dossiê com a mentora Queila Trizotti', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Confirmar público-alvo validado: donas de negócios de beleza com 5–15 colaboradores e faturamento entre R$50k–R$200k/mês', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Validar posicionamento estratégico: mentora de liderança, cultura e excelência para empresárias da beleza', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Confirmar produto principal: Mentoria Aura Business (6 meses, R$25k ancoragem / R$20k parcelado / R$15k à vista)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Revisar os 4 pilares do Método Aura Business: Posicionamento Premium, Liderança que Cria Cultura, Experiência 360°, Estratégias de Crescimento', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 2: Estruturação do Posicionamento Digital
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Estruturação do Posicionamento Digital', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Criar novo Instagram estratégico separado do perfil banido (100% dedicado a tráfego e captação de leads)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Escolher nome do novo perfil (opções: @thiellyprado.academy, @thielly.aurabusiness, @thielly.beautyleader)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Configurar foto de perfil: close sofisticado, roupa neutra (preto/bege/branco), fundo claro, expressão de líder confiante', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Escrever bio seguindo estrutura: quem é + o que faz + prova social + CTA filtrado (lista de espera mentoria)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Configurar os 6 destaques essenciais do Instagram (Começar Aqui, Minha História, Liderança & Time, Campanhas & Estratégia, Experiência & Marca, Depoimentos)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Criar destaque "Começar Aqui": mini apresentação, valores e visão', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar destaque "Minha História": trajetória do hospital ao Aura, dor e transformação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Criar destaque "Liderança & Time": rituais de cultura, feedbacks, reuniões com balões', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Criar destaque "Experiência & Marca": atmosfera Aura, detalhes premium, estética sensorial', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 3, 'Criar e fixar os 3 posts estratégicos do perfil (storytelling premium, crenças sobre negócios, apresentação aspiracional da mentoria)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Post fixado 1: storytelling emocional + estratégico (prisão no negócio anterior → renascimento no Aura → liderança e cultura)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Post fixado 2: carrossel provocativo sobre crenças — "Negócio não cresce por mágica. Cresce por estratégia + liderança + cultura."', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Post fixado 3: apresentação aspiracional da mentoria (para quem é, para quem não é, o que transforma)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 4, 'Definir mensagem central da marca pessoal: "Você não cresce por sorte. Você cresce por estratégia + liderança + cultura."', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Usar o perfil banido apenas para collabs e construção de autoridade, nunca para tráfego pago', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 3: Produção da Primeira Leva de Conteúdo
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Produção da Primeira Leva de Conteúdo', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Produzir 15–20 vídeos curtos iniciais (45–60 segundos, estilo conversa espontânea, tom natural e premium)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Vídeo: "O que ninguém te conta sobre liderar um time na beleza"', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Vídeo: "Como eu penso cultura dentro do Aura"', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Vídeo: "A diferença entre equipe e movimento"', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Vídeo: "Por que experiência é mais importante que técnica"', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 5, 'Vídeo: "Erros que quase me fizeram desistir do empreendedorismo"', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 6, 'Vídeo: "A história dos balões e o conceito por trás"', 'pendente', 'mentorado', 6, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 7, 'Vídeo: "O que realmente faz um negócio de beleza crescer"', 'pendente', 'mentorado', 7, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 8, 'Vídeo: "Você sabe a diferença entre gestor e líder?"', 'pendente', 'mentorado', 8, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 9, 'Vídeo: "700 mil de faturamento por mês — os 4 pilares que sustentam isso"', 'pendente', 'mentorado', 9, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Registrar bastidores do aniversário de 3 anos do Aura para usar como primeira leva de conteúdo estratégico', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Filmar time se preparando, balões, estética e atmosfera do evento', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Registrar momentos emocionais da equipe (ritual dos balões com sonhos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Capturar bastidores da criação da experiência (café da manhã, decoração, celebração)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 3, 'Estabelecer ritmo de postagem: 3 a 4 vídeos por semana + 1 carrossel profundo + stories diários com bastidores', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Planejar collabs entre novo IG, perfil principal e Instagram do Aura para amplificar alcance', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Seguir calendário editorial semanal: domingo (desejo/oportunidade), segunda (confiança expert), terça (alcance/descoberta), quarta (infovendas), quinta (desejo), sexta (confiança), sábado (identificação)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 4: Pilar 1 — Posicionamento Premium
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Pilar 1 — Posicionamento Premium', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Mapeamento do cliente ideal de alto padrão', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Listar os 20 últimos clientes e classificar por ticket médio, frequência, indicações e nível de exigência', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Identificar os 5 clientes ideais (pagam bem, voltam sempre, indicam) e criar persona premium com foto e descrição completa', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Criar critérios de aceite para novos clientes e script de recusa educada para perfis fora do padrão', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Auditoria de imagem e identidade visual do negócio', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Fotografar estabelecimento em todos os ângulos e analisar o que comunica valor vs. o que precisa melhorar', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Avaliar apresentação pessoal e uniforme da equipe (alinhamento com padrão premium desejado)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Listar e priorizar 3 melhorias visuais para executar imediatamente (uniforme, iluminação, decoração)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 3, 'Definir o serviço âncora que representa o DNA da marca Aura', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Identificar serviço com maior margem, maior procura e que melhor representa o DNA da marca', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Reformular entrega do serviço âncora: agregar avaliação personalizada, brinde, pós-venda diferenciado', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Criar nome especial e narrativa premium para o serviço assinatura', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 4, 'Reestruturação de precificação consciente e alinhada ao posicionamento premium', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Calcular custo real de cada serviço (produto + tempo + equipe + estrutura)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Pesquisar 3 concorrentes do mesmo padrão desejado (não os mais baratos) como referência', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Definir novos preços baseados em custo + valor percebido + posicionamento desejado, e criar pacotes estratégicos (combos de valor, sem desconto)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 5, 'Criar estratégia de comunicação digital: definir 3 pilares de conteúdo e banco com 20–30 fotos/vídeos para 1 mês', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 5: Pilar 2 — Liderança que Cria Cultura
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Pilar 2 — Liderança que Cria Cultura', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Definir os valores e DNA da marca em documento formal', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Escrever a história da marca: por que criou o Aura, qual era o sonho, o que move até hoje', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Listar 5 valores inegociáveis e 3 comportamentos esperados que os representam na prática', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Apresentar documento de história + valores + comportamentos para toda a equipe em reunião especial', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Reestruturar processo de contratação com foco em fit cultural', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Criar roteiro de entrevista com perguntas de fit cultural (ex: "O que é excelência para você?", "Como você lida com feedback?")', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Definir 3 "sinais vermelhos" que indicam que a pessoa não é certa (ex: falta de pontualidade, resistência a seguir padrões)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Criar checklist de avaliação dos primeiros 30 dias com acompanhamento próximo', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 3, 'Criar rituais e rotinas de cultura fixos', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Definir reunião semanal de alinhamento (15–30 minutos toda segunda de manhã)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar ritual de boas-vindas para novos colaboradores (apresentação à equipe + kit de boas-vindas)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Estabelecer café da manhã mensal (última quarta) onde Thielly abre os números e celebra conquistas coletivas', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Documentar todos os rituais em calendário mensal fixo e compartilhar com a equipe', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 4, 'Estruturar onboarding e treinamento contínuo para novos colaboradores', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Montar roteiro de integração de 7 dias: Dia 1 história da marca + tour; Dias 2–3 shadowing; Dias 4–7 prática supervisionada', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar manual de padrões de atendimento e comportamento (slides ou PDF simples)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Gravar vídeos curtos (3–5 min) ensinando os principais processos do Aura', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Definir "padrinho/madrinha" para cada novo colaborador nos primeiros 30 dias', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 5, 'Implementar sistema de feedback semanal e protocolo de gestão de conflitos', 'pendente', 'mentorado', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Criar hábito de feedbacks semanais rápidos (2–3 minutos por pessoa) com script: reconhecer o bom + apontar melhoria + oferecer apoio', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Estabelecer conversas individuais mensais de 15–20 minutos com cada colaborador', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Criar protocolo de conflitos: conversa individual primeiro, depois mediação se necessário', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 6, 'Definir funções, processos e responsabilidades de cada colaborador com organograma simples', 'pendente', 'mentorado', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Criar organograma simples do negócio e descrição de cargo resumida para cada função (1 página)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Mapear processos do dia a dia (abertura, atendimento, fechamento, limpeza) e delegar responsáveis', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 7, 'Implementar cultura de metas coletivas mensais com acompanhamento semanal e celebração de resultados', 'pendente', 'mentorado', 7, 'dossie_auto');

  -- ============================================================
  -- FASE 6: Pilar 3 — Experiência 360°
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Pilar 3 — Experiência 360°', 'fase', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Mapear a jornada atual da cliente do agendamento ao pós-atendimento', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Percorrer o caminho da cliente: desde agendar no WhatsApp até sair do salão, anotando cada ponto de contato', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Identificar 5 pontos críticos que precisam melhorar (ex: demora na resposta, recepção fria, ambiente bagunçado)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Pedir feedback sincero de 3 clientes fiéis sobre a experiência atual', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Criar ambiência sensorial completa no espaço (olfato, som, iluminação, temperatura, ordem visual)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Escolher aroma exclusivo do espaço (difusor/vela — baunilha, lavanda ou flor de laranjeira como assinatura Aura)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Montar playlist exclusiva no Spotify que transmita a energia do Aura (relaxante, sofisticada, leve)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Ajustar iluminação para tons quentes ou luz natural (evitar luz branca forte), garantir temperatura confortável', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 3, 'Criar rituais de encantamento que geram conexão emocional e tornam o atendimento memorável', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Implementar cappuccino personalizado com nome da cliente como assinatura do Aura', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar ritual de boas-vindas: cumprimentar pelo nome, oferecer bebida personalizada, gesto de acolhimento', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Incluir elemento surpresa durante atendimento (massagem nas mãos, frase inspiradora no espelho, momento de relaxamento)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Documentar todos os rituais para treinamento padronizado da equipe', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 4, 'Padronizar o atendimento em todos os pontos de contato com scripts definidos', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Criar script de atendimento no WhatsApp com a voz da marca (agendamentos, confirmações, dúvidas)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Padronizar recepção: o que falar quando a cliente chega, como cumprimentar, onde levá-la', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Definir ritual de despedida e treinamento de role-play com a equipe para simulações', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 5, 'Implementar estratégia de pós-atendimento que fideliza e converte clientes em promotoras', 'pendente', 'mentorado', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Enviar mensagem personalizada 2–4h após atendimento agradecendo e perguntando como a cliente está se sentindo', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar sistema de follow-up: mensagem de aniversário + lembrete de retorno 15–30 dias depois', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Solicitar indicação de forma natural ao final do atendimento com script definido', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 6, 'Transformar 2–3 cantinhos do salão em pontos instagramáveis para gerar mídia espontânea das clientes', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 7: Pilar 4 — Estratégias de Crescimento
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Pilar 4 — Estratégias de Crescimento', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Ativar as 20 clientes mais fiéis como canal de indicação (campanha estilo "Ação da Pipoca")', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Criar ação de indicação com benefício exclusivo (upgrade gratuito, brinde especial ou experiência VIP)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Comunicar a ação de forma personalizada (mensagem individualizada para cada cliente VIP)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Acompanhar e registrar indicações geradas e conversões em agendamentos', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Mapear e ativar parcerias estratégicas locais com marcas que atendem o mesmo público', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Listar 10 marcas ou profissionais locais com valores alinhados (cafés, lojas de roupa, clínicas, personal trainers)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Selecionar 3 parceiros para contato e propor ação conjunta (evento, sorteio, troca de brindes, co-branding)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 3, 'Criar calendário de campanhas internas mensais para os próximos 6 meses', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Mapear 6 datas estratégicas: Dia das Mulheres, Dia das Mães, Dia dos Namorados, Outubro Rosa, Black Friday (com Aura Day), Natal', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Para cada campanha: definir tema, oferta especial (valor agregado, não desconto), decoração temática e comunicação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Replicar modelo do Aura Day (aniversário do salão): pacotes estratégicos + experiência premium + evento com equipe', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 4, 'Criar pacotes estratégicos de alto valor com nomes atrativos (Aura Day, Dia do Autocuidado, Glow Total)', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Analisar serviços mais procurados juntos e montar 3 combos estratégicos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Precificar pacotes com valor agregado (não desconto): incluir mimo especial ou upgrade', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Criar arte visual premium para cada pacote e divulgá-los como experiências exclusivas', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 5, 'Otimizar agenda e reativar clientes inativas (60+ dias sem visita)', 'pendente', 'mentorado', 5, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Levantar lista de clientes inativas e criar campanha de reativação com mensagem personalizada e incentivo para voltar', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar sistema de lembretes automáticos de retorno (30 dias após último atendimento)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 6, 'Introdução ao tráfego pago estratégico no Instagram/Facebook com foco local', 'pendente', 'mentorado', 6, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Definir objetivo claro do primeiro anúncio (agendamentos, seguidores locais ou brand awareness)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar 1 anúncio simples com orçamento de R$10–20/dia e raio de 5–10km do salão usando conteúdo orgânico de melhor desempenho', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Monitorar resultados por 7 dias: mensagens recebidas, agendamentos, custo por lead', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- ============================================================
  -- FASE 8: Estruturação do Produto Mentoria Aura Business
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Estruturação do Produto Mentoria Aura Business', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Finalizar arquitetura completa do produto Mentoria Aura Business (6 meses, híbrida)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Definir cronograma dos encontros quinzenais online (revisão de resultados, ajustes de rota, planejamento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Planejar Imersão Presencial no Aura (1 dia intensivo de 8h ou 2 dias imersivos de 4–5h cada)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Estruturar grupo exclusivo no WhatsApp com dinâmica de suporte diário', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Criar Kit Completo de Ferramentas de Gestão para entrega às alunas', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Montar templates prontos de gestão de equipe (organograma, descrição de cargos, checklist de onboarding)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar planilhas de controle e indicadores (faturamento, ticket médio, metas, origem de clientes)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Compilar biblioteca de bastidores do Aura e manuais de liderança e processos internos', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Documentar rituais de cultura do Aura aplicáveis a outros negócios (reuniões, balões, café da manhã, celebrações)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 3, 'Criar formulário de diagnóstico individual para aplicar no início de cada mentoria (Mapa Estratégico Aura)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Definir estrutura de entregáveis da mentoria: diagnóstico + encontros quinzenais + suporte diário + imersão presencial + trilhas + ferramentas', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Precificar e documentar as condições de pagamento: R$25k ancoragem / R$20k parcelado / R$15k à vista', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 9: Preparação e Execução do Evento de Lançamento
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Preparação e Execução do Evento de Lançamento', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Definir conceito, nome e data do evento presencial de lançamento (Aura Business Day / Boss Beauty / Master Aura)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Escolher data entre 20 e 31 de janeiro (energia de planejamento do início de ano)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Confirmar local: espaço clean, elegante e minimalista para 20–30 participantes', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Definir meta de vendas para o evento: 5–15 fechamentos', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Montar lista de 80–150 potenciais participantes qualificados (empresárias com equipe e dor de liderança)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Levantar base de clientes VIP do Aura, donas de studio/spa/clínica e profissionais com equipe', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar formulário de qualificação com perguntas: estágio do negócio, tamanho da equipe, maior desafio, objetivo', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 3, 'Estruturar conteúdo e pitch do evento (marcar call de preparação com Queila)', 'pendente', 'mentor', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Bloco 1: História + autoridade + conexão emocional (dores do público + trajetória da Thielly + resultados reais)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Bloco 2: Jornada do cliente + problemas invisíveis + perguntas de interação para gerar consciência de problema', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Bloco 3: Vendas com naturalidade — quebrar crenças, mostrar provas de resultado, instalar nova mentalidade', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Pitch: apresentar oferta, ancoragem de preço (R$50k → R$25k especial), condições e chamada para ação', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 4, 'Divulgação do evento: lista pessoal + Instagram + prospecção ativa com convites individualizados', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Enviar convites via ligação direta, áudio personalizado e mensagem no WhatsApp para lista qualificada', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Publicar no Instagram usando bastidores do aniversário do Aura como gancho de autoridade', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Fazer collabs com perfil do Aura e perfil pessoal para amplificar alcance do evento', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 5, 'Organizar logística do evento: coffee premium, material impresso, time de apoio (recepção + registro + fechamento de vendas)', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 6, 'Executar follow-up com interessados que não fecharam no evento (até 24–48h após) com mensagem personalizada', 'pendente', 'mentorado', 6, 'dossie_auto');

  -- ============================================================
  -- FASE 10: Gestão do Instagram Banido e Transição de Perfil
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Gestão do Instagram Banido e Transição de Perfil', 'fase', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Aceitar que o perfil banido não será usado para tráfego pago (situação quase impossível de reverter sem processo)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Usar perfil banido exclusivamente para collabs com o novo perfil estratégico e construção de autoridade passiva', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Comunicar a transição para seguidores do perfil atual de forma natural, direcionando para o novo perfil', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Garantir que o novo perfil estratégico esteja 100% configurado antes de iniciar tráfego pago', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Monitorar crescimento do novo perfil semanalmente e ajustar estratégia de conteúdo conforme resultados', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 11: Desenvolvimento do Storytelling e Narrativa Pessoal
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Desenvolvimento do Storytelling e Narrativa Pessoal', 'fase', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Sistematizar o storytelling pessoal para uso em conteúdo, eventos e pitches de venda', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Documentar a história do hospital: filha com câncer, venda de perfumes, sobrancelhas para enfermeiras — origem do dom de levantar mulheres', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Descrever a transição: saída da sociedade anterior (12–14h/dia, exaustão, sem paz) para criação do Aura em 20 dias', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Construir narrativa de resultados: 3 anos → 60+ colaboradores → R$700k/mês → parceria com Natália Beauty', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 4, 'Criar versões do storytelling para diferentes contextos: reels curtos (60s), carrosséis, eventos presenciais e pitches', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Treinar a habilidade de ensinar o que faz intuitivamente (transformar "competência inconsciente" em método ensinável)', 'pendente', 'mentor', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Gravar vídeos respondendo: "Por que você faz isso?" para cada prática do Aura (extrair o método intuitivo)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Escrever os critérios de cada decisão estratégica (contratação, campanhas, precificação) de forma didática', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 3, 'Criar banco de conteúdo de roteiros prontos baseados nos ganchos validados (Alcance, Consciência de Problema, Confiança, Desejo, Identificação)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Gravar o vídeo "Profissionais da beleza não são difíceis. Difícil é liderar sem postura." como conteúdo viral de autoridade', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ============================================================
  -- FASE 12: Parceria Estratégica com Natália Beauty
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Parceria Estratégica com Natália Beauty e Network Nacional', 'fase', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 1, 'Alavancar a parceria com Natália Beauty como prova social de autoridade nacional no posicionamento digital', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 2, 'Criar conteúdo sobre a trajetória: de cliente da Natália Beauty a sócia no projeto de transplante de sobrancelhas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Usar o lançamento em São Paulo do projeto de transplante como marco de prova de credibilidade', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Mapear conexões com médicas, esteticistas e empresárias do network da Natália Beauty como potenciais alunas da mentoria', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Identificar oportunidades de collab de conteúdo com parceiros e figuras de autoridade do setor de beleza nacional', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 13: Pós-Validação e Escalabilidade
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Pós-Validação e Escalabilidade da Mentoria', 'fase', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Revisar feedbacks das primeiras alunas e aprimorar a entrega da mentoria', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Criar formulário de satisfação intermediário (mês 3) e final (mês 6) para cada aluna', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Documentar casos de transformação reais para usar como prova social em futuras vendas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Gravar depoimentos em vídeo de alunas satisfeitas (antes/depois de resultados práticos)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 2, 'Aprofundar os pilares da mentoria com base no feedback das alunas e ajustar conteúdo programático', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Revisar e atualizar os 4 pilares (Posicionamento, Liderança, Experiência, Crescimento) com exemplos reais das alunas', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Criar módulo adicional baseado nas dores mais recorrentes identificadas durante a mentoria', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 3, 'Construir funil de conteúdo contínuo para captação de novas turmas (calendário 2025–2026)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Avaliar criação de produtos complementares: Experiência Presencial no Aura (imersão), formatos de grupo menor, e-book de metodologia', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 5, 'Planejar expansão para alcance nacional: parceiros estratégicos, eventos em outras cidades, collab com influenciadoras do setor', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ============================================================
  -- FASE 14: Acompanhamento de KPIs e Ajustes Estratégicos
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 30, 'Acompanhamento de KPIs e Ajustes Estratégicos', 'passo_executivo', 14, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 30, 1, 'Criar dashboard de indicadores de crescimento do Aura e da mentoria', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 30, 1, 'Monitorar mensalmente: faturamento do Aura, ticket médio, novos clientes, clientes inativos recuperados', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 2, 'Monitorar crescimento do Instagram: seguidores, alcance, engajamento, DMs de potenciais alunas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 30, 3, 'Rastrear funil de vendas da mentoria: leads qualificados → evento → vendas → taxa de conversão', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 30, 2, 'Realizar revisão estratégica mensal com a mentora Queila para ajustar rotas e prioridades', 'pendente', 'mentor', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 3, 'Documentar aprendizados, erros e acertos de cada campanha e ação executada para construção do método pessoal', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 30, 4, 'Celebrar marcos atingidos com a equipe do Aura (reforçar cultura de reconhecimento e pertencimento)', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;

-- ===== MENTORADO: THIAGO KAILER (id=148) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (148, 'PLANO DE AÇÃO v2 | THIAGO KAILER', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- ========================================
  -- FASE 1: Revisão do Dossiê Estratégico
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 1, 'Reler o contexto analisado e validar as 3 frentes estratégicas (Fase 1: Ígnea Agro, Fase 2: marca pessoal, Fase 3: Axioma)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 2, 'Revisar e internalizar os 6 marcos de autoridade na sequência narrativa definida no dossiê', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 3, 'Revisar análise de concorrentes (Rogério Augusto, Produtor Sem Dívida, Deyse Amaral, João Domingos, Sérgio Henrique Agro, Douglas Duek) e mapear lacunas de mercado', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Revisar os storytellings de Produtor Rural e Mercado Geral e identificar qual tom usar em cada canal', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 5, 'Revisar os públicos-alvo mapeados (Produtor Rural, Mercado Geral, Profissional) e confirmar prioridade da Fase 1', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 6, 'Revisar a tese, a oferta e o pitch de vendas da Ígnea Agro e validar com mentor', 'pendente', 'mentorado', 6, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 7, 'Revisar o conteúdo programático dos 4 movimentos e o processo operacional completo', 'pendente', 'mentorado', 7, 'dossie_auto');

  -- ========================================
  -- FASE 2: Empacotamento da Consultoria Ígnea Agro
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Empacotamento da Consultoria Ígnea Agro', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Definir nome oficial da consultoria (campo "[DEFINIR NOME]" ainda em aberto no dossiê)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Gerar lista de opções de nome para o produto de mapeamento estratégico', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Validar nome com mentor e alinhar com identidade da marca Ígnea Agro', 'pendente', 'mentor', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Registrar nome escolhido e atualizar todos os materiais do dossiê', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Finalizar e documentar a proposta comercial com faixas de investimento por tamanho de dívida (R$30K / R$50K / R$90K)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar tabela de preços formalizada com as 3 faixas de dívida (R$3M-R$10M, R$10M-R$20M, acima de R$20M)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Documentar mecanismo de abate: consultoria abatida dos honorários advocatícios ao contratar TK Advogados', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Criar script de qualificação para filtrar leads por tamanho de dívida e perfil de produtor', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 3, 'Criar e formatar os 3 bônus da consultoria (Guia do Banco, Glossário de Dívidas Agro, Checklist do Advogado)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Redigir e formatar Bônus 1 — Guia: Como Ler o que o Banco Pensa do Seu Caso (valor percebido R$5.000)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Redigir e formatar Bônus 2 — Glossário do Mercado de Dívidas Agro (valor percebido R$3.000)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Redigir e formatar Bônus 3 — Checklist: O que Avaliar Antes de Assinar com Advogado (valor percebido R$2.000)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 4, 'Criar templates operacionais: Formulário de Diagnóstico, Mapa Estratégico, Matriz de Riscos e Estratégia Recomendada', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar Formulário de Diagnóstico estruturado (contratos, volumes, credores, processos em andamento)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Criar template base do Mapa Estratégico de Endividamento (PDF personalizado por caso)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Criar template da Matriz de Riscos por Cenário (planilha + PDF com melhor/pior caso)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 4, 'Criar template da Estratégia Recomendada Documentada (plano de ação com timing e prioridades)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 5, 'Redigir e assinar contrato de consultoria padrão para a Ígnea Agro (digital ou presencial)', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 6, 'Definir fluxo interno de análise com o time do escritório para o Movimento 2 (quem faz o quê nos bastidores)', 'pendente', 'mentorado', 6, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 7, 'Definir calendário de disponibilidade com slots para os encontros das consultorias', 'pendente', 'mentorado', 7, 'dossie_auto');

  -- ========================================
  -- FASE 3: Infraestrutura Digital e Canais de Captação
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Infraestrutura Digital e Canais de Captação', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Configurar canal de WhatsApp da Ígnea Agro com mensagem de boas-vindas padrão e script de primeiro contato', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar mensagem de boas-vindas automática para leads que chegam pelo WhatsApp da Ígnea Agro', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Escrever script de qualificação (nome, volume aproximado da dívida, com quem está endividado)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Definir fluxo: lead qualificado → proposta comercial → contrato → pagamento → formulário', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Criar link de pagamento e processo de onboarding do produtor após confirmação de pagamento', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Configurar ferramenta de pagamento digital (Hotmart, Stripe, PagSeguro ou similar)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Automatizar envio do formulário de diagnóstico + Bônus 2 (Glossário) após confirmação do pagamento', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Criar registro interno por caso (planilha com: volume da dívida, credores, estratégia, status de conversão para TK Advogados)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 3, 'Criar página de vendas da Ígnea Agro baseada no pitch de vendas do dossiê (estrutura em 7 blocos: abertura, ponto A, inimigo, autoridade, oferta, investimento, CTA)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Verificar e atualizar bio do Instagram @ignea.agro para comunicar claramente a oferta de consultoria estratégica', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 5, 'Criar e organizar destaques do Instagram @ignea.agro (quem somos, como funciona, resultado, contato)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ========================================
  -- FASE 4: Posicionamento da Marca Pessoal @thiago_kailer
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Posicionamento da Marca Pessoal @thiago_kailer', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Reformular bio e apresentação do perfil @thiago_kailer para comunicar o posicionamento de "estrategista neutro dos dois lados do mercado"', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Escrever nova bio do @thiago_kailer alinhada à narrativa central: "15 anos operando de dentro dos dois lados de um mercado opaco"', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Garantir separação clara de narrativas: @thiago_kailer (estrategista neutro), @ignea.agro (produtor), Axioma (investidor/fundo)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Criar foto de perfil e identidade visual que reforce posicionamento de consultor sênior e autoridade de mercado', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Produzir os primeiros conteúdos de feed/reels baseados nos 6 marcos de autoridade narrativa do dossiê', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Produzir conteúdo sobre Marco 1: Origem na advocacia bancária (HSBC, Banco do Brasil, Itaú/Unibanco)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Produzir conteúdo sobre Marco 3: BTG compra carteira Bamerindus (2016-2017) — "eu estava lá quando esse mercado nasceu"', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Produzir conteúdo sobre Marco 5: A mudança de lado — núcleo da narrativa emocional', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 4, 'Produzir conteúdo sobre Marco 6: Fundação da Ígnea Agro — "a mudança de lado virou empresa e estrutura"', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 5, 'Produzir conteúdo sobre Marco 7: Negociação de exclusividade com BTG/Enforce via Axioma', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 3, 'Criar calendário de conteúdo mensal para @thiago_kailer usando o banco de frases do dossiê (tom analítico, insider, neutro)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Definir frequência e tipos de conteúdo: análises do mercado de distressed, bastidores do mercado de dívida agro, leitura bilateral', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Adaptar banco de frases do dossiê em pautas de conteúdo para feed, reels e stories', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Definir regras do que NÃO postar no @thiago_kailer (não direcionar só para produtor, não direcionar só para investidor)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 4, 'Trabalhar com produtor de conteúdo ou editor para superar a limitação de criatividade reconhecida por Thiago ("tenho falta de habilidades de ser criativo")', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 5, 'Estudar e mapear estratégias de comunicação dos perfis de referência do dossiê (Guilber Hidaka, Rony Meisler, Renato Opice Blum)', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ========================================
  -- FASE 5: Ativação da Rede de Originadores
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Ativação da Rede de Originadores e Captação Offline', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Mapear e listar os originadores ativos nos estados prioritários (MT, RS, PR, TO, PI) e estruturar modelo de parceria/comissão', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Listar todos os originadores ativos por estado com nome, contato e volume de oportunidades', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Definir percentual de comissão e modelo de repasse para originadores que tragam casos qualificados', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Criar material de apresentação da consultoria para enviar aos originadores (versão condensada do pitch)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 4, 'Fazer contato ativo com os 10 principais originadores para apresentar o produto formalizado da Ígnea Agro', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Contatar advogados parceiros que já consultam Thiago informalmente e apresentar o produto formalizado', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Listar advogados de outros estados que já buscaram orientação estratégica informal de Thiago', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Enviar mensagem personalizada para cada advogado parceiro apresentando a consultoria da Ígnea Agro', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Criar estrutura de indicação para advogados parceiros (modelo de comissão ou parceria estratégica)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 3, 'Contatar ex-clientes e contatos da rede de 15 anos de atuação que possam trazer leads qualificados', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Criar roteiro de abordagem para eventos do setor agro — Thiago já está presente em eventos, sistematizar a captação nesses encontros', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ========================================
  -- FASE 6: Aquisição dos Primeiros Clientes da Consultoria
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Aquisição dos Primeiros Clientes da Consultoria Ígnea Agro', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Identificar e listar os produtores que já procuraram Thiago informalmente e que se encaixam no perfil ICP (dívida acima de R$3M)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Mapear casos de consultoria informal já realizados gratuitamente (estimado R$300K/ano não cobrado)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Qualificar cada caso: volume da dívida, urgência, perfil do produtor, credores envolvidos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Selecionar 3-5 casos prioritários para abordagem comercial com o produto formalizado', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Realizar abordagem comercial com os primeiros leads utilizando o pitch de vendas do dossiê', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Enviar proposta comercial para os leads selecionados com faixas de investimento baseadas no tamanho da dívida', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Conduzir conversa de qualificação e fechamento seguindo o roteiro do pitch (abertura, ponto A, diferencial, oferta, investimento)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Fechar e onboar o primeiro cliente pagante da consultoria Ígnea Agro', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 3, 'Executar o primeiro ciclo completo da consultoria (4 movimentos: diagnóstico, análise, mapa, acompanhamento) e documentar aprendizados', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Executar Movimento 1 — Diagnóstico: conduzir encontro de até 2h com o primeiro cliente', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Executar Movimento 2 — Análise: Thiago e time analisam contratos em 5-7 dias úteis com apoio da Axioma', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Executar Movimento 3 — Mapa: apresentar Mapa Estratégico completo + Matriz de Riscos + Estratégia Recomendada', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 4, 'Executar Movimento 4 — Acompanhamento: 3 calls mensais + WhatsApp + call emergencial', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 5, 'Coletar feedback do primeiro cliente e ajustar processos operacionais para os próximos casos', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ========================================
  -- FASE 7: Gestão do Conflito de Interesses e Separação de Marcas
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Gestão do Conflito de Interesses e Separação de Marcas', 'fase', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Documentar e formalizar a separação operacional entre TK Advogados (credores) e Ígnea Agro (produtores)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar regra clara: TK Advogados não aparece em conteúdo da Ígnea Agro e vice-versa', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Validar com mentor a estrutura jurídica de separação das entidades para cumprimento do estatuto da OAB', 'pendente', 'mentor', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Revisar nota de enquadramento da oferta: "Thiago Kailer atua como Consultor Estratégico — não como advogado. A representação jurídica é feita separadamente pelo TK Advogados"', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 2, 'Definir narrativa de comunicação para cada canal: @thiago_kailer (neutro), @ignea.agro (produtor), Axioma (mercado profissional)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 3, 'Criar protocolo interno para casos onde o cliente da consultoria Ígnea Agro deseja contratar o TK Advogados — aplicar mecanismo de abate de honorários', 'pendente', 'mentorado', 3, 'dossie_auto');

  -- ========================================
  -- FASE 8: Desenvolvimento do Storytelling em Conteúdo
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Desenvolvimento do Storytelling em Conteúdo Digital', 'fase', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Adaptar os storytellings completos do dossiê (Produtor Rural e Mercado Geral) em formatos de conteúdo para Instagram', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar versão curta (reel 60-90s) do storytelling central: "Mudei de lado — agora uso o que aprendi contra o produtor para defender o produtor"', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Criar carrossel de feed com a sequência dos 6 marcos de autoridade narrativa', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Produzir conteúdo sobre as crenças-chave do dossiê: "Endividamento não é falha moral", "O produtor precisa de estratégia antes de advogado", "Fundo de investimento não é seu aliado — é um negócio"', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Usar as "Falas Reais do Thiago" do dossiê como base para conteúdos autênticos e de alta autoridade', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Produzir conteúdo baseado em: "Eu advogava para banco. Era eu que executava o produtor."', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Produzir conteúdo baseado em: "Para dever pouco, a vinte milhões" — contextualizando as faixas de endividamento', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Produzir conteúdo baseado em: "Eu comecei a ser consultado por próprios advogados" — autoridade reconhecida por pares', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 4, 'Produzir conteúdo baseado em: "No offline, eu sou muito forte em termos de rede de contato" — validação da presença no mercado', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 3, 'Criar série de conteúdos educativos sobre o mercado de distressed assets para construir autoridade no @thiago_kailer (mercado geral)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Produzir conteúdos sobre os erros mais comuns do produtor endividado usando as "Crenças Erradas do Público" do dossiê', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 5, 'Definir estratégia para lidar com restrições da OAB em captação — posicionar conteúdo como educacional, não como captação direta', 'pendente', 'mentorado', 5, 'dossie_auto');

  -- ========================================
  -- FASE 9: Escalabilidade Operacional e Gestão do Tempo
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Escalabilidade Operacional e Gestão do Tempo', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Definir capacidade máxima de atendimento simultâneo da consultoria (limitação de horas identificada: "minha escala é pequena porque tenho que atender um por um")', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Calcular horas disponíveis por mês para a consultoria considerando advocacia ativa no TK Advogados', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Definir número máximo de casos simultâneos viável sem comprometer qualidade da entrega', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Estruturar fluxo de delegação para o time do escritório absorver parte da análise contratual (Movimento 2)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Integrar a Axioma (IA para mineração de ativos estressados) no processo de análise contratual do Movimento 2', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Mapear quais partes da análise contratual podem ser automatizadas pela Axioma (leitura de CPR, hipotecas, cessões de crédito)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Criar protocolo de uso da Axioma dentro do fluxo da consultoria Ígnea Agro', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Testar a Axioma em um caso real e documentar ganho de velocidade versus análise manual', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 3, 'Trabalhar o problema de foco identificado: "Eu tenho questão de foco. Isso me trava" — criar ritual de revisão semanal de prioridades', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Criar sistema de CRM simplificado para gerenciar pipeline de leads, clientes ativos e histórico de casos', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ========================================
  -- FASE 10: Construção de Autoridade no Mercado de Distressed Assets
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Construção de Autoridade no Mercado de Distressed Assets', 'fase', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Criar conteúdo de posicionamento como "estrategista neutro" do mercado de distressed assets para o @thiago_kailer (Fase 2 do dossiê)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Publicar análises sobre o mercado de NPL (non-performing loans) no Brasil — usando a visão de insider de 15 anos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Publicar conteúdo sobre como fundos de distressed analisam carteiras (linguagem segura: análise de risco, viabilidade, timing)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Publicar sobre a estruturação do mercado de distressed rural no Brasil — posicionamento como testemunha histórica do mercado', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Participar e gerar conteúdo sobre eventos do setor agro e de distressed assets para ampliar presença digital com base na presença offline já ativa', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar conteúdo antes, durante e depois dos eventos (bastidores, análises, insights)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Registrar interações com fundos, bancos e cooperativas durante os eventos (sem revelar confidencialidade dos casos)', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 3, 'Escrever e publicar artigo sobre o mercado de dívida rural no Brasil — credenciais acadêmicas (pós-graduação Insper 2015-2016) como plataforma de autoridade', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Identificar oportunidades de participação em podcasts e eventos como especialista em distressed rural — para construção de autoridade além do Instagram', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ========================================
  -- FASE 11: Desenvolvimento e Negociação da Axioma (Fase 3)
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Desenvolvimento e Negociação da Axioma (Fase 3 — Mercado Profissional)', 'fase', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Acompanhar e apoiar a negociação de exclusividade da Axioma com BTG/Enforce — maior player do mercado de distressed no Brasil', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Reunir com o sócio técnico/engenheiro da Axioma para alinhamento do status da negociação com BTG/Enforce', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Mapear os termos mínimos aceitáveis para o contrato de licenciamento com BTG/Enforce', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Definir prazo máximo para fechar a negociação antes de partir para alternativas de licenciamento com outros fundos', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Planejar oferta de produto da Axioma para fundos e investidores qualificados (Público A da Fase 3)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Definir precificação da análise da Axioma (~R$300 por análise automatizada mencionado na call)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Criar proposta comercial para gestores de FIDCs, family offices e fundos de crédito interessados na tecnologia', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Mapear lista de fundos potenciais além do BTG/Enforce para licenciamento da Axioma', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 3, 'Planejar programa de originadores para a Axioma (Público B da Fase 3) — modelo de comissão para quem traz deal flow de ativos estressados', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'ATENÇÃO: Não ativar ações de mercado da Axioma antes de consolidar Fases 1 e 2 — seguir orientação do dossiê', 'pendente', 'mentor', 4, 'dossie_auto');

  -- ========================================
  -- FASE 12: Mentalidade, Foco e Gestão de Paralisia
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Mentalidade, Foco e Superação da Paralisia por Complexidade', 'fase', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Trabalhar o padrão de paralisia identificado: "Quando eu chego nesse tipo de complexidade, eu nunca consegui avançar" — criar sistema de execução em pequenos passos', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar lista de "próximas ações físicas" por frente de trabalho — nunca mais de 3 por semana', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Agendar revisão semanal de prioridades com o mentor para calibrar foco', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Praticar "validar antes de completar" — testar hipóteses com ações mínimas antes de construir a estrutura completa', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 2, 'Trabalhar o comportamento de olhar para concorrentes e travar — substituir por análise rápida de lacunas e execução imediata', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Criar ritual de análise de concorrente: máximo 30 minutos/mês, foco apenas em lacunas de oportunidade', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Internalizar diferenciação única: "nenhum concorrente tem a trajetória dos dois lados" — usar como âncora contra paralisia por comparação', 'pendente', 'mentorado', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 3, 'Resolver o problema de precificação: Thiago reconheceu que "não sabia precificar a consultoria" — usar as faixas definidas no dossiê como âncora e testar com primeiros clientes', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Praticar autenticidade no conteúdo: "eu queria ser mais eu" — criar exercício de gravação informal semanal para desenvolver voz própria no digital', 'pendente', 'mentorado', 4, 'dossie_auto');

  -- ========================================
  -- FASE 13: Monitoramento, Métricas e Revisão de Resultados
  -- ========================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 148, 'Monitoramento, Métricas e Revisão de Resultados', 'passo_executivo', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 148, 1, 'Definir métricas de sucesso para a Fase 1 (Ígnea Agro) — número de consultorias fechadas, receita, taxa de conversão para TK Advogados', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 148, 1, 'Definir meta de receita mensal mínima da Ígnea Agro (baseline: R$300K/ano identificado como não capturado)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 2, 'Criar painel simples de acompanhamento: leads recebidos, qualificados, propostas enviadas, fechamentos, conversões para TK Advogados', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 148, 3, 'Acompanhar taxa de conversão da consultoria para representação jurídica (LTV do modelo boutique)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 148, 2, 'Revisar mensalmente o PA com o mentor e ajustar prioridades conforme avanço das frentes (Fase 1, Fase 2 e Fase 3)', 'pendente', 'mentor', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 3, 'Documentar casos atendidos e resultados obtidos para criar banco de provas sociais — base para futuros conteúdos de autoridade', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 148, 4, 'Avaliar em 90 dias o progresso da Fase 1 para definir timing de início da Fase 2 (marca pessoal como estrategista neutro no @thiago_kailer)', 'pendente', 'mentor', 4, 'dossie_auto');

END $$;

-- ===== MENTORADO: RENATA ALEIXO (id=44) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (44, 'PLANO DE AÇÃO v2 | RENATA ALEIXO', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- FASE 1: Revisão do Dossiê Estratégico
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 1, 'Ler o dossiê completo e anotar dúvidas e pontos de atenção', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 2, 'Revisar seção de Storytelling da Renata (ex-bailarina, fisiculturismo, compulsão pós-competição, origem do PDM)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Revisar seção de Público-Alvo (nutricionistas clínicas 3-10 anos, faturamento R$4k-12k, dores técnicas e emocionais)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Revisar seção de Oferta (Mentoria Jornadas Clínicas de Alto Valor, 3 pilares PDM, bônus e precificação R$25k-27k)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 5, 'Revisar Arquitetura do Produto (STEP 1 exames isolados, STEP 2 PDM 90 dias, STEP 3 Jornada 5 Estrelas)', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 6, 'Revisar Estratégia do Funil (16 etapas do funil de aula online, da preparação ao onboarding)', 'pendente', 'mentorado', 6, 'dossie_auto');


  -- FASE 2: Posicionamento e Identidade de Marca
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Posicionamento e Identidade de Marca', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 1, 'Definir nome final da mentoria entre as opções sugeridas (MRA, NQT, NAP, etc.)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 2, 'Consolidar tese de posicionamento: "Nutricionista de Precisão que vende protocolo, não hora"', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Definir username e nome de exibição do perfil mentora no Instagram (ex: @renataaleixo.pdm)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Criar e publicar bio do perfil mentora com CTA de aplicação para a mentoria', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 5, 'Revisar e lapidar bio do perfil profissional @nutrirealeixo com foco em captação de pacientes', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 6, 'Agendar sessão fotográfica para foto de perfil da mentora (meio corpo, fundo claro, tom premium)', 'pendente', 'mentorado', 6, 'dossie_auto');


  -- FASE 3: Estruturação do Perfil Instagram (Mentora + Profissional)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Estruturação dos Perfis Instagram (Mentora e Profissional)', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 1, 'Criar novo perfil de mentora no Instagram separado do @nutrirealeixo', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Escolher username entre as opções (@renataaleixo.pdm, @renataaleixo.nutriprecisao, @mentora.renataaleixo)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Configurar foto de perfil premium (close no rosto, fundo liso, blusa lisa branca/preta/verde petróleo)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Publicar bio com uma das versões sugeridas no dossiê (Mentora de Nutricionistas + CTA aplicação)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 2, 'Estruturar os 5 destaques do perfil mentora (Sobre, Resultados, Mentoria, Bastidores, Lifestyle)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Criar destaque SOBRE: quem é Renata, origem PDM, ex-bailarina, compulsão pós-fisiculturismo, 1.500+ jornadas', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Criar destaque RESULTADOS: antes/depois de pacientes, gráficos de inflamação/microbiota, depoimentos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Criar destaque MENTORIA: problema da consulta avulsa, virada de modelo, 3 pilares, para quem é e não é', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Criar destaque BASTIDORES: rotina de consultório, preparação, construção de protocolos, autoridade silenciosa', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 5, 'Criar destaque LIFESTYLE: momentos pessoais, viagem, autocuidado, estilo de vida sem ostentação', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 3, 'Lapidar perfil profissional @nutrirealeixo para captação de pacientes (PDM, microbiota, desinflamação)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Atualizar bio com uma das versões sugeridas (foco em desinflamação, Protocolo PDM, CTA para consulta)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Reestruturar destaques para 3 principais: Sobre, Resultados/Pacientes e PDM (eliminar redundâncias)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Ajustar foto de perfil: aumentar contraste, fundo verde/bege quente, comunicar especialidade intestinal', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 4, 'Criar 3 posts fixados em collab (perfil profissional + mentora): história, prova de autoridade, convite para encontro', 'pendente', 'mentorado', 4, 'dossie_auto');


  -- FASE 4: Preparação da Aula Online (Etapas 1-3 do Funil)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Preparação da Aula Online (Nome, Grupo e Formulário)', 'passo_executivo', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 1, 'Definir nome, promessa e data da aula (data definida: 18/03/2026 às 19h)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Escolher nome da aula entre as 5 opções sugeridas (foco em +150k/mês com protocolos de microbiota)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Confirmar data e horário: 18/03/2026 às 19h (Brasília)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Redigir promessa da aula alinhada ao dossiê (sair da consulta avulsa, protocolo PDM, previsibilidade)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 2, 'Criar grupo fechado de WhatsApp para a aula com configurações corretas', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Criar grupo com nome (ex: "Protocolo Microbiota | Renata Aleixo") e configurar como FECHADO (só admin envia)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Adicionar foto de perfil premium e descrição oficial com data/hora da aula', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Fixar mensagem de boas-vindas e adicionar mínimo 5 administradores', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 3, 'Criar formulário de inscrição para a aula com perguntas de qualificação e redirecionamento para grupo WA', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Criar formulário com campos: Nome completo, E-mail, WhatsApp conforme orientação do dossiê', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Configurar página de confirmação com CTA para entrar no grupo de WhatsApp', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Testar fluxo completo: inscrição → confirmação → entrada no grupo', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 4, 'Criar e configurar link de pagamento da mentoria (R$25k à vista ou 6x R$4.500)', 'pendente', 'equipe_spalla', 4, 'dossie_auto');


  -- FASE 5: Estruturação da Lista de Contatos e Disparo de Mensagens (Etapas 4-5)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Estruturação da Lista de Contatos e Infraestrutura de Disparo', 'passo_executivo', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 1, 'Consolidar lista-mãe de contatos de nutricionistas de todas as fontes', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Levantar lista de fornecedores parceiros (Curitiba, BH e SP) com potencial de 5.000-10.000 nutricionistas', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Compilar grupos antigos com 200-300 nutricionistas cada', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Montar planilha com colunas: Nome, WhatsApp, E-mail, Origem, Temperatura (quente/morno/frio), UF, Área de atuação', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Filtrar lista para excluir Curitiba e região metropolitana (evitar colisão com atendimento presencial)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 5, 'Segmentar lista por área: menopausa, estética, oncológico, lipedema, dermatologia, performance', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 2, 'Configurar infraestrutura técnica para disparo via WhatsApp Business API + ManyChat', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Comprar e ativar chip novo (Vivo ou Claro, DDD 41 Curitiba) SEM instalar WhatsApp no aparelho', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Criar/acessar Meta Business Suite, enviar documentos CNPJ para verificação (prazo 2-5 dias úteis)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Configurar WhatsApp Business API, adicionar número e configurar perfil (nome, foto, descrição)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Criar conta ManyChat Pro e conectar ao WhatsApp Business API', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 5, 'Criar e submeter 3 templates de mensagem (A: resultado, B: autoridade, C: escassez) para aprovação Meta', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 3, 'Executar processo de aquecimento do número e dividir lista em lotes para teste A/B', 'pendente', 'equipe_spalla', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Realizar aquecimento gradual: começar com 20-50 conversas manuais, depois lotes de 100-500', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Importar lista no ManyChat e dividir em 7 lotes (lotes 1-3 de 500 para teste A/B, lotes 4-7 de 1000 para campeão)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Executar testes A/B: Template A (D-10), B (D-9), C (D-8), identificar campeão (D-7) e disparar para lotes restantes', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Monitorar qualidade do número diariamente: Quality Rating verde, taxa de bloqueio < 1%', 'pendente', 'equipe_spalla', 4, 'dossie_auto');


  -- FASE 6: Captação e Aquecimento de Audiência (Etapas 6-10)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Captação e Aquecimento de Audiência (Convites, Instagram e Remarketing)', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 1, 'Executar convite para base de contatos via WhatsApp com abordagem pessoal e autoral (Etapa 6)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Disparar Versão 1 para leads com indicação de fornecedor (tom equilibrado, convite pessoal)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Disparar Versão para base sem fornecedor (grupos de nutricionistas, tom profissional)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Executar sequência de follow-up: "Faltam 5 dias" com áudio de raciocínio clínico + "Faltam 3 dias" com CTA', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 2, 'Executar lapidação do perfil e publicação de conteúdo de captação no Instagram (Etapa 7-8)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Publicar Post 1 em collab (perfil profissional + mentora): transformação através dos protocolos', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Publicar Post 2 em collab: convite direto para encontro online sobre protocolos de microbiota', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Publicar sequência de Stories (5 stories) explicando raciocínio clínico e convidando para DM', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Gravar e publicar Reels com gancho: "O maior erro da nutrição clínica não é o plano alimentar"', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 3, 'Configurar e ativar campanha de remarketing no Meta Ads durante período de captação (Etapa 10)', 'pendente', 'equipe_spalla', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Subir lista de fornecedores no Meta como público personalizado (LISTA_FORNECEDORES) excluindo Curitiba', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Criar público de engajadores do Instagram @nutrirealeixo dos últimos 90 dias (ENV_IG_90D)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Criar campanha RMK_Aula com objetivo Engajamento, R$50/dia, usando posts existentes do feed', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Monitorar frequência (ideal 2-4x) e pausar/ajustar se necessário durante 3-5 dias de captação', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 4, 'Executar comunicação estratégica no grupo de WhatsApp (9 mensagens: boas-vindas, aquecimento, link e pós-aula)', 'pendente', 'mentorado', 4, 'dossie_auto');


  -- FASE 7: Preparação e Execução da Aula Online (Etapas 11-12)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Preparação e Execução da Aula Online', 'passo_executivo', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 1, 'Preparar roteiro completo da aula (5 blocos) com 1 semana de antecedência (Etapa 11)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Elaborar Bloco 1: Posicionamento e confiança (apresentação, história, promessa, mapa da jornada, transparência)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Elaborar Bloco 2: Consciência e quebra (espelhamento do problema, 3 crenças limitantes, montanha-russa financeira)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Elaborar Bloco 3: Os 3 Pilares do Método (diferenciação por exames, PDM 90 dias, Jornada 5 Estrelas + LTV)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Elaborar Bloco 4: Transição para oferta (3 caminhos: ignorar/sozinha/mentoria, processo de seleção, aplicação)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 5, 'Elaborar Bloco 5: Fechamento (resumo, prova social ao vivo, escassez real, encerramento com inversão de polaridade)', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 6, 'Revisar roteiro com time CASE e treinar fala (especialmente abertura e transição para oferta)', 'pendente', 'equipe_spalla', 6, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 2, 'Executar setup técnico da aula e criar formulário de aplicação da mentoria (Etapa 12)', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Criar link Zoom com nome "Dobre o faturamento do consultório - Aula Renata Aleixo", testar com pessoa externa', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Confirmar plano do Zoom suporta volume esperado de inscritos (webinar se necessário)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Criar formulário de aplicação da mentoria com 11 perguntas de qualificação (momento clínico, dores, investimento)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Configurar planilha automática de aplicações e alinhar time sobre critérios de prioridade (à vista primeiro)', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 3, 'Realizar a aula online ao vivo em 18/03/2026 às 19h seguindo roteiro dos 5 blocos', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Enviar sequência de mensagens no grupo WA no dia da aula: manhã (link Zoom), -1h (áudio), ao vivo (texto), 15min depois (texto)', 'pendente', 'equipe_spalla', 4, 'dossie_auto');


  -- FASE 8: Abordagem Pós-Aula e Fechamento de Vendas (Etapas 13-14)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Abordagem Pós-Aula e Fechamento da Turma', 'passo_executivo', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 1, 'Organizar lista de aplicações e priorizar contato (à vista primeiro, parcelado depois)', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Ler cada aplicação inteira antes de ligar: entender modelo atual, dor clínica central, momento profissional', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Separar lista em: aprovadas para ligação imediata x não prontas (não entrar em contato)', 'pendente', 'equipe_spalla', 2, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 2, 'Executar abordagem pós-aula para quem fez aplicação (Etapa 13 do funil)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Enviar mensagem de aprovação no WhatsApp e aguardar resposta para ligar (script do dossiê)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Executar sequência de follow-up se não responder: mensagem (6-8h), ligação direta, mensagem pós-ligação', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Realizar ligação de fechamento de 15-30min: abertura, espelhamento, dor central, apresentação da mentoria, CTA', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Enviar link de pagamento imediatamente após aceite: R$25k à vista ou 6x R$4.500', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 3, 'Executar abordagem pós-aula para quem assistiu mas não aplicou (Etapa 14 do funil)', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Enviar mensagem de ativação de intenção personalizada (ver perfil da nutricionista e mencionar área de atuação)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Executar sequência de 6 follow-ups ao longo de 5 dias (áudio D+1, ligação D+1, mensagem D+2, áudio D+4, caso real D+5, encerramento D+5)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Conduzir ligação de qualificação (fit antes de fechar): espelhar dor, apresentar modelo, verificar desejo', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 4, 'Consolidar total de fechamentos, receita gerada e taxa de conversão da aula para aprendizados do próximo ciclo', 'pendente', 'equipe_spalla', 4, 'dossie_auto');


  -- FASE 9: Onboarding e Operação da Turma (Etapa 15)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Onboarding e Confirmação da Turma da Mentoria', 'passo_executivo', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 1, 'Preparar e enviar kit de onboarding para cada mentorado confirmado', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Gravar e enviar vídeo de boas-vindas personalizado da Renata para cada aluno', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Enviar acesso à plataforma de aulas (módulos 0 a 6 disponíveis conforme arquitetura do produto)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Criar e adicionar mentorado ao grupo de WhatsApp da turma com regras claras de comunidade', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Enviar datas dos encontros ao vivo quinzenais e das oficinas extras programadas', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 2, 'Configurar plataforma de aulas com 6 módulos e progressão por steps liberados conforme avanço do aluno', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Disponibilizar materiais de apoio iniciais: guias clínicos, lista de fornecedores validados, planilha de precificação', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Realizar encontro de onboarding ao vivo: alinhar expectativas, regras da mentoria, responsabilidade do aluno', 'pendente', 'mentorado', 4, 'dossie_auto');


  -- FASE 10: Produção de Conteúdo Estratégico (Etapa 16)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Produção de Conteúdo Estratégico para Ambos os Perfis', 'fase', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 1, 'Produzir série de conteúdos para o perfil MENTORA sobre ciclo vicioso da consulta avulsa e modelo PDM', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Criar post/carrossel: "O ciclo vicioso da consulta avulsa" (montanha-russa Jan R$8k → Fev R$3k)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Criar post/carrossel: "A conta errada que todo nutricionista faz" (40 pacientes x R$250 vs 10 x R$3.500)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Criar Reels: "Por que 50% dos meus pacientes vêm sem pagar R$1 de anúncio" (indicação orgânica)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Criar post: "A conta que mudou tudo" (de R$3k/mês para R$150k/mês com protocolo PDM)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 5, 'Criar post: "A diferença entre vender hora e vender resultado" (comparação PDM x consulta avulsa)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 2, 'Produzir série de conteúdos para o perfil PROFISSIONAL sobre sensibilidade alimentar e microbiota', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Criar post: "Banana: o alimento saudável que mais inflama" (presença no topo dos laudos de sensibilidade)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Criar post: "Por que você come saudável mas não emagrece" (média 17 alimentos inflamatórios de 59 testados)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Criar Reels em collab: "O dia que eu descobri que estava enganando meus pacientes" (historia real fisiculturista)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Criar post: "Por que 85% dos meus pacientes dizem SIM" (pitch na TV do consultório, intestino inflamado vs saudável)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 5, 'Criar post em collab: "O que 59 alimentos podem revelar sobre sua saúde" (exame de sensibilidade na prática)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 3, 'Alinhar uso do agente de copy com time de consultores para produção e revisão dos conteúdos', 'pendente', 'equipe_spalla', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Orientar Renata a usar o prompt do dossiê (STORYTELLING BASE) para adaptar conteúdos com o ChatGPT', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Revisar sugestões geradas pelo agente e adaptar para naturalidade, autoridade clínica e coerência', 'pendente', 'equipe_spalla', 2, 'dossie_auto');


  -- FASE 11: Implementação do STEP 1 da Mentoria (Exames Isolados)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'STEP 1 da Mentoria: Consultas + Exames Isolados com Alunos', 'fase', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 1, 'Gravar Módulo 1: Fundamentos da Nutrição 4P e Nutrição Integrativa Funcional (Aulas 2-5)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Gravar Aula 2: Nutrição 4P (Preventiva, Preditiva, Personalizada, Participativa) e aplicação prática', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Gravar Aula 3: Sensibilidade Alimentar na Prática Clínica (metodologia, indicações, 59 alimentos testados)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Gravar Aula 4: Intestino, Microbiota e Saúde Sistêmica (segundo cérebro, impactos hormonais e inflamatórios)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Gravar Aula 5: Exames Preditivos na Prática (sensibilidade, microbiota, nutrigenética) + Aula 6: Interpretação de Laudos', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 2, 'Gravar Módulo 2: STEP 1 - Consultas + Exames Isolados (Aula 9)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Gravar estrutura da oferta STEP 1: consulta + exame isolado, ticket R$1.500-2.500, pitch de venda na tela', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Gravar como vender exame como evolução natural do cuidado (sem soar comercial, foco em benefício)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Disponibilizar lista de substituição de alimentos intolerantes (Bônus 5) para uso imediato pelos alunos', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 3, 'Realizar Encontro Ao Vivo 1: Como Vender Jornadas Clínicas de High Ticket (abordagem ética, construção de valor)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Acompanhar alunos na aplicação do STEP 1 com pacientes existentes (monitorar primeiros casos e dificuldades)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 5, 'Coletar primeiros resultados dos alunos no STEP 1 (aumento de ticket médio, reações dos pacientes)', 'pendente', 'equipe_spalla', 5, 'dossie_auto');


  -- FASE 12: Implementação do STEP 2 da Mentoria (Protocolo PDM 90 dias)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'STEP 2 da Mentoria: Protocolo PDM de 90 Dias', 'fase', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 1, 'Gravar Módulo 3: PDM completo - Protocolo de Desinflamação e Recuperação da Microbiota (Aula 10)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Gravar estrutura completa do PDM: 3 consultas + exame sensibilidade + exame microbiota + 90 dias', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Gravar fluxo de cada consulta dentro do PDM (critérios de elegibilidade, condução, orientações pós-protocolo)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Gravar aula sobre integração sensibilidade alimentar + inflamação + microbiota intestinal (o elo perdido)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Gravar como vender transformação e planejamento nutricional avançado (não dieta), ticket R$3.500-4.500', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 5, 'Gravar aula sobre pós-PDM: como conduzir o paciente após término, PDM é início não fim', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 2, 'Disponibilizar modelos de scripts para ativação de base de pacientes (textos, vídeos, áudios) para uso pelos alunos', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Realizar Encontro Ao Vivo 3: Onboarding e Encantamento do Paciente (caixinha premium, kits, voucher familiar)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Realizar Encontro Ao Vivo 7: Simulação de Atendimento Guiada pela Renata (demonstração prática do PDM)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 5, 'Disponibilizar Bônus 3 (Pitch de Consultório com modelo e roteiro de aplicação na TV do consultório)', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 6, 'Coletar primeiros cases de alunos aplicando PDM (resultados com paciente em 45 dias: desinflamação, perda de retenção)', 'pendente', 'equipe_spalla', 6, 'dossie_auto');


  -- FASE 13: Implementação do STEP 3 da Mentoria (Jornada 5 Estrelas e LTV)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'STEP 3 da Mentoria: Jornada 5 Estrelas e LTV de Longo Prazo', 'fase', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 1, 'Gravar Módulo 4: Jornada 5 Estrelas - Gestão de Saúde Nutricional de 3 anos (Aula 11)', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Gravar Ano 1, Ano 2 e Ano 3 da jornada: raciocínio técnico e comercial de cada etapa', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Gravar lógica de LTV: de R$4.500 (PDM) para R$15.000-30.000 por paciente ao longo de 3 anos', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Gravar estratégia de check-ups semestrais de microbiota e combinação de exames preditivos ao longo do tempo', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Gravar Aula 7: Check-ups de Microbiota Intestinal (importância da reavaliação semestral, base científica)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 5, 'Gravar como apresentar a Jornada 5 Estrelas no final do PDM (transição natural para recorrência)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 2, 'Realizar Encontro Ao Vivo 2: Jornada 5 Estrelas na prática (como conduzir pacientes ao longo dos anos)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 3, 'Realizar Encontro Ao Vivo 4: Precificação e Gestão de Indicadores de Desempenho (planilha do consultório)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Realizar Encontro Ao Vivo 6: Vendas para Casais e Famílias (estratégias de ativação, vouchers, indicações)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 5, 'Disponibilizar Bônus 4: Painel de Controle do Consultório (planilha precificação + indicadores + metas)', 'pendente', 'equipe_spalla', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 6, 'Disponibilizar Bônus 6: Aula de Encantamento e Fidelização (onboarding 5 estrelas, microexperiências, LTV)', 'pendente', 'equipe_spalla', 6, 'dossie_auto');


  -- FASE 14: Comercial, Precificação e Regulação do Consultório (Módulos 5-6)
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 44, 'Comercial, Precificação e Regulação do Consultório', 'fase', 14, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 1, 'Gravar Módulo 5: Comercial, Precificação e Crescimento Sustentável', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Gravar conteúdo sobre processo comercial: SDR, CRM, abordagem sem medo de cobrar R$3.500-4.500', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Disponibilizar Bônus 2: Scripts Prontos de Venda e Abordagem (com raciocínio sustentando o fechamento)', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Gravar como quebrar objeções de preço usando laudo na TV do consultório (taxa de conversão 85%)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Realizar Encontro Ao Vivo 5: Planejamento Anual de Vendas e Sazonalidade (calendário de saúde, combos)', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 44, 2, 'Gravar Módulo 6: Operação, Regulação e Escala do Consultório', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 44, 1, 'Gravar Aula 8: Aspectos Regulatórios (como deixar consultório apto para jornadas Nutrição 4P, domínio legal de Rodrigo)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 2, 'Gravar conteúdo sobre parcerias com laboratórios: como estruturar, domínio regulatório, remover medo burocrático', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 3, 'Disponibilizar lista de fornecedores e parceiros validados (exames sensibilidade Curitiba/BH/SP + microbiota + nutrigenética)', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 44, 4, 'Gravar conteúdo sobre escala: quando contratar SDR, como gerenciar CRM, agência de marketing dedicada', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 44, 3, 'Realizar Encontro Ao Vivo 8: Tira-Dúvidas com Renata e Rodrigo (discussão de casos reais, ajustes práticos)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 4, 'Monitorar evolução de faturamento dos alunos: de R$5-10k (Ponto A) rumo a R$30k (STEP 1) e R$80-120k (STEP 2)', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 44, 5, 'Coletar e documentar cases de sucesso para prova social do próximo ciclo de captação da mentoria', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

END $$;

-- ===== MENTORADO: SILVANE CASTRO (id=2) =====
DO $$
DECLARE
  _plano_id UUID;
  _fase_id UUID;
  _acao_id UUID;
BEGIN
  INSERT INTO pa_planos (mentorado_id, titulo, formato, status_geral, created_by)
  VALUES (2, 'PLANO DE AÇÃO v2 | SILVANE CASTRO', 'fases', 'nao_iniciado', 'dossie_auto_v3')
  RETURNING id INTO _plano_id;

  -- ============================================================
  -- FASE 1: Revisão do Dossiê Estratégico
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Revisão do Dossiê Estratégico', 'revisao_dossie', 1, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 1, 'Ler o dossiê completo e anotar dúvidas e pontos de atenção', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 2, 'Revisar seção de Contexto Analisado: posicionamento atual, concorrentes (Médicos SA, Íris Martins, Dr. Ricieri) e lacunas do mercado', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 3, 'Revisar seção de Público-Alvo: médico dono de clínica médica de elite, faturamento R$300k-1M/mês, plateau de gestão, Artista querendo virar Magnata', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 4, 'Revisar seção de Oferta Principal: LEGACY 6 meses, R$122k à vista ou 12x R$16.4k, 5 pilares do programa', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 5, 'Revisar Arquitetura do Produto LEGACY: Sprint Estratégico, Conselho Estratégico, Consultoria de Implementação, Liderança/Gestão/Cultura, Mastermind Legacy', 'pendente', 'mentorado', 5, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 6, 'Revisar Sugestão de Funil: abordagem 1:1, sessão estratégica gratuita, qualificação MQL e call de vendas', 'pendente', 'mentorado', 6, 'dossie_auto');


  -- ============================================================
  -- FASE 2: Reposicionamento Estratégico da Marca
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Reposicionamento Estratégico da Marca', 'fase', 2, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 1, 'Validar e internalizar o novo posicionamento: "Estrategista de Crescimento para Clínicas Médicas de Elite"', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Substituir comunicação genérica de "consultoria de gestão" pela nova tese de posicionamento em todos os canais', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Definir frase de posicionamento que diferencia da concorrência: especialista exclusiva em clínicas médicas de elite (não odontológicas, não estéticas)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Alinhar linguagem em todos os canais: Instagram pessoal @silvanecastro.sete, Seven @seven.clinicasmedicas', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 2, 'Consolidar a tese central da metodologia Seven: transformação antes de crescimento, capital interno antes do externo', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Documentar os pilares da tese: gestão emocional + estrutura de gestão + estratégia de crescimento — nessa ordem', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Criar narrativa anti-atalho: "crescimento sem fundamento é colapso disfarçado de sucesso"', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Validar Matriz do Médico-Empresário (Artista x Operador x Falido x Magnata) como ferramenta de posicionamento e qualificação', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 3, 'Mapear e documentar os diferenciais competitivos da Seven frente a concorrentes: 20+ anos, conselheira da indústria (Galderma, Skinceuticals, L''Oréal), 30.000+ médicos atendidos', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 4, 'Definir narrativa de origem: "Da salinha de 30m² ao maior ecossistema de gestão médica do Brasil" — historia de 17 anos sem atalho', 'pendente', 'mentorado', 4, 'dossie_auto');


  -- ============================================================
  -- FASE 3: Lapidação do Perfil Instagram Pessoal (@silvanecastro.sete)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Lapidação do Perfil Instagram Pessoal (@silvanecastro.sete)', 'fase', 3, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 1, 'Atualizar bio do perfil pessoal com nova versão sugerida no dossiê', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Escolher entre as 3 versões de bio sugeridas: Impacto/Transformação, Autoridade ou Conexão/História', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Garantir que a bio responde: quem sou, o que entrego, por que confiar, o que fazer agora (CTA com link)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Testar variação de foto de perfil: rosto visível, postura executiva, fundo que comunique posição (não apenas logo SE7EN)', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 2, 'Criar e publicar 3 posts fixados estratégicos conforme sugestão do dossiê', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Post fixado 1 — Posicionamento: quem sou, diferença, método SE7EN, autoridade (substitui carrossel genérico atual)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Post fixado 2 — Prova Social: cases reais com antes/depois de margem, faturamento e expansão; CTA diagnóstico', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Post fixado 3 — Diagnóstico: CTA direto para sessão estratégica gratuita, elegante e minimalista', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 3, 'Reorganizar destaques do perfil: reduzir para 5-6 essenciais com hierarquia clara', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Criar destaque SOBRE/SILVANE: storytelling da trajetória, 17 anos, da salinha ao maior ecossistema, fé e propósito', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Criar destaque RESULTADOS: casos reais de clientes (médica de 400k que virou 7M, médica de 3% de margem que foi para 28%)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Criar destaque LEGACY: explicação do programa, para quem é, o que entrega, como funciona, CTA aplicação', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 4, 'Criar destaque MÉTODO: os 3 estágios, a Matriz Médico-Empresário, os 5 pilares do LEGACY', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 5, 'Arquivar ou renomear destaques redundantes: eliminar excesso de 12+ destaques que geram desorganização', 'pendente', 'mentorado', 5, 'dossie_auto');


  -- ============================================================
  -- FASE 4: Lapidação do Perfil Instagram Seven (@seven.clinicasmedicas)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Lapidação do Perfil Instagram Seven (@seven.clinicasmedicas)', 'fase', 4, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 1, 'Atualizar bio do perfil Seven com nova versão — resolver 4 perguntas que a bio atual não responde', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Escolher entre versão 1 (Impacto/Transformação), versão 2 (Autoridade) ou versão 3 (Conexão/História) sugeridas no dossiê', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Incluir CTA funcional na bio: link para diagnóstico estratégico gratuito', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Resolver problema da foto de perfil: testar variação com rosto de Silvane ou ajuste de logo (contraste, fonte maior, subtítulo "SE7EN Gestão Clínicas")', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 2, 'Reestruturar destaques do perfil Seven com hierarquia e clareza (reduzir de 12+ para 5 essenciais)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Criar destaque SOBRE/QUEM SOMOS: posicionamento, história 16 anos, metodologia, provas macro, CTA diagnóstico', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Criar destaque RESULTADOS/CASES REAIS: antes/depois numéricos (margem, faturamento, ticket médio), histórias de clientes', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Criar destaque PRODUTOS/COMO CONTRATAR: Signature, Legacy, Select — para quem é cada um, diferencial, CTA diagnóstico', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 4, 'Gravar 5-8 stories novos para destaque SOBRE: posicionamento SE7EN, o que fazem, provas macro, metodologia', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 3, 'Criar 3 posts fixados estratégicos no perfil Seven: Posicionamento, Prova Social e Diagnóstico', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Post fixado Posicionamento: quem é a Seven, o que entrega, números macro (20 anos, 30k médicos, marcos), CTA', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Post fixado Prova Social: case real contraintuitivo (ex: médico 400k vs 7M, médica 800k com margem 3% → 28%)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Post fixado Diagnóstico: CTA para sessão estratégica — direto, elegante, minimalista, sem "coletor de leads barato"', 'pendente', 'mentorado', 3, 'dossie_auto');


  -- ============================================================
  -- FASE 5: Produção de Conteúdo — Roteiros e Calendário Editorial
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Produção de Conteúdo — Roteiros e Calendário Editorial', 'fase', 5, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 1, 'Implementar calendário editorial semanal: Dom (Identificação/Inspiração), Seg (Prova Social Longa), Ter (Consciência do Problema), Qua (Prova Social Curta), Qui (Identificação), Sex (Prova Social Longa), Sab (Descoberta)', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 2, 'Gravar roteiros de alta prioridade — Linha Alcance (audiência fria)', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Gravar Roteiro: "O que a indústria sabe sobre o futuro do seu mercado" (consultora Galderma/Skinceuticals/L''Oréal)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Gravar Roteiro: "A pergunta que o board me faz" (conselheira Skinceuticals vs operador de Instagram)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Gravar Roteiro: "Sua clínica vale zero reais" (valuation de clínica médica, dependência do médico)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 4, 'Gravar Roteiro: "Os 3 estágios da morte lenta" (Ilusão do Crescimento, Aprisionamento, Hemorragia)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 5, 'Gravar Roteiro: "A Matriz do Médico-Empresário" (Artista, Operador, Falido, Magnata)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 3, 'Gravar roteiros de prova social e autoridade — cases reais', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Gravar Roteiro: "400 mil que virou 7 milhões vs processo trabalhista" (duas clínicas, mesma cidade, ordem de prioridades)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Gravar Roteiro: "A médica que me ligou às 23h" (800k/mês, margem 3%, reestruturação para 28%)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Gravar Roteiro: "A médica que me demitiu e voltou" (barato saiu 3x mais caro, 18 meses de estrago)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 4, 'Gravar Roteiro: "A reunião que virou intervenção" (900k/mês, números bem, pessoa não estava bem)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 5, 'Gravar Roteiro: "Do plantão aos 3 milhões" (case de aluna: R$600 inicial → 3M/mês em 5 anos)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 4, 'Gravar roteiros de consciência de problema e identificação com o mercado médico', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Gravar Roteiro: "O erro do copia e cola" (estratégia sem identidade própria não funciona)', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Gravar Roteiro: "O número suficiente vs o psicológico" (desmamar convênio com capital interno)', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Gravar Roteiro: "Capital Interno" (resultados externos sem capital interno são temporários)', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 4, 'Gravar Roteiro: "Tem dinheiro que custa caro" (endividamento irresponsável, o preço escondido)', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 5, 'Gravar Roteiro: "A virada de 2019" (vendeu negócios distratores, foco total, rebranding, pandemia recalculada)', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 5, 'Produzir conteúdo das linhas editoriais do dossiê: Descoberta, Consciência (Entender), Autoridade (Confiar), Desejo (Desejar), Conexão (Identificar) — mínimo 3 peças por linha no primeiro mês', 'pendente', 'mentorado', 5, 'dossie_auto');


  -- ============================================================
  -- FASE 6: Estruturação do Funil de Captação (Sessão Estratégica)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Estruturação do Funil de Captação — Sessão Estratégica Gratuita', 'passo_executivo', 6, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 1, 'Definir e documentar as etapas do funil principal da Sessão Estratégica', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Mapear fluxo completo: captação (conteúdo/anúncio) → formulário qualificação → MQL → agendamento (Calendly) → call de vendas', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Criar formulário de pré-qualificação com perguntas de seleção: tipo de clínica, faturamento atual, principal desafio', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Configurar Calendly ou equivalente para agendamento da sessão estratégica com perguntas de qualificação', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 4, 'Criar página de CTA para o diagnóstico estratégico gratuito — elegante, premium, sem "coletor de leads barato"', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 2, 'Separar e organizar CRM para funil Sessão Estratégica separado do funil Turnê Seven', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Configurar UTMs separados por funil para rastreamento de origem dos leads', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Criar dashboard de métricas: leads, MQL, agendamentos, calls realizadas, vendas, CPL, CAC', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Definir metas numéricas do funil: nº vendas LEGACY → nº calls → nº agendamentos → nº MQL → nº leads → investimento tráfego', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 3, 'Criar roteiro de abordagem consultiva 1:1 para qualificação de leads inbound e outbound (baseado no Método Seven)', 'pendente', 'mentorado', 3, 'dossie_auto');


  -- ============================================================
  -- FASE 7: Produção de Anúncios Pagos
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Produção de Anúncios Pagos — Meta Ads para Sessão Estratégica e Signature', 'passo_executivo', 7, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 1, 'Gravar 5 anúncios do funil Sessão Estratégica / Signature conforme roteiros do dossiê', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Gravar anúncio: "Clínica de 400k travada" — platô + modo sobrevivência + CTA sessão estratégica', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Gravar anúncio: "Erro de 200 mil na expansão" — investimento sem modelo → Análise → Estratégia → Expansão', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Gravar anúncio: "Trabalhar 60h pra 500k vs 30h pra 1M" — modelo centrado no médico vs modelo de negócio', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 4, 'Gravar anúncio: "Checklist dos 500k para 1M" — 4 perguntas de diagnóstico + CTA sessão estratégica', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 5, 'Gravar anúncio: "O que acontece na Sessão Estratégica" — 3 passos: radiografia, gargalos, desenho da rota', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 2, 'Produzir Cortes da Turnê para uso como anúncio + orgânico (conteúdo já gravado, precisa editar)', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Editar corte: "Uma das coisas que impede você de cobrar mais" — começa direto na frase forte, sem abertura com plateia', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Editar corte: "Especialista sem critério vira aplicador aleatório" — diferença entre fazer procedimento e conduzir um caso', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Editar corte: "Clínica bonita, caixa vazio" — ilusão do cenário instagramável, modelo de negócio saudável', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 4, 'Editar corte: "Liderança e atitude influente" — postura do médico-dono diante da equipe', 'pendente', 'equipe_spalla', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 5, 'Editar corte: "Liberdade: parar de ser funcionário da própria clínica" — agenda estratégica vs agenda lotada', 'pendente', 'equipe_spalla', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 3, 'Configurar campanhas de Meta Ads com pelo menos 10 anúncios por quinzena (conversão direta, educacional, depoimento)', 'pendente', 'equipe_spalla', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Otimizar campanha para agendamento (não apenas lead) — objetivo: Calendly marcado', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Criar 3 variações de gancho por vídeo e testar A/B para identificar melhor performance', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Monitorar weeklys com João para revisar métricas e ajustar ganchos, criativos e páginas semanalmente', 'pendente', 'equipe_spalla', 3, 'dossie_auto');


  -- ============================================================
  -- FASE 8: Estruturação e Documentação do Banco de Provas Sociais
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Banco de Provas Sociais e Cases para Comercial e Anúncios', 'passo_executivo', 8, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 1, 'Criar planilha/documento com provas sociais separadas por categoria para uso em anúncios e ligações comerciais', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Levantar e documentar números reais de clientes: aumento de margem (ex: 3% → 28%), aumento de faturamento, mix reorganizado', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Documentar cases de times estruturados e clínicas que destravaram platô de crescimento', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Transformar números em ganchos de anúncio: "Clínica saiu de X% para Y% de margem em 6 meses"', 'pendente', 'equipe_spalla', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 4, 'Criar roteirinho rápido de prova social para o comercial usar no início das calls (contraste antes/depois)', 'pendente', 'equipe_spalla', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 2, 'Produzir 3 peças de prova social no formato vídeo para feed/reels Seven: case contraintuitivo (médico 500k que quase quebrou), linha do tempo 20 anos/30k médicos, impacto diagnóstico cirúrgico em 90 dias', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 3, 'Coletar novos depoimentos estruturados de clientes Signature (115 ativos) — formato texto + vídeo curto', 'pendente', 'mentorado', 3, 'dossie_auto');


  -- ============================================================
  -- FASE 9: Estruturação do Produto LEGACY e Materiais de Venda
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Estruturação do Produto LEGACY e Materiais de Venda', 'fase', 9, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 1, 'Documentar e revisar os 5 pilares do LEGACY com entregáveis claros e critérios de sucesso', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Pilar 1 — Sprint Estratégico: diagnóstico cirúrgico, mapa de crescimento 6 meses, prioridades validadas', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Pilar 2 — Conselho Estratégico: reuniões mensais individuais com Silvane, revisão de indicadores, decisões de alto nível', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Pilar 3 — Consultoria de Implementação: time Seven operando dentro da clínica, implantação de processos e ferramentas', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 4, 'Pilar 4 — Liderança, Gestão e Cultura: desenvolvimento do médico-dono como líder, construção de equipe autônoma', 'pendente', 'mentorado', 4, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 5, 'Pilar 5 — Mastermind Legacy: grupo exclusivo de médicos-empresários de elite, networking e inteligência coletiva', 'pendente', 'mentorado', 5, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 2, 'Criar material de apresentação do LEGACY para uso na call de vendas (não é pitch, é diagnóstico com dados na mesa)', 'pendente', 'equipe_spalla', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Estruturar apresentação em 3 momentos: radiografia dos números atuais, identificação de gargalos, desenho da rota de crescimento', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Incluir cases de before/after relevantes para o perfil do lead: médico em platô 300-500k → caminho para 1M', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Criar tabela de precificação com opções: R$122k à vista ou 12x R$16.400 — comunicação de valor, não de desconto', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 3, 'Revisar e atualizar materiais da Sessão Estratégica Gratuita: o que perguntar, como diagnosticar, como apresentar o LEGACY como solução natural', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 4, 'Criar fluxo de onboarding do cliente LEGACY após fechamento: boas-vindas, acesso ao Mastermind, início do Sprint Estratégico', 'pendente', 'equipe_spalla', 4, 'dossie_auto');


  -- ============================================================
  -- FASE 10: Rotinas de Monitoramento e Acompanhamento Comercial
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Rotinas de Monitoramento, Tráfego e Acompanhamento Comercial', 'passo_executivo', 10, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 1, 'Implementar reuniões semanais (weeklys) com gestor de tráfego para revisar métricas e ajustar criativos', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Definir pauta da weekly: resultados da semana (leads, agendamentos, calls), criativos em teste, próximas ações', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Criar ritual de aprovação de anúncios: Silvane revisa gancho/CTA antes do go-live para garantir alinhamento de posicionamento', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Ajustar anúncios semanalmente com base em dados reais de CTR, CPL e taxa de agendamento', 'pendente', 'equipe_spalla', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 2, 'Implementar rotina comercial: uso de provas sociais no início das calls + acompanhamento de pipeline', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Treinar comercial para usar isca de prova social no início: "Te conto o que aconteceu com uma clínica parecida com a sua…"', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Monitorar taxa de conversão call → proposta → fechamento mensalmente', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Ajustar roteiro de abordagem consultiva com base nos principais objetos levantados nas calls', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 3, 'Criar meta mensal de novos clientes LEGACY com retroalimentação para o funil: definir quantas calls são necessárias por fechamento', 'pendente', 'mentorado', 3, 'dossie_auto');


  -- ============================================================
  -- FASE 11: Estratégia de Conteúdo Seven (Perfil Institucional)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Estratégia de Conteúdo Seven — Perfil Institucional', 'fase', 11, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 1, 'Implementar calendário editorial Seven com 4 linhas principais: Prova Social Longa, Consciência do Problema, Prova Social Curta, Identificação/Inspiração', 'pendente', 'mentorado', 1, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 2, 'Produzir conteúdos de Identificação para o perfil Seven', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Criar conteúdo: "A armadilha invisível dos melhores médicos" — cresce pela intuição, agenda lotada, lucro baixo, clínica controla o médico', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Criar conteúdo: "O médico que trabalha mais e lucra menos" — sintomas: platô, equipe dependente, margem estagnada', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Criar conteúdo: "Você não vê, mas eu vejo: o potencial escondido da clínica" — olhar estratégico Seven vs especialista cansado', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 3, 'Produzir conteúdos de Consciência do Problema para o perfil Seven', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Criar conteúdo: "Gestão não é estratégia — e isso está travando sua clínica" — diferença entre organizar e crescer', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Criar conteúdo: "Por que clínicas de R$500 mil não têm margem proporcional?" — ineficiência, equipe dependente, médico gargalo', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Criar conteúdo: "Crescimento com intuição vs crescimento com modelo" — a intuição te trouxe até aqui, o modelo te leva pro próximo nível', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 4, 'Produzir Conversas Interessantes para geração de debate e viralização no perfil Seven', 'pendente', 'mentorado', 4, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Criar: "Faturamento alto não significa clínica saudável" — maior erro do mercado médico, gera discordância e viraliza', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Criar: "Impacto das mudanças de imposto no setor médico em 2025/2026" — Reforma Tributária e margens clínicas', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Criar: "Diferença entre mentoria com especialista em clínicas vs mentor de carreira própria" — quem só cresceu a própria clínica x quem consultou centenas', 'pendente', 'mentorado', 3, 'dossie_auto');


  -- ============================================================
  -- FASE 12: Storytelling Pessoal e Conteúdo de Conexão (Silvane)
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Storytelling Pessoal e Conteúdo de Conexão — Perfil Silvane', 'fase', 12, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 1, 'Produzir conteúdos da Linha DESCOBERTA para o perfil pessoal', 'pendente', 'mentorado', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Gravar: "A médica que DOBROU o faturamento e perdeu a equipe inteira" — crescimento sem base é castelo de areia', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Gravar: "Por que médicos que estudam 10+ anos têm MEDO de planilha?" — bloqueio emocional, não falta de capacidade', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Gravar: "O que 17 anos atendendo médicos me ensinou sobre sucesso" — crescer LEVA TEMPO, os que duram constroem com propósito', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 4, 'Gravar: "5 mentiras que gurus contam (e que quase quebraram meus clientes)" — desconstrução das 5 mentiras comuns do mercado', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 2, 'Produzir conteúdos da Linha CONEXÃO (Identificar) para o perfil pessoal', 'pendente', 'mentorado', 2, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Gravar: "O dia que quase desisti (e o que me fez continuar)" — motim da equipe, 60% do faturamento, propósito acima do ego', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Gravar: "Coisas que aprendi depois de errar, sofrer e quebrar a cara" — traição, perda de dinheiro, lealdade como valor', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Gravar: "A frase que eu repito pra mim quando quero desistir" — Ellen White, fé, olhar para trás e ver tudo vencido', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 4, 'Gravar: "O sacrifício que ninguém fala: tempo com quem ama" — segunda a sexta viajando, fim de semana sagrado para família', 'pendente', 'mentorado', 4, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 3, 'Produzir conteúdos da Linha DESEJO (Desejar) para o perfil pessoal', 'pendente', 'mentorado', 3, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Gravar: "Trabalhar de qualquer lugar quando você tem SISTEMA (não dependência)" — sistema = liberdade de escolher', 'pendente', 'mentorado', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Gravar: "Antes: médico refém da agenda / Depois: dono do próprio tempo" — capital interno + estrutura = escolher', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Gravar: "Do zero ao 7 dígitos: a jornada que TODOS os meus clientes de sucesso passaram" — sequência: capital interno → gestão → crescimento', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 4, 'Produzir conteúdo da Linha AUTORIDADE: "Como me tornei a maior consultoria de gestão médica do Brasil SEM ostentação" — CONSISTÊNCIA, credibilidade, overdelivery, 17 anos', 'pendente', 'mentorado', 4, 'dossie_auto');


  -- ============================================================
  -- FASE 13: Próximos Passos — Organização de Dados e Métricas
  -- ============================================================
  INSERT INTO pa_fases (plano_id, mentorado_id, titulo, tipo, ordem, status, origem)
  VALUES (_plano_id, 2, 'Organização de Dados, Métricas e Infraestrutura de Crescimento', 'passo_executivo', 13, 'nao_iniciado', 'dossie_auto')
  RETURNING id INTO _fase_id;

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem)
  VALUES (_fase_id, _plano_id, 2, 1, 'Separar e organizar os funis: Turnê Seven vs Sessão Estratégica LEGACY — CRM, UTMs e métricas distintas', 'pendente', 'equipe_spalla', 1, 'dossie_auto')
  RETURNING id INTO _acao_id;

  INSERT INTO pa_sub_acoes (acao_id, fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_acao_id, _fase_id, _plano_id, 2, 1, 'Arrumar CRM com campos padronizados + UTMs para rastreamento de origem por funil', 'pendente', 'equipe_spalla', 1, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 2, 'Criar dashboard de performance: leads, MQL, agendamentos, calls realizadas, vendas, CPL, CAC por funil', 'pendente', 'equipe_spalla', 2, 'dossie_auto'),
  (_acao_id, _fase_id, _plano_id, 2, 3, 'Definir e documentar metas numéricas retroativas: nº vendas LEGACY desejado → calls → agendamentos → MQL → leads → orçamento tráfego', 'pendente', 'mentorado', 3, 'dossie_auto');

  INSERT INTO pa_acoes (fase_id, plano_id, mentorado_id, numero, titulo, status, responsavel, ordem, origem) VALUES
  (_fase_id, _plano_id, 2, 2, 'Criar ritual quinzenal de revisão de resultados: tráfego + comercial + conteúdo — ajuste rápido de rota com dados reais', 'pendente', 'mentorado', 2, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 3, 'Mapear capacidade atual de atendimento LEGACY: quantos clientes simultâneos o modelo comporta sem comprometer qualidade do Conselho Estratégico', 'pendente', 'mentorado', 3, 'dossie_auto'),
  (_fase_id, _plano_id, 2, 4, 'Revisar e atualizar o dossiê estratégico em 90 dias com os aprendizados do funil, criativos e comercial — ciclo de melhoria contínua', 'pendente', 'mentorado', 4, 'dossie_auto');

END $$;
