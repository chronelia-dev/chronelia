import { createClient } from '@supabase/supabase-js'

// Configuración de Supabase
// NOTA: En producción, las variables de entorno no se incluyen en la APK
// Por lo tanto, usamos valores hardcodeados como fallback
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://uzqtqflrhhjkcpkyfjoa.supabase.co'
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6cXRxZmxyaGhqa2Nwa3lmam9hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4Nzk0OTYsImV4cCI6MjA3NjQ1NTQ5Nn0.tt_wAEnUqOxgaOrNYVgNo77ju64xdbMKyHdgPGG9Bvs'

// DEBUG: Mostrar lo que se está cargando
console.log('🔍 [DEBUG] Variables de entorno:')
console.log('  URL:', supabaseUrl || '❌ NO DEFINIDA')
console.log('  Key:', supabaseAnonKey ? '✅ Definida (' + supabaseAnonKey.substring(0, 20) + '...)' : '❌ NO DEFINIDA')

// Verificar si estamos en modo demo o modo real
// Ahora siempre estará en modo producción porque tenemos valores hardcodeados
export const isDemoMode = false

// Crear cliente de Supabase
export const supabase = isDemoMode 
  ? createClient('https://demo.supabase.co', 'demo-key')
  : createClient(supabaseUrl, supabaseAnonKey)

// Log del modo actual
if (isDemoMode) {
  console.log('🎭 Chronelia ejecutándose en MODO DEMO (datos locales)')
  console.log('   Razón: Variables de entorno no configuradas correctamente')
} else {
  console.log('☁️ Chronelia conectado a Supabase (datos en la nube)')
  console.log('   URL: ' + supabaseUrl)
}

// ============================================
// MOCK AUTH (Modo Demo)
// ============================================

export const mockAuth = {
  signIn: async (username, password) => {
    // En modo demo ya no permitimos login - forzar Supabase
    console.log('🚫 Modo demo deshabilitado - usa Supabase')
    return { data: null, error: { message: 'Conecta con Supabase para usar la app' } }
  },
  
  signOut: async () => {
    localStorage.removeItem('chronelia_user')
    return { error: null }
  },
  
  getUser: async () => {
    const user = localStorage.getItem('chronelia_user')
    if (user) {
      return { data: { user: JSON.parse(user) }, error: null }
    }
    return { data: { user: null }, error: null }
  }
}

// ============================================
// AUTH (Real o Mock según configuración)
// ============================================

export const auth = {
  signIn: async (username, password) => {
    if (isDemoMode) {
      return mockAuth.signIn(username, password)
    }
    
    // Autenticación real con Supabase
    try {
      console.log('🔐 Intentando login con:', username)
      
      // OPCIÓN 1: Intentar con función login_user() (arquitectura nueva con schemas)
      try {
        const { data: loginResult, error: loginError } = await supabase
          .rpc('login_user', {
            input_username: username,
            input_password: password
          })

        if (!loginError && loginResult && loginResult.success) {
          console.log('✅ Login con función login_user() exitoso')
          
          // Login exitoso - Guardar información del usuario con schema_name
          const user = {
            id: loginResult.user_id,
            email: loginResult.email,
            username: loginResult.username,
            full_name: loginResult.full_name,
            role: loginResult.role,
            schema_name: loginResult.schema_name,
            business_id: loginResult.business_id,
            business_name: loginResult.business_name,
            user_metadata: {
              full_name: loginResult.full_name,
              role: loginResult.role
            }
          }

          localStorage.setItem('chronelia_user', JSON.stringify(user))
          console.log('✅ Login exitoso:', username, '| Negocio:', user.business_name, '| Schema:', user.schema_name)
          
          return { data: { user }, error: null }
        }
      } catch (rpcError) {
        console.log('⚠️ Función login_user() no disponible, usando método alternativo...')
      }

      // OPCIÓN 2: Método de respaldo (arquitectura antigua - sin schemas)
      console.log('🔄 Usando método de login alternativo (sin schemas)')
      
      const { data: userData, error: userError } = await supabase
        .from('users')
        .select(`
          *,
          business:businesses (
            id,
            business_name,
            schema_name,
            plan_type,
            active,
            max_workers
          )
        `)
        .eq('username', username)
        .single()

      if (userError) {
        console.log('❌ Usuario no encontrado:', userError)
        return { data: null, error: { message: 'Usuario o contraseña incorrectos' } }
      }

      if (!userData.active) {
        return { data: null, error: { message: 'Usuario inactivo' } }
      }

      // Verificar que el negocio esté activo
      if (!userData.business || !userData.business.active) {
        return { data: null, error: { message: 'Negocio inactivo o no asignado' } }
      }

      // VALIDAR CONTRASEÑA
      if (userData.password_hash !== password) {
        console.log('❌ Contraseña incorrecta para:', username)
        return { data: null, error: { message: 'Usuario o contraseña incorrectos' } }
      }

      // Login exitoso - Incluir tanto business_id como schema_name (compatibilidad)
      const user = {
        id: userData.id,
        email: userData.email,
        username: userData.username,
        full_name: userData.full_name,
        role: userData.role,
        business_id: userData.business_id,
        schema_name: userData.business.schema_name || null,
        business_name: userData.business.business_name,
        business_plan: userData.business.plan_type,
        user_metadata: {
          full_name: userData.full_name,
          role: userData.role
        }
      }

      localStorage.setItem('chronelia_user', JSON.stringify(user))
      console.log('✅ Login exitoso (modo compatibilidad):', username, '| Negocio:', user.business_name)
      return { data: { user }, error: null }
      
    } catch (error) {
      console.error('❌ Error inesperado en login:', error)
      return { data: null, error: { message: error.message || 'Error al iniciar sesión' } }
    }
  },

  signOut: async () => {
    localStorage.removeItem('chronelia_user')
    return { error: null }
  },

  getUser: async () => {
    const user = localStorage.getItem('chronelia_user')
    if (user) {
      return { data: { user: JSON.parse(user) }, error: null }
    }
    return { data: { user: null }, error: null }
  }
}

// ============================================
// FUNCIONES DE BASE DE DATOS
// ============================================

/**
 * Guardar o actualizar reserva
 */
export const saveReservation = async (reservation) => {
  if (isDemoMode) {
    console.log('Demo mode: Reserva no guardada en la nube', reservation)
    return { data: reservation, error: null }
  }

  try {
    // Primero, buscar o crear el cliente
    let customerId = reservation.customer_id

    if (!customerId) {
      const { data: existingCustomer } = await supabase
        .from('customers')
        .select('id')
        .eq('email', reservation.customer_email)
        .single()

      if (existingCustomer) {
        customerId = existingCustomer.id
      } else {
        const { data: newCustomer, error: customerError } = await supabase
          .from('customers')
          .insert({
            name: reservation.customer_name,
            email: reservation.customer_email
          })
          .select()
          .single()

        if (customerError) throw customerError
        customerId = newCustomer.id
      }
    }

    // Guardar reserva
    const reservationData = {
      id: reservation.id,
      customer_id: customerId,
      worker_id: reservation.worker_id,
      customer_name: reservation.customer_name,
      customer_email: reservation.customer_email,
      qr_code: reservation.qr_code,
      total_duration: reservation.total_duration,
      actual_duration: reservation.actual_duration,
      start_time: reservation.start_time,
      end_time: reservation.end_time,
      status: reservation.status,
      extensions: reservation.extensions || 0
    }

    const { data, error } = await supabase
      .from('reservations')
      .upsert(reservationData)
      .select()
      .single()

    if (error) throw error
    return { data, error: null }
  } catch (error) {
    console.error('Error al guardar reserva:', error)
    return { data: null, error }
  }
}

/**
 * Obtener todas las reservas activas
 */
export const getActiveReservations = async () => {
  if (isDemoMode) {
    return { data: [], error: null }
  }

  try {
    const { data, error } = await supabase
      .from('reservations')
      .select('*')
      .eq('status', 'active')
      .order('start_time', { ascending: false })

    if (error) throw error
    return { data, error: null }
  } catch (error) {
    console.error('Error al obtener reservas activas:', error)
    return { data: [], error }
  }
}

/**
 * Obtener historial de reservas
 */
export const getReservationHistory = async (limit = 50) => {
  if (isDemoMode) {
    return { data: [], error: null }
  }

  try {
    const { data, error } = await supabase
      .from('reservations')
      .select('*')
      .in('status', ['completed', 'cancelled'])
      .order('end_time', { ascending: false })
      .limit(limit)

    if (error) throw error
    return { data, error: null }
  } catch (error) {
    console.error('Error al obtener historial:', error)
    return { data: [], error }
  }
}

/**
 * Obtener trabajadores
 */
export const getWorkers = async () => {
  if (isDemoMode) {
    return { data: [], error: null }
  }

  try {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('role', 'worker')
      .order('full_name', { ascending: true })

    if (error) throw error
    return { data, error: null }
  } catch (error) {
    console.error('Error al obtener trabajadores:', error)
    return { data: [], error }
  }
}

/**
 * Guardar trabajador
 */
export const saveWorker = async (worker) => {
  if (isDemoMode) {
    console.log('📴 Modo demo: Trabajador no guardado en la nube', worker)
    return { data: worker, error: null }
  }

  try {
    const workerData = {
      id: worker.id,
      username: worker.username,
      email: worker.email,
      full_name: worker.name,
      role: 'worker',
      active: worker.active !== undefined ? worker.active : true,
      // Guardar la contraseña directamente (en producción usar hash)
      password_hash: worker.password || 'changeme123'
    }

    console.log('💾 Guardando trabajador en Supabase:', workerData)

    const { data, error } = await supabase
      .from('users')
      .upsert(workerData)
      .select()
      .single()

    if (error) {
      console.error('❌ Error al guardar en Supabase:', error)
      throw error
    }
    
    console.log('✅ Trabajador guardado exitosamente:', data)
    return { data, error: null }
  } catch (error) {
    console.error('💥 Error inesperado al guardar trabajador:', error)
    return { data: null, error }
  }
}

/**
 * Eliminar trabajador
 */
export const deleteWorker = async (workerId) => {
  if (isDemoMode) {
    console.log('Demo mode: Trabajador no eliminado de la nube', workerId)
    return { error: null }
  }

  try {
    const { error } = await supabase
      .from('users')
      .delete()
      .eq('id', workerId)

    if (error) throw error
    return { error: null }
  } catch (error) {
    console.error('Error al eliminar trabajador:', error)
    return { error }
  }
}

/**
 * Actualizar estadísticas diarias
 */
export const updateDailyStats = async (date, stats) => {
  if (isDemoMode) {
    return { data: stats, error: null }
  }

  try {
    const { data, error } = await supabase
      .from('daily_stats')
      .upsert({
        date,
        ...stats
      })
      .select()
      .single()

    if (error) throw error
    return { data, error: null }
  } catch (error) {
    console.error('Error al actualizar estadísticas:', error)
    return { data: null, error }
  }
}

/**
 * Obtener estadísticas de un rango de fechas
 */
export const getStatsDateRange = async (startDate, endDate) => {
  if (isDemoMode) {
    return { data: [], error: null }
  }

  try {
    const { data, error } = await supabase
      .from('daily_stats')
      .select('*')
      .gte('date', startDate)
      .lte('date', endDate)
      .order('date', { ascending: false })

    if (error) throw error
    return { data, error: null }
  } catch (error) {
    console.error('Error al obtener estadísticas:', error)
    return { data: [], error }
  }
}

/**
 * Suscribirse a cambios en reservas (tiempo real)
 */
export const subscribeToReservations = (callback) => {
  if (isDemoMode) {
    console.log('Demo mode: Suscripción en tiempo real no disponible')
    return { unsubscribe: () => {} }
  }

  const subscription = supabase
    .channel('reservations_channel')
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'reservations'
      },
      (payload) => {
        console.log('Cambio detectado en reservas:', payload)
        callback(payload)
      }
    )
    .subscribe()

  return subscription
}
