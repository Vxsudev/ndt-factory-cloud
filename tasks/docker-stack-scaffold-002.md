# Task: Scaffold React/Vite Frontend

## Parent Spec
specs/docker-stack-scaffold.md

## Phase
phase-1

## Status
pending

## Layer
frontend

## Description
Create the React + Vite + TypeScript + Tailwind frontend scaffold for Factory Cloud v0.
Fetches GET /health from backend and displays result. Shows scaffold status, stack summary,
and current phase info. Page title: "Factory Cloud v0".

Files to create:
- frontend/Dockerfile
- frontend/package.json
- frontend/index.html
- frontend/vite.config.ts
- frontend/tsconfig.json
- frontend/tsconfig.node.json
- frontend/tailwind.config.js
- frontend/postcss.config.js
- frontend/src/main.tsx
- frontend/src/App.tsx
- frontend/src/api.ts         — fetchHealth() using VITE_API_BASE_URL
- frontend/src/types.ts       — HealthResponse, ScaffoldStatusResponse, HealthState
- frontend/src/styles.css     — Tailwind directives
- frontend/src/components/AppShell.tsx   — page layout, phase banner, scaffold status, stack table
- frontend/src/components/HealthStatus.tsx — polls /health, displays result with loading/error states

## Acceptance Criteria
- [ ] docker compose build frontend exits 0
- [ ] http://localhost:5173 returns HTML with "Factory Cloud v0"
- [ ] UI displays backend health status (fetched from /health)
- [ ] No TypeScript compile errors (strict: true)
- [ ] No any types used

## Files Likely Affected
- frontend/* (all new files)

## Blocked By
- tasks/docker-stack-scaffold-001.md
