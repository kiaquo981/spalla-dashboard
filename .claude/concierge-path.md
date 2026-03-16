# Concierge Path — Metodologia de Desenvolvimento

> Metodologia rígida do Dev Concierge Squad. Padrão Task Atom.
> Cada GATE é bloqueante. Sem atalhos. Sem exceções.

---

## Modelo de Dados

```
ClickUp List (fonte de verdade das demandas)
  └── ClickUp Task (estratégico — PRD, briefing)
        └── Bead PAI (tático — tracking dev)
              ├── Bead FILHO 1 → Worktree → PR (execução)
              ├── Bead FILHO 2 → Worktree → PR
              └── GATE: human (espera review)
```

**Beads commands:**
- `bd create "descrição" --parent <PAI>` → cria filho
- `bd children <PAI>` → lista filhos
- `bd dep add <B> <A>` → B depende de A
- `bd gate` → travas assíncronas (human, gh:pr, bead)
- `bd update <ID> --status blocked` → marca como travado (filhos param)

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
- **rollback:** `docker compose -f /workspace/.devcontainer/docker-compose.dev.yml down && docker compose -f /workspace/.devcontainer/docker-compose.dev.yml up -d`

### 0.4 — Verificar SSH

- [ ] **what:** Confirmar acesso SSH ao container
- **target:** Host Mac → SSH → `vscode@localhost:2225`
- **success_criteria:** `ssh -o StrictHostKeyChecking=no -p 2225 vscode@localhost hostname` retorna hash do container
- **rollback:** `ssh-keygen -R "[localhost]:2225"` e repetir

### 0.5 — Verificar credenciais dentro do container

- [ ] **what:** Confirmar que tokens e CLIs estão funcionais
- **target:** `/workspace/.devcontainer/.env` (GITHUB_TOKEN + CLICKUP_API_TOKEN)
- **success_criteria:**
  - `ssh -p 2225 vscode@localhost 'echo $GITHUB_TOKEN'` → não vazio
  - `ssh -p 2225 vscode@localhost 'echo $CLICKUP_API_TOKEN'` → não vazio
  - `ssh -p 2225 vscode@localhost 'claude --version'` → versão
  - `ssh -p 2225 vscode@localhost 'gh auth status'` → ✓ Logged in
  - `ssh -p 2225 vscode@localhost 'bd --version'` → versão
- **rollback:** Verificar `/workspace/.devcontainer/.env` e `/workspace/.devcontainer/entrypoint.sh`

### 0.6 — Autenticar Claude Code (se primeira vez)

- [ ] **what:** Login OAuth do Claude Code dentro do container
- **target:** Volume Docker `spalla-cli-auth-claude` → `/home/vscode/.claude/`
- **constraints:** ⚠️ EXECUTAR DO TERMINAL DO MAC, NÃO DO MAESTRO
- **success_criteria:** `ssh -t -p 2225 vscode@localhost claude login` → "Successfully logged in"
- **rollback:** `docker compose -f /workspace/.devcontainer/docker-compose.dev.yml down` (SEM `-v`) e `up -d`

### 0.7 — Registrar no Maestro

- [ ] **what:** Adicionar SSH host no Maestro.app
- **target:** `~/Library/Application Support/maestro/maestro-settings.json`
- **spec:**
  - Name: `spalla-dev`
  - Host: `localhost`
  - Port: `2225`
  - User: `vscode`
  - Key: `~/.ssh/id_ed25519`
  - Working Dir: `/workspace`
  - Default Shell: Bash
- **success_criteria:** Maestro → Test Connection → verde

### 0.8 — Validar sessão

- [ ] **what:** Verificar que o Dev Concierge responde no Maestro
- **target:** Maestro.app → nova session em `spalla-dev`
- **success_criteria:** Enviar "oi" → Dev Concierge responde com boas-vindas e pergunta de planejamento
- **rollback:** Verificar `/workspace/.claude/CLAUDE.md` contém persona Dev Concierge

### 🔒 GATE: ENV_READY

| Check | Comando | Esperado |
|-------|---------|----------|
| Container up | `docker ps --filter name=spalla-dev` | STATUS: Up |
| SSH | `ssh -p 2225 vscode@localhost hostname` | Hash |
| Claude | `claude --version` (dentro do container) | Versão |
| GitHub | `gh auth status` (dentro do container) | ✓ Logged in |
| Beads | `bd --version` (dentro do container) | Versão |
| Maestro | Nova session responde | Concierge aparece |

> ❌ **NÃO AVANÇA** sem 6/6 checks verdes.

---

## FASE 1 — Recepção e Planejamento

### 1.1 — Boas-vindas

- [ ] **what:** Exibir persona Dev Concierge e iniciar planejamento
- **target:** `/workspace/.claude/CLAUDE.md` → seção "Boas-vindas"
- **success_criteria:** Mensagem com "O que vamos trabalhar hoje?" exibida

### 1.2 — Auto-fetch ClickUp

- [ ] **what:** Buscar tarefas do dev no ClickUp automaticamente
- **target:** ClickUp API → `GET /team/{team_id}/task?assignees[]={user_id}&statuses[]=to+do&statuses[]=in+progress`
- **success_criteria:** Tabela de tasks retornada ao dev
- **spec:**
  - Se tem tasks atribuídas ao dev → listar e sugerir priorização
  - Se NÃO tem tasks atribuídas → listar TODAS da lista e perguntar quais pegar
  - Se dev prefere input manual → aceitar descrição livre ou link direto
- **integration:** `CLICKUP_API_TOKEN` do env → header `Authorization`
- **constraints:** NÃO forçar ClickUp se dev quer input manual

### 1.3 — Classificar cada demanda

- [ ] **what:** Determinar Stream de cada task selecionada
- **target:** Decisão baseada na pergunta: "Isso gera código que RODA em produção?"
- **spec:**
  - SIM → Stream A (CODE) → branch `feat/` ou `fix/`
  - NÃO → Stream B (KNOWLEDGE) → branch `content/`
- **success_criteria:** Cada item tem tipo (feat/fix/refactor/hotfix/content) definido

### 1.4 — Ler contexto do ClickUp (TODAS as tasks)

- [ ] **what:** Ler briefing de CADA task selecionada no ClickUp
- **target:** ClickUp API → `GET /task/{task_id}` PRA CADA task
- **success_criteria:** Para cada task: título, descrição, checklists, anexos extraídos
- **spec:**
  - Avaliar se 1 task do ClickUp gera 1 ou N worktrees
  - Se task grande demais → propor decomposição em N beads filhos
  - REPETIR para TODAS as tasks, não uma por vez
- **constraints:** NÃO pular nenhuma task. TODAS passam por este step.

### 1.5 — Propor plano de worktrees

- [ ] **what:** Apresentar tabela de worktrees propostas ao dev
- **target:** Output formatado como tabela markdown
- **spec:**

| # | Tipo | Worktree | Branch | Escopo | ClickUp | Beads |
|---|------|----------|--------|--------|---------|-------|
| 1 | feat | widget-zoom | feature/widget-zoom | `app/frontend/` | CU-abc123 | SPALLA-14 |
| 2 | fix | login-redirect | fix/login-redirect | `app/backend/` | CU-xyz789 | SPALLA-15 |
| 3 | content | playbook-update | content/playbook-update | `docs/` | CU-def456 | SPALLA-16 |

- **success_criteria:** Dev diz "ok", "confirma", "vai", ou similar
- **constraints:** NÃO criar worktrees sem aprovação EXPLÍCITA. Se ajustar → refazer tabela → confirmar de novo.

### 🔒 GATE: SESSION_PLANNED

| Check | Critério |
|-------|----------|
| ≥1 task definida | Tabela tem pelo menos 1 linha |
| Cada task classificada | Tipo (feat/fix/content) definido |
| Plano apresentado | Tabela formatada exibida |
| Dev aprovou | Confirmação explícita registrada |

> ❌ **NÃO CRIA NENHUM WORKTREE** sem aprovação explícita.

---

## FASE 2 — Criação de Worktrees + Beads (batch)

### 2.1 — Atualizar develop

- [ ] **what:** Garantir develop local sincronizado com remote
- **target:** `/workspace` (repo principal)
- **success_criteria:**
  - `git checkout develop` → ok
  - `git pull origin develop` → Already up to date (ou fast-forward)
- **rollback:** `git stash && git pull --rebase && git stash pop`
- **constraints:** PARA TUDO se conflito não-resolvível

### 2.2 — Criar Beads (pai + filhos)

- [ ] **what:** Criar 1 Bead PAI por task do ClickUp + N Beads filhos por sub-etapa
- **target:** `/workspace/.beads/issues.jsonl`
- **spec:**
  - Bead PAI: `bd create "feat: widget zoom (CU-abc123)"`
  - Beads filhos: `bd create "sub: setup routes" --parent SPALLA-14`
  - Dependências: `bd dep add SPALLA-14b SPALLA-14a` (b depende de a)
- **success_criteria:** `bd list` → todos os beads criados com status open
- **constraints:** Cada sub-bead deve ter escopo claro e atômico

### 2.3 — Criar Worktrees (batch)

- [ ] **what:** Criar todos os worktrees de uma vez
- **target:** `/workspace/../spalla-dashboard-worktrees/`
- **spec:**
  - `mkdir -p /workspace/../spalla-dashboard-worktrees`
  - Para cada: `git worktree add -b <branch> /workspace/../spalla-dashboard-worktrees/<nome> develop`
- **success_criteria:** `git worktree list` → todos listados
- **constraints:** Worktrees SEMPRE fora do repo (sibling). NUNCA dentro.
- **rollback:** `git worktree remove <path>` e repetir

### 2.4 — Reportar resultado

- [ ] **what:** Apresentar tabela final com todos os worktrees criados
- **target:** Output formatado
- **success_criteria:** Tabela com colunas: #, Nome, Branch, Bead, Path, Status (✅)
- **integration:** Instruir dev: "Aponte o Maestro pra `spalla-dashboard-worktrees/`"

### 2.5 — Sync ClickUp

- [ ] **what:** Atualizar ClickUp com progresso
- **target:** ClickUp API → `PUT /task/{task_id}`
- **spec:**
  - Status da task → "in progress"
  - Comment com links dos Beads
- **success_criteria:** Status atualizado no ClickUp

### 🔒 GATE: WORKTREES_READY

| Check | Comando | Esperado |
|-------|---------|----------|
| Beads criados | `bd list` | Todos open |
| Worktrees existem | `git worktree list` | Todos os paths |
| Branches existem | `git branch` | feature/*, fix/*, content/* |
| Maestro descobre | Abrir Maestro em worktree-root | Subpastas visíveis |

> ❌ **NÃO COMEÇA A CODAR** sem 4/4 checks.

---

## FASE 3 — Desenvolvimento (por worktree, paralelo)

### 3.1 — Entrar no worktree

- [ ] **what:** Navegar para o worktree e confirmar branch
- **target:** `/workspace/../spalla-dashboard-worktrees/<nome>/`
- **success_criteria:** `git branch --show-current` retorna branch planejada

### 3.2 — Implementar dentro do escopo

- [ ] **what:** Escrever código APENAS nos diretórios do plano
- **target:** Diretórios da coluna "Escopo" (FASE 1)
- **constraints:**
  - NUNCA modificar fora do escopo
  - Arquivo SHARED → PARAR e perguntar
  - NUNCA commitar `.env`, `.key`, `.pem`, `*secret*`

### 3.3 — Commits atômicos

- [ ] **what:** 1 commit = 1 unidade lógica, formato convencional
- **spec:** `tipo(escopo): descrição #BEAD-ID` (max 72 chars)
- **success_criteria:** `git log --oneline -5` → padrão ok

### 3.4 — Sync com develop

- [ ] **what:** Rebase periódico (mínimo 1x por sessão)
- **spec:** `git fetch origin develop && git rebase origin/develop`
- **rollback:** `git rebase --abort`

### 3.5 — Atualizar Bead filho

- [ ] **what:** Marcar progresso no Bead
- **spec:** `bd update <BEAD-FILHO> --status in_progress` → `done`
- **integration:** Se sub-bead falhou → `bd update <ID> --status blocked`

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

## FASE 4 — PR + Review

### 4.1 — Push

- [ ] **what:** Enviar branch pro remote
- **success_criteria:** `git push -u origin <branch>` → success

### 4.2 — Criar PR

- [ ] **what:** Abrir PR pra develop
- **spec:** `gh pr create --base develop --title "tipo(escopo): desc" --body "Bead: SPALLA-XX\nClickUp: CU-xxx"`
- **constraints:** NUNCA PR pra main

### 4.3 — Esperar CI + CodeRabbit

- [ ] **what:** Aguardar pipeline automático
- **success_criteria:** CI verde + CodeRabbit comentou

### 4.4 — Auto-fix loop (max 5x)

- [ ] **what:** Ler feedback → corrigir → push → repetir
- **rollback:** 5 retries esgotados → `bd update <ID> --status blocked`

### 4.5 — Sync ClickUp

- [ ] **what:** Link do PR na task ClickUp
- **spec:** `POST /task/{id}/comment`

### 🔒 GATE: PR_APPROVED — CI verde + CodeRabbit limpo + PR pra develop + sem conflitos

---

## FASE 5 — Merge + Cleanup

### 5.1 — `gh pr merge --squash`
### 5.2 — `bd close <BEAD-PAI>`
### 5.3 — `git worktree remove` + `git worktree prune` + `git branch -d`
### 5.4 — `git checkout develop && git pull origin develop`
### 5.5 — ClickUp → status done

### 🔒 GATE: MERGE_COMPLETE — PR merged + Bead closed + worktree removido + develop atualizado

---

## FASE 6 — Release (gate humano)

### 6.1 — `gh pr create --base main --head develop --title "release: vX.Y.Z"`
### 6.2 — Aprovação HUMANA (Concierge NÃO mergeia sozinho)
### 6.3 — `gh pr merge --merge` (NÃO squash) + `git tag vX.Y.Z`

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

> Tudo caminha pro playbook. v2 transforma o output do Concierge Path em Auto Run Playbooks autônomos.

### Features v2

1. **Output = Maestro Auto Run Playbook**
   - Cada worktree gera uma pasta de playbook com N `.md` numerados
   - Usa o squad `autorun-playbook-creation` como fase final
   - Dev planeja de dia → playbooks geram → machine executa de madrugada

2. **Multi-Claude Account Randomization**
   - FASE 0 pede ao dev pra logar N contas Claude (via `CLAUDE_CONFIG_DIR`)
   - Setup: `claude login` → `cp -a ~/.claude ~/.claude-<conta>` → symlinks
   - Concierge distribui worktrees entre contas round-robin
   - Ex: 5 worktrees na conta A, 5 na conta B → zero rate limit

3. **Night Mode (Batch Execution)**
   - Após planejamento + spec + playbook gerado pra cada worktree
   - Comando único lança todos os Auto Runs em paralelo
   - Cada playbook roda isolado no seu worktree
   - Resultado de manhã: N PRs prontos pra review

4. **Account Setup no Container**
   - `entrypoint.sh` detecta todas as pastas `~/.claude-*`
   - Lista contas disponíveis ao Concierge na FASE 0
   - Concierge escolhe automaticamente qual conta usar por worktree

---

> **Concierge Path v1.0** — 16/Mar/2026 — Baseado em guia-operacional.md v2.2 + Task Atom + Beads gates
