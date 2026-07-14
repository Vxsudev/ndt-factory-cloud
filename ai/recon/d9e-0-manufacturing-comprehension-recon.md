# D9E-0 — Manufacturing Comprehension System: Max-Depth Recon and Scope Lock Evidence

**Directive ID:** D9E-0
**Feature slug:** `d9e-0-manufacturing-comprehension-recon`
**Directive type:** RECON-ONLY (DIRECTIVE_V3, OS-ENABLED mode)
**Execution authorization:** NONE · **Implementation authorization:** NONE
**Status claimed by this artifact:** `RECON_APPROVED — READY_FOR_D9E-1`
**Date:** 2026-07-14
**Author:** Recon agent (single CC session), operating under the D9E-0 directive

STRICT MODE. Every material claim below is tagged with its evidence class:
**FACT** (directly evidenced, cited), **DERIVATION** (deterministically derived, inputs named),
**INFERENCE** (plausible, not authoritative), **PROPOSAL** (future direction, explicitly unlocked),
**TBD** (authoritative evidence absent), **CONFLICT** (authoritative sources disagree).

This artifact is the only file created by D9E-0. No spec, task, verification script, state
transition, journal entry, commit, push, or application/runtime/data mutation was performed.
The Engineering OS control layers were read as evidence and **not invoked** (§34–§35).

---

## 1. Directive Identity and Recon-Only Status

| Field | Value |
|---|---|
| Node | D9E-0 — Manufacturing Comprehension System Max-Depth Recon |
| Predecessors (all complete) | D9A, D9B, D9C-0 … D9C-6, D9D — verified in `ai/state_registry.json` (all `RELEASE_APPROVED`) and in prior recon/journal artifacts (FACT) |
| Later nodes proposed, NOT executed | D9E-1 … D9E-7, D9F, D9G — OPERATOR_LOCKED in §31; not executed |
| Authorized mutation | exactly `ai/recon/d9e-0-manufacturing-comprehension-recon.md` (this file, which did not previously exist — verified before writing) |
| Forbidden actions honored | no OS pipeline invocation, no state transition, no journal append, no commit/push, no app/backend/data/Docker/browser mutation (§35) |

Note on prior handoff: `specs/d9d-cross-variant-parity.md` §Next-Phase Handoff and the D9D journal
entry name the next node "D9E (visual polish)". The operator's D9E-0 directive re-scopes D9E as the
**Manufacturing Comprehension System** and is the higher authority ("THIS DIRECTIVE WINS"). Recorded
as a superseded-label note, not a conflict (FACT: both texts read directly).

---

## 2. Executive Finding

**FACT-grounded summary (all citations in later sections):**

The manufacturing behavior of Factory Cloud is complete, parity-audited, and truthful — but the
screens expose *state* without *explanation*. Every reviewable surface renders identifiers, codes,
counts, and badges (`UNIT-0004`, `Calibration cap exceeded supervisor disposition required`,
`S-10`, `BLOCKED`, `NO OVERRIDE`, `3 need attention`) and answers almost none of the fourteen
comprehension questions the operator's product goal requires (where am I, what caused this, what is
the consequence, who owns the next step, what happens after the action, why is this variant shaped
this way). The single richest explanation source in the repository — `data/stages.json`, which
carries per-stage requirement IDs, hard-stop controls with `no_override` flags, documented
management-decision notes, rework re-entry targets, calibration/QC metadata, and authority notes,
all served verbatim by `GET /factory/stages` — is consumed by the frontend for **names and badge
flags only**; its explanatory payload is rendered nowhere. The BRS's rationale sentences (the
"why") exist only in `source-materials/` and are rendered nowhere.

The core comprehension failure in one paragraph (for the decision packet, §32): *the application
tells a first-time viewer what is true but never why it is true, what it costs, or what to do about
it; the words it uses are backend identifiers mechanically re-cased rather than manufacturing
language; a single red treatment is used for at least seven operationally distinct conditions; the
three comparison variants carry no self-description of their own philosophies; and the demo can
only truthfully demonstrate three of the nine flowchart scenario families from the actor-first
variants, because the other actions (assembly scan, hardware gate, QC sign-off, package, ship, and
the invalid-reference-standard hard stop) are reachable only through the engineering console.*

Material source conflicts found: 8, all OPERATOR_RESOLVED in §25 (C1–C8). Unresolved TBDs: 12 (§26).
Implementation defects observed (reported, not fixed): 10 (§24, classified `IMPLEMENTATION_DEFECT`).

---

## 3. Repository and Git Snapshot

All commands read-only (§34). Snapshot taken at recon start and re-verified at close (§35).

| Check | Result |
|---|---|
| `pwd` | `/Users/vasudevarao/ndt-factory-cloud` |
| Branch | `main` |
| HEAD | `e4cc0246828c751042afb94cdab7b85e251f01c8` — `fix(factory-ui): enforce cross-variant parity` (the D9D commit) |
| Origin | `https://github.com/Vxsudev/ndt-factory-cloud.git`; `git status -sb` → `main...origin/main` no ahead/behind; `git rev-parse origin/main` = HEAD; `git branch -r --contains HEAD` → `origin/main`. **Local main == pushed origin/main** (FACT) |
| Tracked modifications | none (`git status --short` shows zero `M` entries) |
| Untracked pre-existing residue | exactly 2 files: `AGENTS.md` (root; verbatim copy of project `CLAUDE.md` rule; zero git history — first flagged in D9C-3 recon §1) and `ai/recon/d9c2-shared-view-model.md` (the D9C-2 STOP recon, never committed). **Neither was created or modified by D9E-0** (FACT) |
| Snapshot drift during session | The conversation-start environment snapshot showed uncommitted D9D work (modified journal/state/5 variant files + 6 untracked D9D artifacts). By the first live `git status` of this recon those had been committed as `e4cc024` (operator-side commit between sessions). Recorded as pre-recon history, not D9E-0 activity (FACT) |
| Recent commits | `e4cc024` D9D parity ← `87315eb` three variants ← `aff869a` D9C-3 ← `88194f4` D9C-2 ← `6703ca8`/`a6b0bd6` D9C-1 ← `1882538` D9A–D9C0 recon ← `ba3ab83` ← `931e7f9` D3–D8C ← `d43dc0d` |
| Gitignored-but-present governance | `/vendor/engineering-os/`, `/.engineering-os/`, root `/CLAUDE.md`, `/PROJECT_BOOTSTRAP.md`, `/ENGINEERING_OS.md`, `/_archive/invented-os-bootstrap-d1c/` are all gitignored **and physically present** (`.gitignore` read; dirs listed) — consistent with D9A §1 (FACT) |
| Docker / runtime | Not inspected live and not mutated. No `docker` command of any kind was run (directive forbids container mutation; recon needs none). Application/runtime configuration read as text: `docker-compose.yml` (3 services: postgres:16 w/ named volume `postgres_data`, backend:8000 w/ `DATA_DIR=/app/data` ro-mount + `DATABASE_URL`, frontend:5173 w/ `VITE_API_BASE_URL`), `backend/entrypoint.sh` (wait-for-postgres → `alembic upgrade head` → uvicorn; seeding is in `app/main.py` lifespan via `is_empty→seed`), `.env.example` (FACT) |
| Browser state | No browser session opened. `.playwright-mcp/` residue predates this recon and was not touched (FACT) |
| D9 state entries | `ai/state_registry.json`: `d9c-1` … `d9c-6`, `d9d-cross-variant-parity` all `RELEASE_APPROVED`; plus D3–D8C-era entries; **no `d9e-*` key exists** (FACT — file read in full) |

---

## 4. Complete Engineering OS Reading Ledger (vendored)

The full vendored surface was enumerated (`find vendor/engineering-os -type f` → 49 files) and
every readable text file was read (48 read; 2 × `.gitkeep` are empty placeholders, listed for
completeness). No OS script was executed. (FACT)

| # | File | Read | Role / key content |
|---|---|---|---|
| 1 | `core-docs/PROJECT_BOOTSTRAP.md` | full | Canonical boot sequence; enforcement-layer validation (pre-commit, state machine, invariant engine); DELTA-ONLY verification; incident/journal protocol |
| 2 | `core-docs/ENGINEERING_OS.md` | full | Pipeline doctrine (capability→spec→tasks→execution→verification→journal); 3 enforcement layers (artifact trail token, state machine, invariant engine); state chain `RECON_READY→…→RELEASE_APPROVED` |
| 3 | `core-docs/directive-template.md` | full | Directive scaffold; "operator intent overrides scaffold structure"; template ≠ authority |
| 4 | `core-docs/spec-generation.md` | full | Spec template (Status/Capability/Data Model/API/Frontend/Workflow/Dependencies/Acceptance/Out-of-scope); draft→approved lifecycle |
| 5 | `core-docs/spec-compiler.md` | full | 10-step compile pipeline; halting rules; capability→layer mapping; token handoff `compile-spec.sh → /tmp/.os-compile-token → generate-tasks.sh` |
| 6 | `core-docs/spec-to-task-playbook.md` | full | Layer decomposition; task file format; layer responsibility matrix |
| 7 | `core-docs/task-generator.md` | full | Deterministic layer detection from spec sections; phase-tag propagation; numbering |
| 8 | `core-docs/task-graph.md` | full | DAG rules; `Blocked By`; database→backend→frontend→verification ordering |
| 9 | `core-docs/execution-loop-controller.md` | full | Outer loop; phase files in `specs/phases/` (`Phase:` declaration); invariant gates at EXECUTION_ACTIVE / VERIFICATION_REQUIRED |
| 10 | `core-docs/execution-orchestrator.md` | full | Inner per-task lifecycle (pending→in-progress→done); scope containment |
| 11 | `core-docs/verification-playbook.md` | full | DELTA-ONLY mode; `## Verification Scripts` spec block; lexical-order execution; stale-assertion policy |
| 12 | `core-docs/system-spine-playbook.md` | full | 8-step spine sequence (CONTROL_SURFACE_FREEZE … SYSTEM_CONSTRAINTS_LOCK) — context for later D9E discipline |
| 13–23 | `scripts/`: `compile-spec.sh`, `generate-tasks.sh`, `execution-supervisor.sh`, `state-manager.sh`, `invariant-engine.sh`, `os-adapter-check.sh`, `os-boot-check.sh`, `os-intent-entry.sh`, `os-self-test.sh`, `raystrat-os`, `run-full-regression.sh` | full (source only) | Runtime behavior confirmed from source: token gate; `require/advance` state semantics (exit 2 on violation); supervisor spawns `claude --dangerously-skip-permissions` per task, control-plane hash guard, DELTA verification loop (the here-string stdin loop whose drain defect is documented in `ai/incidents/d9c5-…`), auto journal append at RELEASE_APPROVED. **Not executed** |
| 24–26 | `templates/adapter.config.sh`, `templates/invariant-registry.md`, `templates/state_registry.json` | full | Adapter contract (EOS_* vars; `EOS_INVARIANTS_DIR` hard-required); invariant-registry template (RATIFIED vs CANDIDATE) — see §5 note on the absent local `ai/invariant-registry.md` |
| 27–29 | `claude/agents/journal-agent.md`, `claude/agents/spec-agent.md`, `claude/hooks/docker-build-guard.sh` | full | Read-only helper agents; PreToolUse hook blocking `docker build` without `--no-cache` (hook text only; not installed/invoked by this recon) |
| 30–35 | `tests/run-self-tests.sh`, `tests/001`–`005` | full (source only) | Self-test contract (enforcement layer, state machine, invariant engine, CLI surfaces, CLI wrapper). **Not executed** |
| 36–39 | `ai/engineering-journal.md`, `ai/state_registry.json`, `ai/recon/OS_CLI_V0_SURFACE.md`, `ai/specs/os-cli-v0.md` | full | Vendor-tree shadow registry (holds the pre-D8C-bugfix state history — evidence for `ai/incidents/d8c-state-registry-proxy-bug.md`); CLI surface recon + spec |
| 40 | `recon/os-core-sanitization-recon.md` | full | OS-core sanitization record (NDT identifier cleanup) |
| 41–43 | `specs/phases/phase-1.md`, `phase-backend.md`, `phase-ui.md` | full | Valid phase tags (`phase-1`, `phase-backend`, `phase-ui`) — note the *local* `specs/phases/` adds `phase-persistence`, `phase-demo-readiness` |
| 44–45 | `engineering-os-structure.txt`, `engineering-os-full-tree.txt` | full | Package tree snapshots (48/49 files) |
| 46–47 | `INSTALL.md`, `README.md` | full | Adapter integration steps; OS boundary (core owns lifecycle; project owns domain invariants) |
| 48–49 | `templates/.gitkeep`, `tests/.gitkeep` | n/a | Empty placeholder files |

**OS understanding relevant to later D9E nodes (DERIVATION from the above):** any D9E-1+ execution
node will follow spec→`scripts/compile-spec.sh`→`generate-tasks.sh`→`execution-supervisor.sh` with
state auto-registration at `RECON_READY`; verification scripts must be orchestrator-authored (never
worker-authored, per `ai/incidents/d9c3-…`); the supervisor's own verification loop must never be
trusted past script `007` (stdin-drain defect, `ai/incidents/d9c5-…`) — the standing manual
full-corpus re-run with `< /dev/null` per script is mandatory; spec `## Verification Scripts`
sections must contain only `(none)` or bare script paths (naive parser); `## Phase *`-prefixed
section names break `compile-spec.sh`'s phase grep.

---

## 5. Local Governance Reading Ledger

| Surface | Read | Notes |
|---|---|---|
| `.engineering-os/adapter.config.sh` | full | `EOS_PROJECT_NAME=ndt-factory-cloud`; app surfaces `frontend/ backend/`; registry `ai/state_registry.json`; invariants `.engineering-os/invariants/` |
| `.engineering-os/invariants/INV-001…INV-006.sh` | full (all 6) | Presence checks: factory docs, AI control docs, D3 scaffold+approved spec, registry valid JSON, vendor OS installed, adapter overlay present |
| Root `CLAUDE.md`, `AGENTS.md`, `PROJECT_BOOTSTRAP.md`, `ENGINEERING_OS.md`, `README.md`, `.gitignore`, `.env.example` | full | Boot sequence completed by **reading** (steps 1–6); step 7 (pipeline enforcement) is inapplicable to a recon-only node and the directive's non-invocation lock forbids running the runtime — recorded, not violated. Root `PROJECT_BOOTSTRAP.md` "Current Repository State: D3 not yet started" remains stale (known since D8C recon; unchanged; DOCUMENTATION_GAP §24) |
| `ai/product-invariants.md` | full | 7 RATIFIED invariants (stage authority, backend-owns-transitions, hard-stops absolute, calibration ref-std + 3-cap, post-QC finalization, terminal immutability, placeholder IDs) |
| `ai/runtime-contracts.md` | full | 6 contracts. Contract 4 ("Mock State in v0; Postgres Deferred") and Contract 5's v0 framing remain stale vs D7+ reality — pre-existing, self-flagged in D9A §2 (DOCUMENTATION_GAP) |
| `ai/service-boundaries.md` | full | Frontend/backend/docs/ai/scripts ownership; "planned directory structure" partially stale vs actual flat backend layout (noted in `ai/architecture-index.md` itself) |
| `ai/coding-patterns.md` | full | Declared router split (orders/units/stages/…) never materialized — actual backend is flat (`workflow_rules.py` + 4 route modules); the doc self-dates to D0–D2 (DOCUMENTATION_GAP) |
| `ai/architecture-index.md`, `ai/repo-index.md` | full | Phase table through D8C only (no D9 rows) — stale but explicitly historical; D8C-era component map accurate for `components/*.tsx`, missing `variant-review/**` and `view-model/**` (DOCUMENTATION_GAP) |
| `ai/state_registry.json` | full | §3. Not transitioned by this recon |
| `ai/engineering-journal.md` | full (2,742 lines) | D0→D9D history incl. all D9C addenda, post-release remediation, D9D addendum — heavily cited throughout this artifact |
| `ai/incidents/` (5 files) | full/substantive | `d1d-os-vendor-self-test-failure`, `d8c-state-registry-proxy-bug`, `d9c1-worker-question-not-enforced`, `d9c3-verification-script-deliverable-skipped-by-worker`, `d9c5-execution-supervisor-stdin-truncated-verification-loop` |
| `ai/invariant-registry.md` | **DOES NOT EXIST** | The directive's minimum-read list names it; only the vendor **template** exists (`vendor/engineering-os/templates/invariant-registry.md`). The live invariant surface is `.engineering-os/invariants/*.sh` + `ai/product-invariants.md`. Same finding as D9C-3 recon §3. Reported as a directive-expectation vs repo-layout discrepancy — **not** a stop condition, and no governance file was modified (FACT) |
| Prior recon artifacts | full | `d9a` (486 ln), `d9b` (271), `d9c0`, `d9c1`, `d9c2`, `d9c-3` (parity sections), `d9c-4`, `d9c-5`, `d9c-6`, `d9d` — all read; `d8c-touch-first-responsive-ui-recon.md` sampled (its substance is restated in D9A §2 and the journal) |
| D9 specs | `d9d` full; `d9c-1…6` head+tail (Status/Phase/Capability/Source-Authority/Non-Goals + boundary/handoff sections) | Middle sections (Frontend Surface details, acceptance lists) are independently evidenced by the shipped code (read in full) + journal addenda + verification scripts; no reliance on unread spec text is made in this artifact |
| D9 task files (14: `d9c-1…6`, `d9d` ×2 each) | headers + full Description openings | All `Status: done`; the D9C-4/5/6 001-task texts containing the flawed `old_serial_number: ''` instruction are retained as historical evidence per the journal's remediation entry (FACT) |
| Verification scripts `012`–`016` | headers + structure; check counts from journal (012=8, 013=23, 014=31, 015=34, 016=63 checks) | Static file-based assertion scripts; **not executed** by this recon (mutation-capable? no — but the non-invocation lock and "do not run verification wrappers" instruction were honored: nothing under `scripts/` was run) |
| Non-D9 docs (`docs/*.md`, 15 files) | D4/D5/D6/D7/D8/D8A/D8B/D8C/os-vendor/d1c/d2a/decision-lock/factory-flow-model/domain-glossary/demo-walkthrough | `factory-flow-model.md`, `domain-glossary.md`, `decision-lock.md`, `d2a-model-drift-correction.md`, `demo-walkthrough-d8.md` read **full**; the phase docs sampled (headers) — their content is duplicated in the journal entries read in full. `docs/mock-data-contract-d4.md` retains its known-defective stage table (ignored as authority per D9A §2 conflict #1 + D9B §0 operator confirmation) |
| Git hook `.git/hooks/pre-commit` | full (source text) | Live hook = invariant-engine gate only (simpler than the canonical doctrine's artifact-trail hook). Not executed |

---

## 6. Product / Source Authority Ledger

Reconciliation of the 20 source classes the directive requires. Authority order for manufacturing
truth in this recon: **operator directive > BRS+flowchart (operator-supplied, in-repo) > transcript
> frozen repo domain docs > backend code/data (implementation truth) > UI (presentation truth)**.
Where implementation and documents disagree, both are recorded (§25).

| # | Source | Path / identity | Authority | Can answer | Cannot establish | Agreement |
|---|---|---|---|---|---|---|
| 1 | Operator directive D9E-0 | this session | Highest for D9E-0 | Scope, DAG, comprehension goal, flowchart category list | Implementation truth | Consistent with BRS/flowchart categories it cites |
| 2 | Latest transcript | `source-materials/latest-transcripts/call-with-abhilash-kothapalli-3.docx` (2026-07-01, 1h26m; read in full via read-only `textutil` extraction to scratchpad) | Operator/client intent | Actor model (2 humans), attention model, touch/screen targets (11–21″), failure→instruction intent, three-variant instruction, declutter/i-button intent, real-time truth ("in progress" ≠ "at stage") | Stage mechanics detail; wording; no QC-authority statement | Agrees with BRS; D9B's extraction verified accurate against the re-read |
| 3 | Digital Factory Flowchart | `source-materials/digital-factory-requirements-v1/Digital_Factory_Flowchart.html` (+ `Digital_Factory_Workflow.html` variant; both read full) | Operator-supplied canonical branch map | All 14 stages + every branch: S-03 reject, S-04 realloc/HOLD, S-05 ×5 hard-stops, S-07 & S-12 cloud blocks (NO override), S-09/S-10/S-11 gates + rework, retry cap 3, disposition (back-to-HW / scrap-quarantine manager-tier), SHIPPED terminal | Data shapes; UI | **Accessible — the directive's "if not accessible: STOP" clause is NOT triggered** (FACT). The directive's own category list matches it exactly |
| 4 | BRS | `Digital_Factory_Requirements.md` (read full; `.json` structured twin present, spot-consistent; `.docx` binary original not text-extracted — the `.md`/`.json` are its designated readable forms per that folder's `README.md`) | Business requirements v1.0 (2026-06-16) | Requirement IDs (ORD/ALLOC/ASM/SW/PROV/GATE/HW/MDL/CAL/QC/BK/SHIP/RBAC/UNIT/IF/AUD/SCALE/RPT), GP-1…6 principles, 3-tier RBAC, decision log (20 decisions), serial-worthy sub-assembly list | Post-BRS operator decisions (variants, actors-in-app) | Agrees with flowchart & stages.json; **partially conflicts with `docs/factory-flow-model.md`** (§25-C1, C2) |
| 5 | Product invariants | `ai/product-invariants.md` | Ratified constraints | 7 invariants | UI meaning | Consistent with backend behavior (verified against `workflow_rules.py`) |
| 6 | Runtime contracts | `ai/runtime-contracts.md` | Boundary rules | Compose-only runtime, REST-only frontend, backend owns transitions, env-var config | — | Contracts 1–3, 6 hold in code; Contract 4 stale (Postgres exists since D7) — known drift |
| 7 | Service boundaries | `ai/service-boundaries.md` | Ownership | frontend/backend/docs/ai split | — | Holds; directory sketch stale |
| 8 | Backend workflow rules | `backend/app/workflow_rules.py` (904 ln, read full) | **Implementation truth for behavior** | Every enforced rule, block, transition, authority check | Intent/why | Faithful to BRS with enumerated exceptions (§10, §11, §25) |
| 9 | Backend models/schemas | `backend/app/models.py`, `db_models.py`, `state_store.py`, `seed.py`, `repositories.py`, `data_loader.py`, `db.py`, `settings.py`, `alembic/versions/001` (models/state_store full; others full-or-head) | Data shapes | Field-level availability (§21) | — | Known seeding losses (multi-role users, `can_perform_stages`, stage `requirements`/metadata, part `note`) confirmed still present in `seed.py`/`db_models.py`/`state_store.py` — matches D9A §5 |
| 10 | Seed/demo data | `data/*.json` (all 8 read; events via structured dump) | Demo truth | 7 units/3 orders/6 parts/6 users/2 recipes/3 ref-stds/22 events; every scenario’s exact fields | Production policy | Internally consistent except pre-existing PART-0004 fixture inconsistency (released `damaged_at_bench` yet UNIT-0004 alloc still `allocated_bound` → this is exactly why `findAffectedAllocation` finds nothing for UNIT-0004's stage-10 state — benign today; documented D9A §5) |
| 11 | API contracts | `backend/app/routes/*.py` (all read full), `frontend/src/api/factoryApi.ts` (full) | Wire truth | 10 GET + 11 POST surface; blocked=HTTP 200 semantics; 403/404/409/422 conventions | — | README API table matches code |
| 12 | Shared FactoryViewModel | `frontend/src/view-model/{types.ts,useFactoryViewModel.ts}` (full) | Frontend canonical data boundary | 16-member contract; 8-call load; select/refresh/reload/reset | orders/stock/staffing (not exposed) | All four options consume it (re-verified in code; matches D9D matrix) |
| 13 | Current console | `FactoryFlowBoard.tsx` + `UnitList/StageSpine/UnitDetailPanel/ActionPanel/EventTrace` (all full) | Baseline presentation truth | §8, §17 | — | Matches D9A/D9D descriptions |
| 14 | Attention-First | `attention-first/*.tsx` (4 files, full) | Variant A truth | §8, §17, §20 | — | Matches D9C-4 recon/journal |
| 15 | Workflow-First | `workflow-first/*.tsx` (4 files, full) | Variant B truth | 〃 | — | Matches D9C-5; the three `*ActionForm.tsx` confirmed byte-identical modulo variant-name strings via name-normalized diff (FACT) |
| 16 | Command-Center | `command-center/*.tsx` (4 files, full) | Variant C truth | 〃 | — | Matches D9C-6 |
| 17 | Prior recon/spec/task/journal | §5 ledger | Process + settled decisions | Operator decisions (3-variant structure; D9C-2 architecture-only; amended DAG; QC-distinct authority) | — | Mutually consistent |
| 18 | Verification scripts | `scripts/verification/001–016` (012–016 sampled; 001–011 known via journal/README) | Regression contract | What is machine-asserted today | Comprehension (none assert explanation content) | Consistent |
| 19 | Incident reports | 5 files (§5) | Process risk truth | Supervisor gaps; registry proxy bug; stdin drain | — | Consistent |
| 20 | Screenshots / observable UI | `artifacts/d8c-touch-verification/*.png` (9), `artifacts/d9a-current-flow-recon/*.png` (5), `artifacts/d9c1-…/*.png` (3) — enumerated; content per their producing recons. **No new browser session was opened for D9E-0** (mutation lock) | Visual evidence at capture time | Current pixel truth post-D9D | UI structure claims in §17 are sourced from component code (authoritative for structure), journal live-browser evidence (D9C-4/5/6/D9D addenda), and these artifacts — not from a new run |

**Operator-supplied documents inaccessible: NONE.** The flowchart, BRS, and transcript are all
present in-repo and were read. The directive's stop-for-missing-evidence branch is not triggered
(FACT).

---

## 7. Repository Architecture Map

FACT (all files read; sizes from `wc -l`):

```
Runtime (docker-compose.yml): postgres:16 ── backend (FastAPI 0.7.0, :8000) ── frontend (Vite dev server, :5173)
                                             │  entrypoint: wait-pg → alembic upgrade → uvicorn; seed on empty via lifespan
                                             └─ data/*.json ro-mounted at /app/data (DATA_DIR)

backend/app/
  main.py            app + CORS + routers + seed-on-empty lifespan
  routes/health.py   GET /health                      (stale phase string "D3_STACK_SCAFFOLD")
  routes/factory.py  GET /factory/scaffold-status     (stale D3 flags)
  routes/data_contract.py  10 GETs — units/parts/events FROM DB; stages/orders/users/recipes/ref-standards FROM JSON cache (split-brain risk documented D9A §3.3)
  routes/actions.py  11 POSTs — thin: get_state(db) → workflow_rules.* → persist_action(db)
  workflow_rules.py  ALL domain logic (904 ln) — §10/§11
  state_store.py     DB↔dict load/persist; `_UNIT_TOP_KEYS` + JSONB payload pattern
  seed.py / data_loader.py / db_models.py / db.py / settings.py / repositories.py (dead code)

frontend/src/
  main.tsx           hash gate: '#/variants' → VariantReviewShell, else App→FactoryFlowBoard (one-time read; no hashchange listener — known D9C-1 limitation)
  view-model/        useFactoryViewModel(): 8-call Promise.all; selectUnit/refreshSelected/reload/resetDemoState
  api/factoryApi.ts  typed client; 200+blocked is NOT an error
  types/factory.ts   mirrors backend read models
  components/        Current console: FactoryFlowBoard + UnitList + StageSpine + UnitDetailPanel + ActionPanel + EventTrace
                     (+ dead: AppShell, HealthStatus, DataContractStatus, D5BackendStatus; legacy dead api.ts/types.ts)
  components/variant-review/
    VariantReviewShell.tsx      4 top tabs (Current / Variant A — Attention-First / B — Workflow-First / C — Command-Center)
    VariantPlaceholderPane.tsx  now UNREFERENCED (dead since D9C-6 wired variantC) — new dead-code finding of this recon (FACT: no importer)
    attention-first/  AttentionFirstView + AssemblerView + FloorManagerView + AttentionActionForm
    workflow-first/   WorkflowFirstView + AssemblerWorkflowView + FloorManagerWorkflowView + WorkflowActionForm
    command-center/   CommandCenterView + AssemblerCommandView + FloorManagerCommandView + CommandCenterActionForm
  styles.css          MD3 token system ([data-theme] light/dark) + factory tokens + helper classes (§16)

Governance: vendor/engineering-os (49 files) · .engineering-os (config + 6 invariants) · ai/ (control docs, journal, registry, 11 recons, 5 incidents) · specs (21) · tasks (48) · scripts (6 + 16 verification) · docs (16) · source-materials (BRS/flowchart/transcript) · _archive (quarantined invented OS)
```

---

## 8. Application Route and Screen Inventory

FACT (from `main.tsx`, shell, and view components — all read full):

| Route / state | Renders | Identity shown to user |
|---|---|---|
| `/` (no hash) | `FactoryFlowBoard` (Current engineering console) | Header "Factory Cloud v0 / D8 Review Prototype / Postgres-backed"; `<title>` "Factory Cloud v0 — D8 Review Prototype" |
| `/#/variants` (fresh load only) | `VariantReviewShell` — 4 primary tabs; default `Current` | No page title change; no explanation of what the shell is for |
| Shell › Current | The same `FactoryFlowBoard`, full console inside the shell | Identical to `/` |
| Shell › Variant A/B/C | Variant root → secondary tabs `Assembler` / `Floor Manager` (default Assembler) | Tab labels only; **zero variant description anywhere** |
| Hash edited on an already-open page | **Nothing** — no `hashchange` listener; requires reload (documented D9C-1 limitation, re-confirmed in `main.tsx`) | — |

Screen/state inventory (each audited in §17):

- **Current**: unselected (empty Detail/Action: "Select a unit…"), selected-normal, selected-blocked, selected-terminal, action success/blocked/failed response, loading ("…" indicators per header stat; body renders empty lists), load error (header `Error: …` text), compact (<1024px) pane-switcher variant of all of the above, light/dark themes, Reset flow.
- **Attention-First**: Assembler calm; Assembler interrupt (takeover card) with action (S-12) / without action ("Needs floor manager approval…"); Assembler unsupported-attention (same message path); FM counter=0 calm; FM triage list + queue; TriageRow actionable (Resolve/Hide + form) vs non-actionable ("No resolution action is available in this comparison view."); Loading; load-error.
- **Workflow-First**: Assembler calm single card + always-visible action; Assembler blocked-inline section (same card); FM Queue pane w/ collapsed triage button ("N need attention — tap to view"), expanded triage, Secondary Info pane ("Order, stock, and staffing information is not available in this view."); loading/error.
- **Command-Center**: Assembler simultaneous regions (conditional Attention banner / Current Unit + action / Other Units / `<details>` Supporting Detail collapsed); FM simultaneous (Attention block when non-empty / Queue / always-visible Secondary Context); loading/error.
- **Review shell**: variant/actor selection; selected-state = in-memory `useState` only (lost on reload — reload returns to Current+Assembler defaults); no route per variant/actor; **no comparison guidance of any kind** (FACT: shell renders tabs + pane only).

Empty state: a genuinely empty factory (0 units) renders "Loading…" forever in all three variants
(`units.length === 0 && !loadError` is treated as loading) and an empty queue in Current —
indistinguishable from load-in-progress (FACT from the three root views; classified §22/§24).

---

## 9. Shared Data / Orchestration Map

FACT (from `useFactoryViewModel.ts`, `factoryApi.ts`, routes):

- One hook instance per mounted option (Current/A/B/C each call it once; shell mounts exactly one at a time) — re-verified in all four roots; matches D9D dimension 1–2.
- Load = `Promise.all` of 8 GETs: `/health`, `/factory/data-contract/status`, `/factory/stages`, `/factory/units`, `/factory/events`, `/factory/users`, `/factory/parts`, `/factory/reference-standards`. `GET /factory/orders`, `/factory/model-recipes`, `/factory/units/{id}` (except on select/refresh) are **not** loaded by the view model.
- `selectUnit(id)` → `fetchUnit`; `refreshSelected()` → unit+events+units; `reload()` → all 8; `resetDemoState()` → `POST /factory/dev/reset-state` then reload (Current-only button).
- Mutations: variant forms call `postReallocatePart` / `postCalibration` / `postCalibrationDisposition` / `postCloudBackup` directly (fixed demo-actor constants; §13). Current's `ActionPanel` additionally calls scan-part, hardware-gate, qc-signoff, package, ship, transition.
- Server truth: units/parts/events from Postgres; stages/orders/users/recipes/ref-standards served from the JSON cache while workflow authority reads the DB-seeded (lossy) copies — the latent split-brain risk documented in D9A §3.3 remains (FACT re-verified in `data_contract.py` + `state_store.py`).
- No push/real-time infrastructure exists anywhere (D9A §10; re-confirmed: no ws/sse dependency in `factoryApi.ts`/`package.json` readings this session). All freshness is fetch-on-mount / fetch-after-action.

## 10. Fourteen-Stage Manufacturing Matrix

Sources per row: BRS §2/§4 + flowchart (operator canon), `data/stages.json` (in-app stage truth,
served by `GET /factory/stages`), `docs/factory-flow-model.md` (frozen doc), `workflow_rules.py`
(behavior), `data/factory_units.json` + `data/events.json` (demo), variant/Current components (UI).
"UI rep." = what any screen shows for the stage today. Abbreviations: FM=Floor Manager, WR=workflow_rules.py.

**Cross-cutting facts (apply to all rows):**
- Ordering/legality: hardcoded `STAGE_SEQUENCE` +1-only in WR:29–33, 803–817; dedicated actions hardcode their entry stage. `normal_next_stage_id`/`allowed_rework_stage_ids` in stages.json are **never consulted** by WR (D9A §3.5 #3, re-verified) — DERIVATION.
- Persistent unit-level block fields (`blocked_reason`/`block_type`/`no_override`) are written by WR only at: S-09 fail (reason only, **no block_type**), S-10 cap-exceeded, disposition scrap/quarantine (quarantine: reason only, **no block_type** — latent bug WR:608–619), S-12 cloud-unavailable. Everything else that "blocks" is a **transient per-call** `ActionResponse` (FACT, grep-verified across WR; matches journal remediation note).
- Audit: every WR action appends an event (id `EVENT-D5-NNNN`) with actor/timestamp/severity/payload; events are immutable rows (FACT).
- Authority enforcement per action (FACT, §13): scan-part none · reallocate `can_override` (200/"failed" if not) · hardware-gate none · calibration none · disposition `disposition_authority` (403) · qc-signoff `can_qc_signoff` + SoD (403/blocked) · cloud-backup none · package/ship/transition none.

| S | Canonical name (stages.json) | Category (stages.json / BRS) | Owner / actor | Entry condition | Normal work | Required inputs | Serialized-traceability interaction | Gate/decision | Success → forward | Documented failure modes (trigger → severity → scope) | Override | Recovery (actor → action → destination; retries) | Terminal outcome | Audit | Data available to frontend | Current UI representation | Missing UI explanation (headline) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Order created | external / upstream | Customer via eStore (BRS §2; transcript: customer customizes; payment upstream in eStore, outside factory scope — D9B §1.10) | — | order intake upstream | — | none | no | →S-02 | none documented in-factory | — | — | — | seed EVT only | `orders.json` via `GET /factory/orders` (NOT in view model) | StageSpine row + EXTERNAL badge | Who creates orders and that this is outside the factory is never stated in actor views (spine hidden there) |
| 2 | Order approved | external / upstream | Sales manager (BRS) | order created | sales approval | checklist (BRS §4.5 narrative; transcript ~54:00 export-restriction example) | none | no | →S-03 | none in-factory | — | — | — | — | `approved_by/approved_at` on order | 〃 | 〃 |
| 3 | Order received | factory_core; **flowchart draws it as a decision node** | Factory system (boundary validation) | approved order handed over | validate ORD-1 fields + known model recipe (ORD-2/3, MDL-1) | order fields, recipe registry | units provisioned w/ `genealogy_serial` at acceptance | boundary check (hardstop control `boundary_validation_hardstop`, `no_override: true` in stages.json) | →S-04 | **Boundary rejection**: missing field / unknown model → order rejected, reason reported upstream (BRS ORD-2/3; seed ORDER-0003 `rejected`, `unknown_model_no_recipe_found`; EVT-0022 severity `error`) → order-scoped (no unit exists) | none | upstream fixes order; **no runtime path exists in backend** (no order-intake endpoint; rejection exists only as seed data) — TBD for future capability, not D9E | rejected order (dead-ends) | EVT-0001/0022 | full order incl. `boundary_validation_status`, `rejection_reason` — **fetched by no screen** | **None.** Orders invisible in every UI (D9A §9 finding unchanged) | Stage-3 rejection — a flowchart-named scenario — cannot be seen anywhere |
| 4 | Parts allocated | factory_core | Inventory operator (BRS ALLOC-1; seed users: `inventory_op` role) | order accepted | reserve specific serials; deliver to bench | inventory serials | `Part.allocated_to_order_id`; unit `part_allocations{type→part_id,status}`; genealogy `parts_allocated` | no (control: `reallocation`, supervisor, `no_override:false`, `halts_order:false`) | →S-05 | **Serial unusable** (damaged/lost/failed-at-bench/reprioritized) → supervisor re-allocation (ALLOC-2..5); **no replacement available → order WAITS** (flowchart HOLD) | realloc requires supervisor (`can_override`) | Supervisor → `reallocate-part` (works at any non-terminal stage in WR — not stage-gated; releases old serial w/ `release_reason_code`, binds new, appends `genealogy.reallocation_history`, keeps both serials) → same stage | — | `supervisor_reallocation` event | parts + allocations + genealogy | Current: Part Allocations rows + Supervisor Reallocation form (S-05 only); variants: realloc only inside stage-5-blocked branch (unreachable — see S-05) | HOLD/waiting state not modeled anywhere; "allocated_unbound vs allocated_bound" never explained |
| 5 | Assembly | factory_core; flowchart draws the scan as a verification decision | Assembler (operator tier) | parts at bench | scan each serialized part → bind ("marry") to genealogy (ASM-3) | allocated serials | scan binds `part.bound_to_unit_id`, alloc→`allocated_bound`, genealogy `parts_bound`; sets `assembly_operator_id`/`assigned_operator_id`/`station_id` (WR:188–197) | **5 named hard-stops, no bench override** (ASM-1/2; stages.json `trigger_cases` ×5) | →S-06 (via generic transition — no dedicated "assembly complete" action) | `unknown_serial`, `wrong_part_type` (2 paths), `already_used_serial` (2 paths), `wrong_serial_for_allocated_slot` — each: reject event (warning) + transient blocked response; **`out_of_sequence` declared in stages.json but has NO WR implementation** (§26-T2); wrong-stage guard | none at bench (matches ASM-2) | correct part re-presented → rescan; wrong/lost part → supervisor realloc → rescan | — | `assembly_scan_rejected/accepted` events | everything scanned + reject reasons (in ActionResponse + events) | Current: Assembly Scan + Realloc forms; variants: **scan action entirely absent** (form maps only 5-blocked/10/12) and stage-5 blocks are never persisted, so a "blocked assembly" unit can never appear in any queue/triage (FACT: WR `_scan_reject` writes no unit field; journal remediation confirmed live-unreachable) | The assembler's *primary job* (scan) is invisible in all three actor-first variants; the five hard-stop cases are never enumerated to the user |
| 6 | Software & firmware install | factory_core | Technician per flow-model; transcript: assembler starts it and walks away | assembly complete | flash pinned validated baseline (SW-1/2); no cloud identity yet | baseline `firmware_baseline` per recipe | genealogy timestamps (`sw_baseline_installed_at` in seed) | no | →S-07 (generic transition only) | none documented (stages.json `hard_stop_controls: []`) → **TBD — NO AUTHORITATIVE FAILURE MODE FOUND** (transcript mentions "download failed → retry" as intent, not a modeled rule) | — | — | — | — | recipe `firmware_baseline` (recipes endpoint unconsumed) | Stage name only | What "pinned validated baseline" means/why (SW-1 rationale) never shown |
| 7 | Software & firmware update from cloud | `hard_block_dependency` (stages.json); **BRS/flowchart: cloud hard block, NO override — documented management decision** | System / cloud (transcript: start & walk away) | baseline installed | confirm device holds latest production SW/FW (SW-3) | cloud reachability | — | cloud-availability check (conceptually; **no backend action or check exists for S-07 at all** — no endpoint, no WR function) | →S-08 | **Cloud unreachable → HARD BLOCK, unit waits, no override** (SW-4 + decision note verbatim in stages.json). Demo: UNIT-0002 seeded blocked (`cloud_unreachable_sw_update_cannot_proceed`, `block_type=hardstop_cloud_dependency`, `no_override=true`); EVT-0004 (critical) + EVT-0005 floor alert (critical, SW-5) | **none** (BRS explicit) | cloud returns → unit re-checks (flowchart dotted arrow). **No recovery path exists in the app**: no S-07 action; generic transition refuses (blocked_reason+block_type set) ⇒ UNIT-0002 is permanently blocked in the demo (FACT; journal D9C-4 §9 same finding) | — | seeded events only | block fields + stages.json decision_note (served, unrendered) | Current: red spine row + CLOUD BLOCK/NO OVERRIDE badges + raw reason; ActionPanel "No actions available at this stage". Variants: attention row; Assembler copy says **"Needs floor manager approval — visible in the Floor Manager triage list"** while FM row says "No resolution action is available in this comparison view." | The true story ("waiting for cloud; nobody on the floor can or should act; management chose this trade-off") is never told; the Assembler copy is **factually wrong** for this stage (§24-D1, §25-C4) |
| 8 | Cloud provisioning | factory_core | System | SW current | create cloud identity; credential separate from genealogy serial, 1:1, rotatable (PROV-1..3) | cloud | credential↔serial binding (concept) | no | →S-09 | none in stages.json/WR → **TBD — NO AUTHORITATIVE FAILURE MODE FOUND in implementation**; `docs/factory-flow-model.md` hard-stop table lists "Cloud provision failure (S-08) → Supervisor" — **CONFLICT C3 (§25)**: BRS/flowchart/stages.json/WR have no S-08 failure | — | — | — | — | `cloud_status.provisioned` bool | stage name; Detail "Cloud/Ship" rows | PROV rationale (rotatable credential vs permanent genealogy serial) never shown |
| 9 | Hardware checks / setup | **gate** (stages.json `is_gate:true`, GATE 1 in flowchart) — `docs/factory-flow-model.md` table types it `factory core` → **CONFLICT C1 (§25)** | Technician (flow-model) / assembler-partly (transcript: filter-wheel test runs long, button test needs presence) | provisioned | config-driven checks vs ordered model recipe (HW-1/2, MDL-1; recipes carry per-check `pass_criteria`) | model recipe | verifies built unit matches order (GP-1) | pass/fail | pass → S-10 (WR:362–374 sets `hw_gate_passed`) | **Gate fail / missing-or-unexpected hardware** → HW rework then re-enter S-09 (flowchart RW9; stages.json `fail_reentry_stage_id: STAGE-09`). WR:375–386: status `hardware_rework_required`, `blocked_reason` = free-text reason or `hardware_gate_failed` (**no block_type**), unit stays at S-09, warning event | n/a (rework, not override) | anyone resubmits `hardware-gate` with pass (WR only checks stage — blocked state does not prevent retry; no authority check); unlimited retries (no cap documented — matches BRS silence) | — | `hardware_gate_passed/failed` events | `gate_results["STAGE-09"]` incl. checks | Current: gate form + amber GATE badge; variants: **no S-09 action mapped** — a runtime-failed unit would appear in triage with "No resolution action…" (truthful but unhelpful) | "What checks, against which recipe, and what rework means" never shown; recipes endpoint unconsumed |
| 10 | Calibration | **gate** (GATE 2) | Calibration technician (`calibration_tech` role; transcript: start & walk away, human switches samples) | HW gate passed | validate ref standards then run calibration; capture full record (CAL-1 list in stages.json `calibration_metadata.record_captured`) | valid reference standard(s), equipment id | certificate `CERT-D5-<unit>-ATT<n>`; all attempts retained (`attempt_history`) | pre-check + pass/fail + retry loop (cap 3) + disposition | pass → S-11; cert issued; gate_results set | (a) **Invalid/unknown/expired/uncertified ref standard** → HARD-STOP, cannot start/complete, **no override** (CAL-3): WR:417–445 blocks with `no_override=true`, error event, per-attempt (not persisted on unit); (b) **attempt fail < 3** → warning event, remaining count; (c) **3rd fail → cap exceeded** (CAL-4/5): persisted `blocked_reason=calibration_cap_exceeded_supervisor_disposition_required`, `block_type=calibration_retry_cap`, error event | (a) none; (c) none below supervisor | (a) obtain valid standard → retry attempt (pre-check re-runs each attempt); (c) supervisor/manager disposition — §12 | scrap → terminal; quarantine → indefinite non-terminal hold | every attempt + hard-stop + cap + disposition events | full `calibration_summary` incl. history; 3 ref standards (1 valid / 1 expired / 1 missing-cert) | Current: Calibration form (free-text comma-separated ref-std IDs; defaults to usable ones), Disposition form on cap; Detail attempts x/3 + cap row; variants: calibration submit (calm) + 3 disposition buttons (triage/FM) | Attempts-remaining consequence ("one attempt left before supervisor disposition") never phrased; **the no-override ref-standard hard stop is undemonstrable from variants** — their forms auto-pick `can_be_used_for_calibration` standards (FACT: `AttentionActionForm.tsx:139` and twins) |
| 11 | Quality Control | **gate** (GATE 3), final human sign-off | QC sign-off authority — distinct named authority (BRS RBAC-2; operator-settled D9B §0). Demo: only `USER-QC-0001` has `can_qc_signoff` (supervisor & manager: false) | calibration passed w/ certificate | verify physical unit + complete digital record (QC-1/2; stages.json `qc_metadata.checks` ×8) | prior gates passed, cert present | verifies genealogy complete; pass **finalizes record** (QC-3; product-invariant 5) | sign-off w/ separation-of-duty (signer ≠ assembly op ≠ calibration op; manager-tier waiver, logged — RBAC-3/4) | pass → S-12, `blocked_reason=None`, status `qc_complete_backup_pending` | Prerequisite blocks (transient): hw gate not passed / cal gate not passed / certificate missing; **SoD violation** → blocked `separation_of_duty_violation` unless valid waiver (403 if waiver actor lacks `can_waive_separation_of_duty`); **QC fail/rework (BRS RW11 “fail → QC rework/disposition → re-enter S-11”) is NOT implemented — there is no reject/fail action for QC at all** (FACT: WR has only sign-off; §26-T3) | waiver = manager tier only, recorded | (unimplemented rework path); prerequisites → do the missing gate first | — | `qc_signoff_complete` event (records waiver) | `qc_summary` (+ waiver fields when used) | Current: QC form incl. waiver fields (checklist hardcoded to 2 items in the client!); variants: **stage 11 unmapped — UNIT-0005 “QC ready” shows NO action in any variant** | SoD and waiver semantics (the accountability story) never explained; QC-fail path missing entirely |
| 12 | Cloud backup | `hard_block_dependency` — cloud hard block #2, NO override (BK-2; documented management decision in stages.json) | System (operator triggers; transcript: start, walk away, check later) | QC passed (enforced: WR requires stage 12 which is only reachable via QC pass) | back up full record (genealogy, calibration record, certificate, test results — stages.json list) | cloud reachability (`cloud_available` request boolean — **client-typed mock**, D9A §11) | record preserved off-site before leaving floor | availability check | confirmed → S-13, block cleared (`no_override=False`) | **Backup cannot complete** → persisted `blocked_reason=cloud_backup_cannot_complete_connectivity_unavailable`, `block_type=hardstop_cloud_dependency`, `no_override=true`, error event. Demo: UNIT-0006 seeded in this state | **none** (BRS) | cloud returns → resubmit backup with `cloud_available=true` (any actor; no authority check). Variants: "Retry Cloud Backup" button hardcodes `cloud_available: true` | — | `cloud_backup_hard_stop/confirmed` events | `cloud_status` + block fields | Current: Cloud Backup form w/ checkbox + inline warning; variants: Retry button in Assembler-interrupt (S-12 only) & triage | "Retry" silently asserts the cloud is back (simulation semantics unexplained); demo-walkthrough's "supervisor clears the block" narrative conflicts with BRS no-override wording (§25-C4) |
| 13 | Package | factory_core, separable | Operator (transcript: ~100% human) | backup confirmed | package device | — | `packaged_at` genealogy | no | →S-14 | none documented → **TBD — NO AUTHORITATIVE FAILURE MODE FOUND** | — | — | — | `unit_packaged` event | `package_ship_status.packaged` | Current: Package form; variants: **unmapped (no action)** | "Separable/fulfillment" concept never shown to actors (fine), but packaging step is invisible in variants |
| 14 | Ship | **terminal** | Operator/Manager (flow-model); ship form defaults `USER-MGR-0001` | packaged | record ship; attach certificate + docs (SHIP-1) | QC signed off + cloud backed up (WR re-checks both — second gate) | record immutable (SHIP-4; invariant 6) | prerequisites | terminal `shipped`; `terminal/immutable=true` | transient blocks `qc_not_passed` / `cloud_backup_not_confirmed`; after terminal: **any action → HTTP 409** (all WR actions check `_is_terminal`) | — | — | **shipped** (also terminal family: `rejected` — defined in flow-model/`_is_terminal` but **no code path ever sets it** (§26-T4); `scrapped` via disposition) | `unit_shipped` event | `package_ship_status`, doc refs param (unused by UI) | Current: Ship form + TERMINAL banner; UnitList SHIPPED badge; variants: terminal units filtered out of queues entirely | "Why a shipped unit disappears from actor views" unexplained; certificate/docs never surfaced |

**Directive flowchart-category validation (DERIVATION over the matrix):** Stage-3 boundary
rejection ✓ (seed/order-level only) · Stage-4 reallocation-or-waiting ✓/partial (realloc live;
HOLD unmodeled) · Stage-5 five hard stops ✓ 4-of-5 live-enforced, `out_of_sequence` data-declared
only · Stage-7 cloud hard block ✓ (seed-permanent, no recovery endpoint) · Stage-9 hardware rework
✓ · Stage-10 invalid-ref-standard hard stop ✓ (transient) · retry ✓ · retry-cap disposition ✓ ·
return-to-hardware ✓ · quarantine/scrap ✓ (quarantine non-terminal + block_type bug) · Stage-11
QC rework/disposition ✗ **not implemented** · Stage-12 backup hard block ✓ · Stage-14 shipped
terminal ✓.

---

## 11. Failure-Mode Catalog (normalized)

Proposed stable identifiers are **PROPOSALS pending operator approval** (directive: do not
canonicalize). "Persisted?" = written to the unit record (drives queues/triage/attention) vs
transient per-call `ActionResponse` only. Presentation columns describe today, not recommendations.
Confidence: H = code+doc+seed agree.

| Proposed ID | Raw backend identifier(s) | Stage | Trigger | Human title (proposed, non-canonical) | Plain-language explanation (proposed) | Operational consequence | Unit status | Factory-flow consequence | Viewing actor today | Recovery owner | Authority | Available action | Unavailable/prohibited | Recovery transition | Audit effect | Recommended semantic (proposal, §28) | Presentation today (Current / A / B / C) | Truth source | Conf. | TBD |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| FM-S03-REJECT | `boundary_validation_status="rejected"`, `unknown_model_no_recipe_found` | 3 | missing field / unknown model at boundary | Order rejected at factory boundary | The factory refused an order it cannot build; the reason was reported back upstream | order never enters floor | n/a (no unit) | none (order-scoped) | **nobody** (orders unrendered) | upstream (eStore/sales) | system auto | none in-app | admitting invalid order | fixed order re-submitted upstream | EVT-0022 (error) | Informational/rejected | — / — / — / — | BRS ORD-2/3; `orders.json`; stages.json | H | runtime path absent |
| FM-S04-REALLOC-NEEDED | part `released` + `release_reason_code` (`damaged_at_bench`, …) | 4/5 | allocated serial damaged/lost/failed/reprioritized | Allocated part unusable — replacement needed | The specific reserved part can't be used; a supervisor must approve a replacement serial | bench waits for replacement | unchanged | unit paced, line not halted (`halts_order:false`) | FM (via realloc form); Current | Supervisor | `can_override` | `reallocate-part` | operator self-swap (BRS ALLOC-2); factory freeing stock (ALLOC-5) | same stage, new serial bound, both serials in genealogy | `supervisor_reallocation` | Approval-required / recoverable | Current form / variants: only when a (never-occurring) persisted stage-5 block exists | WR:212–331; BRS ALLOC | H | HOLD/no-replacement state unmodeled |
| FM-S05-UNKNOWN-SERIAL | `unknown_serial` | 5 | scan matches nothing in inventory | Unknown part scanned | This barcode isn't in inventory at all — stop; the part cannot be verified | scan blocked at bench | unchanged (transient) | none persisted | actor who scanned (Current only) | Assembler w/ correct part; else supervisor realloc | none at bench | rescan correct part | bench override (ASM-2) | rescan | reject event (warning) | Hard stop (bench) | Current: red BLOCKED response box; variants: n/a (no scan) | WR:132–138; BRS ASM-1 | H | — |
| FM-S05-WRONG-TYPE | `wrong_part_type` | 5 | scanned type ≠ part's type, or type not allocated for unit | Wrong part type for this step | 〃 wrong kind of part for what this build needs now | 〃 | 〃 | 〃 | 〃 | 〃 | 〃 | 〃 | 〃 | 〃 | 〃 | 〃 | 〃 | WR:143–150, 162–168 | H | — |
| FM-S05-ALREADY-USED | `already_used_serial` | 5 | serial bound to another unit, or slot already bound | Part already used in another device | That exact serialized part is already married into a different device's record | 〃 | 〃 | 〃 | 〃 | supervisor realloc if truly conflicting | 〃 | 〃 | 〃 | 〃 | 〃 | 〃 | 〃 | WR:152–159, 179–185 | H | — |
| FM-S05-WRONG-SERIAL-FOR-SLOT | `wrong_serial_for_allocated_slot` | 5 | serial ≠ the allocated serial for this unit's slot | Not the part reserved for this device | Right type, wrong individual — this device must use its specific reserved serial | 〃 | 〃 | 〃 | 〃 | inventory op delivers correct serial; or supervisor realloc | 〃 | 〃 | 〃 | 〃 | 〃 | 〃 | 〃 | WR:170–177; ALLOC-1 | H | — |
| FM-S05-OUT-OF-SEQ | (declared `out_of_sequence` in stages.json; **no WR code**) | 5 | part scanned for a step that shouldn't happen yet | Part scanned out of build order | — | — | — | — | — | — | — | — | — | — | — | — | — | stages.json trigger_cases | H (as gap) | **TBD — declared, unimplemented (§26-T2)** |
| FM-S07-CLOUD-BLOCK | `cloud_unreachable_sw_update_cannot_proceed` / `hardstop_cloud_dependency` / `no_override=true` | 7 | cloud unreachable at SW/FW currency check | Cloud outage — firmware update blocked (no override) | The factory deliberately halts here so no device ships without current firmware; wait for cloud to return | all affected units wait; floor alerted (SW-5) | `cloud_blocked` | line-level for stage-7 WIP (EVT-0005 floor alert) | Assembler (if focused), FM triage, Current | nobody on floor — cloud/external | none (management decision) | **none** (no endpoint) | any override | cloud returns → re-check (unimplemented) | seeded critical events | Hard block / waiting-on-external | Current: full block panel + badges; A: takeover w/ **misleading "Needs floor manager approval"**; B: inline attention (same copy); C: banner (same copy) | BRS SW-4/5; stages.json; seed; WR-absence | H | recovery endpoint absent by design or omission? (§26-T5) |
| FM-S09-GATE-FAIL | `hardware_gate_failed` or free-text reason; status `hardware_rework_required` | 9 | gate result=fail (missing/unexpected hardware, checks fail) | Hardware check failed — rework | The built unit doesn't match its ordered recipe; fix hardware and re-run the checks | unit loops at S-09 | blocked (persisted reason; **no block_type**) | unit-scoped | FM triage (once persisted), Current | Technician/assembler rework; anyone may resubmit gate | none enforced | resubmit `hardware-gate` | — | re-enter S-09 checks (RW9) | `hardware_gate_failed` (warning) | Rework / recoverable | Current: gate form; variants: triage row with "No resolution action…" (S-09 unmapped) | WR:375–386; stages.json | H | retry cap: none documented |
| FM-S10-REFSTD | `invalid_reference_standard` / `reference_standard_expired` / `reference_standard_missing_certificate` + `no_override=true` | 10 | any selected standard unknown / not usable | Reference standard invalid — calibration cannot start (no override) | Calibrating against an out-of-cert standard would produce a worthless certificate; a valid standard is required first | attempt refused; unit stays pre-attempt | unchanged (transient) | unit paced | Current only (variants auto-pick valid standards) | Supervisor obtains valid standard (BRS CAL-3 narrative) | none | retry with valid standard | proceeding with expired/uncertified standard | re-run pre-check → attempt | `calibration_ref_std_hardstop` (error) | Hard stop (no override) | Current: blocked response + NO OVERRIDE; variants: **undemonstrable** | WR:417–445; REFSTD-0002/0003; CAL-3 | H | not persisted — flow-model table implies a persistent supervisor-cleared stop (§25-C4 wording family) |
| FM-S10-ATTEMPT-FAIL | `calibration_attempt_failed` | 10 | attempt result=fail, attempts<3 | Calibration attempt failed — N remaining | The device didn't meet spec this run; up to 3 tries are allowed, every attempt is recorded | retry available | `calibration_in_progress`-family | unit paced | all (UNIT-0003 seeded at 2/3) | Cal tech retries | none | `calibration` again | 4th attempt (cap) | attempt++ | warning event | Warning / retry | Detail "Attempts 2/3"; variants show nothing about remaining margin | WR:514–527; CAL-4 | H | — |
| FM-S10-CAP | `calibration_cap_exceeded_supervisor_disposition_required` / `calibration_retry_cap` | 10 | 3rd failed attempt | Calibration cap reached — supervisor decision required | Three strikes: the line may not keep retrying; a supervisor must choose rework, quarantine, or scrap | unit halted pending decision | `calibration_cap_exceeded_awaiting_disposition` | unit halted | FM triage + all | Supervisor (route/quarantine), Manager (scrap) | `disposition_authority` (403 otherwise) | 3 disposition buttons / form | 4th attempt (WR:409 refuses) | §12 | error + critical seed events | Approval-required (escalation) | Current disposition form; variants: 3 buttons w/ fixed `USER-MGR-0001` | WR:496–513, 532+; CAL-5 | H | — |
| FM-S10-QUARANTINE | `quarantined: <reason>`; status `quarantined`; **block_type NOT set** | 10 (disposition) | supervisor picks quarantine | Unit quarantined | Set aside pending review — neither scrapped nor back in flow | indefinite hold | quarantined (non-terminal) | unit out of flow but still in every non-terminal queue/triage | FM/all | **TBD** — no un-quarantine/release action exists | supervisor+ | none after entry | — | none implemented (dead end) | `unit_quarantined` (warning) | Quarantined (distinct terminal-ish semantic) | shows as just another red BLOCKED row everywhere | WR:608–619 | H | exit path TBD (§26-T6); block_type bug → generic transition may not refuse (D9A latent bug, unfixed) |
| FM-S10-SCRAP | `scrapped_after_calibration_cap: <reason>`; status `scrapped`; `terminal=true` | 10 (disposition) | manager picks scrap | Unit scrapped (write-off) | High-cost final decision; record immutable (RBAC-1) | unit removed permanently | scrapped (terminal) | out of flow | disappears from variant queues; Current keeps row | — | manager tier only | — | any further action (409) | — | `unit_scrapped` (error) | Scrapped (terminal, distinct from shipped) | UnitList keeps generic row (no SCRAPPED badge — only SHIPPED/BLOCKED exist) | WR:596–606 | H | — |
| FM-S11-PREREQ | `prerequisite_hw_gate_not_passed` / `prerequisite_calibration_gate_not_passed` / `prerequisite_calibration_certificate_missing` | 11 | QC attempted with record gaps | QC blocked — record incomplete | QC is the last guard: it refuses to sign a unit whose record has a gap (QC-2) | sign-off refused | unchanged (transient) | unit paced | Current only | whoever owns the missing gate | — | complete missing gate | — | back to prerequisite | none (no event on these) | Warning / prerequisite | raw code in response box | WR:648–666 | H | no event emitted (audit gap? TBD-T7) |
| FM-S11-SOD | `separation_of_duty_violation` | 11 | signer == assembly op or calibration op | Sign-off refused — separation of duty | The person who built or calibrated a unit cannot certify it; a manager may waive, and every waiver is logged (RBAC-3/4) | sign-off refused unless waived | unchanged (transient) | unit paced | Current only | different QC signer, or manager waiver | `can_waive_separation_of_duty` (waiver); 403 if waiver actor invalid | provide waiver fields | self-certification | signed w/ waiver recorded | waiver recorded in qc_summary + event payload | Approval-required (accountability) | Current: two raw optional fields; variants: n/a (no QC action) | WR:668–699; RBAC-3/4 | H | — |
| FM-S11-QC-FAIL | — (**not implemented**) | 11 | BRS QC-fail (cosmetic/doc/record gap → rework/disposition, re-enter S-11) | — | — | — | — | — | — | — | — | — | — | — | — | — | — | BRS §4.5 QC; flowchart RW11 | H (as gap) | **TBD — capability absent (§26-T3); not for D9E to add** |
| FM-S12-CLOUD-BLOCK | `cloud_backup_cannot_complete_connectivity_unavailable` / `hardstop_cloud_dependency` / `no_override=true` | 12 | `cloud_available=false` at backup | Cloud outage — record backup blocked (no override) | The device must not leave the floor until its irreplaceable record is safe off-site (BK-2) | cannot package/ship | `cloud_backup_blocked` | unit(s) held pre-ship | all (UNIT-0006 seeded) | operator retry when cloud returns | none required (no authority check) | Retry (backup w/ `cloud_available=true`) | any override | → S-13 on confirm; block fields cleared | error event + seeded critical | Hard block / waiting-on-external | Current: checkbox + warning; variants: "Retry Cloud Backup" (hardcodes cloud back) | WR:741–779; BK-2 | H | — |
| FM-S14-PREREQ | `qc_not_passed` / `cloud_backup_not_confirmed` | 14 | ship attempted w/o prerequisites | Ship blocked — record not complete | 〃 final re-check before terminal | ship refused | unchanged (transient) | — | Current only | owner of missing step | — | complete prerequisite | — | — | none | Warning | raw code in response box | WR:884–889 | H | no event (TBD-T7) |
| FM-TERMINAL-IMMUTABLE | HTTP 409 `terminal state; record is immutable` | any | any action vs shipped/rejected/scrapped | Record immutable | Terminal records are legal documents (invariant 6) | none possible | terminal | — | Current (Dev form demo) | — | — | — | everything | — | — | Terminal | Current: 409 error text; variants: terminal units filtered out | WR `_is_terminal` ×10 call sites | H | `rejected` unreachable (T4) |
| FM-WRONG-STAGE | `wrong_stage` | any dedicated action | action at wrong stage | Action not valid at this stage | Each action belongs to one stage; the unit isn't there | refused | unchanged (transient) | — | Current | — | — | use correct action | — | — | none | Info | raw code | WR per-action guards | H | — |
| FM-AUTH-INSUFFICIENT | `insufficient_authority` (200/"failed") or HTTP 403 | realloc / disposition / QC / waiver | actor lacks capability flag | Not authorized for this action | This decision belongs to a higher/different authority tier | refused | unchanged | — | Current (typed actors); variants can 403 only if seed constants drift | correct-tier actor | per §13 | — | — | — | none for realloc-failed; 403s unlogged | Authority | inconsistent shapes (D9A §3.5 #5, unfixed) | WR:220–230, 547–563, 639–646, 685–691 | H | signaling inconsistency = defect (§24) |

---

## 12. Recovery-Path Catalog

FACT (WR + flowchart), keyed to §11:

| From condition | Recovery actor | Action (endpoint) | Destination / effect | Retry semantics | Notes |
|---|---|---|---|---|---|
| S-05 scan reject (any of 4 live cases) | Assembler | re-scan correct part (`scan-part`) | binds part; stays S-05 | unlimited | no persisted block to clear |
| S-05 wrong/lost part | Supervisor | `reallocate-part` | new serial bound; old released w/ reason code; both retained in genealogy | n/a | works at any non-terminal stage (WR does not stage-gate it) — broader than BRS's S-04/5 framing (INFERENCE: intentional demo convenience; TBD-T8) |
| S-07 cloud block | — (external cloud) | **none exists** | flowchart: cloud returns → re-check → S-08 | n/a | permanently blocked in demo; only full demo reset restores |
| S-09 gate fail (rework) | Technician (any caller) | `hardware-gate` result=pass | S-10; `hw_gate_passed` (note: WR does **not** clear the persisted `blocked_reason` on pass — it only sets status/stage; reason remains until another action clears it → stale-block display risk, §24-D6) | unlimited | fail again → same loop |
| S-10 ref-std hard stop | Cal tech w/ valid standard (supervisor obtains standard per BRS) | `calibration` with usable standard ids | proceeds to attempt | per-attempt pre-check | no persisted state to clear |
| S-10 fail < cap | Cal tech | `calibration` again | attempt++; history retained | cap 3 | |
| S-10 cap → route back | Supervisor (`route_to_hardware_rework`/`route_back_to_stage_9`) | `calibration-disposition: route_back_to_hardware` | S-09; attempts reset to 0/3; STAGE-09/10 gate_results cleared; block cleared | new cycle authorized (matches flow-model "new attempt cycle") | |
| S-10 cap → quarantine | Supervisor+ | `calibration-disposition: quarantine` | status quarantined; blocked_reason set; **no exit path** | — | dead-end (T6) |
| S-10 cap → scrap | Manager | `calibration-disposition: scrap` | terminal scrapped | — | RBAC-1 honored via `disposition_authority` |
| S-11 prerequisite blocks | owner of missing gate | do that gate | — | — | |
| S-11 SoD | different signer, or manager waiver | `qc-signoff` (+waiver fields) | S-12; waiver recorded | — | |
| S-12 cloud block | any actor when cloud returns | `cloud-backup` `cloud_available=true` | S-13; block + `no_override` cleared | unlimited | UI "Retry" asserts cloud recovery |
| S-14 prerequisites | owner | complete QC/backup | — | — | |
| Generic forward | any | `transition` (+1 only) | next stage, status `active` | — | refuses when `blocked_reason && block_type` both set (quarantine escapes this guard — bug) |
| Everything ↔ known state | demo operator | `POST /factory/dev/reset-state` (Current header button) | truncate + reseed all 8 tables | idempotent (verified in prior phases) | the only global recovery |

## 13. Actor and Authority Matrix

**Authority sources:** BRS §5 (3 tiers: Operator / Supervisor / Manager-&-QC; RBAC-1..4),
transcript (2 human app actors: Assembler + Floor Manager; FM=admin; viewers later),
`docs/factory-flow-model.md` (4 levels incl. **Technician** — not in BRS; CONFLICT C2),
`data/users.json` (6 users; `authority_tier` ∈ operator/supervisor/manager; capability flags),
WR enforcement (per-action, §10 cross-cutting), operator-settled canon (D9B §0: **QC authority is
distinct from Supervisor authority — do not collapse**; preserved throughout this recon).

| Actor | Needs to know (BRS/transcript) | May see (today) | May do (enforced today) | May NOT do (enforced) | Requires escalation | Separation of duty | Absent from identity model | UI implication today | Implication supported by truth? |
|---|---|---|---|---|---|---|---|---|---|
| **Assembler** (operator tier; `USER-OP-0001/0002`) | current unit, its stage, parts received?, my blocked/new units, what to do when device reports failure | everything (no auth): all units, all variants | scan parts (no auth check!), start/see anything typed with any actor id in Current | nothing is technically prevented for reads; realloc/disposition/QC blocked only by typed actor id | part replacement (→supervisor), calibration disposition (→supervisor/mgr) | cannot QC-sign what they built (enforced vs the recorded operator ids) | login/session; personal queue ("assigned to me" — fields exist, only set as scan side-effect, null after reset) | Variant Assembler views imply "my current unit / other units" | Partially — D9C-4 recon §8 resolution: manual focus, truthfully labeled "Other Units in Queue"; no personal claim made (✓ truthful), but no explanation that focus is manual |
| **Inventory operator** (role on `USER-OP-0002`) | deliver allocated serials (ALLOC-1); notified on realloc (transcript) | n/a (no surface) | — (no allocation endpoint exists) | — | — | — | any UI at all | none | n/a — correctly out of scope (BRS: inventory module separate) |
| **Floor Manager / Supervisor** (`USER-SUP-0001`, supervisor tier) | queue+stages, what needs attention, incoming orders, stock, staffing (transcript §1.4) | queue + triage (variants), everything (Current) | reallocate (`can_override`); disposition route-back & **quarantine** (`disposition_authority`) | **scrap** (403 — manager only); QC sign-off (403 — `can_qc_signoff=false`) | scrap → manager; SoD waiver → manager | — | orders/stock/staffing feeds (honest "not available" copy); multi-FM concept; admin (add/remove assemblers — transcript-lock, unbuilt) | Variant FM triage exposes **Route back / Quarantine / Scrap** buttons | **Partially untrue as presented**: all three buttons send `actor_user_id: 'USER-MGR-0001'` (manager), so the *Floor Manager screen* silently acts with *Manager* authority incl. scrap — works, but misrepresents tiering (AUTHORITY_CLARITY_GAP G-A1; decision §25-C5) |
| **Manager** (`USER-MGR-0001`, manager tier) | high-cost decisions | no dedicated surface | scrap; waive SoD; realloc; route/quarantine | **QC sign-off** (`can_qc_signoff=false` in seed — sign-off is NOT a manager permission here) | — | waiver is logged (qc_summary + event) | any manager-specific view | Ship form defaults to manager id | Seed models RBAC-2's "distinct named QC authority" *more strictly* than BRS's tier table reads (manager cannot sign) — consistent with operator canon; worth stating explicitly in D9E-1 |
| **QC authority** (`USER-QC-0001`, `qc_inspector`, tier=operator!) | physical + record checks (QC-1 ×8 in stages.json) | Current only (variants have no QC surface) | qc-signoff (sole holder of `can_qc_signoff`) | override/realloc/disposition (no flags) | waiver of SoD → manager | signer ≠ assembly op ≠ cal op (enforced) | QC-fail/rework action (T3) | none in variants | Distinct-QC canon honored in data+WR ✓; `authority_tier: operator` for the QC user is a naming oddity vs BRS "Manager/QC tier" — terminology for D9E-1 (§25-C2) |
| **Technician / calibration_tech** (`USER-TECH-0001`, roles assembler+calibration_tech) | hardware checks, calibration procedure | — | hardware-gate & calibration (both unenforced anyway) | — | — | his ids recorded → SoD comparisons | distinct Technician *tier* (flow-model) vs role-token (data) | Variant calibration submits as `USER-TECH-0001` | CONFLICT C2 (tier vs role) — presentation naming decision |
| **Leadership (Vijay) / Sales / Customer** | high-level real-time status (transcript §35–41) | nothing (no dashboards) | — | — | — | — | everything | Review shell exists *for* Vijay as reviewer, but nothing says so | Correct scope (deferred per D9B §10 / D9C-0 §4) |
| **Inventory module / eStore (systems)** | interface needs IF-INV/IF-ORD | represented as seed fixtures only | — | — | — | — | live interfaces | — | Correctly absent (BRS boundaries; transcript §52–58) |
| **Cloud (system)** | availability drives S-07/S-12 | `cloud_status` fields; CLOUD BLOCK badges | — | — | — | — | real connectivity (client-typed boolean, intentional mock) | "Cloud Available" checkbox (Current) | Mock is documented (D5 doc); *simulation semantics* unexplained on-screen |
| **Device software (actor per transcript)** | reports failure modes → cloud maps to instruction | not modeled | — | — | — | — | telemetry, failure-mode feed | "in progress" concept absent | Matches D9B §1.6 gap — future capability, not D9E |

**Authority-model cross-check (DERIVATION):** BRS 3-tier ↔ seed `authority_tier` 3 values ✓;
BRS RBAC-1 scrap=manager ↔ `disposition_authority` ✓; RBAC-2 distinct QC ↔ only QC user signs ✓
(operator canon preserved); RBAC-3/4 SoD+waiver ↔ WR qc_signoff ✓; flow-model's extra
"Technician" level and its "Supervisor: QC sign-off" line remain the two uncorrected doc drifts
(C1/C2 family, §25). Enforcement holes (scan/gate/calibration/backup/package/ship/transition accept
any actor string) are prototype-known (D9A §3.5 #7) — comprehension work must not imply enforcement
that isn't there.

---

## 14. Serialized-Traceability Analysis

FACT unless noted:

- Canonical chain intact end-to-end in data+code: part `serial_number` → `allocated_to_order_id`
  (S-04) → scan binds `bound_to_unit_id` + unit `part_allocations[type]` + `genealogy.parts_bound`
  (S-05, "marry") → reallocation preserves both serials + `reallocation_history` (who/when/why/old/new,
  ALLOC-3) → calibration certificate + full `attempt_history` (CAL-6 clean-cert/complete-history) →
  QC finalization (invariant 5) → backup manifest (stages.json `backed_up` list) → terminal immutability.
- Physical serials bind to orders and units ✓ (directive's preserved contract holds).
- D9D remediation holds in code: all three `*ActionForm.tsx` resolve the **real** `old_serial_number`
  via `findAffectedAllocation` (allocation-status ≠ bound → part_id → `vm.parts` serial) and require
  a non-empty replacement serial (byte-identical logic ×3, verified by normalized diff).
- Gaps/limits: "received-at-bench ≠ installed" still unmodeled (D9A §5 Q4; BRS conflates by design;
  transcript "parts received" relabeling remains a future data question — D9B §1.10); BRS UNIT-2's
  8 serial-worthy sub-assembly names (X-ray tube, Detector, DPP, SOM, MCB, Battery pack, BMS board,
  Chassis) vs seed/recipe generic types (DETECTOR_MODULE, POWER_SUPPLY, MAINBOARD, CHASSIS,
  SECONDARY_DETECTOR, WIFI_MODULE) — demo simplification, naming decision for D9E-1 (§26-T9);
  UNIT-0006/0007 have empty `part_allocations`/`parts_bound` yet passed QC — demo shortcut that
  contradicts QC-1 "genealogy complete" if narrated literally (DEMO_NARRATIVE_GAP G-D6);
  `genealogy_serial` (`SN-MOCK-*`) is never displayed in any variant (Current shows it as "Serial").
- UI: traceability appears only as raw rows (Current Part Allocations / CC Supporting Detail
  `TYPE · status`); the *story* ("this exact tube is married to this device forever; replacements
  never erase history") is never told anywhere.

---

## 15. Current Terminology Audit

Columns: term → where it appears (FACT) → intended meaning (source) → first-time-user
comprehensible? (INFERENCE, reviewer-audience) → defined in repo? → actor-appropriate wording? →
disposition recommendation (**PROPOSAL — wording NOT finalized here**, per directive).
Placement key: AV=always visible, EXP=expandable "About", TIP=tooltip/inline definition.

| Term | Appears | Intended meaning | 1st-time clear? | Defined in repo? | Actor-appropriate? | Proposed disposition |
|---|---|---|---|---|---|---|
| Current | shell tab | the pre-variant engineering console baseline | No — reads as "current state" | D9C-1 spec | reviewer-only term | keep for review shell; EXP explains "engineering console baseline" |
| Variant / Variant A/B/C | shell tabs | comparison options | Partially | specs | reviewer-facing | keep; EXP per variant philosophy (D9E-3) |
| Attention-First / Workflow-First / Command-Center | tab suffixes | interaction philosophies (D9B §5–7) | No (names alone carry no meaning) | D9B | reviewer | EXP with one-line philosophy + "what to notice" |
| Assembler / Floor Manager | secondary tabs | the two human actors (transcript) | Yes | D9B/BRS | yes | keep; AV actor chip |
| Current Unit | A/B/C assembler | manually-focused unit | Misleads toward "assigned to me" | D9C-4 recon §8 | needs qualifier | AV + TIP ("focused unit — tap another to switch") |
| Other Units in Queue / Other Units | A,B / C strips | all other non-terminal units | Partially ("whose queue?") | code | ok | TIP |
| Queue | FM views | all non-terminal units by stage | Yes | — | yes | keep |
| Triage | FM sections | blocked-unit resolution list | Jargon for factory floor | D9B | borderline | AV title + TIP ("units needing a decision") |
| Attention / N need attention / needs resolution | FM counters/banners | `blocked_reason != null` count | Yes (count), No (criteria) | D9C-4 §9 rule | yes | TIP stating the criterion |
| BLOCKED | badges everywhere | unit has persisted blocked_reason | Yes-ish, but covers 5+ distinct conditions | glossary (hard-stop) | too coarse | split per §28 semantic states |
| NO OVERRIDE | badges | `no_override=true` — no bypass exists (BRS GP-3) | Alarming but unexplained (why? who decided?) | glossary + stages.json decision notes | needs one-liner | AV short line + EXP (management-decision note verbatim from stages.json) |
| Hard block / hard-stop | docs, walkthrough | blocking condition needing authorized resolution | Not shown as term in variants | glossary | ok | TIP |
| GATE | spine badge (Current) | pass/fail checkpoint w/ rework routing | No | glossary/BRS | engineering vocab | TIP; variants should say "quality gate" family in D9E-2 |
| CLOUD BLOCK | spine/cloud form badge | stage depends on cloud availability | Partially | stages.json | ok | TIP + link to decision note |
| EXTERNAL / SEPARABLE | spine badges | outside factory scope / future fulfillment split | No (SEPARABLE meaningless to floor) | BRS | engineering-only | keep in Current; hide or TIP elsewhere |
| TERMINAL / SHIPPED | badges | immutable end state | Partially | glossary | ok | TIP ("record is now permanent") |
| Rework | disposition label "Route back to hardware" | return to earlier stage for corrective action | Yes | glossary | yes | keep + consequence line ("calibration counter resets") |
| Retry / Retry Cloud Backup | buttons | resubmit attempt | Button clear; *simulation* semantics not | — | yes | TIP ("simulates cloud restored" in demo) |
| Resolve / Hide | TriageRow toggle | reveal/hide action form | "Resolve" overpromises (it reveals a form) | — | borderline | rename candidate (D9E-2), TIP now |
| Disposition | form/labels | mandatory supervisor decision after gate failure | No | glossary | supervisor term — ok w/ TIP | TIP |
| Quarantine | button | hold outside flow pending review | Partially (no exit shown) | glossary (absent! — not defined) | ok | TIP + define in glossary (D9E-1) |
| Scrap | button | manager-tier write-off, terminal | Yes; cost/authority not | BRS RBAC-1 | needs authority hint | AV "manager decision" chip |
| Serialized allocation / allocated_bound / allocated_unbound / released | Current rows, CC detail | reservation vs married vs released states | **No** — raw enum | glossary(partial) | no | plain-language mapping (D9E-2), TIP |
| Genealogy / genealogy_serial | Detail "Serial" | permanent device identity + build history | No | glossary (Production Record) | needs plain term | TIP ("device's permanent build record") |
| Supporting Detail | CC assembler | collapsed part/calibration facts | Yes | D9B §7 | yes | keep |
| Secondary Info / Secondary Context | B tab / C region | orders/stock/staffing slot (honest 'not available') | Yes | D9B | yes | keep + one-line why-empty |
| S-05 / STAGE-05 | queues, detail | stage number shorthand | Number yes, meaning no | stages.json names | needs name | AV "S-05 · Assembly" pairing |
| `cloud_unreachable_sw_update_cannot_proceed` etc. (reformatted) | attention rows | backend reason codes, `_`→space sentence-case | **No** — machine text | stages.json/BRS explain them | no | replace via reason→explanation map (D9E-2/4); keep raw code in EXP for traceability |
| `calibration_cap_exceeded_awaiting_disposition` & other `current_status` values | Current Detail/UnitList | status enum | No | — | no | plain-language map (D9E-2) |
| Backend-guarded action · POST /factory/… | every Current form | endpoint transparency (D8 review goal) | Engineering-only | D8 doc | Current-only ✓ (variants correctly omit) | keep in Current; never in actor views (already true) |
| Dev — Backend-Guarded Transition | Current form | +1 stage dev tool | No | D8 doc | Current-only ✓ | keep, label as dev tool more strongly (D9E-2 optional) |
| Postgres-backed / D8 Review Prototype / Data Contract: N stages · N units | Current header | infra badges | No (client-irrelevant) | — | engineering | EXP or demote in D9E-5 (Current preserved — decision needed on whether Current header is in-scope, §25-C6) |
| "Needs floor manager approval — visible in the Floor Manager triage list." | A/B/C assembler non-S-12 blocks | hand-off hint | Reads clear but is **false for S-07/S-09-unmapped cases** (FM has no action either) | — | no | replace with truthful per-reason ownership line (D9E-2/4) — G-D1 |
| "No resolution action is available in this comparison view." | FM triage unsupported | truthful absence | Yes, but no *why* | D9C remediation | ok | add reason ("waiting for cloud — no floor action exists") |
| "Order, stock, and staffing information is not available in this view." | B/C secondary | honest data gap | Yes | D9C-5 §8 | yes | add one-line why (outside approved data surface) |
| Loading… / Error: HTTP N | all | fetch states | Yes | — | ok | Empty-vs-loading disambiguation (§22) |
| Reset Demo State | Current header | truncate+reseed | Yes for reviewers | walkthrough | reviewer tool | TIP ("returns the 7 seeded scenarios") |

---

## 16. Current Design-System Inventory

FACT (from `styles.css` full read + component usage):

- **Tokens:** MD3 set `--mds-{surface,surface-low,surface-container,surface-high,on-surface,
  on-surface-variant,outline,outline-variant,primary,on-primary,primary-container,
  on-primary-container,error,on-error,error-container,on-error-container}` ×
  `[data-theme=light|dark]`; factory set `--factory-{gate,cloud,success,supervisor}` (+on/container
  variants). No spacing/typography/elevation/breakpoint tokens — those come from Tailwind utilities
  inline (text-xs…text-2xl; p-3/4/5; rounded/rounded-xl; one shadow on `.mdc-card`).
- **Helper classes:** `surf*/t-on-*/b-*` per color family; `.mdc-card/.mdc-card-container/.mdc-input/
  .mdc-select/.mdc-divider`; `.touch-target-primary` 48px / `.touch-target-secondary` 44px;
  `.variant-review-tab-bar(-primary/-secondary)`; hover helpers. Focus: 2px primary outline on
  inputs/selects only; buttons rely on browser default focus (kept per D8C).
- **Breakpoints:** Tailwind `lg`(1024)/`xl`(1600 arbitrary `min-[1600px]`) drive Current's
  compact pane switcher; variants are single-column flows (no breakpoint logic of their own).
- **Component inventory in use:** buttons (3 tone families: primary-container tabs/submits;
  Current's raw `bg-blue/red/purple-600` SubmitBtn variants — note these bypass tokens),
  tab bars ×2 levels, unit cards/rows, badges (SHIPPED/BLOCKED/NO OVERRIDE/GATE/CLOUD BLOCK/
  EXTERNAL/SEPARABLE/TERMINAL/severity), banner/section blocks (`surf-error` family), disclosure
  (`<details>`: Current sections **default open**; CC Supporting Detail **default closed** — the
  only true progressive disclosure), forms (inputs/selects), queue rows, response box
  (ResponseDisplay incl. raw field grid), event table/cards, counters ("N need attention").
- **Absent primitives:** tooltip (none anywhere), info/"?" affordance (transcript asked for an
  i-button — none exists), "About this view" panel, toast/notification, modal, skeleton loaders,
  stepper/progress affordance for actors (StageSpine is Current-only), empty-state component,
  severity-tiered alert set.

**Semantic-state coverage vs distinct operational meanings (the flattening evidence):**

| Operational meaning | Current visual treatment | FACT basis |
|---|---|---|
| informational | plain surf rows | — |
| active work (current stage) | primary/blue row+dot (Current spine only); variants: nothing marks "active" | StageSpine |
| waiting on external (cloud) | **same `surf-error` red as everything else** in variants; Current adds CLOUD BLOCK badge | AssemblerView etc. |
| warning / attempt-failed margin | not surfaced (only Detail "Attempts 2/3" text) | UnitDetailPanel |
| recoverable block (cap-exceeded, gate-fail) | same red | 〃 |
| hard block, no override | same red + NO OVERRIDE text | 〃 |
| approval required (disposition/SoD) | same red | 〃 |
| rework | same red until action; then gone | 〃 |
| retry available | same red + a button | 〃 |
| completed stage | muted `surf-low` (Current spine only) | StageSpine |
| shipped | green SHIPPED (UnitList/spine); filtered out of variants | UnitList |
| quarantined | **same red BLOCKED** — no distinct treatment; UnitList badge set has only SHIPPED/BLOCKED | UnitList/FM rows |
| scrapped | terminal → no badge at all in UnitList (neither SHIPPED nor BLOCKED shows for scrapped: `isBlocked && !isTerminal` hides BLOCKED; SHIPPED badge keys on `terminal` — **scrapped shows "SHIPPED"-badge? No: badge text is SHIPPED but keys on `isTerminal`** → a scrapped unit would display a green "SHIPPED" badge — mislabeled terminal, D-6 defect) | UnitList:44–47 |
| unavailable data | plain gray sentence (B/C secondary) ✓ distinct | FM views |
| unsupported action | plain sentence inside red row | TriageRow |
| system error (fetch) | small text `Error: …` | roots |

**Red currently encodes at least 7 distinct concepts** (waiting-on-external, recoverable block,
approval-required, rework, retry-available, quarantined, plus error-severity events and destructive
Scrap button) — the exact over-loading the directive asked to examine (DERIVATION over the table).
Also: event severity styling handles `error/warning/info` but **not `critical`** — the four seeded
critical events render in the *muted default* color, i.e. the highest severity gets the least
emphasis (`EventTrace.severityStyle`, FACT — new finding, §24-D5). The purple supervisor family is
used only in Current's realloc form; variants express authority through nothing at all.

## 17. Screen-by-Screen Comprehension Audit

Method: each screen/state scored against the 14 proposed questions (§27), Q1…Q14. ✓ answered,
◐ partial, ✗ unanswered. Data provenance per displayed datum is FACT from component code
(§8 sources); "purpose" is FACT from D9B/spec; comprehension judgments are INFERENCE
(first-time client reviewer standard). Q-key: 1 where am I · 2 which actor · 3 screen for ·
4 what am I seeing · 5 what needs attention · 6 why · 7 consequence · 8 owner · 9 can do ·
10 cannot do · 11 what happens after · 12 unavailable/TBD · 13 why this variant shape ·
14 what to compare.

### 17.1 Review Shell (`/#/variants`)

| Aspect | Finding |
|---|---|
| Actor/purpose | Client reviewer (Vijay) comparison shell (D9B §1.12) |
| Displays | 4 primary tab buttons; selected pane. Data: none of its own |
| Q-scores | Q1 ◐ (tabs imply location; page title still says "D8 Review Prototype") · Q2 ✓ within variants · Q3 ✗ (nothing says "compare three approaches and pick") · Q13 ✗ · Q14 ✗ · others delegated |
| Missing explanation | Variant philosophies, comparison guidance, what stays identical (shared truth), demo-reset guidance from inside variants, the hash-reload caveat |
| Hierarchy/touch | Tab bar wraps; 48px targets ✓; selection state lost on reload (in-memory) |
| Truthfulness | ✓ (labels accurate) |
| Self-explanation verdict | **Fails as a comparison instrument without a narrator** — the exact D9E-3 target |

### 17.2 Current (engineering console) — inside shell and at `/`

| State | Displayed data (provenance) | Q-scores (headline) | Key missing explanation / notes |
|---|---|---|---|
| Unselected | header health/contract (live), Unit Queue w/ 7 units + `SCENARIO_LABELS` (hardcoded map keyed to seed ids), 14-row StageSpine (stages.json names/flags + hardcoded CLOUD/GATE sets), empty Detail/Action prompts, EventTrace 10-of-22 | Q1◐ Q3✗ Q4◐ Q5◐ (BLOCKED badges) Q9✗ | Console's own purpose unstated; scenario labels are demo-only copy (HARDCODED_DEMO_COPY) and silently vanish for any new unit |
| Unit selected (normal, e.g. UNIT-0001) | Identity rows (unit), Stage/Status raw enums, Part Allocations rows, Calibration x/3, QC rows, Cloud/Ship rows — all backend truth; ActionPanel stage forms w/ endpoint paths + free-text actor ids + Dev transition | Q4✓(raw) Q6✗ Q7✗ Q8✗ Q9✓(forms) Q10◐(only via submit-and-see) Q11◐ (response box shows next stage after the fact) | The record dump answers "what", never "so what"; forced-open `<details>`; ActionPanel state not keyed by unit (stale-field risk, D9A) |
| Blocked selected (0002/0004/0006) | red Block/Hard-Stop section: raw `blocked_reason`, NO OVERRIDE line, `block_type` | Q5✓ Q6◐(code only) Q7✗ Q8✗ | cause chain/consequence/ownership absent; stage-7 shows "No actions available at this stage" without why |
| Terminal (0007) | TERMINAL banner; SHIPPED badges | Q10✓ | why-immutable (legal record) unstated |
| Action responses | ResponseDisplay: status chip + message + raw field grid | Q11◐ | machine fields exposed (by design for D8 review) |
| Loading / error / compact / themes | header dots + "…"; `Error: HTTP…`; pane switcher; light/dark | — | loading vs empty ambiguity minimal here (header states it) |
| Verdict | **Preserved engineering baseline** (must stay per directive); it is the comparison anchor, not a comprehension target — but D9E-5 "cross-screen application" scope question §25-C6 |

### 17.3 Attention-First — Assembler

| State | Data shown (source) | Q1 | Q2 | Q3 | Q4 | Q5 | Q6 | Q7 | Q8 | Q9 | Q10 | Q11 | Q12 | Q13 | Q14 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Calm | "Current Unit" + id + stage **name** (stages.json) + action form (stage-mapped) + "Other Units in Queue" strip w/ BLOCKED chips | ◐ | ✓(tab) | ✗ | ◐ | ✓(chips) | ✗ | ✗ | ✗ | ◐ (only for stages 10; stage-5 calm→no scan!) | ✗ | ✗ | ✗ | ✗ | ✗ |
| Interrupt (S-12 focused, 0006) | full-bleed error card "Interrupt — UNIT-0006", reformatted reason, Retry button | ◐ | ✓ | ✗ | ◐ | ✓ | ◐ (code words) | ✗ | ◐ (implicitly "you") | ✓ | ✗ | ✗ (what retry does/asserts unstated) | ✗ | ✗ | ✗ |
| Interrupt (non-S-12, e.g. 0002/0004 focused) | same card + **"Needs floor manager approval — visible in the Floor Manager triage list."** | ◐ | ✓ | ✗ | ◐ | ✓ | ◐ | ✗ | **✗/false for S-07** (no FM approval exists) | ✓(none) | ◐ | ✗ | ✗ | ✗ | ✗ |
| Notes | Takeover = intended philosophy (D9B §5) ✓ implemented; NO OVERRIDE shown when true; unsupported-attention truthful except the ownership sentence (G-D1) |

### 17.4 Attention-First — Floor Manager

| State | Data | Headline scores | Notes |
|---|---|---|---|
| Counter + Triage + Queue | "N need attention" (derived count), TriageRow per blocked unit (id, NO OVERRIDE, reformatted reason, Resolve/Hide or truthful no-action line), Queue rows `id · S-NN · BLOCKED?` | Q2✓ Q5✓ Q6◐ Q7✗ Q8◐ (row implies FM owns) Q9✓ (forms incl. **Scrap as USER-MGR-0001** — G-A1) Q10✗ Q11✗ Q13✗ Q14✗ | Triage always-rendered = variant signature ✓; queue rows lack stage names (S-NN only) and status words; disposition consequences (reset counter / dead-end quarantine / terminal scrap) unstated |

### 17.5 Workflow-First — Assembler (single persistent card)

Calm: same fields as 17.3-calm inside one stable card + always-visible action (post-D9D) — same
Q-profile as 17.3-calm. Blocked-inline: "Attention" section inside the card (reason, NO OVERRIDE,
S-12 action or the same misleading FM-approval line) — same Q-profile as 17.3-interrupt, without
takeover (Q-philosophy difference only). Focus changes only by strip tap ✓ (D9B §6 honored).

### 17.6 Workflow-First — Floor Manager

Queue|Secondary Info pane tabs; collapsed triage button "N need attention — tap to view/collapse";
expanded triage identical rows to 17.4; queue identical. Secondary Info pane: honest not-available
sentence (✓ Q12 — the only screen that answers it). Q13/Q14 ✗. Collapse-by-default = signature ✓.

### 17.7 Command-Center — Assembler (simultaneous regions)

Attention banner (only when blocked) above always-rendered Current Unit (+calm action post-D9D),
Other Units, `<details>` Supporting Detail (allocation `TYPE · status` rows; **default closed** —
the app's only real progressive disclosure). Same Q-profile as 17.3 rows plus: Q4 ◐+ (detail on
demand); "No other units in the queue." empty-strip copy exists here only. Blocked+calm coexist:
banner + card simultaneously (signature ✓); banner uses same misleading FM-approval line for
non-S-12 (G-D1).

### 17.8 Command-Center — Floor Manager

"Attention — N needs resolution" block (direct-rendered when non-empty) + Queue + always-visible
muted Secondary Context (honest not-available). Same Q-profile as 17.4 + Q12 ✓. No toggle —
signature ✓ (verified against 015/016 assertions and code).

### 17.9 Cross-cutting screen facts

- Stage **names** appear in Assembler cards (all variants) but FM queues show only `S-NN`
  (FACT: FM rows render number only) — asymmetric stage literacy.
- No screen shows: order context (customer/model/qty), station, operator identity, attempts-left
  phrasing, next-stage preview ("after this: S-13 Package"), or any stages.json requirement/
  decision-note text.
- Variant Assembler default focus = first non-terminal unit = **UNIT-0001 (S-05)**, whose calm
  state maps to **no action** (scan unmapped) — the very first thing a reviewer sees in every
  variant is an action-less card (DEMO_NARRATIVE_GAP G-D2).
- The three variants' identical action forms mean Q9/Q10/Q11 answers are *structurally identical*
  across variants — comparison differences are exclusively layout/interruption semantics (matches
  D9D intent; useful for §30 narrative framing).

---

## 18. Explanation-Hierarchy Analysis

Classification of required explanatory content (directive's three buckets), evaluated per §17
evidence. **PROPOSAL status — placement not locked.**

**Always Visible (essential to operate/understand):** screen purpose (1 line), actor chip, unit
identity + stage number+name pair, semantic state (per §28 vocabulary, not bare BLOCKED),
plain-language reason headline, operational consequence (1 line: e.g. "cannot ship until backed
up"), ownership ("waiting on: cloud / supervisor / you"), the one permitted action + its outcome
("Retry marks cloud available → unit moves to Package"), prohibited-action statement where the
truth is "nothing can be done here" (already partially present), attempts-remaining at S-10.
Evidence gaps today: all of these except identity/stage/action are absent (§17).

**Expandable "About This View" (comparison philosophy):** why this variant is organized this way
(D9B §5/6/7 one-paragraph philosophies), what intentionally differs vs the other two (D9D §10
intentional-difference inventory is ready-made content), what is shared (one view model, same
backend truth, same actions), what to notice as a reviewer (§30), demo caveats (mocked cloud,
fixed demo actors, reset semantics). None exists today (FACT). Also the right home for
management-decision notes (stages.json `decision_note`) and raw reason codes/event ids.

**Tooltip / inline definition (short, term-level):** gate, no override, serialized allocation
states, disposition, rework, quarantine, triage, terminal/immutable, S-NN pattern, "Current Unit"
focus semantics. **Constraint honored:** essential meaning must not live only in hover — target
hardware is 11–21″ touchscreens (transcript §1.8; D8C substrate), so tooltips must be
tap-activated and everything Always-Visible-classified above stays out of tooltips. Today: zero
tooltip primitive exists (§16), so nothing can be mis-assigned yet — greenfield for D9E-4.

---

## 19. Demo-Unit and Scenario Map

FACT (seed files + WR + variant code); stability = state after `reset-state`.

| Unit | Stage/state (seed) | Intended scenario (UnitList label) | Actor relevance | Supported action today (where) | Unsupported/absent | Expected transition | Stable after reset | Understandable w/o narration | Demonstrates variant difference |
|---|---|---|---|---|---|---|---|---|---|
| UNIT-0001 | S-05 `assembly_active`, DETECTOR bound, POWER_SUPPLY allocated-unbound | Assembly in progress | Assembler | **Scan + realloc in Current only** | variants: none (G-D2) | scan PS → bound; then generic transition | ✓ | ◐ (raw rows) | ✗ (calm card looks same in A/B; C adds detail region) |
| UNIT-0002 | S-07 cloud-blocked, no_override | Cloud SW/FW blocked | Assembler(focused)/FM | none anywhere (truthful) | any resolution (permanent) | none (reset only) | ✓ | ✗ (misleading FM-approval copy) | ✓ (takeover vs inline vs banner) |
| UNIT-0003 | S-10 attempts 2/3, last fail | Calibration retry active | Cal tech/Assembler | Submit calibration (all variants post-D9D + Current) | ref-std hard stop (variants auto-pick valid) | pass→S-11 / fail→cap (becomes 0004-like) | ✓ | ◐ (margin not phrased) | ✓ (calm-state action visibility now equal — D9D talking point) |
| UNIT-0004 | S-10 cap exceeded, disposition required | Calibration cap exceeded | FM/Supervisor(+Mgr for scrap) | 3 dispositions (variant triage/interrupt + Current) | — | route-back→S-09(reset 0/3) / quarantine(dead-end) / scrap(terminal) | ✓ | ◐ (options' consequences unstated) | ✓ (where the decision surfaces) |
| UNIT-0005 | S-11 ready_for_qc, cert CERT-MOCK-0005 | QC ready | QC authority | **QC sign-off in Current only** | variants: none (G-D3) | →S-12 `qc_complete_backup_pending` | ✓ | ◐ | ✗ in variants |
| UNIT-0006 | S-12 backup-blocked, no_override, QC signed | Cloud backup blocked | Assembler/FM/operator | Retry Cloud Backup (all variants + Current) | — | →S-13 Package | ✓ | ◐ (retry semantics) | ✓ (the flagship cross-variant action demo — journal-verified live) |
| UNIT-0007 | S-14 shipped terminal | Shipped — terminal | reviewer | none (409 demo via Current Dev form) | — | — | ✓ | ✓-ish | ◐ (visible only in Current; filtered from variants — itself a talking point) |

**Flowchart-scenario coverage from the actor-first variants (DERIVATION):**
normal assembly ✗ (Current-only) · serialized mismatch/reallocation ✗ live-truthful (stage-5
persisted block unproducible; realloc form reachable only through that state; the D9C remediation
verified this branch by synthetic fixtures, not click-path) · cloud update block ✓ (static; no
recovery) · hardware rework ◐ (only by first driving UNIT-0004 route-back in a variant, then
failing the gate **in Current** — gate form absent in variants) · calibration retry ✓ ·
calibration-cap disposition ✓ · QC ready/sign-off ✗ (Current-only) · QC rework ✗ (capability
absent) · cloud-backup block ✓ · shipped terminal ◐ (Current only).
**Net: 3 of the 9 operator-named scenario families are fully demonstrable inside the variants
(calibration retry, cap disposition, backup block/retry), 2 partially, 4 not at all.** This is the
demo-narrative ceiling D9E-3 must either script around (hand off to Current at the right moments)
or the operator must re-scope (§25-C7 asks which).

Missing comparison narrative (directive item): what each variant prioritizes, what stays identical,
what the client should notice, and which unit best shows each difference — none of this exists in
any repo artifact today beyond D9B's design prose (which is not client-facing). §30 proposes the
structure.

---

## 20. Cross-Variant Explanatory Comparison

FACT rows (code/D9D-verified); "should notice" = PROPOSAL feeding D9E-3.

| Dimension | Current | Attention-First | Workflow-First | Command-Center | Client should notice |
|---|---|---|---|---|---|
| Philosophy (D9B) | engineering console | interrupt-driven takeover | one-job-at-a-time, actor-paced | everything visible, re-prioritized | three answers to "how should a blocked unit interrupt you?" |
| Assembler blocked | red section among many | **replaces** the calm card | inline section, same card | banner above intact regions | interruption cost vs guarantee-of-noticing |
| FM attention | badges in flat list | triage always rendered | collapsed count, tap to expand | direct-rendered block | forced vs opt-in vs ambient triage |
| Secondary info | n/a | absent | separate tab (honest empty) | always-visible muted region (honest empty) | where non-urgent info lives |
| Detail depth | full record dump | none | none | collapsed Supporting Detail | how much truth an actor needs |
| Identical across A/B/C | — | shared view model; same 8 GETs; same attention rule (`blocked_reason && !terminal`); same focus rule; same stage-sorted queue; byte-equivalent action forms, payloads, fixed demo actors, refresh split, error handling (D9D 21× parity) | | | differences are *presentation philosophy only* — by design |
| Self-description | none | none | none | none | (the D9E gap itself) |

---

## 21. Data-Availability Map

Classification per directive vocabulary. FACT per cited surface.

| Desired explanation datum | Class | Evidence / where |
|---|---|---|
| Actor identity (who am I) | NOT_AVAILABLE | no auth/session anywhere (D9A §3.5#7; unchanged) |
| Actor assignment ("my units") | CONFLICTING/NOT_AVAILABLE | `assigned_operator_id` exists but only set as scan side-effect; null on reset; unusable for "me" (D9C-4 §8) |
| Unit assignment to station | AVAILABLE_DIRECTLY (seed) | `station_id` (BENCH-A1 …) — rendered only in Current Identity |
| Failure→instruction mapping | NOT_AVAILABLE (as data); AVAILABLE_ONLY_IN_DOCUMENTATION (as content) | no code→instruction table in backend (D9C-4 §6 grep, re-confirmed); the *content* to author one exists in stages.json controls + BRS rationale — the D9E-2 opportunity |
| Stage description/name | AVAILABLE_DIRECTLY | `GET /factory/stages` names (used); `requirements`, `authority_notes`, `hard_stop_controls`, `decision_note`, calibration/QC metadata (served, unrendered) — **the highest-value untapped surface** |
| Failure cause (which condition) | AVAILABLE_DIRECTLY | `blocked_reason`/`block_type`/`no_override` + event payloads |
| Operational consequence | AVAILABLE_ONLY_IN_DOCUMENTATION / AVAILABLE_DERIVED | BRS/stages.json notes; some derivable (cap ⇒ no more attempts: `attempts/max_attempts`) |
| Action authority | AVAILABLE_ONLY_IN_BACKEND (partially lossy) | users endpoint serves full JSON (flags incl. `can_perform_stages`); WR reads DB copy that **drops** `authority_tier`/`can_perform_stages`/2nd roles (seed.py/state_store) — display may use JSON; enforcement truth is the DB subset |
| Next transition (what happens after) | AVAILABLE_DERIVED / AVAILABLE_ONLY_IN_BACKEND | `normal_next_stage_id` served per stage (unused); WR hardcodes actual advances — for supported actions the outcome is deterministic and derivable |
| Order info (model/qty/status/rejection) | AVAILABLE_ONLY_IN_BACKEND | `GET /factory/orders` exists, outside view model (protected surface per D9C-5 §8) — wiring it is a D9E-5-scale decision (§25-C8) |
| Serialized inventory / part detail | AVAILABLE_DIRECTLY | `vm.parts` (already loaded; barely rendered) |
| Part allocation states | AVAILABLE_DIRECTLY | `part_allocations` |
| Stock availability | NOT_AVAILABLE | no endpoint (re-grepped in D9C-5 §12) |
| Staffing / roster / leave | NOT_AVAILABLE | none (transcript defers to external systems) |
| Station load | NOT_AVAILABLE (beyond per-unit station_id) | — |
| Model/recipe (checks, cal profile, firmware) | AVAILABLE_ONLY_IN_BACKEND | `GET /factory/model-recipes` — zero consumers (D9A §3.1, unchanged) |
| Calibration attempts/history | AVAILABLE_DIRECTLY | `calibration_summary` incl. `attempt_history` w/ per-attempt `failure_reason` (seed) — history rendered nowhere |
| Reference-standard validity | AVAILABLE_DIRECTLY | `vm.refStandards` (status/expiry/cert) — only used to pick defaults |
| QC sign-off / waiver | AVAILABLE_DIRECTLY | `qc_summary` |
| Cloud status | AVAILABLE_DIRECTLY (mock) | `cloud_status` flags |
| Audit/event history per unit | AVAILABLE_DIRECTLY | `vm.events` + `unit.event_ids` — rendered only in Current's EventTrace |
| Certificate/document status | AVAILABLE_DIRECTLY (id only) | `certificate_id`; ship `document_refs` accepted but never displayed |
| Shipping status | AVAILABLE_DIRECTLY | `package_ship_status` |
| Live "in progress" activity | NOT_AVAILABLE | no telemetry (D9B §1.6; D9C-4 §7) |
| Attention severity tiers | NOT_AVAILABLE (by decision) | transcript §1.9: single "immediate" tier for now |

No missing datum authorizes backend/data expansion in D9E (directive lock honored; items marked
ONLY_IN_BACKEND are *frontend wiring* questions for the operator, §25-C8).

---

## 22. Loading / Empty / Error / Unavailable-State Audit

| Surface | Loading | Empty | Error | Unavailable data | Pending/in-flight | Success feedback |
|---|---|---|---|---|---|---|
| Current | header "…" dots; regions render empty lists | "No units loaded" (UnitList), "Select a unit…", "No events" | header `Error: HTTP…` (small text); ActionPanel error box | n/a | buttons "Submitting…" + disabled | ResponseDisplay SUCCESS box; post-action refresh |
| Variants (all three roots) | "Loading…" center text — **triggered by `units.length===0 && !loadError`, so a truly empty factory reads as eternal loading** (G-D8) | FM queue silently renders zero rows (no copy); CC "No other units in the queue." is the only empty-copy | `Error: {loadError}` line above panes | honest sentences (B tab / C region) ✓ | SubmitButton "Submitting…" | **none** — forms call `onDone` and the row/card simply changes or vanishes; no confirmation copy at all (G-D4) |
| EventTrace | — | "No events" | — | — | — | new rows appear (Current only) |

Also: `refreshSelected` swallows errors silently (`catch { /* silent */ }` in the hook) — a failed
post-action refresh leaves stale UI with no signal (IMPLEMENTATION_DEFECT candidate D-8, FACT from
`useFactoryViewModel.ts:83`).

---

## 23. Accessibility and Touchscreen Implications

FACT (code) + DERIVATION vs the 11–21″ touch mandate (transcript §1.8; D8C contract):

- Touch targets: 48/44px utilities applied on all tab bars, unit strips, submit buttons, TriageRow
  toggles, `<summary>` in Current — ✓ carried into variants. CC's `<details>` Supporting Detail
  summary has **no touch-target class** (`AssemblerCommandView.tsx:107`) — minor target-size gap.
- Hover: no hover-gated content anywhere (✓ policy held since D8C); future tooltip work must be
  tap-first (§18 constraint).
- Semantics: native `<button>`/`<details>` throughout variants ✓; Current pane switcher has
  `role="tablist"/tab/aria-selected` — **variant tab bars have no tablist/aria-selected semantics**
  (plain buttons; selection conveyed by color only) → screen-reader cannot tell active variant/actor
  (ACCESSIBILITY_GAP G-X1).
- Color-only state: BLOCKED chips and selected-tab state rely on color+text; status dots in spine
  are color-only (Current, pre-existing). Contrast: MD3 container pairs are token-designed; D8A/D8B
  passes verified readability for Current; variant surfaces reuse the same pairs (INFERENCE: same
  contrast class; not re-measured — no browser run in this recon).
- Focus: inputs/selects have visible focus ring; buttons rely on default outlines (kept per D8C);
  tab order follows DOM (single-column variants ⇒ sane).
- Screen-reader phrasing: reformatted snake_case reads as flat sentences ("Cloud unreachable sw
  update cannot proceed") — poor but pronounceable; `S-05` reads "S dash zero five" with no name in
  FM queues (ties to §17.9).
- Live-region/announcement: none — attention count changes and post-action state changes are not
  announced (ACCESSIBILITY_GAP G-X2, pairs with G-D4).

## 24. Gap Register (classified)

Each gap: exactly one class (directive taxonomy) · screen(s) · actor · severity (for the
comprehension goal) · user consequence · evidence · resolvable in later D9E without new capability?
· operator input needed? · proposed node · protected surfaces involved.

### Comprehension / content gaps

| ID | Class | Gap | Screens | Actor | Sev | Consequence | Evidence | D9E-resolvable? | Operator input | Node | Protected surfaces |
|---|---|---|---|---|---|---|---|---|---|---|---|
| G-C1 | COMPREHENSION_GAP | No screen states its own purpose, the cause chain, the operational consequence, or the expected next state | all | all | **High** | reviewer needs narration for every screen (the D9E-0 premise) | §17 matrix | ✓ (content layer) | contract lock (§27) | D9E-2/4/5 | none (frontend additive) |
| G-C2 | COMPREHENSION_GAP | stages.json explanatory payload (requirements, controls, decision notes, rework targets, metadata) served but unrendered | all | all | High | the best in-app truth stays invisible | §10, §21 | ✓ | none | D9E-4/5 | view model untouched (stages already loaded) |
| G-C3 | COMPREHENSION_GAP | Attempts-remaining / margin (“1 attempt left before supervisor disposition”) never phrased | S-10 screens | assembler/cal-tech/FM | Med | cap event surprises reviewer | §17, `calibration_summary` | ✓ (derived) | none | D9E-4 | — |
| G-C4 | COMPREHENSION_GAP | Post-action outcome unstated before/after submit (what Retry asserts; where unit goes) | all action forms | all | High | actions feel magical; G-D4 pairs | §11 “Available action” vs UI | ✓ (deterministic per WR) | none | D9E-2/4 | — |
| G-T1 | TERMINOLOGY_GAP | Reformatted snake_case + raw status enums as primary copy | variants + Current | all | High | machine language ≠ manufacturing language | §15 | ✓ | vocabulary lock | D9E-2 | — |
| G-T2 | TERMINOLOGY_GAP | FM queues show `S-NN` with no stage name | A/B/C FM | FM | Med | stage literacy asymmetry | §17.9 | ✓ | none | D9E-4/5 | — |
| G-IA1 | INFORMATION_ARCHITECTURE_GAP | No “About this view” layer; philosophies/shared-truth/compare-guidance absent | shell + variants | reviewer | **High** | comparison purpose invisible (Q13/Q14 ✗ everywhere) | §17.1, §18 | ✓ | D9E-3 content approval | D9E-3/4 | shell edit (allowed surface TBD by directive of that node) |
| G-IA2 | INFORMATION_ARCHITECTURE_GAP | No tooltip/info primitive at all (transcript asked for “?”/i-button) | all | all | Med | no home for term definitions | §16 | ✓ | none | D9E-4 | — |
| G-IA3 | INFORMATION_ARCHITECTURE_GAP | Orders/model/recipe context absent from every screen (endpoints exist, unconsumed) | all | FM/reviewer | Med | “what is being built for whom” unanswerable | §21 | ◐ — needs view-model/API-client touch | **yes** (§25-C8) | D9E-5 (if authorized) | `useFactoryViewModel.ts`/`factoryApi.ts` (currently protected) |
| G-V1 | VISUAL_SEMANTICS_GAP | Single red treatment for ≥7 distinct conditions; no waiting/rework/approval/quarantine distinctions | all | all | **High** | severity/ownership unreadable at a glance | §16 table | ✓ (token/system work) | semantic-state lock (§28) | D9E-2 (system) + D9E-4 (primitives) | styles.css additive |
| G-V2 | VISUAL_SEMANTICS_GAP | `critical` event severity renders in muted default color (less emphasis than warning) | Current EventTrace | reviewer | Low-Med | flagship seed events under-signaled | `EventTrace.severityStyle` | ✓ | none | D9E-5 | EventTrace (Current-scope question §25-C6) |
| G-V3 | VISUAL_SEMANTICS_GAP | Scrapped unit would wear the green SHIPPED badge (badge keys on `terminal`, text hardcoded) | Current UnitList | reviewer | Med (latent — no scrapped unit in seed until demo produces one) | wrong terminal story mid-demo | `UnitList.tsx:44–47` | ✓ | none | D9E-5 (or defect fix) | Current-scope question |
| G-A1 | AUTHORITY_CLARITY_GAP | FM screens submit dispositions/realloc as `USER-MGR-0001`/`USER-SUP-0001` silently — Scrap (manager-tier) sits un-labeled on the FM surface | A/B/C FM triage | FM | **High** | authority story (BRS RBAC-1/2) is invisible & mislabeled | §13, form constants | ✓ (labeling/attribution copy) | **yes** — actor↔tier presentation mapping (§25-C5) | D9E-1 (model) + D9E-4 | forms (allowed in later nodes) |
| G-A2 | ACTION_CLARITY_GAP | “Needs floor manager approval…” shown for conditions where no FM action exists (S-07; unmapped stages) | A/B/C assembler blocked | assembler | **High** | actively wrong ownership claim | §17.3; code lines cited §10-S7 | ✓ | wording lock | D9E-2/4 | — |
| G-A3 | ACTION_CLARITY_GAP | “Resolve” reveals a form (doesn’t resolve); no success confirmation after actions (G-D4 twin) | FM triage; all forms | FM | Med | trust/feedback gap | §15, §22 | ✓ | none | D9E-2/4 | — |
| G-D1..D8 (demo) | DEMO_NARRATIVE_GAP | D1 misleading S-07 hand-off copy (=G-A2 demo face) · D2 default focus UNIT-0001 shows action-less card; assembly scan absent from variants · D3 QC sign-off absent from variants (UNIT-0005 inert) · D4 no success feedback for the flagship cross-variant action · D5 ref-standard no-override hard stop undemonstrable in variants · D6 UNIT-0006/0007 empty genealogy contradicts “QC verifies genealogy complete” if narrated · D7 quarantine dead-ends mid-demo (unit stays red forever) · D8 empty-vs-loading ambiguity if reset mid-walkthrough fails | variants | reviewer | High (D2/D3/D5), Med rest | demo cannot tell 6 of 9 scenario families from variants (§19) | §19 | D1,D4,D6,D7,D8 ✓ content/copy; **D2/D3/D5 need action-mapping expansion in variants** — frontend-only but widens D9C’s locked “stage 5/10/12 only” action surface | **yes** (§25-C7) | D9E-3 (script) + D9E-4/5 (if expanded) | variant forms |
| G-DOC1..5 | DOCUMENTATION_GAP | stale root PROJECT_BOOTSTRAP “D3 not started” · runtime-contracts Contract 4 “Postgres deferred” · repo/architecture-index end at D8C · coding-patterns router plan never materialized · mock-data-contract-d4 defective stage table (ignored by canon) | governance docs | agents/operator | Med (agent-facing) | future sessions misread state | §5 | ✓ (doc pass) | none (already operator-acknowledged defect for d4 table) | D9E-1 or housekeeping node | docs (currently forbidden — needs node authorization) |
| G-X1/X2 | ACCESSIBILITY_GAP | variant tab bars lack tablist/selected semantics · no announcements for attention/action changes | variants | AT users | Med | screen-reader comprehension fails | §23 | ✓ | none | D9E-4/5 | — |
| G-INT1..3 | INTENTIONAL_VARIANT_DIFFERENCE | takeover vs inline vs banner; collapsed vs direct triage; tab vs region secondary info | variants | — | n/a | **not gaps — protected** (D9D §10) | §20 | preserve | none | all D9E nodes must preserve | ✓ |
| G-ENG1 | CURRENT_BASELINE_ENGINEERING_DETAIL | endpoint paths, Dev transition, raw response grid, forced-open details, infra badges in Current | Current | engineer | n/a | by-design review console | §17.2 | preserve (scope §25-C6) | scope only | — | Current protected |

### Implementation defects (reported separately — NOT fixed by D9E-0; directive rule honored)

| ID | Defect | Evidence | First recorded |
|---|---|---|---|
| D-1 | Quarantine sets `blocked_reason` but not `block_type` → generic `transition` guard (`reason && block_type`) can advance a quarantined unit | WR:608–619 vs 795–801 | D9A §3.5#4 (still present) |
| D-2 | S-09 gate-pass does not clear a previously persisted fail `blocked_reason` (sets stage/status only) → stale block text can display on an advanced unit | WR:362–374 vs 377 | **new (this recon)** |
| D-3 | `hasSupportedAction` returns true for **any** stage-10 unit incl. blocked-at-10 edge cases beyond cap (consistent ×3, benign today) — and stage-5 branch requires a persisted block that WR never writes (dead branch by backend design) | forms; WR | journal remediation (partially), re-verified |
| D-4 | Authorization-failure signaling inconsistent (200/`failed` vs 403) | WR:220 vs 547/639 | D9A §3.5#5 |
| D-5 | `critical` severity unmapped in EventTrace styling | EventTrace.tsx:9–16 | **new** |
| D-6 | Scrapped-unit SHIPPED-badge mislabel (terminal-keyed badge text) | UnitList.tsx:44–47 | **new** |
| D-7 | Variants’ `units.length===0` = “Loading…” forever (empty-state conflation) | 3 root views | **new** |
| D-8 | `refreshSelected` swallows failures silently → stale UI after a failed refresh | useFactoryViewModel.ts:83 | **new** |
| D-9 | `VariantPlaceholderPane.tsx` now dead code (unreferenced since D9C-6) + 4 legacy dead components + dead `api.ts`/`types.ts` + dead `repositories.py` | shell imports; D9A | D9A (+new placeholder finding) |
| D-10 | ActionPanel not keyed per unit (stale form fields across unit switches); `calRefStds` stale-init race | FactoryFlowBoard/ActionPanel | D9A §4.1 |

### Defect Disposition — OPERATOR_LOCKED

The following defects require a **dedicated correctness node before design-system rollout** (i.e.
before D9E-3 "Design and Content Language" in the locked DAG, §31/§37 — these are correctness
fixes, not new capabilities, and are explicitly **not fixed by D9E-0**, per directive):

- **D-1** — quarantine transition escape (missing `block_type` on quarantine)
- **D-2** — stale Stage-9 blocked reason after pass
- **D-5** — critical severity rendered as muted
- **D-6** — Scrapped unit presented as Shipped
- **D-7** — empty state presented as perpetual loading
- **D-8** — refresh failure swallowed silently
- **D-10** — stale action-form state across unit changes

Disposition for the remainder:

- **D-3** — address during the later action/explanation rollout where its supported-action
  semantics are consumed (i.e. whichever D9E node builds on `hasSupportedAction`/action-eligibility
  presentation).
- **D-4** — document and defer unless recon for the hardening node proves it blocks consistent user
  feedback.
- **D-9** — defer dead-code cleanup (`VariantPlaceholderPane.tsx`, legacy dead components,
  `repositories.py`, etc.); it is unrelated to manufacturing comprehension.

These are correctness fixes, not new capabilities. Do not fix them during D9E-0 (none were fixed by
this artifact's amendment).

No PRODUCT_RULE_CONFLICT class entries beyond §25; no gap here authorizes capability expansion.

---

## 25. Conflicts Requiring Operator Decision — C1–C8 now OPERATOR_RESOLVED

**Status: OPERATOR_RESOLVED (all of C1–C8)**, resolved by the D9E-0 operator decision continuation
(§37). The original conflict-evidence table immediately below is **preserved unchanged** as the
historical record of what D9E-0's recon found in tension; it remains visible for traceability. The
resolutions themselves — the operator's canonical rulings — are recorded in the subsection
following the table, per conflict.

Per the directive's conflict lock, recon originally recorded these **not resolved**; none blocked
completion of safe recon (all were decision items, not evidence-gathering blockers). C1–C4 were
source conflicts; C5–C8 were scope/decision forks the comprehension spec could not proceed without.
All eight are now resolved below.

| # | Conflict | Sources in tension | Evidence | Needed decision (for D9E-1 lock) |
|---|---|---|---|---|
| **C1** | Is S-09 a **gate**? BRS/flowchart (“GATE 1 of three independent gates”) + `stages.json is_gate:true` + WR pass/fail behavior **vs** `docs/factory-flow-model.md` stage table typing S-09 “factory core” (its own hard-stop table also omits S-09/S-07 while adding an S-08 row) | BRS §2/GATE-1; stages.json; WR:336+; flow-model table | §10 rows 7–9 | Confirm canon = **three gates (9/10/11)** and schedule the frozen doc’s correction (a D2A-style errata) — or rule the doc supreme (would contradict code+BRS) |
| **C2** | Authority naming: BRS 3 tiers w/ “Manager & QC authority” (QC = distinct named authority, operator-settled) **vs** flow-model’s 4 levels incl. “Technician” and “Supervisor: QC sign-off” line **vs** seed (`qc_inspector` w/ tier `operator`; manager cannot sign) | BRS §5; D9B §0 canon; flow-model Authority Levels; users.json | §13 | Lock the canonical actor/authority vocabulary for all UI copy (incl. whether “Technician” is a tier, a role, or dropped) — QC-distinctness itself is already settled and preserved |
| **C3** | S-08 “Cloud provision failure → Supervisor” exists **only** in flow-model’s hard-stop table; BRS/flowchart/stages.json/WR have no S-08 failure | flow-model table vs all other sources | §10 row 8 | Declare S-08 failure out-of-model (doc errata) or a future capability — either way D9E copy must not invent it |
| **C4** | Cloud-block recovery narrative: BRS/flowchart “no override at all; cloud returns → re-check” **vs** `docs/demo-walkthrough-d8.md` (“supervisor clears the block”) **vs** implementation (S-12: any actor retries w/ `cloud_available=true`, no authority; S-07: no path exists) | BRS SW-4/BK-2; walkthrough §2/§6; WR | §10 rows 7/12 | Lock the canonical recovery story + demo phrasing for both cloud blocks (and whether S-07’s missing retry endpoint stays absent for the comparison phase) |
| **C5** | Floor-Manager surface silently exercises **manager-tier** authority (Scrap, `USER-MGR-0001`) | BRS RBAC-1 vs variant FM forms | §13/G-A1 | Choose the presentation rule: (a) label dispositions with the acting tier, (b) split scrap behind an explicit “manager decision” affordance, or (c) declare demo-FM = manager for this phase — copy depends on it |
| **C6** | Is **Current** in-scope for comprehension changes? Directive preserves “Current remains the engineering-console baseline” while D9E-5 says “cross-screen application” | directive Preserved-Architecture vs D9E-5 name | §17.2, G-ENG1, G-V2/V3 | Define D9E-5’s exact surface list (variants-only vs variants+shell vs incl. Current chrome) |
| **C7** | Demo coverage ceiling: variants expose only stage-10/12(+dead 5) actions; scan/QC/package/ship/gate/ref-std-hard-stop are Current-only | D9C-4 §10 locked mapping vs D9E-3’s “coherent client walkthrough” goal | §19 | Choose: script the walkthrough to hand off to Current for those beats, **or** authorize widening the variants’ action mapping (frontend-only, no backend change — but it amends D9C-4/5/6’s shipped non-goals) |
| **C8** | Order/recipe context (`/factory/orders`, `/factory/model-recipes`) is real backend data outside the protected view-model surface | D9C-5 §8 protection vs comprehension needs (Q4/Q7 for FM) | §21/G-IA3 | Authorize (or defer) extending `FactoryViewModel`/`factoryApi.ts` in a named D9E node — otherwise D9E copy must keep saying “not available” |

None of these involve stage order, serialized-traceability rules, or variant philosophy — those
all reconciled cleanly (§10, §14, §20).

### Operator Resolutions (OPERATOR_RESOLVED)

**C1 — Stage 9 Gate — OPERATOR_RESOLVED**

Canonical truth: Stages 9, 10, and 11 are the three manufacturing gates. Stage 9 is Gate 1. The
BRS, flowchart, `stages.json`, and backend behavior control. The conflicting frozen flow-model
classification (`docs/factory-flow-model.md` typing S-09 "factory core") is stale and requires
later documentation errata. No workflow behavior changes are authorized by this lock.

**C2 — Actor, Role, and Authority Vocabulary — OPERATOR_RESOLVED**

Canonical UI actors: Assembler; Floor Manager.

Canonical operational roles: Assembler; Technician / Calibration Technician; Floor Manager /
Supervisor; Manager; QC Inspector.

Canonical authority rules: operational role and action authority are distinct concepts. Technician
is a role, not a fourth authority tier. QC authority is distinct from Supervisor and Manager.
Manager authority does not imply QC-signoff authority. Internal seed `authority_tier` values are
implementation details and must not become user-facing terminology. UI explanations describe the
authority required for an action, not an oversimplified hierarchy.

**C3 — Stage 8 Phantom Failure — OPERATOR_RESOLVED**

Canonical truth: no authoritative Stage 8 provisioning failure exists in the current product
model. The flow-model-only "Cloud provision failure → Supervisor" row is stale. D9E must not
invent Stage 8 failure copy, behavior, recovery, or demo coverage. Any future Stage 8 failure would
require a separately authorized capability.

**C4 — Cloud-Block Recovery — OPERATOR_RESOLVED**

Canonical truth: Stage 7 and Stage 12 cloud blocks have no override. Recovery after cloud
restoration is not an override. Stage 7 waits for cloud; nobody on the factory floor can clear it;
the current prototype has no recovery endpoint or action. Stage 12 waits for cloud; Retry Cloud
Backup represents a re-check after connectivity returns. Stage 12 retry is not a Supervisor
override or privileged disposition. Any walkthrough or UI statement claiming that a Floor Manager
or Supervisor clears either cloud block is incorrect and must later be replaced (this specifically
corrects `docs/demo-walkthrough-d8.md`'s "supervisor clears the block" phrasing, cited in the
original C4 evidence above). The missing Stage 7 recovery path remains absent during the current
comprehension phase.

**C5 — Floor Manager and Manager Authority — OPERATOR_RESOLVED**

Canonical presentation: Floor Manager may route a calibration-cap unit back to hardware. Floor
Manager may quarantine a calibration-cap unit. Scrap requires Manager authorization. Floor Manager
screens must not silently execute Scrap as `USER-MGR-0001` while presenting the action as Floor
Manager authority. The actor-first Floor Manager surface must present Scrap as "Manager
authorization required." The real Manager-tier Scrap operation may be demonstrated from Current,
where acting identity and backend behavior remain visible. Do not redefine the demo Floor Manager
as a Manager. No new Manager actor view is authorized.

**C6 — Current Scope — OPERATOR_RESOLVED**

Current is included in D9E under a narrow preservation contract.

Allowed later comprehension treatment: identify Current as the Engineering Baseline; add
orientation and terminology explanations; correct factually wrong semantic presentation; correct
critical-event styling (G-V2/D-5); correct Scrapped-versus-Shipped labeling (G-V3/D-6); improve
truthful loading/error/empty feedback where authorized.

Protected: engineering-console structure; endpoint paths; raw records; technical forms; technical
detail; baseline purpose; underlying behavior.

Current must not be redesigned into an actor view.

**C7 — Demo Coverage — OPERATOR_RESOLVED**

Canonical scope: do not widen actor-variant action mappings during D9E. Actor variants demonstrate
presentation and interruption philosophy. Current demonstrates engineering-only operations such as
assembly scan, hardware gate, QC sign-off, package, and ship. Unavailable scenarios must be
identified honestly. QC rework is documented but unimplemented (T3) and must not be simulated or
implied. The demo narrative may deliberately hand off between actor variants and Current. No new
backend, seed, workflow, or actor capability is authorized. (This resolves §19's "demo-coverage
ceiling" by choosing the hand-off approach over widening D9C-4/5/6's locked action mapping.)

**C8 — Orders and Recipes — OPERATOR_RESOLVED**

Canonical scope: do not extend `FactoryViewModel`, `factoryApi.ts`, order wiring, or recipe wiring
during the currently locked D9E plan. D9E should use the explanatory stage metadata already
available through the existing stage surface (§10, §21 — `stages.json`'s `requirements`,
`hard_stop_controls`, `decision_note`, calibration/QC metadata, already served by `GET
/factory/stages` and unrendered — this remains the sanctioned high-value surface, per G-C2).
Order, stock, staffing, or recipe data absent from a screen must remain truthfully labeled
unavailable. Any future integration requires a separately authorized capability.

---

## 26. TBD Register

| # | TBD | Why not FACT | Blocking? |
|---|---|---|---|
| T1 | S-06/S-13 failure modes | no authoritative failure documented anywhere (BRS silent, stages.json empty) — recorded as “NO AUTHORITATIVE FAILURE MODE FOUND” | no |
| T2 | `out_of_sequence` assembly hard stop | declared in stages.json, no WR implementation, no BRS-level per-step sequence model | no (copy must not claim it) |
| T3 | QC fail/rework path | BRS RW11 exists; implementation absent; adding it = product capability (out of D9E) | no (demo scripts around it) |
| T4 | `rejected` terminal state | defined in flow-model/`_is_terminal`; no code path sets it | no |
| T5 | S-07 recovery endpoint absence — design intent or omission? | BRS implies auto re-check when cloud returns; app has neither check nor action | no (C4 covers narrative) |
| T6 | Quarantine exit path | no un-quarantine action; BRS silent on exit | no |
| T7 | No events emitted for QC-prereq / ship-prereq refusals | audit-completeness question (AUD-1 reading) | no |
| T8 | `reallocate-part` not stage-gated (any non-terminal stage) | intentional convenience vs oversight — no doc states it | no |
| T9 | Sub-assembly naming: BRS’s 8 serial-worthy types vs demo part types | presentation vocabulary choice | no (D9E-1 input) |
| T10 | “Attention levels” future taxonomy | transcript defers (“all immediate for now, build the foundation”) | no (semantic model must leave room) |
| T11 | Whether `.docx` BRS original contains content beyond its `.md`/`.json` twins | binary not text-extracted; folder README designates the md/json as the readable forms | no (accepted source hierarchy) |
| T12 | Verification scripts 012–016 pass status **at this exact HEAD** | not executed by D9E-0 (non-invocation lock); last full green: D9D addendum (all 16, per-script counts recorded in journal) at the same code state now committed as `e4cc024` | no |

---

## 27. Screen Comprehension Contract — OPERATOR_LOCKED

**Status: OPERATOR_LOCKED** (locked by the D9E-0 operator decision continuation; supersedes the
prior "NON-CANONICAL" framing below). Original Q1–Q14 wording preserved unchanged; the applicability
rules below are additive clarification, not a rewrite of the questions themselves.

| Q | Contract line | Today (§17 aggregate) |
|---|---|---|
| 1 | Where am I? (app · variant · actor · screen) | ◐ tabs only |
| 2 | Which actor am I viewing? | ✓ tab label |
| 3 | What is this screen for? (1 sentence) | ✗ everywhere |
| 4 | What am I seeing? (each region self-labels its truth source) | ◐ labels w/o meaning |
| 5 | What needs attention? | ✓ count/badges |
| 6 | Why does it need attention? (cause, plain language + raw code discoverable) | ◐ code-words only |
| 7 | What is the operational consequence? | ✗ |
| 8 | Who owns the next step? | ✗/false in one case |
| 9 | What can this actor do here? | ◐ (three actions; others invisible) |
| 10 | What can this actor NOT do (and why)? | ◐ (two truthful sentences exist) |
| 11 | What happens after the action? | ✗ |
| 12 | What data is unavailable/TBD? | ✓ only in B/C secondary |
| 13 | Why is this variant organized this way? | ✗ |
| 14 | What should a client compare? | ✗ |

**Applicability rules (OPERATOR_LOCKED):**

- **Q1–Q11 are required on every operational screen.** ("Operational screen" = any screen showing
  a real unit/queue/action, per §8/§17 — Assembler calm/interrupt, Floor Manager queue/triage,
  Current's Detail/Action views. It excludes the bare shell chrome itself, which Q13/Q14 cover.)
- **Q12 is required wherever information is unavailable, simulated, unsupported, or TBD** — i.e.
  anywhere §21's classifications (`NOT_AVAILABLE`, mock-simulated cloud truth, `hasSupportedAction`
  false states, or a §26 TBD) surface on-screen.
- **Q13–Q14 are required in the comparison shell and each variant's "About this view" explanation
  only** — they are NOT required to be repeated inside every operational card. (This resolves the
  ambiguity in §17's per-screen Q13/Q14 scoring, which measured operational cards, not the shell —
  those per-screen ✗ marks stand as *evidence of the current gap*, not as a requirement that every
  card carry philosophy text.)
- **Essential operating meaning must remain always visible** — Q1–Q11/Q12 content (where
  applicable) may not be relegated to a tooltip or an expandable panel as its *only* representation.
- **Supporting rationale may be available through one tap** — the "why" behind a Q6/Q7 answer (e.g.
  a stages.json `decision_note` or BRS rationale) may live one tap away (EXP per §18), as long as
  the headline answer itself is always visible.
- **Tooltips may define terminology but must never contain the only available essential
  instruction** — a TIP (§18) may explain a term (e.g. "gate," "no override") but must never be the
  sole place an actor learns what they may or may not do.
- **Touchscreen users must not depend on hover** — carried forward from §18/§23's tap-first
  constraint (target hardware 11–21″ touchscreens per transcript §1.8); no hover-only disclosure of
  any Q1–Q14 content.
- **D9E-6/D9E-7 acceptance must prove** that a first-time reviewer can answer every applicable
  question, per screen, from on-screen content or one tap — without developer narration. (This
  restates and extends the original "Acceptance shape" below to cover both the design-and-build
  audit intent named D9E-6 in §31's original proposal and the operator-renumbered D9E-7 audit node
  in the locked DAG, §37.)

Acceptance shape (original, preserved): a first-time reviewer, per screen, can answer each question
from on-screen content (AV) or one tap (EXP/TIP per §18 placement rules) — no narration.

## 28. Semantic-State Model — OPERATOR_LOCKED (composable, three-axis)

**Status: OPERATOR_LOCKED.** This replaces the prior flat one-to-one proposal below (retained at
the end of this section as superseded evidence, not as the locked model) with a composable
three-axis model: one manufacturing condition is classified along *all three* axes simultaneously,
not collapsed into a single badge.

### Axis 1 — Manufacturing State

- Active
- Waiting
- Rework
- Quarantined
- Completed
- Shipped
- Scrapped

### Axis 2 — Constraint

- Warning
- Blocked
- No override
- Approval required
- Terminal / immutable

### Axis 3 — Ownership and Actionability

- Action required from you
- Waiting on Supervisor
- Waiting on Manager
- Waiting on QC
- Waiting on external system / cloud
- Retry available
- No action available here

**Rules (OPERATOR_LOCKED):**

- These axes are composable, not mutually exclusive. A single presentation may show one value from
  each axis simultaneously (e.g. a badge/chip cluster), rather than one flattened color.
- One manufacturing condition may carry one value from multiple axes at once.
- Do not flatten Stage 7 or Stage 12 into a single generic red state — each must carry its own
  Manufacturing State (Waiting), Constraint (Blocked + No override), and Ownership (external/cloud)
  values distinctly.
- Semantic presentation must distinguish state, constraint, ownership, and actionability — no single
  visual channel (e.g. "red") may be the only signal for more than one axis value.
- Attention remains a single current tier (T10 preserved) — this model classifies *meaning*
  (what kind of condition this is), not *priority severity* (how urgent it is). The two are
  orthogonal; this axis system does not reintroduce a severity ranking.
- No new backend fields are authorized by this model. All classifications below derive from fields
  and rules already read as FACT in §10–§14/§21 of this recon.
- Derivation is deterministic and computable from existing repository truth only (no invented data).

### Locked example — Stage 12 cloud-backup failure

| Axis | Value | Derivation |
|---|---|---|
| Manufacturing state | Waiting | unit remains at S-12, has not advanced (§10 row 12) |
| Constraint | Blocked + No override | `blocked_reason=cloud_backup_cannot_complete_connectivity_unavailable`, `no_override=true` (WR:741–758) |
| Ownership | Waiting on external system / cloud | `block_type=hardstop_cloud_dependency` (no floor-owned action exists per BRS BK-2) |
| Actionability | Retry available after connectivity returns | `cloud-backup` action remains callable with `cloud_available=true` (WR:760–779); resubmission is a re-check, not an override (C4) |

### Additional worked derivations (for D9E-2/D9E-5 reference, not exhaustive)

| Condition | Manufacturing state | Constraint | Ownership/actionability |
|---|---|---|---|
| S-07 cloud SW/FW block (UNIT-0002) | Waiting | Blocked + No override | Waiting on external system / cloud; no retry endpoint exists (§10 row 7, C4) |
| S-10 attempt fail, <3 | Active | Warning | Action required from you (retry) |
| S-10 cap exceeded | Waiting | Approval required | Waiting on Supervisor (route-back/quarantine) or Manager (scrap) |
| S-10 quarantine disposition | Quarantined | Blocked | No action available here (T6 — no exit path exists) |
| S-10 scrap disposition | Scrapped | Terminal / immutable | No action available here |
| S-09 gate fail | Rework | Blocked | Action required from you (resubmit gate) |
| S-11 SoD violation | Active | Approval required | Waiting on Manager (waiver) or a different QC signer |
| S-14 shipped | Shipped | Terminal / immutable | No action available here |
| Unsupported blocked condition (e.g. S-07 in FM triage) | Waiting | Blocked | No action available here (truthful, per §11/§24 G-A2 correction) |

### Superseded — prior flat proposal (retained as historical evidence only, NOT locked)

The following one-to-one mapping was proposed before this operator lock and is superseded by the
three-axis model above. Retained verbatim for traceability, not as guidance:

| Semantic state (superseded) | Derivation (existing fields) | Distinct treatment goal |
|---|---|---|
| Informational / external stage | `is_external` | neutral |
| Active work | unit at stage, not blocked | primary |
| Waiting on external (cloud) | `block_type=hardstop_cloud_dependency` | distinct “waiting” family (not error-red) |
| Warning / margin | S-10 `attempts>0 && !cap_exceeded` | amber family |
| Recoverable block / rework | S-09 fail; realloc-needed | amber/rework |
| Approval required | `calibration_retry_cap`; SoD | supervisor/authority family (purple exists, unused) |
| Hard block — no override | `no_override=true` | strongest error + decision-note link |
| Retry available | mapped action exists (`hasSupportedAction`-style) | action affordance chip |
| Quarantined | `current_status=quarantined` | distinct hold family |
| Scrapped | terminal + scrapped | terminal-negative (never green) |
| Shipped / completed | terminal + shipped | success |
| Unavailable data | honest-empty regions | muted informational |
| Unsupported action | truthful no-action rows | muted + reason |
| System error | loadError/ApiError | error, app-level |

## 29. Proposed Design-System Component Inventory (NON-CANONICAL, D9E-4 scope)

PROPOSAL (build nothing now): semantic state tokens/classes per §28 (extending the existing
`--factory-*` pattern; additive to styles.css) · StateBadge (maps semantic state → chip) ·
ReasonHeadline (plain-language map w/ raw-code disclosure) · ConsequenceLine · OwnershipChip
(“waiting on: cloud/supervisor/you” + acting-tier label for C5) · NextStepPreview (deterministic
post-action outcome) · AboutThisView expandable panel (shell+variant philosophy, D9D §10 content)
· InfoTip (tap-first “?” per transcript; 44px target; ARIA) · StageChip (`S-NN · Name`) ·
EmptyState (fixes D-7 conflation) · ActionResult confirmation (fixes G-D4) · A11y upgrades
(tablist semantics, live-region announcements). All frontend-additive; zero backend/data change;
variant structural signatures untouched (G-INT preserved).

## 30. Proposed Demo Narrative Structure (NON-CANONICAL, D9E-3 scope)

PROPOSAL, honest to §19’s ceiling (assumes C7 unresolved → hand-offs to Current where needed):
1. **Orientation** (shell + About panels): “Same factory, same truth, three presentation
   philosophies; Current is the engineering baseline.”
2. **Calm day** (UNIT-0001 focus in each variant): compare calm layouts; state plainly that
   assembly scanning itself is demonstrated in Current (or per C7 decision).
3. **Interruption philosophy** (UNIT-0002): the S-07 cloud block seen three ways — takeover vs
   inline vs banner; tell the management-decision story (stages.json note); truthfully “nobody on
   the floor can act; this is by design.”
4. **Margin → escalation** (UNIT-0003 → fail → becomes cap-exceeded): attempts language; then
   **decision** (now-blocked unit): route-back (show S-09 re-entry + counter reset) — reset demo,
   redo, choose quarantine to show the hold state (and its current dead-end, honestly).
5. **Recovery that clears** (UNIT-0006): Retry Cloud Backup from a different variant each run;
   show identical truth reflected in Current’s Event Trace (parity story, D9D-verified live).
6. **Finality** (UNIT-0007 + a 409 via Current): immutability story.
7. **Close**: comparison checklist (Q14 content per variant), then Reset Demo State.
Each beat names: unit, variant, screen, expected transition, and the sentence the screen itself
should eventually say (D9E-2 copy targets).

## 31. D9E-0 … D9E-7 DAG — OPERATOR_LOCKED (supersedes the prior proposed D9E-1…D9E-6 sequence)

**Status: OPERATOR_LOCKED.** This is the operator-approved sequence, replacing the previously
proposed D9E-1…D9E-6 list (retained below as superseded evidence, not as the active plan). It
extends the prior non-canonical proposal with a renumbered/reshaped set of nodes and one
additional node (D9E-7). This does **not** alter or insert a node into the already-completed D9C
DAG — D9C-1 through D9C-6 and D9D remain exactly as `RELEASE_APPROVED` in `ai/state_registry.json`.

```
D9E-0
Max-Depth Recon and Decision Lock
│
└── RECON_APPROVED
      │
      ▼
D9E-1
Canonical Stage, Failure, Recovery, and Authority Model
│
└── RELEASE_APPROVED
      │
      ▼
D9E-2
Manufacturing Truth and Presentation Hardening
│
└── RELEASE_APPROVED
      │
      ▼
D9E-3
Design System and Content Language
│
└── RELEASE_APPROVED
      │
      ▼
D9E-4
Demo Narrative and Review-Shell Guidance
│
└── RELEASE_APPROVED
      │
      ▼
D9E-5
Shared Explanatory UI Primitives
│
└── RELEASE_APPROVED
      │
      ▼
D9E-6
Cross-Screen Application
│
└── RELEASE_APPROVED
      │
      ▼
D9E-7
First-Time-User Comprehension Audit
│
└── RELEASE_APPROVED
      │
      ▼
D9F
Touch Optimization
│
└── RELEASE_APPROVED
      │
      ▼
D9G
Factory Acceptance
│
└── RELEASE_APPROVED
```

**Node scope (locked, mapped from this recon's evidence):**

| Node | Scope (in) | Explicitly out |
|---|---|---|
| **D9E-1** Canonical Stage, Failure, Recovery, and Authority Model | Lock the 14-stage matrix (§10) + failure catalog (§11) + recovery table (§12) + actor/authority vocabulary (§13) as ONE canonical doc; apply C1–C3 doc errata (S-09 gate typing, actor/role vocabulary, S-08 phantom-failure removal) | any code; any new failure modes; T3/T4/T5 capability adds |
| **D9E-2** Manufacturing Truth and Presentation Hardening | Apply the D-1/D-2/D-5/D-6/D-7/D-8/D-10 correctness fixes (§24 disposition) before design-system rollout; apply C4/C5 narrative/authority-labeling corrections (walkthrough phrasing, FM Scrap = "Manager authorization required") | new capabilities; D-3/D-4/D-9 (parked per §24) |
| **D9E-3** Design System and Content Language | Semantic-state system (§28, three-axis, OPERATOR_LOCKED) + reason→explanation/consequence/ownership copy map + terminology replacements (§15 dispositions) + tone rules | rendering changes (D9E-5/6 consume it); backend |
| **D9E-4** Demo Narrative and Review-Shell Guidance | Walkthrough script (§30, per C7's hand-off approach) + About-This-View/comparison copy (Q13/Q14, per §27's shell-and-About-panel scoping) + shell guidance surface design | new scenarios requiring backend/seed change; widening variant action mapping (C7) |
| **D9E-5** Shared Explanatory UI Primitives | Build §29 components + §28 tokens; wire into ONE reference screen for approval | mass rollout |
| **D9E-6** Cross-Screen Application | Apply primitives/copy across all variant screens (+shell; Current per C6's narrow preservation contract; orders/recipes explicitly NOT wired per C8) | variant structural changes; backend; `FactoryViewModel`/`factoryApi.ts` extension |
| **D9E-7** First-Time-User Comprehension Audit | Independent audit vs the OPERATOR_LOCKED §27 contract; evidence per screen/question; gap list → fix loop | new features |
| Then | D9F Touch Optimization · D9G Factory Acceptance (as pre-declared, unchanged) | — |

D9E-7 is an intentional operator-approved extension of the previously non-canonical D9E-6 proposal
(the original single "comprehension audit" node is now split across D9E-2 hardening + D9E-7 audit,
with the intervening content/primitive/application nodes renumbered accordingly).

### Superseded — prior proposed sequence (retained as historical evidence only, NOT the active plan)

| Node | Scope (in) | Explicitly out |
|---|---|---|
| **D9E-1** Canonical stage/failure/recovery/authority model | Lock: 14-stage matrix (§10) + failure IDs (§11) + recovery table (§12) + actor/authority vocabulary (§13) as ONE canonical doc; resolve C1–C5 doc errata (incl. flow-model corrections) | any code; any new failure modes; T3/T4/T5 capability adds |
| **D9E-2** Design system & content language | Semantic-state system (§28) + reason→explanation/consequence/ownership copy map + terminology replacements (§15 dispositions) + tone rules | rendering changes (D9E-4/5 consume it); backend |
| **D9E-3** Demo narrative & review-shell guidance | Walkthrough script (§30) + About-This-View/comparison copy (Q13/Q14) + shell guidance surface design | new scenarios requiring backend/seed change |
| **D9E-4** Shared explanatory UI primitives | Build §29 components + tokens; wire into ONE reference screen for approval | mass rollout |
| **D9E-5** Cross-screen application | Apply primitives/copy across all variant screens (+shell; Current per C6; orders wiring per C8) | variant structural changes; backend |
| **D9E-6** First-time-user comprehension audit | Independent audit vs locked §27 contract; evidence per screen/question; gap list → fix loop | new features |
| Then | D9F touch optimization · D9G factory acceptance (as pre-declared) | — |

## 32. Recommended Next Operator Decisions (the decision packet, summarized consequences) — SUPERSEDED BY §37

**Status note:** items 1–6 below were the original recon's decision requests. All six are now
resolved by the D9E-0 operator decision continuation recorded in §37 (contract locked §27,
semantic model locked §28, C1–C8 resolved §25, DAG locked §31). This numbered list is preserved
unchanged as the historical record of what was originally requested; §37 is authoritative for
current status.

1. **Lock the comprehension contract** (§27 Q1–Q14 + placement rules §18) — gates every later node’s acceptance criteria. *(Now OPERATOR_LOCKED, §27.)*
2. **Lock the semantic-state vocabulary** (§28) — gates D9E-2 tokens and all copy. *(Now OPERATOR_LOCKED as a three-axis composable model, §28; the D9E node that consumes it is renumbered D9E-3 in the locked DAG, §31.)*
3. **Resolve C1–C4** (gate typing, authority naming, S-08 phantom failure, cloud-recovery narrative) — gates D9E-1’s canonical doc; C1/C3/C4 are doc-errata-shaped, C2 is naming. *(Now OPERATOR_RESOLVED, §25.)*
4. **Decide C5** (how FM surfaces manager-tier scrap) — gates authority copy. *(Now OPERATOR_RESOLVED, §25.)*
5. **Decide C6** (Current’s inclusion in D9E-5) and **C7** (script around vs widen variant actions) and **C8** (orders/recipes wiring) — gates D9E-3/5 scope; C7/C8 are the only items that would touch currently-protected frontend surfaces, and neither touches backend/data. *(Now OPERATOR_RESOLVED, §25; the nodes they gate are renumbered D9E-4/D9E-6 in the locked DAG, §31.)*
6. **Confirm** the proposed D9E-1…6 serialization (§31) and that defects D-1…D-10 remain parked (or get their own small hardening node) — D9E-0 fixed nothing, by rule. *(Now confirmed and locked as the D9E-0…D9E-7 DAG, §31; defects D-1/D-2/D-5/D-6/D-7/D-8/D-10 are assigned to the new D9E-2 hardening node, per §24's Defect Disposition — still not fixed by D9E-0 itself.)*
7. Housekeeping (optional, non-blocking, still open): commit policy for this artifact + the two pre-existing untracked files; stale-doc errata batch (G-DOC).

## 33. Exact Files Read

**FULL reads (complete file):**

- Vendored OS (48 readable files — every file under `vendor/engineering-os/` except two empty
  `.gitkeep`s): `INSTALL.md`, `README.md`, `core-docs/{PROJECT_BOOTSTRAP,ENGINEERING_OS,
  directive-template,spec-generation,spec-compiler,spec-to-task-playbook,task-generator,task-graph,
  execution-loop-controller,execution-orchestrator,verification-playbook,system-spine-playbook}.md`,
  `scripts/{compile-spec,generate-tasks,execution-supervisor,state-manager,invariant-engine,
  os-adapter-check,os-boot-check,os-intent-entry,os-self-test,run-full-regression}.sh`,
  `scripts/raystrat-os`, `templates/{adapter.config.sh,invariant-registry.md,state_registry.json}`,
  `claude/agents/{journal-agent,spec-agent}.md`, `claude/hooks/docker-build-guard.sh`,
  `tests/{run-self-tests,001-os-enforcement-layer,002-os-state-machine,003-os-invariant-engine,
  004-os-cli-backing-surfaces,005-os-cli-wrapper}.sh`, `ai/{engineering-journal.md,
  state_registry.json}`, `ai/recon/OS_CLI_V0_SURFACE.md`, `ai/specs/os-cli-v0.md`,
  `recon/os-core-sanitization-recon.md`, `specs/phases/{phase-1,phase-backend,phase-ui}.md`,
  `engineering-os-structure.txt`, `engineering-os-full-tree.txt`.
- Local adapter & scripts: `.engineering-os/adapter.config.sh`, `.engineering-os/invariants/
  INV-001…INV-006.sh` (6), `scripts/{compile-spec,generate-tasks,execution-supervisor,
  state-manager,invariant-check,smoke}.sh`, `.git/hooks/pre-commit`.
- Root/instruction: `CLAUDE.md`, `AGENTS.md`, `PROJECT_BOOTSTRAP.md`, `ENGINEERING_OS.md`,
  `README.md`, `.gitignore`, `.env.example`, `docker-compose.yml`, `backend/entrypoint.sh`.
- Governance `ai/`: `product-invariants.md`, `runtime-contracts.md`, `service-boundaries.md`,
  `coding-patterns.md`, `architecture-index.md`, `repo-index.md`, `state_registry.json`,
  `engineering-journal.md` (2,742 lines, full).
- Domain/docs: `docs/{factory-flow-model,domain-glossary,decision-lock,
  d2a-model-drift-correction,demo-walkthrough-d8}.md`.
- Source materials: `Digital_Factory_Requirements.md` (BRS, full),
  `Digital_Factory_Flowchart.html`, `Digital_Factory_Workflow.html`, that folder’s `README.md`,
  and `latest-transcripts/call-with-abhilash-kothapalli-3.docx` — extracted read-only via
  `textutil -convert txt -stdout` to the session scratchpad and read in full (684 lines);
  the source `.docx` untouched.
- Prior recon: `ai/recon/{d9a-…,d9b-…,d9c0-…,d9c1-…,d9c2-…,d9c-4-…,d9c-5-…,d9c-6-…,d9d-…}.md`
  (d9a/d9b/d9c0/d9c1/d9c2/d9c-4/d9c-5/d9c-6/d9d full).
- Spec: `specs/d9d-cross-variant-parity.md` (full).
- Backend: `app/{workflow_rules,models,state_store}.py` (full), `app/routes/{actions,
  data_contract,health,factory}.py` (full), `app/{main,settings}.py` (full).
- Data: `data/{stages,factory_units,users,parts,orders,reference_standards,model_recipes}.json`
  (full); `data/events.json` (all 22 events via structured field dump — id/unit/type/severity/
  message for every record).
- Frontend: `src/{main,App}.tsx`, `src/{api,types}.ts`, `src/api/factoryApi.ts`,
  `src/view-model/{types,useFactoryViewModel}.ts`, `src/components/{FactoryFlowBoard,UnitList,
  StageSpine,UnitDetailPanel,ActionPanel,EventTrace}.tsx`, `src/components/variant-review/
  {VariantReviewShell,VariantPlaceholderPane}.tsx`, all 12 files under `variant-review/
  {attention-first,workflow-first,command-center}/`, `src/styles.css`, `index.html`,
  `tailwind.config.js`, `vite.config.ts`.

**PARTIAL reads (sampled; extent stated):**

- `ai/recon/d9c-3-…` (first 120 lines — its remaining parity tables are restated verbatim in the
  journal’s D9C-3 addendum, read full) and `ai/recon/d8c-touch-first-responsive-ui-recon.md`
  (header — substance carried in D9A §2 and the journal).
- `specs/d9c-1…d9c-6` (head ≈85–95 lines + tail ≈12–18 each: Status/Phase/Capability/Source
  Authority/Non-Goals + boundary/handoff — the omitted middles are the Frontend-Surface/acceptance
  text whose shipped results were read directly in code and re-verified by scripts 012–016’s
  existence and the journal’s recorded counts).
- Task files `tasks/{d9c-1…d9c-6,d9d}-{001,002}.md` (14 files, first 30 lines each: title/spec/
  phase/status/layer + description opening; all `Status: done`).
- Verification `scripts/verification/{012..016}-*.sh` (first 22 lines each: header + target-file
  tables; check counts taken from the journal’s recorded runs).
- `ai/incidents/*.md` (5 files, first 60 lines each — all five substantive root-cause sections
  captured; the three D9C incidents are additionally restated in full in the journal).
- Backend support: `app/{seed,db_models,data_loader,repositories}.py` (heads: 30/45/30/12 lines —
  the load-bearing seeding-loss facts were independently confirmed in `state_store.py`, read full).
- Docs phase files `docs/{mock-data-contract-d4,backend-state-behavior-d5,factory-flow-board-ui-d6,
  persistence-postgres-d7,factory-review-hardening-d8,light-mode-readability-d8a,
  material-theme-readability-d8b,touch-first-responsive-ui-d8c,os-vendor-integration,
  d1c-invented-os-cleanup}.md` + `docs/superpowers/plans/2026-06-30-d3-stack-scaffold.md`
  (headers, ≈14 lines each — full content mirrored by journal entries 005–013/D8C, read full).
- `backend/alembic/**`, Dockerfiles, `requirements.txt`, `package.json`, tsconfigs,
  `playwright.config.ts`, `tests/d8c-*.spec.ts`: enumerated (find/wc), not opened — no claim in
  this artifact rests on their contents beyond existence.
- `Digital_Factory_Requirements.json`: enumerated + spot-consistent with the `.md` twin (T11);
  `.docx` originals: not extracted (binary; readable twins designated by that folder’s README).
- `_archive/invented-os-bootstrap-d1c/**`: enumerated only (quarantined by D1C; excluded as
  authority by its own record).
- `artifacts/**` (17 PNGs): enumerated; visual claims in this artifact rest on component code +
  journal-recorded browser evidence, not on re-viewing the images.

**Diff-verification:** the three `*ActionForm.tsx` files were additionally compared via
variant-name-normalized `diff` (both diffs empty ⇒ byte-equivalent modulo names).

## 34. Exact Commands and Queries Executed (all read-only)

Git/repo state: `pwd` · `git branch --show-current` · `git rev-parse HEAD` ·
`git rev-parse origin/main` · `git status --short` (×4: start, mid, pre-write, close) ·
`git status -sb` · `git remote -v` · `git log --oneline -15` ·
`git log --oneline origin/main..HEAD` · `git branch -r --contains HEAD` ·
`git show --stat --oneline HEAD | head -25`.

Enumeration/measurement: `find vendor/engineering-os -type f | sort` ·
`find .engineering-os -type f | sort` · `find ai specs tasks scripts -type f | sort` ·
`find docs source-materials artifacts data _archive .claude -type f | sort` ·
`find backend frontend -type f` (node_modules/dist/pycache excluded) · `ls -la` (root,
`ai/recon/`, `.git/hooks/`) · `wc -l` batches over recon/docs/specs/tasks/scripts/frontend/
backend/data surfaces.

Content reads: the `Read` tool for every file listed in §33; three batched `head`/`tail`/`cat`
sweeps (specs heads+tails; task heads; verification-script heads; small config/backend files;
docs headers) — display-only.

Extraction/analysis: `textutil -convert txt -stdout <transcript.docx> > <scratchpad>/transcript…txt`
(write target = session scratchpad **outside the repository**; source untouched) ·
`python3 -c "…json.load('data/events.json')…print(fields)"` (stdout-only JSON inspection) ·
the two name-normalized `diff <(sed …) <(sed …)` comparisons of the action forms (stdout-only).

Target-existence guard (before any write): `ls ai/recon/d9e-0-manufacturing-comprehension-recon.md`
→ “No such file or directory” → **no overwrite condition; the STOP-if-exists clause did not
trigger.**

**Not executed (explicitly):** any `scripts/*` or `vendor/engineering-os/scripts/*` or
`scripts/verification/*` or `tests/*` script; `raystrat-os` in any mode; `state-manager.sh`;
`invariant-check.sh`; any `docker`/`docker compose` command; any `curl`/HTTP request; any browser
tool; any `git add/commit/stash/reset/clean/push/fetch`; any formatter/generator/installer.

## 35. Confirmation of Zero Unauthorized Mutation

Close-out `git status --short` (after all writes to this artifact):

```
?? AGENTS.md                              (pre-existing, untouched)
?? ai/recon/d9c2-shared-view-model.md     (pre-existing, untouched)
?? ai/recon/d9e-0-manufacturing-comprehension-recon.md   (THIS ARTIFACT — the only D9E-0 mutation)
```

- Tracked files: **zero modified** (no `M`/`D`/staged entries at any point in the session).
- Created: exactly this artifact. Renamed/deleted/staged/committed/pushed: nothing.
- `ai/state_registry.json`: no `d9e-*` key added; file byte-untouched (never opened for write).
- `ai/engineering-journal.md`: no entry appended (read-only).
- `frontend/`, `backend/`, `data/`, `alembic`, seeds, `docker-compose.yml`, Dockerfiles,
  `vendor/`, `.engineering-os/`, `specs/`, `tasks/`, `scripts/`, `tests/`, package/lock manifests,
  git hooks, repository configuration, existing `ai/recon/*`: **untouched** (no write tool was
  ever pointed at any of these paths; §34’s only non-repo write target was the session scratchpad).
- Control layers not invoked: no `os-adapter-check.sh`, `compile-spec.sh`, `generate-tasks.sh`,
  `execution-supervisor.sh`, orchestrators/workers, state or release transitions,
  mutation-capable verification wrappers, pre-commit hook runs, commits, or pushes (§34).
- Docker/browser/demo state: no container, HTTP, browser, or reset interaction of any kind.
- Pre-existing residue accounted separately (§3): the two untracked files above predate D9E-0
  (zero git history; first recorded in D9C-3 recon §1) and are **not** attributed to this node.
- The only persistent artifacts of this session outside the repo: transcript text extraction in
  the session-scratchpad temp directory (harness-managed, non-repository).

This recon deliberately did **not** claim `SPEC_LOCKED`, `TASK_GRAPH_LOCKED`, `EXECUTION_ACTIVE`,
`VERIFICATION_REQUIRED`, or `RELEASE_APPROVED` for anything.

## 36. Pre-Decision Recon Status — SUPERSEDED BY §37

Historical closeout status before the operator decision lock; this is superseded by §37 and is not
the artifact's active status.

All completion-gate items verified: OS surface enumerated + read (§4); local governance read (§5);
prior D9 artifacts read (§5, §33); implementation and data surfaces read (§33); supplied
manufacturing evidence (flowchart/BRS/transcript) present, read, and reconciled (§6, §10); 14
stages mapped (§10); documented failure/recovery paths mapped (§11–§12); actor authority mapped
(§13); every current screen/state inventoried and audited (§8, §17, §22); terminology audited
(§15); design-system semantics audited (§16); demo scenarios mapped (§19, §30); data availability
classified (§21); conflicts and TBDs explicit (§25–§26); comprehension contract proposed, **not
locked** (§27); later D9E node boundaries proposed, **not executed** (§31); this artifact exists;
zero unauthorized mutation proven (§35).

**Historical status line, preserved as evidence of the pre-lock state (superseded by §37 below —
not the artifact's current status):**
`D9E-0 — Manufacturing Comprehension System Max-Depth Recon: RECON_COMPLETE — OPERATOR_DECISION_REQUIRED`

---

## 37. Operator Decision Lock and Recon Approval

**Approval date/time:** 2026-07-14 (this continuation session, immediately following the primary
D9E-0 recon above).

**Corrected defect count:** the implementation-defect register in §24 is authoritative at **10**
defects (D-1 through D-10). §2's Executive Finding previously misstated this as 8 and has been
corrected to 10 in this amendment. The material-source-conflict count in §2 was also found
inconsistent (stated as 4 against an actual 8-row C1–C8 table in §25) and has been corrected to 8
in this same amendment, since it is the same class of internal-consistency error the operator asked
this pass to eliminate. One further internal inconsistency was found and corrected: §16's
scrapped/SHIPPED-badge finding cited "D-7 defect" where the authoritative §24 register assigns this
finding to **D-6**; corrected in place.

**Comprehension-contract lock:** §27 is now marked **OPERATOR_LOCKED**. The original Q1–Q14
wording is preserved unchanged; the operator's applicability rules are recorded as additive
clarification (Q1–Q11 required on every operational screen; Q12 required wherever data is
unavailable/simulated/unsupported/TBD; Q13–Q14 required only in the shell and each variant's
"About this view," not repeated per operational card; essential meaning always visible; rationale
one tap away; tooltips never the sole source of essential instruction; no hover-dependence;
D9E-6/D9E-7 acceptance must prove first-time-reviewer comprehension without narration).

**Composable semantic-model lock:** §28 is now marked **OPERATOR_LOCKED** as a three-axis model
(Manufacturing State × Constraint × Ownership/Actionability), replacing the prior flat
one-to-one proposal (retained as superseded evidence within §28). The locked Stage-12 example and
additional worked derivations are recorded verbatim per the operator's specification. No new
backend fields were introduced; every derivation traces to fields/rules already established as
FACT in §10–§14/§21.

**C1–C8 resolutions:** all eight conflicts in §25 are now marked **OPERATOR_RESOLVED**, with the
operator's canonical rulings recorded in full substance immediately after the original (preserved)
conflict-evidence table: C1 confirms the three-gate model (9/10/11) and flags the frozen flow-model
doc for later errata; C2 locks the actor/role/authority vocabulary (Technician = role, not a tier;
QC distinct from Supervisor/Manager); C3 declares the Stage-8 failure row apocryphal (no
implementation, no copy to be invented); C4 locks the cloud-block recovery narrative (no override
at either block; Stage-12 retry is a re-check, not a Supervisor override; the demo walkthrough's
"supervisor clears the block" phrasing is flagged incorrect); C5 requires Floor Manager Scrap to be
presented as "Manager authorization required," never silently exercised as unlabeled FM authority;
C6 locks Current's narrow preservation contract (baseline identification, terminology, and named
correctness fixes only — no redesign into an actor view); C7 locks the demo-coverage approach
(hand off to Current for scan/QC/package/ship/gate/ref-std-hardstop beats; no widening of the D9C
action mapping); C8 locks the scope boundary against extending `FactoryViewModel`/`factoryApi.ts`
for orders/recipes during the current plan.

**Defect dispositions:** §24 now carries an OPERATOR_LOCKED disposition subsection. D-1, D-2, D-5,
D-6, D-7, D-8, and D-10 are assigned to a dedicated correctness node (D9E-2, in the revised DAG)
that must land before design-system rollout (D9E-3). D-3 is deferred to whichever later node
consumes action-eligibility semantics; D-4 is documented and deferred pending proof it blocks
consistent feedback; D-9 (dead code) is deferred as unrelated to comprehension. None of D-1…D-10
was fixed by this amendment or by D9E-0 — this remains a recon-only artifact.

**Revised D9E DAG:** §31 now records the OPERATOR_LOCKED sequence D9E-0 (Max-Depth Recon and
Decision Lock, `RECON_APPROVED`) → D9E-1 (Canonical Stage, Failure, Recovery, and Authority Model)
→ D9E-2 (Manufacturing Truth and Presentation Hardening) → D9E-3 (Design System and Content
Language) → D9E-4 (Demo Narrative and Review-Shell Guidance) → D9E-5 (Shared Explanatory UI
Primitives) → D9E-6 (Cross-Screen Application) → D9E-7 (First-Time-User Comprehension Audit) → D9F
(Touch Optimization) → D9G (Factory Acceptance), each gated on the prior node's `RELEASE_APPROVED`.
The prior proposed D9E-1…D9E-6 sequence is retained in §31 as superseded historical evidence. This
revised DAG is an **intentional, operator-approved extension** of the previously non-canonical
D9E-1…D9E-6 proposal (splitting the original single comprehension-audit node into a D9E-2 hardening
node and a D9E-7 audit node, and renumbering the content/primitive/application nodes accordingly).
It does **not** alter or insert a node into the already-completed D9C DAG — `d9c-1-variant-review-
shell` through `d9c-6-command-center-actor-views` and `d9d-cross-variant-parity` remain exactly as
recorded (`RELEASE_APPROVED`) in `ai/state_registry.json`, which this continuation did not touch.

**Confirmation — no implementation introduced:** this continuation modified exactly one file
(`ai/recon/d9e-0-manufacturing-comprehension-recon.md`). No frontend, backend, data, schema,
seed, Docker, or governance file was created, modified, or deleted. No spec, task, or verification
script was authored.

**Confirmation — D9E-1 has not started:** no canonical-model document, code change, or
capability work has begun. The locks recorded above are decision records within this recon
artifact, not the D9E-1 deliverable itself (a standalone canonical doc is D9E-1's own scope, per
§31's node table).

**Confirmation — the only mutation remains the recon artifact:** verified by read-only
`git status --short` immediately before and after this amendment (§ below); no other repository
path changed.

### Read-only validation (evidence)

Commands actually run (read-only), with real captured output:

```
$ grep -c "^## " ai/recon/d9e-0-manufacturing-comprehension-recon.md
37

$ grep -n "^\*\*C[1-8] —" ai/recon/d9e-0-manufacturing-comprehension-recon.md
886:**C1 — Stage 9 Gate — OPERATOR_RESOLVED**
893:**C2 — Actor, Role, and Authority Vocabulary — OPERATOR_RESOLVED**
906:**C3 — Stage 8 Phantom Failure — OPERATOR_RESOLVED**
913:**C4 — Cloud-Block Recovery — OPERATOR_RESOLVED**
925:**C5 — Floor Manager and Manager Authority — OPERATOR_RESOLVED**
935:**C6 — Current Scope — OPERATOR_RESOLVED**
949:**C7 — Demo Coverage — OPERATOR_RESOLVED**
959:**C8 — Orders and Recipes — OPERATOR_RESOLVED**
(all 8 conflicts confirmed individually marked OPERATOR_RESOLVED)

$ grep -c "^| D-[0-9]* |" ai/recon/d9e-0-manufacturing-comprehension-recon.md
10
(D-1 through D-10 — exactly ten rows confirmed in the §24 register)

$ grep -n "Implementation defects observed" ai/recon/d9e-0-manufacturing-comprehension-recon.md
66:Implementation defects observed (reported, not fixed): 10 (§24, classified `IMPLEMENTATION_DEFECT`).
(confirmed corrected to 10, not 8)

$ grep -n "^D9E-7$\|^D9F$\|^D9G$" ai/recon/d9e-0-manufacturing-comprehension-recon.md
1226:D9E-7
1232:D9F
1238:D9G
(confirms the revised D9E-0…D9E-7 + D9F/D9G sequence diagram is present in §31, in order)

$ git status --short
?? AGENTS.md
?? ai/recon/d9c2-shared-view-model.md
?? ai/recon/d9e-0-manufacturing-comprehension-recon.md

$ git diff --name-only
(empty)

$ git diff --cached --name-only
(empty)
```

Zero tracked files modified or staged; exactly one new untracked file (this artifact) plus the two
pre-existing untracked files, unchanged.

No `docker`, `docker compose`, `curl`, browser-automation tool, `git add`, `git commit`,
`git push`, or Engineering OS control-layer script (`os-adapter-check.sh`, `compile-spec.sh`,
`generate-tasks.sh`, `execution-supervisor.sh`, `state-manager.sh`, `invariant-check.sh`,
`raystrat-os`, or any `scripts/verification/*.sh`) was invoked during this continuation.

The two pre-existing untracked files — `AGENTS.md` and `ai/recon/d9c2-shared-view-model.md` — are
confirmed present, unmodified, unstaged, and not cleaned; they predate D9E-0 (zero git history,
first recorded in the D9C-3 recon) and remain outside this node's authorized mutation.

**Final D9E-0 status:**

RECON_APPROVED — READY_FOR_D9E-1

D9E-0 remains outside the execution state machine (`ai/state_registry.json` was not written) because it was recon-only throughout, including this decision-lock continuation.

**D9E-0 — Manufacturing Comprehension System: RECON_APPROVED — READY_FOR_D9E-1**





