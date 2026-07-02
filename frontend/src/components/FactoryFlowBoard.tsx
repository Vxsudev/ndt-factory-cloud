import { useCallback, useEffect, useState } from 'react'
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
import {
  ApiError,
  fetchDataContractStatus,
  fetchEvents,
  fetchHealth,
  fetchParts,
  fetchRefStandards,
  fetchStages,
  fetchUnit,
  fetchUnits,
  fetchUsers,
  postResetState,
} from '../api/factoryApi'
import { UnitList } from './UnitList'
import { StageSpine } from './StageSpine'
import { UnitDetailPanel } from './UnitDetailPanel'
import { ActionPanel } from './ActionPanel'
import { EventTrace } from './EventTrace'

export function FactoryFlowBoard() {
  const [theme, setTheme] = useState<'light' | 'dark'>(
    () => (localStorage.getItem('factory-theme') === 'dark' ? 'dark' : 'light')
  )

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme)
    localStorage.setItem('factory-theme', theme)
  }, [theme])

  const toggleTheme = () => setTheme(t => (t === 'light' ? 'dark' : 'light'))

  const [health, setHealth] = useState<HealthResponse | null>(null)
  const [contractStatus, setContractStatus] = useState<DataContractStatus | null>(null)
  const [stages, setStages] = useState<FactoryStage[]>([])
  const [units, setUnits] = useState<FactoryUnit[]>([])
  const [events, setEvents] = useState<FactoryEvent[]>([])
  const [users, setUsers] = useState<FactoryUser[]>([])
  const [parts, setParts] = useState<FactoryPart[]>([])
  const [refStandards, setRefStandards] = useState<FactoryRefStd[]>([])
  const [selectedUnitId, setSelectedUnitId] = useState<string | null>(null)
  const [selectedUnit, setSelectedUnit] = useState<FactoryUnit | null>(null)
  const [loadError, setLoadError] = useState<string | null>(null)
  const [resetting, setResetting] = useState(false)

  // D8C — compact-width (<1024px) active pane. Irrelevant at lg+ where all
  // regions render simultaneously per the existing desktop layout.
  const [compactPane, setCompactPane] = useState<'unit' | 'detail' | 'stages' | 'events'>(
    'detail',
  )

  const loadAll = useCallback(async () => {
    setLoadError(null)
    try {
      const [h, cs, st, us, ev, usr, pts, refs] = await Promise.all([
        fetchHealth(),
        fetchDataContractStatus(),
        fetchStages(),
        fetchUnits(),
        fetchEvents(),
        fetchUsers(),
        fetchParts(),
        fetchRefStandards(),
      ])
      setHealth(h)
      setContractStatus(cs)
      setStages(st)
      setUnits(us)
      setEvents(ev)
      setUsers(usr)
      setParts(pts)
      setRefStandards(refs)
    } catch (e: unknown) {
      const msg = e instanceof ApiError ? `HTTP ${e.status}: ${e.message}` : String(e)
      setLoadError(msg)
    }
  }, [])

  useEffect(() => {
    void loadAll()
  }, [loadAll])

  const refreshSelected = useCallback(async () => {
    if (!selectedUnitId) return
    try {
      const [u, evts, us] = await Promise.all([
        fetchUnit(selectedUnitId),
        fetchEvents(),
        fetchUnits(),
      ])
      setSelectedUnit(u)
      setEvents(evts)
      setUnits(us)
    } catch {
      // silent — unit may have been reset
    }
  }, [selectedUnitId])

  const selectUnit = useCallback(
    async (id: string) => {
      setSelectedUnitId(id)
      try {
        const u = await fetchUnit(id)
        setSelectedUnit(u)
      } catch {
        setSelectedUnit(null)
      }
    },
    [],
  )

  const handleReset = useCallback(async () => {
    setResetting(true)
    try {
      await postResetState()
      setSelectedUnitId(null)
      setSelectedUnit(null)
      await loadAll()
    } catch {
      /* ignore */
    } finally {
      setResetting(false)
    }
  }, [loadAll])

  const healthOk = health?.status === 'ok'
  const contractOk = contractStatus?.status === 'ok'

  return (
    <div
      data-d8-demo-readiness="true"
      data-d8a-readability="true"
      data-d8b-material-theme="true"
      data-d8c-touch-responsive="true"
      className="app-bg min-h-screen flex flex-col"
    >
      {/* Header */}
      <header className="border-b surf b-outline-var px-5 py-4 flex items-center justify-between gap-4 flex-wrap">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="text-2xl font-bold tracking-tight t-on-surface">Factory Cloud v0</h1>
            <span className="px-2 py-0.5 rounded text-xs font-bold surf-primary b-primary t-on-primary border">
              Postgres-backed
            </span>
          </div>
          <p className="text-sm t-on-surface-var mt-0.5">D8 Review Prototype</p>
        </div>

        <div className="flex items-center gap-4 flex-wrap">
          {/* Health indicator */}
          <div className="flex items-center gap-1.5 text-sm">
            <div
              className={`w-2 h-2 rounded-full ${healthOk ? 'bg-green-500' : 'bg-red-500'}`}
            />
            <span className="t-on-surface-var">Backend</span>
            <span className={healthOk ? 'text-green-600 font-medium' : 'text-red-600 font-medium'}>
              {health ? health.status : '…'}
            </span>
          </div>

          {/* Contract indicator */}
          <div className="flex items-center gap-1.5 text-sm">
            <div
              className={`w-2 h-2 rounded-full ${contractOk ? 'bg-green-500' : 'bg-amber-500'}`}
            />
            <span className="t-on-surface-var">Data Contract</span>
            <span className={contractOk ? 'text-green-600 font-medium' : 'text-amber-600 font-medium'}>
              {contractStatus ? `${contractStatus.stage_count} stages / ${contractStatus.unit_count} units` : '…'}
            </span>
          </div>

          {/* Error */}
          {loadError && (
            <span className="t-on-error text-sm">Error: {loadError}</span>
          )}

          {/* Reset */}
          <button
            onClick={() => void handleReset()}
            disabled={resetting}
            className="touch-target-primary inline-flex items-center justify-center px-4 rounded border b-outline surf hover-surf-low text-sm t-on-surface font-medium disabled:opacity-50 transition-colors"
          >
            {resetting ? 'Resetting…' : 'Reset Demo State'}
          </button>

          {/* Theme toggle */}
          <button
            onClick={toggleTheme}
            className="touch-target-primary inline-flex items-center justify-center px-4 rounded border b-outline surf hover-surf-low text-sm t-on-surface font-medium transition-colors"
          >
            {theme === 'light' ? 'Dark' : 'Light'}
          </button>
        </div>
      </header>

      {/* Compact-width (<1024px) pane switcher — irrelevant at lg+, all
          regions render simultaneously there. */}
      <nav
        className="lg:hidden flex items-stretch gap-1.5 px-2 py-1.5 border-b b-outline-var surf overflow-x-auto"
        role="tablist"
        aria-label="Factory view"
      >
        {(
          [
            { key: 'unit', label: 'Unit Queue' },
            { key: 'detail', label: 'Detail' },
            { key: 'stages', label: 'Stages' },
            { key: 'events', label: 'Events' },
          ] as const
        ).map((pane) => (
          <button
            key={pane.key}
            type="button"
            role="tab"
            aria-selected={compactPane === pane.key}
            onClick={() => setCompactPane(pane.key)}
            className={`touch-target-primary shrink-0 px-4 rounded border text-sm font-semibold transition-colors ${
              compactPane === pane.key
                ? 'surf-primary b-primary t-on-primary'
                : 'surf-low b-outline-var t-on-surface-var'
            }`}
          >
            {pane.label}
          </button>
        ))}
      </nav>

      {/* Main grid — single active pane below lg, all four regions
          simultaneously visible at lg+ (unchanged desktop layout). */}
      <div
        className={`${compactPane === 'events' ? 'hidden' : 'flex'} lg:flex flex-1 min-h-0 flex-col lg:flex-row overflow-hidden`}
      >
        {/* Unit Queue */}
        <div
          className={`${compactPane === 'unit' ? 'flex' : 'hidden'} lg:flex flex-1 min-h-0 lg:flex-none flex-col border-r-0 lg:border-r b-outline-var overflow-y-auto p-3 w-full lg:w-56 xl:w-64 min-[1600px]:w-72`}
        >
          <div className="text-xs font-semibold uppercase tracking-widest t-on-surface-var mb-3">
            Unit Queue ({units.length})
          </div>
          <UnitList
            units={units}
            selectedId={selectedUnitId}
            onSelect={(id) => {
              setCompactPane('detail')
              void selectUnit(id)
            }}
          />
        </div>

        {/* Stage Spine */}
        <div
          className={`${compactPane === 'stages' ? 'flex' : 'hidden'} lg:flex flex-1 min-h-0 lg:flex-none flex-col border-r-0 lg:border-r b-outline-var overflow-y-auto p-3 w-full lg:w-72 xl:w-80 min-[1600px]:w-96`}
        >
          <div className="text-xs font-semibold uppercase tracking-widest t-on-surface-var mb-3">
            14-Stage Production Spine
            {selectedUnit && (
              <span className="ml-2 t-primary normal-case font-normal">
                · {selectedUnit.id}
              </span>
            )}
          </div>
          <StageSpine stages={stages} selectedUnit={selectedUnit} />
        </div>

        {/* Detail + Action */}
        <div
          className={`${compactPane === 'detail' ? 'flex' : 'hidden'} lg:flex flex-1 min-h-0 flex-col overflow-y-auto p-4 gap-5 w-full`}
        >
          {/* Unit Detail */}
          <div>
            <div className="text-xs font-semibold uppercase tracking-widest t-on-surface-var mb-3">
              Unit Detail
            </div>
            <UnitDetailPanel unit={selectedUnit} />
          </div>

          {/* Action Panel */}
          <div>
            <div className="text-xs font-semibold uppercase tracking-widest t-on-surface-var mb-3">
              Action Panel
            </div>
            <ActionPanel
              unit={selectedUnit}
              users={users}
              refStandards={refStandards}
              onActionComplete={() => void refreshSelected()}
            />
          </div>
        </div>
      </div>

      {/* Event Trace — bottom footer at lg+, full switchable pane below lg */}
      <div
        className={`${compactPane === 'events' ? 'flex' : 'hidden'} lg:flex flex-1 min-h-0 lg:flex-none flex-col border-t surf b-outline-var px-5 py-4 lg:max-h-64 overflow-y-auto`}
      >
        <div className="text-xs font-semibold uppercase tracking-widest t-on-surface-var mb-3">
          Event Trace
        </div>
        <EventTrace events={events} selectedUnitId={selectedUnitId} />
      </div>
    </div>
  )
}
