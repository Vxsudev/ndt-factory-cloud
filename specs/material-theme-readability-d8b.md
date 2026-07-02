# Spec: Material Design Theme System + Readability Rework

## Status
approved

## Phase
phase-demo-readiness

## Feature
material-theme-readability-d8b

## Description

Rework the Factory Flow Board presentation layer to follow Material Design 3 principles.
Implement a real CSS token system with light/dark theme support, a user-accessible toggle,
improved typography, surface elevation model, and readable component hierarchy.

No backend changes. No product scope expansion.

---

## Purpose

D8A produced functionally correct light mode but the presentation remained flat, dense,
and visually weak for stakeholder review. D8B replaces the raw Tailwind color approach with
a proper Material Design 3 token system, a light/dark mode toggle, and a higher-quality
visual hierarchy across all six UI components.

---

## Scope

Frontend presentation layer only:

- `frontend/src/styles.css` — CSS variable token system + semantic helper classes
- `frontend/src/components/FactoryFlowBoard.tsx` — theme toggle, app root token usage
- `frontend/src/components/UnitList.tsx` — Material card list
- `frontend/src/components/StageSpine.tsx` — Material stage cards
- `frontend/src/components/UnitDetailPanel.tsx` — Material grouped card sections
- `frontend/src/components/ActionPanel.tsx` — Material form containers
- `frontend/src/components/EventTrace.tsx` — Readable event table
- `frontend/index.html` — D8B meta markers, inline theme-init script (no FOUC)
- `frontend/tailwind.config.js` — add `darkMode: false` to prevent @media override

No backend changes.

---

## Non-Goals

- No Material UI (MUI) library installation
- No dark/light toggle that requires backend
- No auth
- No Azure SDK
- No new product features
- No backend domain rule changes
- No Postgres schema changes
- No D4–D8 API behavior changes
- No canonical 14-stage model changes
- No vendored OS core mutations
- No chart/icon/animation libraries

---

## Current Visual Problem

D8A outputs raw Tailwind color classes scattered per-component. Problems:

- No token system — each component hardcodes its own colors
- No dark mode — single light presentation with no toggle
- Flat surfaces — no visual elevation model
- Dense typography — text-sm still too compressed in table rows
- Weak hierarchy — header, body, labels all similar visual weight
- No Material-style card system — everything looks like bordered divs

---

## Material Design 3 Guidance

Reference: Material Design 3 color system + typography system.
Implementation: CSS custom properties only, no MUI library.

Key principles applied:

**1. Color roles** — not named colors. Use `--mds-bg`, `--mds-surface`, `--mds-error-container`
etc. Components reference roles, not specific colors. Theme switches the values.

**2. Surface hierarchy** — background < surface < surface-container-low <
surface-container < surface-container-high. Cards sit above the background.

**3. Typography scale** — display/title/body/label scale. Avoid dense paragraphs.
Content areas use larger type.

**4. Tonal containers** — selected/active elements use `primary-container`. Blocked/error
elements use `error-container`. Gate elements use `factory-gate-container`. Terminal uses
`factory-success-container`. Each has a matching `on-*-container` text role.

**5. Accessible contrast** — each tonal container pair provides sufficient contrast
in both themes without relying on color alone (text labels + colors).

---

## Theme Token System

### CSS Variable Naming

Prefix `--mds-` for Material Design system tokens.
Prefix `--factory-` for operational domain tokens.

### Light Theme Values

```
--mds-bg:                  #FAFAF7  (warm off-white)
--mds-surface:             #FFFFFF
--mds-surface-low:         #F4F3F0
--mds-surface-container:   #EDECEA
--mds-surface-high:        #E7E6E3
--mds-on-bg:               #1C1B1F
--mds-on-surface:          #1C1B1F
--mds-on-surface-var:      #49454F
--mds-outline:             #CAC4D0
--mds-outline-var:         #E6E0E9
--mds-primary:             #1D4ED8
--mds-on-primary:          #FFFFFF
--mds-primary-container:   #DBEAFE
--mds-on-primary-container: #1E3A8A
--mds-error:               #DC2626
--mds-error-container:     #FEE2E2
--mds-on-error-container:  #991B1B
--factory-gate:            #D97706
--factory-gate-container:  #FEF3C7
--factory-on-gate:         #92400E
--factory-cloud:           #EA580C
--factory-cloud-container: #FFEDD5
--factory-on-cloud:        #7C2D12
--factory-success:         #16A34A
--factory-success-container: #DCFCE7
--factory-on-success:      #14532D
--factory-supervisor:      #7C3AED
--factory-supervisor-container: #EDE9FE
--factory-on-supervisor:   #4C1D95
```

### Dark Theme Values

```
--mds-bg:                  #141218
--mds-surface:             #1C1B1F
--mds-surface-low:         #201F24
--mds-surface-container:   #26252B
--mds-surface-high:        #302F37
--mds-on-bg:               #E6E1E5
--mds-on-surface:          #E6E1E5
--mds-on-surface-var:      #CAC4D0
--mds-outline:             #6B6572
--mds-outline-var:         #49454F
--mds-primary:             #93C5FD
--mds-on-primary:          #1E3A8A
--mds-primary-container:   #1E3A8A
--mds-on-primary-container: #BFDBFE
--mds-error:               #F87171
--mds-error-container:     #7F1D1D
--mds-on-error-container:  #FECACA
--factory-gate:            #FCD34D
--factory-gate-container:  #451A03
--factory-on-gate:         #FDE68A
--factory-cloud:           #FB923C
--factory-cloud-container: #431407
--factory-on-cloud:        #FED7AA
--factory-success:         #4ADE80
--factory-success-container: #14532D
--factory-on-success:      #BBF7D0
--factory-supervisor:      #C4B5FD
--factory-supervisor-container: #3B0764
--factory-on-supervisor:   #DDD6FE
```

### Semantic CSS Helper Classes

Defined in `styles.css`. Used by all components.

- `.app-bg` — root background + on-background text
- `.surf` — surface background
- `.surf-low` — surface-container-low
- `.surf-container` — surface-container
- `.surf-high` — surface-container-high
- `.t-on-surface` — on-surface text
- `.t-on-surface-var` — on-surface-variant text
- `.b-outline` — outline border color
- `.b-outline-var` — outline-variant border color
- `.surf-primary` — primary-container background
- `.t-on-primary` — on-primary-container text
- `.b-primary` — primary border
- `.t-primary` — primary text
- `.surf-error` — error-container background
- `.t-on-error` — on-error-container text
- `.b-error` — error border
- `.surf-gate` — gate-container background
- `.t-on-gate` — on-gate text
- `.b-gate` — gate border
- `.surf-cloud` — cloud-block-container background
- `.t-on-cloud` — on-cloud text
- `.b-cloud` — cloud border
- `.surf-success` — success-container background
- `.t-on-success` — on-success text
- `.b-success` — success border
- `.surf-supervisor` — supervisor-container background
- `.t-on-supervisor` — on-supervisor text
- `.b-supervisor` — supervisor border
- `.mdc-card` — surface card (border + radius + padding)
- `.mdc-card-container` — surface-container card
- `.mdc-input` / `.mdc-select` — styled input/select
- `.mdc-divider` — divider using outline-var

---

## Light/Dark Toggle

### Behavior

- Default: light mode
- Toggle button in header: shows current mode, switches on click
- `data-theme` attribute set on `document.documentElement` (the `<html>` element)
- Preference persisted in `localStorage` under key `factory-cloud-theme`
- On load: inline script in `<head>` reads localStorage and sets `data-theme`
  before React hydrates — prevents flash of wrong theme (FOUC)

### Toggle Component

Implemented inline in `FactoryFlowBoard.tsx`:
```tsx
const [theme, setTheme] = useState<'light'|'dark'>(() => {
  try { return (localStorage.getItem('factory-cloud-theme') as 'light'|'dark') || 'light' }
  catch { return 'light' }
})
useEffect(() => {
  document.documentElement.setAttribute('data-theme', theme)
  try { localStorage.setItem('factory-cloud-theme', theme) } catch {}
}, [theme])
```

Header button shows "☀ Light" or "◑ Dark", switches theme on click.

---

## Component Readability Plan

### FactoryFlowBoard.tsx

- Root: `app-bg` class (CSS variable background + text)
- `data-d8b-material-theme="true"` added to root div
- Header: `surf b-outline-var` (white surface, outline-var bottom border)
- Section headers: `t-on-surface-var`, `text-xs font-semibold uppercase tracking-wider`
- Column separators: `b-outline-var`
- Theme toggle button in header

### UnitList.tsx

- Default row: `surf-low b-outline-var` + rounded-xl
- Selected row: `surf-primary b-primary t-on-primary`
- Hover: `hover:surf-container`
- Unit ID: `text-[15px] font-bold t-on-surface`
- Scenario label: `text-[13px] font-medium t-primary` (selected) or `text-[13px] t-on-surface-var`
- Blocked badge: `surf-error b-error t-on-error text-xs font-bold`
- Shipped badge: `surf-success b-success t-on-success text-xs font-bold`
- Row min-height: ~82px via padding

### StageSpine.tsx

- Completed: `surf-low b-outline-var opacity-90`
- Current: `surf-primary b-primary`
- Blocked: `surf-error b-error`
- Gate pending: `surf-gate b-gate`
- Cloud block pending: `surf-cloud b-cloud`
- Terminal pending: `surf-success b-success`
- Default pending: `surf b-outline-var`
- Stage name: `text-sm font-semibold t-on-surface` (adjusted per state)
- Stage number: `text-xs font-mono t-on-surface-var`
- No opacity-* on any row

### UnitDetailPanel.tsx

- Section cards: `mdc-card` (CSS class)
- Row labels: `t-on-surface-var`
- Row values: `t-on-surface font-mono`
- Block/Hard-Stop section: `surf-error b-error` card
- Row dividers: `mdc-divider`

### ActionPanel.tsx

- Form containers: semantic classes by action type
  - Assembly/Package/Ship: `surf b-outline-var`
  - Supervisor: `surf-supervisor b-supervisor`
  - Gate/Calibration/QC: `surf-gate b-gate`
  - Cloud: `surf-cloud b-cloud`
  - Disposition: `surf-error b-error`
- Inputs/selects: `.mdc-input` / `.mdc-select`
- Submit button: `bg-primary text-on-primary` (inline style or Tailwind bg-blue-700)
- Response success: `surf-success b-success`
- Response blocked: `surf-error b-error`

### EventTrace.tsx

- Table header: `t-on-surface-var b-outline-var`
- Row hover: `hover:surf-low`
- Selected row: `surf-primary/30` (semi-transparent primary container)
- Severity badges: themed via helper classes
- Row height: min 36–40px

---

## Acceptance Criteria

- [ ] Light/dark toggle exists in header
- [ ] Theme persists across reload via localStorage
- [ ] data-theme attribute set on document.documentElement
- [ ] CSS variables defined for both [data-theme="light"] and [data-theme="dark"]
- [ ] Root background uses CSS variable (not hardcoded Tailwind class)
- [ ] data-d8b-material-theme="true" on app root
- [ ] index.html meta tag app-d8b="material-theme-toggle" present
- [ ] Unit IDs are 15px+ and bold
- [ ] Stage names are 14px+ and readable
- [ ] Blocked state uses error-container tokens (prominent in both modes)
- [ ] Gate stages use gate-container tokens
- [ ] Cloud block uses cloud-container tokens
- [ ] Terminal uses success-container tokens
- [ ] Action panel forms have semantic container backgrounds
- [ ] All 001–009 scripts still pass
- [ ] 010-material-theme-readability.sh passes (21 checks)
- [ ] No new npm packages added
- [ ] No Azure SDK, no auth
- [ ] OS state RELEASE_APPROVED for material-theme-readability-d8b

---

## Verification Protocol

`scripts/verification/010-material-theme-readability.sh` — 21 checks:

V1: frontend root loads (200)
V2: page contains Factory Cloud
V3: page contains Review Prototype
V4: page contains material-theme-toggle (meta tag)
V5: page contains d8b (meta tag)
V6: FactoryFlowBoard.tsx contains data-theme attribute usage
V7: styles.css contains --mds- token variables
V8: FactoryFlowBoard.tsx contains "Light" and "Dark" (toggle labels)
V9: backend health ok
V10: data-contract/status 200
V11: stage_count = 14
V12: unit_count >= 7
V13: D4 verification passes
V14: D5 verification passes
V15: D6 verification passes
V16: D7 verification passes
V17: D8 verification passes
V18: D8A verification passes (meta markers retained)
V19: smoke passes
V20: no Azure SDK
V21: no auth/session implementation

---

## Entry and Exit Conditions

**Entry:** D8A is RELEASE_APPROVED. All 001–009 verifications pass. Stack is live.

**Exit:** All 001–010 verifications pass. OS state = RELEASE_APPROVED for
material-theme-readability-d8b. Journal Entry 013 appended. README, repo-index,
architecture-index updated. docs/material-theme-readability-d8b.md created.
