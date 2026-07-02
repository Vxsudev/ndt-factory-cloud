#!/usr/bin/env bash
# 002-backend-health.sh — Verify backend /health endpoint
# REQUIRES: docker compose up must be running before this script.
# Run from repo root: bash scripts/verification/002-backend-health.sh

set -euo pipefail

BACKEND_URL="${BACKEND_URL:-http://localhost:8000}"
PASS=0; FAIL=0

echo "002 — Backend Health Verification"
echo "════════════════════════════════════════"
echo "  Backend: $BACKEND_URL"
echo "  NOTE: docker compose up must be running."
echo ""

echo "V1. GET /health is reachable"
HTTP_CODE=$(curl -s -o /tmp/.002-health-body -w "%{http_code}" "${BACKEND_URL}/health" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
  echo "  PASS  /health returned 200"
  PASS=$((PASS+1))
else
  echo "  FAIL  /health returned $HTTP_CODE (expected 200)"
  FAIL=$((FAIL+1))
fi

echo ""
echo "V2. response body contains status ok"
if grep -q '"status":"ok"' /tmp/.002-health-body 2>/dev/null || \
   grep -q '"status": "ok"' /tmp/.002-health-body 2>/dev/null; then
  echo "  PASS  status: ok"
  PASS=$((PASS+1))
else
  echo "  FAIL  status not ok in response body"
  cat /tmp/.002-health-body | sed 's/^/      /' 2>/dev/null || true
  FAIL=$((FAIL+1))
fi

echo ""
echo "V3. GET /factory/scaffold-status returns 200"
SC_CODE=$(curl -s -o /tmp/.002-scaffold-body -w "%{http_code}" "${BACKEND_URL}/factory/scaffold-status" 2>/dev/null || echo "000")
if [ "$SC_CODE" = "200" ]; then
  echo "  PASS  /factory/scaffold-status returned 200"
  PASS=$((PASS+1))
else
  echo "  FAIL  /factory/scaffold-status returned $SC_CODE"
  FAIL=$((FAIL+1))
fi

echo ""
echo "V4. scaffold-status body contains scaffold_only"
if grep -q '"status":"scaffold_only"' /tmp/.002-scaffold-body 2>/dev/null || \
   grep -q '"status": "scaffold_only"' /tmp/.002-scaffold-body 2>/dev/null; then
  echo "  PASS  status: scaffold_only"
  PASS=$((PASS+1))
else
  echo "  FAIL  status not scaffold_only in response body"
  cat /tmp/.002-scaffold-body | sed 's/^/      /' 2>/dev/null || true
  FAIL=$((FAIL+1))
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
