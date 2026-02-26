#!/usr/bin/env python3
"""
Apply RLS Policies to Spalla Supabase Project
Usage: python3 apply-rls-policies.py [--project-url] [--service-key]
"""

import os
import sys
import json
from pathlib import Path

def read_sql_file():
    """Read RLS policies from SQL file"""
    sql_file = Path(__file__).parent / '01-RLS-POLICIES.sql'
    if not sql_file.exists():
        print(f"❌ Error: {sql_file} not found")
        sys.exit(1)

    with open(sql_file, 'r') as f:
        content = f.read()

    # Extract only SQL commands (skip comments and documentation)
    lines = []
    for line in content.split('\n'):
        if not line.strip().startswith('--') and line.strip():
            lines.append(line)

    return '\n'.join(lines)

def apply_policies_via_api(project_url, service_key):
    """
    Apply RLS policies using Supabase REST API

    Note: This uses the SQL query endpoint which may require additional setup
    """
    import urllib.request
    import json

    print(f"🔐 Applying RLS policies to: {project_url}")

    sql_content = read_sql_file()

    # The SQL API endpoint requires special setup; recommend using dashboard instead
    print("⚠️  NOTE: Use Supabase Dashboard SQL Editor for direct application:")
    print(f"   1. Go to: {project_url}/projects/_/editor")
    print("   2. Create new query")
    print("   3. Paste content of 01-RLS-POLICIES.sql")
    print("   4. Run query")
    print("\n✅ Or use Supabase CLI:")
    print("   supabase db execute < 01-RLS-POLICIES.sql")

def verify_policies(project_url, service_key):
    """
    Verify that RLS policies are enabled on all tables
    """
    print("✅ Verification queries to run in Supabase:")
    print("""
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'mentorados', 'calls_mentoria', 'tasks_mentorados',
    'god_tasks', 'teses_juridicas', 'medicamentos'
  )
ORDER BY tablename;

-- Check existing policies
SELECT tablename, policyname, permissive, roles
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
    """)

def main():
    """Main entry point"""
    print("╔════════════════════════════════════════════════════════════╗")
    print("║        Spalla RLS Policies Application Tool                 ║")
    print("╚════════════════════════════════════════════════════════════╝\n")

    # Get credentials from environment
    project_url = os.environ.get('SUPABASE_URL')
    service_key = os.environ.get('SUPABASE_SERVICE_KEY')

    if not project_url or not service_key:
        print("❌ Error: Missing environment variables:")
        print("   - SUPABASE_URL")
        print("   - SUPABASE_SERVICE_KEY")
        print("\nSet them with:")
        print("   export SUPABASE_URL='https://xxxxx.supabase.co'")
        print("   export SUPABASE_SERVICE_KEY='xxxxx'")
        sys.exit(1)

    print(f"✅ Project URL: {project_url}")
    print(f"✅ Service Key: {service_key[:20]}...\n")

    # Show instructions
    apply_policies_via_api(project_url, service_key)

    print("\n" + "="*60)
    print("📋 VERIFICATION STEPS:")
    print("="*60)
    verify_policies(project_url, service_key)

    print("\n" + "="*60)
    print("📚 DOCUMENTATION:")
    print("="*60)
    print("See RLS-SETUP-GUIDE.md for complete instructions")

if __name__ == '__main__':
    main()
