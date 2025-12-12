# 🧪 CÓMO PROBAR LA CONEXIÓN A OPENAI

## ⚠️ PROBLEMA ACTUAL

Estás viendo este error en el Chat de IA:

```
**Error al conectar con OpenAI**
Cannot read properties of undefined (reading 'length')
```

## ✅ SOLUCIÓN: TEST DE CONEXIÓN

He creado herramientas para diagnosticar el problema. Hay 3 formas de probar:

---

## MÉTODO 1: CONSOLA DEL NAVEGADOR (MÁS RÁPIDO) ⚡

### Paso 1: Iniciar la app

```bash
npm run dev
```

### Paso 2: Abrir la consola

1. Abre tu app en el navegador
2. Presiona **F12** (Developer Tools)
3. Ve a la pestaña **Console**

### Paso 3: Ejecutar tests

#### Test A: Verificar configuración (SIN gastar tokens)

```javascript
window.verifyOpenAI()
```

**Deberías ver:**
```
hasApiKey: true
apiKeyValid: true
apiKeyLength: 164 (o similar)
model: "gpt-4o-mini"
```

#### Test B: Ping real a OpenAI (gasta ~$0.0001)

```javascript
await window.testOpenAI()
```

**Si es exitoso verás:**
```javascript
{
  success: true,
  message: "Conexión exitosa con OpenAI",
  aiResponse: "Conexión exitosa",
  responseTime: 1234,
  usage: {
    total_tokens: 45,
    ...
  }
}
```

**Si falla verás:**
```javascript
{
  success: false,
  error: "INVALID_API_KEY", // o el error específico
  message: "Descripción del error",
  ...
}
```

---

## MÉTODO 2: COMPONENTE DE TEST (VISUAL) 🎨

### Paso 1: Agregar ruta temporal

Edita `src/App.jsx` y agrega:

```jsx
import OpenAITest from './components/OpenAITest'

// Dentro de <Routes>:
<Route path="/test-openai" element={<OpenAITest />} />
```

### Paso 2: Visitar la página

Abre: `http://localhost:5173/test-openai`

### Paso 3: Usar la interfaz

1. Click en **"🔍 Verificar Configuración"** - No gasta tokens
2. Click en **"⚡ Hacer Ping a OpenAI"** - Gasta tokens pero prueba de verdad

Verás resultados en pantalla con colores:
- 🟢 Verde = Éxito
- 🔴 Rojo = Error
- 🟡 Amarillo = Advertencia

---

## MÉTODO 3: DESDE EL CÓDIGO (AVANZADO) 💻

Importa la función en cualquier componente:

```jsx
import { testOpenAIConnection } from '@/utils/testOpenAI'

const result = await testOpenAIConnection()

if (result.success) {
  console.log('✅ Funciona!', result.aiResponse)
} else {
  console.error('❌ Error:', result.message)
}
```

---

## 📊 ERRORES COMUNES Y SOLUCIONES

### Error: `NO_API_KEY`

**Problema:** No existe el archivo `.env.local` o está vacío

**Solución:**
```bash
# Verificar que existe
ls -la .env.local

# Si no existe, crearlo con:
echo "VITE_OPENAI_API_KEY=sk-proj-tu-api-key-aqui" > .env.local
```

### Error: `INVALID_API_KEY` (401)

**Problema:** La API key es incorrecta o expiró

**Solución:**
1. Ve a https://platform.openai.com/api-keys
2. Genera una nueva API key
3. Actualiza `.env.local`:
   ```
   VITE_OPENAI_API_KEY=sk-proj-nueva-key-aqui
   ```
4. Reinicia el servidor: `npm run dev`

### Error: `RATE_LIMIT` (429)

**Problema:** Demasiadas peticiones

**Solución:**
1. Espera 1-2 minutos
2. Si persiste, revisa tu cuenta de OpenAI
3. Verifica que tienes créditos disponibles

### Error: `NETWORK_ERROR`

**Problema:** No hay conexión a internet o está bloqueada

**Solución:**
1. Verifica tu conexión a internet
2. Desactiva VPN temporalmente
3. Verifica firewall/antivirus

### Error: `INVALID_RESPONSE`

**Problema:** OpenAI devolvió datos en formato incorrecto

**Solución:**
1. Este es raro, probablemente un problema temporal de OpenAI
2. Espera unos minutos y reintenta
3. Verifica en https://status.openai.com/

---

## 🔍 LOGS DETALLADOS

Al ejecutar el test en la consola, verás logs como:

```
🧪 Iniciando test de OpenAI...
📝 Configuración:
  - Modelo: gpt-4o-mini
  - API Key: sk-proj-mmvBfrRlacZ...
📡 Enviando petición de prueba...
📊 Respuesta recibida
  - Status: 200
  - Status Text: OK
  - Tiempo de respuesta: 1523ms
📦 Datos recibidos: {choices: [...], usage: {...}}
✅ Test exitoso!
💬 Respuesta: Conexión exitosa
```

Si hay un error verás:
```
❌ Error HTTP: 401
❌ Detalles: {error: {message: "Invalid API key", ...}}
```

---

## 🎯 DIAGNÓSTICO PASO A PASO

### 1. Verificar que el archivo existe

```bash
cat .env.local
```

Deberías ver:
```
VITE_OPENAI_API_KEY=sk-proj-...
VITE_OPENAI_MODEL=gpt-4o-mini
```

### 2. Verificar formato de la API key

La key debe:
- ✅ Empezar con `sk-proj-`
- ✅ Tener ~164 caracteres
- ❌ NO tener espacios
- ❌ NO tener comillas extra

### 3. Reiniciar el servidor

```bash
# Ctrl+C para detener
npm run dev
```

### 4. Verificar en consola

Cuando la app cargue, busca en la consola:
```
🔧 Estado de OpenAI: {
  configured: true,
  model: "gpt-4o-mini",
  hasKey: true,
  keyPreview: "sk-proj-mm..."
}
```

Si `configured: false`, hay un problema de configuración.

### 5. Ejecutar test

```javascript
await window.testOpenAI()
```

---

## 💰 COSTOS

Cada test consume:
- **Tokens:** ~40-60 tokens
- **Costo:** ~$0.0001 USD (un centavo cada 100 tests)
- **Modelo:** gpt-4o-mini (el más económico)

Es muy barato probar. Puedes hacer 10,000 tests por $1 USD.

---

## ✅ MEJORAS IMPLEMENTADAS

He mejorado el código para prevenir el error:

### En `src/lib/openai.js`:

- ✅ Validación de estructura de respuesta
- ✅ Verificación de `data.choices` existe y es array
- ✅ Verificación de `data.choices.length > 0`
- ✅ Validación de tipo de `aiMessage`
- ✅ Logs detallados en cada paso
- ✅ Mensajes de error más específicos

### Nuevos archivos:

- ✅ `src/utils/testOpenAI.js` - Funciones de test
- ✅ `src/components/OpenAITest.jsx` - Componente visual
- ✅ Este documento de instrucciones

---

## 🚀 PRÓXIMOS PASOS

### Si el test es EXITOSO:

1. El problema está resuelto con las mejoras
2. Prueba el Chat de IA normal en el Dashboard
3. Si sigue fallando, comparte los logs de la consola

### Si el test FALLA:

1. Anota el código de error exacto
2. Anota el mensaje completo
3. Copia los logs de la consola
4. Comparte esa información

---

## 📝 EJEMPLO DE RESPUESTA EXITOSA

```javascript
{
  success: true,
  message: "Conexión exitosa con OpenAI",
  aiResponse: "Conexión exitosa si recibes este mensaje.",
  model: "gpt-4o-mini",
  usage: {
    prompt_tokens: 28,
    completion_tokens: 7,
    total_tokens: 35
  },
  responseTime: 1456,
  details: {
    tokensUsed: 35,
    promptTokens: 28,
    completionTokens: 7
  }
}
```

---

## 🎉 RESUMEN

**Para probar AHORA MISMO:**

1. Abre la consola del navegador (F12)
2. Ejecuta: `await window.testOpenAI()`
3. Lee el resultado
4. Compártelo si necesitas ayuda

**Esto te dirá EXACTAMENTE qué está mal.** 🎯

---

**Creado:** Diciembre 8, 2025  
**Versión:** 1.0  
**Propósito:** Diagnosticar problemas de OpenAI en Chronelia







