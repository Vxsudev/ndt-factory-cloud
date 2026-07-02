# Spec Compiler — ndt-factory-cloud

## Purpose

The spec compiler is the deterministic procedure that converts a capability description
into a specification and task graph. It is the single entry point for all engineering
work in this repository.

Agents must follow this procedure when compiling capabilities.

---

## Spec Compilation Pipeline

```
Input:
  capability description
  phase tag (D3, D4, ...)

Output:
  specification: specs/<feature-name>.md  (Status: approved)
  task graph:    tasks/<feature-name>-NNN.md
```

Pipeline steps:

```
1.  capability intake      — read capability description; extract phase tag
2.  factory model check    — verify capability aligns with docs/factory-flow-model.md
3.  invariant validation   — check ai/product-invariants.md (no violations)
4.  contract check         — check ai/runtime-contracts.md (no violations)
5.  boundary check         — check ai/service-boundaries.md (correct ownership)
6.  pattern selection      — identify coding patterns from ai/coding-patterns.md
7.  spec generation        — author spec per ai/spec-generation.md structure
8.  spec approval          — product authority sets Status: approved
9.  task generation        — decompose per ai/spec-to-task-playbook.md
10. execution loop handoff — hand to ai/execution-loop-controller.md
11. verification gate      — run scripts/verification/ after implementation
12. journal entry          — append to ai/engineering-journal.md
```

Each step is a gate. If a step fails, the pipeline halts.

---

## Halt Conditions

Compilation halts and must not proceed if:

- The capability conflicts with any RATIFIED invariant.
- The capability requires a runtime contract violation.
- The capability crosses a forbidden service boundary.
- A required coding pattern does not exist and no amendment has been approved.
- The capability references stages outside the 14-stage spine without a model update.
- The spec is incomplete (missing required sections per ai/spec-generation.md).

---

## Current State

D0-D2: No capabilities have been compiled. No specs exist. No tasks exist.

The first spec will be authored in D3 Stack Scaffold.
