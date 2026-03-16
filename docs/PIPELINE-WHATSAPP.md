# Pipeline WhatsApp — Documentação Técnica

## Visão Geral

```
Evolution API (producao002, manager01)
    │ webhook POST
    ▼
N8N Scraper v34 (manager01)
    │
    ├─ Normalizar Webhook
    │   ├─ Salvar em whatsapp_messages (backup raw)
    │   └─ Buscar Contexto Ativo
    │
    ├─ Filtrar Válidos → Buscar Mentorado
    │
    ├─ [PATCH] Detector Tipo Mensagem (GPT-4o-mini)
    │   ├─ OK → classificação completa
    │   └─ ERRO → gpt-fallback-classifier.js (conservador)
    │
    ├─ fallback-eh-equipe.js (heurística por telefone/nome)
    ├─ fallback-requer-resposta.js (heurística por conteúdo)
    │
    ├─ Salvar Interação (Supabase INSERT → interacoes_mentoria)
    │   ├─ OK → Switch por classificação
    │   └─ ERRO → save-interaction-error-handler.js → DLQ
    │
    └─ Trigger SQL: auto_mark_responded()
       (se eh_equipe=true → marca pendências anteriores 72h como respondidas)

    ┌──────────────────────────────────┐
    │ N8N: Alertas Mensagens Pendentes │
    │ Schedule: a cada 3h              │
    │ Query: requer_resposta=true      │
    │        AND respondido=false      │
    │ Envia WA para: equipe CASE       │
    └──────────────────────────────────┘
```

## Tabelas

| Tabela | Função |
|---|---|
| `interacoes_mentoria` | Mensagens classificadas (~24K rows) |
| `wa_dead_letter_queue` | Mensagens que falharam no pipeline |
| `wa_pipeline_stats` | Contadores diários do pipeline |
| `wa_sessions` | Sessões WhatsApp per-user |

## Views

| View | Função |
|---|---|
| `vw_god_pendencias` | Mensagens pendentes de resposta |
| `vw_pipeline_health` | Health check do pipeline |

## Functions

| Function | Função |
|---|---|
| `auto_mark_responded()` | Trigger: marca pendências como respondidas |
| `fix_phantom_pendencias()` | Cleanup: corrige pendências fantasma |
| `increment_pipeline_stat()` | Helper: incrementa contadores diários |

## Troubleshooting

### Pendências fantasma aparecendo
```sql
SELECT * FROM fix_phantom_pendencias();
```

### Verificar health do pipeline
```sql
SELECT * FROM vw_pipeline_health;
```

### Ver mensagens na DLQ
```sql
SELECT * FROM wa_dead_letter_queue WHERE status = 'pending' ORDER BY created_at DESC;
```

### Reprocessar mensagem da DLQ
```sql
UPDATE wa_dead_letter_queue SET status = 'retried' WHERE id = <ID>;
-- Depois: re-inserir manualmente ou via N8N
```

### Campos NULL na classificação
```sql
SELECT COUNT(*) FILTER (WHERE eh_equipe IS NULL) AS null_eh_equipe,
       COUNT(*) FILTER (WHERE requer_resposta IS NULL) AS null_requer
FROM interacoes_mentoria WHERE created_at > NOW() - INTERVAL '7 days';
```

## Equipe CASE (telefones para heurísticas)

| Nome | Telefone |
|---|---|
| Heitor | 5527999473185 |
| Kaique | 5511964682447 |
| Lara | 5524992514909 |
| Queila | 5527988918032 |
| Thiago | 5511967755879 |
