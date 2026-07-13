# Task: Build functional Attention-First actor views (Assembler + Floor Manager)

## Parent Spec
specs/d9c-4-attention-first-actor-views.md

## Phase
phase-ui

## Status
done

## Layer
frontend

## Description

You have no prior conversation context. Read `specs/d9c-4-attention-first-actor-views.md`
in full before starting — it is the authority for this task. Also read
`ai/recon/d9c-4-attention-first-actor-views.md` — it documents exactly which facts are
truthfully available in the data and which are not; do not deviate from its findings.

**Goal:** replace the inert `variantA` placeholder inside the `/#/variants` review
shell with a real, functional Attention-First experience for two actor sub-views —
Assembler and Floor Manager — built entirely on the existing, unmodified
`useFactoryViewModel()` hook (from D9C-2/D9C-3, already consumed by `FactoryFlowBoard`).

### Reference reading (read these existing files first, do not modify most of them)

- `frontend/src/view-model/types.ts` / `useFactoryViewModel.ts` — the hook contract you
  will consume. **Do not modify.**
- `frontend/src/types/factory.ts` — `FactoryUnit` has `blocked_reason: string | null`,
  `block_type: string | null`, `no_override: boolean`, `current_stage_number: number`,
  `package_ship_status: { terminal: boolean, ... }`, `calibration_summary: { cap_exceeded?:
  boolean, ... }`, `part_allocations: Record<string, { part_id, status, bound_at? }>`.
  **Do not modify.**
- `frontend/src/api/factoryApi.ts` — exports `postReallocatePart`, `postCalibration`,
  `postCalibrationDisposition`, `postCloudBackup` (among others) with their exact
  request types from `types/factory.ts`. **Do not modify — import from it only.**
- `frontend/src/components/ActionPanel.tsx` — read for reference (exact request shapes,
  existing demo actor-id constants, existing stage-to-form mapping) but **do not reuse
  it as a child and do not modify it.** It unconditionally renders a raw endpoint-path
  line and an always-visible "Dev — Backend-Guarded Transition" panel — both explicitly
  forbidden in actor-first views. Build new, minimal components instead that call the
  same underlying `factoryApi.ts` functions directly.
- `frontend/src/components/variant-review/VariantPlaceholderPane.tsx` — reference for
  the existing Assembler/Floor Manager secondary-tab-bar visual pattern
  (`touch-target-secondary`, `surf-primary`/`t-on-primary` for selected,
  `surf-container`/`t-on-surface`/`b-outline-var` for unselected). Reuse this exact
  pattern for the new actor switcher. **Do not modify this file** — it remains in use
  for `variantB`/`variantC`.
- `frontend/src/components/variant-review/VariantReviewShell.tsx` — you WILL modify
  this one (see Part D below).

### Truth constraints (do not violate these — see recon for full justification)

- There is no login/auth and no real "assigned to this specific person" data (recon §8).
  Never claim a unit is "assigned to me." The Assembler's "current unit" is a
  **manually-focused** unit using the same `vm.selectedUnitId`/`vm.selectUnit` mechanism
  Current already uses — default it to the first non-terminal unit in `vm.units` on
  first render if nothing is focused yet.
- Attention/blocked derivation is exactly: `unit.blocked_reason != null &&
  !unit.package_ship_status.terminal`. This is the **only** signal — do not invent
  severity tiers.
- There is no failure-mode-to-instruction lookup table anywhere in this codebase. Do
  not author one. Instead, reformat `blocked_reason` for readability: replace `_` with
  spaces and sentence-case it (e.g. `cloud_unreachable_sw_update_cannot_proceed` →
  `Cloud unreachable sw update cannot proceed`). Write this as a small, pure string
  function, not a lookup table of authored sentences.
- There is no live "actively in progress right now" telemetry distinct from stage
  location. Do not build any such badge.
- Not every blocked unit has an available corrective action. Per the stage-to-action
  mapping below, stage 7 (and any stage not listed) has **no** actor-available action —
  show a plain truthful message, not a fabricated button.

### Stage-to-action mapping (exactly reuse `ActionPanel.tsx`'s own logic and defaults)

| `current_stage_number` | Condition | Action | `factoryApi` function | Demo actor id (reuse `ActionPanel.tsx`'s own default constant) |
|---|---|---|---|---|
| 5, blocked (`blocked_reason != null`) | bad/missing part | Reallocate part | `postReallocatePart` | `USER-SUP-0001` |
| 10, `calibration_summary.cap_exceeded` falsy | in-progress retry | Submit calibration result | `postCalibration` | `USER-TECH-0001` |
| 10, `calibration_summary.cap_exceeded` true | cap exceeded | Disposition (route back to hardware / scrap / quarantine) | `postCalibrationDisposition` | `USER-MGR-0001` |
| 12, blocked | cloud backup blocked | Retry cloud backup | `postCloudBackup` | `USER-OP-0001` |
| anything else (e.g. 7) | — | **no action available** | — | — |

Stage 5 and stage 10-cap-exceeded actions require supervisor/manager-tier actors per
`ActionPanel.tsx`'s own field labels (`"Actor User ID (supervisor+)"`) — these are
**Floor-Manager-triage-only** actions in this capability (matching D9B's own narrative:
the assembler gets stuck and a floor manager triages/approves). Stage 12's cloud-backup
retry uses a plain `"Actor User ID"` field in `ActionPanel.tsx` (no supervisor
qualifier) — this is the **one** action exposed directly in the Assembler's own
interrupt state as well as in Floor Manager triage.

### Part A — `frontend/src/components/variant-review/attention-first/AttentionActionForm.tsx`

A single shared component, `AttentionActionForm({ unit, refStandards, onDone })`:
- Given `unit`, determines which row of the mapping table above applies (or none).
- Stage 5: renders a minimal form with just a "Replacement Serial Number" text input
  (the old/new serial and reason fields `ActionPanel` exposes are reduced to just the
  new serial — reuse a sensible fixed default for the rest: `release_reason_code:
  'damaged_at_bench'`, a fixed `reason` string, `old_serial_number` left as an empty
  string matching `ActionPanel`'s own default blank state) and a submit button. Uses
  `part_type` derived from the unit's own `part_allocations` (the first entry whose
  `status !== 'allocated_bound'`).
  Uses `actor_user_id: 'USER-SUP-0001'`.
- Stage 10 not cap-exceeded: a Pass/Fail toggle (reuse `mdc-select`-style pattern from
  `ActionPanel.tsx`) plus a submit button calling `postCalibration` with
  `reference_standard_ids` defaulted to the first `refStandards` entry where
  `can_be_used_for_calibration` is true (fallback `['REFSTD-0001']`), `equipment_id:
  'CAL-EQUIP-01'`, `actor_user_id: 'USER-TECH-0001'`.
- Stage 10 cap-exceeded: three buttons (Route back to hardware / Quarantine / Scrap)
  each calling `postCalibrationDisposition` with the corresponding `disposition` value,
  a fixed `reason` string, `actor_user_id: 'USER-MGR-0001'`.
- Stage 12: a single "Retry Cloud Backup" button calling `postCloudBackup` with
  `cloud_available: true`, `actor_user_id: 'USER-OP-0001'`.
- Any other stage: renders `null` (parent components handle the "no action available"
  message themselves).
- On any successful submission, call the `onDone()` prop (parent decides whether that
  means `vm.refreshSelected()` or `vm.reload()` — see Part B/C).
- On error, show a small inline error message (reuse `t-on-error text-sm` styling).
- No raw endpoint-path text anywhere. No free-text actor-ID input anywhere (all actor
  ids are the fixed constants above, matching `ActionPanel.tsx`'s own default values —
  not inputs the user can edit).
- Use existing tokens only: `touch-target-primary`, `surf-primary`/`t-on-primary`,
  `mdc-input`, `mdc-select`, `t-on-error`, `b-outline-var`, etc. — the same classes
  already used elsewhere in this codebase. No new hardcoded colors.

### Part B — `frontend/src/components/variant-review/attention-first/AssemblerView.tsx`

`AssemblerView({ vm })` where `vm` is the full `FactoryViewModel` return value:
- Compute `nonTerminal = vm.units.filter(u => !u.package_ship_status.terminal)`.
- On first render, if `vm.selectedUnitId` is null, call `vm.selectUnit(nonTerminal[0].id)`
  (guard for empty array).
- `focused = vm.selectedUnit` (fall back to a "loading" state if null).
- If `focused.blocked_reason == null`: **calm state** — one card showing the unit id,
  its stage name (look up `vm.stages` by `focused.current_stage_id` for the display
  name), and a single primary action button appropriate to the stage (reuse
  `AttentionActionForm` inline if the stage/condition matches a mapping-table row that
  makes sense even when not blocked — stage 10 not-blocked calibration retry is a
  normal, non-blocked action too; if no form applies, show no action control, just the
  unit/stage summary). Below it, a compact horizontal strip of the other `nonTerminal`
  units (excluding the focused one) as small tappable chips — each shows the unit id
  and a "BLOCKED" chip if that unit's `blocked_reason != null`; tapping one calls
  `vm.selectUnit(otherUnit.id)`.
- If `focused.blocked_reason != null`: **interrupt state** — a full-bleed card (visually
  dominant — e.g. `surf-error`/`b-error` bordered, larger than the calm card) showing:
  the unit id, the reformatted `blocked_reason` text, a `NO OVERRIDE` marker (reuse the
  `⚠ NO OVERRIDE` styling pattern from `UnitDetailPanel.tsx`) if `focused.no_override`
  is true, then either `<AttentionActionForm unit={focused} refStandards={vm.refStandards}
  onDone={() => void vm.refreshSelected()} />` **only if the stage is 12** (the one
  assembler-appropriate action per the table above), or — for stage 5 / stage 10
  cap-exceeded / any other blocked stage — a plain message: `"Needs floor manager
  approval — visible in the Floor Manager triage list."` Do not render
  `AttentionActionForm` for stage 5 or cap-exceeded stage 10 in this view.
- No raw endpoint text, no free-text actor-ID field, no forced-open engineering detail
  (no reuse of `UnitDetailPanel`'s full collapsible sections — this is a decluttered
  view, only show what's specified above).

### Part C — `frontend/src/components/variant-review/attention-first/FloorManagerView.tsx`

`FloorManagerView({ vm })`:
- `blockedUnits = vm.units.filter(u => u.blocked_reason != null && !u.package_ship_status.terminal)`.
- Always-visible small counter/badge showing `blockedUnits.length` at the top (e.g.
  "0 need attention" / "N need attention", styled distinctly when non-zero — reuse
  `surf-error`/`t-on-error` when `> 0`, a neutral `surf-container` style when `0`).
- **Calm state (or always, alongside the counter)**: the queue — render
  `vm.units.filter(u => !u.package_ship_status.terminal)` grouped/sorted by
  `current_stage_number`, each row showing unit id, stage, and a BLOCKED chip if
  applicable (reuse `UnitList.tsx`'s visual chip pattern, but you are not required to
  reuse the component itself — a new, simpler row is fine).
- **Triage state**: only rendered when `blockedUnits.length > 0` — a list, positioned
  above the queue, of exactly `blockedUnits`, each showing the reformatted
  `blocked_reason`, `NO OVERRIDE` marker where applicable, and a "Resolve" disclosure
  that reveals `<AttentionActionForm unit={u} refStandards={vm.refStandards}
  onDone={() => void vm.reload()} />` for that unit (Floor Manager may resolve stage 5,
  stage-10-cap-exceeded, and stage-12 conditions — i.e., render `AttentionActionForm`
  for every blocked unit here, since `AttentionActionForm` itself returns `null` for
  stages with no defined action, e.g. stage 7, which then falls back to your own
  "no action available" message for that item).
- No raw endpoint text, no free-text actor-ID field.

### Part D — `frontend/src/components/variant-review/attention-first/AttentionFirstView.tsx`

`AttentionFirstView()`:
- `const vm = useFactoryViewModel()` — call exactly once, at the top of this component.
- `const [activeActor, setActiveActor] = useState<'assembler' | 'floorManager'>('assembler')`.
- Render a secondary tab bar identical in visual pattern to
  `VariantPlaceholderPane.tsx`'s existing Assembler/Floor Manager switcher (same
  `touch-target-secondary`/`surf-primary`/`t-on-primary`/`surf-container` classes).
- Render `<AssemblerView vm={vm} />` or `<FloorManagerView vm={vm} />` based on
  `activeActor` — **never re-invoke `useFactoryViewModel()`**, always pass this same
  `vm` object down to whichever child is active.
- Handle `vm.loadError` (show a small error banner, matching the pattern in
  `FactoryFlowBoard.tsx`'s header) and an initial loading state (e.g. `vm.units.length
  === 0 && !vm.loadError` → "Loading…").

### Part E — modify `frontend/src/components/variant-review/VariantReviewShell.tsx`

Change only the `variantA` branch:
```tsx
import { AttentionFirstView } from './attention-first/AttentionFirstView'
// ...
{activeTab === 'variantA' && <AttentionFirstView />}
```
removing the old `<VariantPlaceholderPane variantId="variantA" .../>` line for that
branch only. Do **not** change the `variantB`/`variantC` branches, the `TABS` array, or
any tab-bar label. Do **not** remove the `VariantPlaceholderPane` import if it's still
used by `variantB`/`variantC` (it is).

## Acceptance Criteria
- [ ] `frontend/src/components/variant-review/attention-first/{AttentionFirstView,
      AssemblerView,FloorManagerView,AttentionActionForm}.tsx` all exist.
- [ ] `AttentionFirstView` calls `useFactoryViewModel` exactly once; switching
      `activeActor` does not remount/re-invoke it.
- [ ] No new file imports any `fetch*` read function from `factoryApi.ts`; only
      `AttentionActionForm` imports the four write functions listed above.
- [ ] `VariantReviewShell.tsx`'s `variantA` branch renders `<AttentionFirstView/>`;
      `variantB`/`variantC` and all tab labels are unchanged.
- [ ] Assembler calm state shows one focused unit + a strip of other units; interrupt
      state shows only for `blocked_reason != null`, with the stage-12-only exception
      for an inline action control.
- [ ] Floor Manager shows the queue, an attention counter, and a triage list (only when
      non-zero) with resolve controls for all blocked-and-actionable units.
- [ ] No raw endpoint-path text and no free-text actor-ID input anywhere in the four
      new files.
- [ ] `ActionPanel.tsx`, `FactoryFlowBoard.tsx`, `useFactoryViewModel.ts`, `types.ts`,
      `factoryApi.ts`, `UnitList.tsx`, `StageSpine.tsx`, `UnitDetailPanel.tsx`,
      `EventTrace.tsx`, `main.tsx`, `App.tsx`, `VariantPlaceholderPane.tsx` are
      byte-for-byte unchanged.
- [ ] No file under `backend/`, `data/`, `vendor/`, `.engineering-os/` touched.
- [ ] Type-checks cleanly in strict mode, no `any`.

## Files Likely Affected
- frontend/src/components/variant-review/attention-first/AttentionFirstView.tsx (new)
- frontend/src/components/variant-review/attention-first/AssemblerView.tsx (new)
- frontend/src/components/variant-review/attention-first/FloorManagerView.tsx (new)
- frontend/src/components/variant-review/attention-first/AttentionActionForm.tsx (new)
- frontend/src/components/variant-review/VariantReviewShell.tsx (modified, variantA branch only)
- frontend/src/styles.css (only if a bounded new class is truly needed beyond existing tokens)

## Blocked By
- none
