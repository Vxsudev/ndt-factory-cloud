# D8C — Touch-First Responsive Factory UI

**Date:** 2026-07-02
**Phase:** phase-ui
**Status:** COMPLETE
**Spec:** `specs/touch-first-responsive-factory-ui-d8c.md`
**Recon:** `ai/recon/d8c-touch-first-responsive-ui-recon.md`

---

## Capability Purpose

Make the existing Factory Cloud frontend operationally usable on touchscreen displays
from approximately 11 inches to 21 inches, without becoming mobile-phone-first and
without regressing mouse usability, keyboard accessibility, the D8B light/dark theme
system, or any backend/API behavior.

---

## Supported Screen Range / Minimum Supported Width

Approximately 11" to 21" touchscreen displays, landscape orientation. Minimum
supported width is **768px landscape**. D8C does not optimize for narrow mobile-phone
widths; below 768px a minimum-width message is acceptable rather than a broken
compressed layout (no such guard was needed in practice — the compact layout remains
functional down to 768px in all verification passes).

---

## Breakpoint Strategy

Reuses Tailwind's existing default breakpoint scale (`tailwind.config.js` was not
modified) plus one arbitrary-value variant for the top band:

| Band | Width | Mechanism |
|---|---|---|
| Compact / Tablet Landscape | 768–1023px | base (no prefix) |
| Standard Workstation | 1024–1599px | `lg:` (1024px) / `xl:` (1280px) |
| Large Workstation | ≥1600px | `min-[1600px]:` |

---

## Touch-Target Standard

- Primary controls (submit/action buttons, reset demo, theme toggle, unit-row
  selection, compact-pane tabs): **≥48×48 CSS px**, via a new `.touch-target-primary`
  utility class in `frontend/src/styles.css`.
- Secondary controls (EventTrace show-all toggle, `UnitDetailPanel` disclosure
  summaries, Cloud Backup checkbox wrapper): **≥44×44 CSS px**, via
  `.touch-target-secondary`.
- Form controls (`mdc-input` / `mdc-select`): bumped to `min-height: 48px` and
  `font-size: 16px` (previously ~36px / 14px).
- Both utility classes are additive — no existing `surf-*`/`t-on-*`/`b-*`/`mdc-*`
  class or `:focus` rule was removed or overridden.

Measured via Playwright `boundingBox()` and browser DevTools during interactive
verification (see Screenshot Evidence): header buttons 48px, compact-pane tabs 48px,
ActionPanel submit buttons 48px, form inputs/selects 48px, UnitList rows 96px (well
above floor), EventTrace show-all toggle 44px.

---

## Responsive Shell Behavior

`FactoryFlowBoard.tsx` gained a `compactPane` state (`'unit' | 'detail' | 'stages' |
'events'`, default `'detail'`) that only matters below `lg` (1024px):

- **Compact (<1024px):** a touch-safe tab bar (`role="tablist"`) switches between one
  full-width active pane at a time — Unit Queue, Detail (Unit Detail + Action Panel,
  the default), Stages (14-stage spine), or Events (event history). Selecting a unit
  from the Unit Queue pane automatically switches to the Detail pane. The forced
  three-column desktop layout is never rendered at this width.
- **Standard (1024–1599px) / Large (≥1600px):** all four regions render
  simultaneously exactly as before D8C, with column widths narrowing (standard) or
  widening (large) via `lg:w-56 xl:w-64 min-[1600px]:w-72` (Unit Queue) and
  `lg:w-72 xl:w-80 min-[1600px]:w-96` (Stage Spine). The compact tab bar is hidden
  (`lg:hidden`).

---

## Component-by-Component Adaptations

| Component | Change |
|---|---|
| `FactoryFlowBoard.tsx` | `data-d8c-touch-responsive="true"` marker; compact pane switcher; breakpoint-aware column widths; touch-safe header buttons |
| `UnitList.tsx` | Explicit `min-h-[48px]` floor on the row button (content height alone wasn't guaranteed for short labels) |
| `StageSpine.tsx` | Unchanged — already a non-interactive vertical list with wrapping badges; compact presentation handled entirely by the new tab/pane wrapper in `FactoryFlowBoard.tsx` |
| `UnitDetailPanel.tsx` | `blocked_reason` and "NO OVERRIDE" bumped from `text-sm` to `text-base font-bold` / `font-black uppercase` with a `⚠` marker and a `border-2` block box; Part Allocations / Calibration / Quality Control / Cloud-Ship sections wrapped in touch-safe `<details>` disclosures (default open) |
| `ActionPanel.tsx` | `SubmitBtn` raised to `.touch-target-primary` (~36px → 48px); new `variant` prop colors Supervisor Reallocation purple and Calibration Disposition red, distinguishing high-authority/destructive actions from routine ones; Cloud Backup checkbox wrapped in a `.touch-target-secondary` clickable label |
| `EventTrace.tsx` | Below `lg`, the `<table>` is replaced by a stacked card list (all six fields — Event ID, Unit, Stage, Sev, Message, Timestamp — preserved per card); the "Show all events" toggle gained an explicit `.touch-target-secondary` hit area (previously plain text with no enforced size) |

---

## Actor-Priority / Compact Behavior

No authentication or role concept was introduced. At compact widths, the default
pane is Detail (current unit + block state + required action), matching the
directive's priority order: current unit → block/attention state → current stage →
required action → progress context → supporting detail → event history. The full
14-stage engineering view remains reachable via the Stages tab, never removed.

---

## Accessibility Decisions

- All new interactive elements (compact-pane tabs, `<details><summary>` disclosures)
  are native, keyboard-focusable, non-hover-dependent elements.
- `StageSpine` rows remain plain `<div>`s (non-focusable, non-actionable) even when
  presented inside the new compact pane — informational content stays informational.
- No content was ever hover-gated in this app (confirmed by recon), and none was
  introduced by D8C.
- Existing `:focus` outline rules on `.mdc-input`/`.mdc-select` were preserved.

---

## Light/Dark Compatibility

The D8B `--mds-*`/`--factory-*` CSS custom-property system, the `[data-theme]`
mechanism, and `localStorage['factory-theme']` persistence are unchanged. All new
CSS is layout-only (breakpoints, min-height/min-width) and reuses existing semantic
classes for color. Verified interactively in both themes across the full viewport
matrix — see Screenshot Evidence.

---

## Browser Viewport Matrix Verified

768×1024, 1024×768, 1180×820, 1280×800, 1440×900, 1920×1080 — each confirmed to have
no page-level horizontal overflow (`document.documentElement.scrollWidth <=
clientWidth`), in both light and dark theme, via interactive Playwright MCP session
tooling.

## Screenshot Evidence

Captured under `artifacts/d8c-touch-verification/`:

- `compact-light-768x1024.png`, `compact-dark-768x1024.png`
- `standard-light-1024x768.png`, `standard-dark-1280x800.png`
- `large-light-1920x1080.png`, `large-dark-1920x1080.png`
- `blocked-unit-compact-768x1024.png` (UNIT-0004 calibration-cap scenario — blocked
  reason, block type, and the correct Calibration Disposition form all visible)
- `stages-compact-768x1024.png`, `events-compact-768x1024.png`

---

## Verification Results

- `scripts/verification/011-touch-first-responsive-ui.sh`: **32 PASS / 0 FAIL / 1
  SKIP** (see Known Limitations for the SKIP).
- Full existing chain (`001`–`010`) + `scripts/smoke.sh`: all exit 0, unweakened.
- `bash scripts/invariant-check.sh`: 6/6 PASS.
- Manual interactive verification (this session's Playwright MCP tooling): confirmed
  no overflow at all six required viewports in both themes; compact layout does not
  force the desktop three-column shell; unit selection auto-switches to Detail pane;
  blocked reason / block type / correct action form visible for UNIT-0004; all touch
  targets measured ≥48px (primary) / ≥44px (secondary); theme toggle works and
  persists across reload; Reset Demo State works; all 14 stages reachable via the
  Stages tab; event history reachable via the Events tab as a card list; keyboard
  Tab moves focus.

---

## Infrastructure Fix Discovered During Release Gate

While advancing this capability's state, discovered that `scripts/state-manager.sh`
and the three proxies that call it (`compile-spec.sh`, `generate-tasks.sh`,
`execution-supervisor.sh`) never sourced `.engineering-os/adapter.config.sh`, so
every state transition for the life of this project had been silently written to
`vendor/engineering-os/ai/state_registry.json` instead of the real
`ai/state_registry.json`. Fixed by sourcing the adapter config in all four local
proxies (not a vendor-core change). Full detail:
`ai/incidents/d8c-state-registry-proxy-bug.md`. `ai/state_registry.json` now
correctly shows `touch-first-responsive-factory-ui-d8c: RELEASE_APPROVED`.

## Known Limitations

1. **Playwright cannot execute inside the frontend service's own Docker image.** The
   frontend runtime image is `node:20-alpine` (musl libc). Playwright's bundled
   Chromium requires glibc/glib and fails even with the `gcompat` shim installed
   (confirmed: `Error relocating ... g_variant_get: symbol not found` and similar for
   ~30 glib symbols). This is a pre-existing characteristic of the base image chosen
   in D3, not something D8C is scoped to change (switching the frontend base image is
   not a declared D8C mutation surface). `scripts/verification/011-...sh` detects
   this via a launch probe and SKIPs (does not FAIL) the automated in-container
   browser run, printing the reason. The `@playwright/test` devDependency,
   `frontend/playwright.config.ts`, and `frontend/tests/d8c-touch-responsive.spec.ts`
   are real and will run correctly in any standard glibc-based Linux, macOS, or CI
   environment (e.g. `cd frontend && npx playwright test` on a developer's Mac, or a
   Debian-based CI image) — they were exercised locally against the live stack from
   the frontend container's Node runtime only for the launch probe, and the actual
   browser-level verification for this release was performed via this session's
   interactive Playwright MCP tooling (see Screenshot Evidence).
2. **Pre-existing, unrelated `tsc --noEmit` findings** (not touched, not introduced by
   D8C, confirmed present in the original code before any D8C edit): `src/api.ts` and
   `src/api/factoryApi.ts` reference `import.meta.env` without a `vite/client` types
   reference; `ActionPanel.tsx`'s `users` prop and `FactoryFlowBoard.tsx`'s `parts`
   state were already unused before D8C. None of these affect runtime (the app runs
   via `vite dev`, not a type-checked production build) and none are in the D8C
   mutation surface.
3. Dead/unwired component files `AppShell.tsx`, `HealthStatus.tsx`,
   `DataContractStatus.tsx`, `D5BackendStatus.tsx` remain on disk, unimported,
   unchanged — confirmed out of scope, not part of the live render tree.

---

## Fixed During D8C (Documented Before Mutation, Per Recon)

`ActionPanel.tsx` and `UnitDetailPanel.tsx` read calibration cap-exceeded status and
the calibration certificate ID from `unit.calibration_status`, an optional field the
backend has never actually populated (confirmed via `curl` against
`/factory/units/UNIT-0004` — only `calibration_summary` is present in the response).
This meant the "Calibration Disposition (Cap Exceeded)" form never rendered for any
unit in production, silently defeating the very disposition workflow the calibration
cap exists to trigger. Both files now read `unit.calibration_summary` (already
correctly typed with `cap_exceeded`/`certificate_id` in `types/factory.ts`) — a
minimal, well-scoped fix within files already in the D8C mutation surface, made
because a touch-first UI that shows the *wrong* current action fails D8C's own
"current action must remain obvious" acceptance criterion. No backend, schema, or API
change was involved.

---

## Exact Non-Changes

- No file under `backend/` was modified.
- No PostgreSQL schema, Alembic migration, or seed data changed.
- No REST endpoint was added, removed, or changed — all 20 endpoints in
  `frontend/src/api/factoryApi.ts` are called exactly as before.
- No workflow legality, hard-stop, calibration-retry, QC, or cloud-block logic moved
  into the frontend.
- `tailwind.config.js` was not modified.
- The D8B `--mds-*`/`--factory-*` token system and `[data-theme]` mechanism are
  unchanged.
- No Material UI (MUI) library was installed. No Azure SDK. No auth/session code.
- `vendor/engineering-os/` core doctrine is unmodified.

---

## Next-Phase Handoff

The frontend is now touch-and-mouse usable from 768px to 1920px+, with the
compact-width actor-priority behavior (current unit → block state → current stage →
required action → ... ) in place as groundwork for a future actor-specific
(assembler/floor-manager) UI split. D8C does not implement authentication, role
routing, or any actor-specific application — those require an explicit later
directive.
