#!/bin/bash
# worktree-guard.sh — Bloqueia criação de worktrees dentro de /workspace/
# Hook: PreToolUse (Bash)
#
# Regra: Worktrees SEMPRE em /worktrees/. NUNCA dentro de /workspace/.

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.command // empty' 2>/dev/null)

# Só checa se é git worktree add
if echo "$CMD" | grep -q "git worktree add"; then
  # Extrai o path do worktree (argumento após git worktree add)
  WT_PATH=$(echo "$CMD" | grep -oP 'git worktree add\s+(-b\s+\S+\s+)?(\S+)' | awk '{print $NF}')

  # Se o path é relativo (não começa com /), resolve
  if [[ "$WT_PATH" != /* ]]; then
    WT_PATH="$(pwd)/$WT_PATH"
  fi

  # Resolve .. no path
  WT_PATH=$(realpath -m "$WT_PATH" 2>/dev/null || echo "$WT_PATH")

  # BLOQUEIA se dentro de /workspace/
  if [[ "$WT_PATH" == /workspace/* ]]; then
    echo "🚫 BLOQUEADO: Worktree não pode ser criado dentro de /workspace/." >&2
    echo "   Path detectado: $WT_PATH" >&2
    echo "   Use: git worktree add -b <branch> /worktrees/<nome> develop" >&2
    exit 2
  fi

  # BLOQUEIA se NÃO está em /worktrees/
  if [[ "$WT_PATH" != /worktrees/* ]]; then
    echo "🚫 BLOQUEADO: Worktrees devem ficar em /worktrees/." >&2
    echo "   Path detectado: $WT_PATH" >&2
    echo "   Use: git worktree add -b <branch> /worktrees/<nome> develop" >&2
    exit 2
  fi
fi

exit 0
