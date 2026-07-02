# Service Boundaries — ndt-factory-cloud

## Planned Directory Structure

```
ndt-factory-cloud/
├── frontend/                — FRONTEND LAYER (React + Vite + TypeScript)
│   ├── src/
│   │   ├── components/      — UI components (shadcn/ui + Tailwind)
│   │   ├── pages/           — Route-level page components
│   │   ├── api/             — API client (fetch wrappers, typed responses)
│   │   └── types/           — Shared TypeScript types
│   ├── index.html
│   ├── vite.config.ts
│   └── package.json
├── backend/                 — BACKEND LAYER (FastAPI + Pydantic)
│   ├── app/
│   │   ├── main.py          — FastAPI app entry point
│   │   ├── routers/         — API route handlers (orders, units, stages, etc.)
│   │   ├── models/          — Pydantic data models
│   │   ├── state/           — In-memory state store (v0)
│   │   └── domain/          — Domain logic (stage machine, gates, hard-stops)
│   ├── requirements.txt
│   └── Dockerfile
├── docs/                    — DOMAIN AUTHORITY (not app code)
│   ├── factory-flow-model.md
│   ├── domain-glossary.md
│   └── decision-lock.md
├── ai/                      — ENGINEERING OS GOVERNANCE (not app code)
├── scripts/                 — OS PIPELINE SCRIPTS
├── specs/                   — SPEC ARTIFACTS (from D3 onwards)
├── tasks/                   — TASK ARTIFACTS (from D3 onwards)
├── docker-compose.yml       — RUNTIME CONFIGURATION
└── .env.example             — Environment variable template
```

---

## Boundary Rules

### frontend/ — Frontend Layer

- Renders the factory operator/supervisor/manager UI.
- Communicates with backend only via HTTP REST API (no direct state access).
- Owns: UI components, API client code, TypeScript types, user interaction logic.
- Does not own: factory state, stage transitions, authority enforcement.
- Does not import from `backend/`.

### backend/ — Backend Layer

- Owns all factory state and business logic.
- Enforces authority levels, hard-stops, calibration retry limits, gate conditions.
- Exposes REST API to the frontend.
- In v0: in-memory / JSON state (no database).
- Does not import from `frontend/`.

### docs/ — Domain Authority Layer

- Contains the factory flow model, domain glossary, and decision lock.
- NOT application code. Not imported by frontend or backend.
- Agents must read these documents before generating specs or tasks.

### ai/ — Engineering OS Governance Layer

- Contains control-layer docs, engineering journal, and state registry.
- NOT application code. Not imported by frontend or backend.
- The governance layer is distinct from application code.

### scripts/ — OS Pipeline Layer

- Pipeline scripts (compile-spec.sh, generate-tasks.sh, execution-supervisor.sh, smoke.sh).
- Not deployed as part of the application.
- Executable by developers and CI.

### docker-compose.yml — Runtime Configuration

- Defines service containers (frontend, backend).
- Source of truth for port assignments, environment variable names, volume mounts.

---

## Cross-Boundary Rules

1. Frontend must not access `backend/` Python modules directly.
2. Backend must not access `frontend/` TypeScript modules directly.
3. Shared types (if needed) live in a `shared/types/` directory to be created in D3.
4. The `ai/` governance layer is never imported by application code.
5. The `docs/` domain authority layer is never imported by application code.
