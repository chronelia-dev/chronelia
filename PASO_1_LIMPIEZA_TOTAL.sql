-- ============================================
-- 🧹 LIMPIEZA TOTAL DE SUPABASE - CHRONELIA
-- ============================================
-- Este script ELIMINA TODO para empezar desde cero
-- ⚠️ ADVERTENCIA: Esto borrará TODOS los datos
-- ============================================

-- ============================================
-- PASO 1: Eliminar funciones
-- ============================================
DROP FUNCTION IF EXISTS login_user(TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS create_business_schema(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS create_business_user(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT) CASCADE;

-- ============================================
-- PASO 2: Eliminar schemas de negocios
-- ============================================
DROP SCHEMA IF EXISTS business_demo CASCADE;
DROP SCHEMA IF EXISTS business_bella CASCADE;
DROP SCHEMA IF EXISTS business_spa CASCADE;
DROP SCHEMA IF EXISTS business_prueba CASCADE;
DROP SCHEMA IF EXISTS business_test CASCADE;

-- ============================================
-- PASO 3: Eliminar tablas en public
-- ============================================
DROP TABLE IF EXISTS public.user_business_map CASCADE;
DROP TABLE IF EXISTS public.businesses CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.reservations CASCADE;
DROP TABLE IF EXISTS public.customers CASCADE;
DROP TABLE IF EXISTS public.daily_stats CASCADE;
DROP TABLE IF EXISTS public.ai_insights CASCADE;

-- ============================================
-- VERIFICACIÓN: Ver qué quedó
-- ============================================
-- Ver funciones restantes
SELECT 
  '=== FUNCIONES RESTANTES ===' as info,
  proname as nombre_funcion
FROM pg_proc 
WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
  AND proname LIKE '%login%' OR proname LIKE '%business%' OR proname LIKE '%user%';

-- Ver schemas restantes (solo negocios)
SELECT 
  '=== SCHEMAS DE NEGOCIOS RESTANTES ===' as info,
  schema_name
FROM information_schema.schemata
WHERE schema_name LIKE 'business_%';

-- Ver tablas en public
SELECT 
  '=== TABLAS EN PUBLIC ===' as info,
  table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- ============================================
-- RESULTADO ESPERADO
-- ============================================
/*
Después de ejecutar este script, deberías ver:

FUNCIONES RESTANTES: (vacío)
SCHEMAS DE NEGOCIOS RESTANTES: (vacío)
TABLAS EN PUBLIC: (solo tablas del sistema de Supabase como auth.users, storage.buckets, etc)

Si ves resultados vacíos o solo tablas del sistema, ¡la limpieza fue exitosa! ✅

SIGUIENTE PASO:
Ejecuta: PASO_2_SETUP_COMPLETO.sql
*/




