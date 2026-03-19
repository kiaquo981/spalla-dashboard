---
title: "Organizacao por Mentorado — Pastas Virtuais"
type: story
status: Draft
priority: P1
epic: arquivos-busca-semantica
sprint: arquivos-frontend
effort: M
created: 2026-03-19
depends_on: ["STORY-5.1"]
---

# Story 5.2 — Organizacao por Mentorado (Pastas Virtuais)

**Prioridade:** P1
**Esforco:** Medio
**Sprint:** Arquivos & Busca Semantica — Frontend
**Depende de:** Story 5.1 (Upload Inteligente com Contexto)

---

## Contexto

Atualmente a pagina de Arquivos exibe uma lista plana de todos os uploads sem organizacao. Com o modelo polimórfico funcionando (apos Story 5.1), os arquivos passam a ter `entidade_tipo` e `entidade_id` — o que permite agrupar por mentorado.

O banco ja possui a view `vw_arquivos_por_mentorado` que agrega contagem e tamanho por mentorado. A Story 5.2 constroi a camada de navegacao visual sobre essa view.

---

## Story

**Como** usuario do Spalla Dashboard,
**quero** visualizar os arquivos organizados por mentorado em um grid de cards (pastas virtuais),
**para que** eu encontre rapidamente os arquivos de um mentorado especifico sem ter que filtrar manualmente.

---

## Acceptance Criteria

1. **View de pastas — grid de cards:** A pagina de Arquivos tem um novo modo de visualizacao "Por Mentorado" (pode ser a view default). Exibe um grid de cards onde cada card representa um mentorado que possui ao menos 1 arquivo. Inclui um card especial "Geral" para arquivos sem mentorado associado.

2. **Card de mentorado:** Cada card exibe: nome do mentorado, badge com total de arquivos (ex: "12 arquivos"), badge com tamanho total (ex: "45 MB"). Fonte de dados: `vw_arquivos_por_mentorado`.

3. **Navegacao para arquivos do mentorado:** Ao clicar no card de um mentorado, a view muda para exibir os arquivos daquele mentorado agrupados por categoria: Documentos (PDF, DOCX, MD, TXT), Planilhas (XLSX, CSV), Audios (MP3, WAV, etc), Videos (MP4, etc), Imagens (JPG, PNG, etc).

4. **Breadcrumb de navegacao:** Ao entrar na view de arquivos de um mentorado, exibir breadcrumb: "Arquivos > [Nome do Mentorado]". Clicar em "Arquivos" volta para o grid de cards.

5. **Atalho de upload direto:** Dentro da view de arquivos de um mentorado, exibir botao "Upload" que abre o modal/formulario de upload ja com o mentorado pre-selecionado (campos `entidade_tipo='mentorado'` e `entidade_id` ja preenchidos).

6. **Card "Geral":** Sempre presente no grid, exibe contagem e tamanho dos arquivos com `entidade_tipo='geral'` ou `entidade_id=null`. Ao clicar, mostra esses arquivos sem agrupamento por categoria.

7. **Grupos por categoria:** Dentro da view de um mentorado, as categorias sao exibidas como secoes colapsaveis (ou abas). Categorias sem arquivos podem ser omitidas ou exibidas vazias — decisao do dev.

8. **Dados via `vw_arquivos_por_mentorado`:** A query de resumo (total de arquivos e MB por mentorado) usa a view `vw_arquivos_por_mentorado`. Para listar arquivos individuais dentro de um mentorado, filtrar `sp_arquivos` por `entidade_id = mentorado.id`.

---

## Tasks / Subtasks

- [ ] **Task 1 — Query e estado da view (AC: 1, 2, 8)**
  - [ ] Criar funcao `loadArquivosPorMentorado()` que faz query em `vw_arquivos_por_mentorado`
  - [ ] Armazenar resultado no state do componente Alpine da pagina de Arquivos
  - [ ] Incluir query separada para arquivos "Geral" (sem mentorado)

- [ ] **Task 2 — Grid de cards de mentorado (AC: 1, 2, 6)**
  - [ ] Renderizar grid CSS (3-4 colunas em desktop, 2 em tablet, 1 em mobile)
  - [ ] Cada card: nome, badge de contagem, badge de tamanho total formatado (KB/MB)
  - [ ] Card "Geral" com icone distinto (pasta ou caixa)
  - [ ] Estado vazio: mensagem quando nenhum arquivo existe

- [ ] **Task 3 — Navegacao para view de mentorado (AC: 3, 4)**
  - [ ] Implementar navegacao via state (nao rota nova): `{ view: 'mentorado', mentoradoId, mentoradoNome }`
  - [ ] Funcao `abrirMentorado(mentorado)` que altera state e dispara query de arquivos do mentorado
  - [ ] Breadcrumb renderizado condicionalmente: aparece apenas quando `view === 'mentorado'`
  - [ ] Botao/link "Arquivos" no breadcrumb chama `voltarParaGrid()`

- [ ] **Task 4 — Agrupamento por categoria (AC: 3, 7)**
  - [ ] Definir mapa de extensao → categoria
  - [ ] Apos carregar arquivos do mentorado, agrupar por categoria
  - [ ] Renderizar secoes colapsaveis (x-show com toggle) ou abas por categoria
  - [ ] Cada arquivo na lista: nome, tamanho, data de upload, status de processamento (icone)

- [ ] **Task 5 — Atalho de upload no contexto do mentorado (AC: 5)**
  - [ ] Botao "Upload" na view de mentorado chama o modal/componente de upload de Story 5.1
  - [ ] Passar `mentoradoId` e `mentoradoNome` como props/parametros pre-preenchidos
  - [ ] Apos upload concluido, recarregar a lista de arquivos do mentorado atual

---

## Dev Notes

### View SQL disponivel
```sql
-- vw_arquivos_por_mentorado (ja existe no banco)
-- Colunas esperadas: mentorado_id, mentorado_nome, total_arquivos, total_bytes
-- Confirmar nome exato das colunas antes de usar
SELECT * FROM vw_arquivos_por_mentorado;
```

### Mapa de categorias sugerido
```javascript
const CATEGORIA_MAP = {
  pdf: 'Documentos', docx: 'Documentos', md: 'Documentos', txt: 'Documentos',
  xlsx: 'Planilhas', csv: 'Planilhas',
  mp3: 'Audios', wav: 'Audios', m4a: 'Audios',
  mp4: 'Videos', mov: 'Videos',
  jpg: 'Imagens', jpeg: 'Imagens', png: 'Imagens', webp: 'Imagens'
};
```

### Navegacao por state (sem rota)
O Spalla usa Alpine.js SPA. A navegacao entre views e feita alterando variaveis de state, nao mudando a URL. Verificar como as outras paginas (ex: detalhe de mentorado) implementam essa troca de view para manter consistencia.

### Formatacao de tamanho
- < 1024 bytes → "X bytes"
- < 1MB → "X KB"
- >= 1MB → "X.X MB"

### Dependencia de Story 5.1
Esta story depende que o upload com contexto (5.1) esteja funcionando para que os arquivos cheguem com `entidade_tipo='mentorado'` correto. Em desenvolvimento, pode usar dados de seed/fixture para testar o grid sem depender do 5.1 completo.

### Testing
- Testar grid com 0, 1 e varios mentorados
- Testar card "Geral" com e sem arquivos
- Verificar que o breadcrumb exibe corretamente e a navegacao de volta funciona
- Verificar que o atalho de upload pre-preenche o mentorado corretamente
- Testar agrupamento por categoria com arquivos de tipos mistos

---

## Definition of Done

- [ ] Grid de cards exibe todos os mentorados com arquivos + card "Geral"
- [ ] Cada card mostra contagem de arquivos e tamanho total formatado
- [ ] Clicar no card navega para view de arquivos do mentorado com breadcrumb
- [ ] Arquivos sao agrupados por categoria (Documentos, Planilhas, Audios, Videos, Imagens)
- [ ] Botao de upload dentro da view do mentorado pre-preenche o mentorado
- [ ] Navegacao de volta para grid funciona via breadcrumb
- [ ] View responsiva (funciona em telas menores)

---

## Change Log

| Data | Versao | Descricao | Autor |
|------|--------|-----------|-------|
| 2026-03-19 | 1.0 | Story criada | River (@sm) |
