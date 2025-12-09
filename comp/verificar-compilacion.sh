#!/bin/bash

# Script de Verificación de Configuración para Compilación de APK
# Para ejecutar: chmod +x verificar-compilacion.sh && ./verificar-compilacion.sh

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

errores=0
advertencias=0

echo -e "${CYAN}========================================"
echo -e "  VERIFICADOR DE COMPILACIÓN APK"
echo -e "========================================${NC}"

# 1. Verificar Java JDK
echo -e "\n${YELLOW}[1/8] Verificando Java JDK 17...${NC}"
if command -v java &> /dev/null; then
    java_version=$(java -version 2>&1 | head -n 1)
    
    if [[ $java_version == *"17."* ]]; then
        echo -e "  ${GREEN}✓ Java 17 detectado correctamente${NC}"
        echo -e "  ${GRAY}$java_version${NC}"
    else
        echo -e "  ${RED}✗ ADVERTENCIA: No se detectó Java 17${NC}"
        echo -e "  ${GRAY}Versión actual: $java_version${NC}"
        echo -e "  ${RED}Se requiere JDK 17 para compilar correctamente${NC}"
        ((errores++))
    fi
else
    echo -e "  ${RED}✗ ERROR: Java no encontrado en el PATH${NC}"
    ((errores++))
fi

# 2. Verificar Gradle Wrapper
echo -e "\n${YELLOW}[2/8] Verificando Gradle Wrapper (8.9)...${NC}"
gradle_wrapper_path="android/gradle/wrapper/gradle-wrapper.properties"
if [ -f "$gradle_wrapper_path" ]; then
    gradle_url=$(grep "distributionUrl" "$gradle_wrapper_path")
    
    if [[ $gradle_url == *"gradle-8.9"* ]]; then
        echo -e "  ${GREEN}✓ Gradle 8.9 configurado correctamente${NC}"
    else
        echo -e "  ${RED}✗ ADVERTENCIA: Gradle no es versión 8.9${NC}"
        echo -e "  ${GRAY}Actual: $gradle_url${NC}"
        echo -e "  ${RED}Requerido: gradle-8.9-bin.zip${NC}"
        ((errores++))
    fi
else
    echo -e "  ${RED}✗ ERROR: No se encontró $gradle_wrapper_path${NC}"
    ((errores++))
fi

# 3. Verificar local.properties
echo -e "\n${YELLOW}[3/8] Verificando local.properties...${NC}"
local_properties_path="android/local.properties"
if [ -f "$local_properties_path" ]; then
    sdk_dir=$(grep "sdk.dir" "$local_properties_path")
    
    if [ ! -z "$sdk_dir" ]; then
        echo -e "  ${GREEN}✓ local.properties existe${NC}"
        echo -e "  ${GRAY}$sdk_dir${NC}"
        
        # Verificar si la ruta del SDK existe
        sdk_path=$(echo "$sdk_dir" | cut -d'=' -f2 | tr -d ' ')
        if [ -d "$sdk_path" ]; then
            echo -e "  ${GREEN}✓ SDK directory encontrado${NC}"
        else
            echo -e "  ${YELLOW}✗ ADVERTENCIA: La ruta del SDK no existe${NC}"
            ((advertencias++))
        fi
    else
        echo -e "  ${RED}✗ ERROR: sdk.dir no está definido en local.properties${NC}"
        ((errores++))
    fi
else
    echo -e "  ${RED}✗ ERROR: local.properties no existe${NC}"
    echo -e "  ${RED}Crear archivo en: $local_properties_path${NC}"
    echo -e "  ${GRAY}Contenido ejemplo: sdk.dir=/Users/TuUsuario/Library/Android/sdk${NC}"
    ((errores++))
fi

# 4. Verificar capacitor-cordova-android-plugins/build.gradle
echo -e "\n${YELLOW}[4/8] Verificando capacitor-cordova-android-plugins/build.gradle...${NC}"
cordova_plugin_gradle_path="android/capacitor-cordova-android-plugins/build.gradle"
if [ -f "$cordova_plugin_gradle_path" ]; then
    if grep -q "JavaVersion.VERSION_17" "$cordova_plugin_gradle_path"; then
        echo -e "  ${GREEN}✓ VERSION_17 configurado${NC}"
    else
        echo -e "  ${RED}✗ ERROR: No se encontró VERSION_17${NC}"
        echo -e "  ${RED}Buscar 'compileOptions' y cambiar a VERSION_17${NC}"
        ((errores++))
    fi
else
    echo -e "  ${RED}✗ ERROR: Archivo no encontrado${NC}"
    ((errores++))
fi

# 5. Verificar app/capacitor.build.gradle
echo -e "\n${YELLOW}[5/8] Verificando app/capacitor.build.gradle...${NC}"
app_cap_gradle_path="android/app/capacitor.build.gradle"
if [ -f "$app_cap_gradle_path" ]; then
    if grep -q "JavaVersion.VERSION_17" "$app_cap_gradle_path"; then
        echo -e "  ${GREEN}✓ VERSION_17 configurado${NC}"
    else
        echo -e "  ${RED}✗ ERROR: No se encontró VERSION_17${NC}"
        echo -e "  ${RED}Buscar 'compileOptions' y cambiar a VERSION_17${NC}"
        ((errores++))
    fi
else
    echo -e "  ${RED}✗ ERROR: Archivo no encontrado${NC}"
    ((errores++))
fi

# 6. Verificar node_modules/@capacitor/android
echo -e "\n${YELLOW}[6/8] Verificando @capacitor/android/build.gradle...${NC}"
cap_android_gradle_path="node_modules/@capacitor/android/capacitor/build.gradle"
if [ -f "$cap_android_gradle_path" ]; then
    if grep -q "JavaVersion.VERSION_17" "$cap_android_gradle_path"; then
        echo -e "  ${GREEN}✓ VERSION_17 configurado${NC}"
    else
        echo -e "  ${YELLOW}✗ ADVERTENCIA: No se encontró VERSION_17${NC}"
        echo -e "  ${GRAY}Este archivo se regenera con npm install${NC}"
        ((advertencias++))
    fi
else
    echo -e "  ${GRAY}⊘ Archivo no encontrado (puede que no tengas Capacitor instalado)${NC}"
fi

# 7. Verificar node_modules/@capacitor/camera
echo -e "\n${YELLOW}[7/8] Verificando @capacitor/camera/build.gradle...${NC}"
cap_camera_gradle_path="node_modules/@capacitor/camera/android/build.gradle"
if [ -f "$cap_camera_gradle_path" ]; then
    if grep -q "JavaVersion.VERSION_17" "$cap_camera_gradle_path"; then
        echo -e "  ${GREEN}✓ VERSION_17 configurado${NC}"
    else
        echo -e "  ${YELLOW}✗ ADVERTENCIA: No se encontró VERSION_17${NC}"
        echo -e "  ${GRAY}Este archivo se regenera con npm install${NC}"
        ((advertencias++))
    fi
else
    echo -e "  ${GRAY}⊘ Plugin de cámara no instalado (opcional)${NC}"
fi

# 8. Verificar estructura de directorios
echo -e "\n${YELLOW}[8/8] Verificando estructura de directorios...${NC}"
directorios_requeridos=(
    "android"
    "android/app"
    "android/gradle"
    "src"
)

faltantes=()
for dir in "${directorios_requeridos[@]}"; do
    if [ ! -d "$dir" ]; then
        faltantes+=("$dir")
    fi
done

if [ ${#faltantes[@]} -eq 0 ]; then
    echo -e "  ${GREEN}✓ Estructura de directorios correcta${NC}"
else
    echo -e "  ${YELLOW}✗ ADVERTENCIA: Faltan directorios:${NC}"
    for dir in "${faltantes[@]}"; do
        echo -e "    ${GRAY}- $dir${NC}"
    done
    ((advertencias++))
fi

# Resumen
echo -e "\n${CYAN}========================================"
echo -e "           RESUMEN"
echo -e "========================================${NC}"

if [ $errores -eq 0 ] && [ $advertencias -eq 0 ]; then
    echo -e "\n${GREEN}✓ TODO CORRECTO - Listo para compilar!${NC}"
    echo -e "\n${CYAN}Comandos para compilar:${NC}"
    echo -e "  ${NC}npm run build${NC}"
    echo -e "  ${NC}npm exec cap copy android${NC}"
    echo -e "  ${NC}cd android${NC}"
    echo -e "  ${NC}./gradlew clean${NC}"
    echo -e "  ${NC}./gradlew assembleDebug --rerun-tasks${NC}"
else
    echo -e "\n${YELLOW}⚠ Se encontraron problemas:${NC}"
    echo -e "  ${RED}Errores críticos: $errores${NC}"
    echo -e "  ${YELLOW}Advertencias: $advertencias${NC}"
    echo -e "\n${CYAN}Revisa la guía GUIA_COMPILACION_APK.md para más detalles${NC}"
fi

echo -e "\n${CYAN}========================================${NC}\n"

