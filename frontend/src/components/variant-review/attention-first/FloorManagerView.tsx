import { useState } from 'react'
import type { FactoryUnit } from '../../../types/factory'
import type { FactoryViewModel } from '../../../view-model/types'
import { AttentionActionForm, hasSupportedAction } from './AttentionActionForm'
import { formatBlockedReason } from './AssemblerView'

interface Props {
  vm: FactoryViewModel
}

function TriageRow({ unit, vm }: { unit: FactoryUnit; vm: FactoryViewModel }) {
  const [open, setOpen] = useState(false)
  const actionable = hasSupportedAction(unit, vm.parts)
  return (
    <div className="rounded-xl border-2 surf-error b-error p-3 space-y-2">
      <div className="flex items-center justify-between gap-2">
        <span className="font-mono font-bold t-on-error">{unit.id}</span>
        {unit.no_override && (
          <span className="t-on-error font-black text-xs uppercase tracking-wide">
            ⚠ NO OVERRIDE
          </span>
        )}
      </div>
      <div className="t-on-error text-sm">{formatBlockedReason(unit.blocked_reason as string)}</div>
      {actionable ? (
        <>
          <button
            type="button"
            onClick={() => setOpen((o) => !o)}
            className="touch-target-secondary px-3 rounded surf-container t-on-surface b-outline-var text-sm font-medium"
          >
            {open ? 'Hide' : 'Resolve'}
          </button>
          {open && (
            <AttentionActionForm
              unit={unit}
              parts={vm.parts}
              refStandards={vm.refStandards}
              onDone={() => void vm.reload()}
            />
          )}
        </>
      ) : (
        <div className="t-on-error text-sm">
          No resolution action is available in this comparison view.
        </div>
      )}
    </div>
  )
}

export function FloorManagerView({ vm }: Props) {
  const nonTerminal = vm.units.filter((u) => !u.package_ship_status.terminal)
  const blockedUnits = nonTerminal.filter((u) => u.blocked_reason != null)
  const sortedQueue = [...nonTerminal].sort(
    (a, b) => a.current_stage_number - b.current_stage_number,
  )

  return (
    <div className="p-4 space-y-4">
      <div
        className={`rounded-lg border px-3 py-2 text-sm font-semibold ${
          blockedUnits.length > 0
            ? 'surf-error b-error t-on-error'
            : 'surf-container b-outline-var t-on-surface-var'
        }`}
      >
        {blockedUnits.length} need{blockedUnits.length === 1 ? 's' : ''} attention
      </div>

      {blockedUnits.length > 0 && (
        <div className="space-y-2">
          <div className="text-xs font-semibold uppercase tracking-widest t-on-error">Triage</div>
          {blockedUnits.map((u) => (
            <TriageRow key={u.id} unit={u} vm={vm} />
          ))}
        </div>
      )}

      <div className="space-y-1.5">
        <div className="text-xs font-semibold uppercase tracking-widest t-on-surface-var">Queue</div>
        {sortedQueue.map((u) => (
          <div
            key={u.id}
            className="flex items-center justify-between gap-2 px-3 py-2.5 rounded border surf-low b-outline-var text-sm"
          >
            <span className="font-mono font-semibold t-on-surface">{u.id}</span>
            <span className="t-on-surface-var">
              S-{String(u.current_stage_number).padStart(2, '0')}
            </span>
            {u.blocked_reason != null && (
              <span className="px-1.5 py-0.5 rounded text-xs font-bold surf-error b-error t-on-error border">
                BLOCKED
              </span>
            )}
          </div>
        ))}
      </div>
    </div>
  )
}
