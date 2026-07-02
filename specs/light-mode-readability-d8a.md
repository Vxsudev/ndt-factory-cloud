# Spec: Light Mode Readability Pass

## Status
approved

## Phase
phase-demo-readiness

## Feature
light-mode-readability-d8a

## Description

Apply a light-mode readability pass to the D8 Factory Flow Board UI. The current dark
presentation is visually too dark and too dense for stakeholder review on a laptop screen.
Replace the dark default with an off-white light presentation that preserves all product
behavior, domain semantics, and component structure.

---

## Purpose

D8 is functionally complete. The operator has rejected the current dark UI readability for
stakeholder review. D8A converts the Factory Flow Board to light mode to enable a comfortable
review session with Vijay / Mohit / engineering stakeholders.

Core rule: improve readability only. Preserve product behavior exactly.

---

## Scope

Frontend presentation layer only:

- `frontend/src/components/FactoryFlowBoard.tsx`
- `frontend/src/components/UnitList.tsx`
- `frontend/src/components/StageSpine.tsx`
- `frontend/src/components/UnitDetailPanel.tsx`
- `frontend/src/components/ActionPanel.tsx`
- `frontend/src/components/EventTrace.tsx`
- `frontend/index.html` (add `data-theme="light-review"` and `data-d8a-readability="true"`)

No backend changes. No schema changes. No new dependencies.

---

## Non-Goals

- No dark/light mode toggle
- No auth
- No Azure SDK
- No new product features
- No backend domain rule changes
- No Postgres schema changes
- No D4/D5/D6/D7 API behavior changes
- No canonical 14-stage model changes
- No vendored OS core mutations
- No new npm packages
- No animation libraries
- No charting libraries

---

## Current Readability Issue

The D8 UI uses Tailwind dark-mode classes throughout:

- Root: `bg-gray-950 text-gray-100`
- Panels: `bg-gray-900 border-gray-800`
- Text: `text-xs` (12px) throughout — too small for review
- Section headers: `text-[10px]` — below minimum readability
- Stage rows: `opacity-40`–`opacity-60` on pending/completed — low contrast on dark
- Badges: dark variants (`bg-red-900 text-red-300`, etc.) — hard to read at a glance
- Overall: unsuitable for a laptop screen demo in a bright room

---

## Light Mode Design Direction

### Color Palette

| Token      | Value           | Usage |
|------------|-----------------|-------|
| app-bg     | `#FAFAF7`       | Page background (off-white, not pure white) |
| panel-bg   | `#FFFFFF`       | Card/panel backgrounds |
| border     | `#D8DDE6`       | Borders (soft slate-blue) |
| text-main  | `#111827`       | Primary text (near-black) |
| text-sec   | `#4B5563`       | Secondary/label text |
| text-muted | `#6B7280`       | Muted/metadata text |
| sel-blue   | blue-50/blue-500| Selected state |
| danger     | red-50/red-600  | Blocked/hard-stop |
| warning    | amber-50/amber-700 | Gates 9/10/11 |
| success    | green-50/green-700 | Shipped/terminal |
| cloud      | orange-50/orange-700 | Cloud block stages |
| purple     | purple-50/purple-700 | Supervisor/disposition |

### Typography Minimums

| Element         | Current   | Target    |
|-----------------|-----------|-----------|
| Page title      | text-lg   | text-2xl  |
| Section headers | text-[10px] | text-xs (12px) |
| Unit IDs        | text-xs   | text-sm (14px) |
| Stage names     | implicit small | text-sm |
| Body/table text | text-xs   | text-sm   |
| Badges          | text-[10px] | text-xs (12px) |
| Form labels     | text-[10px] | text-xs (12px) |
| Form inputs     | text-xs   | text-sm   |
| Buttons         | text-xs   | text-sm   |

---

## Affected Components

### FactoryFlowBoard.tsx

- Root: `bg-[#FAFAF7] text-gray-900` (replaces `bg-gray-950 text-gray-100`)
- Add `data-theme="light-review"` and `data-d8a-readability="true"` to root div
- Header: `bg-white border-slate-200`, taller padding (`py-4`)
- Title: `text-2xl`
- Postgres-backed badge: `bg-blue-50 text-blue-700 border-blue-200`
- Subtitle: `text-gray-500 text-sm`
- Health/contract status: readable light-mode colors
- Reset button: `border-slate-300 bg-white hover:bg-slate-50 text-gray-700`
- Column borders: `border-slate-200`
- Column section headers: `text-xs text-gray-400`
- Wider columns for better stage/detail readability

### UnitList.tsx

- Default row: `bg-white border-slate-200 text-gray-700`
- Selected row: `bg-blue-50 border-blue-400 text-blue-900`
- Hover: `hover:border-slate-400 hover:bg-slate-50`
- Unit ID: `font-mono font-semibold text-gray-800 text-sm`
- BLOCKED badge: `bg-red-100 text-red-700 border-red-300`
- SHIPPED badge: `bg-green-100 text-green-700 border-green-300`
- Scenario label: `text-sky-600 text-xs`
- Order/stage/status meta: `text-gray-500 text-xs`
- Blocked reason: `text-red-600 text-xs`
- NO OVERRIDE: `text-red-700 font-bold`

### StageSpine.tsx

Remove `opacity-*` from all pending/completed rows.
Replace all dark backgrounds with light equivalents:

- Completed: `border-slate-200 bg-slate-50`
- Current (not blocked): `border-blue-400 bg-blue-50`
- Current + blocked: `border-red-400 bg-red-50`
- Gate pending (S-09/10/11): `border-amber-300 bg-amber-50`
- Cloud block pending (S-07/12): `border-orange-200 bg-orange-50`
- Terminal pending (S-14): `border-green-300 bg-green-50`
- Default pending: `border-slate-200 bg-white`

Stage name colors — light equivalents:
- Current not blocked: `text-blue-700`
- Current blocked: `text-red-700`
- Completed: `text-slate-500`
- Gate: `text-amber-700`
- Cloud: `text-orange-600`
- Terminal: `text-green-700`
- Default pending: `text-slate-400`

Badges — light equivalents:
- EXTERNAL: `bg-slate-100 text-slate-500 border-slate-300`
- GATE: `bg-amber-100 text-amber-700 border-amber-300`
- TERMINAL: `bg-green-100 text-green-700 border-green-300`
- CLOUD BLOCK (inactive): `bg-orange-100 text-orange-600 border-orange-300`
- CLOUD BLOCK (active): `bg-red-100 text-red-700 border-red-300`
- BLOCKED: `bg-red-100 text-red-700 border-red-300`
- NO OVERRIDE: `bg-red-600 text-white border-red-500` (keep prominent)
- SHIPPED: `bg-green-100 text-green-700 border-green-300`

Stage number: `text-slate-400`
Status dots — light equivalents: completed=slate-400, current=blue-500, blocked=red-500, pending=slate-300

### UnitDetailPanel.tsx

- Panel cards: `bg-white border-slate-200`
- Row separators: `border-slate-100`
- Label text: `text-gray-500`
- Value text: `text-gray-800 font-mono`
- Section headers: `text-xs text-gray-400`
- Block/Hard-Stop section header: `text-red-600`
- Block box: `bg-red-50 border-red-200`
- Blocked reason text: `text-red-700 font-semibold`
- NO OVERRIDE text: `text-red-700 font-bold`
- Success/color values: same semantic green/red/amber but light variants

### ActionPanel.tsx

- Form container: `bg-white border-slate-200`
- Form header: `text-gray-700 text-sm font-semibold`
- Endpoint line: `text-slate-400 text-xs`
- Labels: `text-gray-500 text-xs uppercase tracking-wide`
- Inputs/selects: `bg-slate-50 border-slate-300 text-gray-800 text-sm`
- Submit button: `bg-blue-600 hover:bg-blue-700 text-white text-sm`
- "No actions" message: `text-gray-400 text-sm`
- ResponseDisplay success: `border-green-300 bg-green-50`
- ResponseDisplay blocked: `border-red-300 bg-red-50`
- Response labels: `text-gray-500`
- Response values: `text-gray-700 font-mono`
- Status badge success: `bg-green-100 text-green-700 border-green-300`
- Status badge blocked: `bg-red-100 text-red-700 border-red-300`

### EventTrace.tsx

- Table header: `border-slate-200 text-gray-400`
- Row hover: `hover:bg-slate-50`
- Row separator: `border-slate-100`
- Selected unit row highlight: `bg-blue-50/50`
- Unit ID in selected row: `text-blue-600`
- Non-selected unit ID: `text-gray-600`
- Event ID: `font-mono text-gray-400`
- Stage ID: `font-mono text-gray-500`
- Message: `text-gray-700`
- Timestamp: `font-mono text-gray-400`
- Severity badges — light variants:
  - error: `text-red-600 border-red-200`
  - warning: `text-amber-600 border-amber-200`
  - info: `text-blue-600 border-blue-200`
  - default: `text-gray-500 border-gray-200`
- Count label: `text-gray-400`
- Show all/fewer button: `text-blue-600 hover:text-blue-700`

---

## Acceptance Criteria

- [ ] UI is light mode by default
- [ ] Page background is off-white (#FAFAF7), not pure white, not dark
- [ ] data-theme="light-review" present on root div
- [ ] data-d8a-readability="true" present on root div
- [ ] Page title is 22–24px (text-2xl)
- [ ] Body text is minimum 14px (text-sm) throughout
- [ ] Section headers are minimum 12px (text-xs)
- [ ] Badge text is minimum 12px (text-xs)
- [ ] Blocked/hard-stop state is visually obvious (red tones, light background)
- [ ] NO OVERRIDE is visually prominent
- [ ] Gate stages 9/10/11 show amber treatment in light mode
- [ ] Cloud block stages 7/12 show orange/red treatment in light mode
- [ ] Terminal stage 14 shows green treatment in light mode
- [ ] All 001–008 verification scripts still pass
- [ ] 009-light-mode-readability.sh created and passes (18 checks)
- [ ] No backend changes introduced
- [ ] No new npm packages added
- [ ] No Azure SDK added
- [ ] No auth added
- [ ] OS state RELEASE_APPROVED for light-mode-readability-d8a

---

## Verification Protocol

`scripts/verification/009-light-mode-readability.sh` — 18 checks:

V1: frontend root loads (200)
V2: page contains "Factory Cloud"
V3: page contains "D8 Review Prototype"
V4: page contains "light-review" (data-theme marker)
V5: page contains "d8a-readability" (data-d8a marker)
V6: index.html does not contain "bg-gray-950" as root class (dark bg removed)
V7: backend health ok
V8: data-contract/status 200
V9: stage_count = 14
V10: unit_count >= 7
V11: D4 verification passes
V12: D5 verification passes
V13: D6 verification passes
V14: D7 verification passes
V15: D8 verification passes
V16: smoke passes
V17: no Azure SDK
V18: no auth/session implementation

---

## Entry and Exit Conditions

**Entry:** D8 is RELEASE_APPROVED. All 001–008 verifications pass. Stack is live.

**Exit:** All 001–009 verifications pass. OS state = RELEASE_APPROVED for
light-mode-readability-d8a. Journal Entry 012 appended. README, repo-index,
architecture-index updated. docs/light-mode-readability-d8a.md created.
