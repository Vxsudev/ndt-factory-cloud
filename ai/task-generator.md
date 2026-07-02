# Task Generator — ndt-factory-cloud

## Purpose

This document defines the rules for generating task files from approved specifications.
The task generator is invoked by `scripts/generate-tasks.sh` and follows the
decomposition rules in `ai/spec-to-task-playbook.md`.

---

## Generator Inputs

```
Input:   specs/<feature-name>.md  (Status: approved)
Output:  tasks/<feature-name>-001.md through tasks/<feature-name>-NNN.md
```

---

## Generation Procedure

1. Read the approved spec from `specs/<feature-name>.md`.
2. Identify all layers touched (from the spec's "API Surface" and "Frontend Surface" sections).
3. Read `ai/spec-to-task-playbook.md` for layer ordering.
4. Decompose into atomic tasks, one per layer boundary.
5. Assign sequential task numbers starting at 001.
6. For each gate or hard-stop touched: create separate tasks for pass path, fail path,
   and disposition path.
7. Append a verification task as the final task.
8. Write task files to `tasks/`.

---

## Task Numbering

```
tasks/<feature>-001.md   — first task
tasks/<feature>-002.md   — second task
...
tasks/<feature>-NNN.md   — verification (always last)
```

Numbers are zero-padded to 3 digits. Features with more than 999 tasks should be split.

---

## Current State

D0-D2: No specs exist. No task files have been generated.

Task generation activates in D3 when the first spec reaches `approved` status.
