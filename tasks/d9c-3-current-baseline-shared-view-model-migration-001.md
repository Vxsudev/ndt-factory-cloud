# Task: Migrate FactoryFlowBoard to consume useFactoryViewModel; add D9C-3 verification script

## Parent Spec
specs/d9c-3-current-baseline-shared-view-model-migration.md

## Phase
phase-ui

## Status
done

## Layer
frontend

## Description

You have no prior conversation context. Read
`specs/d9c-3-current-baseline-shared-view-model-migration.md` in full before starting —
it is the authority for this task. This description restates the essential facts so you
can work without further exploration, but the spec is the final word if anything here
is ambiguous.

**Goal:** `frontend/src/components/FactoryFlowBoard.tsx` currently owns its own
factory-data fetching/selection/reset logic. A prior capability (D9C-2) already created
`frontend/src/view-model/useFactoryViewModel.ts`, a hook that faithfully mirrors this
exact same logic, but nothing consumes it yet. Your job: make `FactoryFlowBoard.tsx`
consume that hook instead of its own local copy, with **zero change to rendered
behavior, layout, styling, or interaction**. Then create a new verification script that
proves the migration.

### Part A — Migrate `frontend/src/components/FactoryFlowBoard.tsx`

The file's current content (313 lines) begins:

```tsx
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
    // ... JSX unchanged below this point (Unit Queue count, StageSpine, UnitDetailPanel,
    // ActionPanel onActionComplete, EventTrace, header health/contract indicators,
    // Reset Demo State button, theme toggle button, compact-pane nav — all reference
    // the variables above by name)
  )
}
```

The hook you must consume, `frontend/src/view-model/useFactoryViewModel.ts` (do not
modify this file — read-only reference), exports:

```ts
export function useFactoryViewModel(): FactoryViewModel
```

where `FactoryViewModel` (from `frontend/src/view-model/types.ts`, also read-only) is:

```ts
export interface FactoryViewModel {
  health: HealthResponse | null
  contractStatus: DataContractStatus | null
  stages: FactoryStage[]
  units: FactoryUnit[]
  events: FactoryEvent[]
  users: FactoryUser[]
  parts: FactoryPart[]
  refStandards: FactoryRefStd[]
  selectedUnitId: string | null
  selectedUnit: FactoryUnit | null
  loadError: string | null
  resetting: boolean
  selectUnit: (id: string) => Promise<void>
  refreshSelected: () => Promise<void>
  reload: () => Promise<void>
  resetDemoState: () => Promise<void>
}
```

**Required edits to `FactoryFlowBoard.tsx`:**

1. Add `import { useFactoryViewModel } from '../view-model/useFactoryViewModel'`.
2. Remove the entire `import { ApiError, fetchDataContractStatus, ... } from
   '../api/factoryApi'` block (all 11 named imports) — nothing in the migrated file
   should import from `../api/factoryApi` anymore.
3. Remove the 12 `useState` declarations for `health, contractStatus, stages, units,
   events, users, parts, refStandards, selectedUnitId, selectedUnit, loadError,
   resetting`.
4. Remove the `loadAll`, `refreshSelected`, `selectUnit`, `handleReset` callback
   definitions and the `useEffect(() => { void loadAll() }, [loadAll])` block.
5. Add one hook invocation in their place, e.g. `const vm = useFactoryViewModel()`
   (any reasonable local name is fine, but be consistent).
6. Update every remaining reference in the function body and JSX to read from the hook
   result instead of the removed locals:
   - `health` → `vm.health` (used to compute `healthOk` and in the header health
     indicator)
   - `contractStatus` → `vm.contractStatus` (used to compute `contractOk` and in the
     header contract indicator)
   - `loadError` → `vm.loadError` (header error span)
   - `resetting` → `vm.resetting`, `handleReset` → `vm.resetDemoState` (Reset Demo
     State button `onClick`/`disabled`)
   - `units` → `vm.units` (Unit Queue count and `UnitList` `units` prop)
   - `selectedUnitId` → `vm.selectedUnitId` (`UnitList` `selectedId` prop, `EventTrace`
     `selectedUnitId` prop)
   - `selectUnit` → `vm.selectUnit` (`UnitList`'s `onSelect` callback body)
   - `stages` → `vm.stages` (`StageSpine` `stages` prop)
   - `selectedUnit` → `vm.selectedUnit` (`StageSpine`, `UnitDetailPanel`, `ActionPanel`
     props, and the "· {selectedUnit.id}" label in the Stage Spine header)
   - `users` → `vm.users`, `refStandards` → `vm.refStandards` (`ActionPanel` props)
   - `refreshSelected` → `vm.refreshSelected` (`ActionPanel`'s `onActionComplete`
     callback body)
   - `events` → `vm.events` (`EventTrace` `events` prop)
7. Do **not** touch: `theme`, `setTheme`/`toggleTheme`, the theme `useEffect`,
   `compactPane`/`setCompactPane`. These stay exactly as they are today — same
   `useState` calls, same effect, same behavior. Keep the `useState`/`useEffect`
   import from `react` (still needed for these two pieces of local state). Remove
   `useCallback` from the `react` import only if nothing in the file still uses it
   after the above removals (check — `toggleTheme` does not use `useCallback` today).
8. Do not change any JSX structure, class names, layout, labels, or `data-*` markers.
   Do not change `UnitList`/`StageSpine`/`UnitDetailPanel`/`ActionPanel`/`EventTrace`
   prop *names* or *types* — only the values passed now come from `vm.*`.
9. Confirm no other file (`main.tsx`, `App.tsx`, any variant-review component) needs
   any change — they don't; `FactoryFlowBoard` is still rendered exactly as before.

### Part B — Create `scripts/verification/012-d9c-3-current-shared-view-model.sh`

Create a new, executable (`chmod +x`) bash script at this exact path. Model its style
on the existing scripts in `scripts/verification/` (e.g. `006-factory-flow-board-ui.sh`)
— use `set -e`, clear PASS/FAIL echo lines, and a non-zero exit on any failed check.
It must verify, via `grep`/static file checks (no live browser needed — this is a
static structural check; live behavior is verified separately, by a human, outside
this task):

1. `frontend/src/components/FactoryFlowBoard.tsx` contains
   `useFactoryViewModel` in an import line referencing `../view-model/useFactoryViewModel`.
2. `frontend/src/components/FactoryFlowBoard.tsx` contains exactly one call site of
   `useFactoryViewModel(` (i.e. invoked exactly once).
3. `frontend/src/components/FactoryFlowBoard.tsx` contains **no** import from
   `'../api/factoryApi'`.
4. `frontend/src/components/FactoryFlowBoard.tsx` still declares a `theme` state
   variable (e.g. `grep` for `useState<'light' | 'dark'>` or `const [theme,`) and a
   `compactPane` state variable (e.g. `grep` for `compactPane`).
5. `frontend/src/components/variant-review/VariantReviewShell.tsx` and
   `VariantPlaceholderPane.tsx` still contain **no** import from `'../../api/factoryApi'`
   or `'../../view-model/useFactoryViewModel'` (they remain unwired, per D9C-1's
   original acceptance criteria — this capability must not have touched them).
6. No file under `backend/` was modified during this task
   (`git diff --stat -- backend/` from repo root should be empty — if `git` is
   unavailable in the execution sandbox, skip this specific check and note it in your
   summary rather than failing the whole script).

Print a final `Result: N/N PASS` line and `exit 0` only if every check passes;
`exit 1` on any failure with a clear `✗` line identifying which check failed.

## Acceptance Criteria
- [ ] `FactoryFlowBoard.tsx` imports and invokes `useFactoryViewModel` exactly once.
- [ ] All 12 factory-data `useState`s and the 4 orchestration callbacks and the
      mount-load effect are removed from `FactoryFlowBoard.tsx`; every read-site now
      reads from the hook result.
- [ ] `FactoryFlowBoard.tsx` has zero direct imports from `../api/factoryApi`.
- [ ] `theme`/`toggleTheme`/theme-effect and `compactPane` remain local, unchanged in
      behavior.
- [ ] All child-component prop names/types are unchanged; only values now come from
      the hook.
- [ ] All D8/D8A/D8B/D8C semantic markers and existing labels/regions remain present.
- [ ] `frontend/src/view-model/types.ts`, `useFactoryViewModel.ts` are untouched.
- [ ] `frontend/src/components/variant-review/*` are untouched.
- [ ] `scripts/verification/012-d9c-3-current-shared-view-model.sh` exists, is
      executable, and passes all its own checks against the migrated code.
- [ ] No file under `backend/`, `data/`, `vendor/`, `.engineering-os/` touched.

## Files Likely Affected
- frontend/src/components/FactoryFlowBoard.tsx
- scripts/verification/012-d9c-3-current-shared-view-model.sh (new)

## Blocked By
- none
