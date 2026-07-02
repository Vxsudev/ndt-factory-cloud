#!/usr/bin/env bash
# ndt-factory-cloud | scripts/smoke.sh
# D0-D2 Bootstrap Smoke Verification
#
# Verifies that all required D0-D2 control-layer artifacts are present.
# This is the active verification script for the bootstrap phase.
# Run after any agent session to confirm bootstrap integrity.

set -euo pipefail

PASS=0
FAIL=0

check() {
  local desc="$1"
  local path="$2"
  if [ -f "$path" ]; then
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

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo ""
echo "================================================================"
echo "  ndt-factory-cloud | smoke.sh"
echo "  D0-D2 Bootstrap Smoke Verification"
echo "================================================================"
echo ""

echo "  [D0] Repository Decision Lock"
check "docs/decision-lock.md" "$REPO_ROOT/docs/decision-lock.md"

echo ""
echo "  [D1] OS Root Documents"
check "CLAUDE.md" "$REPO_ROOT/CLAUDE.md"
check "PROJECT_BOOTSTRAP.md" "$REPO_ROOT/PROJECT_BOOTSTRAP.md"
check "ENGINEERING_OS.md" "$REPO_ROOT/ENGINEERING_OS.md"

echo ""
echo "  [D1] AI Control Layer (16 documents)"
check "ai/product-invariants.md" "$REPO_ROOT/ai/product-invariants.md"
check "ai/runtime-contracts.md" "$REPO_ROOT/ai/runtime-contracts.md"
check "ai/service-boundaries.md" "$REPO_ROOT/ai/service-boundaries.md"
check "ai/coding-patterns.md" "$REPO_ROOT/ai/coding-patterns.md"
check "ai/spec-generation.md" "$REPO_ROOT/ai/spec-generation.md"
check "ai/spec-compiler.md" "$REPO_ROOT/ai/spec-compiler.md"
check "ai/spec-to-task-playbook.md" "$REPO_ROOT/ai/spec-to-task-playbook.md"
check "ai/task-generator.md" "$REPO_ROOT/ai/task-generator.md"
check "ai/task-graph.md" "$REPO_ROOT/ai/task-graph.md"
check "ai/execution-loop-controller.md" "$REPO_ROOT/ai/execution-loop-controller.md"
check "ai/execution-orchestrator.md" "$REPO_ROOT/ai/execution-orchestrator.md"
check "ai/verification-playbook.md" "$REPO_ROOT/ai/verification-playbook.md"
check "ai/debug-playbook.md" "$REPO_ROOT/ai/debug-playbook.md"
check "ai/repo-index.md" "$REPO_ROOT/ai/repo-index.md"
check "ai/architecture-index.md" "$REPO_ROOT/ai/architecture-index.md"
check "ai/engineering-journal.md" "$REPO_ROOT/ai/engineering-journal.md"

echo ""
echo "  [D1] Pipeline Scripts (executable)"
check_exec "scripts/compile-spec.sh" "$REPO_ROOT/scripts/compile-spec.sh"
check_exec "scripts/generate-tasks.sh" "$REPO_ROOT/scripts/generate-tasks.sh"
check_exec "scripts/execution-supervisor.sh" "$REPO_ROOT/scripts/execution-supervisor.sh"
check_exec "scripts/smoke.sh" "$REPO_ROOT/scripts/smoke.sh"

echo ""
echo "  [D2] Factory Domain Model"
check "docs/factory-flow-model.md" "$REPO_ROOT/docs/factory-flow-model.md"
check "docs/domain-glossary.md" "$REPO_ROOT/docs/domain-glossary.md"

echo ""
echo "  [D0-D2] Negative checks (should NOT exist yet)"
if [ -f "$REPO_ROOT/docker-compose.yml" ]; then
  echo "  WARN  docker-compose.yml exists — D3 started?"
else
  echo "  OK    docker-compose.yml not present (expected)"
fi
if [ -d "$REPO_ROOT/frontend" ]; then
  echo "  WARN  frontend/ exists — D3 started?"
else
  echo "  OK    frontend/ not present (expected)"
fi
if [ -d "$REPO_ROOT/backend" ]; then
  echo "  WARN  backend/ exists — D3 started?"
else
  echo "  OK    backend/ not present (expected)"
fi

echo ""
echo "----------------------------------------------------------------"
echo "  Results: $PASS passed, $FAIL failed"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "  STATUS: FAIL — D0-D2 bootstrap is incomplete"
  echo "  Fix missing artifacts before continuing."
  exit 1
else
  echo "  STATUS: PASS — D0-D2 bootstrap verified"
  echo "  Ready for D3 Stack Scaffold directive."
  exit 0
fi
