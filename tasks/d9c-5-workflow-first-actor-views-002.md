# Task: Confirm D9C-5's Workflow-First implementation is truthful, structurally distinct from Attention-First, and regresses nothing

## Parent Spec
specs/d9c-5-workflow-first-actor-views.md

## Phase
phase-ui

## Status
done

## Layer
verification

## Description

This is a verification-only task. **Do not modify any application source file, and do
not create any file under `scripts/`** — per
`ai/incidents/d9c3-verification-script-deliverable-skipped-by-worker.md`, no
task-graph worker may write to `scripts/` under any layer; the node-specific
verification script is authored separately, directly by the orchestrator, after this
task completes.

A prior task built four new components under
`frontend/src/components/variant-review/workflow-first/` and wired `variantB` in
`VariantReviewShell.tsx` to render `WorkflowFirstView` instead of the placeholder.

Run, in order, from the repository root (a docker compose stack with backend on `:8000`
and frontend on `:5173` is expected to already be running):

1. `bash scripts/invariant-check.sh` — must report 6/6 PASS.
2. Each of `bash scripts/verification/001` through `013` — every one must exit 0 (0
   FAIL each; `011`'s browser-launch check may SKIP gracefully).
3. Read all four new files in full and confirm:
   - `WorkflowFirstView.tsx` calls `useFactoryViewModel` exactly once; the
     `activeActor` switch does not call it again.
   - None of the four files imports a `fetch*` read function; only
     `WorkflowActionForm.tsx` imports `postReallocatePart`, `postCalibration`,
     `postCalibrationDisposition`, `postCloudBackup`.
   - None of the four files imports anything from
     `../attention-first/` — this node's component tree must be fully independent of
     D9C-4's.
   - `AssemblerWorkflowView.tsx` renders **one persistent card structure**: confirm
     there is no conditional branch that swaps in an entirely different
     component/JSX subtree keyed on `blocked_reason` — blocked info must appear as an
     additional section within the same card markup, not a takeover/replacement.
   - Focus changes in `AssemblerWorkflowView.tsx` only originate from an explicit
     `vm.selectUnit` call tied to a user tap (e.g. an `onClick` on a unit-strip item) —
     not from any effect keyed on `blocked_reason`.
   - `FloorManagerWorkflowView.tsx`'s triage list state defaults to collapsed
     (`useState(false)` or equivalent) and is only shown when that state is toggled by
     an explicit user action — not always rendered whenever `blockedUnits.length > 0`.
   - A secondary-info section exists whose rendered text states plainly that order/
     stock/staffing data is unavailable — confirm no `fetch` call, no hardcoded
     order/stock numbers.
   - No raw endpoint-path text, no free-text actor-ID input field, anywhere in the four
     files.
4. Read `VariantReviewShell.tsx` and confirm only the `variantB` branch changed —
   `variantA`/`variantC` branches, the `TABS` array, and all tab labels are identical to
   the pre-task-001 version.
5. `git diff --stat -- frontend/src/components/FactoryFlowBoard.tsx frontend/src/components/ActionPanel.tsx frontend/src/components/variant-review/attention-first/ frontend/src/components/variant-review/VariantPlaceholderPane.tsx frontend/src/view-model/ frontend/src/api/factoryApi.ts frontend/src/types/factory.ts frontend/src/components/UnitList.tsx frontend/src/components/StageSpine.tsx frontend/src/components/UnitDetailPanel.tsx frontend/src/components/EventTrace.tsx frontend/src/main.tsx frontend/src/App.tsx frontend/package.json frontend/package-lock.json`
   — must show **no changes** to any of these.
6. Confirm no file under `backend/`, `data/`, `vendor/`, `.engineering-os/` was touched.

If any check fails, report exactly which one and why — do not attempt to fix
implementation code yourself; a failure here should leave this task unfinished rather
than be marked complete with a known-failing check.

## Acceptance Criteria
- [ ] `bash scripts/invariant-check.sh` reports 6/6 PASS.
- [ ] All of `scripts/verification/001`–`013` exit 0 (0 FAIL each).
- [ ] All four new files read and confirmed correct per the checks above, including
      the structural-distinction checks (no card-swap takeover, actor-driven-only
      focus change, collapsed-by-default triage).
- [ ] Zero imports from `attention-first/` in any new file.
- [ ] Secondary-info section confirmed present and honest (no fabricated data).
- [ ] `VariantReviewShell.tsx` confirmed to change only the `variantB` branch.
- [ ] Confirmed zero changes to every protected file listed in check 5.
- [ ] Confirmed zero files touched under `backend/`, `data/`, `vendor/`,
      `.engineering-os/`.
- [ ] No application source file, and no `scripts/` file, was created or modified by
      this verification task itself.

## Files Likely Affected
- None (verification-only task; does not create scripts/verification/014-*.sh).

## Blocked By
- tasks/d9c-5-workflow-first-actor-views-001.md
