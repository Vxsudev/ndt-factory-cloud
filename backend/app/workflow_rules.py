"""
Workflow rules — D5 Backend State Behavior.

All domain logic lives here. Routes call these functions.
No business rules are scattered in route handlers.
"""
from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

from fastapi import HTTPException

from app import state_store
from app.models import (
    ActionResponse,
    CalibrationDispositionRequest,
    CalibrationRequest,
    CloudBackupRequest,
    HardwareGateRequest,
    PackageRequest,
    QcSignoffRequest,
    ReallocatePartRequest,
    ScanPartRequest,
    ShipRequest,
    TransitionRequest,
)

STAGE_SEQUENCE = [
    "STAGE-01", "STAGE-02", "STAGE-03", "STAGE-04", "STAGE-05",
    "STAGE-06", "STAGE-07", "STAGE-08", "STAGE-09", "STAGE-10",
    "STAGE-11", "STAGE-12", "STAGE-13", "STAGE-14",
]

STAGE_NUMBER = {s: i + 1 for i, s in enumerate(STAGE_SEQUENCE)}


def _now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def _require_unit(state: dict[str, Any], unit_id: str) -> dict[str, Any]:
    unit = state["units"].get(unit_id)
    if unit is None:
        raise HTTPException(status_code=404, detail=f"Unit '{unit_id}' not found")
    return unit


def _is_terminal(unit: dict[str, Any]) -> bool:
    return bool(
        unit["package_ship_status"].get("terminal")
        or unit["current_status"] in ("shipped", "rejected", "scrapped")
    )


def _blocked_response(unit: dict[str, Any], message: str,
                      blocked_reason: str, event_id: str | None = None,
                      no_override: bool | None = None) -> ActionResponse:
    return ActionResponse(
        status="blocked",
        unit_id=unit["id"],
        current_stage_id=unit["current_stage_id"],
        current_status=unit["current_status"],
        message=message,
        event_id=event_id,
        blocked_reason=blocked_reason,
        no_override=no_override,
    )


def _success_response(unit: dict[str, Any], message: str,
                      event_id: str | None = None) -> ActionResponse:
    return ActionResponse(
        status="success",
        unit_id=unit["id"],
        current_stage_id=unit["current_stage_id"],
        current_status=unit["current_status"],
        message=message,
        event_id=event_id,
    )


def _make_event(
    state: dict[str, Any],
    unit: dict[str, Any],
    event_type: str,
    message: str,
    severity: str = "info",
    actor_user_id: str | None = None,
    payload: dict[str, Any] | None = None,
) -> dict[str, Any]:
    return {
        "id": state_store.next_event_id(state),
        "unit_id": unit["id"],
        "order_id": unit.get("order_id"),
        "event_type": event_type,
        "stage_id": unit["current_stage_id"],
        "actor_user_id": actor_user_id,
        "timestamp": _now(),
        "message": message,
        "severity": severity,
        "payload": payload or {},
        "source_refs": [],
    }


# ── scan_part ─────────────────────────────────────────────────────────────────

def scan_part(state: dict[str, Any], unit_id: str,
              req: ScanPartRequest) -> ActionResponse:
    unit = _require_unit(state, unit_id)

    if _is_terminal(unit):
        raise HTTPException(status_code=409,
                            detail=f"Unit {unit_id} is in terminal state; record is immutable.")

    if unit["current_stage_id"] != "STAGE-05":
        return _blocked_response(
            unit,
            f"Assembly scan requires STAGE-05; unit is at {unit['current_stage_id']}.",
            "wrong_stage",
        )

    def _scan_reject(reason: str, msg: str, payload: dict[str, Any]) -> ActionResponse:
        ev = _make_event(state, unit, "assembly_scan_rejected", msg,
                         severity="warning", actor_user_id=req.actor_user_id,
                         payload={**payload, "reason": reason})
        state_store.append_event(state, ev)
        return _blocked_response(unit, msg, reason, event_id=ev["id"])

    # Lookup serial in inventory
    part_id = state["parts_by_serial"].get(req.serial_number)
    if part_id is None:
        return _scan_reject(
            "unknown_serial",
            f"Assembly hard-stop: unknown serial '{req.serial_number}'.",
            {"serial_number": req.serial_number, "part_type": req.part_type},
        )

    part = state["parts"][part_id]

    # Part type must match
    if part["part_type"] != req.part_type:
        return _scan_reject(
            "wrong_part_type",
            f"Assembly hard-stop: part type mismatch — scanned {req.part_type}, "
            f"serial belongs to {part['part_type']}.",
            {"serial_number": req.serial_number,
             "scanned_type": req.part_type, "actual_type": part["part_type"]},
        )

    # Already bound to a different unit
    bound_to = part.get("bound_to_unit_id")
    if bound_to and bound_to != unit_id:
        return _scan_reject(
            "already_used_serial",
            f"Assembly hard-stop: serial '{req.serial_number}' already bound to unit {bound_to}.",
            {"serial_number": req.serial_number, "bound_to": bound_to},
        )

    # Part type slot must exist in this unit's allocations
    alloc = unit["part_allocations"].get(req.part_type)
    if alloc is None:
        return _scan_reject(
            "wrong_part_type",
            f"Assembly hard-stop: part type {req.part_type} not allocated for unit {unit_id}.",
            {"serial_number": req.serial_number, "part_type": req.part_type},
        )

    # The allocated part_id must match
    if alloc.get("part_id") != part_id:
        return _scan_reject(
            "wrong_serial_for_allocated_slot",
            f"Assembly hard-stop: serial '{req.serial_number}' is not the allocated "
            f"{req.part_type} for this unit.",
            {"serial_number": req.serial_number, "allocated_part_id": alloc.get("part_id")},
        )

    # Slot already bound
    if alloc["status"] == "allocated_bound":
        return _scan_reject(
            "already_used_serial",
            f"Assembly hard-stop: {req.part_type} slot already bound.",
            {"serial_number": req.serial_number, "part_type": req.part_type},
        )

    # Bind
    alloc["status"] = "allocated_bound"
    alloc["bound_at"] = _now()
    if part_id not in unit["genealogy"]["parts_bound"]:
        unit["genealogy"]["parts_bound"].append(part_id)
    part["inventory_status"] = "allocated_bound"
    part["bound_to_unit_id"] = unit_id
    unit.setdefault("assembly_operator_id", req.actor_user_id)
    unit["assigned_operator_id"] = req.actor_user_id
    if req.station_id:
        unit["station_id"] = req.station_id

    ev = _make_event(state, unit, "assembly_scan_accepted",
                     f"Part '{req.serial_number}' ({req.part_type}) bound to {unit_id}.",
                     actor_user_id=req.actor_user_id,
                     payload={"serial_number": req.serial_number,
                               "part_type": req.part_type, "part_id": part_id})
    state_store.append_event(state, ev)
    return _success_response(unit,
                             f"Part '{req.serial_number}' ({req.part_type}) bound successfully.",
                             event_id=ev["id"])


# ── reallocate_part ───────────────────────────────────────────────────────────

def reallocate_part(state: dict[str, Any], unit_id: str,
                    req: ReallocatePartRequest) -> ActionResponse:
    unit = _require_unit(state, unit_id)

    if _is_terminal(unit):
        raise HTTPException(status_code=409,
                            detail=f"Unit {unit_id} is in terminal state; record is immutable.")

    user = state["users"].get(req.actor_user_id)
    if not user or not user.get("can_override"):
        return ActionResponse(
            status="failed",
            unit_id=unit_id,
            current_stage_id=unit["current_stage_id"],
            current_status=unit["current_status"],
            message=f"Actor {req.actor_user_id} does not have supervisor authority for reallocation.",
            event_id=None,
            blocked_reason="insufficient_authority",
        )

    # Find old part by serial
    old_part_id = state["parts_by_serial"].get(req.old_serial_number)
    if old_part_id is None:
        raise HTTPException(status_code=422,
                            detail=f"Old serial '{req.old_serial_number}' not found in inventory.")

    old_part = state["parts"][old_part_id]
    if old_part.get("bound_to_unit_id") != unit_id and \
       old_part.get("allocated_to_order_id") != unit.get("order_id"):
        raise HTTPException(status_code=422,
                            detail=f"Serial '{req.old_serial_number}' is not allocated to unit {unit_id}.")

    part_type = old_part["part_type"]

    # Verify part type matches request
    if part_type != req.part_type:
        raise HTTPException(status_code=422,
                            detail=f"Part type mismatch: old serial is {part_type}, request says {req.part_type}.")

    # Find or create new part record
    new_part_id = state["parts_by_serial"].get(req.new_serial_number)
    if new_part_id is None:
        # Create a new part record for the replacement (mock/D5 behavior)
        new_part_id = f"PART-REALLOC-{state['event_counter'] + 1:04d}"
        new_part: dict[str, Any] = {
            "id": new_part_id,
            "part_type": part_type,
            "serial_number": req.new_serial_number,
            "lot_number": None,
            "inventory_status": "allocated_bound",
            "allocated_to_order_id": unit.get("order_id"),
            "bound_to_unit_id": unit_id,
            "released": False,
            "release_reason_code": None,
            "source_system": "supervisor_reallocation",
        }
        state["parts"][new_part_id] = new_part
        state["parts_by_serial"][req.new_serial_number] = new_part_id
    else:
        new_part = state["parts"][new_part_id]

    # Release old part
    old_part["inventory_status"] = "released"
    old_part["released"] = True
    old_part["release_reason_code"] = req.release_reason_code
    if old_part.get("bound_to_unit_id") == unit_id:
        old_part["bound_to_unit_id"] = None

    # Update allocation slot
    alloc = unit["part_allocations"].get(part_type)
    if alloc:
        alloc["part_id"] = new_part_id
        alloc["status"] = "allocated_bound"
        alloc["bound_at"] = _now()
        alloc["reallocated_from"] = old_part_id
    else:
        unit["part_allocations"][part_type] = {
            "part_id": new_part_id,
            "status": "allocated_bound",
            "bound_at": _now(),
            "reallocated_from": old_part_id,
        }

    # Update genealogy — keep old part in history
    genealogy = unit["genealogy"]
    if old_part_id in genealogy.get("parts_bound", []):
        genealogy["parts_bound"].remove(old_part_id)
    if new_part_id not in genealogy.get("parts_bound", []):
        genealogy.setdefault("parts_bound", []).append(new_part_id)
    genealogy.setdefault("reallocation_history", []).append({
        "at": _now(),
        "actor": req.actor_user_id,
        "part_type": part_type,
        "old_serial": req.old_serial_number,
        "new_serial": req.new_serial_number,
        "reason": req.reason,
        "release_reason_code": req.release_reason_code,
    })

    # Bind new part
    new_part["inventory_status"] = "allocated_bound"
    new_part["bound_to_unit_id"] = unit_id
    new_part["allocated_to_order_id"] = unit.get("order_id")

    ev = _make_event(state, unit, "supervisor_reallocation",
                     f"Supervisor reallocated {part_type}: "
                     f"'{req.old_serial_number}' → '{req.new_serial_number}'.",
                     severity="info", actor_user_id=req.actor_user_id,
                     payload={
                         "part_type": part_type,
                         "old_serial": req.old_serial_number,
                         "new_serial": req.new_serial_number,
                         "reason": req.reason,
                         "release_reason_code": req.release_reason_code,
                     })
    state_store.append_event(state, ev)
    return _success_response(unit,
                             f"Reallocation complete: {part_type} replaced "
                             f"'{req.old_serial_number}' → '{req.new_serial_number}'.",
                             event_id=ev["id"])


# ── record_hardware_gate ──────────────────────────────────────────────────────

def record_hardware_gate(state: dict[str, Any], unit_id: str,
                         req: HardwareGateRequest) -> ActionResponse:
    unit = _require_unit(state, unit_id)

    if _is_terminal(unit):
        raise HTTPException(status_code=409,
                            detail=f"Unit {unit_id} is in terminal state.")

    if unit["current_stage_id"] != "STAGE-09":
        return _blocked_response(
            unit,
            f"Hardware gate requires STAGE-09; unit is at {unit['current_stage_id']}.",
            "wrong_stage",
        )

    if req.result not in ("pass", "fail"):
        raise HTTPException(status_code=422, detail="result must be 'pass' or 'fail'.")

    unit["gate_results"]["STAGE-09"] = {
        "result": req.result,
        "passed_at": _now() if req.result == "pass" else None,
        "operator": req.actor_user_id,
        "checks": req.checks,
        "reason": req.reason,
    }

    if req.result == "pass":
        unit["current_status"] = "hw_gate_passed"
        unit["current_stage_id"] = "STAGE-10"
        unit["current_stage_number"] = 10
        unit["genealogy"]["hw_gate_passed_at"] = _now()
        ev = _make_event(state, unit, "hardware_gate_passed",
                         "Hardware gate (STAGE-09) passed; advancing to calibration.",
                         actor_user_id=req.actor_user_id,
                         payload={"checks": req.checks})
        state_store.append_event(state, ev)
        return _success_response(unit,
                                 "Hardware gate passed. Unit advanced to calibration (STAGE-10).",
                                 event_id=ev["id"])
    else:
        unit["current_status"] = "hardware_rework_required"
        unit["blocked_reason"] = req.reason or "hardware_gate_failed"
        ev = _make_event(state, unit, "hardware_gate_failed",
                         f"Hardware gate (STAGE-09) failed: {req.reason or 'no reason given'}.",
                         severity="warning", actor_user_id=req.actor_user_id,
                         payload={"reason": req.reason, "checks": req.checks})
        state_store.append_event(state, ev)
        return _blocked_response(unit,
                                 f"Hardware gate failed: {req.reason or 'rework required'}.",
                                 "hardware_gate_failed",
                                 event_id=ev["id"])


# ── record_calibration ────────────────────────────────────────────────────────

def record_calibration(state: dict[str, Any], unit_id: str,
                       req: CalibrationRequest) -> ActionResponse:
    unit = _require_unit(state, unit_id)

    if _is_terminal(unit):
        raise HTTPException(status_code=409,
                            detail=f"Unit {unit_id} is in terminal state.")

    if unit["current_stage_id"] != "STAGE-10":
        return _blocked_response(
            unit,
            f"Calibration requires STAGE-10; unit is at {unit['current_stage_id']}.",
            "wrong_stage",
        )

    cal = unit["calibration_summary"]

    # Cap exceeded check
    if cal.get("cap_exceeded"):
        return _blocked_response(
            unit,
            "Calibration cap exceeded (3/3 attempts). Supervisor disposition required.",
            "calibration_cap_exceeded_supervisor_disposition_required",
        )

    # Validate every reference standard
    for ref_id in req.reference_standard_ids:
        ref_std = state["reference_standards"].get(ref_id)
        if ref_std is None:
            ev = _make_event(state, unit, "calibration_ref_std_hardstop",
                             f"Unknown reference standard '{ref_id}'.",
                             severity="error", actor_user_id=req.actor_user_id,
                             payload={"reference_standard_id": ref_id})
            state_store.append_event(state, ev)
            return _blocked_response(
                unit,
                f"Calibration hard-stop: reference standard '{ref_id}' not found. No override.",
                "invalid_reference_standard",
                event_id=ev["id"],
                no_override=True,
            )
        if not ref_std.get("can_be_used_for_calibration"):
            ev = _make_event(state, unit, "calibration_ref_std_hardstop",
                             f"Reference standard '{ref_id}' cannot be used: {ref_std.get('status')}.",
                             severity="error", actor_user_id=req.actor_user_id,
                             payload={"reference_standard_id": ref_id,
                                       "status": ref_std.get("status")})
            state_store.append_event(state, ev)
            return _blocked_response(
                unit,
                f"Calibration hard-stop: reference standard '{ref_id}' is {ref_std.get('status')}. No override.",
                f"reference_standard_{ref_std.get('status')}",
                event_id=ev["id"],
                no_override=True,
            )

    if req.result not in ("pass", "fail"):
        raise HTTPException(status_code=422, detail="result must be 'pass' or 'fail'.")

    attempt_number = cal.get("attempts", 0) + 1
    attempt_record: dict[str, Any] = {
        "attempt": attempt_number,
        "result": req.result,
        "at": _now(),
        "operator": req.actor_user_id,
        "ref_std_used": req.reference_standard_ids,
        "equipment_id": req.equipment_id,
    }
    if req.raw_readings is not None:
        attempt_record["raw_readings"] = req.raw_readings
    if req.coefficients is not None:
        attempt_record["coefficients"] = req.coefficients
    if req.environmental_conditions is not None:
        attempt_record["environmental_conditions"] = req.environmental_conditions

    cal.setdefault("attempt_history", []).append(attempt_record)
    cal["attempts"] = attempt_number
    cal["last_result"] = req.result

    if req.result == "pass":
        cert_id = f"CERT-D5-{unit_id}-ATT{attempt_number}"
        cal["passed"] = True
        cal["passed_at"] = _now()
        cal["certificate_id"] = cert_id
        unit["gate_results"]["STAGE-10"] = {
            "result": "pass",
            "passed_at": _now(),
            "operator": req.actor_user_id,
        }
        unit["current_status"] = "calibration_passed"
        unit["current_stage_id"] = "STAGE-11"
        unit["current_stage_number"] = 11
        unit["genealogy"]["calibration_passed_at"] = _now()
        ev = _make_event(state, unit, "calibration_passed",
                         f"Calibration passed on attempt {attempt_number}. Certificate: {cert_id}.",
                         actor_user_id=req.actor_user_id,
                         payload={"attempt": attempt_number, "certificate_id": cert_id})
        state_store.append_event(state, ev)
        return _success_response(unit,
                                 f"Calibration passed (attempt {attempt_number}/{cal['max_attempts']}). "
                                 f"Certificate {cert_id} issued. Unit advanced to QC (STAGE-11).",
                                 event_id=ev["id"])

    # Fail path
    cal["last_result"] = "fail"
    if attempt_number >= cal.get("max_attempts", 3):
        cal["cap_exceeded"] = True
        cal["disposition_required_at"] = _now()
        unit["current_status"] = "calibration_cap_exceeded_awaiting_disposition"
        unit["blocked_reason"] = "calibration_cap_exceeded_supervisor_disposition_required"
        unit["block_type"] = "calibration_retry_cap"
        ev = _make_event(state, unit, "calibration_cap_exceeded",
                         f"Calibration failed on attempt {attempt_number}/{cal['max_attempts']}. "
                         "Cap exceeded. Supervisor disposition required.",
                         severity="error", actor_user_id=req.actor_user_id,
                         payload={"attempt": attempt_number})
        state_store.append_event(state, ev)
        return _blocked_response(
            unit,
            f"Calibration cap exceeded (3/3 attempts). Supervisor disposition required.",
            "calibration_cap_exceeded_supervisor_disposition_required",
            event_id=ev["id"],
        )
    else:
        remaining = cal["max_attempts"] - attempt_number
        ev = _make_event(state, unit, "calibration_attempt_failed",
                         f"Calibration failed on attempt {attempt_number}. "
                         f"{remaining} attempt(s) remaining.",
                         severity="warning", actor_user_id=req.actor_user_id,
                         payload={"attempt": attempt_number, "remaining": remaining})
        state_store.append_event(state, ev)
        return _blocked_response(
            unit,
            f"Calibration attempt {attempt_number} failed. {remaining} attempt(s) remaining.",
            "calibration_attempt_failed",
            event_id=ev["id"],
        )


# ── record_calibration_disposition ───────────────────────────────────────────

def record_calibration_disposition(state: dict[str, Any], unit_id: str,
                                   req: CalibrationDispositionRequest) -> ActionResponse:
    unit = _require_unit(state, unit_id)

    if _is_terminal(unit):
        raise HTTPException(status_code=409,
                            detail=f"Unit {unit_id} is in terminal state.")

    if not unit["calibration_summary"].get("cap_exceeded"):
        return _blocked_response(
            unit,
            "Calibration disposition is only valid when cap_exceeded is true.",
            "calibration_cap_not_exceeded",
        )

    user = state["users"].get(req.actor_user_id)
    if not user:
        raise HTTPException(status_code=403, detail=f"Unknown actor '{req.actor_user_id}'.")

    valid_dispositions = user.get("disposition_authority", [])
    disposition_map = {
        "route_back_to_hardware": ["route_to_hardware_rework", "route_back_to_stage_9"],
        "scrap": ["scrap"],
        "quarantine": ["quarantine"],
    }

    allowed = disposition_map.get(req.disposition, [req.disposition])
    if not any(a in valid_dispositions for a in allowed):
        raise HTTPException(
            status_code=403,
            detail=f"Actor {req.actor_user_id} does not have authority for disposition '{req.disposition}'.",
        )

    cal = unit["calibration_summary"]
    cal["dispositioned_by"] = req.actor_user_id
    cal["disposition"] = req.disposition
    cal["disposition_reason"] = req.reason
    cal["disposition_at"] = _now()

    if req.disposition == "route_back_to_hardware":
        # Reset calibration state and route back to STAGE-09
        cal["cap_exceeded"] = False
        cal["attempts"] = 0
        cal["attempt_history"] = []
        cal["last_result"] = None
        cal["passed"] = False
        unit["current_stage_id"] = "STAGE-09"
        unit["current_stage_number"] = 9
        unit["current_status"] = "routed_back_to_hardware"
        unit["blocked_reason"] = None
        unit["block_type"] = None
        # Clear STAGE-09 and STAGE-10 gate results
        unit["gate_results"].pop("STAGE-09", None)
        unit["gate_results"].pop("STAGE-10", None)
        ev = _make_event(state, unit, "calibration_disposition_rework",
                         f"Supervisor disposition: route back to hardware (STAGE-09). Reason: {req.reason}.",
                         actor_user_id=req.actor_user_id,
                         payload={"disposition": req.disposition, "reason": req.reason})
        state_store.append_event(state, ev)
        return _success_response(unit,
                                 "Unit routed back to hardware checks (STAGE-09). "
                                 "Calibration attempt counter reset.",
                                 event_id=ev["id"])

    elif req.disposition == "scrap":
        unit["current_status"] = "scrapped"
        unit["package_ship_status"]["terminal"] = True
        unit["blocked_reason"] = f"scrapped_after_calibration_cap: {req.reason}"
        ev = _make_event(state, unit, "unit_scrapped",
                         f"Unit scrapped by {req.actor_user_id}. Reason: {req.reason}.",
                         severity="error", actor_user_id=req.actor_user_id,
                         payload={"disposition": "scrap", "reason": req.reason})
        state_store.append_event(state, ev)
        return _success_response(unit, f"Unit scrapped. Record is now immutable.",
                                 event_id=ev["id"])

    else:  # quarantine
        unit["current_status"] = "quarantined"
        unit["blocked_reason"] = f"quarantined: {req.reason}"
        ev = _make_event(state, unit, "unit_quarantined",
                         f"Unit quarantined. Reason: {req.reason}.",
                         severity="warning", actor_user_id=req.actor_user_id,
                         payload={"disposition": "quarantine", "reason": req.reason})
        state_store.append_event(state, ev)
        return _blocked_response(unit,
                                 f"Unit quarantined pending supervisor review.",
                                 "quarantined",
                                 event_id=ev["id"])


# ── qc_signoff ────────────────────────────────────────────────────────────────

def qc_signoff(state: dict[str, Any], unit_id: str,
               req: QcSignoffRequest) -> ActionResponse:
    unit = _require_unit(state, unit_id)

    if _is_terminal(unit):
        raise HTTPException(status_code=409,
                            detail=f"Unit {unit_id} is in terminal state.")

    if unit["current_stage_id"] != "STAGE-11":
        return _blocked_response(
            unit,
            f"QC sign-off requires STAGE-11; unit is at {unit['current_stage_id']}.",
            "wrong_stage",
        )

    user = state["users"].get(req.actor_user_id)
    if not user:
        raise HTTPException(status_code=403, detail=f"Unknown actor '{req.actor_user_id}'.")
    if not user.get("can_qc_signoff"):
        raise HTTPException(
            status_code=403,
            detail=f"Actor {req.actor_user_id} does not have QC sign-off authority.",
        )

    # Prerequisite: hardware gate passed
    hw_gate = unit["gate_results"].get("STAGE-09", {})
    if hw_gate.get("result") != "pass":
        return _blocked_response(unit,
                                 "QC blocked: hardware gate (STAGE-09) not passed.",
                                 "prerequisite_hw_gate_not_passed")

    # Prerequisite: calibration gate passed and certificate present
    cal_gate = unit["gate_results"].get("STAGE-10", {})
    if cal_gate.get("result") != "pass":
        return _blocked_response(unit,
                                 "QC blocked: calibration gate (STAGE-10) not passed.",
                                 "prerequisite_calibration_gate_not_passed")

    cal = unit["calibration_summary"]
    if not cal.get("passed") or not cal.get("certificate_id"):
        return _blocked_response(unit,
                                 "QC blocked: calibration certificate not present.",
                                 "prerequisite_calibration_certificate_missing")

    # Separation-of-duty check
    assembly_op = unit.get("assembly_operator_id") or \
        unit["genealogy"].get("assembly_operator_id")
    cal_op = cal_gate.get("operator")
    signer = req.actor_user_id

    sod_violated = (signer == assembly_op and assembly_op is not None) or \
                   (signer == cal_op and cal_op is not None)

    if sod_violated:
        if not req.waiver_actor_user_id:
            return _blocked_response(
                unit,
                f"QC blocked: separation-of-duty violation — signer {signer} performed "
                f"assembly or calibration on this unit. Manager waiver required.",
                "separation_of_duty_violation",
            )
        waiver_user = state["users"].get(req.waiver_actor_user_id)
        if not waiver_user or not waiver_user.get("can_waive_separation_of_duty"):
            raise HTTPException(
                status_code=403,
                detail=f"Waiver actor {req.waiver_actor_user_id} cannot waive separation-of-duty.",
            )

    # Sign off
    now = _now()
    unit["qc_summary"]["signed_off"] = True
    unit["qc_summary"]["signed_by"] = signer
    unit["qc_summary"]["signed_at"] = now
    if req.waiver_actor_user_id:
        unit["qc_summary"]["waiver_by"] = req.waiver_actor_user_id
        unit["qc_summary"]["waiver_reason"] = req.waiver_reason

    unit["gate_results"]["STAGE-11"] = {
        "result": "pass",
        "passed_at": now,
        "signed_by": signer,
    }
    unit["genealogy"]["qc_signed_off_at"] = now
    unit["current_stage_id"] = "STAGE-12"
    unit["current_stage_number"] = 12
    unit["current_status"] = "qc_complete_backup_pending"
    unit["blocked_reason"] = None

    ev = _make_event(state, unit, "qc_signoff_complete",
                     f"QC sign-off complete by {signer}. Unit advanced to cloud backup (STAGE-12).",
                     actor_user_id=signer,
                     payload={"signed_by": signer,
                               "waiver": req.waiver_actor_user_id,
                               "checklist_items": len(req.checklist)})
    state_store.append_event(state, ev)
    return _success_response(unit,
                             "QC sign-off complete. Unit advanced to cloud backup (STAGE-12).",
                             event_id=ev["id"])


# ── record_cloud_backup ───────────────────────────────────────────────────────

def record_cloud_backup(state: dict[str, Any], unit_id: str,
                        req: CloudBackupRequest) -> ActionResponse:
    unit = _require_unit(state, unit_id)

    if _is_terminal(unit):
        raise HTTPException(status_code=409,
                            detail=f"Unit {unit_id} is in terminal state.")

    if unit["current_stage_id"] != "STAGE-12":
        return _blocked_response(
            unit,
            f"Cloud backup requires STAGE-12; unit is at {unit['current_stage_id']}.",
            "wrong_stage",
        )

    if not req.cloud_available:
        unit["blocked_reason"] = "cloud_backup_cannot_complete_connectivity_unavailable"
        unit["block_type"] = "hardstop_cloud_dependency"
        unit["no_override"] = True
        unit["current_status"] = "cloud_backup_blocked"
        unit["cloud_status"].setdefault("backup_block_raised_at", _now())
        ev = _make_event(state, unit, "cloud_backup_hard_stop",
                         "Cloud backup hard-stop: connectivity unavailable. No override.",
                         severity="error", actor_user_id=req.actor_user_id,
                         payload={"cloud_available": False})
        state_store.append_event(state, ev)
        return _blocked_response(
            unit,
            "Cloud backup hard-stop: connectivity unavailable. No override.",
            "cloud_backup_cannot_complete_connectivity_unavailable",
            event_id=ev["id"],
            no_override=True,
        )

    # Cloud available: confirm backup
    unit["cloud_status"]["backed_up"] = True
    unit["cloud_status"]["backed_up_at"] = _now()
    if req.backup_reference:
        unit["cloud_status"]["backup_reference"] = req.backup_reference
    unit["current_status"] = "backup_confirmed"
    unit["blocked_reason"] = None
    unit["block_type"] = None
    unit["no_override"] = False
    unit["current_stage_id"] = "STAGE-13"
    unit["current_stage_number"] = 13
    unit["genealogy"]["cloud_backup_confirmed_at"] = _now()
    ev = _make_event(state, unit, "cloud_backup_confirmed",
                     "Cloud backup confirmed. Unit advanced to packaging (STAGE-13).",
                     actor_user_id=req.actor_user_id,
                     payload={"backup_reference": req.backup_reference})
    state_store.append_event(state, ev)
    return _success_response(unit,
                             "Cloud backup confirmed. Unit advanced to packaging (STAGE-13).",
                             event_id=ev["id"])


# ── transition_stage ──────────────────────────────────────────────────────────

def transition_stage(state: dict[str, Any], unit_id: str,
                     req: TransitionRequest) -> ActionResponse:
    unit = _require_unit(state, unit_id)

    if _is_terminal(unit):
        raise HTTPException(
            status_code=409,
            detail=f"Unit {unit_id} is in terminal state ({unit['current_status']}). "
                   f"Record is immutable.",
        )

    if unit.get("blocked_reason") and unit.get("block_type"):
        return _blocked_response(
            unit,
            f"Unit has an active hard-stop: {unit['blocked_reason']}",
            unit["blocked_reason"],
            no_override=unit.get("no_override"),
        )

    current_idx = STAGE_SEQUENCE.index(unit["current_stage_id"]) \
        if unit["current_stage_id"] in STAGE_SEQUENCE else -1
    target_idx = STAGE_SEQUENCE.index(req.target_stage_id) \
        if req.target_stage_id in STAGE_SEQUENCE else -1

    if target_idx == -1:
        raise HTTPException(status_code=422,
                            detail=f"Unknown target stage '{req.target_stage_id}'.")

    if target_idx != current_idx + 1:
        raise HTTPException(
            status_code=409,
            detail=f"Illegal stage transition: {unit['current_stage_id']} → {req.target_stage_id}. "
                   f"Stages must advance one step at a time.",
        )

    unit["current_stage_id"] = req.target_stage_id
    unit["current_stage_number"] = STAGE_NUMBER[req.target_stage_id]
    unit["current_status"] = "active"

    ev = _make_event(state, unit, "stage_transition",
                     f"Stage advanced: {STAGE_SEQUENCE[current_idx]} → {req.target_stage_id}.",
                     actor_user_id=req.actor_user_id,
                     payload={"from_stage": STAGE_SEQUENCE[current_idx],
                               "to_stage": req.target_stage_id,
                               "reason": req.reason})
    state_store.append_event(state, ev)
    return _success_response(unit,
                             f"Unit advanced to {req.target_stage_id}.",
                             event_id=ev["id"])


# ── package_unit ──────────────────────────────────────────────────────────────

def package_unit(state: dict[str, Any], unit_id: str,
                 req: PackageRequest) -> ActionResponse:
    unit = _require_unit(state, unit_id)

    if _is_terminal(unit):
        raise HTTPException(status_code=409,
                            detail=f"Unit {unit_id} is in terminal state.")

    if unit["current_stage_id"] != "STAGE-13":
        return _blocked_response(
            unit,
            f"Package requires STAGE-13; unit is at {unit['current_stage_id']}.",
            "wrong_stage",
        )

    unit["package_ship_status"]["packaged"] = True
    unit["package_ship_status"]["packaged_at"] = _now()
    unit["current_status"] = "packaged"
    unit["current_stage_id"] = "STAGE-14"
    unit["current_stage_number"] = 14
    unit["genealogy"]["packaged_at"] = _now()

    ev = _make_event(state, unit, "unit_packaged",
                     "Unit packaged and advanced to STAGE-14 (ship).",
                     actor_user_id=req.actor_user_id)
    state_store.append_event(state, ev)
    return _success_response(unit, "Unit packaged. Advanced to STAGE-14 (ship).",
                             event_id=ev["id"])


# ── ship_unit ─────────────────────────────────────────────────────────────────

def ship_unit(state: dict[str, Any], unit_id: str,
              req: ShipRequest) -> ActionResponse:
    unit = _require_unit(state, unit_id)

    if _is_terminal(unit):
        raise HTTPException(status_code=409,
                            detail=f"Unit {unit_id} is already in terminal state.")

    if unit["current_stage_id"] != "STAGE-14":
        return _blocked_response(
            unit,
            f"Ship requires STAGE-14; unit is at {unit['current_stage_id']}.",
            "wrong_stage",
        )

    if not unit["qc_summary"].get("signed_off"):
        return _blocked_response(unit, "Ship blocked: QC not signed off.", "qc_not_passed")

    if not unit["cloud_status"].get("backed_up"):
        return _blocked_response(unit, "Ship blocked: cloud backup not confirmed.",
                                 "cloud_backup_not_confirmed")

    unit["current_status"] = "shipped"
    unit["package_ship_status"]["shipped"] = True
    unit["package_ship_status"]["shipped_at"] = _now()
    unit["package_ship_status"]["terminal"] = True
    unit["package_ship_status"]["immutable"] = True
    unit["genealogy"]["shipped_at"] = _now()

    ev = _make_event(state, unit, "unit_shipped",
                     "Unit shipped. Production record is now immutable.",
                     actor_user_id=req.actor_user_id,
                     payload={"document_refs": req.document_refs})
    state_store.append_event(state, ev)
    return _success_response(unit, "Unit shipped. Record is immutable.",
                             event_id=ev["id"])
