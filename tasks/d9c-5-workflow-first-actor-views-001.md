# Task: Build functional Workflow-First actor views (Assembler + Floor Manager)

## Parent Spec
specs/d9c-5-workflow-first-actor-views.md

## Phase
phase-ui

## Status
done

## Layer
frontend

## Description

You have no prior conversation context. Read `specs/d9c-5-workflow-first-actor-views.md`
in full before starting, and also `ai/recon/d9c-5-workflow-first-actor-views.md` — the
recon documents exactly which facts are truthfully available and the required
**structural differences** from the already-completed Attention-First variant. Do not
deviate from either.

**Goal:** replace the inert `variantB` placeholder with a functional Workflow-First
experience for Assembler and Floor Manager, built on the existing, unmodified
`useFactoryViewModel()` hook — and **structurally distinct** from Attention-First
(D9C-4, already shipped at `frontend/src/components/variant-review/attention-first/`).

### Critical constraint: do not copy Attention-First's structure

Read `frontend/src/components/variant-review/attention-first/{AttentionFirstView,
AssemblerView,FloorManagerView,AttentionActionForm}.tsx` for reference only — **do not
import from this directory, do not modify it, and do not replicate its interaction
model.** Attention-First's Assembler *replaces* its calm card with a completely
different, dominant error-styled card the instant a unit is blocked (a "takeover").
Workflow-First must **never do this**:

- The Assembler view must use **one stable card layout** at all times. When the
  focused unit is blocked, blocked information appears as an **additional section
  inside that same card** — same outer structure, same card, not a different
  component swapped in.
- Focus must change **only** when the actor deliberately taps another unit in the
  strip — never automatically because the focused unit becomes blocked. (Contrast:
  Attention-First's focus stays on the same unit but the *card itself* changes
  appearance/structure when blocked — Workflow-First's card structure must not
  change based on blocked state at all, only its content grows by one section.)
- The Floor Manager's attention list must be **collapsed by default**, expanding only
  when the actor taps an attention badge/counter, and collapsing again on request —
  not always-rendered above the queue the way Attention-First's triage list is.

### Reference reading (do not modify any of these)

- `frontend/src/view-model/types.ts` / `useFactoryViewModel.ts` — the hook contract.
- `frontend/src/types/factory.ts` — same relevant `FactoryUnit` fields as before:
  `blocked_reason: string | null`, `block_type: string | null`, `no_override: boolean`,
  `current_stage_number: number`, `package_ship_status: { terminal: boolean }`,
  `calibration_summary: { cap_exceeded?: boolean }`, `part_allocations`.
- `frontend/src/api/factoryApi.ts` — `postReallocatePart`, `postCalibration`,
  `postCalibrationDisposition`, `postCloudBackup` — import only, do not modify.
- `frontend/src/components/ActionPanel.tsx` — read for reference (same reasoning as
  D9C-4: it exposes raw endpoint text and a generic Dev panel, both forbidden here
  too) but do not reuse it as a child, do not modify it.
- `frontend/src/components/variant-review/attention-first/*.tsx` — read for contrast
  only, per the constraint above. Do not import from this directory.
- `frontend/src/components/variant-review/VariantPlaceholderPane.tsx` — reference for
  the existing Assembler/Floor Manager secondary-tab visual pattern
  (`touch-target-secondary`, `surf-primary`/`t-on-primary` selected,
  `surf-container`/`t-on-surface`/`b-outline-var` unselected). Do not modify — still
  used by `variantC`.
- `frontend/src/components/variant-review/VariantReviewShell.tsx` — you WILL modify
  this one (Part E below).

### Truth constraints (identical reasoning to D9C-4 — see recon for full justification)

- No login/auth, no "assigned to me" data. Use language like "Other Units," "Relevant
  Units," or "Units in Queue" — never claim personal assignment.
- Attention/blocked derivation: exactly `unit.blocked_reason != null &&
  !unit.package_ship_status.terminal`. Single tier — no severity levels.
- No failure-instruction lookup table — reformat `blocked_reason` mechanically
  (underscore→space, sentence case) via a small, local pure function in this node's own
  files (do not import `attention-first/AssemblerView.tsx`'s `formatBlockedReason` —
  write an independent, equivalent one-line copy here instead).
- No live "in progress right now" telemetry — do not build any such badge.
- A real `/factory/orders` backend endpoint exists, but it is **out of scope** — do not
  add a `fetchOrders` call or modify `factoryApi.ts`/the view model. The Floor
  Manager's secondary-info tab must render and, when opened, show a plain, honest
  message that order/stock/staffing information is not available in this view — no
  fabricated numbers, no fetch call.

### Stage-to-action mapping (identical to D9C-4 — reuse the same logic, independently implemented)

| `current_stage_number` | Condition | Action | `factoryApi` function | Demo actor id |
|---|---|---|---|---|
| 5, blocked | bad/missing part | Reallocate part | `postReallocatePart` | `USER-SUP-0001` |
| 10, `calibration_summary.cap_exceeded` falsy | in-progress retry | Submit calibration result | `postCalibration` | `USER-TECH-0001` |
| 10, `calibration_summary.cap_exceeded` true | cap exceeded | Disposition (route back to hardware / scrap / quarantine) | `postCalibrationDisposition` | `USER-MGR-0001` |
| 12, blocked | cloud backup blocked | Retry cloud backup | `postCloudBackup` | `USER-OP-0001` |
| anything else (e.g. 7) | — | **no action available** | — | — |

Stage 5 and cap-exceeded stage 10 require supervisor/manager-tier actors per
`ActionPanel.tsx`'s own field labels — expose these only in the Floor Manager's triage
resolution, not inline in the Assembler card. Stage 12's cloud-backup retry is the one
action safe to expose directly in the Assembler's inline blocked section too (same
reasoning as D9C-4).

### Part A — `frontend/src/components/variant-review/workflow-first/WorkflowActionForm.tsx`

Independently implement the same behavior as D9C-4's `AttentionActionForm.tsx`
(described above in the stage-to-action mapping) — same request shapes, same fixed
demo-actor-id constants, same "no raw endpoint text, no free-text actor-ID field"
constraint, same `onDone()` callback contract (parent decides `vm.refreshSelected()` vs
`vm.reload()`). Do not import from `attention-first/`; write this as a self-contained
file in the new `workflow-first/` directory.

### Part B — `frontend/src/components/variant-review/workflow-first/AssemblerWorkflowView.tsx`

`AssemblerWorkflowView({ vm })`:
- On first render, if `vm.selectedUnitId` is null, call `vm.selectUnit` on the first
  non-terminal unit (`vm.units.filter(u => !u.package_ship_status.terminal)[0]`).
- Render **one card** (not two alternating card types): unit id, its stage name (via
  `vm.stages`), and — **always in this same card** — an inline "Attention" section that
  only appears (as an additional block within the card, not a replacement of it) when
  `focused.blocked_reason != null`: the reformatted reason, a `NO OVERRIDE` marker if
  applicable, and `WorkflowActionForm` inline (only for stage 12) or a truthful "Needs
  floor manager approval" line otherwise (same logic as D9C-4's Assembler, but
  presented as a section within the persistent card, not a full-bleed replacement of
  it — no distinct component/branch that swaps the entire card's outer structure).
- Below the card, a persistent strip of the other non-terminal units (tap to call
  `vm.selectUnit` — this is the only way focus changes).
- No raw endpoint text, no free-text actor-ID field, no forced-open engineering detail.

### Part C — `frontend/src/components/variant-review/workflow-first/FloorManagerWorkflowView.tsx`

`FloorManagerWorkflowView({ vm })`:
- `blockedUnits = vm.units.filter(u => u.blocked_reason != null && !u.package_ship_status.terminal)`.
- Render the **queue** (`vm.units.filter(u => !u.package_ship_status.terminal)`,
  sorted by `current_stage_number`) as the persistent primary content — always visible.
- An attention badge/counter (`blockedUnits.length`) that the actor must **tap to
  expand** a triage list (`useState` boolean, default `false`/collapsed); expanding
  shows `blockedUnits` with a resolve control revealing `WorkflowActionForm` per unit
  (same as D9C-4's triage pattern, but collapsed by default and explicitly
  toggle-able, not always rendered).
- A second, separately-selectable tab/section ("Secondary Info" or similar) that, when
  opened, shows a plain message such as "Order, stock, and staffing information is not
  available in this view." — no fetch call, no numbers.
- No raw endpoint text, no free-text actor-ID field.

### Part D — `frontend/src/components/variant-review/workflow-first/WorkflowFirstView.tsx`

`WorkflowFirstView()`:
- `const vm = useFactoryViewModel()` — exactly once.
- `const [activeActor, setActiveActor] = useState<'assembler' | 'floorManager'>('assembler')`.
- Secondary tab bar identical in visual pattern to `VariantPlaceholderPane.tsx`'s
  existing Assembler/Floor Manager switcher.
- Renders `<AssemblerWorkflowView vm={vm} />` or `<FloorManagerWorkflowView vm={vm} />`
  based on `activeActor` — never re-invoke the hook.
- Handle `vm.loadError` and an initial loading state, same pattern as D9C-4's
  `AttentionFirstView`.

### Part E — modify `frontend/src/components/variant-review/VariantReviewShell.tsx`

Change only the `variantB` branch:
```tsx
import { WorkflowFirstView } from './workflow-first/WorkflowFirstView'
// ...
{activeTab === 'variantB' && <WorkflowFirstView />}
```
removing the old `<VariantPlaceholderPane variantId="variantB" .../>` line for that
branch only. Do not change `variantA`/`variantC`, the `TABS` array, or any tab label.
Keep the `VariantPlaceholderPane` import (still used by `variantC`).

## Acceptance Criteria
- [ ] `frontend/src/components/variant-review/workflow-first/{WorkflowFirstView,
      AssemblerWorkflowView,FloorManagerWorkflowView,WorkflowActionForm}.tsx` all exist.
- [ ] `WorkflowFirstView` calls `useFactoryViewModel` exactly once; no other new file
      calls it.
- [ ] No new file imports a `fetch*` read function; only `WorkflowActionForm.tsx`
      imports the four action-submission functions.
- [ ] `AssemblerWorkflowView` uses one persistent card structure regardless of blocked
      state — blocked info is an additional inline section, never a component/branch
      swap of the whole card.
- [ ] Focus in `AssemblerWorkflowView` only changes via an explicit tap on another
      unit in the strip.
- [ ] `FloorManagerWorkflowView`'s triage list defaults to collapsed and requires an
      explicit tap to expand; the queue is always rendered underneath.
- [ ] A secondary-info section/tab exists and states plainly that order/stock/staffing
      data is unavailable — no fabricated numbers, no new fetch call.
- [ ] `VariantReviewShell.tsx`'s `variantB` branch renders `<WorkflowFirstView/>`;
      `variantA`/`variantC` and all tab labels unchanged.
- [ ] No raw endpoint-path text, no free-text actor-ID input, anywhere in the four new
      files.
- [ ] `frontend/src/components/variant-review/attention-first/**`, `ActionPanel.tsx`,
      `FactoryFlowBoard.tsx`, `useFactoryViewModel.ts`, `types.ts`, `factoryApi.ts`,
      `UnitList.tsx`, `StageSpine.tsx`, `UnitDetailPanel.tsx`, `EventTrace.tsx`,
      `main.tsx`, `App.tsx`, `VariantPlaceholderPane.tsx` are byte-for-byte unchanged.
- [ ] No file under `backend/`, `data/`, `vendor/`, `.engineering-os/` touched.
- [ ] Type-checks cleanly in strict mode, no `any`.

## Files Likely Affected
- frontend/src/components/variant-review/workflow-first/WorkflowFirstView.tsx (new)
- frontend/src/components/variant-review/workflow-first/AssemblerWorkflowView.tsx (new)
- frontend/src/components/variant-review/workflow-first/FloorManagerWorkflowView.tsx (new)
- frontend/src/components/variant-review/workflow-first/WorkflowActionForm.tsx (new)
- frontend/src/components/variant-review/VariantReviewShell.tsx (modified, variantB branch only)
- frontend/src/styles.css (only if a bounded new class is truly needed)

## Blocked By
- none
