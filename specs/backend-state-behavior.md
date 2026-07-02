## Capability
Backend State Behavior

## Status
approved

## Phase
phase-backend

## Author
D5 Directive

## Description
Convert the D4 read-only mock data contract into a controlled in-memory workflow engine.
The backend owns all state decisions. Every workflow action appends an immutable event.
No Postgres. No Azure SDKs. No auth. No Factory Flow Board UI.

## Boundary Condition
D5 ends after verification scripts pass. Do not continue to D6.

## Purpose
D5 makes the factory domain model operational as a reviewable in-memory prototype.
Operators can submit scan actions, supervisors can disposition exceptions, QC can sign off,
and cloud backup confirms the record before package/ship. All behavior runs in-memory
and can be reset from seed JSON. No production infrastructure is added.

## Scope

- In-memory mutable state store loaded from D4 JSON seeds
- Backend action endpoints (10 unit actions + 1 dev reset)
- Legal transition guards (stage sequence, hard-stop enforcement)
- Event append on every action
- Assembly scan validation (Stage 5)
- Supervisor reallocation (Stage 4/5)
- Hardware gate result recording (Stage 9)
- Calibration pass/fail with 3-attempt cap (Stage 10)
- QC sign-off with prerequisite and separation-of-duty check (Stage 11)
- Cloud backup confirm/hard-block (Stage 12)
- Package and ship (Stages 13–14)
- Reset-state dev endpoint
- Verification script 005

## Non-Goals

- Postgres, database migrations, persistent storage
- Azure SDKs, cloud integrations, real device connectivity
- Auth/session management, production RBAC
- Factory Flow Board UI, frontend unit timeline
- Complex simulator or device protocol
- Real eStore/inventory/cloud integrations

## Source Materials

- docs/factory-flow-model.md (stage definitions, gate rules, authority levels)
- docs/domain-glossary.md (canonical domain terms)
- ai/product-invariants.md (INV-1 through INV-7)
- data/factory_units.json (7 seed units)
- data/users.json (6 users, 4 authority tiers)
- data/parts.json (6 parts)
- data/reference_standards.json (3 standards: 1 valid, 1 expired, 1 missing cert)

## Backend Behavior

### State Store (backend/app/state_store.py)

In-memory dict keyed by unit_id, loaded from data/*.json on startup.
Provides: load_state(), get_state(), reset_state(), get_unit(), update_unit(), append_event().
All mutations are in-memory. data/*.json is never written.

### Workflow Rules (backend/app/workflow_rules.py)

All domain logic as pure-ish functions. Routes call workflow_rules; rules are not
scattered in route handlers.

Functions: scan_part, reallocate_part, record_hardware_gate, record_calibration,
record_calibration_disposition, qc_signoff, record_cloud_backup, transition_stage,
package_unit, ship_unit.

### Action API (backend/app/routes/actions.py)

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

## HTTP Status Conventions

- 200 + ActionResponse.status=blocked: business hard-stop raised
- 200 + ActionResponse.status=success: action succeeded
- 404: unit not found
- 409: illegal state transition (terminal unit, stage sequence violation)
- 422: invalid request shape
- 403: insufficient authority (for authority-only failures)

## Event Append Model

Every action appends one event: id (EVENT-D5-XXXX), unit_id, order_id, event_type,
stage_id, actor_user_id, timestamp, message, severity, payload, source_refs.
Event counter is in-memory; event IDs do not collide with seed EVT-* IDs.

## Mock Authority Rules

From users.json. No auth/login. Actor provided in request body.
- operator: assembly scan, package
- supervisor: reallocation, calibration disposition (rework/quarantine), can_override=true
- manager: scrap, waive separation-of-duty, can_waive_separation_of_duty=true
- USER-QC-0001: can_qc_signoff=true (QC sign-off only)
- USER-MGR-0001: can_qc_signoff=false but can authorize ship (Stage 14)

## Acceptance Criteria

- [ ] state_store.py exists with all required functions
- [ ] workflow_rules.py exists with all domain logic centralized
- [ ] actions.py exists with all 11 endpoints
- [ ] All D4 GET endpoints still return correct data
- [ ] assembly scan hard-stops: wrong type, wrong serial, unknown serial, already bound
- [ ] supervisor reallocation logs old/new serial with reason
- [ ] hardware gate pass/fail recorded in gate_results
- [ ] calibration 3-attempt cap enforced; 3rd fail raises supervisor disposition
- [ ] expired/missing-cert reference standard raises no-override hard-stop
- [ ] QC prerequisites checked (hw gate, calibration cert, genealogy)
- [ ] QC separation-of-duty enforced (with manager waiver path)
- [ ] cloud backup unavailable: no_override hard-stop raised
- [ ] every action appends event with EVENT-D5-XXXX id
- [ ] missing unit returns 404
- [ ] terminal unit transition returns 409
- [ ] reset-state reloads seed JSON
- [ ] frontend D5 status panel visible in browser
- [ ] no Postgres in requirements.txt
- [ ] no Azure SDK in requirements.txt
- [ ] verification script 005 passes all checks

## API Surface

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

Minimal D5 status panel added to AppShell.
Component: frontend/src/components/D5BackendStatus.tsx
Displays: action API available, domain logic enabled, current limitation.

## Data Model Changes

D5 adds Pydantic request/response models to models.py. No database schema change.
In-memory state store adds mutable dict state over D4 JSON seeds.

## Verification Scripts

- scripts/verification/005-backend-state-behavior.sh (15 checks)

## Boundary

Phase: phase-backend

D5 must not add Postgres, Azure SDKs, auth, or Factory Flow Board UI.
D6 will add the Factory Flow Board frontend reading from D5 endpoints.
