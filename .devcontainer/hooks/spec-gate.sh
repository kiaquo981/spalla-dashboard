#!/bin/bash
# spec-gate.sh — Bloqueia escrita de código sem spec.md
# Hook: PreToolUse (Write/Edit)
#
# Regra: NÃO pode escrever código de implementação sem spec.md no worktree.

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.file_path // .path // empty' 2>/dev/null)

# Se não tem file_path, deixa passar
[ -z "$FILE" ] && exit 0

# Só aplica para arquivos dentro de /worktrees/
[[ "$FILE" != /worktrees/* ]] && exit 0

# Só aplica para arquivos de código (não config, não docs)
if [[ "$FILE" =~ \.(py|js|ts|tsx|jsx|vue|svelte|go|rs|rb|java|c|cpp|h|cs)$ ]]; then
  # Extrai o diretório do worktree (ex: /worktrees/widget-zoom)
  WORKTREE_DIR=$(echo "$FILE" | sed 's|^\(/worktrees/[^/]*\).*|\1|')

  # Verifica se spec.md existe
  if [ ! -f "$WORKTREE_DIR/spec.md" ]; then
    echo "🚫 BLOQUEADO: spec.md não encontrado em $WORKTREE_DIR/" >&2
    echo "   Você precisa criar spec.md ANTES de escrever código." >&2
    echo "   Concierge Path: Spec → Plan → Tasks → Beads → Code" >&2
    exit 2
  fi

  # Verifica se plan.md existe
  if [ ! -f "$WORKTREE_DIR/plan.md" ]; then
    echo "🚫 BLOQUEADO: plan.md não encontrado em $WORKTREE_DIR/" >&2
    echo "   Você precisa criar plan.md ANTES de escrever código." >&2
    echo "   Concierge Path: Spec → Plan → Tasks → Beads → Code" >&2
    exit 2
  fi
fi

exit 0
