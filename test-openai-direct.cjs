// ============================================
// TEST DIRECTO DE OPENAI - NODE.JS
// ============================================
// Este script hace una petición real a OpenAI desde Node.js

const https = require('https');

// Cargar .env.local manualmente
const fs = require('fs');
const path = require('path');

// Leer .env.local
let OPENAI_API_KEY = '';
let OPENAI_MODEL = 'gpt-4o-mini';

try {
  const envPath = path.join(__dirname, '.env.local');
  const envContent = fs.readFileSync(envPath, 'utf8');
  
  // Parsear el contenido
  envContent.split('\n').forEach(line => {
    line = line.trim();
    if (line.startsWith('VITE_OPENAI_API_KEY=')) {
      OPENAI_API_KEY = line.replace('VITE_OPENAI_API_KEY=', '').trim();
    }
    if (line.startsWith('VITE_OPENAI_MODEL=')) {
      OPENAI_MODEL = line.replace('VITE_OPENAI_MODEL=', '').trim();
    }
  });
  
  console.log('📋 Configuración cargada:');
  console.log('  - Modelo:', OPENAI_MODEL);
  console.log('  - API Key:', OPENAI_API_KEY ? `${OPENAI_API_KEY.substring(0, 20)}...` : '❌ NO ENCONTRADA');
  console.log('  - Longitud:', OPENAI_API_KEY.length, 'caracteres');
  console.log('');
  
} catch (error) {
  console.error('❌ Error leyendo .env.local:', error.message);
  process.exit(1);
}

// Verificar que existe la API key
if (!OPENAI_API_KEY || OPENAI_API_KEY === 'sk-your-api-key-here') {
  console.error('❌ API key no configurada correctamente');
  process.exit(1);
}

// Preparar el payload
const payload = JSON.stringify({
  model: OPENAI_MODEL,
  messages: [
    {
      role: 'system',
      content: 'Eres un asistente de prueba. Responde brevemente en español.'
    },
    {
      role: 'user',
      content: 'Di "Conexión exitosa con OpenAI desde Chronelia" si recibes este mensaje.'
    }
  ],
  temperature: 0.5,
  max_tokens: 50
});

// Opciones de la petición
const options = {
  hostname: 'api.openai.com',
  port: 443,
  path: '/v1/chat/completions',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${OPENAI_API_KEY}`,
    'Content-Length': Buffer.byteLength(payload)
  }
};

console.log('🚀 Enviando petición a OpenAI...');
console.log('📡 Endpoint: https://api.openai.com/v1/chat/completions');
console.log('');

const startTime = Date.now();

// Hacer la petición
const req = https.request(options, (res) => {
  const endTime = Date.now();
  const responseTime = endTime - startTime;
  
  console.log('📊 Respuesta recibida:');
  console.log('  - Status Code:', res.statusCode);
  console.log('  - Status Message:', res.statusMessage);
  console.log('  - Tiempo de respuesta:', responseTime, 'ms');
  console.log('');
  
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    try {
      const response = JSON.parse(data);
      
      if (res.statusCode === 200) {
        console.log('✅ TEST EXITOSO!');
        console.log('');
        console.log('📦 Respuesta de OpenAI:');
        console.log('  - Modelo usado:', response.model);
        console.log('  - ID:', response.id);
        console.log('');
        
        if (response.choices && response.choices.length > 0) {
          const message = response.choices[0].message.content;
          console.log('💬 Mensaje de la IA:');
          console.log('  "' + message + '"');
          console.log('');
        }
        
        if (response.usage) {
          console.log('📊 Uso de tokens:');
          console.log('  - Prompt tokens:', response.usage.prompt_tokens);
          console.log('  - Completion tokens:', response.usage.completion_tokens);
          console.log('  - Total tokens:', response.usage.total_tokens);
          console.log('  - Costo aproximado: $' + ((response.usage.total_tokens / 1000000) * 0.15).toFixed(6));
          console.log('');
        }
        
        console.log('🎉 La conexión con OpenAI funciona correctamente!');
        console.log('');
        console.log('✅ RESULTADO: SUCCESS');
        
      } else {
        console.error('❌ ERROR HTTP:', res.statusCode);
        console.error('');
        console.error('📋 Detalles del error:');
        console.error(JSON.stringify(response, null, 2));
        console.error('');
        
        if (res.statusCode === 401) {
          console.error('🔑 La API key es inválida o expiró');
          console.error('Solución: Genera una nueva en https://platform.openai.com/api-keys');
        } else if (res.statusCode === 429) {
          console.error('⏳ Límite de peticiones excedido');
          console.error('Solución: Espera unos minutos o verifica tu plan en OpenAI');
        } else if (res.statusCode === 500 || res.statusCode === 503) {
          console.error('🔧 OpenAI está teniendo problemas temporales');
          console.error('Solución: Espera unos minutos y reintenta');
        }
        
        console.error('');
        console.error('❌ RESULTADO: FAILED');
      }
    } catch (error) {
      console.error('❌ Error parseando respuesta:', error.message);
      console.error('Respuesta raw:', data);
    }
  });
});

req.on('error', (error) => {
  console.error('❌ ERROR DE RED:', error.message);
  console.error('');
  console.error('Posibles causas:');
  console.error('  - Sin conexión a internet');
  console.error('  - Firewall bloqueando la conexión');
  console.error('  - Proxy o VPN interfiriendo');
  console.error('');
  console.error('❌ RESULTADO: NETWORK_ERROR');
});

req.write(payload);
req.end();

