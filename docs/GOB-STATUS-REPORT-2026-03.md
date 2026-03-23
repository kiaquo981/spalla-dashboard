---
title: CASE Scale — Report de Status Geral para GOB
type: governance-report
status: current
date: 2026-03-22
author: Kaique Rodrigues
---

# CASE Scale — Status Report GOB
**Data de referência:** 22 de março de 2026
**Destinatário:** GOB (Governança do Negócio)
**Escopo:** Software, GitHub, Agentes de IA, Ferramentas, Processos e Backlog

---

## Índice

1. [Visão Executiva](#1-visão-executiva)
2. [GitHub — Onde cada coisa está](#2-github--onde-cada-coisa-está)
3. [Spalla Dashboard — Hub Central](#3-spalla-dashboard--hub-central)
4. [Agentes de IA — Mapeamento Completo](#4-agentes-de-ia--mapeamento-completo)
5. [ClickUp — Gestão Operacional](#5-clickup--gestão-operacional)
6. [Ferramentas e SaaS](#6-ferramentas-e-saas)
7. [Backlog Estratégico Consolidado](#7-backlog-estratégico-consolidado)

---

## 1. Visão Executiva

A CASE Scale opera com um stack proprietário em construção ativa. O ativo central é o **Spalla Dashboard** — plataforma web de gestão dos mentorados. Paralelo a isso, temos 11 agentes de IA no N8N em produção e um roadmap de 39 agentes mapeados na imersão de produto de março.

```
Status geral: 🟡 MVP funcional — em uso parcial pela equipe
Próximo ciclo: adoção + integrações críticas + pipeline de dossiê em produção
```

**Números-chave:**

| Dimensão | Quantidade | Status |
|----------|-----------|--------|
| Repositórios GitHub ativos | 2 (spalla + bu-case) | ✅ Ativos |
| Módulos do Spalla | 17 | 🔄 Funcional, adoção parcial |
| Agentes N8N em produção | 11 | 🔄 Alguns com problemas |
| Workflows N8N no ar (total) | 59 de 100 ativos | ✅ Monitorado via Cortex |
| Execuções N8N / 24h | 200 (199 sucesso, 1 erro) | 🔄 99.5% saúde |
| Agentes mapeados para construir | 39 (imersão mar/26) | ❌ Roadmap |
| Workflows na KB (bu-case) | 299 arquivos / 9 pastas | ✅ No GitHub |
| Hub CASE AI — agentes ao vivo | 21 (Estratégia 13, Conteúdo 4, Utilitários 2, Funis 1) | ✅ Em produção |
| Social CASE — mentorados | 35 total / 24 ativos (69%) / 13 precisam atenção | 🔄 Beta |
| Social CASE — conteúdos | 2.102 conteúdos / 8.3% engagement médio | 🔄 Beta |
| FunnelCase — funis construídos | 16 funis (projeto Deisy) | 🔄 Beta |

---

## 2. GitHub — Onde Cada Coisa Está

### 2.1 Repositórios

| Repo | O que é | Deploy | Status |
|------|---------|--------|--------|
| `case-company/spalla-dashboard` | Software de gestão dos mentorados | Vercel (frontend) + Railway (backend) | ✅ Em produção |
| `case-company/bu-case` | Knowledge base, JSONs dos agentes, KB Queila, playbooks | — (versionamento e backup) | ✅ Ativo |

---

### 2.2 Repositório `bu-case` — Estrutura Completa

Este repositório centraliza todo o conhecimento técnico e operacional da empresa.

#### `/drive/agents/n8n-workflows/` — JSONs dos Agentes N8N

> Branch: `develop` | Path: `bu-case/drive/agents/n8n-workflows/`

| Pasta | Agente | Status |
|-------|--------|--------|
| `analise-formatos/` | Agente de Análise de Formato de Conteúdo | ✅ Exportado |
| `arquitetura-produto/` | Agente Arquitetura de Produto | ✅ Exportado |
| `download-expert/` | Agente Download do Expert | ✅ Exportado |
| `lapidacao-perfil/` | Agente de Lapidação de Perfil Instagram | ✅ Exportado |
| `onboarding/` | Fluxo de Entrada de Novo Mentorado | ✅ Exportado |
| `roteiros/` | Agente de Ideias & Roteiros de Conteúdo | ✅ Exportado |
| `stories/` | Agente Stories | ✅ Exportado (precisa revisão) |
| `transcricao-reels/` | Agente de Transcrição de Reels e Carrosséis | ✅ Exportado |
| `whatsapp/` | Agente Orquestrador de WhatsApp | ✅ Exportado |

#### `/drive/kb/` — Knowledge Base

| Pasta | Conteúdo |
|-------|---------|
| `architecture_db/` | Arquitetura e schemas do banco de dados |
| `gold_standard_docs/` | Dossiês gold standard de referência |
| `kb_aulas_queila_conteudo/` | Aulas da Academia Expert (Queila) |
| `kb_conteudo/` | Base de conhecimento de conteúdo |
| `kb_entrega_dossie/` | Materiais e processos de entrega do dossiê |
| `playbooks/` | Playbooks operacionais |
| `transcricoes/` | Transcrições de reuniões e calls |
| `_INDEX.md` | Índice mestre da KB |

---

### 2.3 Repositório `spalla-dashboard` — Worktrees Ativos

| Worktree | Escopo | Situação |
|----------|--------|----------|
| `wt-carteira-owner` | Carteira de mentorados por consultor | ✅ Merged |
| `wt-cfo-payments` | View financeiro CFO | ✅ Merged |
| `wt-dossie-pipeline` | Pipeline de dossiês no Spalla | ✅ Merged |
| `wt-production-ready` | Hardening de produção | ✅ Merged |
| `wt-evolution-msg-sync` | Sincronização de mensagens Evolution | 🔄 Em desenvolvimento |
| `wt-google-calendar-integration` | Agenda Google Calendar | 🔄 Com problemas |
| `wt-wa-topics` | Tópicos de WhatsApp por mentorado | 🔄 Inativo |
| `wt-wa-bulk-ops` | Operações em massa no WhatsApp | 🔄 Em desenvolvimento |
| `wt-wa-inbox-ui` | UI de inbox WhatsApp | 🔄 Em desenvolvimento |
| `wt-notifications` | Sistema de notificações in-app | 🔄 Em desenvolvimento |
| `wt-recurring-tasks` | Tarefas recorrentes | 🔄 Pendente |

---

## 3. Spalla Dashboard — Hub Central

**Stack:** Python 3.9 (Railway) + HTML/Alpine.js (Vercel)
**URL:** spalla-dashboard.vercel.app
**DB:** Supabase (PostgreSQL + RLS)
**Integrações:** ClickUp API, Evolution API (WhatsApp), Google Sheets, Supabase Storage

### 3.1 Mapa de Módulos — Status Atual

#### ✅ Funcionando bem

| Módulo | O que funciona | Observações |
|--------|----------------|-------------|
| **Dashboard (mentorados)** | Lista completa, filtros, status, fases, SLA de resposta, carteira por consultor | Base sólida |
| **Detalhe do Mentorado** | Ficha completa, jornada, histórico, documentos, WhatsApp | Mais completo do sistema |
| **WhatsApp — Inbox** | Mensagens sem resposta, tempo sem resposta, SLA | Proxy via Evolution |
| **Carteira WA** | Grupos por consultor, mensagens pendentes | Board funcional |
| **Financeiro (CFO)** | Pagamentos, status, alertas | Sem DB próprio ainda |
| **Onboarding CS** | Templates de tarefas por etapa, checklists | Existe, pouco utilizado |
| **Dossiês** | Produção, acompanhamento por mentorado | Funciona, falta acesso integrado |
| **Agenda (Zoom)** | Integração Zoom | Google Calendar com problemas |
| **Command Center** | Projetos, sprint, time, atividade (ClickUp live) | Em finalização |
| **Tarefas (ClickUp)** | Kanban de tasks, filtros | Falta custom fields |

#### 🔄 Parcialmente funcionando / Precisa atenção

| Módulo | Problema | Prioridade |
|--------|----------|-----------|
| **Agenda (Google Calendar)** | Integração com problemas | Alta |
| **WhatsApp (proxy)** | Não é nativo — gerenciar conversas não é prático | Alta |
| **WA Tópicos** | Existe mas está inativo | Média |
| **Kanban por Fase** | Falta detalhamento por etapa (call Queila, onboarding, etc.) | Alta |
| **Planos de Ação** | Coleta do dossiê funciona mas não consolida corretamente | Alta |
| **Lembretes** | Bug: aparecem para outros usuários (vinculado ao login errado) | Média |
| **Jornadas dos Mentorados** | Estrutura existe mas fluxo não está lógico | Alta |

#### ❌ Não implementado

| Feature | Impacto |
|---------|---------|
| WhatsApp nativo (coleta, cadastro, tarefas via WA) | Alto |
| ClickUp Custom Fields espelhados no Spalla | Alto |
| Kanban por etapa/fase com checklist de calls | Alto |
| Google Drive vinculado (Docs como se fosse nativo) | Médio |
| Financeiro → persistência em Supabase | Médio |
| Dossiês → acesso Google Docs integrado | Médio |
| Planos de Ação → fluxo de atualização pós-dossiê | Médio |
| WhatsApp Bulk Ops | Médio |

### 3.2 Adoção pelo Time

O sistema tem funcionalidades que existem mas não viraram hábito:

- **Onboarding CS** — templates prontos, ninguém usa sistematicamente
- **Planos de Ação** — coletado, não é consultado depois
- **Lembretes** — uso raro
- **Views de Equipe** — existem mas pouco úteis na prática

---

## 4. Agentes de IA — Mapeamento Completo

### 4.1 Agentes N8N — Inventário Completo (Auditoria Mar/2026)

> **Instância:** `meueditor.manager01.feynmanproject.com` (infraestrutura Feynman compartilhada)
> **Total instância:** 897 workflows | **Com "CASE" no nome:** 24 | **CASE-relacionados (sem nome):** ~36
> **JSONs exportados:** `bu-case/drive/agents/n8n-workflows/`

#### Legenda de Status N8N
| Símbolo | Significado |
|---------|-------------|
| ✅ | Active — workflow publicado e rodando |
| ⊘ | Inactive — despublicado ou em standby |
| 🔄 | Funcionando mas com melhorias pendentes |
| ❌ | Não integrado / fora de uso |

---

#### 4.1.1 Workflows com "CASE" no Nome (24 workflows)

> Auditado via extração DOM do N8N em Mar/2026. Status por SVG class (`_publishIndicatorColor_` = Active).

| # | Workflow | Status N8N | Cluster | Observação |
|---|----------|-----------|---------|-----------|
| 1 | **CASE - WA 02 - Orquestrador de WhatsApp CASE** | ✅ Active | WhatsApp System | Workflow principal de orquestração WA |
| 2 | **CASE - WA 03 - Mensagens Proativas WhatsApp** | ✅ Active | WhatsApp System | Disparo proativo de mensagens |
| 3 | **CASE - WA 05 - Integração Metas WhatsApp** | ✅ Active | WhatsApp System | Integração com Meta/Facebook |
| 4 | **CASE Scraper + WhatsApp v34** | ✅ Active | WhatsApp System | Scraper Instagram + envio WA |
| 5 | **CASE Stories** | ✅ Active | Conteúdo Hub | Geração de stories Instagram |
| 6 | **CASE Download Expert - Sistema Novo** | ✅ Active | Pipeline Dossiê | Call de download estruturada |
| 7 | **CASE SDR** | ✅ Active | Pipeline Vendas | Qualificação e SDR |
| 8 | **CASE SDR Interno** | ✅ Active | Pipeline Vendas | Fluxo SDR interno |
| 9 | **CASE Agendamento** | ✅ Active | Onboarding | Agendamento de calls |
| 10 | **CASE - Lapidação de Perfil — Parte 1** | ⊘ Inactive | Conteúdo Hub | Análise de perfil IG |
| 11 | **CASE - Lapidação de Perfil — Parte 2** | ⊘ Inactive | Conteúdo Hub | Output lapidação IG |
| 12 | **CASE Agente Arquitetura de Produto** | ⊘ Inactive | Arquitetura Produto | 1 de 5 sub-agentes |
| 13 | **CASE Arquitetura Produto — Orquestrador** | ⊘ Inactive | Arquitetura Produto | Orquestrador dos 5 agentes |
| 14 | **CASE Arquitetura Produto — Análise** | ⊘ Inactive | Arquitetura Produto | Sub-agente análise |
| 15 | **CASE Arquitetura Produto — Síntese** | ⊘ Inactive | Arquitetura Produto | Sub-agente síntese |
| 16 | **CASE Arquitetura Produto — Output** | ⊘ Inactive | Arquitetura Produto | Sub-agente output |
| 17 | **CASE Plano de Ação** | ⊘ Inactive | Plano de Ação | Geração de plano de ação |
| 18 | **CASE Onboarding Novo Mentorado** | ⊘ Inactive | Onboarding | Fluxo entrada mentorado |
| 19 | **CASE Análise de Formato de Conteúdo** | ⊘ Inactive | Conteúdo Hub | Análise formato posts |
| 20 | **CASE Transcrição de Conteúdo** | ⊘ Inactive | Pipeline Dossiê | Transcrição reels/carrosséis |
| 21 | **CASE - Fluxo de Concepção de Dossiê** | ⊘ Inactive | Pipeline Dossiê | Saindo do N8N — prompts baixados |
| 22 | **CASE Revisão de Dossiê** | ⊘ Inactive | Pipeline Dossiê | QA gate dossiê |
| 23 | **CASE Entrega de Dossiê** | ⊘ Inactive | Pipeline Dossiê | Entrega ao mentorado |
| 24 | **CASE Análise de Conteúdo Hub** | ⊘ Inactive | Conteúdo Hub | A confirmar com Kaique |

**Resumo CASE-named:** 9 Active ✅ / 15 Inactive ⊘

---

#### 4.1.2 Workflows CASE-relacionados (sem "CASE" no nome — Top usados)

> Identificados por recência de uso (últimos atualizados na instância). Ordenados por último update.

| # | Workflow | Status N8N | Cluster | Observação |
|---|----------|-----------|---------|-----------|
| 1 | **Download Expert V10** | ✅ Active | Pipeline Dossiê | Versão mais recente do download |
| 2 | **WA Orquestrador Principal** | ✅ Active | WhatsApp System | Backbone WA |
| 3 | **Arquitetura de Produto — Main** | ✅ Active | Arquitetura Produto | Workflow consolidado |
| 4 | **Agente de Ideias & Roteiros** | 🔄 Active | Conteúdo Hub | Melhorias pendentes |
| 5 | **Transcrição Reels e Carrosséis** | ✅ Active | Pipeline Dossiê | Em uso |
| 6 | **Fluxo Entrada Novo Mentorado** | ✅ Active | Onboarding | Em uso |
| 7 | **Agendamento de Calls** | ✅ Active | Onboarding | Em uso |
| 8 | **SDR Qualificação** | ✅ Active | Pipeline Vendas | Em uso |
| 9 | **Lapidação Instagram v2** | ⊘ Inactive | Conteúdo Hub | Substituído por CASE-named |
| 10 | **Plano de Ação Mentorado** | 🔄 Active | Plano de Ação | Em uso, ajustes pendentes |
| 11-36 | *(Workflows adicionais — a catalogar iterativamente com Kaique)* | — | — | — |

---

#### 4.1.3 Clusters Funcionais — Visão Consolidada

| Cluster | Workflows | Ativos | Função Principal |
|---------|-----------|--------|-----------------|
| **WhatsApp System** | WA 02, WA 03, WA 05, Scraper v34 | 4 ✅ | Orquestração completa de mensagens WA |
| **Download Expert v10** | Download Expert V10, CASE Download Expert | 2 ✅ | Call de download estruturada com extração de dados |
| **Arquitetura de Produto** | 5 sub-agentes + orquestrador | 1 ✅ (main) | Análise e síntese de produto do mentorado |
| **Pipeline Dossiê** | Transcrição, Concepção, Revisão, Entrega | 1 ✅ | End-to-end de produção do dossiê |
| **Conteúdo Hub** | Stories, Lapidação, Ideias, Roteiros, Análise | 2 ✅ | Geração de conteúdo Instagram |
| **CASE SDR** | SDR, SDR Interno | 2 ✅ | Qualificação e pipeline de vendas |
| **Onboarding** | Onboarding, Agendamento, Entrada Mentorado | 3 ✅ | Entrada e integração de novos mentorados |
| **Plano de Ação** | Plano de Ação | 1 🔄 | Geração de plano de ação personalizado |

---

#### 4.1.4 Workflows Legados (referência histórica)

> Tabela original do GOB — workflows mapeados antes da auditoria de Mar/2026.

| # | Agente | Status Histórico |
|---|--------|-----------------|
| 1 | Agente de Ideias & Roteiros de Conteúdo | 🔄 Melhorias pendentes |
| 2 | Agente Stories | 🔄 Revisão de prompts |
| 3 | Agente Orquestrador de WhatsApp | ✅ Funcionando |
| 4 | Fluxo de Entrada de Novo Mentorado | ✅ Funcionando |
| 5 | Lapidação de Perfil Instagram — Parte 1 | ❌ Não integrado |
| 6 | Lapidação de Perfil Instagram — Parte 2 | ❌ Não integrado |
| 7 | Fluxo de Concepção de Dossiê | ❌ Saindo do N8N |
| 8 | Agente Download do Expert | 🔄 Em transição |
| 9 | Agente Arquitetura de Produto | ✅ Disponível |
| 10 | Transcrição de Reels e Carrosséis | ✅ Funcionando |
| 11 | Análise de Formato de Conteúdo | ✅ Funcionando |

---

### 4.2 Roadmap de Agentes — Imersão de Produto (Mar/2026)

> 39 necessidades mapeadas. Cruzamento de 25+ fontes: Sprint Master, transcrições, notas, demandas Kaique/Queila, backlog Spalla.

#### Legenda

| Status | Significado |
|--------|-------------|
| **CONSTRUIR** | Não existe. Criar do zero. |
| **REVISAR** | Existe com problemas graves. Refatorar. |
| **MELHORAR** | Existe, funciona parcialmente. Ajustes pontuais. |
| **INFRAESTRUTURA** | Fundação técnica que os agentes dependem. |

#### 4.2.1 Pipeline de Dossiê — `[Download → Transcrição → Resumo → Geração → Revisão → Entrega]`

| ID | Agente | Status | O que faz | Bloqueia |
|----|--------|--------|-----------|----------|
| **AGEN-06** | Resumir 2 Calls → Texto p/ Dossiê | CONSTRUIR | Extrai da transcrição as informações organizadas por seção do dossiê. Sem ele, AGEN-01 não tem input estruturado. | AGEN-01 |
| **AGEN-11** | Mapa de Comunicação do Mentorado | CONSTRUIR | Gera DNA de comunicação (personalidade, tom, vocabulário) a partir da call de download. Input obrigatório para todos os agentes de conteúdo. | AGEN-03, AGEN-07 |
| **AGEN-01** | Sequência Completa: Download → Dossiê | CONSTRUIR | Pipeline principal. Pega output de AGEN-06 + AGEN-11 e gera dossiê completo com todas as seções. | Entrega completa |
| **AGEN-09** | Regra de Zero Invenção | REVISAR | Constraint de segurança — quando agente não encontra informação, escreve "Não encontrado" em vez de inventar. Existe nos prompts mas sem verificação automática. | Confiança do mentorado |
| **AGEN-02** | Pré-Revisão Automática de Dossiê | CONSTRUIR | QA gate antes da revisão da Mariza. Checa: completude, coerência, tom. Reduz turnaround de 25 dias → ~10-12 dias. | Velocidade de entrega |
| **AGEN-10** | Memória do Mentorado (Contexto Persistente) | CONSTRUIR | Armazena decisões prévias, pilares, feedback, classificação C1/C2/C3. Sem isso, cada interação começa do zero. | Escala e retrabalho |
| **AGEN-14** | Validação de Execução Pós-Dossiê | CONSTRUIR | Monitora se mentorado executou as recomendações. Transforma CS de reativo em proativo. | Resultado do mentorado |

#### 4.2.2 Pipeline de Conteúdo — `[Lapidação → Posts → Ideias → Roteiros → Stories → Análise]`

| ID | Agente | Status | Problema Principal |
|----|--------|--------|--------------------|
| **AGEN-03** | Sequência Lapidação → Posts → Ideias → Roteiros → Stories | REVISAR | 5 sub-agentes existem mas com problemas: Lapidação exige foto formal desnecessariamente; Posts Fixados geram output ruim (Mariza revisa quase tudo); Stories perde contexto das etapas anteriores |
| **AGEN-05** | Separar Modos: Criar vs. Revisar | REVISAR | Agentes atuais misturam criação e revisão no mesmo fluxo → output incoerente. Afeta TODOS os agentes. |
| **AGEN-07** | Agente Específico para Posts Fixados | CONSTRUIR | Posts fixados (long-form, educativos, atemporais) têm formato completamente diferente de Stories. Usar o mesmo agente gera qualidade ruim. |
| **AGEN-04** | Revisão de Roteiros de Conteúdo | CONSTRUIR | QA gate para roteiros antes da produção. Verifica: tom, pilar, formato, CTA. Depende de Mariza definir critérios. |
| **AGEN-22** | Banco de Referências por Formato | INFRAESTRUTURA | Knowledge base com exemplos reais por formato (Destaques, Stories, Reels, Carrosséis). Sem isso, agentes geram "no vácuo". Mariza seleciona exemplos, Kaique estrutura. |
| **AGEN-19** | Análise de Conteúdo Pós-Publicação | CONSTRUIR | Após 4+ semanas publicando, analisa métricas e recomenda ajustes. 3 calls de análise previstas na jornada. |
| **AGEN-20** | Cronograma de Postagens Automático | CONSTRUIR | Gera calendário semanal indexado por SEMANA (não data) — permite entrada contínua de mentorados. |

#### 4.2.3 Pipeline Comercial — `[Classificação → Funil → Abordagem → Follow-up → Fechamento]`

| ID | Agente | Status | O que faz |
|----|--------|--------|-----------|
| **AGEN-08** | Mensagens WhatsApp por Tipo de Lead | CONSTRUIR | Variações de mensagem por tipo (ex-aluno, prospect, cold, referral). Curtas, diretas, não-robóticas. Bloqueado por Mariza organizar framework de abordagens. |
| **AGEN-12** | Revisão do Agente de Ofertas | REVISAR | Gera ofertas com critérios vagos e baixa assertividade. Precisa: Mariza organizar critérios, depois Kaique ajusta. |
| **AGEN-18** | Recomendador de Funil por Perfil | CONSTRUIR | Dado perfil C1/C2/C3, recomenda funil e gera templates de abordagem. 3 perfis mapeados: demanda+autoridade → Abordagem; resultado sem demanda → Aula; sem demanda+off fraco → Evento. |
| **AGEN-21** | Agente de Anúncios (Gerador + Analisador) | CONSTRUIR | Gera variações de anúncio por funil + analisa performance de campanhas. Depende de Kit de Tráfego (DOSS-14). |
| **AGEN-30** | Follow-up Automático (Pré/Pós Consulta) | CONSTRUIR | Mensagens automáticas de follow-up por etapa do funil. Canais: WhatsApp + Email. Depende de CRM (Kommo para C3). |

#### 4.2.4 Suporte CS & Operações Internas

| ID | Agente | Status | O que faz |
|----|--------|--------|-----------|
| **AGEN-13** | Agentes @mention no WhatsApp | CONSTRUIR | Agentes especialistas acionáveis via @mention nos grupos: `@case-copy`, `@case-comercial`, `@case-trafego`, `@case-funil`, `@case-conteudo`. Elimina gargalo de Hugo/Queila em cada revisão. |
| **AGEN-16** | Monitor SLA de Grupos WhatsApp | MELHORAR | Já existe parcialmente (whatsapp-mention-alerts + whatsapp-response-analyzer no N8N). Precisa integrar com SLA por canal e dashboard consolidado. |
| **AGEN-17** | Coaching Comercial Interno (para Consultores) | CONSTRUIR | Analisa calls de vendas dos consultores (Heitor/Lara) e dá feedback sobre técnica, objeções, fechamento. Ferramenta interna. |
| **AUTO-01** | Automação Financeira (Billing separado do CS) | CONSTRUIR | CS não deve cobrar — destrói a relação. Automação de cobrança + lembretes separada da relação consultor-mentorado. |
| **SPAL-07** | Chat NL do Mentorado no Spalla | CONSTRUIR | Mentorado pergunta em linguagem natural: "O que faço essa semana?", "Já entreguei meus posts?". Reduz perguntas ao CS. Depende de AGEN-10 e AGEN-14. |
| **SPAL-08** | FAQ Inteligente para CS | CONSTRUIR | CS busca processos e links em linguagem natural. Substitui planilha estática. |

#### 4.2.5 Produto C3 — Agentes Específicos

| ID | Agente | Status | O que faz |
|----|--------|--------|-----------|
| **AGEN-15** | Diagnóstico Automático (Questionário Inteligente) | RECLASSIFICAR | Hoje é planilha/formulário estático. Deveria ser agente conversacional com 21 pontos de extração + classificação C1/C2/C3 automática. |
| **AGEN-23** | Análise de Vídeo/Consulta Gravada | CONSTRUIR | Mentorado grava consultas por 1 semana → agente analisa técnica, objeções, fechamento → feedback estruturado. |
| **AGEN-27** | Ofertas Interativo (Pacotes + Precificação) | CONSTRUIR | Guia mentorado na criação de pacotes com precificação automática, bundling, estruturas de oferta. |
| **AGEN-31** | Coaching de Autoridade (Acompanha Funil 3m) | CONSTRUIR | Coach IA que acompanha mentorado ao longo dos 3 meses de funil de autoridade. Responde dúvidas, dá feedback, mantém accountability. |

---

### 4.3 Sumário do Roadmap de Agentes

| Status | Quantidade | Agentes |
|--------|-----------|---------|
| ✅ Existem e funcionam | 5 | WhatsApp, Transcrição, Análise Formato, Onboarding, Arquitetura de Produto |
| 🔄 Existem com problemas | 6 | Ideias/Roteiros, Stories, Download Expert, Lapidação Perfil, Concepção Dossiê, Revisão Ofertas |
| ❌ CONSTRUIR — core | 7 | AGEN-01, 02, 06, 07, 10, 11, 14 |
| ❌ CONSTRUIR — gap | 14 | AGEN-08, 13, 15, 17, 18, 19, 20, 21, 23, 27, 30, 31, SPAL-07, SPAL-08, AUTO-01 |
| 🔧 REVISAR | 4 | AGEN-03 (5 sub), 05, 09, 12 |
| 🏗 INFRAESTRUTURA | 1 | AGEN-22 (banco referências) |

**Por pipeline:**

| Pipeline | Total agentes | Existem | A construir |
|----------|--------------|---------|-------------|
| Dossiê | 7 | 1 (parcial) | 6 |
| Conteúdo | 7 | 3 (com problemas) | 4 |
| Comercial/Vendas | 5 | 1 (com problemas) | 4 |
| CS/Operações | 6 | 1 (parcial) | 5 |
| Produto C3 | 4 | 0 | 4 |

---

## 5. ClickUp — Gestão Operacional

**Workspace:** All In Marketing (ID: `9011530618`)
**Space:** Case Scale (ID: `90114112693`)

### 5.1 Sprints Atuais

| Sprint | Período | Status |
|--------|---------|--------|
| Sprint 1 | 16–22 Mar 2026 | ✅ Ativo |
| Sprint 2 | 23–29 Mar 2026 | Planejado |
| Sprint 3 | 30 Mar–5 Abr 2026 | Planejado |

### 5.2 Status do Workflow com IA

| Item | Status |
|------|--------|
| Workflow CASE com IA | 🔄 Quase fechado — Gobe finalizando |
| APIs subidas para Gobe manusear | ✅ Disponíveis |
| Pipeline de dossiê | ❌ Precisa teste em tempo real |
| Playbook de Call de Download | ❌ Em finalização |
| Mapa do Expert | ❌ Pendente |

### 5.3 Integrações ClickUp ↔ Spalla

| Integração | Status |
|-----------|--------|
| Tasks visíveis no Spalla (leitura via API v2) | ✅ Funcionando |
| Activity feed do Command Center (ClickUp live) | ✅ Funcionando |
| Sprint progress sincronizado | ✅ Funcionando |
| Custom Fields espelhados no Spalla | ❌ Não implementado |
| Criar/atualizar tasks do Spalla → ClickUp | ❌ Só leitura hoje |

---

## 6. Ferramentas e SaaS

### 6.1 Stack Técnico

| Ferramenta | Uso | Status |
|-----------|-----|--------|
| **Vercel** | Deploy do Spalla (frontend) | ✅ Ativo |
| **Railway** | Backend Python do Spalla | ✅ Ativo |
| **Supabase** | DB PostgreSQL + Auth + Storage | ✅ Ativo |
| **ClickUp** | Gestão de tarefas e sprints | ✅ Em uso ativo |
| **GitHub** | Versionamento (spalla + bu-case) | ✅ Ativo |
| **N8N** | Automações e agentes de IA | ✅ Ativo (24 CASE-named + ~36 relacionados / 897 total instância) |
| **Evolution API** | WhatsApp (proxy) | 🔄 Funcional, limitado |
| **Google Workspace** | Drive, Docs, Calendar | 🔄 Parcialmente integrado |
| **Zoom** | Calls e sessões | ✅ Integrado no Spalla |
| **Claude API** | IA dos agentes e análises | ✅ Em uso |

### 6.2 Ferramentas Proprietárias CASE

| Ferramenta | URL | O que é | Métricas reais | Status |
|-----------|-----|---------|----------------|--------|
| **Spalla Dashboard** | `spalla-dashboard.vercel.app` | Hub de gestão dos mentorados | — | ✅ Em produção |
| **Hub CASE AI** | `hub.caseai.com.br` | Central de agentes de IA para mentorados | 21 agentes: Estratégia (13), Conteúdo (4), Utilitários (2), Funis (1) | ✅ Ao vivo |
| **Social CASE** | `social.caseai.com.br` | Calendário editorial + métricas de conteúdo | 35 mentorados / 24 ativos / 13 precisam atenção / 2.102 conteúdos / 8.3% engagement | 🔄 Beta |
| **FunnelCase** | `funnelcase.vercel.app` | Editor visual de funis (nodes + components) | 16 funis construídos (Abordagem de Lista, Social Seller, Autoridade Instagram...) | 🔄 Beta → futuro: integrar no Spalla |
| **Cortex** | `cortex-peek.vercel.app` | Monitor de saúde dos workflows N8N | 200 exec/24h · 199 sucesso · 1 erro · 59/100 workflows ativos | ✅ Ao vivo |
| **PageOS** | `page-os-eta.vercel.app` | Criação de páginas de captura | — | 🔄 Beta |
| **Carousel AI** | `carousel-ai-production.up.railway.app` | Produção de carrosséis com IA | — | 🔄 Beta |

#### 6.2.1 Hub CASE AI — Agentes disponíveis aos mentorados

> URL: `hub.caseai.com.br` | 21 agentes totais

| Categoria | Qtd | Agentes recentes/relevantes |
|-----------|-----|----------------------------|
| Estratégia | 13 | Arquitetura de Produto, Download Expert |
| Conteúdo | 4 | Agente Stories, Agente Naming, Melhorias Roteiros |
| Utilitários | 2 | — |
| Funis | 1 | — |

#### 6.2.2 Social CASE — Dashboard de Mentorados

> URL: `social.caseai.com.br` | Atualizado em tempo real

| Métrica | Valor | Interpretação |
|---------|-------|---------------|
| Total mentorados | 35 | Base de mentorados cadastrados |
| Ativos | 24 (69%) | Publicando conteúdo regularmente |
| Precisam atenção | 13 | Sem atividade recente ou baixo engajamento |
| Total conteúdos | 2.102 | Produzidos por todos os mentorados |
| Engagement médio | 8.3% | Acima da média de mercado (~3-5%) |

#### 6.2.3 Cortex (N8N Monitor) — Saúde dos Workflows

> URL: `cortex-peek.vercel.app` | Dados das últimas 24h

| Métrica | Valor |
|---------|-------|
| Execuções / 24h | 200 |
| Sucesso | 199 (99.5%) |
| Erro | 1 — `CASE — Analisador WhatsApp Semanal` → tabela `analises_whatsapp` |
| Workflows ativos | 59 de 100 total |

**Ação necessária:** Investigar erro no `Analisador WhatsApp Semanal` (provável problema de escrita na tabela `analises_whatsapp` no Supabase).

#### 6.2.4 FunnelCase — Editor Visual de Funis

> URL: `funnelcase.vercel.app` | 16 funis no projeto "Deisy"

Editor visual com nodes e components organizados em 4 categorias:
- **Canais** — Pontos de entrada (WhatsApp, Instagram, etc.)
- **Mensagens** — Templates de comunicação
- **Páginas** — Landing pages e capturas
- **Vendas** — Etapas de conversão

Funis mapeados (amostra): Abordagem de Lista, Social Seller, Autoridade Instagram, e demais funis CASE.

**Pendências:** Integração com Spalla Dashboard | Mapeamento completo de funis no GOB.

#### 6.2.5 PageOS — Criação de Páginas de Captura

> URL: `page-os-eta.vercel.app` | Status: Beta

Ferramenta proprietária para criação de páginas de captura (landing pages) para mentorados CASE.

| Item | Status |
|------|--------|
| URL pública | ✅ `page-os-eta.vercel.app` |
| Páginas criadas | ❓ A auditar com Kaique |
| Templates disponíveis | ❓ A auditar |
| Integração com funis (FunnelCase) | ❓ A confirmar |
| Integração com N8N | ❓ A confirmar |
| O que foi enviado aos clientes | ❓ A confirmar |

**Próximos passos GOB:** Kaique mostra o interior → documentar páginas, templates, status de uso por mentorado.

#### 6.2.6 Carousel AI — Produção de Carrosséis com IA

> URL: `carousel-ai-production.up.railway.app` | Status: Beta

Ferramenta proprietária para produção de carrosséis para Instagram com assistência de IA.

| Item | Status |
|------|--------|
| URL pública | ✅ `carousel-ai-production.up.railway.app` |
| Carrosséis criados | ❓ A auditar com Kaique |
| Templates disponíveis | ❓ A auditar |
| Integração com Hub CASE AI | ❓ A confirmar |
| Integração com Social CASE | ❓ A confirmar |
| O que foi enviado aos clientes | ❓ A confirmar |

**Próximos passos GOB:** Kaique mostra o interior → documentar templates, artefatos criados, status de uso.

---

## 7. Backlog Estratégico Consolidado

### Prioridade 1 — Impacto imediato na operação

| # | Item | Área | Resp. | Depende de |
|---|------|------|-------|-----------|
| 1 | WhatsApp Evolution: aprofundar para gestão real de conversas | Spalla | Dev | Documentação Evolution API |
| 2 | Kanban por etapa/fase com checklist de calls (Queila, onboarding) | Spalla | Dev | — |
| 3 | Google Calendar: resolver integração | Spalla | Dev | — |
| 4 | ClickUp Custom Fields no Spalla | Spalla + ClickUp | Dev | — |
| 5 | Pipeline de dossiê: AGEN-06 + AGEN-11 + AGEN-01 (teste em tempo real) | N8N | Dev + Gobe | Roteiro de Download (Queila) |
| 6 | AGEN-09: verificação automática de zero invenção | N8N | Dev | — |

### Prioridade 2 — Qualidade e consolidação

| # | Item | Área | Resp. |
|---|------|------|-------|
| 7 | Playbook de Call de Download | ClickUp | Gobe |
| 8 | AGEN-05: Separar modos Criar vs. Revisar nos agentes | N8N | Dev |
| 9 | AGEN-10: Memória persistente do mentorado | N8N | Dev |
| 10 | AGEN-03: Revisar 5 sub-agentes de conteúdo | N8N | Dev + Mariza |
| 11 | Dossiês: conectar acesso Google Docs | Spalla | Dev |
| 12 | Planos de Ação: fluxo de atualização pós-dossiê | Spalla | Dev |
| 13 | Financeiro: persistência em Supabase | Spalla | Dev |
| 14 | Lembretes: isolar por usuário logado (bug) | Spalla | Dev |
| 15 | AGEN-22: Banco de referências por formato | N8N | Dev + Mariza |

### Prioridade 3 — Próximo ciclo

| # | Item | Área | Resp. |
|---|------|------|-------|
| 16 | AGEN-13: @mention specialists nos grupos WA | N8N + WA | Dev |
| 17 | AGEN-14: Validação de execução pós-dossiê | N8N + Spalla | Dev |
| 18 | AGEN-18: Recomendador de funil por perfil | N8N | Dev |
| 19 | AUTO-01: Automação financeira separada do CS | N8N | Dev |
| 20 | WhatsApp nativo: coletas, cadastro e tarefas via WA | Spalla | Dev |
| 21 | Funnel Case integrado ao Spalla | Spalla | Dev |
| 22 | Modelo de apresentação do dossiê + vídeos | Produto | Kaique |

---

## 8. Status de Entrega — O que Está Construído mas Não Chegou ao Cliente

> Esta seção documenta o que foi desenvolvido mas ainda não foi formalmente entregue / disponibilizado para os mentorados. Essencial para o Gob priorizar o que "já existe mas está parado".

### 8.1 Por Plataforma — Status de Entrega

| Plataforma | Construído | Entregue aos clientes | Gap |
|-----------|-----------|----------------------|-----|
| **Hub CASE AI** | ✅ 21 agentes ao vivo | ✅ Mentorados têm acesso | Verificar quais mentorados estão usando de fato |
| **Social CASE** | ✅ Ao vivo, 35 mentorados | 🔄 Beta — acesso parcial | 13 mentorados sem atividade recente — abandonaram ou não foram onboardados |
| **FunnelCase** | ✅ 16 funis construídos | ❓ Não confirmado | Funis criados mas não está claro se mentorados estão usando ativamente |
| **PageOS** | 🔄 Beta | ❓ Não confirmado | Páginas criadas — status de uso por mentorado desconhecido |
| **Carousel AI** | 🔄 Beta | ❓ Não confirmado | Carrosséis criados — não está claro quem usa |
| **Cortex** | ✅ Ao vivo | ❌ Ferramenta interna | Monitor interno — não destinado a mentorados |
| **Spalla Dashboard** | ✅ Em produção | 🔄 Acesso interno CASE | Mentorados não acessam diretamente — é ferramenta da equipe CASE |

### 8.2 Agentes N8N — O que o mentorado acessa vs. o que só a equipe usa

| Agente/Workflow | Quem acessa | Canal de acesso | Entregue? |
|----------------|-------------|-----------------|-----------|
| Agentes do Hub CASE AI | Mentorado | `hub.caseai.com.br` | ✅ Sim |
| Download Expert V10 | Equipe CASE (Kaique/Gobe) | N8N direto | ❌ Só interno |
| WhatsApp Orquestrador | Mentorado (resposta no WA) | WhatsApp | ✅ Sim (indireto) |
| Stories + Conteúdo | Mentorado via Hub | Hub CASE AI | ✅ Sim (via Hub) |
| Arquitetura de Produto | Mentorado via Hub | Hub CASE AI | ✅ Sim (via Hub) |
| Plano de Ação | Equipe CASE | N8N direto | ❌ Só interno |
| SDR + Agendamento | Equipe CASE | N8N direto | ❌ Só interno |
| Cortex Monitor | Equipe CASE | cortex-peek.vercel.app | ❌ Só interno |
| Social CASE analytics | Equipe CASE | social.caseai.com.br | ❌ Só interno (mentorado não vê dados) |

### 8.3 O que foi construído e ainda não está sendo usado (desperdício atual)

| Item | Status | Por que parado | Ação necessária |
|------|--------|---------------|-----------------|
| Lapidação de Perfil IG (Partes 1 e 2) | ⊘ Inactive N8N | Não integrado no fluxo operacional | Kaique confirma se ainda faz sentido ou deprecar |
| Fluxo de Concepção de Dossiê | ⊘ Inactive N8N | Migrou para prompts locais (Claude) | Decidir: manter N8N ou formalizar no Claude |
| 15 workflows CASE inativos | ⊘ Inactive | Motivos variados — ver 4.1.1 | Iterar com Kaique workflow por workflow |
| PageOS páginas | 🔄 Beta | Status de uso desconhecido | Auditar: quais páginas existem, quais foram usadas |
| Carousel AI carrosséis | 🔄 Beta | Status de uso desconhecido | Auditar: quais carrosséis existem, quais foram usados |

### 8.4 Pendências de Auditoria (para próximas iterações com Kaique)

> Os itens abaixo requerem que Kaique mostre o interior de cada plataforma para completar o GOB.

| # | Plataforma | O que falta auditar |
|---|-----------|---------------------|
| 1 | **Hub CASE AI** | Lista completa dos 21 agentes por nome + qual mentorado usa qual |
| 2 | **Social CASE** | Lista dos 13 mentorados sem atividade + causa (abandonaram? não onboardados?) |
| 3 | **FunnelCase** | Todos os 16 funis do projeto Deisy + outros projetos existentes |
| 4 | **PageOS** | Páginas criadas + templates disponíveis + quem usa |
| 5 | **Carousel AI** | Carrosséis criados + templates + quem usa |
| 6 | **N8N** | Workflows 11-24 CASE-named: confirmar propósito de cada um com Kaique |
| 7 | **N8N** | ~36 workflows relacionados: Kaique explica propósito de cada cluster |
| 8 | **Cortex** | Investigar erro `Analisador WhatsApp Semanal` → tabela `analises_whatsapp` |

---

## Anexo A — Glossário

| Termo | Significado |
|-------|------------|
| **GOB** | Governança do Negócio — instância de decisão estratégica |
| **Gobe** | Responsável por fechar workflows no ClickUp e N8N |
| **bu-case** | Repositório GitHub com KB, JSONs dos agentes e documentação técnica |
| **Bill Case** | Drive com documentação técnica dos agentes de IA (espelhado no bu-case) |
| **Spalla** | Software de gestão dos mentorados (hub central) |
| **Evolution API** | API de integração com WhatsApp (proxy) |
| **C1/C2/C3** | Classificação de mentorados por perfil e maturidade digital |
| **Download do Expert** | Processo de extração de conhecimento e perfil do mentorado via call |
| **Lapidação de Perfil** | Refinamento do perfil estratégico do mentorado pós-download |
| **AGEN-XX** | Numeração dos agentes mapeados na Imersão de Produto (09-13/03/2026) |

---

## Anexo B — Onde Encontrar Cada Coisa

| O que | Onde |
|-------|------|
| JSONs dos agentes N8N | `github.com/case-company/bu-case/tree/develop/drive/agents/n8n-workflows/` |
| Knowledge base (aulas, dossiês, transcrições) | `github.com/case-company/bu-case/tree/develop/drive/kb/` |
| Código do Spalla Dashboard | `github.com/case-company/spalla-dashboard` |
| Spalla em produção | `spalla-dashboard.vercel.app` |
| N8N (agentes ativos) | `meueditor.manager01.feynmanproject.com` |
| Mapeamento de agentes (planilha) | Google Sheets: `1KKXQ9Bcznd6cnEjswS9gLcLFBgPHhd_dhI8KAJDY7JQ` |
| Desdobramento completo de agentes (39) | `bu-case/drive/kb/architecture_db/` |
| ClickUp (Workspace) | `app.clickup.com` — All In Marketing (9011530618) |
| Hub CASE AI (agentes para mentorados) | `hub.caseai.com.br` |
| Social CASE (editorial + métricas) | `social.caseai.com.br` |
| FunnelCase (editor visual de funis) | `funnelcase.vercel.app` |
| Cortex (monitor N8N) | `cortex-peek.vercel.app` |
| PageOS (criação de páginas) | `page-os-eta.vercel.app` |
| Carousel AI (carrosséis com IA) | `carousel-ai-production.up.railway.app` |

---

*Report gerado em 22/03/2026 — baseado em levantamento direto com Kaique Rodrigues + Imersão de Produto 09-13/03/2026.*
*Auditoria N8N realizada via extração DOM em Mar/2026 (897 workflows totais, 24 CASE-named, ~36 CASE-relacionados).*
*Próxima revisão: iterações com Kaique para cobrir seção 8.4 (auditoria interior das plataformas).*
