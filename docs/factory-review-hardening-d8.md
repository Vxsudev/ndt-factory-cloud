# D8 Factory Review Hardening — Documentation

**Phase:** D8 Demo Readiness
**Status:** COMPLETE
**Date:** 2026-06-30

---

## Purpose

Harden the Factory Cloud v0 prototype for stakeholder review. D8 improves the existing
D6 UI without adding new features, changing domain rules, or expanding product scope.

Core rule: make the existing prototype reviewable.

---

## What D8 Changes

D8 is a presentation layer improvement. No backend logic, domain rules, database schema,
API endpoints, or workflow rules are changed.

### Header

| Before (D6) | After (D8) |
|-------------|------------|
| "D6 Factory Flow Board" | "D8 Review Prototype" |
| No persistence indicator | "Postgres-backed" badge |
| "Reset Mock State" button | "Reset Demo State" button |
| No D8 data attribute | `data-d8-demo-readiness="true"` on root div |

### Unit Queue

| Before (D6) | After (D8) |
|-------------|------------|
| Unit ID, order ID, stage, status | + **Scenario label** (sky-400 text) |
| No context for each unit's purpose | Labels: "Assembly in progress", "Cloud SW/FW blocked", etc. |

Scenario labels are derived from a `SCENARIO_LABELS` mapping in UnitList.tsx. No seed
data changes were required.

### Stage Spine

| Before (D6) | After (D8) |
|-------------|------------|
| Gates S-09/S-10/S-11 had no special pending styling | Gate rows get amber border when pending |
| CLOUD BLOCK badge only shown when currently blocked | CLOUD BLOCK badge always shown on S-07/S-12 |
| NO OVERRIDE: standard red badge | NO OVERRIDE: `font-black tracking-wide bg-red-700 text-white` |
| Gate/terminal rows same height as others | Gate/terminal rows get `py-2.5` extra padding |
| Cloud stages: same border as pending | Cloud stages: slate border for pending visibility |
| Terminal S-14: green border only when current | Terminal S-14: green border always |

### Unit Detail Panel

| Before (D6) | After (D8) |
|-------------|------------|
| Blocked reason shown inline in Stage/Status section | Explicit "Block / Hard-Stop" section added when blocked |
| No block_type display | block_type shown in hard-stop section |
| `NO OVERRIDE` as inline span | `NO OVERRIDE — No bypass possible` as prominent red block |

### Action Panel

| Before (D6) | After (D8) |
|-------------|------------|
| Form header was just action name | + "Backend-guarded action" label |
| No endpoint URL shown | Each form shows the POST endpoint URL |
| Response box: status, message, event_id | Response box: + all fields clearly labeled |
| No "no actions available" message for unsupported stages | "No available action..." guidance text added |

### Event Trace

| Before (D6) | After (D8) |
|-------------|------------|
| All 25 events shown flat | **Unit-filtered view**: selected unit's events first |
| No unit focus mode | "Show all events" toggle |
| "Event Trace (recent 25)" label | Label adapts to filtered/all mode |

### index.html

| Before (D6) | After (D8) |
|-------------|------------|
| `<title>Factory Cloud v0 — D6 Factory Flow Board</title>` | `<title>Factory Cloud v0 — D8 Review Prototype</title>` |
| `<meta name="app-phase" content="D6-factory-flow-board" />` | `<meta name="app-phase" content="D8-review-prototype" />` |
| — | `<meta name="app-d8" content="demo-readiness" />` |

D6 backward-compat tag `<meta name="app-d6" content="factory-flow-board" />` retained.

---

## What D8 Does NOT Change

- `backend/app/workflow_rules.py` — unchanged
- `backend/app/routes/actions.py` — unchanged
- `backend/app/routes/data_contract.py` — unchanged
- `backend/app/state_store.py` — unchanged
- `backend/app/models.py` — unchanged
- All 11 D5 action endpoints — same URLs, same request/response shapes
- All 10 D4 data contract endpoints — same URLs, same response shapes
- 14-stage canonical production spine — unchanged
- PostgreSQL schema — unchanged
- Alembic migrations — unchanged
- Hard-stop enforcement — unchanged
- No-override semantics — unchanged
- Terminal state immutability — unchanged
- `data/*.json` seed files — unchanged

---

## New Files

| File | Purpose |
|------|---------|
| `docs/demo-walkthrough-d8.md` | Reviewer walkthrough script |
| `docs/factory-review-hardening-d8.md` | This file — D8 documentation |
| `specs/factory-review-hardening.md` | D8 spec (approved) |
| `specs/phases/phase-demo-readiness.md` | Phase definition |
| `scripts/verification/008-demo-readiness.sh` | D8 verification (17 checks) |

---

## Changed Files

| File | Change |
|------|--------|
| `frontend/src/components/FactoryFlowBoard.tsx` | Header D8 markers, pass selectedUnitId to EventTrace |
| `frontend/src/components/UnitList.tsx` | Scenario labels mapping |
| `frontend/src/components/StageSpine.tsx` | Gate/cloud-block/terminal visual improvements |
| `frontend/src/components/UnitDetailPanel.tsx` | Block/Hard-Stop section |
| `frontend/src/components/ActionPanel.tsx` | Backend-guarded label, endpoint URL, response clarity |
| `frontend/src/components/EventTrace.tsx` | Unit filtering, all-events toggle |
| `frontend/index.html` | D8 meta tags, title |
| `scripts/verification/006-factory-flow-board-ui.sh` | V3 updated: "D6 in title" → "Factory Cloud in page" |

---

## Demo Scenarios Preserved

| Unit | Stage | Scenario | Key Property |
|------|-------|----------|-------------|
| UNIT-0001 | S-05 | Assembly in progress | scan-part action available |
| UNIT-0002 | S-07 | Cloud SW/FW blocked | no_override=true hard-stop |
| UNIT-0003 | S-10 | Calibration retry active | 2/3 attempts, retry possible |
| UNIT-0004 | S-10 | Calibration cap exceeded | 3/3, supervisor disposition required |
| UNIT-0005 | S-11 | QC ready | hardware+cal passed, awaiting sign-off |
| UNIT-0006 | S-12 | Cloud backup blocked | no_override=true hard-stop |
| UNIT-0007 | S-14 | Shipped — terminal | immutable, all actions 409 |

---

## Reviewer Experience Target

A reviewer opening http://localhost:5173 should understand within 60 seconds:

1. This is Factory Cloud v0 ✓ (header title)
2. Left side is unit queue ✓ (labeled "Unit Queue (7)")
3. Center is 14-stage spine ✓ (labeled "14-Stage Production Spine")
4. Selected unit's position highlighted ✓ (blue dot)
5. Blocked units clearly show reason ✓ (red badge + reason text)
6. Stage 7 and 12 cloud blocks visible ✓ (CLOUD BLOCK badge always shown)
7. No-override hard-stops obvious ✓ (red NO OVERRIDE badge)
8. Gates 9/10/11 visually distinct ✓ (amber border + GATE badge)
9. Calibration 3-attempt cap ✓ (shown in unit detail)
10. QC finalizes record ✓ (sign-off action at stage 11)
11. Stage 14 is terminal ✓ (TERMINAL + SHIPPED badges, no actions)
12. Actions are backend-guarded ✓ (label on every form)
13. Reset returns to seed state ✓ (Reset Demo State button)

---

## Verification

```bash
docker compose up --build -d
bash scripts/verification/008-demo-readiness.sh
```

17 checks covering: frontend loads, D8 markers, Factory Cloud v0, persistence markers,
backend health, data contract, stage_count=14, unit_count≥7, D4-D7 verifications,
reset-state, Postgres running, no Azure SDK, no auth code, smoke passes.

---

## What Is Intentionally Not Implemented (D8)

- Auth / login
- Azure SDK wiring
- Real external integrations
- Reporting analytics
- WebSockets
- Production deployment
- Tenanting
- Major schema redesign

---

## D9 Handoff

D9 is safe to begin after D8 RELEASE_APPROVED with an explicit directive. Candidates:
- Order management UI (create orders, approve orders)
- Full unit history viewer (complete audit trail per unit)
- Azure IoT Hub wiring for S-07 and S-12
- All require new explicit directives before implementation.
