@echo off
chcp 65001 >nul
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║   🔍 COMPILACIÓN LIMPIA - CHRONELIA v3.0 (Escáner QR)    ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Verificar Node.js
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo ❌ Error: Node.js no está instalado
    echo    Descárgalo desde: https://nodejs.org/
    pause
    exit /b 1
)

REM Verificar Java
where java >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo ❌ Error: Java JDK no está instalado
    echo    Descárgalo desde: https://adoptium.net/
    echo    Se requiere JDK 17 o superior
    pause
    exit /b 1
)

echo ✅ Node.js: 
node --version
echo ✅ Java: 
java -version 2>&1 | findstr "version"
echo.

echo ════════════════════════════════════════════════════════════
echo  INICIANDO COMPILACIÓN LIMPIA
echo ════════════════════════════════════════════════════════════
echo.

echo [1/6] 🧹 Limpiando archivos antiguos...
if exist "dist" (
    rmdir /s /q "dist"
    echo    ✓ Eliminado: dist\
)
if exist "android\app\src\main\assets\public" (
    rmdir /s /q "android\app\src\main\assets\public"
    echo    ✓ Eliminado: android\app\src\main\assets\public\
)
echo    ✅ Limpieza completada
echo.

echo [2/6] 🔨 Compilando build web...
echo    Esto puede tardar 10-30 segundos...
call npm run build
if %ERRORLEVEL% neq 0 (
    echo.
    echo    ❌ Error al compilar la aplicación web
    echo    Verifica que no haya errores de sintaxis en el código
    pause
    exit /b 1
)
echo    ✅ Build web compilado exitosamente
echo.

echo [3/6] 🔄 Sincronizando con Android...
call npx cap sync android
if %ERRORLEVEL% neq 0 (
    echo    ⚠️ Hubo advertencias, pero continuaremos...
) else (
    echo    ✅ Sincronización exitosa
)
echo.

echo [4/6] 🔍 Verificando configuración del escáner QR...
findstr /C:"android.permission.CAMERA" android\app\src\main\AndroidManifest.xml >nul
if %ERRORLEVEL% neq 0 (
    echo    ⚠️ Permiso de CAMERA no encontrado en AndroidManifest.xml
) else (
    echo    ✅ Permiso de CAMERA: Configurado
)

findstr /C:"@capacitor-mlkit/barcode-scanning" android\app\src\main\assets\capacitor.config.json >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo    ✅ Plugin ML Kit: Detectado
) else (
    echo    ℹ️ Plugin ML Kit: Se verificará en Android Studio
)
echo.

echo [5/6] 🚀 Abriendo Android Studio...
echo.
echo ════════════════════════════════════════════════════════════
echo  📱 PASOS EN ANDROID STUDIO
echo ════════════════════════════════════════════════════════════
echo.
echo  PASO 1: Esperar sincronización de Gradle
echo          ⏱️ Tiempo estimado: 1-3 minutos
echo          Verás: "Gradle sync in progress..." en la parte inferior
echo.
echo  PASO 2: Compilar APK
echo          📍 Build → Build Bundle(s) / APK(s) → Build APK(s)
echo          ⏱️ Tiempo estimado: 2-5 minutos
echo.
echo  PASO 3: Encontrar el APK
echo          📂 Clic en "locate" cuando aparezca la notificación verde
echo          📍 Ubicación: android\app\build\outputs\apk\debug\app-debug.apk
echo.
echo ════════════════════════════════════════════════════════════
echo.

call npx cap open android
if %ERRORLEVEL% neq 0 (
    echo    ⚠️ No se pudo abrir Android Studio automáticamente
    echo    Ábrelo manualmente y navega a la carpeta 'android'
    pause
)
echo.

echo [6/6] ✅ Proceso completado - Android Studio está abierto
echo.
echo ════════════════════════════════════════════════════════════
echo  🎯 CARACTERÍSTICAS DEL ESCÁNER QR EN ESTA APK
echo ════════════════════════════════════════════════════════════
echo.
echo  ✨ Botón flotante central en panel inferior
echo     • Grande, rosa-púrpura con efecto de pulso
echo     • Siempre visible y fácil de acceder
echo.
echo  ✨ Modal del escáner mejorado
echo     • Animaciones suaves con Framer Motion
echo     • Cámara nativa de Android (ML Kit)
echo     • Detección automática y rápida
echo.
echo  ✨ Página completa en /scan
echo     • 3 métodos de escaneo disponibles
echo     • Panel de debug con logs
echo     • Botón de prueba sin QR real
echo.
echo ════════════════════════════════════════════════════════════
echo  📋 CÓMO PROBAR EN EL MÓVIL
echo ════════════════════════════════════════════════════════════
echo.
echo  1. Instala la APK en tu móvil Android
echo  2. Abre la app Chronelia
echo  3. Presiona el botón central "Escanear"
echo  4. Permite permisos de cámara (primera vez)
echo  5. Apunta al código QR o usa "Crear Reserva de Prueba"
echo  6. ¡La reserva se creará automáticamente!
echo.
echo ════════════════════════════════════════════════════════════
echo  📚 DOCUMENTACIÓN ADICIONAL
echo ════════════════════════════════════════════════════════════
echo.
echo  • Instrucciones_Compilacion\PASOS_EN_ANDROID_STUDIO.txt
echo  • Instrucciones_Compilacion\VERIFICACION_RAPIDA.md
echo  • Instrucciones_Compilacion\SOLUCION_ESCANER_QR_DEFINITIVA.md
echo  • COMPILAR_APK_PASO_A_PASO.md (guía detallada paso a paso)
echo.
echo ════════════════════════════════════════════════════════════
pause

