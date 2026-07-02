import type { FactoryUnit } from '../types/factory'

const SCENARIO_LABELS: Record<string, string> = {
  'UNIT-0001': 'Assembly in progress',
  'UNIT-0002': 'Cloud SW/FW blocked',
  'UNIT-0003': 'Calibration retry active',
  'UNIT-0004': 'Calibration cap exceeded',
  'UNIT-0005': 'QC ready',
  'UNIT-0006': 'Cloud backup blocked',
  'UNIT-0007': 'Shipped — terminal',
}

interface Props {
  units: FactoryUnit[]
  selectedId: string | null
  onSelect: (id: string) => void
}

export function UnitList({ units, selectedId, onSelect }: Props) {
  return (
    <div className="flex flex-col gap-1.5">
      {units.length === 0 && (
        <div className="text-gray-400 text-sm px-2 py-4">No units loaded</div>
      )}
      {units.map((unit) => {
        const isSelected = unit.id === selectedId
        const isTerminal = unit.package_ship_status?.terminal
        const isBlocked = !!unit.blocked_reason
        const scenarioLabel = SCENARIO_LABELS[unit.id]

        return (
          <button
            key={unit.id}
            onClick={() => onSelect(unit.id)}
            className={`text-left px-3 py-4 rounded-xl border transition-colors min-h-[48px] ${
              isSelected
                ? 'surf-primary b-primary t-on-primary'
                : 'surf-low b-outline-var'
            }`}
          >
            <div className="flex items-center justify-between gap-2">
              <span className="font-mono text-[15px] font-bold t-on-surface">{unit.id}</span>
              <div className="flex gap-1">
                {isTerminal && (
                  <span className="px-1.5 py-0.5 rounded text-xs font-bold surf-success b-success t-on-success border">
                    SHIPPED
                  </span>
                )}
                {isBlocked && !isTerminal && (
                  <span className="px-1.5 py-0.5 rounded text-xs font-bold surf-error b-error t-on-error border">
                    BLOCKED
                  </span>
                )}
              </div>
            </div>
            {scenarioLabel && (
              <div className={`mt-0.5 text-[13px] font-medium ${isSelected ? 't-on-primary' : 't-on-surface-var'}`}>
                {scenarioLabel}
              </div>
            )}
            <div className="mt-0.5 t-on-surface-var text-xs">
              <span className="font-mono">{unit.order_id}</span>
              {' · '}
              <span>S-{String(unit.current_stage_number).padStart(2, '0')}</span>
              {' · '}
              <span>{unit.current_status}</span>
            </div>
            {isBlocked && !isTerminal && unit.blocked_reason && (
              <div className="mt-0.5 t-on-error text-xs truncate">
                {unit.blocked_reason}
                {unit.no_override && (
                  <span className="ml-1 font-bold">NO OVERRIDE</span>
                )}
              </div>
            )}
          </button>
        )
      })}
    </div>
  )
}
