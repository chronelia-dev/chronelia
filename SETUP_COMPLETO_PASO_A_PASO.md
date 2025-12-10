# 🚀 SETUP COMPLETO - Configurar Supabase desde Cero

**Problema detectado:** La tabla `public.users` no existe  
**Solución:** Configurar la base de datos completa  
**Tiempo estimado:** 10 minutos

---

## ⚡ **SOLUCIÓN RÁPIDA (3 SCRIPTS)**

Ejecuta estos 3 scripts EN ORDEN en Supabase SQL Editor:

### 📝 SCRIPT 1: Diagnóstico Básico (OPCIONAL)
```
Archivo: DIAGNOSTICO_NIVEL_0_BASICO.sql
Propósito: Ver qué existe actualmente
Tiempo: 30 segundos
```

### 📝 SCRIPT 2: Setup Completo (OBLIGATORIO)
```
Archivo: SETUP_PRODUCCION_SUPABASE.sql
Propósito: Crear toda la estructura (tablas, funciones, datos)
Tiempo: 2 minutos
```

### 📝 SCRIPT 3: Funciones RPC (OBLIGATORIO)
```
Archivo: FUNCIONES_RPC_MULTI_TENANT.sql
Propósito: Crear funciones para multi-tenant
Tiempo: 1 minuto
```

---

## 📋 **PASO A PASO DETALLADO**

### ✅ PASO 1: Abrir Supabase

1. Ve a: https://supabase.com/dashboard
2. Selecciona tu proyecto de Chronelia
3. Ve a **SQL Editor** (menú lateral izquierdo)

---

### ✅ PASO 2: Ejecutar Diagnóstico (OPCIONAL)

1. En tu editor de código, abre: `DIAGNOSTICO_NIVEL_0_BASICO.sql`
2. **Copia TODO el contenido** (Ctrl+A, Ctrl+C)
3. Pega en Supabase SQL Editor
4. Click en **"Run"**
5. Observa los resultados

**Si ves pocas o ninguna tabla** → Continúa al Paso 3

---

### ✅ PASO 3: Setup Producción (OBLIGATORIO)

1. En tu editor, abre: `SETUP_PRODUCCION_SUPABASE.sql`
2. **Copia TODO el contenido**
3. Pega en Supabase SQL Editor
4. Click en **"Run"**
5. Espera a que diga **"Success"**

**Esto creará:**
- ✅ Tabla `public.businesses`
- ✅ Tabla `public.users`
- ✅ Schema `locosxcerveza`
- ✅ Todas las tablas del schema (users, reservations, etc.)
- ✅ Datos de ejemplo (admin, trabajador)

---

### ✅ PASO 4: Funciones RPC (OBLIGATORIO)

1. En tu editor, abre: `FUNCIONES_RPC_MULTI_TENANT.sql`
2. **Copia TODO el contenido**
3. Pega en Supabase SQL Editor
4. Click en **"Run"**
5. Espera "Success"

**Esto creará:**
- ✅ `save_reservation()`
- ✅ `get_active_reservations()`
- ✅ `get_reservation_history()`
- ✅ `get_workers()`

---

### ✅ PASO 5: Verificar que todo se creó

Ejecuta en Supabase SQL Editor:

```sql
-- Verificar tablas en public
SELECT table_name 
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Verificar funciones RPC
SELECT routine_name 
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%reservation%'
ORDER BY routine_name;

-- Verificar usuarios
SELECT 
  email, 
  schema_name, 
  business_name, 
  role
FROM public.users;
```

**Deberías ver:**
- ✅ Tablas: `businesses`, `users`
- ✅ Funciones: `save_reservation`, `get_active_reservations`, etc.
- ✅ Usuarios: admin y trabajador con `schema_name = 'locosxcerveza'`

---

### ✅ PASO 6: Iniciar sesión de nuevo

1. En la app (chronelia.online)
2. **Cerrar sesión**
3. **Iniciar sesión** con:
   ```
   Email: trabajador@chronelia.com
   Password: Chronelia@202x
   ```

4. Verificar en consola (F12):
```javascript
JSON.parse(localStorage.getItem('chronelia_user')).schema_name
// Debe retornar: "locosxcerveza"
```

---

### ✅ PASO 7: Probar escáner

1. Haz clic en botón "Escanear"
2. Escanea un QR
3. Verifica en consola:
   ```
   ✅ Reserva guardada en BD: [uuid]
   ```
4. **Recarga la página** (F5)
5. **Verifica que la reserva aparece** en "Reservas Activas"

---

## 🎯 **CREDENCIALES CREADAS**

El script `SETUP_PRODUCCION_SUPABASE.sql` crea estos usuarios:

### Admin:
```
Email: admin@chronelia.com
Password: Chronelia@202x
Rol: admin
Schema: locosxcerveza
```

### Trabajador:
```
Email: trabajador@chronelia.com
Password: Chronelia@202x
Rol: worker
Schema: locosxcerveza
```

**Usa estas credenciales para probar.**

---

## 📊 **QUÉ SE CREA**

### En `public` schema:
- Tabla `businesses` (datos de negocios)
- Tabla `users` (usuarios del sistema)
- 1 negocio: "Locos X Cerveza"
- 2 usuarios: admin y trabajador

### En `locosxcerveza` schema:
- Tabla `users` (usuarios del negocio)
- Tabla `reservations` (reservas)
- Tabla `customers` (clientes)
- Tabla `daily_stats` (estadísticas)

### Funciones RPC:
- `save_reservation()` - Guardar reservas
- `get_active_reservations()` - Obtener reservas activas
- `get_reservation_history()` - Historial
- `get_workers()` - Obtener trabajadores

---

## ⚠️ **IMPORTANTE**

Después de ejecutar los scripts:

1. ✅ **DEBES cerrar sesión** en la app
2. ✅ **DEBES volver a iniciar sesión**
3. ✅ **Verifica en consola** que tienes `schema_name`
4. ✅ Solo entonces prueba el escáner

**¿Por qué?** El `schema_name` se carga al iniciar sesión y se guarda en localStorage. Si no cierras sesión, seguirá siendo `null`.

---

## 🔄 **SI YA TIENES DATOS**

Si ya tienes un negocio configurado con otro nombre:

1. Abre `SETUP_PRODUCCION_SUPABASE.sql`
2. Busca y reemplaza:
   - `'locosxcerveza'` → `'tu_schema_name'`
   - `'Locos X Cerveza'` → `'Tu Negocio'`
3. Ejecuta el script modificado

---

## 📋 **CHECKLIST COMPLETO**

```
[ ] 1. Abrir Supabase Dashboard
[ ] 2. Ir a SQL Editor
[ ] 3. Ejecutar SETUP_PRODUCCION_SUPABASE.sql
[ ] 4. Esperar "Success"
[ ] 5. Ejecutar FUNCIONES_RPC_MULTI_TENANT.sql
[ ] 6. Esperar "Success"
[ ] 7. Verificar que tablas y funciones existen
[ ] 8. Cerrar sesión en la app
[ ] 9. Iniciar sesión de nuevo
[ ] 10. Verificar schema_name en consola
[ ] 11. Probar escáner QR
[ ] 12. Verificar que reserva se guarda
```

---

## 🆘 **SIGUIENTE ACCIÓN INMEDIATA**

**Ejecuta en este orden:**

1. **Primero:** `SETUP_PRODUCCION_SUPABASE.sql`
2. **Segundo:** `FUNCIONES_RPC_MULTI_TENANT.sql`
3. **Tercero:** Cerrar/abrir sesión en la app
4. **Cuarto:** Probar escáner

---

**¿Tienes el archivo `SETUP_PRODUCCION_SUPABASE.sql`?**

Si SÍ → Ejecútalo ahora  
Si NO → Dime y te lo creo

---

**Tiempo total: 5 minutos** ⚡

