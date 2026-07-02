# Domain Glossary — ndt-factory-cloud

**Phase:** D2A — Drift-corrected
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

A single AstraX/NDT handheld device moving through the 14-stage production spine. A
factory unit:
- Is provisioned when an order is received by the factory (S-03).
- Carries a placeholder serial until production serial-number policy is defined.
- Has exactly one active production run at any time.
- Becomes immutable upon reaching a terminal state.

In v0, placeholder format: `UNIT-0001`, `UNIT-0002`, etc. These are not production
serial numbers.

---

## Order

A production order that authorizes the manufacture of one or more factory units.
An order lifecycle:
- Created externally (S-01: Order Created).
- Approved externally (S-02: Order Approved).
- Received by the factory system (S-03: Order Received by Factory).
- Remains open until all its factory units reach terminal states.

In v0, placeholder format: `ORDER-0001`, `ORDER-0002`, etc.

---

## Production Record

The full digital record of a factory unit's production history: which parts were
installed, in which sequence, by which actors, at what time, and what results were
recorded at each stage. The production record is the audit trail linking a physical
device to every component, operation, and sign-off in its production history.

The production record is **finalized** when Quality Control (S-11) passes. After QC
pass, the record may not be modified except by explicit corrective action under manager
authority, which creates a new audit entry without overwriting the original.

---

## Serialized Part

A physical component (tube, PCB, battery, etc.) that carries a unique identifier
tracked through the production process. A serialized part is allocated to a factory
unit before installation and is scan-confirmed during assembly.

In v0, placeholder formats: `PART-TUBE-0001`, `PART-PCB-0001`, etc.

---

## Allocation

The act of reserving one or more serialized parts from inventory for a specific factory
unit and order. Allocation occurs at stage S-04 (Parts Allocated). A part that is
allocated to one unit cannot be concurrently allocated to another.

---

## Assembly Scan

The process of confirming part installation by scanning part and unit identifiers.
Assembly scanning occurs at stage S-05 (Assembly). A scan confirms that a specific
serialized part is installed in a specific factory unit.

---

## Hard-Stop

A blocking condition in the production spine that prevents all subsequent stage
advancement until explicitly resolved by an authorized actor. Hard-stops are raised
automatically by the system or manually by supervisors. See `docs/factory-flow-model.md`
for the complete list of hard-stop conditions and clearance authorities.

A calibration hard-stop due to an invalid reference standard has **no override** —
a valid standard must be obtained before the hard-stop can be cleared.

---

## Gate

A stage in the production spine that requires a specific pass condition to be met before
the unit may advance. Gates enforce quality and safety requirements. The two gates in the
canonical spine are:
- **Calibration (S-10)** — valid calibration certificate required; reference standard
  must be valid; max 3 attempts; hard-stop on failure.
- **Quality Control (S-11)** — supervisor/QC inspector sign-off required; verifies
  physical unit and digital record; QC pass finalizes production record.

---

## Rework

A disposition outcome following a gate failure, in which the factory unit is returned
to an earlier stage for corrective action. Rework is authorized by a supervisor or
manager. All rework events are recorded in the unit's production history.

---

## Supervisor Disposition

A mandatory decision required from a supervisor or manager when a gate fails or a
hard-stop cannot be cleared by the immediate operator. Supervisor disposition outcomes
are: `rework`, `reject`, or `escalate`. Disposition is recorded with actor identity
and timestamp.

---

## Calibration Attempt

A single execution of the calibration procedure on a factory unit. Every attempt is
recorded: attempt number, timestamp, technician identity, result (pass/fail), and
measurement data. A maximum of 3 calibration attempts are permitted per production run
before a supervisor disposition is required. Passed and failed attempts are all retained
in the production record.

---

## Calibration Reference Standard

The physical reference instrument used during calibration to verify the unit's calibration
parameters. Before any calibration attempt, the technician must validate the reference
standard's certificate and expiry date. An expired or invalid reference standard raises
an immediate hard-stop with no bypass. The reference standard check is re-run before
each subsequent attempt.

---

## Calibration Certificate

A record generated upon a successful calibration attempt that certifies the factory
unit's calibration parameters met specification. The calibration certificate is the
clean pass record; it does not erase the full attempt history. The certificate is
required for the Calibration gate (S-10) to pass.

---

## QC Sign-Off

The formal approval action by a QC inspector or supervisor at Quality Control (S-11),
indicating that the factory unit has passed quality control inspection. A QC sign-off:
- records actor identity, timestamp, and inspection outcome;
- confirms physical unit matches digital record;
- confirms all prior gates (calibration certificate) are present and valid;
- authorizes the unit to proceed to Factory Data Backup (S-12) and the shipping path.

---

## Cloud Provisioning

The act of creating cloud-side resources (credentials, device identities, storage entries)
for a factory unit and pushing those credentials to the physical device. Cloud provisioning
occurs at stage S-08 (Device Provisioned with Cloud). In v0, this is mocked; no real
cloud calls are made.

---

## Factory Data Backup to Cloud

The confirmed transfer of the unit's complete production record and initial device data
to cloud storage, verifying that the device is reachable and the cloud association is
active. Occurs at stage S-12 (Factory Data Backup to Cloud). In v0, this is mocked.
S-12 cannot proceed until Quality Control (S-11) has passed.

---

## Ship Terminal State

The final, immutable state of a factory unit that has completed all 14 production stages
and been authorized for shipment at stage S-14 (Ship). Once a unit reaches the Ship
terminal state, its production record cannot be modified under any circumstances.
