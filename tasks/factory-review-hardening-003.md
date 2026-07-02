# Task: Harden event trace with unit filtering and all-events toggle

## Parent Spec
specs/factory-review-hardening.md

## Phase
phase-demo-readiness

## Status
done

## Layer
frontend

## Description
Update EventTrace.tsx and FactoryFlowBoard.tsx to show unit-filtered events when a unit
is selected (that unit's events first), with an "All events" toggle to see the full list.
Pass selectedUnitId to EventTrace to enable the filtering.

## Acceptance Criteria
- [ ] EventTrace accepts selectedUnitId prop
- [ ] When unit selected: unit's events shown at top, then remaining events
- [ ] "Show all events" toggle to collapse/expand full 25-event view
- [ ] Default view shows unit events (if any) + 10 most recent others
- [ ] Event count label updated to reflect filtered vs total
- [ ] FactoryFlowBoard passes selectedUnitId to EventTrace

## Files Likely Affected
- frontend/src/components/EventTrace.tsx (UPDATE)
- frontend/src/components/FactoryFlowBoard.tsx (UPDATE — pass selectedUnitId)

## Blocked By
- tasks/factory-review-hardening-001.md
