# Task: Apply light mode to UnitDetailPanel, ActionPanel, and EventTrace

## Parent Spec
specs/light-mode-readability-d8a.md

## Phase
phase-demo-readiness

## Status
done

## Layer
frontend

## Description
Convert UnitDetailPanel.tsx, ActionPanel.tsx, and EventTrace.tsx from dark-mode to
light-mode. Detail panel gets white card backgrounds, slate borders, larger text, and a
prominent red Block/Hard-Stop section. Action panel gets light inputs (slate-50 bg),
larger form text, light response boxes. Event trace gets light table headers, larger row
text, and light-mode severity badge variants.

## Acceptance Criteria
- [ ] UnitDetailPanel cards: bg-white border-slate-200
- [ ] UnitDetailPanel row separators: border-slate-100
- [ ] UnitDetailPanel label text: text-gray-500
- [ ] UnitDetailPanel value text: text-gray-800 font-mono text-sm
- [ ] Block/Hard-Stop box: bg-red-50 border-red-200
- [ ] Blocked reason text: text-red-700 font-semibold text-sm
- [ ] NO OVERRIDE in detail panel: text-red-700 font-bold text-sm
- [ ] ActionPanel "no unit" / "no actions" placeholder: text-gray-400 text-sm
- [ ] ActionPanel form header: text-gray-700 text-sm font-semibold
- [ ] ActionPanel endpoint line: text-slate-400 text-xs
- [ ] ActionPanel inputs/selects: bg-slate-50 border-slate-300 text-gray-800 text-sm
- [ ] ActionPanel submit button: bg-blue-600 hover:bg-blue-700 text-white text-sm
- [ ] ResponseDisplay success: border-green-300 bg-green-50
- [ ] ResponseDisplay blocked: border-red-300 bg-red-50
- [ ] ResponseDisplay status badge success: bg-green-100 text-green-700 border-green-300
- [ ] ResponseDisplay status badge blocked: bg-red-100 text-red-700 border-red-300
- [ ] EventTrace table header: border-slate-200 text-gray-400
- [ ] EventTrace row hover: hover:bg-slate-50
- [ ] EventTrace selected unit row: bg-blue-50/50 (or bg-blue-50)
- [ ] EventTrace text is text-sm throughout (not text-xs)
- [ ] EventTrace severity badges light-mode: error=text-red-600, warning=text-amber-600, info=text-blue-600
- [ ] EventTrace show-all button: text-blue-600

## Files Likely Affected
- frontend/src/components/UnitDetailPanel.tsx
- frontend/src/components/ActionPanel.tsx
- frontend/src/components/EventTrace.tsx

## Blocked By
- tasks/light-mode-readability-d8a-002.md
