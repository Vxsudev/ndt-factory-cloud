# Task: Confirm D9C-2's shared view model is inert and regresses nothing

## Parent Spec
specs/d9c-2-shared-view-model.md

## Phase
phase-ui

## Status
done

## Layer
verification

## Description

This is a verification-only task. **Do not modify any application source file.** A
prior task created two new, standalone files —
`frontend/src/view-model/types.ts` and `frontend/src/view-model/useFactoryViewModel.ts`
— that nothing in the app imports yet. Your job is to confirm this is exactly true and
that nothing else regressed. No new verification script is created by this task.

Run, in order, from the repository root (a docker compose stack with backend on `:8000`
and frontend on `:5173` is expected to already be running):

1. `bash scripts/invariant-check.sh` — must report 6/6 PASS.
2. Each of `bash scripts/verification/001-docker-compose-config.sh` through
   `bash scripts/verification/011-touch-first-responsive-ui.sh` — every one must exit 0
   (0 FAIL; 011's browser-launch check may SKIP gracefully, as it already does on `main`).
3. `grep -rn "view-model" frontend/src/components/ frontend/src/main.tsx frontend/src/App.tsx`
   — must return no matches, confirming zero consumers import the new hook/types yet.
4. `git diff --stat -- frontend/src/components/FactoryFlowBoard.tsx frontend/src/components/variant-review/ frontend/src/main.tsx frontend/src/App.tsx frontend/src/styles.css frontend/src/api/factoryApi.ts frontend/src/types/factory.ts` (or equivalent) — must show no changes to any of these files.
5. Read `frontend/src/view-model/types.ts` and `frontend/src/view-model/useFactoryViewModel.ts`
   and confirm they match task `tasks/d9c-2-shared-view-model-001.md`'s acceptance
   criteria: correct `FactoryViewModel` shape, faithful mirror of
   `FactoryFlowBoard.tsx`'s current fetch/selection/reset logic (same call order, same
   error handling), no redefinition of existing domain types, no actor-specific derived
   fields, no theme/pane state.
6. Confirm no file under `backend/`, `data/`, `vendor/`, `.engineering-os/`,
   `frontend/package.json`, `frontend/package-lock.json`, `frontend/vite.config.ts`,
   `frontend/index.html`, or `frontend/tsconfig.json` was touched.

If any check fails, report exactly which one and why — do not attempt to fix
implementation code yourself (out of scope for a verification-layer task); a failure
here should leave this task unfinished rather than be marked complete with a known-
failing check.

## Acceptance Criteria
- [ ] `bash scripts/invariant-check.sh` reports 6/6 PASS.
- [ ] All of `scripts/verification/001-011*.sh` exit 0 (0 FAIL each).
- [ ] Confirmed zero existing component/entry-point imports `view-model` yet (grep
      returns no matches).
- [ ] Confirmed zero changes to `FactoryFlowBoard.tsx`, the variant-review components,
      `main.tsx`, `App.tsx`, `styles.css`, `factoryApi.ts`, `types/factory.ts`.
- [ ] `types.ts` / `useFactoryViewModel.ts` confirmed to match task 001's acceptance
      criteria.
- [ ] Confirmed zero files touched under `backend/`, `data/`, `vendor/`,
      `.engineering-os/`, and zero touched among
      `frontend/{package.json,package-lock.json,vite.config.ts,index.html,tsconfig.json}`.
- [ ] No application source file was modified by this verification task itself.

## Files Likely Affected
- None (verification-only task).

## Blocked By
- tasks/d9c-2-shared-view-model-001.md
