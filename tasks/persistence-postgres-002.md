# Task: Replace in-memory state store with DB-backed implementation

## Parent Spec
specs/persistence-postgres.md

## Phase
phase-persistence

## Status
complete

## Layer
backend

## Description
Implement seed.py (load data/*.json into DB), update state_store.py to use SQLAlchemy
Session instead of in-memory dict (preserve same public interface), create repositories.py
(CRUD helpers), update settings.py to add DATABASE_URL, update data_contract.py to read
from DB via state_store, update routes/actions.py to pass db session, create entrypoint.sh
(wait-for-postgres → alembic upgrade head → seed if empty → uvicorn), and update
backend/Dockerfile to use entrypoint.sh.

All D4/D5/D6 API behavior is preserved exactly. No business logic changes.

## Acceptance Criteria
- [ ] backend/app/seed.py loads all data/*.json files into DB tables
- [ ] backend/app/repositories.py provides get_unit, update_unit, list_units, etc.
- [ ] backend/app/state_store.py preserves load_state/get_state/reset_state/get_unit/update_unit/next_event_id/append_event interface — DB-backed
- [ ] backend/app/settings.py has DATABASE_URL field
- [ ] backend/app/routes/data_contract.py reads from DB (not data_loader)
- [ ] backend/app/routes/actions.py injects db session to state_store calls
- [ ] backend/entrypoint.sh: wait-for-postgres, alembic upgrade head, seed if empty, uvicorn
- [ ] backend/Dockerfile ENTRYPOINT updated to use entrypoint.sh
- [ ] POST /factory/dev/reset-state truncates tables and reseeds from JSON

## Files Likely Affected
- backend/app/seed.py (CREATE)
- backend/app/repositories.py (CREATE)
- backend/app/state_store.py (REPLACE internals)
- backend/app/settings.py (UPDATE)
- backend/app/routes/data_contract.py (UPDATE)
- backend/app/routes/actions.py (UPDATE)
- backend/app/main.py (UPDATE — add db lifespan/startup)
- backend/entrypoint.sh (CREATE)
- backend/Dockerfile (UPDATE)

## Blocked By
- tasks/persistence-postgres-001.md
