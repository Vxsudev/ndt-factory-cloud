# Task Graph — ndt-factory-cloud

## Purpose

This document defines how tasks within a feature are ordered, how dependencies are
declared, and how the execution controller resolves task sequencing.

---

## Task Graph Structure

A task graph is the complete ordered set of tasks for a single feature. The graph is
implicit in the task file numbering and explicit dependency declarations in each task file.

```
tasks/<feature>-001.md
tasks/<feature>-002.md   (depends on 001)
tasks/<feature>-003.md   (depends on 001, independent of 002)
tasks/<feature>-004.md   (depends on 002 and 003)
tasks/<feature>-005.md   (verification, depends on all prior)
```

---

## Dependency Rules

1. Tasks execute in ascending numeric order unless a dependency is explicitly listed
   in the task file as an exception.
2. A task with `Status: blocked` cannot be started until its dependency reaches
   `Status: complete`.
3. The verification task (always last) depends on all prior tasks being complete.
4. Cross-feature dependencies must be declared at the spec level, not the task level.

---

## Graph Invariants

- No circular dependencies.
- No task may depend on a task from a different feature.
- The final task in every graph is always a verification task.
- A task marked `complete` is never reopened. If a bug is found, a new task is created.

---

## Multi-Feature Sequencing

When multiple features are active concurrently, the execution orchestrator
(`ai/execution-orchestrator.md`) manages ordering between them. Task graphs for
different features do not reference each other's task numbers.

---

## Current State

D0-D2: No task graphs exist. All task graph activity begins in D3.
