# Spec: Variant Review Shell (D9C-1)

## Status
approved

## Phase
phase-ui

## Feature
d9c-1-variant-review-shell

## Capability

Today Factory Cloud has exactly one presentation: the existing engineering-console
`FactoryFlowBoard` reachable at `/`. There is no way to show the client (Vijay) more
than one candidate presentation approach at a time.

After this capability, opening `/#/variants` reveals a new, additive review shell with
a primary tab bar of exactly four tabs — **Current**, **Variant A — Attention-First**,
**Variant B — Workflow-First**, **Variant C — Command-Center** — that switches instantly
(client state, no reload, no network call). Current renders the existing
`FactoryFlowBoard` completely unmodified. Each of Variant A/B/C contains a secondary,
nested switcher — **Assembler** / **Floor Manager** — matching the operator-settled
three-variant × two-actor-view design (see Structural Design below), rendering
placeholder panes only (no real variant content — that is a later, separate phase).
The existing entry point `/` (no hash) is completely unaffected: same DOM, same
components, same behavior, byte-for-byte, as before this capability.

## Source Authority

- `ai/recon/d9a-actor-first-factory-ui-current-flow-recon.md` — current-flow recon.
- `ai/recon/d9b-three-functional-actor-first-ui-variants.md` — three-variant design (this
  spec's Structural Design section implements it exactly).
- `ai/recon/d9c0-variant-review-shell-preflight-scope-lock.md` — scope lock, serialization
  rules (D9C-1 is shell/routing only; real variant content is later nodes D9C-5/6/7).
- `ai/recon/d9c1-variant-review-shell.md` — recon that found a structural conflict between
  a proposed 4-flat-tab directive and the settled D9B design, and stopped for an operator
  decision.
- **Operator decision (2026-07-12):** three variants with nested Assembler/Floor Manager
  views (matching D9B) — not four flat tabs. This spec implements that decision.
- `ai/product-invariants.md`, `ai/runtime-contracts.md`, `ai/service-boundaries.md` —
  governing invariants, all unaffected (see Dependencies).
- `specs/touch-first-responsive-factory-ui-d8c.md` — prior capability whose acceptance
  criteria this capability must not weaken or regress.

## Current Problem

1. Only one presentation of Factory Cloud exists; there is no side-by-side client review
   mechanism for candidate UI approaches.
2. No structure exists yet for organizing multiple presentation variants, each with
   multiple actor-specific sub-views, without disturbing the existing baseline.

## Non-Goals / Out of Scope

- No backend, API, database, schema, or seed-data change of any kind.
- No authentication, RBAC, or tenanting work.
- No real Assembler/Floor Manager content for any variant — Variant A/B/C render
  placeholder panes only in this capability. Real content is out of scope until later,
  separately directed nodes.
- No new npm dependency — `frontend/package.json`, `frontend/package-lock.json` unchanged.
  No routing library is added.
- No change to `frontend/index.html`, `frontend/vite.config.ts`, `frontend/tsconfig.json`.
- No change to the existing `/` entry point's behavior, DOM structure, or component tree.
- No change to `frontend/src/api/**` or `frontend/src/types/factory.ts`.

## Data Model Changes
none

## API Surface
none

## Frontend Surface

New directory `frontend/src/components/variant-review/`:

- `VariantReviewShell.tsx` — top-level component. Owns a single piece of React state
  (`activeTab`, one of `'current' | 'variantA' | 'variantB' | 'variantC'`, default
  `'current'`). Renders a primary tab bar with exactly four real `<button>` elements
  (Current / Variant A — Attention-First / Variant B — Workflow-First / Variant C —
  Command-Center) and, below it, the active pane:
  - `activeTab === 'current'` → renders `<FactoryFlowBoard />` (imported unmodified from
    `../FactoryFlowBoard`) with no additional wrapper markup around it beyond the pane
    container itself.
  - `activeTab === 'variantA' | 'variantB' | 'variantC'` → renders
    `<VariantPlaceholderPane variantId={...} variantLabel={...} />`.
  Switching `activeTab` must be a pure client-state update (`useState` setter in an
  `onClick` handler) — no route change, no reload, no network request.
- `VariantPlaceholderPane.tsx` — reusable placeholder pane, props: `variantId: 'variantA' |
  'variantB' | 'variantC'`, `variantLabel: string`. Owns its own local state
  (`activeActor`, one of `'assembler' | 'floorManager'`, default `'assembler'`). Renders a
  secondary tab bar with exactly two real `<button>` elements — **Assembler** / **Floor
  Manager** — and, below it, a placeholder body showing the variant label, the selected
  actor label, and a short message that presentation content for this combination ships in
  a later phase. No factory data is fetched or displayed; no import from
  `frontend/src/api/**`.
- `variant-review.css` is NOT a new file — instead add the new, additive-only CSS rules
  directly to the existing `frontend/src/styles.css` (see below). Do not create a second
  stylesheet.

Modified (additive only, no existing rule/line removed or changed):

- `frontend/src/main.tsx` — add a minimal, additive routing shim, evaluated once at
  module load: if `window.location.hash` starts with `#/variants`, render
  `<VariantReviewShell />` in place of `<App />`; otherwise render `<App />` exactly as
  it does today (unchanged import, unchanged `<StrictMode>` wrapper, unchanged
  `createRoot(...).render(...)` call shape). Implement via a tiny local component (e.g.
  `Root()`) that decides which element to render — do not add a routing library.
- `frontend/src/styles.css` — append new rules only, for the shell's primary/secondary
  tab bar and placeholder pane chrome. Reuse existing semantic classes/tokens
  (`surf-*`, `t-on-*`, `b-*`, `.touch-target-primary`, `.touch-target-secondary`) —
  introduce zero new hardcoded color values and zero new CSS custom properties. Do not
  modify any existing rule already in the file.

Unmodified (must remain byte-for-byte identical):

- `frontend/src/App.tsx`
- `frontend/src/components/FactoryFlowBoard.tsx` and every one of its existing child
  components (`UnitList.tsx`, `StageSpine.tsx`, `UnitDetailPanel.tsx`, `ActionPanel.tsx`,
  `EventTrace.tsx`, etc.)
- `frontend/src/api/factoryApi.ts`, `frontend/src/types/factory.ts`
- `frontend/index.html`, `frontend/vite.config.ts`, `frontend/tsconfig.json`,
  `frontend/package.json`, `frontend/package-lock.json`

## Structural Design (operator-locked, 2026-07-12)

Three variants, each with two nested actor sub-views — **not** four flat, equal tabs:

```
Current (baseline, unchanged FactoryFlowBoard)
Variant A — Attention-First      → [ Assembler | Floor Manager ]  (placeholder)
Variant B — Workflow-First       → [ Assembler | Floor Manager ]  (placeholder)
Variant C — Command-Center       → [ Assembler | Floor Manager ]  (placeholder)
```

This matches `ai/recon/d9b-three-functional-actor-first-ui-variants.md` exactly and
resolves the structural conflict identified in `ai/recon/d9c1-variant-review-shell.md`
§2 (a competing four-flat-tab reading would have conflated variant-level and actor-level
concepts and dropped Variant A/B's identity). The operator explicitly selected this
nested structure.

## Entry Point Contract

- `/` (no hash): renders `<App />` exactly as before this capability — identical DOM,
  identical behavior, identical components. This is the existing, unchanged baseline
  used by all current verification scripts (001–011).
- `/#/variants`: renders `<VariantReviewShell />` — new, additive, does not alter `/` in
  any way.
- No routing library added. The hash is read once at module load in `main.tsx`.

## Placeholder Content Contract (D9C-1 scope boundary)

Each of Variant A/B/C's Assembler/Floor Manager panes shows only: the variant's label,
the selected actor's label, and a short "presentation content for this view ships in a
later phase" message. No factory/unit/order data, no API calls, no charts, no real
assembler/floor-manager UI — that is out of scope for this capability (reserved for
later, separately directed nodes per `ai/recon/d9c0-variant-review-shell-preflight-scope-lock.md`
§7).

## Operational Workflow

1. Operator or client opens `/` → sees today's Factory Cloud engineering console exactly
   as before, unaffected by this capability.
2. Operator or client opens `/#/variants` → sees a primary tab bar: Current | Variant A —
   Attention-First | Variant B — Workflow-First | Variant C — Command-Center, with
   Current selected by default.
3. Current tab renders the exact same `FactoryFlowBoard`, fully functional (unit
   selection, actions, theme toggle, reset demo all work identically to `/`).
4. Selecting Variant A, B, or C instantly swaps the pane (no reload, no network request)
   to that variant's placeholder, defaulting to its Assembler sub-view.
5. Within a variant, switching Assembler ↔ Floor Manager is instant, client-state only.
6. No backend call is made by the shell or any placeholder pane.

## Accessibility / Touch Rules

- All tab controls (both the primary 4-tab bar and each variant's secondary 2-tab bar)
  are real `<button>` elements — keyboard-operable (native Enter/Space activation),
  with visible focus state (reuse existing `:focus` outline conventions already used by
  `.mdc-input`/`.mdc-select` — do not suppress focus outlines).
- Primary tab buttons (Current / Variant A / Variant B / Variant C): apply
  `.touch-target-primary` (≥48×48 CSS px), consistent with the D8C touch contract.
- Secondary tab buttons (Assembler / Floor Manager): apply `.touch-target-secondary`
  (≥44×44 CSS px).
- No information is hover-only; no focus traps.

## Theme-Preservation Rules

No change to the `--mds-*`/`--factory-*` CSS custom-property token system, the
`[data-theme]` attribute mechanism, or `localStorage['factory-theme']` persistence. All
new shell/placeholder chrome uses only existing semantic classes (`surf-*`, `t-on-*`,
`b-*`) for any visual state — no new hardcoded color values.

## Backend Non-Change Contract

No file under `backend/` is modified. No PostgreSQL schema, Alembic migration, or seed
data change. No new or modified REST endpoint. `frontend/src/api/factoryApi.ts` is
unchanged (byte-for-byte).

## Dependencies

- `ai/product-invariants.md` Invariant 2 (Backend Owns State Transitions) — unaffected;
  this capability adds no state-transition logic, client-side or otherwise.
- `ai/runtime-contracts.md` Contract 2 (Frontend Communicates via REST API Only) and
  Contract 3 (Backend Owns All Factory State Transitions) — unaffected; the shell and
  placeholder panes make zero API calls.
- `ai/service-boundaries.md` — frontend/backend boundary unaffected.
- `specs/touch-first-responsive-factory-ui-d8c.md` — this capability does not modify or
  weaken any of its acceptance criteria; `FactoryFlowBoard` remains reachable at `/`,
  functionally and visually identical.
- `ai/recon/d9a-...`, `d9b-...`, `d9c0-...`, `d9c1-variant-review-shell.md` — full
  grounding for every claim in this spec.

## Acceptance Criteria

- [ ] `/` (no hash) renders exactly the pre-existing `FactoryFlowBoard` — no new DOM
      wrapper, no behavior change, verified by full existing verification corpus passing
      unweakened.
- [ ] `/#/variants` renders a new primary tab bar with exactly 4 tabs: Current, Variant A
      — Attention-First, Variant B — Workflow-First, Variant C — Command-Center.
- [ ] Current tab (default selected) renders `<FactoryFlowBoard />` unmodified, fully
      functional (unit selection, actions, theme toggle, reset demo all work identically
      to `/`).
- [ ] Each of Variant A/B/C renders a secondary Assembler/Floor Manager switcher with
      placeholder content only (no factory data, no API calls).
- [ ] Switching between any of the 4 primary tabs, or between Assembler/Floor Manager
      within a variant, is instant (client-state only) — no full page reload, no network
      request.
- [ ] All primary tab controls measure ≥48×48 CSS px; secondary actor-view controls
      measure ≥44×44 CSS px.
- [ ] `frontend/package.json`, `frontend/package-lock.json`, `frontend/vite.config.ts`,
      `frontend/index.html`, `frontend/tsconfig.json` unchanged.
- [ ] Zero files under `backend/`, `data/`, `vendor/`, `.engineering-os/` modified.
- [ ] `frontend/src/api/factoryApi.ts` unchanged (byte-for-byte).
- [ ] Verification scripts 001–011 (full existing corpus) all still pass.
- [ ] `bash scripts/invariant-check.sh` — 6/6 PASS.
- [ ] Capability reaches `RELEASE_APPROVED` in `ai/state_registry.json`.

## Verification Scripts

(none)

## Regression Plan

The full existing chain (001–011) plus `scripts/smoke.sh` plus
`scripts/invariant-check.sh` (6/6) must still pass unweakened. No prior verification
script is modified.

## Capability Phase Boundary

D9C-1 builds the shell/routing layer only. It does not implement real Assembler/Floor
Manager content for any variant (later nodes D9C-5/6/7), derived frontend view models
(D9C-2), reusable UI primitives (D9C-3), baseline-wrapping polish (D9C-4), cross-variant
labeling polish (D9C-8), or the dedicated verification script (D9C-9). It does not
implement authentication, RBAC, production actor-UI selection (D9D), or any backend/data
change.

## Next-Phase Handoff

On `RELEASE_APPROVED`, `/#/variants` exists with a working primary + secondary
shell/routing structure and placeholder panes for 3 variants × 2 actor views, ready for
later nodes to fill in real content one at a time without further shell/routing rework.

## Out of Scope

See Non-Goals above: real variant content, new dependencies, backend/API/data changes,
auth/RBAC, and any change to the existing `/` entry point's behavior.
