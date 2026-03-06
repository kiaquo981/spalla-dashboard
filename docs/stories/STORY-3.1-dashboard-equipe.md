# Story 3.1 — Dashboard de Performance da Equipe

**Prioridade:** Alta | **Esforco:** Medio | **Wave:** 2
**Status:** [ ] Pendente

---

## Contexto

A equipe CASE tem 6 membros (Kaique, Heitor, Hugo, Queila, Mariza, Lara) gerenciando 40 mentorados ativos. Hoje, Queila (lider) nao tem como visualizar:
- Quem esta sobrecarregado com tarefas
- Quem demora mais para responder no WhatsApp
- Quantas calls cada membro fez na semana
- Se a carga de trabalho esta bem distribuida

Ela precisa abrir tarefa por tarefa, call por call, para montar esse quadro mental.

## Dados Ja Disponiveis (nao precisa criar)

| Dado | Fonte | Como acessar |
|------|-------|-------------|
| Tarefas por responsavel | `god_tasks.responsavel` | `vw_god_tasks_full` ja carregada em `data.tasks` |
| Calls por participante | `calls_mentoria` | `_supabaseCalls` ja carregado |
| Tempo resposta WA | `vw_god_pendencias.horas_pendente` | `data.pendencias` ja carregado |
| Mentorados por responsavel | `god_tasks` distinct `mentorado_nome` | Derivavel de `data.tasks` |
| Membros da equipe | `TEAM_MEMBERS` array | `11-APP-app.js` line 21 |

## O Que Precisa Ser Criado

### Camada 1: View SQL — `vw_god_team_performance`

**Delegacao:** @data-engineer

```sql
CREATE OR REPLACE VIEW vw_god_team_performance AS
WITH task_stats AS (
  SELECT
    responsavel,
    COUNT(*) FILTER (WHERE status = 'pendente') AS tarefas_pendentes,
    COUNT(*) FILTER (WHERE status = 'em_andamento') AS tarefas_em_andamento,
    COUNT(*) FILTER (WHERE status = 'concluida' AND updated_at >= now() - interval '7 days') AS concluidas_semana,
    COUNT(*) FILTER (WHERE status = 'concluida' AND updated_at >= now() - interval '30 days') AS concluidas_mes,
    COUNT(*) FILTER (WHERE status = 'pendente' AND data_fim IS NOT NULL AND data_fim < CURRENT_DATE) AS tarefas_atrasadas,
    COUNT(DISTINCT mentorado_nome) AS mentorados_atribuidos
  FROM god_tasks
  WHERE responsavel IS NOT NULL
  GROUP BY responsavel
),
call_stats AS (
  SELECT
    -- Precisamos de um campo "participante" ou usar observacoes_equipe
    -- Por ora: contar calls por mentorado_id dos mentorados atribuidos
    NULL AS responsavel,
    0 AS calls_semana,
    0 AS calls_mes
)
SELECT
  ts.responsavel,
  ts.tarefas_pendentes,
  ts.tarefas_em_andamento,
  ts.concluidas_semana,
  ts.concluidas_mes,
  ts.tarefas_atrasadas,
  ts.mentorados_atribuidos,
  -- Carga: (pendentes + em_andamento) / 20 * 100 (20 = capacidade padrao)
  LEAST(ROUND((ts.tarefas_pendentes + ts.tarefas_em_andamento)::numeric / 20 * 100), 100) AS carga_pct
FROM task_stats ts;
```

**Nota para @data-engineer:**
- A view acima e um ponto de partida. Ajustar conforme as tabelas reais.
- Calls: `calls_mentoria` nao tem campo `responsavel` direto — precisamos definir como associar calls a membros. Opcoes: (a) usar mentorados atribuidos, (b) adicionar campo `responsavel` em calls_mentoria.
- WA response time: pode vir de `vw_god_pendencias` agrupado por quem respondeu, mas `respondido_por` nao existe hoje. Considerar adicionar.

### Camada 2: Backend — Carregar dados no `loadDashboard()`

**Delegacao:** @dev

**Arquivo:** `11-APP-app.js`

**Tarefas:**
- [ ] Adicionar `teamPerformance: []` ao objeto `data` (line ~172)
- [ ] No `loadDashboard()`, adicionar ao `Promise.all` (line ~863):
  ```js
  sb.from('vw_god_team_performance').select('*')
  ```
- [ ] Salvar resultado em `this.data.teamPerformance`
- [ ] Criar computed `get teamStats()` que cruza `data.teamPerformance` com `TEAM_MEMBERS`:
  ```js
  get teamStats() {
    return TEAM_MEMBERS.map(member => {
      const stats = this.data.teamPerformance.find(
        tp => tp.responsavel?.toLowerCase().includes(member.name.toLowerCase())
      ) || {};
      // Complementar com dados client-side
      const myTasks = this.data.tasks.filter(
        t => t.responsavel?.toLowerCase().includes(member.name.toLowerCase())
      );
      const pendentes = myTasks.filter(t => t.status === 'pendente').length;
      const emAndamento = myTasks.filter(t => t.status === 'em_andamento').length;
      const atrasadas = myTasks.filter(t =>
        t.status === 'pendente' && t.data_fim && parseDateStr(t.data_fim) < SYSTEM_TODAY
      ).length;
      const concluidas7d = myTasks.filter(t => {
        if (t.status !== 'concluida' || !t.updated_at) return false;
        const d = new Date(t.updated_at);
        const week = new Date(); week.setDate(week.getDate() - 7);
        return d >= week;
      }).length;
      const mentorados = [...new Set(myTasks.map(t => t.mentorado_nome).filter(Boolean))].length;
      const carga = Math.min(Math.round((pendentes + emAndamento) / 20 * 100), 100);

      return {
        nome: member.name,
        email: member.email,
        pendentes,
        emAndamento,
        atrasadas,
        concluidas7d,
        mentorados,
        carga,
        cargaStatus: carga >= 85 ? 'danger' : carga >= 60 ? 'warning' : 'success',
      };
    });
  }
  ```

**Nota:** A abordagem client-side (computar de `data.tasks`) pode ser suficiente sem a view SQL. Isso simplifica — a view SQL so sera necessaria quando precisarmos de dados que o frontend nao tem (ex: historico de calls por membro, tempo medio de resposta WA).

**Decisao para @dev:** Comecar client-side puro (sem view SQL). Se performance ou dados insuficientes, escalar para view.

### Camada 3: Frontend — Pagina "Equipe"

**Delegacao:** @dev (implementacao) com input de @ux-design-expert (se quiser refinar layout)

**Arquivo:** `10-APP-index.html`

**Estrutura da pagina:**

```
┌─────────────────────────────────────────────────────────────┐
│  Performance da Equipe                        [Semana ▼]    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ Kaique   │ │ Heitor   │ │ Hugo     │ │ Queila   │ ...   │
│  │          │ │          │ │          │ │          │       │
│  │ Pend: 12 │ │ Pend: 18 │ │ Pend: 8  │ │ Pend: 5  │       │
│  │ Andam: 3 │ │ Andam: 4 │ │ Andam: 2 │ │ Andam: 1 │       │
│  │ Atr: 2   │ │ Atr: 7 ⚠│ │ Atr: 0   │ │ Atr: 0   │       │
│  │ Conc/7d:8│ │ Conc/7d:3│ │ Conc/7d:6│ │ Conc/7d:4│       │
│  │ Ment: 7  │ │ Ment: 9  │ │ Ment: 6  │ │ Ment: 5  │       │
│  │          │ │          │ │          │ │          │       │
│  │ ████░ 78%│ │ █████ 94%│ │ ███░ 50% │ │ ██░ 30%  │       │
│  │  Carga   │ │ SOBREC.  │ │  Carga   │ │  Carga   │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
│                                                             │
│  Click em membro → filtra tarefas por responsavel          │
└─────────────────────────────────────────────────────────────┘
```

**Tarefas HTML:**
- [ ] Adicionar item "Equipe" no sidebar (secao "Principal", apos Agenda)
- [ ] Adicionar `ui.page === 'equipe'` no navigate()
- [ ] Grid de cards responsivos (CSS grid, 3 colunas desktop, 2 tablet, 1 mobile)
- [ ] Cada card: avatar com initials, nome, 6 metricas, barra de carga
- [ ] Click no card → navega para Tasks com filtro `taskAssignee = member.name`
- [ ] Badge visual "SOBRECARGA" quando carga >= 85%

### Camada 4: CSS

**Delegacao:** @dev

**Arquivo:** `13-APP-styles.css`

**Classes a criar:**
```css
/* Container */
.team-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 16px; }

/* Card */
.team-card { background: white; border-radius: 12px; border: 1px solid var(--neutral-200); padding: 16px; transition: all var(--transition-base); cursor: pointer; }
.team-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-md); }
.team-card--danger { border-left: 3px solid var(--danger); }

/* Header */
.team-card__header { display: flex; align-items: center; gap: 10px; margin-bottom: 12px; }
.team-card__name { font-size: 14px; font-weight: 700; color: var(--neutral-800); }
.team-card__overload { font-size: 10px; font-weight: 700; color: var(--danger); text-transform: uppercase; }

/* Metricas */
.team-card__stats { display: grid; grid-template-columns: 1fr 1fr; gap: 6px; margin-bottom: 12px; }
.team-card__stat { display: flex; justify-content: space-between; font-size: 12px; }
.team-card__stat-label { color: var(--neutral-500); }
.team-card__stat-val { font-weight: 600; color: var(--neutral-800); }
.team-card__stat-val--danger { color: var(--danger); }

/* Barra de carga */
.team-card__load { height: 6px; background: var(--neutral-200); border-radius: 3px; overflow: hidden; }
.team-card__load-fill { height: 100%; border-radius: 3px; transition: width var(--transition-slow); }
.team-card__load-fill--success { background: var(--success); }
.team-card__load-fill--warning { background: var(--warning); }
.team-card__load-fill--danger { background: var(--danger); }
.team-card__load-label { font-size: 11px; color: var(--neutral-500); margin-top: 4px; text-align: right; }
```

## Criterios de Aceite

- [ ] Pagina "Equipe" acessivel pelo sidebar
- [ ] Card por membro mostrando: pendentes, em andamento, atrasadas, concluidas/7d, mentorados, carga %
- [ ] Barra de carga colorida (verde <60%, amarelo 60-85%, vermelho >85%)
- [ ] Badge "SOBRECARGA" quando >= 85%
- [ ] Click no card filtra pagina de Tasks pelo membro
- [ ] Responsivo (3 → 2 → 1 coluna)
- [ ] Dados atualizados em tempo real (recomputa de `data.tasks`)

## Arquivos Modificados

| Arquivo | Modificacao |
|---------|------------|
| `11-APP-app.js` | `data.teamPerformance`, `get teamStats()`, navigate('equipe') |
| `10-APP-index.html` | Sidebar item, pagina equipe com grid de cards |
| `13-APP-styles.css` | `.team-grid`, `.team-card`, `.team-card__*` |

## Ordem de Execucao

1. @dev → Computed `teamStats` no app.js (client-side, sem SQL)
2. @dev → HTML da pagina + CSS
3. @dev → Testar com dados reais
4. Se dados insuficientes → @data-engineer cria `vw_god_team_performance`

---
