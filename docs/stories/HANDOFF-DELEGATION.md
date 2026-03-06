# Handoff & Delegacao — Features v3

**Data:** 2026-03-06
**Architect:** Aria

---

## Resumo Executivo

3 features planejadas, 3 stories detalhadas, prontas para execucao.

| # | Feature | Story | Complexidade | Agente Principal | SQL Necessario? |
|---|---------|-------|-------------|-----------------|-----------------|
| 1 | Dashboard Equipe | STORY-3.1 | Media | @dev | Nao (client-side) |
| 2 | Tarefas Recorrentes | STORY-3.2 | Media | @dev + @data-engineer | Sim (ALTER TABLE) |
| 3 | Health Score | STORY-3.3 | Alta | @dev | Nao (fase 1) |

---

## Delegacao por Agente

### @data-engineer (Dara)

**Responsabilidade:** Migracoes SQL no Supabase

**Tarefa 1 — Recorrencia em god_tasks** (Story 3.2)
```
Prioridade: Fazer PRIMEIRO (bloqueia @dev na Story 3.2)
Arquivo: Criar XX-SQL-task-recurrence.sql
Executar no Supabase SQL Editor

ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS recorrencia TEXT DEFAULT 'nenhuma'
  CHECK (recorrencia IN ('nenhuma', 'diario', 'semanal', 'mensal', 'quinzenal'));
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS dia_recorrencia INT;
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS recorrencia_ativa BOOLEAN DEFAULT true;
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS recorrencia_origem_id UUID REFERENCES god_tasks(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_god_tasks_recorrencia ON god_tasks(recorrencia) WHERE recorrencia != 'nenhuma';
```

**Tarefa 2 — Tabela de Snapshots** (Story 3.3, Fase 2 — NAO urgente)
```
Prioridade: Pode esperar 1-2 semanas
Arquivo: Criar XX-SQL-health-snapshots.sql

CREATE TABLE IF NOT EXISTS god_health_snapshots (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  mentorado_id BIGINT REFERENCES mentorados(id) ON DELETE CASCADE,
  semana DATE NOT NULL,
  health_score INT NOT NULL,
  breakdown JSONB,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(mentorado_id, semana)
);
CREATE INDEX IF NOT EXISTS idx_health_snapshots_mentee ON god_health_snapshots(mentorado_id);
```

**Checklist @data-engineer:**
- [ ] Rodar ALTER TABLE no Supabase (Tarefa 1)
- [ ] Verificar que vw_god_tasks_full continua funcionando apos ALTER
- [ ] Avisar @dev quando migracoes estiverem prontas
- [ ] (Fase 2) Criar tabela god_health_snapshots

---

### @dev (implementacao fullstack)

**Responsabilidade:** Todo o codigo frontend (JS, HTML, CSS)

#### Sprint 1: Health Score (Story 3.3) — NAO depende de SQL

**Por que comecar por aqui:** Zero dependencia de migracoes. Pode comecar imediatamente. Alto impacto visual.

```
Arquivos: 11-APP-app.js, 10-APP-index.html, 13-APP-styles.css
Referencia completa: docs/stories/STORY-3.3-health-score.md
```

**Checklist:**
- [ ] Implementar `calcHealthScore(m)` no app.js (funcao pura, retorna {total, breakdown, status, color})
- [ ] Implementar `healthScoreClass(score)` helper
- [ ] Substituir engagement bar nos mentee cards por health score bar
- [ ] Adicionar health breakdown card no detail page (tab resumo)
- [ ] CSS: `.mc-card__health-*`, `.health-breakdown*`
- [ ] Testar com dados reais — verificar se scores fazem sentido
- [ ] Ajustar thresholds se necessario

**Pontos de atencao:**
- `calcHealthScore` e chamado para cada card — manter performatico (sem async, sem DOM)
- No detail, o `data.detail.profile` pode ter campos diferentes de `data.mentees[i]` — verificar nomes dos campos
- Engagement bar atual (line ~320 do HTML) pode ser mantida junto ou substituida — decisao do dev

#### Sprint 2: Dashboard Equipe (Story 3.1) — NAO depende de SQL

```
Arquivos: 11-APP-app.js, 10-APP-index.html, 13-APP-styles.css
Referencia completa: docs/stories/STORY-3.1-dashboard-equipe.md
```

**Checklist:**
- [ ] Adicionar `equipe` ao navigate() e sidebar
- [ ] Implementar `get teamStats()` computed (client-side, de data.tasks)
- [ ] HTML: pagina equipe com grid de cards (1 por membro do TEAM_MEMBERS)
- [ ] Cada card: pendentes, em_andamento, atrasadas, concluidas/7d, mentorados, barra de carga
- [ ] Click no card → navega para Tasks com `taskAssignee = member.name`
- [ ] CSS: `.team-grid`, `.team-card`, `.team-card__*`
- [ ] Badge "SOBRECARGA" visual quando carga >= 85%
- [ ] Responsivo: 3→2→1 colunas

**Pontos de atencao:**
- `TEAM_MEMBERS` esta no app.js line 21 — usar diretamente
- `data.tasks` ja esta carregado — nao precisa de nova query
- Filtro por responsavel usa `.includes()` (match parcial) — consistente com `filteredTasks`

#### Sprint 3: Tarefas Recorrentes (Story 3.2) — DEPENDE de @data-engineer

```
Arquivos: 11-APP-app.js, 10-APP-index.html, 13-APP-styles.css
Referencia completa: docs/stories/STORY-3.2-tarefas-recorrentes.md
BLOQUEADO POR: @data-engineer completar ALTER TABLE
```

**Checklist:**
- [ ] Adicionar campos ao taskForm: `recorrencia`, `dia_recorrencia`, `recorrencia_ativa`
- [ ] Atualizar `_sbUpsertTask()` para incluir campos de recorrencia
- [ ] Implementar `_checkRecurringTasks()` — gerar nova instancia ao completar
- [ ] Implementar `_calcNextOccurrence(task)` — calcular proxima data
- [ ] Chamar `_checkRecurringTasks()` no `loadTasks()` e apos `updateTaskStatus()` → concluida
- [ ] HTML: campos de recorrencia no task modal (select + dia da semana / dia do mes)
- [ ] HTML: badge recorrente nos cards de tarefa
- [ ] CSS: `.task-recurring-badge`
- [ ] Testar ciclo: criar recorrente → completar → verificar nova instancia criada
- [ ] Testar proteção contra duplicatas

**Pontos de atencao:**
- `_checkRecurringTasks` pode rodar multiplas vezes — DEVE checar se ja existe instancia futura antes de criar
- `recorrencia_origem_id` vincula instancias — usar o id da tarefa MAE (nao da instancia anterior)
- Ao editar tarefa modal de uma instancia, nao alterar recorrencia da mae

---

## Ordem de Execucao Recomendada

```
Semana 1:
  @data-engineer → ALTER TABLE god_tasks (recorrencia) — 30 min
  @dev → Health Score completo (Story 3.3) — 3-4 horas

Semana 2:
  @dev → Dashboard Equipe (Story 3.1) — 2-3 horas
  @dev → Tarefas Recorrentes (Story 3.2) — 3-4 horas

Total estimado: ~10 horas de dev + 30 min de data-engineer
```

---

## Dependencias Cruzadas

```
Story 3.1 (Equipe)    → Independente, pode rodar a qualquer momento
Story 3.2 (Recorr.)   → Depende de ALTER TABLE do @data-engineer
Story 3.3 (Health)    → Independente (Fase 1), depende de tabela para Fase 2

Nenhuma story depende de outra. Podem ser paralelizadas.
```

---

## Verificacao Final (QA)

Apos implementacao, verificar:

**Health Score:**
1. Dashboard → mentee cards mostram score 0-100 com cor
2. Detail → breakdown mostra 6 dimensoes com barras
3. Mentorado com tudo em dia → score >= 80 (verde)
4. Mentorado inadimplente + sem call 30d → score < 50 (vermelho)

**Dashboard Equipe:**
5. Sidebar → item "Equipe" clicavel
6. Pagina mostra 6 cards (um por membro)
7. Card mostra metricas corretas (checar vs pagina Tasks)
8. Barra de carga verde/amarelo/vermelho conforme %
9. Click no card → vai para Tasks filtrado por responsavel

**Tarefas Recorrentes:**
10. Criar tarefa com recorrencia "semanal" → campo dia aparece
11. Completar tarefa → nova instancia criada automaticamente
12. Nova instancia tem data correta (proxima segunda, por ex)
13. Badge recorrente visivel no card
14. Completar de novo → mais uma instancia (sem duplicatas)

---

## Arquivos de Referencia

| Documento | Caminho |
|-----------|---------|
| Story 3.1 (Equipe) | `docs/stories/STORY-3.1-dashboard-equipe.md` |
| Story 3.2 (Recorrentes) | `docs/stories/STORY-3.2-tarefas-recorrentes.md` |
| Story 3.3 (Health Score) | `docs/stories/STORY-3.3-health-score.md` |
| Schema Tasks | `07-SQL-god-tasks-schema.sql` |
| App principal | `11-APP-app.js` |
| HTML principal | `10-APP-index.html` |
| CSS Design System | `13-APP-styles.css` |
| PRD Geral | `docs/prd/PRD-INCREMENTOS-V3.md` |

---

*— Aria, arquitetando o futuro do Spalla*
