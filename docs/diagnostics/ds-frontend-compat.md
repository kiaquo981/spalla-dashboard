# DS-09: Frontend Compatibility Check — 2026-03-16

## vw_ds_pipeline — COMPATÍVEL ✅

Frontend (`loadDsData()` L4195): `sb.from('vw_ds_pipeline').select('*')`
View retorna 23 colunas. Frontend usa `*` — sem risco de mismatch.

## ds_documentos — COMPATÍVEL ✅

Frontend (`loadDsData()` L4196) pede 10 colunas:
`id, producao_id, mentorado_id, tipo, titulo, estagio_atual, responsavel_atual, estagio_desde, link_doc, ordem`

DB tem 19 colunas. Todas as 10 do frontend existem.

### Cross-check resultado
- Frontend pede mas DB NÃO tem: **NENHUM**
- DB tem mas frontend NÃO pede: 9 colunas de timestamp (data_producao_ia, data_revisao_*, etc.) — usadas no detail view com `select('*')` (L4213)

## ds_producoes — COMPATÍVEL ✅

Frontend (`loadDsMenteeDetail()` L4212): `sb.from('ds_producoes').select('*')` — sem risco.

## ds_eventos — COMPATÍVEL ✅

Frontend L4214: `sb.from('ds_eventos').select('*')` — sem risco.

## ds_ajustes — COMPATÍVEL ✅

Frontend L4215: `sb.from('ds_ajustes').select('*')` — sem risco.

## Conclusão

Frontend é **100% compatível** com o schema deployado. Nenhum fix necessário.
O frontend deve funcionar imediatamente com os dados reais das tabelas `ds_*`.
