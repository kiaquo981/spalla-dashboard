#!/bin/bash
# handoff-injector.sh — Injeta HANDOFF.md no contexto do agent ao iniciar sessão
# Hook: SessionStart
#
# Se o cwd contém HANDOFF.md, injeta o conteúdo como additionalContext.
# Isso faz o agent já saber o que precisa fazer SEM precisar ler nada.

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)

# Fallback pro pwd se cwd não veio no input
[ -z "$CWD" ] && CWD="$(pwd)"

HANDOFF="$CWD/HANDOFF.md"

# Se não tem HANDOFF.md, sai silenciosamente
if [ ! -f "$HANDOFF" ]; then
  exit 0
fi

# Lê o conteúdo e escapa pra JSON
CONTENT=$(cat "$HANDOFF" | jq -Rs .)

# Injeta como additionalContext (aparece como contexto do sistema)
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $CONTENT
  }
}
EOF

exit 0
