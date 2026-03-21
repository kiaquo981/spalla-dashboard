---
worktree: wt-wa-dm-core
branch: feature/case/wa-dm-core
type: feature
created: 2026-03-21
sprint: S9-A
status: pending
scope:
  directories:
    - supabase/migrations/
    - app/backend/14-APP-server.py
  excluded:
    - app/frontend/
    - app/frontend/10-APP-index.html
    - app/frontend/11-APP-app.js
---

# Handoff — WA DM v2: Core Data Model

## Contexto

Este é o worktree S9-A — fundação de dados para o módulo WA Management v2.
Sem frontend. Só SQL + backend endpoints base.

**Os outros 2 worktrees (inbox-ui, task-triage) dependem deste.**

Arquitetura completa documentada em:
`~/Documents/Workspace/docs/specs/wa-management-v2-architecture.md`

## O Que Já Existe (NÃO duplicar)

- `mentorados.grupo_whatsapp_id` — JID do grupo (já mapeado)
- `wa_messages.mentorado_id` — populado pelo N8N (já existe)
- `wa_topics.mentorado_id` — populado pelo N8N (já existe)
- `mentee_notes` table — S8 já aplicou
- `mentorados.snoozed_until` — S8 já aplicou
- `vw_wa_topic_board` — digest já funciona

## Entregável: Migration SQL + Backend

### 1. Migration `20260321_wa_dm_v2.sql`

Criar em `supabase/migrations/` com:

```sql
-- 1. vw_wa_mentee_inbox
--    VIEW que abstrai grupos como DM 1:1 por mentorado
--    Campos: mentorado_id, nome, foto_url, fase_jornada, group_jid,
--            snoozed_until, last_message, last_message_at, last_message_sender,
--            last_message_is_team, unread_count, horas_sem_resposta_equipe,
--            health_status (verde/amarelo/vermelho/snoozed),
--            open_topics_count, active_tasks_count
--    LATERAL JOINs em wa_messages por mentorado_id

-- 2. wa_sla_states
--    Histórico de SLA por mentorado
--    Campos: mentorado_id, yellow_at, red_at, resolved_at, resolved_by

-- 3. wa_canned_responses
--    Templates de resposta rápida com shortcode
--    Campos: shortcode, name, content, category
--    Seed com ~8 templates padrão (bom_dia, acompanhamento, call, etc.)

-- 4. wa_presence
--    Collision detection — quem está vendo qual mentorado
--    Campos: mentorado_id, user_email, user_name, last_seen
--    UNIQUE(mentorado_id, user_email)

-- 5. wa_saved_segments
--    Filter presets salvos na Carteira
--    Campos: name, filters JSONB, is_shared, owner_email

-- 6. ALTER god_tasks
--    ADD source_topic_id UUID REFERENCES wa_topics(id) ON DELETE SET NULL
--    ADD source_message_id UUID REFERENCES wa_messages(id) ON DELETE SET NULL

-- 7. Expose views/tables via public schema para PostgREST
-- 8. RLS policies (select/insert para authenticated, update para wa_presence)
```

Detalhes exatos do SQL estão no arquivo de arquitetura.

### 2. Backend endpoints em `app/backend/14-APP-server.py`

Adicionar ao roteador:

- `GET /api/wa/inbox` → query `vw_wa_mentee_inbox` com filtros
  - params: `health_status`, `fase_jornada`, `search`, `sort`
- `POST /api/wa/presence` → upsert `wa_presence`
  - body: `{ mentorado_id, user_email, user_name }`
- `DELETE /api/wa/presence` → clear presence
  - params: `mentorado_id`, `user_email`
- `GET /api/wa/presence/{mentorado_id}` → quem está vendo agora
  - filtrar por `last_seen > now() - interval '60 seconds'`

## Próximos Passos

1. Criar `spec.md` — revisar o arquivo de arquitetura, adaptar SQL para o schema real
2. Criar `plan.md` — decompor em steps: migration → backend endpoints → testes
3. Criar Beads
4. Implementar migration + endpoints
5. PR para develop

## Referências

- Arquitetura: `~/Documents/Workspace/docs/specs/wa-management-v2-architecture.md`
- Schema WA existente: `sql/migrations/35-SQL-wa-topics-schema.sql`
- Schema mentorados: `sql/migrations/08-SQL-god-views-v2.sql`
- Backend server: `app/backend/14-APP-server.py` (endpoints existentes ~linha 1800)
