"""initial factory cloud schema

Revision ID: 001
Revises:
Create Date: 2026-06-30

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB

revision: str = "001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "stages",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("stage_id", sa.String(), unique=True, nullable=False),
        sa.Column("number", sa.Integer(), nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("stage_type", sa.String(), nullable=False),
        sa.Column("ownership", sa.String(), nullable=False),
        sa.Column("is_gate", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("is_external", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("is_separable", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("hard_stop_controls", JSONB(), nullable=False, server_default="[]"),
        sa.Column("authority_notes", sa.Text(), nullable=True),
        sa.Column("normal_next_stage_id", sa.String(), nullable=True),
    )
    op.create_index("ix_stages_stage_id", "stages", ["stage_id"])

    op.create_table(
        "orders",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("order_id", sa.String(), unique=True, nullable=False),
        sa.Column("model_id", sa.String(), nullable=True),
        sa.Column("customer_ref", sa.String(), nullable=True),
        sa.Column("order_date", sa.String(), nullable=True),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("payload", JSONB(), nullable=False, server_default="{}"),
    )
    op.create_index("ix_orders_order_id", "orders", ["order_id"])

    op.create_table(
        "factory_units",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("unit_id", sa.String(), unique=True, nullable=False),
        sa.Column("order_id", sa.String(), nullable=True),
        sa.Column("model_id", sa.String(), nullable=True),
        sa.Column("genealogy_serial", sa.String(), nullable=True),
        sa.Column("current_stage_id", sa.String(), nullable=False),
        sa.Column("current_stage_number", sa.Integer(), nullable=False),
        sa.Column("current_status", sa.String(), nullable=False),
        sa.Column("blocked_reason", sa.String(), nullable=True),
        sa.Column("block_type", sa.String(), nullable=True),
        sa.Column("no_override", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("payload", JSONB(), nullable=False, server_default="{}"),
    )
    op.create_index("ix_factory_units_unit_id", "factory_units", ["unit_id"])

    op.create_table(
        "parts",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("part_id", sa.String(), unique=True, nullable=False),
        sa.Column("part_type", sa.String(), nullable=False),
        sa.Column("serial_number", sa.String(), nullable=True),
        sa.Column("lot_number", sa.String(), nullable=True),
        sa.Column("inventory_status", sa.String(), nullable=False),
        sa.Column("allocated_to_order_id", sa.String(), nullable=True),
        sa.Column("bound_to_unit_id", sa.String(), nullable=True),
        sa.Column("released", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("release_reason_code", sa.String(), nullable=True),
        sa.Column("source_system", sa.String(), nullable=True),
    )
    op.create_index("ix_parts_part_id", "parts", ["part_id"])
    op.create_index("ix_parts_serial_number", "parts", ["serial_number"])

    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("user_id", sa.String(), unique=True, nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("role", sa.String(), nullable=False),
        sa.Column("can_override", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("can_qc_signoff", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("can_waive_separation_of_duty", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("disposition_authority", JSONB(), nullable=False, server_default="[]"),
    )
    op.create_index("ix_users_user_id", "users", ["user_id"])

    op.create_table(
        "model_recipes",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("model_id", sa.String(), unique=True, nullable=False),
        sa.Column("name", sa.String(), nullable=True),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("payload", JSONB(), nullable=False, server_default="{}"),
    )
    op.create_index("ix_model_recipes_model_id", "model_recipes", ["model_id"])

    op.create_table(
        "reference_standards",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("ref_std_id", sa.String(), unique=True, nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("status", sa.String(), nullable=False),
        sa.Column("can_be_used_for_calibration", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("expiry_date", sa.String(), nullable=True),
        sa.Column("payload", JSONB(), nullable=False, server_default="{}"),
    )
    op.create_index("ix_reference_standards_ref_std_id", "reference_standards", ["ref_std_id"])

    op.create_table(
        "events",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("event_id", sa.String(), unique=True, nullable=False),
        sa.Column("unit_id", sa.String(), nullable=True),
        sa.Column("order_id", sa.String(), nullable=True),
        sa.Column("event_type", sa.String(), nullable=False),
        sa.Column("stage_id", sa.String(), nullable=True),
        sa.Column("actor_user_id", sa.String(), nullable=True),
        sa.Column("timestamp", sa.String(), nullable=False),
        sa.Column("message", sa.Text(), nullable=False),
        sa.Column("severity", sa.String(), nullable=False, server_default="'info'"),
        sa.Column("payload", JSONB(), nullable=False, server_default="{}"),
        sa.Column("source_refs", JSONB(), nullable=False, server_default="[]"),
    )
    op.create_index("ix_events_event_id", "events", ["event_id"])
    op.create_index("ix_events_unit_id", "events", ["unit_id"])


def downgrade() -> None:
    op.drop_table("events")
    op.drop_table("reference_standards")
    op.drop_table("model_recipes")
    op.drop_table("users")
    op.drop_table("parts")
    op.drop_table("factory_units")
    op.drop_table("orders")
    op.drop_table("stages")
