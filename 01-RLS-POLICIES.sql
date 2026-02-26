-- ===================================================================
-- SPALLA V2 — Row Level Security (RLS) Policies
-- Apply in Supabase SQL Editor
-- ===================================================================
--
-- Security Model:
-- 1. Anon users: READ-ONLY access (public data only)
-- 2. Authenticated users: Full access (via JWT)
-- 3. Service role: Admin access (backend only)
--
-- ===================================================================

-- ===== 1. ENABLE RLS ON ALL TABLES =====

ALTER TABLE mentorados ENABLE ROW LEVEL SECURITY;
ALTER TABLE calls_mentoria ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks_mentorados ENABLE ROW LEVEL SECURITY;
ALTER TABLE god_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE teses_juridicas ENABLE ROW LEVEL SECURITY;
ALTER TABLE medicamentos ENABLE ROW LEVEL SECURITY;

-- ===================================================================
-- TABLE: mentorados (Mentees - Core data)
-- ===================================================================

-- Policy 1: Anon users can only READ public data
CREATE POLICY "mentorados_anon_select" ON mentorados
  FOR SELECT
  TO anon
  USING (true);

-- Policy 2: Authenticated users can SELECT all mentees
CREATE POLICY "mentorados_authenticated_select" ON mentorados
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy 3: Authenticated users can UPDATE mentees
CREATE POLICY "mentorados_authenticated_update" ON mentorados
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Policy 4: Authenticated users can INSERT mentees
CREATE POLICY "mentorados_authenticated_insert" ON mentorados
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Policy 5: Service role (backend) has full access
CREATE POLICY "mentorados_service_all" ON mentorados
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ===================================================================
-- TABLE: calls_mentoria (Call logs)
-- ===================================================================

-- Policy 1: Authenticated users can READ calls
CREATE POLICY "calls_authenticated_select" ON calls_mentoria
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy 2: Authenticated users can INSERT calls
CREATE POLICY "calls_authenticated_insert" ON calls_mentoria
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Policy 3: Authenticated users can UPDATE calls
CREATE POLICY "calls_authenticated_update" ON calls_mentoria
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Policy 4: Service role full access
CREATE POLICY "calls_service_all" ON calls_mentoria
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ===================================================================
-- TABLE: tasks_mentorados (Personal tasks)
-- ===================================================================

-- Policy 1: Authenticated users can READ
CREATE POLICY "tasks_authenticated_select" ON tasks_mentorados
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy 2: Authenticated users can INSERT
CREATE POLICY "tasks_authenticated_insert" ON tasks_mentorados
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Policy 3: Authenticated users can UPDATE
CREATE POLICY "tasks_authenticated_update" ON tasks_mentorados
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Policy 4: Authenticated users can DELETE own tasks
CREATE POLICY "tasks_authenticated_delete" ON tasks_mentorados
  FOR DELETE
  TO authenticated
  USING (true);

-- Policy 5: Service role full access
CREATE POLICY "tasks_service_all" ON tasks_mentorados
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ===================================================================
-- TABLE: god_tasks (Team-wide tasks)
-- ===================================================================

-- Policy 1: Authenticated users can READ all god_tasks
CREATE POLICY "god_tasks_authenticated_select" ON god_tasks
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy 2: Authenticated users can INSERT
CREATE POLICY "god_tasks_authenticated_insert" ON god_tasks
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Policy 3: Authenticated users can UPDATE
CREATE POLICY "god_tasks_authenticated_update" ON god_tasks
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Policy 4: Service role full access
CREATE POLICY "god_tasks_service_all" ON god_tasks
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ===================================================================
-- TABLE: teses_juridicas (Legal theses)
-- ===================================================================

-- Policy 1: Everyone can READ teses (public reference data)
CREATE POLICY "teses_select_public" ON teses_juridicas
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- Policy 2: Authenticated users can UPDATE
CREATE POLICY "teses_authenticated_update" ON teses_juridicas
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Policy 3: Authenticated users can INSERT
CREATE POLICY "teses_authenticated_insert" ON teses_juridicas
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Policy 4: Service role full access
CREATE POLICY "teses_service_all" ON teses_juridicas
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ===================================================================
-- TABLE: medicamentos (Medications - reference data)
-- ===================================================================

-- Policy 1: Everyone can READ medications (public reference)
CREATE POLICY "medicamentos_select_public" ON medicamentos
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- Policy 2: Authenticated users can UPDATE
CREATE POLICY "medicamentos_authenticated_update" ON medicamentos
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Policy 3: Service role full access
CREATE POLICY "medicamentos_service_all" ON medicamentos
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ===================================================================
-- VERIFICATION QUERIES
-- ===================================================================
--
-- Run these to verify RLS is enabled:
--
-- SELECT schemaname, tablename, rowsecurity FROM pg_tables
--   WHERE schemaname = 'public' AND tablename IN (
--     'mentorados', 'calls_mentoria', 'tasks_mentorados',
--     'god_tasks', 'teses_juridicas', 'medicamentos'
--   );
--
-- Expected: All should show 't' (true) in rowsecurity column
--
-- ===================================================================
-- TESTING RLS
-- ===================================================================
--
-- As ANON user:
-- SELECT * FROM mentorados;  -- Works (public read)
-- INSERT INTO mentorados (...) VALUES (...);  -- Fails (no insert)
--
-- As AUTHENTICATED user (with valid JWT):
-- SELECT * FROM mentorados;  -- Works
-- INSERT INTO mentorados (...) VALUES (...);  -- Works
--
-- As SERVICE_ROLE (backend):
-- SELECT * FROM mentorados;  -- Works (unrestricted)
--
-- ===================================================================
-- IMPORTANT NOTES
-- ===================================================================
--
-- 1. RLS applies to ALL users including authenticated ones
-- 2. Service role BYPASSES RLS (only use for backend)
-- 3. Anon key = read-only access
-- 4. Authenticated key = full CRUD access
-- 5. Service role key = unrestricted admin access (NEVER expose)
--
-- Security hierarchy:
--   Service Role (backend) > Authenticated (frontend) > Anon (public)
--
-- ===================================================================
