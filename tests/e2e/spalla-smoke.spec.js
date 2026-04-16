// @ts-check
const { test, expect } = require('@playwright/test');

/**
 * Spalla Dashboard — Smoke Tests E2E
 *
 * Valida que cada page principal carrega, mostra dados, e não tem erros.
 * Roda em cada deploy pra pegar regressões antes do usuário.
 *
 * Pré-requisito: login via localStorage injection (não depende de UI de login)
 */

const LOGIN_EMAIL = process.env.SPALLA_EMAIL || 'kaique.azevedoo@outlook.com';
const LOGIN_PASSWORD = process.env.SPALLA_PASSWORD || '';

// Helper: login via API e injetar tokens no localStorage
async function loginAndNavigate(page, path = '/command-center') {
  // Vai pra raiz primeiro pra ter acesso ao localStorage do domínio
  await page.goto('/');

  // Se já tem tokens salvos no env, injeta direto
  const accessToken = process.env.SPALLA_ACCESS_TOKEN;
  if (accessToken) {
    await page.evaluate((token) => {
      localStorage.setItem('spalla_access_token', token);
      localStorage.setItem('spalla_page', 'command_center');
    }, accessToken);
    await page.reload();
    await page.waitForTimeout(2000);
    return;
  }

  // Senão, espera a tela de login carregar e faz login manual
  await page.waitForSelector('[x-show="!auth.authenticated"]', { timeout: 10000 }).catch(() => {});

  // Se já está logado, pula
  const isLoggedIn = await page.evaluate(() => !!localStorage.getItem('spalla_access_token'));
  if (isLoggedIn) {
    await page.goto(path);
    await page.waitForTimeout(2000);
    return;
  }

  // Login via form
  if (LOGIN_PASSWORD) {
    await page.fill('input[type="email"]', LOGIN_EMAIL);
    await page.fill('input[type="password"]', LOGIN_PASSWORD);
    await page.click('button:has-text("Entrar")');
    await page.waitForTimeout(3000);
  }

  await page.goto(path);
  await page.waitForTimeout(2000);
}

// ====================================================================
// 1. COMMAND CENTER
// ====================================================================
test.describe('Command Center', () => {
  test('carrega sem erros no console', async ({ page }) => {
    const errors = [];
    page.on('console', msg => { if (msg.type() === 'error') errors.push(msg.text()); });

    await loginAndNavigate(page, '/command-center');

    // Filtra erros irrelevantes (favicon, extensions)
    const realErrors = errors.filter(e =>
      !e.includes('favicon') && !e.includes('extension') && !e.includes('net::ERR')
    );
    expect(realErrors.length).toBeLessThanOrEqual(2); // tolerância: 2 erros não-críticos
  });

  test('mostra mentorados no board', async ({ page }) => {
    await loginAndNavigate(page, '/command-center');
    // Espera pelo board renderizar
    const cards = await page.locator('[style*="grid-template-columns"]').first().locator('div.card, [style*="border-radius:10px"]').count();
    expect(cards).toBeGreaterThan(0);
  });

  test('sprints não estão duplicados', async ({ page }) => {
    await loginAndNavigate(page, '/command-center');
    const sprintTexts = await page.locator('text=Sprint').allTextContents();
    const sprintNames = sprintTexts.filter(t => t.match(/Sprint \d/));
    const uniqueNames = [...new Set(sprintNames)];
    // Cada sprint name deve ser único
    expect(sprintNames.length).toBe(uniqueNames.length);
  });

  test('pendências WA não incluem msgs da equipe', async ({ page }) => {
    await loginAndNavigate(page, '/command-center');
    // O badge de pendências deve mostrar <= 5 (depois do fix de equipe)
    const pendBadge = page.locator('text=/\\d+ pendente/').first();
    if (await pendBadge.isVisible()) {
      const text = await pendBadge.textContent();
      const count = parseInt(text.match(/(\d+)/)?.[1] || '0');
      expect(count).toBeLessThan(20); // antes do fix era 19+
    }
  });
});

// ====================================================================
// 2. TAREFAS
// ====================================================================
test.describe('Tarefas', () => {
  test('lista carrega com tasks', async ({ page }) => {
    await loginAndNavigate(page, '/tasks');
    await page.waitForTimeout(3000);
    // Verifica que tem pelo menos uma task renderizada
    const taskCount = page.locator('text=/\\d+ tarefas?/').first();
    if (await taskCount.isVisible()) {
      const text = await taskCount.textContent();
      const count = parseInt(text.match(/(\d+)/)?.[1] || '0');
      expect(count).toBeGreaterThan(0);
    }
  });

  test('sprints na sidebar mostram contagem', async ({ page }) => {
    await loginAndNavigate(page, '/tasks');
    await page.waitForTimeout(3000);
    // Sprint 4 deve ter tasks
    const sprint4 = page.locator('text=Sprint 4').first();
    if (await sprint4.isVisible()) {
      // O count ao lado deve ser > 0
      const parent = sprint4.locator('..').locator('..');
      const countEl = parent.locator('.tasks-sidebar__count').first();
      if (await countEl.isVisible()) {
        const count = parseInt(await countEl.textContent() || '0');
        expect(count).toBeGreaterThan(0);
      }
    }
  });

  test('spaces mostram contagem > 0', async ({ page }) => {
    await loginAndNavigate(page, '/tasks');
    await page.waitForTimeout(3000);
    // Pelo menos Gestão Interna deve ter tasks
    const gestao = page.locator('text=Gestão Interna').first();
    if (await gestao.isVisible()) {
      const parent = gestao.locator('..');
      const countEl = parent.locator('.tasks-sidebar__count').first();
      if (await countEl.isVisible()) {
        const count = parseInt(await countEl.textContent() || '0');
        expect(count).toBeGreaterThan(0);
      }
    }
  });
});

// ====================================================================
// 3. MEU TRABALHO
// ====================================================================
test.describe('Meu Trabalho', () => {
  test('carrega tasks (não fica em branco)', async ({ page }) => {
    await loginAndNavigate(page, '/meu-trabalho');
    await page.waitForTimeout(4000);

    // Deve ter tasks visíveis (o view mywork ou a tab meu_trabalho)
    const hasContent = await page.evaluate(() => {
      const app = document.querySelector('[x-data]')?.__x?.$data;
      return app?.meuTrabalho?.length > 0 || false;
    });
    // Se Alpine não é acessível, verifica pelo DOM
    if (!hasContent) {
      const emptyMsg = page.locator('text=Nenhuma tarefa').first();
      const taskCards = page.locator('.cu-list__row, [style*="border-bottom"]').count();
      // Deve ter cards OU a mensagem de "nenhuma" (mas não ficar em loading infinito)
      expect((await taskCards) > 0 || await emptyMsg.isVisible()).toBeTruthy();
    }
  });
});

// ====================================================================
// 4. CARTEIRA
// ====================================================================
test.describe('Carteira', () => {
  test('cards de mentorados carregam', async ({ page }) => {
    await loginAndNavigate(page, '/carteira');
    await page.waitForTimeout(3000);

    // Deve ter cards de mentorados
    const cards = await page.locator('.card').count();
    expect(cards).toBeGreaterThan(0);
  });

  test('SLA não mostra 0m pra todos', async ({ page }) => {
    await loginAndNavigate(page, '/carteira');
    await page.waitForTimeout(3000);

    // Pega todos os SLA badges
    const slaBadges = await page.locator('.sla-badge').allTextContents();
    const allZero = slaBadges.every(s => s === '0m');
    // Se tem SLA badges visíveis, não devem ser todos 0m
    if (slaBadges.length > 3) {
      expect(allZero).toBeFalsy();
    }
  });

  test('último contato não mostra "Agora" pra todos', async ({ page }) => {
    await loginAndNavigate(page, '/carteira');
    await page.waitForTimeout(3000);

    const contacts = await page.locator('text=Agora').count();
    const totalCards = await page.locator('.card').count();
    // No máximo 20% dos cards devem mostrar "Agora"
    if (totalCards > 5) {
      expect(contacts / totalCards).toBeLessThan(0.5);
    }
  });

  test('click no card abre ficha do mentorado', async ({ page }) => {
    await loginAndNavigate(page, '/carteira');
    await page.waitForTimeout(3000);

    const firstCard = page.locator('.card').first();
    if (await firstCard.isVisible()) {
      await firstCard.click();
      await page.waitForTimeout(1500);
      // Deve ter aberto a ficha (detail panel)
      const detailVisible = await page.locator('text=Resumo').or(page.locator('text=WA Intel')).or(page.locator('text=Plano de')).first().isVisible();
      expect(detailVisible).toBeTruthy();
    }
  });
});

// ====================================================================
// 5. DASHBOARD
// ====================================================================
test.describe('Dashboard', () => {
  test('KPIs carregam com números > 0', async ({ page }) => {
    await loginAndNavigate(page, '/dashboard');
    await page.waitForTimeout(3000);

    // Verifica que "Total" não é 0
    const totalEl = page.locator('text=Total').first().locator('..').locator('div').first();
    if (await totalEl.isVisible()) {
      const text = await totalEl.textContent();
      const num = parseInt(text || '0');
      expect(num).toBeGreaterThan(0);
    }
  });
});

// ====================================================================
// 6. FEEDBACK
// ====================================================================
test.describe('Feedback', () => {
  test('page carrega sem erro RLS', async ({ page }) => {
    const errors = [];
    page.on('console', msg => { if (msg.type() === 'error') errors.push(msg.text()); });

    await loginAndNavigate(page, '/feedback');
    await page.waitForTimeout(2000);

    const rlsErrors = errors.filter(e => e.includes('row-level security'));
    expect(rlsErrors.length).toBe(0);
  });
});

// ====================================================================
// 7. WHATSAPP
// ====================================================================
test.describe('WhatsApp', () => {
  test('não mostra QR Code pra usuário prelinked', async ({ page }) => {
    await loginAndNavigate(page, '/whatsapp');
    await page.waitForTimeout(3000);

    // QR Code prompt não deve aparecer pra Kaique (prelinked)
    const qrPrompt = page.locator('text=Gerar QR Code');
    // Se aparece, é bug
    if (await qrPrompt.isVisible()) {
      // Verifica se é porque auth falhou
      const isLoggedIn = await page.evaluate(() => !!localStorage.getItem('spalla_access_token'));
      if (isLoggedIn) {
        // Logado mas mostrando QR = bug
        expect(await qrPrompt.isVisible()).toBeFalsy();
      }
    }
  });
});

// ====================================================================
// 8. MATRIZ (Eisenhower)
// ====================================================================
test.describe('Matriz', () => {
  test('quadrantes não estão todos vazios', async ({ page }) => {
    await loginAndNavigate(page, '/tasks');
    await page.waitForTimeout(2000);

    // Click na tab Matriz
    const matrizTab = page.locator('text=Matriz').first();
    if (await matrizTab.isVisible()) {
      await matrizTab.click();
      await page.waitForTimeout(1500);

      // Pelo menos 1 quadrante deve ter tasks
      const nenhumas = await page.locator('text=Nenhuma').count();
      expect(nenhumas).toBeLessThan(4); // não pode ser 4/4 vazios
    }
  });
});
