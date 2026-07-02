# Spec: Factory Review Hardening — D8 Demo Readiness

## Status
approved

## Phase
phase-demo-readiness

## Version
1.0

## Date
2026-06-30

---

## Purpose

Harden the Factory Cloud v0 prototype so it can be reviewed by Vijay / Mohit /
engineering stakeholders. This is a presentation and readability improvement phase only.

D8 does not add features, change domain rules, introduce auth, add Azure integrations,
or redesign backend logic. Every product constraint from D7 remains in force.

Core rule: make the existing prototype reviewable. Do not expand product scope.

---

## Scope

D8 may implement:

- UI readability improvements (header, unit queue, stage spine, detail panel, action panel, event trace)
- Demo scenario labels in the unit queue
- Clearer blocked/hard-stop state rendering
- Better action response visibility (endpoint, actor defaults, full response box)
- Better event trace filtering (unit-focused view + all-events toggle)
- Demo walkthrough documentation
- Reviewer handoff documentation
- Verification script for demo readiness

D8 must not implement:

- Auth / login / session management
- Azure SDK integration
- Real external integrations (eStore, inventory, device protocols)
- Reporting analytics or yield dashboards
- WebSockets or background workers
- Production deployment configuration
- Major schema redesign or new API endpoints
- Changes to the canonical 14-stage model
- Changes to backend domain/workflow rules

---

## Non-Goals

- Real serial-number conventions
- Multi-site or tenanting
- Device protocol ingestion
- File upload or report generation
- Production secret handling
- Mobile-first responsive redesign

---

## Source Materials

- `docs/factory-flow-model.md` — canonical 14-stage model (FROZEN)
- `docs/domain-glossary.md` — canonical terminology
- `docs/backend-state-behavior-d5.md` — D5 domain rules
- `docs/factory-flow-board-ui-d6.md` — D6 UI baseline
- `docs/persistence-postgres-d7.md` — D7 persistence
- `source-materials/digital-factory-requirements-v1/` — original requirements

---

## Seeded Demo Scenarios

Seven core scenarios must be preserved and identifiable in the UI:

| Unit | Stage | Scenario Label | Key Feature to Show |
|------|-------|---------------|---------------------|
| UNIT-0001 | S-05 | Assembly in progress | Part scan action, unbound part |
| UNIT-0002 | S-07 | Cloud SW/FW blocked | Hard-stop, no_override=true, cloud dependency |
| UNIT-0003 | S-10 | Calibration retry active | 2/3 attempts, can still try |
| UNIT-0004 | S-10 | Calibration cap exceeded | 3/3 failed, supervisor disposition required |
| UNIT-0005 | S-11 | QC ready | Hardware + calibration passed, awaiting sign-off |
| UNIT-0006 | S-12 | Cloud backup blocked | Hard-stop, no_override=true |
| UNIT-0007 | S-14 | Shipped — terminal | Immutable, no actions available |

---

## UI Hardening Plan

### Header (FactoryFlowBoard.tsx)

- Title: "Factory Cloud v0" (unchanged)
- Subtitle: "D8 Review Prototype" (replaces "D6 Factory Flow Board")
- Add persistence badge: "Postgres-backed"
- Add "data-d8-demo-readiness" attribute for verification
- Backend health indicator (unchanged)
- Data contract indicator (unchanged)
- Reset Demo State button (was "Reset Mock State")
- Add "Demo Guide" anchor linking to #demo-guide section or docs note

### Unit Queue (UnitList.tsx)

Each unit card shows:
- Unit ID (font-mono bold) — unchanged
- **Scenario label** (new — short human-readable description)
- Stage number + stage name short label
- Current status
- SHIPPED badge (terminal)
- BLOCKED / NO OVERRIDE badges

Scenario labels are derived from a frontend mapping (no seed data change needed).

### Stage Spine (StageSpine.tsx)

Improve visual clarity:
- Gates S-09, S-10, S-11: GATE badge in amber, slightly larger row
- Cloud blocks S-07, S-12: CLOUD BLOCK badge always visible (not just when active)
- Current stage: blue highlight with larger stage number font
- Completed stages: subtle grey
- Pending stages: subdued
- Terminal stage S-14: TERMINAL badge always visible
- NO OVERRIDE: red prominent badge
- Blocked current stage: red highlight (unchanged, already good)

### Unit Detail Panel (UnitDetailPanel.tsx)

Add explicit "Block / Hard-Stop" section when unit is blocked:
- blocked_reason — prominent red
- no_override — prominent red bold "NO OVERRIDE — No bypass possible"
- block_type — grey label
- Section appears only when unit.blocked_reason is non-null

### Action Panel (ActionPanel.tsx)

For each action form:
- Add header line: "Backend-guarded action · POST /factory/units/{id}/actions/{action}"
- Add actor/user default label showing which user will be used
- Show "Available at this stage" vs "Not available — unit blocked / wrong stage"
- After action: full response box showing:
  - Status badge (SUCCESS / BLOCKED / FAILED)
  - message
  - event_id
  - blocked_reason
  - no_override flag

### Event Trace (EventTrace.tsx)

- If a unit is selected: show events for that unit first (sorted by timestamp desc)
- Add "Show all" toggle to see all 25 events
- Show unit_id column only when "Show all" is active
- Add severity badge colors (unchanged, already good)
- Keep 25-event cap

---

## Backend / API Impact

No new endpoints. No changes to existing endpoints. No changes to workflow_rules.py.
No schema changes. No migration needed.

The only backend-visible change: the frontend no longer says "D6 Factory Flow Board" in
the HTML — it now says "D8 Review Prototype". The D6 verification script check for the
D6 meta marker must be updated in D8 verification to check for D8 markers.

---

## Data Impact

No seed data changes required. The 7 core scenarios are already correctly seeded.

---

## Dependencies

- D7 persistence-postgres RELEASE_APPROVED ✓
- All D4/D5/D6/D7 verification scripts must still pass ✓

---

## Acceptance Criteria

1. Header shows "Review Prototype" and "D8" identifiers
2. Header shows "Postgres-backed" persistence indicator
3. Unit queue shows scenario labels for all 7 seeded units
4. Blocked units show blocked_reason prominently in unit queue
5. no_override is clearly indicated in unit queue and detail panel
6. Unit detail panel has explicit "Block / Hard-Stop" section when blocked
7. Stage spine: gates S-09/S-10/S-11 visually distinct with GATE badge
8. Stage spine: cloud blocks S-07/S-12 show CLOUD BLOCK badge
9. Stage spine: terminal S-14 shows TERMINAL badge
10. Action panel shows "Backend-guarded action" label and endpoint URL
11. Action panel response box shows status, message, event_id, blocked_reason, no_override
12. Event trace filters by selected unit (unit events first)
13. Event trace has "Show all events" toggle
14. docs/demo-walkthrough-d8.md exists with complete reviewer script
15. docs/factory-review-hardening-d8.md exists with D8 documentation
16. scripts/verification/008-demo-readiness.sh passes all checks
17. D4 verification (004) still passes
18. D5 verification (005) still passes
19. D6 verification (006) still passes — updated for D8 markers
20. D7 verification (007) still passes
21. No auth added
22. No Azure SDK added
23. No external integrations added
24. No canonical stage changes
25. OS state reaches RELEASE_APPROVED for factory-review-hardening

---

## Verification Scripts

New: `scripts/verification/008-demo-readiness.sh` — 17 checks

Updated: `scripts/verification/006-factory-flow-board-ui.sh` — update D6 meta marker
check to not require "D6 Factory Flow Board" string (frontend subtitle changed to D8)

---

## Entry and Exit Conditions

D8 starts with D7 RELEASE_APPROVED.
D8 ends when verification 008 passes and OS state is RELEASE_APPROVED.

---

## D9 Handoff

D9 is safe to begin after D8 RELEASE_APPROVED.
D9 direction: depends on explicit directive. Candidates include order management UI,
full unit history viewer, or Azure wiring — all require new directives.
