# CodeRabbit-Style Review — 2026-03-16

**Scope:** 2 commits on `feat/kaique/dossie-pipeline-auto` (15 files, +856/-94)
**Reviewer:** Manual (CodeRabbit CLI unavailable on macOS)

---

## Findings

### CRITICAL — Must Fix

| # | File | Line | Issue | Fix |
|---|------|------|-------|-----|
| C1 | `14-APP-server.py` | L1193 | **SQL injection via `slug` parameter** — `f'mentorados?nome=ilike.*{slug}*'` passes user input directly into PostgREST ILIKE filter without sanitization. An attacker could inject `*&select=*` or other PostgREST operators. | Sanitize: strip non-alphanumeric chars except spaces/hyphens, or URL-encode the slug. |
| C2 | `14-APP-server.py` | L1172-1244 | **No authentication** — `POST /api/ds/update-stage` has zero auth checks. Other endpoints like `/api/financial/*` check `CFO_ALLOWED_USERS`. Anyone with network access can modify document stages. | Add JWT auth check matching existing pattern (`_check_auth` or `CFO_ALLOWED_USERS`). |

### HIGH — Fix Before Merge

| # | File | Line | Issue | Fix |
|---|------|------|-------|-----|
| H1 | `14-APP-server.py` | L1182 | **No validation of `estagio` param** — accepts any arbitrary string. Should validate against known stages. | Add `valid_estagios = ('pendente', 'producao_ia', 'revisao_mariza', 'revisao_kaique', 'revisao_queila', 'aprovado', 'enviado', 'finalizado')` and reject unknown. |
| H2 | `14-APP-server.py` | L1218 | **PATCH result not checked** — `result = supabase_request('PATCH', ...)` return value is unused. If PATCH fails, the event is still created (inconsistent state). | Check result for error, return 500 if PATCH failed, skip event creation. |
| H3 | `14-APP-server.py` | L1225 | **ds_eventos POST result not checked** — silent failure on audit trail creation. | Log warning if event creation fails. |

### MEDIUM — Technical Debt

| # | File | Line | Issue |
|---|------|------|-------|
| M1 | `46-SQL-ds-bridge-v2.sql` | L38 | SECURITY DEFINER on trigger function — runs as function owner (postgres), not invoker. Acceptable for internal trigger but worth noting. |
| M2 | `ds-stage-notification.json` | L20 | Supabase credential ID hardcoded as `"SUPABASE_CRED_ID"` — placeholder, will need replacement when importing to N8N. |
| M3 | `57-SQL-vw-ds-metrics.sql` | — | View uses 5 CTEs with `json_agg` — may be slow with large datasets. Monitor performance. |

### LOW — Noted

| # | File | Issue |
|---|------|-------|
| L1 | `12-APP-data.js` | Deprecated array is empty `[]` but legacy `filteredDossiers` getter and HTML template still reference it — dead code. |
| L2 | `53-SQL-ds-transcricoes.sql` | RLS policy is fully permissive (`USING (true)`) — fine for team tool, but should be tightened if external access is added. |
| L3 | `55-SQL-ds-seed-transcricoes.sql` | Only Thiago Kailer seeded — other mentorados have empty transcricoes dirs. |

---

## Summary

| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | 2 | **Must fix** |
| HIGH | 3 | Recommend fix |
| MEDIUM | 3 | Tech debt |
| LOW | 3 | Noted |

**Decision:** FAIL — 2 CRITICAL issues (SQL injection + missing auth) must be fixed before merge.
