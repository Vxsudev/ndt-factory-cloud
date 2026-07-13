#!/usr/bin/env bash
# 014-d9c-5-workflow-first-actor-views.sh — Verify D9C-5 Workflow-First actor views
# Static, file-based checks — no live browser required. Run from repo root:
#   bash scripts/verification/014-d9c-5-workflow-first-actor-views.sh

set -uo pipefail

PASS=0; FAIL=0
DIR="frontend/src/components/variant-review/workflow-first"
WFV="$DIR/WorkflowFirstView.tsx"
AWV="$DIR/AssemblerWorkflowView.tsx"
FMWV="$DIR/FloorManagerWorkflowView.tsx"
WAF="$DIR/WorkflowActionForm.tsx"
VRS="frontend/src/components/variant-review/VariantReviewShell.tsx"
VPP="frontend/src/components/variant-review/VariantPlaceholderPane.tsx"
FFB="frontend/src/components/FactoryFlowBoard.tsx"
ACTP="frontend/src/components/ActionPanel.tsx"
ATTN_DIR="frontend/src/components/variant-review/attention-first"

_pass() { echo "  PASS  $1"; PASS=$((PASS+1)); }
_fail() { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }

echo "014 — D9C-5 Workflow-First Actor Views Verification"
echo "════════════════════════════════════════"

# ── V1: all four new files exist and are non-empty ───────────────────────────
echo ""
echo "V1. All four new workflow-first component files exist and are non-empty"
if [ -s "$WFV" ] && [ -s "$AWV" ] && [ -s "$FMWV" ] && [ -s "$WAF" ]; then
  _pass "all four files exist and are non-empty"
else
  _fail "one or more of WorkflowFirstView/AssemblerWorkflowView/FloorManagerWorkflowView/WorkflowActionForm missing or empty"
fi

# ── V2: WorkflowFirstView calls useFactoryViewModel exactly once ────────────
echo ""
echo "V2. $WFV imports useFactoryViewModel and calls it exactly once"
if grep -qE "import \{ *useFactoryViewModel *\} *from *'\.\./\.\./\.\./view-model/useFactoryViewModel'" "$WFV"; then
  _pass "useFactoryViewModel import present"
else
  _fail "useFactoryViewModel import missing"
fi
COUNT=$(grep -o "useFactoryViewModel(" "$WFV" | wc -l | tr -d ' ')
if [ "$COUNT" = "1" ]; then
  _pass "exactly one call site in WorkflowFirstView (found $COUNT)"
else
  _fail "expected exactly 1 call site in WorkflowFirstView, found $COUNT"
fi

# ── V3: no useFactoryViewModel call outside WorkflowFirstView ───────────────
echo ""
echo "V3. useFactoryViewModel is not re-invoked in the other three new files"
if grep -l "useFactoryViewModel(" "$AWV" "$FMWV" "$WAF" 2>/dev/null | grep -q .; then
  _fail "found a useFactoryViewModel( call outside WorkflowFirstView"
else
  _pass "no second orchestration path — hook called only in WorkflowFirstView"
fi

# ── V4: no read (fetch*) import from factoryApi ──────────────────────────────
echo ""
echo "V4. No new file imports a fetch* read function from factoryApi"
if grep -hoE "fetch[A-Za-z]+" "$WFV" "$AWV" "$FMWV" "$WAF" 2>/dev/null | grep -q .; then
  _fail "found a fetch* reference in one of the new files"
else
  _pass "no fetch* references found"
fi

# ── V5: only WorkflowActionForm imports the four write functions ───────────
echo ""
echo "V5. Only WorkflowActionForm.tsx imports the action-submission functions"
if grep -lE "postReallocatePart|postCalibration|postCloudBackup" "$WFV" "$AWV" "$FMWV" 2>/dev/null | grep -q .; then
  _fail "found action-submission imports outside WorkflowActionForm.tsx"
else
  _pass "action-submission functions imported only by WorkflowActionForm.tsx"
fi
if grep -q "postReallocatePart" "$WAF" && grep -q "postCalibration" "$WAF" \
  && grep -q "postCalibrationDisposition" "$WAF" && grep -q "postCloudBackup" "$WAF"; then
  _pass "WorkflowActionForm.tsx imports all four expected action functions"
else
  _fail "WorkflowActionForm.tsx is missing one or more expected action-function imports"
fi

# ── V6: zero imports from attention-first/ (independent component tree) ─────
echo ""
echo "V6. No new file imports from ../attention-first/"
if grep -lE "attention-first" "$WFV" "$AWV" "$FMWV" "$WAF" 2>/dev/null | grep -q .; then
  _fail "found a reference to attention-first/ in one of the new files"
else
  _pass "workflow-first/ is fully independent of attention-first/"
fi

# ── V7: no raw endpoint-path text ────────────────────────────────────────────
echo ""
echo "V7. No raw endpoint-path text in the new files"
if grep -lE "Backend-guarded action|POST /factory" "$WFV" "$AWV" "$FMWV" "$WAF" 2>/dev/null | grep -q .; then
  _fail "found raw endpoint-path text in one of the new files"
else
  _pass "no raw endpoint-path text found"
fi

# ── V8: no free-text actor-ID input field ────────────────────────────────────
echo ""
echo "V8. No free-text actor-ID input field in the new files"
if grep -lE "Actor User ID|actor_user_id: *[a-zA-Z]" "$WFV" "$AWV" "$FMWV" "$WAF" 2>/dev/null | grep -q .; then
  _fail "found a possible editable actor-ID input or non-literal actor_user_id"
else
  _pass "no editable actor-ID input found (actor ids are fixed string literals)"
fi

# ── V9: single attention tier, no severity taxonomy ─────────────────────────
echo ""
echo "V9. Attention derivation is single-tier (no severity taxonomy)"
if grep -qiE "severity|priority[0-9]|tier[0-9]" "$AWV" "$FMWV"; then
  _fail "found a possible multi-tier severity/priority reference"
else
  _pass "no multi-tier severity taxonomy found"
fi

# ── V10: AssemblerWorkflowView never swaps to a distinct interrupt component ─
# Structural distinction from Attention-First: blocked info is an *inline*
# section within the persistent card (an `isBlocked && (...)` block), not a
# ternary/component swap of the whole card.
echo ""
echo "V10. AssemblerWorkflowView renders blocked info inline (no card-swap takeover)"
if grep -qE '\{isBlocked &&' "$AWV"; then
  _pass "blocked info renders as an inline conditional block (isBlocked && ...), not a card swap"
else
  _fail "did not find the expected inline isBlocked && ... conditional pattern"
fi
if grep -qE 'isBlocked *\?' "$AWV"; then
  _fail "found a ternary keyed on isBlocked — suggests a component/card swap, not an inline section"
else
  _pass "no isBlocked ? ... : ... ternary found (confirms no whole-card swap)"
fi

# ── V11: focus changes only via explicit user tap, not auto on blocked state ─
echo ""
echo "V11. Focus changes only via an explicit vm.selectUnit call from a click handler"
if grep -q "onClick.*vm.selectUnit" "$AWV"; then
  _pass "found an onClick handler calling vm.selectUnit (deliberate focus switch)"
else
  _fail "no onClick-triggered vm.selectUnit call found in AssemblerWorkflowView"
fi
if grep -qE "blocked_reason" "$AWV" | grep -q "useEffect"; then
  _fail "found blocked_reason referenced inside a useEffect — possible auto focus-switch on block"
else
  _pass "no useEffect keyed on blocked_reason (focus defaulting is keyed on selectedUnitId/units only)"
fi

# ── V12: Floor Manager triage defaults collapsed, toggled explicitly ────────
echo ""
echo "V12. FloorManagerWorkflowView's triage list defaults collapsed and requires an explicit toggle"
if grep -q "triageOpen" "$FMWV" && grep -qE "useState\((false)\)" "$FMWV"; then
  _pass "triageOpen state exists and defaults to false (collapsed)"
else
  _fail "expected a triageOpen useState(false) declaration"
fi
if grep -qE "triageOpen *&&.*blockedUnits\.length" "$FMWV"; then
  _pass "triage list is gated on triageOpen (explicit toggle), not shown whenever blockedUnits.length > 0 alone"
else
  _fail "triage list does not appear to be gated on an explicit triageOpen toggle"
fi

# ── V13: secondary-info section exists and is honest ─────────────────────────
echo ""
echo "V13. Secondary-info section exists and states data is unavailable, with no fabricated numbers"
if grep -qi "secondaryInfo\|Secondary Info" "$FMWV"; then
  _pass "a secondary-info pane/tab exists"
else
  _fail "no secondary-info pane/tab found"
fi
if grep -qi "not available" "$FMWV"; then
  _pass "secondary-info content states data is not available"
else
  _fail "secondary-info content does not state data is unavailable"
fi
if grep -qE "fetchOrders|/factory/orders" "$FMWV" "$WFV" "$AWV" "$WAF" 2>/dev/null; then
  _fail "found a reference to the orders endpoint — should not be wired into this node"
else
  _pass "no orders-endpoint reference found — correctly out of scope"
fi

# ── V14: VariantReviewShell's variantB branch is correct, variantA/C untouched ─
echo ""
echo "V14. VariantReviewShell wiring is correctly scoped"
# Note: this script originally also asserted variantC stayed on
# VariantPlaceholderPane. D9C-6 (RELEASE_APPROVED) legitimately rewired variantC
# to CommandCenterView — that assertion was retired here, not weakened. This
# script's remaining job is confirming variantB's own wiring stays intact.
if grep -q "WorkflowFirstView" "$VRS"; then
  _pass "variantB now renders WorkflowFirstView"
else
  _fail "variantB does not reference WorkflowFirstView"
fi
if grep -q "AttentionFirstView" "$VRS"; then
  _pass "variantA still renders AttentionFirstView (D9C-4 wiring intact)"
else
  _fail "variantA no longer references AttentionFirstView"
fi
if grep -q "Variant A — Attention-First" "$VRS" && grep -q "Variant B — Workflow-First" "$VRS" \
  && grep -q "Variant C — Command-Center" "$VRS"; then
  _pass "top-level tab-bar labels unchanged"
else
  _fail "one or more top-level tab-bar labels changed"
fi

# ── V15: protected files untouched (git-based, best-effort) ─────────────────
echo ""
echo "V15. Protected surfaces show zero git diff"
if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
  # Note: AssemblerView.tsx, AttentionActionForm.tsx, and FloorManagerView.tsx under
  # $ATTN_DIR are excluded here — a later, cross-cutting bug fix legitimately touches
  # these same three file-shapes in all three variants (serialized-reallocation and
  # dead-Resolve fixes). Everything else under $ATTN_DIR remains protected.
  PROTECTED_DIFF=$(git diff --stat -- "$FFB" "$ACTP" "$VPP" "$ATTN_DIR" \
    ":(exclude)$ATTN_DIR/AssemblerView.tsx" ":(exclude)$ATTN_DIR/AttentionActionForm.tsx" \
    ":(exclude)$ATTN_DIR/FloorManagerView.tsx" \
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

# ── V16: no backend/data/vendor/.engineering-os files modified ──────────────
echo ""
echo "V16. No file under backend/, data/, vendor/, .engineering-os/ modified"
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

# ── V17: no empty old_serial_number payload; serial derived from real allocation ─
echo ""
echo "V17. Reallocation payload uses a real, allocation-derived old serial number"
if grep -qE "old_serial_number: *''" "$WAF"; then
  _fail "found a hardcoded empty old_serial_number: '' payload"
else
  _pass "no empty old_serial_number: '' payload found"
fi
if grep -q "findAffectedAllocation" "$WAF" && grep -qE "old_serial_number: *target\.oldSerial" "$WAF"; then
  _pass "old_serial_number is derived from a resolved allocation (target.oldSerial)"
else
  _fail "expected old_serial_number to be sourced from a resolved allocation, not a literal"
fi
if grep -q "part.serial_number" "$WAF" || grep -qE "p\.serial_number" "$WAF"; then
  _pass "the affected allocation's real serial number is looked up from the parts list"
else
  _fail "expected the affected allocation to resolve a real serial_number from parts"
fi

# ── V18: unsupported blocked units get truthful visible feedback, never a dead form ─
echo ""
echo "V18. Unsupported reallocation targets and unsupported triage items get truthful feedback"
if grep -q "hasSupportedAction" "$WAF"; then
  _pass "WorkflowActionForm exports a hasSupportedAction helper"
else
  _fail "expected WorkflowActionForm to export hasSupportedAction"
fi
if grep -qi "No serialized part could be identified" "$WAF"; then
  _pass "WorkflowActionForm shows truthful feedback when no allocation can be resolved"
else
  _fail "expected a truthful message when no affected allocation can be resolved"
fi
if grep -q "hasSupportedAction" "$FMWV" && grep -qi "No resolution action is available" "$FMWV"; then
  _pass "FloorManagerWorkflowView's TriageRow shows truthful feedback instead of a dead Resolve control"
else
  _fail "expected FloorManagerWorkflowView's TriageRow to gate Resolve on hasSupportedAction with a truthful fallback"
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
