from sqlalchemy import Boolean, Column, Integer, String, Text, DateTime, Float
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass


class Stage(Base):
    __tablename__ = "stages"

    id = Column(Integer, primary_key=True, autoincrement=True)
    stage_id = Column(String, unique=True, nullable=False, index=True)
    number = Column(Integer, nullable=False)
    name = Column(String, nullable=False)
    stage_type = Column(String, nullable=False)
    ownership = Column(String, nullable=False)
    is_gate = Column(Boolean, nullable=False, default=False)
    is_external = Column(Boolean, nullable=False, default=False)
    is_separable = Column(Boolean, nullable=False, default=False)
    hard_stop_controls = Column(JSONB, nullable=False, default=list)
    authority_notes = Column(Text, nullable=True)
    normal_next_stage_id = Column(String, nullable=True)


class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, autoincrement=True)
    order_id = Column(String, unique=True, nullable=False, index=True)
    model_id = Column(String, nullable=True)
    customer_ref = Column(String, nullable=True)
    order_date = Column(String, nullable=True)
    notes = Column(Text, nullable=True)
    payload = Column(JSONB, nullable=False, default=dict)


class FactoryUnit(Base):
    __tablename__ = "factory_units"

    id = Column(Integer, primary_key=True, autoincrement=True)
    unit_id = Column(String, unique=True, nullable=False, index=True)
    order_id = Column(String, nullable=True)
    model_id = Column(String, nullable=True)
    genealogy_serial = Column(String, nullable=True)
    current_stage_id = Column(String, nullable=False)
    current_stage_number = Column(Integer, nullable=False)
    current_status = Column(String, nullable=False)
    blocked_reason = Column(String, nullable=True)
    block_type = Column(String, nullable=True)
    no_override = Column(Boolean, nullable=False, default=False)
    payload = Column(JSONB, nullable=False, default=dict)


class Part(Base):
    __tablename__ = "parts"

    id = Column(Integer, primary_key=True, autoincrement=True)
    part_id = Column(String, unique=True, nullable=False, index=True)
    part_type = Column(String, nullable=False)
    serial_number = Column(String, nullable=True, index=True)
    lot_number = Column(String, nullable=True)
    inventory_status = Column(String, nullable=False)
    allocated_to_order_id = Column(String, nullable=True)
    bound_to_unit_id = Column(String, nullable=True)
    released = Column(Boolean, nullable=False, default=False)
    release_reason_code = Column(String, nullable=True)
    source_system = Column(String, nullable=True)


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, unique=True, nullable=False, index=True)
    name = Column(String, nullable=False)
    role = Column(String, nullable=False)
    can_override = Column(Boolean, nullable=False, default=False)
    can_qc_signoff = Column(Boolean, nullable=False, default=False)
    can_waive_separation_of_duty = Column(Boolean, nullable=False, default=False)
    disposition_authority = Column(JSONB, nullable=False, default=list)


class ModelRecipe(Base):
    __tablename__ = "model_recipes"

    id = Column(Integer, primary_key=True, autoincrement=True)
    model_id = Column(String, unique=True, nullable=False, index=True)
    name = Column(String, nullable=True)
    description = Column(Text, nullable=True)
    payload = Column(JSONB, nullable=False, default=dict)


class ReferenceStandard(Base):
    __tablename__ = "reference_standards"

    id = Column(Integer, primary_key=True, autoincrement=True)
    ref_std_id = Column(String, unique=True, nullable=False, index=True)
    name = Column(String, nullable=False)
    status = Column(String, nullable=False)
    can_be_used_for_calibration = Column(Boolean, nullable=False, default=False)
    expiry_date = Column(String, nullable=True)
    payload = Column(JSONB, nullable=False, default=dict)


class Event(Base):
    __tablename__ = "events"

    id = Column(Integer, primary_key=True, autoincrement=True)
    event_id = Column(String, unique=True, nullable=False, index=True)
    unit_id = Column(String, nullable=True, index=True)
    order_id = Column(String, nullable=True)
    event_type = Column(String, nullable=False)
    stage_id = Column(String, nullable=True)
    actor_user_id = Column(String, nullable=True)
    timestamp = Column(String, nullable=False)
    message = Column(Text, nullable=False)
    severity = Column(String, nullable=False, default="info")
    payload = Column(JSONB, nullable=False, default=dict)
    source_refs = Column(JSONB, nullable=False, default=list)
