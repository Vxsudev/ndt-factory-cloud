# Task: Correct two cross-variant action-eligibility/payload drift items

## Parent Spec
specs/d9d-cross-variant-parity.md

## Phase
phase-ui

## Status
done

## Layer
frontend

## Description

You have no prior conversation context. Read `specs/d9d-cross-variant-parity.md` in
full before starting, and `ai/recon/d9d-cross-variant-parity.md` for the full
justification behind both corrections. This task makes exactly two narrow,
independent corrections across four files — do not do anything beyond what is
specified here.

### Correction 1 — expose the always-visible primary action in Workflow-First and Command-Center's Assembler calm state

**Context**: `attention-first/AssemblerView.tsx` already correctly renders
`<AttentionActionForm/>` in its calm (non-blocked) state, so a backend-supported
action like "submit calibration result" (stage 10, not cap-exceeded) is visible for a
focused unit that is mid-calibration but not blocked (e.g. the canonical UNIT-0003).
`workflow-first/AssemblerWorkflowView.tsx` and `command-center/AssemblerCommandView.tsx`
never call their own `*ActionForm` outside their `isBlocked` block, so this same
action is silently invisible in those two variants — a real parity gap, and a
deviation from each variant's own design intent (`ai/recon/d9b-three-functional-actor-first-ui-variants.md`
§6/§7 both call for an always-visible "one primary action").

**Exact edit for `frontend/src/components/variant-review/workflow-first/AssemblerWorkflowView.tsx`**:

The file currently has this shape (do not change anything except what's noted):
```tsx
return (
  <div className="p-4 space-y-4">
    <div className="rounded-xl border surf-container b-outline-var p-4 space-y-3">
      <div className="text-xs font-semibold uppercase tracking-widest t-on-surface-var">
        Current Unit
      </div>
      <div className="font-mono text-lg font-bold t-on-surface">{focused.id}</div>
      <div className="text-sm t-on-surface-var">{stageName}</div>

      {isBlocked && (
        <div className="rounded-lg border-2 surf-error b-error p-3 space-y-2">
          {/* ... existing Attention section, unchanged ... */}
        </div>
      )}
    </div>
    {/* ... Other Units section, unchanged ... */}
  </div>
)
```
Add a new sibling block **immediately after** the closing `)}` of the existing
`{isBlocked && (...)}` block, still inside the same "Current Unit" `<div>`:
```tsx
      {!isBlocked && (
        <WorkflowActionForm
          unit={focused}
          parts={vm.parts}
          refStandards={vm.refStandards}
          onDone={() => void vm.refreshSelected()}
        />
      )}
```
Do not change the existing `{isBlocked && (...)}` block's contents at all. Do not use
a ternary (`isBlocked ? ... : ...`) — keep these as two separate, sibling
`{condition && (...)}` blocks, exactly as shown.

**Exact edit for `frontend/src/components/variant-review/command-center/AssemblerCommandView.tsx`**:

The file currently has this shape:
```tsx
return (
  <div className="p-4 space-y-4">
    {isBlocked && (
      <div className="rounded-lg border-2 surf-error b-error px-3 py-2.5 space-y-2">
        {/* ... existing Attention section, unchanged ... */}
      </div>
    )}

    <div className="rounded-xl border surf-container b-outline-var p-4 space-y-2">
      <div className="text-xs font-semibold uppercase tracking-widest t-on-surface-var">
        Current Unit
      </div>
      <div className="font-mono text-lg font-bold t-on-surface">{focused.id}</div>
      <div className="text-sm t-on-surface-var">{stageName}</div>
    </div>
    {/* ... Other Units, Supporting Detail, unchanged ... */}
  </div>
)
```
Add the new call **inside** the "Current Unit" `<div>`, as a new line after the
`{stageName}` line:
```tsx
      <div className="text-sm t-on-surface-var">{stageName}</div>
      {!isBlocked && (
        <CommandCenterActionForm
          unit={focused}
          parts={vm.parts}
          refStandards={vm.refStandards}
          onDone={() => void vm.refreshSelected()}
        />
      )}
```
Do not change the existing `{isBlocked && (...)}` Attention block at all. Do not use a
ternary.

### Correction 2 — require a non-empty new serial number before allowing Stage-5 reallocation submission

**Context**: none of the three `*ActionForm.tsx` files currently prevents submitting
an empty `new_serial_number` — the "Submit Reallocation" button is only disabled
while `loading`. Apply the identical fix to all three files:

- `frontend/src/components/variant-review/attention-first/AttentionActionForm.tsx`
- `frontend/src/components/variant-review/workflow-first/WorkflowActionForm.tsx`
- `frontend/src/components/variant-review/command-center/CommandCenterActionForm.tsx`

In each file's stage-5 branch, find:
```tsx
        <SubmitButton
          label="Submit Reallocation"
          loading={loading}
          onClick={() =>
```
and add a `disabled` prop matching this pattern (adjust `SubmitButton`'s own
signature if needed — it currently only accepts `loading`, `onClick`, `label`,
`tone`; extend it minimally to also honor a `disabled` boolean, OR — simpler and
requiring no signature change — pass a combined condition through the existing
`loading` prop is NOT correct since that also drives the "Submitting…" label text, so
instead add a new optional `disabled?: boolean` prop to the shared `SubmitButton`
function in each file, defaulting to `false`, and combine it with the existing
`loading` check: `disabled={loading || disabled}` inside `SubmitButton`, then pass
`disabled={newSerial.trim().length === 0}` from the Stage-5 call site only (the other
four `SubmitButton` call sites — calibration, three disposition buttons, cloud-backup
retry — do not pass this new prop and are unaffected, defaulting to `false`).

Do not add this validation to any other stage's submit button — only the Stage-5
"Submit Reallocation" button gets the new-serial-non-empty guard.

## Constraints

- Do not touch `attention-first/AssemblerView.tsx` or
  `attention-first/FloorManagerView.tsx` for Correction 1 — Attention-First's
  calm-state visibility is already correct; it only needs Correction 2 (applied to
  `AttentionActionForm.tsx`).
- Do not touch `workflow-first/FloorManagerWorkflowView.tsx`,
  `command-center/FloorManagerCommandView.tsx`, or `VariantReviewShell.tsx`.
- Do not touch any protected surface (`ActionPanel.tsx`, `FactoryFlowBoard.tsx`, the
  shared view-model, `factoryApi.ts`, `types/factory.ts`, backend, data, vendor).
- Do not touch `scripts/`, `ai/`, `specs/`, `tasks/` — orchestrator-owned for this
  capability.
- Do not introduce an `isBlocked ?` ternary anywhere — use separate
  `{condition && (...)}` blocks as shown.
- Do not add any new dependency, do not do any visual/touch polish beyond what's
  specified.

## Acceptance Criteria
- [ ] `AssemblerWorkflowView.tsx`'s Current Unit region additionally renders
      `WorkflowActionForm` when `!isBlocked`, via a separate `{!isBlocked && (...)}`
      block (no ternary); the existing `{isBlocked && (...)}` block is unchanged.
- [ ] `AssemblerCommandView.tsx`'s Current Unit region additionally renders
      `CommandCenterActionForm` when `!isBlocked`, via a separate block (no ternary);
      the existing Attention block is unchanged.
- [ ] All three `*ActionForm.tsx` files disable "Submit Reallocation" when
      `newSerial.trim().length === 0`, in addition to the existing `loading` check;
      no other submit button in any file is affected.
- [ ] `attention-first/{AssemblerView,FloorManagerView}.tsx`,
      `workflow-first/FloorManagerWorkflowView.tsx`,
      `command-center/FloorManagerCommandView.tsx`, `VariantReviewShell.tsx`, and all
      protected files are byte-for-byte unchanged.
- [ ] No file under `backend/`, `data/`, `vendor/`, `.engineering-os/`, or `scripts/`
      touched.
- [ ] Type-checks cleanly in strict mode, no `any`.

## Files Likely Affected
- frontend/src/components/variant-review/workflow-first/AssemblerWorkflowView.tsx
- frontend/src/components/variant-review/command-center/AssemblerCommandView.tsx
- frontend/src/components/variant-review/attention-first/AttentionActionForm.tsx
- frontend/src/components/variant-review/workflow-first/WorkflowActionForm.tsx
- frontend/src/components/variant-review/command-center/CommandCenterActionForm.tsx

## Blocked By
- none
