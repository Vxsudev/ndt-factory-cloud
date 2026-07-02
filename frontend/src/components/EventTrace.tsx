import React, { useState } from 'react'
import type { FactoryEvent } from '../types/factory'

interface Props {
  events: FactoryEvent[]
  selectedUnitId?: string | null
}

function severityStyle(sev: string): React.CSSProperties {
  switch (sev) {
    case 'error': return { color: 'var(--mds-error)' }
    case 'warning': return { color: 'var(--factory-gate)' }
    case 'info': return { color: 'var(--mds-primary)' }
    default: return { color: 'var(--mds-on-surface-variant)' }
  }
}

export function EventTrace({ events, selectedUnitId }: Props) {
  const [showAll, setShowAll] = useState(false)

  const sorted = [...events].sort((a, b) => b.timestamp.localeCompare(a.timestamp))

  let displayed: FactoryEvent[]
  let countLabel: string

  if (selectedUnitId) {
    const unitEvents = sorted.filter(e => e.unit_id === selectedUnitId)
    const otherEvents = sorted.filter(e => e.unit_id !== selectedUnitId)
    if (showAll) {
      displayed = [...unitEvents, ...otherEvents].slice(0, 25)
      countLabel = `${displayed.length} of ${sorted.length} events`
    } else {
      const others = otherEvents.slice(0, 10)
      displayed = [...unitEvents, ...others]
      countLabel = unitEvents.length > 0
        ? `${unitEvents.length} unit events + ${others.length} others`
        : `${others.length} of ${sorted.length} recent events`
    }
  } else {
    const limit = showAll ? 25 : 10
    displayed = sorted.slice(0, limit)
    countLabel = `${displayed.length} of ${sorted.length} events`
  }

  if (sorted.length === 0) {
    return <div className="t-on-surface-var text-sm py-4 text-center">No events</div>
  }

  return (
    <div className="surf-low">
      <div className="flex items-center justify-between mb-2">
        <span className="text-xs t-on-surface-var">{countLabel}</span>
        <button
          onClick={() => setShowAll(v => !v)}
          className="touch-target-secondary inline-flex items-center justify-center px-3 rounded border surf-low b-outline-var text-xs t-primary font-medium hover-surf-container transition-colors"
        >
          {showAll ? 'Show fewer' : 'Show all events'}
        </button>
      </div>

      {/* Compact (<lg) — stacked cards, all six fields preserved */}
      <div className="lg:hidden flex flex-col gap-2">
        {displayed.map((evt) => {
          const sevStyle = severityStyle(evt.severity)
          const isUnitRow = !!selectedUnitId && evt.unit_id === selectedUnitId
          return (
            <div
              key={evt.id}
              className="rounded border b-outline-var p-3"
              style={
                isUnitRow
                  ? { backgroundColor: 'color-mix(in srgb, var(--mds-primary-container) 40%, transparent)' }
                  : undefined
              }
            >
              <div className="flex items-center justify-between gap-2">
                <span
                  className={`font-mono text-xs ${isUnitRow ? 'font-semibold' : 't-on-surface-var'}`}
                  style={isUnitRow ? { color: 'var(--mds-primary)' } : undefined}
                >
                  {evt.unit_id ?? '—'}
                </span>
                <span className="px-1.5 py-0.5 rounded text-xs font-bold" style={sevStyle}>
                  {evt.severity.toUpperCase()}
                </span>
              </div>
              <div className="mt-1 t-on-surface text-sm">{evt.message}</div>
              <div className="mt-1 flex items-center justify-between gap-2 text-xs t-on-surface-var">
                <span className="font-mono">{evt.stage_id ?? '—'}</span>
                <span className="font-mono whitespace-nowrap">
                  {evt.timestamp.replace('T', ' ').replace('Z', '').slice(0, 19)}
                </span>
              </div>
              <div className="mt-1 font-mono text-xs t-on-surface-var">{evt.id}</div>
            </div>
          )
        })}
      </div>

      {/* Standard/large (lg+) — original table */}
      <div className="hidden lg:block overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b b-outline-var t-on-surface-var text-left">
              <th className="pb-1.5 pr-3 font-medium text-xs">Event ID</th>
              <th className="pb-1.5 pr-3 font-medium text-xs">Unit</th>
              <th className="pb-1.5 pr-3 font-medium text-xs">Stage</th>
              <th className="pb-1.5 pr-3 font-medium text-xs">Sev</th>
              <th className="pb-1.5 pr-3 font-medium text-xs">Message</th>
              <th className="pb-1.5 font-medium text-xs">Timestamp</th>
            </tr>
          </thead>
          <tbody>
            {displayed.map((evt) => {
              const sevStyle = severityStyle(evt.severity)
              const isUnitRow = !!selectedUnitId && evt.unit_id === selectedUnitId
              return (
                <tr
                  key={evt.id}
                  className="border-b b-outline-var py-2.5 hover-surf-container"
                  style={isUnitRow ? { backgroundColor: 'color-mix(in srgb, var(--mds-primary-container) 40%, transparent)' } : undefined}
                >
                  <td className="py-2.5 pr-3 font-mono t-on-surface-var text-xs">{evt.id}</td>
                  <td
                    className={`py-2.5 pr-3 font-mono text-xs ${isUnitRow ? 'font-semibold' : 't-on-surface-var'}`}
                    style={isUnitRow ? { color: 'var(--mds-primary)' } : undefined}
                  >
                    {evt.unit_id ?? '—'}
                  </td>
                  <td className="py-2.5 pr-3 font-mono t-on-surface-var text-xs">{evt.stage_id ?? '—'}</td>
                  <td className="py-2.5 pr-3">
                    <span className="px-1.5 py-0.5 rounded text-xs font-bold" style={sevStyle}>
                      {evt.severity.toUpperCase()}
                    </span>
                  </td>
                  <td className="py-2.5 pr-3 t-on-surface max-w-xs truncate text-xs">{evt.message}</td>
                  <td className="py-2.5 font-mono t-on-surface-var whitespace-nowrap text-xs">
                    {evt.timestamp.replace('T', ' ').replace('Z', '').slice(0, 19)}
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>
    </div>
  )
}
