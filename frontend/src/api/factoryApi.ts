// Factory Cloud v0 — D6 API client
// All API calls route through this module. No raw fetch in component files.

import type {
  ActionResponse,
  CalibrationDispositionRequest,
  CalibrationRequest,
  CloudBackupRequest,
  DataContractStatus,
  FactoryEvent,
  FactoryPart,
  FactoryRefStd,
  FactoryStage,
  FactoryUnit,
  FactoryUser,
  HardwareGateRequest,
  HealthResponse,
  PackageRequest,
  QcSignoffRequest,
  ReallocatePartRequest,
  ResetStateResponse,
  ScanPartRequest,
  ShipRequest,
  TransitionRequest,
} from '../types/factory'

const API_BASE = (import.meta.env.VITE_API_BASE_URL as string | undefined) ?? 'http://localhost:8000'

export class ApiError extends Error {
  constructor(
    public status: number,
    message: string,
  ) {
    super(message)
    this.name = 'ApiError'
  }
}

async function get<T>(path: string): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`)
  if (!res.ok) throw new ApiError(res.status, `GET ${path} failed: ${res.status}`)
  return res.json() as Promise<T>
}

async function post<T>(path: string, body: unknown): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  // 200 with blocked status is NOT an error — return normally
  // Only 4xx/5xx throw
  if (!res.ok) throw new ApiError(res.status, `POST ${path} failed: ${res.status}`)
  return res.json() as Promise<T>
}

// ── Read endpoints (D4) ──────────────────────────────────────────────────────

export function fetchHealth(): Promise<HealthResponse> {
  return get<HealthResponse>('/health')
}

export function fetchDataContractStatus(): Promise<DataContractStatus> {
  return get<DataContractStatus>('/factory/data-contract/status')
}

export function fetchStages(): Promise<FactoryStage[]> {
  return get<FactoryStage[]>('/factory/stages')
}

export function fetchUnits(): Promise<FactoryUnit[]> {
  return get<FactoryUnit[]>('/factory/units')
}

export function fetchUnit(id: string): Promise<FactoryUnit> {
  return get<FactoryUnit>(`/factory/units/${id}`)
}

export function fetchEvents(): Promise<FactoryEvent[]> {
  return get<FactoryEvent[]>('/factory/events')
}

export function fetchUsers(): Promise<FactoryUser[]> {
  return get<FactoryUser[]>('/factory/users')
}

export function fetchParts(): Promise<FactoryPart[]> {
  return get<FactoryPart[]>('/factory/parts')
}

export function fetchRefStandards(): Promise<FactoryRefStd[]> {
  return get<FactoryRefStd[]>('/factory/reference-standards')
}

// ── Dev endpoint (D5) ────────────────────────────────────────────────────────

export function postResetState(): Promise<ResetStateResponse> {
  return post<ResetStateResponse>('/factory/dev/reset-state', {})
}

// ── Action endpoints (D5) ────────────────────────────────────────────────────

export function postScanPart(unitId: string, req: ScanPartRequest): Promise<ActionResponse> {
  return post<ActionResponse>(`/factory/units/${unitId}/actions/scan-part`, req)
}

export function postReallocatePart(unitId: string, req: ReallocatePartRequest): Promise<ActionResponse> {
  return post<ActionResponse>(`/factory/units/${unitId}/actions/reallocate-part`, req)
}

export function postHardwareGate(unitId: string, req: HardwareGateRequest): Promise<ActionResponse> {
  return post<ActionResponse>(`/factory/units/${unitId}/actions/hardware-gate`, req)
}

export function postCalibration(unitId: string, req: CalibrationRequest): Promise<ActionResponse> {
  return post<ActionResponse>(`/factory/units/${unitId}/actions/calibration`, req)
}

export function postCalibrationDisposition(
  unitId: string,
  req: CalibrationDispositionRequest,
): Promise<ActionResponse> {
  return post<ActionResponse>(`/factory/units/${unitId}/actions/calibration-disposition`, req)
}

export function postQcSignoff(unitId: string, req: QcSignoffRequest): Promise<ActionResponse> {
  return post<ActionResponse>(`/factory/units/${unitId}/actions/qc-signoff`, req)
}

export function postCloudBackup(unitId: string, req: CloudBackupRequest): Promise<ActionResponse> {
  return post<ActionResponse>(`/factory/units/${unitId}/actions/cloud-backup`, req)
}

export function postPackage(unitId: string, req: PackageRequest): Promise<ActionResponse> {
  return post<ActionResponse>(`/factory/units/${unitId}/actions/package`, req)
}

export function postShip(unitId: string, req: ShipRequest): Promise<ActionResponse> {
  return post<ActionResponse>(`/factory/units/${unitId}/actions/ship`, req)
}

export function postTransition(unitId: string, req: TransitionRequest): Promise<ActionResponse> {
  return post<ActionResponse>(`/factory/units/${unitId}/actions/transition`, req)
}
