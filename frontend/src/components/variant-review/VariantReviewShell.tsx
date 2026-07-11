import { useState } from 'react'
import { FactoryFlowBoard } from '../FactoryFlowBoard'
import { VariantPlaceholderPane } from './VariantPlaceholderPane'

type TabId = 'current' | 'variantA' | 'variantB' | 'variantC'

const TABS: { id: TabId; label: string }[] = [
  { id: 'current', label: 'Current' },
  { id: 'variantA', label: 'Variant A — Attention-First' },
  { id: 'variantB', label: 'Variant B — Workflow-First' },
  { id: 'variantC', label: 'Variant C — Command-Center' },
]

export function VariantReviewShell() {
  const [activeTab, setActiveTab] = useState<TabId>('current')

  return (
    <div data-d9c1-variant-review-shell="true">
      <div className="variant-review-tab-bar variant-review-tab-bar-primary">
        {TABS.map(tab => {
          const selected = activeTab === tab.id
          return (
            <button
              key={tab.id}
              type="button"
              onClick={() => setActiveTab(tab.id)}
              className={
                selected
                  ? 'touch-target-primary surf-primary t-on-primary'
                  : 'touch-target-primary surf-container t-on-surface b-outline-var'
              }
            >
              {tab.label}
            </button>
          )
        })}
      </div>
      {activeTab === 'current' && <FactoryFlowBoard />}
      {activeTab === 'variantA' && (
        <VariantPlaceholderPane variantId="variantA" variantLabel="Variant A — Attention-First" />
      )}
      {activeTab === 'variantB' && (
        <VariantPlaceholderPane variantId="variantB" variantLabel="Variant B — Workflow-First" />
      )}
      {activeTab === 'variantC' && (
        <VariantPlaceholderPane variantId="variantC" variantLabel="Variant C — Command-Center" />
      )}
    </div>
  )
}
