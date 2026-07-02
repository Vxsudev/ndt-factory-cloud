# D7 Persistence / Postgres — Documentation

**Phase:** D7
**Status:** COMPLETE
**Date:** 2026-06-30

---

## Purpose

Replace the in-memory D5 state store with PostgreSQL persistence. All D4/D5/D6 API
behavior is preserved exactly. Unit state survives container restart. Alembic manages
schema migrations. A seed loader populates the database from data/*.json on first boot.

Core rule: persist state without changing product behavior.

---

## Architecture Change

Before D7: state was held in a module-level dict loaded from JSON at startup. State was
lost on every container restart.

After D7:
- PostgreSQL service (postgres:16) stores all factory state
- Alembic manages schema via migrations
- Backend waits for Postgres, runs `alembic upgrade head`, seeds if empty, then starts
- All D4/D5 routes read and write from DB
- workflow_rules.py is unchanged — it still mutates a state dict in-place; routes call
  `persist_action()` to flush changes to DB after each workflow action

---

## New Files

| File | Purpose |
|------|---------|
| `backend/app/db.py` | SQLAlchemy engine, SessionLocal, get_db dependency |
| `backend/app/db_models.py` | ORM models for 8 tables |
| `backend/app/seed.py` | Loads data/*.json into DB tables |
| `backend/app/repositories.py` | DB query helpers (count, list, get) |
| `backend/alembic.ini` | Alembic configuration |
| `backend/alembic/env.py` | Alembic env (reads DATABASE_URL from env) |
| `backend/alembic/versions/001_initial_factory_cloud_schema.py` | Initial schema migration |
| `backend/entrypoint.sh` | Startup: wait-postgres → alembic → seed → uvicorn |

---

## Changed Files

| File | Change |
|------|--------|
| `backend/app/state_store.py` | DB-backed (same public interface) |
| `backend/app/routes/actions.py` | Injects DB session; calls persist_action() |
| `backend/app/routes/data_contract.py` | Mutable endpoints (units, parts, events) read from DB |
| `backend/app/main.py` | Lifespan handler seeds DB on startup |
| `backend/Dockerfile` | Installs postgresql-client; uses entrypoint.sh |
| `backend/requirements.txt` | Added sqlalchemy, alembic, psycopg[binary] |
| `docker-compose.yml` | Added postgres service, DATABASE_URL, postgres_data volume |

---

## Database Schema

8 tables managed by Alembic migration `001`:

| Table | Key columns | Notes |
|-------|-------------|-------|
| `stages` | stage_id, number, name, stage_type | Static; seeded from stages.json |
| `orders` | order_id, model_id, payload(jsonb) | Static; seeded from orders.json |
| `factory_units` | unit_id, current_stage_id, current_status, no_override, payload(jsonb) | Mutable; full unit state |
| `parts` | part_id, part_type, serial_number, inventory_status | Mutable; part binding state |
| `users` | user_id, role, can_override, can_qc_signoff, disposition_authority(jsonb) | Static |
| `model_recipes` | model_id, name, description, payload(jsonb) | Static |
| `reference_standards` | ref_std_id, name, status, can_be_used_for_calibration | Static |
| `events` | event_id, unit_id, event_type, timestamp, message, severity, payload(jsonb) | Append-only |

`factory_units.payload` stores all nested fields: part_allocations, genealogy,
gate_results, calibration_summary, qc_summary, cloud_status, package_ship_status, event_ids.

---

## State Store Interface (preserved from D5)

```python
get_state(db: Session) -> dict[str, Any]    # was: get_state() — now takes DB session
reset_state(db: Session) -> None             # was: reset_state() — truncates + reseeds
get_unit(db: Session, unit_id: str) -> dict | None
update_unit(db: Session, unit_id: str, patch: dict) -> dict
next_event_id(state: dict) -> str           # UNCHANGED — uses in-state counter
append_event(state: dict, event: dict) -> None  # UNCHANGED — mutates in-state list
persist_action(db, state, unit_id, events_baseline)  # NEW — flushes mutations to DB
```

`workflow_rules.py` is unchanged. Routes call `persist_action()` after each workflow.

---

## Startup Sequence

`backend/entrypoint.sh`:
1. Wait for `pg_isready` on `$DB_HOST:$DB_PORT`
2. Run `alembic upgrade head` (creates tables on first boot, no-op on subsequent boots)
3. Start uvicorn (`app.main:app`)

`app.main` lifespan:
4. On startup: if factory_units table is empty, call `seed(db)` to populate from data/*.json

---

## Persistence Model for Actions

For each D5 workflow action route:
1. `state = state_store.get_state(db)` — load full state from DB as dict
2. `baseline = len(state["events"])` — record event count before action
3. `result = workflow_rules.<action>(state, unit_id, req)` — mutates state dict in-place
4. `state_store.persist_action(db, state, unit_id, baseline)` — flush unit + parts + new events to DB

If workflow_rules raises HTTPException (terminal state 409, auth 403, etc.): no
mutations happened, so persist_action is not called.

---

## What Is Not Changed

- workflow_rules.py — all domain rules unchanged
- models.py — all Pydantic models unchanged
- All 11 D5 action endpoints — same URLs, same request/response shapes
- All 10 D4 data contract endpoints — same URLs, same response shapes
- D6 Factory Flow Board UI — unchanged
- 14-stage production spine — unchanged
- Hard-stop and no_override enforcement — unchanged
- Terminal state immutability — unchanged

---

## Connection Details (local Docker Compose)

| Parameter | Value |
|-----------|-------|
| Image | postgres:16 |
| Database | factory_cloud |
| User | factory_cloud |
| Password | factory_cloud_dev |
| Port | 5432 (internal only) |
| Volume | postgres_data (named volume) |
| DATABASE_URL | `postgresql+psycopg://factory_cloud:factory_cloud_dev@postgres:5432/factory_cloud` |

---

## Verification

```bash
docker compose up --build -d
bash scripts/verification/007-persistence-postgres.sh
```

15 checks: Postgres running, health OK, alembic ran, 7 units seeded, 14 stages seeded,
GET /factory/units from DB, GET /factory/events from DB, reset-state reseeds, D5 action
event persists, terminal 409, D4 passes, D5 passes, no Azure SDK, no _state dict, smoke.

---

## What Is Intentionally Not Implemented (D7)

- Real-time push updates (WebSocket / SSE)
- Full unit history viewer
- Order management UI
- Azure SDK wiring
- Auth or session management
