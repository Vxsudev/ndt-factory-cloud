# Task: Extract the canonical factory view-model hook (zero consumers, zero UI change)

## Parent Spec
specs/d9c-2-shared-view-model.md

## Phase
phase-ui

## Status
done

## Layer
frontend

## Description

Create a new, standalone, currently-unimported React hook that faithfully extracts the
data-fetching/selection logic that already exists inside
`frontend/src/components/FactoryFlowBoard.tsx`. This is a pure, additive extraction —
**do not modify `FactoryFlowBoard.tsx` itself, or any other existing file, in any way.**
Nothing in the app imports or uses the new hook yet; that wiring is explicitly out of
scope for this task (it happens in later, separately-directed work).

**Context you need (self-contained — this is the exact current logic in
`FactoryFlowBoard.tsx` you must mirror faithfully, do not invent different behavior):**

```tsx
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
```

(All of `fetchHealth`, `fetchDataContractStatus`, `fetchStages`, `fetchUnits`,
`fetchEvents`, `fetchUsers`, `fetchParts`, `fetchRefStandards`, `fetchUnit`,
`postResetState`, `ApiError` are already exported from `frontend/src/api/factoryApi.ts`
exactly as used above — import them from there, do not redefine them. All of
`HealthResponse`, `DataContractStatus`, `FactoryStage`, `FactoryUnit`, `FactoryEvent`,
`FactoryUser`, `FactoryPart`, `FactoryRefStd` are already exported from
`frontend/src/types/factory.ts` — import them from there, do not redefine them.)

**Build exactly this:**

1. Create `frontend/src/view-model/types.ts` exporting:
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
   with all member types imported from `../types/factory` (no redefinition of any
   existing domain type).

2. Create `frontend/src/view-model/useFactoryViewModel.ts` exporting
   `useFactoryViewModel(): FactoryViewModel` — a custom hook whose internal
   implementation is the code block above, verbatim in behavior (same state variables,
   same `Promise.all` call order and arguments, same error handling, same mount-time
   `useEffect`), with these renames only: `loadAll` → `reload` (still called from the
   mount-time `useEffect`), `handleReset` → `resetDemoState`. The hook's return value is
   an object matching the `FactoryViewModel` shape from `types.ts`:
   `{ health, contractStatus, stages, units, events, users, parts, refStandards,
   selectedUnitId, selectedUnit, loadError, resetting, selectUnit, refreshSelected,
   reload, resetDemoState }`.

**Hard constraints (do not violate):**
- Do not modify `frontend/src/components/FactoryFlowBoard.tsx` — not even to import the
  new hook. It keeps its own independent, unmodified internal logic in this task; a
  later, separate task migrates it.
- Do not modify `frontend/src/components/variant-review/VariantReviewShell.tsx` or
  `VariantPlaceholderPane.tsx` — do not import the new hook into either. A later,
  separate task migrates each variant, one at a time.
- Do not modify `frontend/src/main.tsx`, `frontend/src/App.tsx`, `frontend/src/styles.css`,
  `frontend/src/api/factoryApi.ts`, `frontend/src/types/factory.ts`.
- Do not modify `frontend/package.json`, `frontend/package-lock.json`,
  `frontend/vite.config.ts`, `frontend/index.html`, `frontend/tsconfig.json`. Do not add
  any new npm dependency or state-management library.
- Do not modify anything under `backend/`, `data/`, `vendor/`, `.engineering-os/`,
  `scripts/`, `ai/`, `tasks/`, `specs/`.
- Do not add any actor-specific derived field (e.g. "attention items", "units assigned to
  an actor") — this task exposes only the same canonical, actor-agnostic facts
  `FactoryFlowBoard.tsx` already manages today, nothing more.
- Do not add theme or active-pane/tab state to the hook — those are not factory-domain
  data and are out of scope for this task.

## Acceptance Criteria
- [ ] `frontend/src/view-model/types.ts` exists and exports `FactoryViewModel` exactly as
      specified above, reusing existing types from `../types/factory` (no redefinition).
- [ ] `frontend/src/view-model/useFactoryViewModel.ts` exists and exports
      `useFactoryViewModel(): FactoryViewModel`, mirroring `FactoryFlowBoard.tsx`'s
      current fetch sequence, state shape, and error handling exactly (same call order,
      same error handling, same mount-time effect).
- [ ] `frontend/src/components/FactoryFlowBoard.tsx` is byte-for-byte unchanged.
- [ ] `frontend/src/components/variant-review/VariantReviewShell.tsx` and
      `VariantPlaceholderPane.tsx` are byte-for-byte unchanged.
- [ ] `frontend/src/main.tsx`, `frontend/src/App.tsx`, `frontend/src/styles.css`,
      `frontend/src/api/factoryApi.ts`, `frontend/src/types/factory.ts` are byte-for-byte
      unchanged.
- [ ] `frontend/package.json`, `frontend/package-lock.json`, `frontend/vite.config.ts`,
      `frontend/index.html`, `frontend/tsconfig.json` are byte-for-byte unchanged.
- [ ] Zero files under `backend/`, `data/`, `vendor/`, `.engineering-os/` are touched.
- [ ] The new files type-check cleanly on their own (strict mode, no `any`), even though
      nothing imports them yet.

## Files Likely Affected
- `frontend/src/view-model/types.ts` (new)
- `frontend/src/view-model/useFactoryViewModel.ts` (new)

## Blocked By
- none
