# ENGINEERING_OS.md — ndt-factory-cloud

## Purpose

This document describes the **Engineering Operating System (Engineering OS)** used by the
`ndt-factory-cloud` repository.

The Engineering OS defines how capabilities move from product ideas to verified production
code through a deterministic engineering pipeline.

This document exists so that AI agents, developers, and future sessions can immediately
understand the system architecture without reconstructing it from scattered documents.

---

# Core Principle

Engineering work is treated as a deterministic pipeline, not an open-ended development
process.

```
capability
↓
specification
↓
tasks
↓
implementation
↓
verification
↓
journal
```

Agents must not bypass this pipeline.

---

# Engineering Pipeline

```
capability description
↓
SPEC COMPILER           (ai/spec-compiler.md)
↓
specification (specs/<feature>.md, Status: approved)
↓
TASK GENERATOR          (ai/task-generator.md)
↓
task graph (tasks/<feature>-NNN.md)
↓
EXECUTION LOOP CONTROLLER (ai/execution-loop-controller.md)
↓
implementation
↓
verification gate       (scripts/verification/)
↓
engineering journal entry (ai/engineering-journal.md)
↓
capability completed
```

---

# Control Layer Overview

The Engineering OS is implemented through documents in `ai/`.

## Architecture Authority (what the system is allowed to do)

```
ai/product-invariants.md   — non-negotiable factory production constraints
ai/runtime-contracts.md    — runtime interaction rules between services
ai/service-boundaries.md   — ownership of system components
```

## Engineering Protocol (how work is produced)

```
ai/spec-compiler.md          — compiles capabilities into specs and task graphs
ai/spec-generation.md        — defines valid spec structure
ai/spec-to-task-playbook.md  — decomposes specs into tasks
ai/task-generator.md         — task generation rules
ai/task-graph.md             — task dependency and ordering rules
ai/execution-loop-controller.md  — deterministic task execution pipeline
ai/execution-orchestrator.md     — multi-capability orchestration
ai/coding-patterns.md        — implementation patterns for this stack
```

## Operational Safety (how the system detects and responds to failure)

```
ai/verification-playbook.md  — verification gate definition
ai/debug-playbook.md         — deterministic debugging procedure
ai/engineering-journal.md    — append-only capability history
```

## Navigation

```
ai/repo-index.md             — repository structure map
ai/architecture-index.md     — planned system architecture
```

## Domain Authority

```
docs/factory-flow-model.md   — authoritative 14-stage production spine
docs/domain-glossary.md      — canonical factory domain terms
docs/decision-lock.md        — locked repository decisions (D0)
```

---

# Stack

| Layer       | Technology                    |
|-------------|-------------------------------|
| Frontend    | React + Vite + TypeScript     |
| UI          | Tailwind + shadcn/ui          |
| Backend     | FastAPI + Pydantic            |
| State (v0)  | Mock JSON / in-memory         |
| Database    | Postgres (deferred)           |
| Runtime     | Docker Compose                |
| Cloud       | Cloud-neutral (Azure-ready)   |

---

# Factory Domain Authority

The factory production spine, stage types, transition rules, and control gates are
defined in:

```
docs/factory-flow-model.md
```

This document is frozen (D2). All backend state machine logic and frontend display
must reference it. No agent may invent or reorder stages without a new directive.

All domain terminology is defined in:

```
docs/domain-glossary.md
```

---

# Phase Boundary

| Phase | Description               | Status         |
|-------|---------------------------|----------------|
| D0    | Repository Decision Lock  | COMPLETE       |
| D1    | OS Vendor Bootstrap        | COMPLETE       |
| D2    | Factory Domain Model Freeze | COMPLETE     |
| D3    | Stack Scaffold             | NOT STARTED    |
| D4+   | Feature Implementation     | NOT STARTED    |

Advancing beyond D2 requires an explicit D3 directive.

---

# Enforcement

Pipeline correctness is enforced by:
1. Script gates — `scripts/compile-spec.sh`, `scripts/generate-tasks.sh`, `scripts/execution-supervisor.sh`
2. Smoke verification — `scripts/smoke.sh` (active in D0-D2)
3. Full verification — `scripts/verification/` (active from D3 onwards)

---

# Development Philosophy

This repository does not implement features through ad-hoc coding.

It uses a structured pipeline that ensures:
- architectural integrity
- deterministic engineering workflows
- traceable system evolution
- safe AI-assisted development

All agents and developers must follow this system.
