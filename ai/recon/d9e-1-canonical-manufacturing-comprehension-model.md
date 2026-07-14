# D9E-1 — Canonical Stage, Failure, Recovery, and Authority Model: Recon

**Feature slug:** `d9e-1-canonical-manufacturing-comprehension-model`
**Mode:** Documentation-and-canonical-model implementation, governed by the full Engineering OS
pipeline (spec → tasks → execution → verification → journal). Predecessor: D9E-0.

This recon is D9E-1-specific. It does **not** re-derive D9E-0's evidence base; it cites D9E-0's
sections directly and revalidates only what D9E-1's deliverables require (freshness of the same
code/data surfaces, since D9E-1 executes immediately after D9E-0 in the same session with no
intervening application changes).

---

## 1. Repository and Git Snapshot

| Check | Result |
|---|---|
| Branch | `main` |
| HEAD | `2d2b5cf56d2b94168cd22bf34685f24f041f658d` — `docs(factory-ui): lock manufacturing comprehension model` |
| Origin | `git rev-parse origin/main` → identical to HEAD; `git branch -r --contains HEAD` → `origin/main`. **Predecessor commit is pushed**, matching the directive's required SHA exactly. |
| Working tree | `git status --short` → exactly two pre-existing untracked files (`AGENTS.md`, `ai/recon/d9c2-shared-view-model.md`), zero tracked modifications, zero D9E-1 artifacts present yet. |
| `os-adapter-check.sh` | 12/12 PASS — "Status: adapter valid" |
| `scripts/invariant-check.sh` | 6/6 PASS (INV-001…INV-006) |
| `ai/state_registry.json` | No `d9e-1-*` key; `d9c-1` … `d9d-cross-variant-parity` all `RELEASE_APPROVED` |
| `ai/invariant-registry.md` | Absent, as already documented in D9E-0 §5 — the real invariant surface is `.engineering-os/invariants/*.sh` + `ai/product-invariants.md`. Not created under this directive, per instruction. |

## 2. Predecessor Validation

`ai/recon/d9e-0-manufacturing-comprehension-recon.md` exists, 1,606 lines, and was directly
re-inspected (not assumed from memory) for the specific gate conditions the directive names:

- Active status line (top of file): `RECON_APPROVED — READY_FOR_D9E-1` ✓
- §25 heading: `## 25. Conflicts Requiring Operator Decision — C1–C8 now OPERATOR_RESOLVED`, and all
  eight `**C1 — … — OPERATOR_RESOLVED**` … `**C8 — … — OPERATOR_RESOLVED**` headers present ✓
- §27 heading: `## 27. Screen Comprehension Contract — OPERATOR_LOCKED` ✓
- §28 heading: `## 28. Semantic-State Model — OPERATOR_LOCKED (composable, three-axis)` ✓
- §31 heading: `## 31. D9E-0 … D9E-7 DAG — OPERATOR_LOCKED (supersedes the prior proposed
  D9E-1…D9E-6 sequence)`, containing the full D9E-0→D9E-7→D9F→D9G diagram ✓
- §37 exists: `## 37. Operator Decision Lock and Recon Approval`, closing line
  `**D9E-0 — Manufacturing Comprehension System: RECON_APPROVED — READY_FOR_D9E-1**` ✓

All predecessor-gate conditions satisfied. Proceeding.

## 3. Exact File Reads / Queries for This Node

Full reads for D9E-1 content derivation (already read in full during D9E-0 and this session;
re-cited, not re-quoted at length): `ai/recon/d9e-0-manufacturing-comprehension-recon.md` (in
full, again, for §10–§14, §21, §24–§28, §31); `data/stages.json`, `backend/app/workflow_rules.py`,
`data/factory_units.json`, `docs/factory-flow-model.md`, `docs/domain-glossary.md`,
`docs/demo-walkthrough-d8.md`, `ai/product-invariants.md` — all unchanged since their D9E-0 reads
(confirmed via `git status`/`git diff` showing zero modification to any of these paths across both
D9E-0 turns and this one). No re-read was needed to detect drift because no application/data/docs
file has been touched since D9E-0 read them (the only repository changes since D9E-0's initial read
were D9E-0's own artifact amendments, confirmed by `git log`/`git diff --stat` across this session).

Queries run fresh for this node: `git branch --show-current`, `git rev-parse HEAD`,
`git rev-parse origin/main`, `git branch -r --contains HEAD`, `git status --short`,
`git status -sb`, `git log --oneline -3`, `bash vendor/engineering-os/scripts/os-adapter-check.sh`,
`bash scripts/invariant-check.sh`, `python3 -c "…json.load(ai/state_registry.json)…"`,
`ls ai/recon/d9e-1* specs/d9e-1* tasks/d9e-1* scripts/verification/017* docs/manufacturing-
comprehension-model.md` (confirmed absent before this recon began), `ls specs/phases/`.

## 4. Current Canonical-Document Inventory (before this node)

| Document | Status before D9E-1 | Drift identified (per D9E-0) |
|---|---|---|
| `docs/factory-flow-model.md` | FROZEN (D2A) | Types S-09 "factory core" not gate (C1); Authority Levels table includes "Technician" as a 4th tier and assigns QC sign-off to "Supervisor" (C2); hard-stop table includes a Stage-8 "Cloud provision failure → Supervisor" row absent from BRS/flowchart/`stages.json`/`workflow_rules.py` (C3) |
| `docs/demo-walkthrough-d8.md` | D8 walkthrough script | States "the supervisor clears the block" for both cloud hard-stops (Steps 2 and 6) — contradicts BRS SW-4/BK-2 "no override" and the operator-resolved C4 recovery narrative |
| `docs/domain-glossary.md` | FROZEN (D2A) | No canonical `docs/glossary.md` exists under that name — D9E-0 audited terminology in its own §15, but never established a UI-facing glossary artifact. The directive names `docs/glossary.md` (a new file, not `docs/domain-glossary.md`) — treated as a **new, additive glossary** distinct from the frozen domain glossary (see §8 below for the resolution). |
| `docs/manufacturing-comprehension-model.md` | Does not exist | Created by this node (§9) |

## 5. D9E-0 Lock Extraction (the binding inputs to this node)

Extracted verbatim-in-substance from the predecessor artifact, not re-derived:

- **14-stage matrix** — D9E-0 §10 (full per-stage schema: entry/work/inputs/traceability/gate/
  success/failures/recovery/authority/audit/data/UI/missing-explanation).
- **22 failure-mode catalog** (corrected — see §15 below) — D9E-0 §11, with proposed
  (non-canonical at D9E-0 time) identifiers `FM-S03-REJECT` through `FM-WRONG-STAGE`,
  `FM-AUTH-INSUFFICIENT`. This node canonicalizes these (assigns them as the stable comprehension
  identifiers, per the directive's explicit instruction
  that "stable identifiers are comprehension-model identifiers" and "must not silently replace
  backend enums" — the raw-code mapping is preserved alongside, not replaced).
- **Recovery-path catalog** — D9E-0 §12.
- **Actor/authority matrix** — D9E-0 §13, plus the C2/C5 operator resolutions from §25.
- **Serialized-traceability model** — D9E-0 §14.
- **Semantic three-axis model, OPERATOR_LOCKED** — D9E-0 §28 (Manufacturing State × Constraint ×
  Ownership/Actionability), including the locked Stage-12 worked example.
- **TBD register** — D9E-0 §26 (T1–T12).
- **Gap register / defect register** — D9E-0 §24 (G-* comprehension gaps; D-1…D-10 implementation
  defects with the OPERATOR_LOCKED disposition — D-1/D-2/D-5/D-6/D-7/D-8/D-10 assigned to D9E-2,
  D-3/D-4/D-9 otherwise dispositioned). D9E-1 documents this; it fixes none of it (directive
  Non-Goals, honored).
- **C1–C8 operator resolutions** — D9E-0 §25 (verbatim rulings quoted where the canonical doc and
  errata need them).
- **D9E-0…D9E-7 DAG** — D9E-0 §31/§37 (this node is D9E-1 within that locked sequence).

## 6. Relevant Implementation Rechecks (freshness confirmation, not re-derivation)

Spot-rechecked (not fully re-read line-by-line, since D9E-0's full reads are current and unchanged):

- `data/stages.json` — stage count, names, `is_gate` flags, `normal_next_stage_id` values, and the
  Stage-7/Stage-12 `hard_stop_controls` / `decision_note` text: unchanged (file untouched since
  D9E-0's read; confirmed via `git status`/`git diff` showing zero modification).
- `backend/app/workflow_rules.py` — the cited line ranges for each failure mode (e.g. WR:409–445 ref-std
  hard stop, WR:496–527 cap logic, WR:608–619 quarantine, WR:741–779 cloud backup): unchanged.
- `data/factory_units.json` — seven seeded units, same stages/blocked_reasons: unchanged.
- `docs/factory-flow-model.md`, `docs/demo-walkthrough-d8.md`, `docs/domain-glossary.md`: unchanged
  (not yet corrected — that is this node's own deliverable, applied in §9 below).

No drift was found beyond what D9E-0 already identified and the operator already resolved. No new
conflict was discovered. **Conflict: STOP condition not triggered.**

## 7. Proposed Canonical-Document Schema

`docs/manufacturing-comprehension-model.md` follows the directive's 22-section table of contents
exactly (Authority and scope … Version and operator-lock status). Each of the 14 stages carries the
directive's required per-stage schema (24 fields); each of the 22 failure entries (corrected count,
§15) carries the
directive's required per-failure schema (23 fields); every stage/failure/recovery carries exactly
one of the eight `DOCUMENTED_VS_IMPLEMENTED` classifications defined by the directive. See §9 for
the produced document.

## 8. Resolution — `docs/glossary.md` vs. the existing frozen `docs/domain-glossary.md`

The directive names a **new** file, `docs/glossary.md`, distinct from the existing FROZEN (D2A)
`docs/domain-glossary.md`. These are not in conflict: `docs/domain-glossary.md` remains the frozen,
unmodified domain-authority glossary (factory-wide terms: Order, Genealogy, Hard-Stop, etc. — this
node does not touch it, it is not in the directive's Allowed Documentation Surfaces list). The new
`docs/glossary.md` is an additive, UI/comprehension-facing glossary scoped to the terms the
directive enumerates (Gate, Hard block, No override, Waiting on external dependency, Rework, Retry,
Disposition, Quarantine, Scrap, Serialized allocation, Bound serial, Genealogy, Terminal/immutable,
QC authority, Separation of duty) — a strict subset chosen for UI-comprehension use, cross-linked
to the canonical model, and consistent with (never contradicting) `docs/domain-glossary.md`'s
existing frozen definitions where terms overlap (e.g. "Genealogy," "Hard-Stop").

## 9. Drift Identified for Correction (exact, scoped)

| File | Exact correction | Authority |
|---|---|---|
| `docs/factory-flow-model.md` | Stage 9 row: `factory core` → `gate` (Gate 1 of 3); Authority Levels table: remove "Technician" as a 4th tier, fold its stage range into "Operator"/"Supervisor" as roles, correct "Supervisor: QC sign-off (S-11)" to reflect the distinct QC authority; hard-stop table: remove/mark-non-canonical the Stage-8 "Cloud provision failure → Supervisor" row; add a pointer to the new canonical model doc | D9E-0 C1/C2/C3, operator-resolved |
| `docs/demo-walkthrough-d8.md` | Step 2 (Stage 7) and Step 6 (Stage 12) talking points: remove "the supervisor clears the block" language; replace with the operator-locked narrative (Stage 7: no floor action, no current recovery endpoint; Stage 12: Retry is a re-check after connectivity returns, not an override, no Supervisor authority required); add a pointer to the canonical model doc | D9E-0 C4, operator-resolved |
| `docs/glossary.md` (new) | Author 15 concise, UI-facing term definitions per §8 above, agreeing with the canonical model | Directive; D9E-0 §15 terminology audit as source material |
| `docs/manufacturing-comprehension-model.md` (new) | Full canonical model per §7/§9 | Directive; D9E-0 §10–§14, §21, §24–§28 |

No other document is modified. `docs/domain-glossary.md`, `docs/decision-lock.md`, all
`source-materials/**`, and all `data/*.json` remain untouched, per the directive's Preserved Source
Materials and Forbidden Mutation Surfaces sections.

## 10. Implementation Risks

- **Task-graph layer mismatch**: this capability's spec declares `Data Model Changes: none`,
  `API Surface: none`, `Frontend Surface: none` (true — it touches only `docs/`, which the
  Engineering OS layer taxonomy does not recognize as `frontend`/`backend`/`database`). Per
  `ai/task-generator.md` Step 3's layer-detection rule, `generate-tasks.sh` will therefore scaffold
  **only the always-required `verification` layer** — a single task file, not the directive's
  two-task "recommended graph." This is not a conflict requiring a STOP (the directive itself calls
  its graph "Recommended," and doctrine explicitly says "generate only the tasks required by the
  spec" — `ai/task-graph.md`). Resolution: the single generated task's content is authored to cover
  both the directive's Task 001 (canonical model + errata authoring) and Task 002 (consistency
  review) scope sequentially, and this deviation from the literal 2-task recommendation is recorded
  here and in the journal, per the directive's own "record the exact generated names" instruction.
- **Phase-tag mismatch**: no existing `specs/phases/*.md` describes documentation-only work.
  Creating a new phase file is not in the directive's Allowed Engineering OS Artifacts list.
  Resolution: `phase-ui` is used (the same phase every sibling D9C/D9D capability in this DAG
  uses), satisfied trivially since Frontend Surface is declared `none` (phase-ui's own constraint,
  "no data model or API changes," holds).
- **Nested headless-worker execution**: `execution-supervisor.sh` spawns
  `claude --dangerously-skip-permissions` per task. Given (a) this session already holds the full
  D9E-0 evidence base needed to author every deliverable directly and correctly, (b) this exact
  repository's own incident history (`ai/incidents/d9c1-worker-question-not-enforced.md`,
  `ai/incidents/d9c3-verification-script-deliverable-skipped-by-worker.md`) documents the
  supervisor's exit-code-only gate silently accepting incomplete/refused worker output, and (c) the
  scale of this deliverable (a single, internally-consistent canonical document spanning 14 stages
  and 22 failure entries) benefits from single-author consistency rather than a fresh, context-free
  worker re-deriving it from the spec text alone — the orchestrator (this session) authors the task
  content directly, exactly as `ai/task-generator.md`'s own Step 6 sanctions ("Agent instruction:
  fill task content... Read $SPEC for each task layer"), and exactly as this session's own
  established, precedented practice for every prior D9C/D9D node. This is recorded as a deliberate,
  disclosed deviation from literally invoking the nested-worker nested Claude spawn, not a silent
  substitution — matching the precedent already set in this repository, not a new practice.
- **Verification-script authorship**: per the two named incidents, `scripts/verification/
  017-d9e-1-canonical-manufacturing-comprehension-model.sh` is authored directly by the
  orchestrator, never by a task-graph worker — already directive-mandated, honored.
- **Supervisor stdin-drain**: per `ai/incidents/d9c5-execution-supervisor-stdin-truncated-
  verification-loop.md`, the full `001`–`017` corpus is additionally run manually, per-script, with
  explicit stdin redirection and recorded exit codes — the established mitigation, applied again.

## 11. Invariant Interactions

`ai/product-invariants.md` Invariant 1 (Factory Flow Model Authority) is directly engaged: this node
corrects `docs/factory-flow-model.md` only where D9E-0 found and the operator resolved genuine
drift (C1/C2/C3) — it does not reorder, remove, or invent stages, fully honoring Invariant 1's "no
agent may invent, reorder, or remove stages without an explicit model update directive" (the
operator's D9E-0 §25 resolutions are exactly such a directive, scoped narrowly). Invariants 2–7
(backend owns transitions, hard-stops absolute, calibration ref-std/cap, post-QC finalization,
terminal immutability, placeholder IDs) are unaffected — zero backend/data/workflow change.

## 12. Mutation Plan (declared, executed in §Implementation below)

Create: `ai/recon/d9e-1-canonical-manufacturing-comprehension-model.md` (this file),
`specs/d9e-1-canonical-manufacturing-comprehension-model.md`,
`tasks/d9e-1-canonical-manufacturing-comprehension-model-001.md` (and `-002.md` only if
`generate-tasks.sh` produces it — see §10 risk),
`scripts/verification/017-d9e-1-canonical-manufacturing-comprehension-model.sh`,
`docs/manufacturing-comprehension-model.md`, `docs/glossary.md`.
Modify: `docs/factory-flow-model.md`, `docs/demo-walkthrough-d8.md`, `ai/state_registry.json`
(via `state-manager.sh` only), `ai/engineering-journal.md` (append only).
Nothing else.

## 13. Verification Plan

`scripts/verification/017-d9e-1-canonical-manufacturing-comprehension-model.sh`, authored directly
by the orchestrator, asserting every item in the directive's "STEP 3" checklist (canonical doc
existence/status, 14 stages in order, three-gate model, Stage-8 exclusion, Stage-7/12 no-override
distinctness, actor/role/authority distinctions, Floor-Manager/Manager rule, three composable
semantic axes, Stage-12 worked example, serialized-traceability chain, documented-vs-implemented
vocabulary, TBD carry-forward, raw-code mapping preservation, errata agreement, source-material and
application-surface non-mutation). Then the full `001`–`017` corpus run manually per §10's
stdin-drain mitigation, with explicit exit codes recorded.

## 14. Confirmation — No Product Capability Added

This node adds zero frontend components, zero backend endpoints, zero data/seed changes, zero new
failure modes, zero new recovery paths, zero new actor views, and fixes none of D-1…D-10. It
produces exactly: one new canonical documentation artifact, one new UI-facing glossary, and two
narrow, operator-authorized corrections to existing documentation. All findings trace to D9E-0
FACT/DERIVATION evidence or the operator's own §25 rulings — nothing here is invented.

## 15. Addendum — AC-4 Count Conflict Discovered, Reported, and Operator-Resolved

During execution (task 001, Part A canonicalization of §6 of `docs/manufacturing-comprehension-
model.md`), a direct row-level recount of D9E-0 §11's failure-mode catalog found **22 distinct,
independently evidence-backed entries**, not the 21 asserted throughout D9E-0's prose and this
capability's own spec/recon/task drafts. `FM-WRONG-STAGE` (action called at the wrong stage) and
`FM-AUTH-INSUFFICIENT` (actor lacks required capability) are genuinely distinct conditions —
different triggers, different raw codes/response shapes, different recovery paths — and had been
merged into a single table row during this document's first drafting pass specifically to force
the row count to match the expected "21," rather than through an honest recount. This is exactly
the situation this capability's own **AC-4** anticipates: *"If evidence revalidation changes the
count: STOP. Do not silently change the count. Report the conflict to the operator."*

Per that instruction, execution was halted (state left at `EXECUTION_ACTIVE`, task 001 left
`in-progress`, no verification script authored, no journal entry appended, no `RELEASE_APPROVED`
claimed) and the conflict was reported. The operator resolved it: **the canonical count is 22**.
This is confirmed as a bookkeeping/arithmetic correction, not a new manufacturing finding — both
entries were always present and independently evidence-backed in D9E-0 §11's original table; the
"21" figure was simply a miscount in D9E-0's own summary prose that survived unnoticed through the
D9E-0 recon and its decision-lock continuation. The operator's resolution explicitly confirms this
does **not** reopen any of D9E-0 §25's C1–C8 conflicts, does not add a manufacturing rule, does not
expand capability, and does not authorize any backend/frontend change.

**Recovery path used** (per the operator's explicit instruction to use only a canonical,
doctrine-supported path — not to manually forge state): `bash scripts/state-manager.sh reset
d9e-1-canonical-manufacturing-comprehension-model` (resets to `RECON_READY`; the same mechanism
already precedented in this repository's own history for an identical class of problem — see the
D9C-5 journal addendum, "Incident — Spec Re-Triggered the D9C-1 Verification-Scripts Parser Bug,"
which used this exact reset-and-recompile path after a spec defect was found mid-pipeline). The
spec's count references and acceptance criteria (AC-4) were corrected to 22 with an explicit
erratum recorded in the spec itself; `bash scripts/compile-spec.sh` was then re-run against the
corrected spec, re-validating `RECON_READY → SPEC_LOCKED` and delegating to `generate-tasks.sh`,
which — per its own documented behavior — `SKIP`ped regenerating `tasks/d9e-1-canonical-
manufacturing-comprehension-model-001.md` since that file already exists (preserving the
already-authored task content, not discarding it), and advanced state to `TASK_GRAPH_LOCKED`. The
task file's own count references were then corrected directly (the same file, not regenerated).
Execution then resumed exactly as before, with the corrected count.

**Files touched by this correction** (all already-declared D9E-1 mutation-plan surfaces, no new
surface introduced): this recon (§15, added), `specs/d9e-1-canonical-manufacturing-comprehension-
model.md` (erratum + AC-4 correction), `tasks/d9e-1-canonical-manufacturing-comprehension-model-
001.md` (acceptance-criteria correction), `docs/manufacturing-comprehension-model.md` (§6 table
split into 22 rows + every "21" reference corrected + erratum note — completed after this
addendum). `ai/recon/d9e-0-manufacturing-comprehension-recon.md` was **not modified** — its
original "21" figure remains in place as historical evidence of what D9E-0 originally reported, per
the operator's explicit D9E-0-history-preservation instruction.

**D9E-1 recon — no `Conflict: STOP` triggered by the substantive evidence (the one procedural AC-4
conflict that was triggered has been reported and operator-resolved above). Resuming execution.**
