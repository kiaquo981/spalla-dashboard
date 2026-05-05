# Diodo — Quality Ratchet

Catraca unidirecional de métricas: PR pode adicionar código, **não pode piorar** nenhuma métrica congelada.

## Como funciona

`baseline.json` é o snapshot das métricas no commit congelado. CI roda `measure.mjs --gate` em cada PR e compara contra o baseline. Se qualquer métrica regrediu, o gate **comenta no PR** (modo descritivo atual — não bloqueia merge).

## Métricas trackeadas

Adaptadas pra stack Spalla (Python + HTML + Alpine.js vanilla — sem build step).

| Métrica | Direção | O que captura |
|---------|---------|---------------|
| `largest_file_lines` | max | Arquivo mais gordo do repo |
| `files_over_2k_lines` | max | Quantos arquivos passam de 2k linhas |
| `files_over_5k_lines` | max | Quantos arquivos passam de 5k linhas (catraca crítica) |
| `total_loc_frontend_js` | max | LOC total JS frontend |
| `total_loc_frontend_css` | max | LOC total CSS |
| `total_loc_frontend_html` | max | LOC total HTML |
| `total_loc_backend_py` | max | LOC total Python backend |
| `hardcoded_secrets_count` | max | Secrets em texto plano (sk_, ey_, etc) |
| `inline_event_handlers` | max | `onclick=`, `onload=`, etc — anti-pattern |
| `console_log_count` | max | `console.log/debug/info` deixados |
| `todo_fixme_count` | max | Marcadores TODO/FIXME/XXX/HACK |
| `cache_buster_drift` | max | Cache busters fora de sync (drift > 5) |
| `python_syntax_errors` | max | py_compile falhas (deve ser 0) |
| `e2e_test_count` | **min** | Quantos `test()` em tests/e2e/ — counter-balance |
| `e2e_skip_count` | max | `.skip()` em tests |

**Regra:** métricas `max` só podem empatar ou descer. Métricas `min` só podem empatar ou subir. Counter-balance: `e2e_test_count` (min) é o antagonista de `todo_fixme_count` (max) — você não pode acumular TODOs sem aumentar testes.

## Filosofia

1. **Brownfield = freeze, não conserte.** Os 4 arquivos monstro (`11-APP-app.js` 16k, `10-APP-index.html` 13k, `13-APP-styles.css` 8k, `14-APP-server.py` 8k) já existiam. Catraca congela o estado atual e impede ficar pior. Limpeza vem em PRs intencionais.
2. **Forward ratchet via `bump`.** Quando um PR melhora intencionalmente, rode `node .diodo/measure.mjs --baseline` e commite junto. Sarrafo sobe.
3. **Modo descritivo agora.** CI comenta diff no PR mas não bloqueia. Pra ativar bloqueio hard, edite `.github/workflows/diodo.yml` e troque o `continue-on-error: true` por `false`.

## Uso

```bash
# Gerar/atualizar baseline (após melhoria intencional)
node .diodo/measure.mjs --baseline

# Rodar gate localmente (compara HEAD vs baseline)
node .diodo/measure.mjs --gate

# Só medir o estado atual (debug)
node .diodo/measure.mjs
```

## Pra ativar gate hard

Quando confiar 100%, em `.github/workflows/diodo.yml`:

```diff
       - name: Run Diodo gate (compare against baseline)
         id: gate
-        continue-on-error: true
+        # remove continue-on-error pra bloquear merge
         run: |
           node .diodo/measure.mjs --gate | tee diodo-report.txt
```

E adicione "Diodo — Quality Ratchet / diodo-gate" como required check em Settings → Branches → Branch protection rules.

## Anti-patterns documentados

- ❌ Tentar limpar arquivos monstro **antes** de instalar o gate. Você nunca instala. Freeze first.
- ❌ Colocar threshold absoluto (ex: max 1000 linhas/arquivo). Os arquivos atuais já violam isso. Ratchet é **relativo**.
- ❌ Single-metric gate. Sempre counter-balance.
- ❌ Misturar refactor com feature no mesmo PR. PR de cleanup deve ser isolado e mexer no `bump`.

## Convenção de PR de cleanup

Quando intencionalmente reduzir métricas:

1. Faça o cleanup
2. Rode `node .diodo/measure.mjs --baseline`
3. Commit em 2 commits separados: `refactor(...)` + `chore(diodo): bump baseline`
4. PR title: `refactor: ... [diodo:bump]`
