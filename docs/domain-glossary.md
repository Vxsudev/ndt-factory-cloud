# Domain Glossary — ndt-factory-cloud

**Phase:** D2 — Factory Domain Model Freeze
**Status:** FROZEN
**Date:** 2026-06-30

All factory domain terms used in specifications, code, and documentation must conform
to these definitions. Do not invent alternative terms or synonyms without a model update.

---

## Factory Cloud

The software system — this repository — that digitizes, tracks, and controls the
production of AstraX/NDT handheld devices. The Factory Cloud enforces the production
spine, records factory events, and exposes the factory state to operators, supervisors,
and managers through a web interface and API.

In v0, the Factory Cloud runs as a Docker Compose deployment with a React frontend
and FastAPI backend.

---

## Digital Factory

The concept of representing a physical factory's production activities (equipment, parts,
units, personnel) as structured digital records within the Factory Cloud. The Digital
Factory is the union of all active factory entities and their recorded state.

---

## MES (Manufacturing Execution System)

A class of software systems that connect, monitor, and control manufacturing operations.
The ndt-factory-cloud is a lightweight, purpose-built MES for AstraX/NDT device
production. It is not a general-purpose MES platform.

---

## Factory Unit

A single AstraX/NDT handheld device moving through the production spine. A factory unit:
- Is created at stage S-02 (UNIT_PROVISIONED).
- Carries a placeholder serial until production serial-number policy is defined.
- Has exactly one active production run at any time.
- Becomes immutable upon reaching a terminal state.

In v0, placeholder format: `UNIT-0001`, `UNIT-0002`, etc. These are not production
serial numbers.

---

## Order

A production order that authorizes the manufacture of one or more factory units.
An order:
- Enters the system at stage S-01 (ORDER_RECEIVED).
- Contains the requested quantity, product variant, and customer reference.
- Remains open until all its factory units reach terminal states.

In v0, placeholder format: `ORDER-0001`, `ORDER-0002`, etc.

---

## Genealogy Serial

The full record of a factory unit's identity: which parts were installed, in which
sequence, by which operators, at what time. The genealogy serial is the audit trail
that links a physical device to every component and production event in its history.

The genealogy serial is frozen at stage S-10 (GENEALOGY_LOCK).

---

## Serialized Part

A physical component (tube, PCB, battery, etc.) that carries a unique identifier
tracked through the production process. A serialized part is allocated to a factory
unit before installation and is scan-confirmed during assembly.

In v0, placeholder formats: `PART-TUBE-0001`, `PART-PCB-0001`, etc.

---

## Allocation

The act of reserving one or more serialized parts from inventory for a specific factory
unit and order. Allocation occurs at stage S-03 (PARTS_ALLOCATED). A part that is
allocated to one unit cannot be concurrently allocated to another.

---

## Assembly Scan

The process of confirming part installation by scanning part and unit identifiers.
Assembly scanning occurs starting at stage S-04 (ASSEMBLY_OPEN). A scan confirms
that a specific serialized part is installed in a specific factory unit.

---

## Hard-Stop

A blocking condition in the production spine that prevents all subsequent stage
advancement until explicitly resolved by an authorized actor. Hard-stops are raised
automatically by the system (e.g., on calibration failure) or manually by operators
and supervisors. See `docs/factory-flow-model.md` for the full list of hard-stop
conditions and clearance authorities.

---

## Gate

A checkpoint stage in the production spine that requires a specific pass condition
to be met before the unit may advance. Gates enforce quality and safety requirements.
The two gates in the v0 spine are:
- CALIBRATION_GATE (S-07)
- QC_SIGNOFF_GATE (S-09)

---

## Rework

A disposition outcome following a gate failure, in which the factory unit is returned
to an earlier stage for corrective action. Rework is authorized by a supervisor or
manager. All rework events are recorded in the unit's production history.

---

## Supervisor Disposition

A mandatory decision required from a supervisor when an automated gate fails or a
hard-stop cannot be cleared by an operator. Supervisor disposition outcomes are:
`rework`, `reject`, or `escalate`. Disposition is recorded with supervisor identity
and timestamp.

---

## Calibration Attempt

A single execution of the calibration procedure on a factory unit. The system records
attempt number, timestamp, technician identity, and result (pass/fail). A maximum of
3 calibration attempts are permitted per production run before a supervisor disposition
is required.

---

## Calibration Certificate

A record generated upon a successful calibration attempt that certifies the factory
unit's calibration parameters met specification. The calibration certificate is required
for CALIBRATION_GATE to pass. The certificate is stored in the unit's production record.

---

## QC Sign-Off

The formal approval action by a supervisor at QC_SIGNOFF_GATE (S-09), indicating that
the factory unit has passed quality control inspection. A QC sign-off records the
supervisor identity, timestamp, and inspection outcome. Without a QC sign-off, the unit
cannot proceed to GENEALOGY_LOCK.

---

## Cloud Provisioning

The act of creating cloud-side resources (credentials, device identities, storage entries)
for a factory unit and pushing those credentials to the physical device. Cloud provisioning
occurs at stage S-11 (CLOUD_PROVISION). In v0, this is mocked; no real cloud calls are made.

---

## Cloud Backup

The confirmed transfer of initial device data and configuration to cloud storage, verifying
that the device is reachable and the cloud association is active. Cloud backup occurs at
stage S-12 (CLOUD_BACKUP). In v0, this is mocked.

---

## Shipped Terminal State

The final, immutable state of a factory unit that has completed all 14 production stages
and been authorized for shipment by a manager at stage S-13 (FINAL_REVIEW), then formally
marked shipped at S-14 (SHIPPED). Once a unit reaches the SHIPPED terminal state, its
production record cannot be modified under any circumstances.
