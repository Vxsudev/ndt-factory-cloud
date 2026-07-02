# Factory Flow Model — ndt-factory-cloud

**Authority level:** This document is the authoritative source for all factory production
stage definitions, transition rules, and control gates. Backend stage machine logic,
frontend progress display, and verification tests must all reference this model.

**Status:** FROZEN (D2)
**Date:** 2026-06-30

---

## Production Spine Overview

The ndt-factory-cloud production spine consists of 14 ordered stages. Every AstraX/NDT
handheld device travels through these stages in sequence. Out-of-order advancement is
prohibited.

### Stage Type Legend

| Type                    | Meaning                                                    |
|-------------------------|------------------------------------------------------------|
| `external`              | Originates outside the factory system (customer, sales)    |
| `factory core`          | Core production operation performed by operator            |
| `gate`                  | Blocking checkpoint — must pass before proceeding          |
| `hard-block dependency` | Cannot execute until a specific prior gate has passed      |
| `supervisor/manager action` | Requires elevated authority to proceed              |
| `terminal`              | Final state — record becomes immutable                     |

---

## 14-Stage Production Spine

| Stage | ID                   | Type                      | Actor            | Description                                   |
|-------|----------------------|---------------------------|------------------|-----------------------------------------------|
| S-01  | ORDER_RECEIVED       | external                  | Sales / API      | Production order received from customer/sales |
| S-02  | UNIT_PROVISIONED     | factory core              | System           | Factory unit record created; placeholder serial assigned |
| S-03  | PARTS_ALLOCATED      | factory core              | Operator         | Serialized parts allocated to unit from inventory |
| S-04  | ASSEMBLY_OPEN        | factory core              | Operator         | Operator opens assembly scan session          |
| S-05  | TUBE_PRESS           | factory core              | Operator         | Tube press operation performed and scan confirmed |
| S-06  | CALIBRATION_ATTEMPT  | factory core (retry loop) | Technician       | Calibration performed; max 3 attempts before gate fails |
| S-07  | CALIBRATION_GATE     | gate                      | System           | Valid calibration certificate required; fail after 3 → supervisor disposition |
| S-08  | QC_INSPECTION        | factory core              | QC Technician    | Physical quality control inspection performed |
| S-09  | QC_SIGNOFF_GATE      | gate                      | Supervisor       | Supervisor sign-off required; fail → rework or reject |
| S-10  | GENEALOGY_LOCK       | hard-block dependency     | System           | Depends on QC_SIGNOFF_GATE pass; freezes unit genealogy permanently |
| S-11  | CLOUD_PROVISION      | factory core              | System           | Cloud credentials provisioned and pushed to device |
| S-12  | CLOUD_BACKUP         | factory core              | System           | Device backup to cloud confirmed               |
| S-13  | FINAL_REVIEW         | supervisor/manager action | Manager          | Manager reviews and authorizes shipment       |
| S-14  | SHIPPED              | terminal                  | System / Manager | Order fulfilled; all records immutable        |

---

## Transition Rules

### General Rules

1. Stages advance in sequence: S-01 → S-02 → ... → S-14. No skipping.
2. A stage cannot begin until the previous stage is in `COMPLETE` status.
3. Only the backend may advance stage state. Frontend reads state; it does not write it.
4. Every stage transition is logged with actor identity, timestamp, and stage ID.

### Hard-Stop Rules

A hard-stop blocks all stage advancement until explicitly resolved. Hard-stops are raised
and cleared only by operators/supervisors with appropriate authority.

Hard-stop conditions:

| Condition                              | Raised by         | Clearance authority    |
|----------------------------------------|-------------------|------------------------|
| Missing required part scan             | System            | Operator               |
| Calibration failed 3 times             | System            | Supervisor             |
| QC inspection finding (defect)         | QC Technician     | Supervisor / Manager   |
| Cloud provision failure                | System            | Supervisor             |
| Genealogy lock conflict                | System            | Manager                |

---

## Calibration Retry Loop

The calibration loop at S-06 / S-07 is the only retry loop in the production spine.

```
Attempt 1 → PASS → advance to S-07 (CALIBRATION_GATE passes)
Attempt 1 → FAIL → Attempt 2
Attempt 2 → PASS → advance to S-07 (CALIBRATION_GATE passes)
Attempt 2 → FAIL → Attempt 3
Attempt 3 → PASS → advance to S-07 (CALIBRATION_GATE passes)
Attempt 3 → FAIL → HARD-STOP raised → Supervisor disposition required
```

Rules:
- Maximum 3 calibration attempts per unit per production run.
- Each attempt must record: attempt number, timestamp, result, technician ID.
- Attempt count resets only if a supervisor creates a new calibration session after disposition.
- A supervisor disposition may result in: rework (new attempt cycle), reject, or escalate.
- A valid calibration certificate is required before CALIBRATION_GATE passes.

---

## Gate Control Rules

### CALIBRATION_GATE (S-07)

- **Pass condition:** Valid calibration certificate recorded against unit in this production run.
- **Fail condition:** 3 failed calibration attempts with no valid certificate.
- **Fail action:** Hard-stop raised. Supervisor disposition required.
- **Disposition outcomes:** rework (allows new attempt cycle), reject (advances to terminal-rejected), escalate.

### QC_SIGNOFF_GATE (S-09)

- **Pass condition:** Supervisor signs off on QC inspection record.
- **Fail condition:** Supervisor refuses sign-off or raises QC finding.
- **Fail action:** Hard-stop raised. Decision by supervisor or manager.
- **Disposition outcomes:** rework (returns to S-08), reject (advances to terminal-rejected), escalate.

---

## Hard-Block Dependency: GENEALOGY_LOCK (S-10)

- GENEALOGY_LOCK (S-10) has a hard-block dependency on QC_SIGNOFF_GATE (S-09).
- GENEALOGY_LOCK cannot execute unless QC_SIGNOFF_GATE is in status `PASS`.
- Once GENEALOGY_LOCK executes, the unit's genealogy record is frozen and cannot be modified.
- If a post-lock error is discovered, a new unit provision (S-02) is required. The original
  locked record is retained as-is for audit purposes.

---

## Authority Levels

| Level    | Role               | Permissions                                      |
|----------|--------------------|--------------------------------------------------|
| Operator | Factory floor      | Advance S-03 → S-06, S-08; scan parts           |
| Supervisor | Line supervisor  | Clear hard-stops; sign off S-09; disposition S-07 failures |
| Manager  | Factory manager    | Authorize S-13; escalate dispositions; override rework limits |

Authority is enforced by the backend. The frontend indicates authority gating but
enforcement lives in the API layer.

---

## Terminal States

| State             | Description                                      |
|-------------------|--------------------------------------------------|
| `SHIPPED`         | Successful production completion (S-14)          |
| `REJECTED`        | Unit rejected at gate (QC or calibration); record immutable |
| `SCRAPPED`        | Manager decision to scrap; record immutable      |

Once a unit reaches any terminal state, its production record is immutable. No stage
transitions, no annotation changes, no record modifications are permitted.

---

## Stage State Values

Each stage in a production run carries one of the following status values:

| Status      | Meaning                                        |
|-------------|------------------------------------------------|
| `pending`   | Stage not yet started                          |
| `active`    | Stage is currently in progress                 |
| `complete`  | Stage successfully completed                   |
| `blocked`   | Hard-stop is active; advancement blocked       |
| `skipped`   | Stage skipped (not used in v0; reserved)       |
| `failed`    | Stage failed; disposition required             |
