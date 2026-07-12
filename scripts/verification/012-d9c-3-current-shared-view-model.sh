#!/usr/bin/env bash
# 012-d9c-3-current-shared-view-model.sh — Verify D9C-3 Current->useFactoryViewModel migration
# Static, file-based checks — no live browser required. Run from repo root:
#   bash scripts/verification/012-d9c-3-current-shared-view-model.sh

set -euo pipefail

PASS=0; FAIL=0
FFB="frontend/src/components/FactoryFlowBoard.tsx"
VRS="frontend/src/components/variant-review/VariantReviewShell.tsx"
VPP="frontend/src/components/variant-review/VariantPlaceholderPane.tsx"

_check() {
  local label="$1" cond="$2"
  if [ "$cond" = "0" ]; then
    echo "  PASS  $label"
    PASS=$((PASS+1))
  else
    echo "  FAIL  $label"
    FAIL=$((FAIL+1))
  fi
}

echo "012 — D9C-3 Current Shared View Model Migration Verification"
echo "════════════════════════════════════════"

# ── V1: FactoryFlowBoard imports useFactoryViewModel ─────────────────────────
echo ""
echo "V1. $FFB imports useFactoryViewModel from ../view-model/useFactoryViewModel"
grep -qE "import \{ *useFactoryViewModel *\} *from *'\.\./view-model/useFactoryViewModel'" "$FFB"
_check "useFactoryViewModel import present" "$?"

# ── V2: invoked exactly once ─────────────────────────────────────────────────
echo ""
echo "V2. useFactoryViewModel( invoked exactly once in $FFB"
COUNT=$(grep -o "useFactoryViewModel(" "$FFB" | wc -l | tr -d ' ')
if [ "$COUNT" = "1" ]; then
  echo "  PASS  exactly one call site (found $COUNT)"
  PASS=$((PASS+1))
else
  echo "  FAIL  expected exactly 1 call site, found $COUNT"
  FAIL=$((FAIL+1))
fi

# ── V3: no direct factoryApi import ──────────────────────────────────────────
echo ""
echo "V3. $FFB contains no import from ../api/factoryApi"
if grep -q "from '\.\./api/factoryApi'" "$FFB"; then
  echo "  FAIL  found a direct ../api/factoryApi import"
  FAIL=$((FAIL+1))
else
  echo "  PASS  no direct ../api/factoryApi import"
  PASS=$((PASS+1))
fi

# ── V4: theme state still local ──────────────────────────────────────────────
echo ""
echo "V4. theme state still declared locally in $FFB"
grep -qE "useState<'light' \| 'dark'>" "$FFB"
_check "theme useState present" "$?"

# ── V5: compactPane state still local ────────────────────────────────────────
echo ""
echo "V5. compactPane state still declared locally in $FFB"
grep -q "compactPane" "$FFB"
_check "compactPane state present" "$?"

# ── V6: variant-review components remain unwired ────────────────────────────
echo ""
echo "V6. variant-review components import neither factoryApi nor view-model"
if grep -qE "factoryApi|view-model" "$VRS" "$VPP" 2>/dev/null; then
  echo "  FAIL  variant-review component references factoryApi or view-model"
  FAIL=$((FAIL+1))
else
  echo "  PASS  variant-review components remain unwired"
  PASS=$((PASS+1))
fi

# ── V7: view-model source files untouched by this script's concerns ─────────
echo ""
echo "V7. frontend/src/view-model/{types.ts,useFactoryViewModel.ts} exist"
if [ -s frontend/src/view-model/types.ts ] && [ -s frontend/src/view-model/useFactoryViewModel.ts ]; then
  echo "  PASS  both view-model files exist and are non-empty"
  PASS=$((PASS+1))
else
  echo "  FAIL  one or both view-model files missing/empty"
  FAIL=$((FAIL+1))
fi

# ── V8: no backend files modified (best-effort, git-based) ──────────────────
echo ""
echo "V8. No file under backend/ modified (working-tree check)"
if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
  BACKEND_DIFF=$(git status --porcelain -- backend/ 2>/dev/null || true)
  if [ -z "$BACKEND_DIFF" ]; then
    echo "  PASS  no changes under backend/"
    PASS=$((PASS+1))
  else
    echo "  FAIL  changes detected under backend/:"
    echo "$BACKEND_DIFF"
    FAIL=$((FAIL+1))
  fi
else
  echo "  SKIP  git not available in this environment — cannot check backend/ diff"
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
