---
title: "EPIC: WhatsApp Intelligence Layer — Conectar n8n com Frontend"
status: draft
created: 2026-03-29
owner: kaique
priority: urgente
---

# EPIC: WhatsApp Intelligence Layer

> O n8n ja faz o trabalho pesado (classificacao, extracao, alertas).
> O que falta e MOSTRAR isso no dashboard de forma util pro consultor.
> Zero TypeScript novo. Zero system prompts novos. Conectar o que existe.

## Principio

O workflow "Scraper v34" (169 nos) ja:
- Classifica mensagens por categoria (duvida, metrica, celebracao, agendamento, etc)
- Extrai tarefas, notas e lembretes
- Detecta urgencias e envia alertas WhatsApp
- Registra percepcoes sobre o mentorado
- Analisa imagens e documentos com IA
- Transcreve audios
- Responde duvidas automaticamente via agente

**O que falta:** o frontend nao usa esses dados. O consultor abre o Spalla e nao ve nada disso.

## O que ja existe no Supabase (populado pelo n8n)

| Tabela | O que tem | Usado no frontend? |
|--------|-----------|---------------------|
| `wa_messages` | Todas as mensagens classificadas | SIM (chat WA) |
| `wa_topics` | Topicos agrupados por IA | SIM (board topicos) |
| `wa_topic_types` | Tipos de topico (taxonomia) | SIM (filtros) |
| `wa_topic_events` | Eventos dos topicos | NAO |
| `interacoes_mentoria` | Classificacao por categoria | NAO |
| `god_tasks` | Tarefas extraidas das conversas | PARCIAL (board tarefas) |
| `god_reminders` | Lembretes extraidos | PARCIAL (page lembretes) |
| `chat_history` | Historico de conversas com agente | NAO |

## Stories

### STORY 1: Resumo Semanal do Mentorado (AI Digest)

**O que:** Na ficha do mentorado, mostrar um resumo automatico da semana.
**De onde vem:** `wa_messages` + `wa_topics` + `interacoes_mentoria` filtrados por mentorado_id e ultima semana.
**Como:** Nova query no frontend que monta o digest a partir dos dados JA existentes.
**Nao precisa:** Nenhum novo node no n8n. Os dados ja estao no banco.

Exibir na aba Resumo:
- Ultimas interacoes relevantes (nao spam/oi/bom dia)
- Topicos abertos (duvidas, pedidos, travas)
- Tarefas criadas/concluidas na semana
- Alertas e percepcoes registradas
- Tempo medio de resposta da equipe
- Proximos compromissos

**Arquivos:** 11-APP-app.js, 10-APP-index.html

---

### STORY 2: Painel de Pendencias (o que cobrar na segunda)

**O que:** Tela que mostra POR MENTORADO o que esta pendente.
**De onde vem:**
- `god_tasks` com status pendente + mentorado_nome
- `wa_topics` com status open + sentiment negativo/critico
- `wa_messages` ultimas mensagens sem resposta da equipe
- `interacoes_mentoria` com requer_resposta = true

**Como:** View no Supabase ou query composta no frontend.
**Exibir no Command Center** como card "Pendencias da Semana":
- Lista de mentorados com pendencias
- Por cada um: o que ta pendente, ha quanto tempo, quem deveria ter respondido
- Acao rapida: clicar → abre ficha do mentorado na aba certa

**Arquivos:** 11-APP-app.js, 10-APP-index.html, possivelmente SQL view

---

### STORY 3: Timeline de Atividade do Mentorado

**O que:** Na ficha do mentorado, aba Timeline que ja existe (45 itens), incluir eventos do WA.
**De onde vem:**
- `interacoes_mentoria` (classificacoes: duvida, metrica, celebracao, etc)
- `wa_topic_events` (mudancas de status dos topicos)
- `god_tasks` (criacao/conclusao de tarefas)
- `calls_mentoria` (calls realizadas)

**Como:** Merge de todas as fontes num array ordenado por data.
**Exibir como timeline cronologica** com icones por tipo:
- 💬 Mensagem relevante
- ❓ Duvida levantada
- ✅ Tarefa concluida
- 📞 Call realizada
- 🎯 Metrica de venda
- 🚨 Alerta de urgencia
- 📝 Nota/percepcao da equipe

**Arquivos:** 11-APP-app.js, 10-APP-index.html

---

### STORY 4: Duvidas Pendentes (sem resposta da equipe)

**O que:** O n8n ja detecta duvidas e marca como pendentes. Mostrar no dashboard.
**De onde vem:** `interacoes_mentoria` com eh_duvida = true e respondida = false
**Ou:** query que o n8n ja faz: "Buscar Dúvidas Pendentes Grupo"

**Como:** Card no Command Center + badge na ficha do mentorado
- Quantas duvidas sem resposta por mentorado
- Texto da duvida
- Ha quanto tempo esperando
- Quem e o consultor responsavel

**Arquivos:** 11-APP-app.js, 10-APP-index.html, possivelmente SQL view

---

### STORY 5: Notas e Percepcoes (anotacoes do consultor)

**O que:** O n8n tem tools `registrarPercepcao` e `buscarPercepcoes`. Mostrar e permitir criar no dashboard.
**De onde vem:** Tabela que o tool `registrarPercepcao` usa
**Como:** Na ficha do mentorado, secao de notas/percepcoes
- Listar percepcoes existentes (criadas pelo agente ou pela equipe)
- Permitir criar nova percepcao manual (campo de texto + tipo)
- Tipos: observacao, insight, alerta, decisao

**Arquivos:** 11-APP-app.js, 10-APP-index.html

---

### STORY 6: Alertas e Urgencias no Command Center

**O que:** O n8n ja envia alertas WhatsApp pra Queila. Mostrar no dashboard tambem.
**De onde vem:** Tabela de alertas (o n8n registra via "Registrar Alerta" node)
**Como:** Card no Command Center:
- Alertas criticos (mentorado sumiu, insatisfacao, trava grave)
- Alertas de inatividade (grupos sem interacao)
- Mentorados sem call ha mais de X dias
- Promessas da equipe nao cumpridas

**Arquivos:** 11-APP-app.js, 10-APP-index.html

---

### STORY 7: Conectar `interacoes_mentoria` com categorias do n8n

**O que:** Verificar schema da tabela `interacoes_mentoria`, mapear campos com o que o n8n grava.
**Acao:**
1. Ler schema atual de `interacoes_mentoria`
2. Verificar quais campos o n8n popula (via Salvar Interação Classificada)
3. Criar SQL view `vw_wa_mentee_activity` que unifica wa_messages + interacoes_mentoria + wa_topics
4. Usar essa view no frontend pra alimentar Stories 1-6

**Arquivos:** SQL migration, 11-APP-app.js

---

### STORY 8: Revisar/Otimizar nodes n8n

**O que:** Revisar o workflow v34 e sugerir:
- Nodes desabilitados que deveriam estar ativos (ex: Criar Evento Compromisso, Salvar Compromissos)
- Gaps: dados que o n8n extrai mas nao salva no Supabase
- Classificacoes que poderiam alimentar campos no frontend
- System prompts que precisam de ajuste

**NAO e reescrever.** E auditoria + sugestoes pontuais de nodes.

**Entregavel:** Documento com recomendacoes + patches pro workflow

---

## Abordagem tecnica

```
n8n (JA RODA)          Supabase (JA TEM DADOS)          Frontend (CONECTAR)
  |                           |                               |
  | webhook Evolution         | wa_messages                   | selectWhatsAppChat()
  | → classifica              | wa_topics                     | _loadDetailWaMessages()
  | → extrai tarefas          | interacoes_mentoria           | loadDashboard()
  | → detecta urgencias       | god_tasks                     | Command Center cards
  | → registra percepcoes     | god_reminders                 |
  | → salva tudo ↓            | wa_topic_events               |
  |                           | alertas                        |
  └───────────────────────────┘                               |
                                    ← QUERY DIRETO ───────────┘
```

**Zero nova API backend.** O frontend ja fala com Supabase direto (anon key).
Precisa: queries SQL certas + componentes HTML/Alpine.js.

## Prioridade

1. Story 7 primeiro (mapear o que existe) — sem isso nao da pra fazer nada
2. Story 2 (Pendencias) — impacto imediato pro dia a dia
3. Story 1 (Resumo Semanal) — valor mais alto pro consultor
4. Story 4 (Duvidas Pendentes) — gap critico
5. Story 3, 5, 6 — complementam
6. Story 8 — otimizacao

## Remover

- [x] Aba "Mensagens" (Chatwoot) — substituida por WhatsApp
