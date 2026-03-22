---
title: "Recomendacoes de Features para o Spalla"
type: research-recommendations
status: complete
date: 2026-03-20
---

# Recomendacoes de Features para o Spalla

## Contexto

O Spalla Dashboard atende consultores de mentoria (CASE Mentoring) que gerenciam carteiras de mentorados via WhatsApp. O cenario e fundamentalmente diferente de "suporte ao cliente" — e gestao de relacionamento consultivo de longo prazo.

Nenhuma ferramenta do mercado atende esse caso de uso nativamente. As ferramentas existentes sao otimizadas para:
- **Suporte ao cliente** (ticket-based, resolucao rapida) — Intercom, Crisp, Chatwoot, Front
- **Vendas** (pipeline, lead conversion) — Kommo, Respond.io
- **Broadcasting** (envio em massa) — WATI, Bird

O Spalla precisa de algo que nenhuma faz: **gestao de relacionamento consultivo com WhatsApp como canal primario**.


---

## Tier 1 — Features Criticas (devem existir no MVP)

### F1: Carteira do Consultor (Portfolio View)
**Gap atendido:** Gap 2

View primaria do consultor mostrando todos os seus mentorados com:
- Nome, foto, fase da mentoria (onboarding / execucao / resultado / renovacao)
- Ultimo contato (data + preview da ultima mensagem)
- Status de saude: verde (engajado), amarelo (atencao), vermelho (risco)
- Quantidade de mensagens nao lidas no grupo
- Proximo compromisso / proxima acao pendente
- Quick actions: abrir conversa, adicionar nota, agendar follow-up

**Referencia de mercado:** Nenhuma direta. Inspiracao parcial em Kommo (pipeline visual) + Respond.io (lifecycle tracking).

**Diferenciador vs mercado:** Nenhuma ferramenta oferece essa view. E a feature que define o Spalla.


### F2: Resumo de Grupo WhatsApp (AI Group Digest)
**Gap atendido:** Gap 1, Gap 4

Resumo diario/semanal automatico do que aconteceu no grupo do mentorado:
- Topicos discutidos
- Decisoes tomadas
- Action items identificados (quem prometeu fazer o que)
- Sentimento geral do mentorado
- Mensagens que precisam de atencao do consultor

**Referencia de mercado:** Periskope (resumo de grupo) + WhatsApp nativo (Message Summaries). Mas nenhum com foco consultivo.

**Nota tecnica:** A API oficial do WhatsApp Business NAO suporta grupos. Implementacoes possiveis:
1. **Evolution API / Baileys** — acesso nao-oficial via WA Web protocol (risco de compliance)
2. **n8n webhook + WA Web** — automacao via n8n que ja existe no stack CASE
3. **Chrome Extension + WA Web** — menos invasivo, usuario autoriza explicitamente
4. **WhatsApp Cloud API futura** — Meta pode abrir suporte a grupos (monitorar roadmap)

[AUTO-DECISION] Abordagem tecnica para grupos: considerar **Evolution API** e **n8n webhook** como opcoes candidatas. **Requer sign-off de compliance e seguranca (revisao legal/tecnica) antes de selecionar Evolution API** dado risco de compliance com uso nao-oficial do WA Web protocol. Apos aprovacao, usar Evolution API como primaria com n8n webhook como fallback. Plano de rollback: desativar Evolution API e escalar para n8n webhook direto em caso de ban. **Caminho de longo prazo preferido: WhatsApp Cloud API futura** (monitorar roadmap Meta para suporte a grupos).


### F3: Notas Estruturadas por Mentorado
**Gap atendido:** Gap 3

Sistema de anotacoes tipadas com templates:
- **Checkpoint Mensal:** campos para progresso (1-5), bloqueios, proximos passos, humor do mentorado
- **Feedback de Aula:** participou? entregou tarefa? observacoes
- **Registro de Ligacao:** duracao, topicos, decisoes, follow-ups
- **Nota Livre:** texto aberto com tags

Cada nota gera entrada na timeline do mentorado. Timeline exportavel para relatorio.

**Referencia de mercado:** Nenhuma ferramenta oferece notas estruturadas. JivoChat e Respond.io tem notas + tags, mas texto livre apenas.


### F4: Inbox Inteligente com Priorizacao por Contexto
**Gap atendido:** Gap 5

Nao e um inbox de suporte. E um inbox de consultor que prioriza por:
1. **Risco de churn:** mentorado sem interacao ha X dias sobe ao topo
2. **Fase critica:** mentorados em onboarding ou proximos de renovacao tem prioridade
3. **Pendencias:** se o consultor prometeu algo e nao cumpriu, a conversa sobe
4. **Mensagens nao lidas:** volume de msgs nao lidas no grupo
5. **Sentimento:** AI detecta frustacao ou insatisfacao

**Referencia de mercado:** Intercom (AI Triage) + Bird (smart routing por urgencia). Mas ambos sao para suporte, nao mentoria.


---

## Tier 2 — Features de Alto Valor (pos-MVP)

### F5: Dashboard Executivo (Gestao View)
**Gap atendido:** Gap 7

Para o gestor (lider de consultores) ver:
- Health score agregado por consultor (media dos mentorados)
- Consultores com mais mentorados em risco
- Tempo medio de resposta por consultor
- Mentorados sem interacao ha mais de 5 dias (alerta)
- Funil de mentoria: quantos em cada fase, taxa de renovacao

**Referencia:** Chatwoot (Label Reports) + Respond.io (Lifecycle analytics). Nenhum com foco em mentoria.


### F6: Alertas Proativos (Smart Notifications)

Notificacoes push/email quando:
- Mentorado nao interage ha X dias (configuravel)
- Mentorado enviou mensagem com sentimento negativo
- Follow-up agendado esta proximo
- Mentorado completou marco importante
- Grupo WA teve alta atividade e consultor nao leu

**Referencia:** Front (SLA alerts) + Intercom (priority routing). Adaptado para contexto consultivo.


### F7: AI Copilot para Consultor

Assistente que ajuda o consultor:
- Resume conversa recente ("O que o Joao falou essa semana?")
- Sugere proximos passos baseado no historico
- Detecta padroes ("3 mentorados reclamaram da mesma aula")
- Prepara briefing pre-call ("pontos a abordar com Maria")

**Referencia:** Intercom Fin Copilot (31% mais eficiente) + Chatwoot Captain. Mas adaptado de suporte para consultoria.


### F8: Automacao de Follow-ups

Fluxos automaticos:
- "Se mentorado nao respondeu em 3 dias, lembrar consultor"
- "Apos checkpoint mensal, criar nota estruturada automatica"
- "Se mentorado completou 30 dias, trigger de feedback"

**Referencia:** Chatwoot automations (AND/OR logic) + Trengo AI Journeys.


---

## Tier 3 — Features Avancadas (longo prazo)

### F9: Kanban de Mentoria

View kanban com colunas por fase:
- Onboarding → Diagnostico → Execucao → Resultado → Renovacao/Saida
- Cards com foto, nome, health score, ultimo contato
- Drag and drop para mover entre fases

**Referencia:** Kommo (pipeline visual). Adaptado de vendas para mentoria.


### F10: Relatorios de Mentorado (Export)

Gerar relatorio PDF/MD consolidando:
- Timeline de notas estruturadas
- Metricas de engajamento
- Historico de marcos
- Resumos de grupo (AI digests)
- Score de evolucao

**Referencia:** Chatwoot Label Reports + Respond.io Lifecycle Reports. Nenhum gera relatorio por "mentorado".


---

## Matriz de Inspiracao: O Que Pegar de Cada Ferramenta

| Ferramenta | O Que Copiar | Adaptacao para Spalla |
|-----------|-------------|----------------------|
| **Intercom** | Fin Copilot, AI Triage, Conversation Summary | Copilot consultivo, priorizacao por risco de churn |
| **Kommo** | Pipeline visual (Kanban), lead card | Kanban de mentoria com health score |
| **Respond.io** | Lifecycle tracking, AI summary, File View | Fases da mentoria, resumos consultivos |
| **Chatwoot** | Labels + automation + reports, open source patterns | Labels por fase/tema, reports por mentorado, automacoes AND/OR |
| **Front** | SLA monitoring, shared drafts, rule library | Alertas de follow-up, regras pre-configuradas |
| **Periskope** | Grupo como entidade, flag AI, msg→task | Grupo do mentorado como hub, flags inteligentes |
| **Trengo** | AI Labeling automatico | Auto-categorizacao de notas/mensagens |
| **Crisp** | Triage rules, AI treinada em historico | Filtro pre-inbox, AI que conhece o mentorado |


---

## Posicionamento de Mercado

O Spalla nao compete com Intercom, Front ou Respond.io. Eles resolvem "suporte ao cliente em escala". O Spalla resolve **"gestao de relacionamento consultivo em mentorias"** — um nicho que ninguem atende.

**Analogia:** Intercom esta para suporte assim como Spalla esta para mentoria. Ambos usam WhatsApp como canal, mas os workflows, metricas e views sao completamente diferentes.

**Mensagem-chave:** "O unico inbox construido para quem acompanha pessoas, nao tickets."


---

## Proximos Passos

1. **Validar F1 (Carteira)** com consultores reais — e a view que define o produto
2. **Prototipar F2 (Resumo de Grupo)** — testar com n8n + Evolution API no ambiente de dev
3. **Definir modelo de dados para F3 (Notas Estruturadas)** — templates, campos, timeline
4. **Pesquisar compliance** da abordagem de grupos WA (Evolution API vs oficial)
5. **Benchmarking de pricing** — Chatwoot gratis self-hosted vs SaaS a R$X/consultor/mes

Responsavel para priorizacao: @pm
Responsavel para implementacao: @dev
