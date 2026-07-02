#!/usr/bin/env bash
# 004-data-contract-api.sh — Verify D4 read-only data contract API endpoints
# REQUIRES: docker compose up must be running before this script.
# Run from repo root: bash scripts/verification/004-data-contract-api.sh

set -euo pipefail

BACKEND_URL="${BACKEND_URL:-http://localhost:8000}"
PASS=0; FAIL=0

echo "004 — Data Contract API Verification"
echo "════════════════════════════════════════"
echo "  Backend: $BACKEND_URL"
echo "  NOTE: docker compose up must be running."
echo ""

# ── V1: data-contract/status ─────────────────────────────────────────────────

echo "V1. GET /factory/data-contract/status returns ok"
HTTP=$(curl -s -o /tmp/.004-dcs-body -w "%{http_code}" "${BACKEND_URL}/factory/data-contract/status" 2>/dev/null || echo "000")
if [ "$HTTP" = "200" ]; then
  echo "  PASS  /factory/data-contract/status returned 200"
  PASS=$((PASS+1))
else
  echo "  FAIL  /factory/data-contract/status returned $HTTP"
  FAIL=$((FAIL+1))
fi

echo ""
echo "V2. data-contract/status has status ok"
if grep -q '"status":"ok"' /tmp/.004-dcs-body 2>/dev/null || \
   grep -q '"status": "ok"' /tmp/.004-dcs-body 2>/dev/null; then
  echo "  PASS  status: ok"
  PASS=$((PASS+1))
else
  echo "  FAIL  status not ok"
  cat /tmp/.004-dcs-body | sed 's/^/      /' 2>/dev/null || true
  FAIL=$((FAIL+1))
fi

echo ""
echo "V3. stage_count = 14"
STAGE_COUNT=$(python3 -c "import json,sys; d=json.load(open('/tmp/.004-dcs-body')); print(d.get('stage_count','?'))" 2>/dev/null || echo "?")
if [ "$STAGE_COUNT" = "14" ]; then
  echo "  PASS  stage_count = 14"
  PASS=$((PASS+1))
else
  echo "  FAIL  stage_count = $STAGE_COUNT (expected 14)"
  FAIL=$((FAIL+1))
fi

echo ""
echo "V4. unit_count >= 7"
UNIT_COUNT=$(python3 -c "import json,sys; d=json.load(open('/tmp/.004-dcs-body')); print(d.get('unit_count','0'))" 2>/dev/null || echo "0")
if [ "$UNIT_COUNT" -ge 7 ] 2>/dev/null; then
  echo "  PASS  unit_count = $UNIT_COUNT (>= 7)"
  PASS=$((PASS+1))
else
  echo "  FAIL  unit_count = $UNIT_COUNT (expected >= 7)"
  FAIL=$((FAIL+1))
fi

# ── V5: stages endpoint ───────────────────────────────────────────────────────

echo ""
echo "V5. GET /factory/stages returns 200"
HTTP=$(curl -s -o /tmp/.004-stages-body -w "%{http_code}" "${BACKEND_URL}/factory/stages" 2>/dev/null || echo "000")
if [ "$HTTP" = "200" ]; then
  echo "  PASS  /factory/stages returned 200"
  PASS=$((PASS+1))
else
  echo "  FAIL  /factory/stages returned $HTTP"
  FAIL=$((FAIL+1))
fi

echo ""
echo "V6. /factory/stages returns array of 14 stages"
STAGES_COUNT=$(python3 -c "import json; d=json.load(open('/tmp/.004-stages-body')); print(len(d))" 2>/dev/null || echo "0")
if [ "$STAGES_COUNT" = "14" ]; then
  echo "  PASS  14 stages returned"
  PASS=$((PASS+1))
else
  echo "  FAIL  $STAGES_COUNT stages returned (expected 14)"
  FAIL=$((FAIL+1))
fi

# ── V7: units endpoint ────────────────────────────────────────────────────────

echo ""
echo "V7. GET /factory/units returns 200"
HTTP=$(curl -s -o /tmp/.004-units-body -w "%{http_code}" "${BACKEND_URL}/factory/units" 2>/dev/null || echo "000")
if [ "$HTTP" = "200" ]; then
  echo "  PASS  /factory/units returned 200"
  PASS=$((PASS+1))
else
  echo "  FAIL  /factory/units returned $HTTP"
  FAIL=$((FAIL+1))
fi

# ── V8: single unit ───────────────────────────────────────────────────────────

echo ""
echo "V8. GET /factory/units/UNIT-0001 returns 200"
HTTP=$(curl -s -o /tmp/.004-unit-body -w "%{http_code}" "${BACKEND_URL}/factory/units/UNIT-0001" 2>/dev/null || echo "000")
if [ "$HTTP" = "200" ]; then
  echo "  PASS  /factory/units/UNIT-0001 returned 200"
  PASS=$((PASS+1))
else
  echo "  FAIL  /factory/units/UNIT-0001 returned $HTTP"
  FAIL=$((FAIL+1))
fi

# ── V9: missing unit returns 404 ─────────────────────────────────────────────

echo ""
echo "V9. GET /factory/units/DOES-NOT-EXIST returns 404"
HTTP=$(curl -s -o /dev/null -w "%{http_code}" "${BACKEND_URL}/factory/units/DOES-NOT-EXIST" 2>/dev/null || echo "000")
if [ "$HTTP" = "404" ]; then
  echo "  PASS  missing unit returns 404"
  PASS=$((PASS+1))
else
  echo "  FAIL  missing unit returned $HTTP (expected 404)"
  FAIL=$((FAIL+1))
fi

# ── V10: D4 data contract GET endpoints present in OpenAPI ────────────────────

echo ""
echo "V10. OpenAPI schema has all 10 D4 data contract GET routes"
curl -s "${BACKEND_URL}/openapi.json" > /tmp/.004-openapi.json 2>/dev/null || true
D4_ROUTES=$(python3 -c "
import json
with open('/tmp/.004-openapi.json') as f:
    d = json.load(f)
paths = d.get('paths', {})
required = [
    '/factory/data-contract/status',
    '/factory/stages',
    '/factory/units',
    '/factory/orders',
    '/factory/parts',
    '/factory/users',
    '/factory/model-recipes',
    '/factory/reference-standards',
    '/factory/events',
]
found = [p for p in required if p in paths and 'get' in paths[p]]
print(len(found))
" 2>/dev/null || echo "0")
if [ "$D4_ROUTES" = "9" ]; then
  echo "  PASS  all 9 D4 data contract GET base routes present in OpenAPI"
  PASS=$((PASS+1))
else
  echo "  FAIL  only $D4_ROUTES/9 D4 GET routes found in OpenAPI"
  FAIL=$((FAIL+1))
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
