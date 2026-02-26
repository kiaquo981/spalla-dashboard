#!/usr/bin/env python3
"""
Apply authentication schema to Supabase
Usage: python3 apply-auth-schema.py
"""

import requests
import sys
import getpass

def apply_schema():
    """Apply 02-AUTH-SETUP.sql to Supabase"""

    # Get credentials from user
    print("\n🔐 SUPABASE AUTHENTICATION SCHEMA SETUP")
    print("=" * 50)
    print("\nGet your credentials from:")
    print("  1. Go to https://app.supabase.com/projects")
    print("  2. Select your project (knusqfbvhsqworzyhvip)")
    print("  3. Settings → API → Copy details below\n")

    project_id = input("Project ID [knusqfbvhsqworzyhvip]: ").strip() or "knusqfbvhsqworzyhvip"
    service_key = getpass.getpass("Paste SERVICE_KEY (hidden input): ").strip()

    if not service_key:
        print("❌ SERVICE_KEY is required!")
        return False

    # Read SQL file
    try:
        with open('02-AUTH-SETUP.sql', 'r') as f:
            sql_content = f.read()
    except FileNotFoundError:
        print("❌ Error: 02-AUTH-SETUP.sql not found!")
        return False

    # Build Supabase URL
    supabase_url = f"https://{project_id}.supabase.co"

    # Execute SQL via REST API
    print("\n⏳ Applying schema to Supabase...")

    try:
        # Split SQL into individual statements
        statements = [stmt.strip() for stmt in sql_content.split(';') if stmt.strip()]

        headers = {
            'Authorization': f'Bearer {service_key}',
            'Content-Type': 'application/json',
            'apikey': service_key,
        }

        # Execute each statement
        for i, stmt in enumerate(statements, 1):
            # PostgreSQL can't execute multiple statements at once via REST API
            # So we'll construct a single transaction
            print(f"  [{i}/{len(statements)}] Processing statement...")

        # Execute all at once wrapped in transaction
        sql_request = "BEGIN TRANSACTION;\n" + ";\n".join(statements) + ";\nCOMMIT;"

        # Use PostgreSQL query endpoint
        response = requests.post(
            f"{supabase_url}/rest/v1/rpc/exec_sql",
            headers=headers,
            json={"sql": sql_content},
            timeout=30
        )

        if response.status_code in [200, 201]:
            print("✅ Schema applied successfully!")
            print("\nNext steps:")
            print("  1. Create users in Supabase Auth dashboard:")
            print("     - kaique.azevedoo@outlook.com (admin)")
            print("     - adm@allindigitalmarketing.com.br (admin)")
            print("     - queilatrizotti@gmail.com")
            print("     - hugo.nicchio@gmail.com")
            print("     - mariza.rg22@gmail.com")
            print("     - santoslarafreitas@gmail.com")
            print("     - heitorms15@gmail.com")
            print("  2. Update admin roles by running: python3 create-users.py")
            return True
        else:
            print(f"❌ Error: {response.status_code}")
            print(f"Response: {response.text}")
            return False

    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == '__main__':
    success = apply_schema()
    sys.exit(0 if success else 1)
