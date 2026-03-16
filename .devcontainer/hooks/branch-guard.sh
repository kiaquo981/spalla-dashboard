#!/bin/bash
# branch-guard.sh — Bloqueia push direto pra main ou develop
# Hook: PreToolUse (Bash)
#
# Regra: NUNCA push direto. SEMPRE via PR.

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.command // empty' 2>/dev/null)

# Só checa se é git push
if echo "$CMD" | grep -q "git push"; then
  # Bloqueia push pra main
  if echo "$CMD" | grep -qE "git push.*(origin|upstream)\s+main(\s|$)"; then
    echo "🚫 BLOQUEADO: Push direto pra main é proibido." >&2
    echo "   Use: gh pr create --base main --head develop" >&2
    exit 2
  fi

  # Bloqueia push pra develop (SÓ se não é a branch feature fazendo push)
  # Permite: git push origin feature/xyz (que depois vira PR pra develop)
  # Bloqueia: git push origin develop (push direto)
  if echo "$CMD" | grep -qE "git push.*(origin|upstream)\s+develop(\s|$)"; then
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
    if [ "$CURRENT_BRANCH" = "develop" ]; then
      echo "🚫 BLOQUEADO: Push direto pra develop é proibido." >&2
      echo "   Crie uma feature branch e faça PR." >&2
      exit 2
    fi
  fi
fi

exit 0
