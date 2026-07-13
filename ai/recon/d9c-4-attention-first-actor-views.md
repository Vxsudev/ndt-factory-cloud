# Recon — D9C-4: Attention-First Actor Views

STRICT MODE. No assumptions. All findings below are backed by direct file reads and
command output captured during this recon pass (2026-07-13).

## 1. Repository / Branch State

- `git branch --show-current` → `main`. `git status --short` at recon start:
  `?? AGENTS.md`, `?? ai/recon/d9c2-shared-view-model.md` only — both pre-existing,
  untracked, unrelated to this capability (same finding as D9C-3 recon §1).
- `git remote -v` → `origin https://github.com/Vxsudev/ndt-factory-cloud.git`.
  `git status -sb` shows `main...origin/main` with no ahead/behind marker — local is
  in sync with origin.
- `git log --oneline -8`: `aff869a feat(factory-ui): migrate Current to shared view
  model` is HEAD. `git branch -r --contains aff869a` → `origin/main` — **D9C-3's
  commit is confirmed present AND pushed**, satisfying the directive's predecessor-state
  check exactly.

## 2. Predecessor State Evidence

`ai/state_registry.json`: `d9c-1-variant-review-shell`, `d9c-2-shared-view-model`,
`d9c-3-current-baseline-shared-view-model-migration` are all `RELEASE_APPROVED`.
`git show --stat aff869a` confirms D9C-3's real diff:
`frontend/src/components/FactoryFlowBoard.tsx` (157 lines changed, -132/+... net
shrink from removing local orchestration), plus the D9C-3 recon/spec/task/incident/
journal artifacts and `scripts/verification/012-d9c-3-current-shared-view-model.sh`.

Read `frontend/src/components/FactoryFlowBoard.tsx` fresh: confirmed it calls
`const vm = useFactoryViewModel()` exactly once and has zero `../api/factoryApi`
imports — D9C-3's migration is real and intact on `main`, not just claimed.

## 3. Existing VariantReviewShell / VariantPlaceholderPane Structure

`frontend/src/components/variant-review/VariantReviewShell.tsx` (full, 51 lines):
a 4-tab bar (`current`, `variantA`, `variantB`, `variantC`), each tab's content
conditionally rendered (`{activeTab === 'x' && <Component/>}`) — **only one child is
ever mounted at a time**, the others fully unmount. Tab labels are literally:
`'Current'`, `'Variant A — Attention-First'`, `'Variant B — Workflow-First'`,
`'Variant C — Command-Center'`.

`frontend/src/components/variant-review/VariantPlaceholderPane.tsx` (full, 48 lines):
renders a secondary Assembler/Floor Manager tab bar (`touch-target-secondary`), then a
placeholder body ("Presentation content for this view ships in a later phase.").
Currently used for all three of `variantA`/`variantB`/`variantC`.

**Selector naming discrepancy, confirmed and resolved:** the directive's canonical
names are `Attention-First` / `Workflow-First` / `Command Center` (no "Variant A/B/C —"
prefix, no hyphen in "Command Center"). The existing D9C-1 tab bar uses
`"Variant A — Attention-First"` etc. **Decision: leave the top-level tab-bar labels
unchanged.** This is a shell/navigation-chrome concern established and
`RELEASE_APPROVED` in D9C-1, orthogonal to D9C-4's goal (replacing the *content* behind
one tab). Renaming the tab bar is not required by any D9C-4 acceptance criterion, would
touch a settled D9C-1 artifact for cosmetic reasons only, and risks exactly the
"unrelated cleanup" the directive forbids. Not a data/fact conflict, so this does not
rise to a `Conflict: STOP` — recorded here as a made, justified call, not an operator
question.

## 4. D9B Attention-First Contract (source: `ai/recon/d9b-three-functional-actor-first-ui-variants.md`, read in full, 271 lines)

Section 5 ("Variant A — Attention-First / Interrupt-Driven") is the authoritative
design target:

- **Assembler calm state**: one large card for the current unit — stage, a single
  big-icon primary action, and a compact strip of the assembler's *other* assigned-but-
  not-current units (BLOCKED chip where relevant).
- **Assembler interrupt state**: when the current (or any assigned) unit hits a
  blocked/attention condition, the screen replaces itself with a full-bleed Attention
  card — what failed, a single clear corrective action, a "back to my unit" affordance
  once resolved.
- Two separate badges per §1.6: "at this stage" vs. "actively in progress right now" —
  **confirmed unavailable** (see §7 below); not built, flagged as a known gap, not
  fabricated.
- **Floor Manager calm state**: the queue fills most of the screen; a small,
  always-visible attention counter at top.
- **Floor Manager interrupt/triage state**: once the attention count is non-zero, the
  top becomes a triage list; clicking an item opens the corrective action.
- Secondary info (orders/stock/assembler availability) — **confirmed unavailable as
  real data** (no orders/stock/HR endpoints exist); not built, not fabricated.
- Single attention severity tier only (§1.9) — no invented multi-level taxonomy.
- Two actor routes only, no auth (§1.3, §1.7) — confirmed below, no current-user
  identity exists to derive "assigned to me" from.

## 5. FactoryViewModel Fields Available (from `frontend/src/view-model/types.ts`, unmodified)

`health, contractStatus, stages, units, events, users, parts, refStandards,
selectedUnitId, selectedUnit, loadError, resetting, selectUnit, refreshSelected,
reload, resetDemoState`. `units: FactoryUnit[]` is the critical field for attention
derivation; `selectUnit`/`selectedUnit` is the existing "focus one unit" mechanism
already used by Current, reusable as-is for Assembler's "current unit" concept (see §8).

## 6. Truth-to-Presentation Mapping — What Canonical Data Actually Supports

Read `frontend/src/types/factory.ts` (`FactoryUnit` interface) and
`frontend/src/components/{UnitDetailPanel,UnitList,ActionPanel}.tsx` in full.

| D9B requirement | Canonical data available? | Finding |
|---|---|---|
| Blocked/attention condition per unit | `blocked_reason: string \| null`, `block_type: string \| null`, `no_override: boolean` | **Available.** `blocked_reason != null` is the exact, existing truth signal already rendered (in red) by `UnitDetailPanel`/`UnitList` today. |
| Single attention severity | No severity field exists at all | **Matches D9B exactly** — there is no tier to accidentally invent; "attention" is boolean (`blocked_reason != null`), which is itself the single-tier requirement. |
| "Assigned to me" (assembler) | `assigned_operator_id: string \| null`, `assembly_operator_id?: string \| null` on `FactoryUnit` | **Exists as a field, but is not truthfully usable for "assigned to ME"** — see §8. |
| Failure-mode → corrective instruction lookup | None. `blocked_reason` is a single snake_case code (e.g. `cloud_unreachable_sw_update_cannot_proceed`, `calibration_cap_exceeded_awaiting_disposition`) set directly by `backend/app/workflow_rules.py`; grepped the full backend for any code→instruction mapping table — none exists. | **Unavailable — not fabricated.** Resolution: display the existing `blocked_reason` string reformatted for readability (underscores → spaces, sentence case) — a presentation transform of real data, not an invented instruction. No new "what to do" text beyond what the already-available action form (if any) implies. |
| Live "actively in progress right now" vs. "at this stage" | Grepped `backend/app/{models,workflow_rules,state_store}.py` for any in-progress/live boolean distinct from stage location — none exists. `calibration_summary`/`calibration_status` only have `attempts/max_attempts/passed/cap_exceeded/certificate_id` — no live-activity flag. | **Unavailable — not fabricated.** Not built. Documented as a known gap matching D9B §1.6's own observation that real device telemetry doesn't exist yet. |
| Corrective action per blocked condition | `ActionPanel.tsx`'s existing `hasStageForm = [5, 9, 10, 11, 12, 13, 14].includes(stageNum)` conditional, cross-referenced with seed scenarios (see §9) | **Available for some conditions, genuinely absent for others** (e.g. stage 7 cloud-block has no action form at all — it's a real, actor-unactionable hard block per current data). Must be shown truthfully as "no action available" where genuinely true, not papered over with a fabricated button. |
| Orders/stock/assembler-availability secondary info (Floor Manager) | Grepped backend routes — no `/orders`, `/inventory`, `/stock`, `/staffing` endpoints exist | **Unavailable — not fabricated. Explicitly out of scope per D9B §1.4.5/§10 anyway** (external systems, not yet built). Not attempted. |

## 7. Live-Device-Truth Availability Finding

Confirmed absent (see table above). No badge distinguishing "at this stage" from
"actively running" will be built in this capability. This is consistent with the
directive's own "no live device activity," "no invented live telemetry" prohibitions
and with D9B §1.6's own note that the underlying telemetry doesn't exist yet.

## 8. Actor-Assignment Availability Finding — the most consequential recon finding

`assigned_operator_id`/`assembly_operator_id` are real `FactoryUnit` fields, but
`grep -n "assigned_operator_id\|assembly_operator_id" backend/app/*.py` shows they are
**only ever set as a side effect of `postScanPart`** (`backend/app/workflow_rules.py:194-195`:
`unit.setdefault("assembly_operator_id", req.actor_user_id); unit["assigned_operator_id"]
= req.actor_user_id`) — i.e., whichever free-text `actor_user_id` string happens to be
typed into the Assembly Scan form becomes that unit's "assigned operator." All units are
`null` on a fresh reset. **There is no authenticated session, no fixed "this is me"
identity, and no real assignment workflow** — matching D9B §1.7's explicit statement
that no auth/login exists yet and actor separation is meant to be simple path-based
routing, not individual accounts.

**Consequence: the Assembler view cannot truthfully claim "these are units assigned to
me" for a specific individual**, because there is no "me" to compare
`assigned_operator_id` against — doing so would require inventing a current-user
identity, explicitly forbidden by the directive ("no invented current-user identity,"
"no invented unit assignments").

**Resolution**: the Assembler's "current unit" is a **manually-focused unit**, using
the exact same mechanism Current already uses (`vm.selectedUnitId`/`vm.selectUnit`) —
not an auto-derived "my assigned unit." The "other assigned units" strip is not
filtered by a fabricated operator match; it is truthfully labeled as **"other units in
the queue"** (all non-terminal units except the currently-focused one), which is real,
available data (`vm.units` minus the focused unit), just not personally-scoped
assignment data. This is a deliberate, documented scope reduction from D9B's literal
language ("units assigned to me") to what the data can truthfully support, consistent
with the directive's explicit instruction: *"If current data cannot distinguish
'assigned to this assembler,' the Assembler view must not falsely claim personal
assignment."*

## 9. Blocked-Status Inventory (from live seed data, confirmed via the running stack)

| Unit | Stage | `blocked_reason` | `no_override` | Existing action form available? |
|---|---|---|---|---|
| UNIT-0002 | S-07 (cloud SW/FW update) | `cloud_unreachable_sw_update_cannot_proceed` | true | **None** — stage 7 has no entry in `ActionPanel`'s `hasStageForm`; this is a genuine, truthful "hard blocked, no actor action possible" state. |
| UNIT-0003 | S-10 (calibration), not cap-exceeded | none (in-progress, not blocked) | — | Calibration form (pass/fail) |
| UNIT-0004 | S-10 (calibration), cap-exceeded | `calibration_cap_exceeded_awaiting_disposition` | false | Calibration Disposition form (route back to hardware / scrap / quarantine) |
| UNIT-0006 | S-12 (cloud backup) | `cloud_backup_blocked` | true | Cloud Backup form (retry with `cloud_available` toggle) |
| UNIT-0001, 0005, 0007 | S-05 / S-11 / S-14 | none | — | Not blocked (0001, 0005 in normal flow; 0007 shipped/terminal) |

This confirms attention derivation is genuinely binary and deterministic
(`blocked_reason != null && !package_ship_status.terminal`), and that "a single clear
corrective action" is not always true — sometimes the truthful state is "blocked, no
override, no actor-available action," which the UI must say plainly rather than
fabricate a button for.

## 10. Supported Action Mapping (from `ActionPanel.tsx`, full read)

Stage-to-action mapping already exists and is exactly reused (same request shapes,
same `factoryApi.ts` functions) for the new views:

- Stage 5, blocked (bad part) → `postReallocatePart` (Supervisor Reallocation)
- Stage 9 → `postHardwareGate`
- Stage 10, not cap-exceeded → `postCalibration`
- Stage 10, cap-exceeded → `postCalibrationDisposition`
- Stage 11 → `postQcSignoff`
- Stage 12 → `postCloudBackup`
- Stage 13 → `postPackage`
- Stage 14 → `postShip`
- Stage 7 (and any stage without a form) → **no action**, truthfully shown as such.

**Component-boundary decision on `ActionPanel.tsx` reuse**: the directive says
`ActionPanel.tsx` "is protected by default. Reuse it as an unchanged child if
appropriate." Read in full: `ActionPanel` unconditionally renders (a) a raw endpoint
path line — `"Backend-guarded action · POST {actionBase}/scan-part"` etc. — on every
form, and (b) an always-visible "Dev — Backend-Guarded Transition" panel with a raw
`target_stage_id` free-text field. Both are explicitly, unconditionally forbidden for
actor-first views by this directive ("no raw endpoint paths," "no generic engineering
transition panel," "no free-text actor IDs" — the Dev panel's free-text stage-ID field
also violates this) and by D9B §3's own "hide raw engineering-console noise" invariant.
**Decision: do not reuse `<ActionPanel/>` as a child.** `ActionPanel.tsx` remains
completely untouched (protected surface, zero modification). New, minimal Attention-
First action affordances are built instead, importing the **same, unmodified**
`factoryApi.ts` functions directly (`postCalibration`, `postCalibrationDisposition`,
`postCloudBackup`, `postReallocatePart` — the only ones reachable from the current
seed's blocked scenarios) with the same request shapes ActionPanel already uses, minus
the raw endpoint text and Dev panel. This satisfies "reuse... if appropriate" as an
optional instruction (not mandatory), justified by the directive's own stronger,
unconditional "no raw endpoint paths"/"no generic engineering transition panel" rules
taking precedence.

## 11. Assembler Calm-State Contract (locked for spec)

One large card: the manually-focused unit (`vm.selectedUnit`, defaulting to the first
non-terminal unit on mount if nothing is focused yet — a presentation default, not a
fabricated assignment), its stage name (from `vm.stages`), a single primary action
appropriate to its stage (reusing the stage-to-action mapping in §10, hidden entirely
if the unit isn't blocked and has no pending gate action... actually per D9B, the
"single big-icon primary action" is whatever the *next expected action* at that stage
is, blocked or not — e.g. Assembly Scan at stage 5 even when not blocked). A compact
strip below lists the other non-terminal units with a status chip (blocked/normal)
each; tapping one changes the focus (calls `vm.selectUnit`). No raw endpoint text, no
free-text actor-ID field exposed (a fixed, non-editable actor id is used internally,
matching the existing seeded demo actor pattern — not a new invented identity, just
reusing the same kind of fixed demo constant `ActionPanel.tsx` itself defaults to,
e.g. `USER-OP-0001`).

## 12. Assembler Interrupt-State Contract (locked for spec)

Activates when the focused unit's `blocked_reason != null`. Full-bleed card replacing
the calm-state card: unit id/stage, the reformatted `blocked_reason` text, a `NO
OVERRIDE` marker if `no_override` is true, and — only if a corrective action exists
per §10's mapping — a single action control; if none exists (stage 7 case), a plain
"Blocked — no action available, awaiting external resolution" message, matching truth.
A "Back to my unit" control appears once the unit's `blocked_reason` clears (detected
via `vm.refreshSelected`/`vm.reload` picking up the updated unit, exactly as Current
already does after any action).

## 13. Floor Manager Calm-State Contract (locked for spec)

The queue (`vm.units`, grouped by `current_stage_number`, reusing the existing
`UnitList`-style scenario presentation but without engineering noise) fills most of the
screen. A small, always-visible attention counter (`vm.units.filter(u =>
u.blocked_reason && !u.package_ship_status.terminal).length`) sits at the top.

## 14. Floor Manager Interrupt/Triage-State Contract (locked for spec)

When the attention count is non-zero, the top of the screen becomes a triage list of
exactly those blocked, non-terminal units, each showing its reformatted
`blocked_reason` and (if available per §10) a "Resolve" affordance opening the same
minimal action control described in §12/§10 — reusing the identical action-submission
logic, not a second implementation.

## 15. Exact Component Boundary

New directory: `frontend/src/components/variant-review/attention-first/`:

- `AttentionFirstView.tsx` — root. Calls `useFactoryViewModel()` **exactly once**.
  Holds `activeActor: 'assembler' | 'floorManager'` state (mirrors
  `VariantPlaceholderPane`'s existing secondary-tab pattern) and renders
  `<AssemblerView vm={vm}/>` or `<FloorManagerView vm={vm}/>` — the same `vm` object
  passed to both, never re-invoking the hook. This resolves the directive's "exactly
  once unless recon proves the shell must own and inject one canonical instance"
  clause: because `VariantReviewShell` already mounts only one top-level tab's
  component at a time (§3), `AttentionFirstView` owning its own hook call is exactly
  equivalent to `FactoryFlowBoard`'s existing pattern for `Current` — no shell-level
  injection is needed, and actor-switching *within* Attention-First never remounts the
  hook (only switching *away from* the Attention-First tab does, matching Current's
  own behavior when the shell switches tabs).
- `AssemblerView.tsx` — calm/interrupt states per §11/§12.
- `FloorManagerView.tsx` — calm/triage states per §13/§14.
- `AttentionActionForm.tsx` — shared minimal corrective-action control per §10,
  imported by both `AssemblerView` and `FloorManagerView` (single implementation, not
  duplicated).
- `frontend/src/components/variant-review/VariantReviewShell.tsx` — modified only to
  render `<AttentionFirstView/>` instead of `<VariantPlaceholderPane variantId="variantA".../>`
  for the `variantA` tab; `variantB`/`variantC` unchanged, still placeholders. Tab
  labels unchanged (§3).

## 16. Architecture Risks

- **Actor-switch remount risk**: mitigated by design (§15) — `activeActor` is inner
  state of `AttentionFirstView`, not a shell-level tab, so switching actors never
  remounts the hook.
- **Blocked-state race after a submitted action**: `AttentionActionForm` must call
  `vm.refreshSelected()` (if the acted-on unit is the focused one) or `vm.reload()`
  (if it's a different unit acted on from the Floor Manager triage list) on success,
  exactly mirroring `ActionPanel`'s existing `onActionComplete` contract — no new
  refresh pattern invented.
- **Reformatting `blocked_reason` must not drift into inventing instructions**: the
  transform is strictly mechanical (snake_case → spaced, sentence-cased text), verified
  by the new verification script asserting the transform is a pure string function with
  no lookup table of authored sentences.

## 17. Invariant Interactions

`ai/product-invariants.md` Invariant 2 (Backend Owns State Transitions) — unaffected;
all new action affordances call the exact same backend-guarded POST endpoints with the
same payloads `ActionPanel` already uses, no client-side transition legality is
introduced. Invariant 3 (Hard-Stops Absolutely Blocking) — reinforced, not weakened:
the stage-7 "no action available" truthful state is a direct, correct expression of a
`no_override` hard-stop, not a bypass.

## 18. Protected Surfaces Confirmed (paths verified to exist exactly as named)

`frontend/src/components/FactoryFlowBoard.tsx`, `frontend/src/view-model/{types.ts,
useFactoryViewModel.ts}`, `frontend/src/components/{UnitList,StageSpine,
UnitDetailPanel,EventTrace,ActionPanel}.tsx`, `frontend/src/api/factoryApi.ts` (dir:
`frontend/src/api/`), `frontend/src/types/` (dir), `frontend/src/main.tsx`,
`frontend/src/App.tsx`, `frontend/package.json`, `frontend/package-lock.json`,
`backend/`, `data/`, `vendor/`, `.engineering-os/`. (`migrations/`, `alembic/` do not
exist as top-level dirs — backend's real migration tooling is `backend/alembic/`,
already covered by the `backend/` protection.) `frontend/src/components/
variant-review/VariantPlaceholderPane.tsx` remains in active use for `variantB`/
`variantC` — not deleted, not modified.

## 19. Existing Verification Corpus / Next Number

`scripts/verification/` currently has `001`–`012` (012 added by D9C-3). Next available
number: **`013`**. Per the D9C-3 incident (`ai/incidents/d9c3-verification-script-deliverable-skipped-by-worker.md`)
and this directive's own explicit instruction, `scripts/verification/013-d9c-4-attention-first-actor-views.sh`
**will be authored directly by the orchestrator, not delegated to any task-graph
worker** — the task graph's "Files Likely Affected" for every task will list
application source only.

## 20. Conflict / Ambiguity Discovered

**No `Conflict: STOP` condition met.** The directive's own STOP clause is scoped to
"the functional Attention-First design requires facts, assignments, instructions, or
actions not supported by the current data/API contract" — every such gap found (actor
identity, corrective instructions, live telemetry, secondary info) was resolved by
**scoping the design down to what the data truthfully supports** (§8, §6, §7), exactly
as the directive itself instructs ("the Assembler view must not falsely claim personal
assignment"), not by requiring new facts to be invented or an operator decision on
scope. The `ActionPanel` reuse question (§10) and the selector-naming question (§3)
were both resolved by direct evidence, not conflicting requirements needing operator
adjudication. Proceeding directly to STEP 1 (spec compilation).
