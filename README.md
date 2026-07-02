# ndt-factory-cloud

Dockerized Factory Cloud v0 — AstraX/NDT handheld device production management prototype.

**Current Phase:** D8C Touch-First Responsive Factory UI
**Status:** COMPLETE

---

## Purpose

Factory Cloud is a digital control system for tracking AstraX/NDT handheld devices
through a 14-stage production spine — from order intake through cloud provisioning
and shipment.

D4 establishes the mock data contract: 8 JSON data files and a read-only API surface.
No domain business logic is implemented yet.

---

## Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 18 + Vite 5 + TypeScript |
| UI | Tailwind CSS 3 |
| Backend | FastAPI + Pydantic + Uvicorn |
| State | PostgreSQL 16 + SQLAlchemy + Alembic |
| Runtime | Docker Compose |

---

## Running the Stack

```bash
docker compose up --build
```

| Service | URL |
|---------|-----|
| Frontend | http://localhost:5173 |
| Backend API | http://localhost:8000 |
| Backend docs | http://localhost:8000/docs |
| Backend health | http://localhost:8000/health |
| Data contract status | http://localhost:8000/factory/data-contract/status |

---

## Verification

```bash
# No running services needed
bash scripts/verification/001-docker-compose-config.sh

# Requires running stack (docker compose up --build -d)
bash scripts/verification/002-backend-health.sh
bash scripts/verification/003-frontend-reachable.sh
bash scripts/verification/004-data-contract-api.sh
bash scripts/verification/005-backend-state-behavior.sh  # D5 — 15 checks (26 assertions)
bash scripts/verification/006-factory-flow-board-ui.sh  # D6 — 12 checks
bash scripts/verification/007-persistence-postgres.sh  # D7 — 15 checks
bash scripts/verification/008-demo-readiness.sh         # D8 — 17 checks
bash scripts/verification/009-light-mode-readability.sh # D8A — 18 checks
bash scripts/verification/010-material-theme-readability.sh # D8B — 21 checks
bash scripts/verification/011-touch-first-responsive-ui.sh   # D8C — 32 checks + 1 env-limited skip

# Project smoke test
bash scripts/smoke.sh

# D8C browser test suite (requires a glibc-based Playwright-capable environment;
# see docs/touch-first-responsive-ui-d8c.md — Known Limitations)
cd frontend && npx playwright test

# OS invariant check
bash vendor/engineering-os/scripts/raystrat-os verify
```

---

## Action API (D5)

All action endpoints are POST. They enforce domain workflow rules and return `ActionResponse`.

| Endpoint | Domain Rule |
|----------|-------------|
| `POST /factory/units/{unit_id}/actions/scan-part` | Bind allocated part at STAGE-05 |
| `POST /factory/units/{unit_id}/actions/reallocate-part` | Supervisor reallocates part |
| `POST /factory/units/{unit_id}/actions/hardware-gate` | Pass/fail hardware gate at STAGE-09 |
| `POST /factory/units/{unit_id}/actions/calibration` | Record calibration attempt at STAGE-10 |
| `POST /factory/units/{unit_id}/actions/calibration-disposition` | Disposition after cap exceeded |
| `POST /factory/units/{unit_id}/actions/qc-signoff` | QC sign-off at STAGE-11 |
| `POST /factory/units/{unit_id}/actions/cloud-backup` | Cloud backup at STAGE-12 |
| `POST /factory/units/{unit_id}/actions/package` | Package at STAGE-13 |
| `POST /factory/units/{unit_id}/actions/ship` | Ship at STAGE-14 (terminal) |
| `POST /factory/units/{unit_id}/actions/transition` | Generic stage advance |
| `POST /factory/dev/reset-state` | Reload state from seed JSON (dev only) |

Business hard-stops return HTTP 200 + `status="blocked"`. Terminal unit → 409. Missing unit → 404.

---

## Data Contract API (D4 — unchanged)

All endpoints are read-only (GET only).

| Endpoint | Description |
|----------|-------------|
| `GET /factory/data-contract/status` | Contract metadata: phase, counts, files loaded |
| `GET /factory/stages` | All 14 canonical production stages |
| `GET /factory/units` | All factory units |
| `GET /factory/units/{unit_id}` | Single unit (404 if missing) |
| `GET /factory/orders` | All orders |
| `GET /factory/parts` | All parts |
| `GET /factory/users` | All users |
| `GET /factory/model-recipes` | All model recipes |
| `GET /factory/reference-standards` | All reference standards |
| `GET /factory/events` | All audit events |

---

## What Exists (D8)

- PostgreSQL 16 persistence — unit state survives container restart (D7)
- 11 workflow action endpoints with full domain rule enforcement (D5)
- Hard-stop and no_override enforcement (calibration ref standard, cloud backup unavailable)
- Calibration 3-attempt cap with supervisor disposition path
- QC separation-of-duty check (signer ≠ assembly operator ≠ calibration technician)
- Terminal state immutability (409 on any action against shipped/scrapped/rejected units)
- D4 read-only API unchanged and backward-compatible
- Factory Flow Board UI: unit queue, 14-stage spine, action panel, event trace (D6)
- D8 review hardening: scenario labels, gate/cloud-block visual clarity, unit-filtered event trace,
  hard-stop section in unit detail, backend-guarded action labels, Reset Demo State button
- D8 meta markers: `data-d8-demo-readiness`, `<meta name="app-d8" content="demo-readiness" />`
- D8A light mode: off-white background (#FAFAF7), larger typography (text-sm/text-2xl),
  light semantic state colors (red-50/amber-50/green-50/orange-50), no opacity washout on stages
- D8A meta markers: `data-theme="light-review"`, `data-d8a-readability="true"`
- D8B Material Design theme: CSS token system (--mds-*, --factory-*), Light/Dark toggle with
  localStorage persistence, no-FOUC inline script, container color hierarchy, MD3 cards/inputs
- D8B meta markers: `data-d8b-material-theme="true"`, `app-d8b="material-theme-toggle"`
- D8C touch-first responsive UI: 48/44px touch-target contract, breakpoint model (compact
  <1024px / standard 1024-1599px / large >=1600px), compact-width pane switcher (Unit Queue /
  Detail / Stages / Events tabs) replacing the forced three-column desktop layout, EventTrace
  responsive card list at compact widths, prominent blocked-reason/NO-OVERRIDE styling,
  destructive/supervisor action color differentiation, touch-safe form controls
- D8C meta marker: `data-d8c-touch-responsive="true"`
- D8C also fixed a pre-existing defect where the calibration-cap-exceeded disposition form never
  rendered (frontend read a phantom `calibration_status` field never sent by the backend instead
  of the real `calibration_summary` field) — see docs/touch-first-responsive-ui-d8c.md

---

## What Is Intentionally Not Implemented (D8)

- Real-time push updates (WebSocket / SSE)
- Full unit history viewer
- Order management UI
- Azure SDK wiring
- Auth / session management

---

## Engineering OS

This project uses the Raystrat Engineering OS for deterministic AI-assisted development.

```bash
# Boot check
bash vendor/engineering-os/scripts/raystrat-os boot

# Adapter check
bash vendor/engineering-os/scripts/raystrat-os check

# Run self-tests
bash vendor/engineering-os/tests/run-self-tests.sh
```
# ndt-factory-cloud
