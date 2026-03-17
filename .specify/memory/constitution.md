<!--
SYNC IMPACT REPORT
==================
Version change: (none) → 1.0.0 (initial ratification)
Modified principles: N/A (new document)
Added sections:
  - Core Principles (I–V)
  - Integration Standards
  - Development Workflow
  - Governance
Removed sections: N/A
Templates requiring updates:
  ✅ .specify/memory/constitution.md (this file — created)
  ⚠ .specify/templates/plan-template.md (not yet created — pending)
  ⚠ .specify/templates/spec-template.md (not yet created — pending)
  ⚠ .specify/templates/tasks-template.md (not yet created — pending)
Follow-up TODOs:
  - Create .specify/templates/ files to complete Spec Kit setup
-->

# Spalla Dashboard Constitution

## Core Principles

### I. Story-Driven Development (NON-NEGOTIABLE)

Every code change in Spalla Dashboard MUST originate from a story in `docs/stories/`.
No feature, fix, or refactor is implemented without an associated, approved story.

**Rules:**

- MUST: No code is written without a story file in `docs/stories/`
- MUST: Stories MUST have explicit acceptance criteria before implementation begins
- MUST: Story checkboxes MUST be updated in real time as tasks complete
- MUST: The File List section inside each story MUST reflect every file touched
- MUST: Story status follows the lifecycle: Draft → Approved → InProgress → InReview → Done
- MUST NOT: Create throwaway scripts, hotfixes, or "quick patches" outside the story flow

**Gate:** Block implementation if no valid story exists for the change.

### II. No Invention (MUST)

Specifications and implementations MUST derive exclusively from stated requirements.
Agents and developers are NOT permitted to add undocumented features or assumptions.

**Rules:**

- MUST: Every statement in a spec or plan MUST trace to a FR-*, NFR-*, CON-*, or
  verified research finding
- MUST NOT: Add capabilities not present in the PRD or story acceptance criteria
- MUST NOT: Assume undocumented integration behavior (e.g., Google Calendar OAuth scopes
  MUST be verified against official docs before coding)
- MUST NOT: Invent database schema columns not present in `sql/migrations/` or
  `docs/03-DOC-TECNICA-TABELAS.md`

**Gate:** Block spec merge if uninventory items are found during review.

### III. Quality First (MUST)

All code MUST pass the full quality gate before being considered complete.
The quality bar applies equally to frontend (Alpine.js), backend (Python/Flask), and
database (SQL migrations).

**Rules:**

- MUST: Python backend — `flake8` or configured linter passes with zero errors
- MUST: SQL migrations — reviewed against RLS policies in `supabase/` before apply
- MUST: No `console.error` or unhandled promise rejections left in frontend JS
- MUST: New Flask endpoints MUST include error handling (`try/except`) and
  structured logging (`print(f"Error in {op}:", e)`)
- MUST: `supabase db push` MUST succeed without conflicts before PR
- SHOULD: New backend routes include at least one integration-level test

**Gate:** Pre-push hook blocks if linter errors are present.

### IV. Agent Authority (NON-NEGOTIABLE)

Each AIOS agent holds exclusive authority over its domain.
No agent may assume another agent's authority or bypass delegation.

**Delegation table:**

| Authority | Exclusive Agent |
|---|---|
| `git push` to remote | @devops |
| PR creation / merge | @devops |
| Story creation / expansion | @sm, @po |
| Architecture decisions | @architect |
| Schema design (DDL) | @data-engineer |
| Quality verdicts | @qa |
| Requirements & PRD | @pm |

**Rules:**

- MUST: @dev MUST NOT run `git push` or `gh pr create` — delegate to @devops
- MUST: @dev MUST NOT modify story acceptance criteria — delegate to @po or @sm
- MUST: @architect decides technology choices; @data-engineer implements DDL details
- MUST NOT: Any agent take an action outside its exclusive authority domain

**Gate:** Implemented via agent persona definitions; violations flagged on review.

### V. Full-Stack Consistency (MUST)

Spalla Dashboard is a tightly coupled three-tier system (Alpine.js → Python Flask →
Supabase). Changes that touch one tier MUST be reflected and validated across all
affected tiers before the story is marked Done.

**Rules:**

- MUST: A new backend endpoint MUST have a corresponding frontend fetch call
  and error-state handling before the story closes
- MUST: A new Supabase table or column MUST have a corresponding SQL migration
  in `sql/migrations/` AND updated RLS policy in `supabase/`
- MUST: External integrations (Google Calendar, WhatsApp, n8n) MUST be
  implemented via a dedicated service module — no inline API calls in route handlers
- MUST: Environment variables for new integrations MUST be documented in `.env.example`
  before PR is opened
- SHOULD: Frontend views that depend on new API fields MUST be updated in the
  same story, not a follow-up

**Gate:** PR checklist enforced in `.github/pull_request_template.md`.

## Integration Standards

Google Calendar integration (current feature branch) MUST comply with:

- OAuth 2.0 scopes MUST be declared minimally — only `calendar.readonly` or
  `calendar.events` depending on the operation; NEVER request broader scopes
- Tokens MUST be stored in Supabase (encrypted at rest via RLS), never in `.env`
  or frontend localStorage
- All Google API calls MUST be wrapped in a `services/google_calendar.py` module
  (backend) — frontend NEVER calls Google APIs directly
- Webhook/push notification channels MUST be registered and renewed via a
  documented background job, not on-demand per request

## Development Workflow

1. `git checkout develop && git pull`
2. `git checkout -b feature/<taskid>-<description>`
3. Implement story, updating checkboxes in real time
4. `git commit -m "feat(scope): description #TASKID"`
5. `git push origin feature/<branch>` (**@devops only**)
6. `gh pr create --base develop` (**@devops only**)
7. CI → CodeRabbit → 1 approval → Squash and Merge

## Governance

### Amendment Process

1. Document the proposed change with justification
2. Review by @architect and @po
3. Consensus required for approval
4. Increment version following semantic rules
5. Propagate changes to `.specify/templates/` and dependent task definitions

### Versioning Policy

- **MAJOR**: Removal or backward-incompatible redefinition of a principle
- **MINOR**: New principle added or materially expanded guidance
- **PATCH**: Clarifications, wording fixes, non-semantic refinements

### Compliance Review

- All PRs MUST verify constitution compliance via the story checklist
- Violations of NON-NEGOTIABLE principles BLOCK merge
- Violations of MUST principles generate a WARN that requires acknowledgment
- SHOULD violations are reported but do not block

**Version**: 1.0.0 | **Ratified**: 2026-03-16 | **Last Amended**: 2026-03-16
