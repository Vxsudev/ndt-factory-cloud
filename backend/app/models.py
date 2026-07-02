from typing import Any
from pydantic import BaseModel


# ── D3 models ────────────────────────────────────────────────────────────────

class HealthResponse(BaseModel):
    status: str
    service: str
    phase: str


class ScaffoldStatusResponse(BaseModel):
    status: str
    domain_logic_enabled: bool
    stage_model_locked: bool
    current_phase: str


# ── D4 read models — data contract ───────────────────────────────────────────
# These mirror the JSON structure in data/*.json.
# All fields are read-only; no mutation logic in D4.

class StageRecord(BaseModel):
    id: str
    number: int
    name: str
    ownership: str
    stage_type: str
    is_gate: bool
    is_external: bool
    is_separable: bool
    requirements: list[str]
    normal_next_stage_id: str | None
    allowed_rework_stage_ids: list[str]
    hard_stop_controls: list[dict[str, Any]]
    authority_notes: str
    source_refs: list[str]


class OrderRecord(BaseModel):
    id: str
    source_system: str
    approval_status: str
    approved_by: str | None
    approved_at: str | None
    model_id: str
    quantity: int
    options: dict[str, Any]
    boundary_validation_status: str
    rejection_reason: str | None
    created_at: str
    unit_ids_provisioned: list[str]
    source_refs: list[str]


class FactoryUnitRecord(BaseModel):
    id: str
    order_id: str
    model_id: str
    genealogy_serial: str
    current_stage_id: str
    current_stage_number: int
    current_status: str
    blocked_reason: str | None
    block_type: str | None
    no_override: bool
    assigned_operator_id: str | None
    station_id: str | None
    part_allocations: dict[str, Any]
    genealogy: dict[str, Any]
    gate_results: dict[str, Any]
    calibration_summary: dict[str, Any]
    qc_summary: dict[str, Any]
    cloud_status: dict[str, Any]
    package_ship_status: dict[str, Any]
    event_ids: list[str]
    source_refs: list[str]


class PartRecord(BaseModel):
    id: str
    part_type: str
    serial_number: str
    lot_number: str | None
    inventory_status: str
    allocated_to_order_id: str | None
    bound_to_unit_id: str | None
    released: bool
    release_reason_code: str | None
    source_system: str
    note: str | None = None


class UserRecord(BaseModel):
    id: str
    name: str
    roles: list[str]
    authority_tier: str
    can_perform_stages: list[str]
    can_override: bool
    can_qc_signoff: bool
    can_waive_separation_of_duty: bool


class ModelRecipeRecord(BaseModel):
    id: str
    model_name: str
    required_part_types: list[str]
    hardware_checks: list[dict[str, Any]]
    calibration_profile: dict[str, Any]
    firmware_baseline: str
    active: bool
    source_refs: list[str]


class ReferenceStandardRecord(BaseModel):
    id: str
    standard_type: str
    certificate_id: str | None
    valid_until: str | None
    status: str
    can_be_used_for_calibration: bool
    note: str | None = None


class EventRecord(BaseModel):
    id: str
    unit_id: str | None
    order_id: str | None
    event_type: str
    stage_id: str | None
    actor_user_id: str | None
    timestamp: str
    message: str
    severity: str
    payload: dict[str, Any]
    source_refs: list[str]


class DataContractStatusResponse(BaseModel):
    status: str
    phase: str
    read_only: bool
    domain_logic_enabled: bool
    data_files_loaded: list[str]
    unit_count: int
    stage_count: int


# ── D5 request models ─────────────────────────────────────────────────────────

class ScanPartRequest(BaseModel):
    part_type: str
    serial_number: str
    actor_user_id: str
    station_id: str | None = None


class ReallocatePartRequest(BaseModel):
    part_type: str
    old_serial_number: str
    new_serial_number: str
    reason: str
    release_reason_code: str
    actor_user_id: str


class HardwareGateRequest(BaseModel):
    result: str  # "pass" | "fail"
    actor_user_id: str
    checks: list[dict[str, Any]] = []
    reason: str | None = None


class CalibrationRequest(BaseModel):
    result: str  # "pass" | "fail"
    actor_user_id: str
    reference_standard_ids: list[str]
    raw_readings: list[Any] | None = None
    coefficients: list[Any] | None = None
    equipment_id: str
    environmental_conditions: dict[str, Any] | None = None


class CalibrationDispositionRequest(BaseModel):
    disposition: str  # "route_back_to_hardware" | "scrap" | "quarantine"
    actor_user_id: str
    reason: str


class QcSignoffRequest(BaseModel):
    actor_user_id: str
    checklist: list[dict[str, Any]] = []
    waiver_actor_user_id: str | None = None
    waiver_reason: str | None = None


class CloudBackupRequest(BaseModel):
    cloud_available: bool
    actor_user_id: str
    backup_reference: str | None = None


class TransitionRequest(BaseModel):
    target_stage_id: str
    actor_user_id: str
    reason: str | None = None


class PackageRequest(BaseModel):
    actor_user_id: str


class ShipRequest(BaseModel):
    actor_user_id: str
    document_refs: list[str] | None = None


# ── D5 response model ─────────────────────────────────────────────────────────

class ActionResponse(BaseModel):
    status: str  # "success" | "blocked" | "failed"
    unit_id: str
    current_stage_id: str
    current_status: str
    message: str
    event_id: str | None = None
    blocked_reason: str | None = None
    no_override: bool | None = None


class ResetStateResponse(BaseModel):
    status: str
    message: str
