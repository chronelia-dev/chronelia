-- ============================================
-- 🏢 AGREGAR NUEVO NEGOCIO - CHRONELIA
-- ============================================
-- Script simple para crear un nuevo cliente con su usuario admin
-- 
-- INSTRUCCIONES:
-- 1. Reemplaza los valores entre [CORCHETES]
-- 2. Ejecuta todo el script en Supabase SQL Editor
-- 3. Guarda las credenciales generadas
-- ============================================

-- ============================================
-- PASO 1: CREAR EL NEGOCIO Y SUS TABLAS
-- ============================================

SELECT create_business_schema(
  '[NOMBRE_SCHEMA]',              -- Ejemplo: 'business_pepe' (sin espacios, minúsculas)
  '[Nombre del Negocio]',         -- Ejemplo: 'Peluquería Pepe'
  '[email@negocio.com]',          -- Email de contacto del negocio
  '[+34 600 000 000]',            -- Teléfono del negocio
  '[Dirección completa]',         -- Dirección física
  '[PLAN]',                       -- 'basic', 'premium' o 'enterprise'
  [MAX_WORKERS]                   -- Número máximo de trabajadores (ejemplo: 10)
);

-- ============================================
-- PASO 2: CREAR USUARIO ADMINISTRADOR
-- ============================================

SELECT create_business_user(
  '[NOMBRE_SCHEMA]',              -- Mismo que en PASO 1
  '[username_admin]',             -- Username para login (ejemplo: 'admin_pepe')
  '[admin@negocio.com]',          -- Email del administrador
  '[contraseña_admin]',           -- Contraseña (ejemplo: 'pepe2025')
  '[Nombre del Admin]',           -- Nombre completo (ejemplo: 'José Pérez')
  'admin'                         -- Rol: siempre 'admin' para el primer usuario
);

-- ============================================
-- PASO 3 (OPCIONAL): CREAR TRABAJADORES
-- ============================================

-- Trabajador 1
SELECT create_business_user(
  '[NOMBRE_SCHEMA]',              -- Mismo schema del negocio
  '[username_trabajador1]',       -- Username único (ejemplo: 'carlos')
  '[trabajador1@negocio.com]',   -- Email del trabajador
  '[contraseña_trabajador1]',    -- Contraseña
  '[Nombre Trabajador 1]',       -- Nombre completo
  'worker'                        -- Rol: 'worker' para trabajadores
);

-- Trabajador 2 (opcional)
SELECT create_business_user(
  '[NOMBRE_SCHEMA]',
  '[username_trabajador2]',
  '[trabajador2@negocio.com]',
  '[contraseña_trabajador2]',
  '[Nombre Trabajador 2]',
  'worker'
);

-- Agrega más trabajadores copiando el bloque anterior

-- ============================================
-- PASO 4: VERIFICAR QUE TODO SE CREÓ CORRECTAMENTE
-- ============================================

-- Ver el negocio creado
SELECT 
  '=== NEGOCIO CREADO ===' as verificacion,
  business_name,
  schema_name,
  active,
  plan_type,
  max_workers,
  created_at
FROM public.businesses
WHERE schema_name = '[NOMBRE_SCHEMA]';

-- Ver usuarios en el mapeo
SELECT 
  '=== USUARIOS MAPEADOS ===' as verificacion,
  username,
  schema_name,
  business_name
FROM public.user_business_map
WHERE schema_name = '[NOMBRE_SCHEMA]';

-- Ver usuarios creados en el negocio
SELECT 
  '=== USUARIOS DEL NEGOCIO ===' as verificacion,
  username,
  email,
  full_name,
  role,
  active,
  password_hash as contraseña
FROM [NOMBRE_SCHEMA].users;

-- Ver tablas disponibles en el negocio
SELECT 
  '=== TABLAS CREADAS ===' as verificacion,
  table_name
FROM information_schema.tables
WHERE table_schema = '[NOMBRE_SCHEMA]'
ORDER BY table_name;

-- ============================================
-- PASO 5: PROBAR EL LOGIN
-- ============================================

-- Probar login del administrador
SELECT 
  '=== PRUEBA LOGIN ADMIN ===' as test,
  success,
  message,
  username,
  business_name,
  schema_name,
  role
FROM login_user('[username_admin]', '[contraseña_admin]');

-- Probar login del trabajador (si lo creaste)
SELECT 
  '=== PRUEBA LOGIN TRABAJADOR ===' as test,
  success,
  message,
  username,
  role
FROM login_user('[username_trabajador1]', '[contraseña_trabajador1]');

-- ============================================
-- ✅ RESULTADO ESPERADO
-- ============================================
/*
Si todo salió bien, deberías ver:

1. NEGOCIO CREADO:
   - business_name: [Tu Negocio]
   - schema_name: [NOMBRE_SCHEMA]
   - active: true
   - plan_type: [PLAN]

2. USUARIOS MAPEADOS:
   - Todos los usuarios listados con su schema

3. USUARIOS DEL NEGOCIO:
   - Admin y trabajadores con sus credenciales

4. TABLAS CREADAS:
   - users
   - reservations
   - daily_stats
   - ai_insights

5. PRUEBA LOGIN:
   - success: true para admin
   - success: true para trabajadores

¡Listo para usar! 🎉
*/

-- ============================================
-- 📝 GUARDAR CREDENCIALES
-- ============================================
/*
IMPORTANTE: Guarda estas credenciales de forma segura

NEGOCIO: [Nombre del Negocio]
SCHEMA: [NOMBRE_SCHEMA]
PLAN: [PLAN]

ADMINISTRADOR:
- Usuario: [username_admin]
- Contraseña: [contraseña_admin]
- Email: [admin@negocio.com]

TRABAJADORES:
- Usuario: [username_trabajador1] | Contraseña: [contraseña_trabajador1]
- Usuario: [username_trabajador2] | Contraseña: [contraseña_trabajador2]

URL DE LA APP: https://tu-app.vercel.app
*/




