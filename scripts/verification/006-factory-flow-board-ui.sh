#!/usr/bin/env bash
# 006-factory-flow-board-ui.sh — Verify D6 Factory Flow Board UI
# REQUIRES: docker compose up must be running before this script.
# Run from repo root: bash scripts/verification/006-factory-flow-board-ui.sh

set -euo pipefail

BACKEND_URL="${BACKEND_URL:-http://localhost:8000}"
FRONTEND_URL="${FRONTEND_URL:-http://localhost:5173}"
PASS=0; FAIL=0

_get_http() {
  curl -s -o /dev/null -w "%{http_code}" "$1" 2>/dev/null || echo "000"
}

_get_body() {
  curl -s "$1" 2>/dev/null || echo ""
}

_post_http() {
  curl -s -o /dev/null -w "%{http_code}" -X POST "$1" \
    -H "Content-Type: application/json" -d "$2" 2>/dev/null || echo "000"
}

_check() {
  local label="$1" actual="$2" expected="$3"
  if [ "$actual" = "$expected" ]; then
    echo "  PASS  $label"
    PASS=$((PASS+1))
  else
    echo "  FAIL  $label (got '$actual', expected '$expected')"
    FAIL=$((FAIL+1))
  fi
}

echo "006 — Factory Flow Board UI Verification"
echo "════════════════════════════════════════"
echo "  Backend:  $BACKEND_URL"
echo "  Frontend: $FRONTEND_URL"
echo ""

# ── V1: frontend root loads ───────────────────────────────────────────────────

echo "V1. Frontend root returns 200"
HTTP=$(_get_http "${FRONTEND_URL}")
_check "frontend returns 200" "$HTTP" "200"

# ── V2: D6 meta marker present ────────────────────────────────────────────────

echo ""
echo "V2. index.html contains D6 factory-flow-board meta marker"
BODY=$(_get_body "${FRONTEND_URL}")
if echo "$BODY" | grep -q "factory-flow-board"; then
  echo "  PASS  D6 factory-flow-board meta marker found"
  PASS=$((PASS+1))
else
  echo "  FAIL  D6 factory-flow-board marker not found in index.html"
  FAIL=$((FAIL+1))
fi

# ── V3: title contains Factory Cloud ─────────────────────────────────────────
# (D8 changed subtitle from "D6 Factory Flow Board" to "D8 Review Prototype";
#  this check now verifies "Factory Cloud" is still present in the page)

echo ""
echo "V3. index.html contains Factory Cloud v0"
if echo "$BODY" | grep -q "Factory Cloud"; then
  echo "  PASS  Factory Cloud found in page"
  PASS=$((PASS+1))
else
  echo "  FAIL  Factory Cloud not found in index.html"
  FAIL=$((FAIL+1))
fi

# ── V4: D4 backward compat ────────────────────────────────────────────────────

echo ""
echo "V4. D4 data-contract status still works"
HTTP=$(_get_http "${BACKEND_URL}/factory/data-contract/status")
_check "D4 data-contract status returns 200" "$HTTP" "200"

# ── V5: D5 reset-state still responds ────────────────────────────────────────

echo ""
echo "V5. D5 reset-state endpoint still responds"
HTTP=$(_post_http "${BACKEND_URL}/factory/dev/reset-state" '{}')
_check "D5 reset-state returns 200" "$HTTP" "200"

# ── V6: no Azure SDK ──────────────────────────────────────────────────────────
# (D7 adds Postgres; the invariant is "no Azure SDK", not "no Postgres")

echo ""
echo "V6. No Azure SDK in requirements.txt (D7: Postgres is expected)"
if grep -qi "azure" backend/requirements.txt 2>/dev/null; then
  echo "  FAIL  Azure SDK found in requirements.txt"
  FAIL=$((FAIL+1))
else
  echo "  PASS  No Azure SDK in requirements.txt"
  PASS=$((PASS+1))
fi

# ── V7: no Azure SDK ─────────────────────────────────────────────────────────

echo ""
echo "V7. No Azure SDK in requirements.txt"
if grep -qi "azure" backend/requirements.txt 2>/dev/null; then
  echo "  FAIL  Azure SDK found"
  FAIL=$((FAIL+1))
else
  echo "  PASS  No Azure SDK"
  PASS=$((PASS+1))
fi

# ── V8: types file exists and is non-empty ────────────────────────────────────

echo ""
echo "V8. frontend/src/types/factory.ts exists and is non-empty"
if [ -s frontend/src/types/factory.ts ]; then
  echo "  PASS  types/factory.ts exists ($(wc -l < frontend/src/types/factory.ts) lines)"
  PASS=$((PASS+1))
else
  echo "  FAIL  types/factory.ts missing or empty"
  FAIL=$((FAIL+1))
fi

# ── V9: API client exists and is non-empty ────────────────────────────────────

echo ""
echo "V9. frontend/src/api/factoryApi.ts exists and is non-empty"
if [ -s frontend/src/api/factoryApi.ts ]; then
  echo "  PASS  api/factoryApi.ts exists ($(wc -l < frontend/src/api/factoryApi.ts) lines)"
  PASS=$((PASS+1))
else
  echo "  FAIL  api/factoryApi.ts missing or empty"
  FAIL=$((FAIL+1))
fi

# ── V10: FactoryFlowBoard exists ─────────────────────────────────────────────

echo ""
echo "V10. frontend/src/components/FactoryFlowBoard.tsx exists"
if [ -f frontend/src/components/FactoryFlowBoard.tsx ]; then
  echo "  PASS  FactoryFlowBoard.tsx exists ($(wc -l < frontend/src/components/FactoryFlowBoard.tsx) lines)"
  PASS=$((PASS+1))
else
  echo "  FAIL  FactoryFlowBoard.tsx missing"
  FAIL=$((FAIL+1))
fi

# ── V11: D5 verification passes ───────────────────────────────────────────────

echo ""
echo "V11. D5 verification script passes"
if bash scripts/verification/005-backend-state-behavior.sh > /tmp/.006-d5 2>&1; then
  echo "  PASS  005-backend-state-behavior.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  005-backend-state-behavior.sh failed"
  tail -3 /tmp/.006-d5
  FAIL=$((FAIL+1))
fi

# ── V12: smoke passes ─────────────────────────────────────────────────────────

echo ""
echo "V12. Smoke test passes"
if bash scripts/smoke.sh > /tmp/.006-smoke 2>&1; then
  echo "  PASS  smoke.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  smoke.sh failed"
  tail -5 /tmp/.006-smoke
  FAIL=$((FAIL+1))
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
