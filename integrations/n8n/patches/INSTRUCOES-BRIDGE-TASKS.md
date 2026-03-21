# Bridge Tasks: Instruções de Aplicação

## Contexto

As functions `bridge_create_task` e `bridge_auto_check_task` já existem no Supabase.
Precisamos atualizar 2 nodes existentes e adicionar 2 nodes novos no Scraper v34.

Todos os nodes usam **Postgres executeQuery** com credencial `Postgres | case` — sem HTTP Request, sem env vars.

---

## PARTE 1: Modificar Nodes Existentes (manual no N8N)

### Node: "Salvar Compromissos"

**Localização:** Canvas posição [1040, 5296] — é um Supabase node
**Tipo atual:** `n8n-nodes-base.supabase` (INSERT em `tarefas_acordadas`)

**Ação:** Trocar por Postgres node que chama `bridge_create_task` via query

1. Deletar o node "Salvar Compromissos"
2. Adicionar **Postgres** node no mesmo lugar
3. Renomear para "Salvar Compromissos"
4. Selecionar credencial: `Postgres | case`
5. Operation: `Execute Query`
6. Query:

```sql
SELECT bridge_create_task(
  {{ $json.mentorado_id }}::bigint,
  '{{ ($json.compromisso || '').replace(/'/g, "''") }}'::text,
  '{{ ($json.contexto || '').replace(/'/g, "''") }}'::text,
  '{{ $json.sender_name || 'mentorado' }}'::text,
  'normal'::text,
  {{ $json.prazo_inferido ? "'" + $json.prazo_inferido + "'" : 'NULL' }}::date,
  'whatsapp_compromisso'::text,
  {{ $json.interacao_id || 'NULL' }}::bigint,
  {{ $json.confianca || 0.7 }}::numeric
);
```

7. Reconectar as setas (mesmas entradas/saídas de antes)

---

### Node: "Criar Tarefa Material"

**Localização:** Canvas posição [1328, 3088] — é um Supabase node
**Tipo atual:** `n8n-nodes-base.supabase` (INSERT em `tarefas_acordadas`)

**Ação:** Mesma coisa — trocar por Postgres executeQuery

1. Deletar o node "Criar Tarefa Material"
2. Adicionar **Postgres** node no mesmo lugar
3. Renomear para "Criar Tarefa Material"
4. Credencial: `Postgres | case`
5. Operation: `Execute Query`
6. Query:

```sql
SELECT bridge_create_task(
  {{ $json.mentorado_id }}::bigint,
  'Enviar material solicitado'::text,
  '{{ ($json.resumo || ($json.conteudo || '').substring(0, 300)).replace(/'/g, "''") }}'::text,
  '{{ $json.responsavel_detectado || 'Equipe' }}'::text,
  'alta'::text,
  '{{ $now.plus({days: 2}).toFormat("yyyy-MM-dd") }}'::date,
  'whatsapp_material'::text,
  {{ $json.interacao_id || 'NULL' }}::bigint,
  0.9::numeric
);
```

7. Reconectar setas

---

## PARTE 2: Adicionar Nodes Novos (importar JSON)

### Arquivo: `patch-bridge-auto-check.json`

Contém 2 nodes prontos para importar:
- **"Tem Ação Concluída?"** — IF node que verifica se GPT detectou conclusão
- **"Auto-Check Tarefas"** — Postgres node que chama `bridge_auto_check_task`

Ambos usam credencial `Postgres | case` (não HTTP Request).

**Como aplicar:**
1. Copiar conteúdo de `patch-bridge-auto-check.json`
2. Ctrl+V no canvas do N8N
3. Conectar: `Detectar Ação Concluída` → `Tem Ação Concluída?` → (true) `Auto-Check Tarefas`

```
ANTES:
  Detectar Ação Concluída → Buscar Plano Pendente

DEPOIS:
  Detectar Ação Concluída → Tem Ação Concluída? → (true) → Auto-Check Tarefas
                          → Buscar Plano Pendente (manter conexão existente)
```
