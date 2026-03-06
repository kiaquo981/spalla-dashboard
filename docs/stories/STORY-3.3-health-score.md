# Story 3.3 — Health Score Composto (0-100)

**Prioridade:** Alta | **Esforco:** Alto | **Wave:** 3
**Status:** [ ] Pendente

---

## Contexto

O campo `risco_churn` atual (critico/alto/medio/baixo) e subjetivo e unidimensional. Um mentorado pode estar "em dia" nas calls mas com zero vendas e engagement caindo — o risco deveria ser alto, mas aparece como baixo.

O Health Score resolve isso: um **unico numero de 0 a 100** calculado automaticamente a partir de 6 dimensoes ponderadas, usando **dados que ja existem** no sistema.

## Dados Ja Disponiveis (nao precisa criar nenhum)

| Dimensao | Campos | View/Tabela |
|----------|--------|-------------|
| Engagement WA | `whatsapp_7d`, `whatsapp_30d`, `horas_sem_resposta_equipe` | `vw_god_overview` |
| Frequencia Calls | `dias_desde_call`, `ultima_call_data` | `vw_god_overview` |
| Progresso Tarefas | `tarefas_pendentes`, `tarefas_atrasadas` | `vw_god_overview` |
| Evolucao Vendas | `faturamento_atual`, `meta_faturamento`, `qtd_vendas_total`, `ja_vendeu` | `vw_god_overview` |
| Implementacao | `marco_atual`, `engagement_score`, `implementation_score` | `vw_god_overview` |
| Financeiro | `contrato_assinado`, `status_financeiro` | `vw_god_overview` |

**Tudo vem de `vw_god_overview`** que ja e carregada em `data.mentees`.

## O Que Precisa Ser Criado

### Camada 1: View SQL — `vw_god_health_score`

**Delegacao:** @data-engineer

**Arquivo:** Novo `XX-SQL-health-score.sql`

```sql
CREATE OR REPLACE VIEW vw_god_health_score AS
SELECT
  m.id,
  m.nome,
  m.fase_jornada,
  m.cohort,

  -- === DIMENSAO 1: Engagement WhatsApp (peso 25%) ===
  -- Score 0-100 baseado em msgs 7d (0=0, 5+=80, 10+=100) + penalidade por resposta lenta
  LEAST(100, GREATEST(0,
    CASE
      WHEN COALESCE(m.whatsapp_7d, 0) >= 10 THEN 100
      WHEN COALESCE(m.whatsapp_7d, 0) >= 5 THEN 80
      WHEN COALESCE(m.whatsapp_7d, 0) >= 2 THEN 50
      WHEN COALESCE(m.whatsapp_7d, 0) >= 1 THEN 30
      ELSE 0
    END
    - CASE
        WHEN COALESCE(m.horas_sem_resposta_equipe, 0) > 48 THEN 40
        WHEN COALESCE(m.horas_sem_resposta_equipe, 0) > 24 THEN 20
        WHEN COALESCE(m.horas_sem_resposta_equipe, 0) > 12 THEN 10
        ELSE 0
      END
  )) AS score_wa,

  -- === DIMENSAO 2: Frequencia de Calls (peso 20%) ===
  -- Score 0-100 baseado em dias desde ultima call
  CASE
    WHEN COALESCE(m.dias_desde_call, 999) <= 14 THEN 100
    WHEN COALESCE(m.dias_desde_call, 999) <= 21 THEN 80
    WHEN COALESCE(m.dias_desde_call, 999) <= 30 THEN 50
    WHEN COALESCE(m.dias_desde_call, 999) <= 45 THEN 25
    ELSE 0
  END AS score_calls,

  -- === DIMENSAO 3: Progresso de Tarefas (peso 20%) ===
  -- Score 0-100 baseado em tarefas pendentes e atrasadas
  GREATEST(0,
    100
    - COALESCE(m.tarefas_pendentes, 0) * 5    -- -5 por pendente
    - COALESCE(m.tarefas_atrasadas, 0) * 15   -- -15 por atrasada
  ) AS score_tarefas,

  -- === DIMENSAO 4: Evolucao de Vendas (peso 15%) ===
  CASE
    WHEN COALESCE(m.meta_faturamento, 0) = 0 THEN
      CASE WHEN COALESCE(m.ja_vendeu, false) THEN 60 ELSE 20 END
    WHEN COALESCE(m.faturamento_atual, 0)::numeric / NULLIF(m.meta_faturamento, 0) >= 1.0 THEN 100
    WHEN COALESCE(m.faturamento_atual, 0)::numeric / NULLIF(m.meta_faturamento, 0) >= 0.5 THEN 70
    WHEN COALESCE(m.faturamento_atual, 0)::numeric / NULLIF(m.meta_faturamento, 0) >= 0.2 THEN 40
    ELSE 10
  END AS score_vendas,

  -- === DIMENSAO 5: Implementacao (peso 10%) ===
  -- Usa engagement_score e implementation_score ja calculados
  LEAST(100, GREATEST(0, (
    COALESCE(m.engagement_score, 50) * 0.5 +
    COALESCE(m.implementation_score, 50) * 0.5
  )::int)) AS score_implementacao,

  -- === DIMENSAO 6: Financeiro (peso 10%) ===
  CASE
    WHEN m.contrato_assinado = true AND m.status_financeiro IN ('em_dia', 'quitado', 'pago') THEN 100
    WHEN m.contrato_assinado = true AND m.status_financeiro = 'atrasado' THEN 40
    WHEN m.contrato_assinado = false THEN 20
    ELSE 50
  END AS score_financeiro

FROM vw_god_overview m;
```

**Nota para @data-engineer:**
- Todos os campos vem de `vw_god_overview` — nao precisa de JOIN adicional
- Os thresholds (10 msgs = 100, 5 msgs = 80, etc.) sao estimativas iniciais
- Ajustar com dados reais apos primeira rodada
- Considerar adicionar `score_total` calculado como coluna para evitar recomputo no frontend:
  ```sql
  -- No SELECT final, adicionar:
  ROUND(
    score_wa * 0.25 +
    score_calls * 0.20 +
    score_tarefas * 0.20 +
    score_vendas * 0.15 +
    score_implementacao * 0.10 +
    score_financeiro * 0.10
  ) AS health_score
  ```

### Alternativa: Calcular Client-Side (Sem View SQL)

**Delegacao:** @dev

Se preferir evitar migracoes SQL, o Health Score pode ser calculado inteiramente no frontend, ja que todos os dados ja estao em `data.mentees`.

**Arquivo:** `11-APP-app.js`

```js
calcHealthScore(m) {
  // Dimensao 1: Engagement WA (25%)
  let scoreWa = 0;
  const wa7d = m.whatsapp_7d || 0;
  if (wa7d >= 10) scoreWa = 100;
  else if (wa7d >= 5) scoreWa = 80;
  else if (wa7d >= 2) scoreWa = 50;
  else if (wa7d >= 1) scoreWa = 30;
  const horasSemResp = m.horas_sem_resposta_equipe || 0;
  if (horasSemResp > 48) scoreWa -= 40;
  else if (horasSemResp > 24) scoreWa -= 20;
  else if (horasSemResp > 12) scoreWa -= 10;
  scoreWa = Math.max(0, Math.min(100, scoreWa));

  // Dimensao 2: Frequencia Calls (20%)
  const diasCall = m.dias_desde_call ?? 999;
  let scoreCalls = 0;
  if (diasCall <= 14) scoreCalls = 100;
  else if (diasCall <= 21) scoreCalls = 80;
  else if (diasCall <= 30) scoreCalls = 50;
  else if (diasCall <= 45) scoreCalls = 25;

  // Dimensao 3: Progresso Tarefas (20%)
  const scoreTarefas = Math.max(0,
    100 - (m.tarefas_pendentes || 0) * 5 - (m.tarefas_atrasadas || 0) * 15
  );

  // Dimensao 4: Evolucao Vendas (15%)
  let scoreVendas = 20;
  const meta = m.meta_faturamento || 0;
  const fat = m.faturamento_atual || 0;
  if (meta > 0) {
    const pct = fat / meta;
    if (pct >= 1) scoreVendas = 100;
    else if (pct >= 0.5) scoreVendas = 70;
    else if (pct >= 0.2) scoreVendas = 40;
    else scoreVendas = 10;
  } else if (m.ja_vendeu) {
    scoreVendas = 60;
  }

  // Dimensao 5: Implementacao (10%)
  const scoreImpl = Math.min(100, Math.max(0, Math.round(
    (m.engagement_score || 50) * 0.5 + (m.implementation_score || 50) * 0.5
  )));

  // Dimensao 6: Financeiro (10%)
  let scoreFin = 50;
  if (m.contrato_assinado && ['em_dia', 'quitado', 'pago'].includes(m.status_financeiro)) scoreFin = 100;
  else if (m.contrato_assinado && m.status_financeiro === 'atrasado') scoreFin = 40;
  else if (m.contrato_assinado === false) scoreFin = 20;

  // Score final ponderado
  const total = Math.round(
    scoreWa * 0.25 +
    scoreCalls * 0.20 +
    scoreTarefas * 0.20 +
    scoreVendas * 0.15 +
    scoreImpl * 0.10 +
    scoreFin * 0.10
  );

  return {
    total,
    breakdown: { scoreWa, scoreCalls, scoreTarefas, scoreVendas, scoreImpl, scoreFin },
    status: total >= 80 ? 'saudavel' : total >= 50 ? 'atencao' : 'critico',
    color: total >= 80 ? 'success' : total >= 50 ? 'warning' : 'danger',
  };
}

healthScoreClass(score) {
  if (score >= 80) return 'health--saudavel';
  if (score >= 50) return 'health--atencao';
  return 'health--critico';
}
```

**Decisao:** Comecar client-side (zero SQL). Migrar para view SQL apenas se precisar de historico ou performance.

### Camada 2: Historico Semanal (para tendencia ↑↓)

**Delegacao:** @data-engineer (tabela) + @dev (snapshot)

**Nova tabela:**
```sql
CREATE TABLE IF NOT EXISTS god_health_snapshots (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  mentorado_id BIGINT REFERENCES mentorados(id) ON DELETE CASCADE,
  semana DATE NOT NULL, -- primeiro dia da semana (segunda)
  health_score INT NOT NULL,
  breakdown JSONB, -- {scoreWa, scoreCalls, scoreTarefas, ...}
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(mentorado_id, semana)
);

CREATE INDEX IF NOT EXISTS idx_health_snapshots_mentee ON god_health_snapshots(mentorado_id);
```

**Snapshot semanal (client-side, no loadDashboard):**
```js
async _saveWeeklyHealthSnapshot() {
  const monday = new Date();
  monday.setDate(monday.getDate() - monday.getDay() + 1);
  const semana = monday.toISOString().split('T')[0];

  // Verificar se ja salvou esta semana
  const lastSnapshot = localStorage.getItem('health_snapshot_week');
  if (lastSnapshot === semana) return;

  const snapshots = this.data.mentees.map(m => {
    const hs = this.calcHealthScore(m);
    return {
      mentorado_id: m.id,
      semana,
      health_score: hs.total,
      breakdown: hs.breakdown,
    };
  });

  const sb2 = await initSupabase();
  if (!sb2) return;
  await sb2.from('god_health_snapshots').upsert(snapshots, { onConflict: 'mentorado_id,semana' });
  localStorage.setItem('health_snapshot_week', semana);
}
```

**Para mostrar tendencia:** No computed ou no card, buscar snapshot da semana anterior e comparar:
```js
healthTrend(m) {
  // Implementar quando historico tiver pelo menos 2 semanas
  // Por ora, retornar null
  return null; // { direction: 'up'|'down'|'stable', diff: +5|-3|0 }
}
```

**Nota:** O snapshot pode ser fase 2. Na primeira implementacao, mostrar apenas o score sem tendencia.

### Camada 3: Frontend — Visual nos Mentee Cards

**Delegacao:** @dev

**Arquivo:** `10-APP-index.html`

**Substituir/complementar a barra de engagement atual no card (line ~320):**

```html
<!-- Health Score (substitui engagement bar) -->
<div class="mc-card__health">
  <div class="mc-card__health-bar">
    <div class="mc-card__health-fill"
         :style="'width:' + calcHealthScore(m).total + '%'"
         :class="'mc-card__health-fill--' + calcHealthScore(m).color">
    </div>
  </div>
  <span class="mc-card__health-val"
        :class="'mc-card__health-val--' + calcHealthScore(m).color"
        x-text="calcHealthScore(m).total"></span>
</div>
```

**No detail do mentorado — breakdown completo:**

```html
<!-- Health Score Breakdown (nova secao no detail, tab resumo) -->
<div class="health-breakdown" x-data="{ hs: calcHealthScore(data.detail?.profile || {}) }">
  <div class="health-breakdown__header">
    <span class="health-breakdown__title">Health Score</span>
    <span class="health-breakdown__total"
          :class="'health-breakdown__total--' + hs.color"
          x-text="hs.total + '/100'"></span>
  </div>
  <div class="health-breakdown__grid">
    <div class="health-breakdown__dim">
      <span class="health-breakdown__label">WhatsApp</span>
      <div class="health-breakdown__bar"><div :style="'width:' + hs.breakdown.scoreWa + '%'" class="health-breakdown__fill"></div></div>
      <span x-text="hs.breakdown.scoreWa"></span>
    </div>
    <div class="health-breakdown__dim">
      <span class="health-breakdown__label">Calls</span>
      <div class="health-breakdown__bar"><div :style="'width:' + hs.breakdown.scoreCalls + '%'" class="health-breakdown__fill"></div></div>
      <span x-text="hs.breakdown.scoreCalls"></span>
    </div>
    <div class="health-breakdown__dim">
      <span class="health-breakdown__label">Tarefas</span>
      <div class="health-breakdown__bar"><div :style="'width:' + hs.breakdown.scoreTarefas + '%'" class="health-breakdown__fill"></div></div>
      <span x-text="hs.breakdown.scoreTarefas"></span>
    </div>
    <div class="health-breakdown__dim">
      <span class="health-breakdown__label">Vendas</span>
      <div class="health-breakdown__bar"><div :style="'width:' + hs.breakdown.scoreVendas + '%'" class="health-breakdown__fill"></div></div>
      <span x-text="hs.breakdown.scoreVendas"></span>
    </div>
    <div class="health-breakdown__dim">
      <span class="health-breakdown__label">Implementacao</span>
      <div class="health-breakdown__bar"><div :style="'width:' + hs.breakdown.scoreImpl + '%'" class="health-breakdown__fill"></div></div>
      <span x-text="hs.breakdown.scoreImpl"></span>
    </div>
    <div class="health-breakdown__dim">
      <span class="health-breakdown__label">Financeiro</span>
      <div class="health-breakdown__bar"><div :style="'width:' + hs.breakdown.scoreFin + '%'" class="health-breakdown__fill"></div></div>
      <span x-text="hs.breakdown.scoreFin"></span>
    </div>
  </div>
</div>
```

### Camada 4: CSS

**Delegacao:** @dev

**Arquivo:** `13-APP-styles.css`

```css
/* Health Score no mentee card */
.mc-card__health { display: flex; align-items: center; gap: 6px; }
.mc-card__health-bar { flex: 1; height: 6px; background: var(--neutral-200); border-radius: 3px; overflow: hidden; }
.mc-card__health-fill { height: 100%; border-radius: 3px; transition: width 0.5s ease; }
.mc-card__health-fill--success { background: var(--success); }
.mc-card__health-fill--warning { background: var(--warning); }
.mc-card__health-fill--danger { background: var(--danger); }
.mc-card__health-val { font-size: 12px; font-weight: 700; min-width: 24px; text-align: right; }
.mc-card__health-val--success { color: var(--success-dark); }
.mc-card__health-val--warning { color: var(--warning-dark); }
.mc-card__health-val--danger { color: var(--danger-dark); }

/* Health Breakdown no detail */
.health-breakdown { background: white; border-radius: 12px; border: 1px solid var(--neutral-200); padding: 16px; }
.health-breakdown__header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.health-breakdown__title { font-size: 14px; font-weight: 700; color: var(--neutral-800); }
.health-breakdown__total { font-size: 20px; font-weight: 800; }
.health-breakdown__total--success { color: var(--success); }
.health-breakdown__total--warning { color: var(--warning); }
.health-breakdown__total--danger { color: var(--danger); }
.health-breakdown__grid { display: flex; flex-direction: column; gap: 8px; }
.health-breakdown__dim { display: grid; grid-template-columns: 100px 1fr 30px; align-items: center; gap: 8px; }
.health-breakdown__label { font-size: 12px; color: var(--neutral-500); }
.health-breakdown__bar { height: 6px; background: var(--neutral-200); border-radius: 3px; overflow: hidden; }
.health-breakdown__fill { height: 100%; background: var(--brand-500); border-radius: 3px; transition: width 0.5s ease; }
.health-breakdown__dim span:last-child { font-size: 12px; font-weight: 600; color: var(--neutral-700); text-align: right; }
```

## Criterios de Aceite

- [ ] Cada mentee card mostra Health Score (0-100) com barra colorida
- [ ] Score >= 80: verde (saudavel), 50-79: amarelo (atencao), <50: vermelho (critico)
- [ ] Detail page mostra breakdown das 6 dimensoes com barras individuais
- [ ] Score calculado automaticamente a partir dos dados existentes (sem input manual)
- [ ] Formula ponderada: WA 25% + Calls 20% + Tarefas 20% + Vendas 15% + Impl 10% + Fin 10%
- [ ] Score atualiza ao recarregar dashboard
- [ ] (Fase 2) Snapshot semanal salvo para historico de tendencia

## Arquivos Modificados

| Arquivo | Modificacao |
|---------|------------|
| `11-APP-app.js` | `calcHealthScore(m)`, `healthScoreClass()`, `_saveWeeklyHealthSnapshot()` |
| `10-APP-index.html` | Health bar nos mentee cards, breakdown no detail |
| `13-APP-styles.css` | `.mc-card__health-*`, `.health-breakdown*` |
| `XX-SQL-health-score.sql` | (Opcional) View SQL + tabela snapshots |

## Ordem de Execucao

1. @dev → Implementar `calcHealthScore(m)` client-side no app.js
2. @dev → Substituir engagement bar nos cards pelo health score
3. @dev → Adicionar breakdown no detail page
4. @dev → CSS
5. @dev → Testar com dados reais, calibrar thresholds
6. (Fase 2) @data-engineer → Criar tabela `god_health_snapshots`
7. (Fase 2) @dev → Implementar snapshot semanal + tendencia ↑↓

## Calibracao de Thresholds

Os valores iniciais sao estimativas. Apos primeira implementacao, rodar com dados reais e ajustar:

| Dimensao | Calibrar |
|----------|---------|
| WA 7d | Quantas msgs/semana e "bom"? 5? 10? 15? Depende do mentorado |
| Dias sem call | 14d = ok, 21d = atencao, 30d = critico? Ou mais/menos? |
| Tarefas | -5 por pendente, -15 por atrasada? Muito punitivo? |
| Vendas vs meta | Meta de faturamento e confiavel? Muitos com meta 0? |
| Implementacao | `engagement_score` e `implementation_score` sao confiaveis? |
| Financeiro | Peso de 10% e suficiente? Inadimplencia deveria penalizar mais? |

**Recomendacao:** Implementar, rodar 1 semana, coletar feedback de Queila, ajustar pesos e thresholds.

---
