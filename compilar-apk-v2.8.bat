@echo off
chcp 65001 >nul
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║   📱 COMPILAR APK v2.8 - CON SISTEMA DE TEMAS 📱        ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo 🎨 Esta versión incluye:
echo    - Sistema de temas intercambiables
echo    - Tema Base44 (naranja vibrante)
echo    - Logo con colores, texto adaptativo
echo    - Mejoras visuales generales
echo.
pause

echo.
echo ════════════════════════════════════════════════════════════
echo  [1/4] Compilando aplicación web para móvil...
echo ════════════════════════════════════════════════════════════
call npm run build
if %ERRORLEVEL% neq 0 (
    echo ❌ Error al compilar la aplicación web
    pause
    exit /b 1
)

echo.
echo ════════════════════════════════════════════════════════════
echo  [2/4] Sincronizando con Android...
echo ════════════════════════════════════════════════════════════
call npx cap sync android
if %ERRORLEVEL% neq 0 (
    echo ⚠️ Advertencia: Hubo errores en la sincronización
)

echo.
echo ════════════════════════════════════════════════════════════
echo  [3/4] Construyendo APK...
echo ════════════════════════════════════════════════════════════
cd android
call gradlew assembleDebug
if %ERRORLEVEL% neq 0 (
    echo ❌ Error al compilar el APK
    echo.
    echo 💡 Alternativa: Abrir Android Studio
    echo    Ejecuta: npx cap open android
    echo    Luego: Build → Build Bundle(s) / APK(s) → Build APK(s)
    cd ..
    pause
    exit /b 1
)
cd ..

echo.
echo ════════════════════════════════════════════════════════════
echo  [4/4] Copiando APK al directorio raíz...
echo ════════════════════════════════════════════════════════════

if exist "android\app\build\outputs\apk\debug\app-debug.apk" (
    copy "android\app\build\outputs\apk\debug\app-debug.apk" "chronelia-v2.8-TEMAS.apk"
    echo.
    echo ✅ ¡APK COMPILADO EXITOSAMENTE!
    echo.
    echo 📦 Archivo creado: chronelia-v2.8-TEMAS.apk
    echo 📍 Ubicación: %CD%\chronelia-v2.8-TEMAS.apk
    echo.
    echo 📱 Para instalar:
    echo    1. Transfiere el APK a tu dispositivo Android
    echo    2. Habilita "Instalar aplicaciones de orígenes desconocidos"
    echo    3. Abre el APK y selecciona "Instalar"
    echo.
) else (
    echo ❌ No se encontró el APK compilado
    echo.
    echo 💡 Intenta compilar manualmente con Android Studio:
    echo    1. Ejecuta: npx cap open android
    echo    2. Build → Build Bundle(s) / APK(s) → Build APK(s)
    echo    3. El APK estará en: android\app\build\outputs\apk\debug\
)

echo.
echo ════════════════════════════════════════════════════════════
pause











