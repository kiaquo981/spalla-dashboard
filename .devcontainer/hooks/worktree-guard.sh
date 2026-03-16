#!/bin/bash
# worktree-guard.sh — Bloqueia git worktree add direto. Força uso do script.
# Hook: PreToolUse (Bash)
#
# REGRA: NUNCA usar git worktree add diretamente.
# SEMPRE usar: bash /workspace/.claude/scripts/create-worktree.sh

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.command // empty' 2>/dev/null)

# Só checa se é git worktree add
if echo "$CMD" | grep -q "git worktree add"; then
  # Permite se veio de dentro do script create-worktree.sh
  # (detecta pelo process tree ou env var)
  if [ "$WORKTREE_SCRIPT_RUNNING" = "1" ]; then
    exit 0
  fi

  echo "🚫 BLOQUEADO: git worktree add direto é proibido." >&2
  echo "" >&2
  echo "   Use o script atômico:" >&2
  echo "   bash /workspace/.claude/scripts/create-worktree.sh \\" >&2
  echo "     --name <nome> \\" >&2
  echo "     --branch <branch> \\" >&2
  echo "     --type <feature|fix|content> \\" >&2
  echo "     --clickup <task_id> \\" >&2
  echo "     --scope <dirs>" >&2
  echo "" >&2
  echo "   O script cria worktree + HANDOFF.md atomicamente." >&2
  echo "   Sem HANDOFF.md = sem contexto pro agent." >&2
  exit 2
fi

exit 0
