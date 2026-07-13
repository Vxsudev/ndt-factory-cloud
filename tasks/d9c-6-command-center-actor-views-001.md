# Task: Build functional Command-Center actor views (Assembler + Floor Manager)

## Parent Spec
specs/d9c-6-command-center-actor-views.md

## Phase
phase-ui

## Status
done

## Layer
frontend

## Description

You have no prior conversation context. Read `specs/d9c-6-command-center-actor-views.md`
in full before starting, and also `ai/recon/d9c-6-command-center-actor-views.md` — the
recon documents exactly which facts are truthfully available and the required
**three-way structural distinction** from Current, Attention-First, and Workflow-First.

**Goal:** replace the inert `variantC` placeholder with a functional Command-Center
experience for Assembler and Floor Manager, built on the existing, unmodified
`useFactoryViewModel()` hook — structurally distinct from **both** already-completed
variants (D9C-4 Attention-First, D9C-5 Workflow-First) and from Current.

### Critical constraint: a genuine third structural philosophy

Read `frontend/src/components/variant-review/attention-first/*.tsx` and
`frontend/src/components/variant-review/workflow-first/*.tsx` for reference/contrast
only — **do not import from either directory, do not modify them, do not replicate
their interaction models, and do not silently merge them into something new.**

- **Attention-First's Assembler** replaces its whole calm card with a distinct
  full-bleed error card the instant a unit is blocked (a takeover). **Command-Center
  must never do this.**
- **Workflow-First's Assembler** keeps one stable card with blocked info inline —
  closer to what Command-Center wants, but Command-Center additionally requires a
  **persistent, always-visible Attention banner region** positioned above/alongside
  everything else (not merely an inline section within the current-unit card), plus a
  genuinely **collapsed-by-default** Supporting Detail disclosure that neither prior
  variant has.
- **Workflow-First's Floor Manager** gates its triage list behind an explicit
  `useState(false)` toggle the user must tap to expand — collapsed by default.
  **Command-Center's Floor Manager must render its Attention/Triage region directly
  whenever non-empty, with no toggle gating its visibility at all.**
- **Workflow-First's Floor Manager** puts secondary info behind a separate "Secondary
  Info" tab. **Command-Center's Secondary Context region must always be visible
  alongside the Queue — no tab, no toggle** (just visually quieter/subordinate
  styling).
- Command-Center's four Assembler regions and three Floor Manager regions must all
  render **simultaneously in one screen** — no region is ever hidden by a route swap,
  a tab, or a toggle (only the Attention region's *presence* is conditional on
  `blocked_reason` truthfully existing; its *existence as a UI element*, once present,
  is never toggled away, and the Supporting Detail's open/closed state is the *one*
  legitimate disclosure toggle in this whole capability).

### Reference reading (do not modify any of these)

- `frontend/src/view-model/types.ts` / `useFactoryViewModel.ts` — the hook contract.
- `frontend/src/types/factory.ts` — same relevant `FactoryUnit` fields as the prior two
  variants: `blocked_reason`, `block_type`, `no_override`, `current_stage_number`,
  `package_ship_status.terminal`, `calibration_summary.cap_exceeded`,
  `part_allocations`.
- `frontend/src/api/factoryApi.ts` — `postReallocatePart`, `postCalibration`,
  `postCalibrationDisposition`, `postCloudBackup` — import only, do not modify.
- `frontend/src/components/ActionPanel.tsx` — read for reference only (same reasoning
  as the prior two variants: raw endpoint text + generic Dev panel, both forbidden
  here); do not reuse as a child, do not modify.
- `frontend/src/components/UnitDetailPanel.tsx` — read for reference: note its
  `<details className="group" open>` sections default **open** (markup-only
  disclosure). Command-Center's own Supporting Detail region must default **closed** —
  do not copy this file's `open` default.
- `frontend/src/components/variant-review/{attention-first,workflow-first}/*.tsx` —
  read for contrast only, per the constraint above. Do not import from either
  directory.
- `frontend/src/components/variant-review/VariantPlaceholderPane.tsx` — reference for
  the existing Assembler/Floor Manager secondary-tab visual pattern. Do not modify —
  no longer used by any variant after this task, but leave the file itself untouched
  (it may still be referenced elsewhere or kept as historical scaffold — do not delete
  it).
- `frontend/src/components/variant-review/VariantReviewShell.tsx` — you WILL modify
  this one (Part E below).

### Truth constraints (identical reasoning to D9C-4/D9C-5 — see recon for justification)

- No login/auth, no "assigned to me" data — use "Other Units" or equivalent neutral
  language.
- Attention/blocked derivation: exactly `unit.blocked_reason != null &&
  !unit.package_ship_status.terminal`. Single tier.
- No failure-instruction lookup table — reformat `blocked_reason` mechanically
  (underscore→space, sentence case) via a small, local pure function written fresh in
  this node's own files — do not import either prior variant's copy.
- No live "in progress right now" telemetry.
- A real `/factory/orders` backend endpoint exists but is out of scope — do not add a
  `fetchOrders` call or modify `factoryApi.ts`/the view model. The Floor Manager's
  Secondary Context region must render and state plainly that order/stock/staffing
  information is not available in this view — no fabricated numbers, no fetch call.
- Do not reproduce the full 14-stage `StageSpine`-style spine anywhere — the queue's
  per-unit stage number (`current_stage_number`) is sufficient; a full spine
  reproduces raw engineering detail this capability must keep hidden.

### Stage-to-action mapping (identical to the prior two variants, independently implemented)

| `current_stage_number` | Condition | Action | `factoryApi` function | Demo actor id |
|---|---|---|---|---|
| 5, blocked | bad/missing part | Reallocate part | `postReallocatePart` | `USER-SUP-0001` |
| 10, `calibration_summary.cap_exceeded` falsy | in-progress retry | Submit calibration result | `postCalibration` | `USER-TECH-0001` |
| 10, `calibration_summary.cap_exceeded` true | cap exceeded | Disposition (route back to hardware / scrap / quarantine) | `postCalibrationDisposition` | `USER-MGR-0001` |
| 12, blocked | cloud backup blocked | Retry cloud backup | `postCloudBackup` | `USER-OP-0001` |
| anything else (e.g. 7) | — | **no action available** | — | — |

Stage 5 and cap-exceeded stage 10 require supervisor/manager-tier actors per
`ActionPanel.tsx`'s own field labels — expose these only in the Floor Manager's
triage resolution, not inline in the Assembler's Current Unit region. Stage 12's
cloud-backup retry is safe to expose directly in the Assembler's Attention banner too
(same reasoning as the prior two variants).

### Part A — `frontend/src/components/variant-review/command-center/CommandCenterActionForm.tsx`

Independently implement the same behavior as the other two variants'
`AttentionActionForm.tsx`/`WorkflowActionForm.tsx` (described in the mapping above) —
same request shapes, same fixed demo-actor-id constants, same "no raw endpoint text,
no free-text actor-ID field" constraint, same `onDone()` callback contract. Do not
import from either sibling variant directory; write this as a self-contained file.

### Part B — `frontend/src/components/variant-review/command-center/AssemblerCommandView.tsx`

`AssemblerCommandView({ vm })`:
- On first render, if `vm.selectedUnitId` is null, default-focus the first non-terminal
  unit (same rule as both prior variants).
- Render, **all in one simultaneous layout, top to bottom**:
  1. **Attention banner** — a compact, distinctly-styled (e.g. `surf-error`/`b-error`)
     region rendered **only when `focused.blocked_reason != null`** — reformatted
     reason, `NO OVERRIDE` marker if applicable, and (only for stage 12)
     `CommandCenterActionForm` inline, or a truthful "Needs floor manager approval"
     message otherwise. This banner sits **above** the Current Unit region below it —
     it does not replace or hide it.
  2. **Current Unit region** — always rendered (regardless of blocked state): unit id,
     stage name (via `vm.stages`).
  3. **Other Units region** — always rendered: persistent list of other non-terminal
     units with BLOCKED chips where relevant, tap to call `vm.selectUnit`.
  4. **Supporting Detail region** — a real disclosure control (e.g. a
     `useState(false)` "expanded" flag driving conditional render of a details block,
     or a native `<details>` element with no `open` attribute so it defaults closed)
     showing the focused unit's `part_allocations` (part type → status) when expanded.
     Defaults **closed**.
- No raw endpoint text, no free-text actor-ID field, no full stage-spine reproduction.

### Part C — `frontend/src/components/variant-review/command-center/FloorManagerCommandView.tsx`

`FloorManagerCommandView({ vm })`:
- `blockedUnits = vm.units.filter(u => u.blocked_reason != null && !u.package_ship_status.terminal)`.
- Render, **all simultaneously, top to bottom**:
  1. **Attention/Triage region** — rendered **directly whenever `blockedUnits.length >
     0`** (no `useState` toggle gating whether this region appears at all — if there
     are blocked units, the triage list is simply there), each item showing
     reformatted `blocked_reason`, `NO OVERRIDE` marker, and a "Resolve" disclosure
     revealing `CommandCenterActionForm` (a per-item open/closed toggle for the
     *action form* itself is fine and expected — the constraint is that the region's
     *existence* must not require an extra tap to reveal, unlike Workflow-First).
  2. **Queue region** — always rendered: all non-terminal units, sorted by
     `current_stage_number`, with BLOCKED chips where relevant. Rendered regardless of
     whether the Attention/Triage region above it is present.
  3. **Secondary Context region** — always rendered (no tab, no toggle), visually
     subordinate styling (e.g. smaller text, `surf-container`/`t-on-surface-var`
     rather than the more prominent styling used for Attention/Queue), stating
     plainly: "Order, stock, and staffing information is not available in this
     view."
- No raw endpoint text, no free-text actor-ID field.

### Part D — `frontend/src/components/variant-review/command-center/CommandCenterView.tsx`

`CommandCenterView()`:
- `const vm = useFactoryViewModel()` — exactly once.
- `const [activeActor, setActiveActor] = useState<'assembler' | 'floorManager'>('assembler')`.
- Secondary tab bar identical in visual pattern to the existing
  Assembler/Floor Manager switcher used by the other variants.
- Renders `<AssemblerCommandView vm={vm} />` or `<FloorManagerCommandView vm={vm} />`
  based on `activeActor` — never re-invoke the hook.
- Handle `vm.loadError` and an initial loading state, same pattern as the other two
  variants' root components.

### Part E — modify `frontend/src/components/variant-review/VariantReviewShell.tsx`

Change only the `variantC` branch:
```tsx
import { CommandCenterView } from './command-center/CommandCenterView'
// ...
{activeTab === 'variantC' && <CommandCenterView />}
```
removing the old `<VariantPlaceholderPane variantId="variantC" .../>` line for that
branch only. Do not change `variantA`/`variantB`, the `TABS` array, or any tab label.

**Do not touch anything under `scripts/`.** Two predecessor verification scripts
(`013`, `014`) have a now-stale assertion this capability legitimately invalidates —
updating them is explicitly the orchestrator's job, not yours; leave them exactly as
they are.

## Acceptance Criteria
- [ ] `frontend/src/components/variant-review/command-center/{CommandCenterView,
      AssemblerCommandView,FloorManagerCommandView,CommandCenterActionForm}.tsx` all
      exist.
- [ ] `CommandCenterView` calls `useFactoryViewModel` exactly once; no other new file
      calls it.
- [ ] No new file imports a `fetch*` read function; only `CommandCenterActionForm.tsx`
      imports the four action-submission functions.
- [ ] Zero imports from `attention-first/` or `workflow-first/` in any new file.
- [ ] `AssemblerCommandView` renders all four regions in one simultaneous layout — no
      conditional branch hides the whole Current Unit or Other Units region.
- [ ] Supporting Detail defaults closed.
- [ ] `FloorManagerCommandView`'s Attention/Triage region has no toggle gating its
      overall visibility — it renders directly whenever non-empty.
- [ ] Queue and Secondary Context are always rendered in `FloorManagerCommandView`.
- [ ] Secondary Context states plainly that order/stock/staffing data is unavailable.
- [ ] `VariantReviewShell.tsx`'s `variantC` branch renders `<CommandCenterView/>`;
      `variantA`/`variantB` and all tab labels unchanged.
- [ ] No raw endpoint-path text, no free-text actor-ID input, anywhere in the four new
      files. No full 14-stage spine reproduced.
- [ ] `attention-first/**`, `workflow-first/**`, `ActionPanel.tsx`,
      `FactoryFlowBoard.tsx`, `useFactoryViewModel.ts`, `types.ts`, `factoryApi.ts`,
      `UnitList.tsx`, `StageSpine.tsx`, `UnitDetailPanel.tsx`, `EventTrace.tsx`,
      `main.tsx`, `App.tsx`, `VariantPlaceholderPane.tsx` are byte-for-byte unchanged.
- [ ] No file under `backend/`, `data/`, `vendor/`, `.engineering-os/`, or `scripts/`
      touched.
- [ ] Type-checks cleanly in strict mode, no `any`.

## Files Likely Affected
- frontend/src/components/variant-review/command-center/CommandCenterView.tsx (new)
- frontend/src/components/variant-review/command-center/AssemblerCommandView.tsx (new)
- frontend/src/components/variant-review/command-center/FloorManagerCommandView.tsx (new)
- frontend/src/components/variant-review/command-center/CommandCenterActionForm.tsx (new)
- frontend/src/components/variant-review/VariantReviewShell.tsx (modified, variantC branch only)
- frontend/src/styles.css (only if a bounded new class is truly needed)

## Blocked By
- none
