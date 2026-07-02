# Architecture Index — ndt-factory-cloud

**Phase:** D0-D2 Bootstrap Complete
**Status:** Planned architecture — no implementation yet
**Date:** 2026-06-30

This document describes the intended system architecture for ndt-factory-cloud.
No application code exists yet. This is a forward declaration for D3 and beyond.

---

## System Overview

ndt-factory-cloud is a Digital Factory control system for AstraX/NDT handheld device
production. The system tracks factory units through a 14-stage production spine, enforces
gates and hard-stops, manages calibration retry loops, and provisions cloud resources
upon completion.

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
│                                │  │ In-memory State     │  │    │
│                                │  │ (state/store.py)    │  │    │
│                                │  │ → Postgres (D4+)    │  │    │
│                                │  └─────────────────────┘  │    │
│                                └───────────────────────────┘    │
└────────────────────────────────────────────────────────────────┘
```

---

## Frontend Architecture

```
frontend/src/
├── components/
│   ├── production/     — factory unit cards, stage progress, hard-stop banners
│   ├── gates/          — calibration gate, QC sign-off gate UI
│   ├── forms/          — order intake form, part scan form
│   └── ui/             — shadcn/ui primitives (generated)
├── pages/
│   ├── OrdersPage      — list and create orders
│   ├── UnitDetailPage  — single unit production timeline
│   ├── FloorPage       — active units on the production floor
│   └── SupervisorPage  — hard-stops and dispositions queue
├── api/
│   ├── client.ts       — base fetch wrapper
│   ├── orders.ts       — order API calls
│   ├── units.ts        — unit API calls
│   └── stages.ts       — stage advance API calls
└── types/
    └── factory.ts      — TypeScript types mirroring Pydantic models
```

---

## Backend Architecture

```
backend/app/
├── main.py             — FastAPI app, router registration, CORS config
├── routers/
│   ├── orders.py       — POST /api/orders, GET /api/orders
│   ├── units.py        — POST /api/units, GET /api/units/{id}
│   ├── stages.py       — POST /api/units/{id}/advance, hard-stop management
│   ├── calibration.py  — POST /api/units/{id}/calibration, certificate management
│   ├── qc.py           — POST /api/units/{id}/qc-signoff
│   ├── genealogy.py    — POST /api/units/{id}/genealogy-lock
│   └── cloud.py        — POST /api/units/{id}/cloud-provision, cloud-backup (mocked)
├── models/
│   ├── order.py        — ProductionOrder, OrderResponse
│   ├── unit.py         — FactoryUnit, UnitResponse, StageHistory
│   ├── stage.py        — StageStatus, StageTransition, HardStop
│   ├── calibration.py  — CalibrationAttempt, CalibrationCertificate
│   └── actor.py        — Actor, AuthorityLevel
├── domain/
│   ├── stage_machine.py  — advance_stage(), check_hard_stop(), clear_hard_stop()
│   ├── calibration.py    — record_attempt(), issue_certificate(), check_limit()
│   ├── genealogy.py      — lock_genealogy(), is_locked()
│   └── cloud.py          — mock_provision(), mock_backup()
└── state/
    └── store.py          — in-memory dict state (v0)
```

---

## Domain Authority → Implementation Mapping

| Factory Flow Model Rule                  | Implementation                          |
|------------------------------------------|-----------------------------------------|
| 14 ordered stages                        | `backend/app/domain/stage_machine.py`   |
| Hard-stops block all advancement         | `stage_machine.advance_stage()` guard   |
| Calibration max 3 attempts               | `backend/app/domain/calibration.py`     |
| GENEALOGY_LOCK depends on QC gate        | `genealogy.py` pre-lock check           |
| Terminal state immutability              | Update endpoints reject terminal units  |
| Authority levels                         | `Actor.authority_level` check per stage |

---

## Cloud Integration (v0 Mock → D4+ Azure)

| v0 (Mock)                     | D4+ Azure Target                          |
|-------------------------------|-------------------------------------------|
| `mock_provision()` stubs      | Azure IoT Hub device registration         |
| `mock_backup()` stubs         | Azure Blob Storage backup confirmation    |
| No credentials                | Azure Managed Identity                    |
| In-memory result              | Real device connectivity check            |

---

## Key Constraints (from docs/decision-lock.md)

- No Postgres in v0 — all state is in-memory.
- No Azure SDKs in v0 — cloud stages are mocked.
- No real serial-number policy — placeholder formats only.
- Docker Compose is the only supported runtime.
