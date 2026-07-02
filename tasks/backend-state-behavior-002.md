# Task: Implement workflow rules (domain logic)

## Parent Spec
specs/backend-state-behavior.md

## Phase
phase-backend

## Status
complete

## Layer
backend

## Description
Create `backend/app/workflow_rules.py` — centralizes all D5 domain logic.
Routes call these functions; no business logic lives in route handlers.

Implement:
- scan_part: assembly scan with 5 hard-stop cases
- reallocate_part: supervisor serial swap with audit trail
- record_hardware_gate: stage 9 pass/fail
- record_calibration: stage 10 with 3-attempt cap and reference standard validation
- record_calibration_disposition: supervisor route_back_to_hardware/scrap/quarantine
- qc_signoff: stage 11 with prerequisites and separation-of-duty check
- record_cloud_backup: stage 12 hard-block if cloud unavailable (no_override)
- transition_stage: generic next-stage advancement with guard
- package_unit: stage 13
- ship_unit: stage 14 (requires QC passed + cloud backup confirmed)

Every function must append exactly one event with EVENT-D5-XXXX id.

## Acceptance Criteria
- [ ] All 10 workflow functions exist
- [ ] scan_part hard-stops: wrong_part_type, wrong_serial, unknown_serial, already_used_serial, out_of_sequence
- [ ] calibration: expired or missing-cert reference standard raises hard-stop (no override)
- [ ] calibration: 3rd fail raises supervisor disposition required
- [ ] QC: prerequisite checks (hw gate, calibration cert, STAGE-10 gate_result)
- [ ] QC: separation-of-duty check (signer != assembler, signer != calibration op)
- [ ] cloud_backup: cloud_available=false → blocked, no_override=true
- [ ] every function appends one event with EVENT-D5-XXXX id
- [ ] terminal unit calls return blocked/409 (not modify state)
- [ ] missing unit raises HTTPException(404)

## Files Likely Affected
- backend/app/workflow_rules.py (created)

## Blocked By
- tasks/backend-state-behavior-001.md
