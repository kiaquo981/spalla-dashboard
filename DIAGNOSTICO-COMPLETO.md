# 🔍 DIAGNÓSTICO COMPLETO — SPALLA CALLS + INSTAGRAM + CONTEXTO IA

**Data:** 2026-02-27
**Status:** Problemas Identificados + Soluções Prontas

---

## 📊 O QUE NÃO ESTAVA FUNCIONANDO

### 1. ❌ Calls Antigas Aparecendo
**Problema:** Você vê calls de 15 dias atrás em vez de calls recentes

**Causa Root:** View SQL `vw_god_calls` não filtra por data

```sql
-- ANTES (bugado):
WHERE m.ativo = true AND m.cohort IS DISTINCT FROM 'tese'
-- Retorna TODAS as calls (sem filtro de data)

-- DEPOIS (corrigido):
WHERE m.ativo = true
  AND m.cohort IS DISTINCT FROM 'tese'
  AND cm.data_call >= NOW() - INTERVAL '60 days'
-- Retorna apenas calls dos últimos 60 dias
```

**Solução:** Execute o arquivo `10-FIXES-CALLS-INSTAGRAM.sql` em Supabase SQL Editor

---

### 2. ❌ Instagram Followers Mostrando "-"
**Problema:** Campo `instagram` em cada mentee aparece vazio

**Causa Root:** Dados não preenchidos na tabela `mentorados.instagram`

**Como funciona:**
```
Supabase: mentorados.instagram → vw_god_overview.instagram → Frontend (m.instagram)
                                                              ↓
                                                              igFollowers(m.instagram)
                                                              ↓
                                                              Busca em INSTAGRAM_PROFILES
                                                              ↓
                                                              Se não encontrar → "-"
```

**Solução:** Você precisa preencher em Supabase:
1. Abra: https://app.supabase.com/project/knusqfbvhsqworzyhvip/editor/tableEdit/mentorados
2. Coluna `instagram` — preencha com handles (ex: `draamanda_ribeiro`, `dra_camille_braganca`)
3. Salve

OU execute a query do `10-FIXES-CALLS-INSTAGRAM.sql` para ver quem JÁ tem preenchido.

---

### 3. ❌ Contexto IA Mostrando Hardcoded/Errado
**Problema:** "Odontologa em Brasilia-DF. Recém iniciou (Fev 2026)" para TODOS

**Causa Root:** Dados de demo em vez de dados reais do Supabase

**Como funciona:**
```
Supabase: extracoes_agente (agente_tipo='DIAGNOSTICO')
          ↓
          output_json->>'cenario_atual'
          ↓
          vw_god_contexto_ia.cenario_atual
          ↓
          fn_god_mentorado_deep().context_ia
          ↓
          Frontend: data.detail.context_ia.cenario_atual
```

**Solução:** Os agentes IA precisam rodar para extrair o contexto:
1. Você precisa ter um agente IA que rode `agente_tipo = 'DIAGNOSTICO'`
2. Esse agente salva o output em `extracoes_agente`
3. A view pega os dados de lá

Se não houver agente rodando, vai ficar vazio/demo.

OU execute a query do arquivo para ver se há contexto IA preenchido.

---

### 4. ❌ Transcrições de Calls Não Aparecem
**Problema:** Botão "Transcrição" não aparece nas calls

**Causa Root:** Campo `calls_mentoria.link_transcricao` vazio

**Como funciona:**
```
Supabase: calls_mentoria.link_transcricao
          ↓
          vw_god_calls.link_transcricao
          ↓
          fn_god_mentorado_deep().last_calls[].link_transcricao
          ↓
          Frontend: x-show="c.transcricao" (só mostra se houver URL)
```

**Solução:** Preencha manualmente em Supabase ou integre com Zoom API:
1. Abra: https://app.supabase.com/project/knusqfbvhsqworzyhvip/editor/tableEdit/calls_mentoria
2. Coluna `link_transcricao` — adicione URLs (ex: link Google Docs com transcrição)
3. Salve

---

## 🛠️ PRÓXIMOS PASSOS

### Passo 1: Corrigir Calls (URGENT)
Execute em Supabase SQL Editor:
```sql
-- Copia o conteúdo de 10-FIXES-CALLS-INSTAGRAM.sql
-- Paste em: https://app.supabase.com/project/knusqfbvhsqworzyhvip/sql/editor
-- Click "Run"
```

Depois recarregue a página — calls agora vão mostrar apenas últimos 60 dias ✅

### Passo 2: Preencher Instagram
Execute esta query PRIMEIRO para diagnosticar:
```sql
SELECT id, nome, instagram FROM mentorados
WHERE ativo = true
ORDER BY nome;
```

Se a coluna `instagram` for NULL ou vazia para muitos:
1. Abra tabela `mentorados` em Supabase
2. Preencha coluna `instagram` com handles reais
3. Exemplos: `draamanda_ribeiro`, `dra_camille_braganca`, `dracarolsampaio`

### Passo 3: Verificar Contexto IA
Execute esta query:
```sql
SELECT mentorado_id, mentorado_nome, cenario_atual
FROM vw_god_contexto_ia
WHERE cenario_atual IS NOT NULL
LIMIT 10;
```

Se retornar vazio:
- Contexto IA vem de `extracoes_agente` com `agente_tipo = 'DIAGNOSTICO'`
- Você precisa ter um agente IA rodando para extrair isso
- Ou preencher manualmente em `extracoes_agente`

### Passo 4: Preencher Transcrições (OPCIONAL)
Se quiser ter transcrições nas calls:
1. Abra tabela `calls_mentoria` em Supabase
2. Preencha coluna `link_transcricao` com URLs (Google Docs, Drive, etc)
3. Links vão aparecer na interface automaticamente

---

## 📋 ESTRUTURA DE DADOS (para referência)

```
TABELAS PRINCIPAIS:
├── mentorados
│   ├── id (INT)
│   ├── nome (TEXT)
│   ├── instagram (TEXT) ← PRECISA PREENCHER
│   ├── email (TEXT)
│   └── ... (50+ colunas)
│
├── calls_mentoria
│   ├── id (INT)
│   ├── mentorado_id (FK)
│   ├── data_call (TIMESTAMP)
│   ├── link_gravacao (TEXT)
│   ├── link_transcricao (TEXT) ← PRECISA PREENCHER
│   └── ...
│
└── extracoes_agente
    ├── mentorado_id (FK)
    ├── agente_tipo (TEXT) ← 'DIAGNOSTICO', 'ESTRATEGIAS', etc
    ├── output_json (JSONB) ← Contém cenario_atual, gargalos, etc
    └── created_at (TIMESTAMP)

VIEWS (derivadas):
├── vw_god_overview (mentorados list — 45 colunas)
├── vw_god_contexto_ia (IA output por mentorado)
├── vw_god_calls (calls com análise IA) ← CORRIGIDA
├── vw_god_tarefas (tasks unificadas)
└── ... (10 views no total)

FUNCTIONS:
└── fn_god_mentorado_deep(id) → JSON completo para detail page
    Retorna:
    {
      profile: { instagram, ... },
      context_ia: { cenario_atual, gargalos, ... },
      last_calls: [{ link_transcricao, resumo, ... }],
      ...
    }
```

---

## ✅ CHECKLIST

- [ ] Execute `10-FIXES-CALLS-INSTAGRAM.sql` em Supabase
- [ ] Recarregue a página — calls agora filtram 60 dias
- [ ] Verifique tabela `mentorados` — preencha coluna `instagram`
- [ ] Recarregue — followers agora devem aparecer
- [ ] Verifique `extracoes_agente` — se há contexto IA (`agente_tipo='DIAGNOSTICO'`)
- [ ] Preencha `calls_mentoria.link_transcricao` (opcional)
- [ ] Recarregue — transcrições agora devem aparecer

---

## 🔗 LINKS ÚTEIS

- Supabase SQL Editor: https://app.supabase.com/project/knusqfbvhsqworzyhvip/sql/editor
- Tabela mentorados: https://app.supabase.com/project/knusqfbvhsqworzyhvip/editor/tableEdit/mentorados
- Tabela calls_mentoria: https://app.supabase.com/project/knusqfbvhsqworzyhvip/editor/tableEdit/calls_mentoria
- Tabela extracoes_agente: https://app.supabase.com/project/knusqfbvhsqworzyhvip/editor/tableEdit/extracoes_agente

---

**Status:** Diagnóstico completo ✅
**Próxima ação:** Execute o SQL em Supabase para corrigir calls
**Tempo estimado:** 5 min para SQL, 10-30 min para preencher dados
