# Task: Write verification script 008 and update OS indexes and journal

## Parent Spec
specs/factory-review-hardening.md

## Phase
phase-demo-readiness

## Status
done

## Layer
verification

## Description
Create scripts/verification/008-demo-readiness.sh (17 checks for demo readiness).
Update scripts/verification/006-factory-flow-board-ui.sh to not require the old D6
subtitle string. Update README, ai/repo-index.md, ai/architecture-index.md,
ai/engineering-journal.md for D8 complete.

## Acceptance Criteria
- [ ] scripts/verification/008-demo-readiness.sh exists and passes (17 checks)
- [ ] 006 D6 verification no longer fails due to changed subtitle
- [ ] README updated for D8
- [ ] ai/repo-index.md updated — D8 complete, new files listed
- [ ] ai/architecture-index.md updated — phase D8
- [ ] ai/engineering-journal.md has Entry 011 for D8 completion

## Files Likely Affected
- scripts/verification/008-demo-readiness.sh (CREATE)
- scripts/verification/006-factory-flow-board-ui.sh (UPDATE — D6 subtitle check)
- README.md (UPDATE)
- ai/repo-index.md (UPDATE)
- ai/architecture-index.md (UPDATE)
- ai/engineering-journal.md (UPDATE)

## Blocked By
- tasks/factory-review-hardening-004.md
