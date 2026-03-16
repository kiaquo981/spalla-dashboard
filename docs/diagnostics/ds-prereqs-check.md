# DS-01+DS-06: Diagnóstico de Pré-requisitos — 2026-03-16

## Resultado

| Query | Resultado | Status |
|-------|-----------|--------|
| Q1: mentorados count | **76 mentorados** | ✅ Existe com dados |
| Q2: god_tasks colunas | `auto_created`, `fonte`, `space_id`, `list_id` — TODAS existem | ✅ Bridge-ready |
| Q3: ds_producoes | **EXISTE com 40 registros** | ⚠️ Já deployado |
| Q4: ds_documentos | **EXISTE com 66 registros** | ⚠️ Já deployado |
| Q4b: ds_eventos | **EXISTE com 40 registros** | ⚠️ Já deployado |
| Q4c: ds_ajustes | **EXISTE com 0 registros** | ✅ Tabela vazia |
| Q5: nomes sample | Amanda Ribeiro, Betina Franciosi, Camille Bragança... | ✅ Match ILIKE |
| Q6: vw_ds_pipeline | **40 registros** | ✅ View funcional |
| Bridge: god_task_id em ds_documentos | **NÃO EXISTE** | ❌ Migration 46 NÃO executada |

## Distribuição de Status (ds_producoes)

| Status | Count |
|--------|-------|
| finalizado | 26 |
| revisao | 5 |
| enviado | 3 |
| call_estrategia | 2 |
| cancelado | 1 |
| aprovado | 1 |
| nao_iniciado | 1 |
| pausado | 1 |
| **Total** | **40** |

## Distribuição de Estágios (ds_documentos)

| Estágio | Count |
|---------|-------|
| finalizado | 27 |
| pendente | 12 |
| enviado | 9 |
| revisao_mariza | 8 |
| aprovado | 4 |
| revisao_kaique | 3 |
| revisao_queila | 3 |
| **Total** | **66** |

## Colunas ds_documentos

created_at, data_envio, data_feedback_mentorado, data_finalizado, data_producao_ia,
data_revisao_kaique, data_revisao_mariza, data_revisao_queila, estagio_atual,
estagio_desde, id, link_doc, mentorado_id, ordem, producao_id, responsavel_atual,
tipo, titulo, updated_at

**Nota: NÃO tinha `god_task_id`** — migration 46-SQL-ds-bridge-v2.sql foi executada e corrigiu isso.

## Impacto no Plano

- **DS-02, DS-03, DS-04, DS-05** → SKIP (schema + seed já executados)
- **DS-06** → ✅ god_tasks tem todas as colunas necessárias
- **DS-07** → PRECISA EXECUTAR (migration 46 bridge)
- **DS-08** → Validação parcial — dados existem, view funciona
- **DS-09** → Frontend deveria funcionar — testar
- **DS-10** → Ainda relevante (deprecar array estático)
