# Task: Create verification script 010 and update docs/indexes/journal/state

## Parent Spec
specs/material-theme-readability-d8b.md

## Phase
phase-demo-readiness

## Status
done

## Layer
verification

## Description
Create `scripts/verification/010-material-theme-readability.sh` with 21 checks.
Create `docs/material-theme-readability-d8b.md`.
Update README.md: add D8B phase row, add script 010 to verification table.
Update `ai/repo-index.md`: mark D8B COMPLETE, list new files.
Update `ai/architecture-index.md`: update Phase to D8B.
Append Entry 013 to `ai/engineering-journal.md` (append to end of file only).
Update `ai/state_registry.json`: add material-theme-readability-d8b RELEASE_APPROVED.
Update `scripts/verification/009-light-mode-readability.sh` V6 to accept
the new .app-bg token class approach (grep for app-bg OR bg-\[#FAFAF7\]).

Verification script 010 checks:
V1: curl frontend root → 200
V2: curl frontend → contains "Factory Cloud"
V3: curl frontend → contains "Review Prototype"
V4: curl frontend → contains "material-theme-toggle"
V5: curl frontend → contains "d8b"
V6: grep FactoryFlowBoard.tsx → contains "data-theme"
V7: grep styles.css → contains "--mds-"
V8: grep FactoryFlowBoard.tsx → contains "Light" (toggle label)
V9: curl backend/health → 200
V10: curl backend/data-contract/status → 200
V11: curl backend/data-contract/status → stage_count==14
V12: curl backend/data-contract/status → unit_count>=7
V13: bash scripts/verification/004-*.sh exits 0
V14: bash scripts/verification/005-*.sh exits 0
V15: bash scripts/verification/006-*.sh exits 0
V16: bash scripts/verification/007-*.sh exits 0
V17: bash scripts/verification/008-*.sh exits 0
V18: bash scripts/verification/009-*.sh exits 0
V19: bash scripts/smoke.sh exits 0
V20: grep -r "azure" backend/app/*.py → 0 results (no Azure SDK)
V21: grep -r "session\|auth\|jwt\|bearer" backend/app/*.py → 0 sensitive results

## Acceptance Criteria
- [ ] scripts/verification/010-material-theme-readability.sh exists and is executable
- [ ] Script has 21 checks with PASS/FAIL output
- [ ] Script exits 0 only when all 21 checks pass
- [ ] V4 checks for "material-theme-toggle" in page HTML
- [ ] V7 checks styles.css contains --mds- token
- [ ] V8 checks FactoryFlowBoard.tsx contains toggle label "Light"
- [ ] V13-V18 call D4-D9 scripts and verify exit 0
- [ ] docs/material-theme-readability-d8b.md created
- [ ] README.md updated with D8B row and script 010
- [ ] ai/repo-index.md updated with D8B completion
- [ ] ai/architecture-index.md Phase updated to D8B
- [ ] ai/engineering-journal.md has Entry 013
- [ ] ai/state_registry.json has material-theme-readability-d8b: RELEASE_APPROVED
- [ ] scripts/verification/009-light-mode-readability.sh V6 updated for D8B compatibility

## Files Likely Affected
- scripts/verification/010-material-theme-readability.sh (CREATE)
- scripts/verification/009-light-mode-readability.sh (UPDATE V6)
- docs/material-theme-readability-d8b.md (CREATE)
- README.md (UPDATE)
- ai/repo-index.md (UPDATE)
- ai/architecture-index.md (UPDATE)
- ai/engineering-journal.md (APPEND Entry 013)
- ai/state_registry.json (UPDATE)

## Blocked By
- tasks/material-theme-readability-d8b-002.md
- tasks/material-theme-readability-d8b-003.md
