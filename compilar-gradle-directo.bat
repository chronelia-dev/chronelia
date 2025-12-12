@echo off
chcp 65001 >nul
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║   🔨 COMPILACIÓN DIRECTA CON GRADLE                       ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

echo [1/2] Configurando entorno...
echo ✓ Usando Java del sistema (versión 17.0.12)
echo.

echo [2/2] Compilando APK con Gradle...
echo ⏳ Esto puede tardar 2-5 minutos...
echo.

cd android
call gradlew.bat assembleDebug --no-daemon --warning-mode=none

if %ERRORLEVEL% equ 0 (
    echo.
    echo ════════════════════════════════════════════════════════════
    echo  ✅ COMPILACIÓN EXITOSA
    echo ════════════════════════════════════════════════════════════
    echo.
    echo 📱 Tu APK está lista en:
    echo    android\app\build\outputs\apk\debug\app-debug.apk
    echo.
    echo 📦 Tamaño aprox: 10-15 MB
    echo.
    echo 🎯 Escáner QR incluido:
    echo    • Abre directamente sin ventanas intermedias
    echo    • Usa ML Kit (escáner nativo Android)
    echo    • Botón flotante en panel inferior
    echo.
    start "" "app\build\outputs\apk\debug\"
) else (
    echo.
    echo ════════════════════════════════════════════════════════════
    echo  ❌ ERROR EN LA COMPILACIÓN
    echo ════════════════════════════════════════════════════════════
    echo.
    echo Posibles soluciones:
    echo  1. Abrir Android Studio y compilar desde ahí
    echo  2. Verificar que Java 17 esté instalado
    echo  3. Ejecutar: gradlew.bat clean
    echo.
)

cd ..
echo.
pause








