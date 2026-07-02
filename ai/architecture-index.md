# Architecture Index — ndt-factory-cloud

**Phase:** D8C Touch-First Responsive Factory UI — COMPLETE
**Status:** Frontend is touch-and-mouse usable 768px–1920px+ via a breakpoint model and
48/44px touch-target contract; D8B MD3 theme system unchanged; all D4–D8B APIs preserved;
no backend changes in D8C
**Date:** 2026-07-02

This document describes the intended system architecture for ndt-factory-cloud.
No application code exists yet. This is a forward declaration for D3 and beyond.

---

## System Overview

ndt-factory-cloud is a Digital Factory control system for AstraX/NDT handheld device
production. The system tracks factory units through a 14-stage production spine, enforces
calibration gates, manages QC sign-off, and backs up production records to cloud.

---

## Runtime Architecture (Docker Compose)

```
┌────────────────────────────────────────────────────────────────┐
│ docker-compose.yml                                              │
│                                                                 │
│  ┌──────────────────┐         ┌───────────────────────────┐    │
│  │ frontend          │         │ backend                   │    │
│  │ React + Vite      │◄────────│ FastAPI + Pydantic        │    │
│  │ :5173 (dev)       │  HTTP   │ :8000                     │    │
│  │ Tailwind + shadcn │  REST   │                           │    │
│  └──────────────────┘         │  ┌─────────────────────┐  │    │
│                                │  │ Stage Machine       │  │    │
│                                │  │ (domain/stage_      │  │    │
│                                │  │  machine.py)        │  │    │
│                                │  └─────────────────────┘  │    │
│                                │  ┌─────────────────────┐  │    │
│                                │  │ DB State Store      │  │    │
│                                │  │ (state_store.py)    │  │    │
│                                │  │ → PostgreSQL 16     │  │    │
│                                │  └─────────────────────┘  │    │
│                                └───────────────────────────┘    │
└────────────────────────────────────────────────────────────────┘
```

---

## Frontend Architecture

```
frontend/src/
├── components/
│   ├── production/     — factory unit cards, 14-stage progress, hard-stop banners
│   ├── gates/          — calibration gate UI, QC sign-off gate UI
│   ├── forms/          — order intake form, part scan form
│   └── ui/             — shadcn/ui primitives (generated)
├── pages/
│   ├── OrdersPage      — list and create orders
│   ├── UnitDetailPage  — single unit production timeline (all 14 stages)
│   ├── FloorPage       — active units on the production floor
│   └── SupervisorPage  — hard-stops and dispositions queue
├── api/
│   ├── client.ts       — base fetch wrapper
│   ├── orders.ts       — order API calls (S-01 through S-03)
│   ├── units.ts        — unit API calls
│   └── stages.ts       — stage advance API calls
└── types/
    └── factory.ts      — TypeScript types mirroring Pydantic models
```

---

## Backend Architecture

```
backend/app/
├── main.py             — FastAPI app, router registration, CORS config (v0.5.0)
├── settings.py         — Pydantic settings from env
├── models.py           — all Pydantic models (D3 + D4 read models + D5 action models)
├── data_loader.py      — loads data/*.json from DATA_DIR env (D4)
├── state_store.py      — in-memory state singleton; load/get/reset/update_unit (D5)
├── workflow_rules.py   — all domain workflow action functions (D5)
└── routes/
    ├── health.py        — GET /health
    ├── factory.py       — GET /factory/scaffold-status
    ├── data_contract.py — 10 GET endpoints for D4 read-only data contract
    └── actions.py       — 11 POST endpoints for D5 workflow actions
```

**D5 implementation pattern:** flat module layout (not domain/routers split).
workflow_rules.py contains all domain logic; state_store.py is the state boundary.
Future routers (D6+) may decompose further as feature surface grows.

---

## Domain Authority → Implementation Mapping

| Factory Flow Model Rule                       | Implementation                          |
|-----------------------------------------------|-----------------------------------------|
| 14 ordered stages (S-01 through S-14)         | `backend/app/domain/stage_machine.py`   |
| Hard-stops block all advancement              | `stage_machine.advance_stage()` guard   |
| Calibration reference standard (no override)  | `domain/calibration.validate_reference_standard()` |
| Calibration max 3 attempts                    | `domain/calibration.record_attempt()` + counter check |
| QC pass finalizes production record           | `stage_machine.py` post-QC guard on S-12 |
| Terminal state immutability                   | Update endpoints reject terminal units  |
| Authority levels                              | `Actor.authority_level` check per stage |

---

## Stage Coverage by Router

| Stage | Name                              | Primary Router     |
|-------|-----------------------------------|--------------------|
| S-01  | Order Created                     | orders.py          |
| S-02  | Order Approved                    | orders.py          |
| S-03  | Order Received by Factory         | orders.py          |
| S-04  | Parts Allocated                   | stages.py          |
| S-05  | Assembly                          | stages.py          |
| S-06  | Software / Firmware Installed     | firmware.py        |
| S-07  | Software / Firmware Updated from Cloud | firmware.py   |
| S-08  | Device Provisioned with Cloud     | cloud.py           |
| S-09  | Hardware Checks / Setup           | stages.py          |
| S-10  | Calibration                       | calibration.py     |
| S-11  | Quality Control                   | qc.py              |
| S-12  | Factory Data Backup to Cloud      | backup.py          |
| S-13  | Package                           | stages.py          |
| S-14  | Ship                              | stages.py          |

---

## Cloud Integration (v0 Mock → D4+ Azure)

| v0 (Mock)                     | D4+ Azure Target                              |
|-------------------------------|-----------------------------------------------|
| `mock_provision()` stubs (S-08) | Azure IoT Hub device registration            |
| `mock_backup()` stubs (S-12)  | Azure Blob Storage backup confirmation         |
| Firmware update stub (S-07)   | Azure IoT Hub firmware deployment             |
| No credentials                | Azure Managed Identity                        |
| In-memory result              | Real device connectivity check                |

---

## D8C Responsive/Touch Layer (frontend-only, additive)

```
frontend/src/
├── styles.css                          — .touch-target-primary (48px) / .touch-target-secondary
│                                          (44px) utility classes; .mdc-input/.mdc-select bumped
│                                          to 48px min-height, 16px font-size. Additive to the
│                                          existing --mds-*/--factory-* token system — no theme
│                                          mechanism changes.
├── components/FactoryFlowBoard.tsx     — compact-width (<1024px) pane switcher (Unit Queue /
│                                          Detail / Stages / Events), standard (1024-1599px) and
│                                          large (>=1600px, via min-[1600px]:) column widths.
│                                          data-d8c-touch-responsive="true" marker.
├── playwright.config.ts, tests/        — minimum browser-verification tooling (@playwright/test),
│                                          added because none existed in this repo before D8C.
```

No new backend routes, no schema changes, no new npm runtime dependency (only a devDependency).
Breakpoint boundaries reuse Tailwind's default `lg`/`xl` scale plus one arbitrary `min-[1600px]:`
variant — `tailwind.config.js` is unmodified.

---

## Key Constraints (from docs/decision-lock.md)

- PostgreSQL 16 for state persistence (D7+). No Azure SDKs — cloud stages are mocked.
- No real serial-number policy — placeholder formats only.
- Docker Compose is the only supported runtime.
