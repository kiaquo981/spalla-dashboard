-- =============================================================================
-- SPALLA — Add email field to mentorados table
-- Run this if email column doesn't exist
-- =============================================================================

-- Check if email column exists, if not add it
ALTER TABLE public.mentorados
ADD COLUMN IF NOT EXISTS email text;

-- Add index for email lookups
CREATE INDEX IF NOT EXISTS idx_mentorados_email ON public.mentorados(email);

-- Verify email column exists
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'mentorados' AND column_name = 'email';

-- Show sample data
SELECT id, nome, email FROM mentorados LIMIT 5;
