# Spec: Shared View Model (D9C-2)

## Status
approved

## Phase
phase-ui

## Feature
d9c-2-shared-view-model

## Capability

Today, all factory-data fetching, derivation, and selected-unit state lives entirely
inside `frontend/src/components/FactoryFlowBoard.tsx` — 8 parallel API calls, selected-
unit state, error/reset state, all as component-local `useState`/`useCallback` logic
with no reusable extraction point. There is no shared data layer any other component
(the D9C-1 variant-review shell's placeholders, or any future actor-first variant) could
consume without re-implementing the same fetch/derive logic from scratch.

After this capability, a single new, standalone module —
`frontend/src/view-model/useFactoryViewModel.ts` — exists as the canonical, reusable
source of factory presentation data (units, stages, events, users, parts, reference
standards, health/contract status, selected-unit state, and the load/select/refresh/reset
operations), faithfully extracted from `FactoryFlowBoard.tsx`'s existing logic with
**zero behavioral difference**. **Nothing consumes this new hook yet** — `FactoryFlowBoard.tsx`
is not modified, and neither of the D9C-1 variant placeholder panes is modified. This
capability is architecture-only: it introduces the shared view model as a new, inert
addition to the codebase, so that later, separately-directed nodes can migrate existing
consumers onto it one at a time.

## Source Authority

- `ai/recon/d9c2-shared-view-model.md` — recon that found a real conflict between this
  capability's originally-incoming smoke test (which implied the three variants must
  already visibly consume the model) and two settled facts: `ai/recon/d9c0-variant-review-shell-preflight-scope-lock.md`
  §7's "D9C-2 — derived frontend view models only (no new UI)" scoping, and
  `specs/d9c-1-variant-review-shell.md`'s already-`RELEASE_APPROVED` acceptance criterion
  that the three variant placeholders make zero API calls / show no factory data.
- **Operator decision (2026-07-12):** D9C-2 is an architecture capability only. Build the
  canonical shared view model and derivation layer. Do not wire Current. Do not wire any
  variant. Do not change any rendered behavior. This spec implements that decision.
- **Operator-amended DAG (2026-07-12, supersedes the equivalent portion of
  `ai/recon/d9c0-variant-review-shell-preflight-scope-lock.md` §7):**
  - D9C-2 (this capability) — shared view model, architecture only, no consumers wired.
  - D9C-3 — migrate `FactoryFlowBoard` (Current) onto the shared view model (refactor,
    zero behavioral change).
  - D9C-4 through D9C-6 — migrate the three variants (Attention-First, Workflow-First,
    Command-Center) onto the shared view model individually, one per node.
  - (D9C-0's original D9C-3/D9C-4/D9C-5-7/D9C-8/D9C-9 labels are superseded by this
    amended sequence where they conflict; D9C-9-equivalent verification/evidence-capture
    work is still expected as a later, separate node.)
- `ai/recon/d9b-three-functional-actor-first-ui-variants.md` — confirms the three variants
  differ in structural/interaction priority over the *same* underlying facts (current
  unit, assigned/blocked units, attention items, stage queue, secondary info) — the
  architectural motivation for one shared derivation layer.
- `ai/product-invariants.md` Invariant 2, `ai/runtime-contracts.md` Contracts 2/3 —
  governing invariants; unaffected (see Dependencies).
- `frontend/src/components/FactoryFlowBoard.tsx`, `frontend/src/api/factoryApi.ts`,
  `frontend/src/types/factory.ts` — full grounding for the exact logic being extracted.

## Current Problem

1. Factory-data fetching/derivation/selection logic exists in exactly one place
   (`FactoryFlowBoard.tsx`), with no extraction point for reuse.
2. Any future consumer (the D9C-1 variant panes, once they gain real content) would
   otherwise have to re-implement the same 8-call fetch sequence and selected-unit logic
   independently, producing duplicated presentation state across consumers.

## Non-Goals / Out of Scope

- No backend, API, database, schema, or seed-data change of any kind.
- No change to `FactoryFlowBoard.tsx` or any of its existing children — Current is not
  touched, not even to import the new hook. That migration is explicitly D9C-3's job.
- No change to `frontend/src/components/variant-review/VariantReviewShell.tsx` or
  `VariantPlaceholderPane.tsx` — the variants are not wired to the new hook. That
  migration is explicitly D9C-4/D9C-5/D9C-6's job, one variant per node.
- No new npm dependency — `frontend/package.json`, `frontend/package-lock.json`
  unchanged. No state-management library (Redux/Zustand/React Query/etc.) is
  introduced — the hook uses plain React `useState`/`useCallback`/`useEffect`, matching
  the existing codebase's only precedent (`FactoryFlowBoard.tsx` itself).
- No authentication, RBAC, or actor-specific derived slices (e.g. "attention items",
  "units assigned to an actor") — those are actor-specific concerns for the later
  variant-migration nodes (D9C-4/5/6), not this architecture-only node. The view model
  exposes the same canonical, actor-agnostic facts `FactoryFlowBoard` already manages
  today — nothing more.
- No UI chrome (theme, active-pane/tab state) is part of the shared view model — theme
  and layout/navigation state are cross-cutting or variant-specific presentation concerns,
  not factory-domain data, and stay local to whichever component renders them (as
  `FactoryFlowBoard.tsx` already does today, unchanged).
- Temporary, deliberate duplication: until D9C-3 migrates `FactoryFlowBoard`, its existing
  internal fetch/state logic and the new hook's logic are two independent implementations
  of the same behavior. This is intentional and explicitly sanctioned by the operator
  decision above — deduplication happens in D9C-3, not this node.

## Data Model Changes
none

## API Surface
none

## Frontend Surface

New directory `frontend/src/view-model/`:

- `types.ts` — exports the `FactoryViewModel` interface:
  ```ts
  export interface FactoryViewModel {
    health: HealthResponse | null
    contractStatus: DataContractStatus | null
    stages: FactoryStage[]
    units: FactoryUnit[]
    events: FactoryEvent[]
    users: FactoryUser[]
    parts: FactoryPart[]
    refStandards: FactoryRefStd[]
    selectedUnitId: string | null
    selectedUnit: FactoryUnit | null
    loadError: string | null
    resetting: boolean
    selectUnit: (id: string) => Promise<void>
    refreshSelected: () => Promise<void>
    reload: () => Promise<void>
    resetDemoState: () => Promise<void>
  }
  ```
  All member types imported from `frontend/src/types/factory.ts` — no new/duplicated
  type definitions for shapes that already exist there.
- `useFactoryViewModel.ts` — exports `useFactoryViewModel(): FactoryViewModel`, a custom
  React hook implementing **exactly** the logic currently embedded in
  `FactoryFlowBoard.tsx`'s `health`/`contractStatus`/`stages`/`units`/`events`/`users`/
  `parts`/`refStandards`/`selectedUnitId`/`selectedUnit`/`loadError`/`resetting` state and
  its `loadAll`/`selectUnit`/`refreshSelected`/`handleReset` callbacks and the mount-time
  `useEffect` that calls `loadAll`, faithfully extracted (same `Promise.all` call order:
  `fetchHealth, fetchDataContractStatus, fetchStages, fetchUnits, fetchEvents, fetchUsers,
  fetchParts, fetchRefStandards`; same error handling via `ApiError`; same silent-catch
  behavior in `refreshSelected`) — renamed only where necessary (`handleReset` →
  `resetDemoState`, `loadAll` → `reload`) to read as a general-purpose hook rather than a
  component-internal handler. This is a pure extraction — no new fetch call, no new
  derived field, no changed call order or error-handling behavior relative to
  `FactoryFlowBoard.tsx`'s current implementation.

Unmodified (must remain byte-for-byte identical — this capability touches nothing that
any existing component or verification script observes):

- `frontend/src/components/FactoryFlowBoard.tsx` and every existing child component.
- `frontend/src/components/variant-review/VariantReviewShell.tsx`,
  `VariantPlaceholderPane.tsx`.
- `frontend/src/main.tsx`, `frontend/src/App.tsx`, `frontend/src/styles.css`.
- `frontend/src/api/factoryApi.ts`, `frontend/src/types/factory.ts`.
- `frontend/index.html`, `frontend/vite.config.ts`, `frontend/tsconfig.json`,
  `frontend/package.json`, `frontend/package-lock.json`.

## Architecture Contract (this node's scope within the larger, multi-node goal)

- **One canonical UI view model**: `useFactoryViewModel()` becomes the single reusable
  definition of factory presentation data. This node creates it; it does not yet make it
  the *only* place such logic exists (see Non-Goals — `FactoryFlowBoard.tsx`'s existing
  logic is untouched and temporarily duplicative until D9C-3).
- **Zero duplicated presentation state — end-state goal, not this node's exit
  condition**: full deduplication is reached only after D9C-3 (Current migrated) and
  D9C-4/5/6 (variants migrated) complete. This node's exit condition is narrower: the
  shared view model exists, is correctly typed, and faithfully mirrors
  `FactoryFlowBoard.tsx`'s current behavior, with zero consumers wired yet.
  cross-referenced explicitly so this is not mistaken for a violation of this node's own
  acceptance criteria.
- **Current view remains behaviorally identical**: trivially true this node, since
  `FactoryFlowBoard.tsx` is not modified at all.

## Operational Workflow

1. A developer working on D9C-3 (Current migration) or D9C-4/5/6 (variant migration) can
   `import { useFactoryViewModel } from '../view-model/useFactoryViewModel'` and call it
   to get the exact same data/operations `FactoryFlowBoard.tsx` manages today, without
   re-implementing any fetch logic.
2. No end-user-visible behavior changes as a result of this capability — the running
   application (both `/` and `/#/variants`) is pixel-and-behavior identical before and
   after, because no existing file that renders UI is modified.

## Dependencies

- `ai/product-invariants.md` Invariant 2 (Backend Owns State Transitions) — unaffected;
  the hook only wraps existing read calls and the existing reset/action-refresh calls,
  adding no new mutation path and no client-side transition logic.
- `ai/runtime-contracts.md` Contract 2 (Frontend Communicates via REST API Only) and
  Contract 3 (Backend Owns All Factory State Transitions) — unaffected; the hook calls
  only the existing, unchanged `factoryApi.ts` functions.
- `specs/d9c-1-variant-review-shell.md` — this capability does not modify or weaken any
  of its acceptance criteria; the variant placeholders remain exactly as released.
- `ai/recon/d9b-three-functional-actor-first-ui-variants.md`,
  `ai/recon/d9c0-variant-review-shell-preflight-scope-lock.md`,
  `ai/recon/d9c2-shared-view-model.md` — full grounding for every claim in this spec.

## Acceptance Criteria

- [ ] `frontend/src/view-model/types.ts` exists and exports `FactoryViewModel` with
      exactly the shape specified above, reusing existing types from
      `frontend/src/types/factory.ts` (no duplicate/redefined domain types).
- [ ] `frontend/src/view-model/useFactoryViewModel.ts` exists and exports
      `useFactoryViewModel(): FactoryViewModel`, faithfully mirroring
      `FactoryFlowBoard.tsx`'s current fetch sequence, state shape, and error handling.
- [ ] `frontend/src/components/FactoryFlowBoard.tsx` is byte-for-byte unchanged.
- [ ] `frontend/src/components/variant-review/VariantReviewShell.tsx` and
      `VariantPlaceholderPane.tsx` are byte-for-byte unchanged.
- [ ] `frontend/src/main.tsx`, `frontend/src/App.tsx`, `frontend/src/styles.css` are
      byte-for-byte unchanged.
- [ ] `frontend/src/api/factoryApi.ts`, `frontend/src/types/factory.ts` are byte-for-byte
      unchanged.
- [ ] `frontend/package.json`, `frontend/package-lock.json`, `frontend/vite.config.ts`,
      `frontend/index.html`, `frontend/tsconfig.json` are byte-for-byte unchanged.
- [ ] Zero files under `backend/`, `data/`, `vendor/`, `.engineering-os/` are touched.
- [ ] The app still builds/type-checks (`frontend/tsconfig.json`'s strict mode; no `any`
      types introduced); the new hook file compiles standalone even though nothing
      imports it yet.
- [ ] Running application behavior at both `/` and `/#/variants` is unaffected (full
      existing verification corpus 001–011 passes unweakened).
- [ ] `bash scripts/invariant-check.sh` — 6/6 PASS.
- [ ] Capability reaches `RELEASE_APPROVED` in `ai/state_registry.json`.

## Verification Scripts

(none)

## Regression Plan

The full existing chain (001–011) plus `scripts/smoke.sh` plus
`scripts/invariant-check.sh` (6/6) must still pass unweakened. Since no existing,
consumed file is modified, this should hold trivially — this capability adds new,
currently-unimported files only.

## Capability Phase Boundary

D9C-2 builds the shared view-model layer only, with zero consumers. It does not migrate
`FactoryFlowBoard` (D9C-3), does not migrate any of the three variants (D9C-4/5/6), does
not add actor-specific derived slices, does not add authentication/RBAC, and does not add
a dedicated verification script (a later, separate evidence-capture node still applies,
per the amended DAG in Source Authority).

## Next-Phase Handoff

On `RELEASE_APPROVED`, `frontend/src/view-model/useFactoryViewModel.ts` exists, is fully
typed, and faithfully mirrors `FactoryFlowBoard.tsx`'s current behavior — ready for D9C-3
to migrate Current onto it (refactor, zero behavior change) and for D9C-4/5/6 to migrate
each variant onto it individually, one per node, without further shared-architecture
rework.

## Out of Scope

See Non-Goals above: no UI wiring of any kind, no actor-specific derived data, no new
dependency, no backend/API/data change.
