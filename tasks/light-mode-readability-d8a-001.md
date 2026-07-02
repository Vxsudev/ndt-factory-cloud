# Task: Apply light mode to FactoryFlowBoard root and global styles

## Parent Spec
specs/light-mode-readability-d8a.md

## Phase
phase-demo-readiness

## Status
done

## Layer
frontend

## Description
Convert the FactoryFlowBoard root container and global Tailwind base from dark-mode to
light-mode. Add data-theme="light-review" and data-d8a-readability="true" markers.
Update the header (taller, white bg, larger title). Update column borders, section headers,
and layout wrapper to light palette. This establishes the light-mode foundation that all
other components render inside.

## Acceptance Criteria
- [ ] Root div uses bg-[#FAFAF7] text-gray-900 (not bg-gray-950)
- [ ] data-theme="light-review" present on root div
- [ ] data-d8a-readability="true" present on root div
- [ ] Header background is white (bg-white), border is border-slate-200
- [ ] Header padding is taller (py-4)
- [ ] Title "Factory Cloud v0" is text-2xl font-bold
- [ ] Postgres-backed badge is light blue (bg-blue-50 text-blue-700 border-blue-200)
- [ ] Subtitle "D8 Review Prototype" is text-sm text-gray-500
- [ ] Column borders are border-slate-200
- [ ] Section header labels are text-xs text-gray-400
- [ ] Reset Demo State button uses light styling (bg-white border-slate-300)
- [ ] Health/contract status indicators use light-mode colors

## Files Likely Affected
- frontend/src/components/FactoryFlowBoard.tsx

## Blocked By
- none
