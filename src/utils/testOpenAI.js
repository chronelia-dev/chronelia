// ============================================
// TEST DE CONEXIÓN A OPENAI
// ============================================
// Este script hace una prueba real de conexión a OpenAI
// Usa tokens reales pero verifica que todo funciona

/**
 * Test básico de ping a OpenAI
 * @returns {Promise<Object>} Resultado del test
 */
export async function testOpenAIConnection() {
  const OPENAI_API_KEY = import.meta.env.VITE_OPENAI_API_KEY
  const OPENAI_MODEL = import.meta.env.VITE_OPENAI_MODEL || 'gpt-4o-mini'
  const OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions'

  console.log('🧪 Iniciando test de OpenAI...')
  console.log('📝 Configuración:')
  console.log('  - Modelo:', OPENAI_MODEL)
  console.log('  - API Key:', OPENAI_API_KEY ? `${OPENAI_API_KEY.substring(0, 20)}...` : '❌ NO CONFIGURADA')

  // Verificar que existe la API key
  if (!OPENAI_API_KEY || OPENAI_API_KEY === 'sk-your-api-key-here') {
    return {
      success: false,
      error: 'NO_API_KEY',
      message: 'API key no configurada. Verifica tu archivo .env.local',
      details: 'Debe existir VITE_OPENAI_API_KEY en .env.local'
    }
  }

  try {
    console.log('📡 Enviando petición de prueba...')

    const startTime = Date.now()

    const response = await fetch(OPENAI_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENAI_API_KEY}`
      },
      body: JSON.stringify({
        model: OPENAI_MODEL,
        messages: [
          {
            role: 'system',
            content: 'Eres un asistente de prueba. Responde brevemente.'
          },
          {
            role: 'user',
            content: 'Di "Conexión exitosa" si recibes este mensaje.'
          }
        ],
        temperature: 0.5,
        max_tokens: 50
      })
    })

    const endTime = Date.now()
    const responseTime = endTime - startTime

    console.log('📊 Respuesta recibida')
    console.log('  - Status:', response.status)
    console.log('  - Status Text:', response.statusText)
    console.log('  - Tiempo de respuesta:', `${responseTime}ms`)

    // Verificar status code
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      console.error('❌ Error HTTP:', response.status)
      console.error('❌ Detalles:', errorData)

      let errorMessage = 'Error desconocido'
      let errorCode = 'HTTP_ERROR'

      if (response.status === 401) {
        errorMessage = 'API key inválida o expirada'
        errorCode = 'INVALID_API_KEY'
      } else if (response.status === 429) {
        errorMessage = 'Límite de tasa excedido. Espera unos minutos.'
        errorCode = 'RATE_LIMIT'
      } else if (response.status === 500 || response.status === 503) {
        errorMessage = 'OpenAI está experimentando problemas temporales'
        errorCode = 'OPENAI_ERROR'
      } else if (response.status === 400) {
        errorMessage = 'Petición inválida: ' + (errorData.error?.message || 'Sin detalles')
        errorCode = 'BAD_REQUEST'
      }

      return {
        success: false,
        error: errorCode,
        message: errorMessage,
        statusCode: response.status,
        details: errorData,
        responseTime
      }
    }

    // Parsear respuesta JSON
    const data = await response.json()
    console.log('📦 Datos recibidos:', data)

    // Verificar estructura de la respuesta
    if (!data.choices || !Array.isArray(data.choices) || data.choices.length === 0) {
      console.error('❌ Respuesta sin choices:', data)
      return {
        success: false,
        error: 'INVALID_RESPONSE',
        message: 'La respuesta de OpenAI no tiene el formato esperado',
        details: { receivedData: data },
        responseTime
      }
    }

    const aiMessage = data.choices[0]?.message?.content

    if (!aiMessage) {
      console.error('❌ Respuesta sin mensaje:', data.choices[0])
      return {
        success: false,
        error: 'NO_MESSAGE',
        message: 'No se recibió contenido en la respuesta',
        details: { choice: data.choices[0] },
        responseTime
      }
    }

    console.log('✅ Test exitoso!')
    console.log('💬 Respuesta:', aiMessage)

    return {
      success: true,
      message: 'Conexión exitosa con OpenAI',
      aiResponse: aiMessage,
      model: data.model,
      usage: data.usage,
      responseTime,
      details: {
        tokensUsed: data.usage?.total_tokens || 0,
        promptTokens: data.usage?.prompt_tokens || 0,
        completionTokens: data.usage?.completion_tokens || 0
      }
    }

  } catch (error) {
    console.error('💥 Error de red o parsing:', error)
    
    return {
      success: false,
      error: 'NETWORK_ERROR',
      message: 'Error de conexión: ' + error.message,
      details: {
        errorType: error.name,
        errorMessage: error.message,
        stack: error.stack
      }
    }
  }
}

/**
 * Test con historial de conversación
 */
export async function testOpenAIWithHistory() {
  const OPENAI_API_KEY = import.meta.env.VITE_OPENAI_API_KEY
  const OPENAI_MODEL = import.meta.env.VITE_OPENAI_MODEL || 'gpt-4o-mini'
  const OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions'

  console.log('🧪 Test con historial de conversación...')

  if (!OPENAI_API_KEY) {
    return { success: false, error: 'NO_API_KEY' }
  }

  try {
    const response = await fetch(OPENAI_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENAI_API_KEY}`
      },
      body: JSON.stringify({
        model: OPENAI_MODEL,
        messages: [
          { role: 'system', content: 'Eres un asistente de Chronelia.' },
          { role: 'user', content: 'Hola' },
          { role: 'assistant', content: 'Hola! ¿En qué puedo ayudarte?' },
          { role: 'user', content: '¿Cómo estás?' }
        ],
        temperature: 0.7,
        max_tokens: 100
      })
    })

    if (!response.ok) {
      const error = await response.json().catch(() => ({}))
      return {
        success: false,
        error: 'HTTP_ERROR',
        statusCode: response.status,
        details: error
      }
    }

    const data = await response.json()
    const aiMessage = data.choices?.[0]?.message?.content

    return {
      success: !!aiMessage,
      message: 'Test con historial exitoso',
      aiResponse: aiMessage,
      usage: data.usage
    }

  } catch (error) {
    return {
      success: false,
      error: 'NETWORK_ERROR',
      message: error.message
    }
  }
}

/**
 * Verificar configuración sin gastar tokens
 */
export function verifyConfiguration() {
  const OPENAI_API_KEY = import.meta.env.VITE_OPENAI_API_KEY
  const OPENAI_MODEL = import.meta.env.VITE_OPENAI_MODEL || 'gpt-4o-mini'

  const results = {
    hasApiKey: Boolean(OPENAI_API_KEY),
    apiKeyValid: OPENAI_API_KEY && OPENAI_API_KEY !== 'sk-your-api-key-here' && OPENAI_API_KEY.startsWith('sk-'),
    apiKeyLength: OPENAI_API_KEY?.length || 0,
    model: OPENAI_MODEL,
    envFileExists: Boolean(import.meta.env.VITE_OPENAI_API_KEY),
    apiKeyPreview: OPENAI_API_KEY ? `${OPENAI_API_KEY.substring(0, 10)}...${OPENAI_API_KEY.substring(OPENAI_API_KEY.length - 4)}` : 'No configurada'
  }

  console.log('🔍 Verificación de configuración:')
  console.table(results)

  return results
}

// Exportar función para usar en consola del navegador
if (typeof window !== 'undefined') {
  window.testOpenAI = testOpenAIConnection
  window.verifyOpenAI = verifyConfiguration
  console.log('✅ Funciones de test disponibles en consola:')
  console.log('   - window.testOpenAI()')
  console.log('   - window.verifyOpenAI()')
}


