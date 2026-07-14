# Recon — D9D: Cross-Variant Parity

STRICT MODE. No assumptions. All findings below are backed by direct, fresh file
reads and command output captured during this recon pass (2026-07-13).

## 1. Branch / Commit / Repository-Status Evidence

- `git branch --show-current` → `main`.
- `git fetch origin` then `git rev-parse HEAD` and `git rev-parse origin/main` → both
  `87315eb52fe40f9c7318ffbccbba7b4e0191a8a7` — local and remote remain aligned at the
  authorized D9C-6-plus-remediation baseline. No later operator-authorized commit
  exists.
- `git status --short` → only `AGENTS.md` and `ai/recon/d9c2-shared-view-model.md`,
  both untracked, both confirmed by `git log --all --oneline` to have zero commit
  history — unrelated pre-existing files, unchanged, not part of D9D.

## 2. D9C-7 Cleanup Evidence

Checked fresh, before any other recon activity: `ai/state_registry.json` has no
`d9c-7-*` key; `ls ai/recon/d9c-7*`, `ls specs/d9c-7*`, `ls tasks/d9c-7*`, `ls
scripts/verification/016*`, `ls docs/review` all return no matches. **D9C-7 residue
is fully absent** — the operator's own stop-and-cleanup is confirmed, not assumed.
D9D does not need to perform or repeat any cleanup.

## 3. Predecessor State Evidence

`ai/state_registry.json`: `d9c-1` through `d9c-6` all `RELEASE_APPROVED`. No `d9d-*`
entry exists yet (will auto-register at `RECON_READY`).

## 4. Complete Parity Matrix

All thirteen relevant files were re-read in full and fresh for this recon (not
assumed from memory, despite this session having built them): `FactoryFlowBoard.tsx`,
`useFactoryViewModel.ts`, and all four files under each of `attention-first/`,
`workflow-first/`, `command-center/`.

| Parity Dimension | Current | Attention-First | Workflow-First | Command Center | Canonical Rule | Classification |
|---|---|---|---|---|---|---|
| Data source | `useFactoryViewModel()` | same | same | same | Single shared hook, one call per mounted root | CANONICAL_PARITY |
| Hook ownership | Called once in `FactoryFlowBoard` | Called once in `AttentionFirstView` | Called once in `WorkflowFirstView` | Called once in `CommandCenterView` | Exactly one invocation per mounted root; sub-views receive `vm` as a prop | CANONICAL_PARITY |
| Initial load | Hook's internal `useEffect(reload)` | same | same | same | No component re-implements loading | CANONICAL_PARITY |
| Unit eligibility ("other units"/queue) | Shows **all** units incl. terminal (`UnitList` receives `vm.units` unfiltered) | `nonTerminal = units.filter(!terminal)` | `others = units.filter(!terminal && id!==focused)` (inlined, same result) | same inlined pattern | Actor-first variants exclude terminal units from their queues/strips; Current shows the raw engineering queue | Current: INTENTIONAL_PRESENTATION_DIFFERENCE (predates D9C-4, D9C-3 never changed it, no directive ever required Current to filter). Three variants vs each other: CANONICAL_PARITY |
| Terminal filtering | None (by design) | Excluded from strip/queue | Excluded (inlined) | Excluded (inlined) | Same as above | Same as above |
| Initial focus | None — `selectedUnit` starts `null`, shows "Select a unit from the list" | `useEffect`: if `selectedUnitId==null`, select first non-terminal unit | identical `useEffect`, byte-for-byte | identical `useEffect`, byte-for-byte | Actor-first variants auto-focus; Current does not (predates D9C-4, unchanged, no directive required it) | Current: INTENTIONAL_PRESENTATION_DIFFERENCE. Three variants: CANONICAL_PARITY |
| Manual focus change | `UnitList` `onSelect` → `vm.selectUnit(id)` | strip tap → `vm.selectUnit(id)` | identical | identical | Same mechanism everywhere | CANONICAL_PARITY |
| Attention derivation | N/A (no attention concept in Current) | `blocked_reason != null` (both Assembler `isBlocked` and FloorManager `blockedUnits` filter) | identical | identical | Single boolean signal, no severity tiers, identical predicate text in all three | CANONICAL_PARITY |
| Blocked-reason formatting | N/A | `formatBlockedReason` exported from `AssemblerView.tsx`, imported by `FloorManagerView.tsx` | `formatBlockedReason` defined **twice** — once unexported in `AssemblerWorkflowView.tsx`, once separately in `FloorManagerWorkflowView.tsx` (not imported from the former) | `formatBlockedReason` exported from `AssemblerCommandView.tsx`, imported by `FloorManagerCommandView.tsx` | Output must be identical everywhere | **Output confirmed byte-identical in all three** (same transform: `_`→space, capitalize first char, lowercase rest) — Workflow-First's duplicate-definition-instead-of-shared-import is a code-organization inconsistency, not a functional difference (identical output). Per the architecture contract's own "duplication alone is not automatically a D9D defect" principle: CANONICAL_PARITY (functionally); the duplication itself is OUT_OF_SCOPE (no behavior to correct) |
| Stage-5 reallocation eligibility | N/A (`ActionPanel`, protected, out of scope) | `findAffectedAllocation`+`hasSupportedAction`, identical logic | identical | identical | Byte-identical implementation across all three `*ActionForm.tsx` | CANONICAL_PARITY |
| Stage-5 old serial derivation | N/A | `part.serial_number` resolved by joining `part_allocations[type].part_id` to `vm.parts` | identical | identical | Real serial, never empty, already remediated | CANONICAL_PARITY |
| Stage-5 actor authority | N/A | `actor_user_id: 'USER-SUP-0001'` | identical literal | identical literal | Same fixed demo-actor constant everywhere | CANONICAL_PARITY |
| Stage-5 new-serial validation | N/A | **No validation** — `SubmitButton` only `disabled={loading}`, empty string can be submitted | same gap | same gap | Directive explicitly requires "a non-empty new serial" (Stage-5 scenario section, verification item #15) | **DEFECTIVE_DRIFT** — uniformly missing in all three, drifted from the directive's own named requirement (not a cross-variant difference, but a drift from the canonical rule) |
| Stage-10 calibration eligibility (form rendered when relevant) | N/A | Form call is **unconditional** in the calm-state branch (renders for any focused unit; internally no-ops unless stage 10 not-cap) **and** conditionally in the blocked branch (stage 12 only) | Form call exists **only** inside `{isBlocked && (...)}`, and even then only for stage 12 — **never called in the calm/non-blocked state at all** | same gap as Workflow-First — form never called outside the blocked block | D9B §6 (Workflow-First): "one large primary action appropriate to that stage" — always visible, separate from the blocked-only "corrective-instruction panel." D9B §7 (Command-Center): "(2) current unit + its one primary action" — explicitly always-visible, not conditional | **DEFECTIVE_DRIFT** — Workflow-First and Command-Center's own documented design intent (D9B) requires an always-visible primary action; only Attention-First's implementation actually does this. This is a real action-eligibility gap: a backend-supported action (submit calibration result for a non-blocked, mid-calibration unit, e.g. UNIT-0003) is reachable in one variant's Assembler view and silently absent in the other two |
| Stage-10 cap disposition | N/A | 3 buttons, `USER-MGR-0001`, identical reason strings pattern | identical | identical | Same disposition set/authority/reason pattern everywhere | CANONICAL_PARITY |
| Stage-12 retry eligibility | N/A | `stageNum===12 && blocked_reason!=null` | identical | identical | Same condition everywhere | CANONICAL_PARITY |
| Unsupported action feedback | N/A | `hasSupportedAction` gates `TriageRow`'s Resolve control; truthful "No resolution action is available in this comparison view." message otherwise (already remediated) | identical | identical | No dead Resolve anywhere | CANONICAL_PARITY |
| Post-action refresh | `ActionPanel`'s `onActionComplete` → `vm.refreshSelected()` (protected, unchanged) | `vm.refreshSelected()` (Assembler calm/blocked), `vm.reload()` (FloorManager triage) | identical split | identical split | Refresh-the-focused-unit vs. reload-the-whole-list split is identical logic everywhere | CANONICAL_PARITY |
| Load error | `{vm.loadError && <span>Error: ...</span>}` | `{vm.loadError && <div>Error: ...</div>}` in the root View | identical | identical | Same condition/text pattern everywhere | CANONICAL_PARITY |
| Mutation error | N/A (delegated to `ActionPanel`, protected) | `{error && <div>Error: {error}</div>}` after every submit block in `*ActionForm.tsx` | identical | identical | Same try/catch/setError pattern in all three `*ActionForm.tsx` | CANONICAL_PARITY |
| Actor switching | N/A (Current has no actor concept) | `activeActor` state in root View, same `vm` passed to both sub-views | identical | identical | No second hook invocation on actor switch | CANONICAL_PARITY |
| Variant switching | N/A | `VariantReviewShell` mounts one top-level tab at a time | identical mechanism | identical mechanism | Switching tabs fully unmounts/remounts the outgoing variant | CANONICAL_PARITY |
| Reset reflection | `vm.resetDemoState()` wired to Current's own button | No local reset button; reflects a reset performed via Current after remount/reload | identical | identical | No client-side state syncing exists or is needed — every mount fetches fresh backend truth | CANONICAL_PARITY |
| API call count/boundary | 8-call `Promise.all` inside the hook | identical (same hook) | identical | identical | One 8-call sequence per mount, no parallel path anywhere | CANONICAL_PARITY |
| Backend truth reflection | Confirmed live across D9C-4/5/6/remediation testing | confirmed | confirmed | confirmed | Same backend, same truth, always | CANONICAL_PARITY |

## 5. Data-Source Map

All four options ultimately read from the same eight backend GET endpoints via
`frontend/src/api/factoryApi.ts` (unchanged, protected), reached exclusively through
`useFactoryViewModel()`. No option has a second data path.

## 6. API-Call Map / Action-to-Endpoint Matrix

| Stage/Condition | Endpoint | Called by |
|---|---|---|
| 5, blocked | `POST /factory/units/{id}/actions/reallocate-part` | All three `*ActionForm.tsx`, identical payload shape |
| 10, not cap-exceeded | `POST /factory/units/{id}/actions/calibration` | All three, identical payload shape |
| 10, cap-exceeded | `POST /factory/units/{id}/actions/calibration-disposition` | All three, identical payload shape (3 dispositions) |
| 12, blocked | `POST /factory/units/{id}/actions/cloud-backup` | All three, identical payload shape |
| Reset | `POST /factory/dev/reset-state` | Current only (`FactoryFlowBoard`), protected, unchanged |

## 7. Payload-Semantic / Actor-Authority Comparison

Identical across all three `*ActionForm.tsx` files: `part_type`/`old_serial_number`
resolved from the real allocation, `release_reason_code: 'damaged_at_bench'`,
`actor_user_id` constants (`USER-SUP-0001` for reallocation, `USER-TECH-0001` for
calibration, `USER-MGR-0001` for disposition, `USER-OP-0001` for cloud-backup retry).
Only the free-text `reason` string differs (mentions the variant's own name, e.g.
"Reallocated via Attention-First triage") — a cosmetic label difference with no
functional effect, OUT_OF_SCOPE.

## 8. State-Ownership Comparison

`useFactoryViewModel()` owns all canonical data/selection/refresh/reload/reset state
in every option. `activeActor` (all three variants) and `theme`/`compactPane`
(Current only) are the only local presentation state, matching each option's own
already-`RELEASE_APPROVED` design.

## 9. Serialized-Traceability Comparison

Identical, already-remediated logic in all three `*ActionForm.tsx`
(`findAffectedAllocation` joins `part_allocations[type].part_id` to `vm.parts` to
resolve a real `serial_number`). The one gap found (§4, new-serial validation) is
documented as `DEFECTIVE_DRIFT` above.

## 10. Intentional-Difference Inventory (preserved, not touched)

- Attention-First's Assembler full-screen takeover on blocked focus (whole-card
  replacement) — structurally distinct from both other variants, confirmed intact.
- Workflow-First's single persistent card with inline attention section, and its
  Floor Manager's collapsed-by-default, explicitly-toggled triage — confirmed intact.
- Command-Center's simultaneous, always-visible multi-region layout for both actors —
  confirmed intact.
- Current's un-scoped engineering-console presentation (all units, no auto-focus, no
  actor concept) — confirmed intact and out of D9D's touch scope.
- The `reason` string's per-variant name mention in mutation payloads — cosmetic only.

## 11. Defective-Drift Inventory (this node's only authorized corrections)

1. **Missing always-visible primary action in Workflow-First and Command-Center's
   calm-state Assembler view.** `AssemblerWorkflowView.tsx` and
   `AssemblerCommandView.tsx` never call their respective `*ActionForm` outside the
   `isBlocked` block, so a real, backend-supported action (stage-10 calibration
   submission for a non-blocked, mid-calibration unit) that Attention-First's
   `AssemblerView.tsx` already correctly exposes is silently unreachable in the other
   two — contradicting each variant's own D9B-documented design intent ("one primary
   action" / "current unit + its one primary action," both explicitly always-visible,
   not conditional on blocked state). **Correction**: add
   `{!isBlocked && <XxxActionForm .../>}` to each file's always-rendered "Current
   Unit" region, exactly mirroring Attention-First's existing, correct pattern.
   Category: mismatched action eligibility.
2. **No non-empty validation on the Stage-5 "Replacement Serial Number" field**,
   uniformly absent in all three `*ActionForm.tsx`. The directive explicitly names
   this requirement ("require a non-empty new serial," verification item #15).
   **Correction**: disable the "Submit Reallocation" button (in addition to the
   existing `loading` check) when `newSerial.trim().length === 0`, identically in all
   three files. Category: mismatched mutation payload / missing validation.

No other defective drift was found across any of the 23 parity dimensions audited.

## 12. Unavailable-Data Inventory (unchanged, not this node's concern)

Order/stock/staffing data (real `/factory/orders` endpoint exists but is outside the
shared view-model's approved surface, per D9C-5/D9C-6 recon) — already truthfully
labeled "not available" in Workflow-First's Secondary Info tab and Command-Center's
Secondary Context region. No change needed or authorized.

## 13. Exact Correction Boundary

Only `frontend/src/components/variant-review/workflow-first/{AssemblerWorkflowView.tsx,
WorkflowActionForm.tsx}` and `frontend/src/components/variant-review/command-center/
{AssemblerCommandView.tsx,CommandCenterActionForm.tsx}` require changes.
`attention-first/**` requires **no** change (it is already the correct reference
implementation for both drift items — its calm-state form call already has no
new-serial validation either, so it needs the same validation fix, but not the
calm-state-visibility fix, since it already has that correctly).

Re-stating precisely: **all three** `*ActionForm.tsx` files need the new-serial
validation fix (drift #2); **only** `AssemblerWorkflowView.tsx` and
`AssemblerCommandView.tsx` need the calm-state form-visibility fix (drift #1) —
`AssemblerView.tsx` (attention-first) already does this correctly and needs no change
for drift #1.

## 14. Protected Surfaces Confirmed (paths verified to exist exactly as named)

`frontend/src/components/{FactoryFlowBoard,ActionPanel,UnitList,StageSpine,
UnitDetailPanel,EventTrace}.tsx`, `frontend/src/view-model/`, `frontend/src/api/`,
`frontend/src/types/`, `frontend/src/main.tsx`, `frontend/src/App.tsx`,
`frontend/src/styles.css`, `frontend/package.json`, `frontend/package-lock.json`,
`backend/`, `data/`, `vendor/`, `.engineering-os/`, `source-materials/`, all D9C-1–
D9C-6 historical artifacts, `AGENTS.md`, `ai/recon/d9c2-shared-view-model.md` — none
require any change for this node.

## 15. Architectural Findings

Neither correction requires a shared abstraction — both are narrow, independent edits
within each already-independent `*ActionForm.tsx`/`Assembler*View.tsx` pair, fully
consistent with the architecture contract's "do not introduce a shared abstraction
unless recon proves an actual parity-control failure that cannot be safely corrected
within the existing components" — both failures here are safely correctable in place.

## 16. Execution Risks

- **Structural-check compatibility**: the calm-state fix must use a separate
  `{!isBlocked && (...)}` block, not a ternary combining it with the existing
  `{isBlocked && (...)}` block, to remain compatible with `scripts/verification/
  014`'s/`015`'s existing "no `isBlocked ?` ternary" structural assertions (confirmed
  by reading those scripts' current content — they specifically assert the *absence*
  of a ternary, not the absence of any conditional rendering).
- **Backend lock contention**: same pacing discipline as every prior node (one action
  at a time, confirm before the next).
- **Stage-5 unreachable via live seed**: unchanged finding from the prior
  remediation — no code path in `backend/app/workflow_rules.py` ever persists a
  stage-5 `blocked_reason`. The Stage-5 scenario audit is again verified via
  controlled typed fixtures through `browser_evaluate`, not a live click-path,
  exactly as done in the prior remediation.

## 17. Invariant Interactions

Identical to every prior D9C node — no new mutation path, no client-side transition
legality, both corrections only change *when* an already-existing, already-correct
action call is reachable, never *what* it does.

## 18. Verification Plan

`scripts/verification/016-d9d-cross-variant-parity.sh`, authored directly by the
orchestrator, asserting: shared-view-model single-invocation in all four options; no
parallel data fetch; equivalent unit-eligibility/terminal-filtering/initial-focus
logic across the three variants; equivalent attention derivation; equivalent
supported-action detection including the corrected calm-state visibility; no empty
old serial; new-serial validation present in all three forms; equivalent actor
authority; equivalent refresh split; equivalent error visibility; no dead Resolve;
Attention-First takeover, Workflow-First collapsed-triage, and Command-Center
simultaneous-region structural markers all still intact (re-using and extending
scripts 013/014/015's existing structural assertions where applicable); no
backend/API/data/view-model file touched; final diff scoped to exactly the four
files named in §13 plus Engineering OS artifacts.

## 19. Browser Parity Plan

After rebuilding the frontend image and confirming current source is served: reset
demo state; open Current and record UNIT-0003's canonical state (stage 10, not
blocked, `calibration_in_progress`); open each of the three variants' Assembler view,
confirm UNIT-0003 (once focused) now shows the calibration-submission action in all
three (previously only Attention-First); execute one supported action per variant in
turn (cloud-backup retry via Attention-First, calibration-cap disposition via
Workflow-First, an equivalent action via Command-Center), confirming the resulting
backend truth appears identically in Current and the other two variants after
switching; confirm the new-serial validation blocks an empty submission attempt;
confirm unsupported-attention feedback (UNIT-0002, stage 7) still shows the truthful
message in all three; confirm all three variants' intentional structural differences
remain visually and behaviorally intact throughout; reset demo state; confirm zero
residue.
