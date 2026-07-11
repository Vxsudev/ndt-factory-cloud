import { useState } from 'react'

type ActorId = 'assembler' | 'floorManager'

const ACTOR_LABELS: Record<ActorId, string> = {
  assembler: 'Assembler',
  floorManager: 'Floor Manager',
}

interface VariantPlaceholderPaneProps {
  variantId: 'variantA' | 'variantB' | 'variantC'
  variantLabel: string
}

export function VariantPlaceholderPane({ variantId, variantLabel }: VariantPlaceholderPaneProps) {
  const [activeActor, setActiveActor] = useState<ActorId>('assembler')

  return (
    <div data-variant-id={variantId}>
      <div className="variant-review-tab-bar variant-review-tab-bar-secondary">
        {(Object.keys(ACTOR_LABELS) as ActorId[]).map(actorId => {
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
      <div className="mdc-card mdc-card-container variant-review-placeholder-body">
        <p className="t-on-surface">{variantLabel}</p>
        <p className="t-on-surface-var">{ACTOR_LABELS[activeActor]}</p>
        <p className="t-on-surface-var">
          Presentation content for this view ships in a later phase.
        </p>
      </div>
    </div>
  )
}
