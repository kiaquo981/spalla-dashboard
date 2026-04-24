---
title: "EPIC CU-02: ClickUp Deep — Full Interactive Task Management"
type: epic
status: backlog
priority: P0
created: 2026-04-07
owner: kaique
---

# EPIC CU-02: ClickUp Deep — Full Interactive Task Management

## Visao
Transformar o Gerenciamento de Tarefas do Spalla em uma experiencia equivalente ao ClickUp: cada celula editavel, custom fields dinamicos, task detail drawer completo, views plugaveis, sidebar hierarquica.

## Referencia Visual (screenshots ClickUp 2026-04-07)
- Task detail: status badge, datas, prioridade, pontos, etiquetas, descricao markdown, custom fields, subtasks com assignee, dependencias, checklists com progress, activity feed com comentarios
- List view: agrupamento por data relativa (Em atraso, Amanha, Quarta, Futuro), colunas Sprints/Responsavel/Data/Prioridade + toggle show/hide
- Custom fields: 30+ tipos (texto, dropdown, data, numero, checkbox, formula, progresso, avaliacao, relacao, etc.)
- Views: Lista, Kanban, Calendario, Tabela, Gantt, Paineis, Atividade, Carga de trabalho
- Sidebar: hierarquia Space > Folder > List > Sprint com counts e CRUD inline

## Schema JA EXISTENTE (pronto pra usar)
- `god_task_field_defs` — definicoes de custom fields (10 tipos, scoped por space/list)
- `god_task_field_values` — valores por task (JSONB flexivel)
- `get_task_fields()` — function que retorna fields aplicaveis + valores
- `god_spaces` + `god_lists` — hierarquia de spaces com sprints
- `god_statuses` — statuses customizaveis por space
- `god_task_comments` + `god_task_handoffs` + `god_task_activity` — atividade
- `god_task_subtasks` + `god_task_checklist` — subtasks e checklists

## Stories

### CU-02.1 — Task Detail Drawer Rebuild
**Prioridade:** P0
**Escopo:**
- Drawer lateral com todas as secoes do ClickUp:
  - Header: titulo editavel inline, status badge clicavel (dropdown)
  - Properties grid: Datas (inicio+fim), Responsaveis, Prioridade, Pontos, Estimativa, Etiquetas
  - Descricao com markdown editor
  - Custom Fields section (renderiza `get_task_fields()`)
  - Subtasks com expand, assignee, status
  - Checklists com progress bar
  - Dependencias (vincular tasks)
  - Activity feed (comments + historico de mudancas)
  - Comment box com mention (@)
**AC:**
- [ ] Cada property editavel inline (click-to-edit)
- [ ] Custom fields renderizados pelo tipo (text, select, date, number, checkbox)
- [ ] Subtasks com assignee + status editaveis
- [ ] Comments com thread + timestamp + avatar

### CU-02.2 — List View: Agrupamento por Data + Colunas Dinamicas
**Prioridade:** P0
**Escopo:**
- Agrupar por data relativa: "Em atraso", "Hoje", "Amanha", dia da semana, "Futuro", "Sem data"
- Colunas dinamicas baseadas em `god_task_field_defs`
- Column visibility toggle (show/hide com toggle on/off)
- Column reorder (drag)
- "+ Adicionar campo" no header (abre modal de custom fields)
**AC:**
- [ ] GroupBy 'date' funciona com labels relativas
- [ ] Colunas podem ser adicionadas/removidas via toggle
- [ ] Custom fields aparecem como colunas extras
- [ ] Inline edit em TODAS as colunas

### CU-02.3 — Custom Fields Engine (UI)
**Prioridade:** P0
**Escopo:**
- Modal "Campos" com:
  - Tab "Criar novo": lista de tipos (texto, dropdown, data, numero, checkbox, progresso, avaliacao, formula, relacao, etc.)
  - Tab "Adicionar existente": campos ja criados com toggle show/hide
- Renderizacao de cada tipo na list/board view
- Sugerir campos: "Objetivo do Sprint", "Tarefas Pendentes", "Feedback do Cliente", "Data de Revisao"
**Depende:** Schema ja existe (`god_task_field_defs` + `god_task_field_values`)
**AC:**
- [ ] Modal com 2 tabs (Criar novo / Adicionar existente)
- [ ] Pelo menos 10 tipos de campo implementados
- [ ] Campos aparecem no task detail drawer
- [ ] Campos aparecem como colunas na list view

### CU-02.4 — View System (plugavel)
**Prioridade:** P1
**Escopo:**
- "+ Visualizacao" dropdown com opcoes: Lista, Kanban, Calendario, Tabela, Gantt
- Cada view e um tab (como ClickUp mostra "list-dossiers" + "+ Visualizacao")
- Saved views: salvar configuracao de filtros + colunas visiveis + groupBy por view
- Tab bar: views salvas como tabs clicaveis
**AC:**
- [ ] Dropdown de views disponíveis
- [ ] Criar nova view com nome + tipo
- [ ] Cada view persiste seus filtros e colunas
- [ ] Tabs de views salvas

### CU-02.5 — Sidebar v2: Hierarchy + CRUD
**Prioridade:** P1
**Escopo:**
- Breadcrumb: Space > Folder > List
- CRUD inline: criar space, criar folder, criar list, renomear, deletar
- Sprint folder com sprints numerados e CRUD
- "+ Novo Espaco" no bottom
- Collapse/expand por space
- Drag-reorder de spaces e lists
**AC:**
- [ ] Breadcrumb funcional
- [ ] Criar/renomear/deletar space e list
- [ ] Sprint folder com CRUD de sprints
- [ ] Drag-reorder

### CU-02.6 — Gantt com Dependencias
**Prioridade:** P2
**Escopo:**
- Gantt chart real com barras por task
- Setas de dependencia entre tasks (blocking/blocked)
- Drag-to-resize (mudar datas)
- Drag-to-link (criar dependencia)
**AC:**
- [ ] Barras renderizadas por data_inicio/data_fim
- [ ] Setas de dependencia visiveis
- [ ] Drag interativo

## Ordem de Execucao
1. CU-02.1 (Task Detail) — base pra tudo, toda interacao passa por aqui
2. CU-02.3 (Custom Fields UI) — precisa existir antes de CU-02.2
3. CU-02.2 (List View dynamica) — depende de custom fields
4. CU-02.4 (View System) — depende de list/board/calendar funcionarem bem
5. CU-02.5 (Sidebar v2) — pode ser paralelo
6. CU-02.6 (Gantt) — ultimo, mais complexo

## Estimativa
- Total: ~6-8 semanas de trabalho focado
- Cada story: 1-2 sessoes de implementacao + QA visual

## Regras
- 1 PR por story
- QA visual ANTES de merge (screenshot de antes/depois)
- Inline styles proibidos — usar CSS classes `cu-*`
- Usar schema existente antes de criar tabelas novas
- Testar mobile responsive
