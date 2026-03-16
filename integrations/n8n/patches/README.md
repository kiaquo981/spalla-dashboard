# N8N Safety Net Patches

Patches para tornar o pipeline de mensagens WhatsApp mais confiável.

## Patches Disponíveis

| Arquivo | Aplicar em | Função |
|---|---|---|
| `gpt-fallback-classifier.js` | Error branch do "Detector Tipo Mensagem" | Classificação conservadora quando GPT falha |
| `fallback-eh-equipe.js` | Code node APÓS Detector, ANTES de Salvar | Determina eh_equipe por telefone/nome se GPT falhou |
| `fallback-requer-resposta.js` | Code node APÓS fallback-eh-equipe | Determina requer_resposta por heurísticas |
| `save-interaction-error-handler.js` | Error branch do "Salvar Interação" | Salva msg na DLQ se Supabase falhar |

## Ordem de Aplicação

```
Webhook
  → Normalizar Webhook
    → [existente] Detector Tipo Mensagem (GPT)
       ├── OK → gpt output
       └── ERRO → gpt-fallback-classifier.js    ← PATCH 1
    → fallback-eh-equipe.js                       ← PATCH 2
    → fallback-requer-resposta.js                 ← PATCH 3
    → [existente] Salvar Interação (Supabase)
       ├── OK → continua
       └── ERRO → save-interaction-error-handler.js → INSERT DLQ  ← PATCH 4
```

## Como Aplicar

1. Abrir workflow "Sistema de Gestão de Whatsapp - Scraper v34" no N8N
2. Para cada patch: criar Code node → colar código → conectar na posição correta
3. Para error handlers: usar o "Error Output" do node correspondente
4. Salvar e testar com mensagem de teste

## Como Testar

1. Enviar mensagem de teste em grupo WhatsApp
2. Verificar no Supabase: `SELECT * FROM interacoes_mentoria ORDER BY created_at DESC LIMIT 1;`
3. Verificar campos: `eh_equipe`, `requer_resposta`, `classificacao` não são NULL
4. Para testar DLQ: temporariamente quebrar credenciais do Supabase no N8N
5. Verificar: `SELECT * FROM wa_dead_letter_queue WHERE status = 'pending';`

## SQL Migrations Necessárias

Executar no Supabase SQL Editor ANTES de aplicar os patches:

1. `54-SQL-wa-dead-letter-queue.sql` — Tabela DLQ
2. `55-SQL-wa-pipeline-stats.sql` — Tabela de stats
