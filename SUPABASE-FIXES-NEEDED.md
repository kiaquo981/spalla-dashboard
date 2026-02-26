# Spalla Dashboard — Supabase Data Fixes Required

## Status of Bugs Fixed

### ✅ Bug 1: Double @ symbol (@@dra.yaragomes)
**Fixed:** Line 273 of `10-APP-index.html`
- Changed: `'@' + m.instagram`
- To: `'@' + m.instagram.replace('@', '')`
- Now properly removes duplicate @ from Instagram handles

### ✅ Bug 2: Instagram handles not displaying
**Fixed:** New function `_enrichMenteesWithSocialAndZoom()` in `11-APP-app.js`
- Queries `mentorados` table directly for `instagram` field
- Fetches for all mentees even if not in `vw_god_overview`
- Auto-enriches display with Instagram data from Supabase

### ✅ Bug 3: Zoom recording password not visible
**Fixed:** Updated HTML templates in `10-APP-index.html` (lines 478 & 636)
- Added `zoom_password` and `link_gravacao_senha` fields display
- Shows password badge next to recording link (blue badge)
- User can easily see password needed to access recording

---

## Remaining Issues (Data Corrections Needed in Supabase)

### ❌ Issue 1: Two "Daniela Morais" with confused photos

**Problem:**
- Card 1: Daniela Morais (ONBOARDING) — currently shows wrong photo (photo from Daniela #2)
- Card 2: Daniela Morais (ONBOARDING) — has photo but it's not displaying in Card 1

**Current System Logic:**
- When multiple people have same name, `igPhoto(handleOrName)` finds first match
- If Card 1 Daniela doesn't have Instagram handle, uses name to look up photo
- Finds first "Daniela Morais" entry in INSTAGRAM_PROFILES → gets wrong photo

**What User Reported:**
> "Tem duas daniela morais, é só a de cima que tem o @ do instagram, e a foto era pra ter a foto da debaixo na de cima"

Translation: "There are two Daniela Morais, only the top one has the Instagram @, and the photo should be from the bottom one in the top card"

**Solution Options:**

#### Option A: Add Instagram handles to both
- Top Daniela (ONBOARDING): Add her Instagram handle in `mentorados.instagram`
- This will make `igPhoto()` use exact handle match instead of name-based lookup
- Avoids ambiguity completely

#### Option B: Differentiate by cohort/status in photo lookup
- Would require code change to use cohort + name as lookup key
- More complex, not recommended

#### Option C: Update INSTAGRAM_PROFILES to have both entries separately
- Current: Only stores by handle as key
- Could add secondary mapping by handle + cohort
- More complex, not ideal

**Recommended:** **Option A** — Add Instagram handles for both Daniela Morais in Supabase `mentorados` table

---

## How to Run Code Changes

These changes are already deployed:

1. **Clear browser cache** (Ctrl+Shift+Delete or Cmd+Shift+Delete)
2. **Refresh site:** https://spalla-dashboard.vercel.app/
3. **Check for fixes:**
   - No more `@@` in Instagram handles
   - Instagram handles should display for all mentees (if in Supabase)
   - Zoom passwords now visible next to recordings

---

## Supabase Schema Verification

To fix the remaining issues, verify these columns exist in `mentorados` table:

```sql
-- Check if columns exist
SELECT column_name FROM information_schema.columns
WHERE table_name = 'mentorados'
AND column_name IN ('instagram', 'zoom_password', 'link_gravacao_senha');

-- Expected columns:
-- - instagram (text) — Instagram handle with or without @
-- - zoom_password (text) — Password for Zoom recordings
-- - link_gravacao_senha (text) — Alternative password field
```

If columns are missing, create them:
```sql
ALTER TABLE mentorados
  ADD COLUMN instagram TEXT,
  ADD COLUMN zoom_password TEXT,
  ADD COLUMN link_gravacao_senha TEXT;
```

---

## Debugging in Browser Console

To debug Instagram enrichment:

```javascript
// Open DevTools Console (F12)

// Check what was enriched
console.log('Mentees with Instagram:',
  spalla.$data.mentees
    .filter(m => m.instagram)
    .map(m => ({ nome: m.nome, instagram: m.instagram }))
);

// Check Daniela Morais entries
console.log('Daniela Morais entries:',
  spalla.$data.mentees
    .filter(m => m.nome?.includes('Daniela Morais'))
    .map(m => ({
      nome: m.nome,
      instagram: m.instagram,
      cohort: m.cohort,
      foto: spalla.igPhoto(m.instagram || m.nome)
    }))
);

// Check if Supabase has Instagram data
// (will be populated after _enrichMenteesWithSocialAndZoom() runs)
```

---

## Next Steps

1. ✅ **Deploy code fixes** — Already pushed to Vercel
2. ⏳ **Fix Supabase data:**
   - Add Instagram handles for Daniela Morais #2 (if missing)
   - Populate `zoom_password` column if not already done
3. ✅ **Test in browser:**
   - No `@@` symbols
   - All Instagram handles display
   - Zoom passwords visible next to recordings

---

## Files Changed

- `10-APP-index.html` — Fixed @ duplication, added password display
- `11-APP-app.js` — Added `_enrichMenteesWithSocialAndZoom()` function
- `SUPABASE-FIXES-NEEDED.md` — This file

---

**Status:** Code fixes deployed. Awaiting Supabase data corrections for full fix.
