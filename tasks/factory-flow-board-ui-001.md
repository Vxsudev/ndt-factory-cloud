# Task: Add TypeScript types for D4/D5 data shapes

## Parent Spec
specs/factory-flow-board-ui.md

## Phase
phase-ui

## Status
pending

## Layer
database

## Description
Create `frontend/src/types/factory.ts` with all TypeScript types required to represent
D4/D5 API responses in the frontend. Types must match the Pydantic response model shapes
from backend/app/models.py exactly (no `any`). This is the single source of frontend type
truth — all components import from here.

Types required:
- FactoryStage — id, number, name, stage_type, is_gate, is_external, is_separable, hard_stop_controls
- FactoryUnit — id, order_id, current_stage_id, current_stage_number, current_status,
  blocked_reason, block_type, no_override, part_allocations, calibration_summary, qc_summary,
  cloud_status, package_ship_status, event_ids, genealogy_serial, genealogy
- FactoryEvent — id, unit_id, event_type, stage_id, actor_user_id, message, severity, timestamp
- FactoryUser — id, name, authority_tier, can_override, can_qc_signoff
- FactoryPart — id, serial_number, part_type, current_status
- FactoryRefStd — id, standard_type, can_be_used_for_calibration, status_label
- DataContractStatus — status, phase, stage_count, unit_count
- ActionResponse — status, unit_id, current_stage_id, current_status, message,
  event_id, blocked_reason, no_override
- ResetStateResponse — status, message

## Acceptance Criteria
- [ ] frontend/src/types/factory.ts created with all required types
- [ ] No `any` types in type definitions
- [ ] Types imported in at least one component without TypeScript error

## Files Likely Affected
- frontend/src/types/factory.ts (CREATE)

## Blocked By
- none
