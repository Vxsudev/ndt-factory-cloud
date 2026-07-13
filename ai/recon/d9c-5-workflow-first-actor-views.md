# Recon — D9C-5: Workflow-First Actor Views

STRICT MODE. No assumptions. All findings below are backed by direct file reads and
command output captured during this recon pass (2026-07-13).

## 1. Repository / Branch State

- `git branch --show-current` → `main`. `git status --short`: `M
  ai/engineering-journal.md`, `M ai/state_registry.json`, `M frontend/src/components/
  variant-review/VariantReviewShell.tsx` (all D9C-4's own uncommitted changes), plus
  untracked D9C-4 artifacts (`ai/recon/d9c-4-*.md`, `specs/d9c-4-*.md`,
  `tasks/d9c-4-*.md`, `scripts/verification/013-*.sh`,
  `frontend/src/components/variant-review/attention-first/`) and the two pre-existing
  untracked files (`AGENTS.md`, `ai/recon/d9c2-shared-view-model.md`) already flagged in
  every prior recon this session.
- `git status -sb` → `main...origin/main` with no `[ahead N]`/`[behind N]` marker —
  local `main` and `origin/main` point at the same commit
  (`aff869a feat(factory-ui): migrate Current to shared view model`); D9C-4's work is
  present in the local working tree but not yet committed. This does not block D9C-5 —
  the directive's own predecessor-state checks below confirm D9C-4 is functionally
  complete and `RELEASE_APPROVED` in the state registry regardless of commit status.

## 2. Predecessor State Evidence

`ai/state_registry.json`: `d9c-1-variant-review-shell`, `d9c-2-shared-view-model`,
`d9c-3-current-baseline-shared-view-model-migration`,
`d9c-4-attention-first-actor-views` are all `RELEASE_APPROVED`. No `d9c-5-*` entry
exists yet (unregistered feature — will auto-register at `RECON_READY` on spec
compile, same bootstrapping pattern as every prior node this session).

## 3. D9C-4 Implementation Evidence (read fresh, in full)

`frontend/src/components/variant-review/attention-first/{AttentionFirstView,
AssemblerView,FloorManagerView,AttentionActionForm}.tsx` all exist and are unchanged
since my own D9C-4 read (confirmed via `git diff --stat` — no drift). Key facts
re-confirmed directly from source, not from memory of the journal:

- `AttentionFirstView.tsx` calls `useFactoryViewModel()` exactly once, holds
  `activeActor` state, passes the same `vm` to `AssemblerView`/`FloorManagerView`.
- `AssemblerView.tsx`'s calm state renders one focused-unit card
  (`vm.selectedUnit`, defaulted via a `useEffect` that calls `vm.selectUnit` on the
  first non-terminal unit if nothing is selected) plus a compact horizontal strip of
  "Other Units in Queue" (all non-terminal units except the focused one, tap to
  refocus). Its **interrupt state** is a full-bleed, visually dominant card
  (`surf-error`/`b-error`, replacing the calm card entirely) that activates whenever
  `focused.blocked_reason != null`.
- `FloorManagerView.tsx` shows an always-visible attention counter, a "Triage" section
  (rendered only when the count is non-zero) positioned above a "Queue" section (all
  non-terminal units, sorted by `current_stage_number`).
- `AttentionActionForm.tsx` is the shared corrective-action component (stage 5/10/12
  mapping), called by both actor views, importing `postReallocatePart`,
  `postCalibration`, `postCalibrationDisposition`, `postCloudBackup` directly from the
  unmodified `factoryApi.ts`.

**This is the exact behavior D9C-5 must remain structurally distinct from**: D9C-4's
Assembler *replaces* its entire card with a dominant error-styled takeover the instant
the focused unit is blocked. D9C-5 must never do this — attention must stay inline
within the same stable layout (see §8 below for the enforced structural difference).

## 4. D9B Workflow-First Contract (source: `ai/recon/d9b-three-functional-actor-first-ui-variants.md`
§6, already read in full earlier this session; re-verified against the live file, no
changes)

- **Assembler**: full-screen, step-oriented view of **the one current unit** — stage,
  one large primary action, and (only if relevant) a corrective-instruction panel
  hidden entirely when nothing's wrong. A **persistent bottom strip** (not a takeover)
  lists the assembler's other units with a status chip each; tapping one **deliberately
  switches** the current-unit focus — "the assembler chooses when to switch, rather
  than being interrupted." Blocked-state badges are shown **inline on the current
  card**, "without ever forcing a full-screen takeover."
- **Floor Manager**: default view is **the queue**, organized by stage. An attention
  **count badge** (not a takeover) sits above the queue; clicking it **expands an
  in-place triage list**, then **collapses back to the queue** once handled. Secondary
  info (orders/stock/resources) is a **clearly-labeled tab** next to the queue, one tap
  away, never overlaid on top of it.
- Comparison table (D9B §8): Workflow-First's navigation model is "Actor-driven pane
  focus switch" (not "State-driven calm⇄interrupt" like Attention-First); its attention
  surfacing is "Non-blocking badge, in-place expand" (not "Full-screen takeover").

## 5. Comparison Against Attention-First — Required Structural Differences (locked)

| Dimension | Attention-First (D9C-4, built) | Workflow-First (D9C-5, this node) |
|---|---|---|
| Assembler layout on blocked unit | Calm card is **replaced** by a full-bleed, differently-styled interrupt card | The **same stable card/layout persists**; blocked info renders as an inline section within it — no card swap, no distinct "interrupt mode" component tree |
| Assembler focus-switch trigger | Automatic transition calm→interrupt driven by data state | **Actor-driven only** — focus changes only when the assembler taps another unit in the strip; blocked-ness never forces a takeover |
| Floor Manager attention surface | Triage list always rendered above the queue whenever count > 0, pushing queue down | Attention is a **count badge** that must be **deliberately expanded/collapsed** by the actor; queue remains the persistent primary view underneath, layout doesn't reflow around an always-shown triage block |
| Secondary info | Not present in D9C-4 (out of scope there too) | Present as a **explicit, one-tap-away tab** next to the queue (per D9B's literal instruction) — even though the underlying data is unavailable (§9), the *navigation affordance* itself (a tab that, when opened, truthfully states no data is available) is part of Workflow-First's required structural shape and is what distinguishes it from Attention-First's structure |
| Navigation model | State-driven (calm ⇄ interrupt) | Actor-driven pane/tab switch |

These are genuine structural/interaction differences, not palette/CSS differences —
satisfying the directive's explicit "not merely in labels, colors, or CSS" requirement.

## 6. Shared View-Model Consumption Boundary

`frontend/src/view-model/types.ts`/`useFactoryViewModel.ts` (read fresh, confirmed
unchanged, byte-identical to D9C-4's read): exposes `health, contractStatus, stages,
units, events, users, parts, refStandards, selectedUnitId, selectedUnit, loadError,
resetting, selectUnit, refreshSelected, reload, resetDemoState`. Both protected —
**not modified** by this node (confirmed in System Integration's protected-surfaces
list too). `WorkflowFirstView` (this node's root component) will call
`useFactoryViewModel()` exactly once, exactly mirroring `AttentionFirstView`'s already-
proven pattern (§15 of the D9C-4 recon: safe because `VariantReviewShell` only ever
mounts one top-level tab's component at a time).

## 7. Available Field / Action Inventory (identical to D9C-4's findings — re-verified, no drift)

Same `FactoryUnit` fields (`blocked_reason`, `no_override`, `current_stage_number`,
`package_ship_status.terminal`, `calibration_summary.cap_exceeded`,
`part_allocations`), same action functions
(`postReallocatePart`/`postCalibration`/`postCalibrationDisposition`/`postCloudBackup`)
with the same stage-to-action mapping documented in the D9C-4 recon §10, reusable
as-is for Workflow-First's action forms (same underlying backend, same authority
rules). `AttentionActionForm.tsx` itself is under `attention-first/` — an explicitly
**protected** directory for this node (System Integration's protected-surfaces list) —
so it is **not imported or reused directly**; a new, Workflow-First-owned action
component is built instead, duplicating only the thin stage-to-function mapping (not a
shared abstraction — the directive explicitly forbids "silently mov[ing]
Attention-First code into a new shared abstraction during D9C-5").

## 8. Truth-to-Presentation Mapping (identical underlying truths to D9C-4; different presentation contract)

Everything in the D9C-4 recon's truth table (`ai/recon/d9c-4-attention-first-actor-views.md`
§6) still holds — no new backend data was added between D9C-4 and D9C-5. Re-confirmed:
no actor identity/login, no failure-instruction lookup table, no live-activity
telemetry, and (new to this node's requirements) **a real `/factory/orders` endpoint
does exist** (`backend/app/routes/data_contract.py:41-43`,
`GET /factory/orders → list[OrderRecord]`) — but it is **not exposed by the shared
view model** (`FactoryViewModel` has no `orders` field, `factoryApi.ts` has no
`fetchOrders` function), and both files are explicitly **protected surfaces for this
node**. Wiring it in would require modifying `useFactoryViewModel.ts`/`types.ts`
(forbidden) or adding a second, parallel fetch call outside the shared view model
(forbidden — "no parallel initial-data orchestration," "no duplicated initial-data
fetching"). **Finding: order/stock/staffing secondary information is real backend data
but is architecturally unreachable from this node's approved surface** — this is
stronger than "doesn't exist," and is recorded precisely so as not to overstate the
gap. Per the directive's own instruction ("omit unavailable secondary information
rather than fabricate it"), the secondary-info tab will render and state plainly that
this information is not available in this view — the tab itself is real UI (matching
D9B's required structural affordance), its content honestly reports the gap.

## 9. Attention Derivation Rule (unchanged from D9C-4)

`blocked_reason != null && !package_ship_status.terminal` — single tier, deterministic,
identical rule, reused verbatim (this is a truth-derivation rule, not
Attention-First-specific presentation code — reusing the *rule* is not the same as
reusing the forbidden shared-abstraction *component*).

## 10. Assembler Unit-Strip Eligibility / Initial-Focus Rule

Same finding as D9C-4 recon §8: no data distinguishes "assigned to this specific
assembler" (no auth, `assigned_operator_id` only reflects whichever free-text actor id
last happened to submit a scan). **The secondary strip lists all non-terminal units
except the currently-focused one** (truthful language: "Other Units," "Relevant
Units," or similar — never "assigned to me"). **Initial focus rule**: the first
non-terminal unit in `vm.units` (identical deterministic rule to D9C-4's Assembler,
reused because it's a data-derivation rule, not a UI-presentation pattern — the
*rule* "pick the first non-terminal unit" is genuinely the only truthful,
deterministic option available from the data, regardless of which variant is asking).

## 11. Floor Manager Stage-Grouping Rule

`current_stage_number` is the only canonical, ratified ordering
(`docs/factory-flow-model.md`, per `ai/product-invariants.md` Invariant 1) — the queue
is sorted/grouped by `current_stage_number`, identical rule to D9C-4's Floor Manager
queue (again: reusing a data-truth rule, not a forbidden shared component).

## 12. Secondary-Information Availability Finding

See §8 — a real `/factory/orders` endpoint exists but is outside this node's approved
integration surface (shared view model is protected; no parallel fetch permitted).
Stock/staffing/HR data: confirmed absent from the entire backend (no route matches
`/stock`, `/staffing`, `/inventory` per a fresh grep of `backend/app/routes/*.py` —
only `/factory/orders` exists, and it's out of reach for the reason above). The
secondary-info tab will state this explicitly rather than silently omit the tab or
fabricate content for it.

## 13. Unavailable-Data Handling (locked)

- No current-user identity → no "assigned to me" language anywhere.
- No failure-instruction table → reuse the same mechanical `blocked_reason` reformat
  pattern established in D9C-4 (a generic string utility, not Attention-First's
  specific `formatBlockedReason` export, which lives in a protected file — a small,
  independent copy of the same trivial transform is written for this node, not an
  import from `attention-first/`).
- No live telemetry → no "in progress right now" badge, same as D9C-4.
- Orders data unreachable from this node's surface → secondary-info tab states this
  truthfully.

## 14. Action-Surface Architecture

New `WorkflowActionForm.tsx` (name deliberately distinct from D9C-4's
`AttentionActionForm.tsx` to avoid implying a shared component), implementing the
identical stage-to-action mapping (stage 5 reallocate / stage 10 calibration or
disposition / stage 12 cloud-backup retry) against the same unmodified `factoryApi.ts`
functions. Presented **inline** within the stable focused-unit card (Assembler) or
within an expanded triage row (Floor Manager) — never inside a full-screen takeover.
Same "no raw endpoint text, no free-text actor-ID field" constraint as D9C-4, same
fixed demo-actor-id constants reused from `ActionPanel.tsx`'s own defaults.

## 15. Actor-Switching Behavior

Identical pattern to D9C-4: `WorkflowFirstView` calls `useFactoryViewModel()` once,
holds `activeActor` state, passes the same `vm` object to whichever actor sub-view is
active — switching actors never remounts the hook.

## 16. Docker Rebuild / Current-Source Validation Procedure (per D9C-4 incident)

Confirmed still applicable: `docker-compose.yml`'s `frontend` service has no volume
mount (re-confirmed via `docker inspect ndt-factory-cloud-frontend-1 --format
'{{json .Mounts}}'` → `[]`, unchanged since D9C-4). Before any live Playwright
verification: `docker compose build frontend && docker compose up -d --force-recreate
frontend`, then confirm via `curl -s http://localhost:5173/src/components/
variant-review/VariantReviewShell.tsx | grep WorkflowFirstView` that the served module
actually references the new component before trusting any browser test.

## 17. Backend Test-State Isolation Procedure (per D9C-4 incident)

The D9C-4 incident (`ai/incidents` — documented in the D9C-4 journal addendum, not a
separate incident file since it required no process change beyond awareness) found the
backend can become transiently unresponsive under rapid, back-to-back manual
mutation/reset calls (Postgres lock contention observed in `docker compose logs
postgres`, recovered via `docker compose restart backend`). Procedure for this node:
pace mutation tests (one action, confirm result, reset only when done — not
back-to-back resets), and if a hang is observed, restart the `backend` service
(Postgres itself is never restarted, no data loss) and re-verify the full corpus before
continuing.

## 18. Pre-Existing TypeScript/Lint Baseline

Documented consistently across D9C-2/D9C-3/D9C-4 verification runs: `tsc --noEmit`
inside an ephemeral container reports errors in `frontend/src/api.ts`,
`frontend/src/api/factoryApi.ts`, `frontend/src/components/{ActionPanel,
DataContractStatus,FactoryFlowBoard}.tsx` — all pre-existing `ImportMeta.env` typing
and unused-variable lint issues, confirmed unrelated to and unmodified by any D9C node
so far. This node will re-run the same check and confirm zero *new* errors are
introduced by the new `workflow-first/` files, per the directive's explicit
baseline-comparison requirement.

## 19. Selector Naming Discrepancy (same finding as D9C-3/D9C-4, same resolution)

`VariantReviewShell.tsx`'s tab label remains `'Variant B — Workflow-First'` (not the
directive's bare canonical `Workflow-First`). Same resolution as before: this is
settled D9C-1 shell chrome, out of scope for a content-only capability, not touched.

## 20. Exact Component Boundary

New directory `frontend/src/components/variant-review/workflow-first/`:

- `WorkflowFirstView.tsx` — root; calls `useFactoryViewModel()` once; holds
  `activeActor` state; renders `AssemblerWorkflowView`/`FloorManagerWorkflowView`.
- `AssemblerWorkflowView.tsx` — one stable card (never swapped for a distinct
  "interrupt" component); focused unit chosen via `vm.selectedUnit`/`vm.selectUnit`
  (default: first non-terminal unit); a persistent bottom strip of other non-terminal
  units for deliberate focus-switching; blocked info (if any) rendered as an **inline
  section within the same card**, not a takeover; `WorkflowActionForm` rendered inline
  when a mapped action exists for the focused unit's stage/condition.
- `FloorManagerWorkflowView.tsx` — persistent queue (grouped/sorted by
  `current_stage_number`) as the primary, always-rendered view; a small attention-count
  badge that toggles an in-place, collapsible triage list (not always-rendered above
  the queue like D9C-4 — must be explicitly expanded/collapsed); a secondary-info tab
  alongside the queue that, when opened, truthfully states no order/stock/staffing data
  is available in this view.
- `WorkflowActionForm.tsx` — shared within this node only (not exported to or imported
  from `attention-first/`), same stage-to-action mapping as D9C-4's
  `AttentionActionForm`, independently implemented.
- `frontend/src/components/variant-review/VariantReviewShell.tsx` — modified only to
  render `<WorkflowFirstView/>` for the `variantB` tab; `variantA`/`variantC` and all
  tab labels unchanged.

## 21. Architecture Risks

- **Accidental convergence with Attention-First**: mitigated by the explicit structural
  contract in §5 (no card-swap takeover, actor-driven-only focus change, expand/
  collapse triage vs. always-shown). The new verification script will assert these
  structural markers directly (e.g., no full-screen-takeover class/element swap tied to
  `blocked_reason`).
- **Secondary-info tab honesty**: must render real UI (a tab), not skip it, while its
  content must not fabricate order/stock data — verified by checking the tab exists and
  its content contains an explicit "not available" statement, no numbers.
- **Backend lock contention recurrence**: mitigated by the paced-testing procedure in
  §17.

## 22. Invariant Interactions

Identical to D9C-4 (`ai/product-invariants.md` Invariant 2/3 unaffected/reinforced — no
new mutation path, no client-side transition legality, truthful "no action available"
states correctly reflect real hard-stops).

## 23. Protected Surfaces Confirmed (paths verified to exist exactly as named)

`frontend/src/components/{FactoryFlowBoard,ActionPanel,UnitList,StageSpine,
UnitDetailPanel,EventTrace}.tsx`, `frontend/src/components/variant-review/
attention-first/` (all four files), `frontend/src/view-model/{types.ts,
useFactoryViewModel.ts}`, `frontend/src/api/factoryApi.ts`, `frontend/src/types/
factory.ts`, `frontend/src/main.tsx`, `frontend/src/App.tsx`, `frontend/package.json`,
`frontend/package-lock.json`, `backend/`, `data/`, `vendor/`, `.engineering-os/`.
(`migrations/` does not exist as a top-level dir — real migration tooling is
`backend/alembic/`, covered by `backend/`'s protection.)

## 24. Verification Plan

`scripts/verification/014-d9c-5-workflow-first-actor-views.sh` (next available number
after `013`), authored directly by the orchestrator per the D9C-3/D9C-4 established
process — never delegated to a task-graph worker. Must assert: functional (non-
placeholder) Workflow-First content; shared-view-model single-invocation; no
`fetch*` import outside the hook; only `WorkflowActionForm.tsx` imports the four action
functions; no raw endpoint text; no free-text actor-ID field; single attention tier; a
structural marker proving no full-screen-takeover pattern exists (e.g., absence of a
component-swap keyed directly to `blocked_reason` the way D9C-4's does); `VariantReviewShell.tsx`
diff scoped to the `variantB` branch only; all protected files unchanged; nothing under
`backend/`/`data/`/`vendor/`/`.engineering-os/` touched.

## 25. Smoke-Test Plan

Rebuild+recreate the frontend image, positively confirm the served bundle contains
`WorkflowFirstView` before any browser assertions, then: Assembler focus-switch via the
strip, an inline blocked state (no takeover) with an available action executed once
against the live backend, Floor Manager queue + attention badge expand/collapse,
resolving one action from the triage list, checking the secondary-info tab's honest
"not available" content, confirming Current/Attention-First/Command-Center are
unaffected, resetting demo state at the end, and confirming zero residue.

## 26. Conflict / Ambiguity Discovered

**No `Conflict: STOP` condition met.** A functional Workflow-First design is fully
producible from truthfully available data without inventing assignment, secondary
data, telemetry, instructions, or workflow authority — the same resolutions D9C-4
already established apply identically here, plus one new, precisely-scoped finding
(order data exists but is outside this node's approved integration surface, handled by
an honest "not available" tab rather than either fabricating content or silently
omitting the required tab affordance). Proceeding directly to STEP 1 (spec
compilation).
