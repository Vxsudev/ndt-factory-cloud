# Engineering Journal — ndt-factory-cloud

This is the append-only history of engineering work in this repository.
Entries are added after each phase or feature is complete.
Do not modify or delete existing entries.

---

## Entry 001 — D0-D2 Bootstrap

**Date:** 2026-06-30
**Phase:** D0 / D1 / D2
**Status:** COMPLETE

### D0 — Repository Decision Lock

Created `docs/decision-lock.md` locking the following decisions:
- Repo name: `ndt-factory-cloud`
- Stack: React + Vite + TypeScript / FastAPI + Pydantic / Docker Compose
- State: in-memory / mock JSON (v0); Postgres deferred
- Cloud: cloud-neutral posture; Azure-ready structure; no Azure SDKs in v0
- Naming: `UNIT-0001`, `ORDER-0001`, `PART-TUBE-0001` are placeholder identifiers only
- Phase boundary: D3 Stack Scaffold requires a new directive

### D1 — OS Vendor Bootstrap

Created Engineering OS control layer for this repository:

Root documents:
- `CLAUDE.md` — agent entry instruction
- `PROJECT_BOOTSTRAP.md` — full boot sequence for all agents
- `ENGINEERING_OS.md` — OS doctrine adapted for factory cloud context

AI control layer (16 documents):
- `ai/product-invariants.md` — 7 ratified factory invariants
- `ai/runtime-contracts.md` — 6 runtime boundary contracts
- `ai/service-boundaries.md` — frontend/backend/docs/ai/scripts boundary rules
- `ai/coding-patterns.md` — backend + frontend + API coding patterns (forward declaration)
- `ai/spec-generation.md` — spec structure definition
- `ai/spec-compiler.md` — 12-step compilation pipeline
- `ai/spec-to-task-playbook.md` — spec → task decomposition rules
- `ai/task-generator.md` — task generation procedure
- `ai/task-graph.md` — task dependency and ordering rules
- `ai/execution-loop-controller.md` — deterministic task execution loop
- `ai/execution-orchestrator.md` — multi-feature orchestration rules
- `ai/verification-playbook.md` — verification gate definition
- `ai/debug-playbook.md` — 6-step debugging procedure with domain checklists
- `ai/repo-index.md` — full repository structure map
- `ai/architecture-index.md` — planned system architecture (forward declaration)
- `ai/engineering-journal.md` — this file

Pipeline scripts (placeholder executables):
- `scripts/compile-spec.sh` — active in D3
- `scripts/generate-tasks.sh` — active in D3
- `scripts/execution-supervisor.sh` — active in D3
- `scripts/smoke.sh` — active now; verifies D0-D2 artifacts

### D2 — Factory Domain Model Freeze

Created factory domain authority documents:

- `docs/factory-flow-model.md` — 14-stage production spine with:
  - Stage types: external, factory core, gate, hard-block dependency, supervisor/manager action, terminal
  - Calibration retry loop (max 3 attempts, supervisor disposition on failure)
  - Gate control rules: CALIBRATION_GATE (S-07), QC_SIGNOFF_GATE (S-09)
  - Hard-block dependency: GENEALOGY_LOCK (S-10) depends on QC_SIGNOFF_GATE
  - Authority levels: Operator / Supervisor / Manager
  - Terminal states: SHIPPED, REJECTED, SCRAPPED
  - Stage status values: pending, active, complete, blocked, failed

- `docs/domain-glossary.md` — 19 canonical factory domain terms defined

### Assumptions Made

1. The "vendor/engineering-os" pattern from Raystrat-Systems was used as the OS template
   reference but the OS is implemented as in-tree control docs (not a git submodule) in v0,
   consistent with D0 decision lock.
2. Calibration retry loop covers stages S-06 and S-07 (not a single stage) to allow the
   retry counter to live outside the gate stage itself.
3. FINAL_REVIEW (S-13) is typed as supervisor/manager action — specifically manager,
   since it authorizes shipment, which is the highest-stakes decision in the spine.
4. The smoke.sh verification script is the active verification tool for D0-D2. A full
   `scripts/verification/` directory will be established in D3.
5. `scripts/generate-tasks.sh` is listed as a D1 script placeholder per the directive,
   but the task generation pipeline is invoked through `compile-spec.sh → generate-tasks.sh`.
   This is consistent with the vendor OS pipeline.

### What Was NOT Done (per stop condition)

- No React/Vite frontend scaffold
- No FastAPI backend scaffold
- No Docker Compose file
- No Postgres configuration
- No Azure SDK wiring
- No specs authored
- No tasks generated
- No application code written

---

## Next Phase

**D3 — Stack Scaffold**

Requires: explicit D3 directive from product authority.

D3 will produce:
- `docker-compose.yml` with frontend + backend services
- `frontend/` scaffold (Vite + React + TypeScript + Tailwind + shadcn/ui)
- `backend/` scaffold (FastAPI main.py + Pydantic stubs + in-memory store)
- `scripts/verification/` with initial verification scripts
- `.env.example`
- First spec: `specs/docker-stack-scaffold.md`

---

## Entry 002 — D2A Model Drift Correction

**Date:** 2026-06-30
**Phase:** D2A — Post-D2 Correction
**Status:** COMPLETE

### Trigger

The D2 completion report exposed significant drift between the domain model produced by
the initial D2 execution and the locked canonical 14-stage production spine. A D2A
correction directive was issued to audit and correct all documents before D3 begins.

### Drift Summary

The D2 model contained 8 drift categories:
1. Two-stage external order process (Order Created S-01, Order Approved S-02) was collapsed into a single invented stage ORDER_RECEIVED
2. UNIT_PROVISIONED appeared as a domain stage — it is an internal operation at S-03
3. TUBE_PRESS appeared as a domain stage — it is an assembly operation within S-05 Assembly
4. Calibration was split across two stages (CALIBRATION_ATTEMPT S-06 + CALIBRATION_GATE S-07) — canonical model has single Calibration at S-10
5. Four canonical stages were entirely absent: Software/Firmware Installed (S-06), Software/Firmware Updated from Cloud (S-07), Device Provisioned with Cloud (S-08), Hardware Checks / Setup (S-09)
6. GENEALOGY_LOCK appeared as a domain stage (S-10, hard-block dependency type) — it is an internal backend implementation concept, not a production stage
7. FINAL_REVIEW appeared as S-13 — canonical S-13 is Package
8. QC was split into QC_INSPECTION + QC_SIGNOFF_GATE — canonical model has single Quality Control at S-11

### Files Corrected

- `docs/factory-flow-model.md` — complete rewrite with canonical 14 stages
- `docs/domain-glossary.md` — updated 9 terms; added Production Record, Calibration Reference Standard; removed GENEALOGY_LOCK and FINAL_REVIEW stage references
- `ai/product-invariants.md` — INV-4 updated (added reference standard no-override rule); INV-5 rewritten as "Production Record Finalized After QC Pass" (removed GENEALOGY_LOCK stage reference)
- `ai/architecture-index.md` — router list corrected; added stage coverage table; removed genealogy.py; added firmware.py, backup.py; corrected domain mapping table
- `ai/coding-patterns.md` — router list corrected; API paths corrected to S-10 and S-11; naming conventions updated
- `ai/spec-to-task-playbook.md` — genealogy lock section replaced with QC post-pass record finalization section
- `ai/debug-playbook.md` — "Genealogy Lock Debug Checklist" replaced with "Post-QC Stage Advance Debug Checklist"

### File Created

- `docs/d2a-model-drift-correction.md` — full drift record (found, corrected, canonical confirmation, ambiguity status)

### Invariants After Correction

All 7 product invariants remain RATIFIED. INV-4 and INV-5 were substantively corrected.
INV-1 through INV-3, INV-6, INV-7 required no changes.

### GENEALOGY_LOCK Disposition

GENEALOGY_LOCK is explicitly **not** a domain stage. Reserved as a possible future
internal backend implementation concept only. Not referenced in any corrected document
as a production stage.

### No Application Code

Stop condition confirmed: no frontend/, backend/, docker-compose.yml, specs, or tasks
exist. D3 has not started.

---

## Next Phase (unchanged from Entry 001)

**D3 — Stack Scaffold**

Requires: explicit D3 directive from product authority.

---

## Entry 004 — D1D Vendor Real Engineering OS From Local Path

**Date:** 2026-06-30
**Phase:** D1D — OS Vendor Bootstrap (real)
**Status:** COMPLETE (with documented incident)

### Source Path

```
/Users/vasudevarao/RaystratSystems-AI-Engineering-OS
```

### Source Commit Hash

```
e718eac925c3a642ef520d3e582bc42fbe5eadbf
```

Source working tree: dirty (3 untracked files — included in vendor copy).

### Vendored OS Installed

`vendor/engineering-os/` — rsync copy of canonical OS at above commit.

Vendored directories:
- `vendor/engineering-os/core-docs/` — OS doctrine (ENGINEERING_OS.md, spec-compiler.md, etc.)
- `vendor/engineering-os/scripts/` — OS runtime (compile-spec.sh, execution-supervisor.sh, etc.)
- `vendor/engineering-os/templates/` — adapter.config.sh template, state_registry.json template
- `vendor/engineering-os/tests/` — OS self-tests

### Adapter Overlay Created

`.engineering-os/adapter.config.sh` — EOS_* variables for ndt-factory-cloud.

6 project invariants in `.engineering-os/invariants/`:
- INV-001: Factory model docs present
- INV-002: AI control layer docs present
- INV-003: No application code before D3 directive
- INV-004: State registry is valid JSON
- INV-005: Vendored Engineering OS installed
- INV-006: Adapter overlay present

All 6 invariants pass. `Result: 6/6 PASS`.

### Scripts Proxied

- `scripts/compile-spec.sh` → `vendor/engineering-os/scripts/compile-spec.sh`
- `scripts/generate-tasks.sh` → `vendor/engineering-os/scripts/generate-tasks.sh`
- `scripts/execution-supervisor.sh` → `vendor/engineering-os/scripts/execution-supervisor.sh`
- `scripts/state-manager.sh` → `vendor/engineering-os/scripts/state-manager.sh`
- `scripts/invariant-check.sh` → `vendor/engineering-os/scripts/invariant-engine.sh`

Phase definitions installed at `specs/phases/` (required by compile pipeline).
Pre-commit hook installed at `.git/hooks/pre-commit`.
State registry initialized: `ai/state_registry.json = {}`.

### Self-Test Result

| Test | Result |
|------|--------|
| 001 — Enforcement Layer | 6/6 PASS |
| 002 — State Machine | 8/8 PASS |
| 003 — Invariant Engine | 9/9 PASS |
| 004 — CLI Backing Surfaces | 33/33 assertions PASS; 1 cleanup error (macOS ln behavior) |
| 005 — CLI Wrapper | 37/37 PASS |

Incident documented: `ai/incidents/d1d-os-vendor-self-test-failure.md`

### Smoke Result

`bash scripts/smoke.sh` — **29/29 PASS**

### D3 Readiness

**READY.** OS is operational. No application code exists.

---

## Entry 003 — D1C Invented OS Cleanup

**Date:** 2026-06-30
**Phase:** D1C — Pre-Vendor Cleanup
**Status:** COMPLETE

### Reason for Cleanup

The D0-D2 bootstrap installed invented stand-in Engineering OS files rather than
vendoring from the canonical source at:

```
/Users/vasudevarao/RaystratSystems-AI-Engineering-OS
```

Invented files were 2-19x smaller than their canonical equivalents and contained
placeholder/stub logic. They needed removal before the real OS can be vendored in D1D.

### Files Quarantined

Moved to `_archive/invented-os-bootstrap-d1c/` (16 files):

Root documents:
- `ENGINEERING_OS.md` — invented stand-in (2x smaller than canonical)
- `PROJECT_BOOTSTRAP.md` — invented stand-in (2x smaller than canonical)
- `CLAUDE.md` — invented; referenced quarantined PROJECT_BOOTSTRAP.md

AI protocol docs (invented OS core):
- `ai/spec-compiler.md` — 5x smaller than canonical
- `ai/spec-generation.md` — 2.7x smaller than canonical
- `ai/spec-to-task-playbook.md` — D2A domain refs patched; factory content in docs/
- `ai/task-generator.md` — 6x smaller than canonical
- `ai/task-graph.md` — 2x smaller than canonical
- `ai/execution-loop-controller.md` — 3x smaller than canonical
- `ai/execution-orchestrator.md` — 3x smaller than canonical
- `ai/verification-playbook.md` — 2x smaller than canonical
- `ai/debug-playbook.md` — D2A domain patch documented in Entry 002

Pipeline scripts (placeholder stubs):
- `scripts/compile-spec.sh` — stub, printed placeholder, exited 0
- `scripts/generate-tasks.sh` — stub
- `scripts/execution-supervisor.sh` — 19x smaller than canonical
- `scripts/smoke.sh` — invented D0-D2 verification (not in canonical OS)

### Project Docs Preserved

All 11 project-specific Factory Cloud control artifacts remain intact:
`docs/decision-lock.md`, `docs/factory-flow-model.md`, `docs/domain-glossary.md`,
`docs/d2a-model-drift-correction.md`, `ai/engineering-journal.md`,
`ai/repo-index.md`, `ai/architecture-index.md`, `ai/product-invariants.md`,
`ai/runtime-contracts.md`, `ai/service-boundaries.md`, `ai/coding-patterns.md`.

### Canonical OS Source Path

```
/Users/vasudevarao/RaystratSystems-AI-Engineering-OS
```

Not modified. Read-only authority for D1D.

### Cleanup Report

Full report at: `docs/d1c-invented-os-cleanup.md`

### Next Phase

**D1D — Vendor Real OS From Local Path**

Requires: explicit D1D directive from product authority.

D1D will install the canonical Engineering OS from the local source path
and create a new project-specific CLAUDE.md pointing to the real boot sequence.

---

### 2026-06-30

### Feature

pipeline-test

### Phase

phase-ui

### Spec

specs/pipeline-test.md

### Tasks


- tasks/pipeline-test-001.md [frontend]
- tasks/pipeline-test-002.md [verification]

### Implementation Notes

Executed by execution-supervisor.sh at 2026-06-30T06:39:21Z.
All 2 tasks completed. Verification passed.

### Pattern Updates

None.

### Incidents

None.

---

## Entry 005 — D3 Stack Scaffold

**Date:** 2026-06-30
**Phase:** D3
**Status:** COMPLETE (Docker build pending — Docker Desktop not running at time of execution)

### OS Lifecycle

- Spec created: `specs/docker-stack-scaffold.md` (Status: approved, Phase: phase-1)
- Pipeline: `bash scripts/compile-spec.sh specs/docker-stack-scaffold.md`
- 3 task stubs generated: 001 (backend), 002 (frontend), 003 (verification)
- Tasks filled with concrete content
- INV-003 updated: was "no app code before D3" → now "D3 scaffold present and spec approved"

### Files Created

Backend (FastAPI):
- `backend/Dockerfile` — Python 3.12-slim, uvicorn CMD
- `backend/requirements.txt` — fastapi, uvicorn, pydantic, pydantic-settings, python-dotenv
- `backend/app/__init__.py`
- `backend/app/main.py` — FastAPI app, CORS, router includes
- `backend/app/settings.py` — Pydantic settings (ALLOWED_ORIGINS, APP_ENV)
- `backend/app/models.py` — HealthResponse, ScaffoldStatusResponse
- `backend/app/routes/__init__.py`
- `backend/app/routes/health.py` — GET /health
- `backend/app/routes/factory.py` — GET /factory/scaffold-status

Frontend (React/Vite/TS/Tailwind):
- `frontend/Dockerfile` — node:20-alpine, npm run dev CMD
- `frontend/package.json` — React 18, Vite 5, TS, Tailwind 3
- `frontend/index.html`
- `frontend/vite.config.ts` — host: 0.0.0.0, port: 5173
- `frontend/tsconfig.json`, `frontend/tsconfig.node.json`
- `frontend/tailwind.config.js`, `frontend/postcss.config.js`
- `frontend/src/main.tsx`, `App.tsx`, `api.ts`, `types.ts`, `styles.css`
- `frontend/src/components/AppShell.tsx` — phase banner, health display, scaffold status, stack table
- `frontend/src/components/HealthStatus.tsx` — polls /health with loading/error/ok states

Infrastructure:
- `docker-compose.yml` — backend:8000, frontend:5173, depends_on
- `.env.example`, `.gitignore`, `README.md`
- `scripts/verification/001-docker-compose-config.sh` — PASS 4/4
- `scripts/verification/002-backend-health.sh`
- `scripts/verification/003-frontend-reachable.sh`

OS Lifecycle artifacts:
- `specs/docker-stack-scaffold.md`
- `tasks/docker-stack-scaffold-001.md`, `002.md`, `003.md`
- `docs/superpowers/plans/2026-06-30-d3-stack-scaffold.md`

### Verification

- V001 docker compose config: **4/4 PASS**
- Docker build: **PENDING** — Docker Desktop not running on execution host
- V002 backend health: pending
- V003 frontend reachable: pending

### Bug Fix During Execution

`## Phase Boundary` section in spec conflicted with compile-spec.sh `grep -A1 "^## Phase"` parser.
The blank line after `## Phase Boundary` resolved as the PHASE variable, making it empty.
Fix: renamed section to `## Boundary`.

### Invariant Update

INV-003 was "No application code before D3 directive" (test ! -d frontend).
After D3, this is now "D3 scaffold present and spec approved" (test -d frontend && test -d backend && ...).

### No Domain Behavior

No factory state machine, no calibration logic, no QC logic, no assembly scan,
no cloud backup, no Postgres, no Azure SDK, no placeholder identifiers in code.

### Next Phase

D4 Mock Data Contract — in-memory store, 3 orders, 5 units, GET /api/units + GET /api/orders,
frontend unit list display.

---

## Entry 006 — D3A Backend Runtime Patch

**Date:** 2026-06-30
**Phase:** D3A — Corrective patch to D3
**Status:** COMPLETE

### Issue

Live backend verification failed after D3 Docker build succeeded.
`curl http://localhost:8000/health` returned connection reset / no valid HTTP response.

### Finding

App import and manual no-reload startup passed:
```
python -c "from app.main import app; print(app.title)"  # Factory Cloud v0
python -m uvicorn app.main:app --host 0.0.0.0 --port 8001  # Application startup complete
```

Root cause: `--reload` flag in backend Dockerfile CMD. Uvicorn's reload mode uses a file
watcher subprocess that can fail to bind inside Docker when watchfiles/inotify behaves
unexpectedly, preventing the HTTP listener from starting.

### Fix

`backend/Dockerfile` CMD changed:

Before: `CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]`
After:  `CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]`

### Verification Results

```
curl http://localhost:8000/health
→ {"status":"ok","service":"ndt-factory-cloud-backend","phase":"D3_STACK_SCAFFOLD"}

curl http://localhost:8000/factory/scaffold-status
→ {"status":"scaffold_only","domain_logic_enabled":false,"stage_model_locked":true,"current_phase":"D3_STACK_SCAFFOLD"}
```

| Script | Result |
|--------|--------|
| 001-docker-compose-config.sh | 4/4 PASS |
| 002-backend-health.sh | 4/4 PASS |
| 003-frontend-reachable.sh | 2/2 PASS |
| smoke.sh | 35/35 PASS |

### D3 Runtime Status

**COMPLETE.** All 22 D3 directive acceptance criteria met.

### D4 Readiness

**READY.** D4 Mock Data Contract is safe to proceed.
No domain logic, no Postgres, no Azure SDK in D3 codebase.

---

## Entry 007 — D4 Mock Data Contract

**Date:** 2026-06-30
**Phase:** D4 — Mock Data Contract + Read-Only API
**Status:** COMPLETE

### Scope

Made the NDT factory domain model visible through 8 structured JSON data files
and a read-only HTTP API. No domain behavior implemented. No state transitions.

### Data Files Created (`data/`)

| File | Records |
|------|---------|
| stages.json | 14 canonical production stages |
| factory_units.json | 7 units (UNIT-0001 through UNIT-0007, all critical states covered) |
| orders.json | 3 orders (2 accepted, 1 rejected at boundary) |
| parts.json | 6 parts in various allocation/bound/released states |
| users.json | 6 users covering all 4 authority tiers |
| model_recipes.json | 2 model recipes (MODEL-XRF-BASIC, MODEL-XRF-PRO) |
| reference_standards.json | 3 reference standards (valid, expired, missing cert) |
| events.json | 22 events covering full lifecycle including cloud blocks |

All stage IDs, names, and types derived from Digital_Factory_Requirements.json.
Identifier format follows INV-7: UNIT-XXXX, ORDER-XXXX, PART-XXXX, USER-ROLE-XXXX.
No AX-* identifiers.

Critical states covered by UNIT-0001..0007:
- UNIT-0001: assembly active (stage 5)
- UNIT-0002: cloud-blocked at stage 7, no_override (hard block)
- UNIT-0003: calibration attempt 2/3 in progress (stage 10)
- UNIT-0004: calibration cap exceeded, supervisor disposition required (stage 10)
- UNIT-0005: ready for QC sign-off (stage 11)
- UNIT-0006: cloud-backup-blocked at stage 12, no_override (hard block)
- UNIT-0007: shipped, terminal, immutable (stage 14)

### Backend Changes

- `backend/app/data_loader.py` — reads JSON files from DATA_DIR env (default: repo root / data/)
- `backend/app/models.py` — D4 Pydantic read models added (8 entity types + DataContractStatusResponse)
- `backend/app/routes/data_contract.py` — 10 GET-only endpoints for data contract
- `backend/app/main.py` — version 0.4.0, data_contract router registered
- `docker-compose.yml` — DATA_DIR=/app/data env + ./data:/app/data:ro volume mount

### Frontend Changes

- `frontend/src/components/DataContractStatus.tsx` — new component fetching /factory/data-contract/status
- `frontend/src/components/AppShell.tsx` — "Data Contract" section added, phase banner updated to D4

### OS Lifecycle

- Spec: `specs/mock-data-contract.md` (Status: approved, Phase: phase-1)
- Tasks: `mock-data-contract-001.md` (backend+data), `002.md` (frontend), `003.md` (verification)
- Verification script: `scripts/verification/004-data-contract-api.sh` (10 checks)
- Documentation: `docs/mock-data-contract-d4.md`

### Verification Results

| Script | Result |
|--------|--------|
| 001-docker-compose-config.sh | **4/4 PASS** |
| 002-backend-health.sh | **4/4 PASS** |
| 003-frontend-reachable.sh | **2/2 PASS** |
| 004-data-contract-api.sh | **10/10 PASS** |
| smoke.sh | **45/45 PASS** |

### Known Issues

None. All D4 directive acceptance criteria satisfied.

### D5 Readiness

**READY.**
D5 will add in-memory state machines and POST routes for stage advancement.
No domain behavior has been added in D4.

---

## Entry 008 — D5 Backend State Behavior

**Date:** 2026-06-30
**Phase:** D5 — Backend State Behavior
**Status:** COMPLETE

### Scope

Converted the D4 read-only mock data contract into a controlled in-memory workflow
engine. The backend now enforces factory workflow rules for all key production stages.
D4 API unchanged and backward-compatible.

### New Files

Backend:
- `backend/app/state_store.py` — singleton in-memory state, loaded from data/*.json;
  `load_state()`, `get_state()`, `reset_state()`, `get_unit()`, `update_unit()`,
  `next_event_id()`, `append_event()`. Secondary index `parts_by_serial` for O(1) lookup.
- `backend/app/workflow_rules.py` — all 10 domain action functions + helpers.
  `_now()`, `_require_unit()`, `_is_terminal()`, `_blocked_response()`, `_success_response()`,
  `_make_event()`. Domain: scan_part, reallocate_part, record_hardware_gate,
  record_calibration, record_calibration_disposition, qc_signoff, record_cloud_backup,
  transition_stage, package_unit, ship_unit.
- `backend/app/routes/actions.py` — 11 POST endpoints (10 workflow + dev/reset-state).
- `frontend/src/components/D5BackendStatus.tsx` — static D5 backend status panel.

Updated files:
- `backend/app/models.py` — added 10 D5 request models + ActionResponse + ResetStateResponse
- `backend/app/main.py` — v0.5.0, description updated, actions router registered
- `frontend/src/components/AppShell.tsx` — D5 phase banner, Backend Behavior section

### OS Lifecycle

- Spec: `specs/backend-state-behavior.md` (Status: approved, Phase: phase-backend)
- Tasks: `tasks/backend-state-behavior-001..005.md` (all layers: state, rules, routes, frontend, verification)
- Verification: `scripts/verification/005-backend-state-behavior.sh` (15 checks)
- Documentation: `docs/backend-state-behavior-d5.md`

### Domain Rules Implemented

| Rule | Implementation |
|------|---------------|
| STAGE-05 assembly scan — part binding | workflow_rules.scan_part |
| Supervisor reallocation (can_override) | workflow_rules.reallocate_part |
| STAGE-09 hardware gate pass/fail | workflow_rules.record_hardware_gate |
| STAGE-10 calibration — 3-attempt cap | workflow_rules.record_calibration |
| Reference standard no_override hard-stop | workflow_rules.record_calibration (pre-check) |
| Calibration disposition after cap | workflow_rules.record_calibration_disposition |
| STAGE-11 QC separation-of-duty | workflow_rules.qc_signoff |
| Manager waiver path for QC SOD | workflow_rules.qc_signoff (waiver_actor_user_id) |
| STAGE-12 cloud backup unavailable hard-stop | workflow_rules.record_cloud_backup |
| STAGE-14 ship → terminal | workflow_rules.ship_unit |
| Terminal unit → 409 on any action | workflow_rules.transition_stage + _is_terminal() |

### Known Tradeoffs / Incidents

1. **FastAPI v0.138.2 route detection**: `isinstance(r, APIRoute)` returns 0 because
   FastAPI now stores included routers as `_IncludedRouter`. Validated via `app.openapi()`
   which correctly returned 23 paths (11 action + 12 D4 endpoints).

2. **`## Phase Boundary` parser conflict**: resolved in D3 but worth repeating — any spec
   section named `## Phase *` causes compile-spec.sh PHASE variable to resolve to empty.
   Fix: always use `## Boundary` or `## Boundary Condition`. Applied correctly in D5 spec.

3. **Task generator section detection**: `generate-tasks.sh` only generates layer tasks when
   spec contains `## Data Model Changes`, `## API Surface`, `## Frontend Surface`. Spec must
   include these sections explicitly.

### Verification Results (pending Docker run)

Verification scripts created and ready. Docker build + run required before final check.
Expected: 001 4/4, 002 4/4, 003 2/2, 004 10/10, 005 ≥15/15, smoke.sh pass.

### D6 Readiness

**READY for directive.**
D6 will add Factory Flow Board UI — unit list, stage progress visualization,
active hard-stop banners, supervisor action panels.
No domain behavior beyond D5 scope has been added.
D6 requires an explicit directive before any implementation begins.

---

## Entry 009 — D6 Factory Flow Board UI

**Date:** 2026-06-30
**Phase:** D6 — Factory Flow Board UI
**Status:** COMPLETE

### Scope

Built the first usable Factory Flow Board UI. The UI consumes D4/D5 backend APIs and
lets a reviewer see every unit, where each unit is in the 14-stage flow, which units are
blocked and why, what action is available at the current stage, and recent event history.

### Files Created

Frontend types/API:
- `frontend/src/types/factory.ts` — all TypeScript types (234 lines, no `any`)
- `frontend/src/api/factoryApi.ts` — complete API client, GET + POST (144 lines)

Frontend components:
- `frontend/src/components/FactoryFlowBoard.tsx` — root layout, data loading, state
- `frontend/src/components/UnitList.tsx` — unit queue, blocked/shipped badges
- `frontend/src/components/StageSpine.tsx` — 14-stage visual progression with stage-type badges
- `frontend/src/components/UnitDetailPanel.tsx` — unit fields, calibration, QC, cloud, ship
- `frontend/src/components/ActionPanel.tsx` — backend-backed action forms for all D5 actions
- `frontend/src/components/EventTrace.tsx` — recent events table

Updated:
- `frontend/src/App.tsx` — render FactoryFlowBoard (replaced AppShell as root)
- `frontend/index.html` — D6 meta markers for verification

OS Lifecycle:
- Spec: `specs/factory-flow-board-ui.md` (Status: approved, Phase: phase-ui)
- Tasks: `tasks/factory-flow-board-ui-001..004.md`
- Verification: `scripts/verification/006-factory-flow-board-ui.sh` (12 checks)
- Documentation: `docs/factory-flow-board-ui-d6.md`

### APIs Consumed

All 10 D4 GET endpoints + 11 D5 POST action endpoints consumed by frontend.
No new backend endpoints added.

### Action Panel Behavior

Stage-gated forms show based on selected unit's current stage:
STAGE-05: scan-part + supervisor realloc
STAGE-09: hardware gate
STAGE-10: calibration form OR disposition form (if cap exceeded)
STAGE-11: QC sign-off (with optional waiver fields)
STAGE-12: cloud backup (cloud_available flag)
STAGE-13: package
STAGE-14: ship
Always visible (dev): backend-guarded transition (visually dimmed)

Blocked responses (HTTP 200 + status="blocked") displayed with blocked_reason and
NO OVERRIDE badge — not fake-success. After every action: units/detail/events refresh.

### Visual Semantics Implemented

EXTERNAL (grey) · GATE (amber) · CLOUD BLOCK (slate/red when active) ·
TERMINAL (green) · BLOCKED (red) · NO OVERRIDE (red) · SHIPPED (green)
Stage dots: blue=current, grey=completed, red=blocked, dark=pending

### Verification Results

| Script | Result |
|--------|--------|
| 001-docker-compose-config.sh | **4/4 PASS** |
| 002-backend-health.sh | **4/4 PASS** |
| 003-frontend-reachable.sh | **2/2 PASS** |
| 004-data-contract-api.sh | **10/10 PASS** |
| 005-backend-state-behavior.sh | **26/26 PASS** |
| 006-factory-flow-board-ui.sh | **12/12 PASS** |
| smoke.sh | **PASS** |

### No Postgres / No Azure / No Auth

No Postgres, Azure SDK, or auth/session management added. Backend in-memory state store
unchanged. Frontend decision authority: display only.

### D7 Readiness

**READY for directive.**
D7 Persistence/Postgres is safe to begin. D7 will add Postgres persistence (in-memory
store replaced by SQLAlchemy + Alembic), unit state survives container restart.
D7 requires an explicit directive before any implementation begins.

---

## Entry 010 — D7 Persistence / Postgres

**Date:** 2026-06-30
**Phase:** D7
**Status:** COMPLETE

### Objective

Replace the in-memory D5 state store with PostgreSQL persistence. Preserve all D4/D5/D6
API behavior exactly. Unit state survives container restart.

Core rule enforced: persist state without changing product behavior.

### What Was Built

**Infrastructure:**
- PostgreSQL 16 service in docker-compose.yml (db: factory_cloud, volume: postgres_data)
- DATABASE_URL env var wired to backend service
- backend/entrypoint.sh: wait-for-postgres → alembic upgrade head → seed if empty → uvicorn

**Schema:**
- 8 ORM models in db_models.py: stages, orders, factory_units, parts, users, model_recipes,
  reference_standards, events
- factory_units.payload (jsonb) stores all nested unit fields: part_allocations, genealogy,
  gate_results, calibration_summary, qc_summary, cloud_status, package_ship_status, event_ids
- Alembic migration 001 creates all 8 tables

**Seed and State Store:**
- seed.py loads all data/*.json into DB tables on first boot
- state_store.py replaced entirely: get_state(db), reset_state(db), persist_action(db, ...)
  Same public interface — workflow_rules.py is UNCHANGED

**Route Changes:**
- routes/actions.py: DB session injection via Depends(get_db); persist_action() called after
  each workflow action
- routes/data_contract.py: units, parts, events now served from DB; stages/orders/users from
  data_loader (static/immutable)

### Design Decision: Load-Mutate-Persist

workflow_rules.py mutates state dicts in-place. Rather than rewrite workflow_rules, the D7
approach:
1. Load full state from DB into dict at request start
2. workflow_rules mutates the dict
3. persist_action() flushes unit + all parts + new events back to DB

This keeps domain logic untouched and preserves the exact D5 behavior contract.

### Verification Results

| Script | Result |
|--------|--------|
| 001-docker-compose-config.sh | **PASS** |
| 002-backend-health.sh | **PASS** |
| 003-frontend-reachable.sh | **PASS** |
| 004-data-contract-api.sh | **10/10 PASS** |
| 005-backend-state-behavior.sh | **26/26 PASS** |
| 006-factory-flow-board-ui.sh | **12/12 PASS** |
| 007-persistence-postgres.sh | **17/17 PASS** |
| smoke.sh | **PASS** |

### Constraints Honored

- No Azure SDK added
- No auth/session management added
- workflow_rules.py unchanged — all domain logic preserved
- 14-stage model unchanged
- D6 Factory Flow Board UI unchanged
- Placeholder IDs only in seed data (INV-7)

---

## Entry 011 — D8 Factory Review Hardening / Demo Readiness

**Date:** 2026-06-30
**Phase:** D8 — Factory Review Hardening
**Status:** COMPLETE

### Objective

Harden the D6 Factory Flow Board UI for stakeholder review without adding features,
changing backend logic, or expanding product scope. Core rule: make the existing prototype
reviewable.

### What Was Built

Frontend UI improvements (presentation layer only — no backend changes):
- `frontend/src/components/UnitList.tsx` — Scenario labels per unit (sky-400 text) derived
  from SCENARIO_LABELS mapping: "Assembly in progress", "Cloud SW/FW blocked", etc.
- `frontend/src/components/StageSpine.tsx` — Gate rows (S-09/S-10/S-11) get amber border
  when pending; CLOUD BLOCK badge always visible on S-07/S-12; NO OVERRIDE badge bolded;
  terminal S-14 green border always shown; slate border for cloud-stage pending states
- `frontend/src/components/UnitDetailPanel.tsx` — Explicit "Block / Hard-Stop" section
  when unit is blocked; block_type displayed; NO OVERRIDE shown as prominent red block
- `frontend/src/components/ActionPanel.tsx` — "Backend-guarded action" label on every form;
  POST endpoint URL shown; "No available action" guidance for unsupported stages
- `frontend/src/components/EventTrace.tsx` — Unit-filtered event view (selected unit's events
  first); "Show all events" toggle
- `frontend/src/components/FactoryFlowBoard.tsx` — Header: "D8 Review Prototype" title,
  "Postgres-backed" badge, "Reset Demo State" button; pass selectedUnitId to EventTrace;
  `data-d8-demo-readiness="true"` on root div
- `frontend/index.html` — Title: "Factory Cloud v0 — D8 Review Prototype"; meta tags:
  `app-phase=D8-review-prototype`, `app-d8=demo-readiness`; D6 backward-compat tag retained

OS Lifecycle:
- Spec: `specs/factory-review-hardening.md` (Status: approved, Phase: phase-demo-readiness)
- Tasks: `tasks/factory-review-hardening-001..005.md`
- Verification: `scripts/verification/008-demo-readiness.sh` (17 checks)
- Documentation: `docs/factory-review-hardening-d8.md`, `docs/demo-walkthrough-d8.md`

### Verification Results

| Script | Result |
|--------|--------|
| 001-docker-compose-config.sh | **PASS** |
| 002-backend-health.sh | **PASS** |
| 003-frontend-reachable.sh | **PASS** |
| 004-data-contract-api.sh | **10/10 PASS** |
| 005-backend-state-behavior.sh | **26/26 PASS** |
| 006-factory-flow-board-ui.sh | **12/12 PASS** |
| 007-persistence-postgres.sh | **17/17 PASS** |
| 008-demo-readiness.sh | **17/17 PASS** |
| smoke.sh | **PASS** |

### Unchanged Components

- `backend/app/workflow_rules.py` — untouched
- `backend/app/routes/actions.py` — untouched
- `backend/app/routes/data_contract.py` — untouched
- `backend/app/state_store.py` — untouched
- `backend/app/models.py` — untouched
- `backend/app/db_models.py` — untouched
- All D5 action endpoints — same URLs, same request/response shapes
- All D4 data contract endpoints — unchanged
- PostgreSQL schema — unchanged
- 14-stage canonical production spine — unchanged
- `data/*.json` seed files — unchanged

### 006 Backward-Compatibility Fix

`scripts/verification/006-factory-flow-board-ui.sh` V3 was updated: the subtitle check
changed from "D6 Factory Flow Board" (no longer in title) to "Factory Cloud" (still present).
D6 backward-compat meta tag retained in index.html ensures V2 (`factory-flow-board` marker)
still passes.

### D9 Readiness

**READY for directive.**
D9 candidates: Order management UI, full unit history viewer, Azure IoT Hub wiring for S-07/S-12.
All require explicit directives before implementation.

---

## Entry 012 — D8A Light Mode Readability Pass

**Date:** 2026-06-30
**Phase:** D8A — Light Mode Readability Pass
**Status:** COMPLETE

### Objective

Convert the D8 Factory Flow Board from dark-mode Tailwind to light off-white mode.
Core rule: improve readability only. No backend changes, no product scope expansion.

The operator rejected the current dark UI readability for stakeholder review on a laptop screen.

### Files Changed (frontend only)

- `frontend/src/components/FactoryFlowBoard.tsx` — root bg-[#FAFAF7], text-2xl title, white header,
  data-theme="light-review", data-d8a-readability="true", wider columns
- `frontend/src/components/UnitList.tsx` — light rows, text-sm IDs, light badges (100-bg/700-text)
- `frontend/src/components/StageSpine.tsx` — removed all opacity-*, light semantic state backgrounds
  (blue-50/red-50/amber-50/orange-50/green-50), text-sm stage names, light badges
- `frontend/src/components/UnitDetailPanel.tsx` — white cards, slate-200 borders, text-sm values,
  red-50 block section, text-gray-800 values
- `frontend/src/components/ActionPanel.tsx` — slate-50 inputs, text-sm forms, light response boxes,
  light semantic form containers, blue-600 submit buttons
- `frontend/src/components/EventTrace.tsx` — slate-200 table header, slate-100 row borders,
  blue-50 selected row, text-gray-700 messages, light severity badge colors
- `frontend/index.html` — added app-d8a and app-theme meta tags

### Readability Changes

| Element | Before | After |
|---------|--------|-------|
| Page background | bg-gray-950 (near-black) | bg-[#FAFAF7] (off-white) |
| Page title size | text-lg (18px) | text-2xl (24px) |
| Body text size | text-xs (12px) | text-sm (14px) |
| Section headers | text-[10px] | text-xs (12px) |
| Stage opacity | opacity-40–60 on pending | none — full opacity |
| Badges | dark (bg-*-900 text-*-300) | light (bg-*-100 text-*-700) |
| Form inputs | bg-gray-900 | bg-slate-50 |

### Verification Results

| Script | Result |
|--------|--------|
| 001-docker-compose-config.sh | **4/4 PASS** |
| 002-backend-health.sh | **4/4 PASS** |
| 003-frontend-reachable.sh | **2/2 PASS** |
| 004-data-contract-api.sh | **10/10 PASS** |
| 005-backend-state-behavior.sh | **26/26 PASS** |
| 006-factory-flow-board-ui.sh | **12/12 PASS** |
| 007-persistence-postgres.sh | **17/17 PASS** |
| 008-demo-readiness.sh | **17/17 PASS** |
| 009-light-mode-readability.sh | **18/18 PASS** |
| smoke.sh | **PASS** |

### Backend/Schema Unchanged

- `workflow_rules.py` — untouched
- All 11 action endpoints — same URLs and behavior
- All 10 data contract endpoints — unchanged
- PostgreSQL schema — unchanged
- 14-stage canonical spine — unchanged
- Seeded unit scenarios UNIT-0001..0007 — unchanged

### D9 Readiness

**READY for directive.**
D9 candidates: Order management UI, full unit history viewer, Azure IoT Hub wiring for S-07/S-12.
All require explicit directives before implementation.

---

## Entry 013 — D8B Material Design Theme System + Readability Rework

**Date:** 2026-06-30
**Phase:** D8B Material Design Theme System
**Status:** COMPLETE

### Capability Added

Replaced the D8A scattered-Tailwind-class approach with a proper Material Design 3-inspired
CSS token system. Added Light/Dark mode toggle with localStorage persistence. All six UI
components converted to semantic CSS helper classes that reference CSS variables.

### CSS Token System

`frontend/src/styles.css` rewritten with:

- `[data-theme="light"]` and `[data-theme="dark"]` token blocks
- MD3 system tokens: `--mds-surface*`, `--mds-on-surface*`, `--mds-outline*`, `--mds-primary*`, `--mds-error*`
- Factory operational tokens: `--factory-gate*`, `--factory-cloud*`, `--factory-success*`, `--factory-supervisor*`
- 35+ semantic CSS helper classes: `.app-bg`, `.surf`, `.surf-low`, `.surf-container`, `.surf-high`,
  `.t-on-surface`, `.t-on-surface-var`, `.b-outline`, `.b-outline-var`, plus container variants for
  primary/error/gate/cloud/success/supervisor, plus `.mdc-card`, `.mdc-input`, `.mdc-select`, `.mdc-divider`

### Theme Toggle

`FactoryFlowBoard.tsx`:
- `useState<'light'|'dark'>` initialized from `localStorage.getItem('factory-theme')`
- `useEffect` sets `document.documentElement.setAttribute('data-theme', theme)` on every change
- Toggle button in header: "Dark" → switches to dark; "Light" → switches to light
- `root div` uses `app-bg` class (CSS variable), not hardcoded `bg-[#FAFAF7]`
- `data-d8b-material-theme="true"` on root div

No-FOUC inline script in `index.html <head>` reads localStorage before React hydrates:
```html
<script>
  (function () {
    var stored = localStorage.getItem('factory-theme');
    var theme = stored === 'dark' ? 'dark' : 'light';
    document.documentElement.setAttribute('data-theme', theme);
  })();
</script>
```

### Component Rework

All six components converted from hardcoded D8A Tailwind colors to MD3 semantic classes:

| Component | Key changes |
|-----------|------------|
| FactoryFlowBoard | `.surf .b-outline-var` header/footer; `.b-outline-var` column dividers; `.t-on-surface-var` section labels |
| UnitList | `.surf-low .b-outline-var rounded-xl` rows; `.surf-primary .b-primary .t-on-primary` selected; `.surf-error .surf-success` badges |
| StageSpine | 7 state variants → MD3 token classes; badge text uses container on-colors; NO OVERRIDE stays `bg-red-600 text-white` |
| UnitDetailPanel | `.mdc-card .b-outline-var` cards; `.t-on-surface-var/.t-on-surface` row labels/values; `.surf-error .b-error` block section |
| ActionPanel | `.mdc-input/.mdc-select` for all inputs; form containers by action type; semantic response display |
| EventTrace | `severityStyle()` returns CSS variable inline styles; `.hover-surf-container` hover; selected row via `color-mix()` |

### Tailwind Config

`frontend/tailwind.config.js`: Added `darkMode: false` to prevent system preference override.

### New Files

- `specs/material-theme-readability-d8b.md` — spec (Status: approved, Phase: phase-demo-readiness)
- `docs/material-theme-readability-d8b.md` — documentation
- `scripts/verification/010-material-theme-readability.sh` — 21 checks
- `tasks/material-theme-readability-d8b-001..004.md` — task graph (all: done)

### Modified Files

- `frontend/src/styles.css` — full rewrite (MD3 token system)
- `frontend/tailwind.config.js` — added darkMode: false
- `frontend/index.html` — D8B meta tags + no-FOUC script
- `frontend/src/components/FactoryFlowBoard.tsx` — theme toggle + MD3 layout classes
- `frontend/src/components/UnitList.tsx` — MD3 card/badge classes
- `frontend/src/components/StageSpine.tsx` — MD3 state classes
- `frontend/src/components/UnitDetailPanel.tsx` — MD3 card/row classes
- `frontend/src/components/ActionPanel.tsx` — MD3 form container/input classes
- `frontend/src/components/EventTrace.tsx` — CSS variable severity styles
- `scripts/verification/009-light-mode-readability.sh` — V6 updated for D8B compatibility

### Verification Results

| Script | Result |
|--------|--------|
| 001-docker-compose-config.sh | PASS |
| 002-backend-health.sh | PASS |
| 003-frontend-reachable.sh | PASS |
| 004-data-contract-api.sh | PASS |
| 005-backend-state-behavior.sh | PASS |
| 006-factory-flow-board-ui.sh | PASS |
| 007-persistence-postgres.sh | PASS |
| 008-demo-readiness.sh | PASS |
| 009-light-mode-readability.sh | PASS |
| 010-material-theme-readability.sh | 21/21 PASS |
| smoke.sh | PASS |

### Backend/Schema Unchanged

- `workflow_rules.py` — untouched
- All 11 action endpoints — same URLs and behavior
- All 10 data contract endpoints — unchanged
- PostgreSQL schema — unchanged
- 14-stage canonical spine — unchanged
- Seeded unit scenarios UNIT-0001..0007 — unchanged

### D9 Readiness

**READY for directive.**
D9 candidates: Order management UI, full unit history viewer, Azure IoT Hub wiring for S-07/S-12.
All require explicit directives before implementation.

---

## D8C — Touch-First Responsive Factory UI

**Date:** 2026-07-02
**Capability:** touch-first-responsive-factory-ui-d8c
**Branch:** main
**Repository mode:** OS-ENABLED (vendor/engineering-os/ + .engineering-os/ adapter overlay)
**Recon artifact:** ai/recon/d8c-touch-first-responsive-ui-recon.md

### Summary

Made the existing Factory Cloud frontend touch-first from 768px to 1920px+ while
preserving mouse usability, keyboard accessibility, the D8B light/dark theme system,
and all D4–D8B API/backend behavior unchanged. Replaced the fixed three-column
desktop layout's compact-width behavior with a priority-ordered pane switcher instead
of naively shrinking it.

### Responsive Strategy

Compact (<1024px): touch-safe tab bar switches between Unit Queue / Detail
(default) / Stages / Events — one full-width pane at a time, no forced three-column
shell. Standard (1024–1599px) and Large (>=1600px): all four regions render
simultaneously as before, with `lg:`/`xl:`/`min-[1600px]:` column-width adjustments.
`tailwind.config.js` was not modified — reused the framework's default breakpoint
scale plus one arbitrary `min-[1600px]:` variant.

### Touch-Target Standards

New `.touch-target-primary` (48px) / `.touch-target-secondary` (44px) utility
classes in `styles.css`, additive to the existing `surf-*`/`t-on-*`/`b-*`/`mdc-*`
system. `.mdc-input`/`.mdc-select` bumped to 48px min-height / 16px font-size.
Applied to header buttons, compact-pane tabs, ActionPanel submit buttons, the
EventTrace show-all toggle, and the Cloud Backup checkbox wrapper.

### Browser Viewport Matrix

768×1024, 1024×768, 1180×820, 1280×800, 1440×900, 1920×1080 — verified in both
light and dark theme via this session's interactive Playwright MCP tooling (no
repo-level browser automation existed before D8C). No horizontal overflow at any
viewport. Compact layout confirmed not to force the desktop three-column shell.

### Screenshots Generated

9 screenshots under `artifacts/d8c-touch-verification/`: compact-light/dark
(768x1024), standard-light (1024x768) / standard-dark (1280x800), large-light/dark
(1920x1080), blocked-unit-compact (768x1024), stages-compact, events-compact.

### Accessibility Decisions

All new interactive elements are native `<button>`/`<details><summary>` — no
`<div onClick>` patterns. `StageSpine` rows remain non-interactive even inside the
new compact pane. No hover-gated content existed before D8C and none was introduced.
Existing `:focus` outline rules preserved.

### Architectural Reasoning

Kept the change additive and component-boundary-preserving: `FactoryFlowBoard.tsx`
became width-aware in how it *composes* the existing five child components, rather
than rewriting them. `EventTrace.tsx` is the one component with a real structural
change (table → responsive card list below `lg`) because it was the only component
using a fixed-column `<table>`; every other component was already close to
touch-compatible in its underlying structure (recon-confirmed).

### Discovered-and-Fixed Defect

`ActionPanel.tsx` and `UnitDetailPanel.tsx` read calibration cap-exceeded status from
`unit.calibration_status`, a field the backend never populates (only
`calibration_summary` is ever sent — confirmed via `curl`). This meant the
Calibration Disposition form never rendered for any capped-out unit, pre-existing
and unrelated to D8C's authorship but directly undermining D8C's "current action
must remain obvious" criterion. Fixed both to read `unit.calibration_summary`
(already correctly typed). No backend/schema/API change.

### Invariant Status

`bash scripts/invariant-check.sh` — 6/6 PASS (pre- and post-implementation).

### Verification Results

| Script | Result |
|--------|--------|
| 001-docker-compose-config.sh | PASS |
| 002-backend-health.sh | PASS |
| 003-frontend-reachable.sh | PASS |
| 004-data-contract-api.sh | PASS |
| 005-backend-state-behavior.sh | PASS |
| 006-factory-flow-board-ui.sh | PASS |
| 007-persistence-postgres.sh | PASS |
| 008-demo-readiness.sh | PASS |
| 009-light-mode-readability.sh | PASS |
| 010-material-theme-readability.sh | PASS |
| 011-touch-first-responsive-ui.sh | 32 PASS / 0 FAIL / 1 SKIP |
| smoke.sh | PASS |

### Smoke-Test Outcome

Compact touchscreen flow (1024×768 and 768×1024) and large workstation flow
(1920×1080) both manually exercised via interactive Playwright MCP session tooling:
unit selection, blocked-reason visibility, action submission form correctness (post
calibration_summary fix), theme toggle + reload persistence, and Reset Demo State
all confirmed working. See docs/touch-first-responsive-ui-d8c.md for full detail.

### Backend/Schema Confirmation

- Zero files under `backend/` modified.
- PostgreSQL schema, Alembic migrations, seed data — unchanged.
- All 20 endpoints in `frontend/src/api/factoryApi.ts` — unchanged, byte-identical.
- 14-stage canonical spine — unchanged.

### New Files

- `specs/touch-first-responsive-factory-ui-d8c.md` — spec (Status: approved, Phase: phase-ui)
- `ai/recon/d8c-touch-first-responsive-ui-recon.md` — recon
- `docs/touch-first-responsive-ui-d8c.md` — documentation
- `scripts/verification/011-touch-first-responsive-ui.sh` — 32 checks + 1 documented skip
- `tasks/touch-first-responsive-factory-ui-d8c-001..002.md` — task graph (both: done)
- `frontend/playwright.config.ts`, `frontend/tests/d8c-touch-responsive.spec.ts` — minimum browser-verification tooling (new devDependency: `@playwright/test`)
- `artifacts/d8c-touch-verification/*.png` — 9 screenshots

### Modified Files

- `frontend/src/styles.css` — touch-target utilities, form control sizing bump
- `frontend/src/components/FactoryFlowBoard.tsx` — responsive shell, compact pane switcher, D8C marker
- `frontend/src/components/UnitList.tsx` — 48px row floor
- `frontend/src/components/UnitDetailPanel.tsx` — block/no-override prominence, disclosure sections, calibration_summary fix
- `frontend/src/components/ActionPanel.tsx` — 48px buttons, destructive/supervisor variant colors, touch-safe checkbox, calibration_summary fix
- `frontend/src/components/EventTrace.tsx` — responsive card list below lg, touch-safe toggle
- `frontend/package.json` — added `@playwright/test` devDependency + `test:e2e` script
- `README.md`, `ai/repo-index.md`, `ai/architecture-index.md` — D8C phase updates

### Unresolved Risks

- Playwright cannot launch a browser inside the frontend service's Alpine (musl)
  runtime image — documented as a known limitation, non-blocking (see
  docs/touch-first-responsive-ui-d8c.md). Real browser verification for this release
  was performed interactively; the committed suite is for environments that can run
  it (developer machines, most CI images).
- Pre-existing stale documentation (`PROJECT_BOOTSTRAP.md`'s "D3 not yet started"
  line, `ai/runtime-contracts.md` Contract 4's "Postgres Deferred" line) was flagged
  in recon but left unfixed — out of D8C's declared scope.

### Next Safe Capability

Actor-specific assembler and floor-manager UI work is safe to begin as a new,
explicitly-directed phase. D8C does not implement authentication, role routing, or
any actor-specific application — the compact-width priority behavior (current unit →
block state → current stage → required action → ...) is groundwork only.

---

## D8C Addendum — State Registry Proxy Bug Discovered and Fixed

**Date:** 2026-07-02

While driving `touch-first-responsive-factory-ui-d8c` through the release gate, the
real `ai/state_registry.json` did not reflect a `state-manager.sh advance` call that
had just reported success. Root cause: `scripts/state-manager.sh`,
`scripts/compile-spec.sh`, `scripts/generate-tasks.sh`, and
`scripts/execution-supervisor.sh` are one-line proxies that `exec` into the vendored
OS scripts without first sourcing `.engineering-os/adapter.config.sh`. The vendored
`state-manager.sh` therefore never saw `EOS_STATE_REGISTRY` and fell back to a
`$0`-relative path, silently writing every state transition, for the life of this
project, to `vendor/engineering-os/ai/state_registry.json` instead of the real
project registry. `scripts/invariant-check.sh` was unaffected (it resolves the
adapter config independently, CWD-relative) — which is why INV-004 always passed
without ever catching this.

Fixed all four local proxies to source the adapter config before exec'ing (see
`ai/incidents/d8c-state-registry-proxy-bug.md` for full detail). This is a
local-adapter-layer fix, not a vendor-core change — `vendor/engineering-os/` was not
touched. Re-ran `touch-first-responsive-factory-ui-d8c`'s full legitimate state
sequence (`RECON_READY → SPEC_LOCKED → TASK_GRAPH_LOCKED → EXECUTION_ACTIVE →
VERIFICATION_REQUIRED → RELEASE_APPROVED`) against the now-correctly-resolving
registry; `ai/state_registry.json` now accurately shows `RELEASE_APPROVED` for this
feature. Historical backfill of prior phases' real transition history (visible in
the vendor-tree shadow file) was intentionally left as a follow-up recommendation,
out of D8C's scope.

---

### 2026-07-11

### Feature

d9c-1-variant-review-shell

### Phase

phase-ui

### Spec

specs/d9c-1-variant-review-shell.md

### Tasks


- tasks/d9c-1-variant-review-shell-001.md [frontend]
- tasks/d9c-1-variant-review-shell-002.md [verification]

### Implementation Notes

Executed by execution-supervisor.sh at 2026-07-11T19:17:23Z.
All 2 tasks completed. Verification passed.

### Pattern Updates

None.

### Incidents

None.

---

## D9C-1 Addendum — Variant Review Shell (full detail)

**Date:** 2026-07-11/12
**Branch:** `main`
**Capability:** `d9c-1-variant-review-shell` → `RELEASE_APPROVED`

### Architectural Reasoning

The incoming directive specified a flat 4-tab selector (Current / Assembler View /
Floor Manager / Operations Center). Recon (`ai/recon/d9c1-variant-review-shell.md`)
found this conflicted with the operator-settled D9B design (three functional variants —
Attention-First, Workflow-First, Command-Center — each with its own Assembler and Floor
Manager sub-view) and stopped per the directive's own "Conflict: STOP" rule rather than
building the literal wording. The operator was asked and chose: (1) the 3-variant ×
2-actor-view nested structure over the flat 4-tab reading, and (2) the full spec →
compile-spec → generate-tasks → execution-supervisor ceremony over direct
implementation. `specs/d9c-1-variant-review-shell.md` implements that decision.

The shell is reachable additively at `/#/variants`, implemented with a one-time hash
read in `frontend/src/main.tsx` (no routing library added, `frontend/package.json`
untouched). `/` (no hash) renders `<App />` completely unwrapped and unmodified — the
existing baseline is not touched.

### Files Modified/Created

- `frontend/src/components/variant-review/VariantReviewShell.tsx` (new) — primary
  4-tab switcher (Current / Variant A / Variant B / Variant C).
- `frontend/src/components/variant-review/VariantPlaceholderPane.tsx` (new) — secondary
  2-tab switcher (Assembler / Floor Manager) with placeholder-only body, no API calls.
- `frontend/src/main.tsx` — additive hash-gated `Root()` decision component.
- `frontend/src/styles.css` — additive-only tab-bar/placeholder-body CSS, reusing
  existing `surf-*`/`t-on-*`/`b-*`/`touch-target-*` tokens; zero new hardcoded colors.
- `specs/d9c-1-variant-review-shell.md`, `tasks/d9c-1-variant-review-shell-{001,002}.md`
  (new, OS pipeline artifacts).
- `ai/incidents/d9c1-worker-question-not-enforced.md` (new — see Incidents below).
- `artifacts/d9c1-variant-review-shell-verification/*.png` (new — manual browser
  verification evidence).

`frontend/src/App.tsx`, `FactoryFlowBoard.tsx` and all existing children,
`factoryApi.ts`, `types/factory.ts`, `package.json`, `package-lock.json`,
`vite.config.ts`, `index.html`, `tsconfig.json` — confirmed byte-for-byte unchanged.
Zero files under `backend/`, `data/`, `vendor/`, `.engineering-os/` touched.

### Invariant Status

`bash scripts/invariant-check.sh` — 6/6 PASS (both pre- and post-execution gates, per
the automated pipeline run).

### Verification Results

Full existing corpus `scripts/verification/001-011*.sh` — 0 FAIL across all 11 scripts
(011's one Playwright browser-launch check SKIPs gracefully, as it does on `main`
today). This was run three times independently: once as a pre-existing baseline before
any change, once inside the automated pipeline's per-task and final gates, and once
manually after the run. All three runs are clean.

Additionally verified manually, live, via Playwright MCP against the running docker
stack (not just the automated corpus):
- `/` loads and renders the unmodified `FactoryFlowBoard` (screenshot:
  `artifacts/d9c1-variant-review-shell-verification/d9c1-01-root-unchanged.png`).
- A fresh load of `/#/variants` renders the 4-tab primary bar
  (`d9c1-02-variants-shell-current.png`).
- Clicking "Variant A — Attention-First" renders its nested Assembler/Floor Manager
  switcher with the exact required placeholder copy, and clicking "Floor Manager"
  updates the pane reactively with no network request
  (`d9c1-03-variantA-assembler.png`).

### Unresolved Risks / Known Limitations

1. **Hash-only navigation does not trigger the shell without a reload.** Because
   `main.tsx` reads `window.location.hash` once at module load (by spec design, to avoid
   adding a routing library), navigating to `#/variants` from a page that is already
   loaded at `/` (e.g. editing only the fragment in the address bar, or an in-page
   `location.hash` change) does not show the shell until the page is actually reloaded —
   confirmed via manual Playwright testing. Opening `/#/variants` as a fresh link (new
   tab, or any real navigation) works correctly. **For the client demo: open the
   `/#/variants` link fresh (new tab) rather than editing the hash on an already-open
   tab.** A trivial follow-up (a `hashchange` listener in `main.tsx`) would remove this
   limitation entirely; left out of this capability's minimal shell/routing scope,
   candidate for a later polish node.
2. **See `ai/incidents/d9c1-worker-question-not-enforced.md`** — the verification-task
   worker correctly identified that its own prompt references `ai/execution-orchestrator.md`,
   which does not exist at that path (only vendored/archived copies exist), and it also
   flagged that root `PROJECT_BOOTSTRAP.md` is stale. It asked a clarifying question
   instead of declaring done; the supervisor's exit-code-only check did not actually
   pause the pipeline for that question. Verification passed on its own merits
   regardless (confirmed independently, see above), but this is a real gap in the
   self-running pipeline's ability to honor a worker's "stop and ask," worth its own
   directed hardening pass — not fixed here since it requires touching `vendor/**`,
   outside D9C-1's declared scope.
3. Real Assembler/Floor Manager content for all three variants remains out of scope by
   design (placeholder-only, later nodes D9C-5/6/7 per
   `ai/recon/d9c0-variant-review-shell-preflight-scope-lock.md` §7). No dedicated
   `scripts/verification/012-variant-review-shell.sh` exists yet — intentionally
   reserved for the later D9C-9 node; this capability's verification gate correctly runs
   the full existing corpus in fallback mode instead.

### Next Safe Capability

D9C-2 (derived frontend view models) or directly into D9C-5/6/7 (real content for one
variant at a time) are both safe to begin as separately directed nodes. Neither requires
further shell/routing rework.

---

### 2026-07-11

### Feature

d9c-2-shared-view-model

### Phase

phase-ui

### Spec

specs/d9c-2-shared-view-model.md

### Tasks


- tasks/d9c-2-shared-view-model-001.md [frontend]
- tasks/d9c-2-shared-view-model-002.md [verification]

### Implementation Notes

Executed by execution-supervisor.sh at 2026-07-11T19:54:21Z.
All 2 tasks completed. Verification passed.

### Pattern Updates

None.

### Incidents

None.

---

## D9C-2 Addendum — Shared View Model (full detail)

**Date:** 2026-07-11/12
**Branch:** `main`
**Capability:** `d9c-2-shared-view-model` → `RELEASE_APPROVED`

### Architectural Reasoning

The incoming directive's smoke test implied the three D9C-1 variant placeholders should
already visibly "consume" a shared view model — but that conflicted with two settled
facts: `ai/recon/d9c0-variant-review-shell-preflight-scope-lock.md` §7 scopes D9C-2 as
"derived frontend view models only (no new UI)", and `specs/d9c-1-variant-review-shell.md`
(already `RELEASE_APPROVED`) locked an acceptance criterion that the three placeholders
make zero API calls. Recon (`ai/recon/d9c2-shared-view-model.md`) surfaced this and
stopped. The operator resolved it: D9C-2 is architecture-only — build the canonical view
model, wire it into nothing. The operator also amended the forward DAG: **D9C-3** now
migrates Current onto the shared view model (refactor, zero behavior change); **D9C-4
through D9C-6** migrate the three variants individually, one per node. This supersedes
the equivalent portion of D9C-0's original D9C-3/4/5-7 labels.

`specs/d9c-2-shared-view-model.md` implements exactly this: a new, standalone
`frontend/src/view-model/{types.ts,useFactoryViewModel.ts}` pair, faithfully extracted
from `FactoryFlowBoard.tsx`'s existing fetch/selection/reset logic (same `Promise.all`
call order, same error handling, same mount-time effect — verified line-by-line, not
just by script), with **zero consumers wired**. `FactoryFlowBoard.tsx` and the D9C-1
variant components are untouched, confirmed via `git diff --stat` returning empty for
all of them.

### Files Modified/Created

- `frontend/src/view-model/types.ts` (new) — `FactoryViewModel` interface, all member
  types imported from `../types/factory`, no redefinition.
- `frontend/src/view-model/useFactoryViewModel.ts` (new) — `useFactoryViewModel()` hook,
  verbatim mirror of `FactoryFlowBoard.tsx`'s current logic (renamed `loadAll`→`reload`,
  `handleReset`→`resetDemoState` only).
- `specs/d9c-2-shared-view-model.md`, `tasks/d9c-2-shared-view-model-{001,002}.md` (new,
  OS pipeline artifacts).
- `ai/recon/d9c2-shared-view-model.md` (new — STOP recon, conflict + resolution record).

Confirmed byte-for-byte unchanged: `FactoryFlowBoard.tsx` and all existing children,
`VariantReviewShell.tsx`, `VariantPlaceholderPane.tsx`, `main.tsx`, `App.tsx`,
`styles.css`, `factoryApi.ts`, `types/factory.ts`, `package.json`, `package-lock.json`,
`vite.config.ts`, `index.html`, `tsconfig.json`. Zero files under `backend/`, `data/`,
`vendor/`, `.engineering-os/` touched. A `grep -rn "view-model"` across
`components/`/`main.tsx`/`App.tsx` returns no matches — confirmed zero consumers.

### Invariant Status

`bash scripts/invariant-check.sh` — 6/6 PASS (pre-execution, pre-verification, and a
manual re-run after the pipeline completed).

### Verification Results

Full existing corpus `scripts/verification/001-011*.sh` — 0 FAIL across all 11 scripts
(011's Playwright browser-launch check SKIPs gracefully, as on `main`). Run inside the
pipeline's per-task and final gates, then re-run manually after completion — all clean.
No live-browser re-verification was needed beyond this: since zero UI-rendering file
changed (confirmed by diff), the D9C-1 browser verification already on record continues
to hold unmodified.

### Unresolved Risks / Known Limitations

1. Deliberate, temporary duplication: `FactoryFlowBoard.tsx` still has its own internal
   copy of the same fetch/selection logic the new hook now also implements, until D9C-3
   migrates it. This is intentional per the operator's decision, not an oversight.
2. Same known adapter-path gap as `ai/incidents/d9c1-worker-question-not-enforced.md`
   (worker prompts reference `ai/execution-orchestrator.md`, which only exists vendored)
   — the task-002 worker independently re-noticed it, correctly treated it as
   non-blocking (same root cause, already documented), and did not stop this time since
   nothing new followed from it.
3. No actor-specific derived slices (attention items, per-actor assigned units, etc.)
   exist yet — intentionally deferred to D9C-4/5/6, since those are actor-specific
   concerns, not this node's "canonical, actor-agnostic facts" scope.

### Next Safe Capability

D9C-3 — migrate `FactoryFlowBoard` (Current) onto `useFactoryViewModel()`, a refactor
that must produce zero output/behavior change (verifiable against the full 001–011
corpus plus live browser re-verification, since this one *does* touch a rendered file).

---

### 2026-07-12

### Feature

d9c-3-current-baseline-shared-view-model-migration

### Phase

phase-ui

### Spec

specs/d9c-3-current-baseline-shared-view-model-migration.md

### Tasks


- tasks/d9c-3-current-baseline-shared-view-model-migration-001.md [frontend]
- tasks/d9c-3-current-baseline-shared-view-model-migration-002.md [verification]

### Implementation Notes

Executed by execution-supervisor.sh at 2026-07-12T20:26:19Z.
All 2 tasks completed. Verification passed.

### Pattern Updates

None.

### Incidents

None.

---

## D9C-3 Addendum — Current Baseline Shared View Model Migration (full detail)

### Architectural Reasoning

Recon (`ai/recon/d9c-3-current-baseline-shared-view-model-migration.md`) performed a
full field-by-field, operation-by-operation parity comparison between
`FactoryFlowBoard.tsx`'s pre-migration local state/orchestration and the D9C-2
`FactoryViewModel` contract, and found **full 1:1 parity with no conflict** — unlike
D9C-1 and D9C-2, this was a clean migration with nothing requiring an operator
`AskUserQuestion` pause. `useFactoryViewModel()` is now Current's sole owner of
factory-data loading, selection, refresh, and reset state; `FactoryFlowBoard.tsx`
retains only `theme`/`toggleTheme` and `compactPane` as local presentation state,
exactly as both the directive and the recon's independent parity analysis required.

### State-Ownership Migration Map

| Concern | Before | After |
|---|---|---|
| health, contractStatus, stages, units, events, users, parts, refStandards, selectedUnitId, selectedUnit, loadError, resetting | 12 local `useState`s in `FactoryFlowBoard.tsx` | Owned exclusively by `useFactoryViewModel()`, read via `vm.*` |
| loadAll / refreshSelected / selectUnit / handleReset | 4 local callbacks + 1 mount effect | `reload` / `refreshSelected` / `selectUnit` / `resetDemoState` inside the hook |
| theme, toggleTheme, theme effect | local | **unchanged, still local** |
| compactPane, setCompactPane | local | **unchanged, still local** |

### Duplicate Ownership Removed

All 11 `../api/factoryApi` imports and all 12 factory-data `useState`s plus 4
callbacks plus the mount-load effect were removed from `FactoryFlowBoard.tsx`.
Confirmed via direct read: the file now contains exactly one
`useFactoryViewModel()` call site and zero `factoryApi` imports.

### Presentation State Intentionally Retained Locally

`theme`/`toggleTheme` (with its `localStorage`/`data-theme` effect) and
`compactPane` remain local to `FactoryFlowBoard.tsx`, confirmed unchanged by direct
read and by live Playwright verification (theme persisted across a reload; compact
panes switched correctly at a 390px viewport).

### Protected Surfaces Confirmed Untouched

`git diff --stat` confirms only `frontend/src/components/FactoryFlowBoard.tsx`,
`ai/engineering-journal.md`, and `ai/state_registry.json` changed among tracked
files. `frontend/src/view-model/{types.ts,useFactoryViewModel.ts}`,
`frontend/src/components/variant-review/{VariantReviewShell.tsx,VariantPlaceholderPane.tsx}`,
`main.tsx`, `App.tsx`, `styles.css`, `api/factoryApi.ts`, `types/factory.ts`, and all
frontend config/lockfiles are byte-for-byte unchanged. Nothing under `backend/`,
`data/`, `vendor/`, `.engineering-os/` was touched.

### Invariant / Adapter Status

`bash vendor/engineering-os/scripts/os-adapter-check.sh` — 12/12 PASS (adapter valid),
run fresh at the start of this node. `bash scripts/invariant-check.sh` — 6/6 PASS, run
at pre-execution, pre-verification, and again after the manual fix described below.

### Verification Results (actual, independently re-run)

Full `scripts/verification/001`–`011` corpus: 0 FAIL across all 11 scripts (011's
Playwright browser-launch sub-check SKIPs gracefully, as on `main`). Exact per-script
pass counts on the fresh, post-fix re-run: 001=4/4, 002=4/4, 003=2/2, 004=10/10,
005=26/26, 006=12/12, 007=17/17, 008=17/17, 009=18/18, 010=21/21, 011=32/32 (+1 SKIP).
New `scripts/verification/012-d9c-3-current-shared-view-model.sh`: 8/8 PASS (see
Incident below for why this script did not exist until after the automated pipeline
run completed).

### Live Browser Verification (independent, beyond the automated pipeline)

Performed manually via Playwright MCP against the running dev stack:
initial load through `useFactoryViewModel()` confirmed (network trace shows the same
8-call sequence as pre-migration — verified identical by temporarily `git stash`-ing
the migration and reloading for direct comparison; the observed doubled request count
is pre-existing React 18 StrictMode dev-mode effect double-invocation, confirmed
present identically in the pre-migration code, not a regression); selected UNIT-0001
and confirmed Unit Detail/Stage Spine/Action Panel/Event Trace all updated correctly;
submitted an Assembly Scan action and confirmed `refreshSelected` updated the part
allocation, added a new event, and refreshed the unit list; toggled theme to Dark,
reloaded, and confirmed persistence; used Reset Demo State and confirmed selection
cleared, the injected event disappeared, and units returned to canonical order;
resized to 390×844 and confirmed the compact-pane tab switcher correctly toggled
between Unit Queue/Detail/Stages/Events; navigated to `/#/variants` (via a hard
reload, since same-document hash navigation does not re-trigger the route split — a
pre-existing, already-documented D9C-1 limitation) and confirmed the shell renders,
Current renders identically inside it, and Variant A's placeholder still shows
"Presentation content for this view ships in a later phase." with no new factory-data
calls triggered by switching tabs.

### Incident — Verification-Script Deliverable Skipped By Worker, Fixed By Orchestrator

Full detail in `ai/incidents/d9c3-verification-script-deliverable-skipped-by-worker.md`.
Summary: task 001's worker correctly refused to create
`scripts/verification/012-d9c-3-current-shared-view-model.sh` per its own hardcoded
"application source only, `scripts/` is off-limits" constraint (confirmed real by
reading `vendor/engineering-os/scripts/execution-supervisor.sh` directly — this
applies to every worker regardless of declared `## Layer`, not something specific to
this task). Task 002's worker independently confirmed the script was missing and
explicitly declared its own task "unfinished," but `execute_task()`'s exit-code-only
gate still marked both tasks `done` and the pipeline advanced to `RELEASE_APPROVED`
anyway. This is a second, more severe instance of the same gap in
`ai/incidents/d9c1-worker-question-not-enforced.md` (that one was a shrugged-off
question; this one was an explicitly-failed acceptance criterion). Resolution: since
no task-graph worker, under any layer, is ever permitted to write to `scripts/`, I
authored `scripts/verification/012-d9c-3-current-shared-view-model.sh` directly as the
orchestrator (the same ownership model already used for specs/recon/task files),
ran it (8/8 PASS), and re-ran the full corpus plus invariants fresh. State was already
`RELEASE_APPROVED` by the time this was discovered; not reset, since a task-graph
re-run would hit the identical wall. Process change recorded: any future
`scripts/verification/*.sh` deliverable must be authored by the orchestrator directly,
never delegated to a task file.

### Unresolved Risks / Known Limitations

1. Same adapter-path gap noted in prior capabilities
   (`ai/incidents/d9c1-worker-question-not-enforced.md`): worker prompts reference
   `ai/execution-orchestrator.md`, which only exists vendored. Non-blocking, already
   documented, not new.
2. The `scripts/`-off-limits-to-workers constraint (newly confirmed explicit in this
   node) means **any** future capability needing a new verification script must plan
   for orchestrator-authored script creation from the start, not delegate it — see
   incident file for the process change.
3. Hash-only navigation to `/#/variants` from an already-loaded page does not
   re-render (no `hashchange` listener) — pre-existing, documented D9C-1 limitation,
   re-confirmed here, not a D9C-3 regression.

### Final State

`d9c-3-current-baseline-shared-view-model-migration: RELEASE_APPROVED` in
`ai/state_registry.json`, substantively true as of the manual script fix — not merely
mechanically true as first written by the pipeline.

### Next Safe Capability

D9C-4 — migrate the first actor-first variant (Attention-First) onto
`useFactoryViewModel()`, per the operator-amended DAG recorded in
`specs/d9c-2-shared-view-model.md`. Not executed by this capability.
