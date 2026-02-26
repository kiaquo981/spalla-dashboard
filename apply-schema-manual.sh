#!/bin/bash
# Apply Supabase authentication schema
# Este script aplica o schema de autenticação na Supabase

echo "🔐 APLICAR SCHEMA DE AUTENTICAÇÃO NA SUPABASE"
echo "=============================================="
echo ""
echo "⚠️  Você precisa das credenciais da Supabase:"
echo "   1. Abra: https://app.supabase.com/projects/knusqfbvhsqworzyhvip"
echo "   2. Vá em: Settings → API"
echo "   3. Copie: Project URL e service_role secret (SERVICE_KEY)"
echo ""

read -p "Cole a PROJECT_URL (ex: https://knusqfbvhsqworzyhvip.supabase.co): " PROJECT_URL
read -sp "Cole a SERVICE_KEY (será escondida): " SERVICE_KEY
echo ""

if [ -z "$SERVICE_KEY" ] || [ -z "$PROJECT_URL" ]; then
    echo "❌ Credenciais incompletas!"
    exit 1
fi

echo "⏳ Aplicando schema..."

# Extract SQL from file
SQL_FILE="02-AUTH-SETUP.sql"

if [ ! -f "$SQL_FILE" ]; then
    echo "❌ Arquivo $SQL_FILE não encontrado!"
    exit 1
fi

# Create temporary SQL file without comments and empty lines
SQL_CLEAN=$(cat "$SQL_FILE" | grep -v '^--' | grep -v '^$')

# Execute via PostgreSQL endpoint
RESPONSE=$(curl -s -X POST \
    "$PROJECT_URL/rest/v1/rpc/exec_sql" \
    -H "Authorization: Bearer $SERVICE_KEY" \
    -H "apikey: $SERVICE_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"sql\": \"$(cat "$SQL_FILE" | sed 's/"/\\"/g' | tr '\n' ' ')\"}" \
    -w "\n%{http_code}")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    echo "✅ Schema aplicado com sucesso!"
    echo ""
    echo "📋 Próximos passos:"
    echo "   1. Abra: https://app.supabase.com/projects/knusqfbvhsqworzyhvip/auth/users"
    echo "   2. Clique em 'Invite' para cada usuário:"
    echo "      - kaique.azevedoo@outlook.com (depois marcar como admin)"
    echo "      - adm@allindigitalmarketing.com.br (depois marcar como admin)"
    echo "      - queilatrizotti@gmail.com"
    echo "      - hugo.nicchio@gmail.com"
    echo "      - mariza.rg22@gmail.com"
    echo "      - santoslarafreitas@gmail.com"
    echo "      - heitorms15@gmail.com"
    echo "   3. Para marcar como admin, execute: bash set-admin-roles.sh"
else
    echo "❌ Erro ao aplicar schema (HTTP $HTTP_CODE)"
    echo ""
    echo "Resposta:"
    echo "$BODY"
    echo ""
    echo "💡 ALTERNATIVA: Cole o SQL manualmente:"
    echo "   1. Abra: https://app.supabase.com/projects/knusqfbvhsqworzyhvip/sql/editor"
    echo "   2. Cole o conteúdo de $SQL_FILE"
    echo "   3. Execute"
    exit 1
fi
