import { useState } from 'react'
import type { FactoryPart, FactoryRefStd, FactoryUnit } from '../../../types/factory'
import {
  postCalibration,
  postCalibrationDisposition,
  postCloudBackup,
  postReallocatePart,
} from '../../../api/factoryApi'

interface Props {
  unit: FactoryUnit
  parts: FactoryPart[]
  refStandards: FactoryRefStd[]
  onDone: () => void
}

interface ReallocationTarget {
  partType: string
  oldSerial: string
}

function findAffectedAllocation(unit: FactoryUnit, parts: FactoryPart[]): ReallocationTarget | null {
  const entry = Object.entries(unit.part_allocations).find(
    ([, alloc]) => alloc.status !== 'allocated_bound',
  )
  if (!entry) return null
  const [partType, alloc] = entry
  const part = parts.find((p) => p.id === alloc.part_id)
  if (!part?.serial_number) return null
  return { partType, oldSerial: part.serial_number }
}

export function hasSupportedAction(unit: FactoryUnit, parts: FactoryPart[]): boolean {
  const stageNum = unit.current_stage_number
  const isCapExceeded = unit.calibration_summary.cap_exceeded ?? false
  if (stageNum === 5 && unit.blocked_reason != null) {
    return findAffectedAllocation(unit, parts) != null
  }
  if (stageNum === 10 && !isCapExceeded) return true
  if (stageNum === 10 && isCapExceeded) return true
  if (stageNum === 12 && unit.blocked_reason != null) return true
  return false
}

function SubmitButton({
  label,
  loading,
  onClick,
  tone = 'primary',
}: {
  label: string
  loading: boolean
  onClick: () => void
  tone?: 'primary' | 'error'
}) {
  const toneCls =
    tone === 'error' ? 'surf-error t-on-error b-error border' : 'surf-primary t-on-primary'
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={loading}
      className={`touch-target-primary inline-flex items-center justify-center px-4 rounded text-sm font-semibold w-full transition-colors disabled:opacity-50 ${toneCls}`}
    >
      {loading ? 'Submitting…' : label}
    </button>
  )
}

export function AttentionActionForm({ unit, parts, refStandards, onDone }: Props) {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [newSerial, setNewSerial] = useState('')
  const [calResult, setCalResult] = useState<'pass' | 'fail'>('pass')

  const stageNum = unit.current_stage_number
  const isCapExceeded = unit.calibration_summary.cap_exceeded ?? false

  async function submit(fn: () => Promise<unknown>) {
    setLoading(true)
    setError(null)
    try {
      await fn()
      onDone()
    } catch (e: unknown) {
      setError(e instanceof Error ? e.message : String(e))
    } finally {
      setLoading(false)
    }
  }

  if (stageNum === 5 && unit.blocked_reason != null) {
    const target = findAffectedAllocation(unit, parts)
    if (!target) {
      return (
        <div className="t-on-error text-sm">
          No serialized part could be identified for reallocation.
        </div>
      )
    }
    return (
      <div className="space-y-2">
        <label className="flex flex-col gap-1">
          <span className="text-xs uppercase tracking-widest t-on-surface-var font-semibold">
            Replacement Serial Number
          </span>
          <input
            className="mdc-input text-sm font-mono"
            value={newSerial}
            onChange={(e) => setNewSerial(e.target.value)}
            placeholder="new serial"
          />
        </label>
        <SubmitButton
          label="Submit Reallocation"
          loading={loading}
          onClick={() =>
            submit(() =>
              postReallocatePart(unit.id, {
                part_type: target.partType,
                old_serial_number: target.oldSerial,
                new_serial_number: newSerial,
                reason: 'Reallocated via Attention-First triage',
                release_reason_code: 'damaged_at_bench',
                actor_user_id: 'USER-SUP-0001',
              }),
            )
          }
        />
        {error && <div className="t-on-error text-sm">Error: {error}</div>}
      </div>
    )
  }

  if (stageNum === 10 && !isCapExceeded) {
    const defaultRef = refStandards.find((r) => r.can_be_used_for_calibration)?.id ?? 'REFSTD-0001'
    return (
      <div className="space-y-2">
        <label className="flex flex-col gap-1">
          <span className="text-xs uppercase tracking-widest t-on-surface-var font-semibold">
            Calibration Result
          </span>
          <select
            className="mdc-select text-sm font-mono"
            value={calResult}
            onChange={(e) => setCalResult(e.target.value as 'pass' | 'fail')}
          >
            <option value="pass">Pass</option>
            <option value="fail">Fail</option>
          </select>
        </label>
        <SubmitButton
          label="Submit Calibration Result"
          loading={loading}
          onClick={() =>
            submit(() =>
              postCalibration(unit.id, {
                result: calResult,
                actor_user_id: 'USER-TECH-0001',
                reference_standard_ids: [defaultRef],
                equipment_id: 'CAL-EQUIP-01',
              }),
            )
          }
        />
        {error && <div className="t-on-error text-sm">Error: {error}</div>}
      </div>
    )
  }

  if (stageNum === 10 && isCapExceeded) {
    return (
      <div className="space-y-2">
        <SubmitButton
          label="Route back to hardware"
          loading={loading}
          onClick={() =>
            submit(() =>
              postCalibrationDisposition(unit.id, {
                disposition: 'route_back_to_hardware',
                actor_user_id: 'USER-MGR-0001',
                reason: 'Calibration cap exceeded — routing back to hardware',
              }),
            )
          }
        />
        <SubmitButton
          label="Quarantine"
          loading={loading}
          onClick={() =>
            submit(() =>
              postCalibrationDisposition(unit.id, {
                disposition: 'quarantine',
                actor_user_id: 'USER-MGR-0001',
                reason: 'Calibration cap exceeded — quarantining unit',
              }),
            )
          }
        />
        <SubmitButton
          label="Scrap"
          loading={loading}
          tone="error"
          onClick={() =>
            submit(() =>
              postCalibrationDisposition(unit.id, {
                disposition: 'scrap',
                actor_user_id: 'USER-MGR-0001',
                reason: 'Calibration cap exceeded — scrapping unit',
              }),
            )
          }
        />
        {error && <div className="t-on-error text-sm">Error: {error}</div>}
      </div>
    )
  }

  if (stageNum === 12 && unit.blocked_reason != null) {
    return (
      <div className="space-y-2">
        <SubmitButton
          label="Retry Cloud Backup"
          loading={loading}
          onClick={() =>
            submit(() =>
              postCloudBackup(unit.id, {
                cloud_available: true,
                actor_user_id: 'USER-OP-0001',
              }),
            )
          }
        />
        {error && <div className="t-on-error text-sm">Error: {error}</div>}
      </div>
    )
  }

  return null
}
