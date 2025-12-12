# 🧹 LIMPIEZA TOTAL Y SETUP DESDE CERO

## 🎯 OBJETIVO

Eliminar todo de Supabase y crear un sistema multi-tenant limpio con un solo negocio de prueba.

---

## ⚠️ ADVERTENCIA

**Esto eliminará TODOS los datos actuales en Supabase:**
- ✅ Todas las tablas de usuarios
- ✅ Todas las reservas
- ✅ Todos los negocios
- ✅ Todas las funciones
- ✅ Todos los schemas

**Solo procede si estás seguro de que quieres empezar desde cero.**

---

## 🚀 PROCESO COMPLETO (5 MINUTOS)

### 📋 PASO 1: Limpieza Total (1 minuto)

1. Abre Supabase → SQL Editor
2. Abre el archivo: **`PASO_1_LIMPIEZA_TOTAL.sql`**
3. Copia **TODO** el contenido
4. Pega en Supabase SQL Editor
5. Click **RUN**

**Resultado esperado:**
```
=== FUNCIONES RESTANTES ===
(vacío)

=== SCHEMAS DE NEGOCIOS RESTANTES ===
(vacío)

=== TABLAS EN PUBLIC ===
(solo tablas del sistema de Supabase)
```

✅ Si ves esto, la limpieza fue exitosa.

---

### 📋 PASO 2: Setup Completo (2 minutos)

1. **SIN CERRAR** Supabase SQL Editor
2. Abre el archivo: **`PASO_2_SETUP_COMPLETO.sql`**
3. Copia **TODO** el contenido
4. Pega en Supabase SQL Editor (puedes reemplazar todo)
5. Click **RUN**

**Resultado esperado:**

El script creará automáticamente:

#### 1️⃣ Estructura del Sistema:
```
✅ Tabla: public.businesses
✅ Tabla: public.user_business_map
✅ Función: create_business_schema()
✅ Función: create_business_user()
✅ Función: login_user() (con parámetros correctos)
```

#### 2️⃣ Negocio de Prueba:
```
✅ Negocio: Chronelia Demo
✅ Schema: business_chronelia
✅ Estado: Activo
✅ Plan: Premium
```

#### 3️⃣ Usuarios Creados:
```
✅ admin (role: admin)
   - Email: admin@chronelia.com
   - Contraseña: chronelia2025
   
✅ trabajador (role: worker)
   - Email: trabajador@chronelia.com
   - Contraseña: trabajador123
```

#### 4️⃣ Tablas en business_chronelia:
```
✅ users
✅ reservations
✅ daily_stats
✅ ai_insights
```

#### 5️⃣ Pruebas Automáticas:
```
✅ Login admin: success = true
✅ Login trabajador: success = true
✅ Contraseña incorrecta: success = false (como debe ser)
```

---

### 📋 PASO 3: Probar en la App (1 minuto)

1. Abre tu aplicación Chronelia
2. Ve a la página de Login
3. Prueba con:

**Opción 1: Administrador**
```
Usuario: admin
Contraseña: chronelia2025
```

**Opción 2: Trabajador**
```
Usuario: trabajador
Contraseña: trabajador123
```

**Resultado esperado:**
```
✅ ¡Bienvenido!
→ Redirige al dashboard
→ Sesión iniciada correctamente
```

---

## 🔍 VERIFICACIÓN POST-SETUP

### En Supabase, verifica que todo está correcto:

```sql
-- Ver función login_user con parámetros correctos
SELECT pg_get_function_arguments(p.oid) as parametros
FROM pg_proc p
WHERE p.proname = 'login_user';

-- Debe retornar: input_username text, input_password text ✅

-- Ver negocio
SELECT * FROM public.businesses;

-- Ver usuarios en mapeo
SELECT * FROM public.user_business_map;

-- Ver usuarios del negocio
SELECT username, role, active, password_hash 
FROM business_chronelia.users;

-- Probar login
SELECT * FROM login_user('admin', 'chronelia2025');
-- Debe retornar: success = true ✅
```

---

## 📊 ESTRUCTURA FINAL

```
Supabase Database
│
├── public (schema)
│   ├── businesses (tabla)
│   │   └── Chronelia Demo
│   │
│   ├── user_business_map (tabla)
│   │   ├── admin → business_chronelia
│   │   └── trabajador → business_chronelia
│   │
│   └── Funciones
│       ├── create_business_schema()
│       ├── create_business_user()
│       └── login_user(input_username, input_password) ✅
│
└── business_chronelia (schema)
    ├── users
    │   ├── admin (password: chronelia2025)
    │   └── trabajador (password: trabajador123)
    │
    ├── reservations (vacía)
    ├── daily_stats (vacía)
    └── ai_insights (vacía)
```

---

## ✅ CHECKLIST FINAL

Después de ejecutar ambos scripts, verifica:

- [ ] ✅ Función `login_user` existe con parámetros `input_username`, `input_password`
- [ ] ✅ Tabla `public.businesses` existe con 1 negocio
- [ ] ✅ Tabla `public.user_business_map` existe con 2 usuarios
- [ ] ✅ Schema `business_chronelia` existe
- [ ] ✅ Tabla `business_chronelia.users` tiene 2 usuarios (admin y trabajador)
- [ ] ✅ Login SQL funciona: `SELECT * FROM login_user('admin', 'chronelia2025')`
- [ ] ✅ Login en la app funciona con admin / chronelia2025

---

## 🎉 ¡LISTO!

Si todos los checks están ✅, tienes:

1. ✅ Sistema multi-tenant configurado correctamente
2. ✅ Un negocio de prueba funcional
3. ✅ Dos usuarios para probar (admin y trabajador)
4. ✅ Login funcionando al 100%
5. ✅ Base de datos limpia sin errores residuales

---

## 🆘 SI ALGO SALE MAL

### Error en PASO 1 (Limpieza):
```
Algunos schemas o tablas no se pueden eliminar
```
**Solución:** Está bien, ejecuta el PASO 2 de todos modos. El script creará o actualizará lo necesario.

### Error en PASO 2 (Setup):
```
"schema business_chronelia already exists"
```
**Solución:** Ejecuta PASO 1 de nuevo para limpiar completamente.

### Error: "function login_user already exists"
**Solución:** 
```sql
DROP FUNCTION IF EXISTS login_user(TEXT, TEXT) CASCADE;
```
Luego ejecuta PASO 2 de nuevo.

### El login sigue sin funcionar:
1. Ejecuta este test:
```sql
SELECT * FROM login_user('admin', 'chronelia2025');
```

2. Si retorna `success: true` pero la app falla:
   - Revisa la consola del navegador (F12)
   - Verifica que `src/lib/supabase.js` tenga las credenciales correctas de Supabase

3. Si retorna `success: false`:
   - Comparte el mensaje de error
   - Ejecuta: `SELECT * FROM business_chronelia.users WHERE username = 'admin';`
   - Verifica la contraseña guardada

---

## 📞 CREDENCIALES FINALES

### Para la App:

**Administrador:**
```
Usuario: admin
Contraseña: chronelia2025
Acceso: Completo (admin)
```

**Trabajador:**
```
Usuario: trabajador
Contraseña: trabajador123
Acceso: Limitado (worker)
```

### Para Supabase:
- Schema: `business_chronelia`
- Negocio: Chronelia Demo
- Estado: Activo

---

## 🎯 PRÓXIMOS PASOS (Opcionales)

### Agregar Más Trabajadores:
```sql
SELECT create_business_user(
  'business_chronelia',
  'nuevo_usuario',
  'email@example.com',
  'contraseña123',
  'Nombre Completo',
  'worker'
);
```

### Agregar Otro Negocio:
```sql
-- Crear negocio
SELECT create_business_schema(
  'business_nuevo',
  'Nombre del Negocio',
  'contacto@negocio.com',
  '+34 600 000 000',
  'Dirección',
  'basic',
  5
);

-- Crear admin para el negocio
SELECT create_business_user(
  'business_nuevo',
  'admin_nuevo',
  'admin@negocio.com',
  'password123',
  'Admin Nuevo Negocio',
  'admin'
);
```

---

**¡Empieza ejecutando PASO_1_LIMPIEZA_TOTAL.sql!** 🚀







