# ndt-factory-cloud — Repository Decision Lock

**Phase:** D0 — Repository Decision Lock
**Status:** LOCKED
**Date:** 2026-06-30

Decisions recorded here are locked. Reopening any of these decisions requires
a new directive from the product authority.

---

## Decision 1 — Repository Identity

**Repo name:** `ndt-factory-cloud`
**Purpose:** Dockerized Factory Cloud v0 prototype for AstraX/NDT handheld device
manufacturing.
**Scope:** Factory production spine — order intake through cloud provisioning and shipment.
**Not in scope (v0):** Multi-site, SLA enforcement, real-time telemetry streaming.

---

## Decision 2 — Stack

| Layer       | Technology                         | Notes                            |
|-------------|-----------------------------------|----------------------------------|
| Frontend    | React + Vite + TypeScript          | shadcn/ui + Tailwind             |
| Backend     | FastAPI + Pydantic                 | Python 3.12+                     |
| State (v0)  | Mock JSON / in-memory              | No database in v0                |
| Database    | Postgres (deferred)                | Not in D3; introduced in later phase |
| Runtime     | Docker Compose                     | Container-first                  |
| Cloud       | Cloud-neutral                      | Azure-ready posture; no Azure SDKs in v0 |

---

## Decision 3 — Architecture Posture

- **Container-first.** All services run inside Docker Compose. No bare-host execution.
- **Backend owns all state transitions.** The frontend never directly advances factory state.
- **Mock state first.** v0 uses in-memory / JSON state. Postgres is explicitly deferred.
- **REST API boundary.** Frontend communicates with backend only via HTTP REST API.
- **Cloud-neutral.** No Azure SDKs, no Azure-specific services in v0. Azure-ready means
  the code is structured to accept Azure credentials when introduced; it does not mean
  Azure is wired now.

---

## Decision 4 — Cloud Posture

- v0 cloud backend is mocked. Cloud provisioning and cloud backup stages exist in the
  factory flow model but call mock/stub implementations.
- No real cloud credentials, no real storage, no real device connectivity in v0.
- Azure targets (Azure IoT Hub, Azure Blob Storage) are the planned D4+ targets.
  Nothing Azure-specific is imported or wired in v0.

---

## Decision 5 — Naming Conventions

The following placeholder identifiers are used in tests, fixtures, and documentation only.
They are NOT production serial-number policy and must never be treated as such.

| Placeholder    | Type                  | Example         |
|----------------|-----------------------|-----------------|
| `UNIT-0001`    | Factory unit          | UNIT-0001       |
| `ORDER-0001`   | Production order      | ORDER-0001      |
| `PART-TUBE-0001` | Serialized part (tube) | PART-TUBE-0001 |
| `PART-PCB-0001`  | Serialized part (PCB)  | PART-PCB-0001  |

Production serial-number policy is a separate decision outside the scope of this repository.

---

## Decision 6 — Engineering OS

- Engineering OS is provisioned as an in-tree adapter (no git submodule in v0).
- Vendoring from upstream OS if needed is a D3+ decision.
- All control-layer docs live in `ai/`.
- Pipeline scripts live in `scripts/`.
- The vendor path `vendor/engineering-os/` is reserved but empty in D0-D2.

---

## Decision 7 — Phase Boundary

| Phase | Name                    | Status         |
|-------|-------------------------|----------------|
| D0    | Repository Decision Lock | COMPLETE       |
| D1    | OS Vendor Bootstrap      | COMPLETE       |
| D2    | Factory Domain Model Freeze | COMPLETE    |
| D3    | Stack Scaffold           | NOT STARTED    |
| D4+   | Feature Implementation   | NOT STARTED    |

D3 requires a new directive. No application code, no React scaffold, no FastAPI scaffold
exists until D3 is authorized.
