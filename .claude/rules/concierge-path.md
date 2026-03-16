# Concierge Path — Regras de Enforcement

> Carregado automaticamente em toda sessão Claude Code neste repo.
> NÃO MODIFICAR sem aprovação do squad lead.

---

## 🚨 BLOQUEIOS ABSOLUTOS (HARD STOPS)

### WORKTREE: CAMINHO OBRIGATÓRIO

```
✅ CORRETO:  git worktree add -b <branch> /workspace/../spalla-dashboard-worktrees/<nome> develop
❌ ERRADO:   git worktree add -b <branch> /workspace/<nome> develop
❌ ERRADO:   git worktree add -b <branch> ./<nome> develop
❌ ERRADO:   qualquer path DENTRO de /workspace/
```

**REGRA:** Worktrees SEMPRE em `/workspace/../spalla-dashboard-worktrees/`. NUNCA dentro do repo. Se o path do worktree começa com `/workspace/` e NÃO tem `../`, está ERRADO. PARE IMEDIATAMENTE.

### FASE OBRIGATÓRIA: SPEC ANTES DE CÓDIGO

```
❌ PROIBIDO: Receber task → criar worktree → COMEÇAR A CODAR
✅ CORRETO:  Receber task → criar worktree → SPEC → PLAN → BEADS → CODAR
```

**REGRA:** Você NÃO PODE escrever código de implementação sem antes ter criado `spec.md` e `plan.md` dentro do worktree. ZERO exceções. Nem se o dev pedir. Responda: "Preciso fazer a spec primeiro. É regra do Concierge Path."

### SEQUÊNCIA DE FASES (INVIOLÁVEL)

```
FASE 0 → 🔒 ENV_READY
FASE 1 → 🔒 SESSION_PLANNED       ← ClickUp + classificação + aprovação do dev
FASE 2 → 🔒 WORKTREES_READY       ← Worktrees criados (SEM beads, SEM código)
FASE 3 → 🔒 SPEC_APPROVED         ← spec.md + plan.md + ENTÃO beads
FASE 4 → 🔒 CODE_CLEAN            ← SÓ AGORA escreve código
FASE 5 → 🔒 PR_APPROVED
FASE 6 → 🔒 MERGE_COMPLETE
FASE 7 → 🔒 DEPLOY_OK
```

**REGRA:** Cada GATE é bloqueante. Não pode pular fase. Se está na FASE 2, NÃO escreve código. Se está na FASE 3, NÃO faz push. Sem exceções.

---

## Regras Invioláveis (todas)

1. **NUNCA** criar worktree DENTRO de `/workspace/`. Sempre em `../spalla-dashboard-worktrees/`.
2. **NUNCA** escrever código sem ter `spec.md` e `plan.md` prontos.
3. **NUNCA** criar Beads antes da spec. A spec revela a complexidade real.
4. **NUNCA** pular um GATE.
5. **NUNCA** push direto pra main ou develop. SEMPRE via PR.
6. **NUNCA** commitar `.env`, `.key`, `.pem`, `*secret*`, `*credential*`.
7. **NUNCA** modificar arquivos fora do escopo definido no plano.
8. **SEMPRE** commit no formato convencional: `tipo(escopo): desc #BEAD-ID` (max 72 chars).
9. **SEMPRE** usar worktree isolado por frente de trabalho.
10. **SEMPRE** esperar CI + CodeRabbit antes de merge.

## Auto-verificação (rodar mentalmente ANTES de cada ação)

Antes de criar worktree:
- [ ] O path começa com `../` ou é absoluto FORA de /workspace? Se não → PARE.

Antes de escrever código:
- [ ] Existe `spec.md` no worktree? Se não → PARE. Faça a spec primeiro.
- [ ] Existe `plan.md` no worktree? Se não → PARE. Faça o plan primeiro.
- [ ] Beads foram criados a partir do plan? Se não → PARE. Crie beads primeiro.

Antes de push:
- [ ] `git status` limpo?
- [ ] Commits seguem `tipo(escopo): desc #BEAD-ID`?
- [ ] Zero secrets no stage?

Antes de PR:
- [ ] Base branch = develop (NUNCA main)?
- [ ] Rebase com develop feito?

## Tipos de Branch

| Stream | Prefixo |
|--------|---------|
| CODE (feature) | `feature/` |
| CODE (bugfix) | `fix/` |
| KNOWLEDGE | `content/` |
| Hotfix | `hotfix/` |

## Tipos de Commit

Válidos: `feat`, `fix`, `docs`, `refactor`, `style`, `test`, `chore`, `perf`, `ci`, `security`

## Referência

Metodologia completa: `/workspace/.claude/concierge-path.md`
