# 🚀 CHRONELIA - INSTRUCCIONES DE PRODUCCIÓN

## 📋 CAMBIOS IMPLEMENTADOS

### 1. Seguridad de Autenticación ✅
- ❌ Eliminados usuarios de prueba
- ❌ Eliminada opción de login con cualquier contraseña
- ✅ Validación real de contraseñas
- ✅ Usuario admin único con contraseña segura

### 2. Usuario Administrador ✅
```
Usuario: admin
Contraseña: chronelia2025
```

### 3. Interfaz Optimizada ✅
- Safe areas configuradas para evitar superposición
- Soporte para notch y barra de estado
- Navegación transparente en Android

---

## 🗄️ CONFIGURAR SUPABASE

### Paso 1: Ejecutar Script de Producción
1. Abre tu proyecto en **Supabase Dashboard**
2. Ve a **SQL Editor**
3. Ejecuta el archivo: `SETUP_PRODUCCION_SUPABASE.sql`
4. Verifica que aparezca el usuario admin

### Paso 2: Verificar Conexión
```javascript
URL: https://uzqtqflrhhjkcpkyfjoa.supabase.co
ANON_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 📱 INSTALAR Y PROBAR

### 1. Instalar APK
```powershell
# La APK está en:
android/app/build/outputs/apk/debug/app-debug.apk

# Renombrada a:
Chronelia-PRODUCCION-v2.0.apk
```

### 2. Primer Inicio
1. Abre la app en tu móvil
2. Inicia sesión con:
   - **Usuario:** `admin`
   - **Contraseña:** `chronelia2025`

### 3. Crear Trabajadores
1. Ve a **Panel Admin** → **Gestión de Trabajadores**
2. Clic en **+ Agregar Trabajador**
3. Completa los datos:
   - Nombre completo
   - Nombre de usuario (sin espacios)
   - Email
   - Contraseña (mínimo 6 caracteres)
4. Los trabajadores se guardan automáticamente en Supabase

### 4. Probar Funcionalidades
- ✅ Crear reservas
- ✅ Extender tiempos
- ✅ Finalizar reservas
- ✅ Ver estadísticas
- ✅ Recibir notificaciones
- ✅ Ver recomendaciones de IA

---

## 🔒 SEGURIDAD

### ⚠️ IMPORTANTE
Las contraseñas se almacenan **SIN HASH** por simplicidad.

Para **producción REAL**, deberías:
1. Implementar **bcrypt** o **argon2** para hashear contraseñas
2. Usar **Supabase Auth** en lugar de tabla custom
3. Implementar **JWT tokens** para sesiones
4. Añadir **rate limiting** al login
5. Implementar **2FA** para admin

### Recomendación Rápida
Si quieres mejorar la seguridad ahora, cambia la contraseña del admin a algo único que solo tú conozcas:

```sql
UPDATE users 
SET password_hash = 'TU_CONTRASEÑA_SUPER_SEGURA_123!'
WHERE username = 'admin';
```

---

## 📊 VERIFICAR DATOS EN SUPABASE

### Ver Usuarios
```sql
SELECT username, full_name, role, active 
FROM users 
ORDER BY created_at DESC;
```

### Ver Reservas
```sql
SELECT * FROM reservations 
WHERE DATE(start_time) = CURRENT_DATE
ORDER BY start_time DESC;
```

### Ver Estadísticas
```sql
SELECT * FROM daily_stats 
ORDER BY date DESC 
LIMIT 7;
```

---

## 🎯 FLUJO DE TRABAJO

1. **Administrador** inicia sesión → Crea trabajadores
2. **Trabajadores** inician sesión → Gestionan reservas
3. **Datos** se sincronizan automáticamente con Supabase
4. **Notificaciones** se activan 5 minutos antes del fin
5. **IA** genera recomendaciones basadas en uso real

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### No puedo iniciar sesión
- Verifica que ejecutaste el script SQL en Supabase
- Verifica la conexión a internet
- Revisa las credenciales: `admin` / `chronelia2025`

### Los datos no se guardan
- Verifica las credenciales de Supabase en `.env`
- Revisa la consola del navegador (chrome://inspect)
- Verifica que el usuario tenga permisos en RLS

### La app se superpone con la barra
- Asegúrate de tener la última APK compilada
- Reinicia la app completamente (forzar cierre)

---

## 📞 PRÓXIMOS PASOS

1. ✅ Probar todas las funciones en campo
2. 📝 Recopilar feedback de trabajadores
3. 🔧 Ajustar tiempos de notificación si es necesario
4. 📊 Revisar estadísticas después de 1 semana
5. 🚀 Planificar nuevas funcionalidades

---

**Versión:** 2.0 - PRODUCCIÓN  
**Fecha:** Octubre 2025  
**Estado:** ✅ Lista para pruebas de campo







