---
title: "Backlog Spalla V2 — Priorizado pós-call 27/03"
created: 2026-03-30
source: "PRD-SPALLA-V2 + decisões Kaique 30/03"
status: active
---

# Backlog Spalla V2 — Priorizado

> Filtrado do PRD de 80+ items. Só o que Kaique confirmou em 30/03.

---

## DESCARTADO / JÁ RESOLVIDO

| Item | Motivo |
|------|--------|
| Label "Minhas Tarefas" redundante | Já resolvido |
| Revisar dossiê Débora + enviar Daniela | É tarefa operacional, já tá no board |
| Entregar dossiê Lidiane + formulário | É tarefa operacional, já tá no board |
| Quem atualiza status Operon revisões Keyla | Não precisa pensar nisso |
| Fix call Lidiane | Já resolvido |
| Calls vinculadas ao card | Já resolvido |
| Depoimentos por mentorado | Não agora |
| Convite automático pro mentorado | Descartado |
| Tipo adjudicação call | Descartado |
| Wiki interna | Futuro |
| Review templates onboarding | Vai fazer reunião separada |

---

## BACKLOG ATIVO — Por prioridade

### BLOCO 1: Cockpit & Operação (Command Center V2)

> Kaique quer ver em localhost antes de implementar.

| # | Item | Epic | Complexidade |
|---|------|------|-------------|
| 1 | Download da semana (sexta: descarregar contexto) | CC | Grande |
| 2 | Planejamento da semana (segunda: o que priorizar) | CC | Grande |
| 3 | Dossiês gargalados (prazo passando) | CC | Médio |
| 4 | Mentorados sem call há X dias | CC | Pequeno |

### BLOCO 2: Dossiês & Produção

| # | Item | Epic | Complexidade |
|---|------|------|-------------|
| 5 | Datas internas vs externas no card dossiê | E4 | Médio |
| 6 | Etapas internas (revisão Mariza → Keyla → aprovado) | E4 | Médio |
| 7 | Histórico de eventos (quem fez o que, quando) | E4 | Médio |
| 8 | Comentários dentro do card dossiê (audio, video, texto, prints) | E4 | Grande |

### BLOCO 3: WA Intelligence Layer

| # | Item | Epic | Complexidade |
|---|------|------|-------------|
| 9 | Classificações no frontend (mostrar categorias do n8n) | E3 | Médio |
| 10 | Resumo semanal por mentorado | E3 | Grande |
| 11 | Painel de pendências (integrar com CC existente) | E3 | Médio |
| 12 | Percepções/notas visíveis (47k registros, mostrar na ficha) | E3 | Pequeno |

### BLOCO 4: Central do Mentorado

| # | Item | Epic | Complexidade |
|---|------|------|-------------|
| 13 | Contexto onboarding na ficha (audios, percepções) | E1 | Médio |
| 14 | Comentários dentro do card mentorado | E1 | Grande |
| 15 | Campos financeiros (revisar o que já tem, completar) | E7 | Médio |

### BLOCO 5: Integrações

| # | Item | Epic | Complexidade |
|---|------|------|-------------|
| 16 | YouTube auto-upload (Zoom → YouTube) | E5 | Grande |
| 17 | Google Drive sync (pastas por mentorado) | E6 | Grande |
| 18 | Grupos WA em pastas/por fase | E3 | Médio |
| 19 | Acesso Mariza media (conectar storage Hetzner ao Evolution dela) | E3 | Pequeno |

### BLOCO 6: Alertas & Automação

| # | Item | Epic | Complexidade |
|---|------|------|-------------|
| 20 | Alertas etapa atrasada onboarding | E9 | Médio |
| 21 | Maestro privado (WA → tarefa, importar n8n) | E2 | Grande (80% pronto) |

---

## STATUS DE IMPLEMENTAÇÃO (2026-03-30)

| # | Item | Status | PR |
|---|------|--------|----|
| 1 | Download da semana | ✅ FEITO | #333 |
| 2 | Planejamento da semana | ✅ FEITO | #333 |
| 3 | Dossiês gargalados | ✅ FEITO | #333 |
| 4 | Mentorados sem call | ✅ FEITO | #333 |
| 5 | Datas internas/externas | ✅ FEITO | #333 |
| 6 | Etapas internas (prazos por etapa) | ✅ FEITO | #333 |
| 7 | Histórico de eventos | ✅ JÁ EXISTIA | ds_eventos + audit trail |
| 8 | Comentários dossiê | ✅ FEITO | #333 |
| 9 | Classificações frontend | ✅ FEITO | #333 (WA Intelligence) |
| 10 | Resumo semanal IA | ✅ FEITO | #333 (Gemini Flash) |
| 11 | Painel de pendências | ✅ FEITO | #333 (WA Intelligence) |
| 12 | Percepções visíveis | ✅ FEITO | #333 (WA Intelligence) |
| 13 | Contexto onboarding | ✅ FEITO | #333 |
| 14 | Comentários mentorado | ✅ FEITO | #333 |
| 15 | Campos financeiros | ✅ JÁ EXISTIA | Removido x-show CFO only |
| 16 | YouTube auto-upload | ✅ FEITO | #333 (precisa YOUTUBE_API_KEY) |
| 17 | Google Drive sync | ⏳ SCAFFOLD | Precisa google-auth lib no Railway |
| 18 | Grupos WA em pastas | ✅ FEITO | #333 (campo fase + view) |
| 19 | Acesso Mariza media | ⏳ CONFIG | Conectar Evolution dela ao Hetzner S3 |
| 20 | Alertas etapa atrasada | ✅ FEITO | #333 |
| 21 | Maestro privado | ⏳ N8N | Importar WF-02 manualmente |

**19/21 implementados. 2 pendentes de config externa (Google Drive lib, Maestro n8n).**

### Env vars necessárias no Railway
- `YOUTUBE_API_KEY` — pra YouTube upload funcionar
- `GOOGLE_DRIVE_FOLDER_ID` — pra Drive sync funcionar
- `EVOLUTION_API_KEY` = `E4F50E10-F3A6-4421-92F9-D486C2597C71` — já atualizado
