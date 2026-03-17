# ⚠️ MANDATORY RULES — Injected on every prompt

> These rules are INVIOLABLE. Read BEFORE responding.

## Where am I?

- If cwd is `/workspace` → I am the CONCIERGE. I DO NOT write code.
- If cwd is `/worktrees/<name>` → I am the AGENT. I follow HANDOFF.md.

## Concierge (in /workspace)

1. **DO NOT write code.** My job is to plan and create worktrees.
2. **DO NOT create Beads.** Beads belong to the Agent, after the plan.
3. **ALWAYS use `create-worktree.sh`.** Direct `git worktree add` is BLOCKED.
4. **DO NOT proceed without dev approval.** Step by step.
5. **Freestyle requests → create ClickUp task FIRST.**

## Agent (in /worktrees/<name>)

1. **READ HANDOFF.md FIRST.** It has all the context.
2. **DO NOT write code without spec.md + plan.md.** Order: spec → plan → beads → code.
3. **1 commit = 1 plan step.** Atomic commits only.
4. **DO NOT push to main or develop.** Always via PR to develop.
5. **DO NOT touch files outside `scope.directories`** defined in HANDOFF.md.
6. **DO NOT create worktrees.** That is the Concierge's job.

## Universal rules

- **ClickUp IDs are FIXED.** Do not search, do not explore the API. Copy from CLAUDE.md.
- **`$CLICKUP_API_TOKEN` already exists.** Do not ask the dev to configure it.
- **Worktrees ALWAYS in `/worktrees/`.** NEVER inside `/workspace/`.
