import type {
  DataContractStatus,
  FactoryEvent,
  FactoryPart,
  FactoryRefStd,
  FactoryStage,
  FactoryUnit,
  FactoryUser,
  HealthResponse,
} from '../types/factory'

export interface FactoryViewModel {
  health: HealthResponse | null
  contractStatus: DataContractStatus | null
  stages: FactoryStage[]
  units: FactoryUnit[]
  events: FactoryEvent[]
  users: FactoryUser[]
  parts: FactoryPart[]
  refStandards: FactoryRefStd[]
  selectedUnitId: string | null
  selectedUnit: FactoryUnit | null
  loadError: string | null
  resetting: boolean
  selectUnit: (id: string) => Promise<void>
  refreshSelected: () => Promise<void>
  reload: () => Promise<void>
  resetDemoState: () => Promise<void>
}
