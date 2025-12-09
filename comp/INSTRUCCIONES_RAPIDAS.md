# 🚀 Instrucciones Rápidas - Compilación de APK

## 📋 Archivos Incluidos

1. **GUIA_COMPILACION_APK.md** - Guía completa paso a paso
2. **verificar-compilacion.ps1** - Script de verificación para Windows
3. **verificar-compilacion.sh** - Script de verificación para Mac/Linux
4. **INSTRUCCIONES_RAPIDAS.md** - Este archivo

---

## ⚡ Inicio Rápido

### Para Windows (PowerShell)

1. **Copiar archivos al otro proyecto:**
   ```powershell
   # Copiar estos 3 archivos a la raíz de tu otro proyecto:
   # - GUIA_COMPILACION_APK.md
   # - verificar-compilacion.ps1
   # - INSTRUCCIONES_RAPIDAS.md
   ```

2. **Ejecutar el verificador:**
   ```powershell
   cd tu-otro-proyecto
   .\verificar-compilacion.ps1
   ```

3. **Seguir las correcciones sugeridas** por el script

4. **Compilar:**
   ```powershell
   npm.cmd run build
   npm.cmd exec cap copy android
   cd android
   .\gradlew clean
   .\gradlew assembleDebug --rerun-tasks
   ```

### Para Mac/Linux (Terminal)

1. **Copiar archivos al otro proyecto:**
   ```bash
   # Copiar estos 3 archivos a la raíz de tu otro proyecto:
   # - GUIA_COMPILACION_APK.md
   # - verificar-compilacion.sh
   # - INSTRUCCIONES_RAPIDAS.md
   ```

2. **Dar permisos de ejecución:**
   ```bash
   cd tu-otro-proyecto
   chmod +x verificar-compilacion.sh
   ```

3. **Ejecutar el verificador:**
   ```bash
   ./verificar-compilacion.sh
   ```

4. **Seguir las correcciones sugeridas** por el script

5. **Compilar:**
   ```bash
   npm run build
   npm exec cap copy android
   cd android
   ./gradlew clean
   ./gradlew assembleDebug --rerun-tasks
   ```

---

## 🔧 Configuraciones Críticas

### 1. Instalar JDK 17
**¡EL MÁS IMPORTANTE!**

- Descargar: https://adoptium.net/temurin/releases/?version=17
- NO usar JDK 21 o superior

### 2. Archivo: `android/gradle/wrapper/gradle-wrapper.properties`
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-bin.zip
```

### 3. Archivo: `android/local.properties`
```properties
# Windows:
sdk.dir=C:\\Users\\TuUsuario\\AppData\\Local\\Android\\Sdk

# Mac:
sdk.dir=/Users/TuUsuario/Library/Android/sdk

# Linux:
sdk.dir=/home/TuUsuario/Android/Sdk
```

### 4. Archivo: `android/capacitor-cordova-android-plugins/build.gradle`
```gradle
compileOptions {
    sourceCompatibility JavaVersion.VERSION_17
    targetCompatibility JavaVersion.VERSION_17
}
```

### 5. Archivo: `android/app/capacitor.build.gradle`
```gradle
android {
  compileOptions {
      sourceCompatibility JavaVersion.VERSION_17
      targetCompatibility JavaVersion.VERSION_17
  }
}
```

### 6. Archivos en `node_modules/@capacitor/*/android/build.gradle`
Buscar todos los `build.gradle` en node_modules y cambiar a `VERSION_17`:
- `node_modules/@capacitor/android/capacitor/build.gradle`
- `node_modules/@capacitor/camera/android/build.gradle`
- Cualquier otro plugin de Capacitor que tengas instalado

---

## 🐛 Problemas Comunes y Soluciones

### ❌ Error: "Unsupported class file major version"
**Solución:**
1. Verificar que Java 17 esté instalado: `java -version`
2. Cambiar todos los `JavaVersion.VERSION_XX` a `VERSION_17` en los archivos build.gradle

### ❌ Error: "SDK location not found"
**Solución:**
1. Crear/editar `android/local.properties`
2. Agregar la ruta correcta del Android SDK

### ❌ Error: PowerShell no ejecuta npm
**Solución:**
- Usar `npm.cmd` en lugar de `npm`
- Ejemplo: `npm.cmd run build`

### ❌ Los cambios no aparecen en la APK
**Solución:**
1. Ejecutar `.\gradlew clean` antes de compilar
2. Usar el flag `--rerun-tasks` con assembleDebug
3. Verificar que ejecutaste `npm exec cap copy android`

---

## 📦 Ubicación de la APK

Después de compilar exitosamente, encontrarás la APK en:

```
android/app/build/outputs/apk/debug/
```

El archivo se llamará algo como:
- `app-debug.apk`
- `[NombreApp]-v[version]-[fecha]-debug.apk`

---

## ✅ Checklist Antes de Compilar

- [ ] JDK 17 instalado (`java -version`)
- [ ] Gradle 8.9 configurado en `gradle-wrapper.properties`
- [ ] `local.properties` con ruta correcta del SDK
- [ ] Todos los `build.gradle` con `VERSION_17`
- [ ] Script verificador ejecutado sin errores críticos
- [ ] `npm run build` ejecutado sin errores
- [ ] `cap copy android` ejecutado correctamente

---

## 📞 Flujo de Trabajo Recomendado

```
1. Copiar archivos de guía → Tu otro proyecto
2. Ejecutar script verificador → Revisar errores
3. Corregir configuraciones → Según reporte del script
4. Volver a ejecutar verificador → Confirmar que todo está OK
5. Compilar proyecto web → npm run build
6. Copiar a Android → cap copy android
7. Limpiar Gradle → ./gradlew clean
8. Compilar APK → ./gradlew assembleDebug --rerun-tasks
9. Instalar en dispositivo → Probar la app
```

---

## 💡 Consejos Finales

1. **Siempre ejecuta el verificador primero** antes de intentar compilar
2. **Lee los errores del Gradle** - son muy descriptivos
3. **Si todo falla**, borra `node_modules`, reinstala y vuelve a aplicar las configuraciones
4. **Documenta cambios** que hagas específicos para tu proyecto
5. **Guarda esta configuración** una vez que funcione

---

## 📚 Recursos Adicionales

- **Guía Completa:** Lee `GUIA_COMPILACION_APK.md` para detalles exhaustivos
- **Capacitor Docs:** https://capacitorjs.com/docs
- **Gradle Docs:** https://docs.gradle.org/8.9/userguide/userguide.html

---

**¡Buena suerte con tu compilación!** 🎉

Si el script verificador muestra todo en verde, deberías poder compilar sin problemas.

