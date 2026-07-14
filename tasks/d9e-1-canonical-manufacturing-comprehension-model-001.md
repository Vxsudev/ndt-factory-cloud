# Task: Author the canonical manufacturing comprehension model, its documentation errata, and verify consistency

## Parent Spec
specs/d9e-1-canonical-manufacturing-comprehension-model.md

## Phase
phase-ui

## Status
done

## Layer
verification

## Description

**Note on layer/task-count deviation (recorded per the D9E-1 recon §10 risk and the directive's own
"record the exact generated names" instruction):** the spec declares `Data Model Changes: none`,
`API Surface: none`, `Frontend Surface: none` — all true, since this capability touches only
`docs/` files, a surface `ai/task-generator.md`'s layer-detection rule does not map to `database`/
`backend`/`frontend`. Per that rule, `generate-tasks.sh` correctly scaffolded only the
always-required `verification` layer as a single task (this one), rather than the directive's
"Recommended" two-task graph (docs-authoring + review). This single task's scope is therefore
widened to cover both halves of the directive's recommended graph sequentially, as documented here.
This is not a scope violation — `ai/task-graph.md` explicitly instructs "generate only the tasks
required by the spec," and doctrine (`ai/task-generator.md` Step 6) sanctions the agent filling in
task content directly from the spec.

**Part A — Canonical model and glossary authoring.** Create `docs/manufacturing-comprehension-
model.md`, transforming the evidence already established in `ai/recon/d9e-0-manufacturing-
comprehension-recon.md` (§10 fourteen-stage matrix, §11 22-entry failure catalog (originally
misreported as 21 in D9E-0 prose), §12
recovery catalog, §13 actor/authority matrix, §14 serialized-traceability model, §21
data-availability map, §24 gap/defect register, §26 TBD register, §28 OPERATOR_LOCKED three-axis
semantic model) into the directive's 22-section canonical schema. Every stage/failure/recovery
entry must carry exactly one of the eight `DOCUMENTED_VS_IMPLEMENTED`-family classifications
(`IMPLEMENTED_AND_REACHABLE`, `IMPLEMENTED_SEEDED_ONLY`, `IMPLEMENTED_TRANSIENT_ONLY`,
`IMPLEMENTED_BUT_UI_UNAVAILABLE`, `DOCUMENTED_NOT_IMPLEMENTED`, `DOCUMENTED_CONFLICT_RESOLVED_OUT`,
`DATA_UNAVAILABLE`, `TBD`). Stable comprehension identifiers (the `FM-*` family from D9E-0 §11) are
canonicalized here — preserved as a mapping layer over the real raw backend codes/event types in
`backend/app/workflow_rules.py`, never silently replacing them. Also create `docs/glossary.md` (new,
additive, 15 terms: Gate, Hard block, No override, Waiting on external dependency, Rework, Retry,
Disposition, Quarantine, Scrap, Serialized allocation, Bound serial, Genealogy, Terminal/immutable,
QC authority, Separation of duty), agreeing with the canonical model and with the existing frozen
`docs/domain-glossary.md` where terms overlap (not modifying that file).

**Part B — Documentation errata.** Apply exactly these narrow corrections:
- `docs/factory-flow-model.md`: retype Stage 9 from "factory core" to a gate (Gate 1 of the
  three-gate model 9/10/11); correct the Authority Levels table (remove "Technician" as a fourth
  tier — fold its stage range into role language, not a new authority tier; correct QC sign-off
  attribution away from "Supervisor" to reflect the distinct QC authority already preserved
  elsewhere in this same document); remove or explicitly mark non-canonical the Stage-8 "Cloud
  provision failure → Supervisor" hard-stop-table row (no BRS/flowchart/`stages.json`/
  `workflow_rules.py` support exists for it — D9E-0 §25 C3); add one cross-reference line pointing
  to `docs/manufacturing-comprehension-model.md`. No other line in this file changes.
- `docs/demo-walkthrough-d8.md`: in Step 2 (Stage 7) and Step 6 (Stage 12) talking points, remove
  any "the supervisor clears the block" phrasing; replace with the operator-locked narrative —
  Stage 7 has no floor-owned action and no current recovery endpoint (cloud return would require a
  re-check the app does not yet implement); Stage 12's "Retry Cloud Backup" is a re-check after
  connectivity returns, not a Supervisor override, and requires no special authority. Add one
  cross-reference line to the canonical model. No other content in this file changes.

**Part C — Consistency review (the directive's Task-002-equivalent, folded in per the note above).**
Before marking this task done, re-read all three modified/created docs plus `docs/glossary.md`
against `ai/recon/d9e-0-manufacturing-comprehension-recon.md` and confirm: all 14 stages present in
order; exactly three gates (9/10/11); no Stage-8 failure invented; Stage 7/12 no-override
distinctness correct; actor/role/authority distinctions correct (Technician = role, QC distinct);
Floor-Manager/Manager Scrap rule present; three semantic axes present and marked composable with
the Stage-12 worked example verbatim; serialized-traceability chain complete; all 12 TBDs carried
forward with a disposition; raw-code mappings preserved (not replaced); errata agree with the
canonical model; zero frontend/backend/data/source-material/vendor file touched.

**Verification-script authorship note:** `scripts/verification/017-d9e-1-canonical-manufacturing-
comprehension-model.sh` is explicitly **out of this task's scope** — per
`ai/incidents/d9c3-verification-script-deliverable-skipped-by-worker.md`, no task-graph worker may
author files under `scripts/`, regardless of declared `## Layer`. That script is authored separately
by the orchestrator after this task completes.

## Acceptance Criteria
- [ ] `docs/manufacturing-comprehension-model.md` exists with all 22 directive-required sections and
      the status line `CANONICAL — OPERATOR_LOCKED THROUGH D9E-0; IMPLEMENTED BY D9E-1`.
- [ ] All 14 stages present, in canonical order, with the full required per-stage schema.
- [ ] Stages 9/10/11 are the only three stages typed as gates.
- [ ] All **22** D9E-0 §11 failure entries present with stable identifiers, raw-code mappings, and
      a `DOCUMENTED_VS_IMPLEMENTED`-family classification each — **corrected count, per the AC-4
      erratum in the parent spec: D9E-0 originally reported 21 (a counting error); `FM-WRONG-STAGE`
      and `FM-AUTH-INSUFFICIENT` are independently evidence-backed and must each be a separate,
      complete entry, never merged.**
- [ ] No Stage-8 failure entry exists in the canonical model; `docs/factory-flow-model.md`'s phantom
      row is removed or marked non-canonical.
- [ ] Stage 7 and Stage 12 each carry distinct, correct no-override/recovery-availability language.
- [ ] Actor/role/authority model present: Technician = role not tier; QC distinct from Supervisor
      and Manager; Manager does not imply QC-signoff.
- [ ] Floor-Manager-vs-Manager Scrap rule documented.
- [ ] Three composable semantic axes present, explicitly marked composable, with the locked Stage-12
      example verbatim, mapped against every failure entry.
- [ ] Full serialized-traceability chain documented.
- [ ] All 12 D9E-0 TBDs carried forward with an explicit disposition each.
- [ ] `docs/factory-flow-model.md` and `docs/demo-walkthrough-d8.md` corrected exactly as specified,
      with no other content altered in either file.
- [ ] `docs/glossary.md` created with the 15 named terms, consistent with the canonical model and
      the existing frozen `docs/domain-glossary.md`.
- [ ] Zero modification to any frontend/backend/data/source-material/vendor/Docker/package-lock/
      existing-verification-script path.
- [ ] `scripts/verification/017-*.sh` was NOT created by this task.

## Files Likely Affected
- docs/manufacturing-comprehension-model.md (new)
- docs/glossary.md (new)
- docs/factory-flow-model.md (narrow edit)
- docs/demo-walkthrough-d8.md (narrow edit)

## Blocked By
- none
