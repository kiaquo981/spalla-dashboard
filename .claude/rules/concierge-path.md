# Concierge Path — Regras de Enforcement

> Carregado automaticamente em toda sessão Claude Code neste repo.
> NÃO MODIFICAR sem aprovação do squad lead.

---

## Regras Invioláveis

1. **NUNCA** pular um GATE. Cada fase tem um GATE bloqueante. Sem exceções.
2. **NUNCA** push direto pra main ou develop. SEMPRE via PR.
3. **NUNCA** criar container novo por feature. Usar worktree.
4. **NUNCA** commitar `.env`, `.key`, `.pem`, `*secret*`, `*credential*`.
5. **NUNCA** modificar arquivos fora do escopo definido no plano.
6. **SEMPRE** commit no formato convencional: `tipo(escopo): desc #BEAD-ID` (max 72 chars).
7. **SEMPRE** usar worktree isolado por frente de trabalho.
8. **SEMPRE** esperar CI + CodeRabbit antes de merge.
9. **SEMPRE** fechar Bead + remover worktree após merge.

## Tipos de Branch

| Stream | Prefixo | Quando |
|--------|---------|--------|
| CODE (feature) | `feature/` | Funcionalidade nova |
| CODE (bugfix) | `fix/` | Correção de bug |
| KNOWLEDGE | `content/` | Prompts, docs, pesquisa |
| Hotfix | `hotfix/` | Correção urgente em main |

## Tipos de Commit

Válidos: `feat`, `fix`, `docs`, `refactor`, `style`, `test`, `chore`, `perf`, `ci`, `security`

## Processo Obrigatório

Referência completa: `/workspace/.claude/concierge-path.md`

```
FASE 0 → 🔒 ENV_READY
FASE 1 → 🔒 SESSION_PLANNED
FASE 2 → 🔒 WORKTREES_READY
FASE 3 → 🔒 CODE_CLEAN
FASE 4 → 🔒 PR_APPROVED
FASE 5 → 🔒 MERGE_COMPLETE
FASE 6 → 🔒 DEPLOY_OK (gate humano)
```

## Checklist Antes de Cada Push

- [ ] `git status` limpo
- [ ] Commits seguem padrão convencional
- [ ] Zero `.env`/`.key` no stage
- [ ] Dentro do escopo planejado
- [ ] Bead atualizado (`bd update`)

## Checklist Antes de Cada PR

- [ ] Rebase com develop feito
- [ ] PR pra develop (NUNCA main)
- [ ] Body tem Bead ID e ClickUp link
- [ ] CI passou localmente (se aplicável)
