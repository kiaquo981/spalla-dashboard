# N8N Safety Net Patches — Scraper v34

JSONs prontos para importar no N8N (Ctrl+V no canvas).

## Arquitetura do Pipeline (real, mapeada do v34)

```
Merge → Classificar e Enriquecer Completo (GPT) → Salvar Interação (INSERT)
                                                          │
                                            ┌─────────────┼──────────────────┐
                                            ↓             ↓                  ↓
                               [PATCH] Detector    É Msg Equipe?    Classificar Grupo
                                  Tipo Msg              ↓                    ↓
                                     ↓           Buscar Dúvidas     Switch Categoria
                            [PATCH] Switch           ...                  ...
                              Roteamento
                                  ↓
                          [PATCH] Buscar Pendentes ...
```

## Onde Entram os Safety Nets

### Cenário 1 — Safety antes do Salvar Interação

Os fallbacks `eh_equipe` e `requer_resposta` devem rodar ENTRE
o `Classificar e Enriquecer Completo` e o `Salvar Interação`,
pra garantir que os campos nunca chegam null no INSERT.

```
ANTES:
  Classificar e Enriquecer ────→ Salvar Interação

DEPOIS:
  Classificar e Enriquecer ──→ [SAFETY] Fallback eh_equipe
                                        ↓
                               [SAFETY] Fallback requer_resposta
                                        ↓
                               Salvar Interação
```

**Se o GPT do "Classificar e Enriquecer" falhar:**
```
  Classificar e Enriquecer ──ERRO──→ [SAFETY] GPT Fallback Classifier
                                              ↓
                                     [SAFETY] Fallback eh_equipe
                                              ↓
                                     [SAFETY] Fallback requer_resposta
                                              ↓
                                     Salvar Interação
```

### Cenário 2 — DLQ se o Salvar Interação falhar

```
  Salvar Interação ──ERRO──→ [SAFETY] Error → Preparar DLQ
                                       ↓
                             [SAFETY] INSERT DLQ (Postgres)
```

## Patches

| Arquivo | Node Type | Onde conectar |
|---|---|---|
| `patch-gpt-fallback-classifier.json` | Code | Error output do "Classificar e Enriquecer Completo" |
| `patch-fallback-eh-equipe.json` | Code | Entre "Classificar e Enriquecer" (ou GPT Fallback) e "Salvar Interação" |
| `patch-fallback-requer-resposta.json` | Code | Entre "Fallback eh_equipe" e "Salvar Interação" |
| `patch-save-error-to-dlq.json` | Code + Postgres | Error output do "Salvar Interação" (2 nodes já conectados) |

## Como Importar

1. Abrir "Sistema de Gestão de Whatsapp - Scraper v34" no N8N
2. Copiar o conteúdo JSON do patch
3. No canvas do N8N: Ctrl+V (cola os nodes)
4. Arrastar para a posição correta
5. Conectar as setas conforme diagramas acima
6. Salvar workflow

## Passo a Passo

### PATCH 1: GPT Fallback
1. Abrir `patch-gpt-fallback-classifier.json`, copiar conteúdo
2. Ctrl+V no canvas do N8N
3. Clicar no node "Classificar e Enriquecer Completo"
4. Settings → ativar "Error Output" (toggle on)
5. Conectar saída vermelha (Error) → `[SAFETY] GPT Fallback Classifier`

### PATCH 2 + 3: Fallbacks eh_equipe + requer_resposta
1. Colar os 2 JSONs no canvas
2. DESCONECTAR a seta `Classificar e Enriquecer Completo → Salvar Interação`
3. Conectar: `Classificar e Enriquecer (OK)` → `[SAFETY] Fallback eh_equipe`
4. Conectar: `[SAFETY] GPT Fallback` → `[SAFETY] Fallback eh_equipe`
5. Conectar: `[SAFETY] Fallback eh_equipe` → `[SAFETY] Fallback requer_resposta`
6. Conectar: `[SAFETY] Fallback requer_resposta` → `Salvar Interação`

### PATCH 4: DLQ
1. Colar JSON (já contém 2 nodes conectados entre si)
2. Clicar no node "Salvar Interação" (Supabase)
3. Settings → ativar "Error Output"
4. Conectar saída vermelha → `[SAFETY] Error → Preparar DLQ`
