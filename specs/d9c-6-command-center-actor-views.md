# Spec: Command-Center Actor Views (D9C-6)

## Status
approved

## Phase
phase-ui

## Feature
d9c-6-command-center-actor-views

## Capability

Replace the `variantC` placeholder inside the existing `/#/variants` review shell with
a functional Command-Center experience for Assembler and Floor Manager, powered
exclusively by `useFactoryViewModel()`, and structurally distinct from Current,
Attention-First (D9C-4), and Workflow-First (D9C-5). This is the third and final
comparison variant. It does not select Command-Center as the production UI.

## Source Authority

- `ai/recon/d9c-6-command-center-actor-views.md` — full recon, no `Conflict: STOP`.
  Contains the required three-way structural comparison matrix (§6) proving
  Command-Center is a genuine third philosophy, not a re-styled copy of Current or a
  merge of the two completed variants.
- `ai/recon/d9b-three-functional-actor-first-ui-variants.md` §7 — Command-Center
  design authority: persistent multi-region layout, attention always visible when
  present (never a takeover, never gated behind a toggle), supporting detail genuinely
  collapsed by default.
- The eight files under `frontend/src/components/variant-review/{attention-first,
  workflow-first}/` — read for structural contrast only; not reused, not imported, not
  modified.
- `ai/incidents/d9c5-execution-supervisor-stdin-truncated-verification-loop.md` —
  governs the mandatory manual, non-supervisor-loop full-corpus verification for this
  node.

## Current Problem

`VariantPlaceholderPane` still renders inert placeholder copy for `variantC`. There is
no way to compare a persistent, always-visible, multi-region design against the two
already-built interaction models.

## Non-Goals / Out of Scope

- No backend, API, database, schema, or seed-data change.
- No change to Current, Attention-First (`attention-first/**`), or Workflow-First
  (`workflow-first/**`) — all remain byte-for-byte unchanged except the two narrow,
  pre-authorized fixes described below.
- No modification of `useFactoryViewModel.ts`/`types.ts`/`factoryApi.ts`/
  `ActionPanel.tsx`/`FactoryFlowBoard.tsx`.
- No wiring of the real `/factory/orders` endpoint — same reasoning as D9C-5; the
  Secondary Context region states plainly that order/stock/staffing data is
  unavailable.
- No invented identity, assignment, instructions, or telemetry — identical
  constraints to D9C-4/D9C-5.
- No full 14-stage engineering spine reproduction — the queue's per-unit stage number
  is sufficient; a full spine reproduces raw engineering detail this capability must
  keep hidden.
- No new npm dependency; no `frontend/package.json`/`package-lock.json` change.
- No renaming of `VariantReviewShell`'s tab-bar labels.
- **Narrow, pre-authorized exception**: `scripts/verification/013-d9c-4-attention-first-actor-views.sh`
  and `scripts/verification/014-d9c-5-workflow-first-actor-views.sh` each contain one
  stale check asserting `variantC` stays on `VariantPlaceholderPane` — both are
  updated to drop only that assertion (every other check in each script is untouched),
  the same class of fix already applied to `013`'s `variantB` assertion during D9C-5.
  This is authorized directly by this spec, not a scope violation.

## Data Model Changes
none

## API Surface
none

## Frontend Surface

New directory `frontend/src/components/variant-review/command-center/`:

- `CommandCenterView.tsx` — root. Calls `useFactoryViewModel()` exactly once. Holds
  `activeActor` state (same secondary-tab pattern as the other two variants). Renders
  `AssemblerCommandView`/`FloorManagerCommandView`, passing the same `vm` to both.
- `AssemblerCommandView.tsx` — renders four persistent regions **simultaneously, in a
  single render, no conditional hiding of any region as a whole**:
  1. Attention banner — rendered only when the focused unit's `blocked_reason != null`
     (a compact summary, not a takeover of the regions below it).
  2. Current Unit region — unit id, stage name, one primary action inline where
     available (via `CommandCenterActionForm`).
  3. Other Units region — persistent list of other non-terminal units with status
     chips, tap to refocus via `vm.selectUnit`.
  4. Supporting Detail region — a genuinely collapsed-by-default disclosure (default
     closed) showing part-allocation/calibration summary for the focused unit.
- `FloorManagerCommandView.tsx` — renders three persistent regions simultaneously:
  1. Attention/Triage region — rendered directly whenever
     `blockedUnits.length > 0` (no expand/collapse toggle gating its visibility).
  2. Queue region — always rendered regardless of attention state.
  3. Secondary Context region — always rendered (not behind a tab), visually
     subordinate styling, honest "order/stock/staffing information is not available in
     this view" content.
- `CommandCenterActionForm.tsx` — independent implementation of the same
  stage-to-action mapping used by the other two variants (stage 5 reallocate / stage
  10 calibration or disposition / stage 12 cloud-backup retry), calling the same
  unmodified `factoryApi.ts` functions. Not imported from `attention-first/` or
  `workflow-first/`.

Modified:

- `frontend/src/components/variant-review/VariantReviewShell.tsx` — only the
  `variantC` branch changes to render `<CommandCenterView/>`. `variantA`/`variantB`
  and all tab labels unchanged.
- `scripts/verification/013-d9c-4-attention-first-actor-views.sh`,
  `scripts/verification/014-d9c-5-workflow-first-actor-views.sh` — each has its one
  stale `variantC`-stays-a-placeholder assertion removed; every other check untouched.
- `frontend/src/styles.css` — additive only, if genuinely needed beyond existing
  tokens.

New:

- `scripts/verification/015-d9c-6-command-center-actor-views.sh` — authored directly
  by the orchestrator.

Unmodified (byte-for-byte, protected):

- `frontend/src/components/{FactoryFlowBoard,ActionPanel,UnitList,StageSpine,
  UnitDetailPanel,EventTrace}.tsx`, `frontend/src/components/variant-review/
  {attention-first,workflow-first}/**` (all eight files), `frontend/src/view-model/
  {types.ts,useFactoryViewModel.ts}`, `frontend/src/api/factoryApi.ts`,
  `frontend/src/types/factory.ts`, `frontend/src/main.tsx`, `frontend/src/App.tsx`,
  all frontend config/lockfiles, everything under `backend/`, `data/`, `vendor/`,
  `.engineering-os/`.

## Architecture Contract

- `useFactoryViewModel()` remains the sole factory-data orchestration source; no
  parallel initial-data fetch.
- Command-Center's structural signature — all actor-relevant regions simultaneously
  visible, attention never a takeover and never gated behind a toggle, supporting
  detail genuinely collapsed by default — is an acceptance requirement distinguishing
  it from both Current (undifferentiated, everything-open engineering console) and
  the two completed variants (state-driven takeover / actor-driven toggle+tab).
- Every displayed fact is deterministically derived from `vm.units`' existing fields,
  or explicitly labeled unavailable.
- `CommandCenterActionForm`'s action calls are the one write-side exception to
  read-via-view-model, mirroring the already-established, directive-sanctioned
  pattern from both prior variants.
- Current, Attention-First, Workflow-First, backend, workflow rules, and the
  canonical 14-stage model are unaffected.

## Operational Workflow

1. Operator opens `/#/variants` → "Variant C — Command-Center" tab.
2. `CommandCenterView` mounts, calls `useFactoryViewModel()` once.
3. Assembler sub-view shows all four regions together; if the focused unit is
   blocked, the Attention banner appears above the still-visible Current Unit and
   Other Units regions — nothing is replaced or hidden.
4. Floor Manager sub-view shows Attention/Triage (if non-empty), Queue, and Secondary
   Context together, with no toggle or tab required to see any of them.
5. Submitting an action calls the same backend endpoint the other two variants would
   call for that stage/condition, refreshed via the view model.
6. Current, Attention-First, and Workflow-First remain untouched and fully functional
   throughout.

## Dependencies

- `ai/product-invariants.md` Invariant 2/3 — unaffected/reinforced, identical
  reasoning to D9C-4/D9C-5.
- `ai/runtime-contracts.md` Contracts 2/3 — unaffected.
- `specs/d9c-4-attention-first-actor-views.md`,
  `specs/d9c-5-workflow-first-actor-views.md` — this node does not weaken either's
  acceptance criteria; the two predecessor-script updates are narrow and
  pre-authorized (see Non-Goals).
- `ai/incidents/d9c5-execution-supervisor-stdin-truncated-verification-loop.md` —
  governs mandatory manual full-corpus verification, independent of the supervisor's
  own loop.

## Acceptance Criteria

- [ ] `frontend/src/components/variant-review/command-center/{CommandCenterView,
      AssemblerCommandView,FloorManagerCommandView,CommandCenterActionForm}.tsx`
      exist.
- [ ] `CommandCenterView` calls `useFactoryViewModel` exactly once; no other new file
      calls it.
- [ ] No new file imports a `fetch*` read function; only `CommandCenterActionForm.tsx`
      imports the four action-submission functions.
- [ ] Zero imports from `attention-first/` or `workflow-first/` in any new file.
- [ ] `AssemblerCommandView` renders all four regions (Attention-when-present, Current
      Unit, Other Units, Supporting Detail) in one simultaneous render — no
      conditional branch hides the whole Current Unit or Other Units region based on
      attention state.
- [ ] Supporting Detail defaults closed (a real, toggled disclosure state, not
      markup-only).
- [ ] `FloorManagerCommandView`'s Attention/Triage region renders directly whenever
      non-empty — no explicit-toggle state gates its visibility (contrast:
      Workflow-First's `triageOpen`).
- [ ] Queue and Secondary Context regions are always rendered in
      `FloorManagerCommandView`, regardless of attention state — Secondary Context is
      not behind a second tab.
- [ ] Secondary Context states plainly that order/stock/staffing data is unavailable —
      no fabricated numbers, no new fetch call.
- [ ] `VariantReviewShell.tsx`'s `variantC` branch renders `<CommandCenterView/>`;
      `variantA`/`variantB` and all tab labels unchanged.
- [ ] `scripts/verification/013-*.sh` and `014-*.sh` each have only their stale
      `variantC` assertion removed — every other check intact and still passing.
- [ ] No raw endpoint text, no free-text actor-ID field, in any new file.
- [ ] `attention-first/**`, `workflow-first/**`, `FactoryFlowBoard.tsx`,
      `ActionPanel.tsx`, `useFactoryViewModel.ts`, `types.ts`, `factoryApi.ts`,
      `UnitList.tsx`, `StageSpine.tsx`, `UnitDetailPanel.tsx`, `EventTrace.tsx`,
      `main.tsx`, `App.tsx` are byte-for-byte unchanged.
- [ ] Zero files under `backend/`, `data/`, `vendor/`, `.engineering-os/` touched.
- [ ] The app builds/type-checks in strict mode; no new `any`; no new TypeScript/lint
      error beyond the documented pre-existing baseline.
- [ ] `scripts/verification/015-d9c-6-command-center-actor-views.sh` exists (authored
      by the orchestrator) and proves every item above.
- [ ] Every script in `scripts/verification/` (001 through 015) is run manually,
      outside the supervisor's own loop, with an individually recorded exit code —
      not merely inferred from the supervisor's own "Verification: pass" report.
- [ ] `bash scripts/invariant-check.sh` — 6/6 PASS.
- [ ] Live behavior confirmed via Playwright **after rebuilding the frontend image and
      positively confirming the served bundle contains `CommandCenterView`**: all
      regions visible together for both actors, one executed action, Current/
      Attention-First/Workflow-First unaffected, demo state reset to canonical
      afterward.
- [ ] Capability reaches `RELEASE_APPROVED` in `ai/state_registry.json`, substantively
      confirmed by the orchestrator.

## Verification Scripts

(none)

## Regression Plan

Every script `001` through `015` run manually in a plain shell loop (not solely via
`execution-supervisor.sh`'s own loop, which is confirmed to silently stop after `007`
— see the incident referenced in Source Authority), plus `scripts/smoke.sh` plus
`scripts/invariant-check.sh` (6/6), plus independent live Playwright verification
against a freshly rebuilt frontend image.

## Capability Phase Boundary

D9C-6 implements Command-Center only — the last of the three comparison variants. Does
not modify Attention-First or Workflow-First (beyond the two narrow, pre-authorized
script fixes), does not modify the shared view-model contract, does not add
authentication or select a production UI.

## Next-Phase Handoff

On `RELEASE_APPROVED`, all three functional actor-first variants (Attention-First,
Workflow-First, Command-Center) exist side-by-side with Current for operator/Vijay
comparison, per the original D9B "three functional options, presented together"
instruction. No further D9C-series UI variant work is anticipated by this spec; any
next step (selection, production-UI adoption, or further iteration) is an operator
decision, not executed by this capability.

## Out of Scope

See Non-Goals above: no hook/contract change, no Attention-First/Workflow-First/
Current change beyond the two narrow script fixes, no backend/API/data change, no
orders-endpoint wiring, no new dependency, no production-UI selection.
