import { supabase } from './supabase'

/**
 * Obtener el schema_name del usuario actual del localStorage
 */
export const getCurrentSchema = () => {
  const user = localStorage.getItem('chronelia_user')
  if (user) {
    const userData = JSON.parse(user)
    return userData.schema_name || null
  }
  return null
}

/**
 * Obtener el business_id del usuario actual del localStorage
 */
export const getCurrentBusinessId = () => {
  const user = localStorage.getItem('chronelia_user')
  if (user) {
    const userData = JSON.parse(user)
    return userData.business_id || null
  }
  return null
}

/**
 * Obtener el nombre del negocio actual
 */
export const getCurrentBusinessName = () => {
  const user = localStorage.getItem('chronelia_user')
  if (user) {
    const userData = JSON.parse(user)
    return userData.business_name || null
  }
  return null
}

/**
 * Configurar el search_path para apuntar al schema del negocio
 * IMPORTANTE: Esto debe llamarse después del login y antes de cualquier consulta
 */
export const setBusinessSchema = async () => {
  const schemaName = getCurrentSchema()
  if (!schemaName) {
    console.error('❌ No hay schema_name en el usuario actual')
    return { success: false, error: 'No schema found' }
  }

  try {
    // Establecer el search_path para todas las consultas siguientes
    const { error } = await supabase.rpc('exec_sql', {
      sql: `SET search_path TO ${schemaName}, public;`
    })

    if (error) {
      console.error('❌ Error al establecer search_path:', error)
      return { success: false, error }
    }

    console.log(`✅ Search path establecido a: ${schemaName}`)
    return { success: true }
  } catch (error) {
    console.error('❌ Error al configurar schema:', error)
    return { success: false, error }
  }
}

/**
 * Obtener información del negocio actual
 */
export const getCurrentBusiness = async () => {
  const schemaName = getCurrentSchema()
  if (!schemaName) {
    return { data: null, error: { message: 'No schema found' } }
  }

  try {
    const { data, error } = await supabase
      .from('businesses')
      .select('*')
      .eq('schema_name', schemaName)
      .single()

    return { data, error }
  } catch (error) {
    console.error('Error al obtener negocio:', error)
    return { data: null, error }
  }
}

/**
 * Guardar reserva en el schema del negocio actual
 */
export const saveReservationMultiTenant = async (reservation) => {
  const schemaName = getCurrentSchema()
  if (!schemaName) {
    return { data: null, error: { message: 'No schema found' } }
  }

  try {
    const reservationData = {
      id: reservation.id,
      customer_name: reservation.customer_name || reservation.clientName,
      customer_email: reservation.customer_email || reservation.clientEmail,
      qr_code: reservation.qr_code || reservation.qrCode,
      total_duration: reservation.total_duration || reservation.totalDuration,
      actual_duration: reservation.actual_duration,
      start_time: reservation.start_time || reservation.startTime,
      end_time: reservation.end_time,
      status: reservation.status,
      worker_name: reservation.worker || reservation.worker_name,
      group_size: reservation.group_size || reservation.groupSize || 1,
      extensions: reservation.extensions || 0
    }

    console.log(`💾 Guardando reserva en schema ${schemaName}:`, reservationData)

    // Usar función RPC para guardar en el schema correcto
    const { data, error } = await supabase
      .rpc('save_reservation', {
        schema_name: schemaName,
        reservation_id: reservationData.id,
        p_customer_name: reservationData.customer_name,
        p_customer_email: reservationData.customer_email,
        p_qr_code: reservationData.qr_code,
        p_total_duration: reservationData.total_duration,
        p_actual_duration: reservationData.actual_duration,
        p_start_time: reservationData.start_time,
        p_end_time: reservationData.end_time,
        p_status: reservationData.status,
        p_worker_name: reservationData.worker_name,
        p_group_size: reservationData.group_size,
        p_extensions: reservationData.extensions
      })

    if (error) throw error
    
    console.log('✅ Reserva guardada exitosamente, ID:', data)
    return { data: { id: data, ...reservationData }, error: null }
  } catch (error) {
    console.error('❌ Error al guardar reserva:', error)
    return { data: null, error }
  }
}

/**
 * Obtener reservas activas del schema del negocio actual
 */
export const getActiveReservationsMultiTenant = async () => {
  const schemaName = getCurrentSchema()
  if (!schemaName) {
    console.error('❌ No schema found para obtener reservas')
    return { data: [], error: { message: 'No schema found' } }
  }

  try {
    console.log('📥 Obteniendo reservas activas del schema:', schemaName)
    
    // Usar función RPC para acceder al schema correcto
    const { data, error } = await supabase
      .rpc('get_active_reservations', { schema_name: schemaName })

    if (error) {
      console.error('❌ Error de Supabase:', error)
      throw error
    }
    
    console.log('✅ Reservas activas obtenidas:', data?.length || 0)
    return { data: data || [], error: null }
  } catch (error) {
    console.error('❌ Error al obtener reservas activas:', error)
    return { data: [], error }
  }
}

/**
 * Obtener historial de reservas del schema del negocio actual
 */
export const getReservationHistoryMultiTenant = async (limit = 50) => {
  const schemaName = getCurrentSchema()
  if (!schemaName) {
    console.error('❌ No schema found para obtener historial')
    return { data: [], error: { message: 'No schema found' } }
  }

  try {
    console.log('📥 Obteniendo historial del schema:', schemaName)
    
    // Usar función RPC para acceder al schema correcto
    const { data, error } = await supabase
      .rpc('get_reservation_history', { 
        schema_name: schemaName,
        limit_count: limit 
      })

    if (error) {
      console.error('❌ Error de Supabase:', error)
      throw error
    }
    
    console.log('✅ Historial obtenido:', data?.length || 0)
    return { data: data || [], error: null }
  } catch (error) {
    console.error('❌ Error al obtener historial:', error)
    return { data: [], error }
  }
}

/**
 * Obtener trabajadores del schema del negocio actual
 */
export const getWorkersMultiTenant = async () => {
  const schemaName = getCurrentSchema()
  if (!schemaName) {
    console.error('❌ No schema found para obtener trabajadores')
    return { data: [], error: { message: 'No schema found' } }
  }

  try {
    console.log('📥 Obteniendo trabajadores del schema:', schemaName)
    
    // Usar función RPC para acceder al schema correcto
    const { data, error } = await supabase
      .rpc('get_workers', { schema_name: schemaName })

    if (error) {
      console.error('❌ Error de Supabase:', error)
      throw error
    }
    
    console.log('✅ Trabajadores obtenidos:', data?.length || 0)
    return { data: data || [], error: null }
  } catch (error) {
    console.error('❌ Error al obtener trabajadores:', error)
    return { data: [], error }
  }
}

/**
 * Guardar trabajador en el schema del negocio actual
 */
export const saveWorkerMultiTenant = async (worker) => {
  const schemaName = getCurrentSchema()
  if (!schemaName) {
    return { data: null, error: { message: 'No schema found' } }
  }

  try {
    const workerData = {
      id: worker.id,
      username: worker.username,
      email: worker.email,
      full_name: worker.name || worker.full_name,
      role: 'worker',
      active: worker.active !== undefined ? worker.active : true,
      password_hash: worker.password || 'changeme123'
    }

    console.log(`💾 Guardando trabajador en schema ${schemaName}:`, workerData)

    // Usar schema.table para acceder a la tabla correcta
    const { data, error} = await supabase
      .from(`${schemaName}.users`)
      .upsert(workerData)
      .select()
      .single()

    if (error) throw error
    
    console.log('✅ Trabajador guardado exitosamente:', data)
    return { data, error: null }
  } catch (error) {
    console.error('❌ Error al guardar trabajador:', error)
    return { data: null, error }
  }
}

/**
 * Eliminar trabajador del schema del negocio actual
 */
export const deleteWorkerMultiTenant = async (workerId) => {
  const schemaName = getCurrentSchema()
  if (!schemaName) {
    return { data: null, error: { message: 'No schema found' } }
  }

  try {
    // Usar schema.table para acceder a la tabla correcta
    const { data, error } = await supabase
      .from(`${schemaName}.users`)
      .delete()
      .eq('id', workerId)

    if (error) throw error
    return { data, error: null }
  } catch (error) {
    console.error('Error al eliminar trabajador:', error)
    return { data: null, error }
  }
}

/**
 * Obtener estadísticas diarias del schema del negocio actual
 */
export const getDailyStatsMultiTenant = async (date) => {
  const schemaName = getCurrentSchema()
  if (!schemaName) {
    return { data: null, error: { message: 'No schema found' } }
  }

  try {
    const { data, error } = await supabase
      .from('daily_stats')
      .select('*')
      .eq('date', date)
      .single()

    if (error && error.code !== 'PGRST116') throw error // PGRST116 = no encontrado
    return { data: data || null, error: null }
  } catch (error) {
    console.error('Error al obtener estadísticas:', error)
    return { data: null, error }
  }
}

/**
 * Guardar estadísticas diarias en el schema del negocio actual
 */
export const saveDailyStatsMultiTenant = async (stats) => {
  const schemaName = getCurrentSchema()
  if (!schemaName) {
    return { data: null, error: { message: 'No schema found' } }
  }

  try {
    // Usar schema.table para acceder a la tabla correcta
    const { data, error } = await supabase
      .from(`${schemaName}.daily_stats`)
      .upsert(stats)
      .select()
      .single()

    if (error) throw error
    return { data, error: null }
  } catch (error) {
    console.error('Error al guardar estadísticas:', error)
    return { data: null, error }
  }
}

/**
 * Obtener todos los negocios (solo para super admin desde public.businesses)
 */
export const getAllBusinesses = async () => {
  try {
    const { data, error } = await supabase
      .from('businesses')
      .select('*')
      .order('business_name', { ascending: true })

    if (error) throw error
    return { data: data || [], error: null }
  } catch (error) {
    console.error('Error al obtener negocios:', error)
    return { data: [], error }
  }
}


