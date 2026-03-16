-- =============================================================================
-- CASE Mentoria — UPDATE mentorados com classificação IA
-- Gerado em: 2026-02-09 06:46
-- Total: 36 mentorados
-- =============================================================================

-- Danielle Ferreira (ID 1)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'primeiras_vendas',
  marco_atual = 'M2',
  risco_churn = 'baixo',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Danielle (esteticista, dona de clinica) entrou em Jul/2025, uma das mais antigas. Fez call de onboarding, estrategia com Queila, recebeu dossie. Fez primeira call de vendas para mentoria em 07/01/2026 (ticket R$60k) mas lead achou caro. Nao seguiu estrutura de call de vendas (nem sabia que tinha). Criou perfil @mentora separado, producao de conteudo consistente desde Jan/2026. Clinica explodiu de R$70k para R$300k/mes gracas ao reposicionamento aprendido na CASE. Comecou impulsionamento em Fev/2026. Possibilidade de fechar apos Carnaval.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Boas-vindas em 25/07/2025, call de onboarding mencionada"}, {"fase": "concepcao", "evidencia": "Call com Queila em 13/08/2025, dossie entregue em 14/08/2025, direcionamento continuo via WhatsApp"}, {"fase": "validacao", "evidencia": "Primeira call de vendas mentoria em 07/01/2026 (lead achou caro R$60k). Conteudo consistente. Impulsionamento iniciado em Fev/2026. Possibilidade de fechar pos-Carnaval."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 1;

-- Silvane Castro (ID 2)
UPDATE public.mentorados SET
  fase_jornada = 'concepcao',
  sub_etapa = 'conteudo_e_posicionamento',
  marco_atual = 'M1',
  risco_churn = 'baixo',
  cohort = 'N2',
  tem_produto = true,
  ja_vendeu = true,
  qtd_vendas_total = 45,
  faturamento_mentoria = 33527,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Silvane ja tem uma operacao existente (Seven Gestao) com time, produtos e trafego rodando. O CASE esta focado em escalar a operacao via conteudo, anuncios e posicionamento. Gargalo principal e formato de conteudo: Silvane e impostada/fria nos videos, nao conecta com audiencia. Time trabalhando em linha editorial, anuncios de Turne (ROAS 4.76-8.37) e estruturacao do Conselho. Gabriela (COO) e muito ativa e executa, mas depende da Silvane para gravar.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Entrou em 22/08/2025, call de onboarding em 25/08/2025. Concorrentes mapeados no mesmo dia."}, {"fase": "concepcao", "evidencia": "Dossie estrategico entregue em 05/12/2025. Linha editorial, lapidacao de perfil e ideias de conteudo produzidas. Reunioes com Hugo, Queila, Kaique e Lara ao longo de set-fev. Turne vendendo via trafego com ROAS positivo."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 2;

-- Flavianny Artiaga (ID 3)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'otimizacao_funil_e_comercial',
  marco_atual = 'M3',
  risco_churn = 'medio',
  cohort = NULL,
  tem_produto = true,
  ja_vendeu = true,
  qtd_vendas_total = 400,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Flavianny tem produto validado (curso CO2 com 400+ alunos) mas enfrenta saturação de mercado com concorrentes que copiaram seu material. Gargalo principal era equipe comercial antiética que sabotava vendas. Queila direcionou foco em melhorar posicionamento, produção de conteúdo e funil antes de lançar mentoria. Em dezembro/2025 pediu suspensão por agenda tumultuada (viagens China, EUA, livro), Queila alinhou pausa até pós-Carnaval mantendo acesso às aulas.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Grupo criado 20/08/2025, call onboarding 21/08/2025, concorrentes mapeados, análise de conteúdo entregue 09/09/2025."}, {"fase": "concepcao", "evidencia": "Estratégia definida: foco em posicionamento como referência em CO2, produção de conteúdo intencional, troca de equipe comercial."}, {"fase": "validacao", "evidencia": "Produto já validado (400+ alunos, 7+ turmas), mas ajustando posicionamento e comercial. Turma Goiânia teve 13 alunos. SP com 7 alunos em dez/2025. Mentoria de R$15K desenhada mas não lançada — Queila recomendou adiar para mar-mai/2026."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 3;

-- Paulo Rodrigues (ID 4)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'lapidar_perfil',
  marco_atual = 'M1',
  risco_churn = 'medio',
  cohort = NULL,
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Paulo e Mabel (assessora) estão na fase de produção de conteúdo e lapidação de perfil. Dossiê entregue, call de estratégia com Queila realizada em 24/09/2025. Primeiro vídeo no Instagram saiu em 11/11/2025. Frequência de publicação ainda baixa (3-4/semana, meta é 5). Não iniciou tráfego pago ainda. Queila orientou soltar 10-15 provas sociais e iniciar tráfego pago. Frank (social media) produzindo calendário. Call de acompanhamento com Heitor agendada para 06/02/2026. Calendário estratégico de fevereiro entregue.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Grupo WhatsApp desde 17/09/2025, call com Queila em 24/09/2025"}, {"fase": "concepcao", "evidencia": "Dossiê entregue em 24/09/2025, feedback de site Loom em 30/09/2025, materiais de aula enviados"}, {"fase": "validacao", "evidencia": "Primeiro vídeo em 11/11/2025, aula de funil em 18/11/2025, produção de conteúdo em andamento, call acompanhamento Heitor em 06/02/2026"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 4;

-- Raquilaine Pioli (ID 5)
UPDATE public.mentorados SET
  fase_jornada = 'concepcao',
  sub_etapa = 'estruturacao_funil_e_tecnica_venda',
  marco_atual = 'M1',
  risco_churn = 'baixo',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Raquilaine tem clinica grande em SP, bom posicionamento visual mas gap severo em tecnica de venda e trafego. Ofertas de mentoria ja estruturadas (R$60k e R$20-25k) mas ainda nao vendeu nenhuma. Campanhas de trafego tiveram problemas graves (conta bloqueada, gestor pouco comunicativo, leads desqualificados). Em fev/2026 esta cobrando avaliacao presencial para qualificar, contratando comercial e rodando anuncios novos com Gabriel (mkt).',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Entrou em 05/08/2025, call de onboarding em 11/08/2025. Download do expert com Queila em 14/08/2025."}, {"fase": "concepcao", "evidencia": "Ofertas estruturadas com Queila: Oculoplastica R$60k, Frontoplastia R$20k. Dossie entregue. Linha editorial definida. Tecnica de venda sendo treinada desde out/2025. Problemas de trafego com Rafa (out-dez/2025) atrasaram execucao."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 5;

-- Pablo Santos (ID 6)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'primeiras_vendas_mentoria',
  marco_atual = 'M2',
  risco_churn = 'medio',
  cohort = 'N2',
  tem_produto = true,
  ja_vendeu = true,
  qtd_vendas_total = 2,
  faturamento_mentoria = 30000,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Pablo fechou 1 venda confirmada de R$30k (contrato assinado e pago em 15/12) e teve um segundo lead verbal que nao concretizou. Atualmente esta gravando criativos para rodar formulario de aplicacao e trabalhar funil de trafego. Gargalo principal e a falta de tempo por excesso de operacional na clinica e crengas de escassez que o impedem de soltar atividades de menor valor.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Entrou em 11/09/2025, call de onboarding em 18/09/2025 com Queila."}, {"fase": "concepcao", "evidencia": "Oferta estruturada entre out-nov/2025: mentoria de gestao + tecnica, R$30k/12 meses. Plano de acao entregue em 07/10/2025. Call de estrategia em 02/10/2025."}, {"fase": "validacao", "evidencia": "Primeira venda fechada em 15/12/2025 (R$30k contrato assinado). Segundo lead nao converteu. Em jan/2026 esta focado em gravar criativos e rodar formulario para escalar abordagens."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 6;

-- Érica Macedo (ID 7)
UPDATE public.mentorados SET
  fase_jornada = 'concepcao',
  sub_etapa = 'definicao_oferta_e_posicionamento',
  marco_atual = 'M1',
  risco_churn = 'baixo',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Érica tem oferta desenhada (Full Regenera) e estratégia definida por Queila desde outubro/2025, mas não conseguiu executar por 4 meses — sem equipe de apoio digital, dificuldade com tecnologia e insegurança na abordagem comercial. Em janeiro/2026 o Heitor entrou para destravar a execução, pediu que ela estudasse material de vendas, abordasse 5 pessoas da lista e produzisse o PDF da mentoria. Em fevereiro/2026 ela assistiu a aula de vendas, precisa ainda enviar mensagem inicial para prospects, e tem call com Queila agendada para 11/02.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Grupo criado 22/09/2025, call onboarding com Gabriel, contrato assinado 04/10/2025."}, {"fase": "concepcao", "evidencia": "Call de acompanhamento 08/10/2025: Queila definiu posicionamento (especialista 40+ regeneração fullface), nome Full Regenera, oferta de R$8-12K, formato presencial 3-4 dias. Oferta entregue 14/10/2025. Calls em 26-27/01/2026 com Heitor revisando oferta e plano de ação comercial."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 7;

-- Rafael Castro (ID 8)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'lapidar_perfil',
  marco_atual = 'M1',
  risco_churn = 'alto',
  cohort = 'N2',
  tem_produto = true,
  ja_vendeu = true,
  qtd_vendas_total = 2,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Rafael está travado na execução. Tem 2 mentorados ativos mas pediu para pausar tráfego pago da mentoria porque não consegue abraçar mais demanda. Precisa gravar aulas de posicionamento e vendas (marketing já gravado). Ajustou agenda: quarta, sexta tarde e sábado de manhã para trabalhar na mentoria. Heitor fez call motivacional em 23/01/2026 para destravar. Meta: 2 vendas no primeiro trimestre de 2026. Potencial lead (médica de palestra) segurada porque não tem estrutura para receber.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Onboarding realizado anteriormente (não detalhado no digest)"}, {"fase": "concepcao", "evidencia": "Dossiê e plano de ação já entregues"}, {"fase": "validacao", "evidencia": "Tem 2 mentorados ativos, precisa gravar aulas e lapidar perfil. Call com Heitor em 23/01/2026 para destravar execução"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 8;

-- Juliana Altavilla (ID 9)
UPDATE public.mentorados SET
  fase_jornada = 'concepcao',
  sub_etapa = 'plano_acao',
  marco_atual = 'M1',
  risco_churn = 'medio',
  cohort = 'N2',
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Juliana (otorrinolaringologista, referencia em rinoplastia, MG) entrou em Set/2025 mas avancou devagar. Teve call de estrategia com Queila em 19/12/2025 focando em conteudo e posicionamento. Produziu roteiros e gravou conteudos em Nov/2025. Recebeu plano de anuncios para trafego em 22/01/2026. Frank (social media) esta ajustando linha editorial. Dificuldade principal: falta de tempo (agenda lotada de cirurgias, pai doente, ballet). Nao fez lista de potenciais mentorados ainda. Nao iniciou vendas.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Boas-vindas em 22/09/2025, call onboarding com Queila em 23/09/2025"}, {"fase": "concepcao", "evidencia": "Oferta entregue em 17/10/2025, call estrategia em 19/12/2025, plano de acao enviado, plano de anuncios em 22/01/2026. Roteiros produzidos e gravados em Nov/2025"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 9;

-- Flávia Nantes (ID 11)
UPDATE public.mentorados SET
  fase_jornada = 'otimizacao',
  sub_etapa = 'otimizar_entrega',
  marco_atual = 'M3',
  risco_churn = 'medio',
  cohort = 'N2',
  tem_produto = true,
  ja_vendeu = true,
  qtd_vendas_total = 40,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Flávia está em fase avançada mas em crise operacional. Já vendeu ~25-30 mentorias no primeiro ciclo (abril-outubro), mais vendas na Black Friday. Problema principal: hiper-personalização da entrega está gerando burnout. Queila orientou padronizar diagnóstico e planos de ação, fazer revisão de plano em grupo (não individual), contratar pessoa mais sênior para CS. Jennifer (consultora) contratada mas causando atrito no time. Mentoria com Queila oficialmente encerrou (13/09), mas Queila deu 2 meses extras de acompanhamento. Queila encoraja a decidir se quer continuar com o modelo de negócio e resolver produto antes de voltar a vender.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Mentorada desde aproximadamente março/abril 2025"}, {"fase": "concepcao", "evidencia": "Produto já concebido e validado anteriormente"}, {"fase": "validacao", "evidencia": "Vendeu ~25-30 mentorias no primeiro ciclo, teve renovações (poucas)"}, {"fase": "otimizacao", "evidencia": "Call de acompanhamento em 14/11/2025, foco em otimizar entrega e padronizar processos, resolver problema de hiper-personalização"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 11;

-- Lívia Lyra (ID 13)
UPDATE public.mentorados SET
  fase_jornada = 'escala',
  sub_etapa = 'estruturacao_ecossistema_e_novos_produtos',
  marco_atual = 'M5',
  risco_churn = 'baixo',
  cohort = NULL,
  tem_produto = true,
  ja_vendeu = true,
  qtd_vendas_total = 15,
  faturamento_mentoria = 500000,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Lívia é mentorada avançada com ecossistema robusto (formação, Impulse, Forends, clínica). Ultrapassou R$500K de faturamento combinado pela primeira vez. Está planejando evento presencial imersivo (30-31 jan/2026) com pitch para vender Impulse e Forends, estruturando time de marketing, e buscando escalar distribuição de conteúdo e tráfego pago. Queila a empurra para construir marca pessoal Lívia Lyra como referência nacional em flebologia.',
  historico_fases = '[{"fase": "concepcao", "evidencia": "Mentorada antiga (pré-2024), já teve oferta concebida e validada antes das calls registradas."}, {"fase": "validacao", "evidencia": "Impulse validado com primeiras turmas, método testado, primeiras vendas realizadas."}, {"fase": "otimizacao", "evidencia": "Renovação do Impulse em andamento, ajuste comercial, lapidação de método, faturamento estável na clínica (DRE estável nos últimos 12 meses)."}, {"fase": "escala", "evidencia": "Faturou >R$500K combinado, planejando evento presencial imersivo para jan/2026, estruturando time de marketing, lançando Forends (novo produto com parceiro), planejando tráfego pago e distribuição de conteúdo para escalar marca pessoal."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 13;

-- Thielly Prado (ID 30)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'preparando_evento_e_lista_de_leads',
  marco_atual = 'M2',
  risco_churn = 'baixo',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Thielly e a mais avancada do grupo. Entrou em 07/10/2025, ja tem dossie, produto estruturado (Metodo Protagonista), conteudos gravados e editados, novo Instagram criado, lista de 16 contatos quentes, e evento presencial planejado para marco/2026. Call de acompanhamento estrategico com Queila (13/11/2025 e 26/01/2026) ja realizadas. Proxima call agendada para 09/02/2026 com Lara e Heitor para acompanhamento do plano de acao do evento. Esta na fase de validacao preparando a primeira venda via evento.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Entrada em 07/10/2025. Call de onboarding com Queila realizada em 10/10/2025."}, {"fase": "concepcao", "evidencia": "Dossie entregue em 29/10/2025. Oferta e posicionamento definidos. Acessos ao HubCaseIA liberados em 23/10/2025. Produto: mentoria de alto padrao para estetica/beleza."}, {"fase": "validacao", "evidencia": "Gravou conteudos em lote (01/12/2025 e 18-19/12/2025). Recebeu feedbacks de edicao. Lista de 16 contatos enviada em 19/01/2026. Call de direcionamento estrategico com Queila em 26/01/2026 definiu evento presencial como funil. Nome do produto definido: Metodo Protagonista (02/02/2026). Evento planejado para 09 ou 16/03/2026."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 30;

-- Deisy Porto (ID 31)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'primeiras_vendas',
  marco_atual = 'M2',
  risco_churn = 'baixo',
  cohort = 'N2',
  tem_produto = true,
  ja_vendeu = true,
  qtd_vendas_total = 12,
  faturamento_mentoria = 115800,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Deisy (psiquiatra infantil, Florianopolis) e uma das mentoradas mais executoras. Vendeu 7 mentorias iniciais (R$7k cada, total R$49k), depois mais vendas chegando a R$115.800 total ate 29/12/2025. Em Jan/2026 vendeu mais 2 mentorias para novos leads (nao vindos do curso). Fez aulao pago (R$97) em 05/02 com 23 vendas + vendas pos-aula. Producao de conteudo consistente, contratou equipe de gravacao. Trafego pago iniciado. Marido Marcelo atua como socio no comercial/financeiro.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Boas-vindas em 09/10/2025, call onboarding com Queila (referenciada como 16/10)"}, {"fase": "concepcao", "evidencia": "Call de acompanhamento em 24/10/2025 com Queila, dossie/oferta refinada, arquitetura de 6 pilares enviada em 24/10"}, {"fase": "validacao", "evidencia": "7 mentorias vendidas inicialmente (R$49k), total R$115.800 ate 29/12. Mais 2 mentorias em Jan/2026. Aulao pago em 05/02 com 23 vendas + conversoes"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 31;

-- Amanda Ribeiro (ID 32)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'executando_funil_abordagem_lista',
  marco_atual = 'M2',
  risco_churn = 'medio',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = true,
  qtd_vendas_total = 1,
  faturamento_mentoria = 10000,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Amanda ja vendeu 1 mentoria por R$10k antes de entrar na CASE. Teve 3 calls (23/10, 31/10, conteudo com Lara). Dossie entregue, 24 aulas gravadas, videos editados para Instagram da mentoria. Criou Instagram da mentoria em collab. Tem calls de venda agendadas (reagendou uma para incluir marido como decisor). Esta travada em conteudo ha 3 meses, sentindo-se engolida por falta de processos e comercial. Quer contratar alguem para comercial (10-20% comissao). Ultima mensagem WhatsApp: 23/01/2026.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Call de download em 23/10/2025 com Queila"}, {"fase": "concepcao", "evidencia": "Call de posicionamento e conteudo em 31/10/2025, dossie e arquitetura de produto entregues"}, {"fase": "validacao", "evidencia": "24 aulas gravadas, videos editados, calls de venda agendadas (jan/2026), close friends ativo, 1 venda previa de R$10k"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 32;

-- Lauanne Santos (ID 33)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'executar_funil',
  marco_atual = 'M1',
  risco_churn = 'medio',
  cohort = 'N2',
  tem_produto = true,
  ja_vendeu = true,
  qtd_vendas_total = 1,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Lauanne (dentista/empreendedora, Florianopolis) entrou em Out/2025, teve 4 calls com Queila + call de alinhamento em 02/12. Fez evento presencial gratuito em Dez/2025 mas sem pitch estruturado. Fechou 1 venda de uma lead do G4. Perdeu mentorados da The One (churn na entrega). Agora em Jan/2026 retomando com foco em producao de conteudo, proximo workshop pago (tema: aumentar ticket medio de forma etica), e inicio de trafego pago. Medo de frustracao e dificuldade em fechar vendas sao bloqueios recorrentes.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Boas-vindas em 21/10/2025, primeira call com Queila em 24/10/2025"}, {"fase": "concepcao", "evidencia": "Calls de acompanhamento em 24/10, 31/10, call sem data, alinhamento em 02/12/2025. Dossie e plano de acao entregues em 03/11/2025"}, {"fase": "validacao", "evidencia": "Evento presencial realizado em Dez/2025, 1 venda fechada de lead do G4, iniciando producao de conteudo e trafego em Jan/2026"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 33;

-- Karine Canabrava (ID 34)
UPDATE public.mentorados SET
  fase_jornada = 'concepcao',
  sub_etapa = 'paralisia_emocional_risco_churn',
  marco_atual = 'M1',
  risco_churn = 'critico',
  cohort = 'N2',
  tem_produto = true,
  ja_vendeu = true,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Karine está em situação crítica de churn. Sofreu crise reputacional grave em dezembro/2025 que a paralisou emocionalmente - parou de vender, de produzir conteúdo e quase desistiu da mentoria. Na call de 13/01/2026, Queila trabalhou o emocional e deu prazo de 2 semanas para decisão. Desde 02/02/2026 não responde mensagens no grupo (7 dias de silêncio).',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Entrada em 07/10/2025. Call com Queila em 24/10/2025 - entendimento profundo do produto, público, modelo de venda e gargalos de escala."}, {"fase": "concepcao", "evidencia": "Call acompanhamento 07/11/2025 - discussão de arquitetura de produto, linhas editoriais, plano de conteúdo. Dossiê/concepção entregue 15/11/2025. Feedback de vídeos em novembro (copy, edição, posicionamento). Evento FGG presencial realizado em 03-04/12/2025."}, {"fase": "concepcao", "evidencia": "Call estratégia 13/01/2026 - crise reputacional, paralisia emocional, bloqueio de vendas. Queila ofereceu renegociação ou continuidade. Karine pediu 2 semanas. Call com Heitor 27/01/2026 para renegociação de contrato."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 34;

-- Hevellin Felix (ID 36)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'preparando_abordagem_lista',
  marco_atual = 'M1',
  risco_churn = 'alto',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Hevellin teve 3 calls (20/11, 23/01 com Heitor, call de oferta com Queila sem data). Dossie entregue com oferta, lapidacao de perfil e ideias de conteudo. Viajou 1 mes para EUA em ferias, atrasando execucao. Na call de 23/01 com Heitor, revisou produto e proximos passos (revisar oferta, abordar base de ~25 ex-alunos, lapidar perfil, estudar aula de vendas). Contrato ainda pendente de assinatura. Tambem cursa medicina paralelamente. Mora no Acre.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Call de acompanhamento/download em 20/11/2025 com Queila"}, {"fase": "concepcao", "evidencia": "Dossie entregue com oferta, lapidacao, ideias de conteudo. Call de oferta com Queila onde validou oferta e definiu funil"}, {"fase": "validacao", "evidencia": "Call de acompanhamento do plano de acao em 23/01/2026 com Heitor, proximos passos: abordar lista, lapidar perfil, gravar anuncios"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 36;

-- Leticia Ambrosano (ID 37)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'abordagem_lista_em_andamento',
  marco_atual = 'M1',
  risco_churn = 'medio',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Leticia teve call de download (30/10), call de validacao de oferta (21/11), e participa dos Conselhos semanais. Dossie entregue com oferta, lapidacao de perfil, ideias de conteudo. Abordou lista de ex-alunos e contatos: mandou msg para ~5 iniciais, fez 3 ligacoes de qualificacao (nenhum fechou, todos com desculpas financeiras), 1 call de venda que nao deu certo (lead nao qualificado). Tem 1 call agendada para sabado (05/02). Ativa em stories, apanhando com reels e copy. Ultima interacao WhatsApp: 05/02/2026.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Boas-vindas ao grupo em 27/10/2025, call de download em 30/10/2025"}, {"fase": "concepcao", "evidencia": "Call de validacao de oferta e funil em 21/11/2025, dossie entregue com oferta e lapidacao"}, {"fase": "validacao", "evidencia": "Abordagem de lista em andamento (jan-fev/2026), 1 call de venda realizada (ruim), gravou videos, call agendada para sabado"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 37;

-- Tatiana Clementino (ID 38)
UPDATE public.mentorados SET
  fase_jornada = 'concepcao',
  sub_etapa = 'posicionamento_e_conteudo',
  marco_atual = 'M1',
  risco_churn = 'baixo',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Tatiana esta em fase de concepcao avancada focada em posicionamento e producao de conteudo. Ja definiu oferta (Protocolo Decada, turmas de 4, R$20k), ja contratou gestor de trafego (Rafael), esta produzindo videos e trabalhando posicionamento no Instagram. Primeira turma planejada para maio/2026. Aguardando call com Lara para reajuste de plano e definicao final do nome do curso.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Boas-vindas em 05/11/2025. Primeira call com Queila em 08/11/2025 (download)."}, {"fase": "concepcao", "evidencia": "Call estrategia 23/12/2025: pivotou de labios para Full Face avancado. Call acompanhamento (feriado ~20/11): definicao programa aperfeicoamento, ticket 20k, turmas de 4. Dossie entregue 28/11/2025. Producao de conteudo e videos em andamento. Contratou gestor de trafego. Nome definido: Protocolo Decada (06/02/2026)."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 38;

-- Maria Spindola (ID 39)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'conteudo_e_primeiras_abordagens',
  marco_atual = 'M1',
  risco_churn = 'baixo',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Maria esta em validacao focada em producao de conteudo e primeiras abordagens de venda. Mora nos EUA, o que adiciona complexidade logistica. Recebeu analise completa de conteudo da Queila (video privado), esta melhorando copies e formatos de video. Tem lista de prospects pronta (~10 do Instagram + 3 conhecidas). Ainda nao fechou venda mas esta tentando converter leads quentes. Engajamento no Instagram ainda baixo.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Boas-vindas 01/11/2025. Primeira call com Queila 07/11/2025."}, {"fase": "concepcao", "evidencia": "Segunda call (plano de acao) com Queila: definicao oferta individual R$15-20k, 6 meses, quinzenal. Dossie entregue. Linha editorial e funil definidos."}, {"fase": "validacao", "evidencia": "Producao de conteudo ativa desde jan/2026. Analise completa de conteudo pela Queila em 22/01. Lista de prospects montada. Tentativa de venda diagnostico para lead quente (sem sucesso ainda). Videos melhorando apos feedback."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 39;

-- Caroline Bittencourt (ID 40)
UPDATE public.mentorados SET
  fase_jornada = 'concepcao',
  sub_etapa = 'dossie_entregue_plano_acao',
  marco_atual = 'M1',
  risco_churn = 'alto',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Caroline teve 3 calls (07/11, 21/11 x2). Dossie entregue com oferta, plano de acao e lapidacao de perfil. Queila validou oferta na segunda call e planejou evento para Janeiro. Caroline viajou no final de Novembro e recebeu plano de acao para executar em Dezembro. Dona de clinica odontologica em Vila Velha, fatura ~R$200-300k/mes na clinica. Lista de ~400 profissionais nos melhores amigos do Instagram. Ultima interacao identificavel nas calls e em 21/11/2025.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Call de acompanhamento/download em 07/11/2025 com Queila"}, {"fase": "concepcao", "evidencia": "Call de estrategia + oferta em 21/11/2025, dossie entregue, plano de acao definido"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 40;

-- Marina Mendes (ID 41)
UPDATE public.mentorados SET
  fase_jornada = 'concepcao',
  sub_etapa = 'pausa_contratual',
  marco_atual = 'M1',
  risco_churn = 'critico',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Marina esta em pausa contratual desde janeiro/2026. Recebeu dossie completo, definiu nome H6, teve 2 calls de concepcao com Queila. Porem houve impasse no contrato - seu juridico orientou a nao assinar. Grupo foi fechado em 16/01/2026 ate retorno previsto em marco/2026. Nao ha atividade desde 16/01. Risco critico de churn pela inatividade prolongada e questao contratual nao resolvida.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Boas-vindas 05/11/2025. Primeira call com Queila 11/11/2025."}, {"fase": "concepcao", "evidencia": "Segunda call: validacao oferta, ticket R$15k ancorado em R$25k, nome H6, dossie entregue 26/11/2025. Instagram novo criado (dramarina.h6). Interesse de lead recebido em 08/12 mas nao convertido."}, {"fase": "pausa", "evidencia": "10/12/2025: pediu contato com financeiro. 02/01-09/01/2026: discussao contratual. 13/01: juridico orientou a nao assinar. 16/01: grupo fechado, acessos suspensos ate retorno em marco/2026."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 41;

-- Carolina Sampaio (ID 42)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'preparando_abordagem_lista',
  marco_atual = 'M1',
  risco_churn = 'critico',
  cohort = NULL,
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Carolina recebeu o dossie e oferta estruturada, fez call de acompanhamento do plano de acao em 20/01/2026. Ja ajustou oferta, fez lapidacao basica de perfil, e tem um lead quente (Amelia, dona de clinica no interior que quer alugar laser). Ainda nao fez call de venda, nao abriu PJ, e tem dificuldade com execucao/organizacao (TDAH). Precisa urgentemente abordar lista e fechar primeiras vendas.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Call de oferta (sem data) + call de onboarding (sem data) com Heitor e Queila"}, {"fase": "concepcao", "evidencia": "Dossie entregue com oferta estruturada, storytelling, lapidacao de perfil e ideias de conteudo"}, {"fase": "validacao", "evidencia": "Call de acompanhamento do plano de acao em 20/01/2026, lead quente (Amelia), preparando abordagens de lista"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 42;

-- Mônica Felici (ID 43)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'preparacao_primeira_venda_funil',
  marco_atual = 'M1',
  risco_churn = 'baixo',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = true,
  qtd_vendas_total = 7,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Mônica está na fase de validação, preparando seu primeiro lançamento via funil CASE. Dossiê entregue em 07/01/2026, criativos gravados e em revisão, evento de lançamento adiado para 04/03/2026. Já vendeu 7 unidades informalmente para alunos da pós-graduação antes de entrar no CASE, mas ainda não executou venda pelo funil estruturado.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Call de onboarding com Heitor em 24/11/2025. Apresentação do time, download do expert, explicação da jornada CASE."}, {"fase": "concepcao", "evidencia": "Call de oferta com Queila em 03/12/2025 (definição de público, ticket R$12K, formato dinâmico sem turma). Call de estratégia em 19/12/2025 (dossiê apresentado, funil de aula gratuita + captação + pitch definido, tema de aula validado com alunos)."}, {"fase": "validacao", "evidencia": "Dossiê entregue 07/01/2026. Criativos gravados 23/01/2026, enviados para revisão 29/01/2026. Evento adiado para 04/03/2026. Equipe de social media (Mariana) envolvida na produção."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 43;

-- Renata Aleixo (ID 44)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'executar_funil',
  marco_atual = 'M1',
  risco_churn = 'baixo',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Renata e Rodrigo (marido/estrategista) estão em fase avançada de preparação para lançamento. Dossiê entregue em 10/01/2026, oferta definida, nome da mentoria em fase final (Nutri Reset ou Next Nutri). Já possuem 850+ leads de fornecedores, equipe de social media e tráfego contratada, Instagram novo sendo criado, captação de conteúdo marcada para 13/02, e uma potencial primeira venda presencial em março. Perfil novo ainda vazio mas estrutura robusta sendo montada.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Call de onboarding realizada em 21/11/2025, contrato assinado, grupo WhatsApp criado em 18/11/2025"}, {"fase": "concepcao", "evidencia": "Call de oferta com Queila em 04/12/2025, call de estratégia 2 em 18/12/2025, call de estratégia 3 em 23/12/2025, dossiê entregue em 10/01/2026"}, {"fase": "validacao", "evidencia": "Call de acompanhamento plano de ação em 19/01/2026, preparando funil, lista de 850 leads, captação de conteúdo para 13/02, Instagram novo sendo preparado"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 44;

-- Letícia Oliveira (ID 45)
UPDATE public.mentorados SET
  fase_jornada = 'concepcao',
  sub_etapa = 'dossie_em_producao',
  marco_atual = 'M1',
  risco_churn = 'baixo',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = true,
  qtd_vendas_total = 6,
  faturamento_mentoria = 108000,
  dossie_entregue = false,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Letícia está em fase de concepção com dossiê pré-pronto após 4 calls (onboarding + acompanhamento + 2 calls estratégia com Queila). Expert com problema de saúde (câncer de mama, terminando tratamento). Já vendeu mentoria há 3 anos (6 alunas, R$18K cada). Possui esteira de produtos digitais rodando (vendeu 90+ do produto de R$497 na Black Friday). Queila está redefinindo oferta e posicionamento para focar em artesãs que já faturam 5-10K+ e querem escalar. Grupo WhatsApp criado recentemente em 03/02/2026.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Call de onboarding realizada (sem data específica), grupo WhatsApp criado em 03/02/2026"}, {"fase": "concepcao", "evidencia": "Call de acompanhamento em 26/01/2026, call de estratégia com Queila em 10/12/2025, segunda call de estratégia em 22/12/2025, dossiê pré-pronto"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 45;

-- Juliana Takasu (ID 46)
UPDATE public.mentorados SET
  fase_jornada = 'onboarding',
  sub_etapa = 'call_estrategia_pendente',
  marco_atual = 'M0',
  risco_churn = 'medio',
  cohort = NULL,
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = false,
  call_estrategia_realizada = false,
  call_onboarding_realizada = true,
  resumo_status = 'Juliana Takasu (terapeuta capilar/head spa, Barretos/SP) completou apenas o call de onboarding com Heitor (as 2 calls no digest sao duplicatas do mesmo onboarding). Call de estrategia com Queila ainda nao agendada. Tem forte base de cursos online (~42 alunos head spa, ~13 massagem) e presenciais. Viajou para Coreia em Janeiro para trazer novidades. Sem dossie, sem plano de acao. Bio do Instagram precisa de ajuste (ja incomodava antes do onboarding). Publico-alvo: profissionais de estetica, medicos (dermatologistas, tricologistas).',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Call de onboarding com Heitor realizada (sem data, mas pre-viagem Coreia em Janeiro). Proximo passo: call com Queila."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 46;

-- Anna e Paula (Kava) (ID 47)
UPDATE public.mentorados SET
  fase_jornada = 'concepcao',
  sub_etapa = 'dossie_entregue',
  marco_atual = 'M1',
  risco_churn = 'baixo',
  cohort = 'N1',
  tem_produto = false,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Anna e Paula (Kava Arquitetura, RJ/SP) completaram onboarding com Heitor, 2 calls de estrategia com Queila (19/12 e 09/12), e call de acompanhamento do plano de acao (19/01). Dossie entregue, estao na fase de lapidacao de perfil, construcao de lista de contatos e preparacao de evento/aula de venda agendada para 09/03. Produto de mentoria ainda sendo definido (organizacao de escritorio vs home office). Proximos passos: finalizar lapidacao de perfil, criar grupo WhatsApp, comecar convites dia 25/02.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Call onboarding com Heitor realizada (sem data especifica)"}, {"fase": "concepcao", "evidencia": "Call estrategia com Queila em 19/12/2025, segunda call estrategia em 09/12/2025, dossie entregue, call acompanhamento plano de acao em 19/01/2026"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 47;

-- Gustavo Guerra (ID 48)
UPDATE public.mentorados SET
  fase_jornada = 'concepcao',
  sub_etapa = 'plano_acao',
  marco_atual = 'M1',
  risco_churn = 'baixo',
  cohort = 'N1',
  tem_produto = false,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Gustavo (oftalmologista especialista em blefaroplastia a laser, Volta Redonda/RJ) entrou recentemente com ticket alto de investimento na mentoria. Completou onboarding, call de estrategia e call de acompanhamento do plano de acao (19/01/2026). Dossie entregue com oferta de R$10-15k. Tem lista de ~40 colegas medicos interessados + seguidores no Instagram. Proximos passos: lapidacao de perfil, producao de conteudo, abordagem da lista, formulario de aplicacao no Typeform. Membro de sociedades internacionais, perfil ultra premium.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Call 1 (fragmento de pagamento) + Call 2 onboarding completo com Heitor"}, {"fase": "concepcao", "evidencia": "Dossie entregue, call de acompanhamento do plano de acao em 19/01/2026 com Heitor. Definindo oferta R$10-15k, lapidacao de perfil em andamento"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 48;

-- Camille Braganca (ID 49)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'primeiras_abordagens_conteudo',
  marco_atual = 'M1',
  risco_churn = 'baixo',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Camille teve onboarding com Heitor (28/11) e call de estrategia com Queila (09-10/12/2025). Dossie em elaboracao/entregue. Muito ativa no WhatsApp: criando roteiros de carrossel e video, interagindo com Lara e time sobre conteudo. Em 02/02/2026 fez call com lead de Portugal que quer vir em Abril, dentista interessada em 2 dias + 6 meses acompanhamento. Lead muito quente, pedindo proposta. Camille esta nervosa mas motivada. Marido (Gustavo) e cirurgiao e mentorado CASE tambem.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Call de onboarding com Heitor em 28/11/2025"}, {"fase": "concepcao", "evidencia": "Call de estrategia com Queila em 09-10/12/2025, dossie com oferta, lapidacao e ideias de conteudo"}, {"fase": "validacao", "evidencia": "Criando conteudo (carrosseis, roteiros video), lead quente de Portugal (02/02/2026), estudando aula de vendas"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 49;

-- Miriam Alves (ID 50)
UPDATE public.mentorados SET
  fase_jornada = 'validacao',
  sub_etapa = 'primeiras_calls_de_venda',
  marco_atual = 'M2',
  risco_churn = 'baixo',
  cohort = 'N1',
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Miriam esta em fase de validacao ativa. Ja montou produto na Kiwify, gravou cirurgias e aulas, fez 7+ calls de venda em 04-05/02 com leads quentes. Nenhum fechamento ainda, porem teve 7 contatos interessados e esta melhorando habilidade de fechamento com coaching do Heitor. Principal gargalo e inseguranca no fechamento da venda.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Call de onboarding em 12/12/2025 com Heitor. Boas-vindas em 08/12/2025."}, {"fase": "concepcao", "evidencia": "Call de estrategia com Queila em 19/12/2025. Definicao de oferta (capacitacao em cirurgia refrativa para oftalmologistas). Tarefas: pesquisa de mercado, preco concorrentes, sondagem em grupos."}, {"fase": "validacao", "evidencia": "A partir de 02/02/2026: abordagem de lista, calls de venda (4-5 no primeiro dia, mais no segundo), montagem de produto na Kiwify, gravacao de cirurgias e aulas. Heitor acompanhou call ao vivo em 05/02 e deu feedback detalhado."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 50;

-- Michelle Novelli (ID 132)
UPDATE public.mentorados SET
  fase_jornada = 'concepcao',
  sub_etapa = 'dossie_recebido_aguardando_apresentacao',
  marco_atual = 'M0',
  risco_churn = 'baixo',
  cohort = NULL,
  tem_produto = false,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Michelle é a mentorada mais recente, entrou em 20/01/2026. Concepção acelerada: onboarding em 22/01 e call de estratégia com Queila em 26/01. Dossiê entregue em 06/02/2026. Muito engajada e motivada, já fornecendo feedbacks técnicos sobre o dossiê. Próximo passo: apresentação do funil e conteúdo com Heitor/Lara na semana de 10/02.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Call de onboarding com Heitor em 22/01/2026. Apresentação da jornada CASE, levantamento de ideias de produto (glúteo, ultrassom, celulite), mapeamento de público (médicos de várias especialidades)."}, {"fase": "concepcao", "evidencia": "Call de estratégia com Queila em 26/01/2026 (NOTA: calls 2 e 3 são duplicatas do mesmo arquivo). Definição de oferta: treinamento presencial 2 dias, 4 pessoas, foco em subcisão para celulite + ultrassom. Ticket R$30-35K. Dossiê entregue 06/02/2026."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 132;

-- Tayslara Belarmino (ID 133)
UPDATE public.mentorados SET
  fase_jornada = 'concepcao',
  sub_etapa = 'dossie_entregue_aguardando_apresentacao',
  marco_atual = 'M1',
  risco_churn = 'baixo',
  cohort = NULL,
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = true,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Tayslara completou onboarding (24/01/2026) e call de estrategia com Queila (28/01/2026). Dossie estrategico foi entregue em 07/02/2026. Produto concebido: mentoria de 6 meses para medicos iniciantes (tecnica + gestao de clinica), ticket R$15k. Aguarda call de apresentacao do dossie com Heitor e inicio da fase de validacao/lapidacao de perfil. Encontrou concorrente inspiracao no Instagram em 08/02/2026, sinalizando engajamento ativo.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Entrada em 19/01/2026, onboarding call em 24/01/2026 com Heitor. Preencheu formulario de concorrentes em 27/01."}, {"fase": "concepcao", "evidencia": "Call de estrategia com Queila em 28/01/2026. Definicao de publico (medicos iniciantes), produto (mentoria tecnica+gestao), ticket (R$15k/6 meses). Dossie entregue em 07/02/2026."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 133;

-- Rosalie Torrelio (ID 135)
UPDATE public.mentorados SET
  fase_jornada = 'concepcao',
  sub_etapa = 'call_estrategia_agendada',
  marco_atual = 'M0',
  risco_churn = 'baixo',
  cohort = NULL,
  tem_produto = false,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = false,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Rosalie fez call de onboarding em 28/01/2026 e call de estratégia com Queila agendada para 03/02/2026 às 9h30. É cirurgiã plástica com clínica em Vitória/ES, coordenadora do Hospital Infantil. Não tem produto digital definido ainda. Motivação: ajudar médicos recém-formados com gestão de clínica (identifica que médicos não aprendem isso na faculdade). Tem 6h/semana reservadas para a mentoria. Formulário de concorrentes preenchido, contrato assinado.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Grupo WhatsApp criado em 20/01/2026, call de onboarding em 28/01/2026"}, {"fase": "concepcao", "evidencia": "Call de estratégia com Queila agendada para 03/02/2026 às 9h30"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 135;

-- Karina Cabelino (ID 136)
UPDATE public.mentorados SET
  fase_jornada = 'onboarding',
  sub_etapa = 'call_onboarding_realizada',
  marco_atual = 'M0',
  risco_churn = 'medio',
  cohort = NULL,
  tem_produto = false,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = false,
  call_estrategia_realizada = false,
  call_onboarding_realizada = true,
  resumo_status = 'Karina fez call de onboarding (sem data registrada), recebeu link para preencher formulário de concorrentes e contrato. Está no início absoluto - não tem produto definido, apenas ''a coragem e um sonho''. Clínica de harmonização facial em cidade pequena (Itaperuna/RJ), fatura ~R$150K/mês. Tem dificuldade com precificação - concorrentes locais vendem mentoria por R$2K. Aguardando call de estratégia com Queila. Pagamento parcial feito (PIX de R$5K, restante quando cartão chegar - cartão clonado).',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Call de onboarding realizada (data não registrada), formulário de concorrentes enviado, contrato pendente de cartão"}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 136;

-- Yara Gomes (ID 137)
UPDATE public.mentorados SET
  fase_jornada = 'concepcao',
  sub_etapa = 'call_estrategia_realizada_aguardando_dossie',
  marco_atual = 'M1',
  risco_churn = 'medio',
  cohort = NULL,
  tem_produto = true,
  ja_vendeu = false,
  qtd_vendas_total = 0,
  faturamento_mentoria = 0,
  dossie_entregue = false,
  call_estrategia_realizada = true,
  call_onboarding_realizada = true,
  resumo_status = 'Yara completou onboarding e call de estrategia com Queila (29/01/2025). Produto definido: mentoria de gestao e faturamento para profissionais da estetica. Fatura ~R$120-150k/mes na clinica com 2.5 anos. Queila viu alto potencial executor. Nao ha evidencia de dossie entregue ainda nem interacoes WhatsApp pos-call de estrategia. Sem dados de atividade recente, o que eleva risco de churn para medio.',
  historico_fases = '[{"fase": "onboarding", "evidencia": "Onboarding call com Heitor realizado (data nao especificada, arquivo sem data). Definiu interesse em mentoria de gestao/faturamento sem tecnica hands-on."}, {"fase": "concepcao", "evidencia": "Call de estrategia com Queila em 29/01/2025. Definicao de oferta: mentoria de gestao para esteticistas, ticket R$10-15k. Queila identificou perfil executor e elogiou potencial."}]'::jsonb,
  ultimo_processamento = now()
WHERE id = 137;
