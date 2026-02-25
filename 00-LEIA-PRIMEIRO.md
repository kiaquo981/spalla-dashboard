# SPALLA V2 — Handoff Completo (17/02/2026)

## O Que E Esta Pasta

Esta pasta contem **toda a documentacao do sistema Spalla V2** — o CRM de mentoria
do programa CASE da Queila. Foi criada em 17/02/2026 como handoff pro Demetrio
(dev que vai subir tudo em producao).

## Contexto — O Que Foi Feito

### O Problema
A Queila mentora 37 pessoas no programa CASE. Tinha dados espalhados em varias
planilhas, WhatsApp, Zoom, e nenhum lugar centralizado pra acompanhar tudo.

### O Que Construimos (Kaique + Claude, Jan-Fev 2026)

1. **Banco de dados completo no Supabase** (`knusqfbvhsqworzyhvip`)
   - 17 tabelas com dados reais: 23.840 msgs WhatsApp, 226 calls, 505 extracoes IA,
     93 planos de acao, 1.362 direcionamentos, ~800 tarefas
   - 9 views SQL ("God Views") que consolidam tudo em queries prontas pro frontend
   - 2 functions RPC (detalhe completo de mentorado + alertas automaticos)
   - Pipeline automatico: Zoom → N8N → 5 agentes IA → plano de acao

2. **Frontend funcional (prototipo)**
   - Alpine.js SPA com 8 paginas: Dashboard, Detalhe, Kanban, Tarefas, Agenda,
     WhatsApp, Dossies, Lembretes
   - Integracoes: Supabase (direto do browser), Zoom, Google Calendar, WhatsApp
   - Fotos de perfil dos mentorados (50+ JPGs do Instagram)

3. **Backend simples (server.py)**
   - Python HTTP server que proxeia Zoom, Google Calendar e Evolution API (WhatsApp)
   - Endpoint principal: POST /api/schedule-call (cria Zoom + Calendar + salva no DB)

### Estado Atual
- **Banco:** DEPLOYADO e validado no Supabase
- **Frontend:** Funcional localmente (python server.py, porta 8888, senha: spalla2026)
- **Producao:** NAO SUBIU AINDA — precisa de infra (Railway/Render/VPS), HTTPS, auth real

### O Que O Demetrio Precisa Fazer
- Ler `01-REPORT-COMPLETO-PRO-DEMETRIO.md` — tem TUDO (credenciais, endpoints, como rodar, validacao)
- Usar as views/functions do Supabase como API (ja ta pronto, so consumir)
- Decidir stack de producao (Next.js? Nuxt? FastAPI?) e subir

---

## Indice dos Arquivos

### Documentacao Principal (MANDA PRO DEMETRIO)
| # | Arquivo | O Que Tem |
|---|---------|-----------|
| 01 | `01-REPORT-COMPLETO-PRO-DEMETRIO.md` | Guia completo: arquitetura, credenciais, tabelas, views, endpoints, como rodar, o que falta |
| 02 | `02-FLOWCHARTS-SISTEMA.md` | 3 diagramas Mermaid: arquitetura geral, fluxo de agendamento, pipeline IA |
| 03 | `03-DOC-TECNICA-TABELAS.md` | Documentacao tecnica: 17 tabelas com todas as colunas, tipos, descricoes |
| 04 | `04-SPEC-VIEWS-COMPONENTES.md` | Mapeamento view → componente frontend, colunas detalhadas |

### SQL (EXECUTAR NO SUPABASE SE PRECISAR RECRIAR)
| # | Arquivo | Ordem | O Que Faz |
|---|---------|-------|-----------|
| 05 | `05-SQL-schema-inicial.sql` | 1o | Cria as tabelas base |
| 06 | `06-SQL-update-mentorados.sql` | 2o | Popula/atualiza dados dos mentorados |
| 07 | `07-SQL-god-tasks-schema.sql` | 3o | Cria tabelas de tarefas bidirecionais |
| 08 | `08-SQL-god-views-v2.sql` | 4o | Cria 9 views + 2 functions + indexes (PRINCIPAL) |
| 09 | `09-SQL-fix-imediato.sql` | se necessario | Correcoes pontuais (fases, desativacoes) |

### App (CODIGO DO PROTOTIPO)
| # | Arquivo | O Que E |
|---|---------|---------|
| 10 | `10-APP-index.html` | UI completa (Alpine.js, 8 paginas) |
| 11 | `11-APP-app.js` | Logica da aplicacao (77KB) |
| 12 | `12-APP-data.js` | Dados estaticos + fallback (146KB) |
| 13 | `13-APP-styles.css` | Estilos (130KB) |
| 14 | `14-APP-server.py` | Backend Python (Zoom, Calendar, WhatsApp) |

### Extras
| # | Arquivo | O Que E |
|---|---------|---------|
| 15 | `15-AUDITORIA-COMPLETA.md` | Auditoria de gaps e dados (16/02/2026) |
| 16 | `16-DASHBOARD-REPORT-FINAL.md` | Report final do dashboard (15/02/2026) |

---

## Credenciais Rapidas

| Servico | Valor |
|---------|-------|
| Supabase projeto | `knusqfbvhsqworzyhvip` |
| Supabase password | `BekIUq66EhVJ84QB` |
| Senha dashboard | `spalla2026` |
| Zoom Account ID | `DXq-KNA5QuSpcjG6UeUs0Q` |
| Evolution API | `07826A779A5C-4E9C-A978-DBCD5F9E4C97` |

(Credenciais completas no arquivo 01)

---

## Timeline do Projeto

| Data | O Que Aconteceu |
|------|-----------------|
| Jan 2025 | Inicio do programa CASE, primeiras calls |
| Jan 2026 | Inicio do Spalla V1 (views basicas) |
| 09/02/2026 | Inicio Spalla V2 (God Views, Alpine.js) |
| 15/02/2026 | Dashboard funcional, 8 paginas, integracoes |
| 16/02/2026 | Auditoria completa, god_tasks bidirecional, fixes |
| 17/02/2026 | Documentacao final, handoff pro Demetrio |

---

*Gerado por Kaique + Claude Code em 17/02/2026*
