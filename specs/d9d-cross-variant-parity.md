# Spec: Cross-Variant Parity (D9D)

## Status
approved

## Phase
phase-ui

## Feature
d9d-cross-variant-parity

## Capability

Audit and reconcile Current, Attention-First, Workflow-First, and Command-Center
against one canonical factory truth so the three actor-first variants differ only in
their intentionally designed presentation/interaction philosophies, not through
accidental data, API, state, action, refresh, error-handling, or authority drift.
Preserve every intentional structural difference (Attention-First's takeover,
Workflow-First's stable layout + expandable triage, Command-Center's simultaneous
regions, Current's engineering-console baseline).

## Source Authority

- `ai/recon/d9d-cross-variant-parity.md` — full recon, complete 23-dimension parity
  matrix. No `Conflict: STOP`. Found exactly two `DEFECTIVE_DRIFT` items, both narrow,
  both within the "mismatched action eligibility"/"mismatched mutation payload"
  allowed-correction categories, neither requiring a backend/API/data-model change,
  actor-authority change, or a choice between design philosophies.
- `ai/recon/d9b-three-functional-actor-first-ui-variants.md` §6/§7 — confirms
  Workflow-First's and Command-Center's own documented design intent already requires
  an always-visible primary action, independent of blocked state; the drift is a gap
  between documented intent and actual implementation, not a new design decision.
- `ai/incidents/d9c5-execution-supervisor-stdin-truncated-verification-loop.md` —
  governs mandatory manual, non-supervisor-loop full verification.

## Current Problem

1. `AssemblerWorkflowView.tsx` and `AssemblerCommandView.tsx` never render their
   `*ActionForm` outside the blocked-state block, so the backend-supported stage-10
   calibration-submission action (available for a non-blocked, mid-calibration unit
   like the canonical UNIT-0003) is reachable in Attention-First's Assembler view but
   silently absent from the other two — a genuine action-eligibility parity gap, and
   a deviation from each variant's own D9B-documented design ("one primary action,"
   always visible).
2. None of the three `*ActionForm.tsx` files validates that the Stage-5 "Replacement
   Serial Number" field is non-empty before allowing submission — a uniform gap
   against the directive's own explicit requirement.

## Non-Goals / Out of Scope

- No backend, API, database, seed-data, or workflow-rule change.
- No change to `FactoryFlowBoard.tsx`, `ActionPanel.tsx`, the shared view-model,
  `factoryApi.ts`, `types/factory.ts` — all confirmed at full parity already.
- No change to `attention-first/AssemblerView.tsx` or
  `attention-first/FloorManagerView.tsx` for drift #1 — Attention-First's calm-state
  action visibility is already correct and serves as the reference implementation;
  only its `AttentionActionForm.tsx` needs the drift #2 (new-serial validation) fix,
  identically to the other two variants' forms.
- No change to any variant's intentional structural difference (takeover, stable
  layout + triage toggle, simultaneous regions, engineering-console baseline).
- No visual polish, no touch-target tuning, no selector-label change, no new
  dependency, no unrelated cleanup.
- No shared abstraction extracted across the three `*ActionForm.tsx`/`Assembler*View.tsx`
  files — both corrections are applied independently, in place, per recon §15.

## Data Model Changes
none

## API Surface
none

## Frontend Surface

Modified:

- `frontend/src/components/variant-review/workflow-first/AssemblerWorkflowView.tsx` —
  add `{!isBlocked && <WorkflowActionForm unit={focused} parts={vm.parts}
  refStandards={vm.refStandards} onDone={() => void vm.refreshSelected()} />}` inside
  the always-rendered "Current Unit" region, as a sibling immediately after the
  existing `{isBlocked && (...)}` block. No other change to this file.
- `frontend/src/components/variant-review/command-center/AssemblerCommandView.tsx` —
  add the identical `{!isBlocked && <CommandCenterActionForm .../>}` call inside the
  always-rendered "Current Unit" region (the separate sibling `<div>` that currently
  only shows unit id/stage name). No other change to this file.
- `frontend/src/components/variant-review/{attention-first,workflow-first,command-center}/
  {AttentionActionForm,WorkflowActionForm,CommandCenterActionForm}.tsx` — each gains a
  non-empty check on `newSerial` before the "Submit Reallocation" button is enabled:
  `disabled={loading || newSerial.trim().length === 0}`. No other change to any of
  these three files.

New:

- `scripts/verification/016-d9d-cross-variant-parity.sh` — authored directly by the
  orchestrator.

Unmodified (byte-for-byte, protected):

- `frontend/src/components/{FactoryFlowBoard,ActionPanel,UnitList,StageSpine,
  UnitDetailPanel,EventTrace}.tsx`, `frontend/src/view-model/**`, `frontend/src/api/**`,
  `frontend/src/types/**`, `frontend/src/main.tsx`, `frontend/src/App.tsx`,
  `frontend/src/styles.css`, all frontend config/lockfiles, everything under
  `backend/`, `data/`, `vendor/`, `.engineering-os/`, `source-materials/`,
  `attention-first/{AssemblerView.tsx,FloorManagerView.tsx}`,
  `workflow-first/FloorManagerWorkflowView.tsx`,
  `command-center/FloorManagerCommandView.tsx`, `VariantReviewShell.tsx`.

## Architecture Contract

- `useFactoryViewModel()` remains the sole canonical-data boundary; no new mutation
  path, no new data fetch.
- Equivalent backend-supported actions use equivalent eligibility, authority,
  serialized traceability, payload semantics, refresh behavior, and error handling
  across all three actor-first variants — the two corrections above close the only
  two gaps recon found against this invariant.
- Every intentional structural difference remains fully intact; neither correction
  touches layout, takeover behavior, triage-toggle behavior, or simultaneous-region
  behavior — both are `{condition && (...)}` additions/guards, not restructuring.

## Operational Workflow

1. Orchestrator applies both narrow corrections to the four named files.
2. Orchestrator rebuilds and recreates the frontend Docker image, confirms via
   `curl` that the rebuilt bundle contains the corrected logic before any browser
   verification.
3. Demo state reset to canonical.
4. Equivalent action scenarios executed across variants (per the directive's
   Equivalent Action Scenarios section), confirming parity and shared backend truth.
5. Demo state reset to canonical; residue confirmed absent.

## Dependencies

- `ai/product-invariants.md` Invariant 2/3 — unaffected/reinforced; no new mutation
  path, only a visibility/validation correction on already-existing, already-correct
  action calls.
- `specs/d9c-4/5/6-*.md` — this node does not weaken any of their acceptance criteria;
  their structural distinctions remain fully intact.

## Acceptance Criteria

- [ ] `AssemblerWorkflowView.tsx`'s always-rendered "Current Unit" region additionally
      renders `WorkflowActionForm` when `!isBlocked` (mirroring the already-correct
      Attention-First pattern); the existing `{isBlocked && (...)}` block is otherwise
      unchanged.
- [ ] `AssemblerCommandView.tsx`'s "Current Unit" region additionally renders
      `CommandCenterActionForm` when `!isBlocked`; the existing Attention region block
      is otherwise unchanged.
- [ ] All three `*ActionForm.tsx` files disable "Submit Reallocation" when
      `newSerial.trim().length === 0`, in addition to the existing `loading` check.
- [ ] No `isBlocked ?` ternary is introduced anywhere (both additions use a separate
      `{!isBlocked && (...)}` block, preserving the existing structural-distinction
      assertions in scripts 013/014/015).
- [ ] `attention-first/{AssemblerView,FloorManagerView}.tsx`,
      `workflow-first/FloorManagerWorkflowView.tsx`,
      `command-center/FloorManagerCommandView.tsx`, `VariantReviewShell.tsx`, and all
      protected files remain byte-for-byte unchanged.
- [ ] Zero files under `backend/`, `data/`, `vendor/`, `.engineering-os/` touched.
- [ ] `scripts/verification/016-d9d-cross-variant-parity.sh` exists
      (orchestrator-authored) and proves every parity dimension in the recon matrix,
      plus both corrections, plus the continued absence of a card-swap ternary.
- [ ] Full existing verification corpus `001`–`016` passes, run manually outside the
      supervisor loop, with every filename and exit code individually recorded.
- [ ] `bash scripts/invariant-check.sh` — 6/6 PASS.
- [ ] Frontend image rebuilt and recreated; served source positively confirmed to
      contain the corrected logic before any browser verification.
- [ ] Live browser verification confirms: UNIT-0003's calibration-submission action
      now appears in all three variants' Assembler calm state; an empty
      new-serial submission is blocked in all three; equivalent action scenarios
      (cloud-backup retry, calibration-cap disposition) executed through different
      variants each reflect identically in Current and the other two variants after
      switching; unsupported-attention feedback (UNIT-0002) still shows the truthful
      message in all three; all intentional structural differences remain intact.
- [ ] Demo state reset to canonical after all verification; zero mutation residue
      confirmed.
- [ ] Capability reaches `RELEASE_APPROVED` in `ai/state_registry.json`,
      substantively confirmed by the orchestrator.

## Verification Scripts

(none)

## Regression Plan

Full existing chain `001`–`016` run manually (not solely via
`execution-supervisor.sh`, confirmed defective past script `007`), plus
`scripts/smoke.sh`, plus `scripts/invariant-check.sh` (6/6), plus
`vendor/engineering-os/scripts/raystrat-os verify`, plus independent live Playwright
verification against a freshly rebuilt frontend image.

## Capability Phase Boundary

D9D corrects exactly the two recon-proven defective-drift items. It does not perform
visual polish (D9E), touch optimization (D9F), final factory acceptance (D9G), or any
production selection.

## Next-Phase Handoff

On `RELEASE_APPROVED`, D9E (visual polish) is the next serialized node — not executed
by this capability.

## Out of Scope

See Non-Goals above: no backend/API/data change, no structural-difference change, no
visual/touch work, no shared abstraction, no unrelated cleanup.
