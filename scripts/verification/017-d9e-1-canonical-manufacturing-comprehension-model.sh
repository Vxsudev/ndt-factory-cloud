#!/usr/bin/env bash
# 017-d9e-1-canonical-manufacturing-comprehension-model.sh — Verify D9E-1 canonical model
# Static, file-based checks — no live browser required, no Docker mutation. Run from repo root:
#   bash scripts/verification/017-d9e-1-canonical-manufacturing-comprehension-model.sh
#
# Authored directly by the orchestrator, never delegated to a task-graph worker, per
# ai/incidents/d9c3-verification-script-deliverable-skipped-by-worker.md.
#
# Count-scope note: this script validates the failure-entry count (22, corrected from D9E-0's
# originally-reported 21 — see docs/manufacturing-comprehension-model.md §1/§6 erratum) ONLY
# against active D9E-1 artifacts and the new canonical model. It must not, and does not, fail
# merely because the historical, immutable ai/recon/d9e-0-manufacturing-comprehension-recon.md
# still contains its original "21" figure — that artifact is preserved unmodified by operator
# instruction.

set -uo pipefail

PASS=0; FAIL=0
CM="docs/manufacturing-comprehension-model.md"
GLOSS="docs/glossary.md"
FFM="docs/factory-flow-model.md"
WALK="docs/demo-walkthrough-d8.md"
D9E0="ai/recon/d9e-0-manufacturing-comprehension-recon.md"
SPEC="specs/d9e-1-canonical-manufacturing-comprehension-model.md"
TASK="tasks/d9e-1-canonical-manufacturing-comprehension-model-001.md"

_pass() { echo "  PASS  $1"; PASS=$((PASS+1)); }
_fail() { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }

echo "017 — D9E-1 Canonical Manufacturing Comprehension Model Verification"
echo "══════════════════════════════════════════════════════════════"

# ── V1: canonical document exists, correct status, exact 22-section structure ─
echo ""
echo "V1. Canonical document exists with OPERATOR_LOCKED status and the exact 22-section structure"
if [ -f "$CM" ]; then
  _pass "V1.1: $CM exists"
else
  _fail "V1.1: $CM missing"
fi
if [ -f "$CM" ] && grep -q "CANONICAL — OPERATOR_LOCKED THROUGH D9E-0; IMPLEMENTED BY D9E-1" "$CM"; then
  _pass "V1.2: status line present"
else
  _fail "V1.2: status line missing or incorrect"
fi
# Structural proof, not just existence: extract top-level "## N. ..." headings only (excludes
# "### " subsections, numbered list items, and section-number references inside prose — the
# anchor `^## ` requires the third character to be a space, which a "### " line never satisfies),
# preserve source order, and require an exact match against 1..22. Fails on a missing, duplicated,
# reordered, or unexpected numbered section, or any count other than 22.
EXPECTED_SECTIONS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22"
if [ -f "$CM" ]; then
  ACTUAL_SECTIONS=$(grep -oE '^## [0-9]+\.' "$CM" | grep -oE '[0-9]+' | tr '\n' ' ' | sed 's/ $//')
  if [ "$ACTUAL_SECTIONS" = "$EXPECTED_SECTIONS" ]; then
    _pass "V1.3: exact 22-section structure verified — sections 1 through 22, no gaps/duplicates/reorders/extras"
  else
    _fail "V1.3: section structure mismatch — expected [$EXPECTED_SECTIONS], found [$ACTUAL_SECTIONS]"
  fi
else
  _fail "V1.3: skipped — canonical document missing"
fi

# ── V2: all 14 stages present, in exact canonical order ─────────────────────
echo ""
echo "V2. All 14 stages present, in exact canonical order (§4 summary table only)"
EXPECTED_STAGE_ORDER="STAGE-01 STAGE-02 STAGE-03 STAGE-04 STAGE-05 STAGE-06 STAGE-07 STAGE-08 STAGE-09 STAGE-10 STAGE-11 STAGE-12 STAGE-13 STAGE-14"
if [ -f "$CM" ]; then
  # Extract stage IDs only from the canonical "## 4. Fourteen-Stage Model" summary table
  # (bounded before "### Per-stage detail"), in source order — not merely presence anywhere
  # in the document. A missing, duplicated, reordered, or extra stage row breaks the exact
  # string comparison below.
  ACTUAL_STAGE_ORDER=$(awk '/^## 4\. Fourteen-Stage Model/,/### Per-stage detail/' "$CM" \
    | grep -oE '^\| [0-9]+ \| STAGE-[0-9]+' | grep -oE 'STAGE-[0-9]+' | tr '\n' ' ' | sed 's/ $//')
  if [ "$ACTUAL_STAGE_ORDER" = "$EXPECTED_STAGE_ORDER" ]; then
    _pass "V2: exact stage order verified — STAGE-01 through STAGE-14, no gaps/duplicates/reorders/extras"
  else
    _fail "V2: stage order mismatch — expected [$EXPECTED_STAGE_ORDER], found [$ACTUAL_STAGE_ORDER]"
  fi
else
  _fail "V2: skipped — canonical document missing"
fi

# ── V3: three-gate model — exact gate set, not merely declared ──────────────
echo ""
echo "V3. Stages 9/10/11 are the only three canonical gates (declaration + structural table proof)"
if [ -f "$CM" ] && grep -q "Gate 1 = Stage 9" "$CM" && grep -q "Gate 2 = Stage 10" "$CM" && grep -q "Gate 3 = Stage 11" "$CM"; then
  _pass "V3.1: three-gate model (9/10/11) explicitly declared"
else
  _fail "V3.1: three-gate model declaration missing or incomplete"
fi
if [ -f "$FFM" ] && grep -q "S-09.*| gate" "$FFM"; then
  _pass "V3.2: docs/factory-flow-model.md retypes Stage 9 as gate"
else
  _fail "V3.2: docs/factory-flow-model.md Stage 9 gate retyping not found"
fi
# Structural proof, not declaration-presence: extract every STAGE-NN row from the §4 summary
# table whose "Gate?" cell (the table's last populated column) is affirmative ("Yes"), in table
# order, and require an exact match against STAGE-09/10/11 only. This fails if any other stage
# is (mis)marked as a gate, a gate is missing/duplicated, or the order differs — a document
# with Gates 9/10/11 plus an incorrectly gated Stage 8 would fail this check even though it
# would still satisfy V3.1's declaration-only text search.
EXPECTED_GATE_SET="STAGE-09 STAGE-10 STAGE-11"
if [ -f "$CM" ]; then
  ACTUAL_GATE_SET=$(awk '/^## 4\. Fourteen-Stage Model/,/### Per-stage detail/' "$CM" | awk -F'|' '
    /^\| [0-9]+ \| STAGE-[0-9]+/ {
      id = $3; gsub(/^[ \t]+|[ \t]+$/, "", id)
      gate = $7; gsub(/^[ \t]+|[ \t]+$/, "", gate)
      gsub(/\*/, "", gate)
      if (gate ~ /^Yes/) { print id }
    }
  ' | tr '\n' ' ' | sed 's/ $//')
  if [ "$ACTUAL_GATE_SET" = "$EXPECTED_GATE_SET" ]; then
    _pass "V3.3: exact gate set structurally proven — only STAGE-09/10/11 marked affirmative in the §4 table"
  else
    _fail "V3.3: gate set mismatch — expected [$EXPECTED_GATE_SET], found [$ACTUAL_GATE_SET]"
  fi
else
  _fail "V3.3: skipped — canonical document missing"
fi

# ── V4: Stage 8 phantom failure excluded ────────────────────────────────────
echo ""
echo "V4. No canonical Stage 8 failure invented"
if [ -f "$CM" ] && grep -q "DOCUMENTED_CONFLICT_RESOLVED_OUT" "$CM" && grep -qi "Cloud provision failure (S-08)" "$CM"; then
  _pass "V4: Stage 8 phantom failure documented as resolved-out, not invented"
else
  _fail "V4: Stage 8 exclusion not properly documented"
fi
# Check specifically for an ACTIVE TABLE ROW naming the Stage-8 failure (a line starting with
# "|"), not the errata prose paragraph that explains its removal (which legitimately quotes the
# phrase in past tense).
if [ -f "$FFM" ] && grep -E "^\|.*Cloud provision failure \(S-08\)" "$FFM" > /dev/null 2>&1; then
  _fail "V4: docs/factory-flow-model.md still lists a Stage-8 failure row as an active table row"
else
  _pass "V4: docs/factory-flow-model.md no longer lists an active Stage-8 failure table row"
fi

# ── V5: Stage 7 / Stage 12 no-override distinctness ─────────────────────────
echo ""
echo "V5. Stage 7 and Stage 12 no-override rules are distinct and correct"
if [ -f "$CM" ] && grep -q "no existing recovery action" "$CM" || { [ -f "$CM" ] && grep -q "no backend endpoint or frontend action exists for Stage 7" "$CM"; }; then
  _pass "V5: Stage 7 documented with no current recovery action"
else
  _fail "V5: Stage 7 no-recovery-action statement missing"
fi
if [ -f "$CM" ] && grep -q "not a Supervisor override" "$CM" && grep -q "re-check" "$CM"; then
  _pass "V5: Stage 12 Retry documented as a re-check, not an override"
else
  _fail "V5: Stage 12 retry-as-recheck statement missing"
fi
if [ -f "$WALK" ] && grep -qi "supervisor clears the block" "$WALK"; then
  _fail "V5: docs/demo-walkthrough-d8.md still contains 'supervisor clears the block' language"
else
  _pass "V5: docs/demo-walkthrough-d8.md no longer claims a Supervisor clears either cloud block"
fi

# ── V6: actor/role/authority distinctions ───────────────────────────────────
echo ""
echo "V6. Actor, role, and authority are documented as distinct concepts"
if [ -f "$CM" ] && grep -q "Technician is a role, not a fourth authority tier" "$CM"; then
  _pass "V6: Technician documented as a role, not a tier"
else
  _fail "V6: Technician-as-role statement missing"
fi
if [ -f "$CM" ] && grep -q "QC authority is distinct from Supervisor and Manager" "$CM"; then
  _pass "V6: QC distinctness from Supervisor/Manager documented"
else
  _fail "V6: QC distinctness statement missing"
fi
if [ -f "$CM" ] && grep -q "Manager authority does not imply QC-signoff authority" "$CM"; then
  _pass "V6: Manager-does-not-imply-QC statement documented"
else
  _fail "V6: Manager/QC non-implication statement missing"
fi
if [ -f "$FFM" ] && grep -q "Technician" "$FFM" && ! grep -qE "^\| Technician \|" "$FFM"; then
  _pass "V6: docs/factory-flow-model.md no longer lists Technician as its own Authority Levels row"
else
  if [ -f "$FFM" ] && grep -qE "^\| Technician \|" "$FFM"; then
    _fail "V6: docs/factory-flow-model.md still lists Technician as a standalone authority tier row"
  else
    _pass "V6: docs/factory-flow-model.md Technician-as-tier row absent"
  fi
fi

# ── V7: Floor Manager vs Manager Scrap rule ─────────────────────────────────
echo ""
echo "V7. Floor Manager versus Manager Scrap rule documented"
if [ -f "$CM" ] && grep -q "Scrap requires Manager authorization" "$CM" && grep -q "Manager authorization required" "$CM"; then
  _pass "V7: Floor-Manager-vs-Manager Scrap rule fully documented"
else
  _fail "V7: Floor-Manager-vs-Manager Scrap rule missing or incomplete"
fi

# ── V8: three composable semantic axes ──────────────────────────────────────
echo ""
echo "V8. Three semantic axes present and declared composable"
AXIS_COUNT=0
for axis in "Manufacturing State" "Constraint" "Ownership and Actionability"; do
  if [ -f "$CM" ] && grep -q "Axis.*$axis" "$CM"; then
    AXIS_COUNT=$((AXIS_COUNT+1))
  fi
done
if [ "$AXIS_COUNT" -eq 3 ]; then
  _pass "V8: all three axes (Manufacturing State / Constraint / Ownership and Actionability) present"
else
  _fail "V8: expected 3 axes, found $AXIS_COUNT"
fi
if [ -f "$CM" ] && grep -q "axes are composable, not mutually exclusive" "$CM"; then
  _pass "V8: axes explicitly declared composable"
else
  _fail "V8: composability declaration missing"
fi

# ── V9: Stage 12 locked worked example ──────────────────────────────────────
echo ""
echo "V9. Stage 12 locked worked classification example present"
if [ -f "$CM" ] && grep -q "Waiting" "$CM" && grep -q "Blocked + No override" "$CM" && grep -q "Retry available after connectivity returns" "$CM"; then
  _pass "V9: Stage 12 worked example (Waiting / Blocked+No override / external cloud / Retry available) present"
else
  _fail "V9: Stage 12 worked example missing or incomplete"
fi

# ── V10: serialized-traceability chain ──────────────────────────────────────
echo ""
echo "V10. Serialized-traceability chain documented"
if [ -f "$CM" ] && grep -q "physical part serial" "$CM" && grep -q "genealogy record" "$CM" && grep -q "immutable terminal record" "$CM"; then
  _pass "V10: full serial-to-terminal chain documented"
else
  _fail "V10: serialized-traceability chain incomplete"
fi

# ── V11: documented-vs-implemented classification vocabulary ───────────────
echo ""
echo "V11. Documented-vs-implemented classification vocabulary complete"
CLASS_COUNT=0
for cls in IMPLEMENTED_AND_REACHABLE IMPLEMENTED_SEEDED_ONLY IMPLEMENTED_TRANSIENT_ONLY IMPLEMENTED_BUT_UI_UNAVAILABLE DOCUMENTED_NOT_IMPLEMENTED DOCUMENTED_CONFLICT_RESOLVED_OUT DATA_UNAVAILABLE; do
  if [ -f "$CM" ] && grep -q "$cls" "$CM"; then
    CLASS_COUNT=$((CLASS_COUNT+1))
  fi
done
if [ "$CLASS_COUNT" -eq 7 ]; then
  _pass "V11: all 7 named classification values present (TBD is the 8th, checked separately)"
else
  _fail "V11: expected 7 classification values, found $CLASS_COUNT"
fi

# ── V12: TBD register carried forward ───────────────────────────────────────
echo ""
echo "V12. TBD register present with 12 entries"
TBD_ROWS=$(grep -cE '^\| T[0-9]+ \|' "$CM" 2>/dev/null || echo 0)
if [ "$TBD_ROWS" -eq 12 ]; then
  _pass "V12: 12 TBD rows present"
else
  _fail "V12: expected 12 TBD rows, found $TBD_ROWS"
fi

# ── V13: raw-code mapping preserved (not replaced) ──────────────────────────
echo ""
echo "V13. Raw backend codes preserved as a mapping, not replaced"
if [ -f "$CM" ] && grep -q "## 7. Raw-Code Mapping" "$CM" && grep -q "never a replacement" "$CM"; then
  _pass "V13: raw-code mapping section present with never-a-replacement framing"
else
  _fail "V13: raw-code mapping section missing or framing absent"
fi
if [ -f "$CM" ] && grep -q "wrong_stage" "$CM" && grep -q "insufficient_authority" "$CM" && grep -q "quarantined:" "$CM"; then
  _pass "V13: representative raw codes (wrong_stage, insufficient_authority, quarantined:) present verbatim"
else
  _fail "V13: representative raw codes missing"
fi

# ── V14: 22-entry failure count (corrected) ─────────────────────────────────
echo ""
echo "V14. Canonical failure-entry count is 22 (corrected from D9E-0's originally-reported 21)"
FM_ROWS=0
if [ -f "$CM" ]; then
  FM_ROWS=$(awk '/^## 6\. Failure-Mode Catalog/,/Count confirmation/' "$CM" | grep -cE '^\| FM-')
fi
if [ "$FM_ROWS" -eq 22 ]; then
  _pass "V14: exactly 22 failure-entry rows in the §6 catalog table"
else
  _fail "V14: expected 22 failure-entry rows, found $FM_ROWS"
fi
# Scoped to the §6 catalog table specifically — each canonical ID legitimately appears a second
# time in the separate §7 raw-code mapping table, which is a different table, not a duplicate.
FM_WRONG_STAGE_COUNT=$(awk '/^## 6\. Failure-Mode Catalog/,/Count confirmation/' "$CM" | grep -cF "| FM-WRONG-STAGE |")
FM_AUTH_COUNT=$(awk '/^## 6\. Failure-Mode Catalog/,/Count confirmation/' "$CM" | grep -cF "| FM-AUTH-INSUFFICIENT |")
if [ "$FM_WRONG_STAGE_COUNT" -eq 1 ]; then
  _pass "V14: exactly one FM-WRONG-STAGE row in the §6 catalog table"
else
  _fail "V14: expected exactly 1 FM-WRONG-STAGE row in §6, found $FM_WRONG_STAGE_COUNT"
fi
if [ "$FM_AUTH_COUNT" -eq 1 ]; then
  _pass "V14: exactly one FM-AUTH-INSUFFICIENT row in the §6 catalog table"
else
  _fail "V14: expected exactly 1 FM-AUTH-INSUFFICIENT row in §6, found $FM_AUTH_COUNT"
fi
if grep -qF "| FM-WRONG-STAGE | any dedicated action |" "$CM" 2>/dev/null && grep -qF "| FM-WRONG-STAGE |" "$CM" 2>/dev/null; then
  _pass "V14: FM-WRONG-STAGE has its own independent classification row (not merged)"
else
  _fail "V14: FM-WRONG-STAGE row not found as an independent entry"
fi
if grep -qF "| FM-AUTH-INSUFFICIENT | reallocation / disposition / QC / waiver |" "$CM" 2>/dev/null; then
  _pass "V14: FM-AUTH-INSUFFICIENT has its own independent classification row (not merged)"
else
  _fail "V14: FM-AUTH-INSUFFICIENT row not found as an independent entry"
fi

# ── V15: each of the two split entries has its own trigger AND recovery ────
echo ""
echo "V15. FM-WRONG-STAGE and FM-AUTH-INSUFFICIENT each independently prove trigger + recovery"
# Triggers are scoped to §6 (Failure-Mode Catalog through its Count confirmation prose) — the
# canonical location where each entry's trigger is defined, not incidental prose elsewhere.
SEC6=$(awk '/^## 6\. Failure-Mode Catalog/,/^## 7\. Raw-Code Mapping/' "$CM" 2>/dev/null)
# Recoveries are scoped to §9 (Recovery-Path Catalog) — the canonical recovery catalog itself,
# not any other section that happens to mention recovery in passing.
SEC9=$(awk '/^## 9\. Recovery-Path Catalog/,/^## 10\. Actor\/Role\/Authority Model/' "$CM" 2>/dev/null)

if echo "$SEC6" | grep -q "unit not at that action's required stage"; then
  _pass "V15.1: FM-WRONG-STAGE trigger (dedicated action called against unit not at its required stage) proven in §6"
else
  _fail "V15.1: FM-WRONG-STAGE trigger not proven in §6"
fi

if echo "$SEC9" | grep -q "FM-WRONG-STAGE correction" && echo "$SEC9" | grep -q "using the action valid for the unit's actual stage"; then
  _pass "V15.2: FM-WRONG-STAGE recovery (perform the action valid for the unit's actual stage) proven in §9"
else
  _fail "V15.2: FM-WRONG-STAGE recovery not proven in the §9 recovery catalog"
fi

if echo "$SEC6" | grep -q "calling actor lacks the required capability/authority for the action"; then
  _pass "V15.3: FM-AUTH-INSUFFICIENT trigger (caller lacks required authority/capability) proven in §6"
else
  _fail "V15.3: FM-AUTH-INSUFFICIENT trigger not proven in §6"
fi

if echo "$SEC9" | grep -q "FM-AUTH-INSUFFICIENT handoff" && echo "$SEC9" | grep -q "Authorized-actor handoff / approval"; then
  _pass "V15.4: FM-AUTH-INSUFFICIENT recovery (use or escalate to an authorized actor) proven in §9"
else
  _fail "V15.4: FM-AUTH-INSUFFICIENT recovery not proven in the §9 recovery catalog"
fi

# ── V16: erratum recorded in canonical document ─────────────────────────────
echo ""
echo "V16. D9E-0 numeric erratum recorded in the canonical document"
if grep -q "Erratum" "$CM" && grep -q "D9E-0 reported 21 normalized" "$CM" && grep -q "arithmetic/catalog-counting error" "$CM"; then
  _pass "V16: erratum recorded with cause (arithmetic/catalog-counting error, not a new finding)"
else
  _fail "V16: erratum not fully recorded"
fi
if grep -q "not modified" "$CM" && grep -q "d9e-0-manufacturing-comprehension-recon.md" "$CM"; then
  _pass "V16: canonical document confirms D9E-0 artifact was not modified"
else
  _fail "V16: D9E-0 non-modification confirmation missing from canonical document"
fi

# ── V17: no ACTIVE D9E-1 artifact still claims 21 (scoped correctly) ────────
echo ""
echo "V17. No active D9E-1 artifact still claims the uncorrected count of 21"
# Scope: spec + task only (canonical doc already verified above; D9E-0 recon is explicitly
# excluded per operator instruction — its original 21 is historical evidence, not a live claim).
V17_OK=true
if grep -qE "All 21 (evidence-backed|D9E-0)" "$SPEC" "$TASK" 2>/dev/null; then
  _fail "V17: an active D9E-1 artifact (spec/task) still asserts the uncorrected count of 21"
  V17_OK=false
fi
if [ "$V17_OK" = true ]; then
  _pass "V17: spec and task files carry the corrected count (22), not the stale 21"
fi
if grep -q "All \*\*22\*\*" "$SPEC" 2>/dev/null; then
  _pass "V17: spec's acceptance criteria explicitly assert 22"
else
  _fail "V17: spec's acceptance criteria do not explicitly assert 22"
fi

# Task-specific check: the task previously carried an unqualified stale "twenty-one-entry failure
# catalog" phrase (a plain factual error, not a historical-erratum reference) alongside its own
# correct 22-entry acceptance criteria — internally inconsistent. Require the corrected wording
# and require none of the unqualified stale forms. Historical erratum prose that clearly explains
# D9E-0 originally reported 21 (in the spec or the task's own erratum-narrative section) is not
# targeted by these patterns and remains allowed.
if grep -qF "22-entry failure catalog" "$TASK" 2>/dev/null; then
  _pass "V17: active task carries the corrected '22-entry failure catalog' wording"
else
  _fail "V17: active task does not carry the corrected '22-entry failure catalog' wording"
fi
V17_STALE_FOUND=false
for stale in "twenty-one-entry failure catalog" "21-entry failure catalog" "21 evidence-backed failure" "All 21"; do
  if grep -qF "$stale" "$TASK" 2>/dev/null; then
    echo "    STALE FORM STILL PRESENT IN TASK: $stale"
    V17_STALE_FOUND=true
  fi
done
if [ "$V17_STALE_FOUND" = false ]; then
  _pass "V17: active task carries none of the stale unqualified '21' forms"
else
  _fail "V17: active task still carries at least one stale unqualified '21' form"
fi

# ── V18: D9E-0 artifact confirmed untouched ─────────────────────────────────
echo ""
echo "V18. Immutable D9E-0 artifact was not modified by this correction"
if [ -f "$D9E0" ]; then
  D9E0_STATUS=$(git diff --name-only -- "$D9E0" 2>/dev/null)
  if [ -z "$D9E0_STATUS" ]; then
    _pass "V18: $D9E0 shows zero diff against the repository's tracked state"
  else
    _fail "V18: $D9E0 has uncommitted modifications"
  fi
else
  _fail "V18: $D9E0 not found"
fi

# ── V19: glossary exists ────────────────────────────────────────────────────
echo ""
echo "V19. New UI-facing glossary exists and is additive"
if [ -f "$GLOSS" ] && grep -q "CANONICAL — OPERATOR_LOCKED THROUGH D9E-0; IMPLEMENTED BY D9E-1" "$GLOSS"; then
  _pass "V19: docs/glossary.md exists with correct status"
else
  _fail "V19: docs/glossary.md missing or status incorrect"
fi
if [ -f "$GLOSS" ] && grep -q "does not modify" "$GLOSS" && grep -q "domain-glossary.md" "$GLOSS"; then
  _pass "V19: glossary explicitly declares itself additive, not a modification of the frozen domain glossary"
else
  _fail "V19: glossary additivity declaration missing"
fi

# ── V20: source materials and application surfaces untouched ───────────────
echo ""
echo "V20. Source materials and application/backend/data/vendor surfaces untouched"
CHANGED=$(git status --short | awk '{print $2}')
UNAUTHORIZED=false
for f in $CHANGED; do
  case "$f" in
    frontend/*|backend/*|data/*|source-materials/*|vendor/*|.engineering-os/*|docker-compose.yml|*/package.json|*/package-lock.json|scripts/verification/00*|scripts/verification/01[0-6]*)
      echo "    UNAUTHORIZED PATH CHANGED: $f"
      UNAUTHORIZED=true
      ;;
  esac
done
if [ "$UNAUTHORIZED" = false ]; then
  _pass "V20: no frontend/backend/data/source-material/vendor/Docker/package-lock/existing-verification-script path changed"
else
  _fail "V20: an unauthorized path was changed"
fi

# ── V21: only authorized paths changed (positive allow-list check) ─────────
echo ""
echo "V21. Only declared D9E-1 mutation-plan paths changed (plus known pre-existing residue)"
V21_OK=true
for f in $CHANGED; do
  case "$f" in
    AGENTS.md|ai/recon/d9c2-shared-view-model.md) ;; # known pre-existing untracked residue
    ai/recon/d9e-1-canonical-manufacturing-comprehension-model.md) ;;
    specs/d9e-1-canonical-manufacturing-comprehension-model.md) ;;
    tasks/d9e-1-canonical-manufacturing-comprehension-model-001.md) ;;
    scripts/verification/017-d9e-1-canonical-manufacturing-comprehension-model.sh) ;;
    docs/manufacturing-comprehension-model.md) ;;
    docs/glossary.md) ;;
    docs/factory-flow-model.md) ;;
    docs/demo-walkthrough-d8.md) ;;
    ai/state_registry.json) ;;
    ai/engineering-journal.md) ;;
    *)
      echo "    UNDECLARED PATH CHANGED: $f"
      V21_OK=false
      ;;
  esac
done
if [ "$V21_OK" = true ]; then
  _pass "V21: every changed path is an authorized D9E-1 artifact or known pre-existing residue"
else
  _fail "V21: an undeclared path was changed"
fi

# ── V22: §6 catalog structurally validated — 22 rows × 5 populated columns ─
echo ""
echo "V22. §6 Failure-Mode Catalog structurally validated: 22 rows, each with 5 populated logical columns"
if [ -f "$CM" ]; then
  # Structural parse, not a prefix grep: for every "| FM-..." row inside §6 (bounded to the
  # catalog table + its Count confirmation prose, excluding §7's unrelated re-mentions and §9's
  # unrelated recovery rows), split on "|" and require exactly 7 fields (leading empty + 5
  # populated logical columns + trailing empty: Canonical ID / Stage / Persistence /
  # Classification / Semantic axes). Any row that loses/gains a column, or has an empty column
  # after trimming, is counted as malformed. This fails if a semantic-expression cell is dropped,
  # a cell goes empty, or the table gains/loses a logical column — not merely if a fixed prefix
  # string changes.
  V22_OUT=$(awk '/^## 6\. Failure-Mode Catalog/,/Count confirmation/' "$CM" | awk -F'|' '
    BEGIN {
      n = split("IMPLEMENTED_AND_REACHABLE IMPLEMENTED_SEEDED_ONLY IMPLEMENTED_TRANSIENT_ONLY IMPLEMENTED_BUT_UI_UNAVAILABLE DOCUMENTED_NOT_IMPLEMENTED DOCUMENTED_CONFLICT_RESOLVED_OUT DATA_UNAVAILABLE TBD", allowed, " ")
      for (k = 1; k <= n; k++) { valid[allowed[k]] = 1 }
    }
    /^\| FM-/ {
      total++
      malformed = (NF != 7)
      if (!malformed) {
        for (i = 2; i <= 6; i++) {
          v = $i
          gsub(/^[ \t]+|[ \t]+$/, "", v)
          if (v == "") { malformed = 1 }
        }
      }
      if (malformed) { bad++ }
      id = $2; gsub(/^[ \t]+|[ \t]+$/, "", id)

      cls = $5; gsub(/^[ \t]+|[ \t]+$/, "", cls); gsub(/`/, "", cls)
      if (!(cls in valid)) { bad_cls++ }

      if (id == "FM-WRONG-STAGE") {
        ws_count++
        persist = $4; gsub(/^[ \t]+|[ \t]+$/, "", persist)
        sem = $6; gsub(/^[ \t]+|[ \t]+$/, "", sem)
        ws_retain = (index(persist, "request-scoped; unit unchanged") > 0 && index(sem, "Action required from you") > 0) ? "OK" : "FAIL"
        ws_cls = cls
      }
      if (id == "FM-AUTH-INSUFFICIENT") {
        auth_count++
        persist = $4; gsub(/^[ \t]+|[ \t]+$/, "", persist)
        sem = $6; gsub(/^[ \t]+|[ \t]+$/, "", sem)
        auth_retain = (index(persist, "request-scoped; unit unchanged") > 0 && index(sem, "no action available to the current actor") > 0) ? "OK" : "FAIL"
        auth_cls = cls
      }
    }
    END {
      printf "TOTAL=%d\nBAD=%d\nBAD_CLS=%d\nWS_COUNT=%d\nAUTH_COUNT=%d\nWS_RETAIN=%s\nAUTH_RETAIN=%s\nWS_CLS=%s\nAUTH_CLS=%s\n",
        total+0, bad+0, bad_cls+0, ws_count+0, auth_count+0,
        (ws_retain == "" ? "MISSING" : ws_retain), (auth_retain == "" ? "MISSING" : auth_retain),
        (ws_cls == "" ? "MISSING" : ws_cls), (auth_cls == "" ? "MISSING" : auth_cls)
    }
  ')
  V22_TOTAL=$(echo "$V22_OUT" | sed -n 's/^TOTAL=//p')
  V22_BAD=$(echo "$V22_OUT" | sed -n 's/^BAD=//p')
  V22_BAD_CLS=$(echo "$V22_OUT" | sed -n 's/^BAD_CLS=//p')
  V22_WS_COUNT=$(echo "$V22_OUT" | sed -n 's/^WS_COUNT=//p')
  V22_AUTH_COUNT=$(echo "$V22_OUT" | sed -n 's/^AUTH_COUNT=//p')
  V22_WS_RETAIN=$(echo "$V22_OUT" | sed -n 's/^WS_RETAIN=//p')
  V22_AUTH_RETAIN=$(echo "$V22_OUT" | sed -n 's/^AUTH_RETAIN=//p')
  V22_WS_CLS=$(echo "$V22_OUT" | sed -n 's/^WS_CLS=//p')
  V22_AUTH_CLS=$(echo "$V22_OUT" | sed -n 's/^AUTH_CLS=//p')

  if [ "$V22_TOTAL" -eq 22 ]; then
    _pass "V22.1: exactly 22 FM-* rows structurally present in §6"
  else
    _fail "V22.1: expected 22 FM-* rows, found $V22_TOTAL"
  fi
  if [ "$V22_BAD" -eq 0 ]; then
    _pass "V22.2: every one of the 22 rows has exactly 5 populated logical columns after trimming"
  else
    _fail "V22.2: $V22_BAD row(s) are structurally malformed (wrong column count or an empty cell)"
  fi
  if [ "$V22_WS_COUNT" -eq 1 ]; then
    _pass "V22.3: FM-WRONG-STAGE appears exactly once"
  else
    _fail "V22.3: expected exactly 1 FM-WRONG-STAGE row, found $V22_WS_COUNT"
  fi
  if [ "$V22_AUTH_COUNT" -eq 1 ]; then
    _pass "V22.4: FM-AUTH-INSUFFICIENT appears exactly once"
  else
    _fail "V22.4: expected exactly 1 FM-AUTH-INSUFFICIENT row, found $V22_AUTH_COUNT"
  fi
  if [ "$V22_WS_RETAIN" = "OK" ]; then
    _pass "V22.5: FM-WRONG-STAGE row retains its required Persistence and Semantic-expression content"
  else
    _fail "V22.5: FM-WRONG-STAGE row lost its required Persistence/Semantic-expression content ($V22_WS_RETAIN)"
  fi
  if [ "$V22_AUTH_RETAIN" = "OK" ]; then
    _pass "V22.6: FM-AUTH-INSUFFICIENT row retains its required Persistence and Semantic-expression content"
  else
    _fail "V22.6: FM-AUTH-INSUFFICIENT row lost its required Persistence/Semantic-expression content ($V22_AUTH_RETAIN)"
  fi
  if [ "$V22_BAD_CLS" -eq 0 ]; then
    _pass "V22.7: every one of the 22 rows carries exactly one recognized classification value from the closed 8-value set"
  else
    _fail "V22.7: $V22_BAD_CLS row(s) carry an empty, unknown, malformed, or multi-value classification cell"
  fi
  if [ "$V22_WS_CLS" = "IMPLEMENTED_TRANSIENT_ONLY" ]; then
    _pass "V22.8: FM-WRONG-STAGE classification is IMPLEMENTED_TRANSIENT_ONLY (consistent with §8 — never persists to the unit record)"
  else
    _fail "V22.8: FM-WRONG-STAGE classification expected IMPLEMENTED_TRANSIENT_ONLY, found $V22_WS_CLS"
  fi
  if [ "$V22_AUTH_CLS" = "IMPLEMENTED_TRANSIENT_ONLY" ]; then
    _pass "V22.9: FM-AUTH-INSUFFICIENT classification is IMPLEMENTED_TRANSIENT_ONLY (consistent with §8 — never persists to the unit record)"
  else
    _fail "V22.9: FM-AUTH-INSUFFICIENT classification expected IMPLEMENTED_TRANSIENT_ONLY, found $V22_AUTH_CLS"
  fi
else
  _fail "V22: skipped — canonical document missing"
fi

# ── V23: glossary 'No override' truth corrected ─────────────────────────────
echo ""
echo "V23. Glossary 'No override' entry no longer claims an unsupported exhaustive count"
if grep -qi "canonical model's two no-override conditions" "$GLOSS" 2>/dev/null; then
  _fail "V23: glossary still claims 'two' no-override conditions"
else
  _pass "V23: glossary no longer asserts an exhaustive 'two no-override conditions' count"
fi
# Note: the source sentence wraps across two lines in the .md file, so this is checked as two
# single-line substrings rather than one multi-line phrase (a lesson from this session's own
# verification-script authorship history — never assume prose wrapping matches a grep pattern).
if grep -q "No override does not mean that recovery, retry" "$GLOSS" 2>/dev/null \
  && grep -q "permanently prohibited" "$GLOSS" 2>/dev/null; then
  _pass "V23: glossary correctly states no-override does not prohibit recovery/retry after the prerequisite resolves"
else
  _fail "V23: corrected no-override framing missing from glossary"
fi
if grep -q "Stage 10 invalid/expired reference standard" "$GLOSS" 2>/dev/null \
  && grep -q "Stage 7 cloud block" "$GLOSS" 2>/dev/null \
  && grep -q "Stage 12 cloud-backup block" "$GLOSS" 2>/dev/null; then
  _pass "V23: all three evidence-backed no-override examples present"
else
  _fail "V23: one or more required no-override examples missing"
fi

# ── V24: glossary 'Retry' definition corrected ──────────────────────────────
echo ""
echo "V24. Glossary 'Retry' entry corrected — retry is not an override, no blanket prohibition claim"
if grep -q "no retry, of any kind, is permitted" "$GLOSS" 2>/dev/null; then
  _fail "V24: glossary still contains the blanket 'no retry, of any kind, is permitted' claim"
else
  _pass "V24: blanket no-retry claim removed from glossary"
fi
if grep -q "Retry is not an override" "$GLOSS" 2>/dev/null && grep -q "lacks a recovery action for that stage" "$GLOSS" 2>/dev/null; then
  _pass "V24: corrected Retry definition present (not an override; Stage 7 distinct only for lacking a recovery action)"
else
  _fail "V24: corrected Retry definition missing or incomplete"
fi

# ── V25: factory-flow-model.md authority truth corrected ────────────────────
echo ""
echo "V25. docs/factory-flow-model.md Supervisor permission and authority-enforcement claims corrected"
if grep -qF "clear hard-stops" "$FFM" 2>/dev/null; then
  _fail "V25: docs/factory-flow-model.md still contains the overbroad 'clear hard-stops' permission phrase"
else
  _pass "V25: overbroad 'clear hard-stops' phrase removed from Supervisor permissions"
fi
if grep -q "Resolve Supervisor-actionable conditions" "$FFM" 2>/dev/null && grep -q "cannot bypass no-override conditions" "$FFM" 2>/dev/null; then
  _pass "V25: bounded Supervisor permission language present"
else
  _fail "V25: bounded Supervisor permission language missing"
fi
if grep -q "do \*\*not\*\* currently enforce actor authority" "$FFM" 2>/dev/null && grep -q "manufacturing-comprehension-model.md.*§10" "$FFM" 2>/dev/null; then
  _pass "V25: authority-enforcement scope corrected with cross-reference to canonical §10"
else
  _fail "V25: corrected authority-enforcement scope statement missing"
fi
# The old blanket claim must not remain as a standalone, uncorrected assertion.
if grep -qF "Authority is enforced by the backend. The frontend indicates authority gating" "$FFM" 2>/dev/null; then
  _fail "V25: overbroad blanket 'Authority is enforced by the backend' statement still present uncorrected"
else
  _pass "V25: overbroad blanket authority statement no longer stands alone/uncorrected"
fi

# ── V26: verification script itself is executable ──────────────────────────
echo ""
echo "V26. This verification script is executable"
if [ -x "scripts/verification/017-d9e-1-canonical-manufacturing-comprehension-model.sh" ]; then
  _pass "V26: script carries the executable bit"
else
  _fail "V26: script is not executable"
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
