---
title: "EPIC LF-FASE3: Descarrego como entidade + Saga formal"
type: epic
status: pending
priority: P0
parent_epic: EPIC-LF-MASTER.md
depends_on: EPIC-LF-FASE2-state-machines.md
created: 2026-04-07
duration: 2-3 weeks
breaking_change: parcial (nova tabela, migração gradual de mentorado_context)
---

# EPIC LF-FASE3: Descarrego como entidade + Saga formal

## Visão

Promover **Descarrego** a entidade de primeira classe com FSM, aggregate root, e implementar a primeira **saga formal** do Spalla: `DescarregoProcessor` que executa o pipeline completo (capturar → transcrever → classificar → ação).

Esta é a fase que **destrava o orquestrador de IA** que o Kaique pediu desde o início. Sem as fundações das fases 0-2, a saga seria frágil e invisível. Com elas, é robusta e observável.

## Por que importa

1. **Desbloqueia o orquestrador de IA**: Kaique grava áudio → IA classifica → task criada/contexto salvo automaticamente
2. **Primeiro caso de uso real do entity_events com correlation_id**: a saga vai amarrar 5+ eventos com mesmo correlation_id
3. **HITL configurável**: confidence threshold define quando IA executa sozinha vs pede aprovação
4. **Aplica TUDO que construímos**: FSM (Fase 2) + event store (Fase 1) + vocabulário (Fase 0)

## Stories

### Story LF-3.1 — Migration: tabela `descarregos`

**Schema:**
```sql
CREATE TABLE descarregos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Identidade
  mentorado_id BIGINT REFERENCES mentorados(id) ON DELETE CASCADE,
  consultor_id TEXT,  -- quem capturou
  
  -- Input bruto
  tipo_bruto TEXT NOT NULL CHECK (tipo_bruto IN ('texto','audio','video','imagem','arquivo','link','gravacao')),
  conteudo_bruto TEXT,                    -- texto direto, ou caption
  arquivo_url TEXT,                       -- pra audio/video/arquivo/imagem
  arquivo_size_bytes BIGINT,
  arquivo_mime_type TEXT,
  duracao_ms INT,                         -- pra audio/video
  
  -- Transcrição (preenchido na fase de transcrição)
  transcricao TEXT,
  transcrito_em TIMESTAMPTZ,
  transcrito_por TEXT,                    -- 'whisper-1' | 'groq-whisper-large-v3' | 'human'
  transcricao_confidence NUMERIC(3,2),
  
  -- Classificação IA
  classificacao_principal TEXT CHECK (classificacao_principal IN (
    'task','contexto','feedback','reembolso','bloqueio','duvida','celebracao','outro'
  )),
  classificacao_sub TEXT,                 -- 'dossie','analise','feedback_positivo','feedback_negativo', etc
  classificacao_confidence NUMERIC(3,2),
  classificacao_payload JSONB DEFAULT '{}'::jsonb,  -- raw output da IA
  classificado_em TIMESTAMPTZ,
  classificado_por TEXT,                  -- 'gpt-4o' | 'gemini-2.5-flash' | 'human'
  
  -- Ação tomada
  acao_tomada TEXT CHECK (acao_tomada IN (
    'task_criada','salvo_como_contexto','escalado_kaique','rejeitado_humano','sem_acao'
  )),
  task_id UUID,                           -- se virou task (FK lógica pra god_tasks)
  context_id UUID,                        -- se virou contexto estruturado
  acao_tomada_em TIMESTAMPTZ,
  acao_tomada_por TEXT,
  
  -- State machine
  status TEXT NOT NULL DEFAULT 'capturado' CHECK (status IN (
    'capturado','transcricao_pendente','transcrito',
    'classificacao_pendente','classificado',
    'aguardando_humano','executando_acao_automatica','executando_acao_manual',
    'finalizado','rejeitado','erro'
  )),
  
  -- Metadados
  fonte TEXT,                             -- 'web_drawer','wa_inbound','api','batch_import','migration_legacy'
  correlation_id UUID,                    -- pra amarrar com event_events e outras entidades
  retry_count INT DEFAULT 0,
  last_error TEXT,
  
  -- Audit
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_descarregos_mentorado ON descarregos(mentorado_id, created_at DESC);
CREATE INDEX idx_descarregos_status ON descarregos(status) WHERE status NOT IN ('finalizado','rejeitado');
CREATE INDEX idx_descarregos_correlation ON descarregos(correlation_id) WHERE correlation_id IS NOT NULL;
CREATE INDEX idx_descarregos_classificacao ON descarregos(classificacao_principal, classificado_em);

-- Trigger pra updated_at
CREATE TRIGGER trg_descarregos_updated
BEFORE UPDATE ON descarregos
FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

-- Trigger pra entity_events (Fase 1 dependency)
CREATE TRIGGER trg_descarregos_events
AFTER INSERT OR UPDATE OR DELETE ON descarregos
FOR EACH ROW EXECUTE FUNCTION emit_entity_event('Descarrego');

-- RLS
ALTER TABLE descarregos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "descarregos_select" ON descarregos FOR SELECT TO authenticated USING (true);
CREATE POLICY "descarregos_insert" ON descarregos FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "descarregos_update" ON descarregos FOR UPDATE TO authenticated USING (true);
```

**AC:**
- [ ] Migration aplicada
- [ ] CHECK constraints validados
- [ ] Trigger entity_events ativo
- [ ] RLS configurada

---

### Story LF-3.2 — Migração de dados legados (mentorado_context → descarregos)

**Procedimento:**
1. SELECT all from `mentorado_context`
2. INSERT em `descarregos` com:
   - `tipo_bruto = 'texto'` (legado é tudo texto)
   - `conteudo_bruto = mentorado_context.conteudo`
   - `transcricao = NULL` (já é texto)
   - `classificacao_principal = 'contexto'` (default — não temos info de classificação)
   - `classificacao_confidence = 0.0` (não foi classificado)
   - `acao_tomada = 'salvo_como_contexto'`
   - `status = 'finalizado'`
   - `fonte = 'migration_legacy'`
   - `created_at = mentorado_context.criado_em`

**AC:**
- [ ] Script de migração criado em `supabase/migrations/`
- [ ] Dados migrados (validar count antes/depois)
- [ ] mentorado_context **mantido** durante período de transição (deletado em Fase 6)

---

### Story LF-3.3 — DescarregoStateMachine implementação concreta

(FSM já desenhada na Story LF-2.7. Aqui é a implementação concreta linkada à tabela real.)

**Arquivo:** `app/backend/domain/state_machines/descarrego.py`

**AC:**
- [ ] Classe carrega `descarrego` row do Supabase
- [ ] Cada `transition()` faz UPDATE no Supabase + emit_event
- [ ] Guards funcionais (ex: skip_transcription só pra texto direto)
- [ ] Test suite

---

### Story LF-3.4 — Backend: endpoint `POST /api/descarrego/capture`

**Input:**
- `mentorado_id` (required)
- `tipo_bruto` (required)
- `conteudo_bruto` (texto) OU `arquivo` (multipart)
- `fonte` (opcional, default `web_drawer`)

**Comportamento:**
1. Valida mentorado existe
2. Se arquivo: upload pra Supabase Storage, pega URL
3. INSERT em `descarregos` (status=`capturado`, correlation_id=novo UUID)
4. Retorna `{descarrego_id, status, correlation_id}`
5. **Não processa a saga inline.** Frontend chama `/process` separadamente (assíncrono).

**AC:**
- [ ] Endpoint criado
- [ ] Auth via check_auth_any
- [ ] Suporta texto + arquivo
- [ ] Retorna correlation_id pra amarrar com saga

---

### Story LF-3.5 — Backend: GPT-4o classifier

**Arquivo:** `app/backend/domain/services/descarrego_classifier.py`

**Função:** `classify_descarrego(text: str, mentorado_context: dict) -> dict`

**Prompt do classifier:**
```
Você é um classificador de "descarrego" de mentoria. Analisa o input do consultor e retorna JSON estruturado.

Tipos válidos:
- task: ação a ser tomada (criar, fazer, enviar, executar)
- contexto: informação a guardar pro mentorado (sobre o negócio dele, situação)
- feedback: opinião do mentorado sobre algo (positivo ou negativo)
- reembolso: solicitação ou menção de reembolso/cancelamento
- bloqueio: mentorado está travado/parado em algo
- duvida: pergunta a responder
- celebracao: vitória, conquista, marco

Retorne JSON:
{
  "primary_type": "...",
  "subtype": "...",         // ex: "dossie", "feedback_positivo", etc
  "confidence": 0.0-1.0,
  "summary": "1-2 frases",
  "task": {                  // só se primary_type=task
    "titulo": "...",
    "responsavel": "kaique|mariza|queila|...",
    "prazo_dias": 0-30,      // dias a partir de hoje
    "prioridade": "baixa|normal|alta|urgente"
  },
  "alertas": []              // ex: ["urgente: reembolso", "menciona prazo legal"]
}
```

**AC:**
- [ ] Função criada
- [ ] Usa OPENAI_API_KEY (já setada no Railway)
- [ ] Modelo: gpt-4o-mini (custo) ou gpt-4o (qualidade)
- [ ] Retry com exponential backoff
- [ ] Test com 5 inputs reais

---

### Story LF-3.6 — DescarregoProcessor saga

**Arquivo:** `app/backend/domain/sagas/descarrego_processor.py`

(Esqueleto na ARCHITECTURE-V2-spalla-applied.md.)

**Comportamento:**
1. Carrega descarrego por ID
2. Se `tipo_bruto` em (audio,video,gravacao): chama `_transcribe()` → Whisper
3. Chama `_classify()` → GPT-4o
4. Decide ação:
   - confidence ≥ 0.8 AND tipo_não_crítico → `_execute_auto_action()`
   - senão → `_queue_for_human_review()`
5. Em qualquer falha: marca status=`erro`, salva `last_error`, incrementa `retry_count`

**Cada passo:**
- Chama `sm.transition(event, actor, correlation_id, payload)` que emite evento
- Logga em `entity_events` com correlation_id consistente

**AC:**
- [ ] Saga executando end-to-end com input mock
- [ ] Idempotente (rodar 2x sem efeitos duplicados)
- [ ] Rollback em caso de erro
- [ ] Test integration

---

### Story LF-3.7 — Backend: endpoint `POST /api/descarrego/{id}/process`

**Input:** none (descarrego_id na URL)

**Comportamento:**
1. Carrega descarrego
2. Valida status (só processa se `status in (capturado, classificado, erro)`)
3. Spawna thread daemon que roda `DescarregoProcessor.run()`
4. Retorna 202 Accepted com `{descarrego_id, status, message: "processing started"}`

**Por que async:** transcrição + classificação podem demorar 30-60s. Cliente faz polling em `/api/descarrego/{id}` pra ver status.

**AC:**
- [ ] Endpoint criado
- [ ] Async execution
- [ ] Auth required
- [ ] Test: capturar → process → polling até `finalizado`

---

### Story LF-3.8 — Frontend: aba Contexto na ficha do mentorado

**Tab "Contexto"** já existe (foi adicionada em PR anterior). Esta story conecta com `descarregos` ao invés de `mentorado_context`.

**Mudanças:**
1. Loader: `loadMenteeContext(mentoradoId)` passa a ler de `descarregos` (filtrar por mentorado_id, ordenar por created_at desc)
2. Renderer: card por descarrego mostrando:
   - Tipo (texto/audio/etc) com ícone
   - Conteúdo bruto OU transcrição
   - Classificação (badge colorido)
   - Confidence %
   - Ação tomada (ícone + texto)
   - Botão "Reprocessar" se status=erro
   - Botão "Aprovar" / "Rejeitar" se status=aguardando_humano
3. Drawer de captura: botão "+ Novo Descarrego" abre modal com tipo (texto/audio) → POST `/api/descarrego/capture` → POST `/api/descarrego/{id}/process` → fecha modal → refresh
4. Realtime: subscribe em `descarregos` filtrado por mentorado_id pra ver mudanças

**AC:**
- [ ] Aba Contexto consumindo `descarregos`
- [ ] Card renderiza todos campos relevantes
- [ ] Captura via modal funcionando
- [ ] HITL: card com `aguardando_humano` mostra botões aprovar/rejeitar

---

### Story LF-3.9 — HITL: aprovação humana

**Endpoint:** `POST /api/descarrego/{id}/approve` e `/reject`

**Comportamento:**
- `approve`: chama `sm.transition('human_approved', actor=user)`, executa `_execute_auto_action()` no processor
- `reject`: chama `sm.transition('human_rejected', actor=user)`, marca finalizado com `acao_tomada='rejeitado_humano'`

**AC:**
- [ ] 2 endpoints criados
- [ ] Frontend tem botões funcionais
- [ ] Test: capturar texto ambíguo → IA classifica com confidence 0.6 → vai pra aguardando_humano → user clica aprovar → vira task

---

### Story LF-3.10 — Smoke Test em Produção (gold scenario)

**Procedimento:**
1. Kaique grava áudio: "preciso fazer dossiê da Maria pra quinta-feira, urgente"
2. Frontend captura → POST capture → POST process
3. Saga roda: Whisper transcreve → GPT-4o classifica como `task` com confidence 0.95
4. Auto-execute: cria task com titulo extraído, responsavel="kaique", prazo=quinta, prioridade=urgente
5. Kaique abre `/tasks` → task aparece automaticamente

**SLO:** todo esse pipeline em <60s

**AC:**
- [ ] Cenário ouro funciona
- [ ] Latência <60s (medir)
- [ ] Task aparece em /tasks
- [ ] Journey query: SELECT * FROM vw_correlation_timeline WHERE correlation_id = X mostra 7+ eventos amarrados

---

## DoD do Epic LF-FASE3

- [ ] Story LF-3.1 (migration descarregos) ✓
- [ ] Story LF-3.2 (migração legados) ✓
- [ ] Story LF-3.3 (DescarregoStateMachine concreto) ✓
- [ ] Story LF-3.4 (endpoint capture) ✓
- [ ] Story LF-3.5 (GPT-4o classifier) ✓
- [ ] Story LF-3.6 (DescarregoProcessor saga) ✓
- [ ] Story LF-3.7 (endpoint process async) ✓
- [ ] Story LF-3.8 (frontend aba Contexto refatorada) ✓
- [ ] Story LF-3.9 (HITL approve/reject) ✓
- [ ] Story LF-3.10 (smoke test gold scenario) ✓
- [ ] PR mergeado em develop
- [ ] Backend deployado no Railway
- [ ] Frontend deployado no Vercel
- [ ] Métrica: ≥10 descarregos processados via saga em produção
- [ ] Métrica: >70% de approval rate humana nas sugestões IA
