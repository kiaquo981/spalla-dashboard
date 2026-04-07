---
title: "Deep Research: ClickUp Internalization into Spalla Dashboard"
type: research
status: complete
date: 2026-04-06
author: Atlas (AIOX Analyst)
confidence: HIGH (85-90%) — based on official docs, GitHub repos, and verified API specs
---

# ClickUp White-Label Internalization — Deep Research

## 1. Executive Summary

Spalla Dashboard currently uses ClickUp externally (355 tasks, sprints, spaces: Entregas/Atendimento/Mentorado/Produto). This research maps the full ClickUp feature surface, benchmarks open-source alternatives, documents API capabilities/limits, and proposes a phased architecture for internalizing project management into Spalla.

**Key findings:**

- ClickUp has 15+ view types, but Spalla's mentorship context only needs 5-6 (Kanban, List, Table, Calendar, Gantt, Activity)
- The ClickUp API covers ~80% of task CRUD but cannot access Dashboards, Whiteboards, Docs content, or Automations programmatically
- **Plane.so** (47.4K stars, React+Django+PostgreSQL) is the strongest reference architecture for reusable patterns
- **Huly** (25.3K stars, Svelte+TypeScript) offers the most complete all-in-one feature set but uses MongoDB (incompatible with Supabase)
- A hybrid approach is recommended: build core views in Alpine.js + Supabase, keep ClickUp sync for sprint analytics during transition, then deprecate ClickUp entirely in Phase 3
- Estimated 12-16 weeks for MVP (Kanban + List + Sprints), 6-9 months for full replacement

**Strategic recommendation:** Build the internalization in 3 phases. Phase 1 replaces 80% of daily ClickUp usage with Kanban + List views. The Supabase real-time stack already in production eliminates the need for additional infrastructure.

---

## 2. ClickUp Feature Matrix

### 2.1 All View Types (15+)

| View | Description | Data Rendering | Filter/Sort/Group | Complexity | Priority for Spalla |
|------|-------------|---------------|-------------------|------------|-------------------|
| **List** | Default view, most flexible. Groups by status/priority/assignee. Inline editing. | Rows with configurable columns | All: status, assignee, priority, dates, tags, custom fields | LOW | P0 — MUST HAVE |
| **Board (Kanban)** | Cards organized in columns by status. Drag-and-drop. | Cards in columns | Group by status/priority/assignee. Filter by all fields | LOW-MED | P0 — MUST HAVE |
| **Table** | Spreadsheet-like, shows all custom fields as columns. | Grid with editable cells | Full sorting per column, multi-field filters | MED | P1 — SHOULD HAVE |
| **Calendar** | Tasks on calendar by due date. Drag to reschedule. | Date grid (day/week/month) | Filter by assignee, status, tags | MED | P1 — SHOULD HAVE |
| **Gantt** | Timeline with dependencies, milestones, critical path. | Horizontal bars with arrows | Filter by list/folder, group by assignee | HIGH | P2 — NICE TO HAVE |
| **Timeline** | Linear schedule visualization. | Horizontal timeline | Flexible grouping | HIGH | P3 — DEFER |
| **Team/Workload** | Capacity per team member. Points/hours allocated. | User rows with capacity bars | Filter by team, date range | HIGH | P2 — NICE TO HAVE |
| **Map** | Geographic task visualization via Location field. | Map pins | Filter by location field | MED | P4 — NOT NEEDED |
| **Form** | Public forms that create tasks on submission. | Form fields | N/A | LOW | P1 — SHOULD HAVE (intake) |
| **Activity** | Feed of all changes, comments, status transitions. | Reverse-chronological feed | Filter by type of activity | LOW | P1 — SHOULD HAVE |
| **Mind Map** | Visual outline for brainstorming. Converts to tasks. | Tree/node structure | N/A | HIGH | P4 — NOT NEEDED |
| **Whiteboard** | Collaborative canvas, flow charts, brainstorming. | Freeform canvas | N/A | VERY HIGH | P4 — NOT NEEDED |
| **Doc** | Wiki-style documentation within workspace. | Rich text editor | N/A | HIGH | P3 — DEFER (Spalla has own docs) |
| **Dashboard** | Widget-based analytics: charts, burndown, velocity. | Cards/widgets with data | Configurable per widget | HIGH | P2 — NICE TO HAVE |
| **Chat** | Team communication within context. | Chat messages | N/A | HIGH | P4 — NOT NEEDED (WhatsApp exists) |
| **Embed** | Embed external content (Figma, Loom, etc.). | iFrame | N/A | LOW | P3 — DEFER |

### 2.2 Card Anatomy (Task Card on Board View)

A ClickUp task card displays:

| Element | Description | Required for Spalla? |
|---------|-------------|---------------------|
| Task name | Title text, clickable to open | YES |
| Status | Color-coded badge (e.g., "Em Andamento", "Concluido") | YES |
| Priority | Flag icon (Urgent/High/Normal/Low/None) | YES |
| Assignee(s) | Avatar(s) of assigned users | YES |
| Due date | Date display, overdue turns red | YES |
| Tags | Color-coded labels | YES |
| Custom fields | Type-specific display (dropdown, number, checkbox) | YES (select fields) |
| Subtask count | "3/5 subtasks" indicator | YES |
| Checklist progress | Progress bar for checklists | YES |
| Comment count | Comment icon with count | YES |
| Time tracked | Duration display | NICE TO HAVE |
| Attachments | Paperclip icon with count | NICE TO HAVE |
| Cover image | Optional header image | NO |
| Dependency indicator | Arrow icon if blocked/blocking | NICE TO HAVE |

### 2.3 Status Workflow System

ClickUp statuses work as follows:

- **Status groups**: Active (color-coded), Done (green), Closed (gray)
- **Per-Space customization**: Each Space defines its own status set
- **Color coding**: Fully customizable per status (hex color)
- **Transitions**: No enforced transition rules in standard plans (any status to any status). Business+ plans support automations to enforce transitions.
- **WIP limits**: Not native. Must be implemented via automations or custom solutions.
- **Default statuses**: "To Do", "In Progress", "Complete" — fully editable

**For Spalla**: Status workflow maps directly to mentorship pipeline stages (e.g., Briefing -> Em Andamento -> Revisao -> Entregue -> Validado).

### 2.4 Sprint Mechanics

| Feature | How It Works in ClickUp |
|---------|------------------------|
| Sprint creation | Manual or auto-recurring. Sprint = a List with date range. |
| Points estimation | Configurable point system. Subtask points roll up. |
| AI estimation | ClickUp AI suggests points based on description/history |
| Velocity tracking | Dashboard card comparing committed vs completed over 3-10 sprints |
| Burndown chart | Task/points remaining vs ideal line over sprint duration |
| Burnup chart | Work completed + scope changes visualized |
| Unfinished work | Auto-moves to next sprint on sprint close |
| Capacity planning | Drag tasks into sprint while monitoring total points vs velocity |
| Sprint folder | Sprints live as Lists within a Folder structure |

### 2.5 Custom Fields System

| Field Type | API type_name | Values | Spalla Priority |
|-----------|---------------|--------|----------------|
| Short Text | `short_text` | Single line string | P0 |
| Text (Long) | `text` | Paragraph | P0 |
| Number | `number` | Numeric value | P0 |
| Currency | `currency` | Numeric with currency symbol | P1 |
| Dropdown | `drop_down` | Single select from options (max 500) | P0 |
| Labels | `labels` | Multi-select from options (max 500) | P0 |
| Checkbox | `checkbox` | Boolean true/false | P0 |
| Date | `date` | Unix timestamp ms + optional time | P0 |
| Email | `email` | Email string | P1 |
| Phone | `phone` | Phone + country code | P1 |
| URL | `url` | URL string | P1 |
| Emoji/Rating | `emoji` | Integer 0 to N | P1 |
| Users/People | `users` | User ID references | P0 |
| Tasks/Relationship | `tasks` | Task ID references (cross-list linking) | P1 |
| Location | `location` | Lat/lng + formatted address | P4 |
| Formula | `formula` | Computed from other fields (number/date only) | P2 |
| Manual Progress | `manual_progress` | 0-100 percentage | P1 |
| Auto Progress | `automatic_progress` | Computed from subtasks (read-only) | P1 |
| Files | `attachment` | File references | P2 |

**Limitation**: Free plan allows only 60 custom field uses across entire workspace. Voting fields cannot be set via API.

### 2.6 Automations Engine

ClickUp automations follow a Trigger -> Condition -> Action pattern:

**Triggers** (events that start automation):
- Status changes, Assignee changes, Priority changes
- Due date arrives, Task created, Task moved
- Custom field changes, Checklist completed
- Comment posted, Time tracked

**Conditions** (filters that gate the action):
- Status equals/not equals
- Priority is/is not
- Assignee is/is not
- Custom field value matches
- Tag contains/doesn't contain

**Actions** (what happens):
- Change status, Change assignee, Change priority
- Add/remove tag, Set custom field value
- Create task, Move task, Archive task
- Post comment, Send email/webhook
- Apply template

**Limits by plan**: Free=0, Unlimited=100/month, Business=250/month, Business+=500/month, Enterprise=custom.

### 2.7 Additional Features

| Feature | Description | Complexity |
|---------|-------------|-----------|
| Sidebar navigation | Spaces -> Folders -> Lists (3-level hierarchy) | MED |
| Bulk actions | Select multiple tasks, batch update status/assignee/etc | LOW |
| Drag-and-drop | Board cards, Gantt bars, Calendar events, List reordering | MED |
| Inline editing | Click any field in List/Table view to edit in place | LOW |
| Search | Global search across all tasks, filtered by space/list | MED |
| Saved filters | Persist filter combinations as named views | LOW |
| Quick filters | One-click filters at view level (Me, Overdue, etc) | LOW |
| Notifications | Bell icon, unread count, mention alerts | MED |
| Activity feed | Per-task and per-workspace activity log | LOW |
| Templates | Task templates, list templates, space templates | MED |
| Time tracking | Start/stop timer, manual entry, reports | MED-HIGH |
| Recurring tasks | Auto-create on schedule (daily/weekly/monthly/custom) | MED |
| Dependencies | Wait on / Blocking relationships between tasks | MED |
| Goals & OKRs | Goal tracking with targets, rollup from tasks | HIGH |

---

## 3. Open Source Benchmarks

### 3.1 Comparison Table

| Tool | GitHub Stars | License | Frontend | Backend | Database | Views Implemented | Self-Host | Active? | Relevance for Spalla |
|------|-------------|---------|----------|---------|----------|-------------------|-----------|---------|---------------------|
| **Plane.so** | 47.4K | AGPL-3.0 | React + TypeScript (Vite) | Django (Python) | PostgreSQL + Redis | Board, List, Gantt, Calendar, Cycles (sprints), Modules | Docker/K8s | Very active (100+ contributors) | **HIGH — same DB, closest feature match** |
| **Huly** | 25.3K | EPL-2.0 | Svelte + TypeScript | Node.js (Rush monorepo) | MongoDB + ElasticSearch + MinIO | Kanban, Gantt, Sprint boards, Planner, Calendar | Docker Compose | Very active (345+ releases) | **MED — great features, wrong DB** |
| **Focalboard** | 25.6K | MIT/AGPL | React + TypeScript | Go | PostgreSQL/SQLite | Board, Table, Gallery, Calendar | Docker | **DEPRECATED** (no updates since Sep 2023) | **LOW — dead project** |
| **Taiga** | ~5K (new repo) | AGPL-3.0 | Angular + CoffeeScript (rewriting) | Django (Python) | PostgreSQL | Scrum board, Kanban, Backlog, Burndown, Issues, Wiki | Docker | Active (rewrite in progress) | **MED — good agile patterns, aging frontend** |
| **Leantime** | 9.4K | AGPL-3.0 | PHP + jQuery/JS | PHP (Laravel-like) | MySQL/MariaDB | Kanban, Gantt, Table, List, Calendar, Lean Canvas | Docker | Active (v3.7.3 Mar 2026) | **LOW — PHP stack mismatch** |
| **Vikunja** | ~5K | AGPL-3.0 | Vue 3 + TypeScript | Go | PostgreSQL/MySQL/SQLite | List, Kanban, Gantt, Table | Docker | Active | **MED — lightweight, Go backend** |
| **OpenProject** | ~10K | GPL-3.0 | Angular + TypeScript | Ruby on Rails | PostgreSQL | Gantt, Kanban, Calendar, Team planner, Time tracking | Docker/DEB/RPM | Very active | **MED — enterprise grade, heavy** |
| **AppFlowy** | 60K+ | AGPL-3.0 | Flutter (Rust core) | Rust | — | Board, Grid, Calendar | Docker | Very active | **LOW — Notion alternative, not PM** |

### 3.2 What's Reusable from Each

**Plane.so** (BEST reference):
- PostgreSQL schema design for issues, cycles (sprints), modules, views, labels, states
- Django API patterns (translatable to Flask)
- React component architecture for Board/List/Gantt (study UI patterns, implement in Alpine.js)
- Cycle management (sprint start/end, burndown logic, carry-over)
- Workspace -> Project -> Module -> Issue hierarchy (maps to Spalla's Space -> Folder -> List -> Task)
- Custom properties system (their "issue properties" = ClickUp custom fields)
- Source: [github.com/makeplane/plane](https://github.com/makeplane/plane)

**Huly** (study for UX patterns):
- Svelte component patterns for real-time collaboration
- Card-based Meta Framework (typed, relational objects with schema flexibility)
- Sprint board + planner UX (keyboard-driven, Linear-style)
- Bidirectional GitHub sync pattern
- Source: [github.com/hcengineering/platform](https://github.com/hcengineering/platform)

**Taiga** (study for agile workflows):
- Scrum board with proper burndown/velocity calculations
- Backlog management and sprint planning flow
- Issue triage workflow
- Source: [github.com/kaleidos-ventures/taiga](https://github.com/kaleidos-ventures/taiga)

---

## 4. ClickUp API Capabilities & Limits

### 4.1 API Endpoint Coverage

| Resource | Create | Read | Update | Delete | Notes |
|----------|--------|------|--------|--------|-------|
| **Tasks** | YES | YES (paginated, 100/page) | YES | YES | Full CRUD. Filtered queries. |
| **Subtasks** | YES | YES (nested in task) | YES | YES | Via task endpoint with parent param |
| **Lists** | YES | YES | YES | YES | — |
| **Folders** | YES | YES | YES | YES | — |
| **Spaces** | YES | YES | YES | YES | — |
| **Teams/Workspaces** | NO | YES | NO | NO | Read-only |
| **Custom Fields** | NO (create via UI) | YES | YES (set values) | NO | Can set values on tasks, cannot create field definitions |
| **Views** | YES | YES | YES | YES | Task views only. Page views (Docs, Whiteboards) NOT supported. |
| **Comments** | YES | YES | YES | YES | Plain text and rich text |
| **Checklists** | YES | YES | YES | YES | Items within checklists |
| **Tags** | YES | YES | YES | YES | Per-space tags |
| **Members** | NO | YES | NO | NO | Read-only |
| **Guests** | YES | YES | YES | YES | Guest management |
| **Goals** | YES | YES | YES | YES | Including key results |
| **Time Tracking** | YES | YES | YES | YES | Time entries per task |
| **Webhooks** | YES | YES | YES | YES | 30+ event types |
| **Templates** | NO | YES | NO | NO | Read-only, cannot create |
| **Docs** | YES (limited) | YES (limited) | YES (limited) | YES | Cannot link to tasks, limited access control, no content search |
| **Dashboards** | NO | NO | NO | NO | **NOT available via API** |
| **Whiteboards** | NO | NO | NO | NO | **NOT available via API** |
| **Automations** | NO | NO | NO | NO | **NOT available via API** |

### 4.2 Rate Limits

| Plan | Limit | Reset |
|------|-------|-------|
| Free / Unlimited / Business | 100 req/min/token | Rolling window |
| Business Plus | 1,000 req/min/token | Rolling window |
| Enterprise | 10,000 req/min/token | Rolling window |

Headers returned: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`.
HTTP 429 on exceeded.

### 4.3 Webhook Events (30+ types)

**Task events (13)**: taskCreated, taskUpdated, taskDeleted, taskPriorityUpdated, taskStatusUpdated, taskAssigneeUpdated, taskDueDateUpdated, taskTagUpdated, taskMoved, taskCommentPosted, taskCommentUpdated, taskTimeEstimateUpdated, taskTimeTrackedUpdated

**List events (3)**: listCreated, listUpdated, listDeleted

**Folder events (3)**: folderCreated, folderUpdated, folderDeleted

**Space events (3)**: spaceCreated, spaceUpdated, spaceDeleted

**Goal events (6)**: goalCreated, goalUpdated, goalDeleted, keyResultCreated, keyResultUpdated, keyResultDeleted

Payloads include `before` and `after` state. Webhook signature validation via shared secret.

### 4.4 What CANNOT Be Synced

1. **Dashboards** — No API access at all
2. **Whiteboards** — No API access at all
3. **Automations** — No API access (cannot read, create, or trigger)
4. **Doc-Task linking** — Cannot associate Docs with Tasks via API
5. **Doc access control** — Only public/private, cannot set per-user access
6. **Doc search** — Cannot search content within Docs
7. **Custom field definitions** — Cannot create new field types via API (only set values)
8. **Template creation** — Read-only access to templates
9. **Voting field values** — Cannot be set via API
10. **Sprint velocity/burndown data** — No dedicated endpoint (must compute from task data)

### 4.5 Bidirectional Sync Assessment

| Data | ClickUp -> Spalla | Spalla -> ClickUp | Feasibility |
|------|-------------------|-------------------|-------------|
| Tasks (CRUD) | Via API polling or webhooks | Via API | HIGH |
| Statuses | Via webhook (taskStatusUpdated) | Via API (update task) | HIGH |
| Custom fields | Via API (get task with custom_fields) | Via API (set custom field value) | HIGH (values only) |
| Comments | Via webhook + API | Via API | HIGH |
| Time tracking | Via webhook + API | Via API | HIGH |
| Sprint membership | Via API (tasks in list) | Via API (move task) | MED |
| Views | Via API | Via API | MED (task views only) |
| Automations | NOT POSSIBLE | NOT POSSIBLE | NONE |
| Dashboards | NOT POSSIBLE | NOT POSSIBLE | NONE |

---

## 5. Recommended Architecture

### 5.1 Stack Decision

Given Spalla's current stack (HTML + Alpine.js + Flask + Supabase), the recommendation is:

| Layer | Choice | Rationale |
|-------|--------|-----------|
| **Frontend** | Alpine.js + SortableJS + HTMX | Alpine.js is already in production. SortableJS has official Alpine plugin for drag-drop. HTMX for partial page updates without SPA complexity. |
| **Backend** | Flask (Python) | Already in production. Add blueprints for task management endpoints. |
| **Database** | Supabase (PostgreSQL) | Already in production. Real-time subscriptions for live updates. RLS for multi-user access control. |
| **Real-time** | Supabase Realtime | Built-in. Subscribe to task changes, status updates. No additional infra. |
| **Drag-and-drop** | Alpine.js Sort plugin (SortableJS) | Official Alpine plugin. Lightweight. Touch-friendly. |
| **Charts** | Chart.js or Frappe Charts | Burndown, velocity, activity charts. Lightweight, no-dependency. |
| **Calendar** | FullCalendar (vanilla JS) | Mature library, drag-drop scheduling, works without framework. |

**Why NOT adopt Plane.so or Huly directly:**
- Plane requires React + Django (complete frontend rewrite of Spalla)
- Huly requires Svelte + MongoDB (incompatible database)
- Both are overkill for Spalla's focused mentorship context
- Building on existing stack is 3-5x faster than migrating to new framework

**What TO study from Plane.so:**
- PostgreSQL schema design (issues, states, cycles, modules, labels)
- Sprint/cycle calculation logic (burndown, velocity formulas)
- Custom properties data model (JSONB-based flexibility)
- Workspace permission model

### 5.2 Database Schema Recommendation

```sql
-- ============================================
-- CORE: Spaces, Folders, Lists (3-level hierarchy)
-- ============================================

CREATE TABLE pm_spaces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL, -- links to existing Spalla workspace
    name TEXT NOT NULL,
    slug TEXT NOT NULL,
    icon TEXT,
    color TEXT, -- hex color
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    created_by UUID REFERENCES auth.users(id),
    UNIQUE(workspace_id, slug)
);

CREATE TABLE pm_folders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id UUID NOT NULL REFERENCES pm_spaces(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE pm_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    folder_id UUID REFERENCES pm_folders(id) ON DELETE CASCADE, -- NULL = folderless list
    space_id UUID NOT NULL REFERENCES pm_spaces(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    is_sprint BOOLEAN DEFAULT FALSE,
    sprint_start DATE,
    sprint_end DATE,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- STATUSES: Per-Space status definitions
-- ============================================

CREATE TABLE pm_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id UUID NOT NULL REFERENCES pm_spaces(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    color TEXT NOT NULL DEFAULT '#808080',
    status_group TEXT NOT NULL CHECK (status_group IN ('active', 'done', 'closed')),
    sort_order INTEGER DEFAULT 0,
    UNIQUE(space_id, name)
);

-- ============================================
-- TASKS: Core task entity
-- ============================================

CREATE TABLE pm_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    list_id UUID NOT NULL REFERENCES pm_lists(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES pm_tasks(id), -- subtask support
    title TEXT NOT NULL,
    description TEXT, -- rich text / markdown
    status_id UUID NOT NULL REFERENCES pm_statuses(id),
    priority TEXT CHECK (priority IN ('urgent', 'high', 'normal', 'low', 'none')) DEFAULT 'none',
    sort_order FLOAT DEFAULT 0, -- float for insertion between items
    due_date TIMESTAMPTZ,
    start_date TIMESTAMPTZ,
    time_estimate INTEGER, -- minutes
    points INTEGER, -- sprint points
    is_archived BOOLEAN DEFAULT FALSE,
    custom_fields JSONB DEFAULT '{}', -- flexible custom field values
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    created_by UUID REFERENCES auth.users(id)
);

-- ============================================
-- TASK ASSIGNMENTS: Many-to-many
-- ============================================

CREATE TABLE pm_task_assignees (
    task_id UUID NOT NULL REFERENCES pm_tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id),
    assigned_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (task_id, user_id)
);

-- ============================================
-- TAGS: Per-Space tags
-- ============================================

CREATE TABLE pm_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id UUID NOT NULL REFERENCES pm_spaces(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    color TEXT DEFAULT '#808080',
    UNIQUE(space_id, name)
);

CREATE TABLE pm_task_tags (
    task_id UUID NOT NULL REFERENCES pm_tasks(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES pm_tags(id) ON DELETE CASCADE,
    PRIMARY KEY (task_id, tag_id)
);

-- ============================================
-- CUSTOM FIELD DEFINITIONS: Per-Space
-- ============================================

CREATE TABLE pm_custom_field_defs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id UUID NOT NULL REFERENCES pm_spaces(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    field_type TEXT NOT NULL CHECK (field_type IN (
        'text', 'number', 'dropdown', 'labels', 'checkbox',
        'date', 'url', 'email', 'phone', 'currency',
        'rating', 'progress', 'relationship', 'formula'
    )),
    config JSONB DEFAULT '{}', -- options for dropdown/labels, currency symbol, etc.
    sort_order INTEGER DEFAULT 0,
    is_required BOOLEAN DEFAULT FALSE,
    UNIQUE(space_id, name)
);

-- ============================================
-- COMMENTS & ACTIVITY
-- ============================================

CREATE TABLE pm_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES pm_tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE pm_activity_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID REFERENCES pm_tasks(id) ON DELETE CASCADE,
    list_id UUID REFERENCES pm_lists(id),
    space_id UUID REFERENCES pm_spaces(id),
    user_id UUID REFERENCES auth.users(id),
    action TEXT NOT NULL, -- 'status_changed', 'assigned', 'comment_added', etc.
    field_name TEXT, -- which field changed
    old_value JSONB,
    new_value JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- CHECKLISTS: Within tasks
-- ============================================

CREATE TABLE pm_checklists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES pm_tasks(id) ON DELETE CASCADE,
    name TEXT NOT NULL DEFAULT 'Checklist',
    sort_order INTEGER DEFAULT 0
);

CREATE TABLE pm_checklist_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    checklist_id UUID NOT NULL REFERENCES pm_checklists(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    assignee_id UUID REFERENCES auth.users(id),
    sort_order INTEGER DEFAULT 0
);

-- ============================================
-- DEPENDENCIES: Between tasks
-- ============================================

CREATE TABLE pm_dependencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocking_task_id UUID NOT NULL REFERENCES pm_tasks(id) ON DELETE CASCADE,
    blocked_task_id UUID NOT NULL REFERENCES pm_tasks(id) ON DELETE CASCADE,
    UNIQUE(blocking_task_id, blocked_task_id)
);

-- ============================================
-- TIME TRACKING
-- ============================================

CREATE TABLE pm_time_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES pm_tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id),
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    duration_minutes INTEGER, -- computed or manual
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- SAVED VIEWS: Persisted filter/sort/group configs
-- ============================================

CREATE TABLE pm_saved_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id UUID REFERENCES pm_spaces(id) ON DELETE CASCADE,
    list_id UUID REFERENCES pm_lists(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    view_type TEXT NOT NULL CHECK (view_type IN ('list', 'board', 'table', 'calendar', 'gantt', 'activity')),
    config JSONB NOT NULL DEFAULT '{}', -- filters, sort, group, visible columns
    is_default BOOLEAN DEFAULT FALSE,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- INDEXES for performance
-- ============================================

CREATE INDEX idx_pm_tasks_list ON pm_tasks(list_id);
CREATE INDEX idx_pm_tasks_status ON pm_tasks(status_id);
CREATE INDEX idx_pm_tasks_parent ON pm_tasks(parent_id);
CREATE INDEX idx_pm_tasks_due_date ON pm_tasks(due_date);
CREATE INDEX idx_pm_tasks_priority ON pm_tasks(priority);
CREATE INDEX idx_pm_tasks_custom_fields ON pm_tasks USING GIN (custom_fields);
CREATE INDEX idx_pm_activity_task ON pm_activity_log(task_id);
CREATE INDEX idx_pm_activity_created ON pm_activity_log(created_at DESC);
CREATE INDEX idx_pm_comments_task ON pm_comments(task_id);
CREATE INDEX idx_pm_time_entries_task ON pm_time_entries(task_id);

-- ============================================
-- RLS POLICIES (Supabase)
-- ============================================

ALTER TABLE pm_spaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE pm_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE pm_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE pm_activity_log ENABLE ROW LEVEL SECURITY;

-- Example: Users can only see tasks in spaces they have access to
-- (Define pm_space_members table for granular access control)
```

### 5.3 Minimal Viable Internalization (Phase 1)

What replaces 80% of daily ClickUp usage:

1. **Kanban Board** — Drag-and-drop task cards between status columns (SortableJS + Alpine.js)
2. **List View** — Sortable/filterable table with inline editing
3. **Task Detail Modal** — Full task view with description, comments, checklists, activity
4. **Sprint Management** — Sprint lists with date range, point tracking, auto-carry-over
5. **Sidebar Navigation** — Spaces -> Folders -> Lists tree

### 5.4 Full Vision

| View | Implementation Approach | Estimated Effort |
|------|------------------------|-----------------|
| Kanban Board | Alpine.js + SortableJS + Supabase Realtime | 2-3 weeks |
| List View | Alpine.js table with sort/filter/group | 1-2 weeks |
| Table View | Spreadsheet-like grid (consider ag-Grid lite or custom) | 2-3 weeks |
| Calendar | FullCalendar.js integration | 1-2 weeks |
| Gantt | Frappe Gantt or custom SVG timeline | 3-4 weeks |
| Activity Feed | Supabase query on pm_activity_log | 1 week |
| Dashboard/Analytics | Chart.js widgets (burndown, velocity, workload) | 2-3 weeks |
| Form View | Alpine.js form builder -> task creation | 1-2 weeks |
| Sprint Management | Sprint CRUD + burndown calculation + velocity | 2-3 weeks |
| Automations | Rule engine: trigger -> condition -> action (database-driven) | 4-6 weeks |
| Search & Filters | Full-text search (Supabase pg_trgm) + saved filters | 1-2 weeks |
| Notifications | Supabase Realtime + in-app notification center | 1-2 weeks |

### 5.5 ClickUp Sync vs Full Replacement

| Approach | Pros | Cons | Recommendation |
|----------|------|------|---------------|
| **Keep ClickUp + sync** | Gradual migration, no data loss, team can use both | Double maintenance, sync complexity, API rate limits (100/min on current plan) | Phase 1-2 only |
| **Full replacement** | Single source of truth, no subscription cost, full control | Migration risk, feature gaps during transition, team retraining | Phase 3 (target) |
| **Hybrid permanent** | Best of both worlds | Perpetual complexity, double cost | NOT recommended |

**Recommendation**: Start with bidirectional sync (Phase 1-2), then cut over to Spalla-only (Phase 3) once feature parity is achieved for the mentorship use case.

---

## 6. Implementation Roadmap

### Phase 1: Foundation + Kanban (Weeks 1-6)

**Goal**: Replace daily board usage.

| Week | Deliverable |
|------|------------|
| 1 | Database migration: create all pm_* tables. Seed statuses from ClickUp spaces. |
| 2 | Flask API: task CRUD endpoints + Supabase RLS policies |
| 3 | Kanban board component: Alpine.js + SortableJS. Drag-and-drop status changes. |
| 4 | Task detail modal: description, comments, checklists, assignees |
| 5 | Sidebar navigation: Spaces -> Folders -> Lists tree. Quick filters. |
| 6 | ClickUp sync: Import existing 355 tasks via API. Set up webhook listener for bidirectional sync. |

**Exit criteria**: Team can manage daily tasks in Spalla Kanban. ClickUp stays synced as backup.

### Phase 2: Views + Sprints (Weeks 7-12)

**Goal**: Replace all ClickUp views used by CASE team.

| Week | Deliverable |
|------|------------|
| 7-8 | List view with sort/filter/group. Inline editing. |
| 9 | Table view (spreadsheet-style with custom field columns) |
| 10 | Sprint management: create sprint, assign tasks, point tracking |
| 11 | Calendar view (FullCalendar integration) + Activity feed |
| 12 | Dashboard: burndown chart, velocity card, workload summary |

**Exit criteria**: All 4 ClickUp views (Board/List/Calendar/Dashboard) replicated. Sprint workflow functional.

### Phase 3: Full Independence (Weeks 13-20)

**Goal**: Deprecate ClickUp entirely.

| Week | Deliverable |
|------|------------|
| 13-14 | Automation engine: trigger -> condition -> action (database-driven rules) |
| 15 | Form view: public intake forms that create tasks |
| 16 | Gantt view (stretch goal, use Frappe Gantt) |
| 17 | Search: full-text across tasks/comments + saved filter system |
| 18 | Notifications: in-app notification center + optional email/WhatsApp alerts |
| 19 | Migration tool: final ClickUp export -> Spalla import with relationship preservation |
| 20 | Team onboarding, ClickUp subscription cancellation |

**Exit criteria**: ClickUp subscription cancelled. All task management in Spalla.

---

## 7. Risks & Tradeoffs

### 7.1 Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| **Feature gap frustration** | HIGH | MED | Phase 1 ships Kanban first (most-used view). Sync keeps ClickUp available as fallback. |
| **Drag-and-drop performance** | MED | HIGH | SortableJS is proven at scale. Optimistic UI updates (update UI immediately, sync to DB async). |
| **Real-time sync conflicts** | MED | MED | Supabase Realtime handles multi-user. Use `updated_at` for conflict resolution. Last-write-wins with activity log. |
| **ClickUp API rate limits** | MED | LOW | 100 req/min is sufficient for 355 tasks. Batch imports during off-hours. Webhook-driven sync (push, not poll). |
| **Team adoption resistance** | MED | HIGH | Ship features incrementally. Don't force full migration until Phase 2 complete. |
| **Custom field complexity** | LOW | MED | JSONB in PostgreSQL handles arbitrary field types. Schema validated at application layer. |
| **Sprint calculation accuracy** | LOW | MED | Study Plane.so's cycle calculation logic. Test with historical sprint data. |

### 7.2 Tradeoffs

| Decision | Tradeoff | Justification |
|----------|----------|---------------|
| Alpine.js over React | Less component ecosystem, no SSR | Already in production. Migration to React = 3-6 month detour. Alpine + HTMX covers all PM views. |
| JSONB for custom fields over normalized tables | Harder to query/index individual fields | Flexibility outweighs query complexity for <1000 tasks. GIN index covers common queries. |
| SortableJS over native HTML5 DnD | External dependency | Native DnD is unreliable on mobile. SortableJS has official Alpine plugin and touch support. |
| Supabase Realtime over WebSockets | Tied to Supabase platform | Already paying for Supabase. Eliminates need for separate WS server. Built-in auth integration. |
| Build custom over adopt Plane.so | More development effort | Plane requires React + Django migration. Building on existing stack is faster for focused use case. |
| ClickUp sync during transition over cold turkey | Double maintenance for 2-3 months | Reduces migration risk. Team has fallback. Historical data preserved. |

### 7.3 Cost Analysis

| Item | Current (ClickUp) | After Internalization |
|------|-------------------|----------------------|
| ClickUp subscription | ~$10-19/user/month | $0 |
| Development effort | $0 | 12-20 weeks of dev time |
| Supabase (already paid) | $25/month | $25/month (no change) |
| Maintenance | ClickUp manages | Team manages (Flask + Supabase) |
| Customization | Limited by ClickUp features | Unlimited — own code |

For a team of 5-10 users at ~$12/user/month, ClickUp costs $60-120/month ($720-1,440/year). The internalization pays for itself in developer freedom and mentorship-specific customization that ClickUp cannot provide.

---

## Sources

- [ClickUp Views Overview](https://clickup.com/features/views)
- [ClickUp API Rate Limits](https://developer.clickup.com/docs/rate-limits)
- [ClickUp API Webhooks](https://developer.clickup.com/docs/webhooks)
- [ClickUp Custom Fields Documentation](https://developer.clickup.com/docs/customfields)
- [ClickUp Sprint Points](https://help.clickup.com/hc/en-us/articles/6303883602327-Use-Sprint-Points)
- [ClickUp Automations](https://help.clickup.com/hc/en-us/articles/6312102752791-Intro-to-Automations)
- [ClickUp API Getting Started](https://developer.clickup.com/docs/Getting%20Started)
- [Plane.so GitHub](https://github.com/makeplane/plane) — 47.4K stars, AGPL-3.0
- [Huly GitHub](https://github.com/hcengineering/platform) — 25.3K stars, EPL-2.0
- [Focalboard GitHub](https://github.com/mattermost-community/focalboard) — 25.6K stars, deprecated
- [Taiga GitHub](https://github.com/kaleidos-ventures/taiga) — AGPL-3.0, rewriting
- [Leantime GitHub](https://github.com/Leantime/leantime) — 9.4K stars, AGPL-3.0
- [Alpine.js Sort Plugin (SortableJS)](https://alpinejs.dev/plugins/sort)
- [ClickUp API Custom Fields Reference](https://developer.clickup.com/docs/customfields)
- [ClickUp 4.0 Review 2026](https://www.morgen.so/blog-posts/clickup-review)
- [ClickUp API Comprehensive Guide — Zuplo](https://zuplo.com/learning-center/clickup-api)
- [Plane.so Open Source PM 2026](https://plane.so/blog/top-6-open-source-project-management-software-in-2026)
- [Huly Self-Hosting Docs](https://docs.huly.io/getting-started/self-host/)
