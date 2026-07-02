# Task: Implement touch-first responsive shell and component adaptation across the Factory Cloud frontend

## Parent Spec
specs/touch-first-responsive-factory-ui-d8c.md

## Phase
phase-ui

## Status
done

## Layer
frontend

## Description

Implement the full touch/responsive contract defined in
`specs/touch-first-responsive-factory-ui-d8c.md`, grounded in
`ai/recon/d8c-touch-first-responsive-ui-recon.md`. This is one frontend layer task
covering four ordered sub-steps (all in this task, executed in this order so later
steps can rely on the breakpoint/utility foundation from the first):

**Sub-step A — Responsive shell + breakpoint foundation.**
In `frontend/src/components/FactoryFlowBoard.tsx`: add `data-d8c-touch-responsive="true"`
to the root element (alongside the existing `data-d8-demo-readiness`,
`data-d8a-readability`, `data-d8b-material-theme` markers). Replace the fixed
`w-64`/`w-80` `flex-shrink-0` columns with width-aware classes using Tailwind's
existing default breakpoints (`lg:`, `xl:`) plus one `min-[1600px]:` arbitrary variant
for the Large Workstation band — no `tailwind.config.js` edit. Implement the
compact-width (<1024px) recomposition: Detail+Action becomes the full-width primary
view; Unit Queue becomes a collapsible drawer/top selector; Stage Spine becomes a
secondary tab/pane; Event Trace becomes reachable via tab/disclosure. Bump header
Reset/Theme buttons and add two new utility classes to `frontend/src/styles.css`:
`.touch-target-primary { min-height:48px; min-width:48px }` and
`.touch-target-secondary { min-height:44px; min-width:44px }` — additive to the
existing `surf-*`/`t-on-*`/`b-*`/`mdc-*` classes, no changes to the `--mds-*`/
`--factory-*` token system or `[data-theme]` mechanism.

**Sub-step B — Header, UnitList, StageSpine touch pass.**
Apply `.touch-target-primary`/`.touch-target-secondary` to header controls. In
`frontend/src/components/UnitList.tsx`: add an explicit `min-h-[48px]` floor to the
row `<button>` (content-height alone isn't guaranteed for short labels per recon).
In `frontend/src/components/StageSpine.tsx`: implement the compact-width tab/pane
presentation decided in Sub-step A; keep rows non-interactive (no `onClick`, no
`<button>`) — informational only, per current design; preserve all 14 stage
names/numbers, gate (9,10,11), cloud-block (7,12), external/separable, and terminal
(14) badge rendering exactly as today.

**Sub-step C — UnitDetailPanel + ActionPanel touch pass.**
In `frontend/src/components/UnitDetailPanel.tsx`: increase visual prominence of
`blocked_reason`, `block_type`, and the "NO OVERRIDE" line (currently `text-sm`,
same size as every other row per recon) without breaking the flat key/value row
pattern; add optional disclosure for secondary sections (Part Allocations,
Calibration, Quality Control, Cloud/Ship) at compact widths only. In
`frontend/src/components/ActionPanel.tsx`: raise all `SubmitBtn` instances from
~36px to ≥48px height (`.touch-target-primary`); wrap the Cloud Backup checkbox in a
touch-safe padded target; keep `w-full` layout; audit `space-y-2.5` panel spacing
against the 8px min/12px preferred contract (currently compliant, verify it stays so
after sizing changes). Do not add any client-side legality/workflow logic — every
existing `factoryApi.ts` call and its request/response shape is preserved exactly.

**Sub-step D — EventTrace responsive adaptation.**
In `frontend/src/components/EventTrace.tsx`: replace the `<table>`/`overflow-x-auto`
rendering with a responsive stacked card/list representation at compact widths
(<1024px), preserving all six fields (Event ID, Unit, Stage, Sev, Message,
Timestamp), the selected-unit-first filtering logic, and the show-all/show-fewer
toggle behavior exactly. Give the show-all toggle an explicit `.touch-target-secondary`
hit area (currently plain text with no enforced size, per recon). At ≥1024px the
existing table presentation may be retained if it does not overflow.

Across all sub-steps: no `hover:`-gated critical content may be introduced (recon
confirms zero exists today — do not regress this). All new interactive elements are
real `<button>` elements with visible focus states. No file under `backend/` is
touched. No endpoint in `frontend/src/api/factoryApi.ts` is added, removed, or
changed.

## Acceptance Criteria
- [ ] `data-d8c-touch-responsive="true"` present on `FactoryFlowBoard.tsx` root element.
- [ ] No page-level horizontal overflow at 768×1024, 1024×768, 1180×820, 1280×800, 1440×900, 1920×1080 (verified in Task 002).
- [ ] At <1024px, Unit Queue and Stage Spine are not both simultaneously fixed-width-docked alongside Detail+Action — compact recomposition is in effect.
- [ ] All primary controls (submit buttons, reset demo, theme toggle, unit-row selection) have computed `min-height`/`min-width` ≥48px via `.touch-target-primary` or equivalent explicit sizing.
- [ ] All secondary controls (EventTrace show-all toggle, any new disclosure controls) have computed size ≥44px via `.touch-target-secondary` or equivalent.
- [ ] `blocked_reason` and "NO OVERRIDE" render with greater visual prominence than a plain `Row` in `UnitDetailPanel.tsx`.
- [ ] `EventTrace.tsx` renders a non-table stacked representation at <1024px with all six fields intact.
- [ ] All 14 stage names/numbers, gate/cloud-block/external/separable/terminal badges remain rendered by `StageSpine.tsx` at every breakpoint.
- [ ] `frontend/src/api/factoryApi.ts` unchanged (no endpoint added/removed/modified).
- [ ] No file under `backend/` modified.
- [ ] `[data-theme]`, `--mds-*`/`--factory-*` tokens, and `localStorage['factory-theme']` mechanism unchanged.
- [ ] `frontend/src/styles.css` gains only additive utility/breakpoint classes — no removal of existing `.mdc-*`/`.surf-*`/`.t-on-*`/`.b-*` classes or their `:focus` rules.

## Files Likely Affected
- frontend/src/components/FactoryFlowBoard.tsx
- frontend/src/components/UnitList.tsx
- frontend/src/components/StageSpine.tsx
- frontend/src/components/UnitDetailPanel.tsx
- frontend/src/components/ActionPanel.tsx
- frontend/src/components/EventTrace.tsx
- frontend/src/styles.css
- frontend/index.html (only if a new meta marker proves necessary)

## Blocked By
- none
