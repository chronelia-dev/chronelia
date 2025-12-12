-- ============================================
-- 🧪 CREAR NEGOCIO DE PRUEBA - DEMO
-- ============================================
-- Negocio de prueba para testing en tiempo real
-- Fecha: Diciembre 8, 2025
-- ============================================

-- ============================================
-- PASO 1: CREAR EL NEGOCIO
-- ============================================

SELECT create_business_schema(
  'business_demo',                  -- Schema único
  'Barbería Demo',                  -- Nombre del negocio
  'demo@chronelia.app',             -- Email
  '+34 600 111 222',                -- Teléfono
  'Calle Principal 123, Madrid',    -- Dirección
  'premium',                        -- Plan: basic/premium/enterprise
  10                                -- Máximo trabajadores
);

-- ============================================
-- PASO 2: CREAR USUARIO ADMIN
-- ============================================

SELECT create_business_user(
  'business_demo',                  -- Schema del negocio
  'admin_demo',                     -- Username para login
  'admin@demo.com',                 -- Email admin
  'demo2025',                       -- Contraseña (simple para demo)
  'Administrador Demo',             -- Nombre completo
  'admin'                           -- Rol: admin
);

-- ============================================
-- PASO 3: CREAR TRABAJADORES DE PRUEBA
-- ============================================

-- Trabajador 1: Barbero
SELECT create_business_user(
  'business_demo',
  'barbero_carlos',
  'carlos@demo.com',
  'carlos123',
  'Carlos Barbero',
  'worker'
);

-- Trabajador 2: Asistente
SELECT create_business_user(
  'business_demo',
  'asistente_ana',
  'ana@demo.com',
  'ana123',
  'Ana Asistente',
  'worker'
);

-- ============================================
-- PASO 4: VERIFICAR CREACIÓN
-- ============================================

-- Ver negocio creado
SELECT 
  '🏢 NEGOCIO CREADO' as status,
  schema_name as "Schema",
  business_name as "Nombre",
  plan_type as "Plan",
  max_workers as "Max Trabajadores",
  active as "Activo",
  created_at as "Creado"
FROM public.businesses
WHERE schema_name = 'business_demo';

-- Ver usuarios del negocio
SELECT 
  '👥 USUARIOS CREADOS' as status,
  username as "Usuario",
  email as "Email",
  full_name as "Nombre Completo",
  role as "Rol",
  active as "Activo"
FROM business_demo.users
ORDER BY role DESC, username;

-- Ver mapeo para login
SELECT 
  '🔐 MAPEO LOGIN' as status,
  username as "Usuario",
  schema_name as "Schema",
  business_name as "Negocio"
FROM public.user_business_map
WHERE schema_name = 'business_demo';

-- Ver tablas creadas
SELECT 
  '📋 TABLAS DEL NEGOCIO' as status,
  table_name as "Tabla"
FROM information_schema.tables
WHERE table_schema = 'business_demo'
ORDER BY table_name;

-- ============================================
-- PASO 5: PROBAR LOGIN
-- ============================================

-- Test login admin
SELECT 
  '🔓 TEST LOGIN ADMIN' as test,
  success as "Éxito",
  message as "Mensaje",
  username as "Usuario",
  business_name as "Negocio",
  schema_name as "Schema",
  role as "Rol"
FROM login_user('admin_demo', 'demo2025');

-- Test login trabajador
SELECT 
  '🔓 TEST LOGIN TRABAJADOR' as test,
  success as "Éxito",
  message as "Mensaje",
  username as "Usuario",
  role as "Rol"
FROM login_user('barbero_carlos', 'carlos123');

-- ============================================
-- ✅ CREDENCIALES DEL NEGOCIO DEMO
-- ============================================

/*

🎉 NEGOCIO DE PRUEBA CREADO

📋 INFORMACIÓN:
  Negocio: Barbería Demo
  Schema: business_demo
  Plan: Premium
  Max Trabajadores: 10

🔑 CREDENCIALES:

  ADMINISTRADOR:
    Usuario: admin_demo
    Contraseña: demo2025
    Email: admin@demo.com

  TRABAJADOR 1:
    Usuario: barbero_carlos
    Contraseña: carlos123
    Email: carlos@demo.com

  TRABAJADOR 2:
    Usuario: asistente_ana
    Contraseña: ana123
    Email: ana@demo.com

🌐 PRUEBA EN LA APP:
  1. Ve a tu app: https://tu-app.vercel.app
  2. Login con: admin_demo / demo2025
  3. Empieza a crear reservas y probar

🧪 DATOS DE PRUEBA:
  - Este negocio es independiente
  - Todos los datos están aislados
  - Perfecto para testing sin afectar otros negocios

*/

-- ============================================
-- 🗑️ ELIMINAR NEGOCIO DEMO (SI YA NO LO NECESITAS)
-- ============================================

/*
-- ⚠️ CUIDADO: Esto eliminará TODOS los datos del negocio demo

-- Paso 1: Eliminar usuarios del negocio
DELETE FROM business_demo.users;

-- Paso 2: Eliminar registros del negocio
DELETE FROM public.user_business_map WHERE schema_name = 'business_demo';
DELETE FROM public.businesses WHERE schema_name = 'business_demo';

-- Paso 3: Eliminar el schema completo
DROP SCHEMA IF EXISTS business_demo CASCADE;

-- Verificar eliminación
SELECT * FROM public.businesses WHERE schema_name = 'business_demo';
-- Debería devolver 0 resultados
*/






