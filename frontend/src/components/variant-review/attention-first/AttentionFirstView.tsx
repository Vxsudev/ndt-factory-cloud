import { useState } from 'react'
import { useFactoryViewModel } from '../../../view-model/useFactoryViewModel'
import { AssemblerView } from './AssemblerView'
import { FloorManagerView } from './FloorManagerView'

type ActorId = 'assembler' | 'floorManager'

const ACTOR_LABELS: Record<ActorId, string> = {
  assembler: 'Assembler',
  floorManager: 'Floor Manager',
}

export function AttentionFirstView() {
  const vm = useFactoryViewModel()
  const [activeActor, setActiveActor] = useState<ActorId>('assembler')

  return (
    <div data-attention-first-view="true">
      <div className="variant-review-tab-bar variant-review-tab-bar-secondary">
        {(Object.keys(ACTOR_LABELS) as ActorId[]).map((actorId) => {
          const selected = activeActor === actorId
          return (
            <button
              key={actorId}
              type="button"
              onClick={() => setActiveActor(actorId)}
              className={
                selected
                  ? 'touch-target-secondary surf-primary t-on-primary'
                  : 'touch-target-secondary surf-container t-on-surface b-outline-var'
              }
            >
              {ACTOR_LABELS[actorId]}
            </button>
          )
        })}
      </div>

      {vm.loadError && <div className="px-4 py-2 t-on-error text-sm">Error: {vm.loadError}</div>}

      {vm.units.length === 0 && !vm.loadError ? (
        <div className="t-on-surface-var text-sm px-4 py-8 text-center">Loading…</div>
      ) : activeActor === 'assembler' ? (
        <AssemblerView vm={vm} />
      ) : (
        <FloorManagerView vm={vm} />
      )}
    </div>
  )
}
