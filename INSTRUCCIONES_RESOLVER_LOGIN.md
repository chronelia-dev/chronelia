# 🚨 ERROR DE LOGIN - SOLUCIÓN PASO A PASO

## 📌 DIAGNÓSTICO RÁPIDO (30 segundos)

### Ejecuta esto PRIMERO en Supabase SQL Editor:

```sql
SELECT 
  pg_get_function_arguments(p.oid) as parametros_actuales
FROM pg_proc p
WHERE p.proname = 'login_user';
```

### 🔍 Interpretación:

#### ✅ Si ves esto:
```
parametros_actuales: input_username text, input_password text
```
→ **La función está correcta**  
→ El problema está en otro lado  
→ **Salta al [Paso 2: Diagnóstico Completo](#paso-2-diagnóstico-completo)**

#### ❌ Si ves esto:
```
parametros_actuales: p_username text, p_password text
```
→ **¡ESTE ES EL PROBLEMA!**  
→ La función usa nombres antiguos  
→ **Ve directo al [Paso 1: Arreglar Parámetros](#paso-1-arreglar-parámetros)**

#### ❌ Si no retorna nada:
→ **La función no existe**  
→ **Ve al [Paso 0: Crear la Base](#paso-0-crear-la-base)**

---

## 🔧 PASO 0: Crear la Base

**Solo si la función `login_user` NO existe**

1. Ve a Supabase → SQL Editor
2. Ejecuta: **`MULTI_TENANT_SCHEMAS.sql`**
3. Espera a que termine (puede tomar 1-2 minutos)
4. Regresa al [Diagnóstico Rápido](#diagnóstico-rápido-30-segundos)

---

## 🔧 PASO 1: Arreglar Parámetros

**Si los parámetros son `p_username` y `p_password`**

### 1.1 Ejecutar el Fix

1. Ve a Supabase → SQL Editor
2. Abre el archivo: **`FIX_LOGIN_PARAMETROS.sql`**
3. Copia TODO el contenido
4. Pega en Supabase SQL Editor
5. Click **RUN**

### 1.2 Verificar que funcionó

Deberías ver un resultado como:

```
check: === VERIFICAR FUNCIÓN ===
parametros_actuales: input_username text, input_password text
estado: ✅ CORRECTO - Usa input_username
```

### 1.3 Probar el login

```
test: === PRUEBA DE LOGIN ===
success: true
message: Login exitoso
username: admin
business_name: Demo Chronelia
```

### 1.4 Si la prueba falla:

**Error: "Usuario no encontrado"**
→ Ve al [Paso 3: Crear Usuario](#paso-3-crear-usuario)

**Error: "Contraseña incorrecta"**
→ Ve al [Paso 4: Resetear Contraseña](#paso-4-resetear-contraseña)

**Error: "Usuario inactivo"**
→ Ejecuta:
```sql
UPDATE business_demo.users 
SET active = true 
WHERE username = 'admin';
```

### 1.5 Probar en la App

1. Abre tu app Chronelia
2. Intenta login con:
   ```
   Usuario: admin
   Contraseña: chronelia2025
   ```
3. **¿Funcionó?** 🎉 ¡Listo!
4. **¿Sigue fallando?** → Ve al [Paso 2](#paso-2-diagnóstico-completo)

---

## 🔍 PASO 2: Diagnóstico Completo

**Si la función tiene los parámetros correctos pero el login falla**

### 2.1 Ejecutar diagnóstico

1. Abre: **`DIAGNOSTICO_LOGIN.sql`**
2. Copia TODO el contenido
3. Pega en Supabase SQL Editor
4. Click **RUN**

### 2.2 Revisa cada sección:

#### Sección 1: Función login_user
```
status: ✅ EXISTE
```
✅ OK → Continúa

```
status: ❌ NO EXISTE
```
❌ ERROR → Ve al [Paso 0](#paso-0-crear-la-base)

#### Sección 2: Parámetros
```
parametros: input_username text, input_password text
```
✅ OK → Continúa

```
parametros: p_username text, p_password text
```
❌ ERROR → Ve al [Paso 1](#paso-1-arreglar-parámetros)

#### Sección 3: Tabla user_business_map
```
status: ✅ EXISTE
```
✅ OK → Continúa

```
status: ❌ NO EXISTE
```
❌ ERROR → Ve al [Paso 0](#paso-0-crear-la-base)

#### Sección 4: Usuarios en mapeo
```
username: admin
schema_name: business_demo
business_name: Demo Chronelia
```
✅ OK → Continúa

Si está **VACÍO**:
❌ ERROR → Ve al [Paso 3](#paso-3-crear-usuario)

#### Sección 6: Prueba de login
```
test: === PRUEBA DE LOGIN: admin ===
success: true
message: Login exitoso
```
✅ OK → El problema está en el **frontend**

```
success: false
message: Usuario no encontrado
```
❌ ERROR → Ve al [Paso 3](#paso-3-crear-usuario)

```
success: false
message: Contraseña incorrecta
```
❌ ERROR → Ve al [Paso 4](#paso-4-resetear-contraseña)

---

## 👤 PASO 3: Crear Usuario

**Si el usuario no existe o el mapeo está vacío**

```sql
-- ============================================
-- CREAR USUARIO ADMIN COMPLETO
-- ============================================

-- Paso 1: Asegurar que existe el negocio
INSERT INTO public.businesses (
  schema_name, 
  business_name, 
  active, 
  plan_type, 
  max_workers
)
VALUES (
  'business_demo',
  'Demo Chronelia',
  true,
  'premium',
  20
)
ON CONFLICT (schema_name) DO UPDATE 
SET active = true;

-- Guardar el business_id
-- (Ve al resultado y copia el id que aparece)

-- Paso 2: Crear el schema y tabla si no existen
CREATE SCHEMA IF NOT EXISTS business_demo;

CREATE TABLE IF NOT EXISTS business_demo.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'worker')),
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Paso 3: Insertar usuario
INSERT INTO business_demo.users (
  username, 
  email, 
  password_hash, 
  full_name, 
  role, 
  active
)
VALUES (
  'admin',
  'admin@chronelia.com',
  'chronelia2025',
  'Administrador Demo',
  'admin',
  true
)
ON CONFLICT (username) DO UPDATE 
SET 
  password_hash = 'chronelia2025',
  active = true,
  email = 'admin@chronelia.com';

-- Paso 4: Agregar al mapeo
-- IMPORTANTE: Reemplaza el UUID con el id del negocio del Paso 1
INSERT INTO public.user_business_map (
  username, 
  schema_name, 
  business_name,
  business_id
)
SELECT 
  'admin',
  'business_demo',
  'Demo Chronelia',
  b.id
FROM public.businesses b
WHERE b.schema_name = 'business_demo'
ON CONFLICT (username) DO UPDATE 
SET 
  schema_name = 'business_demo',
  business_name = 'Demo Chronelia',
  business_id = EXCLUDED.business_id;

-- Paso 5: Verificar
SELECT * FROM business_demo.users WHERE username = 'admin';
SELECT * FROM public.user_business_map WHERE username = 'admin';
```

Luego regresa al [Paso 1](#paso-1-arreglar-parámetros) y prueba de nuevo.

---

## 🔑 PASO 4: Resetear Contraseña

**Si la contraseña es incorrecta**

```sql
-- Ver la contraseña actual
SELECT username, password_hash 
FROM business_demo.users 
WHERE username = 'admin';

-- Cambiar a: chronelia2025
UPDATE business_demo.users 
SET password_hash = 'chronelia2025'
WHERE username = 'admin';

-- Verificar
SELECT username, password_hash, active 
FROM business_demo.users 
WHERE username = 'admin';
```

Ahora prueba login con:
```
Usuario: admin
Contraseña: chronelia2025
```

---

## 🖥️ PASO 5: Revisar Frontend

**Si el SQL funciona pero la app no**

### 5.1 Abrir consola del navegador

1. Abre la app Chronelia
2. Presiona **F12**
3. Ve a la pestaña **Console**

### 5.2 Intentar login

Escribe: `admin` / `chronelia2025`

### 5.3 Buscar estos mensajes:

#### ✅ Login exitoso:
```
🔐 Intentando login con: admin
📊 Resultado de login_user (raw): [{success: true, ...}]
✅ Login exitoso: admin | Negocio: Demo Chronelia
```
→ ¡Debería funcionar!

#### ❌ Error de función:
```
❌ Error en login_user: {code: "42883", message: "function login_user(input_username => text, ...) does not exist"}
```
→ Los parámetros están mal → [Paso 1](#paso-1-arreglar-parámetros)

#### ❌ Error de conexión:
```
❌ Error inesperado en login: Failed to fetch
```
→ Problema de red o credenciales de Supabase incorrectas

### 5.4 Verificar credenciales de Supabase

Revisa el archivo: `src/lib/supabase.js`

Líneas 6-7:
```javascript
const supabaseUrl = '...'      // Debe ser tu URL de Supabase
const supabaseAnonKey = '...'  // Debe ser tu Anon Key
```

Verifica en Supabase:
1. Project Settings
2. API
3. Project URL = `supabaseUrl`
4. anon/public = `supabaseAnonKey`

---

## 📞 NECESITAS MÁS AYUDA?

### Comparte esta información:

1. **Resultado del diagnóstico rápido:**
```sql
SELECT pg_get_function_arguments(p.oid) 
FROM pg_proc p 
WHERE p.proname = 'login_user';
```

2. **Resultado de la prueba de login:**
```sql
SELECT * FROM login_user('admin', 'chronelia2025');
```

3. **Logs de la consola del navegador** (F12 → Console)

4. **Mensaje de error exacto** que ves en la pantalla

---

## ✅ CHECKLIST FINAL

Antes de decir que no funciona, verifica:

- [ ] ✅ La función `login_user` existe
- [ ] ✅ Los parámetros son `input_username` e `input_password`
- [ ] ✅ Existe la tabla `user_business_map`
- [ ] ✅ El usuario `admin` está en `business_demo.users`
- [ ] ✅ El usuario `admin` está en `public.user_business_map`
- [ ] ✅ La contraseña es `chronelia2025`
- [ ] ✅ El usuario está activo (`active = true`)
- [ ] ✅ El negocio está activo
- [ ] ✅ Las credenciales de Supabase son correctas en `supabase.js`
- [ ] ✅ La consola del navegador no muestra errores de red

---

## 🎯 RESUMEN RÁPIDO

```
1. ¿Función existe? NO → Ejecutar MULTI_TENANT_SCHEMAS.sql
                    SÍ → Continuar

2. ¿Parámetros correctos? NO → Ejecutar FIX_LOGIN_PARAMETROS.sql
                          SÍ → Continuar

3. ¿Usuario existe? NO → Ejecutar script de crear usuario (Paso 3)
                    SÍ → Continuar

4. ¿Contraseña correcta? NO → Ejecutar UPDATE de contraseña (Paso 4)
                         SÍ → Continuar

5. ¿SQL funciona? NO → Revisar diagnóstico completo
                  SÍ → Revisar frontend (F12 Console)
```

---

**Empieza por el [Diagnóstico Rápido](#diagnóstico-rápido-30-segundos) y sigue los pasos según los resultados.** 🚀




