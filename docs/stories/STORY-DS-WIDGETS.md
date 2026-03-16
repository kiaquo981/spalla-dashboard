---
title: "Widgets de Produção — Fila e Aging Alerts"
type: story
status: backlog
priority: P2
epic: dossie-pipeline
created: 2026-03-16
---

# Widgets de Produção — Fila e Aging Alerts

## Contexto

As views SQL já existem no Supabase (criadas em Fase B do Dossiê Pipeline):
- `vw_ds_production_queue` — mentorados com transcrição disponível mas sem dossiê produzido
- `ds_aging_alerts()` — documentos parados há >3 dias no mesmo estágio
- `vw_ds_metrics` — métricas de throughput e bottleneck

## Acceptance Criteria

### AC1: KPI Card — Fila de Produção
- [ ] Adicionar query `sb.from('vw_ds_production_queue').select('*', { count: 'exact', head: true })` no `loadDashboard()` ou equivalente em `11-APP-app.js`
- [ ] Exibir KPI card no dashboard: "X mentorados prontos para produção"
- [ ] Click no card navega para página Dossiês com filtro "nao_iniciado"

### AC2: Seção Aging Alerts
- [ ] Adicionar query `sb.rpc('ds_aging_alerts')` na página Dossiês em `11-APP-app.js`
- [ ] Exibir seção colapsável "Alertas de Aging" no topo da página Dossiês
- [ ] Cada alerta mostra: mentorado, tipo do doc, estágio atual, dias parado, responsável
- [ ] Ordenado por dias_parado DESC (mais antigos primeiro)
- [ ] Badge vermelho se dias_parado > 7

### AC3: Métricas de Pipeline
- [ ] Query `sb.from('vw_ds_metrics').select('*').single()` na página Dossiês
- [ ] Mini-cards com: throughput 30d, docs em bottleneck, tempo médio por estágio

## Arquivos a Modificar

| Arquivo | Mudança |
|---------|---------|
| `app/frontend/11-APP-app.js` | Adicionar queries + state para production_queue, aging_alerts, metrics |
| `app/frontend/10-APP-index.html` | KPI card HTML no dashboard + seção aging na página Dossiês |

## Dependências

- `vw_ds_production_queue` (DS-12) ✅ Deployada
- `ds_aging_alerts()` (DS-17) ✅ Deployada
- `vw_ds_metrics` (DS-18) ✅ Deployada

## Estimativa

Médio — ~2-4h de frontend (queries + HTML + CSS)
