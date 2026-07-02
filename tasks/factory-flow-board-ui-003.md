# Task: Build Factory Flow Board UI components

## Parent Spec
specs/factory-flow-board-ui.md

## Phase
phase-ui

## Status
pending

## Layer
frontend

## Description
Build all Factory Flow Board frontend components and wire them into App.tsx.

Components:
1. `FactoryFlowBoard.tsx` — root layout. Loads all data on mount (stages, units, events,
   users, parts, ref standards, health, data-contract-status). Manages selected unit state.
   Grid: header (full width), left column (unit list), center (stage spine + unit detail),
   right column (action panel + backend response). Bottom: event trace.

2. `UnitList.tsx` — renders unit queue. Each row: unit id, order id, current stage number
   and name, current status, BLOCKED badge (red) if blocked_reason set, SHIPPED badge (green)
   if terminal. Click selects unit.

3. `StageSpine.tsx` — renders all 14 canonical stages in order. Props: stages, selectedUnit.
   For each stage: stage number, full canonical name (from stages.json), stage type badge,
   visual state: completed (grey), current (highlighted), pending (dim). Special indicators:
   - EXTERNAL badge on stages 1-2 (stage_type="external")
   - GATE badge (amber) on stages with is_gate=true (9, 10, 11)
   - CLOUD BLOCK badge on stages 7 and 12 when unit is blocked there
   - SEPARABLE badge when is_separable=true
   - TERMINAL badge on stage 14
   - NO OVERRIDE badge (red) when unit is blocked at this stage with no_override=true

4. `UnitDetailPanel.tsx` — shows selected unit detail: unit id, order id, genealogy serial,
   current stage/status, blocked reason (if any), part allocations table, calibration summary
   (attempts N/3, passed, certificate), QC summary (signed_off, signed_by), cloud status,
   package/ship status.

5. `ActionPanel.tsx` — shows action forms based on selected unit's current stage:
   - STAGE-05: scan-part form (part_type, serial_number, actor_user_id, station_id)
             + reallocate-part form (old_serial, new_serial, reason, release_reason_code, actor)
   - STAGE-09: hardware-gate form (result pass/fail, actor_user_id, reason optional)
   - STAGE-10: calibration form (result pass/fail, actor_user_id, reference_standard_ids,
               equipment_id) OR calibration-disposition form if cap_exceeded
               (disposition, actor_user_id, reason)
   - STAGE-11: qc-signoff form (actor_user_id, waiver_actor_user_id, waiver_reason optional)
   - STAGE-12: cloud-backup form (cloud_available checkbox, actor_user_id, backup_reference)
   - STAGE-13: package button (actor_user_id)
   - STAGE-14: ship button (actor_user_id, document_refs optional)
   - Secondary: transition form (target_stage_id, actor_user_id, reason) — visually
     secondary/dev-only, label "Backend-Guarded Transition"
   After submit: calls factoryApi POST, shows ActionResponse in backend response panel.
   On success or blocked: refresh units + unit detail + events.

6. `EventTrace.tsx` — shows recent events (last 20) sorted by timestamp descending.
   Each row: event_id, unit_id (or "—"), stage_id, severity badge, message, timestamp.
   Severity color: info=blue, warning=amber, error=red.

Update `frontend/src/App.tsx` to render `<FactoryFlowBoard />` instead of `<AppShell />`.
Update `frontend/index.html` to add `<meta name="app-d6" content="factory-flow-board">`.

## Acceptance Criteria
- [ ] FactoryFlowBoard.tsx renders without TypeScript errors
- [ ] Unit list shows all seed units with stage and blocked state
- [ ] Selecting unit highlights current stage in spine
- [ ] Action panel shows correct form for STAGE-05 (scan-part)
- [ ] Action panel shows correct form for STAGE-10 (calibration)
- [ ] Action panel shows correct form for STAGE-11 (qc-signoff)
- [ ] Action panel shows correct form for STAGE-12 (cloud-backup)
- [ ] Submitting scan-part for UNIT-0001 with correct serial → success response displayed
- [ ] Submitting cloud-backup with cloud_available=false → blocked+no_override displayed
- [ ] Terminal unit (UNIT-0007) shows TERMINAL/SHIPPED badge

## Files Likely Affected
- frontend/src/components/FactoryFlowBoard.tsx (CREATE)
- frontend/src/components/UnitList.tsx (CREATE)
- frontend/src/components/StageSpine.tsx (CREATE)
- frontend/src/components/UnitDetailPanel.tsx (CREATE)
- frontend/src/components/ActionPanel.tsx (CREATE)
- frontend/src/components/EventTrace.tsx (CREATE)
- frontend/src/App.tsx (UPDATE — render FactoryFlowBoard)
- frontend/index.html (UPDATE — add D6 meta tag)

## Blocked By
- tasks/factory-flow-board-ui-002.md
