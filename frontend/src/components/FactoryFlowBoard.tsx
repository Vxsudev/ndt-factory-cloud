import { useEffect, useState } from 'react'
import { useFactoryViewModel } from '../view-model/useFactoryViewModel'
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

  const vm = useFactoryViewModel()

  // D8C — compact-width (<1024px) active pane. Irrelevant at lg+ where all
  // regions render simultaneously per the existing desktop layout.
  const [compactPane, setCompactPane] = useState<'unit' | 'detail' | 'stages' | 'events'>(
    'detail',
  )

  const healthOk = vm.health?.status === 'ok'
  const contractOk = vm.contractStatus?.status === 'ok'

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
              {vm.health ? vm.health.status : '…'}
            </span>
          </div>

          {/* Contract indicator */}
          <div className="flex items-center gap-1.5 text-sm">
            <div
              className={`w-2 h-2 rounded-full ${contractOk ? 'bg-green-500' : 'bg-amber-500'}`}
            />
            <span className="t-on-surface-var">Data Contract</span>
            <span className={contractOk ? 'text-green-600 font-medium' : 'text-amber-600 font-medium'}>
              {vm.contractStatus ? `${vm.contractStatus.stage_count} stages / ${vm.contractStatus.unit_count} units` : '…'}
            </span>
          </div>

          {/* Error */}
          {vm.loadError && (
            <span className="t-on-error text-sm">Error: {vm.loadError}</span>
          )}

          {/* Reset */}
          <button
            onClick={() => void vm.resetDemoState()}
            disabled={vm.resetting}
            className="touch-target-primary inline-flex items-center justify-center px-4 rounded border b-outline surf hover-surf-low text-sm t-on-surface font-medium disabled:opacity-50 transition-colors"
          >
            {vm.resetting ? 'Resetting…' : 'Reset Demo State'}
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
            Unit Queue ({vm.units.length})
          </div>
          <UnitList
            units={vm.units}
            selectedId={vm.selectedUnitId}
            onSelect={(id) => {
              setCompactPane('detail')
              void vm.selectUnit(id)
            }}
          />
        </div>

        {/* Stage Spine */}
        <div
          className={`${compactPane === 'stages' ? 'flex' : 'hidden'} lg:flex flex-1 min-h-0 lg:flex-none flex-col border-r-0 lg:border-r b-outline-var overflow-y-auto p-3 w-full lg:w-72 xl:w-80 min-[1600px]:w-96`}
        >
          <div className="text-xs font-semibold uppercase tracking-widest t-on-surface-var mb-3">
            14-Stage Production Spine
            {vm.selectedUnit && (
              <span className="ml-2 t-primary normal-case font-normal">
                · {vm.selectedUnit.id}
              </span>
            )}
          </div>
          <StageSpine stages={vm.stages} selectedUnit={vm.selectedUnit} />
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
            <UnitDetailPanel unit={vm.selectedUnit} />
          </div>

          {/* Action Panel */}
          <div>
            <div className="text-xs font-semibold uppercase tracking-widest t-on-surface-var mb-3">
              Action Panel
            </div>
            <ActionPanel
              unit={vm.selectedUnit}
              users={vm.users}
              refStandards={vm.refStandards}
              onActionComplete={() => void vm.refreshSelected()}
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
        <EventTrace events={vm.events} selectedUnitId={vm.selectedUnitId} />
      </div>
    </div>
  )
}
