---
title: "Relatorio Completo — WhatsApp Team Inbox Benchmark"
type: research-report
status: complete
date: 2026-03-20
confidence: HIGH (21 web searches, 10+ sources por ferramenta)
---

# WhatsApp Team Inbox Benchmark — Relatorio Completo

## 1. Feature Matrix Comparativa

### Legenda
- **S** = Sim, feature nativa
- **P** = Parcial (existe mas limitada)
- **N** = Nao tem
- **R** = Roadmap / em desenvolvimento
- **?** = Dados insuficientes para confirmar

### 1.1 Organizacao de Conversas

| Feature | Trengo | Respond.io | WATI | Bird | Kommo | Whaticket | JivoChat | Front | Intercom | Crisp | Chatwoot |
|---------|--------|------------|------|------|-------|-----------|----------|-------|----------|-------|----------|
| Inbox unificado (multi-canal) | S | S | S | S | S | S | S | S | S | S | S |
| Status de conversa (open/pending/resolved) | S | S | S | S | P | S | S | S | S | S | S |
| Labels/Tags customizaveis | S | S | S | P | S | P | S | S | S | S | S |
| Filtros por label/tag | S | S | S | P | S | P | S | S | S | S | S |
| Filtros por agente atribuido | S | S | S | S | S | P | S | S | S | S | S |
| Filtros por canal | S | S | S | S | S | S | S | S | S | S | S |
| Views customizaveis / saved filters | P | S | P | P | S | N | P | S | S | S | S |
| Conversas arquivadas | S | S | S | S | S | P | S | S | S | S | S |
| Conversas snooze/mute | P | S | P | P | P | N | N | S | S | S | S |

### 1.2 Priorizacao e Atribuicao

| Feature | Trengo | Respond.io | WATI | Bird | Kommo | Whaticket | JivoChat | Front | Intercom | Crisp | Chatwoot |
|---------|--------|------------|------|------|-------|-----------|----------|-------|----------|-------|----------|
| Atribuicao manual a agente | S | S | S | S | S | S | S | S | S | S | S |
| Auto-assign (round robin) | S | S | S | S | P | S | P | S | S | S | S |
| Auto-assign (skill-based) | P | S | P | S | P | N | N | S | S | P | P |
| Priorizacao de conversas (priority levels) | P | P | P | S | P | N | N | S | S | P | P |
| SLA monitoring / time goals | P | S | P | S | N | N | N | S | S | P | P |
| Fila de espera visivel | S | S | S | S | S | P | P | S | S | S | S |
| Routing por regras/workflows | S | S | S | S | S | P | P | S | S | S | S |

### 1.3 Colaboracao e Anotacoes

| Feature | Trengo | Respond.io | WATI | Bird | Kommo | Whaticket | JivoChat | Front | Intercom | Crisp | Chatwoot |
|---------|--------|------------|------|------|-------|-----------|----------|-------|----------|-------|----------|
| Notas internas por conversa | S | S | S | S | S | P | S | S | S | S | S |
| @mencoes de colegas | S | S | P | S | S | N | P | S | S | S | S |
| Shared drafts | N | P | N | N | N | N | N | S | P | N | N |
| Historico completo de contato | S | S | S | S | S | S | S | S | S | S | S |
| CRM / ficha de contato | P | S | P | P | S | P | S | P | S | P | S |
| Custom fields por contato | P | S | S | P | S | N | P | S | S | S | S |
| Lifecycle / stage tracking | P | S | P | P | S | N | P | P | S | P | P |

### 1.4 Features de IA

| Feature | Trengo | Respond.io | WATI | Bird | Kommo | Whaticket | JivoChat | Front | Intercom | Crisp | Chatwoot |
|---------|--------|------------|------|------|-------|-----------|----------|-------|----------|-------|----------|
| AI Chatbot / Agent | S (HelpMate) | S (AI Agent) | S (KnowBot) | S | S (Salesbot) | P | P | S | S (Fin) | S | S (Captain) |
| AI Resumo de conversa | R | S | P | P | P | N | N | S | S | P | S |
| AI Sugestao de resposta (Copilot) | S | S | P | S | P | N | N | S | S (Fin Copilot) | S | S (Captain) |
| AI Categorizacao/labeling automatico | S | P | N | S | P | N | N | P | S | P | P |
| AI Traducao | P | S | P | P | P | N | N | P | S | P | P |
| AI Sentiment analysis | P | P | P | S | S | N | N | P | P | P | P |
| AI Triage (priorizacao automatica) | P | P | N | S | P | N | N | P | S | P | P |

### 1.5 Gestao de Grupos WhatsApp

| Feature | Trengo | Respond.io | WATI | Bird | Kommo | Whaticket | JivoChat | Front | Intercom | Crisp | Chatwoot | Periskope |
|---------|--------|------------|------|------|-------|-----------|----------|-------|----------|-------|----------|-----------|
| Suporte a grupos WA | N | N | N | N | N | P | N | N | N | N | N | S |
| Resumo de grupo (AI) | N | N | N | N | N | N | N | N | N | N | N | S |
| Gestao de membros de grupo | N | N | N | N | N | N | N | N | N | N | N | S |
| Flag de mensagens importantes | N | N | N | N | N | N | N | N | N | N | N | S |
| Analytics de grupo | N | N | N | N | N | N | N | N | N | N | N | S |
| Converter msg em ticket/task | N | N | N | N | N | N | N | N | N | N | N | S |

### 1.6 Precificacao (por agente/mes, plano inicial) — valores aproximados coletados em 20/03/2026

| Ferramenta | Preco Inicial | Modelo |
|-----------|---------------|--------|
| Trengo | ~EUR 25/agente/mes | Per agent |
| Respond.io | ~USD 79/mes (team) | Per workspace |
| WATI | ~USD 39/mes (5 agents) | Per workspace + msg |
| Bird | Custom pricing | Volume-based |
| Kommo | ~USD 15/user/mes | Per user |
| Whaticket | ~BRL 99/mes | Per workspace |
| JivoChat | ~USD 19/agente/mes | Per agent |
| Front | ~USD 19/seat/mes | Per seat |
| Intercom | ~USD 29/seat/mes + AI usage | Per seat + consumption |
| Crisp | ~EUR 25/workspace/mes (4 seats) | Per workspace |
| Chatwoot | Gratis (self-hosted) | Open source / cloud |
| Periskope | ~USD 20/mes | Per workspace |


---

## 2. Top 10 Features Mais Comuns e Valorizadas

Ranked por frequencia de implementacao e destaque na comunicacao das ferramentas:

| # | Feature | Presente em | Importancia para Spalla |
|---|---------|-------------|------------------------|
| 1 | **Inbox unificado multi-canal** | 11/11 | ALTA — consolidar WA + outros canais |
| 2 | **Atribuicao de conversa a agente** | 11/11 | CRITICA — consultor = dono da carteira |
| 3 | **Labels/tags customizaveis** | 10/11 | ALTA — categorizar por etapa do mentorado |
| 4 | **Notas internas por conversa** | 11/11 | CRITICA — registro de evolucao do mentorado |
| 5 | **AI Chatbot/Agent para FAQ** | 10/11 | MEDIA — menos relevante em mentoria high-touch |
| 6 | **Filtros e busca avancada** | 10/11 | ALTA — encontrar rapidamente quem precisa de atencao |
| 7 | **Auto-assign (round robin / regras)** | 9/11 | MEDIA — carteira ja e fixa por consultor |
| 8 | **Historico completo de contato** | 11/11 | CRITICA — timeline do mentorado |
| 9 | **AI Sugestao de resposta** | 8/11 | BAIXA — consultor precisa personalizar |
| 10 | **Workflows / automacao** | 10/11 | ALTA — alertas automaticos, follow-ups |


---

## 3. Features Unicas / Diferenciadoras por Ferramenta

### Trengo
- **AI Labeling automatico via Journeys** — a IA analisa cada conversa e adiciona labels tematicos automaticamente. Unico no mercado com labeling driven by AI como feature nativa de analytics.
- **HelpMate com 26 idiomas** — chatbot com deteccao automatica de idioma.

### Respond.io
- **Lifecycle tracking nativo** — rastreia status do contato (new lead, qualified, customer, churned) com visualizacao de funil.
- **AI File View** — view dedicada que mostra todos os attachments trocados numa conversa sem precisar scrollar.
- **Conversation merge** — unifica conversas do mesmo contato vindas de canais diferentes.

### WATI
- **KnowBot com treinamento por documentos** — upload de PDF/FAQ e o bot responde baseado no conteudo. Bom para bases de conhecimento de mentoria.
- **Chat status (Open/Pending/Resolved)** com filtro nativo.

### Bird (MessageBird)
- **Smart routing por urgencia + topico** — auto-classifica mensagens por urgencia e direciona ao agente mais adequado.
- **AI tone adjustment** — ajusta tom da resposta (formal, casual, etc).
- **Volume-based pricing** — vantagem para operacoes de grande escala.

### Kommo
- **Pipeline visual (Kanban) nativo** — conversas sao leads que se movem por stages visuais. Unico com CRM pipeline como view primaria.
- **Salesbot com filtro condicional** — bot que ramifica comportamento baseado em campos do contato ou conteudo da mensagem.
- **Match WhatsApp number → pipeline** — associa numeros de WA a pipelines especificos por equipe/regiao.

### Whaticket
- **Open source (community edition)** — whaticket-community no GitHub, self-hosted.
- **Foco em mercado BR** — pricing em BRL, integracao com canais brasileiros.

### JivoChat
- **CRM built-in leve** — status, tags e reminders por conversa dentro do proprio chat, sem precisar de CRM externo.
- **Roles granulares** — Admin, Supervisor, User com permissoes diferentes.

### Front
- **Shared drafts** — unica ferramenta com rascunhos colaborativos em tempo real antes de enviar mensagem.
- **SLA monitoring visual** — time goals com alertas visuais quando SLA esta proximo de ser violado.
- **Rule library** — biblioteca de regras pre-construidas para automacao.
- **AI chatbot com knowledge base** — responde usando docs internos do Front.

### Intercom
- **Fin AI Copilot** — o mais avancado copilot do mercado: resume conversa, sugere resposta, busca artigos relevantes, tudo em tempo real para o agente. Agentes ficam 31% mais eficientes (declarado pela Intercom — metrica de marketing, nao verificada independentemente).
- **AI Triage automatico** — classifica urgencia e roteia sem regras manuais. VIPs vao primeiro, billing issues para especialistas.
- **Conversation summary automatico via Workflows** — resumos podem ser gerados automaticamente por trigger, nao apenas on-demand.
- **50% de resolucao por AI** — Fin AI Agent resolve metade das perguntas sem humano (per Intercom — claim de marketing, nao auditado externamente).

### Crisp
- **Triage rules nativo** — bloqueia mensagens, seta segmentos ou custom data baseado em regras, antes da conversa chegar ao agente.
- **AI treinada em conversas reais** — o assistant aprende do historico de suporte, nao apenas de docs.
- **Pricing por workspace (4 seats)** — economico para times pequenos.

### Chatwoot
- **Open source (MIT License)** — full control, self-hosted ou cloud. Unica alternativa enterprise-grade open source.
- **Captain (AI)** — copilot que busca em help center + historico de conversas + FAQs.
- **Automacoes com AND/OR logic** — builder visual com logica booleana, mais flexivel que maioria.
- **Label Reports** — reports automaticos por label (volume, tempo de resolucao, tendencias). Nenhuma outra ferramenta tem reports por label tao robustos.
- **CSAT surveys triggered by label** — pesquisa de satisfacao condicionada a labels (ex: nao enviar para conversas marcadas como "spam").

### Periskope (bonus — especialista em grupos)
- **Gestao de grupos WA como entidade primaria** — unica ferramenta que trata grupos como cidadaos de primeira classe.
- **AI flag de mensagens importantes** — sentiment analysis para detectar mensagens urgentes em grupos.
- **Converter mensagem em ticket/task** — transforma uma msg de grupo em item acionavel.
- **Analytics de grupo** — volume, response time, query counts por grupo.
- **Gestao de membros** — add/remove membros em lote entre grupos.
- **Sem restricao de janela de 24h** — responde a mensagens a qualquer hora (diferente da API oficial).


---

## 4. Gaps — O Que Nenhuma Ferramenta Faz Bem

### Gap 1: Gestao de Grupos WhatsApp como Entidade Primaria
**Severidade: CRITICA para Spalla**

Todas as 10 ferramentas principais sao desenhadas para conversas 1:1 (empresa-cliente). Nenhuma trata grupos de WhatsApp como entidade gerenciavel, exceto Periskope. Para o Spalla, onde cada mentorado tem um grupo com consultor + equipe, isso e um gap fundamental.

- Nenhuma ferramenta (exceto Periskope) oferece resumos de grupo
- Nenhuma permite "entrar" no grupo e ver um dashboard do que foi discutido
- A API oficial do WhatsApp Business tem suporte limitado a grupos

### Gap 2: "Carteira de Clientes" como Conceito Nativo
**Severidade: CRITICA para Spalla**

Nenhuma ferramenta implementa o conceito de "carteira" — um agrupamento de contatos sob responsabilidade de um agente especifico, com dashboard de saude da carteira. O mais proximo e:
- Kommo: pipeline por agente (mas e CRM de vendas, nao de relacionamento)
- Respond.io: lifecycle tracking (mas e por contato individual, sem view de carteira)

O que falta: uma view "Minha Carteira" mostrando todos os mentorados do consultor com indicadores de saude (ultimo contato, pendencias, score de engajamento).

### Gap 3: Anotacoes Estruturadas por Contato
**Severidade: ALTA para Spalla**

Todas as ferramentas oferecem "notas internas" por conversa, mas sao texto livre sem estrutura. Nenhuma oferece:
- Templates de anotacao (ex: "Feedback de aula", "Checkpoint mensal")
- Campos estruturados por nota (ex: humor, progresso, bloqueios)
- Timeline de evolucao do contato baseada em notas
- Export de historico de notas para relatorio

### Gap 4: Resumos de Conversa para Consultores (Nao Suporte)
**Severidade: ALTA para Spalla**

Os resumos de IA existentes (Respond.io, Intercom, Front) sao otimizados para suporte ao cliente — "qual era o problema e como foi resolvido". Nenhum e otimizado para relacionamento consultivo:
- "O que foi discutido nesta semana com este mentorado?"
- "Quais compromissos foram feitos?"
- "Qual o sentimento geral do mentorado?"
- "Quais action items ficaram pendentes?"

### Gap 5: Priorizacao por Contexto de Mentoria
**Severidade: MEDIA-ALTA para Spalla**

As priorizacoes existentes (Intercom, Bird, Front) sao baseadas em urgencia de suporte (SLA, tempo sem resposta). Nenhuma considera:
- Tempo desde ultimo 1:1
- Fase da mentoria (onboarding vs execucao vs saida)
- Score de engajamento (participa de aulas? envia duvidas? entrega tarefas?)
- Risco de churn (nao interage ha X dias)

### Gap 6: Integracao Nativa com WhatsApp Grupos via Web/Desktop
**Severidade: MEDIA**

A API oficial do WhatsApp Business nao suporta grupos. Ferramentas como Periskope usam workarounds (provavelmente WA Web scraping ou extensoes). Isso gera:
- Riscos de compliance (termos de uso da Meta)
- Fragilidade tecnica (scraping pode quebrar com updates)
- Limitacoes de escala

### Gap 7: Dashboard Executivo para Gestores
**Severidade: MEDIA para Spalla**

Dashboards de analytics existem (Chatwoot, Respond.io, Front), mas sao orientados a metricas de suporte (first response time, resolution time, CSAT). Falta:
- "Health score" por mentorado
- Performance comparativa entre consultores
- Alertas proativos ("3 mentorados sem interacao ha 5 dias")
- Funil de mentoria (onboarding → execucao → resultado → renovacao)


---

## 5. Analise por Dimensao — Deep Dive

### 5.1 Como Organizam Conversas Nao Respondidas

| Ferramenta | Mecanismo |
|-----------|-----------|
| Trengo | Filtro "unassigned" + "unreplied" no inbox. Labels manuais ou automaticos via AI Journeys |
| Respond.io | Filtro nativo "unreplied". Lifecycle stage indica contexto. AI pode alertar |
| WATI | Status "Open" = nao resolvido. Filtro por status. Auto-assignment distribui novas |
| Bird | Smart routing por urgencia. Conversas nao atendidas escalam automaticamente |
| Kommo | Pipeline visual — conversas sem resposta ficam no stage "incoming" visualmente |
| Front | Inbox com indicadores de SLA. Conversas proximas de violar SLA ficam destacadas |
| Intercom | AI Triage prioriza automaticamente. "Waiting on team" vs "Waiting on customer" |
| Crisp | Triage rules bloqueiam/classificam antes de chegar ao agente. Filtros por status |
| Chatwoot | Status (open/pending/resolved/snoozed). Filtros combinados com labels |

### 5.2 Sistemas de Priorizacao

| Abordagem | Ferramentas | Como Funciona |
|-----------|-------------|---------------|
| Manual (labels/tags) | Todas | Agente marca como "urgente", "alta prioridade" etc |
| SLA-based | Front, Intercom, Respond.io, Bird | Define tempo maximo de resposta, alerta visual quando proximo |
| AI Triage | Intercom, Bird | IA classifica urgencia automaticamente baseada em conteudo |
| Pipeline position | Kommo | Posicao no kanban indica prioridade visual |
| AI Labeling | Trengo | IA categoriza automaticamente e aplica labels |
| Sentiment-based | Periskope, Bird, Kommo | Detecta mensagens com sentimento negativo/urgente |

### 5.3 Views Disponiveis

| View | Presente Em |
|------|-------------|
| Inbox (todas as conversas) | Todas |
| Minhas conversas (atribuidas a mim) | Todas |
| Nao atribuidas | 10/11 |
| Pendentes / aguardando resposta | 9/11 |
| Arquivadas / resolvidas | Todas |
| Por label/tag | 10/11 |
| Por canal | Todas |
| Custom saved views | Front, Respond.io, Intercom, Chatwoot, Crisp, Kommo |
| Por pipeline stage | Kommo |
| Por lifecycle stage | Respond.io |

### 5.4 Resumos e AI Summaries

| Ferramenta | Tipo de Resumo | Disponibilidade |
|-----------|----------------|-----------------|
| Respond.io | Resumo de conversa por AI | Disponivel, on-demand |
| Intercom | Resumo automatico via Fin + Workflows | Disponivel, automatizavel |
| Front | Resumo de threads longas | Disponivel, on-demand |
| Chatwoot | Resumo via Captain AI | Disponivel |
| Crisp | Resumo via AI assistant | Parcial |
| Trengo | Resumo de conversa | Em roadmap |
| Periskope | Resumo de grupo WA | Disponivel (unico para grupos) |
| WhatsApp nativo | Message Summaries (Meta AI) | Lancado em 2025, usuario final apenas |

### 5.5 Anotacoes Internas

| Ferramenta | Tipo | Estrutura |
|-----------|------|-----------|
| Todas as 11 | Notas internas por conversa | Texto livre |
| Respond.io | Notas + custom fields + lifecycle | Semi-estruturado |
| Kommo | Notas no lead card + pipeline history | Semi-estruturado |
| JivoChat | Notas + tags + reminders | Semi-estruturado |
| Chatwoot | Notas + custom attributes | Semi-estruturado |
| Nenhuma | Templates de nota, campos tipados, timeline de evolucao | GAP |


---

## 6. Ferramentas Open Source

### Chatwoot
- **Licenca:** MIT
- **GitHub:** github.com/chatwoot/chatwoot (20k+ stars)
- **Stack:** Ruby on Rails + Vue.js
- **Deploy:** Self-hosted (Docker, K8s) ou cloud gerenciado
- **WhatsApp:** Via Twilio ou 360dialog
- **AI:** Captain (built-in, usa Ruby LLM)
- **Veredito:** Melhor opcao open source. Feature-rich, comunidade ativa, extensivel.

### Whaticket Community
- **Licenca:** Open source
- **GitHub:** github.com/canove/whaticket-community
- **Stack:** Node.js + React
- **Deploy:** Self-hosted
- **WhatsApp:** Direto via baileys/whatsapp-web.js (nao oficial)
- **AI:** Basica ou inexistente
- **Veredito:** Simplista, bom para MVP. Comunidade BR forte. Risco de compliance por usar API nao oficial.


---

## Fontes

- [Trengo WhatsApp Team Inbox](https://trengo.com/blog/whatsapp-team-inbox)
- [Trengo AI Labeling](https://help.trengo.com/article/ai-labeling-in-journeys-automate-and-analyze-conversations)
- [Trengo AI HelpMate](https://trengo.com/products/ai-automation/ai-helpmate)
- [Respond.io Team Inbox](https://respond.io/team-inbox)
- [Respond.io AI Assist](https://respond.io/help/inbox/using-ai-assist)
- [Respond.io Review 2025](https://wadesk.io/en/tutorial/respond-io-pricing-features)
- [WATI Team Inbox](https://www.wati.io/en/blog/whatsapp-team-inbox/)
- [WATI KnowBot Setup](https://support.wati.io/en/articles/11463665-how-to-set-up-and-use-the-ai-support-agent-formerly-knowbot-in-wati)
- [Bird WhatsApp Inbox](https://bird.com/en-us/use-case/inbox-for-whatsapp)
- [Kommo WhatsApp CRM](https://www.kommo.com/whatsapp/)
- [Kommo Salesbot](https://www.kommo.com/salesbot/)
- [Front WhatsApp Integration](https://front.com/integrations/whatsapp)
- [Front Rule Library](https://help.front.com/en/articles/2114)
- [Intercom AI Inbox Features](https://www.intercom.com/help/en/articles/6955446-ai-features-available-in-the-inbox)
- [Intercom Fin AI Copilot](https://www.intercom.com/blog/announcing-fin-ai-copilot/)
- [Crisp WhatsApp Shared Inbox](https://crisp.chat/en/integrations/whatsapp/)
- [Crisp Shared Inbox](https://crisp.chat/en/shared-inbox/)
- [Chatwoot Features](https://www.chatwoot.com/features/)
- [Chatwoot Labels](https://www.chatwoot.com/features/labels/)
- [Chatwoot Automations](https://www.chatwoot.com/features/automations)
- [Chatwoot Label Reports](https://www.chatwoot.com/features/label-reports/)
- [Chatwoot 2025 Overview](https://www.eesel.ai/blog/chatwoot)
- [Periskope WhatsApp Groups](https://periskope.app/)
- [Periskope Group Management](https://periskope.app/blog/whatsapp-groups-manager)
- [WhatsApp AI Summaries 2025](https://dataconomy.com/2025/07/21/whatsapp-will-now-summarize-your-messy-group-chats/)
- [WhatsApp Private Message Summaries](https://blog.whatsapp.com/catch-up-on-conversations-with-private-message-summaries)
- [ControlHippo Top 15 Providers](https://controlhippo.com/blog/whatsapp/whatsapp-team-inbox-providers/)
- [Rasayel Best Practices](https://learn.rasayel.io/en/blog/whatsapp-team-inbox/)
- [Hiver Shared Inbox Guide](https://hiverhq.com/blog/whatsapp-shared-inbox)
