## Feature
factory-flow-board-ui

## Status
approved

## Phase
phase-ui

## Purpose

Build the first usable Factory Flow Board UI for the ndt-factory-cloud Digital Factory
prototype. The UI must let a reviewer see every unit, where each unit is in the 14-stage
flow, which units are blocked, why they are blocked, what action is available at the
current stage, recent event history, and backend response after an action.

This is not a generic dashboard. It is a production-flow control UI for the Digital
Factory.

## Non-Goals

- Frontend-owned workflow rules or transition legality decisions
- Local-only fake transitions
- Postgres, Azure SDK, auth/session management
- Real inventory/cloud/eStore integrations
- Advanced reporting or yield analytics
- Mobile optimization beyond basic responsive layout
- Factory Flow Board is the only page; no routing layer needed in D6

## Source Materials

- docs/factory-flow-model.md — 14-stage canonical spine, gate rules, hard-stop rules
- docs/domain-glossary.md — factory domain terms
- docs/backend-state-behavior-d5.md — D5 action endpoint contracts
- data/stages.json — stage metadata (type, is_gate, is_external)
- data/factory_units.json — unit seed data
- data/users.json — user authority data

## Data Model Changes

No backend data model changes required. All data served by existing D4/D5 endpoints.
Frontend adds new TypeScript type definitions in `frontend/src/types/factory.ts`.

## API Surface

No new backend endpoints in D6. All UI actions call existing D4/D5 endpoints:

GET  /health
GET  /factory/data-contract/status
GET  /factory/stages
GET  /factory/units
GET  /factory/units/{unit_id}
GET  /factory/events
GET  /factory/users
GET  /factory/parts
GET  /factory/reference-standards
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

## Frontend Surface

New frontend files:

- frontend/src/types/factory.ts        — all TypeScript types for D4/D5 data shapes
- frontend/src/api/factoryApi.ts       — all API functions (GET + POST wrappers)
- frontend/src/components/FactoryFlowBoard.tsx — main page layout + data loading
- frontend/src/components/UnitList.tsx           — left column unit queue
- frontend/src/components/StageSpine.tsx         — center 14-stage spine
- frontend/src/components/UnitDetailPanel.tsx    — right column unit detail
- frontend/src/components/ActionPanel.tsx        — right column action forms
- frontend/src/components/EventTrace.tsx         — event/history panel

Updated:
- frontend/src/App.tsx         — render FactoryFlowBoard instead of AppShell
- frontend/index.html          — add D6 marker meta tag for verification

## Acceptance Criteria

1. Factory Flow Board UI page loads at http://localhost:5173
2. Unit list displays all 7 seed units with stage/status/blocked state
3. Selecting a unit shows detail panel and stage spine highlight
4. Stage spine shows all 14 canonical stages in order
5. External stages (1-2) visually distinct (grey)
6. Gate stages (9-11) visually distinct (amber border)
7. Cloud-block stages (7, 12) show CLOUD BLOCK badge when blocked
8. Blocked unit shows red hard-stop indicator with reason
9. NO OVERRIDE badge shown when no_override=true
10. Terminal/shipped unit shows TERMINAL/SHIPPED badge
11. Action panel shows relevant form for current stage
12. Submitting action calls backend; shows response status/message
13. blocked/no_override response displayed clearly without fake-success
14. After every action: unit list, unit detail, and events refresh
15. Event trace shows recent events: id, stage, message, severity, timestamp
16. Reset state button calls POST /factory/dev/reset-state and refreshes all
17. Backend health and data contract status shown in header
18. No frontend-owned workflow legality check present
19. D4 verification (004) still passes
20. D5 verification (005) still passes
21. Smoke passes

## Verification Script

scripts/verification/006-factory-flow-board-ui.sh

## Boundary

This spec covers only D6 Frontend Factory Flow Board.
No backend rule changes. No Postgres. No Azure. No auth.
Stop after D6. Do not continue into D7.
