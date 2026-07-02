# Task: Create frontend API client for all D4/D5 endpoints

## Parent Spec
specs/factory-flow-board-ui.md

## Phase
phase-ui

## Status
pending

## Layer
backend

## Description
Create `frontend/src/api/factoryApi.ts` — the complete API client for all D4 read
endpoints and D5 action endpoints. All API calls use `VITE_API_BASE_URL` (default
http://localhost:8000). No raw fetch in component files — all calls go through this module.

Functions required:
- fetchHealth() → HealthResponse
- fetchDataContractStatus() → DataContractStatus
- fetchStages() → FactoryStage[]
- fetchUnits() → FactoryUnit[]
- fetchUnit(id) → FactoryUnit
- fetchEvents() → FactoryEvent[]
- fetchUsers() → FactoryUser[]
- fetchParts() → FactoryPart[]
- fetchRefStandards() → FactoryRefStd[]
- postResetState() → ResetStateResponse
- postScanPart(unitId, req) → ActionResponse
- postReallocatePart(unitId, req) → ActionResponse
- postHardwareGate(unitId, req) → ActionResponse
- postCalibration(unitId, req) → ActionResponse
- postCalibrationDisposition(unitId, req) → ActionResponse
- postQcSignoff(unitId, req) → ActionResponse
- postCloudBackup(unitId, req) → ActionResponse
- postPackage(unitId, req) → ActionResponse
- postShip(unitId, req) → ActionResponse
- postTransition(unitId, req) → ActionResponse

All functions throw ApiError (with status: number, message: string) on non-2xx HTTP.
Note: action endpoints returning HTTP 200 with status="blocked" are NOT errors — return
the ActionResponse normally. Only HTTP 4xx/5xx throw.

## Acceptance Criteria
- [ ] frontend/src/api/factoryApi.ts created with all listed functions
- [ ] All imports use types from frontend/src/types/factory.ts
- [ ] ApiError exported so components can catch and display error messages
- [ ] POST functions use Content-Type: application/json

## Files Likely Affected
- frontend/src/api/factoryApi.ts (CREATE)

## Blocked By
- tasks/factory-flow-board-ui-001.md
