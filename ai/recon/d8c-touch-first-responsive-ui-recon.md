# D8C — Touch-First Responsive Factory UI — Recon

**Date:** 2026-07-02
**Capability:** touch-first-responsive-factory-ui-d8c
**Phase:** phase-ui
**Status:** COMPLETE

---

## Repository Mode

**OS-ENABLED**, confirmed by evidence, not assumed:

- `vendor/engineering-os/` exists with full canonical doctrine (`core-docs/`, `scripts/`, `ai/`, `claude/`, `templates/`, `tests/`).
- `.engineering-os/adapter.config.sh` + `.engineering-os/invariants/` (6 rule files) exist as the local adapter overlay.
- `bash vendor/engineering-os/scripts/os-adapter-check.sh` → **12 PASS / 0 FAIL, Status: adapter valid**.
- `bash scripts/invariant-check.sh` (proxy to `vendor/engineering-os/scripts/invariant-engine.sh`) → **6/6 PASS**.
- Root `scripts/compile-spec.sh`, `scripts/generate-tasks.sh`, `scripts/execution-supervisor.sh` are thin proxies to the vendored canonical scripts (per `docs/os-vendor-integration.md`), not invented stand-ins. The prior D1C/D1D history (`docs/d1c-invented-os-cleanup.md`, `docs/os-vendor-integration.md`) documents that a first attempt at this OS was locally invented, was quarantined to `_archive/invented-os-bootstrap-d1c/`, and was then correctly re-vendored from the canonical source at commit `e718eac925c3a642ef520d3e582bc42fbe5eadbf`. Current root `ENGINEERING_OS.md`/`PROJECT_BOOTSTRAP.md`/`CLAUDE.md` are the D1D real wrappers, not the invented ones.

Conclusion: the control layer is real and operational. Proceeding through it is correct, not ceremony.

**Documentation staleness note (non-blocking):** `PROJECT_BOOTSTRAP.md` still says "Active phase: D1D ... D3 Stack Scaffold not yet started," and `ai/runtime-contracts.md` Contract 4 still says "Mock State in v0; Postgres Deferred." Both are stale — `frontend/`, `backend/`, `docker-compose.yml`, and `docs/persistence-postgres-d7.md` show D3–D7 are long complete and Postgres is live. This is a pre-existing documentation-drift issue, not something D8C is scoped to fix. Flagging per STRICT MODE; not fixing outside declared scope.

---

## Branch and Git Status

- Branch: `main`.
- `git log` → **`fatal: your current branch 'main' does not have any commits yet`** — this repository has never been committed. All work (D1–D8B) exists only in the working tree / index.
- `git status --short` shows a mix of `A`/`AM`/`AD` (staged-then-modified / staged-then-deleted, from the D1C quarantine → D1D re-vendor sequence) plus a large set of `??` untracked directories: `.engineering-os/`, `backend/`, `frontend/`, `data/`, `docker-compose.yml`, `specs/`, `tasks/`, `docs/*-d4..d8b*.md`, `vendor/`, `scripts/verification/`, etc.
- No destructive git action is required or proposed by D8C. No commit is created by this recon.

---

## Files Read (exact list)

- `frontend/src/components/FactoryFlowBoard.tsx` (full, 260 lines)
- `frontend/src/components/UnitList.tsx` (full, 81 lines)
- `frontend/src/components/StageSpine.tsx` (full, 147 lines)
- `frontend/src/components/UnitDetailPanel.tsx` (full)
- `frontend/src/components/ActionPanel.tsx` (full)
- `frontend/src/components/EventTrace.tsx` (full, 108 lines)
- `frontend/src/api/factoryApi.ts` (full, 145 lines)
- `frontend/src/types/factory.ts` (full, 235 lines)
- `frontend/src/App.tsx` (full, 8 lines)
- `frontend/index.html` (full, 27 lines)
- `frontend/src/styles.css` (full, 320 lines) — **this is the real stylesheet; `frontend/src/index.css` named in the directive does not exist**
- `frontend/tailwind.config.js` (full, 12 lines)
- `frontend/vite.config.ts` (full, 11 lines)
- `frontend/package.json` (full, 26 lines)
- `scripts/verification/006-factory-flow-board-ui.sh`, `008-demo-readiness.sh`, `009-light-mode-readability.sh`, `010-material-theme-readability.sh`, `scripts/smoke.sh` (full)
- `docker-compose.yml` (full)
- `docs/factory-review-hardening-d8.md`, `docs/light-mode-readability-d8a.md`, `docs/material-theme-readability-d8b.md`, `docs/d1c-invented-os-cleanup.md`, `docs/d2a-model-drift-correction.md`, `docs/os-vendor-integration.md` (summarized/full as needed)
- `ai/product-invariants.md`, `ai/runtime-contracts.md`, `ai/service-boundaries.md`, `ai/state_registry.json`, `PROJECT_BOOTSTRAP.md`, `.engineering-os/adapter.config.sh`

## Commands / Queries Executed

- `git branch --show-current`, `git status --short`, `git log --oneline -5`
- `bash vendor/engineering-os/scripts/os-adapter-check.sh`
- `bash scripts/invariant-check.sh`
- `find frontend/src -type f | sort`
- `find . -iname "*playwright*" -not -path "*/node_modules/*"`, `ls frontend/node_modules/.bin | grep -i play`, `which npx`
- `find . -iname "*screenshot*" -o -iname "*artifacts*"` (excluding node_modules)
- `grep -rn "AppShell\|D5BackendStatus\|DataContractStatus\|HealthStatus" frontend/src` — to check for dead/unwired component files

---

## Current Layout Map

`FactoryFlowBoard.tsx` renders one fixed structure, no responsive variance:

```
<div class="app-bg min-h-screen flex flex-col" data-d8-demo-readiness data-d8a-readability data-d8b-material-theme>
  <header class="flex items-center justify-between gap-4 flex-wrap">   ← title, health dot, contract dot, reset btn, theme toggle
  <div class="flex flex-1 overflow-hidden">                            ← main row, no wrap, no breakpoints
    <div class="w-64 flex-shrink-0 overflow-y-auto">  UnitList          ← fixed 256px
    <div class="w-80 flex-shrink-0 overflow-y-auto">  StageSpine        ← fixed 320px
    <div class="flex-1 overflow-y-auto flex flex-col gap-5">           ← only flexible region
      UnitDetailPanel
      ActionPanel
    </div>
  </div>
  <div class="border-t max-h-64 overflow-y-auto">  EventTrace           ← fixed 256px max-height, contains <table> in its own overflow-x-auto
</div>
```

This is a fixed three-column-plus-footer desktop layout with **zero responsive adaptation** at any width — confirmed by full-file reads of `FactoryFlowBoard.tsx` and `styles.css`: no `@media` query exists anywhere in the app, and no Tailwind responsive prefix (`sm:`/`md:`/`lg:`/`xl:`/`2xl:`) appears anywhere in `FactoryFlowBoard.tsx`, `App.tsx`, `UnitList.tsx`, `StageSpine.tsx`, `UnitDetailPanel.tsx`, `ActionPanel.tsx`, or `EventTrace.tsx`.

`frontend/index.html` viewport meta is standard (`width=device-width, initial-scale=1.0`, no zoom lock) — safe to keep as-is.

### Dead / unwired files (not part of the live tree)

`frontend/src/components/AppShell.tsx`, `D5BackendStatus.tsx`, `HealthStatus.tsx` exist on disk but are **not imported anywhere** (confirmed by grep across `frontend/src`). `DataContractStatus` is used only as a *type* from `types/factory.ts`, not the component file. These four leftover files are out of scope for D8C — they render nothing today, are not in the directive's mutation allow-list, and will not be touched.

---

## Viewport Assumptions (current, implicit)

The app currently assumes an unconstrained desktop viewport ≥ ~900px purely by accident of fixed-width columns (256px + 320px + whatever remains for detail/action). There is no explicit minimum-width guard and no narrow-viewport behavior — below roughly 750–800px total width the three columns plus their internal padding will not fit and the browser will either shrink `flex-1` toward zero or, more likely, page-level horizontal overflow will appear because `w-64`/`w-80` are `flex-shrink-0` (non-negotiable minimums).

---

## Fixed-Width Inventory

| Location | Value | Shrinkable? |
|---|---|---|
| `FactoryFlowBoard.tsx:202` unit queue column | `w-64` = 256px | No — `flex-shrink-0` |
| `FactoryFlowBoard.tsx:214` stage spine column | `w-80` = 320px | No — `flex-shrink-0` |
| `StageSpine.tsx:56` stage-number gutter | `w-6` = 24px | n/a (small, fine) |
| `StageSpine.tsx` status dots | `w-2 h-2` = 8px | n/a |
| `FactoryFlowBoard.tsx` health/contract dots | `w-2 h-2` = 8px | n/a |

No fixed pixel widths exist in `UnitDetailPanel.tsx`, `ActionPanel.tsx`, or `EventTrace.tsx` (both are content-width, single-column stacks) — the fixed-width risk is concentrated entirely in `FactoryFlowBoard.tsx`'s two side columns.

## Fixed-Height Inventory

| Location | Value |
|---|---|
| `FactoryFlowBoard.tsx:252` Event Trace panel | `max-h-64` = 256px, internally scrollable |

No other fixed heights found. Row/card heights throughout `UnitList`, `StageSpine`, `UnitDetailPanel`, `ActionPanel` are content-driven (padding + text), which is favorable for a touch pass (no need to fight a hard-coded height when enlarging touch targets).

---

## Touch-Target Inventory (current, all below or borderline vs. contract)

| Control | Current sizing | Meets 48px primary / 44px secondary? |
|---|---|---|
| `UnitList` row (`FactoryFlowBoard→UnitList.tsx:35`) | full-row `<button>`, `px-3 py-4`, content-height ≈ 50–60px total (multi-line) | Height OK in practice due to 3 lines of content + py-4, but not guaranteed at min-content (single short label) — needs explicit `min-h` |
| Header Reset / Theme buttons (`FactoryFlowBoard.tsx:184`, `:195`) | `px-4 py-1.5`, `text-sm` → **~30–32px tall** | **No** — below 44px secondary minimum |
| ActionPanel `SubmitBtn` (`ActionPanel.tsx:101`) | `px-3 py-2`, `text-sm` → **~36px tall** | **No** — below 48px primary minimum |
| ActionPanel checkbox (`ActionPanel.tsx:542-548`) | native checkbox, no explicit size (~13–16px) | **No** — far below 44px; label click helps but hit-area of the box itself is tiny |
| EventTrace "Show all/fewer" toggle (`EventTrace.tsx:53-58`) | plain text button, `text-xs`, no padding classes at all | **No** — effectively a text hit-target only |
| `mdc-input`/`mdc-select` (`styles.css:289,307`) | `padding: 8px 12px` | Borderline — likely ~34–38px with `text-sm`/16px font; needs verification and probable bump |
| `StageSpine` rows | non-interactive `<div>`, no click handler at all | N/A — informational only, contract doesn't require a touch target here |

**Net finding:** every existing interactive control in the app is undersized relative to the D8C 44/48px contract. This is a real, pervasive gap — not a hypothetical one.

---

## Hover-Only Interaction Inventory

Grep-verified across all six in-scope component files and `styles.css`: **zero** `hover:`-gated *content visibility* exists anywhere. The only `hover:`/`:hover` usages found are pure color transitions on already-visible elements:
- `styles.css:205-211` — `.hover-surf-low:hover`, `.hover-surf-container:hover` (background tint change only)
- `ActionPanel.tsx:101` — `hover:bg-blue-700` on the submit button
- `EventTrace.tsx:55` — `hover:underline` on the show-all toggle

No tooltip library, no `title=`-only critical info, no CSS `:hover { display: block }` pattern. **This means Invariant 3 ("no critical information may depend on hover") is already satisfied today** — D8C does not need to *fix* a hover-dependency defect, only ensure the touch/responsive pass doesn't introduce one (e.g., don't hide the blocked-reason behind a hover-revealed tooltip when compacting).

---

## Nested-Scroll Inventory

- `FactoryFlowBoard.tsx:202` UnitList column: `overflow-y-auto`
- `FactoryFlowBoard.tsx:214` StageSpine column: `overflow-y-auto`
- `FactoryFlowBoard.tsx:227` Detail+Action column: `overflow-y-auto`
- `FactoryFlowBoard.tsx:252` EventTrace panel: `overflow-y-auto` (outer) wrapping `EventTrace.tsx:60` `overflow-x-auto` (inner, around the `<table>`)

Four independent vertical scroll regions plus one horizontal scroll region today. This is a real "nested scroll" pattern already in production — on a touchscreen, four adjacent independently-scrollable panes plus a horizontally-scrollable table is a known source of accidental-scroll and scroll-capture bugs, and is one reason the compact layout must reduce simultaneous visible regions rather than just shrinking them.

## Overflow Risks

- The two `flex-shrink-0` fixed columns (`w-64` + `w-80` = 576px combined) plus mandatory padding mean **any viewport under roughly 750–800px will overflow horizontally today** — confirmed structurally (not yet confirmed in-browser; will be confirmed in Step 6 browser verification).
- `EventTrace.tsx`'s `<table>` inside `overflow-x-auto` will horizontally scroll at any width where 6 columns (Event ID, Unit, Stage, Sev, Message, Timestamp) don't fit — likely true well above 768px given `font-mono` IDs and full ISO timestamps. This is an existing, currently-invisible-because-desktop-is-wide overflow risk that becomes a real compact-width problem.

---

## Component-by-Component Findings

### FactoryFlowBoard.tsx
Single fixed flex layout, no breakpoints, no grid. Owns theme state (`useState` + `useEffect` + `localStorage['factory-theme']` + `data-theme` attribute on `documentElement`), health/contract polling and header display, reset button. Three markers already present: `data-d8-demo-readiness`, `data-d8a-readability`, `data-d8b-material-theme` — D8C must add a fourth, `data-d8c-touch-responsive="true"`, following the exact same pattern.

### UnitList.tsx
Already the best-positioned component for touch: full-row `<button>`, no hover-only info, no fixed height. Needs: explicit `min-h-[48px]` (can't rely on 3-line content height alone for short labels), font-size floor check (`text-[15px]`/`text-[13px]`/`text-xs` are all below the 16px body-text guidance in places), and a compact-width presentation mode (drawer/top-selector/overlay per directive) since it currently lives in a fixed 256px column that cannot survive compact width as-is.

### StageSpine.tsx
Vertical list of 14 rows (not horizontal — directive's "horizontally scrollable stage strip" option is a *choice*, not a fait accompli; current code is a vertical stack). Non-interactive by design (informational), which matches "not make informational stages accidentally actionable." Needs: compact-width presentation (collapsible/tab/pane per directive), badge legibility check (`GATE`/`CLOUD BLOCK`/`TERMINAL`/`NO OVERRIDE` badges are all `text-xs`, 12px — at the documented floor, acceptable per typography contract's "badge text: 12-13px minimum" but not below it).

### UnitDetailPanel.tsx
Dense but already single-column (no table, no horizontal scanning) — good starting position. Block/Hard-Stop section already gets a distinct red `surf-error` box, but blocked_reason and "NO OVERRIDE — No bypass possible" are both plain `text-sm` (14px), same size as every other row — directive requires block reason/no-override to be "prominent"; today they're color-distinguished only, not size-distinguished. Needs: increase emphasis (size/icon/weight) without breaking the flat key/value row pattern, optional disclosure for secondary sections (Part Allocations, Calibration, QC, Cloud/Ship) at compact widths.

### ActionPanel.tsx
Highest-priority surface per directive, and currently the *worst* offender on touch-target size: submit buttons ≈36px (need 48px), checkbox is browser-default size, no color differentiation between routine actions (Ship) and destructive/high-authority ones (Scrap disposition) — both use the identical blue button. The `NO OVERRIDE` badge in the post-submit response grid is a dense 12px inline badge, smaller/less prominent than the equivalent text in `UnitDetailPanel`. Needs: button height bump to ≥48px, checkbox/input touch sizing, full-width controls preserved (already `w-full`), spacing audit (`space-y-2.5` = 10px, contract wants 8px min/12px preferred — currently compliant but tight for adjacent buttons if more are ever added), no new legality logic (backend already fully owns this — confirmed via `factoryApi.ts` endpoint enumeration, 20 endpoints, all POST/GET round-trips, no client-side stage-advance logic found).

### EventTrace.tsx
The one component using an actual `<table>` — 6 columns, `overflow-x-auto`, all `text-xs` (12px, at floor for "event message text: 14px minimum where practical" — currently below that). "Show all" toggle has no enforced tap target at all (plain text button). This is the component most in need of structural change (table → responsive list/card at compact widths), consistent with the directive's explicit instruction.

---

## Theme Compatibility Findings

D8B's Material-inspired token system in `styles.css` is a real, complete `[data-theme="light"|"dark"]` CSS-custom-property system (`--mds-*` core tokens + `--factory-gate/cloud/success/supervisor*` domain tokens), toggled via `FactoryFlowBoard.tsx`'s `theme` state and persisted to `localStorage['factory-theme']`, with an inline pre-paint script in `index.html` to avoid flash-of-wrong-theme. This system is theme-token-driven, not Tailwind `dark:`-driven (`darkMode: false` in `tailwind.config.js` — confirmed, no override). **This means responsive/touch changes are additive to layout/sizing classes and do not need to touch the theming mechanism at all** — new breakpoint/touch CSS can be written entirely in terms of layout (flex/grid/width/min-height) without any new theme-conditional branches, as long as new visual states (e.g. a new compact-mode drawer) reuse the existing `surf-*`/`t-on-*`/`b-*` semantic classes rather than introducing hardcoded colors. One existing inconsistency worth preserving-as-is (not fixing, out of scope): `StageSpine.tsx`'s `NO OVERRIDE` badge uses hardcoded `bg-red-600 text-white` instead of the `surf-error`/`t-on-error` tokens used everywhere else — this predates D8C and isn't a regression D8C introduces, but the new touch-target treatment of that badge should not compound the inconsistency by hardcoding further colors.

---

## Browser-Tooling Availability

- **No repo-level Playwright.** `frontend/package.json` has zero test/browser-automation dependencies (react/react-dom only, plus vite/tailwind/typescript build tooling). No root `package.json`. No `frontend/node_modules/.bin/playwright`.
- **No prior screenshot or visual-regression artifacts anywhere in the repo** — D6/D8/D8A/D8B all verified UI changes exclusively via `curl` (HTTP status + body-string grep) and static source-file grep for expected class names/attributes/tokens (confirmed by full reads of scripts 006/008/009/010). There is no precedent for real rendered-pixel verification in this repository.
- **This session has MCP Playwright browser tools available** (`mcp__playwright__browser_*`), backed by a machine-global browser cache (`~/Library/Caches/ms-playwright`), not a repo dependency. These are usable *interactively in this session* for the directive's required live-viewport/screenshot verification, but are not something a committed `011-touch-first-responsive-ui.sh` script can invoke on another machine or in CI without the repo itself gaining a Playwright devDependency.
- `docker-compose.yml` defines a real runnable stack (`postgres` + `backend:8000` + `frontend:5173`), exactly matching what all prior verification scripts assume — sufficient as a live target for both the MCP-tool-driven interactive browser pass and a future repo-committed Playwright suite.

**Decision for the verification-design section below:** follow the directive's explicit permission — add `@playwright/test` as a minimal `frontend`-local devDependency (the smallest tooling addition that makes browser verification repeatable outside this interactive session), write one Playwright spec covering the required viewport matrix, and have `011-touch-first-responsive-ui.sh` invoke it via `npx playwright test`, falling back to the existing curl/grep pattern for the static/marker-based checks (consistent with 006/008/009/010's proven convention). This session's MCP Playwright tools will additionally be used directly for the interactive demonstration/screenshot pass required by the directive's Browser Verification section.

---

## Proposed Breakpoint Model

Tailwind's **default** scale is already active (`tailwind.config.js` extends nothing) and lines up well with the directive's viewport matrix without needing custom values:

| Directive band | Tailwind breakpoint | Width |
|---|---|---|
| Minimum supported width | (base, no prefix) | 768px landspace floor |
| Compact Workstation / Tablet Landscape | `lg:` boundary used as the "compact → standard" switch | 900–1279px → treat `< lg` (1024px) as compact-ish, but directive's own boundary is 1280px, so the compact tier is better modeled as base-up-to-`xl` |
| Standard Workstation | `xl:` (1280px) | 1280–1599px |
| Large Workstation | custom threshold at 1600px (Tailwind default has no 1600 stop; nearest is `2xl` at 1536px) | ≥1600px |

Concrete decision: use Tailwind's existing `lg` (1024px) and `xl` (1280px) stops for the compact/standard boundary (close enough to the directive's 900/1280 bands that no config edit is needed for those two), and add **one** custom breakpoint `2xl` override or an arbitrary-value `min-[1600px]:` variant for the Large Workstation 1600px threshold (no `tailwind.config.js` edit strictly required — Tailwind v3 arbitrary variants support `min-[1600px]:` inline). This avoids modifying `tailwind.config.js` at all, keeping the change surface smaller. Base (no prefix, <1024px down to 768px) = compact/tablet-landscape. `lg:`/`xl:` (≥1024px) = standard workstation transitional zone. `min-[1600px]:` = large workstation.

## Proposed Touch-Target Contract (implementation-ready)

- Introduce two utility classes in `styles.css` (theme-token-driven, no hardcoded colors): `.touch-target-primary { min-height: 48px; min-width: 48px; }` and `.touch-target-secondary { min-height: 44px; min-width: 44px; }`, applied alongside existing Tailwind classes rather than replacing the `surf-*`/`t-on-*` system.
- Apply to: header Reset/Theme buttons, ActionPanel submit buttons, ActionPanel checkbox (via padded label wrapper), EventTrace show-all toggle, UnitList row (`min-h`), form `mdc-input`/`mdc-select` (bump `styles.css` `.mdc-input`/`.mdc-select` padding).
- Spacing: audit all adjacent-control gaps against 8px min/12px preferred (`ActionPanel.tsx` panels are currently `space-y-2.5` = 10px — compliant, keep).

## Proposed Compact-Layout Strategy (768–1279px)

Given the current structure is `UnitList | StageSpine | Detail+Action` + `EventTrace` footer with 4 independent scroll regions, and the directive's priority order (current unit → block/attention → current stage → required action → progress → supporting details → event history → full engineering context):

- **Base/compact (<1024px):** Detail+Action column becomes the primary, full-width view. UnitList becomes a collapsible top drawer/selector (collapsed by default, current unit always shown as a persistent compact header strip). StageSpine becomes a secondary tab/pane reachable via a control near the top of the detail view, not simultaneously visible. EventTrace remains reachable via a tab/disclosure, not permanently docked.
- **Standard (`lg`/`xl`, 1024–1599px):** Restore the multi-column layout but with adjusted ratios (UnitList and StageSpine columns can shrink from 256px/320px toward ~200px/260px) so Detail+Action never gets truncated.
- **Large (`min-[1600px]:`):** Current desktop 3-column-plus-footer layout, effectively unchanged, ratios can even widen.

This is additive (new compact-mode markup/branches) rather than a full rewrite — the existing component boundaries (UnitList, StageSpine, UnitDetailPanel, ActionPanel, EventTrace) are preserved; only `FactoryFlowBoard.tsx`'s composition of them becomes width-aware.

## Actor-Priority Implications

No role/auth logic exists or is introduced (confirmed: no `jwt`/`session`/`OAuth2` patterns in backend, matching the D8/demo-readiness verification's own check). The compact-mode priority order above is purely a layout/visibility decision inside `FactoryFlowBoard.tsx` — it does not require new state beyond a `viewMode`/`activePane` UI toggle, and does not touch `factoryApi.ts` or any backend route.

## Accessibility Considerations

- Existing `.mdc-input`/`.mdc-select` `:focus` rules already set a visible `outline: 2px solid var(--mds-primary)` — must be preserved, not overridden, when touch-target padding is increased.
- New compact-mode disclosure controls (drawer toggles, tab switches) must be real `<button>` elements with visible focus states, keyboard-activatable (native buttons get this for free) — no `<div onClick>` patterns.
- `StageSpine` rows must remain non-`<button>` (they're informational, not actionable) even inside a new tab/pane presentation — do not accidentally make them focusable/interactive when moving them into a collapsible container.

## Files Proposed for Mutation

Matches the directive's allowed list exactly, corrected for the one factual discrepancy found:

- `frontend/src/components/FactoryFlowBoard.tsx`
- `frontend/src/components/UnitList.tsx`
- `frontend/src/components/StageSpine.tsx`
- `frontend/src/components/UnitDetailPanel.tsx`
- `frontend/src/components/ActionPanel.tsx`
- `frontend/src/components/EventTrace.tsx`
- `frontend/src/App.tsx` (likely no change needed — currently 8 lines, pure passthrough — will only touch if a wrapper becomes necessary)
- **`frontend/src/styles.css`** (not `frontend/src/index.css` — that file does not exist; this is the documented deviation, made explicit before mutation per directive's conflict-handling rule)
- `frontend/index.html` (only if a meta tag needs updating; viewport meta is already correct)
- `frontend/package.json` (adding `@playwright/test` as a devDependency only — minimum tooling addition, per directive's explicit allowance)
- New: `frontend/playwright.config.ts`, `frontend/tests/d8c-touch-responsive.spec.ts` (frontend-local browser tests, allowed surface)
- `scripts/verification/011-touch-first-responsive-ui.sh` (new)
- `ai/recon/d8c-touch-first-responsive-ui-recon.md` (this file)
- `specs/touch-first-responsive-factory-ui-d8c.md` (new)
- generated `tasks/touch-first-responsive-factory-ui-d8c-*.md` (new)
- `docs/touch-first-responsive-ui-d8c.md` (new)
- `README.md`, `ai/repo-index.md`, `ai/architecture-index.md`, `ai/engineering-journal.md`, `ai/state_registry.json`

## Files Forbidden From Mutation (confirmed untouched by this plan)

- Everything under `backend/` (routers, models, domain/stage-machine logic, Alembic migrations if any, seed data under `data/`)
- PostgreSQL schema / `DATABASE_URL` config in `docker-compose.yml`
- `docs/factory-flow-model.md`, `docs/domain-glossary.md`, `docs/decision-lock.md` (canonical stage/domain authority — read-only)
- `vendor/engineering-os/` core doctrine (read-only)
- Dead/unwired files `AppShell.tsx`, `D5BackendStatus.tsx`, `HealthStatus.tsx`, `DataContractStatus.tsx` (component) — out of scope, not part of the live render tree, not named in the directive's allow-list

## Invariant Interactions

- **Invariant 1 (Backend Workflow Authority):** No interaction — `factoryApi.ts`'s 20 endpoints are the only state-mutation path today and D8C introduces zero new ones; all changes are presentational/layout.
- **Invariant 2 (Product/Data Contract Stability):** No interaction — no type in `types/factory.ts`, no endpoint in `factoryApi.ts`, no stage name in `StageSpine.tsx`'s rendering of the 14-stage data changes.
- **Invariant 3 (Touch/Responsive Integrity):** This is the invariant D8C exists to satisfy — see touch-target and hover findings above; the plan directly targets every gap found.

## Implementation Risks

1. **Regression risk in `EventTrace.tsx`:** converting `<table>` to a list/card view at compact widths is the largest structural change in the plan; must preserve severity/stage/actor/timestamp/message semantics exactly, just re-flowed.
2. **Column-ratio risk in `FactoryFlowBoard.tsx`:** shrinking `w-64`/`w-80` at `lg`/`xl` risks truncating StageSpine badge text (`CLOUD BLOCK`, `TERMINAL`) — needs `flex-wrap` on the badge row (already present, `StageSpine.tsx:73`) to absorb narrower widths gracefully.
3. **New Playwright devDependency:** first browser-automation tooling ever added to this repo — must be scoped tightly (frontend-local only, one config, one spec file) to avoid violating "no heavy test framework unrelated to this capability."
4. **Verification-script precedent:** 006/008/009/010 are pure curl/grep; 011 introducing `npx playwright test` is a new pattern — must still expose a clean PASS/FAIL exit code compatible with the existing chain-calling convention (008/009/010 each `bash` the previous script and check its exit code).

## Verification Design

`scripts/verification/011-touch-first-responsive-ui.sh` will, following the 006–010 convention:
1. Run static/source checks via grep (marker `data-d8c-touch-responsive`, presence of `.touch-target-primary`/`.touch-target-secondary` classes in `styles.css`, absence of new hardcoded stage/legality logic in the touched `.tsx` files).
2. Chain-run 004/005/006/007/008/009/010 (existing regression) and fail if any fail.
3. Invoke `npx playwright test` (new `frontend/tests/d8c-touch-responsive.spec.ts`) against the running `docker compose` stack for the required viewport matrix (768×1024, 1024×768, 1180×820, 1280×800, 1440×900, 1920×1080) checking: no horizontal scroll (`document.documentElement.scrollWidth <= clientWidth`), unit selection works, blocked reason + no-override visible, action controls meet computed bounding-box ≥48/44px, theme toggle + reload persistence, reset-demo works.
4. Chain `scripts/smoke.sh`.
This session will additionally use the MCP Playwright tools directly for the interactive demonstration pass and screenshot capture the directive requires under `artifacts/d8c-touch-verification/`.

## Implementation DAG

```
1. Recon (this artifact) — DONE
2. Spec (specs/touch-first-responsive-factory-ui-d8c.md) → compile-spec.sh → SPEC_LOCKED
3. Task graph (generate-tasks.sh) → TASK_GRAPH_LOCKED
4. Responsive shell + breakpoint foundation (FactoryFlowBoard.tsx, styles.css, marker)
5. Header + UnitList + StageSpine touch pass          ─┐ (can proceed in parallel once 4 lands)
6. UnitDetailPanel + ActionPanel touch pass            ─┤
7. EventTrace responsive adaptation                    ─┘
8. Playwright devDependency + spec + 011 script + browser verification (depends on 4-7)
9. Full regression chain (001-010, invariants, smoke)
10. Docs + indexes + journal + state registry + release gate
```

## Stop Conditions Checked

- No conflict found between existing code/specs/verification artifacts and this directive that would require stopping — the one factual discrepancy (`index.css` vs `styles.css`) is documented above and resolved by targeting the real file, not a blocker.
- No backend change is required or proposed.

## Explicit Confirmation: Backend Changes Required?

**No.** Confirmed by full enumeration of `frontend/src/api/factoryApi.ts` (20 endpoints, all pre-existing) and `ai/product-invariants.md`/`ai/runtime-contracts.md` — D8C is presentation/layout/CSS/component-composition only. No backend file will be touched.
