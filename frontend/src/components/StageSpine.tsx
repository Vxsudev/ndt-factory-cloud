import type { FactoryStage, FactoryUnit } from '../types/factory'

interface Props {
  stages: FactoryStage[]
  selectedUnit: FactoryUnit | null
}

function stageState(stage: FactoryStage, unit: FactoryUnit | null) {
  if (!unit) return 'pending'
  if (stage.number < unit.current_stage_number) return 'completed'
  if (stage.number === unit.current_stage_number) return 'current'
  return 'pending'
}

const CLOUD_BLOCK_STAGES = new Set([7, 12])
const GATE_STAGES = new Set([9, 10, 11])

export function StageSpine({ stages, selectedUnit }: Props) {
  const sorted = [...stages].sort((a, b) => a.number - b.number)

  return (
    <div className="flex flex-col gap-1.5">
      {sorted.map((stage) => {
        const state = stageState(stage, selectedUnit)
        const isCurrentBlocked =
          state === 'current' && selectedUnit && !!selectedUnit.blocked_reason
        const isCurrentNoOverride =
          isCurrentBlocked && selectedUnit?.no_override
        const isTerminal = stage.number === 14
        const isCloudBlock = CLOUD_BLOCK_STAGES.has(stage.number)
        const isGateStage = GATE_STAGES.has(stage.number)
        const isCloudBlockActive =
          isCurrentBlocked && isCloudBlock && selectedUnit?.no_override

        let rowCls = 'px-3 rounded border text-sm flex items-start gap-2 '
        rowCls += (isGateStage || isTerminal) ? 'py-2.5 ' : 'py-2 '
        if (state === 'completed') {
          rowCls += 'surf-low b-outline-var'
        } else if (state === 'current' && isCurrentBlocked) {
          rowCls += 'surf-error b-error'
        } else if (state === 'current') {
          rowCls += 'surf-primary b-primary'
        } else if (isGateStage) {
          rowCls += 'surf-gate b-gate'
        } else if (isCloudBlock) {
          rowCls += 'surf-cloud b-cloud'
        } else if (isTerminal) {
          rowCls += 'surf-success b-success'
        } else {
          rowCls += 'surf b-outline-var'
        }

        return (
          <div key={stage.id} className={rowCls}>
            {/* Stage number */}
            <div className="w-6 shrink-0 font-mono text-right text-xs t-on-surface-var">
              {String(stage.number).padStart(2, '0')}
            </div>

            {/* Stage name + badges */}
            <div className="flex-1 min-w-0">
              <div className={`text-[14px] font-semibold ${
                state === 'current' && !isCurrentBlocked ? 't-on-primary' :
                state === 'current' && isCurrentBlocked ? 't-on-error' :
                state === 'completed' ? 't-on-surface-var' :
                isGateStage ? 't-on-gate' :
                isCloudBlock ? 't-on-cloud' :
                isTerminal ? 't-on-success' :
                't-on-surface-var'
              }`}>
                {stage.name}
              </div>
              <div className="flex flex-wrap gap-1 mt-1">
                {stage.is_external && (
                  <span className="px-1.5 py-0.5 rounded text-xs font-bold surf-container b-outline-var t-on-surface-var border">
                    EXTERNAL
                  </span>
                )}
                {stage.is_gate && (
                  <span className="px-1.5 py-0.5 rounded text-xs font-bold surf-gate b-gate t-on-gate border">
                    GATE
                  </span>
                )}
                {isTerminal && (
                  <span className="px-1.5 py-0.5 rounded text-xs font-bold surf-success b-success t-on-success border">
                    TERMINAL
                  </span>
                )}
                {isCloudBlock && (
                  <span className={`px-1.5 py-0.5 rounded text-xs font-bold border ${
                    isCloudBlockActive
                      ? 'surf-error b-error t-on-error'
                      : 'surf-cloud b-cloud t-on-cloud'
                  }`}>
                    CLOUD BLOCK
                  </span>
                )}
                {stage.is_separable && (
                  <span className="px-1.5 py-0.5 rounded text-xs font-bold surf-container b-outline-var t-on-surface-var border">
                    SEPARABLE
                  </span>
                )}
                {state === 'current' && isCurrentBlocked && !isCloudBlockActive && (
                  <span className="px-1.5 py-0.5 rounded text-xs font-bold surf-error b-error t-on-error border">
                    BLOCKED
                  </span>
                )}
                {isCurrentNoOverride && (
                  <span className="px-2 py-0.5 rounded text-xs font-black tracking-wide bg-red-600 text-white border border-red-500">
                    NO OVERRIDE
                  </span>
                )}
                {state === 'current' &&
                  selectedUnit?.package_ship_status?.terminal && (
                    <span className="px-1.5 py-0.5 rounded text-xs font-bold surf-success b-success t-on-success border">
                      SHIPPED
                    </span>
                  )}
              </div>
              {state === 'current' && isCurrentBlocked && selectedUnit?.blocked_reason && (
                <div className="mt-1 t-on-error text-xs">
                  {selectedUnit.blocked_reason}
                </div>
              )}
            </div>

            {/* Status dot */}
            <div className="shrink-0 mt-1">
              {state === 'completed' && (
                <div className="w-2 h-2 rounded-full bg-slate-400" />
              )}
              {state === 'current' && !isCurrentBlocked && (
                <div className="w-2 h-2 rounded-full bg-blue-500" />
              )}
              {state === 'current' && isCurrentBlocked && (
                <div className="w-2 h-2 rounded-full bg-red-500" />
              )}
              {state === 'pending' && (
                <div className="w-2 h-2 rounded-full bg-slate-300" />
              )}
            </div>
          </div>
        )
      })}
    </div>
  )
}
