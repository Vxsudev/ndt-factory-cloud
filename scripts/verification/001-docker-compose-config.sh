#!/usr/bin/env bash
# 001-docker-compose-config.sh — Verify docker-compose.yml is valid
# Does not require running services.
# Run from repo root: bash scripts/verification/001-docker-compose-config.sh

set -euo pipefail

PASS=0; FAIL=0

echo "001 — Docker Compose Config Verification"
echo "════════════════════════════════════════"

echo ""
echo "V1. docker-compose.yml exists"
if [ -f docker-compose.yml ]; then
  echo "  PASS  docker-compose.yml found"
  PASS=$((PASS+1))
else
  echo "  FAIL  docker-compose.yml not found"
  FAIL=$((FAIL+1))
fi

echo ""
echo "V2. docker compose config exits 0"
if docker compose config > /dev/null 2>&1; then
  echo "  PASS  docker compose config is valid"
  PASS=$((PASS+1))
else
  echo "  FAIL  docker compose config returned non-zero"
  docker compose config 2>&1 | head -20 | sed 's/^/      /'
  FAIL=$((FAIL+1))
fi

echo ""
echo "V3. backend service declared"
if docker compose config | grep -q "backend:"; then
  echo "  PASS  backend service found"
  PASS=$((PASS+1))
else
  echo "  FAIL  backend service not found in compose config"
  FAIL=$((FAIL+1))
fi

echo ""
echo "V4. frontend service declared"
if docker compose config | grep -q "frontend:"; then
  echo "  PASS  frontend service found"
  PASS=$((PASS+1))
else
  echo "  FAIL  frontend service not found in compose config"
  FAIL=$((FAIL+1))
fi

echo ""
echo "════════════════════════════════════════"
echo "Result: $PASS PASS / $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
