---
title: "Feature Spec: Google Calendar Integration"
type: spec
status: approved
author: "feature/case/google-calendar-integration"
date: "2026-03-16"
bu: "BU-CASE"
---

# Feature Spec: Google Calendar Integration

## Problema

A equipe CASE agenda calls com mentorados pelo Spalla Dashboard, mas a integração com
Google Calendar está **inoperante em produção** por dois bugs críticos:

1. **Field name mismatch** (`app/backend/14-APP-server.py:979`): o frontend envia
   `start_iso`/`end_iso`, mas o handler lê `body.get('start', '')` e
   `body.get('end', '')` — eventos criados no Google Calendar nunca têm datetime.
2. **Service account path hardcoded** (linha 59): `GOOGLE_SA_PATH` aponta para
   `~/.config/google/credentials.json`, caminho inexistente no container Docker de
   produção (Hetzner). A integração cai silenciosamente no startup.
3. **Env vars não documentadas**: `GOOGLE_CALENDAR_ID` e `GOOGLE_SA_PATH` ausentes
   do `.env.example`.

Além disso, a Agenda exibe apenas calls internas (Supabase) e não tem visibilidade
de eventos do Google Calendar nem alerta de conflito de horário — Gap G6 do PRD v3.

## Solução Proposta

### Fase 1 — Bugfixes + Configuração (bloqueador de produção)

Corrigir os dois bugs críticos e tornar a autenticação configurável via env var,
com suporte a `GOOGLE_SA_JSON` (conteúdo JSON em base64) para ambientes Docker que
não montam volumes, e `GOOGLE_SA_PATH` para desenvolvimento local.

### Fase 2 — Visibilidade na Agenda

Consumir `GET /api/calendar/events` no frontend e exibir os eventos do Google Calendar
no calendário visual existente. Cada dia com evento externo recebe um badge distinto
(diferente das calls internas). Ao selecionar horário no scheduleModal, verificar
conflitos client-side e alertar antes de confirmar.

### Fase 3 — Ciclo de vida completo (cancelamento)

Adicionar `delete_calendar_event()` no módulo de serviço do backend,
expor `DELETE /api/calendar/event/<event_id>`, e salvar o `google_calendar_event_id`
em `calls_mentoria` para que o frontend possa acionar a deleção quando o status da
call mudar para `cancelada`.

### Decisões Técnicas

| Decisão | Opção Escolhida | Justificativa |
|---------|----------------|---------------|
| Auth Google Calendar | Service Account existente | Já implementado; evita fluxo OAuth user-by-user |
| Credentials em Docker | `GOOGLE_SA_JSON` (base64) OU `GOOGLE_SA_PATH` (volume) | Base64 via env var sem volume; path mantém compatibilidade local |
| Overlay de eventos GCal | Badge no dia do calendário + campo `gcalEvents` no state Alpine | Não refatora o calendário existente |
| Detecção de conflito | Client-side com dados já em memória | Zero round-trip extra; dados carregados ao abrir a Agenda |
| Cancelamento GCal | Novo `delete_calendar_event()` no módulo + handler DELETE | Segue Princípio V da constituição (serviço isolado, não inline) |
| `google_calendar_event_id` | Coluna nova em `calls_mentoria` via migration SQL | Persistência necessária para cancelamento futuro |

## Fora de Escopo

- OAuth por usuário (cada membro autenticando com conta Google própria)
- Sincronização bidirecional (GCal → Supabase)
- Notificações push/email via Google Calendar API
- Múltiplos calendários por membro da equipe
- Importação de eventos históricos do GCal

## Dependências

| Dependência | Status | Responsável |
|-------------|--------|------------|
| Service account Google com acesso ao calendário | Deve existir em prod | DevOps / Kaique |
| `GOOGLE_CALENDAR_ID` configurado no Hetzner | A verificar | DevOps |
| `google-api-python-client`, `google-auth` nos requirements | ✅ Presente | — |
| Coluna `google_calendar_event_id TEXT` em `calls_mentoria` | A criar (migration 53) | @dev |

## Critérios de Aceitação

- [ ] Dado que o usuário agenda uma call via scheduleModal, quando o backend processa
  a requisição, então o evento no Google Calendar tem `start.dateTime` e `end.dateTime`
  com os valores ISO corretos.
- [ ] Dado que `GOOGLE_SA_JSON` está definida no ambiente, quando o servidor inicia,
  então `get_gcal_service()` usa o JSON decodificado da env var sem depender de
  arquivo em disco (log confirma "using GOOGLE_SA_JSON").
- [ ] Dado que `GOOGLE_SA_PATH` está definida no ambiente (sem `GOOGLE_SA_JSON`),
  quando o servidor inicia, então `get_gcal_service()` lê o arquivo no path
  configurado (comportamento atual preservado).
- [ ] Dado que o usuário abre a página Agenda, quando os eventos do GCal carregam,
  então dias com evento externo exibem um badge distinto das calls internas (ex: ponto
  azul vs ponto verde).
- [ ] Dado que o usuário seleciona data e horário no scheduleModal e há evento GCal
  no mesmo slot (±30 min), então o modal exibe aviso de conflito antes de confirmar.
- [ ] Dado que uma call tem `google_calendar_event_id` salvo, quando o usuário muda
  o status para "cancelada", então o evento é removido do Google Calendar via
  `DELETE /api/calendar/event/<event_id>` e a resposta retorna `{ deleted: true }`.
- [ ] Dado que qualquer dev copia `.env.example`, então `GOOGLE_CALENDAR_ID` e
  `GOOGLE_SA_PATH` / `GOOGLE_SA_JSON` estão documentadas com descrições claras.

## Riscos

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| Service account sem permissão no calendário compartilhado | Médio | Alto | Validar via `/api/health` (`gcal_configured`) antes do deploy |
| Volume alto de eventos GCal deixando a Agenda lenta | Baixo | Médio | `list_calendar_events` limitado a max_results=50 e janela de 30 dias |
| Calls antigas sem `google_calendar_event_id` | Alto | Baixo | Handler DELETE verifica existência antes de chamar API; retorna `{ skipped: true }` se nulo |
| Decode base64 inválido do `GOOGLE_SA_JSON` | Baixo | Alto | `get_gcal_service()` loga erro explícito e retorna None; servidor continua |

## Notas

- `_handle_list_events` (linha 1107) já existe e funciona — só falta o frontend consumir.
- O `do_DELETE` handler (linha 855) existe mas roteia apenas `/api/evolution/*` — basta
  adicionar o case para `/api/calendar/event/`.
- `scheduleCall()` no frontend (linha 3912) já chama `/api/calendar/create-event` mas
  envia `start_iso`/`end_iso` — o fix é no backend (1 linha), não no frontend.
- `calendarDays()` (linha 3852) já expõe `calls` por dia — adicionar `gcalEvents` ao
  mesmo objeto sem refatorar a estrutura.
