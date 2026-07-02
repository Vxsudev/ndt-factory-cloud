#!/usr/bin/env bash
# 003-frontend-reachable.sh — Verify frontend is reachable
# REQUIRES: docker compose up must be running before this script.
# Run from repo root: bash scripts/verification/003-frontend-reachable.sh

set -euo pipefail

FRONTEND_URL="${FRONTEND_URL:-http://localhost:5173}"
PASS=0; FAIL=0

echo "003 — Frontend Reachability Verification"
echo "════════════════════════════════════════"
echo "  Frontend: $FRONTEND_URL"
echo "  NOTE: docker compose up must be running."
echo ""

echo "V1. GET / returns 200"
HTTP_CODE=$(curl -s -o /tmp/.003-frontend-body -w "%{http_code}" "${FRONTEND_URL}/" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
  echo "  PASS  frontend returned 200"
  PASS=$((PASS+1))
else
  echo "  FAIL  frontend returned $HTTP_CODE (expected 200)"
  FAIL=$((FAIL+1))
fi

echo ""
echo "V2. response contains HTML"
if grep -qi "<!doctype html>" /tmp/.003-frontend-body 2>/dev/null || \
   grep -qi "<html" /tmp/.003-frontend-body 2>/dev/null; then
  echo "  PASS  response contains HTML"
  PASS=$((PASS+1))
else
  echo "  FAIL  response does not appear to be HTML"
  head -5 /tmp/.003-frontend-body | sed 's/^/      /' 2>/dev/null || true
  FAIL=$((FAIL+1))
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
