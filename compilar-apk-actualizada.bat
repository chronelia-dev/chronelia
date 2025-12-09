@echo off
echo ================================================
echo COMPILAR APK ACTUALIZADA - CHRONELIA
echo ================================================
echo.

echo [1/5] Limpiando builds antiguos...
if exist dist rmdir /s /q dist
if exist android\app\build rmdir /s /q android\app\build
echo     Limpio!

echo.
echo [2/5] Compilando proyecto web...
call npm run build
if errorlevel 1 (
    echo ERROR: Falló la compilación web
    pause
    exit /b 1
)
echo     Web compilado!

echo.
echo [3/5] Copiando assets a Android...
xcopy /E /I /Y dist\*.* android\app\src\main\assets\public\
echo     Assets copiados!

echo.
echo [4/5] Sincronizando Capacitor...
call npx cap sync android --no-build
echo     Capacitor sincronizado!

echo.
echo [5/5] Compilando APK con Gradle...
cd android
call gradlew.bat assembleRelease
if errorlevel 1 (
    echo ERROR: Falló la compilación de la APK
    cd ..
    pause
    exit /b 1
)
cd ..

echo.
echo ================================================
echo APK COMPILADA EXITOSAMENTE!
echo ================================================
echo.
echo Ubicación: android\app\build\outputs\apk\release\app-release.apk
echo.
echo Renombrando APK...
copy android\app\build\outputs\apk\release\app-release.apk chronelia-v3.0-produccion.apk
echo.
echo APK LISTA: chronelia-v3.0-produccion.apk
echo.
pause



