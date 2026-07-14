# Glossary — UI Comprehension Terms (ndt-factory-cloud)

**Phase:** D9E-1 — Canonical Stage, Failure, Recovery, and Authority Model
**Status:** CANONICAL — OPERATOR_LOCKED THROUGH D9E-0; IMPLEMENTED BY D9E-1
**Date:** 2026-07-14

## Scope and Relationship to `docs/domain-glossary.md`

This is a new, additive glossary scoped to **UI-comprehension terminology** — the words a
first-time reviewer of Current, Attention-First, Workflow-First, or Command-Center will encounter
on screen. It is distinct from, and does not modify, the existing **frozen** (D2A)
`docs/domain-glossary.md`, which remains the authoritative source for factory-wide domain terms
(Order, Production Record, Serialized Part, Allocation, Assembly Scan, Calibration Attempt,
Calibration Reference Standard, Calibration Certificate, QC Sign-Off, Cloud Provisioning, Factory
Data Backup, Ship Terminal State, etc.). Where a term below overlaps with a `domain-glossary.md`
definition (Genealogy, Hard-Stop, Rework, Supervisor Disposition), this glossary's definition is
consistent with — and does not contradict — the frozen one; it simply restates the term in the
shorter, UI-facing form later comprehension work (D9E-3 onward) will use.

For the full stage/failure/recovery/authority model these terms describe, see
`docs/manufacturing-comprehension-model.md`. This glossary defines terms; it does not define
visual/styling rules (that is reserved for D9E-3's design-system and content-language work).

---

## Terms

### Gate
A stage that requires a specific pass condition before a unit may advance, with its own
disposition/rework path on failure. The canonical model has exactly three gates: Stage 9 (Hardware
Checks — Gate 1), Stage 10 (Calibration — Gate 2), Stage 11 (Quality Control — Gate 3).

### Hard block
A blocking condition that prevents all further stage advancement until explicitly resolved by an
authorized actor or an external dependency (e.g. cloud connectivity) returns. Consistent with
`docs/domain-glossary.md`'s "Hard-Stop" definition.

### No override
A condition that cannot be bypassed by any actor or authority. The required prerequisite must
become valid before work can be evaluated again. **No override does not mean that recovery, retry,
re-presentation, or re-check is permanently prohibited** — it means no actor, at any authority
level, may skip past the condition while it remains unresolved. Evidence-backed examples:

- **Stage 10 invalid/expired reference standard:** present a valid, certified standard and run the
  pre-check again — calibration may then proceed.
- **Stage 7 cloud block:** wait for cloud connectivity to return; **the current prototype has no
  recovery action for this stage** (no endpoint exists), so this condition is presently
  unresolvable through the application, not because retry is categorically forbidden but because no
  runtime path currently implements the re-check.
- **Stage 12 cloud-backup block:** wait for cloud connectivity to return, then **Retry Cloud
  Backup** performs a re-check — this is a real, working recovery action, not a hypothetical one.

### Waiting on external dependency
A condition where advancement depends on something outside factory floor authority — currently:
cloud connectivity (Stage 7, Stage 12). No Supervisor, Manager, or QC action can resolve this;
resolution occurs only when the external dependency (the cloud) becomes available again.

### Rework
A disposition outcome that returns a unit to an earlier stage for corrective action (e.g. Stage 10
cap-exceeded → "route back to hardware" → re-enters Stage 9). Consistent with `docs/domain-
glossary.md`'s "Rework" definition. Rework is authorized by a Supervisor or Manager, per the
disposition's own authority requirement.

### Retry
Resubmitting an action at the same stage without a stage change (e.g. a Stage 10 calibration
attempt below the 3-attempt cap, or a Stage 12 cloud-backup resubmission once connectivity
returns). **Retry is not an override.** A no-override condition may still permit retry or
re-evaluation once its underlying prerequisite becomes valid — see "No override" above: the
Stage-10 reference-standard check and the Stage-12 cloud-backup block both permit re-evaluation
once their prerequisite (a valid standard; restored connectivity) is met. Stage 7 is presently
distinct only because **the current prototype lacks a recovery action for that stage**, not
because the underlying condition categorically forbids retry.

### Disposition
A mandatory decision required from a Supervisor or Manager when a gate fails or a hard-stop cannot
be cleared by the immediate operator (e.g. Stage 10's cap-exceeded disposition: route back to
hardware, quarantine, or scrap). Consistent with `docs/domain-glossary.md`'s "Supervisor
Disposition" definition.

### Quarantine
A disposition outcome that sets a unit aside, pending further review, without advancing or
terminating it. As of this canonical model, no exit path from quarantine exists in the current
implementation (see the canonical model's TBD register, T6) — a quarantined unit remains
quarantined until a future capability defines a release path.

### Scrap
A disposition outcome that permanently removes a unit from production (terminal, immutable).
**Scrap requires Manager authorization** — it is never a Floor Manager (Supervisor-tier) action,
even where the Floor Manager surface is the point of entry for the disposition decision. See the
canonical model's Floor-Manager-vs-Manager rule.

### Serialized allocation
The reservation of a specific serialized part for a specific unit and order (Stage 4). An
allocated part may be `allocated_unbound` (reserved but not yet installed) or `allocated_bound`
(scan-confirmed and installed at Stage 5).

### Bound serial
A serialized part that has been scan-confirmed and installed into a specific unit at Assembly
(Stage 5) — the "marrying" of a part to a device's permanent build record.

### Genealogy
The permanent, cumulative build-history record for a unit: every part bound to it, every
reallocation (old and new serials both retained), every calibration attempt, and every gate
result. Consistent with `docs/domain-glossary.md`'s underlying "Production Record" concept.
Genealogy never erases history — a replaced part's original serial remains in the record
alongside its replacement.

### Terminal / immutable
A unit that has reached Shipped, Scrapped, or (documented but not currently reachable) Rejected.
Once terminal, no field, stage, or annotation on the unit's record may be modified — the record
is a permanent, legal document of the unit's production history.

### QC authority
The authority to sign off Quality Control (Stage 11) — a **distinct named authority**, never
folded into Supervisor or Manager authority. QC sign-off additionally requires separation of duty
(see below).

### Separation of duty
The rule that the person signing off Quality Control on a unit may not be the same person who
performed assembly or calibration on that same unit. A Manager may waive this rule for a specific
unit, with a recorded justification (who waived, why, which unit) — the waiver itself becomes part
of the unit's audit record.

---

## Version and Operator-Lock Status

CANONICAL — OPERATOR_LOCKED THROUGH D9E-0; IMPLEMENTED BY D9E-1. Definitions above must agree with
`docs/manufacturing-comprehension-model.md` and must not contradict `docs/domain-glossary.md`. Any
future addition or correction to this glossary requires the same evidence-and-operator-lock
standard established by D9E-0/D9E-1 — no term may be added or redefined by invention.
