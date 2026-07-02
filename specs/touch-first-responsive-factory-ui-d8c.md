# Spec: Touch-First Responsive Factory UI

## Status
approved

## Phase
phase-ui

## Feature
touch-first-responsive-factory-ui-d8c

## Capability

Today the Factory Cloud frontend (`FactoryFlowBoard.tsx`) is a single fixed desktop
layout: two `flex-shrink-0` columns of 256px (Unit Queue) and 320px (Stage Spine), a
flexible Detail+Action column, and a fixed-height Event Trace footer — with zero
responsive breakpoints, zero enforced touch-target sizing, and one component
(`EventTrace.tsx`) rendered as an HTML `<table>` inside a horizontal-scroll wrapper.
Confirmed by full-file recon (`ai/recon/d8c-touch-first-responsive-ui-recon.md`): no
`@media` query and no Tailwind responsive prefix exists anywhere in the app; every
interactive control (header buttons, action submit buttons, form inputs, the event
trace "show all" toggle) is sized below the 44–48px touch-target range; the two fixed
columns make any viewport under ~750–800px overflow horizontally.

After this capability, the same frontend becomes usable as a **touch-first factory
workstation UI** from 768px landscape up through 1920px+ desktop, while remaining
fully usable with mouse and keyboard: primary controls meet a 48×48px minimum, no
supported viewport has page-level horizontal overflow, the compact width band
reflows the fixed three-column desktop shell into a priority-ordered single-focus
layout (current unit → block/attention state → current stage → required action →
progress → supporting detail → event history) instead of naively shrinking it, and
the existing D8B Material-inspired light/dark theme system is preserved unchanged.

## Source Authority

- `docs/factory-flow-model.md`, `docs/domain-glossary.md`, `docs/decision-lock.md` — read-only domain authority, unaffected by this capability.
- `ai/product-invariants.md`, `ai/runtime-contracts.md`, `ai/service-boundaries.md` — governing invariants; see Dependencies.
- `docs/factory-review-hardening-d8.md`, `docs/light-mode-readability-d8a.md`, `docs/material-theme-readability-d8b.md` — presentation-layer precedent this capability builds on.
- `ai/recon/d8c-touch-first-responsive-ui-recon.md` — full grounded recon for this capability.

## Current Problem

1. Fixed-width columns (`w-64`, `w-80`, both `flex-shrink-0`) guarantee horizontal
   overflow below ~750–800px.
2. No breakpoint exists anywhere — the layout does not change shape at any width.
3. Every interactive control is undersized for touch: header Reset/Theme buttons
   (~30–32px), ActionPanel submit buttons (~36px), the checkbox in the Cloud Backup
   form (browser default, ~13–16px), and the EventTrace "Show all" toggle (plain text,
   no enforced hit area).
4. `EventTrace.tsx` renders a 6-column `<table>` inside `overflow-x-auto` — unusable
   on a compact touch display.
5. Four independent vertical scroll regions plus one horizontal scroll region are
   simultaneously live today — acceptable on desktop, a scroll-capture hazard on touch.

## Non-Goals / Out of Scope

- Production authentication, role-specific login routing, assembler-only or
  floor-manager-only applications, admin/sales/customer dashboards, inventory app,
  eStore.
- Device-to-cloud real-time messaging, notification severity levels, assembly work
  instructions, CAD/3D rendering.
- Azure deployment or any external integrations.
- Any change to backend workflow rules, the canonical 14-stage spine, PostgreSQL
  schema, seed data, or any REST endpoint (`frontend/src/api/factoryApi.ts`'s 20
  existing endpoints are exercised as-is, none added or changed).
- Mobile-phone-first optimization — minimum supported width is 768px landscape, not
  narrow phone widths.

## Data Model Changes
none

## API Surface
none

## Frontend Surface

All work is confined to the existing Factory Cloud presentation layer, no new
pages/routes:

- `frontend/src/components/FactoryFlowBoard.tsx` — responsive shell, breakpoint-aware
  composition of the existing five child components, `data-d8c-touch-responsive="true"`
  marker, touch-safe header controls.
- `frontend/src/components/UnitList.tsx` — touch-safe row sizing (`min-h` floor),
  compact-width presentation (drawer/top-selector/pane, decided during implementation
  per the Compact Layout Strategy below).
- `frontend/src/components/StageSpine.tsx` — touch-safe scrolling/presentation at
  compact widths (collapsible/tab/pane), badge legibility preserved, remains
  non-interactive (informational) per current design.
- `frontend/src/components/UnitDetailPanel.tsx` — grouped responsive sections,
  increased visual prominence for blocked_reason / block_type / NO OVERRIDE, optional
  disclosure for secondary sections at compact widths.
- `frontend/src/components/ActionPanel.tsx` — 48px-minimum submit controls, touch-safe
  checkbox/inputs, preserved full-width layout, no new legality logic (backend remains
  sole authority for all 20 action/read endpoints).
- `frontend/src/components/EventTrace.tsx` — responsive list/card representation at
  compact widths replacing the raw `<table>`, touch-safe "show all" toggle.
- `frontend/src/styles.css` (the real stylesheet — `frontend/src/index.css` does not
  exist in this repo; see recon) — two new touch-target utility classes, breakpoint
  helper classes, no changes to the existing `--mds-*`/`--factory-*` theme token
  system or `[data-theme]` mechanism.
- `frontend/index.html` — no change expected (viewport meta already correct); touched
  only if a new marker/meta tag proves necessary during implementation.
- `frontend/package.json`, new `frontend/playwright.config.ts`, new
  `frontend/tests/d8c-touch-responsive.spec.ts` — minimum devDependency addition
  (`@playwright/test`) to make the required browser/viewport verification real and
  repeatable, since no browser-automation tooling exists in this repo today (recon
  confirmed via `package.json` read and filesystem search).

No new role concept is introduced. No route/navigation change. No component is
removed; `AppShell.tsx`, `D5BackendStatus.tsx`, `HealthStatus.tsx`, and the
`DataContractStatus` component file are confirmed dead/unwired (not imported
anywhere) and remain untouched — out of scope.

## Supported Screen Range

Approximately 11-inch to 21-inch touchscreen displays, landscape orientation.

## Minimum Supported Width

768px landscape. Below this width a clear minimum-width message is acceptable; a
broken compressed interface is not. D8C does not optimize for narrow mobile-phone
widths.

## Viewport Matrix (required verification set)

768×1024, 1024×768, 1180×820, 1280×800, 1440×900, 1920×1080 — each checked in both
light and dark theme.

## Breakpoint Contract

Uses Tailwind's existing default scale (`tailwind.config.js` extends nothing today —
confirmed by recon) rather than introducing a parallel breakpoint system:

| Band | Width | Tailwind mechanism |
|---|---|---|
| Compact / Tablet Landscape | 768px–1023px | base (no prefix) |
| Standard Workstation | 1024px–1599px | `lg:` (1024px) / `xl:` (1280px) |
| Large Workstation | ≥1600px | `min-[1600px]:` arbitrary variant (no config edit required) |

## Touch-Target Contract

- Primary controls (submit/action buttons, reset demo, unit-row selection, theme
  toggle, major segmented controls, expandable-section controls, approval/disposition
  controls): **minimum 48×48 CSS px**.
- Secondary controls (filters, toggles, disclosure controls, auxiliary nav, the
  EventTrace show-all toggle): **minimum 44×44 CSS px**.
- Adjacent interactive controls: 8px minimum / 12px preferred separation; conflicting
  or destructive actions must not sit close enough to invite accidental activation.
- Form controls: 48px minimum height, 16px input text, persistent labels (already the
  case — no placeholder-only fields exist today), visible focus (already implemented
  via `.mdc-input`/`.mdc-select` `:focus` outline — must be preserved, not overridden).
- Implementation mechanism: two new utility classes in `styles.css`
  (`.touch-target-primary { min-height:48px; min-width:48px }`,
  `.touch-target-secondary { min-height:44px; min-width:44px }`) applied alongside the
  existing `surf-*`/`t-on-*`/`b-*`/`mdc-*` classes — additive, not a token-system
  rewrite.

## Responsive Layout Behavior / Component Adaptation Plan

- **Large Workstation (≥1600px):** current desktop four-region layout (Unit Queue |
  Stage Spine | Detail+Action | Event Trace footer), effectively unchanged, column
  ratios may widen slightly.
- **Standard Workstation (1024–1599px):** same four-region layout, Unit Queue and
  Stage Spine columns narrow from 256px/320px toward a tighter width so Detail+Action
  is never truncated; StageSpine's existing `flex-wrap` badge row absorbs the
  narrower width.
- **Compact / Tablet Landscape (768–1023px):** Detail+Action becomes the full-width
  primary view. Unit Queue becomes a collapsible drawer/top selector (current unit
  always visible via a persistent compact header strip). Stage Spine becomes a
  secondary tab/pane reachable from the detail view, not permanently docked. Event
  Trace becomes reachable via a tab/disclosure rather than a permanently-visible
  footer. `EventTrace.tsx`'s `<table>` becomes a stacked card/list representation at
  this band (columns collapse into a labeled multi-line card per event, preserving
  severity/stage/actor/timestamp/message).
- Below 768px: a minimum-width message, not a broken compressed layout.

## Actor-Priority Behavior

No authentication or role routing is introduced (confirmed: no `jwt`/session/OAuth2
pattern exists in `backend/app/`). At compact widths only, visual priority follows:
current unit → block/attention state → current stage → required action → progress
context → supporting unit detail → event history → full 14-stage engineering view
(still reachable, not removed). This is implemented as a `FactoryFlowBoard.tsx`-local
view-mode/active-pane UI state, not a new role or permission concept.

## Accessibility Rules

- Logical tab order preserved; no focus traps.
- Visible focus state preserved on all controls, including new compact-mode
  disclosure/tab controls (must be real `<button>` elements, not `<div onClick>`).
- No information becomes hover-only. Recon confirmed zero hover-gated content exists
  today (only `:hover` color transitions) — the compact/touch pass must not introduce
  a hover-only regression (e.g. must not hide blocked_reason behind a hover tooltip).
- `StageSpine` rows remain non-interactive/non-focusable even when moved into a new
  compact tab/pane container — they must not become accidentally actionable.
- Keyboard Enter/Space activation preserved for all buttons (native `<button>` usage,
  no custom click-only widgets).

## Theme-Preservation Rules

The D8B Material-inspired `--mds-*`/`--factory-*` CSS custom-property token system,
the `[data-theme]` attribute mechanism on `document.documentElement`, the
`localStorage['factory-theme']` persistence, and the inline pre-paint script in
`index.html` are all preserved exactly as-is. `tailwind.config.js`'s `darkMode: false`
(confirmed set) is not changed. No Material UI (MUI) library is installed. All new
responsive/touch CSS is layout-only (flex/grid/width/min-height/breakpoint) and
reuses existing `surf-*`/`t-on-*`/`b-*` semantic classes for any new visual state
(e.g. a new compact-mode drawer) rather than introducing hardcoded colors.

## Backend Non-Change Contract

No file under `backend/` is modified. No PostgreSQL schema, Alembic migration, or
seed data changes. No new or modified REST endpoint — `factoryApi.ts`'s 20 existing
endpoints (enumerated in recon) are the complete, unchanged API surface this
capability calls. No workflow legality, hard-stop, calibration-retry, QC, or
cloud-block logic moves into the frontend; the frontend continues to only display
backend-computed state and submit operator actions via existing endpoints
(Invariant 2 / Runtime Contract 3).

## Operational Workflow

1. Operator opens Factory Cloud at any viewport from 768px to 1920px+, in light or
   dark theme.
2. At ≥1600px, the operator sees the full four-region desktop layout as today (Unit
   Queue, Stage Spine, Detail+Action, Event Trace), with all controls now touch-safe.
3. At 1024–1599px, the same four regions remain simultaneously visible with adjusted
   column widths; no control is clipped or truncated.
4. At 768–1023px, the operator lands on the current unit's Detail+Action view by
   default; they can reach the Unit Queue via a drawer/selector, the Stage Spine via a
   tab/pane, and Event History via a tab/disclosure — all reachable without losing
   sight of the current unit, its block state, and its required action.
5. The operator selects a unit (full-row touch target, ≥48px), sees its blocked
   reason / NO OVERRIDE (if any) prominently, reaches the current action form (all
   controls ≥48/44px, 8–12px spacing), submits it (existing backend endpoint,
   unchanged request/response shape), and sees the backend response (status, message,
   event ID, blocked reason, no-override) — all without needing a mouse or hover.
6. The operator can toggle light/dark theme (touch-safe control), reload, and the
   preference persists (existing `localStorage` mechanism, unchanged).
7. The operator can reset demo state via a touch-safe control (existing
   `postResetState()` endpoint, unchanged).
8. Mouse and keyboard operation continue to work identically to today at every width.

## Dependencies

- `ai/product-invariants.md` Invariant 2 (Backend Owns State Transitions) — this
  capability adds no client-side stage-advance logic.
- `ai/runtime-contracts.md` Contract 2 (Frontend Communicates via REST API Only) and
  Contract 3 (Backend Owns All Factory State Transitions) — unaffected, no new call
  patterns introduced.
- `ai/service-boundaries.md` — frontend/backend boundary unaffected.
- Prior specs `docs/factory-review-hardening-d8.md`, `light-mode-readability-d8a.md`,
  `material-theme-readability-d8b.md` — this capability is additive to their output,
  does not supersede or revert any of their acceptance criteria.
- `ai/recon/d8c-touch-first-responsive-ui-recon.md` — full grounding for every claim
  in this spec.

## Acceptance Criteria

- [ ] `data-d8c-touch-responsive="true"` present on the `FactoryFlowBoard.tsx` root element.
- [ ] No supported viewport (768×1024, 1024×768, 1180×820, 1280×800, 1440×900, 1920×1080) has page-level horizontal overflow (`document.documentElement.scrollWidth <= document.documentElement.clientWidth`), in both themes.
- [ ] At 768–1023px, the full desktop three-column layout is not force-rendered (Unit Queue and Stage Spine are not both simultaneously fixed-width-visible alongside Detail+Action without reflow).
- [ ] All primary controls (submit buttons, reset demo, theme toggle, unit-row selection) measure ≥48×48 CSS px via computed bounding box.
- [ ] All secondary controls (EventTrace show-all toggle, disclosure controls) measure ≥44×44 CSS px.
- [ ] Selected unit remains visually obvious at every supported viewport.
- [ ] Current stage remains visually obvious at every supported viewport.
- [ ] Current/required action remains visually obvious and reachable without excessive scrolling at every supported viewport.
- [ ] blocked_reason and NO OVERRIDE remain visible (not hover-gated) at every supported viewport, for a blocked unit (e.g. UNIT-0004 calibration-cap scenario).
- [ ] Full 14-stage spine remains reachable (not removed) at every supported viewport.
- [ ] Event history remains reachable (not removed) at every supported viewport.
- [ ] Light theme and dark theme both remain fully readable; theme toggle works; preference persists across reload (`localStorage['factory-theme']`).
- [ ] Reset Demo State control works and is touch-safe.
- [ ] Mouse click interaction remains fully functional (no touch-only regression).
- [ ] Keyboard focus remains visible on every interactive control; tab order remains logical; no focus traps.
- [ ] No content depends on `:hover` for critical information (blocked reason, no-override, current action, stage/unit status).
- [ ] `frontend/src/api/factoryApi.ts`'s 20 endpoints are unchanged (byte-for-byte diff limited to non-behavioral formatting if any).
- [ ] Zero files under `backend/` modified; zero schema/migration/seed changes.
- [ ] Verification scripts 001–010 (or the project's existing D4–D8B chain) all still pass.
- [ ] New `scripts/verification/011-touch-first-responsive-ui.sh` passes.
- [ ] `bash scripts/smoke.sh` passes.
- [ ] Vendored Engineering OS core (`vendor/engineering-os/`) unmodified.
- [ ] Capability reaches `RELEASE_APPROVED` in `ai/state_registry.json`.

## Browser Verification Plan

Since no Playwright or browser-automation dependency exists in this repo today
(confirmed by recon), this capability adds `@playwright/test` as a minimal
`frontend`-local devDependency plus one config and one spec file
(`frontend/tests/d8c-touch-responsive.spec.ts`), run against the live
`docker compose` stack (`postgres` + `backend:8000` + `frontend:5173`, confirmed
runnable per `docker-compose.yml`). The spec exercises the full viewport matrix above
in both themes and asserts: no horizontal overflow, unit selection works, blocked
reason/no-override visible, control bounding boxes meet the 48/44px contract, theme
toggle + reload persistence, reset-demo works, stage spine and event history remain
reachable. `scripts/verification/011-touch-first-responsive-ui.sh` invokes this suite
alongside the existing curl/grep-based static checks (following the exact convention
of scripts 006/008/009/010) and chains the full 001–010 regression. Screenshots are
captured under `artifacts/d8c-touch-verification/` for at least: compact light,
compact dark, standard light, standard dark, large workstation light, blocked-unit
compact view, action-panel compact view.

## Regression Plan

Full existing chain must still pass unweakened: 001-docker-compose-config,
002-backend-health, 003-frontend-reachable, 004-data-contract-api,
005-backend-state-behavior, 006-factory-flow-board-ui, 007-persistence-postgres,
008-demo-readiness, 009-light-mode-readability, 010-material-theme-readability, plus
the new 011, plus `scripts/smoke.sh`, plus `scripts/invariant-check.sh` (6/6). No
prior verification script is weakened to obtain a pass; if a prior script encodes a
presentation assumption D8C intentionally supersedes, the change is documented before
mutation (recon found no such conflict — see recon "Stop Conditions Checked").

## Capability Phase Boundary

D8C prepares the shared Factory Cloud frontend for touchscreen factory use. It does
not implement production authentication, role-specific login routing, an
assembler-only or floor-manager-only application, admin/sales/customer dashboards,
inventory app, eStore, device-to-cloud real-time messaging, notification severity
levels, assembly work instructions, CAD/3D rendering, Azure deployment, or external
integrations. These require explicit later directives.

## Next-Phase Handoff

On `RELEASE_APPROVED`, the frontend is touch-and-mouse usable from 768px to 1920px+
with the actor-priority compact behavior in place as groundwork for a future
actor-specific (assembler/floor-manager) UI split — without that split, any new
authentication, or any role concept having been introduced in this phase.

## Out of Scope

See Non-Goals above: production auth/role routing, actor-specific applications,
device-to-cloud messaging, work instructions/CAD rendering, Azure deployment, external
integrations, and mobile-phone-first optimization below 768px.
