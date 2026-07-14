#!/usr/bin/env bash
# 016-d9d-cross-variant-parity.sh — Verify D9D cross-variant parity corrections
# Static, file-based checks — no live browser required. Run from repo root:
#   bash scripts/verification/016-d9d-cross-variant-parity.sh

set -uo pipefail

PASS=0; FAIL=0
ATTN_DIR="frontend/src/components/variant-review/attention-first"
WKFL_DIR="frontend/src/components/variant-review/workflow-first"
CC_DIR="frontend/src/components/variant-review/command-center"
AFV="$ATTN_DIR/AttentionFirstView.tsx"
ASV="$ATTN_DIR/AssemblerView.tsx"
FMV="$ATTN_DIR/FloorManagerView.tsx"
AAF="$ATTN_DIR/AttentionActionForm.tsx"
WFV="$WKFL_DIR/WorkflowFirstView.tsx"
AWV="$WKFL_DIR/AssemblerWorkflowView.tsx"
FMWV="$WKFL_DIR/FloorManagerWorkflowView.tsx"
WAF="$WKFL_DIR/WorkflowActionForm.tsx"
CCV="$CC_DIR/CommandCenterView.tsx"
ACV="$CC_DIR/AssemblerCommandView.tsx"
FMCV="$CC_DIR/FloorManagerCommandView.tsx"
CCAF="$CC_DIR/CommandCenterActionForm.tsx"
FFB="frontend/src/components/FactoryFlowBoard.tsx"
ACTP="frontend/src/components/ActionPanel.tsx"
VRS="frontend/src/components/variant-review/VariantReviewShell.tsx"

_pass() { echo "  PASS  $1"; PASS=$((PASS+1)); }
_fail() { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }

echo "016 — D9D Cross-Variant Parity Verification"
echo "════════════════════════════════════════"

# ── V1-V4: shared view-model single-invocation in all four options ──────────
echo ""
echo "V1-V4. Shared view model consumed exactly once per root"
for f in "$FFB" "$AFV" "$WFV" "$CCV"; do
  COUNT=$(grep -o "useFactoryViewModel(" "$f" | wc -l | tr -d ' ')
  if [ "$COUNT" = "1" ]; then
    _pass "$f invokes useFactoryViewModel exactly once"
  else
    _fail "$f invokes useFactoryViewModel $COUNT times (expected 1)"
  fi
done

# ── V5: no parallel initial-data fetching in any actor-first sub-view ───────
echo ""
echo "V5. No sub-view re-invokes useFactoryViewModel"
if grep -l "useFactoryViewModel(" "$ASV" "$FMV" "$AAF" "$AWV" "$FMWV" "$WAF" "$ACV" "$FMCV" "$CCAF" 2>/dev/null | grep -q .; then
  _fail "found a useFactoryViewModel( call outside a root View"
else
  _pass "no sub-view re-invokes the shared hook"
fi

# ── V6: no second factory-data store (no fetch* outside the hook) ──────────
echo ""
echo "V6. No new file imports a fetch* read function"
if grep -hoE "fetch[A-Za-z]+" "$ASV" "$FMV" "$AAF" "$AWV" "$FMWV" "$WAF" "$ACV" "$FMCV" "$CCAF" 2>/dev/null | grep -q .; then
  _fail "found a fetch* reference in a variant component"
else
  _pass "no fetch* references found outside the shared hook"
fi

# ── V7: equivalent unit-eligibility / terminal-filtering rules ──────────────
echo ""
echo "V7. Equivalent terminal-unit filtering across all three variants"
for f in "$ASV" "$AWV" "$ACV"; do
  if grep -q "package_ship_status.terminal" "$f"; then
    _pass "$f filters by package_ship_status.terminal"
  else
    _fail "$f does not reference package_ship_status.terminal"
  fi
done

# ── V8: equivalent initial-focus rule ────────────────────────────────────────
echo ""
echo "V8. Equivalent initial-focus rule across all three Assembler views"
for f in "$ASV" "$AWV" "$ACV"; do
  if grep -q "selectedUnitId == null" "$f" && grep -q "vm.selectUnit(first.id)" "$f"; then
    _pass "$f defaults focus to the first non-terminal unit"
  else
    _fail "$f is missing the expected default-focus rule"
  fi
done

# ── V9: equivalent attention derivation ──────────────────────────────────────
echo ""
echo "V9. Equivalent attention derivation across all three Floor Manager views"
for f in "$FMV" "$FMWV" "$FMCV"; do
  if grep -q "blocked_reason != null" "$f"; then
    _pass "$f derives attention from blocked_reason != null"
  else
    _fail "$f does not derive attention from blocked_reason != null"
  fi
done

# ── V10: equivalent supported-action detection, including corrected visibility ─
echo ""
echo "V10. hasSupportedAction present and consistent in all three *ActionForm.tsx"
for f in "$AAF" "$WAF" "$CCAF"; do
  if grep -q "export function hasSupportedAction" "$f" && grep -q "findAffectedAllocation" "$f"; then
    _pass "$f exports hasSupportedAction backed by findAffectedAllocation"
  else
    _fail "$f is missing hasSupportedAction/findAffectedAllocation"
  fi
done

echo ""
echo "V10b. Corrected calm-state action visibility (Workflow-First / Command-Center)"
if grep -qE '\{!isBlocked && \($' "$AWV" || grep -qE '\{!isBlocked &&' "$AWV"; then
  _pass "AssemblerWorkflowView renders its action form when !isBlocked"
else
  _fail "AssemblerWorkflowView does not render an action form when !isBlocked"
fi
if grep -qE '\{!isBlocked &&' "$ACV"; then
  _pass "AssemblerCommandView renders its action form when !isBlocked"
else
  _fail "AssemblerCommandView does not render an action form when !isBlocked"
fi
# Attention-First already had this correctly (reference implementation) — confirm unchanged.
# Its calm branch renders the form INSIDE the existing isBlocked ? ternary's else
# arm (that ternary is its intentional takeover structure, not a defect) — so this
# checks for presence of both, not absence of the ternary.
if grep -q "AttentionActionForm" "$ASV" && grep -qE 'isBlocked \?' "$ASV"; then
  _pass "AssemblerView (reference) still renders its action form in the calm branch of its intentional takeover ternary"
else
  _fail "AssemblerView's reference calm-state pattern looks different than expected"
fi

# ── V11: no NEW card-swap ternary introduced in the two corrected views ─────
echo ""
echo "V11. No isBlocked ? ternary introduced in Workflow-First/Command-Center (structural-distinction preserved)"
for f in "$AWV" "$ACV"; do
  if grep -qE 'isBlocked \?' "$f"; then
    _fail "$f contains an isBlocked ? ternary — suggests a card-swap, not additive regions"
  else
    _pass "$f has no isBlocked ? ternary"
  fi
done
# Attention-First's own pre-existing ternary is its intentional, protected takeover
# structure (confirmed in V10b) — it must NOT be flagged as a violation here.
if grep -qE 'isBlocked \?' "$ASV"; then
  _pass "AssemblerView retains its intentional isBlocked ? takeover ternary (protected, not a violation)"
else
  _fail "AssemblerView unexpectedly lost its intentional isBlocked ? takeover ternary"
fi

# ── V12: Stage-5 part resolution / no empty old serial (already-remediated) ─
echo ""
echo "V12. Stage-5 old serial is always allocation-derived, never a literal empty string"
for f in "$AAF" "$WAF" "$CCAF"; do
  if grep -qE "old_serial_number: *''" "$f"; then
    _fail "$f still sends a literal empty old_serial_number"
  else
    _pass "$f never sends a literal empty old_serial_number"
  fi
done

# ── V13-V15: new-serial validation now present ──────────────────────────────
echo ""
echo "V13-V15. New-serial non-empty validation present on Submit Reallocation only"
for f in "$AAF" "$WAF" "$CCAF"; do
  if grep -qE "disabled=\{newSerial\.trim\(\)\.length === 0\}" "$f"; then
    _pass "$f blocks submission when newSerial is empty"
  else
    _fail "$f does not validate newSerial before submission"
  fi
  # Ensure only the Stage-5 submit button gets this — count occurrences of the new
  # disabled prop should be exactly 1 (attached to Submit Reallocation only).
  COUNT=$(grep -oE "disabled=\{newSerial\.trim\(\)\.length === 0\}" "$f" | wc -l | tr -d ' ')
  if [ "$COUNT" = "1" ]; then
    _pass "$f applies the new-serial guard to exactly one submit button"
  else
    _fail "$f applies the new-serial guard to $COUNT submit buttons (expected 1)"
  fi
done

# ── V16-V18: calibration/disposition/cloud-backup payload semantics match ───
echo ""
echo "V16-V18. Calibration/disposition/cloud-backup payload semantics match across variants"
for pair in "postCalibration(" "postCalibrationDisposition(" "postCloudBackup("; do
  A=$(grep -c "$pair" "$AAF")
  W=$(grep -c "$pair" "$WAF")
  C=$(grep -c "$pair" "$CCAF")
  if [ "$A" = "$W" ] && [ "$W" = "$C" ]; then
    _pass "call count for $pair matches across all three forms ($A each)"
  else
    _fail "call count for $pair differs: attention=$A workflow=$W command-center=$C"
  fi
done

# ── V19: equivalent actor authority ──────────────────────────────────────────
echo ""
echo "V19. Equivalent fixed demo-actor authority across all three forms"
for actor in "USER-SUP-0001" "USER-TECH-0001" "USER-MGR-0001" "USER-OP-0001"; do
  if grep -q "$actor" "$AAF" && grep -q "$actor" "$WAF" && grep -q "$actor" "$CCAF"; then
    _pass "actor constant $actor present in all three forms"
  else
    _fail "actor constant $actor missing from one or more forms"
  fi
done

# ── V20: equivalent post-action refresh behavior ────────────────────────────
echo ""
echo "V20. Equivalent refresh split (refreshSelected for focused unit, reload for triage)"
for f in "$ASV" "$AWV" "$ACV"; do
  if grep -q "vm.refreshSelected()" "$f"; then
    _pass "$f refreshes the focused unit via vm.refreshSelected()"
  else
    _fail "$f does not call vm.refreshSelected()"
  fi
done
for f in "$FMV" "$FMWV" "$FMCV"; do
  if grep -q "vm.reload()" "$f"; then
    _pass "$f reloads the full list via vm.reload() after a triage action"
  else
    _fail "$f does not call vm.reload()"
  fi
done

# ── V21: equivalent mutation errors are visible ─────────────────────────────
echo ""
echo "V21. Mutation errors are visibly rendered in all three *ActionForm.tsx"
for f in "$AAF" "$WAF" "$CCAF"; do
  if grep -q "{error && <div className=\"t-on-error text-sm\">Error: {error}</div>}" "$f"; then
    _pass "$f renders mutation errors visibly"
  else
    _fail "$f does not render mutation errors in the expected way"
  fi
done

# ── V22-V23: unsupported attention feedback, no dead Resolve ───────────────
echo ""
echo "V22-V23. No dead Resolve control; truthful unsupported-action feedback"
for f in "$FMV" "$FMWV" "$FMCV"; do
  if grep -q "hasSupportedAction(unit, vm.parts)" "$f" && grep -qi "No resolution action is available" "$f"; then
    _pass "$f gates Resolve on hasSupportedAction with a truthful fallback"
  else
    _fail "$f is missing the hasSupportedAction gate or truthful fallback message"
  fi
done

# ── V24-V25: actor switching / variant switching (structural, established) ──
echo ""
echo "V24-V25. Actor-switch and variant-switch structural markers intact"
for f in "$AFV" "$WFV" "$CCV"; do
  if grep -q "activeActor" "$f"; then
    _pass "$f holds its own activeActor state (no duplicate hook invocation on switch)"
  else
    _fail "$f is missing activeActor state"
  fi
done
if grep -q "AttentionFirstView" "$VRS" && grep -q "WorkflowFirstView" "$VRS" && grep -q "CommandCenterView" "$VRS"; then
  _pass "VariantReviewShell still wires all three variants correctly"
else
  _fail "VariantReviewShell is missing one or more variant wirings"
fi

# ── V26-V29: intentional structural differences remain intact ──────────────
echo ""
echo "V26-V29. Intentional structural differences remain intact"
if grep -qE 'isBlocked \?' "$ASV"; then
  _pass "Attention-First's Assembler still uses the ternary card-swap takeover pattern"
else
  _fail "Attention-First's Assembler no longer shows the expected takeover ternary"
fi
if grep -q "triageOpen" "$FMWV"; then
  _pass "Workflow-First's Floor Manager still has the collapsed-by-default triage toggle"
else
  _fail "Workflow-First's Floor Manager is missing the triageOpen toggle"
fi
if ! grep -q "triageOpen" "$FMCV" && grep -qE 'blockedUnits\.length > 0 &&' "$FMCV"; then
  _pass "Command-Center's Floor Manager still shows attention directly, no toggle"
else
  _fail "Command-Center's Floor Manager structure looks different than expected"
fi
if grep -q "Unit Queue" "$FFB" && grep -q "14-Stage Production Spine" "$FFB"; then
  _pass "Current still renders the engineering-console baseline"
else
  _fail "Current's engineering-console baseline looks different than expected"
fi

# ── V30: no backend/API/data/view-model surface changed ────────────────────
echo ""
echo "V30. No backend/API/data/view-model surface changed"
if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
  PROTECTED_DIFF=$(git diff --stat -- "$FFB" "$ACTP" "$VRS" "$ASV" "$FMV" "$FMWV" "$FMCV" \
    frontend/src/view-model/ frontend/src/api/ frontend/src/types/ frontend/src/styles.css \
    frontend/src/components/UnitList.tsx frontend/src/components/StageSpine.tsx \
    frontend/src/components/UnitDetailPanel.tsx frontend/src/components/EventTrace.tsx \
    frontend/src/main.tsx frontend/src/App.tsx \
    frontend/package.json frontend/package-lock.json 2>/dev/null)
  if [ -z "$PROTECTED_DIFF" ]; then
    _pass "no changes to any protected or unrelated-variant surface"
  else
    _fail "changes detected in a protected surface:"
    echo "$PROTECTED_DIFF"
  fi
  OTHER_DIFF=$(git status --porcelain -- backend/ data/ vendor/ .engineering-os/ 2>/dev/null)
  if [ -z "$OTHER_DIFF" ]; then
    _pass "no changes under backend/, data/, vendor/, .engineering-os/"
  else
    _fail "changes detected:"
    echo "$OTHER_DIFF"
  fi
else
  echo "  SKIP  git not available in this environment"
fi

# ── V31-V32: no visual-polish or touch-optimization mutation ────────────────
echo ""
echo "V31-V32. No visual-polish or touch-optimization mutation introduced"
if grep -qE "className=\"[^\"]*touch-target" <(git diff -- "$AWV" "$ACV" "$AAF" "$WAF" "$CCAF" 2>/dev/null | grep '^+' | grep -v '^+++'); then
  _fail "found a new touch-target class in the D9D diff — out of scope for this node"
else
  _pass "no new touch-target/visual class introduced by the D9D diff"
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
