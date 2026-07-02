# Product Invariants — ndt-factory-cloud

## Context

ndt-factory-cloud is the Digital Factory control system for AstraX/NDT handheld device
production. This repository enforces the production spine from order intake through
shipment.

These invariants are non-negotiable. No capability may violate them. If a proposed
feature conflicts with an invariant, it must be redesigned before a spec is approved.

---

## Invariant 1 — Factory Flow Model Authority

**Statement:** `docs/factory-flow-model.md` is the sole authoritative source for stage
definitions, stage ordering, transition rules, and gate control rules.

**Rationale:** Divergence between the model document and backend/frontend implementation
creates production defects and audit failures.

**Constraint:** Backend stage machine logic and frontend display must reference
`docs/factory-flow-model.md`. No agent may invent, reorder, or remove stages without
an explicit model update directive.

**Status:** RATIFIED

---

## Invariant 2 — Backend Owns State Transitions

**Statement:** Only the backend API may advance factory unit stage state. The frontend
reads state and submits operator actions; it never directly writes stage state.

**Rationale:** Central enforcement ensures that business rules, authority checks, and
audit logging apply to every state transition without exception.

**Constraint:** No client-side code may call stage-advance logic directly. All state
mutations route through the backend REST API.

**Status:** RATIFIED

---

## Invariant 3 — Hard-Stops Are Absolutely Blocking

**Statement:** A hard-stop condition must block all subsequent stage advancement without
exception. No stage may advance past a hard-stop without explicit resolution by an actor
with the required authority level.

**Rationale:** Hard-stops exist to prevent defective units from reaching shipment. Any
bypass — including development shortcuts — defeats the purpose of the control system.

**Constraint:** Backend enforcement of hard-stops must not include debug overrides,
test bypass flags, or authority elevation shortcuts that are accessible in production
builds.

**Status:** RATIFIED

---

## Invariant 4 — Calibration Retry Limit and Reference Standard

**Statement:** Calibration (S-10) has two hard-stop conditions:
(a) An expired or invalid calibration reference standard raises an immediate hard-stop
    with no bypass. Supervisor must obtain a valid standard before any attempt proceeds.
(b) Calibration attempts are capped at 3 per unit per production run. A third failed
    attempt raises a hard-stop and triggers mandatory supervisor disposition. No code
    path may allow a fourth attempt without an explicit new calibration cycle authorized
    by a supervisor.

**Rationale:** (a) Calibration against an invalid reference standard produces invalid
certificates — no override is acceptable. (b) The attempt cap prevents operators from
retrying indefinitely to force a pass on a defective unit.

**Constraint:** Both checks must be enforced server-side. The reference standard
validation must run before each attempt. The attempt counter must be stored server-side
and enforced by the backend. The frontend may display both but must not influence either
check. All attempts (pass and fail) must be retained in the production record.

**Status:** RATIFIED

---

## Invariant 5 — Production Record Is Finalized After QC Pass

**Statement:** Once a factory unit's Quality Control stage (S-11) passes and the QC
sign-off is recorded, the unit's production record is finalized. No parts list, assembly
scan history, firmware version, calibration record, or prior stage records may be
modified after QC pass.

**Rationale:** The production record is the legal and audit record of the device's
production history. Post-QC modification destroys audit integrity and breaks the
separation between the verified record and any subsequent corrective activity.

**Constraint:** If an error is discovered after QC pass, corrective action must be
recorded as a new audit entry under manager authority — it must never overwrite the
original finalized record. The unit's stage advancement to S-12 (Factory Data Backup)
must not proceed unless S-11 is in `complete` status. Backend endpoints must reject
production record modifications for units that have passed QC.

**Status:** RATIFIED

---

## Invariant 6 — Terminal State Immutability

**Statement:** Once a factory unit reaches any terminal state (SHIPPED, REJECTED,
SCRAPPED), its production record becomes immutable. No field may be updated, no stage
may be appended, and no annotation may be added.

**Rationale:** Production records that reach terminal states are legal documents. Post-
terminal modification is a compliance violation.

**Constraint:** Backend record update endpoints must reject any write operation targeting
a unit in a terminal state with a 409 Conflict response.

**Status:** RATIFIED

---

## Invariant 7 — Placeholder Serial Numbers Are Not Production Policy

**Statement:** The identifiers `UNIT-0001`, `ORDER-0001`, `PART-TUBE-0001` and similar
placeholders are test/fixture identifiers only. They are not production serial-number
policy.

**Rationale:** Preventing placeholder formats from leaking into production naming
conventions. Real serial-number policy is outside the scope of this repository.

**Constraint:** Placeholder identifiers must only appear in test fixtures, local dev
seeds, and documentation. No production-facing code may generate identifiers in these
formats.

**Status:** RATIFIED
