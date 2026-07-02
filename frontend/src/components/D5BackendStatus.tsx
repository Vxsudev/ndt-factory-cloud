export function D5BackendStatus() {
  const rows = [
    { label: 'Action API', value: 'available', ok: true },
    { label: 'Domain logic', value: 'enabled (in-memory)', ok: true },
    { label: 'Read-only contract', value: 'still available (D4)', ok: true },
    { label: 'State persistence', value: 'in-memory only (reset on restart)', ok: null },
    { label: 'Factory Flow Board', value: 'not implemented (D6+)', ok: false },
    { label: 'Database', value: 'none — mock JSON seeds', ok: null },
  ]

  return (
    <div className="space-y-2 text-sm">
      {rows.map(({ label, value, ok }) => (
        <div key={label} className="flex justify-between">
          <span className="text-gray-400">{label}</span>
          <span
            className={`font-mono ${
              ok === true
                ? 'text-green-400'
                : ok === false
                ? 'text-amber-400'
                : 'text-gray-400'
            }`}
          >
            {value}
          </span>
        </div>
      ))}
    </div>
  )
}
