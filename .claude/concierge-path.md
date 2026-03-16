# Concierge Path — Metodologia de Desenvolvimento

> Metodologia rígida do Dev Concierge Squad. Padrão Task Atom.
> Cada GATE é bloqueante. Sem atalhos. Sem exceções.

---

## Fluxo Geral

```
FASE 0  Setup do Ambiente (uma vez por repo)
   ↓ 🔒 GATE: ENV_READY
FASE 1  Recepção e Planejamento da Sessão (ClickUp auto-fetch)
   ↓ 🔒 GATE: SESSION_PLANNED
FASE 2  Criação de Worktrees (batch, SEM beads ainda)
   ↓ 🔒 GATE: WORKTREES_READY
FASE 3  Spec → Plan → Tasks → Beads (dentro de cada worktree)
   ↓ 🔒 GATE: SPEC_APPROVED
FASE 4  Desenvolvimento (código)
   ↓ 🔒 GATE: CODE_CLEAN
FASE 5  PR + Review
   ↓ 🔒 GATE: PR_APPROVED
FASE 6  Merge + Cleanup
   ↓ 🔒 GATE: MERGE_COMPLETE
FASE 7  Release (gate humano)
   ↓ 🔒 GATE: DEPLOY_OK
```

## Modelo de Dados

```
ClickUp Task (estratégico — fonte de verdade)
  └── Worktree (ambiente isolado — 1 por task)
        └── Spec (entendimento do problema)
              └── Plan (decomposição em steps)
                    └── Tasks → Beads (tracking com deps)
                          └── Código → PR → Merge
```

**Regra:** Beads são criados DEPOIS da spec/plan. A spec revela a complexidade real.

---

## FASE 0 — Setup do Ambiente (uma vez por repo)

### 0.1 — Docker Desktop

- [ ] **what:** Verificar Docker Desktop rodando
- **target:** Host Mac → Docker Desktop.app
- **success_criteria:** `docker info` retorna sem erro
- **rollback:** Abrir Docker Desktop manualmente

### 0.2 — Build do container

- [ ] **what:** Build da imagem do devcontainer
- **target:** `/workspace/.devcontainer/Dockerfile.dev`
- **success_criteria:** `docker compose -f /workspace/.devcontainer/docker-compose.dev.yml build` exit code 0
- **constraints:** NÃO modificar Dockerfile sem aprovação

### 0.3 — Subir container

- [ ] **what:** Iniciar container em background
- **target:** `/workspace/.devcontainer/docker-compose.dev.yml`
- **success_criteria:** `docker ps --filter name=spalla-dev` → STATUS: Up
- **rollback:** `docker compose down && docker compose up -d`

### 0.4 — Verificar SSH

- [ ] **what:** Confirmar acesso SSH ao container
- **target:** Host Mac → SSH → `vscode@localhost:2225`
- **success_criteria:** `ssh -o StrictHostKeyChecking=no -p 2225 vscode@localhost hostname` retorna hash
- **rollback:** `ssh-keygen -R "[localhost]:2225"` e repetir

### 0.5 — Verificar credenciais

- [ ] **what:** Confirmar tokens e CLIs funcionais
- **target:** `/workspace/.devcontainer/.env`
- **success_criteria:**
  - `echo $GITHUB_TOKEN` → não vazio
  - `echo $CLICKUP_API_TOKEN` → não vazio
  - `claude --version` → versão
  - `gh auth status` → ✓ Logged in
  - `bd --version` → versão
- **rollback:** Verificar `.devcontainer/.env` e `entrypoint.sh`

### 0.6 — Autenticar Claude Code (se primeira vez)

- [ ] **what:** Login OAuth do Claude Code dentro do container
- **target:** Volume Docker `spalla-cli-auth-claude`
- **constraints:** ⚠️ EXECUTAR DO TERMINAL DO MAC, NÃO DO MAESTRO
- **success_criteria:** `ssh -t -p 2225 vscode@localhost claude login` → "Successfully logged in"

### 0.7 — Registrar no Maestro

- [ ] **what:** Adicionar SSH host no Maestro.app
- **target:** `~/Library/Application Support/maestro/maestro-settings.json`
- **spec:** Name: `spalla-dev`, Host: `localhost`, Port: `2225`, User: `vscode`, Key: `~/.ssh/id_ed25519`, Working Dir: `/workspace`
- **success_criteria:** Maestro → Test Connection → verde

### 0.8 — Validar sessão

- [ ] **what:** Dev Concierge responde no Maestro
- **target:** Maestro.app → nova session em `spalla-dev`
- **success_criteria:** Enviar "oi" → Concierge responde com boas-vindas + oferece ClickUp

### 🔒 GATE: ENV_READY

| Check | Comando | Esperado |
|-------|---------|----------|
| Container up | `docker ps --filter name=spalla-dev` | Up |
| SSH | `ssh -p 2225 vscode@localhost hostname` | Hash |
| Claude | `claude --version` | Versão |
| GitHub | `gh auth status` | ✓ Logged in |
| Beads | `bd --version` | Versão |
| Maestro | Nova session | Concierge aparece |

> ❌ **NÃO AVANÇA** sem 6/6.

---

## FASE 1 — Recepção e Planejamento

### 1.1 — Boas-vindas + auto-fetch ClickUp

- [ ] **what:** Buscar tarefas do dev no ClickUp OU aceitar input manual
- **target:** ClickUp API → `GET /team/{team_id}/task?assignees[]={user_id}&statuses[]=to+do&statuses[]=in+progress`
- **spec:**
  - Se tem tasks atribuídas ao dev → listar e sugerir priorização
  - Se NÃO tem tasks atribuídas → listar TODAS e perguntar quais pegar
  - Se dev prefere manual → aceitar links ou descrição livre
- **integration:** `CLICKUP_API_TOKEN` do env → header `Authorization`

### 1.2 — Classificar cada demanda

- [ ] **what:** Determinar Stream de cada task
- **spec:**
  - "Gera código que RODA em produção?" → SIM = CODE → branch `feat/` ou `fix/`
  - NÃO = KNOWLEDGE → branch `content/`
- **success_criteria:** Cada item tem tipo definido

### 1.3 — Ler contexto do ClickUp (TODAS as tasks)

- [ ] **what:** Ler briefing de CADA task selecionada
- **target:** ClickUp API → `GET /task/{task_id}` PRA CADA task
- **spec:**
  - Extrair: título, descrição, checklists, anexos
  - Avaliar se 1 task gera 1 ou N worktrees
  - REPETIR para TODAS. NÃO pular nenhuma.

### 1.4 — Propor plano de worktrees

- [ ] **what:** Apresentar tabela de worktrees propostas
- **spec:**

| # | Tipo | Worktree | Branch | Escopo | ClickUp |
|---|------|----------|--------|--------|---------|
| 1 | feat | widget-zoom | feature/widget-zoom | `app/frontend/` | CU-abc123 |
| 2 | fix | login-redirect | fix/login-redirect | `app/backend/` | CU-xyz789 |

- **success_criteria:** Dev confirma explicitamente ("ok", "vai", "confirma")
- **constraints:** NÃO criar worktrees sem aprovação.

### 🔒 GATE: SESSION_PLANNED

| Check | Critério |
|-------|----------|
| ≥1 task | Tabela tem pelo menos 1 linha |
| Classificadas | Tipo definido pra cada |
| Dev aprovou | Confirmação explícita |

> ❌ **NÃO CRIA WORKTREES** sem aprovação.

---

## FASE 2 — Criação de Worktrees (batch, SEM beads)

### 2.1 — Atualizar develop

- [ ] **what:** Sincronizar develop local com remote
- **target:** `/workspace`
- **success_criteria:** `git checkout develop && git pull origin develop` → up to date
- **rollback:** `git stash && git pull --rebase && git stash pop`

### 2.2 — Criar Worktrees (batch)

- [ ] **what:** Criar todos os worktrees de uma vez
- **target:** `/workspace/../spalla-dashboard-worktrees/`
- **spec:**
  - `mkdir -p /workspace/../spalla-dashboard-worktrees`
  - Para cada: `git worktree add -b <branch> ../spalla-dashboard-worktrees/<nome> develop`
- **success_criteria:** `git worktree list` → todos listados
- **constraints:** Worktrees SEMPRE fora do repo (sibling). NUNCA dentro.

### 2.3 — Reportar resultado

- [ ] **what:** Apresentar tabela final
- **success_criteria:** Tabela com: #, Nome, Branch, Path, Status (✅)
- **integration:** Instruir dev: "Aponte o Maestro pra `spalla-dashboard-worktrees/`"

### 🔒 GATE: WORKTREES_READY

| Check | Comando | Esperado |
|-------|---------|----------|
| Worktrees existem | `git worktree list` | Todos os paths |
| Branches existem | `git branch` | feature/*, fix/*, content/* |

> ❌ **NÃO COMEÇA SPEC** sem worktrees validados.
> ⚠️ Note: ZERO beads existem neste ponto. É intencional.

---

## FASE 3 — Spec → Plan → Tasks → Beads (dentro de cada worktree)

> Esta fase acontece DENTRO de cada worktree isoladamente.
> É aqui que o problema é entendido e a complexidade real revelada.

### 3.1 — Spec (entender o problema)

- [ ] **what:** Analisar requisitos e escrever especificação
- **target:** `<worktree>/spec.md`
- **spec:**
  - Ler briefing do ClickUp (já extraído na FASE 1)
  - Investigar código existente no escopo
  - Documentar: o que precisa mudar, por quê, impacto
  - Listar dependências e riscos
- **success_criteria:** `spec.md` escrito e coerente
- **constraints:** SPEC É LEITURA. Zero código nesta fase.

### 3.2 — Plan (decompor em steps)

- [ ] **what:** Criar plano de execução a partir da spec
- **target:** `<worktree>/plan.md`
- **spec:**
  - Quebrar a spec em steps atômicos (Task Atom format)
  - Cada step tem: what, target (arquivo exato), success_criteria, rollback, constraints
  - Definir ordem e dependências entre steps
  - Estimar esforço
- **success_criteria:** `plan.md` com N steps numerados, cada um no formato Task Atom

### 3.3 — Tasks → Beads

- [ ] **what:** Criar Beads a partir do plan (AGORA sim)
- **target:** `/workspace/.beads/issues.jsonl`
- **spec:**
  - Bead PAI: `bd create "feat: widget zoom (CU-abc123)"`
  - Beads filhos (1 por step do plan): `bd create "sub: setup routes" --parent <PAI>`
  - Dependências: `bd dep add <B> <A>` (B depende de A)
- **success_criteria:** `bd list` → todos criados com deps corretas
- **constraints:** Cada bead = 1 step do plan. Escopo atômico.

### 3.4 — Sync ClickUp

- [ ] **what:** Atualizar ClickUp com progresso
- **target:** ClickUp API → `PUT /task/{task_id}`
- **spec:** Status → "in progress", comment com links dos Beads

### 🔒 GATE: SPEC_APPROVED

| Check | Critério |
|-------|----------|
| spec.md existe | Arquivo escrito no worktree |
| plan.md existe | Steps atômicos no formato Task Atom |
| Beads criados | `bd children <PAI>` → filhos com deps |
| ClickUp atualizado | Status = in progress |

> ❌ **NÃO COMEÇA A CODAR** sem spec + plan + beads.

---

## FASE 4 — Desenvolvimento (por worktree, paralelo)

### 4.1 — Confirmar branch

- [ ] **what:** Verificar worktree e branch corretos
- **success_criteria:** `git branch --show-current` retorna branch planejada

### 4.2 — Implementar dentro do escopo

- [ ] **what:** Escrever código seguindo o plan.md step by step
- **target:** Diretórios da coluna "Escopo" (FASE 1)
- **constraints:**
  - Seguir a ORDEM dos steps do plan
  - NUNCA modificar fora do escopo
  - Arquivo SHARED → PARAR e perguntar
  - NUNCA commitar `.env`, `.key`, `.pem`, `*secret*`

### 4.3 — Commits atômicos

- [ ] **what:** 1 commit = 1 step do plan, formato convencional
- **spec:** `tipo(escopo): descrição #BEAD-ID` (max 72 chars)

### 4.4 — Sync com develop

- [ ] **what:** Rebase periódico (mínimo 1x por sessão)
- **spec:** `git fetch origin develop && git rebase origin/develop`
- **rollback:** `git rebase --abort`

### 4.5 — Atualizar Beads

- [ ] **what:** Marcar progresso nos Beads filhos
- **spec:** `bd update <BEAD-FILHO> --status in_progress` → `done` conforme completa cada step
- **integration:** Se sub-bead falhou → `bd update <ID> --status blocked` → deps param

### 🔒 GATE: CODE_CLEAN

| Check | Critério |
|-------|----------|
| Branch atualizada | Rebase sem conflitos |
| Commits convencionais | `tipo(escopo): desc #ID` |
| Sem secrets | Zero .env/.key no stage |
| Escopo respeitado | Só dentro do planejado |
| `git status` limpo | Nada pendente |

> ❌ **NÃO FAZ PUSH** com status sujo.

---

## FASE 5 — PR + Review

### 5.1 — Push

- [ ] **what:** `git push -u origin <branch>` → success

### 5.2 — Criar PR

- [ ] **what:** `gh pr create --base develop --title "tipo(escopo): desc" --body "Bead: SPALLA-XX\nClickUp: CU-xxx"`
- **constraints:** NUNCA PR pra main

### 5.3 — Esperar CI + CodeRabbit

- [ ] **what:** Aguardar pipeline automático
- **success_criteria:** CI verde + CodeRabbit comentou

### 5.4 — Auto-fix loop (max 5x)

- [ ] **what:** Ler feedback → corrigir → push → repetir
- **rollback:** 5 retries esgotados → `bd update <ID> --status blocked`

### 5.5 — Sync ClickUp

- [ ] **what:** Link do PR na task ClickUp

### 🔒 GATE: PR_APPROVED — CI verde + CodeRabbit limpo + PR pra develop + sem conflitos

---

## FASE 6 — Merge + Cleanup

### 6.1 — `gh pr merge --squash`
### 6.2 — `bd close <BEAD-PAI>`
### 6.3 — `git worktree remove` + `git worktree prune` + `git branch -d`
### 6.4 — `git checkout develop && git pull origin develop`
### 6.5 — ClickUp → status done

### 🔒 GATE: MERGE_COMPLETE — PR merged + Bead closed + worktree removido + develop atualizado

---

## FASE 7 — Release (gate humano)

### 7.1 — `gh pr create --base main --head develop --title "release: vX.Y.Z"`
### 7.2 — Aprovação HUMANA (Concierge NÃO mergeia sozinho)
### 7.3 — `gh pr merge --merge` (NÃO squash) + `git tag vX.Y.Z`

### 🔒 GATE: DEPLOY_OK — main atualizada + tag + deploy ok

---

## Gotchas

| # | Gotcha | Solução |
|---|--------|---------|
| 1 | SSH host key mismatch | `ssh-keygen -R "[localhost]:2225"` |
| 2 | Claude não autenticado | `ssh -t -p 2225 vscode@localhost claude login` (Terminal Mac) |
| 3 | GITHUB_TOKEN missing | Verificar `/workspace/.devcontainer/.env` |
| 4 | CLICKUP_API_TOKEN missing | Verificar `/workspace/.devcontainer/.env` |
| 5 | `bd` not found | `sudo npm install -g @beads/bd` + `/workspace/.devcontainer/Dockerfile.dev:L56` |
| 6 | Env vars não chegam via SSH | Verificar `/workspace/.devcontainer/entrypoint.sh` |
| 7 | Push rejeitado | `git stash && git pull --rebase && git stash pop && git push` |
| 8 | Worktree dentro do repo | SEMPRE em `../<repo>-worktrees/` |
| 9 | Container novo por feature | Usar worktree no MESMO container |
| 10 | Push direto pra main | SEMPRE via PR pra develop |
| 11 | Secrets no commit | Verificar `.gitignore` |
| 12 | Volume destruído com `-v` | `down` SEM `-v` preserva auth |
| 13 | Sub-bead falhou | `bd update <ID> --status blocked` → deps param |
| 14 | Beads criados antes da spec | ❌ ERRADO. Spec revela complexidade. Beads vêm DEPOIS. |

---

## Saga Pattern

| Cenário | Ação |
|---------|------|
| Auto-fix esgotou 5 retries | `bd update --status blocked` → próxima task |
| Sub-bead falhou (step 8 de 15) | Steps 1-7 preservados, 9-15 bloqueados |
| Task dependente bloqueada | Espera dep resolver → `bd gate check` |
| Sessão falhou | Worktrees permanecem → `*status` na próxima |

---

## v2 Roadmap (planejado)

> Tudo caminha pro playbook. v2 transforma o output da FASE 3 em Auto Run Playbooks autônomos.

### Features v2

1. **Output = Maestro Auto Run Playbook**
   - FASE 3 (spec/plan) gera playbook com N `.md` numerados
   - Usa squad `autorun-playbook-creation` como conversor
   - Dev planeja de dia → playbooks geram → machine executa de madrugada

2. **Multi-Claude Account Randomization**
   - FASE 0 pede ao dev pra logar N contas Claude (via `CLAUDE_CONFIG_DIR`)
   - Concierge distribui worktrees entre contas round-robin
   - Ex: 5 worktrees na conta A, 5 na conta B → zero rate limit

3. **Night Mode (Batch Execution)**
   - Comando único lança todos os Auto Runs em paralelo
   - Resultado de manhã: N PRs prontos pra review

4. **Account Setup no Container**
   - `entrypoint.sh` detecta todas as pastas `~/.claude-*`
   - Concierge escolhe automaticamente qual conta usar por worktree

---

> **Concierge Path v1.0** — 16/Mar/2026 — Baseado em guia-operacional.md v1.0 + Task Atom + Beads gates
