---
title: "Spalla E2E Smoke Tests"
type: docs
---

# Spalla E2E Smoke Tests

Testes automatizados que validam cada page do Spalla Dashboard.

## Rodar

```bash
# Com token de acesso (skip login UI)
SPALLA_ACCESS_TOKEN=eyJ... npx playwright test --config tests/e2e/playwright.config.js

# Com email/senha (faz login via form)
SPALLA_EMAIL=kaique@... SPALLA_PASSWORD=... npx playwright test --config tests/e2e/playwright.config.js

# Contra localhost
SPALLA_URL=http://localhost:3000 npx playwright test --config tests/e2e/playwright.config.js
```

## O que valida

| Test | O que verifica |
|------|---------------|
| CC: sem erros | Console não tem erros críticos |
| CC: board | Mentorados aparecem no board |
| CC: sprints | Nenhum sprint duplicado |
| CC: pendências | Msgs da equipe não contam como pendência |
| Tasks: lista | Tasks carregam (count > 0) |
| Tasks: sprints | Sprint 4 tem contagem > 0 |
| Tasks: spaces | Gestão Interna tem tasks |
| Meu Trabalho | Não fica em branco |
| Carteira: cards | Cards de mentorados renderizam |
| Carteira: SLA | SLA não é 0m pra todos |
| Carteira: contato | Último contato não é "Agora" pra todos |
| Carteira: click | Click no card abre ficha |
| Dashboard: KPIs | Números > 0 |
| Feedback: RLS | Sem erro de row-level security |
| WhatsApp: QR | Não pede QR pra user prelinked |
| Matriz: quadrantes | Não está 100% vazia |
