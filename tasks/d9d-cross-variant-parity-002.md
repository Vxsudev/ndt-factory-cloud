# Task: Confirm D9D's two parity corrections are applied correctly and regress nothing

## Parent Spec
specs/d9d-cross-variant-parity.md

## Phase
phase-ui

## Status
done

## Layer
verification

## Description

This is a verification-only task. **Do not modify any application source file, and do
not create or modify any file under `scripts/`** — per
`ai/incidents/d9c3-verification-script-deliverable-skipped-by-worker.md`, no
task-graph worker may write to `scripts/`. The D9D verification script is
orchestrator-owned, authored separately after this task completes.

A prior task made exactly five file changes: added `{!isBlocked && <XxxActionForm/>}`
to `AssemblerWorkflowView.tsx`'s and `AssemblerCommandView.tsx`'s Current Unit
regions, and added a `newSerial`-non-empty guard to the Stage-5 submit button in all
three `*ActionForm.tsx` files.

Run, in order, from the repository root (a docker compose stack with backend on `:8000`
and frontend on `:5173` is expected to already be running):

1. `bash scripts/invariant-check.sh` — must report 6/6 PASS.
2. Each of `bash scripts/verification/001` through `015` — every one must exit 0 (0
   FAIL each; `011`'s browser-launch check may SKIP gracefully).
3. Read all five changed files in full and confirm:
   - `AssemblerWorkflowView.tsx`: a new `{!isBlocked && (...)}` block (not a ternary)
     renders `WorkflowActionForm` with `unit={focused}`, `parts={vm.parts}`,
     `refStandards={vm.refStandards}`, `onDone={() => void vm.refreshSelected()}`; the
     existing `{isBlocked && (...)}` block's contents are byte-identical to before.
   - `AssemblerCommandView.tsx`: same pattern, `CommandCenterActionForm`, inside the
     "Current Unit" div; the existing Attention block is byte-identical to before.
   - Neither file contains an `isBlocked ?` ternary.
   - All three `*ActionForm.tsx` files: the "Submit Reallocation" button (and only
     that button — not the calibration, disposition, or cloud-backup-retry buttons)
     is disabled when `newSerial.trim().length === 0`, in addition to the existing
     `loading` check.
4. `git diff --stat -- frontend/src/components/variant-review/attention-first/AssemblerView.tsx frontend/src/components/variant-review/attention-first/FloorManagerView.tsx frontend/src/components/variant-review/workflow-first/FloorManagerWorkflowView.tsx frontend/src/components/variant-review/command-center/FloorManagerCommandView.tsx frontend/src/components/variant-review/VariantReviewShell.tsx frontend/src/components/FactoryFlowBoard.tsx frontend/src/components/ActionPanel.tsx frontend/src/view-model/ frontend/src/api/ frontend/src/types/ frontend/src/styles.css`
   — must show **no changes** to any of these.
5. Confirm no file under `backend/`, `data/`, `vendor/`, `.engineering-os/`, or
   `scripts/` was touched.

If any check fails, report exactly which one and why — do not attempt to fix
implementation code yourself; a failure here should leave this task unfinished rather
than be marked complete with a known-failing check.

## Acceptance Criteria
- [ ] `bash scripts/invariant-check.sh` reports 6/6 PASS.
- [ ] All of `scripts/verification/001`–`015` exit 0 (0 FAIL each).
- [ ] Both corrections confirmed present and correctly scoped in all five files, with
      no `isBlocked ?` ternary introduced anywhere.
- [ ] Confirmed zero changes to every protected/unrelated file listed in check 4.
- [ ] Confirmed zero files touched under `backend/`, `data/`, `vendor/`,
      `.engineering-os/`, `scripts/`.
- [ ] No application source file, and no `scripts/` file, was created or modified by
      this verification task itself.

## Files Likely Affected
- None (verification-only task; does not create or modify any scripts/ file).

## Blocked By
- tasks/d9d-cross-variant-parity-001.md
