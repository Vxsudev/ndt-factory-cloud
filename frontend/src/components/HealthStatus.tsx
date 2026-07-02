import { useEffect, useState } from 'react'
import type { HealthState } from '../types'
import { fetchHealth } from '../api'

export function HealthStatus() {
  const [health, setHealth] = useState<HealthState>({ state: 'loading' })

  useEffect(() => {
    fetchHealth()
      .then((data) => setHealth({ state: 'ok', data }))
      .catch((err: unknown) =>
        setHealth({
          state: 'error',
          message: err instanceof Error ? err.message : 'Unknown error',
        })
      )
  }, [])

  if (health.state === 'loading') {
    return (
      <div className="flex items-center gap-2 text-gray-500">
        <span className="inline-block h-3 w-3 animate-pulse rounded-full bg-gray-400" />
        Checking backend health...
      </div>
    )
  }

  if (health.state === 'error') {
    return (
      <div className="flex items-center gap-2 text-red-600">
        <span className="inline-block h-3 w-3 rounded-full bg-red-500" />
        Backend unreachable — {health.message}
      </div>
    )
  }

  return (
    <div className="flex items-center gap-2 text-green-700">
      <span className="inline-block h-3 w-3 rounded-full bg-green-500" />
      Backend healthy — {health.data.service} ({health.data.phase})
    </div>
  )
}
