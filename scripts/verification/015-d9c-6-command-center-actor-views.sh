#!/usr/bin/env bash
# 015-d9c-6-command-center-actor-views.sh — Verify D9C-6 Command-Center actor views
# Static, file-based checks — no live browser required. Run from repo root:
#   bash scripts/verification/015-d9c-6-command-center-actor-views.sh

set -uo pipefail

PASS=0; FAIL=0
DIR="frontend/src/components/variant-review/command-center"
CCV="$DIR/CommandCenterView.tsx"
ACV="$DIR/AssemblerCommandView.tsx"
FMCV="$DIR/FloorManagerCommandView.tsx"
CCAF="$DIR/CommandCenterActionForm.tsx"
VRS="frontend/src/components/variant-review/VariantReviewShell.tsx"
FFB="frontend/src/components/FactoryFlowBoard.tsx"
ACTP="frontend/src/components/ActionPanel.tsx"
ATTN_DIR="frontend/src/components/variant-review/attention-first"
WKFL_DIR="frontend/src/components/variant-review/workflow-first"

_pass() { echo "  PASS  $1"; PASS=$((PASS+1)); }
_fail() { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }

echo "015 — D9C-6 Command-Center Actor Views Verification"
echo "════════════════════════════════════════"

# ── V1: all four new files exist and are non-empty ───────────────────────────
echo ""
echo "V1. All four new command-center component files exist and are non-empty"
if [ -s "$CCV" ] && [ -s "$ACV" ] && [ -s "$FMCV" ] && [ -s "$CCAF" ]; then
  _pass "all four files exist and are non-empty"
else
  _fail "one or more of CommandCenterView/AssemblerCommandView/FloorManagerCommandView/CommandCenterActionForm missing or empty"
fi

# ── V2: CommandCenterView calls useFactoryViewModel exactly once ────────────
echo ""
echo "V2. $CCV imports useFactoryViewModel and calls it exactly once"
if grep -qE "import \{ *useFactoryViewModel *\} *from *'\.\./\.\./\.\./view-model/useFactoryViewModel'" "$CCV"; then
  _pass "useFactoryViewModel import present"
else
  _fail "useFactoryViewModel import missing"
fi
COUNT=$(grep -o "useFactoryViewModel(" "$CCV" | wc -l | tr -d ' ')
if [ "$COUNT" = "1" ]; then
  _pass "exactly one call site in CommandCenterView (found $COUNT)"
else
  _fail "expected exactly 1 call site in CommandCenterView, found $COUNT"
fi

# ── V3: no useFactoryViewModel call outside CommandCenterView ───────────────
echo ""
echo "V3. useFactoryViewModel is not re-invoked in the other three new files"
if grep -l "useFactoryViewModel(" "$ACV" "$FMCV" "$CCAF" 2>/dev/null | grep -q .; then
  _fail "found a useFactoryViewModel( call outside CommandCenterView"
else
  _pass "no second orchestration path — hook called only in CommandCenterView"
fi

# ── V4: no read (fetch*) import from factoryApi ──────────────────────────────
echo ""
echo "V4. No new file imports a fetch* read function from factoryApi"
if grep -hoE "fetch[A-Za-z]+" "$CCV" "$ACV" "$FMCV" "$CCAF" 2>/dev/null | grep -q .; then
  _fail "found a fetch* reference in one of the new files"
else
  _pass "no fetch* references found"
fi

# ── V5: only CommandCenterActionForm imports the four write functions ───────
echo ""
echo "V5. Only CommandCenterActionForm.tsx imports the action-submission functions"
if grep -lE "postReallocatePart|postCalibration|postCloudBackup" "$CCV" "$ACV" "$FMCV" 2>/dev/null | grep -q .; then
  _fail "found action-submission imports outside CommandCenterActionForm.tsx"
else
  _pass "action-submission functions imported only by CommandCenterActionForm.tsx"
fi
if grep -q "postReallocatePart" "$CCAF" && grep -q "postCalibration" "$CCAF" \
  && grep -q "postCalibrationDisposition" "$CCAF" && grep -q "postCloudBackup" "$CCAF"; then
  _pass "CommandCenterActionForm.tsx imports all four expected action functions"
else
  _fail "CommandCenterActionForm.tsx is missing one or more expected action-function imports"
fi

# ── V6: zero imports from attention-first/ or workflow-first/ ───────────────
echo ""
echo "V6. No new file imports from ../attention-first/ or ../workflow-first/"
if grep -lE "attention-first|workflow-first" "$CCV" "$ACV" "$FMCV" "$CCAF" 2>/dev/null | grep -q .; then
  _fail "found a reference to a sibling variant directory in one of the new files"
else
  _pass "command-center/ is fully independent of attention-first/ and workflow-first/"
fi

# ── V7: no raw endpoint-path text ────────────────────────────────────────────
echo ""
echo "V7. No raw endpoint-path text in the new files"
if grep -lE "Backend-guarded action|POST /factory" "$CCV" "$ACV" "$FMCV" "$CCAF" 2>/dev/null | grep -q .; then
  _fail "found raw endpoint-path text in one of the new files"
else
  _pass "no raw endpoint-path text found"
fi

# ── V8: no free-text actor-ID input field ────────────────────────────────────
echo ""
echo "V8. No free-text actor-ID input field in the new files"
if grep -lE "Actor User ID|actor_user_id: *[a-zA-Z]" "$CCV" "$ACV" "$FMCV" "$CCAF" 2>/dev/null | grep -q .; then
  _fail "found a possible editable actor-ID input or non-literal actor_user_id"
else
  _pass "no editable actor-ID input found (actor ids are fixed string literals)"
fi

# ── V9: no full 14-stage spine reproduction ─────────────────────────────────
echo ""
echo "V9. No full 14-stage StageSpine-style reproduction in the new files"
if grep -lE "StageSpine|14-Stage Production Spine" "$CCV" "$ACV" "$FMCV" "$CCAF" 2>/dev/null | grep -q .; then
  _fail "found a reference to the full stage spine in one of the new files"
else
  _pass "no full stage-spine reproduction found"
fi

# ── V10: single attention tier, no severity taxonomy ────────────────────────
echo ""
echo "V10. Attention derivation is single-tier (no severity taxonomy)"
if grep -qiE "severity|priority[0-9]|tier[0-9]" "$ACV" "$FMCV"; then
  _fail "found a possible multi-tier severity/priority reference"
else
  _pass "no multi-tier severity taxonomy found"
fi

# ── V11: Assembler renders Attention (conditional), Current Unit, Other Units, ──
# Supporting Detail simultaneously — no branch hides the whole Current Unit or
# Other Units region based on blocked state.
echo ""
echo "V11. AssemblerCommandView renders all four regions simultaneously"
if grep -qE '\{isBlocked &&' "$ACV"; then
  _pass "Attention region is a conditional-presence block (isBlocked && ...), not a takeover"
else
  _fail "did not find the expected {isBlocked && ...} conditional pattern"
fi
if grep -qE 'isBlocked *\?' "$ACV"; then
  _fail "found a ternary keyed on isBlocked — suggests a whole-view swap, not simultaneous regions"
else
  _pass "no isBlocked ? ... : ... ternary found (confirms no view swap)"
fi
if grep -q "Current Unit" "$ACV" && grep -q "Other Units" "$ACV"; then
  _pass "Current Unit and Other Units region labels both present"
else
  _fail "expected both a 'Current Unit' and an 'Other Units' region label"
fi

# ── V12: Supporting Detail defaults closed ──────────────────────────────────
echo ""
echo "V12. Supporting Detail region defaults closed (collapsed)"
if grep -qE '<details[^>]*>\s*$' "$ACV" || grep -qE '<details className="[^"]*">' "$ACV"; then
  if grep -qE '<details[^>]*\bopen\b' "$ACV"; then
    _fail "found a <details> element with an open attribute — should default closed"
  else
    _pass "found a <details> element with no open attribute (defaults closed)"
  fi
else
  _fail "no <details>-based Supporting Detail disclosure found"
fi

# ── V13: Floor Manager Attention/Triage region has no visibility-gating toggle ─
echo ""
echo "V13. FloorManagerCommandView's Attention/Triage region is not gated behind a toggle"
if grep -qE 'blockedUnits\.length > 0 &&' "$FMCV"; then
  _pass "Attention/Triage region renders directly whenever blockedUnits.length > 0"
else
  _fail "expected the Attention/Triage region to be gated only on blockedUnits.length > 0"
fi
if grep -qE '\btriageOpen\b' "$FMCV"; then
  _fail "found a triageOpen-style toggle — Command-Center's triage region must not require manual expansion"
else
  _pass "no triageOpen-style visibility toggle found"
fi

# ── V14: Queue and Secondary Context always rendered ────────────────────────
echo ""
echo "V14. Queue and Secondary Context regions are always rendered (no pane/tab gating)"
if grep -q "Queue" "$FMCV" && grep -q "Secondary Context" "$FMCV"; then
  _pass "both Queue and Secondary Context region labels present"
else
  _fail "expected both a 'Queue' and a 'Secondary Context' region label"
fi
if grep -qE "\bpane\b|setPane|activePane" "$FMCV"; then
  _fail "found a pane-switching pattern — Secondary Context must not be behind a tab"
else
  _pass "no pane/tab-switching pattern found — Secondary Context is always visible"
fi

# ── V15: Secondary Context is honest, no fabricated data ────────────────────
echo ""
echo "V15. Secondary Context states data is unavailable, with no fabricated numbers"
if grep -qi "not available" "$FMCV"; then
  _pass "Secondary Context content states data is not available"
else
  _fail "Secondary Context content does not state data is unavailable"
fi
if grep -qE "fetchOrders|/factory/orders" "$CCV" "$ACV" "$FMCV" "$CCAF" 2>/dev/null; then
  _fail "found a reference to the orders endpoint — should not be wired into this node"
else
  _pass "no orders-endpoint reference found — correctly out of scope"
fi

# ── V16: VariantReviewShell's variantC branch is correct, variantA/B untouched ─
echo ""
echo "V16. VariantReviewShell wiring is correctly scoped"
if grep -q "CommandCenterView" "$VRS"; then
  _pass "variantC now renders CommandCenterView"
else
  _fail "variantC does not reference CommandCenterView"
fi
if grep -q "AttentionFirstView" "$VRS"; then
  _pass "variantA still renders AttentionFirstView"
else
  _fail "variantA no longer references AttentionFirstView"
fi
if grep -q "WorkflowFirstView" "$VRS"; then
  _pass "variantB still renders WorkflowFirstView"
else
  _fail "variantB no longer references WorkflowFirstView"
fi
if grep -q "Variant A — Attention-First" "$VRS" && grep -q "Variant B — Workflow-First" "$VRS" \
  && grep -q "Variant C — Command-Center" "$VRS"; then
  _pass "top-level tab-bar labels unchanged"
else
  _fail "one or more top-level tab-bar labels changed"
fi

# ── V17: protected files untouched (git-based, best-effort) ─────────────────
echo ""
echo "V17. Protected surfaces show zero git diff"
if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
  # Note: AssemblerView.tsx/AttentionActionForm.tsx/FloorManagerView.tsx under
  # $ATTN_DIR and AssemblerWorkflowView.tsx/WorkflowActionForm.tsx/
  # FloorManagerWorkflowView.tsx under $WKFL_DIR are excluded here — a later,
  # cross-cutting bug fix legitimately touches these same three file-shapes in all
  # three variants (serialized-reallocation and dead-Resolve fixes). Everything else
  # under either directory remains protected.
  PROTECTED_DIFF=$(git diff --stat -- "$FFB" "$ACTP" "$ATTN_DIR" "$WKFL_DIR" \
    ":(exclude)$ATTN_DIR/AssemblerView.tsx" ":(exclude)$ATTN_DIR/AttentionActionForm.tsx" \
    ":(exclude)$ATTN_DIR/FloorManagerView.tsx" \
    ":(exclude)$WKFL_DIR/AssemblerWorkflowView.tsx" ":(exclude)$WKFL_DIR/WorkflowActionForm.tsx" \
    ":(exclude)$WKFL_DIR/FloorManagerWorkflowView.tsx" \
    frontend/src/view-model/ frontend/src/api/factoryApi.ts frontend/src/types/factory.ts \
    frontend/src/components/UnitList.tsx frontend/src/components/StageSpine.tsx \
    frontend/src/components/UnitDetailPanel.tsx frontend/src/components/EventTrace.tsx \
    frontend/src/main.tsx frontend/src/App.tsx \
    frontend/package.json frontend/package-lock.json 2>/dev/null)
  if [ -z "$PROTECTED_DIFF" ]; then
    _pass "no changes to any protected surface"
  else
    _fail "changes detected in a protected surface:"
    echo "$PROTECTED_DIFF"
  fi
else
  echo "  SKIP  git not available in this environment"
fi

# ── V18: no backend/data/vendor/.engineering-os files modified ──────────────
echo ""
echo "V18. No file under backend/, data/, vendor/, .engineering-os/ modified"
if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
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

# ── V19: no empty old_serial_number payload; serial derived from real allocation ─
echo ""
echo "V19. Reallocation payload uses a real, allocation-derived old serial number"
if grep -qE "old_serial_number: *''" "$CCAF"; then
  _fail "found a hardcoded empty old_serial_number: '' payload"
else
  _pass "no empty old_serial_number: '' payload found"
fi
if grep -q "findAffectedAllocation" "$CCAF" && grep -qE "old_serial_number: *target\.oldSerial" "$CCAF"; then
  _pass "old_serial_number is derived from a resolved allocation (target.oldSerial)"
else
  _fail "expected old_serial_number to be sourced from a resolved allocation, not a literal"
fi
if grep -q "part.serial_number" "$CCAF" || grep -qE "p\.serial_number" "$CCAF"; then
  _pass "the affected allocation's real serial number is looked up from the parts list"
else
  _fail "expected the affected allocation to resolve a real serial_number from parts"
fi

# ── V20: unsupported blocked units get truthful visible feedback, never a dead form ─
echo ""
echo "V20. Unsupported reallocation targets and unsupported triage items get truthful feedback"
if grep -q "hasSupportedAction" "$CCAF"; then
  _pass "CommandCenterActionForm exports a hasSupportedAction helper"
else
  _fail "expected CommandCenterActionForm to export hasSupportedAction"
fi
if grep -qi "No serialized part could be identified" "$CCAF"; then
  _pass "CommandCenterActionForm shows truthful feedback when no allocation can be resolved"
else
  _fail "expected a truthful message when no affected allocation can be resolved"
fi
if grep -q "hasSupportedAction" "$FMCV" && grep -qi "No resolution action is available" "$FMCV"; then
  _pass "FloorManagerCommandView's TriageRow shows truthful feedback instead of a dead Resolve control"
else
  _fail "expected FloorManagerCommandView's TriageRow to gate Resolve on hasSupportedAction with a truthful fallback"
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
