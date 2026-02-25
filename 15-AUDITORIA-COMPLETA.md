# AUDITORIA COMPLETA — CASE Mentorados
**Data:** 2026-02-16 | **Fontes:** Supabase DB + Zoom API + Evolution API (WhatsApp)

---

## RESUMO EXECUTIVO

### Contagem Real de Mentorados

| Categoria | Qtd | Detalhes |
|-----------|-----|----------|
| **Mentorados ativos reais** | **42** | IDs 1-50 + 124-148 (excl. equipe/teste/tese) |
| Batch "Tese" (novo) | 20 | IDs 56-75, cohort=tese, zero dados |
| Merged (duplicatas) | 8 | Nomes com [MERGED→X], ativo=false |
| Inativos | 3 | Daiana Capuci, Thiago Almeida, Juliana Takasu |
| Equipe | 2 | Queila Trizotti (17), Kaique Rodrigues (22) |
| Teste | 1 | "Teste Lapidacao Perfil" (123) |
| **TOTAL na tabela** | **76** | |

### Problemas Criticos

| # | Problema | Severidade | Impacto |
|---|----------|------------|---------|
| 1 | **93% das extracoes_agente sao duplicatas** | CRITICO | 6.761 rows, apenas 495 unicos |
| 2 | **89% dos documentos_plano_acao sao duplicatas** | CRITICO | 843 rows, apenas 91 unicos |
| 3 | **4 grupos WhatsApp com ID errado no DB** | ALTO | Michelle, Tayslara, Karina, Rosalie |
| 4 | **21 calls do Zoom nao importadas no DB** | ALTO | Calls de mentorados recentes |
| 5 | **12 mentorados com data_inicio = 2024-01-01** | MEDIO | Placeholder, nao e data real |
| 6 | **44 "Reuniao Zoom de Queila com Q"** | MEDIO | Calls sem nome, impossivel matchear |
| 7 | **Mannu (id=124): quem e?** | MEDIO | 2.162 msgs, 3 calls, 18 direcoes, 0 extracoes |
| 8 | **Marina Mendes (id=41) ativa mas pediu reembolso** | BAIXO | Deve ser inativada |
| 9 | **Queila + Kaique na tabela de mentorados** | BAIXO | Poluem metricas |

---

## TABELA MASTER — TODOS OS 42 MENTORADOS ATIVOS

### Legenda
- **Calls Zoom**: Total de gravacoes individuais encontradas na API do Zoom
- **Calls DB**: Total de calls na tabela `calls_mentoria`
- **Gap Calls**: Zoom - DB (positivo = faltam no DB, negativo = DB tem mais que Zoom)
- **Msgs DB**: Total de mensagens na tabela `interacoes_mentoria`
- **Grupo Evo**: Grupo existe na Evolution API (WhatsApp ativo)
- **Grupo DB**: Grupo vinculado no campo `grupo_whatsapp_id`
- **Ext. Unicas**: Extracoes de agente IA DEDUPLICADAS (nao o total inflado)
- **Planos Unicos**: Documentos plano de acao DEDUPLICADOS

| ID | Nome | Fase | Risco | Cohort | Data Inicio | Calls Zoom | Calls DB | Gap | Msgs DB | Grupo Evo | Grupo DB | Ext.Un. | Plan.Un. | Marcos | Direcoes | Tar.Eq | Criticidade |
|----|------|------|-------|--------|-------------|------------|----------|-----|---------|-----------|----------|---------|----------|--------|----------|--------|-------------|
| 1 | Danielle Ferreira | validacao | medio | N1 | 2024-01-01* | 0 | 0 | 0 | 1.894 | SIM | SIM | 0 | 0 | 2 | 0 | 5 | MEDIA: 0 calls, data placeholder |
| 2 | Silvane Castro | validacao | baixo | N2 | 2024-01-01* | 3 | 15 | -12 | 1.242 | SIM | SIM | 19 | 2 | 6 | 45 | 3 | BAIXA: DB tem mais calls que Zoom (pre-API?) |
| 3 | Flavianny Artiaga | validacao | medio | - | 2024-01-01* | 1 | 4 | -3 | 203 | SIM | SIM | 0 | 0 | 8 | 32 | 0 | MEDIA: 64 dias sem msg, data placeholder |
| 4 | Paulo Rodrigues | validacao | alto | - | 2024-01-01* | 2 | 0 | +2 | 397 | SIM | SIM | 0 | 0 | 12 | 0 | 0 | ALTA: risco alto, 0 calls DB, 33d sem msg |
| 5 | Raquilaine Pioli | concepcao | medio | N1 | 2024-01-01* | 0 | 4 | -4 | 691 | SIM | SIM | 30 | 5 | 7 | 36 | 9 | BAIXA |
| 6 | Pablo Santos | validacao | baixo | N2 | 2024-01-01* | 7 | 9 | -2 | 911 | SIM | SIM | 6 | 1 | 8 | 54 | 0 | BAIXA: 17d sem msg |
| 7 | Dra Erica Macedo | concepcao | medio | N1 | 2024-01-01* | 3 | 8 | -5 | 682 | SIM | SIM | 24 | 4 | 9 | 34 | 0 | MEDIA: 33d sem msg |
| 8 | Rafael Castro | validacao | medio | N2 | 2024-01-01* | 0 | 1 | -1 | 1.659 | SIM | SIM | 0 | 0 | 5 | 8 | 6 | BAIXA |
| 9 | Juliana Altavilla | concepcao | medio | N2 | 2024-01-01* | 1 | 10 | -9 | 281 | SIM | SIM | 6 | 1 | 2 | 35 | 1 | BAIXA |
| 10 | Luciana Saraiva | onboarding | medio | N2 | 2024-01-01* | 0 | 9 | -9 | 117 | SIM | SIM | 24 | 4 | 0 | 23 | 0 | MEDIA: onboarding ha muito tempo, data placeholder |
| 11 | Flavia Nantes | otimizacao | medio | N2 | 2024-01-01* | 1 | 9 | -8 | 424 | SIM | SIM | 0 | 0 | 4 | 32 | 1 | MEDIA: 12d sem msg, 0 extracoes |
| 13 | Livia Lyra | escala | baixo | - | 2024-01-01* | 3 | 5 | -2 | 2.681 | SIM | SIM | 24 | 4 | 17 | 40 | 36 | BAIXA |
| 30 | Thielly Prado | validacao | medio | N1 | 2025-10-20 | 3 | 8 | -5 | 391 | SIM | SIM | 42 | 7 | 9 | 33 | 7 | BAIXA |
| 31 | Deisy Porto | validacao | baixo | N2 | 2025-10-16 | 0 | 5 | -5 | 592 | SIM | SIM | 36 | 6 | 28 | 13 | 12 | BAIXA |
| 32 | Amanda Ribeiro | validacao | medio | N1 | 2025-10-24 | 0 | 3 | -3 | 1.236 | SIM | SIM | 36 | 6 | 14 | 20 | 20 | BAIXA: 10d sem msg |
| 33 | Lauanne Santos | validacao | medio | N2 | 2025-10-24 | 0 | 10 | -10 | 1.286 | SIM | SIM | 6 | 1 | 8 | 59 | 13 | MEDIA: 11d sem msg |
| 34 | Karine Canabrava | concepcao | CRITICO | N2 | 2025-10-25 | 0 | 10 | -10 | 325 | SIM | SIM | 3 | 0 | 5 | 47 | 1 | **CRITICA: risco critico, 19d sem msg** |
| 36 | Hevellin Felix | validacao | medio | N1 | 2025-10-24 | 6 | 6 | 0 | 343 | SIM | SIM | 6 | 1 | 3 | 36 | 5 | BAIXA: OK |
| 37 | Leticia Ambrosano | validacao | medio | N1 | 2025-10-30 | 7 | 2 | **+5** | 351 | SIM | SIM | 0 | 0 | 5 | 19 | 4 | **ALTA: 5 calls Zoom nao importadas** |
| 38 | Tatiana Clementino | concepcao | medio | N1 | 2025-11-08 | 3 | 5 | -2 | 424 | SIM | SIM | 12 | 2 | 10 | 47 | 16 | MEDIA: 9d sem msg |
| 39 | Maria Spindola | validacao | medio | N1 | 2025-11-07 | 1 | 4 | -3 | 599 | SIM | SIM | 36 | 6 | 9 | 40 | 0 | MEDIA: 33d sem msg |
| 40 | Caroline Bittencourt | concepcao | medio | N1 | 2025-11-07 | 3 | 5 | -2 | 823 | SIM | SIM | 6 | 1 | 8 | 50 | 12 | BAIXA |
| 41 | Marina Mendes | concepcao | ALTO | N1 | 2025-11-07 | 2 | 4 | -2 | 215 | NAO | NAO | 0 | 0 | 3 | 40 | 0 | **INATIVAR: pediu reembolso** |
| 42 | Carolina Sampaio | validacao | medio | - | 2025-11-24 | 2 | 5 | -3 | 350 | SIM | SIM | 6 | 1 | 10 | 48 | 18 | BAIXA |
| 43 | Monica Felici | validacao | baixo | N1 | 2025-11-25 | 2 | 4 | -2 | 188 | NAO | NAO | 0 | 0 | 4 | 39 | 0 | MEDIA: sem grupo WhatsApp, 33d sem msg |
| 44 | Renata Aleixo | validacao | medio | N1 | 2025-11-21 | 7 | 20 | -13 | 112 | SIM | SIM | 3 | 9 | 13 | 190 | 2 | BAIXA: DB tem muitas mais calls (pre-API) |
| 45 | Leticia Oliveira | concepcao | baixo | N1 | 2025-12-01 | 0 | 10 | -10 | 348 | SIM | SIM | 1 | 0 | 5 | 71 | 1 | BAIXA: 17d sem msg |
| 47 | Paula/Anna (Kava) | concepcao | medio | N1 | 2025-12-01 | 2 | 6 | -4 | 431 | SIM | SIM | 42 | 14 | 15 | 58 | 3 | BAIXA |
| 48 | Gustavo Guerra | concepcao | medio | N1 | 2025-12-01 | 4 | 6 | -2 | 422 | SIM | SIM | 30 | 5 | 10 | 30 | 6 | BAIXA |
| 49 | Camille Braganca | validacao | medio | N1 | 2025-12-08 | 2 | 4 | -2 | 380 | NAO | NAO | 36 | 6 | 10 | 40 | 0 | MEDIA: sem grupo Evolution, 33d sem msg |
| 50 | Miriam Alves | validacao | medio | N1 | 2025-12-16 | 4 | 4 | 0 | 770 | SIM | SIM | 12 | 2 | 5 | 40 | 58 | BAIXA: OK |
| 124 | Mannu | onboarding | medio | - | 2025-12-14 | 0 | 3 | -3 | 2.162 | SIM | SIM | 0 | 0 | 0 | 18 | 0 | **VERIFICAR: quem e Mannu?** |
| 132 | Michelle Novelli | concepcao | baixo | - | 2026-01-20 | 1 | 0 | **+1** | 122 | SIM | **ERRADO** | 0 | 0 | 3 | 0 | 0 | **ALTA: grupo DB errado, 1 call falta** |
| 133 | Tayslara Belarmino | onboarding | medio | - | 2026-01-19 | 3 | 2 | **+1** | 11 | SIM | **ERRADO** | 0 | 0 | 2 | 20 | 0 | **ALTA: grupo DB errado, 1 call falta** |
| 135 | Rosalie Torrelio | onboarding | medio | - | 2026-01-20 | 2 | 1 | **+1** | 78 | SIM | **ERRADO** | 0 | 0 | 1 | 10 | 0 | **ALTA: grupo DB errado, 1 call falta** |
| 136 | Karina Cabelino | onboarding | medio | - | 2026-01-27 | 3 | 1 | **+2** | 37 | SIM | **ERRADO** | 0 | 0 | 4 | 10 | 0 | **ALTA: grupo DB errado, 2 calls faltam** |
| 137 | Yara Gomes | concepcao | medio | - | 2026-02-01 | 4 | 2 | **+2** | 140 | SIM | SIM | 0 | 0 | 3 | 20 | 4 | MEDIA: 2 calls faltam |
| 144 | Jordanna Diniz | onboarding | medio | - | 2026-02-01 | 0 | 0 | 0 | 51 | NAO | NAO | 0 | 0 | 0 | 0 | 0 | ALTA: sem grupo, 0 calls, dados minimos |
| 145 | Betina Franciosi | onboarding | medio | - | 2026-02-01 | 4 | 1 | **+3** | 81 | SIM | NAO | 0 | 0 | 0 | 0 | 0 | **ALTA: grupo Evo nao vinculado, 3 calls faltam** |
| 146 | Daniela Morais | onboarding | medio | - | 2026-02-01 | 0 | 0 | 0 | 37 | SIM | NAO | 0 | 0 | 0 | 0 | 0 | MEDIA: grupo Evo nao vinculado |
| 147 | Leticia Wenderoscky | onboarding | medio | - | 2026-02-01 | 0 | 0 | 0 | 10 | NAO | NAO | 0 | 0 | 0 | 0 | 0 | ALTA: sem grupo, 0 calls, 10 msgs |
| 148 | Thiago Kailer | onboarding | medio | - | 2026-02-01 | 4 | 0 | **+4** | 71 | NAO | NAO | 0 | 0 | 0 | 0 | 0 | **ALTA: sem grupo, 4 calls Zoom nao importadas** |

*\* data_inicio = 2024-01-01 e placeholder, nao e real*

---

## DETALHE: PROBLEMAS E ACOES

### 1. DUPLICATAS MASSIVAS (CRITICO)

**extracoes_agente:** 6.761 rows → 495 unicos (**93% duplicatas**)
- Pipeline de IA reprocessa e reinsere sem checar se ja existe
- Pior caso: Paula (id=47) tem 814 extracoes → 42 unicas

**documentos_plano_acao:** 843 rows → 91 unicos (**89% duplicatas**)
- Pior caso: Thielly (id=30) tem 108 planos → 6 unicos (23 duplicatas de um unico plano!)
- Todos duplicados tem `call_id = NULL`

**Acao:** Deduplicar com query SQL:
```sql
-- Identificar duplicatas de planos
DELETE FROM documentos_plano_acao a
USING documentos_plano_acao b
WHERE a.id > b.id
  AND a.mentorado_id = b.mentorado_id
  AND COALESCE(a.call_id::text, '') = COALESCE(b.call_id::text, '')
  AND COALESCE(a.titulo, '') = COALESCE(b.titulo, '')
  AND a.created_at::date = b.created_at::date;
```

### 2. GRUPOS WHATSAPP COM ID ERRADO (ALTO)

O DB tem IDs de grupo que NAO existem na Evolution. O scraper criou IDs falsos durante a importacao manual de ZIPs.

| Mentorado | ID DB (ERRADO) | ID Evolution (CORRETO) | Nome Grupo |
|-----------|----------------|------------------------|------------|
| Michelle Novelli (132) | `12036302e259a88b66@g.us` | `120363423109346723@g.us` | [Case] Michelle Novelli |
| Tayslara Belarmino (133) | `1203635299ed680d76@g.us` | `120363423263106612@g.us` | [Case] Tayslara Belarmino |
| Rosalie Torrelio (135) | `56ae5122543cfe6a9eef2c67dca20008` | `120363405618429117@g.us` | [Case] Rosalie Torrelio |
| Karina Cabelino (136) | `120363e039bc8e58ef@g.us` | `120363422678267967@g.us` | [Case] Dra. Karina Cabelino |

**Acao:**
```sql
UPDATE mentorados SET grupo_whatsapp_id = '120363423109346723@g.us' WHERE id = 132;
UPDATE mentorados SET grupo_whatsapp_id = '120363423263106612@g.us' WHERE id = 133;
UPDATE mentorados SET grupo_whatsapp_id = '120363405618429117@g.us' WHERE id = 135;
UPDATE mentorados SET grupo_whatsapp_id = '120363422678267967@g.us' WHERE id = 136;
```

### 3. GRUPOS NAO VINCULADOS (ALTO)

Grupos existem na Evolution mas mentorado no DB nao tem `grupo_whatsapp_id`:

| Mentorado | ID | Grupo Evolution |
|-----------|-----|-----------------|
| Betina Franciosi | 145 | `120363423537756907@g.us` |
| Daniela Morais | 146 | `120363407759892012@g.us` |

**Acao:**
```sql
UPDATE mentorados SET grupo_whatsapp_id = '120363423537756907@g.us' WHERE id = 145;
UPDATE mentorados SET grupo_whatsapp_id = '120363407759892012@g.us' WHERE id = 146;
```

### 4. MENTORADOS SEM GRUPO (verificar com Queila)

| Mentorado | ID | Notas |
|-----------|-----|-------|
| Marina Mendes | 41 | Pediu reembolso → INATIVAR |
| Monica Felici | 43 | Sem grupo na Evolution — pedir para alguem exportar |
| Camille Braganca | 49 | Sem grupo na Evolution — pedir para alguem exportar |
| Jordanna Diniz | 144 | Nova, sem grupo criado ainda? |
| Leticia Wenderoscky | 147 | Nova, sem grupo criado ainda? |
| Thiago Kailer | 148 | Nova, sem grupo criado ainda? |

### 5. CALLS DO ZOOM NAO IMPORTADAS NO DB

21 calls individuais encontradas no Zoom que NAO estao no `calls_mentoria`:

| Mentorado | ID | Calls Faltando | Datas |
|-----------|-----|----------------|-------|
| Leticia Ambrosano | 37 | 5 | 2025-11-14, 11-26, 12-10, 12-22, 2026-01-26 |
| Thiago Kailer | 148 | 4 | 2026-02-05, 02-09 |
| Betina Franciosi | 145 | 3 | 2026-02-05, 02-13 |
| Paulo Rodrigues | 4 | 2 | 2025-07-01, 07-02 |
| Karina Cabelino | 136 | 2 | 2026-01-29, 02-04 |
| Yara Gomes | 137 | 2 | 2026-01-24, 01-29 (+ 02-11) |
| Michelle Novelli | 132 | 1 | 2026-01-26 |
| Tayslara Belarmino | 133 | 1 | 2026-02-13 |
| Rosalie Torrelio | 135 | 1 | 2026-02-03 |

**Nota importante:** Muitos mentorados tem MAIS calls no DB do que no Zoom. Isso acontece porque:
- Calls anteriores a junho/2025 nao estao no Zoom (periodo antes do Zoom conectado)
- Ou calls foram importadas de transcricoes em disco (nao via API do Zoom)

### 6. CALLS GENERICAS "Reuniao Zoom de Queila com Q" (44 gravacoes)

44 calls no Zoom tem o titulo generico "Reuniao Zoom de Queila com Q" — impossivel saber pra qual mentorado sao sem abrir a transcricao. Podem conter calls individuais de mentorados que aparecem com 0 no cruzamento.

**Acao:** Abrir cada uma e verificar o participante, ou checar o participant list via Zoom API.

### 7. DATA INICIO PLACEHOLDER

12 mentorados com `data_inicio = 2024-01-01` (claramente nao e real):

IDs: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13

**Acao:** Perguntar pra Queila a data real de inicio de cada um, ou inferir da primeira call/msg.

### 8. QUEM E MANNU? (id=124)

- 2.162 mensagens WhatsApp (3o maior volume!)
- 3 calls no DB
- 18 direcionamentos
- 0 extracoes IA, 0 planos, 0 marcos
- Grupo: "Consultoria Mannu" (120363409168506731@g.us)
- data_inicio: 2025-12-14

**Acao:** Confirmar com Queila se e mentorado ativo ou caso especial.

### 9. BATCH TESE (20 mentorados)

20 mentorados com cohort="tese", todos em onboarding, todos com data_inicio=2025-01-21, ZERO dados em todas as tabelas (0 calls, 0 msgs, 0 extracoes, 0 planos, 0 marcos, 0 direcoes).

**Excecao:** Michelle Fonte (id=65) tem 3 calls no DB.

**Acao:** Esses mentorados sao ativos? Precisam de grupos WhatsApp e calls?

---

## TOTAIS POR TABELA (estado atual)

| Tabela | Total | Unicos | Duplicatas |
|--------|-------|--------|------------|
| mentorados | 76 | 76 | 0 (mas 8 merged + 1 teste) |
| calls_mentoria | 212 | - | 2 orfas (Juliana Takasu, inativa) |
| analises_call | 260 | - | 166 conselhos + 94 individuais |
| extracoes_agente | 6.761 | **495** | **6.266 (93%)** |
| documentos_plano_acao | 843 | **91** | **752 (89%)** |
| interacoes_mentoria | 23.748 | - | - |
| marcos_mentorado | 269 | - | - |
| direcionamentos | 1.392 | - | - |
| tarefas_equipe | 264 | - | - |
| tarefas_acordadas | 9 | - | - |
| travas_bloqueios | 28 | - | - |

### Zoom API
| Metrica | Valor |
|---------|-------|
| Total gravacoes | 214 |
| Calls individuais CASE | 90 |
| Calls grupo (conselhos/QAs) | 31 |
| Calls Tese | 5 |
| Calls internas/outras | 88 |
| Calls genericas (sem nome mentorado) | 44 |

### Evolution API (WhatsApp)
| Metrica | Valor |
|---------|-------|
| Total mensagens | 21.173 |
| Total contatos | 1.414 |
| Total chats | 679 |
| Grupos CASE | 37 |
| Grupos teste | 4 |
| Grupos nao-CASE | 4 |

---

## DISTRIBUICAO POR FASE (42 mentorados ativos)

| Fase | Qtd | Mentorados |
|------|-----|------------|
| onboarding | 10 | Betina, Daniela, Jordanna, Karina, Leticia W., Luciana, Mannu, Rosalie, Tayslara, Thiago K. |
| concepcao | 12 | Caroline B., Erica, Gustavo, Juliana A., Karine, Leticia O., Marina, Michelle, Paula/Anna, Raquilaine, Tatiana, Yara |
| validacao | 18 | Amanda, Camille, Carolina S., Danielle, Deisy, Flavianny, Hevellin, Lauanne, Leticia A., Maria S., Miriam, Monica, Pablo, Paulo, Rafael, Renata, Silvane, Thielly |
| otimizacao | 1 | Flavia Nantes |
| escala | 1 | Livia Lyra |

---

## ACOES PRIORIZADAS

### Prioridade 1 — Correcoes Imediatas (SQL, 10min)
1. Corrigir 4 grupo_whatsapp_id errados (Michelle, Tayslara, Rosalie, Karina)
2. Vincular 2 grupos faltantes (Betina, Daniela)
3. Inativar Marina Mendes (ativo=false)

### Prioridade 2 — Deduplicacao (SQL, 30min)
4. Deduplicar extracoes_agente (6.266 duplicatas)
5. Deduplicar documentos_plano_acao (752 duplicatas)
6. Verificar se pipeline de IA tem guard contra reinsercao

### Prioridade 3 — Importar Calls Faltantes (1-2h)
7. Importar 21 calls do Zoom que nao estao no DB
8. Investigar as 44 calls "Reuniao Zoom de Queila com Q"

### Prioridade 4 — Limpeza de Dados (30min)
9. Corrigir data_inicio dos 12 mentorados com placeholder
10. Confirmar quem e Mannu (id=124)
11. Definir status do batch Tese (20 mentorados)

### Prioridade 5 — Mensagens WhatsApp (1h)
12. Criar grupos para Jordanna, Leticia W., Thiago K. (se ativos)
13. Exportar/importar msgs de Monica Felici e Camille Braganca (sem grupo Evolution)
14. Re-importar mensagens mais recentes de grupos defasados

---

## CREDENCIAIS UTILIZADAS

| Servico | Detalhe |
|---------|---------|
| Supabase | knusqfbvhsqworzyhvip.supabase.co / postgres / BekIUq66EhVJ84QB |
| Zoom S2S OAuth | Account: DXq-KNA5QuSpcjG6UeUs0Q / Client: fvNVWKX_SumngWI1kQNhg |
| Zoom Webhook Secret | UNdbNlldQ3-vIyaKNtzsKg |
| Evolution API | evolution.manager01.feynmanproject.com / inst: produ02 / token: 07826A779A5C-4E9C-A978-DBCD5F9E4C97 |
| Evolution Phone | 5511941936764@s.whatsapp.net (Suporte Case) |

---

*Gerado em 2026-02-16 por auditoria cruzada Supabase × Zoom API × Evolution API*
