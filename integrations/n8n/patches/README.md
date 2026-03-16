# N8N Safety Net Patches

Patches JSON para importar no N8N Scraper v34. Cada arquivo é um node (ou par de nodes) pronto para colar no workflow.

## Patches Disponíveis

| Arquivo | Aplicar em | Função |
|---|---|---|
| `patch-gpt-fallback-classifier.json` | Error branch do "Detector Tipo Mensagem" | Classificação conservadora quando GPT falha |
| `patch-fallback-eh-equipe.json` | Code node APÓS Detector, ANTES de Salvar | Determina eh_equipe por telefone/nome se GPT falhou |
| `patch-fallback-requer-resposta.json` | Code node APÓS fallback-eh-equipe | Determina requer_resposta por heurísticas |
| `patch-save-error-to-dlq.json` | Error branch do "Salvar Interação" | Salva msg na DLQ se Supabase falhar (2 nodes: Code + Postgres) |

## Como Importar no N8N

1. Abrir workflow "Sistema de Gestão de Whatsapp - Scraper v34"
2. Para cada patch: **Ctrl+V** o conteúdo JSON do arquivo no canvas
3. Conectar os nodes na posição correta (ver diagrama abaixo)
4. Salvar e testar

## Ordem de Aplicação no Pipeline

```
Webhook
  → Normalizar Webhook
    → [existente] Detector Tipo Mensagem (GPT)
       ├── OK → gpt output
       └── ERRO → patch-gpt-fallback-classifier.json      ← PATCH 1
    → patch-fallback-eh-equipe.json                         ← PATCH 2
    → patch-fallback-requer-resposta.json                   ← PATCH 3
    → [existente] Salvar Interação (Supabase)
       ├── OK → continua pipeline
       └── ERRO → patch-save-error-to-dlq.json             ← PATCH 4 (2 nodes)
```

## Credenciais

O patch DLQ usa a credencial `Postgres | case` (ID: `vVXQE04tisGHZsFJ`) — mesma do Scraper v34. Se o ID não bater, atualizar no node `[PATCH] INSERT DLQ`.

## SQL Migrations Necessárias (já aplicadas)

Executar no Supabase ANTES de aplicar patches:

1. `54-SQL-wa-dead-letter-queue.sql` — Tabela DLQ ✅
2. `55-SQL-wa-pipeline-stats.sql` — Tabela de stats ✅

## Como Testar

1. Enviar mensagem de teste em grupo WhatsApp
2. Verificar no Supabase: `SELECT * FROM interacoes_mentoria ORDER BY created_at DESC LIMIT 1;`
3. Verificar campos não são NULL: `eh_equipe`, `requer_resposta`, `classificacao`
4. Para testar DLQ: temporariamente quebrar credenciais Supabase no N8N
5. Verificar: `SELECT * FROM wa_dead_letter_queue WHERE status = 'pending';`
