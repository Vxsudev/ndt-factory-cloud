// Factory Cloud v0 — D6 TypeScript types
// Shapes mirror backend Pydantic models exactly. No `any`.

export interface HealthResponse {
  status: string
  service: string
  phase: string
}

export interface DataContractStatus {
  status: string
  phase: string
  stage_count: number
  unit_count: number
  [key: string]: unknown
}

export interface HardStopControl {
  type: string
  trigger: string
  action: string
  no_override: boolean
}

export interface FactoryStage {
  id: string
  number: number
  name: string
  stage_type: string
  ownership: string
  is_gate: boolean
  is_external: boolean
  is_separable: boolean
  hard_stop_controls: HardStopControl[]
  authority_notes: string
  normal_next_stage_id: string | null
}

export interface PartAllocation {
  part_id: string
  status: string
  bound_at?: string
}

export interface CalibrationSummary {
  attempts: number
  max_attempts: number
  last_result: string | null
  passed: boolean
  certificate_id?: string | null
  cap_exceeded?: boolean
  attempt_history?: unknown[]
}

export interface QcSummary {
  signed_off: boolean
  signed_by: string | null
  signed_at: string | null
}

export interface CloudStatus {
  sw_update_done: boolean
  provisioned: boolean
  backed_up: boolean
}

export interface PackageShipStatus {
  packaged: boolean
  shipped: boolean
  terminal: boolean
}

export interface Genealogy {
  parts_bound: string[]
  parts_allocated: string[]
  build_started_at?: string
  reallocation_history?: unknown[]
}

export interface FactoryUnit {
  id: string
  order_id: string
  model_id: string
  genealogy_serial: string
  current_stage_id: string
  current_stage_number: number
  current_status: string
  blocked_reason: string | null
  block_type: string | null
  no_override: boolean
  assigned_operator_id: string | null
  station_id: string | null
  assembly_operator_id?: string | null
  part_allocations: Record<string, PartAllocation>
  genealogy: Genealogy
  gate_results: Record<string, unknown>
  calibration_status?: {
    attempts: number
    max_attempts: number
    passed: boolean
    certificate_id: string | null
    cap_exceeded: boolean
    attempt_history: unknown[]
    hardware_gate_passed?: boolean
  }
  calibration_summary: CalibrationSummary
  qc_summary: QcSummary
  cloud_status: CloudStatus
  package_ship_status: PackageShipStatus
  event_ids: string[]
}

export interface FactoryEvent {
  id: string
  unit_id: string | null
  event_type: string
  stage_id: string | null
  actor_user_id: string | null
  message: string
  severity: string
  timestamp: string
  payload?: Record<string, unknown>
}

export interface FactoryUser {
  id: string
  name: string
  roles: string[]
  authority_tier: string
  can_override: boolean
  can_qc_signoff: boolean
  can_waive_separation_of_duty?: boolean
  can_perform_stages?: string[]
}

export interface FactoryPart {
  id: string
  serial_number: string
  part_type: string
  current_status: string
  allocated_to_unit_id?: string | null
}

export interface FactoryRefStd {
  id: string
  standard_type: string
  can_be_used_for_calibration: boolean
  status_label?: string
  certificate_id?: string | null
  expiry_date?: string | null
}

export interface ActionResponse {
  status: string
  unit_id: string
  current_stage_id: string
  current_status: string
  message: string
  event_id: string | null
  blocked_reason: string | null
  no_override: boolean | null
}

export interface ResetStateResponse {
  status: string
  message: string
}

// Request shapes for action endpoints
export interface ScanPartRequest {
  part_type: string
  serial_number: string
  actor_user_id: string
  station_id?: string
}

export interface ReallocatePartRequest {
  part_type: string
  old_serial_number: string
  new_serial_number: string
  reason: string
  release_reason_code: string
  actor_user_id: string
}

export interface HardwareGateRequest {
  result: 'pass' | 'fail'
  actor_user_id: string
  reason?: string
}

export interface CalibrationRequest {
  result: 'pass' | 'fail'
  actor_user_id: string
  reference_standard_ids: string[]
  equipment_id: string
  raw_readings?: unknown[]
  coefficients?: unknown[]
  environmental_conditions?: Record<string, unknown>
}

export interface CalibrationDispositionRequest {
  disposition: 'route_back_to_hardware' | 'scrap' | 'quarantine'
  actor_user_id: string
  reason: string
}

export interface QcSignoffRequest {
  actor_user_id: string
  checklist?: { item: string; passed: boolean }[]
  waiver_actor_user_id?: string
  waiver_reason?: string
}

export interface CloudBackupRequest {
  cloud_available: boolean
  actor_user_id: string
  backup_reference?: string
}

export interface PackageRequest {
  actor_user_id: string
}

export interface ShipRequest {
  actor_user_id: string
  document_refs?: string[]
}

export interface TransitionRequest {
  target_stage_id: string
  actor_user_id: string
  reason?: string
}
