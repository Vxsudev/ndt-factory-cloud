#!/usr/bin/env bash
# 007-persistence-postgres.sh — Verify D7 Postgres persistence
# REQUIRES: docker compose up must be running before this script.
# Run from repo root: bash scripts/verification/007-persistence-postgres.sh

set -euo pipefail

BACKEND_URL="${BACKEND_URL:-http://localhost:8000}"
PASS=0; FAIL=0

echo "007 — Persistence / Postgres Verification"
echo "════════════════════════════════════════"
echo "  Backend: $BACKEND_URL"
echo "  NOTE: docker compose up must be running."
echo ""

_check() {
  local label="$1" actual="$2" expected="$3"
  if [ "$actual" = "$expected" ]; then
    echo "  PASS  $label"
    PASS=$((PASS+1))
  else
    echo "  FAIL  $label (got $actual, expected $expected)"
    FAIL=$((FAIL+1))
  fi
}

_get_http() {
  curl -s -o /dev/null -w "%{http_code}" "$1" 2>/dev/null || echo "000"
}

# ── V1: Postgres container running ───────────────────────────────────────────

echo "V1. Postgres container is running"
if docker compose ps postgres 2>/dev/null | grep -q "Up"; then
  echo "  PASS  postgres container running"
  PASS=$((PASS+1))
else
  echo "  FAIL  postgres container not running"
  FAIL=$((FAIL+1))
fi

# ── V2: Backend health (Postgres startup survived) ────────────────────────────

echo ""
echo "V2. Backend health OK (survived Postgres startup)"
HTTP=$(_get_http "${BACKEND_URL}/health")
_check "/health returns 200" "$HTTP" "200"

# ── V3: Alembic migration ran (tables exist in Postgres) ─────────────────────

echo ""
echo "V3. Alembic migration ran (factory_units table exists)"
TBL_EXISTS=$(docker compose exec -T postgres psql -U factory_cloud -d factory_cloud -tAc "SELECT to_regclass('public.factory_units');" 2>/dev/null | tr -d ' \n' || echo "nil")
if [ "$TBL_EXISTS" = "factory_units" ]; then
  echo "  PASS  factory_units table exists"
  PASS=$((PASS+1))
else
  echo "  FAIL  factory_units table not found (got: $TBL_EXISTS)"
  FAIL=$((FAIL+1))
fi

# ── V4: Seed data loaded — units in DB ───────────────────────────────────────

echo ""
echo "V4. Seed data loaded — 7 units in DB"
UNIT_COUNT=$(docker compose exec -T postgres psql -U factory_cloud -d factory_cloud -tAc "SELECT COUNT(*) FROM factory_units;" 2>/dev/null | tr -d ' \n' || echo "0")
if [ "$UNIT_COUNT" -ge 7 ] 2>/dev/null; then
  echo "  PASS  $UNIT_COUNT units in DB (>= 7)"
  PASS=$((PASS+1))
else
  echo "  FAIL  $UNIT_COUNT units in DB (expected >= 7)"
  FAIL=$((FAIL+1))
fi

# ── V5: Seed data loaded — 14 stages in DB ───────────────────────────────────

echo ""
echo "V5. Seed data loaded — 14 stages in DB"
STG_COUNT=$(docker compose exec -T postgres psql -U factory_cloud -d factory_cloud -tAc "SELECT COUNT(*) FROM stages;" 2>/dev/null | tr -d ' \n' || echo "0")
_check "14 stages seeded" "$STG_COUNT" "14"

# ── V6: GET /factory/units returns data from DB ───────────────────────────────

echo ""
echo "V6. GET /factory/units returns >= 7 units from DB"
curl -s -o /tmp/.007-units.json "${BACKEND_URL}/factory/units" 2>/dev/null || true
UNITS_COUNT=$(python3 -c "import json; d=json.load(open('/tmp/.007-units.json')); print(len(d))" 2>/dev/null || echo "0")
if [ "$UNITS_COUNT" -ge 7 ] 2>/dev/null; then
  echo "  PASS  $UNITS_COUNT units returned (>= 7)"
  PASS=$((PASS+1))
else
  echo "  FAIL  $UNITS_COUNT units returned (expected >= 7)"
  FAIL=$((FAIL+1))
fi

# ── V7: GET /factory/events returns seed events ───────────────────────────────

echo ""
echo "V7. GET /factory/events returns events from DB"
EVENT_COUNT=$(curl -s "${BACKEND_URL}/factory/events" 2>/dev/null | python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
if [ "$EVENT_COUNT" -ge 5 ] 2>/dev/null; then
  echo "  PASS  $EVENT_COUNT events returned (>= 5)"
  PASS=$((PASS+1))
else
  echo "  FAIL  $EVENT_COUNT events returned (expected >= 5)"
  FAIL=$((FAIL+1))
fi

# ── V8: POST reset-state truncates and reseeds ────────────────────────────────

echo ""
echo "V8. POST /factory/dev/reset-state reseeds DB"
# Make a state mutation first
curl -s -X POST "${BACKEND_URL}/factory/units/UNIT-0001/actions/scan-part" \
  -H "Content-Type: application/json" \
  -d '{"part_type":"sensor_module","serial_number":"BAD","actor_user_id":"USER-OP-0001"}' \
  > /dev/null 2>&1 || true

PRE_EVENTS=$(curl -s "${BACKEND_URL}/factory/events" 2>/dev/null | python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

# Reset
RESET_HTTP=$(curl -s -o /tmp/.007-reset.json -w "%{http_code}" -X POST "${BACKEND_URL}/factory/dev/reset-state" 2>/dev/null || echo "000")
_check "reset-state returns 200" "$RESET_HTTP" "200"

POST_EVENTS=$(curl -s "${BACKEND_URL}/factory/events" 2>/dev/null | python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
# After reset, events should be <= pre-events (mutation event removed)
if [ "$POST_EVENTS" -le "$PRE_EVENTS" ] && [ "$POST_EVENTS" -ge 5 ] 2>/dev/null; then
  echo "  PASS  events after reset ($POST_EVENTS) <= before reset ($PRE_EVENTS)"
  PASS=$((PASS+1))
else
  echo "  FAIL  events after reset ($POST_EVENTS), before ($PRE_EVENTS)"
  FAIL=$((FAIL+1))
fi

# ── V9: D5 workflow action persists to DB ─────────────────────────────────────

echo ""
echo "V9. D5 action (scan-part blocked) event persists to DB"
# Reset first for clean state
curl -s -X POST "${BACKEND_URL}/factory/dev/reset-state" > /dev/null 2>&1 || true

# UNIT-0001 is at STAGE-05 — scan with bad serial to trigger a rejected event
PRE_EVENTS=$(curl -s "${BACKEND_URL}/factory/events" 2>/dev/null | \
  python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

SCAN_HTTP=$(curl -s -o /tmp/.007-scan.json -w "%{http_code}" \
  -X POST "${BACKEND_URL}/factory/units/UNIT-0001/actions/scan-part" \
  -H "Content-Type: application/json" \
  -d '{"part_type":"sensor_module","serial_number":"PERSIST-TEST-SN","actor_user_id":"USER-OP-0001"}' \
  2>/dev/null || echo "000")
_check "scan-part returns 200" "$SCAN_HTTP" "200"

# Event should have been persisted — count should increase
POST_EVENTS=$(curl -s "${BACKEND_URL}/factory/events" 2>/dev/null | \
  python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
if [ "$POST_EVENTS" -gt "$PRE_EVENTS" ] 2>/dev/null; then
  echo "  PASS  new event persisted to DB ($PRE_EVENTS → $POST_EVENTS)"
  PASS=$((PASS+1))
else
  echo "  FAIL  no new event persisted ($PRE_EVENTS → $POST_EVENTS)"
  FAIL=$((FAIL+1))
fi

# ── V10: Terminal state immutability still enforced ───────────────────────────

echo ""
echo "V10. Terminal unit returns 409 (DB-backed immutability)"
TERM_HTTP=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "${BACKEND_URL}/factory/units/UNIT-0007/actions/transition" \
  -H "Content-Type: application/json" \
  -d '{"target_stage_id":"STAGE-02","actor_user_id":"USER-OP-0001"}' 2>/dev/null || echo "000")
_check "terminal unit returns 409" "$TERM_HTTP" "409"

# ── V11: D4 verification still passes ────────────────────────────────────────

echo ""
echo "V11. D4 data contract verification passes"
if bash scripts/verification/004-data-contract-api.sh > /tmp/.007-d4.out 2>&1; then
  echo "  PASS  D4 verification passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  D4 verification failed"
  tail -3 /tmp/.007-d4.out | sed 's/^/      /' 2>/dev/null || true
  FAIL=$((FAIL+1))
fi

# ── V12: D5 verification still passes ────────────────────────────────────────

echo ""
echo "V12. D5 backend state behavior verification passes"
if bash scripts/verification/005-backend-state-behavior.sh > /tmp/.007-d5.out 2>&1; then
  echo "  PASS  D5 verification passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  D5 verification failed"
  tail -3 /tmp/.007-d5.out | sed 's/^/      /' 2>/dev/null || true
  FAIL=$((FAIL+1))
fi

# ── V13: No Azure SDK ─────────────────────────────────────────────────────────

echo ""
echo "V13. No Azure SDK in requirements.txt"
if grep -qi "azure" backend/requirements.txt 2>/dev/null; then
  echo "  FAIL  Azure SDK found"
  FAIL=$((FAIL+1))
else
  echo "  PASS  No Azure SDK"
  PASS=$((PASS+1))
fi

# ── V14: No in-memory state dict in state_store.py ───────────────────────────

echo ""
echo "V14. state_store.py uses DB (no module-level _state dict)"
if grep -q "^_state:" backend/app/state_store.py 2>/dev/null || \
   grep -q "^_state = " backend/app/state_store.py 2>/dev/null; then
  echo "  FAIL  in-memory _state dict found in state_store.py"
  FAIL=$((FAIL+1))
else
  echo "  PASS  No module-level _state dict"
  PASS=$((PASS+1))
fi

# ── V15: Smoke test ───────────────────────────────────────────────────────────

echo ""
echo "V15. Smoke test passes"
if bash scripts/smoke.sh > /dev/null 2>&1; then
  echo "  PASS  smoke.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  smoke.sh failed"
  FAIL=$((FAIL+1))
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
