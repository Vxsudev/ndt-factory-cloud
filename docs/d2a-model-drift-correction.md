# D2A — Model Drift Correction

**Date:** 2026-06-30
**Triggered by:** D2A Correction Directive
**Status:** COMPLETE

---

## Summary

D2 produced a factory-flow-model.md and supporting control-layer documents that did not
match the locked canonical 14-stage production spine. This document records the drift
found, the files corrected, and confirms the canonical model is now in place.

---

## Drift Found

### docs/factory-flow-model.md

| Issue | Detail |
|-------|--------|
| Wrong stage 1 | `ORDER_RECEIVED` — should be `Order Created` (S-01, external) |
| Missing stage | `Order Approved` (S-02, external) was entirely absent |
| Invented stage | `UNIT_PROVISIONED` appeared as a domain stage — it is an internal system operation that occurs at S-03 (Order Received by Factory), not a separate stage |
| Wrong S-05 | `TUBE_PRESS` — wrong domain name. Canonical S-05 is `Assembly`. Tube press is an assembly operation, not a stage name. |
| Calibration split | Calibration was incorrectly split into `CALIBRATION_ATTEMPT` (S-06) and `CALIBRATION_GATE` (S-07). Canonical model: single stage `Calibration` at S-10. |
| Missing stages S-06–S-09 | `Software/Firmware Installed`, `Software/Firmware Updated from Cloud`, `Device Provisioned with Cloud`, and `Hardware Checks / Setup` were entirely absent |
| Invented stage `GENEALOGY_LOCK` | Appeared as domain stage S-10 (hard-block dependency type). GENEALOGY_LOCK is not a domain stage. Post-QC production record finalization is a backend domain rule enforced within the stage machine, not a stage in the spine. |
| Wrong S-11 | `CLOUD_PROVISION` at S-11 — canonical S-11 is `Quality Control` |
| Wrong S-12 | `CLOUD_BACKUP` at S-12 — canonical S-12 is `Factory Data Backup to Cloud` (which exists at the right number, but was S-12 in the wrong sequence — QC was missing) |
| Wrong S-13 | `FINAL_REVIEW` (supervisor/manager action) — canonical S-13 is `Package` |
| Wrong S-14 | `SHIPPED` — canonical S-14 is `Ship` (minor naming; corrected for consistency) |
| QC split | QC was split into `QC_INSPECTION` and `QC_SIGNOFF_GATE` — canonical model has a single `Quality Control` stage (S-11) |

### docs/domain-glossary.md

| Issue | Detail |
|-------|--------|
| `Genealogy Serial` | Defined as frozen "at stage S-10 (GENEALOGY_LOCK)" — GENEALOGY_LOCK is not a stage. Corrected to `Production Record` with post-QC finalization rule. |
| `Factory Unit` | Referenced S-02 (UNIT_PROVISIONED) as creation stage — corrected to S-03. |
| `Order` | Referenced S-01 (ORDER_RECEIVED) — order lifecycle now has S-01 (Created), S-02 (Approved), S-03 (Received). |
| `Gate` | Incorrectly listed CALIBRATION_GATE (S-07) and QC_SIGNOFF_GATE (S-09) — corrected to Calibration (S-10) and Quality Control (S-11). |
| `Assembly Scan` | Referenced ASSEMBLY_OPEN (S-04) — corrected to Assembly (S-05). |
| `QC Sign-Off` | Referenced QC_SIGNOFF_GATE (S-09) and GENEALOGY_LOCK — corrected to Quality Control (S-11). |
| `Cloud Provisioning` | Referenced CLOUD_PROVISION (S-11) — corrected to Device Provisioned with Cloud (S-08). |
| `Cloud Backup` | Referenced CLOUD_BACKUP (S-12) — corrected to Factory Data Backup to Cloud (S-12). |
| `Shipped Terminal State` | Referenced FINAL_REVIEW (S-13) — removed FINAL_REVIEW, corrected to Ship (S-14). |
| Missing terms | Added: `Production Record`, `Calibration Reference Standard`. |
| `Calibration Certificate` | Removed incorrect reference to CALIBRATION_GATE. Corrected to reference Calibration (S-10). |

### ai/product-invariants.md

| Issue | Detail |
|-------|--------|
| INV-4 | Only mentioned attempt cap, not reference standard hard-stop. Corrected to include both: (a) invalid reference standard → hard-stop with no override, (b) max 3 attempts → supervisor disposition. |
| INV-5 | Was "GENEALOGY_LOCK Is Permanent" referencing non-existent stage S-10 (GENEALOGY_LOCK). Corrected to "Production Record Is Finalized After QC Pass" — post-QC (S-11) record finalization rule in the stage machine. |

### ai/architecture-index.md

| Issue | Detail |
|-------|--------|
| Router list | Included `genealogy.py` — removed. Added `firmware.py` (S-06/S-07), `backup.py` (S-12). Reframed `cloud.py` for S-08 only. |
| Domain mapping table | "GENEALOGY_LOCK depends on QC gate → genealogy.py" — corrected to "QC pass finalizes production record → stage_machine.py post-QC guard". |
| Added stage coverage table | Maps all 14 stages to their primary router. |

### ai/coding-patterns.md

| Issue | Detail |
|-------|--------|
| Router list | Included `genealogy.py` — removed. Added `firmware.py`, `backup.py`. |
| API path S-06 | `POST /api/units/{id}/calibration — record calibration attempt (S-06)` — corrected to S-10. |
| API path S-09 | `POST /api/units/{id}/qc-signoff — QC sign-off (S-09, supervisor+)` — corrected to S-11. |
| Added endpoints | Reference standard validation endpoint, order approve, order receive. |
| Domain verb `lock` | Removed. Not a domain verb in the canonical model. |
| Naming conventions | Removed `genealogy_lock` / `genealogyLock`. Added `production_record`, `calibration_reference_standard`. |

### ai/spec-to-task-playbook.md

| Issue | Detail |
|-------|--------|
| Genealogy lock section | "When a capability touches genealogy lock: ..." — corrected to "When a capability touches QC pass → production record finalization: ...". |

### ai/debug-playbook.md

| Issue | Detail |
|-------|--------|
| "Genealogy Lock Debug Checklist" | Removed GENEALOGY_LOCK references. Replaced with "Post-QC Stage Advance Debug Checklist". |

---

## Files Not Requiring Correction

| File | Reason |
|------|--------|
| docs/decision-lock.md | No stage-specific references. Phase boundary and stack decisions remain valid. |
| ai/runtime-contracts.md | No stage-specific references. All 6 contracts remain valid. |
| ai/service-boundaries.md | No stage-specific references. Boundary rules remain valid. |
| ai/spec-compiler.md | References docs/factory-flow-model.md generically — no specific stage names. |
| ai/spec-generation.md | No stage-specific references. |
| ai/task-generator.md | No stage-specific references. |
| ai/task-graph.md | No stage-specific references. |
| ai/execution-loop-controller.md | No stage-specific references. |
| ai/execution-orchestrator.md | No stage-specific references. |
| ai/verification-playbook.md | No stage-specific references. |

---

## GENEALOGY_LOCK Status

GENEALOGY_LOCK is **not** a domain stage and is **not** part of the canonical 14-stage
production spine. It does not appear in any corrected document as a stage.

GENEALOGY_LOCK may be used in a **future phase** as an internal implementation concept
for the backend data integrity mechanism that enforces production record immutability
after QC pass. If introduced, it must be clearly marked as an internal backend mechanism,
not a domain stage visible to operators or referenced in the factory flow model.

---

## Canonical 14-Stage Model (Confirmed)

| Stage | Name                                  |
|-------|---------------------------------------|
| S-01  | Order Created                         |
| S-02  | Order Approved                        |
| S-03  | Order Received by Factory             |
| S-04  | Parts Allocated                       |
| S-05  | Assembly                              |
| S-06  | Software / Firmware Installed         |
| S-07  | Software / Firmware Updated from Cloud |
| S-08  | Device Provisioned with Cloud         |
| S-09  | Hardware Checks / Setup               |
| S-10  | Calibration                           |
| S-11  | Quality Control                       |
| S-12  | Factory Data Backup to Cloud          |
| S-13  | Package                               |
| S-14  | Ship                                  |

---

## Remaining Ambiguity

None. The canonical model is unambiguous. All 14 stage names, types, and rules are
defined in `docs/factory-flow-model.md` as of this correction.
