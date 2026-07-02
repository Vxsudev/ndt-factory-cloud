# Task: Verification, docs, and index update for D6

## Parent Spec
specs/factory-flow-board-ui.md

## Phase
phase-ui

## Status
pending

## Layer
verification

## Description
Create verification script, documentation, and update indexes for D6.

1. `scripts/verification/006-factory-flow-board-ui.sh` — 12 checks:
   V1. Frontend root loads (HTTP 200)
   V2. index.html contains "factory-flow-board" meta marker
   V3. index.html contains "D6" or "Factory Flow Board" text
   V4. Backend data-contract status still works (D4 backward compat)
   V5. D5 action endpoint still responds (POST reset-state)
   V6. No Postgres in requirements.txt
   V7. No Azure SDK in requirements.txt
   V8. TypeScript types file exists and is non-empty
   V9. factoryApi.ts exists and is non-empty
   V10. FactoryFlowBoard.tsx exists
   V11. D5 verification script passes (call 005-backend-state-behavior.sh)
   V12. Smoke passes

2. `docs/factory-flow-board-ui-d6.md` — D6 documentation

3. Update README.md — phase D6, factory flow board section
4. Update ai/repo-index.md — D6 complete in phase table, directory map updated
5. Update ai/architecture-index.md — D6 complete note
6. Append Entry 009 to ai/engineering-journal.md

## Acceptance Criteria
- [ ] scripts/verification/006-factory-flow-board-ui.sh created and executable
- [ ] Running verification script against live stack: all checks pass
- [ ] docs/factory-flow-board-ui-d6.md created
- [ ] README, repo-index, architecture-index, engineering-journal updated

## Files Likely Affected
- scripts/verification/006-factory-flow-board-ui.sh (CREATE)
- docs/factory-flow-board-ui-d6.md (CREATE)
- README.md (UPDATE)
- ai/repo-index.md (UPDATE)
- ai/architecture-index.md (UPDATE)
- ai/engineering-journal.md (APPEND)

## Blocked By
- tasks/factory-flow-board-ui-003.md
