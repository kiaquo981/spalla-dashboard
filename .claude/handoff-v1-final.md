# Concierge Path v1.0 — Handoff Completo

> Session: 16/Mar/2026 | Repo: `spalla-dashboard` | Branch: `develop`

---

## Estado Atual — O que existe e funciona

### Arquivos criados/atualizados

| Arquivo | O que é | Commit |
|---------|---------|--------|
| [CLAUDE.md](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.claude/CLAUDE.md) | Persona Concierge + ClickUp quick ref | `63ee255` |
| [concierge-path.md](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.claude/concierge-path.md) | Metodologia v1.0 completa (8 fases) | `d0a0a6a` |
| [concierge-flow.yaml](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.claude/concierge-flow.yaml) | Fluxo em YAML estruturado | `d469e3f` |
| [create-worktree.sh](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.claude/scripts/create-worktree.sh) | Script atômico (worktree + HANDOFF.md) | `c721ad3` |
| [worktree-guard.sh](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.devcontainer/hooks/worktree-guard.sh) | Bloqueia `git worktree add` direto | `c721ad3` |
| [spec-gate.sh](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.devcontainer/hooks/spec-gate.sh) | Bloqueia código sem spec+plan | `05d8dd1` |
| [branch-guard.sh](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.devcontainer/hooks/branch-guard.sh) | Bloqueia push main/develop | `05d8dd1` |
| [secret-guard.sh](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.devcontainer/hooks/secret-guard.sh) | Bloqueia API keys fora de .env | `05d8dd1` |
| [handoff-injector.sh](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.devcontainer/hooks/handoff-injector.sh) | Injeta HANDOFF.md no SessionStart | `b2ce49c` |
| [settings.json](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.devcontainer/hooks/settings.json) | Registro dos hooks no Claude Code | `b2ce49c` |
| [guia-operacional.md](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/dev-playbook/guides/guia-operacional.md) | Manual v1 (seção 18 atualizada) | `83d431d` |

### Infra Docker

| Item | Status | Detalhe |
|------|--------|---------|
| Container `spalla-dev` | ✅ Running | Python 3.9 + Node 20 + AI CLIs |
| SSH porta 2225 | ✅ Funciona | `ssh -p 2225 vscode@localhost` |
| Volume `/worktrees/` | ✅ Persistente | Named volume `spalla-worktrees` |
| Volume `cli-auth-claude` | ✅ Persistente | Auth tokens sobrevivem restart |
| Hooks em `/opt/hooks/` | ✅ Build-time | `entrypoint.sh` copia pra `~/.claude/hooks/` |
| `settings.json` | ✅ Registrado | SessionStart + PreToolUse |

### ClickUp IDs (fixos, hardcoded no CLAUDE.md)

| Recurso | ID |
|---------|----|
| Workspace | `9011530618` (All In Marketing) |
| Space | `90114112693` (Case Scale) |
| Sprint Folder | `90117773705` |
| Sprint 1 | `901113377455` |
| Sprint 2 | `901113377456` |
| Sprint 3 | `901113377457` |
| Token env var | `$CLICKUP_API_TOKEN` |

---

## Problemas Encontrados e Soluções

### 1. Concierge criava worktree dentro de `/workspace/`

**Problema:** Git worktrees criados DENTRO do repo, causando conflitos.
**Solução:** Volume Docker `/worktrees/` + hook `worktree-guard.sh` bloqueia qualquer path fora de `/worktrees/`.
**Depois:** Hook atualizado pra bloquear `git worktree add` COMPLETAMENTE — força uso do script atômico.

### 2. Concierge pulava spec/plan e ia direto pro código

**Problema:** Sem enforcement, o AI ignora as regras de markdown e sai codando.
**Solução:** Hook `spec-gate.sh` — bloqueia escrita de arquivos `.py/.js/.ts` se `spec.md` e `plan.md` não existem no worktree. Exit 2 = bloqueado.

### 3. Beads criados antes da spec (sem complexidade real)

**Problema:** Beads eram criados na Fase 2 pelo Concierge, antes de qualquer investigação.
**Solução:** Separação de papéis: Concierge = PORTEIRO (fases 0-2), Agent = EXECUTOR (fases 3-7). Beads são criados pelo Agent DEPOIS do plan.md.

### 4. ClickUp gastava tokens demais pra encontrar IDs

**Problema:** Toda sessão, o Concierge fazia 5-10 API calls pra descobrir workspace/space/list IDs.
**Solução:** IDs hardcoded no CLAUDE.md com curl commands prontos pra copiar-colar. Token var corrigida: `CLICKUP_API_TOKEN` (era `CLICKUP_API_KEY`).

### 5. Worktrees criados sem HANDOFF.md

**Problema:** Concierge criava worktree mas não escrevia HANDOFF.md. Agent abria sessão sem contexto.
**Solução:** Script atômico `create-worktree.sh` — cria worktree + busca ClickUp + escreve HANDOFF.md com YAML frontmatter, tudo numa operação. `git worktree add` direto é BLOQUEADO.

### 6. Volume `~/.claude/` sobrescrevia hooks do build

**Problema:** Volume `cli-auth-claude` sobrescreve `~/.claude/` inteiro, apagando hooks copiados no Dockerfile.
**Solução:** Hooks ficam em `/opt/hooks/` (build-time) → `entrypoint.sh` copia pra `~/.claude/hooks/` (runtime, depois do volume mount).

### 7. SSH host key mismatch após rebuild

**Problema:** Cada rebuild gera nova SSH key. Maestro recusa conexão.
**Solução:** `ssh-keygen -R "[localhost]:2225"` + `ssh -o StrictHostKeyChecking=no`. Recorrente — acontece em TODO rebuild.

---

## Arquitetura Final

```
CONCIERGE (em /workspace, fases 0-2)
├── Boas-vindas
├── Coleta (ClickUp auto-fetch / freestyle)
├── Freestyle → cria task no ClickUp primeiro
├── Propõe worktrees (tabela) → dev aprova
├── Roda create-worktree.sh (atômico)
│     → /worktrees/<nome>/ + HANDOFF.md
└── FIM. Reporta paths.

AGENT (em /worktrees/<nome>, fases 3-7)
├── SessionStart → handoff-injector.sh → contexto injetado
├── spec.md (investigação, sem código)
├── plan.md (Task Atom format)
├── Beads (bd create, a partir do plan)
├── Código (1 commit = 1 step, hook bloqueia sem spec)
├── PR (hook bloqueia push pra main/develop)
├── Merge + cleanup worktree
└── Release (gate humano)
```

## O que falta testar

| Item | Status |
|------|--------|
| Concierge segue CLAUDE.md e usa o script | ❓ Não testado com Maestro ainda |
| Handoff-injector injeta contexto real | ✅ Testado manualmente |
| Agent lê HANDOFF.md e faz spec primeiro | ❓ Não testado |
| ClickUp auto-fetch funciona | ❓ Precisa MEMBER_ID do dev |
| Freestyle → cria task no ClickUp | ❓ Não testado |
| CI + CodeRabbit no PR | ✅ Funciona (testado antes) |
| SSH pós-rebuild | ⚠️ Recorrente — sempre limpar key |

---

## Próximos passos pra sessão limpa

1. **Limpar SSH key** antes de conectar Maestro
2. **Testar Concierge end-to-end:** abrir session em `/workspace` → "puxa do clickup"
3. **Verificar se o Concierge usa o script** (hook deve bloquear `git worktree add` direto)
4. **Testar Agent no worktree:** abrir session no worktree → deve ver HANDOFF.md injetado
5. **Pegar MEMBER_ID do ClickUp** pra auto-fetch funcionar:
   ```bash
   curl -s -H "Authorization: $CLICKUP_API_TOKEN" "https://api.clickup.com/api/v2/team/9011530618" | jq '.team.members[] | {id: .user.id, username: .user.username}'
   ```

## Arquivos-chave pra ler na sessão nova

```
spalla-dashboard/.claude/CLAUDE.md            ← Persona + ClickUp IDs
spalla-dashboard/.claude/concierge-path.md    ← Metodologia v1.0
spalla-dashboard/.claude/concierge-flow.yaml  ← Fluxo YAML
spalla-dashboard/.claude/scripts/create-worktree.sh  ← Script atômico
spalla-dashboard/.devcontainer/hooks/         ← 5 hooks
spalla-dashboard/.devcontainer/Dockerfile.dev ← Build do container
spalla-dashboard/.devcontainer/entrypoint.sh  ← Sync hooks + env vars
```
