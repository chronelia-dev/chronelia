-- ============================================
-- DIAGNÓSTICO RÁPIDO - Por qué no se guardan las reservas
-- ============================================
-- Ejecuta este script en Supabase SQL Editor
-- Te dirá exactamente qué falta configurar

-- ============================================
-- TEST 1: Verificar funciones RPC existen
-- ============================================
SELECT 
  '🔍 TEST 1: Funciones RPC' as test,
  routine_name as funcion,
  CASE 
    WHEN routine_name IS NOT NULL THEN '✅ Existe'
    ELSE '❌ No existe'
  END as estado
FROM information_schema.routines
WHERE routine_name IN (
  'save_reservation',
  'get_active_reservations',
  'get_reservation_history',
  'get_workers'
)
ORDER BY routine_name;

-- ============================================
-- TEST 2: Verificar usuarios tienen schema_name
-- ============================================
SELECT 
  '🔍 TEST 2: Usuarios' as test,
  email,
  schema_name,
  business_name,
  role,
  CASE 
    WHEN schema_name IS NOT NULL THEN '✅ OK'
    ELSE '❌ SIN SCHEMA'
  END as estado
FROM public.users
ORDER BY role, email;

-- ============================================
-- TEST 3: Verificar tabla reservations existe
-- ============================================
SELECT 
  '🔍 TEST 3: Tablas' as test,
  table_schema as schema,
  table_name as tabla,
  '✅ Existe' as estado
FROM information_schema.tables
WHERE table_name = 'reservations'
  AND table_schema != 'public'  -- Solo schemas de negocios
ORDER BY table_schema;

-- ============================================
-- TEST 4: Verificar reservas activas actuales
-- ============================================
-- NOTA: Reemplaza 'locosxcerveza' con tu schema
SELECT 
  '🔍 TEST 4: Reservas Activas' as test,
  COUNT(*) as cantidad,
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ Hay reservas'
    ELSE '⚠️ Sin reservas'
  END as estado
FROM locosxcerveza.reservations
WHERE status = 'active';

-- ============================================
-- TEST 5: Verificar permisos en funciones
-- ============================================
SELECT 
  '🔍 TEST 5: Permisos' as test,
  proname as funcion,
  prosecdef as security_definer,
  CASE 
    WHEN prosecdef THEN '✅ SECURITY DEFINER'
    ELSE '⚠️ Sin SECURITY DEFINER'
  END as estado
FROM pg_proc
WHERE proname IN (
  'save_reservation',
  'get_active_reservations'
)
ORDER BY proname;

-- ============================================
-- RESUMEN DEL DIAGNÓSTICO
-- ============================================
-- Ejecuta todos los tests de arriba y verifica:
--
-- ✅ TEST 1: Deben aparecer 4 funciones
-- ✅ TEST 2: Todos los usuarios deben tener schema_name
-- ✅ TEST 3: Debe aparecer al menos 1 tabla (de tu negocio)
-- ⚠️ TEST 4: Puede estar vacío si no hay reservas activas
-- ✅ TEST 5: Ambas funciones deben tener SECURITY DEFINER

-- ============================================
-- SI ALGÚN TEST FALLA:
-- ============================================

-- ❌ TEST 1 falla (funciones no existen):
-- → Ejecuta el archivo completo: FUNCIONES_RPC_MULTI_TENANT.sql

-- ❌ TEST 2 falla (usuarios sin schema_name):
-- → Ejecuta:
/*
UPDATE public.users
SET 
  schema_name = 'locosxcerveza',  -- Reemplaza con tu schema
  business_id = (SELECT id FROM public.businesses WHERE schema_name = 'locosxcerveza')
WHERE email = 'trabajador@chronelia.com';  -- Reemplaza con el email del usuario
*/

-- ❌ TEST 3 falla (tabla no existe):
-- → Ejecuta el script de creación del schema completo

-- ❌ TEST 5 falla (sin permisos):
-- → Las funciones deben tener SECURITY DEFINER (se crea automáticamente en FUNCIONES_RPC_MULTI_TENANT.sql)

-- ============================================
-- NOTA IMPORTANTE
-- ============================================
-- Después de cualquier cambio en usuarios:
-- 1. El usuario debe CERRAR SESIÓN
-- 2. VOLVER A INICIAR SESIÓN
-- 3. Para que el nuevo schema_name se cargue en localStorage

