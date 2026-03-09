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
