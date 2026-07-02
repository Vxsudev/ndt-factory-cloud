export interface HealthResponse {
  status: string
  service: string
  phase: string
}

export interface ScaffoldStatusResponse {
  status: string
  domain_logic_enabled: boolean
  stage_model_locked: boolean
  current_phase: string
}

export type HealthState =
  | { state: 'loading' }
  | { state: 'ok'; data: HealthResponse }
  | { state: 'error'; message: string }
