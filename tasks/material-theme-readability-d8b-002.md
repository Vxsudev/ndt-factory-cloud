# Task: Rework FactoryFlowBoard columns, UnitList, and StageSpine with MD3 tokens

## Parent Spec
specs/material-theme-readability-d8b.md

## Phase
phase-demo-readiness

## Status
done

## Layer
frontend-components-1

## Description
Apply Material Design 3 semantic CSS classes to FactoryFlowBoard layout elements,
UnitList component, and StageSpine component.

FactoryFlowBoard: replace hardcoded Tailwind border/bg color classes on the three
column containers and header with .surf/.b-outline-var classes. Section header
labels use .t-on-surface-var. Column borders use .b-outline-var.

UnitList: rework each unit row to use MD3 classes.
- Default row: remove bg-white, add .surf-low .b-outline-var, rounded-xl, py-4 px-3
- Selected row: .surf-primary .b-primary .t-on-primary
- Unit ID: text-[15px] font-bold with .t-on-surface
- Scenario label: text-[13px] font-medium with .t-primary (selected) or .t-on-surface-var
- BLOCKED badge: .surf-error .b-error .t-on-error text-xs font-bold
- SHIPPED badge: .surf-success .b-success .t-on-success text-xs font-bold

StageSpine: rework each stage row to use MD3 classes (no opacity- classes).
- completed: .surf-low .b-outline-var
- current (not blocked): .surf-primary .b-primary
- current + blocked: .surf-error .b-error
- gate pending (stages 9,10,11): .surf-gate .b-gate
- cloud block pending (stages 7,12): .surf-cloud .b-cloud
- terminal pending (stage 14): .surf-success .b-success
- default pending: .surf .b-outline-var
- Stage name: text-[14px] font-semibold .t-on-surface for current/blocked/gate/cloud/success
- Stage number: text-xs font-mono .t-on-surface-var
- NO OVERRIDE badge: keep bg-red-600 text-white border-red-500 (remains prominent)
- Remove all opacity-* from stage rows

## Acceptance Criteria
- [ ] FactoryFlowBoard header uses .surf with bottom border .b-outline-var
- [ ] FactoryFlowBoard column dividers use .b-outline-var
- [ ] UnitList default rows: .surf-low .b-outline-var rounded-xl
- [ ] UnitList selected rows: .surf-primary .b-primary .t-on-primary
- [ ] UnitList BLOCKED badge: .surf-error .b-error .t-on-error
- [ ] UnitList SHIPPED badge: .surf-success .b-success .t-on-success
- [ ] UnitList unit ID: text-[15px] font-bold .t-on-surface
- [ ] StageSpine states all use correct MD3 token classes
- [ ] StageSpine has zero opacity-* class usages
- [ ] StageSpine stage names: text-[14px] font-semibold
- [ ] NO OVERRIDE badge remains bg-red-600 text-white

## Files Likely Affected
- frontend/src/components/FactoryFlowBoard.tsx (UPDATE)
- frontend/src/components/UnitList.tsx (UPDATE)
- frontend/src/components/StageSpine.tsx (UPDATE)

## Blocked By
- tasks/material-theme-readability-d8b-001.md
