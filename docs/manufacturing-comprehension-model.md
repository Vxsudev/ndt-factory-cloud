# Manufacturing Comprehension Model — ndt-factory-cloud

**Status:** CANONICAL — OPERATOR_LOCKED THROUGH D9E-0; IMPLEMENTED BY D9E-1
**Phase:** D9E-1 — Canonical Stage, Failure, Recovery, and Authority Model
**Date:** 2026-07-14
**Predecessor:** `ai/recon/d9e-0-manufacturing-comprehension-recon.md` (RECON_APPROVED — READY_FOR_D9E-1)

This document is the single, governed source for manufacturing stage, failure, recovery,
authority, and comprehension-classification truth in this repository. It is a **canonical
comprehension model**, not backend executable configuration — `docs/factory-flow-model.md` remains
the sole authoritative source for stage definitions, transition rules, and control gates
(Product Invariant 1); this document explains that frozen model in comprehension terms and must
never contradict it. Later D9E nodes (D9E-2 through D9E-7) must consume this document rather than
deriving stage/failure/recovery/authority semantics independently from scattered UI conditionals.

---

## 1. Authority and Scope

This document's authority is derived entirely from `ai/recon/d9e-0-manufacturing-comprehension-
recon.md`'s evidence base and the operator's binding decision-lock continuation recorded in that
artifact's §25 (C1–C8, all `OPERATOR_RESOLVED`), §27 (screen comprehension contract,
`OPERATOR_LOCKED`), §28 (three-axis semantic model, `OPERATOR_LOCKED`), and §31/§37 (the D9E-0…
D9E-7 DAG, `OPERATOR_LOCKED`). It does not introduce new manufacturing behavior, new failure modes,
new recovery paths, or new actor authority — it canonicalizes what D9E-0 already found as FACT/
DERIVATION and resolves only the specific documentation drift the operator authorized (D9E-0 §25).

**In scope:** the 14-stage production spine, the 3-gate model, all 22 evidence-backed failure
modes, every documented recovery path, the actor/role/authority model, the composable three-axis
semantic model, the serialized-traceability chain, and the boundaries between documented,
implemented, UI-available, and TBD truth.

**Erratum (recorded during D9E-1 execution, operator-resolved):** D9E-0 reported 21 normalized
failure entries; a direct row-level recount during D9E-1 execution established **22**. The
discrepancy was an arithmetic/catalog-counting error in D9E-0's summary prose, not a newly
discovered manufacturing condition — `FM-WRONG-STAGE` and `FM-AUTH-INSUFFICIENT` were always
separately present and independently evidence-backed in D9E-0 §11 (distinct triggers, distinct raw
codes/response shapes, distinct recovery paths). This is a bookkeeping correction only: it does not
reopen any of D9E-0's C1–C8 operator resolutions, add a manufacturing rule, expand capability, or
authorize any backend/frontend change. `ai/recon/d9e-0-manufacturing-comprehension-recon.md` (the
pushed, immutable D9E-0 artifact) is not modified — its original "21" figure remains there as
historical evidence of what was originally reported. 22 is canonical from this document forward.

**Out of scope:** any change to `data/*.json`, `backend/app/**`, `frontend/**`, or
`source-materials/**`; any new failure mode, recovery path, or actor capability; any fix to D-1
through D-10 (assigned to D9E-2); any UI rendering, design token, or in-application copy (D9E-3/
D9E-5); any demo-narrative or review-shell guidance surface (D9E-4).

## 2. Source Hierarchy

1. Operator decisions recorded in D9E-0 §25/§27/§28/§31/§37 — highest authority for anything this
   document classifies or corrects.
2. `docs/factory-flow-model.md` (FROZEN, D2A + D9E-1 errata) — sole authority for stage
   definitions, transition rules, and control gates.
3. `source-materials/digital-factory-requirements-v1/` (BRS + flowchart) — original business
   intent; used to resolve ambiguity.
4. `backend/app/workflow_rules.py`, `data/*.json` — implementation truth (read-only reference;
   unmodified by this document).
5. `frontend/src/**` (shared view model, Current, Attention-First, Workflow-First, Command-Center)
   — UI-availability truth.
6. `ai/recon/d9e-0-manufacturing-comprehension-recon.md` — the evidence trail connecting all of the
   above; cited throughout this document by section number.

## 3. Canonical Terminology

Full term definitions live in `docs/glossary.md` (new, additive, 15 terms — Gate, Hard block, No
override, Waiting on external dependency, Rework, Retry, Disposition, Quarantine, Scrap, Serialized
allocation, Bound serial, Genealogy, Terminal/immutable, QC authority, Separation of duty). This
document uses those terms consistently and additionally defines two comprehension-model-specific
vocabularies used throughout: the **Documented-vs-Implemented classification** (§8) and the
**three-axis semantic model** (§13).

## 4. Fourteen-Stage Model

All 14 stages, in canonical order. Category/gate status per `docs/factory-flow-model.md` (as
corrected by this node's errata — see that document's D9E-1 errata notes). Every field below is
FACT, traced to D9E-0 §10 (re-verified fresh for this node, §6 of the D9E-1 recon — no drift
found).

| # | Canonical ID | Display name | Category | Owner | Gate? |
|---|---|---|---|---|---|
| 1 | STAGE-01 | Order Created | external_upstream | Customer / Sales (eStore) | No |
| 2 | STAGE-02 | Order Approved | external_upstream | Sales Manager | No |
| 3 | STAGE-03 | Order Received | factory_core | Factory System (boundary validation) | No (boundary hard-stop, no override) |
| 4 | STAGE-04 | Parts Allocated | factory_core | Inventory Operator | No |
| 5 | STAGE-05 | Assembly | factory_core | Assembler | No (5 named hard-stops, no bench override) |
| 6 | STAGE-06 | Software & Firmware Install | factory_core | Technician (Operator-tier role) | No |
| 7 | STAGE-07 | Software & Firmware Update from Cloud | hard_block_dependency | System / Cloud | No (no-override hard block) |
| 8 | STAGE-08 | Cloud Provisioning | factory_core | System | No |
| 9 | STAGE-09 | Hardware Checks / Setup | **gate** | Technician (Operator-tier role) | **Yes — Gate 1** |
| 10 | STAGE-10 | Calibration | **gate** | Calibration Technician (Operator-tier role) | **Yes — Gate 2** |
| 11 | STAGE-11 | Quality Control | **gate** | QC Inspector (distinct QC authority) | **Yes — Gate 3** |
| 12 | STAGE-12 | Cloud Backup | hard_block_dependency | System / Cloud | No (no-override hard block) |
| 13 | STAGE-13 | Package | factory_separable | Operator | No |
| 14 | STAGE-14 | Ship | terminal | Operator / Manager | No (terminal) |

### Per-stage detail (entry / work / inputs / traceability / success / forward transition / failures / recovery / retry / override / authority / consequence / terminal effect / audit / data availability / demonstrability / semantic classification / sources / TBDs)

**S-01 Order Created.** Entry: none (upstream origin). Work: customer customizes and orders on
eStore. Inputs: none from the factory. Traceability: none yet. Gate: no. Success → S-02. Failures:
none documented in-factory scope. Recovery: n/a. Retry: n/a. Override: n/a. Authority: external
(Customer/Sales). Consequence: none in-factory. Terminal effect: n/a. Audit: none (pre-factory).
Frontend data: `GET /factory/orders` exists, exposes `id/source_system/approval_status/...`, **not
consumed by the shared view model** (D9E-0 §21, C8 resolved: remains outside plan). Demonstrability:
actor-variant — No; Current — No (orders invisible everywhere, D9A §9). Semantic classification:
Manufacturing State — n/a (pre-factory); Constraint — n/a; Ownership — external (Customer/Sales).
Sources: BRS §2/§4.0; `data/orders.json`. TBDs: none stage-specific.

**S-02 Order Approved.** Entry: order created. Work: sales manager approval (BRS: e.g. export
restrictions). Inputs: order fields. Traceability: `approved_by`/`approved_at` recorded on the
order. Gate: no. Success → S-03. Failures: none in-factory scope. Recovery/Retry/Override: n/a.
Authority: external (Sales Manager). Consequence/Terminal/Audit: none in-factory. Frontend data:
same as S-01 — unconsumed. Demonstrability: No / No. Semantic: same as S-01 (external, n/a).
Sources: BRS §4.0.

**S-03 Order Received.** Entry: approved order handed to factory. Work: boundary validation — ORD-1
required fields present, ORD-2/ORD-3 known-model check against the recipe registry. Inputs: order
fields, recipe registry. Traceability: unit(s) provisioned with `genealogy_serial` on acceptance.
Gate: no (a hard-stop control, not a gate — `stages.json` `boundary_validation_hardstop`, `no_override:
true`). Success → S-04. **Failure: FM-S03-REJECT** (§6) — missing field or unknown model → order
rejected, reason reported upstream. Recovery: upstream order correction and re-submission —
**documented but no runtime order-intake endpoint exists in the current backend** (rejection exists
only as seed data, `ORDER-0003`). Retry: n/a (order-level, not unit-level). Override: none
(`no_override: true`). Authority: system automatic; correction owned by upstream (eStore/Sales).
Consequence: order never reaches the floor. Terminal effect: n/a (no unit exists to terminate).
Audit: `EVT-0022` (error severity, seeded). Frontend data: as S-01/S-02. Demonstrability: No / No.
Semantic: Manufacturing State — n/a (order-scoped); Constraint — Blocked + No override; Ownership —
external (upstream). Sources: BRS ORD-1/2/3, MDL-1; `data/stages.json` STAGE-03; D9E-0 §10 row 3.
TBDs: none new (see §18 T5-family note — no, T5 is Stage-7-specific; this stage's recovery-endpoint
absence is recorded here as its own gap, not a numbered D9E-0 TBD, since D9E-0 did not TBD-tag it
explicitly — flagged here for completeness, not a new capability).

**S-04 Parts Allocated.** Entry: order accepted. Work: Inventory Operator reserves specific serials
(ALLOC-1) and delivers to bench. Inputs: inventory serials matching the order's model recipe.
Traceability: `Part.allocated_to_order_id`; unit `part_allocations{type→part_id,status}`; genealogy
`parts_allocated`. Gate: no (control type `reallocation`, `no_override:false`, `halts_order:false`).
Success → S-05. **Failure: FM-S04-REALLOC-NEEDED** — allocated serial unusable (damaged/lost/failed-
at-bench/reprioritized) or no replacement available (flowchart HOLD state, unmodeled in current
data). Recovery: Supervisor reallocation (`reallocate-part` — `can_override` required); releases old
serial with a reason code, binds new serial, retains both in genealogy. **Implementation note**:
`workflow_rules.reallocate_part` is **not stage-gated** — it is callable at any non-terminal stage,
broader than the BRS's S-04/S-05 framing (recorded as TBD T8, §18). Retry: unlimited (supervisor may
reallocate again if the replacement also fails). Override: none required beyond `can_override`
capability itself. Authority: Supervisor. Consequence: bench waits for replacement; order is paced,
not halted. Terminal effect: n/a. Audit: `supervisor_reallocation` event. Frontend data: `part_
allocations`, `vm.parts` fully available. Demonstrability: actor-variant — **structurally present in
all three `*ActionForm.tsx` files, but currently unreachable via live seed data** since no unit ever
carries a persisted Stage-5 block (see S-05 below) — classify as `IMPLEMENTED_BUT_UI_UNAVAILABLE`
via live click-path (verified only via synthetic fixtures per the D9C/D9D remediation); Current —
**Yes, live**: `ActionPanel`'s "Supervisor Reallocation" form renders for any unit at Stage 5
(e.g. UNIT-0001, not blocked) and is directly usable today. Semantic: Manufacturing State — Active
(unit paced, not halted); Constraint — Warning (recoverable); Ownership — Waiting on Supervisor.
Sources: BRS ALLOC-1..5; `data/stages.json` STAGE-04; D9E-0 §10 row 4, §11 FM-S04-REALLOC-NEEDED.

**S-05 Assembly.** Entry: parts at bench. Work: Assembler scans each serialized part, binding
("marrying") it to the unit's genealogy (ASM-3). Inputs: allocated serials. Traceability: scan sets
`alloc.status=allocated_bound`, `part.bound_to_unit_id`, `genealogy.parts_bound`, and (side effect)
`assembly_operator_id`/`assigned_operator_id`/`station_id`. Gate: no (5 hard-stops, no gate
disposition/rework loop — a rescan, not a gate re-entry). Success → S-06 (via generic `transition`,
no dedicated "assembly complete" action). **Failures (5, ASM-1):** `unknown_serial`, `wrong_part_
type` (×2 code paths), `already_used_serial` (×2 code paths), `wrong_serial_for_allocated_slot`; a
sixth, **`out_of_sequence`, is declared in `data/stages.json`'s `trigger_cases` but has no
`workflow_rules.py` implementation** (`DOCUMENTED_NOT_IMPLEMENTED` — §18 T2). Recovery: correct part
re-scanned (no state change needed — each reject is transient, never persisted to the unit);
supervisor reallocation if the part itself is wrong/lost (see S-04). Retry: unlimited. Override:
**none at the bench** (ASM-2, matches BRS explicitly). Authority: Assembler (rescan); Supervisor
(reallocation). Consequence: assembly step blocked until resolved. Terminal effect: n/a. Audit:
`assembly_scan_rejected`/`assembly_scan_accepted` events. Frontend data: full scan-reject detail in
`ActionResponse` + events; **never written to the persisted unit record** (`blocked_reason` is set
only transiently for the one rejected call). Demonstrability: actor-variant — **No** (scan action is
entirely absent from all three variants' action-form mapping; and because rejects are never
persisted, a "blocked at Stage 5" unit cannot exist in any queue/triage regardless); Current — **Yes,
live** (Assembly Scan form, e.g. against UNIT-0001). Semantic: Manufacturing State — Active;
Constraint — Blocked (transient, per-call) — **No override**; Ownership — Action required from you
(Assembler) or Waiting on Supervisor (if reallocation needed). Sources: BRS ASM-1/2/3; `data/
stages.json` STAGE-05; `backend/app/workflow_rules.py:109-207`; D9E-0 §10 row 5, §11
FM-S05-*, §24 defect note (D9D remediation: serialized reallocation logic fixed to resolve a real
part serial, verified via synthetic fixtures since the live click-path is unreachable).

**S-06 Software & Firmware Install.** Entry: assembly complete. Work: flash pinned validated
factory baseline (SW-1/2); no cloud identity yet. Inputs: recipe `firmware_baseline`. Traceability:
genealogy `sw_baseline_installed_at`. Gate: no. Success → S-07 (generic transition only — no
dedicated action). Failure: **`TBD — NO AUTHORITATIVE FAILURE MODE FOUND`** (§18 T1) — `stages.json`
declares `hard_stop_controls: []`; do not invent a generic failure. Recovery/Retry/Override/
Authority/Consequence/Terminal/Audit: n/a (no failure mode to recover from). Frontend data: recipe
`firmware_baseline` served by `GET /factory/model-recipes`, zero consumers. Demonstrability: No /
No (stage name only, in Current's spine and variant Assembler cards). Semantic: Manufacturing State
— Active; Constraint — n/a; Ownership — n/a. Sources: BRS SW-1/2; D9E-0 §10 row 6.

**S-07 Software & Firmware Update from Cloud.** Entry: baseline installed. Work: confirm device
holds latest production SW/FW (SW-3). Inputs: cloud reachability. Traceability: none beyond block
fields. Gate: no (`hard_block_dependency` category, not a gate — no disposition/rework loop, only a
binary block/pass). Success → S-08. **Failure: FM-S07-CLOUD-BLOCK** — cloud unreachable → **hard
block, no override** (SW-4/SW-5, `docs/stages.json`'s own `decision_note`: "Production throughput is
intentionally coupled to cloud availability at stage 7... chosen deliberately"). Seed: UNIT-0002
permanently blocked (`cloud_unreachable_sw_update_cannot_proceed`); `EVT-0004` (critical),
`EVT-0005` floor alert (critical). Recovery: **conceptually**, cloud returns and the system
re-checks — **no backend endpoint or frontend action exists for Stage 7 at all** (no `POST .../
actions/*` route, no WR function). This means the seeded blocked unit is not recoverable except via
full demo reset (§18 T5). Retry: n/a (no action exists). Override: **none** (BRS explicit,
`no_override: true`). Authority: nobody on the factory floor — this is a management-decision hard
block, not an authority gap. Consequence: unit(s) wait; floor alerted. Terminal effect: n/a. Audit:
seeded critical events only (no live event generation possible). Frontend data: `blocked_reason`/
`block_type`/`no_override` fully available; `stages.json`'s `decision_note` text (the actual
management-decision rationale) is served by `GET /factory/stages` and **rendered nowhere**. 
Demonstrability: actor-variant — partial (the block *state* is visible and correctly shown with NO
OVERRIDE in all three variants; **no recovery action exists to demonstrate**, and the Assembler
copy "Needs floor manager approval — visible in the Floor Manager triage list" is **factually
incorrect** for this condition — no FM action exists either, corrected disposition: D9E-2, D-defect
family; not fixed by this document); Current — same (block state shown, "No actions available at
this stage"). Semantic: Manufacturing State — Waiting; Constraint — Blocked + No override;
Ownership — Waiting on external system / cloud; Actionability — No action available here (no
recovery endpoint exists). Sources: BRS SW-3/4/5; `data/stages.json` STAGE-07 (`decision_note`
verbatim); `data/factory_units.json` UNIT-0002; D9E-0 §10 row 7, §25 C4 (operator-resolved).

**S-08 Cloud Provisioning.** Entry: SW/FW current. Work: create cloud identity, credential
separate from genealogy serial, 1:1, rotatable (PROV-1..3). Inputs: cloud. Traceability: concept
of credential↔serial binding (not separately modeled as a field). Gate: no. Success → S-09.
**Failure: none canonical** — `DOCUMENTED_CONFLICT_RESOLVED_OUT` (§18; D9E-0 §25 C3, operator-
resolved): the only source ever naming a Stage-8 failure was the frozen `docs/factory-flow-
model.md`'s own hard-stop table ("Cloud provision failure (S-08) → Supervisor"), which had no
support in the BRS, flowchart, `stages.json`, or `workflow_rules.py`, and has been corrected as
part of this node's errata (§9 of the D9E-1 recon; that document's hard-stop table). **Do not
invent Stage-8 failure copy, behavior, recovery, or demo coverage of any kind.** Recovery/Retry/
Override/Authority/Consequence/Terminal/Audit: n/a. Frontend data: `cloud_status.provisioned`
boolean. Demonstrability: No / No. Semantic: Manufacturing State — Active; Constraint — n/a;
Ownership — n/a. Sources: BRS PROV-1..3; D9E-0 §10 row 8, §25 C3.

**S-09 Hardware Checks / Setup — GATE 1.** Entry: provisioned. Work: config-driven checks against
the ordered model recipe (HW-1/2, MDL-1) — verifies built unit matches order. Inputs: model recipe
(`hardware_checks` list with per-check `pass_criteria`). Traceability: `gate_results["STAGE-09"]`
records checks performed. Gate: **yes — Gate 1 of 3** (errata-corrected; `docs/factory-flow-
model.md` previously mistyped this as `factory core` — D9E-0 §25 C1, operator-resolved). Success →
S-10, `hw_gate_passed`. **Failure: FM-S09-GATE-FAIL** — gate result=fail (missing/unexpected
hardware) → rework, re-enters S-09 (flowchart RW9; `stages.json fail_reentry_stage_id: STAGE-09`).
`blocked_reason` set to the free-text reason or `hardware_gate_failed`; **`block_type` is NOT set on
this path** (a known implementation defect, D-2, assigned to D9E-2 — not fixed here). Recovery:
resubmit `hardware-gate` with `result=pass` — **any caller may resubmit; WR does not check authority
or a retry cap for this gate** (no documented cap; BRS is silent). Retry: unlimited. Override: none
(rework is not an override; genuine correctness fix required). Authority: Technician (Operator-tier
role) performs the check and resubmit; no authority enforcement in code. Consequence: unit loops at
S-09 until checks pass. Terminal effect: n/a. Audit: `hardware_gate_passed`/`hardware_gate_failed`
events. Frontend data: `gate_results["STAGE-09"]` incl. checks array; recipe `hardware_checks` list
unconsumed. Demonstrability: actor-variant — **No** (Stage 9 has no mapped action in any of the
three `*ActionForm.tsx` files; a runtime-failed unit would appear in Floor Manager triage showing
only the truthful "No resolution action is available in this comparison view."); Current — **Yes**
(Hardware Gate form). Semantic: Manufacturing State — Rework; Constraint — Blocked; Ownership —
Action required from you (Technician) — recovery-eligible, not externally blocked. Sources: BRS
GATE-1/2, HW-1/2, MDL-1; `data/stages.json` STAGE-09 (`is_gate: true`); D9E-0 §10 row 9, §25 C1.

**S-10 Calibration — GATE 2.** Entry: hardware gate passed. Work: validate reference standard(s),
then run calibration; capture full record (CAL-1: reference standards used incl. cert ID/expiry,
raw readings, resulting coefficients, equipment/fixture ID, operator, timestamp, environmental
conditions, firmware version at calibration time — all listed verbatim in `stages.json`'s
`calibration_metadata.record_captured`). Inputs: valid reference standard(s), equipment ID.
Traceability: certificate `CERT-D5-<unit>-ATT<n>`; every attempt (pass or fail) retained in
`attempt_history`. Gate: **yes — Gate 2 of 3**. Success → S-11, `calibration_passed`, `gate_
results["STAGE-10"]` set. **Failures (3):**
- **FM-S10-REFSTD** — any selected standard unknown, expired, or lacking a valid certificate →
  **hard-stop, no override** (CAL-3), transient per-call (`no_override:true`, not persisted to the
  unit). Two seeded invalid standards exist (`REFSTD-0002` expired, `REFSTD-0003` missing cert)
  alongside one valid (`REFSTD-0001`).
- **FM-S10-ATTEMPT-FAIL** — attempt fails, attempts < 3 → warning event, remaining-attempts count
  (CAL-4). Seeded: UNIT-0003 at 2/3.
- **FM-S10-CAP** — 3rd failed attempt → **cap exceeded**, persisted `blocked_reason=calibration_
  cap_exceeded_supervisor_disposition_required`, `block_type=calibration_retry_cap` (CAL-5). Seeded:
  UNIT-0004.

Recovery: (ref-std) obtain a valid standard, re-attempt — pre-check re-runs each attempt; (attempt-
fail) retry, same stage; (cap) **Supervisor/Manager disposition required** — §9/§12 for the three
outcomes. Retry: attempts capped at 3 per production run (max_attempts, seed default); ref-std
pre-check has no cap (may be retried indefinitely once a valid standard is loaded). Override: none
for the ref-std hard-stop; disposition is not an override, it is a mandatory decision. Authority:
Calibration Technician (attempts); Supervisor (route-back/quarantine); Manager (scrap) — see §10.
Consequence: unit halted at various severities depending on which failure. Terminal effect: scrap
disposition only. Audit: `calibration_ref_std_hardstop`/`calibration_attempt_failed`/`calibration_
cap_exceeded`/`calibration_passed` events, plus disposition events (§9). Frontend data: full
`calibration_summary` incl. `attempt_history` (rendered only in Current's Detail panel — history
itself never shown); 3 reference standards fully available (`vm.refStandards`) — variant forms
auto-select a usable one rather than surfacing the choice, making the ref-std hard-stop
undemonstrable through the variant UI. Demonstrability: actor-variant — attempt-fail/cap/
disposition **Yes** (all three variants, post-D9D always-visible-calm-action correction); ref-std
hard-stop **No** (auto-selection bypasses it); Current — **Yes**, all failures including ref-std
(free-text ref-std ID field allows selecting an invalid standard deliberately). Semantic:
ref-std — Manufacturing State: Active; Constraint: Blocked + No override; Ownership: Action
required from you (load a valid standard). attempt-fail — Manufacturing State: Active; Constraint:
Warning; Ownership: Action required from you (retry). cap — Manufacturing State: Waiting;
Constraint: Approval required; Ownership: Waiting on Supervisor or Manager (§9 disposition
outcomes). Sources: BRS CAL-1..6; `data/stages.json` STAGE-10 (full `calibration_metadata`); `data/
reference_standards.json`; D9E-0 §10 row 10, §11 FM-S10-*.

**S-11 Quality Control — GATE 3.** Entry: calibration passed, certificate present. Work: QC
Inspector verifies physical unit + complete digital record (QC-1: 8 checks listed verbatim in
`stages.json`'s `qc_metadata.checks` — physical/cosmetic condition, correct labeling and serial,
accessories and seals, digital record complete and consistent, genealogy complete, calibration
certificate generated, every prior required gate passed, required regulatory documents present).
Inputs: hardware-gate pass, calibration certificate. Traceability: `qc_summary` records signer,
timestamp, any waiver. Gate: **yes — Gate 3 of 3**. Success → S-12, **finalizes the production
record** (QC-3; Product Invariant 5) — `blocked_reason` cleared. **Failures (2 transient prerequisite
classes, 1 documented-not-implemented):**
- **FM-S11-PREREQ** — hardware gate not passed / calibration gate not passed / certificate missing
  → transient block, no event emitted (audit gap, §18 T7).
- **FM-S11-SOD** — signer is the same person who performed assembly or calibration on this unit →
  refused unless a Manager waiver is supplied (RBAC-3/4); waiver is logged in `qc_summary` and the
  event payload.
- **FM-S11-QC-FAIL** (BRS RW11: cosmetic/doc/record-gap failure → QC rework/disposition, re-enter
  S-11) — **`DOCUMENTED_NOT_IMPLEMENTED`** (§18 T3): no reject/fail action exists for QC in the
  current backend at all; only sign-off exists. This is a genuine capability gap, not a UI gap —
  **do not simulate or imply QC rework anywhere.**

Recovery: complete the missing prerequisite gate; use a different signer, or obtain a Manager
waiver (SoD). Retry: unlimited (prerequisites); n/a (SoD — requires a different signer or waiver,
not a retry). Override: waiver is Manager-tier only, always logged — not a bypass, an accountable
exception. Authority: **QC Inspector** (distinct QC authority — never Supervisor, never Manager
directly) signs off; Manager may waive SoD. Consequence: sign-off refused until resolved.
Terminal effect: pass finalizes the record (post-QC, no field/stage/scan/calibration-record may be
modified except as a new audit entry under Manager authority — Product Invariant 5). Audit: `qc_
signoff_complete` event (records waiver if used); no event for prerequisite refusals (T7). Frontend
data: `qc_summary` fully available. Demonstrability: actor-variant — **No** (Stage 11 has no mapped
action in any variant; UNIT-0005, seeded "QC ready," shows no action anywhere in Attention-First/
Workflow-First/Command-Center); Current — **Yes** (QC Sign-Off form, though its checklist is
hardcoded to 2 items client-side regardless of the real 8-item `qc_metadata.checks` list — a
presentation simplification, not a data gap). Semantic: prerequisite/SoD — Manufacturing State:
Active; Constraint: Approval required; Ownership: Waiting on QC (prerequisite) or Waiting on Manager
(SoD waiver). Sources: BRS QC-1/2/3, RBAC-2/3/4; `data/stages.json` STAGE-11 (`qc_metadata`
verbatim); D9E-0 §10 row 11, §25 C2 (QC-distinctness preserved), §26 T3, T7.

**S-12 Cloud Backup.** Entry: QC passed. Work: back up full production record (genealogy,
calibration record, certificate, test results — `stages.json`'s own list) to cloud before the unit
may leave the floor (BK-1/2). Inputs: cloud reachability (`cloud_available` — **client-supplied
boolean, intentionally mocked**, not a real connectivity check). Traceability: `cloud_status`
fields. Gate: no (`hard_block_dependency`, same category as S-07 — binary block/confirm, no
disposition/rework loop). Success → S-13, block fields cleared. **Failure: FM-S12-CLOUD-BLOCK** —
backup cannot complete → **hard block, no override** (BK-2, `stages.json`'s `decision_note`: "A
device must not leave the floor until its irreplaceable record is preserved off-site... accepted
deliberately"). Seeded: UNIT-0006. Recovery: **resubmit `cloud-backup` with `cloud_available:
true`** once connectivity returns — this is a **re-check, not a Supervisor override**; no authority
check exists or is required (D9E-0 §25 C4, operator-resolved — corrects `docs/demo-walkthrough-
d8.md`'s prior "supervisor clears the block" language, fixed in this node's errata). Retry:
unlimited (any actor may resubmit). Override: **none** (BRS explicit — the *retry* is not an
override; it is the documented recovery path itself). Authority: any actor (no capability check in
`record_cloud_backup`). Consequence: unit cannot package/ship until backed up. Terminal effect:
n/a. Audit: `cloud_backup_hard_stop`/`cloud_backup_confirmed` events. Frontend data: `cloud_status`
+ block fields fully available; `decision_note` unrendered (same gap as S-07). Demonstrability:
actor-variant — **Yes** (all three variants: "Retry Cloud Backup," the one flagship cross-variant
action verified live in the D9D addendum); Current — **Yes** (checkbox form). Semantic:
Manufacturing State — Waiting; Constraint — Blocked + No override; Ownership — Waiting on external
system / cloud; Actionability — **Retry available after connectivity returns** (the directive's own
locked worked example, reproduced verbatim in §13). Sources: BRS BK-1/2; `data/stages.json`
STAGE-12 (`decision_note` verbatim); `data/factory_units.json` UNIT-0006; D9E-0 §10 row 12, §25 C4,
§28 (locked example).

**S-13 Package.** Entry: backup confirmed. Work: package device for shipment. Inputs: none beyond
stage gating. Traceability: genealogy `packaged_at`. Gate: no. Success → S-14. Failure:
**`TBD — NO AUTHORITATIVE FAILURE MODE FOUND`** (§18 T1b) — no documented or implemented failure
exists; do not invent one. Recovery/Retry/Override/Authority/Consequence/Terminal/Audit: n/a beyond
the normal event. Frontend data: `package_ship_status.packaged`. Demonstrability: actor-variant —
No (unmapped); Current — Yes (Package form). Semantic: Manufacturing State — Active; Constraint —
n/a. Sources: BRS SHIP-1/3; D9E-0 §10 row 13.

**S-14 Ship — TERMINAL.** Entry: packaged. Work: record ship status; attach certificate + docs
(SHIP-1). Inputs: QC signed off AND cloud backed up (WR re-checks both as a second gate at this
stage). Traceability: genealogy `shipped_at`; `package_ship_status.terminal/immutable = true`.
Gate: no (terminal, not a disposition gate). Success → **SHIPPED** (terminal). **Failures
(prerequisite, transient):** `qc_not_passed`, `cloud_backup_not_confirmed` — refused until the
missing prerequisite completes; no event emitted (T7, same gap as S-11 prerequisites). After
terminal: **any further action on this unit → HTTP 409** (all `workflow_rules.py` mutating actions
check `_is_terminal()`). A second terminal-family status, **`rejected`**, is defined by `_is_
terminal()`'s own check and referenced in `docs/factory-flow-model.md`'s Terminal States table, but
**no code path in the entire backend ever sets a unit to `rejected`** — `DOCUMENTED_NOT_
IMPLEMENTED` (§18 T4). Recovery: complete the missing prerequisite (pre-terminal only); nothing
post-terminal. Retry: n/a post-terminal. Override: none — terminal immutability is absolute
(Product Invariant 6). Authority: Operator/Manager (ship form defaults `USER-MGR-0001`, no
enforced check). Consequence: pre-terminal, ship refused; post-terminal, permanent record.
Terminal effect: **this is the terminal effect** — record immutable, no further mutation of any
kind permitted. Audit: `unit_shipped` event; no event for the two prerequisite refusals (T7).
Frontend data: `package_ship_status` fully available; `document_refs` accepted by the ship action
but never displayed anywhere. Demonstrability: actor-variant — terminal units are **filtered out of
every variant queue/strip entirely** (no ship action anywhere in variants, and no way to view a
shipped unit's terminal state there at all); Current — Yes (TERMINAL/SHIPPED banners; a live 409
demo is available via the always-present Dev Transition form). Semantic: pre-terminal —
Manufacturing State: Active; Constraint: Approval required (prerequisites). Post-terminal —
Manufacturing State: Shipped; Constraint: Terminal / immutable; Ownership: No action available
here. Sources: BRS SHIP-1..4; Product Invariant 6; D9E-0 §10 row 14, §26 T4.

## 5. Three-Gate Model

Canonical gates, in stage order: **Gate 1 = Stage 9 (Hardware Checks)**, **Gate 2 = Stage 10
(Calibration)**, **Gate 3 = Stage 11 (Quality Control)**. This is the complete and exclusive set —
no other stage is a gate (S-03's boundary hard-stop and S-07/S-12's cloud hard blocks are
`hard_block_dependency`/boundary categories, not gates: they have no pass/fail disposition-and-
rework loop, only a binary block/proceed outcome). `docs/factory-flow-model.md`'s prior typing of
Stage 9 as `factory core` was stale and has been corrected by this node's errata (D9E-0 §25 C1,
operator-resolved). This correction is documentation-only — `backend/app/workflow_rules.py`'s
actual pass/fail/rework behavior for Stage 9 was already correctly implemented as a gate; only the
frozen document's classification text was wrong.

## 6. Failure-Mode Catalog

All 22 evidence-backed entries from D9E-0 §11, canonicalized (count corrected from D9E-0's
originally-reported 21 — see the erratum in §1 above; `FM-WRONG-STAGE` and `FM-AUTH-INSUFFICIENT`
are independently evidence-backed and appear here as two separate rows, never merged). Stable
comprehension identifiers
(the `FM-*` family) are established here as canonical for comprehension purposes — they are a
**mapping layer over real backend codes**, never a replacement (§7). Each entry's full narrative
(trigger, plain-language title, consequence, recovery, authority, audit) is documented in context
in §4 above (per-stage) and is not repeated here in full prose; this table is the flat index with
the classification fields the directive requires.

| Canonical ID | Stage | Persistence | `DOCUMENTED_VS_IMPLEMENTED` | Semantic axes (State / Constraint / Ownership) |
|---|---|---|---|---|
| FM-S03-REJECT | 3 | n/a (order-scoped) | `IMPLEMENTED_SEEDED_ONLY` | n/a / Blocked+No override / external |
| FM-S04-REALLOC-NEEDED | 4/5 | Persistent (part record) | `IMPLEMENTED_AND_REACHABLE` | Active / Warning / Waiting on Supervisor |
| FM-S05-UNKNOWN-SERIAL | 5 | Transient | `IMPLEMENTED_TRANSIENT_ONLY` | Active / Blocked, no override / Action required from you |
| FM-S05-WRONG-TYPE | 5 | Transient | `IMPLEMENTED_TRANSIENT_ONLY` | same as above |
| FM-S05-ALREADY-USED | 5 | Transient | `IMPLEMENTED_TRANSIENT_ONLY` | same as above |
| FM-S05-WRONG-SERIAL-FOR-SLOT | 5 | Transient | `IMPLEMENTED_TRANSIENT_ONLY` | same as above |
| FM-S05-OUT-OF-SEQ | 5 | — | `DOCUMENTED_NOT_IMPLEMENTED` | TBD |
| FM-S07-CLOUD-BLOCK | 7 | Persistent (seeded only) | `IMPLEMENTED_SEEDED_ONLY` | Waiting / Blocked+No override / Waiting on external system / cloud |
| FM-S09-GATE-FAIL | 9 | Persistent (reason only, no `block_type` — D-2) | `IMPLEMENTED_AND_REACHABLE` | Rework / Blocked / Action required from you |
| FM-S10-REFSTD | 10 | Transient | `IMPLEMENTED_TRANSIENT_ONLY` | Active / Blocked+No override / Action required from you |
| FM-S10-ATTEMPT-FAIL | 10 | Persistent (attempt counter) | `IMPLEMENTED_AND_REACHABLE` | Active / Warning / Action required from you |
| FM-S10-CAP | 10 | Persistent | `IMPLEMENTED_AND_REACHABLE` | Waiting / Approval required / Waiting on Supervisor or Manager |
| FM-S10-QUARANTINE | 10 (disposition) | Persistent (no `block_type` — D-1) | `IMPLEMENTED_AND_REACHABLE` | Quarantined / Blocked / No action available here (T6) |
| FM-S10-SCRAP | 10 (disposition) | Persistent (terminal) | `IMPLEMENTED_AND_REACHABLE` | Scrapped / Terminal, immutable / No action available here |
| FM-S11-PREREQ | 11 | Transient, no event (T7) | `IMPLEMENTED_TRANSIENT_ONLY` | Active / Approval required / Waiting on QC |
| FM-S11-SOD | 11 | Transient | `IMPLEMENTED_TRANSIENT_ONLY` | Active / Approval required / Waiting on Manager |
| FM-S11-QC-FAIL | 11 | — | `DOCUMENTED_NOT_IMPLEMENTED` | TBD |
| FM-S12-CLOUD-BLOCK | 12 | Persistent | `IMPLEMENTED_AND_REACHABLE` | Waiting / Blocked+No override / Waiting on external system / cloud |
| FM-S14-PREREQ | 14 | Transient, no event (T7) | `IMPLEMENTED_TRANSIENT_ONLY` | Active / Approval required / Waiting on QC or external (cloud) |
| FM-TERMINAL-IMMUTABLE | any | Persistent (permanent) | `IMPLEMENTED_AND_REACHABLE` | Shipped/Scrapped / Terminal, immutable / No action available here |
| FM-WRONG-STAGE | any dedicated action | Transient — request-scoped; unit unchanged | `IMPLEMENTED_TRANSIENT_ONLY` | Active / Warning / Action required from you — use the action valid for the unit's actual stage |
| FM-AUTH-INSUFFICIENT | reallocation / disposition / QC / waiver | Transient — request-scoped; unit unchanged | `IMPLEMENTED_TRANSIENT_ONLY` | Active / Approval required / Waiting on Supervisor, Manager, or QC according to the action; no action available to the current actor |

**Count confirmation:** exactly **22** rows. `FM-WRONG-STAGE` (a dedicated action called against a
unit not at that action's required stage — a workflow-position failure) and `FM-AUTH-INSUFFICIENT`
(the calling actor lacks the required capability/authority for the action — an authorization
failure) are independently evidence-backed, carry different triggers, different raw codes/response
shapes (`wrong_stage` vs. `insufficient_authority`/HTTP 403 — see §7), and different recovery paths
(perform the correct action at the correct stage, vs. use an appropriately authorized actor or
escalate). They are not the same condition and are never merged. **This corrects D9E-0's originally
reported count of 21** (§1 erratum) — an arithmetic/catalog-counting error discovered during this
capability's own execution, reported to the operator per this spec's AC-4, and resolved by the
operator as a bookkeeping correction only (no new manufacturing condition, no reopened C1–C8
conflict). No entry beyond this correction was added, removed, or merged during canonicalization.

## 7. Raw-Code Mapping

Canonical comprehension identifiers are a mapping **layer**, never a replacement, over the real
backend `blocked_reason` strings and event types in `backend/app/workflow_rules.py`. Where one raw
code has a single, unambiguous meaning, the mapping is 1:1. Two context-dependent cases exist:

| Canonical ID | Raw code(s) | Context dependency |
|---|---|---|
| FM-S05-UNKNOWN-SERIAL … FM-S05-WRONG-SERIAL-FOR-SLOT | `unknown_serial`, `wrong_part_type`, `already_used_serial` (×2 distinct trigger paths — WR:143-150 and WR:162-168), `wrong_serial_for_allocated_slot` | `already_used_serial` is raised from two different WR code paths (part already bound to another unit, vs. this unit's slot already bound) — same raw string, same canonical ID, distinguishable only by which `_scan_reject` call site raised it (payload differs) |
| FM-S10-QUARANTINE | `quarantined: <reason>` (free-text reason interpolated into the raw string) | The raw `blocked_reason` string is not a fixed enum value — it always begins `quarantined:` followed by the disposition's free-text `reason` field; the canonical ID matches on the prefix, not exact string equality |
| FM-S10-SCRAP | `scrapped_after_calibration_cap: <reason>` | Same free-text-suffix pattern as quarantine |
| FM-WRONG-STAGE | `wrong_stage` | Raised identically by every dedicated action (`scan_part`, `record_hardware_gate`, `record_calibration`, `qc_signoff`, `record_cloud_backup`, `package_unit`, `ship_unit`) when called against a unit not at that action's required stage — one raw code, context is "which action was called," not stage-specific |
| FM-AUTH-INSUFFICIENT | `insufficient_authority` (HTTP 200 + `status:"failed"`) **or** HTTP 403 (no `blocked_reason` string at all) | Two entirely different response shapes for the same underlying meaning — `reallocate_part`'s insufficient-authority path returns 200/`failed`; `qc_signoff`/`record_calibration_disposition`/waiver-authority paths raise HTTP 403 with a detail string, not a `blocked_reason`. This shape inconsistency is itself catalogued as implementation defect D-4 (D9E-2 scope) — the canonical ID covers both, the raw-code table does not paper over the inconsistency |

All other canonical IDs map 1:1 to a single, unambiguous raw `blocked_reason` value (or, for
`FM-S03-REJECT`, the order's `boundary_validation_status`/`rejection_reason` fields; for
`FM-S11-PREREQ`, one of three distinct prerequisite strings each mapping to the same canonical ID
since all three share identical semantics — missing prerequisite gate — differing only in *which*
prerequisite; for `FM-S14-PREREQ`, two distinct strings, same pattern).

## 8. Documented-vs-Implemented Classification

Eight values, used consistently throughout §4 and §6, never invented ad hoc:

| Value | Meaning |
|---|---|
| `IMPLEMENTED_AND_REACHABLE` | Real backend code exists, persists to the unit record (or is otherwise durable), and is reachable through normal live operation (via Current and/or a variant) without synthetic setup. |
| `IMPLEMENTED_SEEDED_ONLY` | The condition exists in seed data and backend logic recognizes it, but no runtime code path creates or clears it from a fresh/normal state — only the seed produces it. |
| `IMPLEMENTED_TRANSIENT_ONLY` | Real backend code exists and returns a correct per-call `ActionResponse`, but never persists to the unit record — it cannot appear in any queue, triage, or badge; it is only visible in the response of the specific call that triggered it. |
| `IMPLEMENTED_BUT_UI_UNAVAILABLE` | Real, persisted, reachable backend behavior exists, but no actor-variant UI surface (Attention-First/Workflow-First/Command-Center) exposes an action or view for it — only Current can demonstrate it. |
| `DOCUMENTED_NOT_IMPLEMENTED` | The BRS, flowchart, or `data/stages.json` documents the condition, but no corresponding backend code exists at all. |
| `DOCUMENTED_CONFLICT_RESOLVED_OUT` | A prior document (typically the frozen `docs/factory-flow-model.md` before this node's errata) asserted the condition, but no other source or the implementation supports it — the operator has resolved it as non-canonical (D9E-0 §25). |
| `DATA_UNAVAILABLE` | The explanatory data itself does not exist anywhere in the backend/data surfaces (used at the data-availability level, §17, rather than per-failure — no failure entry in §6 currently requires this value, since all 22 entries have real evidence one way or another). |
| `TBD` | Authoritative evidence is genuinely absent and the condition cannot be classified with confidence by any of the above (used for the un-implemented-and-undocumented remainder captured in §18, not for named failure entries, which all resolve to one of the other seven values). |

A behavior is never called "supported" merely because a document describes it (`DOCUMENTED_NOT_
IMPLEMENTED` exists precisely to prevent that), and never called "missing" when it is intentionally
excluded (`DOCUMENTED_CONFLICT_RESOLVED_OUT` exists precisely to prevent that).

## 9. Recovery-Path Catalog

Every evidence-backed recovery path, classified by kind (true manufacturing recovery / retry /
rework loop / approval-disposition / demo-only reset), current executability, actor/authority,
resulting state, and audit consequence:

| Recovery | Kind | Executable today? | Actor/authority | Resulting stage/state | Audit |
|---|---|---|---|---|---|
| S-03 upstream order correction | Manufacturing recovery (order-level) | **No** — no runtime order-intake endpoint | Upstream (eStore/Sales) | order re-submitted, re-validated | none (no runtime path) |
| S-04 serialized reallocation | True recovery | Yes | Supervisor | same stage, new serial bound | `supervisor_reallocation` |
| S-04 no-replacement waiting (HOLD) | Waiting state | **No** — unmodeled in current data (flowchart-only) | n/a | n/a | n/a |
| S-05 correct-part re-presentation | Retry | Yes | Assembler | same stage, part bound | `assembly_scan_accepted` |
| S-05 Supervisor reallocation | True recovery | Yes (structurally; live click-path unreachable per §4) | Supervisor | same stage | `supervisor_reallocation` |
| S-07 cloud-return re-check | Manufacturing recovery (conceptual) | **No** — no endpoint exists | n/a (would be system/cloud) | would be S-08 | none (cannot occur) |
| S-09 hardware rework + gate re-entry | Rework loop | Yes | Technician | re-enters S-09, then S-10 on pass | `hardware_gate_passed`/`failed` |
| S-10 ref-std re-presentation | Retry (pre-check) | Yes | Calibration Technician / Supervisor (obtains standard) | same stage, pre-check re-run | none until next attempt event |
| S-10 calibration retry (below cap) | Retry | Yes | Calibration Technician | same stage, attempt++ | `calibration_attempt_failed`/`_passed` |
| S-10 route back to hardware | Rework loop (disposition) | Yes | Supervisor | S-09, attempts reset 0/3 | `calibration_disposition_rework` |
| S-10 quarantine | Approval/disposition | Yes (entry only — no exit, T6) | Supervisor | quarantined (non-terminal, dead-end) | `unit_quarantined` |
| S-10 scrap | Approval/disposition (terminal) | Yes | Manager | scrapped (terminal) | `unit_scrapped` |
| S-11 prerequisite completion | True recovery | Yes | owner of the missing gate | — | none emitted (T7) |
| S-11 separation-of-duty correction / waiver | Approval/disposition | Yes | different QC signer, or Manager (waiver) | S-12 | `qc_signoff_complete` (waiver recorded) |
| S-11 QC rework | Rework loop (documented) | **No** — capability absent (T3) | n/a | n/a | n/a |
| S-12 backup retry after connectivity returns | Retry (re-check, not override) | Yes | any actor | S-13 | `cloud_backup_confirmed` |
| S-14 prerequisite completion | True recovery | Yes | owner of missing prerequisite | — | none emitted (T7) |
| Terminal immutability | n/a (absolute) | n/a — nothing to recover, by design | n/a | n/a | 409 on any attempt |
| Demo reset | **Demo-only mechanism, not a manufacturing recovery** | Yes (`POST /factory/dev/reset-state`) | demo operator | full reseed to canonical scenarios | none (truncate + reseed) |
| FM-WRONG-STAGE correction | Request correction / retry (not a stage/state change itself) | Yes | Same actor, using the action valid for the unit's actual stage; that action's own authority requirement still applies | Unit unchanged by the rejected request itself; once the corrected action is performed, that action's own resulting stage/state applies (see its own row above) | None for the rejected request itself — every `wrong_stage` response is returned via `_blocked_response()` with no `event_id`, so no audit event is emitted (`backend/app/workflow_rules.py:118-121, 345-348, 400-403, 633-636, 735-738, 846-849, 878-881`, all seven dedicated actions). The corrected action, once performed, emits that action's own normal audit event per its own row above |
| FM-AUTH-INSUFFICIENT handoff | Authorized-actor handoff / approval | Yes | Depends on the specific action — **not uniformly Manager**: Supervisor (`can_override`) for reallocation; Supervisor or Manager per `disposition_authority` for calibration disposition; QC Authority (`can_qc_signoff`) for QC sign-off; Manager (`can_waive_separation_of_duty`) for separation-of-duty waiver | Unit unchanged by the denied request itself; the eventual successful action's own resulting stage/state applies (see its own row above) | None for the denied request itself — `reallocate_part`'s insufficient-authority path returns HTTP 200/`status:"failed"` with no event created (`workflow_rules.py:220-230`); the disposition/QC-signoff/waiver paths raise HTTP 403 before any event is created (`workflow_rules.py:547-563, 639-646, 685-689`). The eventual successful action, once performed by an actor who holds the required authority, emits that action's own normal audit event per its own row above |

**Completeness confirmation:** with the two rows above, this catalog now includes a recovery path for
every canonical ID in §6, including the two request-level failures (`FM-WRONG-STAGE`,
`FM-AUTH-INSUFFICIENT`) that apply across multiple stages rather than to one stage alone — closing
the gap between this section's "every evidence-backed recovery path" claim and §6's failure catalog.

## 10. Actor/Role/Authority Model

**Canonical UI actors** (the two logins the transcript and D9B settled on): **Assembler**;
**Floor Manager**.

**Canonical operational roles** (distinct from UI actors and from authority tiers): Assembler;
Technician / Calibration Technician; Floor Manager / Supervisor; Manager; QC Inspector.

**Canonical system/external actors:** Customer; Sales; eStore / upstream order system; Inventory;
Cloud / external dependency; automated factory system.

**Canonical rules (operator-locked, D9E-0 §25 C2):**

- UI actor, operational role, and action authority are three distinct concepts. A UI actor (e.g.
  "Floor Manager") may exercise a role (e.g. "Supervisor") that carries specific authority (e.g.
  `can_override`); the three must not be conflated in explanatory copy.
- **Technician is a role, not a fourth authority tier.** The authority model has exactly three
  tiers: Operator, Supervisor, Manager — plus the **distinct QC authority**, which is not a tier in
  the Operator→Supervisor→Manager hierarchy at all (see §11).
- **QC authority is distinct from Supervisor and Manager.** Only the QC Inspector role may sign off
  Quality Control; neither Supervisor nor Manager authority implies QC-signoff authority (confirmed
  in seed data: `USER-MGR-0001` has `can_qc_signoff: false`).
- **Manager authority does not imply QC-signoff authority** — restated for emphasis, since it is
  the most commonly mis-assumed authority relationship in this model.
- Internal seed `authority_tier` values (`operator`/`supervisor`/`manager`) are implementation
  details, not user-facing vocabulary — later UI copy must express authority as a required
  capability or a named decision-owner (e.g. "requires Manager authorization"), never surface the
  raw tier string.
- Separation of duty (§11) remains canonical and is never weakened by any authority simplification.
- No new UI actor view is authorized by this document.

**Authority-to-action matrix** (derived from `backend/app/workflow_rules.py`'s actual enforcement,
re-confirmed unchanged since D9E-0 §13):

| Action | Enforced authority requirement | Enforcement mechanism |
|---|---|---|
| Assembly scan | none | no check |
| Reallocate part | `can_override` capability | 200/`failed` if absent (shape inconsistency, D-4) |
| Hardware gate | none | no check |
| Calibration attempt | none | no check |
| Calibration disposition | `disposition_authority` list (route/quarantine = Supervisor; scrap = Manager) | HTTP 403 if absent |
| QC sign-off | `can_qc_signoff` (QC Inspector only) | HTTP 403 if absent |
| QC SoD waiver | `can_waive_separation_of_duty` (Manager only) | HTTP 403 if absent |
| Cloud backup | none | no check |
| Package / Ship / Transition | none | no check |

## 11. QC Separation-of-Duty Model

The QC signer for a unit must not be the same person who performed assembly (`assembly_operator_id`
/ `genealogy.assembly_operator_id`) or calibration (`gate_results["STAGE-10"].operator`) on that
same unit (RBAC-3). A Manager may waive this rule for a specific unit, with a recorded
justification — the waiver itself becomes part of the unit's permanent audit record
(`qc_summary.waiver_by`/`waiver_reason`, plus the `qc_signoff_complete` event payload), never a
silent bypass (RBAC-4). QC authority itself remains categorically distinct from Supervisor and
Manager authority (§10) — separation of duty is a check *within* the QC action, not a statement
about who may hold QC authority.

## 12. Floor Manager versus Manager Rule

**Operator-locked canonical presentation rule (D9E-0 §25 C5):**

- Floor Manager may route a calibration-cap unit back to hardware.
- Floor Manager may quarantine a calibration-cap unit.
- **Scrap requires Manager authorization.**
- Floor Manager screens must not silently execute Scrap as an unlabeled Floor Manager action —
  today, all three actor-first variants' Floor Manager triage forms submit disposition/reallocation
  actions using fixed demo-actor constants including `USER-MGR-0001` for Scrap, without presenting
  this to the viewer as a Manager-tier decision (catalogued as comprehension gap G-A1, D9E-0 §24).
- **Later UI must present Scrap as "Manager authorization required."** This document defines the
  rule; it does not implement the presentation change — that belongs to the D9E node that consumes
  this model for copy/labeling (D9E-2, per the defect disposition in §24 of D9E-0 and §18 below).
- The real Manager-tier Scrap operation remains demonstrable through Current, where the acting
  identity and backend authority check are directly visible in the raw request/response.
- No Manager actor view is added by this document or authorized for any later node without a new,
  explicit operator directive.

This document documents the rule; it does not modify `frontend/src/components/variant-review/**`
in any way — zero application code changed by D9E-1.

## 13. Three-Axis Semantic Model (composable, OPERATOR_LOCKED)

Reproduced verbatim from D9E-0 §28 (`OPERATOR_LOCKED`), the canonical classification vocabulary
used throughout §4 and §6:

**Axis 1 — Manufacturing State:** Active · Waiting · Rework · Quarantined · Completed · Shipped ·
Scrapped.

**Axis 2 — Constraint:** Warning · Blocked · No override · Approval required · Terminal / immutable.

**Axis 3 — Ownership and Actionability:** Action required from you · Waiting on Supervisor ·
Waiting on Manager · Waiting on QC · Waiting on external system / cloud · Retry available · No
action available here.

**Rules:** the axes are composable, not mutually exclusive — a single condition carries one value
from each applicable axis simultaneously. Stage 7 and Stage 12 must never be flattened into a
single generic "blocked" state — each carries its own state/constraint/ownership triple, distinctly
(demonstrated per-stage in §4). Classification describes operational *meaning*, not *priority*; the
single current attention tier (T10, §18) is unaffected and orthogonal to this model. No backend
field is introduced by this classification — every value in §4/§6 derives from fields and rules
already established as FACT in D9E-0 §10–§14/§21 and re-confirmed in this node's recon.

**Locked worked example — Stage 12 cloud-backup failure** (reproduced exactly, per directive):

| Axis | Value | Derivation |
|---|---|---|
| Manufacturing state | Waiting | unit remains at S-12, has not advanced |
| Constraint | Blocked + No override | `blocked_reason=cloud_backup_cannot_complete_connectivity_unavailable`, `no_override=true` |
| Ownership | Waiting on external system / cloud | `block_type=hardstop_cloud_dependency`, no floor-owned action exists per BRS BK-2 |
| Actionability | Retry available after connectivity returns | `cloud-backup` action remains callable with `cloud_available=true`; resubmission is a re-check, not an override |

Forward destination after successful backup: **Stage 13, Package.**

## 14. Serialized-Traceability Model

Canonical chain: **physical part serial → order allocation → unit binding → genealogy record →
reallocation history (retaining old and new serials) → calibration history → QC finalization →
cloud backup → immutable terminal record.**

- **Allocated vs. bound:** a part is `allocated_unbound` once reserved for an order/unit (Stage 4)
  and becomes `allocated_bound` once scan-confirmed and installed at Assembly (Stage 5, "marrying").
- **Why physical serial identity matters:** the genealogy record is the permanent, legally
  significant build history of a regulated instrument (BRS §1.2) — it is the "system of record for
  what was built, how it was built, who built it, and whether it is fit to ship."
- **Why replacement cannot erase history:** a Stage-4/5 reallocation releases the old serial with a
  reason code and binds a new one, but **both** remain in `genealogy.parts_bound`/`reallocation_
  history` — the record shows what was originally reserved and what actually shipped, never one or
  the other.
- **How old and new serials remain traceable:** `genealogy.reallocation_history` retains an entry
  per swap: timestamp, actor, part type, old serial, new serial, reason, release reason code.
- **How calibration attempts remain internally retained:** every attempt (pass or fail) is appended
  to `calibration_summary.attempt_history`; only the passing certificate is the clean, shippable
  record — the full internal history is retained alongside it, never erased (CAL-6).
- **How QC finalizes the record:** QC pass (Stage 11) freezes the production record (Product
  Invariant 5) — no field, stage, or annotation may be modified afterward except as a new,
  Manager-authorized audit entry that never overwrites the original.
- **How terminal immutability protects the record:** once a unit reaches Shipped or Scrapped
  (Rejected remains unreachable, T4), every mutating backend action refuses with HTTP 409 —
  absolute, no exception, no authority level bypasses it (Product Invariant 6).

**Current demo simplifications/limitations (recorded, not corrected by this document):** UNIT-0006
and UNIT-0007 carry empty `part_allocations`/`genealogy.parts_bound` in seed data despite having
passed QC — a demo shortcut that would contradict QC-1's "genealogy complete" check if narrated
literally (D9E-0 §14, G-D6 gap family); BRS's eight named serial-worthy sub-assemblies (X-ray tube,
Detector, DPP, SOM, MCB, Battery pack, BMS board, Chassis) are represented in seed/recipe data by
six more generic part types (DETECTOR_MODULE, POWER_SUPPLY, MAINBOARD, CHASSIS, SECONDARY_DETECTOR,
WIFI_MODULE) — a naming simplification, recorded as TBD T9 (§18), not resolved here. No data was
altered to investigate or correct either point.

## 15. Terminal-State Model

Three terminal states are named in `docs/factory-flow-model.md`: **Shipped** (Stage 14, successful
completion), **Rejected** (gate/calibration failure — **defined but never reachable through any
current code path**, T4), **Scrapped** (Manager-tier disposition, Stage 10 only in the current
implementation). Once any unit reaches a terminal state, its production record is immutable — no
stage transition, field modification, or annotation is permitted, enforced absolutely by
`_is_terminal()` checks across every mutating backend action (Product Invariant 6). Terminal
status is presented inconsistently in the current UI: `UnitList.tsx`'s badge set has only `SHIPPED`
(keyed on `package_ship_status.terminal`) and `BLOCKED` — a **scrapped unit would incorrectly
display the green "SHIPPED" badge**, since the badge text is hardcoded while its trigger condition
is the generic `terminal` flag (implementation defect D-6, assigned to D9E-2; documented here, not
fixed).

## 16. Demo-Availability Classification

Per-unit demo-scenario availability from actor-first variants vs. Current, reconciled against the
directive's named flowchart scenario families (D9E-0 §19, re-confirmed unchanged):

| Scenario family | Actor-variant demonstrable? | Current demonstrable? | Seeded unit |
|---|---|---|---|
| Normal assembly | No | Yes | UNIT-0001 |
| Serialized mismatch / reallocation | Structurally present, live-unreachable (synthetic-fixture-verified only) | Yes | UNIT-0001 (Stage 5, not blocked) |
| Cloud SW/FW update block (S-07) | Yes (block state); no recovery to demonstrate (none exists) | Yes | UNIT-0002 |
| Hardware rework (S-09) | No | Yes | (produced by failing S-09 in Current) |
| Calibration retry (S-10) | Yes | Yes | UNIT-0003 |
| Calibration-cap disposition (S-10) | Yes | Yes | UNIT-0004 |
| QC ready / sign-off (S-11) | No | Yes | UNIT-0005 |
| QC rework (S-11) | **No — capability does not exist anywhere** (T3) | **No — capability does not exist anywhere** | n/a |
| Cloud-backup block (S-12) | Yes (flagship cross-variant action) | Yes | UNIT-0006 |
| Shipped terminal (S-14) | Terminal units filtered from every variant queue | Yes | UNIT-0007 |

**Net result (unchanged from D9E-0 §19):** 3 of 9 scenario families are fully demonstrable inside
the actor-first variants (calibration retry, calibration-cap disposition, cloud-backup block/
retry); 2 partially (cloud SW/FW block shows state but not recovery; serialized reallocation is
code-present but live-unreachable); 4 are Current-only (normal assembly, hardware rework, QC ready,
shipped terminal); 1 (QC rework) is demonstrable nowhere because it does not exist. **Per the
operator-resolved C7 decision (D9E-0 §25): do not widen actor-variant action mappings to close this
gap. The demo narrative (D9E-4) hands off to Current for the four Current-only beats.**

## 17. Data-Availability Boundaries

Reproduced from D9E-0 §21 (unchanged; re-confirmed no drift): actor identity and personal unit
assignment are `NOT_AVAILABLE` (no auth/session exists); stage names/descriptions/`hard_stop_
controls`/`decision_note`/calibration & QC metadata are `AVAILABLE_DIRECTLY` via `GET /factory/
stages` and are the single highest-value, currently-unrendered surface in the entire application
(D9E-0 G-C2); order/model-recipe context is `AVAILABLE_ONLY_IN_BACKEND` and explicitly **not** to be
wired into the shared view model under the current plan (C8, operator-resolved); stock/staffing/
roster data is `NOT_AVAILABLE` anywhere; failure→instruction mapping content is `AVAILABLE_ONLY_
IN_DOCUMENTATION` (this document and the BRS) rather than a backend lookup table — later UI copy
work (D9E-3) may draw prose from this document's §4/§6, but must not fabricate a backend capability
that does not exist. No datum's unavailability authorizes backend or data expansion under this
document or any currently-locked D9E node.

## 18. TBD Register

All 12 D9E-0 TBDs, carried forward with an explicit disposition per the directive's required
questions (affects D9E-1? mentionable in later UI? excluded from demo claims? requires a future
capability?):

| # | TBD | Affects D9E-1? | Later UI may mention it? | Excluded from demo claims? | Requires future capability? |
|---|---|---|---|---|---|
| T1 | S-06/S-13 failure modes: none authoritative | No — documented here as `TBD — NO AUTHORITATIVE FAILURE MODE FOUND` | Only to say "no failure mode is documented" if ever asked; never invent one | Yes | Only if a future BRS revision defines one |
| T2 | S-05 `out_of_sequence` declared, unimplemented | No | May mention as documented-not-implemented | Yes | Yes (backend implementation) |
| T3 | S-11 QC rework/fail path absent | No | May mention as documented-not-implemented; must never be simulated | Yes, absolutely | Yes (new backend capability) |
| T4 | `rejected` terminal state unreachable | No | May mention as defined-but-unreachable | Yes | Yes (a code path must set it) |
| T5 | S-07 recovery endpoint absent | No | May state "no recovery endpoint exists today" | Yes | Yes (new backend endpoint) |
| T6 | Quarantine exit path absent | No | May state "no exit path exists today" | Yes | Yes (new disposition/action) |
| T7 | No events for QC-prereq/ship-prereq/S-11-SoD refusals | No | Not typically UI-facing; an audit-completeness note only | n/a (backend gap) | Possibly (event-emission addition) |
| T8 | `reallocate-part` not stage-gated | No | Not typically UI-facing | n/a | No — may be intentional; flagged, not acted on |
| T9 | BRS sub-assembly naming vs. demo part types | No | Later copy should use the demo's actual part-type names, not invent the BRS's eight names | n/a | No — a naming/presentation decision only |
| T10 | Future attention-severity taxonomy deferred | No | Single attention tier remains canonical; do not introduce tiers | n/a | Yes, if ever authorized |
| T11 | BRS `.docx` original vs. `.md`/`.json` twins | No | n/a | n/a | No — accepted source hierarchy |
| T12 | Verification-script pass status at exact HEAD | **Yes — freshly measured in §Verification of this capability's execution, not assumed from any prior session** | n/a | n/a | n/a |

## 19. Explicit Exclusions

This document does not implement, and no later node may treat as authorized by this document: any
UI component, page, or rendering change; any backend route, model, or workflow-rule change; any new
data, seed scenario, failure mode, recovery path, or actor view; authentication of any kind;
widened actor-variant action mappings (C7); orders/recipes wiring into the shared view model (C8);
design tokens or in-application explanatory copy (D9E-3/D9E-5 territory); demo-narrative or
review-shell guidance UI (D9E-4 territory); fixes to any of D-1 through D-10 (D9E-2 territory).

## 20. Downstream Consumption Contract for D9E-2 through D9E-7

- **D9E-2 (Manufacturing Truth and Presentation Hardening)** must consume §6/§8 (classification),
  §12 (Floor-Manager/Manager rule), and the D-1/D-2/D-5/D-6/D-7/D-8/D-10 disposition from D9E-0 §24
  when correcting those defects — it may not invent new failure/recovery behavior while doing so.
- **D9E-3 (Design System and Content Language)** must build its semantic tokens directly from §13's
  three axes and its copy directly from §4/§6's plain-language content — it may not introduce a
  fourth axis, a severity ranking, or terminology not defined in `docs/glossary.md`.
- **D9E-4 (Demo Narrative and Review-Shell Guidance)** must script around §16's demonstrability
  ceiling (hand off to Current for the four Current-only scenario families) rather than assume
  wider variant coverage.
- **D9E-5 (Shared Explanatory UI Primitives)** must respect §17's data-availability boundaries —
  no primitive may imply order/stock/staffing data is available.
- **D9E-6 (Cross-Screen Application)** must apply primitives/copy consistent with §10/§11/§12's
  authority model — no screen may present Scrap as Floor Manager authority, and no screen may
  conflate QC with Supervisor or Manager.
- **D9E-7 (First-Time-User Comprehension Audit)** must audit against the OPERATOR_LOCKED contract
  in D9E-0 §27, using this document as the ground truth for what a screen is permitted to claim.

No later node may claim more than this document authorizes.

## 21. Source Citations

`ai/recon/d9e-0-manufacturing-comprehension-recon.md` §10–§14, §21, §24–§28, §31, §37;
`ai/recon/d9e-1-canonical-manufacturing-comprehension-model.md` (this node's own recon);
`source-materials/digital-factory-requirements-v1/Digital_Factory_Requirements.md` (BRS v1.0,
2026-06-16); `source-materials/digital-factory-requirements-v1/Digital_Factory_Flowchart.html`;
`docs/factory-flow-model.md` (FROZEN D2A + D9E-1 errata); `docs/domain-glossary.md` (FROZEN D2A);
`docs/demo-walkthrough-d8.md` (D9E-1 errata applied); `data/stages.json`; `data/factory_units.json`;
`data/reference_standards.json`; `data/users.json`; `backend/app/workflow_rules.py`; `ai/product-
invariants.md`; `ai/incidents/d9c1-worker-question-not-enforced.md`, `ai/incidents/
d9c3-verification-script-deliverable-skipped-by-worker.md`, `ai/incidents/
d9c5-execution-supervisor-stdin-truncated-verification-loop.md`.

## 22. Version and Operator-Lock Status

**Status:** CANONICAL — OPERATOR_LOCKED THROUGH D9E-0; IMPLEMENTED BY D9E-1.
**Version:** 1 (initial canonicalization).
**Supersedes:** no prior canonical document (this is the first). Corrects, narrowly, the drift the
operator resolved in `docs/factory-flow-model.md` and `docs/demo-walkthrough-d8.md` (§9 of the
D9E-1 recon).
**Amendment rule:** any future correction to this document requires the same evidence-and-
operator-lock standard established by D9E-0/D9E-1 — no stage, failure, recovery, authority rule, or
semantic classification may be added, removed, or altered by invention. A future amendment must
cite new primary evidence and, where it changes an operator-resolved conflict (C1–C8), a new,
explicit operator directive superseding the prior resolution.
