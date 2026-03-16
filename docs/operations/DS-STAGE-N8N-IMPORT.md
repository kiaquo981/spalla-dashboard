---
title: DS Stage Notification — Import e Smoke Test
type: operations
status: active
created: 2026-03-16
---

# DS Stage Notification — Import e Smoke Test

## Artefato

- Workflow source: `integrations/n8n/ds-stage-notification.json`
- Destino operacional: N8N do `manager01`
- Objetivo: notificar no WhatsApp quando um `ds_documentos` muda de estágio e gera `ds_eventos.tipo_evento = 'estagio_change'`

## O que o workflow faz

1. Agenda execução a cada 5 minutos.
2. Consulta `ds_eventos` filtrando `tipo_evento = 'estagio_change'` e `created_at >= now() - 5min`.
3. Formata mensagem com descrição, estágio anterior, estágio novo e responsável.
4. Envia texto via Evolution API para o grupo definido em `NOTIFY_GROUP_ID`.

## Pré-importação

- Confirmar que o arquivo `integrations/n8n/ds-stage-notification.json` é o artefato a ser importado.
- Criar ou identificar no N8N uma credencial `Supabase API` para o projeto CASE.
- Confirmar variáveis de ambiente no N8N:
  - `EVOLUTION_API_URL=https://evolution.manager01.feynmanproject.com`
  - `EVOLUTION_API_KEY=<token ativo da Evolution>`
  - `NOTIFY_GROUP_ID=<jid ou grupo de destino>`
- Confirmar que a instância `producao002` é a correta para `/message/sendText/producao002`.

## Ajustes obrigatórios após import

1. Abrir o node `Buscar eventos recentes`.
2. Substituir a credencial placeholder `Supabase CASE (replace ID after N8N import)` pela credencial real do ambiente.
3. Abrir o node `Enviar WhatsApp` e validar:
   - URL: `{{$env.EVOLUTION_API_URL}}/message/sendText/producao002`
   - Header `apikey`: `{{$env.EVOLUTION_API_KEY}}`
   - Body `number`: `{{$env.NOTIFY_GROUP_ID}}`
4. Salvar e ativar o workflow.

## Smoke test recomendado

1. Executar um `POST /api/ds/update-stage` para um documento conhecido:

```bash
curl -X POST "https://manager01.juridicomarinho.com.br:9999/api/ds/update-stage" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <jwt-valido>" \
  -d '{
    "mentorado_slug": "thiago-kailer",
    "dossie_tipo": "oferta",
    "estagio": "producao_ia"
  }'
```

2. Validar no Supabase que um novo registro foi criado em `ds_eventos` com:
   - `tipo_evento = 'estagio_change'`
   - `created_at` nos últimos 5 minutos
3. Rodar o workflow manualmente no N8N ou aguardar o próximo ciclo de 5 minutos.
4. Confirmar recebimento da mensagem no grupo WhatsApp configurado.

## Critérios de aprovação

- O workflow importa sem erro de schema.
- O node Supabase usa a credencial real do ambiente.
- O node HTTP usa retry (`maxTries: 2`, `waitBetweenTries: 3000ms`) e entrega a notificação.
- Um evento real de `estagio_change` gera uma mensagem WhatsApp legível com estágio anterior, estágio novo e responsável.

## Riscos conhecidos

- O JSON usa credencial placeholder para Supabase e exige substituição manual após o import.
- Se `NOTIFY_GROUP_ID` estiver vazio ou inválido, o workflow executa mas não entrega a notificação.
- O filtro de 5 minutos pode reenviar eventos em cenários de execução manual repetida dentro da mesma janela.
