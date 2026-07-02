#!/usr/bin/env bash
# 010-material-theme-readability.sh — Verify D8B Material Design Theme System
# REQUIRES: docker compose up must be running before this script.
# Run from repo root: bash scripts/verification/010-material-theme-readability.sh

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

echo "010 — D8B Material Design Theme Readability Verification"
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

# ── V3: page contains Review Prototype ───────────────────────────────────────

echo ""
echo "V3. index.html contains Review Prototype"
if echo "$BODY" | grep -q "Review Prototype"; then
  echo "  PASS  Review Prototype found in page"
  PASS=$((PASS+1))
else
  echo "  FAIL  Review Prototype not found in index.html"
  FAIL=$((FAIL+1))
fi

# ── V4: D8B material-theme-toggle meta tag present ───────────────────────────

echo ""
echo "V4. index.html contains material-theme-toggle meta tag"
if echo "$BODY" | grep -q "material-theme-toggle"; then
  echo "  PASS  material-theme-toggle meta tag found"
  PASS=$((PASS+1))
else
  echo "  FAIL  material-theme-toggle meta tag not found in index.html"
  FAIL=$((FAIL+1))
fi

# ── V5: D8B marker present ────────────────────────────────────────────────────

echo ""
echo "V5. index.html contains d8b marker"
if echo "$BODY" | grep -q "d8b\|app-d8b"; then
  echo "  PASS  d8b marker found in page"
  PASS=$((PASS+1))
else
  echo "  FAIL  d8b marker not found in index.html"
  FAIL=$((FAIL+1))
fi

# ── V6: FactoryFlowBoard uses data-theme attribute ────────────────────────────

echo ""
echo "V6. FactoryFlowBoard.tsx uses data-theme attribute"
BOARD_SRC="frontend/src/components/FactoryFlowBoard.tsx"
if [ -f "$BOARD_SRC" ] && grep -q 'data-theme\|setAttribute.*data-theme' "$BOARD_SRC" 2>/dev/null; then
  echo "  PASS  data-theme usage found in FactoryFlowBoard.tsx"
  PASS=$((PASS+1))
else
  echo "  FAIL  data-theme not found in FactoryFlowBoard.tsx"
  FAIL=$((FAIL+1))
fi

# ── V7: styles.css contains --mds- token variables ───────────────────────────

echo ""
echo "V7. styles.css contains --mds- Material Design token variables"
STYLES_SRC="frontend/src/styles.css"
if [ -f "$STYLES_SRC" ] && grep -q '\-\-mds-' "$STYLES_SRC" 2>/dev/null; then
  echo "  PASS  --mds- token variables found in styles.css"
  PASS=$((PASS+1))
else
  echo "  FAIL  --mds- tokens not found in styles.css"
  FAIL=$((FAIL+1))
fi

# ── V8: FactoryFlowBoard has Light/Dark toggle labels ────────────────────────

echo ""
echo "V8. FactoryFlowBoard.tsx contains Light/Dark toggle labels"
if [ -f "$BOARD_SRC" ] && grep -q "'Light'\|\"Light\"" "$BOARD_SRC" 2>/dev/null; then
  echo "  PASS  Toggle label 'Light' found in FactoryFlowBoard.tsx"
  PASS=$((PASS+1))
else
  echo "  FAIL  Toggle labels not found in FactoryFlowBoard.tsx"
  FAIL=$((FAIL+1))
fi

# ── V9: backend health OK ─────────────────────────────────────────────────────

echo ""
echo "V9. Backend health returns ok"
HEALTH=$(_get_body "${BACKEND_URL}/health")
if echo "$HEALTH" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if d.get('status')=='ok' else 1)" 2>/dev/null; then
  echo "  PASS  Backend health: ok"
  PASS=$((PASS+1))
else
  echo "  FAIL  Backend health not ok (got: $HEALTH)"
  FAIL=$((FAIL+1))
fi

# ── V10: data-contract status OK ─────────────────────────────────────────────

echo ""
echo "V10. Data contract status endpoint responds"
HTTP=$(_get_http "${BACKEND_URL}/factory/data-contract/status")
_check "data-contract/status returns 200" "$HTTP" "200"

# ── V11: stage_count = 14 ────────────────────────────────────────────────────

echo ""
echo "V11. Data contract reports 14 stages"
DCS=$(_get_body "${BACKEND_URL}/factory/data-contract/status")
STAGE_COUNT=$(echo "$DCS" | python3 -c "import sys,json; print(json.load(sys.stdin).get('stage_count','0'))" 2>/dev/null || echo "0")
_check "stage_count = 14" "$STAGE_COUNT" "14"

# ── V12: unit_count >= 7 ─────────────────────────────────────────────────────

echo ""
echo "V12. Data contract reports >= 7 units"
UNIT_COUNT=$(echo "$DCS" | python3 -c "import sys,json; print(json.load(sys.stdin).get('unit_count','0'))" 2>/dev/null || echo "0")
if [ "$UNIT_COUNT" -ge 7 ] 2>/dev/null; then
  echo "  PASS  unit_count = $UNIT_COUNT (>= 7)"
  PASS=$((PASS+1))
else
  echo "  FAIL  unit_count = $UNIT_COUNT (expected >= 7)"
  FAIL=$((FAIL+1))
fi

# ── V13: D4 verification still passes ────────────────────────────────────────

echo ""
echo "V13. D4 verification passes"
if bash scripts/verification/004-data-contract-api.sh > /tmp/.010-d4 2>&1; then
  echo "  PASS  004-data-contract-api.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  004-data-contract-api.sh failed"
  tail -3 /tmp/.010-d4
  FAIL=$((FAIL+1))
fi

# ── V14: D5 verification still passes ────────────────────────────────────────

echo ""
echo "V14. D5 verification passes"
if bash scripts/verification/005-backend-state-behavior.sh > /tmp/.010-d5 2>&1; then
  echo "  PASS  005-backend-state-behavior.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  005-backend-state-behavior.sh failed"
  tail -3 /tmp/.010-d5
  FAIL=$((FAIL+1))
fi

# ── V15: D6 verification still passes ────────────────────────────────────────

echo ""
echo "V15. D6 verification passes"
if bash scripts/verification/006-factory-flow-board-ui.sh > /tmp/.010-d6 2>&1; then
  echo "  PASS  006-factory-flow-board-ui.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  006-factory-flow-board-ui.sh failed"
  tail -3 /tmp/.010-d6
  FAIL=$((FAIL+1))
fi

# ── V16: D7 verification still passes ────────────────────────────────────────

echo ""
echo "V16. D7 verification passes"
if bash scripts/verification/007-persistence-postgres.sh > /tmp/.010-d7 2>&1; then
  echo "  PASS  007-persistence-postgres.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  007-persistence-postgres.sh failed"
  tail -3 /tmp/.010-d7
  FAIL=$((FAIL+1))
fi

# ── V17: D8 verification still passes ────────────────────────────────────────

echo ""
echo "V17. D8 verification passes"
if bash scripts/verification/008-demo-readiness.sh > /tmp/.010-d8 2>&1; then
  echo "  PASS  008-demo-readiness.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  008-demo-readiness.sh failed"
  tail -3 /tmp/.010-d8
  FAIL=$((FAIL+1))
fi

# ── V18: D8A verification still passes ───────────────────────────────────────

echo ""
echo "V18. D8A verification passes (meta markers retained)"
if bash scripts/verification/009-light-mode-readability.sh > /tmp/.010-d8a 2>&1; then
  echo "  PASS  009-light-mode-readability.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  009-light-mode-readability.sh failed"
  tail -5 /tmp/.010-d8a
  FAIL=$((FAIL+1))
fi

# ── V19: smoke passes ────────────────────────────────────────────────────────

echo ""
echo "V19. Smoke test passes"
if bash scripts/smoke.sh > /tmp/.010-smoke 2>&1; then
  echo "  PASS  smoke.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  smoke.sh failed"
  tail -5 /tmp/.010-smoke
  FAIL=$((FAIL+1))
fi

# ── V20: no Azure SDK ────────────────────────────────────────────────────────

echo ""
echo "V20. No Azure SDK in backend"
if grep -qi "azure" backend/requirements.txt 2>/dev/null; then
  echo "  FAIL  Azure SDK found in requirements.txt"
  FAIL=$((FAIL+1))
else
  echo "  PASS  No Azure SDK"
  PASS=$((PASS+1))
fi

# ── V21: no auth/session in backend ──────────────────────────────────────────

echo ""
echo "V21. No auth/session implementation in backend"
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
