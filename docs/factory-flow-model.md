# Factory Flow Model — ndt-factory-cloud

**Authority level:** This document is the authoritative source for all factory production
stage definitions, transition rules, and control gates. Backend stage machine logic,
frontend progress display, and verification tests must all reference this model.

**Status:** FROZEN (D2A — drift-corrected 2026-06-30)
**Canonical model version:** v1

---

## Production Spine Overview

The ndt-factory-cloud production spine consists of 14 ordered stages. Every AstraX/NDT
handheld device travels through these stages in sequence. Out-of-order advancement is
prohibited.

### Stage Type Legend

| Type          | Meaning                                                           |
|---------------|-------------------------------------------------------------------|
| `external`    | Originates outside the factory system (customer, sales)           |
| `factory core`| Core production operation performed inside the factory            |
| `gate`        | Blocking checkpoint — must pass before proceeding; hard-stops apply |
| `terminal`    | Final state — record becomes immutable                            |

---

## 14-Stage Production Spine

| Stage | Name                                  | Type          | Actor                   | Description                                    |
|-------|---------------------------------------|---------------|-------------------------|------------------------------------------------|
| S-01  | Order Created                         | external      | Customer / Sales        | Order is created in the customer/sales system  |
| S-02  | Order Approved                        | external      | Sales / Management      | Order reviewed and approved for production     |
| S-03  | Order Received by Factory             | factory core  | Factory System          | Order enters the factory system; unit provisioned |
| S-04  | Parts Allocated                       | factory core  | Operator                | Serialized parts reserved from inventory for the unit |
| S-05  | Assembly                              | factory core  | Operator                | Unit physically assembled; parts scan-confirmed |
| S-06  | Software / Firmware Installed         | factory core  | Technician              | Factory-baseline software/firmware flashed to device |
| S-07  | Software / Firmware Updated from Cloud | factory core | System / Technician     | Device syncs to current production firmware version from cloud |
| S-08  | Device Provisioned with Cloud         | factory core  | System                  | Cloud device identity and credentials provisioned; pushed to device |
| S-09  | Hardware Checks / Setup               | factory core  | Technician              | Physical and electrical checks; hardware setup confirmed |
| S-10  | Calibration                           | gate          | Technician              | Calibration performed with reference standard; max 3 attempts |
| S-11  | Quality Control                       | gate          | QC Inspector / Supervisor | Final human sign-off; verifies physical unit and digital record |
| S-12  | Factory Data Backup to Cloud          | factory core  | System                  | Full production record backed up to cloud; confirms device reachability |
| S-13  | Package                               | factory core  | Operator                | Device packaged for shipment                   |
| S-14  | Ship                                  | terminal      | Operator / Manager      | Device shipped; all production records immutable |

---

## Transition Rules

### General Rules

1. Stages advance in sequence: S-01 → S-02 → ... → S-14. No skipping.
2. A stage cannot begin until the previous stage is in `complete` status.
3. Only the backend may advance stage state. Frontend reads state; it does not write it.
4. Every stage transition is logged with actor identity, timestamp, and stage ID.
5. S-12 (Factory Data Backup) cannot proceed unless S-11 (Quality Control) has passed.
   This is a domain rule enforced in the stage machine, not a separate stage.

### Hard-Stop Rules

A hard-stop blocks all stage advancement until explicitly resolved by an authorized actor.
Hard-stops are raised automatically by the system or manually by operators/supervisors.

Hard-stop conditions:

| Condition                                  | Raised by         | Clearance authority    |
|--------------------------------------------|-------------------|------------------------|
| Missing required part scan (S-05)          | System            | Operator               |
| Calibration reference standard invalid or expired (S-10) | System | Supervisor (no override — hard block) |
| Calibration failed 3 times (S-10)          | System            | Supervisor             |
| QC inspection failure / sign-off withheld (S-11) | Supervisor   | Manager                |
| Cloud provision failure (S-08)             | System            | Supervisor             |
| Cloud backup failure (S-12)                | System            | Supervisor             |

---

## Gate: Calibration (S-10)

The Calibration stage is a gate with an internal retry loop.

### Pre-Check: Reference Standard Validation

Before any calibration attempt may begin, the technician must validate the calibration
reference standard (traceability document, expiry date, certificate ID).

- If the reference standard is expired or invalid: **hard-stop raised immediately.**
  This hard-stop has no bypass. Supervisor must obtain a valid reference standard
  and explicitly clear the hard-stop before any calibration attempt is permitted.
- This check runs again before each subsequent attempt.

### Calibration Retry Loop

```
Pre-check → reference standard valid?
  NO  → HARD-STOP raised (no override) → supervisor must clear with valid standard
  YES → proceed to calibration attempt

Attempt 1 → PASS → Calibration complete; calibration certificate issued
Attempt 1 → FAIL → record failure; attempt count = 1 → proceed to attempt 2

Attempt 2 → PASS → Calibration complete; calibration certificate issued
Attempt 2 → FAIL → record failure; attempt count = 2 → proceed to attempt 3

Attempt 3 → PASS → Calibration complete; calibration certificate issued
Attempt 3 → FAIL → record failure; attempt count = 3 → HARD-STOP raised
             → Supervisor disposition required before any further attempt
```

### Calibration Records

- Every attempt (pass or fail) is recorded: attempt number, timestamp, technician identity, result, measurements.
- A successful attempt issues a **calibration certificate** attached to the unit.
- The calibration certificate is the clean pass record.
- The full attempt history (including failures) is retained in the unit's production record.
- All 14 passes are preserved alongside the certificate in the internal record.
- The 3-attempt limit applies per production run. A supervisor may authorize a new attempt cycle after disposition.

### Pass Condition

A valid calibration certificate recorded against the unit in this production run.

### Fail Condition After Maximum Attempts

3 failed calibration attempts with no valid certificate → HARD-STOP → supervisor disposition.

Supervisor disposition outcomes: `rework` (new attempt cycle authorized), `reject`, `escalate`.

---

## Gate: Quality Control (S-11)

Quality Control is the final human gate before the device proceeds to backup and shipment.

### QC Inspection Rules

- A QC inspector (or supervisor) must physically inspect the unit.
- The QC inspector must verify:
  - Physical unit condition
  - Assembly scan record (all parts confirmed)
  - Software/firmware version matches production baseline
  - Hardware checks passed (S-09 complete)
  - Calibration certificate present and valid
- The QC inspector verifies the **digital record** matches the **physical unit**.

### Sign-Off

- QC pass requires an explicit sign-off action by the QC inspector or supervisor.
- Sign-off records: actor identity, timestamp, inspection outcome.
- Separation of duty: the actor who signs off QC must not be the same actor who performed
  assembly (S-05). This is a future production requirement; enforced from the phase in
  which separation-of-duty policy is activated.

### Post-QC Effect

QC pass **finalizes the production record** for the unit:
- All prior stage scan records and production data are treated as authoritative.
- S-12 (Factory Data Backup to Cloud) is now authorized to proceed.
- The production record may not be modified after QC pass except by explicit corrective
  action under manager authority (creates a new audit entry; does not overwrite the original).

### Fail Condition

QC inspector withholds sign-off or raises a finding → HARD-STOP.

Supervisor/manager disposition outcomes: `rework` (returns to appropriate earlier stage),
`reject`, `escalate`.

---

## Authority Levels

| Level      | Role               | Permissions                                                  |
|------------|--------------------|--------------------------------------------------------------|
| Operator   | Factory floor      | Advance S-03–S-05, S-13; scan parts; package                |
| Technician | Factory technician | Advance S-06–S-10; firmware install; hardware checks; calibration |
| Supervisor | Line supervisor    | QC sign-off (S-11); clear hard-stops; disposition calibration and QC failures |
| Manager    | Factory manager    | Override rework limits; authorize S-14 (Ship); escalate dispositions |

Authority is enforced by the backend. The frontend indicates authority gating; enforcement
lives in the API layer.

---

## Terminal States

| State      | Description                                               |
|------------|-----------------------------------------------------------|
| `shipped`  | Successful production completion (S-14)                   |
| `rejected` | Unit rejected at gate (calibration or QC); record immutable |
| `scrapped` | Manager decision to scrap; record immutable               |

Once a unit reaches any terminal state, its production record is immutable. No stage
transitions, no record modifications, no annotation changes are permitted.

---

## Stage Status Values

| Status    | Meaning                                         |
|-----------|-------------------------------------------------|
| `pending` | Stage not yet started                           |
| `active`  | Stage is currently in progress                  |
| `complete`| Stage successfully completed                    |
| `blocked` | Hard-stop is active; advancement blocked        |
| `failed`  | Stage failed; disposition required              |
