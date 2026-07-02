# Execution Orchestrator — ndt-factory-cloud

## Purpose

The execution orchestrator coordinates engineering work when multiple features are
active concurrently. It determines sequencing across feature boundaries, resolves
cross-feature dependency conflicts, and ensures that the factory domain model is not
violated by conflicting concurrent changes.

For single-feature work, the execution loop controller (`ai/execution-loop-controller.md`)
is sufficient.

---

## When the Orchestrator Is Needed

- Multiple approved specs are in the task queue simultaneously.
- One feature's tasks touch the same files or domain areas as another.
- A higher-priority capability must be inserted while a lower-priority one is in progress.

---

## Orchestration Rules

1. Only one feature may be `in_progress` in the factory stage machine domain at a time.
   (The backend domain logic, stage state store, and gate logic are single-ownership.)
2. Frontend features may run concurrently with each other but not concurrently with a
   backend feature that changes their API contract.
3. Verification must run for a completed feature before the next feature begins
   implementation in the same layer.
4. Prioritization: product authority determines priority order when multiple specs are
   approved. The orchestrator executes in priority order.

---

## Sequencing Protocol

```
1. List all approved specs with Status: approved
2. Order by product authority priority
3. Check for layer conflicts with any in_progress spec
4. If no conflict: begin next spec's task execution (execution-loop-controller.md)
5. If conflict: queue the conflicting spec; complete in_progress spec first
6. After each feature completes verification: re-evaluate the queue
```

---

## Cross-Feature Dependencies

If spec B depends on spec A:
- Spec B must declare the dependency in its "Dependencies" section.
- Spec B tasks must not begin until spec A is `complete`.
- The orchestrator enforces this by checking the journal for spec A's completion entry.

---

## Current State

D0-D2: No features are in execution. Orchestrator is not yet active.

Orchestration begins in D4+ when multiple concurrent features are expected.
