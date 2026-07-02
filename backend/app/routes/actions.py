from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app import state_store, workflow_rules
from app.db import get_db
from app.models import (
    ActionResponse,
    CalibrationDispositionRequest,
    CalibrationRequest,
    CloudBackupRequest,
    HardwareGateRequest,
    PackageRequest,
    QcSignoffRequest,
    ReallocatePartRequest,
    ResetStateResponse,
    ScanPartRequest,
    ShipRequest,
    TransitionRequest,
)

router = APIRouter()


@router.post("/factory/units/{unit_id}/actions/scan-part", response_model=ActionResponse)
async def action_scan_part(
    unit_id: str, req: ScanPartRequest, db: Session = Depends(get_db)
) -> ActionResponse:
    state = state_store.get_state(db)
    baseline = len(state["events"])
    result = workflow_rules.scan_part(state, unit_id, req)
    state_store.persist_action(db, state, unit_id, baseline)
    return result


@router.post("/factory/units/{unit_id}/actions/reallocate-part", response_model=ActionResponse)
async def action_reallocate_part(
    unit_id: str, req: ReallocatePartRequest, db: Session = Depends(get_db)
) -> ActionResponse:
    state = state_store.get_state(db)
    baseline = len(state["events"])
    result = workflow_rules.reallocate_part(state, unit_id, req)
    state_store.persist_action(db, state, unit_id, baseline)
    return result


@router.post("/factory/units/{unit_id}/actions/hardware-gate", response_model=ActionResponse)
async def action_hardware_gate(
    unit_id: str, req: HardwareGateRequest, db: Session = Depends(get_db)
) -> ActionResponse:
    state = state_store.get_state(db)
    baseline = len(state["events"])
    result = workflow_rules.record_hardware_gate(state, unit_id, req)
    state_store.persist_action(db, state, unit_id, baseline)
    return result


@router.post("/factory/units/{unit_id}/actions/calibration", response_model=ActionResponse)
async def action_calibration(
    unit_id: str, req: CalibrationRequest, db: Session = Depends(get_db)
) -> ActionResponse:
    state = state_store.get_state(db)
    baseline = len(state["events"])
    result = workflow_rules.record_calibration(state, unit_id, req)
    state_store.persist_action(db, state, unit_id, baseline)
    return result


@router.post(
    "/factory/units/{unit_id}/actions/calibration-disposition",
    response_model=ActionResponse,
)
async def action_calibration_disposition(
    unit_id: str, req: CalibrationDispositionRequest, db: Session = Depends(get_db)
) -> ActionResponse:
    state = state_store.get_state(db)
    baseline = len(state["events"])
    result = workflow_rules.record_calibration_disposition(state, unit_id, req)
    state_store.persist_action(db, state, unit_id, baseline)
    return result


@router.post("/factory/units/{unit_id}/actions/qc-signoff", response_model=ActionResponse)
async def action_qc_signoff(
    unit_id: str, req: QcSignoffRequest, db: Session = Depends(get_db)
) -> ActionResponse:
    state = state_store.get_state(db)
    baseline = len(state["events"])
    result = workflow_rules.qc_signoff(state, unit_id, req)
    state_store.persist_action(db, state, unit_id, baseline)
    return result


@router.post("/factory/units/{unit_id}/actions/cloud-backup", response_model=ActionResponse)
async def action_cloud_backup(
    unit_id: str, req: CloudBackupRequest, db: Session = Depends(get_db)
) -> ActionResponse:
    state = state_store.get_state(db)
    baseline = len(state["events"])
    result = workflow_rules.record_cloud_backup(state, unit_id, req)
    state_store.persist_action(db, state, unit_id, baseline)
    return result


@router.post("/factory/units/{unit_id}/actions/package", response_model=ActionResponse)
async def action_package(
    unit_id: str, req: PackageRequest, db: Session = Depends(get_db)
) -> ActionResponse:
    state = state_store.get_state(db)
    baseline = len(state["events"])
    result = workflow_rules.package_unit(state, unit_id, req)
    state_store.persist_action(db, state, unit_id, baseline)
    return result


@router.post("/factory/units/{unit_id}/actions/ship", response_model=ActionResponse)
async def action_ship(
    unit_id: str, req: ShipRequest, db: Session = Depends(get_db)
) -> ActionResponse:
    state = state_store.get_state(db)
    baseline = len(state["events"])
    result = workflow_rules.ship_unit(state, unit_id, req)
    state_store.persist_action(db, state, unit_id, baseline)
    return result


@router.post("/factory/units/{unit_id}/actions/transition", response_model=ActionResponse)
async def action_transition(
    unit_id: str, req: TransitionRequest, db: Session = Depends(get_db)
) -> ActionResponse:
    state = state_store.get_state(db)
    baseline = len(state["events"])
    result = workflow_rules.transition_stage(state, unit_id, req)
    state_store.persist_action(db, state, unit_id, baseline)
    return result


@router.post("/factory/dev/reset-state", response_model=ResetStateResponse)
async def dev_reset_state(db: Session = Depends(get_db)) -> ResetStateResponse:
    state_store.reset_state(db)
    return ResetStateResponse(
        status="ok",
        message="State reset from seed JSON. DB reseeded.",
    )
