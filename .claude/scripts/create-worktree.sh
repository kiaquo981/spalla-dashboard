#!/bin/bash
# create-worktree.sh — Operação atômica: worktree + HANDOFF.md
#
# Uso:
#   bash /workspace/.claude/scripts/create-worktree.sh \
#     --name widget-zoom \
#     --branch feature/widget-zoom \
#     --type feature \
#     --clickup abc123def \
#     --scope "app/frontend/" \
#     --exclude "app/backend/"
#
# Ou sem ClickUp (freestyle já criou task antes):
#   bash /workspace/.claude/scripts/create-worktree.sh \
#     --name widget-zoom \
#     --branch feature/widget-zoom \
#     --type feature \
#     --description "Adicionar widget de zoom no dashboard" \
#     --scope "app/frontend/"
#
# REGRA: git worktree add DIRETO é bloqueado pelo hook.
#        Use SEMPRE este script.

set -euo pipefail

# ─── Parse args ───
NAME=""
BRANCH=""
TYPE="feature"
CLICKUP_ID=""
SCOPE=""
EXCLUDE=""
DESCRIPTION=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --name)      NAME="$2"; shift 2 ;;
    --branch)    BRANCH="$2"; shift 2 ;;
    --type)      TYPE="$2"; shift 2 ;;
    --clickup)   CLICKUP_ID="$2"; shift 2 ;;
    --scope)     SCOPE="$2"; shift 2 ;;
    --exclude)   EXCLUDE="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    *) echo "❌ Argumento desconhecido: $1"; exit 1 ;;
  esac
done

# ─── Validação ───
if [ -z "$NAME" ]; then
  echo "❌ --name é obrigatório"
  echo "Uso: bash create-worktree.sh --name <nome> --branch <branch> --type <feature|fix|content> [--clickup <task_id>] [--scope <dirs>] [--exclude <dirs>]"
  exit 1
fi

if [ -z "$BRANCH" ]; then
  # Auto-gera branch a partir do tipo + nome
  case "$TYPE" in
    feature)  BRANCH="feature/$NAME" ;;
    fix)      BRANCH="fix/$NAME" ;;
    refactor) BRANCH="refactor/$NAME" ;;
    content)  BRANCH="content/$NAME" ;;
    *)        BRANCH="feature/$NAME" ;;
  esac
fi

WORKTREE_PATH="/worktrees/$NAME"
DATE=$(date +%Y-%m-%d)
AUTH="Authorization: $CLICKUP_API_TOKEN"

# ─── Verifica se já existe ───
if [ -d "$WORKTREE_PATH" ]; then
  echo "⚠️  Worktree já existe em $WORKTREE_PATH"
  if [ -f "$WORKTREE_PATH/HANDOFF.md" ]; then
    echo "✅ HANDOFF.md presente. Tudo ok."
    exit 0
  else
    echo "🔧 Worktree existe mas sem HANDOFF.md. Criando..."
  fi
fi

# ─── Fetch ClickUp (se tem task_id) ───
CLICKUP_TITLE=""
CLICKUP_DESCRIPTION=""
CLICKUP_URL=""
TASK_LIST_ID=""

if [ -n "$CLICKUP_ID" ]; then
  echo "📋 Buscando task $CLICKUP_ID no ClickUp..."
  TASK_JSON=$(curl -s -H "$AUTH" "https://api.clickup.com/api/v2/task/$CLICKUP_ID" 2>/dev/null || echo "{}")

  CLICKUP_TITLE=$(echo "$TASK_JSON" | jq -r '.name // empty' 2>/dev/null)
  CLICKUP_DESCRIPTION=$(echo "$TASK_JSON" | jq -r '.description // empty' 2>/dev/null)
  CLICKUP_URL="https://app.clickup.com/t/$CLICKUP_ID"
  TASK_LIST_ID=$(echo "$TASK_JSON" | jq -r '.list.id // empty' 2>/dev/null)

  if [ -z "$CLICKUP_TITLE" ]; then
    echo "⚠️  Não consegui ler task $CLICKUP_ID. Continuando sem briefing do ClickUp."
  else
    echo "✅ Task encontrada: $CLICKUP_TITLE"
  fi
fi

# ─── Criar worktree ───
if [ ! -d "$WORKTREE_PATH" ]; then
  echo "🌳 Criando worktree em $WORKTREE_PATH (branch: $BRANCH)..."
  cd /workspace
  git worktree add -b "$BRANCH" "$WORKTREE_PATH" develop 2>/dev/null || \
  git worktree add "$WORKTREE_PATH" "$BRANCH" 2>/dev/null || {
    echo "❌ Falha ao criar worktree. Branch já existe?"
    echo "   Tentando: git worktree add $WORKTREE_PATH $BRANCH"
    git worktree add "$WORKTREE_PATH" "$BRANCH"
  }
  echo "✅ Worktree criado"
fi

# ─── Montar YAML do escopo ───
SCOPE_YAML=""
if [ -n "$SCOPE" ]; then
  IFS=',' read -ra DIRS <<< "$SCOPE"
  SCOPE_YAML="  directories:"
  for dir in "${DIRS[@]}"; do
    SCOPE_YAML="$SCOPE_YAML
    - $(echo $dir | xargs)"
  done
fi

EXCLUDE_YAML=""
if [ -n "$EXCLUDE" ]; then
  IFS=',' read -ra DIRS <<< "$EXCLUDE"
  EXCLUDE_YAML="  excluded:"
  for dir in "${DIRS[@]}"; do
    EXCLUDE_YAML="$EXCLUDE_YAML
    - $(echo $dir | xargs)"
  done
fi

# ─── Montar ClickUp YAML ───
CLICKUP_YAML=""
if [ -n "$CLICKUP_ID" ]; then
  CLICKUP_YAML="clickup:
  task_id: \"$CLICKUP_ID\"
  task_url: \"$CLICKUP_URL\"
  workspace_id: \"9011530618\"
  list_id: \"${TASK_LIST_ID:-unknown}\""
fi

# ─── Determinar briefing ───
BRIEFING=""
if [ -n "$CLICKUP_DESCRIPTION" ]; then
  BRIEFING="$CLICKUP_DESCRIPTION"
elif [ -n "$DESCRIPTION" ]; then
  BRIEFING="$DESCRIPTION"
else
  BRIEFING="(sem briefing — preencher manualmente)"
fi

TITLE="${CLICKUP_TITLE:-$NAME}"

# ─── Escrever HANDOFF.md ───
echo "📝 Escrevendo HANDOFF.md..."
cat > "$WORKTREE_PATH/HANDOFF.md" << HANDOFF_EOF
---
worktree: $NAME
branch: $BRANCH
type: $TYPE
created: $DATE
${CLICKUP_YAML}
scope:
${SCOPE_YAML}
${EXCLUDE_YAML}
status: pending
---

# Handoff — $TITLE

## Briefing

$BRIEFING

## Próximos passos

1. Criar \`spec.md\` — investigar código existente, entender dependências e impacto
2. Criar \`plan.md\` — decompor em steps atômicos (Task Atom: what, target, success_criteria, rollback)
3. Criar Beads a partir do plan (\`bd create\`)
4. Implementar seguindo o plan step by step
5. PR para develop
HANDOFF_EOF

echo "✅ HANDOFF.md escrito em $WORKTREE_PATH/HANDOFF.md"

# ─── Verificação final ───
echo ""
echo "════════════════════════════════════════"
echo "  ✅ WORKTREE PRONTO"
echo "════════════════════════════════════════"
echo "  Path:     $WORKTREE_PATH"
echo "  Branch:   $BRANCH"
echo "  Type:     $TYPE"
echo "  ClickUp:  ${CLICKUP_URL:-N/A}"
echo "  HANDOFF:  $WORKTREE_PATH/HANDOFF.md"
echo "════════════════════════════════════════"
echo ""
echo "Próximo passo: apontar agent pro $WORKTREE_PATH"
