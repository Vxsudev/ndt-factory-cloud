# Task: Create verification script 009 and update docs/indexes/journal

## Parent Spec
specs/light-mode-readability-d8a.md

## Phase
phase-demo-readiness

## Status
done

## Layer
verification

## Description
Create scripts/verification/009-light-mode-readability.sh (18 checks). Create
docs/light-mode-readability-d8a.md. Update README, ai/repo-index.md,
ai/architecture-index.md. Append Entry 012 to ai/engineering-journal.md.

## Acceptance Criteria
- [ ] scripts/verification/009-light-mode-readability.sh exists and passes (18 checks)
- [ ] V4 checks for "light-review" in page HTML
- [ ] V5 checks for "d8a-readability" in page HTML
- [ ] V6 checks that index.html does not contain "bg-gray-950" as root background
- [ ] V11–V15 confirm D4/D5/D6/D7/D8 verifications still pass
- [ ] docs/light-mode-readability-d8a.md created
- [ ] README updated: D8A phase, 009 in verification table
- [ ] ai/repo-index.md updated: D8A COMPLETE, new files listed
- [ ] ai/architecture-index.md updated: phase D8A
- [ ] ai/engineering-journal.md has Entry 012 for D8A completion

## Files Likely Affected
- scripts/verification/009-light-mode-readability.sh (CREATE)
- docs/light-mode-readability-d8a.md (CREATE)
- README.md (UPDATE)
- ai/repo-index.md (UPDATE)
- ai/architecture-index.md (UPDATE)
- ai/engineering-journal.md (UPDATE — append only)

## Blocked By
- tasks/light-mode-readability-d8a-003.md
