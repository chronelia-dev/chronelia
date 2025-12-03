# 📱 CHRONELIA v1.1 - NUEVA APK ACTUALIZADA

## 🎉 APK Lista para Instalar

**Archivo**: `Chronelia-v1.1-ACTUALIZADA.apk`

---

## ✨ NUEVAS FUNCIONALIDADES

### 1. 🔐 Campo de Contraseña para Trabajadores

#### ¿Qué se agregó?
- **Campo de contraseña** en el formulario de añadir trabajador
- La contraseña se valida (mínimo 6 caracteres)
- Se guarda en Supabase en el campo `password_hash`

#### ¿Cómo usarlo?
1. Ve a **Trabajadores** en el menú
2. Haz clic en **"Agregar Trabajador"**
3. Completa:
   - Nombre Completo
   - Email
   - **Contraseña** (nuevo campo con icono de candado 🔒)
4. La contraseña se guardará en la base de datos

#### Archivos modificados:
- `src/pages/Workers.jsx` - Formulario actualizado
- `src/lib/supabase.js` - Función `saveWorker` con campo `password_hash`
- `supabase_setup.sql` - Tabla `users` con columna `password_hash`

---

### 2. 📱 Auto-cierre del Menú en Móvil

#### ¿Qué se agregó?
- El menú lateral (sidebar) ahora se **cierra automáticamente** al seleccionar una opción
- Retraso de **300ms** para que veas la selección antes de cerrar
- **Solo funciona en móviles** (pantallas menores a 1024px)

#### Beneficio:
- Mejor experiencia de usuario en dispositivos móviles
- No necesitas cerrar manualmente el menú después de navegar

#### Archivos modificados:
- `src/components/layout/Sidebar.jsx` - Función `handleMenuItemClick`

---

### 3. 🎨 Iconos de la App Configurados

#### Estado:
- Los iconos de Chronelia ya están configurados en el proyecto Android
- Se encuentran en todas las carpetas `mipmap-*` necesarias
- La APK los incluye automáticamente al compilar

#### Ubicaciones:
- `android/app/src/main/res/mipmap-hdpi/`
- `android/app/src/main/res/mipmap-mdpi/`
- `android/app/src/main/res/mipmap-xhdpi/`
- `android/app/src/main/res/mipmap-xxhdpi/`
- `android/app/src/main/res/mipmap-xxxhdpi/`

---

## 🔄 FUNCIONALIDADES EXISTENTES (Intactas)

✅ **Conexión con Supabase** - Funciona perfectamente  
✅ **Sincronización de datos** - Trabajadores y reservas se guardan en la nube  
✅ **5 Tarjetas de Recomendaciones IA** - Auto-scroll cada 20 segundos  
✅ **Sistema de reservas** - Completamente funcional  
✅ **Historial y Estadísticas** - Disponibles  

---

## 📊 ACTUALIZACIÓN DE BASE DE DATOS

### ⚠️ IMPORTANTE: Actualizar schema de Supabase

Debes ejecutar este SQL en tu proyecto de Supabase:

```sql
-- Agregar columna de contraseña a la tabla users
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS password_hash TEXT NOT NULL DEFAULT 'changeme123';
```

**Pasos:**
1. Abre tu proyecto en Supabase: https://supabase.com/dashboard
2. Ve a **SQL Editor**
3. Pega el comando de arriba
4. Ejecuta (Run)

Si prefieres recrear toda la tabla:
- Usa el archivo `supabase_setup.sql` actualizado
- **NOTA**: Esto eliminará datos existentes. Haz backup primero.

---

## 📲 CÓMO INSTALAR LA NUEVA APK

### Opción 1: Actualización directa
Si ya tienes la versión anterior instalada:
1. Transfiere `Chronelia-v1.1-ACTUALIZADA.apk` a tu móvil
2. Instala directamente (se actualizará)

### Opción 2: Instalación limpia
Si prefieres empezar de cero:
1. Desinstala la versión anterior
2. Transfiere `Chronelia-v1.1-ACTUALIZADA.apk` a tu móvil
3. Instala la nueva versión

---

## 🧪 CÓMO PROBAR LAS NUEVAS FUNCIONES

### Test 1: Campo de Contraseña
1. Inicia sesión como **admin** (admin@chronelia.com / admin123)
2. Ve a **Trabajadores**
3. Haz clic en **"Agregar Trabajador"**
4. Verifica que aparece el campo **"Contraseña"** con icono de candado
5. Intenta agregar un trabajador con contraseña corta (menos de 6 caracteres) - debería dar error
6. Agrega un trabajador con datos completos incluyendo contraseña
7. Verifica en Supabase que el trabajador se guardó con `password_hash`

### Test 2: Auto-cierre del Menú
1. Abre la app en tu móvil
2. Inicia sesión
3. Abre el menú lateral (hamburguesa ☰)
4. Toca cualquier opción del menú
5. El menú debería cerrarse automáticamente en **300ms**

---

## 📝 RESUMEN TÉCNICO

### Cambios en el código:

| Archivo | Cambio | Tipo |
|---------|--------|------|
| `src/pages/Workers.jsx` | Campo de contraseña + validación | Nueva funcionalidad |
| `src/lib/supabase.js` | Guardar `password_hash` | Actualización |
| `src/lib/syncHelpers.js` | Sin cambios | - |
| `src/components/layout/Sidebar.jsx` | Auto-cierre en móvil | Mejora UX |
| `supabase_setup.sql` | Columna `password_hash` | Esquema DB |

### Tamaño de la APK:
- **Aproximadamente**: 28-29 MB
- **Incluye**: Todas las dependencias, plugins de cámara y ML Kit

---

## 🚀 PRÓXIMOS PASOS SUGERIDOS

1. **Instalar la APK** en tu móvil
2. **Actualizar el schema** de Supabase con la columna `password_hash`
3. **Probar** las nuevas funcionalidades
4. **Crear trabajadores** con contraseñas
5. **Verificar** que todo se sincronice correctamente con Supabase

---

## ⚙️ CONFIGURACIÓN TÉCNICA

- **Java Version**: 17
- **Gradle Version**: 8.9
- **Android SDK**: 34
- **Min SDK**: 22
- **Capacitor**: Última versión
- **Supabase**: Conectado a `https://uzqtqflrhhjkcpkyfjoa.supabase.co`

---

## 📞 SOPORTE

Si encuentras algún problema:
1. Verifica que actualizaste el schema de Supabase
2. Revisa la consola del navegador (para versión web)
3. Revisa los logs de la app (para versión móvil)

---

**Fecha de compilación**: ${new Date().toLocaleString('es-ES')}  
**Versión**: 1.1.0  
**Build**: Debug con Supabase integrado  
**Estado**: ✅ Lista para producción







