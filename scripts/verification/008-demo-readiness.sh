#!/usr/bin/env bash
# 008-demo-readiness.sh — Verify D8 Factory Review Hardening / Demo Readiness
# REQUIRES: docker compose up must be running before this script.
# Run from repo root: bash scripts/verification/008-demo-readiness.sh

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

echo "008 — D8 Demo Readiness Verification"
echo "════════════════════════════════════════"
echo "  Backend:  $BACKEND_URL"
echo "  Frontend: $FRONTEND_URL"
echo ""

# ── V1: frontend root loads ───────────────────────────────────────────────────

echo "V1. Frontend root returns 200"
HTTP=$(_get_http "${FRONTEND_URL}")
_check "frontend returns 200" "$HTTP" "200"

# ── V2: D8 demo-readiness meta marker ────────────────────────────────────────

echo ""
echo "V2. index.html contains D8 demo-readiness meta marker"
BODY=$(_get_body "${FRONTEND_URL}")
if echo "$BODY" | grep -q "demo-readiness"; then
  echo "  PASS  D8 demo-readiness marker found"
  PASS=$((PASS+1))
else
  echo "  FAIL  D8 demo-readiness marker not found in index.html"
  FAIL=$((FAIL+1))
fi

# ── V3: title contains Factory Cloud v0 ──────────────────────────────────────

echo ""
echo "V3. index.html contains Factory Cloud"
if echo "$BODY" | grep -q "Factory Cloud"; then
  echo "  PASS  Factory Cloud found in page"
  PASS=$((PASS+1))
else
  echo "  FAIL  Factory Cloud not found in index.html"
  FAIL=$((FAIL+1))
fi

# ── V4: D8 Review Prototype in page ──────────────────────────────────────────

echo ""
echo "V4. index.html contains D8 Review Prototype"
if echo "$BODY" | grep -q "D8"; then
  echo "  PASS  D8 found in page"
  PASS=$((PASS+1))
else
  echo "  FAIL  D8 not found in index.html"
  FAIL=$((FAIL+1))
fi

# ── V5: backend health OK ─────────────────────────────────────────────────────

echo ""
echo "V5. Backend health returns ok"
HEALTH=$(_get_body "${BACKEND_URL}/health")
if echo "$HEALTH" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if d.get('status')=='ok' else 1)" 2>/dev/null; then
  echo "  PASS  Backend health: ok"
  PASS=$((PASS+1))
else
  echo "  FAIL  Backend health not ok (got: $HEALTH)"
  FAIL=$((FAIL+1))
fi

# ── V6: data-contract status OK ──────────────────────────────────────────────

echo ""
echo "V6. Data contract status endpoint responds"
HTTP=$(_get_http "${BACKEND_URL}/factory/data-contract/status")
_check "data-contract/status returns 200" "$HTTP" "200"

# ── V7: stage_count = 14 ─────────────────────────────────────────────────────

echo ""
echo "V7. Data contract reports 14 stages"
DCS=$(_get_body "${BACKEND_URL}/factory/data-contract/status")
STAGE_COUNT=$(echo "$DCS" | python3 -c "import sys,json; print(json.load(sys.stdin).get('stage_count','0'))" 2>/dev/null || echo "0")
_check "stage_count = 14" "$STAGE_COUNT" "14"

# ── V8: unit_count >= 7 ───────────────────────────────────────────────────────

echo ""
echo "V8. Data contract reports >= 7 units"
UNIT_COUNT=$(echo "$DCS" | python3 -c "import sys,json; print(json.load(sys.stdin).get('unit_count','0'))" 2>/dev/null || echo "0")
if [ "$UNIT_COUNT" -ge 7 ] 2>/dev/null; then
  echo "  PASS  unit_count = $UNIT_COUNT (>= 7)"
  PASS=$((PASS+1))
else
  echo "  FAIL  unit_count = $UNIT_COUNT (expected >= 7)"
  FAIL=$((FAIL+1))
fi

# ── V9: D4 verification still passes ─────────────────────────────────────────

echo ""
echo "V9. D4 verification passes"
if bash scripts/verification/004-data-contract-api.sh > /tmp/.008-d4 2>&1; then
  echo "  PASS  004-data-contract-api.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  004-data-contract-api.sh failed"
  tail -3 /tmp/.008-d4
  FAIL=$((FAIL+1))
fi

# ── V10: D5 verification still passes ────────────────────────────────────────

echo ""
echo "V10. D5 verification passes"
if bash scripts/verification/005-backend-state-behavior.sh > /tmp/.008-d5 2>&1; then
  echo "  PASS  005-backend-state-behavior.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  005-backend-state-behavior.sh failed"
  tail -3 /tmp/.008-d5
  FAIL=$((FAIL+1))
fi

# ── V11: D6 verification still passes ────────────────────────────────────────

echo ""
echo "V11. D6 verification passes"
if bash scripts/verification/006-factory-flow-board-ui.sh > /tmp/.008-d6 2>&1; then
  echo "  PASS  006-factory-flow-board-ui.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  006-factory-flow-board-ui.sh failed"
  tail -3 /tmp/.008-d6
  FAIL=$((FAIL+1))
fi

# ── V12: D7 verification still passes ────────────────────────────────────────

echo ""
echo "V12. D7 verification passes"
if bash scripts/verification/007-persistence-postgres.sh > /tmp/.008-d7 2>&1; then
  echo "  PASS  007-persistence-postgres.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  007-persistence-postgres.sh failed"
  tail -3 /tmp/.008-d7
  FAIL=$((FAIL+1))
fi

# ── V13: reset-state works ────────────────────────────────────────────────────

echo ""
echo "V13. Reset state returns 200"
HTTP=$(_post_http "${BACKEND_URL}/factory/dev/reset-state" '{}')
_check "reset-state returns 200" "$HTTP" "200"

# ── V14: Postgres service is running ─────────────────────────────────────────

echo ""
echo "V14. Postgres container is running"
if docker compose ps postgres 2>/dev/null | grep -q "Up\|running"; then
  echo "  PASS  Postgres container is up"
  PASS=$((PASS+1))
else
  echo "  FAIL  Postgres container not running"
  FAIL=$((FAIL+1))
fi

# ── V15: no Azure SDK ─────────────────────────────────────────────────────────

echo ""
echo "V15. No Azure SDK in requirements.txt"
if grep -qi "azure" backend/requirements.txt 2>/dev/null; then
  echo "  FAIL  Azure SDK found in requirements.txt"
  FAIL=$((FAIL+1))
else
  echo "  PASS  No Azure SDK"
  PASS=$((PASS+1))
fi

# ── V16: no auth/session in backend ──────────────────────────────────────────

echo ""
echo "V16. No auth/session implementation in backend"
if grep -rq "import jwt\|from jose\|from authlib\|OAuth2\|session\[" backend/app/ 2>/dev/null; then
  echo "  FAIL  Auth/session code found in backend/app/"
  FAIL=$((FAIL+1))
else
  echo "  PASS  No auth/session implementation"
  PASS=$((PASS+1))
fi

# ── V17: smoke passes ────────────────────────────────────────────────────────

echo ""
echo "V17. Smoke test passes"
if bash scripts/smoke.sh > /tmp/.008-smoke 2>&1; then
  echo "  PASS  smoke.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  smoke.sh failed"
  tail -5 /tmp/.008-smoke
  FAIL=$((FAIL+1))
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
