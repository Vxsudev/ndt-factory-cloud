# PROJECT_BOOTSTRAP.md

## Purpose

This file initializes the **Engineering Operating System** for the `ndt-factory-cloud`
repository.

Any AI agent, developer, or automation entering this repository must read this file first
and load the Engineering OS context before performing any work.

The Engineering OS defines the deterministic engineering pipeline used by this repository.

Agents must not begin implementation without loading this context.

---

# Boot Sequence

Upon entering the repository, perform the following initialization sequence.

---

## Step 1 — Load Engineering OS

Read:

```
ENGINEERING_OS.md
```

This document explains the full engineering protocol used by the repository.

It describes:
- the capability → spec → tasks pipeline
- the control layer architecture
- the verification gate
- the engineering journal

Agents must understand this system before continuing.

---

## Step 2 — Load Control Layer

Read the following documents in order:

```
ai/product-invariants.md
ai/runtime-contracts.md
ai/service-boundaries.md
ai/coding-patterns.md
ai/spec-compiler.md
ai/spec-generation.md
ai/spec-to-task-playbook.md
ai/task-generator.md
ai/task-graph.md
ai/execution-loop-controller.md
ai/execution-orchestrator.md
ai/verification-playbook.md
ai/debug-playbook.md
ai/architecture-index.md
ai/repo-index.md
ai/engineering-journal.md
```

These documents define the system's architecture, engineering protocol, and operational
safeguards.

The factory domain model (authoritative for all stage and domain definitions):

```
docs/factory-flow-model.md
docs/domain-glossary.md
```

---

## Step 3 — Load Repository Map

Read:

```
ai/repo-index.md
```

This provides a compact map of the repository structure.

---

## Step 4 — Determine Current Engineering State

Read:

```
ai/engineering-journal.md
```

This document describes the active phase, completed work, and what is next.

---

# Engineering Rule

Agents must not implement features directly.

All work must follow the deterministic pipeline:

```
capability
↓
spec compiler
↓
specification
↓
tasks
↓
execution controller
↓
verification
↓
engineering journal
```

Agents must not bypass this pipeline.

---

# Current Repository State

**Active phase:** D0-D2 Bootstrap Complete — D3 Stack Scaffold not yet started.

No application code (React, FastAPI, Docker Compose) exists yet.
No specs have been authored yet.
No tasks have been generated yet.

The next phase is D3 Stack Scaffold, which requires a new directive.

---

# Verification

After any engineering work, run:

```
bash scripts/smoke.sh
```

This verifies the D0-D2 bootstrap artifacts are intact.

Full verification scripts live in `scripts/verification/` once D3 is active.

---

# System Philosophy

This repository does not use ad-hoc feature development.

It uses a deterministic engineering pipeline that ensures:
- architectural integrity
- pattern consistency
- safe AI-assisted development
- traceable system evolution

All agents and developers must follow this system.
