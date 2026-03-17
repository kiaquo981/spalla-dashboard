---
title: "Tasks: Google Calendar Integration"
type: task-list
status: active
plan: "docs/specs/google-calendar-integration-plan.md"
spec: "docs/specs/google-calendar-integration-spec.md"
author: "feature/case/google-calendar-integration"
date: "2026-03-16"
---

# Tasks: Google Calendar Integration

> Esforço: **S** = < 1h | **M** = 1-4h | **L** = 4-8h

---

## Fase 1 — Bugfixes + Configuração

- [ ] `[S]` **Fix field name mismatch** — em `app/backend/14-APP-server.py`,
  método `_handle_create_calendar_event()` (linha ~979):
  alterar `body.get('start', '')` → `body.get('start_iso', '')` e
  `body.get('end', '')` → `body.get('end_iso', '')`.

- [ ] `[S]` **Tornar `GOOGLE_SA_PATH` configurável via env var** — linha ~59,
  substituir o valor hardcoded por:
  `GOOGLE_SA_PATH = os.environ.get('GOOGLE_SA_PATH', os.path.expanduser('~/.config/google/credentials.json'))`

- [ ] `[M]` **Suporte a `GOOGLE_SA_JSON` em `get_gcal_service()`** — antes de
  verificar `os.path.exists(GOOGLE_SA_PATH)`, checar se `GOOGLE_SA_JSON` está no
  ambiente. Se sim, decodificar base64, parsear JSON e criar credenciais via
  `service_account.Credentials.from_service_account_info(info, scopes=SCOPES)`.
  Logar `[GCal] using GOOGLE_SA_JSON` ou `[GCal] using GOOGLE_SA_PATH`.

- [ ] `[S]` **Documentar env vars no `.env.example`** — adicionar seção:
  ```
  # Google Calendar
  GOOGLE_CALENDAR_ID=primary
  GOOGLE_SA_PATH=~/.config/google/credentials.json
  # Para Docker sem volume mount (base64 do credentials.json):
  # GOOGLE_SA_JSON=<base64>
  ```

- [ ] `[S]` **Migration SQL** — criar `sql/migrations/53-SQL-gcal-event-id.sql`:
  ```sql
  ALTER TABLE calls_mentoria
  ADD COLUMN IF NOT EXISTS google_calendar_event_id TEXT;
  COMMENT ON COLUMN calls_mentoria.google_calendar_event_id IS
    'ID do evento no Google Calendar para cancelamento futuro';
  ```

---

## Fase 2 — Visibilidade na Agenda

- [ ] `[M]` **`fetchGcalEvents()` no frontend** — em `app/frontend/11-APP-app.js`,
  adicionar método que chama `GET {CONFIG.API_BASE}/api/calendar/events`,
  armazena em `this.data.gcalEvents = []` (array de eventos GCal com
  `start.dateTime` e `summary`). Chamar junto com `fetchUpcomingCalls()`
  ao inicializar a Agenda. Degradar graciosamente se falhar (manter array vazio,
  sem toast de erro visível ao usuário).

- [ ] `[S]` **Overlay no calendário visual** — em `calendarDays()` (linha ~3852),
  adicionar campo `gcalEvents` ao objeto de cada dia:
  count de eventos em `this.data.gcalEvents` cuja `start.dateTime` começa com
  o mesmo `YYYY-MM-DD`. No HTML do calendário, renderizar badge azul
  (ex: `<span class="gcal-dot">●</span>`) quando `day.gcalEvents > 0`,
  ao lado do badge verde de calls internas.

- [ ] `[M]` **Detecção de conflito no scheduleModal** — em `scheduleCall()`
  (linha ~3912), antes dos fetches ao Zoom/Calendar, calcular o slot selecionado
  (`f.data + f.horario`) e comparar com todos os itens de `this.data.gcalEvents`.
  Se houver evento cujo `start.dateTime` esteja dentro de ±30 min, setar
  `this.ui.gcalConflict = { summary, start }`. No HTML do modal, exibir aviso
  com nome do evento conflitante e botões "Continuar assim mesmo" / "Alterar horário".
  Mostrar indicador de loading (`this.ui.checkingConflict = true`) durante a
  verificação.

- [ ] `[S]` **Salvar `google_calendar_event_id` no Supabase** — em `scheduleCall()`,
  após receber `calData.event_id` com sucesso, incluir
  `google_calendar_event_id: calData.event_id` no objeto do INSERT em
  `calls_mentoria`. Se `calData.event_id` for null/undefined, não incluir o campo.

---

## Fase 3 — Cancelamento de Evento

- [ ] `[S]` **`delete_calendar_event()` no backend** — adicionar função em
  `app/backend/14-APP-server.py` após `list_calendar_events()` (linha ~402):
  recebe `event_id`, chama `service.events().delete(calendarId=GOOGLE_CALENDAR_ID, eventId=event_id).execute()`,
  retorna `{'deleted': True, 'event_id': event_id}`. Em caso de erro, logar e
  retornar `{'error': str(e)}`. Se `event_id` for None/vazio, retornar `{'skipped': True}`.

- [ ] `[S]` **Handler e routing DELETE** — em `do_DELETE()` (linha ~855), adicionar:
  ```python
  elif self.path.startswith('/api/calendar/event/'):
      self._handle_delete_calendar_event()
  ```
  Implementar `_handle_delete_calendar_event()` que extrai `event_id` do path
  (`self.path.split('/')[-1]`), chama `delete_calendar_event(event_id)` e envia JSON.

- [ ] `[M]` **Frontend: DELETE ao cancelar call** — localizar onde o frontend
  atualiza `status_call` para `'cancelada'` (buscar por `status_call.*cancelad` no
  `11-APP-app.js`). Após o UPDATE no Supabase, se a call tiver
  `google_calendar_event_id`, chamar
  `DELETE {CONFIG.API_BASE}/api/calendar/event/{google_calendar_event_id}`
  com fetch e logar resultado. Não bloquear o fluxo se a deleção falhar (warn no console).

---

## Validação

- [ ] `[S]` **Teste manual Fase 1**: agendar call via scheduleModal e verificar que
  evento aparece no Google Calendar com data/hora correta.
- [ ] `[S]` **Teste manual Fase 1**: iniciar servidor com `GOOGLE_SA_JSON=<base64>`
  e confirmar log `[GCal] using GOOGLE_SA_JSON` no console.
- [ ] `[S]` **Teste manual Fase 2**: abrir Agenda e confirmar badge azul em dias com
  eventos GCal; testar conflito selecionando horário ocupado no modal.
- [ ] `[S]` **Teste manual Fase 3**: cancelar call com `google_calendar_event_id`
  e confirmar que evento some do Google Calendar.
- [ ] `[S]` **Criar story file** em `docs/stories/STORY-5.1-google-calendar-integration.md`
  com checkboxes das tasks acima e seção File List.
- [ ] `[S]` **Commit**: `feat(calendar): fix field mismatch + gcal visibility + cancel flow`

---

## Resumo

| Fase | Tasks | Esforço |
|------|-------|---------|
| Fase 1 — Bugfixes + Config | 5 | ~2h |
| Fase 2 — Visibilidade | 4 | ~3h |
| Fase 3 — Cancelamento | 3 | ~1.5h |
| Validação | 6 | ~1h |
| **Total** | **18** | **~7-8h** |
