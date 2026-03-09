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
