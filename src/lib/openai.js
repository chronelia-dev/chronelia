// ============================================
// chronelia. - INTEGRACIÓN CON OPENAI
// ============================================

import { VERCEL_URL } from '@/config/vercel'

const OPENAI_API_KEY = import.meta.env.VITE_OPENAI_API_KEY || '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'
const OPENAI_MODEL = import.meta.env.VITE_OPENAI_MODEL || 'gpt-4o-mini'
const OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions'

// Verificar si OpenAI está configurado
export const isOpenAIConfigured = () => {
  return Boolean(OPENAI_API_KEY && OPENAI_API_KEY !== 'sk-your-api-key-here')
}

/**
 * Genera un contexto estructurado con las estadísticas actuales
 * @param {Object} store - Store de Zustand con todos los datos
 * @returns {string} Contexto formateado para la IA
 */
export function generateContext(store) {
  // Validar que store existe y tiene las propiedades necesarias
  if (!store) {
    console.warn('⚠️ Store is undefined')
    return 'Eres un asistente IA especializado en el sistema de gestión "chronelia".'
  }

  // Usar valores por defecto si las propiedades no existen
  const { 
    activeReservations = [], 
    workers = [], 
    dailyStats = [], 
    history = [] 
  } = store

  // Calcular estadísticas en tiempo real
  const totalReservations = history.length
  const activeCount = activeReservations.length
  const activeWorkers = workers.filter(w => w.active).length
  const totalWorkers = workers.length

  // Estadísticas de hoy
  const today = new Date().toISOString().split('T')[0]
  const todayStats = dailyStats.find(s => s.date === today) || {}

  // Duración promedio
  const avgDuration = history.length > 0
    ? Math.round(history.reduce((acc, r) => acc + r.duration, 0) / history.length)
    : 0

  // Ingresos totales
  const totalRevenue = dailyStats.reduce((acc, s) => acc + (s.revenue || 0), 0)

  // Últimas reservas
  const recentReservations = history.length > 0
    ? history.slice(-5).map(r => 
        `${r.clientName} (${r.duration} min)`
      ).join(', ')
    : 'Ninguna'

  return `
Eres un asistente IA especializado en el sistema de gestión y crecimiento empresarial "chronelia". 

DATOS ACTUALES DEL NEGOCIO:

📊 RESERVAS:
- Total de reservas: ${totalReservations}
- Reservas activas ahora: ${activeCount}
- Reservas hoy: ${todayStats.totalReservations || 0}
- Últimas 5 reservas: ${recentReservations || 'Ninguna'}

👥 PERSONAL:
- Total de trabajadores: ${totalWorkers}
- Trabajadores activos: ${activeWorkers}
- Trabajadores inactivos: ${totalWorkers - activeWorkers}

⏱️ TIEMPOS:
- Duración promedio de servicio: ${avgDuration} minutos

💰 INGRESOS:
- Ingresos totales: $${totalRevenue.toLocaleString()}
- Ingresos hoy: $${(todayStats.revenue || 0).toLocaleString()}
- Clientes atendidos hoy: ${todayStats.customers || 0}

INSTRUCCIONES:
- Responde en español de forma clara y concisa
- Usa emojis apropiados para hacer las respuestas más visuales
- Proporciona datos específicos cuando sea relevante
- Si te preguntan sobre estadísticas, usa los datos proporcionados arriba
- Si detectas oportunidades de mejora, menciónalas
- Sé amigable pero profesional
- Formatea las respuestas con saltos de línea y bullets cuando sea apropiado
- NO inventes datos que no están en el contexto
`.trim()
}

/**
 * Llama a la API de OpenAI para generar una respuesta
 * @param {string} userMessage - Mensaje del usuario
 * @param {Object} store - Store con datos de la app
 * @param {Array} conversationHistory - Historial de la conversación
 * @returns {Promise<string>} Respuesta de la IA
 */
export async function generateAIResponse(userMessage, store, conversationHistory = []) {
  // Determinar si estamos en producción
  const isProduction = typeof window !== 'undefined' && 
                      window.location.hostname !== 'localhost' && 
                      !window.location.hostname.includes('127.0.0.1')
  
  // Solo verificar configuración en desarrollo
  if (!isProduction && !isOpenAIConfigured()) {
    return `⚙️ **OpenAI no está configurado**

Para usar el chat IA con respuestas avanzadas, necesitas:

1. Obtener una API key de OpenAI en https://platform.openai.com/api-keys
2. Agregar la key al archivo \`.env.local\`:
   \`\`\`
   VITE_OPENAI_API_KEY=sk-tu-api-key-aqui
   \`\`\`
3. Reiniciar la aplicación

Mientras tanto, puedo responder preguntas básicas usando el sistema local.`
  }

  try {
    console.log('🤖 Enviando petición a OpenAI...')
    
    // Preparar mensajes
    const messages = [
      {
        role: 'system',
        content: generateContext(store)
      },
      ...conversationHistory.slice(-10).map(msg => ({
        role: msg.role,
        content: msg.content
      })),
      {
        role: 'user',
        content: userMessage
      }
    ]

    // Determinar si estamos en producción o desarrollo
    const isLocalhost = window.location.hostname === 'localhost' || window.location.hostname.includes('127.0.0.1')
    const isCapacitor = window.location.protocol === 'capacitor:' || window.location.protocol === 'ionic:'
    
    // Determinar qué API usar
    let apiUrl, headers
    
    if (isLocalhost) {
      // Desarrollo local: llamada directa a OpenAI
      apiUrl = OPENAI_API_URL
      headers = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENAI_API_KEY}`
      }
      console.log('📡 Usando API: Directa (OpenAI) - Desarrollo local')
    } else if (isCapacitor) {
      // App nativa: usar URL completa de Vercel desde config
      apiUrl = `${VERCEL_URL}/api/chat`
      headers = { 'Content-Type': 'application/json' }
      console.log('📡 Usando API: Serverless Vercel (App Nativa) -', apiUrl)
    } else {
      // Web en producción: ruta relativa
      apiUrl = '/api/chat'
      headers = { 'Content-Type': 'application/json' }
      console.log('📡 Usando API: Serverless (/api/chat) - Web Producción')
    }

    // Llamar a la API (serverless en producción, directa en desarrollo)
    const response = await fetch(apiUrl, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        model: OPENAI_MODEL,
        messages: messages,
        temperature: 0.7,
        max_tokens: 500
      })
    })

    if (!response.ok) {
      const error = await response.json()
      console.error('❌ Error de OpenAI:', error)
      
      // Errores específicos
      if (response.status === 401) {
        return '🔑 Error: API key inválida. Verifica tu configuración en el archivo `.env`'
      }
      if (response.status === 429) {
        return '⏳ Has excedido el límite de peticiones. Intenta de nuevo en unos minutos.'
      }
      if (response.status === 500) {
        return '🔧 OpenAI está experimentando problemas. Intenta de nuevo en unos minutos.'
      }
      
      throw new Error(error.error?.message || 'Error desconocido')
    }

    const data = await response.json()
    console.log('📦 Datos recibidos de OpenAI:', data)
    
    // Validar estructura de la respuesta
    if (!data || !data.choices || !Array.isArray(data.choices)) {
      console.error('❌ Respuesta inválida - no tiene choices:', data)
      throw new Error('Respuesta de OpenAI con formato inválido')
    }

    if (data.choices.length === 0) {
      console.error('❌ Respuesta vacía - choices está vacío')
      throw new Error('OpenAI no devolvió ninguna respuesta')
    }

    const aiMessage = data.choices[0]?.message?.content

    if (!aiMessage || typeof aiMessage !== 'string') {
      console.error('❌ Mensaje inválido:', data.choices[0])
      throw new Error('No se recibió contenido válido de OpenAI')
    }

    console.log('✅ Respuesta recibida de OpenAI')
    return aiMessage.trim()

  } catch (error) {
    console.error('💥 Error al llamar a OpenAI:', error)
    
    return `❌ **Error al conectar con OpenAI**

${error.message}

**Posibles soluciones:**
• Verifica tu conexión a internet
• Confirma que tu API key es válida
• Revisa que tienes créditos disponibles en OpenAI
• Intenta de nuevo en unos momentos

Mientras tanto, puedo responder preguntas básicas usando el sistema local.`
  }
}

/**
 * Obtiene estadísticas de uso de la API
 * @returns {Object} Información sobre el uso
 */
export function getAPIStatus() {
  return {
    configured: isOpenAIConfigured(),
    model: OPENAI_MODEL,
    hasKey: Boolean(OPENAI_API_KEY)
  }
}

// Debug: Log del estado de configuración
console.log('🔧 Estado de OpenAI:', {
  configured: isOpenAIConfigured(),
  model: OPENAI_MODEL,
  hasKey: Boolean(OPENAI_API_KEY),
  keyPreview: OPENAI_API_KEY ? `${OPENAI_API_KEY.substring(0, 10)}...` : 'No configurada',
  keyLength: OPENAI_API_KEY ? OPENAI_API_KEY.length : 0,
  envVarRaw: import.meta.env.VITE_OPENAI_API_KEY ? 'Presente en import.meta.env ✅' : 'NO presente en import.meta.env ❌'
})

