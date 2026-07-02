# Task: Add DataContractStatus panel to frontend AppShell

## Parent Spec
specs/mock-data-contract.md

## Phase
phase-1

## Status
complete

## Layer
frontend

## Description
Add a minimal data contract panel to the React frontend that fetches
GET /factory/data-contract/status and renders key metrics: phase,
stage_count, unit_count, read_only flag, domain_logic_enabled, and
list of loaded data files. This makes the D4 mock data contract
visible in the browser without building the full Factory Flow Board.

Implementation:
- `frontend/src/components/DataContractStatus.tsx` — new component
  with three display states: loading (pulse animation), error (red),
  ok (metrics table). Reads VITE_API_BASE_URL env for endpoint base.
- `frontend/src/components/AppShell.tsx` — updated to import
  DataContractStatus, add "Data Contract" section above backend health,
  update phase banner to "D4 Mock Data Contract", and add scaffold
  status row for "Data API: read-only (D4)".

No routing, no state management library, no domain mutation UI.

## Acceptance Criteria
- [ ] `frontend/src/components/DataContractStatus.tsx` exists and compiles
- [ ] AppShell renders DataContractStatus under "Data Contract" heading
- [ ] Phase banner reads "D4 Mock Data Contract"
- [ ] Loading state shows animated placeholder
- [ ] Error state renders red error message
- [ ] Ok state shows phase, stage_count, unit_count, read_only, domain_logic_enabled, files
- [ ] No POST/mutation UI added

## Files Likely Affected
- frontend/src/components/DataContractStatus.tsx (created)
- frontend/src/components/AppShell.tsx (modified)

## Blocked By
- tasks/mock-data-contract-001.md
