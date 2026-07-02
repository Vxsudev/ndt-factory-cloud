import { defineConfig, devices } from '@playwright/test'

// D8C — minimum Playwright tooling for touch/responsive browser verification.
// No prior browser-automation dependency existed in this repo (see
// ai/recon/d8c-touch-first-responsive-ui-recon.md). Runs against the live
// docker-compose stack; does not manage the stack's lifecycle itself.
export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  retries: 0,
  forbidOnly: true,
  reporter: [['list']],
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL ?? 'http://localhost:5173',
    trace: 'off',
    screenshot: 'off',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
})
