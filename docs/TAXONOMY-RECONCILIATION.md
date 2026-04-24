---
title: "Operon/Spalla — Taxonomy Reconciliation (Conflitos & Resoluções)"
type: reference
status: action_plan
audience: [dev, architect]
created: 2026-04-07
input_for: EPIC-LF-FASE2-state-machines.md
---

# Taxonomy Reconciliation

> Este documento é o **plano de ação** pra resolver os conflitos de vocabulário identificados na auditoria da V2. Cada conflito tem: **valores atuais**, **decisão canônica**, **lista de pontos a atualizar**, **ordem de execução**.

## Princípio Geral

**O banco de dados é a fonte da verdade pra estados válidos.** Se o CHECK constraint diz X, o código Python tem que respeitar X. Se o frontend referencia algo que não está no CHECK, é bug do frontend.

Quando há divergência, a regra é:
1. Decidir o vocabulário canônico (geralmente o do banco, ou o que faz mais sentido semântico)
2. Atualizar o CHECK se necessário (migration)
3. Atualizar o backend
4. Atualizar o frontend
5. Atualizar testes
6. Atualizar `UBIQUITOUS-LANGUAGE.md`

---

## Conflito 1: Fase Jornada do Mentorado

### Valores atuais

| Local | Valores aceitos |
|-------|-----------------|
| **DB CHECK constraint** (`mentorados.fase_jornada`) | `onboarding | concepcao | validacao | otimizacao | escala | concluido` |
| **Backend** `/api/mentees/{id}` PATCH | `onboarding | execucao | resultado | renovacao | encerrado` |
| **Frontend** filters | mistura ambos, mais `manutencao` |

### Análise

- O DB tem 6 valores granulares (onboarding → escala) que **descrevem o funil de mentoria realisticamente**
- O backend tem 5 valores menos granulares que **misturam fase com evento** (`renovacao` é evento, não estado estável)
- O frontend tem mistura — sintoma de drift histórico

### Decisão Canônica

**Manter os 6 valores do DB** + adicionar `encerrado` como estado terminal (não via CHECK, mas via `ativo=false`).

**Vocabulário canônico**:
```
lead (virtual, pré-contrato — não tá no CHECK)
  ↓
onboarding (D+0 a D+30, setup inicial)
  ↓
concepcao (definindo estratégia, primeiro dossiê em produção)
  ↓
validacao (testando hipóteses, dossiê entregue, primeiras ações)
  ↓
otimizacao (ajustando o que funciona)
  ↓
escala (multiplicando o que dá resultado)
  ↓
concluido (terminou ciclo de mentoria com sucesso)

* qualquer fase → encerrado (cancelamento, reembolso, conclusão antecipada — via ativo=false + motivo_inativacao)
```

### Mapping de valores legados

| Legacy (a remover) | Mapear para |
|---|---|
| `execucao` | `validacao` (na maioria dos casos, ou `otimizacao` se mais avançado) |
| `resultado` | `escala` |
| `renovacao` | NÃO é fase. É evento de `encerrado → onboarding` (novo ciclo). Se mentorado renova, vira novo registro com fase=onboarding. |
| `manutencao` | `escala` (estado estável de quem já escalou) |
| `encerrado` | mantém como conceito, mas não vai pro CHECK — é via `ativo=false` |

### Pontos a atualizar (em ordem)

1. **Audit dos dados existentes**: SQL pra contar quantos mentorados estão em cada valor legacy
   ```sql
   SELECT fase_jornada, COUNT(*) FROM "case".mentorados GROUP BY 1;
   ```

2. **Migration de dados** (se houver registros com valor legacy):
   ```sql
   UPDATE "case".mentorados SET fase_jornada = 'validacao' WHERE fase_jornada = 'execucao';
   UPDATE "case".mentorados SET fase_jornada = 'escala' WHERE fase_jornada = 'resultado';
   UPDATE "case".mentorados SET fase_jornada = 'escala' WHERE fase_jornada = 'manutencao';
   UPDATE "case".mentorados SET ativo = false, motivo_inativacao = 'renovacao_legacy' WHERE fase_jornada = 'renovacao';
   ```

3. **Backend** `app/backend/14-APP-server.py` linha do `/api/mentees/{id}` PATCH:
   - Substituir lista `['onboarding', 'execucao', 'resultado', 'renovacao', 'encerrado']`
   - Por: `['onboarding', 'concepcao', 'validacao', 'otimizacao', 'escala', 'concluido']`
   - Validação extra: se receber `encerrado`, redirecionar pra endpoint `/api/mentees/{id}/offboard`

4. **Frontend** `app/frontend/11-APP-app.js`:
   - Atualizar arrays de filtros que listam fases
   - Atualizar templates de phase task generation
   - Atualizar labels visíveis

5. **Testes** — cenário: tentar PATCH com `execucao` → 400 Bad Request com mensagem clara

6. **UBIQUITOUS-LANGUAGE.md** — já está atualizado (v1.0)

7. **Documentação interna** — README, EPICs antigos

### Risco
**Médio**. Mudança de API externa potencial (se ClickUp ou n8n consomem o PATCH com valores legacy). Validar antes de deploy.

### Status
**Pendente** — fazer na Fase 2.1

---

## Conflito 2: Status de Tarefa

### Valores atuais

| Local | Valores aceitos |
|-------|-----------------|
| **DB CHECK** (`god_tasks.status`) | `pendente | em_andamento | concluida | cancelada` (4 valores) |
| **Frontend** `filteredTasks`, `taskFilter` | `pendente | em_andamento | em_revisao | bloqueada | pausada | concluida | cancelada | atrasada | arquivada` (9 valores!) |
| **Frontend** `quickFilter` | adiciona `overdue` (sinônimo de `atrasada`) |

### Análise

- O frontend referencia 5 estados que **não existem no CHECK do DB**: `em_revisao`, `bloqueada`, `pausada`, `atrasada`, `arquivada`
- Se qualquer código setar um desses como `god_tasks.status`, dá **constraint violation 23514**
- Hoje, o frontend usa esses valores **só pra filtros visuais** (calculados, tipo "atrasada" = pendente + data_fim < now). NÃO setam como `status` real.
- Mas isso é frágil — qualquer dev que adicionar um botão "Marcar como em revisão" vai quebrar.

### Decisão Canônica

**Expandir o CHECK pra incluir os 4 estados realmente úteis** (não incluir `atrasada`, que é cálculo, e renomear `arquivada` pra ser estado terminal):

```sql
CHECK (status IN (
  'pendente',
  'em_andamento',
  'em_revisao',
  'bloqueada',
  'pausada',
  'concluida',
  'cancelada',
  'arquivada'
))
```

**`atrasada` permanece como cálculo no frontend** (não é estado, é propriedade derivada de `data_fim < now() AND status != 'concluida'`).

### FSM Resultante

(Detalhada na Story LF-2.3)

### Pontos a atualizar (em ordem)

1. **Migration** (Fase 2.1):
   ```sql
   ALTER TABLE god_tasks DROP CONSTRAINT IF EXISTS god_tasks_status_check;
   ALTER TABLE god_tasks ADD CONSTRAINT god_tasks_status_check
     CHECK (status IN ('pendente','em_andamento','em_revisao','bloqueada','pausada','concluida','cancelada','arquivada'));
   ```

2. **Frontend**: garantir que `taskFilter` UI mostra os novos estados como opções
3. **Backend**: `TaskStateMachine` valida transições
4. **Endpoint** `/api/tasks/{id}/transition` (Fase 2.8) aceita eventos: `start`, `complete`, `block`, `unblock`, `pause`, `resume`, `cancel`, `archive`, `request_review`, `approve`, `changes_requested`
5. **Testes** com cada transição válida + 5 transições inválidas
6. **UBIQUITOUS-LANGUAGE.md** já alinhado

### Risco
**Baixo**. Migration aditiva (adiciona valores ao CHECK, não remove). Não quebra dados existentes.

### Status
**Pendente** — Fase 2.1

---

## Conflito 3: Tipo de Call

### Valores atuais

| Local | Valores aceitos |
|-------|-----------------|
| **DB** `calls_mentoria.tipo_call` | `onboarding | estrategia | acompanhamento | oferta | conselho | qa | destrave | conteudo` (8 valores, sem CHECK constraint) |
| **Frontend** `scheduleForm.tipo` | `acompanhamento | diagnostico | planejamento | fechamento` (4 valores) |

### Análise

- O DB tem 8 valores semanticamente granulares (cada tipo de call tem propósito diferente)
- O frontend tem 4 valores genéricos
- O `acompanhamento` bate em ambos
- `diagnostico`, `planejamento`, `fechamento` no frontend não correspondem direto a nenhum do DB

### Decisão Canônica

**Manter os 8 valores do DB** + adicionar CHECK constraint pra formalizar.

**Mapping legacy** (frontend → canônico):
- `diagnostico` → `estrategia` (call de levantamento e definição estratégica)
- `planejamento` → `estrategia` (mesma coisa)
- `fechamento` → `oferta` (call de fechar venda)
- `acompanhamento` → mantém

### Pontos a atualizar

1. **Migration**:
   ```sql
   ALTER TABLE calls_mentoria ADD CONSTRAINT calls_mentoria_tipo_check
     CHECK (tipo_call IN ('onboarding','estrategia','acompanhamento','oferta','conselho','qa','destrave','conteudo'));
   ```

2. **Migration de dados** (se há valores legacy):
   ```sql
   UPDATE calls_mentoria SET tipo_call = 'estrategia' WHERE tipo_call IN ('diagnostico','planejamento');
   UPDATE calls_mentoria SET tipo_call = 'oferta' WHERE tipo_call = 'fechamento';
   ```

3. **Frontend**: atualizar `scheduleForm` pra usar 8 valores

4. **Backend** `/api/schedule-call`: validar tipo

### Risco
**Baixo**.

### Status
**Pendente** — Fase 2.1

---

## Conflito 4: Trilha (Scale vs Clinic)

### Situação atual

- Conceito **vive em código Python** (`DS_VALID_TRANSITIONS` em `_handle_ds_update_stage`)
- Não tem coluna no banco
- Mentorados não têm campo `trilha`
- Documentos de dossiê seguem trilha de quem? Confusão.

### Decisão Canônica

**Criar coluna `trilha`** em duas tabelas:

1. `mentorados.trilha` TEXT CHECK (`trilha IN ('scale','clinic')`)
2. `ds_producoes.trilha` TEXT (denormalizado pra performance, atualizado via trigger quando mentorado muda)

**Comportamento**: a `DossieDocumentoStateMachine` (Fase 2.6) recebe `trilha` no construtor e configura transições adequadas.

### Pontos a atualizar

1. **Migration**:
   ```sql
   ALTER TABLE "case".mentorados ADD COLUMN trilha TEXT DEFAULT 'scale' 
     CHECK (trilha IN ('scale','clinic'));
   ALTER TABLE ds_producoes ADD COLUMN trilha TEXT DEFAULT 'scale'
     CHECK (trilha IN ('scale','clinic'));
   ```

2. **Backfill**: SQL pra setar trilha existente baseado em algum critério (consultar Kaique)

3. **Frontend**: dropdown "Trilha" no cadastro/edição de mentorado

4. **Backend**: `/api/mentees/{id}` PATCH aceita `trilha`

5. **FSM Python**: `DossieDocumentoStateMachine(trilha=mentorado.trilha)`

### Risco
**Médio** — depende de Kaique definir qual mentorado é Scale e qual é Clinic (info não está no banco hoje).

### Status
**Pendente** — Fase 2

---

## Conflito 5: Status Financeiro

### Valores atuais

| Local | Valores |
|-------|---------|
| `mentorados.status_financeiro` | `em_dia | atrasado | quitado` |
| Outros lugares | `pago | cancelado | sem_contrato` mencionados |
| Frontend filters | mistura |

### Decisão Canônica

**Vocabulário canônico**:
- `sem_contrato` — ainda não assinou
- `em_dia` — pagamentos em dia (ativo)
- `atrasado` — pagamento(s) em atraso
- `quitado` — contrato pago integralmente (geralmente final)
- `cancelado` — cancelamento + estorno

**Adicionar CHECK**:
```sql
ALTER TABLE "case".mentorados ADD CONSTRAINT mentorados_status_financeiro_check
  CHECK (status_financeiro IN ('sem_contrato','em_dia','atrasado','quitado','cancelado'));
```

### Pontos a atualizar
- Migration
- Backend `/api/mentees/{id}` PATCH validação
- Frontend filters
- View `vw_god_financeiro` adaptar

### Risco
**Baixo**.

### Status
**Pendente** — Fase 2

---

## Conflitos Menores (não-críticos, fazer junto da Fase 2)

### Conflito 6: `sub_etapa` e `marco_atual` em mentorados são TEXT livres
**Resolução**: criar tabela `marcos_catalogo` com FK em mentorados. Adiar pra Fase 5.

### Conflito 7: `tags` em god_tasks tem 2 lugares (TEXT[] legado + tag_relations novo)
**Resolução**: deprecate o TEXT[] legado. Usar só tag_relations. Deletar coluna em Fase 6.

### Conflito 8: `sentimento` aparece em vários lugares com valores potencialmente diferentes
**Locais**: `analises_call.sentimento`, `analises_call.sentimento_geral`, `analises_whatsapp.sentimento_geral`, `wa_messages` (implícito via topic)
**Resolução**: padronizar enum `sentimento_enum` e criar TYPE Postgres. Adiar pra Fase 4.

---

## Plano de Migração Consolidado (Fase 2.1)

Migration única `20260408000000_taxonomy_reconciliation.sql` que executa **TUDO** em ordem:

```sql
BEGIN;

-- 1. god_tasks status — adicionar 4 estados
ALTER TABLE god_tasks DROP CONSTRAINT IF EXISTS god_tasks_status_check;
ALTER TABLE god_tasks ADD CONSTRAINT god_tasks_status_check
  CHECK (status IN ('pendente','em_andamento','em_revisao','bloqueada','pausada','concluida','cancelada','arquivada'));

-- 2. god_tasks tipo — adicionar CHECK
ALTER TABLE god_tasks DROP CONSTRAINT IF EXISTS god_tasks_tipo_check;
ALTER TABLE god_tasks ADD CONSTRAINT god_tasks_tipo_check
  CHECK (tipo IS NULL OR tipo IN ('geral','dossie','ajuste_dossie','follow_up','rotina','bug_report','acao'));

-- 3. calls_mentoria tipo_call — adicionar CHECK
-- (primeiro normalizar legacy)
UPDATE calls_mentoria SET tipo_call = 'estrategia' WHERE tipo_call IN ('diagnostico','planejamento');
UPDATE calls_mentoria SET tipo_call = 'oferta' WHERE tipo_call = 'fechamento';
ALTER TABLE calls_mentoria DROP CONSTRAINT IF EXISTS calls_mentoria_tipo_check;
ALTER TABLE calls_mentoria ADD CONSTRAINT calls_mentoria_tipo_check
  CHECK (tipo_call IS NULL OR tipo_call IN ('onboarding','estrategia','acompanhamento','oferta','conselho','qa','destrave','conteudo'));

-- 4. mentorados trilha — nova coluna
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_schema = 'case' AND table_name = 'mentorados' AND column_name = 'trilha') THEN
    ALTER TABLE "case".mentorados ADD COLUMN trilha TEXT DEFAULT 'scale'
      CHECK (trilha IN ('scale','clinic'));
  END IF;
END $$;

-- 5. ds_producoes trilha — nova coluna (denormalizada)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'ds_producoes' AND column_name = 'trilha') THEN
    ALTER TABLE ds_producoes ADD COLUMN trilha TEXT DEFAULT 'scale'
      CHECK (trilha IN ('scale','clinic'));
  END IF;
END $$;

-- 6. mentorados status_financeiro — adicionar CHECK
ALTER TABLE "case".mentorados DROP CONSTRAINT IF EXISTS mentorados_status_financeiro_check;
ALTER TABLE "case".mentorados ADD CONSTRAINT mentorados_status_financeiro_check
  CHECK (status_financeiro IS NULL OR status_financeiro IN ('sem_contrato','em_dia','atrasado','quitado','cancelado'));

-- 7. mentorados fase_jornada — manter constraint atual (já está alinhado)
-- Backend que vai mudar (não banco)

COMMIT;
```

### Backend updates (Fase 2.1)
1. `/api/mentees/{id}` PATCH: lista de fases válidas = `['onboarding','concepcao','validacao','otimizacao','escala','concluido']`
2. `/api/schedule-call`: validar `tipo` contra a lista canônica
3. Adicionar middleware de validação reutilizável

### Frontend updates (Fase 2.1)
1. `app/frontend/11-APP-app.js`: arrays de filtros atualizados
2. Testes manuais smoke

---

## Versioning

**Versão atual**: v1.0 (2026-04-07)
**Próxima revisão**: após Fase 2.1 (validar que todas as resoluções foram aplicadas)
