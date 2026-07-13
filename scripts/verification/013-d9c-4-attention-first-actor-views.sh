#!/usr/bin/env bash
# 013-d9c-4-attention-first-actor-views.sh — Verify D9C-4 Attention-First actor views
# Static, file-based checks — no live browser required. Run from repo root:
#   bash scripts/verification/013-d9c-4-attention-first-actor-views.sh

set -uo pipefail

PASS=0; FAIL=0
DIR="frontend/src/components/variant-review/attention-first"
AFV="$DIR/AttentionFirstView.tsx"
ASV="$DIR/AssemblerView.tsx"
FMV="$DIR/FloorManagerView.tsx"
AAF="$DIR/AttentionActionForm.tsx"
VRS="frontend/src/components/variant-review/VariantReviewShell.tsx"
VPP="frontend/src/components/variant-review/VariantPlaceholderPane.tsx"
FFB="frontend/src/components/FactoryFlowBoard.tsx"
ACTP="frontend/src/components/ActionPanel.tsx"

_pass() { echo "  PASS  $1"; PASS=$((PASS+1)); }
_fail() { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }

echo "013 — D9C-4 Attention-First Actor Views Verification"
echo "════════════════════════════════════════"

# ── V1: all four new files exist and are non-empty ───────────────────────────
echo ""
echo "V1. All four new attention-first component files exist and are non-empty"
if [ -s "$AFV" ] && [ -s "$ASV" ] && [ -s "$FMV" ] && [ -s "$AAF" ]; then
  _pass "all four files exist and are non-empty"
else
  _fail "one or more of AttentionFirstView/AssemblerView/FloorManagerView/AttentionActionForm missing or empty"
fi

# ── V2: AttentionFirstView imports and calls useFactoryViewModel exactly once ─
echo ""
echo "V2. $AFV imports useFactoryViewModel and calls it exactly once"
if grep -qE "import \{ *useFactoryViewModel *\} *from *'\.\./\.\./\.\./view-model/useFactoryViewModel'" "$AFV"; then
  _pass "useFactoryViewModel import present"
else
  _fail "useFactoryViewModel import missing"
fi
COUNT=$(grep -o "useFactoryViewModel(" "$AFV" | wc -l | tr -d ' ')
if [ "$COUNT" = "1" ]; then
  _pass "exactly one call site in AttentionFirstView (found $COUNT)"
else
  _fail "expected exactly 1 call site in AttentionFirstView, found $COUNT"
fi

# ── V3: no useFactoryViewModel call in AssemblerView/FloorManagerView/AttentionActionForm ─
echo ""
echo "V3. useFactoryViewModel is not re-invoked in AssemblerView/FloorManagerView/AttentionActionForm"
if grep -l "useFactoryViewModel(" "$ASV" "$FMV" "$AAF" 2>/dev/null | grep -q .; then
  _fail "found a useFactoryViewModel( call outside AttentionFirstView"
else
  _pass "no second orchestration path — hook called only in AttentionFirstView"
fi

# ── V4: no read (fetch*) import from factoryApi in any of the four files ─────
echo ""
echo "V4. No new file imports a fetch* read function from factoryApi"
if grep -hoE "fetch[A-Za-z]+" "$AFV" "$ASV" "$FMV" "$AAF" 2>/dev/null | grep -q .; then
  _fail "found a fetch* reference in one of the new files"
else
  _pass "no fetch* references found"
fi

# ── V5: only AttentionActionForm imports the four write functions ───────────
echo ""
echo "V5. Only AttentionActionForm.tsx imports the action-submission functions"
if grep -lE "postReallocatePart|postCalibration|postCloudBackup" "$AFV" "$ASV" "$FMV" 2>/dev/null | grep -q .; then
  _fail "found action-submission imports outside AttentionActionForm.tsx"
else
  _pass "action-submission functions imported only by AttentionActionForm.tsx"
fi
if grep -q "postReallocatePart" "$AAF" && grep -q "postCalibration" "$AAF" \
  && grep -q "postCalibrationDisposition" "$AAF" && grep -q "postCloudBackup" "$AAF"; then
  _pass "AttentionActionForm.tsx imports all four expected action functions"
else
  _fail "AttentionActionForm.tsx is missing one or more expected action-function imports"
fi

# ── V6: no raw endpoint-path text in the new files ───────────────────────────
echo ""
echo "V6. No raw endpoint-path text (e.g. 'POST /factory/units') in the new files"
if grep -lE "Backend-guarded action|POST /factory" "$AFV" "$ASV" "$FMV" "$AAF" 2>/dev/null | grep -q .; then
  _fail "found raw endpoint-path text in one of the new files"
else
  _pass "no raw endpoint-path text found"
fi

# ── V7: no free-text actor-ID input field ────────────────────────────────────
# Note: "actorId"/"activeActor" in AttentionFirstView is the Assembler/Floor-Manager
# UI switcher, not a free-text actor_user_id field — deliberately not matched here.
echo ""
echo "V7. No free-text actor-ID input field in the new files"
if grep -lE "Actor User ID|actor_user_id: *[a-zA-Z]" "$AFV" "$ASV" "$FMV" "$AAF" 2>/dev/null | grep -q .; then
  _fail "found a possible editable actor-ID input or non-literal actor_user_id in one of the new files"
else
  _pass "no editable actor-ID input found (actor ids are fixed string literals)"
fi

# ── V8: attention derivation is exactly blocked_reason != null && !terminal ──
echo ""
echo "V8. Attention/blocked derivation in FloorManagerView matches the single-tier rule"
if grep -q "package_ship_status.terminal" "$FMV" && grep -q "blocked_reason != null" "$FMV"; then
  _pass "FloorManagerView derives attention from blocked_reason != null and !terminal"
else
  _fail "FloorManagerView's attention derivation does not match the expected rule"
fi
if grep -qiE "severity|priority[0-9]|tier[0-9]" "$FMV" "$ASV"; then
  _fail "found a possible multi-tier severity/priority reference"
else
  _pass "no multi-tier severity taxonomy found"
fi

# ── V9: Assembler interrupt state gates AttentionActionForm to stage 12 only ─
echo ""
echo "V9. AssemblerView only renders AttentionActionForm unconditionally for stage 12 in the interrupt branch"
if grep -q "current_stage_number === 12" "$ASV"; then
  _pass "AssemblerView checks current_stage_number === 12 before showing an interrupt-state action"
else
  _fail "AssemblerView does not gate the interrupt-state action to stage 12"
fi
if grep -qi "needs floor manager approval" "$ASV"; then
  _pass "AssemblerView shows the truthful 'needs floor manager approval' fallback message"
else
  _fail "AssemblerView is missing the truthful fallback message for non-stage-12 blocked units"
fi

# ── V10: VariantReviewShell's variantA branch is correct ─────────────────────
# Note: this script originally also asserted variantB, then variantC, stayed on
# VariantPlaceholderPane. D9C-5 (RELEASE_APPROVED) legitimately rewired variantB
# to WorkflowFirstView, and D9C-6 (RELEASE_APPROVED) legitimately rewired variantC
# to CommandCenterView — both assertions were retired here, not weakened. This
# script's remaining job is confirming variantA's own wiring stays intact.
echo ""
echo "V10. VariantReviewShell's variantA wiring is intact"
if grep -q "AttentionFirstView" "$VRS"; then
  _pass "variantA now renders AttentionFirstView"
else
  _fail "variantA does not reference AttentionFirstView"
fi
if grep -q "Variant A — Attention-First" "$VRS" && grep -q "Variant B — Workflow-First" "$VRS" \
  && grep -q "Variant C — Command-Center" "$VRS"; then
  _pass "top-level tab-bar labels unchanged"
else
  _fail "one or more top-level tab-bar labels changed"
fi

# ── V11: protected files untouched (git-based, best-effort) ─────────────────
echo ""
echo "V11. Protected surfaces show zero git diff"
if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
  PROTECTED_DIFF=$(git diff --stat -- "$FFB" "$ACTP" "$VPP" \
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

# ── V12: no backend/data/vendor/.engineering-os files modified ──────────────
echo ""
echo "V12. No file under backend/, data/, vendor/, .engineering-os/ modified"
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

# ── V13: no empty old_serial_number payload; serial derived from real allocation ─
echo ""
echo "V13. Reallocation payload uses a real, allocation-derived old serial number"
if grep -qE "old_serial_number: *''" "$AAF"; then
  _fail "found a hardcoded empty old_serial_number: '' payload"
else
  _pass "no empty old_serial_number: '' payload found"
fi
if grep -q "findAffectedAllocation" "$AAF" && grep -qE "old_serial_number: *target\.oldSerial" "$AAF"; then
  _pass "old_serial_number is derived from a resolved allocation (target.oldSerial)"
else
  _fail "expected old_serial_number to be sourced from a resolved allocation, not a literal"
fi
if grep -q "part.serial_number" "$AAF" || grep -qE "p\.serial_number" "$AAF"; then
  _pass "the affected allocation's real serial number is looked up from the parts list"
else
  _fail "expected the affected allocation to resolve a real serial_number from parts"
fi

# ── V14: unsupported blocked units get truthful visible feedback, never a dead form ─
echo ""
echo "V14. Unsupported reallocation targets and unsupported triage items get truthful feedback"
if grep -q "hasSupportedAction" "$AAF"; then
  _pass "AttentionActionForm exports a hasSupportedAction helper"
else
  _fail "expected AttentionActionForm to export hasSupportedAction"
fi
if grep -qi "No serialized part could be identified" "$AAF"; then
  _pass "AttentionActionForm shows truthful feedback when no allocation can be resolved"
else
  _fail "expected a truthful message when no affected allocation can be resolved"
fi
if grep -q "hasSupportedAction" "$FMV" && grep -qi "No resolution action is available" "$FMV"; then
  _pass "FloorManagerView's TriageRow shows truthful feedback instead of a dead Resolve control"
else
  _fail "expected FloorManagerView's TriageRow to gate Resolve on hasSupportedAction with a truthful fallback"
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
