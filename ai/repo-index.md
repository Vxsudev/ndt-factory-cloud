# Repo Index — ndt-factory-cloud

**Phase:** D8C Touch-First Responsive Factory UI — COMPLETE
**Date:** 2026-07-02

This document is the navigation reference for the repository. Read it after the
Engineering OS boot sequence to orient before doing any work.

---

## Repository State Summary

| Phase | Name                          | Status      |
|-------|-------------------------------|-------------|
| D0    | Repository Decision Lock      | COMPLETE    |
| D1C   | Invented OS Cleanup           | COMPLETE    |
| D1D   | OS Vendor Bootstrap (real)    | COMPLETE    |
| D2    | Factory Domain Model Freeze   | COMPLETE    |
| D2A   | Model Drift Correction        | COMPLETE    |
| D3    | Stack Scaffold                | COMPLETE    |
| D4    | Mock Data Contract            | COMPLETE    |
| D5    | Backend State Behavior        | COMPLETE    |
| D6    | Factory Flow Board UI         | COMPLETE    |
| D7    | Persistence / Postgres        | COMPLETE    |
| D8    | Factory Review Hardening      | COMPLETE    |
| D8A   | Light Mode Readability Pass   | COMPLETE    |
| D8B   | Material Design Theme System  | COMPLETE    |
| D8C   | Touch-First Responsive UI     | COMPLETE    |

**D8C touch-first responsive UI is complete.** Breakpoint model (compact <1024px / standard
1024-1599px / large >=1600px via Tailwind `lg:`/`xl:`/`min-[1600px]:`), `.touch-target-primary`
(48px) / `.touch-target-secondary` (44px) utility classes, compact-width pane switcher (Unit
Queue / Detail / Stages / Events tabs) replacing the forced three-column desktop layout,
EventTrace responsive card list below `lg`, prominent blocked_reason/NO OVERRIDE styling,
destructive/supervisor action color differentiation. D8B theme system unchanged. No backend
changes. Fixed a pre-existing latent bug where calibration-cap disposition never rendered
(frontend read a phantom `calibration_status` field; corrected to `calibration_summary`).

---

## Directory Map

```
ndt-factory-cloud/
│
├── CLAUDE.md                    ← Agent entry point. Read first.
├── PROJECT_BOOTSTRAP.md         ← 7-step boot sequence. Read second.
├── ENGINEERING_OS.md            ← Project wrapper; points to vendored OS doctrine.
│
├── vendor/                      ← VENDORED OS CORE (read-only — do not edit)
│   └── engineering-os/          ← Canonical Engineering OS at commit e718eac
│       ├── core-docs/           ← OS doctrine (ENGINEERING_OS.md, spec-compiler, etc.)
│       ├── scripts/             ← OS runtime (compile-spec, generate-tasks, etc.)
│       ├── templates/           ← adapter.config.sh template, state_registry.json template
│       └── tests/               ← OS self-tests (run-self-tests.sh)
│
├── .engineering-os/             ← ADAPTER OVERLAY (project-specific)
│   ├── adapter.config.sh        ← EOS_* variables for ndt-factory-cloud
│   └── invariants/              ← 6 project invariant rules (INV-001 to INV-006)
│
├── docs/                        ← DOMAIN AUTHORITY (not app code)
│   ├── decision-lock.md         ← D0: Locked repository decisions
│   ├── factory-flow-model.md    ← D2A: Authoritative 14-stage production spine
│   ├── domain-glossary.md       ← D2A: Canonical factory domain terms
│   ├── d2a-model-drift-correction.md ← D2A: Drift audit record
│   ├── d1c-invented-os-cleanup.md   ← D1C: Invented OS cleanup record
│   └── os-vendor-integration.md     ← D1D: Vendor integration report
│
├── ai/                          ← PROJECT CONTROL LAYER (Factory Cloud specific)
│   ├── product-invariants.md    ← Non-negotiable factory constraints
│   ├── runtime-contracts.md     ← Runtime boundary rules
│   ├── service-boundaries.md    ← Service ownership rules
│   ├── coding-patterns.md       ← Implementation pattern declarations
│   ├── architecture-index.md    ← Planned system architecture
│   ├── repo-index.md            ← This file
│   ├── engineering-journal.md   ← Append-only capability history
│   ├── state_registry.json      ← Feature pipeline state (empty: {})
│   └── incidents/               ← Integration incident records
│       └── d1d-os-vendor-self-test-failure.md
│
├── scripts/                     ← PROXIES TO OS RUNTIME + project smoke
│   ├── compile-spec.sh          ← Proxy → vendor/engineering-os/scripts/compile-spec.sh
│   ├── generate-tasks.sh        ← Proxy → vendor/engineering-os/scripts/generate-tasks.sh
│   ├── execution-supervisor.sh  ← Proxy → vendor/engineering-os/scripts/execution-supervisor.sh
│   ├── state-manager.sh         ← Proxy → vendor/engineering-os/scripts/state-manager.sh
│   ├── invariant-check.sh       ← Proxy → vendor/engineering-os/scripts/invariant-engine.sh
│   └── smoke.sh                 ← Project smoke script (D1D)
│
├── specs/                       ← Spec artifacts
│   └── phases/                  ← Phase definition files (phase-1, phase-backend, phase-ui)
│
├── tasks/                       ← Task artifacts (empty until D3 features)
│
├── _archive/                    ← Quarantined invented OS artifacts (D1C)
│   └── invented-os-bootstrap-d1c/
│
├── frontend/                    ← React 18 + Vite 5 + TypeScript + Tailwind (D3)
│   ├── Dockerfile
│   ├── package.json
│   ├── vite.config.ts
│   └── src/
│       ├── api.ts               ← fetchHealth() via VITE_API_BASE_URL
│       ├── types.ts             ← HealthResponse, ScaffoldStatusResponse, HealthState
│       ├── types/
│       │   └── factory.ts           ← all TypeScript types (D4/D5 API shapes)
│       ├── api/
│       │   └── factoryApi.ts        ← all API functions (GET + POST)
│       ├── tests/
│       │   └── d8c-touch-responsive.spec.ts ← D8C Playwright browser suite
│       ├── playwright.config.ts     ← D8C Playwright config (minimum devDependency addition)
│       └── components/
│           ├── FactoryFlowBoard.tsx ← root layout + data loading (D6); D8C responsive shell + compact pane switcher
│           ├── UnitList.tsx         ← unit queue with blocked/shipped badges (D6); D8C 48px touch floor
│           ├── StageSpine.tsx       ← 14-stage spine with visual states (D6); unchanged in D8C (already touch-safe)
│           ├── UnitDetailPanel.tsx  ← unit detail fields (D6); D8C prominence + disclosure + calibration_summary fix
│           ├── ActionPanel.tsx      ← backend-backed action forms (D6); D8C 48px buttons + variant colors + calibration_summary fix
│           ├── EventTrace.tsx       ← event history table (D6); D8C responsive card list below lg
│           ├── AppShell.tsx         ← D5 page layout (dead code, not imported, unchanged)
│           ├── HealthStatus.tsx     ← dead code, not imported, unchanged
│           ├── DataContractStatus.tsx ← dead code, not imported, unchanged
│           └── D5BackendStatus.tsx  ← dead code, not imported, unchanged
├── backend/                     ← FastAPI + Pydantic + SQLAlchemy + Alembic (D3/D4/D5/D7)
│   ├── Dockerfile               ← installs postgresql-client, uses entrypoint.sh
│   ├── entrypoint.sh            ← wait-postgres → alembic upgrade head → seed → uvicorn
│   ├── requirements.txt         ← includes sqlalchemy, alembic, psycopg[binary]
│   ├── alembic.ini              ← Alembic config (script_location=alembic)
│   ├── alembic/
│   │   ├── env.py               ← reads DATABASE_URL, targets db_models metadata
│   │   └── versions/
│   │       └── 001_initial_factory_cloud_schema.py
│   └── app/
│       ├── main.py              ← FastAPI app, CORS, router registration (v0.7.0)
│       ├── settings.py          ← Pydantic settings from env (includes DATABASE_URL)
│       ├── models.py            ← D3 + D4 read models + D5 action request/response models
│       ├── data_loader.py       ← loads data/*.json; DATA_DIR env override (static data)
│       ├── db.py                ← SQLAlchemy engine, SessionLocal, get_db (D7)
│       ├── db_models.py         ← 8 ORM table models (D7)
│       ├── seed.py              ← loads data/*.json into DB (D7)
│       ├── repositories.py      ← DB query helpers (D7)
│       ├── state_store.py       ← DB-backed state; same public interface as D5 (D7)
│       ├── workflow_rules.py    ← all domain workflow logic — UNCHANGED from D5
│       └── routes/
│           ├── health.py        ← GET /health
│           ├── factory.py       ← GET /factory/scaffold-status
│           ├── data_contract.py ← 10 GET endpoints; mutable data from DB (D7)
│           └── actions.py       ← 11 POST endpoints; injects DB session (D7)
│
├── data/                        ← Mock JSON data files (D4); ro-mounted in Docker
│   ├── stages.json              ← 14 canonical stages
│   ├── factory_units.json       ← 7+ placeholder units
│   ├── orders.json              ← 5 placeholder orders
│   ├── parts.json               ← 10+ placeholder parts
│   ├── users.json               ← 5 placeholder users
│   ├── model_recipes.json       ← 3 model recipes
│   ├── reference_standards.json ← 3 reference standards
│   └── events.json              ← 10+ audit events
│
├── docker-compose.yml           ← Docker Compose: postgres:5432, backend:8000, frontend:5173
│                                   DATA_DIR=/app/data, DATABASE_URL, volume postgres_data
├── .env.example                 ← Environment variable template
├── .gitignore
├── README.md
│
├── specs/
│   ├── docker-stack-scaffold.md ← D3 spec (Status: approved, Phase: phase-1)
│   ├── mock-data-contract.md    ← D4 spec (Status: approved, Phase: phase-1)
│   └── phases/
│
├── tasks/
│   ├── docker-stack-scaffold-001..003.md  ← D3 tasks (complete)
│   ├── mock-data-contract-001.md  ← D4 backend+data task (complete)
│   ├── mock-data-contract-002.md  ← D4 frontend task (complete)
│   └── mock-data-contract-003.md  ← D4 verification task (complete)
│
├── docs/
│   ├── ...                      ← existing docs unchanged
│   ├── mock-data-contract-d4.md ← D4 data contract documentation
│   ├── backend-state-behavior-d5.md ← D5 workflow behavior documentation
│   ├── factory-flow-board-ui-d6.md  ← D6 UI documentation
│   ├── factory-review-hardening-d8.md ← D8 review hardening documentation
│   ├── demo-walkthrough-d8.md       ← D8 reviewer walkthrough script
│   ├── light-mode-readability-d8a.md ← D8A light mode documentation
│   ├── material-theme-readability-d8b.md ← D8B material theme documentation
│   └── touch-first-responsive-ui-d8c.md ← D8C touch/responsive documentation
│
└── scripts/
    ├── ...                      ← OS proxies (unchanged)
    └── verification/
        ├── 001-docker-compose-config.sh
        ├── 002-backend-health.sh
        ├── 003-frontend-reachable.sh
        ├── 004-data-contract-api.sh  ← D4 API verification (10 checks)
        ├── 005-backend-state-behavior.sh ← D5 workflow verification (26 assertions)
        ├── 006-factory-flow-board-ui.sh  ← D6 UI verification (12 checks)
        ├── 007-persistence-postgres.sh   ← D7 Postgres verification (15 checks)
        ├── 008-demo-readiness.sh         ← D8 demo readiness verification (17 checks)
        ├── 009-light-mode-readability.sh ← D8A light mode verification (18 checks)
        ├── 010-material-theme-readability.sh ← D8B material theme verification (21 checks)
        └── 011-touch-first-responsive-ui.sh ← D8C touch/responsive verification (32 checks + 1 env-skip)
```

---

## Key Authority Documents

| Question                                   | Read this                                              |
|--------------------------------------------|--------------------------------------------------------|
| What are the 14 production stages?         | docs/factory-flow-model.md                             |
| What does "hard-stop" mean?                | docs/domain-glossary.md                                |
| What are the locked decisions?             | docs/decision-lock.md                                  |
| What can the system NOT do?                | ai/product-invariants.md                               |
| What is the stack and runtime posture?     | ai/runtime-contracts.md                                |
| What owns what?                            | ai/service-boundaries.md                               |
| What coding patterns must I follow?        | ai/coding-patterns.md                                  |
| How do I author a spec?                    | vendor/engineering-os/core-docs/spec-generation.md     |
| How do I compile a capability?             | vendor/engineering-os/core-docs/spec-compiler.md       |
| How do I execute tasks?                    | vendor/engineering-os/core-docs/execution-loop-controller.md |
| What invariants does the project enforce?  | .engineering-os/invariants/                            |
| What is the OS adapter config?             | .engineering-os/adapter.config.sh                      |
| What is the history of completed work?     | ai/engineering-journal.md                              |

---

## OS Runtime Commands

```sh
# Validate OS installation
bash vendor/engineering-os/scripts/raystrat-os boot

# Validate adapter configuration
bash vendor/engineering-os/scripts/raystrat-os check

# Run invariant checks
bash vendor/engineering-os/scripts/raystrat-os verify

# Run OS self-tests
bash vendor/engineering-os/tests/run-self-tests.sh

# Run project smoke test
bash scripts/smoke.sh
```

---

## Running the Stack

```sh
docker compose up --build
# Frontend: http://localhost:5173
# Backend:  http://localhost:8000
# API docs: http://localhost:8000/docs
```

## What Is Missing (future work beyond D8)

- Real-time push updates (WebSocket / SSE)
- Full unit history viewer
- Order management UI
- Azure SDK wiring
- Auth / session management
