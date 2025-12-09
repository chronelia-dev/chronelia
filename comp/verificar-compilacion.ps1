# Script de Verificación de Configuración para Compilación de APK
# Para ejecutar: .\verificar-compilacion.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VERIFICADOR DE COMPILACIÓN APK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$errores = 0
$advertencias = 0

# 1. Verificar Java JDK
Write-Host "`n[1/8] Verificando Java JDK 17..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1
    $javaVersionString = $javaVersion[0]
    
    if ($javaVersionString -match "17\.") {
        Write-Host "  ✓ Java 17 detectado correctamente" -ForegroundColor Green
        Write-Host "  $javaVersionString" -ForegroundColor Gray
    } else {
        Write-Host "  ✗ ADVERTENCIA: No se detectó Java 17" -ForegroundColor Red
        Write-Host "  Versión actual: $javaVersionString" -ForegroundColor Gray
        Write-Host "  Se requiere JDK 17 para compilar correctamente" -ForegroundColor Red
        $errores++
    }
} catch {
    Write-Host "  ✗ ERROR: Java no encontrado en el PATH" -ForegroundColor Red
    $errores++
}

# 2. Verificar Gradle Wrapper
Write-Host "`n[2/8] Verificando Gradle Wrapper (8.9)..." -ForegroundColor Yellow
$gradleWrapperPath = "android/gradle/wrapper/gradle-wrapper.properties"
if (Test-Path $gradleWrapperPath) {
    $gradleContent = Get-Content $gradleWrapperPath
    $gradleUrl = $gradleContent | Select-String "distributionUrl"
    
    if ($gradleUrl -match "gradle-8.9") {
        Write-Host "  ✓ Gradle 8.9 configurado correctamente" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ADVERTENCIA: Gradle no es versión 8.9" -ForegroundColor Red
        Write-Host "  Actual: $gradleUrl" -ForegroundColor Gray
        Write-Host "  Requerido: gradle-8.9-bin.zip" -ForegroundColor Red
        $errores++
    }
} else {
    Write-Host "  ✗ ERROR: No se encontró $gradleWrapperPath" -ForegroundColor Red
    $errores++
}

# 3. Verificar local.properties
Write-Host "`n[3/8] Verificando local.properties..." -ForegroundColor Yellow
$localPropertiesPath = "android/local.properties"
if (Test-Path $localPropertiesPath) {
    $localProps = Get-Content $localPropertiesPath
    $sdkDir = $localProps | Select-String "sdk.dir"
    
    if ($sdkDir) {
        Write-Host "  ✓ local.properties existe" -ForegroundColor Green
        Write-Host "  $sdkDir" -ForegroundColor Gray
        
        # Verificar si la ruta del SDK existe
        $sdkPath = ($sdkDir -split "=")[1].Trim().Replace("\\", "\")
        if (Test-Path $sdkPath) {
            Write-Host "  ✓ SDK directory encontrado" -ForegroundColor Green
        } else {
            Write-Host "  ✗ ADVERTENCIA: La ruta del SDK no existe" -ForegroundColor Yellow
            $advertencias++
        }
    } else {
        Write-Host "  ✗ ERROR: sdk.dir no está definido en local.properties" -ForegroundColor Red
        $errores++
    }
} else {
    Write-Host "  ✗ ERROR: local.properties no existe" -ForegroundColor Red
    Write-Host "  Crear archivo en: $localPropertiesPath" -ForegroundColor Red
    Write-Host "  Contenido ejemplo: sdk.dir=C:\\Users\\TuUsuario\\AppData\\Local\\Android\\Sdk" -ForegroundColor Gray
    $errores++
}

# 4. Verificar capacitor-cordova-android-plugins/build.gradle
Write-Host "`n[4/8] Verificando capacitor-cordova-android-plugins/build.gradle..." -ForegroundColor Yellow
$cordovaPluginGradlePath = "android/capacitor-cordova-android-plugins/build.gradle"
if (Test-Path $cordovaPluginGradlePath) {
    $cordovaContent = Get-Content $cordovaPluginGradlePath -Raw
    if ($cordovaContent -match "JavaVersion\.VERSION_17") {
        Write-Host "  ✓ VERSION_17 configurado" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ERROR: No se encontró VERSION_17" -ForegroundColor Red
        Write-Host "  Buscar 'compileOptions' y cambiar a VERSION_17" -ForegroundColor Red
        $errores++
    }
} else {
    Write-Host "  ✗ ERROR: Archivo no encontrado" -ForegroundColor Red
    $errores++
}

# 5. Verificar app/capacitor.build.gradle
Write-Host "`n[5/8] Verificando app/capacitor.build.gradle..." -ForegroundColor Yellow
$appCapGradlePath = "android/app/capacitor.build.gradle"
if (Test-Path $appCapGradlePath) {
    $appCapContent = Get-Content $appCapGradlePath -Raw
    if ($appCapContent -match "JavaVersion\.VERSION_17") {
        Write-Host "  ✓ VERSION_17 configurado" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ERROR: No se encontró VERSION_17" -ForegroundColor Red
        Write-Host "  Buscar 'compileOptions' y cambiar a VERSION_17" -ForegroundColor Red
        $errores++
    }
} else {
    Write-Host "  ✗ ERROR: Archivo no encontrado" -ForegroundColor Red
    $errores++
}

# 6. Verificar node_modules/@capacitor/android
Write-Host "`n[6/8] Verificando @capacitor/android/build.gradle..." -ForegroundColor Yellow
$capAndroidGradlePath = "node_modules/@capacitor/android/capacitor/build.gradle"
if (Test-Path $capAndroidGradlePath) {
    $capAndroidContent = Get-Content $capAndroidGradlePath -Raw
    if ($capAndroidContent -match "JavaVersion\.VERSION_17") {
        Write-Host "  ✓ VERSION_17 configurado" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ADVERTENCIA: No se encontró VERSION_17" -ForegroundColor Yellow
        Write-Host "  Este archivo se regenera con npm install" -ForegroundColor Gray
        $advertencias++
    }
} else {
    Write-Host "  ⊘ Archivo no encontrado (puede que no tengas Capacitor instalado)" -ForegroundColor Gray
}

# 7. Verificar node_modules/@capacitor/camera
Write-Host "`n[7/8] Verificando @capacitor/camera/build.gradle..." -ForegroundColor Yellow
$capCameraGradlePath = "node_modules/@capacitor/camera/android/build.gradle"
if (Test-Path $capCameraGradlePath) {
    $capCameraContent = Get-Content $capCameraGradlePath -Raw
    if ($capCameraContent -match "JavaVersion\.VERSION_17") {
        Write-Host "  ✓ VERSION_17 configurado" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ADVERTENCIA: No se encontró VERSION_17" -ForegroundColor Yellow
        Write-Host "  Este archivo se regenera con npm install" -ForegroundColor Gray
        $advertencias++
    }
} else {
    Write-Host "  ⊘ Plugin de cámara no instalado (opcional)" -ForegroundColor Gray
}

# 8. Verificar estructura de directorios
Write-Host "`n[8/8] Verificando estructura de directorios..." -ForegroundColor Yellow
$directoriosRequeridos = @(
    "android",
    "android/app",
    "android/gradle",
    "src"
)

$faltantes = @()
foreach ($dir in $directoriosRequeridos) {
    if (-not (Test-Path $dir)) {
        $faltantes += $dir
    }
}

if ($faltantes.Count -eq 0) {
    Write-Host "  ✓ Estructura de directorios correcta" -ForegroundColor Green
} else {
    Write-Host "  ✗ ADVERTENCIA: Faltan directorios:" -ForegroundColor Yellow
    foreach ($dir in $faltantes) {
        Write-Host "    - $dir" -ForegroundColor Gray
    }
    $advertencias++
}

# Resumen
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "           RESUMEN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($errores -eq 0 -and $advertencias -eq 0) {
    Write-Host "`n✓ TODO CORRECTO - Listo para compilar!" -ForegroundColor Green
    Write-Host "`nComandos para compilar:" -ForegroundColor Cyan
    Write-Host "  npm.cmd run build" -ForegroundColor White
    Write-Host "  npm.cmd exec cap copy android" -ForegroundColor White
    Write-Host "  cd android" -ForegroundColor White
    Write-Host "  .\gradlew clean" -ForegroundColor White
    Write-Host "  .\gradlew assembleDebug --rerun-tasks" -ForegroundColor White
} else {
    Write-Host "`n⚠ Se encontraron problemas:" -ForegroundColor Yellow
    Write-Host "  Errores críticos: $errores" -ForegroundColor Red
    Write-Host "  Advertencias: $advertencias" -ForegroundColor Yellow
    Write-Host "`nRevisa la guía GUIA_COMPILACION_APK.md para más detalles" -ForegroundColor Cyan
}

Write-Host "`n========================================`n" -ForegroundColor Cyan

# Pausar para ver resultados
Read-Host -Prompt "Presiona Enter para salir"

