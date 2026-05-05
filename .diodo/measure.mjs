#!/usr/bin/env node
/**
 * Diodo — script de medição de métricas pro Spalla Dashboard.
 *
 * Stack: Python 3.9 + HTML/Alpine.js vanilla (sem build step, sem package.json).
 * Métricas convergem em 5 categorias: tamanho, secrets, refs quebrados,
 * test surface, drift de cache buster.
 *
 * Uso:
 *   node .diodo/measure.mjs                    # imprime JSON em stdout
 *   node .diodo/measure.mjs --baseline         # escreve .diodo/baseline.json
 *   node .diodo/measure.mjs --gate             # compara contra baseline, exit 1 se regrediu
 */

import { readFileSync, readdirSync, writeFileSync, existsSync, statSync } from 'node:fs';
import { join, dirname, relative } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execSync } from 'node:child_process';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');
const BASELINE_PATH = join(__dirname, 'baseline.json');

// ---------- helpers ----------
function walk(dir, exts, skip = []) {
  const out = [];
  const items = readdirSync(dir, { withFileTypes: true });
  for (const item of items) {
    const full = join(dir, item.name);
    if (item.isDirectory()) {
      if (skip.some(s => full.includes(s))) continue;
      out.push(...walk(full, exts, skip));
    } else if (item.isFile()) {
      if (!exts || exts.some(e => item.name.endsWith(e))) out.push(full);
    }
  }
  return out;
}

function countLines(file) {
  try { return readFileSync(file, 'utf8').split('\n').length; } catch { return 0; }
}

function grepCount(file, regex) {
  try {
    const content = readFileSync(file, 'utf8');
    const matches = content.match(regex);
    return matches ? matches.length : 0;
  } catch { return 0; }
}

// ---------- métricas ----------
function measure() {
  const skipDirs = ['node_modules', '.git', '.venv', '__pycache__', '.diodo'];

  // 1. Tamanho dos arquivos
  const jsFiles = walk(join(ROOT, 'app/frontend'), ['.js'], skipDirs);
  const cssFiles = walk(join(ROOT, 'app/frontend'), ['.css'], skipDirs);
  const htmlFiles = walk(join(ROOT, 'app/frontend'), ['.html'], skipDirs);
  const pyFiles = walk(join(ROOT, 'app/backend'), ['.py'], skipDirs);

  const sizes = {};
  for (const f of [...jsFiles, ...cssFiles, ...htmlFiles, ...pyFiles]) {
    sizes[relative(ROOT, f)] = countLines(f);
  }

  const allLines = Object.values(sizes);
  const largest_file_lines = Math.max(...allLines);
  const files_over_2k_lines = allLines.filter(n => n > 2000).length;
  const files_over_5k_lines = allLines.filter(n => n > 5000).length;
  const total_loc_frontend_js = jsFiles.reduce((s, f) => s + countLines(f), 0);
  const total_loc_frontend_css = cssFiles.reduce((s, f) => s + countLines(f), 0);
  const total_loc_frontend_html = htmlFiles.reduce((s, f) => s + countLines(f), 0);
  const total_loc_backend_py = pyFiles.reduce((s, f) => s + countLines(f), 0);

  // 2. Secrets / hardcoded keys (anti-pattern grep curado, CI-aligned)
  let hardcoded_secrets_count = 0;
  const secretPatterns = [
    /sk_spalla_[a-f0-9]+/g,
    /SUPABASE_SERVICE_KEY\s*=\s*['"]?ey/g,
    /sk-[a-zA-Z0-9]{40,}/g,
    /sk-proj-[a-zA-Z0-9]{20,}/g,
  ];
  for (const f of [...jsFiles, ...pyFiles, ...htmlFiles]) {
    for (const pat of secretPatterns) hardcoded_secrets_count += grepCount(f, pat);
  }

  // 3. Inline event handlers + console.log + TODO/FIXME (anti-patterns)
  let inline_event_handlers = 0;
  let console_log_count = 0;
  let todo_fixme_count = 0;
  for (const f of [...jsFiles, ...htmlFiles]) {
    inline_event_handlers += grepCount(f, /\son(click|load|error|submit|change|input)\s*=\s*["']/g);
    console_log_count += grepCount(f, /console\.(log|debug|info)\s*\(/g);
    todo_fixme_count += grepCount(f, /(TODO|FIXME|XXX|HACK)\s*[:(]/g);
  }
  for (const f of pyFiles) {
    todo_fixme_count += grepCount(f, /#\s*(TODO|FIXME|XXX|HACK)/g);
  }

  // 4. Cache buster drift — todos os 3 arquivos main devem estar em sync
  // (index.html referencia styles.css e app.js — verifica se foram bumpados juntos)
  // Métrica: contagem de tags ?v= que diferem da maior versão
  let cache_buster_drift = 0;
  try {
    const indexContent = readFileSync(join(ROOT, 'app/frontend/10-APP-index.html'), 'utf8');
    const versions = [...indexContent.matchAll(/(?:13-APP-styles\.css|11-APP-app\.js)\?v=(\d+)/g)].map(m => parseInt(m[1], 10));
    if (versions.length >= 2) {
      const max = Math.max(...versions);
      cache_buster_drift = versions.filter(v => max - v > 5).length;
    }
  } catch {}

  // 5. Tests E2E
  let e2e_test_count = 0;
  let e2e_skip_count = 0;
  const testFiles = walk(join(ROOT, 'tests'), ['.js', '.ts'], skipDirs);
  for (const f of testFiles) {
    e2e_test_count += grepCount(f, /\btest\s*\(\s*['"`]/g);
    e2e_skip_count += grepCount(f, /\.(skip|todo)\s*\(/g);
  }

  // 6. Python syntax check (binary OK/FAIL)
  let python_syntax_errors = 0;
  for (const f of pyFiles) {
    try {
      execSync(`python3 -m py_compile "${f}"`, { stdio: 'pipe' });
    } catch { python_syntax_errors++; }
  }

  return {
    schema_version: 1,
    measured_at: new Date().toISOString(),
    git_sha: execSync('git rev-parse HEAD', { encoding: 'utf8' }).trim(),
    metrics: {
      // Counter-balanced: small ↑ + large ↓
      largest_file_lines,
      files_over_2k_lines,
      files_over_5k_lines,
      total_loc_frontend_js,
      total_loc_frontend_css,
      total_loc_frontend_html,
      total_loc_backend_py,
      // Anti-patterns (max — ratchet só permite empate ou redução)
      hardcoded_secrets_count,
      inline_event_handlers,
      console_log_count,
      todo_fixme_count,
      cache_buster_drift,
      python_syntax_errors,
      // Test surface (e2e_test_count = min, ratchet só permite empate ou aumento;
      //               e2e_skip_count = max)
      e2e_test_count,
      e2e_skip_count,
    },
    file_sizes: sizes,
  };
}

// ---------- direções (max = não pode subir; min = não pode descer) ----------
const DIRECTIONS = {
  largest_file_lines: 'max',
  files_over_2k_lines: 'max',
  files_over_5k_lines: 'max',
  total_loc_frontend_js: 'max',
  total_loc_frontend_css: 'max',
  total_loc_frontend_html: 'max',
  total_loc_backend_py: 'max',
  hardcoded_secrets_count: 'max',
  inline_event_handlers: 'max',
  console_log_count: 'max',
  todo_fixme_count: 'max',
  cache_buster_drift: 'max',
  python_syntax_errors: 'max',
  e2e_test_count: 'min',
  e2e_skip_count: 'max',
};

// ---------- cli ----------
const args = process.argv.slice(2);
const mode = args[0] || 'measure';

if (mode === '--baseline') {
  const data = measure();
  writeFileSync(BASELINE_PATH, JSON.stringify(data, null, 2) + '\n');
  console.log(`✓ Baseline written to ${relative(process.cwd(), BASELINE_PATH)}`);
  console.log(`  git_sha: ${data.git_sha.slice(0, 8)}`);
  console.log(`  largest file: ${data.metrics.largest_file_lines} lines`);
  console.log(`  files >2k: ${data.metrics.files_over_2k_lines}`);
  console.log(`  files >5k: ${data.metrics.files_over_5k_lines}`);
  console.log(`  e2e tests: ${data.metrics.e2e_test_count}`);
  process.exit(0);
}

if (mode === '--gate') {
  if (!existsSync(BASELINE_PATH)) {
    console.error('✗ No baseline found at .diodo/baseline.json. Run --baseline first.');
    process.exit(2);
  }
  const baseline = JSON.parse(readFileSync(BASELINE_PATH, 'utf8'));
  const current = measure();

  const regressions = [];
  const improvements = [];

  for (const [k, dir] of Object.entries(DIRECTIONS)) {
    const cur = current.metrics[k];
    const base = baseline.metrics[k];
    if (cur === undefined || base === undefined) continue;
    if (dir === 'max' && cur > base) regressions.push({ metric: k, baseline: base, current: cur, delta: `+${cur - base}` });
    if (dir === 'min' && cur < base) regressions.push({ metric: k, baseline: base, current: cur, delta: `${cur - base}` });
    if (dir === 'max' && cur < base) improvements.push({ metric: k, baseline: base, current: cur, delta: `-${base - cur}` });
    if (dir === 'min' && cur > base) improvements.push({ metric: k, baseline: base, current: cur, delta: `+${cur - base}` });
  }

  console.log('## Diodo Gate Report\n');
  console.log(`Baseline: ${baseline.git_sha.slice(0, 8)} (${baseline.measured_at})`);
  console.log(`Current:  ${current.git_sha.slice(0, 8)} (${current.measured_at})\n`);

  if (improvements.length) {
    console.log('### ✓ Improvements\n');
    for (const i of improvements) console.log(`  ${i.metric}: ${i.baseline} → ${i.current} (${i.delta})`);
    console.log();
  }

  if (regressions.length) {
    console.log('### ✗ Regressions (gate FAIL)\n');
    for (const r of regressions) console.log(`  ${r.metric}: ${r.baseline} → ${r.current} (${r.delta})`);
    console.log('\nGate FAIL: pelo menos uma métrica regrediu. PR não pode mergear.');
    console.log('Pra subir o sarrafo (após melhoria intencional), rode: node .diodo/measure.mjs --baseline');
    process.exit(1);
  }

  console.log('### ✓ Gate PASS\n');
  console.log('Nenhuma métrica regrediu. PR pode prosseguir.');
  process.exit(0);
}

// default: measure + print
const data = measure();
console.log(JSON.stringify(data, null, 2));
