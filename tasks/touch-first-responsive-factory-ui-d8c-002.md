# Task: Add Playwright browser verification, verification script 011, and complete the D8C release gate

## Parent Spec
specs/touch-first-responsive-factory-ui-d8c.md

## Phase
phase-ui

## Status
done

## Layer
verification

## Description

Verify the full acceptance-criteria list in `specs/touch-first-responsive-factory-ui-d8c.md`
and drive the capability to `RELEASE_APPROVED`. Three ordered sub-steps:

**Sub-step A — Add minimum Playwright tooling.**
No browser-automation dependency exists in this repo today (confirmed by recon: no
`playwright` in `frontend/package.json`, no config, no prior screenshot/visual-
regression artifacts). Add `@playwright/test` as a `frontend`-local devDependency
only, with one `frontend/playwright.config.ts` and one
`frontend/tests/d8c-touch-responsive.spec.ts`. The spec runs against the live
`docker compose` stack (`postgres` + `backend:8000` + `frontend:5173`) across the
required viewport matrix (768×1024, 1024×768, 1180×820, 1280×800, 1440×900,
1920×1080) in both light and dark theme, asserting: no page-level horizontal
overflow; unit selection works (select a blocked unit, e.g. the calibration-cap
scenario); blocked reason and NO OVERRIDE are visible; primary/secondary control
bounding boxes meet the 48/44px contract; theme toggle works and persists across
reload; reset-demo-state works; stage spine (all 14 stages) and event history remain
reachable; keyboard focus is visible; no critical content is hover-gated.

**Sub-step B — Write `scripts/verification/011-touch-first-responsive-ui.sh`.**
Follow the exact convention of `006-factory-flow-board-ui.sh` /
`008-demo-readiness.sh` / `009-light-mode-readability.sh` /
`010-material-theme-readability.sh` (curl + grep + python3 json parsing for
static/marker checks, `set -euo pipefail`, PASS/FAIL counter, exit 1 on any FAIL).
The new script must, in addition to its own static checks (D8C marker present,
`.touch-target-primary`/`.touch-target-secondary` classes present in `styles.css`,
breakpoint usage present in `FactoryFlowBoard.tsx`, no backend files touched, no
Azure SDK, no auth/session code), invoke `npx playwright test` for the live browser
matrix from Sub-step A, and chain-run 001–010 plus `scripts/smoke.sh`, failing loudly
(not silently passing) if any link in the chain fails. Capture screenshots under
`artifacts/d8c-touch-verification/` for at minimum: compact light, compact dark,
standard light, standard dark, large workstation light, blocked-unit compact view,
action-panel compact view.

**Sub-step C — Regression, docs, indexes, journal, state, release gate.**
Run the full existing verification chain (001–010) and confirm it passes unweakened.
Run `bash scripts/invariant-check.sh` (must be 6/6). Run `bash scripts/smoke.sh`.
Create `docs/touch-first-responsive-ui-d8c.md` per the spec's required content.
Update `README.md`, `ai/repo-index.md`, `ai/architecture-index.md` to reflect D8C.
Append a new entry to `ai/engineering-journal.md` (append-only, end of file).
Update `ai/state_registry.json` for `touch-first-responsive-factory-ui-d8c` via
`vendor/engineering-os/scripts/execution-supervisor.sh` (or `state-manager.sh advance`
through `EXECUTION_ACTIVE` → `VERIFICATION_REQUIRED` → `RELEASE_APPROVED`, gated on
011 and the full chain passing).

## Acceptance Criteria
- [ ] `frontend/package.json` gains exactly one new devDependency (`@playwright/test`) — no other new packages.
- [ ] `frontend/tests/d8c-touch-responsive.spec.ts` covers the full viewport × theme matrix and every check listed in the spec's Browser Verification Plan.
- [ ] `scripts/verification/011-touch-first-responsive-ui.sh` exists, is executable, follows the existing script convention, and exits 0.
- [ ] Screenshots exist under `artifacts/d8c-touch-verification/` for all required states.
- [ ] `bash scripts/verification/001-docker-compose-config.sh` through `010-material-theme-readability.sh` all exit 0 (unweakened).
- [ ] `bash scripts/invariant-check.sh` exits 0 (6/6).
- [ ] `bash scripts/smoke.sh` exits 0.
- [ ] `docs/touch-first-responsive-ui-d8c.md` created with all directive-required sections.
- [ ] `README.md`, `ai/repo-index.md`, `ai/architecture-index.md` updated to mention D8C.
- [ ] `ai/engineering-journal.md` has a new appended entry titled "D8C — Touch-First Responsive Factory UI".
- [ ] `ai/state_registry.json` shows `touch-first-responsive-factory-ui-d8c: RELEASE_APPROVED`.
- [ ] `vendor/engineering-os/` core doctrine unmodified (diff-verified).

## Files Likely Affected
- frontend/package.json
- frontend/playwright.config.ts (new)
- frontend/tests/d8c-touch-responsive.spec.ts (new)
- scripts/verification/011-touch-first-responsive-ui.sh (new)
- artifacts/d8c-touch-verification/ (new, screenshots)
- docs/touch-first-responsive-ui-d8c.md (new)
- README.md
- ai/repo-index.md
- ai/architecture-index.md
- ai/engineering-journal.md
- ai/state_registry.json

## Blocked By
- tasks/touch-first-responsive-factory-ui-d8c-001.md
