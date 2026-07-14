# Factory Cloud v0 — Demo Walkthrough

**Phase:** D8 Review Prototype
**Audience:** Vijay / Mohit / engineering stakeholders
**Date:** 2026-06-30

---

## Setup

```bash
# From repo root
docker compose down -v           # clean slate
docker compose up --build -d     # build and start all services

# Verify stack is healthy
curl http://localhost:8000/health
# Expected: {"status":"ok","service":"factory-cloud","phase":"D8"}

# Open the UI
open http://localhost:5173
```

Wait ~10 seconds for Postgres to seed and the frontend dev server to compile.

**Reset to known seed state at any time:**

Click **Reset Demo State** in the header, or:

```bash
curl -X POST http://localhost:8000/factory/dev/reset-state
```

---

## UI Overview

When the page loads, you will see:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ Factory Cloud v0  [Postgres-backed]                     Backend: ok         │
│ D8 Review Prototype                       Data Contract: 14 stages · 7 units│
│                                                          [Reset Demo State]  │
├──────────────────┬──────────────────────┬───────────────────────────────────┤
│ UNIT QUEUE (7)   │ 14-STAGE SPINE       │ UNIT DETAIL + ACTION PANEL        │
│                  │                      │                                   │
│ UNIT-0001        │ S-01 Order Created   │ Select a unit to see detail       │
│ Assembly in prog │ S-02 Order Approved  │                                   │
│                  │ ...                  │                                   │
│ UNIT-0002  BLOCK │ S-07 [CLOUD BLOCK]   │                                   │
│ Cloud SW/FW blkd │ ...                  │                                   │
│                  │ S-09 [GATE]          │                                   │
│ UNIT-0007 SHIPPED│ S-10 [GATE]          │                                   │
│ Shipped-terminal │ S-11 [GATE]          │                                   │
│                  │ S-12 [CLOUD BLOCK]   │                                   │
│                  │ S-14 [TERMINAL]      │                                   │
├──────────────────┴──────────────────────┴───────────────────────────────────┤
│ EVENT TRACE: recent events — sorted by timestamp, unit-filtered when selected│
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Demo Scenarios — Step by Step

### Step 1 — Unit Queue and Scenario Labels

**What to show:** The left column lists all 7 seeded units. Each unit card shows:
- Unit ID (UNIT-0001 through UNIT-0007)
- A **scenario label** in blue (e.g., "Assembly in progress")
- Current stage number and status
- Red BLOCKED badge + reason for blocked units
- Green SHIPPED badge for the terminal unit

**Talking points:**
- "7 units are pre-seeded to demonstrate all key production scenarios."
- "Each unit sits at a different stage of the 14-stage production spine."
- "Blocked units prominently show what is blocking them."

---

### Step 2 — UNIT-0002: Stage 7 Cloud SW/FW Hard-Block

**Select UNIT-0002 in the unit queue.**

Unit Detail shows:
```
Stage:          STAGE-07 (S-07) — Software / Firmware Updated from Cloud
Status:         cloud_blocked
─── Block / Hard-Stop ─────────────────────────────────────────────
Blocked Reason: cloud_unreachable_sw_update_cannot_proceed
NO OVERRIDE — No bypass possible
Block Type:     hardstop_cloud_dependency
───────────────────────────────────────────────────────────────────
```

Stage Spine shows STAGE-07 highlighted in red with:
- CLOUD BLOCK badge (red)
- BLOCKED badge
- NO OVERRIDE badge (prominent red)

Action Panel shows no available action (cloud dependency — cannot proceed until cloud is available).

**Talking points:**
- "Stage 7 requires a cloud connection to sync device firmware. In this demo, cloud is mocked as unavailable."
- "The hard-stop has NO OVERRIDE. There is no way to bypass this in the system."
- "The backend enforces this — the UI cannot override it. Attempting any action returns a 200 BLOCKED response, not an error."
- "Resolution is a re-check once the cloud service becomes available again — not a Supervisor
  override. There is no floor-owned action for this block today: the current prototype has no
  recovery endpoint for Stage 7, so once cloud connectivity is restored the unit still requires a
  future re-check capability to proceed (see `docs/manufacturing-comprehension-model.md`)."

---

### Step 3 — UNIT-0003: Calibration Retry Active (2 of 3 attempts)

**Select UNIT-0003 in the unit queue.**

Unit Detail shows:
```
Stage:    STAGE-10 (S-10) — Calibration
Status:   calibration_in_progress
Calibration:
  Attempts:  2 / 3
  Passed:    no
  Last:      fail (coefficient_out_of_range)
```

**Talking points:**
- "This unit is at the Calibration gate (S-10). It has failed twice."
- "The system allows up to 3 attempts. One remains."
- "Try submitting a calibration attempt with result=fail to see the cap exceeded state."

**To demonstrate the 3rd fail:**
In the Action Panel (Calibration form), change Result to "fail" and click Submit Calibration.

The response will show:
```
BLOCKED
calibration_cap_exceeded_supervisor_disposition_required
```

And the unit transitions to the same state as UNIT-0004.

---

### Step 4 — UNIT-0004: Calibration Cap Exceeded

**Select UNIT-0004 in the unit queue.**

Unit Detail shows:
```
Stage:    STAGE-10 (S-10) — Calibration
Status:   calibration_cap_exceeded_awaiting_disposition
─── Block / Hard-Stop ─────────────────
Blocked Reason: calibration_cap_exceeded_supervisor_disposition_required
Block Type:     calibration_retry_cap
───────────────────────────────────────
Calibration:
  Attempts:  3 / 3
  Cap Exceeded: YES — disposition required
```

Action Panel shows Calibration Disposition form (supervisor authority required).

**Talking points:**
- "3 failed calibration attempts — the system has hard-stopped and requires supervisor disposition."
- "A supervisor can route back to hardware setup (S-09) for a new calibration cycle, quarantine, or scrap."
- "This enforces the production constraint: you cannot retry indefinitely."

**To demonstrate disposition:**
Keep disposition as "Route back to hardware" and click Submit Disposition.
The unit advances back to STAGE-09.

---

### Step 5 — UNIT-0005: QC Sign-Off

**Select UNIT-0005 in the unit queue.**

Unit Detail shows:
```
Stage:    STAGE-11 (S-11) — Quality Control
Status:   ready_for_qc
Gate Results:
  STAGE-09: pass
  STAGE-10: pass (certificate CERT-MOCK-0005)
QC Summary: not yet signed off
```

Action Panel shows QC Sign-Off form.

**To perform QC sign-off:**
Actor User ID defaults to `USER-QC-0001`. Click Submit QC Sign-Off.

Response:
```
SUCCESS
STAGE-12 · event_id: EVENT-D5-XXXX
QC sign-off recorded for UNIT-0005. Advancing to STAGE-12.
```

The unit advances to STAGE-12. Event trace updates.

**Talking points:**
- "QC is the final human gate. Hardware checks and calibration must be complete."
- "Separation of duty: the QC inspector cannot be the same person who did assembly or calibration."
- "QC pass finalizes the production record — no modifications after this point."

---

### Step 6 — UNIT-0006: Stage 12 Cloud Backup Hard-Block

**Select UNIT-0006 in the unit queue.**

Unit Detail shows:
```
Stage:    STAGE-12 (S-12) — Factory Data Backup to Cloud
Status:   cloud_backup_blocked
─── Block / Hard-Stop ─────────────────────────────────────
Blocked Reason: cloud_backup_cannot_complete_connectivity_unavailable
NO OVERRIDE — No bypass possible
Block Type:     hardstop_cloud_dependency
────────────────────────────────────────────────────────────
QC Summary: signed_off by USER-QC-0001 ✓
```

**Talking points:**
- "Stage 12 backs up the full production record to cloud. Cloud is mocked as unavailable."
- "Like Stage 7, this has NO OVERRIDE — the production record cannot be marked complete without the backup."
- "Once cloud connectivity is restored, Retry Cloud Backup performs a re-check — this is not a
  Supervisor override and requires no special authority; any actor may submit it once the cloud
  is reachable again (see `docs/manufacturing-comprehension-model.md`)."

---

### Step 7 — UNIT-0007: Stage 14 Shipped — Terminal State

**Select UNIT-0007 in the unit queue.**

Unit Detail shows STAGE-14 highlighted with TERMINAL and SHIPPED badges.
```
Stage:  STAGE-14 (S-14) — Ship
Status: shipped  [green]
Cloud:  backed up ✓
QC:     signed_off ✓
Shipped: yes / Packaged: yes / Terminal: yes
```

Action Panel shows:
```
TERMINAL — Unit shipped. No further actions available.
```

**Talking points:**
- "Once a unit ships, its production record is immutable. The backend rejects all further actions with 409 Conflict."
- "Try the Dev Transition form (at the bottom of the action panel) and submit — the backend returns 409."

---

### Step 8 — Event Trace

At the bottom of the page, the **Event Trace** shows recent production events.

- When a unit is selected, that unit's events appear at the top.
- Toggle "Show all events" to see the full 25-event window.
- Each event shows: event ID, unit, stage, severity, message, timestamp.

**Talking points:**
- "Every backend action produces an immutable audit event."
- "Events are persisted to Postgres — they survive container restart."
- "Event IDs starting with EVT- are seeded. EVENT-D5- events are produced by actions in this session."

---

### Step 9 — Reset State

Click **Reset Demo State** in the header.

The backend truncates all DB tables and reseeds from `data/*.json`. All 7 units return to
their seeded positions. All session events are cleared.

**Talking points:**
- "State is fully persisted in Postgres. A reset returns to known seed state."
- "Even a full `docker compose down && docker compose up` preserves state (volume is named)."
- "Use `docker compose down -v` to also wipe the Postgres volume for a clean start."

---

## Talking Points Summary

### Backend Owns All Authority

The frontend is a display layer. Every workflow decision — whether to advance a stage,
block a unit, enforce a hard-stop — is made by the FastAPI backend. The frontend submits
operator actions and displays backend responses. It cannot fake a success or bypass a check.

### Postgres Persistence

Unit state, part allocations, calibration history, events — all live in PostgreSQL 16.
State survives container restart. Schema is managed by Alembic migrations. Seeding
happens automatically on first boot.

### Mocked Cloud Integrations

Stage 7 (cloud SW/FW update) and Stage 12 (cloud backup) require cloud connectivity.
In this prototype, the cloud is mocked. `cloud_available=false` triggers the hard-stop.
In production, these stages would integrate with Azure IoT Hub and Azure Blob Storage.

### Source Requirements

The canonical digital factory requirements are in:
`source-materials/digital-factory-requirements-v1/`

The 14-stage production spine is derived from these requirements and frozen in:
`docs/factory-flow-model.md`

---

## Known Limitations

This is a local development prototype. The following are explicitly out of scope for v0:

| Area | Status |
|------|--------|
| Auth / login | Not implemented — all users are mock |
| Azure deployment | Not implemented — runs in Docker Compose locally |
| Real cloud / Azure SDK | Not implemented — cloud stages are mocked |
| Real device communication | Not implemented — device connectivity is simulated |
| Real inventory / eStore | Not implemented — parts and orders are seeded fixtures |
| Production secret handling | Not implemented — dev credentials only |
| Reporting / yield analytics | Not implemented — deferred |
| Multi-site / tenanting | Not in scope for v0 |
| Real-time push updates | Not implemented — polling on action only |
| Full unit history viewer | Not implemented |

---

## Appendix: Stack Details

| Service | URL | Notes |
|---------|-----|-------|
| Frontend | http://localhost:5173 | Vite dev server, hot-reload |
| Backend API | http://localhost:8000 | FastAPI, uvicorn |
| API Docs | http://localhost:8000/docs | Swagger UI |
| Postgres | localhost:5432 (internal) | Not exposed to host |

Stack: `docker compose up --build -d`
Shutdown: `docker compose down`
Full reset (wipe DB): `docker compose down -v && docker compose up --build -d`
