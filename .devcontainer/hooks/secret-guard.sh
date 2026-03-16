#!/bin/bash
# secret-guard.sh — Bloqueia escrita de secrets em arquivos trackados
# Hook: PreToolUse (Write/Edit)
#
# Regra: NUNCA commitar secrets. Detecta patterns comuns.

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.file_path // .path // empty' 2>/dev/null)
CONTENT=$(echo "$INPUT" | jq -r '.content // .new_content // empty' 2>/dev/null)

# Se não tem conteúdo, deixa passar
[ -z "$CONTENT" ] && exit 0

# Permite edição de .env (é onde secrets DEVEM ficar)
[[ "$FILE" == *.env ]] && exit 0
[[ "$FILE" == *.env.* ]] && exit 0

# Patterns de secrets (case insensitive)
if echo "$CONTENT" | grep -qiE '(pk_[0-9]+_[A-Za-z0-9]+|ghp_[A-Za-z0-9]+|sk-[A-Za-z0-9]+|AKIA[A-Z0-9]+|-----BEGIN.*PRIVATE KEY)'; then
  echo "🚫 BLOQUEADO: Possível secret detectado em $FILE" >&2
  echo "   Secrets devem ficar em .env (gitignored)." >&2
  echo "   Padrão: /workspace/.devcontainer/.env" >&2
  exit 2
fi

exit 0
