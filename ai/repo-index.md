# Repo Index — ndt-factory-cloud

**Phase:** D0-D2 Bootstrap Complete
**Date:** 2026-06-30
**Next Phase:** D3 Stack Scaffold (not yet started)

This document is the navigation reference for the repository. Read it after the
Engineering OS boot sequence to orient before doing any work.

---

## Repository State Summary

| Phase | Name                          | Status      |
|-------|-------------------------------|-------------|
| D0    | Repository Decision Lock      | COMPLETE    |
| D1    | OS Vendor Bootstrap            | COMPLETE    |
| D2    | Factory Domain Model Freeze   | COMPLETE    |
| D3    | Stack Scaffold                | NOT STARTED |
| D4+   | Feature Implementation        | NOT STARTED |

**No application code exists yet.** No React/Vite frontend, no FastAPI backend,
no Docker Compose file, no Postgres, no specs, no tasks.

---

## Directory Map

```
ndt-factory-cloud/
│
├── CLAUDE.md                    ← Agent entry point. Read first.
├── PROJECT_BOOTSTRAP.md         ← Full boot sequence. Read second.
├── ENGINEERING_OS.md            ← Engineering OS doctrine for this repo.
│
├── docs/                        ← DOMAIN AUTHORITY (not app code)
│   ├── decision-lock.md         ← D0: Locked repository decisions
│   ├── factory-flow-model.md    ← D2: Authoritative 14-stage production spine
│   └── domain-glossary.md       ← D2: Canonical factory domain terms
│
├── ai/                          ← ENGINEERING OS GOVERNANCE (not app code)
│   ├── product-invariants.md    ← Non-negotiable factory constraints
│   ├── runtime-contracts.md     ← Runtime boundary rules
│   ├── service-boundaries.md    ← Service ownership rules
│   ├── coding-patterns.md       ← Implementation pattern declarations
│   ├── spec-generation.md       ← Spec structure definition
│   ├── spec-compiler.md         ← Spec compilation pipeline
│   ├── spec-to-task-playbook.md ← Spec → task decomposition rules
│   ├── task-generator.md        ← Task generation rules
│   ├── task-graph.md            ← Task dependency and ordering
│   ├── execution-loop-controller.md  ← Deterministic execution loop
│   ├── execution-orchestrator.md     ← Multi-feature orchestration
│   ├── verification-playbook.md      ← Verification gate definition
│   ├── debug-playbook.md             ← Debugging procedure
│   ├── architecture-index.md         ← Planned system architecture
│   ├── repo-index.md                 ← This file
│   └── engineering-journal.md        ← Append-only capability history
│
├── scripts/                     ← OS PIPELINE SCRIPTS
│   ├── compile-spec.sh          ← Placeholder (D3 activates)
│   ├── generate-tasks.sh        ← Placeholder (D3 activates)
│   ├── execution-supervisor.sh  ← Placeholder (D3 activates)
│   └── smoke.sh                 ← Active: verifies D0-D2 bootstrap artifacts
│
│   [created in D3]
│   └── verification/            ← Feature verification scripts
│
│   [created in D3]
├── frontend/                    ← React + Vite + TypeScript (D3)
├── backend/                     ← FastAPI + Pydantic (D3)
├── specs/                       ← Spec artifacts (D3)
├── tasks/                       ← Task artifacts (D3)
└── docker-compose.yml           ← Runtime config (D3)
```

---

## Key Authority Documents

| Question                                   | Read this                       |
|--------------------------------------------|---------------------------------|
| What are the 14 production stages?         | docs/factory-flow-model.md      |
| What does "hard-stop" mean?                | docs/domain-glossary.md         |
| What are the locked decisions?             | docs/decision-lock.md           |
| What can the system NOT do?                | ai/product-invariants.md        |
| What is the stack and runtime posture?     | ai/runtime-contracts.md         |
| What owns what?                            | ai/service-boundaries.md        |
| What coding patterns must I follow?        | ai/coding-patterns.md           |
| How do I author a spec?                    | ai/spec-generation.md           |
| How do I compile a capability?             | ai/spec-compiler.md             |
| How do I execute tasks?                    | ai/execution-loop-controller.md |
| What is the history of completed work?     | ai/engineering-journal.md       |

---

## What Is Missing (to be created in D3)

- `frontend/` — React + Vite + TypeScript scaffold
- `backend/` — FastAPI + Pydantic scaffold
- `docker-compose.yml` — Docker Compose runtime
- `.env.example` — Environment variable template
- `specs/` — No specs yet
- `tasks/` — No tasks yet
- `scripts/verification/` — Verification scripts (smoke.sh is the only active check now)
