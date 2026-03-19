---
title: "Status de Processamento em Realtime"
type: story
status: Draft
priority: P1
epic: arquivos-busca-semantica
sprint: arquivos-frontend
effort: M
created: 2026-03-19
depends_on: ["STORY-5.1"]
---

# Story 5.4 — Status de Processamento em Realtime

**Prioridade:** P1
**Esforco:** Medio
**Sprint:** Arquivos & Busca Semantica — Frontend
**Depende de:** Story 5.1 (para ter uploads com contexto funcionando)

---

## Contexto

O pipeline de processamento de arquivos no backend e assincrono: upload → extracao de texto → chunking → embedding. Esse processo pode levar de segundos a varios minutos dependendo do tipo e tamanho do arquivo (audio/video com Whisper sao os mais lentos).

O Supabase Realtime esta habilitado na tabela `sp_arquivos`. O campo `status` registra o estado atual do processamento. O frontend precisa exibir esse progresso em tempo real sem que o usuario precise dar refresh.

Estados possiveis em `sp_arquivos.status`: `pendente`, `extraindo`, `chunking`, `embedding`, `concluido`, `erro`.

---

## Story

**Como** usuario do Spalla Dashboard,
**quero** ver o status de processamento dos meus uploads se atualizar em tempo real,
**para que** eu saiba quando um arquivo esta pronto para busca sem precisar recarregar a pagina.

---

## Acceptance Criteria

1. **Supabase Realtime subscription:** Ao abrir a pagina de Arquivos, iniciar subscription no canal Realtime da tabela `sp_arquivos`. Ao sair da pagina, fazer unsubscribe para evitar memory leaks. Usar o cliente `this.supabase` existente.

2. **Icone de status animado por estado:**
   - `pendente` → icone de relogio ou hora (estatico, cor cinza)
   - `extraindo` → icone de documento com spinner (animado, cor azul)
   - `chunking` → icone de tesoura ou divisao (animado, cor azul)
   - `embedding` → icone de cerebro ou vetor (animado, cor roxo)
   - `concluido` → icone de check (estatico, cor verde)
   - `erro` → icone de X ou alerta (estatico, cor vermelho)

3. **Atualizacao automatica da lista:** Quando o Realtime emite um evento de UPDATE em `sp_arquivos`, atualizar o item correspondente na lista sem recarregar toda a pagina. Apenas o item alterado deve piscar/atualizar visualmente (micro-animacao opcional).

4. **Fila de processamento visivel:** Exibir contador no topo da lista: "X arquivo(s) em processamento". Atualizar em tempo real conforme arquivos concluem ou entram na fila. Quando contador e 0, ocultar o banner.

5. **Estimativa de fila (opcional — best effort):** Se possivel determinar quantos arquivos estao na fila antes do atual (status `pendente`), exibir "Posicao na fila: X" ou "Aguardando X arquivo(s)". Se nao for possivel calcular de forma simples, exibir apenas "Em processamento..." sem estimativa.

6. **Botao "Reprocessar":** Para arquivos com `status='erro'`, exibir botao "Reprocessar" ao lado do icone de erro. Ao clicar, chamar `POST /api/storage/reprocess` com o `arquivo_id`. Apos sucesso, status volta para `pendente` e o Realtime atualiza automaticamente.

7. **Toast de conclusao:** Quando um arquivo muda de qualquer status para `concluido`, exibir toast de notificacao: "[nome_arquivo] pronto para busca" com duracao de 4 segundos. Usar o sistema de toast existente no Spalla (verificar implementacao atual em `11-APP-app.js`).

---

## Tasks / Subtasks

- [ ] **Task 1 — Supabase Realtime subscription (AC: 1, 3)**
  - [ ] No `init()` ou `mounted()` do componente de Arquivos, criar subscription:
    ```javascript
    this.realtimeChannel = this.supabase
      .channel('sp_arquivos_changes')
      .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'sp_arquivos' },
          (payload) => this.handleArquivoUpdate(payload.new))
      .subscribe();
    ```
  - [ ] Implementar `handleArquivoUpdate(arquivo)` que encontra o item na lista local e atualiza seu status
  - [ ] No `destroy()` ou ao navegar para fora, chamar `this.supabase.removeChannel(this.realtimeChannel)`

- [ ] **Task 2 — Icones de status animados (AC: 2)**
  - [ ] Definir mapa de status → { icone, cor, animado }
  - [ ] Para icones animados, usar CSS animation (spin) ou SVG animado
  - [ ] Renderizar icone correto em cada item da lista via `x-bind` no Alpine
  - [ ] Adicionar CSS de animacao em `13-APP-styles.css`

- [ ] **Task 3 — Banner de fila (AC: 4, 5)**
  - [ ] Computed property `arquivosEmProcessamento` que filtra a lista por status != 'concluido' e != 'erro'
  - [ ] Renderizar banner condicional: `x-show="arquivosEmProcessamento.length > 0"`
  - [ ] Texto: "X arquivo(s) em processamento" com contagem reativa

- [ ] **Task 4 — Botao Reprocessar (AC: 6)**
  - [ ] Exibir botao apenas quando `arquivo.status === 'erro'`
  - [ ] Handler `reprocessarArquivo(arquivoId)`:
    - Chamar `POST /api/storage/reprocess` com `{ arquivo_id: arquivoId }`
    - Em loading, desabilitar o botao e mostrar spinner
    - Em sucesso, o Realtime deve atualizar o status automaticamente
    - Em erro, exibir toast de erro

- [ ] **Task 5 — Toast de conclusao (AC: 7)**
  - [ ] Dentro de `handleArquivoUpdate`, verificar se novo status e `'concluido'`
  - [ ] Verificar sistema de toast existente no app (procurar por `toast` ou `notification` em `11-APP-app.js`)
  - [ ] Chamar o metodo de toast com mensagem "[nome_arquivo] pronto para busca" e duracao 4000ms
  - [ ] Se nao existir sistema de toast, implementar toast simples com CSS transition

---

## Dev Notes

### Supabase Realtime — padrao de uso
```javascript
// Iniciar subscription
const channel = this.supabase
  .channel('nome-do-canal')
  .on('postgres_changes',
      { event: 'UPDATE', schema: 'public', table: 'sp_arquivos' },
      (payload) => { /* handler */ })
  .subscribe();

// Cancelar subscription (cleanup obrigatorio)
this.supabase.removeChannel(channel);
```
Verificar se o Supabase JS client ja esta inicializado como `this.supabase` no componente ou se precisa de import separado.

### Endpoint de reprocessamento
```
POST /api/storage/reprocess
Body: { "arquivo_id": "uuid" }
Response: { "success": true, "status": "pendente" }
```

### Verificar sistema de toast existente
Antes de criar um novo, verificar se existe alguma funcao `showToast`, `addNotification` ou similar em `11-APP-app.js` ou `12-APP-data.js`. O Spalla pode ter um sistema de notificacoes reutilizavel.

### CSS para animacao de spinner
```css
/* Em 13-APP-styles.css */
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
.icon-spinning {
  animation: spin 1s linear infinite;
}
```

### Importante: filtro por usuario
A subscription Realtime deve receber apenas eventos dos arquivos do usuario logado. Verificar se as RLS policies do Supabase ja filtram automaticamente no canal Realtime ou se precisa adicionar filtro na subscription:
```javascript
.on('postgres_changes',
    { event: 'UPDATE', schema: 'public', table: 'sp_arquivos', filter: `user_id=eq.${userId}` },
    handler)
```

### Memory leak prevention
Alpine.js nao tem lifecycle hooks tao claros quanto Vue/React. Verificar o padrao usado no projeto para cleanup (pode ser `$watch` + `$cleanup` ou evento de navegacao).

### Testing
- Fazer upload de um arquivo e observar os icones mudando em tempo real
- Testar que unsubscribe ocorre ao navegar para outra pagina (verificar no DevTools > Network > WS)
- Testar botao "Reprocessar" em um arquivo com status 'erro' (pode precisar setar manualmente no banco para testar)
- Verificar que o toast aparece quando arquivo muda para 'concluido'
- Testar com multiplos uploads simultaneos — todos devem atualizar independentemente

---

## Definition of Done

- [ ] Subscription Realtime iniciada ao abrir pagina de Arquivos
- [ ] Unsubscribe ocorre ao sair da pagina (sem memory leak)
- [ ] Icone de status correto para cada estado com animacao nos estados intermediarios
- [ ] Banner "X arquivo(s) em processamento" atualiza em tempo real
- [ ] Botao "Reprocessar" visivel para arquivos com erro e funcional
- [ ] Toast exibido quando arquivo muda para `concluido`
- [ ] Lista atualiza automaticamente sem reload da pagina

---

## Change Log

| Data | Versao | Descricao | Autor |
|------|--------|-----------|-------|
| 2026-03-19 | 1.0 | Story criada | River (@sm) |
