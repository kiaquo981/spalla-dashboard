---
title: "Gestao Avancada de Arquivos"
type: story
status: Draft
priority: P3
epic: arquivos-busca-semantica
sprint: arquivos-frontend
effort: L
created: 2026-03-19
depends_on: ["STORY-5.1", "STORY-5.2", "STORY-5.4"]
---

# Story 5.6 — Gestao Avancada de Arquivos

**Prioridade:** P3 (pode ser postergada para o proximo sprint)
**Esforco:** Grande
**Sprint:** Arquivos & Busca Semantica — Frontend
**Depende de:** Story 5.1, 5.2, 5.4 (todas devem estar concluidas antes desta)

---

## Contexto

Apos o fluxo basico de upload, organizacao e busca estar funcionando (Stories 5.1-5.5), esta story adiciona as operacoes avancadas de gestao: mover arquivos entre mentorados, bulk actions, preview inline, download e tagging manual.

Esta story e a de maior esforco do sprint e pode ser dividida em sub-entregaveis se necessario.

---

## Story

**Como** usuario do Spalla Dashboard,
**quero** gerenciar meus arquivos com operacoes avancadas como mover, editar descricao, selecao multipla e preview,
**para que** eu mantenha o acervo de arquivos organizado e acessivel ao longo do tempo.

---

## Acceptance Criteria

1. **Mover arquivo entre mentorados:** Para cada arquivo na lista, menu de contexto (tres pontos ou right-click) com opcao "Mover para...". Abre modal com autocomplete de mentorado de destino. Ao confirmar, atualiza `entidade_tipo` e `entidade_id` no backend via `PATCH /api/storage/files/{id}`. Feedback visual de sucesso/erro.

2. **Editar descricao do arquivo:** Menu de contexto com opcao "Editar descricao". Abre modal ou inline edit com campo de texto. Salva descricao no campo `descricao` da tabela `sp_arquivos`. Campo opcional — pode ser deixado vazio.

3. **Selecao multipla (bulk actions):**
   - Checkbox em cada item da lista (visivel no hover ou sempre visivel)
   - Barra de acoes de bulk aparece quando >= 1 item selecionado: "X selecionados — [Deletar] [Mover] [Reprocessar]"
   - Deletar bulk: confirmacao com lista dos arquivos a serem deletados (soft delete — campo `deletado_em`)
   - Mover bulk: mesmo modal de "Mover para..." mas aplicado a todos os selecionados
   - Reprocessar bulk: chama `POST /api/storage/reprocess` para cada arquivo selecionado

4. **Download via signed URL:** Para cada arquivo, opcao "Download" no menu de contexto. Chama `GET /api/storage/files/{id}/url` (mesmo endpoint de Story 5.3), recebe signed URL e dispara download via `window.location.href = url` ou `<a download href={url}>`.

5. **Preview inline para imagens:** Para arquivos de categoria Imagem (JPG, PNG, WEBP), opcao "Visualizar" no menu de contexto. Abre modal com `<img>` usando a signed URL. Modal com botoes "Download" e "Fechar".

6. **Preview inline para PDFs:** Para arquivos PDF, opcao "Visualizar" no menu de contexto. Abre modal com `<iframe src={signedUrl}>` ou `<embed>`. Tamanho do modal: 80vw x 80vh. Botoes "Download" e "Fechar".

7. **Tagging manual:** Para cada arquivo, opcao "Tags" no menu de contexto. Abre painel com tags atuais do arquivo e campo para adicionar novas. Tags sao strings livres (ex: "contrato", "call-qualificacao", "urgente"). Salvas no campo `tags` (array) da tabela `sp_arquivos`. Tags existentes aparecem como badges removiveis.

---

## Tasks / Subtasks

- [ ] **Task 1 — Menu de contexto por arquivo (base para ACs 1, 2, 4, 5, 6, 7)**
  - [ ] Implementar menu dropdown por item de arquivo (botao de tres pontos)
  - [ ] Opcoes condicionais: "Visualizar" apenas para imagens e PDFs
  - [ ] Fechar menu ao clicar fora (click outside handler)

- [ ] **Task 2 — Mover arquivo (AC: 1)**
  - [ ] Modal "Mover para..." com autocomplete de mentorado (reutilizar componente de Story 5.1)
  - [ ] Confirmacao antes de mover
  - [ ] Chamada `PATCH /api/storage/files/{id}` com `{ entidade_tipo, entidade_id }`
  - [ ] Apos sucesso, remover arquivo da lista atual (se estava dentro de uma pasta) e exibir toast

- [ ] **Task 3 — Editar descricao (AC: 2)**
  - [ ] Modal simples com `<textarea>` pre-populado com descricao atual
  - [ ] Botoes "Salvar" e "Cancelar"
  - [ ] Chamada `PATCH /api/storage/files/{id}` com `{ descricao }`
  - [ ] Atualizar item na lista local apos sucesso

- [ ] **Task 4 — Checkboxes e barra de bulk actions (AC: 3)**
  - [ ] Adicionar estado `selecionados: []` (array de IDs)
  - [ ] Checkbox em cada item que adiciona/remove ID do array `selecionados`
  - [ ] Barra de bulk renderizada condicionalmente com `x-show="selecionados.length > 0"`
  - [ ] Contador: "X arquivo(s) selecionado(s)"
  - [ ] Botao "Limpar selecao" reseta o array

- [ ] **Task 5 — Bulk delete (AC: 3)**
  - [ ] Modal de confirmacao listando os arquivos a serem deletados
  - [ ] Chamada em loop (ou batch se endpoint suportar) para soft delete
  - [ ] Remover itens deletados da lista local
  - [ ] Toast de confirmacao: "X arquivo(s) deletado(s)"

- [ ] **Task 6 — Bulk mover e reprocessar (AC: 3)**
  - [ ] Bulk mover: mesmo modal de Task 2, mas aplicado em loop para todos os selecionados
  - [ ] Bulk reprocessar: chamar `POST /api/storage/reprocess` para cada ID selecionado
  - [ ] Feedback de progresso para bulk operations (ex: "Movendo 5/8 arquivos...")

- [ ] **Task 7 — Download (AC: 4)**
  - [ ] Handler `downloadArquivo(arquivoId)`: buscar signed URL → disparar download
  - [ ] Para disparar download sem abrir nova aba: criar `<a download>` temporario, clicar e remover

- [ ] **Task 8 — Preview de imagens (AC: 5)**
  - [ ] Modal responsivo com `<img>` centrada, max-width 90vw, max-height 80vh
  - [ ] Botao "X" para fechar, click fora fecha tambem
  - [ ] Botao "Download" dentro do modal

- [ ] **Task 9 — Preview de PDFs (AC: 6)**
  - [ ] Modal com `<iframe src={signedUrl} width="100%" height="100%">`
  - [ ] Tamanho: 80vw x 80vh
  - [ ] Fallback: se iframe nao renderizar, mostrar link "Abrir em nova aba"
  - [ ] Botoes "Download" e "Fechar"

- [ ] **Task 10 — Tagging manual (AC: 7)**
  - [ ] Painel lateral ou modal com lista de tags atuais como badges
  - [ ] Input para digitar nova tag + botao "Adicionar" (ou Enter)
  - [ ] Cada badge tem botao "X" para remover a tag
  - [ ] Auto-save (salvar ao adicionar/remover) ou botao "Salvar"
  - [ ] Chamada `PATCH /api/storage/files/{id}` com `{ tags: ['tag1', 'tag2'] }`

---

## Dev Notes

### Endpoint de update de arquivo
Verificar se existe endpoint `PATCH /api/storage/files/{id}` ou se precisa ser criado. Se nao existir, este e um requisito de backend para esta story. Considerar criar via Supabase client diretamente:
```javascript
const { error } = await this.supabase
  .from('sp_arquivos')
  .update({ entidade_tipo, entidade_id, descricao, tags })
  .eq('id', arquivoId);
```
Verificar se as RLS policies permitem update pelo usuario logado.

### Soft delete
O delete nao remove o registro — apenas marca como deletado:
```javascript
await this.supabase
  .from('sp_arquivos')
  .update({ deletado_em: new Date().toISOString() })
  .eq('id', arquivoId);
```
A view ou query de listagem deve filtrar `deletado_em IS NULL`.

### Preview de PDF — consideracoes
- Alguns navegadores bloqueiam iframes com PDFs de signed URLs por politica de seguranca (X-Frame-Options ou Content-Security-Policy)
- Testar com um PDF real antes de implementar — pode precisar de abordagem alternativa (PDF.js ou simplesmente link para abrir em nova aba)

### Campo tags no banco
Verificar se `sp_arquivos.tags` e do tipo `text[]` (array PostgreSQL). Se for, o update via Supabase JS e:
```javascript
.update({ tags: ['tag1', 'tag2'] })
```
Se o campo nao existir, sera necessaria uma migration simples para adicionar `tags text[] DEFAULT '{}'`.

### Bulk operations — UX
Para bulk com muitos itens, considerar feedback progressivo ao inves de esperar tudo terminar:
- Mostrar "Processando X de Y arquivos..."
- Itens processados somem da lista em tempo real
- Toast final com resumo ("X movidos, Y com erro")

### Priorizacao interna (se precisar cortar escopo)
Ordem de prioridade caso o sprint nao comporte tudo:
1. Task 1 (menu de contexto) — base para tudo
2. Task 4 + 5 (checkboxes + bulk delete)
3. Task 7 (download) — muito solicitado pelos usuarios
4. Task 8 (preview imagens)
5. Task 2 (mover arquivo)
6. Task 9 (preview PDF) — pode ter limitacoes tecnicas
7. Task 10 (tagging) — nice to have
8. Task 3 (editar descricao)

### Testing
- Testar mover arquivo de mentorado A para mentorado B e verificar que some da pasta A e aparece na pasta B
- Testar selecao multipla com bulk delete (confirmar soft delete, nao hard delete)
- Testar download funciona sem abrir nova aba
- Testar preview de imagem com diferentes formatos (JPG, PNG)
- Testar preview de PDF — documentar se funciona ou nao em cada navegador principal
- Testar adicionar e remover tags — verificar persistencia

---

## Definition of Done

- [ ] Menu de contexto (tres pontos) funcional em cada arquivo
- [ ] Mover arquivo entre mentorados com modal e feedback
- [ ] Checkboxes com barra de bulk actions (deletar, mover, reprocessar)
- [ ] Download via signed URL funcionando
- [ ] Preview inline de imagens em modal
- [ ] Preview inline de PDFs (ou fallback documentado se nao suportado pelo browser)
- [ ] Adicionar e remover tags com persistencia no banco
- [ ] Edicao de descricao funcional
- [ ] Nenhum hard delete — apenas soft delete com campo `deletado_em`

---

## Notas de Priorizacao

Esta story tem o maior esforco do sprint. Dependendo da velocidade das Stories 5.1-5.5, pode ser necessario:
- Entregar apenas um subset das funcionalidades (ver "Priorizacao interna" em Dev Notes)
- Mover a story completa para o proximo sprint
- Dividir em Story 5.6a (bulk + download) e Story 5.6b (preview + tags)

Decisao fica com o lead do sprint.

---

## Change Log

| Data | Versao | Descricao | Autor |
|------|--------|-----------|-------|
| 2026-03-19 | 1.0 | Story criada | River (@sm) |
