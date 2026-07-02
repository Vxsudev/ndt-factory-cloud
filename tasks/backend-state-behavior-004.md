# Task: Add D5 backend status panel to frontend

## Parent Spec
specs/backend-state-behavior.md

## Phase
phase-backend

## Status
complete

## Layer
frontend

## Description
Add a minimal "D5 Backend Behavior" status panel to the existing scaffold UI.
No action buttons or Factory Flow Board.

Create frontend/src/components/D5BackendStatus.tsx:
- Static component (no API fetch required — always shows D5 active state)
- Displays: action API available=true, domain logic enabled=true,
  read-only contract still available=true, Factory Flow Board=not implemented (D6+)

Update frontend/src/components/AppShell.tsx:
- Import D5BackendStatus
- Update phase banner to "D5 Backend State Behavior"
- Update "Next phase" to "D6 Factory Flow Board"
- Add "Backend Behavior" section with D5BackendStatus component
- Update scaffold status rows to reflect D5 state

## Acceptance Criteria
- [ ] D5BackendStatus.tsx exists and compiles
- [ ] AppShell imports and renders D5BackendStatus under "Backend Behavior" heading
- [ ] Phase banner reads "D5 Backend State Behavior"
- [ ] No action buttons or mutation UI added
- [ ] Frontend still loads without errors

## Files Likely Affected
- frontend/src/components/D5BackendStatus.tsx (created)
- frontend/src/components/AppShell.tsx (updated)

## Blocked By
- tasks/backend-state-behavior-003.md
