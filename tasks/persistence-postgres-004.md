# Task: Write verification script 007 and D7 documentation

## Parent Spec
specs/persistence-postgres.md

## Phase
phase-persistence

## Status
complete

## Layer
verification

## Description
Create scripts/verification/007-persistence-postgres.sh (15 checks confirming Postgres
service up, migrations ran, seed data in DB, all D4/D5 APIs return from DB, reset-state
works, no Azure SDK present). Create docs/persistence-postgres-d7.md. Update README,
ai/repo-index.md, ai/architecture-index.md, ai/engineering-journal.md for D7 complete.

## Acceptance Criteria
- [ ] scripts/verification/007-persistence-postgres.sh exists and passes (15 checks)
- [ ] docs/persistence-postgres-d7.md documents D7 design and behavior
- [ ] README updated for D7 (stack table, verification list)
- [ ] ai/repo-index.md updated — D7 complete, directory map updated
- [ ] ai/architecture-index.md updated — phase D7, Postgres in architecture
- [ ] ai/engineering-journal.md has Entry 010 for D7 completion

## Files Likely Affected
- scripts/verification/007-persistence-postgres.sh (CREATE)
- docs/persistence-postgres-d7.md (CREATE)
- README.md (UPDATE)
- ai/repo-index.md (UPDATE)
- ai/architecture-index.md (UPDATE)
- ai/engineering-journal.md (UPDATE)

## Blocked By
- tasks/persistence-postgres-003.md
