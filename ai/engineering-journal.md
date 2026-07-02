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
