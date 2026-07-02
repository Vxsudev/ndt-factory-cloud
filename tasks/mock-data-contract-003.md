# Task: Create verification script 004-data-contract-api.sh

## Parent Spec
specs/mock-data-contract.md

## Phase
phase-1

## Status
complete

## Layer
verification

## Description
Create `scripts/verification/004-data-contract-api.sh` — a 10-check
verification script that validates the D4 read-only API surface against
a running docker compose stack.

Checks performed:
1. GET /factory/data-contract/status returns 200
2. status field equals "ok"
3. stage_count = 14
4. unit_count >= 7
5. GET /factory/stages returns 200
6. /factory/stages returns array of exactly 14 stages
7. GET /factory/units returns 200
8. GET /factory/units/UNIT-0001 returns 200
9. GET /factory/units/DOES-NOT-EXIST returns 404
10. OpenAPI schema has no POST domain action routes (/advance, /scan,
    /allocate, /calibration, /qc, /backup, /ship)

The script uses BACKEND_URL env var (default http://localhost:8000),
writes temp response bodies to /tmp/.004-*, and exits non-zero on any
FAIL. Uses python3 for JSON parsing (available in CI).

## Acceptance Criteria
- [ ] `scripts/verification/004-data-contract-api.sh` exists and is executable
- [ ] Script exits 0 when all 10 checks pass against a running stack
- [ ] Script exits 1 when any check fails
- [ ] stage_count = 14 is verified from JSON response body
- [ ] unit_count >= 7 verified numerically
- [ ] 404 for missing unit is verified
- [ ] No POST domain route check passes when no such routes exist

## Files Likely Affected
- scripts/verification/004-data-contract-api.sh (created)

## Blocked By
- tasks/mock-data-contract-002.md
