# Spec Generation — ndt-factory-cloud

## Purpose

This document defines the structure of a valid engineering specification for this
repository. All feature specs must conform to this structure before they are approved
and passed to the task generator.

---

## Spec File Location

```
specs/<feature-name>.md
```

Example: `specs/order-intake.md`, `specs/calibration-retry-loop.md`

---

## Required Spec Fields

Every spec must include all of the following sections:

```markdown
# Spec: <Feature Name>

Status: draft | approved
Phase: D3 | D4 | ...
Capability: <one-sentence description>

## Factory Stages Affected
<!-- Which of the 14 stages does this feature touch? -->

## Data Model
<!-- What data structures are created or modified? -->

## API Surface
<!-- What REST endpoints are added or changed? -->

## Frontend Surface
<!-- What UI components are added or changed? -->

## Domain Rules
<!-- What factory-flow-model.md rules does this implement? -->

## Dependencies
<!-- What other features or specs must be complete first? -->

## Acceptance Criteria
<!-- Testable pass/fail conditions -->

## Out of Scope
<!-- What explicitly does NOT belong in this feature? -->

## Verification Scripts
<!-- Optional: list specific scripts/verification/*.sh to run -->
```

---

## Spec Lifecycle

```
draft        — authored but not yet reviewed
approved     — approved by product authority; may generate tasks
blocked      — cannot proceed (dependency unresolved or invariant conflict)
complete     — all tasks executed and verified
```

Only `approved` specs may produce task files.

---

## Spec Quality Rules

1. Acceptance criteria must be testable (pass/fail, not vague descriptions).
2. Domain rules section must cite `docs/factory-flow-model.md` stage IDs.
3. Out of scope must include at least one explicit exclusion.
4. A spec that conflicts with any invariant in `ai/product-invariants.md` must be
   redesigned before it can reach `approved` status.
5. Specs must not contain implementation code — only descriptions of what is needed.
