#!/bin/bash

# Script to apply database migrations to Supabase
# Reads DATABASE_URL from .env and applies SQL migrations

set -e

echo "=== Spalla Dashboard Database Migration Tool ==="
echo ""

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
else
    echo "ERROR: .env file not found"
    exit 1
fi

# Extract Supabase connection details from SUPABASE_URL
SUPABASE_URL=${SUPABASE_URL:-https://knusqfbvhsqworzyhvip.supabase.co}
SUPABASE_SERVICE_KEY=${SUPABASE_SERVICE_KEY}

if [ -z "$SUPABASE_SERVICE_KEY" ]; then
    echo "ERROR: SUPABASE_SERVICE_KEY not found in .env"
    exit 1
fi

# Construct DATABASE_URL from Supabase credentials
# Format: postgresql://postgres:[password]@db.[project].supabase.co:5432/postgres
DATABASE_URL="postgresql://postgres:$(echo $SUPABASE_SERVICE_KEY | base64 -d 2>/dev/null || echo '')@knusqfbvhsqworzyhvip.supabase.co:5432/postgres"

echo "Supabase Project: $SUPABASE_URL"
echo "Database: postgres"
echo ""

# Find all migration files
MIGRATION_DIR="migrations"
if [ ! -d "$MIGRATION_DIR" ]; then
    echo "ERROR: $MIGRATION_DIR directory not found"
    exit 1
fi

# Get list of migration files
MIGRATIONS=$(ls -1 "$MIGRATION_DIR"/*.sql 2>/dev/null | sort)

if [ -z "$MIGRATIONS" ]; then
    echo "No migration files found in $MIGRATION_DIR"
    exit 0
fi

echo "Found $(echo "$MIGRATIONS" | wc -l) migration file(s) to apply"
echo ""

# Apply each migration
for migration_file in $MIGRATIONS; do
    migration_name=$(basename "$migration_file")
    echo "Applying: $migration_name"

    # Use psql with connection string
    # Note: This requires psql to be installed locally
    if command -v psql &> /dev/null; then
        psql "$DATABASE_URL" -f "$migration_file" 2>&1 | head -20
        echo "✓ $migration_name applied"
    else
        echo "WARNING: psql not found. Please install PostgreSQL client tools."
        echo "You can also apply this migration manually via Supabase SQL Editor:"
        echo "  1. Go to https://supabase.com/dashboard"
        echo "  2. Select your project"
        echo "  3. Go to SQL Editor"
        echo "  4. Copy the contents of $migration_file and run it"
        exit 1
    fi
    echo ""
done

echo "=== Migration Complete ==="
echo ""
echo "To verify indexes were created, run:"
echo "psql $DATABASE_URL -c \"SELECT indexname FROM pg_indexes WHERE schemaname='public' AND indexname LIKE 'idx_%';\""
