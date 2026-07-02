# Spec-to-Task Playbook — ndt-factory-cloud

## Purpose

This document defines how approved specifications are decomposed into a task graph.
Tasks are the atomic execution units that agents and developers work through in order.

---

## Task File Location

```
tasks/<feature-name>-NNN.md
```

Examples:
```
tasks/order-intake-001.md   — backend: order model
tasks/order-intake-002.md   — backend: order router
tasks/order-intake-003.md   — frontend: order form component
tasks/order-intake-004.md   — frontend: order list page
tasks/order-intake-005.md   — verification: smoke test
```

---

## Task File Structure

```markdown
# Task: <Feature Name> — NNN — <Short Description>

Feature: <feature-name>
Task: NNN
Status: pending | in_progress | complete | blocked

## Objective
<!-- One sentence: what does this task produce? -->

## Layers Touched
<!-- backend | frontend | docker | scripts | docs -->

## Dependencies
<!-- Task NNN-1 must be complete before this task begins -->

## Implementation Notes
<!-- Specific instructions for this task -->

## Files to Modify
<!-- Expected file list -->

## Acceptance Criteria
<!-- Testable pass/fail conditions for this task -->
```

---

## Decomposition Rules

1. Each task targets a single engineering layer (backend, frontend, docker, scripts, docs).
2. Tasks are sequentially numbered starting at 001.
3. Dependencies between tasks must be explicit (not implied).
4. A task must not span multiple features.
5. The final task in every feature is always a verification task.
6. The total number of tasks depends on feature complexity — no artificial minimums
   or maximums.

---

## Layer Order Convention

When a feature spans multiple layers, tasks follow this ordering:

```
1. Data models (backend/app/models/)
2. State store additions (backend/app/state/)
3. Domain logic (backend/app/domain/)
4. API router (backend/app/routers/)
5. API client (frontend/src/api/)
6. UI components (frontend/src/components/)
7. Page integration (frontend/src/pages/)
8. Verification
```

Steps may be skipped if the feature does not touch that layer.

---

## Factory Domain Decomposition Guidance

When a capability touches a gate or hard-stop:
- Separate tasks for: gate check logic, gate pass path, gate fail path, supervisor
  disposition path.

When a capability touches calibration:
- Separate tasks for: attempt recording, attempt counter check, certificate generation,
  hard-stop raise on third failure.

When a capability touches QC pass → production record finalization:
- Separate tasks for: QC sign-off recording, post-QC guard enforcement (S-12 blocked until
  S-11 complete), production record read-only enforcement for post-QC units.
