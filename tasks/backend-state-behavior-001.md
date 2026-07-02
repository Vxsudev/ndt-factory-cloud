# Task: Implement in-memory state store and D5 Pydantic models

## Parent Spec
specs/backend-state-behavior.md

## Phase
phase-backend

## Status
complete

## Layer
backend

## Description
Create `backend/app/state_store.py` — the in-memory state singleton for D5.
Loads factory_units, parts, users, reference_standards, events from data/*.json
on startup. Provides get_state(), reset_state(), get_unit(), update_unit(),
append_event(), next_event_id(). Never writes back to JSON files.

Update `backend/app/models.py` to add all D5 Pydantic request/response models:
ScanPartRequest, ReallocatePartRequest, HardwareGateRequest, CalibrationRequest,
CalibrationDispositionRequest, QcSignoffRequest, CloudBackupRequest,
TransitionRequest, PackageRequest, ShipRequest, ActionResponse.

## Acceptance Criteria
- [ ] state_store.py exists with all required functions
- [ ] get_state() loads and caches state from data/*.json
- [ ] reset_state() reloads from JSON (in-memory, no file writes)
- [ ] append_event() appends to state["events"] and updates unit["event_ids"]
- [ ] next_event_id() returns EVENT-D5-XXXX format
- [ ] All D5 request models exist in models.py
- [ ] ActionResponse has status, unit_id, current_stage_id, current_status, message, event_id, blocked_reason, no_override

## Files Likely Affected
- backend/app/state_store.py (created)
- backend/app/models.py (updated with D5 request/response models)

## Blocked By
- none
