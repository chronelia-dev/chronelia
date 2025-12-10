# ⚡ INICIO RÁPIDO - Diagnóstico Escáner QR

## 🎯 ¿Qué vamos a hacer?

Verificar que el **escáner QR funcione correctamente** en la versión web de Chronelia para que los trabajadores puedan registrar clientes sin problemas.

---

## 📚 Documentos Creados

### 1. 🚀 **EJECUTAR_DIAGNOSTICO_QR.md** ← **¡EMPIEZA AQUÍ!**
   - Guía paso a paso para ejecutar las pruebas
   - 6 pasos claramente definidos
   - Comandos listos para copiar/pegar
   - ⏱️ Tiempo estimado: 30-45 minutos

### 2. 📄 **DIAGNOSTICO_ESCANER_QR_WEB.md**
   - Documentación técnica completa
   - Detalles de implementación
   - Solución de problemas avanzados
   - Para consulta cuando tengas dudas técnicas

### 3. 🎨 **test-escaner-qr.html**
   - Herramienta para generar códigos QR de prueba
   - Abrir directamente en el navegador
   - 6 presets predefinidos
   - Interfaz bonita y fácil de usar

### 4. 📊 **RESUMEN_DIAGNOSTICO_ESCANER_QR.md**
   - Vista ejecutiva del diagnóstico
   - Estado del código actual
   - Métricas de éxito
   - Próximos pasos

---

## ⚡ QUICK START (3 pasos)

### Paso 1: Iniciar el servidor
```powershell
npm run dev
```

### Paso 2: Abrir en el navegador
```
Pestaña 1: http://localhost:5173/  (Chronelia)
Pestaña 2: test-escaner-qr.html     (Generador de QR)
```

### Paso 3: Probar el escáner
1. En Chronelia → Hacer login
2. Clic en el botón flotante de "Escanear" (centro inferior)
3. Permitir acceso a la cámara
4. En el generador → Clic en "⏱️ Sesión Normal"
5. Generar QR y escanearlo con Chronelia

**✅ Esperado:** Reserva se crea automáticamente y aparece en Dashboard

---

## 🎯 Checklist Ultra-Rápido

```
[ ] ✅ Servidor corriendo (npm run dev)
[ ] ✅ Modal se abre al hacer clic en botón QR
[ ] ✅ Cámara solicita permisos
[ ] ✅ Video en vivo se muestra
[ ] ✅ QR se detecta y procesa
[ ] ✅ Reserva aparece en Dashboard
```

---

## 🆘 Si tienes problemas

1. **Modal no se abre**
   ```powershell
   # Verificar que el servidor está corriendo
   # Ctrl+C y luego: npm run dev
   ```

2. **Cámara no funciona**
   ```
   Chrome → Clic en candado (URL) → Permisos → Cámara → Permitir
   ```

3. **QR no se detecta**
   - Acercar/alejar la cámara
   - Aumentar brillo de pantalla con el QR
   - Mejor iluminación
   - Probar con el botón "Crear Reserva de Prueba" (solo admin)

---

## 📖 Documentación Completa

Si necesitas más detalles, consulta en este orden:

1. **EJECUTAR_DIAGNOSTICO_QR.md** - Guía paso a paso
2. **DIAGNOSTICO_ESCANER_QR_WEB.md** - Detalles técnicos
3. **RESUMEN_DIAGNOSTICO_ESCANER_QR.md** - Vista ejecutiva

---

## ✨ Estado del Código

```
✅ QRScannerModal.jsx - Implementación completa
✅ BottomNav.jsx - Botón flotante funcionando
✅ jsQR - Librería instalada
✅ Store integration - Correcta
✅ Supabase sync - Implementada
✅ Sin errores de linter
```

---

## 🚀 ¡Listo para empezar!

**Siguiente paso:** Abre `EJECUTAR_DIAGNOSTICO_QR.md` y sigue los pasos.

**Tiempo estimado total:** 30-45 minutos

**Dificultad:** 🟢 Fácil (todo documentado paso a paso)

---

*¿Alguna duda? Todos los problemas comunes están documentados en los archivos de diagnóstico.*

