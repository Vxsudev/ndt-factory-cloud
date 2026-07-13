# Recon — D9C-6: Command-Center Actor Views

STRICT MODE. No assumptions. All findings below are backed by direct file reads and
command output captured during this recon pass (2026-07-13).

## 1. Repository / Branch State

- `git branch --show-current` → `main`. `git status --short`: `M
  ai/engineering-journal.md`, `M ai/state_registry.json`, `M frontend/src/components/
  variant-review/VariantReviewShell.tsx` (D9C-5's own uncommitted changes), plus
  untracked D9C-4/D9C-5 artifacts and the two long-standing pre-existing untracked
  files (`AGENTS.md`, `ai/recon/d9c2-shared-view-model.md`).
- `git status -sb` → `main...origin/main`, no ahead/behind marker — local matches
  origin at `aff869a feat(factory-ui): migrate Current to shared view model` (D9C-3's
  commit). **Finding: D9C-4 and D9C-5's work is not yet committed** (only D9C-1
  through D9C-3 are on `origin/main`). The directive asks to validate "D9C-5 is
  committed and present in the execution baseline" — this is **not literally true**
  (no commit exists for D9C-5), but the *functional* baseline is present and correct:
  `ai/state_registry.json` shows `d9c-5-workflow-first-actor-views: RELEASE_APPROVED`,
  and the actual files (`workflow-first/` directory, `VariantReviewShell.tsx` wiring)
  are present and verified on disk, in the same working tree D9C-6 will build on. This
  is the same non-blocking condition observed and accepted at the start of D9C-4 and
  D9C-5's own recons (each predecessor was likewise uncommitted when the next node
  began) — not a new problem, not a `Conflict: STOP` trigger, since the directive's
  own state-machine gate cares about `ai/state_registry.json`, not git commit status.

## 2. Predecessor State Evidence

`ai/state_registry.json`: `d9c-1` through `d9c-5` are all `RELEASE_APPROVED`. No
`d9c-6-*` entry exists yet (unregistered, will auto-register at `RECON_READY`).

## 3. Current VariantReviewShell Wiring (read fresh)

`frontend/src/components/variant-review/VariantReviewShell.tsx` (48 lines): `variantA`
→ `AttentionFirstView`, `variantB` → `WorkflowFirstView`, `variantC` → still
`VariantPlaceholderPane variantId="variantC" variantLabel="Variant C —
Command-Center"`. This is the one line D9C-6 changes.

## 4. Completed Attention-First / Workflow-First Implementation Evidence

Both `frontend/src/components/variant-review/{attention-first,workflow-first}/` (8
files total) confirmed present and unchanged since their respective D9C-4/D9C-5
verification reads (`git diff --stat` shows no drift). Structural facts re-confirmed:

- **Attention-First** (`AssemblerView.tsx`/`FloorManagerView.tsx`): Assembler's calm
  card is **entirely replaced** by a distinct, dominant `surf-error`/`b-error` card the
  instant the focused unit is blocked — a true takeover, no other region stays visible
  alongside it except the "Other Units" strip below. Floor Manager's triage list is
  **always rendered** above the queue whenever `blockedUnits.length > 0` (no toggle).
- **Workflow-First** (`AssemblerWorkflowView.tsx`/`FloorManagerWorkflowView.tsx`):
  Assembler keeps **one persistent card**, blocked info an inline section within it.
  Floor Manager's triage is **collapsed by default**, requiring an explicit tap to
  expand, plus a separate "Secondary Info" tab one navigation step away from the queue.

**Command-Center must be distinct from both**: per D9B §7 and the directive, it must
show attention, current-unit/focused work, other units, and (for Floor Manager)
secondary context **all simultaneously, persistently visible, with no takeover and no
required expand/tab-switch step** for primary context. This is a genuine third
structural philosophy — not values re-styled, not a merge of the other two.

## 5. D9B Command-Center Contract (source: `ai/recon/d9b-three-functional-actor-first-ui-variants.md`
§7, already read in full this session; re-verified unchanged)

- **Core idea**: persistent, multi-region, always-visible layout, closest in spirit to
  the current D8C `FactoryFlowBoard` grid, but re-prioritized (attention/current-task
  promoted to top, engineering-console noise removed) rather than replaced with a new
  interaction pattern.
- **Assembler**: one persistent screen, always-visible regions top to bottom: (1)
  Attention banner (only rendered when non-empty), (2) current unit + one primary
  action, (3) assigned/blocked units strip, (4) **collapsed-by-default** supporting
  detail (parts, calibration history) behind **explicit, actually-collapsed**
  disclosure — "unlike the current app's markup-only disclosure." No route/pane
  switching.
- **Floor Manager**: (1) Attention/triage region at top — always visible, not gated
  behind a toggle, (2) today's queue, (3) a secondary-info rail (orders/stock/
  assembler availability) **always present but visually quieter** (smaller, muted)
  than the top two regions — not hidden behind a tab.
- **Trade-off explicitly named in D9B**: "closest of the three to the current app's
  shape, so it carries the highest risk of quietly reverting toward 'engineering
  console' feel if discipline around hiding raw/noisy content slips" — this recon's
  density/decluttering findings (§13) exist specifically to guard against that named
  risk.

## 6. Comparison Matrix — Command-Center vs. Current vs. Both Completed Variants

| Dimension | Current (engineering console) | Attention-First | Workflow-First | Command-Center (this node) |
|---|---|---|---|---|
| Attention visibility | Rendered inline as part of Unit Detail, not prioritized | Full-screen takeover | Inline section (Assembler) / collapsed toggle (Floor Manager) | **Always-visible banner/region when non-empty, never a takeover, never requiring a toggle** |
| Regions visible simultaneously | All (unscoped engineering grid: Unit Queue, Stage Spine, Unit Detail, Action Panel, Event Trace) | One at a time (calm card XOR interrupt card XOR triage-vs-queue) | Card + strip together; triage vs. queue require a toggle; secondary info behind a tab | **All actor-relevant regions simultaneously, no toggle, no tab** |
| Supporting/raw detail | Fully exposed (raw endpoint text, Dev panel, full 14-stage spine, all `UnitDetailPanel` sections open) | Hidden entirely | Hidden entirely | **Present but explicitly collapsed by default (real `<details>`-style disclosure, not just less of it)** |
| Route/tab required for primary context | N/A (single view) | No (calm/interrupt is state-driven) | No for Assembler; **yes** for Floor Manager's secondary info | **No — never required for any primary-context region** |
| Navigation model | Single page | State-driven (calm ⇄ interrupt) | Actor-driven focus switch + explicit triage toggle + tab | **Persistent multi-region single screen, no navigation for primary content** |

This table is the acceptance-level proof this recon is required to produce: a genuine
third philosophy, not a relabeled copy.

## 7. Available Shared-View-Model Fields / Mutation Functions (unchanged since D9C-4/D9C-5 recon — re-verified)

`frontend/src/view-model/types.ts`/`useFactoryViewModel.ts` (read fresh, byte-identical
to prior reads): `health, contractStatus, stages, units, events, users, parts,
refStandards, selectedUnitId, selectedUnit, loadError, resetting, selectUnit,
refreshSelected, reload, resetDemoState`. `frontend/src/api/factoryApi.ts`'s action
functions (`postReallocatePart`, `postCalibration`, `postCalibrationDisposition`,
`postCloudBackup`, etc.) unchanged. Both protected, not modified.

## 8. Truth-to-Presentation Mapping (identical underlying truths to D9C-4/D9C-5)

No new backend data exists. Re-confirmed absent: authenticated identity, personal
assignment, failure-instruction lookup, live telemetry, stock/staffing data. The real
`/factory/orders` endpoint (found in D9C-5 recon) remains outside this node's approved
surface for the same reason (shared view model / `factoryApi.ts` protected, no
parallel fetch permitted). Per this directive's explicit instruction — "if an
unavailable-data region is included for comparison fidelity, it must be explicitly
labelled unavailable" — Command-Center's Floor Manager secondary-context region will
be a real, always-visible (not tabbed) region that states plainly "Order, stock, and
staffing information is not available in this view," matching D9B's requirement that
this region be "always present" while being honest about its content.

## 9. Attention Derivation Rule (unchanged, reused as a data-truth rule)

`blocked_reason != null && !package_ship_status.terminal` — identical single-tier,
deterministic rule used by both completed variants.

## 10. Focused/Current-Unit Rule

Same deterministic rule as both completed variants: first non-terminal unit in
`vm.units` by default, changed only via explicit `vm.selectUnit` calls from a user tap
on another unit in the "other units" region. Reusing this *rule* (not component code)
across all three variants is consistent with truth-derivation being shared while
presentation is not.

## 11. Queue-Grouping Rule

`current_stage_number` — the only ratified canonical ordering
(`docs/factory-flow-model.md`, `ai/product-invariants.md` Invariant 1), same rule
reused by both completed variants.

## 12. Persistent-Region Map (locked for spec)

**Assembler**, one screen, top to bottom, all simultaneously rendered:
1. Attention banner — rendered only when the focused unit (or, per D9B, any relevant
   unit) is blocked; a compact, always-on-top summary card, not a takeover of anything
   below it.
2. Current/focused unit region — unit id, stage name, one primary action (reusing the
   same stage-to-action mapping as the other two variants, independently implemented).
3. Other Units region — a persistent list/strip (not a takeover, not a route) of other
   non-terminal units with truthful status chips (no "assigned to me" language, same
   constraint as D9C-4/D9C-5).
4. Supporting Detail region — collapsed by default via a real disclosure control (e.g.
   native `<details>` or an equivalent toggled `<div>`), showing part allocations/
   calibration summary for the focused unit only when explicitly expanded.

**Floor Manager**, one screen, top to bottom, all simultaneously rendered:
1. Attention/Triage region — always visible when `blockedUnits.length > 0` (no toggle
   required, unlike Workflow-First), listing each blocked unit with a resolve control.
2. Queue region — all non-terminal units, grouped/sorted by `current_stage_number`,
   remains visible at all times, including while the Attention/Triage region is shown.
3. Secondary Context region — always present, visually quieter (smaller text, muted
   `surf-container`/`t-on-surface-var` styling rather than the primary regions'
   prominent styling), stating truthfully that order/stock/staffing data is
   unavailable in this view.

## 13. Supporting-Detail Disclosure / Density Controls (guards against D9B's named risk)

To avoid "quietly reverting toward engineering console feel" (D9B §7's own named
trade-off): the Supporting Detail region in the Assembler view uses a genuinely
collapsed-by-default disclosure (default closed, one explicit tap to open) — not
markup-only disclosure the way `UnitDetailPanel.tsx`'s `<details ... open>` sections
currently default to *open* (confirmed by reading `UnitDetailPanel.tsx` fresh: every
`<details className="group" open>` in that file defaults open). Command-Center's own,
independently-built disclosure must default **closed**. The full 14-stage
`StageSpine`-style spine is **not** reproduced — per the architecture contract's "no
complete 14-stage engineering spine unless recon proves an actor-scoped summarized
use," and no such actor-scoped need was found (the queue's per-unit stage number is
sufficient truth for both actors; a full 14-row spine reproduces raw engineering detail
D9B explicitly wants hidden from actor-scoped views).

## 14. Action Architecture

Independent `CommandCenterActionForm.tsx`, same stage-to-action mapping as both
completed variants (stage 5 reallocate / stage 10 calibration or disposition / stage
12 cloud-backup retry), same unmodified `factoryApi.ts` functions and fixed demo-actor
constants, no raw endpoint text, no free-text actor-ID field. Not imported from
`attention-first/` or `workflow-first/` — a third, independent implementation, per the
directive's explicit "no silently combine Attention-First and Workflow-First
components" instruction.

## 15. Actor-Switching Behavior

Identical pattern: `CommandCenterView` calls `useFactoryViewModel()` once, holds
`activeActor` state, passes the same `vm` to whichever actor sub-view is active.

## 16. Docker Rebuild / Current-Source Proof Procedure

Unchanged from D9C-4/D9C-5: `docker-compose.yml`'s `frontend` service has no volume
mount (re-confirmed via `docker inspect` → `[]` mounts). Before any browser assertion:
`docker compose build frontend && docker compose up -d --force-recreate frontend`,
then `curl` the served `VariantReviewShell.tsx` module and grep for the new component
name before trusting anything rendered in the browser.

## 17. Backend Mutation-Test Isolation

Same pacing discipline as D9C-5 (one action at a time, confirm result, avoid
back-to-back resets) to avoid recurrence of the D9C-4 Postgres lock-contention
incident.

## 18. Manual Full-Corpus Verification Workaround (per the directive's explicit instruction and `ai/incidents/d9c5-execution-supervisor-stdin-truncated-verification-loop.md`)

Confirmed necessary and already this session's standing practice regardless of
`execution-supervisor.sh`'s own report: after any automated run, manually iterate
every discovered `scripts/verification/[0-9][0-9][0-9]-*.sh` file in a plain shell
`for` loop (no shared stdin with any inner `docker compose exec` calls), printing each
filename and exit code, to produce explicit evidence that scripts after `007` actually
executed — not merely reported as part of an announced count.

## 19. Parser-Safe Spec Requirements (per the D9C-5 incident, repeated in this directive)

The `## Verification Scripts` section of the D9C-6 spec will contain **only** the bare
literal `(none)` — no explanatory prose of any kind underneath it, since any further
line in that section risks being naively parsed as a required script path (confirmed
root cause in `ai/engineering-journal.md`'s D9C-5 addendum). Any explanation of why it
is `(none)` will be placed in a different section entirely (e.g., Frontend Surface or
Regression Plan), never under the Verification Scripts heading itself.

## 20. Pre-Existing TypeScript/Lint Baseline

Unchanged since D9C-2: `frontend/src/api.ts`, `frontend/src/api/factoryApi.ts`,
`frontend/src/components/{ActionPanel,DataContractStatus,FactoryFlowBoard}.tsx` —
`ImportMeta.env` typing and unused-variable lint issues, confirmed unrelated to and
untouched by any D9C node so far. Will be re-confirmed via `tsc --noEmit` during
execution and compared against this exact baseline.

## 21. Stale Predecessor-Script Assertions That Must Legitimately Change

`scripts/verification/013-d9c-4-attention-first-actor-views.sh`'s `V10` and
`scripts/verification/014-d9c-5-workflow-first-actor-views.sh`'s `V14` both assert
`grep -q 'variantId="variantC"' "$VRS"` (i.e., `variantC` stays on
`VariantPlaceholderPane`). D9C-6's own approved spec legitimately invalidates this the
same way D9C-5 legitimately invalidated `013`'s old `variantB` assertion. **Both must
be narrowly updated** (drop the now-stale `variantC`-stays-a-placeholder assertion,
keep every other check in each script fully intact) as an explicitly authorized,
narrow mutation for this node, per the directive's own System Integration allowance
("narrowly necessary updates to predecessor variant verification scripts whose
placeholder assertions become legitimately stale") and this session's own established
precedent from the D9C-5 incident.

## 22. Selector Naming Discrepancy

Unchanged, same resolution as every prior node: tab-bar label remains `'Variant C —
Command-Center'`, out of scope for this content-only capability.

## 23. Component Boundary

New directory `frontend/src/components/variant-review/command-center/`:

- `CommandCenterView.tsx` — root; `useFactoryViewModel()` once; `activeActor` state;
  renders `AssemblerCommandView`/`FloorManagerCommandView`.
- `AssemblerCommandView.tsx` — the four persistent regions from §12 (Attention banner,
  Current Unit, Other Units, Supporting Detail-behind-disclosure), all rendered
  together on one screen, no route/tab switching.
- `FloorManagerCommandView.tsx` — the three persistent regions from §12 (Attention/
  Triage — always shown when non-empty, Queue, Secondary Context — always visible,
  visually subordinate, honest "not available" content).
- `CommandCenterActionForm.tsx` — independent implementation of the shared
  stage-to-action mapping, not imported from either other variant.
- `frontend/src/components/variant-review/VariantReviewShell.tsx` — `variantC` branch
  only changes to render `<CommandCenterView/>`.
- `scripts/verification/013-d9c-4-attention-first-actor-views.sh`,
  `scripts/verification/014-d9c-5-workflow-first-actor-views.sh` — narrow,
  orchestrator-authored fix to drop the stale `variantC` assertion in each.

## 24. Architecture Risks

- **Density creep toward Current**: mitigated by §13's explicit collapsed-by-default
  disclosure requirement and the explicit "no full 14-stage spine" rule — verified by
  the new verification script asserting a default-closed disclosure state and absence
  of a full stage-spine reproduction.
- **Accidental convergence with either completed variant**: mitigated by the
  comparison matrix (§6) driving explicit, checkable structural markers (no takeover
  class/component-swap; no collapsed-attention-by-default toggle; no required
  secondary tab for primary context) in the new verification script.
- **Backend lock contention recurrence**: mitigated by paced testing (§17).
- **Supervisor stdin-drain**: mitigated by the manual, non-supervisor-loop full-corpus
  re-run procedure (§18), already this session's standing practice.

## 25. Invariant Interactions

Identical to D9C-4/D9C-5 — no new mutation path, no client-side transition legality,
truthful "no action available" states correctly reflect real hard-stops.

## 26. Protected Surfaces Confirmed (paths verified to exist exactly as named)

`frontend/src/components/{FactoryFlowBoard,ActionPanel,UnitList,StageSpine,
UnitDetailPanel,EventTrace}.tsx`, `frontend/src/components/variant-review/
{attention-first,workflow-first}/` (all eight files), `frontend/src/view-model/
{types.ts,useFactoryViewModel.ts}`, `frontend/src/api/factoryApi.ts`, `frontend/src/
types/factory.ts`, `frontend/src/main.tsx`, `frontend/src/App.tsx`,
`frontend/package.json`, `frontend/package-lock.json`, `backend/`, `data/`, `vendor/`,
`.engineering-os/`.

## 27. Verification Plan

`scripts/verification/015-d9c-6-command-center-actor-views.sh` (next available number
after `014`), authored directly by the orchestrator. Must assert: functional
(non-placeholder) content; single hook invocation; no `fetch*` outside the hook; only
`CommandCenterActionForm.tsx` imports action functions; zero imports from
`attention-first/`/`workflow-first/`; Assembler shows all four regions simultaneously
in one render (no conditional hiding of the whole Current-Unit or Other-Units regions
based on attention state); Attention region has no full-screen-takeover class pattern;
Supporting Detail defaults closed; Floor Manager's Attention/Triage region is not
gated behind a `useState(false)`-style explicit-toggle the way Workflow-First's is (no
"tap to view" pattern) — it must render directly whenever non-empty; Queue remains
present in the same render regardless of attention state; Secondary Context is always
rendered (not behind a second tab); no raw endpoint text; no free-text actor-ID field;
`VariantReviewShell.tsx` diff scoped to `variantC` only; predecessor scripts `013`/
`014` updated only in their stale `variantC` assertion; all protected files unchanged;
nothing under `backend/`/`data/`/`vendor/`/`.engineering-os/` touched.

## 28. Smoke-Test Plan

Rebuild+recreate frontend image, positively confirm `CommandCenterView` is served,
then: Assembler — confirm all four regions visible together on a blocked and
non-blocked focused unit, expand/collapse Supporting Detail, execute one available
action; Floor Manager — confirm Attention/Triage, Queue, and Secondary Context all
visible together, resolve one triage item, confirm the same backend truth appears in
Current afterward; confirm Attention-First and Workflow-First remain fully unchanged
and functionally distinct from Command-Center and each other; reset demo state;
manually run every verification script in a plain loop and record each exit code,
including 008 through 015, as explicit evidence the supervisor's known stdin-drain
defect didn't hide a real failure.

## 29. Conflict / Ambiguity Discovered

**No `Conflict: STOP` condition met.** A truthful Command-Center implementation is
fully producible from already-available data and actions — no new facts, identity,
telemetry, or authority need inventing beyond what D9C-4/D9C-5 already resolved the
same way. The one new integration point (narrowly updating two predecessor
verification scripts' stale `variantC` assertions) is explicitly pre-authorized by
this directive's own System Integration section, not a scope expansion requiring a
fresh operator decision. Proceeding directly to STEP 1 (spec compilation).
