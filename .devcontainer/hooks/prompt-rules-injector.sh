#!/bin/bash
# prompt-rules-injector.sh — Injeta rules anti-alucinação a cada mensagem do dev
# Hook: UserPromptSubmit
#
# Lê rules-injection.md e injeta como additionalContext.
# Isso garante que o Claude RELEMBRE as regras a cada prompt,
# independente de quanto contexto acumulou na conversa.

INPUT=$(cat)

# Paths possíveis pro rules (dentro do container)
RULES_FILE="/workspace/.claude/rules-injection.md"

# Se o arquivo de rules não existe, sai silenciosamente
if [ ! -f "$RULES_FILE" ]; then
  exit 0
fi

# Lê e escapa pra JSON
CONTENT=$(cat "$RULES_FILE" | jq -Rs .)

# Injeta como additionalContext no UserPromptSubmit
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": $CONTENT
  }
}
EOF

exit 0
