---
title: "Epic — Tarefas & Follow-up"
created: 2026-03-30
source: "Call Onboarding 27/03 + PRD Spalla V2"
status: draft
epic_id: TASK
stories: 10
tables:
  - god_tasks
  - god_task_subtasks
  - god_task_checklist
  - god_task_comments
  - god_task_handoffs
  - god_reminders
  - whatsapp_messages
  - interacoes_mentoria
---

# Epic — Tarefas & Follow-up

> "O tanto de coisa que se perde porque não tem follow-up é surreal."
> — Felipe Gobbi, call 27/03

## Principio

Tarefa no Spalla não é só checklist — é o motor da operação. Cada demanda do mentorado, cada ajuste de dossiê, cada follow-up que a equipe precisa fazer, tudo vira tarefa rastreável com responsável, prazo e notificação.

## Contexto técnico

- **god_tasks** — tabela principal (UUID, titulo, status, responsavel, mentorado_id, tags[], prioridade, data_fim, recorrencia, etc.)
- **god_task_subtasks** — subtarefas por task
- **god_task_checklist** — checklist items por task
- **god_task_comments** — comentários com author
- **god_reminders** — lembretes standalone
- **Frontend** — Alpine.js, taskForm com campos completos, board Kanban drag-and-drop
- **Backend** — Flask, Supabase REST API, ClickUp sync via operon_id

---

## SPRINT IMEDIATO (Semana 1)

### Story TASK-01: Tipos de tarefa estruturados

**Como** consultor, **quero** que cada tarefa tenha um tipo claro (dossiê, ajuste, follow-up, rotina, bug), **para que** eu possa filtrar e priorizar por natureza do trabalho.

**Contexto:** Hoje tags existem como TEXT[] livre. Não há campo `tipo` separado. O tipo governa comportamento (follow-up gera reminder, ajuste vincula ao dossiê, etc.)

#### Critérios de aceite
- [ ] Campo `tipo` (TEXT, CHECK IN) adicionado em god_tasks: `dossie`, `ajuste_dossie`, `follow_up`, `rotina`, `bug_report`, `geral`
- [ ] Migration SQL aplica ALTER TABLE com default `geral`
- [ ] Frontend: dropdown "Tipo" no taskForm (antes de tags)
- [ ] Frontend: filtro por tipo no board (chip/pill clicável)
- [ ] Frontend: ícone visual por tipo no card da tarefa (📋 dossiê, 🔄 follow-up, 🔧 ajuste, 📅 rotina, 🐛 bug)
- [ ] Tarefas existentes migram como `geral`

#### Escopo técnico
- `sql/migrations/XX-add-task-tipo.sql` — ALTER TABLE god_tasks ADD tipo
- `app/frontend/11-APP-app.js` — taskForm.tipo, filtro
- `app/frontend/10-APP-index.html` — dropdown tipo, ícone no card, filtro chips

---

### Story TASK-02: Ajuste de dossiê → tarefa automática

**Como** equipe de produção, **quero** que ao marcar um dossiê como "precisa ajuste", uma tarefa seja criada automaticamente com o contexto certo, **para que** nada se perca entre revisão e execução.

**Contexto:** Lara pediu explicitamente na call. Hoje, Keyla revisa, manda msg no grupo, e a equipe esquece. Precisa virar tarefa rastreável.

#### Critérios de aceite
- [ ] Botão "Criar tarefa de ajuste" no card de dossiê (ds_producoes)
- [ ] Tarefa criada com: tipo=`ajuste_dossie`, mentorado preenchido, titulo="Ajuste dossiê — {nome mentorado}", tag `ajuste-dossie`
- [ ] Descrição auto-preenchida: "Dossiê: {nome_dossie} | Etapa: {etapa_atual} | Solicitado por: {user}"
- [ ] Link do dossiê no campo doc_link
- [ ] Toast confirma criação + link pra abrir tarefa
- [ ] Aparece no board com ícone 🔧

#### Escopo técnico
- `app/frontend/10-APP-index.html` — botão no card dossiê
- `app/frontend/11-APP-app.js` — createAdjustmentTask(dossie)
- Usa god_tasks existente, sem backend novo

---

### Story TASK-03: Notificação WhatsApp ao criar tarefa

**Como** responsável por uma tarefa, **quero** receber uma mensagem no WhatsApp quando alguém cria uma tarefa pra mim, **para que** eu saiba imediatamente que tenho algo novo.

**Contexto:** Hoje tarefa é criada, mas o responsável só descobre quando abre o Spalla. Equipe trabalha pelo WhatsApp — precisa ser notificada lá.

#### Critérios de aceite
- [ ] Ao salvar tarefa com responsavel preenchido, dispara mensagem via Evolution API
- [ ] Mensagem formatada: "📋 Nova tarefa: {titulo}\n👤 De: {criador}\n📅 Prazo: {data_fim}\n🔗 {link_tarefa}"
- [ ] Lookup do número do responsável via spalla_members
- [ ] Notificação só dispara na criação (não na edição)
- [ ] Fallback silencioso se responsável não tem número cadastrado
- [ ] Rate limit respeitado (não duplicar se salvar 2x rápido)

#### Escopo técnico
- `app/backend/14-APP-server.py` — POST /api/tasks/notify ou hook no upsert
- Usa Evolution API send-text existente
- spalla_members precisa ter campo telefone/whatsapp_jid

#### Dependências
- spalla_members precisa ter JID/telefone mapeado (verificar schema atual)

---

## SPRINT CURTO (Semanas 2-3)

### Story TASK-04: Follow-up automático — msg → tarefa de checar

**Como** consultor, **quero** que ao enviar um follow-up pelo Spalla, o sistema crie automaticamente uma tarefa "checar resposta daqui X dias", **para que** nenhum follow-up fique sem acompanhamento.

**Contexto:** "O tanto de coisa que se perde porque não tem follow-up é surreal." Hoje manda msg e esquece. Precisa de lembrete automático.

#### Critérios de aceite
- [ ] Checkbox "Criar follow-up" no campo de envio de mensagem WA (dentro da ficha e no chat geral)
- [ ] Ao marcar, aparece: "Checar em: [2] dias" (input numérico, default 2)
- [ ] Ao enviar a mensagem, cria god_task com: tipo=`follow_up`, titulo="Follow-up — {mentorado}", data_fim=hoje+X dias, responsavel=quem enviou
- [ ] Descrição: "Mensagem enviada: '{preview 100 chars}' em {data}"
- [ ] Tag automática: `follow-up`
- [ ] Tarefa aparece no board e no Command Center como pendência
- [ ] Ao concluir tarefa de follow-up, sistema sugere: "Mentorado respondeu?" (sim/não)

#### Escopo técnico
- `app/frontend/11-APP-app.js` — waFollowupEnabled, waFollowupDays, lógica no sendWhatsAppMessage() e sendDetailWaMessage()
- `app/frontend/10-APP-index.html` — checkbox + input dias
- Criação direto via Supabase (god_tasks), sem endpoint novo

---

### Story TASK-05: Status da tarefa vinculado ao follow-up

**Como** consultor, **quero** que quando o mentorado responde após um follow-up, a tarefa de follow-up seja atualizada automaticamente, **para que** eu não precise fechar manualmente cada uma.

**Contexto:** Se mandei follow-up e criei tarefa "checar em 2 dias", e o mentorado responde no dia seguinte, a tarefa deveria refletir isso.

#### Critérios de aceite
- [ ] Tarefa de follow-up (tipo=`follow_up`) tem campo `follow_up_group_jid` (grupo WA do mentorado)
- [ ] Listener Realtime: quando chega mensagem nova no grupo do mentorado, verifica se existe follow-up pendente pra ele
- [ ] Se sim: marca tarefa como "respondido" (comentário automático: "Mentorado respondeu em {data}" + preview da msg)
- [ ] Tarefa NÃO é fechada automaticamente — só sinalizada. Consultor decide se resolve ou precisa de ação
- [ ] Badge visual "✉️ respondeu" no card da tarefa

#### Escopo técnico
- `sql/migrations/XX-task-followup-fields.sql` — ADD follow_up_group_jid, follow_up_responded_at
- `app/frontend/11-APP-app.js` — Realtime subscription verifica follow-ups pendentes
- `app/frontend/10-APP-index.html` — badge "respondeu" no card

#### Dependências
- Story TASK-04 (follow-up automático precisa existir)

---

### Story TASK-06: Follow-up em bloco (10 mentorados de uma vez)

**Como** consultor, **quero** selecionar vários mentorados e disparar follow-up em bloco, **para que** na segunda-feira eu faça todos os follow-ups em 5 minutos em vez de 1 hora.

**Contexto:** Heitor precisa fazer follow-up com 10-15 mentorados toda segunda. Hoje é 1 a 1. Precisa de batch.

#### Critérios de aceite
- [ ] Novo botão "Follow-up em bloco" no Command Center
- [ ] Abre modal com lista de mentorados: checkbox + preview da última interação + dias sem resposta
- [ ] Lista pré-filtrada: mentorados com >3 dias sem resposta da equipe
- [ ] Mensagem template editável com variáveis: {nome}, {ultima_interacao}
- [ ] Preview antes de enviar: mostra cada mensagem personalizada
- [ ] Ao confirmar: envia N mensagens via Evolution API + cria N tarefas follow-up (TASK-04)
- [ ] Barra de progresso: "Enviando 7/10..."
- [ ] Resumo final: "10 follow-ups enviados, 10 tarefas criadas"

#### Escopo técnico
- `app/frontend/11-APP-app.js` — bulkFollowup state, bulkFollowupSend()
- `app/frontend/10-APP-index.html` — modal follow-up em bloco
- `app/backend/14-APP-server.py` — POST /api/wa/bulk-send (loop send-text com rate limit)
- Usa dados de vw_wa_mentee_inbox ou query direta whatsapp_messages

#### Dependências
- Story TASK-04 (follow-up automático)
- Story TASK-03 (notificação WA — compartilha infra de envio)

---

## SPRINT MÉDIO (Semanas 4-7)

### Story TASK-07: Criação em batelada (audio → N tarefas)

**Como** consultor, **quero** gravar um audio descrevendo várias demandas e o sistema criar todas as tarefas automaticamente, **para que** eu não precise digitar cada uma.

**Contexto:** Heitor sai de uma call e tem 5-6 ações pra registrar. Digitar cada uma é lento. Quer falar num audio e o sistema interpretar.

#### Critérios de aceite
- [ ] Botão "Criar tarefas por áudio" no board de tarefas e no Command Center
- [ ] Grava audio via MediaRecorder (já existe no chat WA — reutilizar)
- [ ] Envia audio pro backend → transcreve (Whisper via n8n ou direto)
- [ ] IA extrai N tarefas do texto: titulo, responsável (se mencionado), mentorado (se mencionado), prioridade, prazo estimado
- [ ] Preview editável: lista de tarefas extraídas, cada uma com campos editáveis
- [ ] "Confirmar todas" → cria N god_tasks de uma vez
- [ ] "Editar" individual antes de confirmar
- [ ] "Descartar" individual

#### Escopo técnico
- `app/backend/14-APP-server.py` — POST /api/tasks/from-audio (recebe audio, transcreve, extrai tarefas)
- Transcrição: Whisper API ou n8n workflow existente
- Extração: prompt Gemini Flash (barato, rápido) com schema JSON de saída
- `app/frontend/11-APP-app.js` — batchTaskFromAudio(), batchTaskPreview[]
- `app/frontend/10-APP-index.html` — modal batch + cards editáveis

#### Dependências
- Story TASK-01 (tipos de tarefa — pra classificar automaticamente)

---

### Story TASK-08: Maestro privado — WhatsApp → tarefa com contexto

**Como** consultor, **quero** encaminhar uma mensagem do grupo do mentorado pro Maestro privado e ele criar uma tarefa com todo o contexto, **para que** eu não precise copiar/colar nada.

**Contexto:** Fase 3 do plano de execução. Maestro tem 80% pronto (workflows n8n, prompts, schema SQL já aplicado). Falta: importar workflows + configurar webhook.

#### Critérios de aceite
- [ ] Consultor encaminha mensagem (texto ou audio) pro número do Maestro no WhatsApp
- [ ] Maestro detecta intent "criar tarefa" (WF-02-task-engine + 02-task-agent.txt)
- [ ] Extrai: titulo, mentorado (pelo grupo de origem), responsável, prioridade
- [ ] Se audio: transcreve primeiro, depois extrai
- [ ] Cria god_task no Supabase com tipo inferido e contexto completo
- [ ] Responde no WhatsApp: "✅ Tarefa criada: {titulo} | Responsável: {nome} | Prazo: {data}"
- [ ] Link clicável pro Spalla (deep link)

#### Escopo técnico
- **n8n:** Importar WF-02-task-engine de ~/Downloads/hive/maestro/pacote-completo/
- **n8n:** Configurar webhook Evolution → Maestro
- **Prompt:** 02-task-agent.txt (já existe)
- **Supabase:** maestro_agent_log (registra ação), god_tasks (cria tarefa)
- **Frontend:** nenhuma mudança (tarefa aparece via Realtime)

#### Dependências
- Maestro workflows importados no n8n
- Webhook Evolution configurado
- Story TASK-01 (tipos de tarefa)

---

### Story TASK-09: Notificação de tarefa inteligente (responsável + mentorado)

**Como** sistema, **quero** notificar tanto o responsável quanto opcionalmente o mentorado quando uma tarefa relevante é criada ou atualizada, **para que** todos os envolvidos saibam o que está acontecendo.

**Contexto:** Expansão da TASK-03. Além de notificar equipe, certas tarefas (tipo=`dossie`, `follow_up`) podem notificar o mentorado também.

#### Critérios de aceite
- [ ] Regras de notificação por tipo de tarefa:
  - `follow_up` → notifica responsável (equipe) sempre
  - `dossie` / `ajuste_dossie` → notifica responsável + opcional mentorado (toggle)
  - `rotina` → notifica responsável
  - `bug_report` → notifica responsável
- [ ] Toggle "Notificar mentorado" no taskForm (aparece quando tipo = dossie/ajuste)
- [ ] Mensagem pro mentorado: formatação amigável, sem jargão interno
- [ ] Notificação de mudança de status: quando tarefa passa pra "concluída", notifica interessados
- [ ] Log de notificações: god_task_notifications (task_id, destinatario, canal, enviado_em)

#### Escopo técnico
- `sql/migrations/XX-task-notifications-log.sql` — tabela god_task_notifications
- `app/backend/14-APP-server.py` — lógica de notificação por tipo + endpoint /api/tasks/{id}/notify
- `app/frontend/10-APP-index.html` — toggle no form

#### Dependências
- Story TASK-01 (tipos)
- Story TASK-03 (infra de notificação WA)

---

### Story TASK-10: View de feedback/bug reports (inbox separado)

**Como** membro da equipe, **quero** um canal interno pra reportar bugs, sugestões e problemas sem criar tarefa diretamente, **para que** a equipe técnica triagem e priorize antes de virar tarefa na esteira.

**Contexto:** Felipe pediu na call: "Criar um cardzinho pra vocês registrarem os erros." Kaique definiu que NÃO deve ser tarefa — é inbox separado. Equipe descarrega (audio, print, texto), gente prioriza e transforma em tarefas.

#### Critérios de aceite
- [ ] Nova seção "Feedback" no menu lateral (ícone 💬)
- [ ] Formulário simples: titulo, descrição, categoria (bug, sugestão, feature), prioridade sentida
- [ ] Upload de mídia: print (paste/drag), audio (gravar), video (upload)
- [ ] Lista de feedbacks com filtro por categoria e status (novo, em_analise, convertido, descartado)
- [ ] Ação "Converter em tarefa" → abre taskForm preenchido com dados do feedback, tipo=`bug_report`
- [ ] Ação "Descartar" com motivo
- [ ] Feedback NÃO aparece no board de tarefas (é separado)
- [ ] Qualquer membro da equipe pode criar feedback (sem autenticação extra)

#### Escopo técnico
- `sql/migrations/XX-feedback-inbox.sql` — tabela god_feedback (id, titulo, descricao, categoria, prioridade, status, media_urls[], created_by, created_at, converted_task_id)
- `app/frontend/11-APP-app.js` — feedbackList, feedbackForm, submitFeedback(), convertFeedbackToTask()
- `app/frontend/10-APP-index.html` — página Feedback, formulário, lista
- `app/backend/14-APP-server.py` — upload media via S3 Hetzner (reutiliza infra WA)

---

## Mapa de dependências

```
TASK-01 (tipos) ─────────────────┬──────────────┬──────────────┐
                                 │              │              │
TASK-02 (ajuste→tarefa)    TASK-07 (batch)  TASK-08 (Maestro)  │
                                                               │
TASK-03 (notif WA) ──────────────┬─────────────────── TASK-09 (notif inteligente)
                                 │
TASK-04 (follow-up auto) ───── TASK-05 (status vinculado)
         │
         └──────────── TASK-06 (follow-up bloco)

TASK-10 (feedback inbox) — independente, pode ser feito em paralelo
```

## Status de implementação (2026-03-30)

| Story | Status | PR |
|-------|--------|----|
| TASK-01 | ✅ FEITO | #329 |
| TASK-02 | ✅ FEITO | #329 |
| TASK-03 | ✅ FEITO | #329, #330 |
| TASK-04 | ✅ FEITO | #329 |
| TASK-05 | ✅ FEITO | #329 |
| TASK-06 | ✅ FEITO | #329 |
| TASK-07 | ✅ FEITO | #330 |
| TASK-08 | PENDENTE | Depende de importar workflows Maestro no n8n |
| TASK-09 | ✅ FEITO | #330 |
| TASK-10 | ✅ FEITO | #329 |

**9/10 stories implementadas.** TASK-08 requer ação manual no n8n (importar WF-02-task-engine + configurar webhook Evolution).

## Resumo de priorização

| Sprint | Stories | Semanas | Impacto |
|--------|---------|---------|---------|
| Imediato | TASK-01, TASK-02, TASK-03 | 1 | Estrutura tipos + ajuste dossiê + notificação |
| Curto | TASK-04, TASK-05, TASK-06 | 2-3 | Follow-up automático + batch |
| Médio | TASK-07, TASK-08, TASK-09, TASK-10 | 4-7 | Audio→tarefas, Maestro, notif inteligente, feedback |

## Estimativa de complexidade

| Story | Backend | Frontend | SQL | n8n | Total |
|-------|---------|----------|-----|-----|-------|
| TASK-01 | - | Médio | Simples | - | Pequeno |
| TASK-02 | - | Médio | - | - | Pequeno |
| TASK-03 | Médio | Simples | Simples | - | Médio |
| TASK-04 | - | Médio | - | - | Médio |
| TASK-05 | - | Médio | Simples | - | Médio |
| TASK-06 | Médio | Alto | - | - | Grande |
| TASK-07 | Alto | Alto | - | Médio | Grande |
| TASK-08 | - | - | - | Alto | Grande (mas 80% pronto) |
| TASK-09 | Médio | Simples | Simples | - | Médio |
| TASK-10 | Médio | Alto | Simples | - | Grande |
