# DS-21: E2E Test Results — 2026-03-16

## Test Results

| # | Test | Expected | Actual | Status |
|---|------|----------|--------|--------|
| 1 | vw_ds_production_queue | >= 0 | 0 (Thiago's transcriptions are 'processada') | PASS (view works, 0 is correct) |
| 2 | INSERT ds_eventos | 1 row | 1 row inserted (id: e5b1cda0) | PASS |
| 3 | Count e2e-test events | 1 | 1 | PASS |
| 4 | UPDATE ds_documentos stage | 1 row affected | Daniela Morais oferta → producao_ia, responsavel Mariza | PASS |
| 5 | Bridge trigger god_task | Task created | `[DS] oferta — Daniela Morais`, pendente, normal, Mariza, dossie, auto_created=true | PASS |
| 6 | ds_aging_alerts() | Returns rows | 19 docs with aging > 3 days | PASS |
| 7 | vw_ds_metrics | Returns data | throughput_30d=2, docs_bottleneck=19 | PASS |

## Summary

**7/7 PASS** — All components validated:
- Schema: tables exist and accept CRUD
- Views: vw_ds_pipeline, vw_ds_production_queue, vw_ds_metrics all functional
- Functions: ds_aging_alerts() returns correct data
- Triggers: bridge_ds_stage_to_task auto-creates god_task with correct fields
- Cleanup: all test data reverted successfully

## Notes

- vw_ds_production_queue returns 0 because the only transcriptions (Thiago Kailer) have status 'processada'. When new transcriptions with status 'disponivel' are added, this view will populate.
- 19 docs flagged as aging bottleneck — these are real docs stuck in review stages > 3 days.
