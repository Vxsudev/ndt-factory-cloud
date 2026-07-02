# Task: Rework UnitDetailPanel, ActionPanel, and EventTrace with MD3 tokens

## Parent Spec
specs/material-theme-readability-d8b.md

## Phase
phase-demo-readiness

## Status
done

## Layer
frontend-components-2

## Description
Apply Material Design 3 semantic CSS classes to UnitDetailPanel, ActionPanel,
and EventTrace components.

UnitDetailPanel:
- Section wrapper cards: .mdc-card (border .b-outline-var, bg .surf)
- Row label text: .t-on-surface-var
- Row value text: .t-on-surface font-mono
- Row dividers: .mdc-divider border color (border-b on rows)
- Block/Hard-Stop section: .surf-error .b-error card
- blocked_reason text: .t-on-error font-semibold text-sm
- NO OVERRIDE text: .t-on-error font-bold text-sm
- Section headers (uppercase tracking-wider): .t-on-surface-var

ActionPanel:
- Form containers by action type:
  - scan/package/ship: .surf .b-outline-var
  - realloc (supervisor): .surf-supervisor .b-supervisor
  - hardware-gate/calibration/qc-signoff: .surf-gate .b-gate
  - cloud-backup: .surf-cloud .b-cloud
  - disposition: .surf-error .b-error
  - transition (inactive): .surf-low .b-outline-var
- All inputs: .mdc-input (replaces bg-slate-50 border-slate-300)
- All selects: .mdc-select (same)
- Submit button: keep bg-blue-600 hover:bg-blue-700 text-white (no change)
- Response success: .surf-success .b-success
- Response blocked: .surf-error .b-error
- Terminal banner: .surf-success .b-success .t-on-success font-semibold
- Status badge success: .surf-success .b-success .t-on-success
- Status badge blocked: .surf-error .b-error .t-on-error

EventTrace:
- Root/panel background: app-bg or .surf-low
- Table header row: .t-on-surface-var, bottom border .b-outline-var
- Data rows: border-b .b-outline-var, min-height py-2.5
- Row hover: bg override with inline style or CSS class using var(--mds-surface-container)
- Selected row highlight: .surf-primary/30 or inline style with opacity
- Severity colors via inline style using CSS vars:
  - error: color var(--mds-error)
  - warning: color var(--factory-gate)
  - info: color var(--mds-primary)
  - default: color var(--mds-on-surface-var)
- Show-all button: .t-primary hover:underline font-medium

## Acceptance Criteria
- [ ] UnitDetailPanel section cards: .mdc-card class
- [ ] UnitDetailPanel row labels: .t-on-surface-var
- [ ] UnitDetailPanel row values: .t-on-surface font-mono
- [ ] UnitDetailPanel block section: .surf-error .b-error
- [ ] ActionPanel form containers use semantic classes by action type
- [ ] ActionPanel inputs use .mdc-input class
- [ ] ActionPanel selects use .mdc-select class
- [ ] ActionPanel response success uses .surf-success .b-success
- [ ] ActionPanel response blocked uses .surf-error .b-error
- [ ] EventTrace table header: .t-on-surface-var
- [ ] EventTrace severity colors reference CSS variable values
- [ ] EventTrace show-all: .t-primary

## Files Likely Affected
- frontend/src/components/UnitDetailPanel.tsx (UPDATE)
- frontend/src/components/ActionPanel.tsx (UPDATE)
- frontend/src/components/EventTrace.tsx (UPDATE)

## Blocked By
- tasks/material-theme-readability-d8b-001.md
