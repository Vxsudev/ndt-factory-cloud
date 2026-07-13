import { useEffect } from 'react'
import type { FactoryViewModel } from '../../../view-model/types'
import { WorkflowActionForm } from './WorkflowActionForm'

function formatBlockedReason(reason: string): string {
  const spaced = reason.replace(/_/g, ' ')
  return spaced.charAt(0).toUpperCase() + spaced.slice(1).toLowerCase()
}

interface Props {
  vm: FactoryViewModel
}

export function AssemblerWorkflowView({ vm }: Props) {
  useEffect(() => {
    if (vm.selectedUnitId == null) {
      const first = vm.units.find((u) => !u.package_ship_status.terminal)
      if (first) void vm.selectUnit(first.id)
    }
  }, [vm.selectedUnitId, vm.units, vm.selectUnit])

  const focused = vm.selectedUnit

  if (!focused) {
    return <div className="t-on-surface-var text-sm px-4 py-8 text-center">Loading…</div>
  }

  const others = vm.units.filter((u) => !u.package_ship_status.terminal && u.id !== focused.id)
  const stageName =
    vm.stages.find((s) => s.id === focused.current_stage_id)?.name ?? focused.current_stage_id
  const isBlocked = focused.blocked_reason != null

  return (
    <div className="p-4 space-y-4">
      <div className="rounded-xl border surf-container b-outline-var p-4 space-y-3">
        <div className="text-xs font-semibold uppercase tracking-widest t-on-surface-var">
          Current Unit
        </div>
        <div className="font-mono text-lg font-bold t-on-surface">{focused.id}</div>
        <div className="text-sm t-on-surface-var">{stageName}</div>

        {isBlocked && (
          <div className="rounded-lg border-2 surf-error b-error p-3 space-y-2">
            <div className="text-xs font-semibold uppercase tracking-widest t-on-error">
              Attention
            </div>
            <div className="t-on-error font-bold text-sm">
              {formatBlockedReason(focused.blocked_reason as string)}
            </div>
            {focused.no_override && (
              <div className="t-on-error font-black text-xs uppercase tracking-wide">
                NO OVERRIDE
              </div>
            )}
            {focused.current_stage_number === 12 ? (
              <WorkflowActionForm
                unit={focused}
                parts={vm.parts}
                refStandards={vm.refStandards}
                onDone={() => void vm.refreshSelected()}
              />
            ) : (
              <div className="t-on-error text-sm">
                Needs floor manager approval — visible in the Floor Manager triage list.
              </div>
            )}
          </div>
        )}
      </div>

      {others.length > 0 && (
        <div>
          <div className="text-xs font-semibold uppercase tracking-widest t-on-surface-var mb-1.5">
            Other Units in Queue
          </div>
          <div className="flex gap-2 overflow-x-auto pb-1">
            {others.map((u) => (
              <button
                key={u.id}
                type="button"
                onClick={() => void vm.selectUnit(u.id)}
                className="touch-target-secondary shrink-0 flex items-center gap-1.5 px-3 rounded border surf-container t-on-surface b-outline-var text-sm font-mono"
              >
                {u.id}
                {u.blocked_reason != null && (
                  <span className="px-1 py-0.5 rounded text-[10px] font-bold surf-error b-error t-on-error border">
                    BLOCKED
                  </span>
                )}
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
