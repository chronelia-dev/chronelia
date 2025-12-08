# 🔧 Configurar OpenAI en Vercel (Producción)

## ⚠️ Problema CORS Solucionado

El error de CORS que viste:
```
Access to fetch at 'https://api.openai.com/v1/chat/completions' has been blocked by CORS policy
```

**Ya está solucionado** con una API serverless que actúa como intermediario.

---

## 🚀 Cambios Implementados

### 1. ✅ API Serverless Creada
- **Archivo:** `api/chat.js`
- **Función:** Maneja las peticiones a OpenAI desde el servidor
- **Beneficio:** La API key nunca se expone en el navegador

### 2. ✅ Cliente Actualizado
- **Archivos:** `src/lib/openai.js`, `src/utils/testOpenAI.js`
- **Lógica:** 
  - En **desarrollo** (localhost): Llamada directa a OpenAI
  - En **producción**: Usa `/api/chat` (serverless)

### 3. ✅ Vercel Config Actualizada
- **Archivo:** `vercel.json`
- **Cambio:** Excluye rutas `/api/*` de rewrites para que funcionen las API routes

---

## 📝 PASO IMPORTANTE: Configurar Variable de Entorno en Vercel

### Opción 1: Desde el Dashboard de Vercel (Recomendado)

1. **Ve a tu proyecto en Vercel:**
   - https://vercel.com/dashboard

2. **Selecciona tu proyecto** `chronelia`

3. **Ve a Settings → Environment Variables**

4. **Agrega la variable:**
   - **Key:** `OPENAI_API_KEY`
   - **Value:** `sk-proj-mmvBfrRlacZQ...` (tu API key completa)
   - **Environments:** ✅ Production ✅ Preview ✅ Development

5. **Click en "Save"**

6. **Redeploy:**
   - Ve a Deployments
   - Click en los 3 puntos del último deployment
   - "Redeploy"

---

### Opción 2: Desde la CLI de Vercel

```bash
# Instalar CLI si no la tienes
npm i -g vercel

# Login
vercel login

# Agregar variable de entorno
vercel env add OPENAI_API_KEY

# Cuando pregunte, pega tu API key
# Selecciona todos los environments

# Redeploy
vercel --prod
```

---

## 🧪 Verificar que Funciona

### Después del deploy:

1. **Abre tu app:** https://chronelia.online

2. **Abre la consola** (F12)

3. **Ejecuta:**
   ```javascript
   await window.testOpenAI()
   ```

4. **Deberías ver:**
   ```javascript
   {
     success: true,
     message: "Conexión exitosa con OpenAI",
     aiResponse: "Conexión exitosa."
   }
   ```

---

## 🔍 Verificar Variables de Entorno

Desde la consola de tu app en producción:

```javascript
// Esto debería mostrar "Serverless (/api/chat)" en producción
console.log('Environment:', window.location.hostname)
```

---

## 📊 Arquitectura Nueva

### Antes (❌ Error CORS):
```
Navegador → OpenAI API (bloqueado por CORS)
```

### Ahora (✅ Funciona):
```
Navegador → Vercel Serverless Function (/api/chat) → OpenAI API
```

---

## 🎯 Próximos Pasos

1. ✅ Hacer commit y push de los cambios
2. ⚠️ **IMPORTANTE:** Configurar `OPENAI_API_KEY` en Vercel
3. ✅ Esperar a que se despliegue automáticamente
4. ✅ Probar el Chat IA en producción

---

## 💡 Notas Importantes

- La API key **NUNCA** se expone en el código del frontend en producción
- En desarrollo local (localhost) sigue usando `.env.local`
- La función serverless se ejecuta en el servidor de Vercel
- No hay límites de CORS porque la petición se hace desde el servidor

---

## 🐛 Solución de Problemas

### Si sigue sin funcionar:

1. **Verificar que la variable existe:**
   ```bash
   vercel env ls
   ```

2. **Verificar logs en Vercel:**
   - Dashboard → Functions → Ver logs de `/api/chat`

3. **Verificar que se redesplegó:**
   - Dashboard → Deployments → Ver el más reciente

---

**Creado:** Diciembre 8, 2025  
**Versión:** 1.0  
**Fix:** CORS error en producción

