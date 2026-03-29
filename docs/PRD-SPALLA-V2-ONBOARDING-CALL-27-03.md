---
title: "PRD Spalla V2 — Extraido da Call de Onboarding 27/03"
created: 2026-03-29
source: "Check Onboarding Spalla - March 27 (90 min)"
participantes: Felipe Gobbi, Kaique Rodrigues, Heitor Sarmenghi, Lara Santos, Mariza Ribeiro
status: draft
---

# PRD Spalla V2 — Levantamento Completo

> Extraido da call de onboarding de 27/03/2026.
> Tudo que foi discutido, pedido, sugerido — com status do que ja foi feito.

---

## PRINCIPIO CENTRAL

**"Clicar no mentorado e ter TUDO ali."**
— Felipe Gobbi

O Spalla e um CRM de pos-venda (CS). Da venda em diante. Tudo que envolve o mentorado tem que estar debaixo dele: mensagens, calls, dossies, tarefas, documentos, financeiro, contexto.

---

## EPIC 1: CENTRAL DO MENTORADO

> "Quero entrar na pasta da Betina e saber tudo sobre ela."

### 1.1 Ficha unificada
| Item | Status | Notas |
|------|--------|-------|
| Todas as calls vinculadas ao card | PARCIAL | Funciona quando email/nome bate. Gap com mentorados novos |
| Ultimas mensagens do WhatsApp | ✅ FEITO | PR #318 — chat integrado na aba WA |
| Status dos dossies por etapa | PARCIAL | View de producao existe mas falta etapas internas |
| Tarefas (dela, equipe, Queila) | ✅ FEITO | PR #322 — board unificado 3 colunas |
| Documentos / Google Drive linkado | PARCIAL | Retroativo importado, falta sync automatico |
| Financeiro (pagamento, contrato, inadimplencia) | NAO | Precisa campos + integracao |
| Contexto de onboarding (audios, percepcoes) | PARCIAL | percepcoes_mentorado tem dados, falta mostrar |
| Depoimentos | NAO | Precisa upload + vinculacao |

### 1.2 Datas internas vs externas
- **Data externa:** prazo comunicado ao mentorado (3 semanas pos-call)
- **Data interna:** prazo real da equipe (2 semanas)
- Precisa de 2 campos de data no card de dossie
- Historico de eventos: "dia 25 Keyla revisou, pediu ajustes"

### 1.3 Comentarios e discussao dentro do card
- Modelo ClickUp: comentarios um embaixo do outro
- Audio, video, texto, prints
- Toda discussao sobre dossie da Debora → dentro do card da Debora
- "Nada de grupo, nada, esquece, so ali dentro"

---

## EPIC 2: TAREFAS E FOLLOW-UP

> "O tanto de coisa que se perde porque nao tem follow-up e surreal."

### 2.1 Follow-up automatico
| Item | Status |
|------|--------|
| Mandou follow-up → cria tarefa "checar daqui 2 dias" | NAO |
| Bloco de follow-up: fazer com 10 mentorados de uma vez | NAO |
| Status da tarefa vinculado ao follow-up | NAO |
| Mensagens disparadas de dentro do Spalla | ✅ FEITO | PR #313 — send autenticado |

### 2.2 Criacao de tarefas
| Item | Status |
|------|--------|
| Criar tarefa de dentro do card do mentorado | ✅ FEITO | PR #320 — auto-preenche mentorado |
| Criar em batelada (descarregar audio → AI cria varias) | NAO |
| Tag/tipo de tarefa: dossiê, ajuste, follow-up, rotina | PARCIAL | Tags existem, tipos nao |
| Checklists dentro da tarefa | EXISTE | Ja tem no sistema |
| Subtarefas | EXISTE | Ja tem |
| Recorrencia (toda segunda follow-up) | EXISTE | Campo recorrencia ja existe |
| Link compartilhavel da tarefa | ✅ FEITO | Sessao anterior |

### 2.3 Maestro privado (WhatsApp → Tarefa)
| Item | Status |
|------|--------|
| Mandar audio/texto no privado do Maestro | PARCIAL | Scraper v34 tem agente de tarefa |
| Copiar mensagem do grupo → encaminhar pro Maestro | NAO |
| ID do grupo capturado automaticamente | NAO |
| Transcreve audio + cria tarefa com contexto | PARCIAL | Transcricao existe mas nao vincula |
| Notifica responsavel no WhatsApp | PARCIAL | Alertas existem, nao para tarefas |

---

## EPIC 3: WHATSAPP COMPLETO

> "A gente transicionar todos esses pontos pra la vai ser muito bom."

### 3.1 Chat e comunicacao
| Item | Status |
|------|--------|
| Mensagens em tempo real | ✅ FEITO | PR #313 — Supabase Realtime |
| Responder por dentro do Spalla | ✅ FEITO | PR #313 — send + reply |
| Ver imagens, audio, video, docs | ✅ FEITO | PR #314, #319 — media inline |
| Gravar audio pelo dashboard | ✅ FEITO | PR #314 |
| Colar imagem (Ctrl+V) | ✅ FEITO | PR #314 |
| Busca de mensagens | ✅ FEITO | PR #314 |
| Grupos organizados em pastas/por fase | NAO |
| Grupos internos (equipe) tambem | NAO |
| Status de entrega (checkzinho azul) | ✅ FEITO | PR #313 |
| Indicador "digitando" | ✅ FEITO | PR #314 |

### 3.2 Inteligencia sobre mensagens
| Item | Status |
|------|--------|
| Classificacao por categoria (duvida, metrica, etc) | ✅ EXISTE | n8n Scraper v34 — 28k registros |
| Deteccao de urgencia + alertas | ✅ EXISTE | n8n envia alerta WhatsApp |
| Mostrar classificacoes no frontend | NAO | Epic WA Intelligence Layer |
| Resumo semanal por mentorado | NAO | Story 1 do epic |
| Painel de pendencias (o que cobrar na segunda) | NAO | Story 2 do epic |
| Duvidas sem resposta | NAO | Story 4 do epic |
| Percepcoes e notas | PARCIAL | 47k no banco, nao mostra |

### 3.3 Conexao WhatsApp pessoal
| Item | Status |
|------|--------|
| Cada consultor conecta seu proprio WhatsApp | PARCIAL | Funciona, mas tem gaps de media |
| Telefone central (azulzinho) como fallback | ✅ FEITO | producao002 |
| Mariza acesso ao banco de media | NAO | Precisa liberar |

---

## EPIC 4: DOSSIES E PRODUCAO

> "Cara, pra eu buscar um dossie hoje, eu vou la no painel, desco aquela planilha inteira..."

### 4.1 Fluxo de producao
| Item | Status |
|------|--------|
| View de etapas (producao AI → revisao Mariza → revisao Keyla → aprovado → enviado) | PARCIAL | Board existe, falta etapas internas |
| Prazos internos por etapa | NAO |
| Data de entrega pro mentorado | PARCIAL | Tem data mas sem logica interna/externa |
| Historico de eventos (quem fez o que, quando) | NAO |
| Ajustes viram tarefa automaticamente | NAO | Lara pediu: tag "ajuste dossie" → tarefa |
| Comentarios dentro do card de dossie | NAO |

### 4.2 Apresentacao visual
| Item | Status |
|------|--------|
| Site de apresentacao cinematica | EM ANDAMENTO | FunnelCase separado |
| Manuais em PDF/visual (nao a calhamaco) | EM ANDAMENTO |
| Mentorado acessa pelo Operon dele | NAO |

### 4.3 Edicao de dossie
| Item | Status |
|------|--------|
| Editar dossie dentro do Spalla (como Google Docs) | PARCIAL | Markdown editor existe |
| Comentarios, marcacoes, revisao | NAO |
| Sair do Google Docs de vez | FUTURO | Transicao gradual |

---

## EPIC 5: CALLS E AGENDA

> "20 segundos pra agendar uma call."

### 5.1 Agendamento
| Item | Status |
|------|--------|
| Agendar pelo Spalla → cria Zoom | ✅ FEITO | Ja funciona |
| Criar Google Calendar automaticamente | PARCIAL | Integrado mas com gaps |
| Convite pro mentorado automatico | NAO |
| Tipos de call: onboarding, acompanhamento, estrategia, adjudicacao | PARCIAL | 3 tipos, falta adjudicacao |

### 5.2 Vinculacao
| Item | Status |
|------|--------|
| Calls vinculadas ao card do mentorado | PARCIAL | Funciona quando email bate |
| Fix: mentorados novos sem call vinculada | NAO | Gap de matching por email/nome |
| Transcrição automatica | ✅ FEITO | Zoom → transcricao |
| Subir no YouTube automaticamente | NAO | Precisa chave API YouTube |

---

## EPIC 6: DOCUMENTOS E WIKI

> "Centralizar o fulano, tudo que for relacionado a ele esta ali."

| Item | Status |
|------|--------|
| Pastas por mentorado com docs linkados | PARCIAL | Retroativo importado |
| Sync automatico Google Drive → Spalla | NAO |
| Wiki interna (manuais, processos) | NAO |
| Versionamento de manuais (v1, v2, v3) | NAO |
| Subir depoimentos por mentorado | NAO |

---

## EPIC 7: FINANCEIRO

| Item | Status |
|------|--------|
| Data de pagamento no card | NAO |
| Status do contrato (assinado, pendente) | NAO |
| Inadimplencia (atrasado X dias) | NAO |
| Vincular contrato ao check de onboarding | NAO |

---

## EPIC 8: COMMAND CENTER / COCKPIT

> "Heitor vai entrar todo dia, vai ter um cockpit ali."

| Item | Status |
|------|--------|
| Painel do consultor (minhas pendencias hoje) | PARCIAL | Tem cards mas falta WA intelligence |
| Mensagens nao vistas por mentorado | ✅ FEITO | PR #319 — badge unread |
| Tempo sem resposta por mentorado | ✅ FEITO | PR #319 — badge sem resposta |
| Dossies gargalados (prazo passando) | NAO |
| Mentorados sem call ha X dias | NAO |
| Sprint da semana (o que fazer) | PARCIAL | Sprint view existe |
| Download da semana (sexta: descarregar contexto) | NAO |
| Planejamento da semana (segunda: o que priorizar) | NAO |

---

## EPIC 9: ONBOARDING

| Item | Status |
|------|--------|
| Template de etapas editavel | EXISTE | Template ja funciona |
| Alertas quando etapa esta atrasada | NAO |
| Review dos templates com Lara e Heitor | NAO | Action item da call |

---

## EPIC 10: CANAL DEV / BUG REPORTS

> "Criar um cardzinho pra vocês registrarem os erros."

| Item | Status |
|------|--------|
| Canal interno pra reportar bugs | NAO |
| Categorias: bug, sugestao, feature | NAO |
| Anexar print, audio, video | NAO |

---

## PRIORIZACAO SUGERIDA

### Sprint imediato (proxima semana)
1. **Aplicar patches n8n** — classificador melhorado (ja pronto)
2. **Fix call matching** — mentorados novos sem call vinculada
3. **Ajustes dossie → tarefa** — tag "ajuste dossie" cria tarefa automatica
4. **Liberar acesso Mariza** — media no WhatsApp

### Sprint curto (2 semanas)
5. **Command Center v2** — pendencias da semana, dossies gargalados
6. **Follow-up automatico** — manda msg → cria tarefa de checar em X dias
7. **Datas internas/externas** no dossie
8. **Google Drive sync** — pastas por mentorado

### Sprint medio (1 mes)
9. **Maestro privado** — audio/texto → tarefa automatica
10. **Criacao em batelada** — descarregar audio → N tarefas
11. **Financeiro basico** — pagamento, contrato, inadimplencia
12. **Resumo semanal IA** — digest automatico por mentorado

### Futuro
13. **Wiki interna** — manuais, processos, versionamento
14. **Edicao de dossie** — sair do Google Docs
15. **Apresentacao visual** — FunnelCase integrado
16. **YouTube auto-upload** — Zoom → YouTube
17. **Canal dev interno** — bug reports

---

## ACTION ITEMS DA CALL (Fathom)

1. Liberar acesso WhatsApp da Mariza (media/audio)
2. Investigar call nao vinculada da Lidiane (novo produto, pulou onboarding)
3. Integrar ajustes de dossie no fluxo de tarefas + @mentions + alertas WhatsApp
4. Definir quem atualiza status no Operon pra revisoes da Keyla
5. Entregar dossie marketing da Lidiane + enviar formulario de coleta
6. Revisar dossie funil de aula da Debora + enviar dossie da Daniela
7. Criar canal "Dev/Tech" pra bug reports + postar instrucoes
8. Pegar chave API YouTube + implementar Zoom → YouTube upload
9. Agendar review de templates de onboarding com Lara e Heitor
10. Adicionar campos financeiros (pagamento, contrato) ao card do mentorado
11. Remover label "Minhas Tarefas" redundante dentro do card
12. Construir Maestro privado pra criacao de tarefas por audio/texto
