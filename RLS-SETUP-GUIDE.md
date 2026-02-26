# RLS Policies Setup Guide

## Overview

Row Level Security (RLS) restricts database access based on user roles:

| Role | Access Level | Use Case |
|------|--------------|----------|
| **Anon** | Read-only public data | Public API (future) |
| **Authenticated** | Full CRUD via JWT | Frontend app |
| **Service Role** | Unrestricted (admin) | Backend server only |

---

## Step 1: Apply RLS Policies

### Via Supabase Dashboard

1. Go to: **SQL Editor** → **New Query**
2. Copy entire content of `01-RLS-POLICIES.sql`
3. Paste and click **Run**
4. Wait for completion (5-10 seconds)

### Via CLI

```bash
# Install Supabase CLI (if not already installed)
npm install -g supabase

# Login
supabase login

# Apply SQL file to your project
supabase db push --file 01-RLS-POLICIES.sql
```

---

## Step 2: Verify RLS is Enabled

Run this query in Supabase SQL Editor:

```sql
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'mentorados', 'calls_mentoria', 'tasks_mentorados',
    'god_tasks', 'teses_juridicas', 'medicamentos'
  )
ORDER BY tablename;
```

**Expected output:** All tables should show `rowsecurity = true`

---

## Step 3: Test RLS Enforcement

### Test as Anon User (Frontend - Supabase Anon Key)

```javascript
const { data, error } = await supabase
  .from('mentorados')
  .select('*');
// ✅ Works: Read-only access

const { error } = await supabase
  .from('mentorados')
  .insert([{ nome: 'New Mentee' }]);
// ❌ Fails: "new row violates row-level security policy"
```

### Test as Authenticated User (Frontend - JWT)

```javascript
// After login (JWT token in localStorage)
const { data, error } = await supabase
  .from('mentorados')
  .select('*');
// ✅ Works: Full access

const { data } = await supabase
  .from('mentorados')
  .insert([{ nome: 'New Mentee' }]);
// ✅ Works: Insert allowed
```

### Test as Service Role (Backend - Service Key)

```python
# Backend Python
import os
from supabase import create_client

supabase = create_client(
  SUPABASE_URL,
  os.environ['SUPABASE_SERVICE_KEY']  # Service role key
)

# This bypasses RLS completely
result = supabase.table('mentorados').select('*').execute()
# ✅ Works: Unrestricted access
```

---

## Step 4: Update Frontend Code

Your frontend is already configured! The `getAuthHeaders()` function includes JWT in all requests.

**Verify in 11-APP-app.js:**

```javascript
async login() {
  const response = await fetch(`${CONFIG.API_BASE_URL}/api/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password })
  });

  const data = await response.json();
  // Token stored in localStorage
  this.auth.token = data.token;
}

getAuthHeaders() {
  const token = this.getAuthToken();
  const headers = { 'Content-Type': 'application/json' };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  return headers;
}
```

✅ Already done!

---

## Step 5: Update Backend Code

Backend needs to use **Service Role Key** for unrestricted Supabase access:

### Current Implementation (14-APP-server.py)

```python
# ❌ Uses SUPABASE_ANON_KEY (restricted by RLS)
sb = supabase.create_client(
  SUPABASE_URL,
  SUPABASE_ANON_KEY  # Limited access
)

# ✅ Should use SUPABASE_SERVICE_KEY (bypasses RLS)
sb = supabase.create_client(
  SUPABASE_URL,
  SUPABASE_SERVICE_KEY  # Full access
)
```

**Update needed:** Change backend to use service key for server-to-server operations.

---

## Security Matrix

| Operation | Anon | Authenticated | Service Role |
|-----------|------|---------------|--------------|
| SELECT mentorados | ✅ | ✅ | ✅ |
| INSERT mentorados | ❌ | ✅ | ✅ |
| UPDATE mentorados | ❌ | ✅ | ✅ |
| DELETE mentorados | ❌ | ✅ | ✅ |
| Bypass RLS | ❌ | ❌ | ✅ |

---

## Troubleshooting

### "new row violates row-level security policy"

**Cause:** Trying to INSERT/UPDATE/DELETE as Anon user

**Fix:** Use Authenticated user (with JWT token) or Service Role

### "Permission denied" error

**Cause:** RLS policy not allowing operation

**Solution:** Check JWT token is valid and included in request

```javascript
// ✅ Correct: Includes JWT
fetch('/api/data', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
})

// ❌ Wrong: Missing JWT
fetch('/api/data', {
  headers: {} // No Authorization header
})
```

### RLS not taking effect

**Cause:** Policy syntax error or table not enabled

**Fix:** Run verification query and check for errors

```sql
-- Check if RLS enabled
SELECT tablename, rowsecurity FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'mentorados';

-- Check existing policies
SELECT * FROM pg_policies WHERE tablename = 'mentorados';
```

---

## Rollback (if needed)

```sql
-- Disable RLS on a table
ALTER TABLE mentorados DISABLE ROW LEVEL SECURITY;

-- Drop a specific policy
DROP POLICY "mentorados_authenticated_select" ON mentorados;

-- Drop all policies for a table
DROP POLICY * ON mentorados;
```

---

## Production Checklist

- [ ] All 6 tables have RLS enabled
- [ ] JWT authentication working (test /api/auth/login)
- [ ] CORS whitelist configured
- [ ] Service key stored in Railway env vars
- [ ] Anon key stored in Vercel env vars
- [ ] Backend uses SERVICE_KEY for server operations
- [ ] Frontend uses JWT token in requests
- [ ] Test with anon + authenticated users
- [ ] Monitor Supabase audit logs for RLS violations

---

## References

- [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL RLS](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [Spalla JWT Auth](./jwt-auth.md)

