---
title: "Handoff — WhatsApp Intelligence Layer"
created: 2026-03-29
status: em_andamento
branch: main
last_pr: 325
---

# Handoff — Sessao 29/03/2026

## O que foi feito nessa sessao

### Epic WhatsApp Full Integration (12/12 stories COMPLETAS)
PRs #313, #314, #315, #316, #317

1. Mensagens em tempo real (Supabase Realtime)
2. Status de entrega (sent/delivered/read/failed)
3. Reply-to (responder mensagem especifica)
4. Send autenticado com audit trail + rate limiting
5. Media inline (imagem lightbox, audio player, video player, doc download)
6. Gravacao de audio pelo microfone
7. Paste imagem (Ctrl+V) + drag & drop
8. Gerenciamento de grupos (sync, criar, vincular ao mentorado)
9. Typing indicators ("digitando...")
10. Read receipts (IntersectionObserver)
11. Busca de mensagens (search bar no chat)
12. Chatwoot deprecated

### Ficha do Mentorado — WhatsApp integrado
PRs #318, #319, #320, #321

- Chat do WhatsApp direto na aba do mentorado (usa grupo vinculado via wa_groups)
- Media inline (audio, imagem, video, documento via S3 Hetzner stream proxy)
- Badge "X nao lidas" + "Sem resposta ha X dias" (detecta equipe por nome)
- Separadores de dia (Hoje, Ontem, Quarta, 24/03/2026)
- Campo de envio direto na ficha
- Aba "Mensagens" (Chatwoot) removida

### Board de Tarefas Unificado
PR #322

- 3 abas (Dela, Equipe, Queila) virou 1 board com 3 colunas
- Filtro pendentes/todas/concluidas
- Task modal auto-preenche mentorado quando aberto da ficha

### Migracao de fonte de dados
PR #324

- `wa_messages` (0 registros) DROPADA
- `whatsapp_messages` (58.975 registros) agora eh a fonte de verdade
- Views `vw_wa_topic_board` e `vw_wa_mentee_inbox` recriadas
- Realtime + RLS habilitados em `whatsapp_messages` e `interacoes_mentoria`
- Frontend todo apontando pra tabelas corretas

### Limpeza de dados
- 1.641 interacoes de 2025 com pendencia/negativo falsas → limpas
- 14 compromissos informais de 2025 → expirados
- Sentimentos negativos pre-marco → zerados
- 27 requer_resposta falsos → limpos

### Patches n8n (nao aplicados ainda)
PR #325 — docs/n8n-patches/

1. `PATCH-fallback-requer-resposta.json` — 10 regras (era 5)
2. `PATCH-classificar-enriquecer-completo.json` — ehDescartavel(), equipe nao gera pendencia, ehPerguntaReal mais restritivo

---

## Proximo passo IMEDIATO

**Aplicar os 2 patches no n8n Scraper v34:**
1. Abrir workflow no n8n
2. Node "[SAFETY] Fallback requer_resposta" → substituir jsCode pelo patch 1
3. Node "Classificar e Enriquecer Completo" → substituir jsCode pelo patch 2
4. Salvar e ativar
5. Testar com mensagens novas: "bom dia" deve virar tipo=social, nao gerar pendencia

---

## O que falta (Epic WA Intelligence Layer)

Doc completo: `docs/EPIC-WA-INTELLIGENCE-LAYER.md`

### Prioridade

1. **Aplicar patches n8n** ← PROXIMO (ops manual)
2. **Story 7** — Mapear interacoes_mentoria vs whatsapp_messages (feito parcialmente: schema mapeado, queries migradas)
3. **Story 2** — Painel de pendencias no Command Center (depende dos patches estarem aplicados pra ter dados limpos)
4. **Story 1** — Resumo semanal do mentorado
5. **Story 4** — Duvidas pendentes sem resposta
6. **Stories 3, 5, 6** — Timeline, notas, alertas
7. **Story 8** — Auditoria completa do workflow n8n (nodes desabilitados, gaps)

### Logica discutida mas nao implementada

- O WhatsApp nao eh so chat — eh centro nervoso da operacao (onboarding, direcionamentos, entregas, cobrancas, agenda, demandas, feedback)
- Pendencia = demanda REAL do mentorado que a equipe precisa responder (nao "bom dia", nao link, nao confirmacao)
- Ciclo de vida: wa_topics (open → active → resolved) deve governar pendencias
- Dados devem ter janela de relevancia (7-14 dias) — historico nao eh pendencia
- Classificacao precisa ser profunda antes de construir views no frontend

---

## Estado do banco Supabase (knusqfbvhsqworzyhvip)

| Tabela | Registros | Status |
|--------|-----------|--------|
| whatsapp_messages | 58.975 | FONTE DE VERDADE, Realtime ON |
| interacoes_mentoria | 28.849 | Classificadas por IA, 0 pendencias falsas |
| percepcoes_mentorado | 47.870 | Ativa (calls + bloqueios) |
| whatsapp_groups | 113 | Grupos com metadata |
| wa_groups | 0-N | Nossos vinculos grupo→mentorado |
| wa_topics | 121 | Topicos classificados (76 resolved) |
| compromissos_informais | 73 | 14 expirados, resto pendente |
| alertas_mensagens_pendentes | 76 | Alertas de fev-mar/2026 |
| wa_messages | DROPADA | N/A |

---

## Arquivos chave

- `app/frontend/11-APP-app.js` — toda logica WA (Realtime, media, send, reply, search, groups)
- `app/frontend/10-APP-index.html` — UI (chat, bubbles, status indicators, board tarefas)
- `app/frontend/13-APP-styles.css` — estilos WA (bubbles, lightbox, typing, search, groups)
- `app/backend/14-APP-server.py` — endpoints send/reply/media/groups/webhook
- `docs/EPIC-WA-INTELLIGENCE-LAYER.md` — epic completo (8 stories)
- `docs/n8n-patches/` — 2 patches JSON prontos pra n8n
