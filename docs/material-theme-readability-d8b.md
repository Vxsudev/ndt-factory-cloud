# D8B — Material Design Theme System + Readability Rework

**Phase:** D8B Material Design Theme System
**Status:** COMPLETE
**Date:** 2026-06-30

---

## Overview

D8B reworks the Factory Flow Board presentation layer with a Material Design 3-inspired
CSS token system. Replaces the D8A scattered-Tailwind-class approach with a proper design
token hierarchy, adds a Light/Dark mode toggle with localStorage persistence, and improves
typography, surface elevation, and visual hierarchy across all six components.

No backend changes. No product scope changes. All D4–D9 APIs remain identical.

---

## What Changed

### CSS Token System (`frontend/src/styles.css`)

Full rewrite to define `[data-theme="light"]` and `[data-theme="dark"]` blocks:

**Material Design 3 system tokens (`--mds-*`):**
- Surface scale: `--mds-surface`, `--mds-surface-low`, `--mds-surface-container`, `--mds-surface-high`
- Text roles: `--mds-on-surface`, `--mds-on-surface-variant`
- Borders: `--mds-outline`, `--mds-outline-variant`
- Primary: `--mds-primary`, `--mds-on-primary`, `--mds-primary-container`, `--mds-on-primary-container`
- Error: `--mds-error`, `--mds-on-error`, `--mds-error-container`, `--mds-on-error-container`

**Factory operational tokens (`--factory-*`):**
- Gate/amber (calibration, QC, hardware gates): `--factory-gate`, `--factory-gate-container`, `--factory-on-gate`
- Cloud block (S-07, S-12): `--factory-cloud`, `--factory-cloud-container`, `--factory-on-cloud`
- Success/terminal (S-14, shipped): `--factory-success`, `--factory-success-container`, `--factory-on-success`
- Supervisor authority (reallocations): `--factory-supervisor`, `--factory-supervisor-container`, `--factory-on-supervisor`

**Semantic CSS helper classes:**
- `.app-bg` — root background + on-background text
- `.surf`, `.surf-low`, `.surf-container`, `.surf-high` — surface hierarchy
- `.t-on-surface`, `.t-on-surface-var` — text roles
- `.b-outline`, `.b-outline-var` — border roles
- `.surf-primary`, `.t-on-primary`, `.b-primary`, `.t-primary` — primary tonal surface
- `.surf-error`, `.t-on-error`, `.b-error` — error/blocked state
- `.surf-gate`, `.t-on-gate`, `.b-gate` — gate/calibration state
- `.surf-cloud`, `.t-on-cloud`, `.b-cloud` — cloud block state
- `.surf-success`, `.t-on-success`, `.b-success` — terminal/success state
- `.surf-supervisor`, `.t-on-supervisor`, `.b-supervisor` — supervisor authority state
- `.mdc-card`, `.mdc-card-container` — MD3 card primitives
- `.mdc-input`, `.mdc-select` — MD3 form inputs
- `.mdc-divider` — outline-variant divider
- `.hover-surf-low`, `.hover-surf-container` — hover state helpers

### Light/Dark Toggle (`FactoryFlowBoard.tsx`)

- `useState<'light'|'dark'>` initialized from `localStorage.getItem('factory-theme')`
- `useEffect` sets `document.documentElement.setAttribute('data-theme', theme)` on every change
- Persists to `localStorage.setItem('factory-theme', theme)`
- Toggle button in header: shows "Dark" when in light mode, "Light" when in dark mode
- No-FOUC inline script in `index.html <head>` reads localStorage before React hydrates

### Index.html

- Added `<meta name="app-d8b" content="material-theme-toggle" />` and `app-d8b-theme="true"` meta tags
- Added inline theme-init script before React loads
- Retained all D8/D8A meta tags (backward-compatible with 009 checks)

### Tailwind Config

- Added `darkMode: false` to prevent system OS preference from overriding `data-theme` attribute

### Component Updates

All six components updated to use semantic CSS helper classes:

| Component | Main changes |
|-----------|-------------|
| FactoryFlowBoard | Header/footer use `.surf .b-outline-var`; column dividers use `.b-outline-var`; section labels use `.t-on-surface-var` |
| UnitList | Default rows `.surf-low .b-outline-var rounded-xl`; selected `.surf-primary .b-primary .t-on-primary`; badges use semantic classes |
| StageSpine | All 7 state variants use MD3 token classes; stage text uses container on-colors; badges use semantic classes; NO OVERRIDE remains `bg-red-600 text-white` |
| UnitDetailPanel | Cards use `.mdc-card .b-outline-var`; rows use `.t-on-surface-var` / `.t-on-surface`; block section uses `.surf-error .b-error` |
| ActionPanel | Inputs/selects use `.mdc-input`/`.mdc-select`; form containers by action type (gate/cloud/error/supervisor/success); response display uses semantic classes |
| EventTrace | `severityStyle()` returns CSS variable inline styles; row hover via `.hover-surf-container`; selected row via `color-mix()` with `--mds-primary-container` |

---

## Light Theme Values (key tokens)

| Token | Value | Purpose |
|-------|-------|---------|
| `--mds-surface` | `#FAFAF7` | Root background (warm off-white) |
| `--mds-primary-container` | `#D6E4FF` | Selected item background |
| `--mds-error-container` | `#FFDAD6` | Blocked/error item background |
| `--factory-gate-container` | `#FFDF9E` | Gate/calibration item background |
| `--factory-cloud-container` | `#9CF2F2` | Cloud block item background |
| `--factory-success-container` | `#9CEAB0` | Terminal/shipped item background |
| `--factory-supervisor-container` | `#F6D9FF` | Supervisor authority item background |

## Dark Theme Values (key tokens)

| Token | Value | Purpose |
|-------|-------|---------|
| `--mds-surface` | `#12140F` | Root background (near-black) |
| `--mds-primary-container` | `#14449E` | Selected item background |
| `--mds-error-container` | `#93000A` | Blocked/error item background |
| `--factory-gate-container` | `#5A3F00` | Gate/calibration item background |
| `--factory-cloud-container` | `#004F4F` | Cloud block item background |
| `--factory-success-container` | `#00521F` | Terminal/shipped item background |
| `--factory-supervisor-container` | `#5B006D` | Supervisor authority item background |

---

## What Is Not Changed

- All 11 workflow action endpoints — same URLs and behavior
- All 10 data contract endpoints — unchanged
- PostgreSQL schema — unchanged
- 14-stage canonical spine — unchanged
- `workflow_rules.py` — untouched
- D8/D8A meta markers in index.html — retained for backward compat
- D8A verification script (009) V6 — updated to accept D8B `.app-bg`/`data-theme` approach

---

## Verification

Script: `scripts/verification/010-material-theme-readability.sh` — 21 checks

All checks pass including D4-D9 regression suite.
