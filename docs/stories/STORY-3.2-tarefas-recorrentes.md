# Story 3.2 — Tarefas Recorrentes

**Prioridade:** Media | **Esforco:** Medio | **Wave:** 2
**Status:** [ ] Pendente

---

## Contexto

A equipe CASE tem tarefas que se repetem toda semana/mes:
- "Revisar mentorados sem call ha 21 dias" (toda segunda)
- "Fazer follow-up dos inadimplentes" (dia 5 de cada mes)
- "Atualizar metricas de Instagram" (toda sexta)
- "Verificar dossies pendentes" (toda quarta)

Hoje, a equipe precisa lembrar de criar essas tarefas manualmente toda vez. Esquece. Acumula.

## Estado Atual do Schema

**Boas noticias:** O schema de `god_tasks` em `07-SQL-god-tasks-schema.sql` **NAO** tem campo de recorrencia, mas `god_reminders` (line 78) ja tem:
```sql
recorrencia TEXT DEFAULT 'nenhuma' CHECK (recorrencia IN ('nenhuma', 'diario', 'semanal', 'mensal'))
```

Precisamos adicionar campos similares a `god_tasks`.

## O Que Precisa Ser Criado

### Camada 1: Migracoes SQL

**Delegacao:** @data-engineer

**Arquivo:** Novo `XX-SQL-task-recurrence.sql`

```sql
-- Adicionar campos de recorrencia em god_tasks
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS recorrencia TEXT DEFAULT 'nenhuma'
  CHECK (recorrencia IN ('nenhuma', 'diario', 'semanal', 'mensal', 'quinzenal'));
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS dia_recorrencia INT;
  -- Para semanal: 0=domingo, 1=segunda... 6=sabado
  -- Para mensal: 1-31 (dia do mes)
  -- Para quinzenal: 0-6 (dia da semana, repete a cada 14 dias)
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS recorrencia_ativa BOOLEAN DEFAULT true;
ALTER TABLE god_tasks ADD COLUMN IF NOT EXISTS recorrencia_origem_id UUID REFERENCES god_tasks(id) ON DELETE SET NULL;
  -- Referencia a tarefa original que gerou esta instancia

-- Index para buscar tarefas recorrentes rapidamente
CREATE INDEX IF NOT EXISTS idx_god_tasks_recorrencia ON god_tasks(recorrencia) WHERE recorrencia != 'nenhuma';
```

**Nota para @data-engineer:**
- `recorrencia_origem_id` permite rastrear que todas as instancias vieram da mesma tarefa "mae"
- `recorrencia_ativa` permite pausar sem deletar
- `dia_recorrencia` e nullable — se null e semanal, assume dia da criacao

### Camada 2: Logica de Geracao de Instancias

**Delegacao:** @dev

**Arquivo:** `11-APP-app.js`

**Abordagem:** Verificar no `loadTasks()` se alguma tarefa recorrente precisa gerar nova instancia.

**Logica core:**

```js
async _checkRecurringTasks() {
  const recurring = this.data.tasks.filter(t =>
    t.recorrencia && t.recorrencia !== 'nenhuma' &&
    t.recorrencia_ativa !== false &&
    t.status === 'concluida'
  );

  for (const task of recurring) {
    const nextDate = this._calcNextOccurrence(task);
    if (!nextDate) continue;

    // Verificar se ja existe instancia futura desta recorrencia
    const existingFuture = this.data.tasks.find(t =>
      t.recorrencia_origem_id === task.id &&
      t.status === 'pendente'
    );
    if (existingFuture) continue; // Ja tem proxima instancia

    // Criar nova instancia
    const newTask = {
      titulo: task.titulo,
      descricao: task.descricao,
      responsavel: task.responsavel,
      mentorado_nome: task.mentorado_nome,
      mentorado_id: task.mentorado_id,
      prioridade: task.prioridade,
      space_id: task.space_id,
      list_id: task.list_id,
      recorrencia: task.recorrencia,
      dia_recorrencia: task.dia_recorrencia,
      recorrencia_ativa: true,
      recorrencia_origem_id: task.recorrencia_origem_id || task.id,
      data_inicio: nextDate,
      data_fim: nextDate,
      status: 'pendente',
    };

    await this._sbUpsertTask(newTask, true);
    this.data.tasks.push({ ...newTask, id: 'temp-' + Date.now() }); // UI refresh
  }
}

_calcNextOccurrence(task) {
  const today = new Date();
  const completedAt = task.updated_at ? new Date(task.updated_at) : today;

  switch (task.recorrencia) {
    case 'diario': {
      const next = new Date(completedAt);
      next.setDate(next.getDate() + 1);
      // Pular fim de semana
      while (next.getDay() === 0 || next.getDay() === 6) next.setDate(next.getDate() + 1);
      return next.toISOString().split('T')[0];
    }
    case 'semanal': {
      const targetDay = task.dia_recorrencia ?? completedAt.getDay();
      const next = new Date(completedAt);
      next.setDate(next.getDate() + ((7 + targetDay - next.getDay()) % 7 || 7));
      return next.toISOString().split('T')[0];
    }
    case 'quinzenal': {
      const targetDay = task.dia_recorrencia ?? completedAt.getDay();
      const next = new Date(completedAt);
      next.setDate(next.getDate() + 14 + ((7 + targetDay - next.getDay()) % 7));
      return next.toISOString().split('T')[0];
    }
    case 'mensal': {
      const targetDay = task.dia_recorrencia ?? completedAt.getDate();
      const next = new Date(completedAt);
      next.setMonth(next.getMonth() + 1);
      next.setDate(Math.min(targetDay, new Date(next.getFullYear(), next.getMonth() + 1, 0).getDate()));
      return next.toISOString().split('T')[0];
    }
    default: return null;
  }
}
```

**Quando executar:** Chamar `_checkRecurringTasks()` no final de `loadTasks()` e apos cada `updateTaskStatus()` quando status muda para `concluida`.

### Camada 3: UI — Formulario de Tarefa

**Delegacao:** @dev

**Arquivo:** `10-APP-index.html` — dentro do Task Modal

**Adicionar apos o campo "Prioridade":**

```html
<!-- Recorrencia -->
<div style="margin-top:12px">
  <label class="form-label">Recorrencia</label>
  <select class="ln-select" x-model="taskForm.recorrencia" style="width:100%">
    <option value="nenhuma">Nenhuma (tarefa unica)</option>
    <option value="diario">Diaria (dias uteis)</option>
    <option value="semanal">Semanal</option>
    <option value="quinzenal">Quinzenal</option>
    <option value="mensal">Mensal</option>
  </select>
</div>
<div x-show="taskForm.recorrencia === 'semanal' || taskForm.recorrencia === 'quinzenal'" style="margin-top:8px">
  <label class="form-label">Dia da semana</label>
  <select class="ln-select" x-model="taskForm.dia_recorrencia" style="width:100%">
    <option value="1">Segunda</option>
    <option value="2">Terca</option>
    <option value="3">Quarta</option>
    <option value="4">Quinta</option>
    <option value="5">Sexta</option>
  </select>
</div>
<div x-show="taskForm.recorrencia === 'mensal'" style="margin-top:8px">
  <label class="form-label">Dia do mes</label>
  <input type="number" class="ln-input" x-model="taskForm.dia_recorrencia" min="1" max="28" placeholder="Ex: 5" style="width:100%">
</div>
```

**Adicionar ao `taskForm` (app.js):**
```js
recorrencia: 'nenhuma',
dia_recorrencia: null,
recorrencia_ativa: true,
```

### Camada 4: Indicadores Visuais

**Delegacao:** @dev

**Nos cards de tarefa (board e list view), quando `t.recorrencia !== 'nenhuma'`:**

```html
<span class="task-recurring-badge" x-show="t.recorrencia && t.recorrencia !== 'nenhuma'"
      :title="'Recorrente: ' + t.recorrencia">
  <svg width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
    <polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/>
    <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/>
  </svg>
</span>
```

**CSS:**
```css
.task-recurring-badge {
  display: inline-flex; align-items: center;
  color: var(--purple); background: var(--purple-light);
  padding: 2px 6px; border-radius: 4px;
  font-size: 10px; font-weight: 600;
}
```

### Camada 5: Persistencia no `_sbUpsertTask`

**Delegacao:** @dev

**No metodo `_sbUpsertTask()`, garantir que os novos campos sao incluidos no upsert:**

```js
const payload = {
  // ... campos existentes ...
  recorrencia: task.recorrencia || 'nenhuma',
  dia_recorrencia: task.dia_recorrencia || null,
  recorrencia_ativa: task.recorrencia_ativa ?? true,
  recorrencia_origem_id: task.recorrencia_origem_id || null,
};
```

## Criterios de Aceite

- [ ] Task modal tem campo "Recorrencia" com opcoes: nenhuma/diaria/semanal/quinzenal/mensal
- [ ] Ao selecionar semanal/quinzenal, aparece seletor de dia da semana
- [ ] Ao selecionar mensal, aparece input de dia do mes
- [ ] Ao completar tarefa recorrente, nova instancia e criada automaticamente
- [ ] Nova instancia herda titulo, descricao, responsavel, prioridade, mentorado
- [ ] Badge visual "recorrente" aparece nos cards de tarefa
- [ ] Tarefa original fica como "concluida" no historico
- [ ] Se ja existe instancia futura pendente, nao cria duplicata
- [ ] `recorrencia_origem_id` vincula todas as instancias a tarefa mae

## Arquivos Modificados

| Arquivo | Modificacao |
|---------|------------|
| `XX-SQL-task-recurrence.sql` | Novo: ALTER TABLE com campos de recorrencia |
| `11-APP-app.js` | `_checkRecurringTasks()`, `_calcNextOccurrence()`, taskForm fields, _sbUpsertTask |
| `10-APP-index.html` | Campos de recorrencia no task modal, badge nos cards |
| `13-APP-styles.css` | `.task-recurring-badge` |

## Ordem de Execucao

1. @data-engineer → Rodar migracoes SQL no Supabase
2. @dev → Adicionar campos ao taskForm e _sbUpsertTask
3. @dev → Implementar _checkRecurringTasks() e _calcNextOccurrence()
4. @dev → UI do modal + badge visual
5. @dev → Testar ciclo completo: criar recorrente → completar → verificar nova instancia

## Riscos

- **Duplicatas:** Se `loadTasks()` roda multiplas vezes rapido, pode criar instancias duplicadas. Mitigacao: check de existencia antes de INSERT.
- **Fuso horario:** Datas calculadas com `new Date()` usam fuso local. Consistente com o resto do sistema que ja usa isso.
- **Volume:** Tarefas recorrentes geram acumulo no banco. Mitigacao: apenas a ultima instancia fica como `pendente`, as anteriores sao `concluida`.

---
