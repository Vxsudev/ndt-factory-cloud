import { useEffect, useState } from 'react'

interface ContractStatus {
  status: string
  phase: string
  read_only: boolean
  domain_logic_enabled: boolean
  data_files_loaded: string[]
  unit_count: number
  stage_count: number
}

type ContractState =
  | { state: 'loading' }
  | { state: 'ok'; data: ContractStatus }
  | { state: 'error'; message: string }

const API_BASE = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8000'

async function fetchContractStatus(): Promise<ContractStatus> {
  const res = await fetch(`${API_BASE}/factory/data-contract/status`)
  if (!res.ok) {
    throw new Error(`Data contract status failed: ${res.status}`)
  }
  return res.json() as Promise<ContractStatus>
}

export function DataContractStatus() {
  const [contract, setContract] = useState<ContractState>({ state: 'loading' })

  useEffect(() => {
    fetchContractStatus()
      .then((data) => setContract({ state: 'ok', data }))
      .catch((err: unknown) =>
        setContract({
          state: 'error',
          message: err instanceof Error ? err.message : 'Unknown error',
        })
      )
  }, [])

  if (contract.state === 'loading') {
    return (
      <div className="text-sm text-gray-500 animate-pulse">
        Loading data contract status...
      </div>
    )
  }

  if (contract.state === 'error') {
    return (
      <div className="text-sm text-red-500">
        Data contract unavailable — {contract.message}
      </div>
    )
  }

  const { data } = contract

  return (
    <div className="space-y-2 text-sm">
      <div className="flex justify-between">
        <span className="text-gray-400">Phase</span>
        <span className="font-mono text-blue-300">{data.phase}</span>
      </div>
      <div className="flex justify-between">
        <span className="text-gray-400">Stage count</span>
        <span className="font-mono text-green-400">{data.stage_count} stages</span>
      </div>
      <div className="flex justify-between">
        <span className="text-gray-400">Unit count</span>
        <span className="font-mono text-green-400">{data.unit_count} units</span>
      </div>
      <div className="flex justify-between">
        <span className="text-gray-400">Read-only</span>
        <span className="font-mono text-green-400">{String(data.read_only)}</span>
      </div>
      <div className="flex justify-between">
        <span className="text-gray-400">Domain logic</span>
        <span className="font-mono text-amber-400">
          {data.domain_logic_enabled ? 'enabled' : 'not implemented'}
        </span>
      </div>
      <div className="pt-1 border-t border-gray-800">
        <span className="text-xs text-gray-500">
          Files loaded: {data.data_files_loaded.join(', ')}
        </span>
      </div>
    </div>
  )
}
