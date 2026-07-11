# Task: Build the D9C-1 variant review shell (additive, presentation-only)

## Parent Spec
specs/d9c-1-variant-review-shell.md

## Phase
phase-ui

## Status
done

## Layer
frontend

## Description

Build a new, additive-only client review shell reachable at `/#/variants`, without
changing the existing `/` entry point in any way. This is a pure frontend/presentation
task — no backend, API, database, or `frontend/package.json` change of any kind.

**Context you need (self-contained, do not need to read anything else first):**

The app today (`frontend/src/main.tsx`) does:
```tsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './styles.css'
import App from './App'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
```
`App.tsx` just renders `<FactoryFlowBoard />`. `FactoryFlowBoard.tsx` is the existing,
fully-built factory engineering console (unit list, stage spine, detail panel, action
panel, event trace). None of this may change behaviorally.

The existing stylesheet `frontend/src/styles.css` already defines these reusable classes
— reuse them, do not invent new colors or new CSS custom properties:
`surf`, `surf-container`, `surf-primary`, `surf-success`, `surf-error`, `surf-cloud`,
`surf-supervisor`, `surf-gate`, `surf-high`, `surf-low`, `t-on-surface`, `t-on-surface-var`,
`t-on-primary`, `t-on-success`, `t-on-error`, `t-on-cloud`, `t-on-supervisor`, `t-on-gate`,
`b-primary`, `b-outline`, `b-outline-var`, `b-success`, `b-error`, `b-cloud`, `b-supervisor`,
`b-gate`, `mdc-card`, `mdc-card-container`, `mdc-divider`, `mdc-input`, `mdc-select`,
`touch-target-primary` (min 48×48px), `touch-target-secondary` (min 44×44px).

**Build exactly this:**

1. Create `frontend/src/components/variant-review/VariantPlaceholderPane.tsx`:
   - Props: `variantId: 'variantA' | 'variantB' | 'variantC'`, `variantLabel: string`.
   - Local state: `activeActor: 'assembler' | 'floorManager'`, default `'assembler'`.
   - Renders a secondary tab bar of exactly two real `<button>` elements — "Assembler"
     and "Floor Manager" — each with class `touch-target-secondary` plus existing
     `surf-*`/`b-*`/`t-on-*` classes to show selected vs. unselected state (e.g. selected
     button gets `surf-primary t-on-primary`, unselected gets `surf-container
     t-on-surface b-outline-var`). Clicking a button updates `activeActor` (pure client
     state, no navigation, no network call).
   - Below the tab bar, render a placeholder body (reuse `mdc-card`/`mdc-card-container`
     styling) showing: the `variantLabel`, the currently selected actor's display label
     ("Assembler" or "Floor Manager"), and the exact text: "Presentation content for this
     view ships in a later phase." Do not fetch or display any factory/unit/order data.
     Do not import anything from `frontend/src/api/`.

2. Create `frontend/src/components/variant-review/VariantReviewShell.tsx`:
   - Local state: `activeTab: 'current' | 'variantA' | 'variantB' | 'variantC'`, default
     `'current'`.
   - Renders a primary tab bar of exactly four real `<button>` elements, in this order,
     with this exact visible text: "Current", "Variant A — Attention-First", "Variant B —
     Workflow-First", "Variant C — Command-Center". Each button has class
     `touch-target-primary` plus `surf-*`/`b-*`/`t-on-*` classes to show selected vs.
     unselected state, same convention as above. Clicking a button updates `activeTab`
     (pure client state, no navigation, no network call, no page reload).
   - Below the tab bar, render the active pane:
     - `activeTab === 'current'` → import and render `<FactoryFlowBoard />` from
       `../FactoryFlowBoard` completely unmodified — no extra wrapper props, no style
       overrides applied to it.
     - `activeTab === 'variantA'` → `<VariantPlaceholderPane variantId="variantA"
       variantLabel="Variant A — Attention-First" />`
     - `activeTab === 'variantB'` → `<VariantPlaceholderPane variantId="variantB"
       variantLabel="Variant B — Workflow-First" />`
     - `activeTab === 'variantC'` → `<VariantPlaceholderPane variantId="variantC"
       variantLabel="Variant C — Command-Center" />`
   - Root element of this component should have a `data-d9c1-variant-review-shell="true"`
     attribute for identifiability (does not affect behavior).

3. Modify `frontend/src/main.tsx` — additive only, do not remove or reorder existing
   lines beyond what's needed to introduce a tiny decision component:
   - Import `VariantReviewShell` from `./components/variant-review/VariantReviewShell`.
   - Add a small local function component (e.g. `Root`) that reads
     `window.location.hash` once at module load: if it starts with `#/variants`, return
     `<VariantReviewShell />`; otherwise return `<App />` exactly as rendered today.
   - Render `<Root />` inside the existing `<StrictMode>` wrapper in place of the direct
     `<App />` reference. The `/` (no hash) path must continue to render `<App />` with
     zero behavioral or DOM difference from before this change — do not wrap `<App />`
     in any new element.

4. Append new, additive-only CSS rules to `frontend/src/styles.css` for the shell's
   primary/secondary tab bar layout (e.g. flex row, gap, wrapping at narrow widths) and
   the placeholder pane body layout. Do not modify, remove, or reorder any existing rule
   already in the file. Do not introduce new hardcoded color values or new CSS custom
   properties — every color must come from an existing `surf-*`/`t-on-*`/`b-*` class.

**Hard constraints (do not violate):**
- Do not modify `frontend/src/App.tsx`, `frontend/src/components/FactoryFlowBoard.tsx`,
  or any of its existing child components.
- Do not modify `frontend/src/api/factoryApi.ts` or `frontend/src/types/factory.ts`.
- Do not modify `frontend/package.json`, `frontend/package-lock.json`,
  `frontend/vite.config.ts`, `frontend/index.html`, or `frontend/tsconfig.json`. Do not
  add any new npm dependency or routing library.
- Do not modify anything under `backend/`, `data/`, `vendor/`, `.engineering-os/`,
  `scripts/`, `ai/`, `tasks/`, `specs/`.
- Do not make any network/API call from the new shell or placeholder components.

## Acceptance Criteria
- [ ] `frontend/src/components/variant-review/VariantReviewShell.tsx` exists and renders
      a 4-button primary tab bar with the exact visible labels specified above.
- [ ] `frontend/src/components/variant-review/VariantPlaceholderPane.tsx` exists and
      renders a 2-button secondary tab bar (Assembler / Floor Manager) plus a placeholder
      body with the exact message specified above; makes zero API/data calls.
- [ ] `frontend/src/main.tsx` renders `<VariantReviewShell />` when
      `window.location.hash` starts with `#/variants`, and renders `<App />` completely
      unmodified otherwise (no new wrapper element around `<App />`).
- [ ] Primary tab buttons use the `touch-target-primary` class; secondary tab buttons use
      the `touch-target-secondary` class.
- [ ] All new CSS in `frontend/src/styles.css` is additive; no existing rule is changed,
      removed, or reordered; no new hardcoded color value is introduced.
- [ ] `frontend/src/App.tsx`, `frontend/src/components/FactoryFlowBoard.tsx` and its
      existing children, `frontend/src/api/factoryApi.ts`, and
      `frontend/src/types/factory.ts` are byte-for-byte unchanged.
- [ ] `frontend/package.json`, `frontend/package-lock.json`, `frontend/vite.config.ts`,
      `frontend/index.html`, `frontend/tsconfig.json` are byte-for-byte unchanged.
- [ ] Zero files under `backend/`, `data/`, `vendor/`, `.engineering-os/` are touched.
- [ ] The app still builds/type-checks (`frontend/tsconfig.json`'s strict mode; no `any`
      types introduced).

## Files Likely Affected
- `frontend/src/components/variant-review/VariantReviewShell.tsx` (new)
- `frontend/src/components/variant-review/VariantPlaceholderPane.tsx` (new)
- `frontend/src/main.tsx` (additive edit)
- `frontend/src/styles.css` (additive edit)

## Blocked By
- none
