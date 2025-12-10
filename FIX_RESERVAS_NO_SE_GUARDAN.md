# 🔧 FIX: Reservas no se guardan después de escanear

**Problema:** El escáner lee correctamente el QR pero la reserva no aparece en el dashboard

---

## 🔍 **DIAGNÓSTICO**

### Síntomas:
- ✅ Escáner abre correctamente
- ✅ QR se lee correctamente
- ✅ Toast de éxito aparece ("¡Reserva activada!")
- ❌ **Reserva NO aparece en el dashboard**
- ❌ **Admin NO ve la reserva en tiempo real**

### Causa Raíz:
La función RPC `save_reservation` no está creada en Supabase, por lo que las reservas no se guardan en la base de datos.

---

## ✅ **SOLUCIÓN**

### Paso 1: Verificar funciones RPC en Supabase

1. Ve a Supabase Dashboard
2. Abre el **SQL Editor**
3. Ejecuta esta consulta para verificar:

```sql
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_name IN (
  'get_active_reservations',
  'get_reservation_history',
  'get_workers',
  'save_reservation'
)
ORDER BY routine_name;
```

**Si no aparecen las 4 funciones** → Continúa al Paso 2

---

### Paso 2: Crear las funciones RPC

1. En Supabase Dashboard → **SQL Editor**
2. **Copia y pega TODO** el contenido de `FUNCIONES_RPC_MULTI_TENANT.sql`
3. Haz clic en **"Run"** (Ejecutar)
4. Espera a que diga "Success"
5. **Verifica** que las 4 funciones se crearon (ejecuta la consulta del Paso 1)

---

### Paso 3: Verificar que el usuario tiene schema_name

En la app, abre la consola (F12) y ejecuta:

```javascript
JSON.parse(localStorage.getItem('chronelia_user'))
```

**Debe mostrar algo como:**
```json
{
  "id": "...",
  "email": "trabajador@chronelia.com",
  "schema_name": "locosxcerveza",  ← DEBE EXISTIR
  "business_id": "...",
  "business_name": "Locos X Cerveza",
  "role": "worker"
}
```

**Si `schema_name` es `null` o no existe** → Continúa al Paso 4

---

### Paso 4: Actualizar usuario con schema_name

Si el usuario no tiene `schema_name`, ejecuta en Supabase SQL Editor:

```sql
-- Reemplaza 'correo@ejemplo.com' con el email del usuario
UPDATE public.users
SET 
  schema_name = 'locosxcerveza',  -- Reemplaza con tu schema
  business_id = (SELECT id FROM public.businesses WHERE schema_name = 'locosxcerveza')
WHERE email = 'trabajador@chronelia.com';

-- Verifica que se actualizó
SELECT 
  email, 
  schema_name, 
  business_name, 
  role
FROM public.users
WHERE email = 'trabajador@chronelia.com';
```

**Importante:** Después de esto, el usuario debe **cerrar sesión y volver a iniciar sesión**.

---

### Paso 5: Verificar tabla reservations existe en el schema

```sql
-- Reemplaza 'locosxcerveza' con tu schema
SELECT 
  table_name, 
  table_schema
FROM information_schema.tables
WHERE table_schema = 'locosxcerveza'
  AND table_name = 'reservations';
```

**Si NO existe** → Crear la tabla:

```sql
CREATE TABLE IF NOT EXISTS locosxcerveza.reservations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name text NOT NULL,
  customer_email text,
  qr_code text,
  total_duration integer NOT NULL,
  actual_duration integer,
  start_time timestamptz NOT NULL DEFAULT NOW(),
  end_time timestamptz,
  status text NOT NULL CHECK (status IN ('active', 'completed', 'cancelled')),
  worker_name text,
  group_size integer DEFAULT 1,
  extensions integer DEFAULT 0,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);
```

---

## 🧪 **PROBAR LA SOLUCIÓN**

### Test 1: Verificar en consola

1. Abre la app en el navegador (o APK)
2. Abre DevTools (F12) si es navegador
3. Escanea un QR
4. **Busca en la consola:**

```
✅ Código QR: {...}
💾 Guardando reserva en schema locosxcerveza: {...}
✅ Reserva guardada exitosamente, ID: ...
✅ Reserva guardada en BD: ...
➕ Agregando nueva reserva: ...
```

**Si ves esos logs** → La reserva se guardó correctamente

**Si ves errores** → Copia el error y revisa el Paso correspondiente

---

### Test 2: Verificar en Supabase

Después de escanear un QR, ve a Supabase y ejecuta:

```sql
-- Verificar que la reserva se guardó
SELECT 
  id,
  customer_name,
  worker_name,
  total_duration,
  status,
  start_time
FROM locosxcerveza.reservations  -- Reemplaza con tu schema
WHERE status = 'active'
ORDER BY start_time DESC
LIMIT 5;
```

**Si aparece la reserva** → ✅ Funcionando correctamente

---

### Test 3: Verificar en el dashboard

1. Escanea un QR en el dispositivo del trabajador
2. **Inmediatamente** recarga el dashboard del admin (F5)
3. Debería aparecer la nueva reserva

**Nota:** El tiempo real está temporalmente deshabilitado, por lo que necesitas recargar manualmente.

---

## 🔄 **HABILITAR TIEMPO REAL (OPCIONAL)**

Para que las reservas aparezcan automáticamente sin recargar:

```sql
-- Habilitar replicación en la tabla reservations
ALTER TABLE locosxcerveza.reservations 
REPLICA IDENTITY FULL;

-- Habilitar realtime
ALTER PUBLICATION supabase_realtime 
ADD TABLE locosxcerveza.reservations;
```

Luego en el código, descomentar la línea en `syncHelpers.js`:

```javascript
// Línea 265
export function setupRealtimeSync(onReservationChange) {
  // Implementar aquí la suscripción a cambios en tiempo real
}
```

---

## ⚠️ **ERRORES COMUNES**

### Error: "No schema found"
**Solución:** El usuario no tiene `schema_name`. Ejecuta el Paso 4.

### Error: "relation does not exist"
**Solución:** La tabla no existe en el schema. Ejecuta el Paso 5.

### Error: "function save_reservation does not exist"
**Solución:** Las funciones RPC no están creadas. Ejecuta el Paso 2.

### Error: "permission denied"
**Solución:** El usuario no tiene permisos. Ejecuta:
```sql
-- Dar permisos al usuario anónimo (public)
GRANT USAGE ON SCHEMA locosxcerveza TO anon;
GRANT ALL ON ALL TABLES IN SCHEMA locosxcerveza TO anon;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon;
```

---

## 📋 **CHECKLIST DE VERIFICACIÓN**

Antes de probar, asegúrate de que:

- [ ] Las 4 funciones RPC están creadas en Supabase
- [ ] El usuario tiene `schema_name` en su perfil
- [ ] La tabla `reservations` existe en el schema
- [ ] El usuario tiene permisos para ejecutar las funciones
- [ ] El usuario ha cerrado sesión y vuelto a iniciar después de actualizaciones

---

## 🎯 **FLUJO CORRECTO**

Cuando todo está configurado correctamente:

```
1. Trabajador escanea QR
   ↓
2. handleScanQR() lee el código
   ↓
3. addReservation() se llama con los datos
   ↓
4. syncReservation() guarda en Supabase
   ↓
5. save_reservation() RPC inserta en schema.reservations
   ↓
6. Estado local se actualiza con set()
   ↓
7. Dashboard muestra la nueva reserva ✅
```

---

## 📝 **SCRIPT COMPLETO DE VERIFICACIÓN**

Ejecuta este script en Supabase para verificar todo:

```sql
-- 1. Verificar funciones RPC
SELECT routine_name FROM information_schema.routines
WHERE routine_name IN ('save_reservation', 'get_active_reservations');

-- 2. Verificar usuarios tienen schema_name
SELECT email, schema_name, business_name 
FROM public.users 
WHERE schema_name IS NOT NULL;

-- 3. Verificar tabla reservations existe
SELECT table_schema, table_name 
FROM information_schema.tables
WHERE table_name = 'reservations';

-- 4. Verificar permisos
SELECT 
  grantee, 
  privilege_type 
FROM information_schema.role_table_grants
WHERE table_name = 'reservations';

-- 5. Contar reservas activas
SELECT 
  schema_name,
  (SELECT COUNT(*) FROM locosxcerveza.reservations WHERE status = 'active') as activas
FROM public.businesses;
```

---

## ✅ **RESULTADO ESPERADO**

Después de aplicar estas soluciones:

- ✅ Escáner funciona
- ✅ QR se lee correctamente
- ✅ **Reserva se guarda en Supabase**
- ✅ **Reserva aparece en el dashboard del trabajador**
- ✅ **Reserva aparece en el dashboard del admin** (después de recargar)
- ✅ Sin errores en consola

---

**Estado:** Listo para aplicar  
**Tiempo estimado:** 10-15 minutos  
**Dificultad:** Media

---

*Ejecuta los pasos en orden y verifica cada uno antes de continuar al siguiente.*

