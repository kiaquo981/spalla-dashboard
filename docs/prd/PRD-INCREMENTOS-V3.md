# PRD — Spalla Dashboard v3: Incrementos Estrategicos

**Autor:** Aria (Architect Agent)
**Data:** 2026-03-06
**Versao:** 3.0
**Baseado em:** Analise completa do sistema (app.js 2791 linhas, 9 paginas, 5 APIs integradas, 12+ tabelas, 9 views SQL)

---

## 1. Contexto: Como o Sistema e Usado Hoje

### 1.1 Uso Diario (Equipe CASE — 6 pessoas)

**Manha (~9h):**
- Abrir Dashboard → verificar KPIs (risco critico, msgs pendentes, tarefas)
- Checar widget de pendencias WhatsApp → marcar respondidas
- Filtrar mentorados por `com_pendencia` ou `risco critico` → priorizar atendimentos
- Abrir WhatsApp → responder mensagens urgentes dos grupos

**Durante o dia:**
- Abrir detail de mentorado antes de call → ler contexto IA, gargalos, ultimas decisoes
- Criar/atualizar tarefas no board (pendente → em_andamento → concluida)
- Agendar calls via Agenda → Zoom + Calendar automatico
- Criar lembretes pessoais para follow-ups

**Fim do dia (~18h):**
- Revisar tarefas atrasadas → reagendar ou delegar
- Verificar mentee cards com engagement baixo
- Checar dossies em producao

### 1.2 Uso Semanal (Segunda/Sexta)

**Segunda:**
- Revisao geral: quem esta critico? quem nao teve call ha 21d+?
- Planejar calls da semana via Agenda
- Sync Google Sheets → atualizar financeiro

**Sexta:**
- Revisao de tarefas concluidas vs pendentes
- Verificar mentorados sem atividade WA 7d
- Preparar contexto para Conselho de Grupo (segunda)

### 1.3 Uso Mensal (Queila — Lider)

- Analise de cohort: quantos em cada fase?
- Verificar evolucao de marcos (M0→M5)
- Avaliar mentorados para mudanca de fase
- Revisar inadimplentes e contratos pendentes
- Direcionamentos estrategicos para equipe

---

## 2. Gaps Identificados no Uso Atual

| # | Gap | Impacto | Onde Afeta |
|---|-----|---------|------------|
| G1 | Sem visao temporal de evolucao do mentorado | Equipe nao sabe se mentorado esta evoluindo ou estagnando | Detail, Dashboard |
| G2 | Sem alertas proativos (so reativo) | Problemas detectados tarde demais | Dashboard |
| G3 | Sem relatorios/exports | Queila precisa montar manualmente | Dashboard, Detail |
| G4 | Sem timeline unificada no detail | fn_god_alerts existe mas nao e usado no frontend | Detail |
| G5 | Sem automacao de tarefas recorrentes | Equipe recria mesmas tarefas todo mes | Tasks |
| G6 | Agenda sem visao de disponibilidade | Conflitos de horario | Agenda |
| G7 | Dossies sem workflow real | Status muda manual, sem notificacao | Dossies |
| G8 | Sem metricas de performance da equipe | Queila nao sabe quem esta sobrecarregado | Dashboard |
| G9 | WhatsApp sem templates/respostas rapidas | Equipe digita mesmas msgs repetidamente | WhatsApp |
| G10 | Sem integracao de vendas real-time | Dados de venda entram manual ou por sheets | Detail, Dashboard |
| G11 | Sem dashboard mobile otimizado | Cards quebram em tela pequena | Responsivo |
| G12 | Sem historico de mudancas de fase | Nao sabe quando mentorado mudou de fase | Detail |
| G13 | Sem notificacoes push/email | Equipe so ve alertas quando abre o dashboard | Global |

---

## 3. Incrementos Planejados (4 Waves)

---

### WAVE 1: Quick Wins (1-2 semanas) — Valor Imediato

#### 1.1 Sistema de Alertas Visuais no Dashboard
**Prioridade:** CRITICA
**Esforco:** Baixo (frontend only, dados ja existem)

**O que:** Usar `fn_god_alerts()` que ja retorna 5 tipos de alerta (sem_resposta, sem_call, tarefas_atrasadas, risco_churn, sem_whatsapp) e exibir no dashboard como barra de alertas colapsavel.

**Implementacao:**
- Nova query no `loadDashboard()`: `sb.rpc('fn_god_alerts')`
- Componente `<div class="alerts-bar">` acima dos KPIs
- Agrupado por severidade (critico primeiro)
- Click no alerta → navega para detail do mentorado
- Badge no sidebar "Dashboard" com count de alertas criticos

**Dados disponveis:** `alerta_tipo`, `severidade`, `mentorado_id`, `mentorado_nome`, `descricao`, `valor_referencia`

**Valor:** Equipe ve problemas assim que abre o dashboard, sem precisar filtrar manualmente.

---

#### 1.2 Timeline Unificada no Detail
**Prioridade:** ALTA
**Esforco:** Baixo (view `vw_god_timeline` ja existe com 5 tipos de evento)

**O que:** Nova tab "Timeline" no detail do mentorado mostrando historico cronologico: calls, marcos, direcionamentos, planos, sessoes de grupo.

**Implementacao:**
- Query: `sb.from('vw_god_timeline').select('*').eq('mentorado_id', id).order('data', { ascending: false }).limit(50)`
- Componente visual: vertical timeline com icones por tipo de evento
- Filtro por tipo (calls, marcos, direcionamentos, todos)
- Expandir/colapsar detalhes

**Dados disponveis:** `evento_tipo`, `data`, `titulo`, `descricao`, `metadata_json`

**Valor:** Visao completa da jornada do mentorado em um unico lugar.

---

#### 1.3 Export de Relatorio (PDF/CSV)
**Prioridade:** ALTA
**Esforco:** Medio

**O que:** Botao "Exportar" no dashboard e no detail que gera:
- **Dashboard:** CSV com todos os mentorados e metricas
- **Detail:** PDF com resumo do mentorado (perfil, KPIs, ultimas calls, tarefas)

**Implementacao:**
- CSV: gerar no frontend via `Blob` + download
- PDF: usar biblioteca `jsPDF` ou `html2canvas` (sem build step)
- Incluir: nome, fase, risco, engagement, vendas, dias desde call, tarefas pendentes, msgs pendentes

**Valor:** Queila consegue compartilhar relatorios sem montar manual.

---

#### 1.4 KPI Comparativo (Semana vs Semana Anterior)
**Prioridade:** MEDIA
**Esforco:** Baixo

**O que:** Nos KPI cards, mostrar seta verde/vermelha indicando se o numero subiu ou desceu vs semana anterior.

**Implementacao:**
- Salvar snapshot semanal dos KPIs em `localStorage` (ou nova tabela `god_kpi_snapshots`)
- Comparar valores atuais com ultimo snapshot
- Seta verde ↑ se melhorou, vermelha ↓ se piorou

**Valor:** Equipe percebe tendencias sem precisar lembrar dos numeros.

---

### WAVE 2: Produtividade da Equipe (2-4 semanas)

#### 2.1 Templates de Tarefas por Fase
**Prioridade:** ALTA
**Esforco:** Medio

**O que:** Ao mover mentorado para nova fase, auto-gerar tarefas padrao da fase.

**Templates por fase:**
- **Onboarding:** Enviar kit boas-vindas, Agendar call onboarding, Criar grupo WA, Enviar contrato
- **Concepcao:** Definir nicho, Validar oferta, Criar funil, Definir posicionamento
- **Validacao:** Primeira venda, Review do funil, Ajustar oferta, Call estrategia
- **Otimizacao:** Escalar trafego, Otimizar conversao, Automatizar processo
- **Escala:** Definir equipe, Implementar processos, Escalar operacao

**Implementacao:**
- Nova tabela `god_task_templates` (fase, titulo, descricao, responsavel_padrao, prioridade)
- Funcao `generatePhaseTasksForMentee(menteeId, newPhase)`
- Trigger no kanban ao mover card entre colunas

**Valor:** Elimina retrabalho manual de criar mesmas tarefas para cada mentorado.

---

#### 2.2 Dashboard de Performance da Equipe
**Prioridade:** ALTA
**Esforco:** Medio

**O que:** Nova view "Equipe" no sidebar mostrando metricas por membro:
- Tarefas concluidas (semana/mes)
- Tempo medio de resposta WA
- Calls realizadas
- Mentorados atribuidos
- Carga de trabalho (tarefas pendentes)

**Implementacao:**
- Nova view SQL `vw_god_team_performance` agregando por `responsavel`
- Componente: grid de cards por membro + ranking
- Grafico de barras simples (SVG inline)

**Valor:** Queila identifica sobrecarga e redistribui trabalho.

---

#### 2.3 Respostas Rapidas no WhatsApp
**Prioridade:** MEDIA
**Esforco:** Baixo

**O que:** Dropdown de templates de mensagem na pagina WhatsApp:
- "Oi [nome]! Tudo bem? Vi que voce..."
- "Lembrete: sua call esta agendada para..."
- "Parabens pela primeira venda!"
- "[nome], notei que faz X dias sem atividade..."

**Implementacao:**
- Array de templates em `12-APP-data.js` com placeholders `{nome}`, `{fase}`, `{dias_sem_call}`
- Botao "Templates" ao lado do input de mensagem
- Dropdown que preenche o campo automaticamente
- Substituicao automatica de variaveis com dados do mentorado

**Valor:** Economia de 30-60 segundos por mensagem, padronizacao de comunicacao.

---

#### 2.4 Tarefas Recorrentes
**Prioridade:** MEDIA
**Esforco:** Medio

**O que:** Opcao de criar tarefa recorrente (diaria, semanal, mensal).

**Implementacao:**
- Novo campo `recorrencia` no `taskForm` (nenhuma/diaria/semanal/mensal)
- Campo `proxima_ocorrencia` na tabela
- Cron job (ou check no `loadTasks`) que auto-cria nova instancia quando vence
- Badge "Recorrente" no card da tarefa

**Valor:** Follow-ups regulares nao sao esquecidos.

---

#### 2.5 Notificacoes In-App (Centro de Notificacoes)
**Prioridade:** MEDIA
**Esforco:** Medio

**O que:** Icone de sino no topbar com dropdown de notificacoes:
- Tarefa atribuida a voce
- Mentorado mudou de status
- Comentario em sua tarefa
- Alerta critico novo
- Lembrete vencendo

**Implementacao:**
- Nova tabela `god_notifications` (user_id, tipo, titulo, lida, created_at, link)
- Triggers SQL para popular automaticamente
- Badge com count de nao-lidas no topbar
- Dropdown com scroll e "marcar todas como lidas"

**Valor:** Equipe nao precisa navegar para descobrir o que mudou.

---

### WAVE 3: Inteligencia e Automacao (4-8 semanas)

#### 3.1 Score de Saude do Mentorado (Health Score Composto)
**Prioridade:** ALTA
**Esforco:** Alto

**O que:** Algoritmo que combina multiplos sinais em um unico score 0-100:

**Formula ponderada:**
- Engagement WA (25%): msgs 7d, tempo resposta, consistencia
- Frequencia de Calls (20%): dias desde call, regularidade
- Progresso de Tarefas (20%): % concluidas, atrasadas
- Evolucao de Vendas (15%): crescimento vs meta
- Implementacao (10%): marcos atingidos vs esperados
- Financeiro (10%): contrato + pagamentos em dia

**Implementacao:**
- Nova view SQL `vw_god_health_score` com formula calculada
- Sparkline no mentee card mostrando evolucao do score (ultimas 4 semanas)
- Threshold: >=70 saudavel, 40-69 atencao, <40 critico
- Historico semanal para trend analysis

**Valor:** Um unico numero resume a situacao do mentorado. Mais objetivo que `risco_churn` atual.

---

#### 3.2 Predicao de Churn com IA
**Prioridade:** MEDIA
**Esforco:** Alto

**O que:** Modelo que prevee probabilidade de abandono baseado em padroes historicos.

**Sinais de input:**
- Queda de engagement WA (7d vs 30d)
- Aumento do tempo sem call
- Tarefas nao concluidas acumulando
- Sentimento negativo em analises
- Inadimplencia financeira
- Sem vendas apos X semanas

**Implementacao:**
- Edge function Supabase com logica de scoring
- Ou: calcular client-side com dados da `vw_god_overview`
- Badge "Risco Churn: 78%" no mentee card
- Alerta automatico quando score > 60%

**Valor:** Intervencao proativa antes do mentorado desistir.

---

#### 3.3 Automacao de Mudanca de Fase
**Prioridade:** MEDIA
**Esforco:** Medio

**O que:** Sugerir automaticamente mudanca de fase quando marcos sao atingidos.

**Regras:**
- M0 atingido → sugerir mover para Concepcao
- M1 atingido → sugerir mover para Validacao
- M2 atingido (primeira venda) → sugerir mover para Otimizacao
- M4 atingido (vendas consistentes) → sugerir mover para Escala

**Implementacao:**
- Verificar marcos na `marcos_mentorado` vs fase atual
- Notificacao: "Maria atingiu M2 (Primeira Venda). Sugerir mudanca para Otimizacao?"
- Botao "Confirmar Mudanca" → UPDATE mentorados SET fase_jornada
- Registrar em `historico_fases` (JSONB)

**Valor:** Ninguem esquece de atualizar fase. Jornada fica precisa.

---

#### 3.4 Resumo Semanal Automatico (Email/WA)
**Prioridade:** MEDIA
**Esforco:** Alto

**O que:** Enviar resumo semanal para cada membro da equipe com:
- Suas tarefas pendentes e atrasadas
- Mentorados em risco sob sua responsabilidade
- Calls agendadas da semana
- Metricas comparativas (semana vs anterior)

**Implementacao:**
- Edge function Supabase com cron (todo domingo 20h)
- Template HTML para email
- Opcional: enviar via Evolution API (WhatsApp) para equipe

**Valor:** Equipe comeca a semana ja sabendo prioridades.

---

#### 3.5 Integracao com Hotmart/Kiwify (Vendas Real-Time)
**Prioridade:** ALTA
**Esforco:** Alto

**O que:** Webhook que recebe notificacoes de venda e atualiza automaticamente:
- `metricas_mentorado` com nova venda
- `mentorados.faturamento_atual` atualizado
- Notificacao para equipe: "Mentorado X fez venda de R$ Y!"
- Auto-detectar M2 (primeira venda) → trigger marco

**Implementacao:**
- Endpoint webhook no backend Railway
- Parser para Hotmart/Kiwify payload
- INSERT em metricas_mentorado + UPDATE mentorados
- Notification trigger

**Valor:** Elimina entrada manual de vendas. Dados sempre atualizados.

---

### WAVE 4: Escala e Diferenciacao (8-12 semanas)

#### 4.1 Portal do Mentorado (Self-Service)
**Prioridade:** ALTA
**Esforco:** Muito Alto

**O que:** Area logada para o mentorado acessar:
- Sua jornada (fase atual, marcos, progresso)
- Tarefas pendentes atribuidas a ele
- Historico de calls com gravacoes
- Materiais e dossies
- Upload de evidencias (prints de vendas, metricas)

**Implementacao:**
- Nova pagina HTML com auth separado (Supabase Auth para mentorados)
- RLS: mentorado so ve seus proprios dados
- Read-only para maioria dos dados
- Upload de evidencias → S3 + registro em `marcos_mentorado`

**Valor:** Mentorado se sente mais engajado. Equipe recebe dados sem pedir.

---

#### 4.2 Dashboards Interativos com Graficos
**Prioridade:** MEDIA
**Esforco:** Alto

**O que:** Pagina "Analytics" com graficos interativos:
- Evolucao de mentorados por fase (area chart mensal)
- Faturamento agregado (bar chart mensal)
- Distribuicao de risco (pie chart)
- Calls realizadas vs agendadas (line chart)
- Engagement medio por cohort (radar chart)
- Funil de conversao (funnel chart)

**Implementacao:**
- Biblioteca: Chart.js (CDN, sem build step)
- Nova view SQL `vw_god_analytics_monthly` com agregacoes mensais
- Tabela `god_kpi_snapshots` para historico (snapshot diario/semanal)

**Valor:** Visao estrategica para Queila. Apresentavel para investidores/parceiros.

---

#### 4.3 Gamificacao e Rankings
**Prioridade:** BAIXA
**Esforco:** Medio

**O que:** Sistema de pontos e conquistas para mentorados:
- Pontos por: completar tarefa, fazer venda, participar de call, atingir marco
- Ranking entre mentorados do mesmo cohort
- Badges visuais: "Primeiro Venda", "Call Streak 4x", "Engagement 90%+"
- Streak tracking: dias consecutivos com atividade

**Implementacao:**
- Nova tabela `god_gamification` (mentorado_id, pontos, badges[], streak)
- Calcular pontos automaticamente via triggers
- Componente visual no portal do mentorado

**Valor:** Engajamento via competicao saudavel.

---

#### 4.4 Integracoes Adicionais
**Prioridade:** VARIAVEL
**Esforco:** Medio cada

| Integracao | O que faz | Valor |
|-----------|-----------|-------|
| **Typeform/Tally** | Formularios de feedback pos-call automatico | NPS do mentorado |
| **Notion** | Sync de documentos e wikis | Base de conhecimento |
| **Stripe** | Cobrancas automaticas | Elimina sheets financeiro |
| **Slack** | Alertas para equipe | Notificacoes real-time |
| **Meta Ads** | Metricas de trafego do mentorado | Performance de anuncios |
| **RD Station** | CRM e funil de novos leads | Pipeline de novos mentorados |

---

#### 4.5 Mobile PWA
**Prioridade:** ALTA
**Esforco:** Medio

**O que:** Transformar o dashboard em PWA (Progressive Web App):
- Manifest.json + Service Worker
- Icone na home do celular
- Push notifications nativas
- Offline mode para dados cached
- Layout responsivo otimizado

**Implementacao:**
- `manifest.json` com icones e theme_color
- Service Worker para cache de assets
- Push notification via Web Push API
- Media queries otimizadas para mobile

**Valor:** Equipe acessa o dashboard como app nativo no celular.

---

## 4. Novas Views SQL Necessarias

| View | Fonte | Proposito |
|------|-------|-----------|
| `vw_god_health_score` | overview + calls + tarefas + vendas | Score composto 0-100 por mentorado |
| `vw_god_team_performance` | tasks + calls + interacoes | Metricas por membro da equipe |
| `vw_god_analytics_monthly` | overview + vendas + calls | Agregacoes mensais para graficos |
| `vw_god_fase_transitions` | mentorados.historico_fases | Historico de mudancas de fase |
| `vw_god_notification_feed` | god_notifications | Feed de notificacoes por usuario |

---

## 5. Novas Tabelas Necessarias

| Tabela | Campos Chave | Wave |
|--------|-------------|------|
| `god_task_templates` | fase, titulo, descricao, responsavel_padrao | W2 |
| `god_notifications` | user_id, tipo, titulo, link, lida, created_at | W2 |
| `god_kpi_snapshots` | data, kpi_json, tipo (diario/semanal) | W1/W4 |
| `god_gamification` | mentorado_id, pontos, badges[], streak | W4 |
| `god_wa_templates` | titulo, conteudo, placeholders[], categoria | W2 |

---

## 6. Prioridade de Implementacao (Roadmap)

### Semana 1-2 (Wave 1 - Quick Wins)
1. **1.1 Alertas Visuais** ← Maior impacto, menor esforco
2. **1.2 Timeline Detail** ← View ja existe
3. **1.4 KPI Comparativo** ← Feedback visual rapido

### Semana 3-4 (Wave 1 + Wave 2 inicio)
4. **1.3 Export PDF/CSV** ← Pedido recorrente da Queila
5. **2.3 Respostas Rapidas WA** ← Produtividade imediata
6. **2.1 Templates de Tarefas** ← Elimina retrabalho

### Semana 5-8 (Wave 2)
7. **2.2 Dashboard Equipe** ← Gestao de carga
8. **2.5 Notificacoes In-App** ← Proatividade
9. **2.4 Tarefas Recorrentes** ← Automacao

### Semana 9-12 (Wave 3)
10. **3.1 Health Score** ← Visao unificada
11. **3.3 Automacao de Fase** ← Precisao da jornada
12. **3.5 Hotmart/Kiwify** ← Dados real-time

### Semana 13+ (Wave 4)
13. **4.5 PWA Mobile** ← Acessibilidade
14. **4.2 Graficos Analytics** ← Visao estrategica
15. **4.1 Portal Mentorado** ← Escala do programa

---

## 7. Metricas de Sucesso

| Metrica | Baseline Atual | Meta Wave 1 | Meta Wave 4 |
|---------|---------------|-------------|-------------|
| Tempo medio resposta WA | Nao medido | < 4h | < 2h |
| Tarefas atrasadas | ~150 | < 80 | < 30 |
| Mentorados em risco critico | Variavel | -30% | -60% |
| Calls sem realizacao 30d+ | ~8 | < 3 | 0 |
| Tempo para detectar problema | Dias | Horas | Minutos |
| Satisfacao equipe (NPS interno) | Nao medido | 7+ | 9+ |
| Churn mentorados | ~15% | < 10% | < 5% |

---

## 8. Riscos e Mitigacoes

| Risco | Probabilidade | Impacto | Mitigacao |
|-------|--------------|---------|-----------|
| Sobrecarga de features | Alta | Alto | Manter waves sequenciais, nao pular |
| API Evolution instavel | Media | Alto | Fallback para dados cached |
| Performance com graficos pesados | Media | Medio | Lazy load Chart.js, limitar dados |
| Resistencia da equipe a mudancas | Baixa | Medio | Onboarding gradual, feedback loops |
| Custo Supabase/Railway escalar | Baixa | Medio | Monitorar uso, otimizar queries |

---

## 9. Decisoes Arquiteturais

### Manter
- **Vanilla HTML + Alpine.js** — Sem build step = deploy instantaneo
- **Supabase** — RLS, auth, realtime ja configurados
- **Railway backend** — Proxy APIs estavel

### Evoluir
- **CSS** → Considerar Tailwind (CDN) para novas features (coexistir com design system atual)
- **Graficos** → Chart.js via CDN (nao precisa de build)
- **PWA** → Service Worker + Manifest (sem framework)
- **Notificacoes** → Web Push API (nativo do browser)

### Nao Mudar
- Stack frontend (nao migrar para React/Vue/Svelte — complexidade desnecessaria para o tamanho da equipe)
- Supabase como banco (nao migrar para Firebase/Planetscale)
- Python backend (funciona, equipe conhece)

---

*— Aria, arquitetando o futuro do Spalla*
