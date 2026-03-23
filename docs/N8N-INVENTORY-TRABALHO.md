---
title: N8N — Inventário de Trabalho (Anotação Kaique)
type: working-document
status: draft
created: 2026-03-22
---

# N8N — Inventário de Trabalho

> **Use este arquivo para anotar o status real de cada workflow.**
> Coluna **"Kaique — Status"**: escreva o que é, se está em uso, se é de cliente, se pode arquivar, etc.
> Auditado via DOM Puppeteer Mar/2026. Total instância: 897 workflows (18 páginas).

---

## Como usar

Na coluna **Kaique — Status** escreva:
- `✅ CASE core` — sistema interno CASE em uso
- `👤 Cliente: [nome]` — projeto de cliente externo
- `🗑️ Arquivar` — pode deletar do N8N
- `🔄 Refatorar` — existe mas precisa de trabalho
- `❓ O que é isso?` — não sabe / precisa investigar
- `⏸️ Stand-by` — inativo mas guardar

---

## PÁGINA 1

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| Monitor Facebook Ads | ✅ | Ads / Tráfego | |
| Zap dos Tópicos | ✅ | WhatsApp System | |
| WA 02 v2 AI Topic Classifier | ✅ | WhatsApp System | |
| Alertas Mensagens Pendentes | ✅ | WhatsApp System | |
| Alerta Menção no Grupo | ✅ | WhatsApp System | |
| Sistema Gestão WA Scraper v34 | ✅ | WhatsApp System | |
| WA 03 v2 Topic Maintenance | ✅ | WhatsApp System | |
| WA 05 Recovery & Dead Letter | ✅ | WhatsApp System | |
| WorkFlow SDR Case | ✅ | Onboarding | |
| DS Stage Notification | ✅ | Onboarding | |
| WA 02 AI Topic Classifier | ✅ | WhatsApp System (versão antiga?) | |
| Alerta Mensagens Não Respondidas | ✅ | WhatsApp System | |
| 02_Agente_Extrator_Contexto | ✅ | Arquitetura de Produto | |
| 04_Agente_Mapeador_Jornada | ✅ | Arquitetura de Produto | |
| Arquitetura Produto - Extrator Metodo | ✅ | Arquitetura de Produto | |
| Arquitetura Produto - Construtor Aulas | ✅ | Arquitetura de Produto | |
| Arquitetura Produto - Construtor Materiais | ✅ | Arquitetura de Produto | |
| Arquitetura Produto - Revisor | ✅ | Arquitetura de Produto | |
| Arquitetura Produto - Construtor Pilar | ✅ | Arquitetura de Produto | |
| Novo Mentorado | ✅ | Onboarding | |
| Conta Simples | ✅ | Financeiro | |
| Follow-Up Menções Queila | ✅ | WhatsApp System | |
| Listar Workflows Publicados | ✅ | Admin/Utilitário | |
| WhatsApp Mention Alerts Spalla | ✅ | WhatsApp System | |
| SUB: Gerar RAG Embeddings | ✅ | Plano de Ação / RAG | |
| SUB: Validação Priorização | ✅ | Plano de Ação | |
| Zoom transcrição Queila | ✅ | Zoom / Transcrição | |
| Alertas WhatsApp Mensagens Pendentes 2h | ✅ | WhatsApp System | |
| senha | ✅ | ❓ | |
| DE V10 Sessao 1 | ✅ | Download Expert V10 | |
| DE V10 Sessao 2 | ✅ | Download Expert V10 | |
| DE V10 Sessao 3 | ✅ | Download Expert V10 | |
| Download Expert V10 FluxoGeral | ✅ | Download Expert V10 | |
| Download Expert V10 Agente Cadastro | ✅ | Download Expert V10 | |
| Download Expert V10 Tools | ✅ | Download Expert V10 | |
| Download Expert V10 SubWF | ✅ | Download Expert V10 | |
| Plano de Ação → Google Docs | ✅ | Plano de Ação | |
| ORQUESTRADOR v5 Plano de Ação | ✅ | Plano de Ação | |
| SESSAO1_V10 (cópia) | ⊘ | Download Expert — legado | |
| SESSAO2_V10 (cópia) | ⊘ | Download Expert — legado | |
| SESSAO3_V10 (cópia) | ⊘ | Download Expert — legado | |
| SubWF_Sessao1 V10 | ⊘ | Download Expert — legado | |
| SubWF_Sessao2 V10 | ⊘ | Download Expert — legado | |
| SubWF_Sessao3 V10 | ⊘ | Download Expert — legado | |
| WhatsApp Response Analyzer Spalla | ✅ | WhatsApp System | |

---

## PÁGINA 2

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| Zoom Recording YouTube | ✅ | Zoom / Transcrição | |
| Download Expert V10 (cópias adicionais) | ⊘ | Download Expert — legado | |
| SUB_WF_01_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_02_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_03_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_04_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_05_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_06_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_07_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_08_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_09_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_10_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_11_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_12_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_13_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_14_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_15_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_16_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_17_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_18_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_19_V11 | ⊘ | Dossiê V11 sub-agente | |
| SUB_WF_20_V11 | ⊘ | Dossiê V11 sub-agente | |
| Turbinar Resumo Diário | ✅ | Analytics / Relatório | |
| Turbinar Campanhas | ✅ | Analytics / Relatório | |
| Teste formatar dossiê | ⊘ | Dev/Teste | |
| MAIN_WF_MASTER_V11 | ⊘ | Dossiê V11 — substituído por V8 | |
| Download Expert V3 Fluxo Geral | ⊘ | Download Expert — legado | |
| Download Expert V5 E1 | ⊘ | Download Expert — legado | |
| Download Expert V5 E2 | ⊘ | Download Expert — legado | |
| Download Expert V5 E3 | ⊘ | Download Expert — legado | |
| Download Expert V5 E4 | ⊘ | Download Expert — legado | |
| Download Expert V5 E5 | ⊘ | Download Expert — legado | |
| Download Expert V5 E6 | ⊘ | Download Expert — legado | |
| Download Expert V5 E7 | ⊘ | Download Expert — legado | |
| Download Expert V5 E8 | ⊘ | Download Expert — legado | |
| Download Expert V5 E9 | ⊘ | Download Expert — legado | |
| Download Expert V5 E10 | ⊘ | Download Expert — legado | |
| Download Expert V5 E11 | ⊘ | Download Expert — legado | |
| Download Expert V5 E12 | ⊘ | Download Expert — legado | |
| Download Expert V5 E13 | ⊘ | Download Expert — legado | |
| Scraper IG Alunos Fluxo 3 | ✅ | Instagram Scraper | |
| SUB: Pipeline Individual Completo | ✅ | Dossiê / Pipeline | |

---

## PÁGINA 3

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| Agentes Mentoria Tool Muda Estado | ✅ | Agentes Mentoria — tool | |
| WF_MONTAGEM_FINAL_V11 | ✅ | Dossiê V11 | |
| SUB_WF_COERENCIA V11 | ✅ | Dossiê V11 | |
| SUB_WF_TANGIBILIZACAO V11 | ✅ | Dossiê V11 | |
| WF_EDITOR_PRINCIPAL_V11 | ✅ | Dossiê V11 | |
| SUB_WF_EDITOR_* V11 (série) | ✅ | Dossiê V11 | |
| WF_ID_* (série — todos ⊘) | ⊘ | Dossiê — registro obsoleto | |
| Turbinar Posts | ✅ | Conteúdo | |
| Stories V8 Validador | ✅ | Stories System | |
| Stories V8 Estrategista | ✅ | Stories System | |
| Stories V8 Escritor | ✅ | Stories System | |
| Stories V7 State Manager | ⊘ | Stories — legado V7 | |
| Stories V7 Coletor | ⊘ | Stories — legado V7 | |
| Stories V7 Orquestrador | ⊘ | Stories — legado V7 | |
| Stories Fluxo Geral | ✅ | Stories System | |
| Stories Agent Tools | ✅ | Stories System | |

---

## PÁGINA 4

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| Stories Agente Ideias | ✅ | Stories System | |
| Stories Agente Roteirista | ✅ | Stories System | |
| SUB FASE 0.5 | ✅ | Dossiê / Pipeline | |
| CASE Analisador WA Semanal | ✅ | CASE Analytics | |
| CASE Processador Calls Zoom | ✅ | CASE Analytics | |
| CASE Consolidador Semanal Mentorados | ✅ | CASE Analytics | |
| My workflow 52 | ⊘ | ❓ | |
| QCES Auto Sync | ✅ | QCES | |
| QCES Content Extraction v4 | ✅ | QCES | |
| QCES Parse WebVTT | ✅ | QCES | |
| QCES Extract Beliefs | ✅ | QCES | |
| QCES Format & Positioning | ✅ | QCES | |
| QCES Generate Hooks/Briefing | ✅ | QCES | |
| Naming Agent + INPI | ✅ | Naming Agent | |
| Naming sub-agentes (série) | ✅/⊘ | Naming Agent | |
| Agentes Mentoria V3 | ✅ | Agentes Mentoria | |
| Download Expert V3 Tools | ⊘ | Download Expert — legado | |
| WF_ORCHESTRATOR V10 | ✅ | Download Expert V10 | |
| SUB_WF V10 (caps) | ⊘ | Download Expert — legado | |

---

## PÁGINA 5

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| SUB_WF V10 (caps continuação) | ⊘ | Download Expert — legado | |
| Agentes Mentoria Ideias v6 | ✅ | Agentes Mentoria | |
| Tool Busca Vetorial | ✅ | RAG / Vetorial | |
| Naming sub-agents (adicionais) | ✅/⊘ | Naming Agent | |
| AI Hub Critical Error Monitor | ✅ | AI Hub Monitor | |
| Scraper IG Carrossel | ✅ | Instagram Scraper | |
| Agentes Mentoria Ideias v17 | ✅ | Agentes Mentoria | |
| Relatório Diário | ⊘ | Analytics | |
| F - SFL | ⊘ | ❓ — confirmar com Kaique | |
| Patch Scraper | ⊘ | Dev/Utilitário | |
| QCES Zoom Scraper | ✅ | QCES | |
| Agente Mensagens Utilidade | ✅ | WhatsApp System? | |
| Clint Deal Stage | ✅ | CRM / Financeiro | |
| RETROATIVO v5 | ⊘ | ❓ | |
| Importar Cobranças | ⊘ | Financeiro | |
| Sistema Cobranças WA ManyChat | ⊘ | Financeiro | |
| SUB Match Google Calendar | ✅ | Agendamento | |
| Linha Editorial Roteiros v6 | ⊘ | Linha Editorial — legado | |
| Linha Editorial Roteiros v7 | ✅ | Linha Editorial | |
| Agentes Mentoria v7-v17 (série) | ✅/⊘ | Agentes Mentoria | |
| Lapidacao V4 | ✅ | Lapidação | |
| Análise Formato Hub Case v3 | ✅ | Analytics / Hub | |
| Hubla→Supabase | ✅ | Financeiro / Integração | |
| Lapidacao agentes (série) | ✅/⊘ | Lapidação | |

---

## PÁGINA 6

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| Lapidacao Consolidador | ✅ | Lapidação | |
| Lapidacao Agente Ideias v6 | ✅ | Lapidação | |
| Lapidacao Roteiros v14 | ✅ | Lapidação | |
| Lapidacao Tool Salva | ✅ | Lapidação | |
| Lapidacao Agente Bio/Nome | ✅ | Lapidação | |
| Lapidacao Storytelling | ✅ | Lapidação | |
| Lapidacao Status Polling | ✅ | Lapidação | |
| Lapidacao Agente Criacao Posts | ✅ | Lapidação | |
| Lapidacao Scraper Perfil | ✅ | Lapidação | |
| Lapidacao Calendario V2 | ✅ | Lapidação | |
| Lapidacao Foto Perfil | ✅ | Lapidação | |
| Lapidacao RAG Contexto | ✅ | Lapidação | |
| Lapidacao Tool Atualiza | ✅ | Lapidação | |
| Lapidacao Tool Busca | ✅ | Lapidação | |
| Agentes Mentoria v8 (série completa) | ✅/⊘ | Agentes Mentoria | |
| Agentes Mentoria V7 (série) | ⊘ | Agentes Mentoria — legado | |
| Agente Lapidacao UNIFICADO | ✅ | Lapidação | |
| F-pes / F-SHEET (variantes) | ⊘ | ❓ — confirmar com Kaique | |
| Download Expert V5 Aprendizados | ⊘ | Download Expert — legado | |
| Tool Redirecionar Ideias | ✅ | Agentes Mentoria — tool | |
| Tool Marcar Ideias | ✅ | Agentes Mentoria — tool | |
| Tool Consultar Ideias | ✅ | Agentes Mentoria — tool | |
| Tool Salvar items (série) | ✅ | Agentes Mentoria — tool | |

---

## PÁGINA 7

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| Tool Salvar Roteiro | ✅ | Linha Editorial — tool | |
| Tool Salvar Mentalidade | ✅ | Linha Editorial — tool | |
| Tool Salvar Metafora | ✅ | Linha Editorial — tool | |
| Tool Salvar Contraponto | ✅ | Linha Editorial — tool | |
| Tool Salvar Historia | ✅ | Linha Editorial — tool | |
| Tool Salvar Ideia | ✅ | Linha Editorial — tool | |
| Download Expert V5 (E1-E13 completo) | ⊘ | Download Expert — legado | |
| Download Expert V4 (E1-E13 completo) | ⊘ | Download Expert — legado | |
| Download Expert V3 (parcial) | ⊘ | Download Expert — legado | |
| TH Inativo Supabase | ⊘ | ❓ — TH = Thiago? | |
| Procura Produto Clint | ⊘ | CRM | |
| Agente Lapidacao UNIFICADO (cópia) | ✅ | Lapidação | |
| Agentes Mentoria V3 (cópias) | ⊘ | Agentes Mentoria — legado | |

---

## PÁGINA 8

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| Agentes Mentoria Cadastro V5 | ✅ | Agentes Mentoria | |
| Agentes Mentoria Campanha | ✅ | Agentes Mentoria | |
| Scraper IG Alunos Fluxo 2 | ✅ | Instagram Scraper | |
| Ideias v4 / v5 | ⊘ | Agentes Mentoria — legado | |
| Processar Top 75 Gisele | ⊘ | ❓ — Gisele = cliente? | |
| Agentes Mentoria (versões antigas) | ⊘ | Agentes Mentoria — legado | |
| Arquitetura Produto Orquestrador v2 | ✅ | Arquitetura de Produto | |
| Processar Fila Referencias DECDI | ✅ | QCES / Posicionamento | |
| Tool Muda Estado | ✅ | Agentes Mentoria — tool | |
| Zoom transcrição (cópia) | ✅ | Zoom / Transcrição | |
| Aplicações Case Forms | ✅ | Onboarding / Admin | |
| Linha Editorial Fluxo Geral v2 | ✅ | Linha Editorial | |
| Agente Lapidação Fase 1 V3 | ⊘ | Lapidação — legado | |
| Linha Editorial Gerador Ideias v6 | ✅ | Linha Editorial | |
| Linha Editorial Tools (série) | ✅ | Linha Editorial | |
| Conta Simples Relatório Semanal | ⊘ | Financeiro | |
| Linha Editorial coletores (série) | ✅/⊘ | Linha Editorial | |
| WF-BFCC | ⊘ | ❓ — confirmar com Kaique | |
| WF-BFFM1125 | ⊘ | ❓ — confirmar com Kaique | |
| SariDoctors Lead Score V4 | ✅ | 👤 Cliente externo | |
| Agentes Mentoria V1/V2 | ⊘ | Agentes Mentoria — legado | |
| Report Semanal Mentorias | ⊘ | Analytics | |

---

## PÁGINA 9

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| Notificador Tarefas | ✅ | Admin / Utilitário | |
| Processador Lembretes | ✅ | Admin / Utilitário | |
| Alerta Mentorados Sem Call 45 dias | ✅ | Fidelização / Retenção | |
| SariDoctors Lançamento Pago | ⊘ | 👤 Cliente externo | |
| Sendflow CD10X | ✅ | ❓ — confirmar | |
| WEBHOOK Aula em Grupo | ✅ | CASE Operacional | |
| Pablo Call Vendas V2 | ✅ | Pablo — análise calls | |
| Pablo Gestor Conhecimento | ✅ | Pablo | |
| Pablo Ferramenta Metodologia | ✅ | Pablo | |
| Pablo Muda Estado | ✅ | Pablo | |
| Instagram Scraper v20 | ✅ | Instagram Scraper | |
| Instagram Onboarding 10 | ✅ | Instagram Scraper | |
| Instagram Onboarding 10A | ✅ | Instagram Scraper | |
| Instagram Onboarding 10B | ✅ | Instagram Scraper | |
| Instagram Onboarding 11 Cache Thumbnails | ✅ | Instagram Scraper | |
| AI Hub Webhook Log | ✅ | AI Hub Monitor | |
| AI Hub Aggregator Sync | ✅ | AI Hub Monitor | |
| AI Hub Cost Processing | ✅ | AI Hub Monitor | |
| AI Hub Daily Report | ✅ | AI Hub Monitor | |
| AI Hub WA Alerts | ✅ | AI Hub Monitor | |
| Analisar Referencia Conteudo V6 | ✅ | Conteúdo / Instagram | |
| Agente AI Analise Conteudo v2 | ✅ | Conteúdo / Instagram | |
| Scraping Diario Posts/Seguidores | ✅ | Instagram Scraper | |
| Instagram Scraper Webhook Backend | ✅ | Instagram Scraper | |
| Scraper Foto Perfil | ✅ | Instagram Scraper | |
| Instagram Onboarding Inicial | ✅ | Instagram Scraper | |
| Linha Editorial Tools Destaques | ✅ | Linha Editorial | |
| Pablo (série adicional) | ✅/⊘ | Pablo | |
| SUB Limpeza Chunking | ✅ | RAG / Vetorial | |
| WF_ORCHESTRATOR V8 | ✅ | Dossiê — orquestrador | |
| WF_ORCHESTRATOR (versões antigas) | ⊘ | Dossiê — legado | |
| My workflow 44 | ⊘ | ❓ | |
| My workflow 45 | ⊘ | ❓ | |
| My workflow 46 | ⊘ | ❓ | |
| My workflow 47 | ⊘ | ❓ | |
| My workflow 48 | ⊘ | ❓ | |
| Fidelizacao Aniversariantes | ✅ | ❓ — CASE ou cliente? | |
| Fidelizacao Alta Finalização | ✅ | ❓ — CASE ou cliente? | |
| Funil captação webhook | ✅ | ❓ — confirmar | |
| FUNIL AGENTE REVISTA | ✅ | 👤 Cliente externo | |
| FUNIL AGENTE TELOES LED | ✅ | 👤 Cliente externo | |
| FUNIL AGENTE TV | ✅ | 👤 Cliente externo | |
| FUNIL AGENTE OUTDOOR | ✅ | 👤 Cliente externo | |

---

## PÁGINA 10

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| FUNIL AGENTE RADIO | ✅ | 👤 Cliente externo | |
| FUNIL AGENTE CONVERSÃO CONVENIO PARA PARTICULAR | ✅ | 👤 Cliente externo | |
| FUNIL Agente Seletor de Programas | ✅ | 👤 Cliente externo | |
| FUNIL AGENTE CASHBACK | ✅ | 👤 Cliente externo | |
| FUNIL AGENTE FALLOW-UP | ✅ | 👤 Cliente externo | |
| FUNIL AGENTE REAVALIAÇÕES (PACIENTES ATUAIS) | ✅ | 👤 Cliente externo | |
| FUNIL AGENTE REATIVAÇÃO DE PACIENTES ANTIGOS | ✅ | 👤 Cliente externo | |
| FUNIL AGENTE VOUCHER | ✅ | 👤 Cliente externo | |
| FUNIL AGENTE NETWORKING | ✅ | 👤 Cliente externo | |
| FUNIL AGENTE PALESTRAS/WORKSHOPS | ✅ | 👤 Cliente externo | |
| FUNIL AGENTE CAMPANHAS INTERNAS | ✅ | 👤 Cliente externo | |
| FUNIL AGENTE PARCERIAS | ✅ | 👤 Cliente externo | |
| WF_ORCHESTRATOR_CAPITULOS_V8_CORRIGIDO | ✅ | Dossiê V8 | |
| WF_00_MAIN_WEBHOOK_V8 | ✅ | Dossiê V8 | |
| PRE PROCESSADOR V5 | ✅ | Dossiê V8 | |
| SUB_WF_CAP_LAPIDACAO_V8_CORRIGIDO | ✅ | Dossiê V8 | |
| SUB_WF_CAP_PROXIMOS_PASSOS_V8_CORRIGIDO | ✅ | Dossiê V8 | |
| SUB_WF_CAP12_CONTEUDO_V8_CORRIGIDO | ✅ | Dossiê V8 | |
| SUB_WF_CAP10_STORYTELLING_V8_CORRIGIDO | ✅ | Dossiê V8 | |
| SUB_WF_CAP9B_EXECUCAO_V8_CORRIGIDO | ✅ | Dossiê V8 | |
| SUB_WF_CAP9A_FUNIL_V8_CORRIGIDO | ⊘ | Dossiê V8 | |
| SUB_WF_CAP8_ARQUITETURA_V8_CORRIGIDO | ⊘ | Dossiê V8 | |
| SUB_WF_CAP7_OFERTA_V8_CORRIGIDO | ⊘ | Dossiê V8 | |
| SUB_WF_CAP6_OBJECOES_V8_CORRIGIDO | ⊘ | Dossiê V8 | |
| SUB_WF_CAP4_TESE_V8_CORRIGIDO | ⊘ | Dossiê V8 | |
| SUB_WF_CAP3_MURO_V8_CORRIGIDO | ⊘ | Dossiê V8 | |
| SUB_WF_CAP2_PUBLICO_V8_CORRIGIDO | ⊘ | Dossiê V8 | |
| SUB_WF_CAP1_CONTEXTO_V8_CORRIGIDO | ✅ | Dossiê V8 | |
| RAG - Processar Transcripts de Calls | ⊘ | RAG | |
| RAG - Backfill Todas as Calls | ⊘ | RAG | |
| RAG - Tool Busca Contexto Calls | ✅ | RAG | |
| Fidelizacao Agente Gameficacao | ✅ | ❓ — CASE ou cliente? | |
| Fidelizacao Agente Prevencao | ✅ | ❓ — CASE ou cliente? | |
| Fidelizacao Agente Google Reviews | ✅ | ❓ — CASE ou cliente? | |
| Fidelizacao Agente Programa de Indicacao | ✅ | ❓ — CASE ou cliente? | |
| Fidelizacao Webhook Lovable (Frontend) | ✅ | ❓ — CASE ou cliente? | |
| Fidelizacao Agente Seletor de Programas | ✅ | ❓ — CASE ou cliente? | |
| Fidelizacao Fluxo Geral (Orquestrador) | ⊘ | ❓ — CASE ou cliente? | |
| Agente Lapidação WEBHOOK - V12 METODOLOGIA QUEILA | ✅ | Lapidação | |
| SUB_WF_AUDIO_TRANSCRIPTION_V7 | ✅ | Onboarding V7 | |
| SUB_WF_ONBOARDING_04_WHATSAPP_GROUP_V7 | ✅ | Onboarding V7 | |
| WF_ORQUESTRADOR_ONBOARDING_V7 | ✅ | Onboarding V7 | |
| SUB_WF_ONBOARDING_03_SUPABASE_INSERT_V7 | ⊘ | Onboarding V7 | |
| SUB_WF_ONBOARDING_05_VALIDACAO_V7 | ⊘ | Onboarding V7 | |
| SUB_WF_ONBOARDING_01_EXTRACAO_DADOS_V7 | ✅ | Onboarding V7 | |
| SUB_WF_ONBOARDING_02_MATCHING_V7 | ⊘ | Onboarding V7 | |
| Check Dúvidas Não Respondidas | ⊘ | WhatsApp System | |
| Sistema de Gestão de Whatsapp - Scraper | ⊘ | WhatsApp System — legado | |
| Scraper IG Sync Para Agente V3 | ⊘ | Instagram Scraper — legado | |
| WF_ORCHESTRATOR_CAPITULOS_V8_CORRIGIDO (cópia ⊘) | ⊘ | Dossiê — duplicata | |

---

## PÁGINA 11

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| SUB_WF_CAP6_OBJECOES_V8_CORRIGIDO | ✅ | Dossiê V8 | |
| SUB_WF_00_PRE_PROCESSADOR_V8_CORRIGIDO | ✅ | Dossiê V8 | |
| MAIN_WF_MASTER_V8_CORRIGIDO | ✅ | Dossiê V8 — orquestrador principal | |
| AGENTE_ANTI_ALUCINACAO_V8_CORRIGIDO | ✅ | Dossiê V8 | |
| SUB_WF_99_POLIDOR_V8_CORRIGIDO | ✅ | Dossiê V8 | |
| SUB_WF_SINTETIZADOR_V8_CORRIGIDO | ⊘ | Dossiê V8 | |
| SUB_WF_CAP_PROXIMOS_PASSOS_V8_CORRIGIDO (p11) | ⊘ | Dossiê V8 — duplicata | |
| SUB_WF_CAP_LAPIDACAO_V8_CORRIGIDO (p11) | ✅ | Dossiê V8 — duplicata | |
| SUB_WF_CAP12_CONTEUDO_V8_CORRIGIDO (p11) | ✅ | Dossiê V8 — duplicata | |
| SUB_WF_CAP10_STORYTELLING_V8_CORRIGIDO (p11) | ✅ | Dossiê V8 — duplicata | |
| SUB_WF_CAP9B_EXECUCAO_V8_CORRIGIDO (p11) | ✅ | Dossiê V8 — duplicata | |
| SUB_WF_CAP9A_FUNIL_V8_CORRIGIDO (p11) | ⊘ | Dossiê V8 | |
| SUB_WF_CAP8_ARQUITETURA_V8_CORRIGIDO (p11) | ⊘ | Dossiê V8 | |
| SUB_WF_CAP7_OFERTA_V8_CORRIGIDO (p11) | ✅ | Dossiê V8 | |
| SUB_WF_CAP4_TESE_V8_CORRIGIDO (p11) | ✅ | Dossiê V8 | |
| SUB_WF_CAP3_MURO_V8_CORRIGIDO (p11) | ✅ | Dossiê V8 | |
| SUB_WF_CAP2_PUBLICO_V8_CORRIGIDO (p11) | ⊘ | Dossiê V8 | |
| SUB_WF_CAP1_CONTEXTO_V8_CORRIGIDO (p11) | ✅ | Dossiê V8 | |
| SUB_WF_11_FORMATADOR_DOSSIE_LOOP_V7 | ⊘ | Dossiê V7 — legado | |
| WF_MAIN_ORCHESTRATOR_V7 | ✅ | Dossiê V7 — legado (ainda ativo?) | |
| SUB_WF_12 (Ideias) V7 | ⊘ | Dossiê V7 — legado | |
| SUB_WF_10_STORYTELLING_V7 | ⊘ | Dossiê V7 — legado | |
| SUB_WF_00_PRE_VALIDACAO_V7 | ⊘ | Dossiê V7 — legado | |
| SUB_WF_01_CAP1_V6 | ⊘ | Dossiê V6 — legado | |
| SUB_WF_02_CAP2 V7 - Público Completo | ⊘ | Dossiê V7 — legado | |
| SUB_WF_03_CAP3 V6 | ⊘ | Dossiê V6 — legado | |
| SUB_WF_04_CAP4 V6 | ⊘ | Dossiê V6 — legado | |
| SUB_WF_06_CAP6_V6 | ⊘ | Dossiê V6 — legado | |
| SUB_WF_07_CAP7_V7 - Estrutura da Oferta | ⊘ | Dossiê V7 — legado | |
| SUB_WF_08_CAP8_V7_COMPLETO | ⊘ | Dossiê V7 — legado | |
| SUB_WF_09B_DETALHAMENTO_FUNIL_V7 | ⊘ | Dossiê V7 — legado | |
| SUB_WF_09A_SUGESTAO_FUNIL_V7 | ⊘ | Dossiê V7 — legado | |
| AGENTE_ANTI_ALUCINACAO_V7 | ⊘ | Dossiê V7 — legado | |
| SUB_WF_12_PROXIMOS_PASSOS_V7 | ⊘ | Dossiê V7 — legado | |
| SUB_WF_ULTIMO - Mapa Psicográfico Profundo V7 | ⊘ | Dossiê V7 — legado | |
| 01 - Webhook Transações | ⊘ | Financeiro / Billing | |
| 05 - Recalculo Semanal V10 | ⊘ | Financeiro / Billing | |
| 03 - Import CSV - Lotes | ⊘ | Financeiro / Billing | |
| 02 - Batch Processador | ⊘ | Financeiro / Billing | |
| Linha Editorial Agente Gerador de Ideias v5.0 PROFUNDO | ⊘ | Linha Editorial — legado | |
| Linha Editorial Agente Coletor E6 | ✅ | Linha Editorial | |
| Linha Editorial Agente Coletor E4 | ⊘ | Linha Editorial | |
| Linha Editorial Agente Coletor E3B | ✅ | Linha Editorial | |
| Linha Editorial Agente Produtor E1 - Historia CORRIGIDO | ✅ | Linha Editorial | |
| Linha Editorial Agente Produtor E3 CORRIGIDO | ✅ | Linha Editorial | |
| Linha Editorial Agente Produtor E2 CORRIGIDO | ✅ | Linha Editorial | |
| Linha Editorial Agente Produtor E3 (duplicata) | ✅ | Linha Editorial | |
| Linha Editorial Agente Coletor E5 | ⊘ | Linha Editorial | |
| Linha Editorial Orquestrador Ideias GOBBI FINAL | ✅ | Linha Editorial | |
| Linha Editorial Agente Gerador de Ideias v3 | ⊘ | Linha Editorial — legado | |

---

## PÁGINA 12

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| Linha Editorial Gerador Ideias GOBBI FINAL V2 | ✅ | Linha Editorial | |
| Linha Editorial Gerador Ideias GOBBI FINAL | ✅ | Linha Editorial | |
| Linha Editorial Agente Etapa 3B Provas Sociais | ✅ | Linha Editorial | |
| Linha Editorial Etapa 6 V3 | ✅ | Linha Editorial | |
| Linha Editorial Etapa 5 Diagnostico COMPLETO | ✅ | Linha Editorial | |
| Linha Editorial Orquestrador Ideias | ✅ | Linha Editorial | |
| Linha Editorial Agente Polidor | ✅ | Linha Editorial | |
| Linha Editorial Agente Desenvolvedor de Ideias | ⊘ | Linha Editorial | |
| Linha Editorial Agente Pré-Processador | ⊘ | Linha Editorial | |
| Linha Editorial Agente Gerador de Ganchos | ⊘ | Linha Editorial | |
| Linha Editorial Gerador Ideias v2 | ✅ | Linha Editorial | |
| Linha Editorial Tool Salva Ideia | ✅ | Linha Editorial | |
| Linha Editorial Tool Salva Linha Editorial | ✅ | Linha Editorial | |
| Linha Editorial Etapa 6 | ✅ | Linha Editorial | |
| Linha Editorial Agente Coletor E2 | ⊘ | Linha Editorial | |
| Linha Editorial Agente Produtor E1 - Historia | ⊘ | Linha Editorial — não-CORRIGIDO | |
| Linha Editorial Tool Salva Historia Refinada | ⊘ | Linha Editorial | |
| Linha Editorial Agente Coletor E1 | ✅ | Linha Editorial | |
| Linha Editorial Agente Coletor E3 | ⊘ | Linha Editorial | |
| Linha Editorial Tool Salva Dados E5 | ✅ | Linha Editorial | |
| Linha Editorial Tool Salva Dados E3 | ⊘ | Linha Editorial | |
| Linha Editorial Tool Salva Dados E2 | ⊘ | Linha Editorial | |
| Linha Editorial Tool Salva Dados E1 | ⊘ | Linha Editorial | |
| Linha Editorial Tool Salva Dados E2 (dup) | ⊘ | Linha Editorial — duplicata | |
| Linha Editorial Tool Salva Campo Generico | ⊘ | Linha Editorial | |
| Linha Editorial Tool Salva Documento | ⊘ | Linha Editorial | |
| Linha Editorial Agente Coletor Documentos | ✅ | Linha Editorial | |
| Linha Editorial Tool Salva Documento (dup) | ⊘ | Linha Editorial — duplicata | |
| Linha Editorial Agente Cadastro CORRIGIDO | ✅ | Linha Editorial | |
| Linha Editorial Tool Valida Email | ✅ | Linha Editorial | |
| Linha Editorial Agente Produtor E2 - Identidade Verbal | ⊘ | Linha Editorial — não-CORRIGIDO | |
| MC Games - 12 Relatório Semanal | ⊘ | 👤 Cliente externo — MC Games | |
| MC Games - 11 Refresh Views Power BI | ⊘ | 👤 Cliente externo — MC Games | |
| MC Games - 10 Validação Retroativa | ⊘ | 👤 Cliente externo — MC Games | |
| MC Games - 09 Monitoramento Drift | ⊘ | 👤 Cliente externo — MC Games | |
| MC Games - 08 Healthcheck | ⊘ | 👤 Cliente externo — MC Games | |
| MC Games - 07 Sync UTM | ⊘ | 👤 Cliente externo — MC Games | |
| MC Games - 06 Pipeline Orquestrador MASTER | ⊘ | 👤 Cliente externo — MC Games | |
| My workflow 43 | ⊘ | ❓ — MC Games? | |
| MC Games - 04 Treinar Modelos | ⊘ | 👤 Cliente externo — MC Games | |
| MC Games - 03 Calcular Features RFM | ⊘ | 👤 Cliente externo — MC Games | |
| My workflow 42 | ⊘ | ❓ — MC Games? | |
| MC Games - 01 Webhook Transações | ⊘ | 👤 Cliente externo — MC Games | |
| My workflow 41 | ⊘ | ❓ — MC Games? | |
| MC Games - Healthcheck | ⊘ | 👤 Cliente externo — MC Games | |
| My workflow 40 | ⊘ | ❓ — MC Games? | |
| MC Games - Pipeline Diário | ⊘ | 👤 Cliente externo — MC Games | |
| Linha Editorial Sintetizador Historia | ⊘ | Linha Editorial | |
| Agentes Mentoria Agente Cadastro | ✅ | Agentes Mentoria | |
| Mentoria System V3 - Logic | ✅ | Agentes Mentoria — lógica core | |

---

## PÁGINA 13

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| SUB_WF_07_CAP7_COMPLETO V5 | ⊘ | Dossiê V5 — legado | |
| WF_MAIN_ORCHESTRATOR [V5] | ✅ | Dossiê V5 — ainda ativo? | |
| 16_TOOL_SALVA_ENTREGAVEL | ⊘ | Dossiê — tool | |
| WF_CAP12_STANDALONE - Ideias de Conteudo | ✅ | Dossiê — standalone | |
| SUB_WF_12 - CAP12 V6 CORRIGIDO | ⊘ | Dossiê V6 — legado | |
| Linha Editorial Agente Produtor E1 - Bio e Apresentacoes | ✅ | Linha Editorial | |
| Linha Editorial Tool Muda Estado Conversa | ⊘ | Linha Editorial — tool | |
| Analise Trafego v4 - Corrigido | ⊘ | Ads / Tráfego | |
| WorkFlow Incompletos Aplicações Case | ✅ | Admin / Monitor | |
| 17_TOOL_BUSCA_CONTEXTO | ⊘ | Dossiê — tool | |
| AGENTE DE VALIDAÇÃO INICIAL (PRÉ-WF2) V4 | ✅ | Onboarding / Dossiê | |
| SUB_WF_06_CAP6 | ✅ | Dossiê (versão base?) | |
| SUB_WF_02_CAP2 V5 | ⊘ | Dossiê V5 — legado | |
| compras_[blacksheep]_[adtk] | ⊘ | 👤 Cliente encerrado | |
| cadastro_data_[blacksheep]_[adtk] | ⊘ | 👤 Cliente encerrado | |
| pesquisa_data_[blacksheep]_[adtk] | ⊘ | 👤 Cliente encerrado | |
| GB Flow | ⊘ | ❓ — confirmar | |
| SUB_WF_09_FUNIL_V5 | ⊘ | Dossiê V5 — legado | |
| Clone Voz Criativo | ⊘ | Experimento — inativo | |
| Scraper IG Alunos Fluxo 1 | ✅ | Instagram Scraper | |
| SUB_WF_12 - CAP12 V4 | ⊘ | Dossiê V4 — legado | |
| SUB_WF_10_STORYTELLING V5 | ⊘ | Dossiê V5 — legado | |
| Lapidação Perfil V4 - CONVERSACIONAL | ✅ | Lapidação | |
| Lapidação Perfil v4 - 3 Agentes PARALELO | ⊘ | Lapidação — variante inativa | |
| SUB_WF_03_CAP3 V5 | ✅ | Dossiê V5 — ainda ativo? | |
| SUB_WF_08_CAP8 V5 | ⊘ | Dossiê V5 — legado | |
| SUB_WF_05_CAP5 V5 | ⊘ | Dossiê V5 — legado | |
| SUB_WF_04_CAP4 V5 | ⊘ | Dossiê V5 — legado | |
| SUB_WF_01_CAP1 V5 | ⊘ | Dossiê V5 — legado | |
| WF_MAIN_ORCHESTRATOR [V4] | ✅ | Dossiê V4 — ainda ativo? | |
| SUB_WF_05 - CAP5 V4 | ⊘ | Dossiê V4 — legado | |
| SUB_WF_03 - CAP3 V4 | ⊘ | Dossiê V4 — legado | |
| SUB_WF_02 - CAP2 V4 | ⊘ | Dossiê V4 — legado | |
| SUB_WF_10 - CAP10 V4 | ⊘ | Dossiê V4 — legado | |
| SUB_WF_09 - CAP9 V4 | ⊘ | Dossiê V4 — legado | |
| SUB_WF_08 - CAP8 V4 | ⊘ | Dossiê V4 — legado | |
| SUB_WF_07 - CAP7 V4 | ⊘ | Dossiê V4 — legado | |
| SUB_WF_06 - CAP6 V4 | ⊘ | Dossiê V4 — legado | |
| SUB_WF_04 - CAP4 V4 | ⊘ | Dossiê V4 — legado | |
| SUB_WF_01 - CAP1 V4 | ⊘ | Dossiê V4 — legado | |
| 1 | ⊘ | ❓ | |
| MGD8 - SHEET - ALUNOS | ✅ | 👤 Cliente externo — MGD8 | |
| Webhook to Manychat - Entrada Grupo Fogo | ⊘ | 👤 Cliente externo — MGD8? | |
| Webhook to Manychat - Entrada Grupo Café | ⊘ | 👤 Cliente externo — MGD8? | |
| AGENTE 3 - Estrategista Conteúdo | ✅ | Ads / Análise criativo | |
| AGENTE 2 - Analisador Copy | ✅ | Ads / Análise criativo | |
| AGENTE 1 - Analisador Visual | ✅ | Ads / Análise criativo | |
| Webhook to Manychat - Entrada Grupo | ⊘ | 👤 Cliente externo — MGD8? | |
| MGD8 - SHEET - CADASTRO PRÉ INSCRITOS | ✅ | 👤 Cliente externo — MGD8 | |
| Agente Lapidação com Transcrição - COMPLETO | ⊘ | Lapidação — inativo | |

---

## PÁGINA 14

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| Agente Lapidação com Memória de Conversa | ⊘ | Lapidação — inativo | |
| Webhook Lapidação Perfil [CORRIGIDO] | ✅ | Lapidação | |
| Adaptação de Roteiro para Formato | ✅ | Conteúdo / Stories | |
| Descontinuado analise | ⊘ | Descontinuado | |
| Fluxo Whatsapp Mentorados Case | ⊘ | WhatsApp — legado | |
| Fluxo Whatsapp Mentorados Case - 1 | ⊘ | WhatsApp — legado | |
| Fluxo Whatsapp Mentorados Case (cópias x3) | ⊘ | WhatsApp — legado | |
| Executor de Lembretes - Memory Keyla | ✅ | ❓ — Keyla = quem? | |
| 08 - Gestor de Tarefas Equipe | ⊘ | Admin / Equipe | |
| SUB_WF_09_FUNIL_V2 | ⊘ | Dossiê V2 — legado | |
| SUB_WF_02_HISTORIA_EXPERT_TEST | ✅ | Dossiê — teste ativo? | |
| Zoom Call Orchestration - COMPLETO E FUNCIONAL | ⊘ | Zoom — legado | |
| WF_MAIN_ORCHESTRATOR_V2 | ✅ | Dossiê V2 — ainda ativo? | |
| SUB_WF_07_CAP7_COMPLETO | ✅ | Dossiê (base) | |
| dasdassa SUB_WF_09_FUNIL_ATIVOS | ✅ | Dossiê — nome maluco, o que é? | |
| SUB_WF_09_FUdsadsadasdsaNIL_V2 | ⊘ | Dossiê V2 — teste/lixo | |
| [MOLDE] SUB_WF_03_CAP3 | ✅ | Dossiê — molde de referência | |
| SUB_WF_08_ARQUITETURA_PRODUTO | ✅ | Dossiê | |
| SUB_WF_02_HISTORIA_EXPERT | ✅ | Dossiê | |
| SUB_WF_11_FORMATADOR_DOCUMENTO | ⊘ | Dossiê | |
| SUB_WF_12_IDEIAS_CONTEUDO | ⊘ | Dossiê | |
| SUB_WF_13_PLANO_ACAO | ⊘ | Dossiê | |
| SUB_WF_10_STORYTELLING | ✅ | Dossiê | |
| Agente Produto Iniciais Lovable - Agente Revisor de Copy | ✅ | Produto Lovable | |
| AGENTE DE VALIDAÇÃO INICIAL (PRÉ-WF2) | ⊘ | Onboarding — versão antiga | |
| SUB_WF_05_CAP5 | ⊘ | Dossiê | |
| AGENTE_ANTI_ALUCINACAO | ✅ | Dossiê — base | |
| SUB_WF_08_CAP8 | ✅ | Dossiê | |
| SUB_WF_07_CAP7 | ✅ | Dossiê | |
| SUB_WF_00_PRE_PROC | ✅ | Dossiê | |
| SUB_WF_04_CAP4 | ⊘ | Dossiê | |
| SUB_WF_02_CAP2 | ✅ | Dossiê | |
| SUB_WF_01_CAP1 | ✅ | Dossiê | |
| WF_MAIN_ORCHESTRATOR | ⊘ | Dossiê — versão base | |
| SUB_WF_09_SINTETIZADOR | ⊘ | Dossiê | |
| v2 - WF1 - Pos-Onboarding COM PLANO DE AÇÃO | ✅ | Onboarding + Plano Ação | |
| Scraper IG Carrossel Alunos Fluxo 1 (x2) | ⊘ | Instagram — legado | |
| Scraper IG Carrossel Alunos Fluxo 2 (x2) | ⊘ | Instagram — legado | |
| Scraper IG Carrossel Alunos Fluxo 3 | ⊘ | Instagram — legado | |
| v1 - WF1 - Pos-Onboarding COM PLANO DE AÇÃO | ⊘ | Onboarding — V1 legado | |
| Fluxo Carrossel | ⊘ | Instagram — legado | |
| SubWF Agente Capitulo 1 - Oferta e Produto v1 | ⊘ | Dossiê V1 — legado | |
| SubWF Agente Capitulo 2 - Oferta e Produto v1 | ⊘ | Dossiê V1 — legado | |
| Scraper IG Carrossel Alunos Fluxo 2 (ativo) | ✅ | Instagram Scraper | |
| SUB-WF-Cap1-Contexto | ⊘ | Dossiê V1 — legado | |
| WF2: Pré-Call 2 | ✅ | Onboarding — Call 2 | |

---

## PÁGINA 15

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| WF3: Call 2 - Geração de Documentos | ✅ | Onboarding — Call 2 | |
| WF5: Pré-Call 3 | ⊘ | Onboarding — Call 3 (inativo) | |
| WF4: Pós-Call 2 - Validação e Publicação | ✅ | Onboarding — Call 2 | |
| WF6: Pós-Call 3 | ⊘ | Onboarding — Call 3 (inativo) | |
| My workflow 39 (x2) | ⊘ | ❓ | |
| My workflow 38 | ⊘ | ❓ | |
| My workflow 37 | ⊘ | ❓ | |
| My workflow 36 | ⊘ | ❓ | |
| My workflow 35 | ⊘ | ❓ | |
| My workflow 34 | ⊘ | ❓ | |
| My workflow 33 | ⊘ | ❓ | |
| My workflow 32 | ⊘ | ❓ | |
| My workflow 31 | ⊘ | ❓ | |
| My workflow 30 | ⊘ | ❓ | |
| My workflow 29 | ⊘ | ❓ | |
| My workflow 28 | ⊘ | ❓ | |
| Agente Produto Lovable - Mapa de Identificação | ✅ | Produto Lovable | |
| Agente Produto Lovable - Pesquisa de Mercado | ✅ | Produto Lovable | |
| Agente Produto Lovable - Lapidação de Vitrine | ✅ | Produto Lovable | |
| Agente Produto Lovable - Método e Tese | ✅ | Produto Lovable | |
| Agente Produto Lovable - Construção de Oferta | ✅ | Produto Lovable | |
| Agente Produto Lovable - Produto e Promessa | ✅ | Produto Lovable | |
| Resumo Grupo de Whatsapp Case | ⊘ | WhatsApp — legado | |
| Fluxo Whatsapp Backup de Fluxo de Consulta | ⊘ | WhatsApp — legado | |
| 2 | ⊘ | ❓ | |
| Fluxo Teste 2 Pós Call de Onboarding | ⊘ | Onboarding — teste | |
| Fluxo II Onboarding Pós-Call Validação Público | ⊘ | Onboarding — legado | |
| WF 5 - Organizador Agentes de Produto e Oferta | ✅ | Dossiê / Produto — antigo | |
| WF 4 - Agente Coletor Call 1 | ⊘ | Dossiê / Produto — antigo | |
| WF 6 - Agente Concepção Oferta com RAG | ⊘ | Dossiê / Produto — antigo | |
| WF 8 - Agente Consolidador Mapa Concepção | ⊘ | Dossiê / Produto — antigo | |
| WF 9 - Agente Ideias Editorial | ⊘ | Dossiê / Produto — antigo | |
| WF 10 - Agente Storytelling Produto | ⊘ | Dossiê / Produto — antigo | |
| WF 11 - Agente de Funil de Vendas | ⊘ | Dossiê / Produto — antigo | |
| WF 7 - Agente Validador Call 2 Oferta | ⊘ | Dossiê / Produto — antigo | |
| Fluxo Original Oferta Case V1 | ⊘ | Dossiê V1 — legado | |
| Fluxo Original Onboarding Pré Oferta V1 | ⊘ | Dossiê V1 — legado | |
| WF 2 - Embedding Calls | ⊘ | RAG — legado | |
| WF 3 - RAG Tool | ⊘ | RAG — legado | |
| WF 1 - Transcrição Calls | ⊘ | Transcrição — legado | |
| MGD8 Grupos Whatsapp Saídas | ✅ | 👤 Cliente externo — MGD8 | |
| MGD8 SHEET CADASTRO | ✅ | 👤 Cliente externo — MGD8 | |
| My workflow 27 | ⊘ | ❓ | |
| ORQ 1 | ⊘ | ❓ | |
| Gamma PDF Geração | ⊘ | Experimento — inativo | |
| MGD8 Grupos Whatsapp | ✅ | 👤 Cliente externo — MGD8 | |
| Fluxo III Oferta Call Consolidação V4 | ⊘ | Dossiê — legado | |
| Fluxo III Oferta Call Consolidação V3 | ⊘ | Dossiê — legado | |
| Fluxo I Onboarding Aluno Coletor e Organizador | ⊘ | Onboarding — legado | |

---

## PÁGINA 16

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| Descontinuado - Fluxo II Onboarding | ⊘ | Descontinuado | |
| Fluxo Whatsapp Mentorados Case Descontinuado | ⊘ | Descontinuado | |
| Scraper IG Alunos Fluxo Descontinuado | ⊘ | Descontinuado | |
| Agentes Mentoria Agente Ideias - Muda estado | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Agente Cadastro - Muda estado | ✅ | Agentes Mentoria — tool | |
| My workflow 26 | ⊘ | ❓ | |
| My workflow 25 (x2) | ⊘ | ❓ | |
| Fluxo de Input Transcricao - Zoom + Plano | ⊘ | Transcrição — legado | |
| My workflow 23 (x2) | ⊘ | ❓ | |
| My workflow 21 | ⊘ | ❓ | |
| My workflow 24 | ⊘ | ❓ | |
| My workflow 22 | ⊘ | ❓ | |
| Agentes Mentoria Agente Roteiro - Muda estado | ✅ | Agentes Mentoria — tool | |
| RESUMO GRUPOS WPP | ⊘ | WhatsApp — legado | |
| My workflow 19 (x2) | ⊘ | ❓ | |
| My workflow 17 (múltiplos) | ⊘ | ❓ | |
| My workflow 20 | ⊘ | ❓ | |
| My workflow 18 | ⊘ | ❓ | |
| Agente de Métricas - Tráfego Pago | ⊘ | Ads / Tráfego | |
| Fluxo de Agendamento Reuniões e Ligações Case | ✅ | Agendamento | |
| Whatsapp Scraper | ✅ | WhatsApp System | |
| Parte 2 Fluxo de Agendamento | ✅ | Agendamento | |
| My workflow 16 | ⊘ | ❓ | |
| My workflow 15 | ⊘ | ❓ | |
| My workflow 3 | ⊘ | ❓ | |
| beeautomatica | ⊘ | 👤 Cliente encerrado | |
| My workflow 8 Hugo | ⊘ | ❓ — Hugo = quem? | |
| Agentes Mentoria Agente Campanha - Muda estado | ✅ | Agentes Mentoria — tool | |
| My workflow 8 | ✅ | ❓ — ativo mas sem nome | |
| Agentes Mentoria Agente Entrega | ✅ | Agentes Mentoria | |
| Fluxo III - FN | ⊘ | ❓ — FN = Flávia? | |
| Fluxo II - FN | ⊘ | ❓ — FN = Flávia? | |
| Fluxo 1 - FN | ⊘ | ❓ — FN = Flávia? | |
| My workflow 13 | ⊘ | ❓ | |
| My workflow 12 | ⊘ | ❓ | |
| My workflow 11 | ⊘ | ❓ | |
| Agentes Ferramenta Orquestrador Escolha funil | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Fluxo geral Agentes funis | ✅ | Agentes Mentoria | |
| My workflow 10 | ✅ | ❓ — ativo mas sem nome | |
| My Sub-Workflow 2 | ✅ | ❓ — ativo, o que é? | |
| Agentes Mentoria Campanha - Muda sub-estado | ✅ | Agentes Mentoria — tool | |
| My workflow 9 | ⊘ | ❓ | |

---

## PÁGINA 17

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| Fluxo Instagram | ✅ | Instagram | |
| Agentes Mentoria Agente ListaVip - Gestor | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Indicador - Gestor | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Levantador - Gestor | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Evento - Gestor | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Recompensa - Gestor | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Pocket - Gestor | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente VSL - Gestor | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Upgrade - Gestor | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Reativacao - Gestor | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Caçador - Gestor | ✅ | Agentes Mentoria | |
| Agentes Ferramenta Ativa agente VSL | ✅ | Agentes Mentoria — tool | |
| Agentes mentoria Ferramenta Copy - Exemplo mensagens | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Ferramenta Pocket | ✅ | Agentes Mentoria — tool | |
| Agentes Ferramenta Call vendas - Ativa agente principal | ✅ | Agentes Mentoria — tool | |
| Agentes Ferramenta Ativa agente Call vendas | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Agente Copy | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Conteúdo | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Reativação alunos | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Upgrade | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Recompensa | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Pocket | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Levantador | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Evento | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Indicador | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Lista Vip | ✅ | Agentes Mentoria | |
| Agentes Ferramenta Ativa agente Conteudo | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Agente Caçador | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente VSL | ✅ | Agentes Mentoria | |
| Agentes Mentoria Agente Call vendas | ✅ | Agentes Mentoria | |
| Agentes Ferramenta VSL - Ativa agente principal | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Agente Orquestrador | ✅ | Agentes Mentoria | |
| My workflow 6 | ⊘ | ❓ | |
| Inserção Agente Demanda Qualificada | ⊘ | ❓ | |
| My workflow 7 | ⊘ | ❓ | |
| Fluxo Instagram - Queila | ⊘ | Instagram — legado | |
| Fluxo Instagram - Queila copy | ⊘ | Instagram — legado | |
| Agentes Ferramenta Muda estado p/ Implementação VSL | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Agente Pocket criador | ✅ | Agentes Mentoria | |
| Agentes Ferramenta Ativa agente Criador | ✅ | Agentes Mentoria — tool | |
| Agentes Ferramenta Conteudo - Ativa agente principal | ✅ | Agentes Mentoria — tool | |
| Agentes Ferramenta Ativa agente Copy | ✅ | Agentes Mentoria — tool | |
| Agentes Ferramenta Muda estado Call vendas | ✅ | Agentes Mentoria — tool | |
| Agentes Ferramenta Muda estado p/ Implementação | ✅ | Agentes Mentoria — tool | |
| My Sub-Workflow 1 | ✅ | ❓ — ativo, o que é? | |
| My workflow 5 | ⊘ | ❓ | |
| V1 - CRM - Aplicação - DataCrazy | ⊘ | 👤 Cliente encerrado | |
| Agentes Mentoria Agente Call vendas Gestor informação | ✅ | Agentes Mentoria | |
| My workflow 4 | ✅ | ❓ — ativo, o que é? | |
| Subir arquivos RAG no Banco de dados vetorizado | ⊘ | RAG — setup | |

---

## PÁGINA 18

| Workflow | Status N8N | Cluster (minha leitura) | Kaique — Status |
|----------|-----------|------------------------|-----------------|
| # Generate AI Videos with Google Veo3 | ⊘ | Experimento — template importado | |
| Agentes Mentoria Agente Gerador de Demanda | ✅ | Agentes Mentoria | |
| Agentes Mentoria Ferramenta VSL | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Ferramenta Lista Vip | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Consulta banco de dados | ✅ | Agentes Mentoria | |
| Agentes Mentoria Ferramenta Gerador de demanda | ✅ | Agentes Mentoria — tool | |
| Agente Gerador de Criativos VEO3 | ⊘ | Experimento | |
| Agentes Mentoria Ferramenta Indicador | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Ferramenta Upgrade | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Ferramenta Reativação alunos | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Ferramenta Recompensa | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Ferramenta Evento | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Ferramenta Levantador (obterModelosPraticos) | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Ferramenta Levantador (obterFundamentos) | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Ferramenta Caçador | ✅ | Agentes Mentoria — tool | |
| Agentes Mentoria Ferramenta Call de vendas | ✅ | Agentes Mentoria — tool | |
| My workflow 2 | ✅ | ❓ — ativo, o que é? | |
| GPTs Entrega detalhada funis | ✅ | Agentes Mentoria — entrega | |
| My workflow | ⊘ | ❓ | |
| Testes TH | ⊘ | ❓ — TH = Thiago? | |
| Followup pendente - airtable | ⊘ | 👤 Cliente encerrado — Airtable | |
| Notificação de novos tickets - airtable | ⊘ | 👤 Cliente encerrado — Airtable | |
| Processador de documentos vetorizado | ⊘ | RAG — legado | |
| RPD | ✅ | ❓ — confirmar com Kaique | |
| SPG | ✅ | ❓ — confirmar com Kaique | |
| Status dos Tickets - Airtable | ⊘ | 👤 Cliente encerrado — Airtable | |
| Instagram e Youtube Ads Scraper | ⊘ | Ads — legado | |
| Todas as operações de scraper api - apify | ⊘ | Experimento | |
| Nem sei | ⊘ | ❓ (nome literal) | |
| Sessão 4 - Recuperar sessão super agente | ⊘ | 👤 Cliente encerrado — Airtable | |
| Sessão 3 - Aprovação entre superagentes | ⊘ | 👤 Cliente encerrado — Airtable | |
| Sessão 2 - Processamento outputs agentes | ⊘ | 👤 Cliente encerrado — Airtable | |
| Automação - Inicio de sessão 1 | ⊘ | 👤 Cliente encerrado — Airtable | |
| Outro workflow de consulta de mensagem - Ecomm | ⊘ | 👤 Cliente encerrado — Ecomm | |
| Workflow de Consulta de mensagens - Ecomm | ⊘ | 👤 Cliente encerrado — Ecomm | |
| Fluxo de Transcrição de Reels | ⊘ | Conteúdo — legado | |
| Global - Ecomm | ⊘ | 👤 Cliente encerrado — Ecomm | |
| CPLD | ✅ | ❓ — confirmar com Kaique | |
| Hub bee libre | ⊘ | 👤 Cliente encerrado | |
| Agente de produtos - ecomm | ⊘ | 👤 Cliente encerrado — Ecomm | |
| Agente suporte geral - ecomm | ⊘ | 👤 Cliente encerrado — Ecomm | |
| Agente de coordenação central de pedidos | ⊘ | 👤 Cliente encerrado — Ecomm | |
| Agente cancelamento de pedido | ⊘ | 👤 Cliente encerrado — Ecomm | |
| Agente de Gestão de Tarefas - Airtable | ⊘ | 👤 Cliente encerrado — Airtable | |
| Agente de Atendimento Ecommerce | ⊘ | 👤 Cliente encerrado — Ecomm | |
| Consulta de informações memória | ⊘ | ❓ | |
| Agente gerador de criativos | ⊘ | Experimento | |

---

## Perguntas Abertas para Kaique

> Preencher antes de rodar limpeza do N8N

| # | Dúvida | Resposta Kaique |
|---|--------|-----------------|
| 1 | **Fidelização** (Gamificação, Google Reviews, Prevenção, Indicação, Seletor, Aniversariantes) — é sistema CASE interno ou de um cliente específico? | |
| 2 | **RPD / SPG / CPLD** — o que são essas siglas (3 workflows ativos)? | |
| 3 | **"Flávia" / FN** — Fluxo I/II/III FN = Flávia Marinho? Todos ⊘, pode arquivar? | |
| 4 | **Clarinha** — onde está no N8N? É um workflow ou apenas no Supabase/código? | |
| 5 | **Sendflow CD10X** — o que é? CASE ou cliente? | |
| 6 | **F-SFL / F-SHEET** — o que são? CASE interno? | |
| 7 | **WF-BFCC / WF-BFFM1125** — o que são? | |
| 8 | **TH Inativo Supabase / Testes TH** — TH = Thiago (mentorado)? Pode arquivar? | |
| 9 | **Processar Top 75 Gisele** — Gisele é mentorada ou cliente externo? | |
| 10 | **My workflow 8 / 10 (ativos)** — o que são esses dois sem nome mas publicados? | |
| 11 | **My Sub-Workflow 1 / 2 (ativos)** — o que são? | |
| 12 | **dasdassa SUB_WF_09_FUNIL_ATIVOS** — nome com erro de digitação, é usado ou é lixo? | |
| 13 | **Executor de Lembretes - Memory Keyla** — Keyla = quem? CASE ou cliente? | |
| 14 | **RETROATIVO v5** — o que é? | |
| 15 | **GB Flow** — o que é? | |
| 16 | **ORQ 1** — o que é? | |
| 17 | **Sendflow CD10X** — CASE ou cliente externo? | |
| 18 | **WF_MAIN_ORCHESTRATOR V2/V4/V5** — ainda ativos, são necessários ou podem ser arquivados? | |
| 19 | **Agente Produto Lovable (série)** — é o sistema para mentorados que está no Lovable? | |
| 20 | **MGD8** — cliente ativo ou encerrado? |  |

---

*Arquivo gerado em Mar/2026 via auditoria DOM Puppeteer — 18 páginas × 50 workflows = 897 total.*
