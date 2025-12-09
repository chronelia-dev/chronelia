// API serverless para manejar peticiones a OpenAI
// Esto evita problemas de CORS al hacer la petición desde el servidor

export default async function handler(req, res) {
  // Solo permitir POST
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  // Headers CORS
  res.setHeader('Access-Control-Allow-Credentials', true)
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT')
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  )

  // Manejar preflight
  if (req.method === 'OPTIONS') {
    return res.status(200).end()
  }

  try {
    const { messages, model = 'gpt-4o-mini', temperature = 0.7, max_tokens = 500 } = req.body

    // Validar que exista la API key
    const OPENAI_API_KEY = process.env.VITE_OPENAI_API_KEY || process.env.OPENAI_API_KEY
    
    if (!OPENAI_API_KEY) {
      return res.status(500).json({ 
        error: 'NO_API_KEY',
        message: 'API key de OpenAI no configurada en el servidor' 
      })
    }

    // Validar que existan los mensajes
    if (!messages || !Array.isArray(messages) || messages.length === 0) {
      return res.status(400).json({ 
        error: 'INVALID_REQUEST',
        message: 'Se requiere un array de mensajes' 
      })
    }

    console.log('📡 Enviando petición a OpenAI desde servidor...')

    // Hacer la petición a OpenAI desde el servidor
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENAI_API_KEY}`
      },
      body: JSON.stringify({
        model,
        messages,
        temperature,
        max_tokens,
        presence_penalty: 0.6,
        frequency_penalty: 0.3
      })
    })

    // Si la respuesta no es OK, manejar el error
    if (!response.ok) {
      const error = await response.json().catch(() => ({}))
      console.error('❌ Error de OpenAI:', error)
      
      return res.status(response.status).json({
        error: 'OPENAI_ERROR',
        message: error.error?.message || 'Error al comunicarse con OpenAI',
        statusCode: response.status,
        details: error
      })
    }

    // Parsear y devolver la respuesta
    const data = await response.json()
    console.log('✅ Respuesta exitosa de OpenAI')

    return res.status(200).json(data)

  } catch (error) {
    console.error('💥 Error en API serverless:', error)
    
    return res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'Error interno del servidor',
      details: error.message
    })
  }
}


