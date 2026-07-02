# Coding Patterns — ndt-factory-cloud

## Status

D0-D2: No application code written yet. This document declares the intended
coding patterns for D3 Stack Scaffold and D4+ Feature Implementation.

Agents must reference this document when generating specs and implementing features.
Agents must not invent new patterns. If a feature requires a pattern that is not
defined here, the agent must stop and propose a pattern amendment.

---

## Backend Patterns (FastAPI + Pydantic)

### Router Organization

```
backend/app/routers/
├── orders.py        — order intake and management
├── units.py         — factory unit CRUD and stage queries
├── stages.py        — stage advancement, hard-stop management
├── calibration.py   — calibration attempt recording and certificate management
├── qc.py            — QC inspection and sign-off
├── genealogy.py     — genealogy lock and read
└── cloud.py         — cloud provision and backup (mocked in v0)
```

Each router file owns one resource domain. Cross-resource operations route
through the most authoritative domain (e.g., stage advance is in `stages.py`
even if it touches the unit record).

### Pydantic Models

```python
# Request models: verb + resource + "Request"
class AdvanceStageRequest(BaseModel): ...
class RecordCalibrationAttemptRequest(BaseModel): ...

# Response models: resource + "Response"
class UnitResponse(BaseModel): ...
class StageStatusResponse(BaseModel): ...

# Domain models: resource name only
class FactoryUnit(BaseModel): ...
class ProductionOrder(BaseModel): ...
class CalibrationAttempt(BaseModel): ...
```

### Stage Machine Pattern

Stage advance logic lives in `backend/app/domain/stage_machine.py`.
It is called from `stages.py` router; it is not duplicated in other routers.

```python
def advance_stage(unit_id: str, target_stage: str, actor: Actor) -> StageTransition:
    # 1. Load unit
    # 2. Check current stage is the predecessor
    # 3. Check no active hard-stop
    # 4. Check actor has required authority
    # 5. Record transition
    # 6. Return new state
```

### HTTP Status Conventions

| Scenario                            | Status Code |
|-------------------------------------|-------------|
| Successful advance                  | 200         |
| Unit not found                      | 404         |
| Hard-stop active (advance blocked)  | 409         |
| Insufficient authority              | 403         |
| Invalid stage transition order      | 422         |
| Terminal unit (immutable)           | 409         |

---

## Frontend Patterns (React + Vite + TypeScript)

### Component Organization

```
frontend/src/components/
├── production/
│   ├── UnitCard.tsx         — single factory unit status display
│   ├── StageProgress.tsx    — 14-stage progress indicator
│   ├── HardStopBanner.tsx   — hard-stop alert display
│   └── CalibrationPanel.tsx — calibration attempt UI
├── forms/
│   ├── OrderForm.tsx        — order intake form
│   └── ScanForm.tsx         — part scan input form
├── gates/
│   ├── CalibrationGate.tsx  — calibration gate status and disposition
│   └── QCSignoffGate.tsx    — QC sign-off form and status
└── ui/                      — shadcn/ui primitives (generated; do not edit)
```

### API Client Pattern

```
frontend/src/api/
├── client.ts        — base fetch wrapper with error handling
├── orders.ts        — order API calls
├── units.ts         — unit API calls
└── stages.ts        — stage advance API calls
```

All API calls use the base client. No raw `fetch` calls in component files.

### TypeScript Conventions

- Strict mode enabled (`"strict": true` in tsconfig).
- All API response types match Pydantic response model shapes.
- No `any` types in production code.
- Factory stage IDs are typed as string literals matching the 14 stage IDs.

---

## API Design Patterns

### REST Resource URLs

```
GET    /api/orders                      — list orders
POST   /api/orders                      — create order (S-01)
GET    /api/orders/{order_id}           — get order detail

GET    /api/units                       — list units
POST   /api/units                       — provision unit (S-02)
GET    /api/units/{unit_id}             — get unit with full stage history
POST   /api/units/{unit_id}/advance     — advance to next stage
POST   /api/units/{unit_id}/hard-stop   — raise hard-stop
POST   /api/units/{unit_id}/resolve     — resolve hard-stop (supervisor+)

POST   /api/units/{unit_id}/calibration — record calibration attempt (S-06)
POST   /api/units/{unit_id}/qc-signoff  — QC sign-off (S-09, supervisor+)
```

### Factory Domain Verbs

Use factory domain language in API paths and function names.
Prefer: `provision`, `allocate`, `scan`, `advance`, `lock`, `ship`.
Avoid generic CRUD verbs where domain verbs exist.

---

## State Store Pattern (v0 — In-Memory)

```python
# backend/app/state/store.py
# v0 in-memory store — single source of truth for all factory data

from typing import Dict, List
from app.models import FactoryUnit, ProductionOrder

orders: Dict[str, ProductionOrder] = {}
units: Dict[str, FactoryUnit] = {}
```

The store is a module-level singleton in v0. When Postgres is introduced, the
store interface is preserved and implementations are swapped behind it.

---

## Naming Conventions

| Concept          | Backend (Python)          | Frontend (TypeScript)  |
|------------------|---------------------------|------------------------|
| Factory unit     | `factory_unit`            | `factoryUnit`          |
| Stage ID         | `CALIBRATION_GATE`        | `"CALIBRATION_GATE"`   |
| Hard-stop        | `hard_stop`               | `hardStop`             |
| Calibration cert | `calibration_certificate` | `calibrationCertificate` |
| QC sign-off      | `qc_signoff`              | `qcSignoff`            |
| Genealogy lock   | `genealogy_lock`          | `genealogyLock`        |
