# Handoff — Concierge Path v2

> Para outra sessão pegar e executar.

---

## Contexto

O **Dev Concierge** é o squad que guia o dev do planejamento ao deploy dentro de containers Docker, via Maestro (SSH). A v1 está completa e pushed.

## O que é a v1 (DONE)

Metodologia em 8 fases com gates bloqueantes:

```
FASE 0  Setup Container → 🔒 ENV_READY
FASE 1  ClickUp auto-fetch → 🔒 SESSION_PLANNED
FASE 2  Worktrees (batch) → 🔒 WORKTREES_READY
FASE 3  Spec → Plan → Beads → 🔒 SPEC_APPROVED
FASE 4  Desenvolvimento → 🔒 CODE_CLEAN
FASE 5  PR + Review → 🔒 PR_APPROVED
FASE 6  Merge + Cleanup → 🔒 MERGE_COMPLETE
FASE 7  Release → 🔒 DEPLOY_OK
```

## O que é a v2 (TODO)

A v2 transforma o output da FASE 3 (spec/plan) em **Maestro Auto Run Playbooks** que rodam autonomamente, em paralelo, de madrugada.

### Features v2

1. **Output = Auto Run Playbook**
   - Após FASE 3 (spec/plan), gerar playbook Maestro (pasta com N `.md` numerados)
   - Usar o squad `autorun-playbook-creation` como conversor
   - Ref: `~/.claude/commands/global/squad/autorun-playbook-creation.md`
   - Ref: `~/.claude/squads/playbook-translator/` (agents, templates, workflows)
   - Fluxo: `spec.md` + `plan.md` → playbook-translator → pasta Auto Run

2. **Multi-Claude Account Randomization**
   - FASE 0 pede ao dev pra logar N contas Claude
   - Mecanismo: `CLAUDE_CONFIG_DIR` por conta (docs: https://docs.runmaestro.ai/multi-claude)
   - Setup: `claude login` → `cp -a ~/.claude ~/.claude-<conta>` → symlinks
   - Concierge distribui worktrees entre contas round-robin
   - No Maestro: cada agent tem env var `CLAUDE_CONFIG_DIR` diferente

3. **Night Mode (Batch Execution)**
   - Após gerar playbooks pra todas as worktrees do dia
   - Dev sai, lança batch: todos os Auto Runs rodam em paralelo
   - Resultado de manhã: N PRs prontos pra review
   - Distribuídos entre contas Claude → zero rate limit

4. **Account Setup no Container**
   - `entrypoint.sh` detecta pastas `~/.claude-*` automaticamente
   - Reporta contas disponíveis ao Concierge na FASE 0
   - Concierge atribui conta por worktree

## Arquivos Relevantes

| Arquivo | O que é | Repo |
|---------|---------|------|
| [concierge-path.md](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.claude/concierge-path.md) | Metodologia v1 completa (atualizar pra v2) | spalla-dashboard |
| [rules/concierge-path.md](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.claude/rules/concierge-path.md) | Rules enforcement (carrega em toda sessão) | spalla-dashboard |
| [CLAUDE.md](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.claude/CLAUDE.md) | Persona + onboarding do Dev Concierge | spalla-dashboard |
| [guia-operacional.md](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/dev-playbook/guides/guia-operacional.md) | Guia oficial v1.0 (§18 = Concierge) | dev-playbook |
| [autorun-playbook-creation.md](file:///Users/felipegobbi/.claude/commands/global/squad/autorun-playbook-creation.md) | Squad que traduz artifacts em playbooks | ~/.claude global |
| [Dockerfile.dev](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.devcontainer/Dockerfile.dev) | Container com AI CLIs | spalla-dashboard |
| [docker-compose.dev.yml](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.devcontainer/docker-compose.dev.yml) | Config do container | spalla-dashboard |
| [entrypoint.sh](file:///Users/felipegobbi/Documents/VibeworkV2/apps/case/spalla-dashboard/.devcontainer/entrypoint.sh) | Persiste env vars pra SSH | spalla-dashboard |

## Task Atom (formato obrigatório)

Cada step de um playbook DEVE ter:

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| **what** | SIM | "Adicionar rota de login" |
| **target** | SIM | `/workspace/app/backend/server.py` → `login_route` |
| **integration** | SIM | "Chamado por AuthController" |
| **success_criteria** | SIM | `curl localhost:9999/api/health` → 200 |
| **rollback** | recomendado | `git revert HEAD` |
| **constraints** | recomendado | "NÃO modificar fora de app/backend/" |

## Portas SSH

| Repo | Porta |
|------|-------|
| frankflow | 2222 |
| meta-search | 2223 |
| queue-processor | 2224 |
| spalla-dashboard | 2225 |

## Gotchas da v1 (levar pra v2)

- SSH host key mismatch → `ssh-keygen -R "[localhost]:<porta>"`
- Claude login DEVE ser do Terminal Mac, NÃO do Maestro
- `docker compose down -v` DESTRÓI tokens. Sem `-v` preserva.
- Worktrees SEMPRE em `../<repo>-worktrees/` (fora do repo)
- Beads DEPOIS da spec, NUNCA antes
- `CLICKUP_API_TOKEN` (não KEY)

## Próximos Passos (ordem sugerida)

1. Ler `autorun-playbook-creation.md` + squad `playbook-translator`
2. Definir como `spec.md` + `plan.md` viram input do translator
3. Implementar multi-Claude setup no `entrypoint.sh` (detectar `~/.claude-*`)
4. Atualizar `CLAUDE.md` com fluxo v2 (perguntar quantas contas, oferecer batch)
5. Atualizar `concierge-path.md` FASE 3 pra incluir geração de playbook
6. Testar end-to-end: 1 feature → spec → plan → playbook → Auto Run → PR
7. Atualizar `guia-operacional.md` §18 com v2

---

> Criado em 16/Mar/2026 — sessão Dev Playbook Setup
