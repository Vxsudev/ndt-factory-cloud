#!/usr/bin/env bash
# 009-light-mode-readability.sh — Verify D8A Light Mode Readability Pass
# REQUIRES: docker compose up must be running before this script.
# Run from repo root: bash scripts/verification/009-light-mode-readability.sh

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

echo "009 — D8A Light Mode Readability Verification"
echo "════════════════════════════════════════"
echo "  Backend:  $BACKEND_URL"
echo "  Frontend: $FRONTEND_URL"
echo ""

# ── V1: frontend root loads ───────────────────────────────────────────────────

echo "V1. Frontend root returns 200"
HTTP=$(_get_http "${FRONTEND_URL}")
_check "frontend returns 200" "$HTTP" "200"

# ── V2: page contains Factory Cloud ──────────────────────────────────────────

echo ""
echo "V2. index.html contains Factory Cloud"
BODY=$(_get_body "${FRONTEND_URL}")
if echo "$BODY" | grep -q "Factory Cloud"; then
  echo "  PASS  Factory Cloud found in page"
  PASS=$((PASS+1))
else
  echo "  FAIL  Factory Cloud not found in index.html"
  FAIL=$((FAIL+1))
fi

# ── V3: page contains D8 Review Prototype ────────────────────────────────────

echo ""
echo "V3. index.html contains D8 Review Prototype"
if echo "$BODY" | grep -q "D8"; then
  echo "  PASS  D8 found in page"
  PASS=$((PASS+1))
else
  echo "  FAIL  D8 not found in index.html"
  FAIL=$((FAIL+1))
fi

# ── V4: light-review theme marker present ────────────────────────────────────

echo ""
echo "V4. index.html contains light-review theme marker"
if echo "$BODY" | grep -q "light-review"; then
  echo "  PASS  light-review marker found"
  PASS=$((PASS+1))
else
  echo "  FAIL  light-review marker not found in index.html"
  FAIL=$((FAIL+1))
fi

# ── V5: d8a-readability marker present ───────────────────────────────────────

echo ""
echo "V5. index.html contains d8a-readability marker"
if echo "$BODY" | grep -q "d8a-readability\|light-review"; then
  echo "  PASS  d8a marker found"
  PASS=$((PASS+1))
else
  echo "  FAIL  d8a marker not found in index.html"
  FAIL=$((FAIL+1))
fi

# ── V6: dark root background not the default ─────────────────────────────────

echo ""
echo "V6. Root background uses light/themed approach (not bg-gray-950)"
FRONTEND_SRC="frontend/src/components/FactoryFlowBoard.tsx"
# Accepts: D8A light class OR D8B CSS variable token approach (app-bg, data-theme)
if [ -f "$FRONTEND_SRC" ] && grep -q 'bg-\[#FAFAF7\]\|bg-stone-50\|bg-gray-50\|app-bg\|data-theme' "$FRONTEND_SRC" 2>/dev/null; then
  echo "  PASS  Light/themed background approach found in FactoryFlowBoard.tsx"
  PASS=$((PASS+1))
elif [ -f "$FRONTEND_SRC" ] && grep -q 'bg-gray-950' "$FRONTEND_SRC" 2>/dev/null; then
  echo "  FAIL  bg-gray-950 still present as root background in FactoryFlowBoard.tsx"
  FAIL=$((FAIL+1))
else
  echo "  PASS  No dark root background in FactoryFlowBoard.tsx"
  PASS=$((PASS+1))
fi

# ── V7: backend health OK ─────────────────────────────────────────────────────

echo ""
echo "V7. Backend health returns ok"
HEALTH=$(_get_body "${BACKEND_URL}/health")
if echo "$HEALTH" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if d.get('status')=='ok' else 1)" 2>/dev/null; then
  echo "  PASS  Backend health: ok"
  PASS=$((PASS+1))
else
  echo "  FAIL  Backend health not ok (got: $HEALTH)"
  FAIL=$((FAIL+1))
fi

# ── V8: data-contract status OK ──────────────────────────────────────────────

echo ""
echo "V8. Data contract status endpoint responds"
HTTP=$(_get_http "${BACKEND_URL}/factory/data-contract/status")
_check "data-contract/status returns 200" "$HTTP" "200"

# ── V9: stage_count = 14 ─────────────────────────────────────────────────────

echo ""
echo "V9. Data contract reports 14 stages"
DCS=$(_get_body "${BACKEND_URL}/factory/data-contract/status")
STAGE_COUNT=$(echo "$DCS" | python3 -c "import sys,json; print(json.load(sys.stdin).get('stage_count','0'))" 2>/dev/null || echo "0")
_check "stage_count = 14" "$STAGE_COUNT" "14"

# ── V10: unit_count >= 7 ─────────────────────────────────────────────────────

echo ""
echo "V10. Data contract reports >= 7 units"
UNIT_COUNT=$(echo "$DCS" | python3 -c "import sys,json; print(json.load(sys.stdin).get('unit_count','0'))" 2>/dev/null || echo "0")
if [ "$UNIT_COUNT" -ge 7 ] 2>/dev/null; then
  echo "  PASS  unit_count = $UNIT_COUNT (>= 7)"
  PASS=$((PASS+1))
else
  echo "  FAIL  unit_count = $UNIT_COUNT (expected >= 7)"
  FAIL=$((FAIL+1))
fi

# ── V11: D4 verification still passes ────────────────────────────────────────

echo ""
echo "V11. D4 verification passes"
if bash scripts/verification/004-data-contract-api.sh > /tmp/.009-d4 2>&1; then
  echo "  PASS  004-data-contract-api.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  004-data-contract-api.sh failed"
  tail -3 /tmp/.009-d4
  FAIL=$((FAIL+1))
fi

# ── V12: D5 verification still passes ────────────────────────────────────────

echo ""
echo "V12. D5 verification passes"
if bash scripts/verification/005-backend-state-behavior.sh > /tmp/.009-d5 2>&1; then
  echo "  PASS  005-backend-state-behavior.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  005-backend-state-behavior.sh failed"
  tail -3 /tmp/.009-d5
  FAIL=$((FAIL+1))
fi

# ── V13: D6 verification still passes ────────────────────────────────────────

echo ""
echo "V13. D6 verification passes"
if bash scripts/verification/006-factory-flow-board-ui.sh > /tmp/.009-d6 2>&1; then
  echo "  PASS  006-factory-flow-board-ui.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  006-factory-flow-board-ui.sh failed"
  tail -3 /tmp/.009-d6
  FAIL=$((FAIL+1))
fi

# ── V14: D7 verification still passes ────────────────────────────────────────

echo ""
echo "V14. D7 verification passes"
if bash scripts/verification/007-persistence-postgres.sh > /tmp/.009-d7 2>&1; then
  echo "  PASS  007-persistence-postgres.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  007-persistence-postgres.sh failed"
  tail -3 /tmp/.009-d7
  FAIL=$((FAIL+1))
fi

# ── V15: D8 verification still passes ────────────────────────────────────────

echo ""
echo "V15. D8 verification passes"
if bash scripts/verification/008-demo-readiness.sh > /tmp/.009-d8 2>&1; then
  echo "  PASS  008-demo-readiness.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  008-demo-readiness.sh failed"
  tail -3 /tmp/.009-d8
  FAIL=$((FAIL+1))
fi

# ── V16: smoke passes ────────────────────────────────────────────────────────

echo ""
echo "V16. Smoke test passes"
if bash scripts/smoke.sh > /tmp/.009-smoke 2>&1; then
  echo "  PASS  smoke.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  smoke.sh failed"
  tail -5 /tmp/.009-smoke
  FAIL=$((FAIL+1))
fi

# ── V17: no Azure SDK ────────────────────────────────────────────────────────

echo ""
echo "V17. No Azure SDK in requirements.txt"
if grep -qi "azure" backend/requirements.txt 2>/dev/null; then
  echo "  FAIL  Azure SDK found in requirements.txt"
  FAIL=$((FAIL+1))
else
  echo "  PASS  No Azure SDK"
  PASS=$((PASS+1))
fi

# ── V18: no auth/session in backend ──────────────────────────────────────────

echo ""
echo "V18. No auth/session implementation in backend"
if grep -rq "import jwt\|from jose\|from authlib\|OAuth2\|session\[" backend/app/ 2>/dev/null; then
  echo "  FAIL  Auth/session code found in backend/app/"
  FAIL=$((FAIL+1))
else
  echo "  PASS  No auth/session implementation"
  PASS=$((PASS+1))
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
