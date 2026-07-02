# Debug Playbook — ndt-factory-cloud

## Purpose

This document defines a deterministic debugging procedure for system failures in
ndt-factory-cloud. When something breaks, follow this procedure rather than attempting
ad-hoc investigation.

---

## Step 1 — Classify the Failure

Determine which layer the failure is in:

| Symptom                               | Layer           |
|---------------------------------------|-----------------|
| Docker container fails to start        | Runtime / Docker |
| Backend returns unexpected HTTP status | Backend / Domain |
| Frontend renders incorrect state       | Frontend / API client |
| Stage advance rejected unexpectedly    | Domain logic / Gate |
| Hard-stop raised with no clear cause   | Domain logic     |
| Calibration count mismatch             | Calibration domain |
| Genealogy lock fails or locks wrong    | Genealogy domain |
| Verification script fails              | Implementation / Test |

---

## Step 2 — Collect Evidence

Before making any change:

1. Copy the exact error message / stack trace.
2. Identify the failing file and line number.
3. Identify the factory stage and unit involved (if domain failure).
4. Check if the failure is reproducible (single unit or all units).

---

## Step 3 — Read the Authority Documents

For domain failures, re-read:
- `docs/factory-flow-model.md` — stage rules and gate conditions
- `ai/product-invariants.md` — which invariant may be violated
- `ai/runtime-contracts.md` — which contract may be broken

Do not debug from memory. Read the authority documents.

---

## Step 4 — Isolate the Cause

- Is the failure in a guard condition (gate, hard-stop check)?
- Is the failure in a state mutation (stage advance, calibration record)?
- Is the failure in a response serialization (Pydantic / TypeScript type mismatch)?
- Is the failure in the Docker runtime (port conflict, environment variable missing)?

Narrow to one root cause before making a fix.

---

## Step 5 — Fix and Verify

1. Make the minimal fix that addresses the root cause.
2. Run verification (`bash scripts/smoke.sh` in D0-D2; `scripts/verification/*.sh` in D3+).
3. Confirm the failure is gone and no regressions are introduced.

---

## Step 6 — Record the Incident (for non-trivial failures)

If the failure revealed a gap in invariant enforcement, a missing contract, or a
model inconsistency, record it in `ai/incidents/`. Incident entries are append-only.

---

## Hard-Stop Debug Checklist

When a hard-stop is raised unexpectedly:

- [ ] Check unit's calibration attempt count (≤ 3?)
- [ ] Check QC sign-off status on the unit
- [ ] Check that previous stage is `complete` (not still `active`)
- [ ] Check actor authority level against required authority
- [ ] Check unit is not in a terminal state

---

## Genealogy Lock Debug Checklist

When genealogy lock fails:

- [ ] Confirm QC_SIGNOFF_GATE (S-09) status is `PASS`
- [ ] Confirm unit has no active hard-stops
- [ ] Confirm unit is not already locked (idempotency check)
- [ ] Confirm unit is not in a terminal state
