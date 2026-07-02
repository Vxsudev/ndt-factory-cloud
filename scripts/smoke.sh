#!/usr/bin/env bash
# ndt-factory-cloud | scripts/smoke.sh
# D4 Mock Data Contract Smoke Verification
#
# Verifies that the Engineering OS is installed, the adapter overlay is wired,
# the D3 application scaffold is present, and D4 data files and verification
# script are in place.
# Run after any agent session to confirm repo integrity.

set -euo pipefail

PASS=0
FAIL=0

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

check() {
  local desc="$1"
  local path="$2"
  if [ -e "$path" ]; then
    echo "  PASS  $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $desc"
    echo "        missing: $path"
    FAIL=$((FAIL + 1))
  fi
}

check_exec() {
  local desc="$1"
  local path="$2"
  if [ -f "$path" ] && [ -x "$path" ]; then
    echo "  PASS  $desc"
    PASS=$((PASS + 1))
  elif [ -f "$path" ]; then
    echo "  FAIL  $desc (exists but not executable)"
    FAIL=$((FAIL + 1))
  else
    echo "  FAIL  $desc"
    echo "        missing: $path"
    FAIL=$((FAIL + 1))
  fi
}

echo ""
echo "================================================================"
echo "  ndt-factory-cloud | smoke.sh"
echo "  D3 Stack Scaffold Smoke Verification"
echo "================================================================"
echo ""

echo "  [Root wrappers]"
check "CLAUDE.md" "$REPO_ROOT/CLAUDE.md"
check "ENGINEERING_OS.md" "$REPO_ROOT/ENGINEERING_OS.md"
check "PROJECT_BOOTSTRAP.md" "$REPO_ROOT/PROJECT_BOOTSTRAP.md"

echo ""
echo "  [Vendored OS core]"
check "vendor/engineering-os/" "$REPO_ROOT/vendor/engineering-os"
check "vendor/engineering-os/core-docs/" "$REPO_ROOT/vendor/engineering-os/core-docs"
check "vendor/engineering-os/scripts/" "$REPO_ROOT/vendor/engineering-os/scripts"
check "vendor/engineering-os/templates/" "$REPO_ROOT/vendor/engineering-os/templates"
check "vendor/engineering-os/tests/" "$REPO_ROOT/vendor/engineering-os/tests"

echo ""
echo "  [Adapter overlay]"
check ".engineering-os/adapter.config.sh" "$REPO_ROOT/.engineering-os/adapter.config.sh"
check ".engineering-os/invariants/" "$REPO_ROOT/.engineering-os/invariants"
INV_COUNT=$(ls "$REPO_ROOT/.engineering-os/invariants/"INV-*.sh 2>/dev/null | wc -l | tr -d ' ')
echo "  INFO  $INV_COUNT invariant rules found (expect 6)"
if [ "$INV_COUNT" -eq 6 ]; then
  echo "  PASS  invariant count = 6"
  PASS=$((PASS+1))
else
  echo "  FAIL  expected 6 invariants, found $INV_COUNT"
  FAIL=$((FAIL+1))
fi

echo ""
echo "  [State registry]"
check "ai/state_registry.json" "$REPO_ROOT/ai/state_registry.json"

echo ""
echo "  [Script proxies (executable)]"
check_exec "scripts/compile-spec.sh" "$REPO_ROOT/scripts/compile-spec.sh"
check_exec "scripts/generate-tasks.sh" "$REPO_ROOT/scripts/generate-tasks.sh"
check_exec "scripts/execution-supervisor.sh" "$REPO_ROOT/scripts/execution-supervisor.sh"
check_exec "scripts/state-manager.sh" "$REPO_ROOT/scripts/state-manager.sh"
check_exec "scripts/invariant-check.sh" "$REPO_ROOT/scripts/invariant-check.sh"

echo ""
echo "  [Factory Cloud domain docs]"
check "docs/decision-lock.md" "$REPO_ROOT/docs/decision-lock.md"
check "docs/factory-flow-model.md" "$REPO_ROOT/docs/factory-flow-model.md"
check "docs/domain-glossary.md" "$REPO_ROOT/docs/domain-glossary.md"
check "docs/d2a-model-drift-correction.md" "$REPO_ROOT/docs/d2a-model-drift-correction.md"

echo ""
echo "  [AI control layer]"
check "ai/product-invariants.md" "$REPO_ROOT/ai/product-invariants.md"
check "ai/runtime-contracts.md" "$REPO_ROOT/ai/runtime-contracts.md"
check "ai/service-boundaries.md" "$REPO_ROOT/ai/service-boundaries.md"
check "ai/coding-patterns.md" "$REPO_ROOT/ai/coding-patterns.md"
check "ai/engineering-journal.md" "$REPO_ROOT/ai/engineering-journal.md"

echo ""
echo "  [D3 scaffold (positive checks)]"
check "frontend/" "$REPO_ROOT/frontend"
check "backend/" "$REPO_ROOT/backend"
check "docker-compose.yml" "$REPO_ROOT/docker-compose.yml"
check ".env.example" "$REPO_ROOT/.env.example"
check "README.md" "$REPO_ROOT/README.md"
check "specs/docker-stack-scaffold.md" "$REPO_ROOT/specs/docker-stack-scaffold.md"

echo ""
echo "  [D3 verification scripts (executable)]"
check_exec "scripts/verification/001-docker-compose-config.sh" "$REPO_ROOT/scripts/verification/001-docker-compose-config.sh"
check_exec "scripts/verification/002-backend-health.sh" "$REPO_ROOT/scripts/verification/002-backend-health.sh"
check_exec "scripts/verification/003-frontend-reachable.sh" "$REPO_ROOT/scripts/verification/003-frontend-reachable.sh"

echo ""
echo "  [D4 data files]"
check "data/stages.json" "$REPO_ROOT/data/stages.json"
check "data/orders.json" "$REPO_ROOT/data/orders.json"
check "data/factory_units.json" "$REPO_ROOT/data/factory_units.json"
check "data/parts.json" "$REPO_ROOT/data/parts.json"
check "data/users.json" "$REPO_ROOT/data/users.json"
check "data/model_recipes.json" "$REPO_ROOT/data/model_recipes.json"
check "data/reference_standards.json" "$REPO_ROOT/data/reference_standards.json"
check "data/events.json" "$REPO_ROOT/data/events.json"
check "specs/mock-data-contract.md" "$REPO_ROOT/specs/mock-data-contract.md"

echo ""
echo "  [D4 verification script (executable)]"
check_exec "scripts/verification/004-data-contract-api.sh" "$REPO_ROOT/scripts/verification/004-data-contract-api.sh"

echo ""
echo "----------------------------------------------------------------"
echo "  Results: $PASS passed, $FAIL failed"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "  STATUS: FAIL — scaffold integrity check failed"
  echo "  Fix missing artifacts before continuing."
  exit 1
else
  echo "  STATUS: PASS — D4 mock data contract verified"
  echo "  Run: docker compose up --build"
  exit 0
fi
