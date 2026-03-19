---
title: "Busca Semantica Avancada"
type: story
status: Draft
priority: P1
epic: arquivos-busca-semantica
sprint: arquivos-frontend
effort: L
created: 2026-03-19
depends_on: ["STORY-5.1"]
---

# Story 5.3 — Busca Semantica Avancada

**Prioridade:** P1
**Esforco:** Grande
**Sprint:** Arquivos & Busca Semantica — Frontend
**Depende de:** Story 5.1 (para arquivos com contexto de mentorado)

---

## Contexto

A barra de busca basica ja existe na aba Arquivos. O backend ja retorna resultados com chunks, scores de relevancia e metadados. O que falta e a camada de UX avancada: filtros por mentorado/categoria/periodo, visualizacao expandida do chunk com highlight, score visual e integracao com a view de pastas (Story 5.2).

Endpoint disponivel: `POST /api/storage/search`
- Parametros: `query`, `mode` ('hybrid'|'semantic'|'keyword'), `entidade_tipo` (opcional), `entidade_id` (opcional), `limit`
- Retorna: array de resultados com `chunk_texto`, `relevance_score`, `arquivo_id`, `arquivo_nome`, `entidade_tipo`, `entidade_id`

---

## Story

**Como** usuario do Spalla Dashboard,
**quero** buscar semanticamente nos arquivos com filtros por mentorado, categoria e periodo,
**para que** eu encontre rapidamente trechos relevantes dentro de qualquer arquivo indexado.

---

## Acceptance Criteria

1. **Barra de busca global sempre visivel:** A barra de busca permanece no topo da pagina de Arquivos em todas as views (grid de cards, view de mentorado). Campo de texto com placeholder "Buscar em todos os arquivos..." (ou "Buscar nos arquivos de [Mentorado]..." quando dentro de uma pasta).

2. **Filtro por mentorado:** Dropdown de mentorado na area de filtros. Quando dentro de uma pasta de mentorado (Story 5.2), este filtro e pre-populado com o mentorado atual. Busca global nao tem mentorado pre-selecionado por padrao.

3. **Filtro por categoria:** Dropdown multi-select com categorias: Documento, Audio, Video, Imagem, Planilha. Mapeado para `entidade_tipo` ou extensao de arquivo conforme o backend suportar.

4. **Filtro de periodo:** Dois campos de data (de / ate) para filtrar por `created_at` do arquivo. Ambos opcionais — sem periodo = sem filtro de data.

5. **Resultados expandidos:** Cada resultado de busca exibe: nome do arquivo, trecho do chunk (os primeiros 200-300 chars), indicador de relevancia. Ao clicar no resultado, expande para mostrar o chunk completo com o trecho que originou o match visualmente destacado (highlight em amarelo ou negrito).

6. **Score de relevancia visual:** Cada resultado exibe um indicador visual do score (ex: barra de progresso de 0-100% ou percentual textual como "87% relevante"). Baseado no campo `relevance_score` retornado pelo backend.

7. **Botoes de acao no resultado:** Cada resultado expandido tem dois botoes: "Abrir arquivo" (gera signed URL via `GET /api/storage/files/{id}/url` e abre em nova aba) e "Ver no mentorado" (navega para a pasta do mentorado correspondente, filtrando para o arquivo).

8. **Busca scoped dentro de pasta:** Quando a busca e disparada dentro de uma pasta de mentorado (Story 5.2), o parametro `entidade_id` do mentorado e automaticamente incluido na requisicao ao `POST /api/storage/search`, restringindo os resultados ao mentorado atual.

9. **Loading state:** Durante o processamento da busca (pode levar 1-3s para busca hibrida com reranking), exibir estado de loading visivel (spinner, skeleton cards ou mensagem "Buscando..."). O botao de busca fica desabilitado durante o loading.

10. **Estado vazio e erros:** Exibir mensagem amigavel quando nenhum resultado e encontrado ("Nenhum resultado para '[query]'"). Exibir mensagem de erro quando a requisicao falha, com botao "Tentar novamente".

---

## Tasks / Subtasks

- [ ] **Task 1 — Refatorar componente de busca (AC: 1)**
  - [ ] Mover a barra de busca para fora do conteudo principal, tornando-a sempre visivel no topo da pagina de Arquivos
  - [ ] Implementar estado `{ query, mode, filtros, resultados, loading, erro }`
  - [ ] Disparar busca no `Enter` ou click no botao (sem busca automatica por digitacao — seria caro)

- [ ] **Task 2 — Painel de filtros (AC: 2, 3, 4)**
  - [ ] Adicionar botao "Filtros" que expande painel colapsavel abaixo da barra de busca
  - [ ] Dropdown de mentorado (mesma logica do autocomplete de Story 5.1)
  - [ ] Dropdown de categoria (checkboxes multi-select)
  - [ ] Inputs de data "De" e "Ate" (tipo `date`)
  - [ ] Botao "Limpar filtros" que reseta todos para default

- [ ] **Task 3 — Integracao com POST /api/storage/search (AC: 2, 3, 4, 8, 9)**
  - [ ] Funcao `executarBusca()` que monta o payload com `query`, `mode`, e filtros ativos
  - [ ] Quando dentro de pasta de mentorado, incluir automaticamente `entidade_id` no payload
  - [ ] Gerenciar estados `loading=true` antes da chamada e `loading=false` apos
  - [ ] Tratar erros HTTP com mensagem amigavel

- [ ] **Task 4 — Renderizacao de resultados com score (AC: 5, 6)**
  - [ ] Renderizar lista de resultados: nome do arquivo, preview de 200 chars do chunk, score visual
  - [ ] Score visual: barra de progresso CSS ou badge colorido (verde > 80%, amarelo 50-80%, cinza < 50%)
  - [ ] Cada item tem botao/link para expandir

- [ ] **Task 5 — Resultado expandido com highlight (AC: 5)**
  - [ ] Toggle de expansao por item (x-show Alpine)
  - [ ] Exibir chunk completo ao expandir
  - [ ] Highlight: identificar o trecho da query dentro do chunk e envolver com `<mark>` ou `<span class="highlight">`
  - [ ] Se backend retornar posicoes do match, usar-las; caso contrario, fazer busca simples pelo termo no texto do chunk

- [ ] **Task 6 — Botoes de acao (AC: 7)**
  - [ ] Botao "Abrir arquivo": chamar `GET /api/storage/files/{arquivo_id}/url`, receber signed URL e abrir em `window.open(url, '_blank')`
  - [ ] Botao "Ver no mentorado": navegar para a pasta do mentorado (Story 5.2) e scrollar/destacar o arquivo correspondente

- [ ] **Task 7 — Estados vazios e erros (AC: 10)**
  - [ ] Mensagem "Nenhum resultado para '[query]'" quando array de resultados vazio
  - [ ] Mensagem de erro com botao "Tentar novamente" em caso de falha HTTP
  - [ ] Estado inicial (sem busca realizada): mensagem de instrucao ("Digite para buscar em todos os arquivos")

---

## Dev Notes

### Endpoint de busca
```
POST /api/storage/search
Headers: Authorization (se necessario — verificar autenticacao atual do backend)
Body (JSON):
{
  "query": "string",
  "mode": "hybrid" | "semantic" | "keyword",
  "entidade_tipo": "mentorado" | ... | null,
  "entidade_id": "uuid" | null,
  "limit": 10,
  "data_inicio": "2026-01-01" | null,
  "data_fim": "2026-03-19" | null
}

Response (array):
[{
  "arquivo_id": "uuid",
  "arquivo_nome": "nome.pdf",
  "entidade_tipo": "mentorado",
  "entidade_id": "uuid",
  "chunk_texto": "trecho extraido...",
  "relevance_score": 0.87,
  "chunk_index": 3
}]
```
Verificar campos exatos no backend antes de implementar.

### Endpoint de signed URL
```
GET /api/storage/files/{arquivo_id}/url
Response: { "url": "https://..." }
```

### Highlight de termos
Approach simples (sem posicoes do backend):
```javascript
function highlightQuery(texto, query) {
  const terms = query.split(' ').filter(t => t.length > 2);
  let result = texto;
  terms.forEach(term => {
    const regex = new RegExp(`(${term})`, 'gi');
    result = result.replace(regex, '<mark>$1</mark>');
  });
  return result;
}
```
Usar `x-html` no Alpine para renderizar o HTML com a tag `<mark>`.

### Performance
- Busca hibrida com Voyage AI reranking pode levar 2-4s — o loading state e critico para UX
- Nao implementar busca em tempo real (ao digitar) — apenas ao submit
- Limitar resultados a 10-15 por busca (parametro `limit`)

### Testing
- Testar busca global (sem filtros) retorna resultados de todos os mentorados
- Testar busca com filtro de mentorado retorna apenas arquivos daquele mentorado
- Testar busca dentro de pasta de mentorado (Story 5.2) auto-filtra pelo mentorado
- Testar click em "Abrir arquivo" abre em nova aba
- Testar loading state visivel durante busca lenta (simular com `await new Promise(r => setTimeout(r, 3000))`)
- Testar estado vazio com query sem resultados

---

## Definition of Done

- [ ] Barra de busca sempre visivel no topo da pagina de Arquivos
- [ ] Filtros de mentorado, categoria e periodo funcionando
- [ ] Resultados exibem score de relevancia visual
- [ ] Click no resultado expande chunk completo com highlight
- [ ] "Abrir arquivo" gera signed URL e abre em nova aba
- [ ] "Ver no mentorado" navega para a pasta correta
- [ ] Busca dentro de pasta de mentorado auto-filtra pelo mentorado
- [ ] Loading state visivel durante processamento
- [ ] Estado vazio e erros com mensagens amigaveis

---

## Change Log

| Data | Versao | Descricao | Autor |
|------|--------|-----------|-------|
| 2026-03-19 | 1.0 | Story criada | River (@sm) |
