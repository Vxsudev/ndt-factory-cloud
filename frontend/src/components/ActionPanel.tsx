import { useState } from 'react'
import type {
  ActionResponse,
  FactoryRefStd,
  FactoryUnit,
  FactoryUser,
} from '../types/factory'
import {
  postCalibration,
  postCalibrationDisposition,
  postCloudBackup,
  postHardwareGate,
  postPackage,
  postQcSignoff,
  postReallocatePart,
  postScanPart,
  postShip,
  postTransition,
} from '../api/factoryApi'

interface Props {
  unit: FactoryUnit | null
  users: FactoryUser[]
  refStandards: FactoryRefStd[]
  onActionComplete: () => void
}

function Field({
  label,
  children,
}: {
  label: string
  children: React.ReactNode
}) {
  return (
    <div className="flex flex-col gap-1">
      <label className="text-xs uppercase tracking-widest t-on-surface-var font-semibold">
        {label}
      </label>
      {children}
    </div>
  )
}

function Input({
  value,
  onChange,
  placeholder,
}: {
  value: string
  onChange: (v: string) => void
  placeholder?: string
}) {
  return (
    <input
      className="mdc-input text-sm font-mono"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
    />
  )
}

function Select({
  value,
  onChange,
  options,
}: {
  value: string
  onChange: (v: string) => void
  options: { value: string; label: string }[]
}) {
  return (
    <select
      className="mdc-select text-sm font-mono"
      value={value}
      onChange={(e) => onChange(e.target.value)}
    >
      {options.map((o) => (
        <option key={o.value} value={o.value}>
          {o.label}
        </option>
      ))}
    </select>
  )
}

function SubmitBtn({
  label,
  loading,
  onClick,
  variant = 'default',
}: {
  label: string
  loading: boolean
  onClick: () => void
  variant?: 'default' | 'error' | 'supervisor'
}) {
  const variantCls =
    variant === 'error'
      ? 'bg-red-600 hover:bg-red-700'
      : variant === 'supervisor'
        ? 'bg-purple-600 hover:bg-purple-700'
        : 'bg-blue-600 hover:bg-blue-700'
  return (
    <button
      onClick={onClick}
      disabled={loading}
      className={`touch-target-primary inline-flex items-center justify-center mt-2 px-4 rounded disabled:opacity-50 text-sm text-white font-semibold w-full transition-colors ${variantCls}`}
    >
      {loading ? 'Submitting…' : label}
    </button>
  )
}

function ResponseDisplay({ resp }: { resp: ActionResponse }) {
  const isSuccess = resp.status === 'success'
  const isBlocked = resp.status === 'blocked'
  return (
    <div
      className={`mt-3 rounded border p-3 text-sm space-y-2 ${
        isSuccess
          ? 'surf-success b-success'
          : isBlocked
            ? 'surf-error b-error'
            : 'surf-low b-outline-var'
      }`}
    >
      <div className="flex items-center gap-2">
        <span
          className={`px-2 py-0.5 rounded text-xs font-bold border ${
            isSuccess
              ? 'surf-success b-success t-on-success'
              : isBlocked
                ? 'surf-error b-error t-on-error'
                : 'surf-container b-outline-var t-on-surface-var'
          }`}
        >
          {resp.status.toUpperCase()}
        </span>
        <span className="t-on-surface-var text-xs">Backend Response</span>
      </div>
      <div className={`font-medium text-sm ${isBlocked ? 't-on-error' : 't-on-surface'}`}>
        {resp.message}
      </div>
      <div className="grid grid-cols-[auto_1fr] gap-x-3 gap-y-0.5 text-xs">
        <span className="t-on-surface-var">unit_id</span>
        <span className="font-mono t-on-surface">{resp.unit_id}</span>
        <span className="t-on-surface-var">stage</span>
        <span className="font-mono t-on-surface">{resp.current_stage_id}</span>
        <span className="t-on-surface-var">status</span>
        <span className="font-mono t-on-surface">{resp.current_status}</span>
        <span className="t-on-surface-var">event_id</span>
        <span className="font-mono t-on-surface-var">{resp.event_id ?? '—'}</span>
        <span className="t-on-surface-var">blocked_reason</span>
        <span className={`font-mono ${resp.blocked_reason ? 't-on-error' : 't-on-surface-var'}`}>
          {resp.blocked_reason ?? 'null'}
        </span>
        <span className="t-on-surface-var">no_override</span>
        <span className={`font-mono font-bold ${resp.no_override ? 't-on-error' : 't-on-surface-var'}`}>
          {resp.no_override === null ? 'null' : String(resp.no_override)}
          {resp.no_override && (
            <span className="ml-1.5 px-1 py-0.5 rounded text-xs surf-error b-error t-on-error border">
              NO OVERRIDE
            </span>
          )}
        </span>
      </div>
    </div>
  )
}

export function ActionPanel({ unit, users, refStandards, onActionComplete }: Props) {
  const [loading, setLoading] = useState(false)
  const [lastResponse, setLastResponse] = useState<ActionResponse | null>(null)
  const [error, setError] = useState<string | null>(null)

  // Scan-part fields
  const [scanPartType, setScanPartType] = useState('POWER_SUPPLY')
  const [scanSerial, setScanSerial] = useState('PS-SN-MOCK-0002')
  const [scanActor, setScanActor] = useState('USER-OP-0001')
  const [scanStation, setScanStation] = useState('BENCH-A1')

  // Reallocate fields
  const [reallocOldSerial, setReallocOldSerial] = useState('')
  const [reallocNewSerial, setReallocNewSerial] = useState('')
  const [reallocReason, setReallocReason] = useState('')
  const [reallocCode, setReallocCode] = useState('damaged_at_bench')
  const [reallocActor, setReallocActor] = useState('USER-SUP-0001')

  // Hardware gate
  const [hwResult, setHwResult] = useState<'pass' | 'fail'>('pass')
  const [hwActor, setHwActor] = useState('USER-TECH-0001')
  const [hwReason, setHwReason] = useState('')

  // Calibration
  const [calResult, setCalResult] = useState<'pass' | 'fail'>('pass')
  const [calActor, setCalActor] = useState('USER-TECH-0001')
  const [calRefStds, setCalRefStds] = useState(
    refStandards.filter((r) => r.can_be_used_for_calibration).map((r) => r.id).join(',') ||
      'REFSTD-0001',
  )
  const [calEquip, setCalEquip] = useState('CAL-EQUIP-01')

  // Calibration disposition
  const [dispDisp, setDispDisp] = useState<'route_back_to_hardware' | 'scrap' | 'quarantine'>(
    'route_back_to_hardware',
  )
  const [dispActor, setDispActor] = useState('USER-MGR-0001')
  const [dispReason, setDispReason] = useState('3 attempts failed, routing back')

  // QC signoff
  const [qcActor, setQcActor] = useState('USER-QC-0001')
  const [qcWaiverActor, setQcWaiverActor] = useState('')
  const [qcWaiverReason, setQcWaiverReason] = useState('')

  // Cloud backup
  const [cloudAvail, setCloudAvail] = useState(true)
  const [cloudActor, setCloudActor] = useState('USER-OP-0001')
  const [cloudRef, setCloudRef] = useState('')

  // Package
  const [pkgActor, setPkgActor] = useState('USER-OP-0001')

  // Ship
  const [shipActor, setShipActor] = useState('USER-MGR-0001')

  // Transition
  const [transTarget, setTransTarget] = useState('')
  const [transActor, setTransActor] = useState('USER-MGR-0001')
  const [transReason, setTransReason] = useState('')

  if (!unit) {
    return (
      <div className="t-on-surface-var text-sm px-4 py-8 text-center">
        Select a unit to see available actions
      </div>
    )
  }

  const isTerminal = unit.package_ship_status?.terminal
  const stageNum = unit.current_stage_number
  const isCapExceeded = unit.calibration_summary?.cap_exceeded ?? false
  const hasStageForm = [5, 9, 10, 11, 12, 13, 14].includes(stageNum)
  const actionBase = `/factory/units/${unit.id}/actions`

  async function submit(fn: () => Promise<ActionResponse>) {
    setLoading(true)
    setError(null)
    setLastResponse(null)
    try {
      const resp = await fn()
      setLastResponse(resp)
      onActionComplete()
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : String(e)
      setError(msg)
    } finally {
      setLoading(false)
    }
  }

  if (isTerminal) {
    return (
      <div className="text-sm">
        <div className="px-3 py-3 rounded border surf-success b-success t-on-success font-semibold">
          TERMINAL — Unit shipped. No further actions available.
        </div>
      </div>
    )
  }

  return (
    <div className="text-sm space-y-4">
      {/* No actions available for this stage */}
      {!hasStageForm && (
        <div className="rounded border surf-low b-outline-var px-3 py-4 text-center text-sm t-on-surface-var">
          No actions available at this stage
        </div>
      )}

      {/* Stage 5 — Assembly Scan */}
      {stageNum === 5 && (
        <div className="rounded border surf b-outline-var p-3 space-y-2.5">
          <div className="font-semibold t-on-surface text-sm">Assembly Scan</div>
          <div className="text-xs font-mono text-slate-400">
            Backend-guarded action · POST {actionBase}/scan-part
          </div>
          <Field label="Part Type">
            <Input value={scanPartType} onChange={setScanPartType} placeholder="POWER_SUPPLY" />
          </Field>
          <Field label="Serial Number">
            <Input value={scanSerial} onChange={setScanSerial} placeholder="PS-SN-MOCK-0002" />
          </Field>
          <Field label="Actor User ID">
            <Input value={scanActor} onChange={setScanActor} />
          </Field>
          <Field label="Station ID">
            <Input value={scanStation} onChange={setScanStation} />
          </Field>
          <SubmitBtn
            label="Submit Scan"
            loading={loading}
            onClick={() =>
              submit(() =>
                postScanPart(unit.id, {
                  part_type: scanPartType,
                  serial_number: scanSerial,
                  actor_user_id: scanActor,
                  station_id: scanStation || undefined,
                }),
              )
            }
          />
        </div>
      )}

      {/* Stage 5 — Supervisor Reallocation */}
      {stageNum === 5 && (
        <div className="rounded border surf-supervisor b-supervisor p-3 space-y-2.5">
          <div className="font-semibold t-on-supervisor text-sm">Supervisor Reallocation</div>
          <div className="text-xs font-mono text-slate-400">
            Backend-guarded action · POST {actionBase}/reallocate-part
          </div>
          <Field label="Old Serial">
            <Input value={reallocOldSerial} onChange={setReallocOldSerial} placeholder="old serial" />
          </Field>
          <Field label="New Serial">
            <Input value={reallocNewSerial} onChange={setReallocNewSerial} placeholder="new serial" />
          </Field>
          <Field label="Reason">
            <Input value={reallocReason} onChange={setReallocReason} placeholder="reason" />
          </Field>
          <Field label="Release Reason Code">
            <Select
              value={reallocCode}
              onChange={setReallocCode}
              options={[
                { value: 'damaged_at_bench', label: 'Damaged at bench' },
                { value: 'wrong_part', label: 'Wrong part' },
                { value: 'supervisor_override', label: 'Supervisor override' },
              ]}
            />
          </Field>
          <Field label="Actor User ID (supervisor+)">
            <Input value={reallocActor} onChange={setReallocActor} />
          </Field>
          <SubmitBtn
            label="Submit Reallocation"
            loading={loading}
            variant="supervisor"
            onClick={() =>
              submit(() =>
                postReallocatePart(unit.id, {
                  part_type: scanPartType,
                  old_serial_number: reallocOldSerial,
                  new_serial_number: reallocNewSerial,
                  reason: reallocReason,
                  release_reason_code: reallocCode,
                  actor_user_id: reallocActor,
                }),
              )
            }
          />
        </div>
      )}

      {/* Stage 9 — Hardware Gate */}
      {stageNum === 9 && (
        <div className="rounded border surf-gate b-gate p-3 space-y-2.5">
          <div className="font-semibold t-on-gate text-sm">Hardware Gate</div>
          <div className="text-xs font-mono text-slate-400">
            Backend-guarded action · POST {actionBase}/hardware-gate
          </div>
          <Field label="Result">
            <Select
              value={hwResult}
              onChange={(v) => setHwResult(v as 'pass' | 'fail')}
              options={[
                { value: 'pass', label: 'Pass' },
                { value: 'fail', label: 'Fail' },
              ]}
            />
          </Field>
          <Field label="Actor User ID">
            <Input value={hwActor} onChange={setHwActor} />
          </Field>
          <Field label="Reason (optional)">
            <Input value={hwReason} onChange={setHwReason} placeholder="optional notes" />
          </Field>
          <SubmitBtn
            label="Submit Hardware Gate"
            loading={loading}
            onClick={() =>
              submit(() =>
                postHardwareGate(unit.id, {
                  result: hwResult,
                  actor_user_id: hwActor,
                  reason: hwReason || undefined,
                }),
              )
            }
          />
        </div>
      )}

      {/* Stage 10 — Calibration */}
      {stageNum === 10 && !isCapExceeded && (
        <div className="rounded border surf-gate b-gate p-3 space-y-2.5">
          <div className="font-semibold t-on-gate text-sm">Calibration</div>
          <div className="text-xs font-mono text-slate-400">
            Backend-guarded action · POST {actionBase}/calibration
          </div>
          <Field label="Result">
            <Select
              value={calResult}
              onChange={(v) => setCalResult(v as 'pass' | 'fail')}
              options={[
                { value: 'pass', label: 'Pass' },
                { value: 'fail', label: 'Fail' },
              ]}
            />
          </Field>
          <Field label="Actor User ID">
            <Input value={calActor} onChange={setCalActor} />
          </Field>
          <Field label="Reference Standard IDs (comma-separated)">
            <Input
              value={calRefStds}
              onChange={setCalRefStds}
              placeholder="REFSTD-0001"
            />
          </Field>
          <Field label="Equipment ID">
            <Input value={calEquip} onChange={setCalEquip} placeholder="CAL-EQUIP-01" />
          </Field>
          <SubmitBtn
            label="Submit Calibration"
            loading={loading}
            onClick={() =>
              submit(() =>
                postCalibration(unit.id, {
                  result: calResult,
                  actor_user_id: calActor,
                  reference_standard_ids: calRefStds.split(',').map((s) => s.trim()).filter(Boolean),
                  equipment_id: calEquip,
                }),
              )
            }
          />
        </div>
      )}

      {/* Stage 10 — Calibration Disposition (cap exceeded) */}
      {stageNum === 10 && isCapExceeded && (
        <div className="rounded border surf-error b-error p-3 space-y-2.5">
          <div className="font-semibold t-on-error text-sm">
            Calibration Disposition (Cap Exceeded)
          </div>
          <div className="text-xs font-mono text-slate-400">
            Backend-guarded action · POST {actionBase}/calibration-disposition
          </div>
          <div className="t-on-error text-xs font-medium">
            3 failed attempts. Supervisor disposition required.
          </div>
          <Field label="Disposition">
            <Select
              value={dispDisp}
              onChange={(v) =>
                setDispDisp(v as 'route_back_to_hardware' | 'scrap' | 'quarantine')
              }
              options={[
                { value: 'route_back_to_hardware', label: 'Route back to hardware' },
                { value: 'quarantine', label: 'Quarantine' },
                { value: 'scrap', label: 'Scrap' },
              ]}
            />
          </Field>
          <Field label="Actor User ID (supervisor+)">
            <Input value={dispActor} onChange={setDispActor} />
          </Field>
          <Field label="Reason">
            <Input value={dispReason} onChange={setDispReason} />
          </Field>
          <SubmitBtn
            label="Submit Disposition"
            loading={loading}
            variant="error"
            onClick={() =>
              submit(() =>
                postCalibrationDisposition(unit.id, {
                  disposition: dispDisp,
                  actor_user_id: dispActor,
                  reason: dispReason,
                }),
              )
            }
          />
        </div>
      )}

      {/* Stage 11 — QC Sign-Off */}
      {stageNum === 11 && (
        <div className="rounded border surf-gate b-gate p-3 space-y-2.5">
          <div className="font-semibold t-on-gate text-sm">QC Sign-Off (GATE)</div>
          <div className="text-xs font-mono text-slate-400">
            Backend-guarded action · POST {actionBase}/qc-signoff
          </div>
          <Field label="QC Inspector User ID">
            <Input value={qcActor} onChange={setQcActor} />
          </Field>
          <Field label="Waiver Actor User ID (optional — manager)">
            <Input value={qcWaiverActor} onChange={setQcWaiverActor} placeholder="for SOD waiver" />
          </Field>
          <Field label="Waiver Reason (optional)">
            <Input value={qcWaiverReason} onChange={setQcWaiverReason} placeholder="waiver reason" />
          </Field>
          <SubmitBtn
            label="Submit QC Sign-Off"
            loading={loading}
            onClick={() =>
              submit(() =>
                postQcSignoff(unit.id, {
                  actor_user_id: qcActor,
                  checklist: [
                    { item: 'physical_inspection', passed: true },
                    { item: 'calibration_cert', passed: true },
                  ],
                  waiver_actor_user_id: qcWaiverActor || undefined,
                  waiver_reason: qcWaiverReason || undefined,
                }),
              )
            }
          />
        </div>
      )}

      {/* Stage 12 — Cloud Backup */}
      {stageNum === 12 && (
        <div className="rounded border surf-cloud b-cloud p-3 space-y-2.5">
          <div className="font-semibold t-on-cloud text-sm flex items-center gap-2">
            Cloud Backup
            <span className="text-xs px-1.5 py-0.5 rounded border b-cloud t-on-cloud font-bold surf-container">
              CLOUD BLOCK
            </span>
          </div>
          <div className="text-xs font-mono text-slate-400">
            Backend-guarded action · POST {actionBase}/cloud-backup
          </div>
          <label
            htmlFor="cloud-avail"
            className="touch-target-secondary flex items-center gap-2 px-2 rounded cursor-pointer hover-surf-low"
          >
            <input
              type="checkbox"
              checked={cloudAvail}
              onChange={(e) => setCloudAvail(e.target.checked)}
              className="accent-blue-600 w-5 h-5"
              id="cloud-avail"
            />
            <span className="t-on-surface text-sm">Cloud Available</span>
          </label>
          {!cloudAvail && (
            <div className="t-on-error text-xs font-medium border b-error rounded p-2 surf-error">
              Cloud unavailable = hard-stop NO OVERRIDE. Backend will block.
            </div>
          )}
          <Field label="Actor User ID">
            <Input value={cloudActor} onChange={setCloudActor} />
          </Field>
          <Field label="Backup Reference (optional)">
            <Input value={cloudRef} onChange={setCloudRef} placeholder="backup ref id" />
          </Field>
          <SubmitBtn
            label="Submit Cloud Backup"
            loading={loading}
            onClick={() =>
              submit(() =>
                postCloudBackup(unit.id, {
                  cloud_available: cloudAvail,
                  actor_user_id: cloudActor,
                  backup_reference: cloudRef || undefined,
                }),
              )
            }
          />
        </div>
      )}

      {/* Stage 13 — Package */}
      {stageNum === 13 && (
        <div className="rounded border surf b-outline-var p-3 space-y-2.5">
          <div className="font-semibold t-on-surface text-sm">Package</div>
          <div className="text-xs font-mono text-slate-400">
            Backend-guarded action · POST {actionBase}/package
          </div>
          <Field label="Actor User ID">
            <Input value={pkgActor} onChange={setPkgActor} />
          </Field>
          <SubmitBtn
            label="Package Unit"
            loading={loading}
            onClick={() =>
              submit(() => postPackage(unit.id, { actor_user_id: pkgActor }))
            }
          />
        </div>
      )}

      {/* Stage 14 — Ship */}
      {stageNum === 14 && (
        <div className="rounded border surf-success b-success p-3 space-y-2.5">
          <div className="font-semibold t-on-success text-sm">Ship (TERMINAL)</div>
          <div className="text-xs font-mono text-slate-400">
            Backend-guarded action · POST {actionBase}/ship
          </div>
          <Field label="Actor User ID">
            <Input value={shipActor} onChange={setShipActor} />
          </Field>
          <SubmitBtn
            label="Ship Unit"
            loading={loading}
            onClick={() =>
              submit(() => postShip(unit.id, { actor_user_id: shipActor }))
            }
          />
        </div>
      )}

      {/* Dev — Backend-Guarded Transition */}
      <div className="rounded border surf-low b-outline-var p-3 space-y-2.5 opacity-75">
        <div className="font-semibold t-on-surface-var text-xs uppercase tracking-widest">
          Dev — Backend-Guarded Transition
        </div>
        <div className="text-xs font-mono text-slate-400">
          Backend-guarded action · POST {actionBase}/transition
        </div>
        <Field label="Target Stage ID">
          <Input value={transTarget} onChange={setTransTarget} placeholder="STAGE-06" />
        </Field>
        <Field label="Actor User ID">
          <Input value={transActor} onChange={setTransActor} />
        </Field>
        <Field label="Reason (optional)">
          <Input value={transReason} onChange={setTransReason} placeholder="reason" />
        </Field>
        <SubmitBtn
          label="Submit Transition"
          loading={loading}
          onClick={() =>
            submit(() =>
              postTransition(unit.id, {
                target_stage_id: transTarget,
                actor_user_id: transActor,
                reason: transReason || undefined,
              }),
            )
          }
        />
      </div>

      {/* Error */}
      {error && (
        <div className="rounded border surf-error b-error p-3 t-on-error text-sm">
          Error: {error}
        </div>
      )}

      {/* Last response */}
      {lastResponse && <ResponseDisplay resp={lastResponse} />}
    </div>
  )
}
