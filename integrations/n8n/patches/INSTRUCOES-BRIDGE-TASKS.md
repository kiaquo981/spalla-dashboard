# Bridge Tasks: Instruções de Aplicação

## Contexto

As functions `bridge_create_task` e `bridge_auto_check_task` já existem no Supabase.
Precisamos atualizar 2 nodes existentes e adicionar 2 nodes novos no Scraper v34.

---

## PARTE 1: Modificar Nodes Existentes (manual no N8N)

### Node: "Salvar Compromissos"

**Localização:** Canvas posição [1040, 5296] — é um Supabase node
**Tipo atual:** `n8n-nodes-base.supabase` (INSERT em `tarefas_acordadas`)

**Ação:** Trocar por HTTP Request que chama `bridge_create_task` via RPC

1. Clicar no node "Salvar Compromissos"
2. **Deletar o node** (Backspace)
3. Adicionar **HTTP Request** node no mesmo lugar
4. Renomear para "Salvar Compromissos"
5. Configurar:

| Campo | Valor |
|---|---|
| Method | POST |
| URL | `={{ $env.SUPABASE_URL }}/rest/v1/rpc/bridge_create_task` |
| Send Headers | ON |
| Header 1 | `apikey` = `={{ $env.SUPABASE_SERVICE_KEY }}` |
| Header 2 | `Authorization` = `=Bearer {{ $env.SUPABASE_SERVICE_KEY }}` |
| Header 3 | `Content-Type` = `application/json` |
| Send Body | ON |
| Body Content Type | JSON |
| JSON Body | (ver abaixo) |

**JSON Body:**
```
={{ JSON.stringify({
  p_mentorado_id: $json.mentorado_id,
  p_titulo: $json.compromisso,
  p_descricao: $json.contexto,
  p_responsavel: $json.sender_name || 'mentorado',
  p_prioridade: 'normal',
  p_data_fim: $json.prazo_inferido || null,
  p_fonte: 'whatsapp_compromisso',
  p_interacao_id: $json.interacao_id || null,
  p_confianca: $json.confianca || 0.7
}) }}
```

6. Reconectar as setas (mesmas entradas/saídas de antes)

---

### Node: "Criar Tarefa Material"

**Localização:** Canvas posição [1328, 3088] — é um Supabase node
**Tipo atual:** `n8n-nodes-base.supabase` (INSERT em `tarefas_acordadas`)

**Ação:** Mesma coisa — trocar por HTTP Request para `bridge_create_task`

1. Deletar o node "Criar Tarefa Material"
2. Adicionar HTTP Request no mesmo lugar
3. Renomear para "Criar Tarefa Material"
4. Configurar igual ao anterior, mas com JSON Body diferente:

**JSON Body:**
```
={{ JSON.stringify({
  p_mentorado_id: $json.mentorado_id,
  p_titulo: 'Enviar material solicitado',
  p_descricao: $json.resumo || ($json.conteudo || '').substring(0, 300),
  p_responsavel: $json.responsavel_detectado || 'Equipe',
  p_prioridade: 'alta',
  p_data_fim: $now.plus({days: 2}).toFormat('yyyy-MM-dd'),
  p_fonte: 'whatsapp_material',
  p_interacao_id: $json.interacao_id || null,
  p_confianca: 0.9,
  p_tags: ['material-solicitado']
}) }}
```

---

## PARTE 2: Adicionar Nodes Novos (importar JSON)

### Arquivo: `patch-bridge-auto-check.json`

Contém 2 nodes prontos para importar:
- **"Tem Ação Concluída?"** — IF node que verifica se GPT detectou conclusão
- **"Auto-Check Tarefas"** — HTTP Request que chama `bridge_auto_check_task`

**Como aplicar:**
1. Copiar conteúdo de `patch-bridge-auto-check.json`
2. Ctrl+V no canvas do N8N
3. Posicionar ao lado de "Detectar Ação Concluída" (posição ~[1488, 3280])
4. Conectar: `Detectar Ação Concluída` → `Tem Ação Concluída?` → (true) `Auto-Check Tarefas`
5. A saída false do IF não precisa de conexão

```
ANTES:
  Detectar Ação Concluída → Buscar Plano Pendente → Atualizar Plano Concluído

DEPOIS:
  Detectar Ação Concluída → Tem Ação Concluída?
                               ├── true  → Auto-Check Tarefas
                               └── false → (nada)
                            → Buscar Plano Pendente → Atualizar Plano Concluído
```

Nota: "Buscar Plano Pendente" continua conectado ao "Detectar Ação Concluída" como antes.
O "Tem Ação Concluída?" é um branch ADICIONAL, não substitui o fluxo existente.

---

## Env Vars Necessárias no N8N

| Variável | Valor |
|---|---|
| `SUPABASE_URL` | `https://knusqfbvhsqworzyhvip.supabase.co` |
| `SUPABASE_SERVICE_KEY` | (service role key do Supabase) |

Configurar em: N8N → Settings → Environment Variables
