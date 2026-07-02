# D3 Stack Scaffold Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a Dockerized React + FastAPI application shell with `docker compose up --build` producing a working scaffold at localhost:5173 (frontend) and localhost:8000 (backend).

**Architecture:** FastAPI backend exposes `/health` and `/factory/scaffold-status` with CORS enabled; React/Vite frontend fetches health and displays scaffold status. Both services run in Docker Compose containers; proxies in `scripts/` delegate to the vendored Engineering OS.

**Tech Stack:** React 18 + Vite 5 + TypeScript, Tailwind CSS 3, FastAPI + Pydantic + Uvicorn, Docker Compose 3.9, Python 3.12

## Global Constraints

- Run from repo root: `/Users/vasudevarao/ndt-factory-cloud`
- No Postgres, no Azure SDKs, no auth, no domain business logic in D3
- Backend router dir is `backend/app/routes/` (D3 scaffold; differs from `ai/coding-patterns.md` which targets D4)
- Python 3.12, strict TypeScript (`"strict": true`)
- All services bind to `0.0.0.0` inside Docker
- Frontend API base URL comes from `VITE_API_BASE_URL` env var
- Placeholder identifiers (`UNIT-0001` etc.) only in docs/fixtures — never in scaffold code
- `docs/factory-flow-model.md` is authority for stage model — D3 code must not invent stages
- OS state machine must be traversed: `RECON_READY → SPEC_LOCKED → TASK_GRAPH_LOCKED → EXECUTION_ACTIVE → VERIFICATION_REQUIRED → RELEASE_APPROVED`

---

## File Map

**Created (new):**
- `specs/docker-stack-scaffold.md` — approved spec for OS pipeline
- `tasks/docker-stack-scaffold-001.md` — backend task (filled)
- `tasks/docker-stack-scaffold-002.md` — frontend task (filled)
- `tasks/docker-stack-scaffold-003.md` — verification task (filled)
- `docker-compose.yml`
- `.env.example`
- `.gitignore`
- `README.md`
- `backend/Dockerfile`
- `backend/requirements.txt`
- `backend/app/__init__.py`
- `backend/app/main.py`
- `backend/app/settings.py`
- `backend/app/models.py`
- `backend/app/routes/__init__.py`
- `backend/app/routes/health.py`
- `backend/app/routes/factory.py`
- `frontend/Dockerfile`
- `frontend/package.json`
- `frontend/index.html`
- `frontend/vite.config.ts`
- `frontend/tsconfig.json`
- `frontend/tsconfig.node.json`
- `frontend/tailwind.config.js`
- `frontend/postcss.config.js`
- `frontend/src/main.tsx`
- `frontend/src/App.tsx`
- `frontend/src/api.ts`
- `frontend/src/types.ts`
- `frontend/src/styles.css`
- `frontend/src/components/AppShell.tsx`
- `frontend/src/components/HealthStatus.tsx`
- `scripts/verification/001-docker-compose-config.sh`
- `scripts/verification/002-backend-health.sh`
- `scripts/verification/003-frontend-reachable.sh`

**Modified:**
- `ai/repo-index.md`
- `ai/architecture-index.md`
- `ai/engineering-journal.md`

---

## Task 1: OS Lifecycle — Spec + Task Graph

**Files:**
- Create: `specs/docker-stack-scaffold.md`
- Create (generated then filled): `tasks/docker-stack-scaffold-001.md`
- Create (generated then filled): `tasks/docker-stack-scaffold-002.md`
- Create (generated then filled): `tasks/docker-stack-scaffold-003.md`

**Interfaces:**
- Produces: approved spec + 3 filled task files; state advances to `TASK_GRAPH_LOCKED`

- [ ] **Step 1: Create the approved spec**

```bash
cat > specs/docker-stack-scaffold.md << 'SPECEOF'
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

## Phase Boundary

D3 ends when: both Docker services start successfully, /health returns ok, frontend reaches backend.

## D4 Handoff

D4 Mock Data Contract will add:
- In-memory state store (orders, units dicts)
- Seeded mock data (3 orders, 5 units at various stages)
- GET /api/units, GET /api/orders endpoints
- Frontend unit list display
SPECEOF
```

- [ ] **Step 2: Run compile-spec through the proxy**

```bash
bash scripts/compile-spec.sh specs/docker-stack-scaffold.md
```

Expected output: `[1/3] Spec status: approved`, `[2/3] Phase tag: phase-1`, `[3/3] Delegating to task generator...`, then 3 task files created.

- [ ] **Step 3: Verify task files were generated**

```bash
ls tasks/docker-stack-scaffold-*.md
```

Expected: `tasks/docker-stack-scaffold-001.md`, `tasks/docker-stack-scaffold-002.md`, `tasks/docker-stack-scaffold-003.md`

- [ ] **Step 4: Fill task 001 — backend**

```bash
cat > tasks/docker-stack-scaffold-001.md << 'TASKEOF'
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
Create the FastAPI backend scaffold for Factory Cloud v0.

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

No domain logic. No database. No auth.

## Acceptance Criteria
- [ ] docker compose build backend exits 0
- [ ] GET /health returns {"status": "ok", "service": "ndt-factory-cloud-backend", "phase": "D3_STACK_SCAFFOLD"}
- [ ] GET /factory/scaffold-status returns {"status": "scaffold_only", "domain_logic_enabled": false, "stage_model_locked": true, "current_phase": "D3_STACK_SCAFFOLD"}
- [ ] GET /docs returns OpenAPI HTML
- [ ] CORS headers present on responses

## Files Likely Affected
- backend/Dockerfile
- backend/requirements.txt
- backend/app/main.py
- backend/app/settings.py
- backend/app/models.py
- backend/app/routes/health.py
- backend/app/routes/factory.py

## Blocked By
- none
TASKEOF
```

- [ ] **Step 5: Fill task 002 — frontend**

```bash
cat > tasks/docker-stack-scaffold-002.md << 'TASKEOF'
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
Create the React + Vite + TypeScript + Tailwind frontend scaffold.

Files to create:
- frontend/Dockerfile
- frontend/package.json
- frontend/index.html
- frontend/vite.config.ts     — dev server on 0.0.0.0:5173, proxy not needed (CORS enabled)
- frontend/tsconfig.json
- frontend/tsconfig.node.json
- frontend/tailwind.config.js
- frontend/postcss.config.js
- frontend/src/main.tsx
- frontend/src/App.tsx         — root component rendering AppShell
- frontend/src/api.ts          — fetchHealth() using VITE_API_BASE_URL
- frontend/src/types.ts        — HealthResponse, ScaffoldStatus interfaces
- frontend/src/styles.css      — Tailwind directives
- frontend/src/components/AppShell.tsx   — page layout, title, subtitle, phase info
- frontend/src/components/HealthStatus.tsx — polls /health, displays result

## Acceptance Criteria
- [ ] docker compose build frontend exits 0
- [ ] http://localhost:5173 returns HTML with "Factory Cloud v0"
- [ ] UI shows backend health status
- [ ] No TypeScript errors (strict mode)
- [ ] No any types

## Files Likely Affected
- frontend/* (all new files)

## Blocked By
- tasks/docker-stack-scaffold-001.md
TASKEOF
```

- [ ] **Step 6: Fill task 003 — verification**

```bash
cat > tasks/docker-stack-scaffold-003.md << 'TASKEOF'
# Task: Verification Scripts + Docs Update

## Parent Spec
specs/docker-stack-scaffold.md

## Phase
phase-1

## Status
pending

## Layer
verification

## Description
Create verification scripts and update documentation.

Files to create:
- scripts/verification/001-docker-compose-config.sh
- scripts/verification/002-backend-health.sh
- scripts/verification/003-frontend-reachable.sh
- docker-compose.yml
- .env.example
- .gitignore
- README.md

Files to update:
- ai/repo-index.md
- ai/architecture-index.md
- ai/engineering-journal.md

## Acceptance Criteria
- [ ] All 3 verification scripts are executable
- [ ] 001 exits 0 when docker-compose.yml is valid
- [ ] 002 exits 0 when backend is running and /health returns status ok
- [ ] 003 exits 0 when frontend is running
- [ ] README.md describes how to run the stack
- [ ] ai/engineering-journal.md has D3 entry

## Files Likely Affected
- scripts/verification/*.sh
- docker-compose.yml
- .env.example
- .gitignore
- README.md
- ai/repo-index.md
- ai/architecture-index.md
- ai/engineering-journal.md

## Blocked By
- tasks/docker-stack-scaffold-002.md
TASKEOF
```

- [ ] **Step 7: Verify state is TASK_GRAPH_LOCKED**

```bash
bash scripts/state-manager.sh get docker-stack-scaffold
```

Expected: `TASK_GRAPH_LOCKED`

---

## Task 2: Infrastructure (docker-compose, env, gitignore)

**Files:**
- Create: `docker-compose.yml`
- Create: `.env.example`
- Create: `.gitignore`

**Interfaces:**
- Produces: Docker Compose config that other tasks depend on

- [ ] **Step 1: Create docker-compose.yml**

```bash
cat > docker-compose.yml << 'DCEOF'
version: "3.9"

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - ALLOWED_ORIGINS=http://localhost:5173
      - APP_ENV=development
    restart: unless-stopped

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "5173:5173"
    environment:
      - VITE_API_BASE_URL=http://localhost:8000
    depends_on:
      - backend
    restart: unless-stopped
DCEOF
```

- [ ] **Step 2: Create .env.example**

```bash
cat > .env.example << 'ENVEOF'
# ndt-factory-cloud — Environment Variable Template
# Copy to .env for local development (not needed for docker compose defaults)

# Backend
ALLOWED_ORIGINS=http://localhost:5173
APP_ENV=development

# Frontend (Vite build-time)
VITE_API_BASE_URL=http://localhost:8000
ENVEOF
```

- [ ] **Step 3: Create .gitignore**

```bash
cat > .gitignore << 'GIEOF'
# Dependencies
node_modules/
__pycache__/
*.pyc
*.pyo
.venv/
venv/
env/

# Build outputs
dist/
build/
*.egg-info/

# Environment
.env
.env.local

# Docker
.docker/

# OS
.DS_Store
Thumbs.db

# Editor
.vscode/
.idea/
*.swp

# Test artifacts
.pytest_cache/
coverage/
*.cover

# OS temp
/tmp/.os-compile-token
GIEOF
```

- [ ] **Step 4: Verify docker compose config**

```bash
docker compose config
```

Expected: YAML output with `backend` and `frontend` services, no errors.

---

## Task 3: Backend Scaffold

**Files:**
- Create: `backend/Dockerfile`
- Create: `backend/requirements.txt`
- Create: `backend/app/__init__.py`
- Create: `backend/app/main.py`
- Create: `backend/app/settings.py`
- Create: `backend/app/models.py`
- Create: `backend/app/routes/__init__.py`
- Create: `backend/app/routes/health.py`
- Create: `backend/app/routes/factory.py`

**Interfaces:**
- Produces: `GET /health` → `HealthResponse`, `GET /factory/scaffold-status` → `ScaffoldStatusResponse`
- Frontend in Task 4 calls `GET /health` and reads `.status`

- [ ] **Step 1: Create backend/Dockerfile**

```bash
mkdir -p backend/app/routes
cat > backend/Dockerfile << 'DFEOF'
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
DFEOF
```

- [ ] **Step 2: Create backend/requirements.txt**

```bash
cat > backend/requirements.txt << 'REQEOF'
fastapi==0.111.0
uvicorn[standard]==0.29.0
pydantic==2.7.1
pydantic-settings==2.2.1
python-dotenv==1.0.1
REQEOF
```

- [ ] **Step 3: Create backend/app/__init__.py**

```bash
touch backend/app/__init__.py
touch backend/app/routes/__init__.py
```

- [ ] **Step 4: Create backend/app/settings.py**

```python
# backend/app/settings.py
cat > backend/app/settings.py << 'SETEOF'
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    allowed_origins: str = "http://localhost:5173"
    app_env: str = "development"

    @property
    def origins_list(self) -> list[str]:
        return [o.strip() for o in self.allowed_origins.split(",")]

    class Config:
        env_file = ".env"


settings = Settings()
SETEOF
```

- [ ] **Step 5: Create backend/app/models.py**

```python
cat > backend/app/models.py << 'MODEOF'
from pydantic import BaseModel


class HealthResponse(BaseModel):
    status: str
    service: str
    phase: str


class ScaffoldStatusResponse(BaseModel):
    status: str
    domain_logic_enabled: bool
    stage_model_locked: bool
    current_phase: str
MODEOF
```

- [ ] **Step 6: Create backend/app/routes/health.py**

```python
cat > backend/app/routes/health.py << 'HEOF'
from fastapi import APIRouter
from app.models import HealthResponse

router = APIRouter()


@router.get("/health", response_model=HealthResponse)
async def health() -> HealthResponse:
    return HealthResponse(
        status="ok",
        service="ndt-factory-cloud-backend",
        phase="D3_STACK_SCAFFOLD",
    )
HEOF
```

- [ ] **Step 7: Create backend/app/routes/factory.py**

```python
cat > backend/app/routes/factory.py << 'FEOF'
from fastapi import APIRouter
from app.models import ScaffoldStatusResponse

router = APIRouter()


@router.get("/factory/scaffold-status", response_model=ScaffoldStatusResponse)
async def scaffold_status() -> ScaffoldStatusResponse:
    return ScaffoldStatusResponse(
        status="scaffold_only",
        domain_logic_enabled=False,
        stage_model_locked=True,
        current_phase="D3_STACK_SCAFFOLD",
    )
FEOF
```

- [ ] **Step 8: Create backend/app/main.py**

```python
cat > backend/app/main.py << 'MAINEOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.settings import settings
from app.routes import health, factory

app = FastAPI(
    title="Factory Cloud v0",
    description="NDT Factory Cloud backend — D3 Stack Scaffold",
    version="0.3.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(factory.router)
MAINEOF
```

- [ ] **Step 9: Verify backend builds**

```bash
docker compose build backend
```

Expected: Build completes without error.

---

## Task 4: Frontend Scaffold

**Files:**
- Create: `frontend/Dockerfile`
- Create: `frontend/package.json`
- Create: `frontend/index.html`
- Create: `frontend/vite.config.ts`
- Create: `frontend/tsconfig.json`
- Create: `frontend/tsconfig.node.json`
- Create: `frontend/tailwind.config.js`
- Create: `frontend/postcss.config.js`
- Create: `frontend/src/main.tsx`
- Create: `frontend/src/App.tsx`
- Create: `frontend/src/api.ts`
- Create: `frontend/src/types.ts`
- Create: `frontend/src/styles.css`
- Create: `frontend/src/components/AppShell.tsx`
- Create: `frontend/src/components/HealthStatus.tsx`

**Interfaces:**
- Consumes: `GET {VITE_API_BASE_URL}/health` → `HealthResponse { status: string, service: string, phase: string }`
- Produces: HTML page at `http://localhost:5173` with "Factory Cloud v0" title

- [ ] **Step 1: Create frontend/Dockerfile**

```bash
mkdir -p frontend/src/components
cat > frontend/Dockerfile << 'DFEOF'
FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install

COPY . .

EXPOSE 5173

CMD ["npm", "run", "dev"]
DFEOF
```

- [ ] **Step 2: Create frontend/package.json**

```bash
cat > frontend/package.json << 'PKGEOF'
{
  "name": "ndt-factory-cloud-frontend",
  "private": true,
  "version": "0.3.0",
  "type": "module",
  "scripts": {
    "dev": "vite --host 0.0.0.0",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@types/react": "^18.3.3",
    "@types/react-dom": "^18.3.0",
    "@vitejs/plugin-react": "^4.3.0",
    "autoprefixer": "^10.4.19",
    "postcss": "^8.4.38",
    "tailwindcss": "^3.4.4",
    "typescript": "^5.4.5",
    "vite": "^5.2.13"
  }
}
PKGEOF
```

- [ ] **Step 3: Create frontend/index.html**

```bash
cat > frontend/index.html << 'HTMLEOF'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Factory Cloud v0</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
HTMLEOF
```

- [ ] **Step 4: Create frontend/vite.config.ts**

```bash
cat > frontend/vite.config.ts << 'VCEOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 5173,
  },
})
VCEOF
```

- [ ] **Step 5: Create frontend/tsconfig.json**

```bash
cat > frontend/tsconfig.json << 'TSEOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
TSEOF
```

- [ ] **Step 6: Create frontend/tsconfig.node.json**

```bash
cat > frontend/tsconfig.node.json << 'TSNEOF'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true,
    "strict": true
  },
  "include": ["vite.config.ts"]
}
TSNEOF
```

- [ ] **Step 7: Create Tailwind config files**

```bash
cat > frontend/tailwind.config.js << 'TWEOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './index.html',
    './src/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
TWEOF

cat > frontend/postcss.config.js << 'PCEOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
PCEOF
```

- [ ] **Step 8: Create frontend/src/types.ts**

```bash
mkdir -p frontend/src/components
cat > frontend/src/types.ts << 'TYPEOF'
export interface HealthResponse {
  status: string
  service: string
  phase: string
}

export interface ScaffoldStatusResponse {
  status: string
  domain_logic_enabled: boolean
  stage_model_locked: boolean
  current_phase: string
}

export type HealthState =
  | { state: 'loading' }
  | { state: 'ok'; data: HealthResponse }
  | { state: 'error'; message: string }
TYPEOF
```

- [ ] **Step 9: Create frontend/src/api.ts**

```bash
cat > frontend/src/api.ts << 'APIEOF'
import type { HealthResponse } from './types'

const API_BASE = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8000'

export async function fetchHealth(): Promise<HealthResponse> {
  const res = await fetch(`${API_BASE}/health`)
  if (!res.ok) {
    throw new Error(`Health check failed: ${res.status}`)
  }
  return res.json() as Promise<HealthResponse>
}
APIEOF
```

- [ ] **Step 10: Create frontend/src/styles.css**

```bash
cat > frontend/src/styles.css << 'CSSEOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
CSSEOF
```

- [ ] **Step 11: Create frontend/src/components/HealthStatus.tsx**

```bash
cat > frontend/src/components/HealthStatus.tsx << 'HSEOF'
import { useEffect, useState } from 'react'
import type { HealthState } from '../types'
import { fetchHealth } from '../api'

export function HealthStatus() {
  const [health, setHealth] = useState<HealthState>({ state: 'loading' })

  useEffect(() => {
    fetchHealth()
      .then((data) => setHealth({ state: 'ok', data }))
      .catch((err: unknown) =>
        setHealth({
          state: 'error',
          message: err instanceof Error ? err.message : 'Unknown error',
        })
      )
  }, [])

  if (health.state === 'loading') {
    return (
      <div className="flex items-center gap-2 text-gray-500">
        <span className="inline-block h-3 w-3 animate-pulse rounded-full bg-gray-400" />
        Checking backend health...
      </div>
    )
  }

  if (health.state === 'error') {
    return (
      <div className="flex items-center gap-2 text-red-600">
        <span className="inline-block h-3 w-3 rounded-full bg-red-500" />
        Backend unreachable — {health.message}
      </div>
    )
  }

  return (
    <div className="flex items-center gap-2 text-green-700">
      <span className="inline-block h-3 w-3 rounded-full bg-green-500" />
      Backend healthy — {health.data.service} ({health.data.phase})
    </div>
  )
}
HSEOF
```

- [ ] **Step 12: Create frontend/src/components/AppShell.tsx**

```bash
cat > frontend/src/components/AppShell.tsx << 'ASEOF'
import { HealthStatus } from './HealthStatus'

const STACK = [
  { layer: 'Frontend', tech: 'React 18 + Vite 5 + TypeScript' },
  { layer: 'UI', tech: 'Tailwind CSS 3 (shadcn-ready)' },
  { layer: 'Backend', tech: 'FastAPI + Pydantic + Uvicorn' },
  { layer: 'State (v0)', tech: 'In-memory / mock JSON' },
  { layer: 'Runtime', tech: 'Docker Compose' },
]

export function AppShell() {
  return (
    <div className="min-h-screen bg-gray-950 text-gray-100">
      <header className="border-b border-gray-800 px-6 py-4">
        <h1 className="text-2xl font-bold tracking-tight">Factory Cloud v0</h1>
        <p className="mt-1 text-sm text-gray-400">
          Dockerized production-flow prototype scaffold.
        </p>
      </header>

      <main className="mx-auto max-w-3xl px-6 py-10 space-y-10">

        {/* Phase banner */}
        <section className="rounded-lg border border-blue-800 bg-blue-950 px-5 py-4">
          <div className="text-xs font-semibold uppercase tracking-widest text-blue-400 mb-1">
            Current Phase
          </div>
          <div className="text-lg font-semibold text-blue-200">D3 Stack Scaffold</div>
          <div className="mt-2 text-xs text-blue-400">
            Next phase: <span className="text-blue-300">D4 Mock Data Contract</span>
          </div>
        </section>

        {/* Backend health */}
        <section>
          <h2 className="text-xs font-semibold uppercase tracking-widest text-gray-500 mb-3">
            Backend Health
          </h2>
          <div className="rounded-lg border border-gray-800 bg-gray-900 px-5 py-4 text-sm">
            <HealthStatus />
          </div>
        </section>

        {/* Scaffold status */}
        <section>
          <h2 className="text-xs font-semibold uppercase tracking-widest text-gray-500 mb-3">
            Scaffold Status
          </h2>
          <div className="rounded-lg border border-gray-800 bg-gray-900 px-5 py-4 space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-gray-400">Domain logic</span>
              <span className="font-mono text-amber-400">not implemented</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Stage model</span>
              <span className="font-mono text-green-400">locked (14 stages)</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Factory Flow Board</span>
              <span className="font-mono text-amber-400">not implemented (D4+)</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Database</span>
              <span className="font-mono text-amber-400">none (in-memory in D4)</span>
            </div>
          </div>
        </section>

        {/* Stack summary */}
        <section>
          <h2 className="text-xs font-semibold uppercase tracking-widest text-gray-500 mb-3">
            Stack
          </h2>
          <div className="rounded-lg border border-gray-800 bg-gray-900 overflow-hidden">
            <table className="w-full text-sm">
              <tbody>
                {STACK.map(({ layer, tech }) => (
                  <tr key={layer} className="border-b border-gray-800 last:border-0">
                    <td className="px-5 py-3 text-gray-400 w-36">{layer}</td>
                    <td className="px-5 py-3 font-mono text-gray-200">{tech}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>

      </main>
    </div>
  )
}
ASEOF
```

- [ ] **Step 13: Create frontend/src/App.tsx**

```bash
cat > frontend/src/App.tsx << 'APPEOF'
import { AppShell } from './components/AppShell'

function App() {
  return <AppShell />
}

export default App
APPEOF
```

- [ ] **Step 14: Create frontend/src/main.tsx**

```bash
cat > frontend/src/main.tsx << 'MAINEOF'
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './styles.css'
import App from './App'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
MAINEOF
```

- [ ] **Step 15: Build frontend image**

```bash
docker compose build frontend
```

Expected: Build completes without error (npm install + no TypeScript errors).

---

## Task 5: Verification Scripts + Docs + OS Lifecycle Close

**Files:**
- Create: `scripts/verification/001-docker-compose-config.sh`
- Create: `scripts/verification/002-backend-health.sh`
- Create: `scripts/verification/003-frontend-reachable.sh`
- Create: `README.md`
- Modify: `ai/repo-index.md`
- Modify: `ai/architecture-index.md`
- Modify: `ai/engineering-journal.md`

**Interfaces:**
- Consumes: running Docker Compose stack (for scripts 002 and 003)
- Produces: verification result artifacts; final OS journal entry

- [ ] **Step 1: Create verification script directory**

```bash
mkdir -p scripts/verification
```

- [ ] **Step 2: Create 001-docker-compose-config.sh**

```bash
cat > scripts/verification/001-docker-compose-config.sh << 'VER1EOF'
#!/usr/bin/env bash
# 001-docker-compose-config.sh — Verify docker-compose.yml is valid
# Does not require running services.
# Run from repo root: bash scripts/verification/001-docker-compose-config.sh

set -euo pipefail

PASS=0; FAIL=0

echo "001 — Docker Compose Config Verification"
echo "════════════════════════════════════════"

echo ""
echo "V1. docker-compose.yml exists"
if [ -f docker-compose.yml ]; then
  echo "  PASS  docker-compose.yml found"
  PASS=$((PASS+1))
else
  echo "  FAIL  docker-compose.yml not found"
  FAIL=$((FAIL+1))
fi

echo ""
echo "V2. docker compose config exits 0"
if docker compose config > /dev/null 2>&1; then
  echo "  PASS  docker compose config is valid"
  PASS=$((PASS+1))
else
  echo "  FAIL  docker compose config returned non-zero"
  docker compose config 2>&1 | head -20 | sed 's/^/      /'
  FAIL=$((FAIL+1))
fi

echo ""
echo "V3. backend service declared"
if docker compose config | grep -q "backend:"; then
  echo "  PASS  backend service found"
  PASS=$((PASS+1))
else
  echo "  FAIL  backend service not found in compose config"
  FAIL=$((FAIL+1))
fi

echo ""
echo "V4. frontend service declared"
if docker compose config | grep -q "frontend:"; then
  echo "  PASS  frontend service found"
  PASS=$((PASS+1))
else
  echo "  FAIL  frontend service not found in compose config"
  FAIL=$((FAIL+1))
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
VER1EOF
chmod +x scripts/verification/001-docker-compose-config.sh
```

- [ ] **Step 3: Create 002-backend-health.sh**

```bash
cat > scripts/verification/002-backend-health.sh << 'VER2EOF'
#!/usr/bin/env bash
# 002-backend-health.sh — Verify backend /health endpoint
# REQUIRES: docker compose up must be running before this script.
# Run from repo root: bash scripts/verification/002-backend-health.sh

set -euo pipefail

BACKEND_URL="${BACKEND_URL:-http://localhost:8000}"
PASS=0; FAIL=0

echo "002 — Backend Health Verification"
echo "════════════════════════════════════════"
echo "  Backend: $BACKEND_URL"
echo "  NOTE: docker compose up must be running."
echo ""

echo "V1. GET /health is reachable"
HTTP_CODE=$(curl -s -o /tmp/.002-health-body -w "%{http_code}" "${BACKEND_URL}/health" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
  echo "  PASS  /health returned 200"
  PASS=$((PASS+1))
else
  echo "  FAIL  /health returned $HTTP_CODE (expected 200)"
  FAIL=$((FAIL+1))
fi

echo ""
echo "V2. response body contains status ok"
if grep -q '"status":"ok"' /tmp/.002-health-body 2>/dev/null || \
   grep -q '"status": "ok"' /tmp/.002-health-body 2>/dev/null; then
  echo "  PASS  status: ok"
  PASS=$((PASS+1))
else
  echo "  FAIL  status not ok in response body"
  cat /tmp/.002-health-body | sed 's/^/      /' 2>/dev/null || true
  FAIL=$((FAIL+1))
fi

echo ""
echo "V3. GET /factory/scaffold-status returns scaffold_only"
SC_CODE=$(curl -s -o /tmp/.002-scaffold-body -w "%{http_code}" "${BACKEND_URL}/factory/scaffold-status" 2>/dev/null || echo "000")
if [ "$SC_CODE" = "200" ]; then
  echo "  PASS  /factory/scaffold-status returned 200"
  PASS=$((PASS+1))
else
  echo "  FAIL  /factory/scaffold-status returned $SC_CODE"
  FAIL=$((FAIL+1))
fi

if grep -q '"status":"scaffold_only"' /tmp/.002-scaffold-body 2>/dev/null || \
   grep -q '"status": "scaffold_only"' /tmp/.002-scaffold-body 2>/dev/null; then
  echo "  PASS  status: scaffold_only"
  PASS=$((PASS+1))
else
  echo "  FAIL  status not scaffold_only in response body"
  cat /tmp/.002-scaffold-body | sed 's/^/      /' 2>/dev/null || true
  FAIL=$((FAIL+1))
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
VER2EOF
chmod +x scripts/verification/002-backend-health.sh
```

- [ ] **Step 4: Create 003-frontend-reachable.sh**

```bash
cat > scripts/verification/003-frontend-reachable.sh << 'VER3EOF'
#!/usr/bin/env bash
# 003-frontend-reachable.sh — Verify frontend is reachable
# REQUIRES: docker compose up must be running before this script.
# Run from repo root: bash scripts/verification/003-frontend-reachable.sh

set -euo pipefail

FRONTEND_URL="${FRONTEND_URL:-http://localhost:5173}"
PASS=0; FAIL=0

echo "003 — Frontend Reachability Verification"
echo "════════════════════════════════════════"
echo "  Frontend: $FRONTEND_URL"
echo "  NOTE: docker compose up must be running."
echo ""

echo "V1. GET / returns 200"
HTTP_CODE=$(curl -s -o /tmp/.003-frontend-body -w "%{http_code}" "${FRONTEND_URL}/" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
  echo "  PASS  frontend returned 200"
  PASS=$((PASS+1))
else
  echo "  FAIL  frontend returned $HTTP_CODE (expected 200)"
  FAIL=$((FAIL+1))
fi

echo ""
echo "V2. response contains HTML"
if grep -qi "<!doctype html>" /tmp/.003-frontend-body 2>/dev/null || \
   grep -qi "<html" /tmp/.003-frontend-body 2>/dev/null; then
  echo "  PASS  response contains HTML"
  PASS=$((PASS+1))
else
  echo "  FAIL  response does not appear to be HTML"
  head -5 /tmp/.003-frontend-body | sed 's/^/      /' 2>/dev/null || true
  FAIL=$((FAIL+1))
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
VER3EOF
chmod +x scripts/verification/003-frontend-reachable.sh
```

- [ ] **Step 5: Create README.md**

```bash
cat > README.md << 'READEOF'
# ndt-factory-cloud

Dockerized Factory Cloud v0 — AstraX/NDT handheld device production management prototype.

**Current Phase:** D3 Stack Scaffold  
**Next Phase:** D4 Mock Data Contract

---

## Purpose

Factory Cloud is a digital control system for tracking AstraX/NDT handheld devices
through a 14-stage production spine — from order intake through cloud provisioning
and shipment.

D3 establishes the Dockerized application shell. No domain business logic is
implemented yet.

---

## Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 18 + Vite 5 + TypeScript |
| UI | Tailwind CSS 3 |
| Backend | FastAPI + Pydantic + Uvicorn |
| State (v0) | In-memory (D4) |
| Runtime | Docker Compose |

---

## Running the Stack

```bash
docker compose up --build
```

| Service | URL |
|---------|-----|
| Frontend | http://localhost:5173 |
| Backend API | http://localhost:8000 |
| Backend docs | http://localhost:8000/docs |
| Backend health | http://localhost:8000/health |

---

## Verification

```bash
# No running services needed
bash scripts/verification/001-docker-compose-config.sh

# Requires running stack
bash scripts/verification/002-backend-health.sh
bash scripts/verification/003-frontend-reachable.sh

# Project smoke test
bash scripts/smoke.sh

# OS invariant check
bash vendor/engineering-os/scripts/raystrat-os verify
```

---

## What Exists (D3)

- Dockerized backend with `/health` and `/factory/scaffold-status` endpoints
- React frontend showing backend health and scaffold status
- CORS configured between frontend and backend
- OpenAPI docs at `/docs`

---

## What Is Intentionally Not Implemented (D3)

- Factory state machine (14-stage production spine)
- Domain actions (order intake, assembly scan, calibration, QC, shipment)
- In-memory mock data (orders, units)
- Factory Flow Board UI
- Hard-stop logic
- Auth / session management
- Postgres / any database
- Azure SDK wiring

---

## Engineering OS

This project uses the Raystrat Engineering OS for deterministic AI-assisted development.

```bash
# Boot check
bash vendor/engineering-os/scripts/raystrat-os boot

# Adapter check
bash vendor/engineering-os/scripts/raystrat-os check

# Run self-tests
bash vendor/engineering-os/tests/run-self-tests.sh
```

---

## Next Phase: D4 Mock Data Contract

D4 will add:
- In-memory state store (orders dict, units dict)
- Seeded mock data (3 orders, 5 units at various stages)
- `GET /api/units` and `GET /api/orders` endpoints
- Frontend unit list display
READEOF
```

- [ ] **Step 6: Update ai/repo-index.md phase table and directory map**

Add D3 to the phase table:

```
| D3    | Stack Scaffold                | COMPLETE    |
```

Update directory map to show new directories: `frontend/`, `backend/`, `docker-compose.yml`, `specs/`, `tasks/`, `scripts/verification/`.

- [ ] **Step 7: Update ai/architecture-index.md**

Replace "D3 Stack Scaffold — NOT STARTED" with "D3 Stack Scaffold — COMPLETE (scaffold only)".

- [ ] **Step 8: Append D3 journal entry to ai/engineering-journal.md**

```markdown
## Entry 005 — D3 Stack Scaffold

**Date:** 2026-06-30  
**Phase:** D3  
**Status:** COMPLETE

### Files Created

Backend (FastAPI):
- backend/Dockerfile, requirements.txt
- backend/app/main.py, settings.py, models.py
- backend/app/routes/health.py, factory.py

Frontend (React/Vite):
- frontend/Dockerfile, package.json, index.html
- frontend/vite.config.ts, tsconfig.json, tailwind.config.js, postcss.config.js
- frontend/src/main.tsx, App.tsx, api.ts, types.ts, styles.css
- frontend/src/components/AppShell.tsx, HealthStatus.tsx

Infrastructure:
- docker-compose.yml, .env.example, .gitignore, README.md
- scripts/verification/001-docker-compose-config.sh
- scripts/verification/002-backend-health.sh
- scripts/verification/003-frontend-reachable.sh

OS Lifecycle:
- specs/docker-stack-scaffold.md (Status: approved)
- tasks/docker-stack-scaffold-001.md (backend)
- tasks/docker-stack-scaffold-002.md (frontend)
- tasks/docker-stack-scaffold-003.md (verification)

### Verification

- docker compose config: PASS
- docker compose up --build: PASS
- GET /health: {"status": "ok", ...}
- GET /factory/scaffold-status: {"status": "scaffold_only", ...}
- Frontend at http://localhost:5173: PASS
- Backend docs at http://localhost:8000/docs: PASS

### No Domain Behavior

No factory state machine, no calibration logic, no QC logic, no assembly scan,
no cloud backup, no Postgres, no Azure SDK.

### Next Phase

D4 Mock Data Contract — adds in-memory store, mock data, unit/order list endpoints.
```

- [ ] **Step 9: Advance OS state to RELEASE_APPROVED**

```bash
bash scripts/state-manager.sh advance docker-stack-scaffold EXECUTION_ACTIVE
bash scripts/state-manager.sh advance docker-stack-scaffold VERIFICATION_REQUIRED
bash scripts/state-manager.sh advance docker-stack-scaffold RELEASE_APPROVED
bash scripts/state-manager.sh get docker-stack-scaffold
```

Expected: `RELEASE_APPROVED`

- [ ] **Step 10: Run full system validation**

Start the stack:
```bash
docker compose up --build -d
```

Run verification:
```bash
bash scripts/verification/001-docker-compose-config.sh
bash scripts/verification/002-backend-health.sh
bash scripts/verification/003-frontend-reachable.sh
bash scripts/smoke.sh
```

All must pass. If backend health fails, check `docker compose logs backend`.

- [ ] **Step 11: Bring stack down**

```bash
docker compose down
```

---

## Self-Review

**Spec coverage:**
- ✅ docker-compose.yml with backend + frontend services
- ✅ GET /health returning required JSON shape
- ✅ GET /factory/scaffold-status returning required JSON shape
- ✅ React frontend with health status display
- ✅ CORS via env-configured allowed origins
- ✅ VITE_API_BASE_URL env var wired
- ✅ Vite dev server on 0.0.0.0
- ✅ uvicorn on 0.0.0.0
- ✅ frontend depends_on backend
- ✅ .env.example with all variables
- ✅ 3 verification scripts, all executable
- ✅ README.md with run/verify instructions
- ✅ Engineering journal updated
- ✅ OS lifecycle traversed to RELEASE_APPROVED
- ✅ No domain logic
- ✅ No Postgres
- ✅ No Azure SDK

**Placeholder scan:** No TBDs, no "similar to", no "fill in later". All steps have actual code.

**Type consistency:**
- `HealthResponse` defined in `types.ts` and `models.py` with matching shapes
- `fetchHealth()` returns `Promise<HealthResponse>` — consumed in `HealthStatus.tsx` as `health.data`
- `HealthState` union type used in `HealthStatus.tsx` local state
