@echo off
REM ============================================
REM CHRONELIA - COMPILACION DIRECTA APK
REM ============================================
REM Script optimizado que funciona en PowerShell
REM Usa cmd /c para evitar problemas de ejecucion

echo.
echo ========================================
echo   CHRONELIA - COMPILACION APK
echo ========================================
echo.

REM ============================================
REM PASO 1: BUILD WEB
REM ============================================
echo [1/3] Compilando web...
cmd /c "npm run build"
if %errorlevel% neq 0 (
    echo ERROR: Fallo al compilar web
    pause
    exit /b 1
)
echo [OK] Web compilada correctamente
echo.

REM ============================================
REM PASO 2: SYNC CAPACITOR
REM ============================================
echo [2/3] Sincronizando con Android...
cmd /c "npx cap sync android"
if %errorlevel% neq 0 (
    echo ERROR: Fallo al sincronizar
    pause
    exit /b 1
)
echo [OK] Sincronizacion completa
echo.

REM ============================================
REM PASO 3: COMPILAR APK
REM ============================================
echo [3/3] Compilando APK...
cd android
.\gradlew assembleDebug
if %errorlevel% neq 0 (
    echo ERROR: Fallo al compilar APK
    cd ..
    pause
    exit /b 1
)
cd ..
echo [OK] APK compilada correctamente
echo.

REM ============================================
REM RESULTADO
REM ============================================
echo ========================================
echo   COMPILACION EXITOSA
echo ========================================
echo.
echo APK ubicada en:
echo android\app\build\outputs\apk\debug\app-debug.apk
echo.
echo Pasos siguientes:
echo 1. Desinstala la app vieja del dispositivo
echo 2. Instala el nuevo APK
echo 3. Prueba con: admin / admin123
echo.
pause




