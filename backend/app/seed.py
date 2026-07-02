"""
Seed loader — populates all DB tables from data/*.json.
Called on first boot (if DB empty) and on reset-state.
"""
from __future__ import annotations

from sqlalchemy.orm import Session

from app import data_loader
from app.db_models import (
    Event, FactoryUnit, ModelRecipe, Order, Part,
    ReferenceStandard, Stage, User,
)

_UNIT_TOP_KEYS = frozenset({
    "id", "order_id", "model_id", "genealogy_serial",
    "current_stage_id", "current_stage_number", "current_status",
    "blocked_reason", "block_type", "no_override",
})


def seed(db: Session) -> None:
    _seed_stages(db)
    _seed_orders(db)
    _seed_units(db)
    _seed_parts(db)
    _seed_users(db)
    _seed_model_recipes(db)
    _seed_reference_standards(db)
    _seed_events(db)
    db.commit()


def is_empty(db: Session) -> bool:
    return db.query(FactoryUnit).count() == 0


def _seed_stages(db: Session) -> None:
    for s in data_loader.get_stages():
        db.add(Stage(
            stage_id=s["id"],
            number=s["number"],
            name=s["name"],
            stage_type=s["stage_type"],
            ownership=s["ownership"],
            is_gate=s.get("is_gate", False),
            is_external=s.get("is_external", False),
            is_separable=s.get("is_separable", False),
            hard_stop_controls=s.get("hard_stop_controls", []),
            authority_notes=s.get("authority_notes"),
            normal_next_stage_id=s.get("normal_next_stage_id"),
        ))


def _seed_orders(db: Session) -> None:
    top = {"id"}
    for o in data_loader.get_orders():
        db.add(Order(
            order_id=o["id"],
            model_id=o.get("model_id"),
            customer_ref=o.get("customer_ref"),
            order_date=o.get("created_at") or o.get("order_date"),
            notes=o.get("notes"),
            payload={k: v for k, v in o.items() if k not in top},
        ))


def _seed_units(db: Session) -> None:
    for u in data_loader.get_factory_units():
        db.add(FactoryUnit(
            unit_id=u["id"],
            order_id=u.get("order_id"),
            model_id=u.get("model_id"),
            genealogy_serial=u.get("genealogy_serial"),
            current_stage_id=u["current_stage_id"],
            current_stage_number=u["current_stage_number"],
            current_status=u["current_status"],
            blocked_reason=u.get("blocked_reason"),
            block_type=u.get("block_type"),
            no_override=u.get("no_override", False),
            payload={k: v for k, v in u.items() if k not in _UNIT_TOP_KEYS},
        ))


def _seed_parts(db: Session) -> None:
    for p in data_loader.get_parts():
        db.add(Part(
            part_id=p["id"],
            part_type=p["part_type"],
            serial_number=p.get("serial_number"),
            lot_number=p.get("lot_number"),
            inventory_status=p["inventory_status"],
            allocated_to_order_id=p.get("allocated_to_order_id"),
            bound_to_unit_id=p.get("bound_to_unit_id"),
            released=p.get("released", False),
            release_reason_code=p.get("release_reason_code"),
            source_system=p.get("source_system"),
        ))


def _seed_users(db: Session) -> None:
    for u in data_loader.get_users():
        roles = u.get("roles", [])
        role = roles[0] if roles else u.get("role", "operator")
        db.add(User(
            user_id=u["id"],
            name=u["name"],
            role=role,
            can_override=u.get("can_override", False),
            can_qc_signoff=u.get("can_qc_signoff", False),
            can_waive_separation_of_duty=u.get("can_waive_separation_of_duty", False),
            disposition_authority=u.get("disposition_authority", []),
        ))


def _seed_model_recipes(db: Session) -> None:
    top = {"id", "name", "description"}
    for m in data_loader.get_model_recipes():
        db.add(ModelRecipe(
            model_id=m["id"],
            name=m.get("name"),
            description=m.get("description"),
            payload={k: v for k, v in m.items() if k not in top},
        ))


def _seed_reference_standards(db: Session) -> None:
    top = {"id", "status", "can_be_used_for_calibration"}
    for r in data_loader.get_reference_standards():
        db.add(ReferenceStandard(
            ref_std_id=r["id"],
            name=r.get("standard_type") or r.get("name") or r["id"],
            status=r["status"],
            can_be_used_for_calibration=r.get("can_be_used_for_calibration", False),
            expiry_date=r.get("valid_until") or r.get("expiry_date"),
            payload={k: v for k, v in r.items() if k not in top},
        ))


def _seed_events(db: Session) -> None:
    for e in data_loader.get_events():
        db.add(Event(
            event_id=e["id"],
            unit_id=e.get("unit_id"),
            order_id=e.get("order_id"),
            event_type=e["event_type"],
            stage_id=e.get("stage_id"),
            actor_user_id=e.get("actor_user_id"),
            timestamp=e["timestamp"],
            message=e["message"],
            severity=e.get("severity", "info"),
            payload=e.get("payload", {}),
            source_refs=e.get("source_refs", []),
        ))
