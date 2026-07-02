# Execution Loop Controller — ndt-factory-cloud

## Purpose

This document defines the deterministic task execution loop used by AI agents when
developing capabilities in this repository.

The controller coordinates the engineering control layer and ensures development follows
the spec-driven workflow.

Agents must follow this controller when performing engineering work.

---

## Execution Sequence

For a single feature:

```
1. Verify spec is Status: approved
2. Verify task graph exists (tasks/<feature>-001.md through NNN.md)
3. Verify no active invariant violations (ai/product-invariants.md)
4. Mark first pending task Status: in_progress
5. Execute task (implement per task instructions)
6. Mark task Status: complete
7. Advance to next pending task
8. Repeat steps 5-7 until all tasks complete
9. Run verification gate (scripts/verification/ or smoke.sh)
10. Append journal entry to ai/engineering-journal.md
11. Mark feature complete
```

---

## Phase Boundary Enforcement

The controller validates that each task's layer matches the active phase:

- D3: Stack Scaffold — only scaffolding tasks (Docker Compose, Vite config, FastAPI
  main.py stubs, component skeletons)
- D4+: Feature Implementation — domain logic, API routes, UI pages

Tasks that attempt to implement domain features during D3 must be flagged and deferred.

---

## Halt Conditions

The execution loop halts and must not continue if:

- An invariant violation is detected during execution.
- A task introduces a pattern not in `ai/coding-patterns.md` without an approved amendment.
- Verification fails after task completion.
- A hard-stop equivalent is encountered in the engineering pipeline (e.g., spec conflict
  discovered mid-execution).

If halted: document the issue, do not proceed, report to product authority.

---

## Task Status Lifecycle

```
pending → in_progress → complete
pending → blocked (dependency not met)
in_progress → blocked (mid-execution halt)
```

---

## Current State

D0-D2: No features are in execution. No tasks exist.

Execution loop activates in D3.
