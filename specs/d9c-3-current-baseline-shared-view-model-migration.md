# Spec: Current Baseline Shared View Model Migration (D9C-3)

## Status
approved

## Phase
phase-ui

## Feature
d9c-3-current-baseline-shared-view-model-migration

## Capability

Today, `frontend/src/components/FactoryFlowBoard.tsx` (the "Current" engineering
console) owns its own factory-data fetching, selection, refresh, and reset logic —
duplicating, unconsumed, the exact same logic already extracted into
`frontend/src/view-model/useFactoryViewModel.ts` by D9C-2. After this capability,
`FactoryFlowBoard.tsx` consumes `useFactoryViewModel()` as its sole source of
factory-data state and operations. All local `useState`/`useCallback` factory-data
orchestration duplicated by the hook is removed from `FactoryFlowBoard.tsx`. Theme
state and compact-pane state remain local to `FactoryFlowBoard.tsx`, unchanged. No
rendered output, layout, styling, or interaction changes. No API, backend, or route
change.

## Source Authority

- `ai/recon/d9c-3-current-baseline-shared-view-model-migration.md` — recon that
  performed a full field-by-field and operation-by-operation parity comparison between
  `FactoryFlowBoard.tsx`'s existing local state/orchestration and the D9C-2
  `FactoryViewModel` contract, finding **full 1:1 parity with no conflict** — every
  field and operation Current uses today has an exact, faithfully-mirrored counterpart
  in the shared hook, and the two fields correctly excluded from the hook (`theme`,
  `compactPane`) are confirmed to be pure presentation state with no factory-data
  relationship.
- `specs/d9c-2-shared-view-model.md` — the predecessor spec. Its "Source Authority" and
  "Next-Phase Handoff" sections record the operator-amended DAG: "D9C-3 — migrate
  `FactoryFlowBoard` (Current) onto the shared view model (refactor, zero behavioral
  change)." This spec implements exactly that, and nothing more.
- `ai/state_registry.json` — confirms `d9c-1-variant-review-shell` and
  `d9c-2-shared-view-model` are both `RELEASE_APPROVED` predecessor states.
- `frontend/src/view-model/types.ts`, `frontend/src/view-model/useFactoryViewModel.ts` —
  the existing, unmodified D9C-2 contract this capability consumes. Neither file is
  modified by this capability.

## Current Problem

1. `FactoryFlowBoard.tsx` independently fetches/holds/derives the same 12 factory-data
   fields and 4 orchestration operations that `useFactoryViewModel()` already
   faithfully implements — a duplicate-ownership condition sanctioned only
   temporarily by D9C-2's own scope boundary.
2. No component actually consumes the D9C-2 hook yet (confirmed at D9C-2 close-out:
   `grep -rn "view-model" frontend/src/components/ ...` returned no matches) — the
   hook exists but is inert.

## Non-Goals / Out of Scope

- No backend, API, database, schema, or seed-data change of any kind.
- No change to `frontend/src/view-model/types.ts` or `useFactoryViewModel.ts` — the
  contract is consumed as-is, not redesigned. If recon or implementation discovers the
  contract cannot faithfully preserve Current's behavior, this is a STOP condition, not
  a license to modify the hook (recon already found full parity — no such discovery is
  expected during execution).
- No change to `frontend/src/components/variant-review/VariantReviewShell.tsx` or
  `VariantPlaceholderPane.tsx` — the variants remain unwired to the shared view model.
  That is explicitly D9C-4/D9C-5/D9C-6's job, one variant per node.
- No change to `frontend/src/main.tsx`, `frontend/src/App.tsx` — the Current route
  path is unaffected; `FactoryFlowBoard` is still rendered exactly the same way.
- No migration of `theme`/`toggleTheme` or `compactPane` state into the shared view
  model — both remain local `useState` inside `FactoryFlowBoard.tsx`, unchanged in
  behavior, persistence, or trigger logic.
- No redesign of Current's JSX structure, labels, layout, responsive breakpoints,
  Tailwind/token classes, or D8/D8A/D8B/D8C semantic `data-*` markers.
- No new npm dependency — `frontend/package.json`, `frontend/package-lock.json`
  unchanged.
- No implementation of Attention-First, Workflow-First, or Command-Center content.

## Data Model Changes
none

## API Surface
none

## Frontend Surface

Modified:

- `frontend/src/components/FactoryFlowBoard.tsx` —
  - Add one import: `import { useFactoryViewModel } from '../view-model/useFactoryViewModel'`.
  - Remove the 11 named imports from `../api/factoryApi'` (`ApiError,
    fetchDataContractStatus, fetchEvents, fetchHealth, fetchParts, fetchRefStandards,
    fetchStages, fetchUnit, fetchUnits, fetchUsers, postResetState`) — all become
    redundant once the hook owns these calls.
  - Add one invocation, once, near the top of the component body:
    `const vm = useFactoryViewModel()` (or an equivalent destructure of the same 16
    members — naming choice is an implementation detail as long as every existing
    read-site below is updated consistently).
  - Remove the 12 factory-data `useState` declarations (`health, contractStatus,
    stages, units, events, users, parts, refStandards, selectedUnitId, selectedUnit,
    loadError, resetting`), the `loadAll`/`refreshSelected`/`selectUnit`/`handleReset`
    callbacks, and the mount-time `useEffect(() => { void loadAll() }, [loadAll])`.
  - Retain unchanged: the `theme` `useState`, its `useEffect` (sets `data-theme` /
    persists to `localStorage`), `toggleTheme`, the `compactPane` `useState` and its
    setter, and every line of JSX/markup.
  - Update every existing read-site of the removed local variables/callbacks to read
    from the `useFactoryViewModel()` result instead (`health`→`vm.health`,
    `contractStatus`→`vm.contractStatus`, `stages`→`vm.stages`, `units`→`vm.units`,
    `events`→`vm.events`, `users`→`vm.users`, `parts`→`vm.parts` if referenced,
    `refStandards`→`vm.refStandards`, `selectedUnitId`→`vm.selectedUnitId`,
    `selectedUnit`→`vm.selectedUnit`, `loadError`→`vm.loadError`,
    `resetting`→`vm.resetting`, `handleReset`→`vm.resetDemoState`,
    `refreshSelected`→`vm.refreshSelected`, `selectUnit`→`vm.selectUnit`).

New:

- `scripts/verification/012-d9c-3-current-shared-view-model.sh` — a new,
  node-specific verification script (see Verification Scripts / Acceptance Criteria
  below for exactly what it must check). This is a deliverable of this capability's
  task graph, not a precondition for it — it does not exist at spec-compile time.

Unmodified (must remain byte-for-byte identical):

- `frontend/src/view-model/types.ts`, `frontend/src/view-model/useFactoryViewModel.ts`.
- `frontend/src/api/factoryApi.ts`, `frontend/src/types/factory.ts`.
- `frontend/src/components/variant-review/VariantReviewShell.tsx`,
  `VariantPlaceholderPane.tsx`.
- `frontend/src/components/UnitList.tsx`, `StageSpine.tsx`, `UnitDetailPanel.tsx`,
  `ActionPanel.tsx`, `EventTrace.tsx`.
- `frontend/src/main.tsx`, `frontend/src/App.tsx`, `frontend/src/styles.css`.
- `frontend/tailwind.config.js`, `frontend/package.json`, `frontend/package-lock.json`,
  `frontend/vite.config.ts`, `frontend/index.html`, `frontend/tsconfig.json`.
- Everything under `backend/`, `data/`, `docker-compose.yml`.

## Architecture Contract

- `useFactoryViewModel()` becomes the sole owner of factory-data loading, factory-data
  state, selected-unit state/selection/refresh, and factory-state reset consumed by
  Current. `FactoryFlowBoard.tsx` becomes the first real consumer of this control
  point.
- Current's rendered structure, user-visible behavior, API call semantics (same 8
  calls on load, same 3 on refresh, same reset call), action-completion behavior,
  selection behavior, reset behavior, theme behavior, and compact-pane behavior are
  all preserved exactly.
- No duplicate ownership of factory-data state remains between `FactoryFlowBoard.tsx`
  and `useFactoryViewModel.ts` after this capability — the component-local copies are
  fully removed, not merely left alongside the hook.
- No parallel data-fetching path is introduced — `FactoryFlowBoard.tsx` triggers no
  fetch directly; all fetching happens inside the hook, invoked exactly once.

## Operational Workflow

1. `FactoryFlowBoard` mounts, invokes `useFactoryViewModel()` once; the hook's
   internal mount effect fires the same 8-call `Promise.all` Current already performs
   today, now owned by the hook.
2. User selects a unit → `vm.selectUnit(id)` runs the same fetch/set logic
   `selectUnit` used to run locally.
3. User completes an action in `ActionPanel` → `onActionComplete` calls
   `vm.refreshSelected()`, identical to today's `refreshSelected()`.
4. User clicks "Reset Demo State" → `vm.resetDemoState()` runs the same
   reset/clear-selection/reload sequence `handleReset` used to run locally.
5. Theme toggle and compact-pane switching behave exactly as before — untouched local
   state, no interaction with the hook.

## Dependencies

- `ai/product-invariants.md` Invariant 2 (Backend Owns State Transitions) —
  unaffected; no new mutation path, only a relocation of existing call sites.
- `ai/runtime-contracts.md` Contracts 2/3 — unaffected; same `factoryApi.ts` functions,
  same call sites in effect, just invoked from inside the hook instead of the
  component.
- `specs/d9c-2-shared-view-model.md` — this capability is exactly the "D9C-3" migration
  that spec's Next-Phase Handoff anticipated; the hook contract is consumed unmodified.
- `specs/d9c-1-variant-review-shell.md` — unaffected; the variant review shell and its
  three placeholders are untouched, continue making zero API calls.
- `ai/recon/d9c-3-current-baseline-shared-view-model-migration.md` — full grounding for
  every claim in this spec, including the parity comparison and the two protected-path
  corrections (`frontend/src/variants/` does not exist; the real path is
  `frontend/src/components/variant-review/` — treated as protected).

## Acceptance Criteria

- [ ] `frontend/src/components/FactoryFlowBoard.tsx` imports and invokes
      `useFactoryViewModel` exactly once.
- [ ] All 12 factory-data `useState` declarations and the `loadAll`/`refreshSelected`/
      `selectUnit`/`handleReset` callbacks and the mount-time load effect are removed
      from `FactoryFlowBoard.tsx`; every read-site is updated to consume the hook's
      return value instead.
- [ ] `FactoryFlowBoard.tsx` contains zero direct imports from `../api/factoryApi`.
- [ ] `theme`, `toggleTheme`, and the theme `useEffect` remain in `FactoryFlowBoard.tsx`,
      byte-for-byte unchanged in behavior (persistence to `localStorage`, `data-theme`
      attribute set).
- [ ] `compactPane` state and its setter remain in `FactoryFlowBoard.tsx`, byte-for-byte
      unchanged in behavior.
- [ ] All existing child-component prop contracts (`UnitList`, `StageSpine`,
      `UnitDetailPanel`, `ActionPanel`, `EventTrace`) are unchanged — same prop names,
      same prop types, same values (now sourced from the hook).
- [ ] All existing D8/D8A/D8B/D8C `data-*` semantic markers and Current's labels/
      structural regions remain present, unchanged.
- [ ] `frontend/src/view-model/types.ts`, `useFactoryViewModel.ts` are byte-for-byte
      unchanged.
- [ ] `frontend/src/components/variant-review/VariantReviewShell.tsx`,
      `VariantPlaceholderPane.tsx` are byte-for-byte unchanged; still make zero API
      calls.
- [ ] `frontend/src/main.tsx`, `frontend/src/App.tsx`, `frontend/src/styles.css`,
      `frontend/src/api/factoryApi.ts`, `frontend/src/types/factory.ts` are
      byte-for-byte unchanged.
- [ ] `frontend/package.json`, `frontend/package-lock.json`, `frontend/vite.config.ts`,
      `frontend/index.html`, `frontend/tsconfig.json`, `frontend/tailwind.config.js`
      are byte-for-byte unchanged.
- [ ] Zero files under `backend/`, `data/`, `vendor/`, `.engineering-os/` are touched.
- [ ] The app builds/type-checks in strict mode with no new `any` types.
- [ ] `scripts/verification/012-d9c-3-current-shared-view-model.sh` exists and proves:
      the hook is imported and invoked exactly once in `FactoryFlowBoard.tsx`; no
      direct `factoryApi` import remains in `FactoryFlowBoard.tsx`; `theme` and
      `compactPane` state declarations remain in `FactoryFlowBoard.tsx`;
      `VariantReviewShell.tsx`/`VariantPlaceholderPane.tsx` are unchanged and still
      contain no `factoryApi`/`view-model` imports beyond what D9C-1 already
      established; no file under `backend/` changed.
- [ ] Full existing verification corpus `001`–`011` passes unweakened.
- [ ] `bash scripts/invariant-check.sh` — 6/6 PASS.
- [ ] Live behavior at `/` (Current) is unchanged: initial load, unit selection, one
      workflow action + refresh, reset demo state, theme toggle, and compact-pane
      switching all behave identically to pre-migration.
- [ ] `/#/variants` review shell still operates; Attention-First/Workflow-First/
      Command-Center panes remain untouched and gain no factory-data calls.
- [ ] Capability reaches `RELEASE_APPROVED` in `ai/state_registry.json`.

## Verification Scripts

(none)

## Regression Plan

The full existing chain (`001`–`011`) plus `scripts/smoke.sh` plus
`scripts/invariant-check.sh` (6/6) must still pass unweakened. Additionally, the new
`scripts/verification/012-d9c-3-current-shared-view-model.sh` (a task-graph
deliverable, not a precondition) is run manually after task execution completes, and
live Playwright browser verification of Current's full interaction surface (load,
select, action, refresh, reset, theme, compact panes) plus the `/#/variants` shell is
performed independently of the automated pipeline's self-report.

## Capability Phase Boundary

D9C-3 migrates only `FactoryFlowBoard.tsx` (Current) onto the shared view model. It
does not migrate any of the three variants (D9C-4/5/6), does not modify the hook
contract, does not add actor-specific derived data, and does not touch backend/API/
route surfaces.

## Next-Phase Handoff

On `RELEASE_APPROVED`, Current is the shared view model's first real consumer, with
zero duplicate factory-data ownership remaining. D9C-4 through D9C-6 (migrate
Attention-First, Workflow-First, Command-Center onto `useFactoryViewModel()`
individually) become the next available nodes — not executed by this capability.

## Out of Scope

See Non-Goals above: no hook-contract change, no variant wiring, no theme/pane
migration, no backend/API/data change, no new dependency.
