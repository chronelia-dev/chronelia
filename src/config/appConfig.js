/**
 * Configuración de la Aplicación chronelia.
 * 
 * ARQUITECTURA:
 * - APK (Android): Para trabajadores - Gestión de reservas en campo
 * - WEB (Admin): Para administradores - Panel de control completo
 */

// Detectar si estamos en entorno web o móvil
export const isWebPlatform = !window.Capacitor

// Configuración de la plataforma
export const APP_CONFIG = {
  // Modo de operación
  platform: isWebPlatform ? 'web' : 'mobile',
  
  // Funcionalidades habilitadas según plataforma
  features: {
    // Funcionalidades WEB (Solo Admin)
    adminPanel: isWebPlatform,
    advancedStatistics: isWebPlatform,
    workerManagement: isWebPlatform,
    aiRecommendations: isWebPlatform,
    aiChat: isWebPlatform,
    
    // Funcionalidades MÓVILES (Trabajadores)
    qrScanner: true, // Ambos pueden escanear QR
    notifications: true,
    basicDashboard: true,
    
    // Funcionalidades compartidas
    reservationManagement: true,
    history: true,
    settings: true,
  },
  
  // Roles permitidos según plataforma
  allowedRoles: isWebPlatform 
    ? ['admin'] // Web solo para admins
    : ['worker'], // APK solo para trabajadores
  
  // Configuración de la UI
  ui: {
    showBottomNav: !isWebPlatform, // Solo en móvil
    showSidebar: true,
    showAdminFeatures: isWebPlatform,
  }
}

// Verificar si el usuario tiene acceso a la plataforma
export const canAccessPlatform = (userRole) => {
  if (isWebPlatform) {
    // Web solo para admins
    return userRole === 'admin'
  } else {
    // APK solo para trabajadores
    return userRole === 'worker'
  }
}

// Obtener mensaje de acceso denegado
export const getAccessDeniedMessage = (userRole) => {
  if (isWebPlatform && userRole === 'worker') {
    return 'Los trabajadores deben usar la aplicación móvil (APK). Por favor, descarga la app desde tu dispositivo Android.'
  }
  if (!isWebPlatform && userRole === 'admin') {
    return 'Los administradores deben usar la plataforma web. Por favor, accede desde chronelia.online'
  }
  return 'No tienes permisos para acceder a esta plataforma.'
}

// Configuración de Supabase (ya existente en tu proyecto)
export const SUPABASE_CONFIG = {
  url: import.meta.env.VITE_SUPABASE_URL || 'https://uzqtqflrhhjkcpkyfjoa.supabase.co',
  anonKey: import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6cXRxZmxyaGhqa2Nwa3lmam9hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4Nzk0OTYsImV4cCI6MjA3NjQ1NTQ5Nn0.tt_wAEnUqOxgaOrNYVgNo77ju64xdbMKyHdgPGG9Bvs'
}

console.log(`🚀 chronelia. iniciado en modo: ${APP_CONFIG.platform.toUpperCase()}`)
console.log(`📱 Plataforma: ${isWebPlatform ? 'WEB (Admin Dashboard)' : 'MOBILE (Worker App)'}`)



