# Task: Confirm D9C-4's Attention-First implementation is truthful and regresses nothing

## Parent Spec
specs/d9c-4-attention-first-actor-views.md

## Phase
phase-ui

## Status
done

## Layer
verification

## Description

This is a verification-only task. **Do not modify any application source file, and do
not create any file under `scripts/`** — a prior D9C-3 incident
(`ai/incidents/d9c3-verification-script-deliverable-skipped-by-worker.md`) established
that no task-graph worker, under any layer, may write to `scripts/`; the node-specific
verification script for this capability is authored separately, directly by the
orchestrator, after this task completes. Your job is confirming task 001's work is
correct — not authoring `scripts/verification/013-*.sh` yourself.

A prior task built four new components under
`frontend/src/components/variant-review/attention-first/` and wired `variantA` in
`VariantReviewShell.tsx` to render `AttentionFirstView` instead of the placeholder.

Run, in order, from the repository root (a docker compose stack with backend on `:8000`
and frontend on `:5173` is expected to already be running):

1. `bash scripts/invariant-check.sh` — must report 6/6 PASS.
2. Each of `bash scripts/verification/001-docker-compose-config.sh` through
   `bash scripts/verification/012-d9c-3-current-shared-view-model.sh` — every one must
   exit 0 (0 FAIL each; `011`'s browser-launch check may SKIP gracefully as it already
   does on `main`).
3. Read all four new files in full and confirm:
   - `AttentionFirstView.tsx` imports `useFactoryViewModel` and calls it exactly once;
     the `activeActor` switch does not call it again.
   - None of the four files imports any `fetch*` function from `../../../api/factoryApi`;
     only `AttentionActionForm.tsx` imports `postReallocatePart`, `postCalibration`,
     `postCalibrationDisposition`, `postCloudBackup`.
   - No file contains a raw endpoint-path string (e.g. `"POST /factory/units"` displayed
     as UI text) or a free-text, user-editable actor-ID input field.
   - `blocked_reason` is shown only via a mechanical reformat (underscore→space,
     sentence case) — confirm there is no lookup table mapping specific reason codes to
     authored instruction sentences.
   - Attention/blocked derivation in `FloorManagerView.tsx` is exactly
     `blocked_reason != null && !package_ship_status.terminal` — no other condition, no
     severity levels.
   - Assembler's interrupt state only renders `AttentionActionForm` for stage-12
     conditions; stage 5 and cap-exceeded stage 10 show the "needs floor manager
     approval" message instead (no button).
4. Read `VariantReviewShell.tsx` and confirm only the `variantA` branch changed —
   `variantB`/`variantC` branches, the `TABS` array, and all tab labels are identical to
   the pre-task-001 version.
5. `git diff --stat -- frontend/src/components/FactoryFlowBoard.tsx frontend/src/view-model/ frontend/src/api/factoryApi.ts frontend/src/types/factory.ts frontend/src/components/UnitList.tsx frontend/src/components/StageSpine.tsx frontend/src/components/UnitDetailPanel.tsx frontend/src/components/EventTrace.tsx frontend/src/components/ActionPanel.tsx frontend/src/components/variant-review/VariantPlaceholderPane.tsx frontend/src/main.tsx frontend/src/App.tsx frontend/package.json frontend/package-lock.json`
   — must show **no changes** to any of these.
6. Confirm no file under `backend/`, `data/`, `vendor/`, `.engineering-os/` was touched.

If any check fails, report exactly which one and why — do not attempt to fix
implementation code yourself (out of scope for a verification-layer task); a failure
here should leave this task unfinished rather than be marked complete with a known-
failing check.

## Acceptance Criteria
- [ ] `bash scripts/invariant-check.sh` reports 6/6 PASS.
- [ ] All of `scripts/verification/001`–`012` exit 0 (0 FAIL each).
- [ ] All four new files read and confirmed correct per the checks above.
- [ ] `VariantReviewShell.tsx` confirmed to change only the `variantA` branch.
- [ ] Confirmed zero changes to every protected file listed in check 5.
- [ ] Confirmed zero files touched under `backend/`, `data/`, `vendor/`,
      `.engineering-os/`.
- [ ] No application source file, and no `scripts/` file, was created or modified by
      this verification task itself.

## Files Likely Affected
- None (verification-only task; does not create scripts/verification/013-*.sh).

## Blocked By
- tasks/d9c-4-attention-first-actor-views-001.md
