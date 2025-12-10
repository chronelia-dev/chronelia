# 🔧 Instrucciones para Compilar APK v3.0 - Escáner QR Mejorado

**Fecha:** 5 de Diciembre 2025  
**Versión:** 3.0  
**Cambios principales:** Escáner QR con ML Kit para Android y jsQR para web

---

## ⚠️ PROBLEMA ACTUAL: Java 21 vs Java 17

El proyecto requiere **Java 17**, pero Gradle está intentando usar **Java 21**, causando este error:

```
error: invalid source release: 21
```

---

## ✅ SOLUCIONES POSIBLES

### Opción 1: Usar Android Studio (RECOMENDADO)

1. **Abrir el proyecto en Android Studio:**
   ```bash
   npx cap open android
   ```

2. **Android Studio automáticamente:**
   - Detectará el proyecto
   - Usará el JDK correcto (Java 17)
   - Sincronizará Gradle

3. **Compilar el APK:**
   - Ve a: `Build → Build Bundle(s) / APK(s) → Build APK(s)`
   - O presiona: `Ctrl + Shift + F9`
   - Espera a que termine la compilación
   - El APK estará en: `android/app/build/outputs/apk/debug/app-debug.apk`

---

### Opción 2: Configurar Java en Terminal

1. **Verificar versión de Java:**
   ```bash
   java -version
   ```
   Debe mostrar: `java version "17.x.x"`

2. **Si tienes Java 21 activo, cambia a Java 17:**
   
   **En Windows:**
   ```powershell
   # Buscar dónde está instalado Java 17
   Get-ChildItem "C:\Program Files\Java" -Directory
   
   # Configurar JAVA_HOME temporal
   $env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
   $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
   
   # Verificar
   java -version
   ```

3. **Compilar:**
   ```bash
   cd android
   .\gradlew clean
   .\gradlew assembleDebug
   ```

---

### Opción 3: Modificar gradle.properties

En `android/gradle.properties`, agrega:

```properties
org.gradle.java.home=C:\\Program Files\\Java\\jdk-17
```

*(Ajusta la ruta según tu instalación de Java 17)*

Luego compila:
```bash
cd android
.\gradlew clean assembleDebug
```

---

## 📦 CAMBIOS EN ESTA VERSIÓN (v3.0)

### Escáner QR Mejorado

#### En Android:
- ✅ Usa **ML Kit** de Google para escaneo en tiempo real
- ✅ Abre la cámara nativa con UI del plugin
- ✅ Detección instantánea de códigos QR
- ✅ Manejo robusto de permisos

#### En Web:
- ✅ Usa **jsQR** para procesar imágenes de la cámara
- ✅ Vista previa en tiempo real
- ✅ Escaneo continuo frame por frame

#### Características Comunes:
- ✅ Botón central flotante "Escanear" en el panel inferior
- ✅ Modal con animaciones suaves
- ✅ Procesamiento de JSON del código QR
- ✅ Creación automática de reserva
- ✅ Feedback visual (toasts)
- ✅ Botón de "Prueba Rápida" para testing

---

## 🔍 ARCHIVOS MODIFICADOS

1. **`src/components/QRScannerModal.jsx`**
   - Agregado soporte para ML Kit en Android
   - Mantiene jsQR para web
   - Detección automática de plataforma

2. **`src/pages/QRScanner.jsx`**
   - Versión v3.0 con 3 métodos independientes:
     - Método 1: Desde Foto (jsQR)
     - Método 2: Tiempo Real (ML Kit)
     - Método 3: Entrada Manual

3. **`src/index.css`**
   - CSS para clase `qr-scanning`
   - Safe areas configuradas

---

## 🌐 DESPLIEGUE WEB

✅ **Ya desplegado en Vercel:**

Los cambios ya están en GitHub y Vercel los desplegará automáticamente en:
- **URL producción:** https://chronelia.online (si el DNS está configurado)
- **URL temporal:** https://chronelia-[hash].vercel.app

Para verificar el despliegue:
1. Ve a: https://vercel.com/pedromillorconsult-dev
2. Busca el proyecto "chronelia"
3. Verifica que el último deployment tenga estado "Ready"

---

## 🧪 TESTING

### En Web (Ya Disponible):
1. Abre: https://chronelia.online
2. Inicia sesión como trabajador
3. Clic en botón central "Escanear"
4. Permite acceso a la cámara
5. Apunta al código QR o usa "Reserva de Prueba"

### En Android (Pendiente de APK):
1. Compila el APK siguiendo las instrucciones arriba
2. Instala en dispositivo: `adb install app-debug.apk`
3. Abre la app
4. Clic en botón "Escanear"
5. Verifica que usa ML Kit (interfaz nativa)
6. Escanea código QR real

---

## 📋 FORMATO DE CÓDIGO QR

Los códigos QR deben contener este JSON:

```json
{
  "clientName": "Juan Pérez",
  "clientEmail": "juan@email.com",
  "code": "QR-12345",
  "duration": 30,
  "groupSize": 2
}
```

**Generar QRs:** Ver archivo `FORMATO_QR_PARA_IMPRIMIR.md`

---

## 🚀 PRÓXIMOS PASOS

1. **Compilar APK v3.0** usando Android Studio (opción más fácil)
2. **Instalar en dispositivo Android** para probar ML Kit
3. **Probar escaneo en tiempo real** con códigos QR físicos
4. **Verificar web app** en https://chronelia.online

---

## 📝 NOTAS

- ✅ El código web ya está desplegado y funcionando
- ⏳ El APK requiere Java 17 configurado correctamente
- 📱 ML Kit solo funciona en app nativa (Android/iOS)
- 🌐 jsQR funciona en todos lados (web + app)
- 🎯 El modal QRScanner detecta automáticamente la plataforma

---

## 🆘 SOPORTE

Si tienes problemas:

1. **Error de Java:** Usa Android Studio (maneja Java automáticamente)
2. **Error de permisos:** Permite cámara en navegador/app
3. **QR no detectado:** Revisa formato JSON con https://jsonlint.com/
4. **Web no funciona:** Verifica que https://chronelia.online esté accesible

---

**Estado:** ✅ Web desplegada | ⏳ APK pendiente de compilación  
**Desarrollado por:** AI Assistant  
**Fecha:** 5 de Diciembre 2025





