---
title: CASE — Report de Status Geral para GOB
type: governance-report
status: current
date: 2026-03-22
author: Kaique Rodrigues
---

# CASE Scale — Status Report GOB
**Data de referência:** 22 de março de 2026
**Destinatário:** GOB (Governança do Negócio)
**Escopo:** Software, ferramentas, agentes de IA, processos e próximos passos

---

## Índice

1. [Visão Executiva](#1-visão-executiva)
2. [GitHub — Repositórios e Status](#2-github--repositórios-e-status)
3. [Spalla Dashboard — O Hub Central](#3-spalla-dashboard--o-hub-central)
4. [ClickUp — Gestão Operacional](#4-clickup--gestão-operacional)
5. [Agentes de IA — N8N + Bill Case](#5-agentes-de-ia--n8n--bill-case)
6. [Ferramentas e SaaS](#6-ferramentas-e-saas)
7. [Backlog Estratégico Consolidado](#7-backlog-estratégico-consolidado)

---

## 1. Visão Executiva

A CASE Scale opera hoje com um stack proprietário em construção ativa. O ativo central é o **Spalla Dashboard** — plataforma web de gestão dos mentorados que concentra jornadas, tarefas, WhatsApp, dossiês, financeiro, agenda e controle operacional.

O estágio atual é **MVP funcional em uso parcial pela equipe**. As bases estão construídas; o próximo ciclo é transformar funcionalidades existentes em processos adotados, e completar as integrações críticas (WhatsApp nativo, ClickUp custom fields, Google Calendar).

```
Status geral: 🟡 Em construção — funcional mas com gaps críticos de adoção e integração
```

---

## 2. GitHub — Repositórios e Status

### Repositório Principal

| Repo | URL | Status | Deploy |
|------|-----|--------|--------|
| **spalla-dashboard** | github.com/case-company/spalla-dashboard | ✅ Ativo | Vercel (auto-deploy em `main`) + Railway (backend Python) |

### Worktrees Ativos (branches em desenvolvimento)

Os worktrees abaixo representam features em progresso ou concluídas aguardando merge:

| Worktree | Escopo | Situação |
|----------|--------|----------|
| `wt-carteira-owner` | Carteira de mentorados por consultor | ✅ Merged |
| `wt-cfo-payments` | View financeiro CFO | ✅ Merged |
| `wt-dossie-pipeline` | Pipeline de dossiês no Spalla | ✅ Merged |
| `wt-evolution-msg-sync` | Sincronização de mensagens Evolution | 🔄 Em desenvolvimento |
| `wt-google-calendar-integration` | Agenda Google Calendar | 🔄 Com problemas |
| `wt-wa-topics` | Tópicos de WhatsApp por mentorado | 🔄 Inativo |
| `wt-wa-bulk-ops` | Operações em massa no WhatsApp | 🔄 Em desenvolvimento |
| `wt-wa-inbox-ui` | UI de inbox WhatsApp | 🔄 Em desenvolvimento |
| `wt-wa-notes-api` | API de notas estruturadas WA | ✅ Merged |
| `wt-notifications` | Sistema de notificações in-app | 🔄 Em desenvolvimento |
| `wt-recurring-tasks` | Tarefas recorrentes | 🔄 Pendente |
| `wt-production-ready` | Hardening de produção | ✅ Merged |

### O que precisa subir para o GitHub (ainda não está lá)

- [ ] Documentação dos fluxos N8N (JSONs dos agentes)
- [ ] Prompts e system messages dos agentes de IA
- [ ] Especificações do Funnel Case (atualmente só no Vercel)
- [ ] Scripts de automação do ClickUp
- [ ] Mapa de arquitetura do stack completo

---

## 3. Spalla Dashboard — O Hub Central

**Stack:** Python 3.9 (backend Railway) + HTML/Alpine.js (frontend Vercel)
**URL produção:** spalla-dashboard.vercel.app
**Banco de dados:** Supabase (PostgreSQL + RLS)
**Integrações:** ClickUp API, Evolution API (WhatsApp), Google Sheets, Supabase Storage

### 3.1 Mapa de Páginas — O que Existe

O Spalla hoje tem **17 módulos/páginas** funcionais:

```
sidebar
├── Command Center      ← visão holística para gestão
├── Dashboard           ← painel Linear/Notion dos mentorados
├── Detalhe Mentorado   ← ficha completa por mentorado
├── Kanban              ← board por fase da jornada
├── Tarefas             ← gestão de tasks (integrado ClickUp)
├── Agenda              ← calls e eventos (Zoom + Google Calendar)
├── WhatsApp            ← inbox e conversas (Evolution API)
├── WA Tópicos          ← board de tópicos por mentorado
├── Lembretes           ← sistema de alertas internos
├── Dossiês             ← produção e acompanhamento
├── Planos de Ação      ← sentinela pós-dossiê
├── Onboarding CS       ← checklists e templates de entrada
├── Arquivos            ← storage + busca semântica
├── Docs                ← documentação interna
├── Equipe              ← visão do time e alocação
├── Financeiro          ← view CFO de pagamentos
└── Configurações       ← admin e permissões
```

### 3.2 Status por Módulo

#### ✅ Funcionando bem

| Módulo | O que funciona | Observações |
|--------|----------------|-------------|
| **Dashboard (mentorados)** | Lista completa, filtros, status, fases, SLA de resposta, carteira por consultor | Base sólida |
| **Detalhe do Mentorado** | Ficha completa, jornada, histórico, documentos, WhatsApp | Mais completo do sistema |
| **WhatsApp — Inbox** | Ver mensagens, identificar sem resposta, tempo sem resposta, mensagens pendentes | Proxy via Evolution — não é nativo |
| **Carteira (WA Management)** | Visão de grupos por consultor, mensagens sem resposta, SLA | Board funcional |
| **Financeiro (CFO)** | Visão de pagamentos, status, alertas | Não tem banco de dados próprio ainda |
| **Onboarding CS** | Templates de tarefas por etapa, checklists | Existe mas pouco utilizado pelo time |
| **Dossiês** | Produção, acompanhamento por mentorado, status | Funciona bem, falta acesso integrado |
| **Lembretes** | Criar e visualizar lembretes | Bug: podem aparecer para outros usuários |
| **Agenda (Zoom)** | Integração Zoom funcionando | Google Calendar com problemas |
| **Command Center** | Projetos ativos, sprint, time, atividade recente (ClickUp live) | Em finalização |
| **Tarefas (ClickUp)** | Kanban de tasks, filtros por status/responsável | Falta custom fields |

#### 🔄 Parcialmente funcionando / Precisa atenção

| Módulo | Problema | Prioridade |
|--------|----------|-----------|
| **Agenda (Google Calendar)** | Integração com problemas — Zoom funciona, GCal não | Alta |
| **WhatsApp — Proxy** | Usar Evolution como proxy não é prático; falta gerenciar conversas de forma fluida | Alta |
| **WA Tópicos** | Existe no sistema mas está inativo | Média |
| **Kanban por Fase** | Kanban existe mas falta detalhamento por etapa (quem fez call com Queila, onboarding, etc.) | Alta |
| **Planos de Ação** | Coleta do dossiê funciona mas não está consolidando corretamente | Alta |
| **Arquivos / Docs** | Existe storage mas não conectado ao Google Drive Pro da empresa | Média |
| **Equipe** | Views existem mas são pouco úteis na prática | Média |
| **Jornadas dos Mentorados** | Estrutura existe mas fluxo não está lógico o suficiente | Alta |

#### ❌ Faltando / Não implementado

| Feature | Descrição | Impacto |
|---------|-----------|---------|
| **WhatsApp nativo** | Coleta de dados via WA, cadastrar mentorado pelo WA, mandar tarefas via WA | Alto |
| **Evolution API — documentação** | Precisar aprofundar integração para tornar utilizável | Alto |
| **ClickUp Custom Fields no Spalla** | Trazer campos personalizados do ClickUp para o sistema de gestão | Alto |
| **Kanban por etapa/fase** | Quem passou pela call de Queila, quem fez onboarding, check de call por fase | Alto |
| **Google Drive vinculado** | Trazer arquivos do Pro Drive como se fosse Google Docs dentro do Spalla | Médio |
| **Financeiro → banco de dados** | Registros persistentes de pagamento em Supabase | Médio |
| **Lembretes — bug de login** | Lembretes compartilhados entre usuários, deveria ser por usuário | Médio |
| **Dossiês — acesso Google Docs** | Conectar acesso aos arquivos reais do dossiê | Médio |
| **Planos de Ação — atualização pós-dossiê** | Consultores atualizarem o plano após entrega, ou reset para começar do zero | Médio |
| **WhatsApp Bulk Ops** | Operações em massa (mensagem para vários mentorados) | Médio |
| **Listas melhoradas** | Operacional, conteúdo, vendas, playbooks, dossiês com mais estrutura | Médio |
| **Notificações in-app** | Sistema de alertas internos (em desenvolvimento) | Baixo |
| **Tarefas recorrentes** | Tasks que se repetem automaticamente | Baixo |

### 3.3 O que o time ainda não usa (adoção pendente)

O sistema tem funcionalidades que existem mas não viraram hábito da equipe:

- **Onboarding CS** — templates prontos, ninguém usa
- **Planos de Ação** — coleta existe, não é consultado
- **Tarefas no Spalla** — time ainda opera mais no ClickUp direto
- **Equipe / Views de alocação** — existem mas não são úteis o suficiente
- **Lembretes** — usados raramente

### 3.4 Próximos Passos Técnicos (priorizado)

```
P1 — Alta prioridade (impacto direto na operação)
  1. WhatsApp: aprofundar Evolution API para gerenciar conversas de forma utilizável
  2. Kanban por fase/etapa com checklist de calls (Queila, onboarding, etc.)
  3. Google Calendar: resolver integração
  4. ClickUp Custom Fields: trazer para o Spalla

P2 — Média prioridade
  5. Dossiês: conectar acesso Google Docs
  6. Planos de Ação: fluxo de atualização pós-dossiê
  7. Financeiro: persistência em Supabase
  8. Lembretes: isolar por usuário logado

P3 — Próximo ciclo
  9. WhatsApp nativo: coletas, cadastro e tarefas via WA
  10. Funnel Case integrado ao Spalla
  11. Playbooks dentro do Spalla
  12. Notificações in-app
```

---

## 4. ClickUp — Gestão Operacional

**Workspace:** All In Marketing (ID: 9011530618)
**Space:** Case Scale (ID: 90114112693)

### 4.1 Estrutura de Sprints Atual

| Sprint | Período | Status | Total de Tasks |
|--------|---------|--------|---------------|
| Sprint 1 | 16–22 Mar 2026 | ✅ Ativo | ~7 (internas) + 225 (backlog) |
| Sprint 2 | 23–29 Mar 2026 | Planejado | ~225 |
| Sprint 3 | 30 Mar–5 Abr 2026 | Planejado | ~230 |

### 4.2 Status do Workflow com IA

```
Workflow CASE com IA no ClickUp:
✅ Quase fechado — falta Gobe fechar alguns detalhes
✅ APIs subidas e disponíveis para Gobe manusear
❌ Pipeline de dossiê: precisa ser testado em tempo real
❌ Playbook de Call de Download: em finalização
❌ Mapa do Expert: pendente
```

### 4.3 Listas Principais e Status

| Lista | Finalidade | Status |
|-------|-----------|--------|
| Operacional | Tasks do dia a dia da equipe | Existe, precisa melhorar estrutura |
| Conteúdo | Produção de conteúdo (Queila e time) | Existe, precisa melhorar |
| Vendas | Pipeline e oportunidades | Existe |
| Playbooks | Processos documentados | Em construção |
| Dossiês | Tracking de produção | Em uso ativo |

### 4.4 Integrações ClickUp ↔ Spalla

- ✅ Tasks visíveis no Spalla (via API v2)
- ✅ Activity feed do Command Center vem do ClickUp
- ✅ Sprint progress sincronizado em tempo real
- ❌ Custom Fields do ClickUp não espelhados no Spalla
- ❌ Criar/atualizar tasks do Spalla para o ClickUp (só leitura hoje)

---

## 5. Agentes de IA — N8N + Bill Case

**Plataforma:** N8N (self-hosted ou cloud)
**Documentação:** Bill Case (Drive com agentes, fluxos e system messages)

### 5.1 Mapa de Agentes

| Agente | Função | Status |
|--------|--------|--------|
| **WhatsApp** | Resposta automática e triagem de mensagens | ✅ Funcionando |
| **Transcrição de Reels** | Converte vídeos em texto | ✅ Funcionando |
| **Análise de Formato** | Analisa formato de conteúdo do mentorado | ✅ Funcionando |
| **Stories** | Cria roteiros de stories para mentorados | 🔄 Precisa revisão de prompts e testes |
| **Fluxo de Entrada do Mentorado** | Automação de onboarding via WA | ✅ Funcionando |
| **Lapidação de Perfil** | Análise e refinamento do perfil do mentorado | ❌ Não integrado ainda |
| **Download do Expert** | Extração de conhecimento do mentorado (vai virar call estruturada) | 🔄 Em transição para call presencial + agente de processamento |
| **Concepção de Dossiê** | Agente principal de geração do dossiê | ❌ Saindo do N8N — prompts baixados, em implementação |
| **Roteiros** | Roteiros de aula e conteúdo | ✅ Funcionando (contexto Queila Brain) |
| **Arquitetura de Produto** | Análise de produto do mentorado | ✅ Disponível |
| **Análise de Formato** | Diagnóstico de formato de conteúdo | ✅ Disponível |
| **System Messages** | Repositório de prompts | 🔄 Pouco utilizado, existe mas sem uso ativo |

### 5.2 Repositório de Artefatos (Bill Case)

```
Bill Case / N8N Documentação:
├── Análise de formato       → JSON exportado ✅
├── Arquitetura de produto   → JSON exportado ✅
├── Download de expert       → JSON exportado ✅
├── Lapidação de perfil      → JSON exportado ✅
├── Onboarding               → JSON exportado ✅
├── Roteiros                 → JSON exportado ✅
├── Stories                  → JSON exportado (precisa revisão) 🔄
├── Transcrição              → JSON exportado ✅
├── WhatsApp                 → JSON exportado ✅
└── System Messages          → Mapeado, pouco utilizado 🔄
```

**Links para download dos JSONs:** disponíveis na documentação da Bill Case.

### 5.3 Próximos Passos — Agentes

```
P1 — Download do Expert: transformar em call estruturada (agente só processa output)
P2 — Concepção de Dossiê: finalizar saída do N8N, testar pipeline completo
P3 — Stories: revisar prompts e testar com mentorados reais
P4 — Lapidação de Perfil: integrar no fluxo de entrada do mentorado
P5 — Subir JSONs dos agentes para o GitHub (versionamento e backup)
```

---

## 6. Ferramentas e SaaS

### 6.1 Stack Técnico Atual

| Ferramenta | Uso | Status |
|-----------|-----|--------|
| **Vercel** | Deploy do Spalla (frontend) | ✅ Ativo — auto-deploy em `main` |
| **Railway** | Backend Python do Spalla | ✅ Ativo |
| **Supabase** | Banco de dados PostgreSQL + Auth + Storage | ✅ Ativo |
| **ClickUp** | Gestão de tarefas e sprints | ✅ Em uso ativo |
| **GitHub** | Versionamento de código | ✅ Ativo |
| **Evolution API** | Integração WhatsApp (proxy) | 🔄 Funcional, mas limitado |
| **N8N** | Automações e agentes de IA | ✅ Ativo |
| **Google Workspace** | Drive, Docs, Calendar | 🔄 Parcialmente integrado |
| **Zoom** | Calls e sessões | ✅ Integrado no Spalla |
| **Claude API** | IA dos agentes e análises | ✅ Em uso nos agentes |

### 6.2 Ferramentas Proprietárias (CASE)

| Ferramenta | Descrição | Status |
|-----------|-----------|--------|
| **Spalla Dashboard** | Hub central de gestão | ✅ Em produção |
| **Hub CASE AI** | Central de agentes de IA (hub.caseai.com.br) | ✅ Ao vivo |
| **Social CASE** | Calendário editorial + métricas (social.caseai.com.br) | 🔄 Beta |
| **Funnel CASE** | Visualização de funis (funnelcase.vercel.app) | 🔄 Beta → futuro: integrar no Spalla |
| **PageOS** | Criação de páginas de captura (page-os-eta.vercel.app) | 🔄 Beta |
| **Carousel AI** | Produção de carrosséis com IA | 🔄 Beta |

### 6.3 Modelo de Apresentação / Dossiê

```
Novo modelo de apresentação: em desdobramento no Funnel OS
Falta: gravar vídeos demonstrativos
Status: 🔄 Em produção
```

---

## 7. Backlog Estratégico Consolidado

### Prioridade 1 — Impacto imediato na operação

| # | Item | Área | Responsável |
|---|------|------|-------------|
| 1 | WhatsApp Evolution: aprofundar integração para gestão real de conversas | Spalla | Dev |
| 2 | Kanban por etapa/fase com checklist de calls (Queila, onboarding) | Spalla | Dev |
| 3 | Google Calendar: resolver integração de agendamento | Spalla | Dev |
| 4 | ClickUp Custom Fields no Spalla | Spalla + ClickUp | Dev |
| 5 | Pipeline de dossiê: teste em tempo real | N8N + ClickUp | Gobe + Dev |

### Prioridade 2 — Qualidade e consolidação

| # | Item | Área | Responsável |
|---|------|------|-------------|
| 6 | Playbook de Call de Download: finalizar | ClickUp | Gobe |
| 7 | Mapa do Expert: finalizar | ClickUp | Gobe |
| 8 | Dossiês: conectar acesso Google Docs | Spalla | Dev |
| 9 | Planos de Ação: fluxo de atualização pós-dossiê | Spalla | Dev |
| 10 | Financeiro: persistência em Supabase | Spalla | Dev |
| 11 | Lembretes: isolar por usuário logado | Spalla | Dev |
| 12 | Stories (N8N): revisar prompts e testar | N8N | Gobe + Dev |
| 13 | Lapidação de Perfil: integrar no fluxo de entrada | N8N | Dev |

### Prioridade 3 — Próximo ciclo

| # | Item | Área | Responsável |
|---|------|------|-------------|
| 14 | WhatsApp nativo: coletas, cadastro e tarefas via WA | Spalla | Dev |
| 15 | Funnel Case integrado ao Spalla | Spalla | Dev |
| 16 | Playbooks dentro do Spalla | Spalla | Dev |
| 17 | Concepção de Dossiê: finalizar saída do N8N | N8N | Dev |
| 18 | JSONs dos agentes no GitHub (versionamento) | GitHub | Dev |
| 19 | Modelo de apresentação + vídeos demonstrativos | Produto | Kaique |
| 20 | Google Drive Pro vinculado ao Spalla | Spalla | Dev |

---

## Anexo — Glossário Rápido

| Termo | Significado |
|-------|------------|
| **GOB** | Governança do Negócio — reunião/instância de decisão estratégica |
| **Gobe** | Responsável por fechar workflows no ClickUp e N8N |
| **Bill Case** | Drive com documentação técnica dos agentes de IA |
| **Spalla** | Software de gestão dos mentorados (hub central) |
| **Evolution API** | API de integração com WhatsApp (proxy) |
| **Funnel OS** | Sistema de apresentação de funis para mentorados |
| **Download do Expert** | Processo de extração de conhecimento e perfil do mentorado |
| **Lapidação de Perfil** | Refinamento do perfil estratégico do mentorado pós-download |

---

*Report gerado em 22/03/2026 — baseado em levantamento direto com Kaique Rodrigues.*
*Próxima revisão recomendada: início do Sprint 2 (23/03/2026).*
