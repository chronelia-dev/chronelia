# ⚡ SOLUCIÓN RÁPIDA - Reservas no se guardan

**Problema:** Escáner funciona pero reservas no aparecen en dashboard

---

## 🎯 **SOLUCIÓN EN 3 PASOS**

### ✅ PASO 1: Ejecutar diagnóstico (2 minutos)

1. Ve a: **Supabase Dashboard → SQL Editor**
2. Abre el archivo: `DIAGNOSTICO_RAPIDO_RESERVAS.sql`
3. **Copia TODO el contenido**
4. Pega en SQL Editor de Supabase
5. Haz clic en **"Run"**
6. **Anota qué tests fallan** (❌)

---

### ✅ PASO 2: Aplicar fix según el diagnóstico

#### Si TEST 1 falla (Funciones RPC no existen):

1. En Supabase SQL Editor
2. Abre `FUNCIONES_RPC_MULTI_TENANT.sql`
3. Copia TODO el contenido
4. Pega en SQL Editor
5. **Run**
6. Espera "Success"

#### Si TEST 2 falla (Usuario sin schema_name):

1. En Supabase SQL Editor, ejecuta:

```sql
-- Actualizar usuario trabajador
UPDATE public.users
SET 
  schema_name = 'locosxcerveza',
  business_id = (SELECT id FROM public.businesses WHERE schema_name = 'locosxcerveza')
WHERE email = 'trabajador@chronelia.com';

-- Actualizar usuario admin
UPDATE public.users
SET 
  schema_name = 'locosxcerveza',
  business_id = (SELECT id FROM public.businesses WHERE schema_name = 'locosxcerveza')
WHERE email = 'admin@chronelia.com';

-- Verificar
SELECT email, schema_name, business_name, role
FROM public.users
WHERE schema_name IS NOT NULL;
```

2. **IMPORTANTE:** Cerrar sesión en todas las pestañas
3. Volver a iniciar sesión
4. Verificar en consola (F12):
```javascript
JSON.parse(localStorage.getItem('chronelia_user')).schema_name
// Debe retornar: "locosxcerveza"
```

#### Si TEST 3 falla (Tabla no existe):

Ejecuta el script completo de creación del schema (contacta para esto).

---

### ✅ PASO 3: Probar de nuevo (1 minuto)

1. Escanea un QR
2. Abre consola (F12)
3. Busca el log: `✅ Reserva guardada en BD`
4. **Recarga la página** (F5)
5. Verifica que la reserva aparece en "Reservas Activas"

---

## 🆘 **SI SIGUE SIN FUNCIONAR**

Comparte en la consola (F12):

1. **Logs cuando escaneas:**
   ```
   Busca desde: "🎯 Abriendo escáner QR directo..."
   Hasta: "✅ Reserva guardada en BD" o el error que aparezca
   ```

2. **Resultado del diagnóstico SQL:**
   ```
   Los 5 tests que ejecutaste en Supabase
   ```

3. **Schema name del usuario:**
   ```javascript
   JSON.parse(localStorage.getItem('chronelia_user'))
   ```

---

## 🎯 **CAUSA MÁS PROBABLE**

Basándome en tu caso:

**90% de probabilidad:** Las funciones RPC no están creadas en Supabase.

**Solución:** Ejecutar `FUNCIONES_RPC_MULTI_TENANT.sql` en Supabase SQL Editor.

---

## ⏱️ **TIEMPO ESTIMADO**

- Diagnóstico: 2 minutos
- Crear funciones RPC: 1 minuto
- Actualizar usuarios: 1 minuto
- Cerrar/abrir sesión: 1 minuto
- Probar: 1 minuto

**TOTAL: 6 minutos** ⚡

---

## ✅ **RESULTADO ESPERADO**

Después de aplicar la solución:

```
Trabajador escanea QR
    ↓
Toast: "✅ ¡Reserva activada! Pepe Gonzales - 240 minutos"
    ↓
Consola: "✅ Reserva guardada en BD: [uuid]"
    ↓
Dashboard se recarga (F5)
    ↓
Tarjeta de reserva aparece en "Reservas Activas" ✅
```

---

**Estado:** Listo para aplicar  
**Archivos necesarios:**  
- `DIAGNOSTICO_RAPIDO_RESERVAS.sql`  
- `FUNCIONES_RPC_MULTI_TENANT.sql`

---

**¡Ejecuta el diagnóstico ahora y comparte los resultados!** 🚀

