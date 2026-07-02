# D5 Backend State Behavior — Documentation

**Phase:** D5
**Status:** COMPLETE
**Date:** 2026-06-30

---

## Purpose

D5 converts the D4 read-only mock data contract into a controlled in-memory workflow
engine. The backend now owns factory workflow state for all key production stages.
No Postgres, no Azure SDK, no auth, no Factory Flow Board UI.

---

## What D5 Adds

| Capability | D4 | D5 |
|-----------|----|----|
| Read-only data API (10 GET endpoints) | yes | yes (unchanged) |
| In-memory state store | no | yes |
| Workflow action endpoints (11 POST) | no | yes |
| Stage transition enforcement | no | yes |
| Hard-stop / no_override enforcement | no | yes |
| Calibration retry cap | no | yes |
| Separation-of-duty QC check | no | yes |
| Terminal unit immutability | no | yes |
| Dev state reset endpoint | no | yes |

---

## Architecture

```
backend/app/
├── state_store.py      ← singleton in-memory state; loaded from data/*.json at startup
├── workflow_rules.py   ← all domain workflow logic (10 action functions)
├── models.py           ← D4 models + D5 request/response models
└── routes/
    └── actions.py      ← 11 POST endpoints mapping to workflow_rules
```

State is a Python dict keyed by unit_id, loaded at import time from `data/*.json`.
No writes to disk. `reset_state()` reloads from JSON — container restart also resets.

---

## State Store (`backend/app/state_store.py`)

```
state = {
  "units":             {unit_id: unit_dict},
  "parts":             {part_id: part_dict},
  "users":             {user_id: user_dict},
  "reference_standards": {refstd_id: refstd_dict},
  "events":            [event_dict, ...],
  "event_counter":     int,
  "parts_by_serial":   {serial_number: part_id}   ← secondary index
}
```

`parts_by_serial` is built at load time for O(1) serial lookup during assembly scan.

---

## Action Endpoints

| Method | Path | Domain Rule |
|--------|------|-------------|
| POST | `/factory/units/{unit_id}/actions/scan-part` | Binds allocated part at STAGE-05 |
| POST | `/factory/units/{unit_id}/actions/reallocate-part` | Supervisor reallocates part |
| POST | `/factory/units/{unit_id}/actions/hardware-gate` | Pass/fail at STAGE-09 |
| POST | `/factory/units/{unit_id}/actions/calibration` | Record calibration attempt at STAGE-10 |
| POST | `/factory/units/{unit_id}/actions/calibration-disposition` | Disposition after cap exceeded |
| POST | `/factory/units/{unit_id}/actions/qc-signoff` | QC sign-off at STAGE-11 |
| POST | `/factory/units/{unit_id}/actions/cloud-backup` | Cloud backup at STAGE-12 |
| POST | `/factory/units/{unit_id}/actions/package` | Package at STAGE-13 |
| POST | `/factory/units/{unit_id}/actions/ship` | Ship at STAGE-14 (terminal) |
| POST | `/factory/units/{unit_id}/actions/transition` | Generic stage advance |
| POST | `/factory/dev/reset-state` | Reload all state from JSON (dev only) |

---

## Response Contract

All action endpoints return `ActionResponse`:

```json
{
  "status": "success | blocked | failed",
  "unit_id": "UNIT-0001",
  "current_stage_id": "STAGE-06",
  "current_status": "in_progress",
  "message": "Part PS-SN-MOCK-0002 bound to UNIT-0001 at STAGE-05.",
  "event_id": "EVENT-D5-0001",
  "blocked_reason": null,
  "no_override": null
}
```

Business hard-stops return HTTP 200 with `status="blocked"`.
Terminal unit actions return HTTP 409.
Missing unit returns HTTP 404.
Invalid request body returns HTTP 422.

---

## Event System

Every action appends exactly one event to `state["events"]`.
Event IDs use the format `EVENT-D5-XXXX` (sequential counter starting at 0001).
These never collide with seed event IDs (`EVT-*`).

---

## Domain Rules by Stage

### STAGE-05 Assembly Scan (`scan-part`)

1. Unit must be at STAGE-05.
2. Part type must match an allocated slot in `unit.part_allocations`.
3. Serial number must be in the parts index.
4. Part must not be already bound to another unit.
5. Serial must match the allocated slot's `part_id` resolved serial.
6. On success: part bound, `assembly_operator_id` set (used later for separation-of-duty).

### Reallocation (`reallocate-part`)

- Actor must have `can_override: true` (supervisor or above).
- Releases old part; creates new part record in-memory if serial unknown.
- Records reallocation history in `unit.genealogy.reallocation_history`.

### STAGE-09 Hardware Gate (`hardware-gate`)

- `result="pass"` → advance to STAGE-10.
- `result="fail"` → `current_status = hardware_rework_required`.

### STAGE-10 Calibration (`calibration`)

- Each reference standard in `reference_standard_ids` must have `can_be_used_for_calibration: true`.
  - Expired or missing-cert standards → blocked, `no_override: true`.
- Attempt count tracked in `unit.calibration_status.attempt_history`.
- `result="pass"` → issue certificate, advance to STAGE-11.
- `result="fail"`, attempts < 3 → blocked (retry allowed).
- `result="fail"`, attempts = 3 → cap exceeded, disposition required.

### Calibration Disposition (`calibration-disposition`)

- Only when cap exceeded.
- `route_back_to_hardware` → reset calibration state, advance to STAGE-09.
- `scrap` → terminal state.
- `quarantine` → blocked pending review.

### STAGE-11 QC Sign-Off (`qc-signoff`)

1. Unit must be at STAGE-11.
2. Actor must have `can_qc_signoff: true`.
3. Hardware gate must be passed (`hardware_gate_passed: true`).
4. Calibration certificate must exist.
5. Signer must not be the assembly operator (separation of duty).
6. Signer must not be the calibration technician (separation of duty).
7. Manager waiver path: if signer is SOD-conflicted, `waiver_actor_user_id` + `waiver_reason` required.
8. On success: `qc_summary.signed_off = true`, advance to STAGE-12.

### STAGE-12 Cloud Backup (`cloud-backup`)

- `cloud_available: false` → blocked, `no_override: true` (hard-stop, no waiver possible).
- `cloud_available: true` → `cloud_status.backed_up = true`, advance to STAGE-13.

### STAGE-13 Package (`package`)

- Advance to STAGE-14.

### STAGE-14 Ship (`ship`)

- Requires `qc_summary.signed_off: true` and `cloud_status.backed_up: true`.
- On success: terminal state — `package_ship_status.terminal = true`, `current_status = shipped`.

### Generic Transition (`transition`)

- Terminal units → HTTP 409.
- Active hard-stop on unit → 200 blocked.
- Target must be exactly `current_stage + 1` → else HTTP 409.

---

## Seed Data — D5-Critical Units

| Unit | Stage | State | D5 Test Fixture |
|------|-------|-------|-----------------|
| UNIT-0001 | STAGE-05 | assembly_active | scan-part (POWER_SUPPLY / PS-SN-MOCK-0002) |
| UNIT-0003 | STAGE-10 | calibration_in_progress | 2/3 attempts → 3rd fail triggers cap |
| UNIT-0004 | STAGE-10 | calibration_cap_exceeded | any calibration attempt returns blocked |
| UNIT-0005 | STAGE-11 | ready_for_qc | QC sign-off with USER-QC-0001 succeeds |
| UNIT-0006 | STAGE-12 | cloud_backup_blocked | cloud_available=false → no_override hard-stop |
| UNIT-0007 | STAGE-14 | shipped (terminal) | any transition → 409 |

Reference standard states:
- `REFSTD-0001` — valid, `can_be_used_for_calibration: true`
- `REFSTD-0002` — expired, `can_be_used_for_calibration: false` → no_override hard-stop
- `REFSTD-0003` — missing certificate, `can_be_used_for_calibration: false` → no_override hard-stop

---

## What Is Intentionally Not Implemented (D5)

- Postgres or any database (no-op as per decision lock)
- Azure SDK wiring (all cloud_available checks are mock flags)
- Auth / session management
- Factory Flow Board UI
- Full unit detail frontend
- Cloud sync for STAGE-07 (present in seed data as historical event only)

---

## Verification

Run against the running stack:

```bash
docker compose up --build -d
bash scripts/verification/005-backend-state-behavior.sh
```

15 checks: reset state, D4 backward compat, successful scan, wrong serial blocked,
supervisor realloc, cloud backup hard-stop, calibration 3rd fail, cap exceeded,
QC sign-off advance, 404 on missing unit, 409 on terminal unit, no Postgres,
no Azure SDK, frontend reachable, smoke passes.

---

## D6 Readiness

D5 is the prerequisite for D6 Factory Flow Board.
D6 will add:
- Real-time unit list UI
- Stage progress visualization
- Active hard-stop banners
- Supervisor action panels

D6 requires an explicit directive before any implementation begins.
