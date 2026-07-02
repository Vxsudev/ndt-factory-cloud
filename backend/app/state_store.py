"""
DB-backed state store for D7 Persistence / Postgres.

Public interface matches D5 in-memory contract. All mutations are persisted to
PostgreSQL. workflow_rules.py is unchanged — it still mutates the state dict in
place; routes call persist_action() after each workflow to flush changes to DB.
"""
from __future__ import annotations

from typing import Any

from sqlalchemy import func, text
from sqlalchemy.orm import Session

from app.db_models import Event, FactoryUnit, Part, ReferenceStandard, User
from app.seed import seed

# ── Keys that live as real columns on factory_units ───────────────────────────

_UNIT_TOP_KEYS = frozenset({
    "id", "order_id", "model_id", "genealogy_serial",
    "current_stage_id", "current_stage_number", "current_status",
    "blocked_reason", "block_type", "no_override",
})

# ── Serialisation helpers ─────────────────────────────────────────────────────


def _unit_to_dict(row: FactoryUnit) -> dict[str, Any]:
    d: dict[str, Any] = {
        "id": row.unit_id,
        "order_id": row.order_id,
        "model_id": row.model_id,
        "genealogy_serial": row.genealogy_serial,
        "current_stage_id": row.current_stage_id,
        "current_stage_number": row.current_stage_number,
        "current_status": row.current_status,
        "blocked_reason": row.blocked_reason,
        "block_type": row.block_type,
        "no_override": row.no_override,
    }
    if row.payload:
        d.update(row.payload)
    return d


def _part_to_dict(row: Part) -> dict[str, Any]:
    return {
        "id": row.part_id,
        "part_type": row.part_type,
        "serial_number": row.serial_number,
        "lot_number": row.lot_number,
        "inventory_status": row.inventory_status,
        "allocated_to_order_id": row.allocated_to_order_id,
        "bound_to_unit_id": row.bound_to_unit_id,
        "released": row.released,
        "release_reason_code": row.release_reason_code,
        "source_system": row.source_system,
    }


def _user_to_dict(row: User) -> dict[str, Any]:
    return {
        "id": row.user_id,
        "name": row.name,
        "role": row.role,
        "can_override": row.can_override,
        "can_qc_signoff": row.can_qc_signoff,
        "can_waive_separation_of_duty": row.can_waive_separation_of_duty,
        "disposition_authority": row.disposition_authority or [],
    }


def _ref_std_to_dict(row: ReferenceStandard) -> dict[str, Any]:
    d: dict[str, Any] = {
        "id": row.ref_std_id,
        "name": row.name,
        "status": row.status,
        "can_be_used_for_calibration": row.can_be_used_for_calibration,
        "expiry_date": row.expiry_date,
    }
    if row.payload:
        d.update(row.payload)
    return d


def _event_to_dict(row: Event) -> dict[str, Any]:
    return {
        "id": row.event_id,
        "unit_id": row.unit_id,
        "order_id": row.order_id,
        "event_type": row.event_type,
        "stage_id": row.stage_id,
        "actor_user_id": row.actor_user_id,
        "timestamp": row.timestamp,
        "message": row.message,
        "severity": row.severity,
        "payload": row.payload or {},
        "source_refs": row.source_refs or [],
    }


# ── Public interface (matches D5 contract) ────────────────────────────────────


def get_state(db: Session) -> dict[str, Any]:
    """Load full factory state from DB as a mutable dict."""
    units = {row.unit_id: _unit_to_dict(row) for row in db.query(FactoryUnit).all()}
    parts = {row.part_id: _part_to_dict(row) for row in db.query(Part).all()}
    users = {row.user_id: _user_to_dict(row) for row in db.query(User).all()}
    ref_stds = {
        row.ref_std_id: _ref_std_to_dict(row)
        for row in db.query(ReferenceStandard).all()
    }
    events = [_event_to_dict(row) for row in db.query(Event).order_by(Event.id).all()]
    event_counter = db.query(func.count(Event.id)).scalar() or 0
    parts_by_serial = {
        row.serial_number: row.part_id
        for row in db.query(Part).filter(Part.serial_number.isnot(None)).all()
    }
    return {
        "units": units,
        "parts": parts,
        "users": users,
        "reference_standards": ref_stds,
        "events": events,
        "event_counter": event_counter,
        "parts_by_serial": parts_by_serial,
    }


def reset_state(db: Session) -> None:
    """Truncate all mutable tables and reseed from data/*.json."""
    db.execute(text(
        "TRUNCATE TABLE events, factory_units, parts, users, "
        "reference_standards, orders, stages, model_recipes RESTART IDENTITY CASCADE"
    ))
    db.commit()
    seed(db)


def get_unit(db: Session, unit_id: str) -> dict[str, Any] | None:
    row = db.query(FactoryUnit).filter(FactoryUnit.unit_id == unit_id).first()
    return _unit_to_dict(row) if row else None


def update_unit(db: Session, unit_id: str, patch: dict[str, Any]) -> dict[str, Any]:
    row = db.query(FactoryUnit).filter(FactoryUnit.unit_id == unit_id).first()
    if row is None:
        raise KeyError(f"Unit {unit_id} not found")
    unit_data = _unit_to_dict(row)
    unit_data.update(patch)
    _persist_unit_row(db, unit_data)
    db.commit()
    return unit_data


def next_event_id(state: dict[str, Any]) -> str:
    """Increment in-state counter and return next event ID string."""
    n = state["event_counter"] + 1
    state["event_counter"] = n
    return f"EVENT-D5-{n:04d}"


def append_event(state: dict[str, Any], event: dict[str, Any]) -> None:
    """Append event to in-state list and update unit event_ids list."""
    state["events"].append(event)
    unit_id = event.get("unit_id")
    if unit_id and unit_id in state["units"]:
        state["units"][unit_id].setdefault("event_ids", []).append(event["id"])


def persist_action(
    db: Session,
    state: dict[str, Any],
    unit_id: str,
    events_baseline: int,
) -> None:
    """Flush in-memory mutations from a workflow action back to the DB.

    Called by route handlers after workflow_rules returns. Persists:
    - The modified unit (including payload with nested fields)
    - All parts (handles both updates and new parts from reallocation)
    - Any events appended since events_baseline
    """
    _persist_unit_row(db, state["units"][unit_id])
    for part_data in state["parts"].values():
        _upsert_part_row(db, part_data)
    for ev in state["events"][events_baseline:]:
        _insert_event_row(db, ev)
    db.commit()


# ── Internal persistence helpers ──────────────────────────────────────────────


def _persist_unit_row(db: Session, unit_data: dict[str, Any]) -> None:
    payload = {k: v for k, v in unit_data.items() if k not in _UNIT_TOP_KEYS}
    row = db.query(FactoryUnit).filter(FactoryUnit.unit_id == unit_data["id"]).first()
    if row is None:
        return
    row.current_stage_id = unit_data["current_stage_id"]
    row.current_stage_number = unit_data["current_stage_number"]
    row.current_status = unit_data["current_status"]
    row.blocked_reason = unit_data.get("blocked_reason")
    row.block_type = unit_data.get("block_type")
    row.no_override = unit_data.get("no_override", False)
    row.payload = payload
    db.flush()


def _upsert_part_row(db: Session, part_data: dict[str, Any]) -> None:
    row = db.query(Part).filter(Part.part_id == part_data["id"]).first()
    if row is not None:
        row.inventory_status = part_data["inventory_status"]
        row.allocated_to_order_id = part_data.get("allocated_to_order_id")
        row.bound_to_unit_id = part_data.get("bound_to_unit_id")
        row.released = part_data.get("released", False)
        row.release_reason_code = part_data.get("release_reason_code")
    else:
        db.add(Part(
            part_id=part_data["id"],
            part_type=part_data["part_type"],
            serial_number=part_data.get("serial_number"),
            lot_number=part_data.get("lot_number"),
            inventory_status=part_data["inventory_status"],
            allocated_to_order_id=part_data.get("allocated_to_order_id"),
            bound_to_unit_id=part_data.get("bound_to_unit_id"),
            released=part_data.get("released", False),
            release_reason_code=part_data.get("release_reason_code"),
            source_system=part_data.get("source_system"),
        ))
    db.flush()


def _insert_event_row(db: Session, event_data: dict[str, Any]) -> None:
    db.add(Event(
        event_id=event_data["id"],
        unit_id=event_data.get("unit_id"),
        order_id=event_data.get("order_id"),
        event_type=event_data["event_type"],
        stage_id=event_data.get("stage_id"),
        actor_user_id=event_data.get("actor_user_id"),
        timestamp=event_data["timestamp"],
        message=event_data["message"],
        severity=event_data.get("severity", "info"),
        payload=event_data.get("payload", {}),
        source_refs=event_data.get("source_refs", []),
    ))
    db.flush()
