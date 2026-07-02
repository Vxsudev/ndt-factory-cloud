# D8A — Light Mode Readability Pass

**Date:** 2026-06-30
**Phase:** D8A — Factory Review Hardening / Light Mode
**Status:** COMPLETE

---

## Issue

The D8 Factory Flow Board used Tailwind dark-mode classes throughout. The operator
rejected the current dark UI readability for stakeholder review on a laptop screen.

Specific problems:
- Root background: `bg-gray-950` — too dark for a bright meeting room
- Text: `text-xs` (12px) throughout — too small for comfortable reading
- Section headers: `text-[10px]` — below minimum readability
- Pending stage rows: `opacity-40`–`opacity-50` — very low contrast on dark
- Badges: `bg-red-900 text-red-300` style — hard to scan quickly
- Panel cards: `bg-gray-900 border-gray-800` — undifferentiated dark surfaces

---

## Visual Direction

Light off-white presentation that retains industrial/control-system character.
Not a generic white SaaS product — a monitoring surface that happens to be readable.

The off-white background (`#FAFAF7`) distinguishes it from pure white and retains
warmth. Panel cards use `#FFFFFF`. Borders use soft slate-blue (`#D8DDE6` equivalent).

All semantic state colors preserved but converted to light variants:
- Blocked/error: red-50/red-600 (was red-950/red-300)
- Gates: amber-50/amber-700 (was gray-950/amber-600)
- Cloud block: orange-50/orange-600 (was gray-950/slate-500)
- Terminal/shipped: green-50/green-700 (was gray-950/green-700)
- Selected: blue-50/blue-700 (was blue-950/blue-200)

---

## Color Policy

| Token | Light Value | Dark (removed) |
|-------|------------|----------------|
| App background | bg-[#FAFAF7] | bg-gray-950 |
| Panel/card | bg-white | bg-gray-900 |
| Border | border-slate-200 | border-gray-800 |
| Primary text | text-gray-900 | text-gray-100 |
| Secondary text | text-gray-600 | text-gray-400 |
| Muted text | text-gray-400–500 | text-gray-600 |
| Blocked bg | bg-red-50 | bg-red-950 |
| Blocked border | border-red-200 | border-red-800 |
| Blocked text | text-red-700 | text-red-300 |
| Gate bg | bg-amber-50 | bg-gray-950 |
| Gate border | border-amber-300 | border-amber-900 |
| Gate text | text-amber-700 | text-amber-300 |
| Cloud block bg | bg-orange-50 | bg-gray-950 |
| Cloud border | border-orange-200 | border-slate-700 |
| Terminal bg | bg-green-50 | bg-gray-950 |
| Terminal border | border-green-300 | border-green-900 |
| NO OVERRIDE | bg-red-600 text-white | bg-red-700 text-white (kept prominent) |

---

## Typography Changes

| Element | Before | After |
|---------|--------|-------|
| Page title | text-lg (18px) | text-2xl (24px) |
| Section headers | text-[10px] | text-xs (12px) |
| Unit IDs | text-xs (12px) | text-sm (14px) |
| Stage names | implicit text-xs | text-sm (14px) |
| Body/table text | text-xs (12px) | text-sm (14px) |
| Badges | text-[10px] | text-xs (12px) |
| Form labels | text-[10px] | text-xs (12px) |
| Form inputs | text-xs (12px) | text-sm (14px) |
| Submit buttons | text-xs (12px) | text-sm (14px) |

---

## Component Changes

### FactoryFlowBoard.tsx
- Root: `bg-gray-950 text-gray-100` → `bg-[#FAFAF7] text-gray-900`
- Added: `data-d8a-readability="true"` and `data-theme="light-review"` on root div
- Header: taller padding (`py-4`), white background, slate-200 border
- Title: `text-lg` → `text-2xl`
- Postgres badge: dark-blue → light-blue (`bg-blue-50 text-blue-700 border-blue-200`)
- Subtitle: `text-gray-400` → `text-gray-500 text-sm`
- Status indicators: dark greens/ambers → light greens/ambers
- Reset button: dark → `bg-white border-slate-300 text-gray-700`
- Column borders: `border-gray-800` → `border-slate-200`
- Column widths: increased (w-56 → w-64 queue, w-72 → w-80 spine)
- Section headers: `text-[10px] text-gray-600` → `text-xs text-gray-400`

### UnitList.tsx
- Default row: `bg-gray-900 border-gray-800` → `bg-white border-slate-200`
- Selected row: `bg-blue-950 border-blue-500` → `bg-blue-50 border-blue-400`
- Unit ID: `text-xs` → `text-sm`
- BLOCKED badge: `bg-red-900 text-red-300` → `bg-red-100 text-red-700 border-red-300`
- SHIPPED badge: `bg-green-900 text-green-300` → `bg-green-100 text-green-700 border-green-300`
- Scenario label: `text-[10px] text-sky-400` → `text-xs text-sky-600`
- Blocked reason: `text-red-400 text-[10px]` → `text-red-600 text-xs`

### StageSpine.tsx
- Removed all `opacity-*` modifiers — no more faded pending stages
- Completed: `border-gray-800 bg-gray-900` → `border-slate-200 bg-slate-50`
- Current: `border-blue-500 bg-blue-950` → `border-blue-400 bg-blue-50`
- Blocked: `border-red-700 bg-red-950` → `border-red-400 bg-red-50`
- Gate pending: `border-amber-900 bg-gray-950` → `border-amber-300 bg-amber-50`
- Cloud block: `border-slate-700 bg-gray-950` → `border-orange-200 bg-orange-50`
- Terminal pending: `border-green-900 bg-gray-950` → `border-green-300 bg-green-50`
- All badges converted to light variants (100 bg, 700 text, 300 border)
- Stage names: `text-sm` throughout, correct semantic colors
- Status dots: `bg-gray-800` pending → `bg-slate-300`

### UnitDetailPanel.tsx
- Cards: `bg-gray-900 border-gray-800` → `bg-white border-slate-200`
- Row separators: `border-gray-800` → `border-slate-100`
- Labels: `text-gray-500` (unchanged), values: `text-gray-200` → `text-gray-800`
- Section headers: `text-gray-600` → `text-gray-400`
- Block/Hard-Stop box: `bg-red-950 border-red-800` → `bg-red-50 border-red-200`
- Blocked reason: `text-red-300` → `text-red-700 font-semibold`
- NO OVERRIDE: `text-red-200` → `text-red-700 font-bold`
- All text sizes: `text-xs` → `text-sm` for values
- Success/green values: `text-green-400` → `text-green-600 font-semibold`

### ActionPanel.tsx
- Terminal banner: `bg-green-950 text-green-300` → `bg-green-50 border-green-300 text-green-700`
- "No actions" banner: `bg-gray-950 text-gray-600` → `bg-slate-50 text-gray-400`
- Form containers: dark → light semantic equivalents (blue for scan, purple for realloc, etc.)
- Form headers: `text-blue-300`/`text-amber-300` → `text-blue-700`/`text-amber-700`
- Endpoint line: `text-gray-600` → `text-slate-400`
- All inputs: `bg-gray-900 border-gray-700` → `bg-slate-50 border-slate-300 text-gray-800`
- Text sizes: `text-xs` → `text-sm`
- Submit button: `bg-blue-700` → `bg-blue-600 hover:bg-blue-700`
- ResponseDisplay success: `bg-green-950 border-green-700` → `bg-green-50 border-green-300`
- ResponseDisplay blocked: `bg-red-950 border-red-700` → `bg-red-50 border-red-300`
- Status badges: dark variants → light variants

### EventTrace.tsx
- Table header: `border-gray-800 text-gray-600` → `border-slate-200 text-gray-400`
- Row separator: `border-gray-900` → `border-slate-100`
- Row hover: `hover:bg-gray-900` → `hover:bg-slate-50`
- Selected row: `bg-blue-950/30` → `bg-blue-50`
- Event ID: `text-gray-400` (unchanged)
- Unit ID selected: `text-blue-300` → `text-blue-600 font-semibold`
- Non-selected unit: `text-gray-300` → `text-gray-600`
- Message: `text-gray-300` → `text-gray-700`
- Severity badges: dark variants → light (`text-red-600`, `text-amber-600`, `text-blue-600`)
- Show-all button: `text-blue-400` → `text-blue-600`
- All table text: `text-xs` body size

### frontend/index.html
- Added: `<meta name="app-d8a" content="light-review" />`
- Added: `<meta name="app-theme" content="light-review" />`
- Previous D8 meta tags unchanged for backward compatibility

---

## What Did NOT Change

- `backend/app/workflow_rules.py` — untouched
- `backend/app/routes/actions.py` — untouched
- `backend/app/routes/data_contract.py` — untouched
- `backend/app/state_store.py` — untouched
- `backend/app/models.py` — untouched
- `backend/app/db_models.py` — untouched
- All 11 action endpoints — same URLs, same request/response shapes
- All 10 data contract endpoints — unchanged
- PostgreSQL schema — unchanged
- 14-stage canonical production spine — unchanged
- `data/*.json` seed files — unchanged
- Seeded unit scenarios (UNIT-0001 through UNIT-0007) — unchanged
- SCENARIO_LABELS mapping — unchanged
- EventTrace unit-filtering logic — unchanged
- All D8 data-attribute markers retained (`data-d8-demo-readiness`, `app-d8`)

---

## Verification Results

| Script | Result |
|--------|--------|
| 001-docker-compose-config.sh | **4/4 PASS** |
| 002-backend-health.sh | **4/4 PASS** |
| 003-frontend-reachable.sh | **2/2 PASS** |
| 004-data-contract-api.sh | **10/10 PASS** |
| 005-backend-state-behavior.sh | **26/26 PASS** |
| 006-factory-flow-board-ui.sh | **12/12 PASS** |
| 007-persistence-postgres.sh | **17/17 PASS** |
| 008-demo-readiness.sh | **17/17 PASS** |
| 009-light-mode-readability.sh | **18/18 PASS** |
| smoke.sh | **PASS** |

---

## D9 Readiness

**READY for directive.**
D9 candidates: Order management UI, full unit history viewer, Azure IoT Hub wiring for S-07/S-12.
All require explicit directives before implementation.
