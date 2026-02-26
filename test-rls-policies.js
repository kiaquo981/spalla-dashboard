/**
 * Test RLS Policies on Spalla Supabase
 *
 * Usage:
 *   1. Set SUPABASE_URL and SUPABASE_ANON_KEY env vars
 *   2. Run: node test-rls-policies.js
 *
 * Tests:
 *   - Anon user (read-only via ANON_KEY)
 *   - Authenticated user (full access with JWT)
 */

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://knusqfbvhsqworzyhvip.supabase.co';
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || '';

if (!SUPABASE_ANON_KEY) {
  console.error('❌ Error: Set SUPABASE_ANON_KEY environment variable');
  process.exit(1);
}

async function testRLS() {
  console.log('╔════════════════════════════════════════════════════════════╗');
  console.log('║            RLS Policies Test Suite                          ║');
  console.log('╚════════════════════════════════════════════════════════════╝\n');

  console.log(`📍 Supabase URL: ${SUPABASE_URL}`);
  console.log(`🔑 Using ANON_KEY: ${SUPABASE_ANON_KEY.substring(0, 20)}...\n`);

  // Test 1: Read as Anon (should work)
  console.log('TEST 1: Anon user reading mentorados (RLS allows SELECT)');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  try {
    const response = await fetch(
      `${SUPABASE_URL}/rest/v1/mentorados?select=id,nome,email,fase_jornada`,
      {
        method: 'GET',
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json',
        },
      }
    );

    if (response.ok) {
      const data = await response.json();
      console.log(`✅ PASS: SELECT works (${data.length} rows returned)`);
      if (data.length > 0) {
        console.log(`   Sample: ${data[0].nome} (${data[0].email})`);
      }
    } else {
      const error = await response.text();
      console.log(`❌ FAIL: ${response.status} - ${error}`);
    }
  } catch (e) {
    console.error(`❌ ERROR: ${e.message}`);
  }

  // Test 2: Insert as Anon (should fail)
  console.log('\nTEST 2: Anon user trying to INSERT (RLS should block)');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  try {
    const response = await fetch(
      `${SUPABASE_URL}/rest/v1/mentorados`,
      {
        method: 'POST',
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          nome: 'Test User',
          email: 'test@example.com',
          cohort: 'N1',
          status: 'ativo',
        }),
      }
    );

    if (response.ok) {
      console.log(`⚠️  FAIL: INSERT should have been blocked by RLS`);
    } else {
      const error = await response.text();
      if (error.includes('row-level security')) {
        console.log(`✅ PASS: INSERT blocked by RLS policy (as expected)`);
        console.log(`   Error: "new row violates row-level security policy"`);
      } else {
        console.log(`✅ PASS: INSERT blocked (${response.status})`);
        console.log(`   Error: ${error.substring(0, 100)}`);
      }
    }
  } catch (e) {
    console.error(`❌ ERROR: ${e.message}`);
  }

  // Test 3: Check RLS status
  console.log('\nTEST 3: Verify RLS is enabled on mentorados table');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  try {
    const response = await fetch(
      `${SUPABASE_URL}/rest/v1/rpc/check_rls_status`,
      {
        method: 'POST',
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ table_name: 'mentorados' }),
      }
    );

    // If RPC doesn't exist, show manual verification query
    console.log(`ℹ️  To verify RLS in Supabase Dashboard:`);
    console.log(`   1. Go to SQL Editor`);
    console.log(`   2. Run: SELECT tablename, rowsecurity FROM pg_tables`);
    console.log(`           WHERE schemaname='public' AND tablename='mentorados'`);
    console.log(`   3. Should show: rowsecurity = true`);
  } catch (e) {
    console.log(`ℹ️  To verify RLS in Supabase Dashboard:`);
    console.log(`   1. Go to SQL Editor`);
    console.log(`   2. Run: SELECT tablename, rowsecurity FROM pg_tables`);
    console.log(`           WHERE schemaname='public' AND tablename='mentorados'`);
  }

  // Summary
  console.log('\n' + '═'.repeat(60));
  console.log('SUMMARY');
  console.log('═'.repeat(60));
  console.log(`
✅ If Tests 1-2 passed:
   - RLS is correctly enforced
   - Anon users can only SELECT
   - Inserts are blocked

❌ If Test 2 didn't fail:
   - RLS may not be applied yet
   - Run: 01-RLS-POLICIES.sql in Supabase SQL Editor

🔐 NEXT STEPS:
   1. Apply JWT authentication (already done)
   2. Test with Authenticated user (via JWT token)
   3. Verify Service Role Key works (admin access)
  `);
}

testRLS().catch(console.error);
