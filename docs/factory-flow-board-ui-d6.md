# D6 Factory Flow Board UI — Documentation

**Phase:** D6
**Status:** COMPLETE
**Date:** 2026-06-30

---

## Purpose

Build the first usable Factory Flow Board UI for the ndt-factory-cloud Digital Factory
prototype. The UI consumes D4 read endpoints and D5 action endpoints. Backend remains
sole authority for all workflow decisions.

---

## UI Layout

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ HEADER: Factory Cloud v0 · D6 Factory Flow Board · health · reset button    │
├────────────┬───────────────┬────────────────────────────────────────────────┤
│ UNIT QUEUE │ 14-STAGE SPINE│ UNIT DETAIL + ACTION PANEL                     │
│ 7 units    │ S-01 … S-14   │ Stage/status, part allocations, calibration,   │
│ w/ badges  │ visual state  │ QC, cloud, ship / + action forms               │
│            │ per selection │                                                 │
├────────────┴───────────────┴────────────────────────────────────────────────┤
│ EVENT TRACE: recent 25 events — id, unit, stage, severity, message, time    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Frontend Components

| Component | File | Purpose |
|-----------|------|---------|
| FactoryFlowBoard | components/FactoryFlowBoard.tsx | Root layout, data loading, state |
| UnitList | components/UnitList.tsx | Left column unit queue with badges |
| StageSpine | components/StageSpine.tsx | Center 14-stage visual progression |
| UnitDetailPanel | components/UnitDetailPanel.tsx | Right column unit detail fields |
| ActionPanel | components/ActionPanel.tsx | Right column action forms |
| EventTrace | components/EventTrace.tsx | Bottom event history table |

---

## API Dependency Table

| Endpoint | Used By | Purpose |
|----------|---------|---------|
| GET /health | FactoryFlowBoard | Header health indicator |
| GET /factory/data-contract/status | FactoryFlowBoard | Header contract indicator |
| GET /factory/stages | FactoryFlowBoard → StageSpine | Stage spine data |
| GET /factory/units | FactoryFlowBoard → UnitList | Unit queue |
| GET /factory/units/{id} | FactoryFlowBoard, after actions | Unit detail refresh |
| GET /factory/events | FactoryFlowBoard → EventTrace | Event history |
| GET /factory/users | ActionPanel | User select lists |
| GET /factory/parts | FactoryFlowBoard | Part context |
| GET /factory/reference-standards | ActionPanel | Ref std lists |
| POST /factory/dev/reset-state | Header reset button | Dev state reset |
| POST …/actions/scan-part | ActionPanel STAGE-05 | Assembly scan form |
| POST …/actions/reallocate-part | ActionPanel STAGE-05 | Supervisor realloc |
| POST …/actions/hardware-gate | ActionPanel STAGE-09 | Hardware gate |
| POST …/actions/calibration | ActionPanel STAGE-10 | Calibration attempt |
| POST …/actions/calibration-disposition | ActionPanel STAGE-10 | Cap exceeded |
| POST …/actions/qc-signoff | ActionPanel STAGE-11 | QC sign-off |
| POST …/actions/cloud-backup | ActionPanel STAGE-12 | Cloud backup |
| POST …/actions/package | ActionPanel STAGE-13 | Package |
| POST …/actions/ship | ActionPanel STAGE-14 | Ship (terminal) |
| POST …/actions/transition | ActionPanel (dev) | Backend-guarded transition |

---

## Action Panel Behavior

- Selecting a unit loads the correct action form for the unit's current stage.
- Submitting calls the backend POST endpoint.
- HTTP 200 with `status="blocked"` is displayed as blocked — not fake-success.
- `blocked_reason` and `no_override` shown clearly in response panel.
- After any action (success or blocked): units, selected unit detail, and events refresh.
- Dev transition form always visible (secondary, visually dimmed).

---

## Visual Semantics

| Visual | Meaning |
|--------|---------|
| EXTERNAL badge (grey) | Stage originates outside factory (S-01, S-02) |
| GATE badge (amber) | Blocking checkpoint (S-09, S-10, S-11) |
| CLOUD BLOCK badge | Cloud dependency hard-block (S-07, S-12) |
| TERMINAL badge (green) | Final state stage (S-14) |
| SEPARABLE badge (grey) | Stage can be separated from adjacent stages |
| BLOCKED badge (red) | Unit is blocked at this stage |
| NO OVERRIDE badge (red) | Hard-stop with no bypass possible |
| SHIPPED badge (green) | Unit has shipped successfully |
| Blue dot | Current stage |
| Grey dot | Completed stage |
| Red dot | Current stage with hard-stop |

---

## What Remains Backend-Owned

- All workflow transition legality decisions
- Hard-stop enforcement (no_override)
- Calibration attempt cap enforcement
- QC separation-of-duty enforcement
- Terminal state immutability (409 responses)
- Authority level enforcement

---

## What Is Intentionally Not Implemented (D6)

- Factory Flow Board routing / multi-page navigation (single page only)
- Real-time push updates (polling on action only)
- Postgres, Azure SDK, auth, session management
- Advanced reporting or yield analytics
- Mobile optimization beyond basic responsive layout
- Full unit history viewer
- Order management UI

---

## Verification

```bash
docker compose up --build -d
bash scripts/verification/006-factory-flow-board-ui.sh
```

12 checks: frontend loads, D6 meta marker, D6 title, D4 compat, D5 compat, no Postgres,
no Azure, types file, API client file, FactoryFlowBoard component, D5 verification passes,
smoke passes.

---

## D7 Handoff

D7 Persistence/Postgres is safe to begin with an explicit directive.
D7 will add:
- Postgres database for persistent state (replaces in-memory store)
- Alembic migrations
- Unit history survives container restart
- Production-grade persistence model

D7 requires an explicit directive before any implementation begins.
