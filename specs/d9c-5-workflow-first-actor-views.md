# Spec: Workflow-First Actor Views (D9C-5)

## Status
approved

## Phase
phase-ui

## Feature
d9c-5-workflow-first-actor-views

## Capability

Replace the `variantB` placeholder inside the existing `/#/variants` review shell with
a functional Workflow-First experience for two actor-scoped views — Assembler and Floor
Manager — powered exclusively by the existing `useFactoryViewModel()` hook, and
structurally/behaviorally distinct from the completed Attention-First (D9C-4)
implementation. Comparative design implementation only; does not select Workflow-First
as the production UI; does not touch Current, Attention-First, or Command-Center.

## Source Authority

- `ai/recon/d9c-5-workflow-first-actor-views.md` — full recon. No `Conflict: STOP` was
  triggered. Key finding: a real `/factory/orders` backend endpoint exists but is
  outside this node's approved integration surface (the shared view model is
  protected; no parallel fetch is permitted) — handled via an honest "not available"
  secondary-info tab, not fabrication or silent omission of the required tab
  affordance.
- `ai/recon/d9b-three-functional-actor-first-ui-variants.md` §6 — Workflow-First design
  authority: one stable current-unit layout for the Assembler (actor-controlled focus
  switching, never an interrupt takeover), a persistent queue for the Floor Manager
  (attention as a non-blocking, deliberately-expandable badge, not an always-shown
  triage block).
- `ai/recon/d9c-4-attention-first-actor-views.md` and the four files under
  `frontend/src/components/variant-review/attention-first/` — read for structural
  contrast; **not reused, not imported, not modified**. This node's own component tree
  is independent.

## Current Problem

`VariantPlaceholderPane` still renders inert placeholder copy for `variantB`. There is
no way to compare a calmer, actor-controlled-focus design against Attention-First's
interrupt-driven one.

## Non-Goals / Out of Scope

- No backend, API, database, schema, or seed-data change.
- No change to Current, Attention-First (`frontend/src/components/variant-review/
  attention-first/**`), or Command-Center (`variantC` stays a placeholder).
- No modification of `useFactoryViewModel.ts`/`types.ts`/`factoryApi.ts`/
  `ActionPanel.tsx`/`FactoryFlowBoard.tsx` — all protected, read-only reference.
- No wiring of the real `/factory/orders` endpoint — it is outside this node's
  approved surface (see Source Authority). The secondary-info tab states plainly that
  order/stock/staffing data is not available in this view.
- No invented current-user identity, personal unit assignment, failure-instruction
  text, or live telemetry — identical constraints to D9C-4, for identical reasons
  (recon §8/§10/§13).
- No multi-tier attention severity — single boolean signal, same rule as D9C-4.
- No silent reuse of `attention-first/`'s components or a new shared abstraction
  extracted from them during this node — a small, independently-implemented
  `WorkflowActionForm.tsx` duplicates only the thin stage-to-action mapping.
- No new npm dependency; no `frontend/package.json`/`package-lock.json` change.
- No renaming of `VariantReviewShell`'s tab-bar labels (settled D9C-1 chrome, out of
  scope — recon §19).

## Data Model Changes
none

## API Surface
none

## Frontend Surface

New directory `frontend/src/components/variant-review/workflow-first/`:

- `WorkflowFirstView.tsx` — root. Calls `useFactoryViewModel()` exactly once. Holds
  `activeActor: 'assembler' | 'floorManager'` state (same secondary-tab visual pattern
  established in D9C-1/D9C-4). Renders `AssemblerWorkflowView`/`FloorManagerWorkflowView`,
  passing the same `vm` to both — never re-invoked on actor switch.
- `AssemblerWorkflowView.tsx` — **one stable card layout** for the focused unit
  (`vm.selectedUnit`, defaulting via `vm.selectUnit` to the first non-terminal unit in
  `vm.units` if nothing is focused yet). Blocked/attention information (if
  `blocked_reason != null`) renders as an **inline section within this same card** —
  there is no separate "interrupt" component and no full-screen replacement. A
  persistent bottom strip lists the other non-terminal units (truthful labels: "Other
  Units," never "assigned to me"); tapping one calls `vm.selectUnit` to deliberately
  change focus — focus never changes automatically based on blocked state.
  `WorkflowActionForm` renders inline within the card when a mapped action exists for
  the focused unit's stage/condition.
- `FloorManagerWorkflowView.tsx` — the queue (`vm.units`, sorted by
  `current_stage_number`) is the **persistent, always-rendered primary surface**. A
  small attention-count badge
  (`vm.units.filter(u => u.blocked_reason && !u.package_ship_status.terminal).length`)
  sits above it; clicking the badge **toggles** an in-place triage list open/closed
  (collapsed by default) — the triage list is not always rendered the way D9C-4's is.
  A secondary-info tab sits alongside the queue; opening it shows an explicit "order/
  stock/staffing information is not available in this view" message — real UI
  affordance, honest content.
- `WorkflowActionForm.tsx` — independently implemented (not imported from
  `attention-first/`), same stage-to-action mapping as D9C-4's `AttentionActionForm`
  (stage 5 reallocate-part / stage 10 calibration or calibration-disposition / stage 12
  cloud-backup retry), calling the same unmodified `factoryApi.ts` functions with the
  same request shapes and fixed demo-actor-id constants. No raw endpoint text, no
  free-text actor-ID field.

Modified:

- `frontend/src/components/variant-review/VariantReviewShell.tsx` — the `variantB` tab
  renders `<WorkflowFirstView/>` instead of `<VariantPlaceholderPane variantId=
  "variantB" .../>`. `variantA`/`variantC` tabs and all tab-bar labels unchanged.
- `frontend/src/styles.css` — additive only, if a bounded new class is genuinely needed
  beyond existing tokens.

New:

- `scripts/verification/014-d9c-5-workflow-first-actor-views.sh` — authored directly by
  the orchestrator (see `ai/incidents/d9c3-verification-script-deliverable-skipped-by-worker.md`
  — never delegated to a task-graph worker).

Unmodified (byte-for-byte identical, protected):

- `frontend/src/components/{FactoryFlowBoard,ActionPanel,UnitList,StageSpine,
  UnitDetailPanel,EventTrace}.tsx`, `frontend/src/components/variant-review/
  attention-first/**` (all four D9C-4 files), `frontend/src/view-model/{types.ts,
  useFactoryViewModel.ts}`, `frontend/src/api/factoryApi.ts`, `frontend/src/types/
  factory.ts`, `frontend/src/main.tsx`, `frontend/src/App.tsx`, all frontend config/
  lockfiles, everything under `backend/`, `data/`, `vendor/`, `.engineering-os/`.

## Architecture Contract

- `useFactoryViewModel()` remains the sole factory-data orchestration source; no
  parallel initial-data fetch is introduced (no `/factory/orders` call, no duplicated
  8-call sequence).
- Structural distinction from Attention-First is an acceptance requirement, not a
  cosmetic one: no full-screen takeover/component-swap tied to `blocked_reason` in the
  Assembler view; attention in the Floor Manager view is a deliberately-toggled,
  collapsible in-place list, not an always-rendered block.
- Every displayed fact is deterministically derived from `vm.units`' existing fields,
  or explicitly labeled unavailable — no fabrication (recon §8/§13).
- `WorkflowActionForm`'s action calls are the one write-side exception to
  read-via-view-model, exactly mirroring D9C-4's already-established, directive-
  sanctioned pattern.
- Current, Attention-First, Command-Center, backend, workflow rules, and the canonical
  14-stage model are unaffected.

## Operational Workflow

1. Operator opens `/#/variants` → "Variant B — Workflow-First" tab.
2. `WorkflowFirstView` mounts, calls `useFactoryViewModel()` once; data loads exactly
   as Current/Attention-First already do.
3. Assembler sub-view shows the one stable card for the first non-terminal unit; if
   blocked, the same card shows an inline blocked section (no swap).
4. Assembler taps another unit in the strip → focus changes deliberately.
5. Floor Manager sub-view shows the queue; taps the attention badge → triage list
   expands in place; taps again (or resolves the last item) → collapses back.
6. Submitting an action (where available) calls the same backend endpoint
   `ActionPanel`/`AttentionActionForm` would call for that stage/condition, refreshed
   via the view model exactly as Current already does.
7. Workflow-First's secondary-info tab, when opened, states plainly that order/stock/
   staffing data isn't available in this view.
8. Attention-First, Command-Center, and Current remain untouched throughout.

## Dependencies

- `ai/product-invariants.md` Invariant 2/3 — unaffected/reinforced, identical reasoning
  to D9C-4.
- `ai/runtime-contracts.md` Contracts 2/3 — unaffected; same unmodified `factoryApi.ts`.
- `specs/d9c-4-attention-first-actor-views.md` — this node must remain structurally
  distinct from it; does not modify or weaken any of its acceptance criteria.
- `ai/incidents/d9c3-verification-script-deliverable-skipped-by-worker.md` — governs
  orchestrator-only authorship of the new verification script.
- Docker rebuild procedure (recon §16) and backend test-pacing procedure (recon §17) —
  required before/during live verification.

## Acceptance Criteria

- [ ] `frontend/src/components/variant-review/workflow-first/{WorkflowFirstView,
      AssemblerWorkflowView,FloorManagerWorkflowView,WorkflowActionForm}.tsx` exist.
- [ ] `WorkflowFirstView` calls `useFactoryViewModel` exactly once; actor switching
      does not re-invoke it; no other new file calls it.
- [ ] None of the four new files imports a `fetch*` read function from `factoryApi`;
      only `WorkflowActionForm.tsx` imports the four action-submission functions.
- [ ] `AssemblerWorkflowView` never swaps to a visually distinct "interrupt" component
      when the focused unit is blocked — blocked info renders inline in the same card
      structure that renders when the unit is not blocked.
- [ ] Focus in `AssemblerWorkflowView` changes only via explicit `vm.selectUnit` calls
      triggered by an actor tapping another unit — never automatically because a unit
      becomes blocked.
- [ ] `FloorManagerWorkflowView`'s triage list is collapsed by default and only shown
      when the actor deliberately expands the attention badge; the queue remains
      rendered underneath at all times.
- [ ] A secondary-info tab exists in `FloorManagerWorkflowView` and, when opened,
      states that order/stock/staffing data is not available in this view — no
      fabricated numbers.
- [ ] `VariantReviewShell.tsx`'s `variantB` tab renders `<WorkflowFirstView/>`;
      `variantA`/`variantC` tabs and all tab-bar labels unchanged.
- [ ] No raw endpoint text, no free-text actor-ID field, in any new file.
- [ ] `frontend/src/components/variant-review/attention-first/**`,
      `FactoryFlowBoard.tsx`, `ActionPanel.tsx`, `useFactoryViewModel.ts`, `types.ts`,
      `factoryApi.ts`, `UnitList.tsx`, `StageSpine.tsx`, `UnitDetailPanel.tsx`,
      `EventTrace.tsx`, `main.tsx`, `App.tsx` are byte-for-byte unchanged.
- [ ] Zero files under `backend/`, `data/`, `vendor/`, `.engineering-os/` touched.
- [ ] The app builds/type-checks in strict mode; no new `any`; no new TypeScript/lint
      error beyond the documented pre-existing baseline (recon §18).
- [ ] `scripts/verification/014-d9c-5-workflow-first-actor-views.sh` exists (authored
      by the orchestrator) and proves every item in Verification below.
- [ ] Full existing verification corpus `001`–`013` passes unweakened.
- [ ] `bash scripts/invariant-check.sh` — 6/6 PASS.
- [ ] Live behavior confirmed via Playwright **after rebuilding the frontend image and
      positively confirming the served bundle contains `WorkflowFirstView`**: Assembler
      focus-switch, an inline blocked state with an available action executed against
      the live backend, Floor Manager queue + badge expand/collapse, one triage
      resolution, the secondary-info tab's honest content, Current/Attention-First/
      Command-Center unaffected, demo state reset to canonical afterward.
- [ ] Capability reaches `RELEASE_APPROVED` in `ai/state_registry.json`, substantively
      confirmed by the orchestrator (not worker exit codes alone).

## Verification Scripts

(none)

## Regression Plan

Full existing chain (`001`–`013`) plus `scripts/smoke.sh` plus
`scripts/invariant-check.sh` (6/6) unweakened. Additionally: the new `014` script, and
independent live Playwright verification against a freshly rebuilt frontend image (per
the D9C-4 incident's process change), with the backend test-pacing procedure (recon
§17) applied to avoid recurring lock contention.

## Capability Phase Boundary

D9C-5 implements Workflow-First only. Does not modify Attention-First, does not
implement Command-Center (D9C-6), does not modify the shared view-model contract, does
not add authentication or wire the `/factory/orders` endpoint.

## Next-Phase Handoff

On `RELEASE_APPROVED`, D9C-6 (Command-Center) becomes the next available node — not
executed by this capability. `WorkflowActionForm`'s independent-implementation pattern
(duplicating only the thin stage-mapping, not a shared abstraction) is available as
precedent for D9C-6's own action surface, should one be needed.

## Out of Scope

See Non-Goals above: no hook/contract change, no Attention-First/Current/Command-Center
change, no backend/API/data change, no orders-endpoint wiring, no new dependency.
