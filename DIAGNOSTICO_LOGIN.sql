-- ============================================
-- DIAGNÓSTICO COMPLETO DE LOGIN - CHRONELIA
-- ============================================
-- Este script verifica TODO lo necesario para que funcione el login
-- Ejecuta esto en Supabase SQL Editor y comparte los resultados

-- ============================================
-- ⚡ TEST RÁPIDO PRIMERO (30 segundos)
-- ============================================
-- Si solo quieres saber cuál es el problema, ejecuta esto primero:

SELECT 
  '⚡ TEST RÁPIDO' as tipo_test,
  CASE 
    WHEN NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'login_user') THEN
      '❌ Función login_user() NO EXISTE → Ejecuta: MULTI_TENANT_SCHEMAS.sql'
    WHEN pg_get_function_arguments((SELECT oid FROM pg_proc WHERE proname = 'login_user')) LIKE '%p_username%' THEN
      '❌ PROBLEMA ENCONTRADO: Parámetros antiguos (p_username) → Ejecuta: FIX_LOGIN_PARAMETROS.sql'
    WHEN pg_get_function_arguments((SELECT oid FROM pg_proc WHERE proname = 'login_user')) LIKE '%input_username%' THEN
      '✅ Función correcta (input_username) → Si login falla, continúa con diagnóstico completo abajo'
    ELSE
      '⚠️ Estado desconocido → Ejecuta diagnóstico completo abajo'
  END as resultado;

-- ============================================
-- 📋 Si el test rápido mostró ✅ pero el login falla,
--    continúa ejecutando el resto de este script
-- ============================================

-- ============================================
-- 1. VERIFICAR QUE EXISTE LA FUNCIÓN login_user
-- ============================================
SELECT 
  '=== FUNCIÓN login_user ===' as check_type,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_proc 
      WHERE proname = 'login_user'
    ) THEN '✅ EXISTE'
    ELSE '❌ NO EXISTE - Debes ejecutar el script MULTI_TENANT_SCHEMAS.sql'
  END as status;

-- ============================================
-- 2. VERIFICAR PARÁMETROS DE LA FUNCIÓN
-- ============================================
SELECT 
  '=== PARÁMETROS DE login_user ===' as info,
  p.proname as nombre_funcion,
  pg_get_function_arguments(p.oid) as parametros,
  pg_get_function_result(p.oid) as retorna
FROM pg_proc p
WHERE p.proname = 'login_user';

-- ============================================
-- 3. VERIFICAR TABLA user_business_map
-- ============================================
SELECT 
  '=== TABLA user_business_map ===' as check_type,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name = 'user_business_map'
    ) THEN '✅ EXISTE'
    ELSE '❌ NO EXISTE - Tabla crítica faltante'
  END as status;

-- ============================================
-- 4. VER USUARIOS EN EL MAPEO
-- ============================================
SELECT 
  '=== USUARIOS EN MAPEO ===' as info,
  username,
  schema_name,
  business_name
FROM public.user_business_map
ORDER BY created_at DESC;

-- ============================================
-- 5. VERIFICAR NEGOCIOS CREADOS
-- ============================================
SELECT 
  '=== NEGOCIOS REGISTRADOS ===' as info,
  business_name,
  schema_name,
  active,
  plan_type,
  max_workers
FROM public.businesses
ORDER BY created_at DESC;

-- ============================================
-- 6. PROBAR LOGIN CON USUARIO admin
-- ============================================
-- Esto prueba exactamente lo que hace la app
SELECT 
  '=== PRUEBA DE LOGIN: admin ===' as test,
  *
FROM login_user('admin', 'chronelia2025');

-- ============================================
-- 7. VER USUARIOS EN EL SCHEMA business_demo
-- ============================================
SELECT 
  '=== USUARIOS EN business_demo ===' as info,
  username,
  email,
  full_name,
  role,
  active,
  created_at
FROM business_demo.users
WHERE true
UNION ALL
SELECT 
  '(Si este query falla, el schema business_demo no existe)' as info,
  NULL, NULL, NULL, NULL, NULL, NULL
WHERE NOT EXISTS (
  SELECT 1 FROM information_schema.schemata 
  WHERE schema_name = 'business_demo'
);

-- ============================================
-- 8. VERIFICAR CONTRASEÑAS
-- ============================================
SELECT 
  '=== VERIFICAR CONTRASEÑAS ===' as info,
  u.username,
  u.password_hash as contraseña_guardada,
  CASE 
    WHEN u.password_hash = 'chronelia2025' THEN '✅ Correcta'
    WHEN u.password_hash = 'admin123' THEN '⚠️ Es admin123, no chronelia2025'
    ELSE '❌ Contraseña diferente'
  END as verificacion
FROM business_demo.users u
WHERE u.username = 'admin';

-- ============================================
-- 9. RESUMEN DE DIAGNÓSTICO
-- ============================================
SELECT 
  '=== RESUMEN DE ESTADO ===' as info,
  json_build_object(
    'funcion_login_existe', EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'login_user'),
    'tabla_mapeo_existe', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'user_business_map'),
    'tabla_businesses_existe', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'businesses'),
    'schema_demo_existe', EXISTS(SELECT 1 FROM information_schema.schemata WHERE schema_name = 'business_demo'),
    'usuarios_en_mapeo', (SELECT COUNT(*) FROM public.user_business_map),
    'negocios_registrados', (SELECT COUNT(*) FROM public.businesses)
  ) as estado;

-- ============================================
-- 10. INSTRUCCIONES SEGÚN EL RESULTADO
-- ============================================
/*
📋 INSTRUCCIONES SEGÚN LOS RESULTADOS:

1️⃣ Si "login_user NO EXISTE":
   → Ejecuta: MULTI_TENANT_SCHEMAS.sql

2️⃣ Si "user_business_map NO EXISTE":
   → Ejecuta: MULTI_TENANT_SCHEMAS.sql

3️⃣ Si "USUARIOS EN MAPEO" está vacío:
   → El sistema está configurado pero no hay usuarios
   → Ejecuta la sección de crear usuarios del script

4️⃣ Si "PRUEBA DE LOGIN" retorna success = false:
   → Revisa el mensaje de error
   → Puede ser contraseña incorrecta o usuario inactivo

5️⃣ Si "PRUEBA DE LOGIN" da error de función:
   → Los parámetros de la función no coinciden
   → Hay que actualizar la función a usar input_username/input_password

6️⃣ Si TODO está ✅ pero el login NO funciona en la app:
   → El problema está en el frontend (supabase.js)
   → Verifica la consola del navegador (F12)
*/

-- ============================================
-- 🎯 SCRIPT DE EMERGENCIA - CREAR USUARIO
-- ============================================
-- Si todo lo demás falla, ejecuta esto para crear un usuario directo:
/*
-- Paso 1: Asegurarse que existe el schema
CREATE SCHEMA IF NOT EXISTS business_demo;

-- Paso 2: Asegurarse que existe la tabla users
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

-- Paso 3: Insertar usuario admin
INSERT INTO business_demo.users (username, email, password_hash, full_name, role, active)
VALUES ('admin', 'admin@chronelia.com', 'chronelia2025', 'Administrador Demo', 'admin', true)
ON CONFLICT (username) DO UPDATE 
SET password_hash = 'chronelia2025', active = true;

-- Paso 4: Asegurar que está en el mapeo
INSERT INTO public.user_business_map (username, schema_name, business_name)
VALUES ('admin', 'business_demo', 'Demo Chronelia')
ON CONFLICT (username) DO UPDATE 
SET schema_name = 'business_demo', business_name = 'Demo Chronelia';

-- Paso 5: Verificar
SELECT * FROM business_demo.users WHERE username = 'admin';
SELECT * FROM public.user_business_map WHERE username = 'admin';
*/
