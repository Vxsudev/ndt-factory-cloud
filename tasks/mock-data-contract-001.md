# Task: Data Files + Backend Read-Only API

## Parent Spec
specs/mock-data-contract.md

## Phase
phase-1

## Status
complete

## Layer
backend

## Description
Create 8 data/*.json files, backend/app/data_loader.py, update backend/app/models.py
with D4 Pydantic models, create backend/app/routes/data_contract.py with all read-only
endpoints, update backend/app/main.py to include new router.

Data files: data/stages.json (14 stages), data/orders.json (3 orders),
data/factory_units.json (7 units), data/parts.json, data/users.json,
data/model_recipes.json, data/reference_standards.json, data/events.json.

Backend routes (all GET, read-only):
GET /factory/stages, GET /factory/orders, GET /factory/units, GET /factory/units/{unit_id},
GET /factory/parts, GET /factory/users, GET /factory/model-recipes,
GET /factory/reference-standards, GET /factory/events, GET /factory/data-contract/status

## Acceptance Criteria
- [ ] All 8 data/*.json files exist
- [ ] stages.json has exactly 14 stages
- [ ] Stages 9, 10, 11 have is_gate: true
- [ ] Stages 7 and 12 have stage_type: "hard_block_dependency"
- [ ] Stage 14 has stage_type: "terminal"
- [ ] factory_units.json has exactly 7 units
- [ ] No AX-* identifiers in any data file
- [ ] GET /factory/stages returns list of 14 stages
- [ ] GET /factory/units returns list of 7 units
- [ ] GET /factory/units/UNIT-0001 returns one unit
- [ ] GET /factory/units/DOES-NOT-EXIST returns 404
- [ ] GET /factory/data-contract/status returns status ok, stage_count 14, unit_count 7
- [ ] No POST routes introduced in D4

## Files Likely Affected
- data/stages.json
- data/orders.json
- data/factory_units.json
- data/parts.json
- data/users.json
- data/model_recipes.json
- data/reference_standards.json
- data/events.json
- backend/app/data_loader.py
- backend/app/models.py
- backend/app/routes/data_contract.py
- backend/app/main.py
- docker-compose.yml

## Blocked By
- none
