# Spec: Docker Stack Scaffold

## Status
approved

## Phase
phase-1

## Purpose

Create the Dockerized application shell for Factory Cloud v0 (D3).
The output is a running scaffold at localhost:5173 (frontend) and localhost:8000 (backend).
No domain business logic is implemented in this phase.

## Scope

- Docker Compose service definition (backend + frontend)
- FastAPI scaffold with /health and /factory/scaffold-status endpoints
- React + Vite + TypeScript + Tailwind scaffold with health status display
- Environment variable configuration via .env.example
- Verification scripts confirming Docker and HTTP endpoints

## Non-Goals (D3)

- Factory state machine logic
- 14-stage production spine implementation
- Calibration, QC, assembly, firmware, cloud backup logic
- Postgres or any real database
- Auth / session management
- Azure SDK wiring
- Real mock domain data (order, unit records)
- Factory Flow Board UI
- shadcn/ui component library installation (shadcn-ready structure only)

## Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 18 + Vite 5 + TypeScript |
| UI | Tailwind CSS 3 (shadcn-ready structure) |
| Backend | FastAPI + Pydantic + Uvicorn |
| Config | Environment variables via .env.example |
| Runtime | Docker Compose 3.9 |

## Docker Services

backend:
- Image: built from backend/Dockerfile (Python 3.12-slim)
- Port: 8000:8000
- Command: uvicorn app.main:app --host 0.0.0.0 --port 8000

frontend:
- Image: built from frontend/Dockerfile (node:20-alpine)
- Port: 5173:5173
- depends_on: backend
- Env: VITE_API_BASE_URL=http://localhost:8000

## Data Model Changes

none

## API Surface

GET /health
  Response: {"status": "ok", "service": "ndt-factory-cloud-backend", "phase": "D3_STACK_SCAFFOLD"}

GET /factory/scaffold-status
  Response: {"status": "scaffold_only", "domain_logic_enabled": false, "stage_model_locked": true, "current_phase": "D3_STACK_SCAFFOLD"}

## Frontend Surface

- Page title: Factory Cloud v0
- Subtitle: Dockerized production-flow prototype scaffold.
- Shows: scaffold status, backend health (fetched from /health), stack summary, current phase: D3 Stack Scaffold, next phase: D4 Mock Data Contract
- Does not render Factory Flow Board, stage UI, unit cards, or action panels

## Operational Workflow

1. docker compose up --build
2. Frontend at http://localhost:5173
3. Backend API at http://localhost:8000
4. Backend docs at http://localhost:8000/docs
5. Backend health at http://localhost:8000/health

## Dependencies

none

## Acceptance Criteria

- [ ] docker compose config exits 0
- [ ] docker compose up --build starts both services without error
- [ ] GET http://localhost:8000/health returns {"status": "ok", ...}
- [ ] GET http://localhost:8000/factory/scaffold-status returns scaffold_only
- [ ] GET http://localhost:5173 returns HTML
- [ ] Frontend displays backend health status
- [ ] No domain logic, no Postgres, no Azure SDK in any file

## Verification Scripts

- scripts/verification/001-docker-compose-config.sh
- scripts/verification/002-backend-health.sh
- scripts/verification/003-frontend-reachable.sh

## Boundary

D3 ends when: both Docker services start successfully, /health returns ok, frontend reaches backend.

## D4 Handoff

D4 Mock Data Contract will add:
- In-memory state store (orders, units dicts)
- Seeded mock data (3 orders, 5 units at various stages)
- GET /api/units, GET /api/orders endpoints
- Frontend unit list display
