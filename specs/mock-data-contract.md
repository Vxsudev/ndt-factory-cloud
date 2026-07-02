# Spec: Mock Data Contract + Read-Only API

## Status
approved

## Phase
phase-1

## Purpose

Create the first reviewable mock data contract for Factory Cloud. D4 makes the domain
model visible through structured data files and read-only backend API endpoints.

D4 is not behavior execution. No transitions, no gate enforcement, no mutations.

## Scope

- 8 structured JSON data files under data/ representing the canonical domain model
- Pydantic read models for all entities
- Read-only API endpoints exposing all data files
- Minimal frontend panel showing data contract status
- Verification script confirming all endpoints
- Documentation of the mock contract and placeholder ID policy

## Non-Goals (D4)

- Stage advancement or transition logic
- Assembly scan mutation
- Calibration retry mutation or execution
- QC sign-off mutation
- Cloud backup mutation
- Supervisor reallocation mutation
- Persistence / database (Postgres)
- Auth / RBAC enforcement
- Factory Flow Board UI
- Unit timeline detail view
- POST/PUT/PATCH/DELETE domain action routes

## Source Materials

Authority order:
1. source-materials/digital-factory-requirements-v1/Digital_Factory_Requirements.json
2. source-materials/digital-factory-requirements-v1/Digital_Factory_Requirements.md
3. source-materials/digital-factory-requirements-v1/Digital_Factory_Workflow.html
4. source-materials/digital-factory-requirements-v1/Digital_Factory_Flowchart.html

## Data Files

| File | Description |
|------|-------------|
| data/stages.json | All 14 canonical production stages |
| data/orders.json | 3 mock orders (2 valid, 1 rejected) |
| data/factory_units.json | 7 mock units covering critical states |
| data/parts.json | Serial-worthy subassembly parts in various states |
| data/users.json | Factory roles and authority tiers |
| data/model_recipes.json | XRF-BASIC and XRF-PRO model recipes |
| data/reference_standards.json | Calibration reference standards (valid, expired, missing cert) |
| data/events.json | Immutable audit event history |

Placeholder ID policy: UNIT-XXXX, ORDER-XXXX, PART-TYPE-XXXX, USER-ROLE-XXXX, MODEL-NAME.
No AX-* identifiers. All identifiers are mock placeholders; not production serial policy.

## API Surface

Read-only endpoints (all GET, no POST/PUT/PATCH/DELETE):

| Endpoint | Description |
|----------|-------------|
| GET /factory/stages | All 14 canonical stages |
| GET /factory/orders | All mock orders |
| GET /factory/units | All mock factory units |
| GET /factory/units/{unit_id} | Single unit by ID (404 if not found) |
| GET /factory/parts | All mock parts |
| GET /factory/users | All mock users |
| GET /factory/model-recipes | All model recipes |
| GET /factory/reference-standards | All reference standards |
| GET /factory/events | All audit events |
| GET /factory/data-contract/status | Data contract health and counts |

Data contract status response shape:
```json
{
  "status": "ok",
  "phase": "D4_MOCK_DATA_CONTRACT",
  "read_only": true,
  "domain_logic_enabled": false,
  "data_files_loaded": [...],
  "unit_count": 7,
  "stage_count": 14
}
```

## Frontend Surface

Minimal update to existing scaffold UI:
- Add DataContractStatus component fetching /factory/data-contract/status
- Display: D4 phase, stage count, unit count, read_only, domain logic disabled
- Do not build Factory Flow Board, unit timeline, or action panels

## Operational Workflow

1. docker compose up --build
2. Backend loads data/*.json from DATA_DIR env var (/app/data in container)
3. All /factory/* endpoints return data from JSON files
4. Frontend displays data contract status panel alongside D3 health panel

## Dependencies

- D3 Stack Scaffold (complete)
- data/*.json files present at repo root

## Acceptance Criteria

- [ ] All 8 data/*.json files exist
- [ ] stages.json has exactly 14 stages
- [ ] Stages 9, 10, 11 are gates (is_gate: true)
- [ ] Stages 7 and 12 have cloud hard-block, no override
- [ ] Stage 14 is terminal
- [ ] factory_units.json has at least 7 units covering all required states
- [ ] No AX-* identifiers in any data file
- [ ] GET /factory/stages returns 14 stages
- [ ] GET /factory/units returns all units
- [ ] GET /factory/units/UNIT-0001 returns one unit
- [ ] GET /factory/units/DOES-NOT-EXIST returns 404
- [ ] GET /factory/data-contract/status returns status ok, stage_count 14, unit_count >= 7
- [ ] No POST domain action routes exist in OpenAPI for D4
- [ ] Frontend loads and displays D4 data contract status panel
- [ ] No Postgres added
- [ ] No Azure SDK added
- [ ] No auth added
- [ ] docker compose up --build succeeds
- [ ] bash scripts/smoke.sh passes

## Verification Scripts

- scripts/verification/004-data-contract-api.sh

## Boundary Condition

D4 ends when: all read-only endpoints return data, frontend displays contract status,
verification script passes, smoke passes.

## D5 Handoff

D5 Backend State Behavior will add:
- POST /factory/units (provision unit from order)
- POST /factory/units/{unit_id}/advance (stage advancement)
- POST /factory/units/{unit_id}/hard-stop (raise hard stop)
- In-memory state store (orders dict, units dict)
- Stage machine enforcement (hard-stops, gate logic)
- Calibration attempt recording
- QC sign-off recording
- Transition events
