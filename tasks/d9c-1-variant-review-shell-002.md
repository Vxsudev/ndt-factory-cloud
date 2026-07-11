# Task: Confirm the D9C-1 variant review shell regresses nothing and meets its criteria

## Parent Spec
specs/d9c-1-variant-review-shell.md

## Phase
phase-ui

## Status
done

## Layer
verification

## Description

This is a verification-only task. **Do not modify any application source file.** A
prior task already built a new, additive review shell reachable at `/#/variants`
(`frontend/src/components/variant-review/VariantReviewShell.tsx` and
`VariantPlaceholderPane.tsx`, plus an additive edit to `frontend/src/main.tsx` and
additive-only CSS in `frontend/src/styles.css`). Your job is to confirm it is correct and
that nothing else regressed, using only read-only checks and the existing verification
scripts — no new verification script is created by this task (a dedicated
`012-variant-review-shell.sh` is intentionally reserved for a later, separate node — do
not create it here).

Run, in order, from the repository root (a docker compose stack with backend on
`:8000` and frontend on `:5173` is expected to already be running):

1. `bash scripts/invariant-check.sh` — must report 6/6 PASS.
2. Each of `bash scripts/verification/001-docker-compose-config.sh` through
   `bash scripts/verification/011-touch-first-responsive-ui.sh` (the full existing
   corpus) — every one must exit 0 (0 FAIL; a graceful SKIP inside 011 for the
   browser-launch check is acceptable and expected).
3. `curl -s http://localhost:5173/` — confirm it returns the same static `index.html`
   shell as before (title "Factory Cloud v0", meta marker `factory-flow-board`) —
   confirms `/` is unaffected by this capability.
4. Read `frontend/src/main.tsx` and confirm: the `/` (no-hash) path still renders `<App
   />` with no new wrapper element, and only a `#/variants`-prefixed hash renders the new
   `VariantReviewShell`.
5. Read `frontend/src/components/variant-review/VariantReviewShell.tsx` and
   `VariantPlaceholderPane.tsx` and confirm they match the acceptance criteria of task
   `tasks/d9c-1-variant-review-shell-001.md` (4 primary tabs with the exact specified
   labels, 2 secondary tabs per variant, placeholder-only content, no API imports, no
   changes to `FactoryFlowBoard.tsx` or its children).
6. Confirm via `git diff --stat` (or equivalent) that no file under `backend/`, `data/`,
   `vendor/`, `.engineering-os/`, `frontend/package.json`, `frontend/package-lock.json`,
   `frontend/vite.config.ts`, `frontend/index.html`, or `frontend/tsconfig.json` was
   touched by the prior task.

If any check fails, report exactly which one and why — do not attempt to fix
implementation code yourself (that is out of scope for a verification-layer task); a
failure here should cause this task to remain unfinished rather than be marked complete
with a known-failing check.

## Acceptance Criteria
- [ ] `bash scripts/invariant-check.sh` reports 6/6 PASS.
- [ ] All of `scripts/verification/001-011*.sh` exit 0 (0 FAIL each).
- [ ] `curl http://localhost:5173/` still returns the unchanged static shell (title
      "Factory Cloud v0", meta marker `factory-flow-board` present).
- [ ] `frontend/src/main.tsx` confirmed to render `<App />` unwrapped at `/` (no hash)
      and `<VariantReviewShell />` only under a `#/variants` hash.
- [ ] `VariantReviewShell.tsx` / `VariantPlaceholderPane.tsx` confirmed to match task 001's
      acceptance criteria (4 primary tabs, 2 secondary tabs per variant, placeholder-only,
      no API calls).
- [ ] Confirmed zero files touched under `backend/`, `data/`, `vendor/`,
      `.engineering-os/`, and zero touched among
      `frontend/{package.json,package-lock.json,vite.config.ts,index.html,tsconfig.json}`.
- [ ] No application source file was modified by this verification task itself.

## Files Likely Affected
- None (verification-only task — confirms via `scripts/verification/001-011*.sh` and
  `scripts/invariant-check.sh`; no application source is modified by this task).

## Blocked By
- tasks/d9c-1-variant-review-shell-001.md
