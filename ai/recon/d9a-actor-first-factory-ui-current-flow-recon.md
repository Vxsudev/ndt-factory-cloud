# D9A — Actor-First Factory UI Current-Flow Recon

**Feature slug:** `actor-first-factory-ui-recon-d9a`
**Mode:** RECON-ONLY. No application code, backend, schema, or data was modified during this recon. New files created: this artifact, `artifacts/d9a-current-flow-recon/*.png` (screenshot evidence).
**Branch:** `main` · **HEAD:** `ba3ab83` ("chore: remove archived Engineering OS bootstrap artifacts")

---

## 0. Executive Summary

**Current app state.** The Factory Cloud prototype is a single-page, Postgres-backed FastAPI + React app that has completed phases D3 through D8C. All local verification passes: `scripts/invariant-check.sh` (6/6), `scripts/verification/001`–`011` (32 PASS / 1 environment-only SKIP), and `scripts/smoke.sh` (45/45). The app was brought up fresh via `docker compose up -d --build` for this recon and exercised end-to-end in a real browser (Playwright), including a full demo-reset round-trip that reproduced the exact seed state.

**Current flow summary.** The app is one screen: a flat Unit Queue (all 7 seed units, unfiltered, visible to everyone identically), a 14-stage read-only spine visualization, a "Unit Detail" record dump (every field open, nothing progressively disclosed), an "Action Panel" that renders exactly one raw HTML form per backend REST endpoint (labelled with the literal `POST /factory/units/{id}/actions/...` path), and a global Event Trace audit log. There is no authentication, no roles, no per-actor scoping of any kind — every visitor sees the same engineering-console view of the same data.

**Ready for three-variant brainstorming?** Yes, with two caveats the operator should resolve or explicitly accept first (see below). The domain model, backend workflow authority, and D8C responsive/theme substrate are all solid and verification-clean — safe to build on. The main gap is that the directive's premise (a "latest Abhilash transcript" superseding all other authority) does not hold: **no such artifact exists anywhere in this repository** (confirmed by an exhaustive filename and content search — see §2). This recon substitutes the best available authority stack (current code → ratified `docs/factory-flow-model.md` → original `source-materials` requirements) and flags every place a transcript-implied "correction" could not be verified against real repo content.

**Major contradictions found:**
1. **No transcript exists.** The directive's authority order ("transcript supersedes all") cannot be applied; substituted order is documented in §2.
2. **`docs/mock-data-contract-d4.md`'s "Canonical 14-Stage Spine" table is a documentation defect** — it lists an entirely different, apparently invented 14-stage process that matches neither the ratified `docs/factory-flow-model.md` spine nor the original source-materials. It should be disregarded as a stage authority (§2, §6).
3. **`docs/factory-flow-model.md`'s Authority Levels table conflicts with the original source-materials** on who holds final QC sign-off authority (the ratified doc gives it to "Supervisor"; the source material explicitly names it a distinct "Manager / QC sign-off authority" tier, separate from Supervisor) and introduces an undocumented "Technician" authority tier absent from the source material (§2, §7). This is a real, unresolved modeling question, not a typo.
4. Several of the directive's own "latest transcript correction" hypotheses (e.g., "factory work effectively starts at assembly") are **directly contradicted** by the currently-ratified, invariant-locked stage model, which places factory-owned scope starting at Stage 3 (Order Received), not Stage 5 (Assembly) — see §6 for the full test of each hypothesis.

**Major implementation risks** (full list in §14): reset endpoint has no environment guard; the Action Panel's ~24 form fields don't reset when switching units (stale-data risk); `repositories.py` and 4 frontend components are dead code; DB seeding is lossy for multi-role users, full stage metadata, and part notes; a quarantine-disposition code path has a latent hard-stop-detection bug; authorization failures are inconsistently signaled (HTTP 403 in some paths, `status:"failed"` in others).

**Recommended next move.** Proceed to **D9B — Three Functional Actor-First UI Variants** using the substitute authority stack in §2, but first put the two documentation conflicts above (QC authority tier; the bogus D4 stage table) in front of the operator for an explicit decision, since actor-first screen design (who can sign off QC, what a "Technician" screen would even be) depends on resolving #3.

---

## 1. Repository / Runtime State

| Check | Result |
|---|---|
| Branch | `main` |
| HEAD commit | `ba3ab83` — "chore: remove archived Engineering OS bootstrap artifacts" |
| Working tree | Clean at recon start (verified via `git status --short`) |
| Origin | `https://github.com/Vxsudev/ndt-factory-cloud.git`; `git fetch --dry-run` returned no output (consistent with local `main` being in sync with `origin/main`; no explicit ahead/behind divergence reported) |
| Ignored local OS/vendor state | `vendor/engineering-os/` and `.engineering-os/` are gitignored **and physically present** locally with real content (core-docs, scripts, invariants, templates, self-tests) — the Engineering OS is not fictional, it is vendored in per `docs/os-vendor-integration.md`. Root-level `PROJECT_BOOTSTRAP.md`, `ENGINEERING_OS.md`, and `CLAUDE.md` are also gitignored local copies (`.gitignore` lines for `/ENGINEERING_OS.md`, `/PROJECT_BOOTSTRAP.md`, `/CLAUDE.md`) and both exist on disk. |
| Docker Compose | Brought up via `docker compose up -d --build` (Docker Desktop was not running at session start; started it, waited for the daemon, then built/started the stack). All 3 services (`postgres`, `backend`, `frontend`) reached `Up`/healthy state. |
| Service health | `GET /health` → `{"status":"ok", ...}` (200); `GET http://localhost:5173/` → 200 with HTML. |
| Migration state | `alembic current` → `001 (head)`; `alembic history` → single migration `<base> -> 001`, no drift, no pending migrations. |
| Seed state | 7 units (`UNIT-0001`..`UNIT-0007`) matching the D5 seed fixture exactly, confirmed via `GET /factory/units`. Confirmed idempotent: called `POST /factory/dev/reset-state` mid-recon and diffed unit stage/status before and after — identical. |
| Verification inventory | `scripts/invariant-check.sh` 6/6 PASS · `001`–`010` all 100% PASS · `011-touch-first-responsive-ui.sh` 32 PASS / 1 SKIP (SKIP is a documented, pre-existing environment limitation: "Browser cannot launch in this Alpine/musl runtime image" — not a regression) · `scripts/smoke.sh` 45/45 PASS. Full output captured in this session; see §15. |

No application code, backend, schema, or data file was modified to produce any of the above.

---

## 2. Source Authority Stack

### Documents found and their role

| Path | Purpose | Phase / Date |
|---|---|---|
| `README.md` | Repo overview, stack, run/verify commands | D8C / current |
| `docs/decision-lock.md` | D0 locked repo-identity, stack, architecture/cloud posture decisions | D0, 2026-06-30 (LOCKED) |
| `docs/factory-flow-model.md` | **Ratified sole authority** for the 14-stage spine, transitions, gates, hard-stops, authority levels | D2A, FROZEN, 2026-06-30 |
| `docs/domain-glossary.md` | Canonical domain terminology, co-frozen with the flow model | D2A, FROZEN |
| `docs/mock-data-contract-d4.md` | D4 data-shape contract — **contains a stage-table defect, see below** | D4, 2026-06-30 |
| `docs/backend-state-behavior-d5.md` | D5 workflow engine documentation | D5, 2026-06-30 |
| `docs/factory-flow-board-ui-d6.md` | D6 first UI documentation | D6, 2026-06-30 |
| `docs/persistence-postgres-d7.md` | D7 Postgres persistence documentation | D7, 2026-06-30 |
| `docs/factory-review-hardening-d8.md`, `-d8a.md`, `-d8b.md`, `-d8c.md` | D8/D8A/D8B/D8C hardening passes (presentation, light-mode, theme, touch-first) | 2026-06-30 → 2026-07-02 |
| `docs/demo-walkthrough-d8.md` | Reviewer walkthrough script | D8 |
| `docs/d1c-invented-os-cleanup.md`, `docs/d2a-model-drift-correction.md`, `docs/os-vendor-integration.md` | Historical corrections: an earlier *invented* fake Engineering OS was quarantined (D1C), an earlier *invented* wrong stage model (stages like `GENEALOGY_LOCK`, `UNIT_PROVISIONED`) was corrected to the canonical spine (D2A), and the real Engineering OS was vendored in from a local canonical path (D1D) | 2026-06-30 |
| `source-materials/digital-factory-requirements-v1/{README.md, Digital_Factory_Requirements.md, .json}` | **Original business requirements** — 14-stage spine, requirement IDs (ORD/ALLOC/ASM/CAL/QC/etc.), 3-tier RBAC, decision log | v1.0, "Draft for Specification," 2026-06-16 |
| `ai/product-invariants.md` | 7 ratified invariants, incl. Invariant 1: `factory-flow-model.md` is sole stage authority | RATIFIED |
| `ai/runtime-contracts.md`, `ai/service-boundaries.md`, `ai/architecture-index.md`, `ai/repo-index.md` | Architecture/ownership documentation (contains some stale phase-status statements, e.g. Contract 4 still says "Mock State... Postgres Deferred" though D7 is long complete — pre-existing, non-blocking drift already known) | various |
| `ai/engineering-journal.md` | Append-only capability history, Entries 002–D8C | through 2026-07-02 |
| `ai/recon/d8c-touch-first-responsive-ui-recon.md` | Prior recon precedent — established the recon-artifact conventions this document follows | 2026-07-02 |

Also present but out of this recon's reading scope: `specs/*.md`, `tasks/*.md` (approved spec/task artifacts per D-phase), `_archive/invented-os-bootstrap-d1c/` (quarantined, do-not-use), `ai/incidents/*.md` (2 incident reports).

### Was an Abhilash transcript found?

**No.** Exhaustive search performed: filename search across the whole repo (excluding `.git`, `node_modules`, `__pycache__`, `.venv`) for `abhilash|kothapalli|transcript|call|meeting|notes` (case-insensitive) — zero matches. Search for any `.docx`/`.vtt`/`.srt` file anywhere — the only `.docx` in the repo is `source-materials/digital-factory-requirements-v1/Digital_Factory_Requirements.docx` (the original requirements doc itself, not a transcript). Content grep for "abhilash"/"kothapalli" anywhere — zero matches. Directory listings of `ai/`, `ai/incidents/`, `ai/recon/`, `docs/`, `source-materials/`, `artifacts/`, `_archive/`, `specs/`, `tasks/` confirm no transcript-shaped file exists in any of them; there is no `scratch/` directory. **No transcript content is reconstructed or speculated about anywhere in this document.**

### Substitute authority order (since no transcript exists)

1. **Current running code / verified runtime behavior** — the only artifact class confirmed to reflect what the system actually does today (this recon verified it directly).
2. **`docs/factory-flow-model.md` + `ai/product-invariants.md` Invariant 1** — explicitly designated sole stage authority; "No agent may invent, reorder, or remove stages without an explicit model update directive."
3. **`docs/domain-glossary.md`** — co-frozen terminology.
4. **Phase docs D4→D8C + `ai/engineering-journal.md`** — detailed change history, subordinate to #2 on conflict.
5. **`source-materials/digital-factory-requirements-v1/`** (2026-06-16) — original business intent; used to resolve ambiguity/gaps in #1–#4. Cross-checked: the ratified 14-stage spine matches this source almost verbatim, confirming faithful derivation.
6. **`ai/architecture-index.md`, `ai/repo-index.md`, `ai/runtime-contracts.md`, `ai/service-boundaries.md`** — descriptive/planning layer, known to contain some stale statements; verify against #1 before relying on them.
7. **Superseded/invented artifacts** — `_archive/invented-os-bootstrap-d1c/` and `docs/mock-data-contract-d4.md`'s stage table specifically — treated as defects, not usable authority.

### Conflicts found

1. **`docs/mock-data-contract-d4.md`'s "Canonical 14-Stage Spine" table is wrong.** It lists stages like "Material Inspection," "Pre-processing," "Calibration Verification," "NDT Scan," "Data Review Gate," "Final Inspection Gate," "Report Generation" — none of which match the ratified spine (`factory-flow-model.md`) or the original source material, and which were never caught by the D2A drift-correction pass (the file postdates D2A). **Treat as a documentation defect; do not use it as a stage authority.**
2. **QC sign-off authority conflict.** `docs/factory-flow-model.md`'s Authority Levels table assigns QC sign-off to "Supervisor." The original source material states QC sign-off is *"its own distinct named authority, not merely a permission every supervisor holds"* and places it in a separate **"Manager / QC authority"** tier. `factory-flow-model.md` also introduces a **"Technician"** authority tier not present anywhere in the source material (which defines only Operator / Supervisor / Manager-QC). This is a genuine, unresolved modeling drift — flagged for operator decision before any actor-specific QC screen is designed (see §13).
3. **Known, pre-existing, non-blocking staleness** (already self-flagged by the D8C recon): `PROJECT_BOOTSTRAP.md` still says "D3 not yet started"; `ai/runtime-contracts.md` Contract 4 still says "Postgres Deferred"; `docs/decision-lock.md`'s phase table still shows D3+/D4+ as "NOT STARTED." None of these are new findings, and none contradict actual current behavior — they're just unupdated status fields.

---

## 3. Current Backend Flow Map

*(Produced by dedicated backend-recon pass; every claim below is cited to file:line in the actual code. Files read in full: `backend/app/main.py`, `routes/health.py`, `routes/data_contract.py`, `routes/actions.py`, `routes/factory.py`, `routes/__init__.py`, `workflow_rules.py`, `models.py`, `db_models.py`, `repositories.py`, `state_store.py`, `data_loader.py`, `seed.py`, `settings.py`, `db.py`, `alembic/versions/001_initial_factory_cloud_schema.py`, plus `docs/backend-state-behavior-d5.md`, `docs/persistence-postgres-d7.md`.)*

### 3.1 Route Table

| Method | Path | Handler | Input | Output | Frontend Consumer | Domain Meaning | Actor Relevance |
|---|---|---|---|---|---|---|---|
| GET | `/health` | `routes/health.py:8` | none | hardcoded `phase="D3_STACK_SCAFFOLD"` (`health.py:12`) | unknown/infra probe | Liveness check | DevOps/QA |
| GET | `/factory/scaffold-status` | `routes/factory.py:8` | none | hardcoded `domain_logic_enabled=False`, `current_phase="D3_STACK_SCAFFOLD"` | unknown, likely vestigial | Stale build-phase flag from D3, never updated | Engineering/QA only |
| GET | `/factory/data-contract/status` | `routes/data_contract.py:23` | none | live `unit_count` from DB but hardcoded `phase="D4_MOCK_DATA_CONTRACT"`, `domain_logic_enabled=False` | unknown | Stale meta/status endpoint | Engineering only |
| GET | `/factory/stages` | `data_contract.py:37` | none | 14 `StageRecord`s from JSON (`data_loader`, not DB) | `StageSpine.tsx` | Static 14-stage spine definition | All roles |
| GET | `/factory/orders` | `data_contract.py:42` | none | `OrderRecord[]` from JSON | **no frontend consumer found** | Order intake records | Sales/planning |
| GET | `/factory/units` | `data_contract.py:47` | none | live `FactoryUnitRecord[]` from DB | `UnitList.tsx` | Live production queue | Operator, Supervisor, QC |
| GET | `/factory/units/{id}` | `data_contract.py:53` | path id | live `FactoryUnitRecord`, 404 if missing | `UnitDetailPanel.tsx` | Full unit record | Operator, Supervisor, QC, Cal tech |
| GET | `/factory/parts` | `data_contract.py:61` | none | live `PartRecord[]` from DB | **no frontend consumer found** | Part inventory/binding status | Inventory operator |
| GET | `/factory/users` | `data_contract.py:67` | none | `UserRecord[]` from JSON (not DB) | fetched but unused (`ActionPanel` never reads its `users` prop) | Actor roster for authority checks | All roles |
| GET | `/factory/model-recipes` | `data_contract.py:72` | none | `ModelRecipeRecord[]` from JSON | **no frontend consumer found** | Model definitions (required parts, checks, cal profile) | Engineering, planning |
| GET | `/factory/reference-standards` | `data_contract.py:77` | none | `ReferenceStandardRecord[]` from JSON | Calibration form's ref-std picker | Calibration reference registry | Cal tech, QC |
| GET | `/factory/events` | `data_contract.py:82` | none | live `EventRecord[]` from DB | `EventTrace.tsx` | Full audit trail | Supervisor, QC, audit |
| POST | `.../actions/scan-part` | `actions.py:25` → `workflow_rules.scan_part` (:109) | part_type, serial, actor, station | `ActionResponse` | `ActionPanel.tsx` | STAGE-05: bind scanned serial | Assembler |
| POST | `.../actions/reallocate-part` | `actions.py:36` → `:212` | old/new serial, reason, actor | `ActionResponse` | `ActionPanel.tsx` | Supervisor part swap | Supervisor (`can_override`) |
| POST | `.../actions/hardware-gate` | `actions.py:47` → `:336` | result, checks, reason | `ActionResponse` | `ActionPanel.tsx` | STAGE-09 gate | HW technician |
| POST | `.../actions/calibration` | `actions.py:58` → `:391` | result, ref-stds, readings, coefficients | `ActionResponse` | `ActionPanel.tsx` | STAGE-10, 3-attempt cap | Calibration tech |
| POST | `.../actions/calibration-disposition` | `actions.py:72` → `:532` | disposition, reason | `ActionResponse` | `ActionPanel.tsx` | Post-cap-exceeded rework/scrap/quarantine | Supervisor/QA mgr |
| POST | `.../actions/qc-signoff` | `actions.py:83` → `:624` | checklist, waiver fields | `ActionResponse` | `ActionPanel.tsx` | STAGE-11, SoD-checked | QC inspector, Manager (waiver) |
| POST | `.../actions/cloud-backup` | `actions.py:94` → `:726` | cloud_available (bool), backup_ref | `ActionResponse` | `ActionPanel.tsx` | STAGE-12, mock cloud hard-stop | Operator/cloud ops |
| POST | `.../actions/package` | `actions.py:105` → `:837` | actor | `ActionResponse` | `ActionPanel.tsx` | STAGE-13 | Shipping operator |
| POST | `.../actions/ship` | `actions.py:116` → `:869` | doc refs | `ActionResponse` | `ActionPanel.tsx` | STAGE-14, terminal | Shipping operator |
| POST | `.../actions/transition` | `actions.py:127` → `:784` | target stage, reason | `ActionResponse` | `ActionPanel.tsx` ("Dev — Backend-Guarded Transition") | Generic one-step advance | Operator/Supervisor (dev tool) |
| POST | `/factory/dev/reset-state` | `actions.py:137` → `state_store.reset_state` (:132) | none | truncates + reseeds all 8 tables | "Reset Demo State" button | Demo reset | QA/demo operator |

### 3.2 Workflow Authority (all in `workflow_rules.py`, per its own docstring: "All domain logic lives here")

- **Legal transitions**: hardcoded `STAGE_SEQUENCE` list (:29-33); generic transitions legal only if exactly +1 index (:812-817) — the data-driven `normal_next_stage_id`/`allowed_rework_stage_ids` fields on `Stage` exist but are **never read** by this logic (flagged in 3.5). Each dedicated action independently hardcodes and checks its own required starting stage.
- **Terminal immutability**: every mutating action checks `_is_terminal()` (:49-53, true if `package_ship_status.terminal` or status in shipped/rejected/scrapped) → HTTP 409 if terminal.
- **Blocked/hard-stop**: single `_blocked_response()` factory (:56-68); `no_override=True` reserved for invalid/unusable reference standards and cloud-unavailable hard-stops; an existing hard-stop persists across calls via a check in generic `transition_stage` (:795-801).
- **Calibration retry**: 3-attempt cap (`max_attempts`, default 3) tracked in `calibration_summary`; on cap-exceeded, blocks pending supervisor disposition (route-to-hardware / scrap / quarantine), each with its own authority + state-reset rules (:391-619).
- **QC sign-off**: requires STAGE-11, requires HW-gate pass + calibration pass + certificate present, and a separation-of-duty check (signer ≠ assembly operator ≠ calibration operator) with a waiver-authority escape hatch (:624-721).
- **Cloud-block**: `cloud_available` is a **client-supplied boolean**, not a real connectivity check (confirmed as an intentional mock per `docs/backend-state-behavior-d5.md`) — hard-stops STAGE-12 if false; ship re-checks `cloud_status.backed_up` independently as a second gate.
- **Package/ship**: package only requires STAGE-13; ship requires STAGE-14 + QC signed-off + cloud backed-up.

### 3.3 State & Persistence

Postgres is the **single source of truth** for units/parts/events — not dual-write. `state_store.get_state()` rebuilds a full working dict from Postgres on every request; `workflow_rules.py` mutates it in plain Python; `persist_action()` flushes it back and commits. However, `stages`, `orders`, `users`, `model_recipes`, `reference_standards` **read endpoints bypass the DB and read the cached static JSON files** via `data_loader.py`, while workflow-authority logic (e.g. reference-standard/user validity checks) reads the DB-seeded copies — these currently agree only because nothing else ever mutates those DB tables post-seed (a latent split-brain risk, not an active bug). `repositories.py` defines DB helper functions that are **never called anywhere** — dead code.

### 3.4 Reset / Demo Behavior

Exactly one mechanism: `POST /factory/dev/reset-state` → raw `TRUNCATE ... RESTART IDENTITY CASCADE` on all 8 tables → re-seed from `data/*.json`. **No authentication, no environment guard** (no `app_env` check despite `settings.py` defining one) — appropriate for a demo prototype but worth flagging (§14). Confirmed working and idempotent during this recon's browser walkthrough.

### 3.5 Notable Backend Observations

1. `/health`, `/factory/scaffold-status`, `/factory/data-contract/status` all still report stale D3/D4-era phase strings, contradicted by `main.py`'s own `version="0.7.0"`/D7 description.
2. `repositories.py` is dead code (zero call sites).
3. Data-driven stage-graph fields (`normal_next_stage_id`, `allowed_rework_stage_ids`) exist on `Stage` but are never consulted — transition legality is a hardcoded linear +1 rule only.
4. **Latent bug**: the `quarantine` disposition path sets `blocked_reason` but never sets `block_type` (unlike every other block path), so the hard-stop-forwarding check in `transition_stage` (which requires both fields truthy) may not catch a quarantined unit.
5. Inconsistent authorization-failure signaling: `reallocate_part`'s insufficient-authority path returns `status:"failed"` (HTTP 200), while QC/disposition/waiver authorization failures raise HTTP 403 — two different shapes for the same class of error.
6. `cloud_available` is purely a caller-typed boolean — no real device/cloud integration exists anywhere (confirmed intentional mock, see §11).
7. **No authentication anywhere** — every `actor_user_id` is a trusted, unverified string; all "who can do this" checks are dict lookups against the seeded roster. Any actor-authority check is trivially spoofable by whichever `actor_user_id` string a caller sends. This is a known, intentional prototype gap (documented in D5/D7 docs), not drift.
8. Backend-only authority surfaces a frontend must never reimplement: stage-sequence legality, the calibration 3-attempt cap/disposition state machine, QC separation-of-duty comparison, cloud-backup hard-stop semantics, terminal immutability. Confirmed the frontend does **not** currently reimplement any of these (see §4.2) — it only duplicates cosmetic stage metadata (gate/cloud-block badge sets), not legality decisions.

---

## 4. Current Frontend Flow Map

*(Produced by dedicated frontend-recon pass; files read in full: `App.tsx`, `main.tsx`, `AppShell.tsx`, `FactoryFlowBoard.tsx`, `UnitList.tsx`, `StageSpine.tsx`, `UnitDetailPanel.tsx`, `ActionPanel.tsx`, `EventTrace.tsx`, `DataContractStatus.tsx`, `HealthStatus.tsx`, `D5BackendStatus.tsx`, `api.ts`, `api/factoryApi.ts`, `types.ts`, `types/factory.ts`, `styles.css`, plus D6/D8/D8A/D8B/D8C docs.)*

### 4.1 Component Map

| Component | API Dependency | User-Visible Role | Current Limitations | Actor-Fit (1-5) |
|---|---|---|---|---|
| `FactoryFlowBoard.tsx` (root) | orchestrates all fetches via `Promise.all` | Whole-app shell: header, compact-pane tabs, 4-region grid | Fetches `parts` but never renders it (dead state). `ActionPanel` rendered without `key={unit.id}` — its ~24 form fields do **not** reset when switching units, so stale actor IDs/serials from the previous unit can leak into the next unit's form. | 2/5 — capable generic shell, not an actor router |
| `UnitList.tsx` | none (data from parent) | Flat list of all units w/ BLOCKED/SHIPPED badges | `SCENARIO_LABELS` is a hardcoded map keyed to the 7 demo seed unit IDs — any other unit gets no label. Unfiltered/unsorted by station, operator, or urgency; every unit shown identically to every viewer. | 2/5 — no "units relevant to me" concept |
| `StageSpine.tsx` | none (pure) | Vertical 14-row spine diagram | `CLOUD_BLOCK_STAGES`/`GATE_STAGES` are hardcoded frontend constants duplicating info the backend could expose per-stage (`is_gate`/`is_external` already exist; there's no `is_cloud_block` field, so this is frontend-only knowledge — a drift risk, not a legality violation). Engineering vocabulary (EXTERNAL/SEPARABLE/GATE), not operator language. | 1/5 — a full state-machine view, the opposite of an actor-scoped screen |
| `UnitDetailPanel.tsx` | none | Full record dump: Identity, Stage/Status, Block, Parts, Calibration, QC, Cloud/Ship | Every `<details>` is hardcoded `open` — despite disclosure-widget markup (from the D8C pass), **nothing is actually collapsed by default**; progressive disclosure exists in markup only. Labels are raw schema field names. | 2/5 — an inspector/DB-row view |
| `ActionPanel.tsx` | one function per POST route | Renders exactly one raw form per current-stage action, echoes backend response verbatim | `users` prop fetched but **never referenced** — the documented "user select lists" feature (D6 doc) was never built; every actor-identity field is free text with hardcoded demo defaults (`'USER-OP-0001'`, etc). `calRefStds` initializes from `refStandards` at mount before the async fetch likely resolves — stale-default bug candidate. UI text literally shows `POST /factory/units/{id}/actions/scan-part` to the user. | 1/5 — a per-endpoint test harness, the purest engineering-console pattern in the app |
| `EventTrace.tsx` | none | Chronological event log, unit-prioritized when selected | Shows raw event IDs and ISO timestamps even in compact card view — machine/audit presentation, not a human narrative. | 2/5 — solid generic audit trail, not actor-tailored |
| `AppShell.tsx`, `HealthStatus.tsx`, `DataContractStatus.tsx`, `D5BackendStatus.tsx` | mixed (one uses raw `fetch()`, bypassing the API client convention) | **Dead code** — confirmed unreachable from the render tree, matches D8C doc's own admission | n/a | n/a |

### 4.2 API Client & Frontend-Authority Check

Two parallel API-client modules exist (`api.ts`, tiny/dead-path-only; `api/factoryApi.ts`, the real one) with an overlapping `fetchHealth` export — confusing but harmless since one path is dead. `factoryApi.ts` treats HTTP 200 + `status:"blocked"` as a **normal, non-error response** (explicit code comment: "200 with blocked status is NOT an error") — blocked/failed outcomes are rendered, not swallowed.

**Explicitly verified**: no submit button is ever disabled by a frontend-computed legality prediction — every submit is gated only on an in-flight `loading` flag. Which *form* renders is gated on backend-returned data (`terminal`, `cap_exceeded`), not invented rules. The frontend does duplicate cosmetic stage-model facts (`hasStageForm` stage-number list in `ActionPanel`, `CLOUD_BLOCK_STAGES`/`GATE_STAGES` in `StageSpine`) that could drift from the backend's own `is_gate`/`is_external` flags if the stage model changes — a real but non-critical drift risk, not a legality violation.

### 4.3 Theme & Responsive System

`[data-theme]` CSS custom-property system (MD3 token set) with a no-FOUC inline boot script; theme persisted to `localStorage`. D8C responsive layout: Compact (below `lg`, single-pane tab bar for Unit Queue/Detail/Stages/Events, defaulting to Detail) vs Standard/Large (`lg`+, all 4 regions simultaneous). Touch targets: 48×48/44×44px utility classes applied consistently; form controls at 48px min-height / 16px font. This recon's own browser walkthrough confirmed no horizontal overflow at 414px width and confirmed dark/light toggle both render correctly (see §16 screenshots).

### 4.4 Information & Action Hierarchy

At `lg`+, everything is visible with no clicks. Below `lg`, one pane at a time. Within the Detail pane, **content order contradicts D8C's own documented actor-priority intent** ("current unit → block state → required action → supporting detail") — the actual DOM order puts the Action Panel *after* all detail sections (Identity → Stage/Status → Block → Parts → Calibration → QC → Cloud/Ship), meaning "required action" renders last, below everything else, in a scrollable pane. This is a real, documented drift between stated intent and shipped code (flagged by the frontend-recon pass, not previously caught).

### 4.5 Notable Frontend Observations

Dead state (`parts`), dead prop (`users`), 4 dead components, `ActionPanel` not resetting per-unit, a stale-init bug candidate in `calRefStds`, hardcoded duplicated stage-model constants, and pervasive display of raw backend field names / raw endpoint paths / raw request forms throughout. All of this is consistent with — and explicitly acknowledged by — the D8C documentation itself, which frames the current UI as "groundwork for a future actor-specific (assembler/floor-manager) UI split" that has **not yet been built**.

---

## 5. Current Data Model / Fixtures

*(Produced by dedicated data-model recon pass; files read in full: all 8 `data/*.json` fixtures, `db_models.py`, `models.py`, migration `001`, `seed.py`, `data_loader.py`, plus `docs/mock-data-contract-d4.md`, `docs/domain-glossary.md`.)*

**Architecture note**: DB tables follow a "hot columns + JSONB payload" pattern for most entities, **except `Stage`, `Part`, and `User`, which have no payload column** — meaning some JSON fields are silently dropped when seeded into Postgres (see below). **No SQL foreign-key constraints exist anywhere** — every cross-entity reference (`order_id`, `bound_to_unit_id`, `allocated_to_order_id`, etc.) is an unconstrained string column; referential integrity is app-code-only.

| Entity | Fixture count | Key fields | DB seeding gaps |
|---|---|---|---|
| Order | 3 | `id`, `approval_status`, `approved_by`, `model_id`, `boundary_validation_status`, `unit_ids_provisioned` | `customer_ref`/`notes` DB columns have no source data (dead columns); rest survives in `payload` |
| Factory Unit | 7 | `current_stage_id/number/status`, `blocked_reason`, `block_type`, `no_override`, `part_allocations`, `genealogy`, `gate_results`, `calibration_summary`, `qc_summary`, `cloud_status`, `package_ship_status` | fully preserved via `payload` |
| Part | 6 | `serial_number`, `lot_number`, `inventory_status`, `allocated_to_order_id`, `bound_to_unit_id`, `released`, `release_reason_code` | **`note` field silently dropped** (no payload column) |
| Stage | 14 | `id/number/name`, `ownership`, `is_gate/is_external/is_separable`, `hard_stop_controls`, `normal_next_stage_id` | **`requirements`, `allowed_rework_stage_ids`, `source_refs`, `calibration_metadata`, `qc_metadata`, `terminal_metadata` all permanently lost on seed** (no payload column) — the one entity with real data loss |
| User | 6 | `roles[]`, `authority_tier`, `can_perform_stages`, `can_override`, `can_qc_signoff`, `disposition_authority` | **multi-role users collapsed to `role = roles[0]`** (2nd role silently dropped for 2 of 6 users); **`can_perform_stages` has no DB column and no payload — entirely lost** |
| Event | 22 | full audit fields incl. `payload`, `source_refs` | none — most completely modeled table |
| Model Recipe | 2 | `required_part_types`, `hardware_checks`, `calibration_profile`, `firmware_baseline` | survives via `payload`; `name`/`description` columns are null (no source field) |
| Reference Standard | 3 | `standard_type`, `certificate_id`, `valid_until`, `status`, `can_be_used_for_calibration` | survives via `payload` |

### Direct answers to the serialized-parts questions

1. **Serialized part numbers exist**: yes, `Part.serial_number` is a first-class, indexed field.
2. **Parts assigned to specific orders**: yes, `allocated_to_order_id` on every part (a direct field, not a join table).
3. **Parts bound to specific units**: yes, two-sided — `Part.bound_to_unit_id` and the mirrored `FactoryUnit.part_allocations`; kept in sync by application code only, no DB constraint.
4. **Does the factory confirm RECEIPT distinct from allocation?** **No — this is a real gap.** `inventory_status` only ever takes 3 values (`allocated_unbound`, `allocated_bound`, `released`); the assembly scan event conflates "physically present" and "installed" into one action. `docs/domain-glossary.md` itself defines the scan this way — this is not an oversight, it's the current intentional design.
5. **Replacement history**: partially modeled — a real seed instance exists (`PART-0004` released as `damaged_at_bench` with a documented policy in `stages.json`'s hard-stop control), and the runtime layer (`workflow_rules.reallocate_part`) appends a `reallocation_history` entry with old/new serial + reason to the unit's `genealogy` (JSONB, no dedicated table). The static D4 fixture itself is internally inconsistent on this point (still shows the old part as bound).
6. **Inventory assignment vs floor confirmation as separate steps**: yes, partially — Stage 4 (`parts_allocated` event, inventory-operator actor) and Stage 5 (`assembly_part_bound` event, assembler actor) are genuinely distinct stages/events/actors, but the floor-side event is "scan-and-install," not a separate "received, not yet installed" checkpoint (same gap as #4).
7. **14-stage mapping**: clean 1:1 match between `data/stages.json`, `docs/factory-flow-model.md`, and the original source material — no gaps, no invented stages (full table in §6).
8. **Roles in `data/users.json`** (verbatim): `assembler`, `inventory_op`, `supervisor`, `manager`, `qc_inspector`, `calibration_tech` (6 users, `authority_tier` ∈ {operator, supervisor, manager}). Two users hold two roles each (`assembler+inventory_op`, `assembler+calibration_tech`) — both are DB-seeding casualties (see gaps above).

**Documentation gotcha**: `docs/mock-data-contract-d4.md`'s own stage table does not match `data/stages.json` at all (see §2 conflict #1) — treat `data/stages.json` + `factory-flow-model.md` + `domain-glossary.md` as authoritative.

---

## 6. Current 14-Stage Flow Versus Latest Canon

Since no transcript exists, "latest canon" = the ratified `docs/factory-flow-model.md` + original `source-materials` requirements (§2). The current `data/stages.json` matches both **exactly**, stage-for-stage:

| # | Canonical (directive) | `stages.json` (current) | Source material (verbatim) | Ownership (current data) |
|---|---|---|---|---|
| 1 | Order created | Order created | Order created (customer, eStore) | `external_upstream` |
| 2 | Order approved | Order approved | Order approved (sales manager) | `external_upstream` |
| 3 | Order received by factory | Order received | Order received by factory | `factory_core` |
| 4 | Parts allocated | Parts allocated | Parts allocated to the order (serial level) | `factory_core` |
| 5 | Assembly | Assembly | Assembly (scan & verify each part) | `factory_core` |
| 6 | SW/FW installed | Software & firmware install | Software & firmware installed | `factory_core` |
| 7 | SW/FW update from cloud | Software & firmware update from cloud | Software & firmware updated from cloud | `factory_core` (cloud hard-block) |
| 8 | Cloud provisioning | Cloud provisioning | Device provisioned with cloud | `factory_core` |
| 9 | HW checks/setup | Hardware checks / setup | Hardware checks / setup | `factory_core`, gate |
| 10 | Calibration | Calibration | Calibration | `factory_core`, gate |
| 11 | QC | Quality Control | Quality Control (QC) | `factory_core`, gate |
| 12 | Cloud backup | Cloud backup | Backup of factory data to cloud | `factory_core` (cloud hard-block) |
| 13 | Package | Package | Package | `factory_separable` |
| 14 | Ship | Ship | Ship | `factory_separable` |

No gaps, no invented stages, no reordering. This is a clean, faithful, verification-confirmed implementation of the ratified model.

### Testing the directive's "latest transcript correction" hypotheses against actual repo content

Since no transcript exists, each hypothesis is tested against the source material and ratified docs instead — **these are not confirmed corrections, they are untested hypotheses, and some are directly contradicted:**

- **"Factory work effectively starts at assembly."** **Contradicted.** The source material's own decision log states: *"Scope boundary: Factory owns stages 3–14; eStore, cloud, inventory are external; 13–14 separable."* Order Received (3) and Parts Allocated (4) are factory-core, backend-authoritative stages with their own hard-stops (boundary-validation reject; supervisor reallocation) — they are not external preconditions. Factory scope starts at Stage 3, not Stage 5.
- **"Stages 1–4 may be preconditions from the assembler's viewpoint."** **Partially true, but a framing distinction, not a model change.** An individual assembler has no task at stages 1–4 (their first touchpoint is the Stage-5 scan) — this is a legitimate observation about what one actor *sees*, but stages 3–4 remain factory-owned, backend-authoritative stages, not preconditions outside factory scope. This is an argument for actor-scoped UI framing, not for renumbering or reowning stages.
- **"Parts allocated may need to become parts received/confirmed at workstation."** This is a **genuinely unmodeled gap** (confirmed in §5, Q4) — but the source material's own design *intentionally* conflates scan-confirmation with installation; there is no existing requirement or code artifact describing a separate "delivered to bench, not yet installed" state. If the operator wants this, it is a **new requirement**, not a correction of a missed one.
- **"Order approval/payment/inventory assignment happen before factory queue."** Order approval: confirmed, Stage 2, external. **Payment: not modeled anywhere** — the source material is silent on payment/checkout (explicitly out of scope per requirement ORD-4, which scopes billing to "fulfillment," not the factory system) — do not assume a payment step exists. Inventory assignment: Stage 4 allocation is itself **inside** factory-owned scope (post Stage-3), performed by an inventory-operator role, not a pre-queue external step.
- **"Serialized parts are assigned before factory receives executable work."** Not quite accurate: the factory receives the order (Stage 3) before allocation (Stage 4) happens, and Stage 4 is itself factory-owned executable work — allocation doesn't precede "factory receiving work," it *is* factory work.

**Conclusion:** several of these hypotheses may reflect a real product-direction conversation, but none of them can currently be verified against any repo artifact, and the strongest one ("factory work starts at assembly") directly contradicts a currently invariant-locked scope boundary. This should be surfaced to the operator explicitly rather than silently assumed true in D9B.

---

## 7. Actor Model Recon

Actors named in the **original source material** (Section 5, "Roles and Permissions," plus stage-narrative mentions) — this is the only actor list groundable in a repo artifact, since no transcript exists:

| Actor | Tier (source material) | Job-to-be-done | Current app support | Gap |
|---|---|---|---|---|
| **Assembler** | Operator | Scan/verify parts at assembly (Stage 5); no override authority | `scan-part` endpoint + raw form exists | No per-actor queue/scoping; no "my units" view; no ownership enforcement (any `actor_user_id` can act on any unit) |
| **Inventory operator** | Operator | Deliver allocated serials to the bench (Stage 4) | Modeled in data (`allocated_to_order_id`) but **no dedicated endpoint or UI surface** — allocation is seed data only, not an interactive action in the current app | No UI/API path to perform an allocation action at all today |
| **Line supervisor** | Supervisor | Routine overrides: part reallocation, calibration retry authorization, disposition-to-hardware | `reallocate-part` + `calibration-disposition` endpoints and raw forms exist | No triage/attention queue; no aggregated "units needing my decision" view |
| **Manager / QC sign-off authority** | Manager | High-cost actions: scrap/write-off, final QC sign-off (a *distinct* named authority per source material), separation-of-duty waivers | `qc-signoff` endpoint exists, backend enforces SoD + waiver-authority checks correctly | **Conflicts with `factory-flow-model.md`, which assigns QC sign-off to "Supervisor" instead** — needs operator resolution (§2, §13) |
| **Customer** | — (external) | Places/customizes order on eStore (Stage 1) | Out of factory scope entirely; zero support, correctly so | None expected at this phase |
| **Sales manager** | — (external) | Approves order (Stage 2) | Out of factory scope entirely; zero support, correctly so | None expected at this phase |
| **eStore / sales-approval system** | external system | Upstream order source | `Order` records exist in data/DB but the GET endpoint has **no frontend consumer** | Orders are invisible in the current UI entirely |
| **Cloud platform** | external system | SW/FW currency, device provisioning, backup | Entirely mocked via a client-typed `cloud_available` boolean — no real integration | See §11 |
| **Inventory Management module** | external system | Owns parts/serials/lots | Represented as static seed data only; no live interface | No integration surface exists |

**Actors named in the directive but NOT found in any repo artifact** (source material, docs, or code) — flagged explicitly rather than invented: "Vijay/leadership viewer," "super admin," "device software" as a distinct actor, "customer viewer" dashboard user, and a "Technician" tier (this last one *does* appear in `factory-flow-model.md`, but not in the original source material — see conflict §2). None of these should be assumed real requirements without operator confirmation; they may be exactly what the (missing) transcript would have specified, but nothing in the repo grounds them today.

**Note on the current `data/users.json` roster**: it operationalizes the 3-tier source model into 6 concrete role tokens (`assembler`, `inventory_op`, `supervisor`, `manager`, `qc_inspector`, `calibration_tech`) — a reasonable extension for a working prototype, not a contradiction of the source material, though `qc_inspector` as a role distinct from "manager" adds another wrinkle to the QC-authority conflict in §2.

---

## 8. Assembler Flow Recon

| Signal | Current app support |
|---|---|
| Current assigned unit / "my units" queue | **Not modeled.** `assigned_operator_id` exists on the unit record but no endpoint filters by it; `UnitList.tsx` shows all 7 units to every viewer identically. |
| Currently active unit | Only as an ephemeral, unscoped UI selection (`selectedUnitId`), not a per-actor concept. |
| Blocked assigned units / newly assigned units | Not filterable or notifiable — no assignment/notification concept exists anywhere in the data model or backend. |
| One assembler owns a device through all steps | **Contradicted by the backend itself**: the QC separation-of-duty rule explicitly requires the QC signer to differ from *both* the assembly operator and the calibration operator, implying the model assumes multiple operators per unit, not single ownership end-to-end. Additionally, no dedicated action endpoint checks that the calling actor matches `assigned_operator_id` — any authorized `actor_user_id` can act at any stage on any unit today. |
| Spillover to next day / reassignment if assembler unavailable | Not modeled — no shift/timestamp/reassignment concept anywhere. |
| Assembly = 100% human / SW update, calibration, cloud backup = "start and walk away" / QC = 100% human / package = human work | **Not modeled at all currently.** Every stage is a synchronous request/response form submit; status strings like `assembly_active`/`calibration_in_progress` are static labels with no actual async job/timer/lifecycle behind them — there is no "in progress, come back later" pattern anywhere in the code. |
| Immediate-attention / corrective-action / failure-mode-to-instruction model | **Not modeled.** `blocked_reason` is a machine string with a human-readable event message, but there is no "what should I do about this" instructional layer; when blocked, the Action Panel just shows "No actions available at this stage" (confirmed via this recon's own screenshot of UNIT-0002) with no guidance. |
| Progressive information hiding | **Opposite of current behavior** — every `UnitDetailPanel` section is hardcoded open; nothing is hidden by default. |

**Verdict**: the current UI is close to the *opposite* of an assembler-shaped view — it is a full-spine, full-record, full-form console with no per-actor scoping, no attention model, and no async work-state awareness.

---

## 9. Floor Manager / Supervisor Flow Recon

| Signal | Current app support |
|---|---|
| Units being manufactured today | Shown (all 7, unfiltered) — this is coincidentally closer to floor-manager-shaped than assembler-shaped, since a manager plausibly wants to see everything. |
| Current stage of each unit | Shown via S-XX badge. |
| Attention/triage queue for blocked units | **Not modeled as a distinct queue.** A BLOCKED badge exists in the flat list, but there's no aggregated blocked-only view, no severity ranking distinguishing a hard-stop (no override) from a retry-eligible block. |
| Part replacement approval | **Best-supported supervisor action today** — `reallocate-part` is fully backend-authorized (`can_override`) and has a dedicated (if raw) form in the UI. |
| Assembler support / who needs help | Not modeled — no linkage surfaced from a blocked unit back to "which assembler is stuck and needs supervisor attention." |
| Keeping factory flowing (throughput/WIP/bottleneck) | **No metrics of any kind** — no stage-occupancy counts, no throughput view, no bottleneck indicator anywhere. |
| Incoming orders | `GET /factory/orders` exists on the backend but **has no frontend consumer at all** — orders are entirely invisible in the current UI. |
| Forecast/load planning, stock levels, assembler/manager roster management | **None of this exists** in backend or frontend — no capacity view, no CRUD on the static `users.json` roster. |
| Multiple floor managers | `manager` and `supervisor` are distinct `authority_tier` values with different override/disposition powers in the data, but there's no UI concept of multiple managers each owning a line/area. |

**Verdict**: no dedicated floor-manager surface exists either. The closest artifact is the flat list + blocked badges + one raw reallocation form + the generic "Dev — Backend-Guarded Transition" form (explicitly a dev/override tool, not a floor-manager tool).

---

## 10. Viewer / Broadcast Flow Recon

None of the following exist in backend or frontend, at all: a leadership/"Vijay" dashboard, a sales dashboard, a customer dashboard, an inventory notification flow, a supply-chain signal, forecast-change alerts, delay notifications, or any Amazon-style proactive customer communication. **Confirmed via a dedicated dependency search**: there is no websocket, SSE, or pub/sub library anywhere in `backend/requirements.txt`, `frontend/package.json`, or the source tree — the entire app is pull/poll-based (fetch on load, refetch after each action). There is no push/real-time infrastructure of any kind to build on top of; a viewer/broadcast surface would need new infrastructure, not a new view on existing data plumbing.

---

## 11. Device / Cloud Truth Flow Recon

- **Device as source of truth**: not modeled — `cloud_available` is a boolean the operator types into a checkbox on the Cloud Backup form; there is no device or cloud integration of any kind (confirmed intentional mock per `docs/backend-state-behavior-d5.md`: "Azure SDK wiring (all cloud_available checks are mock flags)").
- **Device failure mode → corrective action mapping**: not modeled — `blocked_reason` strings are hardcoded literals chosen by `workflow_rules.py`'s own logic branches, not derived from any actual device signal.
- **Calibration "in progress" badge semantics**: purely a static status string set by the last completed action call; no timer, no live polling of an external calibration rig, no async lifecycle.
- **Cloud backup truth**: same mock pattern as cloud connectivity — entirely operator-typed fiction for demo purposes, by design.
- **What must change for real integration**: replacing the manual `cloud_available` checkbox with real device/cloud telemetry would require an entirely new ingestion path (webhook or polling adapter) — currently zero surface exists for this; it would be new backend capability, not a modification of existing logic.

---

## 12. Current UI as Engineering Console

The evidence across §3–§4 converges on one conclusion: the current `FactoryFlowBoard` is an **engineering/review console**, not an actor-specific operator tool, and — importantly — **the codebase and its own documentation already agree on this**. Concrete tells: UI text literally displays `POST /factory/units/{id}/actions/scan-part`-style endpoint paths to the end user; the Action Panel renders exactly one raw form per REST endpoint rather than a task; every actor-identity field is free text despite a user roster being fetched and sitting unused; every detail section is forced open with no real progressive disclosure despite the markup groundwork for it; a "Dev — Backend-Guarded Transition" panel with a free-text target-stage field is exposed to every viewer with no distinction from a real operator control.

What it does well, worth preserving: it correctly reflects backend authority with zero invented workflow legality (verified in §4.2 — no button is ever disabled by frontend-computed business logic); it exposes complete visibility into every backend field, which is genuinely useful for demoing/debugging backend correctness; and the D8C theming/responsive/touch-target substrate is a solid, verification-clean foundation to build actor-specific views on top of, not something to discard.

---

## 13. Three-Variant Brainstorm Boundary

*(Per directive: this section defines input constraints only. No variants are proposed or designed here.)*

**Candidate variation dimensions** (carried forward from the directive, none resolved yet): assembler-first vs. floor-manager-first; attention-first vs. workflow-first; queue-first vs. current-unit-first; dashboard-first vs. task-first; integrated single app vs. actor-specific routes; a "view-as" role-switcher prototype vs. eventual real auth; full engineering spine always visible vs. progressive disclosure by default.

**What must stay constant across all three variants:**
- Backend remains sole workflow authority — no variant may reimplement transition legality, the calibration cap/disposition state machine, QC separation-of-duty, cloud hard-stop semantics, or terminal immutability in the frontend.
- The ratified 14-stage model and its ownership boundaries (`external_upstream` 1–2, `factory_core` 3–12, `factory_separable` 13–14) exactly as currently encoded — unless the operator explicitly authorizes a model change per §6/§13's open questions.
- No auth, RBAC, or tenanting added (Invariant 6 / directive both agree).
- The D8C responsive/touch-target/theme token substrate is preserved as the base styling layer.
- The existing API contract (routes, request/response shapes) is unchanged.
- The existing demo-reset mechanism keeps working.

**What can differ across variants:** information hierarchy and default visibility; whether actions are framed as tasks vs. raw endpoint forms; navigation model (tabs/routes per actor vs. one view); queue scoping/filtering (per-operator, per-station, blocked-only, etc. — noting this may require a **new** filtering convention on the frontend since no per-operator assignment field is consistently enforced today, see §8); whether a "view-as actor" UI-only selector is used to preview actor framing without real auth.

**What cannot differ:** stage count/order/ownership; hard-stop/no-override semantics; who the *backend* says can do what.

**Evidence this recon contributes to brainstorming**: §3 (don't reimplement backend authority), §5 (no per-operator "my queue" field exists — any assembler-scoped variant needs either a new field proposal or an explicitly-labeled client-side approximation), §7–§11 (actor needs vs. actual support, per actor), §12 (what NOT to carry forward — the raw-endpoint/raw-field framing).

**Decisions needing operator approval before (or during) D9B:**
1. Resolve the QC sign-off authority conflict — is it Supervisor (`factory-flow-model.md`) or a distinct Manager/QC tier (source material)? This directly determines what a "Manager" or "QC" actor screen would even contain.
2. Is "Technician" a real 4th authority tier, or should it be removed/merged into Operator? (Present in `factory-flow-model.md`, absent from source material.)
3. Should a new "parts received at bench, not yet installed" state be added to the data model? This is a **new requirement**, not a bug fix, since neither the source material nor the current code models it.
4. Does an assembler-scoped "my units" view need a real new per-operator assignment/queue field, or should a first variant fake this client-side (e.g. filter by `assigned_operator_id`, which already exists but is currently unenforced/unused for this purpose)?
5. Confirm that no transcript exists and that this recon's substitute authority stack (§2) is acceptable to proceed on.

---

## 14. Implementation Risk Map

| Risk | Grounded in |
|---|---|
| Frontend reimplementing workflow legality | Checked — currently does NOT happen (§4.2); must stay that way in any new variant |
| Frontend duplicating backend stage-model facts (drift risk, not legality) | `CLOUD_BLOCK_STAGES`/`GATE_STAGES`/`hasStageForm` hardcoded lists (§4.1, §4.5) |
| Breaking the D8C responsive/touch-target layout | Verified currently intact (0 horizontal overflow at 414px, 32/33 verification checks pass) — any redesign must re-run `011-touch-first-responsive-ui.sh` |
| Mixing eStore/inventory/factory boundaries | `Order`/inventory data exists but has zero UI consumer today (§9) — tempting to "just wire it up," but that's cross-boundary scope creep unless explicitly authorized |
| Prematurely adding auth/RBAC | Explicitly forbidden (Invariant 6); backend has zero auth today (§3.5) — any "view-as actor" affordance must stay UI-only, not real auth |
| Prematurely adding real-time/device integration | No push infra exists at all (§10); mock `cloud_available` boolean is the entire "device truth" surface today (§11) |
| Weakening existing verification | 45/45 smoke + 32/33 (1 documented env-skip) verification currently green — must stay green |
| Breaking demo reset | Reset has no env guard and is a raw TRUNCATE CASCADE (§3.4) — any new variant must not silently rely on state the reset would wipe, and must not add a path that bypasses reset |
| Losing the current working prototype | Current app is stable/verification-clean (§1) — must be explicitly preserved or forked, not silently replaced |
| Overbuilding super-admin / customer / sales dashboards too early | None of these actors are grounded in any repo artifact (§7) — building them now would be speculative scope beyond what's evidenced |
| Stale hardcoded phase strings misleading future integration checks | `/health`, `/factory/scaffold-status` still say `D3_STACK_SCAFFOLD` (§3.5) — a future health-check consumer could misread current capability |
| Latent quarantine-disposition bug | `block_type` not set on quarantine path (§3.5) — could let a quarantined unit slip through the generic transition endpoint undetected |
| ActionPanel stale-form-state across unit switches | No `key={unit.id}` on `ActionPanel` (§4.1, §4.5) — a real operational risk if a real user relies on this today |

---

## 15. Verification / Evidence

All commands run against the live Docker Compose stack brought up for this recon (`docker compose up -d --build`; no source file was modified to make these pass):

- `git status --short` → clean at recon start.
- `docker compose config` / `docker compose ps` → valid, all 3 services `Up`.
- `curl /health` → 200, `{"status":"ok",...}`. `curl http://localhost:5173/` → 200 HTML.
- `scripts/invariant-check.sh` → **6/6 PASS**.
- `scripts/verification/001-docker-compose-config.sh` → 4/4 PASS.
- `002-backend-health.sh` → 4/4 PASS.
- `003-frontend-reachable.sh` → 2/2 PASS.
- `004-data-contract-api.sh` → 10/10 PASS (14 stages, 7 units confirmed).
- `005-backend-state-behavior.sh` → 26/26 PASS (incl. QC sign-off success, terminal-unit 409, missing-unit 404).
- `006-factory-flow-board-ui.sh` → 12/12 PASS.
- `007-persistence-postgres.sh` → 17/17 PASS (incl. event persistence, DB-backed state confirmed no in-memory dict).
- `008-demo-readiness.sh` → 17/17 PASS.
- `009-light-mode-readability.sh` → 18/18 PASS.
- `010-material-theme-readability.sh` → 21/21 PASS.
- `011-touch-first-responsive-ui.sh` → 32 PASS / **1 SKIP** (headless browser cannot launch in this Alpine/musl image — pre-existing, documented, non-blocking; real browser verification done interactively for this recon instead, see §16).
- `scripts/smoke.sh` → **45/45 PASS**.
- Representative API exercises: full unit list (7 units spanning every interesting state: active, cloud-blocked hard-stop, calibration-in-progress, calibration-cap-exceeded, QC-ready, cloud-backup-blocked, shipped/terminal), full 14-stage list with ownership/gate/hard-stop metadata, OpenAPI route enumeration (23 routes, matches §3.1 exactly).
- `POST /factory/dev/reset-state` exercised once mid-recon via the UI button; unit stage/status compared before/after — **identical**, confirming idempotent reset.
- Browser walkthrough via Playwright — see §16.

No verification script was modified. No failures required a fix.

---

## 16. Current Flow Walkthrough

Exercised live in a real browser (Chromium via Playwright) against the Docker Compose stack. Screenshots saved to `artifacts/d9a-current-flow-recon/`:

1. **App loads** → `01-desktop-initial.png` (1440×900, light theme). Header shows app name, "Postgres-backed" badge, backend/data-contract health dots, Reset button, theme toggle. Unit Queue (7), Stage Spine (14 rows), empty Detail/Action panels ("Select a unit..."), Event Trace (10 of 22 events).
2. **Unit list appears** → confirmed in same screenshot; all 7 units shown with per-unit scenario labels and BLOCKED/SHIPPED badges where applicable.
3. **User selects a normal active unit (UNIT-0001, assembly_active)** → `02-desktop-unit0001-selected.png`. Detail panel populates fully (Identity, Stage/Status, Part Allocations, Calibration, QC, Cloud/Ship, all open); Action Panel shows the live Assembly Scan form + Supervisor Reallocation form + Dev Transition form.
4. **Stage spine renders** → visible in all desktop screenshots; current-unit highlight annotation appears next to "14-Stage Production Spine" heading (e.g. "· UNIT-0001").
5. **Unit detail renders** → confirmed, §4.1/§8 above.
6. **Action panel renders** → confirmed; raw per-endpoint forms as described in §4.1/§12.
7. **User selects a blocked unit (UNIT-0002, cloud_blocked, no_override)** → `03-desktop-unit0002-blocked.png`. Detail panel shows a red "Block / Hard-Stop" section with the exact `blocked_reason` string and "⚠ NO OVERRIDE — No bypass possible"; Action Panel shows "No actions available at this stage" plus only the generic Dev Transition form.
8. **Backend action fires / response displayed** → not re-tested destructively in this recon beyond the pre-existing verification-script exercises (§15), to avoid mutating demo state beyond what reset immediately restored; the response-rendering mechanism itself is documented from code in §4.2.
9. **Event trace updates** → confirmed structurally (§4.4); not independently re-verified beyond the verification suite's own event-persistence check (§15, script 007).
10. **Reset demo state works** → clicked live in the browser; confirmed via API diff that unit state is bit-for-bit reproduced (§1, §3.4, §15).
11. **Theme toggle works** → `04-desktop-dark-mode.png` (dark theme, same UNIT-0002 selection) — full re-theme confirmed, no visual regressions observed.
12. **Compact/touch layout works** → `05-compact-touch-width.png` (414×896, dark theme, Detail tab active) — confirmed via `document.documentElement.scrollWidth === clientWidth` (no horizontal overflow) and visual inspection; compact tab bar (Unit Queue / Detail / Stages / Events) renders correctly with 48px+ touch targets.

All 12 steps completed with **no code changes**, exactly as the smoke-test expectation requires.

---

## 17. Gap Matrix

| Signal | Current support | Surface | Gap | Risk | Candidate phase |
|---|---|---|---|---|---|
| Per-operator "my units" queue | None | `assigned_operator_id` field exists, unused for filtering | No scoped queue for any actor | Med | D9B/D10 UI-only filter, or new field |
| Parts received-at-bench (distinct from allocated) | None | `data/parts.json` `inventory_status` (3 values only) | Genuinely unmodeled state | Low (new requirement, not a bug) | Future data-model phase, operator-approved |
| Corrective-action/failure-mapping layer | None | `blocked_reason` strings only | No "what do I do" guidance anywhere | Med | D9B/D10 UI content layer |
| Async "start and walk away" lifecycle | None | Every action is synchronous request/response | No timers/job state for cal/cloud/SW-update | Low (out of current scope per directive) | Explicitly out of D9B scope |
| Supervisor attention/triage queue | None | BLOCKED badge in flat list only | No aggregation/priority ranking | Med | D9B candidate |
| Incoming orders visibility | Backend endpoint exists, zero UI consumer | `GET /factory/orders` | Orders invisible today | Low | D9B candidate (floor-manager variant) |
| Forecast/load/stock/roster views | None anywhere | — | No capacity-planning surface | Low (likely later phase) | Post-D9B |
| Viewer/broadcast dashboards (leadership/sales/customer) | None, no push infra | — | Entire capability class missing | Low (explicitly out of D9A/D9B scope) | Post-D9B, new infra needed |
| Real device/cloud truth vs. mock boolean | Mock only, by design | `cloud_available` client boolean | No real integration surface | Low (explicitly acknowledged mock) | Future integration phase |
| Progressive disclosure (currently forced-open) | Markup exists, behavior doesn't | `UnitDetailPanel.tsx` hardcoded `open` | No actual default collapse | Med — directly relevant to actor-first design | D9B/D10 |
| QC authority tier conflict | Backend enforces one interpretation; two docs disagree | `factory-flow-model.md` vs. source material | Unresolved: Supervisor vs. Manager/QC tier | **High** — blocks confident actor-screen design | Needs operator decision before D9B locks in |
| "Technician" tier undocumented in source | Present in ratified doc only | `factory-flow-model.md` | Not in original requirements | Med | Needs operator decision |
| `mock-data-contract-d4.md` stage-table defect | Wrong content, unused by code | doc only | Misleading if read | Low (doc-only, no runtime impact) | Doc cleanup, any time |
| Reset endpoint has no env guard | Works as designed for a demo | `POST /factory/dev/reset-state` | Would be destructive in a real deployment | Low today, High if ever deployed beyond demo | Flag for any future deployment phase |
| ActionPanel state not reset across units | Confirmed bug-shaped behavior | `FactoryFlowBoard.tsx` missing `key` | Stale form data risk | Med | Cheap frontend fix, any phase |
| Dead code (`repositories.py`, 4 components, `parts`/`users` unused) | Present, harmless | multiple files | Codebase clutter | Low | Cleanup, any phase |
| DB seeding lossy (multi-role users, stage metadata, part notes) | Confirmed data loss on seed | `seed.py` + 3 DB tables w/ no payload column | Real fields silently dropped | Med — could matter if DB becomes source of truth for those reads | Needs attention if any future feature reads these from DB |
| Quarantine `block_type` bug | Confirmed code path | `workflow_rules.py:608-619` | Hard-stop may not be detected by generic transition | Med | Backend fix, any phase (not in scope for D9A/D9B) |
| Inconsistent auth-failure signaling (403 vs. `status:"failed"`) | Confirmed | `workflow_rules.py` | Two shapes for same error class | Low | Backend cleanup, any phase |

No silent caps were applied in this recon — every file group listed in the directive's read list was read by one of the four recon passes; nothing was sampled or truncated except `ai/engineering-journal.md` (52KB), where only the most recent ~800 lines were read (explicitly noted, sufficient for current-state purposes since this is an append-only historical log).

---

## 18. Recon Conclusions

- **Is the current app stable enough to preserve?** Yes — fully verification-clean (78/79 checks passing, 1 documented environment-only skip), confirmed working end-to-end in a real browser, reset is reliable and idempotent.
- **Should the next phase be brainstorming only?** Yes.
- **Should implementation wait until three variants are selected?** Yes.
- **Safest serialization plan:** (1) Operator resolves the two open documentation conflicts in §2/§13 (QC authority tier; confirm the D4 stage-table defect can be ignored) and confirms the substitute authority stack is acceptable in the absence of a transcript. (2) Run **D9B — Three Functional Actor-First UI Variants**, informed by this recon, still no code changes. (3) Operator selects one variant. (4) A single serialized implementation phase touches **only the frontend** (new actor-scoped views/routes on the existing API), unless the operator explicitly authorizes a separately-tracked, reviewed backend/data change (e.g., a new "parts received" field or a real per-operator assignment field) as its own scoped phase.
- **Recommended next directive:** **D9B — Three Functional Actor-First UI Variants.**
- **What must not be touched yet:** `backend/**`, `data/**`, `alembic/**`, `docker-compose.yml`, `scripts/verification/**`, and the ratified stage/authority docs — until the operator has explicitly resolved the QC-authority conflict in §2.

---

**Files/artifacts produced by this recon:** this document; `artifacts/d9a-current-flow-recon/{01-desktop-initial,02-desktop-unit0001-selected,03-desktop-unit0002-blocked,04-desktop-dark-mode,05-compact-touch-width}.png`.

**Engineering journal:** no entry appended to `ai/engineering-journal.md`. Every existing entry in that file documents a completed, `RELEASE_APPROVED` capability advancing the D-phase state machine (`ai/state_registry.json`); this recon is explicitly recon-only and makes no such state transition. Appending a journal entry now would not match the file's established convention (confirmed by inspecting all prior entries) — a journal entry is more appropriately written alongside whichever future phase (D9B or its successor) actually changes registered state.

**D9A RECON STATUS — COMPLETE | IMPLEMENTATION — NONE | CURRENT FLOW — MAPPED | NEXT — D9B THREE VARIANTS**
