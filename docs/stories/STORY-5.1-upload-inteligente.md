---
title: "Upload Inteligente com Contexto"
type: story
status: Draft
priority: P0
epic: arquivos-busca-semantica
sprint: arquivos-frontend
effort: M
created: 2026-03-19
depends_on: []
---

# Story 5.1 — Upload Inteligente com Contexto

**Prioridade:** P0 (blocker para todas as outras stories do sprint)
**Esforco:** Medio
**Sprint:** Arquivos & Busca Semantica — Frontend

---

## Contexto

A aba "Arquivos" atual envia todos os uploads como entidade `geral`, sem associar ao mentorado ou tipo de contexto correto. O backend ja suporta o modelo polimórfico (`entidade_tipo` + `entidade_id`) — falta apenas o frontend expor esse contexto ao usuario no momento do upload.

O endpoint `POST /api/storage/process` ja recebe `entidade_tipo` e `entidade_id` no body. A lista de 42 mentorados pode ser obtida via `this.supabase.from('sp_mentorados').select('id, nome')` (ou view equivalente).

---

## Story

**Como** usuario do Spalla Dashboard,
**quero** selecionar para qual mentorado e qual tipo de entidade estou fazendo upload,
**para que** os arquivos sejam indexados e recuperados com o contexto correto na busca semantica.

---

## Acceptance Criteria

1. **Seletor de mentorado (autocomplete):** Campo de busca/autocomplete que lista os 42 mentorados ativos. Busca por nome (debounce 300ms). Campo opcional — quando vazio, `entidade_tipo='geral'` e `entidade_id=null`.

2. **Seletor de tipo de entidade:** Dropdown com opcoes: `mentorado`, `dossie_doc`, `dossie_producao`, `plano_acao`, `call`, `task`, `geral`. Quando mentorado selecionado, default automatico para `mentorado`.

3. **Preenchimento automatico de entidade_id:** Ao selecionar um mentorado no autocomplete, `entidade_id` e preenchido automaticamente com o UUID do mentorado. Usuario nao precisa inserir ID manualmente.

4. **Seletor de call (condicional):** Quando `entidade_tipo='call'` e mentorado selecionado, exibir dropdown adicional listando as calls existentes daquele mentorado (`sp_calls` ou equivalente). O ID da call vira o `entidade_id`.

5. **Drag-and-drop zone:** Area visual de drag-and-drop (alem do botao "Escolher arquivo") que aceita arrastar arquivos. Feedback visual ao arrastar sobre a zona (highlight/border change).

6. **Upload multiplo com progress por arquivo:** Permitir selecionar ou arrastar multiplos arquivos simultaneamente. Para cada arquivo, exibir barra de progresso individual (0-100%). O upload e feito sequencialmente ou em paralelo (decisao do dev — documentar choice).

7. **Validacao visual de tipos aceitos:** Exibir lista dos formatos suportados (PDF, DOCX, XLSX, CSV, MD, TXT, MP3, MP4, JPG, PNG) proxima a zona de upload. Arquivos com formato nao suportado devem ser rejeitados com mensagem de erro antes de qualquer upload.

8. **Payload correto no POST:** O body enviado para `POST /api/storage/process` deve incluir `entidade_tipo` e `entidade_id` conforme selecao do usuario. Verificar no Network tab que os valores chegam corretos.

---

## Tasks / Subtasks

- [ ] **Task 1 — Autocomplete de mentorados (AC: 1, 3)**
  - [ ] Criar funcao `loadMentorados()` que busca `id, nome` da tabela de mentorados via `this.supabase`
  - [ ] Implementar campo de busca com debounce 300ms filtrando a lista local
  - [ ] Ao selecionar, armazenar `{ id, nome }` no estado do componente de upload
  - [ ] Ao limpar selecao, resetar `entidade_tipo` para `geral` e `entidade_id` para null

- [ ] **Task 2 — Dropdown de tipo de entidade (AC: 2)**
  - [ ] Adicionar `<select>` com as 7 opcoes listadas no AC
  - [ ] Logica: ao selecionar mentorado via autocomplete → auto-set tipo para `mentorado`
  - [ ] Logica: ao limpar mentorado → auto-set tipo para `geral`

- [ ] **Task 3 — Seletor condicional de call (AC: 4)**
  - [ ] Quando tipo = `call` E mentorado != null, fazer query em `sp_calls` (ou view relevante) filtrando por `mentorado_id`
  - [ ] Exibir dropdown de calls com data/label identificatorio
  - [ ] Ao selecionar call, sobrescrever `entidade_id` com `call.id`

- [ ] **Task 4 — Drag-and-drop zone (AC: 5)**
  - [ ] Implementar listeners `dragover`, `dragleave`, `drop` na zona de upload
  - [ ] Adicionar classe CSS de highlight durante dragover
  - [ ] Ao drop, extrair `event.dataTransfer.files` e processar igual ao input file

- [ ] **Task 5 — Upload multiplo com progress (AC: 6)**
  - [ ] Modificar handler de upload para aceitar `FileList` (multiplos arquivos)
  - [ ] Para cada arquivo, criar elemento de progress bar no DOM
  - [ ] Usar `XMLHttpRequest` com `upload.onprogress` ou `fetch` com ReadableStream para atualizar progress
  - [ ] Remover elemento de progress apos conclusao (success ou error)

- [ ] **Task 6 — Validacao de tipos (AC: 7)**
  - [ ] Definir array `TIPOS_ACEITOS` com extensoes permitidas
  - [ ] Validar cada arquivo antes do upload: se extensao nao esta na lista, exibir toast de erro e ignorar o arquivo
  - [ ] Exibir lista de formatos suportados proxima a zona de upload (texto ou icones)

- [ ] **Task 7 — Payload e integracao com backend (AC: 8)**
  - [ ] Atualizar funcao de upload para incluir `entidade_tipo` e `entidade_id` no FormData ou body JSON
  - [ ] Testar com Network tab que os valores chegam ao `POST /api/storage/process`
  - [ ] Tratar resposta de erro do backend (ex: tipo nao suportado) com mensagem amigavel

---

## Dev Notes

### Arquitetura Frontend (Spalla)
- Frontend: Alpine.js SPA em `app/frontend/10-APP-index.html` + `11-APP-app.js` + `12-APP-data.js`
- Cliente Supabase: acessivel via `this.supabase` nos componentes Alpine
- API Backend: Railway — endpoints em `/api/storage/`
- Padrao de chamada API: ver exemplos existentes em `11-APP-app.js` (fetch com await)

### Endpoint relevante
```
POST /api/storage/process
Body (multipart/form-data ou JSON conforme implementacao atual):
  - file: <binary>
  - entidade_tipo: 'mentorado' | 'task' | 'dossie_doc' | 'dossie_producao' | 'plano_acao' | 'call' | 'geral'
  - entidade_id: <uuid> | null
```

### Tabelas relevantes
- Mentorados: verificar nome exato da tabela/view em uso (pode ser `sp_mentorados` ou view `vw_mentorados`)
- Calls: verificar tabela `sp_calls` — campo de ligacao com mentorado
- Arquivos: tabela `sp_arquivos` — campos `entidade_tipo` e `entidade_id`

### Notas de UX
- O seletor de mentorado deve ser um input de texto com lista de sugestoes (estilo combobox), nao um select tradicional, pois sao 42 opcoes
- Progress bar por arquivo deve aparecer dentro ou abaixo da zona de drag-and-drop
- Quando um arquivo falha na validacao de tipo, os outros da lista devem continuar o upload

### Testing
- Testar upload com mentorado selecionado → verificar `entidade_tipo='mentorado'` no payload
- Testar upload sem mentorado → verificar `entidade_tipo='geral'`
- Testar drag-and-drop com multiplos arquivos de tipos mistos (validos e invalidos)
- Testar selecao de call → verificar que `entidade_id` e o ID da call

---

## Definition of Done

- [ ] Seletor de mentorado funciona com busca por nome (autocomplete)
- [ ] Tipo de entidade e preenchido automaticamente ao selecionar mentorado
- [ ] Drag-and-drop aceita arquivos e mostra feedback visual
- [ ] Upload multiplo exibe progress bar individual por arquivo
- [ ] Arquivos com tipo invalido sao rejeitados com mensagem de erro
- [ ] Payload `POST /api/storage/process` inclui `entidade_tipo` e `entidade_id` corretos
- [ ] Call dropdown aparece apenas quando `entidade_tipo='call'` + mentorado selecionado
- [ ] Nenhum erro no console do browser durante upload normal

---

## Change Log

| Data | Versao | Descricao | Autor |
|------|--------|-----------|-------|
| 2026-03-19 | 1.0 | Story criada | River (@sm) |
