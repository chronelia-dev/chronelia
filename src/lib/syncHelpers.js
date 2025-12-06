import {
  isDemoMode
} from './supabase'
import {
  saveReservationMultiTenant,
  getActiveReservationsMultiTenant,
  getReservationHistoryMultiTenant,
  getWorkersMultiTenant,
  saveWorkerMultiTenant,
  deleteWorkerMultiTenant,
  saveDailyStatsMultiTenant
} from './multiTenant'

/**
 * Sincronizar reserva activa con Supabase (Multi-Tenant)
 */
export async function syncReservation(reservation) {
  if (isDemoMode) {
    console.log('📴 Modo demo: Reserva solo en local')
    return { success: true, data: reservation }
  }

  try {
    const { data, error } = await saveReservationMultiTenant({
      id: reservation.id,
      customer_name: reservation.clientName,
      customer_email: reservation.clientEmail,
      qr_code: reservation.qrCode,
      total_duration: reservation.totalDuration,
      actual_duration: reservation.actualDuration,
      start_time: reservation.startTime,
      end_time: reservation.endTime,
      status: reservation.status,
      worker_name: reservation.worker,
      group_size: reservation.groupSize,
      extensions: reservation.extensions || 0
    })

    if (error) {
      console.error('❌ Error sincronizando reserva:', error)
      return { success: false, error }
    }

    console.log('✅ Reserva sincronizada:', data)
    return { success: true, data }
  } catch (error) {
    console.error('💥 Error inesperado:', error)
    return { success: false, error }
  }
}

/**
 * Cargar reservas activas desde Supabase (Multi-Tenant)
 */
export async function loadActiveReservations() {
  if (isDemoMode) {
    console.log('📴 Modo demo: Sin carga desde la nube')
    return []
  }

  try {
    const { data, error } = await getActiveReservationsMultiTenant()
    
    if (error) {
      console.error('❌ Error cargando reservas activas:', error)
      return []
    }

    // Transformar formato de BD a formato de la app
    const reservations = data.map(r => ({
      id: r.id,
      clientName: r.customer_name,
      clientEmail: r.customer_email,
      qrCode: r.qr_code,
      totalDuration: r.total_duration,
      actualDuration: r.actual_duration,
      remainingTime: calculateRemainingTime(r.start_time, r.total_duration),
      startTime: new Date(r.start_time),
      endTime: r.end_time ? new Date(r.end_time) : null,
      status: r.status,
      worker: r.worker_name,
      groupSize: r.group_size,
      extensions: r.extensions || 0,
      notified: false // Se calcula en cliente
    }))

    console.log(`✅ Cargadas ${reservations.length} reservas activas`)
    return reservations
  } catch (error) {
    console.error('💥 Error inesperado:', error)
    return []
  }
}

/**
 * Cargar historial de reservas desde Supabase (Multi-Tenant)
 */
export async function loadReservationHistory(limit = 50) {
  if (isDemoMode) {
    console.log('📴 Modo demo: Sin carga desde la nube')
    return []
  }

  try {
    const { data, error } = await getReservationHistoryMultiTenant(limit)
    
    if (error) {
      console.error('❌ Error cargando historial:', error)
      return []
    }

    // Transformar formato de BD a formato de la app
    const history = data.map(r => ({
      id: r.id,
      clientName: r.customer_name,
      clientEmail: r.customer_email,
      qrCode: r.qr_code,
      totalDuration: r.total_duration,
      actualDuration: r.actual_duration,
      startTime: new Date(r.start_time),
      endTime: r.end_time ? new Date(r.end_time) : null,
      status: r.status,
      worker: r.worker_name,
      groupSize: r.group_size
    }))

    console.log(`✅ Cargadas ${history.length} reservas del historial`)
    return history
  } catch (error) {
    console.error('💥 Error inesperado:', error)
    return []
  }
}

/**
 * Cargar trabajadores desde Supabase (Multi-Tenant)
 */
export async function loadWorkers() {
  if (isDemoMode) {
    console.log('📴 Modo demo: Sin carga desde la nube')
    return []
  }

  try {
    const { data, error } = await getWorkersMultiTenant()
    
    if (error) {
      console.error('❌ Error cargando trabajadores:', error)
      return []
    }

    // Transformar formato de BD a formato de la app
    const workers = data.map(w => ({
      id: w.id,
      name: w.full_name,
      username: w.username,
      email: w.email,
      role: w.role,
      active: w.active,
      createdAt: new Date(w.created_at)
    }))

    console.log(`✅ Cargados ${workers.length} trabajadores`)
    return workers
  } catch (error) {
    console.error('💥 Error inesperado:', error)
    return []
  }
}

/**
 * Sincronizar trabajador con Supabase (Multi-Tenant)
 */
export async function syncWorker(worker) {
  if (isDemoMode) {
    console.log('📴 Modo demo: Trabajador solo en local')
    return { success: true, data: worker }
  }

  try {
    const { data, error } = await saveWorkerMultiTenant(worker)

    if (error) {
      console.error('❌ Error sincronizando trabajador:', error)
      return { success: false, error }
    }

    console.log('✅ Trabajador sincronizado:', data)
    return { success: true, data }
  } catch (error) {
    console.error('💥 Error inesperado:', error)
    return { success: false, error }
  }
}

/**
 * Eliminar trabajador de Supabase (Multi-Tenant)
 */
export async function removeWorkerFromCloud(workerId) {
  if (isDemoMode) {
    console.log('📴 Modo demo: Trabajador solo eliminado localmente')
    return { success: true }
  }

  try {
    const { error } = await deleteWorkerMultiTenant(workerId)

    if (error) {
      console.error('❌ Error eliminando trabajador:', error)
      return { success: false, error }
    }

    console.log('✅ Trabajador eliminado de la nube')
    return { success: true }
  } catch (error) {
    console.error('💥 Error inesperado:', error)
    return { success: false, error }
  }
}

/**
 * Sincronizar estadísticas diarias (Multi-Tenant)
 */
export async function syncDailyStats(stats) {
  if (isDemoMode) {
    console.log('📴 Modo demo: Estadísticas solo en local')
    return { success: true }
  }

  try {
    const today = new Date().toISOString().split('T')[0]
    const { data, error } = await saveDailyStatsMultiTenant({
      date: today,
      total_reservations: stats.totalReservations || 0,
      completed_reservations: stats.completedReservations || 0,
      cancelled_reservations: stats.cancelledReservations || 0,
      total_time: stats.totalTime || 0,
      average_duration: stats.averageDuration || 0,
      total_revenue: stats.totalRevenue || 0
    })

    if (error) {
      console.error('❌ Error sincronizando estadísticas:', error)
      return { success: false, error }
    }

    console.log('✅ Estadísticas sincronizadas')
    return { success: true, data }
  } catch (error) {
    console.error('💥 Error inesperado:', error)
    return { success: false, error }
  }
}

/**
 * Inicializar sincronización en tiempo real
 * NOTA: Por ahora deshabilitado para multi-tenant con schemas
 */
export function setupRealtimeSync(onReservationChange) {
  if (isDemoMode) {
    console.log('📴 Modo demo: Sincronización en tiempo real no disponible')
    return null
  }

  console.log('⚠️ Sincronización en tiempo real temporalmente deshabilitada para arquitectura multi-tenant')
  // TODO: Implementar realtime con filtros por schema
  return null
}

/**
 * Calcular tiempo restante de una reserva
 */
function calculateRemainingTime(startTime, totalDuration) {
  const start = new Date(startTime)
  const now = new Date()
  const elapsed = Math.floor((now - start) / 1000) // segundos transcurridos
  const remaining = totalDuration - elapsed

  return Math.max(0, remaining) // No puede ser negativo
}

/**
 * Verificar estado de conexión
 */
export function checkConnectionStatus() {
  if (isDemoMode) {
    return {
      connected: false,
      mode: 'demo',
      message: '📴 Modo local - Los datos no se sincronizan con la nube'
    }
  }

  return {
    connected: true,
    mode: 'cloud',
    message: '☁️ Conectado a Supabase - Datos sincronizados en tiempo real'
  }
}

/**
 * Forzar sincronización completa (útil al iniciar la app)
 */
export async function fullSync(store) {
  if (isDemoMode) {
    console.log('📴 Modo demo: Sincronización completa omitida')
    return { success: true, message: 'Modo demo activado' }
  }

  try {
    console.log('🔄 Iniciando sincronización completa...')

    // 1. Cargar trabajadores
    const workers = await loadWorkers()
    if (workers.length > 0) {
      // Actualizar store (se hace desde el componente)
      console.log(`✅ ${workers.length} trabajadores cargados`)
    }

    // 2. Cargar reservas activas
    const activeReservations = await loadActiveReservations()
    if (activeReservations.length > 0) {
      console.log(`✅ ${activeReservations.length} reservas activas cargadas`)
    }

    // 3. Cargar historial reciente
    const history = await loadReservationHistory(50)
    if (history.length > 0) {
      console.log(`✅ ${history.length} reservas del historial cargadas`)
    }

    console.log('✅ Sincronización completa finalizada')
    
    return {
      success: true,
      data: {
        workers,
        activeReservations,
        history
      }
    }
  } catch (error) {
    console.error('💥 Error en sincronización completa:', error)
    return {
      success: false,
      error,
      message: 'Error al sincronizar con la nube'
    }
  }
}


