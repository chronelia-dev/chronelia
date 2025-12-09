# 🎨 Guía Completa: Cambiar Icono de chronelia.

## 📋 **Preparación del Icono**

### **Requisitos del Icono:**
- **Formato:** PNG
- **Tamaño recomendado:** 512x512 px (mínimo 192x192 px)
- **Fondo:** Transparente (PNG) o color sólido
- **Contenido:** Tu logo debe ocupar el 80% del canvas (dejar margen)

### **Herramientas Online para Preparar:**
- **Canva** → https://www.canva.com/ (fácil y gratis)
- **Figma** → https://www.figma.com/ (profesional)
- **Remove.bg** → https://www.remove.bg/ (quitar fondo)
- **TinyPNG** → https://tinypng.com/ (optimizar tamaño)

---

## 🚀 **Método 1: Android Studio (Recomendado)**

### **Paso 1: Abrir Android Studio**
```bash
npx cap open android
```

### **Paso 2: Acceder a Image Asset Studio**
1. En el panel izquierdo, busca la carpeta `android/app/src/main/res`
2. **Clic derecho en `res`**
3. **New** → **Image Asset**

### **Paso 3: Configurar el Icono**

Se abrirá una ventana con 3 pestañas:

#### **📱 Pestaña 1: Launcher Icons (Legacy)**
```
Icon Type: Launcher Icons (Legacy)
Name: ic_launcher
Asset Type: Image

[Path] → Selecciona tu logo PNG
```

Opciones:
- **Trim:** ☑️ Sí (recortar espacio vacío)
- **Padding:** 10-15% (margen de seguridad)
- **Background:** Color sólido o transparente

Click **Next** → **Finish**

#### **🎯 Pestaña 2: Launcher Icons (Adaptive and Legacy)**
```
Foreground Layer:
  - Asset Type: Image
  - Path: [Tu logo PNG]
  - Trim: Yes
  - Resize: 70-80%

Background Layer:
  - Asset Type: Color
  - Color: #FFFFFF (blanco) o tu color de marca
```

Click **Next** → **Finish**

#### **🌐 Pestaña 3: Notification Icons (Opcional)**
Si quieres personalizar el icono de notificaciones:
```
Asset Type: Image
Path: [Logo simplificado PNG]
Padding: 15%
```

### **Paso 4: Verificar los Iconos Generados**

Android Studio creará automáticamente todos estos tamaños:
```
android/app/src/main/res/
├─ mipmap-mdpi/
│  ├─ ic_launcher.png (48x48)
│  └─ ic_launcher_round.png
├─ mipmap-hdpi/
│  ├─ ic_launcher.png (72x72)
│  └─ ic_launcher_round.png
├─ mipmap-xhdpi/
│  ├─ ic_launcher.png (96x96)
│  └─ ic_launcher_round.png
├─ mipmap-xxhdpi/
│  ├─ ic_launcher.png (144x144)
│  └─ ic_launcher_round.png
├─ mipmap-xxxhdpi/
│  ├─ ic_launcher.png (192x192)
│  └─ ic_launcher_round.png
└─ mipmap-anydpi-v26/
   ├─ ic_launcher.xml
   └─ ic_launcher_round.xml
```

**¡Listo!** Todos los tamaños generados automáticamente.

---

## 🔧 **Método 2: Manual (Avanzado)**

Si prefieres hacerlo manualmente:

### **Paso 1: Generar Todos los Tamaños**

Usa estas herramientas online:
- **Android Asset Studio** → https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html
- **App Icon Generator** → https://www.appicon.co/

Sube tu logo de 512x512 y descarga el ZIP con todos los tamaños.

### **Paso 2: Reemplazar Archivos**

Copia los archivos generados a:
```
android/app/src/main/res/mipmap-[densidad]/
```

Densidades necesarias:
- `mipmap-mdpi` → 48x48
- `mipmap-hdpi` → 72x72
- `mipmap-xhdpi` → 96x96
- `mipmap-xxhdpi` → 144x144
- `mipmap-xxxhdpi` → 192x192

---

## 🌐 **Actualizar Icono Web (Logo en la App)**

Para el logo que se muestra DENTRO de la app (login, header):

### **Archivo Actual:**
```
public/logo.png  ← Reemplaza este archivo
```

### **Cómo Reemplazarlo:**

1. **Prepara tu logo:**
   - Formato: PNG o SVG
   - Tamaño: 256x256 px (PNG) o vectorial (SVG)
   - Fondo: Transparente

2. **Reemplázalo:**
   ```bash
   # Si tu logo se llama "mi-logo.png"
   cp "mi-logo.png" public/logo.png
   ```

3. **Rebuild:**
   ```bash
   npm run build
   npx cap sync android
   ```

---

## ✅ **Verificar los Cambios**

### **1. En Android Studio (Vista Previa):**
- Abre: `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- Deberías ver tu nuevo icono

### **2. Compilar y Probar:**
```bash
# Recompilar APK
cd android
.\gradlew assembleDebug

# Instalar en dispositivo
adb install app/build/outputs/apk/debug/app-debug.apk
```

### **3. Ver en el Dispositivo:**
- El icono nuevo aparecerá en el cajón de aplicaciones
- En notificaciones
- En ajustes del sistema

---

## 🎨 **Tips de Diseño para el Icono:**

### ✅ **Buenas Prácticas:**
- **Simple:** Evita detalles muy pequeños
- **Reconocible:** Debe verse bien a 48x48 px
- **Sin texto:** El nombre de la app aparece debajo
- **Centrado:** Deja margen de 10-15% alrededor
- **Alto contraste:** Debe verse bien en fondos claros y oscuros

### ❌ **Evitar:**
- Texto muy pequeño
- Muchos detalles finos
- Degradados complejos (se ven mal en tamaños pequeños)
- Bordes muy pegados al límite

---

## 📱 **Iconos Adaptativos (Android 8+)**

Android moderno usa iconos adaptativos con 2 capas:

### **Foreground (Frente):**
- Tu logo principal
- Debe estar centrado
- Ocupa 70% del canvas

### **Background (Fondo):**
- Color sólido o patrón
- Se verá detrás del logo
- Puede ser transparente

**Ventaja:** Android puede aplicar diferentes formas (círculo, cuadrado redondeado, etc.)

---

## 🔄 **Flujo Completo:**

```
1. Preparar logo PNG (512x512)
   ↓
2. Abrir Android Studio
   npx cap open android
   ↓
3. Clic derecho en res → New → Image Asset
   ↓
4. Seleccionar logo y configurar
   ↓
5. Next → Finish
   ↓
6. Recompilar APK
   cd android
   .\gradlew assembleDebug
   ↓
7. ¡Listo! Nuevo icono instalado
```

---

## 📂 **Ubicaciones de Archivos:**

### **Icono de la App (Android):**
```
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
```

### **Logo dentro de la App (Web/Android):**
```
public/logo.png
```

### **Favicon (Web):**
```
public/favicon.ico  ← (Opcional)
```

---

## 🆘 **Problemas Comunes:**

### **El icono no cambia después de compilar:**
1. Desinstala la app del dispositivo
2. Limpia el proyecto: `cd android && .\gradlew clean`
3. Recompila: `.\gradlew assembleDebug`
4. Reinstala la APK

### **El icono se ve cortado:**
- Aumenta el padding en Image Asset Studio
- Deja más margen en tu diseño (15-20%)

### **El icono se ve pixelado:**
- Tu logo original es muy pequeño
- Usa mínimo 512x512 px

---

## 🎯 **Resumen Rápido:**

**Para cambiar el icono de la app Android:**
1. `npx cap open android`
2. Clic derecho en `res` → New → Image Asset
3. Selecciona tu logo PNG de 512x512
4. Next → Finish
5. Recompila con `.\gradlew assembleDebug`

**Para cambiar el logo dentro de la app:**
1. Reemplaza `public/logo.png` con tu nuevo logo
2. `npm run build`
3. `npx cap sync android`

---

¿Necesitas ayuda con algún paso específico? 🚀




