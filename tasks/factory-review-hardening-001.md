# Task: Harden header, unit queue scenario labels, and stage spine readability

## Parent Spec
specs/factory-review-hardening.md

## Phase
phase-demo-readiness

## Status
done

## Layer
frontend

## Description
Update FactoryFlowBoard.tsx header to show "D8 Review Prototype", "Postgres-backed" badge,
and rename reset button. Update UnitList.tsx to show scenario labels for each seeded unit.
Update StageSpine.tsx for better gate/cloud-block/terminal visual distinction.

## Acceptance Criteria
- [ ] Header shows "D8 Review Prototype" subtitle (replaces "D6 Factory Flow Board")
- [ ] Header shows "Postgres-backed" persistence badge
- [ ] Header reset button says "Reset Demo State"
- [ ] data-d8-demo-readiness attribute present in root div for verification
- [ ] UnitList shows scenario label for each unit (derived from frontend mapping)
- [ ] Blocked units show blocked_reason truncated in queue
- [ ] StageSpine: gates S-09/S-10/S-11 have distinct amber GATE visual
- [ ] StageSpine: cloud-block stages S-07/S-12 show CLOUD BLOCK badge always (not only when active)
- [ ] StageSpine: S-14 always shows TERMINAL badge
- [ ] StageSpine: cloud no-override renders prominently

## Files Likely Affected
- frontend/src/components/FactoryFlowBoard.tsx (UPDATE)
- frontend/src/components/UnitList.tsx (UPDATE)
- frontend/src/components/StageSpine.tsx (UPDATE)

## Blocked By
- none
