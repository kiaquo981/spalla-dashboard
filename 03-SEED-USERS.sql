
-- ===================================================================
-- SEED SPALLA USERS
-- Execute after applying 02-AUTH-SETUP.sql in Supabase
-- ===================================================================
--
-- Instructions:
-- 1. Go to Supabase dashboard
-- 2. Authentication → Users
-- 3. Create each user manually OR
-- 4. Use Supabase API to create users programmatically
--
-- For now, create manually with these credentials:
--


-- User: Kaique Azevedo
-- Email: kaique.azevedoo@outlook.com
-- Temporary Password: Generate a strong one (min 8 chars)
-- Role: admin
-- Instructions:
--   1. Go to Supabase Auth → Users → Add user
--   2. Email: kaique.azevedoo@outlook.com
--   3. Set strong password (will be hashed by Supabase)
--   4. Click "Create user"
--   5. Then manually update role:
--
--   UPDATE public.user_profiles
--   SET role = 'admin'
--   WHERE email = 'kaique.azevedoo@outlook.com';


-- User: ADM AllIn
-- Email: adm@allindigitalmarketing.com.br
-- Temporary Password: Generate a strong one (min 8 chars)
-- Role: admin
-- Instructions:
--   1. Go to Supabase Auth → Users → Add user
--   2. Email: adm@allindigitalmarketing.com.br
--   3. Set strong password (will be hashed by Supabase)
--   4. Click "Create user"
--   5. Then manually update role:
--
--   UPDATE public.user_profiles
--   SET role = 'admin'
--   WHERE email = 'adm@allindigitalmarketing.com.br';


-- User: Queila Trizotti
-- Email: queilatrizotti@gmail.com
-- Temporary Password: Generate a strong one (min 8 chars)
-- Role: user
-- Instructions:
--   1. Go to Supabase Auth → Users → Add user
--   2. Email: queilatrizotti@gmail.com
--   3. Set strong password (will be hashed by Supabase)
--   4. Click "Create user"
--   5. Then manually update role:
--
--   UPDATE public.user_profiles
--   SET role = 'user'
--   WHERE email = 'queilatrizotti@gmail.com';


-- User: Hugo Nicchio
-- Email: hugo.nicchio@gmail.com
-- Temporary Password: Generate a strong one (min 8 chars)
-- Role: user
-- Instructions:
--   1. Go to Supabase Auth → Users → Add user
--   2. Email: hugo.nicchio@gmail.com
--   3. Set strong password (will be hashed by Supabase)
--   4. Click "Create user"
--   5. Then manually update role:
--
--   UPDATE public.user_profiles
--   SET role = 'user'
--   WHERE email = 'hugo.nicchio@gmail.com';


-- User: Mariza
-- Email: mariza.rg22@gmail.com
-- Temporary Password: Generate a strong one (min 8 chars)
-- Role: user
-- Instructions:
--   1. Go to Supabase Auth → Users → Add user
--   2. Email: mariza.rg22@gmail.com
--   3. Set strong password (will be hashed by Supabase)
--   4. Click "Create user"
--   5. Then manually update role:
--
--   UPDATE public.user_profiles
--   SET role = 'user'
--   WHERE email = 'mariza.rg22@gmail.com';


-- User: Lara Freitas
-- Email: santoslarafreitas@gmail.com
-- Temporary Password: Generate a strong one (min 8 chars)
-- Role: user
-- Instructions:
--   1. Go to Supabase Auth → Users → Add user
--   2. Email: santoslarafreitas@gmail.com
--   3. Set strong password (will be hashed by Supabase)
--   4. Click "Create user"
--   5. Then manually update role:
--
--   UPDATE public.user_profiles
--   SET role = 'user'
--   WHERE email = 'santoslarafreitas@gmail.com';


-- User: Heitor
-- Email: heitorms15@gmail.com
-- Temporary Password: Generate a strong one (min 8 chars)
-- Role: user
-- Instructions:
--   1. Go to Supabase Auth → Users → Add user
--   2. Email: heitorms15@gmail.com
--   3. Set strong password (will be hashed by Supabase)
--   4. Click "Create user"
--   5. Then manually update role:
--
--   UPDATE public.user_profiles
--   SET role = 'user'
--   WHERE email = 'heitorms15@gmail.com';



-- ===================================================================
-- VERIFICATION QUERY
-- After creating all users, verify:
-- ===================================================================

SELECT id, email, full_name, role, created_at
FROM public.user_profiles
ORDER BY created_at;

-- Expected: 7 users (2 admins + 5 regular users)
