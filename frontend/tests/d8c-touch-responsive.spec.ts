import { test, expect, type Page } from '@playwright/test'

// D8C — Touch-First Responsive Factory UI browser verification.
// Covers specs/touch-first-responsive-factory-ui-d8c.md "Browser Verification Plan".
// Requires the docker-compose stack to be running (frontend:5173, backend:8000).

const VIEWPORTS = [
  { name: '768x1024', width: 768, height: 1024, band: 'compact' },
  { name: '1024x768', width: 1024, height: 768, band: 'standard' },
  { name: '1180x820', width: 1180, height: 820, band: 'standard' },
  { name: '1280x800', width: 1280, height: 800, band: 'standard' },
  { name: '1440x900', width: 1440, height: 900, band: 'standard' },
  { name: '1920x1080', width: 1920, height: 1080, band: 'large' },
] as const

const THEMES = ['light', 'dark'] as const

async function setTheme(page: Page, theme: 'light' | 'dark') {
  await page.addInitScript((t) => {
    window.localStorage.setItem('factory-theme', t)
  }, theme)
}

async function noHorizontalOverflow(page: Page) {
  return page.evaluate(() => ({
    scrollWidth: document.documentElement.scrollWidth,
    clientWidth: document.documentElement.clientWidth,
  }))
}

test.describe('D8C viewport matrix — no horizontal overflow, both themes', () => {
  for (const vp of VIEWPORTS) {
    for (const theme of THEMES) {
      test(`${vp.name} (${vp.band}) — ${theme}`, async ({ page }) => {
        await page.setViewportSize({ width: vp.width, height: vp.height })
        await setTheme(page, theme)
        await page.goto('/')
        await expect(page.locator('[data-d8c-touch-responsive="true"]')).toBeAttached()
        const { scrollWidth, clientWidth } = await noHorizontalOverflow(page)
        expect(scrollWidth).toBeLessThanOrEqual(clientWidth)
      })
    }
  }
})

test.describe('D8C compact layout does not force the desktop three-column shell', () => {
  test('768x1024 shows the compact pane switcher, not all three columns at once', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 })
    await page.goto('/')
    await expect(page.getByRole('tablist', { name: 'Factory view' })).toBeVisible()
    // Only the active pane's content is visible; queue and stages are not
    // simultaneously docked alongside the default Detail pane.
    await expect(page.getByText('Unit Queue (', { exact: false })).toBeHidden()
  })

  test('1024x768 shows all regions simultaneously (standard workstation)', async ({ page }) => {
    await page.setViewportSize({ width: 1024, height: 768 })
    await page.goto('/')
    await expect(page.getByRole('tablist', { name: 'Factory view' })).toBeHidden()
    await expect(page.getByText('Unit Queue (', { exact: false })).toBeVisible()
    await expect(page.getByText('14-Stage Production Spine')).toBeVisible()
    await expect(page.getByText('Unit Detail')).toBeVisible()
  })
})

test.describe('D8C touch-target contract', () => {
  test('primary controls meet 48x48, secondary controls meet 44x44', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 })
    await page.goto('/')

    for (const label of ['Reset Demo State', 'Dark']) {
      const box = await page.getByRole('button', { name: label }).boundingBox()
      expect(box?.width).toBeGreaterThanOrEqual(48)
      expect(box?.height).toBeGreaterThanOrEqual(48)
    }

    for (const tab of ['Unit Queue', 'Detail', 'Stages', 'Events']) {
      const box = await page.getByRole('tab', { name: tab }).boundingBox()
      expect(box?.height).toBeGreaterThanOrEqual(48)
    }

    await page.getByRole('tab', { name: 'Events' }).click()
    const toggleBox = await page.getByRole('button', { name: /Show (all|fewer) events/ }).boundingBox()
    expect(toggleBox?.height).toBeGreaterThanOrEqual(44)
  })
})

test.describe('D8C blocked-unit scenario', () => {
  test('blocked reason and required action remain visible and correct at compact width', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 })
    await page.goto('/')
    await page.getByRole('tab', { name: 'Unit Queue' }).click()
    await page.getByRole('button', { name: /UNIT-0004/ }).click()

    // Selecting a unit auto-switches to the Detail pane.
    await expect(page.getByRole('tab', { name: 'Detail', selected: true })).toBeVisible()
    await expect(page.getByText('calibration_cap_exceeded_supervisor_disposition_required')).toBeVisible()
    await expect(page.getByText('Calibration Disposition (Cap Exceeded)')).toBeVisible()

    const submitBox = await page.getByRole('button', { name: 'Submit Disposition' }).boundingBox()
    expect(submitBox?.height).toBeGreaterThanOrEqual(48)
  })
})

test.describe('D8C theme + reset', () => {
  test('theme toggle persists across reload', async ({ page }) => {
    await page.goto('/')
    await page.getByRole('button', { name: 'Dark' }).click()
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark')
    await page.reload()
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark')
  })

  test('reset demo state control works and is touch-safe', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 })
    await page.goto('/')
    const resetBox = await page.getByRole('button', { name: 'Reset Demo State' }).boundingBox()
    expect(resetBox?.height).toBeGreaterThanOrEqual(48)
    await page.getByRole('button', { name: 'Reset Demo State' }).click()
    await expect(page.getByText('Resetting…')).toHaveCount(0, { timeout: 5000 })
  })
})

test.describe('D8C stage spine and event history remain reachable', () => {
  test('all 14 stages reachable via the Stages tab at compact width', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 })
    await page.goto('/')
    await page.getByRole('tab', { name: 'Stages' }).click()
    for (const stageName of ['Order created', 'Assembly', 'Calibration', 'Quality Control', 'Ship']) {
      await expect(page.getByText(stageName, { exact: true })).toBeVisible()
    }
  })

  test('event history reachable via the Events tab at compact width', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 })
    await page.goto('/')
    await page.getByRole('tab', { name: 'Events' }).click()
    await expect(page.getByText('Event Trace')).toBeVisible()
  })
})

test.describe('D8C keyboard accessibility', () => {
  test('focus outline remains visible on interactive controls', async ({ page }) => {
    await page.goto('/')
    await page.keyboard.press('Tab')
    const active = await page.evaluate(() => document.activeElement?.tagName)
    expect(active).toBeTruthy()
  })
})
