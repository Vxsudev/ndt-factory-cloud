import type { FactoryUnit } from '../types/factory'

interface Props {
  unit: FactoryUnit | null
}

function Row({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex justify-between gap-2 text-sm py-1.5 border-b b-outline-var last:border-0">
      <span className="t-on-surface-var shrink-0">{label}</span>
      <span className="font-mono t-on-surface text-right break-all">{value}</span>
    </div>
  )
}

export function UnitDetailPanel({ unit }: Props) {
  if (!unit) {
    return (
      <div className="t-on-surface-var text-sm px-4 py-8 text-center">
        Select a unit from the list
      </div>
    )
  }

  const cal = unit.calibration_summary
  const calAttempts = cal?.attempts ?? 0
  const calMax = cal?.max_attempts ?? 3
  const calCap = cal?.cap_exceeded ?? false
  const calCert = cal?.certificate_id ?? null

  return (
    <div className="text-sm space-y-3">
      {/* Identity */}
      <div>
        <div className="text-xs font-semibold uppercase tracking-widest t-on-surface-var mb-1.5">
          Unit Identity
        </div>
        <div className="mdc-card border b-outline-var">
          <Row label="Unit ID" value={unit.id} />
          <Row label="Order ID" value={unit.order_id} />
          <Row label="Model" value={unit.model_id} />
          <Row label="Serial" value={unit.genealogy_serial} />
          <Row label="Station" value={unit.station_id ?? '—'} />
        </div>
      </div>

      {/* Stage / Status */}
      <div>
        <div className="text-xs font-semibold uppercase tracking-widest t-on-surface-var mb-1.5">
          Stage / Status
        </div>
        <div className="mdc-card border b-outline-var">
          <Row label="Stage" value={`${unit.current_stage_id} (S-${String(unit.current_stage_number).padStart(2, '0')})`} />
          <Row
            label="Status"
            value={
              <span className={unit.package_ship_status?.terminal ? 'text-green-600 font-semibold' : unit.blocked_reason ? 't-on-error font-semibold' : 't-on-surface'}>
                {unit.current_status}
              </span>
            }
          />
        </div>
      </div>

      {/* Block / Hard-Stop */}
      {unit.blocked_reason && (
        <div>
          <div className="text-xs font-semibold uppercase tracking-widest t-on-error mb-1.5">
            Block / Hard-Stop
          </div>
          <div className="surf-error border-2 b-error rounded px-3 py-2.5 space-y-2">
            <div className="t-on-error font-bold text-base break-all">{unit.blocked_reason}</div>
            {unit.no_override && (
              <div className="t-on-error font-black text-base uppercase tracking-wide">
                ⚠ NO OVERRIDE — No bypass possible
              </div>
            )}
            {unit.block_type && (
              <div className="flex justify-between gap-2 text-sm">
                <span className="t-on-surface-var shrink-0">Block Type</span>
                <span className="font-mono t-on-surface">{unit.block_type}</span>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Part Allocations */}
      {Object.keys(unit.part_allocations).length > 0 && (
        <details className="group" open>
          <summary className="touch-target-secondary flex items-center gap-1.5 cursor-pointer select-none list-none [&::-webkit-details-marker]:hidden text-xs font-semibold uppercase tracking-widest t-on-surface-var mb-1.5">
            <span className="inline-block transition-transform group-open:rotate-90">▸</span>
            Part Allocations
          </summary>
          <div className="mdc-card border b-outline-var">
            {Object.entries(unit.part_allocations).map(([partType, alloc]) => (
              <Row
                key={partType}
                label={partType}
                value={
                  <span className={alloc.status === 'allocated_bound' ? 'text-green-600' : 'text-amber-600'}>
                    {alloc.part_id} · {alloc.status}
                  </span>
                }
              />
            ))}
          </div>
        </details>
      )}

      {/* Calibration */}
      <details className="group" open>
        <summary className="touch-target-secondary flex items-center gap-1.5 cursor-pointer select-none list-none [&::-webkit-details-marker]:hidden text-xs font-semibold uppercase tracking-widest t-on-surface-var mb-1.5">
          <span className="inline-block transition-transform group-open:rotate-90">▸</span>
          Calibration
        </summary>
        <div className="mdc-card border b-outline-var">
          <Row label="Attempts" value={`${calAttempts} / ${calMax}`} />
          <Row label="Passed" value={cal?.passed ? <span className="text-green-600 font-semibold">yes</span> : <span className="t-on-surface-var">no</span>} />
          {calCert && <Row label="Certificate" value={<span className="text-green-600">{calCert}</span>} />}
          {calCap && <Row label="Cap Exceeded" value={<span className="t-on-error font-semibold">YES — disposition required</span>} />}
        </div>
      </details>

      {/* QC */}
      <details className="group" open>
        <summary className="touch-target-secondary flex items-center gap-1.5 cursor-pointer select-none list-none [&::-webkit-details-marker]:hidden text-xs font-semibold uppercase tracking-widest t-on-surface-var mb-1.5">
          <span className="inline-block transition-transform group-open:rotate-90">▸</span>
          Quality Control
        </summary>
        <div className="mdc-card border b-outline-var">
          <Row
            label="Signed Off"
            value={unit.qc_summary.signed_off ? <span className="text-green-600 font-semibold">yes</span> : <span className="t-on-surface-var">no</span>}
          />
          {unit.qc_summary.signed_by && <Row label="Signed By" value={unit.qc_summary.signed_by} />}
        </div>
      </details>

      {/* Cloud / Ship */}
      <details className="group" open>
        <summary className="touch-target-secondary flex items-center gap-1.5 cursor-pointer select-none list-none [&::-webkit-details-marker]:hidden text-xs font-semibold uppercase tracking-widest t-on-surface-var mb-1.5">
          <span className="inline-block transition-transform group-open:rotate-90">▸</span>
          Cloud / Ship
        </summary>
        <div className="mdc-card border b-outline-var">
          <Row label="Cloud Backup" value={unit.cloud_status.backed_up ? <span className="text-green-600 font-semibold">backed up</span> : <span className="t-on-surface-var">not yet</span>} />
          <Row label="Packaged" value={unit.package_ship_status.packaged ? <span className="text-green-600 font-semibold">yes</span> : 'no'} />
          <Row label="Shipped" value={unit.package_ship_status.shipped ? <span className="text-green-600 font-semibold">yes</span> : 'no'} />
          <Row label="Terminal" value={unit.package_ship_status.terminal ? <span className="text-green-600 font-semibold">yes</span> : 'no'} />
        </div>
      </details>
    </div>
  )
}
