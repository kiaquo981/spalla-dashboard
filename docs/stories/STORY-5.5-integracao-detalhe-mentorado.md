---
title: "Integracao com Detalhe do Mentorado"
type: story
status: Draft
priority: P2
epic: arquivos-busca-semantica
sprint: arquivos-frontend
effort: M
created: 2026-03-19
depends_on: ["STORY-5.1", "STORY-5.3"]
---

# Story 5.5 — Integracao com Detalhe do Mentorado

**Prioridade:** P2
**Esforco:** Medio
**Sprint:** Arquivos & Busca Semantica — Frontend
**Depende de:** Story 5.1 (upload com contexto), Story 5.3 (busca semantica avancada)

---

## Contexto

A pagina de detalhe do mentorado (page 'detail' no Spalla) ja exibe calls, tarefas e outras informacoes. Adicionar uma tab/secao de "Arquivos" nessa pagina cria uma experiencia unificada onde o usuario nao precisa sair do contexto do mentorado para ver ou fazer upload de seus arquivos.

Alem disso, o card do mentorado no dashboard principal pode exibir a contagem de arquivos como indicador de completude do dossiê digital.

---

## Story

**Como** usuario do Spalla Dashboard,
**quero** ver e gerenciar os arquivos do mentorado diretamente na pagina de detalhe dele,
**para que** eu nao precise ir para a aba separada de Arquivos para fazer upload ou buscar documentos de um mentorado especifico.

---

## Acceptance Criteria

1. **Tab/Secao "Arquivos" na page de detalhe:** Na pagina de detalhe do mentorado, adicionar uma aba ou secao "Arquivos". O posicionamento (aba nova, secao expandivel, ou painel lateral) deve seguir o padrao visual existente na pagina de detalhe — decisao do dev com base no layout atual.

2. **Lista de arquivos do mentorado:** A secao exibe os arquivos com `entidade_id = mentorado.id` (ou `entidade_tipo='mentorado'` + `entidade_id`). Colunas: nome do arquivo, categoria (icone), tamanho, data de upload, status de processamento (icone reativo, reutilizando logica de Story 5.4).

3. **Upload direto na page de detalhe:** Botao "Upload" dentro da secao de arquivos que abre o formulario/modal de upload (Story 5.1) com o mentorado ja pre-selecionado e o campo bloqueado (usuario nao pode trocar o mentorado neste contexto).

4. **Mini busca semantica scoped:** Campo de busca dentro da secao de Arquivos do detalhe do mentorado. Ao buscar, chama `POST /api/storage/search` com `entidade_id = mentorado.id` automaticamente. Exibe resultados simplificados (sem filtros adicionais, sem score visual elaborado — apenas lista de chunks com nome do arquivo).

5. **Contagem de arquivos no card do mentorado:** No dashboard principal (grid de cards de mentorados), adicionar badge ou contador numerico indicando o total de arquivos do mentorado. Ex: "📎 12". Usar a view `vw_arquivos_por_mentorado` ou query simples com count.

6. **Navegacao para aba de Arquivos standalone:** Link "Ver todos os arquivos" dentro da secao de arquivos do detalhe que navega para a aba principal de Arquivos, ja com o filtro do mentorado aplicado (equivalente a entrar na pasta virtual de Story 5.2).

---

## Tasks / Subtasks

- [ ] **Task 1 — Identificar estrutura da page de detalhe (AC: 1)**
  - [ ] Ler a implementacao atual da pagina de detalhe em `11-APP-app.js` e `10-APP-index.html`
  - [ ] Identificar como as tabs/secoes existentes sao implementadas (abas Alpine, accordion, etc.)
  - [ ] Decidir o posicionamento da nova secao e documentar a decisao

- [ ] **Task 2 — Query de arquivos do mentorado (AC: 2)**
  - [ ] Criar funcao `loadArquivosDoMentorado(mentoradoId)` que filtra `sp_arquivos` por `entidade_id`
  - [ ] Integrar status realtime (reutilizar subscription de Story 5.4 ou criar nova scoped para este mentorado)
  - [ ] Renderizar lista com icone de categoria, tamanho formatado, data e icone de status

- [ ] **Task 3 — Botao de upload pre-preenchido (AC: 3)**
  - [ ] Botao "Upload" que chama o componente de upload de Story 5.1
  - [ ] Passar `mentoradoId` e `mentoradoNome` como parametros fixos
  - [ ] Campo de mentorado no modal deve estar pre-preenchido e readonly neste contexto
  - [ ] Apos upload, recarregar `loadArquivosDoMentorado()`

- [ ] **Task 4 — Mini busca scoped (AC: 4)**
  - [ ] Campo de texto simples com botao "Buscar"
  - [ ] Ao submeter, chamar `POST /api/storage/search` com `entidade_id = mentorado.id` fixo
  - [ ] Exibir resultados como lista simples: nome do arquivo + trecho do chunk (100 chars)
  - [ ] Loading state simples (ex: texto "Buscando...")

- [ ] **Task 5 — Badge de contagem no card do mentorado (AC: 5)**
  - [ ] Identificar onde os cards de mentorado sao renderizados no dashboard
  - [ ] Adicionar query de contagem de arquivos por mentorado (pode ser batch com `vw_arquivos_por_mentorado`)
  - [ ] Exibir badge/contador no card somente quando count > 0

- [ ] **Task 6 — Link para view standalone (AC: 6)**
  - [ ] Link "Ver todos os arquivos" que navega para a aba de Arquivos
  - [ ] Ao navegar, pre-aplicar o filtro/pasta do mentorado (comunicacao entre views via state global ou URL param)

---

## Dev Notes

### Investigacao necessaria antes de implementar
Esta story requer leitura do codigo existente da page de detalhe do mentorado antes de qualquer implementacao. O dev deve:
1. Encontrar onde a pagina de detalhe e renderizada em `10-APP-index.html`
2. Entender como as tabs/secoes existentes sao controladas em `11-APP-app.js`
3. Identificar o state que contem `mentoradoAtual.id` para uso nas queries

### Reutilizacao de componentes (Story 5.1 + 5.4)
- O formulario de upload de Story 5.1 deve ser componentizado para poder ser chamado de multiplos contextos (pagina de Arquivos + pagina de detalhe)
- A logica de icones de status de Story 5.4 deve ser uma funcao/helper reutilizavel

### Query de contagem (Task 5)
Para nao fazer N queries individuais para cada card de mentorado, fazer uma query batch:
```javascript
// Opção 1: usar vw_arquivos_por_mentorado (ja agrega)
const { data } = await this.supabase
  .from('vw_arquivos_por_mentorado')
  .select('mentorado_id, total_arquivos');

// Montar map: { [mentorado_id]: total_arquivos }
// Usar no render dos cards
```

### Mini busca vs busca completa
A mini busca na page de detalhe e intencionalmente simplificada — sem filtros de categoria/periodo, sem score visual, sem botoes de acao elaborados. O objetivo e uma busca rapida no contexto. Para uma busca mais completa, o usuario vai para a aba de Arquivos via o link "Ver todos os arquivos".

### Testing
- Verificar que a secao de Arquivos aparece na page de detalhe com a lista correta
- Fazer upload a partir da page de detalhe e verificar que o arquivo aparece na lista
- Testar mini busca retornando resultados scoped para o mentorado
- Verificar badge de contagem nos cards do dashboard
- Testar link "Ver todos os arquivos" navega para a pasta correta

---

## Definition of Done

- [ ] Secao "Arquivos" visivel na page de detalhe do mentorado
- [ ] Lista de arquivos do mentorado com status reativo
- [ ] Upload da page de detalhe pre-preenche e bloqueia o campo de mentorado
- [ ] Mini busca retorna resultados apenas do mentorado atual
- [ ] Badge de contagem visivel nos cards do dashboard quando count > 0
- [ ] Link "Ver todos os arquivos" navega para pasta correta na aba de Arquivos

---

## Change Log

| Data | Versao | Descricao | Autor |
|------|--------|-----------|-------|
| 2026-03-19 | 1.0 | Story criada | River (@sm) |
