# 🚀 Guía de Compilación de APK para Proyectos Capacitor/Ionic

Esta guía está basada en la configuración exitosa del proyecto Match and Fight y puede ser aplicada a cualquier proyecto Capacitor/Ionic que tenga problemas de compilación.

## 📋 Requisitos Previos

### 1. Java JDK 17 (CRÍTICO)
**NO usar JDK 21 o versiones superiores**

- Descargar e instalar: [Oracle JDK 17](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html) o [OpenJDK 17](https://adoptium.net/temurin/releases/?version=17)
- Verificar instalación:
```bash
java -version
# Debe mostrar: java version "17.x.x"
```

### 2. Gradle 8.9 (IMPORTANTE)
**NO usar Gradle 9.0-milestone o versiones superiores**

- Se configurará automáticamente mediante gradle-wrapper
- La versión se define en `android/gradle/wrapper/gradle-wrapper.properties`

### 3. Android SDK
- Instalar Android Studio o Android Command Line Tools
- Ubicación típica en Windows: `C:\Users\[TuUsuario]\AppData\Local\Android\Sdk`
- Ubicación típica en Mac/Linux: `~/Library/Android/sdk` o `~/Android/Sdk`

### 4. Node.js y NPM
- Node.js 16 o superior
- npm 8 o superior

---

## 🔧 Configuración Paso a Paso

### PASO 1: Configurar Gradle Wrapper

**Archivo:** `android/gradle/wrapper/gradle-wrapper.properties`

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-bin.zip
networkTimeout=10000
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
```

### PASO 2: Configurar local.properties

**Archivo:** `android/local.properties`

```properties
## Location of the SDK
sdk.dir=C:\\Users\\[TuUsuario]\\AppData\\Local\\Android\\Sdk
```

**IMPORTANTE:**
- En Windows, usar dobles barras invertidas `\\`
- En Mac/Linux, usar barras normales `/`
- Ajustar la ruta según tu sistema

### PASO 3: Configurar Build Gradle Principal

**Archivo:** `android/capacitor-cordova-android-plugins/build.gradle`

Buscar la sección `compileOptions` y asegurar que tenga:

```gradle
android {
    // ... otras configuraciones ...
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}
```

### PASO 4: Configurar Capacitor Build Gradle

**Archivo:** `android/app/capacitor.build.gradle`

```gradle
android {
  compileOptions {
      sourceCompatibility JavaVersion.VERSION_17
      targetCompatibility JavaVersion.VERSION_17
  }
}
```

### PASO 5: Configurar Plugins de Node Modules

Estos archivos se regeneran cuando instalas dependencias, pero pueden necesitar corrección:

**Archivo:** `node_modules/@capacitor/android/capacitor/build.gradle`

Buscar `compileOptions` y cambiar a:
```gradle
compileOptions {
    sourceCompatibility JavaVersion.VERSION_17
    targetCompatibility JavaVersion.VERSION_17
}
```

**Archivo:** `node_modules/@capacitor/camera/android/build.gradle` (si usas cámara)

Buscar `compileOptions` y cambiar a:
```gradle
compileOptions {
    sourceCompatibility JavaVersion.VERSION_17
    targetCompatibility JavaVersion.VERSION_17
}
```

**NOTA:** Si tienes otros plugins de Capacitor instalados, buscar sus archivos `build.gradle` en `node_modules/@capacitor/[plugin]/android/build.gradle` y aplicar el mismo cambio.

---

## 🏗️ Proceso de Compilación

### Comandos de Compilación (Secuencia Completa)

**Para Windows (PowerShell):**

```powershell
# 1. Asegurarse de estar en la carpeta del proyecto frontend
cd tu-proyecto/frontend

# 2. Instalar dependencias (si es necesario)
npm.cmd install

# 3. Compilar el proyecto web
npm.cmd run build

# 4. Copiar archivos web a Android
npm.cmd exec cap copy android

# 5. Ir a la carpeta android
cd android

# 6. Limpiar compilaciones anteriores
.\gradlew clean

# 7. Compilar APK Debug
.\gradlew assembleDebug --rerun-tasks

# 8. (Opcional) Compilar APK Release
# .\gradlew assembleRelease
```

**Para Mac/Linux (Terminal):**

```bash
# 1. Asegurarse de estar en la carpeta del proyecto frontend
cd tu-proyecto/frontend

# 2. Instalar dependencias (si es necesario)
npm install

# 3. Compilar el proyecto web
npm run build

# 4. Copiar archivos web a Android
npm exec cap copy android

# 5. Ir a la carpeta android
cd android

# 6. Limpiar compilaciones anteriores
./gradlew clean

# 7. Compilar APK Debug
./gradlew assembleDebug --rerun-tasks

# 8. (Opcional) Compilar APK Release
# ./gradlew assembleRelease
```

---

## 📦 Ubicación de la APK Generada

Después de una compilación exitosa, encontrarás la APK en:

```
android/app/build/outputs/apk/debug/app-debug.apk
```

O si tiene un nombre personalizado:
```
android/app/build/outputs/apk/debug/[NombreApp]-v[version]-[fecha]-debug.apk
```

---

## 🐛 Solución de Problemas Comunes

### Error: "Unsupported class file major version XX"
**Causa:** Versión de Java incorrecta  
**Solución:** Instalar JDK 17 y asegurar que todas las configuraciones `JavaVersion.VERSION_XX` estén en `VERSION_17`

### Error: "Could not determine java version from 'XX.X.X'"
**Causa:** Gradle no compatible con la versión de Java  
**Solución:** Usar Gradle 8.9 exactamente (verificar gradle-wrapper.properties)

### Error: "SDK location not found"
**Causa:** Archivo local.properties no configurado correctamente  
**Solución:** Verificar que la ruta en `local.properties` apunte correctamente al Android SDK

### Error: PowerShell no puede ejecutar npm
**Causa:** Política de ejecución de scripts en Windows  
**Solución:** Usar `npm.cmd` en lugar de `npm`

### Error: "Execution failed for task ':app:compileDebugJavaWithJavac'"
**Causa:** Configuraciones de Java inconsistentes  
**Solución:** 
1. Verificar que TODOS los archivos build.gradle tengan VERSION_17
2. Ejecutar `.\gradlew clean` antes de compilar
3. Reiniciar el daemon de Gradle: `.\gradlew --stop`

### Los cambios no se reflejan en la APK
**Causa:** Caché de compilación  
**Solución:** Usar el flag `--rerun-tasks` con assembleDebug

---

## 📝 Checklist de Verificación

Antes de compilar, verificar:

- [ ] JDK 17 instalado y configurado
- [ ] `gradle-wrapper.properties` con gradle-8.9-bin.zip
- [ ] `local.properties` con ruta correcta del SDK
- [ ] `capacitor-cordova-android-plugins/build.gradle` con VERSION_17
- [ ] `app/capacitor.build.gradle` con VERSION_17
- [ ] `node_modules/@capacitor/android/capacitor/build.gradle` con VERSION_17
- [ ] `node_modules/@capacitor/camera/android/build.gradle` con VERSION_17 (si aplica)
- [ ] Otros plugins de Capacitor con VERSION_17 (si aplica)
- [ ] `npm run build` ejecutado sin errores
- [ ] `cap copy android` ejecutado correctamente

---

## 🎯 Script de Verificación Rápida

Puedes crear un script para verificar las configuraciones:

**verificar-config.ps1 (Windows PowerShell):**
```powershell
Write-Host "=== Verificando Configuración de Compilación ===" -ForegroundColor Cyan

# Verificar Java
Write-Host "`n1. Verificando Java JDK..." -ForegroundColor Yellow
java -version

# Verificar Gradle Wrapper
Write-Host "`n2. Verificando Gradle Wrapper..." -ForegroundColor Yellow
Get-Content android/gradle/wrapper/gradle-wrapper.properties | Select-String "distributionUrl"

# Verificar local.properties
Write-Host "`n3. Verificando local.properties..." -ForegroundColor Yellow
if (Test-Path android/local.properties) {
    Get-Content android/local.properties | Select-String "sdk.dir"
} else {
    Write-Host "¡ADVERTENCIA! local.properties no existe" -ForegroundColor Red
}

# Verificar compileOptions
Write-Host "`n4. Verificando compileOptions en build.gradle..." -ForegroundColor Yellow
Get-Content android/capacitor-cordova-android-plugins/build.gradle | Select-String "VERSION_17"

Write-Host "`n=== Verificación Completa ===" -ForegroundColor Cyan
```

**verificar-config.sh (Mac/Linux):**
```bash
#!/bin/bash

echo "=== Verificando Configuración de Compilación ==="

# Verificar Java
echo -e "\n1. Verificando Java JDK..."
java -version

# Verificar Gradle Wrapper
echo -e "\n2. Verificando Gradle Wrapper..."
grep "distributionUrl" android/gradle/wrapper/gradle-wrapper.properties

# Verificar local.properties
echo -e "\n3. Verificando local.properties..."
if [ -f android/local.properties ]; then
    grep "sdk.dir" android/local.properties
else
    echo "¡ADVERTENCIA! local.properties no existe"
fi

# Verificar compileOptions
echo -e "\n4. Verificando compileOptions en build.gradle..."
grep "VERSION_17" android/capacitor-cordova-android-plugins/build.gradle

echo -e "\n=== Verificación Completa ==="
```

---

## 🔄 Proceso Completo desde Cero

Si estás empezando un proyecto desde cero o quieres resetear todo:

```bash
# 1. Eliminar node_modules y reinstalar
rm -rf node_modules package-lock.json
npm install

# 2. Eliminar plataforma android y regenerar
npx cap rm android
npx cap add android

# 3. Aplicar todas las configuraciones mencionadas arriba
# (gradle-wrapper.properties, local.properties, build.gradle files)

# 4. Sincronizar
npx cap sync

# 5. Compilar
cd android
./gradlew clean
./gradlew assembleDebug --rerun-tasks
```

---

## 💡 Consejos Adicionales

1. **Variables de Entorno:** Asegurar que `JAVA_HOME` apunte a JDK 17
   ```bash
   # Windows
   $env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
   
   # Mac/Linux
   export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home
   ```

2. **Limpiar Gradle Daemon:** Si tienes problemas persistentes:
   ```bash
   ./gradlew --stop
   rm -rf ~/.gradle/caches/
   ```

3. **Actualizar Capacitor:** Mantener Capacitor actualizado pero estable:
   ```bash
   npm install @capacitor/core@latest @capacitor/cli@latest
   npx cap sync
   ```

4. **Logs Detallados:** Para ver más información durante la compilación:
   ```bash
   ./gradlew assembleDebug --info
   # O para máximo detalle:
   ./gradlew assembleDebug --debug
   ```

---

## 📚 Referencias

- [Documentación de Capacitor](https://capacitorjs.com/docs)
- [Gradle Documentation](https://docs.gradle.org/8.9/userguide/userguide.html)
- [Android Developers Guide](https://developer.android.com/studio/build)

---

## ✅ Resumen de Configuración Exitosa

**Versiones Confirmadas como Funcionales:**
- Java JDK: **17**
- Gradle: **8.9**
- Capacitor: **5.5.1**
- Android SDK: **Actualizado** (compileSdk 33+)

**Archivos Críticos:**
1. `android/gradle/wrapper/gradle-wrapper.properties` → Gradle 8.9
2. `android/local.properties` → Ruta del SDK
3. `android/capacitor-cordova-android-plugins/build.gradle` → Java 17
4. `android/app/capacitor.build.gradle` → Java 17
5. `node_modules/@capacitor/android/capacitor/build.gradle` → Java 17
6. `node_modules/@capacitor/camera/android/build.gradle` → Java 17

**Comandos de Compilación:**
```bash
npm run build
npm exec cap copy android
cd android
./gradlew clean
./gradlew assembleDebug --rerun-tasks
```

---

**Creado el:** 5 de Diciembre, 2025  
**Basado en:** Proyecto Match and Fight (compilación exitosa)  
**Autor:** Guía de compilación automatizada

---

¡Buena suerte con tu compilación! 🚀

