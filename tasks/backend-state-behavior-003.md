# Task: Implement action API routes and register in main.py

## Parent Spec
specs/backend-state-behavior.md

## Phase
phase-backend

## Status
complete

## Layer
backend

## Description
Create `backend/app/routes/actions.py` — all 11 POST endpoints.
Each route calls the corresponding workflow_rules function.
Error handling: 404 on missing unit (re-raised from workflow_rules),
409 on illegal state transition, 422 on invalid shape (Pydantic).

Update `backend/app/main.py` to include the actions router (version 0.5.0).

POST /factory/units/{unit_id}/actions/scan-part
POST /factory/units/{unit_id}/actions/reallocate-part
POST /factory/units/{unit_id}/actions/hardware-gate
POST /factory/units/{unit_id}/actions/calibration
POST /factory/units/{unit_id}/actions/calibration-disposition
POST /factory/units/{unit_id}/actions/qc-signoff
POST /factory/units/{unit_id}/actions/cloud-backup
POST /factory/units/{unit_id}/actions/package
POST /factory/units/{unit_id}/actions/ship
POST /factory/units/{unit_id}/actions/transition
POST /factory/dev/reset-state

## Acceptance Criteria
- [ ] actions.py exists with all 11 routes
- [ ] All routes return ActionResponse on success/blocked
- [ ] Missing unit → 404 (HTTPException from workflow_rules)
- [ ] Terminal unit transition → 409
- [ ] POST /factory/dev/reset-state returns {"status": "ok", "message": "State reset from seed JSON"}
- [ ] main.py registers actions router, version 0.5.0
- [ ] All D4 read-only endpoints still work after router registration

## Files Likely Affected
- backend/app/routes/actions.py (created)
- backend/app/main.py (updated to register actions router, version 0.5.0)

## Blocked By
- tasks/backend-state-behavior-002.md
