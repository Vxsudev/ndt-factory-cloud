# Verification Playbook — ndt-factory-cloud

## Purpose

This document defines the verification gate that must execute after every feature
implementation. Verification must pass before a feature is marked complete and a
journal entry is appended.

---

## Verification Script Location

```
scripts/verification/
```

Scripts are numbered and execute in lexical order.

---

## Execution Mode

**DELTA-ONLY** for feature-scoped verification:

- If the feature's spec declares `## Verification Scripts`, the supervisor runs only
  those specific scripts.
- Otherwise, the supervisor runs all active top-level `*.sh` scripts in
  `scripts/verification/`, excluding `_legacy/` and `_quarantine/`.

**Full regression** (run before any release):

```
bash scripts/verification/run-full-regression.sh
```

---

## Script Naming Convention

```
NNN-<description>-v<version>.sh
```

Examples:
```
001-bootstrap-artifacts.sh
010-backend-startup.sh
020-order-intake.sh
030-stage-advance.sh
040-calibration-retry.sh
```

---

## Script Requirements

Each verification script must:
1. Exit 0 on pass.
2. Exit non-zero on fail with a descriptive error message.
3. Not modify production state (read-only verification).
4. Be runnable standalone from the repository root.

---

## Permanent Control-Layer Gates (from D1 onwards)

```
scripts/verification/001-bootstrap-artifacts.sh   — verifies D0-D2 artifacts exist
```

From D3:
```
scripts/verification/010-docker-compose-up.sh     — all containers start cleanly
scripts/verification/020-backend-health.sh        — FastAPI health endpoint responds
scripts/verification/030-frontend-build.sh        — Vite build completes
```

---

## Bootstrap Verification (D0-D2)

During D0-D2, the active verification is `scripts/smoke.sh`. Run it to verify
the bootstrap artifacts are intact.

Full `scripts/verification/` directory is created in D3.

---

## Failure Protocol

If any verification script fails:
1. Do not mark the feature complete.
2. Do not append a journal entry.
3. Fix the failure.
4. Re-run verification.
5. Only proceed on full pass.

If a verification script itself is broken (false failure): document in
`ai/incidents/` and mark the script for review before re-enabling it.
