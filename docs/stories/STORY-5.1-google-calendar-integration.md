---
title: "STORY-5.1: Google Calendar Integration"
type: story
status: InProgress
epic: "5 — Integrações Externas"
branch: "feature/case/google-calendar-integration"
spec: "docs/specs/google-calendar-integration-spec.md"
plan: "docs/specs/google-calendar-integration-plan.md"
tasks: "docs/specs/google-calendar-integration-tasks.md"
date: "2026-03-16"
---

# STORY-5.1: Google Calendar Integration

## Contexto

A integração com Google Calendar está quebrada em produção por dois bugs críticos
(field name mismatch + service account path hardcoded). Esta story corrige os bugs
e implementa visibilidade de eventos GCal na Agenda e cancelamento de eventos.

## Acceptance Criteria

- [ ] Evento criado pelo scheduleModal aparece no Google Calendar com datetime correto
- [ ] Servidor inicia com `GOOGLE_SA_JSON` (base64) sem arquivo em disco
- [ ] Dias com eventos GCal exibem badge distinto na Agenda
- [ ] scheduleModal alerta conflito de horário quando há evento GCal no mesmo slot
- [ ] `google_calendar_event_id` salvo no Supabase após agendamento
- [ ] Call cancelada remove evento correspondente do Google Calendar
- [ ] `.env.example` documenta todas as vars do Google Calendar

## Tasks

### Fase 1 — Bugfixes + Configuração

- [ ] Fix field name mismatch em `_handle_create_calendar_event()` (backend linha ~979)
- [ ] Tornar `GOOGLE_SA_PATH` configurável via env var (backend linha ~59)
- [ ] Suporte a `GOOGLE_SA_JSON` em `get_gcal_service()` (base64 decode)
- [ ] Documentar env vars no `.env.example`
- [ ] Migration SQL: `53-SQL-gcal-event-id.sql` — coluna `google_calendar_event_id`

### Fase 2 — Visibilidade na Agenda

- [ ] `fetchGcalEvents()` no frontend (GET /api/calendar/events)
- [ ] Overlay no calendário visual (`gcalEvents` por dia + badge azul)
- [ ] Detecção de conflito no scheduleModal (±30 min, aviso antes de confirmar)
- [ ] Salvar `google_calendar_event_id` no INSERT do Supabase

### Fase 3 — Cancelamento

- [ ] `delete_calendar_event()` no backend (módulo de serviço)
- [ ] Handler e routing `DELETE /api/calendar/event/<event_id>`
- [ ] Frontend: chamar DELETE ao mudar status_call para 'cancelada'

### Validação

- [ ] Teste manual: agendar call e verificar evento no GCal com datetime correto
- [ ] Teste manual: servidor com `GOOGLE_SA_JSON` no ambiente
- [ ] Teste manual: badge na Agenda + conflito no modal
- [ ] Teste manual: cancelar call remove evento do GCal
- [ ] Commit: `feat(calendar): fix field mismatch + gcal visibility + cancel flow`

## File List

| Arquivo | Ação |
|---------|------|
| `app/backend/14-APP-server.py` | modificar |
| `app/frontend/11-APP-app.js` | modificar |
| `.env.example` | modificar |
| `sql/migrations/53-SQL-gcal-event-id.sql` | criar |
| `docs/stories/STORY-5.1-google-calendar-integration.md` | criar (este arquivo) |
| `docs/specs/google-calendar-integration-spec.md` | criar |
| `docs/specs/google-calendar-integration-plan.md` | criar |
| `docs/specs/google-calendar-integration-tasks.md` | criar |

## Notas

- `_handle_list_events` (backend linha 1107) já funciona — só falta o frontend consumir
- `do_DELETE` (linha 855) já existe mas só roteia `/api/evolution/*`
- `calendarDays()` (linha 3852) já tem campo `calls` por dia — adicionar `gcalEvents`
  sem refatorar
- Frontend degrada graciosamente se GCal não estiver configurado (`gcalEvents = []`)
