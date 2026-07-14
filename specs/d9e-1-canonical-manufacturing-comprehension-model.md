# Spec: Canonical Stage, Failure, Recovery, and Authority Model (D9E-1)

## Status
approved

## Phase
phase-ui

## Feature
d9e-1-canonical-manufacturing-comprehension-model

## Capability

Today, manufacturing comprehension evidence exists only inside `ai/recon/d9e-0-manufacturing-
comprehension-recon.md` — a recon artifact, not a governed, citable canonical source — and inside
three existing documents that carry known, operator-resolved drift (`docs/factory-flow-model.md`'s
stale gate typing/authority vocabulary/phantom Stage-8 failure; `docs/demo-walkthrough-d8.md`'s
incorrect "supervisor clears the cloud block" narrative). After this capability, one canonical
document — `docs/manufacturing-comprehension-model.md` — exists as the single, governed source that
all later D9E nodes (D9E-2 through D9E-7) must consume for stage, failure, recovery, authority, and
semantic-classification truth. It encodes the complete 14-stage model, all 22 evidence-backed
failure modes with stable comprehension identifiers mapped to raw backend codes, every recovery
path with an implementation-status classification, the operator-locked actor/role/authority model
(including the Floor-Manager-vs-Manager Scrap rule), the operator-locked composable three-axis
semantic model, the serialized-traceability chain, and the full TBD/exclusion register — all
without changing any application behavior. Two existing documents receive narrow, operator-
authorized corrections (`docs/factory-flow-model.md`, `docs/demo-walkthrough-d8.md`), and one new,
additive UI-facing glossary (`docs/glossary.md`) is created.

## Source Authority

- `ai/recon/d9e-0-manufacturing-comprehension-recon.md` — primary evidence base (§10–§14, §21,
  §24–§28, §31, §37). This spec does not re-derive that evidence; it canonicalizes it.
- `ai/recon/d9e-1-canonical-manufacturing-comprehension-model.md` — this node's own recon,
  confirming predecessor validation, zero new drift beyond what D9E-0 already found, and the exact
  mutation plan.
- Operator decision-lock continuation (recorded in D9E-0 §25/§27/§28/§31/§37) — binding for every
  correction and classification in this spec. Superseded proposals retained in D9E-0 are historical
  evidence, not active authority, per the directive.
- `ai/product-invariants.md` Invariant 1 (Factory Flow Model Authority) — this spec's corrections to
  `docs/factory-flow-model.md` are exactly the kind of narrow, directive-authorized model-update
  this invariant requires before any stage/authority text may be corrected.

## Erratum (recorded during this capability's execution, operator-resolved)

D9E-0 reported 21 normalized failure entries. Direct row-level recount during D9E-1 execution
established **22**. The discrepancy was caused by an arithmetic/catalog-counting error during
D9E-0's original authoring, not by a newly discovered manufacturing condition — `FM-WRONG-STAGE`
and `FM-AUTH-INSUFFICIENT` were always separately present and independently evidence-backed in
D9E-0 §11 (different triggers, different raw codes/response shapes, different recovery paths).
This is a bookkeeping correction only: it does not reopen any of D9E-0's C1–C8 operator
resolutions, does not add a manufacturing rule, does not expand capability, and does not authorize
any backend/frontend change. `ai/recon/d9e-0-manufacturing-comprehension-recon.md` (the pushed,
immutable D9E-0 artifact) is **not** modified by this correction — the count of 22 is canonical
from this point forward in every active D9E-1 artifact and the new canonical model; D9E-0's
original "21" figure remains in place in that historical artifact as evidence of what was
originally reported.

## Current Problem

1. No single, governed, citable document exists for stage/failure/recovery/authority/semantic
   comprehension truth — only a recon artifact and scattered, partially-stale existing docs.
2. `docs/factory-flow-model.md` types Stage 9 as "factory core" rather than a gate, lists a fourth
   "Technician" authority tier absent from the BRS, assigns QC sign-off to "Supervisor" rather than
   the distinct QC authority, and carries a phantom Stage-8 failure row with no implementation or
   BRS/flowchart support.
3. `docs/demo-walkthrough-d8.md` states "the supervisor clears the block" for both cloud hard-stops,
   contradicting the BRS's explicit "no override" language and the operator's resolved recovery
   narrative.
4. No UI-facing glossary exists distinct from the frozen domain glossary, scoped to the
   comprehension terms later D9E copy work will need to define consistently.

## Non-Goals / Out of Scope

- No frontend component, page, or rendering change of any kind.
- No backend route, model, schema, or workflow-rule change of any kind.
- No `data/*.json` or `source-materials/**` change of any kind.
- No fix to any of D-1 through D-10 (the implementation-defect register) — those are D9E-2's scope.
- No new failure mode, recovery path, actor view, or authentication capability.
- No widening of actor-variant action mappings (C7, operator-resolved: hand off to Current instead).
- No wiring of `/factory/orders` or `/factory/model-recipes` into the shared view model (C8,
  operator-resolved: remain outside this plan).
- No design tokens, component primitives, or in-application explanatory copy — those are D9E-3/D9E-5.
- No demo-narrative UI or review-shell guidance surface — that is D9E-4.
- No modification to `docs/domain-glossary.md` (the frozen D2A domain glossary) — `docs/glossary.md`
  is a new, additive, UI-facing glossary, distinct from it (see recon §8).
- No new `specs/phases/*.md` file — this spec uses the existing `phase-ui` tag.
- No modification to any of `AGENTS.md`, `ai/recon/d9c2-shared-view-model.md`, or any existing
  D9A–D9E-0 recon/spec/task artifact, or verification scripts `001`–`016`.

## Data Model Changes
none

## API Surface
none

## Frontend Surface
none

## Operational Workflow

1. Orchestrator authors `docs/manufacturing-comprehension-model.md` per the canonicalization plan
   in this node's recon §7/§9, transforming D9E-0's evidenced findings into the directive's
   22-section canonical schema, with every stage/failure/recovery entry carrying exactly one
   `DOCUMENTED_VS_IMPLEMENTED`-family classification.
2. Orchestrator authors `docs/glossary.md` (new, additive, 15 terms per recon §8).
3. Orchestrator applies the two narrow corrections to `docs/factory-flow-model.md` (Stage-9 gate
   typing, authority vocabulary, Stage-8 row removal/marking) and `docs/demo-walkthrough-d8.md`
   (cloud-recovery narrative correction), both cross-referencing the new canonical document.
4. Orchestrator authors `scripts/verification/017-d9e-1-canonical-manufacturing-comprehension-
   model.sh` directly (never delegated to a task-graph worker, per
   `ai/incidents/d9c3-verification-script-deliverable-skipped-by-worker.md`).
5. Task file(s) generated by `generate-tasks.sh` are filled in with content matching steps 1–4 above
   (a consistency-review pass folded into the same generated task, since the spec's `none`
   declarations across Data Model/API/Frontend Surface mean only the always-required `verification`
   layer is auto-generated — recorded as an expected, non-conflicting deviation from a literal
   two-task graph, per this node's recon §10).
6. Full verification corpus `001`–`017` run manually, per-script, with exit codes recorded
   (mitigating the documented supervisor stdin-drain defect).
7. `ai/engineering-journal.md` entry appended recording the capability, corrections, and D9E-2
   handoff.

## Dependencies

- `ai/recon/d9e-0-manufacturing-comprehension-recon.md` — must remain `RECON_APPROVED —
  READY_FOR_D9E-1` (unmodified by this spec).
- `ai/product-invariants.md` Invariant 1 — governs the scope of the `docs/factory-flow-model.md`
  correction.
- `ai/incidents/d9c3-verification-script-deliverable-skipped-by-worker.md`,
  `ai/incidents/d9c5-execution-supervisor-stdin-truncated-verification-loop.md` — govern
  verification-script authorship and the manual full-corpus re-run requirement.

## Acceptance Criteria

- [ ] `docs/manufacturing-comprehension-model.md` exists, carries the status line
      `CANONICAL — OPERATOR_LOCKED THROUGH D9E-0; IMPLEMENTED BY D9E-1`, and contains all 22
      directive-required sections.
- [ ] All 14 stages appear in canonical order with the full required per-stage schema.
- [ ] Stages 9, 10, and 11 are documented as the only three canonical gates; no other stage is
      typed as a gate.
- [ ] All **22** evidence-backed failure entries from D9E-0 §11 are present with stable
      comprehension identifiers, raw-backend-code mappings (many-to-one and context-dependent
      cases recorded explicitly, not collapsed), and a `DOCUMENTED_VS_IMPLEMENTED`-family
      classification each. `FM-WRONG-STAGE` and `FM-AUTH-INSUFFICIENT` are independently present
      (distinct triggers, distinct recovery paths) and must not be merged. If further evidence
      revalidation changes this count again: STOP, do not silently change it, report to the
      operator (per the erratum above, resolving the AC-4 conflict this capability originally hit).
- [ ] No Stage-8 failure is documented as canonical; the phantom row is removed or explicitly marked
      non-canonical in `docs/factory-flow-model.md`, and no equivalent entry appears in the new
      canonical model.
- [ ] Stage 7 and Stage 12 are each documented as no-override cloud hard-stops with distinct
      current-recovery availability (Stage 7: no existing recovery action; Stage 12: retry exists
      and is documented as a re-check, not a Supervisor override).
- [ ] The actor/role/authority model distinguishes UI actor, operational role, and action authority;
      Technician is documented as a role, not a tier; QC authority remains distinct from Supervisor
      and Manager; Manager authority is documented as not implying QC-signoff authority.
- [ ] The Floor-Manager-vs-Manager rule is documented: Scrap requires Manager authorization and must
      not be presented as Floor Manager authority in later UI work.
- [ ] All three composable semantic axes (Manufacturing State, Constraint, Ownership/Actionability)
      are documented, explicitly marked composable (not a flat mutually-exclusive enum), and mapped
      against every failure-mode entry, including the locked Stage-12 worked example verbatim.
- [ ] The complete serialized-traceability chain (serial → allocation → binding → genealogy →
      reallocation history → calibration history → QC finalization → cloud backup → terminal
      immutability) is documented without weakening traceability.
- [ ] All 12 D9E-0 TBDs are carried forward with an explicit disposition each (affects D9E-1?
      mentionable in later UI? excluded from demo claims? requires a future capability?).
- [ ] `docs/factory-flow-model.md` and `docs/demo-walkthrough-d8.md` agree with the canonical model
      on every operator-resolved point (C1–C4) and cross-reference it; no other content in either
      file is altered.
- [ ] `docs/glossary.md` exists with the 15 directive-named terms, agreeing with the canonical
      model, without introducing UI-styling rules (reserved for D9E-3).
- [ ] Zero modification to any frontend, backend, data, source-material, vendor, Docker, package/
      lock-file, or existing verification-script (`001`–`016`) path.
- [ ] `scripts/verification/017-d9e-1-canonical-manufacturing-comprehension-model.sh` exists
      (orchestrator-authored), is non-mutating, and asserts every item above.
- [ ] Full `001`–`017` corpus passes when run individually, in a plain shell loop, with recorded
      exit codes proving scripts after `007` actually executed.
- [ ] `bash scripts/invariant-check.sh` reports 6/6 PASS both before and after this capability.
- [ ] `ai/engineering-journal.md` carries a new entry documenting this capability, its corrections,
      and the D9E-2 handoff (not executed).
- [ ] Capability reaches `RELEASE_APPROVED` in `ai/state_registry.json`.

## Out of Scope

See Non-Goals above: no application code, no data, no new failure/recovery/actor capability, no
D-1…D-10 fixes, no D9E-2/D9E-3/D9E-4 work, no new phase file, no modification to the frozen domain
glossary or any protected D9A–D9E-0 artifact.
