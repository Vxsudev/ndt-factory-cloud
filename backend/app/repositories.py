"""
Database query helpers. Thin wrappers over SQLAlchemy Session queries.
state_store.py uses these for read operations.
"""
from __future__ import annotations

from sqlalchemy.orm import Session

from app.db_models import Event, FactoryUnit, Part, ReferenceStandard, Stage, User


def count_units(db: Session) -> int:
    return db.query(FactoryUnit).count()


def count_stages(db: Session) -> int:
    return db.query(Stage).count()


def get_unit_row(db: Session, unit_id: str) -> FactoryUnit | None:
    return db.query(FactoryUnit).filter(FactoryUnit.unit_id == unit_id).first()


def list_unit_rows(db: Session) -> list[FactoryUnit]:
    return db.query(FactoryUnit).all()


def list_part_rows(db: Session) -> list[Part]:
    return db.query(Part).all()


def list_user_rows(db: Session) -> list[User]:
    return db.query(User).all()


def list_ref_std_rows(db: Session) -> list[ReferenceStandard]:
    return db.query(ReferenceStandard).all()


def list_event_rows(db: Session) -> list[Event]:
    return db.query(Event).order_by(Event.id).all()
