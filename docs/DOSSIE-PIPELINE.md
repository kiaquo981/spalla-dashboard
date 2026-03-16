---
title: Dossiê Pipeline — Documentação Técnica
type: documentation
status: active
created: 2026-03-16
---

# Dossiê Pipeline — Documentação Técnica

## Visão Geral

Pipeline automatizado de produção de dossiês para mentorados CASE.
Cada mentorado recebe 3 dossiês gold-standard: Oferta, Posicionamento, Funil.

## Diagrama do Pipeline

```text
Transcrição       Fila de          Produção      Revisão        Revisão        Revisão
Disponível   →    Produção    →    IA (~12h)  →  Mariza    →    Kaique    →    Queila    →  Aprovado → Enviado
                                                                                             │
ds_transcricoes   vw_ds_           Playbooks     ds_documentos  ds_documentos  ds_documentos │
status=disponivel production_queue auto/manual   estagio=       estagio=       estagio=      │
                                                 revisao_mariza revisao_kaique revisao_queila │
                                                                                             ▼
                                                                                        god_tasks
                                                                                        (auto-created
                                                                                         by bridge trigger)
```

## Tabelas

| Tabela | Descrição | Migration |
|--------|-----------|-----------|
| `ds_producoes` | 1 por mentorado — controle macro da produção | 22-SQL-ds-schema |
| `ds_documentos` | 3 por produção (oferta, funil, conteudo) — tracking por doc | 22-SQL-ds-schema |
| `ds_eventos` | Audit trail de mudanças de estágio | 22-SQL-ds-schema |
| `ds_ajustes` | Ajustes pós-call de apresentação | 22-SQL-ds-schema |
| `ds_transcricoes` | Tracking de transcrições disponíveis | 53-SQL-ds-transcricoes |

## Views

| View | Descrição | Migration |
|------|-----------|-----------|
| `vw_ds_pipeline` | Pipeline completo com estágios por doc, aging, ajustes | 22-SQL-ds-schema |
| `vw_ds_production_queue` | Mentorados prontos para produção (transcrição + sem dossiê) | 54-SQL-vw-ds-production-queue |
| `vw_ds_metrics` | Métricas: throughput, bottleneck, tempo médio por estágio | 57-SQL-vw-ds-metrics |

## Functions

| Function | Descrição | Migration |
|----------|-----------|-----------|
| `ds_aging_alerts()` | Retorna docs parados >3 dias no mesmo estágio | 56-SQL-ds-aging-alert |
| `bridge_ds_stage_to_task()` | Trigger: cria god_task ao mudar estágio | 46-SQL-ds-bridge-v2 |
| `ds_update_timestamp()` | Trigger: auto-update `updated_at` | 22-SQL-ds-schema |

## Triggers

| Trigger | Tabela | Evento | Ação |
|---------|--------|--------|------|
| `trg_ds_stage_to_task` | ds_documentos | BEFORE UPDATE OF estagio_atual | Cria god_task para responsável, fecha task anterior |
| `ds_producoes_updated` | ds_producoes | BEFORE UPDATE | Set updated_at = now() |
| `ds_documentos_updated` | ds_documentos | BEFORE UPDATE | Set updated_at = now() |
| `ds_ajustes_updated` | ds_ajustes | BEFORE UPDATE | Set updated_at = now() |

## Estágios de Documento

```text
pendente → producao_ia → revisao_mariza → revisao_kaique → revisao_queila → aprovado → enviado → finalizado
```

| Estágio | Responsável | Descrição |
|---------|-------------|-----------|
| pendente | — | Aguardando transcrição ou trigger |
| producao_ia | IA | Dossiê sendo produzido por agent |
| revisao_mariza | Mariza | Primeira revisão (linguagem, formatação) |
| revisao_kaique | Kaique | Revisão técnica (qualidade, coerência) |
| revisao_queila | Queila | Aprovação final (tom de voz, estratégia) |
| aprovado | — | Pronto para envio |
| enviado | — | Enviado ao mentorado |
| finalizado | — | Call de apresentação realizada |

## Playbooks

| Playbook | Descrição | Path |
|----------|-----------|------|
| pipeline-dossies-auto | Orquestrador: 3 dossiês em sequência (parametrizado) | Auto Run Docs/Playbooks/ |
| write-dossie-oferta | Dossiê Oferta & Produto | Auto Run Docs/Playbooks/ |
| write-dossie-posicionamento | Dossiê Posicionamento & Conteúdo | Auto Run Docs/Playbooks/ |
| write-dossie-funil | Dossiê Funil de Vendas | Auto Run Docs/Playbooks/ |
| pipeline-dossies-completo | Pipeline completo (referência, executado para Thiago Kailer) | Auto Run Docs/Playbooks/ |

## API Endpoints

### `POST /api/ds/update-stage`

Atualiza estágio de documento e cria evento de auditoria.

**Headers:** `Authorization: Bearer <jwt_token>`

**Body:**
```json
{
  "mentorado_slug": "thiago-kailer",
  "dossie_tipo": "oferta",
  "estagio": "producao_ia"
}
```

| Campo | Tipo | Valores |
|-------|------|---------|
| `mentorado_slug` | string | Nome parcial do mentorado (ILIKE match) |
| `dossie_tipo` | string | `oferta`, `funil`, `conteudo` |
| `estagio` | string | `pendente`, `producao_ia`, `revisao_mariza`, `revisao_kaique`, `revisao_queila`, `aprovado`, `enviado`, `finalizado` |

**Transições válidas:**
```
pendente → producao_ia → revisao_mariza → revisao_kaique → revisao_queila → aprovado → enviado → finalizado
                ↑              ↑                ↑
            (send back)    (send back)      (send back)
```

**Respostas:**

| Status | Descrição |
|--------|-----------|
| 200 | `{ok, mentorado, tipo, estagio, responsavel}` |
| 400 | Validação falhou (campo faltando, tipo/estágio inválido) |
| 401 | Token JWT ausente ou inválido |
| 403 | Role insuficiente (requer `admin` ou `team`) |
| 404 | Mentorado ou documento não encontrado |
| 409 | Transição de estágio inválida |
| 500 | Erro interno ao atualizar banco |

## N8N Workflows

| Workflow | Descrição | Path |
|----------|-----------|------|
| ds-stage-notification | Notificação WA ao mover estágio (cron 5min) | integrations/n8n/ |

## Como Adicionar um Novo Mentorado

1. Salvar transcrições em `BU-CASE/knowledge/team/{slug}/transcricoes/`
2. Registrar em `ds_transcricoes`:
   ```sql
   INSERT INTO ds_transcricoes (mentorado_id, arquivo, tipo, tamanho_kb)
   SELECT id, 'nome-do-arquivo.txt', 'estrategia', 200
   FROM "case".mentorados WHERE nome ILIKE '%Nome%';
   ```
3. Criar produção (se não existe):
   ```sql
   INSERT INTO ds_producoes (mentorado_id, status, created_by)
   SELECT id, 'nao_iniciado', 'manual'
   FROM "case".mentorados WHERE nome ILIKE '%Nome%';
   ```
4. Criar 3 documentos:
   ```sql
   INSERT INTO ds_documentos (producao_id, mentorado_id, tipo, titulo, estagio_atual, ordem)
   SELECT p.id, p.mentorado_id, t.tipo, t.titulo, 'pendente', t.ord
   FROM ds_producoes p,
   (VALUES ('oferta', 'Dossiê Oferta - Nome', 1),
           ('funil', 'Dossiê Funil - Nome', 2),
           ('conteudo', 'Dossiê Posicionamento - Nome', 3)) AS t(tipo, titulo, ord)
   WHERE p.mentorado_id = (SELECT id FROM "case".mentorados WHERE nome ILIKE '%Nome%');
   ```

## Como Disparar Produção Manualmente

1. Instanciar playbook: copiar `pipeline-dossies-auto.md` e substituir `{slug}`, `{mentorado}`, `{SLUG_UPPER}`
2. Executar via Maestro ou Claude Code
3. Ao concluir, chamar:
   ```bash
   curl -X POST http://localhost:9999/api/ds/update-stage \
     -H "Authorization: Bearer <jwt_token>" \
     -H "Content-Type: application/json" \
     -d '{"mentorado_slug": "nome", "dossie_tipo": "oferta", "estagio": "producao_ia"}'
   ```
4. Repetir para funil e conteudo
