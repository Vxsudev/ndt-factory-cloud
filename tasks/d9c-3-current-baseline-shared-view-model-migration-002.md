# Task: Confirm D9C-3's FactoryFlowBoard migration is behaviorally faithful and regresses nothing

## Parent Spec
specs/d9c-3-current-baseline-shared-view-model-migration.md

## Phase
phase-ui

## Status
done

## Layer
verification

## Description

This is a verification-only task. **Do not modify any application source file.** A
prior task migrated `frontend/src/components/FactoryFlowBoard.tsx` to consume
`frontend/src/view-model/useFactoryViewModel()` instead of its own local factory-data
state/orchestration, and created
`scripts/verification/012-d9c-3-current-shared-view-model.sh`. Your job is to confirm
this was done correctly and that nothing else regressed.

Run, in order, from the repository root (a docker compose stack with backend on `:8000`
and frontend on `:5173` is expected to already be running):

1. `bash scripts/invariant-check.sh` — must report 6/6 PASS.
2. Each of `bash scripts/verification/001-docker-compose-config.sh` through
   `bash scripts/verification/011-touch-first-responsive-ui.sh` — every one must exit 0
   (0 FAIL; 011's browser-launch check may SKIP gracefully, as it already does on
   `main`).
3. `bash scripts/verification/012-d9c-3-current-shared-view-model.sh` — must exit 0.
4. Read `frontend/src/components/FactoryFlowBoard.tsx` in full and confirm:
   - It imports `useFactoryViewModel` from `../view-model/useFactoryViewModel` and
     invokes it exactly once.
   - It contains zero imports from `../api/factoryApi`.
   - The 12 factory-data `useState`s (`health, contractStatus, stages, units, events,
     users, parts, refStandards, selectedUnitId, selectedUnit, loadError, resetting`)
     and the `loadAll`/`refreshSelected`/`selectUnit`/`handleReset` callbacks and the
     mount-time load effect are gone — replaced by reads from the hook's return value.
   - `theme`, `toggleTheme`, the theme `useEffect`, and `compactPane`/its setter are
     still present, unchanged.
   - Every child component (`UnitList`, `StageSpine`, `UnitDetailPanel`, `ActionPanel`,
     `EventTrace`) still receives the same prop names/types it did before, now sourced
     from the hook.
   - All D8/D8A/D8B/D8C `data-*` semantic markers, header content, nav/compact-pane
     switcher, and grid regions are structurally unchanged from before the migration.
5. `git diff --stat -- frontend/src/view-model/ frontend/src/components/variant-review/ frontend/src/main.tsx frontend/src/App.tsx frontend/src/styles.css frontend/src/api/factoryApi.ts frontend/src/types/factory.ts frontend/package.json frontend/package-lock.json frontend/vite.config.ts frontend/index.html frontend/tsconfig.json frontend/tailwind.config.js`
   — must show **no changes** to any of these (only `FactoryFlowBoard.tsx` and the new
   `012-*.sh` script should differ from the pre-task-001 state).
6. Confirm no file under `backend/`, `data/`, `vendor/`, `.engineering-os/` was touched.

If any check fails, report exactly which one and why — do not attempt to fix
implementation code yourself (out of scope for a verification-layer task); a failure
here should leave this task unfinished rather than be marked complete with a known-
failing check.

## Acceptance Criteria
- [ ] `bash scripts/invariant-check.sh` reports 6/6 PASS.
- [ ] All of `scripts/verification/001-011*.sh` exit 0 (0 FAIL each).
- [ ] `scripts/verification/012-d9c-3-current-shared-view-model.sh` exits 0.
- [ ] `FactoryFlowBoard.tsx` confirmed to consume the hook exactly once, with zero
      direct `factoryApi` imports and all 12 data fields/4 operations sourced from the
      hook.
- [ ] `theme`/`compactPane` presentation state confirmed still local and unchanged.
- [ ] Confirmed zero changes to `view-model/`, `variant-review/`, `main.tsx`,
      `App.tsx`, `styles.css`, `factoryApi.ts`, `types/factory.ts`, and all
      frontend config/lockfiles.
- [ ] Confirmed zero files touched under `backend/`, `data/`, `vendor/`,
      `.engineering-os/`.
- [ ] No application source file was modified by this verification task itself.

## Files Likely Affected
- None (verification-only task).

## Blocked By
- tasks/d9c-3-current-baseline-shared-view-model-migration-001.md
