# Concierge Path v1.0 — Metodologia de Desenvolvimento

> Documento definitivo. Atualizado: 16/Mar/2026.
> Concierge = PORTEIRO. Agent no worktree = EXECUTOR.

---

## Arquitetura

```
CONCIERGE (em /workspace)              AGENT (em /worktrees/<nome>)
─────────────────────────              ──────────────────────────────
Recebe demandas                        Lê HANDOFF.md (injetado por hook)
Lê ClickUp                            Cria spec.md
Propõe worktrees (tabela)              Cria plan.md
Dev aprova                             Cria Beads (a partir do plan)
Roda create-worktree.sh                Codifica (seguindo plan)
  → worktree + HANDOFF.md             PR + Review
Reporta paths → FIM                    Merge + Cleanup
```

## Modelo de Dados

```
ClickUp Task (fonte de verdade)
  └── Worktree (/worktrees/<nome>)
        └── HANDOFF.md (YAML frontmatter — contrato Concierge→Agent)
              └── spec.md → plan.md → Beads → Código → PR
```

## Enforcement (5 hooks)

| Hook | Trigger | Bloqueia |
|------|---------|----------|
| `handoff-injector.sh` | SessionStart | — (injeta HANDOFF.md como contexto) |
| `worktree-guard.sh` | Bash | `git worktree add` direto (força script) |
| `spec-gate.sh` | Write/Edit | Código sem spec.md + plan.md |
| `branch-guard.sh` | Bash | `git push origin main\|develop` |
| `secret-guard.sh` | Write/Edit | API keys fora de .env |

---

## FASE 0 — Setup (uma vez por repo)

| Step | Verificação | Esperado |
|------|-------------|----------|
| Docker | `docker ps --filter name=spalla-dev` | Up |
| SSH | `ssh -p 2225 vscode@localhost hostname` | Hash |
| Tokens | `echo $CLICKUP_API_TOKEN \| head -c 5` | `pk_23...` |
| Claude | `claude --version` | Versão |
| GitHub | `gh auth status` | ✓ |
| Beads | `bd --version` | Versão |
| Maestro | Nova session em spalla-dev | Concierge responde |

### 🔒 GATE: ENV_READY — 7/7 checks passam

---

## FASE 1 — Recepção e Planejamento

### 1.1 — Boas-vindas + coleta

O Concierge oferece 3 opções:

1. **Auto-fetch ClickUp** → busca tasks atribuídas ao dev
2. **Links manuais** → dev cola CU-xxx
3. **Freestyle** → dev descreve → **Concierge CRIA task no ClickUp primeiro**

### 1.2 — Ler contexto de CADA task

```bash
AUTH="Authorization: $CLICKUP_API_TOKEN"
curl -s -H "$AUTH" "https://api.clickup.com/api/v2/task/{TASK_ID}" \
  | jq '{name, description, status: .status.status}'
```

Extrair: título, descrição, checklists, anexos. REPETIR para TODAS.

### 1.3 — Classificar

- "Gera código que RODA em produção?" → SIM = `feature/` ou `fix/`
- NÃO = `content/`

### 1.4 — Propor plano de worktrees

| # | Tipo | Worktree | Branch | Escopo | ClickUp |
|---|------|----------|--------|--------|---------|
| 1 | feat | widget-zoom | feature/widget-zoom | `app/frontend/` | CU-abc123 |

**Esperar aprovação EXPLÍCITA do dev.** ("ok", "vai", "confirma")

### 🔒 GATE: SESSION_PLANNED — ≥1 task + todas classificadas + dev aprovou

---

## FASE 2 — Criar Worktrees (via script atômico)

### 2.1 — Atualizar develop

```bash
git checkout develop && git pull origin develop
```

### 2.2 — Criar worktrees (SCRIPT OBRIGATÓRIO)

> ⚠️ `git worktree add` direto é BLOQUEADO pelo hook.

```bash
bash /workspace/.claude/scripts/create-worktree.sh \
  --name widget-zoom \
  --branch feature/widget-zoom \
  --type feature \
  --clickup abc123def \
  --scope "app/frontend/" \
  --exclude "app/backend/"
```

O script faz TUDO atomicamente:
1. Cria worktree em `/worktrees/<nome>/`
2. Busca briefing do ClickUp (se `--clickup`)
3. Escreve `HANDOFF.md` com YAML frontmatter

### 2.3 — Reportar resultado

| # | Worktree | Branch | Path | HANDOFF | Status |
|---|----------|--------|------|---------|--------|
| 1 | widget-zoom | feature/widget-zoom | /worktrees/widget-zoom | ✅ | Pronto |

**Instruir:** "Aponte os agents nos worktrees. Meu trabalho acabou."

### 🔒 GATE: WORKTREES_READY — Todos criados + HANDOFF.md presente em cada um

> **FIM DO TRABALHO DO CONCIERGE.** Agent assume daqui.

---

## FASE 3 — Spec → Plan → Beads (AGENT no worktree)

> Hook `handoff-injector.sh` injeta HANDOFF.md automaticamente ao abrir sessão.

### 3.1 — Spec

- **Criar:** `spec.md` no worktree
- Investigar código existente no escopo
- Documentar: o que muda, por quê, impacto, dependências
- **SPEC É LEITURA. Zero código.**

### 3.2 — Plan

- **Criar:** `plan.md` no worktree
- Cada step no formato Task Atom:

```yaml
- what: "Adicionar rota de zoom"
  target: "app/frontend/components/zoom.js"
  success_criteria: "Componente renderiza zoom controls"
  rollback: "git revert HEAD"
  constraints: "NÃO modificar app/backend/"
```

### 3.3 — Beads (a partir do plan)

```bash
bd create "feat: widget zoom (CU-abc123)"          # Bead PAI
bd create "sub: setup routes" --parent <PAI>         # Bead FILHO por step
bd dep add <B> <A>                                   # Dependências
```

### 3.4 — Sync ClickUp

```bash
AUTH="Authorization: $CLICKUP_API_TOKEN"
curl -s -X PUT -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"status":"in progress"}' \
  "https://api.clickup.com/api/v2/task/{TASK_ID}"
```

### 🔒 GATE: SPEC_APPROVED — spec.md + plan.md + Beads com deps + ClickUp atualizado

> Hook `spec-gate.sh` BLOQUEIA código sem spec+plan.

---

## FASE 4 — Desenvolvimento (AGENT)

- Seguir plan.md step by step
- 1 commit = 1 step: `tipo(escopo): desc #BEAD-ID`
- NUNCA fora do `scope.directories` do HANDOFF
- `scope.excluded` = PROIBIDO
- Rebase mínimo 1x/sessão: `git fetch origin develop && git rebase origin/develop`

### 🔒 GATE: CODE_CLEAN — git status limpo + commits convencionais + sem secrets

---

## FASE 5 — PR + Review (AGENT)

```bash
git push -u origin {branch}
gh pr create --base develop --title "tipo(escopo): desc" \
  --body "ClickUp: {task_url}\nBead: {BEAD_ID}"
```

- Esperar CI + CodeRabbit
- Auto-fix loop (max 5 retries)
- Se 5 retries esgotados: `bd update --status blocked`

### 🔒 GATE: PR_APPROVED — CI verde + CodeRabbit limpo

---

## FASE 6 — Merge + Cleanup (AGENT)

```bash
gh pr merge --squash
bd close {BEAD_PAI}
git worktree remove /worktrees/{nome}
git worktree prune && git branch -d {branch}
git checkout develop && git pull origin develop
```

ClickUp → status `done`

### 🔒 GATE: MERGE_COMPLETE — PR merged + Bead closed + worktree removido

---

## FASE 7 — Release (GATE HUMANO)

```bash
gh pr create --base main --head develop --title "release: vX.Y.Z"
# Aprovação HUMANA
gh pr merge --merge
git tag vX.Y.Z && git push origin vX.Y.Z
```

### 🔒 GATE: DEPLOY_OK — main atualizada + tag

---

## Gotchas

| # | Problema | Solução |
|---|----------|---------|
| 1 | SSH key mismatch | `ssh-keygen -R "[localhost]:2225"` |
| 2 | Claude não autenticado | `ssh -t -p 2225 vscode@localhost claude login` (Mac) |
| 3 | Token missing | Verificar `/workspace/.devcontainer/.env` |
| 4 | `bd` not found | `sudo npm install -g @beads/bd` |
| 5 | Worktree dentro do repo | Hook BLOQUEIA. Usar script. |
| 6 | Código sem spec | Hook BLOQUEIA. spec.md + plan.md primeiro. |
| 7 | Push pra main/develop | Hook BLOQUEIA. Sempre via PR. |
| 8 | Secrets no código | Hook BLOQUEIA. Só em .env. |
| 9 | Worktree sem HANDOFF | IMPOSSÍVEL. Script é atômico. |
| 10 | Volume destruído | `down` SEM `-v`. Com `-v` perde auth. |
| 11 | Beads antes da spec | ERRADO. Spec revela complexidade real. |
| 12 | Concierge codificando | ERRADO. Concierge = porteiro. Agent = executor. |

---

## Referências

| Arquivo | O que é |
|---------|---------|
| `/workspace/.claude/CLAUDE.md` | Persona + onboarding do Concierge |
| `/workspace/.claude/rules/concierge-path.md` | Rules de enforcement |
| `/workspace/.claude/concierge-flow.yaml` | Fluxo completo em YAML |
| `/workspace/.claude/scripts/create-worktree.sh` | Script atômico |
| `/workspace/.devcontainer/hooks/` | 5 hooks de enforcement |

---

> **Concierge Path v1.0** — 16/Mar/2026
