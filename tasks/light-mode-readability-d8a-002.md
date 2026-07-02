# Task: Apply light mode to UnitList and StageSpine

## Parent Spec
specs/light-mode-readability-d8a.md

## Phase
phase-demo-readiness

## Status
done

## Layer
frontend

## Description
Convert UnitList.tsx and StageSpine.tsx from dark-mode to light-mode. UnitList gets
larger text, light-mode badges, readable selected/blocked/shipped states. StageSpine
removes all opacity-* modifiers and applies light backgrounds for each state:
completed=slate-50, current=blue-50, blocked=red-50, gate=amber-50, cloud-block=orange-50,
terminal=green-50. All badges convert to light variants (bg-color-100 text-color-700).

## Acceptance Criteria
- [ ] UnitList default row: bg-white border-slate-200 text-gray-700
- [ ] UnitList selected row: bg-blue-50 border-blue-400 text-blue-900
- [ ] Unit ID text is text-sm (not text-xs)
- [ ] BLOCKED badge: bg-red-100 text-red-700 border-red-300
- [ ] SHIPPED badge: bg-green-100 text-green-700 border-green-300
- [ ] Scenario label: text-sky-600 text-xs (was text-[10px])
- [ ] Blocked reason in row: text-red-600 text-xs
- [ ] StageSpine has no opacity-40 or opacity-50 or opacity-60 classes
- [ ] Completed stage row: border-slate-200 bg-slate-50
- [ ] Current (not blocked) stage row: border-blue-400 bg-blue-50
- [ ] Current blocked stage row: border-red-400 bg-red-50
- [ ] Gate pending rows (S-09/10/11): border-amber-300 bg-amber-50
- [ ] Cloud block pending rows (S-07/12): border-orange-200 bg-orange-50
- [ ] Terminal pending row (S-14): border-green-300 bg-green-50
- [ ] Default pending rows: border-slate-200 bg-white
- [ ] All stage badges use light-mode variants (100 bg, 700 text, 300 border)
- [ ] NO OVERRIDE badge remains prominent (bg-red-600 text-white)
- [ ] Stage number text: text-slate-400
- [ ] Stage name text-sm throughout

## Files Likely Affected
- frontend/src/components/UnitList.tsx
- frontend/src/components/StageSpine.tsx

## Blocked By
- tasks/light-mode-readability-d8a-001.md
