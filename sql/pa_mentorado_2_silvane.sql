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
