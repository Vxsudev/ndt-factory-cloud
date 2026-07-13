# Task: Confirm D9C-6's Command-Center implementation is truthful, structurally distinct from Current/Attention-First/Workflow-First, and regresses nothing

## Parent Spec
specs/d9c-6-command-center-actor-views.md

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
task-graph worker may write to `scripts/` under any layer. The node-specific
verification script (`015`) and the two narrow predecessor-script fixes (`013`, `014`)
are all orchestrator-owned work, done separately after this task completes.

A prior task built four new components under
`frontend/src/components/variant-review/command-center/` and wired `variantC` in
`VariantReviewShell.tsx` to render `CommandCenterView` instead of the placeholder.

Run, in order, from the repository root (a docker compose stack with backend on `:8000`
and frontend on `:5173` is expected to already be running):

1. `bash scripts/invariant-check.sh` — must report 6/6 PASS.
2. Each of `bash scripts/verification/001` through `014` — every one must exit 0 (0
   FAIL each; `011`'s browser-launch check may SKIP gracefully). Note:
   `013`/`014` currently still contain a stale `variantC`-stays-a-placeholder
   assertion that this capability's approved spec legitimately invalidates — if either
   fails **only** on that specific assertion, report it precisely (do not treat it as
   a regression in the new implementation; this is expected and will be fixed by the
   orchestrator, not you).
3. Read all four new files in full and confirm:
   - `CommandCenterView.tsx` calls `useFactoryViewModel` exactly once; the
     `activeActor` switch does not call it again.
   - None of the four files imports a `fetch*` read function; only
     `CommandCenterActionForm.tsx` imports `postReallocatePart`, `postCalibration`,
     `postCalibrationDisposition`, `postCloudBackup`.
   - None of the four files imports anything from `../attention-first/` or
     `../workflow-first/`.
   - `AssemblerCommandView.tsx` renders all four regions (Attention-when-present,
     Current Unit, Other Units, Supporting Detail) in one simultaneous layout — no
     conditional branch hides the whole Current Unit or Other Units region based on
     blocked state (contrast with `attention-first/AssemblerView.tsx`'s full takeover).
   - The Supporting Detail region defaults to a closed/collapsed state (confirm the
     initial `useState` value is `false`, or the `<details>` element has no `open`
     attribute).
   - `FloorManagerCommandView.tsx`'s Attention/Triage region is rendered directly
     whenever `blockedUnits.length > 0`, with **no** separate `useState` boolean
     gating whether the whole region appears (contrast with
     `workflow-first/FloorManagerWorkflowView.tsx`'s `triageOpen` toggle).
   - Queue and Secondary Context regions in `FloorManagerCommandView.tsx` are always
     rendered, not conditionally hidden behind a tab/pane state.
   - Secondary Context's rendered text states plainly that order/stock/staffing data
     is unavailable — confirm no `fetch` call, no hardcoded numbers.
   - No raw endpoint-path text, no free-text actor-ID input field, no reproduction of
     the full 14-stage spine, anywhere in the four files.
4. Read `VariantReviewShell.tsx` and confirm only the `variantC` branch changed —
   `variantA`/`variantB` branches, the `TABS` array, and all tab labels are identical
   to the pre-task-001 version.
5. `git diff --stat -- frontend/src/components/FactoryFlowBoard.tsx frontend/src/components/ActionPanel.tsx frontend/src/components/variant-review/attention-first/ frontend/src/components/variant-review/workflow-first/ frontend/src/components/variant-review/VariantPlaceholderPane.tsx frontend/src/view-model/ frontend/src/api/factoryApi.ts frontend/src/types/factory.ts frontend/src/components/UnitList.tsx frontend/src/components/StageSpine.tsx frontend/src/components/UnitDetailPanel.tsx frontend/src/components/EventTrace.tsx frontend/src/main.tsx frontend/src/App.tsx frontend/package.json frontend/package-lock.json`
   — must show **no changes** to any of these.
6. Confirm no file under `backend/`, `data/`, `vendor/`, `.engineering-os/`, or
   `scripts/` was touched.

If any check fails (other than the expected, already-flagged `013`/`014` stale
assertion), report exactly which one and why — do not attempt to fix implementation
code yourself; a genuine failure here should leave this task unfinished rather than
be marked complete with a known-failing check.

## Acceptance Criteria
- [ ] `bash scripts/invariant-check.sh` reports 6/6 PASS.
- [ ] All of `scripts/verification/001`–`012` exit 0 (0 FAIL each). `013`/`014`
      confirmed to fail **only** on the already-known, already-flagged stale
      `variantC` assertion, if at all.
- [ ] All four new files read and confirmed correct per the checks above, including
      the three-way structural-distinction checks.
- [ ] Zero imports from `attention-first/` or `workflow-first/` in any new file.
- [ ] Secondary Context section confirmed present, always-visible, and honest.
- [ ] `VariantReviewShell.tsx` confirmed to change only the `variantC` branch.
- [ ] Confirmed zero changes to every protected file listed in check 5.
- [ ] Confirmed zero files touched under `backend/`, `data/`, `vendor/`,
      `.engineering-os/`, `scripts/`.
- [ ] No application source file, and no `scripts/` file, was created or modified by
      this verification task itself.

## Files Likely Affected
- None (verification-only task; does not create or modify any scripts/ file).

## Blocked By
- tasks/d9c-6-command-center-actor-views-001.md
