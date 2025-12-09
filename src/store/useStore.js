import { create } from 'zustand'
import { 
  syncReservation, 
  syncWorker, 
  removeWorkerFromCloud, 
  syncDailyStats,
  loadActiveReservations,
  loadWorkers,
  loadReservationHistory
} from '@/lib/syncHelpers'

// Generar UUID v4 válido
function generateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0
    const v = c === 'x' ? r : (r & 0x3 | 0x8)
    return v.toString(16)
  })
}

const useStore = create((set, get) => ({
  // Auth state
  user: null,
  setUser: (user) => set({ user }),
  
  // Workers management (se cargan desde Supabase)
  workers: [],
  
  addWorker: async (worker) => {
    const newWorker = {
      ...worker,
      id: generateUUID(),
      role: 'worker',
      active: true,
      createdAt: new Date(),
    }
    
    // Actualizar estado local
    set((state) => ({
      workers: [...state.workers, newWorker]
    }))
    
    // Sincronizar con Supabase
    await syncWorker(newWorker)
  },
  
  removeWorker: async (id) => {
    // Actualizar estado local
    set((state) => ({
      workers: state.workers.filter((w) => w.id !== id)
    }))
    
    // Eliminar de Supabase
    await removeWorkerFromCloud(id)
  },
  
  toggleWorkerStatus: async (id) => {
    const worker = get().workers.find((w) => w.id === id)
    if (worker) {
      const updatedWorker = { ...worker, active: !worker.active }
      
      // Actualizar estado local
      set((state) => ({
        workers: state.workers.map((w) =>
          w.id === id ? updatedWorker : w
        )
      }))
      
      // Sincronizar con Supabase
      await syncWorker(updatedWorker)
    }
  },
  
  // Sidebar state
  sidebarOpen: typeof window !== 'undefined' && window.innerWidth >= 768 ? true : false,
  toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
  
  // Reservas activas (se cargan desde Supabase)
  activeReservations: [],
  
  // Historial de reservas
  reservationHistory: [],
  
  // Estadísticas del día
  todayStats: {
    completedReservations: 0,
    averageDuration: 0,
    totalTime: 0,
  },
  
  // Agregar reserva desde QR
  addReservation: async (reservationData) => {
    const newReservation = {
      ...reservationData,
      id: generateUUID(),
      startTime: new Date(),
      remainingTime: reservationData.totalDuration,
      status: 'active',
      notified: false,
    }
    
    console.log('➕ Agregando nueva reserva:', newReservation.id)
    
    // Sincronizar PRIMERO con Supabase
    const syncResult = await syncReservation(newReservation)
    
    if (syncResult.success) {
      console.log('✅ Reserva guardada en BD:', newReservation.id)
      // Solo actualizar estado local si se guardó exitosamente
      set((state) => ({
        activeReservations: [...state.activeReservations, newReservation]
      }))
    } else {
      console.error('❌ Error guardando reserva:', syncResult.error)
      // Mostrar error al usuario
      throw new Error('No se pudo guardar la reserva en la base de datos')
    }
  },
  
  // Actualizar tiempo restante
  updateReservationTime: (id, remainingTime) => {
    set((state) => ({
      activeReservations: state.activeReservations.map((res) =>
        res.id === id ? { ...res, remainingTime } : res
      )
    }))
  },
  
  // Marcar como notificada (5 minutos)
  markAsNotified: (id) => {
    set((state) => ({
      activeReservations: state.activeReservations.map((res) =>
        res.id === id ? { ...res, notified: true } : res
      )
    }))
  },
  
  // Extender reserva
  extendReservation: async (id, additionalMinutes) => {
    const reservation = get().activeReservations.find((res) => res.id === id)
    if (reservation) {
      const additionalSeconds = additionalMinutes * 60
      const updatedReservation = {
        ...reservation,
        totalDuration: reservation.totalDuration + additionalSeconds,
        remainingTime: reservation.remainingTime + additionalSeconds,
        notified: false,
        extensions: (reservation.extensions || 0) + 1
      }
      
      // Actualizar estado local
      set((state) => ({
        activeReservations: state.activeReservations.map((res) =>
          res.id === id ? updatedReservation : res
        )
      }))
      
      // Sincronizar con Supabase
      await syncReservation(updatedReservation)
    }
  },
  
  // Finalizar reserva
  finishReservation: async (id) => {
    const reservation = get().activeReservations.find((res) => res.id === id)
    if (reservation) {
      const finishedReservation = {
        ...reservation,
        status: 'completed',
        endTime: new Date(),
        actualDuration: Math.floor((new Date() - reservation.startTime) / 1000),
      }
      
      // Actualizar estado local
      set((state) => ({
        activeReservations: state.activeReservations.filter((res) => res.id !== id),
        reservationHistory: [finishedReservation, ...state.reservationHistory],
      }))
      
      // Sincronizar con Supabase
      await syncReservation(finishedReservation)
      
      // Actualizar estadísticas
      get().updateTodayStats()
    }
  },
  
  // Actualizar estadísticas del día
  updateTodayStats: () => {
    const history = get().reservationHistory
    const today = new Date().toDateString()
    const todayReservations = history.filter(
      (res) => new Date(res.endTime).toDateString() === today
    )
    
    if (todayReservations.length > 0) {
      const totalTime = todayReservations.reduce((acc, res) => acc + res.actualDuration, 0)
      const averageDuration = Math.floor(totalTime / todayReservations.length)
      
      set({
        todayStats: {
          completedReservations: todayReservations.length,
          averageDuration,
          totalTime,
        }
      })
    }
  },

  // ============================================
  // CARGAR DATOS REALES DESDE SUPABASE
  // ============================================
  
  /**
   * Cargar todos los datos del negocio desde Supabase
   * Se llama después del login exitoso
   */
  loadBusinessData: async () => {
    try {
      console.log('🔄 Cargando datos del negocio desde Supabase...')
      
      // Cargar trabajadores
      const workers = await loadWorkers()
      console.log(`✅ Trabajadores cargados: ${workers.length}`)
      
      // Cargar reservas activas
      const activeReservations = await loadActiveReservations()
      console.log(`✅ Reservas activas cargadas: ${activeReservations.length}`)
      
      // Cargar historial (últimas 100 reservas)
      const history = await loadReservationHistory(100)
      console.log(`✅ Historial cargado: ${history.length} reservas`)
      
      // Actualizar el store
      set({
        workers,
        activeReservations,
        reservationHistory: history
      })
      
      // Actualizar estadísticas
      get().updateTodayStats()
      
      console.log('✅ Datos del negocio cargados exitosamente')
      return { success: true }
      
    } catch (error) {
      console.error('❌ Error cargando datos del negocio:', error)
      return { success: false, error }
    }
  },

  /**
   * Recargar trabajadores desde Supabase
   */
  reloadWorkers: async () => {
    try {
      const workers = await loadWorkers()
      set({ workers })
      console.log(`✅ Trabajadores recargados: ${workers.length}`)
      return { success: true, workers }
    } catch (error) {
      console.error('❌ Error recargando trabajadores:', error)
      return { success: false, error }
    }
  },

  /**
   * Recargar reservas activas desde Supabase
   */
  reloadActiveReservations: async () => {
    try {
      const activeReservations = await loadActiveReservations()
      set({ activeReservations })
      console.log(`✅ Reservas activas recargadas: ${activeReservations.length}`)
      return { success: true, activeReservations }
    } catch (error) {
      console.error('❌ Error recargando reservas activas:', error)
      return { success: false, error }
    }
  },

  /**
   * Limpiar datos al cerrar sesión
   */
  clearBusinessData: () => {
    set({
      workers: [],
      activeReservations: [],
      reservationHistory: [],
      todayStats: {
        completedReservations: 0,
        averageDuration: 0,
        totalTime: 0,
      }
    })
    console.log('🗑️ Datos del negocio limpiados')
  },

  // ============================================
  // SINCRONIZACIÓN EN TIEMPO REAL (POLLING)
  // ============================================
  
  /**
   * Activar sincronización automática cada 10 segundos
   */
  startAutoSync: () => {
    // Detener cualquier sync anterior
    const state = get()
    if (state.syncInterval) {
      clearInterval(state.syncInterval)
    }

    // Sincronizar cada 10 segundos
    const interval = setInterval(async () => {
      console.log('🔄 Auto-sync: Actualizando datos...')
      
      try {
        // Recargar reservas activas desde la BD
        const activeReservationsFromDB = await loadActiveReservations()
        
        // Fusionar con reservas locales (mantener las recién creadas)
        const currentReservations = get().activeReservations
        const currentIds = new Set(currentReservations.map(r => r.id))
        const dbIds = new Set(activeReservationsFromDB.map(r => r.id))
        
        // Reservas que existen en ambos lados -> usar la de BD
        const updatedReservations = activeReservationsFromDB.filter(r => currentIds.has(r.id))
        
        // Reservas nuevas desde BD que no están en local
        const newFromDB = activeReservationsFromDB.filter(r => !currentIds.has(r.id))
        
        // Reservas locales muy recientes (< 15 segundos) que aún no están en BD
        const recentLocal = currentReservations.filter(r => {
          if (dbIds.has(r.id)) return false // Ya está en BD
          const age = Date.now() - new Date(r.startTime).getTime()
          return age < 15000 // Menos de 15 segundos
        })
        
        // Combinar: BD + nuevas de BD + recientes locales
        const mergedReservations = [...updatedReservations, ...newFromDB, ...recentLocal]
        
        // Solo actualizar si hay cambios reales
        if (JSON.stringify(mergedReservations) !== JSON.stringify(currentReservations)) {
          set({ activeReservations: mergedReservations })
          console.log('✅ Reservas sincronizadas:', {
            total: mergedReservations.length,
            fromDB: activeReservationsFromDB.length,
            recentLocal: recentLocal.length
          })
        }
        
        // Cada 30 segundos, recargar también trabajadores
        if (Date.now() % 30000 < 10000) {
          const workers = await loadWorkers()
          set({ workers })
          console.log('✅ Trabajadores actualizados:', workers.length)
        }
      } catch (error) {
        console.error('❌ Error en auto-sync:', error)
      }
    }, 10000) // 10 segundos

    set({ syncInterval: interval })
    console.log('🔄 Auto-sync activado (cada 10 segundos)')
  },

  /**
   * Detener sincronización automática
   */
  stopAutoSync: () => {
    const state = get()
    if (state.syncInterval) {
      clearInterval(state.syncInterval)
      set({ syncInterval: null })
      console.log('⏸️ Auto-sync detenido')
    }
  },

  // Intervalo de sincronización (interno)
  syncInterval: null,
}))

export default useStore

