---
title: "Plan: Google Calendar Integration"
type: plan
status: approved
spec: "docs/specs/google-calendar-integration-spec.md"
author: "feature/case/google-calendar-integration"
date: "2026-03-16"
---

# Plan: Google Calendar Integration

## Overview

Corrige dois bugs críticos que tornam a integração com Google Calendar inoperante em
produção, e adiciona as funcionalidades ausentes de visibilidade na Agenda e
cancelamento de eventos.

- **Spec**: `docs/specs/google-calendar-integration-spec.md`
- **Esforço Total**: M (1-2 dias)
- **Branch**: `feature/case/google-calendar-integration`

---

## Fase 1 — Bugfixes + Configuração

**Goal**: Fazer a integração funcionar em produção (Hetzner Docker) sem alterar
comportamento local.

**Esforço**: S

### Passos

1. **Fix field name mismatch** — em `_handle_create_calendar_event()` (linha 974),
   alterar `body.get('start', '')` → `body.get('start_iso', '')` e
   `body.get('end', '')` → `body.get('end_iso', '')`.

2. **Suporte a `GOOGLE_SA_JSON`** — em `get_gcal_service()` (linha 305), antes de
   verificar o arquivo, checar se `GOOGLE_SA_JSON` está definida no ambiente. Se sim,
   decodificar base64, parsear JSON, criar credenciais `from_service_account_info()`.
   Fallback para `GOOGLE_SA_PATH` se `GOOGLE_SA_JSON` não estiver definida.

3. **`GOOGLE_SA_PATH` via env var** — substituir o path hardcoded (linha 59) por
   `os.environ.get('GOOGLE_SA_PATH', os.path.expanduser('~/.config/google/credentials.json'))`.

4. **Documentar env vars** — adicionar ao `.env.example`:
   ```
   # Google Calendar
   GOOGLE_CALENDAR_ID=primary
   GOOGLE_SA_PATH=~/.config/google/credentials.json
   # OU (para Docker sem volume):
   GOOGLE_SA_JSON=<base64 do conteúdo do credentials.json>
   ```

5. **Migration SQL** — criar `sql/migrations/53-SQL-gcal-event-id.sql` adicionando
   a coluna `google_calendar_event_id TEXT` à tabela `calls_mentoria`.

**Exit Criteria**: `POST /api/calendar/create-event` cria evento com datetime correto
no Google Calendar; servidor inicia sem erro quando `GOOGLE_SA_JSON` está definida.

---

## Fase 2 — Visibilidade na Agenda

**Goal**: A equipe vê eventos do Google Calendar na Agenda e é alertada sobre conflitos
antes de agendar uma call.

**Esforço**: M

### Passos

1. **Fetch de eventos GCal no frontend** — em `11-APP-app.js`, adicionar método
   `fetchGcalEvents()` que chama `GET /api/calendar/events` e armazena resultado em
   `this.data.gcalEvents = []`. Chamar junto com `fetchUpcomingCalls()` ao carregar a
   Agenda.

2. **Overlay no calendário visual** — em `calendarDays()` (linha 3852), adicionar
   campo `gcalEvents` ao objeto de cada dia (count de eventos GCal naquele dia).
   No HTML do calendário, renderizar badge distinto (ex: `●` azul) quando
   `day.gcalEvents > 0`.

3. **Detecção de conflito no scheduleModal** — em `scheduleCall()` (linha 3912),
   antes de chamar os endpoints, verificar se há evento em `this.data.gcalEvents`
   cujo `start.dateTime` esteja dentro de ±30 min do horário selecionado. Se sim,
   setar `this.ui.gcalConflict = { summary, start }` e renderizar aviso no modal.
   O usuário pode confirmar mesmo assim ou alterar o horário.

4. **Salvar `google_calendar_event_id`** — em `scheduleCall()`, após receber
   `calData.event_id` com sucesso, incluir `google_calendar_event_id: calData.event_id`
   no INSERT do Supabase (`calls_mentoria`).

**Exit Criteria**: Dias com eventos GCal exibem badge distinto; scheduleModal mostra
aviso de conflito quando há sobreposição; `google_calendar_event_id` salvo no Supabase.

---

## Fase 3 — Cancelamento de Evento

**Goal**: Quando uma call é cancelada no dashboard, o evento correspondente é removido
do Google Calendar.

**Esforço**: S

### Passos

1. **`delete_calendar_event()`** — adicionar função no backend (após `list_calendar_events`,
   linha 402):
   ```python
   def delete_calendar_event(event_id):
       service = get_gcal_service()
       if not service:
           return {'error': 'Google Calendar not configured'}
       try:
           service.events().delete(calendarId=GOOGLE_CALENDAR_ID, eventId=event_id).execute()
           return {'deleted': True, 'event_id': event_id}
       except Exception as e:
           print(f'[GCal] Delete event error: {e}')
           return {'error': str(e)}
   ```

2. **Handler DELETE** — em `do_DELETE()` (linha 855), adicionar:
   ```python
   elif self.path.startswith('/api/calendar/event/'):
       self._handle_delete_calendar_event()
   ```
   Implementar `_handle_delete_calendar_event()` que extrai `event_id` do path e
   chama `delete_calendar_event()`.

3. **Frontend: chamar DELETE ao cancelar call** — localizar onde o frontend muda
   `status_call` para `'cancelada'` e, se a call tiver `google_calendar_event_id`,
   chamar `DELETE /api/calendar/event/<event_id>` antes ou depois do UPDATE Supabase.

**Exit Criteria**: `DELETE /api/calendar/event/<id>` remove o evento do GCal e retorna
`{ deleted: true }`; calls sem `google_calendar_event_id` retornam `{ skipped: true }`.

---

## Arquivos a Modificar/Criar

| Arquivo | Ação | O que muda |
|---------|------|-----------|
| `app/backend/14-APP-server.py` | modificar | Fix field mismatch (l.979), GOOGLE_SA_JSON (l.305), GOOGLE_SA_PATH env (l.59), `delete_calendar_event()`, handler DELETE, `do_DELETE` routing |
| `app/frontend/11-APP-app.js` | modificar | `fetchGcalEvents()`, `calendarDays()` + `gcalEvents`, conflito no `scheduleModal`, salvar `google_calendar_event_id`, chamar DELETE ao cancelar |
| `.env.example` | modificar | Adicionar seção Google Calendar |
| `sql/migrations/53-SQL-gcal-event-id.sql` | criar | `ALTER TABLE calls_mentoria ADD COLUMN google_calendar_event_id TEXT` |
| `docs/stories/STORY-5.1-google-calendar-integration.md` | criar | Story file com checkboxes das tasks |

## Estratégia de Testes

- **Manual — Fase 1**: Agendar call via scheduleModal e verificar que o evento aparece
  no Google Calendar com data/hora correta.
- **Manual — Fase 1**: Iniciar servidor com `GOOGLE_SA_JSON` definida como env var e
  confirmar log `[GCal] using GOOGLE_SA_JSON`.
- **Manual — Fase 2**: Abrir Agenda e verificar badge nos dias com eventos GCal; testar
  scheduleModal com horário conflitante.
- **Manual — Fase 3**: Cancelar uma call e verificar que o evento some do Google Calendar.
- **`/api/health`**: `gcal_configured` deve retornar `true` quando configurado.

## Plano de Rollback

1. Se o fix de field names quebrar algo, reverter o handler para aceitar ambos (`start`
   e `start_iso`) com `body.get('start_iso') or body.get('start', '')`.
2. Se a coluna `google_calendar_event_id` causar problemas, a migration pode ser revertida
   com `ALTER TABLE calls_mentoria DROP COLUMN google_calendar_event_id`.
3. O frontend degrada graciosamente: se `fetchGcalEvents()` falhar (GCal não configurado),
   `this.data.gcalEvents` permanece `[]` — calendário funciona normalmente sem badges.

## Questões Abertas

- O `GOOGLE_CALENDAR_ID` em produção é `primary` (calendário da service account) ou
  um calendário compartilhado específico? Confirmar com DevOps.
- Onde exatamente no frontend o status de uma call é alterado para `cancelada`?
  (não encontrado no grep inicial — verificar na Fase 3).
