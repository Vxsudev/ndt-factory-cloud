# Spec: Attention-First Actor Views (D9C-4)

## Status
approved

## Phase
phase-ui

## Feature
d9c-4-attention-first-actor-views

## Capability

Replace the `variantA` placeholder inside the existing `/#/variants` review shell with
a functional Attention-First experience for two actor-scoped views — Assembler and
Floor Manager — powered exclusively by the existing `useFactoryViewModel()` hook. This
is a comparative design implementation only; it does not select Attention-First as the
production UI, and it does not touch Current, Workflow-First, Command-Center, or any
backend/data surface.

## Source Authority

- `ai/recon/d9c-4-attention-first-actor-views.md` — full recon. Key resolved findings:
  no `Conflict: STOP` was triggered; every data gap found (actor identity, corrective
  instructions, live telemetry, secondary info) was resolved by scoping the design down
  to what canonical data truthfully supports, per the directive's own instruction not
  to fabricate.
- `ai/recon/d9b-three-functional-actor-first-ui-variants.md` §5 — the design authority
  for Attention-First's calm/interrupt behavior for both actors.
- `specs/d9c-2-shared-view-model.md`, `specs/d9c-3-current-baseline-shared-view-model-migration.md`
  — predecessor specs; this capability is the first of the operator-amended D9C-4/5/6
  variant-migration sequence.

## Current Problem

`frontend/src/components/variant-review/VariantPlaceholderPane.tsx` renders identical,
inert placeholder copy for all three variants. Attention-First has no functional
content; Vijay cannot compare it against Current on real behavior.

## Non-Goals / Out of Scope

- No backend, API, database, schema, or seed-data change of any kind.
- No change to Workflow-First or Command-Center — both remain
  `VariantPlaceholderPane` placeholders, byte-for-byte unchanged in this node.
- No change to `FactoryFlowBoard.tsx`, `useFactoryViewModel.ts`, `types.ts`,
  `factoryApi.ts`, `UnitList.tsx`, `StageSpine.tsx`, `UnitDetailPanel.tsx`,
  `EventTrace.tsx`, `main.tsx`, `App.tsx`.
- **No modification to `ActionPanel.tsx`.** Per recon §10, `ActionPanel` is not reused
  as a child (it unconditionally renders raw endpoint-path text and a generic "Dev —
  Backend-Guarded Transition" panel, both explicitly forbidden for actor-first views).
  New, minimal action affordances are built instead, calling the same unmodified
  `factoryApi.ts` functions directly.
- No authenticated actor identity, no invented unit-assignment relationship (recon §8:
  `assigned_operator_id` cannot truthfully support "assigned to me" with no login — the
  Assembler's "current unit" is a manually-focused unit, exactly like Current's
  `selectedUnit` mechanism, not an auto-derived personal assignment).
- No invented failure-mode-to-instruction lookup table (recon §6: `blocked_reason` is
  shown reformatted for readability — underscores to spaces, sentence case — not
  replaced with authored corrective sentences).
- No invented live-device-activity badge (recon §7: no such telemetry exists; not
  built).
- No invented orders/stock/staffing data for the Floor Manager's secondary info (recon
  §6: no such endpoints exist; not built — also out of scope per D9B itself).
- No multi-tier attention severity — `blocked_reason != null` is the single, binary
  attention signal (recon §9).
- No new npm dependency. No change to `frontend/package.json`/`package-lock.json`.
- No renaming of the existing `VariantReviewShell` tab-bar labels (recon §3 — a
  settled D9C-1 chrome concern, out of scope for this content-only capability).

## Data Model Changes
none

## API Surface
none

## Frontend Surface

New directory `frontend/src/components/variant-review/attention-first/`:

- `AttentionFirstView.tsx` — root component. Calls `useFactoryViewModel()` exactly
  once. Holds `activeActor: 'assembler' | 'floorManager'` state (mirrors the existing
  `VariantPlaceholderPane` secondary-tab pattern: `touch-target-secondary` buttons).
  Renders `<AssemblerView vm={vm}/>` or `<FloorManagerView vm={vm}/>`, passing the same
  `vm` object to both — the hook is never re-invoked on actor switch.
- `AssemblerView.tsx` — implements the calm/interrupt contract from recon §11/§12:
  - Calm: one card for the focused unit (`vm.selectedUnit`, defaulting via
    `vm.selectUnit` to the first non-terminal unit in `vm.units` if nothing is focused
    yet), its stage name (from `vm.stages`), a single primary action per the stage
    mapping below, and a compact strip of other non-terminal units (tap to refocus via
    `vm.selectUnit`).
  - Interrupt: activates when the focused unit's `blocked_reason != null`. Full-bleed
    card: reformatted `blocked_reason`, a `NO OVERRIDE` marker if `no_override` is
    true, the action control from `AttentionActionForm` if one exists for this
    condition, otherwise a plain "Blocked — no action available, awaiting external
    resolution" message. A "Back to my unit" control returns to calm state once
    `blocked_reason` clears.
- `FloorManagerView.tsx` — implements recon §13/§14:
  - Calm: the queue (`vm.units`, grouped/labeled by stage) fills most of the view; a
    small always-visible attention counter
    (`vm.units.filter(u => u.blocked_reason && !u.package_ship_status.terminal).length`)
    at the top.
  - Triage: when the counter is non-zero, the top becomes a list of exactly those
    blocked units, each with reformatted `blocked_reason` and a "Resolve" affordance
    (via `AttentionActionForm`) if a corrective action exists for that unit's
    condition.
- `AttentionActionForm.tsx` — single shared component, imported by both actor views.
  Given a unit, renders the minimal, correct action control per the stage mapping in
  recon §10 (stage 5 blocked → reallocate-part; stage 10 not cap-exceeded →
  calibration; stage 10 cap-exceeded → calibration-disposition; stage 12 → cloud-backup
  retry), calling the corresponding unmodified `factoryApi.ts` function with the same
  request shape `ActionPanel.tsx` already uses. No raw endpoint-path text, no free-text
  actor-ID field (uses a fixed internal demo actor id constant, matching the existing
  demo-actor convention already used by `ActionPanel.tsx`'s own default field values,
  e.g. `USER-OP-0001`/`USER-MGR-0001`). On success, calls `vm.refreshSelected()` (if
  acting on the focused unit) or `vm.reload()` (otherwise) — the same refresh contract
  `ActionPanel` already uses via `onActionComplete`. If no corrective action exists for
  the unit's condition (e.g. stage 7), renders nothing (the parent shows the "no action
  available" message instead).

Modified:

- `frontend/src/components/variant-review/VariantReviewShell.tsx` — the `variantA` tab
  renders `<AttentionFirstView/>` instead of
  `<VariantPlaceholderPane variantId="variantA" variantLabel="Variant A — Attention-First"/>`.
  `variantB`/`variantC` tabs, and the top-level tab-bar labels, are unchanged.
- `frontend/src/styles.css` — additive only, if any bounded Attention-First-specific
  class is needed that cannot be expressed with existing `surf-*`/`t-on-*`/`b-*`/
  `mdc-*`/`touch-target-*` tokens/utilities. No existing rule is modified.

New:

- `scripts/verification/013-d9c-4-attention-first-actor-views.sh` — authored directly
  by the orchestrator (not a task-graph deliverable; see Verification Scripts below and
  `ai/incidents/d9c3-verification-script-deliverable-skipped-by-worker.md` for why).

Unmodified (must remain byte-for-byte identical):

- `frontend/src/components/FactoryFlowBoard.tsx`, `frontend/src/view-model/{types.ts,
  useFactoryViewModel.ts}`, `frontend/src/api/factoryApi.ts`, `frontend/src/types/
  factory.ts`, `frontend/src/components/{UnitList,StageSpine,UnitDetailPanel,
  EventTrace,ActionPanel}.tsx`, `frontend/src/main.tsx`, `frontend/src/App.tsx`,
  `frontend/src/components/variant-review/VariantPlaceholderPane.tsx` (still used by
  `variantB`/`variantC`), all frontend config/lockfiles, everything under `backend/`,
  `data/`, `vendor/`, `.engineering-os/`.

## Architecture Contract

- `useFactoryViewModel()` remains the sole factory-data orchestration source; Attention-
  First introduces no second read-orchestration path (recon §15 — one hook call per
  mount of `AttentionFirstView`, shared across both actor sub-views via prop passing,
  not per-actor re-invocation).
- Every displayed status/unit/attention condition is deterministically derived from
  `vm.units`' existing fields (`blocked_reason`, `no_override`, `package_ship_status`,
  `current_stage_number`) — no fabricated field, no invented instruction text beyond a
  mechanical reformat, no invented identity/assignment/telemetry (recon §6/§7/§8).
  `AttentionActionForm`'s corrective-action calls are the one exception to "read-only
  via the view model": they call the same existing action-mutation endpoints
  `ActionPanel.tsx` already calls, via the same unmodified `factoryApi.ts` — this is
  action-submission (write-side, backend-guarded), not a second data-loading
  orchestration path, and is explicitly permitted by the directive
  ("supported approval/disposition actions may reuse existing backend-governed action
  surfaces").
- Current, Workflow-First, Command-Center, backend, workflow rules, and the canonical
  14-stage model are unaffected.

## Operational Workflow

1. Operator navigates to `/#/variants`, selects the "Variant A — Attention-First" tab.
2. `AttentionFirstView` mounts, calls `useFactoryViewModel()` once; data loads exactly
   as it does for Current.
3. Assembler sub-view (default) shows the calm-state card for the first non-terminal
   unit; if that unit is blocked, the interrupt state shows immediately instead.
4. Switching to Floor Manager sub-view (inner tab, no remount) shows the queue and
   attention counter; if any unit is blocked, the triage list appears at top.
5. Submitting a corrective action (where one exists) calls the same backend endpoint
   `ActionPanel` would call for that stage/condition, then refreshes via the view
   model, exactly mirroring Current's existing action-completion behavior.
6. Workflow-First and Command-Center tabs remain untouched placeholders throughout.

## Dependencies

- `ai/product-invariants.md` Invariant 2 (Backend Owns State Transitions), Invariant 3
  (Hard-Stops Absolutely Blocking) — unaffected/reinforced (recon §17): no client-side
  transition legality is introduced; the stage-7 "no action available" truthful state
  correctly reflects a `no_override` hard-stop rather than bypassing it.
- `ai/runtime-contracts.md` Contracts 2/3 — unaffected; all calls go through the
  existing, unmodified `factoryApi.ts`.
- `specs/d9c-1-variant-review-shell.md`, `specs/d9c-2-shared-view-model.md`,
  `specs/d9c-3-current-baseline-shared-view-model-migration.md` — this capability
  builds directly on all three without modifying any of their acceptance criteria.
- `ai/incidents/d9c3-verification-script-deliverable-skipped-by-worker.md` — governs
  the orchestrator-only authorship of the new verification script for this node.

## Acceptance Criteria

- [ ] `frontend/src/components/variant-review/attention-first/{AttentionFirstView,
      AssemblerView,FloorManagerView,AttentionActionForm}.tsx` exist.
- [ ] `AttentionFirstView` imports and invokes `useFactoryViewModel` exactly once;
      actor switching does not re-invoke it.
- [ ] None of the four new components import from `../../../api/factoryApi` for
      **read** endpoints (`fetchHealth`/`fetchUnits`/etc.) — only `AttentionActionForm`
      imports action-submission functions (`postCalibration`, `postCalibrationDisposition`,
      `postCloudBackup`, `postReallocatePart`), matching `ActionPanel.tsx`'s own import
      pattern for those same functions.
- [ ] `VariantReviewShell.tsx`'s `variantA` tab renders `<AttentionFirstView/>`;
      `variantB`/`variantC` tabs and all tab-bar labels are unchanged.
- [ ] Assembler calm state shows one focused unit with a compact strip of other units;
      no raw endpoint text, no free-text actor-ID field, no forced-open engineering
      detail panels.
- [ ] Assembler interrupt state activates only when the focused unit's
      `blocked_reason != null`; shows reformatted `blocked_reason`, `NO OVERRIDE` where
      true, and either a real corrective action or a truthful "no action available"
      message.
- [ ] Floor Manager calm state shows the queue and an attention counter computed as
      `blocked_reason != null && !terminal` over `vm.units`.
- [ ] Floor Manager triage state appears only when the counter is non-zero, listing
      exactly the blocked units.
- [ ] `ActionPanel.tsx`, `FactoryFlowBoard.tsx`, `useFactoryViewModel.ts`, `types.ts`,
      `factoryApi.ts`, `UnitList.tsx`, `StageSpine.tsx`, `UnitDetailPanel.tsx`,
      `EventTrace.tsx`, `main.tsx`, `App.tsx`, `VariantPlaceholderPane.tsx` are
      byte-for-byte unchanged.
- [ ] Zero files under `backend/`, `data/`, `vendor/`, `.engineering-os/` touched.
- [ ] The app builds/type-checks in strict mode, no new `any`.
- [ ] `scripts/verification/013-d9c-4-attention-first-actor-views.sh` exists (authored
      by the orchestrator) and proves every item in its Verification section below.
- [ ] Full existing verification corpus `001`–`012` passes unweakened.
- [ ] `bash scripts/invariant-check.sh` — 6/6 PASS.
- [ ] Live behavior confirmed via Playwright: Assembler calm/interrupt, Floor Manager
      calm/triage, actor switching without a second data-load, Current/Workflow-First/
      Command-Center unaffected, no fabricated data visible anywhere.
- [ ] Capability reaches `RELEASE_APPROVED` in `ai/state_registry.json`, substantively
      (every deliverable independently confirmed to exist by the orchestrator, not
      merely by worker exit codes — per the D9C-3 incident's process change).

## Verification Scripts

(none)

Note: this section is deliberately left as `(none)` per the lesson from D9C-1's
`## Verification Scripts`-parser bug (mentioning a not-yet-existing script path here
causes a false "MISSING" failure). `scripts/verification/013-d9c-4-attention-first-actor-views.sh`
is still required, authored directly by the orchestrator after task execution
completes, exactly as done for D9C-3's `012` script.

## Regression Plan

Full existing chain (`001`–`012`) plus `scripts/smoke.sh` plus
`scripts/invariant-check.sh` (6/6) must still pass unweakened. Additionally, the new
`013` script (orchestrator-authored) and independent live Playwright verification of
both actor sub-views, both states each, actor switching, and the other three tabs'
non-regression.

## Capability Phase Boundary

D9C-4 implements Attention-First only. It does not migrate Workflow-First or
Command-Center (D9C-5/D9C-6), does not modify the shared view-model contract, does not
add authentication, and does not select a production UI.

## Next-Phase Handoff

On `RELEASE_APPROVED`, the `AttentionActionForm` pattern (minimal, declutter-first
action affordances built directly on `factoryApi.ts`, bypassing `ActionPanel.tsx`'s
engineering chrome) is available as a reference pattern for D9C-5 (Workflow-First) and
D9C-6 (Command-Center), which may each need their own actor-appropriate action
surfaces — not executed by this capability.

## Out of Scope

See Non-Goals above: no backend/API/data change, no `ActionPanel`/`FactoryFlowBoard`/
hook modification, no Workflow-First/Command-Center implementation, no auth, no
invented data of any kind.
