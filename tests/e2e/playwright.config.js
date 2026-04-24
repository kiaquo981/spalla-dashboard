// @ts-check
const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testDir: '.',
  timeout: 60000,
  retries: 1,
  use: {
    baseURL: process.env.SPALLA_URL || 'https://spalla-dashboard.vercel.app',
    headless: true,
    screenshot: 'only-on-failure',
    trace: 'on-first-retry',
  },
  reporter: [['list'], ['html', { open: 'never' }]],
});
