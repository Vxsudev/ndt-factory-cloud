# D4 Mock Data Contract

**Status:** complete  
**Directive:** D4  
**Spec:** specs/mock-data-contract.md

## Purpose

D4 makes the NDT factory domain model visible through structured JSON data
files and a read-only HTTP API. This is the first reviewable contract: human
reviewers and future automated tests can inspect what the data looks like
before any behavior is implemented.

D4 does NOT implement factory behavior. There are no state transitions, no
calibration retries, no gate enforcement, and no scan logic. D4 is a
data-shape contract only.

## Source Authority Order

All domain identities, stage sequencing, and stage types were derived from:

1. `Digital_Factory_Requirements.json` — canonical 14-stage production spine
2. `docs/factory-flow-model.md` — domain narrative and constraint description
3. `docs/domain-glossary.md` — authoritative term definitions

No domain knowledge was invented. All field names and stage names derive
directly from these sources.

## Data Files Created

| File | Key Field | Count |
|---|---|---|
| `data/stages.json` | `stages[]` | 14 |
| `data/factory_units.json` | `factory_units[]` | 7+ |
| `data/orders.json` | `orders[]` | 5 |
| `data/parts.json` | `parts[]` | 10+ |
| `data/users.json` | `users[]` | 5 |
| `data/model_recipes.json` | `model_recipes[]` | 3 |
| `data/reference_standards.json` | `reference_standards[]` | 3 |
| `data/events.json` | `events[]` | 10+ |

All files are read-only inside Docker (`./data:/app/data:ro`).

## Canonical 14-Stage Spine

| # | Name | Type | Gate | Hard Block |
|---|---|---|---|---|
| 1 | Order Receipt | external | | |
| 2 | Material Inspection | core | | |
| 3 | Pre-processing | core | | |
| 4 | Setup & Calibration | core | | |
| 5 | Calibration Verification | core | | |
| 6 | Component Allocation | core | | |
| 7 | Cloud Sync Pre-scan | hard_block_dependency | | yes (no_override) |
| 8 | NDT Scan | core | | |
| 9 | Data Review Gate | gate | yes | |
| 10 | QC Sign-off Gate | gate | yes | |
| 11 | Final Inspection Gate | gate | yes | |
| 12 | Cloud Backup | hard_block_dependency | | yes (no_override) |
| 13 | Report Generation | core | | |
| 14 | Shipment / Delivery | terminal | | |

## Placeholder Identifier Policy (INV-7)

All identifiers in data files follow placeholder format:
- Unit IDs: `UNIT-XXXX` (e.g., UNIT-0001)
- Order IDs: `ORDER-XXXX` (e.g., ORDER-0001)
- Part IDs: `PART-TYPE-XXXX` (e.g., PART-PIPE-0001)
- User IDs: `USER-ROLE-XXXX` (e.g., USER-TECH-0001)
- Model names: `MODEL-NAME` format

No `AX-*` identifiers. No production-facing identifiers.

## Entity Relationships

```
Order (ORDER-XXXX)
  └─ contains → Part (PART-TYPE-XXXX)
       └─ assigned to → FactoryUnit (UNIT-XXXX)
            └─ at → Stage (stage_id)
                 └─ operated by → User (USER-ROLE-XXXX)
                      └─ using → ModelRecipe (for scan stages)
                           └─ against → ReferenceStandard
Event
  └─ references → FactoryUnit + Stage (audit trail)
```

## API Endpoints (Read-Only)

All endpoints are GET only. No POST/PUT/PATCH/DELETE routes exist.

| Endpoint | Returns |
|---|---|
| `GET /factory/data-contract/status` | DataContractStatusResponse |
| `GET /factory/stages` | list[StageRecord] |
| `GET /factory/orders` | list[OrderRecord] |
| `GET /factory/units` | list[FactoryUnitRecord] |
| `GET /factory/units/{unit_id}` | FactoryUnitRecord (404 if missing) |
| `GET /factory/parts` | list[PartRecord] |
| `GET /factory/users` | list[UserRecord] |
| `GET /factory/model-recipes` | list[ModelRecipeRecord] |
| `GET /factory/reference-standards` | list[ReferenceStandardRecord] |
| `GET /factory/events` | list[EventRecord] |

## What Is NOT Implemented

- Stage transitions or state advancement
- Calibration retry behavior
- Gate enforcement (pass/fail decisions)
- Assembly scan behavior
- QC sign-off behavior
- Cloud backup hard-block behavior
- Factory Flow Board UI
- Database (Postgres or otherwise)
- Azure SDKs or cloud-specific code
- Authentication or authorization

## D5 Handoff

D5 will introduce in-memory state machines for factory units progressing
through the 14-stage spine. The data files in `data/` become seed data.
The Pydantic models in `backend/app/models.py` extend with state fields.
POST/action routes will be added for stage advancement and gate decisions.
