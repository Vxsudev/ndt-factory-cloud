# Task: Scaffold FastAPI Backend

## Parent Spec
specs/docker-stack-scaffold.md

## Phase
phase-1

## Status
pending

## Layer
backend

## Description
Create the FastAPI backend scaffold for Factory Cloud v0. Exposes two endpoints:
GET /health and GET /factory/scaffold-status. No domain logic. No database. No auth.

Files to create:
- backend/Dockerfile
- backend/requirements.txt
- backend/app/__init__.py
- backend/app/main.py        — FastAPI app with CORS, includes routers
- backend/app/settings.py    — Pydantic settings reading from env
- backend/app/models.py      — HealthResponse, ScaffoldStatusResponse Pydantic models
- backend/app/routes/__init__.py
- backend/app/routes/health.py   — GET /health
- backend/app/routes/factory.py  — GET /factory/scaffold-status

## Acceptance Criteria
- [ ] docker compose build backend exits 0
- [ ] GET /health returns {"status": "ok", "service": "ndt-factory-cloud-backend", "phase": "D3_STACK_SCAFFOLD"}
- [ ] GET /factory/scaffold-status returns {"status": "scaffold_only", "domain_logic_enabled": false, "stage_model_locked": true, "current_phase": "D3_STACK_SCAFFOLD"}
- [ ] GET /docs returns OpenAPI HTML
- [ ] CORS headers present on responses (Access-Control-Allow-Origin)

## Files Likely Affected
- backend/Dockerfile
- backend/requirements.txt
- backend/app/__init__.py
- backend/app/main.py
- backend/app/settings.py
- backend/app/models.py
- backend/app/routes/__init__.py
- backend/app/routes/health.py
- backend/app/routes/factory.py

## Blocked By
- none
