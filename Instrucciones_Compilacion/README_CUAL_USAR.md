# 📱 Guía: ¿Qué Script de Compilación Usar?

**Fecha:** 5 de Diciembre 2025  
**Proyecto:** Chronelia v3.0 con Escáner QR

---

## 🎯 Scripts Disponibles

Tienes **2 scripts principales** para compilar tu APK. Aquí te explico cuál usar según tu situación:

---

## 📋 Comparación Rápida

| Característica | compilar-apk-limpio.bat | compilar-apk.bat |
|----------------|------------------------|------------------|
| **Propósito** | Compilación limpia desde cero | Compilación normal con opciones |
| **Cuándo usar** | Primera vez o después de cambios importantes | Compilaciones rutinarias |
| **Limpia caché** | ✅ Sí, automáticamente | ⚠️ Solo si eliges opción 4 |
| **Velocidad** | Más lento (compilación fresca) | Más rápido (usa caché) |
| **Menú** | ❌ No, proceso directo | ✅ Sí, con 5 opciones |
| **Verifica permisos** | ✅ Sí, automático | ❌ No |
| **Escáner QR** | ✅ Optimizado para QR | ⚠️ Genérico |

---

## 🔍 compilar-apk-limpio.bat

### ✅ Úsalo cuando:

1. **Primera vez** que compilas después de clonar el proyecto
2. Hiciste **cambios importantes** en el código del escáner QR
3. La APK anterior tiene **problemas** o no funciona
4. Quieres **asegurarte** de que todo está actualizado
5. El escáner QR **no funciona** en la APK actual

### 📝 Lo que hace:

```
1. Verifica Node.js y Java
2. ✨ LIMPIA todos los archivos antiguos
3. Compila build web desde cero
4. Sincroniza con Android
5. ✅ Verifica permisos del escáner QR
6. Abre Android Studio
7. Muestra instrucciones específicas del escáner QR
```

### 🚀 Cómo usarlo:

```bash
# Opción 1: Doble clic en el archivo
compilar-apk-limpio.bat

# Opción 2: Desde terminal
cd "D:\1TB\Nueva carpeta\Proyectos\Osvaldo\Chronelia\App"
compilar-apk-limpio.bat
```

### ⏱️ Tiempo estimado:
- **Primera vez**: 10-20 minutos
- **Siguientes veces**: 5-10 minutos

---

## 🛠️ compilar-apk.bat

### ✅ Úsalo cuando:

1. Ya compilaste antes y todo funciona
2. Hiciste **cambios pequeños** en la UI o estilos
3. Solo quieres **actualizar** la APK rápidamente
4. Conoces el proceso y quieres **más control**
5. Necesitas acceder a **opciones específicas**

### 📝 Lo que hace:

```
Menú con 5 opciones:
1. Compilar APK Debug (normal)
2. Solo abrir Android Studio
3. Solo compilar web + sincronizar
4. Limpiar y recompilar todo (como limpio.bat)
5. Salir
```

### 🚀 Cómo usarlo:

```bash
# Opción 1: Doble clic en el archivo
compilar-apk.bat

# Opción 2: Desde terminal
cd "D:\1TB\Nueva carpeta\Proyectos\Osvaldo\Chronelia\App"
compilar-apk.bat

# Luego selecciona una opción (1-5)
```

### ⏱️ Tiempo estimado:
- **Opción 1**: 3-5 minutos
- **Opción 3**: 30-60 segundos
- **Opción 4**: 10-20 minutos

---

## 🎯 Recomendación según tu Situación

### 🆕 Primera vez compilando
```
👉 Usa: compilar-apk-limpio.bat
```
Razón: Asegura que todo esté limpio y configurado correctamente desde cero.

### 🔍 Cambios en el Escáner QR
```
👉 Usa: compilar-apk-limpio.bat
```
Razón: Garantiza que todos los cambios del escáner se incluyan correctamente.

### 🎨 Cambios en UI/CSS
```
👉 Usa: compilar-apk.bat → Opción 1
```
Razón: Los cambios de UI no requieren limpieza completa.

### 🐛 APK no funciona correctamente
```
👉 Usa: compilar-apk-limpio.bat
```
Razón: Elimina posibles problemas de caché o archivos corruptos.

### ⚡ Compilación rápida
```
👉 Usa: compilar-apk.bat → Opción 3, luego Android Studio
```
Razón: Solo sincroniza sin abrir Android Studio automáticamente.

### 🧹 Problemas con dependencias
```
👉 Usa: compilar-apk.bat → Opción 4
```
Razón: Reinstala todas las dependencias desde cero.

---

## 📊 Diagrama de Decisión

```
¿Primera vez compilando?
├─ Sí → compilar-apk-limpio.bat
└─ No → ¿Cambios importantes en QR?
         ├─ Sí → compilar-apk-limpio.bat
         └─ No → ¿Problemas con APK anterior?
                  ├─ Sí → compilar-apk-limpio.bat
                  └─ No → compilar-apk.bat (Opción 1)
```

---

## 🆘 Problemas Comunes

### La APK no tiene los últimos cambios
```bash
# Solución:
1. Ejecuta: compilar-apk-limpio.bat
2. Desinstala la APK vieja del móvil
3. Instala la APK nueva
```

### El escáner QR no funciona
```bash
# Solución:
1. Ejecuta: compilar-apk-limpio.bat
2. Verifica que diga "✅ Permiso de CAMERA: Configurado"
3. Compila en Android Studio
4. Instala y verifica permisos en: Ajustes → Apps → Chronelia
```

### Gradle sync failed
```bash
# Solución:
1. Cierra Android Studio
2. Ejecuta: compilar-apk.bat → Opción 4
3. Espera a que termine
4. Abre Android Studio manualmente
5. File → Invalidate Caches / Restart
```

### Node modules corruptos
```bash
# Solución:
1. Ejecuta: compilar-apk.bat → Opción 4
2. Espera pacientemente (puede tardar 5-10 min)
```

---

## 💡 Consejos Pro

### Para desarrollo continuo:
```
Primera compilación → compilar-apk-limpio.bat
Cambios menores → compilar-apk.bat (Opción 1)
Cambios en QR → compilar-apk-limpio.bat
```

### Para ahorrar tiempo:
```
Si solo cambiaste código JS/JSX:
1. compilar-apk.bat → Opción 3
2. Abrir Android Studio manualmente
3. Build → Build APK
```

### Para asegurar calidad:
```
Antes de entregar al cliente:
→ SIEMPRE usa compilar-apk-limpio.bat
```

---

## 📚 Documentación Relacionada

- `PASOS_EN_ANDROID_STUDIO.txt` - Qué hacer en Android Studio
- `VERIFICACION_RAPIDA.md` - Checklist rápido
- `SOLUCION_ESCANER_QR_DEFINITIVA.md` - Todo sobre el escáner QR
- `../COMPILAR_APK_PASO_A_PASO.md` - Guía detallada paso a paso

---

## ✅ Checklist Antes de Compilar

Independientemente del script que uses:

- [ ] ✅ Node.js instalado (verificar: `node --version`)
- [ ] ✅ Java JDK 17+ instalado (verificar: `java -version`)
- [ ] ✅ Android Studio instalado
- [ ] ✅ Variables ANDROID_HOME configuradas
- [ ] ✅ Conexión a internet activa (descarga dependencias)
- [ ] ✅ Espacio en disco (mínimo 2 GB libres)

---

## 🎉 Resumen

| Situación | Script | Tiempo | Resultado |
|-----------|--------|--------|-----------|
| **Primera vez** | `compilar-apk-limpio.bat` | 10-20 min | APK limpia y verificada |
| **Cambios QR** | `compilar-apk-limpio.bat` | 5-10 min | Escáner actualizado |
| **Cambios UI** | `compilar-apk.bat` Opción 1 | 3-5 min | APK actualizada rápido |
| **APK con bugs** | `compilar-apk-limpio.bat` | 5-10 min | APK limpia sin bugs |
| **Solo sincronizar** | `compilar-apk.bat` Opción 3 | 1 min | Listo para Android Studio |

---

**¿Aún tienes dudas?** 

- Para **máxima seguridad** → `compilar-apk-limpio.bat`
- Para **velocidad** → `compilar-apk.bat` Opción 1
- Cuando **no funcione nada** → `compilar-apk-limpio.bat`

---

**Última actualización:** 5 de Diciembre 2025  
**Versión:** 3.0 - Escáner QR  
**Estado:** ✅ Verificado y funcional





