# Recon — D9C-3: Current Baseline Shared View Model Migration

STRICT MODE. No assumptions. All findings below are backed by direct file reads and
command output captured during this recon pass (2026-07-13).

## 1. Repository / Branch State

- `git branch --show-current` → `main`. No separate D9C-3 branch exists; this repo has
  executed every prior D9C node directly on `main` (confirmed by `git log --oneline -5`
  showing `88194f4 feat: add D9C-2 shared factory view model`,
  `6703ca8 docs: add D9C-1 implementation recon`,
  `a6b0bd6 feat: add D9C-1 variant review shell` as committed history). D9C-3 will
  likewise proceed on `main`.
- `git status --short` at recon start:
  ```
  ?? AGENTS.md
  ?? ai/recon/d9c2-shared-view-model.md
  ```
  - `ai/recon/d9c2-shared-view-model.md` is my own prior-session recon artifact for
    D9C-2, never committed. Pre-existing, not part of D9C-3's scope; left untouched.
  - `AGENTS.md` (repo root) is an **unexpected pre-existing untracked file**, not
    created by any D9C-1/D9C-2 work (absent from `git diff --stat` between `1882538`
    and `HEAD`, and `git log --all -- AGENTS.md` returns no history). Content is a
    verbatim copy of this project's `CLAUDE.md` boot-sequence rule. This is an
    operator-side artifact pre-dating this recon; not touched, not treated as an
    execution blocker, flagged here per the directive's "clean except explicitly
    identified pre-existing operator changes" recon requirement.
  - Both D9C-1 and D9C-2 are already fully committed (`a6b0bd6`, `6703ca8`, `88194f4`).
    No outstanding commit decision blocks D9C-3.

## 2. Predecessor State Evidence

`ai/state_registry.json`:
```json
"d9c-1-variant-review-shell": { "state": "RELEASE_APPROVED", "updated_at": "2026-07-11T19:17:23Z" },
"d9c-2-shared-view-model":    { "state": "RELEASE_APPROVED", "updated_at": "2026-07-11T19:54:21Z" }
```
Both predecessor nodes are `RELEASE_APPROVED`. No `d9c-3-*` entry exists yet (confirmed
by full registry dump — feature is unregistered, will auto-register at `RECON_READY`
when the D9C-3 spec is compiled, per `state-manager.sh advance` semantics).

D9C-1 evidence: `frontend/src/components/variant-review/{VariantReviewShell.tsx,
VariantPlaceholderPane.tsx}` exist; `frontend/src/main.tsx` contains the
`#/variants`-hash route split (read in full, §5 below).

D9C-2 evidence: `frontend/src/view-model/{types.ts,useFactoryViewModel.ts}` exist (read
in full, §4 below) and, per the D9C-2 execution-supervisor transcript
(`tasks/b76zcw36u.output`) and `tasks/d9c-2-shared-view-model-002.md`'s recorded
verification, zero existing component currently imports them
(`grep -rn "view-model" frontend/src/components/ frontend/src/main.tsx
frontend/src/App.tsx` returned no matches at D9C-2 close-out).

## 3. Boot / Enforcement Layer Checks (run fresh for this node)

- `bash vendor/engineering-os/scripts/os-adapter-check.sh` → **12 PASS / 0 FAIL**,
  `Status: adapter valid`. (Note: no `os-adapter-check.sh` exists under the local
  `scripts/` proxy dir — only under `vendor/engineering-os/scripts/`. Ran the vendor
  script directly per the directive's "OR local equivalent if OS-NATIVE" fallback;
  this repo is OS-ENABLED, so the vendor path is the correct one, not a substitute.)
- `bash scripts/invariant-check.sh` (proxies to
  `vendor/engineering-os/scripts/invariant-engine.sh`) → **6/6 PASS**
  (INV-001..INV-006).
- No literal `scripts/verification/004-invariants.sh` exists in this repo (the
  verification corpus is numbered 001–011 by topic, not by the generic names the
  directive template uses). `scripts/invariant-check.sh` is the actual, existing
  invariant wrapper and is what was run. This mirrors the same template/reality gap
  already documented for D9C-1/D9C-2 (directive templates reference generic paths;
  the adapter config's real paths are what govern). Not a conflict — the adapter
  config (`ai/state_registry.json`, `scripts/verification/`, `specs/`, `tasks/`) is
  exactly what V4/V5 of the adapter check confirmed exists and is wired correctly.
- `ai/invariant-registry.md`, referenced by the directive's doctrine-load list, does
  **not** exist in this repo (only `.engineering-os/invariants/*.sh` and
  `ai/product-invariants.md` exist). Same category as the already-documented
  `ai/execution-orchestrator.md` gap from `ai/incidents/d9c1-worker-question-not-enforced.md`
  — a doctrine-template path that isn't materialized locally. Non-blocking; the real
  invariant surface (`.engineering-os/invariants/`) was verified directly instead.
- State machine gate: current `d9c-3-*` feature is unregistered (no entry). The
  directive's literal gate text ("Required state: TASK_GRAPH_LOCKED... Invalid state:
  STOP") is generic template boilerplate written for resuming an in-flight capability;
  for a brand-new capability, `compile-spec.sh`/`state-manager.sh advance` auto-register
  at `RECON_READY` and this is the documented, correct bootstrapping path (identical to
  how D9C-1 and D9C-2 both began). Proceeding through STEP 1 (spec compile) is correct,
  not a violation of this gate.

## 4. Current Route → Component Rendering Path (exact reads)

`frontend/src/main.tsx` (full, unchanged since D9C-1):
```tsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './styles.css'
import App from './App'
import { VariantReviewShell } from './components/variant-review/VariantReviewShell'

const isVariantReviewRoute = window.location.hash.startsWith('#/variants')

function Root() {
  return isVariantReviewRoute ? <VariantReviewShell /> : <App />
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <Root />
  </StrictMode>,
)
```

`frontend/src/App.tsx` (full, unchanged since before D9C-1):
```tsx
import { FactoryFlowBoard } from './components/FactoryFlowBoard'

function App() {
  return <FactoryFlowBoard />
}

export default App
```

**Finding:** "Current" = the default (non-`#/variants`) route, which renders `<App/>`,
which renders `<FactoryFlowBoard/>` directly, with no props. This is the sole terminus
for the Current console. Confirmed — no other file renders `FactoryFlowBoard`.

## 5. FactoryFlowBoard.tsx — Complete Local-State Ownership Map (pre-migration)

Full file read (`frontend/src/components/FactoryFlowBoard.tsx`, 313 lines). Ownership,
line-referenced:

| State / callback | Lines | Category |
|---|---|---|
| `theme` (`useState<'light'\|'dark'>`, localStorage-backed) | 32–34 | **Presentation — stays local** |
| `useEffect` sets `data-theme` attr + persists to localStorage | 36–39 | **Presentation — stays local** |
| `toggleTheme` | 41 | **Presentation — stays local** |
| `health` | 43 | Factory-data — migrates |
| `contractStatus` | 44 | Factory-data — migrates |
| `stages` | 45 | Factory-data — migrates |
| `units` | 46 | Factory-data — migrates |
| `events` | 47 | Factory-data — migrates |
| `users` | 48 | Factory-data — migrates |
| `parts` | 49 | Factory-data — migrates |
| `refStandards` | 50 | Factory-data — migrates |
| `selectedUnitId` | 51 | Factory-data — migrates |
| `selectedUnit` | 52 | Factory-data — migrates |
| `loadError` | 53 | Factory-data — migrates |
| `resetting` | 54 | Factory-data — migrates |
| `compactPane` (`'unit'\|'detail'\|'stages'\|'events'`) | 58–60 | **Presentation — stays local** |
| `loadAll` (`Promise.all` of 8 fetches → 8 setters, catch→`setLoadError`) | 62–87 | Factory-data orchestration — migrates (becomes `reload`) |
| `useEffect(() => { void loadAll() }, [loadAll])` (mount load) | 89–91 | Factory-data orchestration — migrates (owned by hook's internal effect) |
| `refreshSelected` (`Promise.all` of fetchUnit/fetchEvents/fetchUnits → 3 setters, silent catch) | 93–107 | Factory-data orchestration — migrates |
| `selectUnit(id)` (`setSelectedUnitId` then `fetchUnit` → `setSelectedUnit`, catch→null) | 109–120 | Factory-data orchestration — migrates |
| `handleReset` (`setResetting(true)` → `postResetState` → clear selection → `loadAll()` → `finally setResetting(false)`) | 122–134 | Factory-data orchestration — migrates (becomes `resetDemoState`) |

Imports currently pulled directly from `../api/factoryApi` into `FactoryFlowBoard.tsx`
(lines 12–24): `ApiError, fetchDataContractStatus, fetchEvents, fetchHealth, fetchParts,
fetchRefStandards, fetchStages, fetchUnit, fetchUnits, fetchUsers, postResetState` — all
11 become dead imports in `FactoryFlowBoard.tsx` post-migration (the hook owns them).

JSX consumption sites needing the local variable → `vm.<field>` rename (all confirmed
present, no others missed): `healthOk`/`contractOk` derive from `health`/`contractStatus`
(lines 136–137); `loadError` rendered at line 183; `resetting`/`handleReset` at
188–194; `units.length` + `units` prop to `UnitList` at 248–257 alongside
`selectedUnitId`/`selectUnit`; `stages`/`selectedUnit` to `StageSpine` at 262–273;
`selectedUnit` to `UnitDetailPanel` at 284; `selectedUnit`/`users`/`refStandards`/
`refreshSelected` to `ActionPanel` at 292–297; `events`/`selectedUnitId` to `EventTrace`
at 309.

## 6. FactoryViewModel Contract Map (D9C-2, unmodified, read fresh)

`frontend/src/view-model/types.ts` (full, 29 lines) — `FactoryViewModel` interface:
```
health, contractStatus, stages, units, events, users, parts, refStandards,
selectedUnitId, selectedUnit, loadError, resetting,
selectUnit(id): Promise<void>, refreshSelected(): Promise<void>,
reload(): Promise<void>, resetDemoState(): Promise<void>
```

`frontend/src/view-model/useFactoryViewModel.ts` (full, 133 lines) — `reload` (lines
41–66) is byte-for-byte the same `Promise.all`/setter/catch shape as `loadAll` above;
mount effect at 68–70 mirrors 89–91 exactly; `refreshSelected` (72–86), `selectUnit`
(88–99), `resetDemoState` (101–113, calling `reload()` internally) mirror `handleReset`/
`refreshSelected`/`selectUnit` exactly, field-for-field, only the two documented renames
(`loadAll`→`reload`, `handleReset`→`resetDemoState`) present. Return object (115–132)
exposes all 16 members 1:1 against the interface.

## 7. Field-by-Field / Operation-by-Operation Parity Comparison

| FactoryFlowBoard (pre-migration) | FactoryViewModel field/op | Parity |
|---|---|---|
| `health` | `health` | ✅ identical type/shape |
| `contractStatus` | `contractStatus` | ✅ identical |
| `stages` | `stages` | ✅ identical |
| `units` | `units` | ✅ identical |
| `events` | `events` | ✅ identical |
| `users` | `users` | ✅ identical |
| `parts` | `parts` | ✅ identical |
| `refStandards` | `refStandards` | ✅ identical |
| `selectedUnitId` | `selectedUnitId` | ✅ identical |
| `selectedUnit` | `selectedUnit` | ✅ identical |
| `loadError` | `loadError` | ✅ identical |
| `resetting` | `resetting` | ✅ identical |
| `loadAll()` | `reload()` | ✅ identical body, renamed |
| `refreshSelected()` | `refreshSelected()` | ✅ identical, same name |
| `selectUnit(id)` | `selectUnit(id)` | ✅ identical, same name |
| `handleReset()` | `resetDemoState()` | ✅ identical body, renamed |
| mount-time `useEffect(loadAll)` | internal `useEffect(reload)` | ✅ identical trigger semantics — fires once on hook-instance mount |
| `theme` / `toggleTheme` | *(absent — by design)* | ✅ correctly excluded, presentation-only |
| `compactPane` | *(absent — by design)* | ✅ correctly excluded, presentation-only |

**Result: full 1:1 parity. No field or operation used by Current is missing from the
shared view model. No extra/unexpected field exists in the view model that Current does
not already have an equivalent for.** This is a clean migration target — unlike D9C-1
and D9C-2, this recon pass found **no conflict requiring operator STOP**. The D9C-2
hook is a faithful, complete superset-free mirror of Current's existing data
orchestration.

One structural note, not a conflict: the mount-time load in `FactoryFlowBoard` currently
fires from a `useEffect` that has `loadAll` (a `useCallback` with `[]` deps) as its own
dependency, at the component's mount. After migration, the equivalent effect lives
**inside** `useFactoryViewModel`, keyed to the hook-instance's own mount — since the hook
will be invoked exactly once, directly inside `FactoryFlowBoard`, this fires at the same
logical time (component mount) with identical effect. No behavior change.

## 8. Theme-State Ownership Finding

`theme` and `toggleTheme` (lines 32–41) have no corresponding field in
`FactoryViewModel` (confirmed via full read of `view-model/types.ts`, §6). They read
from and write to `localStorage` and a DOM attribute (`data-theme`) — concerns entirely
orthogonal to factory-data orchestration. **Finding: theme state must remain local to
`FactoryFlowBoard` — this is what the actual code proves, independent of the directive's
instruction, which happens to agree.**

## 9. Compact-Pane-State Ownership Finding

`compactPane` (lines 58–60, plus its setter used at 226, 254) has no corresponding field
in `FactoryViewModel`. It is pure responsive-layout UI state (which single pane is
visible below the `lg` breakpoint) with no relationship to factory-data. **Finding:
compact-pane state must remain local to `FactoryFlowBoard`** — same conclusion as theme,
proven directly from the type contract, not merely asserted by the directive.

## 10. API-Call Ownership — Before Migration

`frontend/src/components/FactoryFlowBoard.tsx` directly imports and calls all of:
`fetchHealth, fetchDataContractStatus, fetchStages, fetchUnits, fetchEvents, fetchUsers,
fetchParts, fetchRefStandards, fetchUnit, postResetState` (plus catches `ApiError`) from
`../api/factoryApi`. This is the only component that owns factory-data API calls today.

## 11. API-Call Ownership — After Migration

All of the above calls move exclusively to `useFactoryViewModel` (already true today,
per §6 — the hook already makes these calls; they are simply unconsumed). Post-migration,
`FactoryFlowBoard.tsx` will hold **zero** direct imports from `../api/factoryApi` and
**zero** direct factory-data API calls — it will consume everything through one
`useFactoryViewModel()` invocation. This eliminates the current duplicate-ownership
condition (both files independently calling the same 8 GETs today, with only
`FactoryFlowBoard`'s copy actually wired to the UI).

## 12. Duplicate-State-Removal Boundary

Removed entirely from `FactoryFlowBoard.tsx`: the 12 `useState` calls listed as
"Factory-data" in §5, the `loadAll`/`refreshSelected`/`selectUnit`/`handleReset`
callbacks, the mount-time `useEffect(loadAll)`, and all 11 named imports from
`../api/factoryApi`. Replaced by one `const vm = useFactoryViewModel()` (or an
equivalent destructure) plus a single new import of `useFactoryViewModel` from
`../view-model/useFactoryViewModel`.

Retained unchanged in `FactoryFlowBoard.tsx`: `theme`, `toggleTheme`, its `useEffect`,
`compactPane` and its setter, all JSX/markup, all Tailwind/token classes, all child
component props (renamed to read from `vm.*` but structurally identical), all D8/D8A/
D8B/D8C `data-*` semantic markers (lines 141–144), all header/nav/grid regions.

## 13. Protected-Surface Path Corrections (directive vs. actual repo)

The directive names `frontend/src/variants/` as an explicitly protected path. **This
path does not exist.** The actual, real path holding the three actor-first variant
components is `frontend/src/components/variant-review/` (confirmed to exist; contains
`VariantReviewShell.tsx`, `VariantPlaceholderPane.tsx`). This is the path that must be
(and will be) treated as protected in D9C-3, per the directive's own instruction to
record and protect the actual path when it differs from the listed one.

The directive also does not explicitly list `frontend/src/styles.css` among protected
surfaces, but the architecture contract's "no change to Current labels, layout, styling"
clause makes it implicitly protected for this node; treated as such.

All other explicitly protected paths were confirmed to exist exactly as named:
`frontend/src/view-model/types.ts`, `frontend/src/view-model/useFactoryViewModel.ts`,
`frontend/src/api/` (dir), `frontend/src/types/` (dir), `frontend/src/components/
{UnitList,StageSpine,UnitDetailPanel,ActionPanel,EventTrace}.tsx`, `frontend/src/
App.tsx`, `frontend/src/main.tsx`, `frontend/tailwind.config.js`, `frontend/
package.json`, `backend/`, `data/`, `docker-compose.yml`. (`migrations/`, `alembic/`
do not exist in this repo — no backend migration tooling present — so there is nothing
to protect there beyond the already-protected `backend/` directory as a whole.)

`frontend/src/index.css` (also sometimes assumed to exist by convention) does **not**
exist in this repo — the real global stylesheet is `frontend/src/styles.css`, already
covered above.

## 14. Existing Verification Surfaces

`scripts/verification/` currently contains `001` through `011` (11 scripts, topic-named,
not generically numbered per the directive's `004-invariants.sh`/`001-typecheck.sh`
naming assumption — same template/reality gap as §3). Highest existing number is `011`;
the next available sequence number for a new D9C-3 script is **`012`**. No script named
`typecheck`/`lint`/`build` exists as a standalone file — `006-factory-flow-board-ui.sh`
already exercises the frontend UI; a new `012-d9c-3-current-shared-view-model.sh` will
be the node-specific script, plus the full existing `001`–`011` corpus and
`scripts/invariant-check.sh` for regression.

`scripts/smoke.sh` exists at the repo root scripts dir and will be run per directive
instruction. `vendor/engineering-os/scripts/raystrat-os` exists (confirmed in §3's
directory listing) and supports a `verify` subcommand per the directive; will be run at
the final invariant gate as the "canonical Engineering OS verification command."

## 15. Invariant Interactions

`ai/product-invariants.md` Invariant 2 ("Backend Owns State Transitions" — frontend
never directly writes stage state) is unaffected: this migration moves *where* the same
existing read/write API calls are invoked from, not *what* they do or *whether* the
frontend gains new write paths. No new API call, no new mutation path, is introduced.
`.engineering-os/invariants/` INV-001..INV-006 (verified 6/6 PASS in §3) have no direct
bearing on a pure-frontend hook-consumption refactor; re-verified as a required gate
regardless, not because a conflict is expected.

## 16. Execution Risks

- **Mount-effect double-fire under StrictMode**: `main.tsx` renders inside
  `<StrictMode>`. Both the current inline `useEffect(loadAll)` and the hook's internal
  `useEffect(reload)` are subject to React 18 StrictMode's dev-mode double-invoke of
  effects. Since the *hook* now owns the effect instead of the component, this is a
  relocation of an existing StrictMode interaction, not a new one — behaviorally
  identical (same double-fire pattern exists today in the un-migrated component). Not a
  regression; documented for completeness.
- **Import cleanup precision**: care is required to remove exactly the 11
  `factoryApi` imports and no others from `FactoryFlowBoard.tsx` (e.g. `ApiError` is
  used only inside the now-removed `loadAll` catch block — confirmed no other use of
  `ApiError` remains in the file after removal).
- **React Hook naming collision risk**: none found — `useFactoryViewModel` is a new,
  uniquely named import; no existing identifier collision in `FactoryFlowBoard.tsx`.
- Repeat of the already-documented, non-blocking worker-prompt path gap
  (`ai/incidents/d9c1-worker-question-not-enforced.md`: dispatch prompts reference
  `ai/execution-orchestrator.md`, which only exists at
  `vendor/engineering-os/core-docs/execution-orchestrator.md`) is expected to recur in
  this node's workers; not a new risk, already accepted.

## 17. Conflict / Ambiguity Discovered

**None requiring operator STOP.** This is the first D9C-3-series recon in this session
that finds a clean, fully-parity-verified migration path with no divergence between the
incoming directive's requirements and any prior settled artifact (D9C-0 plan, D9C-1
acceptance criteria, D9C-2 spec/acceptance criteria all agree with this directive's
scope). The only items requiring recon-time correction were path-naming mismatches
between the directive's generic template language and this repo's actual structure
(§3, §13, §14), all resolved by direct inspection, none rising to a scope conflict.

Proceeding directly to STEP 1 (spec compilation) without an `AskUserQuestion` pause, per
the directive's own conflict-STOP rule (which requires stopping only when a genuine
conflict exists — none does here).
