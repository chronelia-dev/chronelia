# 🚀 GUÍA DE EJECUCIÓN - Diagnóstico del Escáner QR

## PASO 1: Preparación del Entorno

### 1.1 Asegurar que el servidor está corriendo

```powershell
# En la terminal de PowerShell, desde la raíz del proyecto:
npm run dev
```

**Resultado esperado:**
```
VITE v5.x.x  ready in XXX ms

➜  Local:   http://localhost:5173/
➜  Network: use --host to expose
```

### 1.2 Abrir la aplicación en el navegador

1. Abrir Chrome o Edge (recomendado)
2. Navegar a: `http://localhost:5173/`
3. Hacer login (admin o trabajador)

---

## PASO 2: Abrir el Generador de QR de Prueba

### Opción A: Desde el archivo local
1. Abrir el archivo `test-escaner-qr.html` directamente en el navegador
2. O arrastrarlo a una pestaña del navegador

### Opción B: Usar el generador existente
1. Abrir `generar-qr-prueba.html` (si existe)

---

## PASO 3: Ejecutar las Pruebas del Checklist

### ✅ Prueba 1: Apertura del Modal

**En Chronelia (localhost:5173):**

1. Hacer clic en el botón flotante central (icono QR)
2. Observar que el modal se abre con animación
3. Abrir DevTools (F12) y verificar consola

**✅ Resultado exitoso si:**
- Modal se abre suavemente
- Aparece solicitud de permisos de cámara
- En consola: `📱 QRScanner Modal - Plataforma: web - Nativa: false`

---

### ✅ Prueba 2: Acceso a la Cámara

1. Permitir acceso a la cámara cuando el navegador lo solicite
2. Esperar que el video se cargue

**✅ Resultado exitoso si:**
- Video en vivo se muestra
- Marco de escaneo animado visible
- Mensaje: "Apunta la cámara al código QR"

**❌ Si hay problemas:**
```powershell
# Verificar permisos en Chrome:
# 1. Clic en el icono de candado (izquierda de la URL)
# 2. Permisos → Cámara → Permitir
# 3. Recargar página (F5)
```

---

### ✅ Prueba 3: Escaneo de Código QR

**Preparar QR de prueba:**

1. En `test-escaner-qr.html`:
   - Clic en "⏱️ Sesión Normal (30 min)"
   - Clic en "🎨 Generar Código QR"
   - Se mostrará un QR grande en pantalla

2. En Chronelia:
   - Abrir modal del escáner
   - Apuntar la cámara del laptop/teléfono al QR generado
   - Mantener estable por 1-2 segundos

**✅ Resultado exitoso si:**
- Toast verde: "✅ ¡Reserva activada!"
- Modal se cierra automáticamente
- Nueva reserva aparece en Dashboard
- Sin errores en consola

**💡 Tips para mejor detección:**
- Aumentar el brillo de la pantalla con el QR
- Acercar/alejar la cámara para enfocar
- Buena iluminación
- QR en pantalla grande (tablet/monitor)

---

### ✅ Prueba 4: Botón de Prueba (Solo Admin)

**Si estás logueado como ADMIN:**

1. Abrir modal del escáner
2. Scroll al final del modal
3. Clic en "Crear Reserva de Prueba (30 min)"

**✅ Resultado exitoso si:**
- Reserva se crea instantáneamente
- Aparece en Dashboard con nombre "Cliente Test XX"
- Modal se cierra

**Nota:** Este botón NO aparece para usuarios trabajadores.

---

### ✅ Prueba 5: Manejo de Errores

#### Test 5.1: QR Inválido

1. En `test-escaner-qr.html`, modificar manualmente el JSON:
   ```javascript
   // En la consola del navegador del generador:
   new QRCode(document.getElementById('qrcode'), {
     text: "TEXTO INVALIDO SIN JSON",
     width: 256,
     height: 256
   });
   ```

2. Escanear este QR
3. **Esperado:** Toast rojo "❌ Código QR inválido"

#### Test 5.2: Cerrar Modal Durante Escaneo

1. Abrir modal del escáner
2. Cerrar con X o clic fuera del modal
3. **Esperado:** Cámara se detiene, luz de cámara se apaga

#### Test 5.3: Denegar Permisos

1. Cerrar Chronelia
2. En Chrome: chrome://settings/content/camera
3. Bloquear `http://localhost:5173`
4. Recargar Chronelia y abrir escáner
5. **Esperado:** Mensaje de error con instrucciones

---

## PASO 4: Verificación en DevTools

### Abrir DevTools (F12) y verificar:

#### Pestaña Console:
```
✅ Debe aparecer al abrir modal:
   📱 QRScanner Modal - Plataforma: web - Nativa: false

✅ Al escanear exitosamente:
   ✅ Reserva sincronizada: {id: "...", ...}

❌ NO debe haber errores rojos
```

#### Pestaña Network:
```
✅ Verificar llamadas a Supabase después de escanear
   POST /rest/v1/rpc/...
   Status: 200 OK
```

#### React DevTools (si está instalado):
```
Components → QRScannerModal
✅ isOpen: true (cuando modal abierto)
✅ scanning: true (cuando cámara activa)
✅ processing: false → true → false (al escanear)
✅ cameraError: null
```

---

## PASO 5: Pruebas en Diferentes Navegadores

### Chrome/Edge ✅
```powershell
# Ya probado en desarrollo
# Mejor soporte y rendimiento
```

### Firefox
```powershell
# Abrir en Firefox:
# http://localhost:5173/
# Repetir pruebas
```

### Safari (si estás en Mac)
```powershell
# Nota: Safari requiere HTTPS en producción
# En local puede funcionar con http://localhost
```

---

## PASO 6: Marcar Resultados

### Copiar esta plantilla y completar:

```
========================
DIAGNÓSTICO ESCÁNER QR
Fecha: ____________
Tester: ____________
========================

PRUEBAS FUNCIONALES:
[ ] ✅ Apertura del Modal
[ ] ✅ Acceso a la Cámara
[ ] ✅ Escaneo de QR
[ ] ✅ Botón de Prueba (Admin)
[ ] ✅ Manejo de Errores

NAVEGADORES PROBADOS:
[ ] Chrome/Edge Desktop
[ ] Firefox Desktop
[ ] Safari Desktop
[ ] Chrome Mobile
[ ] Safari iOS

PROBLEMAS ENCONTRADOS:
_______________________
_______________________
_______________________

ESTADO FINAL:
[ ] ✅ TODO FUNCIONAL
[ ] ⚠️ FUNCIONAL CON ISSUES MENORES
[ ] ❌ REQUIERE FIXES
```

---

## 🆘 SOLUCIÓN DE PROBLEMAS COMUNES

### Problema: "Cannot read property 'getUserMedia' of undefined"
**Solución:**
- Usar HTTPS o localhost (no IP local)
- Verificar que el navegador soporta getUserMedia

### Problema: Modal se abre pero cámara no inicia
**Solución:**
```powershell
# 1. Verificar permisos del navegador
# 2. Cerrar otras aplicaciones que usen la cámara (Zoom, Teams, etc.)
# 3. Reiniciar el navegador
```

### Problema: QR no se detecta nunca
**Solución:**
1. Verificar que jsQR está instalado:
   ```powershell
   npm ls jsqr
   ```
   
2. Si no está instalado:
   ```powershell
   npm install jsqr
   ```

3. Reiniciar servidor:
   ```powershell
   # Ctrl+C para detener
   npm run dev
   ```

### Problema: "Error al escanear" sin más detalles
**Solución:**
1. Abrir DevTools (F12)
2. Buscar error específico en Console
3. Verificar en Network si hay errores de API

---

## ✅ CRITERIOS DE ÉXITO

El diagnóstico es EXITOSO si:

✅ Modal se abre correctamente (100% de las veces)  
✅ Cámara solicita y obtiene permisos  
✅ Video en vivo se muestra sin errores  
✅ QR se detecta en menos de 2 segundos  
✅ Reserva se crea y aparece en Dashboard  
✅ Modal se cierra correctamente  
✅ Sin errores en consola  
✅ Cámara se detiene al cerrar modal  

---

## 📝 PRÓXIMOS PASOS

Una vez completado este diagnóstico:

1. **Si TODO pasa ✅:**
   - Documentar como "Funcionalidad Verificada"
   - Proceder con siguientes diagnósticos
   - Considerar deploy a producción

2. **Si hay issues menores ⚠️:**
   - Documentar issues específicos
   - Crear tickets de mejora
   - Funcionalidad usable en producción

3. **Si requiere fixes ❌:**
   - Documentar problemas críticos
   - Priorizar fixes
   - Re-ejecutar diagnóstico después de fixes

---

## 📞 CONTACTO

Si encuentras problemas que no están documentados aquí:
1. Capturar screenshot del error
2. Copiar mensaje de error completo de consola
3. Documentar pasos exactos para reproducir
4. Crear issue o consultar con el equipo

---

**¡Buena suerte con el diagnóstico! 🚀**

