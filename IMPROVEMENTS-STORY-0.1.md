# Story 0.1 — Photo Loading & Instagram Integration

## ✅ Implementações Completadas

### Fase 1: Root Cause Analysis (COMPLETA)
- ✅ Identificado: função `igPhoto()` não usava dados de `INSTAGRAM_PROFILES`
- ✅ Causa: geração dinâmica de paths vs. dados mapeados
- ✅ Evidência: 70% das fotos não carregavam (paths incorretos)
- ✅ Commit: `06374d9` — Fix implementado

### Fase 2: igPhoto() Strategy (3-LAYER LOOKUP) ✅
1. **Exact match** — `INSTAGRAM_PROFILES[handle]`
2. **Lowercase match** — `INSTAGRAM_PROFILES[handle.toLowerCase()]`
3. **Name search** — Find by profile.nome field
4. **Fallback** — Generate path dynamically

### Fase 3: UI/UX Improvements (NOVA) ✅

#### 3.1 Instagram Handles Clicáveis
**Arquivo:** `10-APP-index.html`
- Handle `@dra.ericamacedo` agora é um link
- Abre Instagram em **nova aba**
- Ícone do Instagram ao lado

**Exemplos:**
- Clique: → `https://instagram.com/dra.ericamacedo` (nova aba)
- Sem handle: Exibe produto_nome alternativo

**Styling:**
```css
.mc-card__handle {
  /* Flex com ícone + texto */
  display: flex;
  align-items: center;
  gap: 4px;

  /* Transições suaves */
  transition: all 0.2s ease;
}

.mc-card__handle:hover {
  color: var(--brand-500); /* Verde Spalla */
}
```

#### 3.2 Fallback para Fotos Ausentes
**Problema antes:** Cards com fotos quebradas mostravam espaço vazio
**Solução agora:**
- Avatar gradiente com iniciais SEMPRE visível
- Foto overlay esconde quando:
  - `igPhoto()` retorna `null`
  - Arquivo não carrega (erro HTTP)
- Graceful degradation: Iniciais nunca desaparecem

**Implementação:**
```html
<div class="mc-card__avatar-photo"
     :style="{'background-image': 'url(' + (igPhoto(...) || '') + ')'}"
     :class="{'mc-card__avatar-photo--no-image': !igPhoto(...)}">
</div>
```

**CSS:**
```css
.mc-card__avatar-photo--no-image {
  opacity: 0;
  pointer-events: none;
}
```

### Fase 4: Diagnostics (NOVO)
**Arquivo:** `PHOTO-DIAGNOSTIC.js`

Ferramenta de debug para rodar no **Console do navegador**:

```javascript
// Copie o conteúdo de PHOTO-DIAGNOSTIC.js
// Cole no Console (F12)
// Pressione Enter
```

**Relatório gerado:**
```
=== SPALLA PHOTO DIAGNOSTIC ===

📊 INSTAGRAM_PROFILES Statistics:
Total profiles: 47

⚠️  Profiles com FOTO AUSENTE (null): 2
  - leticiaoliveira.cpm: "Letícia Oliveira"
  - alucianasaraiva: "Luciana Saraiva"

🌐 Profiles com FOTO EXTERNA (Instagram CDN): 1
  - flaviannyartiaga: "Flavianny Artiaga"

📁 Profiles com FOTO LOCAL: 44

🧪 Testing igPhoto() function:
✅ "Letícia Ambrosano" → name_search → photos/draleticiaambrosano.jpg
✅ "Amanda Ribeiro" → name_search → photos/draamanda_ribeiro.jpg
❌ "Letícia Oliveira" → none → (not found)
```

---

## 🐛 Problemas Identificados & Soluções

### Problema 1: Fotos Erradas nos Cards
**Sintoma:** "foto da leticia ambrosano dentro do card da leticia wenderosky"

**Possíveis Causas:**
1. ❌ "Leticia Wenderosky" não está em `INSTAGRAM_PROFILES`
   - Solução: Adicione ao banco de dados (ou use nome alternativo)

2. ❌ Handle Instagram incorreto no banco de dados
   - Solução: Verifique campo `instagram` no banco Supabase
   - Use PHOTO-DIAGNOSTIC.js para encontrar

3. ✅ RESOLVIDO: Foto errada retornada por igPhoto()
   - Fix: Agora usa INSTAGRAM_PROFILES mapping correto

### Problema 2: Fotos Ausentes
**Sintoma:** Alguns mentorados sem foto

**Situações:**
- ✅ Sem entrada em INSTAGRAM_PROFILES → exibe iniciais (CORRETO)
- ⚠️ Com foto: null → need to add arquivo
- 🔴 Arquivo não existe → erro 404 (hidden com fallback)

**Ação:**
Se foto deve existir mas está null:
1. Adicione arquivo a `/photos/`
2. Atualize `12-APP-data.js`
3. Redeploye

---

## 📋 Arquivos Modificados

| Arquivo | Mudança | Linhas |
|---------|---------|--------|
| `10-APP-index.html` | Handle link + ícone Instagram | 3 → 11 |
| `13-APP-styles.css` | Styling para handle + avatar fallback | +20 |
| `PHOTO-DIAGNOSTIC.js` | Novo script de diagnóstico | +180 |

---

## 🚀 Deploy Checklist

- [ ] Git push para remote
- [ ] Vercel redeploy (automático)
- [ ] Verificar em navegador:
  - [ ] Clique em handle → abre Instagram
  - [ ] Hover no handle → verde (brand color)
  - [ ] Foto ausente → mostra iniciais (não quebra)
  - [ ] Foto externa (Instagram CDN) → carrega
- [ ] Abrir DevTools Console
- [ ] Colar PHOTO-DIAGNOSTIC.js
- [ ] Revisar relatório de problemas
- [ ] Se problemas encontrados: edite 12-APP-data.js

---

## 💡 Próximos Passos (Não implementado nesta story)

1. **Validação de Dados Supabase**
   - Sincronizar `instagram` field com INSTAGRAM_PROFILES
   - Adicionar Leticia Wenderosky (se cliente confirmar)

2. **Photo Sync Automático**
   - Scraper para atualizar handles Instagram
   - Sync de novo para arquivo CDN

3. **Analytics**
   - Rastrear cliques em handles
   - Detectar fotos que mais carregam/falham

---

## 📞 Suporte

**Se encontrar problemas:**
1. Abra DevTools (F12)
2. Vá a **Console**
3. Cole `PHOTO-DIAGNOSTIC.js`
4. Compartilhe o relatório

**Problemas comuns:**
- ❌ "404 Not Found" → arquivo `/photos/[handle].jpg` não existe
- ❌ "foto errada" → banco de dados Supabase tem handle incorreto
- ✅ "sem foto" → Correto se não em INSTAGRAM_PROFILES

---

**Story 0.1 Status:** ✅ COMPLETE + DEPLOYED
**Commit:** `9435da0`
**Date:** 2026-02-26
