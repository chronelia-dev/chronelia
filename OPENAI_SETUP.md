# 🤖 CONFIGURACIÓN DE OPENAI - chronelia v2.6

## 📋 Guía de Integración de OpenAI

chronelia ahora incluye integración completa con OpenAI para respuestas inteligentes avanzadas en el chat IA.

---

## 🚀 PASO 1: Obtener API Key de OpenAI

### 1.1 Crear cuenta en OpenAI
1. Ve a https://platform.openai.com
2. Crea una cuenta o inicia sesión
3. Navega a https://platform.openai.com/api-keys

### 1.2 Generar API Key
1. Click en "Create new secret key"
2. Dale un nombre descriptivo (ej: "chronelia-app")
3. **COPIA LA KEY INMEDIATAMENTE** (solo se muestra una vez)
4. Guárdala en un lugar seguro

### 1.3 Añadir créditos (si es necesario)
- OpenAI requiere tener créditos en la cuenta
- Ve a https://platform.openai.com/account/billing
- Añade un método de pago
- Carga créditos mínimos ($5-10 USD)

---

## 🔧 PASO 2: Configurar chronelia

### 2.1 Crear archivo `.env`

En la raíz del proyecto, crea un archivo llamado `.env`:

```bash
# Supabase (ya configurado)
VITE_SUPABASE_URL=https://uzqtqflrhhjkcpkyfjoa.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# OpenAI (AGREGAR AQUÍ)
VITE_OPENAI_API_KEY=sk-proj-tu-api-key-aqui
VITE_OPENAI_MODEL=gpt-4o-mini
```

### 2.2 Reemplazar valores
- Reemplaza `sk-proj-tu-api-key-aqui` con tu API key real
- El modelo `gpt-4o-mini` es económico y rápido (recomendado)
- Otros modelos disponibles:
  - `gpt-4o` - Más potente pero más costoso
  - `gpt-3.5-turbo` - Económico y rápido

### 2.3 Reiniciar la aplicación
```bash
# Detén el servidor si está corriendo (Ctrl+C)

# Vuelve a iniciar
npm run dev
```

---

## ✅ PASO 3: Verificar Configuración

### 3.1 En el navegador:
1. Abre chronelia en http://localhost:5173
2. Login como admin
3. Ve a **Recomendaciones IA**
4. Click en **"Consultar IA"**
5. Verás un indicador de rayo ⚡ junto a "Asistente IA chronelia"
6. Debajo dirá: "Potenciado por OpenAI"

### 3.2 Prueba el chat:
- Escribe: "¿Cuántas reservas tengo?"
- Deberías recibir una respuesta detallada en 1-3 segundos
- La respuesta será contextual y natural (no predefinida)

---

## 💰 COSTOS DE OpenAI

### Modelo recomendado: `gpt-4o-mini`
```
Entrada:  $0.15 por 1M tokens (~$0.00015 por consulta)
Salida:   $0.60 por 1M tokens (~$0.00060 por respuesta)
```

**Ejemplo de uso:**
- 1,000 consultas al mes ≈ $0.75 USD
- 10,000 consultas al mes ≈ $7.50 USD

### Optimización de costos:
✅ Usa `gpt-4o-mini` (10x más barato que GPT-4)
✅ Límite de 500 tokens por respuesta (configurado)
✅ Historial limitado a últimos 10 mensajes
✅ Sistema local como fallback si falla OpenAI

---

## 🔍 SOLUCIÓN DE PROBLEMAS

### Error: "OpenAI no está configurado"
**Solución:**
1. Verifica que el archivo `.env` existe en la raíz del proyecto
2. Confirma que la variable `VITE_OPENAI_API_KEY` está presente
3. Reinicia el servidor (`npm run dev`)

### Error: "API key inválida"
**Solución:**
1. Verifica que copiaste la key completa (empieza con `sk-`)
2. Confirma que la key no tiene espacios extra
3. Genera una nueva key en OpenAI si es necesario

### Error: "Has excedido el límite de peticiones"
**Solución:**
1. Espera unos minutos antes de intentar de nuevo
2. OpenAI tiene límites de rate (ej: 3 peticiones/min en tier gratuito)
3. Considera upgrade de plan en OpenAI si es recurrente

### Error: "OpenAI está experimentando problemas"
**Solución:**
1. Verifica el estado de OpenAI: https://status.openai.com
2. Espera unos minutos y reintenta
3. El sistema usará respuestas básicas locales como fallback

### No recibo respuestas o son genéricas
**Solución:**
1. Verifica que tienes créditos en tu cuenta de OpenAI
2. Revisa la consola del navegador (F12) para ver logs
3. Confirma que el modelo configurado existe

---

## 📊 CARACTERÍSTICAS DE LA INTEGRACIÓN

### ✅ Contexto Automático
El chat IA envía automáticamente:
- Total de reservas
- Reservas activas
- Estadísticas del día
- Información de trabajadores
- Ingresos totales
- Duración promedio de servicios

### ✅ Memoria de Conversación
- Mantiene últimos 10 mensajes de contexto
- Puede responder preguntas de seguimiento
- Entiende referencias a mensajes anteriores

### ✅ Respuestas Naturales
- No usa respuestas predefinidas
- Se adapta al contexto específico
- Puede explicar conceptos complejos
- Da recomendaciones personalizadas

### ✅ Fallback Local
- Si OpenAI no está configurado, usa sistema básico
- Si hay error de red, responde localmente
- Usuario siempre tiene respuesta

---

## 🎯 EJEMPLOS DE USO

### Preguntas Simples:
```
Usuario: "¿Cuántas reservas tengo?"
IA: "Según tus datos actuales, tienes un total de 23 reservas 
registradas. De estas, 5 están activas en este momento y hoy 
se han realizado 7 nuevas reservas. ¿Te gustaría saber más 
detalles sobre alguna en particular?"
```

### Análisis Complejo:
```
Usuario: "¿Cómo puedo mejorar mis ingresos?"
IA: "Analizando tus datos, veo varias oportunidades:

1. **Optimizar horarios**: Con una duración promedio de 35 
   minutos por servicio, podrías atender 2-3 clientes más 
   por día optimizando los tiempos muertos.

2. **Promociones en horas valle**: Tus reservas bajan 
   considerablemente entre 2-4 PM. Considera ofertas 
   especiales para ese horario.

3. **Servicios premium**: Con 4 trabajadores activos, 
   podrías ofrecer servicios combinados que aumenten el 
   ticket promedio.

¿Quieres que profundice en alguna de estas estrategias?"
```

### Seguimiento Contextual:
```
Usuario: "¿Qué tal van las reservas?"
IA: "Hoy llevas 7 reservas, que está por encima del 
promedio. ¡Buen día!"

Usuario: "¿Y comparado con ayer?"
IA: "Ayer tuviste 5 reservas, así que hoy vas 2 reservas 
por encima (40% más). La tendencia es positiva."
```

---

## 🔐 SEGURIDAD

### ✅ Buenas Prácticas:
- ✅ API key en archivo `.env` (nunca en el código)
- ✅ `.env` en `.gitignore` (no se sube a GitHub)
- ✅ Variables con prefijo `VITE_` (se incluyen en build)
- ✅ Key hardcodeada en APK para producción

### ⚠️ Consideraciones:
- Las API keys en el frontend son visibles en el código compilado
- Para producción máxima seguridad, considera un backend intermedio
- Monitorea el uso en OpenAI Dashboard regularmente
- Rota las keys periódicamente

---

## 📱 COMPILAR APK CON OPENAI

### Opción 1: Con variables de entorno
```bash
# El .env ya está configurado
npm run build
npm exec cap copy android
cd android
.\gradlew assembleDebug
```
**Resultado:** APK incluye las keys del `.env`

### Opción 2: Sin variables (fallback hardcoded)
Si no existe `.env`, la app usa valores por defecto en `src/lib/openai.js`:
```javascript
const OPENAI_API_KEY = import.meta.env.VITE_OPENAI_API_KEY || ''
```

Para usar OpenAI en producción, edita `src/lib/openai.js`:
```javascript
const OPENAI_API_KEY = import.meta.env.VITE_OPENAI_API_KEY || 'sk-tu-key-real-aqui'
```

---

## 📈 MONITOREO DE USO

### Ver consumo en OpenAI:
1. https://platform.openai.com/usage
2. Revisa tokens consumidos
3. Revisa costo acumulado
4. Configura alertas de presupuesto

### Logs en la app:
Abre la consola del navegador (F12) para ver:
```
🔧 Estado de OpenAI: {
  configured: true,
  model: "gpt-4o-mini",
  hasKey: true,
  keyPreview: "sk-proj-..."
}

🤖 Enviando petición a OpenAI...
✅ Respuesta recibida de OpenAI
```

---

## 🎉 SIGUIENTE NIVEL

Una vez configurado OpenAI, puedes:
1. ✅ Hacer preguntas complejas sobre tu negocio
2. ✅ Obtener análisis predictivos
3. ✅ Recibir recomendaciones personalizadas
4. ✅ Exportar conversaciones (próxima versión)
5. ✅ Acciones directas desde el chat (próxima versión)

---

## 📞 SOPORTE

**Problemas con OpenAI:**
- Documentación oficial: https://platform.openai.com/docs
- Status page: https://status.openai.com
- Soporte: https://help.openai.com

**Problemas con chronelia:**
- Revisa logs en consola del navegador
- Verifica archivo `.env`
- Consulta `CAMBIOS_v2.6_OPENAI.md`

---

**¡Disfruta de chronelia potenciado con IA!** 🚀🤖







