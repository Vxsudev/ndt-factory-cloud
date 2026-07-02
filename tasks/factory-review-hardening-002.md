# Task: Harden unit detail block section and action panel response clarity

## Parent Spec
specs/factory-review-hardening.md

## Phase
phase-demo-readiness

## Status
done

## Layer
frontend

## Description
Update UnitDetailPanel.tsx to add an explicit "Block / Hard-Stop" section showing
blocked_reason, no_override, and block_type prominently. Update ActionPanel.tsx to
display "Backend-guarded action" label, the endpoint URL for each action, and a
comprehensive response box with all backend response fields.

## Acceptance Criteria
- [ ] UnitDetailPanel shows "Block / Hard-Stop" section when unit.blocked_reason is non-null
- [ ] Section shows blocked_reason in red prominently
- [ ] Section shows no_override as "NO OVERRIDE — No bypass possible" in red bold when true
- [ ] Section shows block_type label
- [ ] ActionPanel each form header shows "Backend-guarded action" label
- [ ] ActionPanel each form shows the POST endpoint URL
- [ ] ActionPanel response box shows: status badge, message, event_id, blocked_reason, no_override
- [ ] ActionPanel "no actions available" message when stage has no relevant form

## Files Likely Affected
- frontend/src/components/UnitDetailPanel.tsx (UPDATE)
- frontend/src/components/ActionPanel.tsx (UPDATE)

## Blocked By
- tasks/factory-review-hardening-001.md
