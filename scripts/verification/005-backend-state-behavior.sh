#!/usr/bin/env bash
# 005-backend-state-behavior.sh — Verify D5 backend state behavior
# REQUIRES: docker compose up must be running before this script.
# Run from repo root: bash scripts/verification/005-backend-state-behavior.sh

set -euo pipefail

BACKEND_URL="${BACKEND_URL:-http://localhost:8000}"
FRONTEND_URL="${FRONTEND_URL:-http://localhost:5173}"
PASS=0; FAIL=0

_post() {
  local url="$1"; local body="$2"; local out="$3"
  HTTP=$(curl -s -o "$out" -w "%{http_code}" -X POST "$url" \
    -H "Content-Type: application/json" -d "$body" 2>/dev/null || echo "000")
  echo "$HTTP"
}

_get_http() {
  curl -s -o /dev/null -w "%{http_code}" "$1" 2>/dev/null || echo "000"
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

echo "005 — Backend State Behavior Verification"
echo "════════════════════════════════════════"
echo "  Backend: $BACKEND_URL"
echo ""

# ── V1: reset state ───────────────────────────────────────────────────────────

echo "V1. POST /factory/dev/reset-state returns 200"
HTTP=$(_post "${BACKEND_URL}/factory/dev/reset-state" '{}' /tmp/.005-reset)
_check "/factory/dev/reset-state returns 200" "$HTTP" "200"

# ── V2: D4 backward compat ────────────────────────────────────────────────────

echo ""
echo "V2. GET /factory/data-contract/status still returns 200"
HTTP=$(_get_http "${BACKEND_URL}/factory/data-contract/status")
_check "/factory/data-contract/status still works" "$HTTP" "200"

# ── V3: successful assembly scan ──────────────────────────────────────────────

echo ""
echo "V3. Successful assembly scan on UNIT-0001 (POWER_SUPPLY / PS-SN-MOCK-0002)"
# Reset first to ensure clean state
_post "${BACKEND_URL}/factory/dev/reset-state" '{}' /dev/null > /dev/null

HTTP=$(_post "${BACKEND_URL}/factory/units/UNIT-0001/actions/scan-part" \
  '{"part_type":"POWER_SUPPLY","serial_number":"PS-SN-MOCK-0002","actor_user_id":"USER-OP-0001","station_id":"BENCH-A1"}' \
  /tmp/.005-scan-ok)

if [ "$HTTP" = "200" ]; then
  STATUS=$(python3 -c "import json; d=json.load(open('/tmp/.005-scan-ok')); print(d.get('status','?'))" 2>/dev/null || echo "?")
  _check "scan-part returns 200" "$HTTP" "200"
  _check "scan-part status=success" "$STATUS" "success"
else
  echo "  FAIL  scan-part returned $HTTP"
  FAIL=$((FAIL+2))
fi

# ── V4: wrong assembly serial ─────────────────────────────────────────────────

echo ""
echo "V4. Wrong assembly serial returns blocked hard-stop"
HTTP=$(_post "${BACKEND_URL}/factory/units/UNIT-0001/actions/scan-part" \
  '{"part_type":"POWER_SUPPLY","serial_number":"UNKNOWN-SERIAL-9999","actor_user_id":"USER-OP-0001","station_id":"BENCH-A1"}' \
  /tmp/.005-scan-bad)

if [ "$HTTP" = "200" ]; then
  STATUS=$(python3 -c "import json; d=json.load(open('/tmp/.005-scan-bad')); print(d.get('status','?'))" 2>/dev/null || echo "?")
  _check "wrong serial returns 200 with blocked" "$HTTP" "200"
  _check "wrong serial status=blocked" "$STATUS" "blocked"
else
  echo "  FAIL  wrong serial scan returned $HTTP (expected 200+blocked)"
  FAIL=$((FAIL+2))
fi

# ── V5: supervisor reallocation ───────────────────────────────────────────────

echo ""
echo "V5. Supervisor reallocation on UNIT-0001 POWER_SUPPLY succeeds"
# Reset to get clean state
_post "${BACKEND_URL}/factory/dev/reset-state" '{}' /dev/null > /dev/null

HTTP=$(_post "${BACKEND_URL}/factory/units/UNIT-0001/actions/reallocate-part" \
  '{"part_type":"POWER_SUPPLY","old_serial_number":"PS-SN-MOCK-0002","new_serial_number":"PS-SN-REPLACEMENT-0099","reason":"Damaged at bench","release_reason_code":"damaged_at_bench","actor_user_id":"USER-SUP-0001"}' \
  /tmp/.005-realloc)

if [ "$HTTP" = "200" ]; then
  STATUS=$(python3 -c "import json; d=json.load(open('/tmp/.005-realloc')); print(d.get('status','?'))" 2>/dev/null || echo "?")
  _check "reallocation returns 200" "$HTTP" "200"
  _check "reallocation status=success" "$STATUS" "success"
else
  echo "  FAIL  reallocation returned $HTTP"
  cat /tmp/.005-realloc 2>/dev/null | head -2
  FAIL=$((FAIL+2))
fi

# ── V6: cloud backup unavailable on UNIT-0006 ────────────────────────────────

echo ""
echo "V6. Cloud backup unavailable on UNIT-0006 returns blocked with no_override"
# Reset to ensure UNIT-0006 is at STAGE-12
_post "${BACKEND_URL}/factory/dev/reset-state" '{}' /dev/null > /dev/null

HTTP=$(_post "${BACKEND_URL}/factory/units/UNIT-0006/actions/cloud-backup" \
  '{"cloud_available":false,"actor_user_id":"USER-OP-0001","backup_reference":null}' \
  /tmp/.005-backup)

if [ "$HTTP" = "200" ]; then
  STATUS=$(python3 -c "import json; d=json.load(open('/tmp/.005-backup')); print(d.get('status','?'))" 2>/dev/null || echo "?")
  NO_OVR=$(python3 -c "import json; d=json.load(open('/tmp/.005-backup')); print(str(d.get('no_override',False)).lower())" 2>/dev/null || echo "false")
  _check "cloud-backup returns 200" "$HTTP" "200"
  _check "cloud-backup status=blocked" "$STATUS" "blocked"
  _check "cloud-backup no_override=true" "$NO_OVR" "true"
else
  echo "  FAIL  cloud-backup returned $HTTP"
  FAIL=$((FAIL+3))
fi

# ── V7: calibration on UNIT-0003 (attempt 2 of 3 → attempt 3) ───────────────

echo ""
echo "V7. Calibration fail on UNIT-0003 (currently 2/3 attempts) records 3rd fail"
_post "${BACKEND_URL}/factory/dev/reset-state" '{}' /dev/null > /dev/null

HTTP=$(_post "${BACKEND_URL}/factory/units/UNIT-0003/actions/calibration" \
  '{"result":"fail","actor_user_id":"USER-TECH-0001","reference_standard_ids":["REFSTD-0001"],"equipment_id":"CAL-EQUIP-01"}' \
  /tmp/.005-cal3)

if [ "$HTTP" = "200" ]; then
  STATUS=$(python3 -c "import json; d=json.load(open('/tmp/.005-cal3')); print(d.get('status','?'))" 2>/dev/null || echo "?")
  REASON=$(python3 -c "import json; d=json.load(open('/tmp/.005-cal3')); print(d.get('blocked_reason',''))" 2>/dev/null || echo "")
  _check "calibration 3rd fail returns 200" "$HTTP" "200"
  _check "calibration 3rd fail status=blocked" "$STATUS" "blocked"
  # Should now be cap_exceeded
  if echo "$REASON" | grep -q "cap_exceeded"; then
    echo "  PASS  calibration 3rd fail → cap_exceeded raised"
    PASS=$((PASS+1))
  else
    echo "  FAIL  expected cap_exceeded reason, got: $REASON"
    FAIL=$((FAIL+1))
  fi
else
  echo "  FAIL  calibration returned $HTTP"
  FAIL=$((FAIL+3))
fi

# ── V8: calibration on UNIT-0004 (already cap exceeded) ──────────────────────

echo ""
echo "V8. Calibration on UNIT-0004 (cap exceeded) returns disposition required"
HTTP=$(_post "${BACKEND_URL}/factory/units/UNIT-0004/actions/calibration" \
  '{"result":"pass","actor_user_id":"USER-TECH-0001","reference_standard_ids":["REFSTD-0001"],"equipment_id":"CAL-EQUIP-01"}' \
  /tmp/.005-cal4)

if [ "$HTTP" = "200" ]; then
  STATUS=$(python3 -c "import json; d=json.load(open('/tmp/.005-cal4')); print(d.get('status','?'))" 2>/dev/null || echo "?")
  REASON=$(python3 -c "import json; d=json.load(open('/tmp/.005-cal4')); print(d.get('blocked_reason',''))" 2>/dev/null || echo "")
  _check "UNIT-0004 calibration returns 200" "$HTTP" "200"
  _check "UNIT-0004 calibration status=blocked" "$STATUS" "blocked"
  if echo "$REASON" | grep -q "cap_exceeded"; then
    echo "  PASS  UNIT-0004 cap_exceeded disposition reason present"
    PASS=$((PASS+1))
  else
    echo "  FAIL  expected cap_exceeded, got: $REASON"
    FAIL=$((FAIL+1))
  fi
else
  echo "  FAIL  UNIT-0004 calibration returned $HTTP"
  FAIL=$((FAIL+3))
fi

# ── V9: QC sign-off on UNIT-0005 ─────────────────────────────────────────────

echo ""
echo "V9. QC sign-off on UNIT-0005 succeeds with USER-QC-0001"
HTTP=$(_post "${BACKEND_URL}/factory/units/UNIT-0005/actions/qc-signoff" \
  '{"actor_user_id":"USER-QC-0001","checklist":[{"item":"physical_inspection","passed":true},{"item":"calibration_cert","passed":true}]}' \
  /tmp/.005-qc)

if [ "$HTTP" = "200" ]; then
  STATUS=$(python3 -c "import json; d=json.load(open('/tmp/.005-qc')); print(d.get('status','?'))" 2>/dev/null || echo "?")
  STAGE=$(python3 -c "import json; d=json.load(open('/tmp/.005-qc')); print(d.get('current_stage_id','?'))" 2>/dev/null || echo "?")
  _check "QC sign-off returns 200" "$HTTP" "200"
  _check "QC sign-off status=success" "$STATUS" "success"
  _check "QC sign-off advances to STAGE-12" "$STAGE" "STAGE-12"
else
  echo "  FAIL  QC sign-off returned $HTTP"
  cat /tmp/.005-qc 2>/dev/null | head -2
  FAIL=$((FAIL+3))
fi

# ── V10: missing unit → 404 ───────────────────────────────────────────────────

echo ""
echo "V10. Missing unit action returns 404"
HTTP=$(_post "${BACKEND_URL}/factory/units/UNIT-DOES-NOT-EXIST/actions/scan-part" \
  '{"part_type":"POWER_SUPPLY","serial_number":"PS-SN-0001","actor_user_id":"USER-OP-0001"}' \
  /tmp/.005-404)
_check "missing unit returns 404" "$HTTP" "404"

# ── V11: terminal unit transition → 409 ──────────────────────────────────────

echo ""
echo "V11. Terminal unit transition returns 409"
HTTP=$(_post "${BACKEND_URL}/factory/units/UNIT-0007/actions/transition" \
  '{"target_stage_id":"STAGE-14","actor_user_id":"USER-MGR-0001"}' \
  /tmp/.005-409)
_check "terminal unit transition returns 409" "$HTTP" "409"

# ── V12: no Azure SDK ────────────────────────────────────────────────────────
# (D7 adds Postgres; the invariant is "no Azure SDK", not "no Postgres")

echo ""
echo "V12. No Azure SDK in requirements.txt (D7: Postgres is expected)"
if grep -qi "azure" backend/requirements.txt 2>/dev/null; then
  echo "  FAIL  Azure SDK found in requirements.txt"
  FAIL=$((FAIL+1))
else
  echo "  PASS  No Azure SDK in requirements.txt"
  PASS=$((PASS+1))
fi

# ── V13: no Azure SDK ─────────────────────────────────────────────────────────

echo ""
echo "V13. No Azure SDK in requirements.txt"
if grep -qi "azure" backend/requirements.txt 2>/dev/null; then
  echo "  FAIL  Azure SDK found in requirements.txt"
  FAIL=$((FAIL+1))
else
  echo "  PASS  No Azure SDK in requirements.txt"
  PASS=$((PASS+1))
fi

# ── V14: frontend reachable ───────────────────────────────────────────────────

echo ""
echo "V14. Frontend still reachable"
HTTP=$(_get_http "${FRONTEND_URL}")
_check "frontend returns 200" "$HTTP" "200"

# ── V15: smoke passes ─────────────────────────────────────────────────────────

echo ""
echo "V15. Smoke test passes"
if bash scripts/smoke.sh > /tmp/.005-smoke 2>&1; then
  echo "  PASS  smoke.sh passed"
  PASS=$((PASS+1))
else
  echo "  FAIL  smoke.sh failed"
  tail -5 /tmp/.005-smoke
  FAIL=$((FAIL+1))
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
