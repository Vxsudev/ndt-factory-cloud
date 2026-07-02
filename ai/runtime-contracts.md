# Runtime Contracts — ndt-factory-cloud

## Overview

These contracts define the runtime boundary rules that must hold across all phases.
They are architectural facts, not aspirational goals.

---

## Contract 1 — Docker Compose Is the Only Supported Runtime (v0)

**Boundary:** All services must run inside Docker Compose in v0.

**Permitted:** Running `docker compose up` from the repository root.

**Forbidden:** Running backend or frontend directly on the host outside containers
in any environment that is not a developer's local machine with an explicit override
documented in the README.

**Why:** Container-first posture ensures environment parity and simplifies v0 deployment.

**Status:** RATIFIED

---

## Contract 2 — Frontend Communicates via REST API Only

**Boundary:** The React frontend communicates with the backend only via HTTP REST API.

**Permitted:** `fetch` / Axios calls to backend API endpoints.

**Forbidden:** Direct database access from frontend, shared in-process function calls
between frontend and backend modules, WebSocket connections (reserved for later phase).

**Why:** Clean API boundary ensures backend authority over all state transitions and
enables independent deployment in later phases.

**Status:** RATIFIED

---

## Contract 3 — Backend Owns All Factory State Transitions

**Boundary:** Backend FastAPI application is the sole authority for advancing factory
unit stage state.

**Permitted:** Backend route handlers validating actor authority, checking hard-stops,
recording transitions, and advancing stage state.

**Forbidden:** Any frontend code that mutates factory state without a backend round-trip.
Any CLI or direct database operation that bypasses business rule enforcement.

**Why:** Centralized enforcement ensures audit logging, hard-stop checks, and authority
gates apply to every transition without exception.

**Status:** RATIFIED

---

## Contract 4 — Mock State in v0; Postgres Deferred

**Boundary:** v0 uses in-memory / JSON file state. No Postgres, no SQL, no ORM.

**Permitted:** Python dict, list, or JSON file as backing store for factory state.
Pydantic models for data structure validation.

**Forbidden:** SQLAlchemy imports, Alembic migration files, Postgres connection strings,
or any database driver in v0 code.

**Why:** Keeps v0 simple and immediately runnable. Postgres is a D4+ introduction.

**Status:** RATIFIED

---

## Contract 5 — Cloud-Neutral Posture in v0

**Boundary:** No Azure SDKs, Azure credentials, or Azure-specific infrastructure in v0.

**Permitted:** Stub/mock implementations for cloud provisioning and cloud backup stages.
Return values that simulate cloud responses.

**Forbidden:** `azure-*` Python packages, Azure connection strings, Azure Managed Identity
wiring, Azure IoT Hub SDK calls.

**Why:** Cloud vendor selection is a D4+ decision. v0 must run fully offline.

**Status:** RATIFIED

---

## Contract 6 — Environment Variables Are Container-Scoped

**Boundary:** All configuration that varies by environment (API URLs, feature flags,
secrets) must be passed via environment variables defined in `docker-compose.yml` or
a `.env` file. Never hardcoded.

**Permitted:** `os.environ.get("SOME_VAR")` in backend; `import.meta.env.VITE_*` in
frontend (Vite convention).

**Forbidden:** Hardcoded host names, ports, API keys, or connection strings in
application code.

**Why:** Required for environment portability and secret hygiene.

**Status:** RATIFIED
