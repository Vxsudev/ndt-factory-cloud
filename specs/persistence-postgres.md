## Feature
persistence-postgres

## Status
approved

## Phase
phase-persistence

## Purpose

Replace the in-memory state store with PostgreSQL persistence. All D4/D5/D6 API
behavior must be preserved exactly. Unit state survives container restart. Alembic
manages schema migrations. A seed loader populates the database from data/*.json on
first boot.

This is a persistence swap. No product behavior changes.

## Non-Goals

- Azure SDKs
- Auth or session management
- Real eStore/inventory/cloud integrations
- Canonical 14-stage model changes
- Factory Flow UI redesign
- Frontend workflow rule changes
- Vendored OS core mutations
- Inventing official AstraX serial-number conventions

## Source Materials

- docs/factory-flow-model.md — 14-stage canonical spine
- docs/domain-glossary.md — factory domain terms
- docs/backend-state-behavior-d5.md — D5 workflow action contracts
- data/*.json — seed data files (8 JSON files)
- backend/app/state_store.py — current in-memory interface to preserve

## Data Model Changes

New: PostgreSQL database factory_cloud, user factory_cloud, password factory_cloud_dev.

Tables (SQLAlchemy ORM models in backend/app/db_models.py):
- stages       — id, number, name, stage_type, ownership, is_gate, is_external, is_separable,
                 hard_stop_controls, authority_notes, normal_next_stage_id
- orders       — id, order_id, model_id, customer_ref, order_date, notes, payload (jsonb)
- factory_units — id (pk), unit_id (str), order_id, model_id, genealogy_serial,
                  current_stage_id, current_stage_number, current_status, blocked_reason,
                  block_type, no_override, payload (jsonb for all nested fields)
- parts        — id, part_id, part_type, serial_number, lot_number, inventory_status,
                 allocated_to_order_id, bound_to_unit_id, released, release_reason_code,
                 source_system
- users        — id, user_id, name, role, can_override, can_qc_signoff,
                 can_waive_separation_of_duty, disposition_authority (jsonb)
- model_recipes — id, model_id, name, description, payload (jsonb)
- reference_standards — id, ref_std_id, name, status, can_be_used_for_calibration,
                        expiry_date, payload (jsonb)
- events       — id, event_id, unit_id, order_id, event_type, stage_id, actor_user_id,
                 timestamp, message, severity, payload (jsonb), source_refs (jsonb)

## API Surface

No new endpoints. All D4/D5 endpoints preserved:

GET  /health
GET  /factory/scaffold-status
GET  /factory/data-contract/status
GET  /factory/stages
GET  /factory/units
GET  /factory/units/{unit_id}
GET  /factory/orders
GET  /factory/parts
GET  /factory/users
GET  /factory/model-recipes
GET  /factory/reference-standards
GET  /factory/events
POST /factory/units/{unit_id}/actions/scan-part
POST /factory/units/{unit_id}/actions/reallocate-part
POST /factory/units/{unit_id}/actions/hardware-gate
POST /factory/units/{unit_id}/actions/calibration
POST /factory/units/{unit_id}/actions/calibration-disposition
POST /factory/units/{unit_id}/actions/qc-signoff
POST /factory/units/{unit_id}/actions/cloud-backup
POST /factory/units/{unit_id}/actions/package
POST /factory/units/{unit_id}/actions/ship
POST /factory/units/{unit_id}/actions/transition
POST /factory/dev/reset-state

## Frontend Surface

No frontend changes required. D6 Factory Flow Board UI unchanged.

## Acceptance Criteria

1. docker compose up --build succeeds with postgres service
2. Backend starts after Postgres is ready (entrypoint.sh wait loop)
3. alembic upgrade head runs automatically on startup
4. Seed data loaded from data/*.json if database is empty
5. GET /factory/units returns 7 seed units from database (not JSON)
6. GET /factory/stages returns 14 canonical stages from database
7. GET /factory/events returns seed events from database
8. POST /factory/dev/reset-state truncates tables and reseeds from JSON
9. POST scan-part, hardware-gate, calibration, qc-signoff, cloud-backup, package, ship
   all work correctly against DB-backed state
10. Terminal state immutability (409) still enforced from DB
11. Hard-stop no_override still returned correctly from DB
12. D4 verification (004) passes
13. D5 verification (005) passes
14. D6 verification (006) passes
15. No Azure SDK present in requirements.txt or any backend file
16. No in-memory state dict in state_store.py

## Verification Script

scripts/verification/007-persistence-postgres.sh

## Boundary

This spec covers only D7 Persistence / Postgres.
No product behavior changes. No frontend changes. No Azure. No auth.
Stop after D7.
