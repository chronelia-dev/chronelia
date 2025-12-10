# ✅ CHECKLIST DE DIAGNÓSTICO - Escáner QR Web

**Fecha:** _______________  
**Tester:** _______________  
**Navegador:** _______________

---

## 🔧 PREPARACIÓN

```
[ ] Servidor iniciado (npm run dev)
[ ] Chronelia abierto en: http://localhost:5173/
[ ] Generador QR abierto: test-escaner-qr.html
[ ] Login realizado (usuario: _______________)
[ ] DevTools abierto (F12) en pestaña Console
```

---

## 🧪 PRUEBA 1: Apertura del Modal

```
Acción: Clic en botón flotante "Escanear"

[ ] Modal se abre con animación suave
[ ] Título "Escanear QR" visible
[ ] Solicitud de permisos de cámara aparece
[ ] Consola muestra: "📱 QRScanner Modal - Plataforma: web"
[ ] Sin errores rojos en consola

✅ Resultado: PASA / FALLA
Notas: _________________________________
```

---

## 🎥 PRUEBA 2: Acceso a la Cámara

```
Acción: Permitir acceso a cámara en navegador

[ ] Permisos otorgados correctamente
[ ] Video en vivo se muestra en el modal
[ ] Marco de escaneo animado visible
[ ] 4 esquinas del marco presentes
[ ] Línea horizontal animada moviéndose
[ ] Mensaje "Apunta la cámara al código QR"
[ ] Luz de cámara encendida (física)

✅ Resultado: PASA / FALLA
Notas: _________________________________
```

---

## 📷 PRUEBA 3: Escaneo de Código QR

```
Preparación:
  1. En generador: Clic en "⏱️ Sesión Normal (30 min)"
  2. Clic en "🎨 Generar Código QR"
  3. QR grande visible en pantalla

Acción: Apuntar cámara al QR generado

[ ] QR detectado en menos de 2 segundos
[ ] Toast verde: "✅ ¡Reserva activada!"
[ ] Nombre del cliente visible en toast
[ ] Duración visible en toast (30 minutos)
[ ] Modal se cierra automáticamente (800ms)
[ ] Reserva aparece en Dashboard
[ ] Card de reserva muestra datos correctos
[ ] Consola muestra: "✅ Reserva sincronizada"
[ ] Sin errores en consola

Datos de la reserva creada:
  Cliente: _______________________
  Duración: _______ minutos
  ID: _______________________

✅ Resultado: PASA / FALLA
Notas: _________________________________
```

---

## 🎯 PRUEBA 4: Botón de Prueba (Solo Admin)

```
Pre-requisito: [ ] Usuario es ADMIN

Acción: Clic en "Crear Reserva de Prueba (30 min)"

[ ] Botón visible en footer del modal
[ ] Reserva se crea instantáneamente
[ ] Toast de éxito aparece
[ ] Modal se cierra
[ ] Reserva aparece en Dashboard
[ ] Nombre: "Cliente Test [número]"
[ ] Duración: 30 minutos

SI NO ERES ADMIN:
[ ] Botón NO es visible (correcto)

✅ Resultado: PASA / FALLA / N/A (no admin)
Notas: _________________________________
```

---

## ❌ PRUEBA 5: Manejo de Errores

### Test 5.1: Cerrar Modal Durante Escaneo
```
Acción: Abrir modal → Clic en X (cerrar)

[ ] Modal se cierra suavemente
[ ] Luz de cámara se apaga
[ ] Sin errores en consola
[ ] Puede abrirse nuevamente sin problemas

✅ Resultado: PASA / FALLA
```

### Test 5.2: QR Inválido (opcional)
```
Acción: Escanear QR con texto plano (no JSON)

[ ] Toast rojo: "❌ Código QR inválido"
[ ] Descripción del error clara
[ ] Modal permanece abierto (web)
[ ] Puede escanear otro QR después

✅ Resultado: PASA / FALLA
```

### Test 5.3: Denegar Permisos (opcional)
```
Acción: Denegar permisos de cámara

[ ] Mensaje de error aparece
[ ] Instrucciones para permitir permisos
[ ] Botón "Reintentar" visible
[ ] Al permitir y reintentar, funciona

✅ Resultado: PASA / FALLA
```

---

## 🔍 VERIFICACIÓN TÉCNICA

### Consola del Navegador (F12)
```
[ ] Sin errores rojos durante todo el proceso
[ ] Log de plataforma al abrir modal
[ ] Log de sincronización al escanear
[ ] Sin warnings críticos
```

### Network (F12 → Network)
```
[ ] POST request a Supabase después de escanear
[ ] Status: 200 OK
[ ] Response contiene datos de reserva
```

### Performance
```
[ ] Modal abre en <500ms
[ ] Video inicia en <2 segundos
[ ] QR detectado en <2 segundos
[ ] Modal cierra suavemente sin lag
```

---

## 🌐 PRUEBAS EN NAVEGADORES

### Desktop

#### Chrome/Edge
```
Versión: _______________

[ ] Apertura del modal
[ ] Acceso a cámara
[ ] Escaneo de QR
[ ] Manejo de errores

✅ Resultado: PASA / FALLA
Notas: _________________________________
```

#### Firefox
```
Versión: _______________

[ ] Apertura del modal
[ ] Acceso a cámara
[ ] Escaneo de QR
[ ] Manejo de errores

✅ Resultado: PASA / FALLA
Notas: _________________________________
```

#### Safari (si aplica)
```
Versión: _______________

[ ] Apertura del modal
[ ] Acceso a cámara
[ ] Escaneo de QR
[ ] Manejo de errores

✅ Resultado: PASA / FALLA
Notas: _________________________________
```

### Mobile (si aplica)

#### Chrome Android
```
[ ] Todas las pruebas básicas

✅ Resultado: PASA / FALLA
```

#### Safari iOS
```
[ ] Todas las pruebas básicas

✅ Resultado: PASA / FALLA
```

---

## 📊 RESUMEN DE RESULTADOS

### Pruebas Críticas (deben pasar)
```
[ ] ✅ Prueba 1: Apertura del Modal
[ ] ✅ Prueba 2: Acceso a la Cámara
[ ] ✅ Prueba 3: Escaneo de QR
```

### Pruebas Importantes
```
[ ] ✅ Prueba 4: Botón de Prueba
[ ] ✅ Prueba 5: Manejo de Errores
```

### Navegadores Probados
```
[ ] Chrome/Edge Desktop
[ ] Firefox Desktop
[ ] Safari Desktop
[ ] Chrome Mobile
[ ] Safari iOS
```

---

## 🎯 MÉTRICAS ALCANZADAS

| Métrica | Objetivo | Alcanzado | ✅/❌ |
|---------|----------|-----------|-------|
| Tasa de apertura | 100% | ___% | [ ] |
| Acceso a cámara | >95% | ___% | [ ] |
| Tiempo detección QR | <2s | ___s | [ ] |
| Tasa de parseo | >98% | ___% | [ ] |
| Cierre correcto | 100% | ___% | [ ] |

---

## 🐛 PROBLEMAS ENCONTRADOS

### Problema #1
```
Descripción: _________________________________
_____________________________________________

Severidad: [ ] Crítico [ ] Alto [ ] Medio [ ] Bajo

Pasos para reproducir:
1. _______________________________________
2. _______________________________________
3. _______________________________________

Screenshot/Error: ____________________________
```

### Problema #2
```
Descripción: _________________________________
_____________________________________________

Severidad: [ ] Crítico [ ] Alto [ ] Medio [ ] Bajo

Pasos para reproducir:
1. _______________________________________
2. _______________________________________
3. _______________________________________

Screenshot/Error: ____________________________
```

### Problema #3
```
Descripción: _________________________________
_____________________________________________

Severidad: [ ] Crítico [ ] Alto [ ] Medio [ ] Bajo

Pasos para reproducir:
1. _______________________________________
2. _______________________________________
3. _______________________________________

Screenshot/Error: ____________________________
```

---

## ✅ ESTADO FINAL

```
[ ] 🟢 TODO FUNCIONAL - Listo para producción
    ✅ Todas las pruebas críticas pasaron
    ✅ Sin problemas mayores
    ✅ Performance aceptable

[ ] 🟡 FUNCIONAL CON ISSUES MENORES
    ✅ Funcionalidad básica funciona
    ⚠️ Algunos problemas no críticos
    ⚠️ Requiere optimizaciones

[ ] 🔴 REQUIERE FIXES
    ❌ Pruebas críticas fallaron
    ❌ Problemas que bloquean uso
    ❌ Requiere correcciones antes de usar
```

---

## 📝 COMENTARIOS ADICIONALES

```
_______________________________________________
_______________________________________________
_______________________________________________
_______________________________________________
_______________________________________________
_______________________________________________
```

---

## ✍️ FIRMAS

**Tester:**  
Nombre: _______________  
Firma: _______________  
Fecha: _______________

**Revisado por:**  
Nombre: _______________  
Firma: _______________  
Fecha: _______________

---

## 📎 ARCHIVOS ADJUNTOS

```
[ ] Screenshots de errores
[ ] Logs de consola
[ ] Video de demostración
[ ] Otros: _______________
```

---

**FIN DEL DIAGNÓSTICO**

---

*Versión del Checklist: 1.0*  
*Última actualización: Diciembre 10, 2025*

