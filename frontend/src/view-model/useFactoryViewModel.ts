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
import type { FactoryViewModel } from './types'

export function useFactoryViewModel(): FactoryViewModel {
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

  const reload = useCallback(async () => {
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
    void reload()
  }, [reload])

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

  const resetDemoState = useCallback(async () => {
    setResetting(true)
    try {
      await postResetState()
      setSelectedUnitId(null)
      setSelectedUnit(null)
      await reload()
    } catch {
      /* ignore */
    } finally {
      setResetting(false)
    }
  }, [reload])

  return {
    health,
    contractStatus,
    stages,
    units,
    events,
    users,
    parts,
    refStandards,
    selectedUnitId,
    selectedUnit,
    loadError,
    resetting,
    selectUnit,
    refreshSelected,
    reload,
    resetDemoState,
  }
}
