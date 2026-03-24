---
title: CASE Scale — Report de Status Geral para Gobbi
type: governance-report
status: current
date: 2026-03-22
author: Kaique Rodrigues
---

# CASE Scale — Status Report Gobbi
**Data de referência:** 22 de março de 2026
**Destinatário:** Gobbi (Governança do Negócio)
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

### 4.1 N8N — Inventário Completo (Auditoria DOM Mar/2026)

> **Instância:** `meueditor.manager01.feynmanproject.com` (infraestrutura Feynman compartilhada)
> **Total instância:** 897 workflows | 18 páginas × 50/página
> **Método de auditoria:** Extração DOM via Puppeteer — seletor `h2[class*="_cardHeading"]` + `[class*="_publishIndicatorColor_"]`
> **Data:** Mar/2026

#### Legenda
| Símbolo | Significado |
|---------|-------------|
| ✅ | Active — publicado e rodando em produção |
| ⊘ | Inactive — versão antiga, dev, ou descontinuado |

---

#### 4.1.1 Clusters Funcionais — Visão Executiva

| # | Cluster | Ativos ✅ | Função Principal | Versão Atual |
|---|---------|-----------|-----------------|-------------|
| 1 | **WhatsApp System** | ~15 | Orquestração total de mensagens WA — topics, alertas, recovery, scraper | v34 / WA 02-05 v2 |
| 2 | **Dossiê Pipeline** | ~20 | Geração completa de dossiê em capítulos (Cap 1-12) | V8 CORRIGIDO (V11 sub-WFs) |
| 3 | **Download Expert** | ~8 | Extração estruturada de calls de download (Sessões 1-3) | V10 |
| 4 | **Agentes Mentoria (Funis)** | ~50 | Automação completa dos 11 funis de vendas via WA | V3 atual |
| 5 | **Lapidação de Perfil** | ~10 | Reposicionamento de Instagram de mentorados | V12 Metodologia Queila |
| 6 | **Linha Editorial** | ~20 | Geração de ideias, roteiros e conteúdo | v7 GobbiBI FINAL |
| 7 | **Stories System** | ~5 | Geração de stories para Instagram | V8 |
| 8 | **QCES (Queila Content Extraction)** | ~7 | Extração de crenças, ganchos e posicionamento das aulas da Queila | v4 |
| 9 | **Arquitetura de Produto** | ~8 | Mapeia método, aulas e materiais do mentorado | Orquestrador v2 |
| 10 | **Instagram Scraper** | ~8 | Scraping diário de posts, seguidores, carrossel | v20 + V3 sync |
| 11 | **Onboarding Mentorados** | ~5 | Entrada, matching, inserção Supabase, grupo WA | V7 |
| 12 | **Plano de Ação** | ~4 | Geração e validação do plano de ação pós-call | v5 |
| 13 | **CASE Analytics** | ~5 | Análise WA semanal, calls Zoom, consolidado mentorados | — |
| 14 | **Pablo (Call Vendas)** | ~4 | Análise de calls de vendas + gestor de conhecimento | V2 |
| 15 | **AI Hub Monitor** | ~5 | Monitoramento de erros, custos, relatório diário IA | — |
| 16 | **RAG & Vetorização** | ~3 | Embeddings, busca vetorial, contexto de calls | — |
| 17 | **Agente Produto Lovable** | ~7 | 6 agentes Lovable: mapa, pesquisa, vitrine, método, oferta, copy | 🔄 Refaturar |
| 18 | **Ads / Tráfego** | ~4 | Monitor Facebook Ads, análise visual/copy/estratégia | — |
| 19 | **Zoom / Transcrição** | ~3 | Transcrição de calls, YouTube upload | — |
| 20 | **Legado / Dev / Descontinuado** | 0 | My workflow X, fluxos antigos, ecomm, airtable | — |

**Total estimado ativos CASE: ~180–200 workflows ✅ / ~660–680 ⊘ (arquivados/dev) — 20 clusters CASE mapeados**

---

#### 4.1.2 Cluster 1 — WhatsApp System (CORE OPERACIONAL)

| Workflow | Status | Função |
|----------|--------|--------|
| Sistema Gestão WA Scraper v34 | ✅ | Backbone — scraper + orquestração central |
| WA 02 v2 AI Topic Classifier | ✅ | Classifica mensagens por tópico com IA |
| WA 03 v2 Topic Maintenance | ✅ | Manutenção de tópicos ativos |
| WA 05 Recovery & Dead Letter | ✅ | Recuperação de mensagens falhas |
| Alertas Mensagens Pendentes | ✅ | Alerta p/ msgs sem resposta |
| Alertas WhatsApp Mensagens Pendentes 2h | ✅ | Alerta 2h sem resposta |
| Alerta Menção no Grupo | ✅ | Monitora menções em grupos |
| Alerta Mensagens Não Respondidas | ✅ | Relatório de não-respondidas |
| Follow-Up Menções Queila | ✅ | Follow-up automático de menções |
| WhatsApp Mention Alerts Spalla | ✅ | Alertas WA para Spalla |
| WhatsApp Response Analyzer Spalla | ✅ | Análise de respostas WA |
| Zap dos Tópicos | ✅ | Mapeamento de tópicos WA |
| Fluxo de Agendamento Reuniões e Ligações | ⊘ | Não está sendo utilizado |
| Parte 2 - Fluxo de Agendamento | ⊘ | Não está sendo utilizado |
| WhatsApp Scraper | ⊘ | Não está sendo utilizado |

---

#### 4.1.3 Cluster 2 — Dossiê Pipeline (PRODUTO CORE)

> **V8 CORRIGIDO** = versão em produção atual. **V11** = sub-workflows de conteúdo usados pelo V8. Versões V7/V6/V5/V4 = arquivadas.

| Workflow | Status | Função |
|----------|--------|--------|
| MAIN_WF_MASTER_V8_CORRIGIDO | ✅ | Orquestrador principal do dossiê |
| WF_ORCHESTRATOR_CAPITULOS_V8_CORRIGIDO | ✅ | Orquestra capítulos em paralelo |
| AGENTE_ANTI_ALUCINACAO_V8_CORRIGIDO | ✅ | Valida zero invenção |
| PRE PROCESSADOR V5 | ✅ | Pré-processamento do input |
| SUB_WF_00_PRE_PROCESSADOR_V8 | ✅ | Sub-WF pré-processamento |
| SUB_WF_CAP1_CONTEXTO_V8 | ✅ | Cap 1: Contexto da Expert |
| SUB_WF_CAP7_OFERTA_V8 | ✅ | Cap 7: Estrutura da Oferta |
| SUB_WF_CAP8_ARQUITETURA_V8 | ⊘ | Cap 8: Arquitetura de Produto |
| SUB_WF_CAP9A_FUNIL_V8 | ⊘ | Cap 9A: Sugestão de Funil |
| SUB_WF_CAP9B_EXECUCAO_V8 | ✅ | Cap 9B: Execução |
| SUB_WF_CAP10_STORYTELLING_V8 | ✅ | Cap 10: Storytelling |
| SUB_WF_CAP12_CONTEUDO_V8 | ✅ | Cap 12: Ideias de Conteúdo |
| SUB_WF_CAP_LAPIDACAO_V8 | ✅ | Cap: Lapidação |
| SUB_WF_CAP_PROXIMOS_PASSOS_V8 | ✅ (p10) / ⊘ (p11) | Próximos Passos |
| SUB_WF_99_POLIDOR_V8 | ✅ | Polidor final do dossiê |
| WF_EDITOR_PRINCIPAL_V11 | ✅ | Editor principal V11 |
| WF_MONTAGEM_FINAL_V11 | ✅ | Montagem final V11 |
| SUB_WF_COERENCIA / TANGIBILIZACAO V11 | ✅ | Coerência e tangibilização |
| SUB_WF_01 a SUB_WF_20 V11 | maioria ⊘ | 20 sub-agentes especializados V11 |
| WF_MAIN_ORCHESTRATOR V7/V5/V4/V2 | ⊘ | Versões anteriores — arquivadas |

---

#### 4.1.4 Cluster 3 — Download Expert (EXTRAÇÃO DE CALLS)

> **Mudança de arquitetura:** o workflow N8N (V10) será substituído. Nova abordagem: call direta com o Expert + um único agente que organiza o output. Os prompts já foram extraídos do N8N e estão no GitHub. Versões V3/V4/V5 arquivadas.

| Workflow | Status | Função |
|----------|--------|--------|
| Download Expert V10 (todos os sub-WFs) | 🔄 Em transição | Versão atual ainda em uso — será substituída pela nova arquitetura (call + agente único) |
| Download Expert V5 (E1-E13) | ⊘ | Arquivados |
| Download Expert V4 (E1-E13) | ⊘ | Arquivados |
| Download Expert V3 | ⊘ | Arquivado |

---

#### 4.1.5 Cluster 4 — Agentes Mentoria / Funis WA (MAIOR SISTEMA)

> **32 agentes ativos** cobrindo todos os funis. Estrutura: Orquestrador → Gestor de Funil → Agente Especialista → Ferramentas.

**Agentes principais (✅ todos ativos):**
- Orquestrador | VSL | Call vendas | Caçador | Lista Vip | Indicador | Evento | Levantador | Pocket | Recompensa | Upgrade | Reativação alunos | Copy | Conteúdo | Pocket criador | Gerador de Demanda

**Gestores de informação (✅ todos ativos):**
- Gestor por funil: VSL, Call vendas, Caçador, Lista Vip, Indicador, Evento, Levantador, Pocket, Recompensa, Upgrade, Reativação

**Ferramentas (✅ todas ativas):**
- Ativa agente X (7 tools) | Muda estado X (5 tools) | Escolha funil | Pocket | Copy/Mensagens | Consulta banco de dados

**Infra (✅ ativos):**
- Agentes Mentoria Fluxo geral | Agente Cadastro | Agente Entrega | Agente Campanha + tools | GPTs Entrega detalhada funis

---

#### 4.1.6 Cluster 5 — Lapidação de Perfil

| Workflow | Status | Função |
|----------|--------|--------|
| Agente Lapidação WEBHOOK - V12 METODOLOGIA QUEILA | ✅ | Webhook de entrada — versão atual |
| Webhook Lapidação Perfil [CORRIGIDO] | ✅ | Alternativo corrigido |
| Lapidação Perfil V4 - CONVERSACIONAL | ✅ | Fluxo conversacional |
| Agente Lapidacao UNIFICADO | ✅ | Versão unificada |
| Lapidacao Consolidador | ✅ | Consolida todos os outputs |
| Lapidacao Agente Ideias v6 | ✅ | Gerador de ideias de posicionamento |
| Lapidacao Roteiros v14 | ✅ | Roteiros de reposicionamento |
| Lapidacao Tool Salva / Atualiza / Busca | ✅ | Ferramentas de persistência |
| Lapidacao Agente Bio/Nome | ✅ | Bio e naming |
| Lapidacao Storytelling | ✅ | Storytelling do perfil |
| Lapidacao Status Polling | ✅ | Polling de status |
| Lapidacao Agente Criacao Posts | ✅ | Criação de posts |
| Lapidacao Scraper Perfil | ✅ | Scraping do perfil atual |
| Lapidacao Calendario V2 | ✅ | Calendário de conteúdo |
| Lapidacao Foto Perfil / RAG Contexto | ✅ | Foto e contexto RAG |
| Agente Lapidação com Transcrição | ⊘ | Versão c/ transcrição — inativa |
| Agente Lapidação com Memória | ⊘ | Versão c/ memória — inativa |

---

#### 4.1.7 Cluster 6 — Linha Editorial

> ~30 workflows. Fluxo: Cadastro → Coletores (E1-E6) → Produtores (E1-E3) → Gerador de Ideias → Orquestrador → Polidor → Salva.

**Ativos ✅:** Orquestrador Ideias GobbiBI FINAL V2, Gerador de Ideias v2, Etapa 3B Provas Sociais, Etapa 5 Diagnóstico COMPLETO, Etapa 6 Definição Editorial V3, Polidor, Tool Salva Ideia, Tool Salva Linha Editorial, Tool Salva Dados E5, Agente Cadastro CORRIGIDO, Tool Valida Email, Agente Coletor E1/E3B/E6 (CORRIGIDO), Agente Produtor E1-E3 (CORRIGIDO), Agente Bio e Apresentações, Agente Coletor Documentos, Agente Gerador de Ideias GobbiBI FINAL, Orquestrador Ideias

**Inativos ⊘:** Versões antigas (v2-v5 de gerador, V6-V7 de roteiros), coletores e produtores não-corrigidos

---

#### 4.1.8 Cluster 7 — Stories System

| Workflow | Status | Função |
|----------|--------|--------|
| Stories V8 Validador | ✅ | Valida story gerada |
| Stories V8 Estrategista | ✅ | Define estratégia de story |
| Stories V8 Escritor | ✅ | Escreve a story |
| Stories Fluxo Geral | ✅ | Orquestrador |
| Stories Agent Tools (Ideias/Roteirista/Tool Muda Estado) | ✅/⊘ | Ferramentas |
| Stories V7 (State Manager/Coletor/Orquestrador) | ⊘ | Versão anterior |

---

#### 4.1.9 Cluster 8 — QCES (Queila Content Extraction System)

| Workflow | Status | Função |
|----------|--------|--------|
| QCES Auto Sync | ✅ | Sincronização automática |
| QCES Content Extraction v4 | ✅ | Extração principal |
| QCES Parse WebVTT | ✅ | Parse de legendas Zoom |
| QCES Extract Beliefs | ✅ | Extrai crenças e princípios |
| QCES Format & Positioning | ✅ | Formata para posicionamento |
| QCES Generate Hooks/Briefing | ✅ | Gera ganchos e briefing |
| QCES Zoom Scraper | ✅ | Scraper de gravações Zoom |

---

#### 4.1.10 Cluster 9 — Arquitetura de Produto

| Workflow | Status | Função |
|----------|--------|--------|
| Arquitetura Produto Orquestrador v2 | ✅ | Orquestra todos os sub-agentes |
| Arquitetura Produto Extrator Método | ✅ | Extrai o método do mentorado |
| Arquitetura Produto Construtor Aulas | ✅ | Estrutura as aulas |
| Arquitetura Produto Construtor Materiais | ✅ | Gera materiais |
| Arquitetura Produto Revisor | ✅ | Revisão de coerência |
| Arquitetura Produto Construtor Pilar | ✅ | Define pilares do produto |
| 02_Agente_Extrator_Contexto | ✅ | Extrator de contexto |
| 04_Agente_Mapeador_Jornada | ✅ | Mapeia jornada do aluno |
| WF CAP12 STANDALONE - Ideias | ✅ | Ideias de conteúdo standalone |

---

#### 4.1.11 Cluster 10 — Instagram Scraper & Análise

| Workflow | Status | Função |
|----------|--------|--------|
| Instagram Scraper v20 | ✅ | Scraper principal IG |
| Instagram Scraper Webhook Backend | ✅ | Backend de entrada |
| Instagram Onboarding Inicial | ✅ | Onboarding de conta IG |
| Instagram Onboarding 10/10A/10B | ✅ | Fluxos de onboarding |
| Instagram Onboarding 11 Cache Thumbnails | ✅ | Cache de thumbnails |
| Scraping Diario Posts/Seguidores | ✅ | Scraping diário |
| Scraper Foto Perfil | ✅ | Foto de perfil |
| Analisar Referencia Conteudo V6 | ✅ | Análise de referências |
| Agente AI Analise Conteudo v2 | ✅ | Análise com IA |
| Linha Editorial Tools Destaques | ✅ | Destaques IG |
| Scraper IG Alunos Fluxo 1/2/3 | ✅/⊘ | Scraping de perfis de alunos |
| Scraper IG Carrossel (múltiplos) | ⊘ | Versões antigas de scraping |
| Scraper IG Sync Para Agente V3 | ⊘ | Sync agent — inativo |

---

#### 4.1.12 Cluster 11 — Onboarding Mentorados (V7)

| Workflow | Status | Função |
|----------|--------|--------|
| WF_ORQUESTRADOR_ONBOARDING_V7 | ✅ | Orquestrador principal |
| SUB_WF_ONBOARDING_01_EXTRACAO_DADOS_V7 | ✅ | Extrai dados do mentorado |
| SUB_WF_ONBOARDING_04_WHATSAPP_GROUP_V7 | ✅ | Cria grupo WA |
| SUB_WF_AUDIO_TRANSCRIPTION_V7 | ✅ | Transcreve áudio |
| Novo Mentorado | ✅ | Disparo de entrada |
| DS Stage Notification | ✅ | Notificação de estágio |
| WF2 Pré-Call 2 | ✅ | Preparação call 2 |
| WF3 Call 2 - Geração de Documentos | ✅ | Geração de docs na call |
| WF4 Pós-Call 2 - Validação e Publicação | ✅ | Validação e pub pós-call |
| AGENTE DE VALIDAÇÃO INICIAL (PRÉ-WF2) | ✅ | Valida antes da call |
| v2 - WF1 - Pos-Onboarding COM PLANO DE AÇÃO | ✅ | Pós-onboarding + plano |

---

#### 4.1.13 Cluster 12 — Plano de Ação

> Gerado automaticamente no pós-call da Queila **ou** dos consultores (Hugo, Heitor, Lara). Após a call, o sistema gera e salva o plano de ação do mentorado. **Próximo passo:** integrar ao Spalla para criar tarefas automaticamente para consultores e mentorados.

| Workflow | Status | Função |
|----------|--------|--------|
| ORQUESTRADOR v5 Plano de Ação | ✅ | Orquestrador principal — dispara no pós-call (Queila ou consultores) |
| Plano de Ação → Google Docs | ✅ | Exporta para Google Docs |
| SUB: Gerar RAG Embeddings | ✅ | Embeddings do plano |
| SUB: Validação Priorização | ✅ | Valida e prioriza tarefas |

---

#### 4.1.14 Cluster 13 — CASE Analytics (Monitoramento)

| Workflow | Status | Função |
|----------|--------|--------|
| CASE Analisador WhatsApp Semanal | ✅ | Análise semanal de WA |
| CASE Processador Calls Zoom | ✅ | Processa calls do Zoom |
| CASE Consolidador Semanal Mentorados | ✅ | Consolidado semanal |
| AI Hub Critical Error Monitor | ✅ | Monitor de erros críticos |
| AI Hub (Webhook Log / Aggregator Sync / Cost Processing / Daily Report / WA Alerts) | ✅ | Infraestrutura AI Hub |
| AGENTES 1, 2, 3 (Visual/Copy/Estrategista) | ✅ | Análise de anúncios |
| Análise Formato Hub Case v3 | ✅ | Análise de formato |

---

#### 4.1.15 Cluster 14 — Pablo (Análise de Calls de Vendas)

| Workflow | Status | Função |
|----------|--------|--------|
| Pablo Call Vendas V2 | ✅ | Análise principal de calls |
| Pablo Gestor Conhecimento | ✅ | Base de conhecimento |
| Pablo Ferramenta Metodologia | ✅ | Metodologia de análise |
| Pablo Muda Estado | ✅ | Controle de estado |

---

#### 4.1.16 Cluster 15 — RAG & Vetorização

| Workflow | Status | Função |
|----------|--------|--------|
| RAG Tool Busca Contexto Calls | ✅ | Busca vetorial em calls |
| Tool Busca Vetorial | ✅ | Ferramenta de busca |
| SUB Limpeza Chunking | ✅ | Limpeza e chunking |
| RAG Processar Transcripts de Calls | ⊘ | Processamento — inativo |
| RAG Backfill Todas as Calls | ⊘ | Backfill histórico — inativo |

---

#### 4.1.17 Outros Sistemas Ativos

| Workflow | Status | Função |
|----------|--------|--------|
| Agente Produto Lovable (6 agentes) | 🔄 Refaturar | Mapa, Pesquisa, Vitrine, Método, Oferta, Revisor — criados para outro produto, precisam refatoração |
| Monitor Facebook Ads | ✅ | Monitoramento de anúncios |
| Zoom Recording YouTube | ✅ | Upload automático Zoom→YouTube |
| Zoom transcrição Queila | ✅ | Transcrição Queila |
| Executor de Lembretes - Memory Keyla | ✅ | Lembretes automáticos |
| Agentes Mentoria Agente Entrega | ✅ | Entrega de materiais |
| WorkFlow Incompletos Aplicações Case | ✅ | Monitor de incompletos |
| Aplicações Case Forms | ✅ | Forms de aplicação |
| Listar Workflows Publicados | ✅ | Inventário N8N |
| Fluxo de Agendamento Reuniões | ✅ | Agendamento via WA |
| RPD / SPG / CPLD | ✅ | Siglas a confirmar com Kaique |
| Adaptação de Roteiro para Formato | ✅ | Adapta roteiros |
| Agentes Mentoria Ferramenta Entrega | ✅ | Entrega funis |
| GPTs Entrega detalhada funis | ✅ | Detalhamento de funis |
| My workflow 2 / 4 / 8 / 10 | ✅ | A identificar com Kaique |

---

#### 4.1.18 Legado / Descontinuado (referência)

> ~660 workflows inativos ⊘. Principais grupos:
> - **My workflow 11-52**: protótipos e testes sem nome
> - **Versões anteriores de todos os sistemas**: V1-V7 de dossiê, V1-V4 de download, V1-V3 de stories, versões antigas de lapidação, linha editorial, onboarding
> - **E-commerce / Airtable**: agentes de atendimento ecomm, sessões super-agentes Airtable — projeto externo encerrado
> - **Blacksheep/ADTK**: compras, cadastro, pesquisa — projeto encerrado
> - **DataCrazy CRM V1**: encerrado
> - **Fluxos FN (I/II/III)**: projeto encerrado
> - **Bee Automatica / Hub Bee Libre**: projeto encerrado
> - **Clone Voz Criativo, GB Flow, Gamma PDF**: experimentos inativos

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
| **AGEN-21** | Agente de Anúncios (Gerador + Analisador) | DETALHAR | Já existe estrutura base. Precisa aprofundar: system prompts, critérios de geração e análise. Depois: teste interno → liberação para mentorados. |
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
| **N8N** | Automações e agentes de IA | ✅ Ativo (~200 ativos CASE / 897 total instância — 22 clusters mapeados em Mar/2026) |
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

**Pendências:** Integração com Spalla Dashboard | Mapeamento completo de funis no Gobbi.

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

**Próximos passos Gobbi:** Kaique mostra o interior → documentar páginas, templates, status de uso por mentorado.

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

**Próximos passos Gobbi:** Kaique mostra o interior → documentar templates, artefatos criados, status de uso.

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

> Os itens abaixo requerem que Kaique mostre o interior de cada plataforma para completar o Gobbi.

| # | Plataforma | O que falta auditar |
|---|-----------|---------------------|
| 1 | **Hub CASE AI** | Lista completa dos 21 agentes por nome + qual mentorado usa qual |
| 2 | **Social CASE** | Lista dos 13 mentorados sem atividade + causa (abandonaram? não onboardados?) |
| 3 | **FunnelCase** | Todos os 16 funis do projeto Deisy + outros projetos existentes |
| 4 | **PageOS** | Páginas criadas + templates disponíveis + quem usa |
| 5 | **Carousel AI** | Carrosséis criados + templates + quem usa |
| 6 | **N8N** | RPD, SPG, CPLD — siglas a confirmar com Kaique; "My workflow X" ativos (2/4/8/10) a identificar |
| 7 | **N8N** | ~36 workflows relacionados: Kaique explica propósito de cada cluster |
| 8 | **Cortex** | Investigar erro `Analisador WhatsApp Semanal` → tabela `analises_whatsapp` |

---

## Anexo A — Glossário

| Termo | Significado |
|-------|------------|
| **Gobbi** | Governança do Negócio — instância de decisão estratégica |
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
*Auditoria N8N realizada via extração DOM Puppeteer em Mar/2026 (897 workflows totais, 18 páginas × 50, ~240 ativos, 26 clusters identificados — ver seção 4.1).*
*Próxima revisão: iterações com Kaique para cobrir seção 8.4 (auditoria interior das plataformas).*
