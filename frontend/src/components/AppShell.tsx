import { HealthStatus } from './HealthStatus'
import { DataContractStatus } from './DataContractStatus'
import { D5BackendStatus } from './D5BackendStatus'

const STACK = [
  { layer: 'Frontend', tech: 'React 18 + Vite 5 + TypeScript' },
  { layer: 'UI', tech: 'Tailwind CSS 3 (shadcn-ready)' },
  { layer: 'Backend', tech: 'FastAPI + Pydantic + Uvicorn' },
  { layer: 'State (v0)', tech: 'Mock JSON / data/*.json' },
  { layer: 'Runtime', tech: 'Docker Compose' },
]

export function AppShell() {
  return (
    <div className="min-h-screen bg-gray-950 text-gray-100">
      <header className="border-b border-gray-800 px-6 py-4">
        <h1 className="text-2xl font-bold tracking-tight">Factory Cloud v0</h1>
        <p className="mt-1 text-sm text-gray-400">
          Dockerized production-flow prototype scaffold.
        </p>
      </header>

      <main className="mx-auto max-w-3xl px-6 py-10 space-y-10">

        <section className="rounded-lg border border-blue-800 bg-blue-950 px-5 py-4">
          <div className="text-xs font-semibold uppercase tracking-widest text-blue-400 mb-1">
            Current Phase
          </div>
          <div className="text-lg font-semibold text-blue-200">D5 Backend State Behavior</div>
          <div className="mt-2 text-xs text-blue-400">
            Next phase: <span className="text-blue-300">D6 Factory Flow Board</span>
          </div>
        </section>

        <section>
          <h2 className="text-xs font-semibold uppercase tracking-widest text-gray-500 mb-3">
            Backend Behavior
          </h2>
          <div className="rounded-lg border border-gray-800 bg-gray-900 px-5 py-4">
            <D5BackendStatus />
          </div>
        </section>

        <section>
          <h2 className="text-xs font-semibold uppercase tracking-widest text-gray-500 mb-3">
            Data Contract
          </h2>
          <div className="rounded-lg border border-gray-800 bg-gray-900 px-5 py-4">
            <DataContractStatus />
          </div>
        </section>

        <section>
          <h2 className="text-xs font-semibold uppercase tracking-widest text-gray-500 mb-3">
            Backend Health
          </h2>
          <div className="rounded-lg border border-gray-800 bg-gray-900 px-5 py-4 text-sm">
            <HealthStatus />
          </div>
        </section>

        <section>
          <h2 className="text-xs font-semibold uppercase tracking-widest text-gray-500 mb-3">
            Scaffold Status
          </h2>
          <div className="rounded-lg border border-gray-800 bg-gray-900 px-5 py-4 space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-gray-400">Domain logic</span>
              <span className="font-mono text-green-400">enabled (in-memory, D5)</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Stage model</span>
              <span className="font-mono text-green-400">locked (14 stages)</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Factory Flow Board</span>
              <span className="font-mono text-amber-400">not implemented (D5+)</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Database</span>
              <span className="font-mono text-amber-400">none (in-memory in D5)</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Data API</span>
              <span className="font-mono text-green-400">read-only (D4)</span>
            </div>
          </div>
        </section>

        <section>
          <h2 className="text-xs font-semibold uppercase tracking-widest text-gray-500 mb-3">
            Stack
          </h2>
          <div className="rounded-lg border border-gray-800 bg-gray-900 overflow-hidden">
            <table className="w-full text-sm">
              <tbody>
                {STACK.map(({ layer, tech }) => (
                  <tr key={layer} className="border-b border-gray-800 last:border-0">
                    <td className="px-5 py-3 text-gray-400 w-36">{layer}</td>
                    <td className="px-5 py-3 font-mono text-gray-200">{tech}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>

      </main>
    </div>
  )
}
