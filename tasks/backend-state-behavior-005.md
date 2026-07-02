# Task: Create verification script 005 and update docs/journal/index

## Parent Spec
specs/backend-state-behavior.md

## Phase
phase-backend

## Status
complete

## Layer
verification

## Description
Create scripts/verification/005-backend-state-behavior.sh — 15 checks.

Run against a live stack (requires docker compose up).

Checks:
1. reset state works (POST /factory/dev/reset-state returns 200)
2. /factory/data-contract/status still returns 200 (D4 backward compat)
3. successful assembly scan on UNIT-0001 with POWER_SUPPLY/PS-SN-MOCK-0002
4. wrong assembly serial returns blocked (status=blocked in response)
5. supervisor reallocation succeeds (USER-SUP-0001 reallocates UNIT-0001 POWER_SUPPLY)
6. cloud backup unavailable on UNIT-0006 returns blocked with no_override=true
7. calibration 3rd fail on UNIT-0003 records attempt or returns cap state
8. calibration on UNIT-0004 (cap exceeded) returns disposition required
9. QC sign-off on UNIT-0005 succeeds with USER-QC-0001
10. missing unit action returns 404
11. terminal unit transition (UNIT-0007) returns 409
12. no Postgres in requirements.txt
13. no Azure SDK in requirements.txt
14. frontend still reachable (http://localhost:5173)
15. smoke.sh passes

Also create docs/backend-state-behavior-d5.md.
Update README.md, ai/repo-index.md, ai/architecture-index.md.
Append Entry 008 (D5) to ai/engineering-journal.md.

## Acceptance Criteria
- [ ] 005 verification script exists and is executable
- [ ] All 15 checks pass against running stack
- [ ] docs/backend-state-behavior-d5.md created
- [ ] README reflects D5 phase
- [ ] ai/repo-index.md phase table shows D5 COMPLETE
- [ ] ai/engineering-journal.md has Entry 008

## Files Likely Affected
- scripts/verification/005-backend-state-behavior.sh (created)
- docs/backend-state-behavior-d5.md (created)
- README.md (updated)
- ai/repo-index.md (updated)
- ai/architecture-index.md (updated)
- ai/engineering-journal.md (appended)

## Blocked By
- tasks/backend-state-behavior-004.md
